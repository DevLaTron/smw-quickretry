incsrc "includes/hardware_registers.asm"
incsrc "includes/rammap.asm"

!AddMusikFlag = $008075

; List of variables used by this patch

;!freeram:    Temporary store for Timer1 (Hundreds)
;!freeram+1:  Temporary store for Timer2 (Tens)
;!freeram+2:  Temporary store for Timer3 (Ones)
;!freeram+3:  Calculated result of Respawn location 1
;!freeram+4:  Calculated result of Respawn location 2
;!freeram+5:  Is respawning? (after death)
;!freeram+6:  Music that has to be reloaded after respawn
;!freeram+7:  Music sped up? (hurry up)
;!freeram+8:  Door dest1 (candidate of freeram+3, for door/pipe checkpoint)
;!freeram+9:  Door dest2 (candidate of freeram+4, for door/pipe checkpoint)
;!freeram+10: Music played right before the death jingle

; Do SA-1 ROM check and adapt variables if necessary
if read1($00FFD5) == $23
	sa1rom
	!sa1	= 1
	!dp	= $3000
	!addr	= $6000
	!bank	= $000000
	!bank8	= $00
	!7ED000 = $40D000
else 
        !sa1    = 0
        !dp     = $0000
        !addr   = $0000
        !bank   = $800000
        !bank8  = $80
        !7ED000 = $7ED000
endif

org $00A1DF
autoclean JSL InjectPromptCode                                       ; Inject prompt handling

org $0085D2
autoclean JML InjectRetryScreen                                      ; Inject split image loader for Retry screen

org $00F5B2
autoclean JSL InjectDeathSFX_pitDeath                                ; Inject Death in pit SFX

org $00F606
autoclean JML InjectDeathSFX                                         ; Inject Death SFX

org $008E5B
autoclean JML InjectStoreHurryFlag                                   ; This injection stores if music is sped up in !freeram+7

org $00A28A
autoclean JML PlayerDeathRoutine

; earlier than GeneralInit (between object & sprite)
org $05D8E6
autoclean JML InjectGeneralInitMain

org $0091A6
autoclean JML InjectGeneralInit

org $02A768
autoclean JML InjectYoshiFlagOnInit                                  ; This injection stores the Yoshi flag in !freeram+5

org $00A261
autoclean JML InjectStartSelectExit                                  ; This injection allows SELECT+START to reset level

org $05D7BD
autoclean JML InjectEntranceInitMain

org $05D7D4
autoclean JML InjectEntranceInit

; UeberASM $010B hack
ORG $05D8B7     
BRA +                                                                ;
NOP #3                                                               ; These three lines skip over the Levelnum patch, which is included in many ROMS
+                                                                    ;
REP #$30                                                             ; Reset processor bits $30 -> 16-Bit Registers: X, Y, A
LDA $0E		    
STA !UeberASMFlag|!addr                                              ; Store $0E in $010B
ASL		
CLC		
ADC $0E		  
TAY                                                                  ; Shift left, clear carry, add with carry $0E and transfer result into Y
LDA.w $E000,Y       
STA $65
LDA.w $E001,Y
STA $66                                      ; Address $65 and $66 are 24 bit pointer to layer 1 data - level and overworld
LDA.w $E600,Y
STA $68                 
LDA.w $E601,Y
STA $69     
BRA +
ORG $05D8E0
+

freecode
; Load configuration from extra file.
Config:
	incsrc config/quickretry_config.asm

InjectPromptCode:
        ; Add inject to custom retry prompt code
	CMP #$08
	BEQ .useOriginal
	CMP #$0C
	BEQ .useOriginal                                             ; We use original Code when Menu is $08 (Save?) or $0C (Continue?)
	CMP #$09
	BCS Retry                                                    ; Call Retry prompt code
	JSL $05B10C|!bank
	RTL
.useOriginal
	INC !MessageBoxTrigger|!addr
	STZ !Layer12Window
	STZ !Layer34Window 
	STZ !OBJCWWindow
	LDA #$80
	TRB !HDMAEnable|!addr
	RTL

