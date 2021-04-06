	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGTEXT.ASM'
	.TITLE	" <<< T R O G ---- TEXT PROCESSING ROUTINES >>>"
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
	.INCLUDE	"IMGTBL.GLO"	;Image Equates and Globals
	.INCLUDE	"STRING.H"
	.INCLUDE	"TROGTEXT.TBL"
	.INCLUDE	"TROGSEQU.ASM"	; COLOR DEFS

;		ASCII Character String Definition
;		---------------------------------
;
;     An ASCII string is n consecutive bytes terminated by a 0.
;
;     A string may contain:
;
;	1. Printable ASCII characters 20h - 7fh.
;
;	2. Command character denoted by a leading \.
;
;	3. Format specifier denoted by a leading %.
;
;     Command Characters:
;
;	A command character is identified by a preceding '\'. These
;	are used to embed command characters and the correct arguments
;	in the string.
;
;	Arguments follow the string definition in the order that they,
;	along with format arguments, appear in the string. 
;
;	To insert a single '\' into the string use '\\'.
;
;	Character		Argument	       		Size
;	---------     		--------			----
;	a			Sleep time to embed		.WORD
;	b			Print color to embed		.WORD
;	c			DMA control word to embed	.WORD
;	d			Font to embed			.LONG
;	e			[Y,X] Position to embed		.LONG
;	f			[DY,DX] Position delta to embed	.LONG
;	i			[Y,X] Spacing to embed		.LONG
;	n	    newline		-
;	p			Use new palette, by I.D.	.LONG
;	u			Turn underlining on
;	v			Turn underlining off
;
;	Inserting a '*' between the \ and the command character will
;	cause the argument to be indirected through the specified pointer.
;
;	Example:
;		.string "switch \*b color",0
;		.long	color_ptr
;	  The color that would be inserted is pointed to by color_ptr.	
;
;     Format Specifiers:	(Note: if a string contains format specifiers
;			       then you must call stringf before	
;			       passing it to the string routines.)	 
;
;		%[flags][width][{h|l|L}]type
;
;	flags - Used for justification of output and printing of
;		signs, blanks and hexadecimal prefixes
;
;		flag	Meaning					Default
;		----	-------					-------
;		+	Prefix the output value with a sign	Sign only for
;			+ or - if it is of signed type.		negatives
;		#	Prefix x,X with 0x,0X.			no prefix
;		,	Used with d,u to print commas		no commas		
;
;	width - A non-negative decimal integer controlling the
;		minimum number of characters printed. If width
;		is prefixed with a 0, zeros are added until the
;		minimum width is reached.
;
;	Prefix		Use
;	------		---
;	h		Used as a prefix with d,u,x,X and c to specify
;			that the argument is a short (byte).
;	l,L		Used as a prefix with d,u,x and X to specify
;			that the argument is a long.
;
;	If the % format character is followed by another % then no
;	format field is taken, rather a single % is written.
;
;	type	Size		Output Format	      	
;	----	----		-------------
;	b	word		Pointer to Binary Coded Decimal (bcd) integer
;	d	word		Pointer to Signed decimal integer
;	u	word		Pointer to Unsigned decimal integer
;	x	word		Pointer to Unsigned hex integer using 'abcdef'
;	X	word		Pointer to Unsigned hex integer using 'ABCDEF'
;	c	word		Pointer to Single character
;	p	long		Pointer to a null terminated string
;	s	long		Address of a null terminated string	
;
;	Arguments - Must follow the string specification in order.
;
;	Examples:
;	---------
;	  This will print the string verbatim,
;		.string	"Let's print a string",0
;	
;	  This will put 'count' at the beginning of the string.
;		.string "%d This is item number %d",0 
;		.long	count		;pointer to int count
;		.long	count		;pointer to int count
;
;	  This will print 'short_item' as a short and 'long_item' as a long.
;		.string "%hd This item is a long %ld",0
;		.long	short_item	;pointer to int count
;		.long	long_item	;pointer to long long_item
;
;	Note: Strings may be nested as deep as defined by NUMSFBUFS
;	      Also, these parameters have limits, i.e. width, it would	
;		not be wise to specify a width of 30 or greater, and so on.
;
;		Commas are not recognized on lead zero fills.

	.REF	DICT_LOOKUP

NUMSFBUFS EQU	5	;NUMBER OF BUFFERS FOR STRINGF
SFBUFSIZE EQU	50*16	;STRINGF BUFFERS ARE 99 CHARACTERS + TERMINATOR

	.BSS	STRNGRAM,30*16	;RAM FOR BUILDING OF STRINGS BY CONVERSION ROUTINES
	.BSS	STRINGF_RAM,NUMSFBUFS*SFBUFSIZE	;RESERVE STRINGF BUFFERS
	.BSS	SFINDEX,16	;INDEX OF NEXT USABLE STRINGF BUFFER
	.BSS	STRING1,32	;TEMP PTR FOR NESTED STRINGS, ANYONE CAN USE
	.BSS	STRING2,32
	.BSS	STRING3,32
	.BSS	STRING_SHADOW,16
	.BSS	STRING_UNDERLINE,16	; UNDERLINE FLAG

	.EVEN
	.TEXT

**************************************************************************
*                                                                        *
* 	ANY OF THE FOLLOWING STRING PRINT ROUTINES REQUIRE		 *
* 	  THESE ARGUMENTS. PLUS ANY OTHERS SPECIFIED.			 *
* 									 *
* 	A0 = SLEEP TIME BETWEEN CHARACTERS				 *
* 	A4 = DMA CONTROL						 *
* 	A5 = [COLOR,PALETTE]						 *
* 	A8 = PTR TO STRING						 *
* 	A9 = [Y,X] SCREEN ADDRESS					 *
* 	A10 = [Y,X] SPACING						 *
* 	A11 = PTR TO FONT TABLE						 *
* 									 *
* 	THEY ALL RETURN THESE VALUES INTACT, HOWEVER, ANY CHANGES	 *
* 	INCURRED FROM CONTROL BYTES WILL REMAIN.			 *
* 	ALSO RETURNED:							 *
* 									 *
* 	A8 = POINTS TO THE NEXT BYTE AFTER THE STRING TERMINATOR	 *
* 	A9 = NEXT CURSOR POSITION					 *
* 									 *
* 	NOTE: CALL ALL OF THEM WITH JSRP				 *
*                                                                        *
**************************************************************************
                                                                       
**************************************************************************
*                                                                        *
* PRINTF - FORMAT AND PRINT A STRING.					 *
* A1 = ROUTINE TO CALL FOR OUTPUT					 *
* A8 = PTR TO STRING							 *
* RETURNS:								 *
* A1 = INTACT								 *
* A8 = POINTING TO WORD AFTER THE LAST ARGUMENT OF THIS STRING		 *
* 									 *
* NOTE: CALL WITH JSRP							 *
*                                                                        *
**************************************************************************
PRINTF
	CALLR	STRINGF
	MMTM	A12,A1,A3	;SAVE ROUTINE AND NEXT STRING PTR
	JSRPR	A1
	MMFM	A12,A1,A8	;RESTORE ROUTINE AND NEXT STRING (A8)
	RETP

**************************************************************************
*                                                                        *
* STRLNRM - PRINT STRING WITH:						 *
* 		 LEFT JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* TRASHES A4 & A14							 *
*                                                                        *
**************************************************************************
STRLNRM
	MOVI	DMACNZ,A4
	CLR	A14
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRCNRM - PRINT STRING WITH:						 *
* 		 CENTER JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* TRASHES A4 & A14							 *
*                                                                        *
**************************************************************************
STRCNRM
	MOVI	DMACNZ,A4
	MOVK	1,A14
	JRUC	STRINGER
**************************************************************************
*                                                                        *
* STRRNRM - PRINT STRING WITH:						 *
* 		 RIGHT JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* TRASHES A4 & A14							 *
*                                                                        *
**************************************************************************
STRRNRM
	MOVI	DMACNZ,A4
	MOVK	2,A14
	JRUC	STRINGER
**************************************************************************
*                                                                        *
* STRLNRMO - PRINT STRING WITH:						 *
* 		 LEFT JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
* TRASHES A4 & A14							 *
*                                                                        *
**************************************************************************
STRLNRMO
	MOVI	DMACNZ|M_NOSCROLL,A4
	MOVI	10000H,A14
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRCNRMO - PRINT STRING WITH:						 *
* 		 CENTER JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
* TRASHES A4 & A14							 *
*                                                                        *
**************************************************************************
STRCNRMO
	MOVI	DMACNZ|M_NOSCROLL,A4
	MOVI	10001H,A14
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRRNRMO - PRINT STRING WITH:						 *
* 		 RIGHT JUSTIFY, NORMAL, INSERT ON THE OBJECT LIST 	 *
* TRASHES A4 & A14							 *
*                                                                        *
**************************************************************************
STRRNRMO
	MOVI	DMACNZ,A4
	MOVI	10002H,A14
	JRUC	STRINGER

**************************************************************************
*								         *
* STRLNC - PRINT STRING WITH:						 *
* 		 LEFT JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST	 *
* 		 NO CONSTANT SUBSTITUTE					 *
* TRASHES A4 & A14							 *
*								         *
**************************************************************************
STRLNC:
	MOVI	DMAWNZ,A4
	CLR	A14
	JRUC	STRINGER
**************************************************************************
*                                                                        *
* STRCNC - PRINT STRING WITH:						 *
* 		 CENTER JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* 		 NO CONSTANT SUBSTITUTE					 *
* TRASHES A4 & A14							 *
*                                                                        *
**************************************************************************
STRCNC:
	MOVI	DMAWNZ,A4
	MOVK	1,A14
	JRUC	STRINGER
**************************************************************************
*                                                                        *
* STRRNC - PRINT STRING WITH:						 *
* 		 RIGHT JUSTIFY, NORMAL, NOT PUT ON THE OBJECT LIST 	 *
* 		 NO CONSTANT SUBSTITUTE					 *
* TRASHES A4 & A14							 *
*                                                                        *
**************************************************************************
STRRNC:
	MOVI	DMAWNZ,A4
	MOVK	2,A14
	JRUC	STRINGER
