	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGMISC.ASM'
	.TITLE	" <<< T R O G -- MISCELLANEOUS ROUTINES >>>"
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

	.INCLUDE	"MPROCEQU.ASM"
	.INCLUDE	"DISPEQU.ASM"
        .INCLUDE	"GSPINC.ASM"
        .INCLUDE	"SYSINC.ASM"
	.INCLUDE	"TROGEQU.ASM"
	.INCLUDE	"TROGAEQU.ASM"
	.INCLUDE	"TROGSEQU.ASM"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"BGNDTBL.GLO"
	.INCLUDE	"STRING.H"

	.DEF	CWINDOW, COLOR_START, OWINDOW_OID
	.DEF	WIPE_FROM_MID, SKYUP,SKYDOWN, WATER_CYCLE
	.DEF	LAVA_CYCLE, BUYINWIN, EARTHSHAKER, BORDER_MARQUEE, WOWDEL
	.DEF	TUNNEL_CYCLE, TIME_WARP, SPARKLE, DANCE_STUFF
	.DEF	CYCLE16, OWINDOW, OBJEXP32, PCYCLEHI, PCYCLELO, BUYWIN_Z
	.DEF	PARTY_STUFF, FIREWERK, STAT_WORKS, GAME_ENDER
	.DEF	FEAST_INTRO, GEM_INTRO, BONFIRE_INTRO, BMX5_SND, BWWIN_SND
	.DEF	SECURITY

	.REF	COLRTEMP, SKYCOLOR, PALSET, BTIME, BUYNOW, PCYCLE_RAM
	.REF	P_START, P_CONT, CR_STRTP, CR_CONTP
	.REF	BORDER_SUPP, DRAW_P_BORDER, GPLAYNUM, WAVETIME
 	.REF	EGG_TAB, TROGINIT, BINBCD, PNAME_TAB, WAVE_PLAYERS
	.REF	DINOMADXFER, CLR_PDINOCNT, WAVE_END, FRANIMATE_DIR
	.REF	ANIMATE_DIR, GPLAYD, TUNNEL, WAIT_WAVE_END, GWEN_FLIPOUT
	.REF	GWEN_FLIPIN, REXINIT, BLOOPINIT, ELVISINIT, SPIKEINIT
	.REF	SPFLP0F30, SCORE_IF_ACTIVE, TUNNEL_SCORE, INC_PCONSECUTIVE
	.REF	PNAME15_TAB, STUFF_PLASTWIN, CLR_DRONE, TREX_KILL
	.REF	TROGSMACK2_SND, FAST_TIME, KILL_INVINCIBILITY, EGG_LIST
	.REF	SPIKECHEER_1, REXUP_SND, REXTUNE_SND, HIGHSCORECHECK
	.REF	CREDITS_TEXT, CHAMPM_SND, PLAYER_CLR, CLRBGND, SUFFIX_S
	.REF	SUFFIX_NULL, CLR_PEXTRAS, BONUS_WAVE, BONUS_TIME, WIN_SND
	.REF	HOUSEB_SND2, DINOFLY_ANIM, DINOCHEER_ANIM, CELEBRATEAMATE
	.REF	COMPSNDTAB, WIN_MESSAGES, NUM_WIN_MESSAGES, CELEBRATE_MESS
	.REF	WAVE_ENTERS, REXSCORE_SND, FIRE_SND, SEC_FLAG

	.IF	PRINTER
	.REF	PGAMEWARP, PRINT_DUMP
	.ENDIF

	.EVEN
	.TEXT

**************************************************************************
*								         *
* DUMPPRINT - DO A REGISTER DUMP TO THE PRINTER.			 *
* 									 *
* 		IF DEBUG  THEN WE JUST HANG HERE.			 *
* 		IF PRINTER & ~DEBUG  THEN PRINT REGISTERS.		 *
* 		IF ~PRINTER & ~DEBUG  THEN RETURN.			 *
*								         *
**************************************************************************
DUMPPRINT
	.IF	DEBUG
	DINT
	JRUC	$
	.ENDIF
	.IF	PRINTER
	CALLA	PRINT_DUMP
	.ENDIF
	RETS


*
*SECURITY EXERCISE TABLE
*
SECBTAB	
	.BYTE	>F 		;CLEAR THE SUCKER
	.BYTE	>F 		;CLEAR THE SUCKER
	.BYTE	>F 		;CLEAR THE SUCKER

	.BYTE	>E		;CLOCK IT
	.BYTE	>36		;READ A 3

	.BYTE	>E		;CLOCK IT
	.BYTE	>16		;READ A 1

	.BYTE	>E		;CLOCK IT
	.BYTE	>26		;READ A 2

	.BYTE	>E		;CLOCK IT
	.BYTE	>06		;READ A 0

	.BYTE	>4		;LOAD SEED
	.BYTE	>4		;LOAD A 4

	.BYTE	>A		;ROTATE ONE BIT
	.BYTE	>26		;SHOULD READ A 2

	.BYTE	>C		;CLEAR

	.BYTE	>E		;CLOCK
	.BYTE	>36		;READ A 3

	.BYTE	>7 		;NOP
	.BYTE	>36		;READ A 3

	.BYTE	>A		;ROTATE
	.BYTE	>36		;READ A 3

	.BYTE	>E		;CLOCK
	.BYTE	>16		;READ A 1

	.BYTE	>5		;NOP
	.BYTE	>16		;READ A 1

	.BYTE	>A		;ROTATE
	.BYTE	>06		;READ DAT 0

	.BYTE	>E 		;CLOCK
	.BYTE	>06		;READ A 0

	.BYTE	>A		;ROTATE
	.BYTE	>26		;READ A 2

	.BYTE	>E		;CLOCK
	.BYTE	>36

	.BYTE	>A
	.BYTE	>16

	.BYTE	>E
	.BYTE	>16

	.BYTE	>A
	.BYTE	>26

	.BYTE	>FF		;ITS ALL OVER
	.EVEN

**************************************************************************
*								         *
* SECURITY - AND FINALLY ... THERE IS SECURITY!				 *
* B0 = RETURN ADDRESS							 *
* SETS GLOBAL SEC_FLAG TO 1 IF BREECH!					 *
* NOTE: TRASHES A0,A1,A2,A3,A4,A6					 *
*								         *
**************************************************************************
SECURITY
	CLR	A0
	MOVE	A0,@SEC_FLAG,W
	MOVI	SECBTAB,A0
	GETST	A6
	DINT
SECLOOP
	MOVB	*A0,A1	
	ADDK	8,A0
	SLL	24,A1			; STRIP OUT THE CRUD
	SRL	24,A1			
	CMPI	>FF,A1
	JREQ	SECCHX			; WE ARE DONE
	MOVE	A1,A2
	SLL	8,A1
	MOVI	SECCHIP/2,A3
	SLL	1,A3
	ANDI	>0F00,A1
	MOVE	A1,*A3,W
	CMPI	>0600,A1		;READ IT ?
	JRNE	SECLOOP			;NO READ CYCLE

	MOVE	*A3,A4,W		;CHECK OUT READ DATA
	SLL	18,A4
	SRL	30,A4
	SRL	4,A2
	CMP	A4,A2
	JREQ	SECLOOP
SECERR					;BOGUS SHIT = ERROR
	MOVK	1,A0
	MOVE	A0,@SEC_FLAG,W
SECCHX	
	PUTST	A6
	FRET	B0

**************************************************************************
*                                                                        *
* COLOR_START - START THE COLOR RAM PROCESSES				 *
*                                                                        *
**************************************************************************
COLOR_START
	MMTM	SP,A0,A1,A7
	MOVI	COLORPID,A0
	CLR	A1
	NOT	A1
	CALLA	KILALL
****	CREATE	COLORPID,RGOLD
	CREATE	COLORPID,LFLASH
	CREATE	COLORPID,RGB
	CREATE	COLORPID,BPR
	CREATE	COLORPID,DECAY
	CREATE	COLORPID,PCYCLE
	MMFM	SP,A0,A1,A7
	RETS

**************************************************************************
*                                                                        *
* TABLE DRIVEN COLOR RAM PROCESSES					 *
*                                                                        *
**************************************************************************
*	18000B0(11)	-	BPR
*	18000C0(12)	-	DECAY
*	18000D0(13)	-	LASER FLASH
*	18000E0(14)	-	RGB

RGB	CALLR	TABDRIVE
	.LONG	RGBTAB,COLRTEMP+0E0H
	.WORD	8
RGBTAB	.WORD	07C00H,001FH,>77A0,>741A,0FFFFH

*
DECAY	CALLR	TABDRIVE
	.LONG	DCATAB,COLRTEMP+0C0H
	.WORD	2
DCATAB	.WORD	001CH,001CH,011CH,021CH,031CH,039CH,239CH,2390H,2388H
	.WORD	2380H,4300H,5280H,7180H,6180H,7080H,7000H,6000H,5000H
	.WORD	4000H,3000H,2000H,1000H,0FFFFH
*
BPR	CALLR	TABDRIVE
	.LONG	BPRTAB,COLRTEMP+0B0H
	.WORD	1
BPRTAB	.WORD	001CH,101CH,201CH,301CH,401CH,501CH,601CH,701CH,7010H
	.WORD	7010H,7008H,7008H,7000H,7000H,7008H,7008H,7010H,7010H
	.WORD	701CH,701CH,601CH,501CH,401CH,301CH,201CH,101CH,0FFFFH
*
****RGOLD	CALLR	TABDRIVE
****	.LONG	RGTAB,COLRTEMP+0B0H
****	.WORD	6
****RGTAB	.WORD	7000H,7000H,7280H,0FFFFH

**************************************************************************
*								         *
* LFLASH - PROCESS TO CREATE THE FAMOUS LASER FLASH COLOR 		 *
*								         *
**************************************************************************
LFLASH	MOVI	07FFFH,A0
	MOVE	A0,@COLRTEMP+0D0H,W
	SLEEP	2
LFLASH1
	MOVE	@RAND,A0,W
	ANDI	0000001FH,A0
	MOVI	COLTAB,A1
	SLL	4,A0
	ADD	A0,A1
	MOVE	*A1,A1,W
	MOVE	A1,@COLRTEMP+0D0H,W
	SLEEP	6
	JRUC	LFLASH

COLTAB	.WORD	0380H,1380H,2380H,3380H,4380H,5380H,6380H,7380H,7300H
	.WORD	7280H,7200H,7180H,7080H,7008H,7008H,7010H,7010H,701CH
	.WORD	701CH,601CH,501CH,409CH,309CH,209CH,219CH,029CH,039CH
	.WORD	139CH,239CH,339CH,539CH,739CH,7390H,7380H,6380H,4380H
	.WORD	0FFFFH

**************************************************************************
*                                                                        *
* THE TABLE DRIVEN PROCESS						 *
*                                                                        *
**************************************************************************
TABDRIVE
	MOVE	*SP+,A0,L
	MOVE	*A0+,A11,L	;A11 = TABLE START
	MOVE	*A0+,A9,L	;A9 = LOCATION TO STUFF COLOR
	MOVE	*A0,A10,W	;A10 = SLEEP TIME
TABDRV1
	MOVE	A11,A8		;RESET TO START OF TABLE
TABDRV2
	MOVE	*A8+,A0,W	;GET A COLOR
	JRN	TABDRV1		;BR = END OF TABLE
	MOVE	A0,*A9,W
	MOVE	A10,A0
	MOVI	TABDRV2,A7
	JAUC	PRCLSP		;LOOP SLEEP

	.BSS	PCYCLEHI,16,1
	.BSS	PCYCLELO,16,1
**************************************************************************
*								         *
* PCYCLE - PROCESS TO CYCLE THE PLAYER COLORS FROM BRIGHT TO DIM	 *
*								         *
**************************************************************************
PCYCLE:
	CLR	A14
	MOVE	A14,@PCYCLEHI,W
	MOVE	A14,@PCYCLELO,W
	MOVI	PCYCLE_RAM,A11
PCYCLE_LP:
	MOVI	PCYCLE_TAB,A8
	MOVK	PCYCLE_CNT,A10
	MOVK	1,A14
	MOVE	A14,@PCYCLEHI,W			;FLAG THE TOP
	CLR	A14
	MOVE	A14,@PCYCLELO,W			; CLEAR BOTTOM FLAG
PCYCLE_LP2:
	MOVE	A11,A9				;RESET RAM LOAD LOCATION
	MOVE	*A8+,*A9+,L
	MOVE	*A8+,*A9+,L
	DEC	A10
	JRZ	PCYCLE_LO
	SLEEP	3
	CLR	A14
	MOVE	A14,@PCYCLEHI,W
	MOVE	A14,@PCYCLELO,W
	JRUC	PCYCLE_LP2
PCYCLE_LO:
	MOVK	1,A14
	MOVE	A14,@PCYCLELO,W			;FLAG THE BOTTOM
	SLOOP	3,PCYCLE_LP

PCYCLE_CNT	EQU	12
PCYCLE_TAB:
	.WORD	>7D20,>1BF,>7FE0,>7C1F
	.WORD	>7CE0,>FF,>77A0,>741A
	.WORD	>7C00,>BF,>7B00,>7015
	.WORD	>7400,>1F,>76A0,>6813
	.WORD	>6C00,>1E,>7260,>6011
	.WORD	>6400,>19,>6A20,>5410
	.WORD	>5C00,>16,>65E0,>480E
	.WORD	>5000,>12,>5DA0,>400B
	.WORD	>4C00,>F,>5160,>3409
	.WORD	>4000,>C,>4D20,>3007
	.WORD	>3400,>9,>34A0,>2806
	.WORD	>2800,>7,>2C20,>2004

**************************************************************************
*								         *
* WATER_CYCLE - START THE WATER COLOR CYCLER				 *
*								         *
**************************************************************************
WATER_CYCLE:
	MOVI	WAWA2,A8
	MOVK	3,A9
	MOVK	15,A10
	MOVK	15,A11
	CREATE	INDPID,CYCLE16
	DIE

**************************************************************************
*								         *
* LAVA_CYCLE - START THE LAVA COLOR CYCLER				 *
*								         *
**************************************************************************
LAVA_CYCLE:
	MOVI	LAVA2,A8
	MOVK	3,A9
	MOVK	15,A10
	MOVK	15,A11
	CREATE	INDPID,CYCLE16
	DIE

**************************************************************************
*								         *
* TUNNEL_CYCLE - START THE TUNNEL COLOR CYCLER				 *
*								         *
**************************************************************************
TUNNEL_CYCLE:
	MOVI	TUNPAL,A8
	MOVK	1,A9
	MOVK	11,A10
	MOVK	6,A11
	CREATE	INDPID,CYCLE16
	DIE

**************************************************************************
*								         *
* CYCLE16 - PROCESS TO CYCLE UP TO SIXTEEN COLORS OF A GIVEN PALETTE.	 *
* A8 = PTR TO PALETTE (PALETTE MUST BE ALLOCATED).			 *
* A9 = START COLOR #							 *
* A10 = END COLOR #							 *
* A11 = SPEED								 *
*								         *
**************************************************************************
CYCLE16:
	MOVE	A11,*A13(PDATA),W	;KEEP THE SLEEP TIME
	MOVE	A10,A2
	CLR	A11			;THIS WILL BE THE DIRECTION FLAG
	SUB	A9,A2
	JRNN	CYCLE16_FOR		;BR = FOWARD CYCLE
	ABS	A2	
	NOT	A11			;FLAG A REVERSE CYCLE 
	SWAP	A9,A10			;SWAP THESE FOR LOAD

CYCLE16_FOR:
	MOVE	A9,*A13(PDATA+10H),W	;STORE THE START COLOR
	MOVE	A9,A3	
	MOVE	A13,A9
	ADDI	PDATA+60H,A9		;START COLOR ADDRESS
	MOVE	A9,A10
	MOVE	A2,A4
	SLL	4,A4
	ADD	A4,A10			;END COLOR ADDRESS

	MOVE	A8,A0
	MOVE	A9,A1			;THIS IS THE STARTING COLOR LOCATION
	ADDK	16,A0			;SKIP THE COLOR COUNT
	SLL	4,A3
	ADD	A3,A0			;AND GET TO THE START COLOR
	INC	A2
	MOVE	A2,*A13(PDATA+20H),W	;STORE THE COLOR COUNT

CYCLE16_LOAD:
	MOVE	*A0+,*A1+,W		;TRANSFER THE PALETTE TO RAM
	DSJS	A2,CYCLE16_LOAD

CYCLE16_WAIT:
	MOVE	A8,A0
	CALLA	FINDPAL			;DOES THIS PALETTE EXIST?	
	JRNZ	CYCLE16_FND		;BR = YES, GO AHEAD AND CYCLE
	SLOOP	6,CYCLE16_WAIT		;WAIT FOR IT TO EXIST

CYCLE16_FND:
	MOVE	A0,A7			;STORE FOUND PALETTE NUMBER HERE
	MOVE	*A13(PDATA+20H),A4,W	;DO IT THIS MANY TIMES
	DEC	A4			;WATCH THE ZERO BASE

	MOVE	A11,A11			;CHECK DIRECTION
	JRNN	CYCLE16_UP		;BR = CYCLE COLORS UP
	MOVE	A9,A1			;GET THE END COLOR
	MOVE	*A1,A3,W		;STORE THE COLOR
	MOVE	A10,A2
	MOVE	A1,A0	
	ADDK	16,A1
CYCLE16_DN_LP:
	MOVE	*A1+,*A0+,W
	DSJS	A4,CYCLE16_DN_LP
	JRUC	CYCLE16_DONE

CYCLE16_UP:
	MOVE	A10,A1			;GET THE END COLOR
	MOVE	*A1,A3,W		;STORE THE COLOR
	MOVE	A9,A2
	MOVE	A1,A0	
	ADDK	16,A1
CYCLE16_UP_LP:
	MOVE	-*A0,-*A1,W	
	DSJS	A4,CYCLE16_UP_LP
CYCLE16_DONE:
	MOVE	A3,*A2,W		;WRAP COLOR
	MOVE	A9,A0
	MOVE	*A13(PDATA+10H),A1,W
	ZEXT	A7

	.IF	YUNIT
	SRL	12,A7
	.ELSE
	SRL	8,A7
	.ENDIF

	SLL	8,A7
	OR	A7,A1			;DESTINATION: 8-15 PALETTE, 0-7 START		
	MOVE	*A13(PDATA+20H),A2,W	;GET THE COUNT
	CALLA	PALSET			;SETUP A TRANSFER
	MOVE	*A13(PDATA),A0,W
	SLOOPR	A0,CYCLE16_WAIT


BUYWIN_Z	.EQU	7FFF0001H
**************************************************************************
*                                                                        *
* BUYINWIN - PUT UP THE BUY-IN WINDOW PROCESS				 *
*                                                                        *
**************************************************************************
BUYINWIN
	MOVI	16,A0
	MOVI	BUYWIN_Z,A1
	MOVI	[88+SKYTOPOF,198],A10
	MOVI	[120,236],A8
	JSRP	OWINDOW			;OPEN THE WINDOW
	JRZ	BUYINWDI		;COULDN'T DO IT
****	SOUND1	BUYMUSIC
	CALLR	INIBTIME		;INITIALIZE BUY IN TIME
	CALLR	INIBMESS		;INITIALIZE BUY IN MESSAGE
	CALLR	BUY_POINTEES
	MOVK	1,A0
	MOVE	A0,@BUYNOW,W
PBUYOLP
	MOVI	BUYTICK,A11
PBUYILP
	MOVE	@CURPLYRS,A0,W
	JRNZ	PBUYDONE		;OTHER GUY BOUGHT IN
	SLEEP	BUYSLP
	CALLR	UPBMESS1		;UPDATE BUYIN MESSAGE 1
	DSJS	A11,PBUYILP
	CALLR	DECBTIME		;DECREMENT BUYIN TIME
	JRGE	PBUYOLP			;WE ARE NOT DONE YET
*SOMEBODY JUST BOUGHT IN OR TIME IS UP
PBUYDONE
	CALLR	CLRBTIME
	CALLR	CLRBMESS
***	SOUND1	BUYMOFF
	MOVI	GOODIEPID,A0
	CLR	A1
	NOT	A1
	CALLA	KILALL
	MOVI	GOODIEOID,A0
	CALLA	KILL_OBJECTS
	MOVI	20,A0
	JSRP	CWINDOW
	CLR	A0
	MOVE	A0,@BUYNOW,W
BUYINWDI
	DIE

BUYMUSIC
	.WORD	>F2FE,>01,>8041,0
BUYMOFF
	.WORD	>F2FE,>01,>8042,0

**************************************************************************
*                                                                        *
* INIBMESS - INITIALIZE THE BUY IN MESSAGE				 *
*                                                                        *
**************************************************************************
INIBMESS
	MMTM	SP,A0,A1,A2,A5,A6,A8,A9,A10,A11
	CALLA	CR_CONTP	;ENOUGH TO CONTINUE?
	JRLO	INIBMIN		;BR = NO
	MOVI	PRESS_MESS,A8
	JRUC	INIBM1
