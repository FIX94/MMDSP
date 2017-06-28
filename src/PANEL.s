*************************************************************************
*									*
*									*
*	    �w�U�W�O�O�O�@�l�w�c�q�u�^�l�`�c�q�u�f�B�X�v���C		*
*									*
*				�l�l�c�r�o				*
*									*
*									*
*	Copyright (C) 1992 Masao Takahashi				*
*									*
*									*
*************************************************************************


		.include	iocscall.mac
		.include	doscall.mac
		.include	MMDSP.h
		.include	CONTROL.h


*==================================================
* PANEL �\���̒�`
*==================================================

		.offset	0
PNL_ACT		.ds.w	1			*�p�l���̗L���t���O
PNL_X		.ds.w	1			*�p�l���̍���x���W
PNL_Y		.ds.w	1			*     �V     y �V
PNL_LX		.ds.w	1			*�p�l����x�����̑傫��
PNL_LY		.ds.w	1			*   �V   y     �V
PNL_MAKE	.ds.w	1			*�p�l���`��֐�
PNL_EVENT	.ds.w	1			*�C�x���g�����֐�
PNL_DRAG	.ds.w	1			*�h���b�O�����֐�
		.text


*==================================================
* PANEL �e�[�u��
*==================================================

PANEL		.macro	label
		dc.w	label-PANEL_TABLE
		endm

PANEL_TABLE:
		PANEL	CONSOLE_PANEL
		PANEL	GRAPH_PANEL
		PANEL	SPEAMODE_PANEL
		PANEL	SPEASNS_PANEL
		PANEL	LEVELSNS_PANEL
		PANEL	TRMASK_KB_PANEL
		PANEL	TRACKMASK_PANEL
		PANEL	KEYBD_PANEL
		PANEL	LEVEL_PANEL
		PANEL	BG_PANEL
		PANEL	SEL_PANEL
		PANEL	SELAUTO_PANEL
		PANEL	GTONE_PANEL
*		PANEL	PALET_PANEL
*		PANEL	ANIM_PANEL
*		�V���ȃp�l�����쐬����ꍇ�A������
*		�p�l���e�[�u���̃A�h���X��ǉ�����
		dc.w	0


*==================================================
* PANEL �`��
*	�A�N�e�B�u�ȃp�l����`�悷��
*==================================================

PANEL_MAKE:
		movem.l	d0-d2/a0-a2,-(sp)
		lea	PANEL_TABLE(pc),a1
		movea.l	a1,a2

panel_make10:
		move.w	(a1)+,d0
		beq	panel_make90
		lea	(a2,d0.w),a0
		tst.w	PNL_ACT(a0)
		beq	panel_make10
		move.w	PNL_MAKE(a0),d0
		beq	panel_make10
		jsr	(a0,d0.w)
		bra	panel_make10

panel_make90:
		movem.l	(sp)+,d0-d2/a0-a2
		rts


*==================================================
* PANEL �C�x���g����
*	�}�E�X�������ꂽ���̏���������
*==================================================

PANEL_EVENT:
		movem.l	d0-d2/a0-a3,-(sp)
		lea	PANEL_TABLE(pc),a1
		movea.l	a1,a2

panel_event10:
		move.w	MOUSE_X(a6),d1
		move.w	MOUSE_Y(a6),d2
		move.w	(a1)+,d0
		beq	panel_event90

		lea	(a2,d0.w),a3
		tst.w	PNL_ACT(a3)		*�L���`�F�b�N
		beq	panel_event10
		sub.w	PNL_X(a3),d1		*�͈̓`�F�b�N
		bcs	panel_event10
		sub.w	PNL_Y(a3),d2
		bcs	panel_event10
		cmp.w	PNL_LX(a3),d1
		bcc	panel_event10
		cmp.w	PNL_LY(a3),d2
		bcc	panel_event10

		move.w	PNL_EVENT(a3),d0		*�p�l���͈͓��Ȃ�A���̏����֐���
		jsr	(a3,d0.w)
		tst.l	d0
		beq	panel_event90
		move.l	a3,DRAG_FUNC(a6)		*�h���b�O�����֐���o�^����

panel_event90:
		movem.l	(sp)+,d0-d2/a0-a3
		rts


*==================================================
* PANEL �h���b�O����
*	�}�E�X���h���b�O���ꂽ���̏���������
*==================================================

PANEL_DRAG:
		movem.l	d0-d2/a0,-(sp)

		move.w	MOUSE_X(a6),d1
		move.w	MOUSE_Y(a6),d2
		move.l	DRAG_FUNC(a6),d0
		beq	panel_drag90
		movea.l	d0,a0

		tst.w	PNL_ACT(a0)		*�L���`�F�b�N
		beq	panel_drag10
		sub.w	PNL_X(a0),d1
		sub.w	PNL_Y(a0),d2
		move.w	PNL_DRAG(a0),d0
		jsr	(a0,d0.w)
		tst.l	d0
		bne	panel_drag90
panel_drag10:
		clr.l	DRAG_FUNC(a6)		*�h���b�O�����֐�������
panel_drag90:
		movem.l	(sp)+,d0-d2/a0
		rts


*----------------------------------------------------------------------
*�p�l�������֐��Q
*

