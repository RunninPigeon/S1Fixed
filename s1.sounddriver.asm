; ---------------------------------------------------------------------------
; Modified SMPS 68k Type 1b sound driver
; The source code to a similar version of the driver can be found here:
; https://hiddenpalace.org/News/Sega_of_Japan_Sound_Documents_and_Source_Code
; ---------------------------------------------------------------------------
; Constants
SMPS_TRACK_COUNT = (SMPS_RAM.v_track_ram_end-SMPS_RAM.v_track_ram)/SMPS_Track.len
SMPS_MUSIC_TRACK_COUNT = (SMPS_RAM.v_music_track_ram_end-SMPS_RAM.v_music_track_ram)/SMPS_Track.len
SMPS_MUSIC_FM_DAC_TRACK_COUNT = (SMPS_RAM.v_music_fmdac_tracks_end-SMPS_RAM.v_music_fmdac_tracks)/SMPS_Track.len
SMPS_MUSIC_FM_TRACK_COUNT = (SMPS_RAM.v_music_fm_tracks_end-SMPS_RAM.v_music_fm_tracks)/SMPS_Track.len
SMPS_MUSIC_PSG_TRACK_COUNT = (SMPS_RAM.v_music_psg_tracks_end-SMPS_RAM.v_music_psg_tracks)/SMPS_Track.len
SMPS_SFX_TRACK_COUNT = (SMPS_RAM.v_sfx_track_ram_end-SMPS_RAM.v_sfx_track_ram)/SMPS_Track.len
SMPS_SFX_FM_TRACK_COUNT = (SMPS_RAM.v_sfx_fm_tracks_end-SMPS_RAM.v_sfx_fm_tracks)/SMPS_Track.len
SMPS_SFX_PSG_TRACK_COUNT = (SMPS_RAM.v_sfx_psg_tracks_end-SMPS_RAM.v_sfx_psg_tracks)/SMPS_Track.len
SMPS_SPECIAL_SFX_TRACK_COUNT = (SMPS_RAM.v_spcsfx_track_ram_end-SMPS_RAM.v_spcsfx_track_ram)/SMPS_Track.len
SMPS_SPECIAL_SFX_FM_TRACK_COUNT = (SMPS_RAM.v_spcsfx_fm_tracks_end-SMPS_RAM.v_spcsfx_fm_tracks)/SMPS_Track.len
SMPS_SPECIAL_SFX_PSG_TRACK_COUNT = (SMPS_RAM.v_spcsfx_psg_tracks_end-SMPS_RAM.v_spcsfx_psg_tracks)/SMPS_Track.len
; ---------------------------------------------------------------------------
; Macros
; turn a sample rate into a djnz loop counter
pcmLoopCounterBase function sampleRate,baseCycles, 1+(Z80_Clock/(sampleRate)-(baseCycles)+(13/2))/13
pcmLoopCounter function sampleRate, pcmLoopCounterBase(sampleRate,90) ; 90 is the number of cycles zPlaySEGAPCMLoop takes to deliver one sample.
dpcmLoopCounter function sampleRate, pcmLoopCounterBase(sampleRate,301/2) ; 301 is the number of cycles zPlayPCMLoop takes to deliver two samples.
; ---------------------------------------------------------------------------
; Go_SoundTypes:
Go_SoundPriorities:	dc.l SoundPriorities
; Go_SoundD0:
Go_SpecSoundIndex:	dc.l SpecSoundIndex
Go_MusicIndex:		dc.l MusicIndex
Go_SoundIndex:		dc.l SoundIndex
; off_719A0:
Go_SpeedUpIndex:	dc.l SpeedUpIndex
Go_PSGIndex:		dc.l PSG_Index
; ---------------------------------------------------------------------------
; PSG instruments used in music
; ---------------------------------------------------------------------------
PSG_Index:
		dc.l PSG1, PSG2, PSG3
		dc.l PSG4, PSG5, PSG6
		dc.l PSG7, PSG8, PSG9
PSG1:		binclude	"sound/psg/psg1.bin"
PSG2:		binclude	"sound/psg/psg2.bin"
PSG3:		binclude	"sound/psg/psg3.bin"
PSG4:		binclude	"sound/psg/psg4.bin"
PSG6:		binclude	"sound/psg/psg6.bin"
PSG5:		binclude	"sound/psg/psg5.bin"
PSG7:		binclude	"sound/psg/psg7.bin"
PSG8:		binclude	"sound/psg/psg8.bin"
PSG9:		binclude	"sound/psg/psg9.bin"
; ---------------------------------------------------------------------------
; New tempos for songs during speed shoes
; ---------------------------------------------------------------------------
; DANGER! several songs will use the first few bytes of MusicIndex as their main
; tempos while speed shoes are active. If you don't want that, you should add
; their "correct" sped-up main tempos to the list.
; byte_71A94:
SpeedUpIndex:
		dc.b 7		; GHZ
		dc.b $72	; LZ
		dc.b $73	; MZ
		dc.b $26	; SLZ
		dc.b $15	; SYZ
		dc.b 8		; SBZ
		dc.b $FF	; Invincibility
		dc.b 5		; Extra Life
		;dc.b ?		; Special Stage
		;dc.b ?		; Title Screen
		;dc.b ?		; Ending
		;dc.b ?		; Boss
		;dc.b ?		; FZ
		;dc.b ?		; Sonic Got Through
		;dc.b ?		; Game Over
		;dc.b ?		; Continue Screen
		;dc.b ?		; Credits
		;dc.b ?		; Drowning
		;dc.b ?		; Get Emerald

; ---------------------------------------------------------------------------
; Music	Pointers
; ---------------------------------------------------------------------------
MusicIndex:
ptr_mus01:	dc.l Music01
ptr_mus02:	dc.l Music02
ptr_mus03:	dc.l Music03
ptr_mus04:	dc.l Music04
ptr_mus05:	dc.l Music05
ptr_mus06:	dc.l Music06
ptr_mus07:	dc.l Music07
ptr_mus08:	dc.l Music08
ptr_mus09:	dc.l Music09
ptr_mus0A:	dc.l Music0A
ptr_mus0B:	dc.l Music0B
ptr_mus0C:	dc.l Music0C
ptr_mus0D:	dc.l Music0D
ptr_mus0E:	dc.l Music0E
ptr_mus0F:	dc.l Music0F
ptr_mus10:	dc.l Music10
ptr_mus11:	dc.l Music11
ptr_mus12:	dc.l Music12
ptr_mus13:	dc.l Music13
ptr_musend
; ---------------------------------------------------------------------------
; Priority of sound. New music or SFX must have a priority higher than or equal
; to what is stored in SMPS_RAM.v_sndprio or it won't play. If bit 7 of new priority is
; set ($80 and up), the new music or SFX will not set its priority -- meaning
; any music or SFX can override it (as long as it can override whatever was
; playing before). Usually, SFX will only override SFX, special SFX ($D0-$DF)
; will only override special SFX and music will only override music.
; ---------------------------------------------------------------------------
; SoundTypes:
; Extended sound priority to play all sounds without reading garbage data
SoundPriorities:
		dc.b     $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $01
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $10
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $20
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $30
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $40
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $50
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $60
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $70
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $80
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $90
		dc.b $80,$70,$70,$70,$70,$70,$70,$70,$70,$70,$68,$70,$70,$70,$60,$70	; $A0
		dc.b $70,$60,$70,$60,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$7F	; $B0
		dc.b $60,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70,$70	; $C0
		dc.b $80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80,$80	; $D0
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90	; $E0
		dc.b $90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90,$90		; $F0
		even

; ---------------------------------------------------------------------------
; Subroutine to update music more than once per frame
; (Called by horizontal & vert. interrupts)
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71B4C:
UpdateMusic:
; Removed elements of the old driver
		lea		(v_snddriver_ram&$FFFFFF).l,a6
		clr.b	SMPS_RAM.f_voice_selector(a6)
		tst.b	SMPS_RAM.f_pausemusic(a6)		; is music paused?
		bne.w	PauseMusic			; if yes, branch
		subq.b	#1,SMPS_RAM.v_main_tempo_timeout(a6)	; Has main tempo timer expired?
		bne.s	.skipdelay
		jsr		TempoWait(pc)
; loc_71B9E:
.skipdelay:
		move.b	SMPS_RAM.v_fadeout_counter(a6),d0
		beq.s	.skipfadeout
		jsr	DoFadeOut(pc)
; loc_71BA8:
.skipfadeout:
		tst.b	SMPS_RAM.f_fadein_flag(a6)
		beq.s	.skipfadein
		jsr	DoFadeIn(pc)
; loc_71BB2:
.skipfadein:
	; Sound driver bugfixes
		moveq	#0,d0
		or.b	SMPS_RAM.v_soundqueue2(a6),d0	; Also check SMPS_RAM.v_soundqueue2
		or.w	SMPS_RAM.v_soundqueue0(a6),d0	; is a music or sound queued for playing?
	; Sound driver bugfixes end
		beq.s	.nosndinput		; if not, branch
		jsr	CycleSoundQueue(pc)
; loc_71BBC:
.nosndinput:	; .nonewsound removed -- Alex Field Sound Index Expansion
	; Spin Dash SFX
		tst.b	(v_spindashsfx2).w
		beq.s	.cont
		subq.b	#1,(v_spindashsfx2).w

.cont:
	; Spin Dash SFX end
		lea		SMPS_RAM.v_music_dac_track(a6),a5
		tst.b	SMPS_Track.PlaybackControl(a5)	; Is DAC track playing?
		bpl.s	.dacdone					; Branch if not
		jsr		DACUpdateTrack(pc)
; loc_71BD4:
.dacdone:
		clr.b	SMPS_RAM.f_updating_dac(a6)
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7	; 6 FM tracks
; loc_71BDA:
.bgmfmloop:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5) ; Is track playing?
		bpl.s	.bgmfmnext		; Branch if not
		jsr	FMUpdateTrack(pc)
; loc_71BE6:
.bgmfmnext:
		dbf	d7,.bgmfmloop

		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7 ; 3 PSG tracks
; loc_71BEC:
.bgmpsgloop:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5) ; Is track playing?
		bpl.s	.bgmpsgnext		; Branch if not
		jsr	PSGUpdateTrack(pc)
; loc_71BF8:
.bgmpsgnext:
		dbf	d7,.bgmpsgloop

		move.b	#$80,SMPS_RAM.f_voice_selector(a6)			; Now at SFX tracks
		moveq	#SMPS_SFX_FM_TRACK_COUNT-1,d7	; 3 FM tracks (SFX)
; loc_71C04:
.sfxfmloop:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5) ; Is track playing?
		bpl.s	.sfxfmnext		; Branch if not
		jsr	FMUpdateTrack(pc)
; loc_71C10:
.sfxfmnext:
		dbf	d7,.sfxfmloop

		moveq	#SMPS_SFX_PSG_TRACK_COUNT-1,d7 ; 3 PSG tracks (SFX)
; loc_71C16:
.sfxpsgloop:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5) ; Is track playing?
		bpl.s	.sfxpsgnext		; Branch if not
		jsr	PSGUpdateTrack(pc)
; loc_71C22:
.sfxpsgnext:
		dbf	d7,.sfxpsgloop
		
		move.b	#$40,SMPS_RAM.f_voice_selector(a6) ; Now at special SFX tracks
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5) ; Is track playing?
		bpl.s	.specfmdone		; Branch if not
		jsr	FMUpdateTrack(pc)
; loc_71C38:
.specfmdone:
		adda.w	#SMPS_Track.len,a5
		tst.b	SMPS_Track.PlaybackControl(a5) ; Is track playing
		bpl.s	DoStartZ80		; Branch if not
		jsr	PSGUpdateTrack(pc)
; loc_71C44:
DoStartZ80:
		; removed Z80 macro
		rts	
; End of function UpdateMusic


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71C4E: UpdateDAC:
DACUpdateTrack:
		subq.b	#1,SMPS_Track.DurationTimeout(a5)	; Has DAC sample timeout expired?
		bne.s	.locret				; Return if not
		move.b	#$80,SMPS_RAM.f_updating_dac(a6)		; Set flag to indicate this is the DAC
;DACDoNext:
		movea.l	SMPS_Track.DataPointer(a5),a4	; DAC track data pointer
; loc_71C5E:
.sampleloop:
		moveq	#0,d5
		move.b	(a4)+,d5	; Get next SMPS unit
		cmpi.b	#$E0,d5		; Is it a coord. flag?
		blo.s	.notcoord	; Branch if not
		jsr	CoordFlag(pc)
		bra.s	.sampleloop
; ===========================================================================
; loc_71C6E:
.notcoord:
		tst.b	d5			; Is it a sample?
		bpl.s	.gotduration		; Branch if not (duration)
		move.b	d5,SMPS_Track.SavedDAC(a5)	; Store new sample
		move.b	(a4)+,d5		; Get another byte
		bpl.s	.gotduration		; Branch if it is a duration
		subq.w	#1,a4			; Put byte back
		move.b	SMPS_Track.SavedDuration(a5),SMPS_Track.DurationTimeout(a5) ; Use last duration
		bra.s	.gotsampleduration
; ===========================================================================
; loc_71C84:
.gotduration:
		jsr	SetDuration(pc)
; loc_71C88:
.gotsampleduration:
		move.l	a4,SMPS_Track.DataPointer(a5)		; Save pointer
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.locret								; Return if yes
		moveq	#0,d0
		move.b	SMPS_Track.SavedDAC(a5),d0			; Get sample
		cmpi.b	#$80,d0						; Is it a rest?
		beq.s	.locret						; Return if yes
		MPCM_stopZ80							; ++
		move.b	d0, z80_ram+Z_MPCM_CommandInput	; ++ send DAC sample to Mega PCM
		MPCM_startZ80							; ++
; locret_71CAA:
.locret:
		rts
; End of function DACUpdateTrack

; ===========================================================================
; Note: this only defines rates for samples $88-$8D, meaning $8E-$8F are invalid.
; Also, $8C-$8D are so slow you may want to skip them.
; byte_71CC4:
DAC_sample_rate:
		dc.b dpcmLoopCounter(9750)
		dc.b dpcmLoopCounter(8750)
		dc.b dpcmLoopCounter(7150)
		dc.b dpcmLoopCounter(7000)
		dc.b $FF, $FF
		even

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71CCA:
FMUpdateTrack:
		subq.b	#1,SMPS_Track.DurationTimeout(a5)	; Update duration timeout
		bne.s	.notegoing			; Branch if it hasn't expired
		bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack next note' bit
		jsr	FMDoNext(pc)
		jsr	FMPrepareNote(pc)
		bra.w	FMNoteOn
; ===========================================================================
; loc_71CE0:
.notegoing:
		jsr	NoteTimeoutUpdate(pc)
		jsr	DoModulation(pc)
		bra.w	FMUpdateFreq
; End of function FMUpdateTrack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71CEC:
FMDoNext:
		movea.l	SMPS_Track.DataPointer(a5),a4		; Track data pointer
		bclr	#1,SMPS_Track.PlaybackControl(a5)	; Clear 'track at rest' bit
; loc_71CF4:
.noteloop:
		moveq	#0,d5
		move.b	(a4)+,d5	; Get byte from track
		cmpi.b	#$E0,d5		; Is this a coord. flag?
		blo.s	.gotnote	; Branch if not
		jsr	CoordFlag(pc)
		bra.s	.noteloop
; ===========================================================================
; loc_71D04:
.gotnote:
		jsr	FMNoteOff(pc)
		tst.b	d5		; Is this a note?
		bpl.s	.gotduration	; Branch if not
		jsr	FMSetFreq(pc)
		move.b	(a4)+,d5	; Get another byte
		bpl.s	.gotduration	; Branch if it is a duration
		subq.w	#1,a4		; Otherwise, put it back
		bra.w	FinishTrackUpdate
; ===========================================================================
; loc_71D1A:
.gotduration:
		jsr	SetDuration(pc)
		bra.w	FinishTrackUpdate
; End of function FMDoNext


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71D22:
FMSetFreq:
		subi.b	#$80,d5			; Make it a zero-based index
		beq.s	TrackSetRest
		add.b	SMPS_Track.Transpose(a5),d5	; Add track transposition
		andi.w	#$7F,d5			; Clear high byte and sign bit
		lsl.w	#1,d5
		lea		FMFrequencies(pc),a0
		move.w	(a0,d5.w),d6
		move.w	d6,SMPS_Track.Freq(a5)	; Store new frequency
		rts	
; End of function FMSetFreq


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71D40:
SetDuration:
		move.b	d5,d0
		move.b	SMPS_Track.TempoDivider(a5),d1	; Get dividing timing
; loc_71D46:
.multloop:
		subq.b	#1,d1
		beq.s	.donemult
		add.b	d5,d0
		bra.s	.multloop
; ===========================================================================
; loc_71D4E:
.donemult:
		move.b	d0,SMPS_Track.SavedDuration(a5)	; Save duration
		move.b	d0,SMPS_Track.DurationTimeout(a5)	; Save duration timeout
		rts	
; End of function SetDuration

; ===========================================================================
; loc_71D58:
TrackSetRest:
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		clr.w	SMPS_Track.Freq(a5)			; Clear frequency

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71D60:
FinishTrackUpdate:
		move.l	a4,SMPS_Track.DataPointer(a5)	; Store new track position
		move.b	SMPS_Track.SavedDuration(a5),SMPS_Track.DurationTimeout(a5)	; Reset note timeout
		btst	#4,SMPS_Track.PlaybackControl(a5)	; Is track set to not attack note?
		bne.s	.locret				; If so, branch
		move.b	SMPS_Track.NoteTimeoutMaster(a5),SMPS_Track.NoteTimeout(a5)	; Reset note fill timeout
		clr.b	SMPS_Track.VolEnvIndex(a5)		; Reset PSG volume envelope index (even on FM tracks...)
		btst	#3,SMPS_Track.PlaybackControl(a5)	; Is modulation on?
		beq.s	.locret				; If not, return
		movea.l	SMPS_Track.ModulationPtr(a5),a0	; Modulation data pointer
		move.b	(a0)+,SMPS_Track.ModulationWait(a5)	; Reset wait
		move.b	(a0)+,SMPS_Track.ModulationSpeed(a5)	; Reset speed
		move.b	(a0)+,SMPS_Track.ModulationDelta(a5)	; Reset delta
		move.b	(a0)+,d0			; Get steps
		lsr.b	#1,d0				; Halve them
		move.b	d0,SMPS_Track.ModulationSteps(a5)	; Then store
		clr.w	SMPS_Track.ModulationVal(a5)		; Reset frequency change
; locret_71D9C:
.locret:
		rts	
; End of function FinishTrackUpdate


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71D9E: NoteFillUpdate
NoteTimeoutUpdate:
		tst.b	SMPS_Track.NoteTimeout(a5)	; Is note fill on?
		beq.s	.locret
		subq.b	#1,SMPS_Track.NoteTimeout(a5)	; Update note fill timeout
		bne.s	.locret				; Return if it hasn't expired
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Put track at rest
		tst.b	SMPS_Track.VoiceControl(a5)		; Is this a PSG track?
		bmi.w	.psgnoteoff			; If yes, branch
		jsr	FMNoteOff(pc)
		addq.w	#4,sp				; Do not return to caller
		rts	
; ===========================================================================
; loc_71DBE:
.psgnoteoff:
		jsr	PSGNoteOff(pc)
		addq.w	#4,sp		; Do not return to caller
; locret_71DC4:
.locret:
		rts	
; End of function NoteTimeoutUpdate


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71DC6:
DoModulation:
		addq.w	#4,sp				; Do not return to caller (but see below)
		; Bugfix - Fix modulation during rests - ValleyBell
        btst	#1,(a5)			; Is note playing?
        bne.s	.locret			; no - return		
		; Fix End
		btst	#3,SMPS_Track.PlaybackControl(a5)	; Is modulation active?
		beq.s	.locret				; Return if not
		tst.b	SMPS_Track.ModulationWait(a5)	; Has modulation wait expired?
		beq.s	.waitdone			; If yes, branch
		subq.b	#1,SMPS_Track.ModulationWait(a5)	; Update wait timeout
		rts	
; ===========================================================================
; loc_71DDA:
.waitdone:
		subq.b	#1,SMPS_Track.ModulationSpeed(a5)	; Update speed
		beq.s	.updatemodulation		; If it expired, want to update modulation
		rts	
; ===========================================================================
; loc_71DE2:
.updatemodulation:
		movea.l	SMPS_Track.ModulationPtr(a5),a0	; Get modulation data
		move.b	1(a0),SMPS_Track.ModulationSpeed(a5)	; Restore modulation speed
		tst.b	SMPS_Track.ModulationSteps(a5)	; Check number of steps
		bne.s	.calcfreq			; If nonzero, branch
		move.b	3(a0),SMPS_Track.ModulationSteps(a5)	; Restore from modulation data
		neg.b	SMPS_Track.ModulationDelta(a5)	; Negate modulation delta
		rts	
; ===========================================================================
; loc_71DFE:
.calcfreq:
		subq.b	#1,SMPS_Track.ModulationSteps(a5)	; Update modulation steps
		move.b	SMPS_Track.ModulationDelta(a5),d6	; Get modulation delta
		ext.w	d6
		add.w	SMPS_Track.ModulationVal(a5),d6	; Add cumulative modulation change
		move.w	d6,SMPS_Track.ModulationVal(a5)	; Store it
		add.w	SMPS_Track.Freq(a5),d6		; Add note frequency to it
		subq.w	#4,sp		; In this case, we want to return to caller after all
; locret_71E16:
.locret:
		rts	
; End of function DoModulation


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_71E18:
FMPrepareNote:
		btst	#1,SMPS_Track.PlaybackControl(a5)	; Is track resting?
		bne.s	locret_71E48			; Return if so
		move.w	SMPS_Track.Freq(a5),d6		; Get current note frequency
		beq.s	FMSetRest			; Branch if zero
		; Bugfix: Fix Modulation Frequency bug on note-on - AURORA☆FIELDS
		btst	#3,(a5)			; check if modulation is active
		beq.s	FMUpdateFreq		; if not, branch
		add.w	SMPS_Track.ModulationVal(a5),d6		; add modulation frequency to d6		
		; Bugfix end
; loc_71E24:
FMUpdateFreq:
		move.b	SMPS_Track.Detune(a5),d0 	; Get detune value
		ext.w	d0
		add.w	d0,d6				; Add note frequency
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	locret_71E48			; Return if so
		move.w	d6,d1
		lsr.w	#8,d1
		move.b	#$A4,d0			; Register for upper 6 bits of frequency
		jsr	WriteFMIorII(pc)
		move.b	d6,d1
		move.b	#$A0,d0			; Register for lower 8 bits of frequency
		jsr	WriteFMIorII(pc)	; (It would be better if this were a jmp)
; locret_71E48:
locret_71E48:
		rts	
; ===========================================================================
; loc_71E4A:
FMSetRest:
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		rts	
; End of function FMPrepareNote

; ===========================================================================
; loc_71E50:
PauseMusic:
		bmi.s	.unpausemusic		; Branch if music is being unpaused
		cmpi.b	#2,SMPS_RAM.f_pausemusic(a6)
		beq.w	.unpausedallfm
		move.b	#2,SMPS_RAM.f_pausemusic(a6)
		moveq	#2,d3
		move.b	#$B4,d0		; Command to set AMS/FMS/panning
		moveq	#0,d1		; No panning, AMS or FMS
; loc_71E6A:
.killpanloop:
		jsr	WriteFMI(pc)
		jsr	WriteFMII(pc)
		addq.b	#1,d0
		dbf	d3,.killpanloop

		moveq	#2,d3
		moveq	#$28,d0		; Key on/off register
; loc_71E7C:
.noteoffloop:
		move.b	d3,d1		; FM1, FM2, FM3
		jsr	WriteFMI(pc)
		addq.b	#4,d1		; FM4, FM5, FM6
		jsr	WriteFMI(pc)
		dbf	d3,.noteoffloop

		jsr	PSGSilenceAll(pc)
		bra.w	DoStartZ80
; ===========================================================================
; loc_71E94:
.unpausemusic:
		clr.b	SMPS_RAM.f_pausemusic(a6)
		moveq	#SMPS_Track.len,d3
		lea	SMPS_RAM.v_music_fmdac_tracks(a6),a5
		moveq	#SMPS_MUSIC_FM_DAC_TRACK_COUNT-1,d4	; 6 FM + 1 DAC tracks
; loc_71EA0:
.bgmfmloop:
		btst	#7,SMPS_Track.PlaybackControl(a5)	; Is track playing?
		beq.s	.bgmfmnext			; Branch if not
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.bgmfmnext			; Branch if yes
		move.b	#$B4,d0				; Command to set AMS/FMS/panning
		move.b	SMPS_Track.AMSFMSPan(a5),d1		; Get value from track RAM
		jsr	WriteFMIorII(pc)
; loc_71EB8:
.bgmfmnext:
		adda.w	d3,a5
		dbf	d4,.bgmfmloop

		lea	SMPS_RAM.v_sfx_fm_tracks(a6),a5
		moveq	#SMPS_SFX_FM_TRACK_COUNT-1,d4	; 3 FM tracks (SFX)
; loc_71EC4:
.sfxfmloop:
		btst	#7,SMPS_Track.PlaybackControl(a5)	; Is track playing?
		beq.s	.sfxfmnext			; Branch if not
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.sfxfmnext			; Branch if yes
		move.b	#$B4,d0				; Command to set AMS/FMS/panning
		move.b	SMPS_Track.AMSFMSPan(a5),d1		; Get value from track RAM
		jsr	WriteFMIorII(pc)
; loc_71EDC:
.sfxfmnext:
		adda.w	d3,a5
		dbf	d4,.sfxfmloop

		lea	SMPS_RAM.v_spcsfx_track_ram(a6),a5
		btst	#7,SMPS_Track.PlaybackControl(a5)	; Is track playing?
		beq.s	.unpausedallfm			; Branch if not
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.unpausedallfm			; Branch if yes
		move.b	#$B4,d0				; Command to set AMS/FMS/panning
		move.b	SMPS_Track.AMSFMSPan(a5),d1		; Get value from track RAM
		jsr	WriteFMIorII(pc)
; loc_71EFE:
.unpausedallfm:
		bra.w	DoStartZ80

; ---------------------------------------------------------------------------
; Subroutine to	play a sound or	music track
; ---------------------------------------------------------------------------

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Sound_Play:
CycleSoundQueue:
		movea.l	(Go_SoundPriorities).l,a0
		lea		SMPS_RAM.v_soundqueue0(a6),a1	; load music track number
		_move.b	SMPS_RAM.v_sndprio(a6),d3		; Get priority of currently playing SFX
		moveq	#SMPS_RAM.v_soundqueue_end-SMPS_RAM.v_soundqueue_start-1,d4
; loc_71F12:
.inputloop:
		move.b	(a1),d0						; move track number to d0
		move.b	d0,d1
		clr.b	(a1)+						; Clear entry
		subi.b	#bgm__First,d0				; Make it into 0-based index
		bcs.s	.nextinput					; If negative (i.e., it was $80 or lower), branch
	; .havesound: and prior checks removed -- Alex Field Sound Index Expansion		
		andi.w	#$7F,d0						; Clear high byte and sign bit
		move.b	(a0,d0.w),d2				; Get sound type
		cmp.b	d3,d2						; Is it a lower priority sound?
		blo.s	.nextinput					; Branch if yes
		move.b	d2,d3						; Store new priority
		move.b	d1,SMPS_RAM.v_sound_id(a6)	; Queue sound for play
; loc_71F3E:
.nextinput:
		dbf	d4,.inputloop

		tst.b	d3							; We don't want to change sound priority if it is negative
		bmi.s	PlaySoundID					; Branch ahead instead of returning -- Alex Field Sound Index Expansion
		_move.b	d3,SMPS_RAM.v_sndprio(a6)	; Set new sound priority
		; fallthrough
; End of function CycleSoundQueue


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Sound_ChkValue:
PlaySoundID:
		moveq	#0,d7
		move.b	SMPS_RAM.v_sound_id(a6),d7
		; delete conditional branches -- Alex Field Sound Index Expansion	
		move.b	#$80,SMPS_RAM.v_sound_id(a6)	; reset	music flag

	; Music
		cmpi.b	#bgm__Last,d7		; Is this music ($01-$13)? -- Sound driver bugfixes: Playing sounds $14-$1F will cause a crash!
		bls.w	Sound_PlayBGM		; Branch and play if yes
		cmpi.b	#sfx__First,d7		; Is this after music but before sfx? ($14-$1F)
		blo.w	.locret				; Return if yes. Playing sounds $14-$1F will cause a crash!

	; SFX
		cmpi.b	#sfx__Last,d7		; Is this sfx?
		bls.w	Sound_PlaySFX		; Branch and play if yes
		cmpi.b	#spec__First,d7		; Is this after sfx but before special sfx?
		blo.w	.locret				; Return if yes

	; Special SFX
		cmpi.b	#sfx_Waterfall,d7	; Is this special sfx?
		bcs.w	Sound_PlaySpecial	; Branch and play if yes
		cmpi.b	#spec__Last,d7		; Is this other new special sfx?
		ble.w	Sound_SpecialSFX	; Branch and play if yes

	; Sound Commands
		cmpi.b	#flg__Last,d7		; Is this a command flag?
		bls.s	Sound_Commands		; Branch if yes
		
; locret_71F8C:
.locret:
		rts
; ===========================================================================

; Sound_E0toE4:
Sound_Commands:
		subi.b	#flg__First,d7
		lsl.w	#2,d7
		jmp		Sound_ExIndex(pc,d7.w)
; ===========================================================================

Sound_ExIndex:
ptr_flgFB:	bra.w	FadeOutMusic
ptr_flgFC:	bra.w	PlaySegaSound
ptr_flgFD:	bra.w	SpeedUpMusic
ptr_flgFE:	bra.w	SlowDownMusic
ptr_flgFF:	bra.w	StopAllSound
ptr_flgend
; ===========================================================================
; ---------------------------------------------------------------------------
; Play "Say-gaa" PCM sound
; ---------------------------------------------------------------------------
; Sound_E1: PlaySega:
PlaySegaSound:
		moveq	#$FFFFFF8C, d0		; request SEGA PCM sample
		jmp		MegaPCM_PlaySample
; ===========================================================================
; ---------------------------------------------------------------------------
; Play music track $81-$9F
; ---------------------------------------------------------------------------
; Sound_81to9F:
Sound_PlayBGM:
		cmpi.b	#bgm_ExtraLife,d7	; is the "extra life" music to be played?
		bne.s	.bgmnot1up		; if not, branch
		tst.b	SMPS_RAM.f_1up_playing(a6)	; Is a 1-up music playing?
		bne.w	.locdblret		; if yes, branch
		lea	SMPS_RAM.v_music_track_ram(a6),a5
		moveq	#SMPS_MUSIC_TRACK_COUNT-1,d0	; 1 DAC + 6 FM + 3 PSG tracks
