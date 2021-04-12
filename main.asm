list	p=16f648a
radix dec
#include "p16f648a.inc"
__CONFIG   _CP_OFF & _CPD_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT & _MCLRE_OFF & _LVP_OFF

#define RAS	PORTA, 0
#define CAS	PORTA, 1
#define DI	PORTA, 2
#define DO	PORTA, 3

VARS CBLOCK 0x20
    i_cycle
    ENDC

RES_VECT CODE    0x0000          ; processor reset vector
    NOP                             ; for ICD
    GOTO   START               ; let's start

INT_VECT CODE    0x0004		; interrupt vector stub
    RETFIE

START
    banksel TRISB
    CLRF   TRISB                ; port B to output
    BCF    RAS			; configure outputs
    BCF    CAS
    BCF    DI
    BSF    DO
    banksel PORTB
    MOVLW  0x07
    MOVWF  CMCON		; turning comparator off





    END
