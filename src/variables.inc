;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Variables

;;; Segmento direccionable bit a bit
BSEG AT 0x20

;;; Representa la línea actual de los símbolos del tablero
board_line: ds 1

;;;	Representa la línea lógica donde estoy parado
logic_line: ds 1

;;; Representa el offset de lìnea física dentro de la línea lógica en la que
;;; estoy parado
phys_line_offset: ds 1

