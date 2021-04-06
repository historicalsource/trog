	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGBGND.ASM'
	.TITLE	" <<< T R O G  -- BACKGROUND HANDLERS >>>"

**************************************************************************
*								         *
* 	     COPYRIGHT (C) 1990 MIDWAY MANUFACTURING COMPANY,		 *
* 	      MANUFACTURERS OF BALLY/MIDWAY AMUSEMENT GAMES.		 *
* 		         ALL RIGHTS RESERVED.				 *
*								         *
**************************************************************************

	.OPTION	B,D,L
	.MNOLIST

*	GET THE SYSTEM STUFF
	.INCLUDE	"MPROCEQU.ASM"	;MPROC equates
	.INCLUDE	"DISPEQU.ASM"	;Display processor equates
	.INCLUDE	"GSPINC.ASM"	;GSP assembler equates
	.INCLUDE	"SYSINC.ASM"	;Zunit system equates
	.INCLUDE	"TROGEQU.ASM"
	.INCLUDE	"BGNDTBL.GLO"	;BACKGROUND EQUATES
	.INCLUDE	"IMGTBL.GLO"	;IMAGE EQUATES

	.DEF	BGND_UD1, BGND_UD2, CLRBGND
	.DEF	FGND_OUT, BTYPE_CK
	.DEF	BAKMODS, BAK2MODS

	.DEF	BACKGROUND1, LAVABGND1, LAVABGND2
	.DEF	BACKGROUNDE, BACKGROUNDC, BACKGROUNDW, BACKGROUNDS
	.DEF	BACKGROUNDCRAY,	BACKGROUNDDSRT
	.DEF	BACKGROUNDX6, BACKGROUND2
	.DEF	BACKGROUNDX2, BACKGROUNDX3, BACKGROUNDX5

	.DEF	FOREGROUNDV2

	.DEF	CREDITBGND

	.IF	0

	.DEF	TROGBLACKBOARD

	.DEF	BACKGROUNDX1,BACKGROUNDX7

	.ENDIF

	.REF	FOREGROUND, BGND_TYPE

	.DEF	TROGCAVE1
	.DEF	TROGCAVE2

	.BSS	BGNDRAM_START,0

	.BSS	bgndpaltbl,32,1
	.BSS	mod_pos,32,1
	.BSS	BAKBITS,32*128
	.BSS	BAK2BITS,32*16
	.BSS	BAKMODS,32
	.BSS	BAK2MODS,32

	.BSS	PREVWTL,32		;PREVIOUS WORLDTL FOR BBOFSCRN
	.BSS	PREVSTL,32		;PREVIOUS SCRNTL FOR BBOFSCRN

	.BSS	BGNDRAM_END,0

	.TEXT

**************************************************************************
*                                                                        *
* CLRBGND - CLEAR THE BACKGROUND UPDATE RAM AND MAKE THE MODULE LISTS	 *
* 	  NULL.								 *
*                                                                        *
**************************************************************************
CLRBGND
	MMTM	SP,A0,A1
*INITIALIZE ALL RAM TO 0
	MOVI	BGNDRAM_START,A1	;GET THE RAM AREA
	CLR	A0
CLRBRAMLP:
	MOVE	A0,*A1+,W
	CMPI	BGNDRAM_END,A1
	JRNE	CLRBRAMLP
	MOVI	DUMBGND,A1
	MOVE	A1,@BAKMODS,L
	MOVE	A1,@BAK2MODS,L
	MMFM	SP,A0,A1
	RETS
*
*DUMMY (NULL) BACKGROUND DEFINITION. THIS IS GLOBAL
DUMBGND
	.LONG	0FFFFFFFFH


*BACKGROUND UPDATER EQUATES
BLSTSTRT	.EQU	>8000
BLSTEND 	.EQU	>8001

************* Local Constants for UPD **************
DISP_PAD    	.set	>00300030	  ; Y:X
WIDEST_BLOCK	.set	250

;* Must keep the size of these structures a multiple of 16
map_zflagspal	.set 0
map_pal		.set 0		;size 4 - palette select
map_flags   	.set 4		;size 4 - bit 0 hflip, bit 1 yflip
map_z		.set 8		;size 8
map_x		.set 16		;size 16
map_y		.set 32		;size 16
map_hdr		.set 48		;size 16 - offset in long words from block_hdr_tbl
				; bits 12-15 are bits 4-7 of pal
				; map_hdr set to >FFFF if block is not allocated
block_size	.set 64		;* if changed must get rid of shifts by 6

;* Offsets for a BLOCK HDR structure
map_size	.set	0
map_w		.set	0	;size 16	  ; These fields can't be changed
map_h		.set	16	;size 16	  ; because they are used as the
map_dataptr	.set	32	;size 32	  ;
block_hdr_size	.set 	64
;;* Offsets for a BLOCK HDR structure
;map_size	.set	0
;map_w		.set	0	;size 16	  ; These fields can't be changed
;map_h		.set	16	;size 16	  ; because they are used as the
;map_animoff	.set 	32	;size 32	  ; OIMG block header
;map_dataptr	.set	64	;size 32	  ;
;block_hdr_size	.set 	96

************************************************************************

