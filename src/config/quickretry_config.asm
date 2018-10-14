;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; global settings                       ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

!freeram = $7FB400              ; 11 bytes required

!decrease_lives = $00           ; $00 = Unlimited lives          $01 = Standard SMW behavior.

!clear_itembox = $01            ; $00 = Items are preserved      $01 = Items are cleared. (Counterbreak feature)  Prevents bringing Items to other Levels
!clear_dragoncoins = $01        ; $00 = Dragon coinsnot reset    $01 = Clear dragon coins
!clear_parked_yoshi = $01       ; $00 = Parked Yoshi preserved   $01 = Clear parked Yoshi (Counterbreak feature)  Prevents bringing Yoshi to Overworld
!clear_rng = $00                ; $00 = Don't reset RNG          $01 = Reset RNG on level reset (using SEED variables below)

!prompt_type = $00              ; $00 = Death jingle and Popup for Retry
                                ; $01 = Only play SFX when player dies, show Popup for Retry
                                ; $02 = Only play SFX when player dies, and default to RETRY (Fastest option) (Also enables SELECT+START to exit level)
                                ; $03 = Do not show Retry prompt by default


!death_sfx = $20                ; Define SFX to play when player dies  $01-$FF: sfx number
!death_sfx_bank = $1DF9         ; Define bank to play SFX from: $1DF9 or $1DFC
!death_jingle_alt = $FF         ; Define alternate SFX when player doesn't Retry $01-$FE: custom song number, $FF = do not use this feature
!addmusick_ram_addr = $7FB000   ; Definition for Addmusic Patch. you don't need to change this in most cases

!layer3_disable = $01           ; Disable Layer 3 display upon death? $00 = no, $01 = yes

!rng_seed_B = $00
!rng_seed_C = $00
!rng_seed_D = $00
!rng_seed_E = $00

; The custom table allows you to define different Retry- Types for individual levels. 
; $00 = Use default prompt defined above
; $01 = play the death jingle when players die
; $02 = play only the sfx when players die (music won't be interrupted)
; $03 = Only play SFX and automatically retry, enable SELECT+START to retry
; $04 = Disable Retry system for this level

.custom
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; Levels 0~F
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; Levels 10~1F
db $00,$00,$00,$00,$00							; Levels 20~24
db     $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; Levels 101~10F
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; Levels 110~11F
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00	; Levels 120~12F
db $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00			; Levels 130~13B


; This describes the menu text, loaded as a stripe image.
; Header format: EHHHYXyy yyyxxxxx DRLLLLLL 11111111
;                E = End of data marker
;                HHH = Data destination => 010 : Layer 1, 011 : Layer 2, 101 : Layer 3
;                Yyyyyy = Y coordinate
;                Xxxxxx = X coordinate
;                D = Direction (0 = Horizontal, 1= Vertical)
;                R = Run length encoding
;                LLLLLL Length of data

; This is a tileset base variable. Useful if you moved your font somewhere else
!chr_base = $3800

.menudata
        db $51, $CD, $00, $09                                           ; Header for "RETRY"
        dw !chr_base+$1b
        dw !chr_base+$0e
        dw !chr_base+$1d
        dw !chr_base+$1b
        dw !chr_base+$22

        db $52, $0D, $00, $07                                           ; Header for "EXIT"
        dw !chr_base+$0e
        dw !chr_base+$21
        dw !chr_base+$12
        dw !chr_base+$1D

        db $FF                                                          ; End of data marker

.menutarget
        db $48                                                          ; Message box target size opening??
        db $00                                                          ; Message box target size closing??
.menuspeed
        db $06                                                          ; Message box speed opening??
        db $FA                                                          ; Message box speed closing??
