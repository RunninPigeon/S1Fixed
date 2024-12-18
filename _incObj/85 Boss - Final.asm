; ---------------------------------------------------------------------------
; Object 85 - Eggman (FZ)
; ---------------------------------------------------------------------------

BossFinal_Delete:
		jmp	(DeleteObject).l
; ===========================================================================

BossFinal:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	BossFinal_Index(pc,d0.w),d0
		jmp		BossFinal_Index(pc,d0.w)
; ===========================================================================
BossFinal_Index:	offsetTable
		offsetTableEntry.w BossFinal_Main
		offsetTableEntry.w BossFinal_Eggman
		offsetTableEntry.w loc_1A38E
		offsetTableEntry.w loc_1A346
		offsetTableEntry.w loc_1A2C6
		offsetTableEntry.w loc_1A3AC
		offsetTableEntry.w loc_1A264

BossFinal_ObjData:
		dc.w $100, $100, make_art_tile(ArtTile_FZ_Eggman_No_Vehicle,0,0)	; X pos, Y pos,	VRAM setting
		dc.l Map_SEgg		; mappings pointer
		dc.w boss_fz_x+$160, boss_fz_y+$80, make_art_tile(ArtTile_FZ_Boss,0,0)
		dc.l Map_EggCyl
		dc.w boss_fz_x+$290, boss_fz_y+$86, make_art_tile(ArtTile_FZ_Eggman_Fleeing,0,0)
		dc.l Map_FZLegs
		dc.w boss_fz_x+$290, boss_fz_y+$86, make_art_tile(ArtTile_FZ_Eggman_No_Vehicle,0,0)
		dc.l Map_SEgg
		dc.w boss_fz_x+$290, boss_fz_y+$86, make_art_tile(ArtTile_Eggman,0,0)
		dc.l Map_Eggman
		dc.w boss_fz_x+$290, boss_fz_y+$86, make_art_tile(ArtTile_Eggman,0,0)
		dc.l Map_Eggman

BossFinal_ObjData2:
	; 			routine,		width,
	;					anim,			height
		dc.b	2,		0, 		$20,	$19		
		dc.w	priority4
		dc.b	4,		0,		$12,	8		
		dc.w	priority1
		dc.b	6,		0,		0,		0		
		dc.w	priority3
		dc.b	8,		0,		0,		0		
		dc.w	priority3
		dc.b	$A, 	0,		$20,	$20		
		dc.w	priority3
		dc.b	$C, 	0,		0,		0		
		dc.w	priority3
; ===========================================================================

BossFinal_Main:	; Routine 0
		lea		BossFinal_ObjData(pc),a2
		lea		BossFinal_ObjData2(pc),a3
		movea.l	a0,a1
		moveq	#5,d1
		bra.s	BossFinal_LoadBoss
; ===========================================================================

BossFinal_Loop:
		jsr		(FindNextFreeObj).l
		bne.s	loc_19E20

BossFinal_LoadBoss:
		move.b	#id_BossFinal,obID(a1)
		move.w	(a2)+,obX(a1)
		move.w	(a2)+,obY(a1)
		move.w	(a2)+,obGfx(a1)
		move.l	(a2)+,obMap(a1)
		move.b	(a3)+,obRoutine(a1)
		move.b	(a3)+,obAnim(a1)
		move.b	(a3)+,obActWid(a1)
		move.b	(a3)+,obHeight(a1)
		move.w	(a3)+,obPriority(a1)	; RetroKoH/Devon S3K+ Priority Manager
		move.b	#4,obRender(a1)
		bset	#7,obRender(a0)
		move.l	a0,objoff_34(a1)
		dbf		d1,BossFinal_Loop

loc_19E20:
		lea		objoff_36(a0),a2
		jsr		(FindFreeObj).l
		bne.s	loc_19E5A
		move.b	#id_BossPlasma,obID(a1) ; load energy ball object
		move.w	a1,(a2)
		move.l	a0,objoff_34(a1)
		lea		objoff_38(a0),a2
		moveq	#0,d2
		moveq	#3,d1

