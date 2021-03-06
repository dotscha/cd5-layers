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
	sbc #$03
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
clrpos	ldx #$FF			; self-mod
	bmi no_color_set
newclr	lda #$61			; self-mod
	sta $0B20+0*40,x
	sta $0B20+1*40,x
	sta $0B20+2*40,x
	sta $0B20+3*40,x
	sta $0B20+4*40,x
	dex
	stx clrpos+1
	;
no_color_set
	;
	; ---
	;
	lda char_width
	bne no_new_char
	;
	ldy #$00
chr0	lda (scroll_text_ptr),y
	iny
	cmp #$FF
	bne *+3
	;
	rts
	;
	cmp #$FE			; control byte for "set color"
	bne chr1
	;
	lda (scroll_text_ptr),y
	iny
	sta newclr+1
	lda #$27
	sta clrpos+1
	bne chr0			; always jump, read next char
	;
chr1	cmp #$F0			; control byte for speed
	bcc chr2
	;
	and #$0F
	sta scroll_speed+1
	jmp chr0
	;
chr2	tax
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
	tya
	clc
	adc scroll_text_ptr
	sta scroll_text_ptr
	bcc *+4
	inc scroll_text_ptr+1
	;
no_new_char
	dec char_width
	;
	ldy #$00			; read the column from char data and put it on the screen
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
	iny
	;
	tya				; advance the pointer by 5 bytes
	clc
	adc char_ptr
	sta char_ptr
	bcc *+4
	inc char_ptr+1
	;
	rts
	
	CHARSET 'A','Z',$01
	CHARSET '.',$1B
	CHARSET ',',$1C
	CHARSET '!',$1D
	CHARSET '?',$1E
	CHARSET '+',$1F
	CHARSET 'a','z',$21
	CHARSET '0','9',$3B
	
initial_text
	byt $00
	byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	byt $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	byt $00,$00,$00,$00,$00,$00,$00,$00
	byt $00,$00,$00,$00,$00,$00,$00,$00
	byt $01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	byt $00,$00,$01,$00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$00,$00,$00
	byt $00,$00,$0F,$25,$0C,$0F,$10,$11,$07,$09,$00,$00,$01,$00,$01,$0F
	byt $10,$11,$01,$00,$01,$0B,$24,$11,$00,$00,$07,$24,$11,$0F,$10,$11
	byt $03,$03,$0F,$10,$11,$00,$00,$00,$00,$00,$34,$00,$03,$12,$00,$13
	byt $03,$00,$00,$00,$14,$00,$03,$12,$00,$13,$03,$00,$03,$03,$00,$19
	byt $00,$00,$03,$00,$13,$28,$1E,$29,$03,$03,$2D,$2E,$2F,$00,$00,$00
	byt $00,$00,$16,$27,$0A,$14,$00,$15,$03,$00,$00,$00,$16,$27,$0A,$14
	byt $00,$15,$14,$00,$15,$03,$00,$00,$00,$00,$03,$00,$15,$2A,$2B,$2C
	byt $03,$03,$30,$31,$32,$00,$00,$00,$00,$00,$06,$08,$18,$16,$17,$18
	byt $16,$09,$00,$00,$06,$08,$18,$16,$17,$18,$16,$17,$18,$04,$00,$00
	byt $00,$00,$0D,$26,$18,$16,$08,$0E,$04,$04,$16,$17,$18,$00,$00
	
scroll_text
	byt " "
	byt $FE,$61
	byt " get ready to rock now! "
	byt $FE,$57
	byt " "
	byt $F7
	byt "Greetings to"
	byt " all the Plussy people"
	byt $FE,$41
	byt " "
	byt $F4
	byt "and everyone at"
	byt $FE,$51
	byt " Arok."
	byt "               "
	byt $FE,$41
	byt "Hi there, Bubis is writing. This is my first scroll text ever, how strange! "
	byt "So, a few words about what is going on here. You have 180 triangles covering an inner ball "
	byt "and casting their shadow on it on your screen."
	byt $FE,$51
	byt " The code and the textures were computed and optimized by a C++ program."
	byt $FE,$61
	byt " The texture is compressed by 54 percent to fit into the memory "
	byt "by finding duplicates and overlaps of the 8 byte texture segments the rendering code is using."
	byt $FE,$51
	byt " Most of the coding was done on my Android tablet while commuting between home and work."
	byt $FE,$41
	byt " Thumbs up for Csabo and Chronos for the TED music and the logo!            "
	byt $FE,$57
	byt " Are you still reading? Try to use the joystick and s, z and e in the 3D part. "
	byt $F7
	byt " Enjoy!         "
	byt $FE,$01 ; scroll over
	byt " "
	byt $FF
	
