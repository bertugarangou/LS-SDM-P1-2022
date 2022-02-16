LIST P=PIC18F4321   F=INHX32
#include <p18f4321.inc>

    CONFIG OSC=HSPLL	    ;16MHz
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

CONFIG_PORTS
    BSF TRISB, 0, 0  ;Pols1 entrada
    BSF TRISB, 1, 0  ;Pols2 entrada
    BSF TRISB, 2, 0  ;Pols3 entrada
    BSF TRISB, 3, 0
    BSF TRISB, 4, 0
    BCF INTCON2, 7, 0;Portb pull ups
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
    
CONFIG_OSC
    ;BSF OSCCON, 5, 0	    ;HSPLL comentar els dos
    ;BSF OSCTUNE, 6, 0
    RETURN
    
INIT_EUSART
    movlw b'00100100'
    movwf TXSTA,0
    movlw b'10010000'
    movwf RCSTA,0
    movlw b'00001000'
    movwf BAUDCON,0
    movlw HIGH(.1040)
    movwf SPBRGH,0
    movlw LOW(.1040)
    movwf SPBRG,0
    return
    
CONFIG_ADC
    BSF ADCON0, ADON, 0 ;Converter module enabled.
    MOVLW b'00001110'  ;AN0 analog
    MOVWF ADCON1, 0
    BCF ADCON2, ADFM, 0 ;Left justified
    BSF ADCON2, 5, 0   ;Toquem aquests bits perquè trigui més a convertir
    BSF ADCON2, 4, 0
    BSF ADCON2, 2, 0
    BSF ADCON2, 0, 0
    RETURN    
;--------------------------------------MAIN-------------------------------------
MAIN
    CALL CONFIG_PORTS
    CALL INIT_VARS
    ;CALL CONFIG_OSC
    ;CALL CONFIG_EUSART
    ;CALL CONFIG_INTERRUPTS
    ;CALL CONFIG_TIMER
    ;CALL CARREGA_TIMER
    ;CALL CONFIG_ADC

LOOP_MAIN
    
    GOTO LOOP_MAIN
    END
    
;-----------------------------------FUNCIONS------------------------------------
