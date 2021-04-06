	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGHAUS.ASM'
	.TITLE	" <<< T R O G  -- TRANSPORTER HOUSE ROUTINES >>>"
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
	.INCLUDE	"TROGAEQU.ASM"
	.INCLUDE	"IMGTBL.GLO"

**************************************************************************
*								         *
* 	REFS AND DEFS							 *
*								         *
**************************************************************************

	.DEF	HOUSE_START, FB_HOUSE, TGEN_START

	.DEF	ROCK_START, ROCK_TABLE_1, PALM_TABLE_1, TROGHENG1
	.DEF	TROGSKULL1, TROGSKULL2
	.DEF	HOUSE_TABLE_1, HOUSE_TABLE_2, HOUSE_TABLE_3
	.DEF	ZIG_TABLE_1, ZIG_TABLE_2
	.DEF	TGEN_TABLE_1

	.REF	ENEMY_START, FIND_OPEN_CPNT, TOMOVE, BUMP
	.REF	DINOWXFER, REXINIT, GETINIT_G
	.REF	GETANIXY, GETCENT, TGEN_CNT, TGEN_CPTRS

	.REF	DINO_CENTER, FIND_CLOSE_MPNT, FIND_CLOSE_CPNT
	.REF	START_INVINCIBILITY,FIRE_SND,KILL_INVINCIBILITY
	.REF	DINOTURN, FIND_SAFEST
	.REF	TROG_CENTER, TROGWXFER, TROGINIT
	.REF	WHLXFER, WHL_CENTER, WHLINIT, FIREBALL_XFER
	.REF	IND_BONE, DINOLOAD, DINO_FRANIM, IS_DINO_DEAD_A0

	.TEXT
	.EVEN


**************************************************************************
*								         *
* TGEN_START - ROUTINE TO START A TROG GENERATOR(S)			 *
* A5 = HOUSE START TABLE						 *
* RETURNS								 *
* 	NOTHING								 *
*								         *
**************************************************************************
TGEN_START:
	MMTM	SP,A0,A1,A5,A7,A8,A9
TS_LOOP
	MOVE	*A5+,A8,L		; SRC [Y,X] 1
	JRZ	TS_DONE
	CALLR	TGEN_CREATE
	JRUC	TS_LOOP
TS_DONE
	MMFM	SP,A0,A1,A5,A7,A8,A9
	RETS

**************************************************************************
*								         *
* TGEN_CREATE - ROUTINE TO CREATE A TROG GENERATOR 			 *
* A8 = [Y,X] POINT TO SET IT UPON					 *
*								         *
**************************************************************************
TGEN_CREATE
      	MMTM	SP,A0,A1,A3,A5,A6,A8
	MOVE	A8,A1
*
*SETUP BONE BORDER
*
	SUBK	16,A1			; LEFT BONE
	CALLA	IND_BONE
	ADDI	32,A1			; RIGHT BONE
	CALLA	IND_BONE
	SUBI	[16,16],A1		; TOP BONE
	CALLA	IND_BONE
	MOVE	A8,A1
	CALLA	FIND_CLOSE_CPNT
*
*CREATE THE GENERATOR
*
	MOVE	A0,A6			;SAVE CENTER POINT AWAY
	MOVI	TGEN_INIT,A5
	CALLA	CREATE_OBJ
	JRZ	TGEN_X			;BR = NO OBJECT AVAILABLE, BAIL!

	MOVB	*A6(CMOVEEGG),A14	;HANDLE CENTER POINT BOOKS
	INC	A14
	JRNZ	TGEN_SPOT_BAD
	MOVIB	TGENID,*A6(CMOVEEGG)	;MARK THE SPOT TAKEN
TGEN_SPOT_BAD
	CLR	A14
	NOT	A14
	MOVB	A14,*A6(CMOVETROG)	;MAKE SURE TROG DOES DO ANYTHING HERE

	MOVE	A0,A8
	MOVE	A6,A0			;CENTER POINT
	CALLA	TOMOVE			;PLACE THE GENERATOR ON THE SPOT

	MOVE	@TGEN_CNT,A14,W
	INC	A14
	MOVE	A14,@TGEN_CNT,W
	DEC	A14
	SLL	5,A14
	ADDI	TGEN_CPTRS,A14
	MOVE	A0,*A14,L		;STORE THE PTR TO THIS GENERATOR

	MOVE	A8,A0
	CALLA	SET_ZPOS		;SET Z POSITION
	CALLA	INSERT_OBJ		;ERECT HOUSE
*
*CREATE THE BACKGROUND
*
	MOVI	TGENBACK_INIT,A5
	CALLA	CREATE_OBJ
	JRZ	TGEN_X

	CALLA	GETANIXY_PACKED		;ANI POINT IN A3
	MOVE	A0,A8
	CALLA	OBJ_TO_PNT
	CALLA	SET_MZPOS
	CALLA	INSERT_OBJ