**************************************************************************
*                                                                        *
* STRLNCO - PRINT STRING WITH:						 *
* 		 LEFT JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
* 		 NO CONSTANT SUBSTITUTE					 *
* TRASHES A4 & A14							 *
*                                                                        *
**************************************************************************
STRLNCO
	MOVI	DMAWNZ|M_NOSCROLL,A4
	MOVI	10000H,A14
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRCNCO - PRINT STRING WITH:						 *
* 		 CENTER JUSTIFY, NORMAL, INSERT ON OBJECT LIST	 	 *
* 		 NO CONSTANT SUBSTITUTE					 *
* TRASHES A4 & A14							 *
*                                                                        *
**************************************************************************
STRCNCO:
	MOVI	DMAWNZ|M_NOSCROLL,A4
	MOVI	10001H,A14
	JRUC	STRINGER

**************************************************************************
*								         *
* 	SHADOW ROUTINES -- IDENTICAL TO ABOVE EXCEPT YOU HAVE TO TACK	 *
* 	AN "S" ON THE END OF THE ROUTINE NAME				 *
*								         *
**************************************************************************

STRLNRMS
	MOVI	DMACNZ,A4
	MOVI	8000H,A14
	JRUC	STRINGER

STRCNRMS
	MOVI	DMACNZ,A4
	MOVI	8001H,A14
	JRUC	STRINGER

STRRNRMS
	MOVI	DMACNZ,A4
	MOVI	8002H,A14
	JRUC	STRINGER

STRCNRMOS
	MOVI	DMACNZ|M_NOSCROLL,A4
	MOVI	18001H,A14
	JRUC	STRINGER

**************************************************************************
*                                                                        *
* STRINGER - OUTPUT A TEXT STRING, THIS IS A PROCESS!			 *
* A14 = FLAGS - INSERT:JUSTIFY						 *
*	BIT 16 = 1 INSERT ON OBJECT LIST, 0 JUST QUEUE THE DMA		 *
*	BIT 15 = 1 SHADOW THE CHARACTERS THAT GET KICKED OUT, TOO	 *
*	JUSTIFY = 0 LEFT JUSTIFY					 *
*		  1 CENTER JUSTIFY					 *
*		  2 RIGHT JUSTIFY					 *
*                                                                        *
* NOTE: CALL WITH JSRP							 *
**************************************************************************
STRINGER
	CLR	B0
	MOVE	B0,@STRING_UNDERLINE,W	; CLEAR OUT UNDERLINING
	BTST	15,A14
	JRZ	STRINGER_NOSHAD
	MOVK	1,B0
STRINGER_NOSHAD
	MOVE	B0,@STRING_SHADOW,W
	CALLR	SPACING		;CALCULATE THE SPACING FOR THIS FONT

	MOVE	A9,A3		;KEEP INITIAL POSITION FOR NEWLINES

	CALLR	JUSTIFY		;JUSTIFY THE POSITION CORRECTLY

	.IF YUNIT
	CLR	A7
	MOVX	A5,A7
	CMPI	0F0FH,A7	;ARE WE ALREADY ADJUSTED?
	JRHI	STRINGR2	;BR = YES!
	SLL	4,A7		;DO THE YUNIT SHUFFLE
	MOVX	A7,A5
	.ENDIF

STRINGR2
	MOVB	*A8,A7		;GET A CHARACTER
	SLL	24,A7
	SRL	24,A7		;MAKE SURE WE'RE POSITIVE
	JREQ	STRINGRX	;BR = STRING BE GONE BROTHA
	ADDK	8,A8		;NEXT BYTE
	CLR	B0		; NOT A SPACE, YET

	CMPI	' ',A7
	JRHI	STRNCHAR	;BR = IT'S KOSH BABY 
	JRLO	STRNCONT	;AHHHH SO VEE HAF CONTROLLL

	CLR	A7
	MOVE	A9,B2		; SAVE IT AWAY
	MOVX	A6,A7		;ADD X SPACE
	ADDXY	A7,A9		;AND ADD IT IN
	ADDXY	A10,A9		;ADD SPACING

	MOVE	@STRING_UNDERLINE,B1	; CHECK FOR UNDERLINE
	JRZ	STRINGR2	; NOPE -- DON'T DO ANYTHING
	MOVE	B2,B0	
	MOVE	A9,B2
	MOVE	B0,A9		; SWAP THE LOCATIONS
	MOVK	1,B0
	MOVI	'A',A7		; SET TO AN 'A' FOR APPEARANCES
	JRUC	STRNCHAR	; PROCESS IT

*
*CHECK HERE FOR CONTROL CHARACTERS
*
STRNCONT:
	CMPI	NEW_SLEEP,A7
	JRNE	STRCC1
	MOVE	*A8+,A0,W	;NEW SLEEP TIME
	JRUC	STRINGR2
STRCC1:
	CMPI	NEW_PCOLOR,A7
	JRNE	STRCC2
	MOVE	*A8+,A1,W	;NEW PRINT COLOR
	SLL	16,A1
	MOVY	A1,A5		;THE CORRECT POSITION PLEASE
	JRUC	STRINGR2
STRCC2:
	CMPI	NEW_CONTROL,A7
	JRNE	STRCC3
	MOVE	*A8+,A4,W	;NEW DMA FLAGS
	JRUC	STRINGR2	
STRCC3:
	CMPI	NEW_FONT,A7
	JRNE	STRCC4
	MOVE	*A8+,A11,L	;NEW FONT
	CALLR	SPACING		;RE-CALCULATE SPACING FOR THIS FONT
	JRUC	STRINGR2
STRCC4:
	CMPI	NEW_XY,A7
	JRNE	STRCC5
	MOVE	*A8+,A9,L	;NEW POSITION
	JRUC	STRINGR2
STRCC5:
	CMPI	NEW_SPACING,A7
	JRNE	STRCC6
	MOVE	*A8+,A10,L	;NEW SPACING
	JRUC	STRINGR2
STRCC6:
	CMPI	ASCII_CR,A7
	JRNE	STRCC7
	MOVE	A3,A9		;GET BACK TO WHERE YOU ONCE BELONGED
	CLR	A7
	MOVY	A6,A7
	ADDXY	A7,A9		;NEXT LINE DOWN
	MOVE	A9,A3		;STORE THIS POSITION
	CALLR	JUSTIFY		;AND REJUSTIFY YOUR POSITION
	JRUC	STRINGR2
STRCC7:
	CMPI	ADD_DYDX,A7
	JRNE	STRCC8
	MOVE	*A8+,A1,L	;GET DELTAS
	ADDXY	A1,A9		;AND ADD THEM
	JRUC	STRINGR2
STRCC8:
	CMPI	NEW_PALETTE,A7
	JRNE	STRCC9
	MOVE	A0,A1
	MOVE	*A8+,A0,L	;GET PALETTE I.D.
	CALLA	FINDPAL		;FIND IT'S SPOT		
	MOVX	A0,A5
	MOVE	A1,A0
	JRUC	STRINGR2
STRCC9:
	CMPI	UNDERLINE_ON,A7		; UNDERLINING TURNED ON?
	JRNE	STRCC10
	MOVK	1,B0
	MOVE	B0,@STRING_UNDERLINE,W
	JRUC	STRINGR2	

STRCC10:
	CMPI	UNDERLINE_OFF,A7
	JRNE	STRCC11
	CLR	B0
	MOVE	B0,@STRING_UNDERLINE,W
	JRUC	STRINGR2

STRCC11:
*ADD NEW CONTROL CHARACTERS HERE
	JRUC	STRINGR2

*OUTPUT A CHARACTER
STRNCHAR:
	MMTM	SP,A0,A2,A3,A4,A6,A10,A14

	MOVE	A11,A1		;ESCAPE TO THE OTHER SIDE

	SUBI	21H,A7		;GET A BASE
	SLL	5,A7
	ADD	A7,A1
	MOVE	*A1,A1,L	;LOAD THE ADDRESS OF THE IMAGE HEADER
	CALLA	GSAGOF
	CALLA	GANIOF
	
	BTST	16,A14
	JREQ	STRNQDMA	;BR = DO NORMAL DMA OF STRING

*CREATE THE CHARACTER AS AN OBJECT, HERE

	CALLA	GETOBJ
	JREQ	STRNGDUN	;BR = NO OBJECT
	MOVE	A1,*A0(OIMG),L
	MOVE	A5,*A0(OPAL),L
	MOVE	A0,A14
	ADDI	OSIZE+20H,A14	
	MMTM	A14,A2,A3,A4	;STUFF VITAL SHIT
	CLR	A14
	ADDI	OZVEL+20H,A0
	MOVK	6,A4
STRNGOL
	MOVE	A14,-*A0,L
	DSJS	A4,STRNGOL		;ZERO OUT THE VELS & POSITIONS
	SUBI	64,A0			;BACK TO NORMAL
	MOVI	TEXTOID,A14
	MOVE	A14,*A0(OID),W		;STUFF A FINDABLE I.D.
	MOVE	A9,A14
	SRL	16,A6
	MOVY	A7,A6
	SUBXY	A6,A14			;ADJUST FOR ANIMATION POINT
	MOVE	A14,*A0(OXPOS),W
	SRL	16,A14
	MOVE	A14,*A0(OYPOS),W	;STUFF POSITIONS
	MOVI	7FFF000AH,A14
	MOVE	A14,*A0(OZVAL),L	
	MOVE	*A0(OFLAGS),A4,W
	BTST	B_NOSCROLL,A4		;IS THIS GUY A SCROLLING STRING?
	JRNE	STRN_NOWC		;BR = NO, SKIP WORLD COORDS.
	CALLA	ADJSTWTL		;PUT US IN THE WORLD
