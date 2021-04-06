	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGBAR.ASM'
	.TITLE	" <<< T R O G  -- BONE ROUTINES >>>"
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

*	GET THE SYSTEM STUFF
	.INCLUDE	"MPROCEQU.ASM"	;MPROC equates
	.INCLUDE	"DISPEQU.ASM"	;Display processor equates
	.INCLUDE	"GSPINC.ASM"	;GSP assembler equates
	.INCLUDE	"SYSINC.ASM"	;Zunit system equates
	.INCLUDE	"TROGEQU.ASM"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"TROGAEQU.ASM"

	.DEF	BONED_IN, BONE_OBJ, BONE_SMASH, BONE_OBLITERATE, BONED_IN_4
	.DEF	PDRAW, COUNT_BONES, DELBAR
	.DEF	BARTAB, IND_BONE, BONED_IN_GREY
	.DEF	VOBLIT1, LAY_BONES

	.REF	GPLAYD, TOMOVE, GPLAYNUM, GETMOVE, SWITCH_ESCAPE, DINOPUNCH
	.REF	ONE_MOVE, TWO_MOVES, FIND_CLOSE_MPNT, FINDMOVE, PXBARS
	.REF	IS_DINO_DEAD_A8, FIREBALL

*LOCAL EQUATES
BARIZPOS .EQU	10H
MOVETEMP .EQU	PDATA+60H
MOVEIDXTEMP .EQU PDATA+80H
	.text

**************************************************************************
*								         *
* PDRAW - DRAW BUTTON PROCESS						 *
* *A13(PROCID) = 0000 0PPP 0000 0000					 *
* 	WHERE:								 *
*  		PPP = PLAYER #						 *
*								         *
**************************************************************************
PDRAW
	INCM	@SWITCH_ESCAPE,W	;FLAG THE SWITCH FOR ESCAPEES

	MOVE	@GAME_STATE,A0,W
	CMPI	INPLAY,A0		;ARE WE PLAYING?
	JRNE	PDRAWQDI		;BR = NO, DON'T DRAW

	MOVE	*A13(PROCID),A0,W
	MOVE	A0,A5			;KEEP A COPY HERE
	CLR	A1
	NOT	A1
	CALLA	EXISTP			;CHECK FOR THE SAME PROCESS
	JREQ	PDRAWIT			;O.K. TO DRAW IT'S NOT THERE
	DIE				;PROTECTION AGAINST FLAKO SWITCHES

PDRAWIT
	MOVE	A5,A0			;GET BACK THE PROCID
	SLL	21,A0
	SRL	29,A0			;BASED ON THIRD NIBBLE OF PID
	DEC	A0	
	CALLA	GPLAYD

	INCM	*A2(PSWITCHESC),W	;FLAG THE BUTTON ACTION

	MOVE	@PAUSE_GAME,A8,W	;IS GAME PAUSED?
	JRNZ	PDRAWQDI		;BR = YES

	MOVE	*A2(POBJ),A8,L
	JRZ	PDRAWQDI		;NO PLAYER. DIE QUICKLY AND QUIETLY

	CALLA	IS_DINO_DEAD_A8
	JRZ	PDRAWQDI

	MOVE	*A8(OPLINK),A0,L
	JRZ	PDRAWQDI

	MOVB	*A0(DDIZZYFLG),A7
	CMPI	2,A7
	JREQ	PDRAWQDI

*CHECK IF WE ARE ABLE TO FIRE A SPITBALL
PFIRE_CK
	MOVB	*A0(DFIREFLG),A7
	JRZ	PPUNCH_CK
	MOVE	*A0(DDIR),A11,W
	SLL	30,A11
	SRL	25,A11
	ADDI	FIRE_OFFSET,A11
	MOVE	*A11,A10,L
	CREATE	INDPID,FIREBALL
	JRUC	PDRAWDI

