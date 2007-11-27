//=============================================================================
// T^4 PC Terminal
//=============================================================================
// serial_port.cpp
// Implementa la clase SerialPort, encargada de encapsular el acceso al puerto
// serie.
//-----------------------------------------------------------------------------
// Desarrollado por Mariano Beiró y Mariano Chouza para Laboratorio de
// Microcomputadoras.
//-----------------------------------------------------------------------------
// Desarrollo comenzado el 26/11/2007
//=============================================================================

#include "stdafx.h"
#include "serial_port.h"

// Encapsula los 3 parámetros que se necesitan para alimentar en forma
// segura al buffer de lectura :-)
struct SFeedingParams
{
	// Constructor
	SFeedingParams(HANDLE hComm, std::vector<unsigned char>& readBuffer,
		CCriticalSection& cs) :
	hComm_(hComm), readBuffer_(readBuffer), cs_(cs), exitNow_(false)
	{
	}

	// Handle del puerto
	HANDLE hComm_;
	// Buffer de lectura
	std::vector<unsigned char> readBuffer_;
	// Critical section
	CCriticalSection& cs_;
	// Quiero que salga
	bool exitNow_;
};

namespace
{
	// Clase helper de CCriticalSection
	class Lock
	{
		CCriticalSection& cs_;
	public:
		Lock(CCriticalSection& cs) : cs_(cs)
		{
			cs_.Lock();
		}
		~Lock()
		{
			cs_.Unlock();
		}
	};

	// Alimenta al buffer de lectura
	UINT feedReadBuffer(LPVOID lpParams)
	{
		using std::back_inserter;
		using std::copy;
		
		// Buffer interno
		char buffer[1024];

		// Cantidad de bytes leídos
		DWORD nobr;
		
		// Obtengo los parámetros
		SFeedingParams& fp = *(SFeedingParams*)lpParams;

		// Loop "infinito"
		while (true)
		{
			// Pido permiso para acceder a los datos compartidos
			fp.cs_.Lock();

			// Si quieren que salga, salgo...
			if (fp.exitNow_)
			{
				fp.cs_.Unlock();
				return 0;
			}
			
			// Leo del puerto serie
			::ReadFile(fp.hComm_, buffer, 1024, &nobr, 0);

			// Copio al final del buffer de lectura lo que acabo de leer
			copy(buffer, buffer + nobr, back_inserter(fp.readBuffer_));

			// Dejo de acceder a los datos compartidos
			fp.cs_.Unlock();

			// Espero un poco para evitar consumo 100 % de CPU
			::Sleep(1);
		}
	}
}

SerialPort::SerialPort(const TConfigMap& config)
{
	// Abre el puerto
	hComm_ = ::CreateFile(readStringFromConfigMap(config, "PortName").c_str(),
		GENERIC_READ | GENERIC_WRITE, 0, 0, OPEN_EXISTING, 0, 0);

	// Si falla, lanzo una excepción
	if (hComm_ == INVALID_HANDLE_VALUE)
		// FIXME: Lanzar algo más específico
		throw;
	
	// Bloque de configuración
	DCB dcb;

	// Lo inicializo con el existente
	::GetCommState(hComm_, &dcb);

	// Lo actualizo con la info de la string
	BOOL ret =
	::BuildCommDCB(readStringFromConfigMap(config, "ConfigString").c_str(),
		&dcb);

	// Si falla, lanzo una excepción
	if (!ret)
	{
		::CloseHandle(hComm_);

		// FIXME: Lanzar algo más específico
		throw;
	}

	// Pone el nuevo estado al puerto...
	ret =
	::SetCommState(hComm_, &dcb);

	// Si falla, lanzo una excepción
	if (!ret)
	{
		::CloseHandle(hComm_);

		// FIXME: Lanzar algo más específico
		throw;
	}

	// Timeouts
	COMMTIMEOUTS ct;
	ct.ReadIntervalTimeout = MAXDWORD;
	ct.ReadTotalTimeoutConstant = 0;
	ct.ReadTotalTimeoutMultiplier = 0;
	ct.WriteTotalTimeoutConstant = 0;
	ct.WriteTotalTimeoutMultiplier = 0;

	// Pongo los timeouts
	ret =
	::SetCommTimeouts(hComm_, &ct);

	// Si falla, lanzo una excepción
	if (!ret)
	{
		::CloseHandle(hComm_);

		// FIXME: Lanzar algo más específico
		throw;
	}

	// Armo la estructura para sincronizar con el "feeding thread"
	pFTParams_ = new SFeedingParams(hComm_, readBuffer_, cs_);

	// Lanza el thread de alimentación
	pFT_ = ::AfxBeginThread(feedReadBuffer, pFTParams_);

	// Desactivo el auto-delete
	pFT_->m_bAutoDelete = false;
}

SerialPort::~SerialPort()
{
	// Espero a adquirir la CS
	cs_.Lock();
	
	// Cierra el puerto
	::CloseHandle(hComm_);

	// Le digo al thread que termine
	pFTParams_->exitNow_ = true;

	// Libero la CS...
	cs_.Unlock();

	// Espero a que termine...
	::WaitForSingleObject(pFT_->m_hThread, INFINITE);

	// Libero el thread, ya que no se suicida...
	delete pFT_;

	// Libero los parámetros
	delete pFTParams_;
}

std::vector<unsigned char> SerialPort::read() const
{
	Lock l(cs_);
	
	// Como la lectura real podría bloquearse, solo devuelve lo que hay en el
	// buffer
	std::vector<unsigned char> ret;
	ret.swap(readBuffer_);
	return ret;
}

void SerialPort::write(const std::vector<unsigned char>& data) const
{
	write(&data[0], data.size());
}

void SerialPort::write(const unsigned char* buffer, size_t length) const
{
	Lock l(cs_);

	// Número de bytes escritos
	DWORD nobw;

	::WriteFile(hComm_, buffer, static_cast<DWORD>(length), &nobw, 0);

	// Si no pude escribir todos hay un problema
	if (nobw != length)
		// FIXME: Lanzar algo más específico
		throw;
}