**************************** BSrch1stXB ********************************
BSrch1stXB:
;*** PARMS
;	A0 - x coordinate of a block
;	A1 - Start of background block table
;	A2 - end of block table
;*** Returns
;	A0 - address of first block with x coordinate >= parm
;		if new x is highest returns next empty block
;		if no blocks with >= X, return 0

;* A0 = X val being searched for
;* A1 = Block Table Base + offset to X val
;* A14 - Threshhold for switching from binary to linear search
;* A9 = Low # -- # greatest background block
;* A10 = Mid # -- (High + Low) >> 1
;* A2 = High # -- # of lowest background block

	mmtm	SP,A1,A2,A8,A9,A10
	clr	A9		;* set low = 0
	sub	A1,A2
	srl	6,A2	;* div by size of block (64)
	addi	map_x,A1	;* block tbl base + X offset
	movk	5,A14	;* threshhold for switching from binary to linear search
BSRCH:
	move	A2,A10
	sub	A9,A10	;* if (high - low) <= 5 finish with linear search
	cmp	A14,A10
	jrle	LSRCH

	srl	1,A10
	add	A9,A10		

	;* get mid->x
	move	A10,A8
	sll	6,A8		;* multiply by block size (64)
	add	A1,A8
	move	*A8,A8,W	;* get x coor of the block
	cmp	A0,A8
	jrlt	Blow
	move	A10,A2	;* high = mid
	jruc	BSRCH
Blow:
	move	A10,A9	;* low = mid
	jruc	BSRCH
LSRCH:
	;* finish with a linear search of block table from low to high
	;* ending with first block x coor that is >= A0
;* A0 = X val being searched for
;* A9 = Low Address -- pts to X offset of block
;* A2 = High Address -- pts to X offset of block
	sll	6,A9		;* low block # to low block offset
	sll	6,A2		;* high block # to high block offset
	add	A1,A9
	add	A1,A2
	movi	block_size,A8
LSRCHLP:
	move	*A9,A10,W	;* X coor
	cmp	A0,A10
	jrge	GotB		;* if low->x >= A0 goto found
	add	A8,A9
	cmp	A2,A9
	jrle	LSRCHLP
;* block not found, return 0
	clr	A0
	jruc BSrchDone
GotB:
	;* return a ptr to the block
	move	A9,A0
	subi	map_x,A0

BSrchDone:
	mmfm	SP,A1,A2,A8,A9,A10
	rets
**************************** BSrch1stXB ********************************

****************  U P D A T E   D I S P   L I S T **********************
;* deletes all display objects which are not on the screen
;* insures all background blocks on screen are on the disp list
BGND_UD1:		;* call to update main background
;* input, WORLDTL, SCRNTL, SCRNLR, BAKLST, BAKBITS, BAKMODS
	;* this protects DISP_MOD and DISP_DEL TOO!
	mmtm	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14
	mmtm	SP,B0

	;* Get coors of area to be put on display list.
	move	@WORLDTL,A3,1
	move	A3,A4
	move	@SCRNTL,A0,1
	addxy	A0,A3 		
	move	@SCRNLR,A0,1
	addxy	A0,A4		
	movi	DISP_PAD,A0
	subxy	A0,A3		;A3 - disp_tl
	addxy	A0,A4		;A4 - disp_lr
	movi	BAKLST,A8	;A8 - bakground list
	callr	DISP_DEL

	;* determine which module
	move	@BAKMODS,A0,L		;A0- ptr to the module list
	movi	INSBOBJ,B0		;B0 - which insert routine
	movi	BAKBITS,A7		;A7 - bit table for block being on disp list
	callr	DISP_MOD
	mmfm	SP,B0
	mmfm	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14
	rets

BGND_UD2:		;* call to update secondary background
;* input, BAK2TLX, BAK2TLY, SCRNTL, SCRNLR, BAK2LST, BAK2BITS, BAK2MODS
	mmtm	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14
	mmtm	SP,B0
	;* Get coors of area to be put on display list.
	move	@BAK2TLX+16,A3,W
	move	@BAK2TLY+16,A0,W
	sll	16,A0
	movy	A0,A3
	move	A3,A4
	move	@SCRNTL,A0,L
	addxy	A0,A3 		
	move	@SCRNLR,A0,L
	addxy	A0,A4		
	movi	DISP_PAD,A0
	subxy	A0,A3		;A3 = disp_tl
	addxy	A0,A4		;A4 = disp_lr
	movi	BAK2LST,A8   		;A8 - bakground list
	callr	DISP_DEL

	movi	INSB2OBJ,B0		;B0 - which insert routine
	move	@BAK2MODS,A0,L		;* A0- ptr to the module list
	movi	BAK2BITS,A7
	callr	DISP_MOD
	mmfm	SP,B0
	mmfm	SP,A0,A1,A2,A3,A4,A5,A6,A7,A8,A9,A10,A11,A12,A13,A14
	rets
***********************************************************************


*********************** D I S P   M O D *******************************
;* Scan a Module list to find out which modules contain blocks
;* which need to be checked for addition to the display list.
;	B0 - which insert routine
;	A0 - Module list
;	A3 - disp_tl
;	A4 - disp_lr
;	A7 - BAKBITS	;A7 - bit table for block being on disp list

