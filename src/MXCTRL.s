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
		.include	DRIVER.h


*==================================================
* MXDRV �G���g���[�e�[�u��
*==================================================

		.xdef	MXDRV_ENTRY

FUNC		.macro	entry
		.dc.w	entry-MXDRV_ENTRY
		.endm

MXDRV_ENTRY:
		FUNC	MXDRV_CHECK
		FUNC	MXDRV_NAME
		FUNC	MXDRV_INIT
		FUNC	MXDRV_SYSSTAT
		FUNC	MXDRV_TRKSTAT
		FUNC	MXDRV_GETMASK
		FUNC	MXDRV_SETMASK
		FUNC	MXDRV_FILEEXT
		FUNC	MXDRV_FLOADP
		FUNC	MXDRV_PLAY
		FUNC	MXDRV_PAUSE
		FUNC	MXDRV_CONT
		FUNC	MXDRV_STOP
		FUNC	MXDRV_FADEOUT
		FUNC	MXDRV_SKIP
		FUNC	MXDRV_SLOW

*==================================================
* MXDRV ���[�J�����[�N�G���A
*==================================================

		.offset	DRV_WORK
MX_BUF:		.ds.l	1	*�l�w�c�q�u�o�b�t�@�A�h���X
MX_BUF2:	.ds.l	1	*�l�w�c�q�u�C�o�b�l�W�p�o�b�t�@�A�h���X
		.text

MXDRV		.macro	func
		moveq	func,d0
		TRAP	#4
		.endm


*==================================================
* MXDRV �풓�`�F�b�N
*==================================================

MXDRV_CHECK:
		move.l	a0,-(sp)
		move.l	$24*4.w,a0
		cmp.l	#"mxdr",-8(a0)
		bne	not_keeped
		cmp.l	#"v206",-4(a0)
		bcs	not_keeped
		move.l	-12(a0),d0
		cmp.l	#'EX16',d0			*�o�[�W������
		bcc	keeped				*	�Q�D�O�U�{�P�U�ȏ�
not_keeped:
		moveq	#-1,d0
keeped:
		move.l	(sp)+,a0
		rts

*==================================================
* MXDRV �h���C�o���擾
*==================================================

MXDRV_NAME:
		move.l	a0,-(sp)
		lea	name_buf(pc),a0
		move.l	a0,d0
		move.l	(sp)+,a0
		rts

name_buf:	.dc.b	'MXDRV',0
		.even


*==================================================
* MXDRV �h���C�o������
*==================================================

MXDRV_INIT:
		move.l	a0,-(sp)
		MXDRV	#$10			*�e�l�o�b�t�@�A�h���X�𓾂�
		move.l	d0,MX_BUF(a6)
		MXDRV	#$18			*�o�b�l�o�b�t�@�A�h���X�𓾂�
		move.l	d0,MX_BUF2(a6)

		lea	TRACK_STATUS(a6),a0	*������ނȂǂ̏�����
		moveq	#8-1,d0
mxdrv_init10:
		move.b	#1,INSTRUMENT(a0)
		move.b	#2,INSTRUMENT+TRST*8(a0)
		move.w	#15,KEYOFFSET(a0)
		move.w	#15,KEYOFFSET+TRST*8(a0)
		move.b	#-1,KEYONSTAT(a0)
		move.b	#-1,KEYONSTAT+TRST*8(a0)
		lea	TRST(a0),a0
		dbra	d0,mxdrv_init10

		lea	TRACK_STATUS(a6),a0	*�g���b�N�ԍ�������
		moveq	#1,d0
mxdrv_init20:
		move.b	d0,TRACKNO(a0)
		lea	TRST(a0),a0
		addq.w	#1,d0
		cmpi.w	#16,d0
		bls	mxdrv_init20

		clr.l	TRACK_ENABLE(a6)
		move.w	#222,CYCLETIM(a6)
		move.w	#77,TITLELEN(a6)

		move.l	(sp)+,a0
		rts


*==================================================
* MXDRV �V�X�e�����擾
*==================================================

MXDRV_SYSSTAT:
		movem.l	d0-d2/a0,-(sp)

		moveq	#0,d1
		MXDRV	#$08				*�^�C�g���A�h���X
		move.l	d0,SYS_TITLE(a6)

		move.l	MX_BUF(a6),a0			*���[�v�J�E���^
		move.w	$40A(a0),SYS_LOOP(a6)

		moveq	#0,d0				*�e���|
		move.b	$12(a0),d0
		move.w	d0,SYS_TEMPO(a6)
		sne	d2

		MXDRV	#$12				*���t���t���O
		tst.w	d0
		seq.b	d1
		and.b	d2,d1
		ext.w	d1
		move.w	d1,PLAY_FLAG(a6)

		tst.b	d0				*���t�I���t���O
		sne.b	d1
		ext.w	d1
		move.w	d1,PLAYEND_FLAG(a6)

		movem.l	(sp)+,d0-d2/a0
		rts


*==================================================
* MXDRV �X�e�[�^�X�擾
*==================================================

MXDRV_TRKSTAT:
		bsr	MXDRV_KBSSET
		bsr	MXDRV_TRACK
		rts

*
*	���l�w�c�q�u�Q�j�a�r�r�d�s
*�@�\�F�l�w�c�q�u�̃L�[�{�[�h�X�e�[�^�X�𓾂�
*���o�́F�Ȃ�
*�Q�l�F�b�g�r�s�Q�a�e�Q�v�i���U�j�ɂ��������ނ��
*

MXDRV_KBSSET:
		movem.l	d0-d1/d6-d7/a0-a3,-(sp)

		lea.l	CHST_BF(a6),a0
		move.l	MX_BUF(a6),a2
		lea.l	$100(a2),a3

		moveq.l	#7,d7
mx_kbsset_loop:
		moveq.l	#0,d6

		move.b	$16(a3),d0
		btst.l	#5,d0				*C:�l�o
		sne.b	d1
		cmp.b	KBS_MP(a0),d1
		beq	mx_kbsset_jp01
		bset.l	#$C,d6
		move.b	d1,KBS_MP(a0)
mx_kbsset_jp01:
		btst.l	#6,d0				*D:�l�`
		sne.b	d1
		cmp.b	KBS_MA(a0),d1
		beq	mx_kbsset_jp02
		bset.l	#$D,d6
		move.b	d1,KBS_MA(a0)
mx_kbsset_jp02:
		moveq.l	#0,d0
		move.b	$18(a3),d0			*E:�l�g
		tst.b	$38(a2,d0.w)
		sne.b	d1
		cmp.b	KBS_MH(a0),d1
		beq	mx_kbsset_jp03
		bset.l	#$E,d6
		move.b	d1,KBS_MH(a0)
mx_kbsset_jp03:
		move.b	$1F(a3),d0			*0:��
		cmp.b	KBS_k(a0),d0
		beq	mx_kbsset_jp0
		bset.l	#0,d6
		move.b	d0,KBS_k(a0)
mx_kbsset_jp0:
		move.b	$1E(a3),d0			*1:��
		cmp.b	KBS_q(a0),d0
		beq	mx_kbsset_jp2
		bset.l	#1,d6
		move.b	d0,KBS_q(a0)
mx_kbsset_jp2:
		move.w	$10(a3),d0			*2:�c
		cmp.w	KBS_D(a0),d0
		beq	mx_kbsset_jp3
		bset.l	#2,d6
		move.w	d0,KBS_D(a0)
mx_kbsset_jp3:
		move.w	$36(a3),d0			*3:�o
		cmp.w	KBS_P(a0),d0
		beq	mx_kbsset_jp4
		bset.l	#3,d6
		move.w	d0,KBS_P(a0)
mx_kbsset_jp4:
		move.w	$C(a3),d0			*4:�a
		cmp.w	KBS_B(a0),d0
		beq	mx_kbsset_jp5
		bset.l	#4,d6
		move.w	d0,KBS_B(a0)
mx_kbsset_jp5:
		move.b	$4A(a3),d0			*5:�`
		ext.w	d0
		neg.w	d0
		cmp.w	KBS_A(a0),d0
		beq	mx_kbsset_jp6
		bset.l	#5,d6
		move.w	d0,KBS_A(a0)
mx_kbsset_jp6:
		move.l	$4(a3),d0			*6:��
		beq	mx_kbsset_jp7
		move.l	d0,a1				*A1 is Used!!!
		moveq.l	#0,d0
		move.b	-1(a1),d0
		cmp.w	KBS_PROG(a0),d0
		beq	mx_kbsset_jp7
		bset.l	#6,d6
		move.w	d0,KBS_PROG(a0)
mx_kbsset_jp7:
		moveq.l	#0,d0
		move.b	$22(a3),d0			*7:�����P
		bclr.l	#7,d0
		bne	mx_kbsset_jp9
		lea.l	VOL_DEFALT(pc),a1
		move.b	0(a1,d0.w),d0
		bra	mx_kbsset_jpA
mx_kbsset_jp9:	neg.b	d0
		add.b	#$7F,d0
mx_kbsset_jpA:	cmp.b	KBS_TL1(a0),d0
		beq	mx_kbsset_jpB
		bset.l	#7,d6
		move.b	d0,KBS_TL1(a0)
mx_kbsset_jpB:
		move.b	$23(a3),d0			*8:�����Q
		neg.b	d0
		add.b	#$7F,d0
		cmp.b	KBS_TL2(a0),d0
		beq	mx_kbsset_jpC
		bset.l	#8,d6
		move.b	d0,KBS_TL2(a0)
mx_kbsset_jpC:
		move.l	(a3),d0				*9:�c�`�s�`
		cmp.l	KBS_DATA(a0),d0
		beq	mx_kbsset_jpD
		bset.l	#9,d6
		move.l	d0,KBS_DATA(a0)
mx_kbsset_jpD:
		move.w	$12(a3),d0			*A:�j�b�P
		cmp.w	KBS_KC1(a0),d0
		beq	mx_kbsset_jpF
		bset.l	#$A,d6
		move.w	d0,KBS_KC1(a0)
mx_kbsset_jpF:
		move.w	$14(a3),d0			*B:�j�b�Q
		cmp.w	KBS_KC2(a0),d0
		beq	mx_kbsset_jpG
		bset.l	#$B,d6
		move.w	d0,KBS_KC2(a0)
mx_kbsset_jpG:

		move.w	d6,KBS_CHG(a0)			*�`�F�b�N�t���O��������

		lea.l	CHST(a0),a0
		lea.l	$50(a3),a3
		dbra	d7,mx_kbsset_loop

		movem.l	(sp)+,d0-d1/d6-d7/a0-a3
		rts


*==================================================
*MXDRV �g���b�N���擾
*==================================================

MXDRV_TRACK:
		movem.l	d0-d2/d5/d7/a0-a3,-(sp)
		movea.l	MX_BUF(a6),a0
		lea	$100(a0),a1
		lea	$400(a0),a2
		lea	TRACK_STATUS(a6),a3

		moveq	#0,d2				*�g���b�N���t�󋵎��o��
		move.w	-$120(a1),d2
		not.w	d2
		and.w	-$136(a1),d2
		move.l	TRACK_ENABLE(a6),d0
		move.l	d2,TRACK_ENABLE(a6)
		eor.l	d2,d0
		move.l	d0,TRACK_CHANGE(a6)

		moveq	#0,d1
		moveq	#8-1,d7				*FM 0-7
mxdrv_track10:
		bsr	get_trackFM
		lea	$50(a1),a1
		addq.l	#1,a2
		lea	TRST(a3),a3
		addq.w	#1,d1
		dbra	d7,mxdrv_track10

		movea.l	MX_BUF2(a6),a2
		subq.l	#8,a2
		bsr	get_trackPCM			*PCM 0
		addq.l	#1,a2
		lea	TRST(a3),a3
		addq.l	#1,d1

		movea.l	MX_BUF2(a6),a1			*PCM 1-7
		moveq	#7-1,d7
mxdrv_track20:
		bsr	get_trackPCM
		lea	$50(a1),a1
		addq.l	#1,a2
		lea	TRST(a3),a3
		addq.l	#1,d1
		dbra	d7,mxdrv_track20

		movem.l	(sp)+,d0-d2/d5/d7/a0-a3
		rts

*�e�l�g���b�N�X�e�[�^�X���o��
*	d1.l <- track no
*	d2.l <- track enable
*	a1.l <- mxdrv buffer address
*	a2.l <- keyon buffer address
*	a3.l <- TRACK_STATUS address


get_trackFM:
		moveq	#0,d5
		clr.l	STCHANGE(a3)

		move.w	$14(a1),d0			*FM BEND
		sub.w	$12(a1),d0
		add.w	$10(a1),d0
		cmp.w	BEND(a3),d0
		beq	get_trackFM10
		move.w	d0,BEND(a3)
		bset	#1,d5
get_trackFM10:
		moveq	#$C0,d0				*FM PAN
		and.b	$1C(a1),d0
		rol.b	#2,d0
		cmp.w	PAN(a3),d0
		beq	get_trackFM20
		move.w	d0,PAN(a3)
		bset.l	#2,d5
get_trackFM20:
		move.l	$4(a1),d0			*FM PROGRAM
		beq	get_trackFM30
		movea.l	d0,a0
		moveq	#0,d0
		move.b	-1(a0),d0
		cmp.w	PROGRAM(a3),d0
		beq	get_trackFM30
		move.w	d0,PROGRAM(a3)
		bset.l	#3,d5
get_trackFM30:
		move.b	(a2),d0				*FM KEYON
		bset.b	#7,(a2)
		bne	get_trackFM40
		move.b	#$01,KEYONCHANGE(a3)
		and.b	#$78,d0
		seq.b	d0
		ori.b	#$FE,d0
		move.b	d0,KEYONSTAT(a3)
get_trackFM40:
		move.w	$12(a1),d0			*FM KEYCODE
		sub.w	$10(a1),d0
		subq.w	#5,d0
		bpl	get_trackFM41
		moveq.l	#0,d0
get_trackFM41:	lsr.w	#6,d0
		cmp.b	KEYCODE(a3),d0
		beq	get_trackFM50
		move.b	#$01,KEYCHANGE(a3)
		move.b	d0,KEYCODE(a3)
get_trackFM50:
		move.b	$23(a1),d0			*FM VELOCITY
		neg.b	d0
		add.b	#$7F,d0
		cmp.b	VELOCITY(a3),d0
		beq	get_trackFM90
		move.b	#$01,VELCHANGE(a3)
		move.b	d0,VELOCITY(a3)
get_trackFM90:
		move.b	d5,STCHANGE(a3)
		rts


*�o�b�l�g���b�N�X�e�[�^�X���o��
*	a1.l <- mxdrv buffer address
*	a2.l <- keyon buffer address
*	a3.l <- TRACK_STATUS address

pan_dataPCM:	dc.w	$FF03,$FF01,$FF02,$FF00

get_trackPCM:
		moveq	#0,d5
		clr.l	STCHANGE(a3)

		move.b	$1C(a1),d0			*PCM PAN
		add.w	d0,d0
		andi.w	#$0006,d0
		move.w	pan_dataPCM(pc,d0.w),d0
		cmp.w	PAN(a3),d0
		beq	get_trackPCM10
		move.w	d0,PAN(a3)
		bset.l	#2,d5
get_trackPCM10:
		move.l	$4(a1),d0			*PCM PROGRAM
		beq	get_trackPCM20
		movea.l	d0,a0
		moveq	#0,d0
		move.b	-1(a0),d0
		cmp.w	PROGRAM(a3),d0
		beq	get_trackPCM20
		move.w	d0,PROGRAM(a3)
		bset.l	#3,d5
get_trackPCM20:
		move.b	(a2),d0				*PCM KEYON
		st.b	(a2)
		cmp.b	#$FF,d0
		beq	get_trackPCM21
		move.b	#$01,KEYONCHANGE(a3)
		move.b	#$FE,KEYONSTAT(a3)
		bra	get_trackPCM30
get_trackPCM21:
		btst.b	#0,KEYONSTAT(a3)
		bne	get_trackPCM30
		btst.b	#3,$16(a1)
		bne	get_trackPCM30
		move.b	#$01,KEYONCHANGE(a3)
		move.b	#$FF,KEYONSTAT(a3)
get_trackPCM30:
		move.w	$12(a1),d0			*PCM KEYCODE
		sub.w	$10(a1),d0
		subq.w	#5,d0
		bpl	get_trackPCM31
		moveq.l	#0,d0
get_trackPCM31:
		lsr.w	#6,d0
		cmp.b	KEYCODE(a3),d0
		beq	get_trackPCM40
		move.b	#$01,KEYCHANGE(a3)
		move.b	d0,KEYCODE(a3)
get_trackPCM40:
		moveq.l	#0,d0				*PCM VELOCITY
		move.b	$22(a1),d0
		bclr.l	#7,d0
		bne	get_trackPCM41
		lea.l	VOL_DEFALT(pc),a0
		move.b	0(a0,d0.w),d0
		bra	get_trackPCM42
get_trackPCM41:
		neg.b	d0
		addi.b	#$7F,d0
get_trackPCM42:
		cmp.b	VELOCITY(a3),d0
		beq	get_trackPCM90
		move.b	#$01,VELCHANGE(a3)
		move.b	d0,VELOCITY(a3)
get_trackPCM90:
		move.b	d5,STCHANGE(a3)
		rts


*==================================================
* MXDRV ���t�g���b�N����
*	d0 -> �g���b�N�t���O
*==================================================

MXDRV_GETMASK:
		move.l	TRACK_ENABLE(a6),d0
		rts


*==================================================
* MXDRV ���t�g���b�N�ݒ�
*	d1 <- �g���b�N�t���O
*==================================================

MXDRV_SETMASK:
		movem.l	d0-d1,-(sp)
		not.l	d1
		MXDRV	#14
		movem.l	(sp)+,d0-d1
		rts

*==================================================
*�g���q�e�[�u��
*==================================================

MXDRV_FILEEXT:
		move.l	a0,-(sp)
		lea	ext_buf(pc),a0
		move.l	a0,d0
		move.l	(sp)+,a0
		rts

ext_buf:	.dc.b	_MDX,'MDX'
		.dc.b	_ZDF,'ZDF'
		.dc.b	0
		.even


*==================================================
*�l�c�w�f�[�^�ǂݍ��݃��[�`��
*	a1.l <- �t�@�C���l�[��
*	d0.b <- ���t�f�[�^�̎��ʃR�[�h
*	d0.l -> ���Ȃ�G���[
*==================================================

MXDRV_FLOADP:
		movem.l	d1/a1,-(sp)
		cmpi.b	#_MDX,d0
		beq	floadp_mdx
		cmpi.b	#_ZDF,d0
		beq	floadp_zdf
		movem.l	(sp)+,d1/a1
		moveq	#-1,d0
		rts

floadp_mdx:
		move.l	a1,-(sp)
		bsr	LOAD_MDX
		bra	floadp90
floadp_zdf:
		move.l	a1,-(sp)
		bsr	LOAD_ZDF
floadp90:
		addq.l	#4,sp
		neg.l	d0
		cmpi.w	#7,d0
		bls	floadp91
		moveq	#7,d0
floadp91:
		move.b	errcnvtbl(pc,d0.w),d1	*�G���[�ԍ��ϊ�
		ext.w	d1
		ext.l	d1
		andi.w	#$007f,d1
		bsr	MXDRV_STOP		*���t��~
		tst.l	d1
		bmi	floadp92
		bsr	MXDRV_PLAY		*���t�J�n
floadp92:
		move.l	d1,d0
		lea	MMDSP_NAME(pc),a0	*�v���[������MMDSP
		movem.l	(sp)+,d1/a1
		rts

errcnvtbl:	.dc.b	$00,$82,$03,$85,$87,$08,$8a,$81
		.even


*==================================================
*�l�c�w�t�@�C�������[�h����
*	LOAD_MDX(char *name)
*	name	�t�@�C����
*	d0.l -> ���Ȃ�A�G���[
*		-1 MDX���[�h�G���[
*		-2 PDX���[�h�G���[
*		-3 �������s��
*		-4 MDX�o�b�t�@�s��
*		-5 PCM�o�b�t�@�s��
*		-6 �t�H�[�}�b�g�G���[
*==================================================

		.offset	-512
mdx_title	.ds.b	256
pdx_name	.ds.b	256
		.text

LOAD_MDX:
		movem.l	d1-d3/a0-a1,-(sp)
		movea.l	(5+1)*4(sp),a0
		link	a6,#-512

		moveq	#0,d3
		moveq	#-1,d0
		movea.l	d0,a1

*		pea	ext_mdx(pc)		*�g���q���Ȃ���΂���
*		pea	(a0)
*		bsr	ADD_EXT

		clr.l	-(sp)			*MDX�t�@�C����ǂݍ���
		pea	env_mxp(pc)
		pea	(a0)
		bsr	READ_FILE
		move.l	d0,d1
		bpl	load_mdx10
		moveq	#-1,d0
		bra	load_mdx90

load_mdx10:
		movea.l	a0,a1
		pea	pdx_name(a6)		*�w�b�_����͂���
		pea	mdx_title(a6)
		pea	(a1)
		bsr	CHECK_HEADER
		move.l	d0,d2
		bmi	load_mdx90

		tst.b	pdx_name(a6)		*PDX�������
		beq	load_mdx20
		pea	pdx_name(a6)
		bsr	LOAD_PDX		*���[�h����
		move.l	d0,d3

load_mdx20:
		pea	pdx_name(a6)		*�h���C�o�ɓ]������
		pea	mdx_title(a6)
		sub.l	d2,d1
		move.l	d1,-(sp)
		pea	(a1,d2.l)
		bsr	TRANS_MDX
		tst.l	d0
		bmi	load_mdx90
		move.l	d3,d0

load_mdx90:
		move.l	d0,d1
		pea	(a1)			*MDX�̃������͊J������
		bsr	FREE_MEM
		move.l	d1,d0
		unlk	a6
		movem.l	(sp)+,d1-d3/a0-a1
		rts


*==================================================
*�l�c�w�w�b�_���`�F�b�N����
*	CHECK_HEADER(char *mdx, char *title, char *pdx)
*	mdx	MDX�f�[�^�̃A�h���X
*	title	�^�C�g�����i�[����A�h���X
*	pdx	PDX�t�@�C�������i�[����A�h���X
*	d0.l -> �w�b�_�����̒���(���Ȃ�G���[)
*==================================================

CHECK_HEADER:
		movem.l	d1/a0-a3,-(sp)
		movem.l	(5+1)*4(sp),a1-a3
		movea.l	a1,a0

		move.w	#255-1,d1		*�^�C�g�����R�s�[����
check_header10:
		move.b	(a0)+,d0
		cmpi.b	#$0d,d0
		beq	check_header11
		move.b	d0,(a2)+
		dbra	d1,check_header10
		moveq	#-6,d0
		bra	check_header90
check_header11:
		clr.b	(a2)
		addq.l	#2,a0

		move.w	#255-1,d1		*PDX�t�@�C�������R�s�[����
check_header20:
		move.b	(a0)+,(a3)+
		dbeq	d1,check_header20
		beq	check_header30
		moveq	#-6,d0
		bra	check_header90

check_header30:
		move.l	a0,d0			*�w�b�_�����̒��������߂�
		sub.l	a1,d0

check_header90:
		movem.l	(sp)+,d1/a0-a3
		rts


*==================================================
*�l�c�w�f�[�^���h���C�o�ɓ]������
*	TRANS_MDX(char *mml, int len, char *title, char *pdxname)
*	mml	MML�̐擪�A�h���X
*	len	MML�f�[�^�̒���
*	title	�^�C�g���̃A�h���X
*	pdxname	pdx�t�@�C����(PDX�L���`�F�b�N�Ɏg�p)
*	d0.l -> ���Ȃ�G���[
*==================================================

TRANS_MDX:
		movem.l	d1-d2/a0-a4,-(sp)
		movem.l	(7+1)*4(sp),a1-a4
		link	a6,#0

		moveq	#-1,d2			*�o�b�t�@�|�C���^������

		pea	270(a2)			*MML�̒���+270�̑傫����
		DOS	_MALLOC			*�o�b�t�@���m�ۂ���
		move.l	d0,d2
		bpl	trans_mdx10
		moveq	#-3,d0
		bra	trans_mdx90

trans_mdx10:
		movea.l	d2,a0			*�w�b�_���Z�b�g����
		clr.w	(a0)+			*(mdx�g�p�t���O)
		tst.b	(a4)			*(pdx�g�p�t���O)
		seq	d0
		ext.w	d0
		move.w	d0,(a0)+
		move.w	#270,(a0)+		*(mml�܂ł̃I�t�Z�b�g)
		move.w	#8,(a0)+		*(mdx�^�C�g���܂ł̃I�t�Z�b�g)

trans_mdx20:
		move.b	(a3)+,(a0)+		*�^�C�g�����o�b�t�@�ɃR�s�[
		bne	trans_mdx20

		movea.l	d2,a0			*MML���o�b�t�@�ɃR�s�[
		lea	270(a0),a0
		move.l	a2,d1
trans_mdx30:
		move.b	(a1)+,(a0)+
		subq.l	#1,d1
		bne	trans_mdx30

		lea	270(a2),a2		*MXDRV�ɓ]��
		move.l	a2,d1
		movea.l	d2,a1
		MXDRV	#$02
		tst.l	d0
		bpl	trans_mdx40
		moveq	#-4,d0
		bra	trans_mdx90
trans_mdx40:
		moveq	#0,d0

trans_mdx90:
		move.l	d0,d1
		move.l	d2,-(sp)		*�o�b�t�@���J������
		bsr	FREE_MEM
		move.l	d1,d0

		unlk	a6
		movem.l	(sp)+,d1-d2/a0-a4
		rts


*==================================================
*�o�c�w�t�@�C�������[�h����
*	LOAD_PDX(char *name)
*	name	�t�@�C����
*	d0.l -> ���Ȃ�A�G���[
*		-1 MDX���[�h�G���[
*		-2 PDX���[�h�G���[
*		-3 �������s��
*		-4 MDX�o�b�t�@�s��
*		-5 PCM�o�b�t�@�s��
*		-6 �t�H�[�}�b�g�G���[
*==================================================


LOAD_PDX:
		movem.l	d1-d3/a0-a1,-(sp)
		movea.l	(5+1)*4(sp),a1
		link	a6,#0

		moveq	#0,d2
		moveq	#-1,d3			*�o�b�t�@�|�C���^������

		pea	ext_pdx(pc)		*�g���q���Ȃ���΂���
		pea	(a1)
		bsr	ADD_EXT

		moveq	#0,d1			*�h���C�o����PDX�Ɠ����Ȃ�I���
		MXDRV	#$09
		move.l	d0,-(sp)
		beq	load_pdx10
		pea	(a1)
		bsr	STRCMPI
		tst.l	d0
		beq	load_pdx90

load_pdx10:
		move.l	#270,-(sp)		*PDX�t�@�C����ǂݍ���
		pea	env_mxp(pc)
		pea	(a1)
		bsr	READ_FILE
		move.l	d0,d2
		bpl	load_pdx20
		addq.l	#1,d0
		beq	load_pdx_loaderr
		bra	load_pdx_memerr

load_pdx20:
		move.l	a0,d3
		pea	(a1)			*�h���C�o�ɓ]������
		move.l	#270,-(sp)
		move.l	d2,-(sp)
		move.l	d3,-(sp)
		bsr	TRANS_PDX
		move.l	d0,d2
		bra	load_pdx90

load_pdx_memerr:
		moveq	#-3,d2
		bra	load_pdx90
load_pdx_loaderr:
		moveq	#-2,d2
		bra	load_pdx90

load_pdx90:
		move.l	d3,-(sp)
		bsr	FREE_MEM

		tst.l	d2
		bpl	load_pdx91
		bsr	CLEAR_PDX
load_pdx91:
		move.l	d2,d0
		unlk	a6
		movem.l	(sp)+,d1-d3/a0-a1
		rts


*==================================================
*�o�c�w�f�[�^���h���C�o�ɓ]������
*	TRANS_PDX(char *pdx, int len, int hedlen, char *pdxname)
*	pdx	PDX�̐擪�A�h���X(�w�b�_�t��)
*	len	PDX�f�[�^�̒���(�w�b�_����)
*	hedlen	�w�b�_�̒���
*	pdxname	pdx�t�@�C����
*	d0.l -> ���Ȃ�G���[
*==================================================

TRANS_PDX:
		movem.l	d1/a1-a4,-(sp)
		movem.l	(5+1)*4(sp),a1-a4

		move.l	a1,a0			*�w�b�_���Z�b�g����
		clr.l	(a0)+			*(mdx/pdx�g�p�t���O)
		move.w	a3,(a0)+		*(pdx�܂ł̃I�t�Z�b�g)
		move.w	#8,(a0)+		*(pdx�^�C�g���܂ł̃I�t�Z�b�g)

trans_pdx10:
		move.b	(a4)+,(a0)+		*�^�C�g�����o�b�t�@�ɃR�s�[
		bne	trans_pdx10

		move.l	a2,d1			*MXDRV�ɓ]��
		add.l	a3,d1
		MXDRV	#$03
		tst.l	d0
		bmi	trans_pdx_buferr
		moveq	#0,d0
		bra	trans_pdx90

trans_pdx_buferr:
		moveq	#-5,d0
trans_pdx90:
		movem.l	(sp)+,d1/a1-a4
		rts


*==================================================
*�o�c�w���N���A����
*==================================================

CLEAR_PDX:
		movem.l	d1-d2/a0-a1,-(sp)
		link	a6,#0

		move.l	#8*96*8+8,-(sp)			*�o�b�t�@���m�ۂ���
		DOS	_MALLOC
		move.l	d0,d2
		bmi	clear_pdx90

		move.l	d2,a0
		move.w	#(8*96*8+8)/4-1,d0		*�o�b�t�@���N���A����
clear_pdx10:
		clr.l	(a0)+
		dbra	d0,clear_pdx10

		move.l	d2,a1				*MXDRV�ɓ]��
		move.l	#8*96*8+8,d1
		MXDRV	#$03

		move.l	d2,-(sp)			*�o�b�t�@���J������
		bsr	FREE_MEM

clear_pdx90:
		unlk	a6
		movem.l	(sp)+,d1-d2/a0-a1
		rts


*==================================================
*�y�c�e�t�@�C�������[�h����
*	LOAD_ZDF(char *name)
*	name	�t�@�C����
*	d0.l -> ���Ȃ�A�G���[
*		-1 MDX���[�h�G���[
*		-2 PDX���[�h�G���[
*		-3 �������s��
*		-4 MDX�o�b�t�@�s��
*		-5 PCM�o�b�t�@�s��
*		-6 �t�H�[�}�b�g�G���[
*==================================================

		.offset	-566
zmdx_title	.ds.b	256
zpdx_name	.ds.b	256
zdf_table	.ds.b	54
		.text

LOAD_ZDF:
		movem.l	d1-d3/a0,-(sp)
		move.l	(4+1)*4(sp),a0
		link	a6,#-566

		moveq	#-1,d1			*ZDF�o�b�t�@�|�C���^
		moveq	#-1,d2			*LZZ�o�b�t�@�|�C���^
		moveq	#-1,d3			*MDX�o�b�t�@�|�C���^

*		pea	ext_zdf(pc)		*�g���q���Ȃ���΂���
*		pea	(a0)
*		bsr	ADD_EXT

		clr.l	-(sp)			*ZDF�t�@�C����ǂݍ���
		pea	env_mxp(pc)
		pea	(a0)
		bsr	READ_FILE
		tst.l	d0
		bmi	load_zdf_mdxloaderr
		move.l	a0,d1

		pea	zdf_table(a6)		*ZDF�f�[�^���I�[�v��
		move.l	d1,-(sp)
		bsr	OPEN_ZDF
		move.l	d0,d2
		bmi	load_zdf_mdxloaderr

		lea	zdf_table(a6),a0	*MDX�f�[�^�����邩���ׁA
		tst.w	(a0)+
		beq	load_zdf_mdxloaderr
		cmpi.w	#ZDF_MDX,(a0)
		bne	load_zdf_mdxloaderr

		clr.l	-(sp)			*����΁A�𓀂���
		move.l	6(a0),-(sp)
		move.l	2(a0),-(sp)
		move.l	d2,-(sp)
		bsr	EXTRACT_ZDF
		move.l	d0,d3
		bmi	load_zdf_mdxloaderr

		pea	zpdx_name(a6)		*�w�b�_����͂���
		pea	zmdx_title(a6)
		move.l	d3,-(sp)
		bsr	CHECK_HEADER
		move.l	d0,d4
		bmi	load_zdf90

		pea	zpdx_name(a6)		*�h���C�o�ɓ]������
		pea	zmdx_title(a6)
		move.l	6(a0),d0
		sub.l	d4,d0
		move.l	d0,-(sp)
		move.l	d3,d0
		add.l	d4,d0
		move.l	d0,-(sp)
		bsr	TRANS_MDX
		tst.l	d0
		bmi	load_zdf90

		moveq	#0,d0
		tst.b	zpdx_name(a6)		*pdx�������
		beq	load_zdf90

		move.l	d2,-(sp)		*�]������
		pea	zdf_table(a6)
		pea	zpdx_name(a6)
		bsr	TRANS_ZPDX
		tst.l	d0
		bmi	load_zdf90

		moveq	#0,d0
		bra	load_zdf90

load_zdf_mdxloaderr:
		moveq	#-1,d0

load_zdf90
		movea.l	d0,a0
		move.l	d1,-(sp)		*ZDF�̃�������
		bsr	FREE_MEM
		move.l	d2,(sp)			*LZZ�̃�������
		bsr	FREE_MEM
		move.l	d3,(sp)			*MDX�̃��������J������
		bsr	FREE_MEM
		move.l	a0,d0
		unlk	a6
		movem.l	(sp)+,d1-d3/a0
		rts

*==================================================
*�y�c�e���̂o�c�w���h���C�o�ɓ]������
*	TRANS_ZPDX(char *pdxname, short *zdftbl, void *lzz)
*	pdxname	pdx�t�@�C����
*	zdftbl	OPEN_ZDF�œ�����e�[�u��
*	lzz	lzz�����[�h����Ă���A�h���X
*	d0.l -> ���Ȃ�G���[
*==================================================

TRANS_ZPDX:
		movem.l	d1-d2/a0-a2,-(sp)
		movem.l	(5+1)*4(sp),a0-a2
		link	a6,#0

		moveq	#-1,d2			*PDX�̃o�b�t�@�|�C���^

		pea	ext_pdx(pc)		*�g���q������
		pea	(a0)
		bsr	ADD_EXT

		moveq	#0,d1			*�h���C�o����PDX�Ɠ����Ȃ牽�����Ȃ�
		MXDRV	#$09
		move.l	d0,-(sp)
		beq	trans_zpdx10
		pea	(a0)
		bsr	STRCMPI
		tst.l	d0
		beq	trans_zpdx90

trans_zpdx10:
		move.w	(a1)+,d0		*ZDF����PDX�����邩���ׂ�
		beq	trans_zpdx20
trans_zpdx11:
		cmpi.w	#ZDF_MDX+ZDF_PCM,(a1)
		beq	trans_zpdx30
		lea	10(a1),a1
		subq.w	#1,d0
		bne	trans_zpdx11

trans_zpdx20:
		pea	(a0)			*�Ȃ���΃t�@�C�������[�h����
		bsr	LOAD_PDX
		bra	trans_zpdx90

trans_zpdx30:
		move.l	#270,-(sp)		*����Ή𓀂���
		move.l	6(a1),-(sp)
		move.l	2(a1),-(sp)
		pea	(a2)
		bsr	EXTRACT_ZDF
		move.l	d0,d2
		bmi	trans_zpdx_loaderr

		pea	(a0)			*�h���C�o�ɓ]������
		move.l	#270,-(sp)
		move.l	6(a1),-(sp)
		move.l	d2,-(sp)
		bsr	TRANS_PDX
		bra	trans_zpdx90

trans_zpdx_loaderr:
		moveq	#-2,d0

trans_zpdx90:
		move.l	d0,d1			*PDX�̃o�b�t�@���J������
		move.l	d2,-(sp)
		bsr	FREE_MEM
		tst.l	d1			*�G���[��������
		bpl	trans_zpdx91
		bsr	CLEAR_PDX		*�h���C�o�̂�PCM�o�b�t�@���N���A����
trans_zpdx91:
		move.l	d1,d0
		unlk	a6
		movem.l	(sp)+,d1-d2/a0-a2
		rts


		.data
env_mxp:	.dc.b	'mxp',0
ext_mdx:	.dc.b	'.mdx',0,0
ext_pdx:	.dc.b	'.pdx',0
ext_zdf:	.dc.b	'.zdf',0
		.text

*==================================================
* MXDRV ���t�J�n
*==================================================

MXDRV_PLAY	MXDRV	#$04
		rts


*==================================================
* MXDRV ���t���f
*==================================================

MXDRV_PAUSE:
		MXDRV	#$06
		rts


*==================================================
* MXDRV ���t�ĊJ
*==================================================

MXDRV_CONT:
		MXDRV	#$07
		rts


*==================================================
* MXDRV ���t��~
*==================================================

MXDRV_STOP:
		MXDRV	#$05
		rts


*==================================================
* MXDRV �t�F�[�h�A�E�g
*==================================================

MXDRV_FADEOUT:
		move.l	d1,-(sp)
		moveq	#20,d1
		MXDRV	#$0C
		move.l	(sp)+,d1
		rts


*==================================================
* MXDRV �X�L�b�v
*	d0.w <- �X�L�b�v�J�n�t���O
*==================================================

MXDRV_SKIP:
		tst.w	d0
		bne	mxdrv_skip10
		move.b	#$00,$80e.w
		bra	mxdrv_skip20
mxdrv_skip10:
		move.b	#$0A,$80e.w		*CTRL+OPT2
mxdrv_skip20:
		rts

*==================================================
* MXDRV �X���[
*	d0.w <- �X���[�J�n�t���O
*==================================================

MXDRV_SLOW:
		tst.w	d0
		bne	mxdrv_slow10
		move.b	#$00,$80e.w
		bra	mxdrv_slow20
mxdrv_slow10:
		move.b	#$06,$80e.w		*CTRL+OPT1
mxdrv_slow20:
		rts

		.end

*==================================================
* MXDRV �\���̒�`(�Q�l)
*==================================================

		.offset	0

-$36
playflag:	ds.w	1
-$30
tempo1:		ds.w	1
-$20
trackmask:	ds.w	1
$00
register:	ds.b	256
$100
FM_track:	ds.b	80*9
$3d0
mxdrv_work:	ds.b	48		*mxdrv��a5���W�X�^
$400
FM_keyon:	ds.b	8
		ds.b	1
in_mxdrv:	ds.b	1		*mxdrv���荞�ݏ������t���O(ff:in 00:out)
$40a
loop_count:	ds.w	1


register + $100				*FM�g���b�N���[�N
*$00
data_ptr:	ds.l	1		*���݂̃f�[�^�̃|�C���^
*$04
prog_ptr:	ds.l	1		*���F�f�[�^�ւ̃|�C���^(�f�[�^�擪-1�͉��F�ԍ�)
*$0c
b:		ds.w	1
*$10
d:		ds.w	1
*$12
kc:		ds.w	1		*detune�����Z����Ă���
*$14
kc2:		ds.w	1
*$16
lfo_switch1:	ds.b	1
*$18
opm_ch:		ds.b	1
*$1c
pan:		ds.b	1		*���W�X�^$20-$27�̒l(PAN,FL,CON)
*$1e
q:		ds.b	1		*bit7��@q�t���O
*$1f
k:		ds.b	1
*$22
v1:		ds.b	1		*bit7��@v�t���O
*$23
v2:		ds.b	1		*���݂̃g�[�^�����x��
*$36
p:		ds.w	1
*$4a
a:		ds.b	1


register + $3d0				mxdrv��a5���W�X�^
+$10.l		pdx buffer address
+$18.l		pdx buffer size


*----------------------------------------
*mxdrv.s
*----------------------------------------

L000084:				*MXDRV $10
	lea.l	L0019d2(pc),a0		*register
	move.l	a0,d0
	rts

L0001f8:				*MXDRV $18
	lea.l	L00175a(pc),a0		*PCM8 track work
	move.l	a0,d0
	rts

L000200:				*MXDRV $19
	lea.l	L00174a(pc),a0		*PCM8 keyon work
	move.l	a0,d0
	rts

L001746:
	.ds.b	4
L00174a:
	.ds.b	16		*PCM8 keyon work
L00175a:
	.ds.b	562		*PCM8 track work
L00198c:
	.ds.b	16
	.ds.w	1		*enable track flag
L00199e:
	.ds.b	2
	.ds.b	1		*�L�[�{�[�h�R���g���[���֎~�t���O(00�ȊO:�֎~ 00:����)
	.ds.b	1
L0019a2:
	.ds.b	2		*tempo
L0019a4:
	.ds.b	1		*tempo offset
	.ds.b	1
	.ds.b	1		*key ctrl on?
	.ds.b	1
	.ds.b	1		*pause flag(ff:pause 00:play)
	.ds.b	1		*playend flag(ff:end 00:play)
L0019aa:
	.ds.b	1		*volume offset
	.ds.b	1		*pcm cut flag(ff:cut 00:on)
	.ds.b	1
L0019ad:
	.ds.b	2
L0019af:
	.ds.b	3
L0019b2:
	.ds.w	1		*trackmask
L0019b4:
	.ds.b	6
L0019ba:
	.ds.l	1
L0019be:
	.ds.l	1
L0019c2:
	.ds.l	1
L0019c6:
	.ds.l	1
L0019ca:
	.ds.l	1
L0019ce:
	.ds.l	1
L0019d2:
	.ds.b	256		*register work
L001ad2:
	.ds.b	720		*FM track work
L001da2:			*a5
	.ds.b	12
	.ds.l	1		*MDX data header address
	.ds.l	1		*PDX data header address
	.ds.b	16
	.ds.b	1		*MDX data enable flag
	.ds.b	1		*PDX data enable flag
	.ds.b	10
L001dd2:
	.ds.b	8		*FM keyon work
	.ds.b	1
	.ds.b	1		*in mxdrv flag
	.ds.w	1		*loop count
L001dde:


