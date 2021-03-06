**************************************************************************
*                                                                        *
* 	THE Z-UNIT SYSTEM SPECIFIC EQUATES 				 *
*                                                                        *
**************************************************************************

****DEBUG	EQU	1	;THIS VERSION IS CURRENTLY UNDER CONSTRUCTION
DEBUG	EQU	0	;ADD THIS BEFORE RELEASE!!!!!
YUNIT	EQU	1	;IF 1, THIS VERSION IS FOR THE Y-UNIT AT 4 BITS/PIXEL

PRINTER	EQU	0	; IF 1, THERE IS A PRINTER HOOKED TO SOUND PORT

FORCEFREE	EQU	0	; 1 = GAME HARDWIRED FREE
FULLPRICE	EQU	0	; 1 = ALL THE PRICINGS ARE INCLUDED

NTSC	EQU	0	;IF 1, THEN SET THE GAME INTO NTSC COMPATIBLE MODE

WDOGNUM	.SET	01A2B3C4DH	;"SYSTEM INITIALIZED" MARKER

*
*PIXBLT STUFF
PXSIZE    .set		8
SCRN_PTCH .set		512*PXSIZE
STACK_ST  .set		0FFFC0000h
OFFSETVAL .set		0
PLANEMSK  .set		0
INI_CTRL  .set		28H

*
*SYSTEM Z MEMORY MAP
*
SCRATCH	.SET	01000000h	;START OF SCRATCH
STCKST	.SET	010FFFF0h	;TOP OF STACK
CMOS	.EQU	01400000H	;START OF CMOS RAM
SCREEN	.SET	00h		;START OF SCREEN MEMORY
SCRNE	.SET	0200000h	;END OF SCREEN+1

	.IF	YUNIT
COLRAM	.SET	0181F000h	;COLOR RAM B0-B4 BLU, B5-B9 GRN, B10-B14 RED
PALSIZE .SET	0100H		;PHYSICAL SIZE OF A PALETTE IN COLOR RAM
PCYCLEPAL EQU	5050H
	.ELSE
COLRAM	.SET	01800000h	;COLOR RAM B0-B4 BLU, B5-B9 GRN, B10-B14 RED
PALSIZE .SET	01000H		;PHYSICAL SIZE OF A PALETTE IN COLOR RAM
PCYCLEPAL EQU	0505H
	.ENDIF

CYCOLORS EQU	COLRAM		;CYCLABLE COLORS
COLROFFST EQU	0B0H  		;OFFSET TO START COLORS
COLRCNT	EQU	4	     	;CURRENT NUMBER OF CYCLEABLE COLORS

PCYCOLORS EQU	COLRAM+(5*PALSIZE)	;PLAYER COLOR CYCLE PALETTE 
PCOLROFFST EQU	0C0H			;OFFSET COLOR IN THAT PALETTE
PCOLRCNT EQU	4			;NUMBER OF PLAYER CYCLES