;PARMS For DISP_ADD
;	A1 - Background Block table
;	A2 - End of Background Block table
;	A5 - Background hdr table
;	A9 - Module Start Position Y:X
;	A10 - ptr to palette table for new block
;	    ;passed from above
;	A3 - disp_tl
;	A4 - disp_lr
;	A6 - which bakground insert routine primary|secondary
;	A7 - bit table for block being on disp list

;* caller is responsible for pushing and popping all A-registers

DISP_MOD:
	clr	A9			;init y:x starting position
	clr	A11			;ending y:x pos
	move	A7,A6			;A6 will point to BakBits after Mod

ModLp:	
SkDAdd:
	move	A6,A7
	move	*A0+,A8,L		;load module ptr
	cmpi	>FFFFFFFF,A8
	jrz	ModX			;end of the module tbl
	move	*A8+,A10,L		;load y:x size

	move	*A0+,A14,W		;X start position
	zext	A14,W
	cmpi	BLSTSTRT,A14
	jrnz	NotLastStartX
	move	A11,A14		
	subxy	A10,A14
	jruc	GotNewX
NotLastStartX:
	cmpi	BLSTEND,A14
	jrnz	GotNewX
	move	A11,A14
GotNewX:
	move	*A0+,A5,W		;Y start position
	zext	A5,W
	cmpi	BLSTSTRT,A5
	jrnz	NotLastStartY
	move	A11,A5		
	subxy	A10,A5
	jruc	GotNewY
NotLastStartY:
	cmpi	BLSTEND,A5
	jrnz	NotLastEndY
	move	A11,A5
	jruc	GotNewY
NotLastEndY:
	sll	16,A5
GotNewY:
	movy	A5,A14
	move	A14,A9

	move	A9,A11
	addxy	A10,A11	;A11 is module y:x end
	move	*A8+,A10,W		;load # of blocks
	add	A10,A6		;A6 is new BAKBITS ptr

; 	cmpxy	A9,A4
;	jrxle	ModX  	;jump to exit loop if Mod start X > Screen End X

	cmpxy	A3,A11
	jrxlt	SkDAdd		;skip if Mod X End < TL X
	jrylt	SkDAdd		;skip if Mod Y End < TL Y

	cmpxy	A9,A4
	jrxlt	SkDAdd  ;use this if modules aren't sorted left to right
				;jump to if Mod start X > Screen End X
	jrylt	SkDAdd		;skip if Mod Y Start > BR Y

	move	*A8+,A1,L		;A1-block table	
	move	A10,A2
	sll	6,A2			;each block is 4 words long
	add	A1,A2			;A2-block table end
	move	*A8+,A5,L		;A5-Hdrs
	move	*A8+,A10,L		;A10-Pal tbl
	subxy	A9,A3
	subxy	A9,A4
	callr	DISP_ADD
	addxy	A9,A3
	addxy	A9,A4
	jruc	ModLp

ModX:
	rets
***********************************************************************

*********************** D I S P   A D D *******************************
;* This function adds all module blocks in the given range of Module
;* relative coors to the display list.
;* The boundries are included in the group to add.
DISP_ADD:
;***	PARMS:
;       B0 - which bakground insert routine primary|secondary
;	A5 - Background hdr table
;	A7 - bit table for block being on disp list
;	A9 - Module Start Position Y:X
;	A10 - ptr to palette table for new block
;	A1 - Background Block table
;	A2 - End of Background Block table
;	A3 - disp_tl	- relative to the Module start POS
;	A4 - disp_lr	- " 
;*** RETURNS nothing

;thrashes A1,A8,A14
	mmtm	SP,A0,A6,A7,A11

	;* Find first universe block with an X coor >= A9
	movx	A3,A0
	sext	A0,W
	subi	WIDEST_BLOCK,A0
;A0 - x coordinate of a block
;A1 - Start of background block table
;A2 - end of block table
	callr	BSrch1stXB
;A0 is now the address of a block
	jrz	DADONE	;* no blocks with gtr Xcoor
	
	movi	block_size,A6

	move	A0,A8
	sub	A1,A8	;* subtract off start of table
	srl	6,A8	;* divide by block size (64)
	add	A7,A8	;* A8 - ptr to bit which indicates block on list
	subk	8,A8	;* after inc A8, use movb *A8 to load sign bit
	sub	A6,A0	;subtract block size
BScanLP0:
	inc	A8
	add	A6,A0	;* get next block
	;* check if there are no more bgnd blocks
	cmp	A2,A0
	jrge	DADONE

	;* if block already on display list try again
	movb	*A8,A11
	jrn	BScanLP0

	;* check if x to big
	move	*A0(map_x),A11,W
	cmpxy	A3,A11
	jrxge	BScan1	   	;* Jump if BlockX >= TL X

	;* load map header
	move	*A0(map_hdr),A14,W
	sll	20,A14	;* only want bottom 12 bits, top 4 are pal bits
	srl	15,A14	;* leaves B9 << 5 == long word offset
	add	A5,A14	;* A14 now pts to block hdr

	;* check if right end of block hangs onto screen
	move	*A14,A1,W	;A1 is now the width of the block
	add	A11,A1
	cmpxy	A3,A1	;* right end of block doesn't hang on to screen
	jrxlt	BScanLP0		;* jump if Block X+W < TL X

	;* if ycoor to big try again
	move	*A0(map_y),A1,0
	sll	16,A1
	cmpxy	A1,A4
	jrylt BScanLP0		;* Jump if Block Y > BR Y

	;* if ycoor+height to small try again
	move	*A14(map_h),A11,0
	sll	16,A11
	add	A11,A1
	cmpxy	A3,A1
	jrylt BScanLP0		;* Jump if Block Y+H < TL Y

	move	A0,A7
	callr	ADDBLOCK	;Thrashes A1,A14
	jrnc BScanLP0
	jruc	DADONE		;* was unable to add block - no blocks left

