	include default.ini

	org $0fff
	adr $1001

	adr next_line
	adr 2016
	byt $9e,"4109",0
next_line = *
	byt 0,0

BOTI  = 1
P4EMU = 2

THREED = 1
MC_LOGO = 1
LOGO_FORMAT = BOTI

bitmap = $c000
cmatrix = $f800
bg_col = $00

main:

	sei
	sta $ff3f

	lda #$F7
	cmp $FF1D
	bne *-3

	lda #$08
	sta $ff14

	lda #$0B
	sta $FF06

;clean bitmap
;	ldx #32
;	lda #0
;	tay
;$l:	sta bitmap,y
;	iny
;	bne $l
;	inc $l+2
;	dex
;	bne $l

;set colors
	ldx #3
$$l1:
	lda #(bg_col & $f0) + (bg_col >> 4)
	sta $0800,y
$$l2:
	lda #(bg_col & $0f) * $11
	sta $0c00,y
	iny
	bne $$l1
	inc $$l1+4
	inc $$l2+4
	dex
	bne $$l1

	ldx #120
il2	lda initial_text-1,x
	sta $0EF8-1,x
	lda initial_text-1+120,x
	sta $0EF8-1+120,x
	;
	lda #$00
	sta $0AF8-1,x
	sta $0AF8-1+120,x
	;
	dex
	bne il2

;	ldx #$00		; init bitmap colors
;il2	lda #$04		; luminance
;	sta $0800,x
;	lda #$57
;	sta $0800+40*19,x
;	lda #$11		; color
;	sta $0C00,x
;	lda #$00
;	sta $0C00+40*19,x
;	inx
;	cpx #40*6
;	bne il2

;	ldx #39
;il3	lda #$01
;	sta $0AF8,x
;	dex
;	bpl il3

;set bitmap mode
	;lda $ff06
	;ora #$20
	;sta $ff06
	lda $ff12
	and #%11000011
	ora #(bitmap/1024)
	sta $ff12

	lda #bg_col
	sta $FF15

	lda #hi(cmatrix)&$fc
	sta $FF13

;init
	lda #bg_col
	sta $FF19
	if MC_LOGO
	sta $ff15
	sta $ff16
	endif

	jsr init_anim
	jsr init_irq
	;
	ldx #$FF	; pal
	;
	lda $FF07
	and #$40
	beq *+4
	;
	ldx #$F7	; ntsc
	cpx $FF1D
	bne *-3
	;
	;
	lda #$3B
	sta $FF06
	;
        cli

anim_loop:
	jsr scenario_next

	; Query keyboard for "Space"
	lda #$7F
        sta $FD30
        sta $FF08
        lda $FF08
        and #$10
        bne anim_loop
        ;
        lda $0500 ; space is pressed, exit gracefully
        cmp #$EA
        beq *+5
        jmp $FFF6
	lda #0
	sta $ff06
	sta $ff11
	sta $ff19
        jmp $0500





render:
obj_phases = $02
	include layers.asm
	include scene_code.asm
	include scene_data.asm

	include irq.asm
	include !player.asm
	include music.asm

	if THREED
	include texture2.asm
texture3:
	include texture_sides.asm
	endif

	org bitmap

	switch LOGO_FORMAT
	case P4EMU
	binclude logo.prg,$8000-$fff,6*320
	case BOTI
	binclude logo.prg,2+2048,6*320
	endcase

	org bitmap+320*18

	switch LOGO_FORMAT
	case P4EMU
logo_lum:
	binclude logo.prg,$7800-$fff,6*40
logo_col:
	binclude logo.prg,$7c00-$fff,6*40

	if MC_LOGO
logo_ff15:
	binclude logo.prg,$7bff-$fff,1
logo_ff16:
	binclude logo.prg,$7bfe-$fff,1
	endif

	case BOTI
logo_lum:
	binclude logo.prg,2,6*40
logo_col:
	binclude logo.prg,2+1024,6*40

	if MC_LOGO
logo_ff15:
	binclude logo.prg,1025,1
logo_ff16:
	binclude logo.prg,1024,1
	endif

	endcase


;animation code
	include anim.asm

	if THREED
	include coord_map.asm
	endif

	if THREED
texture:
	include texture_thetra.asm
	endif

	include scroll.asm

	org cmatrix
	include font.asm

