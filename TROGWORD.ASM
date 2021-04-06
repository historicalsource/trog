	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGFADE.ASM'
	.TITLE	" <<< T R O G  -- WORD COMPRESSION >>>"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	     COPYRIGHT (C) 1990 MIDWAY MANUFACTURING COMPANY,		 *
* 	      MANUFACTURERS OF BALLY/MIDWAY AMUSEMENT GAMES.		 *
* 		         ALL RIGHTS RESERVED.				 *
* 									 *
**************************************************************************

	.INCLUDE	"MPROCEQU.ASM"	; MPROC equates
	.INCLUDE	"DISPEQU.ASM"	; Display processor equates
	.INCLUDE	"GSPINC.ASM"	; GSP assembler equates
	.INCLUDE	"SYSINC.ASM"	; Zunit system equates
	.INCLUDE	"TROGEQU.ASM"	; PALETTE HANDLER STUFF
	.INCLUDE	"TROGDICT.ASM"	; DICTIONARY OF WORDS
	.INCLUDE	"STRING.H"	; STRING ROUTINES
	.INCLUDE	"TROGSEQU.ASM"

**************************************************************************
*								         *
* 	DEFS AND REFS							 *
*								         *
**************************************************************************

	.DEF	DICT_LOOKUP
	.DEF	LM_XFINIS, L_XMESS
	
**************************************************************************
*								         *
* 	CODE START							 *
*								         *
**************************************************************************

	.TEXT
	.EVEN

**************************************************************************
*								         *
* 	LM_XFINIS							 *
* 									 *
* 	ENTRY								 *
* 		EVERYTHING LM_FINIS NEEDS				 *
* 									 *
* 	EXIT								 *
* 		WHATEVER LM_FINIS GIVES BACK				 *
* 									 *
* 	CALL								 *
* 		JSRP							 *
*								         *
**************************************************************************

LM_XFINIS
	CALLA	STRINGF
	MMTM	A12,A1,A3	;SAVE ROUTINE AND NEXT STRING PTR
	JSRPR	A1
	MMFM	A12,A1,A8	;RESTORE ROUTINE AND NEXT STRING (A8)
	RETP


**************************************************************************
*                                                                        *
*          L_MESS                                                        *
*                                                                        *
*          A8 POINTS AT MESS_MAC FOLLOWED BY MESSAGE TEXT.               *
*             POP ALL REGGIES LEAVING A8 POINTING AT TEXT.               *
*             AND JUMP TO THE TEXT PROCESSOR!                            *
*                                                                        *
*          THE MMFM POPS THE ROUTINE TO CALL INTO A1.                    *
*                                                                        *
*          YOU ***MUST*** USE JSRP TO GET HERE.                          *
*                                                                        *
**************************************************************************
L_XMESS_LOOP
	ADDI	8,A8			;PUSH BEYOND THIS BYTE
L_XMESS
	ADDI	0FH,A8			;IF IT ENDS IN OTHER THAN ZERO..
*					;KICK TO NEXT WORD (I.E. .EVEN)
	SRL	4,A8
	SLL	4,A8			;MASK FRACTIONAL WORD

	MMFM	A8,A1,A5,A9,A10,A11	;LOAD UP REGGIES FROM A8.
	MMFM	A8,A0			;YOU MAY SLEEP
	CALLA	STRINGF
	PUSHP	A3			; SAVE NEW TEXT LOCATION
	JSRPR	A1			;JSRP TO THE ROUTINE
	PULLP	A8
	MOVB	*A8,A0			;CHECK NEXT BYTE 0=DONE...1=MORE.
	JRNZ	L_XMESS_LOOP
	RETP


**************************************************************************
*								         *
* 	DICT_LOOKUP							 *
* 									 *
* 	ENTRY								 *
* 		A0	WORD NUMBER					 *
* 									 *
* 	EXIT								 *
* 		A8	POINTER TO WORD STRING				 *
* 									 *
* 	CALL								 *
* 		CALL							 *
*								         *
**************************************************************************

DICT_LOOKUP:
	MMTM	SP,A0
	CLR	A8			; "ASSUME ZERO"
	SLL	25,A0
	SRL	25,A0			; MASK ALL BUT LOW 7
	CMPI	W_LASTWORD,A0
	JRHI	DICT_RET		; BR = NOT A REAL WORD
	SLL	5,A0
	ADDI	LOOKUP_TAB,A0
	MOVE	*A0,A8,L
