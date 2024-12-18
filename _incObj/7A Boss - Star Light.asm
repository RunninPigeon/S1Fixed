; ---------------------------------------------------------------------------
; Object 7A - Eggman (SLZ)
; ---------------------------------------------------------------------------

BossStarLight:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossStarLight_Index(pc,d0.w),d1
		jmp	BossStarLight_Index(pc,d1.w)
; ===========================================================================
BossStarLight_Index:	offsetTable
		offsetTableEntry.w BossStarLight_Main
		offsetTableEntry.w BossStarLight_ShipMain
		offsetTableEntry.w BossStarLight_FaceMain
		offsetTableEntry.w BossStarLight_FlameMain
		offsetTableEntry.w BossStarLight_TubeMain

BossStarLight_ObjData:
		; 	routine, anim, priority
		dc.b 2,	0
		dc.w	priority4
		dc.b 4,	1
		dc.w	priority4
		dc.b 6,	7
		dc.w	priority4
		dc.b 8,	0
		dc.w	priority3
; ===========================================================================

BossStarLight_Main:
		move.w	#boss_slz_x+$188,obX(a0)
		move.w	#boss_slz_y+$18,obY(a0)
		move.w	obX(a0),objoff_30(a0)
		move.w	obY(a0),objoff_38(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		move.b	#8,obColProp(a0)	; set number of hits to 8
		lea		BossStarLight_ObjData(pc),a2
		movea.l	a0,a1
		moveq	#3,d1
		bra.s	BossStarLight_LoadBoss
; ===========================================================================

BossStarLight_Loop:
		jsr		(FindNextFreeObj).l
		bne.s	loc_1895C
		_move.b	#id_BossStarLight,obID(a1)
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)

BossStarLight_LoadBoss:
		bclr	#staFlipX,obStatus(a0)
		clr.b	ob2ndRout(a1)
		move.b	(a2)+,obRoutine(a1)
		move.b	(a2)+,obAnim(a1)
		move.w	(a2)+,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.l	#Map_Eggman,obMap(a1)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a1)
		move.b	#4,obRender(a1)
		move.b	#$20,obActWid(a1)
		move.l	a0,objoff_34(a1)
		dbf		d1,BossStarLight_Loop	; repeat sequence 3 more times

loc_1895C:
		lea		(v_lvlobjspace).w,a1	; FixBugs -- Formerly (v_objspace+object_size*1)
		lea		objoff_2A(a0),a2
		moveq	#id_Seesaw,d0
		moveq	#v_lvlobjcount,d1		; FixBugs: Normally only covered the first half of object RAM.

loc_18968:
		cmp.b	obID(a1),d0
		bne.s	loc_18974
		tst.b	obSubtype(a1)
		beq.s	loc_18974
		move.w	a1,(a2)+

loc_18974:
		adda.w	#object_size,a1
		dbf		d1,loc_18968

BossStarLight_ShipMain:	; Routine 2
		moveq	#0,d0
		move.b	ob2ndRout(a0),d0
		move.w	BossStarLight_ShipIndex(pc,d0.w),d0
		jsr		BossStarLight_ShipIndex(pc,d0.w)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplayAndCollision).l	; S3K TouchResponse
; ===========================================================================
BossStarLight_ShipIndex:	offsetTable
		offsetTableEntry.w loc_189B8
		offsetTableEntry.w loc_18A5E
		offsetTableEntry.w BossStarLight_MakeBall
		offsetTableEntry.w loc_18B48
		offsetTableEntry.w loc_18B80
		offsetTableEntry.w loc_18BC6
; ===========================================================================

loc_189B8:
		move.w	#-$100,obVelX(a0)
		cmpi.w	#boss_slz_x+$120,objoff_30(a0)
		bhs.s	loc_189CA
		addq.b	#2,ob2ndRout(a0)

loc_189CA:
		bsr.w	BossMove
		move.b	objoff_3F(a0),d0
		addq.b	#2,objoff_3F(a0)
		jsr		(CalcSine).w
		asr.w	#6,d0
		add.w	objoff_38(a0),d0
		move.w	d0,obY(a0)
		move.w	objoff_30(a0),obX(a0)
		bra.s	loc_189FE
; ===========================================================================

loc_189EE:
		bsr.w	BossMove
		move.w	objoff_38(a0),obY(a0)
		move.w	objoff_30(a0),obX(a0)

