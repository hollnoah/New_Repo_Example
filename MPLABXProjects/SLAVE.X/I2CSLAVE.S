;NAME Noah Holloway
;COURSE 3371
;SEMESTER 5
;Program: I2C SLAVE
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
    SERVO_POS_0	    EQU 0x23
    SERVO_POS_1	    EQU 0x24
    SERVO_POS_2	    EQU 0x25
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
        ;--- Disable analog ---
        BANKSEL ANSEL
        CLRF    ANSEL
        CLRF    ANSELH

        ;--- Disable comparators ---
        BANKSEL CM1CON0
        CLRF    CM1CON0
        CLRF    CM2CON0

        ;--- PORTDIR ---
        BANKSEL TRISA
        MOVLW   0xFF
        MOVWF   TRISA

        BANKSEL TRISB
        MOVLW   0x00
        MOVWF   TRISB    ; whole port output

        BANKSEL TRISC
        MOVLW   0x18     ; RC3=SCL input, RC4=SDA input
        MOVWF   TRISC

        ;--- CLEAR PORTS ---
        BANKSEL PORTB
        CLRF    PORTB

        ;-----------------------------------------------------
        ;   I2C SLAVE CONFIGURATION
        ;-----------------------------------------------------
        BANKSEL SSPSTAT
        MOVLW   0x80        ; SMP = 1 (mid-sample), all else 0
        MOVWF   SSPSTAT

        BANKSEL SSPCON
        MOVLW   0x36        ; 0x36 = I2C Slave mode, 7-bit addr
                            ; CKP=1 (release clock)
                            ; Clock stretching enabled by HW
        MOVWF   SSPCON

        BANKSEL SSPADD
        MOVLW   0x40        ; Address = 0x20 << 1
        MOVWF   SSPADD

        ; DO NOT TOUCH SSPCON2 (hardware controls ACK)
        ; DO NOT TOUCH CKP except when explicitly required

        BANKSEL PORTB
        CLRF    PORTB

;=========================================================
;   MAIN POLLING LOOP
;=========================================================
MainLoop:

        ;-----------------------------------------------------
        ; WAIT FOR SSPIF (MSSP interrupt flag)
        ;-----------------------------------------------------
WaitIF:
        BANKSEL PIR1
        BTFSS   PIR1,3
        GOTO    WaitIF

        ;-----------------------------------------------------
        ; READ SSPSTAT TO SEE IF IT WAS ADDRESS OR DATA
        ;-----------------------------------------------------
        BANKSEL SSPSTAT
        MOVF    SSPSTAT, W

        ;-----------------------------------------------------
        ; ALWAYS READ SSPBUF IMMEDIATELY
        ; (REQUIRED FOR VALID ACK)
        ;-----------------------------------------------------
        BANKSEL SSPBUF
        MOVF    SSPBUF, W
        MOVWF   TEMP

        ;-----------------------------------------------------
        ; CLEAR SSPIF
        ;-----------------------------------------------------
        BANKSEL PIR1
        BCF     PIR1,3

        ;-----------------------------------------------------
        ; RELEASE CLOCK (CKP=1) ? REQUIRED
        ; Only AFTER SSPBUF has been read.
        ;-----------------------------------------------------
        BANKSEL SSPCON
        BSF     SSPCON,4       ; CKP=1

        ;-----------------------------------------------------
        ; At this point the hardware generates ACK automatically.
        ; No manual ACKEN/ACKDT is legal in slave mode.
        ;-----------------------------------------------------

        ; OPTIONAL DEBUG: show byte on PORTB
        BANKSEL PORTB
        MOVF    TEMP, W
        MOVWF   PORTB

        GOTO    MainLoop

   END 
   
    
    
 
    