BScan1:
	dec	A8		;* bit ptr for block on disp list
	sub	A6,A0		;subtract off block size
BScanLP1:
	inc	A8
	add	A6,A0	;Get next block
	;* check if there are no more bgnd blocks
	cmp	A2,A0
	jrge	DADONE

	;* if block already on display list try again
	movb	*A8,A11
	jrn	BScanLP1

	;* if ycoor to big try again
	move	*A0(map_y),A1,W
	sll	16,A1
	cmpxy	A1,A4
	jrylt BScanLP1		;* Jump if Block Y > BR Y

	;* if ycoor+height to small try again
	move	*A0(map_hdr),A14,W
	sll	20,A14	;* only want bottom 12 bits, top 4 are pal bits
	srl	15,A14	;* leaves B9 << 5 == long word offset
	add	A5,A14	;* B9 now pts to block hdr
	move	*A14(map_h),A11,W
	sll	16,A11
	add	A11,A1
	cmpxy	A3,A1
	jrylt BScanLP1		;* Jump if Block Y+H < TL Y

	;* if xcoor to big quit
	move	*A0(map_x),A1,W
	cmpxy	A1,A4
	jrxlt DADONE	;* Jump if Block X > BR X

	move	A0,A7
	callr	ADDBLOCK
	jrnc	BScanLP1

DADONE:
	mmfm	SP,A0,A6,A7,A11
	rets
***********************************************************************

***********************************************************************
ADDBLOCK:
;* PARMS
; B0 - which INS routine
; A5 - base of background block hdr
; A7 - ptr to background block
; A8 - ptr to bit map for block on disp list
; A9 - Module Start Position Y:X
; A10 - ptr to palette table for new block

;* Returns carry set if GETOBJ fails...
	;* Also Destroys A1,A14 but they are used as temps in DISP_ADD
	mmtm	SP,A0,A2,A3,A4

	calla	GETOBJ
	jrz  	ADDX

	;* set bit in bitmap for block on list
	movb	*A8,A14
	ori	>80,A14
	movb	A14,*A8
	move	A8,*A0(OPLINK),L ;set OPLINK to be a ptr to the disp list bit
	
	move	*A7(map_x),A1,L	;A1 ypos:xpos of block from Mod Base
	addxy	A9,A1		;Add in Module Base Position
	move	A1,*A0(OXPOS),W
	srl	16,A1
	move	A1,*A0(OYPOS),W
	move	*A7,A4,W	;A4 - map_z,8:map_flags,4:map_pal,4
	move	A4,A3
	srl	8,A3
	sll	24,A3
	srl	8,A3
	move	A3,*A0(OZVAL),L

	move	*A7(map_hdr),A1,W
	movx	A1,A14
	sll	16,A14
	srl	28,A14
	sll	4,A14		;* bits 12-15 are bits 4-7 of pal index
	
	sll	20,A1		;* bits 0-11 are hdr ptr;
	srl	15,A1		;* A1-long word offset into block hdr tbl
	add	A5,A1		;* A1 - Ptr to oimg hdr - input to GSAGOF

	;A4 - map_z,8:map_flags,4:map_pal,4
	move	A4,A3
	sll	28,A4		;* last four bits for pal
	srl	28,A4
	add	A14,A4	
	sll	5,A4   		;* A4 is lword ptr from pal tbl
	add	A10,A4		;* add in pal tbl
	move	A0,A2		;save A0
	move	*A4,A0,L	;* get palette
	calla	GETBPAL
	jrnz	BSetPal
	clr	A0
BSetPal:
	move	A0,*A2(OPAL),W
	move	A2,A0		;restore A0

	movi	>8002,A4	;>8000 DMA GO, 2
	srl	4,A3	;* remove palette bits
	sll	30,A3		
	jrc	SKIP0	;* carry bit is the transparency bit
	addk	1,A4
SKIP0:
	srl	26,A3	;* line up flip h,v bits
	add	A3,A4	;A4 - Flags for GSAGOF
	move	A1,*A0(OIMG),L
*A1=DATA BLOCK POINTER
*A4=OBJECT FLAGS
	calla	BKGSAGOF	;USES ISAG->20 FOR ISAG
*A2=RETURNED WITH NEW OSIZE
*A3=RETURNED WITH NEW SAG
*A4=RETURNED WITH NEW OFFSET:OFLAGS
	move	A0,A1
	addi	OSIZE+>20,A1
	mmtm	A1,A2,A3,A4		;Stuff OSIZE,OSAG,OFFSET,OFLAGS

	call	B0
	clrc
	mmfm	SP,A0,A2,A3,A4
	rets
