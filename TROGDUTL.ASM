   	.MLIB	"TROGMACS.LIB"
	.FILE	'TROGDUTL.ASM'
	.TITLE	"TROG DIAG UTILITY ROUTINES"
	.WIDTH	132
	.OPTION	B,D,L,T
	.MNOLIST

	.INCLUDE	"MPROCEQU.ASM"	;MPROC equates
	.INCLUDE	"DISPEQU.ASM"	;Display processor equates
	.INCLUDE	"GSPINC.ASM"	;GSP assembler equates
	.INCLUDE	"SYSINC.ASM"	;Zunit system equates
	.INCLUDE	"TROGEQU.ASM"
	.INCLUDE	"IMGTBL.GLO"
	.INCLUDE	"STRING.H"
	.INCLUDE	"TROGSEQU.ASM"

	.REF	SYSFONT,WAIT_BUT
	.DEF	CIRCLE, HVLINE, STRING, RECTANGLE, POINT, DSCRCLR, INITCOLR
	.DEF	STRINGCENTER

        .TEXT
        .EVEN

;****************************************************************************
;* INITCOLR: INITIALIZE COLORS; ROUTINE LOADS PALETTE 0 WITH THE COLOR      *
;*           PALETTE USED BY DIAGNOSTIC TESTS.                              *
;****************************************************************************

INITCOLR:
;
;	KLUDGE TO LOAD DUXPAL IN PALETTE SLOT 0
;

	MOVI	COLRAM,A0,L		; PALETTE LOCATION
	MOVI	DUXPAL,A1,L
	MOVE	*A1+,A2,W		; LENGTH OF PALETTE
LPLP1
	MOVE	*A1+,*A0+,W
	DSJS	A2,LPLP1		; KEEP ON CHUGGIN, BABY

        CLR  A14
        MOVE A14, @CMAPSEL

        FRET B5

;****************************************************************************
;* POINT: FUNCTION DISPLAYS A POINT OF ANY COLOR.                           *
;*                                                                          *
;*            ENTRY: A0 = XY SCREEN ADDRESS OF THE POINT                    *
;*                   A1 = COLOR VALUE                                       *
;*                   B6 = RETURN ADDRESS                                    *
;*                                                                          *
;*            USES:  A0, A1, B2, B3, B4, B6, B10                            *
;****************************************************************************

POINT:

        MOVI SCRN_PTCH, DPTCH
        CLR  OFFSET

        LMO  DPTCH, B10
        MOVE B10, @CONVDP

        PIXT A1, *A0.XY
  
        FRET B6

;****************************************************************************
;* RECTANGLE: FUNCTION DISPLAYS A RECTANGLE OF ANY COLOR.                   *
;*                                                                          *
;*            ENTRY: A0 = XY SCREEN ADDRESS OF UPPER LEFT CORNER            *
;*                   A1 = XY RECTANGLE DIMENSIONS                           *
;*                   A2 = COLOR VALUE                                       *
;*                                                                          *
;*                   B6 = RETURN ADDRESS                                    *
;*                                                                          *
;*            USES:  A0, A1, A2, B2, B3, B4, B6, B7, B9, B10                *
;****************************************************************************

RECTANGLE:

        MOVI SCRN_PTCH, DPTCH
        CLR  OFFSET

        LMO  DPTCH, B10
        MOVE B10, @CONVDP

        MOVE A2, COLOR1
        MOVE A0, DADDR
        MOVE A1, DYDX

        FILL  XY

        FRET B6

;****************************************************************************
;* LINE: FUNCTION DRAWS HORIZONTAL OR VERTICAL LINES OF ANY COLOR.          *
;*                                                                          *
;*            ENTRY: A0 = BEGINNING XY SCREEN ADDRESS                       *
;*                   A1 = ENDING XY SCREEN ADDRESS                          *
;*                   A2 = COLOR VALUE                                       *
;*                                                                          *
;*                   B6 = RETURN ADDRESS                                    *
;*                                                                          *
;*            USES:  A0, A1, A2, A3, A4, B3, B4, B6, B9, B10                *
;****************************************************************************

