; @file Trabajo Práctico N° 2 ~ Electronica Digitales II
; @brief
; @detalis Implementacion para PIC16F887 en MPLAB X com MPASM
; @author Rafael Fariñas
; @version 1.0
; @fecha : 3/4/2026
    
; DIRECTIVAS DE INCLUSION 
LIST P = 16F887
#include "p16f887.inc"
;**** Configuración General ****
__CONFIG _CONFIG1, _XT_OSC & _WDTE_OFF & _MCLRE_ON & _LVP_OFF

CBLOCK  0x20
	; VARIABLES PARA RETARDO 1s
        DELAY1_Init
        DELAY2_Init
        DELAY3_Init
        DELAY1
        DELAY2
        DELAY3
	; VARIABLES PARA RETARDO 300ms
	DELAY4_Init
	DELAY5_Init
	DELAY6_Init
	DELAY4
	DELAY5
	DELAY6
	; VARIABLES PARA RETARDO 200ms
	DELAY7_Init
	DELAY8_Init
	DELAY9_Init
	DELAY7
	DELAY8
	DELAY9
	; VARIABLES PARA RETARDO 100ms
	DELAY10_Init
	DELAY11_Init
	DELAY12_Init
	DELAY10
	DELAY11
	DELAY12
	; CONTADORES PARA LEDS PARA REPETIR PATRONES 3 VECES C/U
	CONT_RL
	CONT_BRL
	CONT_CRAW
ENDC
;*** Declaración de Macros para Configuración de Registros ***
CFG_LEDS         MACRO
                BANKSEL TRISD
                CLRF    TRISD       ; Configura TODOS los pines de PORTD como salidas (0)
                BANKSEL PORTD
                CLRF    PORTD       ; Apaga TODOS los LEDs de PORTD poniéndolos en 0
                ENDM
		
CFG_SWITCH      MACRO
                BANKSEL TRISE		;Nos situamos en el registro TRISE
                BSF     TRISE, TRISE0   ; Pone el bit 0 de TRISE en 1 (RE0 como Entrada)
                
                BANKSEL ANSEL		;Nos  situamos en el registro ANSEL
                BCF     ANSEL, ANS5     ; Pone el bit 5 de ANSEL en 0 (ANS5 como Digital)
		BANKSEL PORTE
                ENDM
		
CFG_DELAY_1s    MACRO
                MOVLW   D'255'
                MOVWF   DELAY1_Init
                MOVLW   D'245'
                MOVWF   DELAY2_Init
                MOVLW   D'4'
                MOVWF   DELAY3_Init
                ENDM
		
CFG_DELAY_300ms MACRO
		MOVLW	.120
		MOVWF	DELAY4_Init
		MOVLW	.39
		MOVWF	DELAY5_Init
		MOVLW	.20
		MOVWF	DELAY6_Init
		ENDM

CFG_DELAY_200ms MACRO
		MOVLW	.80
		MOVWF	DELAY7_Init
		MOVLW	.39
		MOVWF	DELAY8_Init
		MOVLW	.20
		MOVWF	DELAY9_Init
		ENDM
		
CFG_DELAY_100ms MACRO
                MOVLW   .8
                MOVWF   DELAY10_Init
                MOVLW   .125
                MOVWF   DELAY11_Init
                MOVLW   .32
                MOVWF   DELAY12_Init
                ENDM	
;*** Inicialización del MCU ***
                ORG     0x00
                GOTO    INICIO
                ORG     0x05

;*** Inicialización de Registros ***
INICIO          CFG_LEDS
				CFG_SWITCH
                CFG_DELAY_1s
			CFG_DELAY_300ms
			CFG_DELAY_200ms
			CFG_DELAY_100ms
;*** Programa Principal ***

LOOP        
            BTFSC   PORTE, RE0      ; ¿Botón suelto? (Pull-up = 1)
            GOTO    MODO_BLINK      ; Si es 1 (suelto), hace parpadeo
            GOTO    MODO_SECUENCIA  ; Si es 0 (presionado), va a la secuencia indefinida

MODO_BLINK
            CALL    BLINKING
            GOTO    LOOP            ; Vuelve a leer el botón

MODO_SECUENCIA
            ; --- 1. RUNNING LIGHT (3 repeticiones) ---
            CALL    BUCLE_RL
REPITE_PATRON_RL    
            CALL    BLINK_RL        
            DECFSZ  CONT_RL, F      
            GOTO    REPITE_PATRON_RL

            ; --- 2. BIDIRECTIONAL RUNNING LIGHT (3 repeticiones) ---
            CALL    BUCLE_BRL
REPITE_PATRON_BRL
            CALL    BLINK_BRL
            DECFSZ  CONT_BRL,F
            GOTO    REPITE_PATRON_BRL

            ; --- 3. CRAWLING (3 repeticiones) ---
            CALL    BUCLE_CRAW
REPITE_PATRON_CRAW
            CALL    BLINK_CRAW
            DECFSZ  CONT_CRAW,F
            GOTO    REPITE_PATRON_CRAW

            ; --- BUCLE INDEFINIDO DE SECUENCIAS ---
            ; Una vez terminados los 3 efectos, vuelve a chequear el sw
            GOTO    LOOP
