;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Módulo serial (SERIAL)
;;;; Se encarga de enviar y recibir datos por el puerto serie a la PC

$INCLUDE(macros.inc)		; Macros de propósito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general

NAME SERIAL

;;; Segmento propio de este módulo
SERIAL_SEG SEGMENT CODE

;;; Importa
$INCLUDE(variables.inc)		; Variables compartidas a nivel global

;;; Exporta solo la función de inicialización y la de reproduccion
PUBLIC serial_init, serial_send, serial_receive

;;; Comienza el segmento SOUND_SEG
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

		setb TI
		ret

;;;
;;; serial_send
;;;

serial_send:
	   	jnb TI, $ ;Cuando el micro termina la transmisión, avisará seteando TI
		clr TI
		mov A, linea_1
		mov SBUF, A
		ret

;;;
;;; serial_receive
;;;

serial_receive:
		
		ret

;;; Fin del módulo
END