FastRetry:
	CMP #$0E
	BEQ Retry_5
	LDX !MessageBoxExpand|!addr
	LDA.l Config_menutarget,x
	CMP !MessageBoxTimer|!addr
	BEQ Retry_sub2
	STA !MessageBoxTimer|!addr
	BRA Retry_sub

Retry:
	CMP #$0D
	BCS FastRetry
	CMP #$0A
	BNE .4

.5
;A
	LDA !OverworldPromptProcess|!addr
	PHA
	JSR .choose
	PLA
	CMP !OverworldPromptProcess|!addr
	BEQ +
	STA !OverworldPromptProcess|!addr
	INC !MessageBoxTrigger|!addr
+
	RTL

.4
;9,B
	LDX !MessageBoxExpand|!addr
	LDA !MessageBoxTimer|!addr
	CMP.l Config_menutarget,x
	BNE ++
;box complete
.sub2
	INC !MessageBoxTrigger|!addr
	LDA !MessageBoxTrigger|!addr
	CMP #$0A
	BEQ +++
	CMP #$0E
	BNE +
+++
;9
        if !layer3_disable == $01
            LDA #$01
            STA !Layer3ScrollType|!addr
            STZ !Layer3XPos
            STZ !Layer3XPos+1
            STZ !Layer3YPos
            STZ !Layer3YPos+1
        endif

	LDY #$1E
	STY !StripeImage                                             ; stripe image = save prompt
+
	AND #$03
	BEQ +
;9
	RTL
+
;B
	; terminate
	STZ !MessageBoxTrigger|!addr
	STZ !MessageBoxExpand|!addr
	STZ !Layer12Window
	STZ !Layer34Window
	STZ !OBJCWWindow
	LDA #$80
	TRB !HDMAEnable|!addr
	LDA #$02
	STA !ColorAddition
	RTL
++
;box creating
	CLC
	ADC.l Config_menuspeed,x
	STA !MessageBoxTimer|!addr
.sub
	CLC
	ADC #$80
	XBA
	REP #$10
	LDX #$016E
	LDA #$FF
-
	STA $04F0|!addr,x               ; What is this address for?
	STZ $04F1|!addr,x               ; What is this address for?
	DEX
	DEX
	BPL -
	SEP #$10
	LDA !MessageBoxTimer|!addr
	LSR
	ADC !MessageBoxTimer|!addr
	LSR
	AND #$FE
	TAX
	LDA #$80
	SEC
	SBC !MessageBoxTimer|!addr
	REP #$20
	LDY #$48
-
	CPY #$00
	BMI +
	STA $0548|!addr,y
+
	STA $0590|!addr,x
	DEY
	DEY
	DEX
	DEX
	BPL -
	SEP #$20
	LDA #$22
	STA !Layer12Window
	STA !OBJCWWindow
	LDA #$22
	STA !ColorAddition
	LDA #$80
	TSB !HDMAEnable|!addr
	RTL

.choose
	LDY #$00
	JSR .cursor
	TXA
	BEQ +

	; no is selected
	JSR GetPromptType
	CMP #$02
	BNE ++

	LDA !freeram+7
	BNE ++

	LDA.l !AddMusikFlag|!bank
	CMP #$5C
	BNE .no_amk
	if !death_jingle_alt == $FF
		BRA .van
	else
		LDA #!death_jingle_alt
		STA !SPCIO2|!addr
		BRA ++
	endif
.no_amk
	LDA #$FF
	STA !MusicBackup|!addr
.van
	LDA #$4E	; extra frames
	STA !PlayerAniTimer|!addr
	LDA.l $00F60B|!bank
	STA !SPCIO2|!addr
++
	JSL $009C13|!bank
	RTS
+
	; yes is selected
	JSR ResetLevel
	JSL $009C13|!bank
	RTS

.cursor
	INC !BlinkCursorTimer|!addr

	PHB
	LDA.b #$00|!bank8
	PHA
	PLB

	PHK
	PEA .pos-1
	PEA $9BAE
	JML $009E82|!bank
.pos
	PLB

	LDX !BlinkCursorPos|!addr
	LDA !byetudlrFrame
	AND #$90
	BNE +
	LDA !axlr0000Frame
	BPL ++
