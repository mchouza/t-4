;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Macros

;;; Sirve para esperas cortas. Consume 1 byte por cada medio pixel de espera.
SHORT_SLEEP MACRO delay_in_half_pixels
		REPT delay_in_half_pixels
			nop ; + 0.5px
		ENDM 
		ENDM ; + (delay_in_half_pixels / 2) px

;;; Sirve para esperas intermedias, de más de 2 pixels.
;;; Destruye el registro indicado por tmp_reg
INT_SLEEP MACRO delay, tmp_reg
		mov tmp_reg, #delay - 1 ; + 0.5 px = 0.5 px
		nop ; + 0.5px = 1 px
		djnz tmp_reg, $ ; + (delay - 1) px = delay px
		ENDM

;;; Sirve para realizar un pulso de ecualización
;;; Las posiciones corresponden a llamarla al inicio de la línea
EQ_PULSE MACRO ; (n, -1)
		mov graphics_port, #sync_level ; + 1 px = (n, 0)
		SHORT_SLEEP 5 ; + 2.5 px = (n, 2.5)
		mov graphics_port, #black_level ; + 1 px = (n, 3.5)
		INT_SLEEP 39, R0 ; + 39 px = (n, 42.5)
		SHORT_SLEEP 1 ; + 0.5 px = (n, 43)
		ENDM

;;; Sirve para realizar un pulso de vsync
;;; Las posiciones corresponden a llamarla al inicio de la línea
VSYNC_PULSE MACRO ; (n, -1)
		mov graphics_port, #sync_level ; + 1 px = (n, 0)
		INT_SLEEP 39, R0 ; + 39 px = (n, 39)
		SHORT_SLEEP 1 ; + 0.5 px = (n, 39.5)
		mov graphics_port, #black_level ; + 1 px = (n, 40.5)
		SHORT_SLEEP 5 ; + 0.5 px = (n, 43)
		ENDM



