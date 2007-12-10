;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beiró y Mariano Chouza
;;;; Módulo de sonido (SOUND)
;;;; Se encarga de reproducir una melodia

$INCLUDE(macros.inc)		; Macros de propósito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general

NAME SOUND

;;; Segmento propio de este módulo
SOUND_SEG SEGMENT CODE

;;; Importa
$INCLUDE(variables.inc)		; Variables compartidas a nivel global

;;; Exporta solo la función de inicialización y la de reproduccion
PUBLIC sound_init, sound_start_melody, sound_play

;;; Comienza el segmento SOUND_SEG
RSEG SOUND_SEG

;;;
;;; sound_init
;;;
;;;	Rutina que inicializa el sonido.
;;;
sound_init:
		MOV puerto_sonido, #silencio		
		RET


;Melodía cuando el humano juega
altura_melodia_humano:
	db nota_4, silencio, nota_4, silencio, nota_3, silencio, nota_3, silencio, nota_2, silencio, nota_2, silencio, nota_4, fin_melodia

duracion_melodia_humano:
	db corchea, semicorchea, corchea, semicorchea, corchea, semicorchea, corchea, semicorchea, corchea, semicorchea, corchea, semicorchea, negra, fin_melodia

;Melodía cuando la máquina juega
altura_melodia_maquina:
	db nota_3, silencio, nota_3, silencio, nota_2, silencio, nota_2, silencio, nota_3, fin_melodia

duracion_melodia_maquina:
	db corchea, semicorchea, corchea, semicorchea, corchea, semicorchea, corchea, semicorchea, negra, fin_melodia

;Melodía cuando el juego termina
altura_melodia_final:
	db 	nota_3,	silencio, 	nota_3, 	silencio, 	nota_3
	db	silencio,nota_3, 	silencio, 	nota_1, 	silencio
	db	nota_4,	silencio, 	nota_4, 	silencio, 	nota_3
	db	silencio,nota_3, 	silencio, 	nota_2, 	silencio
	db	nota_3, silencio
	db 	nota_3,	silencio, 	nota_3, 	silencio, 	nota_3
	db	silencio,nota_3, 	silencio, 	nota_1, 	silencio
	db	nota_4,	silencio, 	nota_3, 	fin_melodia

duracion_melodia_final:
	db 	negra,	corchea,	negra,		corchea,	semicorchea
	db	corchea,negra,		corchea,	negra,		semicorchea
	db	corchea,semicorchea, 	negra, 		corchea, 	corchea
	db	semicorchea,negra, 		corchea, 	corchea, 	semicorchea
	db	negra, negra
	db 	negra,	corchea,	negra,		corchea,	semicorchea
	db	corchea,negra,		corchea,	negra,		semicorchea
	db	corchea,semicorchea,	negra,		fin_melodia

;Melodía cuando se empata
altura_melodia_empate:
	db 	nota_4,	silencio, 	nota_3, 	silencio, 	nota_2,	fin_melodia

duracion_melodia_empate:
	db 	corchea,	corchea,	corchea,		corchea,	blanca, fin_melodia

tabla_alturas_melodias:
	dw altura_melodia_humano, altura_melodia_maquina, altura_melodia_final, altura_melodia_empate

tabla_duraciones_melodias:
	dw duracion_melodia_humano, duracion_melodia_maquina, duracion_melodia_final, duracion_melodia_empate

; Recibe en R0 (parte baja) y R1 la direccion de la tabla
leer_tabla:
	mov DPH, R1
	mov DPL, R0
	MOVC A, @A+DPTR
	RET

; Recibe en R0 (parte baja) y R1 la direccion de la tabla
; En A viene el número de melodía: 1, 2, 3 o 4
leer_tabla_w:
	mov DPH, R1
	mov DPL, R0
	DEC A ;Decremento A porque los números de melodía comienzan en 1
	RL A ;Multiplico por dos, porque los elementos en la tabla son words
	MOV R3, A
	MOVC A, @A+DPTR
	INC DPTR
	MOV B, A ;Queda en B la parte alta
	MOV A, R3
	MOVC A, @A+DPTR  ;Queda en A la parte baja
	RET

