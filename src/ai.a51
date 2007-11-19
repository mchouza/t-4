;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beir� y Mariano Chouza
;;;; M�dulo de AI (AI)
;;;; Contiene la tabla comprimida y los procedimeintos para decidir y ejecutar
;;;; la jugada

$INCLUDE(macros.inc)		; Macros de prop�sito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general
$INCLUDE(variables.inc)		; Variables globales

NAME AI

;;; Segmento propio de este m�dulo
AI_SEG SEGMENT CODE

;;; Exporto solo la funci�n que juega por la m�quina
PUBLIC ai_play

;;; Empiezo el segmento
RSEG AI_SEG

;;; Tabla comprimida de respuestas para cada posible tablero
comp_move_table:
db 0xf2, 0xe8, 0xa2, 0x96, 0x24, 0x66, 0x48, 0xa7, 0x10, 0xed
db 0x27, 0xd8, 0x91, 0x29, 0xfa, 0xc9, 0x29, 0x35, 0xec, 0x3e
db 0xba, 0x52, 0x09, 0x0e, 0xd3, 0x07, 0xb1, 0x98, 0xe8, 0xfc
db 0x98, 0x11, 0x44, 0x62, 0x3a, 0xc0, 0x31, 0xc5, 0xa6, 0x3f
db 0x17, 0xd7, 0x66, 0xb7, 0x66, 0x67, 0xf1, 0x35, 0xf1, 0x06
db 0xbd, 0x87, 0xd7, 0x64, 0xc0, 0x0c, 0xc3, 0xe6, 0xec, 0x99
db 0xbb, 0x23, 0x2c, 0x18, 0x0c, 0xd9, 0xe6, 0x01, 0x60, 0xd7
db 0xa0, 0x00, 0x5a, 0xcc, 0xee, 0x46, 0x8e, 0x8f, 0x8a, 0x29
db 0x44, 0x48, 0x95, 0x80, 0x4c, 0xa4, 0x9f, 0x2f, 0x6b, 0x66
db 0xc9, 0x93, 0x33, 0x39, 0xc8, 0xd7, 0x90, 0x22, 0x3a, 0xc0
db 0x23, 0x16, 0x91, 0xf1, 0x00, 0x50, 0x00, 0xa1, 0x47, 0x66
db 0x67, 0x79, 0x0c, 0xc7, 0x67, 0xf2, 0x60, 0x60, 0x64, 0xfa
db 0xec, 0x98, 0x19, 0x32, 0x32, 0xcb, 0x01, 0x9b, 0x3c, 0xc3
db 0xb4, 0xbf, 0x98, 0xc8, 0x60, 0x65, 0xf3, 0x76, 0x6c, 0xcb
db 0x5d, 0x87, 0xd7, 0x64, 0xc8, 0x19, 0x82, 0xd7, 0x61, 0xf5
db 0xd2, 0x90, 0x44, 0x3e, 0x6e, 0xb4, 0xbb, 0x49, 0xcf, 0x33
db 0x36, 0x59, 0x80, 0x58, 0x35, 0xe8, 0x00, 0x1f, 0x5d, 0x6b
db 0x76, 0x91, 0xf1, 0x32, 0x60, 0xc8, 0x3b, 0x4c, 0x1e, 0xc6
db 0x63, 0x36, 0x79, 0x64, 0xc9, 0x81, 0x99, 0xaf, 0x61, 0xf5
db 0xd9, 0xb3, 0x06, 0x00, 0x0b, 0x06, 0xbd, 0x00, 0x01, 0xaf
db 0x61, 0xf5, 0xd9, 0x33, 0x06, 0x60, 0x00, 0x00, 0x00, 0x25
db 0x64, 0xfb, 0x1a, 0x25, 0x3f, 0x52, 0xc0, 0x88, 0xd1, 0xd6
db 0x01, 0x3d, 0xa6, 0x5e, 0x93, 0x29, 0x4a, 0x52, 0x92, 0x66
db 0x4c, 0x98, 0x31, 0x02, 0xc7, 0x58, 0x05, 0x76, 0x98, 0x3c
db 0x40, 0x16, 0x00, 0x34, 0x74, 0x3b, 0x4b, 0xf6, 0x28, 0x51
db 0x83, 0x26, 0x06, 0x06, 0x4f, 0x17, 0x64, 0x8b, 0x59, 0x11
db 0xc1, 0x12, 0x2f, 0x10, 0xec, 0x8c, 0xbd, 0x0d, 0x1d, 0x8f
db 0xa7, 0x64, 0x18, 0xb1, 0xc4, 0x31, 0xd7, 0x62, 0xc4, 0x18
db 0x81, 0x62, 0x56, 0x01, 0x1e, 0xd2, 0x7c, 0x40, 0x16, 0x00
db 0x34, 0x74, 0x2d, 0xa5, 0xdc, 0x8d, 0x1d, 0x3e, 0x52, 0xc0
db 0xc8, 0x01, 0x60, 0x03, 0x47, 0x40, 0x00, 0x00, 0x00, 0x16
db 0x2d, 0x60, 0x15, 0xda, 0x60, 0xf9, 0x35, 0x91, 0x96, 0x0c
db 0x03, 0x21, 0x81, 0x97, 0x8b, 0xb2, 0x44, 0x68, 0xeb, 0x00
db 0xc1, 0xda, 0x65, 0xe9, 0x96, 0xad, 0x93, 0x03, 0x26, 0x46
db 0x59, 0x60, 0x35, 0xf0, 0x07, 0xd4, 0xa5, 0x69, 0x49, 0x3e
db 0x24, 0x59, 0x44, 0x3a, 0xcc, 0xbd, 0x09, 0x1d, 0x3e, 0x99
db 0x32, 0x09, 0x4d, 0x84, 0xca, 0x52, 0x90, 0x48, 0x76, 0x97
db 0xec, 0x50, 0xa3, 0x2c, 0x99, 0x30, 0x22, 0x2c, 0x75, 0x80
db 0x57, 0x69, 0x97, 0xa7, 0xd7, 0x5a, 0xd4, 0x14, 0xa3, 0x26
db 0x0c, 0x81, 0x14, 0x62, 0x11, 0x8b, 0xa2, 0x88, 0x22, 0x1e
db 0x9d, 0x90, 0xec, 0x8c, 0xbd, 0x07, 0xa0, 0x08, 0x02, 0x08
db 0x00, 0x00, 0xd7, 0xb0, 0xfa, 0xe8, 0xb2, 0x04, 0x85, 0xe0
db 0x64, 0x94, 0xa5, 0x89, 0x96, 0x38, 0x09, 0x4c, 0x80, 0x58
db 0x35, 0xe8, 0x00, 0x1f, 0x26, 0x04, 0x51, 0x74, 0x48, 0xe3
db 0x91, 0xaf, 0x10, 0xc5, 0xa5, 0xfb, 0x18, 0x8c, 0x58, 0xfd
db 0x76, 0x2c, 0x4d, 0x7b, 0x0f, 0xae, 0x83, 0x20, 0x62, 0x01
db 0x60, 0xd7, 0xa0, 0x00, 0x2d, 0x76, 0x1f, 0x5d, 0x93, 0x00
db 0x20, 0x00, 0x00, 0x00, 0x03, 0x2c, 0x9d, 0x69, 0x64, 0x89
db 0x18, 0xe4, 0x4a, 0x64, 0x25, 0x64, 0xdc, 0x8d, 0x1d, 0x33
db 0x29, 0x4a, 0x4d, 0x7b, 0x0f, 0xae, 0x83, 0x20, 0x48, 0x45
db 0x12, 0x3e, 0xc4, 0x47, 0x47, 0xeb, 0xa2, 0x88, 0xa1, 0x40
db 0x05, 0x50, 0x52, 0x9f, 0x27, 0x41, 0x93, 0xa0, 0x32, 0xc8
db 0xd7, 0xc0, 0x0b, 0x5d, 0x87, 0xd7, 0x64, 0xc8, 0x10, 0x0f
db 0xae, 0xb5, 0xb2, 0x64, 0x65, 0x96, 0x02, 0x08, 0x00, 0x2c
db 0x1a, 0xf4, 0x00, 0x00, 0xb0, 0x6b, 0xd0, 0x00, 0x16, 0xbb
db 0x0f, 0xae, 0x94, 0x82, 0x40, 0x00, 0x00, 0x00, 0x35, 0xec
db 0x3e, 0xbb, 0x03, 0x20, 0x60, 0x0d, 0xc9, 0x81, 0x81, 0x93
db 0xb4, 0xc1, 0xf2, 0x32, 0x60, 0xc8, 0x02, 0xc1, 0xaf, 0x40
db 0x00, 0x00, 0x00, 0x00, 0x01, 0x60, 0xd7, 0xa0, 0x00, 0x00
db 0x00, 0x00, 0x0d, 0x66, 0x4f, 0xcc, 0x66, 0x33, 0x47, 0x2c
db 0x92, 0x94, 0x45, 0x8c, 0xd6, 0x01, 0x3d, 0xa4, 0xf9, 0x4c
db 0xa5, 0x2c, 0x92, 0xcc, 0x9c, 0xe4, 0x94, 0xc8, 0x1a, 0x3a
db 0xc0, 0x33, 0xd6, 0x95, 0xf2, 0x00, 0x58, 0x00, 0xd1, 0xd0
db 0xed, 0x2b, 0x3c, 0x86, 0x63, 0x36, 0x7f, 0x54, 0x32, 0x78
db 0xba, 0xd9, 0xa2, 0xc8, 0x8e, 0x51, 0x33, 0x78, 0x87, 0x64
db 0x5e, 0x79, 0x8c, 0x86, 0x6c, 0xb3, 0xcd, 0xd8, 0xb3, 0x31
db 0x7b, 0x0c, 0x71, 0x76, 0x2c, 0x41, 0x88, 0x16, 0x33, 0x58
db 0x04, 0x7b, 0x49, 0xf1, 0x00, 0x58, 0x00, 0xd1, 0xd0, 0xb6
db 0x64, 0xe5, 0x90, 0xcc, 0x64, 0xcf, 0xca, 0x52, 0xc8, 0x01
db 0x60, 0x03, 0x47, 0x40, 0x00, 0x00, 0x00, 0x1a, 0x3a, 0xc0
db 0x33, 0xd6, 0x95, 0xf2, 0x5b, 0x22, 0xf2, 0xcc, 0x64, 0x32
db 0x65, 0x9e, 0x6e, 0x8b, 0x31, 0xa3, 0xac, 0x03, 0x2e, 0xd3
db 0x3f, 0x9b, 0x2b, 0x75, 0xb2, 0x64, 0xc8, 0xcf, 0x2c, 0x8c
db 0xd9, 0xe6, 0x13, 0x29, 0x4b, 0x34, 0xa4, 0x9c, 0xe4, 0xc9
db 0x32, 0x1d, 0xa4, 0xe7, 0x98, 0x91, 0x9b, 0x3c, 0xb3, 0x4a
db 0x59, 0x92, 0x99, 0x09, 0x94, 0xa5, 0x20, 0x90, 0xed, 0x2b
db 0x3c, 0x86, 0x8c, 0xd9, 0xee, 0x4a, 0x19, 0x0d, 0x16, 0xb0
db 0x0c, 0xf5, 0xa5, 0x7c, 0x9f, 0x54, 0x2d, 0xda, 0x57, 0xcc
db 0xd2, 0x81, 0x17, 0xb0, 0x8c, 0x5d, 0x14, 0x41, 0x10, 0xcf
db 0x35, 0xb2, 0x66, 0xec, 0x8c, 0xb3, 0xcc, 0xcd, 0xf3, 0x00
db 0x80, 0x20, 0x80, 0x00, 0x06, 0x8c, 0x96, 0x01, 0x1c, 0x9a
db 0x47, 0xc4, 0x01, 0x60, 0x03, 0x47, 0x43, 0xb4, 0xbb, 0xc8
db 0x68, 0xe9, 0xdc, 0x9d, 0x2c, 0x80, 0x16, 0x00, 0x34, 0x74
db 0x00, 0x00, 0x00, 0x01, 0xa3, 0xac, 0x02, 0xbb, 0x4a, 0xcb
db 0x26, 0x4c, 0x8c, 0xbd, 0x8c, 0x86, 0x4c, 0xbe, 0xb2, 0x64
db 0x88, 0xc8, 0x76, 0x40, 0x19, 0x76, 0x46, 0x5e, 0x99, 0x62
db 0xc5, 0x93, 0x26, 0x2c, 0x8c, 0x72, 0xc4, 0xc9, 0x96, 0x20
db 0x01, 0x60, 0x03, 0x47, 0x40, 0x00, 0x00, 0x00, 0x1a, 0x32
db 0x58, 0x04, 0xe4, 0xd2, 0x72, 0xc8, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x05, 0x80, 0x0d, 0x1d, 0x03, 0x21, 0x93
db 0x20, 0x0c, 0xb2, 0x64, 0x65, 0xe2, 0x00, 0xb0, 0x01, 0xa3
db 0xa1, 0x93, 0x23, 0x2c, 0xb2, 0x19, 0x0c, 0x99, 0x65, 0x93
db 0x26, 0x4c, 0x99, 0x34, 0xbf, 0x63, 0x47, 0x47, 0x2c, 0x99
db 0x25, 0x11, 0x90, 0xeb, 0x00, 0x9c, 0x99, 0x19, 0x7a, 0x4c
db 0xa5, 0x29, 0x4a, 0x49, 0x99, 0x32, 0x4c, 0x81, 0xa3, 0xac
db 0x02, 0xb2, 0x69, 0x59, 0x64, 0x00, 0xb0, 0x01, 0xa3, 0xa1
db 0xda, 0x57, 0xb1, 0x42, 0x8d, 0xc9, 0x43, 0x24, 0x62, 0x8b
db 0x24, 0x51, 0x64, 0x46, 0x31, 0x22, 0xca, 0x21, 0xd9, 0x19
db 0x7a, 0x19, 0x0e, 0xcb, 0xd3, 0x26, 0x41, 0x04, 0x01, 0x00
db 0x82, 0x00, 0x80, 0x7d, 0x4a, 0x56, 0xe8, 0x91, 0xf2, 0x4a
db 0x64, 0x35, 0x24, 0xf9, 0x12, 0x25, 0x8c, 0xca, 0x52, 0x93
db 0x5e, 0xc3, 0xeb, 0xa0, 0xc8, 0x12, 0x1a, 0xd2, 0xbe, 0x42
db 0x23, 0xa3, 0xf5, 0x42, 0x23, 0x46, 0x2c, 0x40, 0x31, 0xed
db 0x2b, 0xe2, 0xfa, 0xa1, 0x93, 0xa0, 0x3e, 0x46, 0x94, 0x0b
db 0x7b, 0x0f, 0xae, 0x8a, 0x20, 0x80, 0x5d, 0xba, 0xd6, 0xec
db 0x8c, 0xbe, 0x24, 0x10, 0x00, 0x58, 0x35, 0xe8, 0x00, 0x1d
db 0xa4, 0x7c, 0x88, 0x8c, 0x91, 0x99, 0x4a, 0x52, 0x24, 0x4a
db 0xc0, 0x26, 0x52, 0x4c, 0xcb, 0xeb, 0xa0, 0xc9, 0xd0, 0x19
db 0x64, 0x4a, 0x64, 0x08, 0x88, 0xa2, 0x01, 0x1e, 0xd2, 0xbc
db 0x40, 0x14, 0x00, 0x28, 0x51, 0xd0, 0x1f, 0x20, 0x1d, 0x0f
db 0xaa, 0x19, 0x2e, 0xdd, 0x6b, 0x64, 0xc8, 0x8e, 0x59, 0x10
db 0x40, 0x1d, 0xa5, 0xdd, 0x8c, 0x86, 0x4c, 0xa0, 0x10, 0x40
db 0xb7, 0xb0, 0xfa, 0xe8, 0x32, 0x04, 0x01, 0xaf, 0x61, 0xba
db 0xe9, 0x44, 0x12, 0x1b, 0x69, 0x4a, 0xdd, 0xa4, 0xf9, 0x35
db 0x32, 0x01, 0x60, 0xd7, 0xa0, 0x00, 0x7d, 0x50, 0xc9, 0xad
db 0x2b, 0xe4, 0x69, 0x41, 0xad, 0x2b, 0xe4, 0x34, 0x76, 0x5b
db 0x92, 0x86, 0x46, 0x94, 0x1f, 0x54, 0x32, 0x00, 0x02, 0xc1
db 0xaf, 0x40, 0x00, 0x5a, 0xec, 0x3e, 0xbb, 0x26, 0x40, 0x80
db 0x00, 0x00, 0x00, 0x05, 0xbd, 0x87, 0xd7, 0x66, 0x90, 0x66
db 0x13, 0x9b, 0xa5, 0x29, 0x49, 0x94, 0xc9, 0x29, 0xcc, 0x02
db 0xc1, 0xaf, 0x40, 0x00, 0xfa, 0xe8, 0xad, 0xd1, 0x33, 0xf1
db 0x22, 0x8e, 0x41, 0xd6, 0x63, 0xec, 0x68, 0xec, 0x7e, 0xb1
db 0x62, 0xc4, 0xd7, 0xb0, 0xfa, 0xec, 0xd8, 0x83, 0x20, 0x0b
db 0x06, 0xbd, 0x00, 0x01, 0xaf, 0x61, 0xba, 0xec, 0x90, 0x06
db 0x60, 0x00, 0x00, 0x00, 0x26, 0x5d, 0x14, 0xb2, 0x44, 0xca
db 0x64, 0x8a, 0x39, 0x84, 0xac, 0x99, 0x91, 0xa2, 0x53, 0xf5
db 0x29, 0x49, 0x6b, 0xb0, 0xfa, 0xec, 0xd2, 0x09, 0x0e, 0xb2
db 0x3e, 0xc6, 0x8e, 0x8f, 0xd4, 0x51, 0x44, 0x50, 0xa0, 0x02
db 0xa8, 0x29, 0x4b, 0xc9, 0x9b, 0x35, 0xbb, 0x33, 0x3f, 0x99
db 0x93, 0xe4, 0x0d, 0x5d, 0x86, 0xeb, 0xb2, 0x40, 0x19, 0x87
db 0xd6, 0x6c, 0x90, 0x6b, 0x23, 0x28, 0x0c, 0xd9, 0xe6, 0x01
db 0x60, 0xd7, 0xa0, 0x00, 0x05, 0x83, 0x5e, 0x80, 0x00, 0xd7
db 0xb0, 0xfa, 0xe9, 0x48, 0x33, 0x00, 0x00, 0x00, 0x00, 0xd7
db 0xb0, 0xfa, 0xec, 0xd1, 0x06, 0x41, 0xf5, 0x92, 0xd6, 0xcd
db 0x99, 0x9f, 0xcc, 0xcd, 0x96, 0x40, 0x16, 0x0d, 0x7a, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x0b, 0x06, 0xbd, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x7d, 0x75, 0xa2, 0x94, 0x93, 0x32, 0x45, 0xe2
db 0x1d, 0x25, 0xfa, 0x12, 0x25, 0x3e, 0x9d, 0x21, 0x6b, 0xb0
db 0xfa, 0xe9, 0x48, 0x24, 0x3a, 0xcb, 0xf6, 0x28, 0x51, 0xf5
db 0xd1, 0x44, 0x68, 0xeb, 0x00, 0xae, 0xc4, 0xc7, 0xd3, 0xea
db 0xd6, 0xb5, 0x05, 0x28, 0xc9, 0xf2, 0x06, 0xbd, 0x86, 0xeb
db 0xb2, 0x40, 0x11, 0x0f, 0x4e, 0xc8, 0x76, 0x99, 0x40, 0x1e
db 0x80, 0x2c, 0x1a, 0xf4, 0x00, 0x09, 0x59, 0x73, 0x23, 0x44
db 0xa6, 0x31, 0x74, 0x51, 0x12, 0x25, 0x20, 0x13, 0xd2, 0x4f
db 0xa5, 0xda, 0xd6, 0x97, 0x69, 0x33, 0x26, 0xbc, 0x81, 0xa3
db 0xac, 0x02, 0xa2, 0x89, 0x1f, 0x10, 0x05, 0x00, 0x0a, 0x14
db 0x5a, 0xcb, 0xf6, 0x28, 0x51, 0xf2, 0x76, 0x4c, 0x9b, 0xae
db 0xc9, 0x06, 0xb2, 0x32, 0x80, 0x8b, 0xc4, 0x3b, 0x4c, 0xa0
db 0x1a, 0x08, 0x7a, 0x76, 0x41, 0xab, 0xb0, 0xdd, 0x76, 0x48
db 0x03, 0x20, 0x6b, 0xd8, 0x7d, 0x74, 0xa2, 0x08, 0x87, 0xa7
db 0x58, 0xe9, 0x27, 0xd0, 0x7a, 0x00, 0xb0, 0x6b, 0xd0, 0x00
db 0x3e, 0xad, 0x6b, 0x50, 0x52, 0x88, 0xb2, 0xc8, 0x3a, 0xcb
db 0xf4, 0x28, 0x51, 0xe9, 0x93, 0x20, 0xd7, 0xb0, 0x52, 0x80
db 0x19, 0x00, 0x58, 0x35, 0xe8, 0x00, 0x03, 0xd0, 0x7a, 0x76
db 0x40, 0x00, 0x00, 0x00, 0x00, 0x02, 0xc1, 0xaf, 0x40, 0x00
db 0x6b, 0x2b, 0x0c, 0xb5, 0x93, 0x24, 0x82, 0x40, 0x00, 0x00
db 0x00, 0x32, 0x65, 0x90, 0x65, 0x93, 0xa2, 0xc8, 0x19, 0x06
db 0x39, 0x32, 0x62, 0xc5, 0x93, 0x13, 0x2c, 0x72, 0x31, 0x63
db 0x90, 0x05, 0x83, 0x5e, 0x80, 0x00, 0x00, 0x00, 0x00, 0x02
db 0xc1, 0xaf, 0x40, 0x00, 0x00, 0x00, 0x00, 0x0c, 0x99, 0x58
db 0x65, 0x93, 0x26, 0x4c, 0x81, 0x10, 0x99, 0x4a, 0x52, 0xc9
db 0x26, 0x53, 0x24, 0xa6, 0x40, 0x2c, 0x1a, 0xf4, 0x00, 0x08
db 0xe4, 0x8a, 0x28, 0xb2, 0x44, 0x8c, 0x72, 0x22, 0x8e, 0x41
db 0x41, 0x4a, 0x14, 0x28, 0x52, 0x80, 0xc9, 0xf2, 0x0c, 0xb2
db 0x74, 0x19, 0x03, 0x20, 0x0b, 0x06, 0xbd, 0x00, 0x01, 0xaf
db 0x61, 0x96, 0xb2, 0x64, 0x80, 0x20, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x05, 0x83, 0x5e, 0x80, 0x00, 0x00, 0x00
db 0x00, 0x02, 0xc1, 0xaf, 0x40, 0x00, 0x64, 0xcb, 0x20, 0xcb
db 0x26, 0x4c, 0x99, 0x03, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x09, 0x59
db 0x37, 0x23, 0x47, 0x47, 0xea, 0x58, 0x11, 0x16, 0x25, 0x60
db 0x13, 0xda, 0x4f, 0x95, 0xca, 0x59, 0xad, 0xd8, 0x98, 0xf9
db 0x25, 0x32, 0x05, 0x8e, 0xb0, 0x08, 0xf6, 0x98, 0x3d, 0x00
db 0x2c, 0x00, 0x68, 0xe8, 0x76, 0x66, 0x7e, 0x86, 0x63, 0xb1
db 0xf4, 0xec, 0x03, 0xeb, 0xad, 0x81, 0x8b, 0x13, 0x1c, 0x71
db 0x33, 0x67, 0x10, 0xed, 0x2f, 0x06, 0x63, 0x11, 0x81, 0x8e
db 0x79, 0xb3, 0x66, 0xcc, 0xc5, 0x8d, 0x86, 0x38, 0xb1, 0x62
db 0xc4, 0x18, 0x81, 0x62, 0xd6, 0x01, 0x5d, 0xa6, 0x7e, 0x40
db 0x16, 0x00, 0x34, 0x74, 0x2d, 0x66, 0x7e, 0xc5, 0x0a, 0x3c
db 0xb3, 0x66, 0x90, 0x05, 0x80, 0x0d, 0x1d, 0x00, 0x00, 0x00
db 0x00, 0x58, 0xeb, 0x00, 0xae, 0xd3, 0x3f, 0x4b, 0x59, 0x77
db 0x62, 0x85, 0x19, 0xeb, 0x36, 0x68, 0x8b, 0x16, 0xb0, 0x0a
db 0xed, 0x33, 0xf9, 0xae, 0xd6, 0xb5, 0xa8, 0x29, 0x46, 0x6c
db 0xf3, 0x09, 0x94, 0xb0, 0x22, 0x96, 0x64, 0x66, 0x48, 0xa3
db 0x21, 0xda, 0x4f, 0xb1, 0x22, 0x59, 0xfd, 0x76, 0x04, 0x92
db 0x99, 0x09, 0x97, 0x4a, 0x41, 0x21, 0xd9, 0x98, 0x3d, 0x0c
db 0xc7, 0x67, 0xe9, 0xd8, 0x01, 0xa3, 0xac, 0x03, 0x3e, 0xd3
db 0x07, 0xa7, 0xa7, 0x66, 0x3b, 0x33, 0x3f, 0x41, 0xe8, 0x11
db 0x46, 0xc2, 0x3a, 0x8a, 0x28, 0x82, 0x21, 0x9e, 0x6e, 0xb6
db 0x6e, 0xd3, 0x3c, 0x18, 0x0c, 0xd9, 0xe6, 0x01, 0x00, 0x41
db 0x00, 0x00, 0x0d, 0x1d, 0x60, 0x11, 0xec, 0x06, 0x0f, 0x10
db 0x05, 0x80, 0x0d, 0x1d, 0x0e, 0xd2, 0xfd, 0x8d, 0x1d, 0x3f
db 0x58, 0x18, 0x12, 0x00, 0xb0, 0x01, 0xa3, 0xa0, 0x00, 0x00
db 0x00, 0x0d, 0x1d, 0x60, 0x15, 0xd8, 0x0c, 0x1e, 0x98, 0x16
db 0x60, 0xc1, 0x80, 0x68, 0xc0, 0xc7, 0xeb, 0x03, 0x02, 0x23
db 0x00, 0xc0, 0xc0, 0x01, 0x83, 0xb0, 0x18, 0x3d, 0x31, 0xc5
db 0x8b, 0x16, 0x06, 0x2c, 0x4c, 0x71, 0xc4, 0xc0, 0xc1, 0x88
db 0x00, 0x58, 0x00, 0xd1, 0xd0, 0x00, 0x00, 0x00, 0x06, 0x8e
db 0xb0, 0x0a, 0xc0, 0xc0, 0x60, 0xf2, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x02, 0xc0, 0x06, 0x8e, 0x81, 0xa3, 0x02
db 0xc0, 0x2b, 0x03, 0x01, 0x83, 0x06, 0x00, 0x05, 0x80, 0x0d
db 0x1d, 0x0e, 0xd2, 0xef, 0x00, 0xa1, 0x46, 0x0c, 0x0c, 0x0c
db 0x0c, 0x0e, 0xb3, 0x07, 0xb1, 0xa3, 0xa3, 0xf5, 0xd8, 0x11
db 0x18, 0x07, 0x58, 0x04, 0xf6, 0x03, 0x07, 0xa4, 0xca, 0x52
db 0x94, 0xa4, 0x99, 0x92, 0x53, 0x20, 0x68, 0xeb, 0x00, 0xae
db 0xc0, 0x60, 0xf4, 0x00, 0xb0, 0x01, 0xa3, 0xa1, 0xda, 0x5f
db 0xa1, 0x42, 0x8f, 0x4e, 0xc0, 0x23, 0x14, 0x58, 0x11, 0x45
db 0x80, 0x8e, 0x08, 0x91, 0x46, 0x21, 0xd8, 0x0c, 0x1e, 0x86
db 0x01, 0x81, 0x83, 0xd3, 0xb0, 0x04, 0x10, 0x04, 0x02, 0x08
db 0x02, 0x01, 0xf5, 0xd1, 0x5b, 0xb1, 0x23, 0xe2, 0x4a, 0x64
db 0x25, 0x89, 0x33, 0x23, 0x11, 0x8b, 0x19, 0x94, 0xa5, 0x26
db 0xbd, 0x87, 0xd7, 0x41, 0x20, 0x90, 0xe8, 0x91, 0xf4, 0x22
db 0x3b, 0x1f, 0x4e, 0x88, 0x31, 0x1d, 0x88, 0x06, 0x3d, 0xa6
db 0x3e, 0x9e, 0x9d, 0x01, 0xd0, 0x1e, 0x83, 0xd0, 0x2d, 0x76
db 0x1f, 0x5d, 0x8b, 0x10, 0x40, 0x2f, 0x56, 0xb5, 0xb1, 0x62
db 0x63, 0x8e, 0x02, 0x08, 0x00, 0x2c, 0x1a, 0xf4, 0x00, 0x0e
db 0xb2, 0xfd, 0x8a, 0x14, 0x4c, 0xba, 0x29, 0x1a, 0x3a, 0xc0
db 0x2a, 0x52, 0x4c, 0xcb, 0xeb, 0xa0, 0xb5, 0x01, 0x44, 0xbc
db 0x81, 0x11, 0xd6, 0x01, 0x5d, 0x12, 0x3e, 0x80, 0x14, 0x00
db 0x28, 0x51, 0xd0, 0x1e, 0x80, 0x51, 0xe9, 0xd0, 0x17, 0x6b
db 0x5a, 0xd4, 0x14, 0xa2, 0x08, 0x02, 0xd6, 0x5d, 0xd8, 0xa1
db 0x44, 0x02, 0x08, 0x16, 0xbb, 0x05, 0x28, 0x01, 0x00, 0x6b
db 0xd8, 0x7d, 0x74, 0x52, 0x09, 0x0f, 0x2e, 0xb4, 0xbb, 0x49
db 0xf2, 0x4a, 0x64, 0x02, 0xc1, 0xaf, 0x40, 0x00, 0xf4, 0xec
db 0x03, 0xa2, 0x47, 0xd0, 0x7a, 0x0e, 0xd3, 0x07, 0xa1, 0xa3
db 0xb0, 0x7a, 0x76, 0x00, 0x3d, 0x07, 0xa7, 0x40, 0x00, 0x02
db 0xc1, 0xaf, 0x40, 0x00, 0x5a, 0xec, 0x3e, 0xbb, 0x03, 0x00
db 0x20, 0x00, 0x00, 0x00, 0x00, 0xcc, 0x66, 0xb0, 0x08, 0xf6
db 0x91, 0xf1, 0x00, 0x58, 0x00, 0xd1, 0xd0, 0xcd, 0x99, 0x9f
db 0xb1, 0x98, 0xec, 0x7e, 0xba, 0x52, 0x00, 0xb0, 0x01, 0xa3
db 0xa0, 0x00, 0x00, 0x00, 0x0c, 0xc7, 0x66, 0x01, 0x9f, 0x69
db 0x5e, 0x99, 0xac, 0xce, 0xf3, 0x1a, 0x3a, 0x39, 0xe6, 0xcd
db 0x9b, 0x31, 0x98, 0xcd, 0x60, 0x18, 0xe6, 0xcc, 0xcf, 0x3c
db 0xd8, 0xe2, 0xc5, 0x9b, 0x16, 0x2c, 0x4c, 0x71, 0xc4, 0xcd
db 0x9e, 0x20, 0x01, 0x60, 0x03, 0x47, 0x40, 0x00, 0x00, 0x00
db 0x19, 0x8e, 0xb0, 0x0a, 0xcd, 0x99, 0x9f, 0x90, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x16, 0x00, 0x34, 0x74, 0x0d
db 0x1d, 0x60, 0x15, 0x9b, 0x33, 0x3c, 0xf3, 0x00, 0x58, 0x00
db 0xd1, 0xd0, 0xeb, 0x33, 0xf6, 0x28, 0x51, 0x9e, 0x6c, 0xd9
db 0xb3, 0x76, 0x97, 0xec, 0x66, 0x33, 0x67, 0xf5, 0xd1, 0x44
db 0x66, 0x33, 0x66, 0x01, 0x9f, 0x69, 0x3e, 0x53, 0x29, 0x4a
db 0x52, 0xcc, 0x99, 0x92, 0x53, 0x20, 0x68, 0xec, 0xc0, 0x33
db 0xed, 0x2b, 0xd0, 0x02, 0xc0, 0x06, 0x8e, 0x87, 0x69, 0x5e
db 0x86, 0x63, 0xb3, 0xf4, 0xa0, 0x67, 0x14, 0x59, 0xb3, 0x45
db 0x99, 0x1c, 0xe2, 0x66, 0xce, 0x21, 0x9b, 0x33, 0x3c, 0xf3
db 0x19, 0x8c, 0xd9, 0xe7, 0x9b, 0x36, 0x6c, 0xc8, 0x20, 0x08
db 0x04, 0x10, 0x04, 0x00, 0x02, 0x80, 0x05, 0x0a, 0x00, 0x00
db 0x00, 0x01, 0x42, 0x80, 0x0a, 0xa0, 0xa5, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x00, 0xa0, 0x01, 0x42, 0x82, 0x85
db 0x00, 0x15, 0x41, 0x4a, 0x00, 0x50, 0x00, 0xa1, 0x45, 0x05
db 0x28, 0x50, 0xa1, 0x4a, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x14, 0x00, 0x28, 0x50, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa0, 0x01, 0x42
db 0x80, 0x00, 0x00, 0x00, 0x50, 0xa0, 0x02, 0xa8, 0x29, 0x42
db 0x85, 0x00, 0x15, 0x41, 0x4a, 0x00, 0x50, 0x00, 0xa1, 0x45
db 0x05, 0x28, 0x50, 0xa1, 0x4a, 0x00, 0x05, 0x00, 0x0a, 0x14
db 0x00, 0x00, 0x00, 0x02, 0x85, 0x00, 0x15, 0x41, 0x4a, 0x50
db 0x52, 0x85, 0x0a, 0x14, 0xa0, 0x14, 0x28, 0x00, 0xaa, 0x0a
db 0x50, 0x00, 0x00, 0x00, 0x76, 0x91, 0xf2, 0x22, 0x31, 0x63
db 0x32, 0x94, 0xa4, 0x58, 0xb5, 0x80, 0x63, 0xda, 0x4f, 0x97
db 0x97, 0x41, 0x6e, 0x80, 0xf2, 0x4a, 0x64, 0x0d, 0x1d, 0x60
db 0x11, 0xed, 0x2b, 0xd0, 0x02, 0xc0, 0x06, 0x8e, 0x87, 0x40
db 0x7a, 0x01, 0xd0, 0xf4, 0xa0, 0x5d, 0xba, 0xd6, 0xc5, 0x89
db 0x1c, 0x71, 0x20, 0x80, 0x2d, 0x65, 0xdd, 0x8c, 0x46, 0x2c
db 0x60, 0x10, 0x40, 0xd7, 0xb0, 0xc7, 0x17, 0x41, 0x88, 0x20
db 0x05, 0x8b, 0x58, 0x05, 0x76, 0x91, 0xf2, 0x00, 0xb0, 0x01
db 0xa3, 0xa1, 0xd0, 0x1e, 0xc0, 0x51, 0xe5, 0xd0, 0x48, 0x02
db 0xc0, 0x06, 0x8e, 0x80, 0x00, 0x00, 0x00, 0x03, 0xa0, 0x00
db 0xe8, 0x0f, 0x4b, 0x59, 0x77, 0x62, 0x85, 0x10, 0x08, 0x20
db 0x2c, 0x5a, 0xc0, 0x28, 0x80, 0x81, 0x76, 0xe8, 0x2d, 0x40
db 0x51, 0x04, 0x01, 0x32, 0x94, 0xa5, 0x14, 0x48, 0xf9, 0x25
db 0x32, 0x1d, 0xa4, 0xf9, 0x1a, 0x3a, 0x66, 0x52, 0x94, 0x92
db 0x99, 0x0f, 0x2e, 0x82, 0x41, 0x21, 0xda, 0x57, 0xa1, 0x11
db 0xd1, 0xf4, 0xa0, 0x1a, 0x3a, 0xc0, 0x30, 0xf6, 0x95, 0xe9
db 0xe9, 0x40, 0xe8, 0x0f, 0x40, 0xa0, 0x6b, 0xd8, 0x46, 0x28
db 0xa2, 0x88, 0x20, 0x17, 0x6b, 0x5a, 0xdd, 0xa6, 0x1f, 0x84
db 0x82, 0x00, 0x08, 0x02, 0x08, 0x00, 0x01, 0x72, 0xeb, 0x4b
db 0xa4, 0xc6, 0x64, 0x8b, 0xc8, 0x4b, 0x12, 0xe6, 0x46, 0x22
db 0x53, 0xf5, 0xd2, 0x93, 0x5e, 0xc3, 0xeb, 0xb1, 0x48, 0x24
db 0x3a, 0xcb, 0xf4, 0x34, 0x74, 0x7d, 0x3a, 0x20, 0xc4, 0x75
db 0x80, 0x63, 0xd8, 0x98, 0xfa, 0x7a, 0x76, 0x63, 0xb1, 0x33
db 0xf4, 0x1e, 0x81, 0xab, 0xb0, 0xdd, 0x76, 0x28, 0x03, 0x30
db 0xdd, 0x75, 0xa0, 0xd6, 0x26, 0x30, 0x19, 0xb3, 0xcc, 0x02
db 0xc1, 0xaf, 0x40, 0x00, 0xeb, 0x2e, 0xe4, 0x50, 0xa2, 0x65
db 0xd1, 0x48, 0xd1, 0x2b, 0x00, 0xa9, 0x49, 0x33, 0x2f, 0xab
db 0x5a, 0xd4, 0x14, 0xa2, 0x5e, 0x40, 0xd1, 0xd6, 0x01, 0x5d
db 0x12, 0x3e, 0x80, 0x14, 0x00, 0x28, 0x51, 0xd6, 0x67, 0xe8
db 0x50, 0xa3, 0xd3, 0xb3, 0x17, 0xab, 0x5a, 0x0a, 0x0a, 0x0d
db 0x67, 0x98, 0x6a, 0xcb, 0x80, 0x50, 0x1f, 0x59, 0xb3, 0x40
db 0xb5, 0xd8, 0x29, 0x40, 0x0c, 0xc1, 0xaf, 0x61, 0xf5, 0xd1
db 0x48, 0x22, 0x1f, 0x5d, 0x69, 0x76, 0x93, 0x32, 0x6b, 0xc8
db 0x05, 0x83, 0x5e, 0x80, 0x01, 0xe9, 0xd6, 0x3b, 0x33, 0x3f
db 0x41, 0xe8, 0x3b, 0x4b, 0xf4, 0x33, 0x1d, 0x9f, 0xa7, 0x66
db 0x07, 0xa0, 0xf4, 0xec, 0xc0, 0x00, 0x2c, 0x1a, 0xf4, 0x00
db 0x06, 0xbd, 0x86, 0xeb, 0xb3, 0x40, 0x19, 0x80, 0x00, 0x00
db 0x00, 0x95, 0x97, 0x32, 0x34, 0x4a, 0x7e, 0xba, 0x28, 0x8d
db 0x1d, 0x60, 0x13, 0xda, 0x4f, 0xa5, 0xca, 0xd6, 0x97, 0x69
db 0x33, 0x24, 0xbc, 0x81, 0x63, 0xac, 0x02, 0xbb, 0x48, 0xfa
db 0x00, 0x58, 0x00, 0xd1, 0xd0, 0xeb, 0x2f, 0xd0, 0xa1, 0x47
db 0xa7, 0x62, 0x37, 0x5d, 0x68, 0x35, 0x89, 0x8c, 0x04, 0x5e
db 0x21, 0xad, 0x2e, 0x01, 0xa0, 0x87, 0xa7, 0x62, 0x1a, 0xc7
db 0x10, 0xc7, 0x58, 0xb1, 0x40, 0x18, 0x81, 0x62, 0xd6, 0x01
db 0x5a, 0xd2, 0x3e, 0x40, 0x16, 0x00, 0x34, 0x74, 0x2d, 0x65
db 0xdc, 0x8a, 0x14, 0x79, 0x74, 0xa4, 0x01, 0x60, 0x03, 0x47
db 0x40, 0x00, 0x00, 0x00, 0x16, 0x3a, 0xc0, 0x2b, 0xb4, 0xc3
db 0xe9, 0xab, 0x2e, 0x01, 0x40, 0x6e, 0xba, 0x28, 0x0d, 0x04
db 0x00, 0x1a, 0xd3, 0x0c, 0x0b, 0xd5, 0xad, 0x05, 0x05, 0x06
db 0xbe, 0x10, 0xfa, 0xeb, 0x45, 0x29, 0x26, 0x64, 0xd7, 0x88
db 0x76, 0x97, 0xe8, 0x48, 0x94, 0xfa, 0x74, 0x84, 0xa6, 0x42
db 0x65, 0x29, 0x48, 0x24, 0x3a, 0xcb, 0xf4, 0x28, 0x51, 0xe9
db 0xd1, 0x05, 0x8e, 0xb0, 0x0a, 0xed, 0x30, 0xfa, 0x7a, 0x75
db 0x8a, 0x0a, 0x50, 0x7a, 0x04, 0x51, 0x88, 0x7d, 0x45, 0x14
db 0x01, 0x10, 0xf4, 0xeb, 0x1a, 0xd3, 0x0c, 0x01, 0xe8, 0x02
db 0x00, 0x82, 0x00, 0x00, 0x35, 0xec, 0x3e, 0xbb, 0x14, 0x82
db 0x43, 0x65, 0xd8, 0xa5, 0xd8, 0x98, 0xcc, 0x92, 0x99, 0x00
db 0xb0, 0x6b, 0xd0, 0x00, 0x3d, 0x3a, 0x23, 0xb1, 0x23, 0xe8
db 0x3d, 0x07, 0x62, 0x63, 0xe8, 0x62, 0x3b, 0x1f, 0x4e, 0xc4
db 0x0f, 0x41, 0xe9, 0xd0, 0x00, 0x00, 0xb0, 0x6b, 0xd0, 0x00
db 0x1a, 0xbb, 0x0d, 0xd7, 0x62, 0x80, 0x20, 0x00, 0x00, 0x00
db 0x03, 0xeb, 0xad, 0x6a, 0x0a, 0x51, 0x29, 0x90, 0xed, 0x2e
db 0xe4, 0x50, 0xa2, 0x65, 0x29, 0x49, 0xaf, 0x60, 0xa5, 0x00
db 0x24, 0x3a, 0xc8, 0xfa, 0x14, 0x28, 0xf4, 0xe8, 0x82, 0x85
db 0x00, 0x15, 0x41, 0x4a, 0x7a, 0x74, 0x05, 0x01, 0x41, 0xe8
db 0x16, 0xbb, 0x05, 0x28, 0x01, 0x00, 0xbd, 0x5a, 0xd0, 0x50
db 0x50, 0x41, 0x00, 0x05, 0x80, 0x50, 0x00, 0x02, 0xc1, 0xaf
db 0x40, 0x00, 0x6b, 0xd8, 0x7d, 0x74, 0xa4, 0x12, 0x00, 0x00
db 0x00, 0x00, 0x7a, 0x0f, 0x4e, 0x88, 0x00, 0x7a, 0x75, 0x8e
db 0xd3, 0x0f, 0xa0, 0xf4, 0x00, 0x01, 0xe8, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x2c, 0x1a, 0xf4, 0x00, 0x00, 0x00, 0x00, 0x00
db 0xb5, 0xd8, 0x7d, 0x74, 0xb3, 0x04, 0x43, 0x3c, 0xd6, 0x94
db 0xb3, 0x49, 0x33, 0x99, 0x8b, 0xe2, 0x01, 0x60, 0xd7, 0xa0
db 0x00, 0x7b, 0x60, 0x5a, 0x2c, 0xda, 0x46, 0x39, 0x98, 0xb1
db 0xc4, 0x31, 0x69, 0x7e, 0xc6, 0x8e, 0xc7, 0x1c, 0x58, 0xb1
db 0x62, 0x6b, 0xd8, 0x7d, 0x76, 0x6c, 0xc1, 0x80, 0x02, 0xc1
db 0xaf, 0x40, 0x00, 0x6b, 0xd8, 0x7d, 0x74, 0x19, 0x83, 0x30
db 0x00, 0x00, 0x00, 0x1e, 0x2c, 0xd2, 0x8b, 0x34, 0x91, 0x9c
db 0x04, 0x53, 0x98, 0x4a, 0x49, 0xf6, 0x24, 0x4a, 0x7e, 0xa5
db 0x29, 0x35, 0xec, 0x3e, 0xba, 0x52, 0x09, 0x08, 0xb4, 0xbb
db 0x88, 0xd1, 0xd1, 0xd8, 0xba, 0x28, 0x8a, 0x14, 0x00, 0x55
db 0x05, 0x29, 0xf5, 0x81, 0x9a, 0xd9, 0xb3, 0x33, 0xcf, 0x33
db 0x58, 0x30, 0x03, 0x5e, 0xc3, 0xeb, 0xa0, 0xc0, 0x0c, 0xc3
db 0xe6, 0xe8, 0x33, 0x74, 0x07, 0xc0, 0x66, 0xf9, 0x80, 0x58
db 0x35, 0xe8, 0x00, 0x01, 0x60, 0xd7, 0xa0, 0x00, 0x2d, 0x76
db 0x1f, 0x5d, 0x2c, 0xc1, 0x00, 0x00, 0x00, 0x00, 0x0b, 0x5d
db 0x87, 0xd7, 0x45, 0x98, 0x20, 0x17, 0x6b, 0x5b, 0x36, 0x6d
db 0x33, 0xcf, 0x32, 0x08, 0x00, 0x2c, 0x1a, 0xf4, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x16, 0x0d, 0x7a, 0x00, 0x00, 0x00, 0x00
db 0x00, 0xfa, 0xb4, 0xad, 0xd2, 0x4f, 0x89, 0x16, 0x38, 0x87
db 0x49, 0x7e, 0x84, 0x8e, 0x9f, 0x4e, 0x90, 0xb5, 0xd8, 0x7d
db 0x74, 0xa4, 0x18, 0x85, 0xb4, 0xbf, 0x62, 0x85, 0x18, 0xe2
db 0xc5, 0x8a, 0x23, 0x47, 0x58, 0x05, 0x62, 0xc4, 0xc7, 0xd3
db 0x6d, 0xd6, 0xb5, 0x05, 0x28, 0xc5, 0x83, 0x10, 0x6b, 0xd8
db 0x7d, 0x74, 0x11, 0x04, 0x43, 0xd3, 0xa0, 0x3a, 0x03, 0xd0
db 0x7a, 0x00, 0xb0, 0x6b, 0xd0, 0x00, 0x22, 0x92, 0x63, 0x11
db 0x22, 0x53, 0x18, 0xa2, 0x94, 0x44, 0x8e, 0x90, 0x09, 0xe9
db 0x27, 0xd3, 0xea, 0xd2, 0xb4, 0xa4, 0x99, 0x93, 0x5e, 0x40
db 0xd1, 0xd6, 0x01, 0x51, 0x69, 0x18, 0xc4, 0x01, 0x40, 0x02
db 0x85, 0x16, 0xd2, 0xee, 0xc5, 0x0a, 0x3e, 0xb0, 0x30, 0x30
db 0x3c, 0x5d, 0x04, 0x5d, 0x01, 0xf0, 0x11, 0x78, 0x87, 0x40
db 0x7a, 0x01, 0xd0, 0xf4, 0xe8, 0x06, 0xbd, 0x87, 0xd7, 0x41
db 0x80, 0x18, 0x01, 0x6b, 0xb0, 0xfa, 0xe9, 0x44, 0x10, 0x0f
db 0x4e, 0xb1, 0xd2, 0x4f, 0xa0, 0x80, 0x02, 0xc1, 0xaf, 0x40
db 0x00, 0xbb, 0x5a, 0xd6, 0xa0, 0xa5, 0x10, 0x40, 0x16, 0xb2
db 0xfd, 0x0a, 0x14, 0x40, 0x20, 0x16, 0xbb, 0x05, 0x28, 0x01
db 0x00, 0x0b, 0x06, 0xbd, 0x00, 0x00, 0x7a, 0x0f, 0x4e, 0x80
db 0x00, 0x00, 0x00, 0x00, 0x00, 0xb0, 0x6b, 0xd0, 0x00, 0x1a
db 0xf6, 0x18, 0x30, 0x3a, 0x58, 0x01, 0x20, 0x00, 0x00, 0x00
db 0x18, 0x18, 0x30, 0x06, 0x0c, 0x0c, 0x0c, 0x0c, 0x00, 0xc0
db 0x18, 0xe2, 0xc0, 0xc5, 0x8b, 0x03, 0x13, 0x06, 0x38, 0x0c
db 0x58, 0xe2, 0x01, 0x60, 0xd7, 0xa0, 0x00, 0x00, 0x00, 0x00
db 0x00, 0xb0, 0x6b, 0xd0, 0x00, 0x00, 0x00, 0x00, 0x03, 0x03
db 0xd8, 0x7c, 0x0e, 0x8b, 0x00, 0x22, 0x13, 0x29, 0x4a, 0x52
db 0x92, 0x67, 0x01, 0x29, 0x90, 0x0b, 0x06, 0xbd, 0x00, 0x02
db 0x38, 0x18, 0x11, 0x45, 0x14, 0x48, 0xc7, 0x01, 0x14, 0x70
db 0x05, 0x05, 0x28, 0x50, 0xa1, 0x4a, 0x03, 0x03, 0x06, 0x00
db 0xf8, 0x1d, 0x06, 0x00, 0x60, 0x00, 0xb0, 0x6b, 0xd0, 0x00
db 0x1a, 0xf6, 0x1f, 0x03, 0xa0, 0xc0, 0x08, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x01, 0x60, 0xd7, 0xa0, 0x00, 0x00
db 0x00, 0x00, 0x00, 0xb0, 0x6b, 0xd0, 0x00, 0x1a, 0xc1, 0x61
db 0x83, 0x03, 0x03, 0x03, 0x00, 0x20, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01
db 0xf5, 0x29, 0x5b, 0x52, 0x4f, 0x89, 0x8a, 0x64, 0x2d, 0x24
db 0xfc, 0xc4, 0x89, 0x4f, 0xc5, 0x29, 0x62, 0x6b, 0xd8, 0x6e
db 0xba, 0x52, 0x09, 0x0d, 0x69, 0x5e, 0xc6, 0x8c, 0xd1, 0xdc
db 0x54, 0x31, 0x1a, 0x31, 0x58, 0x06, 0x38, 0xb4, 0xac, 0x71
db 0x6e, 0xa8, 0x5b, 0xb4, 0xac, 0xf3, 0x34, 0xa0, 0x5b, 0xd8
db 0x7d, 0x74, 0x11, 0x04, 0x43, 0xe6, 0xe8, 0x33, 0x74, 0x07
db 0xcc, 0xcd, 0xf1, 0x00, 0xb0, 0x6b, 0xd0, 0x00, 0x35, 0x24
db 0xf8, 0x88, 0x88, 0xa6, 0x62, 0x94, 0xa2, 0x24, 0x4a, 0x40
db 0x26, 0x52, 0x4f, 0x97, 0xd4, 0xa5, 0x6e, 0xd2, 0x7c, 0x9a
db 0x99, 0x03, 0x44, 0x56, 0x01, 0x1e, 0xd2, 0xa3, 0x10, 0x05
db 0x00, 0x0a, 0x14, 0x6b, 0x4a, 0xf6, 0x33, 0x19, 0xb3, 0xdd
db 0x50, 0xcd, 0xf5, 0xd0, 0x5b, 0xa0, 0x3c, 0x4c, 0xdf, 0x30
db 0xe8, 0x0f, 0x98, 0x0e, 0x87, 0xcd, 0xd0, 0x66, 0x6b, 0xd8
db 0x7d, 0x74, 0x19, 0x83, 0x30, 0x5a, 0xec, 0x3e, 0xba, 0x59
db 0x82, 0x01, 0x76, 0xb4, 0xb3, 0x74, 0x93, 0x9e, 0x64, 0x10
db 0x00, 0x58, 0x35, 0xe8, 0x00, 0x1b, 0x6a, 0x16, 0xed, 0x2b
db 0x3c, 0xc8, 0x00, 0xb6, 0x95, 0x76, 0x34, 0x66, 0xce, 0x00
db 0x40, 0xd2, 0x83, 0xea, 0x86, 0x60, 0x00, 0x58, 0x35, 0xe8
db 0x00, 0x0b, 0x7b, 0x0f, 0xae, 0x83, 0x30, 0x40, 0x00, 0x00
db 0x00, 0x05, 0xa4, 0x9f, 0x11, 0x22, 0x53, 0xf1, 0x4a, 0x51
db 0x1a, 0x3a, 0xc0, 0x27, 0xb4, 0x9f, 0x49, 0xc5, 0x29, 0x5a
db 0x52, 0x4c, 0xc9, 0x8a, 0x71, 0x03, 0x45, 0xac, 0x02, 0xb5
db 0xa5, 0x7c, 0x40, 0x16, 0x00, 0x34, 0x74, 0x3b, 0x4a, 0xbb
db 0x14, 0x28, 0xdc, 0x54, 0x31, 0x78, 0xba, 0x08, 0xba, 0x03
db 0xc4, 0x8b, 0xe2, 0x1d, 0x01, 0xe8, 0x07, 0x43, 0xd3, 0xa0
db 0x18, 0xbe, 0x21, 0xf1, 0x74, 0x18, 0x83, 0x10, 0x34, 0x75
db 0x80, 0x4f, 0x69, 0x3e, 0x20, 0x0b, 0x00, 0x1a, 0x3a, 0x1a
db 0x92, 0x7d, 0x89, 0x12, 0x9f, 0xa9, 0x4a, 0x40, 0x16, 0x00
db 0x34, 0x74, 0x00, 0x00, 0x00, 0x01, 0xa2, 0xd6, 0x01, 0x5a
db 0xd2, 0xbe, 0x17, 0x40, 0x78, 0x80, 0xe8, 0x78, 0xba, 0x08
db 0x80, 0xe8, 0x00, 0x3a, 0x03, 0xd3, 0xeb, 0xa0, 0xb7, 0x40
db 0x7c, 0x26, 0xbe, 0x10, 0xf6, 0xb4, 0xad, 0x29, 0x27, 0xc4
db 0x82, 0x00, 0xed, 0x2f, 0xd0, 0x91, 0xd3, 0x00, 0x80, 0x6a
db 0x6c, 0x26, 0x52, 0x94, 0x82, 0x01, 0x6d, 0x2a, 0xec, 0x50
db 0xa2, 0x00, 0x40, 0x58, 0xb5, 0x80, 0x51, 0x01, 0x03, 0x6d
db 0x42, 0xd4, 0x14, 0xa2, 0x00, 0x11, 0x7b, 0x0f, 0x17, 0x41
db 0x10, 0x40, 0x3d, 0x3a, 0x03, 0xa0, 0x3d, 0x04, 0x00, 0x10
db 0x04, 0x10, 0x00, 0x01, 0xaf, 0x61, 0xba, 0xe9, 0x44, 0x12
db 0x13, 0x69, 0x4a, 0xda, 0x92, 0x7c, 0x9a, 0x99, 0x00, 0xb0
db 0x6b, 0xd0, 0x00, 0x37, 0x54, 0x2d, 0xad, 0x2b, 0xc4, 0xd2
db 0x83, 0xb4, 0xac, 0x71, 0x1a, 0x31, 0x63, 0xb8, 0xa8, 0x62
db 0x69, 0x41, 0xba, 0xa1, 0x88, 0x00, 0x16, 0x0d, 0x7a, 0x00
db 0x02, 0xde, 0xc3, 0xeb, 0xa0, 0xc4, 0x10, 0x00, 0x00, 0x00
db 0x01, 0x3a, 0x94, 0xad, 0xda, 0x47, 0xc4, 0x94, 0xc8, 0x4a
db 0x49, 0x99, 0x12, 0x25, 0x33, 0x29, 0x4a, 0x4d, 0x7b, 0x0f
db 0xae, 0x82, 0x41, 0x21, 0xda, 0x54, 0x62, 0x22, 0x22, 0x8f
db 0xd5, 0x08, 0x8a, 0x14, 0x00, 0x55, 0x05, 0x29, 0xba, 0xa1
db 0x6e, 0x80, 0xf8, 0x4d, 0x28, 0x16, 0xf6, 0x1f, 0x5d, 0x04
db 0x41, 0x00, 0xf6, 0xe8, 0x2d, 0xd0, 0x1f, 0x09, 0x04, 0x00
db 0x16, 0x0d, 0x7a, 0x00, 0x00, 0x58, 0x35, 0xe8, 0x00, 0x0b
db 0x5d, 0x86, 0xeb, 0xa5, 0x20, 0x80, 0x00, 0x00, 0x00, 0x06
db 0x94, 0x1b, 0xaa, 0x11, 0x00, 0x36, 0xd4, 0x2d, 0xad, 0x2b
db 0xe1, 0x20, 0x00, 0x00, 0xd2, 0x80, 0x00, 0x00, 0x00, 0x00
db 0x02, 0xc1, 0xaf, 0x40, 0x00, 0x00, 0x00, 0x00, 0x01, 0x60
db 0xd7, 0xa0, 0x00, 0x33, 0x67, 0x98, 0x67, 0x9b, 0xa5, 0x98
db 0x33, 0x00, 0x00, 0x00, 0x00, 0xcd, 0x9d, 0x86, 0x79, 0xb3
db 0x66, 0xcc, 0x11, 0x0c, 0x73, 0x62, 0xc5, 0x8b, 0x36, 0x26
db 0x78, 0xe6, 0x62, 0xc7, 0x10, 0x0b, 0x06, 0xbd, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x05, 0x83, 0x5e, 0x80, 0x00, 0x00, 0x00
db 0x00, 0x19, 0xb3, 0xcc, 0x3e, 0xba, 0x28, 0x83, 0x30, 0x9c
db 0xd2, 0x94, 0xa5, 0x24, 0xcc, 0x92, 0x9c, 0xc0, 0x2c, 0x1a
db 0xf4, 0x00, 0x08, 0xe6, 0xcd, 0x14, 0x59, 0xa2, 0x67, 0x1c
db 0xc8, 0xa3, 0x98, 0x50, 0x52, 0x85, 0x0a, 0x14, 0xa0, 0x33
db 0x67, 0x98, 0x67, 0x9b, 0x36, 0x6c, 0xc1, 0x98, 0x05, 0x83
db 0x5e, 0x80, 0x00, 0xcd, 0xf3, 0x0f, 0xae, 0x82, 0x00, 0xcc
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x0b, 0x06, 0xbd
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x05, 0x83, 0x5e, 0x80, 0x00
db 0xcd, 0xec, 0x33, 0xcd, 0x9b, 0x36, 0x60, 0x80, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x03, 0x5e, 0xc3, 0xeb, 0xa5, 0x10, 0x44, 0x3d, 0x3a
db 0x47, 0x49, 0x3e, 0x83, 0xd0, 0x05, 0x83, 0x5e, 0x80, 0x01
db 0xf5, 0x6b, 0x5a, 0x82, 0x94, 0x45, 0x8e, 0x21, 0xda, 0x5f
db 0xa1, 0x42, 0x8f, 0x4c, 0x58, 0x85, 0xae, 0xc1, 0x4a, 0x00
db 0x62, 0x01, 0x60, 0xd7, 0xa0, 0x00, 0x0f, 0x41, 0xe9, 0xd0
db 0x00, 0x00, 0x00, 0x00, 0x01, 0xf5, 0xd2, 0x8a, 0x52, 0x4c
db 0xc9, 0x14, 0x62, 0x1d, 0x24, 0xfa, 0x12, 0x25, 0x3e, 0x9d
db 0x21, 0x6b, 0xb0, 0xfa, 0xe9, 0x48, 0x24, 0x3b, 0x4b, 0xf6
db 0x28, 0x51, 0x18, 0xa2, 0x8a, 0x22, 0x85, 0x00, 0x15, 0x41
db 0x4a, 0x5d, 0xad, 0x6b, 0x50, 0x52, 0x8d, 0x7c, 0x20, 0xd7
db 0xb0, 0xfa, 0xe8, 0x20, 0x08, 0x87, 0xa7, 0x40, 0x74, 0x04
db 0x01, 0xe8, 0x02, 0xc1, 0xaf, 0x40, 0x00, 0x0b, 0x06, 0xbd
db 0x00, 0x00, 0x7a, 0x0f, 0x4e, 0x90, 0x00, 0x00, 0x00, 0x00
db 0x0b, 0x5d, 0x82, 0x94, 0x00, 0x80, 0x7a, 0x5a, 0xc5, 0x05
db 0x28, 0x20, 0x00, 0xb0, 0x0a, 0x00, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x0f, 0x40, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x20, 0x08, 0x20, 0x00, 0x00, 0x00, 0x00, 0x00, 0x08
db 0x02, 0x08, 0x00, 0x00, 0x82, 0x00, 0x80, 0x41, 0x00, 0x40
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x20, 0x08, 0x20, 0x00, 0x02, 0x08
db 0x02, 0x01, 0x04, 0x01, 0x00, 0x00, 0x00, 0x00, 0x08, 0x20
db 0x08, 0x04, 0x10, 0x04, 0x00, 0x00, 0x00, 0x00, 0x04, 0x01
db 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x41, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x04, 0x01
db 0x04, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

