	align 256
volume_map
	byt $00,$01,$02,$03,$04,$05,$06,$07,$08
	byt $00,$01,$02,$03,$04,$05,$06,$07,$08
	byt $00,$01,$02,$03,$04,$05,$05,$06,$07
	byt $00,$01,$02,$03,$03,$04,$05,$06,$07
	;
	byt $00,$01,$02,$02,$03,$04,$05,$06,$06
	byt $00,$01,$02,$02,$03,$04,$05,$05,$06
	byt $00,$01,$01,$02,$03,$04,$04,$05,$06
	byt $00,$01,$01,$02,$03,$03,$04,$05,$05
	;
	byt $00,$01,$01,$02,$02,$03,$04,$04,$05
	byt $00,$01,$01,$02,$02,$03,$03,$04,$04
	byt $00,$01,$01,$02,$02,$03,$03,$04,$04
	byt $00,$00,$01,$01,$02,$02,$03,$03,$04
	;
	byt $00,$00,$01,$01,$02,$02,$02,$03,$03
	byt $00,$00,$01,$01,$01,$02,$02,$02,$03
	byt $00,$00,$01,$01,$01,$02,$02,$02,$02
	byt $00,$00,$01,$01,$01,$01,$02,$02,$02
	;
	byt $00,$00,$00,$01,$01,$01,$01,$01,$02
	byt $00,$00,$00,$00,$01,$01,$01,$01,$01
	byt $00,$00,$00,$00,$00,$01,$01,$01,$01
	byt $00,$00,$00,$00,$00,$00,$00,$00,$01
	;
	byt $00,$00,$00,$00,$00,$00,$00,$00,$00	; 21
	;
Channel1
	adr pat_intro1
	adr pat_glide
	adr pat_glide
	adr pat_lead
	adr pat_lead
	adr pat_u96
	adr pat_u96
	;
	adr 0
Channel2     
	adr pat_intro2
	adr pat_loop
	adr pat_loop
	adr pat_loop
	adr pat_loop
	adr pat_loop
	adr pat_loop
	adr 0
	
arpeggio
arpCC
	byt 24,12,0,$80
;arp36
;	byt 12,6,6,3,3,0,0,$81
;arp37
;	byt 12,7,7,3,3,0,0,$81
;arp38
;	byt 12,8,8,3,3,0,0,$81
;arp59
;	byt 12,9,9,5,5,0,0,$81

vol_new
	byt 8,7,6,5,4
	byt 7,6,5,4,3
	byt 7,6,5,4,3
	byt 7,6,5,4,3
	;             
	byt $FF

vol_default	
	byt 8,8,8,8,8
	byt 7,7,7,7,7
	byt 7,7,6,6,6
	byt 6,6,6,6,5
	byt 5,5,5,5,5
	byt 5,4,4,4,4
	byt 4,4,4,3,3
	byt 3,3,3,3,3
	byt $FF
	
LEN = $40
VOL = $E0

speed = 5

s_def = $F0
s_arp = $F1
s_bdr = $F2
s_snr = $F3
s_gld = $F4

pat_intro1
	byt $FD
	adr vol_default
	byt $F5,LEN+speed*8,C0,OFF
	byt $F5,LEN+speed*8,C0,OFF
	byt $F5,LEN+speed*8,C0,OFF
	byt $F5,LEN+speed*8,Ci0,OFF
	byt END_MARK
	
pat_intro2
	byt $F0,LEN+speed*8,C0, LEN+speed,C1,Ci1,G1,Gi1,C2,Ci2,G2,Gi2
	byt $F0,LEN+speed*8,C0, LEN+speed,C1,Ci1,G1,Gi1,C2,Ci2,G2,Gi2
	byt $F0,LEN+speed*8,C0, LEN+speed,C1,Ci1,G1,Gi1,C2,Ci2,G2,Gi2
	byt $F0,LEN+speed*8,Ci0,LEN+speed,Ci1,F1,G1,Gi1,Ci2,F2,G2,Gi2
	byt END_MARK

