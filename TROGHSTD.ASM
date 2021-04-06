    	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGHSTD.ASM'
	.TITLE	"TROG HSTD ROUTINES"
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
	.INCLUDE        "TROGMEQU.ASM"      ;MENU EQUATES
	.INCLUDE	"TROGAUDN.ASM"		; AUDITING OFFSETS

	.REF	DEF_PAGE, FADEALL
	.REF	WIPEOUT, FILLAREA, STRNGLEN, COLOR_START, HEXTOASC, P_FORK
	.REF	TROGCAVE2
	.REF	BAKMODS, BGND_UD1
*
*        IN THIS MODULE
*
         .GLOBAL         GET_HSCR
         .GLOBAL         RC_BYTEI
         .GLOBAL         RC_BYTE
         .GLOBAL         RC_WORD
	.GLOBAL		RC_WORDI
         .GLOBAL         RC_LONG
         .GLOBAL         RC_LONGI
         .GLOBAL         WC_BYTE
         .GLOBAL         WC_BYTEI
         .GLOBAL         WC_WORD
         .GLOBAL         WC_WORDI
         .GLOBAL         WC_LONG
         .GLOBAL         WC_LONGI
         .GLOBAL         PT_ENTRY
         .GLOBAL         INIT_TB
         .GLOBAL         INIT_TAB    ;GEORGES POWER UP ENTRY
         .GLOBAL         P_FORK 
         .GLOBAL         VAL_TAB
         .GLOBAL         ROM_PTRS
         .GLOBAL         ALL_TAB
         .GLOBAL         TOD_TAB
         .GLOBAL         E_GAME
         .GLOBAL         ISHSTD
         .GLOBAL         SET_PAGE
         .GLOBAL         A2_CHECK
         .GLOBAL         DEC_HSR,INIT_HSR,GET_HSC
*

	.REF	ANY_BUT, WAIT_BUT, FADE_ONLY, GET_CSTR
	.DEF	ATT_HSTD
	.DEF	CKHSTD,TRYADD, CHECK_INITS, ADD_HSHOLD
	.DEF	INIT_TB, ALL_TAB, TOD_TAB
	.DEF	GET_HSC, INIT_HSR
	.DEF	CLEAR_HSCOLORS
	.REF	GPLAYNUM, CYCLE16
	.DEF	INIT_HSHOLD, ADD_HSHOLD, EMPTY_HSHOLD
	.DEF	ON_HSTD

	.DEF	CHAR_PLOT
	.BSS	CHAR_PLOT,64
	.DEF	CHAR_SCORE
	.BSS	CHAR_SCORE,32
	.BSS	CHAR_NUM,16
	.BSS	COLOR_SEQ,16
	.BSS	MASTER_SEQ,16
	.BSS	PLOT_COLOR,32
	.BSS	HOLDINITS,RHS_SIZE*4
	.BSS	ON_HSTD,16
	.BSS	TEMP_PAL,32
	.TEXT
	.EVEN

**************************************************************************
*                                                                        *
*          HIGH SCORE TABLE DEFINITIONS                                  *
*                                                                        *
**************************************************************************

