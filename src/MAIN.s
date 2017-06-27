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
		.include	MMDSP.h
		.include	DRIVER.h


			.text
			.even

*==================================================
*	���c�h�r�o�k�`�x�Q�l�`�h�m
*�@�\�F�ǂ�Ŏ��̒ʂ�i�΁j
*���o�́F�Ȃ�
*�Q�l�F
*==================================================

DISPLAY_MAIN:
		movem.l	d0-d1/a1,-(sp)
		move.l	sp,SPSAVE_MAIN(a6)
		st.b	MMDSPON_FLAG(a6)

		bsr	set_myontime		*���OONTIME�Z�b�g�A�b�v(�����Ȃ�)

		bsr	DISP_INIT			*��ʃ��[�h������
		bsr	DRIVER_INIT			*�h���C�o������
		bsr	DISPLAY_MAKE			*��ʕ`��
		lea.l	VDISP_MAIN(pc),a0		*���荞�݃��[�`���ݒ�
		bsr	VECTOR_INIT
		bsr	STATUS_INIT

		lea	CURRENT(a6),a0			*�w��t�@�C���̉��t
		bsr	PLAY_FILE

display_mn_lp:
		bsr	CONTROL				*�S�̂̃R���g���[��
		bsr	SYSTEM_DISP			*�V�X�e�����\��
		DRIVER	DRIVER_TRKSTAT			*�h���C�o�X�e�[�^�X�擾
		bsr	KEYBORD_DISP			*���Օ\��
		bsr	LEVELM_DISP			*���x�����[�^�\��
		bsr	SPEANA_DISP			*�X�y�A�i�\��
		bsr	SELECTOR_MAIN			*�Z���N�^
		tst.w	QUIT_FLAG(a6)
		beq	display_mn_lp			*�I���w��������܂Ń��[�v

display_mn_dne:
		bsr	VECTOR_DONE			*���荞�݉���
		bsr	DISP_DONE			*��ʂ�߂�

		move.w	#$FF,-(sp)			*�L�[�o�b�t�@�N���A
		move.w	#$06,-(sp)
		DOS	_KFLUSH
		addq.l	#4,sp

		clr.b	MMDSPON_FLAG(a6)
		move.l	SPSAVE_MAIN(a6),sp
		movem.l	(sp)+,d0-d1/a1
		rts


*==================================================
*	���u�c�h�r�o�Q�l�`�h�m
*�@�\�F�����������荞�݃��C��
*==================================================

VDISP_MAIN:
		movem.l	d0-d7/a0-a6,-(sp)
		lea	BUFFER(pc),a6
		tst.w	VDISP_CNT(a6)
		bne	vdisp_main90
		move.w	#1,VDISP_CNT(a6)

		move.w	15*4(sp),d7			*���荞�݃��x��������
		ori.w	#$2000,d7
		move.w	d7,sr

		movea.l	#CRTC_ACM,a0			*�e�L�X�g�}�X�N���n�e�e
		move.b	(a0),-(sp)
		clr.b	(a0)

vdisp_main10:
		bsr	MOUSE_MOVE
		bsr	LEVELM_GENS			*���x�����[�^����
		bsr	SPEANA_GENS			*�X�y�A�i����
*		bsr	PALET_ANIM			*�p���b�g�A�j��

		movea.l	#CRTC_ACM,a0			*�e�L�X�g�}�X�N��߂�
		move.b	(sp)+,(a0)

		clr.w	VDISP_CNT(a6)

vdisp_main90
		movem.l	(sp)+,d0-d7/a0-a6
		rte

		.end
