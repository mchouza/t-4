;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beir� y Mariano Chouza
;;;; Variables

;;; Segmento direccionable bit a bit
BSEG AT 0x20

;;; Representa la l�nea actual de los s�mbolos del tablero
board_line: ds 1

;;;	Representa la l�nea l�gica donde estoy parado
logic_line: ds 1

;;; Representa el offset de l�nea f�sica dentro de la l�nea l�gica en la que
;;; estoy parado
phys_line_offset: ds 1
