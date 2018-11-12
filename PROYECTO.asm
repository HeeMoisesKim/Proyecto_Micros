#include "p16f887.inc"

; CONFIG1
; __config 0xE0F4
 __CONFIG _CONFIG1, _FOSC_INTRC_NOCLKOUT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _CP_OFF & _CPD_OFF & _BOREN_OFF & _IESO_OFF & _FCMEN_OFF & _LVP_OFF
; CONFIG2
; __config 0xFFFF
 __CONFIG _CONFIG2, _BOR4V_BOR40V & _WRT_OFF
	
	
;*******************************************************************************
; Reset Vector
;*******************************************************************************

RES_VECT  CODE    0x0000            ; processor reset vector
    GOTO    START                   ; go to beginning of program
    
ISR_VECT    CODE    0x0004
BOTTOM:				    
    MOVWF W_TEMP
    SWAPF STATUS,W
    MOVWF STATUS_TEMP
NANANA:
    BTFSS PIR1,5
    GOTO  POP
    MOVF  RCREG,0
    MOVWF HOLA
    ANDLW B'11111111'
    BTFSC STATUS,Z
    GOTO  CAMBIO
    BTFSS ESTADO2,0
    GOTO  POP
    MOVF  HOLA,0
    MOVWF PROBAR
    RRF   PROBAR,1
    RRF   PROBAR,1
    RRF   PROBAR,1
    RRF   PROBAR,1
    RRF   PROBAR,1
    RRF   PROBAR,0
    ANDLW B'00000011'
    ADDWF PCL,1
    GOTO  SERIAL_1
    GOTO  SERIAL_2
    GOTO  SERIAL_3
    GOTO  SERIAL_4
SALIR_SERIAL
    MOVLW B'00001111'
    MOVWF TXREG
POP:				    
    SWAPF STATUS_TEMP,W
    MOVWF STATUS
    SWAPF W_TEMP,F
    SWAPF W_TEMP,W
    RETFIE

    
    
GPR_VAR	    UDATA
CHAN_5	    RES	    1
CHAN_6	    RES	    1
CHAN_2	    RES	    1
CHAN_3	    RES	    1
VALOR	    RES	    1
PROBAR	    RES	    1
W_TEMP	    RES	    1
STATUS_TEMP RES	    1
ESTADO	    RES	    1
PERIODO1    RES	    1
PERIODO2    RES	    1
PERIODO3    RES	    1
PERIODO4    RES	    1
PERIODO5    RES	    1
PERIODO6    RES	    1
PERIODO7    RES	    1
PERIODO8    RES	    1
CCPR3L	    RES	    1
CCPR4L	    RES	    1
HOLA	    RES	    1
ESTADO2	    RES	    1
;*******************************************************************************
; MAIN PROGRAM
;*******************************************************************************

MAIN_PROG CODE                      ; let linker place main program

START    
SETUP
    BANKSEL PORTA
    MOVLW   D'255'
    MOVWF   PR2
    CLRF    CCPR1L
    MOVLW   B'00111100'
    MOVWF   CCP1CON
    CLRF    CCPR2L
    MOVLW   B'00001111'
    MOVWF   CCP2CON
    CLRF    PORTE
    CLRF    PORTC
    MOVLW   B'01010101'
    MOVWF   ADCON0
    MOVLW   B'11000000'
    MOVWF   INTCON
    
    BANKSEL TRISA
    CLRF    TRISE
    BSF	    TRISE,0
    BSF	    TRISE,1
    CLRF    TRISC
    CLRF    ADCON1
    MOVLW   B'01001100'
    MOVWF   OSCCON	    ;1000 kHz
    ;BCF	    PIE1,1
    ;BCF	    PIE1,2
    BSF	    PIE1,5
    
    BANKSEL PORTC
    MOVLW   B'00000110'
    MOVWF   T2CON
    
    BANKSEL ANSEL
    CLRF    ANSEL
    BSF	    ANSEL,5
    BSF	    ANSEL,6
    BSF	    ANSEL,2
    BSF	    ANSEL,3
    
    BANKSEL PORTA
    CLRF    ESTADO
    CLRF    PERIODO1
    CLRF    PERIODO2
    CLRF    PORTE
    CLRF    PORTC
    CALL    DELAY
    CALL    UART

LOOP
    BTFSS   ESTADO2,0
    GOTO    LOOP_ADC
    GOTO    LOOP_SERIAL
    

LOOP_ADC
    BSF	    ADCON0,GO
LOOP2
    BTFSS   PIR1,4
    GOTO    LOOP3
    MOVF    CHAN_5,0
    MOVWF   TXREG
LOOP3
;    BTFSS   PIR1,5
;    GOTO    LOOP4
;    MOVF    RCREG,0
;    MOVWF   HOLA
LOOP4
    BTFSS   PIR1,1
    GOTO    LOOP5
    BCF	    PIR1,1
    CALL    HIGH_SERVO3
    CALL    HIGH_SERVO4
