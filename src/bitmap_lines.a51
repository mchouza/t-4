;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Dibujo del tablero
;;;; Partes para el dibujo de las líneas del tablero

NAME DIBUJO_TABLERO_PARTES_LINEA

;;; Inclusiones
$INCLUDE(constantes.inc)
$INCLUDE(macros.inc)
$INCLUDE(variables.inc)

;;; De acuerdo a lo medido, se utilizarán 5 líneas físicas para constituir una
;;; línea lógica, de modo que la relación de aspecto de cada pixel sea cercana
;;; a 1.


;;; De acuerdo a lo diseñado en las imágenes, elegimos bitmaps de 10 X 10
;;; para representar a las Xs y Ox.

;;; Bitmap de la X:
;;;	##......##
;;; ###....###
;;; .###..###.
;;; ..######..
;;; ...####...
;;; ...####...
;;; ..######..
;;; .###..###.
;;; ###....###
;;;	##......##

;;; Bitmap de la O:
;;;	....##....
;;; ..######..
;;; .###..###.
;;; .##....##.
;;; ##......##
;;; ##......##
;;; .##....##.
;;; .###..###.
;;; ..######..
;;;	....##....

;;; Observar que las últimas 5 líneas de cada símbolo son un reflejo de las
;;; primeras 5.

;;; En este módulo se implementa el dibujo de cada tipo de línea física, que
;;; se corresponden con los tipos de línea lógica.

;;; Hay 3 tipos de línea:
;;; - Línea de un separador horizontal.
;;; - Línea de un espacio vertical.
;;; - Línea de un símbolo, que a su vez se clasifican según la fila.

;;; Cada tipo de línea tiene un símbolo, que es la label asociada al código
;;; que la dibuja.
;;; LSH -> Línea del separador horizontal.
;;; LEV -> Línea del espacio vertical.
;;; LS_n -> Línea de la fila n del símbolo

;;; Tengo un total de 44 líneas lógicas que forman el tablero. Son:
;;; 0 a 2 -> LEV
;;; 2 a 12 -> LS_xx, donde xx es el número de línea - 2
;;; 12 a 14 -> LEV
;;; 14 a 15 -> LSH
;;; 15 a 17 -> LEV
;;; 17 a 27 -> LS_xx, donde xx es el número de línea - 17
;;; 27 a 29 -> LEV
;;; 29 a 30 -> LSH
;;; 30 a 32 -> LEV
;;; 32 a 42 -> LS_xx, donde xx es el número de línea - 32
;;; 42 a 44 -> LEV

;;; La decisión de en que línea caer corresponde al loop principal.

;;; La estructura gráfica de las líneas, es:
;;; - LEV:
;;;   0 a 14 -> negro
;;;   14 a 15 -> gris
;;;   15 a 29 -> negro
;;;   29 a 30 -> gris
;;;   30 a 44 -> negro
;;; - LSH:
;;;   0 a 44 -> gris
;;; - LS_n:
;;;   0 a 2 -> negro
;;;   2 a 12 -> línea 'n' símbolo columna 0
;;;   12 a 14 -> negro
;;;   14 a 15 -> gris
;;;   15 a 17 -> negro
;;;   17 a 27 -> línea 'n' símbolo columna 1
;;;   27 a 29 -> negro
;;;   29 a 30 -> gris
;;;   30 a 32 -> negro
;;;   32 a 42 -> línea 'n' símbolo columna 2
;;;   42 a 44 -> negro

;;;	Comienzo del código
CSEG AT 0x252

;;; Todas las posiciones se miden con respecto a xBase, a diferencia
;;; de en el caso del loop principal.
;;; Se omiten las coordenadas Y ya que dependen de donde se invoque el
;;; procedimiento.

;;; Este módulo exporta las siguientes funciones:
PUBLIC LEV, LSH 

;;; Línea de espacio vertical
LEV: ; (-1)
		mov graphics_port, #black_level ; + 1 px = (0)
		INT_SLEEP 13, R0 ; + 13 px = (13)
	 	mov graphics_port, #gray_level ; + 1 px = (14)
		mov graphics_port, #black_level ; + 1 px = (15)
		INT_SLEEP 13, R0 ; + 13 px = (28)
		mov graphics_port, #gray_level ; + 1 px = (29)
		mov graphics_port, #black_level ; + 1 px = (30)
		INT_SLEEP 14, R0 ; + 14 px = (44)
		ret ; + 1 px = (45)

;;; Línea de separador horizontal
LSH: ; (-1)
		mov graphics_port, #gray_level ; + 1 px = (0)
		INT_SLEEP 43, R0 ; + 43 px = (43)
		mov graphics_port, #black_level ; + 1 px = (44)
		ret ; +	1 px = (45)

;;; Línea 0 y 9 de símbolo
LS_0: ; (-1)
LS_9: ; (-1)

		;; Decido si se trata de un espacio vacío o de un símbolo visible
		jnb board_line.5, LS_0_0_E ; + 1 px = (0)

		;; Decido si se trata de una X o una O
		jb board_line.4, LS_0_0_X ; + 1 px = (1)