char_widths
	byt 2 ; null
	byt 3,3,3,3,3,3,3,3
	byt 1,3,3,3,3,3,3,3
	byt 3,3,3,3,3,3,3,3
	byt 3,3
	byt 1,1,1,3,3
	byt 2 ; space
	byt 3,3,3,3,3,2,3,3
	byt 1,2,3,1,3,3,3,3
	byt 3,3,3,2,3,3,3,3
	byt 3,3
	byt 3,1,3,3,3,3,3,3,3,3
	
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
	adr char_comma
	adr char_exclamation
	adr char_question
	adr char_plus
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
	adr char_upper_i
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
	;
	adr char_upper_o
	adr char_upper_i
	adr char_space
	adr char_3
	adr char_4
	adr char_5
	adr char_space
	adr char_space
	adr char_8
	adr char_space
	
char_space
	byt 0,0,0,0,0
	byt 0,0,0,0,0
char_upper_a
	byt $0F,$12,$07,$03,$04
	byt $10,$00,$08,$00,$00
	byt $11,$13,$0a,$03,$04
char_upper_b
	byt $0B,$03,$07,$03,$0D
	byt $24,$00,$44,$00,$26
	byt $11,$33,$45,$33,$18
char_upper_c
	byt $0F,$12,$03,$14,$16
	byt $10,$00,$00,$00,$17
	byt $11,$19,$00,$1B,$18
char_upper_d
	byt $0B,$03,$03,$03,$0D
	byt $24,$00,$00,$00,$26
	byt $11,$13,$03,$15,$18
char_upper_e
	byt $0B,$03,$07,$03,$0D
	byt $08,$00,$09,$00,$08
	byt $09,$00,$00,$00,$09
char_upper_f
	byt $0B,$03,$07,$03,$04
	byt $08,$00,$09,$00,$00
	byt $09,$00,$00,$00,$00
char_upper_g
	byt $0F,$12,$03,$14,$16
	byt $10,$00,$06,$00,$17
	byt $11,$19,$0C,$15,$18
char_upper_h
	byt $01,$03,$07,$03,$04
	byt $00,$00,$08,$00,$00
	byt $01,$03,$0A,$03,$04
char_upper_i
	byt $01,$03,$03,$03,$04
char_upper_j
	byt $00,$00,$00,$1C,$16
	byt $00,$00,$00,$00,$17
	byt $01,$03,$03,$15,$18
char_upper_k
	byt $01,$03,$07,$03,$04
	byt $00,$00,$44,$00,$00
	byt $01,$15,$45,$13,$04
char_upper_l
	byt $01,$03,$03,$03,$0D
	byt $00,$00,$00,$00,$08
	byt $00,$00,$00,$00,$09
char_upper_m
	byt $0B,$03,$03,$03,$04
	byt $02,$03,$03,$03,$04
	byt $11,$13,$03,$03,$04
char_upper_n
	byt $0B,$03,$03,$03,$04
	byt $24,$00,$00,$00,$00
	byt $11,$13,$03,$03,$04
char_upper_o
	byt $0F,$12,$03,$14,$16
	byt $10,$00,$00,$00,$17
	byt $11,$13,$03,$15,$18
char_upper_p
	byt $0B,$03,$07,$03,$04
	byt $24,$00,$26,$00,$00
	byt $11,$33,$18,$00,$00
char_upper_q
	byt $0F,$12,$03,$14,$16
	byt $10,$00,$00,$00,$27
	byt $11,$13,$03,$03,$0E
char_upper_r
	byt $0B,$03,$07,$03,$04
	byt $24,$00,$44,$00,$00
	byt $11,$33,$45,$13,$04
char_upper_s
	byt $0F,$34,$16,$1C,$16
	byt $10,$00,$48,$00,$17
	byt $11,$19,$11,$33,$18
char_upper_t
	byt $06,$00,$00,$00,$00
	byt $02,$03,$03,$03,$04
	byt $09,$00,$00,$00,$00
char_upper_u
	byt $01,$03,$03,$14,$16
	byt $00,$00,$00,$00,$17
	byt $01,$03,$03,$15,$18
char_upper_v
	byt $01,$03,$03,$3C,$3F
	byt $00,$00,$00,$3D,$40
	byt $01,$03,$03,$3E,$41
char_upper_w
	byt $01,$03,$03,$03,$16
	byt $01,$03,$03,$03,$05
	byt $01,$03,$03,$03,$18
char_upper_x
	byt $01,$14,$46,$12,$04
	byt $00,$00,$47,$00,$00
	byt $01,$15,$45,$13,$04
char_upper_y
	byt $01,$14,$16,$00,$06
	byt $00,$00,$27,$00,$08
	byt $01,$03,$0A,$03,$18
char_upper_z
	byt $06,$00,$0F,$12,$0D
	byt $08,$00,$25,$00,$08
	byt $0C,$03,$18,$00,$09
