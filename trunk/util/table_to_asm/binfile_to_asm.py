################################################################################
# binfile_to_asm.py
#-------------------------------------------------------------------------------
# Se encarga de transformar un archivo binario cualquiera a una serie de
# instrucciones 'db'. Recibe dos parámetros, el primero indicando el archivo
# de entrada y el segundo el archivo de salida.
#-------------------------------------------------------------------------------
# Desarrollado por Mariano Beiró y Mariano Chouza para Laboratorio de
# Microcomputadoras.
#-------------------------------------------------------------------------------
# Desarrollo comenzado el 15-11-2007
################################################################################

import sys

#
# Constantes
#

# Cantidad de bytes por cada 'db'
BYTES_PER_LINE = 10

#
# Escribe una línea de bytes como un 'db'
#
def writeAsDB(outFile, bytes):

    # Escribo el 'db'
    outFile.write('db ')

    # Para cada byte...
    for byte in bytes[:-1]:

        # Escribo el byte seguido de una coma
        outFile.write('0x%02x, ' % ord(byte))

    # El último va sin coma
    outFile.write('0x%02x\n' % ord(bytes[-1]))

# Reviso la cantidad de parámetros
if len(sys.argv) != 3:

    # Cantidad incorrecta, imprimo sintaxis y salgo
    sys.stderr.write('Sintaxis: binfile_to_asm <binario> <salida>')
    exit(1)

# Abro los dos archivos
inFile = open(sys.argv[1], 'rb')
outFile = open(sys.argv[2], 'w')

# Mientras haya algo en la salida
bytes = ' '
while bytes != '':
    
    # Leo la cantidad de bytes requerida para una línea de la salida
    bytes = inFile.read(BYTES_PER_LINE)

    # Escribo esa línea en el archivo de salida como un 'db'
    if len(bytes) > 0:
        writeAsDB(outFile, bytes)

# Listo
