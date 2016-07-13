	align 32
patt1:
	;byt 7,6,5,4,3,2,1,0,0,1,2,3,4,5,6,7
	;byt 7,7,7,6,5,4,3,2,1,0,0,0,0,0,0,0 ; thetra
	;byt 0,1,2,3,4,5,6,7,7,6,5,4,3,2,1,0
	;byt 0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7
	;byt 0,0,0,0,0,0,0,0,1,2,3,4,5,6,7,7 ; sides
	;byt 0,0,0,0,1,2,3,4,5,6,7,7,7,7,7,7 ; sides2
	byt [16]0,2,3,4,5,6,7,7,7,7,7,6,5,4,3,2,[6]0 ; sides3
	;byt 7,7,6,6,5,5,4,4,3,3,2,2,1,1,0,0


rot1:	byt 0
rot2:	byt 0

pressed:
	byt 0

p = $fe
q = $fc

init3d:
	lda #0
	sta pressed
	tax
-	sta $0200,x
	inx
	bne -
	rts

loop_until_fire:

	lda pressed
	bmi +
	sc_init joy_loop
+	rts

render3dp:
	inc patt_offs
	jmp render3d

render3dm:
	dec patt_offs

render3d:

LONG1D = LONG1*2 ; the obj coords have double longitude precision

	ldx #0
-	lda obj_longitudes,x
	clc
	adc rot1
	cmp #LONG1D
	bmi +
	sec
	sbc #LONG1D
+	lsr

	ldy obj_latitudes,x
	clc
	adc coord_row_lo,y
	sta p
	lda coord_row_hi,y
	adc #0
	sta p+1

	lda p
	adc #lo(coord_longitudes)
	sta q
	lda p+1
	adc #hi(coord_longitudes)
	sta q+1

	ldy #0
	lda (q),y
	adc rot2
	cmp #LONG2
	bmi +
	sec
	sbc #LONG2
+	lsr ; /2
	lsr ; /2
	pha

	clc
	lda p
	adc #lo(coord_latitudes)
	sta q
	lda p+1
	adc #hi(coord_latitudes)
	sta q+1

	lda (q),y
	and #$f8 ; /8, *8
	asl      ; *2
	asl      ; *2
	sta p
	lda #0
	rol
	sta p+1

	pla
	adc p
	sta p
	lda p+1
	adc #0
	sta p+1

	lda p
	adc #lo(texture)
	sta p
	lda p+1
	adc #hi(texture)
	sta p+1

	lda (p),y
	tay
patt_offs = *+1
	lda patt1,y
	sta $02,x

	inx
	cpx #object_count
	beq +
	jmp -
+

	;the max of current and previous, to filter out noise
	ldy #0
-	lax $02,y
	cmp $0200,y
	bpl +
	ldx $0200,y
	stx $02,y
+	sta $0200,y

	iny
	cpy #object_count
	bne -

	lda #$fd
	sta $fd30
	sta $ff08
	lda $ff08
	eor #$ff
	and #%10001111
	beq +
	sta pressed
+	ldx pressed
	bne +
	lda #%0101
+	sta $fb

	ror $fb
	bcc +
	jsr rot1p
+	ror $fb
	bcc +
	jsr rot1m
+	ror $fb
	bcc +
	jsr rot2p
+	ror $fb
	bcc +
	jsr rot2m

+	jmp render

	; rot1++
rot1p:
	ldx rot1
	inx
	cpx #LONG1D
	bne +
	ldx #0
+	stx rot1
	rts

	; rot1--
rot1m:
	ldx rot1
	dex
	bpl +
	ldx #LONG1D-1
+	stx rot1
	rts

	; rot2++
rot2p:
	clc
	lda rot2
	adc #2
	and #$7f
	sta rot2
	rts

	; rot2--
rot2m:
	sec
	lda rot2
	sbc #2
	and #$7f
	sta rot2
	rts
