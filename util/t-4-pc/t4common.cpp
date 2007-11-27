//=============================================================================
// T^4 PC Terminal
//=============================================================================
// t4common.cpp
// Contiene la implementación de funciones comunes, útiles a todo el programa
//-----------------------------------------------------------------------------
// Desarrollado por Mariano Beiró y Mariano Chouza para Laboratorio de
// Microcomputadoras.
//-----------------------------------------------------------------------------
// Desarrollo comenzado el 27/11/2007
//=============================================================================

#include "stdafx.h"

#include "t4common.h"
#include <cassert>
#include <fstream>

namespace
{
	// Revisa que sea un encabezado
	bool isHeader(const std::string& hl)
	{
		size_t hlLen = hl.length();

		if (hlLen < 3)
			return false;

		return (hl[0] == '[' && hl[hlLen - 1] == ']');
	}

	// Revisa si es un comentario o en blanco
	bool isCommentOrBlank(const std::string& l)
	{
		if (l.length() == 0)
			return true;

		return l[0] == ';';
	}

	// Obtiene el nombre de la sección desde un encabezado
	std::string getSectionNameFromHeader(const std::string& hl)
	{
		size_t hlLen = hl.length();
		
		assert(hlLen >= 3 && hl[0] == '[' && hl[hlLen - 1] == ']');

		return hl.substr(1, hlLen - 2);
	}

	// Parsea un par clave-valor a partir de una línea
	std::pair<std::string, std::string>
		parseKeyValueLine(const std::string& l)
	{
		using std::make_pair;
		using std::string;
		
		// Busco la posición del '='
		size_t eqPos = l.find_first_of('=');

		// Si no lo encuentrom o es el primero, es error
		if (eqPos == string::npos || eqPos == 0)
			// FIXME: No muy descriptivo
			throw;

		// Parto por el '='
		return make_pair(l.substr(0, eqPos), l.substr(eqPos + 1));
	}

	// Agrega un par clave-valor
	void addKeyValuePairToSection(TConfigMap& cm,
		const std::pair<std::string, std::string>& kvp)
	{
		cm[kvp.first] = kvp.second;
	}
}

TConfigSecMap parseINIFile(const std::string& filename)
{
	using std::getline;
	using std::ifstream;
	using std::pair;
	using std::string;
	
	// Valor de retorno
	TConfigSecMap ret;

	// Sección actual
	string curSection;

	// Línea
	string line;

	// Abro el archivo
	ifstream iniFile(filename.c_str());

	// Si no está abierto, es error
	if (!iniFile.is_open())
		// FIXME: Lanzar algo más específico
		throw;

	// Leo línea a línea
	while (getline(iniFile, line))
	{
		// Me fijo si es un encabezado
		if (isHeader(line))
		{
			// Cambio la sección actual
			curSection = getSectionNameFromHeader(line);
		}
		// Me fijo si es un comentario o linea en blanco
		else if (isCommentOrBlank(line))
		{
			// Lo ignoro...
		}
		// Si no tiene que ser un valor...
		else
		{
			// Lo parseo
			pair<string, string> keyValuePair = parseKeyValueLine(line);

			// Lo agrego
			addKeyValuePairToSection(ret[curSection], keyValuePair);
		}
	}

	// Devuelvo el mapa de configuración con secciones
	return ret;
}

int readIntFromConfigMap(const TConfigMap& configMap,
						 const std::string& key)
{
	const std::string& val = configMap.find(key)->second;
	return strtol(val.c_str(), 0, 0);
}

const std::string& readStringFromConfigMap(const TConfigMap& configMap,
										   const std::string& key)
{
	return configMap.find(key)->second;
}