TGEN_X
	MMFM	SP,A0,A1,A3,A5,A6,A8
	RETS


**************************************************************************
*								         *
* 	HOUSE_START							 *
* 									 *
* 	HOUSING SLUMLORD MANAGER					 *
* 									 *
* 	ENTRY								 *
* 		A5 = HOUSE START TABLE					 *							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* 	CALL								 *
* 		CALL							 *
*								         *
**************************************************************************
HOUSE_START:
	MMTM	SP,A0,A1,A5,A7,A8,A9,A10,A11
HOUSE_START_LOOP
	MOVE	*A5,A8,L		; SRC [Y,X] 1
	JRZ	HOUSE_START_DONE
	MOVE	*A5(80H),A11,L		;GET THE GEM PALETTE
	MOVE	*A5(20H),A9,L		; SRC HOUSE TYPE 1
	MOVE	*A5(40H),A10,L		; DEST [Y,X] 1
	CREATE	HAUSPID,HOUSE_PROCESS
	SWAP	A8,A10			; SRC/DEST [Y,X]
	MOVE	*A5(60H),A9,L		; SRC HOUSE TYPE 2
	CREATE	HAUSPID,HOUSE_PROCESS
	ADDI	(5*32),A5
	JRUC	HOUSE_START_LOOP
HOUSE_START_DONE
	MMFM	SP,A0,A1,A5,A7,A8,A9,A10,A11
	RETS

**************************************************************************
*								         *
* HOUSE_PROCESS - PROCESS TO CREATE AND ANIMATE ONE TRANSPORT HOUSE.	 *
* A8 = [Y,X] LOCATION OF THIS TRANSPORT					 *
* A9 = PTR TO HOUSE IMAGE HEADER					 *
* A10 = [Y,X] DESTINATION OF THIS TRANSPORT HOUSE			 *
* A11 = PTR TO GEM PALETTE						 *
*								         *
**************************************************************************
HTOXY	EQU	PDATA
HDOT	EQU	HTOXY+32
HHOUSE	EQU	HDOT+32

HOUSE_PROCESS:
	CLRM	*A13(HDOT),L		;CLEAR THE DOT PTR JUST IN CASE
	MOVE	A10,*A13(HTOXY),L	; SAVE AWAY WHERE THIS HOUSE WARPS TO
	MOVE	A8,A1
*
*SETUP BONE BORDER
*
	SUBK	16,A1			; LEFT BONE
	CALLA	IND_BONE
	ADDI	32,A1			; RIGHT BONE
	CALLA	IND_BONE
	SUBI	[16,16],A1		; TOP BONE
	CALLA	IND_BONE
	MOVE	A8,A1
	CALLA	FIND_CLOSE_CPNT
*
*CREATE THE TRANSPORT HOUSE
*
	MOVE	A0,A6			; SAVE CENTER POINT AWAY
	MOVI	HOUSE_INIT,A5
	CALLA	CREATE_OBJ
	JRZ	HOUSE_PROC_DIE		;BR = NO HOUSE AVAILABLE, BAIL!

	MOVE	A0,A8			;STORE OBJECT IN NATURAL SPOT
	MOVE	A8,*A13(HHOUSE),L
	CLRM	*A8(OPLINK),L
	MOVE	A9,A1			; NEW HOUSE PICTURE
	MOVE	*A8(OFLAGS),A4,W
	CALLA	ANI			; SET THE NEW HOUSE UP

	MOVB	*A6(CMOVEEGG),A2	;HANDLE CENTER POINT BOOKS
	INC	A2
	JRNZ	HOUSE_SPOT_BAD
	MOVIB	HAUSID,*A6(CMOVEEGG)	;MARK THE SPOT TAKEN
HOUSE_SPOT_BAD
	CLR	A14
	NOT	A14
	MOVB	A14,*A6(CMOVETROG)	;MAKE SURE TROG DOES DO ANYTHING HERE

	CLRM	*A8(OMLINK),L		;BUG PROTECTION

	MOVE	A6,A0			;CENTER POINT
	CALLA	TOMOVE			;PLACE THE HOUSE ON THE SPOT

	MOVE	A8,A0
	CALLA	SET_ZPOS		;SET Z POSITION
	MOVI	ENEMIES,A1
	CALLA	INSERT_OBJ_SUPP		;ERECT HOUSE
*
*CREATE THE INDICATOR GEM
*
	MOVI	GEM_INIT,A5
	CALLA	CREATE_OBJ
	JRZ	HOUSE_RUN

	CALLA	GETANIXY_PACKED		; ANI POINT IN A3
	MOVE	*A8(OZPOS),A14,W
	INC	A14
	MOVE	A14,*A0(OZPOS),W	; GET IT UP ON TOP
	MOVE	A0,A8

	CLRM	*A8(OMLINK),L		;BUG PROTECTION

	CALLA	OBJ_TO_PNT		;ALIGN ON THE HOUSE

	MOVE	A11,A0
	CALLA	CHANGE_PAL		;SWITCH TO THE PROPER PALETTE

	CALLA	INSERT_OBJ
	MOVE	A8,*A13(HDOT),L		;STORE FOR FLASH