; loc_71FE6:
.clearsfxloop:
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX is overriding' bit
		adda.w	#SMPS_Track.len,a5
		dbf	d0,.clearsfxloop

		lea	SMPS_RAM.v_sfx_track_ram(a6),a5
		moveq	#SMPS_SFX_TRACK_COUNT-1,d0	; 3 FM + 3 PSG tracks (SFX)
; loc_71FF8:
.cleartrackplayloop:
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Clear 'track is playing' bit
		adda.w	#SMPS_Track.len,a5
		dbf	d0,.cleartrackplayloop

		_clr.b	SMPS_RAM.v_sndprio(a6)		; Clear priority
		movea.l	a6,a0
		lea	SMPS_RAM.v_1up_ram_copy(a6),a1
		move.w	#((SMPS_RAM.v_1up_ram_end-SMPS_RAM.v_1up_ram)/4)-1,d0	; Backup $220 bytes: all variables and music track data
; loc_72012:
.backupramloop:
		move.l	(a0)+,(a1)+
		dbf	d0,.backupramloop

		move.b	#$80,SMPS_RAM.f_1up_playing(a6)
		_clr.b	SMPS_RAM.v_sndprio(a6)		; Clear priority again (?)
		bra.s	.bgm_loadMusic
; ===========================================================================
; loc_72024:
.bgmnot1up:
		clr.b	SMPS_RAM.f_1up_playing(a6)
		clr.b	SMPS_RAM.v_fadein_counter(a6)
; loc_7202C:
.bgm_loadMusic:
		jsr	InitMusicPlayback(pc)
		movea.l	(Go_SpeedUpIndex).l,a4
		subi.b	#bgm__First,d7
		move.b	(a4,d7.w),SMPS_RAM.v_speeduptempo(a6)
		movea.l	(Go_MusicIndex).l,a4
		lsl.w	#2,d7
		movea.l	(a4,d7.w),a4		; a4 now points to (uncompressed) song data
		moveq	#0,d0
		move.w	(a4),d0			; load voice pointer
		add.l	a4,d0			; It is a relative pointer
		move.l	d0,SMPS_RAM.v_voice_ptr(a6)
		move.b	5(a4),d0		; load tempo
		move.b	d0,SMPS_RAM.v_tempo_mod(a6)
		tst.b	SMPS_RAM.f_speedup(a6)
		beq.s	.nospeedshoes
		move.b	SMPS_RAM.v_speeduptempo(a6),d0
; loc_72068:
.nospeedshoes:
		move.b	d0,SMPS_RAM.v_main_tempo(a6)
		move.b	d0,SMPS_RAM.v_main_tempo_timeout(a6)
		moveq	#0,d1
		movea.l	a4,a3
		addq.w	#6,a4			; Point past header
		moveq	#0,d7
		move.b	2(a3),d7		; load number of FM+DAC tracks
		beq.w	.bgm_fmdone		; branch if zero
		subq.b	#1,d7
		move.b	#$C0,d1			; Default AMS+FMS+Panning
		move.b	4(a3),d4		; load tempo dividing timing
		moveq	#SMPS_Track.len,d6
		move.b	#1,d5			; Note duration for first "note"
		lea	SMPS_RAM.v_music_fmdac_tracks(a6),a1
		lea	FMDACInitBytes(pc),a2
; loc_72098:
.bgm_fmloadloop:
		bset	#7,SMPS_Track.PlaybackControl(a1)	; Initial playback control: set 'track playing' bit
		move.b	(a2)+,SMPS_Track.VoiceControl(a1)	; Voice control bits
		move.b	d4,SMPS_Track.TempoDivider(a1)
		move.b	d6,SMPS_Track.StackPointer(a1)	; set "gosub" (coord flag $F8) stack init value
		move.b	d1,SMPS_Track.AMSFMSPan(a1)		; Set AMS/FMS/Panning
		move.b	d5,SMPS_Track.DurationTimeout(a1)	; Set duration of first "note"
		moveq	#0,d0
		move.w	(a4)+,d0			; load DAC/FM pointer
		add.l	a3,d0				; Relative pointer
		move.l	d0,SMPS_Track.DataPointer(a1)		; Store track pointer
		move.w	(a4)+,SMPS_Track.Transpose(a1)	; load FM channel modifier
		adda.w	d6,a1
		dbf	d7,.bgm_fmloadloop

		cmpi.b	#7,2(a3)	; Are 7 FM tracks defined?
		bne.s	.silencefm6
		moveq	#$2B,d0		; DAC enable/disable register
		moveq	#0,d1		; Disable DAC
		jsr	WriteFMI(pc)
		bra.w	.bgm_fmdone
; ===========================================================================
; loc_720D8:
.silencefm6:
		moveq	#$28,d0		; Key on/off register
		moveq	#6,d1		; Note off on all operators of channel 6
		jsr	WriteFMI(pc)
		move.b	#$42,d0		; TL for operator 1 of FM6
		moveq	#$7F,d1		; Total silence
		jsr	WriteFMII(pc)
		move.b	#$4A,d0		; TL for operator 3 of FM6
		moveq	#$7F,d1		; Total silence
		jsr	WriteFMII(pc)
		move.b	#$46,d0		; TL for operator 2 of FM6
		moveq	#$7F,d1		; Total silence
		jsr	WriteFMII(pc)
		move.b	#$4E,d0		; TL for operator 4 of FM6
		moveq	#$7F,d1		; Total silence
		jsr	WriteFMII(pc)
		move.b	#$B6,d0		; AMS/FMS/panning of FM6
		move.b	#$C0,d1		; Stereo
		jsr	WriteFMII(pc)
; loc_72114:
.bgm_fmdone:
		moveq	#0,d7
		move.b	3(a3),d7	; Load number of PSG tracks
		beq.s	.bgm_psgdone	; branch if zero
		subq.b	#1,d7
		lea	SMPS_RAM.v_music_psg_tracks(a6),a1
		lea	PSGInitBytes(pc),a2
; loc_72126:
.bgm_psgloadloop:
		bset	#7,SMPS_Track.PlaybackControl(a1)	; Initial playback control: set 'track playing' bit
		move.b	(a2)+,SMPS_Track.VoiceControl(a1)	; Voice control bits
		move.b	d4,SMPS_Track.TempoDivider(a1)
		move.b	d6,SMPS_Track.StackPointer(a1)	; set "gosub" (coord flag $F8) stack init value
		move.b	d5,SMPS_Track.DurationTimeout(a1)	; Set duration of first "note"
		moveq	#0,d0
		move.w	(a4)+,d0			; load PSG channel pointer
		add.l	a3,d0				; Relative pointer
		move.l	d0,SMPS_Track.DataPointer(a1)	; Store track pointer
		move.w	(a4)+,SMPS_Track.Transpose(a1)	; load PSG modifier
		move.b	(a4)+,d0			; load redundant byte
		move.b	(a4)+,SMPS_Track.VoiceIndex(a1)	; Initial PSG tone
		adda.w	d6,a1
		dbf	d7,.bgm_psgloadloop
; loc_72154:
.bgm_psgdone:
		lea	SMPS_RAM.v_sfx_track_ram(a6),a1
		moveq	#SMPS_SFX_TRACK_COUNT-1,d7	; 6 SFX tracks
; loc_7215A:
.sfxstoploop:
		tst.b	SMPS_Track.PlaybackControl(a1) ; Is SFX playing?
		bpl.w	.sfxnext		; Branch if not
		moveq	#0,d0
		move.b	SMPS_Track.VoiceControl(a1),d0 ; Get voice control bits
		bmi.s	.sfxpsgchannel		; Branch if this is a PSG channel
		subq.b	#2,d0			; SFX can't have FM1 or FM2
		lsl.b	#2,d0			; Convert to index
		bra.s	.gotchannelindex
; ===========================================================================
; loc_7216E:
.sfxpsgchannel:
		lsr.b	#3,d0		; Convert to index
; loc_72170:
.gotchannelindex:
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	(a0,d0.w),a0
		bset	#2,SMPS_Track.PlaybackControl(a0)	; Set 'SFX is overriding' bit
; loc_7217C:
.sfxnext:
		adda.w	d6,a1
		dbf	d7,.sfxstoploop

		tst.w	SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	; Is special SFX being played?
		bpl.s	.checkspecialpsg				; Branch if not
		bset	#2,SMPS_RAM.v_music_fm4_track.PlaybackControl(a6)	; Set 'SFX is overriding' bit
; loc_7218E:
.checkspecialpsg:
		tst.w	SMPS_RAM.v_spcsfx_psg3_track.PlaybackControl(a6)	; Is special SFX being played?
		bpl.s	.sendfmnoteoff					; Branch if not
		bset	#2,SMPS_RAM.v_music_psg3_track.PlaybackControl(a6)	; Set 'SFX is overriding' bit
; loc_7219A:
.sendfmnoteoff:
		lea	SMPS_RAM.v_music_fm_tracks(a6),a5
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d4	; 6 FM tracks
; loc_721A0:
.fmnoteoffloop:
		jsr	FMNoteOff(pc)
		adda.w	d6,a5
		dbf	d4,.fmnoteoffloop		; run all FM tracks
		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d4 ; 3 PSG tracks
; loc_721AC:
.psgnoteoffloop:
		jsr	PSGNoteOff(pc)
		adda.w	d6,a5
		dbf	d4,.psgnoteoffloop		; run all PSG tracks
; loc_721B6:
.locdblret:
		addq.w	#4,sp	; Tamper with return value to not return to caller
		rts	
; ===========================================================================
; byte_721BA:
FMDACInitBytes:	dc.b 6,	0, 1, 2, 4, 5, 6	; first byte is for DAC; then notice the 0, 1, 2 then 4, 5, 6; this is the gap between parts I and II for YM2612 port writes
		even
; byte_721C2:
PSGInitBytes:	dc.b $80, $A0, $C0	; Specifically, these configure writes to the PSG port for each channel
		even
; ===========================================================================
; ===========================================================================
; ---------------------------------------------------------------------------
; Add more sound effects between $D1 onwards
; ---------------------------------------------------------------------------
; Sound_D1_onwards:
Sound_SpecialSFX:
		tst.b	SMPS_RAM.f_1up_playing(a6)
		bne.w	Sound_ClearPriority
		tst.b	SMPS_RAM.v_fadeout_counter(a6)
		bne.w	Sound_ClearPriority
		tst.b	SMPS_RAM.f_fadein_flag(a6)
		bne.w	Sound_ClearPriority
		clr.b	(v_spindashsfx1).w
		cmp.b	#sfx_SpinDash,d7		; is this the Spin Dash sound?
		bne.s	.cont3	; if not, branch
		move.w	d0,-(sp)
		move.b	(v_spindashsfx3).w,d0	; store extra frequency
		tst.b	(v_spindashsfx2).w	; is the Spin Dash timer active?
		bne.s	.cont1		; if it is, branch
		move.b	#-1,d0		; otherwise, reset frequency (becomes 0 on next line)

.cont1:
		addq.b	#1,d0
		cmp.b	#$C,d0		; has the limit been reached?
		bcc.s	.cont2		; if it has, branch
		move.b	d0,(v_spindashsfx3).w	; otherwise, set new frequency

.cont2:
		move.b	#1,(v_spindashsfx1).w	; set flag
		move.b	#60,(v_spindashsfx2).w	; set timer
		move.w	(sp)+,d0

.cont3:
		movea.l	Go_SoundIndex(pc),a0
		sub.b	#$A0,d7
		bra.w	SoundEffects_Common
; ---------------------------------------------------------------------------
; Play normal sound effect
; ---------------------------------------------------------------------------
; Sound_A0toCF:
Sound_PlaySFX:
		tst.b	SMPS_RAM.f_1up_playing(a6)		; Is 1-up playing?
		bne.w	Sound_ClearPriority		; Exit is it is
		tst.b	SMPS_RAM.v_fadeout_counter(a6)	; Is music being faded out?
		bne.w	Sound_ClearPriority		; Exit if it is
		tst.b	SMPS_RAM.f_fadein_flag(a6)		; Is music being faded in?
		bne.w	Sound_ClearPriority		; Exit if it is
		clr.b	(v_spindashsfx1).w		; Spin Dash SFX
		cmpi.b	#sfx_Ring,d7			; is ring sound	effect played?
		bne.s	.sfx_notRing			; if not, branch
		tst.b	SMPS_RAM.v_ring_speaker(a6)		; Is the ring sound playing on right speaker?
		bne.s	.gotringspeaker			; Branch if not
		move.b	#sfx_RingLeft,d7		; play ring sound in left speaker
; loc_721EE:
.gotringspeaker:
		bchg	#0,SMPS_RAM.v_ring_speaker(a6)	; change speaker
; Sound_notB5:
.sfx_notRing:
		cmpi.b	#sfx_Push,d7			; is "pushing" sound played?
		bne.s	.sfx_notPush			; if not, branch
		tst.b	SMPS_RAM.f_push_playing(a6)		; Is pushing sound already playing?
		bne.w	Sound_SFXCommon_Ret		; Return if not
		move.b	#$80,SMPS_RAM.f_push_playing(a6)	; Mark it as playing
; Sound_notA7:
.sfx_notPush:
	; Spin Dash SFX
		cmp.b	#sfx_SpinDash,d7		; is this the Spin Dash sound?
		bne.s	.cont3					; if not, branch
		move.w	d0,-(sp)
		move.b	(v_spindashsfx3).w,d0	; store extra frequency
		tst.b	(v_spindashsfx2).w		; is the Spin Dash timer active?
		bne.s	.cont1					; if it is, branch
		move.b	#-1,d0					; otherwise, reset frequency (becomes 0 on next line)

.cont1:
		addq.b	#1,d0
		cmp.b	#$C,d0					; has the limit been reached?
		bcc.s	.cont2					; if it has, branch
		move.b	d0,(v_spindashsfx3).w	; otherwise, set new frequency

.cont2:
		move.b	#1,(v_spindashsfx1).w	; set flag
		move.b	#60,(v_spindashsfx2).w	; set timer
		move.w	(sp)+,d0

.cont3:
	; Spin Dash SFX End
		movea.l	(Go_SoundIndex).l,a0
		subi.b	#sfx__First,d7		; Make it 0-based

SoundEffects_Common:
		lsl.w	#2,d7				; Convert sfx ID into index
		movea.l	(a0,d7.w),a3		; SFX data pointer
		movea.l	a3,a1
		moveq	#0,d1
		move.w	(a1)+,d1			; Voice pointer
		add.l	a3,d1				; Relative pointer
		move.b	(a1)+,d5			; Dividing timing
		moveq	#0,d7				; Sound driver bugfixes: prevent SFXes indexed above $3F crashing the game
		move.b	(a1)+,d7			; Number of tracks (FM + PSG)
		subq.b	#1,d7
		moveq	#SMPS_Track.len,d6
; loc_72228:
.sfx_loadloop:
		moveq	#0,d3
		move.b	1(a1),d3	; Channel assignment bits
		move.b	d3,d4
		bmi.s	.sfxinitpsg	; Branch if PSG
		subq.w	#2,d3		; SFX can only have FM3, FM4 or FM5
		lsl.w	#2,d3
		lea	SFX_BGMChannelRAM(pc),a5
		movea.l	(a5,d3.w),a5
		bset	#2,SMPS_Track.PlaybackControl(a5)	; Mark music track as being overridden
		bra.s	.sfxoverridedone
