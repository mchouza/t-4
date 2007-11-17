;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Módulo de teclado (KEYBOARD)
;;;; Se encarga de realizar la inicialización y revisa el teclado
		
$INCLUDE(macros.inc)		; Macros de propósito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general

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
;;; inicializar_teclado
;;;
;;;	Rutina que inicializa el teclado.
;;;

keyboard_init:
		;; Pone en 1 los pins para lectura
		setb puerto_teclado_0 ; Pin para lectura
		setb puerto_teclado_1 ; Pin para lectura
		setb puerto_teclado_2 ; Pin para lectura
		setb puerto_teclado_3 ; Pin para lectura

		mov jugar, #1 ; Turno del humano

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
		MOV A, jugar
		;FIXME!!! Eliminar la próxima línea!!! Es para que el humano pueda jugar sin esperar a la máquina
		MOV A, #1
		CJNE A, #1, saltar_a_fin ;Si no es el turno del jugador, salgo
		JMP no_saltar
	saltar_a_fin: 
		INT_SLEEP 73, R0
		SHORT_SLEEP 1 ; FIXME: Eliminar y sumar uno al INT_SLEEP
		JMP fin
	no_saltar:

		CLR puerto_teclado_4 ;Exploro primera columna

		leer_tecla 0, 0
		leer_tecla 1, 0
		leer_tecla 2, 0

		setb puerto_teclado_4 ;Dejo primera columna
		clr puerto_teclado_5 ;Exploro segunda columna

		leer_tecla 0, 1
		leer_tecla 1, 1
		leer_tecla 2, 1

		setb puerto_teclado_5 ;Dejo segunda columna
		clr puerto_teclado_6 ;Exploro tercera columna

		leer_tecla 0, 2
		leer_tecla 1, 2
		leer_tecla 2, 2

		setb puerto_teclado_6 ;Dejo tercera columna

		;SUMAR TIEMPO PARA QUE COMPLETE LA LINEA
	fin:
		ret
	;Fin de rutina revisar_teclado


;;; Fin del módulo
END
