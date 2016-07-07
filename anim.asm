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

char_x0 = 14
char_x1 = 25
char_y0 = 7
char_y1 = 17

char_w = char_x1-char_x0+1
char_h = char_y1-char_y0+1


anim_scenario:
	sc_rept 80,cs_wait_frame
	sc_once cs_middle_color
	sc_rept 80,cs_wait_frame
	sc_once cs_logo_color
	sc_rept 80,cs_wait_frame
	sc_once cs_scroll_color

	sc_rept 120,raster_sync

	sc_once color_it
;
	sc_rept (char_h*8-8*3-4)/3,copy_lines3
	sc_rept 8,copy_lines2
	sc_rept 8,copy_lines1
	sc_rept 3,copy_lines_hl
	sc_rept 1,copy_lines_h

	sc_rept 60,raster_sync
;
	sc_once copy_lines_init2
	sc_rept (char_h*8-8*3-4)/3,copy_lines3
	sc_rept 8,copy_lines2
	sc_rept 8,copy_lines1
	sc_rept 3,copy_lines_hl
	sc_rept 1,copy_lines_h

	sc_rept 60,raster_sync
;
	sc_once copy_lines_init3
	sc_rept (char_h*8-8*3-4)/3,copy_lines3
	sc_rept 8,copy_lines2
	sc_rept 8,copy_lines1
	sc_rept 3,copy_lines_hl
	sc_rept 1,copy_lines_h

	sc_rept 50,raster_sync

	sc_once cs_middle_color

anim_restart:
	sc_rept 1,color_fade_in
	sc_once zero_out
	sc_rept 8,color_fade_in

	sc_once cs_start_scroll

	sc_rept 80,raster_sync


	sc_rept 12*8,nodes_in
	sc_rept 32,render
	sc_rept 7,fade_out
	sc_rept 20*8,faces_in
	sc_rept 32,render

	sc_rept 7,fade_out
	sc_once init_phase1
	sc_once bump1
	sc_rept 8,phase1
	sc_rept 32,render
	sc_rept 8,phase1
	sc_rept 55,render
	sc_rept 8,phase1
	sc_once bump3
	sc_rept 2*(LATI1+16),lati_rot
	sc_once bump1
	sc_rept 2*(LONG1+16),longi_rot
	sc_rept 7,fade_out
	sc_once init_phase_patt
	sc_rept 512,phase2

	if THREED
	sc_once init3d
	sc_rept 10,render3dp
	sc_rept 128,render3d

	sc_rept 11,render3dp
	sc_rept 128,render3d
	sc_rept 11,render3dm

	sc_rept 128,render3d
	sc_rept 10,render3dm
	endif

	sc_rept 8,color_fade_out

	sc_once jump_anim_restart

;-------------------------------------------------

	include obj_coords.asm

bumptab = $0200
bump_start = bumptab+LATI1+LONG1
bump_mid = bump_start+8


init_anim:

	lda #7
	jsr zero_out+2
	lda #char_w*2*8
	jsr copy_stuff

	jsr zero_out
	lda #0
	jsr copy_stuff

	lda #(char_w-1)*8
	jsr copy_stuff	;clears the screen

init_sc:
	sc_init anim_scenario
	rts

jump_anim_restart:
	sc_init anim_restart
	rts


raster_sync2:
	jsr raster_sync
raster_sync:
-	cmp $ff1d
	bne -
-	cmp $ff1d
	beq -
	rts

copy_stuff:
fx_00 = bitmap+char_y0*320+char_x0*8
cp_00 = bitmap+char_y0*320+(char_x0-char_w)*8

	clc
	adc #lo(cp_00)
	sta + +4
	lda #hi(cp_00)
	adc #0
	sta + +5
	lda #lo(fx_00)
	sta + +1
	lda #hi(fx_00)
	sta + +2

	ldy #char_h
-	ldx #char_w*8-1
/	lda fx_00,x
	sta cp_00,x
	dex
	bpl -

	clc
	lda - +1
	adc #lo(320)
	sta - +1
	lda - +2
	adc #hi(320)
	sta - +2

	lda - +4
	adc #lo(320)
	sta - +4
	lda - +5
	adc #hi(320)
	sta - +5

	dey
	bne --

	rts


copy_lines1:
	jsr copy_lines
	jmp horizontal_line

copy_lines3:
	jsr copy_lines
	jsr copy_lines+5
	jmp *+6

copy_lines2:
	jsr copy_lines
	jsr copy_lines+5

