;
; LOD Player Version 2
;
F1LO	= $FF0E
F1HI	= $FF12
F2LO	= $FF0F
F2HI	= $FF10

freqs = $0130

freqs_add
	byt 07,57,54,51, 48,45,43,40, 38,36,34,32 ; 00
	byt 31,28,27,25, 24,23,21,21, 19,18,17,16 ; 12
	byt 15,14,14,12, 12,12,10,10, 10,09,08,08 ; 24
	byt 08,07,07,06, 06,06,05,05, 05,04,05,04 ; 36
	byt 03,04,03,04, 03,02,03,03, 02,02,02,02 ; 48
	byt 02,02,02,02+24			 ; 60 (63=off)
	
; Variables
base = $B6
PCH1		= base + $00	; channel data pattern pointers
PCH2		= base + $02
;PCH3		= base + $04
CH1		= base + $06	; channel data pointers
CH2		= base + $08
;CH3		= base + $0A

NOTE1		= base + $0C	; note counters
NOTE2		= base + $0D
;NOTE3		= base + $0E
NOTELEN1	= base + $0F	; current note lengths
NOTELEN2	= base + $10
;NOTELEN3	= base + $11

INS_TYPE1	= base + $12
INS_TYPE2	= base + $13
;INS_TYPE3	= base + $14
TONE1		= base + $15
TONE2		= base + $16
TONE_PREV1	= base + $17
ARP_CNT1	= base + $18
ARP_CNT2	= base + $19
;ARP_CNT3	= base + $1A

NOISE		= base + $1A
VOL_TAB		= base + $1B ; 16 bit

VOLUME		= base + $1D 
VOLTAB_CNT	= base + $1E

; COMMAND BYTES

END_MARK	= $FF
RETRIG		= $FE
SET_VOLTAB	= $FD
SET_SLIDE	= $FC
SET_ARP		= $FB
SETINS		= $F0
;SETVOL		= $E0
SETLEN		= $40

; Constants
base_note = 0 ; shift to Gi0
C0	= base_note + 0
Ci0	= base_note + 1	
D0	= base_note + 2
Di0	= base_note + 3
E0	= base_note + 4
F0	= base_note + 5
Fi0	= base_note + 6
G0	= base_note + 7
Gi0	= base_note + 8
A0	= base_note + 9
Ai0	= base_note + 10
B0	= base_note + 11

C1	= base_note + 12
Ci1	= base_note + 13
D1	= base_note + 14
Di1	= base_note + 15
E1	= base_note + 16
F1	= base_note + 17
Fi1	= base_note + 18
G1	= base_note + 19
Gi1	= base_note + 20
A1	= base_note + 21
Ai1	= base_note + 22
B1	= base_note + 23

C2 = base_note + 24
Ci2 = base_note + 25
D2 = base_note + 26
Di2 = base_note + 27
E2 = base_note + 28
F2 = base_note + 29
Fi2 = base_note + 30
G2 = base_note + 31
Gi2 = base_note + 32
A2 = base_note + 33
Ai2 = base_note + 34
B2 = base_note + 35

C3 = base_note + 36
Ci3 = base_note + 37
D3 = base_note + 38
Di3 = base_note + 39
E3 = base_note + 40
F3 = base_note + 41
Fi3 = base_note + 42
G3 = base_note + 43
Gi3 = base_note + 44
A3 = base_note + 45
Ai3 = base_note + 46
B3 = base_note + 47

C4 = base_note + 48
Ci4 = base_note + 49
D4 = base_note + 50
Di4 = base_note + 51
E4 = base_note + 52
F4 = base_note + 53
Fi4 = base_note + 54
G4 = base_note + 55
Gi4 = base_note + 56
A4 = base_note + 57
Ai4 = base_note + 58
B4 = base_note + 59

C5 = base_note + 60
Ci5 = base_note + 61
D5 = base_note + 62

OFF = 63

;-----
          
	align 256         
PLAYER_FREQ_INIT
	;         
	; *** Freq init
	;              
	lda #$00
	clc
	adc freqs_add
	sta freqs
	lda #$00
	adc #$00
	sta freqs+1
	;
	ldx #$00
	ldy #$01
	;
