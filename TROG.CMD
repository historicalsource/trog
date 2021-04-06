/*	MAIN linker command file					*/
-e SETUP			/* entry point of program		*/
-f 0xFFFF			/* fill unspecified memory with value	*/
-o f:\video\trog\TROG.out	/* specify output file			*/
-m f:\video\trog\TROG.map	/* map file				*/
-s				/* Kill the symbol table		*/
TROGDISP.OBJ		/* IMAGE HANDLER		*/
TROGRAM.OBJ		/* RAM ALLOCATONS		*/
TROG.OBJ		/* INITS AND INTS		*/
TROGUTIL.OBJ		/* UTILITIES			*/
TROGPALL.OBJ		/* PALETTE ROUTINES		*/
TROGPROC.OBJ		/* MULTI-TASKER			*/
TROGSND.OBJ		/* SOUND PROCESSOR		*/
TROGBGND.OBJ		/* BACKGROUND GENERATOR		*/
TROGPOST.OBJ		/* POST AND MOVE ROUTINES	*/
TROGBAR.OBJ		/* BAR ROUTINES			*/
TROGDINO.OBJ		/* DINOSAUR ROUTINES		*/
TROGDIN2.OBJ		/* DINOSAUR ROUTINES PART II	*/
TROGMISC.OBJ		/* MISCELLANEOUS ROUTINES	*/
TROGTEXT.OBJ		/* TEXT PROCESSING ROUTINES	*/
TROGCOL.OBJ		/* COLLSION ROUTINES		*/
TROGENEM.OBJ		/* ENEMY DISPATCH ROUTINES	*/
TROGTROG.OBJ		/* TROG CONTROL			*/
TROGEGGS.OBJ		/* EGG AND HOUSE ROUTINES	*/
TROGWHL.OBJ		/* WHEEL ROUTINES		*/
TROGSPRG.OBJ		/* TROG WITH THE SPRING SHOE	*/
TROGDRON.OBJ		/* DRONE ROUTINES		*/
TROGTREX.OBJ		/* TREX ROUTINES		*/
TROGMAPS.OBJ		/* POST AND BOUNDRY MAPS	*/
TROGDDAT.OBJ		/* DINOSAUR SCRIPTS		*/
TROGTDAT.OBJ		/* TROG SCRIPTS			*/
TROGWAVE.OBJ		/* WAVE TABLES			*/
IMGPAL.OBJ		/* PALETTE DATA			*/
IMGTBL.OBJ		/* GLOBAL IMAGE HEADERS		*/
BGNDTBL.OBJ		/* BACKGROUND TABLES		*/
BGNDPAL.OBJ		/* BACKGROUND PALETTES		*/
TROGTV.OBJ		/* TODDVIEW HOOKS		*/
/*TROGTIPS.OBJ		 TIPS BOX STUFF		*/
f:\video\trog\TROGKURT.RLO	/* LINK IN THE KURT CODE */

MEMORY        			/* set up memory for sdb board */
{
 SCRATCH	: org = 0x01000000,	len = 0x100000
 ROM		: org = 0xFFE00000,	len = 0x1FFBC0 
 CKSMAREA	: org = 0xFFFFFBC0,	len = 0x40
 TRAP31		: org = 0xFFFFFC00,	len = 0x400 
 IROM		: org = 0x02000000,	len = 0x400000 
}

SECTIONS       /* linker sections directive */
 {
	VECTORS:  {} 	> TRAP31
	CKSUMS: {}	> CKSMAREA
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