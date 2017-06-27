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
* MADRV �G���g���[�e�[�u��
*==================================================

		.xdef	MADRV_ENTRY

FUNC		.macro	entry
		.dc.w	entry-MADRV_ENTRY
		.endm

MADRV_ENTRY:
		FUNC	MADRV_CHECK
		FUNC	MADRV_NAME
		FUNC	MADRV_INIT
		FUNC	MADRV_SYSSTAT
		FUNC	MADRV_TRKSTAT
		FUNC	MADRV_GETMASK
		FUNC	MADRV_SETMASK
		FUNC	MADRV_FILEEXT
		FUNC	MADRV_FLOADP
		FUNC	MADRV_PLAY
		FUNC	MADRV_PAUSE
		FUNC	MADRV_CONT
		FUNC	MADRV_STOP
		FUNC	MADRV_FADEOUT
		FUNC	MADRV_SKIP
		FUNC	MADRV_SLOW


*==================================================
* MADRV ���[�J�����[�N�G���A
*==================================================

		.offset	DRV_WORK
MA_BUF		.ds.l	1
SLOW_TEMPO	.ds.b	1
ORIG_TEMPO	.ds.b	1
		.text


MADRV		.macro	func
		moveq	func,d0
		TRAP	#4
		.endm

*==================================================
* MADRV �\���̒�`
*==================================================

			.offset	0
MA_CM0		.ds.w	3		*TRANSFER_PCMDATA	*�f�[�^�]��/�X�^���o�C
MA_CM1		.ds.w	3		*TRANSFER_MMLDATA	*�f�[�^�]��/�X�^���o�C
MA_CM2		.ds.w	3		*PLAY_MUSIC		*���t�J�n
MA_CM3		.ds.w	3		*STOP_MUSIC		*���t��~
MA_CM4		.ds.w	3		*CONTINUE_MUSIC		*���t�ĊJ
MA_CM5		.ds.w	3		*SET_TITLE		*�^�C�g�������R�s�[����
MA_CM6		.ds.w	3		*GET_TITLE		*�^�C�g�������o��
MA_CM7		.ds.w	3		*GET_STATUS		*���t��Ԃ����o��
MA_CM8		.ds.w	3		*RELEASE		*�풓����
MA_CM9		.ds.w	3		*FADEOUT		*�t�F�[�h�A�E�g���s
MA_CM10		.ds.w	3		*GETWORKPTR		*WORKAREA�ւ�POINTER��o
MA_CM11		.ds.w	3		*GETCLOCK		*�N���b�N���o��
MA_CM12		.ds.w	3		*GETPCMPTR		*PCMBUFFER�ւ�POINTER��o
MA_CM13		.ds.w	3		*SETPCMPTR		*PCMBUFFER��POINTER�ݒ�
MA_CM14		.ds.w	3		*SETFADE		*�t�F�[�h�A�E�g�ݒ�E�֎~
MA_CM15		.ds.w	3		*SETINT			*OPM���荞�݃`�F�C���ݒ�
MA_CM16		.ds.w	3		*UNREMOVE		*�풓�����֎~
MA_CM17		.ds.w	3		*STOPSIGNAL		*��~�V�O�i�����M
MA_CM18		.ds.w	3		*GETMMLPTR		*MMLBUFFER�ւ�POINTER��o
MA_CM19		.ds.w	3		*SETMMLPTR		*MMLBUFFER��POINTER�ݒ�
MA_CM20		.ds.w	3		*KEYBOARDCTRL		*1.07����ǉ�
MA_CM21		.ds.w	3		*SETMASK
MA_CM22		.ds.w	3		*GETPCMFILE
MA_CM23		.ds.w	3		*FADEONETIME
MA_CM24		.ds.w	3		*GETLOOPCOUNTER
MA_CM25		.ds.w	3		*SETPRW
MA_CM26		.ds.w	3		*GETPCMFRAME
MA_CM27		.ds.w	3		*GETMMLFRAME


*
*	�g���b�N���[�N�G���A
*
		.offset	0
TRKPTR		ds.l	1	*�g���b�N���P�[�V�����J�E���^
TRACKACT	ds.b	1	*�g���b�N�A�N�e�B�r�e�B�t���O
TRACKSIGNAL	ds.b	1	*�V�O�i���t���O
PCMBANK		ds.l	1	*PCM�p�o���N���W�X�^
MAKEYCODE	ds.l	1	*�L�[�R�[�h�o�b�t�@	KEYCODE -> MAKEYCODE
KEYDETUNE	ds.l	1	*�f�`���[�����ݒl
PR_PITCH	ds.l	1	*�|���^�����g���݃s�b�`
PR_MPITCH	ds.l	1	*�|���^�����g�s�b�`
WASKEY		ds.w	1	*�ȑO�̃L�[�l
NOWVOLUME	ds.w	1	*���݂̃{�����[��
WAS_VOL		ds.w	1	*�ߋ��̃{�����[��
VOLUMESETJOB	ds.l	1	*���ʐݒ菈���A�h���X
VOLUMEMAP	ds.b	4	*�{�����[���ݒ�l�}�b�v
MPLFOJOB	ds.l	1	*�k�e�n�����A�h���X
MPLFOJOB2	ds.l	1	*�k�e�n�����A�h���X
MALFOJOB	ds.l	1	*�k�e�n�����A�h���X
MALFOJOB2	ds.l	1	*�k�e�n�����A�h���X
MP_LFOX0	ds.l	1	*LFO�p���[�N�G���A
MP_LFOX1	ds.l	1	*
MP_LFOX2	ds.l	1	*
MP_LFOX3	ds.l	1	*
MP_LFOX4	ds.l	1	*
MP_LFOX5	ds.l	1	*
MP_LFOX6	ds.l	1	*
MA_LFOX0	ds.w	1	*LFO�p���[�N�G���A
MA_LFOX1	ds.w	1	*
MA_LFOX2	ds.w	1	*
MA_LFOX3	ds.w	1	*
MA_LFOX4	ds.w	1	*
MA_LFOX5	ds.w	1	*
PCMFREQPAN	ds.w	1	*PCM���g���E���� (PCM8�p)
MASINPT		ds.w	1	*�T�C���g�k�e�n�J�E���^�[
MZSINPT		ds.w	1	*
PROGRAM_PTR	ds.l	1	*�v���O�����ւ̃|�C���^
SEQDELTA	ds.b	1	*�V�[�P���X�E�f���^�^�C�}�[
MH_SYNC		ds.b	1	*�V���N���L��(�S�̂�)
MH_AMSPMS	ds.b	1	*PMS/AMS(���F��)
LFODELAY	ds.b	1	*LFO�f�B���C
LFODELTA	ds.b	1	*LFO�^�C�}�[
LFOACTIVE	ds.b	1	*LFO�A�N�e�B�x�[�g
LFOMOTOR	ds.b	1	*LFO���[�^�[
MPMOTOR		ds.b	1	*MP���[�^�[	0:��~	1:����
MAMOTOR		ds.b	1	*MA���[�^�[	0:��~	1:����
KEYONDELAY	ds.b	1	*�L�[�I���E�f�B���C
KEYONDELTA	ds.b	1	*�L�[�I���E�^�C�}�[
KEYONMOTOR	ds.b	1	*�L�[�I���E���[�^�[
KEYOFGATE	ds.b	1	*�L�[�I�t�E�Q�[�g�^�C��(@q�p)
KEYOFDELTA	ds.b	1	*�L�[�I�t�E�^�C�}�[
KEYOFMOTOR	ds.b	1	*�L�[�I�t�E���[�^�[
KEYONSIGNE	ds.b	1	*�L�[�I�����ɏ������ޓ��e
NOWFLCON	ds.b	1	*FL&CON
NOWPAN		ds.b	1	*���݂̃p���|�b�g
NOWVOLX		ds.b	1	*�p���|�b�g�ψڃo�b�t�@
PCMKEY		ds.b	1	*�L�[�R�[�h�i�l�l�k�ŋL�q�����l�j
WASPCMPAN	ds.b	1	*�L�[�R�[�h�ψڃo�b�t�@
KEYONFLAG	ds.b	1	*�L�[�I���t���O
CURPROG		ds.b	1	*�v���O�����`�F���W�o�b�t�@
CURPROGNEW	ds.b	1	*�v���O�����`�F���W�ψڃo�b�t�@
KEYONWORK	ds.b	1	*�L�[�I�����[�N
EVENTWORK	ds.b	1	*�C�x���g�t���O���[�N
CHVOL		ds.b	1	*�`�����l���剹��
CHVOL_WORK	ds.b	1	*NOWVOLUME�E�ۑ��l
REALTL		ds.l	1	*�f�B�X�g�[�V�������[�N
REALTLWAS	ds.l	1	*�f�B�X�g�[�V�����ψڃo�b�t�@
DISTLVL		ds.b	1	*�f�B�X�g�[�V�������x��
WAS_MALFOX5	ds.b	1	*�k�e�n�ψڃ��[�N
DISTJOB		ds.l	1	*�f�B�X�g�[�V���������A�h���X
LFODELAY_A	ds.b	1	*LFO�f�B���C
LFODELTA_A	ds.b	1	*LFO�^�C�}�[
LFOACTIVE_A	ds.b	1	*LFO�A�N�e�B�x�[�g
LFOMOTOR_A	ds.b	1	*LFO���[�^�[
LFODELAY_Z	ds.b	1	*LFO�f�B���C
LFODELTA_Z	ds.b	1	*LFO�^�C�}�[
LFOACTIVE_Z	ds.b	1	*LFO�A�N�e�B�x�[�g
LFOMOTOR_Z	ds.b	1	*LFO���[�^�[
LFOINUSE	ds.l	1	*LFO�����t���O�p
MZ_LFOX0	ds.w	1	*LFO�p���[�N�G���A
MZ_LFOX1	ds.w	1	*
MZ_LFOX2	ds.w	1	*
MZ_LFOX3	ds.w	1	*
MZ_LFOX4	ds.w	1	*
MZ_LFOX5	ds.w	1	*
MZMOTOR		ds.b	1	*�f�B�X�g�[�V�����f���^�J�E���^
DISTOFS		ds.b	1	*�f�B�X�g�[�V�����I�t�Z�b�g
MZLFOJOB	ds.l	1	*�f�B�X�g�[�V���������A�h���X
MZLFOJOB2	ds.l	1	*
JMPTBLPTR	ds.l	1	*�W�����v�e�[�u���ւ̃A�h���X
KEYONJOB	ds.l	1	*�L�[�I�������A�h���X
CURCH		ds.w	1	*�O���[�o���f�o�C�X(�o�͐�)
WASPCMKEY	ds.b	1	*�L�[�R�[�h�ψڕۑ����[�N
WAS_VOLF	ds.b	1	*���ʕψڃ��[�N
CTRLUNIT	ds.b	1	*�f�o�C�X�`�����l��
NEWPAN		ds.b	1	*�p���|�b�g�ψڃ��[�N
BEND_SNS	ds.w	1	*�x���h���x
GLCH		ds.w	1	*�V�X�e���`�����l��(���� $00�`$07:OPM �`$0F:PCM $80�`$8F:MIDI)
POLY_PTR	ds.w	1	*�|���t�H�j�b�N�m�[�g�I���|�C���^
POLY_WAS	ds.w	1	*�|���t�H�j�b�N�m�[�g�I���|�C���^
BEND_RANGE	ds.b	1	*�x���h�����W�l
NOWVELX		ds.b	1	*�x���V�e�B�ψڃ��[�N
MAVELOCITY	ds.b	1	*�x���V�e�B���[�N	VELOCITY -> MAVELOCITY
MIDIKEYON	ds.b	1	*MIDI�L�[�I���o�b�t�@
MOD_SW		ds.b	1	*���W�����[�V�����X�C�b�`
MOD_SWOF	ds.b	1	*���W�����[�V�����E�I�t���x��
MOD_SWON	ds.b	1	*���W�����[�V�����E�I�����x��
MOD_LVL		ds.b	1	*���W�����[�V�����E���x��
MOD_WAS		ds.b	1	*�ߋ��̃��W�����[�V�������x��
MOD_DELAY	ds.b	1	*�f�B���C
MOD_DELTA	ds.b	1	*�f���^�J�E���^
POLY_KEYON	ds.b	1	*�|���t�H�j�b�N�L�[�I���t���O(���ۂɃL�[�I�����Ă���a����)
POLY_STACK	ds.b	32	*�|���t�H�j�b�N�m�[�g�I���͂P�U���܂�
BEND_MODE	ds.b	1	*�s�b�`�x���_�E���[�h
BEND_RES	ds.b	1	*�s�b�`�x���h�E���X�|���X�^�C��
BEND_RCNT	ds.b	1	*�s�b�`�x���h�E���X�|���X�J�E���^
UDEVICE		ds.b	1	*MIDI�O���[�o���f�o�C�X(MIDI�@��)
MPOFS		ds.b	1	*�|���^�����g�I�t�Z�b�g
MAOFS		ds.b	1	*�A���v���`���[�h�I�t�Z�b�g
MZOFS		ds.b	1	*�f�B�X�g�[�V�����I�t�Z�b�g
		.even


*	�V�X�e�����[�N�G���A

		.offset	0
		ds.b	$100*32	*�g���b�N���[�N���R�Q��
PROGRAM_BANK	ds.l	256	*�v���O�����p�e�[�u��
TO_MMLPTR	ds.l	1	*MML�̈�ւ̃|�C���^
TO_PCMPTR	ds.l	1	*PCM�̈�ւ̃|�C���^
LEN_MMLPTR	ds.l	1	*MML�̈�̒���
LEN_MMLDATA	ds.l	1	*MML�Ɏ��ۂɓ����Ă���f�[�^�̒���
LEN_PCMPTR	ds.l	1	*PCM�̈�̑傫��
PLAYFLAG	ds.l	1	*���t��ԃt���O(b0�`b15�Ɋe�g���b�N����)
ONPCMFLAG	ds.b	1	*PCM�����邩�H
ONMMLFLAG	ds.b	1	*MML�͂��邩�H
STOP_SIGNAL	ds.b	1	*��~�V�O�i��
PAUSE_MARK	ds.b	1
PCMFNAME	ds.b	128	*PCM8.x�̃p�X�l�[��
PCM8VCT		ds.l	1
FADEP		ds.w	1	*�t�F�[�h�A�E�g�s�b�`
FADEPITCH	ds.w	1	*�s�b�`���[�^�[
FADELVL		ds.w	1	*�t�F�[�h�A�E�g���x��(�����ɂȂ�����I��)
WAS_VCT0	ds.l	1	*OPM�̃x�N�^�ۑ�
WAS_VCT1	ds.l	1
WAS_VCT2	ds.l	1
WAS_VCTA	ds.l	1
WAS_VCTB	ds.l	1
WAS_VCTC	ds.l	1
WAS_VCTD	ds.l	1
NEW_VCT0	ds.l	1
NEW_VCT1	ds.l	1
NEW_VCT2	ds.l	1
NEW_VCTA	ds.l	1
NEW_VCTB	ds.l	1
NEW_VCTC	ds.l	1
NEW_VCTD	ds.l	1
MAXTRACK:	ds.w	1	*�ő�g���b�N(0�`15)
NOWCLOCK:	ds.l	1	*�O���N���b�N�o��
TO_MMLPTR2:	ds.l	1	*MDX�̈�ւ̃|�C���^
TO_PCMPTR2:	ds.l	1	*PCM�̈�ւ̃|�C���^
INT_VCT		ds.l	1	*�C���^���v�g�x�N�^
ATPCMPTR	ds.l	1	*�\���΍�
ADPCM_BUSY	ds.b	1
ADPCM_Y0	ds.b	1
ADPCM_FREQ	ds.b	1
ADPCM_PAN	ds.b	1
EX_PCM2:	ds.b	1	*EX-PCM�t���O
TEMPO:		ds.b	1	*�e���|�ێ��p
EX_PCM		ds.b	1	*EX-PCM�t���O
STOPFLAG	ds.b	1
EXOPKEY1	ds.b	1
GRAM_SELECT	ds.b	1
UNREMOVE_FLAG	ds.b	1
KEYCTRLFLAG	ds.b	1
WAS_VCTI	ds.l	1	*IOCS $F0
TRACKMASK	ds.l	1	*�g���b�N�}�X�N
LED_COUNTER	ds.w	1
MMLTITLE:	ds.b	512	*MML�̃^�C�g��
DENDMASK	ds.l	1	*�f�[�^�G���h�t���O
FADEPM		ds.w	1	*�t�F�[�h�A�E�g
INTMASK		ds.w	1
LOOP_FLAG	ds.w	1	*���[�v�t���O
NOW_WAVEFORM	ds.b	1	*�n�[�h�E�G�ALFO WAVEFORM
NOW_LFREQ	ds.b	1	*LFREQ
NOW_PMD		ds.b	1	*PMD
NOW_AMD		ds.b	1	*AMD
NEWFILE		ds.b	1	*-1;�V�K�t�@�C���ݒ�
NEWHLFO		ds.b	1	*�n�[�h�E�G�ALFO�V�K�ݒ�
OPMINT_SUBCNT	ds.b	1	*�T�u���荞�ݐ���
WASTEMPO	ds.b	1
LED_DELAY	ds.b	1
MASTER_VOL	ds.b	1	*�}�X�^�[�{�����[��
REWIND_VOL	ds.b	1	*�����莞�̃{�����[��
PCM_NOREL	ds.b	1	*�m�[�}��MDX����PCM�p�[�g���L�[�I�t���Ȃ�
EX_MIDI		ds.b	1	*�l�h�c�h�g�����[�h(�n�[�h�E�G�A�L��)
EX_MIDI2	ds.b	1	*�l�h�c�h�g�����[�h(�l�h�c�h�g�����[�h���t)
		EVEN
RANDOME_SEED	ds.w	1	*������
REWIND_DELTA	ds.l	1
_REPEAT_HOME	ds.l	1	*���s�[�g�J�n���̃N���b�N
_REPEAT_HOMEC	ds.l	1	*���s�[�g�J�n���̃��[�v�J�E���^
_REPEAT_UNDO	ds.l	1	*���s�[�g�I�����̃N���b�N
WAS_MCSV00	ds.l	1	*�x�N�^�[�o�b�t�@(MIDI�p)
WAS_MCSV01	ds.l	1
WAS_MCSV02	ds.l	1
WAS_MCSV03	ds.l	1
WAS_MCSV04	ds.l	1
WAS_MCSV05	ds.l	1
WAS_MCSV06	ds.l	1
WAS_MCSV07	ds.l	1
WAS_MCSV08	ds.l	1
SCDBS_RAW	ds.w	1	*�\�������[�N
DISPWORK	ds.b	64	*SC55�t�����[�N
CM64_PARTRSV	ds.b	16	*�p�[�V�������U�[�u�o�b�t�@
MT32_PARTRSV	ds.b	16	*
SC55_PARTRSV	ds.b	16	*

		.text
		.even


*==================================================
* MADRV �풓�`�F�b�N
*==================================================

MADRV_CHECK:
		move.l	a0,-(sp)
		move.l	$24*4.w,a0
		cmp.l	#"*MAD",-12(a0)
		bne	not_keeped
		cmp.l	#"RV3*",-8(a0)
		bne	not_keeped
		move.l	-4(a0),d0
		cmp.l	#109*$10000+15,d0		*�o�[�W������
		bcc	keeped				*	�P�D�O�X���ȏ�
not_keeped:
		moveq.l	#-1,d0
keeped:
		move.l	(sp)+,a0
		rts


*==================================================
* MADRV �h���C�o���擾
*==================================================

MADRV_NAME:
		move.l	a0,-(sp)
		lea	name_buf(pc),a0
		move.l	a0,d0
		move.l	(sp)+,a0
		rts

name_buf:	.dc.b	'MADRV',0
		.even

*==================================================
* MADRV �h���C�o������
*==================================================

MADRV_INIT:
		movem.l	d0/a0,-(sp)
		MADRV	#10
		move.l	d0,MA_BUF(a6)

		clr.l	TRACK_ENABLE(a6)
		move.w	#301,CYCLETIM(a6)		*238 at 16track
		move.w	#77,TITLELEN(a6)

		lea	TRACK_STATUS(a6),a0	*�g���b�N�ԍ�������
		moveq	#1,d0
madrv_init10:
		move.b	d0,TRACKNO(a0)
		lea	TRST(a0),a0
		addq.w	#1,d0
		cmpi.w	#32,d0
		bls	madrv_init10

		movem.l	(sp)+,d0/a0
		rts


*==================================================
* MADRV �V�X�e�����擾
*==================================================

MADRV_SYSSTAT:
		movem.l	d0/a0,-(sp)

		MADRV	#6				*�^�C�g��
		move.l	a0,SYS_TITLE(a6)

		move.l	MA_BUF(a6),a0			*���[�v�J�E���^
		move.w	LOOP_FLAG(a0),SYS_LOOP(a6)

		moveq.l	#0,d0				*�e���|
		move.b	TEMPO(a0),d0
		move.w	d0,SYS_TEMPO(a6)

		tst.l	PLAYFLAG(a0)			*���t���t���O
		sne.b	d0
		ext.w	d0
		move.w	d0,PLAY_FLAG(a6)

		or.b	PAUSE_MARK(a0),d0		*���t�I���t���O
		seq	d0
*		and.b	STOPFLAG(a0),d0
		ext.w	d0
		move.w	d0,PLAYEND_FLAG(a6)

		movem.l	(sp)+,d0/a0

		rts


*==================================================
* MADRV �X�e�[�^�X�擾
*==================================================

MADRV_TRKSTAT:
		bsr	MADRV_KBSSET
		bsr	MADRV_TRACK
		rts


*
*	���l�`�c�q�u�Q�j�a�r�r�d�s
*�@�\�F�l�`�c�q�u�̃L�[�{�[�h�X�e�[�^�X�𓾂�
*���o�́F�Ȃ�
*�Q�l�F�b�g�r�s�Q�a�e�Q�v�i���U�j�ɂ������ׂ�
*

MADRV_KBSSET:
		movem.l	d0-d1/d6-d7/a0-a3,-(sp)

		lea.l	CHST_BF(a6),a0
		move.l	MA_BUF(a6),a2
		move.l	a2,a3

		moveq.l	#7,d7
ma_kbsset_loop:
		moveq.l	#0,d6

		move.b	EVENTWORK(a3),d0		*C:�l�o
		btst.l	#0,d0
		sne.b	d1
		cmp.b	KBS_MP(a0),d1
		beq	ma_kbsset_jp01
		bset.l	#$C,d6
		move.b	d1,KBS_MP(a0)
ma_kbsset_jp01:
		btst.l	#1,d0				*D:�l�`
		sne.b	d1
		cmp.b	KBS_MA(a0),d1
		beq	ma_kbsset_jp02
		bset.l	#$D,d6
		move.b	d1,KBS_MA(a0)
ma_kbsset_jp02:
		btst.l	#2,d0				*E:�l�g
		sne.b	d1
		cmp.b	KBS_MH(a0),d1
		beq	ma_kbsset_jp03
		bset.l	#$E,d6
		move.b	d1,KBS_MH(a0)
ma_kbsset_jp03:
		move.b	KEYONDELAY(a3),d0		*0:��
		cmp.b	KBS_k(a0),d0
		beq	ma_kbsset_jp0
		bset.l	#0,d6
		move.b	d0,KBS_k(a0)
ma_kbsset_jp0:
		move.b	KEYOFGATE(a3),d0		*1:��
		cmp.b	KBS_q(a0),d0
		beq	ma_kbsset_jp2
		bset.l	#1,d6
		move.b	d0,KBS_q(a0)
ma_kbsset_jp2:
		move.w	KEYDETUNE(a3),d0		*2:�c
		cmp.w	KBS_D(a0),d0
		beq	ma_kbsset_jp3
		bset.l	#2,d6
		move.w	d0,KBS_D(a0)
ma_kbsset_jp3:
		move.w	MP_LFOX6(a3),d0			*3:�o
		cmp.w	KBS_P(a0),d0
		beq	ma_kbsset_jp4
		bset.l	#3,d6
		move.w	d0,KBS_P(a0)
ma_kbsset_jp4:
		move.w	PR_PITCH(a3),d0			*4:�a
		cmp.w	KBS_B(a0),d0
		beq	ma_kbsset_jp5
		bset.l	#4,d6
		move.w	d0,KBS_B(a0)
ma_kbsset_jp5:
		move.b	MA_LFOX5(a3),d0			*5:�`
		ext.w	d0
		neg.w	d0
		cmp.w	KBS_A(a0),d0
		beq	ma_kbsset_jp6
		bset.l	#5,d6
		move.w	d0,KBS_A(a0)
ma_kbsset_jp6:
		move.l	PROGRAM_PTR(a3),d0		*6:��
		beq	ma_kbsset_jp8
		move.l	d0,a1
		moveq.l	#0,d0
		move.b	-1(a1),d0
		cmp.w	KBS_PROG(a0),d0
		beq	ma_kbsset_jp8
		bset.l	#6,d6
		move.w	d0,KBS_PROG(a0)
ma_kbsset_jp8:
		moveq.l	#0,d0
		move.b	NOWVOLX(a3),d0			*7:�����P
		bclr.l	#7,d0
		bne	ma_kbsset_jp9
		lea.l	VOL_DEFALT(pc),a1
		move.b	0(a1,d0.w),d0
		bra	ma_kbsset_jpA
ma_kbsset_jp9:	neg.b	d0
		add.b	#$7F,d0
ma_kbsset_jpA:	cmp.b	KBS_TL1(a0),d0
		beq	ma_kbsset_jpB
		bset.l	#7,d6
		move.b	d0,KBS_TL1(a0)
ma_kbsset_jpB:
		move.b	NOWVOLUME(a3),d0		*8:�����Q
		add.b	MA_LFOX5(a3),d0
		add.b	FADELVL(a2),d0
		bpl	ma_kbsset_jpZ
		moveq.l	#$7F,d0
ma_kbsset_jpZ:	neg.b	d0
		add.b	#$7F,d0
		cmp.b	KBS_TL2(a0),d0
		beq	ma_kbsset_jpC
		bset.l	#8,d6
		move.b	d0,KBS_TL2(a0)
ma_kbsset_jpC:
		move.l	TRKPTR(a3),d0			*9:�c�`�s�`
		cmp.l	KBS_DATA(a0),d0
		beq	ma_kbsset_jpD
		bset.l	#9,d6
		move.l	d0,KBS_DATA(a0)
ma_kbsset_jpD:
		move.b	PCMKEY(a3),d0			*A:�j�b�P
		lsl.w	#6,d0
		cmp.w	KBS_KC1(a0),d0
		beq	ma_kbsset_jpF
		bset.l	#$A,d6
		move.w	d0,KBS_KC1(a0)
ma_kbsset_jpF:
		move.w	MAKEYCODE(a3),d0		*B:�j�b�Q
		add.w	PR_PITCH(a3),d0
		add.w	MP_LFOX6(a3),d0
		cmp.w	KBS_KC2(a0),d0
		beq	ma_kbsset_jpG
		bset.l	#$B,d6
		move.w	d0,KBS_KC2(a0)
ma_kbsset_jpG:

		move.w	d6,KBS_CHG(a0)			*�`�F�b�N�t���O��������

		lea.l	CHST(a0),a0
		lea.l	$100(a3),a3

		dbra	d7,ma_kbsset_loop

		movem.l	(sp)+,d0-d1/d6-d7/a0-a3

		rts


*==================================================
*MADRV �g���b�N���擾
*==================================================

MADRV_TRACK:
		movem.l	d0-d3/d5/d7/a0-a3,-(sp)
		movea.l	MA_BUF(a6),a0
		movea.l	a0,a3
		lea	TRACK_STATUS(a6),a1
		lea	VOL_DEFALT(pc),a2

		move.l	TRACKMASK(a0),d2
		not.l	d2
		and.l	PLAYFLAG(a0),d2

		moveq	#0,d1
		moveq	#32-1,d7
madrv_track10:
		bsr	get_track
		lea	$100(a0),a0
		lea	TRST(a1),a1
		addq.w	#1,d1
		dbra	d7,madrv_track10

		move.l	TRACK_ENABLE(a6),d0
		move.l	d2,TRACK_ENABLE(a6)
		eor.l	d2,d0
		move.l	d0,TRACK_CHANGE(a6)

		movem.l	(sp)+,d0-d3/d5/d7/a0-a3
		rts

*	a0.l <- MADRV TRACK buffer address
*	a1.l <- TRACK_STATUS address
*	a2.l <- VOL_DEFALT address
*	a3.l <- MADRV buffer address
*	d1.l <- TRACK_NUM
*	d2.l <- TRACK_ENABLE
*	d3.l -- break

get_track:
		moveq	#0,d5
		clr.l	STCHANGE(a1)

		tst.b	TRACKACT(a0)
		bne	get_track10
		bclr	d1,d2

get_track10:
		move.b	CURCH(a0),d3			*INSTRUMENT
		bpl	get_track11
		moveq	#0,d0			*none
		cmpi.b	#$8f,d3
		bhi	get_track13
		moveq	#3,d0			*MIDI
		bra	get_track13
get_track11:
		moveq	#1,d0
		cmpi.b	#7,d3			*FM
		bls	get_track13
		moveq	#2,d0			*ADPCM
		cmpi.b	#15,d3
		bls	get_track13
		moveq	#0,d0			*none
get_track13:	cmp.b	INSTRUMENT(a1),d0
		beq	get_track20
		move.b	d0,INSTRUMENT(a1)
		bset	#0,d5
		cmp.b	#3,d0
		bne	get_track15
		moveq	#0,d0
		bra	get_track16
get_track15:	moveq	#15,d0
get_track16:	move.w	d0,KEYOFFSET(a1)

get_track20:
		cmp.b	#3,d0
		bne	get_track30
		move.w	PR_PITCH(a0),d0			*MIDI BEND
		subi.w	#8192,d0
		add.w	KEYDETUNE(a0),d0
		add.w	MP_LFOX6(a0),d0
		cmp.w	BEND(a1),d0
		beq	get_track21
		move.w	d0,BEND(a1)
		bset	#1,d5
get_track21:
		moveq	#127,d0				*MIDI PAN
		and.b	NOWPAN(a0),d0
		cmp.w	PAN(a1),d0
		beq	get_track50
		move.w	d0,PAN(a1)
		bset.l	#2,d5
		bra	get_track50

get_track30:
		move.w	KEYDETUNE(a0),d0		*FM BEND
		add.w	PR_PITCH(a0),d0
		add.w	MP_LFOX6(a0),d0
		cmp.w	BEND(a1),d0
		beq	get_track40
		move.w	d0,BEND(a1)
		bset	#1,d5
get_track40:
		moveq	#-1,d0				*FM PAN
		move.b	NOWPAN(a0),d0
		rol.b	#2,d0
		andi.b	#3,d0
		cmp.w	PAN(a1),d0
		beq	get_track50
		move.w	d0,PAN(a1)
		bset.l	#2,d5
get_track50:
		moveq	#0,d0				*PROGRAM
		move.b	CURPROG(a0),d0
		cmp.w	PROGRAM(a1),d0
		beq	get_track60
		move.w	d0,PROGRAM(a1)
		bset.l	#3,d5
get_track60:
		btst.l	d1,d2				*KEY ON
		beq	get_track62
		tst.b	KEYONWORK(a0)
		beq	get_track61
		clr.b	KEYONWORK(a0)
		move.b	#$01,KEYONCHANGE(a1)
		move.b	#$FE,KEYONSTAT(a1)
		bra	get_track70
get_track61:	tst.b	KEYONFLAG(a0)
		bne	get_track70
get_track62:	btst.b	#0,KEYONSTAT(a1)
		bne	get_track70
		move.b	#$01,KEYONCHANGE(a1)
		move.b	#$FF,KEYONSTAT(a1)
get_track70:
		move.b	PCMKEY(a0),d0			*KEYCODE
		cmp.b	KEYCODE(a1),d0
		beq	get_track80
		move.b	#$01,KEYCHANGE(a1)
		move.b	d0,KEYCODE(a1)
get_track80:
		move.b	NOWVOLUME(a0),d0			*VELOCITY
		add.b	MA_LFOX5(a0),d0
		add.b	FADELVL(a3),d0
		bpl	get_track81
		moveq.l	#$7F,d0
get_track81:	neg.b	d0
		add.b	#$7F,d0
get_track82:	cmp.b	VELOCITY(a1),d0
		beq	get_track90
		move.b	#$01,VELCHANGE(a1)
		move.b	d0,VELOCITY(a1)
get_track90:
		move.b	d5,STCHANGE(a1)
		rts


*==================================================
* MADRV ���t�g���b�N����
*	d0 -> �g���b�N�t���O
*==================================================

MADRV_GETMASK:
		move.l	a0,-(sp)
		move.l	MA_BUF(a6),a0
		move.l	TRACKMASK(a0),d0
		not.l	d0
		move.l	(sp)+,a0
		rts


*==================================================
* MADRV ���t�g���b�N�ݒ�
*	d1 <- �g���b�N�t���O
*==================================================

MADRV_SETMASK:
		move.l	d1,-(sp)
		not.l	d1
		MADRV	#$15
		move.l	(sp)+,d1
		rts

*==================================================
*�g���q�e�[�u��
*==================================================

MADRV_FILEEXT:
		move.l	a0,-(sp)
		lea	ext_buf(pc),a0
		move.l	a0,d0
		move.l	(sp)+,a0
		rts

ext_buf:	.dc.b	_MDX,'MDX'
		.dc.b	_MDR,'MDR'
		.dc.b	_ZDF,'ZDF'
		.dc.b	_ZMS,'ZMS'
		.dc.b	_OPM,'OPM'

		.dc.b	_PIC,'PIC'
		.dc.b	_MAG,'MAG'
		.dc.b	_PI,'PI',0
		.dc.b	_JPG,'JPG'

		.dc.b	0
		.even


*==================================================
*�l�c�w�f�[�^�ǂݍ��݃��[�`��
*	a1.l <- �t�@�C���l�[��
*	d0.b <- ���t�f�[�^�̎��ʃR�[�h
*	d0.l -> ����word:�G���[�ԍ��B
*		long�����Ȃ牉�t�J�n���Ă��Ȃ�
*==================================================

MADRV_FLOADP:
		movem.l	d1/a1,-(sp)
		cmpi.b	#_MDX,d0
		beq	floadp_mdx
		cmpi.b	#_MDR,d0
		beq	floadp_mdx
		cmpi.b	#_ZDF,d0
		beq	floadp_zdf
		cmpi.b	#_ZMS,d0
		beq	floadp_zms
		cmpi.b	#_OPM,d0
		beq	floadp_zms


		cmpi.b	#_PIC,d0
		beq	floadp_pic

		cmpi.b	#_MAG,d0
		beq	floadp_mag

		cmpi.b	#_PI,d0
		beq	floadp_pi

		cmpi.b	#_JPG,d0
		beq	floadp_jpg

		movem.l	(sp)+,d1/a1
		moveq	#-1,d0
		rts

floadp_mdx:
		move.l	a1,-(sp)
		bsr	LOAD_MDX
		bra	floadp90
floadp_zdf:
		move.l	a1,-(sp)
		bsr	LOAD_ZDF
floadp90:
		addq.l	#4,sp
		neg.l	d0
		cmpi.w	#7,d0
		bls	floadp91
		moveq	#7,d0
floadp91:
		move.b	errcnvtbl(pc,d0.w),d1	*�G���[�ԍ��ϊ�
		ext.w	d1
		ext.l	d1
		andi.w	#$007f,d1
		bsr	MADRV_STOP		*���t��~
		tst.l	d1
		bmi	floadp92
		bsr	MADRV_PLAY		*���t�J�n
floadp92:
		move.l	d1,d0
		lea	MMDSP_NAME(pc),a0	*�v���[������MMDSP
		movem.l	(sp)+,d1/a1
		rts

errcnvtbl:	.dc.b	$00,$82,$03,$85,$87,$08,$8a,$81
		.even

floadp_zms:
		lea	opm2mdr_name(pc),a0
		bsr	CALL_PLAYER
		movem.l	(sp)+,d1/a1
		rts

floadp_pic:
		st.b	VDISP_CNT(a6)
		lea	pic_name(pc),a0
		bsr	CALL_PLAYER
		clr.b	VDISP_CNT(a6)
		movem.l	(sp)+,d1/a1
		rts

floadp_mag:
		st.b	VDISP_CNT(a6)
		lea	mag_name(pc),a0
		bsr	CALL_PLAYER

		move.w	#5,-(sp)
		move.w	#16,-(sp)
		DOS	_CONCTRL
		addq.l	#4,sp

		clr.b	VDISP_CNT(a6)
		movem.l	(sp)+,d1/a1
		rts

floadp_pi:
		st.b	VDISP_CNT(a6)
		lea	pi_name(pc),a0
		bsr	CALL_PLAYER
		clr.b	VDISP_CNT(a6)
		movem.l	(sp)+,d1/a1
		rts

floadp_jpg:
		st.b	VDISP_CNT(a6)
		lea	jpg_name(pc),a0
		bsr	CALL_PLAYER
		clr.b	VDISP_CNT(a6)
		movem.l	(sp)+,d1/a1
		rts

pic_name:	.dc.b	'HAPIC -n',0
mag_name:	.dc.b	'MAG',0
pi_name:	.dc.b	'PI',0
jpg_name:	.dc.b	'JPEGED -f2 -n',0


opm2mdr_name:	.dc.b	'OPM2MDR -pq',0
		.even

*==================================================
*MDX/MDR�t�@�C�������[�h����
*	LOAD_MDX(char *name)
*	name	�t�@�C����
*	d0.l -> ���Ȃ�A�G���[
*		-1 MDX���[�h�G���[
*		-2 PDX���[�h�G���[
*		-3 �������s��
*		-4 MDX�o�b�t�@�s��
*		-5 PCM�o�b�t�@�s��
*		-6 �t�H�[�}�b�g�G���[
*==================================================

		.offset	-256
oldpdx_name	.ds.b	256
		.text

LOAD_MDX:
		movem.l	d1-d4/a0-a2,-(sp)
		movea.l	(7+1)*4(sp),a0
		link	a6,#-256

		moveq	#-1,d2			*MDX�o�b�t�@�|�C���^
		moveq	#0,d4

		lea	oldpdx_name(a6),a2	*MADRV����PDX�����o�b�t�@�Ɏ���Ă���
		clr.b	(a2)			*(�w�b�_��͂�����ƕς���Ă��܂�����)
		MADRV	#$16
		tst.l	d0
		beq	load_mdx19
		movea.l	d0,a1
load_mdx10:
		move.b	(a1)+,(a2)+
		bne	load_mdx10
load_mdx19:

		pea	ext_mdx(pc)		*�g���q���Ȃ���΂���
		pea	(a0)
		bsr	ADD_EXT

		clr.l	-(sp)			*MDX�t�@�C����ǂݍ���
		pea	env_MADRV(pc)		*���ϐ�MADRV,mxp��T��
		pea	(a0)
		bsr	READ_FILE
		move.l	d0,d3
		bpl	load_mdx20
		addq.l	#1,d0
		beq	load_mdx_loaderr
		bra	load_mdx_memerr

load_mdx20:
		move.l	a0,d2			*�w�b�_����͂���
		movea.l	d2,a1
		MADRV	#$05
		tst.l	d0
		beq	load_mdx30

		pea	oldpdx_name(a6)		*PDX������΃��[�h����
		move.l	d0,-(sp)
		bsr	LOAD_PDX
		move.l	d0,d4

load_mdx30:
		exg	d1,d3			*MML���h���C�o�ɓ]������
		sub.l	d3,d1
		movea.l	a0,a1
		move.w	sr,-(sp)
		ori.w	#$0700,sr
		MADRV	#$01
		move.w	(sp)+,sr
		tst.l	d0
		bmi	load_mdx_buferr
		move.l	d4,d0
		bra	load_mdx90

load_mdx_loaderr:
		moveq	#-1,d0
		bra	load_mdx90
load_mdx_memerr:
		moveq	#-3,d0
		bra	load_mdx90
load_mdx_buferr:
		moveq	#-4,d0
load_mdx90:
		move.l	d0,d1
		move.l	d2,-(sp)		*MDX�̃��������J������
		bsr	FREE_MEM
		move.l	d1,d0
		unlk	a6
		movem.l	(sp)+,d1-d4/a0-a2
		rts


*==================================================
*PDX�t�@�C�������[�h����
*	LOAD_PDX(char *name, char *oldname)
*	name	�t�@�C����
*	oldname	�h���C�o����PDX�t�@�C����
*	d0.l -> ���Ȃ�A�G���[
*		-1 MDX���[�h�G���[
*		-2 PDX���[�h�G���[
*		-3 �������s��
*		-4 MDX�o�b�t�@�s��
*		-5 PCM�o�b�t�@�s��
*		-6 �t�H�[�}�b�g�G���[
*==================================================

		.offset	-256
pdx_name	.ds.b	256
		.text

LOAD_PDX:
		movem.l	d1-d4/a0-a2,-(sp)
		movem.l	(7+1)*4(sp),a1-a2
		link	a6,#-256

		moveq	#-1,d2			*PDX�o�b�t�@�|�C���^
		moveq	#0,d4			*�G���[�R�[�h

		lea	pdx_name(a6),a0		*PDX�t�@�C�������R�s�[
load_pdx10:
		move.b	(a1)+,(a0)+
		bne	load_pdx10
		lea	pdx_name(a6),a1

		pea	(a1)			*�����Ȃ�΁A�������Ȃ�
		pea	(a2)
		bsr	STRCMPI
		tst.l	d0
		beq	load_pdx90

load_pdx20:
		pea	ext_pdx(pc)		*�g���q���Ȃ���΂���
		pea	(a1)
		bsr	ADD_EXT

		movea.l	a1,a0			*TDX��������
		bsr	CHECK_TDX
		bne	load_pdx21
		bsr	LOAD_TDX		*TDX�����[�h����
		move.l	d0,d4
		bra	load_pdx90

load_pdx21:
		moveq	#-2,d4
		clr.l	-(sp)			*PDX�t�@�C����ǂݍ���
		pea	env_MADRV(pc)		*���ϐ�MADRV,mxp��T��
		pea	(a1)
		bsr	READ_FILE
		move.l	d0,d3
		bpl	load_pdx30
		addq.l	#1,d0
		beq	load_pdx90
		moveq	#-3,d4
		bra	load_pdx90

load_pdx30:
		moveq	#-5,d4
		move.l	a0,d2			*PDX���h���C�o�ɓ]������
		moveq	#0,d1
		MADRV	#$00
		move.l	d3,d1
		movea.l	d2,a1
		MADRV	#$00
		tst.l	d0
		bmi	load_pdx90
		moveq	#0,d4

load_pdx90:
		move.l	d2,-(sp)		*PDX�̃��������J������
		bsr	FREE_MEM
		tst.l	d4
		bpl	load_pdx91
		moveq	#0,d1			*�G���[��������
		MADRV	#$00			*�h���C�o�̃o�b�t�@����������
		MADRV	#$16			*�h���C�o����PDX��������
		tst.l	d0
		beq	load_pdx91
		movea.l	d0,a1
		clr.b	(a1)
load_pdx91:
		move.l	d4,d0
		unlk	a6
		movem.l	(sp)+,d1-d4/a0-a2
		rts


*==================================================
*�s�c�w�ǂݍ���
*	a0.l <- �t�@�C����
*==================================================

LOAD_TDX:
		movem.l	d1-d2/a0-a2,-(sp)
		moveq	#-1,d0
		movea.l	d0,a2

		clr.l	-(sp)			*TDX�t�@�C����ǂݍ���
		pea	env_MADRV(pc)		*���ϐ�MADRV,mxp��T��
		pea	(a0)
		bsr	READ_FILE
		lea	12(sp),sp
		move.l	d0,d2
		bmi	load_tdx_err
		movea.l	a0,a2

		MADRV	#$0c			*�h���C�o�̃o�b�t�@��TDX��W�J
		move.l	d0,a1
		bsr	TDX_LOAD
		bne	load_tdx_err

		moveq.l	#-1,d1			*PDX���X�^���o�C������
		MADRV	#$00
		moveq	#0,d0
		bra	load_tdx90

load_tdx_err:
		moveq	#-2,d0
load_tdx90:
		move.l	d0,d2
		pea	(a2)			*TDX�̃��������J��
		bsr	FREE_MEM
		addq.l	#4,sp
		move.l	d2,d0
		movem.l	(sp)+,d1-d2/a0-a2
		rts


*�t�@�C������TDX�Ȃ�EQU��Ԃ�
*	a0.l <- �t�@�C����

CHECK_TDX:
		movem.l	a0,-(sp)
		moveq	#0,d0
check_tdx10:
		tst.b	(a0)
		beq	check_tdx20
		lsl.l	#8,d0
		move.b	(a0)+,d0
		bra	check_tdx10
check_tdx20:
		andi.l	#$ffdfdfdf,d0
		cmpi.l	#'.TDX',d0
		movem.l	(sp)+,a0
		rts

*==================================================
*�y�c�e�t�@�C�������[�h����
*	LOAD_ZDF(char *name)
*	name	�t�@�C����
*	d0.l -> ���Ȃ�A�G���[
*		-1 MDX���[�h�G���[
*		-2 PDX���[�h�G���[
*		-3 �������s��
*		-4 MDX�o�b�t�@�s��
*		-5 PCM�o�b�t�@�s��
*		-6 �t�H�[�}�b�g�G���[
*==================================================

		.offset	-310
zdf_table	.ds.b	54
zoldpdx_name	.ds.b	256
		.text

LOAD_ZDF:
		movem.l	d1-d3/a0-a2,-(sp)
		move.l	(6+1)*4(sp),a0
		link	a6,#-310

		moveq	#-1,d1			*ZDF�o�b�t�@�|�C���^
		moveq	#-1,d2			*LZZ�o�b�t�@�|�C���^
		moveq	#-1,d3			*MDX�o�b�t�@�|�C���^

		lea	zoldpdx_name(a6),a2	*MADRV����PDX�����o�b�t�@�Ɏ���Ă���
		clr.b	(a2)			*(�w�b�_��͂�����ƕς���Ă��܂�����)
		MADRV	#$16
		tst.l	d0
		beq	load_zdf19
		movea.l	d0,a1
load_zdf10:
		move.b	(a1)+,(a2)+
		bne	load_zdf10
load_zdf19:

		pea	ext_zdf(pc)		*�g���q���Ȃ���΂���
		pea	(a0)
		bsr	ADD_EXT

		clr.l	-(sp)			*ZDF�t�@�C����ǂݍ���
		pea	env_MADRV(pc)		*���ϐ�MADRV,mxp��T��
		pea	(a0)
		bsr	READ_FILE
		tst.l	d0
		bmi	load_zdf_mdxloaderr
		move.l	a0,d1

		pea	zdf_table(a6)		*ZDF�f�[�^���I�[�v��
		move.l	d1,-(sp)
		bsr	OPEN_ZDF
		move.l	d0,d2
		bmi	load_zdf_mdxloaderr

		lea	zdf_table(a6),a0	*MDX�f�[�^�����邩���ׁA
		tst.w	(a0)+
		beq	load_zdf_mdxloaderr
		cmpi.w	#ZDF_MDX,(a0)
		beq	load_zdf20
		cmpi.w	#ZDF_MDR,(a0)
		bne	load_zdf_mdxloaderr

load_zdf20:
		clr.l	-(sp)			*����΁A�𓀂���
		move.l	6(a0),-(sp)
		move.l	2(a0),-(sp)
		move.l	d2,-(sp)
		bsr	EXTRACT_ZDF
		move.l	d0,d3
		bmi	load_zdf_mdxloaderr

		movea.l	d3,a1			*�w�b�_����͂���
		MADRV	#$05

		move.l	d0,-(sp)
		sub.l	zdf_table+8(a6),d1	*MML���h���C�o�ɓ]������
		neg.l	d1
		movea.l	a0,a1
		move.w	sr,-(sp)
		ori.w	#$0700,sr
		MADRV	#$01
		move.w	(sp)+,sr
		tst.l	d0
		bmi	load_zdf_mdxbuferr

		move.l	(sp)+,d0		*pdx�������
		beq	load_zdf90
		move.l	d2,-(sp)		*�]������
		pea	zdf_table(a6)
		pea	zoldpdx_name(a6)
		move.l	d0,-(sp)
		bsr	TRANS_ZPDX
		bra	load_zdf90

load_zdf_mdxbuferr:
		moveq	#-4,d0
		bra	load_zdf90

load_zdf_mdxloaderr:
		moveq	#-1,d0

load_zdf90
		movea.l	d0,a0
		move.l	d1,-(sp)		*ZDF�̃�������
		bsr	FREE_MEM
		move.l	d2,(sp)			*LZZ�̃�������
		bsr	FREE_MEM
		move.l	d3,(sp)			*MDX�̃��������J������
		bsr	FREE_MEM
		move.l	a0,d0
		unlk	a6
		movem.l	(sp)+,d1-d3/a0-a2
		rts


*==================================================
*�y�c�e���̂o�c�w���h���C�o�ɓ]������
*	TRANS_ZPDX(char *pdxname, char *oldname, short *zdftbl, void *lzz)
*	pdxname	pdx�t�@�C����
*	oldname	�h���C�o����PDX�t�@�C����
*	zdftbl	OPEN_ZDF�œ�����e�[�u��
*	lzz	lzz�����[�h����Ă���A�h���X
*	d0.l -> ���Ȃ�G���[
*==================================================

		.offset	-256
zpdx_name	.ds.b	256
		.text

TRANS_ZPDX:
		movem.l	d1-d2/a0-a3,-(sp)
		movem.l	(6+1)*4(sp),a0-a3
		link	a6,#-256

		moveq	#-1,d2			*PDX�̃o�b�t�@�|�C���^

		pea	(a0)			*�h���C�o����PDX�Ɠ����Ȃ牽�����Ȃ�
		pea	(a1)
		bsr	STRCMPI
		tst.l	d0
		beq	trans_zpdx90

		lea	zpdx_name(a6),a1	*PDX�t�@�C�������R�s�[
trans_zpdx10:
		move.b	(a0)+,(a1)+
		bne	trans_zpdx10
		lea	zpdx_name(a6),a1

		pea	ext_pdx(pc)		*�g���q������
		pea	(a1)
		bsr	ADD_EXT

trans_zpdx20:
		move.w	(a2)+,d0		*ZDF����PDX�����邩���ׂ�
		beq	trans_zpdx30
trans_zpdx21:
		cmpi.w	#ZDF_MDX+ZDF_PCM,(a2)
		beq	trans_zpdx40
		cmpi.w	#ZDF_MDR+ZDF_PCM,(a2)
		beq	trans_zpdx40
		lea	10(a2),a2
		subq.w	#1,d0
		bne	trans_zpdx21

trans_zpdx30:
		clr.l	-(sp)			*�Ȃ���΃t�@�C�������[�h����
		pea	(a1)
		bsr	LOAD_PDX
		bra	trans_zpdx90

trans_zpdx40:
		clr.l	-(sp)			*����Ή𓀂���
		move.l	6(a2),-(sp)
		move.l	2(a2),-(sp)
		pea	(a3)
		bsr	EXTRACT_ZDF
		move.l	d0,d2
		bmi	trans_zpdx_loaderr

		moveq	#0,d1			*�h���C�o�ɓ]������
		MADRV	#$00
		move.l	6(a2),d1
		movea.l	d2,a1
		MADRV	#$00
		tst.l	d0
		bpl	trans_zpdx90
		moveq	#-5,d0
		bra	trans_zpdx90

trans_zpdx_loaderr:
		moveq	#-2,d0
trans_zpdx90:
		exg	d0,d2			*PDX�̃o�b�t�@���J������
		move.l	d0,-(sp)
		bsr	FREE_MEM
		tst.l	d2
		bpl	trans_zpdx91
		moveq	#0,d1			*�G���[��������
		MADRV	#$00			*�h���C�o�̃o�b�t�@����������
		MADRV	#$16			*�h���C�o����PDX��������
		tst.l	d0
		beq	load_pdx91
		movea.l	d0,a0
		clr.b	(a0)
trans_zpdx91:
		move.l	d2,d0
		unlk	a6
		movem.l	(sp)+,d1-d2/a0-a3
		rts


		.data
env_MADRV:	.dc.b	'MADRV',0
		.dc.b	'mxp',0,0
ext_mdx		.dc.b	'.mdx',0
ext_pdx		.dc.b	'.pdx',0
ext_zdf:	.dc.b	'.zdf',0
		.text


*==================================================
* MADRV ���t�J�n
*==================================================

MADRV_PLAY:
		MADRV	#$02
		rts


*==================================================
* MADRV ���t���f
*==================================================

MADRV_PAUSE:
		MADRV	#$03
		rts


*==================================================
* MADRV ���t�ĊJ
*==================================================

MADRV_CONT:
		MADRV	#$04
		rts


*==================================================
* MADRV ���t��~
*==================================================

MADRV_STOP:
		MADRV	#$1C
		rts


*==================================================
* MADRV �t�F�[�h�A�E�g
*==================================================

MADRV_FADEOUT:
		move.l	d1,-(sp)
		moveq	#10,d1
		MADRV	#$17
		MADRV	#$09
		move.l	(sp)+,d1
		rts


*==================================================
* MADRV �X�L�b�v
*	d0.w <- �X�L�b�v�J�n�t���O
*==================================================

MADRV_SKIP:
		movem.l	d1-d2,-(sp)
		tst.w	d0
		beq	madrv_skip90
		moveq	#5,d1
		moveq	#$60,d2
		MADRV	#$1e		*���[�v
madrv_skip90:
		movem.l	(sp)+,d1-d2
		rts


*==================================================
* MADRV �X���[
*	d0.w <- �X���[�J�n�t���O
*==================================================

MADRV_SLOW:
		movem.l	d1,-(sp)
		movea.l	MA_BUF(a6),a0		* MADRV �̌��݂̃e���|
		lea	TEMPO(a0),a0
		move.b	SLOW_TEMPO(a6),d1	* �X���[���̃e���|

		tst.w	d0
		beq	madrv_slow50

		tst.b	d1			* �X���[���J�n���鎞��
		beq	madrv_slow10
		cmp.b	(a0),d1			* �e���|���ς��������
		beq	madrv_slow90
madrv_slow10:
		move.b	(a0),d0			* �e���|��x������(1/2�ɂ���)
		move.b	d0,ORIG_TEMPO(a6)
		lsr.b	#2,d0
		addq.b	#1,d0
		move.b	d0,(a0)
		move.b	d0,SLOW_TEMPO(a6)
		bra	madrv_slow90

madrv_slow50:
		tst.b	d1			* �X���[��Ԃ�
		beq	madrv_slow90
		cmp.b	(a0),d1			* ���e���|���ς���ĂȂ����
		bne	madrv_slow90
		move.b	ORIG_TEMPO(a6),(a0)	* �ۑ����Ă������e���|�ɖ߂�
		clr.b	SLOW_TEMPO(a6)

madrv_slow90:
		movem.l	(sp)+,d1
		rts

		.end



�n�o�l���W�X�^�ݒ�l�̋��ߕ�

(1) �v���O�������e

  �g���b�N���[�N(�Ȍ�TWA�Ɨ�����)��PROGRAM_PTR�������A�h���X�ɁA���F�f�[�^��(MADRV.MAN��
�����ꂽ�t�H�[�}�b�g�̏�Ԃ�)�i�[����Ă��܂��BPROGRAM_PTR�͔j�󂵂č\���܂���B�ʏ��
NIL��ݒ肵�ANIL�ȊO�ɂȂ������V�K�v���O�����ł���ƔF�����鎖���ł��܂��B

(2) �e�`�����l���̉���

  �v���O�������e���邢�́AVOLUMEMAP(TWA)�ƁAMA_LFOX5(TWA)��ʃo�C�g�ENOWVOLUME(TWA)��ʃo�C�g
FADELVL(TWA)��ʃo�C�g�̍��v�����݂̉��ʂł��B

(3) �e�`�����l���̃p���|�b�g

  NOWPAN(TWA)�̏��2bit���p���|�b�g���ł��B

(4) �L�[�I�����

  KEYONFLAG(TWA)��$00:�L�[�I�t $FF:�L�[�I���̃X�e�[�^�X���e���Ԃ�܂��B�܂��AKEYONWORK(TWA)��
$FF���A�L�[�I���u�Ԃɏ������܂��̂ŁA�L�[�I���^�C�~���O�����o�������ł��܂��i���o�������
KEYONWORK���N���A���āA���̃L�[�I�����o���ɔ����ĉ������j�B�܂��A�X���b�g�}�X�N��KEYONSIGNE
(TWA)��OPM�֏������܂��L�[�I���f�[�^���̂��̂������Ă��܂��B


�l�c�w�X�e�[�^�X�̋��ߕ�

(1) ����

  KEYCODE(TWA)+PR_PITCH(TWA)+MP_LFOX6(TWA).H�̍��v�����݂̉����ł��BKEYCODE(TWA)�ɂ̓f�`���[��
��񂪊܂܂�Ă��܂��B�����ȉ��������o���������́APCMKEY(TWA)���Q�Ƃ��ĉ������B

(2) ����

  NOWVOLX(TWA)��0�`15/-128�`-1�̒l������܂��B���̒l��v�R�}���h�A@v�R�}���h�̃p�����[�^
���̂��̂��ݒ肳��Ă��܂��B

(3) LFO�p�����[�^

  �V�X�e�����[�N(�Ȍ�SWA�Əȗ�)�́ANEWHLFO�Łu�V�����n�[�h�E�G�ALFO���v���ݒ肳�ꂽ����
�\�����܂��B���ۂ̃n�[�h�E�G�ALFO�̃I���E�I�t�́AEVENTWORK(TWA)���Q�Ƃ��Ă��������B
�܂��ANOW_LFREQ�`NOW_AMD(SWA)�ɂ�OPM�ɐݒ肷��l���̂��̂��i�[����Ă��܂��B������y�R
�}���h��AMH�R�}���h�Őݒ肳�ꂽ���e�𕡎ʂ������̂ł��B


�e���x���̉��

TRKPTR		ds.l	1	�g���b�N���P�[�V�����J�E���^	($????????)

�@mml���V�[�P���X����s�x�ɃC���N�������g����A��̃t���[������������Ə����߂����
�X�g���[���|�C���^�ł��B���ߎ��s�̓s�x�ɑ�����̂ł͂Ȃ��A����Ă��ǂ܂Ƃ߂ĕω�����̂ŁA
���A���^�C���ɒǏ]���Ă��A����قǈӖ��͂���܂���B

TRACKACT	ds.b	1	�g���b�N�A�N�e�B�r�e�B		($00/$FF)

�@�g���b�N���X���[�v��ԂɂȂ��$ff���������܂�A���̃V�[�P���X���s�Ȃ��܂���B

TRACKSIGNAL	ds.b	1	�g���b�N�ԒʐM�t���O		($00/$FF)

�@$ff���������܂��ƁA�X���[�v��ԂɂȂ�܂��B������TRACKACT�ƈ���āA�������
�������鎖���ł��܂��B�܂��A�킴�Ǝ�M�҂��ɂ��āA�\�t�g�E�G�A�O�����牉�t�J�n��
�C�Ӄu���b�N���؂�o���čs�Ȃ��Ƃ������|�����ł��܂��i����͉��������ɗp���镨�ŁA
1.10�Ńt�@���N�V�����R�[�������܂��BFFT�p�b�P�[�W�����s���ĊJ�����ł��j�B

PCMBANK		ds.l	1	PCM�p�o���N���W�X�^		($00??????)

�@pcm�p�[�g��@�R�}���h���g���ƁA����ɉ����ăw�b�_�A�h���X��ύX����ׂ̒l��������
�ݒ肳��܂��B������PCM�̃o���N�i���o�[�́A����������o�����A��q�̃��A���^�C��
�v���O�����i���o�[���Q�Ƃ������������I�ł��B

KEYCODE		ds.l	1	�L�[				($0000�`$17FF)

�@�L�[�R�[�h�{�f�`���[���������ɐݒ肳��܂��B�L�[�R�[�h�̓L�[�I���f�B���C�Ɋ֌W�Ȃ�
���[�h����܂����A�f�`���[���͎��ۂɃL�[�I������܂Ń��[�h����܂���B

KEYDETUNE	ds.l	1	�f�`���[���ݒ�l		($8000�`$7FFF)

�@�f�`���[���̐ݒ�l�ł��B�������MML�ɓ������đ����ɕω����܂��B

PR_PITCH	ds.l	1	�|���^�����g���݃s�b�`		($8000�`$7FFF)

�@�|���^�����g�ψڂ��L���ł���΁A�����ɂ��̃s�b�`�����[�h����܂��B

PR_MPITCH	ds.l	1	�|���^�����g�s�b�`		($E800�`$17FF)

�@�|���^�����g�ψڂ��̂��̂����[�h����܂��B0�Ȃ�|���^�����g�͓��삵�Ă��܂���B

WASKEY		ds.w	1	�ȑO�̃L�[�l			($0000�`$17FF)

�@�ߋ��̉����ł��B�����Ŏg�p���܂��B

NOWVOLUME	ds.w	1	���݂̃{�����[��		($0000�`$7F00)

�@���݂̉��ʂŁA0.75db�P�ʂ̌����ʂł��B

WAS_VOL		ds.w	1	�ߋ��̃{�����[��		($0000�`$7F00)

�@�ߋ��̉��ʂŁA�����Ŏg�p���܂��B

VOLUMESETJOB	ds.l	1	���ʐݒ���������A�h���X	($????????)

�@���ʐݒ菈���ւ̃|�C���^�ł��B�����Ŏg�p���܂��B

VOLUMEMAP	ds.b	4	�{�����[���ݒ�l�}�b�v		($00.4�`$7F.4)

�@�e�X���b�g���̌����ʂł��B���ۂ�OPM�ɐݒ肳���l�́ANOWVOLUME�ɂ����S���ꂼ���
�a���A�������܂�܂��B

MPLFOJOB	ds.l	1	���������A�h���X		($????????)

�@LFO�����A�h���X�|�C���^�ł��B�����Ŏg�p���܂��B

MPLFOJOB2	ds.l	1					($????????)

�@LFO�����A�h���X�|�C���^�ł��B�����Ŏg�p���܂��B

MALFOJOB	ds.l	1	

�@LFO�����A�h���X�|�C���^�ł��B�����Ŏg�p���܂��B

MALFOJOB2	ds.l	1

�@LFO�����A�h���X�|�C���^�ł��B�����Ŏg�p���܂��B

MP_LFOX0	ds.l	1	LFO�p���[�N�G���A

  LFO���[�N�G���A�ł��B�����Ŏg�p���܂��B

MP_LFOX1	ds.l	1

  LFO���[�N�G���A�ł��B�����Ŏg�p���܂��B

MP_LFOX2	ds.l	1

  LFO���[�N�G���A�ł��B�����Ŏg�p���܂��B

MP_LFOX3	ds.l	1

  LFO���[�N�G���A�ł��B�����Ŏg�p���܂��B

MP_LFOX4	ds.l	1

  LFO���[�N�G���A�ł��B�����Ŏg�p���܂��B

MP_LFOX5	ds.l	1

  LFO���[�N�G���A�ł��B�����Ŏg�p���܂��B

MP_LFOX6	ds.l	1

  ���ۂɉ����ɉ��Z�����l����ʃ��[�h�Ƀ��[�h����܂��B���ʃ��[�h�͏����_�ȉ��̐����ł��B

MA_LFOX0	ds.w	1	LFO�p���[�N�G���A

  LFO���[�N�G���A�ł��B�����Ŏg�p���܂��B

MA_LFOX1	ds.w	1

  LFO���[�N�G���A�ł��B�����Ŏg�p���܂��B

MA_LFOX2	ds.w	1

  LFO���[�N�G���A�ł��B�����Ŏg�p���܂��B

MA_LFOX3	ds.w	1

  LFO���[�N�G���A�ł��B�����Ŏg�p���܂��B

MA_LFOX4	ds.w	1

  LFO���[�N�G���A�ł��B�����Ŏg�p���܂��B

MA_LFOX5	ds.w	1

  ���ۂɉ��ʂɉ��Z�����l����ʃo�C�g�Ƀ��[�h����܂��B���ʃo�C�g�͏����_�ȉ��̐����ł��B

PCMFREQPAN	ds.w	1	PCM���g���E����		(IOCS _ADPCMOUT�ɏ�����)

�@PCM�p�[�g�̃��[�g�E�ʑ��ł��B

KEYOFGATE2	ds.l	1	�����e�[�u���ւ̃|�C���^	($????????)

�@�Q�[�g�^�C���e�[�u���ւ̃|�C���^�ł��B�����Ŏg�p���܂��B

PROGRAM_PTR	ds.l	1	�v���O�����ւ̃|�C���^		($????????)

�@�v���O�����i���F�f�[�^�j�ւ̃|�C���^�ł��BMADRV���삻�̂��̂ɂ͊֗^���܂���B

SEQDELTA	ds.b	1	�V�[�P���X�E�f���^�^�C�}�[	($00�`$FF)

�@��������邽�߂̃^�C�}�[�ł��B

MH_SYNC		ds.b	1	�V���N���L��(�S�̂�)		($00/$20)

  LFO�V���N���f�[�^�ł��B

MH_AMSPMS	ds.b	1	PMS/AMS(���F��)		($00�`$FF)

�@�n�[�h�E�G�ALFO�p�����[�^�̂ЂƂł��B

LFODELAY	ds.b	1	LFO�f�B���C			($00�`$FF)

  LFO����܂ł̃f�B���C�^�C�����i�[����܂��B0�Ńt���^�C��LFO�ł��B

LFODELTA	ds.b	1	LFO�^�C�}�[			($00�`$FF)

�@LFO�f�B���C�^�C�����J�E���g����^�C�}�[�ł��B

LFOACTIVE	ds.b	1	LFO�A�N�e�B�x�[�g		($00/$FF)

  LFO�����삷���$ff�ƂȂ�܂��B

LFOMOTOR	ds.b	1	LFO���[�^�[			($00/$01)

  LFO�����삷���$00�ƂȂ��ăJ�E���g�_�E�����֎~���܂��B

MPMOTOR		ds.b	1	MP���[�^�[			($00/$01)

  �|���^�����gLFO������֎~�E���삳���܂�($01�œ���)

MAMOTOR		ds.b	1	MA���[�^�[			($00/$01)

  �A���v���`���[�hLFO������֎~�E���삳���܂�($01�œ���)

KEYONDELAY	ds.b	1	�L�[�I���E�f�B���C		($00�`$FF)

�@�L�[�I���܂ł̃f�B���C�^�C�������[�h����܂��B

KEYONDELTA	ds.b	1	�L�[�I���E�^�C�}�[		($00�`$FF)

�@�L�[�I���܂ł̃f�B���C�^�C�����J�E���g����^�C�}�[�ł��B

KEYONMOTOR	ds.b	1	�L�[�I���E���[�^�[		($00/$FF)

�@�L�[�I�������$00�ƂȂ��ăJ�E���g�_�E�����֎~���܂��B

KEYOFGATE	ds.b	1	�L�[�I�t�E�Q�[�g�^�C��(@q�p)	($00�`$08/$80�`$FF)

�@�L�[�I�t�܂ł̃Q�[�g�^�C�������[�h����܂��B

KEYOFDELTA	ds.b	1	�L�[�I�t�E�^�C�}�[		($00�`$FF)

�@�L�[�I�t�܂ł̃Q�[�g�^�C�����J�E���g����^�C�}�[�ł��B

KEYOFMOTOR	ds.b	1	�L�[�I�t�E���[�^�[		($00/$FF)

�@�L�[�I�t������$00�ƂȂ��ăJ�E���g�_�E�����֎~���܂��B

KEYONSIGNE	ds.b	1	�L�[�I�����ɏ������ޓ��e	(??)

�@�L�[�I������OPM�ɏ������ޓ��e�����[�h����Ă��܂��B

NOWFLCON	ds.b	1	FL&CON				(??)

�@���݂̃t�B�[�h�o�b�N���x���E�A���S���Y�����w�肳��Ă��܂��B

NOWPAN		ds.b	1	���݂̃p���|�b�g		(??)

�@���݂̃p���|�b�g�ł��B

NOWVOLX		ds.b	1	���݂̉���			($00�`$0F/$80�`$FF)

�@���݂�MML�w�艹�ʂ��i�[����܂��B

PCMKEY		ds.b	1	PCM�p�L�[�R�[�h		($00�`$5F)

�@PCM�p�̃L�[�R�[�h�ŁA0�`95�͈̔́i��؂̏����_�ȉ����������Ȃ��j���̂ł��B

WASPCMPAN	ds.b	1	�ߋ���PCM�p���|�b�g		(??)

�@�ߋ���PCM�p���|�b�g���œ����Ŏg�p���܂��B

KEYONFLAG	ds.b	1	�L�[�I���t���O			($00/$FF)

�@�L�[�I��������$ff�ƂȂ�A��d�ɃL�[�I�������̂�}�����܂��B

CURPROG		ds.b	1	�J�����g�v���O�����ԍ�		($00�`$FF)

�@���݂̃v���O�����ԍ����w�肵�܂��B

CURPROGNEW	ds.b	1	�V�K�v���O�����Z�b�g�w��	($00/$FF)

  $ff���������܂��ƁACURPROG�ɏ]���ĉ��F���Z�b�g���܂��B

KEYONWORK	ds.b	1	�L�[�I���^�C�~���O�ǂݏo��	($FF)

�@�L�[�I���̓s�x��$ff���������܂�܂��B

EVENTWORK	ds.b	1	LFO�C�x���g			��2

�@LFO��Ԃ�ON/OFF�����s�x�ɐݒ肳��܂��B

PROGRAM_BANK	ds.l	256	�v���O�����p�e�[�u��

�@���F�Q�T�U�����L�[�v����|�C���^�e�[�u���ł��B

TO_MMLPTR	ds.l	1	MML�̈�ւ̃|�C���^		($????????)

�@MML�f�[�^�̈�ւ̃|�C���^�ł��B

TO_PCMPTR	ds.l	1	PCM�̈�ւ̃|�C���^		($????????)

  PCM�f�[�^�̈�ւ̃|�C���^�ł��B

LEN_MMLPTR	ds.l	1	MML�̈�̒���			($????????)

  MML�̈�̒����ł��B

LEN_MMLDATA	ds.l	1	MML�̎��ۂɓ����Ă���f�[�^��	($????????)

  MML�̎����ʂ������Ă��܂��B

LEN_PCMPTR	ds.l	1	PCM�̈�̑傫��		($????????)

  PCM�̈�̒����ł��B

PLAYFLAG	ds.l	1	���t��ԃt���O			(b0�`b15�Ɋe�g���b�N����)

  ���t��Ԃ�32bit���ꂼ��ɓ����Ă��܂��B

ONPCMFLAG	ds.b	1	PCM�����邩�H			($FF:PCM����)

  PCM�������$ff���ݒ肳��܂��B

ONMMLFLAG	ds.b	1	MML�͂��邩�H			($FF:MML����)

  MML�������$ff���ݒ肳��܂��B

STOP_SIGNAL	ds.b	1	��~�V�O�i��			($FF:��~����J�n)

  ��~����w�����s�Ȃ��ׂ̂��̂ŁA�����Ŏg�p���܂��B

PAUSE_MARK	ds.b	1	��~���t���O			($FF:��~)

  ��~���Ă���Ԃ�$ff���Z�b�g����܂��B

PCMFNAME	ds.b	128	PCM�t�@�C����			(ASCII)

  PCM�t�@�C�����������Ă��܂��B

FADEP		ds.w	1	�t�F�[�h�A�E�g�s�b�`		($0000�`$FFFF)

  �t�F�[�h�A�E�g���x������܂��B

FADEPITCH	ds.w	1	�s�b�`���[�^�[			($0000�`$FFFF)

  �����Ŏg�p���܂��B

FADELVL		ds.w	1	�t�F�[�h�A�E�g���x��		($0000�`$7FFF/$8000)

  �����Ŏg�p���܂��B

WAS_VCT0	ds.l	1	�e��x�N�^�ۑ�			($????????)
WAS_VCT1	ds.l	1
WAS_VCT2	ds.l	1
WAS_VCTA	ds.l	1
WAS_VCTB	ds.l	1
WAS_VCTC	ds.l	1
WAS_VCTD	ds.l	1
NEW_VCT0	ds.l	1	���ۂ̏����A�h���X
NEW_VCT1	ds.l	1
NEW_VCT2	ds.l	1
NEW_VCTA	ds.l	1
NEW_VCTB	ds.l	1
NEW_VCTC	ds.l	1
NEW_VCTD	ds.l	1

  �ȏ�̓��e�͐�΂ɕύX���Ă͂Ȃ�܂���B

MAXTRACK	ds.w	1	�ő�g���b�N			(0�`31)

  ���݉��t���Ă���f�[�^�̍ő�g���b�N��������܂��B

NOWCLOCK	ds.l	1	�O���N���b�N�o��		($????????)

�@���݂̃N���b�N��������܂��B

TO_MMLPTR2	ds.l	1	MDX�̈�ւ̃|�C���^		($????????)

  MDX�̈�ւ̃|�C���^���Ԃ�܂��B�����Ŏg�p���܂��B

TO_PCMPTR2	ds.l	1	PCM�̈�ւ̃|�C���^		($????????)

  PCM�̈�ւ̃|�C���^���Ԃ�܂��B�����Ŏg�p���܂��B

INT_VCT		ds.l	1	�C���^���v�g�x�N�^		($????????)

  �ύX���Ă͂Ȃ�܂���B

ATPCMPTR	ds.l	1	�\���΍�			($????????)

  �ύX���Ă͂Ȃ�܂���B

ADPCM_BUSY	ds.b	1	�m�C�Y���XADPCM�h���C�u���[�N

  PCM����t���O�B

ADPCM_Y0	ds.b	1

  PCM���[�N�B

ADPCM_FREQ	ds.b	1

  PCM���[�g�B

ADPCM_PAN	ds.b	1

  PCM�ʑ��B

EX_PCM2		ds.b	1	EX-PCM�t���O			($00/$FF/$01/$02)

  PCM8�풓��Ԃ�����܂��B$00:��풓 $FF:�ƂĂ��Â�PCM8 $01:������ƌÂ�PCM8 $02:����O��PCM8

TEMPO		ds.b	1	�e���|�ێ��p			(??)

  �e���|��Ԃ��Ԃ�܂��B�ύX����ƃf�b�h���b�N���鋰�ꂪ����܂��B

EX_PCM		ds.b	1	EX-PCM�t���O			($00/$FF/$01/$02)

  PCM8�풓��Ԃ�����܂��B$00:��풓 $FF:�ƂĂ��Â�PCM8 $01:������ƌÂ�PCM8 $02:����O��PCM8

STOPFLAG	ds.b	1	��~���}�[�N			(�����g�p)

  ��~�t���O�B�����Ŏg�p���܂��B

EXOPKEY1	ds.b	1	�L�[�{�[�h����t���O		(�����R�[�h)

  �L�[�{�[�h�p�t���O�B�����Ŏg�p���܂��B

GRAM_SELECT	ds.b	1	GRAM�g�p���t���O

  �ύX���Ă͂Ȃ�܂���B

UNREMOVE_FLAG	ds.b	1	�풓�����֎~�t���O

  �ύX���Ă͂Ȃ�܂���B

KEYCTRLFLAG	ds.b	1	�L�[�{�[�h����֎~�t���O

  �ύX���Ă͂Ȃ�܂���B

WAS_VCTI	ds.l	1	TRAP #4�p�ۑ��x�N�^		($????????)

  �ύX���Ă͂Ȃ�܂���B

TRACKMASK	ds.l	1	�g���b�N�}�X�N			(b31�`b0:tr31�`tr0)

  �ύX���Ă͂Ȃ�܂���B

LED_COUNTER	ds.w	1	LED�p�J�E���^			($????)

  �ύX���Ă͂Ȃ�܂���B

MMLTITLE	ds.b	512	MML�̃^�C�g��			(ASCII)

  MDX�f�[�^�̃^�C�g����ASCII�����񂪊i�[����܂��B

DENDMASK	ds.l	1	�f�[�^�G���h�t���O		(b31�`b0:tr32�`tr0)

  �ύX���Ă͂Ȃ�܂���B

FADEPM		ds.w	1	�t�F�[�h�A�E�g			($????)

  �ύX���Ă͂Ȃ�܂���B

INTMASK		ds.w	1	���荞�݃}�X�N���W�X�^		(�����R�[�h)

  �ύX���Ă͂Ȃ�܂���B

LOOP_FLAG	ds.w	1	���[�v�t���O			($????)

  ���[�v�񐔂�����܂��B

NOW_WAVEFORM	ds.b	1	�n�[�h�E�G�ALFO WAVEFORM	(OPM�ɏ�����)
NOW_LFREQ	ds.b	1	LFREQ
NOW_PMD		ds.b	1	PMD
NOW_AMD		ds.b	1	AMD

  �n�[�h�E�G�ALFO��Ԓl�ł��B

NEWFILE		ds.b	1	���[�N�G���A�������t���O	($FF:������)

  �V�����t�@�C�����Z�b�g�����ƁA$FF���������܂�܂��B

NEWHLFO		ds.b	1	�n�[�h�E�G�ALFO�V�K�ݒ�	($FF:�ݒ�)

  �V����LFO�f�[�^���Z�b�g������$FF���������܂�܂��B