*PUNCHING IS THE LOWEST BUTTON ACTIVITY
PPUNCH_CK
	MOVB	*A0(DTREXFLG),A7	;BUTTON DOES NOTHING WHILE TREX
	JRNZ	PDRAWQDI		;BR = THIS IS THE CASE

	MOVB	*A0(DPUNCHFLG),A7	;IS HE ALREADY PUNCHING
	JRNZ	PDRAWQDI		;BR = NO
	MOVE	*A0(PSPTR),A3,L
	MMFM	A3,A7,A8,A9,A10,A11	
	MOVE	A7,A1
	MOVI	DINOPUNCH,A7		;TRANSFER TO THE PUNCHER
	MMTM	A3,A1,A7,A8,A9,A10,A11
	MOVE	A3,*A0(PSPTR),L
	MOVK	1,A7
	MOVB	A7,*A0(DPUNCHFLG)	;MARK HIM AS A PUNCHER
	MOVE	A7,*A0(PTIME),W		;AND WAKE HIM UP IMMEADIATELY
PDRAWDI:
	SLEEP	4			;DEBOUNCE
PDRAWQDI:
	DIE

FIRE_OFFSET
	.LONG	[-3,-1],[-2,-1],0,0

DUMBAR
	MMTM	SP,A1,A3,A8,A14
	MOVE	A0,A1
	CALLA	GPLAYNUM
	MOVB	*A1(MOVETYPE),A3
	SLL	7,A3			;OFFSET TO CORRECT BAR DIRECTION	
	SLL	5,A0			;NOW GET TO THE CORRECT PLAYER IMAGE
	ADD	A0,A3	
	ADDI	BARTAB,A3
	MOVE	*A3,A14,L		;AND GET US A BAR
	CALLA	GPALOBJSTF
	JRZ	DUMBARDI		;FAILED THE PALETTE TEST
	MOVE	A0,A8
	MOVE	A1,A0
	CALLA	TOMOVE			;ALIGN ON THE CURRENT MOVE POINT
	MOVE	A8,A0
	CALLA	SET_MZPOS
	CALLA	INSERT_OBJ
DUMBARDI
	MOVE	A0,A0
	MMFM	SP,A1,A3,A8,A14
	RETS

**************************************************************************
*								         *
* LAY_BONES - LAY THE BONES FOR THIS WAVE.				 *
* A3 = PTR TO THE BONE LIST.						 *
* RETURNS:								 *
* A3 = PNTING TO THE WORD AFTER THE LIST TERMINATOR			 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
LAY_BONES
	MOVE	A3,A3
	JRZ	LB_XXX
	PUSH	A1
	JRUC	LB_NEXT
LB_LP
	CALLR	IND_BONE
LB_NEXT
	MOVE	*A3+,A1,L
	JRNZ	LB_LP
	PULL	A1
LB_XXX
	RETS
	
**************************************************************************
*								         *
* IND_BONE - MAKE AN INDESTRUCTIBLE BONE OBJECT.			 *
* A1 = [Y,X] VALUE OF MOVE TO PUT THIS BONE UPON.			 *
* RETURNS								 *
* A0 = BONE OBJECT							 *
* 	.EQ. FAIL							 *
* 	.NE. SUCCESS							 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
IND_BONE
	MMTM	SP,A1,A3,A8
	CALLA	FIND_CLOSE_MPNT
	CALLA	FINDMOVE
	MOVB	*A1(MOVEPLYR),A3		;IS THERE A BONE ON THIS SPOT?
	JRNN	IB_FAIL				;BR = YES
	MOVB	*A1(MOVETYPE),A3
	CMPI	HORBAR,A3
	JREQ	IB_HBONE
	CMPI	VERTBAR,A3
	JRNE	IB_FAIL
	MOVI	PXVINIT,A14
	JRUC	IB_DRAW
IB_HBONE
	MOVI	PXHINIT,A14