+
	LDA #$01
	STA !SPCIO3|!addr
	BRA +
++
	PLA
	PLA
	LDA !byetudlrFrame
	AND #$20
	LSR
	LSR
	LSR
	ORA !byetudlrFrame
	AND #$0C
	BEQ ++
	LDY #$06
	STY !SPCIO3|!addr
	STZ !BlinkCursorTimer|!addr
	LSR
	LSR
	TAY

	PHB
	LDA #$00|!bank8
	PHA
	PLB
	TXA
	ADC $9AC7,y
	PLB
	CMP #$00

	BPL +++
	LDA !GraphicsCompPtr
	DEC
+++
	CMP !GraphicsCompPtr
	BCC ++++
+
	LDA #$00
++++
	STA !BlinkCursorPos|!addr
++
	RTS

ResetLevel:
        ; Figure level mode for vertical/horizontal
	LDA !ScreenMode                                              ; Load Level mode (First bit flags if vertical layer 1)
	LSR                                                          ; Shift right
	BCC .hCheckHoriz                                             ; Branch if carry flag set ( Fancy way of checking first bit is set)
	LDY !PlayerYPosNext+1                                        ; Get 2. byte of player Y position
	BRA +                                                        ; Skip horizontal
.hCheckHoriz
	LDY !PlayerXPosNext+1                                        ; Get 2. byte of player X position
+
	CPY #$00                                                     ; This checks for player X or Y position from above
	BPL .hCheckPos
	LDY #$00
	BRA .hCheckDone
.hCheckPos
	CPY #$20 
	BMI .hCheckDone
	LDY #$1F             
.hCheckDone                                                          ; At this point, we loaded Y correctly

        JSR CalcEntrance                                             ; Calculate correct level entrance to jump to-
        LDA !freeram+3                                               ; Result from CalcEntrance
        STA !ExitTableLow|!addr,y                                    ; Store destination into level exit array
        LDA !freeram+4                                               ; Result from CalcEntrance
        AND #$0F   
        STA !ExitTableHigh|!addr,y                                   ; Store destination into level exit array

	LDA #$01
	STA !freeram+5      
	LDA #$00
	STA !freeram+7
	LDA #$06                                                     ; This section sets up Mario and what to do -> Enter a Pipe Flag
	STA !PlayerAnimation                                         ; Store enter a pipe flag
	STZ !PlayerAniTimer|!addr                                    ; Set Animation Timer to ZERO
	STZ !PlayerPipeAction                                        ; Enter right facing pipe => 0
	STZ !PipeTimer                                               ; Set Warp wait time to ZERO

        ; Reset items and sprites	
        LDX #$7F                                                     ; Prepare looping over 128 entries, counting down
-                                                                    ; LOOP START
	STZ !ItemMemoryTable|!addr,x                                 ; Reset item collected info in table, 3 bytes in 3 tables?
	STZ $1A78|!addr,x                                            ; TODO: Better explanation of this
	STZ $1AF8|!addr,x                                            ; 
	STZ !SpriteLoadStatus|!addr,x                                ; Set Sprite load status to 0
	DEX
	BPL -                                                        ; LOOP UP

        ; Reset timer, music, lives and other stuff
	if !clear_itembox
            STZ !PlayerItembox|!addr                                 ; Clear stored item in item box
	endif

	LDA #$1E
	STA !GreenStarBlockCoins|!addr
	; dc

        if !clear_dragoncoins
            STZ !DragonCoinsCollected|!addr                          ; Reset collected Yoshi coins (Does not update status bar)
            STZ !DragonCoinsShown|!addr                              ; Reset Yoshi coins in status bar ($01 to §04 will show, everything else = empty)
        endif

        if !clear_rng                                                ; Clear RNG generators and set them to the SEED variables if set
                PHA
                LDA !rng_seed_B                                 
                STA !RNGCalc|!addr
                LDA !rng_seed_C
                STA !RNGCalc+1|!addr
                LDA !rng_seed_D
                STA !RandomNumber|!addr
                LDA !rng_seed_E
                STA !RandomNumber+1|!addr
                PLA
        endif

	LDA.l $05D7AB|!bank
	CMP #$5C
	BNE +
	; dcsave
	REP #$20
	LDA $0D
	PHA
	LDA.l $05D7AC|!bank
	CLC
	ADC #$0011
	STA $0D
	SEP #$20
	LDA $0F
	PHA
	LDA.l $05D7AE|!bank
	STA $0F
	JSL .dcsave_init_wrapper
	PLA
	STA $0F
	REP #$20
	PLA
	STA $0D
	SEP #$20