*
*CREATE THE TRANSPORT BACKGROUND
*
	CALLR	GETBACKINIT		;GET SPECIFIC FOR THIS WAVE TYPE
	MOVE	A14,A5
	CALLA	CREATE_OBJ
	JRZ	HOUSE_RUN

	CALLA	GETANIXY_PACKED		;ANI POINT IN A3
	MOVE	A0,A8
	CLRM	*A8(OMLINK),L		;BUG PROTECTION
	CALLA	OBJ_TO_PNT
	CALLA	SET_MZPOS
	CALLA	INSERT_OBJ

HOUSE_RUN
	MOVE	*A13(HHOUSE),A8,L	;EVERYTHING IS CREATED
	MOVE	A13,*A8(OPLINK),L	;LINK UP THE HOUSE
*
*JUST HOLD AND FLASH THE DOT, IF THERE IS ONE.
*
	MOVE	*A13(HDOT),A8,L		; CHECK TO SEE IF THERE IS A DOT
	JRZ	HOUSE_DOTLESS		; BR = NOPE, DOTLESS
	MOVI	GEM_SCRIPT,A9		; IT WALKS, IT TALKS, IT FLASHES
	MOVK	1,A1
	JSRP	FRANIM

HOUSE_DOTLESS
	SLOOP	100,HOUSE_DOTLESS	;HOLD FOR COLLISION REFERENCE
;
HOUSE_PROC_DIE:
	DIE

**************************************************************************
*								         *
* FB_HOUSE - FIREBALL HITS THE HOUSE.					 *
* A0 = PTR TO FIREBALL							 *
* A8 = PTR TO HOUSE							 *
*								         *
**************************************************************************
FB_HOUSE
	CALLR	CK_HOUSE_CENT		;DID THAT STINKING FIREBALL HIT?
	JRNC	FBH_X			;BR = NO
	PUSH	A1
	MOVE	*A0(OYVEL),A1,L
	JRN	FBH_GO
	JRUC	FBH_BAIL
*
*SEND THAT FIREBALL
*
FBH_GO
	MMTM	SP,A0,A7,A8,A9,A10,A11
	MOVE	*A0(OPLINK),A11,L	;GET THE FIREBALL CONTROL
	JRZ	HOUSE_DINO_X		;BR = OUT OF CONTROL 

	MOVE	*A8(OPLINK),A10,L	; GET THE HOUSE PROCESS
	JRZ	HOUSE_DINO_X		; IT MUST HAVE DIED

	MOVI	FB_BLAST,A7		; WHICH ROUTINE TO USE
	MOVE	*A10(HTOXY),A9,L	; WHERE TO SEND THEM
	MOVE	A0,A8			; GET VICTIM OBJECT
	MOVE	A11,A0			; OBJECT PROCESS
	MOVE	*A8(OYVEL),A11,L
	CALLA	PSTOP
	ORIM	M_NOCOLL,*A8(OFLAGS),W	; MAKE SURE OBJECT COLLISIONS ARE OFF
	CALLA	OBJ_OFF
	CALLA	XFERPROC_ID		; RELOCATE THE OBJECT
	MMFM	SP,A0,A7,A8,A9,A10,A11
	PULL	A1
	JAUC	DUMSRETS		;RETURN AND STOP SCAN		
FBH_BAIL
	PULL	A1
FBH_X
	JAUC	DUMCRETS		;RETURN AND CONTINUE SCAN

**************************************************************************
*								         *
* 	HOUSE_DINO							 *
* 									 *
* 	HOUSE VS. DINOSAUR COLLISION ROUTINE				 *
* 									 *
* 	ENTRY								 *
* 		A0	HOUSE OBJECT POINTER				 *
* 		A8	DINO OBJECT POINTER				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* 	CALL								 *
* 		CALL							 *
*								         *
**************************************************************************
HOUSE_DINO:
	MMTM	SP,A0,A8
	SWAP	A8,A0			; SWAP DINO AND CATAPULT
	CALLR	CK_HOUSE_CENT
	JRNC	HOUSE_BAILOUT
	MMTM	SP,A1,A2,A3,A4,A7,A9,A10,A11
;
;	A0 = DINO
;	A8 = HOUSE
;
	MOVE	*A0(OPLINK),A11,L	; GET THE DINOSAURS CONTROL
	JRZ	HOUSE_DINO_X		; THE DINO IS OUT OF CONTROL

	MOVE	*A8(OPLINK),A10,L	; GET THE HOUSE PROCESS
	JRZ	HOUSE_DINO_X		; IT MUST HAVE DIED

	CALLA	IS_DINO_DEAD_A0
	JRZ	HOUSE_DINO_X