ADDX: ;failure to get object
	setc
	mmfm	SP,A0,A2,A3,A4
	rets
**********************************************************************


************************ D I S P   D E L *****************************
;* This function deletes all objs outside the given range
;* of coors from the display list.
;* The boundries are not included in the group to delete.
DISP_DEL:
;***	PARMS:
;	A8 - bak list	
;	A3 - disp_tl
;	A4 - disp_lr
;*** RETURNS nothing

;Thrashes A0,A6,A7,A8,A9	;all of which are pushed by caller

del_loop:
	move	A8,A9	   	; ptr to PREV in A9
	move	*A9,A8,L   	; ptr to NEXT in A8
	jrz	del_done	   	; QUIT if at end of list

	;if X > Xmax continue
	move	*A8(OXPOS),A7,W
	cmpxy	A7,A4
	jrxlt	DEL_IT		;* jump if BR X < Block X

	;if Y > Ymax continue
	move	*A8(OYPOS),A0,W
	sll	16,A0
	cmpxy	A0,A4
	jrylt	DEL_IT		;* jump if BR Y < Block y

	move *A8(OIMG),A1,L
	;if X+width < Xmin continue
	move	*A1,A6,W		;A6 block width
	add	A6,A7
	cmpxy	A3,A7
	jrxlt	DEL_IT		;* jump if TL X > Block X+W

	;if Y+height < Ymin continue
	move	*A1(map_h),A7,0		;A7 block height
	sll	16,A7
	add	A7,A0
	cmpxy	A3,A0
	jrylt	DEL_IT		;* jump if TL Y > Block Y+H

	jruc	del_loop

DEL_IT:	;* DELETE the OBJ
    ;* free the palette
	move	*A8(OPAL),A0,W
	jrz	NoFreeP
	calla	FREEPAL
NoFreeP:

	;* unset the on display list bit
	move	*A8(OPLINK),A0,L
	movb	*A0,A7
	andi	>7F,A7
	movb	A7,*A0
		
	move	*A8,*A9,L  	; put NEXT link in PREV obj
	move	@OFREE,A0,L				
	move	A0,*A8,L
	move	A8,@OFREE,L	; Return deleted block to free stack
	move	A9,A8		;A1- points to last obj
	jruc	del_loop

del_done:
	rets

**************************************************************************
*								         *
* FGND_OUT - OUTPUT THE FOREGROUND OBJECTS DEFINED BY THE LIST IN	 *
* 		GLOBAL RAM LOCATION FOREGROUND.				 *
* GLOBALS:								 *
* 	FOREGROUND,W							 *
* RETURNS:								 *
* 	NOTHING								 *
*								         *
**************************************************************************
FGND_OUT
	PUSH	A0
	MOVE	@FOREGROUND,A14,L
	MOVE	*A14,A0,L
	JRZ	OUT_FGND_X
OUT_FGND_LP:
	CALLA	MAKE_FGND_OBJ		;MAKE IT SPECIAL
	JRZ	OUT_FGND_X		;BR = SORRY, OUT OF OBJECTS
	MOVE	*A14,A0,L
	JRNZ	OUT_FGND_LP
OUT_FGND_X:
	PULL	A0
	RETS

**************************************************************************
*								         *
* MAKE_FGND_OBJ - GET AN OBJECT, A PALETTE, STUFF, AND INSERT		 *
* 		A FOREGROUND PIECE. STUFFING IS DONE WITH A		 *
* 		REDUCED INITIALIZATION TABLE.				 *
* A14 = PTR TO FGND INIT ENTRY.						 *
* RETURNS:								 *
* A0 = PTR TO OBJECT							 *
* Z BIT SET = FAILURE,A0 = 0						 *
*								         *
**************************************************************************
MAKE_FGND_OBJ:
	CALLA	GETOBJ
	JRZ	MFOX			;OBJECT BLOCK FAILURE
	CALLR	FGND_PAL		;GET THE PALETTE, AS A BACKGROUND
	JRZ	MFOXFAIL		;BR = FAILED TO DO SO
	CALLR	STUFF_FGND		;STUFF IT
	CALLA	INSOBJ			;INSERT IT
	MOVE	A0,A0			;CLEAR Z
	JRUC	MFOX			;AND EXIT
MFOXFAIL:
	CALLA	FREEOBJ
	CLR	A0
MFOX:
	RETS

**************************************************************************
*                                                                        *
* FGND_PAL - GET A FOREGROUND PALETTE FOR USE, IN THE BGND PALETTE TAB	 *
* A14 = POINTER TO FGND OBJECT INITIALIZATION TABLE.			 *
* RETURNS:								 *
* ZBIT SET = FAILURE							 *
* ZBIT CLR = SUCCESS --> VAR. CURPAL = PALETTE # JUST CREATED		 *
*                                                                        *
**************************************************************************
FGND_PAL:
	PUSH	A0
  	MOVE	*A14(20H),A0,L
	MOVE	*A0(ICMAP),A0,L		;GET THE PALETTE NAME
	CALLA	GETBPAL			;GET A PALETTE
	JRZ	FGND_PALX		;SUCCESSFUL PALETTE CREATION
	MOVE	A0,@CURPAL,W		;STUFF THIS IN CURRENT PAL
