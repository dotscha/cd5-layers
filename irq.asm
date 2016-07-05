init_irq
	jsr set_irq_1		; set up the irq
	;
	jsr PLAYER_FREQ_INIT	; one time music init
	;
	jsr init_scroll
	;
	rts
	
;	;
;	lda #$06		; simple delay to hold the initial graphics
;	ldx #$00
;	ldy #$00
;delay	iny
;	bne delay
;	inx
;	bne delay
;	sec
;	sbc #$01
;	bne delay
;	;
;	rts

set_irq_1	
	ldx #irq1 & 255
	ldy #irq1 >> 8
	lda #$32
set_irq	stx $FFFE
	sty $FFFF
	sta $FF0B
	rts
	
irq1	pha
	txa
	pha
	tya
	pha
	asl $FF09
	;
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	;
	lda #$31
	sta $FF19
	;
	ldx #irq2 & 255
	ldy #irq2 >> 8
	lda #$9A
	jsr set_irq
	;
	pla
	tay
	pla
	tax
	pla
	rti
	
irq2	pha
	txa
	pha
	tya
	pha
	asl $FF09
	;
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	nop
	;
	lda #$01
	sta $FF19
	;
	lda $FF06
	and #$DF
	sta $FF06
	;
	lda $FF07
	and #$40
xshift	ora #$00
	sta $FF07
	;
	lda $FF12
	and #$C3
	sta $FF12
	;
	jsr PLAYER
	;
	ldx #irq3 & 255
	ldy #irq3 >> 8
	lda #$CC
	jsr set_irq
	;
	pla
	tay
	pla
	tax
	pla
	rti
	
irq3	pha
	txa
	pha
	tya
	pha
	asl $FF09
	;
	lda $FF07
	and #$40
	ora #$08
	sta $FF07
	;
	lda $FF06
	ora #$20
	sta $FF06
	;
	lda $FF12
	and #%11000011
	ora #(bitmap/1024)
	sta $FF12
	;
	jsr SCROLL
	;
	jsr set_irq_1
	;
	pla
	tay
	pla
	tax
	pla
	rti
	
