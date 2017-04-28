;**********************************************************************
;                                                                     *
;    Filename:        irrelevant.asm                                  *
;    Date:                                                            *
;    File Version:                                                    *
;                                                                     *
;    Author:                                                          *
;    Company:                                                         *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Files required: P16F84A.INC                                      *
;                                                                     *
;                                                                     *
;**********************************************************************
;                                                                     *
;    Notes:                                                           *
;                                                                     *
;**********************************************************************


    list      p=16F84A             ; list directive to define processor
    #include <p16F84a.inc>         ; processor specific variable definitions

    __CONFIG   _CP_OFF & _WDT_OFF & _PWRTE_ON & _FOSC_XT	;

; '__CONFIG' directive is used to embed configuration data within .asm file.
; The lables following the directive are located in the respective .inc file.
; See respective data sheet for additional information on configuration word.

;***** VARIABLE DEFINITIONS
;;variables are defined by name and address. SE PIC1684A datablad "register file map"


;Delay-related counters:
COUNTER_LONG	EQU 0x0C
COUNTER_MEDIUM	EQU 0x0D
COUNTER_SHORT	EQU 0x0E


;**********************************************************************
RESET_VECTOR      CODE    0x0000  ; Program counter (PC) is reset to this address.
    
;Initializing:
init 
	;Jumping to memory bank 1, where the TRIS-directories are:
	bsf		STATUS,RP0
	
	;A0 should be the input:
	movlw	b'00000011'	;we move the binary literal 0000 0011 to the working register
	movwf	TRISA		;we move the contents of the working register to TRISA
	
	;PORTB should just be an output, so we clear trisb:
	clrf	TRISB
	
	
	;Jumping back to bank 0:
	bcf		STATUS,RP0
	
	;Resetting the output:
	clrf	PORTB
	

;---------------------------------
;	Notes to self:
;	--------------------
;	A0 is the input that tells it that the weight is above the wanted weight
;	A1 is the input that tells it that there is no box on the scale
;	--------------------
;	B1 is the signal to the pushing piston. '1' means extend, '0' means retract. 
;	B2 is the signal to the holding piston. -||-
;	B3 is the signal to the motor. '1' means run, '0' means stop. 

;---------------------------------

;Setting the output to be the default state:
set_default_state
	
	call retract_pusher		;deactivating pushing piston
	call extend_holder		;activating holding piston
	call start_motor		;activating motor

;---------------------------------

;Waiting loop:
wait_for_signal
	
	btfsc	PORTA,0				;if A0 is 1
		goto perform_sequence	;then it starts the sequence of moves
	
	btfsc	PORTA,1					;if A1 is 1
		goto stop_motor_and_wait	;then it stops the motor
		goto start_motor_and_wait	;else it stops the motor


start_motor_and_wait
	call start_motor		;starting the motor
	goto wait_for_signal	;looping back
	
stop_motor_and_wait
	call stop_motor			;stopping the motor
	goto wait_for_signal	;looping back

;---------------------------------

;Starting the sequence of moves: 
perform_sequence
	
	call stop_motor 	;Stopping the motor
	
	;Waiting for things to fall down from the belt:
	call wait_1		
	
	call extend_pusher	;Pushing...
	
	;Waiting for the box to be pushed away:
	call wait_2
	
	call retract_pusher		;Retracting the pusher
	call retract_holder		;Realeasing a new box
	
	;Waiting before catching the third box in the queue
	call wait_3
	
	call extend_holder		;catching the falling box with the holder
	
	;Waiting for the main box to fall down on the plate:
	call wait_4
	
	;Going to the loop where it waits for a signal:
	goto wait_for_signal

;---------------------------------

;Here are a lot of subroutines for doing various actions:
;Their names should explain what they do...
extend_pusher
	bsf		PORTB,1
	return
retract_pusher
	bcf		PORTB,1
	return

extend_holder
	bsf		PORTB,2
	return
retract_holder
	bcf		PORTB,2
	return

start_motor
	bsf		PORTB,3
	return 
stop_motor
	bcf		PORTB,3
	return


;---------------------------------


;Delay subroutine number 1:
wait_1

	movlw	d'8'
	movwf	COUNTER_LONG	;sets COUNTER_LONG to be 8

