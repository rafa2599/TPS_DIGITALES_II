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

;*** Subrutinas ***
		
;===========================================================

;===========================================================		
BLINKING	MOVLW   b'11111111' ; Carga el valor binario con 8 unos 
                MOVWF   PORTD       ; Pasa esos unos al Puerto D (Enciende todos)
		CALL	DELAY_1s
		MOVLW	b'00000000'
		MOVWF   PORTD       ; Pone los 8 bits de PORTD en 0 (Apaga todos)
		CALL	DELAY_1s
                RETURN
;===========================================================

;===========================================================
BLINK_RL    ; Secuencia manual RD0 a RD7
            MOVLW   b'00000001'
            MOVWF   PORTD
            CALL    DELAY_300ms
            MOVLW   b'00000010'
            MOVWF   PORTD
            CALL    DELAY_300ms
            MOVLW   b'00000100'
            MOVWF   PORTD
            CALL    DELAY_300ms
            MOVLW   b'00001000'
            MOVWF   PORTD
            CALL    DELAY_300ms
            MOVLW   b'00010000'
            MOVWF   PORTD
            CALL    DELAY_300ms
            MOVLW   b'00100000'
            MOVWF   PORTD
            CALL    DELAY_300ms
            MOVLW   b'01000000'
            MOVWF   PORTD
            CALL    DELAY_300ms
            MOVLW   b'10000000'
            MOVWF   PORTD
            CALL    DELAY_300ms
            RETURN
;===========================================================

;===========================================================	
BLINK_BRL   ; Efecto de Barrido Bidireccional (Ida y Vuelta) a 200ms
            
            ; --- IDA (Izquierda a Derecha: RD0 -> RD7) ---
            MOVLW   b'00000001'     ; Enciende LED 0
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            MOVLW   b'00000010'     ; Enciende LED 1
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            MOVLW   b'00000100'     ; Enciende LED 2
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            MOVLW   b'00001000'     ; Enciende LED 3
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            MOVLW   b'00010000'     ; Enciende LED 4
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            MOVLW   b'00100000'     ; Enciende LED 5
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            MOVLW   b'01000000'     ; Enciende LED 6
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            MOVLW   b'10000000'     ; Enciende LED 7 (Punto de rebote)
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            ; --- VUELTA (Derecha a Izquierda: RD6 -> RD1) ---
            
            MOVLW   b'01000000'     ; Enciende LED 6
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            MOVLW   b'00100000'     ; Enciende LED 5
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            MOVLW   b'00010000'     ; Enciende LED 4
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            MOVLW   b'00001000'     ; Enciende LED 3
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            MOVLW   b'00000100'     ; Enciende LED 2
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            MOVLW   b'00000010'     ; Enciende LED 1
            MOVWF   PORTD
            CALL    DELAY_200ms
            
            RETURN

;===========================================================
	    
;===========================================================
BLINK_CRAW  ; Efecto de Arrastre (Crawling) a 100ms
            
            MOVLW   b'00000001'     ; Enciende RD0
            MOVWF   PORTD
            CALL    DELAY_100ms
            
            MOVLW   b'00000011'     ; Mantiene RD0 y enciende RD1
            MOVWF   PORTD
            CALL    DELAY_100ms
            
            MOVLW   b'00000111'     ; Enciende hasta RD2
            MOVWF   PORTD
            CALL    DELAY_100ms
            
            MOVLW   b'00001111'     ; Enciende hasta RD3
            MOVWF   PORTD
            CALL    DELAY_100ms
            
            MOVLW   b'00011111'     ; Enciende hasta RD4
            MOVWF   PORTD
            CALL    DELAY_100ms
            
            MOVLW   b'00111111'     ; Enciende hasta RD5
            MOVWF   PORTD
            CALL    DELAY_100ms
            
            MOVLW   b'01111111'     ; Enciende hasta RD6
            MOVWF   PORTD
            CALL    DELAY_100ms
            
            MOVLW   b'11111111'     ; Enciende TODOS (RD0 a RD7)
            MOVWF   PORTD
            CALL    DELAY_100ms
            
            ; Para que el arrastre se note al repetir el ciclo, 
            ; apagamos todo por 100ms antes de volver a empezar.
            CLRF    PORTD
            CALL    DELAY_100ms
            
            RETURN
;===========================================================

;===========================================================		
BUCLE_RL    MOVLW   .3
	    MOVWF   CONT_RL
	    RETURN
	    
BUCLE_BRL   MOVLW   .3
	    MOVWF   CONT_BRL
	    RETURN
	    
BUCLE_CRAW  MOVLW   .3
	    MOVWF   CONT_CRAW
	    RETURN
;===========================================================

;===========================================================		
DELAY_1s        MOVFW   DELAY1_Init
                MOVWF   DELAY1
		
LOOP1           MOVFW   DELAY2_Init
                MOVWF   DELAY2
		
LOOP2           MOVFW   DELAY3_Init
                MOVWF   DELAY3
		
LOOP3           DECFSZ  DELAY3,F
                GOTO    LOOP3
		
                DECFSZ  DELAY2,F
                GOTO    LOOP2
		
                DECFSZ  DELAY1,F
                GOTO    LOOP1	
		
		RETURN 
;===========================================================

;===========================================================		
DELAY_300ms     MOVFW   DELAY4_Init
                MOVWF   DELAY4
		
LOOP4           MOVFW   DELAY5_Init
                MOVWF   DELAY5
		
LOOP5           MOVFW   DELAY6_Init
                MOVWF   DELAY6
		
LOOP6           DECFSZ  DELAY6,F
                GOTO    LOOP6
		
                DECFSZ  DELAY5,F
                GOTO    LOOP5
		
                DECFSZ  DELAY4,F
                GOTO    LOOP4	
		
		RETURN 
;===========================================================
		
;===========================================================
DELAY_200ms     MOVFW   DELAY7_Init
                MOVWF   DELAY7
        
LOOP7           MOVFW   DELAY8_Init
                MOVWF   DELAY8
        
LOOP8           MOVFW   DELAY9_Init
                MOVWF   DELAY9
        
LOOP9           DECFSZ  DELAY9,F
                GOTO    LOOP9
        
                DECFSZ  DELAY8,F
                GOTO    LOOP8
        
                DECFSZ  DELAY7,F
                GOTO    LOOP7   
        
                RETURN  
;===========================================================
		
;===========================================================
        
DELAY_100ms     MOVFW   DELAY10_Init
                MOVWF   DELAY10
        
LOOP10          MOVFW   DELAY11_Init
                MOVWF   DELAY11
        
LOOP11          MOVFW   DELAY12_Init
                MOVWF   DELAY12
        
LOOP12          DECFSZ  DELAY12,F
                GOTO    LOOP12
        
                DECFSZ  DELAY11,F
                GOTO    LOOP11
        
                DECFSZ  DELAY10,F
                GOTO    LOOP10  
        
                RETURN  
;===========================================================	

;===========================================================
LEDS_OFF     
                CLRF    PORTD      ; Pone los 8 bits de PORTD en 0 (Apaga todos)
                RETURN              

                END
