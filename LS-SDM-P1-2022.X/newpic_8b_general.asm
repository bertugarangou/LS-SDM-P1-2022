;falta comporvar rebots de baixada:
    ; play button OK, JA FET
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
TMP_timer EQU 0X08
MODE_ACTUAL EQU 0X0A
 ; mode: (0s per defecte al init)
 ; b7[0:manual, 1:automatic]
 ; b6[0:no s'ha rebut la P encara pero estem en auto, 1:s'ha rebut la P]
 ; b5[0: mode manual joystick; 1: mode manual java]
 ; b4[0: pwm al servo X; 1: pwm al servo Y]
 ; b3[0: encara no ha arribat a 1segon. 1: ha arribat a 1 segon]
 ; b2[0: no record; 1: record actiu]
 ; b1[1:s'est� reproduint NO-RECORD-NO SI-PLAY-SI; 0: no reproduint, normal]
 ; b0[0: podem enregistrar toogle joystick; 1: ja l'hem guardat un cop no tornar-hi]
EUSART_INPUT EQU 0X0B

TMP3 EQU 0X0C
TMP4 EQU 0X0D
VAR_CONVER EQU 0X0E
VAR_COMP EQU 0X0F
PWM_VAR EQU 0X10
PWM_AUX EQU 0X11
COMPT_GRAUS EQU 0X12
TMP EQU 0X13
TMP2 EQU 0X14
VAR_CONVER2 EQU 0X15
VAR_COMP2 EQU 0X16
PWM_VAR2 EQU 0X17
PWM_AUX2 EQU 0X18
COMPT_GRAUS2 EQU 0X1A
VAR_TOKEN2 EQU 0X1B
ULTIMA_NOTA EQU 0X1C
COMPTADOR_RAM EQU 0X1D
TEMPS_LOW EQU 0X1E
TEMPS_HIGH EQU 0X1F
FLAGS2 EQU 0x20
FLAGS3 EQU 0x21
FLAGS4 EQU 0x22
OFFSET EQU 0x23
NOTA_RAM EQU 0x24
TEMPS_HIGH_RAM EQU 0x25
TEMPS_LOW_RAM EQU 0x26
FLAG_ESPERAL EQU 0x27
FLAG_ESPERAH EQU 0x28
FLAG_TEMPS EQU 0x29
COPY_RAM EQU 0X30

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
    CLRF VAR_TOKEN2, 0
    CLRF FLAG_TEMPS, 0
    
    MOVLW .39
    MOVWF PWM_VAR,0
    MOVWF PWM_VAR2,0
    
    
    CLRF FSR0L,0
    CLRF FSR0H,0
    
    BSF FSR0H,0,0
    CLRF COMPTADOR_RAM,0
    CLRF ULTIMA_NOTA,0
    CLRF TEMPS_HIGH, 0
    CLRF TEMPS_LOW, 0
    
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

    
    
    ;Comptar temps entre nota i nota
    BTFSS MODE_ACTUAL,2,0
    GOTO NEXT
    
    ;Comprovar si ha estat mes d'1 minut inactiu
    MOVLW b'11101010'
    SUBWF TEMPS_HIGH, 0, 0
    BTFSC STATUS, Z, 0
    GOTO COMPROVA_TEMPS_LOW ;60000 part high OK
    GOTO INCREMENTA_LOW  ;Sino cap a incrementar low normal
    
    COMPROVA_TEMPS_LOW
	MOVLW b'01100000'
	SUBWF TEMPS_LOW, 0, 0
	BTFSC STATUS, Z, 0
	GOTO MINUT
	GOTO INCREMENTA_LOW
	
    
    MINUT
	BCF MODE_ACTUAL,2, 0  ;Si ha passat mes d'1 minut (60.000 -- 1110 1010 0110 0000), sortim d'enregistrar
	GOTO NEXT
    
    
    INCREMENTA_LOW
	MOVFF TEMPS_LOW, FLAGS3 ;Movem el valor abans de sumar per no perdre'l en cas d'OV
	MOVLW .20
	ADDWF TEMPS_LOW, 1, 0
	BTFSC STATUS, OV, 0
	GOTO OVER_FLOW
	GOTO NEXT
    
    OVER_FLOW
	MOVLW .20
	MOVWF OFFSET, 0
	MOVLW .255
	MOVWF FLAGS4, 0    ;Flags 4 val 255
	MOVF FLAGS3, 0, 0  ;Movem valor abans del OV al W
	SUBWF FLAGS4, 0, 0
	SUBWF OFFSET, 1, 0 ;20 - (255-valor) = offset
	MOVFF OFFSET, TEMPS_LOW
	DECF TEMPS_LOW, 1, 0
	
    INCREMENTA_HIGH
	INCF TEMPS_HIGH, 1, 0

    
    NEXT
    
    ;Comprovar si es prem pulsador change mode actual, mes d'1 segon
    BTFSS PORTB, 3, 0
    GOTO INCREMENTA_VAR
    GOTO RESET_VAR
    
    INCREMENTA_VAR
	INCF VAR_TOKEN2, 1, 0
	MOVLW .50
	SUBWF VAR_TOKEN2, 0, 0
	BTFSC STATUS, Z, 0
	BSF MODE_ACTUAL, 3, 0
	RETURN
	
    RESET_VAR
	CLRF VAR_TOKEN2, 0
    
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
ENREGISTRAR
    MOVFF ULTIMA_NOTA, POSTINC0
    MOVFF TEMPS_LOW, POSTINC0
    MOVFF TEMPS_HIGH, POSTINC0
    INCF COMPTADOR_RAM,1,0
    CLRF TEMPS_LOW, 0      ;Despres de guardar a la ram, netegem variables SEMPRE
    CLRF TEMPS_HIGH, 0
    
    ;COMPROVAR QUE ARRIBEM A LES 64 NOTES
    MOVLW .5
    SUBWF COMPTADOR_RAM,0,0
    BTFSC STATUS,Z,0
    BCF MODE_ACTUAL,2,0
    RETURN
    
FUNCIO_MODE_MANUAL
    
    BTFSS MODE_ACTUAL,2,0
    GOTO VERD
    GOTO VERMELL
    
    VERD
    BSF LATC, 2,0;veRD
    GOTO POLLANCRE

    VERMELL
    BSF LATC, 1,0;veRMELL
    BCF LATC,2,0
    
    POLLANCRE
    
    
    
    
    ;codi funcio manual
    CALL MIRA_MODE_ENTRADA;joystick o java
    
    BTFSS MODE_ACTUAL,5,0
    CALL MOVIMENT_JOYSTICK
    BTFSC MODE_ACTUAL,5,0
    CALL MOVIMENT_JAVA_MANUAL
    
    
    
    ;EVITAR SORTIR
    BTFSC MODE_ACTUAL,2,0
    GOTO FUNCIO_MODE_MANUAL
    
    
    ;NO ARRIBAR AQUI SI S'ESTA ENREGISTRANT
    
    
    
    BTFSS PORTB,2,0
    CALL CONTROL_REBOTS_PLAY_BUTTON ;MIRAR SI PLAY
    
    
    
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
    BSF MODE_ACTUAL,6,0;ACTIVEM AUTO AMB P JA REBUDA
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
    CLRF LATD,0
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
	MOVLW .123;144=7notes+39init
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
    MOVLW .12;increment pos
    ADDWF PWM_VAR, 1, 0  ;Hem de sumar 5 graus cada vegada
    RETURN
RESTA
    MOVLW .12;dec pos
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
    CPFSGT TMP2,0
    GOTO CAGARRO2
    GOTO CAGARRO
    
    CAGARRO2
    CALL MOSTRAR_NOTA
    
    BTFSC MODE_ACTUAL,2,0; SI ESTEM ENREGISTRANT, GUARDAR LA NOTA mode manual-joystick
	GOTO ZONA_ENREGISTRAR
	GOTO CAGARRO
	
    ZONA_ENREGISTRAR
	BTFSS MODE_ACTUAL,0,0
	CALL ENREGISTRAR
	BSF MODE_ACTUAL,0,0

    CAGARRO
    MOVLW .100; COMPARADOR AMB HIST�RESIS
    CPFSLT ADRESH,0
    BCF MODE_ACTUAL,0,0
    
    ;filtre maxim
    MOVLW .39;posicio minima joystick Y
    CPFSGT TMP2,0
    CALL CORREGIR
    
    FINAL_T
    ;ENVIAR POSICIO
    MOVFF TMP2, PWM_VAR2
    BSF MODE_ACTUAL,4,0

    
    RETURN
    
CORREGIR
    MOVLW .39;posicio minima joystick Y
    MOVWF TMP2,0
RETURN
    
MOSTRAR_NOTA
    MOVLW .40;VALOR_INIT+1
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_C
    MOVLW .52;VALOR_INIT+1+NOTA
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_D
    MOVLW .64;...
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_E
    MOVLW .76
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_F
    MOVLW .88
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_G
    MOVLW .100
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_A
    MOVLW .112
    CPFSGT PWM_VAR,0
	GOTO MOSTRA_B
	GOTO MOSTRA_C_MENOR

	MOSTRA_A
	    MOVFF SEVEN_SEG_A, LATD
	    MOVLW 'A'
	    MOVWF ULTIMA_NOTA,0
	RETURN
	MOSTRA_B
	    MOVFF SEVEN_SEG_B, LATD
	    MOVLW 'B'
	    MOVWF ULTIMA_NOTA, 0
	RETURN
	MOSTRA_C
	    MOVFF SEVEN_SEG_C, LATD
	    MOVLW 'C'
	    MOVWF ULTIMA_NOTA, 0
	RETURN
	MOSTRA_D
	    MOVFF SEVEN_SEG_D, LATD
	    MOVLW 'D' 
	    MOVWF ULTIMA_NOTA, 0
	RETURN
	MOSTRA_E
	    MOVFF SEVEN_SEG_E,LATD
	    MOVLW 'E'
	    MOVWF ULTIMA_NOTA, 0
	RETURN
	MOSTRA_F
	    MOVFF SEVEN_SEG_F,LATD
	    MOVLW 'F'
	    MOVWF ULTIMA_NOTA, 0
	RETURN
	MOSTRA_G
	    MOVFF SEVEN_SEG_G,LATD
	    MOVLW 'G'
	    MOVWF ULTIMA_NOTA, 0
	RETURN
	MOSTRA_C_MENOR
	    MOVFF SEVEN_SEG_C_MENOR,LATD
	    MOVLW 'c'
	    MOVWF ULTIMA_NOTA, 0
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
    
    BTFSC MODE_ACTUAL, 3, 0
    GOTO CANVIS_1S

    BTG MODE_ACTUAL,5,0;FLAG JOYSTICK O JAVA
    BTG LATC,3,0
    RETURN
    
    CANVIS_1S
    BTFSS MODE_ACTUAL,2,0
    GOTO NETEJAR_RAM
    BCF MODE_ACTUAL, 2, 0
    BCF MODE_ACTUAL, 3, 0;Resetegem flag
    RETURN
    
    
    NETEJAR_RAM
	BCF MODE_ACTUAL, 3, 0;Resetegem flag
	BSF MODE_ACTUAL,2,0
	MOVLW b'10111111'  ;Netegem 191 --> 64*3 = 192
	MOVWF COMPTADOR_RAM,0
	
	;NETEJAR RAM
	CLRF FSR0L,0
	BUCLE_NETEJA_RAM
	    MOVLW b'00000000'
	    MOVWF POSTINC0,0
	    DECFSZ COMPTADOR_RAM,1,0
	    GOTO BUCLE_NETEJA_RAM
    CLRF FSR0L,0
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
    
MOVIMENT_JAVA_MANUAL_SI_ENREGISTRAR_TAMBE
    
    BCF MODE_ACTUAL,4,0;CANVI SERVO TOCANT
    CLRF LATD,0
    MOVLW 'C'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_C
    MOVLW .39;valor init C
    MOVWF PWM_VAR
    GOTO TROBAT_NOTA
NEXT_C
    MOVLW 'D'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_D
    MOVLW .51;posicio D
    MOVWF PWM_VAR
    GOTO TROBAT_NOTA
NEXT_D
    MOVLW 'E'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_E
    MOVLW .63;posicio E
    MOVWF PWM_VAR
    GOTO TROBAT_NOTA
NEXT_E
    MOVLW 'F'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_F
    MOVLW .75;posicio F
    MOVWF PWM_VAR
    GOTO TROBAT_NOTA
NEXT_F
    MOVLW 'G'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_G
    MOVLW .87;posicio G
    MOVWF PWM_VAR
    GOTO TROBAT_NOTA
NEXT_G
    MOVLW 'A'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_A
    MOVLW .99;posicio A
    MOVWF PWM_VAR
    GOTO TROBAT_NOTA
NEXT_A
    MOVLW 'B'
    CPFSEQ EUSART_INPUT,0
    GOTO NEXT_B
    MOVLW .111;posicio B
    MOVWF PWM_VAR
    GOTO TROBAT_NOTA
NEXT_B
    MOVLW 'c'
    CPFSEQ EUSART_INPUT,0
    GOTO FAIL_INPUT
    MOVLW .123;posicio c'
    MOVWF PWM_VAR
    GOTO TROBAT_NOTA
    FAIL_INPUT
	RETURN
    TROBAT_NOTA
    
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
    
    ;gravar nota en mode pc-manual-eusart-sio
    BTFSC MODE_ACTUAL,2,0
	CALL ENREGISTRAR
    
    
RETURN
    
;--------------mode automatic--------------
ENVIA_K
    MOVLW 'K'
    MOVWF TXREG,0
    CALL ESPERA_TX
RETURN
    
    
FUNCIO_MODE_AUTOMATIC
    BSF LATC,0,0;blau
    BCF LATC,3,0
    BTFSS MODE_ACTUAL,6,0
    GOTO PRE_AUTO_MODE
    
    BTFSS FLAGS2,7,0
    CALL ENVIA_K
    
    ;INICI CAN��
    REPRODUINT_AUTO_BUCLE
	;BSF FLAGS2,7,0 ;DESCOMENTAR  SI FA FALTA
	
	CALL MOVIMENT_JAVA_MANUAL;EL MANUAL AMB JAVA JA ENS SERVEIX PEL AUTO
	CLRF LATD,0;NETEJA LA PANTALLA PER LA SEGUENT NOTA
	;MIRAR SI S'HA ACABAT LA CAN��
	MOVLW 'S'
	CPFSEQ EUSART_INPUT,0
	GOTO REPRODUINT_AUTO_BUCLE;1: NO HA SALTAT
	BCF MODE_ACTUAL,6,0;netejar que espera una altra P per la seguent can�o
    FI_SONG
    
    ;BTFSS PORTB,1,0;si cliquen manual, activem manual
    ;CALL POLSADOR_REBOTS_CANVI_A_MANUAL
    GOTO END_LOOP_MAIN
    
    
    PRE_AUTO_MODE

	;mirar btn
	BTFSC PORTB,1,0
	GOTO PRE_AUTO_MODE_CHECK_PLAY_BUTTON
	CALL POLSADOR_REBOTS_CANVI_A_MANUAL
	GOTO END_LOOP_MAIN
	
	PRE_AUTO_MODE_CHECK_PLAY_BUTTON
	    BTFSS PORTB,2,0
	    CALL CONTROL_REBOTS_PLAY_BUTTON
	
	PRE_AUTO_MODE_CHECK_PIR
	    BTFSS PIR1,RCIF,0
	    GOTO PRE_AUTO_MODE;no eusart
	    MOVF RCREG,0,0
	    MOVWF EUSART_INPUT,0
	    MOVLW 'P'
	    CPFSEQ EUSART_INPUT,0
	    GOTO PRE_AUTO_MODE
	    BSF MODE_ACTUAL,6,0
	    GOTO FUNCIO_MODE_AUTOMATIC
	    
	    
CONTROL_REBOTS_PLAY_BUTTON
    CALL ESPERA_meitat
    CALL ESPERA_meitat
    BTFSC PORTB,2,0
    RETURN    ;ERA FAKE NAH BRO
CONTROL_REBOTS_PLAY_BUTTON_DESCLICAR
    BTFSS PORTB,2,0
    GOTO CONTROL_REBOTS_PLAY_BUTTON_DESCLICAR	    ;ENCARA CLICA EL RATA
CONTROL_REBOTS_PLAY_BUTTON_BAIXADA
    CALL ESPERA_meitat
    CALL ESPERA_meitat
    BTFSS PORTB,2,0		    ;EL MOLT PUTA ENS HA FET LA PUA, NO HA CLICAT EN REALITAT
    GOTO CONTROL_REBOTS_PLAY_BUTTON_BAIXADA
    CALL PLAY_RAM_SONG ;EL NOM DE LA FUNCIO AMB CALL/RETURN QUE REPRODUEIX EL QUE ESTIGUI A LA RAM
    RETURN

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
 
    
PLAY_RAM_SONG
    MOVLW .0
    SUBWF COMPTADOR_RAM,0,0
    BTFSC STATUS,Z,0
    RETURN;NO MIRAR RES SI NO HI HA NOTES
    
    MOVFF COMPTADOR_RAM, COPY_RAM
    
    BSF MODE_ACTUAL,1,0;FLAG REPRODUINT
    CLRF FSR0L, 0
    LOOP_LLEGEIX
	MOVFF POSTINC0, NOTA_RAM
	MOVFF POSTINC0, TEMPS_LOW_RAM
	MOVFF POSTINC0, TEMPS_HIGH_RAM
	
	;NOTA PANTALLA I NOTA MOVIMENT --START
	    MOVFF NOTA_RAM, EUSART_INPUT;PER APROFITAT LA FUNCIO QUE JA TENIM DEL JAVA ENGANYEM D'ON ENS VE LA NOTA
	    CALL MOVIMENT_JAVA_MANUAL_SI_ENREGISTRAR_TAMBE
	    ;NOTA PANTALLA I NOTA MOVIMENT --END
	
	LOOP_TEMPS
	    CALL ESPERA_MS
	    BTFSC FLAG_TEMPS, 0, 0
	    GOTO LAST_ITERACIO
	    DECF TEMPS_LOW_RAM, 1, 0
	    BTFSC STATUS, Z, 0 ;Mirem si hem arribat a 0
	    CALL RESET_VARR
	    GOTO LOOP_TEMPS
	    LAST_ITERACIO
	    DECF TEMPS_LOW_RAM, 1, 0
	    BTFSS STATUS, Z, 0 ;Si es ultima iteracio i arribem a 0, sortim
	    GOTO LOOP_TEMPS
	    
	    
	    

	    
	DECFSZ COMPTADOR_RAM, 1, 0  ;Llegim tot el que tenim guardat
	GOTO LOOP_LLEGEIX
	CLRF FLAG_TEMPS, 0
	BCF MODE_ACTUAL,1,0;FLAG REPRODUINT
	    MOVFF COPY_RAM, COMPTADOR_RAM
	    
    RETURN

RESET_VARR
    MOVLW .255
    MOVWF TEMPS_LOW_RAM
    DECF TEMPS_HIGH_RAM, 1, 0
    BTFSC STATUS, Z, 0 ;Mirem si hem arribat a 0
    BSF FLAG_TEMPS, 0, 0
    RETURN
    
ESPERA_MS ;1ms --> 10.000 cicles
    MOVLW HIGH(.3325)    ;1 cicle
    MOVWF FLAG_ESPERAH, 0     ;1 cicle
    MOVLW LOW(.3325)    ;1 cicle
    MOVWF FLAG_ESPERAL, 0
    LOOP_MS
	DCFSNZ FLAG_ESPERAL, 1, 0
	DECFSZ FLAG_ESPERAH, 1, 0  ;Iteracio sense salt = 3 cicles
	GOTO LOOP_MS	       ;Iteracio amb salt = 2 cicles
				   ;10000-2-2-1-1-22  --> 3*(x-1)+2 = 9982   x = 3325
    NOP  ;1 cicle
    NOP  ;1 cicle
    RETURN  ;2 cicles 

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