;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beir� y Mariano Chouza
;;;; Dibujo del tablero
;;;; Loop principal

NAME DIBUJO_TABLERO

;;;
;;; Constantes
;;;

sync_level equ 0x00 ; Salida para obtener el nivel de sincronizaci�n
black_level equ 0x40 ; Salida para obtener el nivel de negro o supresi�n (es
                     ; indistinto en nuestro caso)
gray_level equ 0x80 ; Salida para obtener el nivel de gris
white_level equ 0xc0 ; Salida para obtener el nivel de blanco

graphics_port	equ P1 ; Puerto donde se escribe para obtener los gr�ficos

total_lines equ 305 ; Cantidad total de l�neas
active_lines equ 288 ; Cantidad de l�neas activas
hidden_lines equ (total_lines - active_lines) ; Cantidad de l�neas ocultas

back_porch_px equ 10 ; Cantidad de pixels en el back porch
front_porch_px equ 1 ; Cantidad de pixels en el front porch
visible_px equ 71 ; Cantidad de pixels visibles

;;;
;;; Macros
;;;

;;; Sirve para esperas cortas. Consume 1 byte por medio pixel de espera.
SHORT_SLEEP MACRO delay_in_half_pixels
		REPT delay_in_half_pixels
			nop ; + 0.5px
		ENDM 
		ENDM ; + (delay_in_half_pixels / 2) px

;;; Sirve para esperas intermedias, de m�s de 2 pixels.
;;; Destruye el registro indicado por tmp_reg
INT_SLEEP MACRO delay, tmp_reg
		mov tmp_reg, #delay - 1 ; + 0.5 px = 0.5 px
		nop ; + 0.5px = 1 px
		djnz tmp_reg, $ ; + (delay - 1) px = delay px
		ENDM

;;; Comienzo del c�digo
CSEG AT 0x0000 ; FIXME: Por ahora no hay c�digo de inicializaci�n

;;; Empezamos a dibujar
;;; Como casi todas las instrucciones toman dos ciclos de m�quina o sea 24
;;; ciclos de reloj y estamos operando a 33 MHz, tomamos cada pixel como
;;; de 0.727 us = (1 / 33 MHz) * 24
;;; Consideramos a un frame como formado por 305 l�neas, cada una de las
;;; cuales est� formada por 87 p�xels (63.5 us / 0.727 us = 87.34).
;;; De estos solo 71 pixels son visibles, siendo el resto reservado para la
;;; secuencia de sincronizaci�n horizontal (front porch / sync pulse /
;;; back porch)

;;; Por lo tanto el formato de una l�nea ser�a en pixels:
;;; 0 a 10 -> back porch
;;; 10 a 81 -> datos
;;; 81 a 82 -> front porch
;;; 82 a 87 (= 0) -> sync pulse

;;; Los n�meros de las l�neas ser�an:
;;; 0 a 17 -> ocultas
;;; 17 a 305 -> visibles
;;; 305 a 313 (=0) -> vsync sequence

;;; Debido a la gran importancia de los tiempos en este programa, a la derecha
;;; de cada instrucci�n se indica cuantos pixels (0.727 us) demora y la
;;; posici�n en la que estar�a despu�s de su ejecuci�n en forma de un par
;;; (pixel, linea)

hid_lines_start: ; Comienzan las l�neas ocultas

		;; Cargamos la cantidad de l�neas ocultas - 1 (pierdo una por alinear)
		mov R7, #hidden_lines - 1 ; + 0.5px = (0.5, 0)

		;; Alineamos a pixel
		SHORT_SLEEP 1 ; + 0.5 px = (1, 0)

		;; Esperamos para alinear con el primer ciclo
		INT_SLEEP visible_px + back_porch_px - 1, R0 ; + 80 px = (81, 0)

		;; Llamamos al hsync
		call hsync ; + 7 px = (88, 0) = (1, 1)

		;; Alineamos
		SHORT_SLEEP 2 ; + 1 px = (2, 1)