+
	STZ !DirectCoinInit|!addr                                    ; Reset directional coin activation flag
	STZ !OnOffSwitch|!addr                                       ; Reset ON/OFF switches to ON
	STZ !DisableBonusSprite|!addr                                ; Prevent bonus game sprite from loading
	STZ !YoshiHeavenFlag|!addr                                   ; Disable Yoshi wings flag for "Flying levels" 
	STZ !SideExitEnabled|!addr                                   ; Disable side exits
	STZ !BGFastScrollActive|!addr                                ; Disable fast BG scroll sprite
	STZ !ReznorBridgeCount|!addr                                 ; Reset number of broken tiles in Reznor battle

	; mode 7 values for the boss
	; do it later
	;REP #$20
	;STZ $36
	;STZ $38
	;STZ $3A
	;STZ $3C
	;SEP #$20

        ;Set timer to values stored at start of level (in GeneralInit)
	LDA !freeram
	STA !InGameTimerHundreds|!addr                               ; Hundreds
	LDA !freeram+1  
	STA !InGameTimerTens|!addr                                   ; Tens
	LDA !freeram+2
	STA !InGameTimerOnes|!addr                                   ; Ones

	; yoshi drum
	LDA #$03
	STA !SPCIO1|!addr

        ; Check for Addmusic
	LDA.l !AddMusikFlag|!bank
	CMP #$5C
	BEQ .amk

	; non addmusic (dont need to consider sample overhead)
	LDA !MusicBackup|!addr	                                     ; after the death jingle, this value will always be $FF
	CMP !freeram+6
	BEQ .musicend
	STZ !MusicBackup|!addr
	BRA .musicend
.amk
	LDA !MusicBackup|!addr
	CMP #$FF	                                             ; death, kaizo trap, etc
	BEQ .spec
	; normal case: !MusicBackup preserved
	LDA !freeram+6
	CMP !MusicBackup|!addr
	BNE .musicend
	BRA .bypass
.spec
	LDA !SPCIO2|!addr
	CMP #$01	; death
	BEQ +
	; kaizo trap -> order reload (maybe improved, but not major)
	LDA #$00
	STA !addmusick_ram_addr
	STA !SPCIO2|!addr
+
	; death jingle
	LDA !freeram+6
	CMP !freeram+10
	BNE .musicend
.bypass
	JSR GetPromptType
	CMP #$02
	BCS .musicend
	LDA #$01
	STA !addmusick_ram_addr+1
.musicend

	STZ !SublevelCount|!addr
	if !decrease_lives
		DEC !PlayerLives|!addr     ; Decrease live counter by 1
	endif
	RTS

.dcsave_init_wrapper
	JML [$000D|!dp]

InjectRetryScreen:
        ; This injects the possibility to show the retry / exit prompt
	LDY !StripeImage                                             ; Get Stripe image loader value
	CPY #$1E                                                     ; Set to save menu value?
	BNE .useOriginal                                             ; -> Nope
	LDA !GameMode|!addr                                          ; Get Game mode value 
	CMP #$14                                                     ; Is in Level?
	BNE .useOriginal                                             ; -> Nope
	LDA.b #Config_menudata                                  
	STA $00
	LDA.b #Config_menudata>>8                                    ; This loads a full 24 Bit Address into scratch RAM?
	STA $01
	LDA.b #Config_menudata>>16
	STA $02
	JML $0085E3|!bank                                            ; We loaded the menudata into scratch ram, jump to process it
.useOriginal
	LDA $84D0,y                                                  ; Get value from Stripe loader table
	JML $0085D7|!bank                                            ; We load the original Stripe image loader value and jump to process

