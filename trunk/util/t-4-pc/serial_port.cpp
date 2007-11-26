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

SerialPort::SerialPort(const TConfigMap& config)
{
}

SerialPort::~SerialPort()
{
}

std::vector<unsigned char> SerialPort::read() const
{
	return std::vector<unsigned char>();
}

void SerialPort::write(const std::vector<unsigned char>& data) const
{
}
