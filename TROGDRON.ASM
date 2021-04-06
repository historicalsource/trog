	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGDRON.ASM'
	.TITLE	" <<< T R O G  -- DRONE INTELLIGENCE >>>"
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
	.INCLUDE	"TROGAEQU.ASM"
	.INCLUDE	"IMGTBL.GLO"

	.DEF	CLR_DRONE, DRONE_DELETE

	.REF	PLAYER, GPLAYNUM, PLAYER_RESTART, DELBAR

	.TEXT

	.IF	0
**************************************************************************
*								         *
* DRONE_START - START A DRONE PLAYER					 *
* A2 = PTR TO PLAYER DATA THAT WILL BE THE DRONE			 *
* RETURNS:								 *
* 	 Z = COULDN'T START THE DRONE					 *
* 	NZ = DRONE STARTED						 *
*								         *
**************************************************************************
DRONE_START:
	MMTM	SP,A0,A1,A8
	CLR	A0
	MOVE	A0,*A2(POBJ),L		;WE DON'T WANT PLAYER RESTART TO CREATE
	CALLA	PLAYER_RESTART		;MAKE SURE EVERYTHING IS ZERO
	CALLA	PLAYER
	JRZ	DRONE_START_X	 	;COULDN'T CREATE THE DUDE
	MOVK	1,A1
	MOVE	A1,*A2(PDRONEFLG),W
	MOVE	A2,A2	
DRONE_START_X:
	MMFM	SP,A0,A1,A8
	RETS

**************************************************************************
*								         *
* DRONE_DELETE - ROUTINE TO DELETE ALL DRONE STUFF.			 *
* A2 = PTR TO PLAYER DRONE						 *
*								         *
**************************************************************************
DRONE_DELETE:
	MMTM	SP,A0,A1,A3,A8
	MOVE	*A2(PDRONEFLG),A0,W
	JRZ	DRONE_DELETE_X

	MOVE	*A2(PSUPP),A1,L
	MOVE	*A1,A0,L
	JRZ	DRONE_DEL_DINOS
DRONE_DEL_BARS:
	MOVE	*A0(OSLINK),A3,L		;KEEP NEXT LINK FOR DEL
	CALLA	DELBAR
	MOVE	A3,A0
	JRNZ	DRONE_DEL_BARS

DRONE_DEL_DINOS:
	CALLA	GPLAYNUM
	MOVI	DINOS,A8
	MOVE	*A8,A8,L
	JRZ	DRONE_DEL_EGGS
DRONE_DEL_LP:
	MOVE	*A8(OID),A3,W
	SLL	28,A3
	SRL	28,A3
	CMP	A3,A0
	JRNE	DRONE_DEL_NXT
	MOVE	*A8(OPLINK),A3,L
	JRZ	DRONE_DEL_NXT
	MOVB	*A3(DDRONE),A1
	JRZ	DRONE_DEL_NXT
	MOVB	A1,*A3(DDRONEDEL)
DRONE_DEL_NXT:
	MOVE	*A8(OSLINK),A8,L
	JRNZ	DRONE_DEL_LP

DRONE_DEL_EGGS:
	MOVE	A0,A3
	ORI	EGGOID,A0
	CLR	A1
	NOT	A1
	MOVI	EGGS,A8
	CALLA	DELETE_SUPP_ID
	MOVE	*A2(PEXITPNT),A0,L
	JRZ	DRONE_DEL_CPD		;BR = NO EXIT POINT ALLOCATED
	MOVE	*A0(EMOVEOBJ),A8,L
	JRZ	DRONE_DEL_CPD
	CLR	A8
	MOVE	A8,*A0(EMOVEOBJ),L
	MOVE	A3,A0
	ORI	HOUSEOID,A0
	MOVI	HOUSELST,A8
	CALLA	DELETE_SUPP_ID
DRONE_DEL_CPD:
	MOVE	*A2(POBJ),A8,L
	CALLA	OBJPROC_KILL
	CALLA	DELETE_OBJ
	CLR	A0
	MOVE	A0,*A2(POBJ),L			;FOOL PLAYER_RESTART
	MOVE	A0,*A2(PDINOCNT),W		;AND DO WHAT IT DOESN'T
	MOVE	A0,*A2(PWAVEST),W
	MOVE	A0,*A2(PDTHPOS),L
	CALLA	PLAYER_RESTART
DRONE_DELETE_X:
	MMFM	SP,A0,A1,A3,A8
	RETS

**************************************************************************
*								         *
* CLR_DRONE - ROUTINE TO CLEAR A PLAYERS DRONE STATUS, IF HE WAS ONE.	 *
* 		THIS IS A WAVE END THING.				 *
* A2 = PTR TO PLAYER DATA						 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
CLR_DRONE:
	MOVE	*A2(PDRONEFLG),A14,W
	JRZ	CLR_DRONE_X
	CLR	A14
	MOVE	A14,*A2(PDRONEFLG),W
	MOVE	A14,*A2(POBJ),L
CLR_DRONE_X:
	RETS

	.ENDIF

**************************************************************************
*								         *
* DRONE_DELETE - ROUTINE TO DELETE ALL DRONE STUFF.			 *
* A2 = PTR TO PLAYER DRONE						 *
*								         *
**************************************************************************
DRONE_DELETE:
	RETS

**************************************************************************
*								         *
* CLR_DRONE - ROUTINE TO CLEAR A PLAYERS DRONE STATUS, IF HE WAS ONE.	 *
* 		THIS IS A WAVE END THING.				 *
* A2 = PTR TO PLAYER DATA						 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
CLR_DRONE:
	RETS



	.END