freq_init
	lda freqs,x
	clc
	adc freqs_add,y
	sta freqs+2,x
	inx
	lda freqs,x
	adc #$00
	sta freqs+2,x
	inx
	iny
	cpy #64
	bne freq_init
	;
PLAYER_INIT
	jsr reset_ch1
	jsr reset_ch2
	;JSR reset_ch3
	;
	jsr advance_ch1
	jsr advance_ch2
	;
	ldx #$FF
	stx VOLTAB_CNT
	inx
	stx NOTE1
	stx NOTE2
	inx
	stx NOTELEN1
	stx NOTELEN2
	;
	lda #vol_default & 255
	sta VOL_TAB
	lda #vol_default >> 8
	sta VOL_TAB+1
	;
	lda #$00	; max
	sta VOLUME
	;
	rts

res_1	jsr reset_ch1
	;
advance_ch1
	ldy #$01
	lda (PCH1),y	; HI byte
	beq res_1
	sta CH1 + 1
	dey
	lda (PCH1),y	; LO byte
	sta CH1
	inc PCH1
	inc PCH1
	rts
	
;set_ch1
;	STX SPCH1
;	STY SPCH1 + 1
;	RTS

reset_ch1
	;LDX SPCH1
	;LDY SPCH1 + 1
	ldx #Channel1 & 255
	ldy #Channel1 >> 8
	stx PCH1
	sty PCH1 + 1
	rts
	
reset_ch2
	;LDX SPCH2
	;LDY SPCH2 + 1
	ldx #Channel2 & 255
	ldy #Channel2 >> 8
	stx PCH2
	sty PCH2 + 1
	rts
	
;reset_ch3
;	;LDX SPCH2
;	;LDY SPCH2 + 1
;	LDX #Channel3 & 255
;	LDY #Channel3 >> 8
;	STX PCH3
;	STY PCH3 + 1
;	RTS
	
res_2	jsr reset_ch2
	;
advance_ch2
	ldy #$01
	lda (PCH2),y
	beq res_2
	;
	sta CH2 + 1
	;
	dey
	lda (PCH2),y
	sta CH2
	;
	inc PCH2
	inc PCH2
	;
	rts
	
;res_3	JSR reset_ch3
;	;
;advance_ch3
;	LDY #$01
;	LDA (PCH3),y
;	BEQ res_3
;	;
;	STA CH3 + 1
;	;
;	DEY
;	LDA (PCH3),y
;	STA CH3
;	;
;	INC PCH3
;	INC PCH3
;	;
;	RTS

;set_ch2
;	STX SPCH2
;	STY SPCH2 + 1
;	RTS

	;
	;##################
	;

PLAYER
	;------------------
	;JMP *
	inc NOTE1
	inc ARP_CNT1
	;
	lda NOTE1
	cmp NOTELEN1
	beq next_note1
	jmp player_channel2
	;
new_pattern1
	jsr advance_ch1
	;
next_note1
	ldy #$00
	sty NOTE1		; reset note counter
	;STY TICK1
	sty ARP_CNT1		; reset arp counter
	;
	lda (CH1),y		; get byte
	iny
	;
	cmp #END_MARK		; $FF goes to new pattern
	beq new_pattern1
	;
;	CMP #RETRIG
;	BNE pl_10
;	;
;	LDA #$80
;	STA click+1
;	;
;	LDA (CH1),y		; get byte
;	INY
;	;
;pl_10	
	cmp #$FD
	bne pl_11
	;
	lda #$FF		; reset voltab counter
	sta VOLTAB_CNT
	sta VOLUME		; disable SET volume
	;
	lda (CH1),y		; get lo byte
	sta VOL_TAB
	iny
	;
	lda (CH1),y		; get hi byte
	sta VOL_TAB+1
	iny
	;
	lda (CH1),y		; get byte
	iny
	;
pl_11	
;	CMP #$FC
;	BNE pl_12
;	;
;	LDA (CH1),y		; get SLIDE lo byte
;	STA slide
;	INY
;	;
;	LDA (CH1),y		; get SLIDE hi byte
;	STA slide+1
;	INY
;	;
;	LDA (CH1),y		; get byte
;	INY
;	;
;pl_12	
	cmp #SET_ARP
	bne pl_14
	;
	lda (CH1),y		; get arp lo byte
	sta arp_ptr1+1
	iny
	;
	lda (CH1),y		; get arp hi byte
	sta arp_ptr1+2
	iny
	;
	lda (CH1),y		; get byte
	iny
	;
