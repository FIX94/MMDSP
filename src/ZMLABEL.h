			.nlist
*���[�N�G���A
wk_size:	equ	256	*�e�g���b�N�̉��t���̃��[�N�T�C�Y(�ύX�s��)
wk_size2:	equ	8	*���[�N�T�C�Y���Q�̉��悩(�ύX�s��)

p_on_count:	equ	$00	*.w step time		!!! ���Ԃ�ς��Ă͂Ȃ�Ȃ�
p_gate_time:	equ	$02	*.w gate time		!!!
p_data_pointer:	equ	$04	*.l ���݂̃R�}���h�|�C���^
p_fo_spd:	equ	$08	*.b �t�F�[�h�A�E�g�X�s�[�h
p_ch:		equ	$09	*.b �A�T�C������Ă���`�����l��
p_not_empty:	equ	$0a	*.b �g���b�N�̐���(-1=dead/1=play end/0=alive)
p_amod_step:	equ	$0b	*.b AM�̃X�e�b�v���[�N
p_mstep_tbl:	equ	$0c	*.w �e�|�C���g�ɒu����Ӽޭڰ��݃X�e�b�v�l($0c�`$1b)
p_wvpm_loop:	equ	$0c	*.l �g�`���������[�v�J�n�A�h���X
p_wvpm_lpmd:	equ	$10	*.w �g�`���������[�v���[�h
p_altp_flg:	equ	$12	*.b �g�`�������������[�h�t���O
p_fo_mode:	equ	$1c	*.b fade out flag (0=off/1�`127=on)	!!!
p_pgm:		equ	$1d	*.b last tone number(0-199)		!!!
p_pan:		equ	$1e	*.b last panpot(0�`3)			!!!
p_vol:		equ	$1f	*.b last volume(127�`0)			!!!
p_mrvs_tbl:	equ	$20	*.b �e�|�C���g�ɒu����Ӽޭڰ��ݕ␳�l($20�`$27)
p_wvpm_point:	equ	$20	*.l �g�`���������݂̃|�C���^
p_wvpm_end:	equ	$24	*.l �g�`�������I���A�h���X
p_sp_tie:	equ	$28	*.w MIDI�̃X�y�V�����E�^�C�p���[�N
p_om:		equ	$28	*.b �I�y���[�^�}�X�N(&b0000-&b1111)
p_sync:		equ	$29	*.b LFO�̃V���N�X�C�b�`(0=off,ne=on)
p_af:		equ	$2a	*.b AL/FB
p_se_mode:	equ	$2b	*.b se mode or not($ff=normal/0�`=se mode)
p_pmod_tbl:	equ	$2c	*.w Ӽޭڰ��ݒlð���($2c�`$3b)
p_total:	equ	$3c	*.l �g�[�^���X�e�b�v�^�C��
p_fo_lvl:	equ	$40	*.b �o�̓p�[�Z���e�[�W(0-128)
*		equ	$41	*.b
p_note:		equ	$42	*.b �ߋ���ɰĵ݂������K�B�W��($42�`$49)	!!!PCM ch�ȊO�ł͔j��
p_extra_ch:	equ	$4a	*.b �g������ٔԍ�(PCM8 MODE��p0-7)   ��!!!����邱�Ƃ�����
p_aftc_n:	equ	$4b	*.b ����������ݽ�̃|�C���^(0�`7)
p_bend_rng_f:	equ	$4c	*.w �I�[�g�x���h�̃����W(FM)
p_bend_rng_m:	equ	$4e	*.w �I�[�g�x���h�̃����W(MIDI)
p_detune_f:	equ	$50	*.w �f�`���[��(FM�p�̒l)	!!!���Ԃ������Ă͂Ȃ�Ȃ�
p_detune_m:	equ	$52	*.w �f�`���[��(MIDI�p�̒l)	!!!
p_port_dly:	equ	$54	*.w �|���^�����g�f�B���C	###���Ԃ������Ă͂Ȃ�Ȃ�
p_bend_dly:	equ	$56	*.w �x���h�f�B���C�l		###
p_port_work:	equ	$58	*.b �|���^�����g�p�␳���[�N		!!!����3�̃��[�N��
p_port_rvs:	equ	$59	*.b �|���^�����g�p�␳�p�����[�^	!!!���Ԃ�ς��Ă�
p_port_work2:	equ	$5a	*.w �������/�������ޗp ���݂̃x���h�l	!!!�Ȃ�Ȃ�
p_amod_tbl:	equ	$5c	*.b �`�l�lð���($5c�`$63)
p_arcc_tbl:	equ	$5c	*.b arcc�lð���($5c�`$63)
p_arvs_tbl:	equ	$64	*.b amod�p�␳�l(FM)�e�[�u��($64�`$6b)
p_wvam_point:	equ	$64	*.l �g�`���������݂̃|�C���^
p_wvam_end:	equ	$68	*.l �g�`�������I���A�h���X
p_pmod_work4:	equ	$6c	*.w Ӽޭڰ��ݽ�߰��ܰ�(FM)
p_port_flg:	equ	$6e	*.w ������ĵ݂��̂�(0=off/�␳�������-1 or 1) !!! ���Ԃ�
p_bend_flg:	equ	$70	*.w ����ނ��݂��̂�(0=off/�␳�������-1 or 1) !!! �ς��������
p_aftc_tbl:	equ	$72	*.b ����������ݽ�l�e�[�u��($72�`$79)
p_aftc_dly:	equ	$7a	*.w ����������ݽ�ިڲ�l
p_aftc_work:	equ	$7c	*.w ����������ݽ�ިڲܰ�
p_astep_tbl:	equ	$7e	*.b �e�|�C���g�ɒu����AM�X�e�b�v�l($7e�`$85)
p_wvam_loop:	equ	$7e	*.l �g�`���������[�v�J�n�A�h���X
p_wvam_lpmd:	equ	$82	*.w �g�`���������[�v���[�h
p_alta_flg:	equ	$84	*.b �g�`�������������[�h�t���O
p_pmod_step2:	equ	$86	*.w Ӽޭڰ��ݽï��ܰ�(FM)	!!!
p_pmod_work:	equ	$88	*.w Ӽޭڰ����ިڲܰ�(MIDI/FM)	!!!�ʒu�����Ԃ�
p_pmod_work2:	equ	$8a	*.w Ӽޭڰ����߲��ܰ�(MIDI/FM)	!!!�������Ă�
p_pmod_work3:	equ	$8c	*.b Ӽޭڰ��ݗp�␳�l���[�N(FM)	!!!�Ȃ�Ȃ�
p_pmod_n:	equ	$8d	*.b Ӽޭڰ���ð����߲��(MIDI/FM)!!!
p_sync_wk:	equ	$8e	*.b ���������R�}���h�p���[�N			!!!
p_rpt_last?:	equ	$8f	*.b �J��Ԃ����Ōォ�ǂ���(bit pattern)		!!!
p_@b_range:	equ	$90	*.b �x���h�����W(�����l=12)			!!!
p_arcc:		equ	$91	*.b ARCC�̃R���g���[���i���o�[(MIDI)		!!!
p_pmod_flg:	equ	$92	*.w Ӽޭڰ����׸�(FM��ܰ��/MIDI���޲�)	!!!���Ԃ������Ă�
p_pmod_sw:	equ	$94	*.b �s�b�`Ӽޭڰ��݃X�C�b�`(���␳����)	!!!�Ȃ�Ȃ�
p_amod_sw:	equ	$95	*.b AMOD�X�C�b�`(0=off,ne=on)		!!!
p_arcc_sw:	equ	$95	*.b ARCC�X�C�b�`(0=off,ne=on)		!!!
p_bend_sw:	equ	$96	*.b �I�[�g�x���h���A�N�e�B�u��(0=no/�x���h����=yes)	!!!
p_aftc_flg:	equ	$97	*.b ����������ݽ�׸� (0=off/$ff=on)			!!!
p_md_flg:	equ	$98	*d0 @b:����ޒl��ؾ�Ă��ׂ����ǂ���(MIDI��p 0=no/1=yes)	!!!
				*d1 @m:Ӽޭڰ��ݒl��ؾ�Ă��邩���Ȃ���(MIDI��p 0=no/1=yes)
				*d2 @a:AM�l��ؾ�Ă��邩���Ȃ���(MIDI��p 0=no/1=yes)
				*d3 midi tie mode
				*d4 pmd first time? or not
				*d5 amd first time? or not
				*d6 pmd hold or not
				*d7 amd hold or not
p_waon_flg:	equ	$99	*.b �a��������Ƃ��V���O����(0=single/$ff=chord)	!!!
p_pmod_dly:	equ	$9a	*.w ���W�����[�V�����f�B���C�l(FM/MIDI)	!!!���Ԃ������Ă�
p_amod_dly:	equ	$9c	*.w �`�l�f�B���C�l(FM)			!!!�Ȃ�Ȃ�
p_arcc_dly:	equ	$9c	*.w ARCC�f�B���C�l(MIDI)		!!!�Ȃ�Ȃ�
p_port_step:	equ	$9e	*.w �|���^�����g�p���Z���[�N
p_bank_msb:	equ	$a0	*.b MIDI bank MSB
p_ol1:		equ	$a0	*.b (OUT PUT LEVEL OP1)
p_bank_lsb:	equ	$a1	*.b MIDI bank LSB
p_ol2:		equ	$a1	*.b (OUT PUT LEVEL OP2)
p_effect1:	equ	$a2	*.b effect parameter 1
p_ol3:		equ	$a2	*.b (OUT PUT LEVEL OP3)
p_effect3:	equ	$a3	*.b effect parameter 3
p_ol4:		equ	$a3	*.b (OUT PUT LEVEL OP4)
p_d6_last:	equ	$a4	*.b d6.b�̃��[�N(MIDI)
p_cf:		equ	$a4	*.b (CARRIER ���ǂ����̃t���O bit pattern:bit=1 carrier1)
p_amod_step2:	equ	$a5	*.b AM�ï��ܰ�
p_pb_add:	equ	$a6	*.b ���g�p					!!!
p_vset_flg:	equ	$a7	*.b �{�����[�����Z�b�g�t���O(FM)		!!!
p_arcc_rst:	equ	$a8	*.b ARCC�̃��Z�b�g�o�����[(default:0)		!!!
p_arcc_def:	equ	$a9	*.b ARCC�f�t�H���g�l(default:127)		!!!
p_coda_ptr:	equ	$aa	*.l [coda]�̂���ʒu
p_pointer:	equ	$ae	*.l [segno]�̂���ʒu
p_do_loop_ptr:	equ	$b2	*.l [do]�̂���ʒu
p_pmod_work5:	equ	$b6	*.w �ï����т�1/8(FM)
p_pmod_work6:	equ	$b8	*.w �ï����т�1/8���[�N(FM)
p_amod_flg:	equ	$ba	*.b ARCC�׸�(FM)			!!!���Ԃ�
p_arcc_flg:	equ	$ba	*.b ARCC�׸�(MIDI)			!!!���Ԃ�
p_aftc_sw:	equ	$bb	*.b ����������ݽ�̽���(0=off/$ff=on)	!!!�ς��Ă�
p_dumper:	equ	$bc	*.b dumper on or off (0=off/$ff=on)	!!!�Ȃ�Ȃ�
p_tie_flg:	equ	$bd	*.b �^�C��������(0=no/ff=yes)		!!!
p_pmod_dpt:	equ	$be	*.w �߯�Ӽޭڰ������߽(FM)			!!!
p_seq_flag:	equ	$c0	*.b []�R�}���h�n�̏����t���O�r�b�g�p�^�[��	!!!
				*d0:[d.c.]�������������Ƃ����邩(0=no/1=yes)
				*d1:[fine]���������ׂ����ǂ���(0=no/1=yes)
				*d2:[coda]���ȑO�ɐݒ肵�����Ƃ����邩(0=no/1=yes)
				*d3:[segno]�����邩�Ȃ����̃t���O(0=no/1=yes)
				*d4:[d.s.]�������������Ƃ����邩(0=no/1=yes)
				*d5 [!]�R�}���h���[�N(0=normal/1=jumping)
				*d6:key off bit
				*d7:key on bit
p_do_loop_flag:	equ	$c1	*.b [do]���ȑO�ɐݒ肳��Ă��邩/���[�v��	!!!
p_pmod_spd:	equ	$c2	*.w �o�l�̂P�^�S����	!!!
p_amod_spd:	equ	$c4	*.w �`�l�̂P�^�S����	!!!
p_total_olp:	equ	$c6	*.l ٰ�ߊO��İ�ٽï�߲�
p_pmod_step:	equ	$ca	*.w Ӽޭڰ��ݗp���Z���[�N
p_tie_pmod:	equ	$cc	*.b tie�̓r���Ńp�����[�^�`�F���W���s��ꂽ���ǂ���	!!!
p_tie_bend:	equ	$cd	*.b (0=no,$ff=yes)					!!!
p_tie_amod:	equ	$ce	*.b							!!!
p_tie_arcc:	equ	$ce	*.b							!!!
p_tie_aftc:	equ	$cf	*.b							!!!
p_pan2:		equ	$d0	*.b �p���|�b�g(FM/MIDI L 0�`M64�`127 R)	!!!
p_non_off:	equ	$d1	*.b �L�[�I�t�������[�h(0=no,$ff=yes)	!!!
p_frq:		equ	$d2	*.b ADPCM�̎��g��(0-6)			!!!
p_velo:		equ	$d3	*.b velocity(0-127)			!!!
p_amod_work4:	equ	$d4	*.w Ӽޭڰ��ݽ�߰��ܰ�(FM)
p_pmod_rvs:	equ	$d6	*.b ���W�����[�V�����p�␳���Ұ�
p_waon_dly:	equ	$d7	*.b �a���p�f�B���C�l
p_waon_work:	equ	$d8	*.b �a���p�f�B���C���[�N
p_waon_num:	equ	$d9	*.b ���Ԗڃm�[�m�[�g���L�[�I������̂�(minus=end)
p_note_last:	equ	$d9	*.b �m�[�g�̈ꎞ�ޔ�(MIDI)�����ɂ͋N���蓾�Ȃ�������S
p_rpt_cnt:	equ	$da	*.b repeat count work($da�`$e1)
p_maker:	equ	$e2	*.b Ұ��ID(MIDI)
p_device:	equ	$e3	*.b ���޲�ID(MIDI)
p_module:	equ	$e4	*.b Ӽޭ��ID(MIDI)
p_last_aft:	equ	$e5	*.b �O��̃A�t�^�[�^�b�`�l(FM��p)
p_amod_work:	equ	$e6	*.w AMOD�ިڲܰ�(FM)		!!!
p_arcc_work:	equ	$e6	*.w ARCC�ިڲܰ�(MIDI)		!!!
p_arcc_work2:	equ	$e8	*.b ARCC�߲��ܰ�(MIDI)		!!!
p_amod_work2:	equ	$e8	*.b AMOD�߲��ܰ�(FM)		!!!
p_amod_work3:	equ	$e9	*.b Ӽޭڰ��ݗp�␳�l���[�N(FM)	!!!
p_amod_work7:	equ	$ea	*.b �m�R�M���g��p���[�N!!!
p_amod_n:	equ	$eb	*.b AMð����߲��(FM)	!!!
p_arcc_n:	equ	$eb	*.b ARCCð����߲��(MIDI)!!!
p_arcc_work5:	equ	$ec	*.w �ï����т�1/8(FM)
p_amod_work5:	equ	$ec	*.w �ï����т�1/8(FM)
p_arcc_work6:	equ	$ee	*.w �ï����т�1/8���[�N(FM)
p_amod_work6:	equ	$ee	*.w �ï����т�1/8���[�N(FM)
p_pmod_wf:	equ	$f0	*.b �\�t�g�k�e�n(�o�l)�̔g�`�^�C�v(FM:-1,0,1)	!!!
p_amod_dpt:	equ	$f1	*.b FM����AMD�f�v�X				!!!
p_amod_wf:	equ	$f2	*.b �\�t�g�k�e�n(�`�l)�̔g�`�^�C�v(FM:-1,0,1)	!!!
p_dmp_n:	equ	$f3	*.b FM�����p�_���p�[�������[�N			!!!
p_pmod_omt:	equ	$f4	*.b 1/8-PMOD�̏ȗ��r�b�g�p�^�[��			!!!
p_arcc_omt:	equ	$f5	*.b 1/8-ARCC�̏ȗ��r�b�g�p�^�[��
p_amod_omt:	equ	$f5	*.b 1/8-AMOD�̏ȗ��r�b�g�p�^�[��			!!!
p_pmod_mode:	equ	$f6	*.b MIDI���W�����[�V�����̌`��(-1:normal/0:FM/1:MIDI)	!!!
p_arcc_mode:	equ	$f7	*.b MIDI ARCC�̌`��(-1:normal/1�`127:extended mode)	!!!
p_pmod_chain:	equ	$f8	*.b PM�̐ڑ��t���O
p_amod_chain:	equ	$f9	*.b AM�̐ڑ��t���O
p_velo_dmy:	equ	$fa	*.b �Վ��x���V�e�B�p���[�N				 !!!
p_waon_mark:	equ	$fb	*.b ������ق̃p�����[�^��ݒ肵����(0=not yet,1=done)	 !!!
p_marker:	equ	$fc	*.w ̪��ޱ�Ď��Ɏg�p (p_maker(a5)=se track or not,+1=flg)!!!
p_amod_rvs:	equ	$fe	*.b amod�p�␳�l(FM)
p_ne_buff:	equ	$ff	*.b p_not_empty�̈ꎞ�ޔ��ꏊ(se mode ��p���[�N)
p_user:		equ	$ff	*.b ���[�U�[�ėp���[�N

*�R���o�[�g���̃��[�N�G���A
cnv_wk_size:	equ	$8c	*�e�g���b�N��MML���߲ٗpܰ��T�C�Y(��΂ɋ���)

cv_data_adr:	equ	$00	*.l �R���p�C���f�[�^�|�C���^
cv_l_com:	equ	$04	*.w �f�t�H���g����
cv_oct:		equ	$06	*.b �I�N�^�[�u�l
cv_device:	equ	$07	*.b �o�̓f�o�C�X(0=internal ch / 1=adpcm / $ff=MIDI ch)
cv_len:		equ	$08	*.l �R���p�C���f�[�^�̌��݂̑��T�C�Y
cv_rep_cnt:	equ	$0c	*.b ���s�[�g�J�E���^�Ǘ����[�N($0c-$13)8��
cv_q_com:	equ	$14	*.w �Q�[�g�^�C��
cv_cnv_flg:	equ	$16	*.b �t���O���[�N
				*d0 ��ۼè���ݽ����(0=off/1=on)
				*d1 �Վ��x���V�e�B�����R�[�h�����t���O(0=off/1=on)
cv_velo_n:	equ	$17	*.b �x���V�e�B�V�[�P���X�p�|�C���^
cv_port_dly:	equ	$18	*.w �|���^�����g�p�f�B���C
cv_bend_dly:	equ	$1a	*.w �x���h�f�B���C
cv_ktrans:	equ	$1c	*.b �L�[�g�����X�|�[�Y
cv_rltv_velo:	equ	$1d	*.b ���΃x���V�e�B�l���[�N
cv_rltv_vol:	equ	$1e	*.b ���΃{�����[���l���[�N
cv_waon_dly:	equ	$1f	*.b �a���p�f�B���C
cv_velo2:	equ	$20	*.b �O��w�肳�ꂽ�x���V�e�B(fm�̏ꍇ�̓{�����[�����\��)
cv_k_sig:	equ	$21	*.b ����($21�`$27)7��
cv_rep_start:	equ	$28	*.l |:(OPMDRV.x�ƌ݊���ۂ���)
cv_rep_exit:	equ	$2c	*.l |n�p���[�N($2c�`$4b)8��
cv_rep_addr:	equ	$4c	*.6b���s�[�g�A�h���X�Ǘ��e�[�u��(.l,.w)($4c�`$7b)48Bytes
cv_velo:	equ	$7c	*.b �x���V�e�B�V�[�P���X�p���[�N($7c�`$8b)16��
*		equ	$8c	*.b

		.list
