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
*	���a�f�Q�o�q�h�m�s
*�@�\�F�a�f�e�L�X�g�Ƀf�[�^�[����������
*���́F	�c�O	�f�[�^�[�ɉ����鐔
*	�`�O	�ǂݍ��݃A�h���X
*	�`�P	�������݃A�h���X
*�o�́F�Ȃ�
*�Q�l�F�ǂݍ��݃f�[�^�[�̓o�C�g�P�ʁD����ɂc�O�������ď������ށD
*

BG_PRINT:
		movem.l	d0-d1/a0-a1,-(sp)

		bra	bg_print_start
bg_print_loop:
		add.w	d0,d1
		move.w	d1,(a1)+
bg_print_start:
		moveq.l	#0,d1
		move.b	(a0)+,d1
		bne	bg_print_loop

		movem.l	(sp)+,d0-d1/a0-a1
		rts

*
*	���a�f�Q�k�h�m�d
*�@�\�F�a�f�e�L�X�g�ɉ������A���f�[�^�[����������
*���́F	�c�O	�f�[�^�[
*	�c�P	�������ރo�C�g��-1
*	�`�O	�������݃A�h���X
*�o�́F�Ȃ�
*�Q�l�F
*

BG_LINE:
		movem.l	d1/a0,-(sp)
bg_line_loop:
		move.w	d0,(a0)+
		dbra	d1,bg_line_loop

		movem.l	(sp)+,d1/a0
		rts

*
*	���o�q�h�m�s�H�H�Q�H�j�d�s�`
*�@�\�F�P�O�i�^�P�U�i�\��
*���́F	�c�O	�\�����鐔
*	�`�O	�o�̓A�h���X
*�o�́F�Ȃ�
*�Q�l�F�ڂ������x���͈ȉ����Q�Ƃ̎�
*
*
*�l�l�c�r�o�ōl�����鐔���\���p�^�[��
*
*	�P�U�i			���x����
*		00		PRINT16_2KETA
*		00_00		PRINT16_4KETA
*		00_00_00	PRINT16_6KETA
*		0_0		PRINT16_2KT_T�i���v�\���p�j
*	�P�O�i
*		00		PRINT10_2KETA
*		00_0		PRINT10_3KETA
*		00_00_0		PRINT10_5KETA
*		_:00_00_0	PRINT10_5KT_F
*		0_00		PRINT10_3KT_2
*		0.n.0		DIGIT10
*

PRINT16_2KETA:
		movem.l	d0-d1/a1,-(sp)
		lea.l	BG16_TB(a6),a1
		bra	print16_2k_jp
PRINT16_4KETA:
		movem.l	d0-d1/a1,-(sp)
		lea.l	BG16_TB(a6),a1
		bra	print16_4k_jp
PRINT16_6KETA:
		movem.l	d0-d1/a1,-(sp)
		lea.l	BG16_TB(a6),a1

		moveq.l	#0,d1
		move.b	d0,d1
		add.w	d1,d1
		move.w	0(a1,d1.w),d1
		move.w	d1,4(a0)
		lsr.l	#8,d0
print16_4k_jp:
		moveq.l	#0,d1
		move.b	d0,d1
		add.w	d1,d1
		move.w	0(a1,d1.w),d1
		move.w	d1,2(a0)
		lsr.w	#8,d0
print16_2k_jp:
		moveq.l	#0,d1
		move.b	d0,d1
		add.w	d1,d1
		move.w	0(a1,d1.w),d1
		move.w	d1,(a0)

		movem.l	(sp)+,d0-d1/a1
		rts

PRINT16_2KT_T:
		movem.l	d0-d2/a1,-(sp)
		move.l	d0,d2

		lea.l	P10___DATA(pc),a1
		and.b	#$F,d0
		bsr	print10_sub
		move.w	d1,2(a0)

		lea.l	P__10_DATA(pc),a1
		move.l	d2,d0
		lsr.b	#4,d0
		bsr	print10_sub
		move.w	d1,(a0)

		movem.l	(sp)+,d0-d2/a1
		rts

print10_sub:
		moveq.l	#0,d1
		move.b	d0,d1
		add.w	d1,d1
		move.w	0(a1,d1.w),d1
		rts

PRINT10_2KETA:
		movem.l	d0-d1/a1,-(sp)
		and.w	#$FF,d0
		ext.l	d0

		lea.l	BG10_TB(a6),a1
		bsr	print10_sub
		move.w	d1,(a0)

		movem.l	(sp)+,d0-d1/a1
		rts

PRINT10_3KETA:
		movem.l	d0-d1/a1,-(sp)
		and.w	#$FF,d0
		ext.l	d0

		lea.l	BG10_TB(a6),a1
		divu	#10,d0
		bsr	print10_sub
		move.w	d1,(a0)
		swap.w	d0

		lea.l	P10___DATA(pc),a1
		bsr	print10_sub
		move.w	d1,2(a0)

		movem.l	(sp)+,d0-d1/a1
		rts

PRINT10_5KETA:
		movem.l	d0-d1/a1,-(sp)

		swap.w	d0
		clr.w	d0
		swap.w	d0

		lea.l	P10___DATA(pc),a1
		divu	#10,d0
		swap.w	d0
		bsr	print10_sub
		move.w	d1,4(a0)
		swap.w	d0
		ext.l	d0

		lea.l	BG10_TB(a6),a1
		divu	#100,d0
		bsr	print10_sub
		move.w	d1,(a0)
		swap.w	d0

		bsr	print10_sub
		move.w	d1,2(a0)

		movem.l	(sp)+,d0-d1/a1
		rts

PRINT10_3KT_2:
		movem.l	d0-d1/a1,-(sp)
		and.w	#$FF,d0
		ext.l	d0

		lea.l	P__10_DATA(pc),a1
		divu	#100,d0
		bsr	print10_sub
		move.w	d1,(a0)
		swap.w	d0

		lea.l	BG10_TB(a6),a1
		bsr	print10_sub
		move.w	d1,2(a0)

		movem.l	(sp)+,d0-d1/a1
		rts

*
*	���o�q�h�m�s�P�O�Q�T�j�s�Q�e
*�@�\�F�P�O�i�T���A�����t�\��
*���́F	�c�O	�\�����鐔
*	�`�O	�o�̓A�h���X
*�o�́F�Ȃ�
*�Q�l�F
*

PRINT10_5KT_F:
		movem.l	d0/a0-a1,-(sp)

		lea.l	FUGOU_DATA(pc),a1
		tst.w	d0
		beq	print10_5kf_z
		bmi	print10_5kf_m
print10_5kf_p:
		move.w	2(a1),(a0)+
		bsr	PRINT10_5KETA
print10_5kf_dn:
		movem.l	(sp)+,d0/a0-a1
		rts

print10_5kf_m:
		move.w	4(a1),(a0)+
		neg.w	d0
		bsr	PRINT10_5KETA
		bra	print10_5kf_dn
print10_5kf_z:
		move.w	(a1),(a0)+
		move.w	BG10_TB(a6),d0
		move.w	d0,(a0)+
		move.w	d0,(a0)+
		move.w	P10___DATA(pc),(a0)+
		bra	print10_5kf_dn

*==================================================
*�f�W�^���P�O�i�\��
*	d0.w <- �\�����鐔
*	d1.w <- ����
*	a0.l <- �o�̓A�h���X
*==================================================

DIGIT10:
		movem.l	d0-d2/a0,-(sp)
		andi.l	#$0000ffff,d0
		move.w	d1,d2
		add.w	d2,d2
		lea	-2(a0,d2.w),a0		*��납��\�����邽�߂�
		subq.w	#1,d1

digit10_10:
		divu	#10,d0
		swap	d0
		bsr	PUT_DIGIT
		subq.l	#2,a0
		clr.w	d0
		swap	d0
		dbra	d1,digit10_10

		movem.l	(sp)+,d0-d2/a0
		rts

*==================================================
*�f�W�^���P�O�i�\���[���T�v���X��
*	d0.w <- �\�����鐔
*	d1.w <- ����
*	a0.l <- �o�̓A�h���X
*==================================================

DIGIT10S:
		movem.l	d0-d2/a0,-(sp)
		andi.l	#$0000ffff,d0
		move.w	d1,d2
		add.w	d2,d2
		lea	-2(a0,d2.w),a0		*��납��\�����邽�߂�
		subq.w	#2,d1

		divu	#10,d0			*�P�̈ʕ\��
		swap	d0
		bsr	PUT_DIGIT
		subq.l	#2,a0
		clr.w	d0
		swap	d0

digit10s_10:
		divu	#10,d0
		swap	d0
		bne	digit10s_20
		move.w	#-1,d0
digit10s_20:
		bsr	PUT_DIGIT
		subq.l	#2,a0
		clr.w	d0
		swap	d0
		dbra	d1,digit10s_10

		movem.l	(sp)+,d0-d2/a0
		rts

*==================================================
*�f�W�^���P�U�i�\��
*	d0.w <- �\�����鐔
*	d1.w <- ����
*	a0.l <- �o�̓A�h���X
*==================================================

DIGIT16:
		movem.l	d0-d2/a0,-(sp)
		andi.l	#$0000ffff,d0
		move.w	d1,d2
		add.w	d2,d2
		lea	-2(a0,d2.w),a0		*��납��\�����邽�߂�
		subq.w	#1,d1
		move.w	d0,d2

digit16_10:
		move.w	d2,d0
		andi.w	#$000f,d0
		bsr	PUT_DIGIT
		subq.l	#2,a0
		lsr.w	#4,d2
		dbra	d1,digit16_10

		movem.l	(sp)+,d0-d2/a0
		rts

*==================================================
*�f�W�^�������\��
*	d0.w <- �\�����鐔���ԍ�(0-16 ����ȊO�Ńu�����N�L����)
*	a0.l <- �o�̓A�h���X
*==================================================

PUT_DIGIT:
		movem.l	d0-d1/a1,-(sp)
		cmpi.w	#16,d0
		bls	put_digit10
		moveq	#16,d0
put_digit10:
		lea	DIGIT_CON(pc),a1
		move.b	(a1,d0.w),d0
		move.b	d0,d1
		lsr.w	#4,d0
		andi.w	#$000f,d0
		add.w	#$0230,d0
		move.w	d0,(a0)
		andi.w	#$000f,d1
		add.w	#$0230,d1
		move.w	d1,$80(a0)

		movem.l	(sp)+,d0-d1/a1
		rts


			.data
			.even

P10___DATA:	.dc.w	$CC0,$DC0,$EC0,$FC0,$CC1,$DC1,$EC1,$FC1
		.dc.w	$CC2,$DC2,$EC2,$FC2,$CC3,$DC3,$EC3,$FC3
P__10_DATA:	.dc.w	$CC4,$DC4,$EC4,$FC4,$CC5,$DC5,$EC5,$FC5
		.dc.w	$CC6,$DC6,$EC6,$FC6,$CC7,$DC7,$EC7,$FC7
FUGOU_DATA:	.dc.w	$C66,$D66,$E66

DIGIT_CON:	.dc.b	$07,$18,$29,$2A,$3B,$4A,$4C,$08
		.dc.b	$0C,$0A,$0D,$5C,$69,$1C,$49,$4E
		.dc.b	$6F
		.text

		.end
