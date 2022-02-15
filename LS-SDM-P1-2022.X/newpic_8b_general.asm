LIST P=PIC18F4321	F=INHX32
    #include <p18f4321.inc>

    CONFIG OSC=HSPLL	    ;Oscillador -> High Speed PLL
    CONFIG PBADEN=DIG	    ;PORTB com a Digital (el posem a 0)
    CONFIG WDT=OFF	    ;Desactivem el Watch Dog Timer
    CONFIG LVP=OFF	    ;Evitar resets eusart
;--------------------------------DECLARACIO_VARS--------------------------------
 carrier EQU 0x01
 
;-------------------------------------INITS-------------------------------------
    ORG 0x000
    GOTO MAIN
    ORG 0x008
    GOTO HIGH_RSI
    ORG 0x018
    retfie FAST

    
INIT_PORTS
    
RETURN
    
INIT_VARS
    movlw b'00001101' ;\n del putty a Windows 10
    movwf carrier,0
    
RETURN
    
INIT_EUSART
    
RETURN
    
INIT_INTCONS
    
RETURN

INIT_TIMER
    
RETURN
    
CARREGA_TIMER
    MOVLW HIGH(.);cada XXms
    MOVWF TMR0H,0
    MOVLW LOW(.)
    MOVWF TMR0L,0
RETURN
    
INIT_ADCON
    
RETURN

INIT_OSC
    
RETURN
    
;--------------------------------------MAIN-------------------------------------
MAIN
    call INIT_VARS
    call INIT_PORTS
    call INIT_OSC
    call INIT_EUSART
    call INIT_INTCONS
    call INIT_EEPROM
    call INIT_TIMER
    call CARREGA_TIMER
    call INIT_ADCON
    
    
;-------------------------------------LOOP--------------------------------------
LOOP
    ;codi
    
    
    
GOTO LOOP
    
    
;-----------------------------------HIGH_RSI------------------------------------
HIGH_RSI
RETFIE FAST
    
;-----------------------------------FUNCIONS------------------------------------