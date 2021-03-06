	.IF	0
**************************************************************************
*								         *
* 	T-SHIRT STUFF							 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	TSHIRT_START							 *
* 									 *
* 	CHECK THINGS OUT TO SEE IF WE NEED TO PUT UP PLAYER TSHIRTS	 *
*								         *
**************************************************************************

TSHIRT_START:
	MMTM	SP,A0,A1,A2,A3,A7,A8,A10

	MOVI	TPLAYTAB,A1
TSHIRT_ST_LOOP
	MOVE	*A1+,A0,L
	JRZ	TSHIRT_ST_DONE
	MOVE	*A0(POBJ),A2,L
	JRZ	TSHIRT_ST_LOOP		; BR = NO OBJECT, DUDE!
	MOVE	*A0(PTSHIRT),A2,W
	JRNZ	TSHIRT_ST_LOOP		; YO, DUDE, YOU ALREADY HAVE ONE!
	PUSH	A0
	MOVI	ADJTSHIRT,A0
	CALLA	GET_ADJ
	MOVE	A0,A2			; TSHIRT ISLAND NUMBER
	PULL	A0
	MOVE	A2,A2
	JRZ	TSHIRT_ST_DONE		; TURNED OFF, DUDE
	MOVE	*A0(PCONSECUTIVE),A3,W
	CMP	A2,A3	
	JRLO	TSHIRT_ST_LOOP		; HAVEN'T COMPLETED ENOUGH WAVES
	MOVE	A0,A8
	PUSH	A1
	CREATE	TSHIRTPID,TSHIRT_PROCESS	; MAKE ME A TSHIRT
	PULL	A1
	JRUC	TSHIRT_ST_LOOP
TSHIRT_ST_DONE
	MMFM	SP,A0,A1,A2,A3,A7,A8,A10
	RETS

TPLAYTAB
	.LONG	P1DATA, P2DATA, P3DATA, P4DATA,0

**************************************************************************
*								         *
* 	TSHIRT_PROCESS							 *
* 									 *
* 	CREATE A TSHIRT -- NOT A LOT OF ANIMATION HERE			 *
* 									 *
* 	ENTRY								 *
* 		A8	PLAYER DATA AREA POINTER			 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

TSHIRT_PROCESS:
	SLEEP	60   			; WAIT FOR THINGS TO GET MOVING
	CALLA	FIND_OPEN_CPNT
	JRZ	TSHIRT_PROCESS		; BR = NO PLACE TO HANG OUT
	MOVE	A1,A5			; SAVE CENTER POINT AWAY
	MOVE	A8,A2
	MOVE	A8,A11			; SAVE AWAY FOR A RAINY DAY
	CALLA	GPLAYNUM
	MOVE	A0,A9
	SLL	5,A0
	ADDI	TSHIRTTAB,A0
	MOVE	*A0,A14,L
	CALLA	GPALOBJSTF
	JRZ	TSHIRT_PROC_DIE		; BR = COULDN'T GET AN OBJECT

	MOVE	A13,*A0(OPLINK),L	;LINK IT UP
	MOVI	TSHIRTOID,A10
	MOVE	A10,*A0(OID),W		; TSHIRT OID
	MOVE	A0,A8			; OBJECT
	MOVE	A5,A0			; CENTER POINT
	CALLA	TOMOVE			; PLACE THE TSHIRT ON THE CENTER MOVE
	MOVI	TSHIRTID,A0
	MOVB	*A5(CMOVEEGG),A2
	INC	A2
	JRNZ	TSHIRT_SPOT_BAD
	MOVB	A0,*A5(CMOVEEGG)	;MARK IT TAKEN
TSHIRT_SPOT_BAD
	MOVE	A8,A0
	CALLA	SET_MZPOS
	CALLA	INSERT_OBJ
	MOVI	ENEMIES,A1
	CALLA	INSERT_SUPP		;MAKE US COLLIDABLE
	CLR	A0
	MOVE	A0,*A8(OPLINK),L
TSHIRT_PROC_DIE:
	DIE

**************************************************************************
*								         *
* 	TSHIRTDINO							 *
* 									 *
* 	COLLIDE A DINO WITH A TSHIRT					 *
* 									 *
* 	ENTRY								 *
* 		A0	TSHIRT POINTER					 *
* 		A8	DINO POINTER					 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

TSHIRTDINO:
	MMTM	SP,A0,A1,A2,A3,A4,A7,A8,A9,A10,A14
	MOVE	*A8(OPLINK),A10,L	;GET THE DINOSAURS CONTROL
	JRZ	TSHIRTDINOX		;THE DINO IS OUT OF CONTROL

	MOVE	*A8(OID),A4,W
	SLL	28,A4
	SRL	28,A4			; GET DINO NUMBER IN A4

	MOVE	*A0(OIMG),A1,L		; GET THE OBJECT
	CLR	A3
	CMPI	REDTEE,A1
	JRZ	TSHIRT_GOT
	INC	A3
	CMPI	BLUETEE,A1
	JRZ	TSHIRT_GOT
	INC	A3
	CMPI	YELTEE,A1
	JRZ	TSHIRT_GOT
	INC	A3
	CMPI	PURPTEE,A1
	JRZ	TSHIRT_GOT
	.IF	DEBUG
	JRUC	$
	.ENDIF

TSHIRT_GOT
	CMP	A3,A4
	JRNE	TSHIRTDINOFL		; NOT OF THE SAME BREED

	MOVE	A0,A8
	CALLA	OBJPROC_KILL		;KILL THE CONTROL

	MOVE	A3,A0
	MOVE	A3,A4			;STORE OUR TSHIRT I.D. HERE
	CALLA	GETANIXY
	SRL	16,A3
	MOVY	A2,A3
	CALLA	GPLAYD			; GET THE PLAYER DATA AREA

	CALLA	FINDMOVE		; GET MOVE THAT THIS TSHIRT IS ON
	JRNC	TSHIRTNOC		; BR = DIDN'T FIND A MOVE
	MOVE	*A1(MOVECPTR),A3,L	; IS IT A CENTER MOVE?
	JRNN	TSHIRT_DEL		; BR = YES, DO THE DIRTY WORK
	MOVE	*A1(MOVEAPTR),A3,L	; IS IT AN AUXILLARY MOVE?
	JRN	TSHIRTNOC		; BR = NO, THEN DON'T DO ANYTHING
TSHIRT_DEL:
	MOVB	*A3(CMOVEEGG),A1	  
	CMPI	TSHIRTID,A1		; IS THIS MY SHIRT
	JRNE	TSHIRTNOC		; BR = NO
	CLR	A1
	NOT	A1
	MOVB	A1,*A3(CMOVEEGG)	; CLEAR THE USER OF THIS TSHIRT SPOT
TSHIRTNOC:
	MOVE	A8,A0
	MOVI	ENEMIES,A1
	CALLA	DELSUPP			; TAKE TSHIRT OFF OF THE LIST
	MOVE	*A8(OFLAGS),A0,W
	ORI	M_NOCOLL,A0
	MOVE	A0,*A8(OFLAGS),W	; TURN OFF COLLISIONS TO IT

	MOVK	1,A1
	MOVE	A1,*A2(PTSHIRT),W	; FLAG HE GOT HIS TSHIRT
	MOVI	TSHIRT_SND,A0
	CLR	A1
	CALLA	SEND2SCR
	CALLA	OUTTSHIRT
	SETZ				;END O' SCAN
	JRUC	TSHIRTDINOX
TSHIRTDINOFL:
	CLRZ
TSHIRTDINOX:
	MMFM	SP,A0,A1,A2,A3,A4,A7,A8,A9,A10,A14
	RETS

TSHIRT_SND 
	.WORD	>F3E0,0FH,>80AF,80B0H,80B1H, 80B2H, 0

**************************************************************************
*								         *
* 	TSHIRTCOLL -- TSHIRT COLLISION TABLE				 *
*								         *
**************************************************************************

TSHIRTCOLL:
	.WORD	DINOOID,0FFF0H			;COLLIDE WITH ALL DINOS
	.LONG	TSHIRTDINO
	.WORD	0
	.LONG	DUMCRETS			;DO NOTHING

TSHIRTTAB
	.LONG	REXTEE,BLOOPTEE,SPIKETEE,GWENTEE

REXTEE:
	.LONG	0,0
	.WORD	0,0
	.LONG	REDTEE,[12,12],TSHIRTCOLL
	.WORD	DMAWNZ,TSHIRTOID
BLOOPTEE:
	.LONG	0,0
	.WORD	0,0
	.LONG	BLUETEE,[12,12],TSHIRTCOLL
	.WORD	DMAWNZ,TSHIRTOID
SPIKETEE:
	.LONG	0,0
	.WORD	0,0
	.LONG	YELTEE,[12,12],TSHIRTCOLL
	.WORD	DMAWNZ,TSHIRTOID
GWENTEE:
	.LONG	0,0
	.WORD	0,0
	.LONG	PURPTEE,[12,12],TSHIRTCOLL
	.WORD	DMAWNZ,TSHIRTOID

	.ENDIF

	.IF	0
**************************************************************************
*								         *
* 	T-SHIRT ROUTINES						 *
*								         *
**************************************************************************

**************************************************************************
*								         *
* 	GAME_TSHIRT							 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A8	0 = OFFER NOT IN EFFECT -- NOTHING PLOTTED	 *
* 			ANYTHING ELSE, i PUT SOMETHING ON THE SCREEN	 *
*								         *
**************************************************************************

GAME_TSHIRT:
	CLR	A8
	MOVI	ADJTSHIRT,A0
	CALLA	GET_ADJ
	JRZ	GAME_TSHIRT_DIE
	MOVI	TSHIRT1,A8
	CALLA	LM_SETUP
	JSRP	PRINTF
	MOVI	ADJTSHIRT,A0
	CALLA	GET_ADJ
	MOVE	A0,@TEMPNUM,W
	MOVI	TSHIRT2,A8
	CALLA	LM_SETUP
	JSRP	PRINTF
	MOVI	TSHIRT3,A8
	CALLA	LM_SETUP
	JSRP	PRINTF
	MOVK	1,A8
GAME_TSHIRT_DIE:
	MOVE	A8,A8
	RETP

ATT_TSHIRT:
	MOVI	ADJTSHIRT,A0
	CALLA	GET_ADJ
	JRZ	ATT_TSHIRT_DIE
	CLR	A0
	MOVE	A0,@SCRNTL,L		;RE-ADJUST TOP LEFT CORNER OF SCREEN
	MOVE	A0,@GAMERASE,W		;AUTO ERASE OFF
	CALLA	CLR_SCRN
	CALLR	DRAW_BONE_SCORE		; MIGHT EVEN GET US SOME PALETTES
	MOVI	TSHIRT1,A8
	CALLA	LM_SETUP
	JSRP	PRINTF
	MOVI	ADJTSHIRT,A0
	CALLA	GET_ADJ
	MOVE	A0,@TEMPNUM,W
	MOVI	TSHIRT2,A8
	CALLA	LM_SETUP
	JSRP	PRINTF
	MOVI	TSHIRT3,A8
	CALLA	LM_SETUP
	JSRP	PRINTF
	SLEEP	400
ATT_TSHIRT_DIE:
	RETP

TSHIRT1:
	MESS_MAC RD20FONT,1,200,45+SKYTOPOF,TROG_PLF,STRCNRMO,0
	.STRING	"WIN"
	.STRING	"\nA TROG T-SHIRT! !",0
	.EVEN

TSHIRT2:
	MESS_MAC RD15FONT,1,200,110+SKYTOPOF,TROG_PWHITE,STRCNRMO,0
	.STRING	"PLAY \b%d\b SUCCESSIVE ISLANDS AND"
	.STRING	"\nPICKUP YOUR \bTROG\b T-SHIRT!",0
	.WORD	TROG_LF
	.LONG	TEMPNUM
	.WORD	TROG_WHITE
	.WORD	TROG_RED
	.WORD	TROG_WHITE
	.EVEN

TSHIRT3:
	MESS_MAC RD7FONT,1,200,185+SKYTOPOF,TROG_PRGB,STRCNRMO,0
	.STRING	"SPECIAL ACME SHOW OFFER ONLY!",0
	.EVEN

**************************************************************************
*								         *
* 	OUTTSHIRT							 *
* 									 *
* 	PUT OUT A LITTLE SHIRT IF THE GUY DESERVES IT			 *
* 									 *
* 	ENTRY								 *
* 		A2	PLAYER DATA AREA				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

OUTTSHIRT:
	MMTM	SP,A1,A2,A3,A4,A5
	MOVE	*A2(PTSHIRT),A1,W
	JRZ	OUTTSHIRT_X		; NO SHIRT

	MOVE	*A2(PSCRAD),A3,L	;PLAYER SCORE ADDRESS
	ADDI	SCSHIRT,A3

	CALLA	GPLAYNUM
	SLL	5,A0
	MOVE	A0,A1
	ADDI	TSHIRTICON,A0
	MOVE	*A0,A14,L
	ADDI	TSHIRTCOLOR,A1
	MOVE	*A1,A1,L
	
	MOVE	*A14(ISAG),A4,L		;GET STARTING ADDRESS
	MOVE	*A14(ISIZE),A2,L	;GET THE SIZE
	MOVI	DMACNZ,A5		;FLAGS
	CALLA	DMAN			;OUTPUT THE SUCKER
OUTTSHIRT_X:
	MMFM	SP,A1,A2,A3,A4,A5
	RETS

TSHIRTICON
	.LONG	REDTEEsm, BLUETEEsm, YELTEEsm, PURPTEEsm

TSHIRTCOLOR
	.LONG	TROG_PRED, TROG_PBLUE, TROG_PYELLOW, TROG_PPURPLE

	.ENDIF

