*************************************************************************
*									*
*									*
*	    �w�U�W�O�O�O�@�l�w�c�q�u�^�l�`�c�q�u�f�B�X�v���C		*
*									*
*				�l�l�c�r�o				*
*									*
*									*
*	Copyright (C) 1991,1992 Kyo Mikami.				*
*	Copyright (C) 1994 Masao Takahashi				*
*									*
*									*
*************************************************************************

		.include	doscall.mac
		.include	MMDSP.h
		.include	DRIVER.h
		.include	FILES.h


*==================================================
*�t�@�C���l�[���o�b�t�@�ʒu�����߂�
*	d0.w <- buffer pos.
*	a0.l -> buffer address
*==================================================

get_fnamebuf:
		move.l	d0,-(sp)
		movea.l	#SEL_FNAME,a0		*�o�b�t�@�ʒu�v�Z
		ext.l	d0
		lsl.l	#5,d0
		adda.l	d0,a0
		move.l	(sp)+,d0
		rts


*==================================================
*�t�@�C���l�[���o�b�t�@������������
*==================================================

INIT_FNAMEBUF:
		move.l	a0,-(sp)
		clr.w	SEL_FILENUM(a6)
		move.l	#SEL_BUFFER1,SEL_TITLE(a6)
		clr.w	SEL_TITLEBANK(a6)
		clr.w	SEL_CHANGE(a6)

		st.b	SEL_MMOVE(a6)

*		lea	mes_test(pc),a0
*		bsr	G_MESSAGE_PRT

		move.l	(sp)+,a0
		rts

*mes_test:	.dc.b	'�o�b�t�@���N���A����܂����B',0
*		.even


*==================================================
*�����̃f�B���N�g���w�b�_��T��
*	d1.w <- ������t�@�C���ԍ�
*	d0.w -> �w�b�_�̃t�@�C���ԍ�
*	a0.l -> �w�b�_�̃A�h���X
*==================================================

search_header:
		cmp.w	SEL_FILENUM(a6),d1
		bcc	search_header11
		move.w	d1,d0
		bmi	search_header11
		bsr	get_fnamebuf
search_header10:
		tst.b	(a0)
		bmi	search_header90
		lea	-32(a0),a0
		dbra	d0,search_header10
search_header11:
		moveq	#0,d0			*�����������́A�����΂�擪�̃w�b�_��Ԃ�
		bsr	get_fnamebuf
search_header90:
		rts


*==================================================
*���̃f�[�^��T���iAUTO���[�h�p�j
*	d1.w <- �������J�n����t�@�C���ԍ�
*	d0.l -> �������t�@�C���ԍ�(���Ȃ�G���[)
*==================================================

search_next_auto:
		movem.l	d1-d2/a0,-(sp)
		tst.w	SEL_BMAX(a6)		*�o�b�t�@�ɂP���t�@�C�����Ȃ���΃G���[
		beq	search_next_auto_err
		tst.w	SEL_FMAX(a6)		*�f�B���N�g���Ƀt�@�C����������
		bne	search_next_auto01
		btst.b	#2,AUTOFLAG(a6)		*ALLDIR���[�h��������
		beq	search_next_auto_err
		moveq	#0,d0			*�擪����T��
		moveq	#0,d2
		bsr	get_fnamebuf
		bra	search_next_auto10
search_next_auto01:
		move.w	SEL_FCP(a6),d0
		move.w	d0,d2
		bsr	get_fnamebuf
		tst.b	SEL_MMOVE(a6)		*�J�[�\������������Ă��Ȃ����
		beq	search_next_auto20	*�P���̋Ȃ���T��

search_next_auto10:				*do {
		tst.b	(a0)			*if(�f�[�^�t�@�C�� &&
		ble	search_next_auto20
		btst.b	#3,AUTOFLAG(a6)		*  (!PROGMODE || PROGFILE)
		beq	search_next_auto90
		tst.b	PROG_FLAG(a0)
		bne	search_next_auto90	*	return pos;

search_next_auto20:
		lea	32(a0),a0		*pos++;
		addq.w	#1,d0
		cmp.w	SEL_FILENUM(a6),d0	*if( �o�b�t�@�G���h ||
		bcc	search_next_auto21
		tst.b	(a0)			*  (�f�B���N�g���G���h && !ALLDIR)) {
		bpl	search_next_auto30
		btst.b	#2,AUTOFLAG(a6)
		bne	search_next_auto30
search_next_auto21:
		btst.b	#0,AUTOFLAG(a6)		*	if( !REPEAT ) return -1;
		beq	search_next_auto_err
		subq.w	#1,d0
		lea	-32(a0),a0
		bsr	get_repeatpos		*	���s�[�g�ʒu�ֈړ�;
						*}
search_next_auto30:
		cmp.w	d2,d0
		bne	search_next_auto10 	*} while (pos != startpos);

		tst.b	SEL_MMOVE(a6)		*�Ώۂ��P�Ȃ���MMOVE�Ŕ�΂���Ă��܂��̂�
		bne	search_next_auto_err	*�����ōēx�`�F�b�N����
		tst.b	(a0)			*if(�f�[�^�t�@�C�� &&
		ble	search_next_auto_err
		btst.b	#3,AUTOFLAG(a6)		*  (!PROGMODE || PROGFILE)
		beq	search_next_auto90
		tst.b	PROG_FLAG(a0)
		bne	search_next_auto90	*	return pos;

search_next_auto_err:
		moveq	#-1,d0			*return -1;
search_next_auto90:
		tst.w	d0
		movem.l	(sp)+,d1-d2/a0
		rts


*==================================================
*���s�[�g����ʒu�����߂�
*	d0.w <- ���݂̈ʒu(�ԍ�)
*	a0.l <- ���݂̈ʒu(�A�h���X)
*	d0.w -> ���s�[�g����ʒu(�ԍ�)
*	a0.l -> ���s�[�g����ʒu(�A�h���X)
*==================================================

get_repeatpos:
		move.l	d1,-(sp)
		btst.b	#2,AUTOFLAG(a6)
		bne	get_repeatpos20
get_repeatpos10:
		move.w	d0,d1			*ALLDIR���[�h����Ȃ��Ȃ�
		bsr	search_header		*�����̃w�b�_�̈ʒu��Ԃ�
		bra	get_repeatpos90
get_repeatpos20:
		moveq	#0,d0			*ALLDIR���[�h�Ȃ�
		bsr	get_fnamebuf		*�o�b�t�@�̈�Ԑ擪�̈ʒu��Ԃ�
get_repeatpos90:
		move.l	(sp)+,d1
		rts


*==================================================
*���̃f�[�^��T���iSHUFFLE���[�h�p�j
*	d1.w <- �������J�n����t�@�C���ԍ�
*	d0.l -> �������t�@�C���ԍ�(���Ȃ�G���[)
*==================================================

search_next_shuffle:
		movem.l	d1-d2/a0,-(sp)
		tst.w	SEL_BMAX(a6)		*�o�b�t�@�ɂP���t�@�C�����Ȃ���΃G���[
		beq	search_next_shuf_err
		tst.w	SEL_FMAX(a6)		*�t�@�C����������
		bne	search_next_shuf02
		btst.b	#2,AUTOFLAG(a6)
		beq	search_next_shuf_err	*ALLDIR���[�h�łȂ���΃G���[
search_next_shuf02:
		bsr	get_random		*�����ňʒu�����߂�
		moveq	#0,d1
		move.w	d0,d1
		moveq	#0,d2			*�I�t�Z�b�g
		move.w	SEL_FILENUM(a6),d0	*ALLDIR���[�h�Ȃ�S�̑Ώ�
		btst.b	#2,AUTOFLAG(a6)
		bne	search_next_shuf03
		move.w	SEL_BTOP(a6),d2
		move.w	SEL_FMAX(a6),d0		*�����łȂ��Ȃ�f�B���N�g�����Ώ�
search_next_shuf03:
		divu	d0,d1
		swap	d1			*�]����g��
		add.w	d2,d1
search_next_shuf09:

		move.w	d1,d0
		move.w	d1,d2
		bsr	get_fnamebuf

search_next_shuf10:				*do {
		tst.b	(a0)			*if(�f�[�^�t�@�C�� &&
		ble	search_next_shuf20
		btst.b	#3,AUTOFLAG(a6)		*  (!PROGMODE || PROGFILE) &&
		beq	search_next_shuf11
		tst.b	PROG_FLAG(a0)
		beq	search_next_shuf20
search_next_shuf11:
		move.b	SHUFFLE_CODE(a6),d1	*  SHUFFLE_FLAG != SHAFFLE_CODE )
		cmp.b	SHUFFLE_FLAG(a0),d1
		bne	search_next_shuf90	*	return pos;

search_next_shuf20:
		lea	32(a0),a0		*pos++;
		addq.w	#1,d0
		cmp.w	SEL_FILENUM(a6),d0	*if( �o�b�t�@�G���h ||
		bcc	search_next_shuf21
		tst.b	(a0)			*  (�f�B���N�g���G���h && !ALLDIR)) {
		bpl	search_next_shuf30
		btst.b	#2,AUTOFLAG(a6)
		bne	search_next_shuf30
search_next_shuf21:
		subq.w	#1,d0
		lea	-32(a0),a0
		bsr	get_repeatpos		*	���s�[�g�ʒu�ֈړ�;
						*}

search_next_shuf30:
		cmp.w	d2,d0
		bne	search_next_shuf10 	*} while (pos != startpos);
search_next_shuf_err:
		moveq	#-1,d0			*return -1;
search_next_shuf90:
		tst.w	d0
		movem.l	(sp)+,d1-d2/a0
		rts


*==================================================
*�����𓾂�
*	d0.w -> ����
*==================================================

get_random:
		movem.l	d1/a0,-(sp)
		MYONTIME
		move.w	RND_WORK(a6),d1
		not.w	d0
		eor.w	d1,d0
		rol.w	#8,d0
		move.w	d0,RND_WORK(a6)
		movem.l	(sp)+,d1/a0
		rts


*==================================================
*�J�����g�̃f�[�^�t�@�C���������o��
*==================================================

write_datafile:
		movem.l	d1-d2/a1,-(sp)
		moveq	#-1,d2

		movea.l	SEL_HEAD(a6),a1
		move.w	FILE_NUM(a1),d1
		subq.w	#1,d1
		bcs	write_datafile90

		move.w	#$20,-(sp)
		pea	name_datafile(pc)
		DOS	_CREATE
		addq.l	#6,sp
		move.l	d0,d2
		bmi	write_datafile90

		move.w	d2,-(sp)
		pea	datafile_head(pc)
		DOS	_FPUTS
		addq.l	#6,sp

write_datafile10:
		lea	32(a1),a1
		tst.b	(a1)
		beq	write_datafile19
		move.w	d2,-(sp)
		tst.b	DOC_FLAG(a1)
		beq	write_datafile11
		move.w	#'+',-(sp)
		DOS	_FPUTC
		addq.l	#2,sp
write_datafile11:
		pea	FILE_NAME(a1)
		DOS	_FPUTS
		addq.l	#4,sp
		tst.l	TITLE_ADR(a1)
		beq	write_datafile15
		move.w	#9,-(sp)
		DOS	_FPUTC
		addq.l	#2,sp
		move.l	TITLE_ADR(a1),-(sp)
		DOS	_FPUTS
		addq.l	#4,sp
write_datafile15:
		move.w	#13,-(sp)
		DOS	_FPUTC
		move.w	#10,(sp)
		DOS	_FPUTC
		addq.l	#4,sp
write_datafile19:
		dbra	d1,write_datafile10

write_datafile90:
		tst.l	d2
		bmi	write_datafile91
		move.w	d2,-(sp)
		DOS	_CLOSE
		addq.l	#2,sp
write_datafile91:
		movem.l	(sp)+,d1-d2/a1
		rts


name_datafile:	.dc.b	'MMDSP.DAT',0
datafile_head:	.dc.b	'MMDSPDAT'
		.dc.l	MMDATVER
		.dc.b	13,10,0
		.even


*==================================================
*�f�[�^�t�@�C����ǂݍ���
*	a0.l <- �f�B���N�g���w�b�_
*==================================================

read_datafile:
		movem.l	d0-d4/a0-a4,-(sp)

		movea.l	a0,a3			*a3 <- dir head

		clr.l	-(sp)			*�J�����g�̃f�[�^�t�@�C����ǂݍ����
		clr.l	-(sp)
		pea	name_datafile(pc)
		bsr	READ_FILE
		lea	12(sp),sp
		move.l	a0,-(sp)
		movea.l	a0,a4			*a4 <- data adr
		move.l	d0,d4			*d4 <- data len
		bmi	read_datafile90

		bsr	read_datafile_check	*�o�[�W�����`�F�b�N
		bne	read_datafile90
		bsr	read_datafile_next

read_datafile10:
		bsr	read_datafile_search	*��v����t�@�C����T���ă^�C�g���擾
		bsr	read_datafile_next	*���̍s��
		tst.l	d4
		bgt	read_datafile10

read_datafile90:
		bsr	FREE_MEM
		addq.l	#4,sp
		movem.l	(sp)+,d0-d4/a0-a4
		rts

*----------------------------------------
*�f�[�^���`�F�b�N����
*	a4.l <- �f�[�^�t�@�C���̃o�b�t�@�A�h���X
*	d0.l -> 0�Ȃ�K���f�[�^ (ccr�ɂ��Ԃ�)

read_datafile_check:
		cmpi.l	#'MMDS',(a4)
		bne	read_datafile_checkerr
		cmpi.l	#'PDAT',4(a4)
		bne	read_datafile_checkerr
		cmpi.l	#MMDATVER,8(a4)
		bne	read_datafile_checkerr
		moveq	#0,d0
		bra	read_datafile_check90
read_datafile_checkerr:
		moveq	#-1,d0
read_datafile_check90:
		rts


*----------------------------------------
*�f�[�^�t�@�C������^�C�g�����擾
*	a3.l <- �f�B���N�g���w�b�_�̃A�h���X
*	a4.l <- �f�[�^�t�@�C���̃o�b�t�@�A�h���X
*	d4.l <- �f�[�^�t�@�C���̎c�蒷��

read_datafile_search:
		tst.l	d4				*�f�[�^�̏I��肩�A
		ble	read_datafile_search90
		cmpi.b	#' ',(a4)			*�����ȊO�������牽�����Ȃ�
		bls	read_datafile_search90
		cmpi.b	#'+',(a4)
		seq.b	d2
		bne	read_datafile_search09
		addq.l	#1,a4
read_datafile_search09:

		move.w	TOP_POS(a3),d0			*�f�B���N�g���̍ŏ�����A
		bsr	get_fnamebuf
		lea	FILE_NAME-32(a0),a2
		move.w	FILE_NUM(a3),d3
read_datafile_search10:
		move.b	(a4),d0
		bra	read_datafile_search19
read_datafile_search11:
		cmp.b	(a2),d0				*�ŏ��̂P��������v������̂�T���A
read_datafile_search19:
		lea	32(a2),a2
		dbeq	d3,read_datafile_search11
		bne	read_datafile_search90
		lea	-32(a2),a2

read_datafile_search20:
		lea	1(a2),a0			*�c��̕�������v���邩����ׁA
		lea	1(a4),a1
read_datafile_search21:
		move.b	(a0)+,d0
		beq	read_datafile_search30
		cmp.b	(a1)+,d0
		beq	read_datafile_search21
		bra	read_datafile_search10		*����Ă���Ύ���

read_datafile_search30:
		cmpi.b	#9,(a1)				*�t�@�C���������S�Ɉ�v������
		bne	read_datafile_search10		*�^�u�`�F�b�N����
read_datafile_search31:
		cmpi.b	#9,(a1)+			*�^�u���΂�
		beq	read_datafile_search31
		subq.l	#1,a1

		link	a5,#-128			*�^�C�g�����R�s�[����
		movea.l	sp,a0
		moveq	#127-1,d1
read_datafile_search32:
		move.b	(a1)+,d0
		cmpi.b	#$0d,d0
		beq	read_datafile_search33
		move.b	d0,(a0)+
		dbra	d1,read_datafile_search32
read_datafile_search33:
		clr.b	(a0)
		movea.l	sp,a0				*�^�C�g���o�^
		bsr	COPY_TITLE
		move.l	d0,TITLE_ADR-FILE_NAME(a2)
		move.b	d2,DOC_FLAG-FILE_NAME(a2)	*DOC�t���O�Z�b�g
		unlk	a5

read_datafile_search90:
		rts

*----------------------------------------
*�f�[�^�t�@�C���̎��̍s��
*	a4.l <-> �f�[�^�t�@�C���̃o�b�t�@�A�h���X
*	d4.l <-> �f�[�^�t�@�C���̎c�蒷��

read_datafile_next:
read_datafile_next10:
		tst.l	d4
		ble	read_datafile_next90
		subq.l	#1,d4
		cmpi.b	#$0a,(a4)+
		bne	read_datafile_next10
read_datafile_next90:
		rts


*==================================================
*SEL_FNAME�ɃJ�����g�f�B���N�g�����Z�b�g����
*	d0.l -> �f�B���N�g���w�b�_�̃A�h���X�A���Ȃ�G���[
*==================================================

FNAME_SET:
		movem.l	d1/a0-a2,-(sp)
		moveq	#0,d0			*�J�����g�h���C�u���g���Ȃ��ꍇ
		bsr	DRIVE_CHECK
		bpl	fname_set10
		lea	DUMMY_HEAD(pc),a0	*�_�~�[�̃w�b�_��Ԃ�
		move.l	a0,d0
		bra	fname_set90

fname_set10:
		lea	CURRENT(a6),a1		*�h���C�u���g����ꍇ
		movea.l	a1,a0
		bsr	CHECK_DIRDUP		*�w�b�_�o�^���݂Ȃ�A�����
		tst.l	d0
		bpl	fname_set90

		movea.l	a1,a0			*�f�B���N�g���w�b�_��o�^
		bsr	STORE_DIRHED
		tst.l	d0
		bmi	fname_set90

		move.l	d0,a2			*�t�@�C�����o�^�J�n��
		lea	SEL_FILES(a6),a1

		moveq	#$10,d0			*�܂��f�B���N�g�������Ō���
		bsr	fname_setsub

		moveq	#$20,d0			*���Ƀt�@�C�������Ō���
		bsr	fname_setsub

		movea.l	a2,a0			*�f�[�^�t�@�C��������Γǂݍ���
		bsr	read_datafile

		move.l	d1,d0
		bmi	fname_set90
		move.l	a2,d0

fname_set90:
		movem.l	(sp)+,d1/a0-a2
		rts

fname_setsub:
		move.w	d0,-(sp)
		pea	FILES_WILD(pc)
		pea	(a1)
		DOS	_FILES
		bra	fname_setsub20
fname_setsub10:
		move.l	a2,a0
		bsr	STORE_FNAME
		move.l	d0,d1
		bmi	fname_setsub30
		DOS	_NFILES
fname_setsub20:
		tst.l	d0
		bpl	fname_setsub10
fname_setsub30:
		lea	10(sp),sp
		rts

DUMMY_HEAD:	.dc.b	$FF,$FF,$00,$00,$00,$00,$00,$00
		.dc.b	$00,$00,$00,$00,$00,$00,$00,$00
FILES_WILD:	.dc.b	'*.*',0
		.even

*==================================================
*�f�B���N�g���o�^�L������
*	a0 <- ���ׂ����f�B���N�g���̐�΃p�X��
*	d0 -> �f�B���N�g���w�b�_�̃A�h���X�A�Ȃ���Ε�
*==================================================

CHECK_DIRDUP:
		movem.l	a0-a3,-(sp)
		tst.w	SEL_FILENUM(a6)
		beq	check_dirdup80

		movea.l	#SEL_FNAME,a2			*�ŏ�����
check_dirdup10:
		movea.l	a0,a3
		movea.l	PATH_ADR(a2),a1
check_dirdup20:
		move.b	(a3)+,d0			*�p�X�����r
		beq	check_dirdup30
		cmp.b	(a1)+,d0
		beq	check_dirdup20
		bra	check_dirdup40
check_dirdup30:
		move.l	a2,d0
		tst.b	(a1)
		beq	check_dirdup90
check_dirdup40:
		movea.l	NEXT_DIR(a2),a2			*���̃f�B���N�g��
		move.l	a2,d0
		bne	check_dirdup10

check_dirdup80:
		moveq	#-1,d0
check_dirdup90:
		movem.l	(sp)+,a0-a3
		rts


*==================================================
*�f�B���N�g���w�b�_��o�^����
*	a0.l <- �o�^����f�B���N�g���̐�΃p�X��
*	d0.l -> �o�^�����f�B���N�g���w�b�_�̃A�h���X
*		���Ȃ�t�@�C�����I�[�o�[
*==================================================

STORE_DIRHED:
		movem.l	a0-a2,-(sp)

		cmpi.w	#MAXFILE,SEL_FILENUM(a6)	*�t�@�C��������`�F�b�N
		bcc	store_dirhed_err

		movea.l	a0,a2
		move.w	SEL_FILENUM(a6),d0		*�o�b�t�@�A�h���X�v�Z
		bsr	get_fnamebuf
		exg	a0,a2

		tst.w	SEL_FILENUM(a6)
		beq	store_dirhed20
		movea.l	#SEL_FNAME,a1			*�O�̃w�b�_�ƃ����N����
store_dirhed10:
		move.l	NEXT_DIR(a1),d0
		beq	store_dirhed11
		movea.l	d0,a1
		bra	store_dirhed10
store_dirhed11:
		move.l	a2,NEXT_DIR(a1)

store_dirhed20:
		move.b	#$FF,HEAD_MARK(a2)		*�e���ڃZ�b�g
		clr.b	KENS_FLAG(a2)
		clr.w	FILE_NUM(a2)
		clr.l	NEXT_DIR(a2)
		move.w	SEL_FILENUM(a6),d0
		addq.w	#1,d0
		move.w	d0,SEL_FILENUM(a6)
		move.w	d0,PAST_POS(a2)
		move.w	d0,TOP_POS(a2)

		bsr	COPY_TITLE			*�f�B���N�g�����R�s�[
		move.l	d0,PATH_ADR(a2)

		move.l	a2,d0
		movem.l	(sp)+,a0-a2
		rts

store_dirhed_err:
		moveq	#-1,d0
		movem.l	(sp)+,a0-a2
		rts

*==================================================
*�t�@�C������o�^����
*	a0.l <- �f�B���N�g���w�b�_
*	a1.l <- _FILES �o�b�t�@
*	d0.l -> ���Ȃ�A�t�@�C�����I�[�o�[
*==================================================

STORE_FNAME:
		movem.l	d1/a0-a2,-(sp)

		cmpi.w	#MAXFILE,SEL_FILENUM(a6)	*�t�@�C��������`�F�b�N
		bcc	store_fname_err

		bsr	DIRECTORY_CHCK			*���t�\�t�@�C��or<dir>���H
		move.l	d0,d1
		bmi	store_fname90

		addq.w	#1,FILE_NUM(a0)

		move.w	SEL_FILENUM(a6),d0		*�o�b�t�@�A�h���X�v�Z
		bsr	get_fnamebuf

		move.b	d1,DATA_KIND(a0)		*���ʃR�[�h�Z�b�g

		pea	30(a1)				*�t�@�C�������R�s�[
		pea	FILE_NAME(a0)
		bsr	COPY_STRING
		addq.l	#8,sp

		clr.l	TITLE_ADR(a0)			*�^�C�g���A�h���X�N���A

		move.b	SHUFFLE_CODE(a6),d0
		subq.b	#1,d0
		move.b	d0,SHUFFLE_FLAG(a0)		*�V���t���t���O��
		clr.b	PROG_FLAG(a0)			*�v���O�����t���O��
		clr.b	DOC_FLAG(a0)			*�h�L�������g���݃t���O���N���A

		addq.w	#1,SEL_FILENUM(a6)

store_fname90:
		moveq	#0,d0
		movem.l	(sp)+,d1/a0-a2
		rts

store_fname_err:
		moveq	#-1,d0
		movem.l	(sp)+,d1/a0-a2
		rts


*==================================================
*�^�C�g���o�b�t�@�Ƀ^�C�g���o�^
*	a0.l <- �^�C�g��
*	d0.l -> �o�^�����A�h���X
*==================================================

COPY_TITLE:
		movem.l	a0-a2,-(sp)

		move.l	SEL_TITLE(a6),a2

		move.l	a0,a1				*�^�C�g���̒����𒲂ׂ�
copy_title10:
		tst.b	(a1)+
		bne	copy_title10
		suba.l	a0,a1

		move.w	a2,d1				*�I�[�o�[������A���̃o�b�t�@��
		add.w	a1,d1
		bcc	copy_title30
		move.w	SEL_TITLEBANK(a6),d0
		beq	copy_title20
		cmpi.w	#1,d0
		beq	copy_title21
		lea	INVALID_TITLE(pc),a2		*�o�b�t�@�g���s��������
		bra	copy_title40
copy_title20:
		movea.l	#SEL_BUFFER2,a2
		bra	copy_title22
copy_title21:
		movea.l	#SEL_BUFFER3,a2
copy_title22:
		addq.w	#1,SEL_TITLEBANK(a6)

copy_title30:
		adda.l	a2,a1				*���̃A�h���X
		move.l	a1,SEL_TITLE(a6)

		move.l	a0,-(sp)			*�^�C�g���R�s�[
		move.l	a2,-(sp)
		bsr	COPY_STRING
		addq.l	#8,sp

copy_title40:
		move.l	a2,d0
copy_title90:
		movem.l	(sp)+,a0-a2
		rts

INVALID_TITLE:	.dc.b	'- title area over -',0
		.even

*==================================================
*	���c�h�q�d�b�s�n�q�x�Q�b�g�b�j
*�@�\�F�l�c�w�t�@�C�����f�B���N�g�����𔻒f����
*���́F	�r�d�k�Q�e�h�k�d�r
*�o�́F	�c�O	���t�t�@�C�����ʃR�[�h�i�P�`
*		�|�P�F�͈͊O�t�@�C��
*		�@�O�F�f�B���N�g��
*�Q�l�FSEL_FILES��DOS _(N)FILES�̌��ʂ����ăR�[�����邱��
*==================================================

DIRECTORY_CHCK:
		movem.l	d1-d2/a0-a2,-(sp)

		DRIVER	DRIVER_FILEEXT			*�����x���͕ς��Ă�������
		movea.l	d0,a2
		lea.l	SEL_FILES(a6),a0

		btst.b	#4,21(a0)			*�f�B���N�g�����H
		beq	dirchk_jp0

		lea.l	30(a0),a1
		cmp.w	#$2E00,(a1)			*�u.   < dir >�v���Ȃ���
		beq	dirchk_chker

		moveq.l	#0,d0
		bra	dirchk_done

dirchk_jp0:
		lea.l	30(a0),a1			*�f�B���N�g���łȂ���
		moveq	#0,d1
dirchk_lp0:
		move.b	(a1)+,d0			*�g���q�ʒu�ɍ��킹��
		beq	dirchk_jp1
		cmpi.b	#'.',d0
		bne	dirchk_lp0
		move.l	a1,d1
		bra	dirchk_lp0
dirchk_jp1:
		tst.l	d1
		beq	dirchk_chker
		movea.l	d1,a1
		moveq.l	#0,d1
		move.b	(a1)+,d1
		beq	dirchk_jp2
		lsl.l	#8,d1
		move.b	(a1)+,d1
		beq	dirchk_jp2
		lsl.l	#8,d1
		move.b	(a1)+,d1
dirchk_jp2:
		and.l	#$DFDFDF,d1
		move.l	a2,a0
dirchk_lp1:
		moveq.l	#0,d0
		move.b	(a0),d0
		beq	dirchk_chker
		move.l	(a0)+,d2
		and.l	#$DFDFDF,d2
		cmp.l	d1,d2
		beq	dirchk_done
		bra	dirchk_lp1

dirchk_chker:
		moveq.l	#-1,d0
dirchk_done:
		movem.l	(sp)+,d1-d2/a0-a2
		rts


*==================================================
*�^�C�g������������
*	d0.l -> �^�C�g���擾�����t�@�C���̔ԍ�
*		���Ȃ�A�����I��
*	a0.l -> �Ή�����A�h���X
*==================================================

SEARCH_TITLE:
		move.l	d1,-(sp)
		bsr	MIKEN_CHECK			*���������邩�Ȃ��`���H
		tst.l	d0
		bmi	search_title90
		move.l	d0,d1
		bsr	CHECK_DOCFILE			*�h�L�������g�̗L���`�F�b�N
		bsr	GET_TITLE			*�^�C�g���ǂݍ���
		move.l	d1,d0
search_title90:
		move.l	(sp)+,d1
		rts


*==================================================
*	���l�h�j�d�m�Q�b�g�d�b�j
*�@�\�F�^�C�g���������̃o�b�t�@�ʒu�����߂�
*���́F�Ȃ�
*�o�́F	�c�O	�o�b�t�@�ʒu�^���̏ꍇ�͖������Ȃ�
*	�`�O	�Ή�����A�h���X
*�Q�l�FSEL_BSCH���珇�ɒ��׎n�߂�
*==================================================

MIKEN_CHECK:
		move.l	d1,-(sp)

		move.w	SEL_BSCH(a6),d1			*�����J�n�ʒu�����߂�
		cmp.w	SEL_BMAX(a6),d1
		bcs	miken_check01
		move.w	SEL_BTOP(a6),d1
miken_check01:
		move.w	d1,d0
		bsr	get_fnamebuf

		moveq	#-1,d0
		move.w	SEL_FMAX(a6),d2
		beq	miken_check90
		subq.w	#1,d2
miken_check10:
		tst.b	DATA_KIND(a0)			*�f�[�^�t�@�C����
		ble	miken_check20
		tst.l	TITLE_ADR(a0)			*�^�C�g������������Ă��Ȃ����
		beq	miken_check30			*���̈ʒu��Ԃ�
miken_check20:
		addq.w	#1,d1				*�o�b�t�@�̏I���ɗ�����A
		cmp.w	SEL_BMAX(a6),d1
		bne	miken_check21
		move.w	SEL_BTOP(a6),d1			*�o�b�t�@�̐擪�֖߂�
		move.w	d1,d0
		bsr	get_fnamebuf
		bra	miken_check22
miken_check21:
		lea	32(a0),a0
miken_check22:
		dbra	d2,miken_check10
		moveq	#-1,d0
		bra	miken_check90

miken_check30:
		moveq	#0,d0
		move.w	d1,d0
		addq.w	#1,d1
		move.w	d1,SEL_BSCH(a6)
miken_check90:
		move.l	(sp)+,d1
		rts


*==================================================
*�h�L�������g�L���`�F�b�N
*	a0.l <- �t�@�C���l�[���o�b�t�@
*	d0.l -> �h�L�������g�̗L��(0:�� ����ȊO:�L)
*		DOC_FLAG�ɂ��Z�b�g�����
*==================================================

CHECK_DOCFILE:
		movem.l	d1/a0-a2,-(sp)
		link	a5,#-24
		moveq	#0,d1
		movea.l	a0,a2
		lea	FILE_NAME(a2),a0		*�g���q��.doc�ɂ���
		movea.l	sp,a1
		bsr	change_ext_doc
		tst.l	d0
		bmi	check_docfile90
		move.w	#-1,-(sp)			*�����𒲂ׂ�
		move.l	a1,-(sp)
		DOS	_CHMOD
		addq.l	#6,sp
		tst.l	d0				*DOS�G���[���Ȃ��A
		bmi	check_docfile90
		btst.l	#5,d0				*�A�[�J�C�u�����������Ă����
		beq	check_docfile90
		moveq	#1,d1				*�h�L�������g�͑��݂���
check_docfile90:
		move.b	d1,DOC_FLAG(a2)
		unlk	a5
		movem.l	(sp)+,d1/a0-a2
		rts


*==================================================
*�g���q��.doc�ɂ���
*	a0.l <- �t�@�C����
*	a1.l <- ���ʂ̓���o�b�t�@
*	d0.l -> ���Ȃ�t�@�C�����s��
*==================================================

change_ext_doc:
		movem.l	a0-a1,-(sp)
		moveq	#23-1,d0
change_ext_doc10:
		move.b	(a0)+,(a1)+
		dbeq	d0,change_ext_doc10
		bne	change_ext_doc_err		*�t�@�C�������I����ĂȂ��I
		sub.w	#23-1,d0
		neg.w	d0
		subq.w	#1,d0
		bmi	change_ext_doc_err		*�t�@�C�����������I
change_ext_doc20:
		cmpi.b	#'.',-(a1)
		dbeq	d0,change_ext_doc20
		bne	change_ext_doc_err		*�g���q��������Ȃ��I
		addq.l	#1,a1
		move.b	#'d',(a1)+
		move.b	#'o',(a1)+
		move.b	#'c',(a1)+
		clr.b	(a1)
		movem.l	(sp)+,a0-a1
		moveq	#0,d0
		rts

change_ext_doc_err:
		movem.l	(sp)+,a0-a1
		moveq	#-1,d0
		rts


*==================================================
*�^�C�g���擾
*	a0.l <- �t�@�C���l�[���o�b�t�@
*==================================================

GET_TITLE:
		movem.l	d0-d2/a0-a1,-(sp)
		link	a5,#-256
		movea.l	sp,a1
		movea.l	a0,a2
		lea	FILE_NAME(a2),a0		*�t�@�C���̓��������ǂ��
		bsr	READ_FILEBUFF
		tst.l	d0
		bpl	get_title10
		lea	ERROR_TITLE(pc),a0		*�G���[�Ȃ�G���[�^�C�g���o�^
		move.l	a0,TITLE_ADR(a2)
		bra	get_title90
get_title10:
		move.b	DATA_KIND(a2),d0		*�g���q�ɑΉ������T�u�փW�����v
		cmpi.b	#_EXTMAX,d0
		bls	get_title11
		moveq	#0,d0
get_title11:
		ext.w	d0
		add.w	d0,d0
		lea	title_jmp(pc),a0
		move.w	(a0,d0.w),d0
		jsr	(a0,d0.w)
get_title20:
		movea.l	sp,a0				*�^�C�g���o�^
		bsr	COPY_TITLE
		move.l	d0,TITLE_ADR(a2)
get_title90:
		unlk	a5
		movem.l	(sp)+,d0-d2/a0-a1
		rts

ERROR_TITLE:	.dc.b	'- file read error -',0
		.even

title_jmp:
		.dc.w	title_non-title_jmp	* 0:none
		.dc.w	title_mdx-title_jmp	* 1:MDX
		.dc.w	title_mdx-title_jmp	* 2:MDR
		.dc.w	title_rcp-title_jmp	* 3:RCP
		.dc.w	title_rcp-title_jmp	* 4:R36
		.dc.w	title_mdf-title_jmp	* 5:MDF
		.dc.w	title_mcp-title_jmp	* 6:MCP
		.dc.w	title_mdx-title_jmp	* 7:MDI
		.dc.w	title_sng-title_jmp	* 8:SNG
		.dc.w	title_smf-title_jmp	* 9:MID
		.dc.w	title_smf-title_jmp	*10:STD
		.dc.w	title_smf-title_jmp	*11:MFF
		.dc.w	title_smf-title_jmp	*12:SMF
		.dc.w	title_non-title_jmp	*13:SEQ
		.dc.w	title_mdx-title_jmp	*14:MDZ
		.dc.w	title_mdn-title_jmp	*15:MDN
		.dc.w	title_kmd-title_jmp	*16:KMD
		.dc.w	title_zms-title_jmp	*17:ZMS
		.dc.w	title_zmd-title_jmp	*18:ZMD
		.dc.w	title_zms-title_jmp	*19:OPM
		.dc.w	title_mdf-title_jmp	*20:ZDF
		.dc.w	title_non-title_jmp	*21:MM2
		.dc.w	title_non-title_jmp	*22:MMC
		.dc.w	title_non-title_jmp	*23:MDC
		.dc.w	title_pic-title_jmp	*PIC
		.dc.w	title_mag-title_jmp	*MAG
		.dc.w	title_pi-title_jmp	*PI
		.dc.w	title_jpg-title_jmp	*JPG

*----------------------------------------
title_non:
		clr.b	(a1)
		rts

*----------------------------------------
title_mdx:
		lea	FILE_BUFF(a6),a0
		moveq	#72-1,d1
title_mdx10:
		move.b	(a0)+,d0
		beq	title_mdx20			*$00,$0D,$0A,$1A�ŏI��
		cmpi.b	#$0D,d0
		beq	title_mdx20
		cmpi.b	#$0A,d0
		beq	title_mdx20
		cmpi.b	#$1A,d0
		beq	title_mdx20
		move.b	d0,(a1)+
		dbra	d1,title_mdx10
title_mdx20:
		clr.b	(a1)
		rts

*----------------------------------------
title_rcp:
		lea	FILE_BUFF+32(a6),a0
		moveq	#64-1,d1
title_rcp10:
		move.b	(a0)+,d0
		beq	title_rcp20			*$00�ŏI��
		move.b	d0,(a1)+
		dbra	d1,title_rcp10
title_rcp20:
		clr.b	(a1)
		rts

*----------------------------------------
title_mcp:
		lea	FILE_BUFF+2(a6),a0
		moveq	#30-1,d1
title_mcp10:
		move.b	(a0)+,(a1)+
		dbra	d1,title_mcp10
		clr.b	(a1)
		rts

*----------------------------------------
title_mdf:
		lea	FILE_BUFF+6(a6),a0
		moveq	#72-1,d1
title_mdf10:
		move.b	(a0)+,d0
		beq	title_mdf20			*$00,$0D,$0A,$1A�ŏI��
		cmpi.b	#$0D,d0
		beq	title_mdf20
		cmpi.b	#$0A,d0
		beq	title_mdf20
		cmpi.b	#$1A,d0
		beq	title_mdf20
		move.b	d0,(a1)+
		dbra	d1,title_mdf10
title_mdf20:
		clr.b	(a1)
		rts
*----------------------------------------
title_sng:
		lea	FILE_BUFF(a6),a0
		cmpi.l	#'BALL',(a0)
		bne	title_sng_mro
		cmpi.l	#'ADE ',4(a0)
		bne	title_sng_mro
		cmpi.l	#'SONG',8(a0)
		bne	title_sng_mro

		moveq	#16-1,d1
title_sng10:
		move.b	(a0)+,d0
		beq	title_sng20			*$00�ŏI��
		move.b	d0,(a1)+
		dbra	d1,title_sng10
title_sng20:
		clr.b	(a1)
		rts

title_sng_mro:
		cmpi.b	#$0A,(a0)+			*2�s�ڂ�T��
		bne	title_sng_mro
		moveq	#72-1,d1
title_sng_mro10:
		move.b	(a0)+,d0
		beq	title_sng_mro20			*$00,$0D,$0A,$1A�ŏI��
		cmpi.b	#$0D,d0
		beq	title_sng_mro20
		cmpi.b	#$0A,d0
		beq	title_sng_mro20
		cmpi.b	#$1A,d0
		beq	title_sng_mro20
		move.b	d0,(a1)+
		dbra	d1,title_sng_mro10
title_sng_mro20:
		clr.b	(a1)
		rts

*----------------------------------------
Getlong		.macro				*(a0)���烍���O���[�h��d0�ɂƂ��Ă���
.if 0
		move.b	(a0)+,d0		*�f���ȃR�[�f�B���O��
		lsl.l	#8,d0
		move.b	(a0)+,d0
		lsl.l	#8,d0
		move.b	(a0)+,d0
		lsl.l	#8,d0
		move.b	(a0)+,d0
		subq.l	#4,d1
		bcs	title_smf90
.else
		move.b	(a0)+,-(sp)		*�Ƒ��ȃX�^�b�N�Z��
		move.w	(sp)+,d0
		move.b	(a0)+,d0
		swap	d0
		move.b	(a0)+,-(sp)
		move.w	(sp)+,d0
		move.b	(a0)+,d0
		subq.l	#4,d1
		bcs	title_smf90
.endif
		.endm

title_smf:
		movem.l	d1-d4/a2-a3,-(sp)
		lea	FILE_BUFF(a6),a0
		lea	title_smf_dum(pc),a2
		movea.l	a2,a3
		moveq	#0,d2
		moveq	#0,d3
		move.l	#1024-1,d1
		Getlong				*�w�b�_�u���b�N���΂�
		cmpi.l	#'MThd',d0
		bne	title_smf90
title_smf10:
		Getlong
		sub.l	d0,d1			*�g���b�N�u���b�N��T��
		bls	title_smf90
		adda.l	d0,a0
		Getlong
		cmpi.l	#'MTrk',d0
		bne	title_smf10
		Getlong
title_smf20:
		bsr	getvarlen		*delta-time��΂�
		tst.l	d0
		bne	title_smf30
		tst.l	d1
		blt	title_smf30
		subq.l	#2,d1			*���^�C�x���g���擾
		bcs	title_smf30
		cmpi.b	#$ff,(a0)+
		bne	title_smf30
		move.b	(a0)+,d4
		bsr	getvarlen
		tst.l	d1
		blt	title_smf30
title_smf21:
		cmpi.b	#$01,d4			*FF 01(�ėp�e�L�X�g�C�x���g�j��
		bne	title_smf22
		tst.b	(a2)
		bne	title_smf29
		movea.l	a0,a2
		move.l	d0,d2
		bra	title_smf29
title_smf22:
		cmpi.b	#$02,d4			*FF 02(���쌠�\���j��
		bne	title_smf23
		movea.l	a0,a3
		move.l	d0,d3
		bra	title_smf29
title_smf23:
		cmpi.b	#$03,d4			*FF 03(�V�[�P���X��)�Ȃ�A�A�h���X�ۑ�
		bne	title_smf29
		movea.l	a0,a2
		move.l	d0,d2
title_smf29:
		adda.l	d0,a0			*����ȊO�Ȃ�X�L�b�v���ă��[�v
		sub.l	d0,d1
		bcc	title_smf20

title_smf30:
		clr.b	(a2,d2.l)
		clr.b	(a3,d3.l)
		moveq	#72-1,d1
		tst.l	d2
		beq	title_smf32
title_smf31:
		move.b	(a2)+,(a1)+		*�V�[�P���X�����R�s�[
		dbeq	d1,title_smf31
		bne	title_smf90
		move.b	#' ',-1(a1)
title_smf32
		move.b	(a3)+,(a1)+		*���쌠�\�����R�s�[
		dbeq	d1,title_smf32

title_smf90:
		clr.b	(a1)
		movem.l	(sp)+,d1-d4/a2-a3
		rts

getvarlen:
		movem.l	d2,-(sp)
		moveq	#0,d0
get_varlen10:
		subq.l	#1,d1
		blt	get_varlen90
		move.b	(a0)+,d2
		bpl	get_varlen20
		andi.b	#$7f,d2
		or.b	d2,d0
		lsl.l	#7,d0
		bra	get_varlen10
get_varlen20:
		or.b	d2,d0
get_varlen90:
		movem.l	(sp)+,d2
		rts

title_smf_dum:	.dc.w	0


*----------------------------------------
title_mdn:
		lea	FILE_BUFF+64(a6),a0
		moveq	#72-1,d1
title_mdn10:
		move.b	(a0)+,d0
		beq	title_mdn20			*$00�Ń^�C�g���I��
		move.b	d0,(a1)+
		dbra	d1,title_mdn10
		bra	title_mdn60
title_mdn20:
		move.b	#' ',(a1)+
title_mdn30:
		move.b	(a0)+,d0
		beq	title_mdn40			*$00�ō�ȎҏI��
		move.b	d0,(a1)+
		dbra	d1,title_mdn30
		bra	title_mdn60
title_mdn40:
		move.b	#' ',(a1)+
title_mdn50:
		move.b	(a0)+,d0
		beq	title_mdn60			*$00�Ő���ҏI��
		move.b	d0,(a1)+
		dbra	d1,title_mdn50
title_mdn60
		clr.b	(a1)
		rts

*----------------------------------------
title_kmd:
		lea	FILE_BUFF+42(a6),a0
		moveq	#72-1,d1
title_kmd10:
		move.b	(a0)+,d0
		beq	title_kmd20			*$00�ŏI��
		move.b	d0,(a1)+
		dbra	d1,title_kmd10
title_kmd20:
		clr.b	(a1)
		rts

*----------------------------------------
title_zms:						*ZMUSIC�́A�Ȃɂ��Ɩʓ|�Ȃ̂�
		move.l	a2,-(sp)			*�݂�A���̃R�[�h�̒����i�΁j
		lea	FILE_BUFF(a6),a0		*MID�t�@�C��������Ȃ����ǂ�(^^;)
		move.w	#1024-1,d2

title_zms10:
		cmpi.b	#' ',(a0)+			*�X�y�[�X���΂��A
		dbhi	d2,title_zms10
		bls	title_zms_none

		subq.w	#1,d2
		bcs	title_zms_none
		move.b	-1(a0),d0			*�s����'.'��'#'�Ȃ�΁A
		cmpi.b	#'.',d0
		beq	title_zms20
		cmpi.b	#'#',d0
		bne	title_zms22

title_zms20:
		lea	comment_str(pc),a2
title_zms21:
		move.b	(a2)+,d0			*'COMMENT'�����邩�`�F�b�N����
		beq	title_zms30
		move.b	(a0)+,d1
		subq.w	#1,d2
		bcs	title_zms_none
		andi.b	#$DF,d1
		cmp.b	d0,d1
		beq	title_zms21
title_zms22:
		cmpi.b	#$0A,(a0)+			*�Ȃ���΁A���̍s��
		dbeq	d2,title_zms22
		bne	title_zms_none
		subq.w	#1,d2
		bcs	title_zms_none
		bra	title_zms10

title_zms30:
		move.b	(a0)+,d0			*����΁A�X�y�[�X��΂�
		subq.w	#1,d2
		bcs	title_zms50
		cmpi.b	#' ',d0
		beq	title_zms30
		cmpi.b	#9,d0
		beq	title_zms30

		addq.w	#1,d2
		subq.l	#1,a0				*72�����^�C�g���擾
		moveq	#72-1,d1
title_zms40:
		move.b	(a0)+,d0
		beq	title_zms50			*$00/$0D/$0A/$1A�ŏI��
		cmpi.b	#$0D,d0
		beq	title_zms50
		cmpi.b	#$0A,d0
		beq	title_zms50
		cmpi.b	#$1A,d0
		beq	title_zms50
		subq.w	#1,d2
		bcs	title_zms50
		move.b	d0,(a1)+
		dbra	d1,title_zms40
title_zms50:
title_zms_none:
		clr.b	(a1)
		move.l	(sp)+,a2
		rts

comment_str:	.dc.b	'COMMENT',0

*----------------------------------------
title_zmd:				*ZMD���^�C�g���̈ʒu���炢���߂Ă����ė~��������
		lea	FILE_BUFF+8(a6),a0

		cmpi.b	#$7F,(a0)+			*�擪��$7F���Ȃ��Ƃ��߂Ȃ�
		bne	title_zmd20

		moveq	#72-1,d1
title_zmd10:
		move.b	(a0)+,d0
		beq	title_zmd20			*$00�ŏI��
		move.b	d0,(a1)+
		dbra	d1,title_zmd10
title_zmd20:
		clr.b	(a1)
		rts

*----------------------------------------
title_pic:
		lea	FILE_BUFF(a6),a0
		cmpi.b	#'P',(a0)+
		bne	title_pic20
		cmpi.b	#'I',(a0)+
		bne	title_pic20
		cmpi.b	#'C',(a0)+
		bne	title_pic20
		moveq	#72-1,d1
title_pic10:
		move.b	(a0)+,d0
		beq	title_pic20			*$00,$0d,$1a�ŏI��
		cmpi.b	#$0d,d0
		beq	title_pic20
		cmpi.b	#$1a,d0
		beq	title_pic20
		cmpi.b	#' ',d0				*�R���g���[���R�[�h�͍폜
		bcs	title_pic10
		move.b	d0,(a1)+
		dbra	d1,title_pic10
title_pic20:
		clr.b	(a1)
		rts

*----------------------------------------
title_pi:
		lea	FILE_BUFF(a6),a0
		cmpi.b	#'P',(a0)+
		bne	title_pi20
		cmpi.b	#'i',(a0)+
		bne	title_pi20
		moveq	#72-1,d1
title_pi10:
		move.b	(a0)+,d0
		beq	title_pi20			*$00,$0d,$1a�ŏI��
		cmpi.b	#$0d,d0
		beq	title_pi20
		cmpi.b	#$1a,d0
		beq	title_pi20
		cmpi.b	#' ',d0				*�R���g���[���R�[�h�͍폜
		bcs	title_pi10
		move.b	d0,(a1)+
		dbra	d1,title_pi10
title_pi20:
		clr.b	(a1)
		rts

*----------------------------------------
title_mag:
		lea	FILE_BUFF(a6),a0
		cmpi.l	#'MAKI',(a0)+
		bne	title_mag20
		cmpi.l	#'02  ',(a0)+
		bne	title_mag20
		moveq	#72-1,d1
title_mag10:
		move.b	(a0)+,d0
		beq	title_mag20			*$00,$0d,$1a�ŏI��
		cmpi.b	#$0d,d0
		beq	title_mag20
		cmpi.b	#$1a,d0
		beq	title_mag20
		cmpi.b	#' ',d0				*�R���g���[���R�[�h�͍폜
		bcs	title_mag10
		move.b	d0,(a1)+
		dbra	d1,title_mag10
title_mag20:
		clr.b	(a1)
		rts


*----------------------------------------
title_jpg:
		lea	FILE_BUFF(a6),a0
		move.w	#1024-1,d2

title_jpg10:
		cmpi.b	#$ff,(a0)+		*�摜�J�n�R�[�h(SOI:FFD8)��T��
		dbeq	d2,title_jpg10
		bne	title_jpg90
		subq.w	#1,d2
		bcs	title_jpg90
		cmpi.b	#$d8,(a0)+
		dbeq	d2,title_jpg10
		bne	title_jpg90
		subq.w	#1,d2
		bcs	title_jpg90
title_jpg11:
		move.b	(a0)+,d0		*�R�����g�u���b�N(FFFE)��T��
		lsl.w	#8,d0
		move.b	(a0)+,d0
		cmpi.w	#$fffe,d0
		beq	title_jpg19
		move.b	(a0)+,d0
		lsl.w	#8,d0
		move.b	(a0)+,d0
		lea	-2(a0,d0.w),a0
		addq.w	#2,d0
		sub.w	d0,d2
		bcc	title_jpg11
		bra	title_jpg90
title_jpg19:

title_jpg20:
		move.b	(a0)+,d1		*�݂�������R�����g���o�b�t�@�ɃR�s�[
		lsl.w	#8,d1
		move.b	(a0)+,d1
		subq.w	#3,d1
		cmp.w	d2,d1
		bls	title_jpg21
		move.w	d2,d1
title_jpg21:
		cmpi.w	#72-1,d1
		bls	title_jpg23
		moveq	#72-1,d1
title_jpg23:
		move.b	(a0)+,d0
		beq	title_jpg90			*$00,$0d,$1a�ŏI��
		cmpi.b	#$0d,d0
		beq	title_jpg90
		cmpi.b	#$1a,d0
		beq	title_jpg90
		cmpi.b	#' ',d0				*�R���g���[���R�[�h�͍폜
		bcs	title_jpg24
		move.b	d0,(a1)+
title_jpg24:
		dbra	d1,title_jpg23
title_jpg90:
		clr.b	(a1)
		rts


*==================================================
*�t�@�C���o�b�t�@��1024�o�C�g�ǂݍ���
*	a0.l <- �t�@�C���l�[��
*	d0.l -> ���Ȃ�G���[
*==================================================

READ_FILEBUFF:
		movem.l	d1,-(sp)

		clr.w	-(sp)		*�I�[�v��
		move.l	a0,-(sp)
		DOS	_OPEN
		addq.l	#6,sp
		move.l	d0,d1
		bmi	read_filebuff90

		move.l	#1024,-(sp)	*�ǂݍ���
		pea	FILE_BUFF(a6)
		move.w	d1,-(sp)
		DOS	_READ
		lea.l	10(sp),sp
		tst.l	d0
		bmi	read_filebuff90

		move.w	d1,-(sp)	*�N���[�Y
		DOS	_CLOSE
		addq.l	#2,sp

read_filebuff90:
		movem.l	(sp)+,d1
		rts

*==================================================
*������R�s�[
*	COPY_STRING( dest, sour )
*==================================================

COPY_STRING:
		movem.l	a0-a1,-(sp)
		movem.l	12(sp),a0-a1
copy_string10:
		move.b	(a1)+,(a0)+
		bne	copy_string10
		movem.l	(sp)+,a0-a1
		rts