;	CALLR	CK_HOUSE_CENT		; WALK HIM INTO THE HOUSE
;	JRNC	HOUSE_DINO_X
	MOVI	DINO_BLAST,A7		; WHICH ROUTINE TO USE
;
;	A0  = VICTIM
;	A8  = HOUSE
;	A10 = HOUSE PROCESS
;	A11 = VICTIM PROCESS
;
HOUSE_HAPPEN:
	MOVE	*A10(HTOXY),A9,L	; WHERE TO SEND THEM
	MOVE	A0,A8			; GET VICTIM OBJECT
	CALLA	PSTOP			; STOP THE OBJECT FROM WALKING
	ORIM	M_NOCOLL,*A8(OFLAGS),W	; MAKE SURE OBJECT COLLISIONS ARE OFF
	MOVE	A11,A0			; OBJECT PROCESS
	CALLA	GETA10
	CALLA	GETA11			; TRANSFER REGS FOR YUKS
	CALLA	XFERPROC_ID		; RELOCATE THE OBJECT
	MMFM	SP,A1,A2,A3,A4,A7,A9,A10,A11
	MMFM	SP,A0,A8
	JAUC	DUMSRETS

HOUSE_DINO_X:
	MMFM	SP,A1,A2,A3,A4,A7,A9,A10,A11
HOUSE_BAILOUT
	MMFM	SP,A0,A8
	JAUC	DUMCRETS

**************************************************************************
*								         *
* 	HOUSE_TROG							 *
* 									 *
* 	HOUSE VS. TROG COLLISION ROUTINE				 *
* 									 *
* 	ENTRY								 *
* 		A0	HOUSE OBJECT POINTER				 *
* 		A8	TROG OBJECT POINTER				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* 	CALL								 *
* 		CALL							 *
*								         *
**************************************************************************

HOUSE_TROG:
	MMTM	SP,A0,A8
	SWAP	A8,A0			; SWAP DINO AND CATAPULT
	CALLR	CK_HOUSE_CENT
	JRNC	HOUSE_BAILOUT
	MMTM	SP,A1,A2,A3,A4,A7,A9,A10,A11
;
;	A0 = TROG
;	A8 = HOUSE
;
	MOVE	*A0(OPLINK),A11,L	; GET THE TROG'S CONTROL
	JRZ	HOUSE_DINO_X		; THE TROG IS OUT OF CONTROL
	MOVE	*A8(OPLINK),A10,L	; GET THE HOUSE PROCESS
	JRZ	HOUSE_DINO_X		; IT MUST HAVE DIED
	MOVB	*A11(TTYPE),A1		; GET THE TROG TYPE
	CMPI	TTYPE_WHL,A1
	JRZ	HOUSE_DINO_X		; NO WHEEL GUYS ALLOWED
	CMPI	TTYPE_SPRING,A1		
	JRZ	HOUSE_DINO_X		; NO SPRING GUYS ALLOWED

	MOVE	*A0(OID),A1,W
	CMPI	DEADTROGOID,A1		; IS HE DYING?
	JREQ	HOUSE_DINO_X		; BR = HE'S ALREADY DEAD, NO MORE
	CALLA	CK_HOUSE_CENT		; CHECK IF WE'RE NEAR THE PIT CENTER
	JRNC	HOUSE_DINO_X		; BR = HE'S SAFE
	MOVI	TROG_BLAST,A7
	JRUC	HOUSE_HAPPEN		; HANDLE ALL THE GRIT WORK

**************************************************************************
*								         *
* 	HOUSE_WHEEL							 *
* 									 *
* 	HOUSE VS. WHEEL COLLISION ROUTINE				 *
* 									 *
* 	ENTRY								 *
* 		A0	HOUSE OBJECT POINTER				 *
* 		A8	WHEEL OBJECT POINTER				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* 	CALL								 *
* 		CALL							 *
*								         *
**************************************************************************

HOUSE_WHEEL:
	MMTM	SP,A0,A8
	SWAP	A8,A0			; SWAP DINO AND CATAPULT
	CALLR	CK_HOUSE_CENT
	JRNC	HOUSE_BAILOUT
	MMTM	SP,A1,A2,A3,A4,A7,A9,A10,A11
;
;	A0 = WHEEL
;	A8 = HOUSE
;
	MOVE	*A0(OPLINK),A11,L	; GET THE WHEEL'S CONTROL
	JRZ	HOUSE_DINO_X		; THE TROG IS OUT OF CONTROL
	MOVE	*A8(OPLINK),A10,L	; GET THE HOUSE PROCESS
	JRZ	HOUSE_DINO_X		; IT MUST HAVE DIED
