;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beir� y Mariano Chouza
;;;; M�dulo de utilidad general (UTIL)
;;;; Contiene funciones varias

$INCLUDE(macros.inc)		; Macros de prop�sito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general
$INCLUDE(sound.inc)	; Constantes de utilidad general

NAME UTIL

;;; Segmento propio de este m�dulo
UTIL_SEG SEGMENT CODE

;;; Importa
$INCLUDE(variables.inc)		; Variables compartidas a nivel global

;;; Exporta todas las funciones
PUBLIC put_symbol_var, poner_ficha, pantalla_negro

;;; Comienza el segmento UTIL_SEG
RSEG UTIL_SEG

;;; Pone un s�mbolo indicado por R3 en la posici�n:
;;; R0 -> fila, R1 -> columna
;;; El s�mbolo sigue la codificaci�n:
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
		;; la m�scara
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

;;; R0 -> fila, R1 -> columna
poner_ficha:
		MOV A, R0
		MOV R2, A ;Mantengo la fila en R2, porque R0 lo voy a modificar
		MOV A, R1
		MOV R3, A ;Mantengo la columna en R3, porque R1 lo voy a modificar
		MOV A, R0
		add A, #linea_0 ;Tengo en A la direcci�n de la variable correspondiente a la fila
		MOV R0, A
		MOV A, @R0 ;Ahora tengo en A la variable correspondiente a la fila
		;Tengo que shiftear a la derecha una cantidad de bits igual a dos veces el n�mero de columna
		
		CJNE R1, #0, no_cero
		NOP
		NOP
		NOP
		NOP
		NOP
		NOP
no_cero:
		CJNE R1, #1, no_uno
		RR A
		RR A
		NOP
		NOP
		JMP shifteo_listo
no_uno:
		RR A
		RR A
		RR A
		RR A
		NOP
shifteo_listo:
		;Ahora tengo en los dos bits menos significativos de A el s�mbolo correspondiente a la fila y columna
		anl A, #3 ;Tengo en A el s�mbolo correspondiente a la fila y columna
		CJNE A, #0, no_vacia ;Si no est� vac�a salgo

		;Veo si pone cruz (arranca_humano) o circulo (arranca_maquina)
		MOV R0, arranca
		CJNE R0, #arranca_humano, poner_circulo
		MOV A, R2
		MOV R0, A
		MOV A, R3
		MOV R1, A
		MOV R3, #1 ;Cruz seg�n la especificaci�n de put_symbol_var
		call put_symbol_var  ;Si arranc� el humano, juega con cruces
		JMP ficha_puesta
	poner_circulo:
		MOV A, R2
		MOV R0, A
		MOV A, R3
		MOV R1, A
		MOV R3, #2 ;C�rculo seg�n la especificaci�n de put_symbol_var
		call put_symbol_var ;Si arranc� la m�quina, el humano juega con c�rculos
		JMP ficha_puesta
	ficha_puesta:
		MOV A, #melodia_humano
		CALL sound_start_melody ; Reproduzco la melodia
		MOV turno, #turno_maquina ;Turno=maquina
		MOV timer_jugada_maquina, #100 ;Para que espere 2 segundos (100 frames) antes de jugar la m�quina
		MOV enviar_lineas_serial, #3 ;Indico que hay que enviar las 3 lineas del tablero a la PC
	no_vacia:	;Agrego el tiempo del put_symbol y del mov
		SHORT_SLEEP 1
		ret
	suelta:	;Agrego todo el tiempo anterior
		ret


pantalla_negro:
		;;FIXME: Corregir el 220
		MOV R2, #220
linea_negro:
		;; Comenzamos el pulso sync
		mov graphics_port, #sync_level
		;; Esperamos 5 pixels
		INT_SLEEP 5, R0
		;; Esperamos 1/2 pixel m�s
		SHORT_SLEEP 1
		;; Volvemos a nivel de supresi�n
		mov graphics_port, #black_level
		mov R1, #78
		DJNZ R1, $
		DJNZ R2, linea_negro


sinc_vertical:
		;; Espero 1 pixel
		SHORT_SLEEP 2 ; + 1 px = (-1, 304)

		;; Hago 6 pulsos de ecualizaci�n (-1, 304)
		REPT 6
			EQ_PULSE
		ENDM ; + 3 li = (-1, 307)

		;; Hago 5 pulsos de vsync
		REPT 5
			VSYNC_PULSE
		ENDM ; + 2.5 li = (43, 309)

		;; Hago 4 pulsos de ecualizaci�n
		REPT 4
			EQ_PULSE
		ENDM ; + 2 li = (43, 311)

		;; Hago el �ltimo en forma manual, para enganchar con las l�neas de arriba
		mov graphics_port, #sync_level ; + 1 px = (44, 311)
		SHORT_SLEEP 5 ; + 2.5 px = (46.5, 311)
		mov graphics_port, #black_level ; + 1 px = (47.5, 311)
		INT_SLEEP 37, R0 ; + 37 px = (84.5, 311)
		SHORT_SLEEP 1 ; + 0.5 px = (85, 311)	

		ret
		
END
