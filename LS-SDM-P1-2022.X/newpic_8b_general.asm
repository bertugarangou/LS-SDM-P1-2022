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
SEVEN_SEG_C_MENOR EQU 0X07
TMP_timer EQU 0x08
MODE_ACTUAL EQU 0x0A
 ; mode: (0s per defecte al init)
 ; b7[0:manual, 1:automatic]
 ; b6[0:no s'ha rebut la P encara pero estem en auto, 1:s'ha rebut la P]
 ; b5[0: mode manual joystick; 1: mode manual java]
 ; b4[0: pwm al servo X; 1: pwm al servo Y]
EUSART_INPUT EQU 0x0B

TMP3 EQU 0x0C
TMP4 EQU 0x0D
VAR_CONVER EQU 0X0E
VAR_COMP EQU 0X0F
PWM_VAR EQU 0X10
PWM_AUX EQU 0X11
COMPT_GRAUS EQU 0X12
TMP EQU 0x13
TMP2 EQU 0x14
VAR_CONVER2 EQU 0X15
VAR_COMP2 EQU 0X16
PWM_VAR2 EQU 0X17
PWM_AUX2 EQU 0X18
COMPT_GRAUS2 EQU 0X1A





    ORG 0x000
    GOTO MAIN
    ORG 0x008
    GOTO HIGH_RSI
    ORG 0x018
    RETFIE FAST
;-----------------------------------HIGH_RSI------------------------------------
HIGH_RSI
    BTFSC INTCON, TMR0IF, 0
    CALL ACTION_TMR 
    RETFIE FAST
;---------------------------------CONFIG I INITS--------------------------------
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
    
    BCF LATC,0,0
    BCF LATC,1,0
    BCF LATC,2,0
    BCF LATC,3,0
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
    MOVWF SEVEN_SEG_C_MENOR
    
    CLRF MODE_ACTUAL,0
    
    MOVLW .39
    MOVWF PWM_VAR,0
    MOVWF PWM_VAR2,0
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
    
CONFIG_ADC
    BSF ADCON0, ADON, 0 ;Converter module enabled.
    MOVLW b'00001101'  ;AN0 analog
    MOVWF ADCON1, 0
    BCF ADCON2, ADFM, 0 ;Left justified
    BSF ADCON2, 5, 0   ;Toquem aquests bits perqu? trigui m?s a convertir
    BSF ADCON2, 4, 0
    BSF ADCON2, 2, 0
    BSF ADCON2, 0, 0
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
    
;-----------------------------------FUNCIONS------------------------------------
;timer servo
ACTION_TMR
    CALL CARREGA_TIMER;reiniciem el timer
    BCF INTCON,TMR0IF,0;quan salti una interrupcio qualsevol, nomes tenim timer0 de moment
    
    BTFSS MODE_ACTUAL,4,0
    CALL PWM;si es 0 fem el normal X
    BTFSC MODE_ACTUAL,4,0
    CALL PWM2;si es 1 fem l'Y
    
    ;BCF MODE_ACTUAL,4,0
    
    RETURN
PWM
    MOVFF PWM_VAR, PWM_AUX
    BSF LATA,2,0
    LOOP_ESPERAPWM
	CALL ESPERA_GRAUS
	DECFSZ PWM_VAR,1,0
	GOTO LOOP_ESPERAPWM
    BCF LATA,2,0
    MOVFF PWM_AUX, PWM_VAR
    RETURN
    
ESPERA_GRAUS
    MOVLW .41 ;13us un sol grau, canviar a posicions
    MOVWF COMPT_GRAUS,0
    LOOP_GRAUS
	DECFSZ COMPT_GRAUS,1,0
	GOTO LOOP_GRAUS
    RETURN
;------------
PWM2
    
    MOVFF PWM_VAR2, PWM_AUX2
    BSF LATA,3,0
    LOOP_ESPERAPWM2
	CALL ESPERA_GRAUS2
	DECFSZ PWM_VAR2,1,0
	GOTO LOOP_ESPERAPWM2
    BCF LATA,3,0
    MOVFF PWM_AUX2, PWM_VAR2
    RETURN
    
