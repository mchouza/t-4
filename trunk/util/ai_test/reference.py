################################################################################
# reference.py
#-------------------------------------------------------------------------------
# Obtiene resultados de referencia para comparar con los de ai_test.
#-------------------------------------------------------------------------------
# Desarrollado por Mariano Beiró y Mariano Chouza para Laboratorio de
# Microcomputadoras.
#-------------------------------------------------------------------------------
# Desarrollo comenzado el 21-11-2007
################################################################################

# Abro el archivo no comprimido
uncompFile = open('../table_gen/uncomp.bin')

# Lo leo todo a memoria
uncompData = map(ord, uncompFile.read())

# Reduzco el vector con las dos operaciones
sumUCD = reduce(lambda x, y: x + y, uncompData) % 256
xorUCD = reduce(lambda x, y: x ^ y, uncompData)

# Imprimo los valores
print 'suma: %02x xor: %02x' % (sumUCD, xorUCD)

# Listo