;
	CALLA	CK_HOUSE_CENT		; CHECK IF WE'RE NEAR THE PIT CENTER
	JRNC	HOUSE_DINO_X		; BR = HE'S SAFE
	MOVI	WHEEL_BLAST,A7
	JRUC	HOUSE_HAPPEN		; HANDLE ALL THE GRIT WORK

**************************************************************************
*								         *
* FB_BLAST - SEND THE FIREBALL TO THE OTHER TRANSPORT.			 *
* 		LEAVE VELOCITIES INTACT.				 *
* A8 = FIREBALL OBJECT							 *
* A9 = [Y,X] TO GO TO							 *
* A11 = CURRENT Y VELOCITY OF FIREBALL					 *
* A13 = FIREBALL PROCESS						 *
*								         *
**************************************************************************
FB_BLAST
	SLEEP	10
	MOVE	A9,A1	    		;IS THIS A VALID XFER POINT?
	JRZ	FB_BLAST_REV		;BR = NO
	CALLA	FIND_CLOSE_CPNT
	MOVE	*A0(CMOVEPOS),A0,L
	ADDIY	3,A0
	CALLA	GETCPNT
	CALLA	ALIGNOBJ		;CENTER THE FIRE BALL
FB_BLAST_REV
	MOVE	A8,A0
	CALLA	SET_ZPOS
	NEG	A11	
	MOVE	A11,*A8(OYVEL),L
	MOVE	A11,*A8(OZVEL),L
	CALLA	OBJ_ON
	JAUC	FIREBALL_XFER	

**************************************************************************
*								         *
* 	DINO_BLAST							 *
* 									 *
* 	FLY THE DINO FROM ONE POINT TO ANOTHER				 *
* 									 *
* 	ENTRY								 *
* 		A8	DINO OBJECT					 *
*		A9	[Y,X] TO GO TO					 *
* 		A13	DINO PROCESS					 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* 	CALL								 *
* 		XFER'D FROM THE REGULAR DINO PROCESS			 *
*								         *
**************************************************************************

DINO_BLAST:
	SOUND1	TRANSIN_SND
	CALLA	OBJ_OFF			; GET HIM OFF THE SCREEN
	CALLA	PSTOP			; DON'T GO ANYWHERE, GUY
	MOVE	A9,A1			; WHERE TO GO TO
	JRZ	DINO_BLAST_DIE
	MOVE	A8,A0
	CALLA	FIND_CLOSE_CPNT
	MOVE	A0,A0
	JRZ	DINO_BLAST_DIE
	MOVE	*A0(CMOVEMPTR),A0,L
	CALLA	DINO_CENTER		; CENTER UP THE LITTLE DINO
;
;	TURN THE GUY IN THE "OUT" DIRECTION
;
	MOVK	1,A10
	MOVE	A10,*A13(DDIR),W
;
;	TAKE CARE OF INVINCIBILITY RING
;
	CLR	A10			; NO INV TIME TO START WITH
	MOVE	*A13(DINVPROC),A0,L
	JRZ	NO_INV			; BR = NO INVINCIBILITY
	CALLA	GETA10			; GET TIME LEFT
	CALLA	KILL_INVINCIBILITY	; KILL OFF THE RING
NO_INV
	SLEEP	70
	MOVE	A10,A10
	JRZ	NO_INV_2
	CALLA	START_INVINCIBILITY	; START UP WITH TIME REMAINING
NO_INV_2
	SOUND1	TRANSOUT_SND
	MOVE	*A13(DATABLE),A10,L	; RESTORE THE ANIMATION TABLE
	CALLA	OBJ_ON
	MOVE	*A13(DDIR),A0,W
	CALLA	DINOLOAD		; LOAD THE WALKING SCRIPT
****	MOVI	1402H,A1
	MOVI	0702H,A1
	JSRP	DINO_FRANIM
	ANDNIM	M_NOCOLL,*A8(OFLAGS),W	;COLLSIONS ON
	CLR	A1
	JSRP	DINO_FRANIM
DINO_BLAST_DIE
	CALLA	OBJ_ON
	JAUC	DINOWXFER		; START DINO BACK UP

DINO_DIR:
	.WORD	1,0,1,1

**************************************************************************
*								         *
* 	TROG_BLAST							 *
* 									 *
* 	FLY TROG FROM ONE POINT TO ANOTHER				 *
* 									 *
* 	ENTRY								 *
* 		A8	TROG OBJECT					 *
*		A9	LOCATION TO GO TO				 *
* 		A13	TROG PROCESS					 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* 	CALL								 *
* 		XFER'D FROM THE REGULAR TROG PROCESS			 *
*								         *
**************************************************************************