pat_loop
	byt s_bdr,LEN+speed*1,C0
	byt s_def,C0,C0,C0
	byt s_snr,C2
	byt s_def,OFF,OFF
	byt s_bdr,C0
	byt s_def,OFF,OFF
	byt s_bdr,C0     
	byt s_def,OFF    
	byt s_snr,C2         
	byt s_def,OFF,OFF,OFF
	;
	byt s_bdr,C0
	byt s_def,C0,C0,C0
	byt s_snr,C2
	byt s_def,OFF,OFF
	byt s_bdr,C0
	byt s_def,OFF,OFF
	byt s_bdr,C0     
	byt s_def,OFF    
	byt s_snr,C2         
	byt s_def,Ci0,Ci0,Ci0
	;
	byt s_bdr,C0
	byt s_def,C0,C0,C0
	byt s_snr,C2
	byt s_def,OFF,OFF
	byt s_bdr,C0
	byt s_def,OFF,OFF
	byt s_bdr,C0     
	byt s_def,OFF    
	byt s_snr,C2         
	byt s_def,OFF,OFF,OFF
	;
	byt s_bdr,C0
	byt s_def,C0,C0,C0
	byt s_snr,C2
	byt s_def,OFF,OFF
	byt s_bdr,C0
	byt s_def,OFF,OFF
	byt s_bdr,C0     
	byt s_def,OFF    
	byt s_snr,C2         
	byt s_def,Ci0
	byt s_snr,LEN+2,C2,s_def,LEN+speed-2,Ci0
	byt s_snr,LEN+2,C2,s_def,LEN+speed-2,Ci0
	;
	byt END_MARK
	
pat_quiet
	byt s_def
	byt LEN+speed*16
	byt OFF,OFF,OFF,OFF
	byt END_MARK
	
pat_lead
	byt s_arp,LEN+speed*1,C2,OFF,OFF,OFF
	byt                   C2,OFF,OFF,OFF
	byt                   C2,OFF,OFF,OFF
	byt                   C2,OFF
	byt       LEN+speed*2,G2
	;
	byt       LEN+speed*1,C2,OFF,OFF,OFF
	byt                   C2,OFF,OFF,OFF
	byt                   C2,OFF
	byt       LEN+speed*2,G2,Ci2,Di2
	;
	byt       LEN+speed*1,C2,OFF,OFF,OFF
	byt                   C2,OFF,OFF,OFF
	byt                   C2,OFF,OFF,OFF
	byt                   C2,OFF
	byt       LEN+speed*2,G2
	;
	byt       LEN+speed*1,C2,OFF,OFF,OFF
	byt                   C2,OFF,OFF,OFF
	byt       LEN+speed*2,Gi2,G2,Di2,Ci2
	;
	byt END_MARK
	
pat_u96
	byt s_arp,LEN+speed*1,C3,OFF,C3,OFF
	byt                   G2,OFF,G2,OFF
	byt                   Gi2,OFF,G2
	byt       LEN+speed*3,C2
	byt       LEN+speed*2,G2
	;
	byt       LEN+speed*1,C3,OFF,C3,OFF
	byt                   G2,OFF,G2,OFF
	byt                   Gi2,OFF,G2
	byt       LEN+speed*3,C2
	byt       LEN+speed*2,G2
	;
	byt       LEN+speed*1,C3,OFF,C3,OFF
	byt                   G2,OFF,G2,OFF
	byt                   Gi2,OFF,G2
	byt       LEN+speed*3,C2
	byt       LEN+speed*2,Gi2
	;
	byt       LEN+speed*1,Ci3,OFF,Ci3,OFF
	byt                   Gi2,OFF,Gi2,OFF
	byt                   Ci3,OFF,Gi2
	byt       LEN+speed*3,Ci2
	byt       LEN+speed*2,G2
	;
	byt END_MARK

pat_glide
	byt $FD
	adr vol_new
	byt s_gld
	byt LEN+speed*1
	byt C1,G1,C2,C1,G1,C2
	byt C1,G1,C2,C1,G1,C2
	byt Ci1,Gi1,Ci2
	byt s_def,OFF
	;
	byt s_gld
	byt LEN+speed*1
	byt C1,G1,C2,C1,G1,C2
	byt C1,G1,C2,C1,G1,C2
	byt Ci1,Gi1,Ci2,Gi1
	;
	byt s_gld
	byt LEN+speed*1
	byt C1,G1,C2,C1,G1,C2
	byt C1,G1,C2,C1,G1,C2
	byt Ci1,Gi1,Ci2
	byt s_def,OFF
	;
	byt s_gld
	byt LEN+speed*1
	byt C1,G1,C2,C1,G1,C2
	byt C1,G1,C2,Ci1,Gi1,Ci2,Gi1
	byt Ci1,Gi1,Ci2
	;
	byt END_MARK
