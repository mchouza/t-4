;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beir� y Mariano Chouza
;;;; Dibujo del tablero
;;;; Loop principal

NAME DIBUJO_TABLERO_PRINCIPAL

;;; Inclusiones
$INCLUDE(constantes.inc)
$INCLUDE(macros.inc)

;;; Comienzo del c�digo
CSEG AT 0x0000 ; FIXME: Por ahora no hay c�digo de inicializaci�n

;;; Empezamos a dibujar
;;; Como casi todas las instrucciones toman dos ciclos de m�quina o sea 24
;;; ciclos de reloj y estamos operando a 33 MHz, tomamos cada pixel como
;;; de 0.727 us = (1 / 33 MHz) * 24

;;; Tomamos a la modificaci�n en la salida como si se produjera justo al
;;; terminar la instrucci�n.

;;; Consideramos a un frame como formado por 305 l�neas, cada una de las
;;; cuales est� formada por 88 p�xels (64 us / 0.727 us = 88.03).
;;; De estos solo 71 pixels son visibles, siendo el resto reservado para la
;;; secuencia de sincronizaci�n horizontal (front porch / sync pulse /
;;; back porch)

;;; Por lo tanto el formato de una l�nea ser�a en pixels:
;;; 0 a 6.5 -> sync pulse (6.5 * 0.727 us = 4.73 us)
;;; 6.5 a 15 -> back porch (8.5 * 0.727 us = 6.180 us)
;;; 15 a 86 -> imagen (71 * 0.727 us = 51.617 us)
;;; 86 a 88 (= 0) -> front porch (2 * 0.727 us = 1.454 us)

;;; Los n�meros de las l�neas ser�an:
;;; 0 a 17 -> ocultas
;;; 17 a 304 -> visibles
;;; 304 a 312 (=0) -> vsync sequence

;;; Comentarios sobre area de pantalla
;;; La primera l�nea visible es la 49
;;; La columna 23 y la 71 se ven bien, con amplio margen
;;; 5 l�neas se ven igual que un pixel horizontal
;;; Las �ltimas 35 l�neas apenas se ven las 1ras (o sea como
;;; est� ahora, apenas se ve el 3er bloque

;;; En la pr�ctica, no todas las l�neas "visibles" lo son. Experimentalmente
;;; determinamos que puede verse a partir de la l�nea 49 y hasta la 269
;;; (exclusive). En cuanto  las columnas, la columna 23 y 71 se ven con
;;; claridad, dejando un cierto margen. No nos importa exactamente en que
;;; punto comienza a verse debido a que el tablero debe ser cuadrado.

;;; Respecto a la relaci�n de aspecto, tomamos 5 l�neas como p�xel horizontal.

;;; Por lo tanto, tomamos como referencia para la imagen el "viewport" dado
;;; por (23, 44) y (72, 274), lo que nos da una imagen de 49 X 46 que
;;; corresponde al bitmap dibujado.

;;; Las l�neas que forman los pulsos de ecualizaci�n y el vsync en s� tienen
;;; un formato distinto.

;;; Pulsos de ecualizaci�n, l�nea completa:
;;; 0 a 3.5 -> short sync
;;; 3.5 a 44 -> negro
;;; 44 a 47.5 -> short sync
;;; 47.5 a 88 -> negro

;;; VSync, l�nea completa:
;;; 0 a 40.5 -> long sync
;;; 40.5 a 44 -> negro
;;;	44 a 84.5 -> long sync
;;; 84.5 a 88 -> negro

;;; VSync / Pulsos ecualizaci�n mixed :-)
;;; 0 a 40.5 -> long sync
;;; 40.5 a 44 -> negro
;;; 44 a 47.5 -> short sync
;;; 47.5 a 88 -> negro

;;; Debido a la gran importancia de los tiempos en este programa, a la derecha
;;; de cada instrucci�n se indica cuantos pixels (0.727 us) demora y la
;;; posici�n en la que estar�a despu�s de su ejecuci�n en forma de un par
;;; (pixel, linea)