TROG_BLAST:
	SOUND1	TRANSIN_SND
	CALLA	OBJ_OFF			; GET HIM OFF THE SCREEN
	CALLA	PSTOP			; DON'T GO ANYWHERE, GUY
	MOVE	A9,A1			; WHERE TO GO TO
	JRZ	TROG_BLAST_DIE
	MOVE	A8,A0
	CALLA	FIND_CLOSE_CPNT
	MOVE	A0,A0
	JRZ	TROG_BLAST_DIE
	MOVE	*A0(CMOVEMPTR),A0,L
	CALLA	TROG_CENTER		; CENTER UP MR. TROG
;
;	TURN THE GUY IN THE "OUT" DIRECTION
;
;	MOVE	*A13(DDIR),A10,W
;	SLL	4,A10
;	ADDI	DINO_DIR,A10
;	MOVE	*A10,A10,W
	MOVK	1,A10
	MOVE	A10,*A13(DDIR),W
	SLEEP	70
	SOUND1	TRANSOUT_SND
	CALLA	OBJ_ON
	MOVE	*A13(DATABLE),A10,L	; GET AN ANIMATION TABLE
	MOVE	*A13(DDIR),A0,W
	CALLA	DINOLOAD		; LOAD THE WALKING SCRIPT
****	MOVI	1402H,A1
	MOVI	0802H,A1
	JSRP	DINO_FRANIM
TROG_BLAST_DIE
	CALLA	OBJ_ON
	JAUC	TROGWXFER		; START TROG BACK UP

**************************************************************************
*								         *
* 	WHEEL_BLAST							 *
* 									 *
* 	FLY WHEEL FROM ONE POINT TO ANOTHER				 *
* 									 *
* 	ENTRY								 *
* 		A8	WHEEL OBJECT					 *
*		A9	LOCATION TO GO TO				 *
* 		A13	WHEEL PROCESS					 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* 	CALL								 *
* 		XFER'D FROM THE REGULAR WHEEL PROCESS			 *
*								         *
**************************************************************************

WHEEL_BLAST:
	SOUND1	TRANSIN_SND
	CALLA	OBJ_OFF			; GET HIM OFF THE SCREEN
	CALLA	PSTOP			; DON'T GO ANYWHERE, GUY
	MOVE	A9,A1			; WHERE TO GO TO
	JRZ	WHEEL_BLAST_DIE
	MOVE	A8,A0
	CALLA	FIND_CLOSE_CPNT
	MOVE	A0,A0
	JRZ	WHEEL_BLAST_DIE
	MOVE	*A0(CMOVEMPTR),A0,L
	CALLA	WHL_CENTER		; CENTER UP THE WHEEL
;
;	TURN THE GUY IN THE "OUT" DIRECTION
;
;	MOVE	*A13(DDIR),A10,W
;	SLL	4,A10
;	ADDI	DINO_DIR,A10
;	MOVE	*A10,A10,W
	MOVK	1,A10
	MOVE	A10,*A13(DDIR),W
	SLEEP	70
	SOUND1	TRANSOUT_SND
	CALLA	OBJ_ON
	MOVE	*A13(DATABLE),A10,L	; GET AN ANIMATION TABLE
	MOVE	*A13(DDIR),A0,W
	CALLA	DINOLOAD		; LOAD THE ROLLING SCRIPT ( I HOPE )
	MOVI	1402H,A1
	JSRP	DINO_FRANIM
WHEEL_BLAST_DIE
	ANDNIM	M_NOCOLL,*A8(OFLAGS),W	; TURN WHEEL COLLISIONS BACK ON
	CALLA	OBJ_ON
	JAUC	WHLXFER			; START WHEEL ROLLING AGAIN

**************************************************************************
*								         *
* 	CK_HOUSE_CENT							 *
* 									 *
* 	CHECK IF OBJECT IS NEAR THE CENTER OF A HOUSE			 *
* 									 *
* 	ENTRY								 *
* 		A0	OBJECT						 *
* 		A8	HOUSE OBJECT					 *
* 									 *
* 	EXIT								 *
* 		NC	NOT EVEN CLOSE					 *
* 		 C	CLOSE						 *
* 									 *
* 	CALL								 *
* 		CALL							 *
*								         *
**************************************************************************

CK_HOUSE_CENT:
	MMTM	SP,A8,A1,A2,A3
	CALLA	GETCPNT			; CENTER POINT OF FIRST OBJECT
;	SUBI	[7,0],A1		; FUDGE FACTOR
	ADDI	[10,0],A1		; FUDGE FOR TALL HOUSES
	MOVE	A1,A3
	MOVE	A0,A8
	CALLA	GETCPNT			; AND CENTER POINT OF THE SECOND
	MOVI	[20,3],A2
	CALLA	PNT_IN_RANGE
	JRNC	CK_RET			; JUST CHECK THE X END OF THINGS
	CMPXY	A1,A3
	JRYGT	ISGOOD			; FORCE FOR TROG BEING SILLY
	MOVI	[3,3],A2		; FIX THE RANGE	
	CALLA	PNT_IN_RANGE
	JRUC	CK_RET
ISGOOD
	SETC
