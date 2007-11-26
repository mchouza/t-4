//=============================================================================
// T^4 PC Terminal
//=============================================================================
// t4common.h
// Contiene definiciones comunes, útiles a todo el programa
//-----------------------------------------------------------------------------
// Desarrollado por Mariano Beiró y Mariano Chouza para Laboratorio de
// Microcomputadoras.
//-----------------------------------------------------------------------------
// Desarrollo comenzado el 25/11/2007
//=============================================================================

#ifndef T4COMMON_H
#define T4COMMON_H

#include <map>
#include <string>

// Símbolos que van en el tablero
enum ET4Symbol
{
	T4S_E = 0,
	T4S_X = 1,
	T4S_O = 2
};

// Mapa de configuración
typedef std::map<std::string, std::string> TConfigMap;

// Mapa de secciones de configuración
typedef std::map<std::string, TConfigMap> TConfigSecMap;

// PI!!!
const double PI = 3.1415926535897932384626433832795;

#endif
