*************************************************************************
*									*
*									*
*	    �w�U�W�O�O�O�@�l�w�c�q�u�^�l�`�c�q�u�f�B�X�v���C		*
*									*
*				�l�l�c�r�o				*
*									*
*									*
*	Copyright (C) 1991,1992 Kyo Mikami.  All Rights Reserved.	*
*									*
*	Modified Masao Takahashi					*
*									*
*************************************************************************


		.include	iocscall.mac
		.include	doscall.mac
		.include	MMDSP.h
		.include	SELECTOR.h
		.include	DRIVER.h
		.include	FILES.h


INIT_MODE	equ	0				*�Z���N�^�X�e�[�^�X�l
KENS_MODE	equ	1
FSEL_MODE	equ	2
IDLE_MODE	equ	3

			.text
			.even


*==================================================
*�Z���N�^������
*==================================================

SELECTOR_INIT:
		rts

*==================================================
*�Z���N�^�[��ʂ����
*==================================================

SELECTOR_MAKE:
		movem.l	d0-d2/a0-a1,-(sp)

		movea.l	#BGADR+0*2+43*$80,a0		*�㕔�o�[
		move.w	#$16d,d0
		moveq.l	#63,d1
		bsr	BG_LINE

		movea.l	#BGADR+5*2+42*$80,a1		*�㕔�X�C�b�`��`��
		lea	switch_chr1u(pc),a0
		move.w	#$0100,d0
		bsr	BG_PRINT
		lea	$80(a1),a1
		lea	switch_chr1d(pc),a0
		bsr	BG_PRINT

		moveq	#0,d1
		bsr	PROGMODE_SET

		movea.l	#BGADR+0*2+45*$80,a0		*�_��
		move.w	#$16f,d0
		moveq.l	#63,d1
		moveq.l	#8,d2
selector_make10:
		bsr	BG_LINE
		lea.l	$100(a0),a0
		dbra	d2,selector_make10

		move.l	#BGADR2+0*2+62*$80,a0		*�����o�[
		move.w	#$16c,d0
		moveq.l	#63,d1
		bsr	BG_LINE
		lea.l	$80(a0),a0
		move.w	#$16d,d0
		bsr	BG_LINE

		movea.l	#BGADR2+32*2+62*$80,a1		*�����X�C�b�`��`��
		lea	switch_chr2(pc),a0
		move.w	#$0100,d0
		bsr	BG_PRINT
		lea	$80(a1),a1
		move.w	#$0101,d0
		bsr	BG_PRINT

		moveq	#1,d1
		bsr	LOOPTIME_SET

		moveq	#2,d1
		bsr	BLANKTIME_SET

		moveq	#10,d1
		bsr	INTROTIME_SET

		move.l	#$00020002,d0			*�r�d�k�d�b�s�n�q�̕���
		move.l	#9*$10000+9,d1
		lea.l	STITLE(pc),a0
		move.l	#TXTADR+0+(499+1)*$80,a1
		bsr	PUT_PATTERN

		lea.l	FILESEL_MES(pc),a0		*�e�L�X�g�̕����\��
		bsr	TEXT48AUTO

		bsr	INIT_FNAMEBUF
		clr.b	DRV_TBLFLAG(a6)

		lea.l	G_MES_DEF(pc),a0		*�f�t�H���g�̃��b�Z�[�W��\������
		bsr	G_MESSAGE_PRT2
		clr.w	G_MES_FLAG(a6)

		tst.b	SEL_NOUSE(a6)			*�Z���N�^���g�p���[�h�Ȃ�
		beq	selector_make80
		move.w	#IDLE_MODE,SEL_CHANGE(a6)	*�A�C�h�����O���[�`���Z�b�g
		bra	selector_make90

selector_make80:
		move.b	AUTOMODE(a6),d1
		bsr	AUTOMODE_SET
		move.b	AUTOFLAG(a6),d1
		bsr	AUTOFLAG_SET

selector_make90:
		movem.l	(sp)+,d0-d2/a0-a1
		rts

*�X�C�b�`��BG�L����
*__ST		equ	$74	't' 'u'
*__ED		equ	$76	'v' 'w'
*__SP		equ	$6C	'l' 'm'
*__ST2		equ	$2e	'.'
*__ED2		equ	$2f	'/'
*__SP2		equ	$70	'p'

switch_chr1u:	.dc.b	'/././.p/.',0
switch_chr1d:	.dc.b	'wuwuwumwu',0

switch_chr2:	.dc.b	'v','tlv','tlv'
		.dc.b	'tv'
		.dc.b	'tlv','tlv','tlv','tlv'
		.dc.b	'tv'
		.dc.b	'tlv','tlv','tlv'
		.dc.b	0
		.even


*==================================================
*�h���C�u��ԃe�[�u���̍쐬
*	DRV_TBL[26]	�h���C�u A - Z
*		bit8 : 0:�g�p�\ 1:�g�p�s��
*		bit7�`3 :���j�b�g�ԍ�
*		bit1 : 0:2HD�ȊO 1:2HD�h���C�u
*		bit0 : 0:���f�B 1:�m�b�g���f�B
*==================================================

MAKE_DRVTBL:
		movem.l	d0-d2/d7/a0,-(sp)
		link	a5,#-96
		tst.b	DRV_TBLFLAG(a6)
		bne	make_drvtbl90
		st.b	DRV_TBLFLAG(a6)

		lea	DRV_TBL(a6),a0
		moveq	#1,d1
		moveq	#26-1,d7
make_drvtbl10:
		move.w	d1,-(sp)		*�g�p�\���ǂ������ׂ�
		DOS	_DRVCTRL
		addq.l	#2,sp
		tst.l	d0
		bmi	make_drvtbl11
		btst	#2,d0
		sne	d2
		andi.b	#$01,d2
		pea	-96(a5)			*2HD�h���C�u���ǂ������ׂ�
		move.w	d1,-(sp)
		DOS	_GETDPB
		addq.l	#6,sp
		move.b	-96+1(a5),d0		*���j�b�g�ԍ�
		andi.b	#$1f,d0
		lsl.b	#3,d0
		or.b	d0,d2
		move.b	-96+22(a5),d0		*���f�B�AID
		cmpi.b	#$fe,d0
		seq	d0
		andi.b	#$02,d0
		or.b	d2,d0
		move.b	d0,(a0)+
		bra	make_drvtbl12
make_drvtbl11:
		move.b	#$81,(a0)+		*�g�p�s��
make_drvtbl12:
		addq.w	#1,d1
		dbra	d7,make_drvtbl10
make_drvtbl90:
		unlk	a5
		movem.l	(sp)+,d0-d2/d7/a0
		rts

