;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Módulo de dibujo, parte principal (DRAW_MAIN)
;;;; Se encarga de efectuar todas las tareas de dibujo, incluyendo el loop de
;;;; video

$INCLUDE(macros.inc)		; Macros de propósito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general

NAME DRAW_MAIN

;;; Segmento propio de este módulo
DRAW_MAIN_SEG SEGMENT CODE

;;; Importa
$INCLUDE(variables.inc)		; Variables compartidas a nivel global
$INCLUDE(keyboard.inc)		; Procedimientos para acceder al teclado
$INCLUDE(sound.inc)			; Procedimientos para reproducir melodias
$INCLUDE(draw_lines.inc)	; Procedimeintos que se encargan de dibujar las líneas físicas
$INCLUDE(ai.inc)	; Procedimeintos que se encargan de dibujar las líneas físicas

;;; Exporta solo la función de inicialización y el loop
PUBLIC draw_init, draw_loop

;;; FIXME: Mejorar la explicación

;;; Como casi todas las instrucciones toman dos ciclos de máquina o sea 24
;;; ciclos de reloj y estamos operando a 33 MHz, tomamos cada pixel como
;;; de 0.727 us = (1 / 33 MHz) * 24

;;; Tomamos a la modificación en la salida como si se produjera justo al
;;; terminar la instrucción.

;;; Consideramos a un frame como formado por 305 líneas, cada una de las
;;; cuales está formada por 88 píxels (64 us / 0.727 us = 88.03).
;;; De estos solo 71 pixels son visibles, siendo el resto reservado para la
;;; secuencia de sincronización horizontal (front porch / sync pulse /
;;; back porch)

;;; Por lo tanto el formato de una línea sería en pixels:
;;; 0 a 6.5 -> sync pulse (6.5 * 0.727 us = 4.73 us)
;;; 6.5 a 15 -> back porch (8.5 * 0.727 us = 6.180 us)
;;; 15 a 86 -> imagen (71 * 0.727 us = 51.617 us)
;;; 86 a 88 (= 0) -> front porch (2 * 0.727 us = 1.454 us)

;;; Los números de las líneas serían:
;;; 0 a 17 -> ocultas
;;; 17 a 304 -> visibles
;;; 304 a 312 (=0) -> vsync sequence

;;; Comentarios sobre area de pantalla
;;; La primera línea visible es la 49
;;; La columna 23 y la 71 se ven bien, con amplio margen
;;; 5 líneas se ven igual que un pixel horizontal
;;; Las últimas 35 líneas apenas se ven las 1ras (o sea como
;;; está ahora, apenas se ve el 3er bloque

;;; En la práctica, no todas las líneas "visibles" lo son. Experimentalmente
;;; determinamos que puede verse a partir de la línea 49 y hasta la 269
;;; (exclusive). En cuanto  las columnas, la columna 23 y 71 se ven con
;;; claridad, dejando un cierto margen. No nos importa exactamente en que
;;; punto comienza a verse debido a que el tablero debe ser cuadrado.

;;; Respecto a la relación de aspecto, tomamos 5 líneas como píxel horizontal.

;;; Por lo tanto, tomamos como referencia para la imagen el "viewport" dado
;;; por (23, 44) y (72, 274), lo que nos da una imagen en principio de
;;; 49 X 46.

;;; Como el tablero tiene 44 X 44 en píxeles, o sea 44 X 220 utilizando líneas
;;; físicas, quedaría utilizando, en coordenadas físicas (26, 49) - (70, 269).

;;; Las líneas que forman los pulsos de ecualización y el vsync en sí tienen
;;; un formato distinto.

;;; Pulsos de ecualización, línea completa:
;;; 0 a 3.5 -> short sync
;;; 3.5 a 44 -> negro
;;; 44 a 47.5 -> short sync
;;; 47.5 a 88 -> negro

;;; VSync, línea completa:
;;; 0 a 40.5 -> long sync
;;; 40.5 a 44 -> negro
;;;	44 a 84.5 -> long sync
;;; 84.5 a 88 -> negro

;;; VSync / Pulsos ecualización mixed :-)
;;; 0 a 40.5 -> long sync
;;; 40.5 a 44 -> negro
;;; 44 a 47.5 -> short sync
;;; 47.5 a 88 -> negro