ALL_TAB
         .LONG   ALL_TIME_ORIGIN           ;LOCATION OF TABLE
         .WORD   ALL_TIME_ENTRIES-1        ;NUMBER IN THE TABLE (DON'T COUNT ZERO FILLER)
         .WORD   ALL_TIME_VISIBLE          ;# VISIBLE (SHOW 20 ALL TIME)
         .WORD   ALL_TIME_SELECT           ;BITS TO SELECT IT
         .LONG   ALL_TIME_ROM_TABLE        ;ROM IMAGE OF TABLE
         .WORD   ALL_TIME_ENTRIES/5        ;RESET TABLE IF 1/5 OR MORE BAD

TOD_TAB
         .LONG   TODAYS_ORIGIN           ;LOCATION OF TABLE
         .WORD   TODAYS_ENTRIES-1        ;NUMBER IN THE TABLE (DON'T COUNT ZERO FILLER)
         .WORD   TODAYS_VISIBLE          ;# VISIBLE (SHOW 20 ALL TIME)
         .WORD   TODAYS_SELECT           ;BITS TO SELECT IT
         .LONG   TODAYS_ROM_TABLE        ;ROM IMAGE OF TABLE
         .WORD   TODAYS_ENTRIES/5        ;RESET TABLE IF 1/5 OR MORE BAD

**************************************************************************
*                                                                        *
*          AUTO HIGH SCORE TABLE RESET HANDLING                          *
*                                                                        *
**************************************************************************
*                                                                        *
*          DEC_HSR                                                       *
*                                                                        *
*          THIS IS CALLED WITH EACH START OR CONTINUE FOR                *
*          A PLAYER.  IT REMOVES 1 FROM THE HSTD COUNTER UNLESS          *
*          ITS ALREADY SITTING AT ZERO.                                  *
*                                                                        *
**************************************************************************
DEC_HSR  MMTM    SP,A0
         CALLR   GET_HSC         ;THIS IS EASY...GET THE COUNTER
         JRZ     DECHX           ;ITS ZERO....NO ACTION.
         DEC     A0              ;REMOVE A TICK
         CALLR   PUT_HSC         ;PUT IT BACK JAK
DECHX	MMFM    SP,A0
	RETS

**************************************************************************
*                                                                        *
*          DELAY_HSRESET                                                 *
*                                                                        *
*          THIS IS CALLED WHEN A NEW ENTRY IS MADE IN THE ALL TIME       *
*          HIGH SCORE TABLE.  IF WE'RE CLOSE TO A HIGH SCORE             *
*          RESET, WE PUT IT OFF AWHILE SO HE CAN SHOW HIS FRIENDS        *
*          FOR A FEW DAYS.                                               *
*                                                                        *
**************************************************************************
HS_MIN   EQU     750             ;ALWAYS 750 PLAYS BEFORE REMOVING A FRESH
*                                ;NAME.
DELAY_HSRESET
         MMTM    SP,A0
         CALLR   GET_HSC         ;THIS IS EASY...GET THE COUNTER
         CMPI    HS_MIN,A0       ;IS IT TOO LOW
         JRHS    DHX             ;NOPE...NO ACTION

         MOVI    HS_MIN,A0       ;STOP THE RESET!
         CALLR   PUT_HSC         ;THIS MANY PLAYS TILL RESET!
DHX	MMFM    SP,A0
	RETS

**************************************************************************
*                                                                        *
*          INIT_HSR                                                      *
*                                                                        *
*          THIS IS CALLED TO INITIALIZE THE HIGH SCORE RESET             *
*          COUNTER TO ITS ADJUSTED VALUE.                                *
*                                                                        *
**************************************************************************
INIT_HSR MMTM    SP,A0
         MOVI    ADJHSRES,A0
         CALLA   GET_ADJ              ;GET THE ADJUSTED VALUE
         CALLR   PUT_HSC              ;SET IT TO THIS VALUE
	MMFM    SP,A0
	RETS

**************************************************************************
*                                                                        *
*          PUT_HSC                                                       *
*                                                                        *
*          THIS IS CALLED TO SET THE HIGH SCORE RESET COUNTER            *
*          TO THE VALUE IN A0.                                           *
*                                                                        *
**************************************************************************

PUT_HSC  MMTM    SP,A7,A0
         CALLR   HSR_PAGE             ;HIGH SCORE PAGE

         MOVI    HRESET_COUNTER,A7    ;POINT AT 
         CALLR   WC_LONGI             ;WRITE OUR PARAMETER
         NOT     A0                   ;NEGATE IT.
         CALLR   WC_LONG              ;AND WRITE IN SUBSEQUENT SPOT.
         CALLA   DEF_PAGE             ;FLIP PAGE
	MMFM    SP,A7,A0             ;AND RETURN
	RETS

**************************************************************************
*                                                                        *
*          GET_HSC                                                       *
*                                                                        *
*          THIS IS CALLED TO FETCH THE HIGH SCORE COUNTER IN A0.         *
*          IF IT IS INVALID, IT WILL IMMEDIATELY BE RESET TO THE         *
*          ADJUSTED VALUE AND THIS IS WHAT WILL BE RETURNED              *
*          IN A0.           .EQ. MEANS ITS AT ZERO!                      *
*                                                                        *
**************************************************************************
GET_HSC  MMTM    SP,A7,A1
         CALLR   HSR_PAGE             ;POINT PAGE AT HSR

         MOVI    HRESET_COUNTER,A7    ;POINT AT 
         CALLR   RC_LONGI             ;READ THE VALUE
         MOVE    A0,A1                ;STASH IT
         CALLR   RC_LONG              ;READ VERIFIER
         NOT     A0                   ;SEE IF ITS VALID
         CMP     A0,A1
         JRZ     GET_HSCX             ;IT IS....RETURN IT.

         CALLR   INIT_HSR             ;REFRESH IT WITH FACTORY VALUE
*
*        NOW RETURN THE FACTORY VALUE IN CASE IT DIDN'T TAKE
*
         MOVI    ADJHSRES,A0
         CALLA   GET_ADJ              ;GET THE ADJUSTED VALUE

GET_HSCX CALLA   DEF_PAGE             ;FLIP PAGE AWAY FROM US
         MOVE    A0,A0                ;SET Z FLAG BASED ON COUNTER
	MMFM    SP,A7,A1
	RETS
HSR_PAGE MMTM    SP,A1
         MOVI    HSR_SELECT,A1
         CALLR   SET_PAGE
	MMFM    SP,A1
	RETS


**************************************************************************
*								         *
* 	CKHSTD								 *
* 									 *
* 	CHECK TO SEE IF A GIVEN SCORE WILL MAKE EITHER OF THE TABLES	 *
* 									 *
* 	ENTRY								 *
* 		A0	SCORE TO CHECK					 *
* 									 *
* 	EXIT								 *
* 		.EQ.	NO						 *
* 		.NE.	YES						 *
*								         *
**************************************************************************

CKHSTD:
	MMTM	SP,A0,A1,A8
	PUSH	A0
	MOVI	ALL_TAB,A8   		; CHECK ALL TIME TABLE FIRST
	CALLR	CHECK_SCORE
	PULL	A0
	JRNZ	CKRET
	MOVI	TOD_TAB,A8		; TODAY'S TABLE
	CALLR	CHECK_SCORE
CKRET
	MMFM	SP,A0,A1,A8
	RETS

**************************************************************************
*								         *
* 	TRYADD								 *
* 									 *
* 	WE THINK WE ARE IN ONE OF THE TABLES -- ADD ME			 *
* 									 *
* 	ENTRY								 *
* 		A0	SCORE						 *
* 		A1	POINTER TO INITIALS				 *
*		A8	POINTER TO THE PLAYER DATA AREA			 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

TRYADD:
	MMTM	SP,A8
	PUSH	A0
	MOVE	A8,A2
	CALLA	GPLAYNUM
	INC	A0			; 1 BASE THIS ONE
	MOVE	A0,A2			; WHAT TO STICK IN "HS_SCORE"
	PULL	A0
	MOVI	ALL_TAB,A8   		; CHECK ALL TIME TABLE FIRST
	CALLR	ADD_ENTRY
	MOVI	TOD_TAB,A8		; TODAY'S TABLE
	CALLR	ADD_ENTRY
	MMFM	SP,A8
	RETS	

**************************************************************************
*                                                                        *
*          CHECK_INITS                                                   *
*                                                                        *
*          A1 POINTS AT A SET OF INITIALS ENTERED.  RETURN .EQ.          *
*          IF THEY'RE ALL SPACES (OR ZERO).                              *
*                                                                        *
**************************************************************************
CHECK_INITS
         MMTM    SP,A0,A1,A2
         MOVI    NUM_INITS,A2
CHECK_NEXT
         MOVB    *A1,A0               ;GET AN INITIAL
         JRZ     SPACE_FOUND          ;NULL IS A SPACE
         CMPI    SPACE,A0             ;IS IT A REAL SPACE?
         JRNZ    LET_FOUND
SPACE_FOUND
         ADDI    BYTE_SIZE,A1
         DSJS    A2,CHECK_NEXT
         CLR     A2                   ;SET Z BIT ON FALL THROUGH

LET_FOUND
	MMFM    SP,A0,A1,A2
	RETS

**************************************************************************
*                                                                        *
*          CHECK_SCORE                                                   *
*                                                                        *
*          THIS IS CALLED WITH A SCORE IN A0 TO SEE IF IT                *
*          IS HIGH ENOUGH TO MAKE THE TABLE.                             *
*                                                                        * 
*          THIS ROUTINE CALLS FIND_TABLE_LEVEL WHICH RETURNS             *
*          THE POINT IN THE TABLE THAT THE PASSED SCORE WOULD            *
*          LAND.   THIS VALUE MUST BE LESS THAN OR EQUAL TO              *
*          THE "TB_VISIBLE" VALUE FOR THE TABLE.  THIS WOULD             *
*          MEAN THAT WE WANT TO GET THE PLAYER'S INITIALS.               *
*                                                                        *
*          A8 CONTAINS ROM POINTER FOR TABLE TO CHECK.                   *
*          RETURN A0 = 0 (AND .EQ.) IF SCORE ISN'T HIGH ENOUGH           *
*          AND A0 = POSITION IN TABLE IF SCORE MAKES IT.                 *
*                                                                        *
**************************************************************************
CHECK_SCORE
	MMTM	SP,A1,A3,A9,A10
	MOVE	A0,A3				;STASH SCORE IN A3
	CALLR	FIND_TABLE_LEVEL		;SEE WHERE WE LAND IN THIS TABLE
	JRZ	ANSWER_IN_A0			;ZERO.....GUY DIDN'T MAKE IT
	MOVE	*A8(TB_VISIBLE),A1,W		;GET THE NUMBER "VISIBLE"
	CMP	A1,A0				;A0 MUST BE LESS OR EQUAL
	JRLS	ANSWER_IN_A0			;NOT INVISIBLE...RETURN SUCCESS
	CLR	A0				;RETURN FAILURE
ANSWER_IN_A0
	MOVE	A0,A0				;SET EQ BIT ACCORDINGLY
	MMFM	SP,A1,A3,A9,A10
	RETS

**************************************************************************
*                                                                        *
*          ADD_ENTRY                                                     *
*                                                                        *
*          THIS IS CALLED AFTER "ENTER YOUR INITIALS" TO                 *
*          ADD AN ENTRY TO THE TABLE.  A0 CONTAINS THE                   *
*          SCORE OF THE PLAYER.  A1 CONTAINS A POINTER                   *
*          TO THE FETCHED INITIALS.   THE INITIALS ARE                   *
*          STORED AS CONSECUTIVE BYTES IN CONVENTIONAL                   *
*          (1 BYTE TAKES 1 BYTE SPACE) RAM.                              *
*                                                                        *
*          A8 contains a the table to store the entry in.                *
*	   A2 CONTAINS SOMETHING TO STICK IN "HS_COLOR"			 *
*                                                                        *
*          RETURN CARRY SET IF IT DIDN'T MAKE IT INTO REQUESTED TABLE    *
*                                                                        *
**************************************************************************
ADD_ENTRY
         MMTM    SP,A0,A1,A2,A3,A4,A7,A9,A10,A11
	MOVE	A2,A11
         CALLR   ROM_PTRS                  ;SETUP FOR THIS TABLE
         MOVE    A0,A4                     ;STASH THE SCORE A SEC.
         CLR     A2                        ;DONT WORRY ABOUT OTHER GUY AT THIS POINT
         CALLR   CHECK_SCORE               ;DOES THE REQUEST MAKE IT?
         SETC                              ;ANTICIPATE FAILURE
         JRZ     DIDNT_MAKE_IT             ;DON'T KNOW WHY I GOT THESE INITS.
*
*        A0 NOW HAS THE PLACE FOR THE NEW GUY.
*        MOVE THE ENTIRE TABLE DOWN 1 UNIT.
*
         MOVE    A10,A3                    ;LAST GUY IN TABLE IS DESTINATION
COPY_DOWN_LOOP
         MOVE    A3,A2                     ;GUY BEFORE HIM IS SOURCE
         DEC     A2                        ;A2 NOW HAS SOURCE
         CMP     A0,A2                     ;IS SOURCE LOWER THAN OUR SLOT? 
         JRLO    COPY_DONE                 ;IT IS...DON'T MOVE HIM.  

         CALLR   COPY_ENTRY                ;COPY A2 ENTRY TO A3
         DEC     A3                        ;MOVE DOWN TO ONE BEFORE
         JRUC    COPY_DOWN_LOOP

COPY_DONE
         CALLR   PUT_SCORE_FOR_ENTRY       ;SCORE IN A4 WRITTEN TO ENTRY A0
*
*        INITIAL POINTER IS IN A1
*        TABLE OFFSET IN A0
*
         CALLR   PT_ENTRY                  ;GET ENTRY POINTER IN A7
	MMTM	SP,A0,A7
	ADDI	HS_COL,A7
	MOVE	A11,A0
	CALLR	WC_WORD
	MMFM	SP,A0,A7
         ADDI    HS_INITS,A7               ;POINT AT FIRST INITIAL
         MOVI    NUM_INITS,A2              ;THIS IS NUMBER OF INITIALS
         MMTM    SP,A0                     ;SAVE A0

INIT_COPY_LOOP
         MOVB    *A1,A0                    ;GET AN INITIAL
         JRNZ    NOT_BLANK
         MOVI    SPACE,A0                  ;REPLACE BLANKS WITH SPACES
NOT_BLANK
         CALLR   WC_BYTEI       ;WRITE THE BYTE AND INCREMENT
         ADDI    BYTE_SIZE,A1              ;A1 TO NEXT BYTE PLEASE
         DSJ     A2,INIT_COPY_LOOP

	MMFM    SP,A0                     ;GET BACK ENTRY NUMBER
         CALLR   FORM_HS_CKSUM_AND_STORE   ;FOR CHECKSUM FOR THIS ENTRY AND STORE!
         CLRC                              ;RETURN SUCCESS!

DIDNT_MAKE_IT
	MMFM    SP,A0,A1,A2,A3,A4,A7,A9,A10,A11
	RETS

**************************************************************************
*                                                                        *
*          FIND_TABLE_LEVEL                                              *
*                                                                        *
*          THIS IS CALLED TO COMPARE THE SCORE IN A0 TO                  *
*          THE TABLE POINTED TO BY A8.                                   *
*                                                                        *
*          RETURN PHYSICALLY WHERE IT FITS IN A0, AND                    *
*          SET THE Z FLAG ACCORDINGLY                                    *
*                                                                        *
**************************************************************************
FIND_TABLE_LEVEL
         MMTM    SP,A1,A2,A3
         CALLR   ROM_PTRS                  ;SETUP FOR THIS TABLE
         CALLR   VAL_TAB                   ;FIX THE TABLE IN CASE ITS BROKEN.
         JRC     FTL_FAIL                  ;CAN'T VALIDATE..SAY SCORE DIDN'T MAKE IT

         MOVE    A0,A2                     ;KEEP SCORE IN A2
         MOVK    1,A0                      ;START AT 1 AND WORK UP.

CHECK_NEXT_SCORE
         CALLR   GET_HSCR       ;FETCH A0 ENTRY'S SCORE IN A1
         CMP     A1,A2                     ;HOW DO WE FARE AGAINST A1?
         JRHI    FOUND_THE_SPOT            ;WE FOUND THE SPOT
         INC     A0                        ;KEEP MOVING DOWN TILL WE FIT
         CMP     A10,A0                    ;ARE WE LOOKING AT THE LAST ONE?
         JRLS    CHECK_NEXT_SCORE

FTL_FAIL
         CLR     A0                        ;WE'RE NOT HIGH ENOUGH RETURN FAILURE

FOUND_THE_SPOT
         MOVE    A0,A0                     ;MAKE SURE YOU SET THE FLAGS
	MMFM    SP,A1,A2,A3
	RETS


**************************************************************************
*                                                                        *
*          GET_HSCR                                                      *
*                                                                        *
*          THIS IS CALLED TO FETCH THE SCORE FROM CMOS FOR               *
*          A GIVEN ENTRY.                                                *
*                                                                        *
*          ENTRY NUMBER PASSED IN A0.                                    *
*          SCORE RETURNED IN A1.                                         *
*                                                                        *
**************************************************************************
GET_HSCR
         MMTM    SP,A7,A0
         CALLR   PT_ENTRY                  ;POINT A7 AT ENTRY
         ADDI    HS_SCORE,A7               ;INDEX SCORE PART.
         CALLR   RC_LONG            ;FETCH THE LONG WORD INTO A0
         MOVE    A0,A1                     ;MOVE TO A1
	MMFM    SP,A7,A0
	RETS

**************************************************************************
*                                                                        *
*          PUT_SCORE_FOR_ENTRY                                           *
*                                                                        *
*          THIS IS CALLED TO WRITE OUT THE SCORE FOR A GIVEN ENTRY.      *
*          ENTRY SPECIFIED BY A0.                                        *
*          SCORE PASSED IN A4.                                           *
*                                                                        *
**************************************************************************
PUT_SCORE_FOR_ENTRY
         MMTM    SP,A7,A0
         CALLR   PT_ENTRY                  ;POINT A7 AT ENTRY
         ADDI    HS_SCORE,A7               ;INDEX SCORE PART.
         MOVE    A4,A0                     ;MOVE SCORE TO A0
         CALLR   WC_LONG           ;WRITE OUT THE LONG WORD 
	MMFM    SP,A7,A0
	RETS
	
**************************************************************************
*                                                                        *
*          LOW LEVEL HSTD PROCESSING                                     *
*                                                                        *
**************************************************************************
*
*        FOR HIGH SCORE ROUTINES
*
*        A8  = ROM POINTER FOR A GIVEN TABLE STATS
*        A9  = RAM POINTER FOR CMOS DATA
*        A10 = NUMBER OF ENTRIES IN THE TABLE
*
*        A0  = PARTICULAR ENTRY TO DEAL WITH
*                0 = FILL ENTRY (POINTER ROUTINES POINT HERE IF ERROR)
*                1 = HIGHEST SCORE IN TABLE
*                N = NTH SCORE
*
*        A1  = OUTPUT OF CHECKSUM ROUTINE  (BYTE)
*
*        A7  = POINTER TO CURRENT ENTRY
*
*        A4,A5,A6  SCRATCH
*
**************************************************************************
*                                                                        *
*          FORM_HS_CKSUM                                                 *
*                                                                        *
*          THIS IS CALLED TO FORM THE CHECKSUM FOR THE SCORE             *
*          NUMBER IN A0.  (RAM POINTER ASSUMED IN A9).                   *
*          CHECKSUM IS RETURNED IN A1.   THIS IS A *BYTE*.               *
*                                                                        *
*          CHECKSUM IS COMPUTED AS THE COMPLEMENT OF THE SIMPLE SUM      *
*          OF THE BYTES IN THE ENTRY.                                    *
*                                                                        *
*          THIS ROUTINE RETURNS WITH THE Z BIT SET (.EQ.) IF THE         *
*          CHECKSUM FOR THIS ENTRY MATCHES.                              *
*                                                                        *
**************************************************************************
FORM_HS_CKSUM
         MMTM    SP,A0,A4,A6,A7
         CALLR   PT_ENTRY                  ;A7 = POINTER TO CURRENT ENTRY
         MMTM    SP,A7                     ;SAVE POINTER TO ENTRY
         MOVI    HS_BYTES_TO_CHECK,A4      ;COUNT DOWN THE BYTES
         CLR     A1                        ;KEEP SUM IN A1
ADD_A_BYTE
         CALLR   RC_BYTEI        ;GET A BYTE INTO A0
         ADD     A0,A1                     ;ADD TO SUM
         DSJ     A4,ADD_A_BYTE             ;ONE MORE ADDED
         NOT     A1                        ;CHECKSUM IS NOW IN LOW BYTE
         ANDI    BYTE_MASK,A1                   ;MASK SO ITS COOL
	MMFM    SP,A7                     ;GET POINTER BACK
         ADDI    HS_CKBYTE,A7              ;POINT AT CHECKBYTE
         CALLR   RC_BYTE            ;READ IN THE BYTE
         CMP     A0,A1                     ;COMPARE WHAT'S THERE TO WHAT WE GOT
	MMFM    SP,A0,A4,A6,A7                  ;Z BIT RETURNS COMPARE
	RETS                              ;A1 RETURNS CKSUM

**************************************************************************
*                                                                        *
*          FORM_HS_CKSUM_AND_STORE                                       *
*                                                                        *
*          THIS IS USED TO SET THE CHECKSUM FOR THE CURRENT              *
*          ENTRY (A0) TO THE CORRECT VALUE.                              *
*                                                                        *
**************************************************************************
FORM_HS_CKSUM_AND_STORE
         MMTM    SP,A0,A7
         CALLR   FORM_HS_CKSUM             ;GET THE CKSUM IN A1, POINTER IN A7
         CALLR   PT_ENTRY                  ;POINT AT THE VALUE
         ADDI    HS_CKBYTE,A7              ;POINT AT CHECKBYTE
         MOVE    A1,A0                     ;GET CHECKBYTE TO A0
         CALLR   WC_BYTE           ;WRITE OUT THE BYTE
	MMFM    SP,A0,A7
	RETS

**************************************************************************
*                                                                        *
*          PT_ENTRY                                                      *
*                                                                        *
*          THIS IS CALLED TO POINT AT A GIVEN ENTRY OF                   *
*          THE HIGH SCORE TABLE.  THIS ROUTINE BASES                     *
*          ACTIVITY ON ROM POINTER IN A8.  IT FETCHES                    *
*          FRESH COPIES OF THE A9 RAM POINTER AND THE                    *
*          A10 ENTRY COUNTER.  IT RETURNS THE ENTRY                      *
*          POINTER IN A7.                                                *
*                                                                        *
*          A0 SPECIFIES WHICH ENTRY TO POINT AT                          *
*          A8,A9,A10 AND SYSCTRL ASSUMED SET PROPERLY                    *
*          A7 RETURNED POINTING TO THAT ENTRY                            *
*                                                                        *
**************************************************************************
PT_ENTRY
         CMP     A10,A0                   ;A10 IS MAX VALUE
         JRLS    POINTER_IN_RANGE

         .IF DEBUG
            JRUC   $                         ;HANG IN DEVELOPMENT
         .ENDIF

         MOVE    A9,A7                     ;RETURN ZERO OFFSET IN FIELD
         RETS

POINTER_IN_RANGE
         MOVI    HS_SIZE,A7                ;SIZE OF ENTRY
         MPYU    A0,A7                     ;OFFSET OF ENTRY
         ADD     A9,A7                     ;ADD IN THE BASE
         RETS

**************************************************************************
*                                                                        *
*          ROM_PTRS                                                      *
*                                                                        *
*          THIS IS CALLED TO LOAD UP THE ROM STRUCTURE                   *
*          DATA INTO REGISTERS.                                          *
*                                                                        *
*          THIS ALSO SETS UP STATUS WORD TO SELECT THE CMOS              *
*          BANK SELECT FOR WHERE THE PARTICULAR TABLE RESIDES.           *
*                                                                        *
*          INPUT A8    = HSTD STRUCTURE ROM POINTER.                     *
*                                                                        *
*          OUTPUT  A9  = CMOS RAM POINTER TO BASE OF TABLE               *
*          OUTPUT  A10 = LAST ENTRY IN TABLE.  TABLE WILL                *
*                          HAVE A10+1 ENTRIES SINCE ENTRY                *
*                          0 IS A FILLER.                                *
*                                                                        *
**************************************************************************
ROM_PTRS
         MMTM    SP,A0,A1                  ;SCRATCH REGGIES
         MOVE    *A8(TB_POINTER),A9,L      ;GET CMOS POINTER
         MOVE    *A8(TB_COUNT),A10,W       ;GET NUMBER OF ENTRIES
         MOVE    *A8(TB_PAGE_BITS),A1      ;GET OUR CMOS PAGE BITS

         CALLR   SET_PAGE                  ;

	MMFM    SP,A0,A1                  ;SCRATCH REGGIES
	RETS

**************************************************************************
*                                                                        *
*          SET_PAGE                                                      *
*                                                                        *
*          This is called to set the CMOS page to the bits               *
*          contained in A1.                                              *
*                                                                        *
**************************************************************************
SET_PAGE
         MMTM    SP,A0,A1
         ANDI    CMOS_PAGE_SELECT_BITS,A1  ;KILL SIGN EXTEND..SAVE BITS
         PUSHST                            ;SAVE INTERRUPT STATUS
         DINT                              ;STOP INTERRUPTS
         MOVE    @SYSCOPY,A0,W             ;GET THE RAM COPY
         ANDNI   CMOS_PAGE_SELECT_BITS,A0  ;REMOVE THE CURRENT PAGE SELECT
         OR      A1,A0                     ;ADD IN OUR BITS
         MOVE    A0,@SYSCOPY,W             ;PUT THEM BACK IN THE RAM COPY
         MOVE    A0,@SYSCTRL,W             ;NOW THE HARDWARE
         POPST                             ;OK TO RE-START INTS
	MMFM    SP,A0,A1
	RETS

**************************************************************************
*                                                                        *
*          INIT_TAB                                                      *
*                                                                        *
*          This entrypoint is called at power up to                      *
*          clear out "today's" high score table.  We do                  *
*          this job, and then we do the job on the                       *
*          all time table for high score reset if                        *
*          necessary.                                                    *
*                                                                        *
**************************************************************************
INIT_TAB MMTM    SP,A8,A0

         MOVI    TOD_TAB,A8
         CALLR   INIT_TB         ;RESET TODAYS TABLE

	.IF	0
         CALLR   GET_HSC         ;CHECK THE HIGH SCORE RESET COUNTER
         JRNZ    INIT_TAB1        ;NOT ZERO...NO MORE ACTIVITY
*
*        ITS ZERO....SEE IF ITS TURNED OFF
*
         MOVI    ADJHSRES,A0
         CALLA   GET_ADJ              ;GET THE ADJUSTED VALUE
         JRZ     INIT_TAB1            ;ITS TURNED OFF...NO ACTION.
	.ENDIF

         MOVI    ALL_TAB,A8      ;RESET THE ALL TIME TABLE
         CALLR   INIT_TB         ;INIT THE ALL TIME TABLE

         CALLR   INIT_HSR        ;RESET THE COUNTER TO ADJUSTED VALUE

INIT_TAB1
	MMFM    SP,A8,A0
	RETS

**************************************************************************
*                                                                        *
*          INIT_TB                                                       *
*                                                                        *
*          THIS IS CALLED TO SETUP A HIGH SCORE TABLE WITH               *
*          FACTORY ENTRIES.                                              *
*                                                                        *
*          A8 = ROM TABLE POINTER                                        *
*                                                                        *
**************************************************************************
INIT_TB
         MMTM    SP,A5,A6,A7,A0
         CALLR   ROM_PTRS             ;STUFF TABLE DATA
         MOVE    *A8(TB_FACTORY),A6,L ;GET THE FACTORY TABLE
         MOVE    A10,A5               ;NUMBER OF VALID ENTRIES
         INC     A5                   ;1 MORE TO HOLD ZERO ENTRY
         MOVI    HS_SIZE_IN_BYTES,A1  ;SIZE OF 1 ENTRY
         MPYU    A1,A5                ;A7 HAS NUMBER OF WORDS TO MOVE
         MOVE    A9,A7                ;CMOS POINTER IN A7

INIT_TB_1
         MOVB    *A6,A0               ;GET A BYTE FROM ROM
         ADDI    BYTE_SIZE,A6         ;KICK ROM POINTER
         CALLR   WC_BYTEI  ;WRITE THE BYTE AND INCREMENT
         DSJS    A5,INIT_TB_1        ;UNTIL THEY'RE ALL THERE.

         MOVE    A10,A0               ;POINT AT LAST ENTRY
INIT_TB_2
         CALLR   FORM_HS_CKSUM_AND_STORE   ;SET ITS CHECKSUM
         DEC     A0                   ;MOVE DOWN
         JRNN    INIT_TB_2           ;SET EACH ONE INCLUDING ZERO
	MMFM    SP,A5,A6,A7,A0
	RETS
         
**************************************************************************
*                                                                        *
*          KILL_TAB                                                      *
*                                                                        *
*          THIS IS CALLED TO SMASH A HIGH SCORE TABLE.                   *
*                                                                        *
**************************************************************************
*KILL_TAB
*         MMTM    SP,A5,A6,A7,A0
*         CALLR   ROM_PTRS             ;STUFF TABLE DATA
*         MOVE    A10,A0               ;POINT AT LAST ENTRY
*KILL_TAB_2
*
*         MMTM    SP,A0,A7
*         CALLR   FORM_HS_CKSUM             ;GET THE CKSUM IN A1, POINTER IN A7
*         CALLR   PT_ENTRY                  ;POINT AT THE VALUE
*         ADDI    HS_CKBYTE,A7              ;POINT AT CHECKBYTE
*         MOVE    A1,A0                     ;GET CHECKBYTE TO A0
*         INC     A0                        ;BAD CKSUM
*         CALLR   WC_BYTE                   ;WRITE OUT THE BYTE
*	MMFM    SP,A0,A7
*
*         DEC     A0                   ;MOVE DOWN
*         JRNN    KILL_TAB_2           ;SET EACH ONE INCLUDING ZERO
*	MMFM    SP,A5,A6,A7,A0
*	RETS
*         
**************************************************************************
*                                                                        *
*          COPY_ENTRY                                                    *
*                                                                        *
*          THIS IS CALLED TO COPY 1 ENTRY OF THE TABLE TO A              *
*          DIFFERENT LOCATION IN THE TABLE.                              *
*                                                                        *
*          A8,A9,A10,SYSCTRL ASSUMED TO BE SETUP ALREADY                 *
*          A2 = SOURCE ENTRY  (NUMBER)                                   *
*          A3 = DESTINATION ENTRY (NUMBER)                               *
*                                                                        *
**************************************************************************
COPY_ENTRY
         MMTM    SP,A0,A4,A5,A6,A7
         MOVI    HS_SIZE_IN_BYTES,A4      ;ENTRY SIZE IN BYTES
         MOVE    A2,A0                    ;FIRST POINT FOR A0
         CALLR   PT_ENTRY           
         MOVE    A7,A6                    ;A6 = SOURCE POINTER
         MOVE    A3,A0
         CALLR   PT_ENTRY                 ;A5 = DESTINATION
         MOVE    A7,A5
COPY_LOOP
*
*        IN THIS LOOP WE MOVE A BYTE AT A TIME.
*        SINCE THE WORD AND LONG DO THE SHIFTING AND
*        MASKING AND CALL MULTIPLE ROUTINES, THIS IS 
*        THE MOST EFFICIENT MODE OF OPERATION.
*
         MOVE    A6,A7                    ;SOURCE IN CMOS REGGIE
         CALLR   RC_BYTEI       ;FETCH A WORD
         MOVE    A7,A6
         MOVE    A5,A7                    ;DESTINATION
         CALLR   WC_BYTEI      ;WRITE IT
         MOVE    A7,A5                    ;BACK TO DEST REGGIE
         DSJ     A4,COPY_LOOP             ;UNTIL ALL WORDS ARE COPIED
	MMFM    SP,A0,A4,A5,A6,A7
	RETS

**************************************************************************
*                                                                        *
*          VAL_TAB                                                       *
*                                                                        *
*          THIS ROUTINE IS CALLED WHEN WE ARE INTERESTED IN              *
*          THE HSTD TABLE DATA.  A8 CONTAINS THE ROM POINTER             *
*          FOR THE TABLE.  FOR ANY ENTRIES THAT WE THROW                 *
*          OUT, WE MOVE THE REST OF THE TABLE UP, AND CREATE             *
*          A NEW ENTRY AT THE END OF THE TABLE.                          *
*                                                                        *
*          A2 = 0 ON OUTSIDE CALL.                                       *
*          A2 = 1 ON RECURSIVE CALL (THE CHECK AFTER RE-INIT)            *
*                                                                        *
*          THERE ARE 3 CHECKS MADE FOR EACH ENTRY:                       *
*                                                                        *
*          1)      IS CHECKSUM CORRECT.                                  *
*          2)      IS SCORE ALL NUMERIC                                  *
*          3)      ARE INITIALS ALL VALID ENTRIES.                       *
*                                                                        *
*        OUTPUT CC = TABLE OK                                            *
*               CS = PROBLEM THAT CAN'T BE RECTIFIED                     *
*                    (PROBABLY BAD RAM)                                  *
*                                                                        *
*               A2 = 0 ...table ok, or cleaned up                        *
*               A2 otherwise meanes table initialized                    *
*                                                                        *
**************************************************************************
VAL_TAB
         CLR     A2              ;indicate first call in
         CALLR   DO_VALIDATE     ;validate
	RETS

