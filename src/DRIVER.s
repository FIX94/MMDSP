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

		.include	doscall.mac
		.include	MMDSP.h
		.include	DRIVER.h


*==================================================
* DRIVER �e�[�u��
*==================================================

		.xref		MXDRV_ENTRY
		.xref		MADRV_ENTRY
		.xref		MLD_ENTRY
		.xref		RCD_ENTRY
		.xref		RCD3_ENTRY
		.xref		ZMUSIC_ENTRY
		.xref		MCDRV_ENTRY

driver_table:
		.dc.w	MXDRV_ENTRY-driver_table
		.dc.w	MADRV_ENTRY-driver_table
		.dc.w	MLD_ENTRY-driver_table
		.dc.w	RCD_ENTRY-driver_table
		.dc.w	RCD3_ENTRY-driver_table
		.dc.w	ZMUSIC_ENTRY-driver_table
		.dc.w	MCDRV_ENTRY-driver_table

*		�V���ȃh���C�o�ɑΉ�������ꍇ�A������
*		�G���g���[�e�[�u���̃A�h���X��ǉ�����
		dc.w	0


*==================================================
* DRIVER �풓�`�F�b�N
*	�풓���Ă���h���C�o���`�F�b�N����
*	DRV_MODE(a6) <- �w��h���C�o�ԍ� (0�Ȃ玩���I��)
*	d0.w -> �h���C�o�ԍ��i�O�Ȃ�풓���Ă��Ȃ��j
*	�Q�l: DRV_MODE(a6),DRV_ENTRY(a6)�ɂ��L�^����
*==================================================

SEARCH_DRIVER:
		movem.l	d1,-(sp)
		move.w	DRV_MODE(a6),d0
		beq	search_driver10

		cmpi.w	#RCD,d0			*RCD���[�h�w��̏ꍇ
		bne	search_driver01		*RCD3���T��
		moveq	#RCD3,d0
		bsr	check_driver
		bpl	search_driver30
		moveq	#RCD,d0
search_driver01:
		bsr	check_driver		*�h���C�o�w�肪����ꍇ
		bmi	search_driver90
		bra	search_driver30

search_driver10:
		moveq	#1,d1			*�h���C�o�����I���̏ꍇ
search_driver20:
		move.w	d1,d0
		bsr	check_driver
		beq	search_driver90
		bpl	search_driver30
		addq.w	#1,d1
		bra	search_driver20
search_driver30:
		bsr	make_driverjmp
		movem.l	(sp)+,d1
		rts
search_driver90:
		moveq	#0,d0
		movem.l	(sp)+,d1
		rts

*�h���C�o�풓�`�F�b�N
*	d0.w <- �h���C�o�ԍ�
*	d0.w -> �h���C�o�ԍ�(��:�풓���Ă��Ȃ� 0:�S�Ē��׏I�����)
*	a0.l -> �h���C�o�G���g���A�h���X

check_driver:
		movem.l	d1/a1,-(sp)
		lea	driver_table(pc),a0
		move.w	d0,d1
		subq.w	#1,d0
		bmi	check_driver90
		add.w	d0,d0
		move.w	(a0,d0.w),d0
		beq	check_driver90
		lea	(a0,d0.w),a0
		move.w	(a0),d0
		jsr	(a0,d0.w)
		tst.l	d0
		bmi	check_driver90
		move.w	d1,d0
check_driver90:
		movem.l	(sp)+,d1/a1
		rts

*�h���C�o�W�����v�e�[�u���쐬
*	d0.w <- �h���C�o�ԍ�
*	a0.l <- �h���C�o�G���g���A�h���X

make_driverjmp:
		movem.l	d0/a0-a2,-(sp)
		move.w	d0,DRV_MODE(a6)
		move.l	a0,DRV_ENTRY(a6)
		movea.l	a0,a2
		moveq	#DRIVER_CMDS-1,d1
		lea	DRIVER_JMPTBL(a6),a1
make_driverjmp10:
		moveq	#0,d0
		move.w	(a0)+,d0
		add.l	a2,d0
		move.l	d0,(a1)+
		dbra	d1,make_driverjmp10
		movem.l	(sp)+,d0/a0-a2
		rts


*==================================================
* DRIVER �X�e�[�^�X������
*	�S�Ẵg���b�N�̕ω��r�b�g�𗧂Ă�
*==================================================

STATUS_INIT:
		*�����DRIVER_TRKSTAT��refresh_sub���Ă�
		movem.l	d0-d1/a0-a1,-(sp)
		lea	DRIVER_JMPTBL+DRIVER_TRKSTAT*4(a6),a1
		move.l	(a1),REF_TRSTWORK(a6)
		lea	refresh_sub(pc),a0
		move.l	a0,(a1)

		lea	TRACK_STATUS+KEYONSTAT(a6),a0
		moveq	#0,d0
		moveq	#32-1,d1
status_init10:
		move.b	d0,(a0)
		lea	TRST(a0),a0
		dbra	d1,status_init10

		movem.l	(sp)+,d0-d1/a0-a1
		rts

refresh_sub:
		*�{�Ƃ̃��[�`���ɖ߂�
		move.l	REF_TRSTWORK(a6),DRIVER_JMPTBL+DRIVER_TRKSTAT*4(a6)
		DRIVER	DRIVER_TRKSTAT

		movem.l	d0/d7/a0-a1,-(sp)
		lea	TRACK_STATUS(a6),a0
		lea	CHST_BF(a6),a1
		moveq	#32-1,d7
		moveq	#-1,d0
refresh_sub10:
		move.b	d0,STCHANGE(a0)
		move.b	d0,KEYONCHANGE(a0)
		move.b	d0,KEYCHANGE(a0)
		move.b	d0,VELCHANGE(a0)
*		move.w	d0,KBS_CHG(a1)
		lea	TRST(a0),a0
		lea	CHST(a1),a1
		dbra	d7,refresh_sub10
		move.l	d0,TRACK_CHANGE(a6)

		movem.l	(sp)+,d0/d7/a0-a1
		rts


*==================================================
* DRIVER �L�[�I��������
*	�S�Ẵg���b�N���L�[�n�e�e����
*==================================================

CLEAR_KEYON:
		*�����DRIVER_TRKSTAT��keyoff_sub���Ă�
		movem.l	a0-a1,-(sp)
		lea	DRIVER_JMPTBL+DRIVER_TRKSTAT*4(a6),a1
		move.l	(a1),CLR_KEYONWORK(a6)
		lea	keyoff_sub(pc),a0
		move.l	a0,(a1)
		movem.l	(sp)+,a0-a1
		rts

keyoff_sub:
		movem.l	d7/a0,-(sp)
		lea	TRACK_STATUS(a6),a0
		moveq	#32-1,d7
keyoff_sub10:
		clr.b	STCHANGE(a0)
		st.b	KEYONCHANGE(a0)
		st.b	KEYONSTAT(a0)
		clr.b	KEYCHANGE(a0)
		clr.b	VELCHANGE(a0)
		lea	TRST(a0),a0
		dbra	d7,keyoff_sub10

		move.l	#-1,TRACK_CHANGE(a6)
		clr.l	TRACK_ENABLE(a6)

		*�{�Ƃ̃��[�`���ɖ߂�
		move.l	CLR_KEYONWORK(a6),DRIVER_JMPTBL+DRIVER_TRKSTAT*4(a6)

		movem.l	(sp)+,d7/a0
		rts


*==================================================
*�g���b�N�}�X�N
*==================================================

*�P�g���b�N�}�X�N���]
*	d1.w <- �g���b�N�ԍ�

TRMASK_CHG:
		movem.l	d0-d1,-(sp)
		DRIVER	DRIVER_GETMASK
		bchg.l	d1,d0
		move.l	d0,d1
		DRIVER	DRIVER_SETMASK
		movem.l	(sp)+,d0-d1
		rts

*�S�g���b�N�n�m

TRMASK_ALLON:
		move.l	d1,-(sp)
		moveq	#-1,d1
		DRIVER	DRIVER_SETMASK
		move.l	(sp)+,d1
		rts

*�S�g���b�N�n�e�e

TRMASK_ALLOFF:
		move.l	d1,-(sp)
		moveq	#0,d1
		DRIVER	DRIVER_SETMASK
		move.l	(sp)+,d1
		rts

*�S�g���b�N���]

TRMASK_ALLREV:
		movem.l	d0-d1,-(sp)
		DRIVER	DRIVER_GETMASK
		not.l	d0
		move.l	d0,d1
		DRIVER	DRIVER_SETMASK
		movem.l	(sp)+,d0-d1
		rts


*==================================================
*���ϐ�����T���ăI�[�v������
*	OPEN_FILE(char *name, char *env)
*	name	�t�@�C����
*	env	�T�[�`�p�X���ϐ����e�[�u��(0�Ȃ�T�[�`���Ȃ�)
*	d0.l -> �t�@�C���n���h��(���Ȃ�G���[)
*==================================================

		.offset	-512
env_buff	.ds.b	256
open_buff	.ds.b	256
		.text

OPEN_FILE:
		movem.l	a0-a4,-(sp)
		movem.l	(5+1)*4(sp),a1-a2
		link	a6,#-512

		clr.w	-(sp)			*�܂��J�����g��T��
		pea	(a1)
		DOS	_OPEN
		addq.l	#6,sp
		tst.l	d0
		bpl	open_file90

		move.l	a2,d0
		beq	open_file_err
open_file00:
		lea	dummy_form(pc),a3	*X68030�΍�(GETENV �� cpRESTORE (a3)�ɂȂ�)
		pea	env_buff(a6)		*�Ȃ���΁A���ϐ����T�[�`����
		clr.l	-(sp)
		pea	(a2)
		DOS	_GETENV
		lea	12(sp),sp
		tst.l	d0
		bmi	open_file_nextenv

		lea	env_buff(a6),a4
open_file10:
		tst.b	(a4)			*���ϐ����I���܂ňȉ����J��Ԃ�
		beq	open_file_nextenv
		lea	open_buff(a6),a3
open_file20:
		move.b	(a4),d0			*��؂蕶��( ,;| �X�y�[�X �^�u )
		beq	open_file30
		addq.l	#1,a4
		cmpi.b	#',',d0
		beq	open_file30
		cmpi.b	#';',d0
		beq	open_file30
		cmpi.b	#'|',d0
		beq	open_file30
		cmpi.b	#' ',d0
		beq	open_file30
		cmpi.b	#9,d0
		beq	open_file30
		move.b	d0,(a3)+		*������܂ŁA�p�X�����R�s�[
		bra	open_file20
open_file30:
		move.b	-1(a4),d0		*�p�X���̍Ōオ:��\�łȂ�������A
		cmpi.b	#':',d0
		beq	open_file40
		cmpi.b	#'\',d0	
		beq	open_file40
		move.b	#'\',(a3)+		*\��t������
open_file40:
		movea.l	a1,a0			*�t�@�C������t��������
open_file41:	move.b	(a0)+,(a3)+
		bne	open_file41

		pea	open_buff(a6)		*�f�B�X�N�������Ă�����
		bsr	CHECK_DRIVE
		addq.l	#4,sp
		tst.l	d0
		bmi	open_file10

		clr.w	-(sp)			*�I�[�v�����Ă݂�
		pea	open_buff(a6)
		DOS	_OPEN
		addq.l	#6,sp
		tst.l	d0
		bmi	open_file10
		bra	open_file90

open_file_nextenv:
		tst.b	(a2)+
		bne	open_file_nextenv
		tst.b	(a2)
		bne	open_file00

open_file_err:
		moveq	#-1,d0
open_file90:
		unlk	a6
		movem.l	(sp)+,a0-a4
		rts

dummy_form:	.dc.w	0


*==================================================
*�t�@�C�����N���[�Y����
*	CLOSE_FILE(short handle)
*	handle	�t�@�C���n���h��(���Ȃ�N���[�Y���Ȃ�)
*	d0.l -> �G���[�R�[�h
*==================================================

CLOSE_FILE:
		move.w	4(sp),d0
		ext.l	d0
		bmi	close_file90
		move.w	d0,-(sp)
		DOS	_CLOSE
		addq.l	#2,sp
close_file90:
		rts


*==================================================
*�f�B�X�N�������Ă��邩���ׂ�
*	CHECK_DRIVE(char *pathname)
*	pathname	�A�N�Z�X�������p�X��
*	d0.l -> ���Ȃ�A�N�Z�X�s��
*==================================================

CHECK_DRIVE:
		movea.l	4(sp),a0

		moveq	#0,d0			*�h���C�u�����Ȃ���΃J�����g���A
		cmpi.b	#':',1(a0)
		bne	check_drive10

		move.b	(a0),d0			*����΂��̃h���C�u�𒲂ׂ�
		andi.b	#$df,d0
		subi.b	#'A'-1,d0

check_drive10:
		move.w	d0,-(sp)
		DOS	_DRVCTRL
		addq.l	#2,sp
		btst.l	#2,d0
		sne	d0
		ext.w	d0
		ext.l	d0

		rts


*==================================================
*�t�@�C���̒����𒲂ׂ�
*	GET_FILELEN(short handle)
*	handle	�t�@�C���n���h��
*	d0.l -> �t�@�C���̒���(���Ȃ�G���[)
*==================================================

GET_FILELEN:
		movem.l	d1-d2,-(sp)
		move.w	(2+1)*4(sp),d0
		link	a6,#0

		move.w	#1,-(sp)		*���݂̈ʒu�𒲂�
		clr.l	-(sp)
		move.w	d0,-(sp)
		DOS	_SEEK
		move.l	d0,d1
		bmi	get_filelen90

		move.w	#2,6(sp)		*�t�@�C���̍Ō�֍s���Ĉʒu�𒲂ׂ�
		DOS	_SEEK
		move.l	d0,d2
		bmi	get_filelen90

		clr.w	6(sp)			*���̈ʒu�ւ��ǂ�
		move.l	d1,2(sp)
		DOS	_SEEK
		tst.l	d0
		bmi	get_filelen90

		move.l	d2,d0
get_filelen90:
		unlk	a6
		movem.l	(sp)+,d1-d2
		rts


*==================================================
*�t�@�C����ǂ�
*	READ_FILE(char *name, char *env, int ofst)
*	name	�t�@�C����
*	env	�T�[�`�p�X���ϐ����e�[�u��(0�Ȃ�T�[�`���Ȃ�)
*	ofst	�o�b�t�@�̐擪�ɂ���w�b�_�̑傫��
*	d0.l -> �ǂݍ��񂾒���(���Ȃ�G���[)
*		-1 ���[�h�G���[
*		-2 �������s��
*	a0.l -> �ǂݍ��񂾃|�C���^
*==================================================

READ_FILE:
		movem.l	d1-d3/a1-a3,-(sp)
		movem.l	(6+1)*4(sp),a1-a3
		link	a6,#0

		moveq	#-1,d2
		moveq	#-1,d3

		pea	(a2)			*�t�@�C�����I�[�v������
		pea	(a1)
		bsr	OPEN_FILE
		move.l	d0,d1
		bmi	read_file_loaderr

		move.w	d1,-(sp)		*�t�@�C���̒����𒲂�
		bsr	GET_FILELEN
		move.l	d0,d2
		bmi	read_file_loaderr

		pea	(a3,d2.l)		*���̕��̃��������m�ۂ���
		DOS	_MALLOC
		move.l	d0,d3
		bmi	read_file_memerr

		move.l	d2,-(sp)		*�t�@�C�����������ɓǂݍ���
		pea	(a3,d3.l)
		move.w	d1,-(sp)
		DOS	_READ
		cmp.l	d2,d0
		blt	read_file_loaderr
		bra	read_file90

read_file_memerr:
		move.l	d3,-(sp)
		bsr	FREE_MEM
		moveq	#-1,d3
		moveq	#-2,d2
		bra	read_file90

read_file_loaderr:
		move.l	d3,-(sp)
		bsr	FREE_MEM
		moveq	#-1,d3
		moveq	#-1,d2

read_file90:
		move.w	d1,-(sp)
		bsr	CLOSE_FILE

		move.l	d2,d0
		movea.l	d3,a0
		unlk	a6
		movem.l	(sp)+,d1-d3/a1-a3
		rts


*==================================================
*�g���q���Ȃ���΁A�f�t�H���g��t������
*	ADD_EXT(char *name, char *ext)
*	name	�t�@�C����
*	ext	�f�t�H���g�g���q
*	d0.l -> �G���[�R�[�h
*==================================================

		.offset -92
nameckbuf	.ds.b	92
		.text

ADD_EXT:
		movem.l	a0-a1,-(sp)
		movem.l	(2+1)*4(sp),a0-a1
		link	a6,#-92

		pea	nameckbuf(a6)			*�t�@�C�����𒲂�
		pea	(a0)
		DOS	_NAMECK
		tst.l	d0
		bmi	add_ext90

		tst.b	nameckbuf+86(a6)		*�g���q���Ȃ����
		bne	add_ext90

add_ext10:
		tst.b	(a0)+				*�f�t�H���g��ǉ�����
		bne	add_ext10
		subq.l	#1,a0
add_ext20:
		move.b	(a1)+,(a0)+
		bne	add_ext20

add_ext90:
		unlk	a6
		movem.l	(sp)+,a0-a1
		rts


*==================================================
*�啶��/�������̋�ʂȂ��ɕ�������r����
*	STRCMPI(char *str1, char *str2)
*	d0.l -> ��v������0
*==================================================

STRCMPI:
		movem.l	d1/a0-a1,-(sp)
		movem.l	(3+1)*4(sp),a0-a1

		moveq	#0,d0
strcmpi10:
		move.b	(a0)+,d0
		beq	strcmpi20
		andi.b	#$df,d0
		move.b	(a1)+,d1
		andi.b	#$df,d1
		sub.b	d1,d0
		beq	strcmpi10
		bra	strcmpi90

strcmpi20:
		move.b	(a1),d0

strcmpi90:
		movem.l	(sp)+,d1/a0-a1
		rts


*==================================================
*���������J������
*	FREE_MEM(void *ptr)
*	ptr	�������u���b�N�ւ̃|�C���^(���Ȃ�J�����Ȃ�)
*	d0.l -> �G���[�R�[�h
*==================================================

FREE_MEM:
		move.l	4(sp),d0
		bmi	free_mem90
		move.l	d0,-(sp)
		DOS	_MFREE
		addq.l	#4,sp
free_mem90:
		rts


*==================================================
*�y�c�e�f�[�^�̎g�p���J�n����
*	OPEN_ZDF(char *zdf, char *buf)
*	zdf	zdf�t�@�C���̃��[�h����Ă���A�h���X
*	buf	���e���W�J�����o�b�t�@(54bytes)
*	d0.l -> lzz�����[�h���ꂽ�A�h���X(���Ȃ�G���[)
*==================================================

OPEN_ZDF:
		movem.l	d1/a0-a2,-(sp)
		movem.l	(4+1)*4(sp),a0-a1
		link	a6,#0

		moveq	#-1,d1			*LZZ���[�h�|�C���^������

		cmpi.l	#'ZDF0',(a0)		*ZDF�t�@�C�����ǂ����`�F�b�N����
		bne	open_zdf_err
		cmpi.w	#$0d0a,4(a0)
		bne	open_zdf_err

		bsr	LOAD_LZZ		*LZZ�����[�h����
		move.l	d0,d1
		bmi	open_zdf_err

		pea	(a1)			* ref_data ���Ăяo��
		pea	(a0)
		movea.l	d1,a2
		jsr	_ref_data(a2)
		addq.l	#8,sp
		tst.l	d0
		bmi	open_zdf90
		move.l	d1,d0
		bra	open_zdf90

open_zdf_err:
		move.l	d1,-(sp)		*�G���[�Ȃ�LZZ���J������
		bsr	FREE_MEM
		moveq	#-1,d0

open_zdf90:
		unlk	a6
		movem.l	(sp)+,d1/a0-a2
		rts


*==================================================
*�y�c�e�f�[�^��W�J����
*	EXTRACT_ZDF(void *lzz, char *zdfdata, int len, int ofst)
*	lzz	lzz�����[�h����Ă���A�h���X
*	zdfdata	�f�[�^�擪�A�h���X
*	len	�W�J��̃T�C�Y
*	ofst	�o�b�t�@�̐擪�ɂ���w�b�_�̑傫��
*	d0.l -> �W�J�����o�b�t�@�̃A�h���X(���Ȃ�G���[)
*==================================================

EXTRACT_ZDF:
		movem.l	d1/a0-a3,-(sp)
		movem.l	(5+1)*4(sp),a0-a3
		link	a6,#0

		pea	(a2,a3.l)		* �W�J�p�o�b�t�@�m��
		DOS	_MALLOC
		move.l	d0,d1
		bmi	extract_zdf_err

		pea	(a3,d1.l)		* ext_data �Ăяo��
		pea	(a1)
		jsr	_ext_data(a0)
		addq.l	#8,sp
		tst.l	d0
		bmi	extract_zdf90
		move.l	d1,d0
		bra	extract_zdf90

extract_zdf_err:
		move.l	d1,-(sp)
		bsr	FREE_MEM
		moveq	#-1,d0

extract_zdf90:
		unlk	a6
		movem.l	(sp)+,d1/a0-a3
		rts


*==================================================
*�k�y�y�����[�h����
*	d0.l -> ���[�h�����A�h���X(���Ȃ�G���[)
*==================================================

		.offset -512
nambuf		.ds.b	256
cmdlin		.ds.b	256
		.text

LOAD_LZZ:
		movem.l	d1-d2/a0,-(sp)
		link	a6,#-512

		moveq	#-1,d2			*�o�b�t�@�|�C���^������

		lea	LzzName(pc),a0		*LZZ��
		bsr	load_lzzsub
		bpl	load_lzz10

		lea	LzmName(pc),a0		*LZM��T��
		bsr	load_lzzsub
		bmi	load_lzz90

load_lzz10:
		pea	$ffff.w			*�ő���������m�ۂ���
		DOS	_MALLOC
		andi.l	#$00ffffff,d0
		move.l	d0,d1
		move.l	d0,(sp)
		DOS	_MALLOC
		move.l	d0,d2
		bmi	load_lzz_err

		add.l	d2,d1			*���[�h����
		move.l	d1,-(sp)
		move.l	d2,-(sp)
		pea	nambuf(a6)
		move.b	#1,(sp)			*.r�^�C�v�w��
		move.w	#3,-(sp)
		DOS	_EXEC
		tst.l	d0
		bmi	load_lzz_err

		movea.l	d2,a0
		cmpi.l	#'LzzR',_LzzCheck(a0)	* �{����lzz���`�F�b�N����
		bne	load_lzz_err

		move.l	_LzzSize(a0),-(sp)	* �������u���b�N��K�v�ȑ傫���ɏk������
		pea	(a0)
		DOS	_SETBLOCK

		move.l	d2,d0
		bra	load_lzz90

load_lzz_err:
		move.l	d2,-(sp)
		bsr	FREE_MEM
		moveq	#-1,d0

load_lzz90:
		unlk	a6
		movem.l	(sp)+,d1-d2/a0
		rts


*�p�X����
*	a0.l <- �N���t�@�C����
*	d0.l -> ���Ȃ�G���[

load_lzzsub:
		movem.l	a0-a1,-(sp)
		lea	nambuf(a6),a1		* �N���t�@�C�������R�s�[
load_lzzsub10:
		move.b	(a0)+,(a1)+
		bne	load_lzzsub10

		clr.l	-(sp)			* �p�X����
		pea	cmdlin(a6)
		pea	nambuf(a6)
		move.w	#2,-(sp)
		DOS	_EXEC
		lea	14(sp),sp
		tst.l	d0
		movem.l	(sp)+,a0-a1
		rts

		.data
LzzName:	.dc.b	'lzz.r',0
LzmName:	.dc.b	'lzm.r',0
		.text


*********************************************************************
*
*
*	�s�c�w���[�_�[
*
*
*	A1:	PDX�f�[�^�o�b�t�@�i���邢�͓W�J��ւ́j�|�C���^
*	A2:	TDX�f�[�^�|�C���^
*	D1:	PDX�W�J��̑傫��
*	D2:	TDX�f�[�^��
*
*	RETURN	D0.L=0	*PCM�f�[�^�Ґ��ɐ���
*		  ����	*�Ґ��Ɏ��s����
*
		.offset	-($300+30)
TDX_ALLOCPTR	DS.L	1	*TDX�f�[�^�ւ̃|�C���^
TDX_ALLOCLEN	DS.L	1	*TDX�f�[�^�̒���
MAXBANK		DS.W	1	*�ő�o���N�y�[�W
CURBANK		DS.W	1	*���݂̃o���N�y�[�W
CURHEAD		DS.L	1	*���݂̃o���N�I�t�Z�b�g
PCM_ALLOCPTR	DS.L	1	*PCM�f�[�^���[�h��
PCM_ALLOCLEN	DS.L	1	*PCM�o�b�t�@�c��e��
PCM_HEADPTR	DS.L	1	*PCM�w�b�_�G���A�|�C���^
NOW_PCMFILE	DS.W	1	*���݃I�[�v�����Ă���PDX�t�@�C���̃n���h��
PDXBLOCK	DS.B	$300	*PDX�t�@�C���E�w�b�_�u���b�N
		.text

TDX_LOAD:
	MOVEM.L	D1-D7/A0-A6,-(SP)
	link	a6,#-($300+30)
	MOVE.L	A2,TDX_ALLOCPTR(A6)
	MOVE.L	D2,TDX_ALLOCLEN(A6)
	MOVE.L	A1,PCM_HEADPTR(A6)
	MOVE.L	A1,PCM_ALLOCPTR(A6)
	MOVE.L	D1,PCM_ALLOCLEN(A6)
	CLR.W	CURBANK(A6)
	CLR.L	CURHEAD(A6)
	MOVE.W	#-1,NOW_PCMFILE(A6)
*
*
*	#�Ŏn�܂�s�������閘�A�u�����L���O���s�Ȃ��B
*
*
TDX_LOADINIT:
	BSR	GETLINE			*�P�s���o�� A0=�|�C���^	D0=�t���O
	TST.L	D0
	BMI	TDX_ERROR1		*��������������������Ȃ��܂܃t�@�C�����I�����
	BSR	SKIPBRANK		*�u�����N�����񏜋�
	CMP.B	#"#",(A0)+
	BNE	TDX_LOADINIT
	BSR	SKIPBRANK		*�u�����N�����񏜋�
	BSR	TDXGETNUM		*�o���N�����o��
	MOVE.W	D0,D1
	MULU	#$300,D1
	BEQ	TDX_ERROR2		*�m�ۂ���Ӗ����Ȃ�
	SUB.L	D1,PCM_ALLOCLEN(A6)	*�w�b�_�p�Ƀ����������炷
	BCS	TDX_ERROR2		*�������s������������
	ADD.L	D1,PCM_ALLOCPTR(A6)	*�A���P�[�V�����o�b�t�@���m��
	MOVE.W	D0,MAXBANK(A6)		*�ő�o���N���ݒ�

	MOVE.L	PCM_HEADPTR(A6),A0	*�o���N�̈���N���A����
	LSR.L	#6,D1
	SUB.L	#1,D1
TDX_LOADINIT0:
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	CLR.L	(A0)+
	SUBQ.L	#1,D1
	BCC	TDX_LOADINIT0
TDX_LOADMAIN:
	BSR	GETLINE		*�P�s���o��
	TST.L	D0
	BMI	TDX_LOADQUIT	*���[�h�I��
	BSR	SKIPBRANK	*�u�����N�������΂�
	MOVE.B	(A0),D0
	BEQ	TDX_LOADMAIN	*��s
	CMP.B	#"+",D0
	BEQ	PDX_FILEOPEN	*PDX�t�@�C���I�[�v���w��
	CMP.B	#"@",D0
	BEQ	PDX_BANKSELECT	*�X�g�A�E�o���N�Z���N�g
	CMP.B	#"*",D0
	BEQ	PDX_TARGETBANK	*�^�[�Q�b�g�o���N�w��
	CMP.B	#";",D0
	BEQ	TDX_LOADMAIN	*�R�����g�s
	CMP.B	#"&",D0
	BEQ	PDX_MULTIASSIGN	*�}���`�A�T�C��
	CMP.B	#"N",D0
	BEQ	PDX_KEY		*���l�Ń��[�h����
	CMP.B	#"n",D0
	BEQ	PDX_KEY		*���l�Ń��[�h����
	CMP.B	#"A",D0
	BCS	TDX_ERROR3	*�V���^�b�N�X�G���[
	CMP.B	#"G"+1,D0
	BCS	PDX_KEY		*�A���t�@�x�b�g�Ń��[�h����
	CMP.B	#"a",D0
	BCS	TDX_ERROR3	*�V���^�b�N�X�G���[
	CMP.B	#"g"+1,D0
	BCS	PDX_KEY		*�A���t�@�x�b�g�w��Ń��[�h����
	BRA	TDX_ERROR3	*�V���^�b�N�X�G���[
*
*	�P�s���o���āA���̃|�C���^���A��
*
GETLINE:
	MOVE.L	TDX_ALLOCPTR(A6),A0	*�Y���s
*	MOVE.L	A0,REPORT_WORK
*
*	�X�L�b�v����
*
	PEA	(A1)
	MOVE.L	A0,A1
GETLINE_SKIP:
	SUBQ.L	#1,TDX_ALLOCLEN(A6)
	BMI	GETLINE_EOF		*�t�@�C���̏I���܂œǂݏo����(bcs -> bmi)
	TST.B	(A1)
	BEQ	GETLINE_EOF		*NUL����������EOF����
	CMP.B	#$0D,(A1)+
	BNE	GETLINE_SKIP
	CLR.B	-1(A1)			*$0D���������ꏊ��NUL�ɂ���
	ADDQ.W	#1,A1
	MOVE.L	A1,TDX_ALLOCPTR(A6)	*�ǂݏo�����ʒu��o�^���Ă���
	SUBQ.L	#1,TDX_ALLOCLEN(A6)	*(added)
	MOVE.L	(SP)+,A1
	MOVEQ.L	#0,D0
	RTS
GETLINE_EOF:
	MOVEQ.L	#-1,D0
	MOVE.L	(SP)+,A1
	RTS
*
*	�u�����N�����̃X�L�b�v
*
SKIPBRANK:
	CMP.B	#" ",(A0)
	BEQ	SKIPBRANK1		*�u�����N����
	CMP.B	#9,(A0)
	BEQ	SKIPBRANK1		*�u�����N����
	RTS
SKIPBRANK1:
	ADDQ.W	#1,A0
	BRA	SKIPBRANK
*
*	���l�����o��
*
*	���l=D0
*
TDXGETNUM:
	MOVEM.L	D1-D7/A1-A6,-(SP)
	MOVEQ.L	#0,D1
	MOVEQ.L	#0,D0
TDXGETNUM0:
	MOVE.B	(A0)+,D0
	SUB.B	#"0",D0
	BCS	TDXGETNUM_QUIT
	CMP.B	#9+1,D0
	BCC	TDXGETNUM_QUIT
	ADD.L	D1,D1	*2
	MOVE.L	D1,D2
	ADD.L	D1,D1	*4
	ADD.L	D1,D1	*8
	ADD.L	D2,D1	*10
	ADD.L	D0,D1
	BRA	TDXGETNUM0
TDXGETNUM_QUIT:
	MOVE.L	D1,D0
	MOVEM.L	(SP)+,D1-D7/A1-A6
	RTS
*
*	PDX�t�@�C���E�I�[�v������
*
PDX_FILEOPEN
	TST.W	NOW_PCMFILE(A6)
	BMI	PDX_FILEOPEN1
	MOVE.W	NOW_PCMFILE(A6),-(SP)	*�O�̃t�@�C���̓N���[�Y����
	DOS	_CLOSE
	ADDQ.W	#2,SP
PDX_FILEOPEN1:
	ADDQ.W	#1,A0
	BSR	SKIPBRANK		*�u�����N�������X�L�b�v����

*	PEA	(A1)
*	LEA	EXT2(PC),A1
*	BSR	FILE_SEARCH
*	MOVE.L	(SP)+,A1

*
	movem.l	a0-a1,-(sp)
	link	a6,#-128
	lea	-128(a6),a1
pdx_fileopen2:
	move.b	(a0)+,(a1)+
	bne	pdx_fileopen2
	pea	EXT2(pc)
	pea	-128(a6)
	bsr	ADD_EXT
	pea	env_MADRV(pc)
	pea	-128(a6)
	bsr	OPEN_FILE
	unlk	a6
	movem.l	(sp)+,a0-a1
*

	TST.L	D0
	BMI	TDX_ERROR4		*�t�@�C�����݂���Ȃ�

	MOVE.W	D0,NOW_PCMFILE(A6)	*�t�@�C���n���h���o�^
	MOVE.L	#$300,-(SP)		*��n�߂Ƀo���N�O��ǂݏo���Ă���
	PEA	PDXBLOCK(A6)
	MOVE.W	D0,-(SP)
	DOS	_READ
	LEA	10(SP),SP
	TST.L	D0
	BMI	TDX_ERROR5		*PCM�t�@�C���ǂݏo���G���[
	BRA	TDX_LOADMAIN
*
*	�^�[�Q�b�g�o���N�ύX
*
PDX_TARGETBANK:
	TST.W	NOW_PCMFILE(A6)
	BMI	TDX_ERROR6		*�t�@�C���I�[�v�����Ă��Ȃ�
	ADDQ.W	#1,A0
	BSR	SKIPBRANK
	BSR	TDXGETNUM		*�o���N�ԍ������o��

	MULU	#$300,D0
	CLR.W	-(SP)
	MOVE.L	D0,-(SP)
	MOVE.W	NOW_PCMFILE(A6),-(SP)
	DOS	_SEEK
	ADDQ.W	#8,SP
	TST.L	D0
	BMI	TDX_ERROR5		*�V�[�N�G���[

	MOVE.L	#$300,-(SP)		*�Y���o���N��ǂݏo���Ă���
	PEA	PDXBLOCK(A6)
	MOVE.W	NOW_PCMFILE(A6),-(SP)
	DOS	_READ
	LEA	10(SP),SP
	TST.L	D0
	BMI	TDX_ERROR5		*PCM�t�@�C���ǂݏo���G���[
	BRA	TDX_LOADMAIN
*
*	�X�g�A�o���N�E�ύX
*
PDX_BANKSELECT:
	ADDQ.W	#1,A0
	BSR	SKIPBRANK
	BSR	TDXGETNUM		*PDX�o���N���o��
	CMP.W	MAXBANK(A6),D0
	BPL	TDX_ERROR6		*�ő�o���N���𒴂���
PDX_BANKSELECT1:
	MOVE.W	D0,CURBANK(A6)		*�o���N�ԍ��ݒ�
	MULU	#$300,D0
	MOVE.L	D0,CURHEAD(A6)		*�o���N�I�t�Z�b�g�ݒ�
	BRA	TDX_LOADMAIN
*
*	�C�ӃL�[�����[�h���ď�������
*
PDX_KEY:
	BSR	GETKEYCODE
	TST.L	D0
	BMI	TDX_ERROR7		*�L�[�͈͂��ُ�
	MOVE.W	D0,D7			*D7=�X�g�A���ׂ��L�[�ԍ�
	BSR	SKIPBRANK
	CMP.B	#"=",(A0)+
	BNE	TDX_ERROR3		*�\���ُ�
	BSR	SKIPBRANK
	BSR	GETKEYCODE		*�ǂݏo����̃L�[�ԍ����o��
	TST.L	D0
	BMI	TDX_ERROR7		*�L�[�ԍ��ُ�
	MOVE.W	D0,D6			*�ǂݏo�������L�[�̔ԍ�

	TST.W	NOW_PCMFILE(A6)
	BMI	TDX_ERROR6		*�܂��t�@�C���I�[�v�����Ă��Ȃ�

	ADD.W	D0,D0			*word
	ADD.W	D0,D0			*longword
	ADD.W	D0,D0			*longword�~2

	LEA	PDXBLOCK(A6),A1
	ADD.W	D0,A1
	MOVE.L	(A1)+,D1		*D1=�t�@�C���I�t�Z�b�g
	MOVE.L	(A1)+,D2		*D2=�f�[�^��
	BEQ	TDX_ERROR8		*PCM�f�[�^�����݂��Ȃ�

	SUB.L	D2,PCM_ALLOCLEN(A6)
	BCS	TDX_ERROR2		*���������s������

	CLR.W	-(SP)			*�w���PCM�ʒu�փV�[�N����
	MOVE.L	D1,-(SP)
	MOVE.W	NOW_PCMFILE(A6),-(SP)
	DOS	_SEEK
	ADDQ.W	#8,SP
	CMP.L	D1,D0
	BNE	TDX_ERROR5		*�V�[�N�G���[

	MOVE.L	D2,-(SP)		*�f�[�^��
	MOVE.L	PCM_ALLOCPTR(A6),-(SP)	*���[�h�ʒu
	MOVE.W	NOW_PCMFILE(A6),-(SP)
	DOS	_READ
	LEA	10(SP),SP

	CMP.L	D2,D0
	BNE	TDX_ERROR5		*���ۂɓǂݏo���������ƈႤ
	MOVE.L	PCM_ALLOCPTR(A6),D3	*�������ɃX�g�A�����ʒu
	SUB.L	PCM_HEADPTR(A6),D3
	BMI	TDX_ERROR2		*�܂����肦�Ȃ����E�E

	ADD.L	D2,PCM_ALLOCPTR(A6)	*�|�C���^��i�߂�

	MOVE.L	PCM_HEADPTR(A6),A0
	ADD.L	CURHEAD(A6),A0		*�o���N�擪�A�h���X

	ADD.W	D7,D7
	ADD.W	D7,D7
	ADD.W	D7,D7

	TST.L	(A0,D7.W)
	BNE	TDX_ERROR9		*�Q�d��`
	TST.L	4(A0,D7.W)
	BNE	TDX_ERROR9

	MOVE.L	D3,(A0,D7.W)		*�f�[�^�|�C���^
	MOVE.L	D2,4(A0,D7.W)		*�f�[�^��
	BRA	TDX_LOADMAIN
*
*	���Ƀ��[�h�ς݂̃o���N����ăA�T�C�����s�Ȃ�
*
PDX_MULTIASSIGN:
	BSR	GETKEYCODE
	TST.L	D0
	BMI	TDX_ERROR7		*�L�[�͈͂��ُ�
	MOVE.W	D0,D7			*D7=�X�g�A���ׂ��L�[�ԍ�
	BSR	SKIPBRANK
	CMP.B	#"=",(A0)+
	BNE	TDX_ERROR3		*�\���ُ�
	BSR	SKIPBRANK
	BSR	TDXGETNUM
	MOVE.W	D0,D5			*�^�[�Q�b�g�o���N�ԍ�
	BSR	SKIPBRANK
	BSR	GETKEYCODE		*�ǂݏo����̃L�[�ԍ����o��
	TST.L	D0
	BMI	TDX_ERROR7		*�L�[�ԍ��ُ�
	MOVE.W	D0,D6			*�ǂݏo�������L�[�̔ԍ�

	MOVE.L	PCM_HEADPTR(A6),A0
	ADD.L	CURHEAD(A6),A0		*�o���N�擪�A�h���X
	ADD.W	D7,D7
	ADD.W	D7,D7
	ADD.W	D7,D7

	MOVE.L	PCM_HEADPTR(A6),A1
	CMP.W	MAXBANK(A6),D5
	BPL	TDX_ERROR6		*�ő�o���N���𒴂���
PDX_MULTI0:
	MULU	#$300,D5
	ADD.L	D5,A1			*�o���N�擪�A�h���X
	ADD.W	D6,D6
	ADD.W	D6,D6
	ADD.W	D6,D6

	TST.L	(A0,D7.W)
	BNE	TDX_ERROR9		*�Q�d��`
	TST.L	4(A0,D7.W)
	BNE	TDX_ERROR9

	TST.L	(A0,D6.W)
	BEQ	TDX_ERROR8		*�f�[�^�����݂��Ȃ�
	TST.L	4(A0,D6.W)
	BEQ	TDX_ERROR8

	MOVE.L	(A0,D6.W),(A0,D7.W)
	MOVE.L	4(A0,D6.W),4(A0,D7.W)
	BRA	TDX_LOADMAIN

ERROR	MACRO
	ENDM

TDX_ERROR1:
	ERROR	EM1
	MOVEQ.L	#-1,D0
	BRA	TDX_LOADFINAL		*�����������񂪂Ȃ�
TDX_ERROR2:
	ERROR	EM2
	MOVEQ.L	#-2,D0
	BRA	TDX_LOADFINAL		*���������s�����Ă���
TDX_ERROR3:
	ERROR	EM3
	MOVEQ.L	#-3,D0
	BRA	TDX_LOADFINAL		*�\������������
TDX_ERROR4:
	ERROR	EM4
	MOVEQ.L	#-4,D0
	BRA	TDX_LOADFINAL		*�t�@�C�����݂���Ȃ�
TDX_ERROR5:
	ERROR	EM5
	MOVEQ.L	#-5,D0
	BRA	TDX_LOADFINAL		*�t�@�C����ǂݏo�����G���[��������
TDX_ERROR6:
	ERROR	EM6
	MOVEQ.L	#-6,D0
	BRA	TDX_LOADFINAL		*�t�@�C�����w�肵�Ă��Ȃ�
TDX_ERROR7:
	ERROR	EM7
	MOVEQ.L	#-7,D0
	BRA	TDX_LOADFINAL		*�s���ȉ��K���w�肵��
TDX_ERROR8:
	ERROR	EM8
	MOVEQ.L	#-8,D0
	BRA	TDX_LOADFINAL		*���݂��Ȃ�PCM�f�[�^�ɃA�N�Z�X����
TDX_ERROR9:
	ERROR	EM9
	MOVEQ.L	#-9,D0
	BRA	TDX_LOADFINAL		*�Q�d��`���s�Ȃ���

TDX_LOADQUIT:
	MOVEQ.L	#0,D0
TDX_LOADFINAL:
	unlk	a6
	MOVEM.L	(SP)+,D1-D7/A0-A6
	RTS
*
*	�L�[�R�[�h�����o��
*
GETKEYCODE:
	CLR.W	D0
	MOVE.B	(A0)+,D0
	ANDI.B	#$DF,D0
	CMP.B	#"N",D0
	BEQ	NUM_KEYCODE
	CMP.B	#"A",D0
	BCS	KEYCODE_ERROR		*�����ł͂Ȃ�
	CMP.B	#"G"+1,D0
	BCS	ALPHA_KEYCODE
KEYCODE_ERROR:
	MOVEQ.L	#-1,D0
	RTS
NUM_KEYCODE:
	BSR	SKIPBRANK
	BSR	TDXGETNUM			*���l�Ƃ��ĉ��������o��
	TST.W	D0
	BMI	KEYCODE_ERROR
	CMP.W	#96,D0
	BPL	KEYCODE_ERROR
	RTS
KEYCODE_TBL:	*AB  C D E F G
	DC.B	9,11,0,2,4,5,7
	EVEN
ALPHA_KEYCODE:
	CLR.W	D1
	SUB.B	#"A",D0
	MOVE.B	KEYCODE_TBL(PC,D0.W),D1		*�����R�[�h�x�[�X(1)
	BSR	SKIPBRANK
	CMP.B	#"+",(A0)
	BEQ	ADAPTIVE_PLUSE
	CMP.B	#"-",(A0)
	BEQ	ADAPTIVE_MINUSE
	BRA	ADAPTIVE_OCTABE
ADAPTIVE_PLUSE:
	ADDQ.W	#1,D1
	ADDQ.W	#1,A0
	BRA	ADAPTIVE_OCTABE
ADAPTIVE_MINUSE:
	SUBQ.W	#1,D1
	ADDQ.W	#1,A0
ADAPTIVE_OCTABE:
	BSR	SKIPBRANK
	BSR	TDXGETNUM
	MULU	#12,D0
	ADD.W	D1,D0
	SUBQ.W	#4,D0
	BCS	KEYCODE_ERROR
	CMP.W	#96,D0
	BPL	KEYCODE_ERROR
	RTS


		.data
EXT2:
		.dc.b	'.PDX',0
env_MADRV:
		.dc.b	'MADRV',0
		.dc.b	'mxp',0,0
		.text

*==================================================
*�t�@�C�������t����
*	a0.l <- �t�@�C����
*	d0.l -> ���Ȃ�G���[
*==================================================

PLAY_FILE:
		movem.l	d1-d2/a0-a1,-(sp)
		link	a5,#-96
		movea.l	a0,a1

		pea	-96(a5)			*�t�@�C�����̊g���q���������o����
		move.l	a1,-(sp)
		DOS	_NAMECK
		addq.l	#8,sp
		tst.l	d0
		bne	play_file90
		move.l	-96+86(a5),d1
		andi.l	#$00dfdfdf,d1

		DRIVER	DRIVER_FILEEXT		*�g���q���ʃR�[�h�𒲂ׂ�
		movea.l	d0,a0
play_file10:
		moveq	#0,d0
		move.b	(a0),d0
		beq	play_file90
		move.l	(a0)+,d2
		andi.l	#$00dfdfdf,d2
		cmp.l	d2,d1
		bne	play_file10

		DRIVER	DRIVER_FLOADP		*���t����
		bra	play_file99

play_file90:
		moveq	#-1,d0
play_file99:
		unlk	a5
		movem.l	(sp)+,d1-d2/a0-a1
		rts


*==================================================
* �v���C���[�Ăяo��
*	a0.l <- �R�}���h��
*	a1.l <- �p�����[�^
*	d0.l -> �I���R�[�h�A���Ȃ�G���[
*==================================================

nambuf		=	-512
cmdlin		=	-256

CALL_PLAYER:
		link	a5,#-512
		movem.l	d1-d7/a0-a6,-(sp)
		lea	nambuf(a5),a2
		move.w	#254-1,d0
call_player10:
		move.b	(a0)+,(a2)+		*�N���t�@�C���������[�J���G���A�ɃR�s�[
		dbeq	d0,call_player10
		bne	call_player80
		move.b	#' ',-1(a2)
call_player20:
		move.b	(a1)+,(a2)+		*�p�����[�^���R�s�[
		dbeq	d0,call_player20
		bne	call_player80
		clr.b	(a2)
		clr.l	-(sp)			*�����Ɠ������ŁA
		pea.l	cmdlin(a5)
		pea.l	nambuf(a5)
		move.w	#2,-(sp)		*�p�X�̌���
		DOS	_EXEC
		tst.l	d0
		bmi	call_player70
		clr.w	(sp)			*���[�h�����s
		st.b	CHILD_FLAG(a6)
		DOS	_EXEC
call_player70:	lea	14(sp),sp
		bra	call_player90
call_player80:
		moveq	#-1,d0			*�R�}���h���C�������߂����ꍇ
call_player90:
		movem.l	(sp)+,d1-d7/a0-a6
		clr.b	CHILD_FLAG(a6)
		unlk	a5
		rts


*==================================================
*�G���[���b�Z�[�W�擾
*	d0.w <- �G���[���b�Z�[�W�ԍ�(1�`)
*	a0.l <- �v���[����
*	a0.l -> �G���[���b�Z�[�W
*==================================================

GET_PLAYERRMES:
		movem.l	d0/a1-a2,-(sp)
		subq.w	#1,d0
		cmpi.w	#MAXERRMES,d0
		bls	get_playerrmes00
		move.w	#1,d0
get_playerrmes00:
		lea	PLAY_ERRORMES(pc),a1
		lea	FILE_BUFF(a6),a2		*FILE_BUFF���ꎞ�I�Ɏg��
		bra	get_playerrmes19
get_playerrmes10:					*�w��ԍ��̃��b�Z�[�W��T���āA
		tst.b	(a1)+
		bne	get_playerrmes10
get_playerrmes19:
		dbra	d0,get_playerrmes10

get_playerrmes20:
		move.b	(a0)+,(a2)+			*���Ƀv���[�������R�s�[���āA
		bne	get_playerrmes20
		move.b	#':',-1(a2)
		move.b	#' ',(a2)+

get_playerrmes30:
		cmpi.b	#'%',(a1)
		bne	get_playerrmes39
		addq.l	#1,a1
		move.b	(a1)+,d0
get_playerrmesD:
		cmpi.b	#'D',d0				*�擪��%D���h���C�o���ɁA
		bne	get_playerrmesP
		move.l	a0,-(sp)
		DRIVER	DRIVER_NAME
		move.l	d0,a0
get_playerrmesD1:
		move.b	(a0)+,(a2)+
		bne	get_playerrmesD1
		subq.l	#1,a2
		move.l	(sp)+,a0
		bra	get_playerrmes39
get_playerrmesP:
		cmpi.b	#'P',d0				*%P���v���[�����ɒu������
		bne	get_playerrmes39
		move.b	#' ',-2(a2)
		subq.l	#1,a2
get_playerrmes39:

get_playerrmes40:
		move.b	(a1)+,(a2)+			*���b�Z�[�W���R�s�[
		bne	get_playerrmes40

		lea	FILE_BUFF(a6),a0		*FILE_BUFF��Ԃ�
get_playerrmes90:
		movem.l	(sp)+,d0/a1-a2
		rts


*==================================================
* �u�R�}���h�́����l
*==================================================

		.data
VOL_DEFALT:	.dc.b	$55,$57,$5A,$5D,$5F,$62,$65,$67
		.dc.b	$6A,$6D,$6F,$72,$75,$77,$7A,$7D
		.text


*==================================================
* �G���[���b�Z�[�W
*==================================================

PLAY_ERRORMES:
no01:		.dc.b	'�G���[���������܂���',0
no02:		.dc.b	'�ȃf�[�^�����[�h�ł��܂���',0
no03:		.dc.b	'PCM �f�[�^�����[�h�ł��܂���',0
no04:		.dc.b	'���F��`�f�[�^�����[�h�ł��܂���',0
no05:		.dc.b	'������������܂���',0
no06:		.dc.b	'%D �̃o�[�W�������Ⴂ�܂�',0
no07:		.dc.b	'%D �̃g���b�N�o�b�t�@������܂���',0
no08:		.dc.b	'%D �� PCM �o�b�t�@������܂���',0
no09:		.dc.b	'%D �̃��[�N�s���̉\��������܂�',0
no10:		.dc.b	'�ُ�ȃf�[�^�ł�',0
no11:		.dc.b	'PCM �f�[�^���ُ�ł�',0
no12:		.dc.b	'%P ��������܂���',0
no13:		.dc.b	'MIDI �{�[�h������܂���',0
no14:		.dc.b	'�R���o�[�g�Ɏ��s���܂���',0
no15:		.dc.b	'LZM.x(LZZ.r) ��������܂���',0
no16:		.dc.b	'LZZ.r ��������܂���',0
no17:		.dc.b	'LZZ �œW�J�Ɏ��s���܂���',0
no18:		.dc.b	'�R���o�[�^ (??toZ.x) ��������܂���',0
no19:		.dc.b	'�f�[�^�̎�ނ��Ⴂ�܂�',0
no20:		.dc.b	'%D �ŃG���[���������܂���',0
no21:		.dc.b	'�R���o�[�g���Ɉُ�ȃR�[�h�𔭌����܂���',0
no22:		.dc.b	'�������݂ł��܂���',0
no23:		.dc.b	'�t�@�C�������܂���',0
no24:		.dc.b	'�����o�b�t�@���s���ł�',0
no25:		.dc.b	'RC �̃R���o�[�^�ŃG���[���������܂���',0
no26:		.dc.b	'RC �̃R���o�[�^(?toR.x)������܂���',0
no27:		.dc.b	'Human �̃o�[�W��������߂��܂�',0
MAXERRMES	equ	27
MMDSP_NAME:	.dc.b	'MMDSP',0

		.even

		.end

--------------------------------------------------------------------------------
�E�c�q�h�u�d�q�����֐��̍쐬���@�ɂ���

  �܂��A�h���C�o�����֐��̃\�[�X�Ɏ��̂悤�ȃe�[�u�����`���ADRIVER.o
����Q�Ƃł���悤�ɂ��Ă����B

FUNC		.macro	entry
		.dc.w	entry-RCD_ENTRY
		.endm

		.xdef	RCD_ENTRY

RCD_ENTRY:
		FUNC	RCD_CHECK		*�풓�`�F�b�N
		FUNC	RCD_NAME		*�h���C�o���擾
		FUNC	RCD_INIT		*������
		FUNC	RCD_GETSTAT		*�X�e�[�^�X�擾
		FUNC	RCD_TRKSTAT		*�g���b�N���擾
		FUNC	RCD_GETMASK		*���t�g���b�N�擾
		FUNC	RCD_SETMASK		*���t�g���b�N�ݒ�
		FUNC	RCD_FILEEXT		*�g���q�e�[�u���擾
		FUNC	RCD_FLOADP		*�f�[�^�t�@�C�����[�h�����t�J�n
		FUNC	RCD_PLAY		*���t�J�n
		FUNC	RCD_PAUSE		*���t�ꎞ��~
		FUNC	RCD_CONT		*���t�ĊJ
		FUNC	RCD_STOP		*���t�I��
		FUNC	RCD_FADE		*�t�F�[�h�A�E�g
		FUNC	RCD_SKIP		*������
		FUNC	RCD_SLOW		*�X���[
?		FUNC	RCD_FILINFO		*�f�[�^�t�@�C�����擾

�����Ă��̃\�[�X�� driver_table �ɂ��̐擪�A�h���X��ǉ�����B

���W�X�^�́Ad0�ȊO�͔j�󂵂Ă͂Ȃ�Ȃ��B

