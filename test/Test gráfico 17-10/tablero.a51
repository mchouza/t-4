;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Dibujo del tablero
;;;; Loop principal

NAME DIBUJO_TABLERO

;;;
;;; Constantes
;;;

sync_level equ 0xF0 ; Salida para obtener el nivel de sincronización
black_level equ 0xF1 ; Salida para obtener el nivel de negro o supresión (es
                     ; indistinto en nuestro caso)
gray_level equ 0xF2 ; Salida para obtener el nivel de gris
white_level equ 0xF3 ; Salida para obtener el nivel de blanco

graphics_port	equ P1 ; Puerto donde se escribe para obtener los gráficos

total_lines equ 304 ; Cantidad total de líneas
active_lines equ 287 ; Cantidad de líneas activas
hidden_lines equ (total_lines - active_lines) ; Cantidad de líneas ocultas

;;;
;;; Macros
;;;

;;; Sirve para esperas cortas. Consume 1 byte por cada medio pixel de espera.
SHORT_SLEEP MACRO delay_in_half_pixels
		REPT delay_in_half_pixels
			nop ; + 0.5px
		ENDM 
		ENDM ; + (delay_in_half_pixels / 2) px

;;; Sirve para esperas intermedias, de más de 2 pixels.
;;; Destruye el registro indicado por tmp_reg
INT_SLEEP MACRO delay, tmp_reg
		mov tmp_reg, #delay - 1 ; + 0.5 px = 0.5 px
		nop ; + 0.5px = 1 px
		djnz tmp_reg, $ ; + (delay - 1) px = delay px
		ENDM

;;; Sirve para realizar un pulso de ecualización
;;; Las posiciones corresponden a llamarla al inicio de la línea
EQ_PULSE MACRO ; (n, -1)
		mov graphics_port, #sync_level ; + 1 px = (n, 0)
		SHORT_SLEEP 5 ; + 2.5 px = (n, 2.5)
		mov graphics_port, #black_level ; + 1 px = (n, 3.5)
		INT_SLEEP 39, R0 ; + 39 px = (n, 42.5)
		SHORT_SLEEP 1 ; + 0.5 px = (n, 43)
		ENDM

;;; Sirve para realizar un pulso de vsync
;;; Las posiciones corresponden a llamarla al inicio de la línea
VSYNC_PULSE MACRO ; (n, -1)
		mov graphics_port, #sync_level ; + 1 px = (n, 0)
		INT_SLEEP 39, R0 ; + 39 px = (n, 39)
		SHORT_SLEEP 1 ; + 0.5 px = (n, 39.5)
		mov graphics_port, #black_level ; + 1 px = (n, 40.5)
		SHORT_SLEEP 5 ; + 0.5 px = (n, 43)
		ENDM

;;; Comienzo del código
CSEG AT 0x0000 ; FIXME: Por ahora no hay código de inicialización

;;; Empezamos a dibujar
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

		;; Llamamos al hsync
		call hsync ; + 9.5 px = (7.5, 17)

		;; Cargo para el bloque blanco superior
		mov R7, #31 ; + 0.5 px = (8, 17)

		;; Cargo para el 1er bloque vacío
		mov R6, #73 ; + 0.5 px = (8.5, 17)

		;; Cargo para la primera línea
		mov R5, #5 ; + 0.5 px = (9, 17)

		;; Cargo para el 2do bloque vacío
		mov R4, #140 ; + 0.5 px = (9.5, 17)

		;; Cargo para la 2da línea
		mov R3, #3 ; + 0.5 px = (10, 17)

		;; Cargo para el 3er y último bloque vacío
		mov R2, #35 ; + 0.5 px = (10.5, 17)

		;; Alineo a pixel
		SHORT_SLEEP 1 ; + 0.5 px = (11, 17)

		;; Cargo para 

		;; Esperamos para alinear con el primer ciclo
		INT_SLEEP 75, R0 ; + 75 px = (86, 17) = (-2, 18)

draw_lines_loop1: ; Para todas las otras primeras 31 líneas (-2, n)

		;; Llamamos al hsync
		call hsync ; + 9.5 px = (7.5, n)
		
		;; Alineo a pixel
		SHORT_SLEEP 1 ; + 0.5 px = (8, n)

		;; Espero a que termine el back porch
		INT_SLEEP 6, R0 ; + 6 px = (14, n)

		;; Pongo en color blanco
		mov graphics_port, #white_level ; + 1 px = (15, n)

		;; Espero hasta el final de la línea
		INT_SLEEP 69, R0 ; + 69 px = (84, n)

		;; Pongo nivel negro
		mov graphics_port, #black_level ; + 1 px = (85, n)

		;; Volvemos al loop
		djnz R7, draw_lines_loop1 ; + 1 px = (86, n) = (-2, n + 1)

