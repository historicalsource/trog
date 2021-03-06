*
*GLOBAL EQUATES FROM DUXDISP
	.GLOBAL	OFREE,OBJLST,BAKLST,BAK2LST,DISPLAYON,SCRNRELV
	.GLOBAL	OINIT,GETOBJ,INSOBJ,DELOBJ,DISPLAY,ADDOBJ,KILOBJ,OBJSTR,DISPH
	.GLOBAL	ANI,STFOBJ,MAKE_OBJ,SCRTST,SCRTSTG,GSAGOF,BKGSAGOF,GANIOF
	.GLOBAL	YZSORT,INSB2OBJ,INSBOBJ,DELB2OBJ,DELBOBJ,KILB2OBJ,KILBOBJ
	.GLOBAL	PULLB2OBJ,PULLBOBJ,PULLOBJ,GANISAG,ADJSTWTL,CLIPOBJ
	.GLOBAL	QDMA,QDMAN,GETANIXY
	.GLOBAL	SCROLLX,SCROLLY,WORLDTLX,WORLDTLY,WORLDTL,BAK2TLX,BAK2TLY
	.GLOBAL	SCRNTL,SCRNLR,GSCRNREL,ADJNEWTL,DELSOBJ,DELSHAD
	.GLOBAL OBJSTR,SCREENTL,SCREENLR,QSYNC,DMAQCUR,DMAQCNT
	.GLOBAL BOTQ0CNT,BOTQ1CNT,TOPQ0CNT,TOPQ1CNT,BOTQ0FLG,BOTQ1FLG
	.GLOBAL TOPQ0FLG,TOPQ1FLG,BOTQ0,BOTQ1,TOPQ0,TOPQ1,STOPOBJS
	.GLOBAL	FREEOBJ,FREESOBJ,FREEOBJE,PULLSOBJ,INSSOBJ
	.GLOBAL	EXISTOBJ,DMAINT
	.GLOBAL	DISPQT,STFPOST,QSCRTST,DELETE_OBJ,DELETE_OBJ_SUPP
	.GLOBAL	CHANGOID
	.GLOBAL	SCREXP32,KILOBJ_XA8, KILOBJ_ALL
	.GLOBAL	ADDSUPP,DELSUPP,ISSUPPID,ISSUPP,CNTSUPP
	.GLOBAL	INSERT_SUPP,INSERT_OBJ,INSERT_OBJ_SUPP,DELETE_SUPP
	.GLOBAL	INITPAL,INITBPAL,GPALOBJ,GBPALOBJ,GPALOBJSTF
	.GLOBAL	OBJ_ON,OBJ_OFF,OBJ_TO_PNT,FIND_SUPP_LAST, ISSUPPANI
	.GLOBAL	COPY_OBJ, GETANIX, DELETE_SUPP_ID
	.GLOBAL	CHANGEZPOS, GETANIXY_PACKED, OBJTOPNT
	.GLOBAL	KILL_OBJECTS, OBJECTS_ON, OBJECTS_OFF, DELETE_SLAVES
	.GLOBAL	ADD_SLAVE, MULTI_MAKE, STORE_ZVAL, CREATE_OBJ, IS_OBJ_OFF

	.GLOBAL	DECZPOS

*
*GLOBAL EQUATES IN DUXUTIL
	.GLOBAL	DFRMGRND, GPALOBJ, DELSUPP
*
*EXTERNAL REFERENCES TO THE PALETTE ALLOCATOR
	.GLOBAL	DELPAL, DELETE_PAL
*
*GLOBAL EQUATES OF A MISCELLANEOUS NATURE
	.GLOBAL	CURPAL, DUMCOLL, PAUSE_GAME
*
*CONSTANTS
*
SCRNST	.SET	[40,0]	 	;TOP LEFT OF SCREEN
SCRNEND .SET	[256,400]	;BOTTOM RIGHT OF SCREEN
SCRNMID	.SET	[148,200]	;MIDPOINT OF SCREEN