DO_VALIDATE
         MMTM    SP,A0,A1,A3,A4,A5,A6,A7
         CALLR   ROM_PTRS                  ;SETUP FOR TABLE
         MOVI    1,A0                      ;ITERATE THROUGH THE ENTRIES
         CLR     A1                        ;COUNT ERRORS

CHECK_A0_ENTRY
         CALLR   CHECK_ENTRY               ;IS THE ENTRY OK?
         JRNC    VT_1                      ;YEP.

         CALLR   REMOVE_ENTRY              ;REMOVE THIS ENTRY
         INC     A1
         MOVE    *A8(TB_ERROR_COUNT),A3    ;GET THRESHOLD
         CMP     A3,A1                     ;ARE WE THERE?
         JRLO    CHECK_A0_ENTRY            ;NOPE...CHECK MOVE UP ENTRY AT A0
*
*        TABLE IS MESSED UP....RE-INITIALIZE IT PLEASE
*
         MOVE    A2,A2                     ;IS THIS RECURSIVE CHECK AFTER INIT?
         JRNZ    CANT_VALIDATE             ;THEN RETURN FAILURE

         CALLR   INIT_TB                  ;INIT THIS TABLE PLEASE
         MOVK    1,A2                      ;INDICATE RECURSIVE CALL
         CALLR   DO_VALIDATE               ;IS IT ALRIGHT NOW?
	MMFM    SP,A0,A1,A3,A4,A5,A6,A7
	RETS
