# Generalidades #

_Rellenar esta sección con una descripción general del sistema._

# Resolución #

Uno de los factores a considerar en cualquier sistema gráfico es la resolución. En el caso de nuestro sistema, esto es aún más importante, ya que la velocidad del microcontrolador (un Atmel AT89S52), junto a la velocidad del barrido horizontal de los TVs, pone un límite definido a la resolución horizontal. De hecho, uno de los factores decisivos en la elección de un AT89S52 en lugar de un AT89S51 fue el hecho de que nos permitía trabajar con un reloj de 33 MHz (siendo el otro el que tuviera 8 KB de ROM, permitiéndonos guardar la tabla de juego completa, que ocupa unos 4.7 KB).

De acuerdo a la [versión inicial del framework](http://t-4.googlecode.com/svn/tags/framework-complete/), la resolución horizontal es de 71 pixels, equivalente a 51.617 us  de los 64 us que posee una línea en total. La resolución vertical es algo más problemática de determinar: si bien no tenemos problemas en forma directa con ella, ya que los tiempos no son críticos y existen 287 líneas activas, el tamaño de los gráficos requeridos y la relación de aspecto de los pixels nos obligan a ponerle límites.

Tomando la relación de aspecto 4:3 de la pantalla y buscando pixels cuadrados tendríamos 71 `*` 3 / 4 ~= 53 pixels. Pero no podemos tomar una cantidad arbitraria de líneas para cada pixel, sino que (lamentablemente :-) debe ser entera. Por lo tanto, elegimos 5 líneas por pixel, lo que nos daría un total de 57 pixels de resolución vertical y nos dejaría libres dos líneas. Probablemente más que esta cantidad sea efectivamente invisible, ya que, al menos durante las pruebas iniciales, la imagen se extendía hasta el borde y, con toda probabilidad, más alla.

Para determinar en detalle la resolución efectiva (o sea que entre en la pantalla) con la que podemos trabajar será necesario efectuar experimentos...