hid_lines_start: ; Comienzan las l�neas ocultas

		;; Llamamos al hsync (86, -1)
		call hsync ; + 9.5 px = (95.5, -1) = (7.5, 0)
		
		;; Cargamos la cantidad de l�neas ocultas - 1 (pierdo una por alinear)
		mov R7, #hidden_lines - 1 ; + 0.5px = (8, 0)

		;; Esperamos para alinear con el primer ciclo
		INT_SLEEP 78, R0 ; + 78 px = (86, 0)

hid_lines_loop: ; Para todas las otras l�neas ocultas (86, n - 1)

		;; Llamamos al hsync
		call hsync ; + 9.5 px = (95.5, n - 1) = (7.5, n)
		
		;; Alineo a pixel
		SHORT_SLEEP 1 ; + 0.5 px = (8, n)

		;; Esperamos hasta terminar la l�nea
		INT_SLEEP 77, R0 ; + 77 px = (85, n)

		;; Volvemos al loop
		djnz R7, hid_lines_loop ; + 1 px = (86, n)

hid_lines_end: ; Terminan las l�neas ocultas (-2, 17)

draw_start: ; Asociado con la parte superior izquierda de la pantalla (-2, 17)

		;; Si bien llegamos al "�rea visible", en la pr�ctica la zona visible
		;; de la pantalla no es tan amplia.
		;; Por eso saltamos hasta la l�nea 44

		;; La primera l�nea debo hacerla fuera del loop por razones
		;; de alineaci�n.

	top_margin_start: ; Empiezan las l�neas salteadas (-2, 17)

		;; Es igual que en el caso de las ocultas
		call hsync ; + 9.5 px = (7.5, 17)
		mov R7, #44 - 17 - 1 ; + 0.5 px = (8, 17)
		INT_SLEEP 78, R0 ; + 78 px = (86, 17) = (-2, 18)

	top_margin_loop: ; Hago el resto de las l�neas (86, n - 1) = (-2, n)
		
		;; Igual que en el caso de las ocultas
		call hsync ; + 9.5 px = (7.5, n)
		SHORT_SLEEP 1 ; + 0.5 px = (8, n)
		INT_SLEEP 77, R0 ; + 77 px = (85, n)
		djnz R7, top_margin_loop ; + 1 px = (86, n)

	real_draw_start: ; Empieza el dibujo real  (-2, 44)

		;; Utilizo la primera l�nea para inicializar las variables globales

		;; Empiezo la l�nea
		call hsync ; + 9.5 px = (7.5, 44)
		SHORT_SLEEP 1 ; + 0.5 px = (8, 44)

		;; Voy a estar en offset 0 de la l�nea l�gica 0 (dejo una l�nea negra
		;; visible)
		mov logic_line, #0 ; + 1 px = (9, 44)
		mov phys_line_offset, #0 ; + 1 px = (10, 44)
		INT_SLEEP 75, R0 ; + 75 px = (85, 44)
		call do_real_draw: ; + 1 px = (86, 44) = (-2, 45)

	real_draw_end: ; Termina el dibujo real (-2, 275)

	bottom_margin_start:

		;; Es igual que en el caso de las ocultas
		call hsync ; + 9.5 px = (7.5, 275)
		mov R7, #304 - 275 - 1 ; + 0.5 px = (8, 275)
		INT_SLEEP 78, R0 ; + 78 px = (86, 275) = (-2, 276)

	bottom_margin_loop: ; Hago el resto de las l�neas (86, n - 1) = (-2, n)
		
		call hsync ; + 9.5 px = (7.5, n)
		SHORT_SLEEP 1 ; + 0.5 px = (8, n)
		INT_SLEEP 77, R0 ; + 77 px = (85, n)
		djnz R7, bottom_margin_loop ; + 1 px = (86, n)

draw_end: ; Termina de dibujar (-2, 304)