CK_RET
	MMFM	SP,A8,A1,A2,A3
	RETS


**************************************************************************
*								         *
* 	ROCK ROUTINES							 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	ROCK_START							 *
* 									 *
* 	START A FEW ROCKS ON THE SCREEN					 *
* 									 *
* 	ENTRY								 *
* 		A5	POINTER TO ROCK LAYOUT TABLE			 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* 	CALL								 *
* 		CALL							 *
*								         *
**************************************************************************

ROCK_START:
	MMTM	SP,A0,A1,A7,A8,A9
ROCK_LOOP
	MOVE	*A5+,A8,L		; [Y,X] COORDINATES
	JRZ	ROCK_DONE	
	MOVE	*A5+,A9,L		; WHICH IMAGE TO USE
	CREATE	ROCKPID,ROCK_PROCESS
	JRUC	ROCK_LOOP
ROCK_DONE
	MMFM	SP,A0,A1,A7,A8,A9
	RETS

**************************************************************************
*								         *
* 	ROCK_PROCESS							 *
* 									 *
* 	START A ROCK AND THE BONES AROUND IT				 *
* 									 *
* 	ENTRY								 *
* 		A8	[Y,X] TO STICK IT				 *
* 		A9	PTR TO THE IMAGE TO USE				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
* 									 *
* 	CALL								 *
* 		CREATE							 *
*								         *
**************************************************************************

ROCK_PROCESS:
	MOVE	A8,A1
	SUBK	16,A1			; LEFT BONE
	CALLA	IND_BONE
	ADDI	32,A1			; RIGHT BONE
	CALLA	IND_BONE
	SUBI	[16,16],A1		; TOP BONE
	CALLA	IND_BONE
	ADDI	[32,0],A1		; BOTTOM BONE
	CALLA	IND_BONE
	MOVE	A8,A1
	CALLA	FIND_CLOSE_CPNT
	JRZ	ROCK_PROC_DIE		; BR = NOTHING TO FIND
	MOVE	A0,A6			; SAVE CENTER POINT AWAY
;
	MOVI	PALM_INIT,A5
	CMPI	PALM1,A9
	JRZ	ROCK_IMG_INIT
	CMPI	PALM2,A9
	JRZ	ROCK_IMG_INIT
	MOVI	ROCK_INIT,A5
;
ROCK_IMG_INIT:
	CALLA	CREATE_OBJ
	JRZ	ROCK_PROC_DIE		; BR = COULDN'T MAKE THE OBJECT

	MOVE	A0,A8			; OBJECT
	MOVE	A9,A1			; ROCK PICTURE TO USE
	MOVE	*A8(OFLAGS),A4,W
	CALLA	ANI			; SET THE NEW HOUSE UP
	MOVE	A6,A0			; CENTER POINT
	CALLA	TOMOVE			; PLACE THE CATAPULT ON THE SPOT

	MOVI	ROCKID,A0
	MOVB	*A6(CMOVEEGG),A2
	INC	A2
	JRNZ	ROCK_SPOT_BAD
	MOVB	A0,*A6(CMOVEEGG)	; MARK IT TAKEN
ROCK_SPOT_BAD
	CLR	A0
	NOT	A0
	MOVB	A0,*A6(CMOVETROG)
	MOVE	A8,A0
	CALLA	SET_ZPOS		; SET Z POSITION
	CALLA	INSERT_OBJ
	MOVI	ENEMIES,A1
	CALLA	INSERT_SUPP		; MAKE US COLLIDABLE
ROCK_PROC_DIE:
	DIE

**************************************************************************
*								         *
* GETBACKINIT - GET THE CORRECT HOUSE BACK INIT TABLE FOR THE WAVE.	 *
* GLOBALS:								 *
* 	BGND_TYPE,W							 *
* RETURNS:								 *
* 	A14 = CORRECT BACK INIT TO USE					 *
*								         *
**************************************************************************
GETBACKINIT:
	MOVI	BACK_TAB,A14
	JAUC	GETINIT_G

**************************************************************************
*								         *
* 	HOUSE TABLES							 *
*								         *
**************************************************************************

HOUSE_INIT:
	.LONG	HOUSE_COLL,[30,30]
	.WORD	DMAWNZ,HAUSOID
	.LONG	trancave1

TGEN_INIT:
	.LONG	DUMCOLL,[30,30]
	.WORD	DMAWNZ,TGENOID
	.LONG	TROGMOUTH

BACK_TAB
	.LONG	BACK_INIT, VBACK_INIT, EBACK_INIT, CBACK_INIT, WBACK_INIT
	.LONG	SBACK_INIT, BACK_INIT, EBACK_INIT

BACK_INIT:
	.LONG	DUMCOLL,0
	.WORD	DMAWNZ,HAUSOID
	.LONG	TRANBACK

