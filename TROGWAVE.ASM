 	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGWAVE.ASM'
	.TITLE	" <<< T R O G -- WAVE TABLES >>>"
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
	.INCLUDE	"MPROCEQU.ASM"	; MPROC equates
	.INCLUDE	"DISPEQU.ASM"	; Display processor equates
	.INCLUDE	"GSPINC.ASM"	; GSP assembler equates
	.INCLUDE	"SYSINC.ASM"	; Zunit system equates
	.INCLUDE	"TROGEQU.ASM"	; PALETTE HANDLER STUFF
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"STRING.H"
	.INCLUDE	"TROGSEQU.ASM"

	.DEF	WAVE_DIFF_TAB, GAME_DIFF_TAB, WAVE_TABLE

	.REF	P1W1DINO, P2WHDINO, P3WHDINO, P4WHDINO
	.REF	P1WFDINO, P2WFDINO, P3WFDINO, P4WFDINO
	.REF	P1GEMDINO, P2GEMDINO, P3GEMDINO, P4GEMDINO

	.REF	POSTMAP1, POSTMAPX6, POSTMAP2
	.REF	POSTMAPX2, POSTMAPX3, POSTMAPX5

	.REF	BOUNDRY1, BOUNDRYX6, BOUNDRY2, BOUNDRYV2
	.REF	BOUNDRYX2, BOUNDRYX3, BOUNDRYX5

	.REF	BACKGROUND1, LAVABGND1, LAVABGND2
	.REF	BACKGROUNDE, BACKGROUNDC, BACKGROUNDW, BACKGROUNDS
	.REF	BACKGROUNDCRAY, BACKGROUNDDSRT
	.REF	BACKGROUNDX6, BACKGROUND2
	.REF	BACKGROUNDX2, BACKGROUNDX3, BACKGROUNDX5

	.REF	FOREGROUNDV2

	.REF	FEAST_INTRO, GEM_INTRO, BONFIRE_INTRO

	.REF	SIGNINIT, CYCLE16, TROGCLUB_SND, BAITER_TIME, TARBAITER
	.REF	EGGS_LAID, LAY_EGGS, BONUS_WAVE, WAVE_END
	.REF	HOUSEB_SND2, WIPE_FROM_MID, WAIT_WAVE_END, LASTW_TROGS
	.REF	BWWIN_SND, WAVETIME, MASTBAIT

	.IF	0

	.REF	POSTMAPX1, POSTMAPX7

	.REF	BACKGROUNDX1, BACKGROUNDX7

	.REF	BOUNDRYX1, BOUNDRYX7

	.ENDIF

	.REF	WAVE1DSP, WAVE3DSP, WAVE4DSP
	.REF	WAVE7DSP, WAVE8DSP, WAVE9DSP, WAVE10DSP, WAVE11DSP, WAVE12DSP
	.REF	WAVE13DSP, WAVE14DSP, WAVE15DSP, WAVE16DSP, WAVE17DSP
	.REF	WAVE18DSP, WAVE19DSP, WAVE20DSP, WAVE21DSP, WAVE22DSP
	.REF	WAVE23DSP, WAVE34DSP, WAVE36DSP, WAVE38DSP, WAVE32DSP
	.REF	WAVE33DSP, WAVE42DSP, WAVE43DSP, WAVE45DSP, WAVE46DSP
	.REF	WAVE47DSP, WAVE48DSP, WAVE49DSP

	.REF	WATER_CYCLE, LAVA_CYCLE
	.REF	CAVESHOW1, CAVESHOW2, CAVESHOW3, CAVESHOW4, CAVESHOW5
	.REF	AWARD_EXTRAS

	.DATA

**************************************************************************
*                                                                        *
* WAVE_DIFF_TAB - TABLE OF DIFFICULTY PARAMETERS FOR EACH WAVE.		 *
* TABLE ENTRY:								 *
* 	.WORD 	DIFFICULTY DELTA, MIN, MAX, SINGLE PLAYER ADD		 *
*	.WORD	WAVE 1,WAVE 2...WAVE n					 *
* DIFFICULTY:								 *
* 	0=EASIEST (-5*DIFFICULTY DELTA)					 *
* 		.							 *
* 		.							 *
* 	5=DEFAULT (0*DIFFICULTY DELTA)					 *
* 		.							 *
* 		.							 *
* 	10=HARDEST (5*DIFFICULTY DELTA)					 *
* 									 *
* NOTE: THE TOTAL NUMBER OF WORDS PER TABLE ENTRY MUST = NWAVES +4	 *
*                                                                        *
**************************************************************************
WAVE_DIFF_TAB:	
*
*WAVEEGGS - THE NUMBER OF EGGS THAT THE PLAYER WILL BE REQUIRED TO PICK UP.
*		HIGHER IS HARDER.
	.WORD	    0,    1,   25,    10
	.WORD	   10,   10,   10,   10,   10,   10,   10,   10,   10,   10
	.WORD	   10,   10,   10,   10,   10,   10,   10,   10,   10,   10
	.WORD	   10,   10,   10,   10,   10,   10,   10,   10,   10,   10 
	.WORD	   10,   10,   10,   10,   10,   10,   10,   10,   10,   10
	.WORD	   11,    9,   10,   10,   10,    9,    9,   10,    9,   10 

