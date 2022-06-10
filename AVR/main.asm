
.cseg                           ; segment pamiêci kodu programu 

.org 0          rjmp _main               ; skok po resecie (do programu g³ównego)
.org OC1Aaddr   rjmp _timer_isr   ; skok do obs³ugi przerwania timera


_timer_isr:               ; procedura obs³ugi przerwania timera
    cli
    push R16
    push R17
    push R18
    push R19
    push R21
    push R20
    ldi R21, 1
    clr R20

    add PulseEdgeCtrL, R21
    adc PulseEdgeCtrH, R20
    mov R16, R0
    mov R17, R1
    ldi R18,0x10
    ldi R19,0x27
    rcall Divide
    rcall NumberToDigits
    mov R16, R22
    rcall DigitTo7segCode
    mov Digit_0, R16
    mov R16, R23
    rcall DigitTo7segCode
    mov Digit_1, R16
    mov R16, R24
    rcall DigitTo7segCode
    mov Digit_2, R16
    mov R16, R25  
    rcall DigitTo7segCode
    mov Digit_3, R16              
    pop R20
    pop R21
    pop R19
    pop R18
    pop R17
    pop R16
    sei

    reti             ; powrót z procedury obs³ugi przerwania (reti zamiast ret)

_main:

    push R16
    ldi R16, 0x0
    out TCCR1A, R16
    ldi R16, 0x0C
    out TCCR1B,  R16
    ldi R16, 0x7A //0x7A //0x00 
    out OCR1AH,  R16
    ldi R16, 0x12 //0x12 //0xff 
    out OCR1AL,  R16
    ldi R16, 0x40
    out TIMSK, R16
    pop R16
    sei



    .equ Digits_P = PORTB
    .equ Segments_P = PORTD
   
   

    .def Digit_0=R5
    .def Digit_1=R4
    .def Digit_2=R3
    .def Digit_3=R2

    ldi R16, 0x2
    mov R6, R16
    ldi R16, 0x4
    mov R7, R16
    ldi R16, 0x8
    mov R8, R16
    ldi R16, 0x10
    mov R9, R16

    .def Segment_0 = R6
    .def Segment_1 = R7
    .def Segment_2 = R8
    .def Segment_3 = R9


    ldi R17, 0x7f
    out DDRB, R17
    out DDRD, R17



    .def PulseEdgeCtrL=R0
    .def PulseEdgeCtrH=R1
    
    .macro SET_DIGIT
    push R16
    out Digits_P, Segment_@0
    clr R16
    out Segments_P, R16
    out Segments_P,  Digit_@0
    rcall DelayInMs
    pop R16
    .endmacro

MainLoop:
    SET_DIGIT 0 
    SET_DIGIT 1
    SET_DIGIT 2 
    SET_DIGIT 3
   nop

 End:rjmp MainLoop

 
NumberToDigits:
    push R18
    push R19
    ;*** NumberToDigits ***
    ;input : Number: R16-17
    ;output: Digits: R16-19
    ;internals: X_R,Y_R,Q_R,R_R - see _Divide
    ; internals
.def Dig0=R22 ; Digits temps
.def Dig1=R23 ; 
.def Dig2=R24 ; 
.def Dig3=R25 ;


    ldi R18, 0xE8
    ldi R19, 0x03

    rcall Divide
    mov Dig0, R18

    ldi R18, 0x64
    clr R19

    rcall Divide
    mov Dig1, R18

    ldi R18, 0xA
    clr R19

    rcall Divide
    mov Dig2, R18
    mov Dig3, R16


    pop R19
    pop R18
    ret

Divide:
    push R20
    push R21
    push R24
    push R25


    .def XL=R16 ; divident 
    .def XH=R17 
    .def YL=R18 ; divisor
    .def YH=R19 
    ; internal
    .def QCtrL=R24
    .def QCtrH=R25

    clr QCtrL
    clr QCtrH

 rjmp condition
    content:
        sub XL,YL
        sbc XH,YH
        adiw QCtrH:QCtrL, $01

    condition:  cp XL,YL ; Compare low byte
                cpc XH,YH ; Compare high byte
    brsh content

    ; outputs
    .def RL=R16 ; remainder 
    .def RH=R17 
    .def QL=R18 ; quotient
    .def QH=R19 

    mov QL, QCtrL
    mov QH, QctrH

    pop R25
    pop R24
    pop R21
    pop R20

    ret


DigitTo7segCode:

ldi R30, low(Table<<1) // inicjalizacja rejestru Z 
ldi R31, high(Table<<1)

    ZIncrementation:
        dec R16
        brbs 2, EndOfZIncrementation
        adiw R30:R31, 1 // inkrementacja Z
        rjmp  ZIncrementation
    EndOfZIncrementation:

lpm R16, Z
ret
Table: 
.db 0x3f, 0x6, 0x5b, 0x4f,0x66, 0x6d, 0x7d,  0x7, 0xff, 0x6f


DelayInMs:
    push R24
    push R25

    ldi R24, 2
    ldi R25, 0

Loop:rcall DelayOneMs
    sbiw R25:R24, 1
    brne Loop

               pop R25
               pop R24
               
               ret

DelayOneMs:

    push R24
    push R25
    ldi R24, $CE
    ldi R25, $07

    Loop2: 
        sbiw R24:R25, $01
    brne Loop2

    pop R25
    pop R24
    clz
ret