InjectDeathSFX:
	LDA #$90
	STA !PlayerYSpeed
.pitDeath
	LDA !freeram+7
	BNE .useOriginal
	if !decrease_lives
	    LDA !PlayerLives|!addr                                   ; Decrease live counter by 1
            BEQ .useOriginal
	endif
	JSR GetPromptType
	CMP #$02
	BCC .useOriginal
	CMP #$04
	BCS .useOriginal
	LDA #!death_sfx
	STA !death_sfx_bank|!addr
	JML $00F614|!bank
.useOriginal
	LDA !MusicBackup|!addr
	STA !freeram+10
	LDA.l $00F60B|!bank	                                     ; death jingle
	STA !SPCIO2|!addr
	JML $00F60F|!bank

InjectStoreHurryFlag:
	LDA #$FF
	STA !SPCIO0|!addr                                            ; This is the SPC700 I/O port, $FF is a value that plays hurry up sound
	LDA #$01
	STA !freeram+7                                               ; We set !freeram+7 to save that the music is sped up
	JML $008E60|!bank                                            ; Continue as before

InjectGeneralInitMain:
        ; Main initialization routine?
	PHY
	PHP
	SEP #$20

	LDA !SublevelCount|!addr                                     ; Get Level entered counter, set to 0 on level start
	BNE ++                                                       ; If not zero, load !freeram+5
	LDA #$00
	STA !freeram+5	                                             ; Zero because we don't want to trigger yoshi init & initial facing init
++
	LDA !freeram+5
	BEQ +
	if !clear_parked_yoshi == 0
            LDA !RemoveYoshiFlag|!addr                               ; do not touch if !RemoveYoshiFlag is set already (hence no effect on parked yoshi)
	    BNE +                                                    ; only for respawning(after death just in case) && not a castle level
	endif 
	STZ !CarryYoshiThruLvls|!addr                                ; Set Yoshi over levels flag to 0. No carrying Yoshi here! TODO: Config value?
+

	PLP
	PLY
	LDA #$0000
	SEP #$20
	JML $05D8EB|!bank

InjectGeneralInit:
        ; Secondary initialization routine
	LDA !SublevelCount|!addr                                     ; Get Level entered counter
	BNE +                                                        ; Branch if not first level entry (means from Overworld)
	LDA #$00
	STA !freeram+7                                               ; Set !freeram+7 to 0, "Music sped up -> no"

	LDA !InGameTimerHundreds|!addr         
	STA !freeram            
	LDA !InGameTimerTens|!addr
	STA !freeram+1
	LDA !InGameTimerOnes|!addr
	STA !freeram+2                                               ; Store Timer for level for reset
	BRA ++
+
	LDA !freeram+5
	BNE ++

        BRA .useOriginal                                             ; Return to normal behavior
++
        ; This routine resets the Mode 7 config
	REP #$20
	STZ !Mode7Angle
	STZ !Mode7XScale
	STZ !Mode7XPos
	STZ !Mode7YPos
	SEP #$20
	; Recover the freeze state
	LDA !freeram+4
	BPL .no_freeze
	LDA #$01
	STA !SpriteLock
	BRA +++
.no_freeze
	STZ !SpriteLock
+++
	; Music backup, depending on AddMusic patch
	LDA.l !AddMusikFlag|!bank
	CMP #$5C
	BEQ +
	; Not using AddMusic patch
	LDA !MusicBackup|!addr
	AND #$3F
	STA !freeram+6
	BRA .useOriginal
+
	; Using AddMusic patch
	LDA !MusicBackup|!addr
	STA !freeram+6
.useOriginal
	; Original behavior
	LDA #$00
	STA !freeram+5	                                             ; Reset this flag, it has been processed
	LDA !SublevelCount|!addr
	BNE +
	JML $0091AB|!bank
+
	JML $0091B0|!bank

InjectEntranceInitMain:
        ; Do screen adjust
        JSR ScreenIndexAdjust
        LDA !ExitTableLow|!addr,x
        STA !LoadingLevelNumber|!addr
        JML $05D7C3|!bank

