init_anim:

	jmp init_phase_patt

render_anim:

$$beg:

	ldy #0
	jsr render2
	ldx $$beg+1
	inx
	cpx #object_count
	bne $$s
	ldx #0
$$s:
	stx $$beg+1
	rts

render2:
	ldx #0
$$l:
	lda phase_patt,y
	sta obj_phases,x
	iny
	cpy #object_count
	bne $$s
	ldy #0
$$s:	inx
	cpx #object_count
	bne $$l
	jmp render

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

	byt [128]0