DICT_RET
	MOVE	A8,A8
	MMFM	SP,A0
	RETS

**************************************************************************
*								         *
* 	WORD TABLE							 *
*								         *
**************************************************************************

LOOKUP_TAB:
	.LONG	W_000,W_001,W_002,W_003,W_004,W_005,W_006,W_007
	.LONG	W_008,W_009,W_010,W_011,W_012,W_013,W_014,W_015
	.LONG	W_016,W_017,W_018,W_019,W_BLAH,W_020,W_021,W_022,W_023
	.LONG	W_024,W_025,W_026,W_027,W_028,W_029,W_030,W_031
	.LONG	W_032,W_033,W_034,W_035,W_036,W_037,W_038,W_039
	.LONG	W_040,W_041,W_042,W_043,W_044,W_045,W_046,W_047
	.LONG	W_048,W_049,W_050,W_051,W_052,W_053,W_054,W_055
	.LONG	W_056,W_057,W_058,W_059,W_060,W_061,W_062,W_063
	.LONG	W_064,W_065,W_066,W_067,W_068,W_069,W_070,W_071
	.LONG	W_072,W_073

W_000	.STRING	"FRANCE",0
W_001	.STRING	"GERMAN",0
W_002	.STRING	82H,0
W_003	.STRING	"CREDIT",0
W_004	.STRING	"GAME",0
W_005	.STRING	"ADJUSTMENT",0
W_006	.STRING	"CREDITS",0
W_007	.STRING	"PRICING",0
W_008	.STRING	"CUSTOM",0
W_009	.STRING	"FREE",0
W_010	.STRING	"PLAY",0
W_011	.STRING	"COIN",0
W_012	.STRING	"COINS",0
W_013	.STRING	"STANDARD",0
W_014	.STRING	"UNITS",0
W_015	.STRING	"CHUTE",0
W_016	.STRING "FACTORY SETTING",0
W_017	.STRING	"TIME",0
W_018	.STRING	"AUDITS",0
W_019	.STRING	"CLOSED",0
W_BLAH	.STRING	"CLEAR",0
W_020	.STRING	"TEST",0
W_021	.STRING	"AVERAGE",0
W_022	.STRING	"FOURTH",0
W_023	.STRING	"SWITCH",0
W_024	.STRING	"BOARD",0
W_025	.STRING	"SLOT",0
W_026	.STRING	"TONE",0
W_027	.STRING	"GAMES",0
W_028	.STRING	"RETURN",0
W_029	.STRING	"RIGHT",0
W_030	.STRING	"PLAYS",0
W_031	.STRING	"FINISH",0
W_032	.STRING	"TROG",0
W_033	.STRING	"CONTINUES",0
W_034	.STRING	"COLLECTION",0
W_035	.STRING	"BLOOP",0
W_036	.STRING	"AUDIT",0
W_037	.STRING	"PRESS",0
W_038	.STRING	"BONE",0
W_039	.STRING	"SETTINGS",0
W_040	.STRING	"DIPSWITCH",0
W_041	.STRING	"BOOK",0
W_042	.STRING	"SPIKE",0
W_043	.STRING	"CENTER",0
W_044	.STRING	"SELECT",0
W_045	.STRING	"LEFT",0
W_046	.STRING	"START",0
W_047	.STRING	"PLAYER",0
W_048	.STRING	"SIMULTANEOUS",0
W_049	.STRING	"SCREEN",0
W_050	.STRING	"TOTAL",0
W_051	.STRING	"STARTS",0
W_052	.STRING	"SOUND",0
W_053	.STRING	"GWEN",0
W_054	.STRING	"ADJUSTMENTS",0
W_055	.STRING	"ROM ERROR  U",0
W_056	.STRING	"REX",0
W_057	.STRING	"ERROR",0
W_058	.STRING	"TOTALS",0
W_059	.STRING	"COIN COUNTERS",0
W_060	.STRING	"MESSAGE",0
W_061	.STRING	"BUTTON",0
W_062	.STRING	"CONTINUE",0
W_063	.STRING	"U.S.A.",0
W_064	.STRING "DOLLAR",0
W_065	.STRING "CENT",0
W_066	.STRING	"CENTS",0
W_067	.STRING "SCHILLING",0
W_068	.STRING	"MAXIMUM",0
W_069	.STRING	"MINIMUM",0
W_070	.STRING	"LIVES",0
W_071	.STRING	"EXTRA",0
W_072	.STRING	"SCORE",0
W_073	.STRING	"HIGH",0

	.EVEN
