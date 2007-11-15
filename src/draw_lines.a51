;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Módulo de dibujo, sección líneas (DRAW_LINES)
;;;; Se encarga de dibujar efectivamente a las líneas

$INCLUDE(macros.inc)		; Macros de propósito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general

NAME DRAW_LINES

;;; Segmento propio de este módulo
DRAW_LINES_SEG SEGMENT CODE

;;; Importa
$INCLUDE(variables.inc)		; Variables compartidas a nivel global

;;; Exporta todas las funciones de dibujo de _líneas_, no de sus partes
PUBLIC LEV, LSH, LS_0, LS_1, LS_2, LS_3, LS_4

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
;;; primeras 5. También puede apreciarse que las sigueintes líneas son
;;; idénticas entre símbolos:
;;; - 0 de X con 4 de O
;;; - 2 de X con 2 de O
;;; - 3 de X con 1 de O

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

;;; Todas las posiciones se miden con respecto a xBase, a diferencia
;;; de en el caso del loop principal.
;;; Se omiten las coordenadas Y ya que dependen de donde se invoque el
;;; procedimiento.

;;; FIXME: Poner descripciones más detalladas de cada procedimiento
;;; _exportado_.

;;; Comienza el segmento DRAW_LINES_SEG
RSEG DRAW_LINES_SEG

;;; Línea de espacio vertical
LEV: ; (-14)
		INT_SLEEP 13, R0 ; + 13 px = (-1)
		mov graphics_port, #black_level ; + 1 px = (0)
		INT_SLEEP 13, R0 ; + 13 px = (13)
	 	mov graphics_port, #gray_level ; + 1 px = (14)
		mov graphics_port, #black_level ; + 1 px = (15)
		INT_SLEEP 13, R0 ; + 13 px = (28)
		mov graphics_port, #gray_level ; + 1 px = (29)
		mov graphics_port, #black_level ; + 1 px = (30)
		INT_SLEEP 14, R0 ; + 14 px = (44)
		SHORT_SLEEP 2 ; + 1 px = (45)
		ret ; + 1 px = (46)

;;; Línea de separador horizontal
LSH: ; (-14)
		INT_SLEEP 13, R0 ; + 13 px = (-1)
		mov graphics_port, #gray_level ; + 1 px = (0)

		;; Reviso si es una línea de cambio (o sea la primera)
		;; Recordar que R2 contiene el número de línea física dentro de la
		;; línea lógica actual.
		cjne R2, #5, normal_LSH ; + 1 px = (1)
		
		;; Reviso si estamos en la línea 1
		mov A, line_num ; + 0.5 px = (1.5)
		cjne A, #1, not_line_one ; + 1 px = (2.5)

		;; Estoy en la línea 1, pongo dicha línea como línea actual
		mov board_line, linea_2 ; + 1 px = (3.5)
		mov line_num, #2 ; + 1 px = (4.5)
		SHORT_SLEEP 2 ; + 1 px = (5.5)
		jmp rest_of_LSH ; + 1 px = (6.5)

	not_line_one: ; Sé que no estoy en la línea 1 (2.5)
		;; Me fijo si estoy en la 0 o en la 2
		jc line_zero ; + 1 px = (3.5)
		
	line_two: ; (3.5)
		mov board_line, linea_3 ; + 1 px = (4.5)
		mov line_num, #0 ; + 1 px = (5.5)
		jmp rest_of_LSH ; + 1 px = (6.5)
		
	line_zero: ; (3.5)
		mov board_line, linea_1 ; + 1 px = (4.5)
		mov line_num, #1 ; + 1 px = (5.5)
		jmp rest_of_LSH ; + 1 px = (6.5)

	normal_LSH: ; (1)
		SHORT_SLEEP 1 ; + 0.5 px = (1.5)
		INT_SLEEP 5, R0 ; + 5 px = (6.5)

	rest_of_LSH: ; (6.5)
		SHORT_SLEEP 1 ; + 0.5 px = (7)
		INT_SLEEP 36, R0 ; + 36 px = (43)
		mov graphics_port, #black_level ; + 1 px = (44)
		SHORT_SLEEP 2 ; + 1 px = (45)
		ret ; +	1 px = (46)

;;; Línea 0 y 9 de símbolo
LS_0: ; (-14)
LS_9: ; (-14)
		LS_n SLS_0_X, SLS_0_O, SLS_N_E

LS_1: ; (-14)
LS_8: ; (-14)
		LS_n SLS_1_X, SLS_1_O, SLS_N_E

LS_2: ; (-14)
LS_7: ; (-14)
		LS_n SLS_2_X, SLS_2_O, SLS_N_E

LS_3: ; (-14)
LS_6: ; (-14)
		LS_n SLS_3_X, SLS_3_O, SLS_N_E

LS_4: ; (-14)
LS_5: ; (-14)
		LS_n SLS_4_X, SLS_4_O, SLS_N_E
		

;; Fragmento de símbolo de la X	correspondiente a la línea 0 o 9
SLS_0_X: ; (1) (tomando la primera columna, sino es equivalente a 16 o 31)

;; Fragmento de símbolo de la O correspondiente a la línea 4 o 5
SLS_4_O: ; (1)

		mov graphics_port, #white_level ; + 1 px = (2)
		SHORT_SLEEP 2 ; + 1 px = (3)
		mov graphics_port, #black_level ; + 1 px = (4)
		INT_SLEEP 5, R0 ; + 5 px = (9)
		mov graphics_port, #white_level ; + 1 px = (10)
		SHORT_SLEEP 2 ; + 1 px = (11)
		mov graphics_port, #black_level ; + 1 px = (12)
		SHORT_SLEEP 2 ; + 1 px = (13)
		mov graphics_port, #gray_level ; + 1 px = (14)
		mov graphics_port, #black_level ; + 1 px = (15)
		ret ; + 1 px = (16)

