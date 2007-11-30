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
puerto_teclado EQU P2
puerto_teclado_0 EQU P2.0
puerto_teclado_1 EQU P2.1
puerto_teclado_2 EQU P2.2
puerto_teclado_3 EQU P2.3
puerto_teclado_4 EQU P2.4
puerto_teclado_5 EQU P2.5
puerto_teclado_6 EQU P2.6
puerto_teclado_7 EQU P2.7

nota_1 EQU 0x04
nota_2 EQU 0x08
nota_3 EQU 0x10
nota_4 EQU 0x20
silencio EQU 0x00

;La duración mínima de una nota es de 1 frame (20 ms) y se corresponderá con una corchea
tiempo_musical EQU 0x01
semifusa EQU (tiempo_musical)
fusa EQU (2*semifusa)
semicorchea EQU (2*fusa)
corchea EQU (2*semicorchea)
negra EQU (2*corchea)
blanca EQU (2*negra)

fin_melodia EQU 0xFF

puerto_sonido EQU P0

;Estados de melodia
detenida EQU 0
melodia_humano EQU 1
melodia_maquina EQU 2
melodia_final EQU 3
melodia_empate EQU 4

turno_maquina EQU 0
turno_humano EQU 1

arranca_maquina EQU 0
arranca_humano EQU 1

sym_e EQU 0
sym_x EQU 1
sym_o EQU 2