;;; Reinicializa las variables para la lectura secuencial de
;;; la tabla
reset_comp_table_reading:
	
		;; Pongo el primer byte en el puntero al pr�ximo byte
		mov cmt_ptr, #high(comp_move_table)
		mov cmt_ptr + 1, #low(comp_move_table)

		;; Pongo 8 en el offset actual (para que lea)
		mov cmt_bit_offset, #8

		;; Vuelve
		ret

;;; Lee el pr�ximo bit desde la tabla comprimida
comp_table_read_next_bit:

		;; Si el offset de bit no es 8, leo del buffer
		mov A, cmt_bit_offset
		cjne A, #8, cmt_read_bit

		;;
		;; Tengo que leer un byte
		;;

		;; Cargo el puntero en DPTR
		mov DPH, cmt_ptr
		mov DPL, cmt_ptr + 1
	
		;; Leo de DPTR al buffer
		clr A
		movc A, @A+DPTR
		mov cmt_byte_buffer, A
	
		;; Incremento DPTR
		inc DPTR
	
		;; Guardo el puntero incrementado
		mov cmt_ptr, DPH
		mov cmt_ptr + 1, DPL

		;; Limpio el contador de bits
		mov cmt_bit_offset, #0

	;; Si tiene el buffer lleno, lee un bit
	cmt_read_bit:

		;; Incremento el bit offset
		inc cmt_bit_offset

		;; Guardo el bit menos significativo en carry
		rrc A
		
		;; Vuelvo
		ret

