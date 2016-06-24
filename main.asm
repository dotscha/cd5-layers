	include default.ini

	org $0fff
	adr $1001

	adr bas_end
  adr 2012
	byt $9e,"4109",0,0,0
bas_end = *-2


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

;set bitmap mode
	lda $ff06
	ora #$20
	sta $ff06
	lda $ff12
	and #%11000011
	ora #(bitmap/1024)
    sta $ff12

;init
	jsr init_anim

anim_loop:
	jsr render_anim
	jmp anim_loop


;animation code

	include anim.asm

render:
obj_phases = $02
	include layers.asm
	include scene_code.asm
	include scene_data.asm