; ===========================================================================
; loc_72244:
.sfxinitpsg:
		lsr.w	#3,d3
		lea	SFX_BGMChannelRAM(pc),a5
		movea.l	(a5,d3.w),a5
		bset	#2,SMPS_Track.PlaybackControl(a5)	; Mark music track as being overridden
		cmpi.b	#$C0,d4			; Is this PSG 3?
		bne.s	.sfxoverridedone	; Branch if not
		move.b	d4,d0
		ori.b	#$1F,d0			; Command to silence PSG 3
		move.b	d0,(psg_input).l
		bchg	#5,d0			; Command to silence noise channel
		move.b	d0,(psg_input).l
; loc_7226E:
.sfxoverridedone:
		lea		SFX_SFXChannelRAM(pc),a5
		movea.l	(a5,d3.w),a5
		movea.l	a5,a2
		moveq	#(SMPS_Track.len/4)-1,d0	; $30 bytes
; loc_72276:
.clearsfxtrackram:
		clr.l	(a2)+
		dbf	d0,.clearsfxtrackram

		move.w	(a1)+,SMPS_Track.PlaybackControl(a5)	; Initial playback control bits
		move.b	d5,SMPS_Track.TempoDivider(a5)	; Initial voice control bits
		moveq	#0,d0
		move.w	(a1)+,d0			; Track data pointer
		add.l	a3,d0				; Relative pointer
		move.l	d0,SMPS_Track.DataPointer(a5)	; Store track pointer
		move.w	(a1)+,SMPS_Track.Transpose(a5)	; load FM/PSG channel modifier
	; Spin Dash SFX
		tst.b	(v_spindashsfx1).w	; is the Spin Dash sound playing?
		beq.s	.cont		; if not, branch
		move.w	d0,-(sp)
		move.b	(v_spindashsfx3).w,d0
		add.b	d0,8(a5)
		move.w	(sp)+,d0

	.cont:
	; Spin Dash SFX End
		move.b	#1,SMPS_Track.DurationTimeout(a5)	; Set duration of first "note"
		move.b	d6,SMPS_Track.StackPointer(a5)	; set "gosub" (coord flag $F8) stack init value
		tst.b	d4				; Is this a PSG channel?
		bmi.s	.sfxpsginitdone			; Branch if yes
		move.b	#$C0,SMPS_Track.AMSFMSPan(a5)	; AMS/FMS/Panning
		move.l	d1,SMPS_Track.VoicePtr(a5)		; Voice pointer
; loc_722A8:
.sfxpsginitdone:
		dbf		d7,.sfx_loadloop

		tst.b	SMPS_RAM.v_sfx_fm4_track.PlaybackControl(a6)	; Is special SFX being played?
		bpl.s	.doneoverride					; Branch if not
		bset	#2,SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	; Set 'SFX is overriding' bit
; loc_722B8:
.doneoverride:
		tst.b	SMPS_RAM.v_sfx_psg3_track.PlaybackControl(a6)		; Is SFX being played?
		bpl.s	Sound_SFXCommon_Ret								; Branch if not
		bset	#2,SMPS_RAM.v_spcsfx_psg3_track.PlaybackControl(a6)	; Set 'SFX is overriding' bit
; locret_722C4:
Sound_SFXCommon_Ret:
		rts	
; ===========================================================================
; loc_722C6:
Sound_ClearPriority:
		_clr.b	SMPS_RAM.v_sndprio(a6)	; Clear priority
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; RAM addresses for FM and PSG channel variables used by the SFX
; ---------------------------------------------------------------------------
; dword_722CC: BGMChannelRAM:
SFX_BGMChannelRAM:
		dc.l (v_snddriver_ram.v_music_fm3_track)&$FFFFFF
		dc.l 0
		dc.l (v_snddriver_ram.v_music_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_fm5_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_psg1_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_psg2_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_psg3_track)&$FFFFFF	; Plain PSG3
		dc.l (v_snddriver_ram.v_music_psg3_track)&$FFFFFF	; Noise
; dword_722EC: SFXChannelRAM:
SFX_SFXChannelRAM:
		dc.l (v_snddriver_ram.v_sfx_fm3_track)&$FFFFFF
		dc.l 0
		dc.l (v_snddriver_ram.v_sfx_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_fm5_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_psg1_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_psg2_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_psg3_track)&$FFFFFF	; Plain PSG3
		dc.l (v_snddriver_ram.v_sfx_psg3_track)&$FFFFFF	; Noise
; ===========================================================================
; ---------------------------------------------------------------------------
; Play GHZ waterfall sound
; ---------------------------------------------------------------------------
; Sound_D0toDF:
Sound_PlaySpecial:
		tst.b	SMPS_RAM.f_1up_playing(a6)	; Is 1-up playing?
		bne.w	.locret			; Return if so
		tst.b	SMPS_RAM.v_fadeout_counter(a6)	; Is music being faded out?
		bne.w	.locret			; Exit if it is
		tst.b	SMPS_RAM.f_fadein_flag(a6)	; Is music being faded in?
		bne.w	.locret			; Exit if it is
		movea.l	(Go_SpecSoundIndex).l,a0
		subi.b	#spec__First,d7		; Make it 0-based
		lsl.w	#2,d7
		movea.l	(a0,d7.w),a3
		movea.l	a3,a1
		moveq	#0,d0
		move.w	(a1)+,d0			; Voice pointer
		add.l	a3,d0				; Relative pointer
		move.l	d0,SMPS_RAM.v_special_voice_ptr(a6)	; Store voice pointer
		move.b	(a1)+,d5			; Dividing timing
		moveq	#0,d7				; Sound driver bugfixes: prevent SFXes indexed above $3F crashing the game
		move.b	(a1)+,d7			; Number of tracks (FM + PSG)
		subq.b	#1,d7
		moveq	#SMPS_Track.len,d6
; loc_72348:
.sfxloadloop:
		move.b	1(a1),d4					; Voice control bits
		bmi.s	.sfxoverridepsg					; Branch if PSG
		bset	#2,SMPS_RAM.v_music_fm4_track.PlaybackControl(a6)	; Set 'SFX is overriding' bit

		lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
		bra.s	.sfxinitpsg
; ===========================================================================
; loc_7235A:
.sfxoverridepsg:
		bset	#2,SMPS_RAM.v_music_psg3_track.PlaybackControl(a6)	; Set 'SFX is overriding' bit
		lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a5
; loc_72364:
.sfxinitpsg:
		movea.l	a5,a2
		moveq	#(SMPS_Track.len/4)-1,d0	; $30 bytes
; loc_72368:
.clearsfxtrackram:
		clr.l	(a2)+
		dbf	d0,.clearsfxtrackram

		move.w	(a1)+,SMPS_Track.PlaybackControl(a5)	; Initial playback control bits & voice control bits
		move.b	d5,SMPS_Track.TempoDivider(a5)
		moveq	#0,d0
		move.w	(a1)+,d0			; Track data pointer
		add.l	a3,d0				; Relative pointer
		move.l	d0,SMPS_Track.DataPointer(a5)	; Store track pointer
		move.w	(a1)+,SMPS_Track.Transpose(a5)	; load FM/PSG channel modifier
		move.b	#1,SMPS_Track.DurationTimeout(a5)	; Set duration of first "note"
		move.b	d6,SMPS_Track.StackPointer(a5)	; set "gosub" (coord flag $F8) stack init value
		tst.b	d4				; Is this a PSG channel?
		bmi.s	.sfxpsginitdone			; Branch if yes
		move.b	#$C0,SMPS_Track.AMSFMSPan(a5)	; AMS/FMS/Panning
; loc_72396:
.sfxpsginitdone:
		dbf	d7,.sfxloadloop

		tst.b	SMPS_RAM.v_sfx_fm4_track.PlaybackControl(a6)	; Is track playing?
		bpl.s	.doneoverride					; Branch if not
		bset	#2,SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	; Set 'SFX is overriding' bit
; loc_723A6:
.doneoverride:
		tst.b	SMPS_RAM.v_sfx_psg3_track.PlaybackControl(a6)	; Is track playing?
		bpl.s	.locret						; Branch if not
		bset	#2,SMPS_RAM.v_spcsfx_psg3_track.PlaybackControl(a6)	; Set 'SFX is overriding' bit
		ori.b	#$1F,d4						; Command to silence channel
		move.b	d4,(psg_input).l
		bchg	#5,d4			; Command to silence noise channel
		move.b	d4,(psg_input).l
; locret_723C6:
.locret:
		rts	
; End of function Sound_PlaySpecial

; ===========================================================================
; ---------------------------------------------------------------------------
; Unused RAM addresses for FM and PSG channel variables used by the Special SFX
; ---------------------------------------------------------------------------
; The first block would have been used for overriding the music tracks
; as they have a lower priority, just as they are in Sound_PlaySFX
; The third block would be used to set up the Special SFX
; The second block, however, is for the SFX tracks, which have a higher priority
; and would be checked for if they're currently playing
; If they are, then the third block would be used again, this time to mark
; the new tracks as 'currently playing'

; These were actually used in Moonwalker's driver (and other SMPS 68k Type 1a drivers)

; BGMFM4PSG3RAM:
;SpecSFX_BGMChannelRAM:
		dc.l (v_snddriver_ram.v_music_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_music_psg3_track)&$FFFFFF
; SFXFM4PSG3RAM:
;SpecSFX_SFXChannelRAM:
		dc.l (v_snddriver_ram.v_sfx_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_sfx_psg3_track)&$FFFFFF
; SpecialSFXFM4PSG3RAM:
;SpecSFX_SpecSFXChannelRAM:
		dc.l (v_snddriver_ram.v_spcsfx_fm4_track)&$FFFFFF
		dc.l (v_snddriver_ram.v_spcsfx_psg3_track)&$FFFFFF

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Snd_FadeOut1: Snd_FadeOutSFX: FadeOutSFX:
StopSFX:
		_clr.b	SMPS_RAM.v_sndprio(a6)		; Clear priority
		lea		SMPS_RAM.v_sfx_track_ram(a6),a5
		moveq	#SMPS_SFX_TRACK_COUNT-1,d7	; 3 FM + 3 PSG tracks (SFX)
; loc_723EA:
.trackloop:
		tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
		bpl.w	.nexttrack			; Branch if not
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		moveq	#0,d3
		move.b	SMPS_Track.VoiceControl(a5),d3	; Get voice control bits
		bmi.s	.trackpsg			; Branch if PSG
		jsr		FMNoteOff(pc)
		cmpi.b	#4,d3						; Is this FM4?
		bne.s	.getfmpointer					; Branch if not
		tst.b	SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	; Is special SFX playing?
		bpl.s	.getfmpointer					; Branch if not
		movea.l	a5,a3						; Sound driver fixes: Without this, the code is broken.
											; It is dangerous to do a fade out when a GHZ waterfall is playing its sound!
		lea		SMPS_RAM.v_spcsfx_fm4_track(a6),a5
		movea.l	SMPS_RAM.v_special_voice_ptr(a6),a1	; Get special voice pointer
		bra.s	.gotfmpointer
; ===========================================================================
; loc_72416:
.getfmpointer:
		subq.b	#2,d3		; SFX only has FM3 and up
		lsl.b	#2,d3
		lea		SFX_BGMChannelRAM(pc),a0
		movea.l	a5,a3
		movea.l	(a0,d3.w),a5
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1	; Get music voice pointer
; loc_72428:
.gotfmpointer:
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		move.b	SMPS_Track.VoiceIndex(a5),d0	; Current voice
		jsr		SetVoice(pc)
		movea.l	a3,a5
		bra.s	.nexttrack
; ===========================================================================
; loc_7243C:
.trackpsg:
		jsr		PSGNoteOff(pc)
		lea		SMPS_RAM.v_spcsfx_psg3_track(a6),a0
	; Sound driver fixes: Added missing check
		tst.b	SMPS_Track.PlaybackControl(a0)	; Is track playing?
		bpl.s	.getchannelptr			; Branch if not
	; Sound driver fixes end
		cmpi.b	#$E0,d3			; Is this a noise channel:
		beq.s	.gotpsgpointer		; Branch if yes
		cmpi.b	#$C0,d3			; Is this PSG 3?
		beq.s	.gotpsgpointer		; Branch if yes

.getchannelptr:
		lsr.b	#3,d3
		lea		SFX_BGMChannelRAM(pc),a0
		movea.l	(a0,d3.w),a0
; loc_7245A:
.gotpsgpointer:
		bclr	#2,SMPS_Track.PlaybackControl(a0)		; Clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a0)		; Set 'track at rest' bit
		cmpi.b	#$E0,SMPS_Track.VoiceControl(a0)		; Is this a noise channel?
		bne.s	.nexttrack								; Branch if not
		move.b	SMPS_Track.PSGNoise(a0),(psg_input).l	; Set noise type
; loc_72472:
.nexttrack:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.trackloop

		rts	
; End of function StopSFX


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; Snd_FadeOut2: FadeOutSFX2: FadeOutSpecialSFX:
StopSpecialSFX:
		lea		SMPS_RAM.v_spcsfx_fm4_track(a6),a5
		tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
		bpl.s	.fadedfm			; Branch if not
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	.fadedfm			; Branch if not
		jsr		SendFMNoteOff(pc)
		lea		SMPS_RAM.v_music_fm4_track(a6),a5
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
		bpl.s	.fadedfm			; Branch if not
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; Voice pointer
		move.b	SMPS_Track.VoiceIndex(a5),d0		; Current voice
		jsr		SetVoice(pc)
; loc_724AE:
.fadedfm:
		lea		SMPS_RAM.v_spcsfx_psg3_track(a6),a5
		tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
		bpl.s	.fadedpsg			; Branch if not
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	.fadedpsg			; Return if not
		jsr		SendPSGNoteOff(pc)
		lea		SMPS_RAM.v_music_psg3_track(a6),a5
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
		bpl.s	.fadedpsg			; Return if not
		cmpi.b	#$E0,SMPS_Track.VoiceControl(a5)	; Is this a noise channel?
		bne.s	.fadedpsg			; Return if not
		move.b	SMPS_Track.PSGNoise(a5),(psg_input).l ; Set noise type
; locret_724E4:
.fadedpsg:
		rts	
; End of function StopSpecialSFX

; ===========================================================================
; ---------------------------------------------------------------------------
; Fade out music
; ---------------------------------------------------------------------------
; Sound_E0:
FadeOutMusic:
		jsr	StopSFX(pc)
		jsr	StopSpecialSFX(pc)
		move.b	#3,SMPS_RAM.v_fadeout_delay(a6)			; Set fadeout delay to 3
		move.b	#$28,SMPS_RAM.v_fadeout_counter(a6)		; Set fadeout counter
		clr.b	SMPS_RAM.v_music_dac_track.PlaybackControl(a6)	; Stop DAC track
		clr.b	SMPS_RAM.f_speedup(a6)				; Disable speed shoes tempo
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72504:
DoFadeOut:
		move.b	SMPS_RAM.v_fadeout_delay(a6),d0	; Has fadeout delay expired?
		beq.s	.continuefade		; Branch if yes
		subq.b	#1,SMPS_RAM.v_fadeout_delay(a6)
		rts	