ROM	.SET	0FFC00000h	;PROGRAM ROM
IROM	.SET	02000000h	;IMAGE ROM
CMAPSEL	.SET	01A80080h	;COLOR MAP SELECT (0-15)
SWITCH	.SET	01C00000h	;I/O (JAMMA CONNECTOR AND WIRED INPUTS)
SWITCH2	.SET	01C00020H	;I/O (WIRED INPUTS AND DIP SWITCHES) 
COINS	.SET	01C00010H
DIPSWITCH	EQU	01C00030H	; DIP SWITCHES FOR Y UNIT
SECCHIP	EQU	01C00060H	; LOCATION OF SECURITY CHIP
SOUND	.SET	01E00000h	;SOUND I/O (B0-B7 = SOUND#)
				;	    B8 =  MUSIC STROBE (0 EN)
				;	    B9 =  SOUND STROBE (0 EN)
				;	    B10 = RESET (0 EN)
SYSCTRL	.SET	01F00000H	;SYSTEM CONTROL LATCH
				;BIT 0 - FG SCROLL 0
				;BIT 1 - FG SCROLL 1
				;BIT 2 - ALWAYS 1
				;BIT 3 - ALWAYS 1
				;BIT 4 - AUTO-ERASE ENABLE(0)
				;BIT 5 - OBJECT PALETTE ENABLE(0)
				;BIT 6 - ALWAYS 1
				;BIT 7 - ALWAYS 1
				;BITS 8 - 15 7 SEG. (DP,G - A)

;	SYSTEM CONTROL LATCH ON Y UNIT
;
;	BIT 0	+ WATCHDOG CLOCK
;	BIT 1	+ WATCHDOG DATA
;	BIT 2	- LED ON
;	BIT 3	SET TO 1
;	BIT 4	- AUTO-ERASE ENABLE
;	BIT 5	- OBJECT PALETTE ENABLE
;	BIT 6	+ CMOS PAGE BIT 0
;	BIT 7 	+ CMOS PAGE BIT 1
;	BIT 8 - 11   4 BIT CONTROL CODE FOR SECURITY
;
*
*SYSTEM STUFF
*
AUTOERAS	.EQU	10H
OBJPALET	.EQU	20H

	.IF	YUNIT
SYSCINIT	.EQU	07FCH		; INITIAL SYSCTRL VALUE
	.ELSE
SYSCINIT	.EQU	0FFFCH		;INITIAL SYSCTRL VALUE
	.ENDIF

*
*SEVEN SEGMENT DISPLAY
*
SEG70		.EQU	0300H
SEG71		.EQU	9F00H
SEG72		.EQU	2500H
SEG73		.EQU	0D00H
SEG74		.EQU	9900H
SEG75		.EQU	4900H
SEG76		.EQU	4100H
SEG77		.EQU	1F00H
SEG78		.EQU	0100H
SEG79		.EQU	1900H
*
*INTERRUPT CONSTANTS
	.IF	NTSC
ENDVBLNK	.EQU	13H		;SCAN LINE TO END VERTICAL BLANKING
HSINT		.EQU	108+ENDVBLNK	;HALF SCREEN
EOSINT		.EQU	229+ENDVBLNK	;END OF SCREEN
SCOREINT	.EQU	40+ENDVBLNK	;END OF SCORE AREA INTERRUPT
NORMDPYS 	.EQU	0FEBCH		;NORMAL DPYSTRT VALUE
	.ELSE
ENDVBLNK	.EQU	14H		;SCAN LINE TO END VERTICAL BLANKING
HSINT		.EQU	135+ENDVBLNK	;HALF SCREEN
EOSINT		.EQU	256+ENDVBLNK	;END OF SCREEN
SCOREINT	.EQU	40+ENDVBLNK	;END OF SCORE AREA INTERRUPT
NORMDPYS 	.EQU	0FFFCH		;NORMAL DPYSTRT VALUE
	.ENDIF

ERASECOL	.EQU	0F0F0F0FH	;GAME AUTO ERASE COLOR #
ERASELOC	.EQU	COLRAM+0F0H	;GAME AUTO ERASE COLOR LOCATION

DPYPAGE0	.EQU	NORMDPYS	;DPYSTRT VALUE TO DISPLAY PAGE0
DPYPAGE1	.EQU	((~(EOSINT-ENDVBLNK))*10H)|0CH
PAGE1XY		.EQU	[256,0]		;ORIGIN OF GRAPHICS PAGE 1 (X MUST =0)
PAGE0E		.EQU	0100000h	;END OF PAGE0+1

*
*DMA STUFF
*
DMAREGS:	.equ	01A800A0h	;BOTTOM OF DMA REGISTERS FOR MMTM

DMACTRL:	.equ	01A80000h	;DMA CONTROL REGISTER
					;BIT 15:
					;1=START DMA (WRITE)
					;0=STOP DMA  (WRITE)
				
					;1=DMA BUSY (READ)
					;0=DMA IDLE (READ)
DMAGO		.EQU	DMACTRL		;FOR SYSCHECK
DMAOFFST:	.equ	01A80010h	;DMA OFFSET REGISTER
DMASAGL:	.equ	01A80020h	;DMA DATA STARTING ADDRESS LOW 16 BITS
DMASAGH:	.equ	01A80030h	;DMA DATA STARTING ADDRESS HIGH 16 BITS
DMAHORIZ:	.equ	01A80040h	;DMA DESTINATION, X COORDINATE
DMAVERT:	.equ	01A80050h	;DMA DESTINATION, Y COORDINATE
DMAHSIZE:	.equ	01A80060h	;DMA DESTINATION, X SIZE	
DMAVSIZE:	.equ	01A80070h	;DMA DESTINATION, Y SIZE
DMACMAP:	.equ	01A80080h	;DMA COLOR MAP SELECT
DMACONST:	.equ	01A80090h	;DMA CONSTANT COLOR SUBSTITUTE

*BITS FOR THE DMA CONTROL WORD
DMAWZ	.SET	1|8000h		;WRITE ZERO DATA
DMAWNZ	.SET	2|8000h		;WRITE NON-ZERO DATA
DMACZ	.SET	4|8000h		;WRITE CONSTANT ON ZERO DATA
DMACNZ	.SET	8|8000h		;WRITE CONSTANT ON NON-ZERO DATA
DMAWAL	.SET	3|8000h		;WRITE BOTH ZERO & NON-ZERO DATA
DMACAL	.SET	0Ch|8000h	;WRITE CONSTANT ON BOTH ZERO & NON-ZERO DATA

ISIZE	.equ	0
ISIZEX	.EQU	0
ISIZEY	.EQU	10H
IANIOFF	.equ	20H
IANIOFFX .EQU	20H
IANIOFFY .EQU	30H
ISAG	.equ	40h
ICMAP	.equ	60H
ICBOX	.equ	80H
ICBOXSIZ	.equ	90H

ZM	.set	1		;Z MINUS MULTIPLIER
ZP	.set	010000h		;Z PLUS MULTIPLIER
*
*SOUND PROCESSOR EQUATES
NINT	.EQU	0800H		;SOUND NON-INTERRUPTABLE
NINTEQ	.EQU	0400H		;SOUND NON-INTERRUPTABLE BY EQUAL PRIORITY
CHANNEL	.EQU	0F000H
NOTIME	.EQU	04000H
*
*SOUND CHANNELS
CHANCVSD .EQU	0
CHANDACA .EQU	1
CHANDACB .EQU	2
CHANYAM	.EQU	3


