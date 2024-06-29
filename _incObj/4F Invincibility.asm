; ---------------------------------------------------------------------------
; Object 4F - Invincibility Stars (Moved from Shield to its own object)
; ---------------------------------------------------------------------------

StarsItem:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Stars_Index(pc,d0.w),d1
		jmp		Stars_Index(pc,d1.w)
; ===========================================================================
Stars_Index:
		dc.w	Stars_Main-Stars_Index
		dc.w	Stars_Next-Stars_Index
; ===========================================================================

Stars_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.b	#4,obRender(a0)
		move.w	#$80,obPriority(a0)	; RetroKoH S2 Priority Manager
		move.b	#$10,obActWid(a0)
		move.w	#make_art_tile(ArtTile_Shield,0,0),obGfx(a0)
		move.l	#Map_Shield,obMap(a0)
		move.l	#Art_Stars,obArtLoc(a0)
		move.l	#ShieldDynPLC,obDPLCLoc(a0)
		rts
; ===========================================================================

Stars_Delete:
		jmp		(DeleteObject).l
; ===========================================================================

Stars_Next:	; Routine 2
		btst	#sta2ndInvinc,(v_player+obStatus2nd).w	; does Sonic have invincibility?
		beq.s	Stars_Delete							; if not, branch
		move.w	(v_trackpos).w,d0						; get index value for tracking data
		move.b	obAnim(a0),d1
		subq.b	#1,d1

;.trail:
		lsl.b	#3,d1		; multiply animation number by 8
		move.b	d1,d2
		add.b	d1,d1
		add.b	d2,d1		; multiply by 3
		addq.b	#4,d1
		sub.b	d1,d0
		move.b	objoff_30(a0),d1
		sub.b	d1,d0		; use earlier tracking data to create trail
		addq.b	#4,d1
		cmpi.b	#$18,d1
		blo.s	.a
		moveq	#0,d1

.a:
		move.b	d1,objoff_30(a0)

.b:
		lea		(v_tracksonic).w,a1
		lea		(a1,d0.w),a1
		move.w	(a1)+,obX(a0)
		move.w	(a1)+,obY(a0)
		move.b	(v_player+obStatus).w,obStatus(a0)

	; Mercury Shield/Invincibility Positioning Fix
		move.b	obStatus(a0),d0
		move.w	#$A,d1
		cmpi.b	#aniID_Balance,(v_player+obAnim).w
		bne.s	.noshift
		
.shift:
		sub.w	d1,obX(a0)
		btst	#staFlipX,d0		; X-Flip sprite bit
		beq.s	.noshift
		add.w	d1,d1
		add.w	d1,obX(a0)
.noshift:
	; Shield/Invincibility Positioning Fix End

		lea		(Ani_Shield).l,a1
		jsr		(AnimateSprite).l
		bsr.w	Stars_LoadGfx		; RetroKoH VRAM Overhaul
		jmp		(DisplaySprite).l
; ===========================================================================