HVLINE:

        MOVI SCRN_PTCH, DPTCH
        CLR  OFFSET

        LMO  DPTCH, B10
        MOVE B10, @CONVDP

        MOVE A2, COLOR1

        MOVK  1H, A2                    ; DRAV DX: ASSUME HORIZONTAL LINE

        MOVE  A0, A3                    ; DETERMINE (P2 > P1) OR (P2 < P1)
        CVXYL A3, A3

        MOVE  A1, A4
        CVXYL A4, A4

        CMP  A3, A4                     ; IF (P2 < P1) ~(INCREMENT)
        JRP  $100

        NEG  A2                         ; INCREMENT IS A SIGNED WORD
        ZEXT A2, 0

$100:   CMPXY A0, A1                    ; IF VERTICAL LINE
        JRZ   $110                      ; DRAV DX -> DRAV DY
        SLL   16, A2
        
$110:   DRAV  A2, A0                    ; DRAW LINE
        CMPXY A0, A1
        JRNN  $110
        JRNZ  $110

        FRET B6

;****************************************************************************
;* STRING: FUNCTION DISPLAYS AN ASCIZ STRING OF ANY COLOR EITHER VERTICALLY *
;*         OR HORIZONTALLY.                                                 *
;*                                                                          *
;*            ENTRY: A0 = STARTING STRING ADDRESS                           *
;*                   A1 = XY SCREEN ADDRESS                                 *
;*                   A2 = DIRECTION                                         *
 ;*                   A3 = COLOR                                             *
;*                                                                          *
;*                   B6 = RETURN ADDRESS                                    *
;*                                                                          *
;*            USES: A0 - A6, B0 - B4, B6 - B14                              *
;****************************************************************************

STRING:

        MOVI SCRN_PTCH, DPTCH
        CLR  OFFSET

        LMO  DPTCH, B10
        MOVE B10, @CONVDP

        MOVE A3, COLOR1        
        CLR  COLOR0

        SETF 8, 0, 0

$200:   MOVE *A0+, A4                   ; GET CHARACTER
        JRZ  $230                       ; QUIT IFF NULL

        SUBK 32, A4                     ; GET POINTER TO CHARACTER HEADER
        SLL  5H, A4
        ADDI SYSFONT, A4, L
        MOVE *A4, A4, 1

        MOVE *A4+, A5, 1                ; CHAR DIMENSIONS
        MOVE  A5, DYDX

        CLR  A6                         ; A6 = CHAR WIDTH
        MOVX A5, A6

        ADDK 7, A6                      ; ROUND UP WIDTH TO INTEGRAL NUMBER
        SRL  3, A6                      ; OF BYTES = SOURCE PITCH
        SLL  3, A6
        MOVE A6, SPTCH

        MOVE *A4, A6, 1                 ; CHAR DATA
        MOVE  A6, SADDR
        
        MOVE A1, DADDR

        PIXBLT B,XY

        CLR  A6
        MOVE A2, A2
        JRZ  $210

        MOVY A5, A6                      ; A1 += (CHAR HEIGHT + SPACING)
        SRL  16, A6                      ; DIRECTION = DOWN
        ADDK 1H, A6
        SLL  16, A6
        ADD  A6, A1
        JRUC $200
        
$210:   MOVX A5, A6                      ; A1 += (CHAR WIDTH + SPACING)
        ADDK 2H, A6                      ; DIRECTION = RIGHT
        ADD  A6, A1
        JRUC $200

$230:   SETF 16, 1, 0
        FRET B6






STRINGCENTER:
	SETF 	8, 0, 0
	CLR	A1
	MOVE	A0,A2
SPLLOOP
	MOVE 	*A0+, A4 		; GET THE CHAR
        JRZ	SPLEND			; END OF STRING

        SUBK 	32, A4                     ; GET POINTER TO CHARACTER HEADER
        SLL  	5H, A4
        ADDI 	SYSFONT, A4, L
        MOVE 	*A4, A4, 1

        MOVE 	*A4+, A5, 1                ; CHAR DIMENSIONS
        MOVE  	A5, DYDX

        CLR  	A6                         ; A6 = CHAR WIDTH
        MOVX 	A5, A6

        ADDK 	7, A6                      ; ROUND UP WIDTH TO INTEGRAL NUMBER
        SRL  	3, A6                      ; OF BYTES = SOURCE PITCH
        SLL  	3, A6
        
	MOVX 	A5, A6                      ; A1 += (CHAR WIDTH + SPACING)
        ADDK 	2H, A6                      ; DIRECTION = RIGHT
        ADD  	A6, A1
        JRUC	SPLLOOP

