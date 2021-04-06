   	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGJUNK.ASM'
	.TITLE	"Kurts random routines"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

**************************************************************************
*								         *
* 		TROG Adjustments and Audit handing			 *
* 									 *
* 		Original: Larry DeMar	November 10, 1988		 *
* 		Revision: Kurt Mahan	February 19, 1990		 *
* 									 *
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

         .GLOBAL         GET_HSCR
         .GLOBAL         RC_BYTEI
         .GLOBAL         RC_BYTE
         .GLOBAL         RC_WORD
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
	.GLOBAL	KILL_AUD
	.GLOBAL	CLR_AUDR
	.GLOBAL	CLR_AUD
	.REF	NO_CREDS

	.REF	ROM_NAME

	.DEF	DEF_PAGE, GET_AUD, CMOS_VAL, FAC_SET
	.DEF	FORM_ADC, F_ADC_S, ADJ_PAGE, PUT_ADJ
	.DEF	CMOSLOCK, CMOSUNLOCK, STORE_AUDIT

FREE_PLAY	EQU	1
	
*
*        BAD_AUD - ANYTIME AN AUDIT NUMBER IS FETCHED, IF ITS
*                  CHECKSUM IS BAD, THEN BAD_AUD GETS SET TO 1
*                  THIS CAUSES "ERROR" IF ANY AUDIT IN A CALCULATION
*                  IS CORRUPTED, AND KEEPS A BAD CHECKSUM BAD WHEN
*                  AN AUDIT IS CHANGED.

         .BSS            BAD_AUD,16   ;(BAD_AUD...NOT BAD_DOG!)     
         .TEXT

**************************************************************************
*                                                                        *
*          COIN_PAG                                                     *
*                                                                        *
*          THIS SETS THE CURRENT CMOS PAGE FOR COIN/CREDITS              *
*                                                                        *
**************************************************************************
COIN_PAG
         MMTM    SP,A1
         MOVI    COIN_SELECT,A1       ;THIS IS COIN/CREDITS PAGE
         CALLA   SET_PAGE             ;SET IT PLEASE
	MMFM    SP,A1
	RETS

**************************************************************************
*                                                                        *
*         AUDIT HANDLING                                                 *
*                                                                        *
**************************************************************************
*                                                                        *
*          POINT_AT_AUDIT                                                *
*                                                                        *
*          THIS IS CALLED TO POINT AT THE AUDIT INDICATED BY             *
*          A0.  A0 IS THE AUDIT NUMBER 0-30.  A7 IS RETURNED             *
*          POINTING AT THE BEGINNING OF THE AUDIT.                       *
*                                                                        *
**************************************************************************
POINT_AT_AUDIT
         MMTM    SP,A1
         CALLR   AUDIT_PAGE

         MOVI    AUD_SIZE,A7          ;THIS IS SIZE PER AUDIT
         MPYU    A0,A7                ;A1 NOW HAS OFFSET
         ADDI    AUDITORG,A7          ;ADD BASE
	MMFM    SP,A1
	RETS

AUDIT_PAGE
         MMTM    SP,A1
         MOVI    AUDIT_SELECT,A1      ;THIS IS AUDIT PAGE
         CALLA   SET_PAGE             ;SET IT PLEASE
	MMFM    SP,A1
	RETS

**************************************************************************
*                                                                        *
*          FORM_AUD_CKSUM                                                *
*                                                                        *
*          THIS IS CALLED TO FORM THE CHECKSUM FOR THE AUDIT             *
*          SPECIFIED IN A0.                                              *
*                                                                        *
*          A1 RETURNS THE CHECKSUM.                                      *
*                                                                        *
*          Z BIT IS SET BASED ON WHETHER IT MATCHES THE CHECKSUM THERE.  *
*                                                                        *
**************************************************************************

