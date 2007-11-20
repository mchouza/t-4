;;;; T^4 para 66.09 Laboratorio de Microcomputadoras
;;;; Por Mariano Beir� y Mariano Chouza
;;;; M�dulo de sonido (SOUND)
;;;; Se encarga de reproducir una melodia

$INCLUDE(macros.inc)		; Macros de prop�sito general
$INCLUDE(constantes.inc)	; Constantes de utilidad general

NAME SOUND

;;; Segmento propio de este m�dulo
SOUND_SEG SEGMENT CODE

;;; Importa
$INCLUDE(variables.inc)		; Variables compartidas a nivel global

;;; Exporta solo la funci�n de inicializaci�n y la de reproduccion
PUBLIC sound_init, sound_play

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


;Melod�a cuando el humano juega
obtener_nota_melodia_humano:
	INC A
	MOVC A, @A + PC
	RET
	db nota_1, 	nota_2,	nota_3,	silencio,	nota_1,	nota_2,	nota_3,	fin_melodia

obtener_altura_melodia_humano:
	INC A
	MOVC A, @A + PC
	RET
	db negra, 	negra, 	blanca,	blanca,		negra, 	negra, 	blanca,	fin_melodia

;Melod�a cuando la m�quina juega
obtener_nota_melodia_maquina:
	INC A
	MOVC A, @A + PC
	RET
	db nota_1, 	nota_2,	nota_3,	silencio,	nota_1,	nota_2,	nota_3,	fin_melodia

obtener_altura_melodia_maquina:
	INC A
	MOVC A, @A + PC
	RET
	db negra, 	negra, 	blanca,	blanca,		negra, 	negra, 	blanca,	fin_melodia

;Melod�a cuando el juego termina
obtener_nota_melodia_final:
	INC A
	MOVC A, @A + PC
	RET
	db nota_1, 	nota_2,	nota_3,	silencio,	nota_1,	nota_2,	nota_3,	fin_melodia

obtener_altura_melodia_final:
	INC A
	MOVC A, @A + PC
	RET
	db negra, 	negra, 	blanca,	blanca,		negra, 	negra, 	blanca,	fin_melodia

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
		JZ fin_sound_play ;Si no hay que reproducir nada, salgo
		
		MOV R0, timer_nota_actual ;Paso la duraci�n restante a R0 para comparar con 0
		CJNE R0, #0, descontar_tiempo ;Si la nota sigue, le descuento una unidad de tiempo (frame)

		;Si no sigue, tomo la pr�xima nota
		INC nota_actual	  ;Sumo uno al iterador
		
cambiar_nota:
		MOV A, estado_melodia ;Para comparar el estado de la melod�a
		CJNE A, #melodia_humano, cambiar_nota_2 ;Si estoy reproduciendo melodia_humano
		MOV A, nota_actual ;Guardo el iterador en A para llamar a la rutina que lee de la tabla (partitura)					  
		call obtener_nota_melodia_humano ;Guarda en A la pr�xima nota
		MOV puerto_sonido, A ;Y la reproduzco
		MOV altura_nota_actual, A ;Me guardo el valor de esta nota
		CJNE A, #fin_melodia, no_detener ;Si no es la �ltima nota
		JMP detener
no_detener:
		call obtener_altura_melodia_humano ;Guarda en A la duraci�n de la pr�xima nota
		MOV timer_nota_actual, A ;La guardo en memoria
		JMP descontar_tiempo;
cambiar_nota_2:
		MOV A, estado_melodia ;Para comparar el estado de la melod�a
		CJNE A, #melodia_maquina, cambiar_nota_3 ;Si estoy reproduciendo melodia_maquina
		MOV A, nota_actual ;Guardo el iterador en A para llamar a la rutina que lee de la tabla (partitura)					  
		call obtener_nota_melodia_maquina ;Guarda en A la pr�xima nota
		MOV puerto_sonido, A ;Y la reproduzco
		MOV altura_nota_actual, A ;Me guardo el valor de esta nota
		CJNE A, #fin_melodia, no_detener_2 ;Si no es la �ltima nota
		JMP detener
no_detener_2:
		call obtener_altura_melodia_maquina ;Guarda en A la duraci�n de la pr�xima nota
		MOV timer_nota_actual, A ;La guardo en memoria
		JMP descontar_tiempo
cambiar_nota_3:
		;Estoy reproduciendo melodia del final del juego
		MOV A, estado_melodia ;Para comparar el estado de la melod�a
		call obtener_nota_melodia_final ;Guarda en A la pr�xima nota
		MOV A, nota_actual ;Guardo el iterador en A para llamar a la rutina que lee de la tabla (partitura)					  
		MOV puerto_sonido, A ;Y la reproduzco
		MOV altura_nota_actual, A ;Me guardo el valor de esta nota
		CJNE A, #fin_melodia, no_detener_3 ;Si no es la �ltima nota
		JMP detener
no_detener_3:
		call obtener_altura_melodia_final ;Guarda en A la duraci�n de la pr�xima nota
		MOV timer_nota_actual, A ;La guardo en memoria
		JMP descontar_tiempo

detener:
		MOV puerto_sonido, #silencio ;Limpio el puerto
		MOV estado_melodia, #detenida ;Guardo que la reproducci�n est� detenida
		JMP fin_sound_play ;y salgo

		
descontar_tiempo:
		DEC timer_nota_actual ;Decremento la duraci�n de la nota que en este frame se va a reproducir

fin_sound_play:
		ret

END