ESPERA_GRAUS2
    MOVLW .41
    MOVWF COMPT_GRAUS2,0
    LOOP_GRAUS2
	DECFSZ COMPT_GRAUS2,1,0
	GOTO LOOP_GRAUS2
    RETURN
    ;---------
;--------------mode manual--------------
FUNCIO_MODE_MANUAL
    BSF LATC, 2,0;verd
   
    
    
    
    
    
    ;codi funcio manual
    CALL MIRA_MODE_ENTRADA;joystick o java
    
    BTFSS MODE_ACTUAL,5,0
    CALL MOVIMENT_JOYSTICK
    BTFSC MODE_ACTUAL,5,0
    CALL MOVIMENT_JAVA_MANUAL
    
    
    ;NO ARRIBAR AQUI SI S'ESTA ENREGISTRANT
    BTFSS PORTB,1,0;si actiu (0) canvi mode
    CALL POLSADOR_REBOTS_CANVI_A_AUTO
    ;canvi per P EUSART.
    BTFSS PIR1,RCIF,0
    GOTO END_LOOP_MAIN;no eusart
    MOVF RCREG,0,0
    MOVWF EUSART_INPUT,0
    MOVLW 'P'
    CPFSEQ EUSART_INPUT,0
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
    
MOVIMENT_JOYSTICK
    CALL PICAR_NOTA
    
    BCF MODE_ACTUAL,4,0

    BSF ADCON0,CHS0,0   ;activar hoystick X PORTA0 per lectura
    LOOP_ANALOG
	BSF ADCON0, 1, 0  ;Fem la conversi�
	LOOP_CONVER
	    BTFSC ADCON0, 1, 0  ;Esperem a que es faci la conversi� i mirem qu� obtenim
	    GOTO LOOP_CONVER
	MOVFF ADRESH, VAR_CONVER  ;Passem la conversi� a la nostra variable
	MOVLW .200
	CPFSLT VAR_CONVER, 0
	CALL INCREMENT_ANALOG  ;Si estem per sobre de 240 incrementem PWM
	MOVLW .15
	CPFSGT VAR_CONVER, 0
	CALL DECREMENT_ANALOG  ;Si estem per sota de 15 decrementem PWM
    RETURN
INCREMENT_ANALOG
	MOVLW .144;144=notes+39init
	SUBWF PWM_VAR, 0, 0
	BTFSS STATUS, Z, 0  ;Si la suma no dona 0, decrementem
	CALL SUMA
	LOOP_WAIT
	    BSF ADCON0, 1, 0  ;Fem la conversi�
	    LOOP_CWAIT
		BTFSC ADCON0, 1, 0  ;Esperem a que es faci la conversi� i mirem qu� obtenim
		GOTO LOOP_CWAIT
		MOVFF ADRESH, VAR_COMP  ;Passem la conversi� a la nostra variable
		MOVLW .140
		SUBWF VAR_COMP, 0, 0
		BTFSS STATUS, N, 0  ;Si es negatiu vol dir que ja esta a la posicio inicial
	    GOTO LOOP_WAIT	
	
	RETURN
DECREMENT_ANALOG
    MOVLW .39
    SUBWF PWM_VAR, 0, 0
    BTFSS STATUS, Z, 0  ;Si la resta no dona 0, decrementem
    CALL RESTA
    LOOP_WAITD  ;Esperem a que el joystick torni a la seva posici�
	BSF ADCON0, 1, 0  ;Fem la conversi�
	LOOP_DWAIT
	    BTFSC ADCON0, 1, 0  ;Esperem a que es faci la conversi� i mirem qu� obtenim
	    GOTO LOOP_DWAIT
	    MOVFF ADRESH, VAR_COMP  ;Passem la conversi� a la nostra variable
	    MOVLW .100
	    SUBWF VAR_COMP, 0, 0
	    BTFSC STATUS, N, 0
	GOTO LOOP_WAITD
    RETURN
SUMA
    MOVLW .15;increment pos
    ADDWF PWM_VAR, 1, 0  ;Hem de sumar 5 graus cada vegada
    RETURN
