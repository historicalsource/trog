	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGUTIL.ASM'
	.TITLE	" <<< T R O G ---- GENERAL PURPOSE SUBROUTINES >>>"
	.WIDTH	132
	.OPTION	B,D,L
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

	.REF	SUPPLST,SUPPLEND,CLRBGND

	.EVEN
	.TEXT

*
*SHVELCPY - COPY VELOCITIES TO SHADOW (IF ANY)
*A8=OBJECT
*
SHVELCPY: 
	MMTM	SP,A0,A1
	MOVE	*A8(OSHAD),A0,L
	JREQ	SHVLCPX
	MOVE	*A8(OXVEL),*A0(OXVEL),L
	MOVE	*A8(OZVEL),A1,L
	MOVE	A1,*A0(OZVEL),L
	MOVE	A1,*A0(OYVEL),L
SHVLCPX:
	MMFM	SP,A0,A1
	RETS

*
*SHVELFLP - COPY SHADOW VELOCITY AND FLIP HIM
*A8=OBJECT
*A3=OXVEL
SHVELFLP:
	CALLR	SHVELCPY
	MOVE	*A8(OXVEL+>10),A14,W		;TEST X VELOCITY
*FLIPDUDE
*A8=OBJECT, N=SIGN OF XVEL
FLP:
	JAN	YFLP
	JAUC	NOYFLP

**************************************************************************
*                                                                        *
* Z POSITIONING ROUTINES						 *
*                                                                        *
**************************************************************************

*
*XZCHK
*CALLING PARAMETERS:
*A8=OBJECT SEEKING
*A0=OBJECT SEEKED
*A5=X RANGE
*A6=Z RANGE
*RETURNS:
*CARRY SET IF HE IS CLOSE ENOUGH
*A1=DELTA X
*A2=DELTA Z
*A3=ABS DELTA X
*A4=ABS	DELTA Z
XZCHK:
	MOVE	A0,A4
	CALLA	GETANIX			;GET X ANIMATION POINT
	MOVE	A0,A3
	SWAP	A4,A8
	CALLA	GETANIX
	MOVE	A0,A1
	MOVE	A8,A0
	MOVE	A4,A8
	MOVE	*A8(OZPOS),A4,W	       
	MOVE	*A0(OZPOS),A2,W
	SUB	A4,A2
	SUB	A3,A1
	MOVE	A1,A3
	MOVE	A2,A4
	ABS	A3
	ABS	A4
	CMP	A5,A3
	JRNC	XZCHKX
	CMP	A6,A4
XZCHKX:
	RETS
	
**************************************************************************
*                                                                        *
* CLRPDATA - CLEAR THE PDATA AREA OF A PROCESS BLOCK			 *
* A13 = PTR TO PROCESS BLOCK						 *
*                                                                        *
**************************************************************************
CLRPDATA
	MMTM	SP,A1,A6,A14
	MOVE	A13,A14
	CLR	A1
	ADDI	PDATA,A14
	MOVI	(PSDATA-PDATA)/16,A6
CLRSHL
	SRL	1,A6
	JRNC	CLRPDL
	MOVE	A1,*A14+,W	;STUFF THE ODD WORD	
CLRPDL
	MOVE	A1,*A14+,L		
	DSJS	A6,CLRPDL
	MMFM	SP,A1,A6,A14
	RETS

**************************************************************************
*                                                                        *
* DFRMGRND - RETURNS THE DISTANCE FROM THE BOTTOM OF			 *
* 		   AN OBJECT TO THE "GROUND."				 *
* A8 = OBJECT BLOCK							 *
* RETURN(S)								 *
* A1 = DISTANCE FROM GROUND (16 BITS)					 *
* STATUS BITS SET ACCORDING TO THE SIGN OF A1				 *
* NOTE: MAX ACCEPTABLE Y = +32K, MIN ACCEPTABLE Y = -32K		 *
*                                                                        *
**************************************************************************
DFRMGRND
	PUSH	A2
	move	*A8(OYPOS),A1,W
	move	*A8(OSIZEY),A2,W
	add	A1,A2			;A2 = BOTTOM Y
	move	*A8(OZPOS),A1,W
	sub	A2,A1
	mmfm	SP,A2
	RETS

**************************************************************************
*                                                                        *
* MIDPOINT - RETURN THE MIDPOINT BETWEEN TO POINTS			 *
* A0 = [Y,X] POINT 0							 *
* A1 = [Y,X] POINT 1							 *
* RETURNS								 *
* A0 = [Y,X] MIDPOINT							 *
*                                                                        *
**************************************************************************
MIDPOINT
	MMTM	SP,A1,A2
	SUBXY	A0,A1
	MOVY	A1,A2
	SRA	17,A2
	SLL	16,A2
	SEXT	A1
	SRA	1,A1
	MOVY	A2,A1
	ADDXY	A1,A0
	MMFM	SP,A1,A2
	RETS
	
**************************************************************************
*                                                                        *
* GET BOTTOM Y OF AN OBJECT						 *
* A8 = OBJECT BLOCK PTR							 *
* RETURN(S)								 *
* A1 = 16 BIT BOTTOM Y IN LSW						 *
* STATUS SET ACCORDING TO THE BOTTOM Y					 *
*NOTE: MAKE SURE OBLOCK IS INIT'D WITH GSAGOF BEFORE CALLING		 *
*                                                                        *
**************************************************************************
GETBOTY
	PUSH	A2
	MOVE	*A8(OYPOS),A1,W		;GET Y POSITION
	MOVE	*A8(OSIZEY),A2,W	;GET THE CURRENT SIZE
	ADD	A2,A1			;A1 = BOTTOM Y
	MMFM	SP,A2
	RETS

**************************************************************************
*                                                                        *
* GETCPNT - RETURNS THE CENTER XY POSITION OF A GIVEN IMAGE		 *
* A8 = IMAGE OBLOCK							 *
* RETURN(S)								 *
* A1 = CENTER Y:CENTER X						 *
*                                                                        *
**************************************************************************
GETCPNT	MOVE	A0,-*SP,L
	MOVE	*A8(OYPOS),A0,W
	SLL	16,A0
	MOVE	*A8(OXPOS),A1,W
	MOVX	A1,A0
	MOVE	*A8(OSIZE),A1,L
	CALLR	GETCENT
	SLL	16,A0
	MOVY	A0,A1
	MOVE	*SP+,A0,L
	RETS

**************************************************************************
*								         *
* GET_BOTTOM_MID - GET THE MID POINT OF THE BOTTOM LINE OF AN IMAGE	 *
* A8 = PTR TO IMAGE							 *
* RETURNS:								 *
* A1 = [Y,X] BOTTOM LINE MIDPOINT					 *
*								         *
**************************************************************************
GET_BOTTOM_MID:
	PUSH	A0
	CALLR	GETBOTY
	MOVE	A1,A0
	CALLR	GETCPNT
	SLL	16,A0
	MOVY	A0,A1			;GET THE BOTTOM MIDPOINT
	PULL	A0
	RETS

**************************************************************************
*								         *
* GET_INIT_CPNT - GET THE CENTER POINT OF AN OBJECT STORED WITHIN AN	 *
* 	INITIALIZATION TABLE WITH RESPECT TO ITS CURRENT ANIMATION	 *
* 	POINT.								 *
* A8 = PTR TO OBJECT							 *
* RETURNS:								 *
* A1 = [Y,X] CENTER POINT						 *
*								         *
**************************************************************************
GET_INIT_CPNT:
	MMTM	SP,A0,A2,A3,A5,A6
	CALLA	GETANIXY		;OBJECT ANI PNT, A2=Y A3=X
	SRL	16,A3
	MOVX	A3,A2			;PACK [Y,X] INTO A2
	MOVE	*A4(INITIMG),A5,L	;AND NOW THE IMAGE PTR
	MOVE	*A5(IANIOFF),A6,L
	SUBXY	A6,A2			;FIND CORRECT UPPER LEFT CORNER
	MOVE	A2,A0
	MOVE	*A5(ISIZE),A1,L
	CALLA	GETCENT			;GET THE CENTER PNT OF THIS BOX
	SLL	16,A0
	MOVY	A0,A1			;PACK IT UP IN A1
	MMFM	SP,A0,A2,A3,A5,A6
	RETS

**************************************************************************
*                                                                        *
* GETCENT - RETURNS THE CENTER POINT OF A BOX		      		 *
* A0 = UPPER LEFT Y:UPPER LEFT X					 *
* A1 = Y_SIZE:X_SIZE   							 *
* RETURN(S)								 *
* A0 = CENTER Y(LSW)							 *
* A1 = CENTER X(LSW)							 *
*                                                                        *
**************************************************************************
GETCENT	MOVE	A2,-*SP,L
	MOVY	A1,A2
	SRL	17,A2		;YSIZE/2
	SLL	16,A2		;BACK TO Y HALF
	SLL	16,A1		;CLEAR Y
	SRL	17,A1		;XSIZE/2
	MOVY	A2,A1
	ADDXY	A1,A0		;OFFSET TO CENTER
	CLR	A1
	MOVX	A0,A1		;RETURN THESE IN USEFUL POSITIONS
	SRL	16,A0
	MOVE	*SP+,A2,L
	RETS