; ===========================================================================
; loc_72510:
.continuefade:
		subq.b	#1,SMPS_RAM.v_fadeout_counter(a6)	; Update fade counter
		beq.w	StopAllSound			; Branch if fade is done
		move.b	#3,SMPS_RAM.v_fadeout_delay(a6)		; Reset fade delay
		lea		SMPS_RAM.v_music_fm_tracks(a6),a5
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7	; 6 FM tracks
; loc_72524:
.fmloop:
		tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
		bpl.s	.nextfm				; Branch if not
		addq.b	#1,SMPS_Track.Volume(a5)		; Increase volume attenuation
		bpl.s	.sendfmtl			; Branch if still positive
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		bra.s	.nextfm
; ===========================================================================
; loc_72534:
.sendfmtl:
		jsr		SendVoiceTL(pc)
; loc_72538:
.nextfm:
		adda.w	#SMPS_Track.len,a5
		dbf		d7,.fmloop

		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7	; 3 PSG tracks
; loc_72542:
.psgloop:
		tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
		bpl.s	.nextpsg			; branch if not
		addq.b	#1,SMPS_Track.Volume(a5)		; Increase volume attenuation
		cmpi.b	#$10,SMPS_Track.Volume(a5)		; Is it greater than $F?
		blo.s	.sendpsgvol			; Branch if not
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		bra.s	.nextpsg
; ===========================================================================
; loc_72558:
.sendpsgvol:
		move.b	SMPS_Track.Volume(a5),d6	; Store new volume attenuation
		jsr		SetPSGVolume(pc)
; loc_72560:
.nextpsg:
		adda.w	#SMPS_Track.len,a5
		dbf		d7,.psgloop

		rts	
; End of function DoFadeOut


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_7256A:
FMSilenceAll:
		moveq	#2,d3		; 3 FM channels for each YM2612 parts
		moveq	#$28,d0		; FM key on/off register
; loc_7256E:
.noteoffloop:
		move.b	d3,d1
		jsr	WriteFMI(pc)
		addq.b	#4,d1		; Move to YM2612 part 1
		jsr	WriteFMI(pc)
		dbf	d3,.noteoffloop

		moveq	#$40,d0		; Set TL on FM channels...
		moveq	#$7F,d1		; ... to total attenuation...
		moveq	#2,d4		; ... for all 3 channels...
; loc_72584:
.channelloop:
		moveq	#3,d3		; ... for all operators on each channel...
; loc_72586:
.channeltlloop:
		jsr	WriteFMI(pc)	; ... for part 0...
		jsr	WriteFMII(pc)	; ... and part 1.
		addq.w	#4,d0		; Next TL operator
		dbf	d3,.channeltlloop

		subi.b	#$F,d0		; Move to TL operator 1 of next channel
		dbf	d4,.channelloop

		rts	
; End of function FMSilenceAll

; ===========================================================================
; ---------------------------------------------------------------------------
; Stop music
; ---------------------------------------------------------------------------
; Sound_E4: StopSoundAndMusic:
StopAllSound:
		moveq	#$2B,d0		; Enable/disable DAC
		move.b	#$80,d1		; Enable DAC
		jsr	WriteFMI(pc)
		moveq	#$27,d0		; Timers, FM3/FM6 mode
		moveq	#0,d1		; FM3/FM6 normal mode, disable timers
		jsr	WriteFMI(pc)
		movea.l	a6,a0
		move.w	#((SMPS_RAM.v_1up_ram_copy)/4)-1,d0	; Clear $400 bytes: all variables and track data -- Sound driver fixes: Only cleared $390 before
; loc_725B6:
.clearramloop:
		clr.l	(a0)+
		dbf	d0,.clearramloop

		move.b	#$80,SMPS_RAM.v_sound_id(a6)	; set music to $80 (silence)
		jsr	FMSilenceAll(pc)
		bra.w	PSGSilenceAll

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_725CA:
InitMusicPlayback:
		movea.l	a6,a0
		; Save several values
		_move.b	SMPS_RAM.v_sndprio(a6),d1
		move.b	SMPS_RAM.f_1up_playing(a6),d2
		move.b	SMPS_RAM.f_speedup(a6),d3
		move.b	SMPS_RAM.v_fadein_counter(a6),d4
		move.w	SMPS_RAM.v_soundqueue0(a6),d5
		move.b	SMPS_RAM.v_soundqueue2(a6),d6	; Sound driver fixes: back up soundqueue2 as well.
		move.w	#((SMPS_RAM.v_1up_ram_end-SMPS_RAM.v_1up_ram)/4)-1,d0	; Clear $220 bytes: all variables and music track data
; loc_725E4:
.clearramloop:
		clr.l	(a0)+
		dbf	d0,.clearramloop

		; Restore the values saved above
		_move.b	d1,SMPS_RAM.v_sndprio(a6)
		move.b	d2,SMPS_RAM.f_1up_playing(a6)
		move.b	d3,SMPS_RAM.f_speedup(a6)
		move.b	d4,SMPS_RAM.v_fadein_counter(a6)
		move.w	d5,SMPS_RAM.v_soundqueue0(a6)
		move.b	d6,SMPS_RAM.v_soundqueue2(a6)	; Sound driver fixes: restore soundqueue2 as well.
		move.b	#$80,SMPS_RAM.v_sound_id(a6)		; set music to $80 (silence)
	; Sound driver fixes
		lea		SMPS_RAM.v_music_dac_track.VoiceControl(a6),a1
		lea		FMDACInitBytes(pc),a2
		moveq	#SMPS_MUSIC_FM_DAC_TRACK_COUNT-1,d1		; 7 DAC/FM tracks
		bsr.s	.writeloop
		lea		PSGInitBytes(pc),a2
		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d1	; 3 PSG tracks

.writeloop:
		move.b	(a2)+,(a1)		; Write track's channel byte
		lea		SMPS_Track.len(a1),a1		; Next track
		dbf		d1,.writeloop		; Loop for all DAC/FM/PSG tracks

		rts
	; Sound driver fixes end
	
; End of function InitMusicPlayback


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_7260C:
TempoWait:
		move.b	SMPS_RAM.v_main_tempo(a6),SMPS_RAM.v_main_tempo_timeout(a6)	; Reset main tempo timeout
		lea		SMPS_RAM.v_music_track_ram+SMPS_Track.DurationTimeout(a6),a0	; note timeout
		moveq	#SMPS_Track.len,d0
		moveq	#SMPS_MUSIC_TRACK_COUNT-1,d1		; 1 DAC + 6 FM + 3 PSG tracks
; loc_7261A:
.tempoloop:
		addq.b	#1,(a0)	; Delay note by 1 frame
		adda.w	d0,a0	; Advance to next track
		dbf	d1,.tempoloop

		rts	
; End of function TempoWait

; ===========================================================================
; ---------------------------------------------------------------------------
; Speed	up music
; ---------------------------------------------------------------------------
; Sound_E2:
SpeedUpMusic:
		tst.b	SMPS_RAM.f_1up_playing(a6)
		bne.s	.speedup_1up
		move.b	SMPS_RAM.v_speeduptempo(a6),SMPS_RAM.v_main_tempo(a6)
		move.b	SMPS_RAM.v_speeduptempo(a6),SMPS_RAM.v_main_tempo_timeout(a6)
		move.b	#$80,SMPS_RAM.f_speedup(a6)
		rts	
; ===========================================================================
; loc_7263E:
.speedup_1up:
		move.b	SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_speeduptempo(a6),SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_main_tempo(a6)
		move.b	SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_speeduptempo(a6),SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_main_tempo_timeout(a6)
		move.b	#$80,SMPS_RAM.v_1up_ram_copy+SMPS_RAM.f_speedup(a6)
		rts	
; ===========================================================================
; ---------------------------------------------------------------------------
; Change music back to normal speed
; ---------------------------------------------------------------------------
; Sound_E3:
SlowDownMusic:
		tst.b	SMPS_RAM.f_1up_playing(a6)
		bne.s	.slowdown_1up
		move.b	SMPS_RAM.v_tempo_mod(a6),SMPS_RAM.v_main_tempo(a6)
		move.b	SMPS_RAM.v_tempo_mod(a6),SMPS_RAM.v_main_tempo_timeout(a6)
		clr.b	SMPS_RAM.f_speedup(a6)
		rts	
; ===========================================================================
; loc_7266A:
.slowdown_1up:
		move.b	SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_tempo_mod(a6),SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_main_tempo(a6)
		move.b	SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_tempo_mod(a6),SMPS_RAM.v_1up_ram_copy+SMPS_RAM.v_main_tempo_timeout(a6)
		clr.b	SMPS_RAM.v_1up_ram_copy+SMPS_RAM.f_speedup(a6)
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_7267C:
DoFadeIn:
		tst.b	SMPS_RAM.v_fadein_delay(a6)	; Has fadein delay expired?
		beq.s	.continuefade		; Branch if yes
		subq.b	#1,SMPS_RAM.v_fadein_delay(a6)
		rts	
; ===========================================================================
; loc_72688:
.continuefade:
		tst.b	SMPS_RAM.v_fadein_counter(a6)	; Is fade done?
		beq.s	.fadedone		; Branch if yes
		subq.b	#1,SMPS_RAM.v_fadein_counter(a6)	; Update fade counter
		move.b	#2,SMPS_RAM.v_fadein_delay(a6)	; Reset fade delay
		lea	SMPS_RAM.v_music_fm_tracks(a6),a5
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7	; 6 FM tracks
; loc_7269E:
.fmloop:
		tst.b	SMPS_Track.PlaybackControl(a5) ; Is track playing?
		bpl.s	.nextfm			; Branch if not
		subq.b	#1,SMPS_Track.Volume(a5)	; Reduce volume attenuation
		jsr	SendVoiceTL(pc)
; loc_726AA:
.nextfm:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.fmloop
		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7		; 3 PSG tracks
; loc_726B4:
.psgloop:
		tst.b	SMPS_Track.PlaybackControl(a5) ; Is track playing?
		bpl.s	.nextpsg		; Branch if not
		subq.b	#1,SMPS_Track.Volume(a5)	; Reduce volume attenuation
		move.b	SMPS_Track.Volume(a5),d6	; Get value
		cmpi.b	#$10,d6			; Is it is < $10?
		blo.s	.sendpsgvol		; Branch if yes
		moveq	#$F,d6			; Limit to $F (maximum attenuation)
; loc_726C8:
.sendpsgvol:
		jsr	SetPSGVolume(pc)
; loc_726CC:
.nextpsg:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.psgloop
		rts	
; ===========================================================================
; loc_726D6:
.fadedone:
		bclr	#2,SMPS_RAM.v_music_dac_track.PlaybackControl(a6)	; Clear 'SFX overriding' bit
		clr.b	SMPS_RAM.f_fadein_flag(a6)				; Stop fadein
		rts	
; End of function DoFadeIn

; ===========================================================================
; loc_726E2:
FMNoteOn:
		btst	#1,SMPS_Track.PlaybackControl(a5)	; Is track resting?
		bne.s	.locret				; Return if so
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.locret				; Return if so
		moveq	#$28,d0				; Note on/off register
		move.b	SMPS_Track.VoiceControl(a5),d1	; Get channel bits
		ori.b	#$F0,d1				; Note on on all operators
		bra.w	WriteFMI
; ===========================================================================
; locret_726FC:
.locret:
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_726FE:
FMNoteOff:
		btst	#4,SMPS_Track.PlaybackControl(a5)	; Is 'do not attack next note' set?
		bne.s	locret_72714			; Return if yes
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	locret_72714			; Return if yes
; loc_7270A:
SendFMNoteOff:
		moveq	#$28,d0				; Note on/off register
		move.b	SMPS_Track.VoiceControl(a5),d1	; Note off to this channel
		bra.w	WriteFMI
; ===========================================================================

locret_72714:
		rts	
; End of function FMNoteOff

; ===========================================================================
; loc_72716:
WriteFMIorIIMain:
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overriden by sfx?
		bne.s	.locret						; Return if yes
		bra.w	WriteFMIorII
; ===========================================================================
; locret_72720:
.locret:
		rts     

; ||||||||||||||| S U B R O U T I N E |||||||||||||||||||||||||||||||||||||||

; sub_72722:
WriteFMIorII:
		move.b	SMPS_Track.VoiceControl(a5), d2
		subq.b	#4, d2						; Is this bound for part I or II?
		bcc.s	WriteFMIIPart				; If yes, branch
		addq.b	#4, d2						; Add in voice control bits
		add.b	d2, d0						;

; ---------------------------------------------------------------------------
WriteFMI:
		MPCM_stopZ80
		MPCM_ensureYMWriteReady
.waitLoop:
		tst.b	(ym2612_a0).l		; is FM busy?
		bmi.s	.waitLoop			; branch if yes
		move.b	d0, (ym2612_a0).l
		nop
		move.b	d1, (ym2612_d0).l
		nop
		nop
.waitLoop2:
		tst.b	(ym2612_a0).l		; is FM busy?
		bmi.s	.waitLoop2			; branch if yes
		move.b	#$2A, (ym2612_a0).l	; restore DAC output for Mega PCM
		MPCM_startZ80
		rts
; End of function WriteFMI

; ===========================================================================
; loc_7275A:
WriteFMIIPart:
		add.b	d2,d0				; Add in to destination register

; ---------------------------------------------------------------------------
WriteFMII:
		MPCM_stopZ80
		MPCM_ensureYMWriteReady
.waitLoop:
		tst.b	(ym2612_a0).l		; is FM busy?
		bmi.s	.waitLoop			; branch if yes
		move.b	d0, (ym2612_a1).l
		nop
		move.b	d1, (ym2612_d1).l
		nop
		nop
.waitLoop2:
		tst.b	(ym2612_a0).l		; is FM busy?
		bmi.s	.waitLoop2			; branch if yes
		move.b	#$2A, (ym2612_a0).l	; restore DAC output for Mega PCM
		MPCM_startZ80
		rts
; End of function WriteFMII

; ===========================================================================
; ---------------------------------------------------------------------------
; FM Note Values: b-0 to a#8
;
; Each row is an octave, starting with B and ending with A-sharp/B-flat.
; Notably, this differs from the PSG frequency table, which starts with C and
; ends with B. This is caused by 'FMSetFreq' subtracting $80 from the note
; instead of $81, meaning that the first frequency in the table ironically
; corresponds to the 'rest' note. The only way to use this frequency in a
; real note is to transpose the channel to a lower semitone.
;
; Rather than use a complete lookup table, other SMPS drivers such as
; Sonic 3's compute the octave, and only store a single octave's worth of
; notes in the table.
;
; Invalid transposition values will cause this table to be overflowed,
; resulting in garbage data being used as frequency values. In drivers that
; compute the octave instead, invalid transposition values merely cause the
; notes to wrap-around (the note below the lowest note will be the highest
; note). It's important to keep this in mind when porting buggy songs.
; ---------------------------------------------------------------------------
MakeFMFrequency function frequency,roundFloatToInteger(frequency*1024*1024*2/FM_Sample_Rate)
MakeFMFrequenciesOctave macro octave
		; Frequencies for the base octave. The first frequency is B, the last frequency is B-flat.
		irp op, 15.39, 16.35, 17.34, 18.36, 19.45, 20.64, 21.84, 23.13, 24.51, 25.98, 27.53, 29.15
			dc.w MakeFMFrequency(op)+octave*$800
		endm
	endm

