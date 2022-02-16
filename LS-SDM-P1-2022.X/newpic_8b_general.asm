LIST P=PIC18F4321   F=INHX32
#include <p18f4321.inc>

    CONFIG OSC=HSPLL	    
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
tmp_timer EQU 0x08
MODE_ACTUAL EQU 0x0A
eusart_input EQU 0x0B
tmp3 EQU 0x0C
tmp4 EQU 0x0D
 ; mode: (0s per defecte al init)
 ; b7[0:manual, 1:automatic]
 ; b6[0:no s'ha rebut la P encara pero estem en auto, 1:s'ha rebut la P]
 ;
    ORG 0x000
    GOTO MAIN
    ORG 0x008
    GOTO HIGH_RSI
    ORG 0x018
    RETFIE FAST

;------------------------------------------------------------------------------
CONFIG_PORTS
    MOVLW b'00000011'
    MOVWF TRISA,0
    BCF LATA,2,0
    BCF LATA,3,0
    
    BSF TRISB, 0, 0
    BSF TRISB, 1, 0
    BSF TRISB, 2, 0
    BSF TRISB, 3, 0
    BSF TRISB, 4, 0
    
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
    
    CLRF MODE_ACTUAL,0
    
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
    MOVLW b'00001101'
    MOVWF ADCON1,0
    MOVLW b'00001000'
    MOVWF ADCON2,0
    RETURN
    
CONFIG_TIMER
    MOVLW b'10010001'
    MOVWF T0CON,0   
    CALL CARREGA_TIMER
    RETURN
CARREGA_TIMER
    MOVLW HIGH(.15536);cada 20ms
    MOVWF TMR0H,0
    MOVLW LOW(.15536)
    MOVWF TMR0L,0
    RETURN
CONFIG_INTERRUPTS
    MOVLW b'11100000'
    MOVWF INTCON,0
    BCF INTCON2,RBPU,0
    
    RETURN
;--------------------------------------MAIN-------------------------------------
MAIN

    CALL CONFIG_PORTS
    CALL INIT_VARS
    CALL INIT_EUSART
    CALL CONFIG_INTERRUPTS
    CALL CONFIG_TIMER
    CALL CONFIG_ADC

LOOP_MAIN;bucle del programa
    ;entrar als modes
    ;nota: els canvis de modes es fan dins els funcio_mode_xxxx
    BTFSS MODE_ACTUAL,7,0
    GOTO FUNCIO_MODE_MANUAL;aqui manual
    GOTO FUNCIO_MODE_AUTOMATIC;aqui auto
    
END_LOOP_MAIN
    ;netejar leds
    BCF LATC,0,0
    BCF LATC,1,0
    BCF LATC,2,0
    BCF LATC,3,0
    
    GOTO LOOP_MAIN
    
;-----------------------------------HIGH_RSI------------------------------------
HIGH_RSI
    BCF INTCON,TMR0IF,0;quan salti una interrupcio qualsevol, nomes tenim timer0 de moment
    call CARREGA_TIMER;reiniciem el timer
    
    
    ;BTG LATC,0,0
    
    movlw .250;250
    movwf tmp_timer,0  
;-----------------------------------FUNCIONS------------------------------------
FUNCIO_MODE_MANUAL
    BSF LATC, 2,0;verd
    ;codi funcio manual
    
    ;codis canvi de funcions des del manual
    
    
    
    
    ;NO ARRIBAR AQUI SI S'ESTÀ ENREGISTRANT
    
    
    
    
    
    
    
    
    
    
    BTFSS PORTB,1,0;si actiu (0) canvi mode
    CALL POLSADOR_REBOTS_CANVI_A_AUTO
    
    
    
    
    
    
    
    
    
    
    
    
    ;canvi per P EUSART.
    BTFSS PIR1,RCIF,0
    GOTO END_LOOP_MAIN;no eusart
    movf RCREG,0,0
    movwf eusart_input,0
    movlw 'P'
    CPFSEQ eusart_input,0
    GOTO END_LOOP_MAIN
    BSF MODE_ACTUAL,7,0;activem mode auto
    GOTO END_LOOP_MAIN
    
    
    
    
POLSADOR_REBOTS_CANVI_A_AUTO
  CALL ESPERA_meitat
  CALL ESPERA_meitat
  BTFSC PORTB,1,0
  RETURN
  BSF MODE_ACTUAL,7,0	;OKOKOKOKOK
ESPERA_DESCLICAR_CANVI_A_AUTO
  BTFSS PORTB,1,0
  GOTO ESPERA_DESCLICAR_CANVI_A_AUTO
  RETURN
  
  
POLSADOR_REBOTS_CANVI_A_MANUAL
  CALL ESPERA_meitat
  CALL ESPERA_meitat
  
  BTFSC PORTB,1,0
  RETURN
  BCF MODE_ACTUAL,7,0	;OKOKOKOKOK
ESPERA_DESCLICAR_CANVI_A_MANUAL
  BTFSS PORTB,1,0
  GOTO ESPERA_DESCLICAR_CANVI_A_MANUAL
  RETURN
    
    
    
    
FUNCIO_MODE_AUTOMATIC
    BSF LATC,0,0;blau
    
    BTFSS MODE_ACTUAL,6,0
    GOTO PRE_AUTO_MODE
    
    
    ;codi auto
    
    
    ;no arribar aqui si s'esta reproduint (si abans i si despres)
    
    BCF MODE_ACTUAL,6,0;netejar que espera una altra P per la seguent cançó
    ;i tornar a reproduir una altra
    
    BTFSS PORTB,1,0;si cliquen manual, activem manual
    CALL POLSADOR_REBOTS_CANVI_A_MANUAL
    
    GOTO END_LOOP_MAIN
    
    
PRE_AUTO_MODE
    
    ;mirar btn
    BTFSC PORTB,1,0
    GOTO PRE_AUTO_MODE_CHECK_PIR
    CALL POLSADOR_REBOTS_CANVI_A_MANUAL
    GOTO END_LOOP_MAIN
    
    ;mirar eusart
PRE_AUTO_MODE_CHECK_PIR
    BTFSS PIR1,RCIF,0;s'ha de netejar?
    GOTO PRE_AUTO_MODE;no eusart
    movf RCREG,0,0
    movwf eusart_input,0
    movlw 'P'
    CPFSEQ eusart_input,0
    GOTO PRE_AUTO_MODE
    GOTO FUNCIO_MODE_AUTOMATIC
    
    
ESPERA_meitat
    setf tmp3,0
BUCLE_D_1
    setf tmp4,0
BUCLE2_D_1
    decfsz tmp4,f,0
    goto BUCLE2_D_1
    decfsz tmp3,f,0
    goto BUCLE_D_1
    RETURN
    
    
    
    END