LOOP5
    CALL    SERVO_1
    CALL    SERVO_2
    CALL    SERVO_3
    CALL    SERVO_4
    BTFSC   ADCON0,GO
    GOTO    LOOP2
    MOVF    ESTADO,0
    ADDWF   PCL,1
    GOTO    CANAL2
    GOTO    CANAL5
    GOTO    CANAL3
    GOTO    CANAL6
    GOTO    LOOP    
 
LOOP_SERIAL
    CLRF    HOLA
    MOVF    RCREG,0   
CANAL2
    INCF    ESTADO,1
    MOVF    ADRESH,0
    MOVWF   CHAN_2
    CALL    CANAL_5
    GOTO LOOP 
CANAL5
    MOVF    ADRESH,0
    MOVWF   CHAN_5
    CALL    CANAL_3
    INCF    ESTADO,1
    GOTO    LOOP
CANAL3
    INCF    ESTADO,1
    MOVF    ADRESH,0
    MOVWF   CHAN_3
    CALL    CANAL_6
    GOTO    LOOP
CANAL6
    CLRF    ESTADO
    MOVF    ADRESH,0
    MOVWF   CHAN_6
    CALL    CANAL_2
    GOTO LOOP     
    
CANAL_5:
    BCF	    ADCON0,5
    BSF	    ADCON0,4
    BCF	    ADCON0,3
    BSF	    ADCON0,2
    CALL    DELAY
    RETURN
CANAL_6:
    BCF	    ADCON0,5
    BSF	    ADCON0,4
    BSF	    ADCON0,3
    BCF	    ADCON0,2
    CALL    DELAY
    RETURN
CANAL_2:
    BCF	    ADCON0,5
    BCF	    ADCON0,4
    BSF	    ADCON0,3
    BCF	    ADCON0,2
    CALL    DELAY
    RETURN
CANAL_3:
    BCF	    ADCON0,5
    BCF	    ADCON0,4
    BSF	    ADCON0,3
    BSF	    ADCON0,2
    CALL    DELAY
    RETURN
    
SERVO_1:
    MOVF    CHAN_5,0
    MOVWF   PROBAR
    RRF	    PROBAR,0
    ANDLW   B'01111111'
    MOVWF   CCPR1L
    RETURN  
SERVO_2:
    MOVF    CHAN_6,0
    MOVWF   PROBAR
    RRF	    PROBAR,0
    ANDLW   B'01111111'
    MOVWF   CCPR2L
    RETURN
SERVO_3:
    MOVF    CHAN_2,0
    MOVWF   PROBAR
    ANDLW   B'11111111'
    MOVWF   CCPR3L  
    RETURN
SERVO_4:
    MOVF    CHAN_3,0
    MOVWF   PROBAR
    ANDLW   B'11111111'
    MOVWF   CCPR4L
    RETURN

    
    
HIGH_SERVO3:
    BSF	    PORTC,0
    DECFSZ  CCPR3L
    GOTO    $-1
    BCF	    PORTC,0
    RETURN
    
HIGH_SERVO4:
    BSF	    PORTC,3
    DECFSZ  CCPR4L
    GOTO    $-1
    BCF	    PORTC,3
    RETURN
    
DELAY
    MOVLW   .100
    MOVWF   PROBAR
    DECFSZ  PROBAR,1
    GOTO    $-1
    RETURN
 
CAMBIO
    BTFSC   ESTADO2,0
    GOTO    CAMBIO1
    BSF	    ESTADO2,0
    GOTO    POP
CAMBIO1
    BCF	    ESTADO2,0
    GOTO    POP

SERIAL_1
    MOVF    HOLA,0
    ANDLW   B'00111111'
    MOVWF   CCPR1L
    GOTO    SALIR_SERIAL
SERIAL_2
    MOVF    HOLA,0
    ANDLW   B'00111111'
    MOVWF   CCPR2L
    GOTO    SALIR_SERIAL
SERIAL_3
    MOVF    HOLA,0
    ANDLW   B'00111111'
    MOVWF   CCPR3L
    GOTO    SALIR_SERIAL
SERIAL_4
    MOVF    HOLA,0
    ANDLW   B'00111111'
    MOVWF   CCPR4L
    GOTO    SALIR_SERIAL
UART    
    BANKSEL TXSTA
    BCF	    TXSTA, SYNC		    ; ASINCRÓNO
    BSF	    TXSTA, BRGH		    ; HIGH SPEED
    BANKSEL BAUDCTL
    BSF	    BAUDCTL, BRG16		    ; 16 BITS BAURD RATE GENERATOR
    BANKSEL SPBRG
    MOVLW   .25	    
    MOVWF   SPBRG			    ; CARGAMOS EL VALOR DE BAUDRATE CALCULADO
    CLRF    SPBRGH
    BANKSEL RCSTA
    BSF	    RCSTA, SPEN		    ; HABILITAR SERIAL PORT
    BCF	    RCSTA, RX9		    ; SOLO MANEJAREMOS 8BITS DE DATOS
    BSF	    RCSTA, CREN		    ; HABILITAMOS LA RECEPCIÓN 
    BANKSEL TXSTA
    BSF	    TXSTA, TXEN		    ; HABILITO LA TRANSMISION
    
    
    BCF STATUS, RP0
    BCF STATUS, RP1		    ; BANCO 0
    RETURN
    END