*
*        LAST ENTRY WAS VALID...MOVE TO NEXT
*
VT_1     INC     A0                        ;KICK IT
         CMP     A10,A0                    ;STILL IN TABLE?
         JRLS    CHECK_A0_ENTRY            ;YEP....CHECK THIS ENTRY

         CLRC                              ;RETURN VALID!
	MMFM    SP,A0,A1,A3,A4,A5,A6,A7
	RETS

CANT_VALIDATE
         SETC                              ;RETURN FAILURE!
	MMFM    SP,A0,A1,A3,A4,A5,A6,A7
	RETS

**************************************************************************
*                                                                        *
*          CHECK_ENTRY                                                   *
*                                                                        *
*          THIS IS CALLED TO CHECK THE ENTRY INDICATED BY                *
*          A0.                                                           *
*                                                                        *
*          CC = OK                                                       *
*          CS = ENTRY BAD                                                *
*                                                                        *
**************************************************************************
CHECK_ENTRY
         MMTM    SP,A0,A1,A2,A3,A7

         CALLR   FORM_HS_CKSUM             ;CHECK OUT CKSUM FIRST
         JRNZ    CHECK_FAIL                ;BAD CHECKSUM....ITS BAD
*
*        CHECKSUM OK...CHECK SCORE
*
         CALLR   GET_HSCR       ;SCORE IN A1
         MOVE    A1,A3                     ;SAVE COPY OF SCORE

