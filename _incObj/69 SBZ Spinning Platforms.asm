; ---------------------------------------------------------------------------
; Object 69 - spinning platforms and trapdoors (SBZ)
; ---------------------------------------------------------------------------

SpinPlatform:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Spin_Index(pc,d0.w),d1
		jmp		Spin_Index(pc,d1.w)
; ===========================================================================
Spin_Index:		offsetTable
		offsetTableEntry.w Spin_Main
		offsetTableEntry.w Spin_Trapdoor
		offsetTableEntry.w Spin_Spinner

spin_timer = objoff_30		; time counter until change
spin_timelen = objoff_32	; time between changes (general)
; ===========================================================================

Spin_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Trap,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Trap_Door,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$40,obActWid(a0)			; Ralakimus Trapdoor Glitch Fix
		moveq	#$F,d0
		and.b	obSubtype(a0),d0
		add.w	d0,d0						; multiply by 60 (1 second)
		add.w	d0,d0						; Optimization from S1 in S.C.E.
		move.w	d0,d1
		lsl.w	#4,d0
		sub.w	d1,d0
		move.w	d0,spin_timelen(a0)
		tst.b	obSubtype(a0)		; is subtype $8x?
		bpl.s	Spin_Trapdoor		; if not, branch

		addq.b	#2,obRoutine(a0)	; goto Spin_Spinner next
		move.l	#Map_Spin,obMap(a0)
		move.w	#make_art_tile(ArtTile_SBZ_Spinning_Platform,0,0),obGfx(a0)
		move.b	#$10,obActWid(a0)
		move.b	#2,obAnim(a0)
		moveq	#0,d0
		move.b	obSubtype(a0),d0	; get object type
		move.w	d0,d1
		andi.w	#$F,d0				; read only the	2nd digit
		add.w	d0,d0				; multiply by 6
		move.w	d0,d1				; Optimization from S1 in S.C.E.
		add.w	d0,d0
		add.w	d1,d0
		move.w	d0,spin_timer(a0)
		move.w	d0,spin_timelen(a0)	; set time delay
		andi.w	#$70,d1
		addi.w	#$10,d1
		lsl.w	#2,d1
		subq.w	#1,d1
		move.w	d1,objoff_36(a0)
		bra.s	Spin_Spinner
; ===========================================================================

Spin_Trapdoor:	; Routine 2
		subq.w	#1,spin_timer(a0)		; decrement timer
		bpl.s	.animate				; if time remains, branch

		move.w	spin_timelen(a0),spin_timer(a0)
		bchg	#0,obAnim(a0)
		tst.b	obRender(a0)
		bpl.s	.animate
		move.w	#sfx_Door,d0
		jsr		(PlaySound_Special).w	; play door sound

.animate:
		lea		Ani_Spin(pc),a1
		jsr		(AnimateSprite).w
		tst.b	obFrame(a0)	; is frame number 0 displayed?
		bne.s	.notsolid	; if not, branch
		move.w	#$4B,d1
		move.w	#$C,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		bra.w	RememberState
; ===========================================================================

.notsolid:
		btst	#staSonicOnObj,obStatus(a0)	; is Sonic standing on the trapdoor?
		beq.w	RememberState				; if not, branch
		lea		(v_player).w,a1
		bclr	#staOnObj,obStatus(a1)
		bclr	#staSonicOnObj,obStatus(a0)	; removed obSolid
		bra.w	RememberState
; ===========================================================================

Spin_Spinner:	; Routine 4
		move.w	(v_framecount).w,d0
		and.w	objoff_36(a0),d0
		bne.s	.delay
		move.b	#1,objoff_34(a0)

.delay:
		tst.b	objoff_34(a0)
		beq.s	.animate
		subq.w	#1,spin_timer(a0)
		bpl.s	.animate
		move.w	spin_timelen(a0),spin_timer(a0)
		clr.b	objoff_34(a0)
		bchg	#0,obAnim(a0)

.animate:
		lea		Ani_Spin(pc),a1
		jsr		(AnimateSprite).w
		tst.b	obFrame(a0)	; check	if frame number	0 is displayed
		bne.s	.notsolid2	; if not, branch
		move.w	#$1B,d1
		move.w	#7,d2
		move.w	d2,d3
		addq.w	#1,d3
		move.w	obX(a0),d4
		bsr.w	SolidObject
		bra.w	RememberState
; ===========================================================================

.notsolid2:
		btst	#staSonicOnObj,obStatus(a0)
		beq.w	RememberState
		lea		(v_player).w,a1
		bclr	#staOnObj,obStatus(a1)
		bclr	#staSonicOnObj,obStatus(a0)	; removed obSolid
		bra.w	RememberState
