; ---------------------------------------------------------------------------
; Sonic 1 Dynamic PLC Script - Generated by Sonic Triad Studio
; To be used with spritePiece Macro. Set SonicMappingsVer to 1 to use this DPLC script.
; ---------------------------------------------------------------------------

; RetroKoH VRAM Overhaul
GRingDynPLC:	mappingsTable
		mappingsTableEntry.w	GRing_DPLC0 ; O
		mappingsTableEntry.w	GRing_DPLC1 ; first rotation
		mappingsTableEntry.w	GRing_DPLC2 ; second rotation (OLD first rotation)
		mappingsTableEntry.w	GRing_DPLC3 ; third rotation
		mappingsTableEntry.w	GRing_DPLC4 ; side
		mappingsTableEntry.w	GRing_DPLC3 ; third rotation REVERSE
		mappingsTableEntry.w	GRing_DPLC2 ; second rotation REVERSE
		mappingsTableEntry.w	GRing_DPLC1 ; first rotation REVERSE

GRing_DPLC0:	dplcHeader
		dplcEntry	$10, 0
		dplcEntry	$10, $10
		dplcEntry	$10, $20
GRing_DPLC0_End

GRing_DPLC1:	dplcHeader
		dplcEntry	$10, $36
		dplcEntry	$10, $46
		dplcEntry	$E, $56
GRing_DPLC1_End

GRing_DPLC2:	dplcHeader
		dplcEntry	4, $64
		dplcEntry	3, $68
		dplcEntry	6, $6B
		dplcEntry	8, $71
		dplcEntry	4, $79
		dplcEntry	6, $7D
		dplcEntry	3, $83
		dplcEntry	4, $86
GRing_DPLC2_End

GRing_DPLC3:	dplcHeader
		dplcEntry	$10, $8A
		dplcEntry	$10, $9A
GRing_DPLC3_End

GRing_DPLC4:	dplcHeader
		dplcEntry	8, $AA
		dplcEntry	8, $B2
GRing_DPLC4_End
	even