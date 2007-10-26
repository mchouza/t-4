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

;;; Sirve para dibujar una lìnea lógica
LOGICAL_LINE MACRO draw_line_func, trim_last_line ; (-2.5, n)
LOCAL phys_line_loop, short_wait
	
	;; Pongo en R2 la cantidad de líneas físicas
	mov R2, #5 ; + 0.5 px = (-2, n)

	phys_line_loop: ; (-2, n)

		;; Llamo al hsync
		call hsync ; + 9.5 px = (7.5, n)

		;; Espero hasta que esté en posición
		SHORT_SLEEP 1 ; + 0.5 px = (8, n)
		INT_SLEEP 17, R0 ; + 17 px = (25, n) 

		;; Llamo a la función que dibuja
		call draw_line_func ; + 47 px = (72, n)

		;; Espero
		INT_SLEEP 10 - trim_last_line, R0 ; + 10 px = (82, n)
		SHORT_SLEEP 1 ; + 0.5 px = (82.5, n)

		;; Retorno si es el último ciclo
		cjne R2, #1, short_wait	; + 1 px = (83.5, n)
		ret ; + 1 px = (84.5, n) = (-3.5, n + 1)
		
		;; Pequeña espera para ciclos normales
		short_wait: ; (83.5, n)
		SHORT_SLEEP 3 + 2 * trim_last_line ; + 1.5 px = (85, n)

	;; Vuelvo
	djnz R2, phys_line_loop ; + 1 px = (86, n) = (-2, n + 1)

	;; Nunca llega, ya que cuando R2 llega a 1, pasa de largo el 'cjne'
	;; y hace 'ret'

	ENDM