char_period
	byt $00,$00,$00,$00,$23
char_comma
	byt $00,$00,$00,$1B,$18
char_exclamation
	byt $01,$03,$03,$04,$23
char_question
	byt $0F,$1A,$00,$00,$00
	byt $10,$00,$0F,$04,$23
	byt $11,$33,$18,$00,$00
char_plus
	byt $00,$00,$06,$00,$00
	byt $00,$01,$49,$04,$00
	byt $00,$00,$09,$00,$00
char_lower_a
	byt $00,$0F,$28,$2A,$16
	byt $00,$10,$1E,$2B,$08
	byt $00,$11,$29,$2C,$0E
char_lower_b
	byt $01,$07,$03,$03,$0D
	byt $00,$24,$00,$00,$26
	byt $00,$11,$13,$15,$18
char_lower_c
	byt $00,$0F,$12,$14,$16
	byt $00,$10,$00,$00,$17
	byt $00,$11,$19,$1B,$18
char_lower_d
	byt $00,$0F,$12,$14,$16
	byt $00,$25,$00,$00,$27
	byt $01,$0A,$03,$03,$0E
char_lower_e
	byt $00,$0F,$1D,$20,$16
	byt $00,$10,$1E,$21,$17
	byt $00,$11,$1F,$22,$18
char_lower_f
	byt $0f,$07,$03,$03,$04
	byt $09,$09,$00,$00,$00
char_lower_g
	byt $00,$0F,$34,$16,$06
	byt $00,$25,$00,$27,$08
	byt $00,$0C,$03,$0A,$18
char_lower_h
	byt $01,$07,$03,$03,$04
	byt $00,$24,$00,$00,$00
	byt $00,$11,$13,$03,$04
char_lower_i
	byt $23,$01,$03,$03,$04
char_lower_j
	byt $00,$00,$00,$00,$06
	byt $23,$01,$03,$03,$18
char_lower_k
	byt $01,$03,$3A,$3B,$04
	byt $00,$00,$39,$31,$00
	byt $00,$01,$35,$36,$04
char_lower_m
	byt $00,$0B,$03,$03,$04
	byt $00,$02,$03,$03,$04
	byt $00,$11,$13,$03,$04
char_lower_n
	byt $00,$0B,$03,$03,$04
	byt $00,$24,$00,$00,$00
	byt $00,$11,$13,$03,$04
char_lower_o
	byt $00,$0F,$12,$14,$16
	byt $00,$10,$00,$00,$17
	byt $00,$11,$13,$15,$18
char_lower_p
	byt $00,$0B,$03,$07,$04
	byt $00,$24,$00,$26,$00
	byt $00,$11,$33,$18,$00
char_lower_q
	byt $00,$0F,$34,$16,$00
	byt $00,$25,$00,$27,$00
	byt $00,$0C,$03,$0A,$04
char_lower_r
	byt $00,$0B,$03,$03,$04
	byt $00,$24,$00,$00,$00
	byt $00,$11,$19,$00,$00
char_lower_s
	byt $00,$0F,$2D,$30,$16
	byt $00,$10,$2E,$31,$17
	byt $00,$11,$2F,$32,$18
char_lower_t
	byt $01,$07,$03,$03,$16
	byt $00,$09,$00,$00,$09
char_lower_u
	byt $00,$01,$03,$14,$16
	byt $00,$00,$00,$00,$17
	byt $00,$01,$03,$15,$18
char_lower_v
	byt $00,$01,$03,$3C,$3F
	byt $00,$00,$00,$3D,$40
	byt $00,$01,$03,$3E,$41
char_lower_w
	byt $00,$01,$03,$03,$16
	byt $00,$01,$03,$03,$05
	byt $00,$01,$03,$03,$18
char_lower_x
	byt $00,$01,$37,$38,$04
	byt $00,$00,$42,$43,$00
	byt $00,$01,$35,$36,$04
char_lower_y
	byt $00,$01,$14,$16,$06
	byt $00,$00,$00,$27,$08
	byt $00,$01,$03,$0A,$18
char_lower_z
	byt $00,$06,$0F,$12,$0D
	byt $00,$08,$25,$00,$08
	byt $00,$0C,$18,$00,$09
char_3
	byt $06,$00,$00,$00,$06
	byt $24,$00,$44,$00,$26
	byt $11,$33,$45,$33,$18
char_4
	byt $01,$14,$16,$00,$00
	byt $00,$00,$27,$00,$00
	byt $01,$03,$0A,$03,$04
char_5
	byt $0B,$03,$0D,$1C,$16
	byt $08,$00,$24,$00,$17
	byt $09,$00,$11,$33,$18
char_8
	byt $0F,$34,$46,$34,$16
	byt $10,$00,$47,$00,$17
	byt $11,$33,$45,$33,$18
	