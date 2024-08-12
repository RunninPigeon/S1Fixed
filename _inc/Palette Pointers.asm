; ---------------------------------------------------------------------------
; Palette pointers
; ---------------------------------------------------------------------------

palp:	macro paladdress,ramaddress,colours
	dc.l paladdress
	dc.w ramaddress, (colours>>1)-1
	endm

PalPointers:

; palette address, RAM address, colours

	if FadeInSEGA = 0
ptr_Pal_SegaBG:		palp	Pal_SegaBG,v_palette,$40		; Sega logo palette
	endif
ptr_Pal_Title:		palp	Pal_Title,v_palette,$20			; 0 - title screen -- RetroKoH Title Screen Adjustment
ptr_Pal_LevelSel:	palp	Pal_LevelSel,v_palette,$40		; 1 - level select
ptr_Pal_Sonic:		palp	Pal_Sonic,v_palette,$10			; 2 - Sonic
Pal_Levels:
ptr_Pal_GHZ:		palp	Pal_GHZ,v_palette+$20,$30		; 3 - GHZ
ptr_Pal_LZ:			palp	Pal_LZ,v_palette+$20,$30		; 4 - LZ
ptr_Pal_MZ:			palp	Pal_MZ,v_palette+$20,$30		; 5 - MZ
ptr_Pal_SLZ:		palp	Pal_SLZ,v_palette+$20,$30		; 6 - SLZ
ptr_Pal_SYZ:		palp	Pal_SYZ,v_palette+$20,$30		; 7 - SYZ
ptr_Pal_SBZ1:		palp	Pal_SBZ1,v_palette+$20,$30		; 8 - SBZ1
			zonewarning Pal_Levels,8
ptr_Pal_Special:	palp	Pal_Special,v_palette,$40		; 9 - special stage
ptr_Pal_LZWater:	palp	Pal_LZWater,v_palette,$40		; $A (10) - LZ underwater
ptr_Pal_SBZ3:		palp	Pal_SBZ3,v_palette+$20,$30		; $B (11) - SBZ3
ptr_Pal_SBZ3Water:	palp	Pal_SBZ3Water,v_palette,$40		; $C (12) - SBZ3 underwater
ptr_Pal_SBZ2:		palp	Pal_SBZ2,v_palette+$20,$30		; $D (13) - SBZ2
ptr_Pal_LZSonWater:	palp	Pal_LZSonWater,v_palette,$10	; $E (14) - LZ Sonic underwater
ptr_Pal_SBZ3SonWat:	palp	Pal_SBZ3SonWat,v_palette,$10	; $F (15) - SBZ3 Sonic underwater
ptr_Pal_SSResult:	palp	Pal_SSResult,v_palette,$40		; $10 (16) - special stage results
ptr_Pal_Continue:	palp	Pal_Continue,v_palette,$20		; $11 (17) - special stage results continue
ptr_Pal_Ending:		palp	Pal_Ending,v_palette,$40		; $12 (18) - ending sequence
			even

	if FadeInSEGA = 0
palid_SegaBG:		equ	(ptr_Pal_SegaBG-PalPointers)/8
	endif
palid_Title:		equ (ptr_Pal_Title-PalPointers)/8
palid_LevelSel:		equ (ptr_Pal_LevelSel-PalPointers)/8
palid_Sonic:		equ (ptr_Pal_Sonic-PalPointers)/8
palid_GHZ:			equ (ptr_Pal_GHZ-PalPointers)/8
palid_LZ:			equ (ptr_Pal_LZ-PalPointers)/8
palid_MZ:			equ (ptr_Pal_MZ-PalPointers)/8
palid_SLZ:			equ (ptr_Pal_SLZ-PalPointers)/8
palid_SYZ:			equ (ptr_Pal_SYZ-PalPointers)/8
palid_SBZ1:			equ (ptr_Pal_SBZ1-PalPointers)/8
palid_Special:		equ (ptr_Pal_Special-PalPointers)/8
palid_LZWater:		equ (ptr_Pal_LZWater-PalPointers)/8
palid_SBZ3:			equ (ptr_Pal_SBZ3-PalPointers)/8
palid_SBZ3Water:	equ (ptr_Pal_SBZ3Water-PalPointers)/8
palid_SBZ2:			equ (ptr_Pal_SBZ2-PalPointers)/8
palid_LZSonWater:	equ (ptr_Pal_LZSonWater-PalPointers)/8
palid_SBZ3SonWat:	equ (ptr_Pal_SBZ3SonWat-PalPointers)/8
palid_SSResult:		equ (ptr_Pal_SSResult-PalPointers)/8
palid_Continue:		equ (ptr_Pal_Continue-PalPointers)/8
palid_Ending:		equ (ptr_Pal_Ending-PalPointers)/8
