LIST P=PIC18F4321	F=INHX32
    #include <p18f4321.inc>

    CONFIG OSC=HSPLL	    ;Oscillador -> High Speed PLL
    CONFIG PBADEN=DIG	    ;PORTB com a Digital (el posem a 0)
    CONFIG WDT=OFF	    ;Desactivem el Watch Dog Timer
    CONFIG LVP=OFF	    ;Evitar resets eusart
;vars
    ORG 0x000
    GOTO MAIN
    ORG 0x008
    GOTO HIGH_RSI
    ORG 0x018
    retfie FAST
    
INIT_PORTS
RETURN
    
INIT_VARS
RETURN
    
INIT_EUSART
RETURN
    
INIT_INTCONS
RETURN

INIT_TIMER
RETURN
    
CARREGA_TIMER
    MOVLW HIGH(.);cada 20ms
    MOVWF TMR0H,0
    MOVLW LOW(.)
    MOVWF TMR0L,0
RETURN

INIT_EEPROM
    BCF EECON1, EEPGD
    BCF EECON1, CFGS
RETURN
    
INIT_ADCON
RETURN

INIT_OSC
RETURN
    
;-------------------------------------------------------------------------------
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
    
    
    
LOOP
    ;codi
    
    
    
GOTO LOOP
    
    
;-------------------------------------------------------------------------------
HIGH_RSI
RETFIE FAST
    
;-------------------------------------------------------------------------------

;Lectura EEPROM
EEPROM_READ
    movf eeprom_addr,0
    movwf EEADR,0
    BCF EECON1, EEPGD    ; Point to DATA memory
    BCF EECON1, CFGS     ; Access EEPROM
    BSF EECON1, RD        ; EEPROM Read
    MOVFF EEDATA, eeprom_data
RETURN
    
;Escriptura EEPROM   
EEPROM_WRITE
    movf eeprom_addr,0
    movwf EEADR,0
    movf eeprom_data,0
    movwf EEDATA,0
    bsf EECON1,WREN
    bcf INTCON,GIE
    movlw 55h
    movwf EECON2,0
    movlw 0AAh
    movwf EECON2
    bsf EECON1,WR
    call ESPERA_EEPROM_ESCRIURE
    bsf INTCON,GIE
    bcf EECON1,WREN
    return
    
ESPERA_EEPROM_ESCRIURE
    BTFSC EECON1,WR
    GOTO ESPERA_EEPROM_ESCRIURE
    RETURN