*�Q�l:���̏����͂܂�����Ă��Ȃ�
*	DOS _GETDPB�ɂ���āA�h���C�u�p�����[�^�[�u���b�N�𓾂�
*	DPBPTR+$16�̃��f�B�A�o�C�g��$FE,$FD,$FC,$FB,$FA�Ȃ�
*	����͂e�c�ł���Ƃ킩��B
*	�i�Q�l�F���f�B�A�o�C�g�j
*		$FE	:	�e�c
*		$FA	:	�e�c�i�Q�c�c�W�Z�N�^�j
*		$FB	:	�e�c�i�Q�c�c�X�Z�N�^�j
*		$FC	:	�e�c�i�Q�g�c�P�W�Z�N�^�j
*		$FD	:	�e�c�i�Q�g�c�P�T�Z�N�^�j


*==================================================
*�@�\�F�h���C�u���g�p�\�����ׂ�
*	d0.w <- ���ׂ�h���C�u
*	d0.l -> _DRVCTRL�̌���(���Ȃ�G���[) ccr�ɂ��Ԃ�
*==================================================

DRIVE_CHECK:
		move.w	d0,-(sp)
		DOS	_DRVCTRL
		addq.l	#2,sp
		tst.l	d0
		bmi	drivechk_done
		btst.l	#2,d0			*NOT READY
		beq	drivechk_done
		bset.l	#31,d0
drivechk_done:
		tst.l	d0
		rts

*==================================================
*�f�B�X�N�C�W�F�N�g���o
*	d0.l -> 0�ȊO�Ȃ�}���^�C�W�F�N�g���ꂽ
*		����1byte��DRV_TBL�Ɠ���
*==================================================

EJECT_CHECK:
		movem.l	d1-d2/a0-a1,-(sp)
		moveq	#0,d2

		MYONTIME		*.5�b���Ƀ`�F�b�N����
		lea	EJECT_ONTIME(pc),a0
		sub.w	(a0),d0
		cmpi.w	#50,d0
		bls	eject_check90
		add.w	d0,(a0)
eject_check10:
		move.b	CURRENT(a6),d1
		andi.w	#$00df,d1
		subi.w	#'A',d1
		lea	DRV_TBL(a6),a0
		lea	(a0,d1.w),a1
		move.b	(a1),d1
		btst	#1,d1
		bne	eject_check15
		clr.w	-(sp)			*(2HD�ȊO)
		DOS	_DRVCTRL
		addq.l	#2,sp
		btst	#2,d0
		sne	d0
		bra	eject_check20
eject_check15:					*(2HD)
		lea	$9e6.w,a0
		move.b	d1,d0
		lsr.b	#2,d0
		andi.w	#$0006,d0
		tst.w	(a0,d0.w)
		spl	d0
eject_check20:
		eor.b	d0,d1
		btst	#0,d1
		beq	eject_check90
		bchg.b	#0,(a1)
		moveq	#-1,d2
		move.b	d0,d2
eject_check90:
		move.l	d2,d0
		movem.l	(sp)+,d1-d2/a0-a1
		rts

EJECT_ONTIME:	.dc.w	0


*==================================================
*�J�����g�h���C�u�C�W�F�N�g�֎~
*==================================================

LOCK_DRIVE:
		move.l	d0,-(sp)
		tst.b	LOCKDRIVE(a6)		*���b�N����Ă���h���C�u����������
		beq	lock_drive10
		bsr	UNLOCK_DRIVE		*�A�����b�N����
lock_drive10:
		move.b	CURRENT(a6),d0		*�J�����g�h���C�u�����߂�
		andi.w	#$00df,d0
		subi.w	#'A',d0
		addq.w	#1,d0
		move.b	d0,LOCKDRIVE(a6)	*���b�N�h���C�u�ԍ����Z�b�g
		ori.w	#$0200,d0		*MD=2:EJECT�֎~
		move.w	d0,-(sp)
		DOS	_DRVCTRL
		addq.l	#2,sp
		move.l	(sp)+,d0
		rts


*==================================================
*���b�N�����h���C�u�̃C�W�F�N�g������
*==================================================

UNLOCK_DRIVE:
		move.l	d0,-(sp)
		moveq	#0,d0
		move.b	LOCKDRIVE(a6),d0
		ori.w	#$0300,d0		*MD=3:EJECT����
		move.w	d0,-(sp)
		DOS	_DRVCTRL
		addq.l	#2,sp
		clr.b	LOCKDRIVE(a6)
		move.l	(sp)+,d0
		rts


*==================================================
*�Z���N�^���C�����[�`��
*==================================================

SELECTOR_MAIN:
		movem.l	d0-d7/a0-a5,-(sp)
		tst.b	SEL_NOUSE(a6)
		bne	selector_done

		bsr	G_MESSAGE_WAIT			*���b�Z�[�W���ԑ҂��N���A
		bsr	EJECT_CHECK			*�f�B�X�N�̏�Ԃ��ω�������
		bpl	selector_main01
		btst	#0,d0
		beq	selector_main00
		bsr	INIT_FNAMEBUF			*�C�W�F�N�g�Ȃ�o�b�t�@�N���A
selector_main00:
		clr.w	SEL_CHANGE(a6)			*init���[�h�ֈڍs����

selector_main01:
		move.w	SEL_CHANGE(a6),d0		*���[�h�ύX�H
		bmi	selector_main10
		move.w	d0,SEL_STAT(a6)
		move.w	#-1,SEL_CHANGE(a6)

selector_main10:
		move.w	SEL_STAT(a6),d0
		and.w	#7,d0
		lsl.w	#2,d0
		jmp	selector_jtop(pc,d0.w)		*��ԕʂŃW�����v�����I

selector_jtop:	bra.w	selmode_init
		bra.w	selmode_kens
		bra.w	selmode_tsel
		bra.w	selmode_idle
		bra.w	selmode_idle
		bra.w	selmode_idle
		bra.w	selmode_idle
		bra.w	selmode_idle

selector_done:
		movem.l	(sp)+,d0-d7/a0-a5
		rts


*==================================================
*�A�C�h�����O���
*==================================================

selmode_idle:
		bra	selector_done


*==================================================
*�������
*==================================================

selmode_init:
		bsr	MAKE_DRVTBL

		lea	CURRENT(a6),a0
		bsr	GET_CURRENT
		bsr	PRINT_CURDIR			*�J�����g�p�X���\��

selmode_init10:
		bsr	LOCK_DRIVE			*�h���C�u�����b�N����
		bsr	FNAME_SET			*�J�����g�f�B���N�g����o�^
		tst.l	d0
		bpl	selmode_init20

		lea.l	G_MES_No5(pc),a0		*�u�o�b�t�@�����ӂ�܂����v
		bsr	G_MESSAGE_PRT

		bsr	INIT_FNAMEBUF
		bsr	UNLOCK_DRIVE			*���b�N�h���C�u����������
		bra	selector_done

selmode_init20
		movea.l	d0,a0
		bsr	SET_SELECTOR			*�Z���N�^������
		bsr	REF_SELECTOR			*�Z���N�^�\��

		movea.l	SEL_HEAD(a6),a0			*�^�C�g���������������Ă�����
		tst.b	KENS_FLAG(a0)
		beq	selmode_init30
		clr.b	SEL_SRC_F(a6)
		bsr	UNLOCK_DRIVE			*���b�N�h���C�u����������
		move.w	#FSEL_MODE,SEL_CHANGE(a6)	*���̓Z���N�g����
		bra	selector_done

selmode_init30:
							*�܂��^�C�g���������c���Ă�����
*		lea.l	G_MES_No1(pc),a0		*�u�������ł��v
*		bsr	G_MESSAGE_PRT
*		clr.w	G_MES_FLAG(a6)
		st.b	SEL_SRC_F(a6)
		move.w	#KENS_MODE,SEL_CHANGE(a6)	*���͌�������
		bra	selector_done


*==================================================
*�^�C�g��������
*==================================================

selmode_kens:
		bsr	SELECT_MAIN			*�Z���N�^�R�}���h���s
		tst.w	SEL_CHANGE(a6)
		bpl	selector_done

selmode_kens10:
		tst.l	d0				*�L�[���͂���������A
		bmi	selmode_kens19
		MYONTIME
		move.w	d0,SEL_TIME(a6)
*		lea.l	G_MES_No2(pc),a0		*�u�����𒆒f���܂����v
*		bsr	G_MESSAGE_PRT
		move.w	#FSEL_MODE,SEL_CHANGE(a6)
		bra	selector_done			*�Z���N�g��
selmode_kens19:

selmode_kens20:
		bsr	SEARCH_TITLE			*�^�C�g���ǂݍ���
		tst.l	d0
		bpl	selmode_kens29			*�����I��������A
		clr.b	SEL_SRC_F(a6)
		movea.l	SEL_HEAD(a6),a0			*�����I���t���O���Z�b�g
		st.b	KENS_FLAG(a0)
		bsr	UNLOCK_DRIVE			*���b�N�h���C�u����������
*		lea.l	G_MES_No4(pc),a0		*�u�������I�����܂����v
*		bsr	G_MESSAGE_PRT
		move.w	#FSEL_MODE,SEL_CHANGE(a6)
		bra	selector_done			*�Z���N�g��
selmode_kens29:

selmode_kens30:
		tst.b	SEL_VIEWMODE(a6)		*�t�@�C���Z���N�g���[�h��
		bne	selmode_kens39
		sub.w	SEL_BPRT(a6),d0			*���\���͈͓�
		cmpi.w	#8,d0
		bhi	selmode_kens31
		bsr	TITLE_CLR1			*�Ȃ�Ε\��
		bsr	TITLE_PRT1
selmode_kens31:
*		bsr	TITLE_PRT2			*�\���͈͊O�Ȃ�Εʏꏊ��
selmode_kens39:
		bra	selector_done			*�܂�����


*==================================================
*�t�@�C���Z���N�g��
*==================================================

selmode_tsel:
		bsr	SELECT_MAIN
		tst.w	SEL_CHANGE(a6)
		bpl	selector_done

		tst.l	d0				*�L�[���͂���������A
		bmi	select_tsel_j0

		MYONTIME
		move.w	d0,SEL_TIME(a6)
		bra	selector_done			*���ǂ��

select_tsel_j0:
		tst.b	SEL_SRC_F(a6)			*������������Ƃ��A
		beq	selector_done

		MYONTIME
		sub.w	SEL_TIME(a6),d0
		cmpi.w	#30,d0				*0.3�b�L�[���͂�
		bcs	selector_done			*�Ȃ�������

*		lea.l	G_MES_No3(pc),a0		*�u�������ĊJ���܂��v
*		bsr	G_MESSAGE_PRT
*		clr.w	G_MES_FLAG(a6)

		move.w	#KENS_MODE,SEL_CHANGE(a6)	*�������[�h��
		bra	selector_done


*==================================================
*�������t���C��
*==================================================

selector_auto:
		tst.b	AUTOMODE(a6)
		beq	selector_auto90

		tst.w	STAT_OK(a6)
		beq	selector_auto90
		tst.w	PLAYEND_FLAG(a6)
		bne	selector_auto20			*���t���Ȃ�
selector_auto10:
		clr.w	BLANK(a6)
		btst.b	#1,AUTOFLAG(a6)			*�C���g�����[�h�Ŏ��Ԃ𒴂����Ȃ�
		beq	selector_auto11
		move.w	SYS_PASSTM(a6),d0
		cmp.w	INTRO_TIME(a6),d0
		blt	selector_auto90
		bsr	PLAY_NEXT			*���̋Ȃ����t����
		bra	selector_auto90
selector_auto11:
		move.w	SYS_LOOP(a6),d0			*���[�v�񐔂��K��l�ȏ�Ȃ�
		cmp.w	LOOP_TIME(a6),d0
		blt	selector_auto90
		DRIVER	DRIVER_FADEOUT			*�t�F�[�h�A�E�g����
		bra	selector_auto90

selector_auto20:					*��~���Ȃ�
		move.w	BLANK(a6),d0			*�ȊԎ��Ԃ𒴂������܂���
		cmp.w	BLANK_TIME(a6),d0
		bcc	selector_auto21
		addq.w	#1,BLANK(a6)
		btst.b	#1,AUTOFLAG(a6)			*�C���g�����[�h�Ȃ�
		beq	selector_auto90
selector_auto21:
		bsr	PLAY_NEXT			*���̋Ȃ����t����
selector_auto90:
		rts


*==================================================
*���̋Ȃ����t����iAUTO/SHUFFLE���[�h�p�j
*==================================================

PLAY_NEXT:
		movem.l	d0-d1,-(sp)

play_next10:
		cmpi.b	#2,AUTOMODE(a6)		*AUTO���[�h
		beq	play_next20
		bsr	search_next_auto	*���̗L���ȋȂ�������
		bmi	play_next_err		*����������AAUTO���[�h����
		move.w	d0,d1			*�L������A���t����
		bra	play_next_ok

play_next20:
		bsr	search_next_shuffle	*SHUFFLE���[�h
		bpl	play_next21
		btst.b	#0,AUTOFLAG(a6)		*��x������Ȃ��Ă��A���s�[�g���[�h�Ȃ�
		beq	play_next_err
		addq.b	#1,SHUFFLE_CODE(a6)	*�V���t���l��ύX����
		bsr	search_next_shuffle	*������x�T��
		bmi	play_next_err		*����ł�������Ȃ���΁A���[�h����
play_next21:
		move.w	d0,d1

play_next_ok:
		bsr	play_data		*���t����
		bra	play_next90

play_next_err:
		DRIVER	DRIVER_FADEOUT
		moveq	#0,d1
		bsr	AUTOMODE_SET

play_next90:
		movem.l	(sp)+,d0-d1
		rts

.if 0
put_debugpos:
		movem.l	d0-d1/a0,-(sp)
		movea.l	#BGADR+40*2+16*$80,a0
		moveq	#4,d1
		bsr	DIGIT16
		movem.l	(sp)+,d0-d1/a0
		rts
.endif

*==================================================
*�f�B���N�g�����ړ����A���t����iAUTO/SHUFFLE���[�h�p�j
*	d1.w <- �t�@�C���ԍ�
*==================================================

play_data:
		bsr	search_header
		move.w	d1,PAST_POS(a0)
		movea.l	PATH_ADR(a0),a0		*�J�����g�f�B���N�g����ύX��
		bsr	CHANGE_DIR
		move.w	d1,d0
		bsr	get_fnamebuf
		cmpi.b	#2,AUTOMODE(a6)		*SHUFFLE���[�h�Ȃ�
		bne	play_data10		*SHUFFLE�t���O�Z�b�g
		tst.b	(a0)			*���y�f�[�^����Ȃ���Ζ���
		ble	play_data10
		move.b	SHUFFLE_CODE(a6),SHUFFLE_FLAG(a0)
play_data10:
		bsr	PLAY_MUSIC		*���t����
play_data90:
		rts


.if 0		*�����o�b�t�@�\���i�f�o�b�O�p�j
debug:
		movem.l	d0/a0,-(sp)
		move.l	#BGADR+0*2+44*$80,a0

*
		move.w	SEL_FMAX(a6),d0
		bsr	PRINT10_5KETA
		addq.l	#6,a0
*
		move.w	SEL_BTOP(a6),d0
		bsr	PRINT10_5KETA
		addq.l	#6,a0
*
		move.w	SEL_BMAX(a6),d0
		bsr	PRINT10_5KETA
		addq.l	#6,a0
*
		move.w	SEL_BPRT(a6),d0
		bsr	PRINT10_5KETA
		addq.l	#6,a0
*
		move.w	SEL_BSCH(a6),d0
		bsr	PRINT10_5KETA
		addq.l	#6,a0
*
		move.w	SEL_FCP(a6),d0
		bsr	PRINT10_5KETA
		addq.l	#6,a0
*
		move.w	SEL_CUR(a6),d0
		bsr	PRINT10_5KETA
		addq.l	#6,a0
*
		movem.l	(sp)+,d0/a0
		rts
.endif

*==================================================
*�J�����g�h���C�u�p�X���\��
*==================================================

PRINT_CURDIR:
		movem.l	d0-d1/a0-a1,-(sp)

		bsr	OVER_RIGHT_CLR

		movea.l	#TXTADR+344*$80+46,a1	*�\���ʒu����
		lea	CURRENT(a6),a0
		moveq	#0,d0
print_curdir10:
		addq.w	#1,d0
		tst.b	(a0)+
		bne	print_curdir10
		lsr.w	#1,d0
		subi.w	#18,d0
		bls	print_curdir30
		cmpi.w	#12,d0
		bls	print_curdir20
		moveq	#12,d0
print_curdir20:
		suba.w	d0,a1

print_curdir30:
		lea	CURRENT(a6),a0		*4*8�h�b�g�Ńe�L�X�g��(368,344)�ɕ\��
		moveq	#2,d0
		moveq	#0,d1
		bsr	TEXT_4_8

		movem.l	(sp)+,d0-d1/a0-a1
		rts


*==================================================
*�Z���N�^����R�}���h�����s����
*	d0.l -> ���Ȃ�AFCP�|�C���^���ړ����Ă��Ȃ�
*==================================================

SELECT_MAIN:
		bsr	selector_auto			*AUTO���[�h����

		tst.b	SEL_VIEWMODE(a6)		*�r���[�����[�h
		bne	VIEWER_MAIN

*		bsr	debug
		clr.b	SEL_PLAYCHK(a6)			*���t�������ǂ����̃`�F�b�N�p
		move.w	SEL_FCP(a6),-(sp)
		lea	selt_jmp_fsel(pc),a0		*�Z���N�^�R�}���h���s
		bsr	select_jump
		move.w	(sp)+,d0
		cmp.w	SEL_FCP(a6),d0
		beq	select_main80			*�ړ����Ă�����
		bsr	disp_linenum

		movea.l	SEL_HEAD(a6),a0			*���݈ʒu��ۑ�
		move.w	SEL_FCP(a6),PAST_POS(a0)

		move.w	SEL_BPRT(a6),SEL_BSCH(a6)	*�^�C�g�������J�n�ʒu���Z�b�g
*		move.w	SEL_BPRT(a6),d0			*(�X�O���猟������ꍇ�j
*		subi.w	#9,d0
*		bcc	select_main50
*		cmp.w	SEL_BTOP(a6),d0
*		bcc	aa
*		move.w	SEL_BTOP(a6),d0
*select_main50:
*		move.w	d0,SEL_BSCH(a6)

		tst.b	SEL_PLAYCHK(a6)			*mmove = (playchk)? 0 : -1;
		seq	SEL_MMOVE(a6)
		moveq	#0,d0
		bra	select_main90
select_main80:
		moveq	#-1,d0
select_main90:
		rts


*==================================================
*�Z���N�^����R�}���h�����s����i�h�L�������g�r���[���j
*	d0.l -> ���Ȃ�A�J�[�\���ړ�����������
*==================================================

VIEWER_MAIN:
		move.l	DOCV_NOW(a6),-(sp)		*���̕\���ʒu���o���Ă���
		lea	selt_jmp_view(pc),a0		*�r���[���R�}���h���s
		bsr	select_jump
		move.l	(sp)+,d0
		cmp.l	DOCV_NOW(a6),d0
		beq	viewer_main80			*�\���ʒu���ς���Ă�����0
		moveq	#0,d0
		bra	viewer_main90
viewer_main80:
		moveq	#-1,d0				*�ς��ĂȂ�������-1
viewer_main90:
		rts


*==================================================
*�Z���N�^����R�}���h�������[�`���փW�����v
*	a0.l <- �W�����v�e�[�u��
*==================================================

select_jump:
		movea.l	a0,a1
		move.w	SEL_CMD(a6),d0		*�R�}���h�`�F�b�N
		beq	selt_none
		cmpi.w	#SEL_CMDNUM,d0
		bcc	selt_none

		move.w	SEL_ARG(a6),d1
		subq.w	#1,d0
		lsl.w	#2,d0
		lea	(a0,d0.w),a0
		move.w	(a0)+,d0
		tst.w	(a0)
		beq	select_jump10		*�t�@�C�����Ȃ��Ƃ��߂ȃR�}���h�̏ꍇ
		tst.w	SEL_FMAX(a6)		*�t�@�C�����O�Ȃ�
		beq	selt_none		*�������Ȃ�
select_jump10:
		jsr	(a1,d0.w)		*�R�}���h���s
selt_none:
		clr.w	SEL_CMD(a6)
		rts


CMD_FSEL	macro	label,flag
		.dc.w	label-selt_jmp_fsel
		.dc.w	flag		*�t�@�C����������Ύ��s�ł��Ȃ��R�}���h�Ȃ�1
		endm

selt_jmp_fsel:
		CMD_FSEL	selt_rolldw_one,1
		CMD_FSEL	selt_rollup_one,1
		CMD_FSEL	selt_cur_up,1
		CMD_FSEL	selt_cur_down,1
		CMD_FSEL	selt_enter_cmd,1
		CMD_FSEL	selt_enter,1
		CMD_FSEL	selt_drive_right,0
		CMD_FSEL	selt_drive_left,0
		CMD_FSEL	selt_parent,0
		CMD_FSEL	selt_root,0
		CMD_FSEL	selt_roll_up,1
		CMD_FSEL	selt_roll_dw,1
		CMD_FSEL	selt_refresh,0
		CMD_FSEL	selt_top,1
		CMD_FSEL	selt_botom,1
		CMD_FSEL	selt_playdown,1
		CMD_FSEL	selt_playup,1
		CMD_FSEL	selt_eject,0
		CMD_FSEL	selt_datawrite,1
		CMD_FSEL	selt_docread,1
		CMD_FSEL	selt_docreadn,1

CMD_VIEW	macro	label,flag
		.dc.w	label-selt_jmp_view
		.dc.w	flag		*�t�@�C����������Ύ��s�ł��Ȃ��R�}���h�Ȃ�1
		endm

selt_jmp_view:
		CMD_VIEW	view_rolldw_one,1
		CMD_VIEW	view_rollup_one,1
		CMD_VIEW	view_cur_up,1
		CMD_VIEW	view_cur_down,1
		CMD_VIEW	view_enter_cmd,0
		CMD_VIEW	view_enter,1
		CMD_VIEW	view_drive_right,0
		CMD_VIEW	view_drive_left,0
		CMD_VIEW	view_parent,0
		CMD_VIEW	view_root,0
		CMD_VIEW	view_roll_up,1
		CMD_VIEW	view_roll_dw,1
		CMD_VIEW	view_refresh,0
		CMD_VIEW	view_top,1
		CMD_VIEW	view_botom,1
		CMD_VIEW	view_playdown,1
		CMD_VIEW	view_playup,1
		CMD_VIEW	view_eject,0
		CMD_VIEW	view_datawrite,1
		CMD_VIEW	view_docread,1
		CMD_VIEW	view_docreadn,1


*==================================================
*�Z���N�^�R�}���h�T�u���[�`���i�t�@�C���Z���N�^�j
*==================================================

*�o�b�t�@�N���A

selt_refresh:
		moveq	#0,d1
		bsr	AUTOMODE_SET
		bsr	AUTOFLAG_SET
		bsr	PROGMODE_SET
		bsr	INIT_FNAMEBUF
		clr.w	SEL_CHANGE(a6)
		rts

*�e�f�B���N�g���Ɉړ�

selt_parent:
		lea	FNAM_BUFF(a6),a0
		move.b	#'.',(a0)
		move.b	#'.',1(a0)
		move.b	#'\',2(a0)
		clr.b	3(a0)
		bsr	CHANGE_DIR
		rts

*���[�g�f�B���N�g���Ɉړ�

selt_root:
		lea	FNAM_BUFF(a6),a0
		move.b	#'\',(a0)
		clr.b	1(a0)
		bsr	CHANGE_DIR
		rts

*�P�Ⴂ�h���C�u�Ɉړ�

selt_drive_left:
		move.b	CURRENT(a6),d0
		andi.w	#$00df,d0
		subi.w	#'A',d0
		beq	selt_drv_left90

		lea	DRV_TBL(a6),a0
selt_drv_left10:
		subq.w	#1,d0				*�L���h���C�u��������
		bcs	selt_drv_left90
		tst.b	(a0,d0.w)
		bmi	selt_drv_left10

		move.w	d0,-(sp)			*�h���C�u�ړ�
		DOS	_CHGDRV
		addq.l	#2,sp
		clr.w	SEL_CHANGE(a6)
selt_drv_left90:
		rts

*�P���̃h���C�u�Ɉړ�

selt_drive_right:
		move.b	CURRENT(a6),d0
		andi.w	#$00df,d0
		subi.w	#'A',d0

		lea	DRV_TBL(a6),a0
selt_drv_right10:
		addq.w	#1,d0				*�L���h���C�u��������
		cmpi.w	#25,d0
		bhi	selt_drv_right90
		tst.b	(a0,d0.w)
		bmi	selt_drv_right10

		move.w	d0,-(sp)			*�h���C�u�ړ�
		DOS	_CHGDRV
		addq.l	#2,sp
		clr.w	SEL_CHANGE(a6)
selt_drv_right90:
		rts

*���t���Ă��玟�̍s�ֈړ�

selt_playdown:
		tst.b	AUTOMODE(a6)		*AUTO/SHUFFLE���[�h��
		beq	selt_playdown10
		tst.b	PROG_MODE(a6)		*����PROG���[�h�łȂ�������
		bne	selt_playdown10
		bsr	PLAY_NEXT		*���̋Ȃւ����ڂ�
		bra	selt_playdown90
selt_playdown10:
		move.w	SEL_FCP(a6),d0		*���̍s���f�[�^��������A
		bsr	get_fnamebuf
		tst.b	(a0)
		ble	selt_playdown11
		bsr	selt_enter		*���t/�I������
selt_playdown11:
		bsr	selt_cur_down		*���̍s�ֈړ�����
selt_playdown90:
		rts

*�O�̍s�ֈړ����ĉ��t

selt_playup:
		bsr	selt_cur_up		*�O�̍s�ֈړ�����
		move.w	SEL_FCP(a6),d0		*���̍s���f�[�^��������
		bsr	get_fnamebuf
		tst.b	(a0)
		ble	selt_playup90
		bsr	selt_enter		*���t/�I������
selt_playup90:
		rts

*�f�B�X�N�C�W�F�N�g

selt_eject:
		bsr	UNLOCK_DRIVE		*���b�N����Ă���h���C�u������
		move.w	#$0100,-(sp)
		DOS	_DRVCTRL		*�J�����g�h���C�u���C�W�F�N�g
		addq.l	#2,sp
		clr.w	SEL_CHANGE(a6)		*init���[�h��
		rts


*	���d�m�s�d�q�C�q�d�s�t�q�m��

selt_enter_cmd:
		move.w	SEL_ARG(a6),d0
		add.w	SEL_BPRT(a6),d0
		cmp.w	SEL_BMAX(a6),d0
		bcc	selt_enter_done
		move.w	d0,SEL_FCP(a6)
		move.w	SEL_ARG(a6),d0
		move.w	d0,SEL_CUR(a6)
		bsr	LINE_CUR_ON

selt_enter:
		tst.b	PROG_MODE(a6)
		bne	selt_enter_prog

		moveq	#0,d0
		bsr	DRIVE_CHECK		*�h���C�u���f�B�`�F�b�N
		bmi	selt_enter_done
		move.w	SEL_FCP(a6),d0		*�o�b�t�@�A�h���X�v�Z
		bsr	get_fnamebuf
		tst.b	(a0)
		beq	selt_enter_dir
		bsr	PLAY_MUSIC		*�ȃf�[�^�������牉�t
		bra	selt_enter_done
selt_enter_dir:
		lea	FILE_NAME(a0),a0	*�f�B���N�g����������J�����g�ړ�
		bsr	CHANGE_DIR
selt_enter_done:
		rts

selt_enter_prog:
		move.w	SEL_FCP(a6),d0		*�o�b�t�@�A�h���X�v�Z
		bsr	get_fnamebuf
		tst.b	(a0)
		ble	selt_enter_dir
		tst.b	PROG_FLAG(a0)		*PROG�t���O���]
		seq	PROG_FLAG(a0)
		move.w	SEL_CUR(a6),d0		*�\��
		bsr	TITLE_PRT1
selt_enter_prog90:
		rts


*�擪�s�ֈړ�

selt_top:
		move.w	SEL_BTOP(a6),d0			*���ܐ擪�Ȃ�A��������
		cmp.w	SEL_FCP(a6),d0
		beq	selt_top90
		move.w	d0,SEL_FCP(a6)			*�\��
		cmp.w	SEL_BPRT(a6),d0
		beq	selt_top80
		move.w	d0,SEL_BPRT(a6)
		bsr	TITLE_NP_PRT
selt_top80:
		moveq	#0,d0
		move.w	d0,SEL_CUR(a6)			*�J�[�\����擪��
		bsr	LINE_CUR_ON
selt_top90:
		rts


*�ŏI�s�ֈړ�

selt_botom:
		move.w	SEL_BMAX(a6),d1
		subq.w	#1,d1
		move.w	d1,SEL_FCP(a6)
		subq.w	#8,d1
		cmp.w	SEL_BTOP(a6),d1
		bge	selt_botom10
		move.w	SEL_BTOP(a6),d1
selt_botom10:
		move.w	SEL_FCP(a6),d0
		sub.w	d1,d0
		move.w	d0,SEL_CUR(a6)
		bsr	LINE_CUR_ON
		cmp.w	SEL_BPRT(a6),d1
		beq	selt_botom90
		move.w	d1,SEL_BPRT(a6)
		bsr	TITLE_NP_PRT			*�\��
selt_botom90:
		rts


*	���q�n�k�k�@�t�o��
selt_roll_up:
		bsr	selt_rollup_one
		bsr	selt_rollup_one
		bsr	selt_rollup_one
		bsr	selt_rollup_one
		bsr	selt_rollup_one
		bsr	selt_rollup_one
		bsr	selt_rollup_one
		bsr	selt_rollup_one
		bsr	selt_rollup_one
		rts

		move.w	SEL_FCP(a6),d0			*�Ō�ɂ�����A��������
		addq.w	#1,d0
		cmp.w	SEL_BMAX(a6),d0
		beq	selt_rldw_done

		move.w	SEL_BPRT(a6),d1

		cmpi.w	#9,SEL_FMAX(a6)			*if (fmax <= 9) {
		bhi	selt_roll_up10
		move.w	SEL_BTOP(a6),SEL_BPRT(a6)	*	bprt = btop;
		move.w	SEL_BMAX(a6),SEL_FCP(a6)	*	fcp = bmax - 1;
		subq.w	#1,SEL_FCP(a6)
		bra	selt_roll_up20
selt_roll_up10:
		move.w	SEL_BMAX(a6),d0			*} else if (fcp >= bmax - 9) {
		subi.w	#9,d0
		cmp.w	SEL_FCP(a6),d0
		bhi	selt_roll_up11
		move.w	d0,SEL_BPRT(a6)			*	bprt = bmax - 9;
		addq.w	#8,d0
		move.w	d0,SEL_FCP(a6)			*	fcp = bmax - 1;
		bra	selt_roll_up20
selt_roll_up11:
		addi.w	#9,SEL_FCP(a6)			*} else {
		addi.w	#9,SEL_BPRT(a6)			*	fcp += 9;
		cmp.w	SEL_BPRT(a6),d0			*	bprt += 9;
		bcc	selt_roll_up20			*	if(bprt > bmax - 9)
		move.w	d0,SEL_BPRT(a6)			*		bprt = bmax - 9;
							*}

selt_roll_up20:
		move.w	SEL_FCP(a6),d0
		sub.w	SEL_BPRT(a6),d0
		move.w	d0,SEL_CUR(a6)

		bsr	LINE_CUR_ON
		cmp.w	SEL_BPRT(a6),d1
		beq	selt_rlup_done
		bsr	TITLE_NP_PRT			*�\��
selt_rlup_done:
		rts


*	���q�n�k�k�@�c�n�v�m��

selt_roll_dw:

		bsr	selt_rolldw_one
		bsr	selt_rolldw_one
		bsr	selt_rolldw_one
		bsr	selt_rolldw_one
		bsr	selt_rolldw_one
		bsr	selt_rolldw_one
		bsr	selt_rolldw_one
		bsr	selt_rolldw_one
		bsr	selt_rolldw_one
		rts


		move.w	SEL_FCP(a6),d0			*�擪�ɂ�����A��������
		cmp.w	SEL_BTOP(a6),d0
		beq	selt_rldw_done

		move.w	SEL_BPRT(a6),d1

		move.w	SEL_BTOP(a6),d0			*if(fcp < btop + 9) {
		addi.w	#9,d0
		cmp.w	SEL_FCP(a6),d0
		bls	selt_roll_dw10
		move.w	SEL_BTOP(a6),SEL_BPRT(a6)	*	bprt = btop;
		move.w	SEL_BTOP(a6),SEL_FCP(a6)	*	fcp = btop;
		bra	selt_roll_dw20			*} else {
selt_roll_dw10:
		subi.w	#9,SEL_FCP(a6)			*	fcp -= 9;
		subi.w	#9,SEL_BPRT(a6)			*	bprt -= 9;
		move.w	SEL_BTOP(a6),d0			*	if (bprt < btop)
		cmp.w	SEL_BPRT(a6),d0
		ble	selt_roll_dw20			*		bprt = btop;
		move.w	d0,SEL_BPRT(a6)			*}

selt_roll_dw20:
		move.w	SEL_FCP(a6),d0			*cur = fcp - bprt;
		sub.w	SEL_BPRT(a6),d0
		move.w	d0,SEL_CUR(a6)

		bsr	LINE_CUR_ON
		cmp.w	SEL_BPRT(a6),d1
		beq	selt_rldw_done
		bsr	TITLE_NP_PRT			*�\��
selt_rldw_done:
		rts

*	���e���L�[�Q

selt_cur_down:
		cmpi.w	#8,SEL_CUR(a6)			*�X�N���[�����邩�H
		bne	selt_cur_down10
		bsr	selt_rollup_one			*�X�N���[��
		bra	selt_cdw_done
selt_cur_down10:
		move.w	SEL_FCP(a6),d0			*�������邩�H
		addq.w	#1,d0
		cmp.w	SEL_BMAX(a6),d0
		bcc	selt_cdw_done
		move.w	d0,SEL_FCP(a6)
		addq.w	#1,SEL_CUR(a6)			*�J�[�\���ړ�
		move.w	SEL_CUR(a6),d0
		bsr	LINE_CUR_ON
selt_cdw_done:
		rts

*	���e���L�[�W

selt_cur_up:
		tst.w	SEL_CUR(a6)			*�X�N���[�����邩�H
		bne	selt_cur_up10
		bsr	selt_rolldw_one			*�X�N���[��
		bra	selt_cup_done
selt_cur_up10:
		move.w	SEL_FCP(a6),d0			*�オ���邩�H
		subq.w	#1,d0
		cmp.w	SEL_BTOP(a6),d0
		bcs	selt_cup_done
		move.w	d0,SEL_FCP(a6)
		sub.w	#1,SEL_CUR(a6)			*�łȂ���΃J�[�\���ړ�
		move.w	SEL_CUR(a6),d0
		bsr	LINE_CUR_ON
selt_cup_done:
		rts

*�P�s���[���_�E��

selt_rolldw_one:
		move.w	SEL_BPRT(a6),SEL_FCP(a6)	*�J�[�\������ԏ��
		moveq	#0,d0
		move.w	d0,SEL_CUR(a6)
		bsr	LINE_CUR_ON

		move.w	SEL_BPRT(a6),d0			*�X�N���[���ł��邩
		cmp.w	SEL_BTOP(a6),d0
		bls	selt_rldw_one90

		subq.w	#1,SEL_BPRT(a6)
		subq.w	#1,SEL_FCP(a6)

		bsr	TITLE_SCUP			*��������[���
		move.w	SEL_FCP(a6),d0			*�o�b�t�@�A�h���X�v�Z
		bsr	get_fnamebuf
		moveq.l	#0,d0				*�^�C�g���\��
		bsr	TITLE_PRT1
selt_rldw_one90:
		rts

*�P�s���[���A�b�v

selt_rollup_one:
		moveq	#8,d0				*�J�[�\������ԉ���
		cmp.w	SEL_FMAX(a6),d0
		bcs	selt_rlup_one10
		move.w	SEL_FMAX(a6),d0
		subq.w	#1,d0
selt_rlup_one10:
		move.w	d0,SEL_CUR(a6)
		bsr	LINE_CUR_ON
		add.w	SEL_BPRT(a6),d0
		move.w	d0,SEL_FCP(a6)

		move.w	SEL_BPRT(a6),d0			*�X�N���[���ł��邩
		addi.w	#9,d0
		cmp.w	SEL_BMAX(a6),d0
		bcc	selt_rlup_one90

		addq.w	#1,SEL_BPRT(a6)
		addq.w	#1,SEL_FCP(a6)

		bsr	TITLE_SCDW			*��������[���
		move.w	SEL_FCP(a6),d0
		bsr	get_fnamebuf			*�o�b�t�@�A�h���X�v�Z
		moveq.l	#8,d0				*�^�C�g���\��
		bsr	TITLE_PRT1
selt_rlup_one90:
		rts

selt_docreadn:
		move.w	SEL_ARG(a6),d0
		add.w	SEL_BPRT(a6),d0
		cmp.w	SEL_BMAX(a6),d0
		bcc	selt_docreadn90
		move.w	d0,SEL_FCP(a6)
		move.w	SEL_ARG(a6),d0
		move.w	d0,SEL_CUR(a6)
		bsr	LINE_CUR_ON
		bsr	selt_docread
selt_docreadn90:
		rts

selt_docread:
		link	a5,#-24
		move.w	SEL_FCP(a6),d0			*���݈ʒu�̃t�@�C���𒲂�
		bsr	get_fnamebuf
		tst.b	DOC_FLAG(a0)
		beq	selt_docread90
		lea	FILE_NAME(a0),a0		*�h�L�������g�t�@�C���������
		lea	-24(a5),a1
		bsr	change_ext_doc
		tst.l	d0
		bmi	selt_docread90

		lea	-24(a5),a0			*�r���[��������������
*		move.l	#$0080_000c,d0			*�\���͈͂̐ݒ�
		move.l	#$0055_0009,d0			*�\���͈͂̐ݒ�
		move.l	#$0000_0058,d1			*�\���ʒu�̐ݒ�
		moveq.l	#0,d2				*�t�H���g�w��
		bsr	DOCVIEW_INIT
		tst.l	d0
		bmi	selt_docread90
		bsr	LINE_CUR_OFF
		bsr	DOCV_NOW_PRT
		st.b	SEL_VIEWMODE(a6)
selt_docread90:
		unlk	a5
		rts

*�f�[�^�t�@�C�������o��

selt_datawrite:
		lea	mes_datawrite1(pc),a0
		bsr	G_MESSAGE_PRT
		bsr	write_datafile
		lea	mes_datawrite2(pc),a0
		bsr	G_MESSAGE_PRT
		rts

mes_datawrite1:	.dc.b	'�f�[�^�t�@�C�������o����...',0
mes_datawrite2:	.dc.b	'�f�[�^�t�@�C�������o���I��',0
		.even


*==================================================
*�Z���N�^�R�}���h�T�u���[�`���i�r���[���j
*==================================================

view_roll_dw:
		bra	DOCV_ROLLDOWN

view_roll_up:
		bra	DOCV_ROLLUP

view_rolldw_one:
view_cur_up:
		bra	DOCVIEW_UP

view_rollup_one:
view_cur_down:
		bra	DOCVIEW_DOWN

view_drive_right:
view_drive_left:
view_playdown:
view_playup:
view_eject:
view_datawrite:
view_top:
view_botom:
		rts				*�������Ȃ�

view_enter:
view_enter_cmd:
view_refresh:
view_parent:
view_root:
view_docread:
view_docreadn:
		clr.b	SEL_VIEWMODE(a6)		*�r���[���𔲂���
		clr.w	SEL_CHANGE(a6)
		rts


*==================================================
*�ȃf�[�^�����t����
*	a0.l <- �o�b�t�@�A�h���X
*==================================================

PLAY_MUSIC:
		movem.l	d0-d1/a0-a1,-(sp)
		bsr	SHRINK_CONSOLE		*�\���G���A�ύX
		movea.l	a0,a1
		move.b	DATA_KIND(a0),d1	*���y�f�[�^��������A
		beq	play_music90
		DRIVER	DRIVER_FADEOUT		*�t�F�[�h�A�E�g����
		bsr	CLEAR_KEYON		*�L�[�n�m�N���A����
		lea	FILE_NAME(a1),a1	*���[�h�����t
		move.b	d1,d0
		DRIVER	DRIVER_FLOADP		*d0.b:code a1.l:filename
		tst.w	d0
		beq	play_music10		*�����G���[������������A
		bsr	GET_PLAYERRMES		*�G���[���b�Z�[�W��\������
		bsr	G_MESSAGE_PRT
play_music10:
		tst.l	d0
		bmi	play_music90		*���t�J�n������A
		bsr	CLEAR_PASSTM		*�o�ߎ��ԃN���A
		clr.w	BLANK(a6)
		bra	play_music90
play_music90:
		bsr	CLEAR_CMD		*���܂��Ă���R�}���h���N���A����
		clr.w	SEL_CMD(a6)
		clr.b	SEL_MMOVE(a6)		*�蓮�ړ��t���O��
		st.b	SEL_PLAYCHK(a6)		*���t�R�}���h�t���O���Z�b�g����
		bsr	RESUME_CONSOLE		*�\���G���A�߂�
		movem.l	(sp)+,d0-d1/a0-a1
		rts


*==================================================
*�v���O�������[�h�Z�b�g
*	d1.b <- ���[�h�t���O(0:OFF 0�ȊO:ON)
*==================================================

PROGMODE_CHG:
		move.l	d1,-(sp)		*PROG�ݒ胂�[�h�g�O������
		tst.b	PROG_MODE(a6)
		seq	d1
		bsr	PROGMODE_SET
		move.l	(sp)+,d1
		rts

PROGMODE_SET:
		movem.l	d0-d1/a1,-(sp)		*PROG�ݒ胂�[�h�Z�b�g
		tst.b	d1
		sne	d1
		tst.b	SEL_NOUSE(a6)		*�Z���N�^���g�p���[�h�Ȃ�N���A
		beq	progmode_set10
		moveq	#0,d1
progmode_set10
		move.b	d1,PROG_MODE(a6)
		move.b	d1,d0			*�X�C�b�`��\������
		move.l	#$00070001,d1
		movea.l	#TXTADR+6+344*$80,a1
		bsr	put_automodesub
		movem.l	(sp)+,d0-d1/a1
		rts


*==================================================
*�v���O�����N���A
*==================================================

PROG_CLR:
		movem.l	d0/a0,-(sp)
		movea.l	#SEL_FNAME,a0
		move.w	SEL_FILENUM(a6),d0
		subq.w	#1,d0
		bcs	prog_clr90
prog_clr10:
		tst.b	(a0)
		ble	prog_clr19
		clr.b	PROG_FLAG(a0)
prog_clr19:
		lea	32(a0),a0
		dbra	d0,prog_clr10

		bsr	TITLE_NP_PRT
prog_clr90:
		movem.l	(sp)+,d0/a0
		rts


*==================================================
*�`�t�s�n���[�h�Z�b�g
*	d1.b <- ���[�h(0:NORMAL 1:AUTO 2:SHUFFLE)
*==================================================

AUTOMODE_CHG:
		move.l	d1,-(sp)		*AUTO���[�h�g�O������
		cmp.b	AUTOMODE(a6),d1
		bne	automode_chg10
		moveq	#0,d1
automode_chg10:
		bsr	AUTOMODE_SET
		move.l	(sp)+,d1
		rts

AUTOMODE_SET:
		movem.l	d0-d1/a1,-(sp)		*AUTO���[�h�Z�b�g
		cmpi.b	#2,d1
		bhi	automode_set90
		tst.b	SEL_NOUSE(a6)		*�Z���N�^���g�p���[�h�Ȃ�AUTO����
		beq	automode_set10
		moveq	#0,d1
automode_set10:
		clr.w	BLANK(a6)		*�u�����N���Ԃ��N���A����
		move.b	d1,AUTOMODE(a6)
		beq	automode_set20
		tst.w	PLAY_FLAG(a6)		*���t���łȂ����
		bne	automode_set11
		DRIVER	DRIVER_STOP		*���t�����S�ɒ�~������
automode_set11:
		move.w	#-1,BLANK(a6)
		cmpi.b	#2,d1			*SHUFFLE���[�h��������
		bne	automode_set20
		addq.b	#1,SHUFFLE_CODE(a6)	*�V���t���R�[�h��ύX����
		clr.b	SEL_MMOVE(a6)		*�蓮�ړ��t���O���N���A����
automode_set20:
		move.b	d1,d0			*�X�C�b�`��\������
		move.l	#$00070002,d1
		movea.l	#TXTADR+33+502*$80,a1
		bsr	put_automodesub
		lea	3(a1),a1
		bsr	put_automodesub

automode_set90:
		movem.l	(sp)+,d0-d1/a1
		rts

put_automodesub:
		lsr.b	#1,d0			*d0.b���E�V�t�g����
		bcs	LIGHT_PATTERN		*bit on �Ȃ�X�C�b�`�𖾂邭����
		bra	DARK_PATTERN		*bit off�Ȃ�Â�����


*==================================================
*�`�t�s�n�t���O�Z�b�g
*	d1.b <- �t���O(bit0:REPEAT bit1:INTRO bit2:ALLDIR bit3:PROG)
*==================================================

AUTOFLAG_CHG:
		movem.l	d0-d1,-(sp)		*AUTO�t���O�g�O������
		move.b	AUTOFLAG(a6),d0
		eor.b	d0,d1
		bsr	AUTOFLAG_SET
		movem.l	(sp)+,d0-d1
		rts

AUTOFLAG_SET:
		movem.l	d0-d1/a1,-(sp)		*AUTO�t���O�Z�b�g
		tst.b	SEL_NOUSE(a6)		*�Z���N�^���g�p���[�h�Ȃ�AUTO�t���O����
		beq	autoflag_set10
		moveq	#0,d1
autoflag_set10:
		andi.w	#$000f,d1
		move.b	d1,AUTOFLAG(a6)
		move.b	d1,d0			*�X�C�b�`��\������
		move.l	#$00070002,d1
		movea.l	#TXTADR+41+502*$80,a1
		bsr	put_automodesub
		lea	3(a1),a1
		bsr	put_automodesub
		lea	3(a1),a1
		bsr	put_automodesub
		lea	3(a1),a1
		bsr	put_automodesub
autoflag_set90:
		movem.l	(sp)+,d0-d1/a1
		rts


*==================================================
*���[�v�񐔃Z�b�g
*==================================================

LOOPTIME_UP:
		move.l	d1,-(sp)
		move.w	LOOP_TIME(a6),d1
		addq.w	#1,d1
		bsr	LOOPTIME_SET
		move.l	(sp)+,d1
		rts
LOOPTIME_DOWN:
		move.l	d1,-(sp)
		move.w	LOOP_TIME(a6),d1
		subq.w	#1,d1
		bsr	LOOPTIME_SET
		move.l	(sp)+,d1
		rts
LOOPTIME_SET:
		movem.l	d0-d1/a0,-(sp)
		cmpi.w	#99,d1
		bhi	looptime_set90
		tst.w	d1
		beq	looptime_set90
		move.w	d1,LOOP_TIME(a6)
		tst.b	SEL_NOUSE(a6)		*�Z���N�^�g�p���[�h�Ȃ�\������
		bne	looptime_set90
		move.w	d1,d0
		moveq	#2,d1
		movea.l	#BGADR+56*2+62*$80,a0
		bsr	DIGIT10
looptime_set90:
		movem.l	(sp)+,d0-d1/a0
		rts


*==================================================
*�Ȋԃu�����N���ԃZ�b�g
*==================================================

BLANKTIME_UP:
		move.l	d1,-(sp)
		move.w	BLANK_TIME(a6),d1
		addq.w	#1,d1
		bsr	BLANKTIME_SET
		move.l	(sp)+,d1
		rts
BLANKTIME_DOWN:
		move.l	d1,-(sp)
		move.w	BLANK_TIME(a6),d1
		subq.w	#1,d1
		bsr	BLANKTIME_SET
		move.l	(sp)+,d1
		rts
BLANKTIME_SET:
		movem.l	d0-d1/a0,-(sp)
		cmpi.w	#99,d1
		bhi	blanktime_set90
		move.w	d1,BLANK_TIME(a6)
		tst.b	SEL_NOUSE(a6)		*�Z���N�^�g�p���[�h�Ȃ�\������
		bne	blanktime_set90
		move.w	d1,d0
		moveq	#2,d1
		movea.l	#BGADR+59*2+62*$80,a0
		bsr	DIGIT10
blanktime_set90:
		movem.l	(sp)+,d0-d1/a0
		rts


*==================================================
*�C���g�����ԃZ�b�g
*==================================================

INTROTIME_UP:
		move.l	d1,-(sp)
		move.w	INTRO_TIME(a6),d1
		addq.w	#1,d1
		bsr	INTROTIME_SET
		move.l	(sp)+,d1
		rts
INTROTIME_DOWN:
		move.l	d1,-(sp)
		move.w	INTRO_TIME(a6),d1
		subq.w	#1,d1
		bsr	INTROTIME_SET
		move.l	(sp)+,d1
		rts
INTROTIME_SET:
		movem.l	d0-d1/a0,-(sp)
		cmpi.w	#99,d1
		bhi	introtime_set90
		tst.w	d1
		beq	introtime_set90
		move.w	d1,INTRO_TIME(a6)
		tst.b	SEL_NOUSE(a6)		*�Z���N�^�g�p���[�h�Ȃ�\������
		bne	introtime_set90
		move.w	d1,d0
		moveq	#2,d1
		movea.l	#BGADR+62*2+62*$80,a0
		bsr	DIGIT10
introtime_set90:
		movem.l	(sp)+,d0-d1/a0
		rts


*==================================================
*�Z���N�^������
*	a0.l <- �f�B���N�g���w�b�_
*==================================================

SET_SELECTOR:
		move.l	d0,-(sp)

		move.l	a0,SEL_HEAD(a6)

		move.w	TOP_POS(a0),SEL_BTOP(a6)
		move.w	PAST_POS(a0),SEL_FCP(a6)
		move.w	FILE_NUM(a0),d0
		move.w	d0,SEL_FMAX(a6)
		add.w	SEL_BTOP(a6),d0
		move.w	d0,SEL_BMAX(a6)

		move.w	SEL_BTOP(a6),d0		*if( fcp < btop + 4 | fmax <= 9) {
		addi.w	#4,d0
		cmp.w	SEL_FCP(a6),d0
		bhi	set_selector10		*	bprt = btop;
		cmpi.w	#9,SEL_FMAX(a6)
		bls	set_selector10
		move.w	SEL_BMAX(a6),d0		*} else if ( fcp > bmax - 5 ) {
		subi.w	#5,d0
		cmp.w	SEL_FCP(a6),d0
		bcs	set_selector11		*	bprt = bmax - 9;
		move.w	SEL_FCP(a6),d0		*} else bprt = fcp - 4;
		subq.w	#4,d0
		move.w	d0,SEL_BPRT(a6)
		bra	set_selector20

set_selector10:
		move.w	SEL_BTOP(a6),SEL_BPRT(a6)
		bra	set_selector20
set_selector11:
		move.w	SEL_BMAX(a6),d0
		subi.w	#9,d0
		move.w	d0,SEL_BPRT(a6)

set_selector20:
		move.w	SEL_FCP(a6),d0		*cur = fcp - bprt
		sub.w	SEL_BPRT(a6),d0
		move.w	d0,SEL_CUR(a6)

		move.w	SEL_BPRT(a6),SEL_BSCH(a6)

		move.l	(sp)+,d0
		rts


*==================================================
*�Z���N�^�ĕ\��
*==================================================

REF_SELECTOR:
		movem.l	d0-d1/a0-a1,-(sp)

		tst.b	SEL_VIEWMODE(a6)
		bne	ref_selector90

		bsr	disp_linenum		*���݈ʒu��\��
		bsr	LINE_CUR_OFF		*�J�[�\����������
		bsr	TITLE_NP_PRT		*��ʂ�`������
		movea.l	SEL_HEAD(a6),a0		*�_�~�[�̃w�b�_�Ȃ�A
		tst.l	PATH_ADR(a0)
		bne	ref_selector10
		moveq	#1,d0			*'NO DISK'�ƕ\��
		moveq	#0,d1
		lea	mes_nodisk(pc),a0
		movea.l	#TXTADR+58+481*$80,a1
		bsr	TEXT_6_16
		bra	ref_selector90
ref_selector10:
		tst.w	SEL_FMAX(a6)		*�t�@�C������ł�����Ȃ�
		beq	ref_selector90
		move.w	SEL_CUR(a6),d0		*�J�[�\����\������
		bsr	LINE_CUR_ON
ref_selector90:
		movem.l	(sp)+,d0-d1/a0-a1
		rts

mes_nodisk:
		.dc.b	'NO DISK',0
		.even


*==================================================
*�o�b�t�@���̃^�C�g�����P�\��
*	a0.l <- �o�b�t�@�|�C���^�A�h���X
*	d0.w <- �\���ʒu(0-8)
*==================================================

TITLE_PRT1:
		movem.l	d0-d2/a0-a3,-(sp)
		movea.l	a0,a2

		tst.b	SEL_VIEWMODE(a6)
		bne	title_prt1_90

		move.l	#TXTADR+(352+7)*$80,a1		*�e�L�X�g�A�h���X�v�Z
		and.w	#15,d0
		ext.l	d0
		lsl.l	#7,d0
		lsl.l	#4,d0
		add.l	d0,a1
		moveq	#0,d1

		move	#3,d0				*�f�B���N�g��:�A�N�Z�X���[�h�R
		tst.b	DATA_KIND(a2)
		bne	title_prt1_10
		lea	dir_mes(pc),a0
		bsr	TEXT_4_8
		lea	-$80*7+10(a1),a1
		lea	FILE_NAME(a2),a0
		bsr	TEXT_6_16
		bra	title_prt1_90

title_prt1_10:
		moveq	#1,d0				*������:�A�N�Z�X���[�h�P
		tst.l	TITLE_ADR(a2)
		beq	title_prt1_20
		moveq	#2,d0				*�t�@�C��:�A�N�Z�X���[�h�Q
title_prt1_20:
		lea	FILE_NAME(a2),a0
		bsr	TEXT_4_8			*�t�@�C�����\��

		movem.l	d0-d1/a1/a3,-(sp)
		movea.l	a1,a3
		lea	-3*$80(a3),a1
		tst.b	PROG_FLAG(a2)			*�v���O��������Ă����
		sne	d0
		ext.w	d0
		move.w	d0,(a1)				*�o�[��\������
		move.w	d0,$80(a1)

		tst.b	DOC_FLAG(a2)			*�h�L�������g���L���
		beq	title_prt1_21
		lea	doc_pat(pc),a0			* [DOC]��\������
		lea	-6*$80+6(a3),a1
		adda.l	#$20000,a1
		move.l	(a0)+,(a1)
		move.l	(a0)+,$80(a1)
		move.l	(a0)+,$100(a1)
		move.l	(a0)+,$180(a1)
		move.l	(a0)+,$200(a1)
title_prt1_21:
		movem.l	(sp)+,d0-d1/a1/a3

		move.l	TITLE_ADR(a2),d0
		beq	title_prt1_90
		movea.l	d0,a0				*�^�C�g���\��
		moveq	#2,d0
		lea.l	-$80*7+10(a1),a1
		tst.b	(a0)
		bne	title_prt1_30			*�^�C�g���̑��Ƀt�@�C�����\��
		lea	$80*8(a1),a1
		lea	file_mes(pc),a0
		bsr	TEXT_4_8
		lea	-$80*8+7(a1),a1
		lea	FILE_NAME(a2),a0
title_prt1_30:
		bsr	TEXT_6_16

title_prt1_90:
		movem.l	(sp)+,d0-d2/a0-a3
		rts

dir_mes:	.dc.b	'<DIRECTORY>',0
file_mes:	.dc.b	'[NO TITLE] ___',$7F,0
prog_mes:	.dc.b	'PROG',0
		.even
doc_pat:	.dc.l	%00000100111100011100011110010000
		.dc.l	%00001000100010100010100000001000
		.dc.l	%00001000000000000000000000001000
		.dc.l	%00001000100010100010100000001000
		.dc.l	%00000100111100011100011110010000

*==================================================
*�^�C�g���s����
*	d0.w <- �\���ʒu
*==================================================

TITLE_CLR1:
		movem.l	d0/a0,-(sp)

		tst.b	SEL_VIEWMODE(a6)
		bne	title_clr1_90

		move.l	#TXTADR+352*$80,a0
		and.w	#15,d0
		ext.l	d0
		lsl.l	#7,d0
		lsl.l	#4,d0
		add.l	d0,a0

		moveq.l	#3,d0
		bsr	TEXT_ACCESS_ON

		moveq.l	#64,d0
		bsr	TXLINE_CLEAR

		bsr	TEXT_ACCESS_OF

title_clr1_90:
		movem.l	(sp)+,d0/a0
		rts


.if 0		*�Ƃ肠�����폜
*
*	���s�h�s�k�d�Q�o�q�s�Q
*�@�\�F�o�b�t�@���̃^�C�g������ʈʒu�ɂP�\��
*���́F	�`�O	�t�@�C���l�[���o�b�t�@�A�h���X
*�o�́F�Ȃ�
*�Q�l�F�o�b�t�@���Ƀ^�C�g���f�[�^�[�̗L�����킸�ɕ\������̂Œ���
*

TITLE_PRT2:
		movem.l	d0-d1/a0-a2,-(sp)

		move.l	a0,a2
		move.l	#TXTADR+496*$80+28,a0		*�\���G���A����
		moveq.l	#3,d0
		bsr	TEXT_ACCESS_ON
		moveq.l	#36,d0
		bsr	TXLINE_CLEAR
		bsr	TEXT_ACCESS_OF
		lea.l	$80*8(a0),a1

		movea.l	TITLE_ADR(a2),a0
		moveq.l	#3,d0
		moveq.l	#0,d1
		bset.l	#31,d1
		bsr	TEXT_4_8

		MYONTIME
		move.w	d0,G_MES_TIME(a6)
		move.w	#-1,G_MES_FLAG(a6)

		movem.l	(sp)+,d0-d1/a0-a2
		rts
.endif

*
*	���s�h�s�k�d�Q�m�o�Q�o�q�s
*�@�\�FSEL_BPRT(a6)�ʒu�̃o�b�t�@��\��
*���o�́F�Ȃ�
*�Q�l�F
*

TITLE_NP_PRT:
		movem.l	d0-d2/a0,-(sp)

		tst.b	SEL_VIEWMODE(a6)
		bne	title_np_done

		bsr	TITLE_CLRALL

		tst.w	SEL_FMAX(a6)			*�t�@�C�����P���Ȃ���΂����
		beq	title_np_done

		move.w	SEL_BPRT(a6),d1			*�o�b�t�@�A�h���X�v�Z
		move.w	d1,d0
		bsr	get_fnamebuf

		moveq	#0,d0
		moveq.l	#9-1,d2				*�X�\������
title_np_lp0:
		bsr	TITLE_PRT1
		lea.l	32(a0),a0
		addq.w	#1,d0
		addq.w	#1,d1				*�t�@�C�����Ȃ��Ȃ�����A�����
		cmp.w	SEL_BMAX(a6),d1
		bcc	title_np_done
		dbra	d2,title_np_lp0

title_np_done:
		movem.l	(sp)+,d0-d2/a0
		rts

TITLE_CLRALL:
		movem.l	d0-d3,-(sp)

		move.w	#$7C7B,d1
		move.w	#$24,d2
		move.w	#$FF03,d3
		IOCS	_TXRASCPY

		movem.l	(sp)+,d0-d3
		rts

TITLE_SCDW:
		movem.l	d0-d3,-(sp)

		move.w	#$5C58,d1
		move.w	#$20,d2
		move.w	#%11,d3
		IOCS	_TXRASCPY

		moveq.l	#8,d0
		bsr	TITLE_CLR1

		movem.l	(sp)+,d0-d3
		rts

TITLE_SCUP:
		movem.l	d0-d3,-(sp)

		move.w	#$777B,d1
		move.w	#$20,d2
		move.w	#$FF03,d3
		IOCS	_TXRASCPY

		moveq.l	#0,d0
		bsr	TITLE_CLR1

		movem.l	(sp)+,d0-d3
		rts


*==================================================
*�s�ԍ���\������
*==================================================

disp_linenum:
*		move.w	SEL_FCP(a6),d0
*		sub.w	SEL_BTOP(a6),d0
*		addq.w	#1,d0
*		movea.l	#BGADR+14*2+43*$80,a0
*		bsr	PRINT10_5KETA
*		move.w	SEL_FMAX(a6),d0
*		movea.l	#BGADR+17*2+43*$80,a0
*		bsr	PRINT10_5KETA
		rts


*==================================================
*���b�Z�[�W������
*==================================================

OVER_RIGHT_CLR:
		movem.l	d0-d1/a0,-(sp)				*�f�B���N�g���\������

		movea.l	#TXTADR+344*$80+34,a0
		moveq	#30,d1
		bra	g_mes_jp0


OVER_LINE_CLR:
		movem.l	d0-d1/a0,-(sp)				*���o������

		move.l	#TXTADR+344*$80,a0
		moveq	#34,d1
		bra	g_mes_jp0

G_MESSAGE_CLR:							*���b�Z�[�W����
		movem.l	d0-d1/a0,-(sp)

		move.l	#TXTADR+496*$80+11,a0
		moveq	#21,d1

g_mes_jp0:
		moveq.l	#3,d0
		bsr	TEXT_ACCESS_ON

		move.w	d1,d0
		bsr	TXLINE_CLEAR

		bsr	TEXT_ACCESS_OF

		movem.l	(sp)+,d0-d1/a0
		rts

*==================================================
*���b�Z�[�W�\��
*	a0.l <- ���b�Z�[�W
*	G_MESSAGE_PRT  �̓A�N�Z�X���[�h�R
*	G_MESSAGE_PRT2 �̓A�N�Z�X���[�h�Q
*==================================================

G_MESSAGE_PRT2:
		movem.l	d0-d1/a1,-(sp)
		moveq.l	#2,d0
		bra	g_message_jp
G_MESSAGE_PRT:
		movem.l	d0-d1/a1,-(sp)
		moveq.l	#3,d0

g_message_jp:
		bsr	G_MESSAGE_CLR

		move.l	#TXTADR+503*$80+11,a1
		moveq.l	#0,d1
		bsr	TEXT_4_8

		MYONTIME
		move.w	d0,G_MES_TIME(a6)
		move.w	#-1,G_MES_FLAG(a6)

		movem.l	(sp)+,d0-d1/a1
		rts


*==================================================
*���b�Z�[�W���ԑ҂�����
*	a0.l <- ���b�Z�[�W
*	G_MESSAGE_PRT  �̓A�N�Z�X���[�h�R
*	G_MESSAGE_PRT2 �̓A�N�Z�X���[�h�Q
*==================================================

G_MESSAGE_WAIT:
		movem.l	d0-d1,-(sp)

		tst.w	G_MES_FLAG(a6)
		beq	g_message_wait90

		MYONTIME			*�\������Q�b��������A
		sub.w	G_MES_TIME(a6),d0
		cmpi.w	#200,d0
		bls	g_message_wait90

		lea.l	G_MES_DEF(pc),a0		*�f�t�H���g�̃��b�Z�[�W��\������
		bsr	G_MESSAGE_PRT2

		clr.w	G_MES_FLAG(a6)

g_message_wait90:
		movem.l	(sp)+,d0-d1
		rts

*==================================================
*���C���J�[�\���\��
*	d0.b <- �J�[�\���ʒu
*==================================================

LINE_CUR_ON:
		movem.l	d0-d1/a0,-(sp)
		lea.l	linecur_pos(pc),a0

		move.b	(a0),d1
		cmp.b	d0,d1
		beq	line_cout_done

		bsr	LINE_CUR_OFF
		move.b	d0,(a0)

		move.l	#BGADR+0*2+45*$80,a0
		ext.w	d0
		lsl.w	#8,d0
		add.w	d0,a0

		move.w	#$172,d0
		moveq.l	#63,d1
		bsr	BG_LINE

line_cout_done:
		movem.l	(sp)+,d0-d1/a0
		rts

*==================================================
*���C���J�[�\������
*==================================================

LINE_CUR_OFF:
		movem.l	d0-d1/a0,-(sp)

		move.b	linecur_pos(pc),d0
		bmi	line_coff_done

		move.l	#BGADR+0*2+45*$80,a0
		ext.w	d0
		lsl.w	#8,d0
		add.w	d0,a0

		move.w	#$16f,d0
		moveq.l	#63,d1
		bsr	BG_LINE

		lea.l	linecur_pos(pc),a0
		st.b	(a0)
line_coff_done:
		movem.l	(sp)+,d0-d1/a0
		rts

linecur_pos:	.dc.b	-1
		.even


*==================================================
*�J�����g�f�B���N�g���𓾂�
*	a0.l <- �p�X�l�[���̕Ԃ�o�b�t�@
*==================================================

GET_CURRENT:
		movem.l	d0/a0-a1,-(sp)
		move.b	#'.',(a0)
		move.b	#'\',1(a0)
		clr.b	2(a0)
		movea.l	a0,a1
		bsr	EXTRACT_FNAME
		movem.l	(sp)+,d0/a0-a1
		rts

*==================================================
*�J�����g�f�B���N�g�����ړ�
*	a0.l <- �p�X�l�[���̓����Ă���o�b�t�@
*		�h���C�u�ړ�������
*==================================================

SET_CURRENT:
		movem.l	d0-d1/a0-a1,-(sp)
		link	a5,#-256
		movea.l	sp,a1
		bsr	EXTRACT_FNAME
		move.l	d0,d1
		move.b	(a1),d0
		subi.b	#'A',d0
		ext.w	d0
		move.w	d0,-(sp)
		DOS	_CHGDRV
		move.w	(sp)+,d0
		addq.w	#1,d0
		bsr	DRIVE_CHECK
		bmi	set_current90
		move.l	a1,-(sp)		*�ړ����Ă݂�
		DOS	_CHDIR
		addq.l	#6,sp
		tst.l	d0
		bpl	set_current90
		clr.b	(a1,d1.l)		*���߂Ȃ�f�B���N�g���������ɂ���
		move.l	a1,-(sp)
		DOS	_CHDIR
		addq.l	#4,sp
set_current90:
		unlk	a5
		movem.l	(sp)+,d0-d1/a0-a1
		rts


*==================================================
*�J�����g�f�B���N�g���ړ�
*	a0.l <- �f�B���N�g����(��΁A���΂Ȃ�ł�����j
*==================================================

CHANGE_DIR:
		bsr	SET_CURRENT
		clr.w	SEL_CHANGE(a6)
		rts


*==================================================
*�t�@�C�����W�J
*	a0.l <- �t�@�C����
*	a1.l <- ��΃p�X���i�[�A�h���X
*	d0.l -> �f�B���N�g�����̒���(�t�@�C�����܂܂�)
*==================================================

EXTRACT_FNAME:
		movem.l	d1-d2/a0-a2,-(sp)
		link	a5,#-96			*���[�J���G���A�m��
		movea.l	sp,a2
		moveq	#0,d2

		move.l	a2,-(sp)		*��΃p�X�l�[���ɓW�J
		move.l	a0,-(sp)
		DOS	_NAMECK
		addq.l	#8,sp
		move.l	d0,d1
		bmi	extract_fname90

		movea.l	a2,a0
extract_fname10:
		move.b	(a0)+,(a1)+		*�p�X���R�s�[
		bne	extract_fname10
		subq.l	#1,a1
		move.l	a0,d2
		sub.l	a2,d2
		subq.l	#1,d2
		cmpi.b	#$FF,d1			*�t�@�C�����̎w�肪����΁A
		beq	extract_fname90

		lea	67(a2),a0
extract_fname20:
		move.b	(a0)+,(a1)+		*�t�@�C�����R�s�[
		bne	extract_fname20
		subq.l	#1,a1

		lea	86(a2),a0
extract_fname30:
		move.b	(a0)+,(a1)+		*�g���q�R�s�[
		bne	extract_fname30
		subq.l	#1,a1

extract_fname90:
		clr.b	(a1)
		move.l	d2,d0
		unlk	a5			*���[�J���G���A�J��
		movem.l	(sp)+,d1-d2/a0-a2
		rts


*==================================================
* �R���\�[���͈͏k��
*==================================================

SHRINK_CONSOLE:
		movem.l	d0-d2/a0-a1,-(sp)

		move.l	#0*$10000+512,d1	*�\���G���A��(0,512)-(1023,527)�ɕύX
		move.l	#127*$10000+0,d2
		IOCS	_B_CONSOL
		movem.l	d1-d2,CONSOLE(a6)

		movem.l	(sp)+,d0-d2/a0-a1
		rts

*==================================================
* �R���\�[���͈͖߂�
*==================================================

RESUME_CONSOLE:
		movem.l	d0-d2/a0-a1,-(sp)

		movem.l	CONSOLE(a6),d1-d2		*�\���G���A��߂�
		IOCS	_B_CONSOL

		movem.l	(sp)+,d0-d2/a0-a1
		rts


			.data
			.even

*			AC,�l,�w�w,�x�x,����
FILESEL_MES:	.dc.b	02,00,00,0,1,088,'FILENAME',0
		.dc.b	01,00,06,2,1,088,'PRG',0
		.dc.b	01,00,08,2,1,088,'CLR',0
		.dc.b	01,00,10,2,1,088,'EJECT',0
		.dc.b	02,00,20,1,1,088,'MUSIC TITLE or DIRECTORY TITLE',0
		.dc.b	01,00,33,4,1,246,'AUTO',0
		.dc.b	01,00,36,2,1,246,'SHUFF',0
		.dc.b	01,00,41,6,1,246,'REP.',0
		.dc.b	01,00,44,3,1,246,'INTRO',0
		.dc.b	01,00,47,1,1,246,'ALLDIR',0
		.dc.b	01,00,50,3,1,246,'PROG.',0
		.dc.b	01,00,55,1,1,248,'LT',0
		.dc.b	01,00,58,1,1,248,'BT',0
		.dc.b	01,00,61,1,1,248,'IT',0
		.dc.b	0

DIRECTORY:	.dc.b	'< dir >',0
G_MES_DEF:	.dc.b	'"MMDSP" REALTIME GRAPHICAL USER INTERFACE.',0
*G_MES_No1:	.dc.b	'�^�C�g���������ł�',0
*G_MES_No2:	.dc.b	'�^�C�g�������𒆒f���܂���',0
*G_MES_No3:	.dc.b	'�^�C�g���������ĊJ���܂�',0
*G_MES_No4:	.dc.b	'�^�C�g���������I�����܂���',0
G_MES_No5:	.dc.b	'�o�b�t�@�����ӂ�܂���',0
*G_MES_No6:	.dc.b	'�G���[���������܂���',0
		.dc.b	0

CURDRV_BACK:	.dc.b	0

		.even

STITLE:	.dc.w	%0111111110011111,%1110110000000001,%1111111001111111,%1011111111110011,%1111100111111110
	.dc.w	%1111111110111111,%1110110000000011,%1111111011111111,%1011111111110111,%1111110111111111
*	.dc.w	%1100000000110000,%0000110000000011,%0000000011000000,%0000001100000110,%0000110110000011
	.dc.w	%1100000000110000,%0000110000000011,%0000000011000000,%0000001100000110,%0000110110000011
	.dc.w	%1111111100111111,%1000110000000011,%1111100011000000,%0000001100000110,%0000110111111111
	.dc.w	%0111111110111111,%1000110000000011,%1111100011000000,%0000001100000110,%0000110111111110
*	.dc.w	%0000000110110000,%0000110000000011,%0000000011000000,%0000001100000110,%0000110110000011
	.dc.w	%0000000110110000,%0000110000000011,%0000000011000000,%0000001100000110,%0000110110000011
	.dc.w	%1111111110111111,%1110111111111011,%1111111011111111,%1000001100000111,%1111110110000011
	.dc.w	%1111111100011111,%1110011111111001,%1111111001111111,%1000001100000011,%1111100110000011
	.dc.w	%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000,%0000000000000000
	.dc.w	%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111,%1111111111111111

		.end

�t�@�C���l�[���o�b�t�@(32byte/file)
+00.b	�f�[�^���(0:dir 1:mdx...) �}�C�i�X��������f�B���N�g����
+01.b	�I�[�g�����t�ς݃t���O
+02.w	(�f�B���N�g���̏ꍇ�Ȃ�t�@�C����������)
+04.l	�^�C�g���o�b�t�@�̃A�h���X�A�������Ȃ�0
+08.b	�t�@�C����+$00
+31	�I���

�^�C�g���o�b�t�@
+00	�^�C�g��
+??	$00


�t�@�C���Z���N�^�Ɋւ��Ă̍\�z�E�E�E

���
�O�F�����s���ĂȂ��A���߂Ă̏��
�P�F�^�C�g��������	(title)
�Q�F�t�@�C���Z���N�g��	(title)
�R�F�h���C�u�Z���N�g��	(title)
*�S�F�t�@�C���Z���N�g��	(file)
*�T�F�h���C�u�Z���N�g��	(file)


�g���q�Ə����h���C�o�ꗗ
*MDX:MXDRV
*MDR:MADRV
*RCP:RCD
*MDF:LZM
*MCP:RCD
*MDI:MDD
*SNG:�~���[�W����/Mu-1/MusicStudio
*MID:STD MIDI
*STD:STD MIDI
*MFF:STD MIDI
*SEQ:�|�B��
*MDZ:MLD
*MDN:NAGDRV
*KMD:KIMELA
*ZMS:ZMUSIC
*ZMD:ZMUSIC
*OPM:OPMDRV
*ZDF:LZZ
*MM2:
*MMC:

*���t�t�@�C�����ʃR�[�h�ꗗ
* 0:none 1:MDX  2:MDR  3:RCP  4:MDF  5:MCP  6:MDI  7:SNG
* 8:MID  9:STD 10:MFF 11:SEQ 12:MDZ 13:MDN 14:KMD 15:ZMS
*16:ZMD 17:OPM 18:ZDF 19:MM2 20:MMC

