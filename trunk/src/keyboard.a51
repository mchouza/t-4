;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Módulo de teclado (KEYBOARD)
;;;; Se encarga de realizar la inicialización y revisa el teclado
		
$INCLUDE(macros.inc)		; Macros de propósito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general
$INCLUDE(serial.inc)		; Puerto serie
$INCLUDE(sound.inc)			; Sonido
$INCLUDE(util.inc)			; Sonido

NAME KEYBOARD

;;; Segmento propio de este módulo
KEYBOARD_SEG SEGMENT CODE

;;; Importa
$INCLUDE(variables.inc)		; Variables compartidas a nivel global

;;; Exporta solo la función de inicialización y la de revisióm
PUBLIC keyboard_init, keyboard_check

;;; Comienza el segmento KEYBOARD_SEG
RSEG KEYBOARD_SEG

;;;
;;; keyboard_init
;;;
;;;	Rutina que inicializa el teclado.
;;;

keyboard_init:
		;; Pone en 1 los pins para lectura
		setb puerto_teclado_0 ; Pin para lectura
		setb puerto_teclado_1 ; Pin para lectura
		setb puerto_teclado_2 ; Pin para lectura
		setb puerto_teclado_3 ; Pin para lectura
												   
		ret ; Vuelve

;;; FIXME: Poner parámetros etc...

;;;
;;; keyboard_check
;;;
;;;	Rutina que revisa el teclado.
;;;
;;; Se ejecuta una vez por barrido de pantalla (20 ms)
;;;
 
keyboard_check:
		MOV A, turno
		CJNE A, #turno_humano, saltar_a_fin ;Si no es el turno del jugador, salgo
		JMP no_saltar
	saltar_a_fin: 
		INT_SLEEP 54, R0
		SHORT_SLEEP 1 ; FIXME: Eliminar y sumar uno al INT_SLEEP
		JMP fin
	no_saltar:

		clr puerto_teclado_4 ;Exploro primera columna

		JB puerto_teclado_2, suelta_1 ;Veo si está suelta la tecla
		MOV R0, #0
		MOV R1, #0
		call poner_ficha
		INT_SLEEP 11, R3
		JMP fin
			
suelta_1:
		JB puerto_teclado_1, suelta_2 ;Veo si está suelta la tecla
		MOV R0, #1
		MOV R1, #0
		call poner_ficha
		INT_SLEEP 10, R3
		JMP fin

suelta_2:		
		JB puerto_teclado_0, suelta_3 ;Veo si está suelta la tecla
		MOV R0, #2
		MOV R1, #0
		call poner_ficha
		INT_SLEEP 9, R3
		JMP fin
		
suelta_3:
		setb puerto_teclado_4 ;Dejo primera columna
		clr puerto_teclado_5 ;Exploro segunda columna

		JB puerto_teclado_2, suelta_4 ;Veo si está suelta la tecla
		MOV R0, #0
		MOV R1, #1
		call poner_ficha
		INT_SLEEP 7, R3
		JMP fin
		
suelta_4:	
		JB puerto_teclado_1, suelta_5 ;Veo si está suelta la tecla
		MOV R0, #1
		MOV R1, #1
		call poner_ficha
		INT_SLEEP 6, R3
		JMP fin
		
suelta_5:
		JB puerto_teclado_0, suelta_6 ;Veo si está suelta la tecla
		MOV R0, #2
		MOV R1, #1
		call poner_ficha
		INT_SLEEP 5, R3
		JMP fin
		
suelta_6:
		setb puerto_teclado_5 ;Dejo segunda columna
		clr puerto_teclado_6 ;Exploro tercera columna

		JB puerto_teclado_2, suelta_7 ;Veo si está suelta la tecla
		MOV R0, #0
		MOV R1, #2
		call poner_ficha
		SHORT_SLEEP 4
		JMP fin

suelta_7:	
		JB puerto_teclado_1, suelta_8 ;Veo si está suelta la tecla
		MOV R0, #1
		MOV R1, #2
		call poner_ficha
		SHORT_SLEEP 2
		JMP fin
		
suelta_8:
		JB puerto_teclado_0, suelta_9 ;Veo si está suelta la tecla
		MOV R0, #2
		MOV R1, #2
		call poner_ficha
		JMP fin
		
suelta_9:
		;Si no se tocó ninguna tecla, agrego mismo tiempo que si se hubiese tocado
		;MOV + MOV + poner_ficha + JMP
		SHORT_SLEEP 1
		INT_SLEEP 61, R0
		mov puerto_teclado, #0xff
		ret

		;SUMAR TIEMPO PARA QUE COMPLETE LA LINEA
	fin:
		SHORT_SLEEP 1
		INT_SLEEP 18, R3
		;; Restauro el estado del puerto
		mov puerto_teclado, #0xff

		;; Vuelvo
		ret
	;Fin de rutina revisar_teclado


;;; Fin del módulo
END