*
*DINOSPEED - INITIAL DINO VELOCITY (SLL 4 TO GET ACTUAL VELOCITY)
*		HIGHER IS HARDER
	.WORD	 100H, 800H,3000H, 100H
	.WORD	1000H,1000H,1000H,1000H,1200H,1200H,1400H,1200H,1400H,1400H
	.WORD	1400H,1400H,1400H,1400H,1400H,1400H,1400H,1400H,1400H,1400H
	.WORD	1400H,1400H,1600H,1600H,1600H,1600H,1600H,1600H,1600H,1600H
	.WORD	1600H,1700H,1700H,1700H,1700H,1700H,1700H,1700H,1700H,1700H
	.WORD	1700H,1700H,1700H,1700H,1700H,1700H,1700H,1700H,1700H,1700H

*
*TROGSPEED - INITIAL TROG VELOCITY (SLL 4 TO GET ACTUAL VEL.)
*		HIGHER IS HARDER
	.WORD	 100H,0800H,3200H, 100H	;TROGSPEED --- INITIAL TROG VELOCITY  	
	.WORD	1000H,1000H,1000H,1000H,1200H,1200H,1400H,1200H,1400H,1400H
	.WORD	1400H,1400H,1400H,1400H,1400H,1400H,1400H,1400H,1400H,1400H
	.WORD	1400H,1400H,1600H,1600H,1600H,1600H,1600H,1600H,1600H,1600H
	.WORD	1600H,1700H,1700H,1700H,1700H,1700H,1700H,1700H,1700H,1700H
	.WORD	1700H,1700H,1700H,1700H,1700H,1700H,1700H,1700H,1700H,1700H

*
*TROG_PURSUIT - TROG WILL STUPIDLY PURSUE A DINOSAUR IF WITHIN THIS MANY
*		MOVES. LOWER IS HARDER.
	.WORD	   -1, MINPURSUIT, MAXPURSUIT, 0
	.WORD	    2,    2,    2,    2,    2,    2,    2,    2,    2,    2
	.WORD	    2,    2,    2,    2,    2,    2,    2,    2,    2,    2
	.WORD	    2,    2,    2,    2,    2,    2,    2,    2,    2,    2
	.WORD	    2,    2,    2,    2,    2,    2,    2,    2,    2,    2
	.WORD	    2,    2,    2,    2,    2,    2,    2,    2,    2,    2

*
*TROG_PURSUIT_RESET - TROG WILL RESET HIS STUPID PURSUIT IN THIS MANY MOVES.
*		      LOWER IS HARDER.	
	.WORD	   -1,    2,   8,   0
	.WORD	    4,    4,    2,    2,    2,    2,    2,    2,    2,	  2
	.WORD	    2,    2,    2,    2,    2,    2,    2,    2,    1,    1
	.WORD	    1,    1,    1,    1,    1,    1,    1,    1,    1,    1
	.WORD	    1,    1,    1,    1,    1,    1,    1,    1,    1,    1
	.WORD	    1,    1,    1,    1,    1,    1,    1,    1,    1,    1

*
*FIRE_DURATION - TIME(IN TICKS) THAT A FIRE WILL STAY BURNING.
*		 HIGHER IS HARDER.
	.WORD	  50H, 120H, 600H,    0
	.WORD	 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H
	.WORD	 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H
	.WORD	 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H
	.WORD	 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H
	.WORD	 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H, 380H

*
*NUM_WHEELS - NUMBER OF SIMULTANEOUS WHEELS ALLOWED
*		 HIGHER IS HARDER.
	.WORD	    1,    1,    3,    1
	.WORD	    1,    1,    1,    1,    1,    1,    1,    1,    1,    1
	.WORD	    4,    4,    5,    3,    1,    1,    1,    2,    2,    3
	.WORD	    3,    3,    3,    3,    3,    3,    5,    3,    3,    3
	.WORD	    3,    3,    3,    3,    3,    5,    3,    3,    3,    3
	.WORD	    3,    3,    3,    3,    5,    3,    3,    3,    1,    1