STRN_NOWC:
	MOVE	B0,B0
	JRNZ	STRN_NO_INS_OBJECT
	CALLA	INSOBJ			;STUFF THIS SHEEEEEEET
STRN_NO_INS_OBJECT
;
;	CHECK FOR UNDERLINING
;
	MOVE	@STRING_UNDERLINE,A14,W
	JRZ	STR_NO_UNDERLINE_OBJECT
	CMPI	RD7FONT,A11		; ONLY UNDERLINES 7 POINT
	JRNZ	STR_NO_UNDERLINE_OBJECT
	PUSH	A0			; SAVE OBJECT FOR SHADOWING
	PUSH	A8			; SAVE TEXT POINTER
	MOVE	A0,A14
	CALLA	GETOBJ
	JRZ	STR_OBJ_UNDERLINE_DONE
	MOVE	A14,A8			; OBJECT TO COPY
	CALLA	COPY_OBJ		; DUPE THE OLD OBJECT
	MOVE	A0,A8
	MOVI	FONT8UNDERLINE,A1
	MOVI	DMACAL,A4		; CONSTANT
	CALLA	ANI			; PRESTO
	MOVE	*A8(OXPOS),A14,W
	SUBK	1,A14
	MOVE	A14,*A8(OXPOS),W
	MOVE	B0,B0			; CHECK TO SEE IF IT IS A SPACE
	JRNZ	STR_OBJ_UNDERLINE_DONE
	CALLA	INSOBJ			; GET IT UP
STR_OBJ_UNDERLINE_DONE
	PULL	A8			; RESTORE TEXT POINTER
	PULL	A0			; GRAB OBJECT BACK FOR SHADOWING
STR_NO_UNDERLINE_OBJECT
;
;	CHECK FOR SHADOWING
;
	MOVE	@STRING_SHADOW,A14,W
	JRZ	STR_NO_SHADOW_OBJECT
	MOVE	A0,A14			; ORIGINAL OBJECT
	CALLA	GETOBJ
	JREQ	STRNGDUN		; BR = COULDN'T GET AN OBJECT
	PUSH	A8			; GOTTA PRESERVE A8, DUDES!
	MOVE	A14,A8
	CALLA	COPY_OBJ		; DUPE THE OLD OBJECT
	MOVK	2,A8			; ASSUME [2,2] OFFSET
	CMPI	RD5FONT,A11
	JRZ	STRN_SPAC1
	CMPI	RD7FONT,A11		; 7 PT FONT GETS [1,1] OFFSET
	JRNZ	STRN_SPAC2
STRN_SPAC1
	MOVK	1,A8
STRN_SPAC2
	MOVE	*A0(OXPOS),A14,W
	ADD	A8,A14
	MOVE	A14,*A0(OXPOS),W
	MOVE	*A0(OYPOS),A14,W	; STUFF POSITIONS
	ADD	A8,A14
 	MOVE	A14,*A0(OYPOS),W	; STUFF POSITIONS
	MOVI	7FFF0009H,A14		; JUST UNDER THE REAL THING
	MOVE	A14,*A0(OZVAL),L	; PUT IT UNDER REGULAR STUFF
	MOVI	TROG_PBLACK,A14
	MOVE	A14,*A0(OPAL),L
	BTST	B_NOSCROLL,A4		;IS THIS GUY A SCROLLING STRING?
	JRNE	SHAD_STRN_NOWC		;BR = NO, SKIP WORLD COORDS.
	CALLA	ADJSTWTL		;PUT US IN THE WORLD
SHAD_STRN_NOWC:
	CALLA	INSOBJ
	PULL	A8

STR_NO_SHADOW_OBJECT:
	JRUC	STRNGDUN

*SIMPLY DMA THE SUCKER, HERE
STRNQDMA
	MOVE	A1,A10
	MOVE	A5,A1		;CONSTANT:PALETTE
	MOVE	A4,A5		;OFFSET:CONTROL
	MOVE	A3,A4		;SAG

	MOVE	A9,A3
	SRL	16,A6
	MOVY	A7,A6
	SUBXY	A6,A3		;ANIMATION PNT ADJUSTED DAG

	MOVE	@STRING_SHADOW,A14,W
	JRZ	NO_DMA_SHADOW
	MMTM	SP,A1,A3
	MOVI	TROG_PBLACK,A1		; BLACK OUT OF DUXPAL
	ADDI	[1,1],A3		; [1,1] FOR THE 7 PT FONT
	CMPI	RD5FONT,A11
	JRZ	STRNQD_SPAC1
	CMPI	RD7FONT,A11
	JRZ	STRNQD_SPAC1
	ADDI	[1,1],A3		; ANOTHER FOR THE BIGGER FONTS
STRNQD_SPAC1
	CALLA	DMAN
	MMFM	SP,A1,A3
NO_DMA_SHADOW
	MOVE	B0,B0			; CHECK FOR SPACE
	JRNZ	DMA_SPACE
	CALLA	DMAN
DMA_SPACE
;
;	CHECK FOR UNDERLINING
;
	MOVE	@STRING_UNDERLINE,A14,W
	JRZ	NO_DMA_UNDERLINE
	PUSH	A1
	MOVI	FONT8UNDERLINE,A1
	MOVI	DMACAL,A4
	CALLA	GSAGOF
	CALLA	GANIOF
	PULL	A1
	MOVE	A4,A5		;OFFSET:CONTROL
	MOVE	A3,A4		;SAG
	MOVE	A9,A3
	SRL	16,A6
	MOVY	A7,A6
	SUBXY	A6,A3		;ANIMATION PNT ADJUSTED DAG
	SUBK	1,A3		; SHIFT OVER 1 MORE
	CALLA	DMAN
NO_DMA_UNDERLINE
	MOVE	A1,A5
	MOVE	A10,A1
STRNGDUN
	MOVE	B0,B0		; CHECK TO SEE IF CHAR IS A SPACE
	JRZ	STRNG_DUN_NO_SPACE
	MOVE	B2,A9		; SETUP THE NEW SPACING
	MMFM	SP,A2,A3,A4,A6,A10,A14
	JRUC	STRNG_BYPASS_1
STRNG_DUN_NO_SPACE
	MOVE	*A1(ISIZE),A6,W	;GET THE VISIBLE HORIZONTAL SIZE
	ADDXY	A6,A9		;GET TO THE OTHER SIDE OF THE CHARACTER

	MMFM	SP,A2,A3,A4,A6,A10,A14
	ADDXY	A10,A9		;ADD IN SPACING
STRNG_BYPASS_1
	MOVE	*SP+,A0,L
	JREQ	STRINGR2	;BR = NO SLEEP
	MMTM	A12,A0,A3,A4,A5,A6,A14
	CALLA	PRCSLP
	MMFM	A12,A0,A3,A4,A5,A6,A14
	JRUC	STRINGR2
STRINGRX
	ADDK	8,A8		;GET TO THE NEXT BYTE
	MOVE	A5,A6
	SRL	16,A6		;RETURN THE COLOR CORRECTLY
	RETP

**************************************************************************
*                                                                        *
* 	END OF PRINT ROUTINES.						 *
*                                                                        *
**************************************************************************

**************************************************************************
*                                                                        *
* 	PRINT FORMAT AND UTILITY ROUTINES				 *
*                                                                        *
**************************************************************************
*
*NULL STRING FOR DUMMIES
*
DUMSTRNG .WORD	0
*
*EQUATES FOR STRINGF
B_LJUSTIFY	EQU	0		;LEFT JUSTIFY WITHIN FIELD
B_CJUSTIFY	EQU	1		;CENTER JUSTIFY WITHIN FIELD
B_PSIGN		EQU	2		;PRINT SIGN IF SIGNED
B_COMMAS	EQU	3		;PRINT COMMAS
B_PHEX		EQU	4		;PRINT HEX PREFIX
B_ZPRINT	EQU	5		;FILL UNUSED WIDTH WITH ZEROS
B_SIGNED	EQU	6		;THIS VALUE IS OF SIGNED TYPE
B_CAP		EQU	7		;USE CAPITAL LETTERS FOR HEX DIGITS
*
*SIZE EQUATES
TYPE_SHORT	EQU	8
TYPE_INT	EQU	16
TYPE_LONG	EQU	32
**************************************************************************
*                                                                        *
* STRINGF - STRING FORMAT ROUTINE.					 *
* 	  SEE "ASCII Character String Definition" AT THE TOP OF FILE.	 *
* A8 = PTR TO STRING TO FORMAT.						 *
* RETURNS:								 *
* A3 = PTR TO .EVEN WORD AFTER THE LAST ARGUMENT OF THE STRING		 *
* A8 = PTR TO FORMATTED STRING						 *
* NOTE: TRASHES A14							 *
*                                                                        *
**************************************************************************
STRINGF:
	CLRM	@SFINDEX,W	;CLEAR THE STRING BUILD MEMORY INDEX
STRINGF_RECURSE:		;RECURSION ENTRY POINT
	MMTM	SP,A0,A1,A2,A4,A5,A6,A7
	MOVE	@SFINDEX,A7,W	;GET THE INDEX OF THE NEXT BUFFER TO USE
	CMPI	NUMSFBUFS,A7
	JRLO	SFALLOC		;MORE BUFFERS TO BE HAD
	MOVI	DUMSTRNG,A8	;POINT TO A NULL STRING WHEN OUT OF MAMMARY
	JRUC	STRINGFX
*ALLOCATE A BUFFER IN WHICH TO BUILD THE STRING
SFALLOC
	INCM	@SFINDEX,W	;INCREMENT THE INDEX FOR NEXT MAM GRAB
	MOVI	SFBUFSIZE,A0
	MPYU	A0,A7		;OFFSET TO NEW ARRAY	
	ADDI	STRINGF_RAM,A7	;ADD OFFSET, A7 POINTS TO OUR BUILD SPACE
	MOVE	A7,A5		;STORE PTR TO BOS HERE
	MOVE	A8,A6
