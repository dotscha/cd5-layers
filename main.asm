	include default.ini

	org $0fff
	adr $1001

	adr bas_end
  adr 2012
	byt $9e,"4109",0,0,0
bas_end = *-2

main:

obj_phases = $02
	include layers.asm

bitmap = $c000

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
	jsr init_phase_patt

beg:

	ldy #0
	jsr render2
	ldx beg+1
	inx
	cpx #object_count
	bne $$s
	ldx #0
$$s:
	stx beg+1	
	jmp beg

	
render2:
	ldx #0
$$l:
	lda phase_patt,y
	sta $02,x
	iny
	cpy #object_count
	bne $$s
	ldy #0
$$s:	inx
	cpx #object_count
	bne $$l
	;jmp render

render:
	include scene_code.asm
	include scene_data.asm

init_phase_patt:
	ldx #phase_patt_len
	lda #0
$$l1:
	sta phase_patt,x
	inx
	cpx #object_count
	bne $$l1
	
	rts
	
	tax
$$l2:
	lda phase_patt,x
	sta phase_patt+object_count/2,x
	inx
	cpx #phase_patt_len
	bne $$l2
	rts

phase_patt:
	byt 0,1,1,2,2,3,3,4
	byt 4,5,5,6,6,7,7,7
	byt 7,7,7,7,7,7,7,7
	byt 7,7,7,7,7,7,7,7
	byt 7,7,7,7,7,7,7,7
	byt 7,7,7,7,7,7,7,7
	byt 7,7,7,6,6,5,5,4
	byt 4,3,3,2,2,1,1,0
	
phase_patt_len = *-phase_patt

	
		