SPLEND
	SETF 	16, 1, 0
	MOVE	A2,A0			; RESTORE STRING ADDRESS
	SRL	1,A1
	MOVI	200,A2
	SUB	A1,A2
	MOVE	A2,A1
        FRET 	B6












;****************************************************************************
;* CIRCLE: FUNCTION DRAWS OUTLINE OR FILLED CIRCLES.                        *
;*                                                                          *
;*       ENTRY: A0 = radius                                                 *
;*              A1 = center  (Y:X)                                          *
;*              A6 = <00:15> = color                                        *
;*              A6 = <15:31> = fill: 0=no fill, 1=fill                      *
;*                                                                          *
;*       USES:  A0 - A8, B0, B10                                            *
;**************************************************************************** 

CIRCLE:

        movi  plot8,a7               ; assume no fill
        btst  16,a6
        jrz   CIRC0
        movi  fill4,a7
CIRC0:
        movi  SCRN_PTCH,DPTCH        ; Restore screen pitch and convdp
        MOVI  13h,B10                ; THIS IS FASTER
        MOVE  B10,@CONVDP
        MOVE  A6,COLOR1
        movi  [1,0],DYDX                 ; Y width always 1

        clr   a2                      ; x = 0
        move  a0,a3                   ; y = r
        move  a0,a4
        sll   1,a4
        subk  3,a4
        neg   a4                     ; d = 3 - 2*r
cloop:
        cmp   a3,a2                  ; if x > y, we are done
        jrgt  done

        MOVE  A7, B0                 ; PLOT ROUTINE
        EXGPC B0

        move  a2,a5                  ; x -> a5
        btst  31,a4
        jrz   dpos                   ; branch if d is positive

;             d negative

        sll   2,a5                   ; 4*x -> a5
        addk  6,a5                   ; 4*x+6 -> a5
        jruc  cont

;             d positive

dpos:                

        sub   a3,a5                  ; x-y -> a5
        sll   2,a5                   ; 4*(x-y) -> a5
        addk  10,a5                  ; 4*(x-y)+10 -> a5
        subk  1,a3                   ; y = y - 1

cont:
        add   a5,a4                  ; d = d + a5
        addk  1,a2                   ; x = x + 1
        jruc  cloop

done:   FRET B6

plot8:
        move  a3,a5
        neg   a5                   ; -y into a5; +y in a3
        sll   16,a5
        sll   16,a3
        movx  a2,a5                ; a3 = (y:x)
        movx  a2,a3                ; a5 = (-y:x)

        movk  2,a8
put4:
        move  a1,a0                ; center (Y:X) in a0
        addxy a3,a0                ; (cx+x),(cy+y)
        pixt  a6,*a0.XY
        move  a1,a0                ; center (Y:X) in a0
        addxy a5,a0                ; (cx+x),(cy-y)
        pixt  a6,*a0.XY
        move  a1,a0                ; center (Y:X) in a0
        subxy a3,a0                ; (cx-x),(cy-y)
        pixt  a6,*a0.XY
        move  a1,a0                ; center (Y:X) in a0
        subxy a5,a0                ; (cx-x),(cy+y)
        pixt  A6,*a0.XY
        rl    16,a3
        rl    16,a5                ; transpose x and y        
        dsj   a8,put4
        sra   16,a3                ; restore y

        FRET B0

fill4:
        move  a2,b10               ; x
        sll   1,b10                ; 2x
        movx  b10,DYDX             ; delta x = 2x
        move  a3,a5
        neg   a5                   ; -y into a5      +y in a3
        sll   16,a5
        sll   16,a3
        movx  a2,a5                ; a3 = (y:x)
        movx  a2,a3                ; a5 = (-y:x)
        movk  2,a8