delay_long_1
	movlw	d'255'
	movwf	COUNTER_MEDIUM	;sets COUNTER_MEDIUM to be 255

delay_medium_1
	movlw	d'255'
	movwf	COUNTER_SHORT	;sets COUNTER_SHORT to be 255

delay_short_1
	decfsz	COUNTER_SHORT		;It decrements COUNTER_SHORT.
								;If it turns out to not be 0...
	goto	delay_short_1		;then it goes to delay_short_1
								;otherwise...
	decfsz	COUNTER_MEDIUM		;it decrements COUNTER_MEDIUM.
								;If it turns out to not be 0...
	goto	delay_medium_1		;then it goes to delay_medium_1
								;otherwise...
	decfsz	COUNTER_LONG		;it decrements COUNTER_LONG.
								;If it turns out to not be 0...
	goto	delay_long_1		;then it goes to delay_long_1
	return						;otherise it returns


;---------------------------------


;Delay subroutine number 2:
wait_2

	movlw	d'5'
	movwf	COUNTER_LONG	;sets COUNTER_LONG to be 5

delay_long_2
	movlw	d'255'
	movwf	COUNTER_MEDIUM	;sets COUNTER_MEDIUM to be 255

delay_medium_2
	movlw	d'255'
	movwf	COUNTER_SHORT	;sets COUNTER_SHORT to be 255

delay_short_2
	decfsz	COUNTER_SHORT		;It decrements COUNTER_SHORT.
								;If it turns out to not be 0...
	goto	delay_short_2		;then it goes to delay_short_2
								;otherwise...
	decfsz	COUNTER_MEDIUM		;it decrements COUNTER_MEDIUM.
								;If it turns out to not be 0...
	goto	delay_medium_2		;then it goes to delay_medium_2
								;otherwise...
	decfsz	COUNTER_LONG		;it decrements COUNTER_LONG.
								;If it turns out to not be 0...
	goto	delay_long_2		;then it goes to delay_long_2
	return						;otherwise it returns

;---------------------------------


;Delay subroutine number 3:
wait_3

	movlw	d'1'
	movwf	COUNTER_LONG	;sets COUNTER_LONG to be 1

delay_long_3
	movlw	d'255'
	movwf	COUNTER_MEDIUM	;sets COUNTER_MEDIUM to be 255

delay_medium_3
	movlw	d'255'
	movwf	COUNTER_SHORT	;sets COUNTER_SHORT to be 255

delay_short_3
	decfsz	COUNTER_SHORT		;It decrements COUNTER_SHORT.
								;If it turns out to not be 0...
	goto	delay_short_3		;then it goes to delay_short_3
								;otherwise...
	decfsz	COUNTER_MEDIUM		;it decrements COUNTER_MEDIUM.
								;If it turns out to not be 0...
	goto	delay_medium_3		;then it goes to delay_medium_3
								;otherwise...
	decfsz	COUNTER_LONG		;it decrements COUNTER_LONG.
								;If it turns out to not be 0...
	goto	delay_long_3		;then it goes to delay_long_3
	return						;otherise it returns


;---------------------------------

;Delay subroutine number 4:
wait_4

	movlw	d'6'
	movwf	COUNTER_LONG	;sets COUNTER_LONG to be 5

delay_long_4
	movlw	d'255'
	movwf	COUNTER_MEDIUM	;sets COUNTER_MEDIUM to be 255

delay_medium_4
	movlw	d'255'
	movwf	COUNTER_SHORT	;sets COUNTER_SHORT to be 255

delay_short_4
	decfsz	COUNTER_SHORT		;It decrements COUNTER_SHORT.
								;If it turns out to not be 0...
	goto	delay_short_4		;then it goes to delay_short_4
								;otherwise...
	decfsz	COUNTER_MEDIUM		;it decrements COUNTER_MEDIUM.
								;If it turns out to not be 0...
	goto	delay_medium_4		;then it goes to delay_medium_4
								;otherwise...
	decfsz	COUNTER_LONG		;it decrements COUNTER_LONG.
								;If it turns out to not be 0...
	goto	delay_long_4		;then it goes to delay_long_4
	return	

;---------------------------------
	
END