;;; Obtiene la movida correspondiente a la siguiente posici�n del tablero
comp_table_read_next_move:

		;; La tabla presenta una codificaci�n Hufmann de acuerdo a lo
		;; siguiente:

		;; 0	111
		;; 1	1101
		;; 2	1011
		;; 3	10001
		;; 4	1001
		;; 5	110001
		;; 6	110011
		;; 7	11000006
		;; 8	110010
		;; 9	1100001
		;; 10	1010
		;; 11	10000
		;; 12	0

		;; La decodificaci�n procede interpretando el proceso como un �rbol en
		;; donde cada nodo representa una decisi�n a tomar en base a un bit de
		;; la entrada. Ver la documentaci�n para m�s detalles

	node_A:
		call comp_table_read_next_bit
		jc node_B
		mov A, #12
		ret

	node_B:
		call comp_table_read_next_bit
		jc node_D
		jmp node_C

	node_C:
		call comp_table_read_next_bit
		jc node_F
		jmp node_E

	node_D:
		call comp_table_read_next_bit
		jnc node_G
		mov A, #0
		ret

	node_E:
		call comp_table_read_next_bit
		jnc node_H
		mov A, #4
		ret
		
	node_F:
		call comp_table_read_next_bit
		jc node_F_2
		mov A, #10
		ret
	node_F_2:
		mov A, #2
		ret

	node_G:
		call comp_table_read_next_bit
		jnc node_I
		mov A, #1
		ret

	node_H:
		call comp_table_read_next_bit
		jc node_H_2
		mov A, #11
		ret
	node_H_2:
		mov A, #3
		ret

	node_I:
		call comp_table_read_next_bit
		jc node_K
		jmp node_J

	node_J:
		call comp_table_read_next_bit
		jnc node_L
		mov A, #5
		ret

	node_K:
		call comp_table_read_next_bit
		jc node_K_2
		mov A, #8
		ret
	node_K_2:
		mov A, #6
		ret

	node_L:
		call comp_table_read_next_bit
		jc node_L_2
		mov A, #7
		ret
	node_L_2:
		mov A, #9
		ret