SFARGLP:
	MOVB	*A6,A0		;FIND THE ARGUMENT LIST
	ADDK	8,A6		;AND PNT A6 AT IT
	MOVE	A0,A0
	JRNZ	SFARGLP		;SEARCHING FOR NULL TERMINATOR
	ADDK    0FH,A6		;DO OUR OWN .EVEN TO MATCH ASSEMBLER
	SRL	4,A6
	SLL	4,A6		;MASK FRACTIONAL WORD
SFBUILDLP:
	CALLR	GETCHAR
	JRNC	SFBUILDCH	;WE RECIEVED A NORMAL CHARACTER
	MOVB	A0,*A7		;PASS THE CONTROL
	ADDK	8,A7
SFBUILDARG:
	MOVE	A1,A1
	JRZ	SFBUILDLP	;FINISHED
	MOVB	*A8,*A7
	ADDK	8,A8
	ADDK	8,A7		;TRANSFER ARGS
	DEC	A1		;DEC ARG COUNT
	JRUC	SFBUILDARG
SFBUILDCH:
	BTST	7,A0		; CHECK THE HIGH BIT
	JRZ	SFVALIDCH
	MOVE	A8,A1		; SAVE IT AWAY
	CALLA	DICT_LOOKUP	; LOOKUP THE WORD IN A0
	JRNZ	SFA8TOA7	; IF THERE IS SOMETHING, USE IT	
	MOVE	A1,A8		; IF BAD RETURN
SFVALIDCH
	CMPI	'%',A0
	JRNE	SFCONTROL	;NOT A FORMAT CHARACTER, HOW ABOUT CONTROL
*PARSE STRINGF FORMAT SPECIFIER HERE
	CALLR	GETCHARI	;NO SPECIAL CHARACTERS ALLOWED IN FORMAT
	CMPI	'%',A0
	JREQ	SFXFER		;JUST PRINT A PERCENT SIGN

	CALLR	FFLAGS		;GET THE FORMAT FLAGS IF THERE ARE ANY
	CALLR	FWIDTH		;GET FORMAT WIDTH NEXT
	CALLR	FTYPE		;GET THE FORMAT TYPE
SFTYPE_LP:
	CMPI	's',A0		;SEE IF IT'S A STRING
	JRNE	SFTYPE0
	MOVE	A8,A1		;STORE A8
	MOVE	*A6+,A8,L	;GET THE ADDRESS OF THE STRING(ALWAYS LONG)
	CALLR	STRINGF_RECURSE
	JRUC	SFA8TOA7	;TRANSFER THE NEW #	