FORM_AUD_CKSUM
         MMTM    SP,A0,A4,A7
         CALLR   POINT_AT_AUDIT            ;A7 = POINTER TO CURRENT ENTRY
         MMTM    SP,A7                     ;SAVE POINTER TO ENTRY
         MOVI    AUD_BYTES_TO_CHECK,A4     ;COUNT DOWN THE BYTES
         CLR     A1                        ;KEEP SUM IN A1
ADD_A_BYTE
         CALLA   RC_BYTEI                  ;GET A BYTE INTO A0
         ADD     A0,A1                     ;ADD TO SUM
         DSJ     A4,ADD_A_BYTE             ;ONE MORE ADDED
         NOT     A1                        ;CHECKSUM IS NOW IN LOW WORD
         ANDI    WORD_MASK,A1              ;MASK SO ITS COOL
	MMFM    SP,A7                     ;GET POINTER BACK
         ADDI    AUD_CKSUM,A7              ;POINT AT CHECKBYTE
         CALLA   RC_WORD                   ;READ IN THE CKSUM
         CMP     A0,A1                     ;COMPARE WHAT'S THERE TO WHAT WE GOT
	MMFM    SP,A0,A4,A7               ;Z BIT RETURNS COMPARE
	RETS                              ;A1 RETURNS CKSUM

**************************************************************************
*                                                                        *
*          STORE_AUD_CKSUM                                               *
*                                                                        *
*          THIS WILL STORE THE AUDIT CHECKSUM IN A1 FOR THE              *
*          AUDIT NUMBER SPECIFIED BY A0.                                 *
*                                                                        *
**************************************************************************

STORE_AUD_CKSUM
         MMTM    SP,A7,A0                  ;POINTING REGISTER
         CALLR   POINT_AT_AUDIT            ;A7 POINTS AT AUDIT
         ADDI    AUD_CKSUM,A7              ;POINT AT CHECKBYTE
         MOVE    A1,A0                     ;GET CHECKBYTE IN A0
         CALLA   WC_WORD                   ;WRITE THE CKSUM
	MMFM    SP,A7,A0                  ;POINTING REGISTER
	RETS

**************************************************************************
*                                                                        *
*          FORM_AUD_CKSUM_AND_STORE                                      *
*                                                                        *
*          THE VALUE AT BAD_AUD IS USED TO DETERMINE WHETHER TO STORE    *
*          THE CORRECT OR INCORRECT VALUE!                               *
*                                                                        *
*          A0 = AUDIT NUMBER                                             *
*                                                                        *
**************************************************************************

FORM_AUD_CKSUM_AND_STORE
         MMTM    SP,A1,A2                     ;SAVE A1!
         CALLR   FORM_AUD_CKSUM
         MOVE    @BAD_AUD,A2,W                ;GET THE "FUDGE" WORD
         XOR     A2,A1                        ;MAKE CKSUM BAD IF AUDIT IS BAD
         CALLR   STORE_AUD_CKSUM
	MMFM    SP,A1,A2
	RETS

**************************************************************************
*                                                                        *
*          GET_AUD                                                       *
*                                                                        *
*          THIS IS CALLED TO FETCH THE AUDIT VALUE FOR THE AUDIT         *
*          SPECIFIED IN A0 INTO A1.  IF THE CHECKBYTE FOR THE            *
*          AUDIT IS INCORRECT, THEN RAM LOCATION BAD_AUD WILL BE         *
*          SET TO 1.                                                     *
*                                                                        *
**************************************************************************
GET_AUD
         MMTM    SP,A7,A0
         CALLR   FORM_AUD_CKSUM       ;SEE IF CKSUM IS OK
         JRZ     FETCH_AUDIT_1        ;ITS OK....
*
*        CHECKSUM IS BAD....SET GLOBAL
*
         MOVK    1,A1
         MOVE    A1,@BAD_AUD,W        ;SET THE FLAG!

FETCH_AUDIT_1
         CALLR   POINT_AT_AUDIT       ;A7 POINTS AT AUDIT
         ADDI    AUD_DATA,A7          ;ADD ZERO OFFSET
         CALLA   RC_LONG              ;FETCH THE LONG WORD TO A0
         MOVE    A0,A1                ;RETURN IN A1
	MMFM    SP,A7,A0
	RETS

