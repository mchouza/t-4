;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Módulo de utilidad general (UTIL)
;;;; Contiene funciones varias

$INCLUDE(macros.inc)		; Macros de propósito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general
$INCLUDE(sound.inc)	; Constantes de utilidad general

NAME UTIL

;;; Segmento propio de este módulo
UTIL_SEG SEGMENT CODE

;;; Importa
$INCLUDE(variables.inc)		; Variables compartidas a nivel global

;;; Exporta todas las funciones
PUBLIC put_symbol_var, poner_ficha, pantalla_negro

;;; Comienza el segmento UTIL_SEG
RSEG UTIL_SEG

;;; Pone un símbolo indicado por R3 en la posición:
;;; R0 -> fila, R1 -> columna
;;; El símbolo sigue la codificación:
;;; 0 -> E, 1 -> X, 2 -> O
;;; Destruye B
put_symbol_var: ; (0)
		mov B, #NOT(3) ; + 0.5 px  = (0.5)
		xch A, R3 ; + 0.5 px = (1)
		
		cjne R1, #0, need_2_shift ; + 1 px = (2)
		SHORT_SLEEP 5 ; + 2.5 px = (4.5)
		jmp shifted ; + 1 px = (5.5)

	need_2_shift: ; Se que es por 2 o 4 Pos: (2)
		cjne R1, #2, shift_two_bits ; + 1 px = (3)
		mov B, #(NOT(3) SHL 4) ; + 1 px = (4)
		swap A ; + 0.5 px = (4.5)
		jmp shifted ; + 1 px = (5.5)

	shift_two_bits: ; (3)
		rl A ; + 0.5 px = (3.5)
		rl A ; + 0.5 px = (4)
		mov B, #(NOT(3) SHL 2) ; + 1px = (5)
		SHORT_SLEEP 1 ; + 0.5 px = (5.5)

	shifted: ; (5.5)
		;; Guardo el valor shifteado
		mov R1, A ; + 0.5 px = (6)

		;; Calculo adonde guardarlo y lo pongo en R0
		mov A, R0 ; + 0.5 px = (6.5)
		add A, #linea_0 ; + 0.5 px = (7)
		mov R0, A ; + 0.5 px = (7.5)

		;; Cargo el viejo valor de la fila en el acumulador y le aplico
		;; la máscara
		mov A, @R0 ; + 1 px = (8.5)
		anl A, B  ; + 1 px = (9.5)
		
		;; Le incorporo el valor shifteado
		orl A, R1 ; + 0.5 px = (10)
		;; Lo guardo
		mov @R0, A ; + 1 px = (11)

		;; Recupero el acumulador
		xch A, R3 ; + 0.5 px = (11.5)

		;; Listo
		ret ; + 1 px = (12.5)

;;; R0 -> fila, R1 -> columna
; Duración: 41 pixels
poner_ficha:
		MOV A, R0
		MOV R2, A ;Mantengo la fila en R2, porque R0 lo voy a modificar
		MOV A, R1
		MOV R3, A ;Mantengo la columna en R3, porque R1 lo voy a modificar
		MOV A, R0
		add A, #linea_0 ;Tengo en A la dirección de la variable correspondiente a la fila
		MOV R0, A
		MOV A, @R0 ;Ahora tengo en A la variable correspondiente a la fila
		;Tengo que shiftear a la derecha una cantidad de bits igual a dos veces el número de columna
		
		CJNE R1, #0, no_cero
		INT_SLEEP 4, R4
		JMP shifteo_listo		
no_cero:
		CJNE R1, #1, no_uno
		RR A
		RR A
		SHORT_SLEEP 4
		JMP shifteo_listo
no_uno:
		RR A
		RR A
		RR A
		RR A
		SHORT_SLEEP 4

shifteo_listo:
		;Ahora tengo en los dos bits menos significativos de A el símbolo correspondiente a la fila y columna
		anl A, #3 ;Tengo en A el símbolo correspondiente a la fila y columna
		CJNE A, #0, no_vacia ;Si no está vacía salgo

		;Veo si pone cruz (arranca_humano) o circulo (arranca_maquina)
		MOV R0, arranca
		CJNE R0, #arranca_humano, poner_circulo
		MOV A, R2
		MOV R0, A
		MOV A, R3
		MOV R1, A
		MOV R3, #1 ;Cruz según la especificación de put_symbol_var
		call put_symbol_var  ;Si arrancó el humano, juega con cruces
		JMP ficha_puesta
	poner_circulo:
		MOV A, R2
		MOV R0, A
		MOV A, R3
		MOV R1, A
		MOV R3, #2 ;Círculo según la especificación de put_symbol_var
		call put_symbol_var ;Si arrancó la máquina, el humano juega con círculos
		JMP ficha_puesta
	ficha_puesta:
		MOV A, #melodia_humano
		CALL sound_start_melody ; Reproduzco la melodia
		MOV turno, #turno_maquina ;Turno=maquina
		MOV timer_jugada_maquina, #100 ;Para que espere 2 segundos (100 frames) antes de jugar la máquina
		MOV enviar_lineas_serial, #3 ;Indico que hay que enviar las 3 lineas del tablero a la PC
		ret
	no_vacia:	;Agrego el tiempo del put_symbol y del mov
		SHORT_SLEEP 1
		INT_SLEEP 28, R3
		ret


pantalla_negro:
prev_linea_negro:
		;; Comenzamos el pulso sync
		mov graphics_port, #sync_level
		;; Esperamos 5 pixels
		INT_SLEEP 5, R0
		;; Esperamos 1/2 pixel más
		SHORT_SLEEP 1
		;; Volvemos a nivel de supresión
		mov graphics_port, #black_level
		MOV R2, #151

		mov R1, #77
		DJNZ R1, $

linea_negro:
		;; Comenzamos el pulso sync
		mov graphics_port, #sync_level
		;; Esperamos 5 pixels
		INT_SLEEP 5, R0
		;; Esperamos 1/2 pixel más
		SHORT_SLEEP 1
		;; Volvemos a nivel de supresión
		mov graphics_port, #black_level
		mov R1, #77
		DJNZ R1, $

		DJNZ R2, linea_negro

prev_linea_negro_2:
		;; Comenzamos el pulso sync
		mov graphics_port, #sync_level
		;; Esperamos 5 pixels
		INT_SLEEP 5, R0
		;; Esperamos 1/2 pixel más
		SHORT_SLEEP 1
		;; Volvemos a nivel de supresión
		mov graphics_port, #black_level
		MOV R2, #151

		mov R1, #77
		DJNZ R1, $

linea_negro_2:
		;; Comenzamos el pulso sync
		mov graphics_port, #sync_level
		;; Esperamos 5 pixels
		INT_SLEEP 5, R0
		;; Esperamos 1/2 pixel más
		SHORT_SLEEP 1
		;; Volvemos a nivel de supresión
		mov graphics_port, #black_level
		mov R1, #77
		DJNZ R1, $

		DJNZ R2, linea_negro_2

sinc_vertical:
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

		ret
		
END