pl_14	cmp #$F0		; instrument change?
	bcc pl_01
	;
	and #$0F		; keep lower 4 bits
	sta INS_TYPE1   	; store instrument type
	;
	lda (CH1),y		; get byte
	iny
	;
pl_01	cmp #$E0
	bcc pl_05
	;
	lda VOLUME
	clc
	adc #$09
	;AND #$0F
	;TAX
	;LDA mul9,x
	sta VOLUME		; store direct volume set value
	;
	lda (CH1),y		; get byte
	iny
	;
pl_05	cmp #$40		; set note length?
	bcc pl_02
	;
	sec
	sbc #$40
	sta NOTELEN1
	;
	lda (CH1),y
	iny
	;
pl_02	; - store note!
	;
	ldx TONE1		; keep previous
	stx TONE_PREV1
	sta TONE1
	;
	; --- advance pointer
	;
	tya
	clc
	adc CH1
	sta CH1
	bcc noi_1
	inc CH1 + 1
noi_1	;
	;
	; -----------------------------------------------------------------
	;
player_channel2
	inc NOTE2
	inc ARP_CNT2
	;
	lda NOTE2
	cmp NOTELEN2
	beq next_note2
	bne channel3
	;
new_pattern2
	jsr advance_ch2
	;
next_note2
	ldy #$00
	sty NOTE2		; reset note counter
	;STY TICK2
	sty ARP_CNT2		; reset arp counter
	;
	lda (CH2),y		; get byte
	iny
	;
	cmp #END_MARK		; $FF goes to new pattern
	beq new_pattern2
	;
	cmp #SET_ARP
	bne pl_24
	;
	lda (CH2),y		; get arp lo byte
	sta arp_ptr2+1
	iny
	;
	lda (CH2),y		; get arp hi byte
	sta arp_ptr2+2
	iny
	;
	lda (CH2),y		; get byte
	iny
	;
pl_24	cmp #$F0		; instrument change?
	bcc pl_21
	;
	and #$0F		; keep lower 4 bits
	sta INS_TYPE2   	; store instrument type
	;
	lda (CH2),y		; get byte
	iny
	;
pl_21	
;	CMP #$E0
;	BCC pl_25
;	;
;	AND #$0F
;	STA VOLUME
;	;
;	LDA (CH2),y		; get byte
;	INY
;	;
;pl_25	
	cmp #$40		; set note length?
	bcc pl_22
	;
	sec
	sbc #$40
	sta NOTELEN2
	;
	lda (CH2),y
	iny
	;
pl_22	; - store note!
	;
	ldx TONE2
	;STX TONE_PREV2
	sta TONE2
	;
	; --- advance pointer
	;
	tya
	clc
	adc CH2
	sta CH2
	bcc noi_2
	inc CH2 + 1
noi_2	;
	;
	; -----------------------------------------------------------------
	;
channel3
;	INC NOTE3
;	INC ARP_CNT3
;	;
;	LDA NOTE3
;	CMP NOTELEN3
;	BEQ next_note3
;	BNE pl_50
;	;
;new_pattern3
;	JSR advance_ch3
;	;
;next_note3
;	LDY #$00
;	STY NOTE3		; reset note counter
;	;STY TICK3
;	STY ARP_CNT3		; reset arp counter
;	;
;	LDA (CH3),y		; get byte
;	INY
;	;
;	CMP #END_MARK		; $FF goes to new pattern
;	BEQ new_pattern3
;	;
;pl_34	CMP #$F0		; instrument change?
;	BCC pl_31
;	;
;	AND #$0F		; keep lower 4 bits
;	STA INS_TYPE3   	; store instrument type
;	;
;	LDA (CH3),y		; get byte
;	INY
;	;
;pl_31	CMP #$40		; set note length?
;	BCC pl_32
;	;
;	SEC
;	SBC #$40
;	STA NOTELEN3
;	;
;	LDA (CH3),y
;	INY
;	;
;pl_32	; - store note!
;	;
;	LDX TONE3
;	;STX TONE_PREV3
;	STA TONE3
;	;
;	; --- advance pointer
;	;
;	TYA
;	CLC
;	ADC CH3
;	STA CH3
;	BCC noi_3
;	INC CH3 + 1
;noi_3	;     
	;
	;    