**************************************************************************
*                                                                        *
*          STORE_AUDIT                                                   *
*                                                                        *
*          A0 = AUDIT NUMBER TO STORE VALUE FOR                          *
*          A1 = VALUE TO STORE.                                          *
*          BAD_AUD = NON ZERO IF BAD CHECKSUM IS TO BE MAINTAINED.       *
*                                                                        *
**************************************************************************

STORE_AUDIT
         MMTM    SP,A0,A7
         CALLR   POINT_AT_AUDIT       ;A7 POINTS AT AUDIT
         ADDI    AUD_DATA,A7          ;ADD ZERO OFFSET
         MOVE    A1,A0                ;MOVE DATA TO WRITING REGISTER
         CALLA   WC_LONG              ;WRITE THE DATA BACK
	MMFM    SP,A0,A7             ;GET AUDIT NUMBER BACK
         JRUC    FORM_AUD_CKSUM_AND_STORE    ;STORE GOOD OR BAD CKSUM BASED
*                                            ;ON BAD_AUD

**************************************************************************
*                                                                        *
*          CLR_SUBS                                                      *
*                                                                        *
*          THIS IS CALLED TO CLEAR OUT THE COINAGE SUB-TOTALS.           *
*                                                                        *
**************************************************************************

CLR_SUBS 
	RETP
;	MOVI    FRST_SUB,A0
;        MOVI    LAST_SUB,A1
;       CALLR   CLR_AUDR        ;CLEAR EM OUT!
;         RETP

**************************************************************************
*                                                                        *
*          CLR_AUDR                                                 *
*                                                                        *
*          THIS IS CALLED TO CLEAR OUT A RANGE OF AUDITS.                *
*          A0 = 1ST AUDIT NUMBER                                         *
*          A1 = LAST AUDIT NUMBER (INCLUSIVE)                            *
*                                                                        *
**************************************************************************

CLR_AUDR
         MMTM    SP,A0,A1,A2
         MOVE    A1,A2                     ;MOVE "LAST" TO A2
         CLR     A1                        ;WE'LL STORE ZEROS
         MOVE    A1,@BAD_AUD               ;MAKE CKSUMS GOOD ON STORING
CAR1     CALLR   STORE_AUDIT               ;STORE THIS AUDIT
         INC     A0                        ;KICK TO NEXT AUDIT
         CMP     A2,A0
         JRLS    CAR1
	MMFM    SP,A0,A1,A2
	RETS

**************************************************************************
*                                                                        *
* 	KILL_AUD							 *
* 									 *
* 	This is called to clear out an audit.				 *
* 									 *
* 	A0 = audit number.						 *
*                                                                        *
**************************************************************************
KILL_AUD
	MMTM	SP,A1
        CLR     A1                        ;WE'LL STORE ZEROS
        MOVE    A1,@BAD_AUD               ;MAKE CKSUMS GOOD ON STORING
        CALLR   STORE_AUDIT               ;STORE THIS AUDIT
	MMFM	SP,A1
	RETS

**************************************************************************
*                                                                        *
*          AUD                                                           *
*                                                                        *
*          A0 = AUDIT NUMBER.......A1 = COUNT TO ADD.                    *
*                                                                        *
**************************************************************************

AUD      MMTM    SP,A1,A2
         CLR     A2                   ;SET "BAD_AUD" GOOD UNTIL OTHERWISE PROVEN!
         MOVE    A2,@BAD_AUD,W        ;ITS GOOD.
         MOVE    A1,A2                ;COPY OUR COUNT
         CALLR   GET_AUD              ;FETCH THE CURRENT AUDIT COUNTER
         ADD     A2,A1                ;ADD THE NEW COUNT
         CALLR   STORE_AUDIT          ;STORE IT BACK
         CALLR   DEF_PAGE             ;SWITCH PAGE AWAY FROM THE DATA!
	MMFM    SP,A1,A2
	RETS

