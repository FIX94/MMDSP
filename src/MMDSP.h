*************************************************************************
*									*
*									*
*	    �w�U�W�O�O�O�@�l�w�c�q�u�^�l�`�c�q�u�f�B�X�v���C		*
*									*
*				�l�l�c�r�o				*
*									*
*									*
*	Copyright (C)1991-94 Kyo Mikami / Masao Takahashi		*
*						 All Rights Reserved.	*
*									*
*									*
*************************************************************************


*==================================================
*�o�[�W����
*==================================================

VERSION		macro
		.dc.b	'0.30��'
		endm

STAYID		equ	$31415926	*�풓���ʂh�c


*==================================================
*�萔
*==================================================

TXTADR		.equ	$E00000		*�e�L�X�g�A�h���X�O
TXTADR1		.equ	$E20000		*�e�L�X�g�A�h���X�P
TXTADR2		.equ	$E40000		*�e�L�X�g�A�h���X�Q
TXTADR3		.equ	$E60000		*�e�L�X�g�A�h���X�R

BGADR		.equ	$EBC000		*�a�f�A�h���X�P
BGADR2		.equ	$EBE000		*�a�f�A�h���X�Q

SPRITEREG	.equ	$EB0000		*�X�v���C�g���W�X�^�A�h���X
SPPALADR	.equ	$E82200		*�X�v���C�g�p���b�g�A�h���X
PCGADR		.equ	$EB8000		*�o�b�f�A�h���X

CRTC_GSCRL	.equ	$E80018		*�O���t�B�b�N�X�N���[�����W�X�^

CRTC_MODE	.equ	$E80028		*CRTC���[�h
CRTC_ACM	.equ	$E8002A		*CRTC�e�L�X�g�A�N�Z�X���[�h

VIDEO_MODE	.equ	$E82400		*VCON���������[�h
VIDEO_PRIO	.equ	$E82500		*VCON�v���C�I���e�B
VIDEO_EFFECT	.equ	$E82600		*VCON�������

GPALADR		.equ	$E82000		*�O���t�B�b�N�p���b�g�A�h���X

MFP		.equ	$E88000		*�l�e�o


*==================================================
*���ʃ}�N��
*==================================================

MYONTIME	.macro
		move.w	ONTIME(a6),d0
		.endm


*==================================================
*�O���[�o�����x��
*==================================================

*MMDSP.S
		.global		START
		.global		MM_HEADER
		.global		MM_STAYFLAG
		.global		BUFFER
*INIT.S
		.global		SYSTEM_INIT
		.global		CLEAR_WORK
		.global		CHECK_OPTION
		.global		SYSTEM_CHCK
		.global		PRINT_ERROR
		.global		DRIVER_INIT
		.global		VECTOR_INIT
		.global		VECTOR_DONE
		.global		RESID_CHECK
		.global		KILL_BREAK
		.global		RESUME_BREAK
		.global		DISP_INIT
		.global		DISP_DONE
		.global		DISPLAY_MAKE
		.global		TABLE_MAKE
		.global		SAVE_CURPATH
		.global		MOVE_CURPATH
		.global		RESUME_CURPATH
		.global		SAVE_DISPLAY
		.global		RESUME_DISPLAY
		.global		HSCOPY
		.global		HSCLR
*SPRITE.S
		.global		SPRITE_INIT
*BG.S
		.global		BG_PRINT	*D0:ADD A0:W_ADR A1:R_ADR
		.global		BG_LINE
						*D0:PRT A0:W_ADR
		.global		PRINT16_2KETA	*16�i:	00
		.global		PRINT16_4KETA	*	00_00
		.global		PRINT16_6KETA	*	00_00_00
		.global		PRINT16_2KT_T	*	0_0
		.global		PRINT10_2KETA	*10�i:	00
		.global		PRINT10_3KETA	*	00_0
		.global		PRINT10_5KETA	*	00_00_0
		.global		PRINT10_5KT_F	*	_:00_00_0
		.global		PRINT10_3KT_2	*	0_00
		.global		DIGIT10		*�f�W�^���P�O�i��
		.global		DIGIT10S	*�f�W�^���P�O�i���[���T�v���X
		.global		DIGIT16		*�f�W�^���P�U�i��
		.global		PUT_DIGIT	*�f�W�^�������\��
*FONT.S
		.global		CHR_00
		.global		CH6_00
*TEXT.S
		.global		TEXT_ACCESS_ON	*D0:A_PL
		.global		TEXT_ACCESS_OF	*D0:A_PL
		.global		CLEAR_TEXT
		.global		TEXT48AUTO	*A0:D_AD
		.global		TEXT_4_8	*D0:A_PL D1:Dset A0:R_AD A1:W_AD
		.global		TEXT_6_16	*D0:A_PL D1:Dset A0:R_AD A1:W_AD
		.global		text_mask_set
		.global		TXLINE_CLEAR	*D0:Count A0:W_AD
		.global		DARK_PATTERN	*D1:SIZE A1:W_AD
		.global		LIGHT_PATTERN	*D1:SIZE A1:W_AD
		.global		PUT_PATTERN_OR	*D1:SIZE A0:R_AD A1:W_AD
		.global		PUT_PATTERN	*D0:A_PL D1:SIZE A0:R_AD A1:W_AD
*MOUSE.S
		.global		MOUSE_INIT
		.global		MOUSE_MOVE
		.global		MOUSE_ERASE
*PANEL.S
		.global		PANEL_MAKE
		.global		PANEL_EVENT
		.global		PANEL_DRUG
*CONTROL.S
		.global		CONTROL
		.global		ENTER_CMD
		.global		CLEAR_CMD
		.global		BIND_DEFAULT
		.global		set_myontime
*MAIN.S
		.global		DISPLAY_MAIN
		.global		VDISP_MAIN
*_SYSDISP.S
		.global		SYSDIS_MAKE
		.global		SYSTEM_DISP
		.global		CLEAR_PASSTM
		.global		SET_GMODE
		.global		BG_SEL
		.global		GTONE_UP
		.global		GTONE_DOWN
		.global		GTONE_SET
		.global		GHOME
		.global		GMOVE_U
		.global		GMOVE_D
		.global		GMOVE_L
		.global		GMOVE_R
*		.global		PALET_ANIM			*(:_;)
*_KEYBORD.S
		.global		KEYBORD_MAKE
		.global		KEYBD_UP
		.global		KEYBD_DOWN
		.global		KEYBD_SET
		.global		KEYBORD_DISP
*_REGISTER.S
*		.global		REGISTER_MAKE
*		.global		REGISTER_DISP
*_LEVEL.S
		.global		LEVELM_MAKE
		.global		LEVELSNS_UP
		.global		LEVELSNS_DOWN
		.global		LEVELSNS_SET
		.global		LEVELPOS_UP
		.global		LEVELPOS_DOWN
		.global		LEVELPOS_SET
		.global		LEVELM_DISP
		.global		LEVELM_GENS
*_SPEANA.S
		.global		SPEANA_MAKE
		.global		SPEASNS_UP
		.global		SPEASNS_DOWN
		.global		SPEASNS_SET
		.global		SPEASUM_CHG
		.global		SPEASUM_SET
		.global		SPEAREV_CHG
		.global		SPEAREV_SET
		.global		SPEAMODE_UP
		.global		SPEAMODE_DOWN
		.global		SPEAMODE_SET
		.global		SPEANA_DISP
		.global		SPEANA_GENS
*_SELECTOR.S
		.global		SELECTOR_INIT
		.global		SELECTOR_MAKE
		.global		SELECTOR_MAIN
		.global		GET_CURRENT
		.global		SET_CURRENT
		.global		UNLOCK_DRIVE
		.global		DRIVE_CHECK
		.global		AUTOMODE_CHG
		.global		AUTOMODE_SET
		.global		AUTOFLAG_CHG
		.global		AUTOFLAG_SET
		.global		LOOPTIME_UP
		.global		LOOPTIME_DOWN
		.global		LOOPTIME_SET
		.global		BLANKTIME_UP
		.global		BLANKTIME_DOWN
		.global		BLANKTIME_SET
		.global		INTROTIME_UP
		.global		INTROTIME_DOWN
		.global		INTROTIME_SET
		.global		PROGMODE_CHG
		.global		PROGMODE_SET
		.global		PROG_CLR

		.global		TITLE_CLR1
		.global		TITLE_PRT1

*FILES.S
		.global		INIT_FNAMEBUF
		.global		READ_FILEBUFF
		.global		FNAME_SET
		.global		SEARCH_TITLE
		.global		search_next_auto
		.global		search_next_shuffle
		.global		search_header
		.global		get_fnamebuf
		.global		write_datafile
		.global		change_ext_doc
*DOCVIEW.S
		.global		DOCVIEW_INIT
		.global		DOCV_NOW_PRT
		.global		DOCVIEW_UP
		.global		DOCVIEW_DOWN
		.global		DOCV_ROLLUP
		.global		DOCV_ROLLDOWN
		.global		DOCV_CLRALL
*DRIVER.S
		.global		SEARCH_DRIVER
		.global		STATUS_INIT
		.global		CLEAR_KEYON
		.global		TRMASK_CHG
		.global		TRMASK_ALLON
		.global		TRMASK_ALLOFF
		.global		TRMASK_ALLREV
		.global		OPEN_FILE
		.global		CLOSE_FILE
		.global		CHECK_DRIVE
		.global		GET_FILELEN
		.global		READ_FILE
		.global		ADD_EXT
		.global		STRCMPI
		.global		FREE_MEM
		.global		OPEN_ZDF
		.global		EXTRACT_ZDF
		.global		LOAD_LZZ
		.global		TDX_LOAD
		.global		PLAY_FILE
		.global		CALL_PLAYER
		.global		GET_PLAYERRMES
		.global		MMDSP_NAME
		.global		VOL_DEFALT

*==================================================
*�g���b�N���o�b�t�@
*==================================================

		.offset	0

STCHANGE	.ds.b	1	*�X�e�[�^�X�ω��t���O(bit0-3)
				*bit0:������� & TRACKNO
				*bit1:BEND
				*bit2:PAN
				*bit3:PROGRAM
KEYONCHANGE:	.ds.b	1	*�L�[�n�m��ԕω��t���O
VELCHANGE:	.ds.b	1	*�x���V�e�B�ω��t���O
KEYCHANGE:	.ds.b	1	*�L�[�R�[�h�ω��t���O

INSTRUMENT:	.ds.b	1	*0:�����̎��(0:none 1:FM 2:ADPCM 3:MIDI)
CHANNEL:	.ds.b	1	*�����̃`�����l���ԍ�(OPM1-8,ADPCM1-8,MIDI1-32)
KEYOFFSET:	.ds.w	1	*KEYCODE��MIDI�R�[�h�Ƃ̍�
BEND:		.ds.w	1	*1:�x���h
PAN:		.ds.w	1	*2:�p��
PROGRAM:	.ds.w	1	*3:�v���O����
KEYONSTAT:	.ds.b	1	*�L�[�n�m���(bit0-7 0:keyon 1:keyoff)
TRACKNO:	.ds.b	1	*�g���b�N�ԍ�
KEYCODE:	.ds.b	8	*�L�[�R�[�h
VELOCITY:	.ds.b	8	*�x���V�e�B
TRST:

		.text

*==================================================
*�g���b�N���i���̑��j
*==================================================

		.offset	0

KBS_CHG:	.ds.w	1	*�`�F�b�N�t���O�i�ω������p�����[�^�̃r�b�g�����j

KBS_MP:		.ds.b	1	*C:�l�o�@�̂n�m�^�n�e�e
KBS_MA:		.ds.b	1	*D:�l�`
KBS_MH:		.ds.b	1	*E:�l�g

KBS_k:		.ds.b	1	*0:��
KBS_q:		.ds.b	1	*1:��(bit7: @v�t���O)
			.ds.b	1

KBS_D:		.ds.w	1	*2345:�c�o�a�`�̌��݂̒l
KBS_P:		.ds.w	1
KBS_B:		.ds.w	1
KBS_A:		.ds.w	1

KBS_PROG:	.ds.w	1	*6:��

KBS_TL1:	.ds.b	1	*7:����
KBS_TL2:	.ds.b	1	*8:�ω���́���

KBS_DATA:	.ds.l	1	*9:�c�`�s�`

KBS_KC1:	.ds.w	1	*A:�j�b
KBS_KC2:	.ds.w	1	*B:�ω���

CHST:
		.text

*==================================================
*MMDSP���[�N�G���A
*==================================================

		.offset	0

DBF_ST:				*����������o�b�t�@�J�n�ʒu

*���ۑ��֌W --------------------
INIT_PATH:	.ds.b	256	*�N�����̃J�����g�f�B���N�g��
SUPER:		.ds.l	1	*�r�r�o
MM_MEMPTR:	.ds.l	1	*MMDSP�̃������Ǘ��|�C���^
CRTMD:		.ds.w	1	*�b�q�s���[�h
FUNCMD:		.ds.w	1	*�t�@���N�V�����L�[�s���[�h
LOCATESAVE:	.ds.l	1	*�J�[�\���ʒu
CONSOLSAVE:	.ds.l	2	*�R���\�[���͈�
CURSORSAVE:	.ds.b	1	*�J�[�\���\�����
CHILD_FLAG:	.ds.b	1	*�q�v���Z�X���s���t���O

CRTCMODE_SAVE:	.ds.w	1	*CRTC���[�h
CRTCACM_SAVE:	.ds.w	1	*CRTC�e�L�X�g�A�N�Z�X
VIDEOMODE_SAVE:	.ds.w	1	*VCON���[�h
VIDEOPRIO_SAVE:	.ds.w	1	*VCON�v���C�I���e�B
VIDEOEFF_SAVE:	.ds.w	1	*VCON�������
BGCTRL_SAVE:	.ds.w	1	*BG���[�h
IOCSXLEN_SAVE:	.ds.l	1	*IOCS�O���t�B�b�N���[�h
IOCSGMODE_SAVE:	.ds.w	1	*IOCS�O���t�B�b�N���[�h
IOCSWIN_SAVE1:	.ds.l	1	*IOCS�O���t�B�b�N���[�h
IOCSWIN_SAVE2:	.ds.l	1	*IOCS�O���t�B�b�N���[�h
APAGE_SAVE:	.ds.b	1	*IOCS APAGE
VPAGE_SAVE:	.ds.b	1	*IOCS VPAGE

TXTPALSAVE:	.ds.b	2*16
VECTMODE:	.ds.w	1	*�g�p���荞�ݎ��(1:TIMERA 2:RASTER 3:VDISP 4:TIMER_D)
ORIG_VECTOR:	.ds.l	1	*�ύX�O�̃x�N�^�A�h���X(VDISP)
BREAKCK_SAVE:	.ds.w	1	*
PDB_SAVE:	.ds.l	1	*
INDOSFLAG_SAVE:	.ds.w	1	*
INDOSNUM_SAVE:	.ds.b	1	*
		.even
INDOSSP_SAVE:	.ds.l	1

		.even
SPSAVE_RESI:	.ds.l	1	*
SPSAVE_MAIN:	.ds.l	1	*

*���ݒ�֌W --------------------
GTONE:		.ds.w	1	*�O���t�B�b�N�g�[��(0-31)
GTONE_TBL:	.ds.l	1	*�O���t�B�b�N�g�[���e�[�u���̃A�h���X(512*32bytes)
GSCROL_X:	.ds.w	1	*�O���t�B�b�N��ʃX�N���[���ʒu�w
GSCROL_Y:	.ds.w	1	*�O���t�B�b�N��ʃX�N���[���ʒu�x

SEL_NOUSE:	.ds.b	1	*�Z���N�^���g�p�t���O
FORCE_TVRAM:	.ds.b	1	*�e�L�X�g�����g�p�t���O
GRAPH_MODE:	.ds.b	1	*�O���t�B�b�N��ʍ������[�h(0-3)
RESIDENT:	.ds.b	1	*�풓���[�h�t���O
REMOVE:		.ds.b	1	*�풓���[�h�����t���O
		.even

*�R���g���[���֌W --------------------
VDISP_CNT:	.ds.w	1	*���荞�݉񐔃J�E���^
MMDSP_CMD:	.ds.w	1	*MMDSP�R�}���h�o�b�t�@
CMD_ARG:	.ds.l	1	*�R�}���h����
QUIT_FLAG:	.ds.w	1	*�l�l�c�r�o�I���t���O
DRUG_KEY:	.ds.w	1	*�h���b�O����Ă���L�[�R�[�h
DRUG_ONFUNC:	.ds.l	1	*�h���b�O���ɌĂ΂�郋�[�`��
DRUG_OFFFUNC:	.ds.l	1	*�h���b�O�������ɌĂ΂�郋�[�`��
CONTROL_ONTIME:	.ds.w	1	*���Ԍv���p
CONTROL_WORK:	.ds.w	1	*���Ԍv���p
HOTKEY1:	.ds.b	1	*�N���L�[1�̃R�[�h
HOTKEY1MASK:	.ds.b	1	*�N���L�[1�̃��[�N���r�b�g�}�X�N
HOTKEY1ADR:	.ds.w	1	*�N���L�[1�̃��[�N�A�h���X
HOTKEY2:	.ds.b	1	*�N���L�[2�̃R�[�h
HOTKEY2MASK:	.ds.b	1	*�N���L�[2�̃��[�N���r�b�g�}�X�N
HOTKEY2ADR:	.ds.w	1	*�N���L�[2�̃��[�N�A�h���X
MMDSPON_FLAG:	.ds.b	1	*MMDSP���쒆�t���O
HOTKEY_FLAG:	.ds.b	1	*�N���L�[�������ꂽ�܂܂�
ONTIME_WORK1:	.ds.w	1
ONTIME_WORK2:	.ds.w	1
ONTIME:		.ds.w	1

		.even

*�h���C�o�֌W --------------------
DRV_MODE:	.ds.w	1	*�g�p����h���C�o(0:none 1:MX 2:MA 3:MLD 4:RCD 5:ZMUS )
DRV_ENTRY:	.ds.l	1	*�h���C�o�̃G���g���A�h���X
DRV_WORK:	.ds.b	256	*�h���C�o�Ŏg�p���郏�[�N�G���A
NOWKEY:		.ds.w	1	*�L�[���͗p
REF_TRSTWORK:	.ds.l	1	*REFRESH_TRST �p�̃��[�N
CLR_KEYONWORK:	.ds.l	1	*CLEAR_KEYON �p�̃��[�N
DRIVER_JMPTBL:	.ds.l	20	*�h���C�o�R�[���̃W�����v�e�[�u��

*�p�l���֌W --------------------
MOUSE_X:	.ds.w	1	*�}�E�Xx���W
MOUSE_Y:	.ds.w	1	*�}�E�Xy���W
MOUSE_L:	.ds.b	1	*���{�^�����(on:$FF off:$00)
MOUSE_R:	.ds.b	1	*�E�{�^�����(on:$FF off:$00)
MOUSE_LC:	.ds.b	1	*���{�^���N���b�N�t���O(click:$FF no change:$00)
MOUSE_RC:	.ds.b	1	*�E�{�^���N���b�N�t���O(click:$FF no change:$00)
DRUG_FUNC:	.ds.l	1	*�h���b�O�����֐��̃A�h���X
PANEL_ONTIME:	.ds.w	1	*PANEL.s�p
PANEL_WORK:	.ds.l	1	*�ėp���[�N�i���DRUG�֐����Ŏg�p�j

*�e�L�X�g��ʊ֌W --------------------
TX_ACM:		.ds.w	1	*�e�L�X�g�A�N�Z�X���[�h�ۑ��p
TX_BF_1:	.ds.b	32	*�O���t�H���g�����\���o�b�t�@
MASK_WORK:	.ds.w	1	*�e�L�X�g�}�X�N���[�N

BG16_TB:	.ds.w	256	*�P�U�i�\���p�e�[�u��
BG10_TB:	.ds.w	100	*�P�O�i
FROM96_TO32:	.ds.b	130	*�R���̂P���e�[�u��
TO6BIT_TBL:	.ds.b	256	*�W�|���U�r�b�g�ϊ��e�[�u��
TO4BIT_TBL:	.ds.b	256	*�W�|���S�r�b�g�ϊ��e�[�u��

*�V�X�e�����֌W --------------------
SYS_ONTIME:	.ds.w	1	*CPU���ב���p
CYCLECNT:	.ds.w	1	*CPU���ב���p
CYCLETIM:	.ds.w	1	*CPU���ב���p
CLKLAMP:	.ds.w	1	*���v':'�_�ŗp

TRACK_STATUS:	.ds.b	TRST*32	*�g���b�N���
TRACK_ENABLE:	.ds.l	1	*�g���b�N�L���t���O
TRACK_CHANGE:	.ds.l	1	*�g���b�N�L����ԕω��t���O
PLAY_FLAG:	.ds.w	1	*���t���t���O
PLAYEND_FLAG:	.ds.w	1	*���t�I���t���O
STAT_OK:	.ds.w	1	*�P�b���̃X�e�[�^�X�擾�t���O
CHST_BF:	.ds.b	CHST*32	*�`�����l���X�e�[�^�X�o�b�t�@

SYS_TITLE:	.ds.l	1	*�ȃ^�C�g���A�h���X
SYS_LOOP:	.ds.w	1	*���[�v�J�E���^
SYS_TEMPO:	.ds.w	1	*�e���|
SYS_DATE:	.ds.w	1	*����
SYS_TIME:	.ds.w	1	*����
SYS_PASSTM:	.ds.w	1	*�o�ߎ���
BLANK:		.ds.w	1	*�ȊԎ��Ԍv���p

LOOPCHK:	.ds.w	1
TEMPOCHK:	.ds.w	1
MDXCHCK:	.ds.b	80
MDXTITLE:	.ds.b	80
TITLELEN:	.ds.w	1

*���Պ֌W --------------------
KEYB_TROFST:	.ds.b	1	*�L�[�{�[�h�擪�g���b�N�ԍ�
KEYB_TRCHG:	.ds.b	1	*�L�[�{�[�h�擪�g���b�N�ԍ��ω��t���O
KEYB_TRBUF:	.ds.l	1	*�L�[�{�[�h�p�擪�g���b�N�o�b�t�@�A�h���X
KEYB_CHBUF:	.ds.l	1	*�L�[�{�[�h�p�擪�g���b�NCHST�o�b�t�@�A�h���X
STSAVE:		.ds.b	80	*�X�e�[�^�X�ۑ��p

*���x�����[�^�֌W --------------------
LEVEL_TROFST:	.ds.b	1	*���x�����[�^�p�擪�g���b�N�ԍ�
LEVEL_TRCHG:	.ds.b	1	*���x�����[�^�p�擪�g���b�N�ԍ��ω��t���O
LEVEL_TRBUF:	.ds.l	1	*���x�����[�^�p�擪�g���b�N�o�b�t�@�A�h���X
VELO_BF:	.ds.l	32	*�x���V�e�B�[�o�b�t�@
LEVEL_SPEED:	.ds.b	1	*���x�����[�^�������x
LEVEL_RANGE:	.ds.b	1	*���x�����[�^���x�����W
		.even

*�X�y�A�i�֌W --------------------
SPEA_MODE:	.ds.w	1	*�X�y�A�i���[�h
SPEA_INTJOB:	.ds.l	1	*�X�y�A�i�����������[�`���̃A�h���X
SPEA_RISETBL:	.ds.l	1	*�㏸���x�e�[�u���̃A�h���X
		.ds.w	10	*�X�y�A�i�͂ݏo���z�����p�i�΁j
SPEA_BF1:	.ds.w	32+10	*�X�y�A�i�o�b�t�@�P
		.ds.w	10	*���z�����
SPEA_BF2:	.ds.b	32*6	*�X�y�A�i�o�b�t�@�Q
SPEA_SPEED:	.ds.b	1	*�X�y�A�i�������x
SPEA_RANGE:	.ds.b	1	*�X�y�A�i���x�����W
SPEA_SUM:	.ds.b	1	*�X�y�A�i�ϕ����[�h
SPEA_REV:	.ds.b	1	*�X�y�A�i���o�[�X���[�h
		.even

*�Z���N�^�֌W --------------------
SEL_CMD:	.ds.w	1	*�Z���N�^�R�}���h
SEL_ARG:	.ds.w	1	*����

SEL_STAT:	.ds.w	1	*�X�e�[�^�X�t���O
SEL_VIEWMODE:	.ds.b	1	*�r���[�����[�h�t���O
		.ds.b	1

SEL_HEAD:	.ds.l	1	*�f�B���N�g���w�b�_�A�h���X
SEL_BTOP:	.ds.w	1	*�o�b�t�@�擪�ʒu
SEL_BPRT:	.ds.w	1	*�\���擪�ʒu
SEL_BSCH:	.ds.w	1	*�^�C�g�������J�n�ʒu
SEL_CUR:	.ds.w	1	*��ʃJ�[�\���ʒu
SEL_FCP:	.ds.w	1	*�J�[�\��SEL_FNAME�ʒu
SEL_FMAX:	.ds.w	1	*�f�B���N�g�����̃t�@�C���̑S��
SEL_BMAX:	.ds.w	1	*�o�b�t�@�̍ŏI�ʒu+1

SEL_CHANGE:	.ds.w	1	*��ԕύX�t���O
SEL_SRC_F:	.ds.w	1	*����������^�Ȃ��t���O
SEL_TIME:	.ds.w	1	*�L�[���̓^�C���J�E���^
SEL_FILENUM:	.ds.w	1	*�Z���N�^�S�t�@�C����
SEL_TITLE:	.ds.l	1	*�^�C�g���o�b�t�@�A�h���X
SEL_TITLEBANK:	.ds.w	1	*�^�C�g���o�b�t�@�ԍ�(0-2)
G_MES_TIME:	.ds.w	1	*���b�Z�[�W�^�C���J�E���^
G_MES_FLAG:	.ds.w	1	*���b�Z�[�W�\�����t���O

RND_WORK:	.ds.w	1	*���O�̗����l
LOOP_TIME:	.ds.w	1	*���̋ȂɈڂ郋�[�v��
BLANK_TIME:	.ds.w	1	*�ȊԂ̑҂�����
INTRO_TIME:	.ds.w	1	*�C���g���X�L�����̎���
SEL_PLAYCHK:	.ds.b	1	*���݈ʒu�̋Ȃ����t���ꂢ�Ȃ��t���O
SEL_MMOVE:	.ds.b	1	*�O�񉉑t���ȍ~�A�蓮�ŃJ�[�\���ړ������t���O
AUTOMODE:	.ds.b	1	*0:NORMAL 1:AUTO 2:SHUFFLE
AUTOFLAG:	.ds.b	1	*bit0:REPEAT bit1:INTRO bit2:ALLDIR bit3:PROG
SHUFFLE_CODE:	.ds.b	1	*�V���t���̉��t���ʃt���O�p���l
PROG_MODE:	.ds.b	1	*�v���O�������[�h
		.even

CONSOLE:	.ds.l	2
SEL_FILES:	.ds.b	54
FNAM_BUFF:	.ds.b	256
CURRENT:	.ds.b	256	*�J�����g�f�B���N�g���̐�΃p�X��
DRV_TBL:	.ds.b	26	*�h���C�u��ԃe�[�u��
DRV_TBLFLAG:	.ds.b	2	*�h���C�u�e�[�u���쐬�t���O
LOCKDRIVE:	.ds.b	1	*�C�W�F�N�g�֎~�����h���C�u(0:none 1:A 2:B ...)
		.even

*�h�L�������g�r�����[�֌W --------------------
DOCV_MEMPTR:	.ds.l	1	*�m�ۂ�����������PSP+$10�A�h���X
DOCV_MEMEND:	.ds.l	1	*�m�ۂ����������̍ŏI�A�h���X+1
DOCV_NOW:	.ds.l	1	*���݂̃o�b�t�@�\���ʒu
DOCV_NEXT:	.ds.l	1	*�o�b�t�@�\���ʒu�̉�
DOCV_SIGEND:	.ds.l	1	*�\���\�ŏI�o�b�t�@�ʒu
DOCV_TXTADR:	.ds.l	1	*�\���J�n����e�L�X�g�A�h���X
DOCV_TXTAD2:	.ds.l	1	*�\���͈͈�ԉ��̃e�L�X�g�A�h���X
DOCV_YOKO:	.ds.w	1	*��������
DOCV_TATE:	.ds.w	1	*�c������

DOCV_FONT:	.ds.l	1	*�t�H���g�ʃe�[�u���A�h���X
DOCV_RAS1:	.ds.b	1	*�X�N���[���p���X�^�i���o�[
DOCV_RAS2:	.ds.b	1	*�X�N���[���p���X�^�i���o�[

* --------------------
DBF_ED:				*����������o�b�t�@�I���ʒu
		.even
*		.ds.b	2	*�X�^�b�N��long���E�ɍ��킹�邽�߂̃_�~�[

FILE_BUFF:	.ds.b	1024	*�t�@�C���ꕔ�ǂݍ��ݗp�o�b�t�@
MYSTACK2:			*�A�{�[�g���̃X�^�b�N
KEY_TABLE:	.ds.b	128*18	*�L�[�o�C���h�e�[�u��
GTONE_BUF:	.ds.b	512*32	*�O���t�B�b�N�p���b�g�e�[�u��
		.ds.l	2048	*�X�^�b�N�G���A(8Kbytes)
MYSTACK:

BUF_SIZE:
		.text

