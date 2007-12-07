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
obtener_nota_melodia_humano:
	INC A
	MOVC A, @A + PC
	RET
	db nota_4, silencio, nota_4, silencio, nota_3, silencio, nota_3, silencio, nota_2, silencio, nota_2, silencio, nota_4, fin_melodia

obtener_altura_melodia_humano:
	INC A
	MOVC A, @A + PC
	RET
	db corchea, semicorchea, corchea, semicorchea, corchea, semicorchea, corchea, semicorchea, corchea, semicorchea, corchea, semicorchea, negra, fin_melodia

;Melodía cuando la máquina juega
obtener_nota_melodia_maquina:
	INC A
	MOVC A, @A + PC
	RET
	db nota_3, silencio, nota_3, silencio, nota_2, silencio, nota_2, silencio, nota_3, fin_melodia

obtener_altura_melodia_maquina:
	INC A
	MOVC A, @A + PC
	RET
	db corchea, semicorchea, corchea, semicorchea, corchea, semicorchea, corchea, semicorchea, negra, fin_melodia

;Melodía cuando se empata
obtener_nota_melodia_empate:
	INC A
	MOVC A, @A + PC
	RET
	db 	nota_4,	silencio, 	nota_3, 	silencio, 	nota_2,	fin_melodia

obtener_altura_melodia_empate:
	INC A
	MOVC A, @A + PC
	RET
	db 	corchea,	corchea,	corchea,		corchea,	blanca, fin_melodia

;Melodía cuando el juego termina
obtener_nota_melodia_final:
	INC A
	MOVC A, @A + PC
	RET
	db 	nota_2,	silencio, 	nota_2, 	silencio, 	nota_2
	db	silencio,nota_2, 	silencio, 	nota_4, 	silencio
	db	nota_3,	silencio, 	nota_3, 	silencio, 	nota_2
	db	silencio,nota_2, 	silencio, 	nota_4, 	silencio
	db	nota_4
	db 	nota_2,	silencio, 	nota_2, 	silencio, 	nota_2
	db	silencio,nota_2, 	silencio, 	nota_4, 	silencio
	db	nota_3,	silencio, 	nota_2, 	fin_melodia

obtener_altura_melodia_final:
	INC A
	MOVC A, @A + PC
	RET
	db 	negra,	corchea,	negra,		corchea,	semicorchea
	db	corchea,negra,		corchea,	negra,		semicorchea
	db	corchea,semicorchea, 	negra, 		corchea, 	corchea
	db	semicorchea,negra, 		corchea, 	corchea, 	semicorchea
	db	negra
	db 	negra,	corchea,	negra,		corchea,	semicorchea
	db	corchea,negra,		corchea,	negra,		semicorchea
	db	corchea,semicorchea,	negra,		fin_melodia

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
		JMP fin_sound_play
	no_saltar_a_fin:

		MOV R0, timer_nota_actual ;Paso la duración restante a R0 para comparar con 0
		CJNE R0, #0, saltar_a_descontar_tiempo ;Si la nota sigue, le descuento una unidad de tiempo (frame)
		JMP no_saltar_a_descontar_tiempo
	saltar_a_descontar_tiempo:
		JMP descontar_tiempo
	no_saltar_a_descontar_tiempo:

		;Si no sigue, tomo la próxima nota
		INC nota_actual	  ;Sumo uno al iterador
		
cambiar_nota:
		MOV A, estado_melodia ;Para comparar el estado de la melodía
		CJNE A, #melodia_humano, cambiar_nota_2 ;Si estoy reproduciendo melodia_humano
		MOV A, nota_actual ;Guardo el iterador en A para llamar a la rutina que lee de la tabla (partitura)					  
		call obtener_nota_melodia_humano ;Guarda en A la próxima nota
		MOV puerto_sonido, A ;Y la reproduzco
		MOV altura_nota_actual, A ;Me guardo el valor de esta nota
		CJNE A, #fin_melodia, no_detener ;Si no es la última nota
		JMP detener
no_detener:
		MOV A, nota_actual ;Guardo el iterador en A para llamar a la rutina que lee de la tabla (partitura)				
		call obtener_altura_melodia_humano ;Guarda en A la duración de la próxima nota
		MOV timer_nota_actual, A ;La guardo en memoria
		JMP descontar_tiempo;
cambiar_nota_2:
		CJNE A, #melodia_maquina, cambiar_nota_3 ;Si estoy reproduciendo melodia_maquina
		MOV A, nota_actual ;Guardo el iterador en A para llamar a la rutina que lee de la tabla (partitura)					  
		call obtener_nota_melodia_maquina ;Guarda en A la próxima nota
		MOV puerto_sonido, A ;Y la reproduzco
		MOV altura_nota_actual, A ;Me guardo el valor de esta nota
		CJNE A, #fin_melodia, no_detener_2 ;Si no es la última nota
		JMP detener
no_detener_2:
		MOV A, nota_actual ;Guardo el iterador en A para llamar a la rutina que lee de la tabla (partitura)				
		call obtener_altura_melodia_maquina ;Guarda en A la duración de la próxima nota
		MOV timer_nota_actual, A ;La guardo en memoria
		JMP descontar_tiempo
cambiar_nota_3:
		;Estoy reproduciendo melodia del final del juego
		CJNE A, #melodia_final, cambiar_nota_4 ;Si estoy reproduciendo melodia_maquina
		MOV A, nota_actual ;Guardo el iterador en A para llamar a la rutina que lee de la tabla (partitura)					  
		call obtener_nota_melodia_final ;Guarda en A la próxima nota
		MOV puerto_sonido, A ;Y la reproduzco
		MOV altura_nota_actual, A ;Me guardo el valor de esta nota
		CJNE A, #fin_melodia, no_detener_3 ;Si no es la última nota
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
arranque_configurado:

		JMP detener
no_detener_3:
		MOV A, nota_actual ;Guardo el iterador en A para llamar a la rutina que lee de la tabla (partitura)				
		call obtener_altura_melodia_final ;Guarda en A la duración de la próxima nota
		MOV timer_nota_actual, A ;La guardo en memoria
		JMP descontar_tiempo

cambiar_nota_4:
		;Estoy reproduciendo melodia de empate
		MOV A, nota_actual ;Guardo el iterador en A para llamar a la rutina que lee de la tabla (partitura)					  
		call obtener_nota_melodia_empate ;Guarda en A la próxima nota
		MOV puerto_sonido, A ;Y la reproduzco
		MOV altura_nota_actual, A ;Me guardo el valor de esta nota
		CJNE A, #fin_melodia, no_detener_4 ;Si no es la última nota
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
ahora_arranca_humano_2:
		MOV arranca, #arranca_humano  ;Arrancará el humano
		MOV turno, #turno_humano
arranque_configurado_2:

		JMP detener
no_detener_4:
		MOV A, nota_actual ;Guardo el iterador en A para llamar a la rutina que lee de la tabla (partitura)				
		call obtener_altura_melodia_empate ;Guarda en A la duración de la próxima nota
		MOV timer_nota_actual, A ;La guardo en memoria
		JMP descontar_tiempo

detener:
		MOV puerto_sonido, #silencio ;Limpio el puerto
		MOV estado_melodia, #detenida ;Guardo que la reproducción está detenida
		JMP fin_sound_play ;y salgo

		
descontar_tiempo:
		DEC timer_nota_actual ;Decremento la duración de la nota que en este frame se va a reproducir

fin_sound_play:
		ret

END
