;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beir� y Mariano Chouza
;;;; Constantes

sync_level equ 0x00 ; Salida para obtener el nivel de sincronizaci�n
black_level equ 0x40 ; Salida para obtener el nivel de negro o supresi�n (es
                     ; indistinto en nuestro caso)
gray_level equ 0x80 ; Salida para obtener el nivel de gris
white_level equ 0xc0 ; Salida para obtener el nivel de blanco

graphics_port	equ P1 ; Puerto donde se escribe para obtener los gr�ficos

total_lines equ 304 ; Cantidad total de l�neas
active_lines equ 287 ; Cantidad de l�neas activas
hidden_lines equ (total_lines - active_lines) ; Cantidad de l�neas ocultas