INIBMIN
	MOVI	INSRT_MESS,A8
INIBM1
	CALLA	LM_SETUP
	CALLR	GWINCENT	;POSITION
	MOVE	A0,A2		;KEEP
	SUBI	[50,0],A0	;OFFSET FROM BOX CENTER
	MOVE	A0,A9
	CLR	A0
	JSRP	PRINTF

	MOVI	TEXTOID,A0
	MOVI	BMES1OID,A1
	CALLA	CHANGOID		;CHANGE THE OID

	MOVI	TOCON_MESS,A8
	CALLA	LM_SETUP

	MOVE	A2,A9
	SUBI	[22,0],A9	;OFFSET FROM BOX CENTER
	JSRP	PRINTF

	MOVI	TEXTOID,A0
	MOVI	BMES2OID,A1
	CALLA	CHANGOID		;CHANGE THE OID

	MMFM	SP,A0,A1,A2,A5,A6,A8,A9,A10,A11
	RETS

**************************************************************************
*                                                                        *
* INIBTIME - INITIALIZE THE BUY IN TIMER				 *
*                                                                        *
**************************************************************************
INIBTIME
	MMTM	SP,A0,A1,A5,A6,A8,A9,A10,A11
	CALLR	CLRBTIME
	MOVI	BUYTIME,A0
	MOVE	A0,@BTIME,W	;STORE IT AWAY

	MOVI	TIME_MESS,A8
	CALLA	LM_SETUP
	CALLR	GWINCENT	;POSITION
	ADDI	[35,0],A0	;OFFSET FROM BOX CENTER
	MOVE	A0,A9
	CLR	A0
	JSRP	PRINTF

	MOVI	TEXTOID,A0
	MOVI	BTIMEOID,A1
	CALLA	CHANGOID		;CHANGE THE OID
	MMFM	SP,A0,A1,A5,A6,A8,A9,A10,A11
	RETS

**************************************************************************
*                                                                        *
* CLRBMESS - CLEAR THE BUY-IN MESSAGE TEXT.				 *
*                                                                        *
**************************************************************************
CLRBMESS
	MMTM	SP,A0,A1
	MOVI	BMES1OID,A0
	CLR	A1
	NOT	A1
	CALLA	KILOBJ
	MOVI	BMES2OID,A0
	CALLA	KILOBJ
	MMFM	SP,A0,A1
	RETS

**************************************************************************
*                                                                        *
* CLRBTIME - CLEAR THE BUY-IN TIME TEXT.				 *
*                                                                        *
**************************************************************************
CLRBTIME
	MMTM	SP,A0,A1
	MOVI	BTIMEOID,A0
	CLR	A1
	NOT	A1
	CALLA	KILOBJ
	MMFM	SP,A0,A1
	RETS

**************************************************************************
*                                                                        *
* DECBTIME - DECREMENT THE BUY IN TIMER					 *
* RETURNS:								 *
* 	Z BIT SET = BUY IN TIME DONE					 *
* 	Z BIT CLR = HURRY WHILE SPECIALS LAST!				 *
*                                                                        *
**************************************************************************
DECBTIME
	MMTM	SP,A0,A1,A5,A6,A8,A9,A10,A11
	CALLR	CLRBTIME
	MOVE	@BTIME,A0,W
	DEC	A0
	JRLT	DECBTX
	MOVE	A0,@BTIME,W

	MOVI	TIME_MESS,A8
	CALLA	LM_SETUP
	CALLR	GWINCENT	;POSITION
	ADDI	[35,0],A0	;OFFSET FROM BOX CENTER
	MOVE	A0,A9
	CLR	A0
	JSRP	PRINTF

	MOVI	TEXTOID,A0
	MOVI	BTIMEOID,A1
	CALLA	CHANGOID		;CHANGE THE OID
	MOVE	@BTIME,A8,W	;SET STATUS
DECBTX
	MMFM	SP,A0,A1,A5,A6,A8,A9,A10,A11
	RETS

**************************************************************************
*                                                                        *
* UPBMESS1 - UPDATE THE "PRESS START" OR "INSERT COIN" MESSAGE.		 *
* RETURNS:								 *
* A11 = UPDATED SLEEP LOOP TIME FOR BUYIN THING				 *
*                                                                        *
**************************************************************************
UPBMESS1
	MMTM	SP,A0,A1,A5,A6,A8	;MORE PUSHING TO COME
	CALLA	CR_CONTP	;ENOUGH TO CONTINUE?
	JRLO	UPBMIN		;BR = NO
	MOVI	PRESS_MESS,A8
	JRUC	UPBM1
UPBMIN
	MOVI	INSRT_MESS,A8
UPBM1
	MMTM	SP,A9,A10,A11	;WATCH OUT FOR THIS BOGUSNESS
	CALLA	LM_SETUP
	CALLR	GWINCENT	;POSITION
	SUBI	[50,0],A0
	MOVE	A0,A9
	CLR	A0
	JSRP	PRINTF

	MOVI	BMES1OID,A0
	CLR	A1
	NOT	A1
	CALLA	KILOBJ		;KILL OLD MESSAGE

	MOVI	TEXTOID,A0
	MOVI	BMES1OID,A1
	CALLA	CHANGOID		;CHANGE THE OID
	MMFM	SP,A0,A1,A5,A6,A8,A9,A10,A11
	RETS

**************************************************************************
*                                                                        *
* GWINCENT - GET THE CURRENT TEXT WINDOW CENTER POINT.			 *
* RETURNS:								 *
* A0 = CENTER PNT.							 *
*                                                                        *
**************************************************************************
GWINCENT
	MMTM	SP,A1,A8
	MOVI	TEXTWOID,A0
	CLR	A1
	NOT	A1
	CALLA	EXISTOBJ
	JRZ	GWINCX
	MOVE	A0,A8
	CALLA	GETCPNT
	MOVE	A1,A0
GWINCX
	MMFM	SP,A1,A8
	RETS

*
*SOME MESSAGES
INSRT_MESS:
	MESS_MAC RD20FONT,1,200,(88+SKYTOPOF),TROG_PRGB,STRCNRMO,0
	.STRING "INSERT COIN",0
	.EVEN
PRESS_MESS:
	MESS_MAC RD20FONT,1,200,(88+SKYTOPOF),TROG_PRGB,STRCNRMO,0
	.STRING	"PRESS START",0
	.EVEN
TOCON_MESS:
	MESS_MAC RD20FONT,1,200,(88+SKYTOPOF),TROG_PBPR,STRCNRMO,0
	.STRING	"TO\nCONTINUE",0
	.EVEN
TIME_MESS:
	MESS_MAC RD20FONT,1,200,88+SKYTOPOF,TROG_PLF,STRCNRMO,0
	.STRING	"%d",0
	.LONG	BTIME
	.EVEN

**************************************************************************
*                                                                        *
* WIPE_FROM_MID - PROCESS TO WIPE THE SCREEN FROM THE MIDDLE		 *
* A11 = TICKS TO COMPLETE THE WIPE					 *
*                                                                        *
**************************************************************************
WIPE_FROM_MID:
	MOVI	SCRNEND-SCRNST,A8
	MOVI	SCRNMID,A10
	MOVE	A11,A0
	MOVI	7FFF0001H,A1
	JSRP	OWINDOW
	DIE

**************************************************************************
*								         *
* WIPE_FROM_XY - PROCESS TO START A WIPE WINDOW AT A GIVEN [Y,X] COORD.	 *
* 		MEANWHILE MOVING THE WINDOW TO THE CENTER OF THE 	 *
* 		SCREEN.							 *
* A10	= [Y,X] START POINT OF WINDOW					 *
* A11	= TICKS TO DO IT						 *
*								         *
**************************************************************************
WIPE_FROM_XY:
	MOVI	WINDINIT,A14
	CALLA	GPALOBJSTF
	JRZ	WIPE_FROM_XY_X	;BR = FAILED MISERBLY
	MOVE	A0,A8
	MOVI	7FFF0001H,A1
	MOVE	A1,*A8(OZVAL),L	;SET THE GIVEN WINDOW POSITION
	MOVE	A10,*A8(OXPOS),W	
	MOVY	A10,A1
	SRL	16,A1
	MOVE	A1,*A8(OYPOS),W
	CLR	A1
	MOVE	A1,*A8(OCONST),W
	CALLA	INSOBJ
	MOVE	A11,A0
	MOVI	SCRNST,A10
	MOVI	SCRNEND,A11
	JSRP	OBJEXP32
WIPE_FROM_XY_X:
	DIE

**************************************************************************
*                                                                        *
* OWINDOW - OPEN A TEXT WINDOW, ON THE OBJECT LIST.			 *
* A0 = # OF TICKS TO EXPAND OBJECT					 *
* A1 = OZVAL OF WINDOW							 *
* A8 = WINDOW SIZE							 *
* A10 = CENTER POINT OF WINDOW (SCREEN RELATIVE)			 *
* RETURNS:								 *
* A8 = PTR WINDOW OBJECT						 *
* 	ZBIT SET = FAILURE TO CREATE					 *
* 	ZBIT CLR = WINDOW IS OPEN					 *
* NOTE: CALL WITH JSRP							 *
*	TRASHES A9,A10 & A11						 *
*                                                                        *
**************************************************************************
*
*OWINDOW_OID - PROVIDE YOUR OWN OBJECT I.D.
*A9 = WINDOW OID
OWINDOW_OID:
	MOVE	A0,A6		;STORE THE EXPAND TIME HERE
	MOVI	WINDINIT,A14
	CALLA	GPALOBJSTF
	MOVE	A9,*A0(OID),W
	JRUC	OWINDOW_G
OWINDOW
	MOVE	A0,A6		;STORE THE EXPAND TIME HERE
	MOVI	WINDINIT,A14
	CALLA	GPALOBJSTF
OWINDOW_G:
	MOVE	A8,A11
	MOVE	A0,A8
	JRZ	OWINDOWX	;BR = FAILED MISERBLY
	MOVE	A1,*A8(OZVAL),L	;SET THE GIVEN WINDOW POSITION
	MOVE	A10,*A8(OXPOS),W	
	MOVY	A10,A1
	SRL	16,A1
	MOVE	A1,*A8(OYPOS),W
	CLR	A1
	MOVE	A1,*A8(OCONST),W
	CALLA	INSOBJ
	MOVE	*A8(OXPOS),A10,W
	MOVE	*A8(OYPOS),A0,W
	SLL	16,A0
	MOVY	A0,A10		;GET NEW WORLD COORDS.
	MOVE	A10,A0		;STORE HERE
	MOVY	A11,A1
	SRL	17,A1
	SLL	16,A1		;DIVIDE Y BY 2
	SLL	16,A11
	SRL	17,A11		;AND X
	MOVY	A1,A11
	SUBXY	A11,A10
	ADDXY	A0,A11
	MOVE	A6,A0
	JSRP	OBJEXP32
	MOVE	A8,A8
OWINDOWX
	RETP

**************************************************************************
*                                                                        *
* CWINDOW - CLOSE A TEXT WINDOW, ON THE OBJECT LIST.			 *
* A0 = TICKS TO CLOSE							 *
* A8 = PTR TO WINDOW OBJECT						 *
* RETURNS:								 *
* 	WITH WINDOW OBJECT DELETED					 *
* NOTE: CALL WITH JSRP							 *
*	TRASHES A9,A10 & A11						 *
*                                                                        *
**************************************************************************
CWINDOW
	MOVE	*A8(OXPOS),A10,W
	MOVE	*A8(OYPOS),A11,W
	SLL	16,A11
	MOVY	A11,A10
	MOVE	*A8(OSIZE),A11,L
	MOVY	A11,A1
	SRL	17,A1
	SLL	16,A1
	SLL	16,A11
	SRL	17,A11
	MOVY	A1,A11
	ADDXY	A11,A10
	MOVE	A10,A11			;CALCULATED CENTER OF OBJECT
	JSRP	OBJEXP32
	CALLA	DELETE_OBJ
	RETP

**************************************************************************
*                                                                        *
* OBJEXP32 - SHRINK OR EXPAND AN OBJECT FROM THE CURRENT SIZE		 *
*	      TO THE GIVEN SIZE IN A GIVEN AMOUNT OF TICKS.		 *
* A0 = # OF TICKS							 *
* A8 = PTR TO OBJECT							 *
* A10 = NEW OBJTL							 *
* A11 = NEW OBJLR							 *
* NOTE: CALL WITH JSRP							 *
*	TRASHES A9							 *
*                                                                        *
**************************************************************************
OBJEXP32
	MOVE	*A8(OXPOS),A1,W
	MOVE	*A8(OYPOS),A14,W
	SLL	16,A14
	MOVX	A1,A14			;A14 = OBJECT UL

	SLL	16,A1
	CLR	A2
	MOVY	A14,A2
	SUBXY	A10,A14
	MOVX	A14,A5
	SLL	16,A5
	DIVS	A0,A5
	NEG	A5
	MOVE	A5,A6
	CLR	A5
	MOVY	A14,A5
	DIVS	A0,A5
	NEG	A5
	MOVE	A5,A7

	MOVE	*A8(OXPOS),A3,W
	MOVE	*A8(OYPOS),A14,W
	SLL	16,A14
	MOVX	A3,A14
	MOVE	*A8(OSIZE),A3,L
	ADDXY	A3,A14			;A14 = OBJECT LR

	PUSH	A8			;STACK OBJECT
	MOVX	A14,A3
	SLL	16,A3
	CLR	A4
	MOVY	A14,A4
	SUBXY	A11,A14
	MOVX	A14,A5
	SLL	16,A5
	DIVS	A0,A5
	NEG	A5
	MOVE	A5,A8
	CLR	A5
	MOVY	A14,A5
	DIVS	A0,A5
	NEG	A5
	MOVE	A5,A9
	MOVE	A0,A5
	PULL	A14			;KEEP OBJECT HERE
OBJTIMLP
	ADD	A6,A1			;ADD THE TLX INCREMENT
	ADD	A7,A2			;ADD THE TLY INCREMENT
	ADD	A8,A3			;ADD THE LRX INCREMENT
	ADD	A9,A4			;ADD THE LRY INCREMENT
	MMTM	A12,A1,A2,A3,A4,A5,A6,A7,A14
	MOVE	A1,*A14(OXVAL),L
	MOVE	A2,*A14(OYVAL),L
	SUB	A1,A3
	SUB	A2,A4			;GET A SIZE FOR THE WINDOW
	SRL	16,A3
	MOVY	A4,A3
	CALLR	FIXA3XY
	MOVE	A3,*A14(OSIZE),L
	SLEEP	1
	MMFM	A12,A1,A2,A3,A4,A5,A6,A7,A14
	DSJS	A5,OBJTIMLP
	MOVE	A10,*A14(OXPOS),W
	MOVY	A10,A1
	SRL	16,A1
	MOVE	A1,*A14(OYPOS),W
	MOVE	A11,A9
	SUBXY	A10,A11
	MOVE	A11,A3
	CALLR	FIXA3XY
	MOVE	A3,*A14(OSIZE),L	;MATCH WHAT THE CALLER WANTED
	MOVE	A9,A11			;PRESERVE FOR YUKS
	MOVE	A14,A8
	RETP

**************************************************************************
*                                                                        *
* FIXA3XY - CHECKS THE X AND Y COMPONENT OF A3, ANY ONE THAT IS ZERO	 *
* 		WILL BE SET TO ONE. KEEPS OSIZE IN ORDER.		 *
* A3 = [Y,X]								 *
*                                                                        *
**************************************************************************
FIXA3XY
	PUSH	A0
	CLR	A0
	MOVY	A3,A0
	MOVE 	A0,A0
	JRNZ	FA3YOK
	MOVK	1,A0
	SLL	16,A0
	MOVY	A0,A3
FA3YOK
	CLR	A0
	MOVX	A3,A0
	MOVE	A0,A0
	JRNZ	FA3XOK
	MOVK	1,A0
	MOVX	A0,A3
FA3XOK
	PULL	A0
	RETS

*INIT TABLE FOR WINDOW
WINDINIT
	.LONG	0,0,7FFF0000H,WINDOBJ,0,0					 
	.WORD	DMACAL|M_NOSCROLL,TEXTWOID,0,0
*INITIAL WINDOW OBJECT
WINDOBJ
	.WORD	1,1,0,0
	.LONG	02000000H,GAMEFIX

**************************************************************************
*                                                                        *
* SKYUP - FADE UP THE SKY COLOR AND DIE					 *
* A9 = FADER SPEED							 *
* I.D. = SKYPID								 *
**************************************************************************
SKYUP
	MOVE	*A13(PROCID),A0,W
	CLR	A1
	NOT	A1
	CALLA	KILALL
	CLR	A8
SKYUP1
	MOVE	@SKYCOLOR,A0,W
	MOVE	A8,A1
	CALLA	XCOLOR
	MOVE	A0,@IRQSKYE,W
	SLEEP	1
	ADD	A9,A8
	CMPI	10000H,A8
	JRLE	SKYUP1
	MOVI	10000H,A1
SKYDIE
	MOVE	@SKYCOLOR,A0,W
	CALLA	XCOLOR
	DIE

**************************************************************************
*								         *
* SKYDOWN - FADE DOWN THE SKY COLOR AND DIE				 *
* A9 = FADER SPEED							 *
* I.D. = SKYPID								 *
*								         *
**************************************************************************
SKYDOWN
	MOVE	*A13(PROCID),A0,W
	CLR	A1
	NOT	A1
	CALLA	KILALL
	MOVI	10000H,A8
SKYDOWN1
	MOVE	@SKYCOLOR,A0,W
	MOVE	A8,A1
	CALLA	XCOLOR
	MOVE	A0,@IRQSKYE,W
	SLEEP	1
	SUB	A9,A8
	JRGT	SKYDOWN1
	CLR	A1
	JRUC	SKYDIE

**************************************************************************
*                                                                        *
* XCOLOR - COLOR VALUE MULTIPLIER					 *
* A0 = COLOR VALUE							 *
* A1 = X FACTOR (MSW:INTEGER LSW:FRACTION)				 *
* RETURNS								 *
* A0 = X COLOR VALUE							 *
*                                                                        *
**************************************************************************
XCOLOR
	MMTM	SP,A3,A4
	CLR	A4
	MOVE	A0,A3
	SLL	27,A3
	SRL	27,A3		;NOW I GOT 'DA BLUES
	MPYU	A1,A3
	SLL	11,A3
	SRL	27,A3
	OR	A3,A4
	MOVE	A0,A3
	SLL	22,A3
	SRL	27,A3		;GREENS
	MPYU	A1,A3
	SLL	11,A3		;STRIP GARBAGE
	SRL	27,A3
	SLL	5,A3
	OR	A3,A4
	MOVE	A0,A3
	SLL	17,A3
	SRL	27,A3		;NOW REDS
	MPYU	A1,A3
	SLL	11,A3
	SRL	27,A3
	SLL	10,A3
	OR	A3,A4
	MOVE	A4,A0
	MMFM	SP,A3,A4
	RETS

**************************************************************************
*								         *
* EARTHSHAKER - PROCESS TO SHAKE THE WORLD RANDOMLY FOR A LITTLE BIT.	 *
*								         *
**************************************************************************
EARTHSHAKER:
	MOVE	@WORLDTLX,A8,L	;KEEP THESE HERE S.V.P
	MOVE	@WORLDTLY,A9,L
	MOVE	A8,A2
	MOVE	A9,A3
	MOVK	3,A0
	CALLA	RANDU		;RANDOM SHOCK
	SLL	16,A0		;UP HERE!
	SUB	A0,A2
	SUB	A0,A3		;ROCK IT THIS WAY
	MOVE	A0,A10
	MOVE	A2,@WORLDTLX,L	
	MOVE	A3,@WORLDTLY,L
	SLEEP	3
	MOVE	A8,A2
	MOVE	A9,A3
	ADD	A10,A2		;AND ROCK IT THAT ...
	ADD	A10,A3
	MOVE	A2,@WORLDTLX,L	
	MOVE	A3,@WORLDTLY,L
	SLEEP	3
	CLR	A8
	MOVE	A8,@WORLDTLX,L	;RESTORE TO GROUND ZERO
	MOVE	A8,@WORLDTLY,L
	DIE

**************************************************************************
*								         *
* BORDER_MARQUEE - PROCESS TO ANIMATE THE BONUS BORDER DURING COUNT.	 *
* A10 = [Y,X] OFFSET OF BORDER MARQUEE					 *
* A11 = PLAYER DATA BLOCK						 *
*								         *
**************************************************************************
BORDER_MARQUEE:
	MOVE	A11,A2
	MOVE	A10,A1
	CALLA	DRAW_P_BORDER		;OUTPUT HIS BORDER
	CALLR	BORDER_TO_SUPP		;FIRST STICK THE BORDER ON THE SUPPS
	CALLA	GPLAYNUM
	SLL	6,A0
	ADDI	MARQANIS,A0
	MOVE	*A0+,A9,L
	MOVE	*A0+,A10,L
	MOVK	1,A11
	
	MOVE	@BORDER_SUPP,A8,L
	JRZ	BM_X
	MOVK	4,A6