CHECK_DIGIT
         MOVE    A1,A2                     ;COPY FOR NEXT NIBBLE
         ANDI    0FH,A2                    ;MASK THE NIBBLE
         CMPI    9,A2
         JRHI    CHECK_FAIL                ;NIBBLE TOO HIGH
         SRL     4,A1                      ;SHIFT DOWN TO NEXT NIBBLE
         JRNZ    CHECK_DIGIT

         DEC     A0                        ;MAKE SURE WE ARE LOWER THAN PREVIOUS SCORE!
         JREQ    FIRST_ENT                 ;WE'RE THE 1ST IN THE TABLE

         CALLR   GET_HSCR       ;GET THE SCORE FOR THE GUY BEFORE US
         CMP     A1,A3                     ;OURS MUST BE LOWER OR SAME
         JRHI    CHECK_FAIL                ;OURS IS BIGGER....REMOVE US

FIRST_ENT
         INC     A0                        ;RESTORE THE ENTRY NUMBER
*
*        SCORE OK...CHECK INITIALS
*
         CALLR   PT_ENTRY                  ;POINT A7 AT ENTRY
         ADDI    HS_INITS,A7               ;POINT AT FIRST INITIAL
         MOVI    NUM_INITS,A2              ;THIS IS NUMBER OF INITIALS

NEXT_LETTER
         CALLR   RC_BYTEI        ;FETCH A BYTE

         CALLR   VERIFY_LETTER             ;SEE IF ITS VALID.
         JRC     CHECK_FAIL                ;NOT A LETTER...BYTE

         DSJ     A2,NEXT_LETTER

         CLRC                              ;RETURN PASS
	MMFM    SP,A0,A1,A2,A3,A7
	RETS

CHECK_FAIL
         SETC
	MMFM    SP,A0,A1,A2,A3,A7
	RETS


**************************************************************************
*                                                                        *
*          VERIFY_LETTER                                                 *
*                                                                        *
*          THIS IS CALLED FOR EACH INITIAL LETTER TO SEE                 *
*          IF ITS VALID.                                                 *
*                                                                        *
*          CC = VALID                                                    *
*          CS = NOT VALID                                                *
*                                                                        *
**************************************************************************

VERIFY_LETTER
	ANDI	BYTE_MASK,A0		;KEEP JUST THE BYTE

	CMPI	SPACE,A0		;BETWEEN SPACE-Z?
****	JREQ	VERIFY_PASS		;ITS OK.
	JRLO	VERIFY_FAIL		

****	CMPI	LET_A,A0		;BETWEEN A-Z?
****	JRLO	VERIFY_FAIL

	CMPI	LET_Z,A0
	JRHI	VERIFY_FAIL

VERIFY_PASS
	CLRC
	RETS

VERIFY_FAIL
	SETC
	RETS

**************************************************************************
*                                                                        *
*          REMOVE_ENTRY                                                  *
*                                                                        *
*          THIS IS CALLED TO REMOVE A BAD ENTRY FROM THE TABLE.          *
*          IT DELETES THE ENTRY INDICATED BY A0.                         *
*                                                                        *
*          IT BUBBLES THE REST OF THE TABLE UP 1 UNIT.                   *
*                                                                        *
*          IT THEN PUTS THE LOWEST SCORE FROM THE ROM TABLE              *
*          WITH INITIALS IN THAT ENTRY.                                  *
*                                                                        *
**************************************************************************
REMOVE_ENTRY
         MMTM    SP,A0,A1,A2,A6,A7
         MOVE    A0,A3                ;THIS IS DEST
         MOVE    A3,A2                ;SOURCE IS 1 BELOW

BUBBLE_ANOTHER
         INC     A2                   ;NOW WE'RE SET FOR A COPY...

         CMP     A10,A2               ;IS SOURCE OUT OF RANGE?
         JRHI    BUBBLE_DONE          ;YEP....WE'RE AT THE BOTTOM (A3)

         CALLR   COPY_ENTRY
         INC     A3
         JRUC    BUBBLE_ANOTHER

BUBBLE_DONE
         MOVE    A3,A0                ;THIS IS BOTTOM OF TABLE
         CALLR   PT_ENTRY             ;A7 POINTS AT CMOS BLOCK

         MOVE    *A8(TB_FACTORY),A6,L  ;GET FACTORY TABLE
         MOVI    HS_ROM_SIZE,A1        ;SIZE OF ENTRY
         MPYU    A10,A1                ;TIMES NUMBER OF VALID ENTRIES..POINTS AT LAST.
         ADD     A1,A6                 ;NOW WE POINT AT END OF ROM TABLE
         MOVI    HS_SIZE_IN_BYTES,A2   ;SIZE OF ENTRY

REPLACE_LOOP
         MOVB    *A6,A0             ;MOVE A ROM BYTE TO A0
         ADDI    BYTE_SIZE,A6
         CALLR   WC_BYTEI  ;WRITE THE WORD AND INCREMENT
         DSJ     A2,REPLACE_LOOP      ;UNTIL THEY'RE ALL THERE.

         MOVE    A10,A0               ;POINT AT "LAST" ENTRY
         CALLR   FORM_HS_CKSUM_AND_STORE   ;STORE THE CHECKBYTE
	MMFM    SP,A0,A1,A2,A6,A7         ;AND RETURN
	RETS

**************************************************************************
*                                                                        *
*          CMOS UTILITIES                                                *
*                                                                        *
**************************************************************************

**************************************************************************
*                                                                        *
*          FOR ALL OF THESE CMOS ROUTINES.                               *
*                                                                        *
*                  A7 = POINTER TO MEMORY                                *
*                  A0 = DATA TO/FROM MEMORY                              *
*                                                                        *
**************************************************************************
*
*        ****  IMPORTANT NOTE ON WORD AND LONG WORD PACKING  ****
*        ****  IMPORTANT NOTE ON WORD AND LONG WORD PACKING  ****
*        ****  IMPORTANT NOTE ON WORD AND LONG WORD PACKING  ****
*        ****  IMPORTANT NOTE ON WORD AND LONG WORD PACKING  ****
*        ****  IMPORTANT NOTE ON WORD AND LONG WORD PACKING  ****
*
*        NOTE THAT REQUESTS FOR WORDS RETURN THE 2 BYTES PACKED
*        INTO A WORD AS <1ST BYTE><2ND BYTE>.   THIS IS NOT
*        THE SAME WAY THAT THE GSP HANDLES A WORD POINTED AT
*        WITH A POINTER.
*
*        LONG WORDS WORK SIMILARLY:
*
*           MSB                                              LSB
*               <1ST BYTE> <2ND BYTE> <3RD BYTE> <4TH BYTE>
*
*        TOUGH LUCK INTEL HACKERS!
*
*
*        RC_BYTE
*        WC_BYTE
*
*        These 2 routines are the only routines that ever touch
*        CMOS ram.  This is done to localize the effect of
*        changes in the architecture.  All efforts to deal with
*        CMOS should come through these routines.  Locking
*        hardware will be easily added in the future (as well
*        as different memory mapping).
*
RC_BYTE
         MOVB    *A7,A0
         ANDI    BYTE_MASK,A0
         RETS

WC_BYTE
         MOVB    A0,*A7          ;WRITE OUT THE BYTE
         RETS                    ;AND RETURN

**************************************************************************
*                                                                        *
*          RC_BYTEI                                            *
*                                                                        *
*          READ BYTE POINTED TO BY A7...INCREMENT POINTER TO             *
*          "NEXT" BYTE.                                                  *
*                                                                        *
**************************************************************************
RC_BYTEI
         CALLR   RC_BYTE
         ADDI    C_BYTE_SIZE,A7    ;WORDS SEPARATE CMOS BYTES.
         MOVE    A0,A0             ;RETURN FLAGS ACCORDINGLY
         RETS

RC_WORD
         MMTM    SP,A1,A7              ;USE A1 TO COMBINE BYTES
         CALLR   RC_BYTEI    ;GET A BYTE
         MOVE    A0,A1                 ;SAVE IN A1
         ANDI    BYTE_MASK,A1          ;MASK ONLY BYTE
         SLL     8,A1                  ;SHIFT TO HIGH BYTE
         CALLR   RC_BYTE        ;GET THE 2ND BYTE
         ANDI    BYTE_MASK,A0
         OR      A1,A0                 ;A0 HAS THE WORD
	MMFM    SP,A1,A7              
	RETS

RC_WORDI
         CALLR   RC_WORD
         ADDI    C_WORD_SIZE,A7    ;LONG SEPARATE CMOS WORDS.
         MOVE    A0,A0             ;RETURN FLAGS ACCORDINGLY
         RETS

RC_LONG
         MMTM    SP,A1,A7              ;USE A1 TO COMBINE BYTES
         CALLR   RC_WORDI    ;GET A WORD
         MOVE    A0,A1                 ;SAVE IN A1
         ANDI    WORD_MASK,A1          ;MASK ONLY WORD
         SLL     16,A1                 ;SHIFT TO HIGH WORD
         CALLR   RC_WORD        ;GET THE 2ND WORD
         ANDI    WORD_MASK,A0
         OR      A1,A0                 ;A0 HAS THE LONG WORD
	MMFM    SP,A1,A7              
	RETS