loc_189FE:
		cmpi.b	#6,ob2ndRout(a0)
		bhs.s	locret_18A44
		tst.b	obStatus(a0)
		bmi.s	loc_18A46
		tst.b	obColType(a0)
		bne.s	locret_18A44
		tst.b	objoff_3E(a0)
		bne.s	BossStarLight_ShipFlash
		move.b	#$20,objoff_3E(a0)
		move.w	#sfx_HitBoss,d0
		jsr		(PlaySound_Special).w	; play boss damage sound

BossStarLight_ShipFlash:
		lea		(v_palette+$22).w,a1 ; load 2nd palette, 2nd entry
		moveq	#0,d0		; move 0 (black) to d0
		tst.w	(a1)
		bne.s	loc_18A36
		move.w	#cWhite,d0	; move 0EEE (white) to d0

loc_18A36:
		move.w	d0,(a1)
		subq.b	#1,objoff_3E(a0)
		bne.s	locret_18A44
		move.b	#(colEnemy|colSz_24x24),obColType(a0)

locret_18A44:
		rts	
; ===========================================================================

loc_18A46:
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#6,ob2ndRout(a0)
		move.b	#$78,objoff_3C(a0)
		clr.w	obVelX(a0)
		rts	
; ===========================================================================

loc_18A5E:
		move.w	objoff_30(a0),d0
		move.w	#$200,obVelX(a0)
		btst	#staFlipX,obStatus(a0)
		bne.s	loc_18A7C
		neg.w	obVelX(a0)
		cmpi.w	#boss_slz_x+8,d0
		bgt.s	loc_18A88
		bra.s	loc_18A82
; ===========================================================================

loc_18A7C:
		cmpi.w	#boss_slz_x+$138,d0
		blt.s	loc_18A88

loc_18A82:
		bchg	#staFlipX,obStatus(a0)

loc_18A88:
		move.w	obX(a0),d0
		moveq	#-1,d1
		moveq	#2,d2
		lea		objoff_2A(a0),a2
		moveq	#$28,d4
		tst.w	obVelX(a0)
		bpl.s	loc_18A9E
		neg.w	d4

loc_18A9E:
		move.w	(a2)+,d1
		movea.l	d1,a3
		btst	#staSonicOnObj,obStatus(a3)
		bne.s	loc_18AB4
		move.w	obX(a3),d3
		add.w	d4,d3
		sub.w	d0,d3
		beq.s	loc_18AC0

loc_18AB4:
		dbf		d2,loc_18A9E

		move.b	d2,obSubtype(a0)
		bra.w	loc_189CA
; ===========================================================================

loc_18AC0:
		move.b	d2,obSubtype(a0)
		addq.b	#2,ob2ndRout(a0)
		move.b	#$28,objoff_3C(a0)
		bra.w	loc_189CA
; ===========================================================================

BossStarLight_MakeBall:
		cmpi.b	#$28,objoff_3C(a0)
		bne.s	loc_18B36
		moveq	#-1,d0
		move.b	obSubtype(a0),d0
		ext.w	d0
		bmi.s	loc_18B40
		subq.w	#2,d0
		neg.w	d0
		add.w	d0,d0
		lea		objoff_2A(a0),a1
		move.w	(a1,d0.w),d0
		movea.l	d0,a2
		lea		(v_lvlobjspace).w,a1	; FixBugs -- Formerly (v_objspace+object_size*1)
		moveq	#v_lvlobjcount,d1		; FixBugs: Normally only covered the first half of object RAM.

loc_18AFA:
		cmp.l	objoff_3C(a1),d0
		beq.s	loc_18B40
		adda.w	#object_size,a1
		dbf		d1,loc_18AFA

		move.l	a0,-(sp)
		lea		(a2),a0
		jsr		(FindNextFreeObj).l
		movea.l	(sp)+,a0
		bne.s	loc_18B40
		move.b	#id_BossSpikeball,obID(a1) ; load spiked ball object
		move.w	obX(a0),obX(a1)
		move.w	obY(a0),obY(a1)
		addi.w	#$20,obY(a1)
		move.b	obStatus(a2),obStatus(a1)
		move.l	a2,objoff_3C(a1)

loc_18B36:
		subq.b	#1,objoff_3C(a0)
		beq.s	loc_18B40
		bra.w	loc_189FE
; ===========================================================================

loc_18B40:
		subq.b	#2,ob2ndRout(a0)
		bra.w	loc_189CA
; ===========================================================================

loc_18B48:
		subq.b	#1,objoff_3C(a0)
		bmi.s	loc_18B52
		bra.w	BossDefeated
; ===========================================================================

loc_18B52:
		addq.b	#2,ob2ndRout(a0)
		clr.w	obVelY(a0)
		bset	#staFlipX,obStatus(a0)
		bclr	#7,obStatus(a0)
		clr.w	obVelX(a0)
		move.b	#-$18,objoff_3C(a0)
		tst.b	(v_bossstatus).w
		bne.s	loc_18B7C
		move.b	#1,(v_bossstatus).w