vsync_start: ; Comienza el sincronismo vertical (-2, 304)

		;; Espero 1 pixel
		SHORT_SLEEP 2 ; + 1 px = (-1, 304)

		;; Hago 6 pulsos de ecualizaci�n (-1, 304)
		REPT 6
			EQ_PULSE
		ENDM ; + 3 li = (-1, 307)

		;; Hago 5 pulsos de vsync
		REPT 5
			VSYNC_PULSE
		ENDM ; + 2.5 li = (43, 309)

		;; Hago 4 pulsos de ecualizaci�n
		REPT 4
			EQ_PULSE
		ENDM ; + 2 li = (43, 311)

		;; Hago el �ltimo en forma manual, para enganchar con las l�neas de arriba
		mov graphics_port, #sync_level ; + 1 px = (44, 311)
		SHORT_SLEEP 5 ; + 2.5 px = (46.5, 311)
		mov graphics_port, #black_level ; + 1 px = (47.5, 311)
		INT_SLEEP 37, R0 ; + 37 px = (84.5, 311)
		SHORT_SLEEP 1 ; + 0.5 px = (85, 311)

vsync_end: ; Termina el sincronismo vertical

		;; Volvemos al comienzo
		jmp hid_lines_start ; + 1 px = (86, 311)

;;;
;;; Procedimiento hsync
;;; El llamado hace las veces de front porch, ya que demora 1 px
;;; El retorno quita un pixel del back porch
;;; Par�metros: Ninguno
;;; Registros modificados: R0
;;;

hsync: ; (-1, n)

		;; Comenzamos el pulso sync
		mov graphics_port, #sync_level ; + 1 px = (0, n)

		;; Esperamos 5 pixels
		INT_SLEEP 5, R0 ; + 5 px = (5, n)

		;; Esperamos 1/2 pixel m�s
		SHORT_SLEEP 1 ; + 0.5 px = (5.5, n)

		;; Volvemos a nivel de supresi�n
		mov graphics_port, #black_level ; + 1 px = (6.5, n)

		;; Volvemos
		ret ; + 1px = (7.5, n)

;;;
;;; Procedimiento do_real_draw
;;; Este procedimiento es el que hace el dibujo en si, llamando a los
;;; fragmentos de c�digo que dibujan cada parte del tablero.
;;; Par�metros: Ninguno
;;; Registros modificados: ??
;;;

do_real_draw: ; (-2, n)

		;; Primero, como siempre, el hsync
		call hsync ; + 9.5 px = (7.5, n)

		;; FIXME: Agregar PADDING adecuado

		;; Tengo que decidir a que llamar, lo que depende del n�mero de l�nea
		;; Para tomar la decisi�n uso una serie de jumps por bit en base al 
		;; n�mero de l�nea l�gica.

		;; Como hay 44 l�neas l�gicas, necesito hacer un jump por los 6 bits
		;; m�s bajos.

		;; Cada jump por bit tiene un label, de la forma 'jb_101nxx' donde
		;; '10' representar�a los bits ya consultados al recorrer el �rbol,
		;; 'n' la posici�n del bit que se va a observar y 'xx' los que
		;; quedar�an por observar

	jb_nxxxxx:
		jb logical_line.5, jb_1nxxxx
	jb_0nxxxx:
		jb logical_line.4, jb_01nxxx
	jb_00nxxx:
		jb logical_line.3, jb_001nxx
	jb_000nxx:
		jb logical_line.2, jb_0001nx
	jb_0000nx:
		jb logical_line.1, jb_00001n
	jb_00000n:
		jb logical_line.0, ll_1
		jmp ll_0
	jb_1nxxxx:
		jb logical_line.4, jb_11nxxx
	jb_10nxxx:
		jb logical_line.3, jb_101nxx
	jb_100nxx:
		jb logical_line.2, jb_1001nx
	jb_1000nx:
		jb logical_line.1, jb_10001n
	jb_10000n:
		jb logical_line.0, ll_33
		jmp ll_32
	jb_11nxxx:
		jb logical_line.3, jb_111nxx
	jb_110nxx:
		jb logical_line.2, jb_1101nx
	jb_1100nx:
		jb logical_line.1, jb_11001n
	jb_11000n:
		



		;; Termin� con todo, vuelvo
		ret

;;; Fin del m�dulo
END