TEST_SEG SEGMENT CODE

PUBLIC read_table
EXTRN DATA(board)
EXTRN DATA(retorno)
EXTRN CODE(comp_table_get_move_from_board)

RSEG TEST_SEG

read_table:
		mov R1, board
		mov R0, board + 1
		call comp_table_get_move_from_board
		mov retorno, A
		ret

END
