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
PUBLIC put_symbol_var, poner_ficha

;;; Comienza el segmento UTIL_SEG
RSEG UTIL_SEG

;;; Pone un símbolo indicado por R3 en la posición:
;;; R0 -> fila, R1 -> columna
;;; El símbolo sigue la codificación:
;;; 0 -> E, 1 -> X, 2 -> O
;;; Destruye B
put_symbol_var:
		mov B, #NOT(3)
		xch A, R3
		
		cjne R1, #0, need_2_shift
		jmp shifted

	need_2_shift: ; Se que es por 2 o 4
		cjne R1, #2, shift_two_bits
		mov B, #(NOT(3) SHL 4)
		swap A
		jmp shifted

	shift_two_bits:
		rl A
		rl A
		mov B, #(NOT(3) SHL 2)

	shifted:
		;; Guardo el valor shifteado
		mov R1, A

		;; Calculo adonde guardarlo y lo pongo en R0
		mov A, R0
		add A, #linea_0
		mov R0, A

		;; Cargo el viejo valor de la fila en el acumulador y le aplico
		;; la máscara
		mov A, @R0
		anl A, B
		
		;; Le incorporo el valor shifteado
		orl A, R1
		;; Lo guardo
		mov @R0, A

		;; Recupero el acumulador
		xch A, R3

		;; Listo
		ret

;;; Pone un símbolo indicado por R3 en la posición:
;;; R0 -> fila, R1 -> columna
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
		
		INC R1 ;Sumo uno porque inmediatamente voy a decrementar
analizar_seguir_shifteando:
		DJNZ R1, seguir_shifteando
		JMP shifteo_listo
seguir_shifteando:
		rr A
		rr A
		JMP analizar_seguir_shifteando
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
	no_vacia:	;Agrego el tiempo del put_symbol y del mov
		SHORT_SLEEP 1
		ret
	suelta:	;Agrego todo el tiempo anterior
		ret


END
