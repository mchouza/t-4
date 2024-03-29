;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beir� y Mariano Chouza
;;;; Macros

;;; FIXME: Documentar mejor las macros

;;; Sirve para esperas cortas. Consume 1 byte por cada medio pixel de espera.
SHORT_SLEEP MACRO delay_in_half_pixels
		REPT delay_in_half_pixels
			nop ; + 0.5px
		ENDM 
		ENDM ; + (delay_in_half_pixels / 2) px

;;; Sirve para esperas intermedias, de m�s de 2 pixels.
;;; Destruye el registro indicado por tmp_reg
;;; Ocupa 2 + 1 + 2 = 5 bytes, por lo que conviene usarla para esperas de m�s
;;; de 2.5 pixels
INT_SLEEP MACRO delay, tmp_reg
		mov tmp_reg, #delay - 1 ; + 0.5 px = 0.5 px
		nop ; + 0.5px = 1 px
		djnz tmp_reg, $ ; + (delay - 1) px = delay px
		ENDM

;;; Sirve para poner una direcci�n de retorno en el stack de forma manual
;;; Destruye el contenido del acumulador
PUSH_ADDRESS MACRO address
		mov a, #LOW(address) ; + 0.5 px = 0.5 px
		push acc ; + 1 px = 1.5 px
		mov a, #HIGH(address) ; + 0.5 px = 2 px
		push acc ; + 1 px = 3 px
		ENDM

;;; Sirve para seleccionar un banco de registros
SEL_BANK MACRO num	
		USING	num
$IF	(num = 0)
		clr RS0
		clr RS1
$ELSEIF (num = 1)
		setb RS0
		clr RS1	
$ELSEIF (num = 2)
		clr RS0
		setb RS1
$ELSEIF (num = 3)
		setb RS0
		setb RS1
$ENDIF
		ENDM

;;; Sirve para realizar un pulso de ecualizaci�n
;;; Las posiciones corresponden a llamarla al inicio de la l�nea
EQ_PULSE MACRO ; (n, -1)
		mov graphics_port, #sync_level ; + 1 px = (n, 0)
		SHORT_SLEEP 5 ; + 2.5 px = (n, 2.5)
		mov graphics_port, #black_level ; + 1 px = (n, 3.5)
		INT_SLEEP 39, R0 ; + 39 px = (n, 42.5)
		SHORT_SLEEP 1 ; + 0.5 px = (n, 43)
		ENDM

;;; Sirve para realizar un pulso de vsync
;;; Las posiciones corresponden a llamarla al inicio de la l�nea
VSYNC_PULSE MACRO ; (n, -1)
		mov graphics_port, #sync_level ; + 1 px = (n, 0)
		INT_SLEEP 39, R0 ; + 39 px = (n, 39)
		SHORT_SLEEP 1 ; + 0.5 px = (n, 39.5)
		mov graphics_port, #black_level ; + 1 px = (n, 40.5)
		SHORT_SLEEP 5 ; + 0.5 px = (n, 43)
		ENDM

;;; Pone el s�mbolo que corresponda en una posici�n del teclado
;;; Utilizo E para indicar vac�o
PUT_SYMBOL MACRO row, col, sym
		anl linea_0 + row, #(NOT(0x3) SHL (2 * col)) ; Ponemos 0s en la posici�n
IF (sym = "E")
		orl linea_0 + row, #(0x0 SHL (2 * col))
ELSEIF (sym = "X")
		orl linea_0 + row, #(0x1 SHL (2 * col))
ELSE
		orl linea_0 + row, #(0x2 SHL (2 * col))
ENDIF
		ENDM

;;; Pone el s�mbolo indicado en R3
PUT_SYMBOL_VARM MACRO row, col
		mov R0, #row
		mov R1, #col
		call put_symbol_var ; Toma el tipo de s�mbolo desde R3
		ENDM 

;;; Sirve para dibujar una l�nea l�gica
LOGICAL_LINE MACRO draw_line_func, trim_last_line, line_length_adjust ; (-2.5, n)
LOCAL phys_line_loop, short_wait
	
	;; Pongo en R2 la cantidad de l�neas f�sicas
	mov R2, #5 ; + 0.5 px = (-2, n)

	phys_line_loop: ; (-2, n)

		;; Llamo al hsync
		call hsync ; + 9.5 px = (7.5, n)

		;; Espero hasta que est� en posici�n
		SHORT_SLEEP 1 ; + 0.5 px = (8, n)
		INT_SLEEP 3, R0 ; + 3 px = (11, n) 

		;; Llamo a la funci�n que dibuja
		call draw_line_func ; + 58 px = (69, n)

		;; Espero
		INT_SLEEP 13 - trim_last_line - line_length_adjust, R0 ; + 13 px = (82, n)
		SHORT_SLEEP 1 ; + 0.5 px = (82.5, n)

		;; Retorno si es el �ltimo ciclo
		cjne R2, #1, short_wait	; + 1 px = (83.5, n)
		ret ; + 1 px = (84.5, n) = (-3.5, n + 1)
		
		;; Peque�a espera para ciclos normales
		short_wait: ; (83.5, n)
		SHORT_SLEEP 3 + 2 * trim_last_line ; + 1.5 px = (85, n)

	;; Vuelvo
	djnz R2, phys_line_loop ; + 1 px = (86, n) = (-2, n + 1)

	;; Nunca llega, ya que cuando R2 llega a 1, pasa de largo el 'cjne'
	;; y hace 'ret'

	ENDM