RC_LONGI
         CALLR   RC_LONG
         ADDI    C_LONG_SIZE,A7    ;DOUBLE THE DISTANCE FOR BRAIN DAMIJ
         MOVE    A0,A0             ;RETURN FLAGS ACCORDINGLY
         RETS

WC_BYTEI
         CALLR   WC_BYTE
         ADDI    C_BYTE_SIZE,A7
         RETS

WC_WORD
         MMTM    SP,A0,A1,A7
         MOVE    A0,A1           ;MAKE COPY OF WORD
         SRL     8,A0            ;GET HIGH BYTE IN A0
         CALLR   WC_BYTEI  ;WRITE THE HIGH BYTE
         MOVE    A1,A0           ;NOW GET THE LOW BYTE BACK
         CALLR   WC_BYTE ;WRITE IT
	MMFM    SP,A0,A1,A7     ;AND RESTORE ALL WE TOUCHED
	RETS

WC_WORDI
         CALLR   WC_WORD
         ADDI    C_WORD_SIZE,A7
         RETS

WC_LONG
         MMTM    SP,A0,A1,A7
         MOVE    A0,A1           ;MAKE COPY OF LONG
         SRL     16,A0           ;GET HIGH WORD IN A0
         CALLR   WC_WORDI  ;WRITE THE HIGH WORD
         MOVE    A1,A0           ;NOW GET THE LOW WORD BACK
         CALLR   WC_WORD ;WRITE IT
	MMFM    SP,A0,A1,A7     ;AND RESTORE ALL WE TOUCHED
	RETS

WC_LONGI
         CALLR   WC_LONG
         ADDI    C_LONG_SIZE,A7
         RETS

**************************************************************************
*								         *
* 	ATT_HSTD							 *
* 									 *
* 	ATTRACT MODE HIGH-SCORE TABLE PAGE				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

ATT_HSTD:
	MOVK	1,A0
	MOVE	A0,@ON_HSTD,W		; FLAG THE HSTD PAGE
	CLR	A0
	MOVE	A0,@MASTER_SEQ,W
	
	MOVI	TOD_TAB,A8
	CALLR	VAL_TAB			; CHECK TO SEE IF WE HAVE A TABLE
	JRC	ATTOUTTAHERE
	MOVI	ALL_TAB,A8
	CALLR	VAL_TAB
	JRC	ATTOUTTAHERE
	CALLA	CLR_SCRN
	CLR	A0
	MOVE	A0,@SCRNTL,L		;RE-ADJUST TOP LEFT CORNER OF SCREEN
	MOVE	A0,@GAMERASE,W		;AUTO ERASE OFF
;
	MOVK	1,A0
	MOVI	ALL_TAB,A8
	MOVI	[1,1],A9
	CALLR	PLOT_ENTRY		; PLOT OUT THE FIRST ENTRY 
	SLEEP	20
;
	DISPOFF
	MOVI	TROGCAVE2,A14
	MOVE	A14,@BAKMODS,L		; SETUP THE BACKGROUND
	CALLA	BGND_UD1
	MOVI	DUXNOFADE,A0		; EVERYBODY BUT THE DUX PAL
	MOVI	FADESORTOF,A11
	CALLA	FADEALL
	MOVI	COLORPID,A0
	CLR	A1
	NOT	A1
	CALLA	KILALL
	SLEEP	3
	DISPON
	SLEEP	2
	CLR	A0
	CLR	A1
	CALLA	KILBOBJ

	MOVI	DINOPAL1,A0
	CALLA	GETFPAL			; GET IT IN THE TABLE
	JRZ	ATTOUTTAHERE		; DIE IF NO PALETTES AROUND
	MOVI	DINOPAL1,A8
	MOVK	1,A9
	MOVK	5,A10
	MOVK	5,A11
	CREATE	INDPID,CYCLE16		; REX
	MOVK	6,A9
	MOVK	10,A10
	CREATE	INDPID,CYCLE16		; BLOOP

	MOVI	DINOPAL2,A0
	CALLA	GETFPAL			; GET IT IN THE TABLE
	JRZ	ATTOUTTAHERE		; DIE IF NO PALETTES AROUND
	MOVI	DINOPAL2,A8
	MOVK	1,A9
	MOVK	5,A10
	MOVK	5,A11
	CREATE	INDPID,CYCLE16		; SPIKE
	MOVK	6,A9
	MOVK	10,A10
	CREATE	INDPID,CYCLE16		; GWEN

	MOVI	RED16,A0
	CALLA	GETFPAL
	JRZ	ATTOUTTAHERE
	ORI	0B0B0000H,A0
	MOVE	A0,@TEMP_PAL,L
	MOVI	ALL_MESS,A8
	CALLA	LM_SETUP
	MOVE	@TEMP_PAL,A5,L
	JSRP	PRINTF
	MOVI	TODAY_MESS,A8
	CALLA	LM_SETUP
	MOVE	@TEMP_PAL,A5,L
	JSRP	PRINTF
	MOVI	CREDIT_TEXT,A8
	CALLA	LM_SETUP
	CALLA	GET_CSTR	  	; GET THE CREDIT STRING
	MOVE	@TEMP_PAL,A5,L
	JSRP	PRINTF			; PRINT THE SCORE THING

	MOVE	@MASTER_SEQ,A0,W
	MOVE	A0,@COLOR_SEQ,W
	MOVI	TOD_TAB,A8
	MOVI	TOD_LOC,A10
	CALLR	PLOT_TABLE

	MOVE	@MASTER_SEQ,A0,W
	MOVE	A0,@COLOR_SEQ,W
	MOVI	ALL_TAB,A8
	MOVI	ALL_LOC,A10
	CALLR	PLOT_TABLE
	SLEEP	21
	MOVI	FADETHEREST,A11
	MOVI	RED16,A0
	CALLA	FADE_ONLY
	MOVI	BLUE16,A0
	CALLA	FADE_ONLY
	MOVI	YELLOW16,A0
	CALLA	FADE_ONLY
	MOVI	PINK16,A0
	CALLA	FADE_ONLY
	MOVI	DUXPAL,A0
	CALLA	FADE_ONLY
	SLEEP	9
	CALLA	COLOR_START
	MOVI	TODAY_MESS,A8
	CALLA	LM_SETUP
	MOVI	TROG_PRGB,A5
	JSRP	PRINTF
	MOVI	ALL_MESS,A8
	CALLA	LM_SETUP
	MOVI	TROG_PLF,A5
	JSRP	PRINTF
	SLEEP	400
ATTOUTTAHERE
	CLR	A0
	MOVE	A0,@ON_HSTD,W
	RETP

CREDIT_TEXT:
	MESS_MAC RD7FONT,1,198,243,TROG_PRED,STRCNRMS,0
	.EVEN

**************************************************************************
*								         *
* 	PLOT_TABLE							 *
* 									 *
* 	PLOT OUT A TABLE AT A GIVEN SET OF TABLE LOCS			 *
* 									 *
* 	ENTRY								 *
* 		A7	POINTER TO CMOS TABLE				 *
* 		A10	POINTER TO TABLE OF SCREEN LOCATIONS		 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

PLOT_TABLE:
	MOVK	1,A0			; START AT TABLE ENTRY #1
PTLOOP
	MOVE	*A10+,A9,L		; GRAB NEXT LOCATION
	JRZ	PTDONE			; NO MORE TO PLOT
	MOVE	@COLOR_SEQ,A1,W
	INC	A1
	ANDI	3,A1
	MOVE	A1,@COLOR_SEQ,W
	CALLR	PLOT_ENTRY		; PLOT IT
	INC	A0
	JRUC	PTLOOP
PTDONE
	RETS

**************************************************************************
*								         *
* 	PLOT_ENTRY							 *
* 									 *
* 	PLOT A HIGHSCORE TABLE ENTRY					 *
* 									 *
* 	ENTRY								 *
* 		A0	ENTRY						 *
* 		A8	POINTER TO CMOS TABLE TO USE			 *
* 		A9	LOCATION ON SCREEN				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

PLOT_ENTRY:
	MMTM	SP,A0,A8,A10
	MOVE	A0,@CHAR_NUM,W
	CALLR	FETCH_SCORE
	MOVE	A1,@CHAR_SCORE,L
	CALLR	ENTRY_PTR	    	; POINT TO THE RIGHT ENTRY
	MOVI	2020H,A0
	MOVE	A0,@CHAR_PLOT,L	    	; SPACES
	MOVI	2000H,A0
	MOVE	A0,@CHAR_PLOT+32,L  	; SPACE AND A ZERO TERMINATE
	MOVE	A7,A1		    	; SAVE IT AROUND
	ADDI	HS_INITS,A7	    	; GET TO THE INITIALS
	CALLR	RC_BYTEI
	MOVB	A0,@CHAR_PLOT
	CALLR	RC_BYTEI
	MOVB	A0,@CHAR_PLOT+8
	CALLR	RC_BYTEI
	MOVB	A0,@CHAR_PLOT+16

	MOVE	A1,A7
	ADDI	HS_COL,A7
	CALLR	RC_WORD			; GET COLOR STUFF
	MOVE	A0,A0
	JRZ	USESEQ			; BR = NOTHING
	DEC	A0			; 0 BASE IT
	PUSH	A0
	ANDI	3,A0			; SANITY IS A GREAT THING
	SLL	4,A0
	ADDI	FLASHTABLE,A0
	MOVE	*A0,A5,W
	SLL	16,A5
	PULL	A0
	SLL	5,A0
	ADDI	FLASHPAL,A0
	MOVE	*A0,A0,L
	CALLA	FINDPAL
	MOVX	A0,A5			; SET THEM LOWER BITS
	MOVE	A5,@PLOT_COLOR,L
	JRUC	PEPLOT

USESEQ
	MOVE	@COLOR_SEQ,A1,W
	SLL	5,A1
   	ADDI	COLTABLE,A1
	MOVE	*A1,A0,L
	MOVI	0D0D0000H,A5