AUD1     MMTM    SP,A1
         MOVK    1,A1
         CALLR   AUD
	MMFM    SP,A1
	RETS

**************************************************************************
*                                                                        *
*          CLR_AUD                                                       *
*                                                                        *
*          This is called to clear out all of the audits.                *
*                                                                        *
*          A relatively easy task given the primitives available.        *
*                                                                        *
**************************************************************************

CLR_AUD  MMTM    SP,A0,A1
         MOVI    1,A0                 ;START AT AUDIT 1
         MOVI    N_AUDITS-1,A1        ;THIS IS TOTAL ALLOCATED
         CALLR   CLR_AUDR
	MMFM    SP,A0,A1
	RETS

**************************************************************************
*                                                                        *
*          ADJUSTMENTS                                                   *
*                                                                        *
**************************************************************************

**************************************************************************
*								         *
* 	CMOS_VAL							 *
* 									 *
* 	VALIDATE THE CMOS VALUES					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		.EQ.	COOL						 *
* 		.NE.	IT IS HOSED					 *
*								         *
**************************************************************************

CMOS_VAL
        CALLR   FORM_ADC  	; SEE IF CKSUM IS OK.
        JRNZ    CMOS_BAD        ; NOPE....RETURN .NE.

        CALLR   CHECK_NAME_AND_REV   ;HOW ABOUT THE NAME AND REV?
CMOS_BAD
        RETS

**************************************************************************
*								         *
* 	FORM_ADC							 *
* 									 *
* 	DO A CHECKSUM OF THE ADJUSTMENTS AREA -- RETURNED IN A1		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		A1	CHECKSUM VALUE					 *
* 		.EQ.	AGREES WITH STORED CHECKSUM			 *
* 		.NE.	IT DON'T					 *
*								         *
**************************************************************************

FORM_ADC:
        MMTM    SP,A7,A0,A6
        CALLR   ADJ_PAGE          ;SET CMOS PAGE FOR ADJUSTMENTS
        MOVI    ADJUSTORG,A7         ;POINT AT FIRST BYTE
        MOVI    ADJ_BYTES_TO_CHECK,A6  ;NUMBER OF BYTES
        CLR     A1                     ;ACCUMULATE CKSUM HERE

ADJ_C1  CALLA   RC_BYTEI               ;READ A BYTE
        ADD     A0,A1                  ;ADD THE BYTE TO THE SUM
        DSJS    A6,ADJ_C1

        NOT     A1                     ;COMPLEMENT THE SUM
        ANDI    WORD_MASK,A1           ;KEEP A WORD.

        MOVI    ADJ_CKSUM,A7
        CALLA   RC_WORD                ;FETCH THE CHECKSUM
        CMP     A0,A1                  ;COMPARE TO FETCHED VALUE
	MMFM    SP,A7,A0,A6
	RETS

**************************************************************************
*								         *
* 	F_ADC_S								 *
* 									 *
* 	FORM AN ADJUSTMENT CHECKSUM AND STORE THE VALUE			 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

F_ADC_S:
        MMTM    SP,A0,A1,A7
        CALLR   FORM_ADC         ;FORM THE CKSUM
        MOVE    A1,A0                  ;PUT IN CMOS WRITING REGGIE
        MOVI    ADJ_CKSUM,A7
        CALLA   WC_WORD                ;AND STORE IT
	MMFM    SP,A0,A1,A7
	RETS

**************************************************************************
*								         *
* 	GET_ADJ								 *
* 									 *
* 	GETS AN ADJUSTMENT VALUE					 *
* 									 *
* 	ENTRY								 *
* 		A0	ADJUSTMENT NUMBER TO GET			 *
* 									 *
* 	EXIT								 *
* 		A0	VALUE OF ADJUSTMENT				 *
*								         *
**************************************************************************