;; Rutina que recibe en A la melodia a reproducir
sound_start_melody:
		MOV estado_melodia, A ;Comienzo a reproducir la melodia
		MOV nota_actual, #(-1) ;Para empezar desde la primera nota
		MOV timer_nota_actual, #0; Para que se tome a continuación la nota 0
		RET

sound_play:
;		Si reproduciendo == false
;			nada
;		Sino //Reproduciendo == true
;			Si duracion != 0 //Hay que seguir reproduciendo la nota
;				salir
;			Sino
;				Si no hay siguiente_nota
;					reproduciendo=false
; 					salir
;				Sino
;					tomar_siguiente_nota
;					guardar_siguiente_duracion
;				Fin
;			Fin
;			duracion--
;		Fin


		MOV A, estado_melodia ;Paso el estado a R0 para comparar
		JZ saltar_a_fin ;Si no hay que reproducir nada, salgo
		JMP no_saltar_a_fin
	
	saltar_a_fin:
		INT_SLEEP 75, R0
		ret
	no_saltar_a_fin:

		MOV R0, timer_nota_actual ;Paso la duración restante a R0 para comparar con 0
		CJNE R0, #0, saltar_a_descontar_tiempo ;Si la nota sigue, le descuento una unidad de tiempo (frame)
		JMP no_saltar_a_descontar_tiempo
	saltar_a_descontar_tiempo:
		SHORT_SLEEP 1	
		INT_SLEEP 71, R0
		DEC timer_nota_actual ;Decremento la duración de la nota que en este frame se va a reproducir
		ret
	no_saltar_a_descontar_tiempo:

		;Si no sigue, tomo la próxima nota
		INC nota_actual	  ;Sumo uno al iterador

		;Este bloque analiza melodia_humano, y guarda en R0, R1, R2 y R3 la tabla de alturas y la tabla de duraciones
		SHORT_SLEEP 1	
		INT_SLEEP 31, R0		

cambiar_nota:
		MOV A, estado_melodia ;Para comparar el estado de la melodía
		MOV R0, #low(tabla_alturas_melodias)
		MOV R1, #high(tabla_alturas_melodias)
		call leer_tabla_w
		
		MOV R0, A
		MOV R1, B
		MOV A, nota_actual ;Guardo el iterador en A para llamar a la rutina que lee de la tabla (partitura)					  
		call leer_tabla
		
		MOV puerto_sonido, A ;Y la reproduzco
		MOV altura_nota_actual, A ;Me guardo el valor de esta nota
		CJNE A, #fin_melodia, no_detener ;Si no es la última nota
		
		MOV A, estado_melodia
		CJNE A, #melodia_final, no_final
		JMP fin_del_juego

	no_final:
		CJNE A, #melodia_empate, no_termina

	fin_del_juego:
			;;FIN DEL JUEGO		  
		;; Limpio el tablero
		mov linea_0, #0
		mov linea_1, #0
		mov linea_2, #0

		;; Muestro que el tablero se limpió
		mov enviar_lineas_serial, #3

		MOV R0, arranca
		CJNE R0, #arranca_humano, ahora_arranca_humano ;La proxima partida empieza el otro
		MOV arranca, #arranca_maquina ;Arrancará la máquina
		MOV turno, #turno_maquina
		JMP arranque_configurado
ahora_arranca_humano:
		MOV arranca, #arranca_humano  ;Arrancará el humano
		MOV turno, #turno_humano
		SHORT_SLEEP 2
arranque_configurado:

no_termina:		
		SHORT_SLEEP 1
		INT_SLEEP 17, R0
		JMP detener

no_detener:
		MOV A, estado_melodia ;Para comparar el estado de la melodía
		MOV R0, #low(tabla_duraciones_melodias)
		MOV R1, #high(tabla_duraciones_melodias)
		call leer_tabla_w
		
		MOV R0, A
		MOV R1, B
		MOV A, nota_actual ;Guardo el iterador en A para llamar a la rutina que lee de la tabla (partitura)					  
		call leer_tabla
		
		MOV timer_nota_actual, A ;La guardo en memoria
		DEC timer_nota_actual ;Decremento la duración de la nota que en este frame se va a reproducir
		ret

detener:
		MOV puerto_sonido, #silencio ;Limpio el puerto
		MOV estado_melodia, #detenida ;Guardo que la reproducción está detenida
		ret

END
