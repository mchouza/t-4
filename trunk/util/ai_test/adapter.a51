TEST_SEG SEGMENT CODE

PUBLIC read_table, encode_board
EXTRN DATA(board)
EXTRN DATA(retorno)
EXTRN DATA(hi_ret, lo_ret)
EXTRN CODE(comp_table_get_move_from_board, get_encoded_board)

RSEG TEST_SEG

read_table:
		mov R1, board
		mov R0, board + 1
		call comp_table_get_move_from_board
		mov retorno, A
		ret

encode_board:
		;; Ya tengo en board_line el tablero
		call get_encoded_board
		mov hi_ret, R1
		mov lo_ret, R0
		ret	

END
