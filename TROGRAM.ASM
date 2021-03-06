	.FILE	'TROGRAM.ASM'
	.TITLE	" <<< T R O G  -- RAM DEFINITIONS >>>"

**************************************************************************
*								         *
* 	     COPYRIGHT (C) 1990 MIDWAY MANUFACTURING COMPANY,		 *
* 	      MANUFACTURERS OF BALLY/MIDWAY AMUSEMENT GAMES.		 *
* 		         ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.OPTION	B,D,L
*
*GLOBALS IN THIS FILE

	.INCLUDE	"SYSINC.ASM"
	.INCLUDE	"TROGEQU.ASM"

	.DEF	SUPPLST, SUPPLEND, WAVEEGGS, DISPATCH_TABLE, WAVETIME
	.DEF	WAVE_MUSIC, COLRTEMP, WDIFF_RAM_ST, WDIFF_RAM_END
	.DEF	GDIFF_RAM_ST, GDIFF_RAM_END, BTIME, BUYNOW
	.DEF	STOP_WAITING, STOP_GREETING, SKYCOLOR, PCYCLE_RAM
	.DEF	TROG_INTRO_FLAG, WAVE_WATER, DINOSPEED, TROGSPEED
	.DEF	STOP_SEARCH, START_BONE, HOUSES, TROG_PURSUIT, TUTOR
	.DEF	TROG_PURSUIT_RESET, MAXBOZO, HOUSE_PITS, FIRE_DURATION
	.DEF	BORDER_SUPP, TUNNEL, TUNNEL_UP, TUNNEL_SCORE, WHEEL_CNT
	.DEF	NUM_WHEELS, APLAYDONE, FOREGROUND, BGND_TYPE
	.DEF	WAVE_SHOW, WAVE_INSTRUCT, WAVE_BGND1, WAVE_BGND2
	.DEF	START_SCORE, SPLAYER_NUM, SPLAYER_COL, WAVE_PSTUFF
	.DEF	TIP1_FLAG, TIP2_FLAG, TIP3_FLAG, TIP4_FLAG, TIP5_FLAG
	.DEF	TIP6_FLAG, TIP2A_FLAG, BAITER_TIME, TIP8_FLAG
	.DEF	MAINTUNE, THRASHFLG, START_WAVE, SPRGSPEED
	.DEF	FAST_TIME, POWERUP_DURATION, PXBARS, EGG_LIST, EGGS_LAID
	.DEF	FREEZE_TIME, CSHOW6_FLAG, BONUS_WAVE, BONUS_TIME
	.DEF	BONE_LIST, NUM_TROGS, TROG_CNT, VIRTUAL_TROGS, SMACK_CNT
	.DEF	COCKTAIL, MAX_TROGSPEED, EGG_DIVISOR, EGG_GROUPS
	.DEF	EGGS_AT_ONCE, TGEN_CNT, TGEN_CPTRS, LASTW_TROGS, SEC_FLAG
	.DEF	EGG_SCHEME

	.SECT	"NFIXED"			;MISC. LIST FIXED AREA
BBACTIVE	.LONG	0
BBFREE  	.LONG	0
*SUPPLEMENTAL LIST HEADERS (MAKE SURE YOU ZERO THESE IN MYOINIT)
SUPPLST:				;START OF SUPPLEMENTAL LIST PTRS

BACKSLST	.LONG	0
POSTSUPP	.LONG	0
P1BARS		.LONG	0		;PLAYER 1 BONES
P2BARS		.LONG	0		;PLAYER 2 BONES
P3BARS		.LONG	0		;PLAYER 3 BONES
P4BARS		.LONG	0		;PLAYER 4 BONES
PXBARS		.LONG	0		;INDESTRUCTIBLE BONES
DINOS		.LONG	0		;DINOSAURS
ENEMIES		.LONG	0		;STATIONARY ENEMIES
TROGS		.LONG	0		;MOVING ENEMIES
EGGS		.LONG	0		;EGGS FOR PICKUP
HOUSE_PITS	.LONG	0		;PITS THAT COVER HOUSES
BORDER_SUPP	.LONG	0		;LIST OF BONE BORDER OBJECTS
HOUSELST	.LONG	0		;HOUSE OBJECTS