; word_72790: FM_Notes:
FMFrequencies:
		MakeFMFrequenciesOctave 0
		MakeFMFrequenciesOctave 1
		MakeFMFrequenciesOctave 2
		MakeFMFrequenciesOctave 3
		MakeFMFrequenciesOctave 4
		MakeFMFrequenciesOctave 5
		MakeFMFrequenciesOctave 6
		MakeFMFrequenciesOctave 7

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72850:
PSGUpdateTrack:
		subq.b	#1,SMPS_Track.DurationTimeout(a5)	; Update note timeout
		bne.s	.notegoing
		bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack note' bit
		jsr	PSGDoNext(pc)
		jsr	PSGDoNoteOn(pc)
		bra.w	PSGDoVolFX
; ===========================================================================
; loc_72866:
.notegoing:
		jsr	NoteTimeoutUpdate(pc)
		jsr	PSGUpdateVolFX(pc)
		jsr	DoModulation(pc)
		jsr	PSGUpdateFreq(pc)	; It would be better if this were a jmp and the rts was removed
		rts
; End of function PSGUpdateTrack


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72878:
PSGDoNext:
		bclr	#1,SMPS_Track.PlaybackControl(a5)	; Clear 'track at rest' bit
		movea.l	SMPS_Track.DataPointer(a5),a4		; Get track data pointer
; loc_72880:
.noteloop:
		moveq	#0,d5
		move.b	(a4)+,d5	; Get byte from track
		cmpi.b	#$E0,d5		; Is it a coord. flag?
		blo.s	.gotnote	; Branch if not
		jsr	CoordFlag(pc)
		bra.s	.noteloop
; ===========================================================================
; loc_72890:
.gotnote:
		tst.b	d5		; Is it a note?
		bpl.s	.gotduration	; Branch if not
		jsr	PSGSetFreq(pc)
		move.b	(a4)+,d5	; Get another byte
		tst.b	d5		; Is it a duration?
		bpl.s	.gotduration	; Branch if yes
		subq.w	#1,a4		; Put byte back
		bra.w	FinishTrackUpdate
; ===========================================================================
; loc_728A4:
.gotduration:
		jsr	SetDuration(pc)
		bra.w	FinishTrackUpdate
; End of function PSGDoNext


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_728AC:
PSGSetFreq:
		subi.b	#$81,d5		; Convert to 0-based index
		bcs.s	.restpsg	; If $80, put track at rest
		add.b	SMPS_Track.Transpose(a5),d5 ; Add in channel transposition
		andi.w	#$7F,d5		; Clear high byte and sign bit
		lsl.w	#1,d5
		lea		PSGFrequencies(pc),a0
		move.w	(a0,d5.w),SMPS_Track.Freq(a5)	; Set new frequency
		bra.w	FinishTrackUpdate
; ===========================================================================
; loc_728CA:
.restpsg:
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		move.w	#-1,SMPS_Track.Freq(a5)		; Invalidate note frequency
		jsr		FinishTrackUpdate(pc)
		bra.w	PSGNoteOff
; End of function PSGSetFreq


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_728DC:
PSGDoNoteOn:
		move.w	SMPS_Track.Freq(a5),d6	; Get note frequency
		bmi.s	PSGSetRest		; If invalid, branch
		; Bugfix: Fix Modulation Frequency bug on note-on - AURORA☆FIELDS
		btst	#3,(a5)			; check if modulation is active
		beq.s	PSGUpdateFreq		; if not, branch
		add.w	SMPS_Track.ModulationVal(a5),d6		; add modulation frequency to d6		
		; Bugfix end		
; End of function PSGDoNoteOn


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_728E2:
PSGUpdateFreq:
		move.b	SMPS_Track.Detune(a5),d0	; Get detune value
		ext.w	d0
		add.w	d0,d6				; Add to frequency
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.locret				; Return if yes
		btst	#1,SMPS_Track.PlaybackControl(a5)	; Is track at rest?
		bne.s	.locret				; Return if yes
		move.b	SMPS_Track.VoiceControl(a5),d0 ; Get channel bits
		cmpi.b	#$E0,d0		; Is it a noise channel?
		bne.s	.notnoise	; Branch if not
		move.b	#$C0,d0		; Use PSG 3 channel bits
; loc_72904:
.notnoise:
		move.w	d6,d1
		andi.b	#$F,d1		; Low nibble of frequency
		or.b	d1,d0		; Latch tone data to channel
		lsr.w	#4,d6		; Get upper 6 bits of frequency
		andi.b	#$3F,d6		; Send to latched channel
		move.b	d0,(psg_input).l
		move.b	d6,(psg_input).l
; locret_7291E:
.locret:
		rts	
; End of function PSGUpdateFreq

; ===========================================================================
; loc_72920:
PSGSetRest:
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72926:
PSGUpdateVolFX:
		tst.b	SMPS_Track.VoiceIndex(a5)	; Test PSG tone
		beq.w	locret_7298A		; Return if it is zero
; loc_7292E:
PSGDoVolFX:	; This can actually be made a bit more efficient, see the comments for more
		move.b	SMPS_Track.Volume(a5),d6	; Get volume
		moveq	#0,d0
		move.b	SMPS_Track.VoiceIndex(a5),d0	; Get PSG tone
		beq.s	SetPSGVolume
		movea.l	(Go_PSGIndex).l,a0
		subq.w	#1,d0
		lsl.w	#2,d0
		movea.l	(a0,d0.w),a0
		move.b	SMPS_Track.VolEnvIndex(a5),d0	; Get volume envelope index		; move.b	SMPS_Track.VolEnvIndex(a5),d0
		move.b	(a0,d0.w),d0			; Volume envelope value			; addq.b	#1,SMPS_Track.VolEnvIndex(a5)
		addq.b	#1,SMPS_Track.VolEnvIndex(a5)	; Increment volume envelope index	; move.b	(a0,d0.w),d0
		btst	#7,d0				; Is volume envelope value negative?	; <-- makes this line redundant
		beq.s	.gotflutter			; Branch if not				; but you gotta make this one a bpl
		cmpi.b	#$80,d0				; Is it the terminator?			; Since this is the only check, you can take the optimisation a step further:
		beq.s	VolEnvHold			; If so, branch				; Change the previous beq (bpl) to a bmi and make it branch to VolEnvHold to make these last two lines redundant
; loc_72960:
.gotflutter:
		add.w	d0,d6		; Add volume envelope value to volume
		cmpi.b	#$10,d6		; Is volume $10 or higher?
		blo.s	SetPSGVolume	; Branch if not
		moveq	#$F,d6		; Limit to silence and fall through
; End of function PSGUpdateVolFX


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_7296A:
SetPSGVolume:
		btst	#1,SMPS_Track.PlaybackControl(a5)	; Is track at rest?
		bne.s	locret_7298A			; Return if so
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	locret_7298A			; Return if so
		btst	#4,SMPS_Track.PlaybackControl(a5)	; Is track set to not attack next note?
		bne.s	PSGCheckNoteTimeout ; Branch if yes
; loc_7297C:
PSGSendVolume:
		or.b	SMPS_Track.VoiceControl(a5),d6 ; Add in track selector bits
		addi.b	#$10,d6			; Mark it as a volume command
		move.b	d6,(psg_input).l

locret_7298A:
		rts	
; ===========================================================================
; loc_7298C: PSGCheckNoteFill:
PSGCheckNoteTimeout:
		tst.b	SMPS_Track.NoteTimeoutMaster(a5)	; Is note timeout on?
		beq.s	PSGSendVolume			; Branch if not
		tst.b	SMPS_Track.NoteTimeout(a5)		; Has note timeout expired?
		bne.s	PSGSendVolume			; Branch if not
		rts	
; End of function SetPSGVolume

; ===========================================================================
; loc_7299A: FlutterDone:
VolEnvHold:
		subq.b	#1,SMPS_Track.VolEnvIndex(a5)	; Decrement volume envelope index
		rts	

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_729A0:
PSGNoteOff:
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	locret_729B4			; Return if so
; loc_729A6:
SendPSGNoteOff:
		move.b	SMPS_Track.VoiceControl(a5),d0	; PSG channel to change
		ori.b	#$1F,d0				; Maximum volume attenuation
		move.b	d0,(psg_input).l
	; Sound driver fixes: Noise prevention. This is the same fix that S&K's driver uses:
		cmpi.b	#$DF,d0				; Are stopping PSG3?
		bne.s	locret_729B4
		move.b	#$FF,(psg_input).l		; If so, stop noise channel while we're at it
	; Sound driver fixes end

locret_729B4:
		rts	
; End of function PSGNoteOff


; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_729B6:
PSGSilenceAll:
		lea	(psg_input).l,a0
		move.b	#$9F,(a0)	; Silence PSG 1
		move.b	#$BF,(a0)	; Silence PSG 2
		move.b	#$DF,(a0)	; Silence PSG 3
		move.b	#$FF,(a0)	; Silence noise channel
		rts	
; End of function PSGSilenceAll

; ===========================================================================
; ---------------------------------------------------------------------------
; PSG Note Values: c-1 to a-6
;
; Each row is an octave, starting with C and ending with B. Sonic 3's driver
; adds another octave at the start, as well as two more notes and the end to
; complete the last octave. Notably, a-6 is changed from 223721.56Hz to
; 6991.28Hz. These changes need to be applied here in order for ports of
; songs from Sonic 3 and later to sound correct.
;
; Here is what Sonic 3's version of this table looks like:
;		MakePSGFrequencies  109.34,    109.34,    109.34,    109.34,    109.34,    109.34,    109.34,    109.34,    109.34,    110.20,    116.76,    123.73
;		MakePSGFrequencies  130.98,    138.78,    146.99,    155.79,    165.22,    174.78,    185.19,    196.24,    207.91,    220.63,    233.52,    247.47
;		MakePSGFrequencies  261.96,    277.56,    293.59,    311.58,    329.97,    349.56,    370.39,    392.49,    415.83,    440.39,    468.03,    494.95
;		MakePSGFrequencies  522.71,    556.51,    588.73,    621.44,    661.89,    699.12,    740.79,    782.24,    828.59,    880.79,    932.17,    989.91
;		MakePSGFrequencies 1045.42,   1107.52,   1177.47,   1242.89,   1316.00,   1398.25,   1491.47,   1575.50,   1669.55,   1747.82,   1864.34,   1962.46
;		MakePSGFrequencies 2071.49,   2193.34,   2330.42,   2485.78,   2601.40,   2796.51,   2943.69,   3107.23,   3290.01,   3495.64,   3608.40,   3857.25
;		MakePSGFrequencies 4142.98,   4302.32,   4660.85,   4863.50,   5084.56,   5326.69,   5887.39,   6214.47,   6580.02,   6991.28, 223721.56, 223721.56
; ---------------------------------------------------------------------------
MakePSGFrequency function frequency,min($3FF,roundFloatToInteger(PSG_Sample_Rate/(frequency*2)))
MakePSGFrequencies macro
		irp op,ALLARGS
			dc.w MakePSGFrequency(op)
		endm
	endm

; word_729CE:
PSGFrequencies:
		MakePSGFrequencies  130.98,    138.78,    146.99,    155.79,    165.22,    174.78,    185.19,    196.24,    207.91,    220.63,    233.52,    247.47
		MakePSGFrequencies  261.96,    277.56,    293.59,    311.58,    329.97,    349.56,    370.39,    392.49,    415.83,    440.39,    468.03,    494.95
		MakePSGFrequencies  522.71,    556.51,    588.73,    621.44,    661.89,    699.12,    740.79,    782.24,    828.59,    880.79,    932.17,    989.91
		MakePSGFrequencies 1045.42,   1107.52,   1177.47,   1242.89,   1316.00,   1398.25,   1491.47,   1575.50,   1669.55,   1747.82,   1864.34,   1962.46
		MakePSGFrequencies 2071.49,   2193.34,   2330.42,   2485.78,   2601.40,   2796.51,   2943.69,   3107.23,   3290.01,   3495.64,   3608.40,   3857.25
		MakePSGFrequencies 4142.98,   4302.32,   4660.85,   4863.50,   5084.56,   5326.69,   5887.39,   6214.47,   6580.02, 223721.56

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72A5A:
CoordFlag:
		subi.w	#$E0,d5
		lsl.w	#2,d5
		jmp	coordflagLookup(pc,d5.w)
; End of function CoordFlag

; ===========================================================================
; loc_72A64:
coordflagLookup:
		bra.w	cfPanningAMSFMS		; $E0
; ===========================================================================
		bra.w	cfDetune		; $E1
; ===========================================================================
		bra.w	cfSetCommunication	; $E2
; ===========================================================================
		bra.w	cfJumpReturn		; $E3
; ===========================================================================
		bra.w	cfFadeInToPrevious	; $E4
; ===========================================================================
		bra.w	cfSetTempoDivider	; $E5
; ===========================================================================
		bra.w	cfChangeFMVolume	; $E6
; ===========================================================================
		bra.w	cfHoldNote		; $E7
; ===========================================================================
		bra.w	cfNoteTimeout		; $E8
; ===========================================================================
		bra.w	cfChangeTransposition	; $E9
; ===========================================================================
		bra.w	cfSetTempo		; $EA
; ===========================================================================
		bra.w	cfSetTempoDividerAll	; $EB
; ===========================================================================
		bra.w	cfChangePSGVolume	; $EC
; ===========================================================================
		bra.w	cfClearPush		; $ED
; ===========================================================================
		bra.w	cfStopSpecialFM4	; $EE
; ===========================================================================
		bra.w	cfSetVoice		; $EF
; ===========================================================================
		bra.w	cfModulation		; $F0
; ===========================================================================
		bra.w	cfEnableModulation	; $F1
; ===========================================================================
		bra.w	cfStopTrack		; $F2
; ===========================================================================
		bra.w	cfSetPSGNoise		; $F3
; ===========================================================================
		bra.w	cfDisableModulation	; $F4
; ===========================================================================
		bra.w	cfSetPSGTone		; $F5
; ===========================================================================
		bra.w	cfJumpTo		; $F6
; ===========================================================================
		bra.w	cfRepeatAtPos		; $F7
; ===========================================================================
		bra.w	cfJumpToGosub		; $F8
; ===========================================================================
		bra.w	cfOpF9			; $F9
; ===========================================================================
; loc_72ACC:
cfPanningAMSFMS:
		move.b	(a4)+,d1		; New AMS/FMS/panning value
		tst.b	SMPS_Track.VoiceControl(a5)	; Is this a PSG track?
		bmi.s	locret_72AEA		; Return if yes
		move.b	SMPS_Track.AMSFMSPan(a5),d0	; Get current AMS/FMS/panning
		andi.b	#$37,d0			; Retain bits 0-2, 3-4 if set
		or.b	d0,d1			; Mask in new value
		move.b	d1,SMPS_Track.AMSFMSPan(a5)	; Store value
		move.b	#$B4,d0			; Command to set AMS/FMS/panning
		bra.w	WriteFMIorIIMain
; ===========================================================================

locret_72AEA:
		rts	
; ===========================================================================
; loc_72AEC: cfAlterNotes:
cfDetune:
		move.b	(a4)+,SMPS_Track.Detune(a5)	; Set detune value
		rts	
; ===========================================================================
; loc_72AF2: cfUnknown1:
cfSetCommunication:
		move.b	(a4)+,SMPS_RAM.v_communication_byte(a6)	; Set otherwise unused communication byte to parameter
		rts	
; ===========================================================================
; loc_72AF8:
cfJumpReturn:
		moveq	#0,d0
		move.b	SMPS_Track.StackPointer(a5),d0 ; Track stack pointer
		movea.l	(a5,d0.w),a4		; Set track return address
		clr.l	(a5,d0.w)		; Set 'popped' value to zero
		addq.w	#2,a4			; Skip jump target address from gosub flag
		addq.b	#4,d0			; Actually 'pop' value
		move.b	d0,SMPS_Track.StackPointer(a5) ; Set new stack pointer
		rts	