*���Ԍo�߂��͂���}�N�� - 1.�v���J�n
*	d0.w -> �V�X�e���^�C�}�[�l

TIME_SET	macro
		MYONTIME
		move.w	d0,PANEL_ONTIME(a6)
		endm

*���Ԍo�߂��͂���}�N�� - 2.�o�߃`�F�b�N
*	d0.w -> (�o�ߎ���)-(�ړI����)

TIME_PASS	macro	time
		MYONTIME
		sub.w	PANEL_ONTIME(a6),d0
		endm


*==================================================
* �R���\�[���p�l��
*==================================================

CONSOLE_PANEL:
		.dc.w	1
		.dc.w	232
		.dc.w	23
		.dc.w	176
		.dc.w	26
		.dc.w	CONS_MAKE-CONSOLE_PANEL
		.dc.w	CONS_EVENT-CONSOLE_PANEL
		.dc.w	CONS_DRAG-CONSOLE_PANEL

CONS_MAKE:
		movea.l	#TXTADR+$80*28+34,a0
		bsr	cons_makebar
		addq.w	#5,a0
		bsr	cons_makebar
		addq.w	#5,a0
		bsr	cons_makebar

		movea.l	#TXTADR+$80*28+29,a0			*������
		move.b	#%01111111,(a0)
		move.b	#%01010000,1(a0)
		move.b	#%01111111,$80*16(a0)
		move.b	#%01010000,$80*16+1(a0)
		move.b	#%10000000,d0
		bsr	cons_maketbar

		movea.l	#TXTADR+$80*28+51,a0			*�E����
		move.b	#%00001010,(a0)
		move.b	#%11111110,1(a0)
		move.b	#%00001010,$80*16(a0)
		move.b	#%11111110,$80*16+1(a0)
		move.b	#%00000001,d0
		addq.l	#1,a0
		bsr	cons_maketbar

		lea	CONS_MES(pc),a0
		bsr	TEXT48AUTO
		rts

cons_makebar:
		move.b	#%10101111,(a0)
		move.b	#%10101111,$80*16(a0)
		move.b	#%11101010,1(a0)
		move.b	#%11101010,$80*16+1(a0)
		rts

cons_maketbar:
		moveq	#15-1,d1
cons_maketbar10:
		lea	$80(a0),a0
		move.b	d0,(a0)
		dbra	d1,cons_maketbar10
		rts

*			AC,�l,�w�w,�x�x,����
CONS_MES:	.dc.b	02,00,31,2,0,24,'PLAY',0
		.dc.b	02,00,36,2,0,24,'PAUSE',0
		.dc.b	02,00,41,4,0,24,'STOP',0
		.dc.b	02,00,46,7,0,24,'FADE OUT',0
		.dc.b	02,00,36,5,0,40,'SKIP',0
		.dc.b	02,00,31,2,0,40,'SLOW',0
		.dc.b	02,00,46,4,0,40,'MMDSP QUIT',0
		.dc.b	0
		.even

CONS_EVENT:
		bsr	get_conscmd
		tst.w	d0
		beq	cons_event90

		cmpi.w	#1,d0
		beq	cons_event_play
		cmpi.w	#2,d0
		beq	cons_event_pause
		cmpi.w	#3,d0
		beq	cons_event_stop
		cmpi.w	#4,d0
		beq	cons_event_fade
		cmpi.w	#5,d0
		beq	cons_event_slow
		cmpi.w	#6,d0
		beq	cons_event_skip
		cmpi.w	#8,d0
		beq	cons_event_quit
cons_event90:
		moveq	#0,d0
		rts

cons_event_play:
		ENTER	CMD_PLAY
		bra	cons_event90

cons_event_pause:
		ENTER	CMD_PAUSE
		bra	cons_event90

cons_event_stop:
		ENTER	CMD_STOP
		bra	cons_event90

cons_event_fade:
		ENTER	CMD_FADE
		bra	cons_event90

cons_event_skip:
		moveq	#CMD_SKIP,d0
		bra	cons_event_slow10
cons_event_slow:
		moveq	#CMD_SLOW,d0
cons_event_slow10:
		move.w	d0,PANEL_WORK(a6)
		moveq	#1,d1
		bsr	ENTER_CMD
		TIME_SET
		moveq	#1,d0
		rts

cons_event_quit:
		ENTER	CMD_QUIT
		bra	cons_event90

get_conscmd:
		moveq	#0,d0
		cmpi.w	#160,d1
		bcs	get_conscmd10
		move.w	#159,d1
get_conscmd10:
		ext.l	d1
		divu	#40,d1			*40�h�b�g�Ŋ�����
		swap	d1
		cmpi.w	#15,d1			*���_�̂Ƃ���Ȃ疳��
		bls	get_conscmd90
		swap	d1
		addq.w	#1,d1
		cmpi.w	#9,d2
		bls	get_conscmd80
		cmpi.w	#14,d2			*�Q�s�̊ԂȂ疳��
		bls	get_conscmd90
		addq.w	#4,d1
get_conscmd80:
		move.w	d1,d0
get_conscmd90:
		rts

CONS_DRAG:
		tst.w	MOUSE_L(a6)		*�{�^����������Ă�����A
		beq	cons_drag_end
		TIME_PASS			*0.05sec���Ƃ�
		cmpi.w	#05,d0
		bls	cons_drag90
		move.w	PANEL_WORK(a6),d0	*�X�L�b�v�^�X���[����������
		moveq	#1,d1
		bsr	ENTER_CMD
		TIME_SET
cons_drag90:
		moveq	#1,d0
		rts

cons_drag_end:
		move.w	PANEL_WORK(a6),d0	*�{�^���������ꂽ��A����
		moveq	#0,d1
		bsr	ENTER_CMD
		moveq	#0,d0
		rts


*==================================================
* �O���t�B�b�N�p�l��
*==================================================

GRAPH_PANEL:
		.dc.w	1
		.dc.w	360
		.dc.w	55
		.dc.w	64
		.dc.w	10
		.dc.w	GRAPH_MAKE-GRAPH_PANEL
		.dc.w	GRAPH_EVENT-GRAPH_PANEL
		.dc.w	GRAPH_DRAG-GRAPH_PANEL

GRAPH_MAKE:
		move.l	a1,-(sp)
		moveq	#1,d0
		move.l	#5*$10000+7,d1
		lea	graph_pat1(pc),a0
		movea.l	#TXTADR+45+$80*57,a1
		bsr	PUT_PATTERN
		moveq	#2,d0
		lea	graph_pat2(pc),a0
		bsr	PUT_PATTERN
		move.l	(sp)+,a1
		rts
.if 1
graph_pat1:
	.dc.w	%0000000000000000,%0000000000000000,%0000000011111110,%0000000011111110
	.dc.w	%0000000000000001,%0000000001111101,%0000000010101010,%0000000011111110
	.dc.w	%0000000000000001,%0000000001111101,%0000000011010100,%0000000011111110
	.dc.w	%0000000000000001,%0000000001111101,%0000000010101010,%0000000011111110
	.dc.w	%0000000000000001,%0000000000000001,%0000000011010100,%0000000011111110
	.dc.w	%0000000001111111,%0000000001111111,%0000000000000000,%0000000000000000

graph_pat2:
	.dc.w	%0000111011111110,%0000111011111110,%0000111000000000,%0000111000000000
	.dc.w	%0000101010000010,%0000101010000010,%0000101001010101,%0000101000000001
	.dc.w	%0000101010000010,%0000101010000010,%0000101000101011,%0000101000000001
	.dc.w	%0000101010000010,%0000101010000010,%0000101001010101,%0000101000000001
	.dc.w	%0000101011111110,%0000101011111110,%0000101000101011,%0000101000000001
	.dc.w	%0000111000000000,%0000111000000000,%0000111001111111,%0000111001111111
.else
graph_pat1:
	.dc.w	%0000000000000000,%0000000000000000,%0000111111111110,%0000111111111110
	.dc.w	%0000000000000001,%0000011111111101,%0000101010101010,%0000111111111110
	.dc.w	%0000000000000001,%0000011111111101,%0000110101010100,%0000111111111110
	.dc.w	%0000000000000001,%0000011111111101,%0000101010101010,%0000111111111110
	.dc.w	%0000000000000001,%0000000000000001,%0000110101010100,%0000111111111110
	.dc.w	%0000011111111111,%0000011111111111,%0000000000000000,%0000000000000000

graph_pat2:
	.dc.w	%0000111111111110,%0000111111111110,%0000000000000000,%0000000000000000
	.dc.w	%0000100000000010,%0000100000000010,%0000010101010101,%0000000000000001
	.dc.w	%0000100000000010,%0000100000000010,%0000001010101011,%0000000000000001
	.dc.w	%0000100000000010,%0000100000000010,%0000010101010101,%0000000000000001
	.dc.w	%0000111111111110,%0000111111111110,%0000001010101011,%0000000000000001
	.dc.w	%0000000000000000,%0000000000000000,%0000011111111111,%0000011111111111
.endif

GRAPH_EVENT:
		move.w	d1,d0
		lsr.w	#4,d1
		andi.w	#$0F,d0				*�p�l���̌��Ԃ������疳������
		cmpi.w	#2,d0
		bls	graph_event80
		bsr	SET_GMODE			*�������[�h�Z�b�g
		moveq	#1,d0
		cmp.w	#3,d1				*gonly���[�h�Ȃ�A�h���b�O�p��
		beq	graph_event90
graph_event80:
		moveq	#0,d0
graph_event90:
		rts

GRAPH_DRAG:
		moveq	#1,d0
		tst.w	MOUSE_LC(a6)
		beq	GRAPH_DRAG90
		moveq	#0,d1
		bsr	SET_GMODE
		moveq	#0,d0
GRAPH_DRAG90:
		rts


*==================================================
*�X�y�A�i���[�h�p�l��
*==================================================

SPEAMODE_PANEL:
		.dc.w	1
		.dc.w	229
		.dc.w	149
		.dc.w	205
		.dc.w	10
		.dc.w	0
		.dc.w	SPEAMODE_EVENT-SPEAMODE_PANEL
		.dc.w	0

SPEAMODE_EVENT:
		cmpi.w	#10,d1
		bhi	speamode_event10
		bsr	SPEASUM_CHG			*�ϕ����[�h
		bra	speamode_event90
speamode_event10:
		cmpi.w	#27,d1
		bls	speamode_event90
		cmpi.w	#57,d1
		bhi	speamode_event20
		bsr	SPEAREV_CHG			*���o�[�X���[�h
		bra	speamode_event90
speamode_event20:
		subi.w	#67,d1				*�f�B�X�v���C���[�h
		bcs	speamode_event90
		lsr.w	#5,d1
		ENTER	CMD_SPEAMODE_SET
speamode_event90:
		moveq	#0,d0
		rts


*==================================================
* �X�y�A�i�X�s�[�h�p�l��
*==================================================

SPEASNS_PANEL:
		.dc.w	1
		.dc.w	229
		.dc.w	169
		.dc.w	11
		.dc.w	39
		.dc.w	SPEASNS_MAKE-SPEASNS_PANEL
		.dc.w	SPEASNS_EVENT-SPEASNS_PANEL
		.dc.w	SPEASNS_DRAG-SPEASNS_PANEL

SPEASNS_MAKE:
		movea.l	#BGADR+28*2+$80*21,a0
		bsr	put_snsbar
		rts

put_snsbar:
		move.w	#$012C,(a0)
		move.w	#$012D,$02(a0)
		move.w	#$012C,$80(a0)
		move.w	#$012D,$82(a0)
		move.w	#$012C,$100(a0)
		move.w	#$012D,$102(a0)
		move.w	#$012C,$180(a0)
		move.w	#$012D,$182(a0)
		move.w	#$012C,$200(a0)
		move.w	#$012D,$202(a0)
		rts

SPEASNS_EVENT:
		move.w	d2,d1
		lsr.w	#2,d1
		tst.b	MOUSE_LC(a6)
		bne	speasns_event10
		moveq	#4,d1
speasns_event10:
		bsr	SPEASNS_SET
		moveq	#1,d0
		rts

SPEASNS_DRAG:
		moveq	#0,d0
		tst.b	MOUSE_L(a6)
		beq	speasns_drag90
		move.w	d2,d1
		lsr.w	#2,d1
		cmp.b	SPEA_RANGE(a6),d1
		beq	speasns_drag80
		bsr	SPEASNS_SET
speasns_drag80:
		moveq	#1,d0
speasns_drag90:
		rts


*==================================================
* ���x�����[�^�X�s�[�h�p�l��
*==================================================

LEVELSNS_PANEL:
		.dc.w	1
		.dc.w	229
		.dc.w	241
		.dc.w	11
		.dc.w	39
		.dc.w	LEVELSNS_MAKE-LEVELSNS_PANEL
		.dc.w	LEVELSNS_EVENT-LEVELSNS_PANEL
		.dc.w	LEVELSNS_DRAG-LEVELSNS_PANEL

LEVELSNS_MAKE:
		movea.l	#BGADR+28*2+$80*30,a0
		bsr	put_snsbar
		rts

LEVELSNS_EVENT:
		move.w	d2,d1
		lsr.w	#2,d1
		tst.b	MOUSE_LC(a6)
		bne	levelsns_event10
		moveq	#4,d1
levelsns_event10:
		bsr	LEVELSNS_SET
		moveq	#1,d0
		rts

LEVELSNS_DRAG:
		moveq	#0,d0
		tst.b	MOUSE_L(a6)
		beq	levelsns_drag90
		move.w	d2,d1
		lsr.w	#2,d1
		cmp.b	LEVEL_RANGE(a6),d1
		beq	levelsns_drag80
		bsr	LEVELSNS_SET
levelsns_drag80:
		moveq	#1,d0
levelsns_drag90:
		rts


*==================================================
* �g���b�N�}�X�N�p�l���i�L�[�{�[�h�����j
*==================================================

TRMASK_KB_PANEL:
		.dc.w	1
		.dc.w	0
		.dc.w	0
		.dc.w	24
		.dc.w	318
		.dc.w	0
		.dc.w	TRMASK_KB_EVENT-TRMASK_KB_PANEL
		.dc.w	TRMASK_KB_DRAG-TRMASK_KB_PANEL

TRMASK_KB_EVENT:
		moveq	#0,d0
		ext.l	d2
		divu	#40,d2			*�g���b�N�}�X�N�P���]
		move.w	d2,d1
		add.b	KEYB_TROFST(a6),d1
		cmpi.w	#31,d1
		bhi	trmask_kb_event90
		move.w	d1,PANEL_WORK(a6)
		ENTER	CMD_TRMASK_CHG
		moveq	#1,d0
trmask_kb_event90:
		rts

TRMASK_KB_DRAG:
		moveq	#0,d0
		tst.w	MOUSE_L(a6)
		beq	trmask_kb_drag90
		ext.l	d2
		divu	#40,d2
		move.w	d2,d1
		add.b	KEYB_TROFST(a6),d1
		cmpi.w	#31,d1
		bhi	trmask_kb_drag80
		cmp.w	PANEL_WORK(a6),d1
		beq	trmask_kb_drag80
		move.w	d1,PANEL_WORK(a6)
		ENTER	CMD_TRMASK_CHG
trmask_kb_drag80:
		moveq	#1,d0
trmask_kb_drag90:
		rts


*==================================================
* �g���b�N�}�X�N�p�l���i�o�`�m�����j
*==================================================

