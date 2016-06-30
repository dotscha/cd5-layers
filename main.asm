	include default.ini

	org $0fff
	adr $1001

	adr next_line
	adr 2016
	byt $9e,"4109",0
next_line = *
	byt 0,0


bitmap = $c000

main:

	sei
	sta $ff3f

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
	ldx #4
$$l1:
	lda #$f1
	sta $0800,y
$$l2:
	lda #1
	sta $0c00,y
	iny
	bne $$l1
	inc $$l1+4
	inc $$l2+4
	dex
	bne $$l1

	ldx #$00		; init bitmap colors
il2	lda #$04		; luminance
	sta $0800,x
	lda #$57
	sta $0800+40*19,x
	lda #$11		; color
	sta $0C00,x
	lda #$00
	sta $0C00+40*19,x
	inx
	cpx #40*6
	bne il2

	ldx #39
	lda #$01
il3	sta $0AF8,x
	dex
	bpl il3

;set bitmap mode
	lda $ff06
	ora #$20
	sta $ff06
	lda $ff12
	and #%11000011
	ora #(bitmap/1024)
	sta $ff12

	lda #$01
	sta $FF15

	lda #$E0
	sta $FF13

;init
	jsr init_anim
	jsr init_irq
        cli

anim_loop:
	jsr scenario_next
	jmp anim_loop


;animation code

	include anim.asm

render:
obj_phases = $02
	include layers.asm
	include scene_code.asm
	include scene_data.asm

	org $c000
	include logo.asm

	org $e000
	include font.asm

	include !player.asm
	include music.asm

	include irq.asm
	include scroll.asm

