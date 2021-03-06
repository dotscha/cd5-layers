init_irq
	jsr set_irq_1		; set up the irq
	asl $FF09
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

	if MC_LOGO
	lda $ff07
	and #$ef
	sta $ff07
	else
	nop
	nop
	nop
	nop
	nop
	endif

	;
border_color
	lda #bg_col
	sta $FF19

	if MC_LOGO
	lda #bg_col	;scroll bg
	sta $ff15
	endif
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
	lda #bg_col
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
	ora #$08 + $10 * MC_LOGO
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

	if MC_LOGO
	lda logo_ff15
	sta $ff15
	lda logo_ff16
	sta $ff16
	endif

	;
call_scroll
	bit SCROLL
	;
	jsr set_irq_1
	;
	pla
	tay
	pla
	tax
	pla
	rti

cs_middle_color
	lda #$71
	sta border_color+1
	;
	ldx #79			; init bitmap colors
csm1	lda #$77		; luminance
	sta $0800+6*40+0*80,x
	sta $0800+6*40+1*80,x
	sta $0800+6*40+2*80,x
	sta $0800+6*40+3*80,x
	sta $0800+6*40+4*80,x
	sta $0800+6*40+5*80,x
	sta $0800+6*40+11*40,x

	lda #$11
	sta $0c00+6*40+0*80,x
	sta $0c00+6*40+1*80,x
	sta $0c00+6*40+2*80,x
	sta $0c00+6*40+3*80,x
	sta $0c00+6*40+4*80,x
	sta $0c00+6*40+5*80,x
	sta $0c00+6*40+11*40,x

	dex
	bpl csm1
	;
	ldx #39
	lda #$77
csm2	sta $0800+18*40,x
	dex
	bpl csm2
	rts

cs_logo_color
	ldx #$00		; init bitmap colors
csl1	lda #$50		; luminance
	sta $0800,x
	lda #$16		; color
	sta $0C00,x
	inx
	cpx #40*6
	bne csl1
	rts
	
cs_scroll_color
	ldx #$27
	lda #$41		; luminance
csc1	sta $0B20+0*40,x
	sta $0B20+1*40,x
	sta $0B20+2*40,x
	sta $0B20+3*40,x
	sta $0B20+4*40,x
	dex
	bpl csc1
	rts

cs_wait_frame
	lda #$BC
	cmp $FF1D
	bne *-3
	rts

cs_start_scroll
	lda #$20	; JSR $#### opcode
	sta call_scroll
	rts
	
