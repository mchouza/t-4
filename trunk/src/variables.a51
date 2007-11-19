;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beir� y Mariano Chouza
;;;; M�dulo de variables (VARS)
;;;; Contiene las distintas variables utilizadas

$INCLUDE(macros.inc)		; Macros de prop�sito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general

NAME VARS

;;;
;;; Variables de byte (directas)
;;; Las uso superpuestas con las variable direccionables de a bit ya que, al
;;; menos pro ahora, no usamos variables de bit
;;;

DSEG AT 0x20

;;; Representa la l�nea actual de los s�mbolos del tablero
;;; Sigue el formato '00aabbcc', donde 'aa', 'bb' y 'cc' representan
;;; las columnas 2, 1 y 0, respectivamente.
;;; los dos bits que representan cada columna se interpretan de acuerdo a
;;; 00 -> Vac�o
;;; 01 -> X
;;; 10 -> O
;;; 11 -> Reservado (no se usa)
PUBLIC board_line
board_line: ds 1

;;; N�mero de la l�nea actual que se est� dibujando
PUBLIC line_num
line_num: ds 1

;;; Contenido de la l�nea 0 (sigue el mismo formato que board_line)
PUBLIC linea_0
linea_0: ds 1

;;; Contenido de la l�nea 1 (sigue el mismo formato que board_line)
PUBLIC linea_1
linea_1: ds 1

;;; Contenido de la l�nea 2 (sigue el mismo formato que board_line)
PUBLIC linea_2
linea_2: ds 1

;;; Turno de jugada: 1 -> Humano, 0 -> M�quina
PUBLIC turno
turno: ds 1

;;; Puntero al pr�ximo byte de la tabla a leer
PUBLIC cmt_ptr
cmt_ptr: ds 2

;;; Offset de bit a leer
PUBLIC cmt_bit_offset
cmt_bit_offset: ds 1

;;; Byte que act�a de buffer
PUBLIC cmt_byte_buffer
cmt_byte_buffer: ds 1

;;; Buffer de 3 bytes
PUBLIC buffer
buffer: ds 3

;;; Indica qu� melod�a se est� reproduciendo actualmente
;;;	valores_posibles: melodia_humano, melodia_maquina, melodia_final
PUBLIC estado_melodia
estado_melodia: ds 1

;;; Es un iterador para avanzar por la partitura (lista de notas a reproducir)
PUBLIC nota_actual
nota_actual: ds 1

;;; Es un timer que se inicializa con la duraci�n de la nota (en frames), de manera que al llegar a cero la nota se acabe
PUBLIC timer_nota_actual
timer_nota_actual: ds 1

;;; Es un timer que se inicializa con el tiempo a esperar despu�s de la jugada del humano para responder
PUBLIC timer_jugada_maquina
timer_jugada_maquina: ds 1

;;;
;;; Variables de bit 
;;;

BSEG	AT	0x00
	
;;; NINGUNA POR AHORA

;;;
;;; Variables de byte (indirectas)
;;;

ISEG AT	0x80

;;; NINGUNA POR AHORA

PUBLIC	stack
stack:			DS	1

;;; Fin del m�dulo
END
