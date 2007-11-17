;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beir� y Mariano Chouza
;;;; Constantes

;;; FIXME: Documentar mejor las constantes
					   
sync_level equ 0xE0 ; Salida para obtener el nivel de sincronizaci�n
black_level equ 0xF0 ; Salida para obtener el nivel de negro o supresi�n (es
                     ; indistinto en nuestro caso)
gray_level equ 0xE8 ; Salida para obtener el nivel de gris
white_level equ 0xF8 ; Salida para obtener el nivel de blanco

graphics_port	equ P1 ; Puerto donde se escribe para obtener los gr�ficos

total_lines equ 304 ; Cantidad total de l�neas
active_lines equ 287 ; Cantidad de l�neas activas
hidden_lines equ (total_lines - active_lines) ; Cantidad de l�neas ocultas

;Teclado
puerto_teclado_0 EQU P2.0
puerto_teclado_1 EQU P2.1
puerto_teclado_2 EQU P2.2
puerto_teclado_3 EQU P2.3
puerto_teclado_4 EQU P2.4
puerto_teclado_5 EQU P2.5
puerto_teclado_6 EQU P2.6
puerto_teclado_7 EQU P2.7