SHADID	.EQU	>0FFF		;SHADOWS ARE HIGH PRI
*
*OBJECT INITIALIZATION TABLE
INITXPOS .EQU	0H
INITYPOS .EQU	20H
INITZPOS .EQU	40H
INITZVEL .EQU	50H
INITIMG  .EQU	060H
INITZSIZ .EQU	080H
INITCVEC .EQU	0A0H
INITFLAG .EQU	0C0H
INITOID  .EQU	0D0H
INITSIZE .EQU	0E0H
*
*	OBJECT BLOCK LAYOUT
*
*struct OBJ
OLINK	.SET   	0   	;UHL 	Link to next object block		(32)
OSLINK	.SET	20H	;UHL 	SPECIAL LINK TO OBJECTS IN CLASS	(32)
OXVEL	.set   	40h    	;UHL 	X VELOCITY 16.16			(32)
OYVEL	.set   	60h   	;UHL 	Y VELOCITY 16.16			(32)
OXVAL	.set   	80h	;UHL 	X POSITION				(32)
OXPOS	.set   	90h	;	Integer portion of X position		(16)
OYVAL	.set   	0A0h   	;UHL 	Y POSITION			 	(32)
OYPOS	.SET   	0B0h   	;	Integer portion of Y position		(16)
OZVAL	.SET	0C0H	;UHL 	Z POSITION				(32)
OZPOS	.SET   	0D0h   	; 	Integer portion of z position	   	(16)
OZVEL	.set   	0E0h   	;UHL 	Z VELOCITY 				(32)
OFLAGS	.set   	100H   	;UHW 	DMA CONTROL				(16)
OFSET	.SET	110H	;UHW	PRECOMPUTED DMA OFFSET			(16)
OSAG	.SET   	120H   	;UHL 	SOURCE ADDRESS (UNCLIPPED, ADJUSTED FOR FLIPS)		(32)
OSIZE	.SET   	140H	;UHL	[H,W] OF OBJECT 			(32)
OSIZEX	.EQU	140H	;	X SIZE OF OBJECT			(16)
OSIZEY	.EQU	150H	;	Y SIZE OF OBJECT			(16)
OPAL	.set   	160h   	;UHW	PALETTE # OF OBJECT			(16)
OCONST	.SET	170H	;UHW	CONSTANT COLOR SUBSTITUTE		(16)
OIMG	.set   	180h   	;UHL	Pointer to image data table		(32)
OID	.set   	1A0H   	;UHW	Object ID				(16)
OZSIZ	.SET   	1B0H 	;UHL	[PLUS,MINUS] Z THICKNESS   		(32)
OZMINUS	.SET   	1B0H 	;	Thickness along minus Z			(16)
OZPLUS	.SET   	1C0H 	;	Thickness along plus  Z			(16)
OCVECT	.set   	1D0H   	;UHL	Link to collision handler     		(32)
OPLINK	.set   	1F0H   	;UHL	Link to controlling process   		(32)
ODMAXY	.SET	210H	;UHL	[Y,X] SCREEN COORDINATE OF OBJECT	(32)
ODMAX	.EQU	210H	;	X COORDINATE				(16)
ODMAY	.EQU	220H	;	Y COORDINATE				(16)
OXCLIP	.SET	230H	;UHW	TOTAL X PRECLIP				(16)
OSHAD	.SET	240H	;UHL	Link to object shadow			(32)
OATTRIB .SET	260H	;UHW	Object attribute word			(16)
OMLINK	.SET	270H	;UHL	Multi-part object link			(32)
OBSIZ	.SET   	290H   	;Object Block Size
*endstruct
NOBJ	.SET   	330   	; OBJECTS TO DISPLAY
*
BQCELL	.SET	>A0 	;SIZE OF DMA QUEUE ELEMENT

**************************************************************************
*								         *
* 	OFLAGS DEFINITIONS						 *
*								         *
**************************************************************************
M_WRZERO 	.EQU	0001H	;Write Zero Data
M_WRNONZ 	.EQU	0002H  	;Write Non-Zero Data
M_CONZER 	.EQU	0004H  	;Replace Zero Data with constant
M_CONNON 	.EQU	0008H  	;Replace Non-Zero Data with constant
M_CONST		.EQU	000CH  	;any constant data replacement
M_FLIPH		.EQU	0010H  	;Flip Horizontally 
M_FLIPV		.EQU	0020H  	;Flip Vertically 
M_NOSCROLL	.EQU	0100H	;Not affected by scroll velocities, screen coordinates.
M_PZPLUS	.EQU	0200H	;TAKE Z VALUE FROM RAM LOC. PREVZ AND ADD 1		
M_PIXSCAN 	.EQU	0400H	;IF=1 O.K. TO PIXEL SCAN WITH THIS OBJECT
M_NOCOLL 	.EQU	0800H	;IF=1 OBJECT NOT COLLIDABLE
M_SLAVE		.EQU	1000H	;THIS IS A SLAVE OBJECT
M_NOPAUSE	.EQU	2000H  	;ADD VELOCITIES EVEN IN PAUSE MODE
M_MASTER	.EQU	4000H	;MASTER OBJECT FLAG
*
*BIT POSITIONS FOR OFLAGS
B_WRZERO	.EQU   	0
B_WRNONZ	.EQU   	1
B_CONZER	.EQU   	2
B_CONNON	.EQU   	3
B_FLIPH		.EQU  	4
B_FLIPV		.EQU  	5
B_NOSCROLL	.EQU	8
B_PZPLUS	.EQU	9
B_PIXSCAN	.EQU	10	
B_NOCOLL	.EQU	11
B_SLAVE		.EQU	12
B_NOPAUSE	.EQU  	13
B_MASTER	.EQU	14
                                                                                                                                              