loc_19E3E:
		jsr		(FindNextFreeObj).l
		bne.s	loc_19E5A
		move.w	a1,(a2)+
		move.b	#id_EggmanCylinder,obID(a1) ; load crushing cylinder object
		move.l	a0,objoff_34(a1)
		move.b	d2,obSubtype(a1)
		addq.w	#2,d2
		dbf		d1,loc_19E3E

loc_19E5A:
		clr.w	objoff_34(a0)
		move.b	#1,obColProp(a0) ; set number of hits to 8
		move.w	#-1,objoff_30(a0)

BossFinal_Eggman:	; Routine 2
		moveq	#0,d0
		move.b	objoff_34(a0),d0
		move.w	off_19E80(pc,d0.w),d0
		jsr		off_19E80(pc,d0.w)
		jmp		(DisplayAndCollision).l	; S3K TouchResponse
; ===========================================================================
off_19E80:		offsetTable
		offsetTableEntry.w loc_19E90
		offsetTableEntry.w loc_19EA8
		offsetTableEntry.w loc_19FE6
		offsetTableEntry.w loc_1A02A
		offsetTableEntry.w loc_1A074
		offsetTableEntry.w loc_1A112
		offsetTableEntry.w loc_1A192
		offsetTableEntry.w loc_1A1D4
; ===========================================================================

loc_19E90:
		tst.l	(v_plc_buffer).w
		bne.s	loc_19EA2
		cmpi.w	#boss_fz_x,(v_screenposx).w
		blo.s	loc_19EA2
		addq.b	#2,objoff_34(a0)

loc_19EA2:
		addq.l	#1,(v_random).w
		rts	
; ===========================================================================

loc_19EA8:
		tst.w	objoff_30(a0)
		bpl.s	loc_19F10
		clr.w	objoff_30(a0)
		jsr		(RandomNumber).w
		andi.w	#$C,d0
		move.w	d0,d1
		addq.w	#2,d1
		tst.l	d0
		bpl.s	loc_19EC6
		exg		d1,d0

loc_19EC6:
		lea		word_19FD6(pc),a1
		move.w	(a1,d0.w),d0
		move.w	(a1,d1.w),d1
		move.w	d0,objoff_30(a0)
		moveq	#-1,d2
		move.w	objoff_38(a0,d0.w),d2
		movea.l	d2,a1
		move.b	#-1,objoff_29(a1)
		move.w	#-1,objoff_30(a1)
		move.w	objoff_38(a0,d1.w),d2
		movea.l	d2,a1
		move.b	#1,objoff_29(a1)
		clr.w	objoff_30(a1)
		move.w	#1,objoff_32(a0)
		clr.b	objoff_35(a0)
		move.w	#sfx_Rumbling,d0
		jsr		(PlaySound_Special).w	; play rumbling sound

loc_19F10:
		tst.w	objoff_32(a0)
		bmi.w	loc_19FA6
		bclr	#staFlipX,obStatus(a0)
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcs.s	loc_19F2E
		bset	#staFlipX,obStatus(a0)

loc_19F2E:
		move.w	#$2B,d1
		move.w	#$14,d2
		move.w	#$14,d3
		move.w	obX(a0),d4
		jsr		(SolidObject).l
		tst.w	d4
		bgt.s	loc_19F50

loc_19F48:
		tst.b	objoff_35(a0)
		bne.s	loc_19F88
		bra.s	loc_19F96
; ===========================================================================

loc_19F50:
		addq.w	#7,(v_random).w
		cmpi.b	#aniID_Roll,(v_player+obAnim).w
		bne.s	loc_19F48
		move.w	#$300,d0
		btst	#staFlipX,obStatus(a0)
		bne.s	loc_19F6A
		neg.w	d0

loc_19F6A:
		move.w	d0,(v_player+obVelX).w
		tst.b	objoff_35(a0)
		bne.s	loc_19F88
	; Mercury FZ Boss Hitcount Fix
		tst.b	obColProp(a0)	; has the boss been defeated?
		beq.s	loc_19F9C		; if so, don't let it be hit again.
	; FZ Boss Hitcount Fix End

		subq.b	#1,obColProp(a0)
		move.b	#$64,objoff_35(a0)
		move.w	#sfx_HitBoss,d0
		jsr		(PlaySound_Special).w	; play boss damage sound

