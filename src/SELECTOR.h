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

*�Z���N�^�R�}���h SEL_CMD �ꗗ
*����	SEL_ARG

		.offset	0
SEL_NONE	.ds.b	1
SEL_ROLLDOWN	.ds.b	1	*�P�s���[���_�E��
SEL_ROLLUP	.ds.b	1	*�P�s���[���A�b�v
SEL_UP		.ds.b	1	*�P���
SEL_DOWN	.ds.b	1	*�P����
SEL_SELN	.ds.b	1	*�w��ʒu�̃t�@�C�������s
SEL_SEL		.ds.b	1	*�J�[�\���ʒu�̃t�@�C�������s
SEL_NEXTDRV	.ds.b	1	*�h���C�u���ړ�
SEL_PREVDRV	.ds.b	1	*�h���C�u�E�ړ�
SEL_PARENT	.ds.b	1	*�e�f�B���N�g���Ɉړ�
SEL_ROOT	.ds.b	1	*���[�g�f�B���N�g���Ɉړ�
SEL_NEXTPAGE	.ds.b	1	*���̃y�[�W��
SEL_PREVPAGE	.ds.b	1	*�O�̃y�[�W��
SEL_CLEAR	.ds.b	1	*�o�b�t�@�N���A
SEL_TOP		.ds.b	1	*�擪�s��
SEL_BOTOM	.ds.b	1	*�ŏI�s��
SEL_PLAYDOWN:	.ds.b	1	*���t���Ă��玟�̍s�Ɉړ�
SEL_PLAYUP	.ds.b	1	*�O�̍s�ֈړ����ĉ��t
SEL_EJECT	.ds.b	1	*�C�W�F�N�g
SEL_DATAWRITE	.ds.b	1	*�f�[�^�t�@�C�������o��
SEL_DOCREAD	.ds.b	1	*�h�L�������g���[�h
SEL_DOCREADN	.ds.b	1	*�h�L�������g���[�h(�s�w��)
SEL_CMDNUM	.ds.b	1	*�R�}���h��
		.text