;;; Debido a la gran importancia de los tiempos en este programa, a la derecha
;;; de cada instrucción se indica cuantos pixels (0.727 us) demora y la
;;; posición en la que estaría después de su ejecución en forma de un par
;;; (pixel, linea)

;;; Comienza el segmento DRAW_MAIN_SEG
RSEG DRAW_MAIN_SEG

;;;
;;; Procedimiento draw_init
;;;
;;; Inicializa el módulo de dibujo
;;;
;;; Parámetros: Ninguno
;;;
;;; Registros modificados: ??
;;;

draw_init:
		;; FIXME: Para prueba
		PUT_SYMBOL 0, 0, "E" 
		PUT_SYMBOL 0, 1, "E"
		PUT_SYMBOL 0, 2, "E"
		PUT_SYMBOL 1, 0, "E"
		PUT_SYMBOL 1, 1, "E"
		PUT_SYMBOL 1, 2, "E"
		PUT_SYMBOL 2, 0, "E"
		PUT_SYMBOL 2, 1, "E"
		PUT_SYMBOL 2, 2, "E"
		mov line_num, #1
		mov board_line, linea_0
		ret

;;;
;;; Procedimiento draw_loop
;;;
;;; Loop de dibujo: no solo se encarga de dibujar sino que llama a las
;;; funciones para manejar I/O. Sin embargo, se denomina así porque debe estar
;;; permanentemente al tanto de la posición en la pantalla.
;;;
;;; Nunca vuelve.
;;;
;;; Parámetros: Ninguno
;;;
;;; Registros modificados: N/A
;;;

