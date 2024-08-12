; ---------------------------------------------------------------------------
; Subroutine to fade to white (Special Stage) -- Mode 01: Green (RetroKoH)
; Slight optimization to WhiteOut_AddColour by RetroKoH
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


PaletteWhiteOut:
		move.w	#$3F,(v_pfade_start).w		; start position = 0; size = $40
		move.w	#$15,d4

.mainloop:
		move.b	#$12,(v_vbla_routine).w
		bsr.w	WaitForVBla
		bsr.s	WhiteOut_ToWhite
		bsr.w	RunPLC
		dbf		d4,.mainloop
		rts	
; End of function PaletteWhiteOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_ToWhite:
		moveq	#0,d0
		lea		(v_palette).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.addcolour:
		bsr.s	WhiteOut_AddColour			; add to colour
		dbf		d0,.addcolour				; repeat for size of palette

		moveq	#0,d0
		lea		(v_palette_water).w,a0
		move.b	(v_pfade_start).w,d0
		adda.w	d0,a0
		move.b	(v_pfade_size).w,d0

.addcolour2:
		bsr.s	WhiteOut_AddColour
		dbf		d0,.addcolour2
		rts	
; End of function WhiteOut_ToWhite


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


WhiteOut_AddColour:
		cmpi.w	#cWhite,(a0)	; Does this colour entry need to be faded out?
		beq.s	.next			; if not, branch and jump to the next palette entry

.addred:
		move.b	1(a0),d1	; d1 = GR byte
		andi.b	#$E,d1		; d1 = current red
		cmpi.b	#$E,d1
		beq.s	.addblue	; if red is already whited out, check blue
		addq.b	#2,1(a0)	; increase red value
		bra.s	.next		; branch and exit
; ===========================================================================

.addblue:
		move.b	(a0),d1		; d1 = 0B byte
		andi.b	#$E,d1		; d1 = blue (done for error-proofing)
		cmpi.b	#$E,d1
		beq.s	.addgreen	; if blue is already whited out, that means only green remains
		addq.b	#2,(a0)		; increase blue value
		bra.s	.next		; branch and exit	
; ===========================================================================

.addgreen:
		addi.b	#$20,1(a0)	; increase green value	
; ===========================================================================

.next:
		addq.w	#2,a0		; next colour
		rts	
; End of function WhiteOut_AddColour
