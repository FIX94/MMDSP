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
*									*
*************************************************************************

		.include	iocscall.mac
		.include	doscall.mac
		.include	MMDSP.H


	.offset	0
DV_FONTSZ:	.ds.w	1
DV_OUTPUT:	.ds.w	1


			.text
			.even


*
*	���c�n�b�u�h�d�v�Q�h�m�h�s
*���́F	�c�O	���������i���.w�F������,����.w�F�c�����j
*	�c�P	�\���J�n�ʒu�i���.w�F�w���W�W�h�b�g�P��,����.w�F�x�S�h�b�g�P�ʁj
*	�c�Q.w	�t�H���g�w��
*	�`�O	�ǂݍ��݃t�@�C���l�[��
*�o�́F	�c�O	���̏ꍇ�̓G���[
*
*�Q�l�F	FILE_BUFF(A6)���g���B
*

DOCVIEW_INIT:
		movem.l	d1-d2/d6-d7/a0,-(sp)

		bsr	docv_inipara		*�����Ҕ����v�Z

		clr.l	DOCV_MEMPTR(a6)		*MEM�m�ۂ��������`�F�b�N���邽��

		clr.w	-(sp)			*�w��̃t�@�C�����I�[�v��
		move.l	a0,-(sp)
		DOS	_OPEN
		addq.l	#6,sp

		move.l	d0,d7			*���[�Ղ�ł��Ȃ����`
		bmi	docvinit_err

		bsr	docv_malloc		*�������m��
		tst.l	d0
		bmi	docvinit_err

		move.l	d0,DOCV_MEMPTR(a6)
		move.l	d0,a0
		addq.l	#1,d0			*�ŏ���$00�̎��̃A�h���X������
		move.l	d0,DOCV_NOW(a6)
		move.l	d1,d6

		bsr	docv_fileread		*�t�@�C���ǂݍ���
		tst.l	d0
		bmi	docvinit_err
		move.l	a0,DOCV_MEMEND(a6)	*�Ō��$00�̎��̃A�h���X������

		move.l	d0,-(sp)		*�������u���b�N�ύX
		move.l	DOCV_MEMPTR(a6),-(sp)
		DOS	_SETBLOCK
		addq.l	#8,sp
		tst.l	d0			*�G���[�͏o�Ȃ��������ǔO�̂���
		bmi	docvinit_err

		move.w	d7,-(sp)		*�ӂ����邭��[���`
		DOS	_CLOSE
		addq.l	#2,sp

		move.w	DOCV_TATE(a6),d0	*���ǂꂷ�����Ɓ[
docv_inisigend:
		bsr	DOCV_PTR_BACK
		dbra	d0,docv_inisigend
		move.l	a0,DOCV_SIGEND(a6)

		move.l	#TXTADR+512*$80,a0	*TEXT(0,512)-(512,527)���N���A
		moveq.l	#3,d0			*�i����ɂ��Ă͖������Q�Ɓj
		bsr	TEXT_ACCESS_ON
		moveq.l	#64,d0
		bsr	TXLINE_CLEAR
		bsr	TEXT_ACCESS_OF


		moveq.l	#0,d0			*����I��
		movem.l	(sp)+,d1-d2/d6-d7/a0
		rts

docvinit_err:
		move.l	DOCV_MEMPTR(a6),d0	*�G���[���������Ƃ�
		beq	docvinit_errj0		*�������m�ۂ��Ă��Ȃ�J������

		move.l	d0,-(sp)
		DOS	_MFREE
		addq.l	#4,sp
docvinit_errj0:
		tst.l	d7			*�t�@�C���I�[�v�����Ă������
		bpl	docvinit_errj1

		move.w	d7,-(sp)
		DOS	_CLOSE
		addq.l	#2,sp
docvinit_errj1:
		moveq.l	#-1,d0			*�G���[�I��
		movem.l	(sp)+,d1-d2/d6-d7/a0
		rts

docv_inipara:
		movem.l	d0-d2/a1,-(sp)		*�����Ҕ����v�Z

		move.l	d0,DOCV_YOKO(a6)	*YOKO,TATE���������̂ɒ���(.L size)

		lea.l	DOCV_FTABLE(pc),a1	*�t�H���g�ʃe�[�u���A�h���X�ݒ�
		lsl.w	#2,d2			*FTABLE�̂P�T�C�Y�͂S�o�C�g
		lea.l	0(a1,d2.w),a1
		move.l	a1,DOCV_FONT(a6)

		move.w	DV_FONTSZ(a1),d0	*���X�^�ʒu�v�Z
		mulu.w	DOCV_TATE(a6),d0
		add.w	d1,d0
		move.b	d1,DOCV_RAS1(a6)
		move.b	d0,DOCV_RAS2(a6)

		move.l	#TXTADR,d0		*�e�L�X�g�A�h���X�v�Z
		swap.w	d1
		add.w	d1,d0
		clr.w	d1
		swap.w	d1
		lsl.l	#7,d1
		lsl.l	#2,d1
		add.l	d1,d0
		move.l	d0,DOCV_TXTADR(a6)

		move.w	DV_FONTSZ(a1),d1	*�e�L�X�g�A�h���X���̂Q
		lsl.w	#2,d1
		move.w	DOCV_TATE(a6),d0
		mulu.w	d1,d0
		sub.w	d1,d0
		ext.l	d0
		lsl.l	#7,d0
		move.l	DOCV_TXTADR(a6),d1
		add.l	d0,d1
		move.l	d1,DOCV_TXTAD2(a6)

		movem.l	(sp)+,d0-d2/a1
		rts

docv_malloc:
		move.l	#$100000,-(sp)		*�Ƃ肠�����P���K�m��
		DOS	_MALLOC			*�����牽�ł��P���K�ȏ��DOC��
		addq.l	#4,sp			*MMDSP��Ō���l�͂��Ȃ��ł��傤^^;

		tst.l	d0
		bmi	docv_malloc_j0

		move.l	#$100000,d1		*�P���K�m�ۏo�������b�`�Ȑl��
		bra	docv_malloc_j1		*���̂܂܏I��
docv_malloc_j0:
		sub.l	#$81000000,d0		*�����łȂ��n�R�Ȑl��
		move.l	d0,d1			*�m�ۂł���ő�o�C�g���m�ۂ���
		move.l	d0,-(sp)
		DOS	_MALLOC
		addq.l	#4,sp			*�����Ŋm�ۏo���Ȃ��Ă�d0�ɕ����͂���
docv_malloc_j1:
		rts


*d0 -> ���ۂɎg�����������i���̏ꍇ�̓G���[�j
*d6 <- �m�ۂ����������̑傫��
*d7 <- �t�@�C���n���h��
*a0 <- �������ւ̃|�C���^
*   -> ������A�h���X�ia0+d0�j

docv_fileread:
		movem.l	d1-d2/d4-d5/a1,-(sp)

		moveq.l	#0,d5			*���ێg�����o�C�g�J�E���^�`
		moveq.l	#0,d2			*FILE_BUFF�ɂ���o�C�g��
		move.w	DOCV_YOKO(a6),d4	*�����c��o�C�g
		subq.w	#1,d4

		bsr	docv_chr_crlf		*�ŏ��ɉ��s(stop check�p)
		bmi	docv_fread_err		*�܂����ŏ���MEM�s���Ȃ�ĂȂ���ˁH^^;
docv_fread_lp:
		bsr	docv_fgetc
		tst.l	d0
		bpl	docv_fread_mn
docv_fread_dne:
		bsr	docv_chr_crlf		*�Ō�͔O�̂��߉��s������
						*byte check���Ȃ��Ă����ށi�Ǝv��^^;�j
		move.l	d5,d0
		movem.l	(sp)+,d1-d2/d4-d5/a1
		rts

docv_fread_err:
		moveq.l	#-1,d0
		movem.l	(sp)+,d1/d4-d5/a1
		rts

						*�����̃\�[�X�݂͂ɂ����Ȃ��`�i�΁j
						*�ʃv���O�����̎g���񂵁E�E�E(^^;)
docv_fread_mn:
		tst.b	d0
		beq	docv_fread_lp		*$00�R�[�h�͖�������i�蔲���j
		bpl	docv_chr1b		*$01�`$7F�͂P�o�C�g�����i�p��&CTRL�j
		cmp.b	#$a0,d0
		bcs	docv_chr2b		*$80�`$9F�͂Q�o�C�g����
		cmp.b	#$e0,d0			*$A0�`$DF�͂P�o�C�g�����i�J�i�j
		bcc	docv_chr2b		*$E0�`$FF�͂Q�o�C�g����

docv_chr1b:					*�P�o�C�g�����̎�
		cmp.b	#9,d0			*�^�u�̓X�y�[�X�ɓW�J
		beq	docv_ctrl_tab
		cmp.b	#10,d0			*�k�e�R�[�h�͖���(^^;
		beq	docv_fread_lp
		cmp.b	#13,d0			*�b�q�R�[�h�͉��s��(^^;
		beq	docv_ctrl_crlf

		subq.w	#1,d4
		bra	docv_chr1b_out		*�������݂�


docv_chr2b:					*�Q�o�C�g�����̎�
		cmp.b	#$80,d0			* �`$80FF �͔��p
		beq	docv_chr2b_han
		cmp.b	#$f0,d0			* $F000�` �����p
		bcc	docv_chr2b_han

		tst.w	d4			*�S�p�����̎���
		bne	docv_chr2b_zen		*�P�s�̎c�蕶�������p�������Ȃ�������
		move.w	d0,d1
		bsr	docv_chr_crlf		*���s������
		bmi	docv_fread_err
		move.w	d1,d0
docv_chr2b_zen:
		subq.w	#2,d4
		bra	docv_chr2b_out
docv_chr2b_han:
		subq.w	#1,d4
docv_chr2b_out:
		bsr	docv_memputc		*�Q�o�C�g�����̂P�o�C�g�ڏ�������
		tst.l	d0
		bmi	docv_fread_err

		bsr	docv_fgetc		*�Q�o�C�g�����̂Q�o�C�g�ڂ�����Ă���
		tst.l	d0
		bmi	docv_fread_dne

docv_chr1b_out:
		bsr	docv_memputc		*��������
		tst.l	d0
		bmi	docv_fread_err

		tst.w	d4
		bpl	docv_fread_lp
docv_ctrl_crlf:
		bsr	docv_chr_crlf		*�����A�s�̏I���ɂ�����
		bmi	docv_fread_err		*���s����
		bra	docv_fread_lp

docv_ctrl_tab:
		move.w	DOCV_YOKO(a6),d1	*�^�u���X�y�[�X�ɓW�J���ďo��
		subq.w	#1,d1
		sub.w	d4,d1

		and.w	#7,d1		*������ւ���蒼���i�蔲�������ǁi�΁j
		eori.w	#7,d1

		cmp.w	#7,d4
		bcs	docv_ctrl_crlf
docv_ctrl_tab1:
		moveq.l	#32,d0
		bsr	docv_memputc
		tst.l	d0
		bmi	docv_fread_err
		subq.w	#1,d4

		dbra	d1,docv_ctrl_tab1
		bra	docv_fread_lp

docv_chr_crlf:					*���s�R�[�h�o��
		move.w	DOCV_YOKO(a6),d4	*�����c��o�C�g�Đݒ�
		subq.w	#1,d4

		moveq.l	#0,d0			*�������s�R�[�h�́��O�O
		bsr	docv_memputc
		tst.l	d0
		rts

*docv_fgetc
*�t�@�C������P�o�C�g���o��
*�P�O�Q�S�P�ʂŃf�B�X�N����ǂݏo���Ă���
*FILE_BUFF(a6)���o�b�t�@�Ɏg��
*�������悤�ȃ��[�`�����Ăǂ����ɂȂ����������H�i�΁j
*�i�y�l�t�r�h�b�̃^�C�g�������ӂ�ɁE�E�E^^;;�j

docv_fgetc:
		tst.w	d2
		bne	docv_fgetc_jp0

		lea.l	FILE_BUFF(a6),a1
		move.l	#1024,-(sp)
		move.l	a1,-(sp)
		move.w	d7,-(sp)
		DOS	_READ
		lea.l	10(sp),sp

		move.w	d0,d2			*���ۂɓǂݍ��񂾃o�C�g��
		beq	docv_fgetc_err		*�����P�o�C�g���ǂ�łȂ�������
						*�t�@�C���̏I���ƌ��Ȃ�
docv_fgetc_jp0:
		moveq.l	#0,d0
		move.b	(a1)+,d0
		subq.w	#1,d2
		rts
docv_fgetc_err:
		moveq.l	#-1,d0
		rts


*docv_memputc
*�������ւP�o�C�g�����o��
*�ő�o�C�g�`�F�b�N������
*

docv_memputc:
		move.b	d0,(a0)+
		addq.l	#1,d5
		cmp.l	d6,d5
		bge	docv_memputer
		moveq.l	#0,d0
		rts
docv_memputer:
		moveq.l	#-1,d0
		rts

*DOCV_PTR_NEXT
*a0 -> �ړ���ʒu�i$00�̎��̃A�h���X�j
*CCR -> ��:ERR
DOCV_PTR_NEXT:
		tst.b	(a0)+
		bne	DOCV_PTR_NEXT

		cmp.l	DOCV_MEMEND(a6),a0
		beq	docv_ptr_nxerr

		andi.b	#%11110111,CCR
		rts
docv_ptr_nxerr:
		bsr	DOCV_PTR_BACK		*���ɖ߂��i�蔲��^^;�j
		ori.b	#%00001000,CCR
		rts

*DOCV_PTR_BACK
*a0 -> �ړ���ʒu�i$00�̎��̃A�h���X�j
*CCR -> ��:ERR
DOCV_PTR_BACK:
		subq.l	#1,a0
		cmp.l	DOCV_MEMPTR(a6),a0
		beq	docv_ptr_bkerr
docv_ptr_back0:
		tst.b	-(a0)
		bne	docv_ptr_back0

		addq.l	#1,a0
		andi.b	#%11110111,CCR
		rts
docv_ptr_bkerr:
		addq.l	#1,a0
		ori.b	#%00001000,CCR
		rts


DOCV_NOW_PRT:
		movem.l	d0-d1/d7/a0-a2,-(sp)

		bsr	DOCV_CLRALL

		move.l	DOCV_FONT(a6),a2	*�t�H���g�ʃA�h���X���o��
		move.w	DV_OUTPUT(a2),d0
		lea.l	DOCV_JPPTR(pc,d0.w),a2

		move.l	DOCV_NOW(a6),a0
		move.l	DOCV_TXTADR(a6),a1

		move.w	DOCV_TATE(a6),d7
		subq.w	#1,d7

		moveq.l	#3,d0			*d1��bit31��1�ł�TEXT_6_16�ɉe���͂Ȃ�
		moveq.l	#0,d1			*����܂�C�����ǂ��Ȃ����ǁA�蔲��^^;
		bset.l	#31,d1			*���A�킩���Ă�Ǝv�����ǂ��̃r�b�g��
docv_nowprt_lp:					*TEXT_4_8�Ŏg���񂾂�`�B
		jsr	(a2)

		bsr	DOCV_PTR_NEXT
		dbmi	d7,docv_nowprt_lp

		move.l	a0,DOCV_NEXT(a6)

		movem.l	(sp)+,d0-d1/d7/a0-a2
		rts

DOCV_JPPTR:
DOCV_FP16:
		bsr	TEXT_6_16
		lea.l	$80*16(a1),a1
		rts
DOCV_FP8:
		bsr	TEXT_4_8
		lea.l	$80*12(a1),a1
		rts

DOCVIEW_UP:
		movem.l	d0-d2/a0-a2,-(sp)

		move.l	DOCV_NOW(a6),a0
		bsr	DOCV_PTR_BACK
		bmi	docview_updne

		move.l	DOCV_TXTADR(a6),a1
		move.l	a0,DOCV_NOW(a6)

		bsr	DOCV_SCUP

		moveq.l	#3,d0
		moveq.l	#0,d1
		bset.l	#31,d1

		move.l	DOCV_FONT(a6),a2	*�t�H���g�ʃA�h���X���o��
		move.w	DV_OUTPUT(a2),d2
		lea.l	DOCV_JPPTR(pc),a2
		jsr	0(a2,d2.w)

		move.l	DOCV_NEXT(a6),a0
		bsr	DOCV_PTR_BACK
		move.l	a0,DOCV_NEXT(a6)

docview_updne:
		movem.l	(sp)+,d0-d2/a0-a2
		rts

DOCVIEW_DOWN:
		movem.l	d0-d2/a0-a2,-(sp)

		move.l	DOCV_NOW(a6),a0
		cmp.l	DOCV_SIGEND(a6),a0
		beq	docview_dwdne

		bsr	DOCV_PTR_NEXT
		bmi	docview_dwdne
		move.l	a0,DOCV_NOW(a6)

		bsr	DOCV_SCDW

		moveq.l	#3,d0
		moveq.l	#0,d1
		bset.l	#31,d1
		move.l	DOCV_NEXT(a6),a0
		move.l	DOCV_TXTAD2(a6),a1

		move.l	DOCV_FONT(a6),a2
		move.w	DV_OUTPUT(a2),d2
		lea.l	DOCV_JPPTR(pc),a2
		jsr	0(a2,d2.w)

		bsr	DOCV_PTR_NEXT
		move.l	a0,DOCV_NEXT(a6)

docview_dwdne:
		movem.l	(sp)+,d0-d2/a0-a2
		rts

DOCV_ROLLUP:
		movem.l	d0/a0,-(sp)

		move.l	DOCV_NOW(a6),a0		*���[���A�b�v�o���邩�H
		cmp.l	DOCV_SIGEND(a6),a0
		beq	docv_rlup_done

		move.w	DOCV_TATE(a6),d0	*�|�C���^�ړ�
		subq.w	#1,d0
		bmi	docv_rlup_done
docv_rlup_lp:
		bsr	DOCV_PTR_NEXT
		bmi	docv_rlup_prt
		cmp.l	DOCV_SIGEND(a6),a0
		dbeq	d0,docv_rlup_lp
docv_rlup_prt:
		move.l	a0,DOCV_NOW(a6)
		bsr	DOCV_NOW_PRT
docv_rlup_done:
		movem.l	(sp)+,d0/a0
		rts

DOCV_ROLLDOWN:
		movem.l	d0/a0,-(sp)

		move.l	DOCV_NOW(a6),a0		*���[���_�E���o���邩�H
		bsr	DOCV_PTR_BACK
		bmi	docv_rldw_done

		move.w	DOCV_TATE(a6),d0	*�|�C���^�ړ�
		subq.w	#2,d0			*�|�Q�Ȃ̂͂������P��PTR_BACK��������
		bmi	docv_rldw_prt
docv_rldw_lp:
		bsr	DOCV_PTR_BACK
		dbmi	d0,docv_rldw_lp
docv_rldw_prt:
		move.l	a0,DOCV_NOW(a6)
		bsr	DOCV_NOW_PRT
docv_rldw_done:
		movem.l	(sp)+,d0/a0
		rts

DOCV_CLRALL:
		movem.l	d0-d3,-(sp)		*view�͈͂��N���A

		move.w	#$8000,d1		*�i�������Q�ƁE�E�j
		or.b	DOCV_RAS1(a6),d1

		moveq.l	#1,d2			*(0,512)����N���A����`
		move.w	#%11,d3
		IOCS	_TXRASCPY

		move.b	DOCV_RAS2(a6),d2	*��C�ɂ炷���R�s�[�N���A
		sub.b	DOCV_RAS1(a6),d2
		subq.w	#1,d2

		move.l	d1,d0
		lsl.w	#8,d1
		and.w	#$FF,d0
		addq.w	#1,d0
		or.w	d0,d1

		move.w	#%11,d3
		IOCS	_TXRASCPY

		movem.l	(sp)+,d0-d3
		rts

DOCV_SCDW:
		movem.l	d0-d3/a1,-(sp)

		move.l	DOCV_FONT(a6),a1	*���X�^�v�Z

		moveq.l	#0,d2
		move.b	DOCV_RAS2(a6),d2	*������̌v�Z�͔͈͂������Ȃ疈�񓯂�
		sub.b	DOCV_RAS1(a6),d2	*�l���o��̂ł������̂��ƃ��[�N��
		sub.w	DV_FONTSZ(a1),d2	*�ۑ�����̂��]�܂����Ǝv����(^^;

		moveq.l	#0,d1
		move.b	DOCV_RAS1(a6),d1
		add.w	DV_FONTSZ(a1),d1
		lsl.w	#8,d1
		move.b	DOCV_RAS1(a6),d1

		move.w	#%11,d3
		IOCS	_TXRASCPY


		move.w	#$8000,d1		*�i�������Q�ƁE�E�E�j
		or.b	DOCV_RAS2(a6),d1
		move.w	DV_FONTSZ(a1),d2
		sub.w	d2,d1

		move.w	#%11,d3
		IOCS	_TXRASCPY

		movem.l	(sp)+,d0-d3/a1
		rts

DOCV_SCUP:
		movem.l	d0-d3/a1,-(sp)

		move.l	DOCV_FONT(a6),a1	*���X�^�v�Z

		moveq.l	#0,d2
		move.b	DOCV_RAS2(a6),d2	*SCDW�Ɠ����悤�ȏ���
		sub.b	DOCV_RAS1(a6),d2
		sub.w	DV_FONTSZ(a1),d2

		moveq.l	#0,d1
		move.b	DOCV_RAS2(a6),d1
		sub.w	DV_FONTSZ(a1),d1
		subq.w	#1,d1
		lsl.w	#8,d1
		move.b	DOCV_RAS2(a6),d1
		subq.w	#1,d1

		move.w	#$FF03,d3
		IOCS	_TXRASCPY


		move.w	#$8000,d1		*�i�������Q�ƁE�E�E�j
		or.b	DOCV_RAS1(a6),d1
		move.w	DV_FONTSZ(a1),d2

		move.w	#%11,d3
		IOCS	_TXRASCPY

		movem.l	(sp)+,d0-d3/a1
		rts


			.data
			.even

DOCVFDATA:	.macro	fysize,label1
		.dc.w	fysize			*�����ݍō��S�܂ŁE�E
		.dc.w	label1-DOCV_JPPTR
		.endm

DOCV_FTABLE:
		DOCVFDATA	4,DOCV_FP16
		DOCVFDATA	3,DOCV_FP8

			.end

�����F
TEXT(0,512)-(512,527)���N���A���Ăт��͈̓N���A�̎���
��������^�����S���C�������Ă��Ă��肠����`�i�킩��ɂ�������^^;�j
��[����ɁA�Q�i�K�ł��肠���Ă�񂾂ˁB^^;;;
�����Əڂ����������Ɓ`(^^;

+(�ر�ݲ----	�ځځ�___��2:�����ɃR�s�[����
|	��3:׽���߰�ر	|
|		��	|
|		��	|
+(�����-----		|
|    :			|
(0,512)-----��1:��������~
+-----------

���݂̂Ƃ���A�X�N���[�����āA�V�����ł����s���N���A����̂�
(0,512)�̂������烉�X�^�R�s�[�N���A������̂ŁA�t�H���g�h�b�g�T�C�Y��
�x�P�U�h�b�g�܂łƂ������������B�i�ڂ����̓\�[�X�Q�Ɓj���ܶ�Ų����^^;;
�i�܂��c�P�U�h�b�g�ȏ�̕����Ȃ�ĕ\�����Ă��˂��E�E�E^^;�j