BM_C
	CREATE	BORDERPID,TRAILAMATE
	MOVE	*A8(OSLINK),A8,L
	JRZ	BM_X
	DSJS	A6,BM_C
	MOVE	A10,A9
	MOVK	2,A6
BM_C1
	CREATE	BORDERPID,TRAILAMATE
	MOVE	*A8(OSLINK),A8,L
	JRZ	BM_X
	DSJS	A6,BM_C1
BM_X
	DIE

**************************************************************************
*								         *
* BORDER_TO_SUPP - PUT ALL OF THE BONE BORDER OBJECTS ON THE BORDER_SUPP *
* 		LIST.							 *
*								         *
**************************************************************************
BORDER_TO_SUPP:
	MMTM	SP,A0,A1,A8
	MOVE	@OBJLST,A8,L		;FIRST OBJECT
	JRZ	BORDER_TO_SUPP_X	;BR = LIST IS EMPTY
	MOVI	BORDER_SUPP,A1
BORDER_TO_SUPP_LP:
	MOVE	*A8(OID),A0,W
	CMPI	BORDEROID,A0		;IS THIS THE OBJECT WE WANT?
	JRNE	BORDER_TO_SUPP_NXT	;BR = NO
	MOVE	*A8(OSLINK),A0,L	;SAFETY CHECK, IS IT ALREADY LINKED?
	JRNZ	BORDER_TO_SUPP_NXT	;BR = YES
	CALLA	INSERT_SUPP
BORDER_TO_SUPP_NXT:
	MOVE	*A8,A8,L
	JRNZ	BORDER_TO_SUPP_LP
BORDER_TO_SUPP_X:
	MMFM	SP,A0,A1,A8
	RETS

**************************************************************************
*								         *
* BUY_POINTEES - ROUTINE TO CREATE THE BUYIN POINTERS			 *
*								         *
**************************************************************************
BUY_POINTEES
	MMTM	SP,A0,A1,A7,A9,A10,A11

	MOVI	[57+SKYTOPOF,285],A10
	CREATE	GOODIEPID,ARROWF

	MOVI	[57+SKYTOPOF,110],A10
	CREATE	GOODIEPID,ARROWN

	MMFM	SP,A0,A1,A7,A9,A10,A11
	RETS

**************************************************************************
*								         *
* PARTY_STUFF - CREATE THE STUFF TO START THE CELEBRATION PARTY.	 *
* A11 = PLAYER WE ARE CELEBRATING.					 *
*								         *
**************************************************************************
PARTY_STUFF
	MMTM	SP,A0,A1,A3,A7,A10

	MOVE	*A11(PWINS),A3,W
	CMPI	5,A3	
	JRLO	PS_X

	MOVI	[SKYTOPOF,26],A10
	CREATE	FWORKSPID,SKYROCKET

	MOVI	[SKYTOPOF,370],A10
	CREATE	FWORKSPID,SKYROCKET
PS_X
	MMFM	SP,A0,A1,A3,A7,A10
	RETS

**************************************************************************
*								         *
* DANCE_STUFF - CREATE THE ANIMATIONS THAT WILL OCCUR DURING THE DINOS	 *
* 		DANCE.							 *
* A11 = PLAYER DOING THE DANCING					 *
*								         *
**************************************************************************
DANCE_STUFF
	MMTM	SP,A0,A1,A3,A7,A10

	MOVE	*A11(PWINS),A3,W		;EVERTHING IRIE MON

	MOVI	[8+SKYTOPOF,109],A10
	CREATE	GOODIEPID,ARROWN

	MOVI	[8+SKYTOPOF,283],A10
	CREATE	GOODIEPID,ARROWF

	CMPI	2,A3
	JRLO	DS_X

	MOVI	[67+SKYTOPOF,262],A10
	CREATE	GOODIEPID,EXCLAIMF

	MOVI	[67+SKYTOPOF,120],A10
	CREATE	GOODIEPID,EXCLAIM

	MOVI	[64+SKYTOPOF,242],A10
	CREATE	GOODIEPID,EXCLAIMF

	MOVI	[64+SKYTOPOF,140],A10
	CREATE	GOODIEPID,EXCLAIM

	CMPI	3,A3
	JRLO	DS_X

	MOVI	[73+SKYTOPOF,57],A10
	CREATE	GOODIEPID,YO

	MOVI	[70+SKYTOPOF,330],A10
	CREATE	GOODIEPID,TRANSFORM

	CMPI	4,A3
	JRLO	DS_X

	MOVI	[163+SKYTOPOF,332],A10
	CREATE	GOODIEPID,PINWEEL

	MOVI	[163+SKYTOPOF,58],A10
	CREATE	GOODIEPID,PINWEEL

DS_X
	MMFM	SP,A0,A1,A3,A7,A10
	RETS

**************************************************************************
*								         *
* PINWEEL - PROCESS TO ANIMATE THE PINWEEL AT A GIVEN POINT		 *
* A10 = [Y,X] START POSITION						 *
*								         *
**************************************************************************
PINWEEL
	MOVK	1,A8
	MOVI	PINWEEL_ANI,A9
	MOVI	ANIMATOR,A11
	JRUC	GOODIE

**************************************************************************
*								         *
* TRANSFORM - PROCESS TO ANIMATE THE TRANSFORM AT A GIVEN POINT		 *
* A10 = [Y,X] START POSITION						 *
*								         *
**************************************************************************
TRANSFORM
	MOVK	1,A8
	MOVI	TRANSFORM_ANI,A9
	MOVI	TRAILAMATE,A11
	JRUC	GOODIE

**************************************************************************
*								         *
* ARROWN - PROCESS TO ANIMATE THE NORMAL ARROW A GIVEN POINT		 *
* A10 = [Y,X] START POSITION						 *
*								         *
**************************************************************************
ARROWN
	MOVK	1,A8
	MOVI	ARROW_ANI,A9
	MOVI	ANIMATOR,A11
	JRUC	GOODIE

**************************************************************************
*								         *
* ARROWF - PROCESS TO ANIMATE THE FLIPPED ARROW AT A GIVEN POINT	 *
* A10 = [Y,X] START POSITION						 *
*								         *
**************************************************************************
ARROWF
	MOVK	1,A8
	MOVI	ARROWF_ANI,A9
	MOVI	ANIMATOR,A11
	JRUC	GOODIE

**************************************************************************
*								         *
* EXCLAIM - PROCESS TO ANIMATE THE EXCLAMATION POINT AT A GIVEN POINT	 *
* A10 = [Y,X] START POSITION						 *
*								         *
**************************************************************************
EXCLAIM
	MOVK	1,A8
	MOVI	EXCLA_ANI,A9
	MOVI	ANIMATOR,A11
	JRUC	GOODIE

**************************************************************************
*								         *
* EXCLAIMF - PROCESS TO ANIMATE THE FLIPPED EXCLA PNT AT A GIVEN POINT	 *
* A10 = [Y,X] START POSITION						 *
*								         *
**************************************************************************
EXCLAIMF
	MOVK	1,A8
	MOVI	EXCLAF_ANI,A9
	MOVI	ANIMATOR,A11
	JRUC	GOODIE

**************************************************************************
*								         *
* YO - PROCESS TO ANIMATE THE YO					 *
* A10 = [Y,X] POSITION							 *
*								         *
**************************************************************************
YO
	MOVK	1,A8
	MOVI	YO_ANI,A9
	MOVI	ANIMATOR,A11
	JRUC	GOODIE

**************************************************************************
*								         *
* YOF - PROCESS TO ANIMATE THE FLIPPED YO				 *
* A10 = [Y,X] POSITION							 *
*								         *
**************************************************************************
YOF
	MOVK	1,A8
	MOVI	YOF_ANI,A9
	MOVI	ANIMATOR,A11
	JRUC	GOODIE

**************************************************************************
*								         *
* WOWDEL - PROCESS TO ANIMATE AND DELETE THE WOW			 *
* A10 = [Y,X] POSITION							 *
*								         *
**************************************************************************
WOWDEL
	MOVK	1,A8
	MOVI	WOW_ANI,A9
	MOVI	ANIMATE_DEL,A11
	JRUC	GOODIE

**************************************************************************
*								         *
* SKYROCKET1 - FIRE A ONE SHOT SKYROCKET.				 *
* A10 = [Y,X] POSITION							 *
* A11 = PTR TO PLAYER DATA AREA						 *
*								         *
**************************************************************************
SKYROCKET1
	MOVK	1,A8
	MOVE	A11,A2
	MOVI	ANIMATE_DEL,A11
	JRUC	SR_G
**************************************************************************
*								         *
* SKYROCKET - PROCESS TO ANIMATE A PLAYER SKYROCKET OVER AND OVER	 *
* A10 = [Y,X] POSITION							 *
* A11 = PTR TO PLAYER DATA AREA						 *
*								         *
**************************************************************************
SKYROCKET
	MOVK	3,A8
	MOVE	A11,A2
	MOVI	ANIMATOR,A11
SR_G
	CALLA	GPLAYNUM
	SLL	5,A0
	ADDI	PROCKETS,A0
	MOVE	*A0,A9,L
	JRUC	GOODIE

**************************************************************************
*								         *
* FIREWERK1 - PROCESS TO ANIMATE A PLAYER FIREWORK, ONE TIME!		 *
* A10 = [Y,X] POSITION							 *
* A11 = PTR TO PLAYER DATA AREA						 *
*								         *
**************************************************************************
FIREWERK_ONE
	MOVK	1,A8
	MOVE	A11,A2
	MOVI	ANIMATE_DEL,A11
	JRUC	FW_G

**************************************************************************
*								         *
* FIREWERK - PROCESS TO ANIMATE A PLAYER FIREWORK			 *
* A10 = [Y,X] POSITION							 *
* A11 = PTR TO PLAYER DATA AREA						 *
*								         *
**************************************************************************
FIREWERK
	MOVK	3,A8
	MOVE	A11,A2
	MOVI	ANIMATOR,A11
FW_G
	CALLA	GPLAYNUM
	SLL	5,A0
	ADDI	PFIREWERKS,A0
	MOVE	*A0,A9,L
	JRUC	GOODIE

**************************************************************************
*								         *
* GOODIE - PROCESS TO CREATE AND ANIMATE ONE OF JACKS LITTLE GOODIES.	 *
* A8 = FRANIM COMMAND							 *
* A9 = ANIMATION SCRIPT							 *
* A10 = [Y,X] POSITION							 *
* A11 = ROUTINE TO JUMP TO TO ANIMATE THIS THING			 *
*								         *
**************************************************************************
GOODIE
	MOVI	GOODIE_INIT,A5
	CALLA	CREATE_OBJ
	JAZ	DUMDIE
	MMTM	A12,A8,A9
	MOVE	A0,A8
	MOVK	4,A1
	JSRP	FRANIM
	PULLP	A9
	MOVE	A10,A3
	CALLA	OBJ_TO_PNT	
	MOVI	GOODIEOID,A1
	MOVE	A1,*A8(OID),W
	MOVI	BUYWIN_Z,A1
	MOVE	A1,*A8(OZVAL),L
	MOVE	A13,*A8(OPLINK),L
	CALLA	INSERT_OBJ
	MOVE	A11,A7
	PULLP	A11
	JUMP	A7	

*
*INITIALIZATION TABLE FOR THE GOODIE IMAGES
GOODIE_INIT:
	.LONG	DUMCOLL,0
	.WORD	DMAWNZ,JUNKOID
	.LONG	SPARK2

**************************************************************************
*								         *
* TRAILAMATE - PROCESS TO ANIMATE A SCRIPT TO COMPLETION. IT WILL	 *
* 		LEAVE THE PREVIOUS FRAME UP FOR A LITTLE AFTER		 *
* 		THE NEXT FRAME IS ANIMATED.				 *
* A8 = OBJECT TO ANIMATE						 *
* A9 = SCRIPT								 *
*								         *
**************************************************************************
TRAILAMATE
	CLR	A1
	JSRP	FRANIM
	JAC	DUMDIE
	CALLA	GETOBJ
	JRZ	TRAILAMATE
	CALLA	COPY_OBJ
	MOVE	*A8(OZVAL),A1,L
	DEC	A1
	MOVE	A1,*A0(OZVAL),L
	CALLA	INSOBJ
	MOVE	A8,A10
	MOVE	A0,A8
	CREATE	INDPID,SAP
	JRZ	TRAILAFAIL
	MOVE	A10,A8
	JRUC	TRAILAMATE
TRAILAFAIL
	MOVE	A8,A0
	CALLA	DELOBJ
	MOVE	A10,A8
	JRUC	TRAILAMATE

*THIS PROCESS GOES WITH TRAILAMATE
*LET OBJECT LIVE, THEN KILL IT
*A8 = OBJECT
SAP
	SLEEP	2	
	MOVE	A8,A0
	CALLA	DELOBJ
	DIE

**************************************************************************
*								         *
* STAT_WORKS - PROCESS TO CREATE THE END OF GAME FIREWORKS IF THERE	 *
* 		ARE STATS TO PRINT OUT.					 *
* A11 = PTR TO THE CHAMPION PLAYER					 *
*								         *
**************************************************************************
STAT_WORKS
	CREATE	GOODIEPID,STAT_BLASTS
SW_LP
	MOVK	26,B0
	MOVI	69,B1
	JSRP	SW_SUB
	MOVI	321,B0
	MOVI	370,B1
	JSRP	SW_SUB
	JRUC	SW_LP

SW_SUB
	CALLA	RANGRAND
	MOVE	A0,A10
	MOVI	SKYTOPOF,B0
	MOVI	SKYTOPOF+100,B1
	CALLA	RANGRAND
	SLL	16,A0
	MOVY	A0,A10
	CREATE	GOODIEPID,SKYROCKET1
	MOVK	5,B0
	MOVK	10,B1
	CALLA	RANGRAND
	SLEEPR	A0
	RETP

**************************************************************************
*								         *
* STAT_BLASTS - PROCESS TO CREATE THE END OF GAME EXPLOSIONS IF THERE	 *
* 		ARE STATS TO PRINT OUT.					 *
* A11 = PTR TO THE CHAMPION PLAYER					 *
*								         *
**************************************************************************
STAT_BLASTS
	MOVI	129,B0
	MOVI	261,B1
	CALLA	RANGRAND
	MOVE	A0,A10
	MOVI	SKYTOPOF-5,B0
	MOVI	SKYTOPOF,B1
	CALLA	RANGRAND
	SLL	16,A0
	MOVY	A0,A10
	CREATE	GOODIEPID,FIREWERK_ONE
	SOUND1	TROGSMACK2_SND
	MOVK	5,B0
	MOVK	12,B1
	CALLA	RANGRAND
	SLOOPR	A0,STAT_BLASTS


	.BSS	BONUSTEMP1,32		;TEMP VARIABLE FOR BONUS OUTPUT
	.BSS	BONUSTEMP2,32		;AND ANOTHER

*BONUS COUNT COMMENTED OUT 8/24/90 GNP
	.IF	0

**************************************************************************
*								         *
* BONUS_COUNT - PROCESS TO DO THE BONUS COUNT FOR THE WINNING PLAYER.	 *
* A11 = PTR TO PLAYERS DATA AREA					 *
*								         *
**************************************************************************
BONUS_COUNT:
	MOVI	BONUSPID,A0
	CLR	A1
	NOT	A1
	CALLA	KILALL

	SLEEP	15
	CLR	A8			;CLEAR THE BONUS

	JSRP	BONUS_EGGS
	JSRP	BONUS_TROGS
	JSRP	BONUS_X			;MULTIPLY

	MOVE	A11,A2
	CALLA	GPLAYNUM
	SLL	5,A0
	ADDI	PNAME15_TAB,A0
	MOVE	*A0,A0,L
	MOVE	A0,@BONUSTEMP1,L	;STORE THE NAME

	MMTM	A12,A8,A11
	MOVI	BONUS_NEW_MESS,A8
	JSRP	LM_PRINTF
	MMFM	A12,A8,A11

	MOVE	A8,A0
	CALLA	BINBCD
	MOVE	A0,A1
	MOVE	A11,A2
	CALLA	SCORE			;FLIP HIM THE BONUS

	MOVI	BONUSOID,A0
	CLR	A1
	NOT	A1
	CALLA	KILOBJ			;KILL THE CURRENT BONUS

	CALLR	NEXT_BONUSX_SND		;HORN HIT FOR SCORE
	SLEEP	1
	SOUND1	BMOFF_SND		;TRANSITION THE MUSIC OFF

	MOVE	*A11(PSCORE),A0,L
	MOVE	A0,@BONUSTEMP1,L	;STORE A SCORE
	MOVI	BCD_SCORE_MESS,A8
	JSRP	LM_PRINTF

	MOVI	POINTS_MESS,A8
	JSRP	LM_PRINTF

	SLEEP	120
	DIE

MAX_BONUS_EGGS	.EQU	19
**************************************************************************
*								         *
* BONUS_EGGS - ROUTINE TO COUNT THE BONUS FOR THE EGGS COLLECTED.	 *
* A8 = CURRENT BONUS							 *
* A11 = PTR TO PLAYER DATA						 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
BONUS_EGGS:
	MOVE	*A11(PEGGS),A0,W
	JRZ	BONUS_EGGS_X		;NO EGGS
	MMTM	SP,A8,A11
	MOVI	EGGS_MESS,A8
	JSRP	LM_PRINTF
	MOVE	*SP,A2,L		;RETRIEVE THE PLAYER DATA PTR
	MOVE	*A2(PWINS),A4,W
	DEC	A4
	CMPI	MAX_SCORES_PER_WIN-1,A4	
	JRLO	BONUS_EGG_SCORE
	MOVI	MAX_SCORES_PER_WIN-1,A4
	MOVI	EGG_VALUE_INC2,A5
	MOVE	A5,@BONUSTEMP2,L
	JRUC	BONUS_EGG_STRING
BONUS_EGG_SCORE:
	MOVI	EGG_VALUE_INC1,A5
	MOVE	A5,@BONUSTEMP2,L
	JRUC	BONUS_EGG_STRING
BONUS_EGG_STRING:
	SLL	4,A4
	ADDI	EGG_SCORE_PER_WIN,A4
	MOVE	*A4,A4,W
	PUSH	A4
	MOVE	A4,@BONUSTEMP1,L	;STORE THIS FOR STRING OUTPUT

	MOVI	EGG_VALUE_MESS,A8
	JSRP	LM_PRINTF

	PULL	A9			;RETRIEVE THE SCORE TO GIVE /

	MMFM	SP,A8,A11
*DON'T SCREW WITH A9 UNTIL AFTER THE COUNT_STUFF CALL
	MOVI	TEXTOID,A0
	MOVI	ICONOID,A1
	CALLA	CHANGOID		;THESE WILL BE ERASED

	MOVE	A11,A2
	CALLA	GPLAYNUM
	SLL	5,A0
	ADDI	EGG_TAB,A0

	MOVE	*A0,A14,L		;USE THIS EGG IMAGE
	MOVI	[158+SKYTOPOF,200],A3	;START THE EGGS HERE
	MOVI	MAX_BONUS_EGGS,A6	;THIS IS THE MOST WE CAN HAVE
	MOVE	*A11(PEGGS),A10		;COUNT THIS MANY EGGS
	MOVI	BONUS_EGG_SND,A0
	JSRP	COUNT_STUFF
	SLEEP	60
	MOVI	ICONOID,A0
	CLR	A1
	NOT	A1
	CALLA	KILOBJ			;WASTE THIS COUNT
	SLEEP	10
BONUS_EGGS_X:
	RETP

MAX_SCORES_PER_WIN	.EQU	10
*
*TABLE OF SCORES TO GIVE PER WIN, IN DECIMAL
EGG_SCORE_PER_WIN:
	.WORD	750,1000,1250,1500,1750,2000,2500,3000,4000,5000

MAX_BONUS_TROGS	.EQU	5
**************************************************************************
*								         *
* BONUS_TROGS - ROUTINE TO COUNT THE BONUS FOR THE TROGS TRICKED.	 *
* A8 = CURRENT BONUS							 *
* A11 = PTR TO PLAYER DATA						 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
BONUS_TROGS:
	MOVE	*A11(PTROGKILLS),A0,W
	JRZ	BONUS_TROGS_X		;NO TROG KILLS

	SOUND1	BONUS_TROG_INTRO_SND

	MMTM	SP,A8,A11
	MOVI	TROGS_MESS,A8
	JSRP	LM_PRINTF
	MOVI	TROG_VALUE_MESS,A8
	JSRP	LM_PRINTF
	MMFM	SP,A8,A11

	MOVI	TEXTOID,A0
	MOVI	ICONOID,A1
	CALLA	CHANGOID		;THESE WILL BE ERASED

	MOVI	TROGINIT,A14		;USE THIS TROG IMAGE
	MOVI	[135+SKYTOPOF,214],A3	;START THE TROGS HERE
	MOVI	MAX_BONUS_TROGS,A6	;THIS IS THE MOST WE CAN HAVE
	MOVI	7500,A9			;THIS MUCH PER KILL
	MOVE	*A11(PTROGKILLS),A10	;COUNT THIS MANY KILLS
	MOVI	BONUS_TROG_SND,A0
	JSRP	COUNT_STUFF
	SLEEP	60
	MOVI	ICONOID,A0
	CLR	A1
	NOT	A1
	CALLA	KILOBJ			;WASTE THIS COUNT
	SLEEP	10
