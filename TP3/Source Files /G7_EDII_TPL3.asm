; @file Trabajo Práctico N° 3 ~ Electronica Digitales II
; @author Rafael Fariñas
; @version 4.0 (Blinking + Multiplexing)
    
LIST P = 16F887
#include "p16f887.inc"

__CONFIG _CONFIG1, _XT_OSC & _WDTE_OFF & _PWRTE_ON & _MCLRE_ON & _LVP_OFF

CBLOCK  0x20
    D_VAR1, D_VAR2, D_VAR3      ; Variables de tiempo
    CONT_WAIT                   ; Contador de los 10 parpadeos
    CONT_REFRESCO               ; Contador para los 300ms de multiplexado
ENDC

; --- MACROS ---
CFG_PORTd   MACRO 
    BANKSEL TRISD
    MOVLW   B'10000000'     
    MOVWF   TRISD           
    BANKSEL PORTD
    MOVLW   0xFF            ; Todo apagado al inicio
    MOVWF   PORTD           
    ENDM

CFG_PORTa   MACRO 
    BANKSEL TRISA
    CLRF    TRISA           ; RA0-RA3 como salidas
    BANKSEL ANSEL
    CLRF    ANSEL           ; Digital
    BANKSEL PORTA
    MOVLW   0xFF            ; PNPs apagados (Lógica negativa)
    MOVWF   PORTA
    ENDM

DO_DELAY    MACRO v1, v2, v3
    MOVLW   v1
    MOVWF   D_VAR1
    MOVLW   v2
    MOVWF   D_VAR2
    MOVLW   v3
    MOVWF   D_VAR3
    CALL    DELAY_MASTER
    ENDM

    ORG 0X00
    GOTO    INICIO

; --- PROGRAMA PRINCIPAL ---
INICIO
    CFG_PORTd
    CFG_PORTa
    
    MOVLW   .10
    MOVWF   CONT_WAIT       ; Vamos a parpadear 10 veces

BUCLE_BLINK
    ; --- FASE: ENCENDIDO (Multiplexado rápido durante 300ms) ---
    MOVLW   .11             ; 11 repeticiones * 28ms = ~308ms de luz
    MOVWF   CONT_REFRESCO
    
    MOVLW   B'10111111'     ; Segmento G (Bit 6 en 0)
    MOVWF   PORTD
    
