	include default.ini

	org $0fff
	adr $1001

	adr next_line
	adr 2016
	byt $9e,"4109",0
next_line = *
	byt 0,0


THREED = 1

bitmap = $c000
cmatrix = $f800

main:

	sei
	sta $ff3f
	
	lda #$F7
	cmp $FF1D
	bne *-3
	
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
	lda #$00
	sta $0800,y
$$l2:
	lda #$11
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
	lda #$01
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

	lda #$01
	sta $FF15

	lda #hi(cmatrix)&$fc
	sta $FF13

;init
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
	lda #$01
	sta $FF19
	;
	lda #$3B
	sta $FF06
	;
        cli

anim_loop:
	jsr scenario_next
	jmp anim_loop


render:
obj_phases = $02
	include layers.asm
	include scene_code.asm
	include scene_data.asm

	include irq.asm
	include !player.asm
	include music.asm

	org bitmap
	include logo.asm

;animation code
	include anim.asm

	if THREED
	include coord_map.asm
	endif

	if THREED
	;org bitmap+5620
	;align 8
	;include texture_side.asm
	;include texture_sides.asm
	include texture_thetra.asm
	;include texture_cube.asm
	endif
	
	include scroll.asm

	org cmatrix
	include font.asm