RESTA
    MOVLW .15;dec pos
    SUBWF PWM_VAR, 1, 0  ;Hem de restar 5 graus cada vegada
    RETURN
    
    
    
    
    
    
    
    
    
    
PICAR_NOTA
   BSF MODE_ACTUAL,4,0
    
   BCF ADCON0,CHS0,0;joystick Y AN0
   BSF ADCON0,1,0 ; Comencem la conversi�
   ESPERA_CONVERSIO
   BTFSC ADCON0,1,0
   GOTO ESPERA_CONVERSIO
   
    CLRF TMP,0
    CLRF TMP2,0
BUCLE_T
    MOVF TMP,0
    CPFSGT ADRESH,0
    GOTO T_TROBAT
    INCF TMP,1,0
    BTFSC STATUS,C,0;val C per TMP?
    GOTO T_TROBAT
    INCF TMP2,1,0
    
    MOVF TMP,0
    CPFSGT ADRESH,0
    GOTO T_TROBAT
    INCF TMP,1,0
    INCF TMP,1,0
    BTFSC STATUS,C,0;val C per TMP?
    GOTO T_TROBAT
    INCF TMP2,1,0
    GOTO BUCLE_T
T_TROBAT
    ;ENCENDRE NOTA
    MOVLW .5
    CPFSGT TMP2
    CALL MOSTRAR_NOTA
    
    ;filtre maxim
    MOVLW .40;posicio minima joystick Y
    CPFSGT TMP2,0
    CALL CORREGIR
    
    FINAL_T
    ;ENVIAR POSICIO
    MOVFF TMP2, PWM_VAR2
    BSF MODE_ACTUAL,4,0
    
    RETURN
    
CORREGIR
    MOVLW .40;posicio minima joystick Y
    MOVWF TMP2,0
RETURN
    
MOSTRAR_NOTA
    MOVLW .40;VALOR_INIT+1+NOTA
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_C
    MOVLW .55;VALOR_INIT+1+NOTA+NOTA
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_D
    MOVLW .70;...
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_E
    MOVLW .85
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_F
    MOVLW .100
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_G
    MOVLW .115
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_A
    MOVLW .130
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_B
	GOTO MOSTRA_C_MENOR

	MOSTRA_A
	    MOVFF SEVEN_SEG_A, LATD
	RETURN
	MOSTRA_B
	    MOVFF SEVEN_SEG_B, LATD
	RETURN
	MOSTRA_C
	    MOVFF SEVEN_SEG_C, LATD
	RETURN
	MOSTRA_D
	    MOVFF SEVEN_SEG_D, LATD
	RETURN
	MOSTRA_E
	    MOVFF SEVEN_SEG_E,LATD
	RETURN
	MOSTRA_F
	    MOVFF SEVEN_SEG_F,LATD
	RETURN
	MOSTRA_G
	    MOVFF SEVEN_SEG_G,LATD
	RETURN
	MOSTRA_C_MENOR
	    MOVFF SEVEN_SEG_C_MENOR,LATD
	RETURN
    
    
    
    
    
    
MIRA_MODE_ENTRADA
    BTFSC PORTB,3,0
    RETURN
    CALL ESPERA_meitat
    CALL ESPERA_meitat
    BTFSS PORTB,3,0
    GOTO ESPERA_DESCLICAR_MODE_TOCAR
    RETURN
    
    ESPERA_DESCLICAR_MODE_TOCAR
    BTFSS PORTB,3,0
    GOTO ESPERA_DESCLICAR_MODE_TOCAR
    BTG MODE_ACTUAL,5,0;FLAG JOYSTICK O JAVA
    BTG LATC,3,0
    RETURN
    
ESPERA_TX
    BTFSS TXSTA,TRMT,0
    GOTO ESPERA_TX
    RETURN   
    
MOVIMENT_JAVA_MANUAL
    BTFSS PIR1,RCIF,0
    RETURN
    MOVF RCREG,0,0
    MOVWF EUSART_INPUT,0
    
    BCF MODE_ACTUAL,4,0

    MOVLW 'C'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_C
    MOVLW .39;valor init C
    MOVWF PWM_VAR
