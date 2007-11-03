;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Variables

;;; Segmento direccionable bit a bit
DSEG AT 0x20

;;; Representa la línea actual de los símbolos del tablero
;;; Sigue el formato '00aabbcc', donde 'aa', 'bb' y 'cc' representan
;;; las columnas 2, 1 y 0, respectivamente.
;;; los dos bits que representan cada columna se interpretan de acuerdo a
;;; 00 -> Vacío
;;; 01 -> X
;;; 10 -> O
;;; 11 -> Reservado (no se usa)

board_line: ds 1