;; Linea 0 y 9 de símbolo O en la columna 0
LS_0_0_O: ; (1)
LS_9_0_O: ; (1)

		;; Dibujo la línea 0 de la O en columna 0
		mov graphics_port, #black_level ; + 1 px = (2)
		INT_SLEEP 3, R0 ; + 3 px = (5)
		mov graphics_port, #white_level ; + 1 px = (6)
		SHORT_SLEEP 2 ; + 1 px = (7)
		mov graphics_port, #black_level ; + 1 px = (8)
		INT_SLEEP 4, R0 ; + 4 px = (12)

		;; Si es vacío, salta al espaciador de vacío
		jnb board_line.3, LS_0_1_E ; + 1 px = (13)

		;; Línea gris
		mov graphics_port, #gray_level ; + 1 px = (14)
		mov graphics_port, #black_level ; + 1 px = (15)

		;; Si es X el que sigue, salta a X
		jb board_line.2, LS_0_1_X ; + 1 px = (16)

;; Linea 0 y 9 de símbolo O en la columna 1
LS_0_1_O: ; (16)
LS_9_1_O: ; (16)

		;; Dibujo la línea 0 de la O en columna 1
		mov graphics_port, #black_level ; + 1 px = (17)
		INT_SLEEP 3, R0 ; + 3 px = (20)
		mov graphics_port, #white_level ; + 1 px = (21)
		SHORT_SLEEP 2 ; + 1 px = (22)
		mov graphics_port, #black_level ; + 1 px = (23)
		INT_SLEEP 4, R0 ; + 4 px = (27)

		;; Si es vacío, salta al espaciador de vacío
		jnb board_line.1, LS_0_2_E ; + 1 px = (28)

		;; Línea gris
		mov graphics_port, #gray_level ; + 1 px = (29)
		mov graphics_port, #black_level ; + 1 px = (30)

		;; Si es X el que sigue, salta a X
		jb board_line.0, LS_0_2_X ; + 1 px = (31)

;; Linea 0 y 9 de símbolo O en la columna 2
LS_0_2_O: ; (31)
LS_9_2_O: ; (31)

		;; Dibujo la línea 0 de la O en columna 2
		mov graphics_port, #black_level ; + 1 px = (32)
		INT_SLEEP 3, R0 ; + 3 px = (35)
		mov graphics_port, #white_level ; + 1 px = (36)
		SHORT_SLEEP 2 ; + 1 px = (37)
		mov graphics_port, #black_level ; + 1 px = (38)
		INT_SLEEP 4, R0 ; + 4 px = (42)

		;; Terminé
		ret ; + 1 px = (43)
		
;; Linea 0 y 9 de símbolo X en la columna 0
LS_0_0_X: ; (1)
LS_9_0_X: ; (1)

		;; Dibujo la línea 0 de la X en columna 0
		mov graphics_port, #white_level ; + 1 px = (2)
		SHORT_SLEEP 2 ; + 1 px = (3)
		mov graphics_port, #black_level ; + 1 px = (4)
		INT_SLEEP 5, R0 ; + 5 px = (9)
		mov graphics_port, #white_level ; + 1 px = (10)
		SHORT_SLEEP 2 ; + 1 px = (11)
		mov graphics_port, #black_level ; + 1 px = (12)

		;; Si es vacío, salta al espaciador de vacío
		jnb board_line.3, LS_0_1_E ; + 1 px = (13)

		;; Línea gris
		mov graphics_port, #gray_level ; + 1 px = (14)
		mov graphics_port, #black_level ; + 1 px = (15)

		;; Si es O el que sigue, salta a O
		jnb board_line.2, LS_0_1_O ; + 1 px = (16)

;; Linea 0 y 9 de símbolo X en la columna 1
LS_0_1_X: ; (16)
LS_9_1_X: ; (16)

		;; Dibujo la línea 0 de la X en columna 1
		mov graphics_port, #white_level ; + 1 px = (17)
		SHORT_SLEEP 2 ; + 1 px = (18)
		mov graphics_port, #black_level ; + 1 px = (19)
		INT_SLEEP 5, R0 ; + 5 px = (24)
		mov graphics_port, #white_level ; + 1 px = (25)
		SHORT_SLEEP 2 ; + 1 px = (26)
		mov graphics_port, #black_level ; + 1 px = (27)

		;; Si es vacío, salta al espaciador de vacío
		jnb board_line.3, LS_0_2_E ; + 1 px = (28)

		;; Línea gris
		mov graphics_port, #gray_level ; + 1 px = (29)
		mov graphics_port, #black_level ; + 1 px = (30)

		;; Si es O el que sigue, salta a O
		jnb board_line.2, LS_0_2_O ; + 1 px = (31)
		
;; Linea 0 y 9 de símbolo X en la columna 2
LS_0_2_X: ; (31)
LS_9_2_X: ; (31)

		;; Dibujo la línea 0 de la X en columna 2
		mov graphics_port, #white_level ; + 1 px = (32)
		SHORT_SLEEP 2 ; + 1 px = (33)
		mov graphics_port, #black_level ; + 1 px = (34)
		INT_SLEEP 5, R0 ; + 5 px = (39)
		mov graphics_port, #white_level ; + 1 px = (40)
		SHORT_SLEEP 2 ; + 1 px = (41)
		mov graphics_port, #black_level ; + 1 px = (42)

		;; Terminé
		ret ; + 1 px = (43)	

LS_0_0_E:
LS_9_0_E:
LS_0_1_E:
LS_9_1_E:
LS_0_2_E:
LS_9_2_E:

END