SUPPLEND:				;END OF SUPPLEMENTAL LIST PTRS

	.LONG	0			
	.LONG	0
	.LONG	0
	.LONG	0
	.LONG	0
	.LONG	0
	.EVEN

         .BSS	NOAUTOE,16	;TURN AUTO ERASE OFF FOR DEBUG
	.BSS	PAGE,16		;FLAG FOR CURRENT GRAPHICS PAGE
	.BSS	RAND,32		
	.BSS	SWSTACK,32	;SWITCH STACK	
	.BSS	SWTEMP1,32	;SWITCH TIMING STORAGE FOR SWITCH
	.BSS	SWTEMP2,32
	.BSS	SW2TEMP1,32	;SWITCH TIMING STORAGE FOR SWITCH2
	.BSS	SW2TEMP2,32
	.BSS	SWSTMN,256	;BOTTOM OF STACK
	.BSS	SWSTST,0	;START SWITCH STACK
	.BSS	SYSCOPY,16	;RAM COPY OF SYSCTRL LATCH

	.BSS	INTSYNC0,16	;HALF SCREEN INTERRUPT SYNCHRO.\ __ KEEP THESE
	.BSS	INTSYNC1,16	;FULL SCREEN INTERRUPT SYNCHRO./    TOGETHER.

	.BSS	PALRAM,0	;PALETTE ALLOCATOR RAM
	.BSS	FPALRAM,PALRSIZ*NMFPAL	
	.BSS	BPALRAM,PALRSIZ*NMBPAL	
	.BSS	PTRRAM,PTRSIZ*NUMPTR
	.BSS	CURPAL,16	;CURRENT PALETTE FOR STUFOBJ TO USE

	.BSS	COLRTEMP,16*16	;RAM COPY OF CYCLING COLORS
	.BSS	COLRTEND,0	;MARKER
	.BSS	PCYCLE_RAM,16*PCOLRCNT	;PLAYER CYCLE COLORS

	.BSS	SKYCOLOR,16	;CURRENT FULL BRIGHTNESS SKY COLOR VALUE
	.BSS	IRQSKYE,16	;ACTUAL SKY COLOR (AUTOERASE)

	.BSS	P1DATA,PDSIZE	;PLAYER ONE DATA 
	.BSS	P2DATA,PDSIZE	;PLAYER TWO DATA 
	.BSS	P3DATA,PDSIZE	;PLAYER THREE DATA 
	.BSS	P4DATA,PDSIZE	;PLAYER FOUR DATA 

	.BSS	NPLAYERS,16	;MAX # OF PLAYERS ALLOWED
	.BSS	STICKTYP,16	;JOYSTICK TYPE, 0 = 4-WAY, 1 = 8-WAY

	.BSS	COCKTAIL,16	;IF = 1 THEN GAME IS IN COCKTAIL MODE

	.BSS	GAME_STATE,16	;GAME STATE VARIABLE :	10 = INGAME
				;			18 = ININTRO
				;			20 = INPLAY
				;			30 = INAMODE
				;			40 = INDIAG

	.BSS	GRAMSTRT,0	;START OF GAME RAM
	.BSS	CURPLYRS,16	;CURRENT NUMBER OF PLAYERS
	.BSS	WAVE,16		;CURRENT WAVE NUMBER
	.BSS	SOUNDSUP,16	;IF<>1 THEN NO SOUNDS SHALL BE MADE
	.BSS	GAMERASE,16	;0 = NO AUTO-ERASE SCHEME
				;1 = AUTO-ERASE, OFF AT SCREEN END.
				;2 = AUTO-ERASE, OFF AT MID-SCREEN.
				;3 = AUTO-ERASE, ON ALL THE TIME!

	.BSS	BTIME,16	;BUY IN TIMER
	.BSS	BUYNOW,16	;BUY IN WINDOW IS UP
	
	.BSS	GDIFF_RAM_ST,0	  	;START GAME DIFFICULTY RAM
	.BSS	STOP_WAITING,16		;STOP WAITING BEFORE DANGER AFTER THIS WAVE
	.BSS	STOP_GREETING,16	;STOP WAVING TO PLAYER UPON APPEARANCE
	.BSS	STOP_SEARCH,16		;STOP DINO SEARCH FOR BEST PATH
	.BSS	START_BONE,16		;WAVE TO START BONING THE PLAYER
	.BSS	MAXBOZO,16,1		;BOZO DISQUALIFY # OF CONSECUTIVE WAVES
	.BSS	MAXBARS,16   		;MAX # ACTIVE BARS FOR EACH PLAYER
	.BSS	LASTW_TROGS,16		;NUMBER OF LAST WAVE TROGS TO KILL
	.BSS	GDIFF_RAM_END,0		;END GAME DIFFICULTY RAM

	.BSS	TROG_INTRO_FLAG,16	;TROG ONLY INTROS ONCE A GAME

	.BSS	START_WAVE,16		;WE STARTED ON THIS WAVE

	.BSS	START_SCORE,32		;SCORE TO ADD UPON FIRST START

	.BSS	SPLAYER_NUM,16		;PLAYER NUMBER THAT STARTED THIS GAME

	.BSS	SPLAYER_COL,16		;PLAYER COLOR THAT STARTED THIS GAME

	.BSS	TIP1_FLAG,16		;FLAGS FOR TROG TIPS 
	.BSS	TIP2_FLAG,16		;IF = 0, THE TIP HAS NOT BEEN SHOWN.
	.BSS	TIP2A_FLAG,16
	.BSS	TIP3_FLAG,16
	.BSS	TIP4_FLAG,16
	.BSS	TIP5_FLAG,16
	.BSS	TIP6_FLAG,16
	.BSS	TIP8_FLAG,16

	.BSS	CSHOW6_FLAG,16		;FLAGS FOR CAVE SHOWS

	.BSS	TUTOR,16		;IF <> 0 THEN IN TUTORIAL MODE

	.BSS	EGG_SCHEME,16		;0 = SIMPLE, 1 = COMPLEX

	.BSS	GRAMEND,0

	.BSS	WRAMSTRT,0	;START OF WAVE RAM (CLEARED AT THE START)

	.BSS	WAVETIME,32	;ELAPSED WAVE TIME

	.BSS	WAVE_MUSIC,32	;MUSIC FOR THIS WAVE

	.BSS	WAVE_WATER,32	;PROCESS THAT WILL CYCLE WATER THIS WAVE

	.BSS	WAVE_BGND1,32	;WAVE PRIMARY BACKGROUND
	
	.BSS	WAVE_BGND2,32	;WAVE SECONDARY BACKGROUND

	.BSS	FOREGROUND,32	;PTR TO FOREGROUND TABLE FOR THIS WAVE

	.BSS	BGND_TYPE,16	;TYPE OF BACKGROUND, 0 = GREEN, 1 = LAVA, ETC.

	.BSS	DISPATCH_TABLE,32 ;CURRENT PROCESS DISPATCH TABLE

	.BSS	TUNNEL,16	;IF <> 0, THEN A TUNNEL IS ALLOWED
	.BSS	TUNNEL_UP,16	;IF <> 0, THEN A TUNNEL IS OUT
	.BSS	TUNNEL_SCORE,32 ;SCORE TO BE AWARDED FOR TUNNELING

	.BSS	WAVE_SHOW,32	;CAVE SCENE DISPLAYED THIS WAVE

	.BSS	WAVE_INSTRUCT,32 ;INSTRUCTIONS POSTED THIS WAVE

	.BSS	WAVE_PSTUFF,32	;PROCESS TO BRING OUT DINOS AND EGGS

	.BSS	FAST_TIME,16	;TIME TO BEAT FOR "FAST FINISH" BONUS

	.BSS	EGG_LIST,32	;IF <> 0, USE THIS LIST TO BRING OUT EGGS

	.BSS	EGGS_LAID,16	;IF <> 0, THEN THE EGGS ARE OUT FOR THIS WAVE

	.BSS	BONE_LIST,32	;IF <> 0, LAY THESE BONES

	.BSS	HOUSES,16	;IF 1, FIRST HOUSE HAS BEEN BUILT

	.BSS	WHEEL_CNT,16	;NUMBER OF WHEELS CURRENTLY ACTIVE

	.BSS	TROG_CNT,16	;NUMBER OF TROGS CURRENTLY ACTIVE

	.BSS	SMACK_CNT,16	;NUMBER OF FACE SMACKS BY SPRING DUDE

	.BSS	FREEZE_TIME,16	;TICKS LEFT THIS FREEZE

	.BSS	POSTMAP,32	;CURRENT ACTIVE POST MAP
	.BSS	BOUNDRIES,32	;BOUNDRY TABLE FOR THIS WAVE

	.BSS	BOXDIM,32	;TYPICAL BOX DIMENSIONS THIS WAVE

	.BSS	MOVEMAP,MOVESIZE*NMOVES	;PLAYER MOVE MAP
	.BSS	MOVEEND,0
	.BSS	MOVECNT,16			;NUMBER OF MOVES

	.BSS	CMOVEMAP,CMOVESIZE*NCMOVES	;CENTER POINT MAP
	.BSS	CMOVEEND,0
	.BSS	CMOVECNT,16			;NUMBER OF CENTER MOVES

	.BSS	AMOVEMAP,AMOVESIZE*NAMOVES	;AUXILARY POINT MAP
	.BSS	AMOVEEND,0
	.BSS	AMOVECNT,16			;NUMBER OF AUXILARY MOVES

	.BSS	EMOVEMAP,EMOVESIZE*NEMOVES	;EXIT POINT MAP
	.BSS	EMOVEEND,0
	.BSS	EMOVECNT,16			;NUMBER OF EXIT MOVES

	.BSS	WDIFF_RAM_ST,0	  	;START WAVE DIFFICULTY RAM

	.BSS	WAVEEGGS,16		;# OF EGGS TO COLLECT THIS WAVE
	.BSS	DINOSPEED,16		;INITIAL DINO VELOCITY THIS WAVE
	.BSS	TROGSPEED,16		;INITIAL TROG SPEED THIS WAVE
	.BSS	TROG_PURSUIT,16	;TROG PURSUES WITHIN THESE MOVES  (< HARDER)
	.BSS	TROG_PURSUIT_RESET,16	;MOVES 'TIL PURSUIT RESET (< HARDER)
	.BSS	FIRE_DURATION,16	;TIME(IN TICKS) THAT A FIRE WILL BURN
	.BSS	NUM_WHEELS,16		;NUMBER OF SIMULTANEOUS WHEELS ALLOWED
	.BSS	SPRGSPEED,16		;INITIAL SPRING GUY SPEED
	.BSS	POWERUP_DURATION,16	;TIME(IN TICKS) POWER UP WILL EXIST
	.BSS	VIRTUAL_TROGS,16	;VIRTUAL # OF SIMULTANEOUS TROGS ALLOWED

	.BSS	WDIFF_RAM_END,0		;END WAVE DIFFICULTY RAM

	.BSS	NUM_TROGS,16		;ACTUAL # OF SIMULTANEOUS TROGS ALLOWED

	.BSS	PAUSE_GAME,16		;IF <> 0, THEN PAUSE GAME PLAY

	.BSS	APLAYDONE,16		;IF <> 0, A DINO HAS FINISHED A-MODE

	.BSS	BAITER_TIME,16		;WAVE TIME UNTIL WE START THE BAITER

	.BSS	WAVE_OVER,16		;IF <> 0, THEN THE WAVE HAS ENDED

	.BSS	MAINTUNE,16		;IF = 0 NORMAL MUSIC, IF = 1 HOME MUSIC
	
	.BSS	THRASHFLG,16		;TRASH ROCK TUNE IS PLAYING

	.BSS	BONUS_WAVE,16		;IF <> 0, THIS IS SOME TYPE OF BONUS

	.BSS	BONUS_TIME,16		;TIME FOR THIS BONUS WAVE

	.BSS	MAX_TROGSPEED,16	;MAX TROG SPEED THIS WAVE

	.BSS	EGG_DIVISOR,16		;# OF PLAYERS ALLOTED EGG SPOTS

	.BSS	EGG_GROUPS,16		;# OF EGG GROUPS PLOTTED

	.BSS	EGGS_AT_ONCE,16		;PLAYER ALLOWED THIS MANY EGGS AT ONCE

	.BSS	TGEN_CNT,16		;NUMBER OF TROG GENERATORS
	.BSS	TGEN_CPTRS,32*8		;PTR ARRAY TO GENERATOR CENTERS

	.BSS	WRAMEND,0

	.BSS	NRAMSTRT,16
	.BSS	NRAMEND,0

	.BSS	SEC_FLAG,16		;SECURITY FLAG

	.END