loc_18B7C:
		bra.w	loc_189FE
; ===========================================================================

loc_18B80:
		addq.b	#1,objoff_3C(a0)
		beq.s	loc_18B90
		bpl.s	loc_18B96
		addi.w	#$18,obVelY(a0)
		bra.w	loc_189EE
; ===========================================================================

loc_18B90:
		clr.w	obVelY(a0)
		bra.w	loc_189EE
; ===========================================================================

loc_18B96:
		cmpi.b	#$20,objoff_3C(a0)
		blo.s	loc_18BAE
		beq.s	loc_18BB4
		cmpi.b	#$2A,objoff_3C(a0)
		blo.w	loc_189EE
		addq.b	#2,ob2ndRout(a0)
		bra.w	loc_189EE
; ===========================================================================

loc_18BAE:
		subq.w	#8,obVelY(a0)
		bra.w	loc_189EE
; ===========================================================================

loc_18BB4:
		clr.w	obVelY(a0)
		move.w	#bgm_SLZ,d0
		jsr		(PlaySound).w			; play SLZ music
		move.b	d0,(v_lastbgmplayed).w	; store last played music
		bra.w	loc_189EE
; ===========================================================================

loc_18BC6:
		move.w	#$400,obVelX(a0)
		move.w	#-$40,obVelY(a0)
		cmpi.w	#boss_slz_end,(v_limitright2).w
		bhs.s	loc_18BE0
		addq.w	#2,(v_limitright2).w
		bra.s	loc_18BE8
; ===========================================================================

loc_18BE0:
		tst.b	obRender(a0)
		bpl.s	BossStarLight_PopAndDelete	; Clownacy DisplaySprite Fix

loc_18BE8:
		bsr.w	BossMove
		bra.w	loc_189CA

BossStarLight_PopAndDelete:
		; Avoid returning to BossStarLight_ShipMain to prevent a
		; display-and-delete bug.
		addq.l	#4,sp
		jmp		(DeleteObject).l
; ===========================================================================

BossStarLight_FaceMain:	; Routine 4
		moveq	#0,d0
		moveq	#1,d1
		movea.l	objoff_34(a0),a1
		move.b	ob2ndRout(a1),d0
		cmpi.b	#6,d0
		bmi.s	loc_18C06
		moveq	#$A,d1
		bra.s	loc_18C1A
; ===========================================================================

loc_18C06:
		tst.b	obColType(a1)
		bne.s	loc_18C10
		moveq	#5,d1
		bra.s	loc_18C1A
; ===========================================================================

loc_18C10:
		cmpi.b	#4,(v_player+obRoutine).w
		blo.s	loc_18C1A
		moveq	#4,d1

loc_18C1A:
		move.b	d1,obAnim(a0)
		cmpi.b	#$A,d0
		bne.s	loc_18C6C
		move.b	#6,obAnim(a0)
		tst.b	obRender(a0)
		bpl.w	BossStarLight_Delete
		bra.s	loc_18C6C
; ===========================================================================

BossStarLight_FlameMain:; Routine 6
		move.b	#8,obAnim(a0)
		movea.l	objoff_34(a0),a1
		cmpi.b	#$A,ob2ndRout(a1)
		bne.s	loc_18C56
		tst.b	obRender(a0)
		bpl.s	BossStarLight_Delete
		move.b	#$B,obAnim(a0)
		bra.s	loc_18C6C
; ===========================================================================

loc_18C56:
		cmpi.b	#8,ob2ndRout(a1)
		bgt.s	loc_18C6C
		cmpi.b	#4,ob2ndRout(a1)
		blt.s	loc_18C6C
		move.b	#7,obAnim(a0)

loc_18C6C:
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w

loc_18C78:
		movea.l	objoff_34(a0),a1
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		move.b	obStatus(a1),obStatus(a0)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplayAndCollision).l	; S3K TouchResponse
; ===========================================================================

BossStarLight_TubeMain:	; Routine 8
		movea.l	objoff_34(a0),a1
		cmpi.b	#$A,ob2ndRout(a1)
		bne.s	loc_18CB8
		tst.b	obRender(a0)
		bpl.s	BossStarLight_Delete

loc_18CB8:
		move.l	#Map_BossItems,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman_Weapons,1,0),obGfx(a0)
		move.b	#3,obFrame(a0)
		bra.s	loc_18C78
; ===========================================================================

BossStarLight_Delete:
		jmp	(DeleteObject).l