IB_DRAW
	MOVE	A0,A3
	CALLA	GPALOBJSTF
	JRZ	IB_X			;FAILED THE OBJECT
	MOVE	A3,*A0(OATTRIB),W
	MOVE	A0,A8
	MOVE	A1,A0
	CALLA	TOMOVE			;ALIGN ON THE CURRENT MOVE POINT
	MOVI	PXPLAYER,A14
	MOVB	A14,*A1(MOVEPLYR)	;MARK THIS POINT TAKEN
	MOVE	A8,A0
	CALLA	SET_MZPOS
	MOVI	PXBARS,A1
	CALLA	INSERT_OBJ_SUPP
IB_X
	MOVE	A0,A0
	MMFM	SP,A1,A3,A8
	RETS
IB_FAIL
	CLR	A0
	JRUC	IB_X

**************************************************************************
*                                                                        *
* DECPBARS - DECREMENT A PLAYERS BAR COUNT				 *
* A2 = PLAYER INDEX							 *
*                                                                        *
**************************************************************************
DECPBARS
	MMTM	SP,A0,A1,A6,A8
	MOVE	*A2(PBARS),A6,W	
	MOVE	@MAXBARS,A1,W
	CMP	A1,A6	  		;WERE THE BARS MAXED?
	JRLT	DPB_NOKILL		;BR = NO
	MOVE	*A2(PSUPP),A1,L
	CALLA	FIND_SUPP_LAST
	JRZ	DPB_NOKILL
	MOVE	A0,A8
	CALLA	OBJPROC_KILL
	CALLA	OBJ_ON			;MAKE SURE IT'S LIT
DPB_NOKILL:
	DEC	A6
	MOVE	A6,*A2(PBARS),W
	MMFM	SP,A0,A1,A6,A8
	RETS

**************************************************************************
*                                                                        *
* FINDBAR - LOOK DOWN A SUPPLEMENTAL LIST FOR A BAR AT A MOVE POINT	 *
* A0 = # OF MOVE POINT							 *
* A1 = SUPPLEMENTAL LIST						 *
* RETURNS:								 *
* A0 = PTR TO OBJECT 0 = NOT FOUND, Z BIT RESPECTS A0			 *
*                                                                        *
**************************************************************************
FINDBAR
	MMTM	SP,A1,A2
	SWAP	A0,A1
	MOVE	*A0,A0,L
	JRZ	FINDBARX
FINDBARL
	MOVE	*A0(OATTRIB),A2,W	
	CMP	A2,A1
	JREQ	FINDBARX	
	MOVE	*A0(OSLINK),A0,L
	JRNZ	FINDBARL
FINDBARX
	MOVE	A0,A0
	MMFM	SP,A1,A2
	RETS

**************************************************************************
*                                                                        *
* DELBAR - DELETE A BAR OBJECT						 *
* A0 = PTR TO BAR OBJECT						 *
* A1 = PTR TO SUPPLEMENTAL LIST IT EXISTS ON				 *
*                                                                        *
**************************************************************************
DELBAR
	MMTM	SP,A0,A1,A8
	MOVE	A0,A8
	CALLA	OBJPROC_KILL		;KILL THE ASSOCIATED PROCESS
	CALLA	DELETE_OBJ_SUPP
	MOVE	*A8(OATTRIB),A0,W	;GET THE POST # 
	CALLA	GETMOVE			;GET THE MOVE ADDRESS
	CLR	A1
	NOT	A1
	MOVB	A1,*A0(MOVEPLYR)	;CLEAR PLAYER ASSOCIATION
	MMFM	SP,A0,A1,A8
	RETS
	
**************************************************************************
*								         *
* DELETE_OLDEST - DELETE THE LAST OBJECT ON A SUPPLEMENTAL LIST.	 *
* A1 = PTR TO PLAYERS BAR SUPPLEMENTAL LIST.				 *
*								         *
**************************************************************************
DELETE_OLDEST:
	PUSH	A0
	CALLA	FIND_SUPP_LAST
	JRZ	DOX
	CALLR	DELBAR			;DELETE THIS BAR
