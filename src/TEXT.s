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
*	���s�d�w�s�Q�`�b�b�d�r�r�Q�n�m
*�@�\�F�e�L�X�g���������A�N�Z�X���[�h�̐ݒ�
*���́F	�c�O	�A�N�Z�X�v���[���̎w��(0-3bit)
*�o�́F�Ȃ�
*�Q�l�F�R�[��������Q�n�e���K���Ăяo������
*
TEXT_ACCESS_ON:
		movem.l	d0-d1/a0,-(sp)
		move.l	#CRTC_ACM,a0
		move.w	(a0),d1
		move.w	d1,TX_ACM(a6)
		bset.l	#8,d1
		and.w	#$FF0F,d1
		lsl.w	#4,d0
		or.w	d0,d1
		move.w	d1,(a0)
		movem.l	(sp)+,d0-d1/a0
		rts
*
*	���s�d�w�s�Q�`�b�b�d�r�r�Q�n�e
*�@�\�F�A�N�Z�X���[�h�����ɖ߂�
*���o�́F�Ȃ�
*�Q�l�F
*
TEXT_ACCESS_OF:
		move.l	a0,-(sp)
		move.l	#CRTC_ACM,a0
		move.w	TX_ACM(a6),(a0)
		move.l	(sp)+,a0
		rts


*==================================================
*������ރ`�F�b�N�}�N��
*	reg <- check data
*		code $00-$7F �������� ascii �֔��
*		code $80-$9F,$E0-$FF�i����code�j�������� kanji  �֔��
*		code $A0-$DF (KANA) ��������f�ʂ�
*==================================================

kanji_check	macro	reg,ascii,kanji
		cmp.b	#$80,reg
		bcs	ascii
		cmp.b	#$A0,reg
		bcs	kanji
		cmp.b	#$E0,reg
		bcc	kanji
		endm


*==================================================
*�e�L�X�g�}�X�N�n�m�}�N��
*==================================================

TEXTMASK_ON	macro
		bset.b	#1,CRTC_ACM
		endm


*==================================================
*�e�L�X�g�}�X�N�n�e�e�}�N��
*==================================================

TEXTMASK_OFF	macro
		bclr.b	#1,CRTC_ACM
		clr.w	MASK_WORK(a6)
		clr.w	CRTC_ACM+4
		endm


*==================================================
*�e�L�X�g�}�X�N�Z�b�g�}�N��
*	d0.w <- mask bit data
*==================================================

TEXTMASK_SET	macro
*		move.w	d0,MASK_WORK(a6)
		move.w	d0,CRTC_ACM+4
		endm


*==================================================
*�e�L�X�g�}�X�N�Z�b�g
*	d0.w <- mask bit data (if d0=0 then mask clear)
*==================================================

text_mask_set:						*�e�L�X�g�}�X�N�ݒ�
		movem.l	d0/a0,-(sp)
		movea.l	#CRTC_ACM,a0
		move.w	d0,4(a0)
		move.w	d0,MASK_WORK(a6)
		bne	text_mask_jp0
		move.w	(a0),d0
		bclr.l	#9,d0
		bra	text_mask_jp1
text_mask_jp0:
		move.w	(a0),d0
		bset.l	#9,d0
text_mask_jp1:
		move.w	d0,(a0)
		movem.l	(sp)+,d0/a0
		rts


*==================================================
*�e�L�X�g��ʂ̃N���A
*==================================================

CLEAR_TEXT:
		movem.l	d0-d1/a0-a1,-(sp)
		movea.l	#CRTC_ACM,a1		*�e�L�X�g���(0-511)����������
		move.w	(a1),-(sp)
		move.w	#$01f0,(a1)
		movea.l	#TXTADR,a0
		moveq	#0,d0
		moveq	#16-1,d1
clear_text10	move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		dbra	d1,clear_text10
		move.w	(sp)+,(a1)
		moveq	#1,d1
		moveq	#127,d2
		moveq	#$0f,d3
		IOCS	_TXRASCPY
		movem.l	(sp)+,d0-d1/a0-a1
		rts

*==================================================
*	���s�d�w�s�S�W�`�t�s�n
*�@�\�F�e�[�u���ɂ�镶���\��
*���́F	�`�O	�f�[�^�[�A�h���X
*�o�́F�Ȃ�
*�Q�l�F�f�[�^�[�\��
*	$00(a0).b	�e�L�X�g�A�N�Z�X���[�h�i�O�Ȃ�e�[�u���I���j
*	$01(a0).b	���l�߂��s�����ǂ����i�O�F�s���C����ȊO�͍s��Ȃ��j
*	$02(a0).b	�e�L�X�g�w���W�i�W�h�b�g�P�ʁj
*	$03(a0).b	�@�ׂ����w�w��i�O�`�V�j�i�����炵���j
*	$04(a0).b	�e�L�X�g�x���W�i�Q�T�U�h�b�g�P�ʁj
*	$05(a0).b	�@�ׂ����x���W�i�P�h�b�g�P�ʁj
*	$06(a0).	�����f�[�^�[
*	$??(a0).b	�G���h�R�[�h�O
*	$??+1(a0).b	���̃e�[�u��
*==================================================

TEXT48AUTO:
		movem.l	d0-d1/a0-a2,-(sp)

		movea.l	#TXTADR,a2
text48auto_lop:
		tst.b	(a0)				*�I���R�[�h���H
		beq	text48auto_bye

		move.l	a2,a1
		moveq.l	#0,d0				*�x���W�A�h���X����
		move.b	4(a0),d0
		lsl.w	#8,d0
		or.b	5(a0),d0
		lsl.l	#7,d0
		add.l	d0,a1

		moveq.l	#0,d0				*�w���W�A�h���X����
		move.b	2(a0),d0
		add.w	d0,a1
		move.b	3(a0),d0
		move.l	d0,d1

		tst.b	1(a0)				*���l�ߍs�����H
		beq	text48auto_jp0
		bset.l	#31,d1
text48auto_jp0:
		move.b	(a0),d0				*�A�N�Z�X���[�h���o��
		addq.l	#6,a0				*�����f�[�^�Ƀ|�C���^�ڂ�
		bsr	TEXT_4_8			*�\������

text48auto_jp1:
		tst.b	(a0)+				*�����f�[�^�̏I���܂Ői�߂�
		bne	text48auto_jp1

		bra	text48auto_lop			*���[�v

text48auto_bye:
		movem.l	(sp)+,d0-d1/a0-a2
		rts


*==================================================
*�S���W�h�b�g�e�L�X�g�����\���p�}�N��
*==================================================

comp4han2line	macro
		move.b	(a0)+,d0
		or.b	(a0)+,d0
		move.b	(a4,d0.w),(a2)+
		move.b	(a0)+,d0
		or.b	(a0)+,d0
		move.b	(a4,d0.w),(a2)+
		endm

comp_4han	macro
		moveq	#0,d0
		lea	TX_BF_1(a6),a2
		comp4han2line
		comp4han2line
		comp4han2line
		comp4han2line
		lea	TX_BF_1(a6),a0
		endm

comp4zen1line	macro
		move.b	(a0)+,d0
		move.b	(a0)+,d1
		or.b	(a0)+,d0
		or.b	(a0)+,d1
		move.b	(a4,d0.w),(a2)+
		move.b	(a4,d1.w),(a3)+
		endm

comp_4zen	macro
		moveq	#0,d0
		moveq	#0,d1
		move.l	a3,d2
		lea	TX_BF_1(a6),a2
		lea	8(a2),a3
		comp4zen1line
		comp4zen1line
		comp4zen1line
		comp4zen1line
		comp4zen1line
		comp4zen1line
		comp4zen1line
		comp4zen1line
		lea	TX_BF_1(a6),a0
		movea.l	d2,a3
		endm

put_4font0	macro	param
		.if param.eq.0
		move.b	(a0)+,(a1)
		.else
		move.b	(a0)+,param*128(a1)
		.endif
		endm

put_4font1	macro	param
		move.b	(a0)+,d0
		ror.b	d1,d0
		.if param.eq.0
		move.b	d0,(a1)
		.else
		move.b	d0,param*128(a1)
		.endif
		endm

put_4font2	macro	param
		.if param.eq.0
		move.b	(a0)+,(a1)+
		.else
		move.b	(a0)+,param*128-1(a1)
		.endif
		endm

put_4font3	macro	param
		move.b	(a0)+,d0
		lsl.w	d1,d0
		.if param.eq.0
		move.w	d0,(a1)
		.else
		move.w	d0,param*128(a1)
		.endif
		endm

put_4font4	macro	param
		move.b	(a0)+,d0
		ror.b	d1,d0
		.if param.eq.0
		move.b	d0,(a1)+
		move.b	d0,(a1)
		.else
		move.b	d0,param*128-1(a1)
		move.b	d0,param*128(a1)
		.endif
		endm

put_4fontmac0	macro
		put_4font0	0
		put_4font0	1
		put_4font0	2
		put_4font0	3
		put_4font0	4
		put_4font0	5
		put_4font0	6
		put_4font0	7
		endm

put_4fontmac1	macro
		moveq	#3,d1
		and.w	d3,d1
		put_4font1	0
		put_4font1	1
		put_4font1	2
		put_4font1	3
		put_4font1	4
		put_4font1	5
		put_4font1	6
		put_4font1	7
		endm

put_4fontmac2	macro
		put_4font2	0
		put_4font2	1
		put_4font2	2
		put_4font2	3
		put_4font2	4
		put_4font2	5
		put_4font2	6
		put_4font2	7
		endm

put_4fontmac3	macro
		move.w	d3,d1
		neg.w	d1
		andi.w	#3,d1
		put_4font3	0
		put_4font3	1
		put_4font3	2
		put_4font3	3
		put_4font3	4
		put_4font3	5
		put_4font3	6
		put_4font3	7
		addq.l	#1,a1
		endm

put_4fontmac4	macro
		moveq	#3,d1
		and.w	d3,d1
		put_4font4	0
		put_4font4	1
		put_4font4	2
		put_4font4	3
		put_4font4	4
		put_4font4	5
		put_4font4	6
		put_4font4	7
		endm


*==================================================
*	���s�d�w�s�Q�S�Q�W
*�@�\�F�S���W�h�b�g�e�L�X�g�����\��
*���́F	�c�O	�e�L�X�g�A�N�Z�X���[�h
*	�c�P.w	�\���h�b�g�P�ʉ����炵�w��(0�`7)
*		��31bit���P�ɂ��Ă����ƁA�h�Ȃǂ̎��l�߂��s��Ȃ��I
*	�`�O	�f�[�^�[�A�h���X
*	�`�P	�o�̓A�h���X
*�o�́F�Ȃ�
*�Q�l�F�f�[�^�I���R�[�h�͂O�C�d�r�b�V�[�P���X�͎g���Ȃ�
*==================================================

TEXT_4_8:
		movem.l	d0-d5/a0-a5,-(sp)

		bsr	TEXT_ACCESS_ON
		TEXTMASK_ON

		tst.l	d1			*d5 : ���l�ߋ��t���O
		spl	d5

		move.w	a1,d3			*d3 : shift mode(0-15)
		andi.w	#1,d3
		lsl.w	#3,d3
		add.w	d1,d3
		andi.w	#$F,d3

		movea.l	a0,a3			*a3 : string
		lea	TO4BIT_TBL(a6),a4	*a4 : to4bit table
		lea.l	CHR_00(pc),a5		*a5 : 4dot font address

		bra	text4_hannext

text4_loop:
		kanji_check	d1,text4_han,text4_zen
		sub.b	#$20,d1
text4_han:
		moveq	#0,d0			*���p��p�t�H���g�̃A�h���X�v�Z
		move.b	d1,d0
		lsl.w	#3,d0
		lea.l	(a5,d0.w),a0
		move.b	7(a0),d4
		bne	text4_han10
		bsr	put_4font		*���l�߂Ȃ��\��
text4_hannext:
		move.b	(a3)+,d1
		bne	text4_loop
		bra	text4_done

text4_han10:
		move.b	d4,d0
		and.b	d5,d0
		bpl	text4_han20		*���l�ߏ���
		moveq	#7,d1
		and.w	d3,d1
		bne	text4_han15
		subq.l	#1,a1
text4_han15:
		subq.w	#1,d3
		andi.w	#$F,d3
text4_han20:
		clr.b	7(a0)
		bsr	put_4font
		move.b	d4,-(a0)
		and.b	d5,d4
		lsr.b	#1,d4
		bcc	text4_hannext
		moveq	#7,d1			*�E�l�ߏ���
		and.w	d3,d1
		bne	text4_han25
		subq.l	#1,a1
text4_han25:
		subq.w	#1,d3
		andi.w	#$F,d3
		move.b	(a3)+,d1
		bne	text4_loop
		bra	text4_done

text4_zen:
		lsl.w	#8,d1
		move.b	(a3)+,d1
		beq	text4_done
		moveq.l	#8,d2				*�S�p�t�H���g�A�h���X
		IOCS	_FNTADR
		movea.l	d0,a0
		tst.w	d1
		beq	text4_zenhan
		comp_4zen
		bsr	put_4font
		bsr	put_4font
		move.b	(a3)+,d1
		bne	text4_loop
		bra	text4_done

text4_zenhan:
		comp_4han
		bsr	put_4font
		move.b	(a3)+,d1
		bne	text4_loop

text4_done:
		TEXTMASK_OFF
		bsr	TEXT_ACCESS_OF

		movem.l	(sp)+,d0-d5/a0-a5
		rts

put_4font:
		move.w	d3,d1
		add.w	d1,d1
		move.w	TEXT48_MASK(pc,d1.w),d0			*�}�X�N���o��
		TEXTMASK_SET
		move.w	put_4fonttbl(pc,d1.w),d0
		jmp	put_4fonttbl(pc,d0.w)			*�ꍇ����
put_4fonttbl:
		dc.w	text410h0-put_4fonttbl	*0
		dc.w	text410h1-put_4fonttbl	*1
		dc.w	text410h1-put_4fonttbl	*2
		dc.w	text410h1-put_4fonttbl	*3
		dc.w	text410h2-put_4fonttbl	*4
		dc.w	text410h3-put_4fonttbl	*5
		dc.w	text410h3-put_4fonttbl	*6
		dc.w	text410h3-put_4fonttbl	*7
		dc.w	text410h0-put_4fonttbl	*8
		dc.w	text410h1-put_4fonttbl	*9
		dc.w	text410h1-put_4fonttbl	*10
		dc.w	text410h1-put_4fonttbl	*11
		dc.w	text410h2-put_4fonttbl	*12
		dc.w	text410h4-put_4fonttbl	*13
		dc.w	text410h4-put_4fonttbl	*14
		dc.w	text410h4-put_4fonttbl	*15

TEXT48_MASK:	.dc.w	%00001111_11111111	*0	h0
		.dc.w	%10000111_11111111	*1	h1
		.dc.w	%11000011_11111111	*2	h1
		.dc.w	%11100001_11111111	*3	h1
		.dc.w	%11110000_11111111	*4	h2
		.dc.w	%11111000_01111111	*5	h3
		.dc.w	%11111100_00111111	*6	h3
		.dc.w	%11111110_00011111	*7	h3
		.dc.w	%11111111_00001111	*8	h0
		.dc.w	%11111111_10000111	*9	h1
		.dc.w	%11111111_11000011	*10	h1
		.dc.w	%11111111_11100001	*11	h1
		.dc.w	%11111111_11110000	*12	h2
		.dc.w	%01111111_11111000	*13	h4
		.dc.w	%00111111_11111100	*14	h4
		.dc.w	%00011111_11111110	*15	h4

text410h0:
		put_4fontmac0
		addq.w	#4,d3			*d3��0��8�̂�
		rts

text410h1:
		put_4fontmac1			*d3��1�`3,9�`11
		addq.w	#4,d3
		rts

text410h2:
		put_4fontmac2			*d3��4,12
		addq.w	#4,d3
		andi.w	#15,d3
		rts

text410h3:
		put_4fontmac3			*d3��5�`7
		addq.w	#4,d3
		rts

text410h4:
		put_4fontmac4			*d3��13�`15
		subi.w	#12,d3			*d3 += 4 - 16
		rts



*==================================================
*�U���P�U�h�b�g�e�L�X�g�����\���p�}�N��
*==================================================

comphan2line	macro
		move.b	(a0)+,d0
		move.b	(a4,d0.w),(a2)+
		move.b	(a0)+,d0
		move.b	(a4,d0.w),(a2)+
		endm

comp_6han	macro
		moveq	#0,d0
		lea	TX_BF_1(a6),a2
		comphan2line
		comphan2line
		comphan2line
		comphan2line
		comphan2line
		comphan2line
		comphan2line
		comphan2line
		lea	TX_BF_1(a6),a0
		endm

compzen2line	macro
		move.b	(a0)+,d0
		move.b	(a4,d0.w),(a2)+
		move.b	(a0)+,d0
		move.b	(a4,d0.w),(a3)+
		move.b	(a0)+,d0
		move.b	(a4,d0.w),(a2)+
		move.b	(a0)+,d0
		move.b	(a4,d0.w),(a3)+
		endm

comp_6zen	macro
		moveq	#0,d0
		move.l	a3,d2
		lea	TX_BF_1(a6),a2
		lea	16(a2),a3
		compzen2line
		compzen2line
		compzen2line
		compzen2line
		compzen2line
		compzen2line
		compzen2line
		compzen2line
		lea	TX_BF_1(a6),a0
		movea.l	d2,a3
		endm

put_6font0_0	macro
		move.b	(a0)+,(a1)
		endm

put_6font0	macro	param
		move.b	(a0)+,param*128(a1)
		endm

put_6fontmac0	macro
		put_6font0_0
		put_6font0	1
		put_6font0	2
		put_6font0	3
		put_6font0	4
		put_6font0	5
		put_6font0	6
		put_6font0	7
		put_6font0	8
		put_6font0	9
		put_6font0	10
		put_6font0	11
		put_6font0	12
		put_6font0	13
		put_6font0	14
		put_6font0	15
		endm

put_6font1_0	macro
		move.b	(a0)+,d0
		ror.b	#2,d0
		move.b	d0,(a1)+
		endm

put_6font1	macro	param
		move.b	(a0)+,d0
		ror.b	#2,d0
		move.b	d0,param*128-1(a1)
		endm

put_6fontmac1	macro
		put_6font1_0
		put_6font1	1
		put_6font1	2
		put_6font1	3
		put_6font1	4
		put_6font1	5
		put_6font1	6
		put_6font1	7
		put_6font1	8
		put_6font1	9
		put_6font1	10
		put_6font1	11
		put_6font1	12
		put_6font1	13
		put_6font1	14
		put_6font1	15
		endm

put_6font2_0	macro
		move.b	(a0)+,d0
		lsl.w	d1,d0
		move.w	d0,(a1)
		endm

put_6font2	macro	param
		move.b	(a0)+,d0
		lsl.w	d1,d0
		move.w	d0,param*128(a1)
		endm

put_6fontmac2	macro
		moveq	#8,d1
		sub.w	d3,d1
		put_6font2_0
		put_6font2	1
		put_6font2	2
		put_6font2	3
		put_6font2	4
		put_6font2	5
		put_6font2	6
		put_6font2	7
		put_6font2	8
		put_6font2	9
		put_6font2	10
		put_6font2	11
		put_6font2	12
		put_6font2	13
		put_6font2	14
		put_6font2	15
		addq.l	#1,a1
		endm

put_6font3_0	macro
		move.b	(a0)+,d0
		rol.b	d1,d0
		move.b	d0,(a1)+
		move.b	d0,(a1)
		endm

put_6font3	macro	param
		move.b	(a0)+,d0
		rol.b	d1,d0
		move.b	d0,param*128-1(a1)
		move.b	d0,param*128(a1)
		endm

put_6fontmac3	macro
		moveq	#16,d1
		sub.w	d3,d1
		put_6font3_0
		put_6font3	1
		put_6font3	2
		put_6font3	3
		put_6font3	4
		put_6font3	5
		put_6font3	6
		put_6font3	7
		put_6font3	8
		put_6font3	9
		put_6font3	10
		put_6font3	11
		put_6font3	12
		put_6font3	13
		put_6font3	14
		put_6font3	15
		endm


*==================================================
*�U���P�U�h�b�g�e�L�X�g�����\��
*	d0.b <- �e�L�X�g�A�N�Z�X���[�h
*	d1.b <- �\��2�h�b�g�P�ʉ����炵�w��(0�`3)�i���ۂ�d1��2�{�ɂȂ�j
*	a0.l <- �f�[�^�[�A�h���X
*	a1.l <- �o�̓A�h���X
*	�Q�l�F	�f�[�^�[�I���R�[�h�͂O�C�R���g���[���A�d�r�b�V�[�P���X�͎g���Ȃ�
*		�s�d�w�s�Q�S�Q�W�̗l�Ȏ��l�ߋ@�\�͂Ȃ�
*==================================================

TEXT_6_16:
		movem.l	d0-d3/a0-a5,-(sp)

		bsr	TEXT_ACCESS_ON
		TEXTMASK_ON

		move.w	a1,d3			*d3 : shift mode(0-14)
		andi.w	#1,d3
		add.w	d3,d3
		add.w	d3,d3
		add.w	d1,d3
		andi.w	#7,d3
		add.w	d3,d3

		movea.l	a0,a3			*a3 : string
		lea	TO6BIT_TBL(a6),a4	*a4 : to6bit table
		lea	CH6_00(pc),a5		*a5 : 6dot font address

		bra	text6_hannext

text6_loop:
		kanji_check	d1,text6_han,text6_zen
		subi.b	#$20,d1
text6_han:
		moveq	#0,d0
		move.b	d1,d0				*���p��p�t�H���g�̃A�h���X�v�Z
		lsl.w	#4,d0
		lea	(a5,d0.w),a0
		bsr	put_6font
text6_hannext:
		move.b	(a3)+,d1
		bne	text6_loop
		bra	text6_done

text6_zen:
		lsl.w	#8,d1
		move.b	(a3)+,d1
		beq	text6_done
		moveq	#8,d2
		IOCS	_FNTADR				*�S�p�t�H���g�A�h���X
		movea.l	d0,a0
		tst.w	d1
		beq	text6_zenhan
		comp_6zen
		bsr	put_6font
		bsr	put_6font
		move.b	(a3)+,d1
		bne	text6_loop
		bra	text6_done
text6_zenhan:
		comp_6han
		bsr	put_6font
		move.b	(a3)+,d1
		bne	text6_loop

text6_done:
		TEXTMASK_OFF
		bsr	TEXT_ACCESS_OF

		movem.l	(sp)+,d0-d3/a0-a5
		rts

put_6font:
		move.w	TEXT610MASK(pc,d3.w),d0			*�}�X�N���o��
		TEXTMASK_SET
		move.w	put_6fonttbl(pc,d3.w),d0
		jmp	put_6fonttbl(pc,d0.w)			*�ꍇ����

put_6fonttbl:
		dc.w	text610h0-put_6fonttbl
		dc.w	text610h1-put_6fonttbl
		dc.w	text610h2-put_6fonttbl
		dc.w	text610h2-put_6fonttbl
		dc.w	text610h0-put_6fonttbl
		dc.w	text610h1-put_6fonttbl
		dc.w	text610h3-put_6fonttbl
		dc.w	text610h3-put_6fonttbl

TEXT610MASK:	.dc.w	%00000011_11111111 *0
		.dc.w	%11000000_11111111 *2
		.dc.w	%11110000_00111111 *4
		.dc.w	%11111100_00001111 *6
		.dc.w	%11111111_00000011 *8
		.dc.w	%11111111_11000000 *10
		.dc.w	%00111111_11110000 *12
		.dc.w	%00001111_11111100 *14

text610h0:				*d3: 0 8
		put_6fontmac0
		addq.w	#6,d3
		rts

text610h1:				*d3: 2 10
		put_6fontmac1
		addq.w	#6,d3
		andi.w	#15,d3
		rts

text610h2:				*d3: 4 6
		put_6fontmac2
		addq.w	#6,d3
		rts

text610h3:				*d3: 12 14
		put_6fontmac3
		subi.w	#10,d3		*d3 += 6 - 16
		rts


*==================================================
*��8*n�h�b�g�~�c�P�U�h�b�g���Ńe�L�X�g���N���A����
*	d0.w <- n
*	a0.l <- �������݃A�h���X
*	�Q�l�F�e�L�X�g�v���[���̐ݒ�͂��炩���߂���Ă�������
*==================================================

TXLINE_CLEAR:
		movem.l	d0-d2/a0,-(sp)
		move.w	d0,d1
		moveq	#0,d2
		cmpi.w	#3,d1			*3bytes�ȉ��Ȃ�ŏ�����1byte�P�ʂŏ���
		bls	txline_clear30

		move.l	a0,d0			*long���E�ɂȂ�܂�1byte�P�ʂŏ���
		andi.w	#3,d0
		beq	txline_clear19
		sub.w	d0,d1
		bsr	txline_clearsub
txline_clear19:

		move.w	d1,d0
		lsr.w	#2,d0
		bra	txline_clear29
txline_clear20:
		move.l	d2,(a0)+		*4bytes(32dot)�P�ʂŏ���
		move.l	d2,$080-4(a0)
		move.l	d2,$100-4(a0)
		move.l	d2,$180-4(a0)
		move.l	d2,$200-4(a0)
		move.l	d2,$280-4(a0)
		move.l	d2,$300-4(a0)
		move.l	d2,$380-4(a0)
		move.l	d2,$400-4(a0)
		move.l	d2,$480-4(a0)
		move.l	d2,$500-4(a0)
		move.l	d2,$580-4(a0)
		move.l	d2,$600-4(a0)
		move.l	d2,$680-4(a0)
		move.l	d2,$700-4(a0)
		move.l	d2,$780-4(a0)
txline_clear29:
		dbra	d0,txline_clear20

txline_clear30:
		moveq	#3,d0			*�c���1byte�P�ʂŏ���
		and.w	d1,d0
		bsr	txline_clearsub

		movem.l	(sp)+,d0-d2/a0
		rts


txline_clearsub:
		bra	txline_clearsub19
txline_clearsub10:
		move.b	d2,(a0)+		*1byte(8dot)�P�ʂŏ���
		move.b	d2,$080-1(a0)
		move.b	d2,$100-1(a0)
		move.b	d2,$180-1(a0)
		move.b	d2,$200-1(a0)
		move.b	d2,$280-1(a0)
		move.b	d2,$300-1(a0)
		move.b	d2,$380-1(a0)
		move.b	d2,$400-1(a0)
		move.b	d2,$480-1(a0)
		move.b	d2,$500-1(a0)
		move.b	d2,$580-1(a0)
		move.b	d2,$600-1(a0)
		move.b	d2,$680-1(a0)
		move.b	d2,$700-1(a0)
		move.b	d2,$780-1(a0)
txline_clearsub19:
		dbra	d0,txline_clearsub10
		rts


*==================================================
*�p�^�[���v���[���ύX
*	d1.l <- (���C����-1) * $10000 + X�����o�C�g��-1
*	a1.l <- �\������A�h���X(�v���[��0�̃A�h���X)
*==================================================

DARK_PATTERN:
		movem.l	d0-d3/a0-a1,-(sp)
		move.l	a1,a0			*�v���[���P����O��
		adda.l	#$20000,a0
		bra	light_pattern00

LIGHT_PATTERN:
		movem.l	d0-d3/a0-a1,-(sp)
		move.l	a1,a0			*�v���[���O����P��
		adda.l	#$20000,a1
light_pattern00:
		moveq	#127,d2			*�A�h���X�����v�Z
		sub.w	d1,d2
		swap	d1
light_pattern10:
		swap	d1
		move.w	d1,d0
		swap	d1
light_pattern20:
		move.b	(a0)+,d3
		or.b	d3,(a1)+
		clr.b	-1(a0)
		dbra	d0,light_pattern20
		adda.w	d2,a0
		adda.w	d2,a1
		dbra	d1,light_pattern10
		movem.l	(sp)+,d0-d3/a0-a1
		rts


*==================================================
*�p�^�[���n�q�\��
*	d1.l <- (���C����-1) * $10000 + X�����o�C�g��-1
*	a0.l <- �p�^�[���e�[�u���̃A�h���X
*	a1.l <- �\������A�h���X
*==================================================

PUT_PATTERN_OR:
		movem.l	d0-d3/a0-a1,-(sp)
		moveq	#127,d2			*�A�h���X�����v�Z
		sub.w	d1,d2
		swap	d1
put_pattern_or10:
		swap	d1
		move.w	d1,d0
		swap	d1
put_pattern_or20:
		move.b	(a0)+,d3
		or.b	d3,(a1)+
		dbra	d0,put_pattern_or20
		adda.w	d2,a1
		dbra	d1,put_pattern_or10
		movem.l	(sp)+,d0-d3/a0-a1
		rts


*==================================================
*�p�^�[���\��
*	d0.l <- �����炵�h�b�g�� * $10000 + �A�N�Z�X���[�h(0-3)
*	d1.l <- (���C����-1) * $10000 + X�����o�C�g��-1
*	a0.l <- �p�^�[���e�[�u���̃A�h���X
*	a1.l <- �\������A�h���X
*==================================================

PUT_PATTERN:
		movem.l	d0-d6/a0-a2,-(sp)
		bsr	TEXT_ACCESS_ON
		TEXTMASK_ON
		swap	d0			*���炵���̎w�肪�L���
		tst.w	d0
		bne	put_patterns		*���炵�Ή����[�`����
		swap	d1			*���炵�Ȃ��̏ꍇ
put_pattern10:
		movea.l	a1,a2
		swap	d1
		move.w	d1,d0
		swap	d1
put_pattern20:
		move.b	(a0)+,(a2)+
		dbra	d0,put_pattern20
		lea	128(a1),a1
		dbra	d1,put_pattern10
put_pattern90:
		TEXTMASK_OFF
		bsr	TEXT_ACCESS_OF
		movem.l	(sp)+,d0-d6/a0-a2
		rts

put_patterns::
		move.w	d0,d6			*���炵�̂���ꍇ
		moveq	#-1,d0
		lsr.b	d6,d0			*d4 = mask
		move.b	d0,d4
		lsl.w	#8,d4
		move.b	d0,d4
		move.w	d4,d5			*d5 = mask rev
		not.w	d5
		move.l	d1,d2
		swap	d2
put_patterns10:
		movea.l	a1,a2
		swap	d2
		move.w	d2,d3
		swap	d2
put_patterns20:
		move.b	(a0)+,d1
		ror.b	d6,d1
		move.w	d5,d0
		TEXTMASK_SET
		move.b	d1,(a2)+
		move.w	d4,d0
		TEXTMASK_SET
		move.b	d1,(a2)
		dbra	d3,put_patterns20
		lea	128(a1),a1
		dbra	d2,put_patterns10
		bra	put_pattern90


		.end
