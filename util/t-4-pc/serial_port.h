//=============================================================================
// T^4 PC Terminal
//=============================================================================
// serial_port.h
// Declara la clase SerialPort, encargada de encapsular el acceso al puerto
// serie.
//-----------------------------------------------------------------------------
// Desarrollado por Mariano Beiró y Mariano Chouza para Laboratorio de
// Microcomputadoras.
//-----------------------------------------------------------------------------
// Desarrollo comenzado el 25/11/2007
//=============================================================================

#ifndef SERIAL_PORT_H
#define SERIAL_PORT_H

#include "t4common.h"
#include <vector>

// Forward	
struct SFeedingParams;

// Encapsula el acceso al puerto serie
class SerialPort
{
	// Handle del puerto
	HANDLE hComm_;

	// Critical section para sincronizar acceso al buffer de lectura y al
	// handle
	mutable CCriticalSection cs_;

	// Buffer de lectura
	mutable std::vector<unsigned char> readBuffer_;

	// Parámetros para el "feeding thread"
	SFeedingParams* pFTParams_;

	// Thread de espera
	CWinThread* pFT_;

	// Para impedir copias...
	SerialPort(const SerialPort&);
	const SerialPort& operator=(const SerialPort&);

public:
	// C & D
	SerialPort(const TConfigMap& config);
	virtual ~SerialPort();

	// Escribe al puerto serie
	void write(const std::vector<unsigned char>& data) const;

	// Escribe al puerto serie
	void write(const unsigned char* buffer, size_t length) const;

	// Lee desde el puerto serie
	std::vector<unsigned char> read() const;
};

#endif