loc_19F88:
		subq.b	#1,objoff_35(a0)
		beq.s	loc_19F96
		move.b	#3,obAnim(a0)
		bra.s	loc_19F9C
; ===========================================================================

loc_19F96:
		move.b	#1,obAnim(a0)

loc_19F9C:
		lea		Ani_SEgg(pc),a1
		jmp		(AnimateSprite).w
; ===========================================================================

loc_19FA6:
		tst.b	obColProp(a0)
		beq.s	loc_19FBC
		addq.b	#2,objoff_34(a0)
		move.w	#-1,objoff_30(a0)
		clr.w	objoff_32(a0)
		rts	
; ===========================================================================

loc_19FBC:
		moveq	#100,d0
		bsr.w	AddPoints
		move.b	#6,objoff_34(a0)
		move.w	#boss_fz_x+$170,obX(a0)
		move.w	#boss_fz_y+$2C,obY(a0)
		move.b	#$14,obHeight(a0)
		rts	
; ===========================================================================
word_19FD6:	dc.w 0,	2, 2, 4, 4, 6, 6, 0
; ===========================================================================

loc_19FE6:
		moveq	#-1,d0
		move.w	objoff_36(a0),d0
		movea.l	d0,a1
		tst.w	objoff_30(a0)
		bpl.s	loc_1A000
		clr.w	objoff_30(a0)
		move.b	#-1,objoff_29(a1)
		bsr.s	loc_1A020

loc_1A000:
		moveq	#$F,d0
		and.w	(v_vbla_word).w,d0
		bne.s	loc_1A00A
		bsr.s	loc_1A020

loc_1A00A:
		tst.w	objoff_32(a0)
		beq.s	locret_1A01E
		subq.b	#2,objoff_34(a0)
		move.w	#-1,objoff_30(a0)
		clr.w	objoff_32(a0)

locret_1A01E:
		rts	
; ===========================================================================

loc_1A020:
		move.w	#sfx_Electric,d0
		jmp		(PlaySound_Special).w	; play electricity sound
; ===========================================================================

loc_1A02A:
		move.b	#$30,obActWid(a0)
		bset	#staFlipX,obStatus(a0)
		jsr		(SpeedToPos).l
		move.b	#6,obFrame(a0)
		addi.w	#$10,obVelY(a0)
		cmpi.w	#boss_fz_y+$8C,obY(a0)
		blo.w	loc_1A166
		move.w	#boss_fz_y+$8C,obY(a0)
		addq.b	#2,objoff_34(a0)
		move.b	#$20,obActWid(a0)
		move.w	#$100,obVelX(a0)
		move.w	#-$100,obVelY(a0)
		addq.w	#2,(v_dle_routine).w	; Now word-length so we don't need to clear d0 elsewhere -- Filter Optimized DLE Manager
		bra.w	loc_1A166
; ===========================================================================

loc_1A074:
		bset	#staFlipX,obStatus(a0)
		move.b	#4,obAnim(a0)
		jsr		(SpeedToPos).l
		addi.w	#$10,obVelY(a0)
		cmpi.w	#boss_fz_y+$93,obY(a0)
		blo.s	loc_1A09A
		move.w	#-$40,obVelY(a0)

loc_1A09A:
		move.w	#$400,obVelX(a0)
		move.w	obX(a0),d0
		sub.w	(v_player+obX).w,d0
		bpl.s	loc_1A0B4
		move.w	#$500,obVelX(a0)
		bra.w	loc_1A0F2
; ===========================================================================

loc_1A0B4:
		subi.w	#$70,d0
		bcs.s	loc_1A0F2
		subi.w	#$100,obVelX(a0)
		subq.w	#8,d0
		bcs.s	loc_1A0F2
		subi.w	#$100,obVelX(a0)
		subq.w	#8,d0
		bcs.s	loc_1A0F2
		subi.w	#$80,obVelX(a0)
		subq.w	#8,d0
		bcs.s	loc_1A0F2
		subi.w	#$80,obVelX(a0)
		subq.w	#8,d0
		bcs.s	loc_1A0F2
		subi.w	#$80,obVelX(a0)
		subi.w	#$38,d0
		bcs.s	loc_1A0F2
		clr.w	obVelX(a0)