horizontal_line:
	lda line_cp+4
	sta $fe
	lda line_cp+5
	sta $ff
	ldy #0
	ldx #char_w
	clc
-	lda #255
	sta ($fe),y
	tya
	adc #8
	tay
	dex
	bne -
	rts

copy_lines_hl:
	jsr copy_lines_h
	jmp horizontal_line

copy_lines_h:
	lda #$cc
	jsr raster_sync2
	jmp copy_lines+5

copy_lines_init3:
	lda #lo(fx_00-320)
	ldx #hi(fx_00-320)
	jmp *+7

copy_lines_init2:
	lda #lo(cp_00+char_w*2*8)
	ldx #hi(cp_00+char_w*2*8)

	sta line_cp+1
	stx line_cp+2
	lda #lo(fx_00)
	sta line_cp+4
	lda #hi(fx_00)
	sta line_cp+5
	rts

copy_lines:
	lda #$cc
	jsr raster_sync

next_line macro a
	inc a
	bne +
	inc a+1
+	lda a
	and #7
	bne +
	clc
	lda a
	adc #lo(312)
	sta a
	lda a+1
	adc #hi(312)
	sta a+1
+
	endm

	ldy #char_w
	ldx #0
	clc
line_cp:
	lda cp_00,x
	sta fx_00,x
	txa
	adc #8
	tax
	dey
	bne line_cp
	next_line line_cp+1
	next_line line_cp+4
	rts

color_fade_out:
	lda #$cc
	jsr raster_sync2
	lda #7
	dec *-1
	and #7
	ora #$70
	sta color08
	lda #$11
	sta color0c
	jmp color_it


color_fade_in:
	ldx #0
	inc *-1
	lda #$cc
	jsr raster_sync2
	txa
	eor #$77
	sta color08
	lda #$11
	cpx #8
	bne +
	lda #0
	sta color_fade_in+1
	lda #$01
+	sta color0c

color_it:

	ldx #char_w-1
color08 = *+1
	lda #$70
y	set char_y0
	rept char_h
	sta $0800+y*40+char_x0,x
y	set y+1
	endm
color0c = *+1
	lda #$01
y	set char_y0
	rept char_h
	sta $0c00+y*40+char_x0,x
y	set y+1
	endm
	dex
	bpl color08-1
	rts


zero_out:
	lda #0

	ldx #0
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
	bne ++
	ldx #0
	lda nodes_in+3
	clc
	adc #5
	cmp #12*5
	bne +
	lda #0
+	sta nodes_in+3
+	stx nodes_in+1
	jmp render

node_triags:
	include node_triangs.asm

faces_in:

	lda #0
	ldy #6
	ldx #0
-	sta obj_phases+3,x
	inx
	dey
	bne -
	ldx faces_in+1
	inx
	cpx #8
	bne ++
	ldx #0
	lda - -1
	clc
	adc #9
	cmp #object_count
	bne +
	lda #0
+	sta - -1
+	stx faces_in+1
	jmp render

init_phase1:
	lda #0
	sta phase1+1
	rts

phase1:

	ldy #0
	inc *-1
	ldx #0
-	lda bump_mid-8,y

	sta obj_phases+0,x
	sta obj_phases+1,x
	sta obj_phases+2,x

	lda bump_mid-16,y

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

	ldx #0
	txa
-	sta bumptab,x
	sta bumptab+256,x
;	sta bumptab+512,x
	inx
	bne -
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
	ldy #phase_patt_len
	inc phase2+1
	ldx #0
-	lda phase_patt,y
	sta obj_phases,x
	iny
	inx
	cpx #object_count
	bne -
	jmp render

init_phase_patt:
	ldx #0
-	lda phase_patt_src,x
	sta phase_patt,x
	inx
	cpx #phase_patt_len
	bne -
	lda #0
-	sta phase_patt,x
	inx
	bne -
	rts

phase_patt = bumptab

phase_patt_src:
	byt   1,1,2,2,3,3,4
	byt 4,5,5,6,6,7,7
	byt 7,7,7,7,7,7,7,7
	byt 7,7,7,7,7,7,7,7
	byt 7,7,7,7,7,7,7,7
	byt 7,7,7,7,7,7,7,7
	byt 7,7,7,7,7,7,7,7
	byt 7,7,7,7,7,7,7,7
	byt   7,7,6,6,5,5,4
	byt 4,3,3,2,2,1,1

phase_patt_len = *-phase_patt_src


	if THREED
	include anim3d.asm
	endif