SFTYPE0:
	CMPI	'p',A0		;SEE IF IT'S A POINTER TO A STRING
	JRNE	SFTYPE1
	MOVE	A8,A1		;STORE A8
	MOVE	*A6+,A8,L	;GET THE PTR TO THE STRING(IT'S ALWAYS LONG)
	MOVE	*A8,A8,L	;NOW GET THE ADDRESS
	CALLR	STRINGF_RECURSE
	JRUC	SFA8TOA7	;TRANSFER THE NEW #	
SFTYPE1:
	MOVE	A8,A1		;SAVE A8
	CALLR	GETARGI
	CMPI	'b',A0
	JRNE	SFTYPE5		;BCD
	CALLR	BCD_TO_ASCII_DEC	;CONVERT
	JRUC	SFA8TOA7
SFTYPE5:
	CMPI	'd',A0		;SIGNED DECIMAL
	JRNE	SFTYPE6
	BSET	B_SIGNED,A4
	CMPI	TYPE_INT,A2	;SIGN EXTEND LITTLE BROTHER
	JRNE	SFTYPE5A
	SEXT	A8
	JRUC	SFTYPE5B
SFTYPE5A:
	CMPI	TYPE_SHORT,A2	;AND THE YOUNGEST
	JRNE	SFTYPE5B
	SLL	24,A8	
	SRA	24,A8
SFTYPE5B:
	CALLR	HEX_TO_ASCII_DEC	;CONVERT
	JRUC	SFA8TOA7
SFTYPE6:
	CMPI	'u',A0		;UNSIGNED DECIMAL
	JRNE	SFTYPE7
	CALLR	HEX_TO_ASCII_DEC
	JRUC	SFA8TOA7
SFTYPE7:
	CMPI	'x',A0 		;UNSIGNED HEXADECIMAL WITH 'abcdef'
	JRNE	SFTYPE8
	CALLR	HEX_TO_ASCII_HEX
	JRUC	SFA8TOA7
SFTYPE8:
	CMPI	'X',A0		;UNSIGNED HEXADECIMAL WITH 'ABCDEF'
	JRNE	SFTYPE9
	BSET	B_CAP,A4
	CALLR	HEX_TO_ASCII_HEX
	JRUC	SFA8TOA7
SFTYPE9:
	CMPI	'c',A0		;SINGLE CHARACTER
	JRNE	SFTYPE10
	MOVB	A8,*A7
	ADDK	8,A7
	MOVE	A1,A8
	JRUC	SFBUILDLP
SFTYPE10:
*ADD NEW type SPECIFIERS HERE
	JRUC	SFBUILDLP
*TRANSFER NEW FORMAT STRING TO THE STRING WE ARE BUILDING
SFA8TOA7:
	MOVB	*A8,A0
	JRZ	SFA8A7DONE
	ADDK	8,A8	
	MOVB	A0,*A7	
	ADDK	8,A7
	JRUC	SFA8TOA7
SFA8A7DONE:
	MOVE	A1,A8
	JRUC	SFBUILDLP
*
*CHECK FOR A CONTROL CHARACTER
SFCONTROL:
	CMPI	'\',A0
	JRNE	SFXFER		;JUST ANOTHER CHARACTER
	CALLR	GETCHARI	;NOW GET THE CONTROL CHARACTER
	CMPI	'\',A0
	JREQ	SFXFER		;OH! HE WANTS TO PRINT THIS
	CLR	A3		;ASSUME NO INDIRECTION
	CMPI	'*',A0		;IS THERE INDIRECTION HERE?
	JRNE	SFCONTROL_IMM	;BR = NO
	MOVK	1,A3		;CONTROL INDIRECT FLAG
	CALLR	GETCHARI	;THIS TIME GET THE CONTROL CHARACTER FOR REAL!

SFCONTROL_IMM:
	CMPI	'a',A0
	JRNE	SFC1
	MOVI	NEW_SLEEP,A0	;NEW SLEEP TIME
	MOVI	TYPE_INT,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC1:
	CMPI	'b',A0
	JRNE	SFC2
	MOVI	NEW_PCOLOR,A0	;NEW PRINT COLOR
	MOVI	TYPE_INT,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC2:
	CMPI	'c',A0
	JRNE	SFC3
	MOVI	NEW_CONTROL,A0	;NEW DMA CONTROL WORD
	MOVI	TYPE_INT,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC3:
	CMPI	'd',A0
	JRNE	SFC4
	MOVI	NEW_FONT,A0	;NEW FONT
	MOVI	TYPE_LONG,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC4:
	CMPI	'e',A0
	JRNE	SFC5
	MOVI	NEW_XY,A0	;NEW [Y,X] CURSOR POSITION
	MOVI	TYPE_LONG,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC5:
	CMPI	'i',A0
	JRNE	SFC6
	MOVI	NEW_SPACING,A0	;NEW SPACING
	MOVI	TYPE_LONG,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC6:
	CMPI	'n',A0
	JRNE	SFC7
	MOVI	ASCII_CR,A0	;NEWLINE
	JRUC	SFXFER
SFC7:
	CMPI	'f',A0
	JRNE	SFC8
	MOVI	ADD_DYDX,A0	;ADD [DY,DX]
	MOVI	TYPE_LONG,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC8:
	CMPI	'p',A0
	JRNE	SFC9
	MOVI	NEW_PALETTE,A0	;USE A NEW PALETTE
	MOVI	TYPE_LONG,A2
	CALLR	PUTCARG		;GET THE CONTROL ARG
	JRUC	SFBUILDLP
SFC9:
	CMPI	'u',A0		; UNDERLINING ACTIVATED?
	JRNE	SFC10
	MOVI	UNDERLINE_ON,A0
	JRUC	SFXFER
SFC10:
	CMPI	'v',A0		; UNDERLINING DE-ACTIVATED?
	JRNE	SFC11
	MOVI	UNDERLINE_OFF,A0
	JRUC	SFXFER
SFC11:
*ADD NEW CONTROL CHARACTERS HERE
	JRUC	SFBUILDLP
SFXFER:
	MOVB	A0,*A7
	ADDK	8,A7
	MOVE	A0,A0
	JRNZ	SFBUILDLP	;ADD ON ANOTHER CHARACTER
*STRING IS DONE
	MOVE	A5,A8		;PASS BACK THE PTR TO THE NEW
	DECM	@SFINDEX,W	;FREE THIS BUFFER
STRINGFX
	MOVE	A6,A3		;RETURN END
	MMFM	SP,A0,A1,A2,A4,A5,A6,A7
	RETS

**************************************************************************
*                                                                        *
* JUSTIFY - JUSTIFY THE STRING STARTING POINT FROM THE GIVEN POSITION	 *
* 	  BASED ON THE JUSTIFICATION BYTE				 *
* A8 = PTR TO STRING							 *
* A9 = STRING POSITION							 *
* A14 = JUSTIFICATION BYTE						 *
* 		0 = LEFT						 *
* 		1 = CENTER						 *
* 		2 = RIGHT						 *
* RETURNS:								 *
* A9 = JUSTIFIED STARTING POSITION					 *
*                                                                        *
**************************************************************************
JUSTIFY:
	PUSH	A7
	CLR	A7
	MOVX	A14,A7
	SLL	30,A7
	SRL	30,A7		; MASK OFF THE SHADOW BIT
	DEC	A7
	JRN	JUSTIFYX	;NORMAL LEFT JUSTIFY
	JREQ	JUSTIFYC	;CENTER JUSTIFY
*RIGHT JUSTIFY
	CALLR	STRNGLEN	;GET THE STRING LENGTH
	JRUC	JUSTIFYA
*CENTER JUSTIFY
JUSTIFYC:
	CALLR	STRNGLEN
	SRL	1,A7		;STRNGLEN/2
JUSTIFYA:
	SUBXY	A7,A9		;ADJUST STRING STARTING POSITION
JUSTIFYX:
	PULL	A7
	RETS

**************************************************************************
*                                                                        *
* SPACING - CALCULATE SPACING FOR THIS FONT				 *
* A11 = PTR TO CURRENT FONT TABLE					 *
* RETURNS:								 *
* A6 = [Y,X] SPACING							 *
*                                                                        *
**************************************************************************
SPACING:
	PUSH	A7
	MOVI	'H' - 21H,A6	;USE 'H' FOR SPACE AND NEWLINE STUFF
	SLL	5,A6
	ADD	A11,A6
	MOVE	*A6,A6,L	;LOAD THE ADDRESS OF THE IMAGE HEADER
	MOVE	*A6(ISIZE),A6,L	;GET THE VISIBLE SIZE OF 'H'
	MOVY	A6,A7
	ZEXT	A6
	SRL	1,A6		;(X SIZE OF 'H')/2 = X SPACING
	MOVY	A7,A6
	SRL	17,A7
	SLL	16,A7
	ADDXY	A7,A6		;(Y SIZE OF 'H') + (Y SIZE OF 'H')/2 = Y SPACE
	PULL	A7
	RETS

**************************************************************************
*                                                                        *
* FFLAGS - PARSE THE FORMAT flags (IF THERE ARE ANY).			 *
* 	 SETS THE APPROPRIATE BITS IN THE FLAG REGISTER.		 *
* A0 = CURRENT CHARACTER FROM STRING					 *
* A8 = PTR TO STRING AFTER *A0						 *
* RETURNS:								 *
* A0 = NEXT CHARACTER AFTER flags OR SAME IF NO flags PRESENT		 *
* A4 = FLAG REGISTER WITH APPROPRIATE BITS SET OR CLEARED		 *
* A8 = PTR TO NEXT CHARACTER     					 *
* NOTE: TRASHES A14							 *
*                                                                        *
**************************************************************************
FFLAGS:
	CLR	A4		;CLEAR FLAG REGISTER TO START
FFLAG_LP:
	CMPI	'-',A0		;CHECK FOR LEFT JUSTIFY FLAG
	JRNE	FFLAGP1
	BSET	B_LJUSTIFY,A4
	BCLR	B_CJUSTIFY,A4
	JRUC	FFLAG_NXT
FFLAGP1:
	CMPI	'^',A0		;CHECK FOR CENTER JUSTIFY FLAG
	JRNE	FFLAGP2
	BSET	B_CJUSTIFY,A4
	BCLR	B_LJUSTIFY,A4
	JRUC	FFLAG_NXT
FFLAGP2:
	CMPI	'+',A0		;CHECK FOR PRINT SIGN FLAG
	JRNE	FFLAGP3
	BSET	B_PSIGN,A4
	JRUC	FFLAG_NXT
FFLAGP3:
	CMPI	',',A0		;CHECK FOR COMMA FLAG
	JRNE	FFLAGP4
	BSET	B_COMMAS,A4
	JRUC	FFLAG_NXT
FFLAGP4:
	CMPI	'#',A0		;CHECK FOR HEX PREFIX FLAG
	JRNE	FFLAGP5
	BSET	B_PHEX,A4
	JRUC	FFLAG_NXT
FFLAGP5:
*ADD NEW FLAGS HERE
	JRUC	FFLAGX
FFLAG_NXT:
	CALLR	GETCHARI
	JRUC	FFLAG_LP
FFLAGX
	RETS

**************************************************************************
*                                                                        *
* FWIDTH - GRAB THE FORMAT width FROM THE CURRENT STRING (IF PRESENT).	 *
* 	 SETS ZPRINT FLAG IS FLAG REGISTER IF NECESSARY			 *
* A0 = CURRENT CHARACTER FROM STRING					 *
* A4 = FLAG REGISTER							 *
* A8 = PTR TO STRING AFTER *A0						 *
* RETURNS:								 *
* A0 = NEXT CHARACTER AFTER width OR SAME IF NO width PRESENT		 *
* A3 = width , 0 = NO width SPECIFIED					 *
* A4 = FLAG REGISTER WITH ZPRINT FLAG SET IF NECESSARY			 *
* A8 = PTR TO NEXT CHARACTER          					 *
*                                                                        *
**************************************************************************
FWIDTH:
	PUSH	A1
	MOVK	10,A1		;DECIMAL MULTIPLIER
	CLR	A3		;FIELD width WILL BE HERE
	CMPI	'0',A0		;CHECK FOR LEADING ZERO PRINT FLAG
	JRNE	FWIDTH_LP
	BSET	B_ZPRINT,A4
	CALLR	GETCHARI	;GET THE NEXT
FWIDTH_LP:
	CMPI	'0',A0
	JRLT	FWIDTHX		;NOT A NUMBER
	CMPI	'9',A0
	JRGT	FWIDTHX		;NOT A NUMBER
	SUBI	'0',A0		;ASCII TO DECIMAL
	MPYU	A1,A3		;UP IT BY 10
	ADD	A0,A3		;AND ADD IN THE NEW
	CALLR	GETCHARI
	JRUC	FWIDTH_LP
FWIDTHX
	PULL	A1
	RETS

**************************************************************************
*                                                                        *
* FTYPE - RETURN THE FORMAT TYPE, I.E. SHORT, INT OR LONG.		 *
* A0 = PTR TO CURRENT CHARACTER TO CHECK				 *
* A8 = PTR TO STRING THAT IS BEING FORMATTED				 *
* RETURNS:								 *
* A0 = NEXT CHARACTER TO PROCESS AFTER type OR SAME IF NO TYPE SPECIFIED *
* A8 = PTR TO NEXT CHARACTER						 *
* DEFAULT RETURN IS INT							 *
*                                                                        *
**************************************************************************
FTYPE:
	MOVK	TYPE_INT,A2
FTYPE_LP:
	CMPI	'h',A0			;CHECK FOR TYPE SHORT
	JRNE	FTYPEP1
	MOVK	TYPE_SHORT,A2
	JRUC	FTYPE_NXT
FTYPEP1:
	CMPI	'l',A0			;CHECK FOR TYPE LONG
	JRNE	FTYPEP2
	MOVK	TYPE_LONG,A2
	JRUC	FTYPE_NXT
FTYPEP2:
	CMPI	'L',A0			;CHECK FOR TYPE LONG
	JRNE	FTYPEP3
	MOVK	TYPE_LONG,A2
	JRUC	FTYPE_NXT
FTYPEP3:
*ADD NEW TYPE HERE
	JRUC	FTYPEX
FTYPE_NXT:
	CALLR	GETCHARI
	JRUC	FTYPE_LP
FTYPEX
	RETS

**************************************************************************
*                                                                        *
* GETCHAR - GET NEXT CHARACTER FROM A STRING.				 *
* 	  MASKS THE HIGH 24 BITS OF THE LONG WORD.			 *
* A8 = PTR STRING							 *
* RETURNS:								 *
* 	C = CONTROL BYTE, ARGS FOLLOW, A1 = # OF BYTE ARGUMENTS		 *
*      NC = NORMAL CHARACTER OR TERMINATOR.				 *	
*	Z = BYTE IS A TERMINATOR					 *
* A0 = CHARACTER							 *
* A8 = PTR TO NEXT							 *
*                                                                        *
**************************************************************************
GETCHAR:
	MOVB	*A8,A0
	SLL	24,A0
	SRL	24,A0		;MAKE SURE THIS NUMBER IS POSITIVE
	ADDK	8,A8		;POINT TO NEXT CHARACTER
	CMPI	0,A0
	JREQ	GETCHARX	;TERMINATOR
	CMPI	' ',A0
	JRNC	GETCHARX	;SAME AS JRHS
	MOVE	A0,A1	
	DEC	A1
	SLL	3,A1
	ADDI	CONTROL_TAB,A1
	MOVB	*A1,A1		;GET NUMBER OF BYTES
	SETC	
GETCHARX:
	MOVE	A0,A0
	RETS

*
*NUMBER OF ARGUMENT BYTES FOR CONTROL CHARACTER (1-1F)
CONTROL_TAB
	.BYTE	2,2,2,4,4,4,4,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	.EVEN

**************************************************************************
*                                                                        *
* GETCHARI - GET NEXT CHARACTER, SKIP COMMAND BYTES AND ARGUMENTS.	 *
* 	   USED WITH STRGNLEN, FFLAGS, FWIDTH, FTYPE, ETC.		 *
* A8 = PTR TO STRING							 *
* RETURNS:								 *
*  Z = CHARACTER IS A TERMINATOR					 *
* A0 = CHARACTER OR TERMINATOR						 *
* A8 = PTR TO NEXT							 *
*                                                                        *
**************************************************************************
GETCHARI:
	PUSH	A1
GETCHARI_LP:
	CALLR	GETCHAR	
	JRNC	GETCHARIX		;VALID CHARACTER OR TERMINATOR
	SLL	3,A1
	ADD	A1,A8			;SKIP ARGS
	JRUC	GETCHARI_LP
GETCHARIX:
	PULL	A1	
	RETS

**************************************************************************
*                                                                        *
* GETARGI - GET NEXT ARGUMENT INDIRECT IN THE ARGUMENT LIST.		 *
*	    NEXT ARG IS A LONG PTR TO ARGUMENT TYPE.			 *
* A2 = ARGUMENT TYPE, I.E. SHORT, INT OR LONG				 *
* A6 = PTR TO ARGUMENT							 *
* RETURNS:								 *
* A6 = PTR TO NEXT ARGUMENT						 *
* A8 = UNSIGNED ARGUMENT						 *
*                                                                        *
**************************************************************************
GETARGI:
	MOVE	*A6+,A8,L	;GET THE POINTER
	CMPI	TYPE_INT,A2	;GET THE VALUE FOR PRINTING NOW		
	JRNE	GETARG1	
	MOVE	*A8,A8,W	;AH AND INT
	ZEXT	A8
	JRUC	GETARGX
GETARG1:
	CMPI	TYPE_LONG,A2
	JRNE	GETARG2
	MOVE	*A8,A8,L	;IT'S VERY LONG
	JRUC	GETARGX
GETARG2:
	MOVB	*A8,A8		;ARE YOU SMALL? SMALL! HAH! LIKE FRENCH BREAD!
	SLL	24,A8
	SRL	24,A8		;ZEXTB A8
GETARGX:
	RETS

**************************************************************************
*								         *
* PUTCARG - GET THE CONTROL ARGUMENT FROM THE ARG LIST AND TRANSFER	 *
* 	CURRENT STRING UNDER CONSTRUCTION. FIRST IT WILL TRANSFER	 *
* 	THE CONTROL BYTE.						 *
* A0 = CONTROL BYTE							 *
* A2 = ARG TYPE								 *
* A3 = INDIRECTION FLAG, IF <> 0 THEN INDIRECT ARGUMENT			 *
* A7 = PTR TO LIST UNDER CONSTRUCTION					 *
* RETURNS:								 *
* A7 NEXT BYTE IN STRING						 *
* A0 & A2 PRESERVED							 *
* A3 IS TRASHED IF ARGUMENT IS INDIRECT					 *
*								         *
**************************************************************************
PUTCARG:
	MOVB	A0,*A7
	ADDK	8,A7
	MOVE	A3,A3		;SHOULD WE HANDLE INDIRECTION
	JRNE	PUTCARGI	;BR = YES
*GET ARGUMENT IMMEADIATELY
	CMPI	TYPE_INT,A2
	JRNE	PUTCLARG
	MOVE	*A6+,*A7+,W
	JRUC	PUTCARGX
PUTCLARG:
	MOVE	*A6+,*A7+,L	;ARGUMENT IS LONG
PUTCARGX:	
	RETS
*GET ARGUMENT VIA INDIRECTION
PUTCARGI:
	MOVE	*A6+,A3,L	;GET POINTER
	CMPI	TYPE_INT,A2
	JRNE	PUTCLARGI
	MOVE	*A3+,*A7+,W
	JRUC	PUTCARGX
PUTCLARGI:
	MOVE	*A3+,*A7+,L
	JRUC	PUTCARGX

**************************************************************************
*                                                                        *
* STRNGLEN - RETURNS THE LENGTH, IN PIXELS, OF A GIVEN STRING		 *
* A8 = PTR TO STRING							 *
* A10 = [Y,X] SPACING OF STRING						 *
* A11 = PTR TO FONT TABLE						 *
* RETURNS:								 *
* A7 = LENGTH OF STRING							 *
* Z BIT SET IF LENGTH IS ZERO						 *
*                                                                        *
**************************************************************************
STRNGLEN
	MMTM	SP,A0,A1,A2,A6,A8,A10
	CLR	A2
	MOVI	'H' - 21H,A6	;USE 'H' FOR SPACE
	SLL	5,A6
	ADD	A11,A6
	MOVE	*A6,A6,L	;LOAD THE ADDRESS OF THE IMAGE HEADER
	MOVE	*A6(ISIZE),A6,W	;GET THE VISIBLE SIZE OF 'H'
	SRL	1,A6		;(X SIZE OF H)/2 = X SPACING

STRNLEN:
	CALLR	GETCHAR
	JRZ	STRNLENX	;END O' STRING. FOR REAL!
	JRNC	STRNLEN0	;REAL CHARACTER

	CMPI	ASCII_CR,A0
	JREQ	STRNLENX	;O.K. THAT'S IT!
	CMPI	NEW_SPACING,A0
	JRNE	STRNLEN_SKIP
	MOVE	*A8+,A10,L	;GET THE NEW SPACING, 'CAUSE WE CARE
	JRUC	STRNLEN
STRNLEN_SKIP:
	SLL	3,A1
	ADD	A1,A8  		;SKIP ARGS
	JRUC	STRNLEN
STRNLEN0:
	CMPI	' ',A0 		;LOOK FOR A SPACE, MAN
	JRNE	STRNLEN1
	ADDXY	A6,A2		;ADD A SPACE
	JRUC	STRNLEN3
STRNLEN1:
	SUBI	21H,A0		;GET A BASE
	SLL	5,A0
	ADD	A11,A0		;A7 = PTR TO CORRECT CHARACTER HEADER
	MOVE	*A0,A0,L
	MOVE	*A0(ISIZE),A0,W	;GET THE ACTUAL X LENGTH
STRNLEN2
	ADDXY	A0,A2		;ADD DIGIT LENGTH
	MOVX	A10,A0
	ADDXY	A0,A2		;ADD SPACE LENGTH
STRNLEN3:
	JRUC	STRNLEN
STRNLENX
	MOVE	A2,A7		;PASS RETURN VALUE IN A7
	MMFM	SP,A0,A1,A2,A6,A8,A10
	RETS

**************************************************************************
*                                                                        *
* HEXTOASC - CONVERTS A 32 BIT HEX # TO AN ASCII STRING TERMINATED	 *
* 	   BY 0 WITH COMMAS.						 *
* A8 = HEX #								 *
* RETURNS:								 *
* A8 PTR TO THE STRING							 *
*                                                                        *
**************************************************************************
HEXTOASC
	MMTM	SP,A3,A4,A14
	CLR	A3
	CLR	A4
	BSET	B_COMMAS,A4
	CALLR	HEX_TO_ASCII_DEC
	MMFM	SP,A3,A4,A14
	RETS

**************************************************************************
*                                                                        *
* HEX_TO_ASCII_DEC - FORMAT A HEXADECIMAL # TO AN DECIMAL ASCII STRING.	 *
* 	     	     USES THE flags AND width IN A4 AND A3.		 *
* A3 = width, MINIMUM # OF CHARACTERS TO OUTPUT				 *
* A4 = flags, USES: B_COMMAS - PUT COMMAS IN THE NUMBER			 *
* 		    B_ZPRINT - IF width IS NOT REACHED, FILL WITH 0's	 *
* 			       NOT SPACES.				 *
*		    B_SIGNED - PASSED NUMBER IS SIGNED			 *
*		    B_PSIGN  - PRINT SIGN IF NUMBER IS OF SIGNED TYPE    *
* A8 = HEXADECIMAL #							 *
* RETURNS:								 *
* A8 = PTR TO STRING							 *
* A3 & A4 PRESERVED							 *
*                                                                        *
**************************************************************************
HEX_TO_ASCII_DEC:
	MMTM	SP,A1,A2,A3,A5,A9
	CLR	A5			;CLR NEGATIVE FLAG
	BTST	B_SIGNED,A4
	JREQ	HEXTNOS			;NOT A SIGNED NUMBER
	MOVE	A8,A8
	JRNN	HEXTNOS			;NOT A NEGATIVE NUMBER
	NEG	A8
	INC	A5
HEXTNOS:
	CLR	A1
	CLR	A2			;COMMA COUNT
	MOVE	A1,-*SP,W		;HERE'S THE NULL TERMINATOR
        MOVK	10,A1			;DIVISOR FOR DECIMAL
	MOVE	A8,A9
HEXTASC2
	CLR	A8
	DIVU	A1,A8
	ADDI	'0',A9			;MAKE THE REMAINDER ASCII
	MOVE	A9,-*SP,W		;SAVE HERE
	DEC	A3			;DECREMENT THE WIDTH
	MOVE	A8,A9
	JRZ	HEXTASC3		;BR = DONE!

	BTST	B_COMMAS,A4
	JREQ	HEXTASC2		;BR = DON'T WORRY ABOUT COMMAS

	INC	A2
	CMPI	3,A2			;COMMA CHECK 	
	JRLO	HEXTASC2		;BR = NO COMMA
	MOVI	',',A2
	MOVE	A2,-*SP,W		;STUFF A COMMA
	CLR	A2
	JRUC	HEXTASC2
HEXTASC3
	MOVE	A3,A3
	JRZ	HEXTASC3A		;WIDTH HAS BEEN FULFILLED
	JRN	HEXTASC3A		;THANX TI
	BTST	B_ZPRINT,A4
	JRNE	HEXTASC30		;YES, FILL width WITH ZEROS
	MOVI	' ',A2
	JRUC	HEXTASC31
HEXTASC30:
	MOVI	'0',A2
HEXTASC31:
	MOVE	A2,-*SP,W		;STUFF THE LEADER
	DSJS	A3,HEXTASC31
HEXTASC3A:
	BTST	B_SIGNED,A4
	JREQ	HEXTASC3D		;THIS IS NOT A SIGNED NUMBER
	MOVE	A5,A5
	JRNZ	HEXTASC3B		;NUMBER IS NEGATIVE
	BTST	B_PSIGN,A4
	JREQ	HEXTASC3D		;DOESN'T WANT THE SIGN PRINTED
	MOVI	'+',A2	
	JRUC	HEXTASC3C
HEXTASC3B:
	MOVI	'-',A2
HEXTASC3C:
	MOVE	A2,-*SP,W		;STUFF THE SIGN
HEXTASC3D
	MOVI	STRNGRAM,A1		;STORE HERE FOR BLOW OUT        
	MOVE	A1,A8
HEXTASC4
	MOVE	*SP+,A9,W
	MOVB	A9,*A1
	ADDK	8,A1
	MOVE	A9,A9
	JRNZ	HEXTASC4
	MMFM	SP,A1,A2,A3,A5,A9
	RETS

**************************************************************************
*                                                                        *
* HTOHXASC - CONVERT A 32 BIT HEXADECIMAL # TO A NULL TERMINATED	 *
* 	   HEXADECIMAL ASCII STRING. USES 'ABCDEF' AND NO Ox PREFIX	 *
* 	   OR COMMAS.							 *
* A8 = HEX #								 *
* RETURNS:								 *
* A8 = PTR TO ASCII HEX STRING						 *
*                                                                        *
**************************************************************************
HTOHXASC
	MMTM	SP,A3,A4,A14
	CLR	A3
	CLR	A4
	BSET	B_CAP,A4	
	CALLR	HEX_TO_ASCII_HEX
	MMFM	SP,A3,A4,A14
	RETS
	
**************************************************************************
*                                                                        *
* HEX_TO_ASCII_HEX - CONVERTS A 32 BIT HEX # TO A NULL TERMINATED	 *
* 		   ASCII STRING.					 *
* A3 = width, MINIMUM # OF CHARACTERS CONVERTED				 *
* A4 = flags, USES: B_COMMAS - PUT COMMAS IN THE NUMBER			 *
* 		  B_ZPRINT - IF width IS NOT REACHED, FILL WITH 0's	 *
* 			     NOT SPACES.				 *
* 		  B_CAP	   - USE 'ABCDEF'				 *
* 		  B_PHEX   - PREFIX WITH HEX SPECIFIER 0x OR 0X		 *
* A8 = HEX #								 *
* RETURNS:								 *
* A8 PTR TO THE STRING							 *
* A3 & A4 ARE PRESERVED							 *
*                                                                        *
**************************************************************************
HEX_TO_ASCII_HEX
	MMTM	SP,A1,A2,A3,A9
	CLR	A1
	CLR	A2			;COMMA COUNT
	MOVE	A1,-*SP,W		;HERE'S THE NULL TERMINATOR
	MOVK	16,A1			;DIVISOR FOR HEX
	MOVE	A8,A9
HEXTASCH2
	CLR	A8
	DIVU	A1,A8
	ADDI	'0',A9			;MAKE THE REMAINDER ASCII
	CMPI    '9',A9			;IS IT IN A-F RANGE?
	JRLS    HHH1
	BTST	B_CAP,A4		;ARE WE IN CAPITAL MODE
	JRNE	HHH0			;YES
	ADDI	'a' - ':',A9		;MAKE alpha!
	JRUC	HHH1
HHH0:
	ADDI    'A' - ':',A9		;MAKE ALPHA!
HHH1:
	DEC	A3			;DECREMENT THE WIDTH
	MOVE	A9,-*SP,W		;SAVE HERE
	MOVE	A8,A9
	JRZ	HEXTASCH3		;BR = DONE!
	INC	A2
	CMPI	3,A2			;COMMA CHECK 	
	JRLO	HEXTASCH2		;BR = NO COMMA
*
*        SEE IF WE'RE DOING COMMAS
*
	BTST	B_COMMAS,A4		;COMMAS?
	JREQ	HEXTASCH2		;NOPE....IGNORE!

	MOVI	',',A2
	MOVE	A2,-*SP,W		;STUFF A COMMA
	CLR	A2
	JRUC	HEXTASCH2
HEXTASCH3:
	MOVE	A3,A3
	JRZ	HEXTASCH3A		;WIDTH HAS BEEN FULFILLED
	JRN	HEXTASCH3A		;THANX TI
	BTST	B_ZPRINT,A4
	JRNE	HEXTASCH30		;YES, FILL width WITH ZEROS
	MOVI	' ',A2
	JRUC	HEXTASCH31
HEXTASCH30:
	MOVI	'0',A2
HEXTASCH31:
	MOVE	A2,-*SP,W		;STUFF THE LEADER
	DSJS	A3,HEXTASCH31
HEXTASCH3A:
*CHECK FOR 0x PREFIX
	BTST	B_PHEX,A4
	JREQ	HEXTASCH3D		;NO PREFIX NECESSARY
	BTST	B_CAP,A4
	JRNE	HEXTASCH3B		;PRINT A CAPITAL X
	MOVI	'x',A2
	JRUC	HEXTASCH3C
HEXTASCH3B:
	MOVI	'X',A2
HEXTASCH3C:
	MOVE	A2,-*SP,W
	MOVI	'0',A2
	MOVE	A2,-*SP,W
HEXTASCH3D:
*DUMP THE STRING AND PASS IT BACK
	MOVI	STRNGRAM,A1		;STORE HERE FOR BLOW OUT        
	MOVE	A1,A8
HEXTASCH4:
	MOVE	*SP+,A9,W
	MOVB	A9,*A1
	ADDK	8,A1
	MOVE	A9,A9
	JRNZ	HEXTASCH4
	MMFM	SP,A1,A2,A3,A9
	RETS

**************************************************************************
*                                                                        *
* BCDTOASC - CONVERT A 32 BIT HEXADECIMAL # TO A NULL TERMINATED	 *
* 	   HEXADECIMAL ASCII STRING. COMMAS AND LEAD ZERO BLANKING	 *
* 	   ARE ASSERTED.						 *
* A8 = BCD #								 *
* RETURNS:								 *
* A8 = PTR TO ASCII HEX STRING						 *
*                                                                        *
**************************************************************************
BCDTOASC
	MMTM	SP,A3,A4,A14
	CLR	A3
	CLR	A4
	BSET	B_COMMAS,A4	
	CALLR	BCD_TO_ASCII_DEC
	MMFM	SP,A3,A4,A14
	RETS

**************************************************************************
*                                                                        *
* BCD_TO_ASCII_DEC - CONVERTS A BCD NUMBER INTO A NULL TERMINATED	 *
* 		   ASCII DECIMAL STRING.				 *
* A3 = width, MINIMUM # OF CHARACTERS CONTAINED IN THE STRING		 *
* A4 = flags, USES: B_COMMAS - PUT COMMAS IN THE NUMBER			 *
* 		  B_ZPRINT - IF width IS NOT REACHED, FILL WITH 0's	 *
* 			     NOT SPACES.				 *
* A8 = BCD #								 *
* RETURNS:								 *
* A8 PTR TO THE STRING							 *
* A3 & A4 ARE PRESERVED							 *
*                                                                        *
**************************************************************************
BCD_TO_ASCII_DEC:
	MMTM	SP,A1,A2,A3,A5,A9
	MOVE	A8,A1
	MOVK	1,A2
	MOVE	A2,A5		;DIGIT COUNT
	SRL	4,A1		;WE WILL ALWAYS PRINT THE FIRST DUDE
BCDZLP:
	MOVE	A1,A9	
	SRL	4,A1		;SLIDE DIGIT OFF THE END
	INC	A2		;KNOCK UP ANOTHER DIGIT
	SLL	28,A9
	SRL	28,A9
	JREQ	BCDZ		;IT'S A ZERO
	MOVE	A2,A5		;UPDATE VALID DIGIT COUNT
BCDZ:
	CMPI	8,A2
	JRLO	BCDZLP		;MORE DIGITS TO CHECK
*O.K. LET'S STRING THIS BITCH
	CLR	A2			;COMMA COUNT
	MOVE	A2,-*SP,W		;HERE'S THE NULL TERMINATOR
BCDCLP:
	MOVE	A8,A9
	SRL	4,A8			;SHIT THIS DIGIT
	SLL	28,A9
	SRL	28,A9			;ISOLATE
	ADDI	'0',A9			;MAKE ASCII
	CMPI	'9',A9
	JRLS	BCDISNUM		;IT'S A VALID NUMBER.
	MOVI	' ',A9			;SUBSTITUTE A SPACE FOR ERROR
BCDISNUM:
	MOVE	A9,-*SP,W		;PUSH ON MY MAN
	DEC	A3			;DECREMENT width
	DEC	A5			;DIGIT COUNT
	JRZ	BCDDONE			;WE HAVE FINISHED
*COMMA SHIT
	INC	A2
	CMPI	3,A2			;COMMA CHECK 	
	JRLO	BCDCLP			;BR = NO COMMA
	BTST	B_COMMAS,A4		;PRINT COMMAS?
	JREQ	BCDCLP			;NOPE....IGNORE!
	MOVI	',',A2
	MOVE	A2,-*SP,W		;STUFF A COMMA
	CLR	A2
	JRUC	BCDCLP
BCDDONE:
	MOVE	A3,A3
	JRZ	BCDXFER			;WIDTH HAS BEEN FULFILLED
	JRN	BCDXFER 		;THANX TI
	BTST	B_ZPRINT,A4
	JRNE	BCDZP1			;YES, FILL width WITH ZEROS
	MOVI	' ',A2
	JRUC	BCDZP2
BCDZP1:
	MOVI	'0',A2
BCDZP2:
	MOVE	A2,-*SP,W		;STUFF THE LEADER
	DSJS	A3,BCDZP2
BCDXFER:
*DUMP THE STRING AND PASS IT BACK
	MOVI	STRNGRAM,A1		;STORE HERE FOR BLOW OUT        
	MOVE	A1,A8
BCDXFER_LP:
	MOVE	*SP+,A9,W
	MOVB	A9,*A1
	ADDK	8,A1
	MOVE	A9,A9
	JRNZ	BCDXFER_LP

	MMFM	SP,A1,A2,A3,A5,A9
	RETS

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
L_MESS_LOOP
	ADDI	8,A8			;PUSH BEYOND THIS BYTE
L_MESS
	ADDI	0FH,A8			;IF IT ENDS IN OTHER THAN ZERO..
*					;KICK TO NEXT WORD (I.E. .EVEN)
	SRL	4,A8
	SLL	4,A8			;MASK FRACTIONAL WORD

	MMFM	A8,A1,A5,A9,A10,A11	;LOAD UP REGGIES FROM A8.
	MMFM	A8,A0			;YOU MAY SLEEP

	JSRPR	A1			;JSRP TO THE ROUTINE
	MOVB	*A8,A0			;CHECK NEXT BYTE 0=DONE...1=MORE.
	JRNZ	L_MESS_LOOP
	RETP
         
**************************************************************************
*                                                                        *
*          LM_SETUP                                                      *
*                                                                        *
*          THIS IS CALLED TO SETUP THE WORLD FOR A STRING                *
*          OPERATION, BUT NOT PHYSICALLY MAKE THE CALL.                  *
*                                                                        *
*          THIS ALLOWS TWEAKING OF REGGIES BEFORE THE CALL.              *
*                                                                        *
*          LM_FINIS                                                     *
*                                                                        *
*          THIS IS CALLED ONCE THE MODIFICATIONS ARE MADE!               *
*                                                                        *
*                                                                        *
**************************************************************************
LM_SETUP MMFM    A8,A1,A5,A9,A10,A11       ;LOAD UP REGGIES FROM A8.
         MMFM	A8,A0                        ;SLEEPY TIME
         RETS
LM_FINIS
         JUMP    A1                            ;THIS RUNS ROUTINE AND

**************************************************************************
*								         *
* LM_PRINTF - THIS ROUTINE COMBINES LM_SETUP WITH PRINTF, USE IF YOU	 *
* 		DON'T NEED TO TWEAK THE REGISTERS			 *
* A8 = MESS_MAC FOLLOWED BY STRING.					 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
LM_PRINTF:
	CALLR	LM_SETUP
	JRUC	PRINTF

**************************************************************************
*                                                                        *
* CLRTEXT - CLEAR ALL TEXT ON THE OBJECT LIST.				 *
*                                                                        *
**************************************************************************
CLRTEXT
	MMTM	SP,A0,A1
	MOVI	TEXTOID,A0
	CLR	A1
	NOT	A1
	CALLA	KILOBJ
	MMFM	SP,A0,A1
	RETS
	
	.DATA
**************************************************************************
*                                                                        *
* 	FONT TABLES STARTING AT ASCII $21				 *
*                                                                        *
**************************************************************************
*
*5 POINT FONT.
*
RD5FONT
	.LONG  FONT5EXC,FONT5APOS,FONT5EXC,FONT5EXC,FONT5EXC,FONT5EXC
	.LONG  FONT5APOS,FONT5EXC,FONT5EXC,FONT5EXC,FONT5EXC
	.LONG  FONT5EXC,FONT5MIN,FONT5PER,FONT5SLA,FONT50,FONT51
	.LONG  FONT52,FONT53,FONT54,FONT55,FONT56,FONT57,FONT58,FONT59
	.LONG  FONT5COLON,FONT5EXC,FONT5EXC,FONT5EXC,FONT5EXC
	.LONG  FONT5EXC,FONT5EXC
	.LONG  FONT5A,FONT5B,FONT5C,FONT5D,FONT5E,FONT5F,FONT5G,FONT5H
	.LONG  FONT5I,FONT5J,FONT5K,FONT5L,FONT5M,FONT5N,FONT5O,FONT5P
	.LONG  FONT5Q,FONT5R,FONT5S,FONT5T,FONT5U,FONT5V,FONT5W,FONT5X
	.LONG  FONT5Y,FONT5Z
	.LONG  FONT5EXC,FONT5EXC,FONT5EXC,FONT5EXC,FONT5EXC
	.LONG  FONT5EXC
	.LONG  FONT5A,FONT5B,FONT5C,FONT5D,FONT5E,FONT5F,FONT5G,FONT5H
	.LONG  FONT5I,FONT5J,FONT5K,FONT5L,FONT5M,FONT5N,FONT5O,FONT5P
	.LONG  FONT5Q,FONT5R,FONT5S,FONT5T,FONT5U,FONT5V,FONT5W,FONT5X
	.LONG  FONT5Y,FONT5Z
	.LONG  FONT5EXC,FONT5EXC,FONT5EXC

*
*7 POINT FONT.
*
RD7FONT
	.LONG  FONT8EXC,FONT8APOS,FONT8NUM,FONT8DOLL,FONT8PERC,FONT8AND
	.LONG  FONT8APOS,FONT8LPAREN,FONT8RPAREN,FONT8ASTR,FONT8PLUS
	.LONG  FONT8COMM,FONT8MIN,FONT8PER,FONT8SLA,FONT80,FONT81
	.LONG  FONT82,FONT83,FONT84,FONT85,FONT86,FONT87,FONT88,FONT89
	.LONG  FONT8COLON,FONT8SMCOL,FONT8LPAREN,FONT8EQL,FONT8RPAREN
	.LONG  FONT8QUEST,FONT8MIN
	.LONG  FONT8A,FONT8B,FONT8C,FONT8D,FONT8E,FONT8F,FONT8G,FONT8H
	.LONG  FONT8I,FONT8J,FONT8K,FONT8L,FONT8M,FONT8N,FONT8O,FONT8P
	.LONG  FONT8Q,FONT8R,FONT8S,FONT8T,FONT8U,FONT8V,FONT8W,FONT8X
	.LONG  FONT8Y,FONT8Z
	.LONG  FONT8LPAREN,FONT8ARRW,FONT8RPAREN,FONT8EXC,FONT8MIN
	.LONG  FONT8APOS	
	.LONG  FONT8A,FONT8B,FONT8C,FONT8D,FONT8E,FONT8F,FONT8G,FONT8H
	.LONG  FONT8I,FONT8J,FONT8K,FONT8L,FONT8M,FONT8N,FONT8O,FONT8P
	.LONG  FONT8Q,FONT8R,FONT8S,FONT8T,FONT8U,FONT8V,FONT8W,FONT8X
	.LONG  FONT8Y,FONT8Z
	.LONG  FONT8LPAREN,FONT8EXC,FONT8RPAREN,FONT8BLK
	.LONG	FONT8UNDERLINE, FONT8BLK, FONT8BLK, FONT8POU

*
*15 POINT FONT. @ is missing (GNP 10/20/88)
*
RD15FONT
	.LONG  FONT15EXC,FON15quote,FON15poun,FONT15DOLL,FON15perc,FON15and
	.LONG  FONT15APOS,FONT15LPAREN,FONT15RPAREN,FON15ast,FONT15PLUS
	.LONG  FONT15COMMA,FONT15MINUS,FONT15PER,FONT15SLASH,FONT150,FONT151
	.LONG  FONT152,FONT153,FONT154,FONT155,FONT156,FONT157,FONT158,FONT159
	.LONG  FONT15COLON,FON15semicol,FON15less,FON15equal,FON15more
	.LONG  FONT15QUEST,FONT15QUEST
	.LONG  FONT15A,FONT15B,FONT15C,FONT15D,FONT15E,FONT15F,FONT15G,FONT15H
	.LONG  FONT15I,FONT15J,FONT15K,FONT15L,FONT15M,FONT15N,FONT15O,FONT15P
	.LONG  FONT15Q,FONT15R,FONT15S,FONT15T,FONT15U,FONT15V,FONT15W,FONT15X
	.LONG  FONT15Y,FONT15Z
	.LONG  FON15brackl,FONT15ARRW,FON15brackr,FON15carr,FON15line
	.LONG  FON15apos1	
	.LONG  FONT15A,FONT15B,FONT15C,FONT15D,FONT15E,FONT15F,FONT15G,FONT15H
	.LONG  FONT15I,FONT15J,FONT15K,FONT15L,FONT15M,FONT15N,FONT15O,FONT15P
	.LONG  FONT15Q,FONT15R,FONT15S,FONT15T,FONT15U,FONT15V,FONT15W,FONT15X
	.LONG  FONT15Y,FONT15Z
	.LONG  FON15paren2l,FON15break,FON15paren2r
     	.LONG  RD15SP,RD15RUB,RD15END,FON15rquote,FON15engPOUN,FON15CR

*
*20 POINT FONT. Much is missing (GNP 10/25/89)
*
RD20FONT
	.LONG  FONT20EXC,FONT20EXC,FONT20EXC,FONT20EXC,FONT20EXC,FONT20EXC
	.LONG  FONT20EXC,FONT20LPAREN,FONT20RPAREN,FONT20EXC,FONT20EXC
	.LONG  FONT20COM,FONT20MIN,FONT20PER,FONT20SLA,FONT200,FONT201
	.LONG  FONT202,FONT203,FONT204,FONT205,FONT206,FONT207,FONT208,FONT209
	.LONG  FONT20COLON,FONT20EXC,FONT20EXC,FONT20EXC,FONT20EXC
	.LONG  FONT20QUEST,FONT20EXC
	.LONG  FONT20A,FONT20B,FONT20C,FONT20D,FONT20E,FONT20F,FONT20G,FONT20H
	.LONG  FONT20I,FONT20J,FONT20K,FONT20L,FONT20M,FONT20N,FONT20O,FONT20P
	.LONG  FONT20Q,FONT20R,FONT20S,FONT20T,FONT20U,FONT20V,FONT20W,FONT20X
	.LONG  FONT20Y,FONT20Z
	.LONG  FONT20EXC,FONT20EXC,FONT20EXC,FONT20EXC,FONT20EXC
	.LONG  FONT20EXC
	.LONG  FONT20A,FONT20B,FONT20C,FONT20D,FONT20E,FONT20F,FONT20G
	.LONG  FONT20H,FONT20I,FONT20J,FONT20K,FONT20L,FONT20M,FONT20N
	.LONG  FONT20o,FONT20P,FONT20Q,FONT20R,FONT20S,FONT20T,FONT20U
	.LONG  FONT20V,FONT20W,FONT20X,FONT20Y,FONT20Z
	.LONG  FONT20EXC,FONT20EXC,FONT20EXC,FONT20EXC,FONT20BACKSP

**************************************************************************
*								         *
* 		TROG SPECIAL CHARACTER DEFINITIONS			 *
*								         *
**************************************************************************
FONT8BLK:
	.WORD	4,4,2,-2
	.LONG	>2000000

FONT8UNDERLINE:
	.WORD	6,1,0,-9
	.LONG	>2000000

	.END