; ===========================================================================
; loc_72B14:
cfFadeInToPrevious:
		movea.l	a6,a0
		lea	SMPS_RAM.v_1up_ram_copy(a6),a1
		move.w	#((SMPS_RAM.v_1up_ram_end-SMPS_RAM.v_1up_ram)/4)-1,d0	; $220 bytes to restore: all variables and music track data
; loc_72B1E:
.restoreramloop:
		move.l	(a1)+,(a0)+
		dbf	d0,.restoreramloop

		bset	#2,SMPS_RAM.v_music_dac_track.PlaybackControl(a6)	; Set 'SFX overriding' bit
		movea.l	a5,a3
		move.b	#$28,d6
		sub.b	SMPS_RAM.v_fadein_counter(a6),d6			; If fade already in progress, this adjusts track volume accordingly
		moveq	#SMPS_MUSIC_FM_TRACK_COUNT-1,d7	; 6 FM tracks
		lea	SMPS_RAM.v_music_fm_tracks(a6),a5
; loc_72B3A:
.fmloop:
		btst	#7,SMPS_Track.PlaybackControl(a5)	; Is track playing?
		beq.s	.nextfm				; Branch if not
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		add.b	d6,SMPS_Track.Volume(a5)		; Apply current volume fade-in
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	.nextfm				; Branch if yes
		moveq	#0,d0
		move.b	SMPS_Track.VoiceIndex(a5),d0	; Get voice
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1	; Voice pointer
		jsr	SetVoice(pc)
; loc_72B5C:
.nextfm:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.fmloop

		moveq	#SMPS_MUSIC_PSG_TRACK_COUNT-1,d7	; 3 PSG tracks
; loc_72B66:
.psgloop:
		btst	#7,SMPS_Track.PlaybackControl(a5)	; Is track playing?
		beq.s	.nextpsg			; Branch if not
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		jsr	PSGNoteOff(pc)
		add.b	d6,SMPS_Track.Volume(a5)	; Apply current volume fade-in
; loc_72B78:
.nextpsg:
		adda.w	#SMPS_Track.len,a5
		dbf	d7,.psgloop
		
		movea.l	a3,a5
		move.b	#$80,SMPS_RAM.f_fadein_flag(a6)		; Trigger fade-in
		move.b	#$28,SMPS_RAM.v_fadein_counter(a6)	; Fade-in delay
		clr.b	SMPS_RAM.f_1up_playing(a6)
		; removed Z80 macro
		addq.w	#8,sp		; Tamper return value so we don't return to caller
		rts	
; ===========================================================================
; loc_72B9E:
cfSetTempoDivider:
		move.b	(a4)+,SMPS_Track.TempoDivider(a5)	; Set tempo divider on current track
		rts	
; ===========================================================================
; loc_72BA4: cfSetVolume:
cfChangeFMVolume:
		move.b	(a4)+,d0		; Get parameter
		add.b	d0,SMPS_Track.Volume(a5)	; Add to current volume
		bra.w	SendVoiceTL
; ===========================================================================
; loc_72BAE: cfPreventAttack:
cfHoldNote:
		bset	#4,SMPS_Track.PlaybackControl(a5)	; Set 'do not attack next note' bit
		rts	
; ===========================================================================
; loc_72BB4: cfNoteFill
cfNoteTimeout:
		move.b	(a4),SMPS_Track.NoteTimeout(a5)		; Note fill timeout
		move.b	(a4)+,SMPS_Track.NoteTimeoutMaster(a5)	; Note fill master
		rts	
; ===========================================================================
; loc_72BBE: cfAddKey:
cfChangeTransposition:
		move.b	(a4)+,d0		; Get parameter
		add.b	d0,SMPS_Track.Transpose(a5)	; Add to transpose value
		rts	
; ===========================================================================
; loc_72BC6:
cfSetTempo:
		move.b	(a4),SMPS_RAM.v_main_tempo(a6)		; Set main tempo
		move.b	(a4)+,SMPS_RAM.v_main_tempo_timeout(a6)	; And reset timeout (!)
		rts	
; ===========================================================================
; loc_72BD0: cfSetTempoMod:
cfSetTempoDividerAll:
		lea	SMPS_RAM.v_music_track_ram(a6),a0
		move.b	(a4)+,d0			; Get new tempo divider
		moveq	#SMPS_Track.len,d1
		moveq	#SMPS_MUSIC_TRACK_COUNT-1,d2	; 1 DAC + 6 FM + 3 PSG tracks
; loc_72BDA:
.trackloop:
		move.b	d0,SMPS_Track.TempoDivider(a0)	; Set track's tempo divider
		adda.w	d1,a0
		dbf	d2,.trackloop

		rts	
; ===========================================================================
; loc_72BE6: cfChangeVolume:
cfChangePSGVolume:
		move.b	(a4)+,d0		; Get volume change
		add.b	d0,SMPS_Track.Volume(a5)	; Apply it
		rts	
; ===========================================================================
; loc_72BEE:
cfClearPush:
		clr.b	SMPS_RAM.f_push_playing(a6)	; Allow push sound to be played once more
		rts	
; ===========================================================================
; loc_72BF4:
cfStopSpecialFM4:
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack next note' bit
		jsr		FMNoteOff(pc)
		tst.b	SMPS_RAM.v_sfx_fm4_track.PlaybackControl(a6) ; Is SFX using FM4?
		bmi.s	.locexit			; Branch if yes
		movea.l	a5,a3
		lea		SMPS_RAM.v_music_fm4_track(a6),a5
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; Voice pointer
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX is overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		move.b	SMPS_Track.VoiceIndex(a5),d0		; Current voice
		jsr	SetVoice(pc)
		movea.l	a3,a5
; loc_72C22:
.locexit:
		addq.w	#8,sp		; Tamper with return value so we don't return to caller
		rts	
; ===========================================================================
; loc_72C26:
cfSetVoice:
		moveq	#0,d0
		move.b	(a4)+,d0		; Get new voice
		move.b	d0,SMPS_Track.VoiceIndex(a5)	; Store it
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding this track?
		bne.w	locret_72CAA		; Return if yes
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1	; Music voice pointer
		tst.b	SMPS_RAM.f_voice_selector(a6)	; Are we updating a music track?
		beq.s	SetVoice		; If yes, branch
		movea.l	SMPS_Track.VoicePtr(a5),a1	; SFX track voice pointer
		tst.b	SMPS_RAM.f_voice_selector(a6)	; Are we updating a SFX track?
		bmi.s	SetVoice		; If yes, branch
		movea.l	SMPS_RAM.v_special_voice_ptr(a6),a1 ; Special SFX voice pointer

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72C4E:
SetVoice:
		subq.w	#1,d0
		bmi.s	.havevoiceptr
		move.w	#25,d1
; loc_72C56:
.voicemultiply:
		adda.w	d1,a1
		dbf	d0,.voicemultiply
; loc_72C5C:
.havevoiceptr:
		move.b	(a1)+,d1		; feedback/algorithm
		move.b	d1,SMPS_Track.FeedbackAlgo(a5) ; Save it to track RAM
		move.b	d1,d4
		move.b	#$B0,d0			; Command to write feedback/algorithm
		jsr	WriteFMIorII(pc)
		lea	FMInstrumentOperatorTable(pc),a2
		moveq	#(FMInstrumentOperatorTable_End-FMInstrumentOperatorTable)-1,d3		; Don't want to send TL yet
; loc_72C72:
.sendvoiceloop:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		jsr	WriteFMIorII(pc)
		dbf	d3,.sendvoiceloop

		moveq	#(FMInstrumentTLTable_End-FMInstrumentTLTable)-1,d5
		andi.w	#7,d4			; Get algorithm
		move.b	FMSlotMask(pc,d4.w),d4	; Get slot mask for algorithm
		move.b	SMPS_Track.Volume(a5),d3	; Track volume attenuation
; loc_72C8C:
.sendtlloop:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		lsr.b	#1,d4		; Is bit set for this operator in the mask?
		bcc.s	.sendtl		; Branch if not
		add.b	d3,d1		; Include additional attenuation
; loc_72C96:
.sendtl:
		jsr	WriteFMIorII(pc)
		dbf	d5,.sendtlloop
		
		move.b	#$B4,d0			; Register for AMS/FMS/Panning
		move.b	SMPS_Track.AMSFMSPan(a5),d1	; Value to send
		jsr	WriteFMIorII(pc) 	; (It would be better if this were a jmp)

locret_72CAA:
		rts	
; End of function SetVoice

; ===========================================================================
; byte_72CAC:
FMSlotMask:	dc.b 8,	8, 8, 8, $A, $E, $E, $F

; ||||||||||||||| S U B	R O U T	I N E |||||||||||||||||||||||||||||||||||||||

; sub_72CB4:
SendVoiceTL:
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is SFX overriding?
		bne.s	.locret				; Return if so
		moveq	#0,d0
		move.b	SMPS_Track.VoiceIndex(a5),d0	; Current voice
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1	; Voice pointer
		tst.b	SMPS_RAM.f_voice_selector(a6)
		beq.s	.gotvoiceptr
		movea.l	SMPS_Track.VoicePtr(a5),a1	; Sound driver fixes: upload the correct voice instead of (a6)
		tst.b	SMPS_RAM.f_voice_selector(a6)
		bmi.s	.gotvoiceptr
		movea.l	SMPS_RAM.v_special_voice_ptr(a6),a1
; loc_72CD8:
.gotvoiceptr:
		subq.w	#1,d0
		bmi.s	.gotvoice
		move.w	#25,d1
; loc_72CE0:
.voicemultiply:
		adda.w	d1,a1
		dbf	d0,.voicemultiply
; loc_72CE6:
.gotvoice:
		adda.w	#21,a1				; Want TL
		lea	FMInstrumentTLTable(pc),a2
		move.b	SMPS_Track.FeedbackAlgo(a5),d0	; Get feedback/algorithm
		andi.w	#7,d0				; Want only algorithm
		move.b	FMSlotMask(pc,d0.w),d4		; Get slot mask
		move.b	SMPS_Track.Volume(a5),d3		; Get track volume attenuation
		bmi.s	.locret				; If negative, stop
		moveq	#(FMInstrumentTLTable_End-FMInstrumentTLTable)-1,d5
; loc_72D02:
.sendtlloop:
		move.b	(a2)+,d0
		move.b	(a1)+,d1
		lsr.b	#1,d4		; Is bit set for this operator in the mask?
		bcc.s	.senttl		; Branch if not
		add.b	d3,d1		; Include additional attenuation
		bcs.s	.senttl		; Branch on overflow
		jsr	WriteFMIorII(pc)
; loc_72D12:
.senttl:
		dbf	d5,.sendtlloop
; locret_72D16:
.locret:
		rts	
; End of function SendVoiceTL

; ===========================================================================
; byte_72D18:
FMInstrumentOperatorTable:
		dc.b  $30		; Detune/multiple operator 1
		dc.b  $38		; Detune/multiple operator 3
		dc.b  $34		; Detune/multiple operator 2
		dc.b  $3C		; Detune/multiple operator 4
		dc.b  $50		; Rate scalling/attack rate operator 1
		dc.b  $58		; Rate scalling/attack rate operator 3
		dc.b  $54		; Rate scalling/attack rate operator 2
		dc.b  $5C		; Rate scalling/attack rate operator 4
		dc.b  $60		; Amplitude modulation/first decay rate operator 1
		dc.b  $68		; Amplitude modulation/first decay rate operator 3
		dc.b  $64		; Amplitude modulation/first decay rate operator 2
		dc.b  $6C		; Amplitude modulation/first decay rate operator 4
		dc.b  $70		; Secondary decay rate operator 1
		dc.b  $78		; Secondary decay rate operator 3
		dc.b  $74		; Secondary decay rate operator 2
		dc.b  $7C		; Secondary decay rate operator 4
		dc.b  $80		; Secondary amplitude/release rate operator 1
		dc.b  $88		; Secondary amplitude/release rate operator 3
		dc.b  $84		; Secondary amplitude/release rate operator 2
		dc.b  $8C		; Secondary amplitude/release rate operator 4
FMInstrumentOperatorTable_End
; byte_72D2C:
FMInstrumentTLTable:
		dc.b  $40		; Total level operator 1
		dc.b  $48		; Total level operator 3
		dc.b  $44		; Total level operator 2
		dc.b  $4C		; Total level operator 4
FMInstrumentTLTable_End
; ===========================================================================
; loc_72D30:
cfModulation:
		bset	#3,SMPS_Track.PlaybackControl(a5)	; Turn on modulation
		move.l	a4,SMPS_Track.ModulationPtr(a5)	; Save pointer to modulation data
		move.b	(a4)+,SMPS_Track.ModulationWait(a5)	; Modulation delay
		move.b	(a4)+,SMPS_Track.ModulationSpeed(a5)	; Modulation speed
		move.b	(a4)+,SMPS_Track.ModulationDelta(a5)	; Modulation delta
		move.b	(a4)+,d0			; Modulation steps...
		lsr.b	#1,d0				; ... divided by 2...
		move.b	d0,SMPS_Track.ModulationSteps(a5)	; ... before being stored
		clr.w	SMPS_Track.ModulationVal(a5)		; Total accumulated modulation frequency change
		rts	
; ===========================================================================
; loc_72D52:
cfEnableModulation:
		bset	#3,SMPS_Track.PlaybackControl(a5)	; Turn on modulation
		rts	
; ===========================================================================
; loc_72D58:
cfStopTrack:
		bclr	#7,SMPS_Track.PlaybackControl(a5)	; Stop track
		bclr	#4,SMPS_Track.PlaybackControl(a5)	; Clear 'do not attack next note' bit
		tst.b	SMPS_Track.VoiceControl(a5)		; Is this a PSG track?
		bmi.s	.stoppsg			; Branch if yes
		tst.b	SMPS_RAM.f_updating_dac(a6)		; Is this the DAC we are updating?
		bmi.w	.locexit			; Exit if yes
		jsr	FMNoteOff(pc)
		bra.s	.stoppedchannel
; ===========================================================================
; loc_72D74:
.stoppsg:
		jsr	PSGNoteOff(pc)
; loc_72D78:
.stoppedchannel:
		tst.b	SMPS_RAM.f_voice_selector(a6)	; Are we updating SFX?
		bpl.w	.locexit		; Exit if not
		_clr.b	SMPS_RAM.v_sndprio(a6)		; Clear priority
		moveq	#0,d0
		move.b	SMPS_Track.VoiceControl(a5),d0 ; Get voice control bits
		bmi.s	.getpsgptr		; Branch if PSG
		lea	SFX_BGMChannelRAM(pc),a0
		movea.l	a5,a3
		cmpi.b	#4,d0			; Is this FM4?
		bne.s	.getpointer		; Branch if not
		tst.b	SMPS_RAM.v_spcsfx_fm4_track.PlaybackControl(a6)	; Is special SFX playing?
		bpl.s	.getpointer		; Branch if not
		lea	SMPS_RAM.v_spcsfx_fm4_track(a6),a5
		movea.l	SMPS_RAM.v_special_voice_ptr(a6),a1	; Get voice pointer
		bra.s	.gotpointer
