/*	MAIN linker command file					*/
-e SETUP			/* entry point of program		*/
-f 0xFFFF			/* fill unspecified memory with value	*/
-o f:\video\trog\TROGKURT.rlo	/* specify output file			*/
-m f:\video\trog\TROGKURT.map	/* map file				*/
-r				/* relocatable file			*/
TROGSCOR.OBJ		/* SCORE AREA MAINTENANCE		*/
TROGATT.OBJ		/* ATTRACT MODE				*/
TROGMENU.OBJ		/* MENU PROCESSING			*/
TROGJUNK.OBJ		/* RANDOM ROUTINES			*/
TROGHSTD.OBJ		/* HIGHSCORE TABLE			*/
TROGCOIN.OBJ		/* COINAGE HANDLING ROUTINES		*/
TROGFADE.OBJ		/* TODD'S PALETTE FADER			*/
TROGCAVE.OBJ		/* TROG CAVE SHOWS			*/
TROGCAT.OBJ		/* CATAPULT				*/
TROGHAUS.OBJ		/* TRANSPORT HOUSE			*/
TROGWORD.OBJ		/* WORD SUBSTITUTIONS FOR STRINGS	*/
SYSFONT.OBJ		/* SYSTEM FONT IN PROGRAM ROM		*/
TROGDUTL.OBJ		/* TROG DIAG UTILITIES			*/
TROGDTST.OBJ		/* ACTUAL DIAGNOSTICS			*/
/*TROGPRNT.OBJ*/	/* DEBUG PRINTER			*/
TROGADJ.OBJ		/* GAME ADJUSTMENTS, LINK THIS LAST!!!	*/

MEMORY        			/* set up memory for sdb board */
{
 SCRATCH	: org = 0x01000000,	len = 0x100000
 ROM		: org = 0xFFE00000,	len = 0x200000 
 TRAP31		: org = 0xFFFFFC00,	len = 0x400 
 IROM		: org = 0x02000000,	len = 0x400000 
}

SECTIONS       /* linker sections directive */
 {
	VECTORS:  {} 	> TRAP31
	IMAGES:   {}    > IROM
	GROUP:
	      {
		FIXED: {}
		OFIXED: {}
		NFIXED: {}
	       .BSS: {}
	       .bss: {}
	      } > SCRATCH

	GROUP:
	      {	
	       .text: {}
	       .TEXT: {}
	       .data: {}
	       .DATA: {}
	      } > ROM	

 }
                                                        