*
*SPRGSPEED - INITIAL SPRING SHOE TROG VELOCITY (SLL 4 TO GET ACTUAL VEL.)
*		HIGHER IS HARDER
	.WORD	 100H,0800H,3200H,1800H
	.WORD	1800H,1800H,1800H,1800H,1800H,1800H,1800H,1800H,1800H,1800H
	.WORD	1800H,1800H,1800H,1800H,1800H,1800H,1800H,1800H,1800H,1800H
	.WORD	1800H,1800H,1800H,1800H,1800H,1800H,1800H,1C00H,1800H,1C00H
	.WORD	1800H,1800H,1800H,1800H,1800H,1800H,1E00H,1800H,1E00H,1800H
	.WORD	1800H,1800H,1800H,1800H,1800H,2000H,1800H,2000H,1800H,1800H

*
*POWERUP_DURATION - TIME(IN TICKS) THAT A POWER_UP WILL STAY ON THE SCREEN
*		 LOWER IS HARDER.
	.WORD	 -80H, 120H, 600H, 380H
	.WORD	 380H, 380H, 380H, 380H, 380H, 300H, 380H, 300H, 300H, 300H
	.WORD	 300H, 300H, 300H, 380H, 300H, 300H, 300H, 300H, 300H, 300H
	.WORD	 300H, 600H, 380H, 380H, 380H, 300H, 300H, 280H, 280H, 280H
	.WORD	 280H, 280H, 280H, 280H, 280H, 280H, 280H, 280H, 280H, 280H
	.WORD	 200H, 200H, 200H, 200H, 200H, 200H, 200H, 200H, 280H, 200H

*
*VIRTUAL_TROGS - VIRTUAL NUMBER OF SIMULTANEOUS TROGS ALLOWED
*		 HIGHER IS HARDER.
	.WORD	    1,    2,    9,   2
	.WORD	    4,    5,    5,    6,    6,    6,   10,    6,    6,	  6
	.WORD	    1,    1,    4,    4,    4,    5,    6,    6,    6,	  6
	.WORD	    6,   10,    6,    6,    6,    6,    6,    6,    6,    6
	.WORD	   10,    7,    7,    7,    7,    4,    4,    7,    7,    7
	.WORD	    8,    8,    8,    8,    8,    8,    8,    8,   10,    8

**************************************************************************
*                                                                        *
* GAME_DIFF_TAB - TABLE OF DIFFICULTY PARAMETERS FOR THE GAME.		 *
* TABLE ENTRY:								 *
* 	.WORD 	DIFFICULTY DELTA,MIN,MAX,VALUE				 *
* DIFFICULTY:								 *
* 	0=EASIEST (-5*DIFFICULTY DELTA)					 *
* 		.							 *
* 		.							 *
* 	5=DEFAULT (0*DIFFICULTY DELTA)					 *
* 		.							 *
* 		.							 *
* 	10=HARDEST (5*DIFFICULTY DELTA)					 *
* 									 *
**************************************************************************
GAME_DIFF_TAB:	
*
*STOP_WAITING - AFTER PLAYER HAS PLAYED THIS MANY CONSECUTIVE WAVES
*		STOP WAITING BEFORE DANGER ON APPEAR.
	.WORD	 -2,  0, 20, 10
*			       
*STOP_GREETING - AFTER PLAYER HAS PLAYED THIS MANY CONSECUTIVE WAVES
*		 STOP GREETING HIM WITH A WAVE.
	.WORD	 -1,  1,  4,  1
*			       
*STOP_SEARCHING - AFTER PLAYER HAS PLAYED THIS MANY CONSECUTIVE WAVES
*		  STOP SEARCHING FOR BEST DIRECTION ON SINGLE BONE DEFLECT.
	.WORD	 -2,  1, 50, 32
*			       
*START_BONER -	AFTER PLAYER HAS PLAYED THIS MANY CONSECUTIVE WAVES
*		START BONING HIM ON THE SINGLE BONE DEFLECTS
	.WORD	 -2,  1, 100, 64
*			       
*MAXBOZO - 	AFTER PLAYER HAS PLAYED THIS MANY CONSECUTIVE WAVES
*		HE IS NO LONGER ALLOWED TO BE CONSIDERED A BOZO
	.WORD	 -1,  0, 10,  5
*
*MAXBARS - NUMBER OF ACTIVE BONES A PLAYER IS ALLOWED TO HAVE.
*		LOWER IS HARDER
	.WORD	   -1,    3,   15,   12 

*
*LASTW_TROGS - NUMBER OF LAST WAVE TROGS TO KILL TO BEAT GAME
*		HIGHER IS HARDER
	.WORD	   10,   20,  100,  33 

**************************************************************************
*								         *
* 			WAVE POINTER TABLE				 *
*								         *
**************************************************************************