InjectEntranceInit:
        ; Inject is activated by all kind of transitions (normal things like door/pipe, or the retry)
        LDA !freeram+5
        BNE .useOriginal
        LDX $95
        LDA !ScreenMode
        AND #$01
        BEQ +
        LDX $97
+
        JSR ScreenIndexAdjust
        LDA !ExitTableLow|!addr,x
        STA !freeram+8
        LDA !ExitTableHigh|!addr,x
        STA !freeram+9
.useOriginal
        LDA !UseSecondaryExit|!addr
        BEQ +
        JML $05D7D9|!bank
+
        JML $05D83B|!bank

InjectYoshiFlagOnInit:
        ; This stores the Yoshi flag in !freeram+5
	LDA !RemoveYoshiFlag|!addr                                   ; Load Yoshi reappear flag?
	ORA !freeram+5                                               ; OR Yoshi flag onto this
	BNE +
	JML $02A76D|!bank
+
	JML $02A771|!bank

InjectStartSelectExit:
        ; Allow SEL+START to reset level depending on prompt type
	JSR GetPromptType
	CMP #$03  
	BEQ +
	LDY !TranslevelNo|!addr
	LDA !OWLevelTileSettings|!addr,y
	JML $00A267|!bank
+
	JML $00A269|!bank

;------------- SUBROUTINES ----------------

PlayerDeathRoutine:
        if !decrease_lives
                LDA !PlayerLives|!addr
                BEQ .useOriginal
        endif

        LDA !PlayerAnimation                                         ; Player animation state
        CMP #$09                                                     ; $09 means player is dying
        BNE .useOriginal                                             ; Not dying, continue as normal

        LDA !PlayerAniTimer|!addr                                    ; Get player animation timer
        CMP #$41
        BNE +                                                        ; Skip first part of death animation?
        LDA #$22                                                     ; 
        STA !PlayerAniTimer|!addr                                    ; Change player animation timer
        BRA .useOriginal
+
        CMP #$38                                                     ; Skip next part of death animation?
        BNE +
        LDA #$30
        STA !PlayerAniTimer|!addr                                    ; Change player animation timer
+
        CMP #$30                                                     ; If it's down to 30, continue as normal?
        BCS .useOriginal        

        JSR GetPromptType                                            ; Get configuration of retry prompt for this level
        CMP #$03
        BCC .prompt                                                  ; Display prompt for retry/exit
        CMP #$04
        BCS .useOriginal                                             ; No retry prompt, just go on as normal
        JSR .autoyes                                                 ; Immitate having checked Retry
        JSR ResetLevel                                               ; Prepare Level reset and then continue as normal
        BRA .useOriginal        
.prompt
        LDA !IRQNMICommand|!addr                                     ; Get IRQ/NMI behavior
        CMP #$80                                                     ; Are we in Iggy/Larry battle mode?
        BEQ .fast
        LDA !byetudlrFrame                                           ; Get held buttons
        ORA !axlr0000Frame                                           ; OR buttons pressed this frame (Any button pressed?)
        BPL ++
.fast
        LDA !PlayerAniTimer|!addr                                    ; Get player animation timer
        CMP #$23
        BCC .useOriginal        
        LDA #$0C
        STA !MessageBoxTrigger|!addr                                 ; Message box trigger, "request fast retry message"?
        LDA #$22
        STA !PlayerAniTimer|!addr                                    ; Change player animation timer
        BRA +++
++
        LDA !PlayerAniTimer|!addr
        CMP #$23
        BNE .useOriginal
        LDA #$08
        STA !MessageBoxTrigger|!addr                                 ; Message box trigger, "request retry"
        DEC !PlayerAniTimer|!addr                                    ; Decrease player animation timer
+++
        JSR .settings
.useOriginal
        LDA !IRQNMICommand|!addr                                     ; Branch if not regular level
        BPL +
        JML $00A28F|!bank
+
        JML $00A295|!bank
