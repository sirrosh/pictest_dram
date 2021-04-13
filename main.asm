list	p=16f648a
radix dec
#include "p16f648a.inc"
__CONFIG   _CP_OFF & _CPD_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT & _MCLRE_OFF & _LVP_OFF

#define RAS	PORTA, 0
#define CAS	PORTA, 1
#define DI	PORTA, 2
#define DO	PORTA, 3
#define WE  PORTA, 4

VARS CBLOCK 0x20
    i_cycle
    column
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
    BCF    WE
    BCF    DI
    BSF    DO
    banksel PORTB
    MOVLW  0x07
    MOVWF  CMCON		; turning comparator off
    
    BSF    RAS
    BSF    CAS
    BSF    WE
    CLRF   coulmn
NEXTCOL
    MOVLW  0xFF
    MOVWF  i_cycle
NEXTROW
    MOVFW  i_cycle
    write0 column
    DECFSZ i_cycle
    GOTO   NEXTROW
    INCF   column
    GOTO   NEXTCOL


write0 macro col_addr   ; row address is expected in W
    MOVWF  PORTB        ; outputting row  address
    BCF    RAS          ; starting to hold RAS low
    BCF    WE           ; holding WE low, serves as RAS-to-CAS delay
    MOVFW  col_addr
    BCF    DI           ; putting "0" on data line
    MOVWF  PORTB        ; outputting col address
    BCF    CAS          ; holding CAS
    
    BSF    WE           ; finishing write
    BSF    CAS          ; and holding everything up again
    BSF    RAS
 
 write1 macro col_addr   ; row address is expected in W
    MOVWF  PORTB        ; outputting row  address
    BCF    RAS          ; starting to hold RAS low
    BCF    WE           ; holding WE low, serves as RAS-to-CAS delay
    MOVFW  col_addr
    BSF    DI           ; putting "1" on data line
    MOVWF  PORTB        ; outputting col address
    BCF    CAS          ; holding CAS
    
    BSF    WE           ; finishing write
    BSF    CAS          ; and holding everything up again
    BSF    RAS

 
    endm
    

    END
