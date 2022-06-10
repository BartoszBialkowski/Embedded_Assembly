		AREA	MAIN_CODE, CODE, READONLY
		GET		6_LPC213x.s
		
		ENTRY	
		
__main
__use_two_region_memory
		EXPORT			__main
		EXPORT			__use_two_region_memory
		
		
CURRENT_DIGIT 	RN R12
DIGIT_0 	RN R8
DIGIT_1 	RN R9	
DIGIT_2 	RN R10	
DIGIT_3 	RN R11
		
		ldr R5, =IO0DIR  ; ustawienie pinów sterujacych wyswietlaczem na wyjsciowe
		ldr R4, =0xF00F0
		str R4, [R5]
	
		ldr R5, =IO1DIR 
		ldr R4, =0xFF0000
		str R4, [R5]
		
		ldr DIGIT_0, =0x00 ; inicjalizacja licznika dekadowego
		ldr DIGIT_1, =0x00
		ldr DIGIT_2, =0x00
		ldr DIGIT_3, =0x00
		
		ldr CURRENT_DIGIT, =0x00  ; wyzerowanie licznika cyfr
		
main_loop
	
		ldr r5, =IO0CLR ; wlaczenie cyfry o numerze podanym w CURR_DIG
		ldr r4, =0xF0000
		str r4, [r5]

		ldr R5, =IO0SET 
		ldr R4, =0x80000
		mov R4, R4, LSR CURRENT_DIGIT
		str R4, [R5]
		
		ldr R4, =0xff0000  ; czyszczenie liczby na wyswietlaczu
		ldr R5, =IO1CLR
		str R4, [R5]
		
		cmp CURRENT_DIGIT, #0   ; zamiana numeru cyfry (CURR_DIG) na kod siedmiosegmentowy (R6)
		moveq R6, DIGIT_0
	
		cmp CURRENT_DIGIT, #1
		moveq R6, DIGIT_1
	
		cmp CURRENT_DIGIT, #2
		moveq R6, DIGIT_2
	
		cmp CURRENT_DIGIT, #3
		moveq R6, DIGIT_3
		
		adr R4, table 		
		add R4, R4, R6
		ldrb R6, [R4]
		
		mov R6, R6, LSL #16     	; wpisanie kodu siedmiosegmentowego (R6) do segmentów 
		ldr R5, =IO1SET
		str R6, [R5]
		
		ldr R7, =1		
		add DIGIT_0, R7
		
		cmp DIGIT_0, #10
		addeq DIGIT_1, R7
		ldreq DIGIT_0, =0x0
	
		cmp DIGIT_1, #10
		addeq DIGIT_2, R7
		ldreq DIGIT_1, =0x0
	
		cmp DIGIT_2, #10
		addeq DIGIT_3, R7
		ldreq DIGIT_2, =0x0

		cmp DIGIT_3, #10
		ldreq DIGIT_0, =0x0
		
		
		ldr R7, =1				; inkrementacja licznika cyfr (CURR_DIG) modulo 4
		add CURRENT_DIGIT, R7
		ldr R7, =4
		cmp CURRENT_DIGIT, R7
		EOREQ CURRENT_DIGIT, CURRENT_DIGIT, R7

		
		ldr R0, =5; // opóznienie
		BL delay_in_ms
		
		b				main_loop

delay_in_ms

		ldr R6, =15000
		mul R6, R0, R6
Loop
		subs R6,R6, #01
		bne				Loop

		BX LR	


table	DCB 0x3f,0x06,0x5B,0x4F,0x66,0x6d,0x7D,0x07,0x7f,0x6f

		END


