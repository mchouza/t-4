;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beir� y Mariano Chouza
;;;; Dibujo del tablero
;;;; Partes para el dibujo de las l�neas del tablero

NAME DIBUJO_TABLERO_PARTES_LINEA

;;; Inclusiones
$INCLUDE(constantes.inc)
$INCLUDE(macros.inc)

;;; De acuerdo a lo medido, se utilizar�n 5 l�neas f�sicas para constituir una
;;; l�nea l�gica, de modo que la relaci�n de aspecto de cada pixel sea cercana
;;; a 1.


;;; De acuerdo a lo dise�ado en las im�genes, elegimos bitmaps de 10 X 10
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

;;; Observar que las �ltimas 5 l�neas de cada s�mbolo son un reflejo de las
;;; primeras 5.

;;; En este m�dulo se implementa el dibujo de cada tipo de l�nea f�sica, que
;;; se corresponden con los tipos de l�nea l�gica.

;;; Hay 3 tipos de l�nea:
;;; - L�nea de un separador horizontal.
;;; - L�nea de un espacio vertical.
;;; - L�nea de un s�mbolo, que a su vez se clasifican seg�n la fila.

;;; Cada tipo de l�nea tiene un s�mbolo, que es la label asociada al c�digo
;;; que la dibuja.
;;; LSH -> L�nea del separador horizontal.
;;; LEV -> L�nea del espacio vertical.
;;; LS_n -> L�nea de la fila n del s�mbolo

;;; Tengo un total de 44 l�neas l�gicas que forman el tablero. Son:
;;; 0 a 2 -> LEV
;;; 2 a 12 -> LS_xx, donde xx es el n�mero de l�nea - 2
;;; 12 a 14 -> LEV
;;; 14 a 15 -> LSH
;;; 15 a 17 -> LEV
;;; 17 a 27 -> LS_xx, donde xx es el n�mero de l�nea - 17
;;; 27 a 29 -> LEV
;;; 29 a 30 -> LSH
;;; 30 a 32 -> LEV
;;; 32 a 42 -> LS_xx, donde xx es el n�mero de l�nea - 32
;;; 42 a 44 -> LEV

;;; La decisi�n de en que l�nea caer corresponde al loop principal.

;;; La estructura gr�fica de las l�neas, es:
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
;;;   2 a 12 -> l�nea 'n' s�mbolo columna 0
;;;   12 a 14 -> negro
;;;   14 a 15 -> gris
;;;   15 a 17 -> negro
;;;   17 a 27 -> l�nea 'n' s�mbolo columna 1
;;;   27 a 29 -> negro
;;;   29 a 30 -> gris
;;;   30 a 32 -> negro
;;;   32 a 42 -> l�nea 'n' s�mbolo columna 2
;;;   42 a 44 -> negro

;;;	Comienzo del c�digo
CSEG AT 0x252

;;; Todas las posiciones se miden con respecto a xBase, a diferencia
;;; de en el caso del loop principal.
;;; Se omiten las coordenadas Y ya que dependen de donde se invoque el
;;; procedimiento.

;;; Este m�dulo exporta las siguientes funciones:
PUBLIC LEV, LSH 

;;; L�nea de espacio vertical
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

;;; L�nea de separador horizontal
LSH: ; (-1)
		mov graphics_port, #gray_level ; + 1 px = (0)
		INT_SLEEP 43, R0 ; + 43 px = (43)
		mov graphics_port, #black_level ; + 1 px = (44)
		ret ; +	1 px = (45)

;;; L�nea 0 y 9 de s�mbolo
LS_0: ; (-1)
LS_9: ; (-1)

		;; Decido si se trata de un espacio vac�o o de un s�mbolo visible
		jnb board_line.5, LS_0_0_EMPTY ; + 1 px = (0)

		;; Decido si se trata de una X o una O
		jb board_line.4, LS_0_0_X ; + 1 px = (1)

;; Linea 0 y 9 de s�mbolo O en la columna 0
LS_0_0_O: ; (1)
LS_9_0_O: ; (1)

		;; Dibujo la l�nea 0 de la O en columna 0
		mov graphics_port, #black_level ; + 1 px = (2)
		INT_SLEEP 3, R0 ; + 3 px = (5)
		mov graphics_port, #white_level ; + 1 px = (7)
		SHORT_SLEEP 2 ; + 1 px = (8)
		mov graphics_port, #black_level ; + 1 px = (9)
		INT_SLEEP 3, R0 ; + 3 px = (12)

		;; Decido si se trata de un espacio vac�o
LS_0_0_O_checkNext: ; (12)
		jnb board_line.3, LS_0_0_O_nextIsEmpty ; + 1 px = (13)

		;; Pongo la l�nea gris
		mov graphics_port, #gray_level ; + 1 px = (14)
		mov graphics_port, #black_level ; + 1 px = (15)

		;; Decido si lo que sigue es una X u O
		jb board_line.2, LS_0_0_O_nextIsX ; + 1 px = (16)
		jmp LS_0_1_O ; + 1 px = (17)

LS_0_0_O_nextIsX:
		jmp LS_0_1_X ; + 1 px = (17)

LS_0_0_O_nextIsEmpty:
		jmp LS_0_1_EMPTY ; + 1 px = (14)

LS_0_0_EMPTY: ; (0)
LS_9_0_EMPTY: ; (0)

		;; Dibuja la l�nea 0 como vac�a en la columna 0
		INT_SLEEP 11, R0 ; + 11 px = (11)

		;; Aprovecho el c�digo de la O
		jmp LS_0_0_O_checkNext ; + 1 px = (12)
		
 








END