;	MOVI	0B0B0000H,A5
	CALLA	FINDPAL			; TURN IT INTO A NUMBER
	MOVX	A0,A5			; SET THEM LOWER BITS
	MOVE	A5,@PLOT_COLOR,L	; COLOR TO PLOT LITTLE DINO IN
	
PEPLOT
	CMPI	[1,1],A9		; CHECK TO SEE IF SPECIAL PAGE
	JRNZ	PELITTLE		; BR = LITTLE SCORE

	MOVI	BIGHSTD_MESS,A8	
	CALLA	LM_SETUP
;	JSRP	SIMPLE_SHADOW
	JSRP	PRINTF
	MOVE	@PLOT_COLOR,A5,L	; SET THE COLOR
	JRUC	PERET
	
PELITTLE
	MOVE	A9,A6			; SAVE LOCATION
	PUSH	A9
	PUSH	A9
	MOVI	HSTD_NUM,A8
	CALLA	LM_SETUP
	MOVE	A6,A9			; SET LOCATION
	MOVE	@PLOT_COLOR,A5,L	; SET THE COLOR
;	JSRP	SIMPLE_SHADOW
	JSRP	PRINTF
	PULL	A6			; YEAH, I KNOW -- A9, DOWN A6 UP
	MOVI	HSTD_MESS,A8
	CALLA	LM_SETUP
	MOVE	A6,A9			; SET LOCATION
	MOVE	@PLOT_COLOR,A5,L	; SET THE COLOR
;	JSRP	SIMPLE_SHADOW
	JSRP	PRINTF
	PULL	A6			; YEAH, I KNOW -- A9, DOWN A6 UP
	ADDI	88,A6
	MOVI	HSTD_SCORE,A8
	CALLA	LM_SETUP
	MOVE	A6,A9
	MOVE	@PLOT_COLOR,A5,L	; SET THE COLOR
;	JSRP	SIMPLE_SHADOW
	JSRP	PRINTF
PERET
	MMFM	SP,A0,A8,A10
	RETS

FLASHTABLE
	.WORD	0101H, 0606H, 0101H, 0606H

FLASHPAL
	.LONG	DINOPAL1, DINOPAL1, DINOPAL2, DINOPAL2

COLTABLE
	.LONG	RED16,BLUE16,YELLOW16,PINK16

**************************************************************************
*								         *
* 	SIMPLE_SHADOW							 *
* 									 *
* 	ENTRY								 *
* 		A8	POINTER TO TEXT					 *
* 									 *
* 	EXIT								 *
* 		A8 ( PRESERVED )					 *
* 									 *
* 	CALL								 *
* 		JSRP							 *
*								         *
**************************************************************************

	.IF	0
SIMPLE_SHADOW:
	MMTM	SP,A5,A8,A9
	ADDI	[1,1],A9		; UPPER LEFT LIGHT SOURCE
	MOVI	TROG_PBLACK,A5		; TURN IT BLACK
	JSRP	PRINTF
	MMFM	SP,A5,A8,A9
	RETP
	.ENDIF



**************************************************************************
*								         *
* 	FETCH_SCORE							 *
* 									 *
* 	GET THE SCORE FOR A GIVEN ENTRY IN THE HIGHSCORE TABLE		 *
* 									 *
* 	ENTRY								 *
* 		A0	ENTRY NUMBER					 *
* 		A8	TABLE TO GET SCORE FROM				 *
* 									 *
* 	EXIT								 *
* 		A1	SCORE						 *
*								         *
**************************************************************************
	
FETCH_SCORE:
	MMTM	SP,A9,A10
         CALLA   ROM_PTRS                  ;GET SYSTEM READY TO ACCESS THIS ONE
         CALLA   GET_HSCR                  ;NOW FETCH THE SCORE IN A1.
	MMFM	SP,A9,A10
         RETS

**************************************************************************
*								         *
* 	ENTRY_PTR							 *
* 									 *
* 	SET A7 TO POINT TO A GIVEN SCORE ENTRY				 *
* 									 *
* 	ENTRY								 *
* 		A0	ENTRY NUMBER					 *
* 		A8	TABLE TO GET SCORE ENTRY FROM			 *
* 									 *
* 	EXIT								 *
* 		A7	POINTER TO TABLE ENTRY				 *
*								         *
**************************************************************************

ENTRY_PTR:
	MMTM	SP,A9,A10
	CALLA   ROM_PTRS       	; SETUP STUFF
	CALLA   PT_ENTRY	; POINT A7 AT ENTRY
	MMFM	SP,A9,A10
	RETS



CLEAR_HSCOLORS
	MMTM	SP,A0,A1,A7,A8
	MOVI	TOD_TAB,A8
	MOVK	10,A0
CTL1
	CALLR	ENTRY_PTR
	PUSH	A0
	CLR	A0
	ADDI	HS_COL,A7
	CALLR	WC_WORD
	PULL	A0
	PUSH	A8
	CALLA	ROM_PTRS
	CALLR	FORM_HS_CKSUM_AND_STORE
	PULL	A8
	DSJS	A0,CTL1

	MOVI	ALL_TAB,A8
	MOVK	20,A0
CTL2
	CALLR	ENTRY_PTR
	PUSH	A0
	CLR	A0
	ADDI	HS_COL,A7
	CALLR	WC_WORD
	PULL	A0
	PUSH	A8
	CALLA	ROM_PTRS
	CALLR	FORM_HS_CKSUM_AND_STORE
	PULL	A8
	DSJS	A0,CTL2
	MMFM	SP,A0,A1,A7,A8
	RETS


**************************************************************************
*								         *
* 	INIT_HSHOLD							 *
* 									 *
* 	INITIALIZE THE HIGHSCORE HOLD TABLE				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

INIT_HSHOLD:
	MMTM	SP,A0,A1,A2

	MOVI	RHSTAB,A0	
	CLR	A2
IHSLOOP
	MOVE	*A0+,A1,L
	JRZ	IHSDONE
	MOVE	A2,*A1,W		; CLEAR THE VALID FLAG
	JRUC	IHSLOOP

IHSDONE
	MMFM	SP,A0,A1,A2
	RETS

**************************************************************************
*								         *
* 	ADD_HSHOLD							 *
* 									 *
* 	ADD AN ENTRY TO THE HIGHSCORE HOLDING AREA			 *
* 									 *
* 	ENTRY								 *
* 		A0	SCORE						 *
* 		A1	PTR TO INITIALS					 *
* 		A8	PTR TO PLAYER DATA AREA 			 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

ADD_HSHOLD:
	MMTM	SP,A0,A1,A2,A3,A8
	PUSH	A0
	MOVE	A8,A2
	CALLA	GPLAYNUM		; GET PLAYER NUMBER
	MOVE	A0,A3
	INC	A0			; 1 BASE THIS ONE
	MOVE	A0,A2			; WHAT TO STICK IN "HS_SCORE"
	PULL	A0
	ANDI	3,A3			; SANITY PLAYER NUMBER
	SLL	5,A3
	ADDI	RHSTAB,A3
	MOVE	*A3,A3,L
	MOVE	A0,*A3(RHS_SCORE),L
	MOVE	A2,*A3(RHS_COL),L
	MOVK	1,A2
	MOVE	A2,*A3(RHS_VALID),W	; FLAG IT AS VALID
	MOVI	NUM_INITS,A0
	ADDI	RHS_INITS,A3
ADDLOOP
	MOVB	*A1,*A3
	ADDK	8,A1
	ADDK	8,A3
	DSJS	A0,ADDLOOP
ADDHSRET
	MMFM	SP,A0,A1,A2,A3,A8
	RETS


**************************************************************************
*								         *
* 	EMPTY_HSHOLD							 *
* 									 *
* 	CLEAR OUT THE HSHOLD TABLES INTO CMOS				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

EMPTY_HSHOLD

	MMTM	SP,A0,A1,A2,A3,A4,A8
	
	MOVI	RHSTAB,A3
EMPTYLOOP
	MOVE	*A3+,A4,L
	JRZ	EMPTYDONE
	MOVE	*A4,A0,W
	JRZ	EMPTYLOOP		; BR = NOT A VALID ENTRY
	MOVE	*A4(RHS_SCORE),A0,L	; SCORE
	MOVE	*A4(RHS_COL),A2,W	; COLOR
	MOVE	A4,A1
	ADDI	RHS_INITS,A1		; POINTER TO INITIALS
	MOVI	ALL_TAB,A8   		; CHECK ALL TIME TABLE FIRST
	CALLR	ADD_ENTRY
	MOVI	TOD_TAB,A8		; TODAY'S TABLE
	CALLR	ADD_ENTRY
	JRUC	EMPTYLOOP
EMPTYDONE
	CALLR	INIT_HSHOLD		; CLEAR OUT EVERYTHING
	MMFM	SP,A0,A1,A2,A3,A4,A8
	RETS

RHSTAB	.LONG	HOLDINITS,HOLDINITS+RHS_SIZE
	.LONG	HOLDINITS+(2*RHS_SIZE)
	.LONG	HOLDINITS+(3*RHS_SIZE)
	.LONG	0
	

*****************************************************************************
*****************************************************************************
*****
*****    DEFAULT ROM HSTD TABLES AND TABLE DEFINITIONS
*****
*****************************************************************************
*****************************************************************************

TB_POINTER       EQU     0                      ;LONG-POINTER TO BEGINNING OF TABLE
TB_COUNT         EQU     TB_POINTER+LONG_SIZE   ;WORD....# IN THE TABLE.
TB_VISIBLE       EQU     TB_COUNT+WORD_SIZE ;WORD....NUMBER DISPLAYED
TB_PAGE_BITS     EQU     TB_VISIBLE+WORD_SIZE     ;WORD....STATUS WORD FOR CMOS PAGE
TB_FACTORY       EQU     TB_PAGE_BITS+WORD_SIZE   ;LONG....ROM STARTUP TABLE
TB_ERROR_COUNT   EQU     TB_FACTORY+LONG_SIZE     ;WORD....NUM ERRORS TO RE-INIT
*