;; Fragmento de símbolo de la X, correspondiente a la línea 1 u 8
SLS_1_X: ; (1)
		mov graphics_port, #white_level ; + 1 px = (2)
		SHORT_SLEEP 4 ; + 2 px = (4)
		mov graphics_port, #black_level ; + 1 px = (5)
		INT_SLEEP 3, R0 ; + 3 px = (8)
		mov graphics_port, #white_level ; + 1 px = (9)
		SHORT_SLEEP 4 ; + 2 px = (11)
		mov graphics_port, #black_level ; + 1 px = (12)
		SHORT_SLEEP 2 ; + 1 px = (13)
		mov graphics_port, #gray_level ; + 1 px = (14)
		mov graphics_port, #black_level ; + 1 px = (15)
		ret ; + 1 px = (16)

;; Fragmento de símbolo de la X, correspondiente a la línea 2 o 7
SLS_2_X: ; (1)

;; Fragmento de símbolo de la O, correspondiente a la línea 2 o 7
SLS_2_O: ; (1)

		mov graphics_port, #black_level ; + 1 px = (2)
		mov graphics_port, #white_level ; + 1 px = (3)
		SHORT_SLEEP 4 ; + 2 px = (5)
		mov graphics_port, #black_level ; + 1 px = (6)
		SHORT_SLEEP 2 ; + 1 px = (7)
		mov graphics_port, #white_level ; + 1 px = (8)
		SHORT_SLEEP 4 ; + 2 px = (10)
		mov graphics_port, #black_level ; + 1 px = (11)
		SHORT_SLEEP 4 ; + 2 px = (13)
		mov graphics_port, #gray_level ; + 1 px = (14)
		mov graphics_port, #black_level ; + 1 px = (15)
		ret ; + 1 px = (16)

;; Fragmento de símbolo de la X, correspondiente a la línea 3 o 6
SLS_3_X: ; (1)

;; Fragmento de símbolo de la O, correspondiente a la línea 1 u 8
SLS_1_O: ; (1)

		mov graphics_port, #black_level ; + 1 px = (2)
		SHORT_SLEEP 2 ; + 1 px = (3)
		mov graphics_port, #white_level	; + 1 px = (4)
		INT_SLEEP 5, R0 ; + 5 px = (9)
		mov graphics_port, #black_level ; + 1 px = (10)
		INT_SLEEP 3, R0 ; + 3 px = (13)
		mov graphics_port, #gray_level ; + 1 px = (14)
		mov graphics_port, #black_level ; + 1 px = (15)
		ret ; + 1 px = (16)

;; Fragmento de símbolo de la X, correspondiente a la línea 4 o 5
SLS_4_X: ; (1)
		mov graphics_port, #black_level ; + 1 px = (2)
		SHORT_SLEEP 4 ; + 2 px = (4)
		mov graphics_port, #white_level ; + 1 px = (5)
		INT_SLEEP 3, R0 ; + 3 px = (8)
		mov graphics_port, #black_level ; + 1 px = (9)
		INT_SLEEP 4, R0 ; + 4 px = (13)
		mov graphics_port, #gray_level ; + 1 px = (14)
		mov graphics_port, #black_level ; + 1 px = (15)
		ret ; + 1 px = (16)

;; Fragmento de símbolo de la O	correspondiente a la línea 0 o 9
SLS_0_O: ; (1) (tomando la primera columna, sino es equivalente a 16 o 31)
		INT_SLEEP 4, R0 ; + 4 px = (5)
		mov graphics_port, #white_level ; + 1 px = (6)
		SHORT_SLEEP 2 ; + 1 px = (7)
		mov graphics_port, #black_level ; + 1 px = (8)
		INT_SLEEP 5, R0 ; + 5 px = (13)
		mov graphics_port, #gray_level ; + 1 px = (14)
		mov graphics_port, #black_level ; + 1 px = (15)
		ret ; + 1 px = (16)

;; Fragmento de símbolo de la O	correspondiente a la línea 3 o 7
SLS_3_O: ; (1)
		SHORT_SLEEP 2 ; + 1 px = (2)
		mov graphics_port, #white_level ; + 1 px = (3)
		SHORT_SLEEP 2 ; + 1 px = (4)
		mov graphics_port, #black_level ; + 1 px = (5)
		INT_SLEEP 3, R0 ; + 3 px = (8)
		mov graphics_port, #white_level ; + 1 px = (9)
		SHORT_SLEEP 2 ; + 1 px = (10)
		mov graphics_port, #black_level ; + 1 px = (11)
		SHORT_SLEEP 4 ; + 2 px = (13)
		mov graphics_port, #gray_level ; + 1 px = (14)
		mov graphics_port, #black_level ; + 1 px = (15)
		ret ; + 1 px = (16)	

;; Fragmento de símbolo vacío correspondiente a cualquier línea
SLS_N_E: ; (1) (tomando la primera columna, sino es equivalente a 16 o 31)
		INT_SLEEP 12, R0 ; + 12 px = (13)
		mov graphics_port, #gray_level ; + 1 px = (14)
		mov graphics_port, #black_level ; + 1 px = (15)
		ret ; + 1 px = (16)

;;; Fin del módulo
END
