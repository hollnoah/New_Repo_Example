;NAME Noah Holloway
;COURSE 3371
;SEMESTER 5
;Program: I2C
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
    STATE	    EQU 0x22
    RECSTAT	    EQU 0x23
    PRESSEDKEY	    EQU 0x24
    TIME	    EQU 0x25
    WRITEPTR	    EQU 0x26
    TEMP1	    EQU 0x27
    TEMP2	    EQU 0x28
    TEMP	    EQU 0x29

 ;Start of Program
 ;Reset vector address
 PSECT resetVect,class=CODE,delta=2 ;-Wl,-presetVect=00h
 GOTO Start
 
 PSECT isrVect,class=CODE,delta=2 ;-Wl,-pisrVect=04h
 ;GOTO INTERRUPT

 ;Setup Code that runs once at power up and at reset
 PSECT code,class=CODE,delta=2 ;-Wl,-pcode=08h
 
 ;-Wl,-presetVect=00h -Wl,-pisrVect=04h -Wl,-pcode=08h
 
Start:
 
;BANK 3
    BSF STATUS,5    ;GO TO BANK 3
    BSF STATUS,6    ;GO TO BANK 3
    
    CLRF ANSELH	    ;DIGITAL I/O
    CLRF ANSEL
    
    
;BANK 2
    BSF STATUS,6    ;GO TO BANK 2
    BCF STATUS,5    ;GO TO BANK 2
    
    CLRF CM2CON1    ;SET ALL BITS TO 0
    
;BANK 1
    BSF STATUS,5    ;GO TO BANK 1
    BCF STATUS,6    ;GO TO BANK 1
    
    BSF TRISC,3	    ;RC3 (SCL) INPUT FOR I2C
    BSF TRISC,4	    ;RC4 (SDA) INPUT FOR I2C
    
    BCF TRISB,0	    ;RB0 AS OUTPUT
      
    
;BANK 0
    BCF STATUS,5    ;GO TO BANK 0
    BCF STATUS,6    ;GO TO BANK 0
    
    MOVLW 0x28	    ;SSPCON I2C MASTER MODE
    MOVWF SSPCON
    
;    CLRF SSPSTAT    ;CLEAR STATUS (SLEW OFF FOR 100KHZ)
    
    BSF SSPCON,5    ;SSPEN = 1 (ENABLE I2C MODULE)
    
    CLRF PORTB
    
    
    ;INTERRUPT STUFF----------------------------------------------------------------------------------------------
    
;    BANKSEL PIR1
;    CLRF PIR1
    
   
    ;END INTERRUPT STUFF-----------------------------------------------------------------------------------------
  
    GOTO MAINLOOP
 
    ;SENDING ADDRESS TO SLAVE

   MAINLOOP:
    
   BANKSEL PORTB
   BSF PORTB,0
   
   ;BSF STATUS,5    ;GO TO BANK 1
   ;BCF STATUS,6    ;GO TO BANK 1

   BANKSEL SSPCON2
   BSF SSPCON2,0    ;START BIT
   BTFSC SSPSTAT,3
   GOTO $-1
   
   ;BCF STATUS,5    ;GO TO BANK 0
   ;BCF STATUS,6    ;GO TO BANK 0
   
   BANKSEL PIR1
   BCF PIR1,3	    ;SSPIF BIT
   BTFSC PIR1,3
   GOTO $-1
   
   BANKSEL SSPBUF
   MOVLW 0x20
   MOVWF SSPBUF	    ;WRITES TO ADDRESS 20
   
   ;BSF STATUS,5    ;GO TO BANK 1
   ;BCF STATUS,6    ;GO TO BANK 1
   
   BANKSEL SSPSTAT
   BTFSC SSPSTAT,0  ;TESTS BF BIT TO MAKE SURE ADDRESS HAS COMPLETED WRITING
   GOTO $-1
   
   ;BCF STATUS,5    ;GO TO BANK 0
   ;BCF STATUS,6    ;GO TO BANK 0
   
   BANKSEL PIR1
   BCF PIR1,3	    ;SSPIF BIT
   BTFSC PIR1,3
   GOTO $-1
   
   ;BSF STATUS,5    ;GO TO BANK 1
   ;BCF STATUS,6    ;GO TO BANK 1
   
   BANKSEL SSPCON2
   BSF SSPCON2,2    ;STOP BIT
   
   BANKSEL SSPSTAT
   BTFSC SSPSTAT,4
   GOTO $-1
   
   ;BCF STATUS,5    ;GO TO BANK 0
   ;BCF STATUS,6    ;GO TO BANK 0
   
   BANKSEL PIR1
   BCF PIR1,3	    ;SSPIF BIT
   BTFSC PIR1,3
   GOTO $-1
   
   BANKSEL PORTB
   BCF	PORTB,0
   
   GOTO MAINLOOP
   
END

    
   
    
    
 
    