pl_50	ldy VOLTAB_CNT
	iny
	lda (VOL_TAB),y
	bpl noi_v		; check for $FF
	ldy #$00		; reached, so warp
noi_v	sty VOLTAB_CNT
	;
	; --- SOUND PROCESSING
	;
PLAYER_SOUND
	lda #$20
	sta NOISE
	;
	ldx #$00		; channel 0
	jsr sound
	;
	sta F1LO
	sty F1HI_x+1
	;
	lda F1HI
	and #$FC
F1HI_x	ora #$00
	sta F1HI
	;
	ldx #$01		; channel 1
	jsr sound
	sta F2LO
	sty F2HI
	;
	; ---
	;    
	;INC TICK1
	;INC TICK2
	;
	; ---
	;  
	ldy VOLTAB_CNT
	lda (VOL_TAB),y		; nope, read from envelope
	clc
	adc VOLUME
	tay
	lda volume_map,y
	;
pl_70	ora #$10
	;
	;ORA #$20
	ora NOISE
	;
;click	ORA #$00
setvol	sta $FF11
	;
	;LDA #$00
	;STA click+1
	;
	rts     
	;
inst_table
	adr normal, arp, bassdrum, snare, glide, plus1
	;
sound	;JMP *	
	lda TONE1,x
	cmp #OFF
	beq lookup
	;
	lda INS_TYPE1,x
	asl a
	tay
	lda inst_table,y
	sta inst_jump+1
	lda inst_table+1,y
	sta inst_jump+2
	;
inst_jump
	jmp $0000
	;
plus1	lda NOTE1,x
	bne plus1a
	;
	lda #$03
	sta $FF10
	lda $FF12
	and #$FC
	ora #$01
	sta $FF12
	lda #$FE
	sta $FF0F
	lda #$2F
	sta $FF0E
	;
	lda #$80+$38
	sta $FF11
	;
plus1a	lda TONE1,x		; normal note
	asl a
	tax
	lda freqs,x
	clc
	adc #$03
	ldy freqs+1,x
	rts
	
normal	lda TONE1,x		; normal note
lookup	asl a
	tax
	lda freqs,x
	ldy freqs+1,x
	rts
	
arp	ldy ARP_CNT1,x		; load current arp counter
	;
	cpx #$00		; check which channel
	beq arp_ptr1
arp_ptr2
	lda arpeggio,y		; for channel 2 (self-mod)
	jmp arp_1
arp_ptr1
	lda arpeggio,y		; for channel 1 (self-mod)
arp_1:
	bpl arp_add		; check for negative numbers
	;
	and #$0F		; low byte is new position
	sta ARP_CNT1,x
	jmp arp			; again!
	;
arp_add
	clc
	adc TONE1,x
	jmp lookup
	
;	;
;slider	;
;;	LDA slide
;;	BNE sl_01
;;	DEC slide+1
;;sl_01	DEC slide
;	;  
;	LDA TICK1,x
;	BNE add1
;	;
;	LDA slide
;	LDY slide+1
;	RTS
;	;
;add1	LDA TONE1,x
;	ASL a
;	TAX
;	LDY freqs+1,x
;	LDA freqs,x
;	CLC
;	ADC #$01
;	BCC sl_03
;	INY
;sl_03	RTS
	;
snare	
	lda #$40		; turn on noise bit
	sta NOISE
	;
	lda TONE1,x		; look up note freq
	asl a
	tay
	;
	lda NOTE1,x
	asl a
	tax
	lda snare_freq,x	; 16 bit add: add snare freq
	clc
	adc freqs,y       
	pha
	lda snare_freq+1,x
	adc freqs+1,y
	tay
	pla
	rts
	
bassdrum
	lda NOTE1,x
	asl a
	tax
	lda bass_freq,x
	ldy bass_freq+1,x
	rts              
	
;vibX	LDA NOTE1,x
;	AND #$0F
;	TAY
;	LDA vibrato2,y
;	BMI vib_sub1
;	BPL vib_add