draw_lines_loop2: ; Para el 1er bloque vacío

		;; Llamamos al hsync
		call hsync ; + 9.5 px = (7.5, n)

		;; Alineo a pixel
		SHORT_SLEEP 1 ; + 0.5 px = (8, n)

		;; Espero hasta media pantalla
		INT_SLEEP 12, R0 ; + 12 px = (20, n)

		;; 1 pixel blanco
		mov graphics_port, #white_level ; + 1 px = (21, n)

		;; Vuelvo a negro
		mov graphics_port, #black_level ; + 1 px = (22, n)
		
		;; Espero
		INT_SLEEP 50, R0 ; + 1 px = (72, n)

		;; 1 pixel blanco
		mov graphics_port, #white_level ; + 1 px = (73, n)

		;; Vuelvo a negro
		mov graphics_port, #black_level ; + 1 px = (74, n)

		;; Esperamos hasta el hsync
		INT_SLEEP 11, R0 ; + 11 px = (85, n)

		;; Volvemos al loop
		djnz R6, draw_lines_loop2 ; + 1 px = (86, n) = (-2, n + 1)

first_hline:
		;; Llamamos al hsync
		call hsync ; + 9.5 px = (7.5, n)
		
		;; Alineo a pixel
		SHORT_SLEEP 1 ; + 0.5 px = (8, n)

		;; Espero a que termine el back porch
		INT_SLEEP 6, R0 ; + 6 px = (14, n)

		;; Pongo en color blanco
		mov graphics_port, #white_level ; + 1 px = (15, n)

		;; Espero hasta el final de la línea
		INT_SLEEP 69, R0 ; + 69 px = (84, n)

		;; Pongo nivel negro
		mov graphics_port, #black_level ; + 1 px = (85, n)

		;; Volvemos al loop
		djnz R5, first_hline ; + 1 px = (86, n) = (-2, n + 1)
		
sec_empty_block:		
		;; Llamamos al hsync
		call hsync ; + 9.5 px = (7.5, n)

		;; Alineo a pixel
		SHORT_SLEEP 1 ; + 0.5 px = (8, n)

		;; Espero hasta media pantalla
		INT_SLEEP 25, R0 ; + 25 px = (33, n)

		;; 1 pixel blanco
		mov graphics_port, #white_level ; + 1 px = (34, n)

		;; Vuelvo a negro
		mov graphics_port, #black_level ; + 1 px = (35, n)
		
		;; Espero
		INT_SLEEP 30, R0 ; + 30 px = (65, n)

		;; 1 pixel blanco
		mov graphics_port, #white_level ; + 1 px = (66, n)

		;; Vuelvo a negro
		mov graphics_port, #black_level ; + 1 px = (67, n)

		;; Esperamos hasta el hsync
		INT_SLEEP 18, R0 ; + 18 px = (85, n)

		;; Volvemos al loop
		djnz R4, sec_empty_block ; + 1 px = (86, n) = (-2, n + 1)

second_hline:
		;; Llamamos al hsync
		call hsync ; + 9.5 px = (7.5, n)
		
		;; Alineo a pixel
		SHORT_SLEEP 1 ; + 0.5 px = (8, n)

		;; Espero a que termine el back porch
		INT_SLEEP 6, R0 ; + 6 px = (14, n)

		;; Pongo en color blanco
		mov graphics_port, #white_level ; + 1 px = (15, n)

		;; Espero hasta el final de la línea
		INT_SLEEP 69, R0 ; + 69 px = (84, n)

		;; Pongo nivel negro
		mov graphics_port, #black_level ; + 1 px = (85, n)

		;; Volvemos al loop
		djnz R3, second_hline ; + 1 px = (86, n) = (-2, n + 1)

third_empty_block:
		;; Llamamos al hsync
		call hsync ; + 9.5 px = (7.5, n)

		;; Alineo a pixel
		SHORT_SLEEP 1 ; + 0.5 px = (8, n)

		;; Espero hasta media pantalla
		INT_SLEEP 25, R0 ; + 25 px = (33, n)

		;; 1 pixel blanco
		mov graphics_port, #white_level ; + 1 px = (34, n)

		;; Vuelvo a negro
		mov graphics_port, #black_level ; + 1 px = (35, n)
		
		;; Espero
		INT_SLEEP 30, R0 ; + 30 px = (65, n)

		;; 1 pixel blanco
		mov graphics_port, #white_level ; + 1 px = (66, n)

		;; Vuelvo a negro
		mov graphics_port, #black_level ; + 1 px = (67, n)

		;; Esperamos hasta el hsync
		INT_SLEEP 18, R0 ; + 18 px = (85, n)

		;; Volvemos al loop
		djnz R2, third_empty_block ; + 1 px = (86, n) = (-2, n + 1)

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
		jmp hid_lines_start ; + 1 px = (86, 311)

;;;
;;; Procedimiento hsync
;;; El llamado hace las veces de front porch, ya que demora 1 px
;;; El retorno quita un pixel del back porch
;;; Parámetros: Ninguno
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

;;; Fin del módulo
END

;;;; Comentarios sobre area de pantalla
;;;; La primera línea visible es la 49
;;;; La columna 23 y la 71 se ven bien, con amplio margen
;;;; 5 líneas se ven igual que un pixel horizontal
;;;; Las últimas 35 líneas apenas se ven las 1ras (o sea como
;;;; está ahora, apenas se ve el 3er bloque.
