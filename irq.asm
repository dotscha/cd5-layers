init_irq
	lda #irq1 & 255
	sta $FFFE
	lda #irq1 >> 8
	sta $FFFF
	lda #$CC
	sta $FF0B
	;
	jsr PLAYER_FREQ_INIT
	;
	rts
	
irq1
	pha
	txa
	pha
	tya
	pha
	;
	asl $FF09
	;
	dec $FF19
	jsr PLAYER
	inc $FF19
	;
	pla
	tay
	pla
	tax
	pla
	rti
	