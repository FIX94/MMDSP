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

MAXFILE		equ	(512-16)*4			*�_���ő�32767�܂�

SEL_FNAME	equ	$E10000+$80*16			*�t�@�C���l�[���o�b�t�@�A�h���X
SEL_BUFFER1	equ	$E30000+$80*16			*�^�C�g���o�b�t�@�A�h���X1
SEL_BUFFER2	equ	$E50000+$80*12			*�^�C�g���o�b�t�@�A�h���X2
SEL_BUFFER3	equ	$E70000+$80*12			*�^�C�g���o�b�t�@�A�h���X3


		.offset	0
HEAD_MARK:	.ds.b	1		*�f�B���N�g���w�b�_�̍\��(32bytes)
KENS_FLAG:	.ds.b	1
FILE_NUM:	.ds.w	1
PATH_ADR:	.ds.l	1		*������0�Ȃ�_�~�[�̃w�b�_
NEXT_DIR:	.ds.l	1
PAST_POS:	.ds.w	1
TOP_POS:	.ds.w	1
		.text

		.offset	0
DATA_KIND:	.ds.b	1			*�t�@�C���l�[���o�b�t�@�̍\��(32bytes)
SHUFFLE_FLAG:	.ds.b	1
PROG_FLAG:	.ds.b	1
DOC_FLAG:	.ds.b	1
TITLE_ADR:	.ds.l	1
FILE_NAME:	.ds.b	24
		.text

MMDATVER	equ	'0.01'			*�^�C�g���f�[�^�t�@�C���t�H�[�}�b�g