BONUS_TROGS_X:
	RETP

	.BSS	BONUSX_CNT,16		;NUMBER OF MULTIPLIERS COUNTED
	.BSS	BONUSX_SND_CNT,16	;NUMBER OF MULTIPLIER SOUNDS MADE

**************************************************************************
*								         *
* BONUS_X - MULTIPLY BONUS FOR BEATING OTHER CHARACTERS.		 *
* A8 = CURRENT BONUS							 *
* A11 = PTR TO PLAYER DATA						 *
* RETURNS:								 *
* A8 = NEW BONUS							 *
* NOTE: CALL WITH JSRP							 *
*	TRASHES PTEMP1 & PTEMP2						 *
*								         *
**************************************************************************
BONUS_X:
	CLRM	@BONUSX_CNT,W		;CLEAR THE RAM COUNTER
	CLRM	@BONUSX_SND_CNT,W

	MOVE	*A11(PINSTRUCT),A0,W	;WAS HE IN INSTRUCTIONAL MODE?
	JRNZ	BONUS_X_X		;BR = YES, THEN NO MULTIPLIERS

	MOVE	A8,*A13(PTEMP1),L	;STORE THE CURRENT SCORE
	MOVE	A8,*A13(PTEMP2),L	;MULTIPLY BY THIS MUCH EVERY TIME

****	MOVI	1923,A1
	MOVE	@FAST_TIME,A1,W

	MOVE	*A11(PWAVETIME),A0,L
	SUB	A0,A1
	JRN	BONUS_X_PLAYERS
	SRL	6,A1			;DIVIDE ROUGHLY BY 62.5 FOR SECONDS
	JRZ	BONUS_X_PLAYERS

****	MOVK	30,A3	
	MOVE	@FAST_TIME,A3,W
	SRL	6,A3

	SUB	A1,A3			;HE FINISHED IN THIS MANY SECONDS 
	JRLE	BONUS_X_PLAYERS
	MOVE	A3,@BONUSTEMP1,L

	PUSHP	A11
	MOVI	FASTFIN_MESS,A8
	JSRP	LM_PRINTF
	MOVI	UNDER30_MESS,A8
	JSRP	LM_PRINTF

	MOVI	TEXTOID,A0
	MOVI	BTITLEOID,A1
	CALLA	CHANGOID		;RECOGNIZE ME

	SLEEP	20

	MOVE	@BONUSTEMP1,A3,W

****	MOVI	30,A1
	MOVE	@FAST_TIME,A1,W
	SRL	6,A1

	SUB	A3,A1
	JRGT	BONUS_TIME_OK
	MOVK	1,A1
BONUS_TIME_OK:
	MOVE	A1,*A13(PTEMP3),W
	CLRM	@BONUSTEMP1,W

BONUS_TIME_LP:
	INCM	@BONUSTEMP1,W
	MOVI	FINTIME_MESS,A8
	JSRP	LM_PRINTF

	MOVI	ICONOID,A0
	CLR	A1
	NOT	A1
	CALLA	KILOBJ			;WASTE THE OLD ONE

	MOVI	TEXTOID,A0
	MOVI	ICONOID,A1
	CALLA	CHANGOID		;GET'TA KNOW ME
	DECM	*A13(PTEMP3),W
	JRZ	BONUS_TIME_DONE
	SOUND1	BONUS_TIME_SND
	SLOOP	4,BONUS_TIME_LP

BONUS_TIME_DONE:
	PULLP	A11
	MOVE	*A13(PTEMP1),A8,L
	MOVE	@BONUSTEMP1,A1,W
	MOVI	5000,A9
	MPYU	A1,A9
	CALLR	ADD_BONUS
	MOVE	A8,*A13(PTEMP1),L
	MOVE	A8,*A13(PTEMP2),L

	CALLR	NEXT_BONUSX_SND

	SLEEP	70

	MOVI	BTITLEOID,A0
	CLR	A1
	NOT	A1
	CALLA	KILOBJ			;WASTE THIS TITLE

	MOVI	ICONOID,A0
	CLR	A1
	NOT	A1
	CALLA	KILOBJ			;WASTE THIS TITLE

	SLEEP	10

BONUS_X_PLAYERS:
	CALLA	WAVE_PLAYERS		;HOW MANY PLAYERS THIS WAVE?
	CMPI	1,A0
	JRLS	BONUS_X_X		;BR = HE DIDN'T BEAT ANYBODY
BONUS_X_NOW:
	MMTM	SP,A8,A11
	MOVI	YOUBEAT_MESS,A8
	JSRP	LM_PRINTF
	MMFM	SP,A8,A11

	MOVI	TEXTOID,A0
	MOVI	BTITLEOID,A1
	CALLA	CHANGOID		;THIS TEXT WILL STAY

	SLEEP	20

	MOVI	P1DATA,A9
	MOVE	@NPLAYERS,A10,W
	MOVE	@BONUSX_CNT,A8,W
	ADDK	2,A8			;WE START BY MULTIPLYING BY 2
BONUS_X_LP:
	CMP	A9,A11
	JREQ	BONUS_X_NXT		;BR = THIS IS US
	MOVE	*A9(PWAVEST),A0,W
	JRZ	BONUS_X_NXT		;BR = THIS LITTLE DINO DIDN'T PLAY
	MOVI	ICONOID,A0
	CLR	A1
	NOT	A1
	CALLA	KILOBJ			;KILL CURRENT BONUS X IF ANY
	MOVE	A9,A2
	CALLA	GPLAYNUM
	SLL	5,A0
	ADDI	PNAME15_TAB,A0
	MOVE	*A0,A0,L
	MOVE	A0,@BONUSTEMP1,L	;STORE THE NAME
	MOVE	A8,@BONUSTEMP2,W	;STORE THE MULTIPLIER
	INC	A8			;PREPARE FOR THE NEXT
	MMTM	A12,A8,A9,A10,A11

	MOVI	BEATNAME_MESS,A8
	JSRP	LM_PRINTF

	MOVI	TEXTOID,A0
	MOVI   	ICONOID,A1
	CALLA	CHANGOID		;THIS TEXT WILL STAY

	PULLP	A11	     		;RETURN THIS FIRST
	MOVE	*A13(PTEMP1),A8,L
	MOVE	*A13(PTEMP2),A9,L
	CALLR	ADD_BONUS
	MOVE	A8,*A13(PTEMP1),L
	MMFM	A12,A8,A9,A10		;AND THE REST

	CALLR	NEXT_BONUSX_SND

	INCM	@BONUSX_CNT,W

	SLEEP	30

BONUS_X_NXT:
	ADDI	PDSIZE,A9
	DEC	A10
	JRNN	BONUS_X_LP

	MOVE	*A13(PTEMP1),A8,L	;RESTORE THE SCORE

	SLEEP	40

	MOVI	BTITLEOID,A0
	CLR	A1
	NOT	A1
	CALLA	KILOBJ			;WASTE THIS TITLE
	MOVI	ICONOID,A0
	CALLA	KILOBJ			;WASTE THIS COUNT

	SLEEP	10
BONUS_X_X:
	RETP

**************************************************************************
*								         *
* NEXT_BONUSX_SND - MAKE THE NEXT BONUS MULTIPLIER SOUND		 *
* GLOBALS:								 *
* 	BONUSX_CNT,W							 *
* RETURNS:								 *
* 	NOTHING								 *
*								         *
**************************************************************************
NEXT_BONUSX_SND:
	PUSH	A0
	MOVE	@BONUSX_SND_CNT,A0,W
	CMPI	NUM_BONUSX_SNDS,A0
	JRLO	NEXT_BSND_OK
	MOVI	NUM_BONUSX_SNDS-1,A0
NEXT_BSND_OK:
	SLL	5,A0
	ADDI	BONUS_MULT_TAB,A0
	MOVE	*A0,A0,L
	CALLA	ONESND
	INCM	@BONUSX_SND_CNT,W
	PULL	A0
	RETS

**************************************************************************
*								         *
* COUNT_STUFF - COUNT A GIVEN BONUS WITH ICON OUTPUT.			 *
* A0 = SOUND TO MAKE EVERY OUTPUT (IF = 0 THEN NO SOUND)		 *
* A3 = [Y,X] CENTERING LOCATION						 *
* A6 = MAXIMUM TO DISPLAY						 *
* A8 = CURRENT BONUS							 *
* A9 = VALUE TO ADD FOR EACH						 *
* A10 = NUMBER TO COUNT							 *
* A11 = PTR TO PLAYER DATA AREA						 *
* A14 = INIT. TABLE OF ICON TO DISPLAY					 *
* RETURNS:								 *
* A8 = NEW BONUS							 *
* A9 = BONUS ADDER							 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
COUNT_STUFF:
	MOVE	*A14(INITIMG),A7,L
	MOVE	*A7(ISIZEX),A7,W	;LET'S COUNT THE SIZES
	ADDK	2,A7			;THIS IS THE SPACING
	MOVE	A10,A2			;COUNT THIS MANY
	MOVE	A6,A4			;BUT NOT MORE THAN THIS
	CLR	A5
COUNT_CENTER_LP:
	ADD	A7,A5
	DEC	A4
	JRZ	COUNT_CENTERED		;BR = HIT THE MAX
	DSJS	A2,COUNT_CENTER_LP
COUNT_CENTERED:
	SRL	1,A5
	SUBXY	A5,A3			;THIS IS THE STARTING POSITION
COUNT_OUT_LOUD:
	PUSHP	A0			;STORE SOUND
	MOVE	A14,A1
	MOVE	A6,A6
	JRZ	COUNT_ADD		;BR = MAX'ED OUT, JUST ADD
	DEC	A6
	CALLA	GPALOBJSTF
	JRZ	COUNT_ADD
	SWAP	A0,A8
	MOVI	ICONOID,A5
	MOVE	A5,*A8(OID),W		;WE CAN SEE CLEARLY NOW
	CALLA	OBJ_TO_PNT		;ALIGN ME
	CALLA	INSERT_OBJ
	SWAP	A0,A8
COUNT_ADD:
	MOVE	A1,A14
	ADDXY	A7,A3
	PULLP	A0
	MOVE	A0,A0
	JRZ	COUNT_WITH_NO_SOUND
	CALLA	ONESND			;MAKE A NOISE
COUNT_WITH_NO_SOUND:
	MMTM	A12,A0,A3,A6,A7,A14
	CALLR	ADD_BONUS
	SLEEP	3			;PAUSE TO SEE
	MMFM	A12,A0,A3,A6,A7,A14
	DSJ	A10,COUNT_OUT_LOUD
	RETP

	.ENDIF
**************************************************************************
*								         *
* ADD_BONUS - ADD A SPECIFIED AMOUNT TO THE PLAYERS BONUS AND OUTPUT.	 *
* A8 = CURRENT BONUS							 *
* A9 = AMOUNT TO ADD							 *
* A11 = PTR TO PLAYER DATA AREA						 *
* RETURNS:								 *
* A8 = NEW BONUS							 *
* A11 = PTR TO PLAYER DATA						 *
* NOTE: ONLY A8,A9,A10 & A11 ARE GUARANTEED				 *
*								         *
**************************************************************************
ADD_BONUS:
	MOVI	[182+SKYTOPOF,197],A3	;FIX THE COORDINATE
*A3 [Y,X] COORDINATE TO STUFF THE BONUS
ADD_BONUS_XY:
	ADD	A9,A8
	MMTM	SP,A8,A9,A10,A11
	MOVE	A8,@BONUSTEMP1,L
	MOVI	BONUSOID,A0
	CLR	A1
	NOT	A1
	CALLA	KILOBJ			;KILL THE CURRENT BONUS
	MOVI	BONUS_MESS,A8
	CALLA	LM_SETUP		;SETUP UP WHAT WE CAN
	MOVE	A3,A9			;STUFF THE DESIRED POSITION
	MOVE	*SP,A2,L		;PULL A11 INTO A2
	MOVE	*A2(PPALID),A0,L	;GET THE PALETTE I.D.
	CALLA	FINDPAL
	MOVI	[0E0EH,0],A5		;DMA THIS CONSTANT
	MOVX	A0,A5			;IN THIS PALETTE
	CLR	A0			;MAKE SURE THE SLEEP IS CLEAR
	JSRP	PRINTF			;OUTPUT THE NEW BONUS
	MOVI	TEXTOID,A0
	MOVI	BONUSOID,A1		;WE'LL FIND IT NEXT TIME
	CALLA	CHANGOID
	MMFM	SP,A8,A9,A10,A11
	RETS

**************************************************************************
*								         *
* 		STRINGS FOR THE BONUS COUNT				 *
*								         *
**************************************************************************

BONUS_MESS:
	MESS_MAC RD20FONT,1,197,(182+SKYTOPOF),0D0D0000H,STRCNRMO,0
	.STRING	"%,ld",0
	.LONG	BONUSTEMP1
	.EVEN

	.IF	0

BCD_SCORE_MESS:
	MESS_MAC RD20FONT,1,197,(150+SKYTOPOF),0D0D0000H,STRCNRMO,0
	.STRING	"%,lb",0
	.LONG	BONUSTEMP1
	.EVEN

EGGS_MESS:
	MESS_MAC RD15FONT,1,197,(117+SKYTOPOF),0F0F0101H,STRCNRMO,0
	.STRING	"Eggs Picked Up.",0
	.EVEN
EGG_VALUE_MESS:
	MESS_MAC RD7FONT,1,197,(138+SKYTOPOF),01010000H,STRCNRMO,0
	.STRING	"(%p each)",0
	.LONG	BONUSTEMP2
	.EVEN

EGG_VALUE_INC1:
	.STRING	"%,d",0
	.LONG	BONUSTEMP1
	.EVEN
EGG_VALUE_INC2:
	.STRING	"\b%,d\b",0
	.WORD	0D0DH
	.LONG	BONUSTEMP1
	.WORD	0101H
	.EVEN

TROGS_MESS:
	MESS_MAC RD15FONT,1,197,(117+SKYTOPOF),0F0F0101H,STRCNRMO,0
	.STRING	"Tricking TROG!",0
	.EVEN
TROG_VALUE_MESS:
	MESS_MAC RD7FONT,1,197,(138+SKYTOPOF),01010000H,STRCNRMO,0
	.STRING	"(7,500 each time)",0
	.EVEN

BONUS_NEW_MESS
	MESS_MAC RD15FONT,1,197,(124+SKYTOPOF),02020000H,STRCNRMO,0
	.STRING	"%p \p\bNow Has",0
	.LONG	BONUSTEMP1
	.LONG	RED16
	.WORD	0F0FH
	.EVEN

POINTS_MESS:
	MESS_MAC RD15FONT,1,197,(182+SKYTOPOF),0F0F0101H,STRCNRMO,0
	.STRING	"Points.",0
	.EVEN

YOUBEAT_MESS:
	MESS_MAC RD15FONT,1,197,(117+SKYTOPOF),0F0F0101H,STRCNRMO,0
	.STRING	"You Beat:",0
	.EVEN	

BEATNAME_MESS:
	MESS_MAC RD15FONT,1,197,(139+SKYTOPOF),04040000H,STRCNRMO,0
	.STRING	"%p\d\n\f%dX",0
	.LONG	BONUSTEMP1
	.LONG	RD20FONT
	.LONG	[-10,0]
	.LONG	BONUSTEMP2
	.EVEN

FASTFIN_MESS:
	MESS_MAC RD15FONT,1,197,(117+SKYTOPOF),0F0F0101H,STRCNRMO,0
	.STRING	"Fast Finish!",0
	.EVEN

UNDER30_MESS:
	MESS_MAC RD7FONT,1,197,(138+SKYTOPOF),01010101H,STRCNRMO,0
	.STRING	"(In %d Seconds !!)",0
	.LONG	BONUSTEMP1
	.EVEN

FINTIME_MESS:
	MESS_MAC RD20FONT,1,197,(153+SKYTOPOF),0F0F0101H,STRCNRMO,0
	.STRING	"%d x 5,000",0
	.LONG	BONUSTEMP1
	.EVEN

TIMESX_MESS:
	MESS_MAC RD20FONT,1,197,(153+SKYTOPOF),0F0F0101H,STRCNRMO,0
	.STRING	"%dX",0
	.LONG	BONUSTEMP1
	.EVEN

**************************************************************************
*								         *
* 		SOUND FOR THE BONUS COUNT				 *
*								         *
**************************************************************************
BONUS_EGG_SND:
	.WORD	>F301,>1,>80AB,0	;SOUND FOR EACH BONUS EGG
BONUS_TROG_INTRO_SND:
	.WORD	>F001,>1,>803E,0	;SOUND TO SAY THERE ARE BONUS TROGS
BONUS_TROG_SND:
	.WORD	>F301,>1,>809D,0	;SOUND FOR EACH BONUS TROG
BONUS_TIME_SND:
	.WORD	>F301,>1,>809D,0	;SOUND FOR EACH BONUS TROG

BONUS_MULT_TAB:
	.LONG	BMX1_SND,BMX2_SND,BMX3_SND,BMX4_SND,BMX5_SND

BMOFF_SND
	.WORD	>F2E1,>1,>800C,0	;TRANSITION BONUS MUSIC OFF

NUM_BONUSX_SNDS	.EQU	5

BMX1_SND
	.WORD	>F3E1,>1,>80AF,0	;X 1
BMX2_SND
	.WORD	>F3E1,>1,>80B0,0	;X 2
BMX3_SND
	.WORD	>F3E1,>1,>80B1,0	;X 3
BMX4_SND
	.WORD	>F3E1,>1,>80B2,0	;X 4

	.ENDIF

BMX5_SND
	.WORD	>F3E1,>1,>80B9,0	;X 5

**************************************************************************
*								         *
* TIME_WARP - WARP EFFECT						 *
* A8	= PTR TO DINOSAUR OBJECT					 *
* A9	= PTR TO TUNNEL OBJECT						 *
* A10	= PTR TO DINOSAUR ANIMATION TABLE				 *
* A13	= PTR TO DINOSAUR PROCESS					 *
* NOTE: XFERING THE DINO PROCESS HERE WILL END THE WAVE			 *
*								         *
**************************************************************************
TIME_WARP:
	CALLA	KILL_INVINCIBILITY
	MOVE	@GAME_STATE,A0,W
	CMPI	INGAMEOV,A0
	JREQ	TW_SKIP_ST
	CMPI	INGAME,A0
	JAEQ	DINOMADXFER		;SKIP BECAUSE WE ARE ALREADY COMPLETE

	MOVI	INGAME,A0		;WE ARE THE FIRST TO PASS
	MOVE	A0,@GAME_STATE,W

TW_SKIP_ST:
	MOVK	1,A0
	MOVE	A0,@WAVE_OVER,W		;FLAG THE WAVE DONE

	MOVI	COLLPID,A0
	MOVI	0FFF0H,A1
	CALLA	KILALL			;KILL THE COLLISION PROCESSES

	MOVE	A9,*A13(PTEMP1),L	;KEEP THE PIT POINTER

	CALLA	TREX_KILL		;KILL THE TREX IF NECESSARY

	MOVE	*A13(DPLAYER),A2,L
	MOVE	*A2(PDRONEFLG),A0,W	;STORE DRONE FLAG FOR LATER
	JRZ	TW_PLAYER
	CLR	A0
	MOVE	A0,*A2(POBJ),L		;CLEAR THIS DRONES OBJECT FOR RE-START
TW_PLAYER:
	MOVI	DIGU,A0
	JSRP	FRANIMATE_DIR		;ANIMATE THE FIRST PART OF THE FALL

	MOVK	1,A11			;FRANIM COMMAND
	CREATE	INDPIDW,ANIMATOR	;ANIMATE THE DINO FOREVER
	MOVE	A0,*A8(OPLINK),L	;LINK DINO TO THAT PROCESS

	JSRP	WAIT_WAVE_END		;WAIT FOR ALL WAVE END PROCS TO END

	MOVI	PHELPPID,A0
	MOVI	PPROCMASK,A1
	CALLA	KILALL			;KILL ALL OF THE HELPER BOXES

	MOVI	7FFF0002H,A1
	MOVE	A1,*A8(OZVAL),L
	
