;NAME Noah Holloway
;COURSE 3371
;SEMESTER 5
;Program: EEPROM
;Git URL
    
;Devices
;Configuration
    
    ; PIC16F883 Configuration Bit Settings

; Assembly source line config statements

; CONFIG1
  CONFIG  FOSC = XT		; Oscillator Selection bits (XT oscillator: Crystal/resonator on RA6/OSC2/CLKOUT and RA7/OSC1/CLKIN)
  CONFIG  WDTE = OFF            ; Watchdog Timer Enable bit (WDT disabled and can be enabled by SWDTEN bit of the WDTCON register)
  CONFIG  PWRTE = OFF           ; Power-up Timer Enable bit (PWRT disabled)
  CONFIG  MCLRE = ON            ; RE3/MCLR pin function select bit (RE3/MCLR pin function is MCLR)
  CONFIG  CP = OFF              ; Code Protection bit (Program memory code protection is disabled)
  CONFIG  CPD = OFF             ; Data Code Protection bit (Data memory code protection is disabled)
  CONFIG  BOREN = OFF           ; Brown Out Reset Selection bits (BOR disabled)
  CONFIG  IESO = OFF            ; Internal External Switchover bit (Internal/External Switchover mode is disabled)
  CONFIG  FCMEN = OFF           ; Fail-Safe Clock Monitor Enabled bit (Fail-Safe Clock Monitor is disabled)
  CONFIG  LVP = OFF             ; Low Voltage Programming Enable bit (RB3 pin has digital I/O, HV on MCLR must be used for programming)

; CONFIG2
  CONFIG  BOR4V = BOR40V        ; Brown-out Reset Selection bit (Brown-out Reset set to 4.0V)
  CONFIG  WRT = OFF             ; Flash Program Memory Self Write Enable bits (Write protection off)
 
  
;Include Statements
  #include <xc.inc>
 ; #include <pic16f883.inc>
;Register/Variable Setup
  ;SOMEVALUE EQU 0x5f ;assign value to a variable
  
    SAVEW	    EQU	0x20
    SAVESTAT	    EQU 0x21
    STATE    EQU 0x22
    RECSTAT	    EQU 0x23
    SERVOPOS	    EQU 0x24
    TIME	    EQU 0x25
    ADDEDBITS	    EQU 0x26
	    MAILOUT EQU 0x27
 ANOTHERTIME	EQU 0x28
	TEMP EQU 0x29


   
 ;Start of Program
 ;Reset vector address
 PSECT resetVect,class=CODE,delta=2 ;-Wl,-presetVect=00h
 GOTO Start
 
 PSECT isrVect,class=CODE,delta=2 ;-Wl,-pisrVect=04h
 GOTO INTERRUPT

 ;Setup Code that runs once at power up and at reset
 PSECT code,class=CODE,delta=2 ;-Wl,-pcode=08h
 
 ;-Wl,-presetVect=00h -Wl,-pisrVect=04h -Wl,-pcode=08h
 
Start:
 
;BANK 3
    BSF STATUS,5    ;GO TO BANK 3
    BSF STATUS,6    ;GO TO BANK 3
    CLRF TRISB	    ;SETS PORTB AS OUTPUT
    CLRF ANSELH	    ;DIGITAL I/O
    MOVLW 0x80
    MOVWF OPTION_REG	;DISABLE PULL UPS
    
;BANK 2
    BSF STATUS,6    ;GO TO BANK 2
    BCF STATUS,5    ;GO TO BANK 2
    CLRF CM2CON1    ;SET ALL BITS TO 0
    
;BANK 1
    BSF STATUS,5    ;GO TO BANK 1
    BCF STATUS,6    ;GO TO BANK 1
    CLRF IOCB	    ;CLEARS INTERRUPTION CHANGE 
    CLRF PSTRCON
    CLRF TRISC	    ;CONFIGURES PORTC AS OUTPUTS
    MOVLW 0xFF
    MOVWF TRISA	    ;CONFIGURES PORTA AS INPUTS
    MOVLW 0x00
    MOVWF ADCON1    ;LEFT JUSTIFIED, VSS & VDD
    CLRF CCP1CON   
    
;BANK 0
    BCF STATUS,5    ;GO TO BANK 0
    BCF STATUS,6    ;GO TO BANK 0
    CLRF PORTC	    ;PUTS PORT C INTO A KNOWN STATE
    CLRF PORTB	    ;PUTS PORT B INTO A KNOWN STATE
    CLRF CCPR1L     ;START WITH 0 DUTY
    
    ;INTERRUPT STUFF----------------------------------------------------------------------------------------------
    
    BSF STATUS,5   ;BANK 1
    BCF STATUS,6
    
    BSF PIE1, 1	    ;ENABLES TIMER2 TO MATCH PR2 INTERRUPT
    ;BSF PIE1, 5	    ;ENABLES EUSART RECIEVE INTERRUPT BIT
    
    MOVLW 0xFF
    MOVWF PR2	    ;LOADING FF FOR MAX COUNT
    
    BCF STATUS,5
    BCF STATUS,6   ;BANK 0
    
    MOVLW 0xFF
    MOVWF T2CON	    ;TMR 2 ON, 1:16 PRE, 1:5 POST
    
    ;MOVLW 0x41
    ;MOVWF ADCON0    ;FOSC8, AN0, A/D NOT IN PROGRESS, A/D ENABLED
    
    CLRF PIR1
    ;BCF PIE1,6	    ;DISABLE AD INTERRUPT
    
    ;MOVLW 0x00
    MOVLW 0xC0
    MOVWF INTCON    ;ENABLE GLOBAL & PERIPHERAL INTERRUPTS
    
    BCF STATUS,5
    BCF STATUS,6
        
    
    ;END INTERRUPT STUFF-----------------------------------------------------------------------------------------
    
    GOTO MAINLOOP
   
MAINLOOP: 
    NOP
    GOTO MAINLOOP
    
INTERRUPT:
    ;SAVE STATUS
    MOVWF SAVEW
    MOVF STATUS,W
    MOVWF SAVESTAT
    
    BTFSS PIR1,1    ;MAKES SEURE TIMER2 INT FLAG IS SET
    GOTO ISREXIT
    
    ;BCF PIR1,1
    
    DECFSZ TIME
    GOTO ISREXIT
    
    MOVLW 16	    ;15 LOOPS SHOULD BE 1 SECOND
    MOVWF TIME
    
    MOVF STATE,W
    XORLW 0x01
    MOVWF STATE
    
    BTFSC STATE,0
    GOTO DISPLAY_S
    CLRF PORTC	    ;DISPLAYS BLANK ON DOT MATRIX
    GOTO ISREXIT
    
 DISPLAY_S:   
    MOVLW 0x53	    ;HEX VALUE FOR LETTER "S"
    MOVWF PORTC
    
ISREXIT:
    ;RESTORE STATUS AND RETURN
    MOVF SAVESTAT,W
    MOVWF STATUS
    MOVF SAVEW,W
    BCF PIR1,1	    ;MIGHT FAIL, MIGHT INTERRUPT AGAIN BEFORE ITS TIME

    RETFIE 
   
END
    
   
    
    
 
    
