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
		.include	MMDSP.H

			.text
			.even

*
*	���j�d�x�a�n�q�c�Q�l�`�j�d
*�@�\�F��ʂɃL�[�{�[�h��\������
*���o�́F�Ȃ�
*�Q�l�F
*

KEYBORD_MAKE:
		movem.l	d0-d2/a0-a3,-(sp)

		move.l	#TXTADR,a2
		move.l	#BGADR,a3
		moveq.l	#7,d2
keyb_mk_loop1:
.if 0
*		lea.l	KEYBORD_BG1(pc),a0		*�L�[�{�[�h��i
*		lea.l	$80*2(a3),a1
*		move.w	#$800,d0
*		bsr	BG_PRINT

*		lea.l	KEYBORD_BG2(pc),a0		*���i�i�H�j
*		lea.l	$80*3(a3),a1
*		bsr	BG_PRINT

*		lea.l	KEYBORD_BG3(pc),a0		*���i
*		lea.l	$80*4(a3),a1
*		bsr	BG_PRINT
.endif
.if 1
		moveq.l	#0,d0
		lea.l	$E(a3),a0
		bsr	PRINT10_3KETA			*�j
		addq.l	#6,a0
		bsr	PRINT10_3KETA			*��

		lea.l	$18(a3),a0
		bsr	PRINT10_5KT_F			*�c
		addq.l	#8,a0
		bsr	PRINT10_5KT_F			*�o
		addq.l	#8,a0
		bsr	PRINT10_5KT_F			*�a
		addq.l	#8,a0
		bsr	PRINT10_5KT_F			*�`

		lea.l	$E+$80(a3),a0
		bsr	PRINT10_3KETA			*��
		addq.l	#6,a0
		bsr	PRINT10_3KETA			*�����P
		addq.l	#4,a0
		bsr	PRINT10_3KETA			*�����Q

		lea.l	$22+$80(a3),a0
		bsr	PRINT16_6KETA			*�c�`�s�`
		lea.l	$2C+$80(a3),a0
		bsr	PRINT16_4KETA			*�j�b�P
		addq.l	#6,a0
		bsr	PRINT16_4KETA			*�j�b�Q
.endif
		moveq.l	#3,d0				*�X�[�e�[�^�X�����P
		moveq.l	#0,d1
		bset.l	#31,d1				*���l�߂����Ȃ����[�h
		lea.l	KEYBORD_TX1(pc),a0
		move.l	a2,a1
		bsr	TEXT_4_8

		lea.l	KEYBORD_TX2(pc),a0		*	�V	�Q
		lea.l	$80*8(a2),a1
		bsr	TEXT_4_8

		lea.l	$80*8*5(a2),a2
		lea.l	$80*5(a3),a3
		dbra	d2,keyb_mk_loop1

		move.b	KEYB_TROFST(a6),d1		*�\���擪�g���b�N�ݒ�
		bsr	KEYBD_SET

*		bsr	clear_status
*		bsr	put_trknum
*		bsr	KEYBORD_DISPM
*		bsr	KEYBORD_LAMP
*		bsr	resume_status

		movem.l	(sp)+,d0-d2/a0-a3
		rts