GET_ADJ:
	MMTM    SP,A1,A7
	.IF	FORCEFREE
	CMPI	ADJFREPL,A0
	JRNZ	GANOTFREE
	MOVK	1,A0
	JRUC	GADONE
GANOTFREE
	.ENDIF
	PUSH	A0
	CALLR	FORM_ADC	; CHECKSUM THINGS
	PULL	A0
	JRZ	GACOOL		; BR = CMOS IS COOL
	SLL	5,A0
	ADDI	FACTORY_TABLE,A0
	MOVE	*A0,A0,L	; READ UP THE FACTORY ADJUSTMENT
	JRUC	GADONE
GACOOL
        CALLR   ADJPOINT             ;POINT AT ADJUSTMENT
        CALLA   RC_LONG              ;FETCH THE ADJUST PLEASE
        CALLR   DEF_PAGE
GADONE
        MOVE    A0,A0                ;RETURN Z BIT BASED ON ADJUSTMENT!
	MMFM    SP,A1,A7
	RETS

**************************************************************************
*								         *
* 	PUT_ADJ								 *
* 									 *
* 	STORE AN ADJUSTMENT VALUE.  NOTE!  DOES NOT RECHECKSUM!!	 *
* 									 *
* 	ENTRY								 *
* 		A0	ADJUSTMENT NUMBER				 *
* 		A1	ADJUSTMENT VALUE				 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

PUT_ADJ:
	MMTM    SP,A7,A0
	CALLA	CMOSUNLOCK
        CALLR   ADJPOINT             ;POINT AT REQUESTED ADJ.
        MOVE    A1,A0                ;GET VALUE IN WRITING REGGIE!
        CALLA   WC_LONG              ;WRITE THE ADJUSTMENT
        CALLR   DEF_PAGE             ;SWAP PAGE AWAY.
	CALLA	CMOSLOCK
	MMFM    SP,A7,A0
	RETS

**************************************************************************
*								         *
* 	ADJPOINT							 *
* 									 *
* 	POINT A7 AT THE CMOS MEMLOC FOR THE ADJUSTMENT			 *
* 									 *
* 	ENTRY								 *
* 		A0	ADJUSTMENT NUMBER				 *
* 									 *
* 	EXIT								 *
* 		A7	POINTER TO CMOS MEMORY				 *
*								         *
**************************************************************************

ADJPOINT:
        CALLR   ADJ_PAGE             ;SET CMOS PAGE FOR ADJUSTMENTS
        MOVI    ADJ_SIZE,A7          ;SIZE PER ADJUSTMENT IN A7
        MPYU    A0,A7                ;TIMES ADJUSTMENT REQUESTED.
        ADDI    ADJUSTORG,A7         ;ADD TO BASE
        RETS

**************************************************************************
*								         *
* 	CHECK_NAME_AND_REV						 *
* 									 *
* 	CHECK THE NAME AND THE REVISION AGAINST THE CMOS		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		.EQ.	COOL						 *
* 		.NE.	NOT COOL					 *
*								         *
**************************************************************************

CHECK_NAME_AND_REV:
        MMTM    SP,A0,A1,A2,A3,A7
        CALLR   ADJ_PAGE          ;MAKE SURE WE'RE ON THE CORRECT PAGE

        MOVI    NAME_REV,A7          ;POINT AT CMOS NAME STORAGE
        MOVI    ROM_NAME,A1          ;POINT AT OUR VERSION
        MOVI    NAME_REV_SIZE,A2     ;MAXIMUM NAME SIZE

NEXT_LET1
        CALLA   RC_BYTEI             ;FETCH A BYTE
        MOVB    *A1,A3               ;GET 1 FROM ROM
        ANDI    BYTE_MASK,A3         ;MASK ANY SIGN EXTENDS

        CMP     A3,A0                ;THEY BETTER BE THE SAME
        JRNZ    RETURN_NOW           ;NOPE....BYE  (RETURN .NE.)

        ADDI    BYTE_SIZE,A1         ;KICK SOURCE POINTER
        MOVE    A0,A0                ;WAS IT A ZERO?
        JRZ     RETURN_NOW           ;YEP....NO MORE (RETURN .EQ.)
        DSJS    A2,NEXT_LET1
        CLR     A0                   ;RETURN .EQ.
         