;;; Obtiene la movida correspondiente a un tablero dado en una cierta
;;; codificaci�n
comp_table_get_move_from_board:

		;; Inicializo la lectura para empezar desde el principio
		call reset_comp_table_reading
		
		;;
		;; Leo del tablero la cantidad de veces indicada por el par R1 - R0:
		;; como este par indica posici�n, debo incrementarlo por uno para tener
		;; la cantidad de lecturas requeridas.
		;;

		mov A, R0
		add A, #1
		mov R0, A
		mov A, R1
		addc A, #0
		mov R1, A

	ctgmfb_loop:

		;; Lee la pr�xima movida desde la tabla comprimida
		call comp_table_read_next_move 

		;; Dos loops anidados: el interno se ejecuta R0 veces inicialmente.
		;; Luego, durante R1 veces, se ejecuta el loop interno partiendo desde
		;; cero. Esto significa que el contenido interno a ambos loops se
		;; ejecuta R0 + R1 * 256 veces, que es exactamente lo buscado.

		djnz R0, ctgmfb_loop
		djnz R1, ctgmfb_loop

		;; La �ltima ejecuci�n es la que se encarga de dejar en el acumulador
		;; la movida a realizar

		;; Vuelvo
		ret

;;; Multiplica el n�mero formado por R2 (parte alta) y R3 (parte baja) por 3
mult_r2_r3_by_3:

		;; Copio a B y A
		mov B, R2
		mov A, R3

		;; Roto B y A un bit a la izquierda
		rlc A
		xch A, B
		rlc A
		xch A, B
		
		;; Sumo con R2 y R3
		add A, R3
		mov R3, A
		mov A, B
		addc A, R2
		mov R2, A
		
		;; Vuelvo
		ret 

