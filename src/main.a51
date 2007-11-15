;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beir� y Mariano Chouza
;;;; M�dulo principal (MAIN)
;;;; Se encarga de realizar la inicializaci�n y llama al loop principal de
;;;; video.

$INCLUDE(macros.inc)		; Macros de prop�sito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general

NAME MAIN

;;; Segmento propio de este m�dulo
MAIN_SEG SEGMENT CODE

;;; Importa
$INCLUDE(variables.inc)		; Variables compartidas a nivel global
$INCLUDE(draw_main.inc)			; Procedimientos de dibujo
$INCLUDE(keyboard.inc)		; Procedimientos de manejo de teclado

;;; Exporta solo el punto de entrada
PUBLIC main

;;; FIXME: Poner en un m�dulo aparte
CSEG AT 0x0000

reset_vec:
		;;; En caso de empezar la ejecuci�n, salta al entry point
		jmp main

;;; Comienza el segmento MAIN_SEG
RSEG MAIN_SEG

;;;
;;; main
;;;
;;; Entry point y rutina principal
;;;

main:
		mov IE, #0 ; Aseguro que est�n deshabilitadas las interrupciones individuales.
		clr EA ; Desactivo las interrupciones.

		mov	SP, #(stack - 1) ; Inicializo el stack pointer.
		
		;; FIXME: HAcer que seleccione el banco 0
		;SEL_BANK 0 ; Selecciono el banco de registros 0.

		;; FIXME: Agregar inicializaciones
		call keyboard_init

		;; FIXME: No activo las interrupciones, analizar consecuencias

		call draw_loop ; Salto al loop de dibujo

		;; Nunca vuelve

;;; Fin del m�dulo
END
