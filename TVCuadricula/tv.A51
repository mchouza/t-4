blanco 		EQU 0xC0
negro 		EQU 0x40
gris 		EQU 0x80
sincro_val 	EQU 0x20


; Prueba a 33 MHz. Uso muchas instrucciones...


cseg


main:			call sincro
				call linea_alt
				nop
				nop
				call sincro
				call linea_alt
				nop
				nop
				call sincro
				call linea_alt
				nop
				nop
				call sincro
				call linea_alt
				nop
				nop
				call sincro
				call linea_alt
				nop
				nop
				call sincro
				call linea_alt
				nop
				nop
				call sincro
				call linea_alt
				nop
				nop
				call sincro
				call linea_alt
				nop
				nop
				call sincro
				call linea_alt2
				nop
				nop
				call sincro
				call linea_alt2
				nop
				nop
				call sincro
				call linea_alt2
				nop
				nop
				call sincro
				call linea_alt2
				nop
				nop
				call sincro
				call linea_alt2
				nop
				nop
				call sincro
				call linea_alt2
				nop
				nop
				call sincro
				call linea_alt2
				nop
				nop
				call sincro
				call linea_alt2
				sjmp main

linea_alt:

			REPT 6

				mov P2, #negro		; 24 ciclos a 33 MHz: 0.72 us
				mov P2, #gris		; 24 ciclos a 33 MHz: 0.72 us
				mov P2, #blanco	; 24 ciclos a 33 MHz: 0.72 us

			ENDM	; 35 x 1.44 us = 50.4 us + o - una línea

				ret

linea_alt2:

			REPT 6

				mov P2, #blanco		; 24 ciclos a 33 MHz: 0.72 us
				mov P2, #gris		; 24 ciclos a 33 MHz: 0.72 us
				mov P2, #negro	; 24 ciclos a 33 MHz: 0.72 us

			ENDM	; 35 x 1.44 us = 50.4 us + o - una línea

				ret

sincro:			mov P2, #negro	; 24 ciclos a 33 MHz: 0.72 us -> front porch
	

			REPT 2

				mov P2, #sincro_val	; 24 ciclos a 33 MHz: 0.72 us

			ENDM 	; 7 x 0.72 us = 5.04 us -> sync



			REPT 3	
				mov P2, #negro 	; 24 ciclos a 33 MHz: 0.72 us
			ENDM	; 7 x 0.72 us = 5.04 us -> back porch



				ret

end
			  