LIST P=PIC18F4321   F=INHX32
#include <p18f4321.inc>

    CONFIG OSC=INTIO2	    
    CONFIG PBADEN=DIG	    ;PORTB com a Digital (el posem a 0)
    CONFIG WDT=OFF	    ;Desactivem el Watch Dog Timer
    CONFIG LVP=OFF	    ;Evitar resets eusart
;--------------------------------DECLARACIO_VARS--------------------------------
SEVEN_SEG_C EQU 0X00
SEVEN_SEG_D EQU 0X01
SEVEN_SEG_E EQU 0X02
SEVEN_SEG_F EQU 0X03
SEVEN_SEG_G EQU 0X04
SEVEN_SEG_A EQU 0X05
SEVEN_SEG_B EQU 0X06
SEVEN_SEG_c EQU 0X07
;-------------------------------------INITS-------------------------------------
    ORG 0x000
    GOTO MAIN
    ORG 0x008
    GOTO HIGH_RSI
    ORG 0x018
    RETFIE FAST

HIGH_RSI
    RETFIE FAST
    
INIT_PORTS
    CLRF TRISD,0
    CLRF LATD,0
    MOVLW b'11000000'
    MOVWF TRISC,0
    CLRF LATC,0    
    RETURN
    
INIT_VARS
    MOVLW b'00110011'
    MOVWF SEVEN_SEG_C,0
    MOVLW b'01001111'
    MOVWF SEVEN_SEG_D,0
    MOVLW b'00111011'
    MOVWF SEVEN_SEG_E,0
    MOVLW b'00111001'
    MOVWF SEVEN_SEG_F
    MOVLW b'01111110'
    MOVWF SEVEN_SEG_G
    MOVLW b'01111101'
    MOVWF SEVEN_SEG_A
    MOVLW b'00011111'
    MOVWF SEVEN_SEG_B
    MOVLW b'00001011'
    MOVWF SEVEN_SEG_c
    RETURN
    
CANVIA_ESTAT_LED
    MOVFF SEVEN_SEG_c, LATD
    RETURN
    
;--------------------------------------MAIN-------------------------------------
MAIN
    CALL INIT_PORTS
    CALL INIT_VARS
    ;CALL INIT_OSC
    ;CALL INIT_EUSART
    ;CALL INIT_INTCONS
    ;CALL INIT_TIMER
    ;CALL CARREGA_TIMER
    ;CALL INIT_ADCON

LOOP_MAIN
	CALL CANVIA_ESTAT_LED
	GOTO LOOP_MAIN
    END
    
;-----------------------------------FUNCIONS------------------------------------
