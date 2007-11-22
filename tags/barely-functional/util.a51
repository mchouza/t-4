;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Módulo de utilidad general (UTIL)
;;;; Contiene funciones varias

$INCLUDE(macros.inc)		; Macros de propósito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general

NAME UTIL

;;; Segmento propio de este módulo
UTIL_SEG SEGMENT CODE

;;; Importa
$INCLUDE(variables.inc)		; Variables compartidas a nivel global

;;; Exporta todas las funciones
PUBLIC put_symbol_var

;;; Comienza el segmento UTIL_SEG
RSEG UTIL_SEG

;;; Pone un símbolo indicado por R3 en la posición:
;;; R0 -> fila, R1 -> columna
;;; El símbolo si gue la codificación:
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

END
