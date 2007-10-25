;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Constantes

sync_level equ 0x00 ; Salida para obtener el nivel de sincronización
black_level equ 0x40 ; Salida para obtener el nivel de negro o supresión (es
                     ; indistinto en nuestro caso)
gray_level equ 0x80 ; Salida para obtener el nivel de gris
white_level equ 0xc0 ; Salida para obtener el nivel de blanco

graphics_port	equ P1 ; Puerto donde se escribe para obtener los gráficos

total_lines equ 304 ; Cantidad total de líneas
active_lines equ 287 ; Cantidad de líneas activas
hidden_lines equ (total_lines - active_lines) ; Cantidad de líneas ocultas