;;; Codifica el tablero en los registros R1 (parte alta) y R0 (parte baja)
;;; Las l�neas en memoria se codifican siguiendo el formato '00aabbcc', donde
;;; 'aa', 'bb' y 'cc' representan las columnas 2, 1 y 0, respectivamente.
;;; Debe codificarse todo el tablero en un formato tal que, si denominamos las
;;; posiciones de acurdo al siguiente diagrama:
;;;
;;; 0|1|2
;;; -+-+-
;;; 3|4|5
;;; -+-+-
;;; 6|7|8
;;;
;;; quedar�a codificado como: Pos_0 * 3^0 + Pos_1 * 3^1 + ... + Pos_8 * 3^8

get_encoded_board:

		;; Empiezo apuntando a linea_0
		mov R1, #linea_0

		;; Guardo en buffer
		mov R0, #buffer

		;; Son 3 l�neas
		mov R3, #3
		
		encode_line: ; Codifico la l�nea apuntada por R1
	
			;; Pongo la posici�n 2 en A
			mov A, @R1
			swap A
			anl A, #3
	
			;; Multiplico por 3
			mov B, #3
			mul AB ; Solo me interesa la parte baja, que queda en A
	
			;; Guardo lo acumulado en R2
			mov R2, A
	
			;; Pongo la posici�n 1 en A
			mov A, @R1
			rr A
			rr A
			anl A, #3
	
			;; La sumo con lo acumulado
			add A, R2
	
			;; Multiplico por 3
			mov B, #3
			mul AB
	
			;; Pongo la posici�n 0 en R2
			mov AR2, @R1
			anl AR2, #3

			;; Sumo con lo acumulado
			add A, R2
	
			;; Guardo en buffer
			mov @R0, A
	
			;; Paso a la siguiente l�nea
			inc R0
			inc R1
			djnz R3, encode_line

		;;
		;; Tengo las 3 l�neas codificadas por separado; debo combinarlas
		;;

		;; Apunto R0 a la �ltima l�nea codificada
		mov R0, buffer + 2

		;; Guardo en A
		mov A, @R0

		;; Apunto a la anterior
		dec R0	

		;; Multiplico por 27, sumo una nueva l�nea y guardo en R2 y R3
		mov B, #27
		mul AB
		add A, @R0
		dec R0
		mov R3, A
		mov A, B
		addc A, #0
		mov R2, A

		;; Multiplico por 27 al contenido de R2 (alto) y R3 (bajo)
		;; Aprovecho que 27 = 3^3, multiplico 3 veces por 3
		call mult_r2_r3_by_3
		call mult_r2_r3_by_3
		call mult_r2_r3_by_3

		;; Sumo la l�nea 0 codificada
		mov A, R3
		add A, @R0
		mov R3, A
		mov A, R2
		addc A, #0
		mov R2, A
									
		;; Vuelvo
		ret

