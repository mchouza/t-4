;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Constantes

;;; FIXME: Documentar mejor las constantes

;;; Utilizo el banco 0
USING 0

		   
sync_level equ 0xE0 ; Salida para obtener el nivel de sincronización
black_level equ 0xF0 ; Salida para obtener el nivel de negro o supresión (es
                     ; indistinto en nuestro caso)
gray_level equ 0xE8 ; Salida para obtener el nivel de gris
white_level equ 0xF8 ; Salida para obtener el nivel de blanco

graphics_port	equ P1 ; Puerto donde se escribe para obtener los gráficos

total_lines equ 304 ; Cantidad total de líneas
active_lines equ 287 ; Cantidad de líneas activas
hidden_lines equ (total_lines - active_lines) ; Cantidad de líneas ocultas

;Teclado
puerto_teclado_0 EQU P2.0
puerto_teclado_1 EQU P2.1
puerto_teclado_2 EQU P2.2
puerto_teclado_3 EQU P2.3
puerto_teclado_4 EQU P2.4
puerto_teclado_5 EQU P2.5
puerto_teclado_6 EQU P2.6
puerto_teclado_7 EQU P2.7