**************************************************************************
*                                                                        *
* SLINEVEL - GET THE X & Y VELOCITIES TO MAKE AN OBJECT TRAVEL		 *
* 	   FROM PNT. A TO PNT. B ALONG THE SHORTEST PATH.		 *
* A2 = PNT. A [Y,X] POSITION						 *
* A3 = PNT. B [Y,X] POSITION						 *
* A4 = DURATION(# OF TICKS TO GET FROM A TO B)				 *
* RETURNS:								 *
* A1 = X VEL (32 BITS)							 *
* A2 = Y VEL (32 BITS)							 *
* NOTE: DON'T CALL WITH THE A=B, IT'S A WAIST OF TIME AND UNDEFINED.	 *
*                                                                        *
**************************************************************************
SLINEVEL
	MMTM	SP,A3
	SUBXY	A2,A3		;GET THE DIFFERENCE
	MOVX	A3,A1		;A1 = X DISTANCE
	SRL	16,A3
	SLL	16,A3		;CLEAR OUT THE X PART
	DIVS	A4,A3		;A3 = Y VELOCITY(32 BITS)
	SLL	16,A1
	DIVS	A4,A1		;A1 = X VELOCITY(32 BITS)
	MOVE	A3,A2		;RETURN Y VEL HERE FOR CONSISTENCY
	MMFM	SP,A3
	RETS

**************************************************************************
*                                                                        *
* WHICHSID - FIND WHICH SIDE (LEFT OR RIGHT) OF THE OBJECT IN A8,	 *
* 	   OBJECT IN A0 EXISTS ON, BASED ON THE CENTER LINES.		 *
* A0 = OBJECT IN ?							 *
* A8 = OBJECT TO CHECK AGAINST						 *
* RETURNS:								 *
* CARRY SET = RIGHT OF OBJECT IN A8					 *
* CARRY CLR = LEFT OR ON TOP OF OBJECT IN A8				 *
*                                                                        *
**************************************************************************
WHICHSID
	MMTM	SP,A1,A2,A8
	CALLR	GETCPNT		;GET CENTER POINT OF A8 OBJECT
	CLR	A2
	MOVX	A1,A2
	MOVE	A0,A8
	CALLR	GETCPNT		;GET CENTER POINT OF A0 OBJECT
	ZEXT	A1
	CMP	A2,A1		
	JRHS	WHICHR
	CLRC
	MMFM	SP,A1,A2,A8
	RETS
WHICHR
	SETC	
	MMFM	SP,A1,A2,A8
	RETS

**************************************************************************
*                                                                        *
* ABOVBELO - FIND WHICH SIDE (ABOVE OR BELOW) OF THE OBJECT IN A8,	 *
* 	   OBJECT IN A0 EXISTS ON, BASED ON THE CENTER LINES.		 *
* A0 = OBJECT IN ?							 *
* A8 = OBJECT TO CHECK AGAINST						 *
* RETURNS:								 *
* CARRY SET = BELOW OBJECT IN A8					 *
* CARRY CLR = ABOVE OF OBJECT IN A8					 *
*                                                                        *
**************************************************************************
ABOVBELO:
	MMTM	SP,A1,A2,A8
	CALLR	GETCPNT		;GET CENTER POINT OF A8 OBJECT
	MOVY	A1,A2
	SRL	16,A2
	MOVE	A0,A8
	CALLR	GETCPNT		;GET CENTER POINT OF A0 OBJECT
	SRL	16,A1
	CMP	A2,A1		
	JRHS	ABELOW
	CLRC
	MMFM	SP,A1,A2,A8
	RETS
ABELOW:
	SETC	
	MMFM	SP,A1,A2,A8
	RETS

**************************************************************************
*								         *
* CK_OBJ_CENT - DETERMINE IF CENTER POINTS OF TWO OBJECTS ARE CLOSE.	 *
* A0 = ONE OBJECT							 *
* A8 = THE OTHER OBJECT							 *
* RETURNS:								 *
* 	NC = NOT EVEN CLOSE						 *
* 	 C = CLOSE							 *
*								         *
**************************************************************************
CK_OBJ_CENT:
	MMTM	SP,A1,A2,A3,A8
	CALLR	GETCPNT			;CENTER POINT OF FIRST OBJECT
	MOVE	A1,A3
	MOVE	A0,A8
	CALLR	GETCPNT			;AND CENTER POINT OF THE SECOND
	MOVI	[8,8],A2		;FIX THE RANGE	
	CALLR	PNT_IN_RANGE
	MMFM	SP,A1,A2,A3,A8
	RETS

**************************************************************************
*								         *
* CK_BOTTOM_CENT - DETERMINE IF BOTTOM MID POINT OF ONE OBJECT IS	 *
*		CLOSE TO THE CENTER OF ANOTHER OBJECT.			 *
* A0 = ONE OBJECT							 *
* A8 = THE OTHER OBJECT							 *
* RETURNS:								 *
* 	NC = NOT EVEN CLOSE						 *
* 	 C = CLOSE							 *
*								         *
**************************************************************************
CK_BOTTOM_CENT:
	MMTM	SP,A0,A1,A2,A3,A8
	CALLR	GETCPNT			;GET THE CENTER POINT
	MOVE	A1,A3
	MOVE	A0,A8
	CALLR	GETBOTY
	MOVE	A1,A0
	CALLR	GETCPNT
	SLL	16,A0
	MOVY	A0,A1			;GET THE BOTTOM MIDPOINT
	MOVI	[6,6],A2		;FIX THE RANGE	
	CALLR	PNT_IN_RANGE
	MMFM	SP,A0,A1,A2,A3,A8
	RETS

**************************************************************************
*                                                                        *
* PNT_IN_RANGE - SEE IF ONE POINT IS IN A GIVEN [Y,X] RANGE OF ANOTHER	 *
* 	POINT.								 *
* A1 = [Y,X] POINT TO CHECK						 *
* A2 = [Y RANGE,X RANGE]						 *
* A3 = [Y,X] CENTER POINT OF RANGE					 *
* RETURNS:								 *
* 	NC = NOT IN RANGE						 *
* 	 C = IN RANGE							 *
*                                                                        *
**************************************************************************
PNT_IN_RANGE:
	MMTM	SP,A2,A3
	CALLR	MAKEBOX		;MAKE A RANGE AREA
	CALLR	PNTINBOX
	MMFM	SP,A2,A3
	RETS

**************************************************************************
*                                                                        *
* MAKEBOX - GIVEN THE CENTER POINT OF A BOX AND HALF THE LENGTH AND	 *
* 	WIDTH THIS FUNCTION WILL RETURN THE UL AND LR OF A BOX		 *
* A2 = [HALF HEIGHT,HALF WIDTH]						 *
* A3 = CENTER POINT OF BOX						 *
* RETURNS:								 *
* A2 = UPPER LEFT [Y,X] OF BOX						 *
* A3 = LOWER RIGHT [Y,X] OF BOX						 *
*                                                                        *
**************************************************************************
MAKEBOX:
	PUSH	A1
	MOVE	A3,A1
	ADDXY	A2,A3		;MAKE LOWER RIGHT
	SWAP	A1,A2
	SUBXY	A1,A2		;MAKE UPPER LEFT
	PULL	A1
	RETS

**************************************************************************
*                                                                        *
* PNTINBOX - SEE IF THE GIVEN POINT IS CONTAINED WITHIN OR ON THE	 *
* 		THE EDGE OF A GIVEN BOX.				 *
* A1 = [Y,X] POINT							 *
* A2 = UPPER LEFT [Y,X] OF BOX						 *
* A3 = LOWER RIGHT [Y,X] OF BOX						 *
* RETURNS:								 *
*        NC = NOT CONTAINED						 *
* 	  C = CONTAINED							 *
*                                                                        *
**************************************************************************
PNTINBOX:
	CMPXY	A2,A1
	JRXLT	PNTNOTINBOX
	JRYLT	PNTNOTINBOX
	CMPXY	A3,A1
	JRXGT	PNTNOTINBOX
	JRYGT	PNTNOTINBOX
	SETC
	RETS
PNTNOTINBOX:
	CLRC
	RETS
**************************************************************************
*								         *
* CHKRANGE - CHECK TO SEE IF AN UNSIGNED 32 BIT VALUE IS IN A		 *
* 		GIVEN RANGE (INCLUSIVE)					 *
* A1 = #								 *
* A2 = LOWER BOUND							 *
* A3 = UPPER BOUND							 *
* RETURN(S)								 *
* CARRY CLEAR (JxNC) = OUT OF RANGE					 *
* CARRY SET   (JxC)  = IN RANGE						 *
*								         *
**************************************************************************
CHKRANGE
	CMP	A2,A1			;CHECK LOWER BOUND
	JRLO	OUTOFRNG		;BR = # TOO LOW
	CMP	A3,A1
	JRHI	OUTOFRNG		;BR = # TOO HIGH

	SETC				;# IN RANGE, YEAH!
	RETS
OUTOFRNG
	CLRC
	RETS

**************************************************************************
*                                                                        *
* ALIGNOBJ - ALIGN OBJECT FROM PTA. TO PTB.				 *
* A0 = POINT B [Y,X]							 *
* A1 = POINT A [Y,X]							 *
* A8 = PTR TO OBJECT							 *
*                                                                        *
**************************************************************************
ALIGNOBJ
	MMTM	SP,A0,A1,A2
	SUBXY	A1,A0
	MOVY	A0,A1
	SRA	16,A1		;ISOLATE THE Y COMPONENT
	SEXT	A0		;AND THE X
	MOVE	*A8(OXPOS),A2,W
	ADD	A0,A2
	SLL	16,A2	       	;ZERO ALL FRACTIONALS
	MOVE	A2,*A8(OXVAL),L
	MOVE	*A8(OYPOS),A2,W
	ADD	A1,A2
	SLL	16,A2	       	;ZERO ALL FRACTIONALS
	MOVE	A2,*A8(OYVAL),L
	MMFM	SP,A0,A1,A2
	RETS

**************************************************************************
*								         *
* CENTEROBJ - CENTER AN OBJECT ON A POINT.				 *
* A0 = POINT TO CENTER UPON						 *
* A8 = OBJECT								 *
*								         *
**************************************************************************
CENTEROBJ:
	PUSH	A1
	CALLR	GETCPNT
	CALLR	ALIGNOBJ
	PULL	A1
	RETS

**************************************************************************
*                                                                        *
* GETSCRRX - THE THE WORLD X COORDINATE OF THE SCREEN RIGHT END		 *
* RETURNS								 *
* A0 = SCREEN RIGHT X, 32 BITS						 *
*                                                                        *
**************************************************************************
GETSCRRX
	PUSH	A2
	MOVE	@SCRNLR,A0,W
	MOVE	@WORLDTL,A2,W
	ADD	A2,A0			;GET SCREEN LOWER RT.
	SLL	16,A0
	PULL	A2
	RETS

**************************************************************************
*                                                                        *
* GET_ZMID - GET THE Z MIDPOINT OF AN OBJECT.				 *
* A8 = PTR TO OBJECT							 *
* RETURNS:								 *
* A0 = 32 BIT Z CENTER							 *
*                                                                        *
**************************************************************************
GET_ZMID
	MMTM	SP,A1,A2
	MOVE	*A8(OZSIZ),A2,L
	MOVY	A2,A1				;A1 = OZPLUS
	SRL	16,A1
	ZEXT	A2
	ADD	A1,A2				;A2 = TOTAL Z WIDTH
	SLL	15,A2				;DIVIDE FOR HALF
	SLL	16,A1
	MOVE	*A8(OZVAL),A0,L
	ADD	A1,A0				;GET TO THE EDGE
	SUB	A2,A0				;GO BACK TO MIDPOINT	
	MMFM	SP,A1,A2	
	RETS

**************************************************************************
*                                                                        *
* CLRWORLD - CLEAR ALL WORLD COORDINATES AND SCROLL VELOCITIES.		 *
*                                                                        *
**************************************************************************
CLRWORLD
	PUSH	A0
	CLR	A0
	MOVE	A0,@SCROLLX,L		;X SCROLL VALUE
	MOVE	A0,@SCROLLY,L		;Y SCROLL VALUE
	MOVE	A0,@WORLDTLX,L		;TOP LEFT X SCREEN COORD (WORLD)
	MOVE	A0,@WORLDTLY,L		;TOP LEFT Y SCREEN COORD (WORLD)
	MOVE	A0,@WORLDTL,L
	MOVE	A0,@BAK2TLY,L		;TOP LFT Y SLOW SCROLL BACKGROUND
	MOVE	A0,@BAK2TLX,L		;TOP LFT X SLOW SCROLL BACKGROUND
	MOVI	SCRNST,A0
	MOVE	A0,@SCRNTL,L
	MOVI	SCRNEND,A0
	MOVE	A0,@SCRNLR,L
	PULL	A0
	RETS

**************************************************************************
*                                                                        *
* GETSCRBY - THE THE WORLD Y COORDINATE OF THE SCREEN BOTTOM		 *
* RETURNS								 *
* A0 = SCREEN BOTTOM Y							 *
*                                                                        *
**************************************************************************
GETSCRBY
	PUSH	A2
	MOVE	@SCRNLR+16,A0,W
	MOVE	@WORLDTL+16,A2,W
	ADD	A2,A0			;GET SCREEN BOTTOM Y
	SLL	16,A0			;MAKE IT A 32 BIT VALUE
	PULL	A2
	RETS

**************************************************************************
*                                                                        *
* SET_ZPOS - SETUP OBJECTS Z POSITION					 *
*	    BASED ON OBJECTS BOTTOM Y POSITION				 *
* A0 = OBJECT BLOCK							 *
*                                                                        *
**************************************************************************
SET_ZPOS:
	MMTM	SP,A1,A8
	CALLR	GET_ZPOS
	SLL	16,A1
	MOVE	A0,A8
	CALLA	STORE_ZVAL
	MMFM	SP,A1,A8
	RETS

**************************************************************************
*                                                                        *
* SET_YFRMZ - SET THE OBJECTS Y POSITION ACCORDING TO IT'S CURRENT Z	 *
* A0 = OBJECT								 *
*                                                                        *
**************************************************************************
SET_YFRMZ
	MMTM	SP,A1,A2
	MOVE	*A0(OZVAL),A1,L
	MOVE	*A0(OSIZEY),A2,W
	SLL	16,A2
	SUB	A2,A1
	MOVE	A1,*A0(OYVAL),L
	MMFM	SP,A1,A2
	RETS

**************************************************************************
*                                                                        *
* SET_TZPOS - SET OBJECTS Z POS. BASED ON TOP Y POSITION		 *
* A0 = PTR TO OBJECT							 *
*                                                                        *
**************************************************************************
SET_TZPOS
	MMTM	SP,A1,A8
	MOVE	*A0(OYVAL),A1,L
	MOVE	A0,A8
	CALLA	STORE_ZVAL
	MMFM	SP,A1,A8
	RETS

**************************************************************************
*								         *
* SET_MZPOS - SET OBJECTS Z POS. BASED ON IT'S Y MIDPOINT		 *
* A0 = PTR TO OBJECT							 *
*								         *
**************************************************************************
SET_MZPOS
	MMTM	SP,A1,A2,A8
	MOVE	*A0(OYPOS),A1,W
	MOVE	*A0(OSIZEY),A2,W
	SRA	1,A2
	ADD	A2,A1
	SLL	16,A1
	MOVE	A0,A8
	CALLA	STORE_ZVAL
	MMFM	SP,A1,A2,A8
	RETS

**************************************************************************
*                                                                        *
* GET_ZPOS - GET AN OBJECTS Z POSITION.					 *
* A0 = OBJECT BLOCK PTR							 *
* RETURN(S)								 *
* A1 = Z POSITION							 *
*                                                                        *
**************************************************************************
GET_ZPOS
	PUSH	A8
	MOVE	A0,A8
	CALLR	GETBOTY
	PULL	A8
	RETS

**************************************************************************
*                                                                        *
* QBOXCK - TEST OBJECT CONTAINMENT WITHIN A BOX				 *
* A2 = BOX TOP LEFT [Y,X]						 *
* A3 = BOX BOTTOM RIGHT [Y,X]						 *
* A8 = PTR TO OBJECT							 *
* RETURNS								 *
* 	.EQ. = TOTALLY IN BOX						 *
* 	.NE. = TOUCHING OR EXCEEDING AN EDGE				 *
* A0 =	BIT 0 SET = TOUCHING TOP					 *
* 	BIT 1 SET = TOUCHING BOTTOM					 *
* 	BIT 2 SET = TOUCHING LEFT					 *
* 	BIT 3 SET = TOUCHING RIGHT					 *
*                                                                        *
**************************************************************************
QBOXCK
	MMTM	SP,A1,A2,A3,A4
	JRUC	QONSCRNG
*
*QINSCRN - QBOXCK USING THE CURRENT SCREEN BOUNDRIES
QINSCRN:
	MMTM	SP,A1,A2,A3,A4	
	MOVE	@SCRNTL,A2,L		;GET SCREEN TOP LEFT
	MOVE	@SCRNLR,A3,L		;GET SCREEN LOWER RT.
QONSCRNG
	CLR	A0			;RETURN INFO HERE
	MOVE	*A8(OYPOS),A4,W
	MOVE	*A8(OXPOS),A1,W
	SLL	16,A4
	MOVX	A1,A4	       		;GET TOP LEFT OF OBJECT
	MOVE	@WORLDTL,A1,L
	SUBXY	A1,A4			;SUBTRACT OUT WORLD BASE
	MOVE	*A8(OSIZE),A1,L
	ADDXY	A4,A1			;GET LOWER RT OF OBJECT

	CMPXY	A2,A4			;CHECK UPPER THE UPPER LEFT CORNER
	JRYGT	QONSCRL			;HASN'T PASSED THE TOP
	ORI	1,A0			;MARK THE TOP TOUCH
	CMPXY	A2,A4
QONSCRL
	JRXGT	QONSCRD			;LEFT O.K.
	ORI	4,A0			;MARK THE LEFT TOUCH	
QONSCRD
	CMPXY	A3,A1
	JRYLT	QONSCRR			;NO BOTTOM TOUCH
	ORI	2,A0			;TOUCHING BOTTOM
	CMPXY	A3,A1
QONSCRR
	JRXLT	QONSCRX			;RIGHT O.K.
	ORI	8,A0			;TOUCHING THE RIGHT EDGE
QONSCRX:
	MOVE	A0,A0
	MMFM	SP,A1,A2,A3,A4	
	RETS

**************************************************************************
*                                                                        *
* MYOINIT - INITIALIZE SUPPLEMENTAL OBJECT LIST HEADERS			 *
*                                                                        *
**************************************************************************
MYOINIT
	MMTM	SP,A0,A1,A2,A3,A4,A5
	CALLA	CLRBGND
	PUSHST
	CALLA	CLRPAL
	
	MOVE	@GAME_STATE,A0,W
	CMPI	INAMODE,A0
	JREQ	MO_DUX
	CMPI	INDIAG,A0
	JREQ	MO_DUX
	MOVI	GAMEFIX,A0
	JRUC	MO_PAL0
MO_DUX
	MOVI	DUXPAL,A0
MO_PAL0
	CALLA	GETFPAL			;GET THE FIXED FOREGROUND PALETTE
	MOVI	RED16,A0
	CALLA	GETFPAL			;FIX THE PLAYER 1 PALETTE
	MOVI	YELLOW16,A0
	CALLA	GETFPAL			;FIX THE PLAYER 2 PALETTE
	MOVI	BLUE16,A0
	CALLA	GETFPAL			;FIX THE PLAYER 3 PALETTE
	MOVI	PINK16,A0
	CALLA	GETFPAL			;FIX THE PLAYER 4 PALETTE
	MOVI	FIXED3,A0
	CALLA	GETFPAL			;FIX THE ROCK PALETTE

	MOVE	A0,@CURPAL,W		;STUFF THIS HERE FOR FIXED STUFF
	DINT
	MOVE	@INTENB,A0,W
	ANDNI	X1E,A0			;NO MORE DMA INTERRUPTS
	MOVE	A0,@INTENB,W
	POPST
	CLR	A0
	MOVE	A0,@GAMERASE
	CALLA	AUTOEOFF		;DISABLE AUTOERASE
	CALLR	DMAWAIT			;WAIT ON DMA
	MOVI	ERASECOL,A1
	SLL	16,A1			;CONSTANT:PALETTE
	MOVI	[2,511],A2		;HEIGHT:WIDTH
	MOVI	[510,0],A3		;DAG
	MOVI	2000000H,A4		;SAG
	MOVI	DMAREGS,A0
	MMTM	A0,A1,A2,A3,A4		;STORE TO LAST 2 LINES OF BITMAP
	CLR	A5	 		;STUFF OFFSET
	MOVE	A5,-*A0,W
	MOVI	DMACAL,A5		;CONTROL &
	MOVE	A5,-*A0,W		;GO!

*INITIALIZE SUPPLEMENTAL LIST HEADERS
	MOVI	SUPPLST,A1		;GET THE SUPPLEMENTAL LIST AREA
	CLR	A0
MYOINITS:
	MOVE	A0,*A1+,L
	CMPI	SUPPLEND,A1
	JRNE	MYOINITS

	MMFM	SP,A0,A1,A2,A3,A4,A5
	JAUC	OINIT

**************************************************************************
*                                                                        *
* RANDOM - GENERATE A RANDOM NUMBER					 *
* RETURNS:								 *
* A0 = 32 BIT RANDOM #							 *
*                                                                        *
**************************************************************************
RANDOM:	PUSH	A1
	MOVE	@RAND,A0,L
	SLA	1,A0
	JRV	RND2
	ORI	2,A0
RND2:	MOVE	A0,@RAND,L
	CLR	A1
	ADDC	A1,A0	;GET LAST BIT BACK TO MAKE 32
	MOVE	@HCOUNT,A1
	RL	A1,A0	;RANDOM ROTATION
	MOVE	A0,A0	;SET STATUS BITS
	MMFM	SP,A1
	RETS	

**************************************************************************
*                                                                        *
* RANDU - GENERATE A UNIFORMLY DISTRIBUTED RANDOM # BETWEEN 1 AND [A0]	 *
* A0 = RANGE INPUT							 *
* RETURNS:								 *
* A0 = RANDOM #								 *
*                                                                        *
**************************************************************************
RANDU:	PUSH	A1
	MOVE	A0,A1
	CALLR	RANDOM
	MPYU	A1,A0
	INC	A0
	MMFM	SP,A1
	RETS		
*
*GET SIGNED RANDOM # IN RANGE +/- A0
*CALLING PARAMETERS: A0
*RETURNS A0
*
SRAND:
	MMTM	SP,A1
	MOVE	A0,A1
	SLL	1,A0
	CALLA	RANDU
	SUB	A1,A0
	MMFM	SP,A1
	RETS
**************************************************************************
*                                                                        *
* RANGRAND - GENERATE A RANDOM NUMBER IN A GIVEN RANGE.			 *
* B0 = LOWER BOUND							 *
* B1 = UPPER BOUND							 *
* RETURNS								 *
* A0 = RANDOM #								 *
*                                                                        *
**************************************************************************
RANGRAND
	PUSH	A1
	PUSH	B1
	SUB	B0,B1		;NORMALIZE THE RANGE
	MOVE	B1,A0		;SET RANGE FOR RANDU
	CALLR	RANDU
	MOVE	B0,A1
	ADD	A1,A0
	PULL	B1
	PULL	A1
	RETS

*
*RANDPER - RANDOM % ROUTINE
*CALLING PARAMETERS:
*A0=PROBABILITY OF EVENT (0-1000) P(A0=1000) = 1; P(A0=1) = 1/1000.
*RETURNS CS IF PROBABILITY IS TRUE, CC FOR FALSE
*RETURNS A0 = ACTUAL RANDOM # 0-999
RANDPER:
	MMTM	SP,A1,A2
	MOVE	A0,A2
	CALLA	RANDOM
	MOVI	1000,A1
	MPYU	A1,A0
	CMP	A2,A0
	MMFM	SP,A1,A2
	RETS		

**************************************************************************
*                                                                        *
* FILLAREA - FILL A GIVEN SQUARE AREA ON THE SCREEN WITH A COLOR	 *
* A1 = [COLOR,PALETTE]							 *
* A3 = DAG OF AREA [YPOS,XPOS]						 *
* A4 = [Y,X] SIZE OF AREA						 *
*                                                                        *
**************************************************************************
FILLAREA
	MMTM	SP,A1,A2,A4,A5
	JRUC	AREACON
**************************************************************************
*                                                                        *
* BLNKAREA - BLANK A GIVEN SQUARE AREA ON THE SCREEN			 *
* A3 = DAG OF AREA [YPOS,XPOS]						 *
* A4 = [Y,X] SIZE OF AREA						 *
*                                                                        *
**************************************************************************
BLNKAREA
	MMTM	SP,A1,A2,A4,A5
	CLR	A1			;CONSTANT 0:PALETTE 0
AREACON
	MOVE	A4,A2
	MOVI	2000000H,A4		;SOMEWHERE IN IMAGE ROM
	MOVI	DMACAL,A5
	CALLR	DMAN
	MMFM	SP,A1,A2,A4,A5
	RETS

**************************************************************************
*                                                                        *
* OBJECT VELOCITY STOP ROUTINES						 *
*                                                                        *
**************************************************************************

**************************************************************************
*								         *
* STOPPED - DETERMINE IF A GIVEN OBJECT IS CURRENTLY STOPPED.		 *
* A8 = PTR TO OBJECT							 *
* RETURNS:								 *
* 	 Z = YES, IT IS COMPLETELY STOPPED				 *
* 	NZ = NO, IT IS MOVING						 *
* NOTE: TRASHES A14							 *
*								         *
**************************************************************************
STOPPED
	MOVE	*A8(OXVEL),A14,L
	JRNZ	STOPPED_X
	MOVE	*A8(OYVEL),A14,L
	JRNZ	STOPPED_X
	MOVE	*A8(OZVEL),A14,L
STOPPED_X
	RETS

**************************************************************************
*								         *
* PSTOP - STOP AN OBJECT, BY ZEROING ALL OF IT'S VELOCITIES		 *
* A8 = PTR TO OBJECT							 *
*								         *
**************************************************************************
PSTOP
	CALLR	PSTOPX
	JRUC	PSTOPYZ
*
*PSTOPX - CLEAR AN OBJECTS X VELOCITY, A8:OBJECT BLOCK PTR
PSTOPX	MMTM	SP,A0,A1	
	CLR	A1
	MOVE	A1,*A8(OXVEL),L
	MOVE	*A8(OSHAD),A0,L
	JREQ	PSTOPXX
	MOVE	A1,*A0(OXVEL),L		;STOP THE SHADOW
PSTOPXX
	MMFM	SP,A0,A1
	RETS

**************************************************************************
*                                                                        *
* PSTOPZ - STOP AN OBJECTS Z VELOCITY ONLY				 *
* A8 = PTR TO OBJECT							 *
*                                                                        *
**************************************************************************
PSTOPZ
	MMTM	SP,A1,A2,A3
	MOVE	*A8(OYVEL),A2,L
	MOVE	A2,A3			;KEEP HERE FOR SIGN COMPARISON
	MOVE	*A8(OZVEL),A1,L
	ABS	A1
	ABS	A2
	SUB	A1,A2
	MOVE	A3,A3			;SWITCH SIGNS?
	JRNN	PSTOPZN			;BR = NO
	NEG	A2
PSTOPZN
	CLR	A1
	MOVE	A1,*A8(OZVEL),L
	MOVE	A2,*A8(OYVEL),L
	MOVE	*A8(OSHAD),A3,L
	JREQ	PSTOPZNS
	MOVE	A1,*A3(OZVEL),L		;STOP THE SHADOW
	MOVE	A1,*A3(OYVEL),L
PSTOPZNS
	MMFM	SP,A1,A2,A3
	RETS

*PSTOPYZ - CLEAR AN OBJECTS(AND ITS SHADOW) Y & Z VELOCITY, A8:OBJECT BLOCK PTR
PSTOPYZ
	MMTM	SP,A0,A1
	CLR	A1
	MOVE	A1,*A8(OYVEL),L
	MOVE	A1,*A8(OZVEL),L
	MOVE	*A8(OSHAD),A0,L
	JREQ	PSTOPYZX
	MOVE	A1,*A0(OYVEL),L		;STOP THE SHADOW
	MOVE	A1,*A0(OZVEL),L		
PSTOPYZX
	MMFM	SP,A0,A1
	RETS

*
*YFLP - SET OBJECT Y-FLIP, A8:OBJECT BLOCK PTR
YFLP	MMTM	SP,A1,A4
	MOVE	*A8(OFLAGS),A4
	ORI	M_FLIPH,A4
	JRUC	STUFLAGS
*
*NOYFLP - CLEAR OBJECT Y-FLIP, A8:OBJECT BLOCK PTR	
NOYFLP	MMTM	SP,A1,A4
	MOVE	*A8(OFLAGS),A4
	ANDNI	M_FLIPH,A4
STUFLAGS
	MOVE	*A8(OIMG),A1,L		;GET THE CURRENT IMAGE POINTER
	CALLA	ANI			;SETUP THE "NEW" IMAGE
UNFLPD	MMFM	SP,A1,A4
	RETS

**************************************************************************
*                                                                        *
* SYNCUP - SYNCHRONIZE WITH THE NEXT DISPLAY INTERRUPT, I.E.		 *
* 	 WAIT UNTIL THE NEXT INTERRUPT IS FINISHED BEFORE RETURNING	 *
*                                                                        *
**************************************************************************
SYNCUP	MOVE	A0,-*SP,L
	CLR	A0
	MOVE	A0,@INTSYNC0,L	;CLEAR HALF SCREEN SYNC

SYNCUP1	MOVE	@INTSYNC0,A0,L
	JREQ	SYNCUP1		;END HASN'T HIT YET
	MOVE	*SP+,A0,L
	RETS

**************************************************************************
*                                                                        *
* SYNCHALF - SYNCHRONIZE WITH THE HALF SCREEN INTERRUPT			 *
*                                                                        *
**************************************************************************
SYNCHALF
	MMTM	SP,A0,A1
	MOVI	INTSYNC0,A1
	JRUC	SYNCSD
**************************************************************************
*                                                                        *
* SYNCFULL - SYNCHRONIZE WITH THE FULL SCREEN INTERRUPT			 *
*                                                                        *
**************************************************************************
SYNCFULL
	MMTM	SP,A0,A1
	MOVI	INTSYNC1,A1

SYNCSD	CLR	A0
	MOVE	A0,*A1,W	;CLEAR HALF SCREEN SYNC

SYNCSD1	MOVE	*A1,A0,W
	JREQ	SYNCSD1		;END HASN'T HIT YET
	MMFM	SP,A0,A1
	RETS

**************************************************************************
*                                                                        *
* DRAWBOX - DRAW A BOX USING THE DMA					 *
* A0 = [H,W] SIZE OF BOX						 *
* A1 = [COLOR,PALETTE]							 *
* A2 = LINE THICKNESS IN PIXELS						 *
* A3 = [Y,X] SCREEN ADDRESS OF BOX					 *
*                                                                        *
**************************************************************************
DRAWBOX
	MMTM	SP,A0,A2,A3,A4,A5,A6,A7,A8
	MOVI	DMACAL,A5		;ALWAYS THIS COLOR
	MOVI	2000000H,A4		;LET'S USE THIS AS DATA
	MOVE	A3,A7
	MOVE	A2,A8			;KEEP PIXEL THICKNESS HERE
	SLL	16,A2
	MOVX	A0,A2
	MOVE	A2,A6
	CALLA	DMAN			;DRAW TOP LINE
	RL	16,A2
	MOVY	A0,A2
	MOVE	A2,A0
	CALLA	DMAN			;DRAW LEFT LINE
	SRL	16,A2
	SLL	16,A2
	RL	16,A8
	SUBXY	A8,A2			;ADJUST FOR PIXEL THICKNESS
	ADDXY	A2,A3			;MOVE TO LL CORNER
	MOVE	A6,A2	
	CALLA	DMAN			;DRAW BOTTOM LINE
	ZEXT	A2
	DEC	A2
	RL	16,A8
	SUBK	1,A8			;BASE ON 1 PIXEL
	SUBXY	A8,A2			;ADJUST FOR PIXEL THICKNESS
	ADDXY	A2,A7			
	MOVE	A7,A3			;MOVE TO UR CORNER
	MOVE	A0,A2
	CALLA	DMAN			;DRAW RIGHT LINE
	MMFM	SP,A0,A2,A3,A4,A5,A6,A7,A8
	RETS

**************************************************************************
*                                                                        *
* DTIME - USED TO DMA AN IMAGE						 *
* A1 = [CONSTANT COLOR,PALETTE(STUFFED IN DTIME)]			 *
* A3 = DAG [Y,X]							 *
* A5 = [OFFSET,CONTROL]							 *
* A14 = ADDRESS OF IMAGE HEADER						 *
*                                                                        *
**************************************************************************
DTIME:
	MMTM	SP,A0,A1
	MOVE	*A14(ICMAP),A0,L	;GET THE PALETTE
	CALLA	FINDPAL			;GET THE CORRECT COLOR MAP #
	JRNZ	DTIME1			;BR = PALETTE WAS FOUND
	CLR	A0			;DEFAULT TO FIXED PALETTE
DTIME1
	MOVX	A0,A1
	CALLA	QDMA			;QUEUE THIS SUCKAH
	MMFM	SP,A0,A1
	RETS
**************************************************************************
*                                                                        *
* DMAN - MANUAL DMA, ALL REGS MUST BE SETUP UPON CALLING		 *
* A1 = [CONSTANT COLOR,PALETTE]						 *
* A2 = SIZE [H,W]							 *
* A3 = DESTINATION [Y,X]						 *
* A4 = STARTING ADDRESS							 *
* A5 = [OFFSET,CONTROL]							 *
*                                                                        *
**************************************************************************
DMAN
	.IF YUNIT
	PUSH	A7
	CLR	A7
	MOVX	A1,A7
	CMPI	0F0FH,A7	;ARE WE ALREADY ADJUSTED?
	JRHI	DMAN_PGO	;BR = YES!
	SLL	4,A7		;DO THE YUNIT SHUFFLE
	MOVX	A7,A1
DMAN_PGO
	PULL	A7
	.ENDIF
	JAUC	QDMAN

**************************************************************************
*								         *
* DMAWPAL - DMA AN OBJECT, ALLOCATING IT'S PALETTE			 *
* A1 = [CONSTANT, 0]							 *
* A3 = POSITION(DAG)							 *
* A5 = OFFSET:FLAGS							 *
* A14 = PTR TO IMAGE HEADER						 *
*								         *
**************************************************************************
DMAWPAL:
	MMTM	SP,A0,A1,A2,A4
	MOVE	*A14(ICMAP),A0,L	;GET THE COLOR MAP WE WANT
	CALLA	GETFPAL			;GET A PALETTE
	JRZ	DMANOPAL
	MOVX	A0,A1			;TACK ON THE PALETTE
	JRUC	DMAWPNOW
DMANOPAL:
	SRL	16,A1
	SLL	16,A1			;DEFAULT TO ZERO PALETTE
DMAWPNOW:
	MOVE	*A14(ISIZE),A2,L
	MOVE	*A14(ISAG),A4,L
	CALLR	DMAN			;DMA THIS GUY
	MMFM	SP,A0,A1,A2,A4
	RETS

**************************************************************************
*                                                                        *
* DMAWAIT - WAIT ON THE DMA BUSY BIT TO CLEAR				 *
*                                                                        *
**************************************************************************
DMAWAIT	
	PUSH	A0
DMAWAITL
	MOVE	@DMACTRL,A0,W	;DMA BUSY?
	JRN	DMAWAITL	;BR = YES
	PULL	A0
	RETS
**************************************************************************
*                                                                        *
* DMAQWAIT - WAIT FOR DMA QUEUES TO EMPTY, THEN WAIT FOR DMA TO FINISH	 *
* 	   THE LAST ONE.						 *
*                                                                        *
**************************************************************************
DMAQWAIT
	PUSH	A0
DMAQWT1
	MOVE	@TOPQ0CNT,A0,W	
	JRNE	DMAQWT1
	MOVE	@TOPQ1CNT,A0,W	
	JRNE	DMAQWT1
	MOVE	@BOTQ0CNT,A0,W	
	JRNE	DMAQWT1
	MOVE	@BOTQ1CNT,A0,W	
	JRNE	DMAQWT1
	PULL	A0
DMAQWT2
	MOVE	B13,B13
	JRZ	DMAWAIT
	JRUC	DMAQWT2
**************************************************************************
*                                                                        *
* DMAHALT - HALT THE DMA						 *
*                                                                        *
**************************************************************************
DMAHALT
	PUSH	A0
	CLR	A0
	MOVE	A0,@DMACTRL,W		;HALT THE DMA			 
	PULL	A0
	RETS
*
*CMAPRS - RESET THE COLOR MAP SELECT
CMAPRS	CLR	A0
*CMAPSL - SELECT THE COLOR MAP(0-15 IN A0)
CMAPSL	MOVE	A1,-*SP,L
	CALLA	DMAWAIT
	MOVE	A0,@CMAPSEL
	MOVE	*SP+,A1,L
	RETS

**************************************************************************
*                                                                        *
* CRINIT - COLOR RAM INITIALIZATION, FIRST CLEAR ALL COLOR RAM, THEN	 *
* 	 FILL WITH PALETTES.						 *
*                                                                        *
**************************************************************************
CRINIT
	MMTM	SP,A0,A1,A2,A6
	MOVI	COLRAM,A1
	CLR	A0
	MOVI	NUMPAL*PALSIZE,A6
**	MOVI	10000H,A6,L
*CLEAR ALL COLOR PALETTES
CRINIT1
	MOVE	A0,*A1+,L	;STUFF TWO WORDS AT A TIME
	DSJS	A6,CRINIT1

	MMFM	SP,A0,A1,A2,A6 ;<----
	RETS		       ;<----

**************************************************************************
*                                                                        *
* CRLOAD - LOAD COLOR RAM FROM A ROM TABLE				 *
* A1 = START OF ROM TABLE						 *
* A2 = COLOR RAM START ADDRESS						 *
* A6 = PALETTE COUNT							 *
*                                                                        *
**************************************************************************
CRLOAD
	MMTM	SP,A0,A1,A2
CRLOAD1
 	MOVE	*A1+,A0,W	;GRAB FIRST COLOR FROM THIS TABLE
	JRN	CRLOAD4		;BR = NULL PALETTE
CRLOAD3
	MOVE	A0,*A2,W	;STUFF COLOR
	MOVE	*A1+,A0,W	;GRAB NEXT COLOR FROM THIS TABLE
	JRN	CRLOAD4		;BR = NEXT PALETTE
	ADDK	16,A2		;INC THIS WAY SO WE DON'T OVERRUN PALETTES
	JRUC	CRLOAD3

CRLOAD4
	ADDI	1000H,A2	;NEXT PALETTE
	SRL	12,A2
	SLL	12,A2		;MASK OFF LOW BULLSHIT
	DSJ	A6,CRLOAD1

	MMFM	SP,A0,A1,A2
	RETS

*
*SCRCLR - CLEAR THE SCREEN WITH EUGENE
*ONLY CALL WITH INTERRUPTS DISABLED AND THE DMA SHUT DOWN, OTHERWISE
*	USE CLR_SCRN
SCRCLR	CLR	A0
*SCRFIL - FILL SCREEN WITH A0
SCRFIL:
	MMTM	SP,A1,A2
	CLR	A1
	MOVE	A1,@CMAPSEL,W			;SELECT COLOR MAP 0
	MOVI	SCREEN,A1,L
	MOVI	(SCRNE-SCREEN)/32,A2,L
SCRLP	MOVE	A0,*A1+,L
	DSJS	A2,SCRLP
	MMFM	SP,A1,A2
	RETS

*
*LAST2CLR - CLEAR LAST TWO LINES OF BIT MAP(I.E. SET AUTO ERASE COLOR)
LAST2CLR
	CLR	A0
*
*LAST2FIL - FILL LAST TWO LINES OF BIT MAP
*A0 = FILL COLOR
LAST2FIL
	MOVE	A0,@ERASELOC,W			;STUFF DA COLOR
	RETS
**************************************************************************
*                                                                        *
* SETPPROC - SETUP TI'S PIXEL PROCESSING REGISTER'S (BFILE), TO MATCH 	 *
* 	   THE ZUNIT SYSTEM.						 *
* NOTE:	   IF YOU WANT TO DO ANY SPECIAL TRICKS, DON'T USE THIS. 	 *
*                                                                        *
**************************************************************************
SETPPROC
	PUSH	A0
	MOVI	OFFSETVAL,B4	;Set up OFFSET register
	MOVI	0,B8		 	;Set background color
	MOVI	SCRN_PTCH,A0 		;Get Screen Pitch
	MOVE	A0,B1
	MOVE	A0,B3
	LMO	A0,A0			;Convert in temporary register
	MOVE	A0,@CONVSP		;Move to CONVSP io register
	MOVE	A0,@CONVDP		;Move to CONVDP io register
	PULL	A0
	RETS


**************************************************************************
*                                                                        *
* CLRBLOCK - CLEAR A BLOCK OF MEMORY. SIZE MUST BE A FACTOR OF 16	 *
*	     MAKE SURE BLOCK SIZE IS 32 BITS OR GREATER.		 *
* A1 = START ADDRESS							 *
* A2 = END ADDRESS							 *
*                                                                        *
**************************************************************************
CLRBLOCK:
	PUSH	A3
	CLR	A3
	CALLR	FILBLOCK
	PULL	A3
	RETS

**************************************************************************
*                                                                        *
* FILBLOCK - FILL A BLOCK OF MEMORY. SIZE MUST BE A FACTOR OF 16	 *
*	     MAKE SURE BLOCK SIZE IS 32 BITS OR GREATER.		 *
* A1 = START ADDRESS							 *
* A2 = END ADDRESS							 *
* A3 = FILL VALUE							 *
*                                                                        *
**************************************************************************
FILBLOCK:
	MMTM	SP,A1,A2
	SUB	A1,A2
	SRL	5,A2
	JRNC	FIL32LP
	MOVE	A3,*A1+,W		;MOVE THE ODD WORD
FIL32LP:	
	MOVE	A3,*A1+,L		;JUST MOVE LONG
	DSJS	A2,FIL32LP
	MMFM	SP,A1,A2
	RETS
	
**************************************************************************
*                                                                        *
* CLR_SCRN - CLEAR THE WHOLE BIT MAP					 *
* NOTE : TRASHES A0							 *
*                                                                        *
**************************************************************************
CLR_SCRN:
	CLR	A0
*
*YOU PROVIDE THE COLOR IN A0
FILL_SCRN:
	MMTM	SP,A1,A2,A3
	MOVE	@DISPLAYON,A3,W
	CLR	A1
	MOVE	A1,@DISPLAYON,W
	CALLR	DMAQWAIT			;WAIT ON DMA
	CLR	A1
	MOVE	A1,@CMAPSEL,W			;SELECT COLOR MAP 0
	MOVI	SCREEN,A1,L
	MOVI	((SCRNE-2000H)-SCREEN)/32,A2,L
CLRLP	MOVE	A0,*A1+,L
	DSJS	A2,CLRLP
	MOVE	A3,@DISPLAYON,W
	MMFM	SP,A1,A2,A3
	RETS

*
*CLEAR EVERYTHING UNDERNEATH THE STATUS AREA
CLRPLAY
	MMTM	SP,A0,A1,A2,A3
	CLR	A0
	MOVE	@DISPLAYON,A3,W
	MOVE	A0,@DISPLAYON,W
	CALLA	DMAQWAIT			;WAIT ON DMA
	CLR	A1
	MOVE	A1,@CMAPSEL,W			;SELECT COLOR MAP 0
	MOVI	SCREEN+(SKYTOPOF*>1000),A1,L
	MOVI	(SCRNE-(SCREEN+(SKYTOPOF*>1000)))/32,A2,L
CLRPLP	MOVE	A0,*A1+,L
	DSJS	A2,CLRPLP
	MOVE	A3,@DISPLAYON,W
	MMFM	SP,A0,A1,A2,A3
	RETS

*
*CLEAR EVERYTHING UNDERNEATH THE STATUS AREA ON PAGE 0 ONLY
CLRP_P0
	MMTM	SP,A0,A1,A2,A3
	CLR	A0
	MOVE	@DISPLAYON,A3,W
	MOVE	A0,@DISPLAYON,W
	CALLA	DMAQWAIT			;WAIT ON DMA
	CLR	A1
	MOVE	A1,@CMAPSEL,W			;SELECT COLOR MAP 0
	MOVI	SCREEN+(SKYTOPOF*1000H),A1,L
	MOVI	(PAGE0E-(SCREEN+(SKYTOPOF*1000H)))/32,A2,L
CLRP0LP	MOVE	A0,*A1+,L
	DSJS	A2,CLRP0LP
	MOVE	A3,@DISPLAYON,W
	MMFM	SP,A0,A1,A2,A3
	RETS

*
*CLEAR EVERYTHING UNDERNEATH THE STATUS AREA ON PAGE 1 ONLY
CLRP_P1
	MMTM	SP,A0,A1,A2,A3
	CLR	A0
	MOVE	@DISPLAYON,A3,W
	MOVE	A0,@DISPLAYON,W
	CALLA	DMAQWAIT			;WAIT ON DMA
	CLR	A1
	MOVE	A1,@CMAPSEL,W			;SELECT COLOR MAP 0
	MOVI	PAGE0E+(SKYTOPOF*1000H),A1,L
	MOVI	(SCRNE-(PAGE0E+(SKYTOPOF*1000H)))/32,A2,L
	JRUC	CLRP0LP

**************************************************************************
*                                                                        *
* FRANIM - ANIMATION SCRIPT PROCESSOR					 *
* A1 = [SLEEP_MULTIPLIER, COMMAND]					 *
*      COMMAND: 00 = PROCESS CURRENT FRAME.				 *
* 		01 = PROCESS TO END OF LIST.				 *
* 		02 = PROCESS X # OF FRAMES OR TO END. A1=[SM,#FRMS:02]	 *
* 		03 = INFINITELY LOOP ON THE LIST.			 *
* 		04 = PROCESS CURRENT FRAME, NO SLEEP(TIME RETRN'D IN A0) *
*	SLEEP_MULTIPLIER:						 *
*		IF = 0 THEN, NO MULTIPLY				 *
*		IF <> 0 THEN, BITS 16-23 FRACTION			 *
*			      BITS 24-31 INTEGER			 *
* A8 = PTR TO OBJECT BLOCK						 *
* A9 = PTR TO CURRENT FRAME						 *
* RETURN(S)								 *
* CARRY SET IF END OF ANIMATION LIST WAS HIT				 *
* A9 = POINTING TO NEXT FRAME, IF NOT AT END OF LIST			 *
* SETS EPARENT OF THE SPAWNED CHILD POINTING TO THIS PROCESS		 *
* NOTE: CALL WITH JSRP, IT SLEEPS					 *
* 									 *
* ANIMATION SCRIPT FORMAT						 *
* 	.LONG	IMAGE_HEADER<-- IF = 0 END OF SCRIPT			 *
* 	.WORD	SLEEP_TIME  <-- BITS 0 - 7 ARE THE SLEEP TIME.	 	 *
* 			    <-- BITS 8 -15 ARE THE FLAGS:		 *
* 				 BIT #	DESCRIPTION		SIZE	 *
* 				 -----	-----------		----	 *
* 				   8	NEW SCRIPT ADDRESS 	(32)	 *
* 				   9	SOUND SCRIPT TO EXECUTE (32)	 *
* 				  10	UNUSED				 *
* 				  11	DELTA Y			(16) 	 *
* 				  12	PACKED DELTAS FOR X&Z 	(16)	 *
* 				  13	NEW PALETTE ADDRESS	(32)	 *
* 				  14	NEW FLIP BITS		(16)	 *
* 				  15	SPAWN PROCESS W/OFFSETS	(80)	 *
* 					 .WORD XOFF,YOFF,PROCID		 *
* 					 .LONG PROCADDR			 *
* 				FLAG HIERARCHY: 15 --> 8		 *
* 				 OPTIONS SHOULD FOLLOW IN THIS ORDER.    *
*                                                                        *
**************************************************************************
FRANIM
	MMTM	A12,A3,A11
	MOVE	A9,A11			;SAVE ENTRYPOINT FOR INFINITE CASE		
	MOVY	A1,A2
	SRL	16,A2			;ISOLATE SLEEP TIME MULTIPLIER
	ZEXT	A1			;AND CLEAR IT FROM A1
	SLL	8,A1			;PUT EXTRA BYTE IN HIGH WORD
	CLR	A3			;TO KEEP COMPATIBLE
	MOVX	A1,A3
	SRL	8,A3			;SLIDE THE COMMAND BACK DOWN
	MOVX	A3,A1			;AND RETURN IT TO A1
FRAN1
	MOVE	A1,A3

	.IF	DEBUG
	CMPI	0FFC00000H,A9
	JRLO	$
	.ENDIF
	
	MOVE	*A9+,A1,L		;GET THE FRAME
	JREQ	FRANND			;BR = END WAS HIT

	MMTM	SP,A2,A4,A5,A6,A7,A10,A14

      	MOVE	*A8(OFLAGS),A4,W	;GRAB THE FLAGS

	MOVE	*A9+,A0,W
	MOVE	A0,A14			;XFER FLAGS HERE	
	SLL	24,A0
	SRL	24,A0			;WIPE OFF THE FLAGS

	SRL	8,A14			;STRIP THE SLEEP TIME
	SLL	24,A14			;MOVE FLAGGIES UP HERE
	JRZ	FRANANI			;BR = NO FLAGS

	SLL	1,A14
	JRNC	FRANNOSP
*SPAWN A PROCESS
	MMTM	SP,A0,A1
	MOVE	*A9+,A10,L	;X AND Y FIRING OFFSETS PASSED IN A10
	MOVE	*A9+,A1,W	;GET PROCESS ID
	MOVE	*A9+,A7,L	;PROCESS STARTING ADDRESS
	CALLA	GETPRC		;SPAWN THE PROCESS
***	JREQ	FRSPAWNF	;BR = FAILED TO SPAWN
***	MOVE	A13,*A0(EPARENT),L	;RETURN LINK TO PARENT PROCESS	
FRSPAWNF
	MMFM	SP,A0,A1	
FRANNOSP
	SLL	1,A14
	JRNC	FRANNOBI
*STUFF SOME NEW FLAGS
	MOVE	*A9+,A2,W		;GET THE NEW FLIP FLAGS
	ANDNI	(M_FLIPV+M_FLIPH),A4	;CLEAR THE CURRENT FLIP STATUS
	OR	A2,A4			;SET DESIRED BITS

FRANNOBI:
	SLL	1,A14
	JRNC	FRANNOPA
*ACTIVATE A NEW PALETTE
	PUSH	A0			

	MOVE	*A9+,A0,L		;GET THE NEW PALETTE ADDRESS
	CALLA	CHANGE_PAL		;SWITCH THE PALETTES

****	MOVE	A8,A0
****	CALLA	DELPAL			;DELETE OLD
****	MOVE	*A9+,A0,L		;GET THE PALETTE ADDRESS
****	CALLA	GETFPAL			;GET A COLOR MAP ASSIGNMENT
****	MOVE	A0,*A8(OPAL),W		;STORE THE NEW PALETTE
	
	PULL	A0
FRANNOPA
	SLL	1,A14
	JRNC	FRANNDXZ
*ADD DELTA X AND Z
	MOVE	*A9+,A7,W		;GET THE DELTAS
	MOVE	A7,A6
	SLL	24,A6
	SRA	24,A6			;BRING THE SIGN BACK DOWN
	JRZ	FNODX			;BR = THERE'S NO DELTA HERE
	BTST	B_FLIPH,A4
	JREQ	FNOFDX
	NEG	A6			;HE'S FLIPPED, NEGATE
FNOFDX
	MOVE	*A8(OXPOS),A5,W
	ADD	A6,A5
	MOVE	A5,*A8(OXPOS),W		;ADJUST X POSITION
FNODX
	SRA	8,A7
	JRZ	FRANNDXZ		;BR = NO Z OFFSET

***	BTST	B_FLIPV,A4		;I DON'T FEEL THIS NECESSARY (10/25/89)
***	JREQ	FNOFDZ
***	NEG	A7
***FNOFDZ

	MOVE	*A8(OZPOS),A5,W
	ADD	A7,A5
	MOVE	A5,*A8(OZPOS),W		;ADJUST Z POSITION

***	MOVE	*A8(OYPOS),A5,W
***	ADD	A7,A5
***	MOVE	A5,*A8(OYPOS),W		;ADJUST MATCHING Y POSITION
FRANNDXZ
	SLL	1,A14
	JRNC	FRANNDY
*ADD DELTA Y
	MOVE	*A9+,A7,W
	JRZ	FRANNDY
	BTST	B_FLIPV,A4
	JREQ	FNOFDY
	NEG	A7
FNOFDY
	MOVE	*A8(OYPOS),A5,W
	ADD	A7,A5
	MOVE	A5,*A8(OYPOS),W		;ADJUST Y POSITION
FRANNDY
	SLL	2,A14		;GET TO BIT 9, SKIP 10
	JRNC	FRANNSND	;BR = NO SOUND TO MAKE
	PUSH	A0
	MOVE	*A9+,A0,L	;GET SOUND SCRIPT
	CALLA	ONESND		;AND PROCESS IT
	PULL	A0
FRANNSND:
	SLL	1,A14
	JRNC	FRANNNA		;BR = NO NEW SCRIPT ADDRESS
	MOVE	*A9,A9,L	;LOAD IN THE NEW SCRIPT ADDRESS
FRANNNA:
*JUST TO THE ANIMATION
FRANANI:
	CALLA	ANI		;SETUP NEW ANIMATION

	MMFM	SP,A2,A4,A5,A6,A7,A10,A14

	MOVE	A3,A1		;GET THE COMMAND BACK
	MOVE	A2,A2		;MULTIPLY?
	JRZ	FRAN_NO_MULT	;BR = NO
	MOVE	A0,A3
	SLL	8,A3 		;MAKE FRACTION ZERO
	MPYU	A2,A3		;MULTIPLY
	SRL	16,A3
	JRNZ	FRAN_SLEEP_OK
	MOVK	1,A3		;DEFAULT TO SHORTEST SLEEP
FRAN_SLEEP_OK:
	MOVE	A3,A0		;INTEGER ONLY TO SLEEP
FRAN_NO_MULT:
	CMPI	4,A1		;ONE FRAME, NO SLEEP?
	JREQ	FRAN3		;YES

	MMTM	A12,A1,A2
	CALLA	PRCSLP		;SLEEP THE PROPER TIME
	MMFM	A12,A1,A2

	CMPI	1,A1
	JREQ	FRAN1		;BR = LOOP 'TIL END OF LIST
	JRLT	FRAN3		;BR = ONE FRAME AT A TIME
	CMPI	3,A1
	JREQ	FRAN1		;BR = INFINTE LOOP

	SUBI	010000h,A1	;DECREMENT FRAME COUNT
    	CLR	A0
	CMPXY	A0,A1
	JRYGT	FRAN1		;FRAME COUNT HAS NOT BEEN EXHAUSTED

FRAN3	CLRC			;CLEAR END FLAG
	JRUC	FRANX			

FRANND	MOVE	A3,A1
	CMPI	3,A1
	JRNE	FRAN4		;BR = EXIT

	MOVE	A11,A9		;GET THE STARTING POINTER BACK
	JRUC	FRAN1		;LOOP INFINITELY

FRAN4	SETC			;OTHERWISE, RETURN WITH END FLAG SET
FRANX
	MMFM	A12,A3,A11
	RETP

**************************************************************************
*                                                                        *
* FRAMSKIP - SKIP TO THE NEXT FRAME OF AN ANIMATION SCRIPT		 *
* A9 = SCRIPT PTR							 *
* RETURNS:								 *
* 	C CLR = A9 IS POINTING TO NEXT FRAME				 *
* 	C SET = SCRIPT END WAS HIT, A9 POINTS TO NEXT WORD		 *
*                                                                        *
**************************************************************************
FRAMSKIP
	MMTM	SP,A1
	MOVE	*A9+,A1,L		;GET THE FRAME
	JREQ	FRAMSSC			;BR = END WAS HIT
	MOVE	*A9+,A1,W
	SRL	8,A1			;STRIP THE SLEEP
	SLL	24,A1			;MOVE FLAGGIES UP HERE
	JRZ	FRAMSANI		;BR = NO FLAGS

	SLL	1,A1
	JRNC	FRAMSNSP
	ADDI	32+16+32,A9		;PROCESS SPAWN
FRAMSNSP
	SLL	1,A1
	JRNC	FRAMSNF
	ADDK	16,A9			;NEW FLAGS
FRAMSNF
	SLL	1,A1
	JRNC	FRAMSNP
	ADDK	32,A9			;NEW PALETTE
FRAMSNP
	SLL	1,A1
	JRNC	FRAMSNXZ
	ADDK	16,A9			;DELTA X & DELTA Z
FRAMSNXZ
	SLL	1,A1
	JRNC	FRAMSNY
	ADDK	16,A9			;DELTA Y
FRAMSNY
	SLL	2,A1
	JRNC	FRAMSNSND
	ADDK	32,A9			;SOUND TO MAKE
FRAMSNSND:
	SLL	1,A1
	JRNC	FRAMSNNSA
	MOVE	*A9,A9,L		;JUMP TO NEW FRAME
FRAMSNNSA:
FRAMSANI:
	CLRC	
	JRUC	FRAMSND
FRAMSSC
	SETC
FRAMSND
	MMFM	SP,A1
	RETS

**************************************************************************
*								         *
* SKIP_ANIMATION - ROUTINE TO SKIP TO THE END OF AN ANIMATION SCRIPT.	 *
*		   THERE IS A 20 FRAME MAX SKIP IMPOSED.		 *
* A9 = PTR TO SCRIPT							 *
* RETURNS:								 *
* A9 = PTR TO WORD AFTER SCRIPT END					 *
*								         *
**************************************************************************
SKIP_ANIMATION
	PUSH	A0
	MOVK	20,A0
SKA_LP
	CALLR	FRAMSKIP
	JRC	SKA_X
	DSJS	A0,SKA_LP
SKA_X
	PULL	A0
	RETS

**************************************************************************
*                                                                        *
* ANIMATOR - INDEPENDENT ANIMATION PROCESS, PROCESSES AN ANIMATION	 *
* 	     SCRIPT WITH A COMMAND.		     			 *
* A8 = OBJECT TO ANIMATE						 *
* A9 = SCRIPT								 *
* A11 = FRANIM COMMAND							 *
*                                                                        *
**************************************************************************
ANIMATOR
	MOVE	A11,A1
	JSRP	FRANIM
	CLR	A0
	MOVE	A0,*A8(OPLINK),L
	DIE

**************************************************************************
*								         *
* ANIMATE_DEL - INDEPENDENT ANIMATION PROCESS, PROCESSES AN ANIMATION	 *
* 	     SCRIPT WITH A COMMAND THEN DELETE THE OBJECT.		 *
* A8 = OBJECT TO ANIMATE						 *
* A9 = SCRIPT								 *
* A11 = FRANIM COMMAND							 *
*								         *
**************************************************************************
ANIMATE_DEL:
	MOVE	A11,A1
	JSRP	FRANIM
	CLR	A0
	MOVE	A0,*A8(OPLINK),L
	CALLA	DELETE_OBJ
	DIE

**************************************************************************
*                                                                        *
* IAUTOE - INITIALIZE THE AUTO ERASE LINES OF THE BIT MAP, 510 & 511.	 *
* NOTE: CALL ONLY WITH INTERRUPTS DISABLED AND THE DMA SHUT DOWN!	 *
*                                                                        *
**************************************************************************
IAUTOE
	MMTM	SP,A0,A1,A2
	MOVI	ERASECOL,A0		;GET THE ERASE COLOR CONSTANT
	CLR	A1
	MOVE	A1,@CMAPSEL,W		;SELECT COLOR MAP 0
	MOVI	SCREEN+(510*1000H),A1,L	;START @ LINE 510
	MOVI	(SCRNE-(SCREEN+(510*1000H)))/32,A2,L
IAUTOELP
	MOVE	A0,*A1+,L
	DSJS	A2,IAUTOELP
	MMFM	SP,A0,A1,A2
	RETS

**************************************************************************
*                                                                        *
* AUTOEOFF - TURN OFF AUTO ERASE					 *
* NOTE: BE SURE THE DIRQ IS OFF BEFORE CALLING				 *
*                                                                        *
**************************************************************************
AUTOEOFF
	PUSH	A0
	PUSHST
	DINT
	MOVE	@SYSCOPY,A0,W
	ORI	AUTOERAS,A0  	;DISABLE AUTO ERASE
	MOVE	A0,@SYSCOPY,W	;STORE EVERYWHERE I DID GO
	POPST
	MOVE	A0,@SYSCTRL,W
	PULL	A0
	RETS

**************************************************************************
*                                                                        *
* AUTOEON - TURN ON AUTO ERASE					 	 *
* NOTE: BE SURE THE DIRQ IS OFF BEFORE CALLING				 *
*                                                                        *
**************************************************************************
AUTOEON
	PUSH	A0
	 MOVE	@NOAUTOE,A0,W
	 JRNE	AUTOEON1	;BR = DEBUGGER MAN SAYS NO AUTOERASE
	PUSHST
	DINT
	MOVE	@SYSCOPY,A0,W
	ANDNI	AUTOERAS,A0  	;AUTO ERASE IS ENABLED LOW
	MOVE	A0,@SYSCOPY,W	;STORE EVERYWHERE I DID GO
	POPST
	MOVE	A0,@SYSCTRL,W
AUTOEON1
	PULL	A0
	RETS

**************************************************************************
*                                                                        *
* PAGE0 - SET THE SYSTEM TO GRAPHICS PAGE 0				 *
*                                                                        *
**************************************************************************
PAGE0
	PUSH	A0
	MOVI	DPYPAGE0,A0,W
	MOVE	A0,@DPYSTRT,W
	CLR	A0
	MOVE	A0,@PAGE,W
	PULL	A0
	RETS

**************************************************************************
*                                                                        *
* PAGE1 - SET THE SYSTEM TO GRAPHICS PAGE 1				 *
*                                                                        *
**************************************************************************
PAGE1
	PUSH	A0
	MOVI	DPYPAGE1,A0,W
	MOVE	A0,@DPYSTRT,W
	MOVK	1,A0
	MOVE	A0,@PAGE,W
	PULL	A0
	RETS

**************************************************************************
*                                                                        *
* TURNPAGE - TOGGLE GRAPHICS PAGE0 & PAGE1				 *
*                                                                        *
**************************************************************************
TURNPAGE
	PUSH	A0	
	MOVE	@DPYSTRT,A0,W
	ZEXT	A0
	CMPI 	DPYPAGE0,A0
	JRNE	TURNTO0
	CALLR	PAGE1			;SHOW PAGE 1
	JRUC	TURNPX
TURNTO0
	CALLR	PAGE0
TURNPX
	PULL	A0
	RETS

**************************************************************************
*								         *
* MAKOBJZ - MAKE AN OBJECT WITH Z INITIALIZATION			 *
* RETURNS:								 *
* 	 Z = FAILED TO GET AN OBJECT BLOCK				 *
* 	NZ = SUCCESS, A0 = PTR TO OBJECT				 *
*								         *
**************************************************************************
MAKOBJZ
	CALLA	GPALOBJSTF
	JRZ	MAKOBZX		;NONE LEFT
	CALLA	SET_ZPOS
	CALLA	INSOBJ
	MOVE	A0,A0		;RETURN NON-ZERO
MAKOBZX
	RETS

**************************************************************************
*                                                                        *
* OSINK - SINK OBJECT INTO GROUND PROCESS SUBROUTINE			 *
* A8=OBJECT								 *
* A9=SLEEP TIME: SINK RATE PIX/SLEEP					 *
* NOTE: CALL WITH JSRP							 *
*                                                                        *
**************************************************************************
OSINK:	
	PUSHP	A10
	CALLA	PSTOP
	MOVE	A9,A10
	ZEXT	A9
	SRL	16,A10
OSINKL:
	MOVE	*A8(OSIZEY),A0,W
	SUB	A9,A0
	JRLS	OSINKX			;SINKING IS DONE
	MOVE	A0,*A8(OSIZEY),W	;ADJUST HT.
	MOVE	*A8(OYPOS),A1,W		;ADJUST TOP LEFT Y
	ADD	A9,A1
	MOVE	A1,*A8(OYPOS),W
	SLEEPR	A10
	JRUC	OSINKL
OSINKX:
	PULLP	A10
	RETP

	.END