VBACK_INIT:
	.LONG	DUMCOLL,0
	.WORD	DMAWNZ,HAUSOID
	.LONG	VTRANBACK

EBACK_INIT:
	.LONG	DUMCOLL,0
	.WORD	DMAWNZ,HAUSOID
	.LONG	ETRANBACK

CBACK_INIT:
	.LONG	DUMCOLL,0
	.WORD	DMAWNZ,HAUSOID
	.LONG	CTRANBACK

WBACK_INIT:
	.LONG	DUMCOLL,0
	.WORD	DMAWNZ,HAUSOID
	.LONG	WTRANBACK

SBACK_INIT:
	.LONG	DUMCOLL,0
	.WORD	DMAWNZ,HAUSOID
	.LONG	STRANBACK

TGENBACK_INIT:
	.LONG	DUMCOLL,[30,30]
	.WORD	DMAWNZ,TGENOID
	.LONG	MOUTHBACK

GEM_INIT:
	.LONG	DUMCOLL,0
	.WORD	DMAWNZ,HAUSOID
	.LONG	GEM1

HOUSE_COLL:
	.WORD	DINOOID,0FFF0H		; COLLIDE WITH ALL DINOS
	.LONG	HOUSE_DINO
	.WORD	TROGOID,0FFF0H		; COLLIDE WITH THE BROTHERS TROG
	.LONG	HOUSE_TROG
	.WORD	WHEELOID,0FFF0H		; COLLIDE WITH THOSE SILLY ROLLERS
	.LONG	HOUSE_WHEEL
	.WORD	0
	.LONG	DUMCRETS		; DO NOTHING

GEM_SCRIPT:
	.LONG	GEM1
	.WORD	20
	.LONG	GEM2
	.WORD	20|SCRIPT
	.LONG	GEM_SCRIPT

;
;	HOUSE TABLE ENTRY FORMAT :
;
;	CPNT 1[Y,X], FRAME1, CPNT 2[Y,X], FRAME2, GEM PALETTE
;
HOUSE_TABLE_1:
	.LONG	[88,66],trancave1,[88,322],trancave1,RED16
	.LONG	0

HOUSE_TABLE_2:
	.LONG	[88,66],trancave1,[88,322],trancave1,RED16
	.LONG	[88,162],trancave1,[88,194],trancave1,BLUE16
	.LONG	0

HOUSE_TABLE_3:
	.LONG	[88,66],trancave1,[88,322],trancave1,RED16
	.LONG	[184,162],trancave2,[88,258],trancave1,BLUE16
	.LONG	[184,226],trancave2,[88,130],trancave1,YELLOW16
	.LONG	0



**************************************************************************
*								         *
* 		TROG GENERATOR TABLE					 *
* 									 *
* 		CPNT [Y,X], FRAME1					 *
*								         *
**************************************************************************
TGEN_TABLE_1:
	.LONG	[88,66]
	.LONG	[88,130]
	.LONG	[88,258]
	.LONG	[88,322]
	.LONG	0

**************************************************************************
*								         *
* 	ROCK TABLES							 *
*								         *
**************************************************************************
ROCK_INIT:
	.LONG	DUMCOLL,0
	.WORD	DMAWNZ,ROCKOID
	.LONG	ZIG1


TROGHENG1
	.LONG	[88,66],TROGHED
	.LONG	[88,322],TROGHED
	.LONG	0

TROGSKULL1
	.LONG	[88,66],SKULL
	.LONG	[88,322],SKULL
	.LONG	0

TROGSKULL2
	.LONG	[88,66],SKULL
	.LONG	[88,322],SKULL
	.LONG	[216,194],SKULL
	.LONG	0

ROCK_TABLE_1
	.LONG	[120,130],BOULDER1
	.LONG	[184,130],BOULDER1
	.LONG	[120,258],BOULDER1
	.LONG	[184,258],BOULDER1
	.LONG	0

ZIG_TABLE_1
	.LONG	[152,194],ZIG1
	.LONG	0

ZIG_TABLE_2
	.LONG	[120,130],ZIG1
	.LONG	[184,130],ZIG1
	.LONG	[120,258],ZIG1
	.LONG	[184,258],ZIG1
	.LONG	0

PALM_INIT:
	.LONG	DUMCOLL,0
	.WORD	DMAWNZ,ROCKOID
	.LONG	PALM1

PALM_TABLE_1
	.LONG	[120,130],PALM2
	.LONG	[184,130],PALM2
	.LONG	[120,258],PALM2
	.LONG	[184,258],PALM2
	.LONG	[152,194],PALM1
	.LONG	0



**************************************************************************
*								         *
* 	SOUNDS								 *
*								         *
**************************************************************************

TRANSIN_SND:	
	.WORD	>F310,>3C,>80A9,0	; TRANSPORT IN SOUND

TRANSOUT_SND:	
	.WORD	>F310,>3C,>80AA,0	; TRANSPORT OUT SOUND