WAVE_TABLE:
	.LONG	WAVE1 ,WAVE2 ,WAVE3, WAVE4 ,WAVE5 ,WAVE6 ,WAVE7 ,WAVE8

	.LONG	WAVE9 ,WAVE10,WAVE11,WAVE12,WAVE13,WAVE14,WAVE15,WAVE16

	.LONG	WAVE17,WAVE18,WAVE19,WAVE20,WAVE21,WAVE22,WAVE23,WAVE24

	.LONG	WAVE25,WAVE26,WAVE27,WAVE28,WAVE29,WAVE30,WAVE31,WAVE32

	.LONG	WAVE33,WAVE34,WAVE35,WAVE36,WAVE37,WAVE38,WAVE39,WAVE40

	.LONG	WAVE41,WAVE42,WAVE43,WAVE44,WAVE45,WAVE46,WAVE47,WAVE48
	
	.LONG	WAVE49

**************************************************************************
*								         *
* 		WAVE TABLES						 *
* 		-----------						 *
* 	.LONG	POST MAP, BOUNDRY MAP, PRIMARY BGND, SECONDARY BGND,FGND *
* 	.LONG	DISPATCH TABLE, WAVE MUSIC, WAVE "WATER" PALETTE	 *
* 	.LONG	P1 DINO STRT, P2 DINO STRT, P3 DINO STRT, P4 DINO STRT	 *
* 	.WORD	BACKGROUND COLOR, BACKGROUND TYPE, TUNNEL, FAST_TIME	 *
* 	.LONG	TUNNEL SCORE, SHOW_THIS_WAVE, INSTRUCTION_SEQUENCE	 *
*	.LONG	PLAYER START PROCESS, EGG_PATTERN, BONE_LIST		 *
*								         *
**************************************************************************
WAVE1:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUND1,DUMBGND,DUMFGND
	.LONG	WAVE1DSP,BAR17_SND,WATER_CYCLE
	.LONG	P1W1DINO,P2WHDINO,P3WHDINO,P4WHDINO
	.WORD	00AEH,BTYPE_GREEN,0,1923
	.LONG	300000,0,0
	.LONG	0,0,0

WAVE2:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUND1,DUMBGND,DUMFGND
	.LONG	WAVE3DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1W1DINO,P2WHDINO,P3WHDINO,P4WHDINO
	.WORD	00AEH,BTYPE_GREEN,5,2564
	.LONG	300000,0,0
	.LONG	0,0,0

WAVE3:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUND1,DUMBGND,DUMFGND
	.LONG	WAVE4DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_GREEN,6,2564
	.LONG	300000,0,0
	.LONG	0,0,WTBONES

WAVE4:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDC,DUMBGND,DUMFGND
	.LONG	WAVE7DSP,BAR49_SND,WATER_CYCLE
	.LONG	P1W1DINO,P2WHDINO,P3WHDINO,P4WHDINO
	.WORD	00AEH,BTYPE_CLUB,7,2564
	.LONG	300000,0,0
	.LONG	0,0,WC1BONES

WAVE5:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDC,DUMBGND,DUMFGND
	.LONG	WAVE8DSP,BAR49_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_CLUB,8,2564
	.LONG	300000,0,0
	.LONG	0,0,WC1BONES

WAVE6:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDC,DUMBGND,DUMFGND
	.LONG	WAVE9DSP,BAR49_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_CLUB,9,2564
	.LONG	300000,0,0
	.LONG	0,0,WC1BONES

*
*TROG FEAST BONUS WAVE
WAVE7:
WAVE31
	.LONG	POSTMAPX6,BOUNDRYX6,BACKGROUNDX6,DUMBGND,DUMFGND
	.LONG	WAVE10DSP,HURRY_SND,WATER_CYCLE
	.LONG	P1W1DINO,P2WHDINO,P3WHDINO,P4WHDINO
	.WORD	00AEH,BTYPE_GREEN,0,0
	.LONG	300000,0,FEAST_INTRO
	.LONG	0,0FFFFFFFFH,0

WAVE8:
	.LONG	POSTMAP1,BOUNDRY1,LAVABGND1,DUMBGND,DUMFGND
	.LONG	WAVE11DSP,BAR49_SND,LAVA_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	3C00H,BTYPE_LAVA,11,2564
	.LONG	300000,CAVESHOW1,0
	.LONG	0,0,WF1BONES

WAVE9:
	.LONG	POSTMAP1,BOUNDRY1,LAVABGND1,DUMBGND,DUMFGND
	.LONG	WAVE12DSP,BAR49_SND,LAVA_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	3C00H,BTYPE_LAVA,12,2564
	.LONG	300000,0,0
	.LONG	0,0,WF2BONES

