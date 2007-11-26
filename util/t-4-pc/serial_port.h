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

// Encapsula el acceso al puerto serie
class SerialPort
{
public:
	// C & D
	SerialPort(const TConfigMap& config);
	virtual ~SerialPort();

	// Escribe al puerto serie
	void write(const std::vector<unsigned char>& data) const;

	// Lee desde el puerto serie
	std::vector<unsigned char> read() const;
};

#endif
