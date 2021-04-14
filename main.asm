list	p=16f648a
radix dec
#include "p16f648a.inc"
;__CONFIG   _CP_OFF & _CPD_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT & _MCLRE_OFF & _LVP_OFF
__CONFIG   _CP_OFF & _CPD_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC & _MCLRE_OFF & _LVP_OFF

#define RAS	PORTA, 0
#define CAS	PORTA, 1
#define DI	PORTA, 2
#define DO	PORTA, 4
#define WE	PORTA, 3

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
    endm

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

readm macro col_addr    ; row address is expected in W, result returns in W
    MOVWF  PORTB        ; outputting row  address
    BCF    RAS          ; starting to hold RAS low
    MOVFW  col_addr     ; serves as RAS-to-CAS delay
    MOVWF  PORTB        ; outputting col address
    BCF    CAS          ; holding CAS
    MOVFW  PORTA        ; reading value
    BSF    CAS          ; and holding everything up again
    BSF    RAS

    endm


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
    banksel CMCON
    MOVLW  0x07
    MOVWF  CMCON		; turning comparator off

    BSF    RAS
    BSF    CAS
    BSF    WE
    CLRF   column
NEXTCOL
    MOVLW  0xFF
    MOVWF  i_cycle
    write1 column
    MOVLW  0xFF
    readm  column
NEXTROW
    MOVFW  i_cycle
    write0 column
    DECFSZ i_cycle
    GOTO   NEXTROW
    INCF   column
    GOTO   NEXTCOL




    END