loc_1A0F2:
		cmpi.w	#boss_fz_x+$250,obX(a0)
		blo.s	loc_1A15C
		move.w	#boss_fz_x+$250,obX(a0)
		move.w	#$240,obVelX(a0)
		move.w	#-$4C0,obVelY(a0)
		addq.b	#2,objoff_34(a0)
		bra.s	loc_1A15C
; ===========================================================================

loc_1A112:
		jsr		(SpeedToPos).l
		cmpi.w	#boss_fz_x+$290,obX(a0)
		blo.s	loc_1A124
		clr.w	obVelX(a0)

loc_1A124:
		addi.w	#$34,obVelY(a0)
		tst.w	obVelY(a0)
		bmi.s	loc_1A142
		cmpi.w	#boss_fz_y+$82,obY(a0)
		blo.s	loc_1A142
		move.w	#boss_fz_y+$82,obY(a0)
		clr.w	obVelY(a0)

loc_1A142:
		move.w	obVelX(a0),d0
		or.w	obVelY(a0),d0
		bne.s	loc_1A15C
		addq.b	#2,objoff_34(a0)
		move.w	#-$180,obVelY(a0)
		move.b	#1,obColProp(a0)

loc_1A15C:
		lea		Ani_SEgg(pc),a1
		jsr		(AnimateSprite).w

loc_1A166:
		cmpi.w	#boss_fz_end,(v_limitright2).w
		bge.s	loc_1A172
		addq.w	#2,(v_limitright2).w

loc_1A172:
		cmpi.b	#$C,objoff_34(a0)
		bge.s	locret_1A190
		move.w	#$1B,d1
		move.w	#$70,d2
		move.w	#$71,d3
		move.w	obX(a0),d4
		jmp		(SolidObject).l
; ===========================================================================

locret_1A190:
		rts	
; ===========================================================================

loc_1A192:
		move.l	#Map_Eggman,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a0)
		clr.b	obAnim(a0)
		bset	#staFlipX,obStatus(a0)
		jsr		(SpeedToPos).l
		cmpi.w	#boss_fz_y+$34,obY(a0)
		bhs.w	loc_1A15C
		move.w	#$180,obVelX(a0)
		move.w	#-$18,obVelY(a0)
		move.b	#(colEnemy|colSz_24x24),obColType(a0)
		addq.b	#2,objoff_34(a0)
		bra.w	loc_1A15C
; ===========================================================================

loc_1A1D4:
		bset	#staFlipX,obStatus(a0)
		jsr		(SpeedToPos).l
		tst.w	objoff_30(a0)
		bne.s	loc_1A1FC
		tst.b	obColType(a0)
		bne.s	loc_1A216
		move.w	#$1E,objoff_30(a0)
		move.w	#sfx_HitBoss,d0
		jsr		(PlaySound_Special).w	; play boss damage sound

loc_1A1FC:
		subq.w	#1,objoff_30(a0)
		bne.s	loc_1A216
		tst.b	obStatus(a0)
		bpl.s	loc_1A210
		move.w	#$60,obVelY(a0)
		bra.s	loc_1A216
; ===========================================================================

loc_1A210:
		move.b	#(colEnemy|colSz_24x24),obColType(a0)

loc_1A216:
		cmpi.w	#boss_fz_end+$90,(v_player+obX).w
		blt.s	loc_1A23A
		move.b	#1,(f_lockctrl).w
		clr.w	(v_jpadhold2).w
		clr.w	(v_player+obInertia).w
		tst.w	obVelY(a0)
		bpl.s	loc_1A248
		move.w	#$100,(v_jpadhold2).w

loc_1A23A:
		cmpi.w	#boss_fz_end+$E0,(v_player+obX).w
		blt.s	loc_1A248
		move.w	#boss_fz_end+$E0,(v_player+obX).w

loc_1A248:
		cmpi.w	#boss_fz_end+$200,obX(a0)
		blo.w	loc_1A15C
		tst.b	obRender(a0)
		bmi.w	loc_1A15C
		move.b	#id_Ending,(v_gamemode).w
		addq.l	#4,sp						; Clownacy DisplaySprite Fix
		bra.w	BossFinal_Delete