WAVE10:
	.LONG	POSTMAP1,BOUNDRY1,LAVABGND1,DUMBGND,DUMFGND
	.LONG	WAVE13DSP,BAR49_SND,LAVA_CYCLE
	.LONG	P1WFDINO,P2WFDINO,P3WFDINO,P4WFDINO
	.WORD	3C00H,BTYPE_LAVA,13,2564
	.LONG	300000,0,0
	.LONG	0,0,WF3BONES

WAVE11:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDW,DUMBGND,DUMFGND
	.LONG	WAVE14DSP,BAR49_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_WHEEL,14,2564
	.LONG	300000,0,0
	.LONG	0,0,WW1BONES

WAVE12:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDW,DUMBGND,DUMFGND
	.LONG	WAVE15DSP,BAR49_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_WHEEL,15,2564
	.LONG	300000,0,0
	.LONG	0,0,WW1BONES

WAVE13:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDW,DUMBGND,DUMFGND
	.LONG	WAVE16DSP,BAR49_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_WHEEL,16,2564
	.LONG	300000,0,0
	.LONG	0,0,WW1BONES

*
*BONUS WAVE - DIAMOND MINE
WAVE14:
WAVE40
	.LONG	POSTMAP2,BOUNDRY2,BACKGROUND2,DUMBGND,DUMFGND
	.LONG	WAVE17DSP,HURRY_SND,WATER_CYCLE
	.LONG	P1GEMDINO,P2GEMDINO,P3GEMDINO,P4GEMDINO
	.WORD	00AEH,BTYPE_GREEN,0,0
	.LONG	300000,0,GEM_INTRO
	.LONG	0,0FFFFFFFFH,0

WAVE15:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDS,DUMBGND,DUMFGND
	.LONG	WAVE18DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_SPRING,18,2564
	.LONG	300000,CAVESHOW2,0
	.LONG	0,0,0

WAVE16:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDS,DUMBGND,DUMFGND
	.LONG	WAVE19DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_SPRING,19,2564
	.LONG	300000,0,0
	.LONG	0,0,0

WAVE17:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDS,DUMBGND,DUMFGND
	.LONG	WAVE20DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_SPRING,20,2564
	.LONG	300000,0,0
	.LONG	0,0,0

WAVE18:
WAVE19:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDCRAY,DUMBGND,DUMFGND
	.LONG	WAVE22DSP,BAR33_SND,LAVA_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	3C00H,BTYPE_CRAY,21,2564
	.LONG	300000,0,0
	.LONG	0,0,0

WAVE20:
WAVE21:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDDSRT,DUMBGND,DUMFGND
	.LONG	WAVE23DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_DESERT,23,2564
	.LONG	300000,0,0
	.LONG	0,0,0

*
*BONUS WAVE - BONFIRE!
WAVE22:
****WAVE49:
	.LONG	POSTMAP2,BOUNDRYV2,LAVABGND2,DUMBGND,FOREGROUNDV2
	.LONG	WAVE21DSP,HURRY_SND,LAVA_CYCLE
	.LONG	P1GEMDINO,P2GEMDINO,P3GEMDINO,P4GEMDINO
	.WORD	3C00H,BTYPE_LAVA,0,0
	.LONG	100000,0,BONFIRE_INTRO
	.LONG	0,0FFFFFFFFH,0

WAVE23
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUND1,DUMBGND,DUMFGND
	.LONG	WAVE4DSP,BAR17_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
 	.WORD	00AEH,BTYPE_GREEN,26,1923
	.LONG	300000,CAVESHOW3,0
	.LONG	0,0,0

WAVE24
	.LONG	POSTMAP2,BOUNDRY2,BACKGROUND2,DUMBGND,DUMFGND
	.LONG	WAVE4DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_GREEN,27,2564
	.LONG	300000,0,0
	.LONG	0,0,0

WAVE25
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDC,DUMBGND,DUMFGND
	.LONG	WAVE8DSP,BAR49_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_CLUB,28,2564
	.LONG	300000,0,0
	.LONG	0,0,0

WAVE26
	.LONG	POSTMAP1,BOUNDRY1,LAVABGND1,DUMBGND,DUMFGND
	.LONG	WAVE12DSP,BAR49_SND,LAVA_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	3C00H,BTYPE_LAVA,29,2564
	.LONG	300000,0,0
	.LONG	0,0,WF2BONES

WAVE27
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDW,DUMBGND,DUMFGND
	.LONG	WAVE16DSP,BAR49_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_WHEEL,30,2564
	.LONG	300000,0,0
	.LONG	0,0,WW1BONES

WAVE28
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDS,DUMBGND,DUMFGND
	.LONG	WAVE20DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_SPRING,31,2564
	.LONG	300000,0,0
	.LONG	0,0,0