TRACKMASK_PANEL:
		.dc.w	1
		.dc.w	228
		.dc.w	288
		.dc.w	284
		.dc.w	16
		.dc.w	0
		.dc.w	TRMASK_EVENT-TRACKMASK_PANEL
		.dc.w	TRMASK_DRAG-TRACKMASK_PANEL

TRMASK_EVENT:
		sub.w	#28,d1			*�}�X�N�ꊇON/OFF/REV
		bhi	trmask_event20
		moveq	#CMD_TRMASK_ALLREV,d0
		tst.b	MOUSE_RC(a6)
		bne	trmask_event10
		moveq	#CMD_TRMASK_ALLON,d0
		cmpi.w	#-14,d1
		blt	trmask_event10
		moveq	#CMD_TRMASK_ALLOFF,d0
trmask_event10:
		bsr	ENTER_CMD
		moveq	#0,d0
		bra	trmask_event90

trmask_event20:
		moveq	#0,d0
		lsr.w	#4,d1			*�g���b�N�}�X�N�P���]
		add.b	LEVEL_TROFST(a6),d1
		cmpi.w	#31,d1
		bhi	trmask_event90
		move.w	d1,PANEL_WORK(a6)
		ENTER	CMD_TRMASK_CHG
		moveq	#1,d0