DOX:
	PULL	A0
	RETS

**************************************************************************
*								         *
* FLASH_OLDEST - FLASH THE LAST OBJECT ON A SUPPLEMENTAL LIST.		 *
* A1 = PTR TO PLAYERS BAR SUPPLEMENTAL LIST.				 *
*								         *
**************************************************************************
FLASH_OLDEST:
	MMTM	SP,A0,A1,A7,A8
	CALLA	FIND_SUPP_LAST
	JRZ	FOX
	MOVE	A0,A8
	CALLA	OBJPROC_KILL
	CREATE	INDPID,FLASH_BAR
	JRZ	FOX
	MOVE	A0,*A8(OPLINK),L
FOX:
	MMFM	SP,A0,A1,A7,A8
	RETS

**************************************************************************
*								         *
* BONE_OBLITERATE - REMOVE ANY BONE FROM EXISTANCE IN ONE HIT.		 *
* A0 = PTR TO MOVE THAT BONE IS RESTING UPON.				 *
* RETURNS:								 *
* 	NOTHING								 *
* NOTE: TIED INTO BONE_SMASH						 *
*								         *
**************************************************************************
BONE_OBLITERATE:
	MMTM	SP,A0,A1,A2,A7,A8,A9,A11
	CALLR	BONE_OBJ	
	JRZ	BONE_SMASH_X

	MOVE	A0,A7
	MOVB	*A7(MOVEPLYR),A0
	CALLA	GPLAYD			;GET THE PLAYER WE BELONG TO
	MOVE	A7,A0

	MOVE	A1,A8

	MOVB	*A0(MOVETYPE),A4	;LET'S SEE WHAT TYPE IT IS
	JRZ	BONE_OB_H		;BR = OBLITERATING A HORIZONTAL BONE

	CMPI	VERTBAR,A4
	JRNE	BONE_SMASH_X		;BR = MOVE IS NOT COOL FOR A BONE

	MOVI	VOBLIT1,A9
	JRUC	BONE_DEL_STUFF		;CRUNCH AND GO

BONE_OB_H:
	MOVI	HOBLIT1,A9
	JRUC	BONE_DEL_STUFF


**************************************************************************
*								         *
* BONE_SMASH - ROUTINE TO SMASH A BONE.					 *
* A0 = PTR TO MOVE THAT BONE IS RESTING UPON.				 *
* RETURNS:								 *
* NOTHING								 *
*								         *
**************************************************************************
BONE_SMASH:
	MMTM	SP,A0,A1,A2,A7,A8,A9,A11
	CALLR	BONE_OBJ	
	JRZ	BONE_SMASH_X

	MOVE	A0,A7
	MOVB	*A7(MOVEPLYR),A0
	CALLA	GPLAYD			;GET THE PLAYER WE BELONG TO
	MOVE	A7,A0

	MOVB	*A0(MOVETYPE),A4	;LET'S SEE WHAT TYPE IT IS
	JRZ	BONE_SMASH_H		;BR = SMASHING A HORIZONTAL BONE

	CMPI	VERTBAR,A4
	JRNE	BONE_SMASH_X		;BR = MOVE IS NOT COOL FOR A BONE

*SMASHING A VERTICAL BONE
	MOVE	A1,A8
	MOVE	*A8(OIMG),A1,L		;LET'S SEE WHO THIS IS
	CMPI	VBONCR2,A1
	JREQ	BONE_SMASH_V2
	CMPI	VBONCR3,A1
	JREQ	BONE_SMASH_V3
	MOVI	VBONCR2,A1		;STICK THIS IMAGE IN
	MOVI	VSMASH1,A9		;ANIMATE THIS
	JRUC	BONE_SMASH_STUFF
