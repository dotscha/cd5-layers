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
	beq +
	dec scenario_next+1
-	jmp $ffff
+	jsr scenario_read
	sta scenario_next+1
	jsr scenario_read
	sta - +1
	jsr scenario_read
	sta - +2
	jmp scenario_next

;-------------------------------------------------

	include obj_coords.asm

anim_scenario:
	sc_once zero_out
	sc_rept 12*8,nodes_in
	sc_rept 32,render
	sc_rept 7,fade_out
	sc_once init_phase1
	sc_rept 8,phase1
	sc_rept 64,render
	sc_rept 8,phase1
	sc_rept 128,render
	sc_rept 8,phase1
	sc_once bump3
	sc_rept 2*(LATI1+16),lati_rot
	sc_once bump1
	sc_rept LONG1+16,longi_rot
	sc_once bump2
	sc_rept LONG1+16,longi_rot
	sc_once bump1
	sc_rept LONG1+16,longi_rot
	sc_rept 7,fade_out
	sc_rept 400,phase2
	sc_rept 7,fade_out
	sc_once init_sc


init_anim:

	jsr init_phase_patt
init_sc:
	sc_init anim_scenario
	lda #0
	sta nodes_in+1
	sta nodes_in+3
	rts

zero_out:
	ldx #0
	txa
-	sta obj_phases,x
	inx
	cpx #object_count
	bne -
	jmp render

nodes_in:
	lda #0
	ldy #0
	ldx node_triags+0,y
	sta obj_phases,x
	ldx node_triags+1,y
	sta obj_phases,x
	ldx node_triags+2,y
	sta obj_phases,x
	ldx node_triags+3,y
	sta obj_phases,x
	ldx node_triags+4,y
	sta obj_phases,x

	ldx nodes_in+1
	inx
	cpx #8
	bne +
	ldx #0
	lda nodes_in+3
	clc
	adc #5
	sta nodes_in+3
+	stx nodes_in+1
	jmp render

node_triags:
	include node_triangs.asm

init_phase1:
	lda #0
	sta phase1+1
	rts

phase1:

	ldy #0
	inc *-1
	ldx #0
-	lda bumptab_mid-8,y

	sta obj_phases+0,x
	sta obj_phases+1,x
	sta obj_phases+2,x

	lda bumptab_mid-16,y

	sta obj_phases+4,x
	sta obj_phases+6,x
	sta obj_phases+8,x

	sta obj_phases+3,x
	sta obj_phases+5,x
	sta obj_phases+7,x
	txa
	clc
	adc #9
	tax
	cpx #object_count
	bne -
	jmp render


bump1:
	ldy #15
	bne bump_init
bump2:
	ldy #31
	bne bump_init
bump3:
	ldy #47

bump_init:

	ldx #15
-	lda +,y
	sta bump_start,x
	dey
	dex
	bpl -
	rts

+	byt 0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0
	byt 0,1,3,5,7,7,7,7,7,7,7,7,5,3,1,0
	byt 0,0,0,1,3,5,7,7,7,7,5,3,1,0,0,0

bumptab:
	byt [LONG1]0
bump_start:
bumptab_mid = bump_start+8
	byt 0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0
	byt [LONG1]0
	byt [LATI1]0

longi_rot:
	ldx #0
-	lda obj_longitudes,x
	lsr
	clc
	adc obj_latitudes,x
shift3 = *+1
	adc #0
	tay
	lda bump_start-LONG1,y
	sta obj_phases,x
	inx
	cpx #object_count
	bne -
	ldx shift3
	inx
	cpx #LONG1+16
	bne +
	ldx #0
+	stx shift3
	jmp render

lati_rot:
	ldx #0
-	lda obj_latitudes,x
shift4 = *+1
	adc #0
	tay
	lda bump_start-LATI1,y
	sta obj_phases,x
	inx
	cpx #object_count
	bne -
	ldx shift4
	inx
	cpx #LATI1+16
	bne +
	ldx #0
+	stx shift4
	jmp render

fade_out:
	ldx #0
-	lda obj_phases,x
	beq +
	dec obj_phases,x
+	inx
	cpx #object_count
	bne -
	jmp render

phase2:

	ldy #0
	jsr render2
	ldx phase2+1
	inx
	cpx #object_count
	bne +
	ldx #0
+	stx phase2+1
	rts

render2:
	ldx #0
-	lda phase_patt,y
	sta obj_phases,x
	iny
	cpy #object_count
	bne +
	ldy #0
+	inx
	cpx #object_count
	bne -
	jmp render

init_phase_patt:
	ldx #phase_patt_len
	lda #0
-	sta phase_patt,x
	inx
	cpx #object_count
	bne -

	rts

	tax
-	lda phase_patt,x
	sta phase_patt+object_count/2,x
	inx
	cpx #phase_patt_len
	bne -
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