hid_lines_loop: ; Para todas las otras l�neas ocultas (2, n)

		;; Esperamos hasta que llegue al hsync
		INT_SLEEP 79, R0 ; + 79 px = (81, n)

		;; Llamamos al hsync
		call hsync ; + 7 px = (88, n) = (1, n + 1)

		;; Volvemos al loop
		djnz R7, hid_lines_loop ; + 1 px = (2, n + 1)

hid_lines_end: ; Terminan las l�neas ocultas (2, 17)

draw_start: ; Asociado con la parte superior izquierda de la pantalla (2, 17)

		;; Cargamos la cantidad de l�neas visibles - 1
		;; (pierdo una por alinear) - 255 (no entran todas en un loop)
		mov R7, #active_lines - 1 - 255 ; + 0.5 px = (2.5, 17)

		;; Cargamos 255 (para el otro loop)
		mov R6, 255 ; + 0.5 px = (3, 17)

		;; Esperamos para alinear con el primer ciclo
		INT_SLEEP visible_px + back_porch_px - 3, R0 ; + 78 px = (81, 17)

		;; Llamamos al hsync
		call hsync ; + 7 px = (88, 17) = (1, 18)

		;; Alineamos para entrar al ciclo
		SHORT_SLEEP 2 ; + 1 px = (2, 18)

draw_lines_loop1: ; Para todas las otras primeras 32 l�neas (2, 18)

		;; Esperamos hasta el hsync
		INT_SLEEP 79, R0 ; + 79 px = (81, n)

		;; Llamamos al hsync
		call hsync ; + 7 px = (88, n) = (1, n + 1)

		;; Volvemos al loop
		djnz R7, draw_lines_loop1 ; + 1 px = (2, n + 1)

draw_lines_loop2: ; Para las 255 finales (34, 2)

		;; Esperamos hasta el hsync
		INT_SLEEP 79, R0 ; + 79 px = (81, n)

		;; Llamamos al hsync
		call hsync ; + 7 px = (88, n) = (1, n + 1)

		;; Volvemos al loop
		djnz R7, draw_lines_loop1 ; + 1 px = (2, n + 1)

draw_end: ; Termina de dibujar (289, 2)

vsync_start: ; Comienza el sincronismo vertical (289, 2)

		;; Hago los pulsos de ecualizaci�n iniciales
		call eq_pulse_train ; + XX px = (XXX, XXX)

		;; Hago los pulsos de vsync propiamente dichos
		call vsync_pulse_train ; + XX px = (XXX, XXX)

		;; Hago el otro tren de pulsos de ecualizaci�n
		call eq_pulse_train2 ; + XX px = (XXX, XXX)

vsync_end: ; Termina el sincronismo vertical

		;; Volvemos al comienzo
		jmp hid_lines_start ; + 1 px = (XXX, XXX)

;;;
;;; Procedimiento hsync
;;; El llamado hace las veces de front porch, ya que demora 1 px
;;; El retorno quita un pixel del back porch
;;; Par�metros: Ninguno
;;; Registros modificados: R0
;;;

hsync: ; (82, n)

		;; Comienzo el pulso sync
		mov graphics_port, #sync_level ; + 0.5 px = (82.5, n)

		;; Espero 4 pixels
		INT_SLEEP 4, R0 ; + 4 px = (86.5, n)

		;; Vuelvo a nivel de supresi�n
		mov graphics_port, #black_level ; + 0.5 px = (87, n) = (0, n + 1)

		;; Vuelvo
		ret ; + 1px = (1, n + 2)

;;;
;;; Procedimiento eq_pulse_train
;;; Par�metros: Ninguno
;;; Registros modificados: R0
;;;

eq_pulse_train: ; (289, 3)

		;; Llevo a blanco
		mov graphics_port, #sync_level ; + 0.5 px =  

;;; Fin del m�dulo
END