SCR_M    $MACRO  A,B,C,D
         .BYTE   :A:
         .BYTE   :B:
         .BYTE   :C:
         .BYTE   :D:
         $END

INIT_M   $MACRO  A,B,C
         .BYTE   :A:
         .BYTE   :B:
         .BYTE   :C:
         .BYTE   0               ;CHECKBYTE
         $END

ALL_TIME_ROM_TABLE:
         SCR_M   95H,12H,21H,45H                ;****ZERO ENTRY...NOT SEEN!
	.WORD	0
         INIT_M  "G","N","P"
ROM_ENTRY_SIZE      EQU     $-ALL_TIME_ROM_TABLE
         SCR_M   02H,00H,00H,01H
	.WORD	0
         INIT_M  "J","E","H"           ;1	JACK
         SCR_M   01H,97H,83H,21H
	.WORD	0
         INIT_M  "G","N","P"           ;2	GEORGE
         SCR_M   01H,92H,15H,24H
	.WORD	0
         INIT_M  "L","E","P"           ;3	LESLIE
         SCR_M   01H,89H,62H,17H
	.WORD	0
         INIT_M  "C","S","D"           ;4       CAROL    
         SCR_M   01H,83H,70H,77H
	.WORD	0
         INIT_M  "J","A","H"           ;5	LITTLE JACK
         SCR_M   01H,80H,01H,76H
	.WORD	0
         INIT_M  "G","G","F"           ;6	FRERES
         SCR_M   01H,75H,58H,21H
	.WORD	0
         INIT_M  "R","J","C"           ;7	RAY CZAJKA
         SCR_M   01H,69H,10H,02H
	.WORD	0
         INIT_M  "R","A","Y"           ;8	RAY GAY
         SCR_M   01H,61H,72H,16H
	.WORD	0
         INIT_M  "E","P","J"           ;9
         SCR_M   01H,52H,89H,59H 
	.WORD	0
         INIT_M  "L","E","D"           ;10
         SCR_M   01H,44H,21H,27H                 
	.WORD	0
         INIT_M  "M","D","R"           ;11
         SCR_M   01H,35H,71H,11H
	.WORD	0
         INIT_M  "E","J","B"           ;12
         SCR_M   01H,24H,08H,47H
	.WORD	0
         INIT_M  "A","K","N"           ;13
         SCR_M   01H,17H,42H,21H
	.WORD	0
         INIT_M  "L","E","B"           ;14
         SCR_M   01H,12H,32H,89H
	.WORD	0
         INIT_M  "C","L","B"           ;15
         SCR_M   01H,11H,11H,11H
	.WORD	0
         INIT_M  "D","U","X"           ;16	NOSTALGIA
         SCR_M   01H,10H,00H,00H
	.WORD	0
         INIT_M  "N","D","N"           ;17
         SCR_M   01H,09H,02H,13H
	.WORD	0
         INIT_M  "S","S","R"           ;18
         SCR_M   01H,09H,02H,12H
	.WORD	0
         INIT_M  "M","R"," "           ;19
         SCR_M   01H,09H,02H,11H
	.WORD	0
         INIT_M  "B","I","G"           ;20
         SCR_M   01H,09H,02H,10H
	.WORD	0
         INIT_M  "L","E","P"
         SCR_M   01H,09H,02H,09H
	.WORD	0
         INIT_M  "M","D","R"
         SCR_M   01H,09H,02H,08H
	.WORD	0
         INIT_M  "B","A","C"
         SCR_M   01H,09H,02H,07H
	.WORD	0
         INIT_M  "W"," ","R"
         SCR_M   01H,09H,02H,06H
	.WORD	0
         INIT_M  "M","P","T"
         SCR_M   01H,09H,02H,05H
	.WORD	0
         INIT_M  "S","U","E"
         SCR_M   01H,09H,02H,04H
	.WORD	0
         INIT_M  "M","O","M"
         SCR_M   01H,09H,02H,03H
	.WORD	0
         INIT_M  "D","A","D"
         SCR_M   01H,09H,02H,02H
	.WORD	0
         INIT_M  "S","F","D"
         SCR_M   01H,09H,02H,01H
	.WORD	0
         INIT_M  "A","K","D"
ALL_TIME_ENTRIES     EQU     ($-ALL_TIME_ROM_TABLE)/ROM_ENTRY_SIZE

TODAYS_ROM_TABLE:
         SCR_M   95H,12H,21H,45H                ;****ZERO ENTRY...NOT SEEN!
	.WORD	0
         INIT_M  "G","N","P"
         SCR_M   01H,10H,08H,65H
	.WORD	0
         INIT_M  "G","N","P"			;GEORGE
         SCR_M   01H,10H,01H,05H
	.WORD	0
         INIT_M  "J","E","H"			;JACK
         SCR_M   01H,09H,41H,52H
	.WORD	0
         INIT_M  "J","K","M"			;KURT
         SCR_M   01H,08H,72H,18H
	.WORD	0
         INIT_M  "C","P","G"			;GRANNER
         SCR_M   01H,07H,19H,20H
	.WORD	0
         INIT_M  "L","T","D"			;LINDA
         SCR_M   01H,06H,19H,19H
	.WORD	0
         INIT_M  "G","W","S"			;GLENN
         SCR_M   01H,05H,11H,19H
	.WORD	0
         INIT_M  "M"," ","L"			;LOFFREDO
         SCR_M   01H,04H,76H,30H
	.WORD	0
         INIT_M  "C","M","M"			;CARY
         SCR_M   01H,03H,90H,20H
	.WORD	0
         INIT_M  "A","L"," "			;AL
         SCR_M   01H,03H,20H,10H
	.WORD	0
         INIT_M  "L","J","R"			;LAURA
TODAYS_ENTRIES     EQU     ($-TODAYS_ROM_TABLE)/ROM_ENTRY_SIZE



**************************************************************************
*								         *
* 	STUFF FOR ATT_HSTD						 *
*								         *
**************************************************************************

HSTDY	EQU	(SKYTOPOF/2)
HSTDY2	EQU	-1*(SKYTOPOF/2)

TODAY_MESS:
	MESS_MAC RD20FONT,1,200,124+HSTDY,TROG_PRGB,STRCNRMS,0
	.STRING	"DAILY DINOS",0
	.EVEN

ALL_MESS:
	MESS_MAC RD20FONT,1,200,11+HSTDY,TROG_PLF,STRCNRMS,0	
	.STRING	"TOP TROGS",0
	.EVEN

HSTD_NUM:
	MESS_MAC RD7FONT,1,200,95+HSTDY,TROG_PBLUE,STRRNRMS,0
	.STRING	"%d> ",0
	.LONG	CHAR_NUM
	.EVEN

HSTD_MESS:
	MESS_MAC RD7FONT,1,200,95+HSTDY,TROG_PRED,STRLNRMS,0
	.STRING	"%s",0
	.LONG	CHAR_PLOT
	.EVEN

HSTD_SCORE:
	MESS_MAC RD7FONT,1,200,95+HSTDY,TROG_PYELLOW,STRRNRMS,0
	.STRING	"%,lb",0
	.LONG	CHAR_SCORE
	.EVEN

BIGBASE	EQU	15+24

BIGHSTD_MESS:
	MESS_MAC RD15FONT,1,200,BIGBASE+HSTDY,TROG_PWHITE,STRCNRMOS,0
	.STRING	"1) %s  %,lb",0
	.LONG	CHAR_PLOT
	.LONG	CHAR_SCORE
	.EVEN

ALL_LOC:
	.LONG	[1,1]			; BOGUS ENTRY -- FOR SPECIAL TOP TROG
	.LONG	[101+HSTDY2,45]
	.LONG	[111+HSTDY2,45]
	.LONG	[121+HSTDY2,45]
	.LONG	[131+HSTDY2,45]
	.LONG	[141+HSTDY2,45]
	.LONG	[101+HSTDY2,161]
	.LONG	[111+HSTDY2,161]
	.LONG	[121+HSTDY2,161]
	.LONG	[131+HSTDY2,161]
	.LONG	[141+HSTDY2,161]
	.LONG	[101+HSTDY2,277]
	.LONG	[111+HSTDY2,277]
	.LONG	[121+HSTDY2,277]
	.LONG	[131+HSTDY2,277]
	.LONG	[141+HSTDY2,277]
	.LONG	0

TOD_LOC:
	.LONG	[193+HSTDY2,100]
	.LONG	[203+HSTDY2,100]
	.LONG	[213+HSTDY2,100]
	.LONG	[223+HSTDY2,100]
	.LONG	[233+HSTDY2,100]
	.LONG	[193+HSTDY2,216]
	.LONG	[203+HSTDY2,216]
	.LONG	[213+HSTDY2,216]
	.LONG	[223+HSTDY2,216]
	.LONG	[233+HSTDY2,216]
	.LONG	0

DINOPAL1:
	.WORD	11
	.WORD	0
	.word	>3400,>5C00,>6C00,>7C00,>7D20	; REX
	.word	>9,>16,>1E,>BF,>1BF		; BLOOP

DINOPAL2:
	.WORD	12
	.WORD	0
	.word	>34A0,>65E0,>7260,>7B00,>7FE0	; SPIKE
	.word	>2806,>480E,>6011,>7015,>7C1F	; GWEN
	.WORD	>6739

FADESORTOF:
	.WORD	0,0,8,8,16,16,24,24,32,32,40,40,48,48,56,56,64,64
	.WORD	72,72,80,80,88,88,>FFFF

FADETHEREST:
	.WORD	96,96,104,104,112,112,120,120,128,>FFFF

DUXNOFADE
	.LONG	DUXPAL,0