****	SOUND1	ALLOFF
****	SLEEP	4
	SLEEP	2
	SOUND1	VOLUME0
	SLEEP	2

	CLR	A0
	MOVI	0E000h,A1
	CALLA	KILALL			;KILL EVERYTHING WE CAN

	MOVE	A8,A5
	MOVE	*A13(PTEMP1),A8,L
	CALLA	GETANIXY		;GET THE PIT ANIMATION POINT
	MOVE	A5,A8  			;RESTORE THE DINO POINTER
	SRL	16,A3
	MOVX	A3,A2
	MOVE	A2,A10
	MOVK	30,A11
	CREATE	INDPID,WIPE_FROM_XY	;CLEAR COOL CLEAR SCREEN

	CALLA	GETANIXY
	SRL	16,A3
	MOVX	A3,A2
	MOVI	[124,202],A3
	MOVI	40,A4			;LONGER THAN WIPE_FROM_MID SLEEP
	CALLA	SLINEVEL
	MOVE	A1,*A8(OXVEL),L
	MOVE	A2,*A8(OYVEL),L
	SLEEP	35			;LONGER THAN WIPE_FROM_MID SLEEP
	CLR	A0	     		;SCREEN SHALL BE BLACK
	MOVE	A0,@IRQSKYE,W
	SLEEP	5
	CALLA	PSTOP

	CLR	A1
	CALLA	KILB2OBJ
	CALLA	KILBOBJ
	CALLA	KILOBJ_XA8		;RID OF ALL OBJECTS EXCEPT WARPER

	CALLA	CLRBPAL			;CLEAR THE BACKGROUND PALETTES

	ALLPLYR	CLR_PDINOCNT		;CLEAR THE DINOSAUR COUNTS
	CALLA	SCORAREA		;REPLOT THE SCORE AREA

	MOVI	7FFF0000H,A1
	MOVE	A1,*A8(OZVAL),L

	MOVE	*A8(OID),A0,W
	SLL	28,A0
	SRL	28,A0
	CALLA	GPLAYD			;GET THAT PLAYERS DATA AREA
	MOVE	A2,A11
	MOVI	25000H,A1
	CALLA	SCORE			;XTRA 25K FOR THE DO GUY

*WARP EFFECT HERE
	SOUND1	WARP_SND		;MAKE THE SOUND

	CREATE	INDPID,WARP_EFFECT

	SLEEP	40

	MOVE	A8,*A13(PTEMP1),L

	PUSHP	A11
	MOVI	WARP_MESS,A8
	JSRP	LM_PRINTF

	MOVI	WARPTO_MESS,A8
	JSRP	LM_PRINTF

	MOVI	WARPBON_MESS,A8
	JSRP	LM_PRINTF

	PULLP	A11

	MOVI	TEXTOID,A0
	MOVI	BTITLEOID,A1
	CALLA	CHANGOID		;LETTERS SHOULD BE NON-DISCERNABLE

	SLEEP	30

	CLR	A8
	MOVE	@TUNNEL_SCORE,A9,L	;GET THE SCORE VALUE
	MOVI	[130+SKYTOPOF,197],A3	;FIX THE COORDINATE
	CALLR	ADD_BONUS_XY	

	SLEEP	20

	SOUNDOFF			;DON'T RUIN THE GRANNER EFFECT
	MOVE	A8,A0
	CALLA	BINBCD
	MOVE	A0,A1
	ALLPLYR	SCORE_IF_ACTIVE
	SOUNDON

	MOVI	WARPEVERY_MESS,A8
	JSRP	LM_PRINTF

	SLEEP	40

	CLR	A1
	NOT	A1
	MOVI	BTITLEOID,A0
	CALLA	KILOBJ
	MOVI	TEXTOID,A0
	CALLA	KILOBJ
	MOVI	BONUSOID,A0
	CALLA	KILOBJ

	SLEEP	27
	SOUND1	YAMOFF
	SLEEP	3

	SOUND1	WARP2_SND		;FIRE DOWN THE TUBE
	SOUND1	WARP3_SND		;AND CONTINUE
	SLEEP	5	
	MOVE	*A13(PTEMP1),A8,L
	CALLA	OBJPROC_KILL
	MOVI	GWEN_FLIPOUT,A9
	MOVK	1,A1
	JSRP	FRANIM
	CALLA	DELETE_OBJ

	SLEEP	20

	MOVI	WARP_TAB,A6
	MOVE	*A6+,A10,L
TW_WOW
	CREATE	INDPID,WOWDEL
	MOVE	*A6+,A10,L
	JRNZ	TW_WOW

	SOUND1	BMX5_SND

	SLEEP	40

	SOUND1	ALLOFF
	SLEEP	4
	SOUND1	VOLUMEF
	SLEEP	4

	MOVE	@TUNNEL,A0,W
	MOVE	@WAVE,A1,W
	DEC	A0
	MOVE	A0,@WAVE,W		;FOOL WAVE_END INTO MAKING OURS NEXT
	ALLPLYR	STUFF_PLASTWIN		;UP THE LAST WIN VARIABLE ON EVERYONE
	SUB	A1,A0
	ABS	A0
	JRZ	WARP_END
WARP_INC_LP:	
	ALLPLYR	INC_PCONSECUTIVE	;INC OR CLR THE CONSECUTIVE WAVE COUNT
	DSJS	A0,WARP_INC_LP
WARP_END:
	.IF	PRINTER
	CALLA	PGAMEWARP		; FLAG A GAME WARP
	.ENDIF
	JAUC	WAVE_END


WARP_MESS:
	MESS_MAC RD20FONT,3,197,40+SKYTOPOF,0D0D0000H,STRCNRMO,0
	.STRING	"Time Warp!",0
	.EVEN

WARPTO_MESS:
	MESS_MAC RD7FONT,1,197,70+SKYTOPOF,01010000H,STRCNRMO,0
	.STRING	"(To Island %d)",0
	.LONG	TUNNEL
	.EVEN

WARPBON_MESS:
	MESS_MAC RD20FONT,1,197,90+SKYTOPOF,0D0D0000H,STRCNRMO,0
	.STRING	"Bonus.",0
	.EVEN

WARPEVERY_MESS:
	MESS_MAC RD15FONT,1,197,160+SKYTOPOF,01010101H,STRCNRMO,0
	.STRING	"(For Everyone!)",0
	.EVEN

*
*NOTE: ALL OF THESE SOUNDS ARE DAMN IMPORTANT, SO THEY BETTER
*	BE OF HIGHER PRIORITY THAN EVEN THE FREE MAN SOUND!
WARP_SND:
	.WORD	>F3F0,>10,>80B4,0	;SOMEBODY JUST WARPED
WARP2_SND:
	.WORD	>F0F0,>10,>8051,0	;START OF HYPER SPACE
WARP3_SND:
	.WORD	>F3F0,>10,>80B5,0	;HYPER SPACE FINISH

	
*A11 = PLAYER DATA WARPING
WARP_EFFECT:
	MOVE	A11,*A13(PTEMP3),L	;STORE THIS PLAYER
	MOVK	1,A11
	MOVI	GWEN_FLIPIN,A9
	MOVK	4,A0
	MOVE	A0,*A13(PTEMP1),W
	MOVI	P1DATA,A2
	MOVE	A2,*A13(PTEMP2),L
WARP_EFFECT_LP:
	MOVI	WARP_TAB,A10
WARP_EFFECT_LP2:
	MOVK	7,A6
WARP_EFFECT_LP3:
	MOVE	*A13(PTEMP2),A2,L
	ADDI	PDSIZE,A2
	CMPI	P4DATA,A2
	JRLS	WARP_EFFECT_PLAYER
	MOVI	P1DATA,A2
WARP_EFFECT_PLAYER:
	MOVE	A2,*A13(PTEMP2),L
	CALLA	GPLAYNUM
	SLL	5,A0
	ADDI	WARPOBJ_TAB,A0
	MOVE	*A0,A14,L
	CALLA	GPALOBJSTF
	JRZ	WARP_EFFECT_X
	MOVE	A0,A8
	MOVI	[124,202],A2
	MOVE	*A10+,A3,L
	JRZ	WARP_EFFECT_NXT
	MOVK	20,B0
	MOVK	30,B1
	CALLA	RANGRAND
	MOVE	A0,A4
	CALLA	SLINEVEL
	MOVE	A1,*A8(OXVEL),L
	MOVE	A2,*A8(OYVEL),L
	MOVI	SPFLP0F30,A1			;ANIMATE IN THE FLIP FRAME
	MOVE	*A8(OFLAGS),A4,W
	CALLA	ANI
	CREATE	INDPID,ANIMATE_DEL
	MOVI	[124,202],A3
	CALLA	OBJ_TO_PNT
	CALLA	INSERT_OBJ
	DSJ	A6,WARP_EFFECT_LP3
	SLEEP	4
	JRUC	WARP_EFFECT_LP2
WARP_EFFECT_NXT:
	DECM	*A13(PTEMP1),W
	JRNZ	WARP_EFFECT_LP

	MOVI	WARP_TAB,A10			;RELOAD THE WARP TABLE

WARP_EFFECT_FINAL:
	MOVE	*A13(PTEMP3),A2,L
	CALLA	GPLAYNUM
	SLL	5,A0
	ADDI	WARPOBJ_TAB,A0
	MOVE	*A0,A14,L
	CALLA	GPALOBJSTF
	JRZ	WARP_EFFECT_X
	MOVE	A0,A8
	MOVI	[124,202],A2
	MOVE	*A10+,A3,L
	JRZ	WARP_EFFECT_X
	MOVI	60,A4
	CALLA	SLINEVEL
	MOVE	A1,*A8(OXVEL),L
	MOVE	A2,*A8(OYVEL),L
	MOVI	SPFLP0F30,A1			;ANIMATE IN THE FLIP FRAME
	MOVE	*A8(OFLAGS),A4,W
	CALLA	ANI
	CREATE	INDPID,WARPIMATE
	MOVI	[124,202],A3
	CALLA	OBJ_TO_PNT
	CALLA	INSERT_OBJ
	JRUC	WARP_EFFECT_FINAL
WARP_EFFECT_X:
	DIE
*
*SUBWARP
*PROCESS
WARPIMATE:
	MOVK	1,A1
	JSRP	FRANIM
	CALLA	GETANIXY
	SRL	16,A3
	MOVX	A3,A2
	MOVI	[124,202],A3
	MOVK	30,A4
	CALLA	SLINEVEL
	MOVE	A1,*A8(OXVEL),L
	MOVE	A2,*A8(OYVEL),L
	MOVI	GWEN_FLIPOUT,A9
	MOVK	1,A1
	JSRP	FRANIM
	CALLA	DELETE_OBJ
	DIE

WARP_TAB:
	.LONG	[31,21]
	.LONG	[207,372]
	.LONG	[207,21]
	.LONG	[31,372]
	.LONG	[31,202]
	.LONG	[207,202]
	.LONG	[124,21]
	.LONG	[124,372]
	.LONG	[77,111]
	.LONG	[77,288]
	.LONG	[164,288]
	.LONG	[164,111]
	.LONG	[124,245]
	.LONG	[207,111]
	.LONG	[77,202]
	.LONG	[31,111]
	.LONG	[207,288]
	.LONG	[164,21]
	.LONG	[77,372]
	.LONG	[124,159]
	.LONG	[31,159]
	.LONG	[77,330]
	.LONG	[207,245]
	.LONG	[207,66]
	.LONG	[77,245]
	.LONG	[164,159]
	.LONG	[207,330]
	.LONG	[31,66]
	.LONG	[164,202]
	.LONG	[207,159]
	.LONG	[31,330]
	.LONG	[164,372]
	.LONG	[77,159]
	.LONG	[164,66]
	.LONG	[31,288]
	.LONG	[164,245]
	.LONG	[77,66]
	.LONG	[124,66]
	.LONG	[31,245]
	.LONG	[164,330]
	.LONG	[77,21]
	.LONG	[124,330]
	.LONG	[124,111]
	.LONG	[124,288]
	.LONG	0

WARPOBJ_TAB:
	.LONG	REXINIT,BLOOPINIT,ELVISINIT,SPIKEINIT

	.BSS	BIG_WINNER_FLAG,16,1	;FLAG FOR THE MONDO 1 CREDIT COMPLETE

**************************************************************************
*								         *
* GAME_ENDER - END OF GAME EFFECT					 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
GAME_ENDER
	SLEEP	50
	CLRM	@BIG_WINNER_FLAG,W
	MOVI	INEPILOG,A0
	MOVE	A0,@GAME_STATE,W
	MOVK	1,A0
	MOVE	A0,@GAMERASE,W		;AUTO ERASE ON
	CREATE	INDPID,GAME_END_WARP
	SLEEP	50H
	MOVI	GE_TEXT1,A8
	JSRP	LM_PRINTF
	SLEEP	140
	CREATE	FWORKSPID,GE_WORKS
	MOVI	GE_TEXT2,A8
	JSRP	LM_PRINTF
	SLEEP	400

	CALLA	CLRTEXT
	SOUND1	MUSICOFF
	JSRP	FIREWORKS_END

       	SOUND1	JUNGLE_SND

	ALLPLYR	CLR_PEXTRAS

	MOVE	@NPLAYERS,A8,W
	MOVI	P1DATA,A11
	MOVE	A11,A9
	CLR	A10
GE_BONUS_LP
	JSRP	GE_BONUS
	MOVE	*A11(PSCORE),A0,L
	CMP	A10,A0
	JRLS	GE_NBIG
	MOVE	A0,A10
	MOVE	A11,A9
GE_NBIG
	ADDI	PDSIZE,A11
	DEC	A8
	JRNN	GE_BONUS_LP

	SLEEP	5

	ALLPLYR	GE_HSCHECK
	ALLPLYR	PLAYER_CLR

	MOVE	A10,A10
	JRZ	GE_SKIP_SHOW
	MOVE	A9,A11

	MOVE	*A11(PINITAB),A14,L	;GET THE INITIALIZATION TABLE
	CALLA	GPALOBJSTF
	JRZ	GE_SKIP_SHOW		;BR = WE FAILED TO GET AN OBJECT

	MOVE	A0,A8
	MOVI	[165,195],A3
	CALLA	OBJ_TO_PNT
	CALLA	INSERT_OBJ

	MOVI	DINOFLY_ANIM,A9
	MOVK	1,A1
	JSRP	FRANIM

	MOVI	BUYWIN_Z,A1
	MOVE	A1,*A8(OZVAL),L

	MOVK	5,A0
	MOVE	A0,*A11(PWINS),W
	CALLR	PARTY_STUFF
	SLEEP	40
	CALLR	DANCE_STUFF		;MAKE SURE A11 STILL IS PLAYER DATA

	MOVE	*A8(OID),A2,W
	SLL	30,A2
	SRL	24,A2
	MOVE	A2,A4
	ADDI	DINOCHEER_ANIM,A4
	MOVE	*A4+,A9,L
	CREATE	INDPID,CELEBRATEAMATE
	MOVE	A0,*A8(OPLINK),L

	MOVE	*A4+,A9,L			;DOES HE HAVE ANOTHER PART?
	JRZ	CELE_1PART			;BR = NO

	CALLA	GETOBJ				;ADD A SECOND PART
	JRZ	CELE_1PART

	CALLA	COPY_OBJ
	MMTM	A12,A2,A8,A9
	MOVE	A0,A8
	MOVK	4,A1
	JSRP	FRANIM
	CALLA	INSERT_OBJ
	PULLP	A9
	CREATE	INDPID,CELEBRATEAMATE
	MOVE	A0,*A8(OPLINK),L
	MOVE	A8,*A13(PTEMP2),L
	MMFM	A12,A2,A8
	JRUC	CB_CONTINUE

CELE_1PART
	CLR	A0
	MOVE	A0,*A13(PTEMP2),L		;FLAG FOR NO EXTRA PARTS

CB_CONTINUE
	MOVE	A8,*A13(PTEMP1),L		;KEEP DINO PTR FOR LATER

	SRL	1,A2
	ADDI	COMPSNDTAB,A2
	MOVE	*A2,A0,L
	CALLA	ONESND			;MAKE HIS COMPLETION SOUND

	SOUND1	MUSICOFF

	MOVE	*A8(OID),A4,W
	SLL	28,A4
	SRL	23,A4
	ADDI	PNAME_TAB,A4
	MOVE	*A4,A4,L
	MOVE	A4,@STRING1,L

	MOVI	WIN_MESSAGES,A8			;WIN TEXT TABLE
	MOVI	NUM_WIN_MESSAGES,A0
	CALLA	RANDU				;SELECT A RANDOM MESSAGE
	DEC	A0				;ZERO BASED
	SLL	29,A0
	SRL	24,A0
	ADD	A0,A8
	MOVE	*A8,A8,L
	PUSH	A8
	MOVI	CELEBRATE_MESS,A8
	CALLA	LM_SETUP
	PULL	A8
	JSRP	PRINTF

	MOVI	TEXTOID,A0
	MOVI	JUNKOID,A1
	CALLA	CHANGOID		;LETTERS SHOULD BE NON-DISCERNABLE

	SLEEP	95
	SOUND1	YAMOFF			;TURN THE CURRENT YAMAHA EFFECT OFF

	SLEEP	5

	MOVI	SCRNMID,A10
	MOVI	SCRNMID,A11
	MOVI	20,A0
	JSRP	SCREXP32		;CLOSE THE CURTAIN

	SLEEP	5

	CLR	A0
	MOVI	0A000h,A1
	CALLA	KILALL			;KILL ALL BUT THE INDESTRUCTIBLES

	DISPOFF
	CALLA	DMAQWAIT		;WAIT ON ALL TO FINISH
	CALLA	MYOINIT
	DISPON

       	SOUND1	CHAMPM_SND

	SLEEP	5

GE_SKIP_SHOW
	MOVE	@BIG_WINNER_FLAG,A0,W
	JRNZ	GE_SKIP_HINT
	MOVI	BIG_WINNER_HINT,A8	;GIVE A HINT ON HOW TO DO IT
	JSRP	LM_PRINTF
	SLEEP	240
	MOVIM	1,@GAMERASE,W		;AUTO ERASE ON
	CALLA	CLRTEXT
	SLEEP	5

GE_SKIP_HINT
	CLR	A0
	MOVE	A0,@GAMERASE,W		;TURN OFF AUTO-ERASE
	CALLA	AUTOEOFF

	JSRP	CREDITS_TEXT
	SLEEP	500
	CALLA	CLRTEXT
	CLR	A1
	CALLA	KILBOBJ
	CALLA	CLRBGND	

	MOVK	1,A0
	MOVE	A0,@GAMERASE,W		;AUTO ERASE ON
	SLEEP	3
	CLR	A0
	MOVE	A0,@GAMERASE,W		;TURN OFF AUTO-ERASE
	CALLA	AUTOEOFF
	MOVE	A0,@IRQSKYE,W		;MAKE SURE WE ARE ZERO

	MOVI	INGAMEOV,A0
	MOVE	A0,@GAME_STATE,W

	RETP

BIG_WINNER_HINT
	MESS_MAC RD15FONT,2,197,30+SKYTOPOF,TROG_PRGB,STRCNRMO,0
	.STRING	"WANT THE\d\n"
	.STRING	"\bULTIMATE\nHIGH SCORE?\d\n\n\n"
	.STRING	"\bUSE ONLY 1 CREDIT TO FINISH!",0
	.LONG	RD20FONT
	.WORD	TROG_LF
	.LONG	RD15FONT
	.WORD	TROG_BPR

**************************************************************************
*								         *
* GE_BONUS - ROUTINE TO GIVE THE PLAYERS FINAL BONUS FOR COMPLETING	 *
* 		THE GAME.						 *
* A11 = PTR TO THE PLAYER.						 *
*								         *
**************************************************************************
GE_BONUS
	MOVE	*A11(PWAVES),A1,W
	JRZ	GE_BONUS_X
	DEC	A1
	JRZ	GE_BONUS_X
	MOVE	A1,@BONUSTEMP1,W
	CMPI	1,A1
	JRHI	GE_B1
     	MOVI	SUFFIX_NULL,A0
	JRUC	GE_B2
GE_B1
	MOVI	SUFFIX_S,A0
GE_B2
	MOVE	A0,@STRING2,L
	MOVE	*A11(PSTARTS),A2,W
	CMPI	1,A2
	JRHI	GE_B3	
	MOVI	SUFFIX_NULL,A0
	JRUC	GE_B4
GE_B3
	MOVI	SUFFIX_S,A0
GE_B4
	MOVE	A0,@STRING3,L

	MOVE	A2,@BONUSTEMP1+16,W
	SUB	A2,A1
****	JRLE	GE_BONUS_X
	JRGT	GE_WAVES_OK
	MOVK	1,A1				;DEFAULT TO ONE WAVE
GE_WAVES_OK
	CMPI	LAST_WAVE-1,A1
	JRNE	GE_CALC_IT

