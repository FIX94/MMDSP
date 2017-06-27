*************************************************************************
*									*
*									*
*	    �w�U�W�O�O�O�@�l�w�c�q�u�^�l�`�c�q�u�f�B�X�v���C		*
*									*
*				�l�l�c�r�o				*
*									*
*									*
*	Copyright (C) 1992 Masao Takahashi				*
*									*
*									*
*************************************************************************

		.include LzzConst.mac

*�h���C�o���

MXDRV		equ	1
MADRV		equ	2
MLD		equ	3
RCD		equ	4
RCD3		equ	5
ZMUSIC		equ	6
MCDRV		equ	7

*�h���C�o�ԍ��ύX���ɂ� DRIVER.s �� �O���Q�Ƃ���� driver_table �����������邱��
*�܂� _SYSDISP.s �̃��S�����������邱��

*�g���q���

_none		equ	0
_MDX		equ	1
_MDR		equ	2
_RCP		equ	3
_R36		equ	4
_MDF		equ	5
_MCP		equ	6
_MDI		equ	7
_SNG		equ	8
_MID		equ	9
_STD		equ	10
_MFF		equ	11
_SMF		equ	12
_SEQ		equ	13
_MDZ		equ	14
_MDN		equ	15
_KMD		equ	16
_ZMS		equ	17
_ZMD		equ	18
_OPM		equ	19
_ZDF		equ	20
_MM2		equ	21
_MMC		equ	22
_MDC		equ	23
_PIC		equ	24
_MAG		equ	25
_PI		equ	26
_JPG		equ	27
_EXTMAX		equ	28

*���ʔԍ��ύX���ɂ�FILES.s��title_jmp�e�[�u�������������邱��
*

*�h���C�o�R�[���}�N��
*	a0.l �j��

DRIVER		macro	call
		movea.l	DRIVER_JMPTBL+call*4(a6),a0
		jsr	(a0)
		endm

*�h���C�o�R�[����

		.offset	0
DRIVER_CHECK:	.ds.b	1		* �풓�`�F�b�N d0.l->�풓�t���O
DRIVER_NAME:	.ds.b	1		* �h���C�o���擾 d0.l->�h���C�o��
DRIVER_SETUP:	.ds.b	1		* �h���C�o������
DRIVER_SYSSTAT:	.ds.b	1		* �h���C�o��Ԏ擾
DRIVER_TRKSTAT:	.ds.b	1		* �g���b�N���擾
DRIVER_GETMASK:	.ds.b	1		* ���t�g���b�N�擾
DRIVER_SETMASK:	.ds.b	1		* ���t�g���b�N�ݒ�
DRIVER_FILEEXT:	.ds.b	1		* �g���q�e�[�u���擾 d0.l->�e�[�u��
DRIVER_FLOADP:	.ds.b	1		* �f�[�^���[�h�����t a1.l<-�t�@�C���� d0.b<-��� d0.l->�G���[�R�[�h
DRIVER_PLAY:	.ds.b	1		* �ĉ��t
DRIVER_PAUSE:	.ds.b	1		* ���t���f
DRIVER_CONT:	.ds.b	1		* ���t�ĊJ
DRIVER_STOP:	.ds.b	1		* ���t��~
DRIVER_FADEOUT:	.ds.b	1		* �t�F�[�h�A�E�g
DRIVER_SKIP:	.ds.b	1		* ������ d0.w<-�J�n�t���O
DRIVER_SLOW:	.ds.b	1		* �X���[ d0.w<-�J�n�t���O
DRIVER_CMDS:
		.text

*DRIVER_CHECK�ȊO�́A�K���풓�m�F��ɌĂяo������
*�e�R�[����d0/a0��j�󂵂Ă��ǂ�
*�R�[���𑝂₵���ꍇ�́Ammdsp.h�� DRIVER_JMPTBL �̐������킹�邱��

