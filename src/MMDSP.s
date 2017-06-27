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
*	Modified 1992-1994 Masao Takahashi				*
*									*
*************************************************************************


		.include	iocscall.mac
		.include	doscall.mac
		.include	MMDSP.H

*DISPTEST	.equ	0			*�\�����x�e�X�g�p

			.text
			.even

START:
		bra.s	NORM_START

MM_HEADER:	.dc.b	'MMDSP000'		*���ʃw�b�_(8bytes)
MM_STAYFLAG:	.dc.l	0			*�풓�t���O($31415926�Ȃ�풓)


*==================================================
*�l�l�c�r�o�X�^�[�g�A�b�v
*==================================================

NORM_START:
		bsr	SYSTEM_INIT		*�V�X�e���A���[�N�G���A�̏�����
		bmi	ERROR_EXIT
		bsr	CHECK_OPTION		*�I�v�V�������
		bmi	ERROR_EXIT

		suba.l	a1,a1			*�X�[�p�[�o�C�U���[�h�ɂ���
		IOCS	_B_SUPER
		move.l	d0,SUPER(a6)
		movea.l	a6,a0			*�X�[�p�[�o�C�U�X�^�b�N�̐ݒ�
		adda.l	#MYSTACK,a0		*�q�v���Z�X�Ăяo�����ɖ�肪�N����̂ŁA
		movea.l	a0,sp			*���[�U�[�o�C�U�X�^�b�N�͋N�����̂܂�

.ifdef	DISPTEST
		bra	disptest
.endif
		tst.b	RESIDENT(a6)		*�풓�w��܂���
		bne	RESID_START
		tst.b	REMOVE(a6)		*�����w��̏ꍇ���ꂼ��̃X�^�[�g�A�b�v��
		bne	REMOVE_START

		bsr	SYSTEM_CHCK		*�N���\�`�F�b�N
		bsr	PRINT_ERROR
		bmi	ERROR_EXIT
		bsr	TABLE_MAKE		*�e��e�[�u���쐬
		bsr	BIND_DEFAULT		*�L�[�o�C���h

		movea.l	sp,a5			*�A�{�[�g�A�h���X�ݒ�
		lea	MYSTACK2(a6),sp
		pea	ABORT_NORM(pc)
		move.w	#_ERRJVC,-(sp)
		DOS	_INTVCS
		pea	ABORT_NORM(pc)
		move.w	#_CTRLVC,-(sp)
		DOS	_INTVCS
		movea.l	a5,sp

		bsr	KILL_BREAK		*�u���[�N�֎~
		bsr	SAVE_CURPATH		*�J�����g�f�B���N�g����ۑ����āA
		bsr	MOVE_CURPATH		*�w��̃f�B���N�g���Ɉړ�����

		bsr	DISPLAY_MAIN		*MMDSP���C��

		bsr	RESUME_CURPATH		*�J�����g�f�B���N�g����߂�
		bsr	UNLOCK_DRIVE		*���b�N�h���C�u����������
		bsr	RESUME_BREAK		*�u���[�N�֎~����

*		move.l	SUPER(a6),a1
*		IOCS	_B_SUPER

		DOS	_EXIT

ERROR_EXIT:
		move.l	d0,d1

*		move.l	SUPER(a6),a1
*		IOCS	_B_SUPER

		move.w	d1,-(sp)
		DOS	_EXIT2

ABORT_NORM:
		lea	START(pc),a6
		adda.l	#BUFFER-START,a6
		tst.b	CHILD_FLAG(a6)
		bne	abort_child
		bsr	VECTOR_DONE			*���荞�݉���
		bsr	DISP_DONE			*��ʂ�߂�
		move.w	BREAKCK_SAVE(a6),-(sp)		*break �߂�
		DOS	_BREAKCK
		addq.l	#2,sp
		clr.b	MMDSPON_FLAG(a6)
abort_child:
		move.w	#-1,-(sp)
		DOS	_EXIT2


*==================================================
*�풓�X�^�[�g�A�b�v
*==================================================

RESID_START:
		bsr	RESID_CHECK			*MMDSP�����ɏ풓���Ă�����A
		bmi	resid_start10
		pea	mes_keeperr(pc)			*���̎|�\�����ďI���
		DOS	_PRINT
		addq.l	#4,sp
		moveq	#1,d0
		bra	ERROR_EXIT
resid_start10:
		pea	mes_keep(pc)
		DOS	_PRINT
		addq.l	#4,sp

		bsr	TABLE_MAKE			*�e��e�[�u���쐬
		bsr	BIND_DEFAULT			*�L�[�o�C���h

		lea	MM_STAYFLAG(pc),a0
		move.l	#STAYID,(a0)

		move.w	#_B_KEYSNS+$100,d1		*IOCS _B_KEYSNS�̃t�b�N
		lea	KEYSNSHOOK(pc),a1
		IOCS	_B_INTVCS
		lea	ORIG_KEYSNS(pc),a0
		move.l	d0,(a0)

		movea.l	MM_MEMPTR(a6),a0		*�풓�I��
		move.l	$08(a0),d0
		lea	START(pc),a0
		sub.l	a0,d0
		clr.w	-(sp)
		move.l	d0,-(sp)
		DOS	_KEEPPR


*==================================================
*�풓�����X�^�[�g�A�b�v
*==================================================

REMOVE_START:
		bsr	RESID_CHECK			*MMDSP�풓�`�F�b�N
		bpl	remove_start10
		pea	mes_removeerr(pc)
		DOS	_PRINT
		addq.l	#4,sp
		moveq	#1,d1
		bra	ERROR_EXIT
remove_start10:
		movea.l	d0,a0
		clr.l	MM_STAYFLAG-START+$100(a0)	*�풓�h�c�̃N���A
		pea	$10(a0)

		movea.l	ORIG_KEYSNS-START+$100(a0),a1
		move.w	#_B_KEYSNS+$100,d1		*IOCS _B_KEYSNS��߂�
		IOCS	_B_INTVCS

		DOS	_MFREE				*�������̊J��
		addq.l	#4,sp

		pea	mes_remove(pc)
		DOS	_PRINT
		addq.l	#4,sp

		DOS	_EXIT


*==================================================
*�풓�����C��
*==================================================

INDOSFLAG	.equ	$1c08		*Human�̃��[�N
INDOSNUM	.equ	$1c0a		*Human�̃��[�N
INDOSSP		.equ	$1c5c		*Human�̃��[�N

ORIG_KEYSNS:	.dc.l	0	*�ύX�O�̃x�N�^�A�h���X(_B_KEYSNS)
		.even

KEYSNSHOOK:
		move.l	a6,-(sp)
		lea	START(pc),a6
		adda.l	#BUFFER-START,a6
		tst.b	MMDSPON_FLAG(a6)
		bne	keysnshook90

		movea.w	HOTKEY1ADR(a6),a0		*�N���L�[��������Ă���
		move.b	(a0),d0
		cmp.b	HOTKEY1MASK(a6),d0
		bne	keysnshook80
		movea.w	HOTKEY2ADR(a6),a0
		move.b	(a0),d0
		cmp.b	HOTKEY2MASK(a6),d0
		bne	keysnshook80
		tst.b	HOTKEY_FLAG(a6)
		bne	keysnshook90

		move.w	sr,d0				*���荞�ݒ��łȂ��Ȃ�
		andi.w	#$0700,d0
		bne	keysnshook90
		st.b	HOTKEY_FLAG(a6)
		bsr	DISP_ON				*�N��
		bra	keysnshook90
keysnshook80:
		clr.b	HOTKEY_FLAG(a6)
keysnshook90:
		move.l	(sp)+,a6
		move.l	ORIG_KEYSNS(pc),-(sp)		*����IOCS_KEYSNS��
		rts


*==================================================
*�풓 MMDSP �N��
*==================================================

DISP_ON:
		movem.l	d0-d7/a0-a6,-(sp)
		move.l	sp,SPSAVE_RESI(a6)
		movea.l	a6,a0
		adda.l	#MYSTACK,a0
		movea.l	a0,sp

		bsr	SYSTEM_CHCK			*�h���C�o�`�F�b�N
		bpl	DISP_ON00
		btst.l	#0,d0
		beq	DISP_ON90
		clr.w	DRV_MODE(a6)
		bsr	SYSTEM_CHCK
		bmi	DISP_ON90
DISP_ON00:
		move.l	INDOSSP.w,INDOSSP_SAVE(a6)	*�d���������i�΁j
		move.w	INDOSFLAG.w,INDOSFLAG_SAVE(a6)
		clr.w	INDOSFLAG.w
		move.b	INDOSNUM.w,INDOSNUM_SAVE(a6)

*�s�V�̂����ꍇ�i�΁j�ł���������ƌ�������(�����INDOSSP���ۑ��ł��Ȃ�)
*		DOS	_INDOSFLG
*		movea.l	d0,a0
*		move.w	(a0),INDOSFLAG_SAVE(a6)
*		clr.w	(a0)
*		move.b	2(a0),INDOSNUM_SAVE(a6)

		DOS	_GETPDB				*���ϐ������v���Z�X�ɂ��킹��
		movea.l	d0,a0
		move.l	(a0),d0
		movea.l	MM_MEMPTR(a6),a0
		lea	$10(a0),a0
		move.l	d0,(a0)
		move.l	a0,-(sp)			*���������v���Z�X�ɂ���
		DOS	_SETPDB
		addq.l	#4,sp
		move.l	d0,PDB_SAVE(a6)

		bsr	KILL_BREAK			*�u���[�N�֎~

		movea.l	sp,a5				*�A�{�[�g�A�h���X�ݒ�
		lea	MYSTACK2(a6),sp
		pea	ABORT_RESI(pc)
		move.w	#_ERRJVC,-(sp)
		DOS	_INTVCS
		pea	ABORT_RESI(pc)
		move.w	#_CTRLVC,-(sp)
		DOS	_INTVCS
		movea.l	a5,sp

		bsr	SAVE_DISPLAY			*��ʏ�Ԃ�ۑ�
		bmi	DISP_ON20
		bsr	SAVE_CURPATH			*�J�����g�f�B���N�g����ۑ�
		bsr	MOVE_CURPATH			*�w��̃f�B���N�g���Ɉړ�����

		clr.w	QUIT_FLAG(a6)
		bsr	DISPLAY_MAIN

DISP_ON10:
		bsr	RESUME_CURPATH			*�J�����g�f�B���N�g����߂�
		bsr	UNLOCK_DRIVE			*���b�N�h���C�u����
		bsr	RESUME_DISPLAY			*��ʏ�Ԃ�߂�
DISP_ON20:
		bsr	RESUME_BREAK			*�u���[�N�֎~����

		move.l	PDB_SAVE(a6),-(sp)
		DOS	_SETPDB
		addq.l	#4,sp

		move.l	INDOSSP_SAVE(a6),INDOSSP.w	*�d�����������̂Q�i�΁j
		move.w	INDOSFLAG_SAVE(a6),INDOSFLAG.w
		move.b	INDOSNUM_SAVE(a6),INDOSNUM.w
*�s�V�̂����ꍇ����
*		DOS	_INDOSFLG
*		movea.l	d0,a0
*		move.w	INDOSFLG_SAVE(a6),(a0)
*		move.b	INDOSNUM_SAVE(a6),2(a0)

DISP_ON90:
		move.l	SPSAVE_RESI(a6),sp
		movem.l	(sp)+,d0-d7/a0-a6
		rts

ABORT_RESI:
		lea	START(pc),a6
		adda.l	#BUFFER-START,a6
		tst.b	CHILD_FLAG(a6)
		bne	abort_child
		bsr	VECTOR_DONE			*���荞�݉���
		bsr	DISP_DONE			*��ʂ�߂�
		clr.b	MMDSPON_FLAG(a6)
		bra	DISP_ON10

.ifdef DISPTEST
*==================================================
*�����\�����x�v�� (�f�o�b�O�p)
*==================================================

*�S���W�h�b�g
*     han   / zen
*0.22  15.76 / 26.58
*0.25  10.03 / 15.66	Rate 57%up / 70%up
*0.28   7.55 / 13.18	     33%up / 19%up
*0.29   5.99 / 11.98	     26%up / 10%up

*�U���P�U�h�b�g
*     han   / zen
*0.22  14.58 / 23.47
*0.25  12.97 / 22.78	Rate 12%up / 3%up
*0.28  10.63   20.45	     22%up / 11%up
*0.29   9.14   18.66	     16%up / 10%up

disptest:
		bsr	TABLE_MAKE

		moveq	#3,d0
		moveq	#0,d1
		lea	mes(pc),a0
		movea.l	#TXTADR,a1
		move.w	#5000-1,d7
loop:
*		bsr	TEXT_6_16
		bsr	TEXT_4_8
		dbra	d7,loop

		move.l	SUPER(a6),a1
		IOCS	_B_SUPER

		DOS	_EXIT
*mes		dc.b	'0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ',0
mes		dc.b	'�����������������������������������ĂƂȂɂʂ˂̂͂Ђӂւق�',0
		.even
.endif


mes_keeperr:	.dc.b	'���ɏ풓���Ă��܂�.',13,10,0
mes_keep:	.dc.b	'�풓���܂���.',13,10,0
mes_removeerr:	.dc.b	'MMDSP�͏풓���Ă��܂���.',13,10,0
mes_remove:	.dc.b	'�풓�������܂���.',13,10,0
		.even

			.bss
			.even

BUFFER:		.ds.b	BUF_SIZE

		.end	START