BONE_SMASH_V2:
	MOVI	VBONCR3,A1
	MOVI	VSMASH1,A9
	JRUC	BONE_SMASH_STUFF
BONE_SMASH_V3:
	MOVI	VSMASH2,A9
	JRUC	BONE_DEL_STUFF

*SMASHING A HORIZONTAL BONE
BONE_SMASH_H:
	MOVE	A1,A8
	MOVE	*A8(OIMG),A1,L		;LET'S SEE WHO THIS IS
	CMPI	HBONCR2,A1
	JREQ	BONE_SMASH_H2
	CMPI	HBONCR3,A1
	JREQ	BONE_SMASH_H3
	MOVI	HBONCR2,A1		;STICK THIS IMAGE IN
	MOVI	HSMASH1,A9		;ANIMATE THIS
	JRUC	BONE_SMASH_STUFF
BONE_SMASH_H2:
	MOVI	HBONCR3,A1
	MOVI	HSMASH1,A9
	JRUC	BONE_SMASH_STUFF
BONE_SMASH_H3:
	MOVI	HSMASH2,A9
	JRUC	BONE_DEL_STUFF

*DELETE BONE FROM EXISTANCE
BONE_DEL_STUFF:
	MOVE	A0,A11
	MOVE	*A2(PSUPP),A1,L
	MOVE	A8,A0
	CALLR	DECPBARS
	CALLR	DELBAR			;WIPE THE SUCKER 
	MOVE	A11,A0
	JRUC	BONE_SMASH_ANI
BONE_SMASH_STUFF:
	MOVE	*A8(OFLAGS),A4,W
	CALLA	ANI			;ANIMATE IN THE NEW FRAME
	CALLA	OBJPROC_KILL
	MOVE	A0,A11
	CREATE	INDPID,BONE_OFF_ON
	MOVE	A0,*A8(OPLINK),L
	MOVE	A11,A0
BONE_SMASH_ANI:
	CALLR	DUMBAR			;CREATE A BAR OBJECT
	JRZ	BONE_SMASH_X
	MOVI	JUNKOID,A1
	MOVE	A1,*A0(OID),W
	MOVE	A0,A8
	MOVK	1,A11
	CREATE	INDPID,ANIMATE_DEL
BONE_SMASH_X:
	MMFM	SP,A0,A1,A2,A7,A8,A9,A11
	RETS

**************************************************************************
*								         *
* BONE_OFF_ON - TURN A BONE OFF THEN ON, USED FOR BONE_SMASH		 *
* A8 = PTR TO BONE OBJECT						 *
*								         *
**************************************************************************
BONE_OFF_ON:
	CALLA	OBJ_OFF
	SLEEP	10
	CALLA	OBJ_ON
	CLR	A0
	MOVE	A0,*A8(OPLINK),L
	DIE

*BONE SMASH ANIMATIONS
VSMASH1:
	.LONG	VBONCR1
	.WORD	10
	.LONG	0
VSMASH2:
	.LONG	VBONCR4
	.WORD	10
	.LONG	0
HSMASH1:
	.LONG	HBONCR1
	.WORD	10
	.LONG	0
HSMASH2:
	.LONG	HBONCR4
	.WORD	10
	.LONG	0

*
*OBLITERATION SEQUENCES
VOBLIT1:
	.LONG	P1VBON
	.WORD	5
	.LONG	VBONCR1
	.WORD	10|MAKESOUND
	.LONG	BONESMASH_SND
	.LONG	VBONCR3
	.WORD	10
	.LONG	0

HOBLIT1:
	.LONG	P1HBON
	.WORD	5
	.LONG	HBONCR1
	.WORD	10|MAKESOUND
	.LONG	BONESMASH_SND
	.LONG	HBONCR3
	.WORD	10
	.LONG	0
*
*SOUND FOR SMASHING A BONE
BONESMASH_SND
	.WORD	>F005,>C,>805E,0	;WHEEL CRUNCHES A BONE

**************************************************************************
*								         *
* FLASH_BAR - PROCESS TO FLASH A BAR ON AND OFF AT A RAPID RATE.	 *
* A8 = PTR TO BAR							 *
*								         *
**************************************************************************
FLASH_BAR:
	CALLA	OBJ_OFF
	SLEEP	2
	CALLA	OBJ_ON
	SLEEP	2
	JRUC	FLASH_BAR

**************************************************************************
*								         *
* BONED_IN - CHECK TO SEE IF THE GIVEN MOVE IS BONED IN.		 *
* 		BLOCKED IN THE DOWN DIRECTION IS DETERMINED BY		 *
* 		A BONE OR AN EDGE. THIS IS BECAUSE OF THE FUNKINESS	 *
* 		OF FINDING A CLOSE MOVE POINT WHEN AN OBJECT BUMPS	 *
* 		INTO AN UP BONE.					 *
* A0 = PTR TO MOVE DATA							 *
* RETURNS:								 *
* 	 Z = BONED IN.							 *
* 	NZ = NOT BONED IN.						 *
* A4 (LOW WORD) = # OF ADJACENT BONES					 *
* A4 BIT 16	= IF 1 BONE EXISTS UP					 *
* A4 BIT 17	= IF 1 BONE EXISTS DOWN					 *
* A4 BIT 18	= IF 1 BONE EXISTS LEFT					 *
* A4 BIT 19	= IF 1 BONE EXISTS RIGHT				 *
*								         *
**************************************************************************
BONED_IN:
	MMTM	SP,A2,A3
	CALLR	ADJACENT_BONES
	MOVE	A4,A2
	MOVY	A2,A3
	ZEXT	A2
	CMPI	4,A2			;FOUR BONES AROUND ME?
	JREQ	BONED_IN_X		;BR = YES, I'M BONED
	CMPI	3,A2			;HOW ABOUT THREE?
	JRNE	BONED_IN_X		;BR = NO, NO GOOFY TRAPS
	SRL	16,A3
	BTST	DOWN,A3			;IS THE DOWN BONE MISSING?
	JRNE	BONED_IN_X		;BR = NO, NOT BONED IN WIERDLY
	MMTM	SP,A0,A1
	MOVE	A0,A1	
	MOVI	DOWN,A0
	CALLA	TWO_MOVES		;THIS WILL SET THE Z BIT CORRECTLY
	MMFM	SP,A0,A1
BONED_IN_X:
	MMFM	SP,A2,A3
	RETS


**************************************************************************
*								         *
* BONED_IN_4 - CHECK TO SEE IF THE GIVEN MOVE IS BONED IN.		 *
* A0 = PTR TO MOVE DATA							 *
* RETURNS:								 *
* 	 Z = BONED IN.							 *
* 	NZ = NOT BONED IN.						 *
* A4 (LOW WORD) = # OF ADJACENT BONES					 *
* A4 BIT 16	= IF 1 BONE EXISTS UP					 *
* A4 BIT 17	= IF 1 BONE EXISTS DOWN					 *
* A4 BIT 18	= IF 1 BONE EXISTS LEFT					 *
* A4 BIT 19	= IF 1 BONE EXISTS RIGHT				 *
*								         *
**************************************************************************
BONED_IN_4:
	PUSH	A2
	CALLR	ADJACENT_BONES
	CMPI	4,A2			;ARE WE SURROUNDED BY INDESTRUCTOS?
	JRLO	BI4_NPX			;BR = NO
	CLR	A2
	INC	A2			;CLEAR Z TO SAY WE ARE NOT BONED
	JRUC	BI4_X
BI4_NPX
	MOVE	A4,A2
	ZEXT	A2
	CMPI	4,A2			;FOUR BONES AROUND ME?
BI4_X
	PULL	A2
	RETS