trmask_event90:
		rts

TRMASK_DRAG:
		moveq	#0,d0
		tst.w	MOUSE_L(a6)
		beq	trmask_drag90

		sub.w	#28,d1
		lsr.w	#4,d1
		add.b	LEVEL_TROFST(a6),d1
		cmpi.w	#31,d1
		bhi	trmask_drag80
		cmp.w	PANEL_WORK(a6),d1
		beq	trmask_drag80
		move.w	d1,PANEL_WORK(a6)
		ENTER	CMD_TRMASK_CHG
trmask_drag80:
		moveq	#1,d0
trmask_drag90:
		rts


*==================================================
* �L�[�{�[�h�p�l��
*==================================================

KEYBD_PANEL:
		.dc.w	1
		.dc.w	24
		.dc.w	0
		.dc.w	224-24
		.dc.w	318
		.dc.w	0
		.dc.w	KEYBD_EVENT-KEYBD_PANEL
		.dc.w	KEYBD_DRAG-KEYBD_PANEL

KEYBD_EVENT:
		bsr	slide_keybd
		TIME_SET
		moveq	#1,d0
		rts

KEYBD_DRAG:
		moveq	#0,d0
		tst.w	MOUSE_L(a6)
		beq	keybd_drag90
		TIME_PASS
		cmpi.w	#25,d0			*���s�[�g�Ԋu0.25sec
		bls	keybd_drag80
		bsr	slide_keybd
keybd_drag80:
		moveq	#1,d0
keybd_drag90:
		rts

slide_keybd:
		moveq	#CMD_KEYBD_UP,d0
		tst.b	MOUSE_L(a6)		*���N���b�N��up�A�E�N���b�N��down
		bne	slide_keybd10
		moveq	#CMD_KEYBD_DOWN,d0
slide_keybd10:
		bsr	ENTER_CMD
		rts


*==================================================
* ���x�����[�^�p�l��
*==================================================

LEVEL_PANEL:
		.dc.w	1
		.dc.w	256
		.dc.w	232
		.dc.w	256
		.dc.w	56
		.dc.w	0
		.dc.w	LEVEL_EVENT-LEVEL_PANEL
		.dc.w	LEVEL_DRAG-LEVEL_PANEL

LEVEL_EVENT:
		moveq	#CMD_LEVELPOS_DOWN,d0
		tst.b	MOUSE_LC(a6)
		bne	level_event20
		moveq	#CMD_LEVELPOS_UP,d0
level_event20:
		bsr	ENTER_CMD
		TIME_SET
		moveq	#1,d0
		rts

LEVEL_DRAG:
		moveq	#0,d0
		tst.w	MOUSE_L(a6)
		beq	level_drag90
		TIME_PASS
		cmpi.w	#25,d0			*���s�[�g�Ԋu0.25sec
		bls	level_drag80
		moveq	#CMD_LEVELPOS_DOWN,d0
		tst.b	MOUSE_L(a6)
		bne	level_drag10
		moveq	#CMD_LEVELPOS_UP,d0
level_drag10:
		bsr	ENTER_CMD
level_drag80:
		moveq	#1,d0
level_drag90:
		rts


*==================================================
* �a�f�p�^�[���p�l��
*==================================================

BG_PANEL:
		.dc.w	1
		.dc.w	312
		.dc.w	72
		.dc.w	112
		.dc.w	16
		.dc.w	BG_MAKE-BG_PANEL
		.dc.w	BG_EVENT-BG_PANEL
		.dc.w	0

BG_MAKE:
		move.l	a1,-(sp)
		lea	bg_makepat(pc),a1
		movea.l	#BGADR+42*2+9*$80,a0
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		lea	bg_makepat(pc),a1
		movea.l	#BGADR+42*2+10*$80,a0
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(a1)+,(a0)+
		move.l	(sp)+,a1
		rts

bg_makepat:
		.dc.w	$0224,$0224,$0000,$0225
		.dc.w	$0225,$0000,$0226,$0226
		.dc.w	$0000,$0227,$0227,$0000

BG_EVENT:
		ext.l	d1
		divu	#24,d1
		cmpi.w	#4,d1
		bhi	bg_event90
		swap	d1			*�p�l���̌��Ԃ������疳������
		cmpi.w	#15,d1
		bhi	bg_event90
		swap	d1
		bsr	BG_SEL
bg_event90:
		moveq	#0,d0
		rts


*==================================================
* �Z���N�^�p�l��
*==================================================

SEL_PANEL:
		.dc.w	1
		.dc.w	0
		.dc.w	342
		.dc.w	512
		.dc.w	154
		.dc.w	0
		.dc.w	SEL_EVENT-SEL_PANEL
		.dc.w	SEL_DRAG-SEL_PANEL

SEL_EVENT:
		subi.w	#12,d2			*�^�C�g���G���A�����̏ꍇ
		bcs	sel_drive
		cmpi.w	#80,d1
		bcc	sel_move
		tst.b	MOUSE_LC(a6)
		bne	sel_event10
		ENTER	CMD_GO_PARENT		*�E�{�^���Őe�ړ�
		bra	sel_event90
sel_event10:
		cmpi.w	#52,d1
		bcc	sel_event20
		move.w	d2,d1
		lsr.w	#4,d1
		ENTER	CMD_SELECTN		*���{�^���ŉ��t�^�f�B���N�g���ړ�
		bra	sel_event90
sel_event20:
		move.w	d2,d1
		lsr.w	#4,d1
		ENTER	CMD_DOCREADN		*���{�^���Ńh�L�������g���[�h

sel_event90:
		moveq	#0,d0
		rts

sel_drive:
		cmpi.w	#6*8,d1
		bcs	sel_playdown
		cmpi.w	#10*8,d1
		bcs	sel_prog
		cmpi.w	#13*8,d1
		bcs	sel_eject
		moveq	#CMD_NEXT_DRIVE,d0	*�㕔�\�������̏ꍇ
		tst.b	MOUSE_LC(a6)		*���{�^���Ŏ��h���C�u�ړ�
		bne	sel_drive10
		moveq	#CMD_PREV_DRIVE,d0	*�E�{�^���őO�h���C�u�ړ�
sel_drive10:
		bsr	ENTER_CMD
		moveq	#0,d0
		rts

sel_move:
		moveq	#CMD_NEXT_LINE,d0	*�^�C�g���G���A�E���̏ꍇ
		tst.b	MOUSE_L(a6)		*���{�^���Ń��[���A�b�v
		bne	sel_move10
		moveq	#CMD_PREV_LINE,d0	*�E�{�^���Ń��[���_�E��
sel_move10:
		bsr	ENTER_CMD
*		TIME_SET
		moveq	#1,d0			*�h���b�O�����ݒ�
		rts

sel_playdown:
		moveq	#CMD_PLAYDOWN,d0
		tst.b	MOUSE_LC(a6)
		bne	sel_playdown10
		moveq	#CMD_PLAYUP,d0
sel_playdown10:
		bsr	ENTER_CMD
		moveq	#0,d0
		rts

sel_prog:
		cmpi.w	#6*8,d1
		bcs	sel_prog90
		moveq	#CMD_PROGMODE_CHG,d0
		cmpi.w	#8*8,d1
		bcs	sel_prog10
		moveq	#CMD_PROG_CLR,d0
sel_prog10:
		bsr	ENTER_CMD
sel_prog90:
		moveq	#0,d0
		rts

sel_eject:
		ENTER	CMD_EJECT
		moveq	#0,d0
		rts

SEL_DRAG:
		moveq	#0,d0
		tst.w	MOUSE_L(a6)
		beq	sel_drag90
*		TIME_PASS
*		cmpi.w	#10,d0			*���s�[�g�Ԋu0.10sec
*		bls	sel_drag80
		moveq	#CMD_NEXT_LINE,d0
		tst.b	MOUSE_L(a6)
		bne	sel_drag10
		moveq	#CMD_PREV_LINE,d0
sel_drag10:
		bsr	ENTER_CMD
sel_drag80:
		moveq	#1,d0
sel_drag90:
		rts



*==================================================
* �Z���N�^�I�[�g�֌W�p�l��
*==================================================

SELAUTO_PANEL:
		.dc.w	1
		.dc.w	0
		.dc.w	496
		.dc.w	512
		.dc.w	16
		.dc.w	0
		.dc.w	SELAUTO_EVENT-SELAUTO_PANEL
		.dc.w	SELAUTO_DRAG-SELAUTO_PANEL

SELAUTO_EVENT:
		cmpi.w	#61*8,d1
		bcc	selat_introtime
		cmpi.w	#58*8,d1
		bcc	selat_blanktime
		cmpi.w	#55*8,d1
		bcc	selat_looptime
		cmpi.w	#53*8,d1
		bcc	selat_event90
		cmpi.w	#50*8,d1
		bcc	selat_prog
		cmpi.w	#47*8,d1
		bcc	selat_alldir
		cmpi.w	#44*8,d1
		bcc	selat_intro
		cmpi.w	#41*8,d1
		bcc	selat_repeat
		cmpi.w	#39*8,d1
		bcc	selat_event90
		cmpi.w	#36*8,d1
		bcc	selat_shuffle
		cmpi.w	#33*8,d1
		bcc	selat_auto
selat_event90:
		moveq	#0,d0
		rts
selat_event_drag:
		TIME_SET
		moveq	#1,d0
		rts


selat_shuffle:
		moveq	#2,d1
		bra	selat_auto10
selat_auto:
		moveq	#1,d1
selat_auto10:
		ENTER	CMD_AUTOMODE_CHG
		bra	selat_event90

selat_repeat:
		moveq	#1,d1
		ENTER	CMD_AUTOFLAG_CHG
		bra	selat_event90

selat_intro:
		moveq	#2,d1
		ENTER	CMD_AUTOFLAG_CHG
		bra	selat_event90

selat_alldir:
		moveq	#4,d1
		ENTER	CMD_AUTOFLAG_CHG
		bra	selat_event90

selat_prog:
		moveq	#8,d1
		ENTER	CMD_AUTOFLAG_CHG
		bra	selat_event90

selat_looptime:
		clr.w	PANEL_WORK(a6)
		bsr	selauto_time
		bra	selat_event_drag

selat_blanktime:
		move.w	#1,PANEL_WORK(a6)
		bsr	selauto_time
		bra	selat_event_drag

selat_introtime:
		move.w	#2,PANEL_WORK(a6)
		bsr	selauto_time
		bra	selat_event_drag

SELAUTO_DRAG:
		moveq	#0,d1
		tst.w	MOUSE_L(a6)		*�}�E�X��������Ă�����I���
		beq	selauto_drag90
		moveq	#1,d1
		TIME_PASS
		cmpi.w	#30,d0			*���s�[�g�Ԋu0.30sec
		bls	selauto_drag90
		bsr	selauto_time		*���l�㉺
selauto_drag90:
		move.l	d1,d0
		rts

selauto_time:
		moveq	#3,d0
		and.w	PANEL_WORK(a6),d0		*�X�C�b�`�̔ԍ���
		add.w	d0,d0
		tst.b	MOUSE_L(a6)			*�}�E�X�{�^���̏�Ԃ���
		beq	selauto_time10
		addq.w	#1,d0
selauto_time10:
		move.b	looptime_cmd(pc,d0.w),d0	*�ݒ肷�ׂ��R�}���h�𓾂�
		bsr	ENTER_CMD
		rts

looptime_cmd:
		dc.b	CMD_LOOPTIME_DOWN
		dc.b	CMD_LOOPTIME_UP
		dc.b	CMD_BLANKTIME_DOWN
		dc.b	CMD_BLANKTIME_UP
		dc.b	CMD_INTROTIME_DOWN
		dc.b	CMD_INTROTIME_UP
		dc.b	CMD_NOP
		dc.b	CMD_NOP
		.even

*==================================================
*�O���t�B�b�N�g�[���p�l��
*==================================================

GTONE_PANEL:
		.dc.w	1
		.dc.w	344
		.dc.w	56
		.dc.w	16
		.dc.w	8
		.dc.w	GTONE_MAKE-GTONE_PANEL
		.dc.w	GTONE_EVENT-GTONE_PANEL
		.dc.w	GTONE_DRAG-GTONE_PANEL

GTONE_MAKE:
		move.l	a1,-(sp)
		move.l	#$00060001,d1
		lea	gtone_pat(pc),a0
		movea.l	#TXTADR1+43+56*$80,a1
		bsr	PUT_PATTERN_OR
		move.l	(sp)+,a1
		rts

gtone_pat:
		.dc.w	%0000000000011000
		.dc.w	%0111111100111000
		.dc.w	%0100001001111000
		.dc.w	%0100010011111000
		.dc.w	%0100100111111000
		.dc.w	%0101001111111000
		.dc.w	%0100000000000000

GTONE_EVENT:
		bsr	gtone_move
		moveq	#1,d0
		rts

GTONE_DRAG:
		moveq	#0,d0
		tst.w	MOUSE_L(a6)
		beq	gtone_drag90
		bsr	gtone_move
		moveq	#1,d0
gtone_drag90:
		rts

gtone_move:
		tst.b	MOUSE_L(a6)
		beq	gtone_move10
		bsr	GTONE_DOWN
		bra	gtone_move90
gtone_move10:
		bsr	GTONE_UP
gtone_move90:
		rts

.if 0
*==================================================
* �p���b�g�p�l��
*==================================================

PALET_PANEL:
		.dc.w	1
		.dc.w	328
		.dc.w	96
		.dc.w	80
		.dc.w	20
		.dc.w	PALET_MAKE-PALET_PANEL
		.dc.w	PALET_EVENT-PALET_PANEL
		.dc.w	PALET_DRAG-PALET_PANEL

PALET_MAKE:
		movea.l	#BGADR+44*2+12*$80,a0
		move.w	#$0B6D,(a0)
		move.w	#$0B6D,$80(a0)
		bsr	read_palet
		rts

PALET_EVENT:
		cmpi.w	#16,d1
		bhi	palet_change
		moveq	#1,d0
		move.w	#$0f,d2
		cmpi.w	#7,d1
		bhi	palet_event10
		moveq	#$10,d0
		move.w	#$f0,d2
palet_event10:
		lea	palet_block(pc),a0
		tst.b	MOUSE_LC(a6)
		bne	palet_event20
		neg.w	d0
palet_event20:
		add.w	(a0),d0
		and.w	d2,d0
		not.w	d2
		and.w	d2,(a0)
		or.w	d0,(a0)
palet_event90:
		bsr	read_palet
		moveq	#0,d0
		rts
palet_event_drag:
		TIME_SET
		moveq	#1,d0
		rts

palet_change:
		subi.w	#32,d1
		bcs	palet_event90
		moveq	#1,d0			*BLUE shift
		cmpi.w	#31,d1
		bhi	palet_change10
		moveq	#11,d0			*GREEN shift
		cmpi.w	#15,d1
		bhi	palet_change10
		moveq	#6,d0			*RED shift
palet_change10:
		move.w	d0,PANEL_WORK(a6)
		bsr	move_palet
		bra	palet_event_drag


PALET_DRAG:
		moveq	#0,d0
		tst.w	MOUSE_L(a6)
		beq	palet_drag_end
		TIME_PASS
		cmpi.w	#25,d0			*���s�[�g�Ԋu0.25sec
		bls	palet_drag90
		bsr	move_palet
palet_drag90:
		moveq	#1,d0
palet_drag_end:
		rts


move_palet:
		move.w	palet_block(pc),d0
		add.w	d0,d0
		movea.l	#SPPALADR,a0
		adda.w	d0,a0
		move.w	(a0),d1
		move.w	PANEL_WORK(a6),d2
		ror.w	d2,d1
		move.w	d1,d0
		andi.w	#%0_00000_00000_11111,d0
		andi.w	#%1_11111_11111_00000,d1
		addq.w	#1,d0
		tst.b	MOUSE_L(a6)		*�����^����
		bne	move_palet10
		subq.w	#2,d0
move_palet10:
		cmpi.w	#31,d0
		bhi	move_palet20
		or.w	d0,d1
		rol.w	d2,d1
		move.w	d1,(a0)
move_palet20:
		bsr	read_palet
		rts

read_palet:
		movem.l	d0-d2/a0-a1,-(sp)
		movea.l	#SPPALADR,a1
		movea.l	#BGADR+41*2+12*$80,a0
		moveq	#2,d1
		move.w	palet_block(pc),d0
		bsr	DIGIT16
		add.w	d0,d0
		move.w	(a1,d0.w),d0
		move.w	d0,$0B*32+$0F*2(a1)

		movea.l	#BGADR+45*2+12*$80,a1
		moveq	#2,d1
		move.w	d0,d2
		lsr.w	#1,d2			*BLUE
		move.w	d2,d0
		andi.w	#31,d0
		lea	4*2(a1),a0
		bsr	DIGIT10
		lsr.w	#5,d2			*RED
		move.w	d2,d0
		andi.w	#31,d0
		lea	(a1),a0
		bsr	DIGIT10
		lsr.w	#5,d2			*GREEN
		move.w	d2,d0
		andi.w	#31,d0
		lea	2*2(a1),a0
		bsr	DIGIT10

		movem.l	(sp)+,d0-d2/a0-a1
		rts

palet_block:	.dc.w	0
.endif


.if 0		*�܂�����ō폜�E�E�E�E(:_;)
		*�d���Ȃ��Ɖ�ʂɃm�C�Y���ł��
*==================================================
* �p���b�g�A�j���p�l��
*==================================================

ANIM_PANEL:
		.dc.w	1
		.dc.w	320
		.dc.w	104
		.dc.w	96
		.dc.w	16
		.dc.w	ANIM_MAKE-ANIM_PANEL
		.dc.w	ANIM_EVENT-ANIM_PANEL
		.dc.w	0

ANIM_MAKE:
		movea.l	#BGADR+42*2+12*$80,a0
		move.w	#$0A74,d0
		move.w	#$CA7D,d1
		moveq	#10-1,d2
anim_make10:
		move.w	d1,$80(a0)
		move.w	d0,(a0)+
		addq.w	#1,d0
		subq.w	#1,d1
		dbra	d2,anim_make10
		rts

ANIM_EVENT:
		moveq	#0,d0
		rts

.endif

		.end


-------------------------------------------------------------------------------
�E�o�`�m�d�k�����֐��̍쐬���@�ɂ���

  �p�l�������֐��̐擪�ŁA���̂悤�ȃp�l���e�[�u�����`����B�i�ʃ\�[
�X�̏ꍇ�͐擪�A�h���X�� PANEL.o ����Q�Əo����悤�ɐ錾���Ă����j��
���āA�擪�A�h���X�����̃\�[�X���� PANEL_TABLE �ɒǉ�����B

	.xdef CONSOLE_PANEL

FUNC	macro	entry
	.dc.w	entry-CONSOLE_PANEL
	endm

CONSOLE_PANEL:
	dc.w	1			*�p�l���L���t���O
	dc.w	100			*�p�l���̍���x���W
	dc.w	100			*     �V     y �V
	dc.w	50			*�p�l����x�����̑傫��
	dc.w	40			*   �V   y     �V
	FUNC	CONS_MAKE		*�p�l���`��֐�
	FUNC	CONS_EVENT		*�C�x���g�����֐�
	FUNC	0			*�h���b�O�����֐�(�Ȃ�)

  �p�l���`��֐��́A���̃e�[�u���ɏ�����Ă�����W�����ɉ�ʂ��쐬����
�̂��]�܂������A���݂̓p�l���̈ړ����s�Ȃ�Ȃ��̂ŁA���̕K�v�͂Ȃ��B

  �C�x���g�����֐��́A�}�E�X���N���b�N���ꂽ���ɌĂ΂��B���̎��Ad1.w
�ɂ̓p�l���̍��ォ���x���W�Ad2.w�ɂ�y���W�������Ă���B�C�x���g������
�������Ń}�E�X�̏�Ԃ��Q�Ƃ���ꍇ�A�ȉ��̃��[�N�G���A���g�p�ł���B

	MOUSE_X:	.ds.w	1	*�}�E�Xx���W
	MOUSE_Y:	.ds.w	1	*�}�E�Xy���W
	MOUSE_L:	.ds.b	1	*���{�^�����(on:$FF off:$00)
	MOUSE_R:	.ds.b	1	*�E�{�^�����(on:$FF off:$00)
	MOUSE_LC:	.ds.b	1	*���{�^���N���b�N�t���O(click:$FF no change:$00)
	MOUSE_RC:	.ds.b	1	*�E�{�^���N���b�N�t���O(click:$FF no change:$00)

  �C�x���g�����֐��̖߂�l(d0)��0�ȊO���w�肷��ƁA���񂩂��VDISP����
���ݏ���������x�ɂ��̃p�l���̃h���b�O�����֐����Ă΂��B�h���b�O����
�֐��� d0.l��0��Ԃ��΁A���̏�Ԃ͉��������B

  �p�l���`��֐��y�уh���b�O�����֐��͏ȗ��ł���(�e�[�u����0������)���A
�C�x���g�����֐������͎��̂�(���Ƃ�rts�݂̂ł�)�p�ӂ��Ȃ��Ă͂Ȃ�Ȃ��B

  �Ȃ��A�e�����֐��́Ad0-d2/a0 �ȊO�̃��W�X�^��j�󂵂Ă͂Ȃ�Ȃ��B

-------------------------------------------------------------------------------