WAVE29
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDCRAY,DUMBGND,DUMFGND
	.LONG	WAVE22DSP,BAR33_SND,LAVA_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	3C00H,BTYPE_CRAY,32,2564
	.LONG	300000,0,0
	.LONG	0,0,0

WAVE30
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDDSRT,DUMBGND,DUMFGND
	.LONG	WAVE23DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_DESERT,33,2564
	.LONG	300000,0,0
	.LONG	0,0,0

WAVE32
	.LONG	POSTMAPX2,BOUNDRYX2,BACKGROUNDX2,DUMBGND,DUMFGND
	.LONG	WAVE32DSP,BAR17_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_GREEN,35,1923
	.LONG	300000,CAVESHOW4,0
	.LONG	0,0,0

WAVE33
	.LONG	POSTMAPX2,BOUNDRYX2,BACKGROUNDX2,DUMBGND,DUMFGND
	.LONG	WAVE33DSP,BAR17_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_GREEN,36,1923
	.LONG	300000,0,0
	.LONG	0,0,0

WAVE34
WAVE35
	.LONG	POSTMAPX3,BOUNDRYX3,BACKGROUNDX3,DUMBGND,DUMFGND
	.LONG	WAVE34DSP,BAR49_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_GREEN,37,2564
	.LONG	300000,0,0
	.LONG	0,0,0

WAVE36
WAVE37
	.LONG	POSTMAPX3,BOUNDRYX3,BACKGROUNDX3,DUMBGND,DUMFGND
	.LONG	WAVE36DSP,BAR49_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_GREEN,39,2564
	.LONG	300000,0,0
	.LONG	0,0,0

WAVE38
WAVE39
	.LONG	POSTMAPX5,BOUNDRYX5,BACKGROUNDX5,DUMBGND,DUMFGND
	.LONG	WAVE38DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1GEMDINO,P2GEMDINO,P3GEMDINO,P4GEMDINO
	.WORD	00AEH,BTYPE_GREEN,41,2564
	.LONG	300000,0,0
	.LONG	0,0,0


WAVE41:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUND1,DUMBGND,DUMFGND
	.LONG	WAVE32DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1W1DINO,P2WHDINO,P3WHDINO,P4WHDINO
	.WORD	00AEH,BTYPE_GREEN,44,0
	.LONG	300000,CAVESHOW5,0
	.LONG	0,0FFFFFFFFH,WTBONES

WAVE42:
	.LONG	POSTMAP2,BOUNDRY2,BACKGROUND2,DUMBGND,DUMFGND
	.LONG	WAVE42DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_GREEN,45,0
	.LONG	300000,0,0
	.LONG	0,0FFFFFFFFH,0

WAVE43:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDC,DUMBGND,DUMFGND
	.LONG	WAVE43DSP,BAR49_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_CLUB,46,0
	.LONG	300000,0,0
	.LONG	0,0FFFFFFFFH,WC1BONES

WAVE44:
	.LONG	POSTMAP1,BOUNDRY1,LAVABGND1,DUMBGND,DUMFGND
	.LONG	WAVE13DSP,BAR49_SND,LAVA_CYCLE
	.LONG	P1WFDINO,P2WFDINO,P3WFDINO,P4WFDINO
	.WORD	3C00H,BTYPE_LAVA,47,0
	.LONG	300000,0,0
	.LONG	0,0FFFFFFFFH,WF3BONES

WAVE45:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDW,DUMBGND,DUMFGND
	.LONG	WAVE45DSP,BAR49_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_WHEEL,48,0
	.LONG	300000,0,0
	.LONG	0,0FFFFFFFFH,WW1BONES

WAVE46:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDS,DUMBGND,DUMFGND
	.LONG	WAVE46DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_SPRING,49,0
	.LONG	300000,0,0
	.LONG	0,0FFFFFFFFH,0

WAVE47:
	.LONG	POSTMAPX5,BOUNDRYX5,BACKGROUNDX5,DUMBGND,DUMFGND
	.LONG	WAVE47DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1GEMDINO,P2GEMDINO,P3GEMDINO,P4GEMDINO
	.WORD	00AEH,BTYPE_GREEN,49,0
	.LONG	300000,0,0
	.LONG	0,0FFFFFFFFH,0

WAVE48:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDDSRT,DUMBGND,DUMFGND
	.LONG	WAVE48DSP,BAR33_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WHDINO,P3WHDINO,P4WFDINO
	.WORD	00AEH,BTYPE_DESERT,49,0
	.LONG	300000,0,0
	.LONG	0,0FFFFFFFFH,0

