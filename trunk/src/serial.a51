;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beir� y Mariano Chouza
;;;; M�dulo serial (SERIAL)
;;;; Se encarga de enviar y recibir datos por el puerto serie a la PC

$INCLUDE(macros.inc)		; Macros de prop�sito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general
$INCLUDE(util.inc)	; Constantes de utilidad general

NAME SERIAL

;;; Segmento propio de este m�dulo
SERIAL_SEG SEGMENT CODE

;;; Importa
$INCLUDE(variables.inc)		; Variables compartidas a nivel global

;;; Exporta solo la funci�n de inicializaci�n y la de reproduccion
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

		;Habilito la recepci�n de datos por el puerto serie.
		setb REN

		;Todav�a no hay que enviar nada del tablero a la PC.
		MOV enviar_lineas_serial, #0

		ret

;;;
;;; serial_send
;;;

serial_send:
	   	MOV R0, enviar_lineas_serial
		CJNE R0, #0, hay_datos_serial
no_hay_datos_serial:
		INT_SLEEP 74, R0
		ret
hay_datos_serial:
		jnb TI, $ ;Cuando el micro termina la transmisi�n, avisar� seteando TI
		clr TI ;Limpio TI para indicar que envi� datos.
		CJNE R0, #1, linea_1_o_2_serial
linea_0_serial:
		MOV A, linea_0
		MOV enviar_lineas_serial, #0
		INT_SLEEP 68, R0 ;Ya hizo 7 instr m�s (contando el MOV a SBUF)
		JMP fin_linea_serial
linea_1_o_2_serial:
		CJNE R0, #2, linea_2_serial
linea_1_serial:
		MOV A, linea_1
		ADD A, #0x40 ;Pongo en los primeros dos bits del byte a enviar que es la l�nea 1
		MOV enviar_lineas_serial, #1
		INT_SLEEP 66, R0 ;Ya hizo 9 instr m�s (contando el MOV a SBUF)
		JMP fin_linea_serial
linea_2_serial:
		MOV A, linea_2
		ADD A, #0x80 ;Pongo en los primeros dos bits del byte a enviar que es la l�nea 2
		MOV enviar_lineas_serial, #2
		INT_SLEEP 67, R0 ;Ya hizo 8 instr m�s (contando el MOV a SBUF)

fin_linea_serial:
		mov SBUF, A
		ret

;;;
;;; serial_receive
;;;

serial_receive:
		jnb RI, no_hay_datos_serie ; Veo si hay un byte en el puerto o no

		;; Se fija si tiene qu ejugar
		MOV A, turno
		CJNE A, #turno_humano, no_tiene_que_jugar

		MOV A, SBUF ; Leo el dato del buffer del puerto serie, pas�ndolo a R0
		CLR RI ; Limpio la indicaci�n de que hay, porque lo proces
		MOV B, #3
		DIV AB ; Tengo en A la fila y en B la columna
		
		MOV R0, A ; En R0, la fila
		MOV R1, B ; En R1 la columna
		call poner_ficha ; Pone la ficha
		
		ret
		
	no_hay_datos_serie:
		INT_SLEEP 75, R0
		ret
				
	no_tiene_que_jugar:
		INT_SLEEP 73, R0
		ret

;;; Fin del m�dulo
END