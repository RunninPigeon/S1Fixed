; ---------------------------------------------------------------------------
; Object 62 - gargoyle head (LZ)
; ---------------------------------------------------------------------------

Gargoyle:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	Gar_Index(pc,d0.w),d1
		jmp		Gar_Index(pc,d1.w)
; ===========================================================================
Gar_Index:	offsetTable
		offsetTableEntry.w Gar_Main
		offsetTableEntry.w Gar_MakeFire
		offsetTableEntry.w Gar_FireBall
		offsetTableEntry.w Gar_AniFire

Gar_SpitRate:	dc.b 30, 60, 90, 120, 150, 180,	210, 240
; ===========================================================================

Gar_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)
		move.l	#Map_Gar,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Gargoyle,2,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority3,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#$10,obActWid(a0)
		move.b	obSubtype(a0),d0 ; get object type
		andi.w	#$F,d0		; read only the	2nd digit
		move.b	Gar_SpitRate(pc,d0.w),obDelayAni(a0) ; set fireball spit rate
		move.b	obDelayAni(a0),obTimeFrame(a0)
		andi.b	#$F,obSubtype(a0)

Gar_MakeFire:	; Routine 2
		subq.b	#1,obTimeFrame(a0)				; decrement timer
		bne.w	RememberState					; if time remains, branch

		move.b	obDelayAni(a0),obTimeFrame(a0)	; reset timer
		bsr.w	ChkObjectVisible
		bne.w	RememberState
		bsr.w	FindFreeObj
		bne.w	RememberState
		_move.b	#id_Gargoyle,obID(a1)			; load fireball object
		addq.b	#4,obRoutine(a1)				; use Gar_FireBall routine
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		move.b	obRender(a0),obRender(a1)
		move.b	obStatus(a0),obStatus(a1)
		bra.w	RememberState	
; ===========================================================================

Gar_FireBall:	; Routine 4
		addq.b	#2,obRoutine(a0)
		move.b	#8,obHeight(a0)
		move.b	#8,obWidth(a0)
		move.l	#Map_Gar,obMap(a0)
		move.w	#make_art_tile(ArtTile_LZ_Gargoyle,0,0),obGfx(a0)
		ori.b	#4,obRender(a0)
		move.w	#priority4,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#(colHarmful|colSz_4x4),obColType(a0)

		bset	#shPropFlame,obShieldProp(a0)	; Negated by Flame Shield

		move.b	#8,obActWid(a0)
		move.b	#2,obFrame(a0)
		addq.w	#8,obY(a0)
		move.w	#$200,obVelX(a0)
		btst	#staFlipX,obStatus(a0)	; is gargoyle facing left?
		bne.s	.noflip		; if not, branch
		neg.w	obVelX(a0)

.noflip:
		move.w	#sfx_Fireball,d0
		jsr		(PlaySound_Special).w	; play lava ball sound

Gar_AniFire:	; Routine 6
		move.b	(v_framebyte).w,d0
		andi.b	#7,d0
		bne.s	.nochg
		bchg	#0,obFrame(a0)	; change every 8 frames

.nochg:
		bsr.w	SpeedToPos_XOnly
		btst	#staFlipX,obStatus(a0) ; is fireball moving left?
		bne.s	.isright	; if not, branch
		moveq	#-8,d3
		bsr.w	ObjHitWallLeft
		tst.w	d1
		bmi.w	DeleteObject	; delete if the	fireball hits a	wall
		bra.w	RememberState	

.isright:
		moveq	#8,d3
		bsr.w	ObjHitWallRight
		tst.w	d1
		bmi.w	DeleteObject
		bra.w	RememberState