draw_loop:

	hid_lines_start: ; Comienzan las líneas ocultas
	
		;; Llamamos al hsync (86, -1)
		call hsync ; + 9.5 px = (95.5, -1) = (7.5, 0)
			
		;; Cargamos la cantidad de líneas ocultas - 1 (pierdo una por alinear)
		mov R7, #hidden_lines - 1 ; + 0.5px = (8, 0)
	
		;; Esperamos para alinear con el primer ciclo
		INT_SLEEP 78, R0 ; + 78 px = (86, 0)
	
	hid_lines_loop: ; Para todas las otras líneas ocultas (86, n - 1)
	
		;; Llamamos al hsync
		call hsync ; + 9.5 px = (95.5, n - 1) = (7.5, n)
			
		;; Alineo a pixel
		SHORT_SLEEP 1 ; + 0.5 px = (8, n)
	
		;; Esperamos hasta terminar la línea
		INT_SLEEP 77, R0 ; + 77 px = (85, n)
	
		;; Volvemos al loop
		djnz R7, hid_lines_loop ; + 1 px = (86, n)
	
	hid_lines_end: ; Terminan las líneas ocultas (-2, 17)
	
	draw_start: ; Asociado con la parte superior izquierda de la pantalla (-2, 17)
	
		;; Si bien llegamos al "área visible", en la práctica la zona visible
		;; de la pantalla no es tan amplia.
		;; Por eso saltamos hasta la línea 44
	
		;; La primera lìnea debo hacerla fuera del loop por razones
		;; de alineación.
	
		top_margin_start: ; Empiezan las líneas salteadas (-2, 17)
	
			;; Es igual que en el caso de las ocultas
			call hsync ; + 9.5 px = (7.5, 17)
			mov R7, #47 - 17 - 3 ; + 0.5 px = (8, 17)
			INT_SLEEP 78, R0 ; + 78 px = (86, 17) = (-2, 18)
	
		linea_invocacion_teclado: ; En esta linea del barrido se lee el teclado
			call hsync
			call keyboard_check
	
		linea_reproduccion_melodias: ; En esta linea del barrido se reproducen notas musicales
			call hsync
			call sound_play
	
		linea_jugada_maquina: ; En esta linea del barrido se analiza si la máquina debe jugar
			call hsync
			call ai_play
	
		top_margin_loop: ; Hago el resto de las líneas (86, n - 1) = (-2, n)
			
			;; Igual que en el caso de las ocultas
			call hsync ; + 9.5 px = (7.5, n)
			SHORT_SLEEP 1 ; + 0.5 px = (8, n)
			INT_SLEEP 77, R0 ; + 77 px = (85, n)
			djnz R7, top_margin_loop ; + 1 px = (86, n)
	
		real_draw_start: ; Empieza el dibujo real  (-2, 48)
	
			;; Utilizo esta línea para inicializar lo que deba
	
			;; Empiezo la línea
			call hsync ; + 9.5 px = (7.5, 48)
			SHORT_SLEEP 1 ; + 0.5 px = (8, 48)
	
			;; FIXME: HAGO LO QUE TENGA QUE HACER!!!
	
			INT_SLEEP 75, R0 ; + 75 px = (83, 48)
			call do_real_draw ; + ?? = (-2.5, 274)
			SHORT_SLEEP 1 ; + 0.5 px = (-2, 274)
	
		real_draw_end: ; Termina el dibujo real (-2, 274)
	
		bottom_margin_start:
	
			;; Es igual que en el caso de las ocultas
			call hsync ; + 9.5 px = (7.5, 274)
			mov R7, #304 - 274 - 1 ; + 0.5 px = (8, 274)
			INT_SLEEP 78, R0 ; + 78 px = (86, 275) = (-2, 276)
	
		bottom_margin_loop: ; Hago el resto de las líneas (86, n - 1) = (-2, n)
			
			call hsync ; + 9.5 px = (7.5, n)
			SHORT_SLEEP 1 ; + 0.5 px = (8, n)
			INT_SLEEP 77, R0 ; + 77 px = (85, n)
			djnz R7, bottom_margin_loop ; + 1 px = (86, n)
	
	draw_end: ; Termina de dibujar (-2, 304)
	
	vsync_start: ; Comienza el sincronismo vertical (-2, 304)
	
		;; Espero 1 pixel
		SHORT_SLEEP 2 ; + 1 px = (-1, 304)
	
		;; Hago 6 pulsos de ecualización (-1, 304)
		REPT 6
			EQ_PULSE
		ENDM ; + 3 li = (-1, 307)
	
		;; Hago 5 pulsos de vsync
		REPT 5
			VSYNC_PULSE
		ENDM ; + 2.5 li = (43, 309)
	
		;; Hago 4 pulsos de ecualización
		REPT 4
			EQ_PULSE
		ENDM ; + 2 li = (43, 311)
	
		;; Hago el último en forma manual, para enganchar con las líneas de arriba
		mov graphics_port, #sync_level ; + 1 px = (44, 311)
		SHORT_SLEEP 5 ; + 2.5 px = (46.5, 311)
		mov graphics_port, #black_level ; + 1 px = (47.5, 311)
		INT_SLEEP 37, R0 ; + 37 px = (84.5, 311)
		SHORT_SLEEP 1 ; + 0.5 px = (85, 311)
	
	vsync_end: ; Termina el sincronismo vertical
	
		;; Volvemos al comienzo
		jmp draw_loop ; + 1 px = (86, 311)

;;;
;;; Procedimiento hsync
;;;
;;; Realiza un pulso de HSYNC
;;;
;;; El llamado hace las veces de front porch, ya que demora 1 px
;;; El retorno quita un pixel del back porch
;;;
;;; Parámetros: Ninguno
;;;
;;; Registros modificados: R0
;;;

hsync: ; (-1, n)

	;; Comenzamos el pulso sync
	mov graphics_port, #sync_level ; + 1 px = (0, n)

	;; Esperamos 5 pixels
	INT_SLEEP 5, R0 ; + 5 px = (5, n)

	;; Esperamos 1/2 pixel más
	SHORT_SLEEP 1 ; + 0.5 px = (5.5, n)

	;; Volvemos a nivel de supresión
	mov graphics_port, #black_level ; + 1 px = (6.5, n)

	;; Volvemos
	ret ; + 1px = (7.5, n)