;;; L�nea f�sica
LS_n MACRO SLS_X, SLS_O, SLS_E, SLS_X_1st_COL, SLS_O_1st_COL SLS_E_1st_COL ; (-14)
LOCAL LS_n_2, LS_n_2_E, LS_n_2_X, LS_n_2_O, LS_n_1, LS_n_1_E, LS_n_1_X, LS_n_1_O, LS_n_0, LS_n_0_E, LS_n_0_X, LS_n_0_O
	
	LS_n_2: ; (-14)		
		jb board_line.4, LS_n_2_X ; + 1 px = (-13)
		jb board_line.5, LS_n_2_O ; + 1 px = (-12)

	LS_n_2_E: ; (-12)
		PUSH_ADDRESS SLS_E ; + 3 px = (-9)
		jmp LS_n_1 ; + 1 px = (-8)

	LS_n_2_X: ; (-13)
		SHORT_SLEEP 2 ; + 1 px = (-12)
		PUSH_ADDRESS SLS_X ; + 3 px = (-9)
		jmp LS_n_1 ; + 1 px = (-8)

	LS_n_2_O: ; (-12)
		PUSH_ADDRESS SLS_O ; + 3 px = (-9)
		jmp LS_n_1 ; + 1 px = (-8)

	LS_n_1: ; (-8)
		jb board_line.2, LS_n_1_X ; + 1 px = (-7)
		jb board_line.3, LS_n_1_O ; + 1 px = (-6)

	LS_n_1_E: ; (-6)
		PUSH_ADDRESS SLS_E ; + 3 px = (-3)
		jmp LS_n_0 ; + 1 px = (-2)

	LS_n_1_X: ; (-7)
		SHORT_SLEEP 2 ; + 1 px = (-6)
		PUSH_ADDRESS SLS_X ; + 3 px = (-3)
		jmp LS_n_0 ; + 1 px = (-2)

	LS_n_1_O: ; (-6)
		PUSH_ADDRESS SLS_O ; + 3 px = (-3)
		jmp LS_n_0 ; + 1 px = (-2)

	LS_n_0: ; (-2)
		jb board_line.0, LS_n_0_X ; + 1 px = (-1)
		jb board_line.1, LS_n_0_O ; + 1 px = (0)

	LS_n_0_E: ; (0)
		jmp SLS_E_1st_COL ; + 1 px = (1)

	LS_n_0_X: ; (-1)
		SHORT_SLEEP 2 ; + 1 px = (0)
		jmp SLS_X_1st_COL ; + 1 px = (1)

	LS_n_0_O: ; (0)
		jmp SLS_O_1st_COL ; + 1 px = (1)
	
		;; No hay 'ret', el �ltimo s�mbolo ya se encarga de eso
		ENDM

	//Forma antigua de manejar el teclado. Ahora se emplea poner_ficha y el c�digo de keyboard.a51
  /*
;Lee una tecla del teclado. Recibe fila y columna, de 0 a 2
leer_tecla_puerto MACRO fila, columna, puerto
LOCAL no_vacia, suelta, sig, poner_circulo, ficha_puesta
		JB puerto_teclado_&puerto, suelta ;Veo si est� suelta la tecla
		;Analizo si ese lugar del tablero ya est� ocupado
		MOV A, linea_&fila ;Obtengo la primera fila
$IF (columna = 0)
			NOP
			NOP
			NOP
			NOP
$ELSEIF (columna = 1)
			RR A
			RR A
			NOP
			NOP
$ELSE
			RR A
			RR A
			RR A
			RR A
$ENDIF

		MOV B, #4
		DIV AB ;Tengo en B los �ltimos dos bits de fila
		MOV A,B
		CJNE A, #0, no_vacia ;Si no est� vac�a salgo
		;Veo si pone cruz (arranca_humano) o circulo (arranca_maquina)
		MOV R0, arranca
		CJNE R0, #arranca_humano, poner_circulo
		PUT_SYMBOL fila, columna, "X"  ;Si arranc� el humano, juega con cruces
		JMP ficha_puesta
	poner_circulo:
		PUT_SYMBOL fila, columna, "O"  ;Si arranc� la m�quina, el humano juega con c�rculos
		JMP ficha_puesta
	ficha_puesta:
		MOV A, #melodia_humano
		CALL sound_start_melody ; Reproduzco la melodia
		MOV turno, #turno_maquina ;Turno=maquina
		MOV timer_jugada_maquina, #100 ;Para que espere 2 segundos (100 frames) antes de jugar la m�quina
		MOV enviar_lineas_serial, #3 ;Indico que hay que enviar las 3 lineas del tablero a la PC
		JMP fin
	no_vacia:	;Agrego el tiempo del put_symbol y del mov
		SHORT_SLEEP 1
		JMP sig
	suelta:	;Agrego todo el tiempo anterior
		JMP sig
	sig:	
		ENDM
  
leer_tecla MACRO fila, columna
		leer_tecla_puerto fila, columna, 2-fila ;Adapta la fila al puerto que corresponde (est�n invertidos en orden)
		ENDM
*/