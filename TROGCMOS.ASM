   	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGCMOS.ASM'
	.TITLE	"TROG CMOS AND DIP ROUTINES"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 	     COPYRIGHT (C) 1990 MIDWAY MANUFACTURING COMPANY,		 *
* 	      MANUFACTURERS OF BALLY/MIDWAY AMUSEMENT GAMES.		 *
* 		         ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.INCLUDE	"MPROCEQU.ASM"	;MPROC equates
	.INCLUDE	"DISPEQU.ASM"	;Display processor equates
	.INCLUDE	"GSPINC.ASM"	;GSP assembler equates
	.INCLUDE	"SYSINC.ASM"	;Zunit system equates
	.INCLUDE	"TROGEQU.ASM"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"STRING.H"
	.INCLUDE	"TROGSEQU.ASM"
	.INCLUDE	"TROGAUDN.ASM"
	.INCLUDE	"TROGDIP.ASM"	; DIP SWITCH MASKS
	.INCLUDE	"UTILMAC.ASM"

	.DEF	DIP_CONFIG

	.REF	STRING, DSCRCLR

	.TEXT
	.EVEN

**************************************************************************
*								         *
* 	DIP_CONFIG							 *
* 									 *
* 	PLOT WHICH CONFIGURATION WE ARE USING				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

DIP_CONFIG:
	DISPON
	FCALL	DSCRCLR,B6		; CLEAN UP THAT MESS, BUD
	CALLR	READ_DIP
	MOVI	USE_CMOS_MESS,A8	; GOOD ASSUMPTION
	ANDI	DPUSECMOS,A0	
	JRNZ	CMGO
	MOVI	USE_DIP_MESS,A8
CMGO
	MOVE	*A8+,A1,L		; SCREEN LOCATION
	MOVE	A8,A0			; FOR STRING
	CLR	A2
	MOVI	TROG_RED,A3
	FCALL	STRING,B6
	CALLR	SHOW_DIP
	PAUSE	200000H,B0
	RETS

**************************************************************************
*								         *
* 	SHOW_DIP							 *
* 									 *
* 	DISPLAY THE DIP SWITCH SETTINGS ( FOR STARTUP SCREEN )		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

SHOW_DIP:
	CLR	A1
	CALLR	SHOW_COIN		; LEFT COIN
	INC	A1
	CALLR	SHOW_COIN		; RIGHT COIN

	CLR	A2
	MOVI	TROG_RED,A3

	MOVI	DCOCKTAIL_0,A1
	CALLR	READ_DIP
	ANDI	DPCOCKTAIL,A0		; COCKTAIL
	JRZ	SD1
	MOVI	DCOCKTAIL_1,A1
SD1
	MOVE	A1,A0
	MOVE	*A0+,A1,L
	FCALL	STRING,B6

	CALLR	READ_DIP
	ANDI	DPCOUNTRY,A0
	SLL	8,A0
	ADDI	DCOUNTRY_TAB,A0
	MOVE	*A0,A0,L
	MOVE	*A0+,A1,L		; GET LOCATION
	FCALL	STRING,B6

	CALLR	READ_DIP
	ANDI	DPPLAYERS,A0
	SLL	12,A0
	ADDI	DPLAYER_TAB,A0
	MOVE	*A0,A0,L
	MOVE	*A0+,A1,L		; GET LOCATION
	FCALL	STRING,B6

	MOVI	DJOYSTICK_0,A1
	CALLR	READ_DIP
	ANDI	DPJOYSTICK,A0
	JRZ	SD2
	MOVI	DJOYSTICK_1,A1
SD2
	MOVE	A1,A0
	MOVE	*A0+,A1,L
	FCALL	STRING,B6

	RETS				

**************************************************************************
*								         *
* 	SHOW_COIN							 *
* 									 *
* 	PLOT THE APPROPRIATE COIN USAGE MESSAGE FOR DIP SWITCH		 *
* 									 *
* 	ENTRY								 *
* 		A1	WHICH CHUTE ( 0 = LEFT, 1 = RIGHT )		 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

SHOW_COIN:
	CLR	A2			; HORIZONTAL PLOTTING
	MOVI	TROG_RED,A3
	MOVE	A1,A1
	JRNZ	SCRIGHT
	MOVI	DLEFTSLOT,A0
	MOVE	*A0+,A1,L		; LOCATION
	FCALL	STRING,B6
	CALLR	READ_DIP
	ANDI	DPLEFTSLOT,A0
	SRL	5,A0
	JRUC	SCRET
SCRIGHT
	MOVI	DRIGHTSLOT,A0
	MOVE	*A0+,A1,L		; LOCATION
	FCALL	STRING,B6
	CALLR	READ_DIP
	ANDI	DPRIGHTSLOT,A0
	SRL	2,A0
SCRET
	CALLR	COIN_STR
	FCALL	STRING,B6
	RETS