**************************************************************************
*								         *
* BONED_IN_GREY - CHECK TO SEE IF A GIVEN MOVE IS SURROUNDED BY		 *
* 		 INDESTRUCTIBLE BONES.					 *
* A0 = PTR TO MOVE DATA							 *
* RETURNS:								 *
* 	 Z = BONED IN GREY BONES.    					 *
* 	NZ = NOT BONED IN GREY BONES.					 *
* A4 (LOW WORD) = # OF ADJACENT BONES					 *
*								         *
**************************************************************************
BONED_IN_GREY
	PUSH	A2
	CALLR	ADJACENT_BONES
	CMPI	4,A2			;ARE WE SURROUNDED BY INDESTRUCTOS?
	PULL	A2
	RETS

**************************************************************************
*								         *
* ADJACENT_BONES - COUNT THE NUMBER OF ADJACENT BONES TO THE GIVEN	 *
* 		MOVE POINT. 4 IS THE MAX.				 *
* A0 = PTR TO MOVE POINT DATA						 *
* RETURNS:								 *
* A2 = NUMBER OF BONES THAT ARE OF PXPLAYER TYPE.			 *
* A4 (LOW WORD) = # OF ADJACENT BONES					 *
* A4 BIT 16	= IF 1 BONE EXISTS UP					 *
* A4 BIT 17	= IF 1 BONE EXISTS DOWN					 *
* A4 BIT 18	= IF 1 BONE EXISTS LEFT					 *
* A4 BIT 19	= IF 1 BONE EXISTS RIGHT				 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
ADJACENT_BONES:
	MMTM	SP,A1,A3
	CLR	A4			;CLEAR COUNT
	CLR	A2			;CLEAR PXPLAYER COUNT
	MOVI	UP,A1
ABONE_LP:
	MOVE	A1,A3			;SAVE CURRENT DIRECTION
	CALLA	ONE_MOVE		;GET MOVE IN THIS DIRECTION
	JRZ	ABONE_NEXT
	MOVB	*A1(MOVEPLYR),A1
	JRN	ABONE_NEXT
	CMPI	PXPLAYER,A1
	JRNE	ABONE_NPX
	INC	A2			;INCREMENT THE PX COUNT
ABONE_NPX
	INC	A4			;COUNT BONE
	MOVE	A3,A1
	ADDK	16,A1
	BSET	A1,A4			;SET CORRECT BIT
ABONE_NEXT:
	MOVE	A3,A1
	INC	A1
	CMPI	RIGHT,A1
	JRLS	ABONE_LP
	MMFM	SP,A1,A3
	RETS

**************************************************************************
*								         *
* BONE_OBJ - RETURN THE PTR TO THE BONE OBJECT RESTING UPON THE		 *
* 		GIVEN MOVE.						 *
* A0 = PTR TO MOVE POINT						 *
* RETURNS:								 *
* 	 Z = NO BONE FOUND						 *
* 	NZ = BONE FOUND (A1 = PTR TO BONE)				 *
* NOTE: WILL ALSO RETURN ZERO IF THIS IS AN INDESTRUCTIBLE BONE.	 *
*								         *
**************************************************************************
BONE_OBJ:
	MMTM	SP,A0,A2,A3
	CLR	A1
	MOVE	*A0(MOVEPOS),A3,L
	MOVB	*A0(MOVEPLYR),A0	;GET BONE ON THIS SPOT
	JRN	BONE_OBJ_X		;BR = NONE FOUND
	CMPI	PXPLAYER,A0
	JREQ	BONE_OBJ_X
	CALLA	GPLAYD			;WHO'S IS IT
	MOVE	*A2(PSUPP),A1,L		;GET THE LIST TO SEARCH
	MOVE	A3,A0			;POSITION TELLS ALL
	CALLA	ISSUPPANI
BONE_OBJ_X:
	MOVE	A1,A1
	MMFM	SP,A0,A2,A3
	RETS
	