NEXT_C
    MOVLW 'D'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_D
    MOVLW .54;posicio D
    MOVWF PWM_VAR
NEXT_D
    MOVLW 'E'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_E
    MOVLW .69;posicio E
    MOVWF PWM_VAR
NEXT_E
    MOVLW 'F'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_F
    MOVLW .84;posicio F
    MOVWF PWM_VAR
NEXT_F
    MOVLW 'G'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_G
    MOVLW .99;posicio G
    MOVWF PWM_VAR
NEXT_G
    MOVLW 'A'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_A
    MOVLW .114;posicio A
    MOVWF PWM_VAR
NEXT_A
    MOVLW 'B'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_B
    MOVLW .129;posicio B
    MOVWF PWM_VAR
NEXT_B
    MOVLW 'c'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_c
    MOVLW .144;posicio c'
    MOVWF PWM_VAR
NEXT_c

    
    ;BAIXAR EL BRA�------------------
    
    ;CALL MOSTRAR_NOTA ;DESCOMENTAR SI ES VOL VEURE LA NOTA ABANS
    
    ;ESPEREM X MOGUT -----llarg
    MOVLW .255
    MOVWF TMP,0
    LOOP_ESPERA_X
	MOVLW .255
	MOVWF TMP2,0
	LOOP_ESPERA_X_2
	    MOVLW .8;TEMPS ESPERA ENTRE X I Y
	    MOVWF TMP3,0
	    LOOP_ESPERA_X_3
		DECFSZ TMP3,1,0
		GOTO LOOP_ESPERA_X_3
	    DECFSZ TMP2,1,0
	    GOTO LOOP_ESPERA_X_2
	DECFSZ TMP,1,0
	GOTO LOOP_ESPERA_X
    
;MOVEM Y ABALL
    CALL MOSTRAR_NOTA
    
    MOVLW .39;POSICIO ABALL
    MOVWF PWM_VAR2
    
    BSF MODE_ACTUAL,4,0;activar PWM Y
    ;ESPEREM QUE BAIXI
    
    MOVLW .255
    MOVWF TMP,0
    LOOP_ESPERA_BAIXADA
	MOVLW .255
	MOVWF TMP2,0
	LOOP_ESPERA_BAIXADA_2
	    MOVLW .2;TEMPS ESPERA ENTRE PUJAR I BAIXAR Y
	    MOVWF TMP3
	    LOOP_ESPERA_BAIXADA_3
		DECFSZ TMP3,1,0
		GOTO LOOP_ESPERA_BAIXADA_3
	    DECFSZ TMP2,1,0
	    GOTO LOOP_ESPERA_BAIXADA_2
    DECFSZ TMP,1,0
    GOTO LOOP_ESPERA_BAIXADA
    
    ;PUGEM Y

    MOVLW .55;posicio elevada en manual-java
    MOVWF PWM_VAR2,0
    
    
RETURN
    
;--------------mode automatic--------------
FUNCIO_MODE_AUTOMATIC
    BSF LATC,0,0;blau
    BCF LATC,3,0
    BTFSS MODE_ACTUAL,6,0
    GOTO PRE_AUTO_MODE
    
    
    
    ;codi auto
    
    
    
    ;no arribar aqui si s'esta reproduint (si abans i si despres)
    BCF MODE_ACTUAL,6,0;netejar que espera una altra P per la seguent canco
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
	PRE_AUTO_MODE_CHECK_PIR
	    BTFSS PIR1,RCIF,0
	    GOTO PRE_AUTO_MODE;no eusart
	    MOVF RCREG,0,0
	    MOVWF EUSART_INPUT,0
	    MOVLW 'P'
	    CPFSEQ EUSART_INPUT,0
	    GOTO PRE_AUTO_MODE
	    GOTO FUNCIO_MODE_AUTOMATIC
    
ESPERA_meitat
    SETF TMP3,0
BUCLE_D_1
    SETF TMP4,0
BUCLE2_D_1
    DECFSZ TMP4,f,0
    GOTO BUCLE2_D_1
    DECFSZ TMP3,f,0
    GOTO BUCLE_D_1
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
	CLRF LATD,0

	GOTO LOOP_MAIN
END