FGND_PALX:
	MMFM	SP,A0
	RETS

**************************************************************************
*                                                                        *
* STUFF_FGND - STUFF A FOREGROUND OBJECT USING JUST THE FOREGROUND	 *
*		INIT TABLE. EVERYTHING ELSE IS ZERO'D EXCEPT DMA INFO.	 *
* A0  = PTR TO THE OBJECT						 *
* A14 = PTR TO THE BORDER HEADER					 *
* RETURNS								 *
* A14 = POINTING TO WORD AFTER THE BORDER HEADER			 *
*                                                                        *
**************************************************************************
STUFF_FGND
	MMTM	SP,A1,A2,A3,A4,A6,A7,A9,A10

	MOVI	DUMCOLL,A1
	MOVE	A1,*A0(OCVECT),L		;AHH SAFETY!
	CLR	A1
	MOVE	A1,*A0(OXVEL),L
	MOVE	A1,*A0(OYVEL),L
	MOVE	A1,*A0(OZVEL),L
	MOVE	A1,*A0(OZSIZ),L

	MOVE	*A14+,A9,W		;XVAL
	SLL	16,A9
	MOVE	*A14+,A10,W		;YVAL
	SLL	16,A10

	MOVE	*A14+,A1,L
	MOVE	A1,*A0(OIMG),L

	MOVE	*A14+,A4,W		;FLAGS

	MOVE	*A14+,A2,W		;SHOW ME SOME I.D.
	MOVE	A2,*A0(OID),W

	MOVE	@CURPAL,A2,W		;OCONST:OPAL
	MOVE	A2,*A0(OPAL),W

	CALLA	GSAGOF
	CALLA	GANIOF		;ADJUST ANIMATION OFFSET
	SUB	A6,A9		;SUBTRACT X ANIOFF
	SUB	A7,A10		;SUBTRACT Y ANIOFF
	MOVE	A9,*A0(OXVAL),L
	MOVE	A10,*A0(OYVAL),L
	MOVE	A1,*A0(OIMG),L
	MOVE	A3,*A0(OSAG),L
	MOVE	A2,*A0(OSIZE),L
	MOVE	A4,*A0(OFLAGS),L

	MOVE	*A14+,A2,W		;GRAB THE Z FLAG
	JRZ	STUFF_ZPOS
	CMPI	1,A2
	JREQ	STUFF_MZPOS
	CALLA	SET_TZPOS		;FLATTEN THE OBJECT
	JRUC	STUFF_X
STUFF_MZPOS:
	CALLA	SET_MZPOS		;MIDDLE Z POSITION SET
	JRUC	STUFF_X
STUFF_ZPOS:
	CALLA	SET_ZPOS		;BOTTOM Z POSITION SET
	JRUC	STUFF_X

STUFF_X:
	MMFM	SP,A1,A2,A3,A4,A6,A7,A9,A10
	RETS

**************************************************************************
*								         *
* BTYPE_CK - CHECK THE TYPE OF BACKGROUND WE ARE DEALING WITH.		 *
* 									 *
* RETURNS:								 *
* 	A0 = 0 IF THIS IS A WATER DEATH					 *
* 	A0 = 1 IF THIS IS A LAVA DEATH					 *
* 	 Z = A0 = 0							 *
* 	NZ = A0 <> 0							 *
*								         *
**************************************************************************
BTYPE_CK:
	MOVE	@BGND_TYPE,A0,W
	CMPI	BTYPE_LAVA,A0
	JREQ	BTC_LAVA
	CMPI	BTYPE_CRAY,A0
	JREQ	BTC_LAVA
	CLR	A0
	JRUC	BTC_X
BTC_LAVA:
	MOVK	1,A0
BTC_X:
	MOVE	A0,A0
	RETS
	
*UNUSED BACKGROUND CODE COMMENTED OUT 4/2/90 GNP
	.if	0
**************************************************************************
*                                                                        *
* BBOFSCRN - EACH OBJECT IN THE BACKGROUND BLOCK LIST IS CHECKED TO	 *
* 	   SEE IF IT SHOULD GO ON OR OFF THE SCREEN, A 1 IN THE		 *
* 	   DATA AREA OF THE BLOCK MEANS IT IS ON SCREEN.		 *
*                                                                        *
**************************************************************************
BBOFSCRN
	calla	BGND_UD1		;UPDATE PRIMARY BACKGROUND
	calla	BGND_UD2		;UPDATE SECONDARY BACKGROUND		 
	MOVE	@WORLDTL,@PREVWTL,L	;SAVE THESE
	MOVE	@SCRNTL,@PREVSTL,L
BBOFSL
	SLEEP	1