**************************************************************************
*								         *
* COUNT_BONES - COUNT THE BONES IN A GIVEN DIRECTION FROM A GIVEN	 *
* 		MOVE POINT.						 *
* A0 = MOVE POINT							 *
* A1 = DIRECTION							 *
* RETURNS								 *
* A5 = BONE COUNT							 *
* A6 = # OF MOVES SEARCHED						 *
*								         *
**************************************************************************
COUNT_BONES:
	MMTM	SP,A0,A2
	CLR	A5
	CLR	A6
COUNT_BLP:
	MOVE	A1,A2
	CALLA	ONE_MOVE		;GO TO THE NEXT MOVE
	JRZ	COUNT_BX		;WE HIT THE END
	INC	A6
	MOVE	A1,A0
	MOVE	A2,A1
	MOVB	*A0(MOVEPLYR),A2	;BONE HERE?
	JRN	COUNT_BLP		;BR = NO
	INC	A5			;TALLY BONE
	JRUC	COUNT_BLP
COUNT_BX
	MOVE	A2,A1
	MMFM	SP,A0,A2
	RETS


	.DATA
*
*TABLE OF BAR IMAGE HEADERS
*SOMEBODY PICK THIS UP, WOULD YA?
BARTAB
	.LONG	P1HINIT,P2HINIT,P3HINIT,P4HINIT
	.LONG	P1VINIT,P2VINIT,P3VINIT,P4VINIT
*
*TABLE OF BAR SUPPLEMENTAL LISTS
BARSUPP
	.LONG	P1BARS,P2BARS,P3BARS,P4BARS

**************************************************************************
*                                                                        *
* 		      BAR INITIALIZATION TABLES				 *
*                                                                        *
**************************************************************************
P1HINIT
	.LONG	0,0
	.WORD	0,BARIZPOS
	.LONG	P1HBON,[5,5],DUMCOLL
	.WORD	DMAWNZ,P1OID|HBAROID

P2HINIT
	.LONG	0,0
	.WORD	0,BARIZPOS
	.LONG	P2HBON,[5,5],DUMCOLL
	.WORD	DMAWNZ,P2OID|HBAROID

P3HINIT
	.LONG	0,0
	.WORD	0,BARIZPOS
	.LONG	P3HBON,[5,5],DUMCOLL
	.WORD	DMAWNZ,P3OID|HBAROID

P4HINIT
	.LONG	0,0
	.WORD	0,BARIZPOS
	.LONG	P4HBON,[5,5],DUMCOLL
	.WORD	DMAWNZ,P4OID|HBAROID

PXHINIT
	.LONG	0,0
	.WORD	0,BARIZPOS
	.LONG	PXHBON,[5,5],DUMCOLL
	.WORD	DMAWNZ,PXOID|HBAROID

P1VINIT
	.LONG	0,0
	.WORD	0,BARIZPOS
	.LONG	P1VBON,[5,5],DUMCOLL
	.WORD	DMAWNZ,P1OID|VBAROID

P2VINIT
	.LONG	0,0
	.WORD	0,BARIZPOS
	.LONG	P2VBON,[5,5],DUMCOLL
	.WORD	DMAWNZ,P2OID|VBAROID

P3VINIT
	.LONG	0,0
	.WORD	0,BARIZPOS
	.LONG	P3VBON,[5,5],DUMCOLL
	.WORD	DMAWNZ,P3OID|VBAROID

P4VINIT
	.LONG	0,0
	.WORD	0,BARIZPOS
	.LONG	P4VBON,[5,5],DUMCOLL
	.WORD	DMAWNZ,P4OID|VBAROID

PXVINIT
	.LONG	0,0
	.WORD	0,BARIZPOS
	.LONG	PXVBON,[5,5],DUMCOLL
	.WORD	DMAWNZ,PXOID|VBAROID