*GIVE SPECIAL SCORE FOR THE ONE CREDIT DUDE
	MOVIM	1,@BIG_WINNER_FLAG,W
	SOUND1	FIRE_SND		;DINO SCREAM
	MOVI	25000000,A1		;BIG 25 MIL FOR FINISHING #1
	JRUC	GE_STUFF_IT

GE_CALC_IT
	MOVI	1000000/(LAST_WAVE-1),A0
	MPYU	A0,A1
GE_STUFF_IT
	MOVE	A1,@BONUSTEMP2,L
	MOVE	A11,A2
	CALLA	GPLAYNUM
	SLL	5,A0
	ADDI	PNAME15_TAB,A0
	MOVE	*A0,A0,L
	MOVE	A0,@STRING1,L

	MMTM	A12,A8,A9,A10,A11
	MOVI	[95,85],A10		;PUT THAT MARQUEE HERE
	CREATE	INDPID,BORDER_MARQUEE
	CREATE	FWORKSPID,SW_LP
	MOVI	GE_BONUS_TEXT,A8
	JSRP	LM_PRINTF
	MMFM	A12,A8,A9,A10,A11

	MOVE	@BONUSTEMP2,A0,L
	CALLA	BINBCD
	MOVE	A0,A1
	MOVE	A11,A2
	CALLA	SCORE			;FLIP HIM THE BONUS

	SLEEP	120

	JSRP	FIREWORKS_END
	CALLA	CLRTEXT
	MOVI	BORDERPID,A0
	CLR	A1
	NOT	A1
	CALLA	KILALL
	SLEEP	6
	DISPOFF
	CALLA	MYOINIT
	MOVK	1,A0
	MOVE	A0,@GAMERASE,W
	DISPON
GE_BONUS_X
	RETP

JUNGLE_SND
	.WORD	>F2FD,3,>8000,>802F,>100,>8005,>4024,0

GE_BONUS_TEXT:
	MESS_MAC RD15FONT,2,197,65+SKYTOPOF,0,STRCNRMO,0
	.STRING	"%p\d\n\n\f\p\bplayed \b%d\b wave%p\n\f"
	.STRING	"and used \b%d\b credit%p.\b\d\n\fspecial bonus\p\b\n\f%,ld",0
	.LONG	STRING1
	.LONG	RD7FONT
	.LONG	[-4,0]
	.LONG	RED16
	.WORD	DINO_GREY
	.WORD	DINO_WHITE
	.LONG	BONUSTEMP1
	.WORD	DINO_GREY
	.LONG	STRING2
	.LONG	[-4,0]
	.WORD	DINO_WHITE
	.LONG	BONUSTEMP1+16
	.WORD	DINO_GREY
	.LONG	STRING3
	.WORD	DINO_WHITE
	.LONG	RD15FONT
	.LONG	[-9,0]
	.LONG	GAMEFIX
	.WORD	TROG_LF
	.LONG	[-10,0]
	.LONG	BONUSTEMP2

**************************************************************************
*								         *
* FIREWORKS_END - ROUTINE THAT KILLS THE CURRENT FIREWORKS PROCESS	 *
* 		AND WAITS FOR REMAINING SKYROCKETS TO END.		 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
FIREWORKS_END
	MOVI	FWORKSPID,A0
	CLR	A1
	NOT	A1
	CALLA	KILALL			;KILL THE FIREMAN
FE_WAIT
	SLEEP	2
	MOVI	GOODIEPID,A0
	CLR	A1
	NOT	A1
	CALLA	EXISTP
	JRNE	FE_WAIT			;ROCKETS LAST GLEAMING
	RETP

**************************************************************************
*								         *
* GE_HSCHECK - ROUTINE TO START THE PLAYERS HIGH SCORE SHIT		 *
* A2 = PTR TO THE PLAYER DATA AREA					 *
*								         *
**************************************************************************
GE_HSCHECK
	PUSH	A0
	MOVE	*A2(POBJ),A0,L
	JRZ	GEHS_X
	CALLA	HIGHSCORECHECK		;DO A VERY SMALL HIGH SCORE CHECK
GEHS_X
	PULL	A0
	RETS

**************************************************************************
*								         *
* GAME_END_WARP -	WARP EFFECT FOR GAME END			 *
*								         *
**************************************************************************
GAME_END_WARP
	MOVI	GWEN_FLIPIN,A9
	MOVI	WARP_TAB,A10			;RELOAD THE WARP TABLE
	SOUND1	REXUP_SND
GEW_LP
	MOVK	4,A0
	CALLA	RANDU
	DEC	A0
	SLL	5,A0
	ADDI	WARPOBJ_TAB,A0
	MOVE	*A0,A14,L
	CALLA	GPALOBJSTF
	JRZ	GEW_DONE
	MOVE	A0,A8
	MOVI	[124,202],A2
	MOVE	*A10+,A3,L
	JRZ	GEW_DONE
	MOVI	60,A4
	CALLA	SLINEVEL
	MOVE	A1,*A8(OXVEL),L
	MOVE	A2,*A8(OYVEL),L
	MOVI	SPFLP0F30,A1			;ANIMATE IN THE FLIP FRAME
	MOVE	*A8(OFLAGS),A4,W
	CALLA	ANI
	CREATE	INDPID,GEWIMATE
	MOVI	[124,202],A3
	CALLA	OBJ_TO_PNT
	CALLA	INSERT_OBJ
	JRUC	GEW_LP
GEW_DONE:
	SLEEP	50H
	SOUND1	REXTUNE_SND
	DIE

*
*SUB GAME END WARP
*PROCESS
GEWIMATE:
	MOVK	1,A1
	JSRP	FRANIM

	CALLA	PSTOP

	MOVI	SPIKECHEER_1,A9
	MOVI	2C02H,A1
	JSRP	FRANIM

	CALLA	GETANIXY
	SRL	16,A3
	MOVX	A3,A2
	MOVI	[124,202],A3
	MOVK	30,A4
	CALLA	SLINEVEL
	MOVE	A1,*A8(OXVEL),L
	MOVE	A2,*A8(OYVEL),L
	MOVI	GWEN_FLIPOUT,A9
	MOVK	1,A1
	JSRP	FRANIM
	CALLA	DELETE_OBJ
	DIE

**************************************************************************
*								         *
* GE_WORKS - PROCESS TO CREATE THE END OF GAME FIREWORKS.		 *
*								         *
**************************************************************************
GE_WORKS
	MOVK	4,A0
	CALLA	RANDU
	DEC	A0
	CALLA	GPLAYD
	MOVE	A2,A11
	MOVK	26,B0
	MOVI	370,B1
	CALLA	RANGRAND
	MOVE	A0,A10
	MOVI	SKYTOPOF,B0
	MOVI	SKYTOPOF+100,B1
	CALLA	RANGRAND
	SLL	16,A0
	MOVY	A0,A10
	CREATE	GOODIEPID,SKYROCKET1
	CREATE	GOODIEPID,REPORT
	MOVK	2,B0
	MOVK	6,B1
	CALLA	RANGRAND
	SLOOPR	A0,GE_WORKS
	
*
*PROCESS TO MAKE THE SKYROCKET REPORT
REPORT
	SLEEP	 40
	MOVI	500,A0
	CALLA	RANDPER
	JRNC	REPORT_DIE
	SOUND1	TROGSMACK2_SND
REPORT_DIE
	DIE

GE_TEXT1:
	MESS_MAC RD20FONT,3,197,40+SKYTOPOF,0D0D0000H,STRCNRMO,0
	.STRING	"YOU DID IT!",0
	.EVEN

GE_TEXT2
	MESS_MAC RD15FONT,1,197,90+SKYTOPOF,DINO_PWHITE,STRCNRMO,0
****	.STRING	"YOU HAVE JOINED\nTHE RANKS OF\n\p\bTHE TROG ELITE!"
	.STRING	"YOUR DINO HAS MADE IT\n\p\bHOME!"
	.STRING	"\n\n\n\bCONGRATULATIONS!",0
	.LONG	GAMEFIX
	.WORD	TROG_RGB
	.WORD	TROG_LF
	.EVEN

**************************************************************************
*								         *
* 			BONUS WAVE TEXT MESSAGES			 *
*								         *
**************************************************************************
FEAST_INTRO
	MOVI	FEAST_MESS,A8
	MOVK	BONUSW_1,A9
	MOVI	1600,A10
	JRUC	BONUS_INTROS

GEM_INTRO
	MOVI	GEM_MESS,A8
	MOVK	BONUSW_2,A9
	MOVI	960,A10
	JRUC	BONUS_INTROS

BONFIRE_INTRO
	MOVI	BONFIRE_MESS,A8
	MOVK	BONUSW_3,A9
	MOVI	1280,A10
	JRUC	BONUS_INTROS

*
*INTRO FOR BONUS WAVES
*A8 = PTR TO TEXT FOR THIS WAVE
*A9 = BONUS NUMBER
*A10 = BONUS TIME (IN TICKS)
BONUS_INTROS
	PUSHP	A8
	MOVE	A9,@BONUS_WAVE,W
	CALLA	WAVE_ENTERS		;ADJUST TIME FOR MULTI_PLAYERS
****	ADDM	@CURPLYRS,A0,W		;AND GET THE PLAYERS RIGHT NOW
	DEC	A0
	JRN	BI_NAT
	SLL	7,A0	
	SUB	A0,A10
BI_NAT
	MOVE	A10,@BONUS_TIME,W
	MOVI	BONUSW_MESS,A8
	JSRP	LM_PRINTF
	PULLP	A8
	JSRP	LM_PRINTF
	MOVE	@BONUS_TIME,A0,W
	SRL	6,A0
	MOVE	A0,@STRING1,L
	MOVI	BWTIME_MESS,A8
	JSRP	LM_PRINTF
	SLEEP	220
	CALLA	CLRTEXT
	CREATE	INDPID,BONUS_TIMER
	RETP

BONUSW_MESS:
	MESS_MAC RD20FONT,3,197,40+SKYTOPOF,TROG_PLF,STRCNRMOS,0
	.STRING	"BONUS WAVE!",0
	.EVEN

FEAST_MESS
	MESS_MAC RD15FONT,3,197,70+SKYTOPOF,TROG_PRGB,STRCNRMOS,0
	.STRING	"* TROG FEAST *\n\n\n\bALL YOU CAN EAT!",0
	.WORD	TROG_BPR

GEM_MESS
	MESS_MAC RD15FONT,3,197,70+SKYTOPOF,TROG_PRGB,STRCNRMOS,0
	.STRING	"* DIAMOND MINE *\n\n\n\bGRAB THE JEWELS!",0
	.WORD	TROG_BPR

BONFIRE_MESS
	MESS_MAC RD15FONT,3,197,70+SKYTOPOF,TROG_PRGB,STRCNRMOS,0
	.STRING	"* BARBEQUE *\n\n\n\bSMOKE 'EM ALL!",0
	.WORD	TROG_BPR

BWTIME_MESS
	MESS_MAC RD7FONT,3,197,170+SKYTOPOF,TROG_PRGB,STRCNRMOS,0
	.STRING	"(YOU HAVE %d SECONDS)",0
	.LONG	STRING1

TIMEUP_MESS:
	MESS_MAC RD20FONT,3,197,80+SKYTOPOF,TROG_PLF,STRCNRMOS,0
	.STRING	"TIME IS UP!",0
	.EVEN

BONUSW_MESS_TAB
	.LONG	BONUSW1_MESS,BONUSW2_MESS,BONUSW3_MESS

BONUSW1_MESS
	MESS_MAC RD20FONT,3,197,40+SKYTOPOF,TROG_PLF,STRCNRMOS,0
	.STRING	"OUTRAGEOUS MEAL!",0
	.EVEN

BONUSW2_MESS
	MESS_MAC RD20FONT,3,197,40+SKYTOPOF,TROG_PLF,STRCNRMOS,0
	.STRING	"ROCK ME BABY!",0
	.EVEN

BONUSW3_MESS
	MESS_MAC RD20FONT,3,197,40+SKYTOPOF,TROG_PLF,STRCNRMOS,0
	.STRING	"YOU ARE HOT!",0
	.EVEN
	

BONUSSCR_MESS
	MESS_MAC RD15FONT,3,197,100+SKYTOPOF,TROG_PRGB,STRCNRMOS,0
	.STRING	"100,000 FOR EVERYONE.",0
	.WORD	TROG_BPR

BEWIN_ZPOS	EQU	2800H		;BONUS END WINDOW BASE Z POSITION
BEWIN_SIZE	EQU	[100,170]
BEWIN_X		EQU	200
BEWIN_Y		EQU	107+SKYTOPOF
BEWIN_POS	EQU	[BEWIN_Y,BEWIN_X]
BEWINDOW	EQU	PDATA

**************************************************************************
*								         *
* BONUS_TIMER - THIS IS THE TIMER FOR THE BONUS WAVE. IT HANGS		 *
* 		OUT, THEN ENDS THE WAVE.				 *
* GLOBALS								 *
* 	BONUS_TIME							 *
*								         *
**************************************************************************
BONUS_TIMER
	MOVE	@BONUS_TIME,A10,W
	JRZ	BONUS_END
	CALLR	UPDATE_BWTIME
	SLEEP	60
BT_LP
	SLEEP	64
	SUBI	64,A10
	CALLR	UPDATE_BWTIME
	JSRP	BONUS_WAVE_COMP
	JRZ	BONUS_END
BT_DEC
	MOVE	A10,A10
	JRGT	BT_LP
	CLR	A10
BONUS_END
	MOVE	@GAME_STATE,A0,W
	CMPI	INGAMEOV,A0
	JREQ	BE_SKIP_ST
	CMPI	INAMODE,A0
	JREQ	BE_SKIP_ST
	MOVI	INGAME,A0		;WE ARE THE FIRST TO PASS
	MOVE	A0,@GAME_STATE,W
BE_SKIP_ST
	MOVK	1,A0
	MOVE	A0,@WAVE_OVER,W		;FLAG THE WAVE DONE

	CLR	A0
	MOVI	0E000h,A1
	CALLA	KILALL			;KILL EVERYTHING WE CAN

	CALLA	STOPOBJS

	SOUND1	ALLOFF
	SLEEP	4

	MOVE	A10,A10	
	JRZ	BE_TIMEUP

BE_WINNER
	MOVI	BONUSW_MESS_TAB,A0
	CALLR	LOAD_BONUS_WAVE
	MOVE	*A0,A8,L
	JSRP	LM_PRINTF
	SOUND1	HOUSEB_SND2
	MOVI	BONUSSCR_MESS,A8
	JSRP	LM_PRINTF
	SOUNDOFF
	MOVI	100000H,A1
	ALLPLYR	SCORE_IF_ACTIVE			;SCORE TO ALL
	SOUNDON
	SLEEP	90
	MOVI	BWWIN_SND,A0
	MOVK	3,A1
	CALLA	SNDLD
	JSRP	WAIT_WAVE_END
	JRUC	BE_WWE

BE_TIMEUP
	MOVI	TIMEUP_SND,A0
	MOVK	5,A1
	CALLA	SNDLD

	JSRP	WAIT_WAVE_END
	JSRP	BONUS_WAVE_COMP
	JRZ	BE_WINNER

	MOVI	TIMEUP_MESS,A8
	JSRP	LM_PRINTF

BE_WWE
	SLEEP	80

	CALLA	CLRTEXT

	SOUND1	REXSCORE_SND

	MOVK	10,A0			;EXPAND RATE
	MOVI	BEWIN_ZPOS,A1
	SLL	16,A1			;FULL Z POSITION FOR WINDOW OPEN
	MOVI	BEWIN_SIZE,A8
	MOVI	TIPOID,A9		;STUFF THIS I.D.
	MOVI	BEWIN_POS,A10
	JSRP	OWINDOW_OID
	MOVE	A8,*A13(BEWINDOW),L	;STORE THE WINDOW PTR

	MOVI	BONUSW_HEAD_TAB,A0
	CALLR	LOAD_BONUS_WAVE
	MOVE	*A0,A0,L
	MOVE	*A0+,A8,L
	PUSHP	A0
	JSRP	LM_PRINTF
	SLEEP	10
	PULLP	A0
	
	MOVE	*A0,A0,W
	CALLR	TOSS_COUNTS

	SOUND1	BWSCORE_SND

	CALLA	WAVE_PLAYERS
	DEC	A0
	MOVK	20,A1
	MPYU	A0,A1
	ADDI	100,A1
	SLEEPR	A1

	SOUND1	WIN_SND			;MAKE THE WINNER SOUND

	CALLA	CLRTEXT
	CALLA	CLRBTIME

	MOVE	*A13(BEWINDOW),A8,L	;RESTORE THE WINDOW PTR
	MOVK	10,A0
	JSRP	CWINDOW

	MOVK	30,A11
	CREATE	INDPID,WIPE_FROM_MID	;CLEAR THE SCREEN

	SLEEP	35

	CLR	A0	     		;SCREEN SHALL BE BLACK
	MOVE	A0,@IRQSKYE,W

	CALLA	SCORAREA		;REPLOT THE SCORE AREA

	SLEEP	2

	JAUC	WAVE_END

BWSCORE_SND
	.WORD	>F2FD,>1,>800B,0	;SCORE RIFF

BONUSW_HEAD_TAB
	.LONG	BHEAD_1,BHEAD_2,BHEAD_3

BHEAD_1
	.LONG	BHEAD1_MESS
	.WORD	PTROGKILLS
BHEAD_2
	.LONG	BHEAD2_MESS
	.WORD	PEGGS
BHEAD_3
	.LONG	BHEAD3_MESS
	.WORD	PTROGKILLS

BHEAD1_MESS:
	MESS_MAC RD15FONT,1,BEWIN_X,BEWIN_Y-45,TROG_PLF,STRCNRMO,0
	.STRING	"\uTROGS EATEN\v:",0
	.EVEN

BHEAD2_MESS:
	MESS_MAC RD15FONT,1,BEWIN_X,BEWIN_Y-45,TROG_PLF,STRCNRMO,0
	.STRING	"\uGEMS COLLECTED\v:",0
	.EVEN
	
BHEAD3_MESS:
	MESS_MAC RD15FONT,1,BEWIN_X,BEWIN_Y-45,TROG_PLF,STRCNRMO,0
	.STRING	"\uTROGS SMOKED\v:",0
	.EVEN

**************************************************************************
*								         *
* TOSS_COUNTS - TOSS OUT THE COUNTS FOR THIS WAVE			 *
* A0 = PDATA OFFSET TO COUNT						 *
*								         *
**************************************************************************
TOSS_COUNTS
	MOVI	[BEWIN_Y-23,BEWIN_X-63],A9

	MOVE	A0,A2
	CALLA	WAVE_PLAYERS
	SUBI	4,A0
	ABS	A0
	MOVK	5,A1
	MPYU	A0,A1
	SLL	16,A1
	ADDXY	A1,A9
	MOVE	A2,A0

	MOVE	@NPLAYERS,A1,W
	MOVI	P1DATA,A2
TC_LP:
	MOVE	*A2(PWAVEST),A3,W
	JRZ	TC_NXT
	CALLR	BONUSW_COUNT
TC_NXT:
	ADDI	PDSIZE,A2
	DEC	A1
	JRNN	TC_LP
	RETS

**************************************************************************
*								         *
* BONUSW_COUNT - ROUTINE TO OUTPUT THE BONUS WAVE COUNT FOR A PLAYER.	 *
* A0 = COUNT OFFSET IN DATA BLOCK					 *
* A2 = PTR TO PLAYER DATA						 *
* A9 = [Y,X] POSITION TO PLOT STRING					 *
* RETURNS								 *
* A9 = [Y,X] POSITION FOR NEXT STRING					 *
*								         *
**************************************************************************
BONUSW_COUNT
	MMTM	SP,A0,A1,A2
	ADD	A2,A0
	MOVE	*A0,A0,W
	MOVE	A0,@BONUSTEMP2,W
	CALLA	GPLAYNUM
	SLL	5,A0
	ADDI	PNAME15_TAB,A0
	MOVE	*A0,A0,L
	MOVE	A0,@STRING1,L		;STORE THE NAME
	MOVE	*A2(PPALID),A0,L
	MOVE	A0,@BONUSTEMP1,L
	PUSH	A9
	MOVI	BWC_MESS,A8
	CALLA	LM_SETUP
	MOVE	*SP,A9,L		;POSITION WE PUSHED
	JSRP	PRINTF
	MOVI	BEWIN_X-1,A14
	MOVX	A14,A9
	JSRP	PRINTF
	MOVI	BEWIN_X+66,A14
	MOVX	A14,A9
	MOVI	STRRNRMO,A1
	JSRP	PRINTF
	PULL	A9
	ADDI	[18,0],A9
	MMFM	SP,A0,A1,A2
	RETS

BWC_MESS
	MESS_MAC RD15FONT,1,198,3+SKYTOPOF,TROG_PRED,STRLNRMO,0
	.STRING	"%p",0
	.LONG	STRING1
	.STRING	". . . .",0
	.STRING	" %d",0
	.LONG	BONUSTEMP2

	