*DETERMINE IF ENOUGH CHANGE HAS OCCURED TO MERIT UPDATE
	MOVK	10,A2			;YES, IT'S BUFFER MAN
	MOVE	@WORLDTL,A0,L		;CHECK WORLDTL DELTA Y,X
	MOVE	@PREVWTL,A1,L
	SUBXY	A0,A1
	MOVY	A1,A0
	ZEXT	A1
	SRA	16,A0
	ABS	A0
	ABS	A1
	CMP	A2,A0
	JRHI	BBOFSCRN		;ENOUGH DELTA Y
	CMP	A2,A1
	JRHI	BBOFSCRN		;ENOUGH DELTA X
	MOVE	@SCRNTL,A0,L		;CHECK SCRNTL DELTA Y,X
	MOVE	@PREVSTL,A1,L
	SUBXY	A0,A1
	MOVY	A1,A0
	ZEXT	A1
	SRA	16,A0
	ABS	A0
	ABS	A1
	CMP	A2,A0
	JRHI	BBOFSCRN		;ENOUGH DELTA Y
	CMP	A2,A1
	JRHI	BBOFSCRN		;ENOUGH DELTA X
	JRUC	BBOFSL	

**************************************************************************
*								         *
* BGNDHGHT - ROUTINE TO DETERMINE THE HEIGHT OF THE CURRENT BACKGROUND	 *
* 		AT A GIVEN X COORDINATE.				 *
* A0 = XPOS TO CHECK HEIGHT						 *
* RETURNS:								 *
* 									 *
* 	A0 = Y HEIGHT OF PRIMARY BACKGROUND AT THAT XPOS		 *
* 	A0 = 0 IF XPOS IS INVALID					 *
*								         *
**************************************************************************
BGNDHGHT:
	mmtm	SP,A1,A2,A3,A4,A7,A8,A9,A10,A11
	move	A0,A1

	clr	A10			;init packed y:x starting position
	clr	A11

	move	@BAKMODS,A0,L		;* A0- ptr to the module list
ModLp0:	
	move	*A0+,A8,L		;load module ptr
	cmpi	>FFFFFFFF,A8
	jrz	ModX0			;end of the module tbl
	move	*A8+,A9,L		;load packed y:x size

	move	*A0+,A3,W		;X start position
	zext	A3,W
	cmpi	BLSTSTRT,A3
	jrnz	NotLstStrtX
	move	A11,A3		
	subxy	A9,A3
	jruc	GotNewX0
NotLstStrtX:
	cmpi	BLSTEND,A3
	jrnz	GotNewX0
	move	A11,A3
GotNewX0:
	move	*A0+,A4,W		;Y start position
	zext	A4,W
	cmpi	BLSTSTRT,A4
	jrnz	NotLstStrtY
	move	A11,A4		
	subxy	A9,A4
	jruc	GotNewY0
NotLstStrtY:
	cmpi	BLSTEND,A4
	jrnz	NotLstEndY
	move	A11,A4
	jruc	GotNewY0
NotLstEndY:
	sll	16,A4
GotNewY0:
	movy	A4,A3
	move	A3,A10

;	cmpxy	A10,A1
;	jrv	ModX0 	;jump to exit loop if Mod start X > X sought

	;if Mod end X < X sought keep searching mod list
	move	A10,A11
	addxy	A9,A11	;A11 is module y:x end

	move	*A8+,A9,W		;load # of blocks
	add	A9,A7		;A7 is new BAKBITS ptr
	cmpxy	A11,A1
	jrnv	ModLp0		;skip if Ax < Bx

	move	A10,A0
	srl	16,A0
	jruc	GotHGHT

ModX0:
	clr	A0
GotHGHT:
	mmfm	SP,A1,A2,A3,A4,A7,A8,A9,A10,A11
	rets

**************************************************************************
*								         *
* BAK_END - ROUTINE TO SCAN A MODULE LIST AND RETURN ITS [Y,X] ENDING	 *
* 		WORLD COORDINATE.					 *
* A0 = MODULE LIST TO SCAN						 *
* RETURNS:								 *
* A0 = [Y,X] WORLD ENDPOINT OF MODULE					 *
*								         *
**************************************************************************
BAK_END:
	mmtm	SP,A3,A4,A8,A9,A10,A11

	clr	A10	;clr packed y:x starting position
	clr	A11
WEModLp:	
	move	*A0+,A8,L		;load module ptr
	cmpi	>FFFFFFFF,A8
	jrz	WEModX			;end of the module tbl
	move	*A8+,A9,L		;load packed y:x size

	move	*A0+,A3,W		;X start position
	zext	A3,W
	cmpi	BLSTSTRT,A3
	jrnz	WENotLastStartX
	move	A11,A3		
	subxy	A9,A3
	jruc	WEGotNewX
WENotLastStartX:
	cmpi	BLSTEND,A3
	jrnz	WEGotNewX
	move	A11,A3
WEGotNewX:
	move	*A0+,A4,W		;Y start position
	zext	A4,W
	cmpi	BLSTSTRT,A4
	jrnz	WENotLastStartY
	move	A11,A4		
	subxy	A9,A4
	jruc	WEGotNewY
WENotLastStartY:
	cmpi	BLSTEND,A4
	jrnz	WENotLastEndY
	move	A11,A4
	jruc	WEGotNewY
WENotLastEndY:
	sll	16,A4
WEGotNewY:
	movy	A4,A3
	move	A3,A10
	
	move	A10,A11
	addxy	A9,A11	;A11 is module y:x end
	jruc	WEModLp

