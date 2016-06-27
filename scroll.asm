scroll_text_ptr = $F0
char_ptr = $F2
char_width = $F4

init_scroll
	lda #scroll_text & 255
	sta scroll_text_ptr
	lda #scroll_text >> 8
	sta scroll_text_ptr+1
	;
	lda #$00
	sta char_width
	rts

SCROLL
	lda xshift+1
	sec
scroll_speed
	sbc #$05
	bpl noscroll
	;
	clc
	adc #$08
	sta xshift+1
	;
	jmp scroll_chars
	;
noscroll
	sta xshift+1
	rts
	
scroll_chars
	ldx #$00
sc1	lda $0F21+0*40,x
	sta $0F20+0*40,x
	lda $0F21+1*40,x
	sta $0F20+1*40,x
	lda $0F21+2*40,x
	sta $0F20+2*40,x
	lda $0F21+3*40,x
	sta $0F20+3*40,x
	lda $0F21+4*40,x
	sta $0F20+4*40,x
	inx
	cpx #39
	bne sc1
	;
	; ---
	;
	lda char_width
	bne no_new_char
	;
	ldy #$00
	lda (scroll_text_ptr),y
	tax
	lda char_widths,x
	sta char_width
	txa
	asl a
	tax
	lda char_ptrs,x
	sta char_ptr
	lda char_ptrs+1,x
	sta char_ptr+1
	;
	lda scroll_text_ptr
	clc
	adc #$01
	sta scroll_text_ptr
	bcc *+4
	inc scroll_text_ptr+1
	;
no_new_char
	dec char_width
	;
	ldy #$00
	lda (char_ptr),y
	sta $0F20+39+0*40
	iny
	lda (char_ptr),y
	sta $0F20+39+1*40
	iny
	lda (char_ptr),y
	sta $0F20+39+2*40
	iny
	lda (char_ptr),y
	sta $0F20+39+3*40
	iny
	lda (char_ptr),y
	sta $0F20+39+4*40
	;
	lda char_ptr
	clc
	adc #$05
	sta char_ptr
	bcc *+4
	inc char_ptr+1
	;
	rts
	
	CHARSET 'A','Z',$01
	CHARSET '.',$1B
	CHARSET 'a','z',$21
	
scroll_text
	byt "Hello an...   ..."
	byt "                                      ..."
	byt "                                      ..."
	byt "                                      ..."
	byt $FF
	
char_widths
	byt 2 ; space
	byt 3,3,3,3,3,3,3,3
	byt 1,3,3,1,3,3,3,3
	byt 3,3,3,3,3,3,3,3
	byt 3,3
	byt 1,1,1,1,1,1
	byt 3,3,3,3,3,3,3,3
	byt 1,3,3,1,3,3,3,3
	byt 3,3,3,3,3,3,3,3
	byt 3,3
	byt 1,1,1,1,1,1
	
char_ptrs
	adr char_space
	adr char_upper_a
	adr char_upper_b
	adr char_upper_c
	adr char_upper_d
	adr char_upper_e
	adr char_upper_f
	adr char_upper_g
	adr char_upper_h
	adr char_upper_i
	adr char_upper_j
	adr char_upper_k
	adr char_upper_l
	adr char_upper_m
	adr char_upper_n
	adr char_upper_o
	adr char_upper_p
	adr char_upper_q
	adr char_upper_r
	adr char_upper_s
	adr char_upper_t
	adr char_upper_u
	adr char_upper_v
	adr char_upper_w
	adr char_upper_x
	adr char_upper_y
	adr char_upper_z
	adr char_period
	adr char_space
	adr char_space
	adr char_space
	adr char_space
	adr char_space
	adr char_lower_a
	adr char_lower_b
	adr char_lower_c
	adr char_lower_d
	adr char_lower_e
	adr char_lower_f
	adr char_lower_g
	adr char_lower_h
	adr char_lower_i
	adr char_lower_j
	adr char_lower_k
	adr char_lower_l
	adr char_lower_m
	adr char_lower_n
	adr char_lower_o
	adr char_lower_p
	adr char_lower_q
	adr char_lower_r
	adr char_lower_s
	adr char_lower_t
	adr char_lower_u
	adr char_lower_v
	adr char_lower_w
	adr char_lower_x
	adr char_lower_y
	adr char_lower_z
	
char_space
	byt 0,0,0,0,0
	byt 0,0,0,0,0
char_upper_a
char_upper_b
char_upper_c
char_upper_d
char_upper_e
char_upper_f
char_upper_g
char_upper_h
char_upper_i
char_upper_j
char_upper_k
char_upper_l
char_upper_m
char_upper_n
char_upper_o
char_upper_p
char_upper_q
char_upper_r
char_upper_s
char_upper_t
char_upper_u
char_upper_v
char_upper_w
char_upper_x
char_upper_y
char_upper_z
	byt $01,$03,$07,$03,$04
	byt $00,$00,$08,$00,$00
	byt $01,$03,$0A,$03,$04
char_period
	byt $00,$00,$00,$00,$23
char_lower_a
	byt $00,$0F,$28,$2A,$16
	byt $00,$10,$1E,$2B,$08
	byt $00,$11,$29,$2C,$0E
char_lower_b
char_lower_c
char_lower_d
char_lower_e
	byt $00,$0F,$1D,$20,$16
	byt $00,$10,$1E,$21,$17
	byt $00,$11,$1F,$22,$18
char_lower_f
char_lower_g
char_lower_h
char_lower_i
char_lower_j
char_lower_k
char_lower_l
	byt $01,$03,$03,$03,$04
char_lower_m
char_lower_n
	byt $00,$0B,$03,$03,$04
	byt $00,$08,$00,$00,$00
	byt $00,$11,$13,$03,$04
char_lower_o
char_lower_p
char_lower_q
char_lower_r
char_lower_s
char_lower_t
char_lower_u
char_lower_v
char_lower_w
char_lower_x
char_lower_y
char_lower_z
	byt $00,$0F,$12,$14,$16
	byt $00,$10,$00,$00,$17
	byt $00,$11,$13,$15,$18