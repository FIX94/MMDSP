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
		.include	MMDSP.h
		.include	DRIVER.h


*==================================================
* MCDRV �G���g���[�e�[�u��
*==================================================

		.xdef	MCDRV_ENTRY

FUNC		.macro	entry
		.dc.w	entry-MCDRV_ENTRY
		.endm

MCDRV_ENTRY:
		FUNC	MCDRV_CHECK
		FUNC	MCDRV_NAME
		FUNC	MCDRV_INIT
		FUNC	MCDRV_SYSSTAT
		FUNC	MCDRV_TRKSTAT
		FUNC	MCDRV_GETMASK
		FUNC	MCDRV_SETMASK
		FUNC	MCDRV_FILEEXT
		FUNC	MCDRV_FLOADP
		FUNC	MCDRV_PLAY
		FUNC	MCDRV_PAUSE
		FUNC	MCDRV_CONT
		FUNC	MCDRV_STOP
		FUNC	MCDRV_FADEOUT
		FUNC	MCDRV_SKIP
		FUNC	MCDRV_SLOW


*==================================================
* MCDRV ���[�J�����[�N�G���A
*==================================================

		.offset	DRV_WORK
MC_BUF		.ds.l	1
MC_KEYONBUF	.ds.l	1
MC_KEYONOFST	.ds.w	1
MC_STOPCOND .ds.b   1
		.text


*==================================================
* MCDRV �\���̒�`
*==================================================


MCDRV		macro	callname
		moveq.l	#callname,d0
		trap	#4
		endm

_RELEASE	equ	$00
_TRANSMDC	equ	$01
_PLAYMUSIC	equ	$02
_TRANSPCM	equ	$03
_PAUSEMUSIC	equ	$04
_STOPMUSIC	equ	$05
_GETWORKPTR	equ	$06
_GETTRACKSTAT	equ	$07	*�g�p�֎~
_GETVCTTBLADR	equ	$08
_GETKEYONPTR	equ	$09
_GETCURDATAPTR	equ	$0a
_GETPLAYFLG	equ	$0b
_SETTRANSPOSE	equ	$0c
_GETLOOPCOUNT	equ	$0d
_GETNOWCLOCK	equ	$0e
_GETTITLE	equ	$0f
_GETCOMMENT	equ	$10
_INTEXEC	equ	$11
_SETSUBEVENT	equ	$12
_UNREMOVE	equ	$13
_FADEOUT	equ	$14
_SETPARAM	equ	$15
_GETTEMPO	equ	$16
_GETPASSTIME	equ	$17
_SKIPPLAY	equ	$18



*============================================================
*		�g���b�N���[�N (256 byte)
*============================================================

*============================================================
*		�g���b�N���[�N (256 byte)
*============================================================

ACTIVE:		equ	$00	*.b �g���b�N�A�N�e�B�r�e�B	-1=kill 0=active
WAITSIGNAL:	equ	$01	*.b �g���b�N�ԒʐM		-1=wait 0=normal
MUTEMARK:	equ	$02	*.b 7:MUTE 6:LOCK 5:NORM 4:SE 3�`0:unuse
CURCH:		equ	$03	*.b ����ch.	0�`7:OPM 10�`1f:ADPCM 80�`:MIDI ff:dummy
NOWPITCH:	equ	$04	*.w ���݂̃s�b�`
	*	equ	$06	*.b 
NOWVOLUME:	equ	$07	*.b ���݂̃{�����[��
EVENT:		equ	$08	*.w �e��C�x���g
STEP:		equ	$0a	*.w �X�e�b�v�^�C���J�E���^�[
PARAMCHGJOBADR:	equ	$0c	*.l �p�����[�^�ύX�����A�h���X
PARAMCHG:	equ	$10	*.w �p�����[�^�ύX�v���t���O
WASPITCH:	equ	$12	*.w �ߋ��̃s�b�`
WASVOLUME:	equ	$14	*.w �ߋ��̃{�����[��
NEXTTRLINK:	equ	$16	*.w ����ւ̃g���b�N�����N
	*	equ	$18	*.l ���g�p�G���A
MMLPTR:		equ	$1c	*.l ���̖��߂̃A�h���X
BANKMSB:	equ	$20	*.b ���F�o���N���
MC_PROGRAM:	equ	$21	*.b ���F�ԍ�
VOLMST:		equ	$22	*.b �{�����[���ݒ�l
PANMST:		equ	$23	*.b 128�i�K�p���|�b�g
MC_BEND:	equ	$24	*.w �x���h�l
CREVERB:	equ	$26	*.b ���o�[�u�l
CCHORUS:	equ	$27	*.b �R�[���X�l
NOWBAR:		equ	$28	*.w ���݂̏��ߔԍ�
NOWSTEP:	equ	$2a	*.b ���݂̃X�e�b�v (�����ߎ��s������)
MVOLMST:	equ	$2b	*.b �}�X�^�[�{�����[���l
BANKLSB:	equ	$2c	*.b ���F�o���N����
BENDRANGE:	equ	$2d	*.b �x���h�����W
MODMST:		equ	$2e	*.b ���W�����[�V����
PHONS:		equ	$2f	*.b ������
WASPARAMCHG:	equ	$3c	*.l �p�����[�^�ύX�t���O(�O�������p)
		.offset	$40	* �ȉ��O������̎Q�Ɓ��g�p�֎~
PROGRAMBANK:	ds.l	1	* OPM ���F�f�[�^�ւ̃|�C���^
BFTRLINK:	ds.w	1	* �O���ւ̃g���b�N�����N
GTTRLINK:	ds.w	1	* �Q�[�g�J�E���^�g���b�N�����N�̐擪
CHTRLINK:	ds.w	1	* �`�����l�����̃g���b�N�����N
DETUNE:		ds.w	1	* �f�`���[��
PCMFREQPAN:	ds.w	1	* ADPCM �̍Đ����g���ƃp���|�b�g
TIEBUF:		ds.w	1	* �ߋ��̉�����̍�
WASKEYCODE:	ds.w	1	* ���K�̃L�[�R�[�h
DELAYEVENT:	ds.w	1	* �f�B���C�C�x���g�̃t���O (�r�b�g�}�b�v)
PROGADR:	ds.l	1	* OPM ���F�f�[�^�ւ̃A�h���X
ADPCMBANK:	ds.w	1	* ADPCM�e�[�u���̃o���N
TIEFLAG:	ds.b	1	* �^�C�t���O
TIEFLAG2:	ds.b	1	* �ߋ��̃^�C�t���O
UNIVFLG:	ds.b	1	* �e��t���O (7:TIE 6:TIE2 5:SYNC 1:DS 0:DC)
CONFB:		ds.b	1	* CONNECTION/FEEDBACK
SLOTMASK:	ds.b	1	* �X���b�g�}�X�N
WASQUANT:	ds.b	1	* �N�I���^�C�Y�w��l
QUANT:		ds.b	1	* �N�I���^�C�Y
PCMVOLUME:	ds.b	1	* PCM�{�����[��
SUBVOLUME:	ds.b	1	* �T�u�{�����[��

NOWVOLCMD:	ds.b	1	* �{�����[���ݒ���
VOLCENTER:	ds.b	1	* �{�����[���Z���^�[�l
NOWMVOLCMD:	ds.b	1	* �C���{�����[���ݒ���
MVOLCENTER:	ds.b	1	* ���C���{�����[���Z���^�[�l
NOWVELCMD:	ds.b	1	* �x���V�e�B�ݒ���
VELCENTER:	ds.b	1	* �x���V�e�B�Z���^�[�l
VELMST:		ds.b	1	* �x���V�e�B�ݒ�l
PANCENTER:	ds.b	1	* �p���|�b�g�Z���^�[�l
NOWPANCMD:	ds.b	1	* �p���|�b�g�ݒ���

OPMPAN:		ds.b	1	* OPM�p���|�b�g(0�`3)
TRKEYSHIFT:	ds.b	1	* �L�[�V�t�g�l
MHSYNC:		ds.b	1	* �n�[�h�k�e�n�̃V���N���L��
MHAMSPMS:	ds.b	1	* �n�[�h�k�e�n���x
CARRIER:	ds.b	1	* OPM �L�����A�̈ʒu (b7:op1 �` b4:op4)
VOLMAP1:	ds.b	1	* OPM �{�����[���̐ݒ�l�}�b�v
VOLMAP2:	ds.b	1
VOLMAP3:	ds.b	1
VOLMAP4:	ds.b	1
		.even
TRLVL:		ds.b	1	* �g���b�N���x��
TRPRI:		ds.b	1	* �g���b�N�v���C�I���e�B

		.offset	$80
MP_JOBADR:	ds.l	1	* ����LFO�̏����A�h���X		�g�`��������
MP_SPDC:	ds.w	1	*	�X�s�[�h�J�E���^
MP_DPTA:	ds.l	1	*	���Z����ψ�		�g�`�擪�A�h���X
MP_DPTD:	ds.l	1	*	���݃s�b�`
MP_DPTM:	ds.l	1	*	�����ψ�
MP_SPDF:	ds.w	1	*	�ŏ��Ƀ��[�h����X�s�[�h
MP_SPDS:	ds.w	1	*	�Q��ڈȍ~�Ƀ��[�h����X�s�[�h
MP_SPD:		ds.w	1	*	�X�s�[�h (1/4�g��)
MP_DPT:		ds.w	1	*	�U��
MA_JOBADR:	ds.l	1	* ����LFO�̏����A�h���X
MA_SPDC:	ds.w	1	*	�X�s�[�h�J�E���^
MA_DPTA:	ds.l	1	*	���Z����ψ�
MA_DPTD:	ds.l	1	*	���݃s�b�`
MA_DPTM:	ds.l	1	*	�����ψ�
MA_DPTI:	ds.l	1	*	�����s�b�`
MA_SPDS:	ds.w	1	*	���[�h����X�s�[�h
MA_SPD:		ds.w	1	*	�X�s�[�h (1/4�g��)
MA_DPT:		ds.w	1	*	�U��
MP_WAVE:	ds.b	1	*	�g�`�ԍ�
MA_WAVE:	ds.b	1	*	�g�`�ԍ�
		.even

MZ_WAVE:	ds.b	1	*	�g�`�ԍ�
MZ_CNTR:	ds.b	1	*	�R���g���[���l
MP_DLY:		ds.w	1	* �e��f�B���C�ݒ�l ****************************
MA_DLY:		ds.w	1
MZ_DLY:		ds.w	1
MH_DLY:		ds.w	1
PORTDLY:	ds.w	1
APANDLY:	ds.w	1

REPEATDEPTH:	ds.b	1	* 
REPEATSTAT:	ds.b	9	* ���[�v�l�X�g
REPEXITFLG:	ds.w	1	* ���[�v�I���}�[�N

PORTSTEP:	ds.w	1	* �|���^�����g�̃X�e�b�v�l
PORTDELTA:	ds.l	1	* �|���^�����g�̑�����
PORTDELTA2:	ds.l	1	* �|���^�����g�̌��݃s�b�`
STEP2:		ds.l	1	* �X�e�b�v�J�E���g�S��
STEP3:		ds.l	1	* �X�e�b�v�J�E���g�ώZ�J�E���^

SAMEMEASBUF:	ds.l	1	* �Z�[�����W���[�p�o�b�t�@
JUMPSTACK:	ds.l	4	* �W�����v���ޔ��o�b�t�@
JUMPSTACKPTR:	ds.b	1	* �W�����v���ޔ��o�b�t�@�p�|�C���^

		.even
TRACKKIND:	equ	$fe	*.b �g���b�N���
NUMOFTRACK:	equ	$ff	*.b �g���b�N�ԍ�
TRACKWORKSIZE:	equ	$100


*============================================================
*		�V�X�e�����[�N�\��
*============================================================

SYSTEMWORKSIZE:	equ	4096+512

		.offset	0-SYSTEMWORKSIZE
CHTRLINKBUF:	ds.w	256		* �`�����l���g���b�N�����N�o�b�t�@
SYSTEMWORK:	ds.w	1		* �A�N�e�B�u���X�g�_�~�[
GTTOP:		ds.w	1
		ds.w	1
		ds.w	1		* �g���b�N�����N�_�~�[
		ds.w	1
		ds.w	1		* �󃊃X�g�_�~�[
GTEMP:		ds.w	1
		ds.w	1
GTBUF:		ds.b	16*128		* �Q�[�g�^�C���Ǘ��o�b�t�@
OPMCHSTAT:	ds.b	1		* OPM �L�[�I���o�b�t�@
		ds.b	1
ADPCMCHSTAT:	ds.w	1		* ADPCM �L�[�I�����
		ds.w	5
MCKEYONPTR:	ds.w	1		* �L�[�I�����	(FIFO POINTER)
MCKEYONBUF:	ds.b	256*4		*		(FIFO BUFFER)
OPMCHKC:	ds.b	8		* OPM�̃`�����l�����̃L�[�R�[�h
OPMCHKF:	ds.b	8		* OPM�̃`�����l�����̃L�[�t���N�V����
OPMCHTRLK:	ds.w	8		* OPM�g�p�`�����l�������N
OPMCHVELO:	ds.b	8
PAUSEMARK:	ds.w	1		* �|�[�Y�}�[�N
DIVISION:	ds.w	1		* �S������������̃N���b�N��
TRUETEMPO:	ds.w	1		* �f�[�^���ڂ̃e���|
TEMPO:		ds.w	1		* ���y�I�e���|
WASTEMPO:	ds.w	1		* �ߋ��̃e���|
TEMPOSNS:	ds.w	1		* �e���|�̊��x
TRACKNUM:	ds.w	1		* �g���b�N��		(default 64 trk)
TRACKUSE:	ds.w	1		* �g�p�g���b�N��
*	OFFSET		+0	+4	+8	+12
*	TRACK(=BIT)	127�`96	95�`64	63�`32	31�`0
TRACKFLGSZ:	ds.w	1		* �g���b�N�t���O�T�C�Y	(���݂S�Œ�)
PLAYTRACKFLG:	ds.l	4		* ���t�g���b�N�t���O	(�O���Q�Ɨp)
TRACKMASK:	ds.l	4		* �g���b�N�}�X�N�t���O	(�O���Q�Ɨp)
TRACKACT:	ds.l	4		* �i�v���[�v���m�p	(Main���t�̂ݎg�p����)
FSTTR:		ds.w	1		* �ŏ��̃g���b�N
FSTTRSE:	ds.w	1		* SE���t�ŏ��̃g���b�N
GTTOPSE:	ds.l	1		* SE�p�Q�[�g�J�E���^
COMMENTADR:	ds.l	1		* �R�����g�̃A�h���X
RANDOMESEED:	ds.l	1		* ������
CURMDCADR:	ds.l	1		* MDC �̐擪�A�h���X
CURMDCSIZE:	ds.l	1		* 	    �T�C�Y
CURPCMADR:	ds.l	1		* PCM �̐擪�A�h���X
CURPCMSIZE:	ds.l	1		* 	    �T�C�Y
TRANSMDCBUF:	ds.l	1		* MDC �]�����[�`���p�̃o�b�t�@
TRANSPCMBUF:	ds.l	1		* PCM �]�����[�`���p�̃o�b�t�@
EXCSENDWAIT:	ds.w	1		* �G�N�X�N���[�V�u���M�E�F�C�g
EXCSENDPTR:	ds.l	1		* �f�[�^�|�C���^
PLAYMODE:	ds.l	1		* ���t�����ւ̃A�h���X
FPITCH:		ds.l	1
FDELTA:		ds.l	1
FLVL:		ds.w	1

FADEPITCH:	ds.w	1		* �t�F�[�h�s�b�`
FADELVL:	ds.w	1		* �t�F�[�h���x��
FADELVLS:	ds.w	1		* �t�F�[�h���x�����v
OPMFADELVL:	ds.w	1		* ���������p�̃t�F�[�h���x��
FADECOUNT:	ds.w	1
FADEMODE:	ds.w	1
FADESELECT:	ds.w	1		* MUSIC/SE �ǂ���Ƀt�F�[�h������K�p���邩
MASTERVOLMST:	ds.w	1		* �}�X�^�[�{�����[���ݒ�l
MASTERVOL:	ds.w	1		* �}�X�^�[�{�����[��
WASMASTERVOL:	ds.w	1		* �ߋ��̃}�X�^�[�{�����[��
SRCHMEAS:	ds.w	1		* �T�[�`���W���[
JUMPDELTA:	ds.l	1		* ���t�̃W�����v
JUMPDELTAX:	ds.w	1		* ���ۂ̃W�����v�X�e�b�v
LOOPCOUNTER:	ds.w	1		* ���[�v�J�E���^�[
LOOPCLOCK:	ds.l	1		* ���[�v���̃N���b�N
ENDCLOCK:	ds.l	1		* ���t�I���̃N���b�N
NOWCLOCK:	ds.l	1		* ���݂̌o�߃N���b�N
INTSPACE:	ds.l	1		* ���荞�݊Ԋu (�P�ʃ�s)
PASSTIMEC:	ds.l	1		* 1/10^6�b�J�E���^ (�����l1000000-1)
PASSTIME:	ds.l	1		* �o�ߎ���(hw:�� lw:�b)
BUFSIZE:	ds.l	1		* �o�b�t�@�T�C�Y	(default 320 kB)
BUFPTR:		ds.l	1		* �o�b�t�@�|�C���^
INTEXECNUM:	ds.w	1		* _INTEXEC �o�^��
INTEXECBUF:	ds.l	8		* _INTEXEC �p�̃o�b�t�@
SUBEVENTNUM:	ds.w	1		* ���̃T�u�C�x���g���o�^����Ă��邩
SUBEVENTADR:	ds.l	8		* _SETSUBEVENT �A�h���X�o�b�t�@
SUBEVENTID:	ds.l	8		* _SETSUBEVENT ID�o�b�t�@
WASRSVCT:	ds.l	8		* VECTOR $58�`$5F �̏����l (SCC)
WASMIDIBVCT:	ds.l	8		* VECTOR $80�`$8E �̏����l (MIDI BOARD #1)
WASMIDIBVCT2:	ds.l	8		* VECTOR $90�`$9E �̏����l (MIDI BOARD #2)
WASOPMVCT:	ds.l	1		* OPM���荞�݃x�N�^
WASTRAP4:	ds.l	1		* �ߋ���TRAP4�x�N�^
NOWTRAP4:	ds.l	1		* �풓�����`�F�b�N�p
WASTRAP2:	ds.l	1		* PCM8 �풓�֎~�p
UNREMOVEFLG:	ds.w	1		* �풓��������

TIMERAWORK:	ds.w	1		* TIMER-A �������[�h�p���[�N
TIMERAWAIT:	ds.w	1		* TIMER-A �������[�h�p�E�F�C�g
TIMERBWORK:	ds.w	1		* TIMER-A �������[�h�p���[�N
TIMERBWAIT:	ds.w	1		* TIMER-A �������[�h�p�E�F�C�g
ADPCMNAME:	ds.b	96		* ���݂�ADPCM�f�[�^��
MIDIFIFOB1:	ds.l	1
MIDIFIFOB2:	ds.l	1
RSMIDIBUF:	ds.l	1
MIDIFIFOPP:	ds.l	1
CURMIDIBUF:	ds.l	1
MIDICHPRI:	ds.l	1		* MIDI �f�o�C�X�v���C�I���e�B

		.offset	-256-64
WASDMA3DONE:	ds.l	1
NOWDMA3DONE:	ds.l	1
WASDMA3ERR:	ds.l	1
NOWDMA3ERR:	ds.l	1
WASDMA3NIV:	ds.b	1
WASDMA3EIV:	ds.b	1

NEXTADPDATA:	ds.w	1		* �_�~�[ (movem ���g���̂œ������Ȃ��悤��)
NEXTADPMODE:	ds.w	1		* ���`�c�o�b�l�\����
NEXTADPd1:	ds.l	1
NEXTADPd2:	ds.l	1
NEXTADPa1:	ds.l	1

CONTADPd2:	ds.l	1
CONTADPa1:	ds.l	1

ADPNEXTF:	ds.b	1		* ������w��t���O($00:�w��Ȃ� $01:�p������ $FF:�\�񂠂�)
ADPPLAYF:	ds.b	1		* ADPCM����t���O ($00:��~�� $0?:���쒆 $FF:$80*26data)
ADPPAUSEF:	ds.b	1		* ADPCM�|�[�Y�t���O
ADPCMBUSY:	ds.b	1		* ADPCM BUSY (�}���`�Q�C��ADPCM�p)

		.offset	-256		* �t���O�G���A
MASTERVOLUME_:	ds.b	1		* �}�X�^�[�{�����[��
MASTERTP:	ds.b	1		* �}�X�^�[�L�[�g�����X�|�[�Y
USERTP:		ds.b	1		* ���[�U�[�L�[�g�����X�|�[�Y
KEYTRANSPOSE:	ds.b	1		* �L�[�g�����X�|�[�Y
ONDATA:		ds.b	1		* �o�b�t�@���Ƀf�[�^�����邩 0=����
PCMON:		ds.b	1		* 
PCM8ON:		ds.b	1		* PCM8 ���풓���Ă��邩?
CANMIDIOUTD:	ds.b	1		* �o�͉\�� MIDI �f�o�C�X
					* b7:BOARD1 b6:BOARD2 b5:RSMIDI b4:POLYPHONE
MIDIBOARDON:	ds.b	1		* MIDI �{�[�h����������Ă��邩
POLYPHONON:	ds.b	1		* POLYPHONON �{�[�h����������Ă��邩
RSMIDI:		ds.b	1		* RSMIDI ���[�h��
MHWAVEFORM:	ds.b	1		*
MHLFREQ:	ds.b	1
MHPMD:		ds.b	1
MHAMD:		ds.b	1
NEWHLFOFLG:	ds.b	1
ANOTHERTIMMD:	ds.b	1		* ���^�C�}�[���[�h
OPMSTAT:	ds.b	1		* OPM���荞�ݔ�����
TEMPOGAP:	ds.w	1		* �e���|���ꌟ�o�p�t���O
NOWINTMASK:	ds.b	1		* ���荞�݂���O�̊��荞�݃��x��
KBCTRLSEL:	ds.b	1		* �L�[�{�[�h�R���g���[���֎~ = -1
KBXF:		ds.w	1		* XF4/XF5�̏��
KB80E:		ds.b	1		* SHIFT CTRL OPT1 OPT2 �̏��
PCMTYPE:	ds.b	1		* 0:PDX 1:ZPD 2:PDN
INJUMP:		ds.b	1		* �W�����v���t���O
RESTARTDATA:	ds.b	1		* 
SEPRI:		ds.b	1		* ���ʉ��̍ō����x��
		.offset	0
TRACKWORK:	ds.b	TRACKWORKSIZE*64	* �g���b�N�o�b�t�@
TRACKWORKASIZE:

WORKAREASIZE:	equ	SYSTEMWORKSIZE+TRACKWORKASIZE


		.text
		.even


*==================================================
* MCDRV �풓�`�F�b�N
*==================================================

MCDRV_CHECK:
		move.l	a0,-(sp)
		move.l	$24*4.w,a0
		cmp.l	#"-MCD",-12(a0)
		bne	not_keeped
		cmp.l	#"RV0-",-8(a0)
		bne	not_keeped
		move.l	-4(a0),d0
		cmpi.l	#$00130000,d0		* �o�[�W�����`�F�b�N
		bcc	keeped
not_keeped:
		moveq.l	#-1,d0
keeped:
		move.l	(sp)+,a0
		rts


*==================================================
* MCDRV �h���C�o���擾
*==================================================

MCDRV_NAME:
		move.l	a0,-(sp)
		lea	name_buf(pc),a0
		move.l	a0,d0
		move.l	(sp)+,a0
		rts

name_buf:	.dc.b	'MCDRV',0
		.even

*==================================================
* MCDRV �h���C�o������
*==================================================

MCDRV_INIT:
		movem.l	d0/a0-a1,-(sp)
		MCDRV	_GETKEYONPTR
		movea.l	d0,a0
		move.l	a0,MC_KEYONBUF(a6)
		move.w	(a0),d0
		move.w	d0,MC_KEYONOFST(a6)

		MCDRV	_GETWORKPTR
		move.l	d0,MC_BUF(a6)
		movea.l	d0,a0

		clr.b   MC_STOPCOND(a6)

		clr.l	TRACK_ENABLE(a6)
		move.w	#202,CYCLETIM(a6)
		move.w	#77,TITLELEN(a6)

		lea	TRACK_STATUS(a6),a0	*�g���b�N�ԍ�������
		moveq	#1,d0
mcdrv_init10:
		move.b	d0,TRACKNO(a0)
		lea	TRST(a0),a0
		addq.w	#1,d0
		cmpi.w	#32,d0
		bls	mcdrv_init10

		movem.l	(sp)+,d0/a0-a1
		rts


*==================================================
* MCDRV �V�X�e�����擾
*==================================================

MCDRV_SYSSTAT:
		movem.l	d0/a0,-(sp)

		MCDRV	_GETTITLE		*�^�C�g��
		move.l	d0,SYS_TITLE(a6)

		MCDRV	_GETLOOPCOUNT		*���[�v�J�E���^
		move.w	d0,SYS_LOOP(a6)

		MCDRV	_GETTEMPO
		move.w	d0,SYS_TEMPO(a6)	*�e���|

		movea.l	MC_BUF(a6),a0
		move.w -128(a0),d0
		tst.w d0 *see if we are stopped
		bne MCDRV_sysstat20
MCDRV_sysstat10:
		moveq #1, d1 *stopped
		bra MCDRV_sysstat30
MCDRV_sysstat20:
		moveq #0, d1 *not stopped
		andi.w #2, d0 *get playing or paused bit
		move.w d0, PLAY_FLAG(a6) *store bit
		bne MCDRV_sysstat30 *jump to end if playing
		tst.b MC_STOPCOND(a6) *paused, see if we are fading out
		beq MCDRV_sysstat30 *jump to end if not fading out
		bsr	MCDRV_STOP *paused after fadeout, now end it
		moveq #1, d1 *stopped
MCDRV_sysstat30:
		move.w d1, PLAYEND_FLAG(a6)

		movem.l	(sp)+,d0/a0
		rts

dummy_title:	.dc.b	0
		.even

*==================================================
* MCDRV �X�e�[�^�X�擾
*==================================================

MCDRV_TRKSTAT:
		bsr	MCDRV_TRACK
		bsr	MCDRV_KEYON
		rts

*==================================================
*MCDRV �g���b�N���擾
*==================================================

MCDRV_TRACK:
		movem.l	d0-d3/d5/d7/a0-a3,-(sp)
		movea.l	MC_BUF(a6),a0
		lea	TRACK_STATUS(a6),a1
		lea	VOL_DEFALT(pc),a2
		movea.l	MC_BUF(a6),a3

		MCDRV	_GETPLAYFLG
		move.l	d0,d2

		moveq	#0,d1
		moveq	#32-1,d7
MCDRV_track10:
		bsr	get_track
		lea	$100(a0),a0
		lea	TRST(a1),a1
		addq.w	#1,d1
		dbra	d7,MCDRV_track10

		move.l	TRACK_ENABLE(a6),d0
		move.l	d2,TRACK_ENABLE(a6)
		eor.l	d2,d0
		move.l	d0,TRACK_CHANGE(a6)

		movem.l	(sp)+,d0-d3/d5/d7/a0-a3
		rts

*	a0.l <- MCDRV TRACK buffer address
*	a1.l <- TRACK_STATUS address
*	a2.l <- VOL_DEFALT address
*	a3.l <- MCDRV buffer address
*	d1.l <- TRACK_NUM
*	d2.l <- TRACK_ENABLE
*	d3.l -- break

get_track:
		moveq	#0,d5
		clr.l	STCHANGE(a1)

*		tst.b	ACTIVE(a0)
*		beq	get_track10
*		bclr	d1,d2

get_track10:
		move.b	CURCH(a0),d3			*INSTRUMENT
		tst.b	d3
		bpl	get_track11
		moveq	#0,d0			*none
		cmpi.b	#$8f,d3
		bhi	get_track13
		moveq	#3,d0			*MIDI
		bra	get_track13
get_track11:
		moveq	#1,d0
		cmpi.b	#15,d3			*FM
		bls	get_track13
		moveq	#2,d0			*ADPCM
		cmpi.b	#31,d3
		bls	get_track13
		moveq	#0,d0			*none
get_track13:	cmp.b	INSTRUMENT(a1),d0
		beq	get_track20
		move.b	d0,INSTRUMENT(a1)
		bset	#0,d5
		moveq	#0,d0
		move.w	d0,KEYOFFSET(a1)

get_track20:
		cmp.b	#3,d0
		bne	get_track30
*		move.w	PR_PITCH(a0),d0			*MIDI BEND
*		subi.w	#8192,d0
*		add.w	KEYDETUNE(a0),d0
*		add.w	MP_LFOX6(a0),d0
		move.w	WASPITCH(a0),d0
		cmp.w	BEND(a1),d0
		beq	get_track21
		move.w	d0,BEND(a1)
		bset	#1,d5
get_track21:
*		eori.w	#$5555,$e82200

		moveq	#127,d0				*MIDI PAN
		and.b	PANMST(a0),d0
		cmp.w	PAN(a1),d0
		beq	get_track50
		move.w	d0,PAN(a1)
		bset.l	#2,d5
		bra	get_track50

get_track30:
	*	move.w	DETUNE(a0),d0			*FM BEND
		move.w	WASPITCH(a0),d0
*		add.w	PR_PITCH(a0),d0
*		add.w	MP_LFOX6(a0),d0
		cmp.w	BEND(a1),d0
		beq	get_track40
		move.w	d0,BEND(a1)
		bset	#1,d5
get_track40:
		moveq	#127,d0
		and.b	PANMST(a0),d0		*FM PAN
		cmp.w	PAN(a1),d0
		beq	get_track50
		move.w	d0,PAN(a1)
		bset.l	#2,d5
get_track50:
		moveq	#0,d0				*PROGRAM
		move.b	MC_PROGRAM(a0),d0
		cmp.w	PROGRAM(a1),d0
		beq	get_track90
		move.w	d0,PROGRAM(a1)
		bset.l	#3,d5
get_track90:
		move.b	d5,STCHANGE(a1)
		rts



*==================================================
*MCDRV �L�[�n�m���擾
*==================================================


TRK_NUM		equ	32


MCDRV_KEYON:
		movem.l	d0-d4/a0-a4,-(sp)

		lea	TRACK_STATUS(a6),a2

		movea.l	a2,a0				*TRACK_STATUS�N���A
*		moveq	#TRK_NUM-1,d0
*MCDRV_KEYON10:
*		clr.l	STCHANGE(a0)
*		lea	TRST(a0),a0
*		dbra	d0,MCDRV_KEYON10

		movea.l	MC_KEYONBUF(a6),a1
		move.w	MC_KEYONOFST(a6),d7
		bra	MCDRV_KEYON80

MCDRV_KEYON20:
		lea	2(a1,d7.w),a0
		moveq	#0,d0
		move.b	(a0)+,d0		*track
		cmpi.w	#TRK_NUM,d0
		bcc	MCDRV_KEYON29
		mulu	#TRST,d0
		lea	(a2,d0.w),a4
		lea	KEYCODE(a4),a3
		move.b	(a0)+,d2		*note
		move.b	(a0)+,d3		*velocity
		bne	MCDRV_KEYON22

		moveq	#8-1,d0				*�L�[�n�e�e
MCDRV_KEYON21:
		cmp.b	(a3)+,d2
		dbeq	d0,MCDRV_KEYON21
		bne	MCDRV_KEYON29
		subq.w	#8-1,d0
		neg.w	d0
		bset.b	d0,KEYONCHANGE(a4)
		bset.b	d0,KEYONSTAT(a4)
		bra	MCDRV_KEYON29

MCDRV_KEYON22:
		moveq	#8-1,d0				*�L�[�n�m
MCDRV_KEYON23:	cmp.b	(a3)+,d2
		dbeq	d0,MCDRV_KEYON23
		bne	MCDRV_KEYON24
		subq.w	#8-1,d0				*����������������A�������n�e�e
		neg.w	d0
		bset.b	d0,KEYONCHANGE(a4)
		bset.b	d0,KEYONSTAT(a4)
MCDRV_KEYON24	move.b	KEYONSTAT(a4),d0		*�L�[�n�e�e�̉���T���Ăn�m����
		moveq	#8-1,d4
MCDRV_KEYON25:	lsr.b	#1,d0
		dbcs	d4,MCDRV_KEYON25
		bcc	MCDRV_KEYON26
		moveq	#8-1,d0
		sub.w	d4,d0
		bra	MCDRV_KEYON27
MCDRV_KEYON26:	moveq	#0,d0				*�L�[�n�e�e�̉�������
MCDRV_KEYON27:
		bset.b	d0,KEYONCHANGE(a4)
		bclr.b	d0,KEYONSTAT(a4)
		bset.b	d0,KEYCHANGE(a4)
		move.b	d2,KEYCODE(a4,d0.w)
		cmp.b	VELOCITY(a4,d0.w),d3
		beq	MCDRV_KEYON29
		bset.b	d0,VELCHANGE(a4)
		move.b	d3,VELOCITY(a4,d0.w)


MCDRV_KEYON29:
		addq.w	#4,d7
		andi.w	#$03ff,d7
MCDRV_KEYON80:
		cmp.w	(a1),d7
		bne	MCDRV_KEYON20

		move.w	d7,MC_KEYONOFST(a6)
		movem.l	(sp)+,d0-d4/a0-a4
		rts


*==================================================
* MCDRV ���t�g���b�N����
*	d0 -> �g���b�N�t���O
*==================================================

MCDRV_GETMASK:
		move.l	d1,-(sp)
		MCDRV	_GETPLAYFLG
		move.l	(sp)+,d1
		rts


*==================================================
* MCDRV ���t�g���b�N�ݒ�
*	d1 <- �g���b�N�t���O
*==================================================

MCDRV_SETMASK:
		rts

*==================================================
*�g���q�e�[�u��
*==================================================

MCDRV_FILEEXT:
		move.l	a0,-(sp)
		lea	ext_buf(pc),a0
		move.l	a0,d0
		move.l	(sp)+,a0
		rts

ext_buf:	.dc.b	_MDX,'MDX'
		.dc.b	_MDR,'MDR'
		.dc.b	_RCP,'RCP'
		.dc.b	_RCP,'R36'
		.dc.b	_MID,'MID'
		.dc.b	_STD,'STD'
		.dc.b	_MFF,'MFF'
		.dc.b	_SMF,'SMF'
		.dc.b	_ZMS,'ZMS'
		.dc.b	_OPM,'OPM'
		.dc.b	_MDZ,'MDZ'
		.dc.b	_ZDF,'ZDF'
		.dc.b	_MDF,'MDF'
		.dc.b	_MDC,'MDC'

		.dc.b	0
		.even


*==================================================
*�ȃf�[�^�ǂݍ��݃��[�`��
*	a1.l <- �t�@�C���l�[��
*	d0.b <- ���t�f�[�^�̎��ʃR�[�h
*	d0.l -> ���Ȃ�G���[
*==================================================

MCDRV_FLOADP:
		move.l	a1,-(sp)
		clr.b	MC_STOPCOND(a6) * loading new file, clear this
		cmpi.b	#_MDX,d0
		beq	floadp_mdx
		cmpi.b	#_MDR,d0
		beq	floadp_mdx
		cmpi.b	#_RCP,d0
		beq	floadp_rcp
		cmpi.b	#_R36,d0
		beq	floadp_rcp
		cmpi.b	#_ZMS,d0
		beq	floadp_zms
		cmpi.b	#_OPM,d0
		beq	floadp_zms
		cmpi.b	#_MDZ,d0
		beq	floadp_mdz
		cmpi.b	#_MID,d0
		beq	floadp_smf
		cmpi.b	#_STD,d0
		beq	floadp_smf
		cmpi.b	#_MFF,d0
		beq	floadp_smf
		cmpi.b	#_SMF,d0
		beq	floadp_smf
		cmpi.b	#_ZDF,d0
		beq	floadp_mmcp
		cmpi.b	#_MDF,d0
		beq	floadp_mmcp
		cmpi.b	#_MDC,d0
		beq	floadp_mmcp

		move.l	(sp)+,a1
		moveq	#-1,d0
		rts

floadp_mdx:
		lea	mdx2mdc_name(pc),a0
		bsr	CALL_PLAYER
		bra	floadp90

floadp_rcp:
		lea	rcp2mdc_name(pc),a0
		bsr	CALL_PLAYER
		bra	floadp90

floadp_smf:
		lea	smf2mdc_name(pc),a0
		bsr	CALL_PLAYER
		bra	floadp90

floadp_zms:
		lea	zms2mdc_name(pc),a0
		bsr	CALL_PLAYER
		bra	floadp90

floadp_mdz:
		lea	mdz2mdc_name(pc),a0
		bsr	CALL_PLAYER
		bra	floadp90

floadp_mmcp:
		lea	mmcp_name(pc),a0
		bsr	CALL_PLAYER
		bra	floadp90

floadp90:
*		move.l	d0,-(sp)
*		bsr	MCDRV_STOP
*		bsr	MCDRV_PLAY
*		move.l	(sp)+,d0
		move.l	(sp)+,a1
		rts

mdx2mdc_name:	.dc.b	'MDX2MDC.R',0
rcp2mdc_name:	.dc.b	'RCP2MDC.R',0
smf2mdc_name:	.dc.b	'SMF2MDC.R',0
zms2mdc_name:	.dc.b	'ZMS2MDC.R',0
mdz2mdc_name:	.dc.b	'MDZ2MDC.R',0
mmcp_name:	.dc.b	'MMCP.R',0
		.even


*==================================================
* MCDRV ���t�J�n
*==================================================

MCDRV_PLAY:
		clr.b	MC_STOPCOND(a6)
		MCDRV	_STOPMUSIC
		MCDRV	_PLAYMUSIC
		rts


*==================================================
* MCDRV ���t���f
*==================================================

MCDRV_PAUSE:
		MCDRV	_PAUSEMUSIC
		rts


*==================================================
* MCDRV ���t�ĊJ
*==================================================

MCDRV_CONT:
		MCDRV	_PAUSEMUSIC
		rts


*==================================================
* MCDRV ���t��~
*==================================================

MCDRV_STOP:
		clr.b	MC_STOPCOND(a6)
		MCDRV	_STOPMUSIC
		rts


*==================================================
* MCDRV �t�F�[�h�A�E�g
*==================================================

MCDRV_FADEOUT:
		move.l	d1,-(sp)
		moveq	#10,d1
		move.b  d1,MC_STOPCOND(a6)
		MCDRV	_FADEOUT
		move.l	(sp)+,d1
		rts


*==================================================
* MCDRV �X�L�b�v
*	d0.w <- �X�L�b�v�J�n�t���O
*==================================================

MCDRV_SKIP:	move.l	d1,-(sp)
		moveq.l	#12,d1
		MCDRV	_SKIPPLAY
		move.l	(sp)+,d1
		rts


*==================================================
* MCDRV �X���[
*	d0.w <- �X���[�J�n�t���O
*==================================================

MCDRV_SLOW:
		rts

		.end