.settings
        LDA !IRQNMICommand|!addr                                     ; Branch if not regular level
        BPL +
        STZ !IRQNMICommand|!addr                                     ; Set IRQ/NMI behavior to "regular level"
        ; Display mode for boss battles
        LDA #$15
        STA !HW_TM                                                   ; Background and object enable for Main Screen Object, BG3, BG1
        STA !HW_TMW                                                  ; Window mask designation for Main Screen Object, BG3, BG 1
        STZ !HW_TS                                                   ; Background and object disable for Sub Screen
        STZ !HW_TSW                                                  ; Window mask designation for Sub Screen
        STZ !BackgroundColor|!addr                                   ; Set background color -> BLACK
        STZ  $0702|!addr                                             ; Set background color -> BLACK
        LDA !ActiveBoss|!addr                                        ; Fetch current boss
        CMP #$04
        BNE .autoyes                                                 ; Jump if not Reznor battle
        PHX
        LDX #$09                                                     ; Iterate through extended Sprite list and remove Reznor fireballs
-
        LDA !ExtSpriteNumber|!addr,x                                 ; Extended Sprite table
        CMP #$02                                                     ; #$02 == Reznor Fireball
        BNE .notFireball
        STZ !ExtSpriteNumber|!addr,x                                 ; Remove Reznor Fireball
.notFireball
        DEX
        BPL -                                                        ; Loop
        PLX
        BRA .autoyes
+
        LDA #$15                                                     ; Display modes for normal levels
        STA !HW_TM
        STA !HW_TMW
        LDA #$02
        STA !HW_TS
        STA !HW_TSW
.autoyes
        STZ !PlayerPeaceSign|!addr                                   ; Reset player peace image timer
        STZ !EndLevelTimer|!addr                                     ; Set End level timer to zero
        STZ !ColorFadeDir|!addr                                      ; Color fade to darker
        STZ !ColorFadeTimer|!addr                                    ; Set fade timer control to zero
        STZ !ShowPeaceSign|!addr                                     ; Don't show peace image, don't handle fade-out ellipse.
        RTS

ScreenIndexAdjust:
        ; Subroutine that adjusts screen index? TODO: What is this?
        ; Returns value in X ?
        CPX #$00
        BPL .positive
        LDX #$00
        BRA .ok
.positive
        CPX #$20
        BMI .ok
        LDX #$1F
.ok
        RTS

CalcEntrance:
        ; Subroutine that calculates correct Re- Entry point in level
        ; Retruns entries in !freeram+3 and !freeram+4
        PHX
        LDA !TranslevelNo|!addr
        CMP #$25
        BCC +
        CLC
        ADC #$DC
+
        STA !freeram+3
        LDA #$00
        ADC #$00
        STA !freeram+4
        LDX !TranslevelNo|!addr
        LDA !OWLevelTileSettings|!addr,x
        AND #$40
        BNE +
        LDA !MidwayFlag|!addr
        BEQ ++
+
        LDA !freeram+4
        ORA #$0C
        STA !freeram+4
        BRA +++
++
        ; only for the first entrance (both mmp and this)
        LDA !freeram+4
        ORA #$04
        STA !freeram+4
+++
        PLX
        RTS

GetPromptType:
        ; Subroutine that returns which prompt to use in this level, none, default or from custom table
        ; Returns Prompt Type in A
        PHX
        LDX !TranslevelNo|!addr                                      ; Fetch Translevel Number
        BNE +
        LDA #$04          
        PLX
        RTS                                                          ; Return PromptType 4 (Disabled)
+
        LDA.l Config_custom,x                                        ; Fetch custom prompt from table
        CMP #$01          
        BCS .not_default
        LDA.b #(!prompt_type+1)
.not_default
        PLX
        RTS                                                          ; Return Prompt Type (Default or custom as per table)

;------------- MISC STUFF ----------------
org $00D0D8                                                          ; This injection disables live deduction conditionally
if !decrease_lives
        DEC !PlayerLives|!addr
else
        NOP #3
endif

; This is some weird stuff displaying or not displaying messages... why would you do this???
if read1(!AddMusikFlag) != $5C
	print ""
	print "Messages:"
endif

if read1(!AddMusikFlag) != $5C
	print "- You are not using AddmusicK: the variable 'death_jingle_alt' will be set to 'Mario Died (SFX)'."
endif