WAVE49:
	.LONG	POSTMAP1,BOUNDRY1,BACKGROUNDE,DUMBGND,DUMFGND
	.LONG	WAVE49DSP,HURRY_SND,WATER_CYCLE
	.LONG	P1WFDINO,P2WFDINO,P3WFDINO,P4WFDINO
	.WORD	00AEH,BTYPE_ENT,0,0
	.LONG	300000,0,LASTW_INTRO
	.LONG	0,0FFFFFFFEH,WWFBONES

*
*BONE PATTERN FOR TROG ENTER WAVE
*
WTBONES
	.LONG	[104,162]
	.LONG	[104,226]
	.LONG	[120,178]
	.LONG	[120,210]
	.LONG	[184,82]
	.LONG	[200,98]
	.LONG	[200,290]
	.LONG	[184,306]
	.LONG	0

*
*BONE PATTERN FOR FIRST TROG CLUB WAVE
*
WC1BONES
	.LONG	[120,114]
	.LONG	[120,178]
	.LONG	[120,242]
	.LONG	[152,146]
	.LONG	[152,210]
	.LONG	[152,274]
	.LONG	[184,114]
	.LONG	[184,178]
	.LONG	[184,242]	
	.LONG	0

*
*BONE PATTERN FOR FIRST FIRE WAVE
*
WF1BONES
	.LONG	[88,178]
	.LONG	[120,178]
	.LONG	[136,194]
	.LONG	[152,210]
	.LONG	[184,210]
	.LONG	[216,210]
	.LONG	0

*
*BONE PATTERN FOR SECOND FIRE WAVE
*
WF2BONES
	.LONG	[104,226]
	.LONG	[120,178]
	.LONG	[152,178]
	.LONG	[168,162]
	.LONG	[184,146]
	.LONG	[216,146]
	.LONG	[120,242]
	.LONG	[152,242]
	.LONG	[168,258]
	.LONG	[184,274]
	.LONG	[216,274]
	.LONG	0

*
*BONE PATTERN FOR THIRD FIRE WAVE
*
WF3BONES
	.LONG	[120,82]
	.LONG	[152,82]
	.LONG	[184,82]
	.LONG	[200,98]
	.LONG	[200,130]
	.LONG	[88,178]
	.LONG	[104,194]
	.LONG	[120,210]
	.LONG	[152,210]
	.LONG	[168,194]
	.LONG	[216,210]
	.LONG	[200,258]
	.LONG	[200,290]
	.LONG	[184,306]
	.LONG	[152,306]
	.LONG	[120,306]
	.LONG	0

*
*BONE PATTERN FOR FIRST WHEEL WAVE
*
WW1BONES
	.LONG	[136,98]
	.LONG	[168,98]
	.LONG	[104,130]
	.LONG	[120,114]
	.LONG	[184,114]
	.LONG	[200,130]
	.LONG	[104,162]
	.LONG	[200,162]
	.LONG	[104,226]
	.LONG	[200,226]
	.LONG	[104,258]
	.LONG	[120,274]
	.LONG	[184,274]
	.LONG	[200,258]
	.LONG	[136,290]
	.LONG	[168,290]
	.LONG	0

*
*BONE PATTERN FOR FINAL TROG WAVE
*
WWFBONES
	.LONG	[120,178]
	.LONG	[120,210]

	.LONG	[184,178]
	.LONG	[184,210]

	.LONG	[184,82]
	.LONG	[200,98]

	.LONG	[152,114]
	.LONG	[168,130]

	.LONG	[216,50]
	.LONG	[232,66]

	.LONG	[200,290]
	.LONG	[184,306]

	.LONG	[168,258]
	.LONG	[152,274]

	.LONG	[232,322]
	.LONG	[216,338]

	.LONG	0

**************************************************************************
*                                                                        *
* 		WAVE MUSIC SOUND CALLS					 *
*                                                                        *
**************************************************************************
BAR1_SND:
	.WORD	>F2FD,>1,>8003,0
BAR17_SND:
	.WORD	>F2FD,>1,>8006,0
BAR33_SND:
	.WORD	>F2FD,>1,>8007,0
BAR49_SND
	.WORD	>F2FD,>1,>8008,0
HURRY_SND
	.WORD	>F2FD,>1,>800E,0

	.TEXT

**************************************************************************
*								         *
* 		    LAST WAVE INTRO (TROG SHOWDOWN)			 *
*								         *
**************************************************************************
LASTW_INTRO
	MOVI	LASTW_MESS,A8
	JSRP	LM_PRINTF
	SLEEP	30
	MOVI	SIGNINIT,A14
	CALLA	GPALOBJSTF
	JRZ	LASTW_SIGN_SKP		;BUMMER, IT BROKE
	CALLA	INSOBJ
	PUSHP	A0
	MOVI	CAVSIN,A8		; PALETTE TO CYCLE
	MOVK	1,A9
	MOVK	2,A10
	MOVK	10,A11			; TICKS
	CREATE	CAVESIGNPID,CYCLE16 	; LIGHTS 1
	MOVK	3,A9
	MOVK	4,A10
	CREATE	CAVESIGNPID,CYCLE16	; LIGHTS 2
	PULLP	A8
	MOVIM	4,*A8(OYVEL+16),W
	SLEEP	29
	CLRM	*A8(OYVEL),L
	SOUND1	TROGCLUB_SND
	SLEEP	30