; ===========================================================================
; loc_72DA8:
.getpointer:
		subq.b	#2,d0		; SFX can only use FM3 and up
		lsl.b	#2,d0
		movea.l	(a0,d0.w),a5
		tst.b	SMPS_Track.PlaybackControl(a5)	; Is track playing?
		bpl.s	.novoiceupd			; Branch if not
		movea.l	SMPS_RAM.v_voice_ptr(a6),a1		; Get voice pointer
; loc_72DB8:
.gotpointer:
		bclr	#2,SMPS_Track.PlaybackControl(a5)	; Clear 'SFX overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a5)	; Set 'track at rest' bit
		move.b	SMPS_Track.VoiceIndex(a5),d0		; Current voice
		jsr	SetVoice(pc)
; loc_72DC8:
.novoiceupd:
		movea.l	a3,a5
		bra.s	.locexit
; ===========================================================================
; loc_72DCC:
.getpsgptr:
		lea	SMPS_RAM.v_spcsfx_psg3_track(a6),a0
		tst.b	SMPS_Track.PlaybackControl(a0)	; Is track playing?
		bpl.s	.getchannelptr	; Branch if not
		cmpi.b	#$E0,d0		; Is it the noise channel?
		beq.s	.gotchannelptr	; Branch if yes
		cmpi.b	#$C0,d0		; Is it PSG 3?
		beq.s	.gotchannelptr	; Branch if yes
; loc_72DE0:
.getchannelptr:
		lea	SFX_BGMChannelRAM(pc),a0
		lsr.b	#3,d0
		movea.l	(a0,d0.w),a0
; loc_72DEA:
.gotchannelptr:
		bclr	#2,SMPS_Track.PlaybackControl(a0)	; Clear 'SFX overriding' bit
		bset	#1,SMPS_Track.PlaybackControl(a0)	; Set 'track at rest' bit
		cmpi.b	#$E0,SMPS_Track.VoiceControl(a0)	; Is this a noise pointer?
		bne.s	.locexit			; Branch if not
		move.b	SMPS_Track.PSGNoise(a0),(psg_input).l ; Set noise tone
; loc_72E02:
.locexit:
		addq.w	#8,sp		; Tamper with return value so we don't go back to caller
		rts	
; ===========================================================================
; loc_72E06:
cfSetPSGNoise:
		move.b	#$E0,SMPS_Track.VoiceControl(a5)	; Turn channel into noise channel
		move.b	(a4)+,SMPS_Track.PSGNoise(a5)		; Save noise tone
		btst	#2,SMPS_Track.PlaybackControl(a5)	; Is track being overridden?
		bne.s	.locret				; Return if yes
		move.b	-1(a4),(psg_input).l		; Set tone
; locret_72E1E:
.locret:
		rts	
; ===========================================================================
; loc_72E20:
cfDisableModulation:
		bclr	#3,SMPS_Track.PlaybackControl(a5)	; Disable modulation
		rts	
; ===========================================================================
; loc_72E26:
cfSetPSGTone:
		move.b	(a4)+,SMPS_Track.VoiceIndex(a5)	; Set current PSG tone
		rts	
; ===========================================================================
; loc_72E2C:
cfJumpTo:
		move.b	(a4)+,d0	; High byte of offset
		lsl.w	#8,d0		; Shift it into place
		move.b	(a4)+,d0	; Low byte of offset
		adda.w	d0,a4		; Add to current position
		subq.w	#1,a4		; Put back one byte
		rts	
; ===========================================================================
; loc_72E38:
cfRepeatAtPos:
		moveq	#0,d0
		move.b	(a4)+,d0			; Loop index
		move.b	(a4)+,d1			; Repeat count
		tst.b	SMPS_Track.LoopCounters(a5,d0.w)	; Has this loop already started?
		bne.s	.loopexists			; Branch if yes
		move.b	d1,SMPS_Track.LoopCounters(a5,d0.w)	; Initialize repeat count
; loc_72E48:
.loopexists:
		subq.b	#1,SMPS_Track.LoopCounters(a5,d0.w)	; Decrease loop's repeat count
		bne.s	cfJumpTo			; If nonzero, branch to target
		addq.w	#2,a4				; Skip target address
		rts	
; ===========================================================================
; loc_72E52:
cfJumpToGosub:
		moveq	#0,d0
		move.b	SMPS_Track.StackPointer(a5),d0	; Current stack pointer
		subq.b	#4,d0				; Add space for another target
		move.l	a4,(a5,d0.w)			; Put in current address (*before* target for jump!)
		move.b	d0,SMPS_Track.StackPointer(a5)	; Store new stack pointer
		bra.s	cfJumpTo
; ===========================================================================
; loc_72E64:
cfOpF9:
		move.b	#$88,d0		; D1L/RR of Operator 3
		move.b	#$F,d1		; Loaded with fixed value (max RR, 1TL)
		jsr	WriteFMI(pc)
		move.b	#$8C,d0		; D1L/RR of Operator 4
		move.b	#$F,d1		; Loaded with fixed value (max RR, 1TL)
		bra.w	WriteFMI
; ===========================================================================

; Removed DAC DRIVER

; ---------------------------------------------------------------------------
; SMPS2ASM - A collection of macros that make SMPS's bytecode human-readable.
; ---------------------------------------------------------------------------
SonicDriverVer = 1 ; Tell SMPS2ASM that we're using Sonic 1's driver.
		include "sound/_smps2asm_inc.asm"

; ---------------------------------------------------------------------------
; Music data
; ---------------------------------------------------------------------------
Music01:	include	"sound/music/Mus01 - GHZ.asm"
		even
Music02:	include	"sound/music/Mus02 - LZ.asm"
		even
Music03:	include	"sound/music/Mus03 - MZ.asm"
		even
Music04:	include	"sound/music/Mus04 - SLZ.asm"
		even
Music05:	include	"sound/music/Mus05 - SYZ.asm"
		even
Music06:	include	"sound/music/Mus06 - SBZ.asm"
		even
Music07:	include	"sound/music/Mus07 - Invincibility.asm"
		even
Music08:	include	"sound/music/Mus08 - Extra Life.asm"
		even
Music09:	include	"sound/music/Mus09 - Special Stage.asm"
		even
Music0A:	include	"sound/music/Mus0A - Title Screen.asm"
		even
Music0B:	include	"sound/music/Mus0B - Ending.asm"
		even
Music0C:	include	"sound/music/Mus0C - Boss.asm"
		even
Music0D:	include	"sound/music/Mus0D - FZ.asm"
		even
Music0E:	include	"sound/music/Mus0E - Sonic Got Through.asm"
		even
Music0F:	include	"sound/music/Mus0F - Game Over.asm"
		even
Music10:	include	"sound/music/Mus10 - Continue Screen.asm"
		even
Music11:	include	"sound/music/Mus11 - Credits.asm"
		even
Music12:	include	"sound/music/Mus12 - Drowning.asm"
		even
Music13:	include	"sound/music/Mus13 - Get Emerald.asm"
		even

; ---------------------------------------------------------------------------
; Sound	effect pointers
; ---------------------------------------------------------------------------
SoundIndex:
ptr_sndA0:	dc.l SoundA0
ptr_sndA1:	dc.l SoundA1
ptr_sndA2:	dc.l SoundA2
ptr_sndA3:	dc.l SoundA3
ptr_sndA4:	dc.l SoundA4
ptr_sndA5:	dc.l SoundA5
ptr_sndA6:	dc.l SoundA6
ptr_sndA7:	dc.l SoundA7
ptr_sndA8:	dc.l SoundA8
ptr_sndA9:	dc.l SoundA9
ptr_sndAA:	dc.l SoundAA
ptr_sndAB:	dc.l SoundAB
ptr_sndAC:	dc.l SoundAC
ptr_sndAD:	dc.l SoundAD
ptr_sndAE:	dc.l SoundAE
ptr_sndAF:	dc.l SoundAF
ptr_sndB0:	dc.l SoundB0
ptr_sndB1:	dc.l SoundB1
ptr_sndB2:	dc.l SoundB2
ptr_sndB3:	dc.l SoundB3
ptr_sndB4:	dc.l SoundB4
ptr_sndB5:	dc.l SoundB5
ptr_sndB6:	dc.l SoundB6
ptr_sndB7:	dc.l SoundB7
ptr_sndB8:	dc.l SoundB8
ptr_sndB9:	dc.l SoundB9
ptr_sndBA:	dc.l SoundBA
ptr_sndBB:	dc.l SoundBB
ptr_sndBC:	dc.l SoundBC
ptr_sndBD:	dc.l SoundBD
ptr_sndBE:	dc.l SoundBE
ptr_sndBF:	dc.l SoundBF
ptr_sndC0:	dc.l SoundC0
ptr_sndC1:	dc.l SoundC1
ptr_sndC2:	dc.l SoundC2
ptr_sndC3:	dc.l SoundC3
ptr_sndC4:	dc.l SoundC4
ptr_sndC5:	dc.l SoundC5
ptr_sndC6:	dc.l SoundC6
ptr_sndC7:	dc.l SoundC7
ptr_sndC8:	dc.l SoundC8
ptr_sndC9:	dc.l SoundC9
ptr_sndCA:	dc.l SoundCA
ptr_sndCB:	dc.l SoundCB
ptr_sndCC:	dc.l SoundCC
ptr_sndCD:	dc.l SoundCD
ptr_sndCE:	dc.l SoundCE
ptr_sndCF:	dc.l SoundCF
ptr_sndend

; ---------------------------------------------------------------------------
; Special sound effect pointers
; ---------------------------------------------------------------------------
SpecSoundIndex:
ptr_sndD0:	dc.l SoundD0
ptr_sndD1:	dc.l SoundD1
ptr_sndD2:	dc.l SoundD2
ptr_sndD3:	dc.l SoundD3
ptr_sndD4:	dc.l SoundD4
ptr_sndD5:	dc.l SoundD5
ptr_sndD6:	dc.l SoundD6
ptr_sndD7:	dc.l SoundD7
ptr_sndD8:	dc.l SoundD8
ptr_sndD9:	dc.l SoundD9
ptr_sndDA:	dc.l SoundDA
ptr_sndDB:	dc.l SoundDB
ptr_sndDC:	dc.l SoundDC
ptr_specend

; ---------------------------------------------------------------------------
; Sound effect data
; ---------------------------------------------------------------------------
SoundA0:	include	"sound/sfx/SndA0 - Jump.asm"
		even
SoundA1:	include	"sound/sfx/SndA1 - Lamppost.asm"
		even
SoundA2:	include	"sound/sfx/SndA2.asm"
		even
SoundA3:	include	"sound/sfx/SndA3 - Death.asm"
		even
SoundA4:	include	"sound/sfx/SndA4 - Skid.asm"
		even
SoundA5:	include	"sound/sfx/SndA5.asm"
		even
SoundA6:	include	"sound/sfx/SndA6 - Hit Spikes.asm"
		even
SoundA7:	include	"sound/sfx/SndA7 - Push Block.asm"
		even
SoundA8:	include	"sound/sfx/SndA8 - SS Goal.asm"
		even
SoundA9:	include	"sound/sfx/SndA9 - SS Item.asm"
		even
SoundAA:	include	"sound/sfx/SndAA - Splash.asm"
		even
SoundAB:	include	"sound/sfx/SndAB.asm"
		even
SoundAC:	include	"sound/sfx/SndAC - Hit Boss.asm"
		even
SoundAD:	include	"sound/sfx/SndAD - Get Bubble.asm"
		even
SoundAE:	include	"sound/sfx/SndAE - Fireball.asm"
		even
SoundAF:	include	"sound/sfx/SndAF - Shield.asm"
		even
SoundB0:	include	"sound/sfx/SndB0 - Saw.asm"
		even
SoundB1:	include	"sound/sfx/SndB1 - Electric.asm"
		even
SoundB2:	include	"sound/sfx/SndB2 - Drown Death.asm"
		even
SoundB3:	include	"sound/sfx/SndB3 - Flamethrower.asm"
		even
SoundB4:	include	"sound/sfx/SndB4 - Bumper.asm"
		even
SoundB5:	include	"sound/sfx/SndB5 - Ring.asm"
		even
SoundB6:	include	"sound/sfx/SndB6 - Spikes Move.asm"
		even
SoundB7:	include	"sound/sfx/SndB7 - Rumbling.asm"
		even
SoundB8:	include	"sound/sfx/SndB8.asm"
		even
SoundB9:	include	"sound/sfx/SndB9 - Collapse.asm"
		even
SoundBA:	include	"sound/sfx/SndBA - SS Glass.asm"
		even
SoundBB:	include	"sound/sfx/SndBB - Door.asm"
		even
SoundBC:	include	"sound/sfx/SndBC - Teleport.asm"
		even
SoundBD:	include	"sound/sfx/SndBD - ChainStomp.asm"
		even
SoundBE:	include	"sound/sfx/SndBE - Roll.asm"
		even
SoundBF:	include	"sound/sfx/SndBF - Get Continue.asm"
		even
SoundC0:	include	"sound/sfx/SndC0 - Basaran Flap.asm"
		even
SoundC1:	include	"sound/sfx/SndC1 - Break Item.asm"
		even
SoundC2:	include	"sound/sfx/SndC2 - Drown Warning.asm"
		even
SoundC3:	include	"sound/sfx/SndC3 - Giant Ring.asm"
		even
SoundC4:	include	"sound/sfx/SndC4 - Bomb.asm"
		even
SoundC5:	include	"sound/sfx/SndC5 - Cash Register.asm"
		even
SoundC6:	include	"sound/sfx/SndC6 - Ring Loss.asm"
		even
SoundC7:	include	"sound/sfx/SndC7 - Chain Rising.asm"
		even
SoundC8:	include	"sound/sfx/SndC8 - Burning.asm"
		even
SoundC9:	include	"sound/sfx/SndC9 - Hidden Bonus.asm"
		even
SoundCA:	include	"sound/sfx/SndCA - Enter SS.asm"
		even
SoundCB:	include	"sound/sfx/SndCB - Wall Smash.asm"
		even
SoundCC:	include	"sound/sfx/SndCC - Spring.asm"
		even
SoundCD:	include	"sound/sfx/SndCD - Switch.asm"
		even
SoundCE:	include	"sound/sfx/SndCE - Ring Left Speaker.asm"
		even
SoundCF:	include	"sound/sfx/SndCF - Signpost.asm"
		even

; ---------------------------------------------------------------------------
; Special sound effect data
; ---------------------------------------------------------------------------
SoundD0:	include	"sound/sfx/SndD0 - Waterfall.asm"
		even
SoundD1:	binclude	"sound/sfx/SndD1 - SpinDash.bin"		; Ported from S2 - From Caverns4/IkeyIlex
		even
SoundD2:	include	"sound/sfx/SndD2 - CDCharge.asm"
		even
SoundD3:	include	"sound/sfx/SndD3 - CDRelease.asm"
		even
SoundD4:	include	"sound/sfx/SndD4 - CDStop.asm"
		even
SoundD5:	include	"sound/sfx/SndD5 - Insta Shield.asm"
		even
SoundD6:	include	"sound/sfx/SndD6 - Fire Shield.asm"
		even
SoundD7:	include	"sound/sfx/SndD7 - Fire Attack.asm"
		even
SoundD8:	include	"sound/sfx/SndD8 - Bubble Shield.asm"
		even
SoundD9:	include	"sound/sfx/SndD9 - Bubble Attack.asm"
		even
SoundDA:	include	"sound/sfx/SndDA - Lightning Shield.asm"
		even
SoundDB:	include	"sound/sfx/SndDB - Lightning Attack.asm"
		even
SoundDC:	include	"sound/sfx/SndDC - Drop Dash.asm"
		even