WEModX:
	move	A11,A0
	mmfm	SP,A3,A4,A8,A9,A10,A11
	rets

**************************************************************************
*								         *
* BAK_START - ROUTINE TO FIND THE [Y,X] WORLD STARTING COORDINATE OF	 *
* 		A GIVEN MODULE LIST.					 *
* A0 = MODULE LIST							 *
* RETURNS:								 *
* A0 = [Y,X] STARTING POINT						 *
*								         *
**************************************************************************
BAK_STRT:
	mmtm	SP,A3,A4,A8,A9,A11

	clr	A11
	move	*A0+,A8,L		;load module ptr
	cmpi	>FFFFFFFF,A8
	jrz	WSModX			;end of the module tbl
	move	*A8+,A9,L		;load packed y:x size

	move	*A0+,A3,W		;X start position
	zext	A3,W
	cmpi	BLSTSTRT,A3
	jrnz	WSNotLastStartX
	move	A11,A3		
	subxy	A9,A3
	jruc	WSGotNewX
WSNotLastStartX:
	cmpi	BLSTEND,A3
	jrnz	WSGotNewX
	move	A11,A3
WSGotNewX:
	move	*A0+,A4,W		;Y start position
	zext	A4,W
	cmpi	BLSTSTRT,A4
	jrnz	WSNotLastStartY
	move	A11,A4		
	subxy	A9,A4
	jruc	WSGotNewY
WSNotLastStartY:
	cmpi	BLSTEND,A4
	jrnz	WSNotLastEndY
	move	A11,A4
	jruc	WSGotNewY
WSNotLastEndY:
	sll	16,A4
WSGotNewY:
	movy	A4,A3
	move	A3,A0

WSModX:
	mmfm	SP,A3,A4,A8,A9,A11
	rets

	.endif

	.DATA

**************************************************************************
*								         *
* 	FOREGROUND TABLES						 *
*								         *
**************************************************************************
FOREGROUNDV2:
	.LONG	[SKYTOPOF+61,165],VOLCTIP
	.WORD	DMAWNZ,JUNKOID,0
DUMFGND:
	.LONG	0
	
**************************************************************************
*                                                                        *
* 	BACKGROUND TABLES FOR EACH WAVE					 *
*                                                                        *
**************************************************************************
BACKGROUND1:
	.LONG	WAVE1BMOD
	.WORD	5,6+SKYTOPOF
	.LONG	0FFFFFFFFH

BACKGROUND2:
	.LONG	WAVE2BMOD
	.WORD	5,5+SKYTOPOF
	.LONG	0FFFFFFFFH

LAVABGND1:
	.LONG	WAVEV2BMOD
	.WORD	6,6+SKYTOPOF
	.LONG	0FFFFFFFFH

LAVABGND2:
	.LONG	WAVEV1BMOD
	.WORD	6,6+SKYTOPOF
	.LONG	0FFFFFFFFH

BACKGROUNDE:
	.LONG	TROGENTBMOD
	.WORD	5,6+SKYTOPOF
	.LONG	0FFFFFFFFH

BACKGROUNDC:
	.LONG	CLUBLANDBMOD
	.WORD	5,6+SKYTOPOF
	.LONG	0FFFFFFFFH

BACKGROUNDW:
	.LONG	WEELANDBMOD
	.WORD	5,6+SKYTOPOF
	.LONG	0FFFFFFFFH

BACKGROUNDS:
	.LONG	SPRING2BMOD
	.WORD	5,6+SKYTOPOF
	.LONG	0FFFFFFFFH

BACKGROUNDCRAY:
	.LONG	CRAYOLABMOD
	.WORD	5,6+SKYTOPOF
	.LONG	0FFFFFFFFH

BACKGROUNDDSRT:
	.LONG	DESERT1BMOD
	.WORD	5,6+SKYTOPOF
	.LONG	0FFFFFFFFH

BACKGROUNDX2:
	.LONG	WAVEX2BMOD
	.WORD	5,5+SKYTOPOF
	.LONG	0FFFFFFFFH

BACKGROUNDX3:
	.LONG	WAVEX3BMOD
	.WORD	5,5+SKYTOPOF
	.LONG	0FFFFFFFFH

BACKGROUNDX5:
	.LONG	WAVEX5BMOD
	.WORD	6,10+SKYTOPOF
	.LONG	0FFFFFFFFH

BACKGROUNDX6:
	.LONG	WAVEX6BMOD
	.WORD	5,5+SKYTOPOF
	.LONG	0FFFFFFFFH

**************************************************************************
*								         *
* 		  MISCELLANEOUS BACKGROUND DEFINITIONS			 *
*								         *
**************************************************************************
TROGCAVE1:
	.LONG	CAVE1BMOD
	.WORD	-3,-6+SKYTOPOF
	.LONG	0FFFFFFFFH

TROGCAVE2:
	.LONG	CAVE1BMOD
	.WORD	-3,0
	.LONG	0FFFFFFFFH

****TROGBLACKBOARD:
****	.LONG	BLACKBO1BMOD
****	.WORD	48,89
****	.LONG	0FFFFFFFFH

CREDITBGND:
	.LONG	CREDITS1BMOD
	.WORD	0,5
	.LONG	0FFFFFFFFH