put2:        
        move  a1,a0
        subxy a5,a0
        move  a0,DADDR
        fill  XY

        move  a1,a0
        subxy a3,a0
        move  a0,DADDR
        fill  XY
        rl    16,a3                ; a3 = (x:y)
        rl    16,a5                ; transpose x and y        
        clr   a6
        subxy a5,a6
        move  a6,a5                ; a5 = (-x:y)
        move  a3,b10               ; y
        sll   1,b10                ; 2y
        movx  b10,DYDX             ; delta x = 2y
        dsj   a8,put2
        sra   16,a3                ; restore y

        FRET B0

;****************************************************************************
;* ADV_BUTTON: FUNCTION READS THE STATE OF THE ADVANCE BUTTON.              *
;*                                                                          *
;*          ENTRY -- B6 = RETURN ADDRESS.                                   *
;*          EXIT  -- C  = SET IFF BUTTON PRESSED.                           *
;*          USES  -- B2                                                     *
;****************************************************************************

ADV_BUTTON:

;       ===========================
;       | ENTRY WITH BUTTON DOWN  |
;       ===========================

        MOVE @COINS, B2
        BTST 04, B2
        JRNZ ADVANCE_FALSE

;        PAUSE ADV_UP_TIME, B2		;ELIMINATE NOISE POSSIBILITY	

        MOVE @COINS, B2
        BTST 04, B2
        JRNZ ADVANCE_FALSE

ADVANCE_TRUE:

        SETC
        FRET B6

ADVANCE_FALSE:

        CLRC
        FRET B6

;****************************************************************************
;* ADV_BUTTON_2: FUNCTION READS THE STATE OF THE ADVANCE BUTTON. ROUTINE IS *
;*               IDENTICAL TO ADV_BUTTON EXCEPT THAT IT MAY BE CALLED ONLY  *
;*               WITHIN THE ERROR LED ROUTINE.                              *
;*                                                                          *
;*               ENTRY -- B3 = RETURN ADDRESS.                              *
;*               EXIT  -- C  = SET IFF BUTTON PRESSED.                      *
;*               USES  -- B2                                                *
;****************************************************************************

ADV_BUTTON_2

        MOVE @COINS, B2
        BTST 04, B2
        JRNZ ADVANCE_FALSE_2

;        PAUSE ADV_UP_TIME, B2		;ELIMINATE NOISE POSSIBILITY	

        MOVE @COINS, B2
        BTST 04, B2
        JRNZ ADVANCE_FALSE_2
        
ADVANCE_TRUE_2:

        SETC
        FRET B3

ADVANCE_FALSE_2:

        CLRC
        FRET B3

**************************************************************************
*                                                                        *
* ADVANCE_WAIT: FUNCTION RETURNS WHEN THE ADVANCE BUTTON HAS GONE FROM   *
*			OFF TO ON, WITH DEBOUNCE.			 *
* 	USE THIS WHEN WAITING ON THE ADVANCE BUTTON TO CONTINUE.         *
*          ENTRY -- B6 = RETURN ADDRESS.                                 *
*          EXIT  -- C  = SET IFF BUTTON PRESSED.                         *
*          USES  -- B2                                                   *
*                                                                        *
**************************************************************************
ADVANCE_WAIT:
        MOVE @COINS, B2
        BTST 04, B2
        JRZ ADVANCE_WAIT     	;BR = SWITCH IS DOWN
;        PAUSE ADV_UP_TIME, B2	;DEBOUNCE	
        MOVE @COINS, B2
        BTST 04, B2
        JRZ ADVANCE_WAIT	;BR = SPURIOUS SWITCH UP
ADVW1
        MOVE @COINS, B2
        BTST 04, B2
        JRNZ ADVW1		;BR = SWITCH IS UP 	
;        PAUSE ADV_UP_TIME, B2	;DEBOUNCE	
        MOVE @COINS, B2
        BTST 04, B2
        JRNZ ADVW1		;BR = SWITCH IS UP 	
        FRET B6

*SCRCLR - CLEAR ENTIRE BIT MAP
*	USES:B2,B3,B4	CALL WITH B6
DSCRCLR
	CLR	B2
	MOVI	SCREEN,B3,L
	MOVI	(SCRNE-SCREEN)/32,B4,L
SCRLP	MOVE	B2,*B3+,L
	DSJS	B4,SCRLP
	FRET	B6