RETURN_NOW
	MMFM    SP,A0,A1,A2,A3,A7
	RETS

**************************************************************************
*								         *
* 	ADJ_PAGE							 *
* 									 *
* 	SET CMOS TO THE ADJUSTMENTS PAGE				 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************
		
ADJ_PAGE:
        MMTM    SP,A1
        MOVI    ADJUST_SELECT,A1      ;THIS IS AUDIT PAGE
        CALLA   SET_PAGE             ;SET IT PLEASE
	MMFM    SP,A1
	RETS

**************************************************************************
*								         *
* 	DEF_PAGE							 *
* 									 *
* 	SET TO THE DEFAULT PAGE -- THE ONE WE DON'T CARE ABOUT		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

DEF_PAGE
        PUSHST                       ;PRESERVE CODES THAT ARE BEING RETURNED
        MMTM    SP,A1
        MOVI    TODAYS_SELECT,A1     ;THIS IS TODAY'S HIGH SCORES PAGE
        CALLA   SET_PAGE             ;SET IT PLEASE
        MMFM    SP,A1
        POPST
	RETS

**************************************************************************
*								         *
* 	FAC_SET								 *
* 									 *
* 	RESTORE THE FACTORY SETTINGS TO THE ADJUSTMENT CMOS		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

FAC_SET:  
	MMTM    SP,A0,A1,A2,A7
	CALLR	CMOSUNLOCK
        CALLR   NO_CREDS             ;REMOVE ANY COINS
        CALLR   ADJ_PAGE             ;SET CMOS PAGE CORRECTLY

        MOVI    FACTORY_TABLE,A1     ;ROM
        MOVI    ADJUSTORG,A7         ;CMOS
        MOVI    N_ADJUSTS,A2         ;NUMBER OF ADJUSTMENTS ALLOCATED

FACS1   MOVE    *A1+,A0,L            ;FETCH A ROM LONG WORD
        CALLA   WC_LONGI             ;WRITE THE WORD TO CMOS
        DSJS    A2,FACS1             ;WRITE 1 LONG WORD PER ADJUST

;         CALLR   SWITCH_FOR_JUMPER    ;CHANGE COINAGE BASED ON JUMPER.
;         CALLR   LD_CTAB      ;EXPAND THE CSELCT VALUE

        CALLR   F_ADC_S  ;MAKE THE CHECKSUM CORRECT.
*
*        NOW STORE THE GAME NAME AND REVISION INFO
*
        MOVI    NAME_REV,A7          ;POINT AT CMOS NAME STORAGE
        MOVI    ROM_NAME,A1          ;POINT AT OUR VERSION
        MOVI    NAME_REV_SIZE,A2     ;MAXIMUM NAME SIZE

NEXT_LETTER
        MOVB    *A1,A0               ;FETCH A BYTE
        CALLA   WC_BYTEI             ;WRITE IT TO CMOS
        ADDI    BYTE_SIZE,A1         ;KICK SOURCE POINTER
        MOVE    A0,A0                ;WAS IT A ZERO?
        JRZ     NAME_DONE            ;YEP....NO MORE!
        DSJS    A2,NEXT_LETTER
         
NAME_DONE
	CALLR	CMOSLOCK
	MMFM    SP,A0,A1,A2,A7
	RETS

**************************************************************************
*								         *
* 	CMOSUNLOCK							 *
* 									 *
* 	CALL THIS TO UNLOCK THE PROTECTED PORTION OF CMOS		 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

CMOSUNLOCK:
	PUSH	A0
	.IF	YUNIT