*==================================================
*�L�[�{�[�h�ړ�
*==================================================

*�L�[�{�[�h�P�ړ�

KEYBD_UP:
		move.l	d1,-(sp)
		move.b	KEYB_TROFST(a6),d1
		addq.b	#1,d1
		bsr	KEYBD_SET
		move.l	(sp)+,d1
		rts

KEYBD_DOWN:
		move.l	d1,-(sp)
		move.b	KEYB_TROFST(a6),d1
		subq.b	#1,d1
		bsr	KEYBD_SET
		move.l	(sp)+,d1
		rts


*�L�[�{�[�h�ʒu�Z�b�g
*	d1.b <- �\���J�n�g���b�N(0-24)
*	�ő�L���g���b�N�𒴂���ꍇ�́A�C������

KEYBD_SET:
		movem.l	d0-d1/a0,-(sp)
		tst.b	d1			*�w�肪0�ȉ���������A0�ɂ���
		bpl	keybd_set10
		moveq	#0,d1
keybd_set10:
*		bsr	get_maxtrack		*�ő�L���g���b�N-7�Ɣ�r����
*		subq.b	#7,d0
*		bpl	keybd_set20
*		moveq	#0,d0
keybd_set20:
*		cmp.b	d0,d1			*������悤�Ȃ�A�C������
*		bls	keybd_set30
*		move.b	d0,d1

		cmpi.b	#31-7,d1
		bls	keybd_set30
		moveq	#31-7,d1

keybd_set30:
		cmp.b	KEYB_TROFST(a6),d1
		beq	keybd_set40
		st.b	KEYB_TRCHG(a6)
keybd_set40:
		move.b	d1,KEYB_TROFST(a6)	*�I�t�Z�b�g��ݒ肵��
		ext.w	d1
		lea	TRACK_STATUS(a6),a0	*TRACK_STATUS�I�t�Z�b�g��
		move.w	d1,d0
		mulu	#TRST,d0
		lea	(a0,d0.w),a0
		move.l	a0,KEYB_TRBUF(a6)
		lea	CHST_BF(a6),a0		*CHST_BF�I�t�Z�b�g���v�Z����
		move.w	d1,d0
		mulu	#CHST,d0
		lea	(a0,d0.w),a0
		move.l	a0,KEYB_CHBUF(a6)
		movem.l	(sp)+,d0-d1/a0
		rts


*�ő�L���g���b�N�ԍ��𒲂ׂ�
*	d0.w -> �ő�L���g���b�N�ԍ�(-1 - 31)

get_maxtrack:
		move.l	d1,-(sp)
		moveq	#31,d0
		move.l	TRACK_ENABLE(a6),d1
get_maxtrack10:
		add.l	d1,d1
		dbcs	d0,get_maxtrack10
get_maxtrack20:
		move.l	(sp)+,d1
		rts


*==================================================
*	���j�d�x�a�n�q�c�Q�c�h�r�o
*�@�\�F�L�[�{�[�h�X�e�[�^�X�̕\��
*���o�́F�Ȃ�
*�Q�l�F�b�g�r�s�i�`�U�j�̃f�[�^�[��\������
*==================================================

KEYBORD_DISP:
		movem.l	d0-d7/a0-a5,-(sp)
		tst.b	KEYB_TRCHG(a6)
		bne	keybord_disp10
		bsr	KEYBORD_DISPM
		bsr	KEYBORD_LAMP
		bra	keybord_disp90

keybord_disp10:
		bsr	clear_status			*�擪�g���b�N���ω������ꍇ
*		bsr	put_trknum
		bsr	KEYBORD_DISPM
		bsr	KEYBORD_LAMP
		bsr	resume_status
		clr.b	KEYB_TRCHG(a6)

keybord_disp90:
		movem.l	(sp)+,d0-d7/a0-a5
		rts


KEYBORD_DISPM:
*		movea.l	#TXTADR+40+$80*20,a3		*�f�o�b�O�p
*		move.w	#$5555,-$80(a3)

keyb_disp10:
		move.l	#BGADR,a1
		movea.l	KEYB_CHBUF(a6),a2
		moveq.l	#7,d7
keyb_disp_loop:
		move.w	KBS_CHG(a2),d3
*		move.w	d7,2(a3)			*�f�o�b�O�p
*		move.w	d3,(a3)
*		lea	$80(a3),a3
		beq	keyb_disp_jp0

keyb_disp_jp3:
		btst.l	#0,d3				*0:�j
		beq	keyb_disp_jp4
		moveq.l	#0,d0
		move.b	KBS_k(a2),d0
		lea.l	$E(a1),a0
		bsr	PRINT10_3KETA
keyb_disp_jp4:
		btst.l	#1,d3				*1:��
		beq	keyb_disp_jp6
		move.w	#$E65,d1	*BGchr(q:)
		moveq.l	#0,d0
		move.b	KBS_q(a2),d0
		bpl	keyb_disp_jp5
		neg.b	d0
		move.w	#$F65,d1	*BGchr(@q)
keyb_disp_jp5:	move.w	d1,$12(a1)
		lea.l	$14(a1),a0
		bsr	PRINT10_3KETA
keyb_disp_jp6:
		btst.l	#2,d3				*2:�c
		beq	keyb_disp_jp7
		move.w	KBS_D(a2),d0
		lea.l	$18(a1),a0
		bsr	PRINT10_5KT_F
keyb_disp_jp7:
		btst.l	#3,d3				*3:�o
		beq	keyb_disp_jp8
		move.w	KBS_P(a2),d0
		lea.l	$20(a1),a0
		bsr	PRINT10_5KT_F
keyb_disp_jp8:
		btst.l	#4,d3				*4:�a
		beq	keyb_disp_jp9
		move.w	KBS_B(a2),d0
		lea.l	$28(a1),a0
		bsr	PRINT10_5KT_F
keyb_disp_jp9:
		btst.l	#5,d3				*5:�`
		beq	keyb_disp_jpA
		move.w	KBS_A(a2),d0
		lea.l	$30(a1),a0
		bsr	PRINT10_5KT_F
keyb_disp_jpA:
		btst.l	#6,d3				*6:��
		beq	keyb_disp_jpB
		move.w	KBS_PROG(a2),d0
		lea.l	$E+$80(a1),a0
		bsr	PRINT10_3KETA
keyb_disp_jpB:
		btst.l	#7,d3				*7:�����P
		beq	keyb_disp_jpC
		moveq.l	#0,d0
		move.b	KBS_TL1(a2),d0
		lea.l	$14+$80(a1),a0
		bsr	PRINT10_3KETA
keyb_disp_jpC:
		btst.l	#8,d3				*8:�����Q
		beq	keyb_disp_jpD
		moveq.l	#0,d0
		move.b	KBS_TL2(a2),d0
		lea.l	$18+$80(a1),a0
		bsr	PRINT10_3KETA
keyb_disp_jpD:
		btst.l	#9,d3				*9:�c�`�s�`
		beq	keyb_disp_jpE
		move.l	KBS_DATA(a2),d0
		lea.l	$22+$80(a1),a0
		bsr	PRINT16_6KETA
keyb_disp_jpE:
		btst.l	#10,d3				*A:�j�b�P
		beq	keyb_disp_jpF
		move.w	KBS_KC1(a2),d0
		lea.l	$2C+$80(a1),a0
		bsr	PRINT16_4KETA
keyb_disp_jpF:
		btst.l	#11,d3				*B:�j�b�Q
		beq	keyb_disp_jpG
		move.w	KBS_KC2(a2),d0
		lea.l	$32+$80(a1),a0
		bsr	PRINT16_4KETA
keyb_disp_jpG:

keyb_disp_jp0:
		lea.l	$80*5(a1),a1
		lea.l	CHST(a2),a2
		dbra	d7,keyb_disp_loop

		rts

*==================================================
* �L�[�{�[�h�����v�̕\��
*==================================================

KEYBORD_LAMP:

*		movea.l	#TXTADR+48+$80*20,a4		*�f�o�b�O�p
*		move.l	TRACK_CHANGE(a6),-$80(a4)

		movea.l	#SPRITEREG,a0			*a0.l <- SPRITEREG
		movea.l	KEYB_TRBUF(a6),a1		*a1.l <- TRACK_BUFF
		lea	KEYBORD_IDX(pc),a2		*a2.l <- KEYBORD_IDX

*		move.l	TRACK_ENABLE(a6),d4		*d4.l <- �n�e�e�g���b�N�t���O
*		not.l	d4
*		and.l	TRACK_CHANGE(a6),d4
		move.l	TRACK_CHANGE(a6),d4

		move.b	KEYB_TROFST(a6),d5		*d5.b <- �擪�g���b�N�ԍ�
		moveq	#0,d6				*d6.w <- �L�[�{�[�h�ԍ�

		moveq.l	#8-1,d7
keyb_lamp10:
*		move.b	STCHANGE(a1),(a4)		*�f�o�b�O�p
*		move.b	KEYONCHANGE(a1),1(a4)
*		move.b	KEYCHANGE(a1),2(a4)
*		move.b	VELCHANGE(a1),3(a4)
*		move.b	d7,4(a4)
*		lea	$80(a4),a4

		btst.l	d5,d4				*�g���b�N���n�e�e���ꂽ���A
		bne	keyb_lamp11
		btst.b	#0,STCHANGE(a1)			*������ނ��ω�������A
		beq	keyb_lamp20
keyb_lamp11:
		bsr	put_instrument			*���łɉ�����ނ̕\��
		bsr	clear_keyb			*�L�[�{�[�h������������
keyb_lamp20:
		moveq	#0,d0
		move.b	INSTRUMENT(a1),d0		*�����v�\���T�u�w
		add.w	d0,d0
		add.w	d0,d0
		jsr	keyb_lamp_jmp(pc,d0.w)
keyb_lamp30:
		lea	128(a0),a0
		lea	TRST(a1),a1
		addq.w	#1,d5
		addq.w	#1,d6
		dbra	d7,keyb_lamp10

		rts

keyb_lamp_jmp:
		bra.w	keylampFM
		bra.w	keylampFM
		bra.w	keylampFM
		bra.w	keylampMIDI


*�L�[�{�[�h�������T�u
*	a0 <- SPRITEREG address

clear_keyb:
		clr.w	(a0)
		clr.w	$8(a0)
		clr.w	$10(a0)
		clr.w	$18(a0)
		clr.w	$20(a0)
		clr.w	$28(a0)
		clr.w	$30(a0)
		clr.w	$38(a0)
		clr.w	$40(a0)
		clr.w	$48(a0)
		clr.w	$50(a0)
		clr.w	$58(a0)
		clr.w	$60(a0)
		clr.w	$68(a0)
		clr.w	$70(a0)
		clr.w	$78(a0)

		movem.l	d0-d2/a0-a3,-(sp)
		move.l	#BGADR,a3
		move.w	d6,d0
		mulu	#$80*5,d0
		adda.l	d0,a3

		move.w	#$0400,d0
		move.l	TRACK_ENABLE(a6),d1
		btst.l	d5,d1
		bne	clear_keyb1
		move.w	#$0800,d0

clear_keyb1:
		lea.l	KEYBORD_BG1(pc),a0		*�L�[�{�[�h��i
		lea.l	$80*2(a3),a1
		bsr	BG_PRINT

		lea.l	KEYBORD_BG2(pc),a0		*���i�i�H�j
		lea.l	$80*3(a3),a1
		bsr	BG_PRINT

		lea.l	KEYBORD_BG3(pc),a0		*���i
		lea.l	$80*4(a3),a1
		bsr	BG_PRINT

		movem.l	(sp)+,d0-d2/a0-a3
		rts

*�L�[�{�[�h�\���iFM�j
*	a0 <- SPRITEREG address
*	a1 <- TRACK_STATUS address
*	a2 <- KEYBORD_IDX address

keylampFM:
		bsr	put_keylamp

		btst.b	#0,KEYONSTAT(a1)	*if (KEYONSTAT==OFF)
		beq	keylampFM10
		clr.w	$70(a0)			*	bendoff();
		clr.w	$78(a0)
		bra	keylampFM90
keylampFM10:
		btst.b	#1,STCHANGE(a1)		*if (STCHANGE_1 == ON ||
		bne	keylampFM20
		tst.b	KEYONCHANGE(a1)		*    KEYONCHANGE == ON ||
		bne	keylampFM20
		tst.b	KEYCHANGE(a1)		*    KEYCHANGE == ON)
		beq	keylampFM90
keylampFM20:
		moveq	#0,d1			*	putbend();
		move.b	KEYCODE(a1),d1
		add.w	KEYOFFSET(a1),d1
		subi.w	#15,d1
		add.w	d1,d1
		add.w	d1,d1
		move.w	BEND(a1),d0
		asr.w	#4,d0
		add.w	d0,d1

		moveq.l	#0,d2
		cmpi.w	#96*4,d1
		bcc	keylampFM40
		andi.w	#$0003,d0
		andi.w	#$fffc,d1
		move.b	(a2,d1.w),d2
		cmpi.b	#$13+3,3(a2,d1.w)
		beq	keylampFM30
		lsr.w	#1,d0
keylampFM30:
		add.w	d0,d2
keylampFM40:
		move.w	d2,$70(a0)
		move.w	d2,$78(a0)
keylampFM90:
		rts


*�L�[�{�[�h�\���iMIDI�j
*	a0 <- SPRITEREG address
*	a1 <- TRACK_STATUS address

keylampMIDI:
		bsr	put_keylamp

		tst.w	$70(a0)
		beq	keylampMIDI70
		btst.b	#1,STCHANGE(a1)			*���_(^^;�݂����ȕ�
		beq	keylampMIDI90
keylampMIDI70:	move.b	BEND(a1),d1
		ext.w	d1
		addi.w	#124,d1
		move.w	d1,$70(a0)
		move.w	d1,$78(a0)
keylampMIDI90:
		rts


*�L�[�{�[�h�����v�\���T�u�p�}�N��
*	d1.w <- keyon / keyoff �t���O
*	d2.w <- keycode ��offset
*	a0.l <- SPRITEREG address
*	a1.l <- TRACK_STATUS address
*	a2.l <- KEYBORD_IDX address
*	a3.l x

LAMPON		macro	pnum
		local	LAMPON_keyon,LAMPON_keyoff,LAMPON_end
		tst.w	d1
		beq	put_keylamp80
		lsr.w	#1,d1
		bcs	LAMPON_keyoff
		tst.b	d1
		bpl	LAMPON_end
LAMPON_keyon:
		moveq	#0,d0				*�L�[�n�m
		move.b	KEYCODE+pnum(a1),d0
		add.w	d2,d0
		cmpi.w	#95,d0
		bhi	LAMPON_keyoff
		add.w	d0,d0
		add.w	d0,d0
		lea	(a2,d0.w),a3
		moveq	#0,d0
		move.b	(a3)+,d0
		move.w	d0,(a0)
		move.b	(a3)+,d0
		move.w	d0,8(a0)
		move.w	(a3),4(a0)
		bra	LAMPON_end
LAMPON_keyoff:
		clr.w	(a0)				*�L�[�n�e�e
		clr.w	8(a0)
LAMPON_end:
		lea	16(a0),a0
		endm

*�L�[�{�[�h�����v�\���T�u
*	a0.l <- SPRITEREG address
*	a1.l <- TRACK_STATUS address
*	a2.l <- KEYBORD_IDX address
*	a3.l x
*
*if (keyonstat == ON && (keychange || keyonchange))
*	keyon();
*else if (keyonstat == OFF && keyonchange)
*	keyoff();

put_keylamp:
		move.b	KEYONSTAT(a1),d1	*d1.wh <- keyon & (keychange | keyonchange)
		move.b	d1,d2			*d1.wl <- keyoff & keyonchange
		not.b	d1
		move.b	KEYONCHANGE(a1),d0
		and.b	d0,d2
		or.b	KEYCHANGE(a1),d0
		and.b	d0,d1
		lsl.w	#8,d1
		move.b	d2,d1
		tst.w	d1
		beq	put_keylamp90

		move.w	KEYOFFSET(a1),d2	*d2.w <- KEYOFFSET-15
		subi.w	#15,d2

		move.l	a0,-(sp)
		LAMPON	0
		LAMPON	1
		LAMPON	2
		LAMPON	3
		LAMPON	4
		LAMPON	5
		LAMPON	6
put_keylamp80:
		move.l	(sp)+,a0
put_keylamp90:
		rts


*�������&TRACK NO�\���T�u
*	d6 <- keyboard no
*	a1 <- TRACK_STATUS address

put_instrument:
		movem.l	d0-d1/a0-a1,-(sp)
		movea.l	#BGADR+3*2+0*80,a0		*�g���b�N�ԍ���\������
		move.w	d6,d0
		mulu	#128*5,d0
		adda.l	d0,a0
		moveq	#2,d1
		moveq	#0,d0
		move.b	TRACKNO(a1),d0
		beq	put_instrument10
		bsr	DIGIT10
		bra	put_instrument20
put_instrument10:
		moveq	#-1,d0			*�g���b�N�ԍ��O�Ȃ�΁A�u�����N�L����
		bsr	PUT_DIGIT
		lea	2(a0),a0
		bsr	PUT_DIGIT
put_instrument20:
		moveq	#0,d0				*������ރ��b�Z�[�W��\������
		move.b	INSTRUMENT(a1),d0
		lsl.w	#3,d0
		lea	inst_mes(pc,d0.w),a0
		movea.l	#TXTADR+0+0*$80,a1
		move.w	d6,d0
		mulu	#128*40,d0
		adda.l	d0,a1
		moveq	#0,d1
*		bset	#31,d1
		moveq	#2,d0
		bsr	TEXT_4_8
		movem.l	(sp)+,d0-d1/a0-a1
		rts

inst_mes:
		.dc.b	'none  ',0,0
		.dc.b	'OPM   ',0,0
		.dc.b	'ADPCM ',0,0
		.dc.b	'MIDI  ',0,0

*==================================================
* �X�e�[�^�X�I�[���N���A
*==================================================

clear_status:
		movem.l	d0/d7/a0-a2,-(sp)
		movea.l	KEYB_TRBUF(a6),a0
		movea.l	KEYB_CHBUF(a6),a1
		lea	STSAVE(a6),a2
		moveq	#-1,d0

		move.l	TRACK_CHANGE(a6),(a2)+
		move.l	d0,TRACK_CHANGE(a6)
		moveq	#8-1,d7
clear_status10:
		move.w	KBS_CHG(a1),(a2)+
		move.b	STCHANGE(a0),(a2)+
		move.b	KEYONCHANGE(a0),(a2)+
		move.b	KEYCHANGE(a0),(a2)+
		move.b	VELCHANGE(a0),(a2)+
		move.w	d0,KBS_CHG(a1)
		move.b	d0,STCHANGE(a0)
		move.b	d0,KEYONCHANGE(a0)
		move.b	d0,KEYCHANGE(a0)
		move.b	d0,VELCHANGE(a0)
		lea	TRST(a0),a0
		lea	CHST(a1),a1
		dbra	d7,clear_status10
		movem.l	(sp)+,d0/d7/a0-a2
		rts

resume_status:
		movem.l	d7/a0-a2,-(sp)
		movea.l	KEYB_TRBUF(a6),a0
		movea.l	KEYB_CHBUF(a6),a1
		lea	STSAVE(a6),a2

		move.l	(a2)+,TRACK_CHANGE(a6)
		moveq	#8-1,d7
resume_status10:
		move.w	(a2)+,KBS_CHG(a1)
		move.b	(a2)+,STCHANGE(a0)
		move.b	(a2)+,KEYONCHANGE(a0)
		move.b	(a2)+,KEYCHANGE(a0)
		move.b	(a2)+,VELCHANGE(a0)
		lea	TRST(a0),a0
		lea	CHST(a1),a1
		dbra	d7,resume_status10
		movem.l	(sp)+,d7/a0-a2
		rts


*==================================================
* �g���b�N�ԍ��\��(8tracks)
*==================================================

put_trknum:
		movem.l	d0-d1/d7/a0-a1,-(sp)
		movea.l	KEYB_TRBUF(a6),a1
		movea.l	#BGADR+3*2+0*$80,a0
		moveq	#2,d1
		moveq	#8-1,d7
put_trknum10:
		moveq	#0,d0
		move.b	TRACKNO(a1),d0
		beq	put_trknum11
		bsr	DIGIT10
		bra	put_trknum20
put_trknum11:
		moveq	#-1,d0			*�g���b�N�ԍ��O�Ȃ�΁A�u�����N�L����
		bsr	PUT_DIGIT
		lea	2(a0),a0
		bsr	PUT_DIGIT
		lea	-2(a0),a0
put_trknum20:
		lea	128*5(a0),a0
		lea	TRST(a1),a1
		dbra	d7,put_trknum10
		movem.l	(sp)+,d0-d1/d7/a0-a1
		rts

		.data
		.even

kbxmacro:	.macro	ads
temp	=	ads*28+14
*			pos1.b, pos2.b, pattern.w
		.dc.b	temp+00,0000000,$03,$13+0	*D#
		.dc.b	temp+02,temp+02,$03,$13+3	*E
		.dc.b	temp+06,temp+06,$03,$13+2	*F
		.dc.b	temp+08,0000000,$03,$13+0	*F#
		.dc.b	temp+10,temp+10,$03,$13+1	*G
		.dc.b	temp+12,0000000,$03,$13+0	*G#
		.dc.b	temp+14,temp+14,$03,$13+1	*A
		.dc.b	temp+16,0000000,$03,$13+0	*A#
		.dc.b	temp+18,temp+18,$03,$13+3	*B
		.dc.b	temp+22,temp+22,$03,$13+2	*C
		.dc.b	temp+24,0000000,$03,$13+0	*C#
		.dc.b	temp+26,temp+26,$03,$13+1	*D
		.endm

*  BBB BBB     BBB BBB BBB     BBB
*WWW WWW WWW WWW WWW WWW WWW WWW WWW
* 0 4 8 c 0   4 8 c 0 4 8 c   0

KEYBORD_IDX:
		kbxmacro	0
		kbxmacro	1
		kbxmacro	2
		kbxmacro	3
		kbxmacro	4
		kbxmacro	5
		kbxmacro	6
		kbxmacro	7

KEYBORD_BG1:	.dc.b	$44,$46,$44,$48,$4A,$48,$4A
		.dc.b	$44,$46,$44,$48,$4A,$48,$4A
		.dc.b	$44,$46,$44,$48,$4A,$48,$4A
		.dc.b	$44,$46,$44,$48,$4A,$48,$4A,0
KEYBORD_BG2:	.dc.b	$45,$47,$45,$49,$4B,$49,$4B
		.dc.b	$45,$47,$45,$49,$4B,$49,$4B
		.dc.b	$45,$47,$45,$49,$4B,$49,$4B
		.dc.b	$45,$47,$45,$49,$4B,$49,$4B,0
KEYBORD_BG3:	.dc.b	$64,$64,$64,$64,$64,$64,$64
		.dc.b	$64,$64,$64,$64,$64,$64,$64
		.dc.b	$64,$64,$64,$64,$64,$64,$64
		.dc.b	$64,$64,$64,$64,$64,$64,$64,0

KEYBORD_TX1:	.dc.b	'            K:          D       P       B       A       ',0
KEYBORD_TX2:	.dc.b	'TRACK',$7f,'       @    @v   -    DATA:$       KC$    -$',0
		.text


		.end
