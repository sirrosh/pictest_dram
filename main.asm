list	p=16f648a
radix dec
#include "p16f648a.inc"
;__CONFIG   _CP_OFF & _CPD_OFF & _WDT_OFF & _PWRTE_ON & _INTRC_OSC_NOCLKOUT & _MCLRE_OFF & _LVP_OFF
__CONFIG   _CP_OFF & _CPD_OFF & _WDT_OFF & _PWRTE_ON & _HS_OSC & _MCLRE_OFF & _LVP_OFF

#define RAS	PORTA, 0
#define CAS	PORTA, 1
#define DI	PORTA, 2
#define DO	PORTA, 5
#define WE	PORTA, 3
#define LED	PORTA, 4

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
    NOP
    MOVFW  PORTA        ; reading value
    BSF    CAS          ; and holding everything up again
    BSF    RAS

    endm


VARS CBLOCK 0x20
    i_cycle
    column
    row
    ENDC

RES_VECT CODE    0x0000        ; processor reset vector
    NOP                        ; for ICD
    GOTO   START               ; let's start

INT_VECT CODE    0x0004        ; interrupt vector stub
    RETFIE

START
;=== Initializing the MCU ===
    banksel TRISB
    CLRF   TRISB               ; port B to output
    BCF    RAS                 ; configure outputs
    BCF    CAS
    BCF    WE
    BCF    DI
    BSF    DO
    BCF    LED
    banksel CMCON
    MOVLW  0x07
    MOVWF  CMCON               ; turning comparator off

    BSF    RAS                 ; setting up the signals
    BSF    CAS
    BSF    WE
    CLRF   column
    CLRF   row

;=== Here goes the purpose ===
ONCEMORE
;== trying to write and read back 1
    MOVFW  row
    write1 column
    MOVFW  row
    readm  column
    ANDLW  00100000b           ; leave only input value
    BTFSC  STATUS, Z
    GOTO   BADDATA             ; should be 1 instead of 0
    BSF    LED                 ; turn on LED if there was 1
;== trying to write and read back 0
    MOVFW  row
    write0 column
    MOVFW  row
    readm  column
    ANDLW  00100000b           ; leave only input value
    BTFSS  STATUS, Z
    GOTO   BADDATA             ; should be 0 instead of 1
    BCF    LED                 ; turn off LED if there was 0
    INCFSZ row
    GOTO   ONCEMORE
    INCF   column
    GOTO   ONCEMORE


BADDATA
    GOTO   $                   ; just hang there for now, LED port holds errorneous data



    END
