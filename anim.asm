sc_init	macro a
	lda #lo(a)
	sta scenario_read+1
	lda #hi(a)
	sta scenario_read+2
	endm

sc_once	macro a
	byt 1
	adr a
	endm

sc_rept	macro n,a
c	set n
	while c>255
	byt 255
	adr a
c	set c-255
	endm
	byt c
	adr a
	endm

scenario_read:
	lda $ffff
	inc scenario_read+1
	bne *+5
	inc scenario_read+2
	rts

scenario_next:
	lda #0
	beq $$next_loop
	dec scenario_next+1
$$jmp:
	jmp $ffff
$$next_loop:
	jsr scenario_read
	sta scenario_next+1
	jsr scenario_read
	sta $$jmp+1
	jsr scenario_read
	sta $$jmp+2
	jmp scenario_next


anim_scenario:
	sc_rept 1000,render_anim
	sc_once init_sc

init_anim:

	jsr init_phase_patt
init_sc:
	sc_init anim_scenario
	rts

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
	byt 7,7,7,7,7,7,7,7
	byt 7,7,7,7,7,7,7,7
	byt 7,7,7,6,6,5,5,4
	byt 4,3,3,2,2,1,1,0

phase_patt_len = *-phase_patt

	byt [128]0


