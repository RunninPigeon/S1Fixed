; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Swing_Move:
		move.b	(v_oscillate+$1A).w,d0
		move.w	#$80,d1
		btst	#staFlipX,obStatus(a0)
		beq.s	Swing_Move2
		neg.w	d0
		add.w	d1,d0
		bra.s	Swing_Move2
; End of function Swing_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Obj48_Move:
		tst.b	objoff_3D(a0)
		bne.s	loc_7B9C
		move.w	objoff_3E(a0),d0
		addq.w	#8,d0
		move.w	d0,objoff_3E(a0)
		add.w	d0,swing_angle(a0)
		move.b	swing_angle(a0),obAngle(a0)
		cmpi.w	#$200,d0
		bne.s	loc_7BB6
		move.b	#1,objoff_3D(a0)
		bra.s	loc_7BB6
; ===========================================================================

loc_7B9C:
		move.w	objoff_3E(a0),d0
		subq.w	#8,d0
		move.w	d0,objoff_3E(a0)
		add.w	d0,swing_angle(a0)
		move.b	swing_angle(a0),obAngle(a0)
		cmpi.w	#-$200,d0
		bne.s	loc_7BB6
		clr.b	objoff_3D(a0)

loc_7BB6:
		move.b	obAngle(a0),d0
; End of function Obj48_Move


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||


Swing_Move2:
		bsr.w	CalcSine
		move.w	objoff_38(a0),d2
		move.w	objoff_3A(a0),d3
		lea		obSubtype(a0),a2
		moveq	#0,d6
		move.b	(a2)+,d6

loc_7BCE:
		moveq	#0,d4
		move.b	(a2)+,d4
		lsl.w	#object_size_bits,d4
		addi.l	#v_objspace&$FFFFFF,d4
		movea.l	d4,a1
		moveq	#0,d4
		move.b	objoff_3C(a1),d4
		move.l	d4,d5
		muls.w	d0,d4
		asr.l	#8,d4
		muls.w	d1,d5
		asr.l	#8,d5
		add.w	d2,d4
		add.w	d3,d5
		move.w	d4,obY(a1)
		move.w	d5,obX(a1)
		dbf		d6,loc_7BCE
		rts	
; End of function Swing_Move2

; ===========================================================================

Swing_ChkDel:
		offscreen.s	Swing_DelAll,objoff_3A(a0)	; ProjectFM S3K Objects Manager
		bra.s	Swing_Display					; Clownacy DisplaySprite Fix
; ===========================================================================

Swing_DelAll:
		moveq	#0,d2
		lea		obSubtype(a0),a2
		move.b	(a2)+,d2

Swing_DelLoop:
		moveq	#0,d0
		move.b	(a2)+,d0
		lsl.w	#object_size_bits,d0
		addi.l	#v_objspace&$FFFFFF,d0
		movea.l	d0,a1
		bsr.w	DeleteChild
		dbf		d2,Swing_DelLoop ; repeat for length of	chain
		rts	
; ===========================================================================

Swing_Delete:	; Routine 6
		bra.w	DeleteObject
; ===========================================================================

Swing_Display:	; Routine $A
		tst.b	obColType(a0)
		beq.w	DisplaySprite

		cmpi.b	#(colHarmful|colSz_20x20),obColType(a0)		; is this the wrecking ball (1X)
		bne.s	.notwreckingball
; The following only applies to the wrecking ball
		moveq	#0,d0
		tst.b	obFrame(a0)				; is ball showing checkered?
		bne.s	.vanish					; if yes, branch to alt frame (frame 0)

	; RetroKoH angled ball mod (Incomplete)
		move.b	(v_oscillate+$1A).w,d0	; fetch chain's current angle; store it in d0
		; no subtraction, as this value already ranges from 0-$80
		lsr.b	#1,d0					; cut range down to 0-$40
		
		lea		(GBall_Angles).l,a2		; a2 = GBall_Angles address
		lea		(a2,d0.w),a2			; a2 = GBall_Angles + angle offset
		move.b	(a2),d0
	; angled ball mod end

.vanish:
		move.b	d0,obFrame(a0)

; The following is used by all swinging hazards
.notwreckingball:
		lea		(v_col_response_list).w,a1
		cmpi.w	#$7E,(a1)		; Is list full?
		bhs.w	DisplaySprite	; If so, return
		addq.w	#2,(a1)			; Count this new entry
		adda.w	(a1),a1			; Offset into right area of list
		move.w	a0,(a1)			; Store RAM address in list
		bra.w	DisplaySprite
