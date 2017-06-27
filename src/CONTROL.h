*************************************************************************
*									*
*									*
*	    �w�U�W�O�O�O�@�l�w�c�q�u�^�l�`�c�q�u�f�B�X�v���C		*
*									*
*				�l�l�c�r�o				*
*									*
*									*
*	Copyright (C) 1994 Masao Takahashi				*
*									*
*									*
*************************************************************************


*==================================================
*MMDSP���߃R�[�h
*==================================================

ENTER		macro	cmd
		moveq	#cmd,d0
		bsr	ENTER_CMD
		endm

FUNC		macro	label
label:		ds.b	1
		endm

		.offset	0
		FUNC	CMD_NOP
		FUNC	CMD_NEXT_DRIVE		*�Z���N�^�֌W
		FUNC	CMD_PREV_DRIVE
		FUNC	CMD_EJECT
		FUNC	CMD_DATAWRITE
		FUNC	CMD_DOCREAD
		FUNC	CMD_DOCREADN
		FUNC	CMD_GO_PARENT
		FUNC	CMD_GO_ROOT
		FUNC	CMD_NEXT_PAGE
		FUNC	CMD_PREV_PAGE
		FUNC	CMD_ROLL_UP
		FUNC	CMD_ROLL_DOWN
		FUNC	CMD_NEXT_LINE
		FUNC	CMD_PREV_LINE
		FUNC	CMD_NEXT_LINE_K
		FUNC	CMD_PREV_LINE_K
		FUNC	CMD_SELECT
		FUNC	CMD_SELECTN
		FUNC	CMD_PLAYDOWN
		FUNC	CMD_PLAYUP
		FUNC	CMD_CLEAR_SEL
		FUNC	CMD_TOP_LINE
		FUNC	CMD_BOTOM_LINE
		FUNC	CMD_AUTOMODE_CHG
		FUNC	CMD_AUTOMODE_SET
		FUNC	CMD_AUTOFLAG_CHG
		FUNC	CMD_AUTOFLAG_SET
		FUNC	CMD_LOOPTIME_UP
		FUNC	CMD_LOOPTIME_DOWN
		FUNC	CMD_LOOPTIME_SET
		FUNC	CMD_BLANKTIME_UP
		FUNC	CMD_BLANKTIME_DOWN
		FUNC	CMD_BLANKTIME_SET
		FUNC	CMD_INTROTIME_UP
		FUNC	CMD_INTROTIME_DOWN
		FUNC	CMD_INTROTIME_SET
		FUNC	CMD_PROGMODE_CHG
		FUNC	CMD_PROGMODE_SET
		FUNC	CMD_PROG_CLR
		FUNC	CMD_PLAY		*�R���\�[���p�l��
		FUNC	CMD_PAUSE
*		FUNC	CMD_CONT
		FUNC	CMD_STOP
		FUNC	CMD_FADE
		FUNC	CMD_SKIP
		FUNC	CMD_SLOW
		FUNC	CMD_SKIPK
		FUNC	CMD_SLOWK
		FUNC	CMD_QUIT
		FUNC	CMD_GMODE		*�O���t�B�b�N�p�l��
		FUNC	CMD_GTONE_UP		*�O���t�B�b�N�g�[���p�l��
		FUNC	CMD_GTONE_DOWN
		FUNC	CMD_GTONE_SET
		FUNC	CMD_GHOME
		FUNC	CMD_GMOVE_U
		FUNC	CMD_GMOVE_D
		FUNC	CMD_GMOVE_L
		FUNC	CMD_GMOVE_R
		FUNC	CMD_SPEASNS_UP		*�X�y�A�i�X�s�[�h
		FUNC	CMD_SPEASNS_DOWN
		FUNC	CMD_SPEASNS_SET
		FUNC	CMD_SPEAMODE_UP		*�X�y�A�i���[�h
		FUNC	CMD_SPEAMODE_DOWN
		FUNC	CMD_SPEAMODE_SET
		FUNC	CMD_SPEASUM_CHG		*�X�y�A�i�ϕ�
		FUNC	CMD_SPEASUM_SET
		FUNC	CMD_SPEAREV_CHG		*�X�y�A�i���o�[�X
		FUNC	CMD_SPEAREV_SET
		FUNC	CMD_LEVELSNS_UP		*���x�����[�^�X�s�[�h
		FUNC	CMD_LEVELSNS_DOWN
		FUNC	CMD_LEVELSNS_SET
		FUNC	CMD_TRMASK_CHG		*�g���b�N�}�X�N�p�l��
		FUNC	CMD_TRMASK_ALLON
		FUNC	CMD_TRMASK_ALLOFF
		FUNC	CMD_TRMASK_ALLREV
		FUNC	CMD_KEYBD_UP		*�L�[�{�[�h�p�l��
		FUNC	CMD_KEYBD_DOWN
		FUNC	CMD_KEYBD_SET
		FUNC	CMD_LEVELPOS_UP		*���x�����[�^�p�l��
		FUNC	CMD_LEVELPOS_DOWN
		FUNC	CMD_LEVELPOS_SET
		FUNC	CMD_BG_SEL		*�a�f�p�l��
		FUNC	CMD_MAX
		.text

