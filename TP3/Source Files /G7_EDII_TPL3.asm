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