**************************************************************************
*								         *
* LOAD_BONUS_WAVE - GRAB PROPER 32 BIT TABLE ENTRY BASED ON THE		 *
* 		CURRENT BONUS WAVE.					 *
* A0 = TABLE ADDRESS							 *
* RETURNS								 *
* A0 = TABLE ENTRY							 *
*								         *
**************************************************************************
LOAD_BONUS_WAVE
	PUSH	A1
	MOVE	@BONUS_WAVE,A1,W
      	CMPI	NBONUS_WAVES,A1
	JRLS	LBW
	MOVI	NBONUS_WAVES,A1
LBW
	DEC	A1
	SLL	5,A1
	ADD	A1,A0
	PULL	A1
	RETS

**************************************************************************
*								         *
* BONUS_WAVE_COMP - DETERMINE IF THE BONUS WAVE HAS BEEN COMPLETED.	 *
* RETURNS:								 *
* 	 Z = BONUS WAVE IS COMPLETE					 *
* 	NZ = BONUS WAVE IS NOT COMPLETE					 *
* NOTE: CALL WITH JSRP							 *
*								         *
**************************************************************************
BONUS_WAVE_COMP
	MOVE	@BONUS_WAVE,A0,W
	CMPI	BONUSW_3,A0
	JREQ	BT_CKTROGS
	CMPI	BONUSW_1,A0
	JRNE	BT_BW2
BT_CKTROGS
	MOVI	TROGS,A1
	CALLA	CNTSUPP
	JRUC	BWC_ENDSUPP
BT_BW2
	CMPI	BONUSW_2,A0
	JRNE	BT_BW3
	MOVI	EGGS,A1
	CALLA	CNTSUPP
BWC_ENDSUPP
	JRZ	BWC_SUCC
	JRUC	BWC_FAIL
BT_BW3

BWC_FAIL
	CLR	A0
	INC	A0
	JRUC	BWC_X
BWC_SUCC
	CLR	A0
BWC_X
	RETP

**************************************************************************
*								         *
* UPDATE_BWTIME - UPDATE THE BONUS WAVE TIMER				 *
* A10 = CURRENT TIME							 *
*								         *
**************************************************************************
UPDATE_BWTIME
	MMTM	SP,A0,A1,A5,A6,A8,A9,A10,A11
	CALLR	CLRBTIME
	MOVE	A10,A10			;HAS THE TIMER BOTTOMED OUT
	JRGE	UBW_OK			;BR = NO
      	CLR	A10
UBW_OK
	SRL	6,A10
	MOVE	A10,@STRING1,W
	MOVI	BWTIMER_MESS,A8
	JSRP	LM_PRINTF
	MOVI	TEXTOID,A0
	MOVI	BTIMEOID,A1
	CALLA	CHANGOID		;CHANGE THE OID
	MMFM	SP,A0,A1,A5,A6,A8,A9,A10,A11
	RETS

BWTIMER_MESS:
	MESS_MAC RD15FONT,1,198,3+SKYTOPOF,TROG_PLF,STRCNRMOS,0
	.STRING	"%d",0
	.LONG	STRING1
	.EVEN

TIMEUP_SND:
	.WORD	>F3D0,15,>808D,0		;YOUR TIME IS UP

BWWIN_SND
	.WORD	>F0D0,18,>8049,0		;"OH YEAH"

**************************************************************************
*								         *
* SPARKLE - MAKE A SPARKLE AT A GIVEN POINT				 *
* A9 = OBJECT TO SPARKLE UPON						 *
* A11 = PTR TO PLAYER THAT WE ARE SPARKLING FOR				 *
*								         *
**************************************************************************
SPARKLE:
	MOVI	SPARKLE_INIT,A5
	CALLA	CREATE_OBJ
	JRZ	SPARKLE_DIE

	MOVE	A9,A8
	CALLA	GETANIXY
	SRL	16,A3
	MOVY	A2,A3
	MOVE	*A8(OZVAL),A2,L
	INC	A2
	MOVE	A2,*A0(OZVAL),L
	MOVE	A0,A8
	MOVE	A13,*A8(OPLINK),L
	CALLA	OBJ_TO_PNT
	CALLA	INSERT_OBJ

	MOVE	@EGG_LIST,A2,L
	JRZ	SPARKLE_WHITE

	MOVIM	DINO_INTENSE,*A8(OCONST),W
	MOVE	A11,A2
	CALLA	GPLAYNUM
	SLL	5,A0
	ADDI	SPARKLE_ANIM,A0
	MOVE	*A0,A9,L
	JRUC	SPARKLE_IT

SPARKLE_WHITE
	MOVIM	DINO_WHITE,*A8(OCONST),W
	MOVI	SA_P4,A9

SPARKLE_IT
	MOVK	1,A1
	JSRP	FRANIM
	CLR	A0
	MOVE	A0,*A8(OPLINK),L
	CALLA	DELETE_OBJ
SPARKLE_DIE:
	DIE

SPARKLE_INIT:
	.LONG	DUMCOLL,0
	.WORD	DMACNZ,JUNKOID
	.LONG	SPARK2


SPARKLE_ANIM
	.LONG	SA_P1,SA_P2,SA_P3,SA_P4

SA_P1:
	.LONG	SPARK2
	.WORD	1|NEWPALET|SCRIPT
	.LONG	RED16
	.LONG	SA_P4
SA_P2:
	.LONG	SPARK2
	.WORD	1|NEWPALET|SCRIPT
	.LONG	BLUE16
	.LONG	SA_P4
SA_P3:
	.LONG	SPARK2
	.WORD	1|NEWPALET
	.LONG	YELLOW16
SA_P4:
	.LONG	SPARK2
	.WORD	6
	.LONG	SPARK3
	.WORD	6
	.LONG	SPARK4
	.WORD	6
	.LONG	SPARK3
	.WORD	6
	.LONG	SPARK4
	.WORD	6
	.LONG	SPARK3
	.WORD	6
	.LONG	SPARK4
	.WORD	6
	.LONG	SPARK3
	.WORD	6
	.LONG	SPARK2
	.WORD	6
	.LONG	0



**************************************************************************
*								         *
* 		TABLE OF PLAYER MARQUEE ANIMATIONS			 *
*								         *
**************************************************************************
MARQANIS
	.LONG	P1MARQT,P1MARQL
	.LONG	P2MARQT,P2MARQL
	.LONG	P3MARQT,P3MARQL
	.LONG	P4MARQT,P4MARQL

P1MARQT
	.LONG	BART1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART3
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BART4
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART3
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BART5
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART4
	.WORD	4
	.LONG	BART1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART3
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BART4
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART3
	.WORD	4|NEWPALET|SCRIPT
	.LONG	YELLOW16
	.LONG	P1MARQT

P1MARQL
	.LONG	BARL1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL3
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BARL4
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL3
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BARL5
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL4
	.WORD	4
	.LONG	BARL1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL3
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BARL4
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL3
	.WORD	4|NEWPALET|SCRIPT
	.LONG	YELLOW16
	.LONG	P1MARQL

P2MARQT
	.LONG	BART1
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART3
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BART4
	.WORD	4
	.LONG	BART1
	.WORD	4
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART3
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BART5
	.WORD	4|NEWPALET
	.LONG   PINK16
	.LONG	BART4
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BART1
	.WORD	6
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART3
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BART4
	.WORD	4
	.LONG	BART1
	.WORD	4
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART3
	.WORD	4|NEWPALET|SCRIPT
	.LONG	BLUE16
	.LONG	P2MARQT

P2MARQL
	.LONG	BARL1
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL3
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BARL4
	.WORD	4
	.LONG	BARL1
	.WORD	4
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL3
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BARL5
	.WORD	4|NEWPALET
	.LONG   PINK16
	.LONG	BARL4
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BARL1
	.WORD	6
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL3
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BARL4
	.WORD	4
	.LONG	BARL1
	.WORD	4
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL3
	.WORD	4|NEWPALET|SCRIPT
	.LONG	BLUE16
	.LONG	P2MARQL

P3MARQT
	.LONG	BART1
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART3
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BART4
	.WORD	4
	.LONG	BART1
	.WORD	4
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART3
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BART5
	.WORD	4|NEWPALET
	.LONG	GREEN16
	.LONG	BART4
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BART1
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART3
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BART4
	.WORD	4
	.LONG	BART1
	.WORD	4
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART3
	.WORD	4|NEWPALET|SCRIPT
	.LONG	YELLOW16
	.LONG	P3MARQT

P3MARQL
	.LONG	BARL1
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL3
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BARL4
	.WORD	4
	.LONG	BARL1
	.WORD	4
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL3
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BARL5
	.WORD	4|NEWPALET
	.LONG	GREEN16
	.LONG	BARL4
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BARL1
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL3
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	BARL4
	.WORD	4
	.LONG	BARL1
	.WORD	4
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL3
	.WORD	4|NEWPALET|SCRIPT
	.LONG	YELLOW16
	.LONG	P3MARQL

P4MARQT
	.LONG	BART1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BART3
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BART4
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BART3
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BART5
	.WORD	4
	.LONG	BART4
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BART3
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BART4
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BART1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BART2
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BART3
	.WORD	4|NEWPALET|SCRIPT
	.LONG	PINK16
	.LONG	P4MARQT

P4MARQL
	.LONG	BARL1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BARL3
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BARL4
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BARL3
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BARL5
	.WORD	4
	.LONG	BARL4
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BARL3
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BARL4
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	BARL1
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	BARL2
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	BARL3
	.WORD	4|NEWPALET|SCRIPT
	.LONG	PINK16
	.LONG	P4MARQL

**************************************************************************
*								         *
* 			MISC. GOODIE ANIMATIONS				 *
*								         *
**************************************************************************
PINWEEL_ANI
	.LONG	PINWEEL1
	.WORD	3|NEWPALET
	.LONG	PINK16
	.LONG	PINWEEL2
	.WORD	3|NEWPALET
	.LONG	BLUE16
	.LONG	PINWEEL3
	.WORD	3|NEWPALET
	.LONG	PINK16
	.LONG	PINWEEL4
	.WORD	3|NEWPALET
	.LONG	YELLOW16
	.LONG	PINWEEL5
	.WORD	3|NEWPALET
	.LONG	PINK16
	.LONG	PINWEEL6
	.WORD	3|NEWPALET
	.LONG	RED16
	.LONG	PINWEEL7
	.WORD	3|NEWPALET
	.LONG	PINK16
	.LONG	PINWEEL8
	.WORD	3|NEWPALET|SCRIPT
	.LONG	GREEN16
	.LONG	PINWEEL_ANI

TRANSFORM_ANI
	.LONG	TRANSF1
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	TRANSF2
	.WORD	3
	.LONG	TRANSF3
	.WORD	3
	.LONG	TRANSF4
	.WORD	3|NEWPALET
	.LONG	GREEN16
	.LONG	TRANSF5
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	TRANSF6
	.WORD	3
	.LONG	TRANSF7
	.WORD	3
	.LONG	TRANSF8
	.WORD	3|NEWPALET
	.LONG	YELLOW16
	.LONG	TRANSF9
	.WORD	4|NEWPALET
	.LONG	RED16
	.LONG	TRANSF10
	.WORD	3
	.LONG	TRANSF11
	.WORD	3
	.LONG	TRANSF8
	.WORD	3|NEWPALET
	.LONG	YELLOW16
	.LONG	TRANSF5
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	TRANSF7
	.WORD	3
	.LONG	TRANSF6
	.WORD	3
	.LONG	TRANSF4
	.WORD	3|NEWPALET|SCRIPT
	.LONG	GREEN16
	.LONG	TRANSFORM_ANI

ARROWF_ANI
	.LONG	ARROW1
	.WORD	8|FLIPBITS|NEWPALET|SCRIPT,M_FLIPH
	.LONG	BLUE16
	.LONG	ARROWG_ANI
ARROW_ANI
	.LONG	ARROW1
	.WORD	8|NEWPALET
	.LONG	BLUE16
ARROWG_ANI
	.LONG	ARROW2
	.WORD	6|NEWPALET
	.LONG	PINK16
	.LONG	ARROW3
	.WORD	8|NEWPALET|SCRIPT
	.LONG	YELLOW16
	.LONG	ARROW_ANI

EXCLAF_ANI
	.LONG	EXCLA1
	.WORD	4|FLIPBITS|NEWPALET|SCRIPT,M_FLIPH
	.LONG	YELLOW16
	.LONG	EXCLAG_ANI
EXCLA_ANI
	.LONG	EXCLA1
	.WORD	4|NEWPALET
	.LONG	YELLOW16
EXCLAG_ANI
	.LONG	EXCLA2
	.WORD	6|NEWPALET
	.LONG	RED16
	.LONG	EXCLA3
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	EXCLA4
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	EXCLA3
	.WORD	3|NEWPALET
	.LONG	BLUE16
	.LONG	EXCLA2
	.WORD	4|NEWPALET|SCRIPT
	.LONG	RED16
	.LONG	EXCLA_ANI

YOF_ANI
	.LONG	YO1
	.WORD	4|FLIPBITS|NEWPALET,M_FLIPH
	.LONG	PINK16
YO_ANI
	.LONG	YO1
	.WORD	4|NEWPALET
	.LONG	PINK16
YOG_ANI
	.LONG	YO2
	.WORD	6|NEWPALET
	.LONG	RED16
	.LONG	YO3
	.WORD	4|NEWPALET
	.LONG	BLUE16
	.LONG	YO4
	.WORD	4|NEWPALET
	.LONG	PINK16
	.LONG	YO5
	.WORD	4|NEWPALET|SCRIPT
	.LONG	GREEN16
	.LONG	YO_ANI

WOW_ANI
	.LONG	WOW1
	.WORD	4|NEWPALET
	.LONG	YELLOW16
	.LONG	WOW2
	.WORD	4
	.LONG	WOW3
	.WORD	4
	.LONG	WOW4a
	.WORD	4
	.LONG	WOW4b
	.WORD	3|NEWPALET
	.LONG	BLUE16
	.LONG	WOW4c
	.WORD	3|NEWPALET
	.LONG	PINK16
	.LONG	WOW4b
	.WORD	3|NEWPALET
	.LONG	BLUE16
	.LONG	WOW4d
	.WORD	3|NEWPALET
	.LONG	GREEN16
	.LONG	WOW4b
	.WORD	3|NEWPALET
	.LONG	BLUE16
	.LONG	WOW4d
	.WORD	3|NEWPALET
	.LONG	GREEN16
	.LONG	WOW4c
	.WORD	3|NEWPALET
	.LONG	PINK16
	.LONG	WOW3
	.WORD	3|NEWPALET
	.LONG	YELLOW16
	.LONG	WOW2
	.WORD	3
	.LONG	0

PROCKETS
	.LONG	P1ROCKET,P2ROCKET,P3ROCKET,P4ROCKET

P1ROCKET
	.LONG	ROCKET1
	.WORD	6|NEWPALET|SCRIPT
	.LONG	RED16
	.LONG	PSKYROCKET
P2ROCKET
	.LONG	ROCKET1
	.WORD	6|NEWPALET|SCRIPT
	.LONG	BLUE16
	.LONG	PSKYROCKET
P3ROCKET
	.LONG	ROCKET1
	.WORD	6|NEWPALET|SCRIPT
	.LONG	YELLOW16
	.LONG	PSKYROCKET
P4ROCKET
	.LONG	ROCKET1
	.WORD	6|NEWPALET
	.LONG	PINK16
PSKYROCKET
	.LONG	ROCKET2
	.WORD	6|DELTAXZ,0FF00H
	.LONG	ROCKET3
	.WORD	6
	.LONG	ROCKET4
	.WORD	4
	.LONG	ROCKET5
	.WORD	4
	.LONG	ROCKET6
	.WORD	4
	.LONG	ROCKET7
	.WORD	4
	.LONG	FIREWERK1
	.WORD	6|DELTAXZ,100H
	.LONG	FIREWERK2
	.WORD	6
	.LONG	FIREWERK3
	.WORD	7
	.LONG	FIREWERK4
	.WORD	10
	.LONG	0

PFIREWERKS
	.LONG	P1FIREW,P2FIREW,P3FIREW,P4FIREW

P1FIREW
	.LONG	FIREWERK1
	.WORD	6|NEWPALET|SCRIPT
	.LONG	RED16
	.LONG	PFIREW
P2FIREW
	.LONG	FIREWERK1
	.WORD	6|NEWPALET|SCRIPT
	.LONG	BLUE16
	.LONG	PFIREW
P3FIREW
	.LONG	FIREWERK1
	.WORD	6|NEWPALET|SCRIPT
	.LONG	YELLOW16
	.LONG	PFIREW
P4FIREW
	.LONG	FIREWERK1
	.WORD	6|NEWPALET
	.LONG	PINK16
PFIREW
	.LONG	FIREWERK2
	.WORD	6
	.LONG	FIREWERK3
	.WORD	7
	.LONG	FIREWERK4
	.WORD	10
	.LONG	0

*ZOOMER COMMENTED OUT 3/14/90 BY GNP
	.IF	0		
**************************************************************************
*                                                                        *
* ZOOMUP - ZOOM CONTENTS OF OBJLST FROM GIVEN ZOOM TO A GREATER ZOOM	 *
* A8 = INITIAL ZOOM FACTOR, MUST BE LESS THAN VALUE IN A9		 *
* A9 = FINAL ZOOM FACTOR				  		 *	
* A10 = ZOOM INCREASE/STEP						 *
* NOTE: CALL WITH JSRP							 *
*                                                                        *
**************************************************************************
ZOOMUP
	MMTM	A12,A8,A11
	MOVE	@PAGE,A0,W
	XORI	1,A0
	MOVE	A0,@PAGE,W	;PLOT ZOOM ON THE NEXT PAGE
	CLR	A0
	CALLR	ZOOMLP		;PLOT THE INITIAL ZOOM		
	CALLA	TURNPAGE
	SLEEP	1
ZOOMUPLP:
	MOVE	A8,A11
	ADD	A10,A8
	CMP	A9,A8
	JRLS	ZOOMUPOK
	MOVE	A9,A8
ZOOMUPOK
	MOVE	@PAGE,A0,W
	XORI	1,A0
	MOVE	A0,@PAGE,W	;PLOT NEXT ZOOM ON THE NEXT PAGE
	CLR	A0
	CALLR	ZOOMLP		;PLOT THE NEW ZOOM
	CALLA	TURNPAGE	;NOW VIEW IT
	SLEEP	1
	MOVE	@PAGE,A0,W
	XORI	1,A0
	MOVE	A0,@PAGE,W	;ERASE PREVIOUS ZOOM
	SWAP	A8,A11		;NEED OLD ZOOM FACTOR
	MOVK	1,A0
	CALLR	ZOOMLP		;USE THE ERASER BOY
	MOVE	@PAGE,A0,W
	XORI	1,A0
	MOVE	A0,@PAGE,W	;CORRECT THE PAGE #
	MOVE	A11,A8
	CMP	A9,A8
	JREQ	ZOOMUPX	
	SLOOP	1,ZOOMUPLP
ZOOMUPX
	SLEEP	1
	MMFM	A12,A8,A11
	RETP

**************************************************************************
*                                                                        *
* ZOOMDN - ZOOM CONTENTS OF OBJLST FROM GIVEN ZOOM TO A LESSER ZOOM	 *
* A8 = INITIAL ZOOM FACTOR, MUST BE GREATER THAN VALUE IN A9		 *
* A9 = FINAL ZOOM FACTOR				  		 *	
* A10 = ZOOM DECREASE/STEP						 *
* NOTE: CALL WITH JSRP							 *
*                                                                        *
**************************************************************************
ZOOMDN
	MMTM	A12,A8,A11
	MOVE	@PAGE,A0,W
	XORI	1,A0
	MOVE	A0,@PAGE,W	;PLOT ZOOM ON THE NEXT PAGE
	CLR	A0
	CALLR	ZOOMLP		;PLOT THE INITIAL ZOOM		
	CALLA	TURNPAGE
	SLEEP	1
ZOOMDNLP:
	MOVE	A8,A11
	ADD	A10,A8
	CMP	A9,A8
	JRHS	ZOOMDNOK
	MOVE	A9,A8
ZOOMDNOK
	MOVE	@PAGE,A0,W
	XORI	1,A0
	MOVE	A0,@PAGE,W	;PLOT NEXT ZOOM ON THE NEXT PAGE
	CLR	A0
	CALLR	ZOOMLP		;PLOT THE NEW ZOOM
	CALLA	TURNPAGE	;NOW VIEW IT
	SLEEP	1
	MOVE	@PAGE,A0,W
	XORI	1,A0
	MOVE	A0,@PAGE,W	;ERASE PREVIOUS ZOOM
	SWAP	A8,A11		;NEED OLD ZOOM FACTOR
	MOVK	1,A0
	CALLR	ZOOMLP		;USE THE ERASER BOY
	MOVE	@PAGE,A0,W
	XORI	1,A0
	MOVE	A0,@PAGE,W	;CORRECT THE PAGE #
	MOVE	A11,A8
	CMP	A9,A8
	JREQ	ZOOMDNX	
	SLOOP	1,ZOOMDNLP