;;; Ejecuta la movida indicada por el acumulador
make_ai_move:
		
		;; Se fija si es una movida real o simplemente una indicaci�n
		cjne A, #9, $+3
		jnc not_a_real_move

		;;
		;; Es una movida real, la lleva a cabo
		;;

	mam_xxxx:
		jb ACC.3, mam_1000

	mam_0xxx:
		jb ACC.2, mam_01xx

	mam_00xx:
		jb ACC.1, mam_001x

	mam_000x:
		jb ACC.0, mam_0001

	mam_0000:
		PUT_SYMBOL 0, 0, "O"
		ret

	mam_1000:
		PUT_SYMBOL 2, 2, "O"
		ret

	mam_01xx:
		jb ACC.1, mam_011x

	mam_010x:
		jb ACC.0, mam_0101

	mam_0100:
		PUT_SYMBOL 1, 1, "O"
		ret

	mam_001x:
		jb ACC.0, mam_0011

	mam_0010:
		PUT_SYMBOL 0, 2, "O"
		ret

	mam_0001:
		PUT_SYMBOL 0, 1, "O"
		ret

	mam_011x:
		jb ACC.0, mam_0111

	mam_0110:
		PUT_SYMBOL 2, 0, "O"
		ret

	mam_0101:
		PUT_SYMBOL 1, 2, "O"
		ret
		
	mam_0011:
		PUT_SYMBOL 1, 0, "O"
		ret
		
	mam_0111:
		PUT_SYMBOL 2, 1, "O"
		ret			

	not_a_real_move:

		;; FIXME: VER QUE HACER!!

		;; Vuelve
		ret

;;; Obtiene y ejecuta la movida correspondiente al tablero actual
ai_play:
		;; Decide si le corresponde jugar o no
		mov R0, turno ; Guardo el turno en R0 para poder compararlo
		cjne R0, #turno_maquina, fin_jugar_maquina ; Si no le toca jugar a la m�quina, salgo
		djnz timer_jugada_maquina, fin_jugar_maquina ; Si le toca jugar, veo si termin� el tiempo de espera
		
		;; Si el timer llega a cero, pasa de largo y juega

		;; Obtengo el tablero codificado en el par R1 - R0
		call get_encoded_board

		;; Obtiene la movida correspondiente al tablero indicado por el par
		;; R1 - R0 y la devuelve en el acumulador
		call comp_table_get_move_from_board

		;; Ejecuta la movida indicada por el acumulador
		call make_ai_move

		;; Pasa el turno al humano
		mov turno, #turno_humano
		
fin_jugar_maquina:

		;; Vuelvo
		ret

;;; Fin del m�dulo
END