; ===========================================================================

loc_1A264:	; Routine 4
		movea.l	objoff_34(a0),a1
		move.b	(a1),d0
		cmp.b	(a0),d0
		bne.w	BossFinal_Delete
		move.b	#7,obAnim(a0)
		cmpi.b	#$C,objoff_34(a1)
		bge.s	loc_1A280
		bra.s	loc_1A2A6
; ===========================================================================

loc_1A280:
		tst.w	obVelX(a1)
		beq.s	loc_1A28C
		move.b	#$B,obAnim(a0)

loc_1A28C:
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w

loc_1A296:
		movea.l	objoff_34(a0),a1
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)

loc_1A2A6:
		movea.l	objoff_34(a0),a1
		move.b	obStatus(a1),obStatus(a0)
		moveq	#(maskFlipX+maskFlipY),d0
		and.b	obStatus(a0),d0
		andi.b	#$FC,obRender(a0)
		or.b	d0,obRender(a0)
		jmp		(DisplayAndCollision).l	; S3K TouchResponse
; ===========================================================================

loc_1A2C6:	; Routine 6
		movea.l	objoff_34(a0),a1
		move.b	(a1),d0
		cmp.b	(a0),d0
		bne.w	BossFinal_Delete
		cmpi.l	#Map_Eggman,obMap(a1)
		beq.s	loc_1A2E4
		move.b	#$A,obFrame(a0)
		bra.s	loc_1A2A6
; ===========================================================================

loc_1A2E4:
		move.b	#1,obAnim(a0)
		tst.b	obColProp(a1)
		ble.s	loc_1A312
		move.b	#6,obAnim(a0)
		move.l	#Map_Eggman,obMap(a0)
		move.w	#make_art_tile(ArtTile_Eggman,0,0),obGfx(a0)
		lea		Ani_Eggman(pc),a1
		jsr		(AnimateSprite).w
		bra.w	loc_1A296
; ===========================================================================

loc_1A312:
		tst.b	obRender(a0)
		bpl.w	BossFinal_Delete
		bsr.w	BossDefeated
		move.w	#priority2,obPriority(a0)	; RetroKoH/Devon S3K+ Priority Manager
		clr.b	obAnim(a0)
		move.l	#Map_FZDamaged,obMap(a0)
		move.w	#make_art_tile(ArtTile_FZ_Eggman_Fleeing,0,0),obGfx(a0)
		lea		Ani_FZEgg(pc),a1
		jsr		(AnimateSprite).w
		bra.w	loc_1A296
; ===========================================================================

loc_1A346:	; Routine 8
		bset	#staFlipX,obStatus(a0)
		movea.l	objoff_34(a0),a1
		cmpi.l	#Map_Eggman,obMap(a1)
		beq.s	loc_1A35E
		bra.w	loc_1A2A6
; ===========================================================================

loc_1A35E:
		move.w	obX(a1),obX(a0)
		move.w	obY(a1),obY(a0)
		tst.b	obTimeFrame(a0)
		bne.s	loc_1A376
		move.b	#$14,obTimeFrame(a0)

loc_1A376:
		subq.b	#1,obTimeFrame(a0)
		bgt.w	loc_1A296
		addq.b	#1,obFrame(a0)
		cmpi.b	#2,obFrame(a0)
		bgt.w	BossFinal_Delete
		bra.w	loc_1A296
; ===========================================================================

loc_1A38E:	; Routine $A
		move.b	#$B,obFrame(a0)
		move.w	(v_player+obX).w,d0
		sub.w	obX(a0),d0
		bcs.s	loc_1A3A6
		tst.b	obRender(a0)
		bpl.w	BossFinal_Delete

loc_1A3A6:
		jmp		(DisplayAndCollision).l	; S3K TouchResponse
; ===========================================================================

loc_1A3AC:	; Routine $C
		clr.b	obFrame(a0)
		bset	#staFlipX,obStatus(a0)
		movea.l	objoff_34(a0),a1
		cmpi.b	#$C,objoff_34(a1)
		bne.w	loc_1A2A6
		cmpi.l	#Map_Eggman,obMap(a1)
		beq.w	BossFinal_Delete
		bra.w	loc_1A2A6
