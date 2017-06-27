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


		.include	iocscall.mac
		.include	doscall.mac
		.include	MMDSP.h
		.include	DRIVER.h


*==================================================
* MLD �G���g���[�e�[�u��
*==================================================

		.xdef	MLD_ENTRY

FUNC		.macro	entry
		.dc.w	entry-MLD_ENTRY
		.endm

MLD_ENTRY:
		FUNC	MLD_CHECK
		FUNC	MLD_NAME
		FUNC	MLD_INIT
		FUNC	MLD_SYSSTAT
		FUNC	MLD_TRKSTAT
		FUNC	MLD_GETMASK
		FUNC	MLD_SETMASK
		FUNC	MLD_FILEEXT
		FUNC	MLD_FLOADP
		FUNC	MLD_PLAY
		FUNC	MLD_PAUSE
		FUNC	MLD_CONT
		FUNC	MLD_STOP
		FUNC	MLD_FADEOUT
		FUNC	MLD_SKIP
		FUNC	MLD_SLOW


*==================================================
* MLD ���[�J�����[�N�G���A
*==================================================

		.offset	DRV_WORK
MLD_SYSBUF	.ds.l	1
MLD_TRKBUF	.ds.l	32
		.text


*==================================================
* MLD �\���̒�`
*==================================================

*�l�k�c�R�[��

_KILL		equ	$00
_MML_ADR	equ	$01
_MML_SIZE	equ	$02
_MML_SET	equ	$03
_PCM_ADR	equ	$04
_PCM_SIZE	equ	$05
_PCM_SET	equ	$06
_TIMER_START	equ	$07
_TIMER_STOP	equ	$08
_PLAY		equ	$09
_STOP		equ	$0A
_MSK_SET	equ	$0B
_MSK_RESET	equ	$0C
_MSK_REQ	equ	$0D
_G_STATUS	equ	$0E
_PLYADB		equ	$0F
_NOTE		equ	$10
_G_PCCH		equ	$11
_F_OUT		equ	$12
_STATUS		equ	$13
_ATDAT		equ	$14
_AUTO_PLY1	equ	$15
_AUTO_PLY2	equ	$16
_AUTO_PLY3	equ	$17
_APLY_END	equ	$18
_APLY_STOP	equ	$19
_APLY_CONT	equ	$1A
_COUNT		equ	$1B
_CONT		equ	$1C
_LOOP		equ	$1D
_MIDIW		equ	$1E
_JUMP		equ	$1F
_NAME_ADR	equ	$20
_WORK		equ	$21
_VERSION	equ	$22
_MML_VER	equ	$23
_KILL_OFF	equ	$24
_KILL_ON	equ	$25
_VSET		equ	$26
_FO_SPD		equ	$27
_MAX_TRK	equ	$28
_DEV_ID		equ	$29
_REPLAY		equ	$2A
_GET_PART	equ	$2B
_KEYSWT		equ	$2C
_TRKWAIT	equ	$2D
_TRKWAITFLG	equ	$2E
_PDN_SET	equ	$2F
_OPMSWT		equ	$30
_MMLEXI		equ	$31
_KEYCTRLSWT	equ	$32
_FOUTFLG	equ	$33
_APFLG		equ	$34
_GRAMUSE	equ	$35
_ADPCMUSE	equ	$36
_PCM8USE	equ	$37
_MDBOARD	equ	$38
_MDUSE		equ	$39
_MDTIE		equ	$3A
_PAUSE		equ	$3B
_JUMPSWT	equ	$3C
_JUMPFLG	equ	$3D
_DRVOCU		equ	$3E
_MDWAIT		equ	$3F
_CM64_INIT	equ	$40
_SC_INIT	equ	$41
_U110_INIT	equ	$42
_TRKLEN		equ	$43
_PROG_SET	equ	$44
_PROG_FREE	equ	$45
_INTMSK		equ	$46
_INTMSK_SET	equ	$47
_OPMA_SET	equ	$48
_ZPD_SET	equ	$49
_MDINIT		equ	$4A
_TRKWORK_INIT	equ	$4B
_PCMMSK		equ	$4C
_END		equ	$4D
_OFSSIZE	equ	$4E

MLD		.macro	callname
		moveq.l	#callname,d0
		trap	#4
		.endm

*�V�X�e�����[�N

		.offset	0

STARTADR:	ds.l	1	; mld �풓�擪�A�h���X
OPMVCT:		ds.l	1	; �x�N�^���A�h���X�ޔ��ꏊ
TRAP4VCT:	ds.l	1
DMADVCT:	ds.l	1
DMADERRVCT:	ds.l	1
IOCS60VCT:	ds.l	1
IOCS62VCT:	ds.l	1
IOCS64VCT:	ds.l	1
IOCS67VCT:	ds.l	1
TRAP2VCT:	ds.l	1

MMLADR:		ds.l	1	; MML �o�b�t�@�擪�A�h���X
MMLSIZE:	ds.l	1	; �@�@�@�@�@�@�T�C�Y
MMLSETSIZE:	ds.l	1	; �@�@�f�[�^���]���T�C�Y
PCMADR:		ds.l	1	; PCM �o�b�t�@�擪�A�h���X
PCMSIZE:	ds.l	1	; �@�@�@�@�@�@�T�C�Y
PCMSETSIZE:	ds.l	1	; �@�@�f�[�^���]���T�C�Y
	ds.l	1	; �g���p�\��
VDATABUF:	ds.l	1	; ���F�f�[�^�o�b�t�@�E�A�h���X
TITLE:		ds.l	1	; �^�C�g���@�@�@�i�[�̈�擪�A�h���X
PCMF:		ds.l	1	; PCM �t�@�C�����@�@�@�@�@�@�@�@�@�@

FIFO_START:	ds.l	1	; �e�h�e�n�֘A
FIFO_END:	ds.l	1
FIFO_IN:	ds.l	1
FIFO_OUT:	ds.l	1
FIFO_IMASK:	ds.b	1
MIDIW_BUF:	ds.b	1

VERSION:	ds.w	1	; mld �o�[�W�����R�[�h

SYSFLG:		ds.w	1	; ���p�t���O�i���g�p�j

MMLVER:		ds.w	1	; MML �o�[�W�����R�[�h
FO_SPD1:	ds.w	1	;* �t�F�[�h�A�E�g�J�E���^�i�Œ�j�@�R�}���h���C���w��
FO_SPD2:	ds.w	1	;* �@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�@���ۂɎg�p�������
PLAYFLG:	ds.l	1	; �v���C�t���O
DENDFLG:	ds.l	1	; �f�[�^�I�[�ʉ߃t���O
MASKFLG:	ds.l	1	; �}�X�N�t���O
RTFLG:		ds.l	1	; ���Y���g���b�N�t���O�i�q�s�j
CH_TBL:		ds.b	32	; �g�p�`�����l��
REPLAYFLG:	ds.l	1	;* �ĉ��t����g���b�N

LOOPCOUNT:	ds.w	1	;* ���[�v�J�E���^
CLOCK:		ds.l	1	;* �N���b�N�J�E���^

OPMSWT:		ds.b	1	;* �n�o�l���荞�݃X�C�b�`�i$00����/$FF�֎~�j
MMLEXI:		ds.b	1	; MML ���݃t���O
KEYSWT:		ds.b	1	;* �L�[�{�[�h�R���g���[���r�v�s�i$00�L��/$FF�����j
FOUTFLG:	ds.b	1	;* �t�F�[�h�A�E�g���s���
APFLG:		ds.b	1	; �I�[�g�v���C���s���
GRAMUSE:	ds.b	1	; G-RAM �g�p�t���O
ADPCMUSE:	ds.b	1	; ADPCM �g�p���
PCM8USE:	ds.b	1	; PCM8 �g�p���

MDBOARD:	ds.b	1	; MIDI �{�[�h��ԁi$00�Ȃ�/$FF�����j
MDUSE:		ds.b	1	; MIDI �g�p���
MDTIE:		ds.b	1	; MIDI �^�C���[�h
PAUSE:		ds.b	1	; �|�[�Y���
JUMPSWT:	ds.b	1	;* �W�����v�R�[���r�v�s�i$00����/$FF�֎~�j
JUMPFLG:	ds.b	1	; �W�����v���s���
DRVOCU:		ds.b	1	;* ��L���
MDWAIT:		ds.b	1	;* �m�[�g�I�����̂e�h�e�n�o�b�t�@�]���҂�

KEYFLG1:	ds.b	1	; �L�[���쒆�t���O�i�m�[�}�����j
KEYFLG2:	ds.b	1	; �@�@�@�@�@�@�@�@�i�I�[�g�v���C���j

MAXTRK:		ds.b	1	; �ő�g���b�N���|�P
DEV:		ds.b	1	; �f�o�C�X�h�c
TEMPO:		ds.b	1	; �ʏ�̃e���|�l
TEMPOFLG:	ds.b	1	; �e���|�l�L�[���쒆�t���O
JUMP_COUNT:	ds.b	1	;* �W�����v�J�E���^

OPM_FOEXIT:	ds.b	1	;* �t�F�[�h�A�E�g�I�����x��
PCM_FOEXIT:	ds.b	1	;*
MIDI_FOEXIT:	ds.b	1	;*

AP_PROG:	ds.l	1	;* �I�[�g�v���C�풓�v���O�����擪�A�h���X
AP_ADR:		ds.l	1	;* �@�@�@�@�@�@�I�t�Z�b�g�̈�擪�A�h���X
AP_PCMADR:	ds.l	1	;* �@�@�@�@�@�@PCM �f�[�^�A�h���X
AP_LOOPED:	ds.b	1	;* �@�@�@�@�@�@���胋�[�v�񐔓��B�t���O
		ds.b	1	; �g���p�\��
AP_PTR:		ds.w	1	;* �@�@�@�@�@�@�I�t�Z�b�g�|�C���^�m�n�v
AP_NEXT:	ds.w	1	;* �@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�m�d�w�s
AP_MAX:		ds.w	1	;* �@�@�@�@�@�@�@�@�@�@�@�@�@�@�@�l�`�w
AP_LOOP:	ds.w	1	;* �@�@�@�@�@�@���[�v��
AP_BRANK:	ds.w	1	;* �@�@�@�@�@�@�u�����N�^�C��

PROG_ADR:	ds.l	1	;* �T�u�v���O�����E�擪�A�h���X
INTMSK:		ds.w	1	; ���荞�݃}�X�N���x���i�r�q�j
INTMSKLV:	ds.b	1
OLDTEMPO:	ds.b	1	; �ŐV�̃e���|�l

MDINIT:		ds.b	1	; �l�h�c�h�������f�[�^���M�i$00����/$FF�֎~�j
MH_NEW:		ds.b	1	;* �n�[�h�k�e�n�V�K�ݒ�t���O
MH_WF:		ds.b	1	; �@�@�@�@�@�@�n�o�l���W�X�^���
MH_LFRQ:	ds.b	1
MH_PMD:		ds.b	1
MH_AMD:		ds.b	1
PCMMSK:		ds.b	1	; �o�b�l�}�X�N
PCM8CALL:	ds.b	1	; �o�b�l�W�R�[���`��

WAITSIGN:	ds.b	32	; �����M���t���O
OFSSIZE:	ds.b	1	; �I�t�Z�b�g�E�T�C�Y
		ds.b	1	; �g���p�\��

		.text

*�g���b�N���[�N

		.offset	0
flg:		ds.w	1	; +$00	* �e��t���O�i���g�p�j
tieflg:		ds.b	1	; +$02	* �^�C�t���O
vcenum:		ds.b	1	; +$03	* ���F�ԍ��^PCM�o���N�ԍ�
trkadr:		ds.l	1	; +$04	* ���݂� MML �A�h���X
trkmdl:		ds.b	1	; +$08	* �g�p���W���[���i0=MIDI,1=OPM,2=PCM�j
trkch:		ds.b	1	; +$09	* �@�@�`�����l��
lcounter:	ds.b	1	; +$0A	* �N���b�N�J�E���^�ikey on�j
qcounter:	ds.b	1	; +$0B	* �@�@�@�@�@�@�@�@�iq cmd �j
vceadr:		ds.l	1	; +$0C	* ���F�A�h���X
pcmbank:	ds.l	1	; +$10	* �o�b�l�o���N�A�h���X
VCEvol:		ds.w	1	; +$14	* ���F�{�����[��
Vvol:		ds.w	1	; +$16	* ���C���{�����[��
vvol:		ds.w	1	; +$18	* �{�����[��
acvol:		ds.w	1	; +$1A	* �A�N�Z���g���̌��s�l�ޔ��ꏊ
TRKvol:		ds.w	1	; +$1C	* �g���b�N�{�����[��
folvl:		ds.w	1	; +$1E	* �t�F�[�h�A�E�g�E�f�v�X
fospd:		ds.w	1	; +$20	* �@�@�@�@�@�@�@�@�J�E���^
note:		ds.w	1	; +$22	* �m�[�g,�g�����X�|�[�Y,�f�`���[�� �g�[�^���l�iOPM�̂݁j
ntbuf:		ds.b	16	; +$24	* KeyOn �����m�[�g���X�g�b�N
ntval:		ds.w	1	; +$34	* �@�@�@�@�@�m�[�g��
keyon_dly:	ds.b	1	; +$36	* �L�[�I���f�B���C
keyon_dlypr:	ds.b	1	; +$37	* 
detune:		ds.w	1	; +$38	* �f�`���[��
port:		ds.l	1	; +$3A	* �|���^�����g�E�f�v�X
portval:	ds.l	1	; +$3E	* �@�@�@�@�@�@�@�@�@�@�g�[�^��
port2:		ds.l	1	; +$42	* �|���^�����g�Q�E�f�v�X
port2val:	ds.l	1	; +$46	* �@�@�@�@�@�@�@�@�@�@�@�g�[�^��
opmvol:		ds.w	1	; +$4A	* OPM �{�����[�����v�l
trans:		ds.b	1	; +$4C	* �g�����X�|�[�Y
qcmd:		ds.b	1	; +$4D	* q �R�}���h
pcmstatus:	dc.b	0
pcmvol:		ds.b	1	; +$4F	* �o�b�l�{�����[��
pcmhz:		ds.b	1	; +$50	* �@�@�@���g��
pan:		ds.b	1	; +$51	* �p���|�b�g
midivelo:	ds.b	1	; +$52	* MIDI�x���V�e�B
confbl:		ds.b	1	; +$53	* CON , FBL
opmkon:		ds.b	1	; +$54	* �L�[�I�����ɏ������ޓ��e
rtflg:		ds.b	1	; +$55	* ���Y���g���b�N
koflg:		ds.b	1	; +$56	* �L�[�I����
keyon:		ds.b	1	; +$57	* �L�[�I������
keyon_work:	ds.b	1	; +$58	* �L�[�I���^�C�~���O�i�ǂݏo���p�j
pedal:		ds.b	1	; +$59	* �_���p�[�y�_���i$00/$7f�j
opmkc:		ds.b	1	; +$5A	* ���݂� KC
opmkf:		ds.b	1	; +$5B	* ���݂� KF
opmtl:		ds.l	1	; +$5C	* ���݂� TL
volcmd:		ds.b	1	; +$60	* �ŐV�̃{�����[���f�[�^
trkact:		ds.b	1	; +$61	* �g���b�N�A�N�e�B�u
trkmask:	ds.b	1	; +$62	* �g���b�N�}�X�N
efect:		ds.b	1	; +$63	* OPM�^���G�t�F�N�g�g�p���t���O
trkwait:	ds.b	1	; +$64	* �����M���ҋ@�t���O
acsent:		ds.b	1	; +$65	* �A�N�Z���g�����i���ʁj�t���O
	ds.b	1
apswt:		ds.b	1	; +$67	* MIDI�I�[�g�p���g�p���
midivol:	ds.w	1	; +$68	* MIDI���C���{�����[��
kf_total:	ds.w	1	; +$6A	* LFO , �|���^�����g �g�[�^���l�iOPM,MIDI�̂݁j
bend_range:	ds.w	1	; +$6C	* ���݂� BR �l
bend_set:	ds.w	1	; +$6E	* ���݂� BS �l
bend:		ds.w	1	; +$70	* �x���h�l�̕ۊ�
qtbladr:	ds.l	1	; +$72	* q �J�E���^�e�[�u���A�h���X
oldvvol:	ds.b	1	; +$76	* �ŐV�� vvol
oldVvol:	ds.b	1	; +$77	* �ŐV�� Vvol

mhswt:		ds.b	1	; +$78	* LFO �X�C�b�`
mvswt:		ds.b	1	; +$79
mpswt:		ds.b	1	; +$7A
maswt:		ds.b	1	; +$7B
mwswt:		ds.b	1	; +$7C
rvswt:		ds.b	1	; +$7D
ecswt:		ds.b	1	; +$7E
mzswt:		ds.b	1	; +$7F

lfoswt:		ds.b	1	; +$80	* LFO�X�C�b�`�iMZ,EC,RV,MW,MA,MP,MVorMODU,MH�j
regset1:	ds.b	1	; +$81	* ���W�X�^�ݒ薽��
regset2:	ds.b	1	; +$82
regset3:	ds.b	1	; +$83
fospd0:		ds.w	1	; +$84	; �g���b�N�P��FadeIn/Out�X�s�[�h
foadd:		ds.b	1	; +$86	; Fade In or Out
pcm8call:	ds.b	1	; +$87	; PCM8 �R�[���`���iFunc/IOCS�j

mv_job:		ds.l	1	; +$88
mp_job:		ds.l	1	; +$8C
ma_job:		ds.l	1	; +$90
mz_job:		ds.l	1	; +$94

mv_dly:		ds.b	1	; +$98	* MV/M �f�B���C�i�V���N���j
mp_dly:		ds.b	1	; +$99	* MP
ma_dly:		ds.b	1	; +$9A	* MA
mz_dly:		ds.b	1	; +$9B	* MZ
mv_dlypr:	ds.b	1	; +$9C
mp_dlypr:	ds.b	1	; +$9D
ma_dlypr:	ds.b	1	; +$9E
mz_dlypr:	ds.b	1	; +$9F

mh_snc:		ds.b	1	; +$A0	* MH SYNC
mh_pms:		ds.b	1	; +$A1	*    PMD,AMS

mv_val:		ds.l	1	; +$A2	* MV �f�v�X�E�g�[�^�� �^ ���W�����[�V����
mv_sval:	ds.l	1	; +$A6
mv_dep2pr:	ds.l	1	; +$AA
mv_dep2:	ds.l	1	; +$AE	*    �f�v�X�Q
mv_deppr:	ds.l	1	; +$B2
mv_dep:		ds.l	1	; +$B6	*    �f�v�X
mv_clcpr:	ds.w	1	; +$BA
mv_sclc:	ds.w	1	; +$BC	*    �J�E���^/2
mv_clc:		ds.w	1	; +$BE	*    �J�E���^
mv_wf:		ds.b	1	; +$C0	*    �E�F�[�u�E�t�H�[��
	ds.b	1

mp_val:		ds.l	1	; +$C2	* MP
mp_sval:	ds.l	1	; +$C6
mp_dep2pr:	ds.l	1	; +$CA
mp_dep2:	ds.l	1	; +$CE
mp_deppr:	ds.l	1	; +$D2
mp_dep:		ds.l	1	; +$D6
mp_clcpr:	ds.w	1	; +$DA
mp_sclc:	ds.w	1	; +$DC
mp_clc:		ds.w	1	; +$DE
mp_wf:		ds.b	1	; +$E0
	ds.b	1

ma_val:		ds.w	1	; +$E2	* MA
ma_sval:	ds.w	1	; +$E4
ma_dep2pr:	ds.w	1	; +$E6
ma_dep2:	ds.w	1	; +$E8
ma_deppr:	ds.w	1	; +$EA
ma_dep:		ds.w	1	; +$EC
ma_clcpr:	ds.w	1	; +$EE
ma_sclc:	ds.w	1	; +$F0
ma_clc:		ds.w	1	; +$F2
ma_wf:		ds.b	1	; +$F4
	ds.b	1

mz_val:		ds.w	1	; +$F6	* MZ
mz_sval:	ds.w	1	; +$F8
mz_dep2pr:	ds.w	1	; +$FA
mz_dep2:	ds.w	1	; +$FC
mz_deppr:	ds.w	1	; +$FE
mz_dep:		ds.w	1	; +$100
mz_clcpr:	ds.w	1	; +$102
mz_sclc:	ds.w	1	; +$104
mz_clc:		ds.w	1	; +$106
mz_wf:		ds.b	1	; +$108
mz_slot:	ds.b	1	; +$109	* MZ ��������X���b�g

mw_val:		ds.w	1	; +$10A	* MW �f�v�X�E�g�[�^���iTL��1/256�j
mw_deppr:	ds.w	1	; +$10C
mw_dep:		ds.w	1	; +$10E
mw_clcpr:	ds.w	1	; +$110
mw_0clc:	ds.w	1	; +$112
mw_clc:		ds.w	1	; +$114

opmrev_val:	ds.w	1	; +$116	* OPM�^�����o�[�u
opmrev_sval:	ds.w	1	; +$118
opmrev_pan:	ds.b	1	; +$11A
opmrev_clcpr:	ds.b	1	; +$11B
opmrev_clc:	ds.b	1	; +$11C
opmrev_dep:	ds.b	1	; +$11D

opmec_val:	ds.w	1	; +$11E	* OPM�^���G�R�[
opmec_sval:	ds.w	1	; +$120
opmec_pan:	ds.b	1	; +$122
opmec_clcpr:	ds.b	1	; +$123
opmec_clc:	ds.b	1	; +$124
opmec_dep:	ds.b	1	; +$125

bend_val:	ds.l	1	; +$126	* MIDI�x���h
bend_dep:	ds.w	1	; +$12A
bend_clcpr:	ds.w	1	; +$12C
bend_clc:	ds.w	1	; +$12E

apan_dep:	ds.b	1	; +$130	* MIDI�I�[�g�p��
apan_pan:	ds.b	1	; +$131
apan_clcpr:	ds.w	1	; +$132
apan_clc:	ds.w	1	; +$134

cmdjtbl:	ds.l	1	; +$136	* �R�}���h�̃e�[�u���A�h���X
mdljadr:	ds.l	1	; +$13A
vdattl:		ds.l	1	; +$13E	* ���݂̉��F�f�[�^�� TL
vdattl2:	ds.l	1	; +$142
volsetjob:	ds.l	1	; +$146	* �{�����[���ݒ�W���u�A�h���X
mzvolsetjob:	ds.l	1	; +$14A
		ds.b	18
		.text


*==================================================
* MLD �풓�`�F�b�N
*==================================================

MLD_CHECK:
		move.l	a0,-(sp)
		move.l	$24*4.w,a0
		cmp.l	#"  Ri",-16(a0)
		bne	not_keeped
		cmp.l	#"e'MI",-12(a0)
		bne	not_keeped
		cmp.l	#"DI  ",-8(a0)
		bne	not_keeped
		move.l	-4(a0),d0			*�o�[�W������
		cmpi.l	#$02240000,d0			*	�Q�D�R�U�ȏ�
		bcc	keeped
not_keeped:
		moveq.l	#-1,d0
keeped:
		move.l	(sp)+,a0
		rts

*==================================================
* MLD �h���C�o���擾
*==================================================

MLD_NAME:
		move.l	a0,-(sp)
		lea	name_buf(pc),a0
		move.l	a0,d0
		move.l	(sp)+,a0
		rts

name_buf:	.dc.b	'MLD',0
		.even


*==================================================
* MLD �h���C�o������
*==================================================

MLD_INIT:
		movem.l	d0-d3/a0,-(sp)
		moveq	#0,d1				*�V�X�e���o�b�t�@�擾
		MLD	_WORK
		move.l	d0,MLD_SYSBUF(a6)

		lea	MLD_TRKBUF(a6),a0		*�g���b�N�o�b�t�@�擾
		moveq	#1,d3
		moveq	#32-1,d2
mld_init10:
		move.w	d3,d1
		MLD	_WORK
		move.l	d0,(a0)+
		addq.w	#1,d3
		dbra	d2,mld_init10

		lea	TRACK_STATUS(a6),a0	*�g���b�N�ԍ�������
		moveq	#1,d0
mld_init20:
		move.b	d0,TRACKNO(a0)
		lea	TRST(a0),a0
		addq.w	#1,d0
		cmpi.w	#32,d0
		bls	mld_init20

		clr.l	TRACK_ENABLE(a6)
		move.w	#249,CYCLETIM(a6)
		move.w	#77,TITLELEN(a6)

		movem.l	(sp)+,d0-d3/a0
		rts


*==================================================
* MLD �V�X�e�����擾
*==================================================

MLD_SYSSTAT:
		movem.l	d0/a0,-(sp)

		movea.l	MLD_SYSBUF(a6),a0

		move.l	TITLE(a0),SYS_TITLE(a6)		*�^�C�g��
		move.w	LOOPCOUNT(a0),SYS_LOOP(a6)	*���[�v�J�E���^

		moveq	#0,d0
		move.b	TEMPO(a0),d0
		move.w	d0,SYS_TEMPO(a6)		*�e���|

		MLD	_PAUSE				*���t���t���O
		tst.b	d0
		bne	mld_sysstat10
		tst.l	PLAYFLG(a0)
		beq	mld_sysstat10
		moveq	#-1,d0
		bra	mld_sysstat11
mld_sysstat10:
		moveq	#0,d0
mld_sysstat11:	move.w	d0,PLAY_FLAG(a6)

		or.b	PAUSE(a0),d0
		seq	d0
		ext.w	d0
		move.w	d0,PLAYEND_FLAG(a6)


		movem.l	(sp)+,d0/a0

		rts


*==================================================
* MLD �X�e�[�^�X�擾
*==================================================

MLD_TRKSTAT:
		movem.l	d0-d3/d5/a0-a2,-(sp)

		movea.l	MLD_SYSBUF(a6),a0

		move.l	MASKFLG(a0),d3			*TRACK_ENABLE �擾
		not.l	d3
		and.l	PLAYFLG(a0),d3
		move.l	TRACK_ENABLE(a6),d0
		move.l	d3,TRACK_ENABLE(a6)
		eor.l	d3,d0
		move.l	d0,TRACK_CHANGE(a6)

		lea	MLD_TRKBUF(a6),a0
		lea	TRACK_STATUS(a6),a2
		moveq	#0,d2
		moveq	#32-1,d7
mld_trkstat10:
		movea.l	(a0)+,a1
		bsr	get_track
		lea	TRST(a2),a2
		addq.w	#1,d2
		dbra	d7,mld_trkstat10

		movem.l	(sp)+,d0-d3/d5/a0-a2
		rts

*	d2.w <- track no
*	d3.l <- track enable
*	d5.b    STCHANGE work
*	a1.l <- track buffer address
*	a2.l <- TRACK_STATUS address

get_track:
		moveq	#0,d5
		clr.l	STCHANGE(a2)

		move.b	trkmdl(a1),d0			*INSTRUMENT
		bne	get_track01
		moveq	#3,d0
get_track01:	cmp.b	INSTRUMENT(a2),d0
		beq	get_track10
		move.b	d0,INSTRUMENT(a2)
		bset	#0,d5
		moveq	#0,d1
		cmpi.b	#2,d0
		bne	get_track02
		moveq	#15,d1
get_track02:	move.w	d1,KEYOFFSET(a2)
get_track10:
		cmpi.b	#3,d0
		bne	get_track20
		bsr	get_trackMIDI
		bra	get_track30
get_track20
		bsr	get_trackFM
get_track30:
		move.b	d5,STCHANGE(a2)
		rts

get_trackFM:
		move.w	kf_total(a1),d0			*FM BEND
		add.w	detune(a1),d0
		asr.w	#2,d0
		cmp.w	BEND(a2),d0
		beq	get_trackFM10
		move.w	d0,BEND(a2)
		bset	#1,d5
get_trackFM10:
		moveq	#-1,d0				*FM PAN
		move.b	pan(a1),d0
		andi.b	#3,d0
		cmp.w	PAN(a2),d0
		beq	get_trackFM20
		move.w	d0,PAN(a2)
		bset.l	#2,d5
get_trackFM20:
		moveq	#0,d0
		move.b	vcenum(a1),d0
		cmp.w	PROGRAM(a2),d0			*FM PROGRAM
		beq	get_trackFM30
		move.w	d0,PROGRAM(a2)
		bset.l	#3,d5
get_trackFM30:
		btst	d2,d3				*FM KEYON
		beq	get_trackFM31
		tst.b	keyon_work(a1)
		beq	get_trackFM31
		clr.b	keyon_work(a1)
		move.b	#$01,KEYONCHANGE(a2)
		move.b	#$FE,KEYONSTAT(a2)
		bra	get_trackFM40
get_trackFM31:	btst	#0,KEYONSTAT(a2)		*FM KEYOFF
		bne	get_trackFM40
		tst.b	koflg(a1)
		bne	get_trackFM40
		move.b	#$01,KEYONCHANGE(a2)
		move.b	#$FF,KEYONSTAT(a2)
get_trackFM40:
		move.b	ntbuf(a1),d0			*FM KEYCODE
		cmp.b	KEYCODE(a2),d0
		beq	get_trackFM50
		move.b	#$01,KEYCHANGE(a2)
		move.b	d0,KEYCODE(a2)
get_trackFM50:
		move.w	opmvol(a1),d0			*FM VELOCITY
		cmpi.b	#2,INSTRUMENT(a2)
		bne	get_trackFM51
		move.b	pcmvol(a1),d0
get_trackFM51:	not.w	d0
		andi.w	#$7f,d0
		cmp.b	VELOCITY(a2),d0
		beq	get_trackFM90
		move.b	#$01,VELCHANGE(a2)
		move.b	d0,VELOCITY(a2)
get_trackFM90:
		rts


get_trackMIDI:
		move.w	bend(a1),d0			*MIDI BEND
		subi.w	#8192,d0
		cmp.w	BEND(a2),d0
		beq	get_trackMIDI10
		move.w	d0,BEND(a2)
		bset	#1,d5
get_trackMIDI10:
		moveq	#127,d0				*MIDI PAN
		and.b	pan(a1),d0
		cmp.w	PAN(a2),d0
		beq	get_trackMIDI20
		move.w	d0,PAN(a2)
		bset.l	#2,d5
get_trackMIDI20:
		moveq	#0,d0
		move.b	vcenum(a1),d0
		cmp.w	PROGRAM(a2),d0			*MIDI PROGRAM
		beq	get_trackMIDI30
		move.w	d0,PROGRAM(a2)
		bset.l	#3,d5
get_trackMIDI30:
		clr.b	KEYONCHANGE(a2)			*MIDI KEYON
		btst	d2,d3
		beq	get_trackMIDI31
		tst.b	keyon_work(a1)
		beq	get_trackMIDI31
		clr.b	keyon_work(a1)
		move.b	#$01,KEYONCHANGE(a2)
		move.b	#$FE,KEYONSTAT(a2)
		bra	get_trackMIDI40
get_trackMIDI31:btst	#0,KEYONSTAT(a2)		*MIDI KEYOFF
		bne	get_trackMIDI40
		tst.b	koflg(a1)
		bne	get_trackMIDI40
		move.b	#$01,KEYONCHANGE(a2)
		move.b	#$FF,KEYONSTAT(a2)
get_trackMIDI40:
		clr.b	KEYCHANGE(a2)			*MIDI KEYCODE
		move.b	ntbuf(a1),d0
		cmp.b	KEYCODE(a2),d0
		beq	get_trackMIDI50
		move.b	#$01,KEYCHANGE(a2)
		move.b	d0,KEYCODE(a2)
get_trackMIDI50:
		clr.b	VELCHANGE(a2)			*MIDI VELOCITY
		move.w	vvol(a1),d0
		subi.b	#127,d0
		neg.b	d0
		cmp.b	VELOCITY(a2),d0
		beq	get_trackMIDI90
		move.b	#$01,VELCHANGE(a2)
		move.b	d0,VELOCITY(a2)
get_trackMIDI90:
		rts


*==================================================
* MLD ���t�g���b�N����
*	d0 -> �g���b�N�t���O
*==================================================

MLD_GETMASK:
		move.l	a0,-(sp)
		move.l	MLD_SYSBUF(a6),a0
		move.l	MASKFLG(a0),d0
		not.l	d0
		move.l	(sp)+,a0
		rts


*==================================================
* MLD ���t�g���b�N�ݒ�
*	d1 <- �g���b�N�t���O
*==================================================

MLD_SETMASK:
		movem.l	d1-d2,-(sp)
		move.l	d1,d2
		beq	mld_setmask10
		not.l	d1
		beq	mld_setmask20
		MLD	_MSK_SET
		move.l	d2,d1
		MLD	_MSK_RESET
		bra	mld_setmask90
mld_setmask10:
		MLD	_MSK_SET
		bra	mld_setmask90
mld_setmask20:
		MLD	_MSK_RESET
mld_setmask90:
		movem.l	(sp)+,d1-d2
		rts


*==================================================
* MLD �g���q�e�[�u���A�h���X�擾
*	a0.l -> �e�[�u���A�h���X
*==================================================

MLD_FILEEXT:
		move.l	a0,-(sp)
		lea	ext_buf(pc),a0
		move.l	a0,d0
		move.l	(sp)+,a0
		rts

ext_buf:	.dc.b	_MDZ,'MDZ'
		.dc.b	_MDX,'MDX'
		.dc.b	_MDR,'MDR'
		.dc.b	_MDI,'MDI'
		.dc.b	_MDN,'MDN'
		.dc.b	_KMD,'KMD'
		.dc.b	_ZMD,'ZMD'
		.dc.b	_RCP,'RCP'
*		.dc.b	_R36,'R36'
		.dc.b	_MDF,'MDF'
		.dc.b	_ZDF,'ZDF'
		.dc.b	0
		.even


*==================================================
* MLD �f�[�^�t�@�C�����[�h�����t
*	a1.l <- �t�@�C����
*	d0.l -> ���Ȃ�G���[
*==================================================

MLD_FLOADP:
		move.l	d0,d1
		lea	mmlp_name(pc),a0		*MMLP�ŉ��t����
		bsr	CALL_PLAYER
		tst.l	d0
		bpl	mld_floadp90
		moveq	#12,d0

		cmpi.b	#_MDZ,d1
		bne	mld_floadp92
		lea	mlp_name(pc),a0			*MMLP���Ȃ����MLP�ŉ��t����
		bsr	CALL_PLAYER
		tst.l	d0
		bpl	mld_floadp90
		lea	mlpnone(pc),a0
		moveq	#12,d0
		bra	mld_floadp92

mld_floadp90:
		cmpi.w	#24,d0				*�G���[�ԍ��̕ϊ�
		bls	mld_floadp91
		moveq	#1,d0
mld_floadp91:
		move.b	errcnvtbl(pc,d0.w),d0
mld_floadp92:
		ext.w	d0
		ext.l	d0
		andi.w	#$007f,d0
		rts

mmlp_name:	.dc.b	'MMLP',0
mlp_name:	.dc.b	'MLP',0
mlpnone:	.dc.b	'MMLP / MLP',0

*			0   1   2   3   4   5   6   7   8   9
errcnvtbl:	.dc.b	$00,$01,$02,$02,$05,$06,$07,$08,$0a,$0d
*			10  11  12  13  14  15  16  17  18  19
		.dc.b	$01,$01,$01,$01,$01,$01,$01,$06,$0b,$0e
*			20  21  22  23  24
		.dc.b	$04,$01,$01,$10,$11
		.even


*==================================================
* MLD ���t�J�n
*==================================================

MLD_PLAY:
		move.l	d1,-(sp)
		moveq	#0,d1
		MLD	_PLAY
		move.l	(sp)+,d1
		rts


*==================================================
* MLD ���t���f
*==================================================

MLD_PAUSE:
		MLD	_STOP
		rts


*==================================================
* MLD ���t�ĊJ
*==================================================

MLD_CONT:
		MLD	_CONT
		rts


*==================================================
* MLD ���t��~
*==================================================

MLD_STOP:
		MLD	_END
		rts

*==================================================
* MLD �t�F�[�h�A�E�g
*==================================================

MLD_FADEOUT:
		MLD	_F_OUT
		rts


*==================================================
* MLD �X�L�b�v
*	d0.w <- �X�L�b�v�J�n�t���O
*==================================================

MLD_SKIP:
		tst.w	d0
		bne	mld_skip10
		andi.b	#0,$80e.w
		bra	mld_skip20
mld_skip10:
		move.b	#$0a,$80e.w		*CTRL+OPT2
mld_skip20:
		rts

*==================================================
* MLD �X���[
*	d0.w <- �X���[�J�n�t���O
*==================================================

MLD_SLOW:
		tst.w	d0
		bne	mld_slow10
		move.b	#0,$80e.w
		bra	mld_slow20
mld_slow10:
		move.b	#$06,$80e.w		*CTRL+OPT1
mld_slow20:
		rts

		.end

�Q�l:MLP/MMLP�̏I���R�[�h
 1:usage
 2:�t�@�C�����I�[�v���ł��܂���
 3:�`���I�[�v���ł��܂���		(���t�t�@�C��)
 4:���������s�����Ă��܂�
 5:�h���C�o�[���g�ݍ��܂�Ă��܂���
 6:�l�l�k�o�b�t�@�e�ʂ��s�����Ă��܂�
 7:�o�b�l�o�b�t�@�e�ʂ��s�����Ă��܂�
 8:�l�l�k�t�H�[�}�b�g���Ⴂ�܂�
 9:�l�h�c�h�{�[�h����������Ă��܂���
10:�o�b�t�@�Ƀf�[�^���Z�b�g����Ă��܂���
11:�Ȗ��͒�`����Ă��܂���
12:�s�q�`�o���O�͎g���Ă��܂���
13:���l���͈͂𒴂��܂���
14:�I�v�V�����w��Ɍ�肪����܂�
15:��L����Ă��܂��B�����ł��܂���
16:���̕s���̃G���[���������܂���
17:mld�̃o�[�W�������Ⴂ�܂��Bv2.41�ȏ���g�p���ĉ�����
18:�o�b�l�t�H�[�}�b�g���Ⴂ�܂�
�ȉ���mmlp�̂�
19:�ϊ��Ɏ��s���܂���
20:�`���I�[�v���ł��܂���		(CM6�t�@�C��)
23:�k�y�y�D�q�����s�ł��܂���
   �`���I�[�v���ł��܂���
24:�k�y�y�D�q�ŃG���[���������܂���



