	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGCOL.ASM'
	.TITLE	" <<< T R O G  -- COLLISION SCAN ROUTINES >>>"
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
	.INCLUDE	"TROGAEQU.ASM"	;Dino and Enemy specifics

	.DEF	COLL_START

	.REF	PXBARS, FREEZE_TIME

	.text

**************************************************************************
*                                                                        *
* PRESCAN0 - SETS UP OBJECT 0 PARAMETERS FOR COLXY AND COLXYZ		 *
* A0 = PTR TO OBJECT 0							 *
* RETURNS:								 *
* 	CARRY CLEAR = DON'T SCAN THIS OBJECT				 *
* 			A4 - A5 UNTOUCHED				 *
* 	CARRY SET = SCAN AWAY						 *
* 	A3 = [ULY,ULX]							 *
* 	A4 = [LRY,LRX]							 *
* 	A5 = INWARD Z							 *
* 	A6 = OUTWARD Z							 *
* NOTE: ALWAYS TRASHES A14						 *
*                                                                        *
**************************************************************************
PRESCAN0
	MOVE	*A0(OFLAGS),A14,W	
	BTST	B_NOCOLL,A14		;IS THIS DUDE COLLIDABLE?
	JRNE	PRESCANF		;BR = NO, DON'T WORRY ABOUT HIM
	SLL	28,A14
	JRZ	PRESCANF		;HE'S NOT EVEN TURNED ON
	MOVE	*A0(ODMAXY),A3,L	;SET UP OBJECT 0 BOX ULX,ULY
	JREQ	PRESCANF		;DMA VALUES ARE YET UNINITIALIZED

	MOVE	*A0(OSIZE),A4,L		;GET HIS SIZE
	ADDXY	A3,A4			;OBJECT 0 LRX,LRY
*Z STUFF
	MOVE	*A0(OZPOS),A5,W		;GET Z MIDPOINT
	MOVE	*A0(OZMINUS),A14,W	;GET Z SIZE IN NEGATIVE DIRECTION
	MOVE	A5,A6
	SUB	A14,A5			;INWARD Z
	MOVE	*A0(OZPLUS),A14,W	;Z SIZE IN POSITIVE DIRECTION
	ADD	A14,A6 			;OUTWARD Z
	SETC
	RETS
PRESCANF
	CLRC
	RETS

**************************************************************************
*								         *
* COLLISION CHECK IN 2-SPACE(COLXY) OR 3-SPACE(COLXYZ)			 *
* A0 =POINTER TO OBJECT BLOCK OF OBJECT TO BE CHECKED(OBJECT 0)		 *
* A1 =POINTER TO SUPPLEMENTAL LIST TO SCAN AGAINST (OBJECT 1)		 *
* RETURN(S)								 *
* 	 Z = NO COLLISIONS THIS SCAN					 *
* 	NZ = COLLISIONS WERE DETECTED					 *
* 	 C = COLLISION SCAN WAS ABORTED					 *
* 	NC = LIST WAS COMPLETELY SCANNED				 *
* IF A COLLISION IS DETECTED, THE OBJECTS COLLISION ROUTINE IS CALLED.	 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
*
*2-D ENTRY PROVIDING OBJECT 0 PARAMS
*
COLXYP
	MMTM	SP,A0,A2,A3,A4,A5,A6,A7,A8,A9,A11
	CLR	A9
	JRUC	COLLPREG
*
*3-D ENTRY PROVIDING OBJECT 0 PARAMS
*
COLXYZP
	MMTM	SP,A0,A2,A3,A4,A5,A6,A7,A8,A9,A11
       	MOVK	1,A9
	JRUC	COLLPREG
COLXYZ0:
	MOVE	*A0(OFLAGS),A14,W	
	BTST	B_NOCOLL,A14		;IS THIS DUDE COLLIDABLE?
	JRNE	COLLX			;BR = NO, DON'T WORRY ABOUT HIM
	SLL	28,A14
	JRZ	COLLX			;HE'S NOT EVEN TURNED ON
	MOVE	*A0(ODMAXY),A3,L	;SET UP OBJECT 0 BOX ULX,ULY
	JREQ	COLLX			;DMA VALUES ARE YET UNINITIALIZED
	MOVE	*A0(OSIZE),A4,L		;GET HIS SIZE
	ADDXY	A3,A4			;OBJECT 0 LRX,LRY
*Z STUFF
	MOVE	*A0(OZPOS),A5,W		;GET Z MIDPOINT
	MOVE	*A0(OZMINUS),A14,W	;GET Z SIZE IN NEGATIVE DIRECTION
	MOVE	A5,A6
	SUB	A14,A5			;INWARD Z
	MOVE	*A0(OZPLUS),A14,W	;Z SIZE IN POSITIVE DIRECTION
	ADD	A14,A6 			;OUTWARD Z

COLLPREG
	CLR	A11			;CLEAR A11
	MOVE	*A1,A8,L		;GET OBJECT LIST
	JRZ	COLLX			;LIST IS NULL
COLLP:
	MOVE	*A8(OFLAGS),A14,W	
	BTST	B_NOCOLL,A14		;IS THIS DUDE COLLIDABLE?
	JRNE	COLLNO			;BR = NO, DON'T WORRY ABOUT HIM
	SLL	28,A14
	JRZ	COLLNO			;NOT TURNED ON
	CMP	A0,A8
	JREQ	COLLNO			;BR = SAME DAMN OBJECT DUDE

	MOVE	*A8(ODMAXY),A7,L	;GET OBJECT 1 ULY,ULX
	JREQ	COLLNO			;BR = DON'T MESS
	CMPXY	A4,A7			;COMPARE 0:(LRX,LRY) TO 1:(ULX,ULY)
	JRXGE	COLLNO
	JRYGE	COLLNO

	MOVE	*A8(OSIZE),A14,L	;GET DISPLAYED SIZE
	ADDXY	A14,A7			;OBJECT 1 LRX,LRY

	CMPXY	A3,A7			;COMPARE 0:(ULX,ULY) TO 1:(LRX,LRY) 
	JRXLE	COLLNO
	JRYLE	COLLNO

*CHECK FOR Z COLLISION
	MOVE	A9,A9
	JREQ	COLLYES			;THIS IS A 2D COLLISION
	MOVE	*A8(OZPOS),A7		;GET Z MIDPOINT
	MOVE	*A8(OZMINUS),A14,W	;SIZE IN THE MINUS DIRECTION

	SUB	A14,A7		;GET INWARD Z1

	CMP	A7,A6		;COMPARE
	JRLE	COLLNO		;OUTWARD Z0 < INWARD Z1

	ADD	A14,A7		;GET BACK TO "MIDPOINT"

	MOVE	*A8(OZPLUS),A14,W	;SIZE IN PLUS DIRECTION
	ADD	A14,A7		

	CMP	A7,A5
	JRLT	COLLYES		;OUTWARD Z1 > INWARD Z0
COLLNO:
	MOVE	*A8(OSLINK),A8,L
	JRNZ	COLLP
COLLX:
	CLRC
COLLXXX
	MOVE	A11,A11
	MMFM	SP,A0,A2,A3,A4,A5,A6,A7,A8,A9,A11
	RETS

COLLX_SETC
	SETC
	JRUC	COLLXXX

COLLYES:
**************************************************************************
*                                                                        *
* 	COLLSION LIST STRUCTURE						 *
* 	-----------------------						 *
* 	.WORD	I.D.0,MASK0						 *
* 	.LONG	ROUTINE0						 *
* 		.							 *
* 		.							 *
* 		.							 *
* 	.WORD	I.D.n,MASKn						 *
* 	.LONG	ROUTINEn						 *
* 	.WORD	0							 *
* 	.LONG	DEFAULT_ROUTINE						 *
*                                                                        *
**************************************************************************
*
*COLLISION VECTOR IS CALLED WITH THESE PARAMETERS
*A0 = PTR TO OBJECT 0
*A1 = I.D. OF OBJECT THAT COLLIDED WITH YOU (0 = DEFAULT CASE)
*A8 = PTR TO OBJECT 1
*NOTE: IF ROUTINE CALLED RETURNS WITH THE Z SET THEN THE
*	COLLISION SCAN WILL END AFTER THIS.
*
****	CALLR	PIXSCAN		;CHECK PIXEL SCAN
****	JRNC	COLLNO		;NO COLLISION ...
	INC	A11		;RETURN A COLLISION
	MMTM	SP,A0,A1,A6,A10
	MOVE	*A8(OSLINK),A10,L	;GET THE NEXT OBJECT IN THE LIST NOW!
	MOVE	*A0(OCVECT),A6,L
	MOVE	*A8(OID),A1,W	;GET THE OBJECT I.D. TO MATCH
	CALLR	COLLCALL
	JRZ	COLLENDR	;THIS MEANS END SCAN AFTER THE NEXT VECTOR CALL

	SWAP	A0,A8
	MOVE	*A0(OCVECT),A6,L
	MOVE	*A8(OID),A1,W	;GET THE OBJECT I.D. TO MATCH
	CALLR	COLLCALL
	JRZ	COLLNDR1	;END SCAN IF FLAGGED TO DO SO
	MOVE	A10,A8		;NEXT OBJECT, IS IT ZERO?
	MMFM	SP,A0,A1,A6,A10
	JRNZ	COLLP		;NO, KEEP ON TRUCKIN'
	JRUC	COLLX
*
*CEASE SCAN AFTER THIS COLLISION VECTOR CALL
COLLENDR
	SWAP	A0,A8
	MOVE	*A0(OCVECT),A6,L
	MOVE	*A8(OID),A1,W	;GET THE OBJECT I.D. TO MATCH
	CALLR	COLLCALL
COLLNDR1
	MMFM	SP,A0,A1,A6,A10
	JRUC	COLLX_SETC

*
*COLLCALL - CALL THE CORRECT COLLISION ROUTINE
*A0 = PTR TO OBJECT 0
*A1 = I.D. TO SCAN FOR IN THE VECTOR LIST
*A6 = COLLISION VECTOR LIST
*A8 = PTR TO OBJECT 1
*NOTE: IF ROUTINE CALLED RETURNS WITH THE Z BIT SET THEN THE
*	COLLISION SCAN WILL END AFTER THIS.
COLLCALL
	MMTM	SP,A2,A3,A4
COLLCLP
	MOVE	*A6+,A2,W		;GET THE FIRST MATCH I.D.
	JREQ	COLLDEF			;AHHH THE DEFAULT CASE
	MOVE	*A6+,A4,W		;GET THE I.D. MASK --  0'S DON'T CARE
	MOVE	A1,A3
	AND	A4,A3			;MASK THE I.D.
	AND	A4,A2			;MASK THE MATCH
	CMP	A3,A2
	JREQ	COLLDEF
	ADDK	32,A6			;SKIP PAST COLLISION VECTOR
	JRUC	COLLCLP		
COLLDEF
	MOVE	*A6,A6,L		;GET THE VECTOR
	CALL	A6			;CALL THE ROUTINE
	MMFM	SP,A2,A3,A4
	RETS

**************************************************************************
*                                                                        *
* COLL_START - ROUTINE TO START THE COLLISION PROCESSES			 *
*                                                                        *
**************************************************************************
COLL_START:
	MMTM	SP,A0,A1,A7
	CREATE	COLLDPID,CDDETECT
	CREATE	COLLEPID,CEDETECT
	MMFM	SP,A0,A1,A7
	RETS
	
**************************************************************************
*                                                                        *
* DINOSAUR COLLISION DETECT PROCESS					 *
*                                                                        *
**************************************************************************
CDDETECT
	SLEEP	1
	MOVI	DINOS,A0
	MOVE	*A0,A0,L
	JREQ	CDDETECT		;THERE ARE NO DINOS TO SPEAK OF
	JRUC	CDD2
CDD1	MOVE	*A0(OSLINK),A0,L	;GRAB NEXT DINO OBJECT
	JREQ	CDDETECT		;END OF LIST
CDD2
	CALLR	PRESCAN0
	JRNC	CDD1			;DON'T WORRY ABOUT THIS DUDE
	ADDI	[3,0],A4		;ADD THIS MUCH TO SCAN WALLS
	MOVI	P1BARS,A1		;FIRST, SCAN AGAINST ALL WALLS
	CALLR	COLXYP
	JRC	CDDETECT		;EXIT SCAN NOW!
	MOVI	P2BARS,A1
	CALLR	COLXYP
	JRC	CDDETECT		;EXIT SCAN NOW!
	MOVI	P3BARS,A1
	CALLR	COLXYP
	JRC	CDDETECT		;EXIT SCAN NOW!
	MOVI	P4BARS,A1
	CALLR	COLXYP
	JRC	CDDETECT		;EXIT SCAN NOW!
	MOVI	PXBARS,A1
	CALLR	COLXYP
	JRC	CDDETECT		;EXIT SCAN NOW!
	SUBI	[3,0],A4
	MOVI	DINOS,A1
	CALLR	COLXYZP
	JRC	CDDETECT		;EXIT SCAN NOW!
	MOVI	TROGS,A1
	CALLR	COLXYZP
	JRC	CDDETECT		;EXIT SCAN NOW!
	MOVI	ENEMIES,A1
	CALLR	COLXYZP
	JRC	CDDETECT		;EXIT SCAN NOW!
	JRUC	CDD1			;CONTINUE PROCESSING

**************************************************************************
*                                                                        *
* ENEMY COLLISION DETECT PROCESS					 *
*                                                                        *
**************************************************************************
CEDETECT
	SLEEP	3
****	MOVE	@FREEZE_TIME,A0,W
****	JRNZ	CEDETECT
	MOVI	TROGS,A0
	MOVE	*A0,A0,L
	JREQ	CEDETECT		;THERE ARE NO ENEMIES TO SPEAK OF
	JRUC	CED2
CED1
	MOVE	*A0(OSLINK),A0,L	;GRAB NEXT ENEMY OBJECT
	JREQ	CEDETECT		;END OF LIST
CED2
	MOVE	*A0(OPLINK),A4,L	;CHECK ENEMIES PROCESS
	JRZ	CED3			;BR = DOES NOT HAVE A CONTROL
	MOVB	*A4(TFREEZE),A4		;IS IT FROZEN?
	JRNZ	CED1			;BR = YES, DON'T SCAN
CED3
	CALLR	PRESCAN0
	JRNC	CED1			;DON'T WORRY ABOUT THIS DUDE
	ADDI	[5,0],A4		;ADD THIS MUCH TO SCAN WALLS
	MOVI	P1BARS,A1		;FIRST, SCAN AGAINST ALL WALLS
	CALLR	COLXYP
	MOVI	P2BARS,A1
	CALLR	COLXYP
	MOVI	P3BARS,A1
	CALLR	COLXYP
	MOVI	P4BARS,A1
	CALLR	COLXYP
	MOVI	PXBARS,A1
	CALLR	COLXYP
	SUBI	[5,0],A4
	MOVI	TROGS,A1
	CALLR	COLXYZP
	MOVI	ENEMIES,A1
	CALLR	COLXYZP
	JRUC	CED1			;CONTINUE PROCESSING

*PIXEL SCANNER COMMENTED OUT 3/22/90 BY GNP
	.IF	0

ODMAIMG	.SET	OIMG
ODMAFLG	.SET	OFLAGS
*
*COLLISION ROUTINE
*A0=OBJECT ZERO
*A8=OBJECT ONE
*RETURNS: CS= COLLISION, CC= NO COLLISION
*NOTE: PIXEL SCAN ONLY OCCURS IFF BOTH OBJECTS HAVE THEIR PIXSCAN FLAG SET.
*	THIS ROUTINE TRASHES A14
*
PIXSCAN:
	MOVE	*A0(OFLAGS),A14,W
	BTST	B_PIXSCAN,A14
	JREQ	NOPIXSCAN		;BR = NO SCAN FOR THIS MAN
	MOVE	*A8(OFLAGS),A14,W
	BTST	B_PIXSCAN,A14		;CHECK TO SEE IF OBJECT 1 IS PIXABLE
	JRNE	PIXSCANG		;BR = BOTH OBJEX SAY "SCAN ME!"
NOPIXSCAN:
	SETC
	RETS
*CREATE TIME SLICE WHILE LOCKING OUT INTERRUPTS
PIXSCANG
	MMTM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13
	MMTM	SP,B0,B1
	PUSHST
	DINT
	MOVE	*A0(ODMAIMG),A9,L		;GET IMAGE 0 POINTER
	MOVE	*A8(ODMAIMG),A7,L		;GET IMAGE 1 POINTER
	MOVE	*A0(ODMAXY),A3,L		;SET UP OBJECT BOX ULX,ULY
	MOVE	*A8(ODMAXY),A4,L
	MOVE	*A0(ODMAFLG),A6
	MOVE 	A6,B0				;FLAGS FOR OBJECT 0
	MOVE	*A8(ODMAFLG),A6
	MOVE	A6,B1				;FLAGS OBJECT 1
	POPST

	MOVE	*A9(ISIZE),A5,L
	MOVE	*A7(ISIZE),A6,L
	ADDXY	A3,A5				;NOW WE HAVE LRX0 AND LRY0
	ADDXY	A4,A6				;LRX1,LRY1
	CMPXY	A6,A3		;COMPARE (LRX1,LRY1) TO (TLX0,TLY0)
	JRXGE	CSFAIL
	JRYGE	CSFAIL
	CMPXY	A4,A5		;COMPARE (TLX1,TLY1) TO (LRX0,LRY0) 
	JRXLE	CSFAIL
	JRYLE	CSFAIL
	MOVE	A0,A10
*
*BOX HAS INTERSECTED
*PERFORM PIXEL SCAN
*A3=TLX0,TLY0
*A4=TLX1,TLY1
*A5=LRX0,LRX1
*A6=LRX1,LRY1
*A7=IMAGE 1 DATA HEADER POINTER
*A8=IMAGE 1 OBJECT POINTER
*A9=IMAGE 0 DATA HEADER POINTER
*A10=IMAGE 0 OBJECT POINTER
*B0=FLAGS OBJECT 0
*B1=FLAGS OBJECT 1
*
*CALCULATE XOFF0,XOFF1,XSCAN
*A11=XOFF0
*A12=XOFF1
*A13=XSCAN
*
	MOVE	A3,A2	
	SUBXY	A4,A2
	SEXT	A2,W
	JRNN    CLX1    
	NEG	A2
	MOVE	A2,A11	;OBJECT 1 TO THE RIGHT
	CLR	A12
	MOVE	A4,A13	;RIGHTMOST TOP LEFT
	JRUC	CLX2
CLX1:			;OBJECT 0 TO THE RIGHT
	MOVE	A2,A12
	CLR	A11
	MOVE	A3,A13	;RIGHTMOST TOP LEFT
CLX2:
	CMPXY	A5,A6	;FIND LEFTMOST LOWER RIGHT
	JRXN	CLX3
	SUBXY	A5,A13
	JRUC	CLX4
CLX3:
	SUBXY	A6,A13
CLX4:
	SEXT	A13,W
	NEG	A13

*CALCULATE YOFF0,YOFF1,YSCAN
*A3=TLX0,TLY0
*A4=TLX1,TLY1
*A5=LRX0,LRX1
*A6=LRX1,LRY1
*COMPUTE:
*A2=YOFF0
*A3=YOFF1
*A14=YSCAN
	SRA	16,A3	;BLOW AWAY X COORDS
	SRA	16,A4
	SRA	16,A5
	SRA	16,A6
	MOVE	A3,A2
	SUB	A4,A2
	JRNN    CLY1    
	NEG	A2
	CLR	A3	;OBJECT 1 TO THE RIGHT
	MOVE	A4,A14	;RIGHTMOST TOP LEFT
	JRUC	CLY2
CLY1:			;OBJECT 0 TO THE RIGHT
	MOVE	A3,A14
	MOVE	A2,A3
	CLR	A2
CLY2:
	CMP	A5,A6	;FIND LEFTMOST LOWER RIGHT
	JRN	CLY3
	SUB	A5,A14
	JRUC	CLY4
CLY3:
	SUB	A6,A14
CLY4:
	NEG	A14
*
*A2=YOFF0
*A3=YOFF1
*A4=IMAGE SOURCE ADDRESS TEMP
*A5=WIDTH TEMP
*A7=IMAGE 1 DATA HEADER POINTER
*A8=IMAGE 1 OBJECT POINTER
*A9=IMAGE 0 DATA HEADER POINTER
*A10=IMAGE 0 OBJECT POINTER
*A11=XOFF0
*A12=XOFF1
*A13=XSCAN
*A14=YSCAN
*
*CALCULATE OBJECT 0 STARTAD, HINC0, VINC0
*
	MOVE	*A9(ISAG),A4,L	;GET IMAGE SOURCE ADDRESS
	MOVE	*A9(ISIZE),A5,W
	ADDK	3,A5		;CORRECT ERRONEOUS WIDTH (THANX, WARREN)
	ANDI	>FFFFFFFC,A5
	
*CHECK OBJECT 0 FLIPS
*
	BTST	B_FLIPH,B0
	JRNE	CL0HF		;HORIZONTAL FLIP
	BTST	B_FLIPV,B0
	JRNE	CL0VF		;VERTICAL FLIP
*	
*NO FLIP CASE
*A2=HINC0=8 (BYTE AT A TIME)
*A5=VINC0=W0-XSCAN
*A4=STARTAD0=IMAGEAD0+(YOFF0 X W0) + XOFF
*
	MOVE	A5,A1		;GET WIDTH
	MPYU	A2,A1		;MULT WIDTH X YOFF
	ADD	A11,A1		;ADD IN X OFFSET
	SLL	3,A1		;CORRECT FOR BYTE ADDRESSING
	ADD	A1,A4		;ADD TO SOURCE ADDRESS
	MOVK	8,A2		;HINC0
	SUB	A13,A5		;VINC0=W0-XSCAN
	SLL	3,A5		;CORRECT FOR PIXEL ADDRESSING
	JRUC	CLOBJ1
*
*HORIZONTAL FLIP
*
*A2=HINC0=-8
*A5=VINC0=W0+XSCAN
*A4=STARTAD0=IMAGEAD0+(YOFF0 X W0) + W0-XOFF0-1
CL0HF	BTST	B_FLIPV,B0	;VERT FLIP TOO?
	JRNE	CL0HVF		;HORIZ AND VERT FLIP
	MOVE	A5,A1		;GET WIDTH
	MPYU	A2,A1		;MULT WIDTH X Y OFFSET
	ADD	A5,A1		;ADD IN WIDTH
	SUB	A11,A1		;SUBTRACT X OFFSET
	DEC	A1		;-1 MORE
	SLL	3,A1		;CORRECT FOR BYTE ADDRESSING
	ADD	A1,A4
	MOVI	-8,A2		;HINC0
	ADD	A13,A5		;VINC0=W0+XSCAN
	SLL	3,A5		;CORRECT FOR PIXEL ADDRESSING
	JRUC	CLOBJ1
*
*VERTICAL FLIP
*
*A2=HINC0=8
*A5=VINC0=-W0-XSCAN
*A4=STARTAD0=IMAGEAD0+(H0-YOFF0-1)W0+XOFF0
CL0VF:	MOVE 	*A9(ISIZE+>10),A1	;GET HEIGHT
	SUB	A2,A1			;SUBTRACT YOFF0
	DEC	A1
	MPYU	A5,A1		;MULTIPLY BY WIDTH
	ADD	A11,A1		;ADD IN X OFFSET
	SLL	3,A1		;CORRECT FOR PIXEL ADDRESSING
	ADD	A1,A4		;ADD TO SOURCE ADDRESS
	NEG	A5		;-W0
	SUB	A13,A5		;-XSCAN
	SLL	3,A5		;CORRECT FOR PIXEL ADDRESSING
	MOVK	8,A2		;HINC0
	JRUC	CLOBJ1
*
*VERTICAL AND HORIZONTAL FLIP
*
*A2=HINC0=-8
*A5=VINC0=-W0-XSCAN
*A4=STARTAD0=(H0-YOFF0-1)W0+W0-XOFF0-1
CL0HVF:	MOVE	*A9(ISIZE+>10),A1	;GET HEIGHT
	SUB	A2,A1			;SUBTRACT YOFF0
	DEC	A1
	MPYU	A5,A1		;MULTIPLY BY WIDTH
	ADD	A5,A1		;ADD IN WIDTH (W0)
	SUB	A11,A1		;SUBTRACT XOFF0
	DEC	A1
	SLL	3,A1		;CORRECT FOR PIXEL ADDRESSING
	ADD	A1,A4		;ADD TO SOURCE ADDRESS
	NEG	A5		;-W0
	ADD	A13,A5		;+XSCAN
	SLL	3,A5		;CORRECT FOR PIXEL ADDRESSING
	MOVI	-8,A2		;HINC0
*
*CALCULATE OBJECT 1 STARTAD, HJUMP, VJUMP		
*	
*
*A2=HINC0
*A3=YOFF1, HINC1
*A4=STARTAD0
*A5=VINC0
*A6=STARTAD1
*A7=IMAGE 1 DATA HEADER POINTER
*A8=IMAGE 1 OBJECT POINTER
*A9=IMAGE 0 DATA HEADER POINTER
*A10=IMAGE 0 OBJECT POINTER
*A11=W1, VINC1
*A12=XOFF1
*A13=XSCAN
*A14=YSCAN
CLOBJ1:
	MOVE	*A7(ISAG),A6,L	;GET IMAGE SOURCE ADDRESS
	MOVE	*A7(ISIZE),A11
	ADDK	3,A11		;CORRECT ERRONEOUS WIDTH (THANX, WARREN)
	ANDI	>FFFFFFFC,A11
*	
*CHECK OBJECT 1 FLIPS
*
	BTST	B_FLIPH,B1
	JRNE	CL1HF		;HORIZONTAL FLIP
	BTST	B_FLIPV,B1
	JRNE	CL1VF		;VERTICAL FLIP
*	
*NO FLIP CASE
*A3=HINC1=8 (BYTE AT A TIME)
*A11=VINC1=W1-XSCAN
*A6=STARTAD1=IMAGEAD1+(YOFF1 X W1) + XOFF1
*
	MOVE	A11,A1		;GET WIDTH
	MPYU	A3,A1		;MULT WIDTH X YOFF
	ADD	A12,A1		;ADD IN X OFFSET
	SLL	3,A1		;CORRECT FOR BYTE ADDRESSING
	ADD	A1,A6		;ADD TO SOURCE ADDRESS
	MOVK	8,A3		;HINC1
	SUB	A13,A11		;VINC1=W1-XSCAN
	SLL	3,A11		;CORRECT FOR PIXEL ADDRESSING
	JRUC	CSH
*
*HORIZONTAL FLIP
*
*A3=HINC1=-8
*A11=VINC1=W1+XSCAN
*A6=STARTAD1=IMAGEAD1+(YOFF1 X W1) + W1-XOFF1-1
CL1HF	BTST	B_FLIPV,B1	;VERT FLIP TOO?
	JRNE	CL1HVF		;HORIZ AND VERT FLIP
	MOVE	A11,A1		;GET WIDTH
	MPYU	A3,A1		;MULT WIDTH X Y OFFSET
	ADD	A11,A1		;ADD IN WIDTH
	SUB	A12,A1		;SUBTRACT X OFFSET
	DEC	A1		;-1 MORE
	SLL	3,A1		;CORRECT FOR BYTE ADDRESSING
	ADD	A1,A6
	MOVI	-8,A3		;HINC1
	ADD	A13,A11		;VINC1=W1+XSCAN
	SLL	3,A11		;CORRECT FOR PIXEL ADDRESSING
	JRUC	CSH
*
*VERTICAL FLIP
*
*A3=HINC1=8
*A11=VINC1=-W1-XSCAN
*A6=STARTAD1=IMAGEAD1+(H1-YOFF1-1)W1+XOFF1
CL1VF:	MOVE 	*A7(ISIZE+>10),A1	;GET HEIGHT
	SUB	A3,A1			;SUBTRACT YOFF1
	DEC	A1
	MPYU	A11,A1		;MULTIPLY BY WIDTH
	ADD	A12,A1		;ADD IN X OFFSET
	SLL	3,A1		;CORRECT FOR PIXEL ADDRESSING
	ADD	A1,A6		;ADD TO SOURCE ADDRESS
	NEG	A11		;-W1
	SUB	A13,A11		;-XSCAN
	SLL	3,A11		;CORRECT FOR PIXEL ADDRESSING
	MOVK	8,A3		;HINC1
	JRUC	CSH
*
*VERTICAL AND HORIZONTAL FLIP
*
*A3=HINC1=-8
*A11=VINC1=-W1-XSCAN
*A6=STARTAD1=(H1-YOFF1-1)W1+W1-XOFF1-1
CL1HVF:	MOVE	*A7(ISIZE+>10),A1	;GET HEIGHT
	SUB	A3,A1			;SUBTRACT YOFF1
	DEC	A1
	MPYU	A11,A1		;MULTIPLY BY WIDTH
	ADD	A11,A1		;ADD IN WIDTH (W1)
	SUB	A12,A1		;SUBTRACT XOFF1
	DEC	A1
	SLL	3,A1		;CORRECT FOR PIXEL ADDRESSING
	ADD	A1,A6		;ADD TO SOURCE ADDRESS
	NEG	A11		;-W1
	ADD	A13,A11		;+XSCAN
	SLL	3,A11		;CORRECT FOR PIXEL ADDRESSING
	MOVI	-8,A3		;HINC1
*
*SCAN COLLISION BOX AREA
*
*A0= TEMP DATA HOLDER
*A1= WIDTH COUNTER XSCAN
*A2=H INCREMENT IMAGE 0
*A3=H INCREMENT IMAGE 1
*A4=INDEX TO IMAGE 0
*A5=V INCREMENT IMAGE 0
*A6=INDEX TO IMAGE 1
*A7=IMAGE 1 DATA HEADER POINTER
*A8=IMAGE 1 OBJECT POINTER
*A9=IMAGE 0 DATA HEADER POINTER
*A10=IMAGE 0 OBJECT POINTER
*A11=V INCREMENT IMAGE 1
*A13=WIDTH COUNT XSCAN
*A14=HEIGHT COUNT YSCAN
*
CSH:
	CMPI	>80,A14	  	;NO SCAN IF XSCAN, YSCAN VALUES OUT OF RANGE
	JRHS	CSFAIL
	CMPI	>80,A13
	JRHS	CSFAIL
	PUSHST
	DINT			;STOP DMA FUCK
	MOVE	@INTENB,A0,W
	ANDNI	X1E,A0
	MOVE	A0,@INTENB,W
	POPST
CSH0:	
	MOVE	@DMACTRL,A0,W	;DMA BUSY?
	JRN	CSH0		;YES, WAIT
CSH1:
	MOVE	A13,A1		;LOAD LINE COUNTDOWN HORIZ COUNTER
CSHL:	MOVB	*A4,A0		;CHECK IMAGE 0 CORRESPONDING NON ZEROES
	JREQ	CSNXH
	MOVB	*A6,A0		;CHECK IMAGE 1
	JRNE	CSHIT		;GOT A HIT
CSNXH:
	ADD	A2,A4		;ADD HORIZ INCREMENTS HINC0
	ADD	A3,A6		;HINC1
	DSJS	A1,CSHL		;LOOP UNTIL HOR LINE DONE

	ADD	A5,A4		;ADD VERT INCREMENTS
	ADD	A11,A6
	DSJS	A14,CSH1		;LOOP UNTIL VERT DONE
CSFAIL:
	MOVE	B13,B13
	JRZ	CSFNODMA	;DON'T REACTIVATE DMA INTS
	PUSHST
	DINT
	MOVE	@INTENB,A0,W
	ORI	X1E,A0
	MOVE	A0,@INTENB,W
	POPST
****	EINT
CSFNODMA
	CLRC
	JRUC	CSHXXX
CSHIT: 
	MOVE	B13,B13
	JRZ	CSFLAGS		;DON'T REACTIVATE DMA INTS
	PUSHST
	DINT
	MOVE	@INTENB,A0,W
	ORI	X1E,A0
	MOVE	A0,@INTENB,W
	POPST
****	EINT
CSFLAGS
	SETC
CSHXXX:
	MMFM	SP,B0,B1
	MMFM	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13
	RETS

	.ENDIF

	.END