;vib	LDA NOTE1,x
;	AND #$07
;	TAY
;	LDA vibrato,y
;	BMI vib_sub1
;	;
;vib_add
;	STA vib2+1
;	;
;	LDA TONE1,x
;	ASL a
;	TAX
;	LDY freqs+1,x
;	LDA freqs,x
;	CLC
;vib2	ADC #$01
;	BCC vib3
;	INY
;vib3	RTS
;	;
;vib_sub1
;	AND #$7F
;	;      
;	STA vib4+1
;	;
;	LDA TONE1,x
;	ASL a
;	TAX
;	LDY freqs+1,x
;	LDA freqs,x
;	SEC
;vib4	SBC #$01
;	BCS vib5
;	DEY
;vib5	RTS
;
glide_2	jmp normal

glide	lda NOTE1,x
	beq glide_1
	;
	;
	;
	cmp #$02			; change this to determine glide length
	bcs glide_2
	;
	lda glide_add
	bmi glide_sub
	;
	lda glide_freq_current
	clc
	adc glide_freq_diff
	sta glide_freq_current
	lda glide_freq_current+1
	adc glide_freq_diff+1
	sta glide_freq_current+1
	lda glide_freq_current+2
	adc glide_freq_diff+2
	sta glide_freq_current+2
	;
	lda glide_freq_current+1
	ldy glide_freq_current+2
	;
	rts
	;
glide_sub
	lda glide_freq_current
	sec
	sbc glide_freq_diff
	sta glide_freq_current
	lda glide_freq_current+1
	sbc glide_freq_diff+1
	sta glide_freq_current+1
	lda glide_freq_current+2
	sbc glide_freq_diff+2
	sta glide_freq_current+2
	;
	lda glide_freq_current+1
	ldy glide_freq_current+2
	;
	rts
	;
	; first iteration
	;
glide_1	lda TONE1,x			; look up destination freq
	asl a
	tay
	lda freqs,y
	sta glide_freq_dest+1
	lda freqs+1,y   
	sta glide_freq_dest+2
	;
	lda TONE_PREV1,x		; look up previous freq
	asl a
	tay
	lda freqs,y
	sta glide_freq_current+1
	lda freqs+1,y   
	sta glide_freq_current+2
	;
	lda #$00             		; clear low bytes of 24 bit values
	sta glide_freq_dest
	sta glide_freq_current
	sta glide_freq_diff
	;
	lda TONE1,x
	cmp TONE_PREV1,x
	bcs glide_down
	;
	; up
	;
	lda glide_freq_dest+1		; diff = dest - current
	sec
	sbc glide_freq_current+1
	sta glide_freq_diff+1
	lda glide_freq_dest+2
	sbc glide_freq_current+2
	sta glide_freq_diff+2
	;
	lda #$00
gl_up	sta glide_add
	;
	lsr glide_freq_diff+2		; 24 bit div routine
	ror glide_freq_diff+1
	ror glide_freq_diff		; div2
	;LSR glide_freq_diff+2
	;ROR glide_freq_diff+1
	;ROR glide_freq_diff		; div4
	;LSR glide_freq_diff+2
	;ROR glide_freq_diff+1
	;ROR glide_freq_diff		; div8
	;LSR glide_freq_diff+2
	;ROR glide_freq_diff+1
	;ROR glide_freq_diff
	;
	lda glide_freq_current+1
	ldy glide_freq_current+2
	;
	rts

glide_down
	lda glide_freq_current+1	; diff = current - dest
	sec
	sbc glide_freq_dest+1
	sta glide_freq_diff+1
	lda glide_freq_current+2
	sbc glide_freq_dest+2
	sta glide_freq_diff+2
	;
	lda #$80     
	bne gl_up			; always jump

glide_freq_current
	byt 0,0,0	; 24 bit values
glide_freq_dest
	byt 0,0,0
glide_freq_diff
	byt 0,0,0
glide_add
	byt 0

snare_freq
	adr $00F7
	adr $00D2
	adr $00F0
	adr $00D1
	adr $00EF
	;
bass_freq
	adr $0159
	adr $0106
	adr $00D9
	adr $0076
	adr $0007
