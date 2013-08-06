; -----------------------------------------------------------------------------
; TV-B-Gone Advance
; https://github.com/mepsoid/TV-B-Gone-Advance
;
; Created: 23.06.2013 14:31:01
; Author: meps (htp://meps.ru)
;
; Revisions history:
;
; v1.0
; - compact byte-oriented format for remote control codes storage;
; - automated shutdown;
; - boost adapter for complete draining out batteries;
; - composite IR LED;
; -----------------------------------------------------------------------------

.equ	TIME_AIMING = 20000 ; Time (x100 microseconds) before sending packets to aim to TV
.equ	TIME_FAREWELL = 15000 ; Time (x100 microseconds) to indicate the end of sequences

.equ	XTAL = 8000000.0 ; External oscillator frequency (CKDIV8 cleared)

.equ	IR_BIT = 0 ; IR LED (PB0=OC0A)
.equ	LED_BIT = 1 ; Status light
.equ	OFF_BIT = 2 ; Self shutdown

.def	data = r0 ; for LPM command
.def	tmp1 = r16
.def	tmp2 = r17
.def	time_mult = r21
.def	time_on = r22
.def	time_off = r23
.def	delay_low = r24
.def	delay_high = r25

;------------------------------------------------------------------------------
; CODE
;------------------------------------------------------------------------------
.cseg
.org 0

;------------------------------------------------------------------------------
; Interrupt vector

	rjmp main ; Reset
	reti ; INT0 External Interrupt Request 0
	reti ; PCINT0 Pin Change Interrupt Request 0
	reti ; TIMER1_COMPA Timer/Counter1 Compare Match A
	reti ; TIMER1_OVF Timer/Counter1 Overflow
	reti ; TIMER0_OVF Timer/Counter0 Overflow
	reti ; EE_RDY EEPROM Ready
	reti ; ANA_COMP Analog Comparator
	reti ; ADC ADC Conversion Complete
	reti ; TIMER1_COMPB Timer/Counter1 Compare Match B
	reti ; TIMER0_COMPA Timer/Counter0 Compare Match A
	reti ; TIMER0_COMPB Timer/Counter0 Compare Match B
	reti ; WDT Watchdog Time-out
	reti ; USI_START USI START
	reti ; USI_OVF USI Overflow

.org INT_VECTORS_SIZE

;------------------------------------------------------------------------------
; x100 microseconds delay subroutine
;
; IN:   delay_high:delay_low - delay timing
; OUT:  -
; USES: tmp1, delay_high, delay_low
delay_x100us:

	ldi tmp1, 199 ; experimental value

delay_inner:

	nop
	dec tmp1
	brne delay_inner

    sbiw delay_low, 1
	brne delay_x100us

	ret

;------------------------------------------------------------------------------
; x10 microseconds multiplication delay subroutine
;
; IN:   delay_high - multiplier 1
;       delay_low - multiplier 2
; OUT:  -
; USES: tmp1, tmp2, delay_high, delay_low
mult_x10us:

	; Multiply arguments
	mov tmp1, delay_high

	clr delay_high
	ldi tmp2, 8
	lsr delay_low

mult_prepare:

	brcc mult_skip
	add delay_high, tmp1

mult_skip:

	ror delay_high
	ror delay_low
	dec tmp2
	brne mult_prepare

	; Delay cycle
mult_outer:

	nop
	ldi tmp1, 25 ; experimental value

mult_inner:

	dec tmp1
	brne mult_inner

    sbiw delay_low, 1
	brne mult_outer

	ret

;------------------------------------------------------------------------------
; Blink status led with delay of 250 ms subroutine
;
; IN:   -
; OUT:  -
; USES: tmp1, delay_high, delay_low
blink_once:

	; Turn status LED on
	cbi PORTB, LED_BIT

	; 250 milliseconds delay between packets
	ldi delay_high, high(2500)
	ldi delay_low, low(2500)
	rcall delay_x100us

	; Turn status LED off
	sbi PORTB, LED_BIT

	ret

;------------------------------------------------------------------------------
; Send single pattern subroutine
;
; IN:   time_mult - base multiplier
;       time_on - modulation time (x10 microseconds)
;       time_off - delay time (x10 microseconds)
; OUT:  -
; USES: tmp1, tmp2, delay_high, delay_low
pattern_send:

	; Start Timer0 outputting the carrier frequency to IR emitter on OC0A (PB0)
	; COM0A1:0=01 to toggle OC0A on Compare Match
	; COM0B1:0=00 to disconnect OC0B
	; WGM01:00=10 for CTC Mode (WGM02=0 in TCCR0B)
	ldi tmp1, (1 << COM0A0) | (1 << WGM01)
	out TCCR0A, tmp1
	; FOC0A=0 (no force compare)
	; F0C0B=0 (no force compare)
	; WGM2=0 for CTC Mode (WGM01:00=10 in TCCR0A)
	; CS02:00=100 for divide by 1 prescaler
	ldi tmp1, (1 << CS00)
	out TCCR0B, tmp1

	mov delay_low, time_mult
	mov delay_high, time_on
	rcall mult_x10us

	; Turn off output to IR emitter on 0C0A (PB0) for offTime
	; CS02:CS00=000 to stop Timer0
	in tmp1, TCCR0B
	cbr tmp1, (1 << CS00) | (1 << CS01) | (1 << CS02)
	out TCCR0B, tmp1
	; COM0A1:0=00 to disconnect 0OC0A from PB0
	in tmp1, TCCR0A
	cbr tmp1, (1 << COM0A0) | (1 << COM0A1)
	out TCCR0A, tmp1
	; Turn off IR emitter on 0C0A (PB2, pin 14) in case it was High
	cbi PORTB, IR_BIT

	; Check for zero delay time
	tst time_off
	breq pattern_end

	mov delay_low, time_mult
	mov delay_high, time_off
	rcall mult_x10us

pattern_end:

	ret

;------------------------------------------------------------------------------
; Main routine
main:

	; Prepare stack
	ldi tmp1, low(RAMEND)
	out SPL, tmp1
	.ifdef SPH
	ldi tmp1, high(RAMEND)
	out SPH, tmp1
	.endif

	; Setup output
	ldi tmp1, (1 << IR_BIT) | (1 << LED_BIT) | (1 << OFF_BIT)
	out DDRB, tmp1
	ldi tmp1, (1 << LED_BIT) | (1 << OFF_BIT)
	out PORTB, tmp1

	; Wait a bit for aiming
	ldi delay_high, high(TIME_AIMING)
	ldi delay_low, low(TIME_AIMING)
	rcall delay_x100us

	; Start transmitting codes
	ldi zh, high(data_cseg << 1)
	ldi zl, low(data_cseg << 1)

main_codes:

	; Blink to show process
	rcall blink_once

	; Setup sequence timer prescaler
	lpm
	adiw zl, 1
	tst data
	breq main_finish
	out OCR0A, data

	; Read base multiplier
	lpm
	adiw zl, 1
	mov time_mult, data

main_patterns:

	; Read timings and transmit single pattern
	lpm
	adiw zl, 1
	mov time_on, data
	lpm
	adiw zl, 1
	mov time_off, data
	rcall pattern_send

	; Check for code finish
	tst data
	brne main_patterns

	rjmp main_codes

main_finish:

	; Show the end of sequences
	cbi PORTB, LED_BIT
	ldi delay_high, high(TIME_FAREWELL)
	ldi delay_low, low(TIME_FAREWELL)
	rcall delay_x100us
	sbi PORTB, LED_BIT

	; Shutdown
	ldi tmp1, (1 << OFF_BIT)
	out DDRB, tmp1
	cbi PORTB, OFF_BIT

end:

	rjmp end

;------------------------------------------------------------------------------
; Code segment with codes

data_cseg:

.include "codes\tvbgone_100.inc"
.include "codes\tvbgone_101.inc"
.include "codes\tvbgone_102.inc"
.include "codes\tvbgone_103.inc"
.include "codes\tvbgone_104.inc"
.include "codes\tvbgone_107.inc"
.include "codes\tvbgone_108.inc"
.include "codes\tvbgone_109.inc"
.include "codes\tvbgone_110.inc"
.include "codes\tvbgone_111.inc"
.include "codes\tvbgone_112.inc"
.include "codes\tvbgone_113.inc"
.include "codes\tvbgone_114.inc"
.include "codes\tvbgone_116.inc"
.include "codes\tvbgone_117.inc"
.include "codes\tvbgone_118.inc"
.include "codes\tvbgone_119.inc"
.include "codes\tvbgone_120.inc"
.include "codes\tvbgone_121.inc"
.include "codes\tvbgone_122.inc"
.include "codes\tvbgone_123.inc"
.include "codes\tvbgone_124.inc"
.include "codes\tvbgone_125.inc"
.include "codes\tvbgone_126.inc"
.include "codes\tvbgone_127.inc"
.include "codes\tvbgone_128.inc"
.include "codes\tvbgone_129.inc"
.include "codes\tvbgone_130.inc"
.include "codes\tvbgone_131.inc"
.include "codes\tvbgone_132.inc"
.include "codes\tvbgone_133.inc"
.include "codes\tvbgone_134.inc"
.include "codes\tvbgone_135.inc"
.include "codes\tvbgone_136.inc"
.include "codes\tvbgone_137.inc"
.include "codes\tvbgone_138.inc"
.include "codes\tvbgone_139.inc"

.db 0 ; End of the codes sequence
