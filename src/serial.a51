;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Módulo serial (SERIAL)
;;;; Se encarga de enviar y recibir datos por el puerto serie a la PC

$INCLUDE(macros.inc)		; Macros de propósito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general
$INCLUDE(util.inc)	; Constantes de utilidad general

NAME SERIAL

;;; Segmento propio de este módulo
SERIAL_SEG SEGMENT CODE

;;; Importa
$INCLUDE(variables.inc)		; Variables compartidas a nivel global

;;; Exporta solo la función de inicialización y la de reproduccion
PUBLIC serial_init, serial_send, serial_receive

;;; Comienza el segmento SERIAL_SEG
RSEG SERIAL_SEG

;;;
;;; serial_init
;;;

serial_init:

		;Habilito el puerto serie con SCON.	Modo 1
		clr SM0 ;SM0=0
		setb SM1 ;SM1=1
		;Configuro el timer1 en Modo 2 (8 bits autoreload)
		MOV TMOD, #0x20
		;Pongo TH1 en contar 18
		MOV TH1, #238
		MOV TL1, #238
		;Pongo SMOD en 0 para NO duplicar el baud rate
		ORL PCON, #0x80
		;Activo el timer 1
		setb TR1

		;Pongo TI en 1 para indicar que estoy en condiciones de enviar datos
		setb TI

		;Habilito la recepción de datos por el puerto serie.
		setb REN

		;Todavía no hay que enviar nada del tablero a la PC.
		MOV enviar_lineas_serial, #0

		ret

;;;
;;; serial_send
;;;

serial_send:
	   	MOV R0, enviar_lineas_serial
		CJNE R0, #0, hay_datos_serial
no_hay_datos_serial:
		ret
hay_datos_serial:
		jnb TI, $ ;Cuando el micro termina la transmisión, avisará seteando TI
		clr TI ;Limpio TI para indicar que envié datos.
		CJNE R0, #1, linea_1_o_2_serial
linea_0_serial:
		MOV A, linea_0
		MOV enviar_lineas_serial, #0
		JMP fin_linea_serial
linea_1_o_2_serial:
		CJNE R0, #2, linea_2_serial
linea_1_serial:
		MOV A, linea_1
		ADD A, #0x40
		MOV enviar_lineas_serial, #1
		JMP fin_linea_serial
linea_2_serial:
		MOV A, linea_2
		ADD A, #0x80
		MOV enviar_lineas_serial, #2

fin_linea_serial:
		mov SBUF, A
		ret

;;;
;;; serial_receive
;;;

serial_receive:
		jnb RI, no_hay_datos_serie ;Veo si hay un byte en el puerto o no
		MOV A, SBUF ;Leo el dato del buffer del puerto serie, pasándolo a R0
		CLR RI ; Limpio la indicación de que hay, porque lo proces
		MOV B, #3
		DIV AB ;Tengo en A la fila y en B la columna
		
		MOV R0, A ; En R0, la fila
		MOV A, B
		
		MOV R1, arranca
		CJNE R1, #arranca_humano, poner_circulo ;Si no arrancó el humano, juega con circulos
		
		mov R1, A ;En R1 la columna
		MOV R3, #1 ;Cruz
		JMP llamar_poner_ficha
poner_circulo:
		mov R1, A ;En R1 la columna
		MOV R3, #2 ;Circulo
llamar_poner_ficha:
		call poner_ficha
no_hay_datos_serie:
		ret

;;; Fin del módulo
END