ZOOMDNX
	SLEEP	1
	MMFM	A12,A8,A11
	RETP

**************************************************************************
*                                                                        *
* ZOOMLP - ZOOMZ THE SCREEN TO THE DESIRED RATIO			 *
* A0 = FLAGS PASSED TO ZOOM						 *
* A8 = ZOOM FACTOR [INT,FRAC]						 *							 *
*                                                                        *
**************************************************************************
ZOOMLP:
	MMTM	SP,A10,A11
	MOVI	1,A10
	CLR	A11
	DIVU	A8,A10		;A10 CONTAINS ZOOM DIVIDER

	MOVI	SCRNST,A6
	MOVI	SCRNEND,A7
	MOVE	A7,A1
	SUBXY	A6,A1
	SRL	1,A1		;SCRNSIZ DIVIDED BY 2
	ANDI	>FFFF7FFF,A1
	ADDXY	A1,A6		;GET CENTER SCREEN
	MOVX	A1,A3		;GET X SCREEN SIZE
	ZEXT	A3
	MPYU	A10,A3		;MULT BY ZOOMDIV
	SRL	16,A3

	MOVY	A1,A5		;GET Y SCREEN SIZE
	SRL	16,A5
	MPYU	A10,A5
	MOVX	A3,A5		;HALF SIZE Y:X
	MOVE	A5,A4
	ADDXY	A6,A5		;NEW SCRNLR
	SUBXY	A4,A6		;NEW SCRNTL
	MOVE	A5,@SCRNLR,L
	MOVE	A6,@SCRNTL,L

	MMTM SP,A8,A9,A12,A13
	CALLA	ZOOM
	MMFM SP,A8,A9,A12,A13
	MMFM	SP,A10,A11
	RETS

	.TITLE	'ZOOM DISPLAY PROCESSOR VER. 1.00'
*
*	GLOBAL VARIABLES
*
	.BSS	ZOOMULT,32		;ZOOM MULTIPLIER 16.16
	.BSS	ZOOMDIV,32		;ZOOM DIVISOR	 16.16
	.BSS	ZOOMFLG,16		;ZOOM FLAGS
*
*A0 = ZOOM FLAGS
ZOOM:
	MOVE	A10,@ZOOMDIV,L
	MOVE	A8,@ZOOMULT,L
	MOVE	A0,@ZOOMFLG,W

*VELOCITY UPDATE
	MOVI	OXVEL,A1
	MOVI	OBJLST,A0
	CALLR	DVELP	

*CLIP AND LOAD DMA 
*A4=BOTTOM DMA Q TO LOAD
*A5=TOP DMA Q TO LOAD
*B1=HALF SCREEN ADDRESS
*B2=BOTTOM Q COUNT
*B3=TOP Q COUNT
*B4=WORLD TOP LEFT [Y,X]

DCLIP:
	MOVE	@SCROLLX,A6,L	; get Y:X scroll values
	MOVE	@SCROLLY,A7,L
	SRA	1,A6
	SRA	1,A7		;SCROLL 1/2 AS FAST
	MOVE	@BAK2TLY,A14,L	;BACKGRD 2 SCREEN TL Y INTEGER:FRACTION
	MOVE	@BAK2TLX,A13,L	;BACKGRD 2 SCREEN TL X INTEGER:FRACTION
	ADD	A7,A14
	MOVE	A14,@BAK2TLY,L
	ADD	A6,A13
	MOVE	A13,@BAK2TLX,L
	SRL	16,A13
	MOVX	A13,A14		;COMBINE TO FORM TOP LEFT Y:X		
	MOVE	A14,B4		;SETUP WORLD TOP LEFT [Y,X]
	MOVE	@SCRNTL,A14,L	;GET SCREEN BOUNDARIES
	MOVE	@SCRNLR,A13,L


	MOVI	BAK2LST,A0,L
	CALLR	NODIS

	MOVE	@SCROLLX,A6,L	; get Y:X scroll values
	MOVE	@SCROLLY,A7,L
	MOVE	@WORLDTLY,A14,L	;SCROLL YOUR SCREEN FOLKS
	MOVE	@WORLDTLX,A13,L
	ADD	A6,A13
	ADD	A7,A14
	MOVE	A14,@WORLDTLY,L
	MOVE	A13,@WORLDTLX,L
	SRL	16,A13
	MOVX	A13,A14		;COMBINE TO FORM TOP LEFT Y:X		

	MOVE	A14,B4		;SETUP WORLD TOP LEFT [Y,X]
	MOVE	B4,@WORLDTL,L	;STORE THE WORLD TOP LEFT [Y,X]
	MOVE	@SCRNTL,A14,L	;GET SCREEN BOUNDARIES
	MOVE	@SCRNLR,A13,L
	
	MOVI	BAKLST,A0,L
	CALLR	NODIS

	MOVI	OBJLST,A0,L
	CALLR	NODIS
DISPX:
	RETS
*
*VELOCITY ADD LOOP
*
DVEL_ZOOM:
	MOVE	*A0(OFLAGS),A3,W	;CHECK FOR NO VELOCITY BLOCKS
	BTST	B_NOMOV,A3		
	JRNE    DVELP			;NO VELOCITY, SKIP IT
DVEL1:
	MOVE	A0,A3
	ADD	A1,A3  			;ADD IN OXVEL
	MMFM	A3,A7,A8,A9,A10,A11,A12

*A12:OXVEL, A11:0YVEL, A10:OXPOS, A9:OYPOS, A8: OZPOS  A7:OZVEL
	ADD	A12,A10		;ADD X VELOCITY TO XVAL
	ADD	A11,A9		;ADD Y VELOCITY TO YVAL
	ADD	A7,A8		;ADD Z VELOCITY TO ZVAL
	SUBK	20H,A3
	MMTM	A3,A8,A9,A10
DVELP:
	move  	*a0,A0,L     	;GET NEXT ONE FOLKS
	JRNE  	DVEL_ZOOM
	RETS

DCLIPL:
	move   	*a0(OXPOS),a10		;
	move	*a0(OYPOS),a2		;
	sll	16,a2
	movy	a2,a10			; Y:X in a10	
	MOVE	A10,*A0(ODMAXY),L	;UPDATED XY POSITION
	MOVE	B4,A6			;SUBTRACT WORLD COORD TO GET SCREEN COORD.
	SUBXY	A6,A10
	MOVE	A0,A3
	ADDI	OFLAGS,A3		;GET PARAMETER LOCATION
	MMFM	A3,A12,A11,A9,A8

*	Check for flipping, necessity of clipping, adjust offset, SAG
*	a0 is the address of the object block
* 	a1 becomes OFFSET
*	A2=AMOUNT TO CLIP OFF BOTTOM, RIGHT	(BC,RC)
* 	A3=AMOUNT TO CLIP OFF TOP, LEFT	(TC,LC)
*	a6=SCREEN TOP LEFT (SCREEN COORDINATES); THEN TOTAL HORIZ. SIZE
*
*	a8 is CONST:PALETTE
*	a9 becomes VS : HS
*	a10 is DAG (Y : X)
*	a11 is the SAG
*	a12 is the control word b0-15; offset b16-31
*	a13 is the window BOTTOM RT
*	a14 is the window TOP LEFT
*
*  COMPUTE LC, RC, TC, BC	
*
	clr	a6		; UPPER LEFT SCREEN COORDINATES
	clr	a1     		; use for clearing now, becomes offset later
	move	a10,a2 		; PT in a2
	addxy	a9,a2 		; lower right in a2
	subxy	a13,a2		; PT - WEND -> a2  ( BC : RC )
	JRYGE	dis_clp0
	movy    a1,a2  		; clear BC if y negative
dis_clp0:	
	JRXGE	dis_clp1
	movx   	a1,a2  		; clear RC if x negative	
dis_clp1:
	move   	a14,a7 		; move WSTART
	clr    	a3				;
	subxy	a10,a7	    	; WSTART - PT -> a7 (TC : LC)
	JRYLT  	dis_clp2
	movy   	a7,a3	    	; TC in upper half of a3
	movy   	A14,a10	    	; adjust start position to window edge
dis_clp2:
	JRXLT  	dis_clp3
	movx   	a7,a3	    	; LC in lower half of a3
	movx   	A14,a10	    	; adjust start position to window edge
dis_clp3:
	movx	a9,a6		;GET TOTAL HORIZONTAL SIZE (MORSEL CORRECTED)
	MOVE	*A0(OXCLIP),A7
	ADD	A7,A6		;ADD PRECLIP TO THE WIDTH TO CALC NEW SAG
	add	a3,a2	    	; (TC+BC : LC+RC) in a2
	JREQ	NOCLIP		; TOTAL CLIP IS ZERO, NOCLIP
	SUBXY	A2,A9	    	; GET CLIPPED SIZE...TOTALLY CLIPPED?
	JRXLE	NODIS	 	; yes, don't display it
	JRYLE	NODIS		

*
*CLIP THE SAG, HS, VS, AND ADJUST OFFSET
*	
	MOVX	A3,A1		;GET LEFT CLIP
	SRL	16,A3		;GET TOP CLIP
	JREQ	CLIP1
	MPYS	A6,A3		;TOP CLIP X TOTAL HORIZ SIZE
CLIP1:
	SLL	16,A2
	BTST	B_FLIPH,A12
	JREQ	CLIP2
	NEG	A2		;NEGATE RC+LC
	NEG	A1		;NEGATE LC
CLIP2:
	BTST	B_FLIPV,A12
	JREQ	CLIP3
	NEG	A3		;NEGATE	THS*TC
CLIP3:
	ADD	A1,A3		;ADD LEFT CLIP TERM +  TC*THS
	SLL	3,A3
	ADD	A3,A11		;ADD TO SAG
	ADD	A2,A12		;ADD CLIP OFFSET TO OFFSET
NOCLIP:
	CALLR	IMZOOM
NODIS:
	MOVE	*A0,A0,L	;GET NEXT LINK
	JRNE	DCLIPL		;DONE?
	RETS
*
*A6 = TOTAL WIDTH OF SOURCE DATA
*A8 = CONST:PALETTE 
*A9 = VSIZE:HSIZE
*A10 = DESTINATION Y:X
*A11 = IMAGE SAG
*A12 = OFFSET:CONTROL
*A13 = SCRNLR
*A14 = SCRNTL
*
*IMAGE SAMPLE ROUTINE
********
***INPUT PARAMETERS
********
*A0=UPPER LEFT CORNER SCREEN DESTINATION ADDRESS 
*A1=H,W	OF IMAGE
*A2=SOURCE IMAGE ADDRESS (LINEAR STORAGE X FIRST)
*A3=X INCREMENT	 16.16
*A4=Y INCREMENT	 16.16
*********
***VARIABLES
*********
*A5=HEIGHT MAX 16.16 PIXELS
*A6=WIDTH MAX 16.16 PIXELS
*A7=SOURCE ADDRESS TEMP
*A8=SOURCE ADDRESS TEMP
*A9=SOURCE ADDRESS START OF CURRENT LINE
*A10=X SAMPLE COUNTER
*A11=Y SAMPLE COUNTER
*A12=DESTINATION SCREEN PIXEL ADDRESS
*A13=OFFSET/FLAGS
*A14=ACTUAL SAG WIDTH (WIDTH+CLIP)
IMZOOM:
	MMTM	SP,A0,A13,A14
	MOVE	A8,@DMACMAP,W
	SUBXY	A14,A10		;SUBTRACT SCREEN UPPER LEFT
	MOVE	A6,A14		;THIS IS TOTAL WIDTH
	MOVY	A10,A3		;CALCULATE Y ZOOM DEST ADDR
	SRL	16,A3
	MOVE	@ZOOMULT,A0,L
	MPYU	A0,A3
	ADDI	SCRNST,A3
	SRL	16,A3		;CLEAR AND ALIGN FOR LINEAR BYTE ADDRESSING
	SLL	12,A3

	MOVX	A10,A1		;CALC X ZOOM DEST ADDR
	ZEXT	A1,W
	MPYU	A0,A1
	SRL	16,A1		;FORM DEST Y:X
	SLL	3,A1		;ADJUST FOR BYTE
	ADD	A3,A1		;COMBINE X,Y DAG
	
	MOVE	A12,A13		;FLAGS
	MOVE	A1,A0		;DESTINATION ADDRESS 
	MOVE	A11,A2		;SAG
	MOVE	A9,A1		;H,W
	MOVE	@ZOOMDIV,A3,L	;LOAD UP X,Y INCREMENTS
	MOVE	A3,A4
	
	CLR	A5
	MOVY	A1,A5	;GET OBJECT HEIGHT
	MOVX	A1,A6	;GET OBJECT WIDTH
	SLL	16,A6	;NORMALIZE 16.16
	CLR	A10	;X COUNTER
	CLR	A11	;Y COUNTER
	MOVE	A2,A9	;SOURCE ADDRESS FOR CURRENT LINE
	MOVE	A0,A12	;DESTINATION ADDRESS CURRENT PIXEL
	MOVE	@PAGE,A7,W
	JRZ	IMZOOMP0
	MOVI	PAGE1XY,A7
	SRL	16,A7	
	SLL	12,A7	
	ADD	A7,A12		;PLOT ON PAGE 1
	MOVE	A12,A0	;KEEP A0 UP TO DATE
IMZOOMP0

*OUTPUT A PIXEL
*CALC SOURCE PIXEL ADDRESS
	MOVE	A8,A1
	SRL	16,A1
	
	MOVE	@ZOOMFLG,A7
	BTST	0,A7
	JRNE	BLACKOUT	;BLACK OUT EVERYTHING THIS TIME

IMSLP:
	BTST	B_CONNON,A13
	JREQ	IMSLP0A	
IMSLPA0:	
	MOVE	A10,A7
	SRL	16,A7	;X COUNT
	SLL	3,A7	;TRUNCATE BYTE FRACTIONS
	ADD	A9,A7	;ADD IN X
	MOVB	*A7,A8	;CHECK PIXEL
	JREQ	IMSLPA01	;DON'T OUTPUT ZERO
	MOVB	A1,*A12 	;TRANSFER DATA

*MOVE TO NEXT HORIZONTAL (X) SAMPLE
IMSLPA01:
	ADDK	8,A12		;NEXT PIXEL IN HORIZONTAL DESTINATION
	ADD	A3,A10		;ADD IN X INCREMENT
	CMP	A6,A10		;CHECK IF FINISHED WITH ROW
	JRLO	IMSLPA0		;NOT DONE WITH ROW
	JRUC	IMVERT

IMSLP0A
	BTST	B_WRZERO,A13 	;WRITE ZEROES?
	JRNE	IMSLP1		;YES...

IMSLP0:	
	MOVE	A10,A7
	SRL	16,A7	;X COUNT
	SLL	3,A7	;TRUNCATE BYTE FRACTIONS
	ADD	A9,A7	;ADD IN X
	MOVB	*A7,A8
	JREQ	IMSLP01		;DON'T OUTPUT ZERO
	MOVB	A8,*A12 	;TRANSFER DATA

*MOVE TO NEXT HORIZONTAL (X) SAMPLE
IMSLP01:
	ADDK	8,A12		;NEXT PIXEL IN HORIZONTAL DESTINATION
	ADD	A3,A10		;ADD IN X INCREMENT
	CMP	A6,A10		;CHECK IF FINISHED WITH ROW
	JRLO	IMSLP0		;NOT DONE WITH ROW
	JRUC	IMVERT

IMSLP1:
	MOVE	A10,A7
	SRL	16,A7	;X COUNT
	SLL	3,A7	;TRUNCATE BYTE FRACTIONS
	ADD	A9,A7	;ADD IN X
	MOVB	*A7,*A12 	;TRANSFER DATA

*MOVE TO NEXT HORIZONTAL (X) SAMPLE
	ADDK	8,A12		;NEXT PIXEL IN HORIZONTAL DESTINATION
	ADD	A3,A10		;ADD IN X INCREMENT
	CMP	A6,A10		;CHECK IF FINISHED WITH ROW
	JRLO	IMSLP1		;NOT DONE WITH ROW

*MOVE TO NEXT VERTICAL (Y) SAMPLE LINE
IMVERT:
	ADDI	512*8,A0
	MOVE	A0,A12		;MOVE TO NEXT DESTINATION HORIZONTAL LINE
	ADD	A4,A11		;ADD IN Y INCREMENT
	MOVE	A11,A8
	SRL	16,A8		;Y COUNT
	SLL	3,A8
	MOVE	A14,A9		;WIDTH
	MPYU	A8,A9		;CALC ADDRESS OFFSET INTO OBJECT FOR CURRENT LINE
	ADD	A2,A9		;ADD IN STARTING ADDRESS
	CLR	A10		;RESET ROW COUNT
	CMP	A5,A11		;DONE WITH Y?
	JRLO	IMSLP
	MMFM	SP,A0,A13,A14
	RETS
	
*
*NO SAMPLE JUST DRAW BLACK IN PLACE OF DATA
BLACKOUT:
	CLR	A8
	MOVE	A8,@DMACMAP,W	;JSUT USE THE FIRST PALETTE TO ZERO WITH
BIMSLP:
	BTST	B_CONNON,A13
	JREQ	BIMSLP0A	
BIMSLPA0:	
	MOVE	A10,A7
	SRL	16,A7	;X COUNT
	SLL	3,A7	;TRUNCATE BYTE FRACTIONS
	ADD	A9,A7	;ADD IN X
	MOVB	*A7,A8	;CHECK PIXEL
	JREQ	BIMSLPA01	;DON'T OUTPUT ZERO
	CLR	A1
****	MOVI	ERASECOL,A1
	MOVB	A1,*A12 	;TRANSFER DATA

*MOVE TO NEXT HORIZONTAL (X) SAMPLE
BIMSLPA01:
	ADDK	8,A12		;NEXT PIXEL IN HORIZONTAL DESTINATION
	ADD	A3,A10		;ADD IN X INCREMENT
	CMP	A6,A10		;CHECK IF FINISHED WITH ROW
	JRLO	BIMSLPA0		;NOT DONE WITH ROW
	JRUC	BIMVERT

BIMSLP0A
	BTST	B_WRZERO,A13 	;WRITE ZEROES?
	JRNE	BIMSLP1		;YES...

BIMSLP0:	
	MOVE	A10,A7
	SRL	16,A7	;X COUNT
	SLL	3,A7	;TRUNCATE BYTE FRACTIONS
	ADD	A9,A7	;ADD IN X
	MOVB	*A7,A8
	JREQ	BIMSLP01		;DON'T OUTPUT ZERO
	CLR	A8
****	MOVI	ERASECOL,A8
	MOVB	A8,*A12 	;TRANSFER DATA

*MOVE TO NEXT HORIZONTAL (X) SAMPLE
BIMSLP01:
	ADDK	8,A12		;NEXT PIXEL IN HORIZONTAL DESTINATION
	ADD	A3,A10		;ADD IN X INCREMENT
	CMP	A6,A10		;CHECK IF FINISHED WITH ROW
	JRLO	BIMSLP0		;NOT DONE WITH ROW
	JRUC	BIMVERT

BIMSLP1:
	MOVE	A10,A7
	SRL	16,A7	;X COUNT
	SLL	3,A7	;TRUNCATE BYTE FRACTIONS
	ADD	A9,A7	;ADD IN X
**	MOVB	*A7,*A12 	;TRANSFER DATA
	CLR	A8
****	MOVI	ERASECOL,A8
	MOVB	A8,*A12

*MOVE TO NEXT HORIZONTAL (X) SAMPLE
	ADDK	8,A12		;NEXT PIXEL IN HORIZONTAL DESTINATION
	ADD	A3,A10		;ADD IN X INCREMENT
	CMP	A6,A10		;CHECK IF FINISHED WITH ROW
	JRLO	BIMSLP1		;NOT DONE WITH ROW

*MOVE TO NEXT VERTICAL (Y) SAMPLE LINE
BIMVERT:
	ADDI	512*8,A0
	MOVE	A0,A12		;MOVE TO NEXT DESTINATION HORIZONTAL LINE
	ADD	A4,A11		;ADD IN Y INCREMENT
	MOVE	A11,A8
	SRL	16,A8		;Y COUNT
	SLL	3,A8
	MOVE	A14,A9		;WIDTH
	MPYU	A8,A9		;CALC ADDRESS OFFSET INTO OBJECT FOR CURRENT LINE
	ADD	A2,A9		;ADD IN STARTING ADDRESS
	CLR	A10		;RESET ROW COUNT
	CMP	A5,A11		;DONE WITH Y?
	JRLO	BIMSLP
	MMFM	SP,A0,A13,A14
	RETS
	.ENDIF

	.END