;;;
;;; Procedimiento do_real_draw
;;;
;;; Este procedimiento es el que hace el dibujo en si, llamando a los
;;; fragmentos de código que dibujan cada parte del tablero.
;;;
;;; Parámetros: ??
;;;
;;; Registros modificados: ??
;;;

do_real_draw: ; (-4, 49)

	;; Tengo 3 líneas en el tablero
	mov R1, #3 ; + 0.5 px = (-3.5, 49)

	board_line_loop: ; Linea del tablero

	call bl_0 ; Hago la línea 0
	call bl_1 ; Hago la línea 1
	call bl_2 ; Y asi...
	call bl_3 
	call bl_4
	call bl_5 
	call bl_6 
	call bl_7
	call bl_8
	call bl_9
	call bl_10
	call bl_11
	call bl_12
	call bl_13
	call bl_14
	
	;; Si no terminó con el tablero, sigue con la otra línea
	djnz R1, board_line_loop ; + 1 px = (-3.5, n)

	;; Terminé con todo, vuelvo
	ret	; + 1 px = (-2.5, 274)


;;;
;;; Procedimientos bl_0, b_1, bl_12 y bl_13
;;;
;;; Estos procedimientos, que comparten el cuerpo, dibujan las
;;; correspondientes líneas del tablero.
;;;
;;; Parámetros: ??
;;;
;;; Registros modificados: R2
;;;

bl_0: ; (-2.5, n)
bl_1:
bl_12:
bl_13:

	; Todas corresponden a un espacio vertical
	LOGICAL_LINE LEV, 0

;;;
;;; Procedimientos bl_2 y bl_11
;;;
;;; Estos procedimientos, que comparten el cuerpo, dibujan las
;;; correspondientes líneas del tablero.
;;;
;;; Parámetros: ??
;;;
;;; Registros modificados: ??
;;;

bl_2: ; (-3, n)
bl_11:
	
	LOGICAL_LINE LS_0, 0

;;;
;;; Procedimientos bl_3 y bl_10
;;;
;;; Estos procedimientos, que comparten el cuerpo, dibujan las
;;; correspondientes líneas del tablero.
;;;
;;; Parámetros: ??
;;;
;;; Registros modificados: ??
;;;

bl_3: ; (-3, n)
bl_10:
	
	LOGICAL_LINE LS_1, 0

;;;
;;; Procedimientos bl_4 y bl_9
;;;
;;; Estos procedimientos, que comparten el cuerpo, dibujan las
;;; correspondientes líneas del tablero.
;;;
;;; Parámetros: ??
;;;
;;; Registros modificados: ??
;;;

bl_4: ; (-3, n)
bl_9:
	
	LOGICAL_LINE LS_2, 0

;;;
;;; Procedimientos bl_5 y bl_8
;;;
;;; Estos procedimientos, que comparten el cuerpo, dibujan las
;;; correspondientes líneas del tablero.
;;;
;;; Parámetros: ??
;;;
;;; Registros modificados: ??
;;;

bl_5: ; (-3, n)
bl_8:
	
	LOGICAL_LINE LS_3, 0

;;;
;;; Procedimientos bl_6 y bl_7
;;;
;;; Estos procedimientos, que comparten el cuerpo, dibujan las
;;; correspondientes líneas del tablero.
;;;
;;; Parámetros: ??
;;;
;;; Registros modificados: ??
;;;

bl_6: ; (-3, n)
bl_7:
	
	LOGICAL_LINE LS_4, 0

;;;
;;; Procedimientos bl_14
;;;
;;; Este procedimiento dibuja la correspondiente línea del tablero
;;;
;;; Parámetros: ??
;;;
;;; Registros modificados: ??
;;;

bl_14: ; (-3, n)

	; Última línea de la línea del tablero
	LOGICAL_LINE LSH, 1

;;; Fin del módulo
END