;	MOVE	@SYSCOPY,A0,W		; UNLOCK CMOS
;	ANDI	00FFH,A0
;	ORI	0200H,A0		; OR IS IT 2?
;	MOVE	A0,@SYSCOPY,W
;	MOVE	A0,@SYSCTRL,W
	MOVI	0200H,A0
	MOVE	A0,@SECCHIP,W
	.ENDIF
	PULL	A0
	RETS

**************************************************************************
*								         *
* 	CMOSLOCK							 *
* 									 *
* 	CALL THIS TO RELOCK CMOS 					 *
* 									 *
* 	ENTRY								 *
* 		NOTHING							 *
* 									 *
* 	EXIT								 *
* 		NOTHING							 *
*								         *
**************************************************************************

CMOSLOCK
	PUSH	A0
	.IF	YUNIT
;	MOVE	@SYSCOPY,A0,W		; RELOCK CMOS
;	ANDI	00FFH,A0	
;	ORI	0300H,A0		; OR IS IT 3?
;	MOVE	A0,@SYSCOPY,W
;	MOVE	A0,@SYSCTRL,W
;	MOVE	@SYSCOPY,A0,W
	MOVI	0300H,A0
	MOVE	A0,@SECCHIP,W
	.ENDIF
	PULL	A0
	RETS

FACTORY_TABLE
	.LONG   0000H  ;ADJ_UNUSED       	EQU     0
	.LONG   0001H  ;ADJ_PRICING      	EQU     1 
	.LONG   0001H  ;ADJ_LEFT_MULT    	EQU     2
	.LONG   0004H  ;ADJ_CENTER_MULT  	EQU     3
	.LONG   0001H  ;ADJ_RIGHT_MULT   	EQU     4
	.LONG	0001H	; ADJ_FOURTH_MULT	EQU	5
	.LONG   0001H  ;ADJ_UNITS_CREDIT 	EQU     6
	.LONG   0000H  ;ADJ_UNITS_BONUS  	EQU     7
	.LONG   0000H  ;ADJ_MIN_UNITS    	EQU     8
	.LONG   0004H  ;ADJCDIV          	EQU     9
	.LONG   0001H  ;SHOW FRACTIONS  	EQU	10        
	.LONG   0001H  ;ADJ_START_CRED   	EQU     11
	.LONG   0001H  ;ADJ_CONT_CRED    	EQU     12
	.LONG   0005H  ;ADJ_DIFFICULTY   	EQU     13
	.LONG    3000  ;ADJ_HSRESET      	EQU     14
	.LONG   0003H  ;ADJ_LIVES        	EQU     15
	.LONG 500000H  ;ADJ_EXTRA_MAN    	EQU    	16
	.LONG   0002H  ;ADJ_NUM_EXTRA_MEN	EQU	17
;	.LONG   0000H  ;ADJ_AMODE_MUSIC  	EQU     18
;	.LONG	0006H	; T-SHIRT WAVE		EQU	18
	.LONG	0001H	;18 ADJEGGS, 0 = SIMPLE, 1=COMPLEX
	.LONG   0030   ;MAXIMUM CREDITS		EQU	19
	.LONG	0000H	; FREEPLAY		EQU	20
	.LONG   0001H  ;NON-ZERO MEANS COIN BLOCK (1ST 8) UNTOUCHED 21
	.LONG	0		; FILLER SPACE
	.LONG   0001H  ;NON-ZERO MEANS 1ST 6 UNTOUCHED.           23
	.LONG   0000H  ;NON-ZERO MEANS NO COIN-SPECIFIC MESSAGE ON COIN PAGE  24
	.LONG   0002H  ;25 ADJBUYIN - 0 = NEVER, 1 = SOMETIMES, 2 = ALWAYS
	.LONG   0001H  ;26 ADJHSON  - 0 = NO, 1 = YES
	.LONG   0000H  ; UNUSED                  27
	.LONG   0000H  ; UNUSED                  28
	.LONG   0000H  ; UNUSED                  29
	.LONG   0000H  ; UNUSED                  30