LASTW_SIGN_SKP
	MOVI	LASTW2_MESS,A8
	JSRP	LM_PRINTF
	SLEEP	180
	CALLA	CLRTEXT
	MOVI	CAVEOID,A0
	CALLA	KILOBJ_ALL
	MOVI	CAVESIGNPID,A0
	CALLA	KILLPROC_ALL
	CREATE	INDPID,LASTW_WATCH
	RETP

**************************************************************************
*								         *
* LASTW_WATCH - PROCESS TO WATCH THE LAST WAVE AND SEE IF ANYBODY	 *
* 		HAS KILLED ENOUGH TROGS. IF THEY HAVE, THEN		 *
* 		WE WILL END THE GAME.					 *
*								         *
**************************************************************************
LASTW_WATCH
	SLEEP	10
	CLR	A6
	MOVE	@LASTW_TROGS,A10,W
	ALLPLYR	LASTW_COUNT
	MOVE	A6,A6
	JRZ	LASTW_WATCH


	MOVI	MASTERID,A0
	CLR	A1
	NOT	A1
	CALLA	EXISTP
	JRZ	LW_WAIT_TROGS
	CALLA	GETA8
	CALLA	GETA9
	CALLA	GETA10
	CALLA	GETA11
	MOVI	MASTBAIT,A7
	CALLA	XFERPROC_ID		;MASTER KEEP ON TIMEIN'

LW_WAIT_TROGS
	SLEEP	10
	MOVI	TROGS,A1
	CALLA	CNTSUPP
	JRNZ	LW_WAIT_TROGS

	SLEEP	60

	CLRM	@EGGS_LAID,W
	MOVIM	BONUSW_2,@BONUS_WAVE,W
	CLR	A1
	NOT	A1
	CALLA	LAY_EGGS
	SLEEP	30
	SOUND1	BWWIN_SND
	MOVI	60*60,A11			;TIMEOUT ON GEM PICKUP

LW_WAIT_GEMS
	SLEEP	10
	SUBK	10,A11
	JRLE	LW_ITS_ALL_OVER
	MOVI	EGGS,A1
	CALLA	CNTSUPP
	JRNZ	LW_WAIT_GEMS

LW_ITS_ALL_OVER
	MOVE	@GAME_STATE,A0,W
	CMPI	INGAMEOV,A0
	JREQ	LW_SKIP_ST
	CMPI	INAMODE,A0
	JREQ	LW_SKIP_ST
	MOVI	INGAME,A0		;WE ARE THE FIRST TO PASS
	MOVE	A0,@GAME_STATE,W
LW_SKIP_ST
	MOVK	1,A0
	MOVE	A0,@WAVE_OVER,W		;FLAG THE WAVE DONE

	CLR	A0
	MOVI	0E000h,A1
	CALLA	KILALL			;KILL EVERYTHING WE CAN

	CALLA	STOPOBJS

	SOUND1	ALLOFF
	SLEEP	4

	SOUND1	HOUSEB_SND2
	JSRP	WAIT_WAVE_END

*****	MOVK	30,A11
*****	CREATE	INDPID,WIPE_FROM_MID	;CLEAR THE SCREEN

	SLEEP	30

	CLR	A0	     		;SCREEN SHALL BE BLACK
	MOVE	A0,@IRQSKYE,W

	CALLA	SCORAREA		;REPLOT THE SCORE AREA

	SLEEP	2

	JAUC	WAVE_END



*
*LASTW_COUNT - ROUTINE TO INCREMENT A6 IF A PLAYER HAS ENOUGH PTROGKILLS
*		TO HIS CREDIT.
*A10 = NUMBER OF TROGS TO BEAT
LASTW_COUNT
	MOVE	*A2(PTROGKILLS),A14,W
	CMP	A10,A14
	JRLO	LC_X
	INC	A6
LC_X
	RETS


LASTW_MESS:
	MESS_MAC RD15FONT,3,197,73+SKYTOPOF,TROG_PLF,STRCNRMOS,0
	.STRING	"YOU'VE REACHED IT ...",0
	.EVEN
LASTW2_MESS:
	MESS_MAC RD15FONT,3,197,138+SKYTOPOF,TROG_PDECAY,STRCNRMOS,0
	.STRING	"BEAT THE TROGS!",0
	.EVEN


	.END