**************************************************************************
*								         *
* 	COIN_STR							 *
* 									 *
* 	RETURN THE APPROPRIATE PIECE OF A STRING			 *
* 									 *
* 	ENTRY								 *
* 		A0	CREDIT SETTING ( 0 - 7 )			 *
* 									 *
* 	EXIT								 *
* 		A0	POINTER TO RIGHT AREA				 *
*								         *
**************************************************************************

COIN_STR
	ANDI	7,A0			; SANITY CHECK HERE
	SLL	5,A0
	ADDI	DCOIN_TAB,A0
	MOVE	*A0,A0,L
	RETS
	
**************************************************************************
*								         *
* 	READ_DIP							 *
* 									 *
* 	READ IN BOTH DIP SWITCHES					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A0	DIP SWITCH					 *
*								         *
**************************************************************************

READ_DIP:
	MOVE	@DIPSWITCH,A0,W		; READ IT IN
	NOT	A0			; INVERT IT FOR TRUE BITS
	CLR	A0			; TEMPORARY UNTIL I GET A YUNIT
	RETS


**************************************************************************
*								         *
* 	MESSAGES AND OTHER RANDOM DATA					 *
*								         *
**************************************************************************

USE_CMOS_MESS
	.LONG	[128,133]
	.STRING	"USING CMOS SETTINGS",0
	.EVEN

USE_DIP_MESS
	.LONG	[80,100]
	.STRING	"USING DIPSWITCH SETTINGS",0
	.EVEN

DCOCKTAIL_0
	.LONG	[130,120]
	.STRING	"UPRIGHT STICKS",0
	.EVEN

DCOCKTAIL_1
	.LONG	[130,120]
	.STRING	"COCKTAIL STICKS",0
	.EVEN

DLEFTSLOT
	.LONG	[100,120]
	.STRING	"LEFT COIN SLOT  -  ",0
	.EVEN

DRIGHTSLOT
	.LONG	[115,120]
	.STRING	"RIGHT COIN SLOT -  ",0
	.EVEN

DCOIN_TAB
	.LONG	DCOIN_0, DCOIN_1, DCOIN_2, DCOIN_3, DCOIN_4
	.LONG	DCOIN_5, DCOIN_6, DCOIN_7

DCOIN_0
	.STRING	"1 COIN - 1 CREDIT",0
	.EVEN
DCOIN_1
	.STRING	"2 COINS - 1 CREDIT",0
	.EVEN
DCOIN_2
	.STRING	"3 COINS - 1 CREDIT",0
	.EVEN
DCOIN_3
	.STRING	"4 COINS - 1 CREDIT",0
	.EVEN
DCOIN_4
	.STRING	"1 COIN - 2 CREDITS",0
	.EVEN
DCOIN_5
	.STRING	"1 COIN - 3 CREDITS",0
	.EVEN
DCOIN_6
	.STRING	"1 COIN - 4 CREDITS",0
	.EVEN
DCOIN_7
	.STRING	"FREE PLAY",0
	.EVEN

DCOUNTRY_TAB
	.LONG	DCOUNTRY_0, DCOUNTRY_1, DCOUNTRY_2, DCOUNTRY_3

DCOUNTRY_0
	.LONG	[145,120]
	.STRING	"COUNTRY USA",0
	.EVEN
DCOUNTRY_1
	.LONG	[145,120]
	.STRING	"COUNTRY GERMANY",0
	.EVEN
DCOUNTRY_2
	.LONG	[145,120]
	.STRING	"COUNTRY FRANCE",0
	.EVEN
DCOUNTRY_3
	.LONG	[145,120]
	.STRING	"COUNTRY OUTERSPACE -- ASSUMING USA",0
	.EVEN

DJOYSTICK_0
	.LONG	[175,120]
	.STRING	"8 WAY JOYSTICKS",0
	.EVEN

DJOYSTICK_1
	.LONG	[175,120]
	.STRING	"4 WAY JOYSTICKS",0
	.EVEN

DPLAYER_TAB
	.LONG	DPLAYER_0, DPLAYER_1, DPLAYER_2, DPLAYER_3

DPLAYER_0
	.LONG	[160,120]
	.STRING	"4 PLAYER TROG",0
	.EVEN
DPLAYER_1
	.LONG	[160,120]
	.STRING	"1 PLAYER TROG",0
	.EVEN
DPLAYER_2
	.LONG	[160,120]
	.STRING	"2 PLAYER TROG",0
	.EVEN
DPLAYER_3
	.LONG	[160,120]
	.STRING	"1 PLAYER TROG",0
	.EVEN

DFREEZE_0
	.LONG	[190,120]
	.STRING	"FREEZE NOT SELECTED",0
	.EVEN
DFREEZE_1
	.LONG	[190,120]
	.STRING	"FREEZE SELECTED",0
	.EVEN

DTEST_0
	.LONG	[205,120]
	.STRING	"TEST MODE NOT SELECTED",0
	.EVEN

DTEST_1
	.LONG	[205,120]
	.STRING	"TEST MODE SELECTED",0
	.EVEN


