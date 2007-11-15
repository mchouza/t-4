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
		JMP fin

	no_saltar:
		CLR puerto_teclado_4 ;Exploro primera columna
		
		JB puerto_teclado_0, sig_11 ;Veo si está suelta la tecla (1,1)
		;Analizo si ese lugar del tablero ya está ocupado
		MOV A, linea_1 ;Obtengo la primera fila
		MOV B, #4
		DIV AB ;Tengo en B los últimos dos bits de fila_1
		MOV A,B
		CJNE A, #0, sig_11 ;Si no está vacía salgo
		%PUT_SYMBOL(0, 0, X)
		MOV jugar, #0
   
	sig_11: 	
		jb puerto_teclado_1, sig_21 ;Veo si está suelta la tecla (2,1)
		;Analizo si ese lugar del tablero ya está ocupado
		MOV A, linea_2 ;Obtengo la segunda fila
		MOV B, #4
		DIV AB ;Tengo en B los últimos dos bits de fila_2
		MOV A,B
		CJNE A, #0, sig_21 ;Si no está vacía salgo
		%PUT_SYMBOL(1, 0, X)
		MOV jugar, #0

	sig_21:
		jb puerto_teclado_2, sig_31 ;veo si está suelta la tecla (3,1)
		;Analizo si ese lugar del tablero ya está ocupado
		MOV A, linea_3 ;Obtengo la tercera fila
		MOV B, #4
		DIV AB ;Tengo en B los últimos dos bits de fila_3
		MOV A,B
		CJNE A, #0, sig_31 ;Si no está vacía salgo
		%PUT_SYMBOL(2, 0, X)
		MOV jugar, #0

	sig_31: 
		setb puerto_teclado_4 ;Dejo primera columna
		clr puerto_teclado_5 ;Exploro segunda columna
	
		jb puerto_teclado_0, sig_12 ;Veo si está suelta la tecla (1,2)
		;Analizo si ese lugar del tablero ya está ocupado
		MOV A, linea_1 ;Obtengo la primera fila
		RR A
		RR A
		MOV B, #4
		DIV AB ;Tengo en B los dos bits del medio de fila_1
		MOV A,B
		CJNE A, #0, sig_12 ;Si no está vacía salgo
		%PUT_SYMBOL(0, 1, X)
		MOV jugar, #0

	sig_12: 	
		jb puerto_teclado_1, sig_22 ;Veo si está suelta la tecla (2,2)
		;Analizo si ese lugar del tablero ya está ocupado
		MOV A, linea_2 ;Obtengo la segunda fila
		RR A
		RR A
		MOV B, #4
		DIV AB ;Tengo en B los dos bits del medio de fila_2
		MOV A,B
		CJNE A, #0, sig_22 ;Si no está vacía salgo
		%PUT_SYMBOL(1, 1, X)
		MOV jugar, #0

	sig_22: 	
		jb puerto_teclado_2, sig_32 ;Veo si está suelta la tecla (3,2)
		;Analizo si ese lugar del tablero ya está ocupado
		MOV A, linea_3 ;Obtengo la tercera fila
		RR A
		RR A
		MOV B, #4
		DIV AB ;Tengo en B los dos bits del medio de fila_3
		MOV A,B
		CJNE A, #0, sig_32 ;Si no está vacía salgo
		%PUT_SYMBOL(2, 1, X)
		MOV jugar, #0

	sig_32: 	
		setb puerto_teclado_5 ;Dejo segunda columna
		clr puerto_teclado_6 ;Exploro tercera columna

		jb puerto_teclado_0, sig_13 ;Veo si está suelta la tecla (1,3)
		;Analizo si ese lugar del tablero ya está ocupado
		MOV A, linea_1 ;Obtengo la primera fila
		RR A
		RR A
		RR A
		RR A
		MOV B, #4
		DIV AB ;Tengo en B los primeros dos bits de fila_1
		MOV A,B
		CJNE A, #0, sig_13 ;Si no está vacía salgo
		%PUT_SYMBOL(0, 2, X)
		MOV jugar, #0

	sig_13: 	
		jb puerto_teclado_1, sig_23 ;Veo si está suelta la tecla (2,3)
		;Analizo si ese lugar del tablero ya está ocupado
		MOV A, linea_2 ;Obtengo la segunda fila
		RR A
		RR A
		RR A
		RR A
		MOV B, #4
		DIV AB ;Tengo en B los primeros dos bits de fila_2
		MOV A,B
		CJNE A, #0, sig_23 ;Si no está vacía salgo
		%PUT_SYMBOL(1, 2, X)
		MOV jugar, #0

	sig_23: 	
		jb puerto_teclado_2, sig_33 ;Veo si está suelta la tecla (3,3)
		;Analizo si ese lugar del tablero ya está ocupado
		MOV A, linea_3 ;Obtengo la tercera fila
		RR A
		RR A
		RR A
		RR A
		MOV B, #4
		DIV AB ;Tengo en B los primeros dos bits de fila_3
		MOV A,B
		CJNE A, #0, sig_33 ;Si no está vacía salgo
		%PUT_SYMBOL(2, 2, X)
		MOV jugar, #0

	sig_33:
		setb puerto_teclado_6 ;Dejo tercera columna
	
	fin:
		ret

;;; Fin del módulo
END
