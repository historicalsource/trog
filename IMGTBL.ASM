	.FILE 'imgtbl.asm'
	.OPTION B,D,L,T

	.include imgtbl.glo
	.DATA
	.even
STARS2:
	.word	30,15,12,-10
	.long	>3000000
STARS3:
	.word	18,15,6,-10
	.long	>3000F00
STARS4:
	.word	18,19,6,-8
	.long	>3001860
STARS5:
	.word	24,21,12,-7
	.long	>3002440
STARS6:
	.word	32,23,15,-5
	.long	>3003400
STARS1:
	.word	31,15,13,-10
	.long	>3004B00
	.long	YELLOW16
WHIRL2a:
	.word	28,28,14,12
	.long	>334D7A0
WHIRL3a:
	.word	28,26,14,10
	.long	>334F020
WHIRL1b:
	.word	26,25,12,9
	.long	>33506E0
WHIRL2b:
	.word	27,25,13,9
	.long	>3351CC0
WHIRL3b:
	.word	27,23,12,6
	.long	>33532A0
WHIRL1c:
	.word	22,20,10,6
	.long	>33546C0
WHIRL2c:
	.word	24,22,12,9
	.long	>33555C0
WHIRL3c:
	.word	24,19,11,5
	.long	>3356640
WHIRL1a:
	.word	29,28,14,12
	.long	>3357480
	.long	FIXED3
BSPWP4F1:
	.word	95,117,47,38
	.long	>358B080
	.long	PINK16
REXHED:
	.word	65,61,25,33
	.long	>35A0F80
	.long	RED16
BLOOPHED:
	.word	63,66,27,37
	.long	>35A9120
	.long	BLUE16
SPIKEHED:
	.word	58,57,24,27
	.long	>35B1520
	.long	YELLOW16
GWENHED:
	.word	63,60,27,30
	.long	>35B8000
	.long	PINK16
blooptung:
	.word	11,14,-12,-1
	.long	>35BF800
	.long	PINK16
BSPSTP0:
	.word	63,108,32,30
	.long	>35BFD40
BSPSTP3:
	.word	132,130,71,42
	.long	>35CD540
BSPTORP2:
	.word	71,65,39,-18
	.long	>35EED80
BSPWP4F2:
	.word	90,122,47,40
	.long	>35F7FC0
BSPWP4F3:
	.word	98,125,53,43
	.long	>360DE80
BSPWP4F4:
	.word	89,123,44,40
	.long	>3626520
BSPWP4F5:
	.word	87,113,42,37
	.long	>363C6C0
BSPWP4F6:
	.word	99,115,52,39
	.long	>364FD80
BSPWP4F7:
	.word	104,113,57,41
	.long	>36664E0
BSPSHP0F3:
	.word	81,61,43,7
	.long	>367D420
BSPSHP0F4:
	.word	62,59,29,-1
	.long	>3687440
BSPSHP0F6:
	.word	58,44,31,-3
	.long	>368EA40
BSPSHP0F7:
	.word	43,43,20,-6
	.long	>3693CC0
BSPSHP0F8:
	.word	46,35,25,-8
	.long	>36977E0
BSPSHP0F9:
	.word	35,32,19,-13
	.long	>369AC60
BSPSHP0F10:
	.word	34,26,18,-13
	.long	>369D060
BSPSHP0F11:
	.word	24,24,11,-17
	.long	>369EDA0
BSPSHP0F12:
	.word	18,17,8,-24
	.long	>369FFA0
BSPSHP0F13:
	.word	23,21,11,-20
	.long	>36A0A40
BSPCHP0F1:
	.word	82,105,46,27
	.long	>36A1A00
BSPCHP0F2:
	.word	78,120,43,37
	.long	>36B2DA0
BSPCHP0F3:
	.word	99,125,63,42
	.long	>36C59A0
BSPCHP0F4:
	.word	104,125,68,42
	.long	>36DE040
TRTIPSa:
	.word	119,21,57,-34
	.long	>36F7680
	.long	trogcol
TRTIPSb:
	.word	48,29,30,-5
	.long	>36FC540
	.long	trogcol
TROGCAVSIN:
	.word	228,38,0,0
	.long	>36FF0C0
	.long	CAVSIN
BOXARV1:
	.word	16,9,8,26
	.long	>3712F00
BOXARV2:
	.word	12,13,6,30
	.long	>3713380
BOXARH1:
	.word	9,16,-25,7
	.long	>3713860
BOXARH2:
	.word	13,12,-25,5
	.long	>3713E60
BALLYMID:
	.word	119,25,0,0
	.long	>3756380
	.long	ball4
PRESENTS:
	.word	51,9,0,0
	.long	>375C140
	.long	will
PLAYMATION:
	.word	132,23,0,0
	.long	>375CFE0
	.long	play6
COPY:
	.word	228,7,0,0
	.long	>3762EC0
	.long	midway
VBONCR4:
	.word	10,23,5,10
	.long	>37660A0
VBONCR5:
	.word	7,25,3,11
	.long	>3766940
HOMBASL1:
	.word	41,39,18,-3
	.long	>3766F80
HOMBASC1:
	.word	58,47,44,18
	.long	>376A520
HOMBASC2:
	.word	50,45,8,18
	.long	>376FD40
BLOOHHAND2:
	.word	17,13,7,8
	.long	>3774660
BLOOVHAND1:
	.word	18,16,10,8
	.long	>3774E80
BLOOVHAND2:
	.word	13,17,7,9
	.long	>3775880
REXHHAND2:
	.word	17,13,9,8
	.long	>3774660
REXVHAND1:
	.word	18,16,12,8
	.long	>3774E80
REXVHAND2:
	.word	13,17,9,9
	.long	>3775880
SPIKHHAND2:
	.word	17,13,7,6
	.long	>3774660
SPIKVHAND1:
	.word	18,16,10,6
	.long	>3774E80
SPIKVHAND2:
	.word	13,17,7,7
	.long	>3775880
GWENHHAND2:
	.word	17,13,9,6
	.long	>3774660
GWENVHAND1:
	.word	18,16,12,6
	.long	>3774E80
GWENVHAND2:
	.word	13,17,9,7
	.long	>3775880
HBONCR4:
	.word	24,11,13,8
	.long	>3776100
VBONCR1:
	.word	11,24,5,12
	.long	>3776940
VBONCR2:
	.word	5,25,3,11
	.long	>3777240
SPRLNDHOMU1:
	.word	32,34,16,33
	.long	>37A1DC0
	.long	SPRINGLA
SPRLNDHOML1:
	.word	33,38,14,-4
	.long	>37A3FC0
SPRLNDHOMC1:
	.word	45,44,44,15
	.long	>37A6A80
SPRLNDHOMC2:
	.word	44,43,2,17
	.long	>37AAC80

	.include BGNDTBL.GLO
spikeicon:
	.word	12,14,0,0
	.long	>2000000
	.long	PINK16
royicon:
	.word	12,14,0,0
	.long	>2000000
	.long	RED16
bloopicon:
	.word	12,14,0,0
	.long	>2000000
	.long	BLUE16
stegicon:
	.word	12,14,0,0
	.long	>2000000
	.long	YELLOW16
HOMBASU1:
	.word	34,40,16,36
	.long	>200FFA0
	.long	NOYLAND1
HOUSEPOST:
	.word	8,8,4,3
	.long	>2012CA0
	.long	FIXED3
SPARK2:
	.word	3,3,0,3
	.long	>2012EA0
	.long	PINK16
GAMEOVER:
	.word	75,18,37,7
	.long	>2012F00
	.long	RED16
TUNNELIMG:
	.word	27,26,13,9
	.long	>20159C0
	.long	TUNPAL
P2HBON:
	.word	25,4,13,1
	.long	>2017080
	.long	BLUE16
P2VBON:
	.word	4,25,2,12
	.long	>2001A40
	.long	BLUE16
P1HBON:
	.word	25,4,13,1
	.long	>2017080
	.long	RED16
P1VBON:
	.word	4,25,2,12
	.long	>2001A40
	.long	RED16
P3HBON:
	.word	25,4,13,1
	.long	>2017080
	.long	YELLOW16
P3VBON:
	.word	4,25,2,12
	.long	>2001A40
	.long	YELLOW16
P4HBON:
	.word	25,4,13,1
	.long	>2017080
	.long	PINK16
P4VBON:
	.word	4,25,2,12
	.long	>2001A40
	.long	PINK16
BLOOHHAND1:
	.word	16,18,7,11
	.long	>2017400
	.long	BLUE16
REXHHAND1:
	.word	16,18,9,11
	.long	>2017400
	.long	RED16
SPIKHHAND1:
	.word	16,18,7,9
	.long	>2017400
	.long	YELLOW16
GWENHHAND1:
	.word	16,18,9,9
	.long	>2017400
	.long	PINK16
ROCKPOST1:
	.word	8,8,4,3
	.long	>2017D00
	.long	WARMGRAY
ROCKPOST2:
	.word	8,8,4,3
	.long	>2017F00
	.long	WARMGRAY
ROCKPOST3:
	.word	8,8,4,3
	.long	>2018100
	.long	WARMGRAY
ROCKPOST4:
	.word	8,8,4,3
	.long	>2018300
	.long	WARMGRAY
WSPLASH1:
	.word	32,23,15,18
	.long	>2018500
WSPLASH2:
	.word	48,31,21,27
	.long	>2019C00
WSPLASH3:
	.word	59,34,28,29
	.long	>201CA80
WSPLASH4:
	.word	64,35,32,32
	.long	>2020A40
WSPLASH5:
	.word	68,22,35,15
	.long	>2025040
LSPLASH1:
	.word	32,23,15,18
	.long	>2027F00
LSPLASH2:
	.word	48,31,21,27
	.long	>2029600
LSPLASH3:
	.word	59,34,28,29
	.long	>202C480
LSPLASH4:
	.word	64,35,32,32
	.long	>2030440
LSPLASH5:
	.word	68,22,35,15
	.long	>2034A40
HBONCR1:
	.word	25,16,13,10
	.long	>2037900
HBONCR2:
	.word	25,5,13,2
	.long	>2038700
HBONCR3:
	.word	25,5,13,1
	.long	>2038B60
HBONCR5:
	.word	25,7,13,2
	.long	>2038FC0
VBONCR3:
	.word	5,25,2,11
	.long	>20395E0
SPARK3:
	.word	5,5,1,4
	.long	>2039C20
SPARK4:
	.word	5,5,1,4
	.long	>2039D60
LITTLELOG:
	.word	95,61,0,0
	.long	>2039EA0
	.long	tlopal8
VOLCTIP:
	.word	53,29,0,0
	.long	>20455A0
	.long	VOLROCK1
boobridge:
	.word	106,22,0,0
	.long	>2048860
	.long	NOYLAND1
SHROOM1:
	.word	5,6,2,-6
	.long	>204D2A0
	.long	FIXED3
SHROOM2:
	.word	7,9,3,-2
	.long	>204D420
	.long	FIXED3
SHROOM3:
	.word	9,16,4,5
	.long	>204D660
	.long	FIXED3
SHROOM4:
	.word	15,17,7,6
	.long	>204DC60
	.long	FIXED3
SPEED1:
	.word	4,4,4,-6
	.long	>204E4E0
	.long	flame
VHOMBASU1:
	.word	34,40,16,36
	.long	>204E560
	.long	VOLROCK1
VOGPIT1:
	.word	39,33,19,12
	.long	>3778780
	.long	VOLROCK1
VTAR5:
	.word	23,20,13,9
	.long	>3777880
	.long	VOLROCK1
EOGPIT1:
	.word	39,33,19,12
	.long	>3778780
	.long	NOYLANDY
ETAR5:
	.word	23,20,13,9
	.long	>3777880
	.long	NOYLANDY
EHOMBASU1:
	.word	34,40,16,36
	.long	>200FFA0
	.long	NOYLANDY
COGPIT1:
	.word	39,33,19,12
	.long	>3778780
	.long	NOYPINK
CTAR5:
	.word	23,20,13,9
	.long	>3777880
	.long	NOYPINK
CHOMBASU1:
	.word	34,40,16,36
	.long	>200FFA0
	.long	NOYPINK
WOGPIT1:
	.word	39,33,19,12
	.long	>3778780
	.long	landblu1
WTAR5:
	.word	23,20,13,9
	.long	>3777880
	.long	landblu1
WELANHOMU1:
	.word	32,29,16,33
	.long	>2051260
	.long	landblu1
SOGPIT1:
	.word	39,33,19,12
	.long	>3778780
	.long	SPRINGLA
STAR5:
	.word	23,20,13,9
	.long	>3777880
	.long	SPRINGLA
WELANHOML1:
	.word	33,37,14,-5
	.long	>2052F60
WELANHOMC1:
	.word	43,44,44,15
	.long	>2055900
WELANHOMC2:
	.word	38,44,-4,17
	.long	>2059580
VHOMBASL1:
	.word	39,39,18,-3
	.long	>205CC80
VHOMBASC1:
	.word	58,48,44,17
	.long	>205FD40
VHOMBASC2:
	.word	50,42,8,16
	.long	>2065740
SPEED2:
	.word	7,13,5,2
	.long	>2069B80
SPEED3:
	.word	9,19,5,8
	.long	>2069EC0
SPEED4:
	.word	16,19,9,7
	.long	>206A5E0
PTRSTP0:
	.word	39,31,19,-13
	.long	>31D5260
	.long	PURPFUR
GTRSTP0:
	.word	39,31,19,-13
	.long	>31D5260
	.long	GREENFUR
BTRSTP0:
	.word	39,31,19,-13
	.long	>31D5260
	.long	BLUEFUR
RTRSTP0:
	.word	39,31,19,-13
	.long	>31D5260
	.long	REDFUR
BZTRSTP0:
	.word	39,31,19,-13
	.long	>31D5260
	.long	BLUZOM
BTRHED:
	.word	189,177,78,-31
	.long	>24DBDA0
	.long	bflesh
BTRBEARD:
	.word	164,126,78,-82
	.long	>251E3A0
	.long	bfur
BTRHAIR:
	.word	30,25,16,-11
	.long	>2546960
	.long	bfur
BTREYE:
	.word	41,33,19,-56
	.long	>2548260
	.long	beye
BTRBROW:
	.word	32,15,16,-40
	.long	>254AFC0
	.long	bfur
BTRBLINK1:
	.word	42,40,20,-49
	.long	>254BEC0
	.long	bflesh
BTRBLINK2:
	.word	42,34,20,-55
	.long	>254F5C0
	.long	bflesh
BTRTEETH:
	.word	61,30,23,-121
	.long	>2552480
	.long	beye
BTRHAND1:
	.word	93,133,138,-36
	.long	>2556080
	.long	bflesh
BTRHAND2:
	.word	91,103,138,-65
	.long	>256EF80
	.long	bflesh
BTRHAND5:
	.word	43,63,98,-144
	.long	>25817A0
	.long	bflesh
SCORCONTINUE:
	.word	72,8,36,1
	.long	>2586E40
	.long	BLUE16
SCORGAMEOVER:
	.word	58,8,29,1
	.long	>2588040
	.long	BLUE16
SCORTOPLAY:
	.word	44,8,22,1
	.long	>2588F40
	.long	BLUE16
SCORINSERT:
	.word	70,8,35,1
	.long	>2589A40
	.long	BLUE16
SCORREX:
	.word	58,8,28,1
	.long	>258AC40
	.long	BLUE16
SCORGWEN:
	.word	65,8,32,1
	.long	>258BB40
	.long	BLUE16
SCORSPIKE:
	.word	72,8,36,1
	.long	>258CC40
	.long	BLUE16
SCORBLOOP:
	.word	72,8,36,1
	.long	>258DE40
	.long	BLUE16
PAPPLE1:
	.word	5,6,2,-2
	.long	>258F040
	.long	FIXED3
PAPPLE2:
	.word	8,11,3,3
	.long	>258F1C0
	.long	FIXED3
PAPPLE3:
	.word	10,19,4,10
	.long	>258F480
	.long	FIXED3
PAPPLE4:
	.word	10,28,4,16
	.long	>258FBA0
	.long	FIXED3
PAPPLE5:
	.word	21,19,9,7
	.long	>2590620
	.long	FIXED3
PAPPLE6a:
	.word	20,25,9,13
	.long	>2591460
	.long	FIXED3
PAPPLE6b:
	.word	20,25,9,13
	.long	>2592400
	.long	FIXED3
PAPPLE6c:
	.word	18,25,8,13
	.long	>25933A0
	.long	FIXED3
EASTEREGG:
	.word	10,13,5,5
	.long	>2594340
	.long	GAMEFIX
HBONREDH:
	.word	25,4,13,1
	.long	>2594820
	.long	GAMEFIX
HBONBLUEV:
	.word	4,25,2,13
	.long	>2594BA0
	.long	GAMEFIX
BLOOPTUNGF1:
	.word	14,23,-2,16
	.long	>2594EC0
	.long	PINK16
BLOOPTUNGF2:
	.word	15,21,-18,5
	.long	>2595A40
BLOOPTUNGF3:
	.word	18,23,-38,-8
	.long	>25964C0
BLOOPTUNGF4:
	.word	17,20,-33,-16
	.long	>2597320
REXCHEERF1:
	.word	79,118,34,34
	.long	>2597FA0
REXCHEERF2:
	.word	104,103,46,38
	.long	>25AA6A0
REXCHEERF3:
	.word	102,102,45,38
	.long	>25BF560
REXCHEERF4:
	.word	100,104,41,40
	.long	>25D40E0
BLOOPCHEERF1:
	.word	98,121,39,56
	.long	>25E85E0
BLOOPCHEERF2:
	.word	92,119,27,45
	.long	>2600000
BLOOPCHEERF3:
	.word	94,112,15,32
	.long	>2615620
BLOOPCHEERF4:
	.word	110,101,24,22
	.long	>262A620
GWENCHEERF3:
	.word	93,118,44,40
	.long	>26407A0
GWENCHEERF1:
	.word	81,124,30,46
	.long	>26569A0
GWENCHEERF2:
	.word	87,126,23,47
	.long	>266AF20
OING1:
	.word	31,30,15,13
	.long	>26809A0
	.long	SPRINGLA
OING2:
	.word	31,30,15,13
	.long	>26827A0
	.long	SPRINGLA
OING3:
	.word	31,30,15,13
	.long	>26845A0
	.long	SPRINGLA
OING4:
	.word	31,35,15,18
	.long	>26863A0
	.long	SPRINGLA
OING5:
	.word	37,40,18,23
	.long	>26886A0
	.long	SPRINGLA
TRANBACK:
	.word	22,26,11,13
	.long	>268B8A0
	.long	NOYLAND1
ETRANBACK:
	.word	22,26,11,13
	.long	>268B8A0
	.long	NOYLANDY
CTRANBACK:
	.word	22,26,11,13
	.long	>268B8A0
	.long	NOYPINK
WTRANBACK:
	.word	22,26,11,13
	.long	>268B8A0
	.long	landblu1
VTRANBACK:
	.word	22,26,11,13
	.long	>268B8A0
	.long	VOLROCK1
STRANBACK:
	.word	22,26,11,13
	.long	>268B8A0
	.long	SPRINGLA
SPBPP4F16:
	.word	29,27,18,-20
	.long	>268CC20
	.long	PINK16
trancave1:
	.word	30,50,15,37
	.long	>268E720
	.long	FIXED3
trancave2:
	.word	30,46,15,33
	.long	>2691920
	.long	FIXED3
RADI4:
	.word	25,25,12,10
	.long	>2694720
	.long	FIXED3
ZIG1:
	.word	28,30,13,16
	.long	>2695D00
	.long	WHEELPAL
GEM1:
	.word	10,8,5,31
	.long	>2697740
	.long	RED16
PALM1:
	.word	32,30,16,15
	.long	>2697A40
	.long	PLNTPOST
DESHOMU1:
	.word	32,34,16,33
	.long	>2699840
	.long	NOYLANDY
TROGHED:
	.word	28,37,14,22
	.long	>269BA40
	.long	WHEELPAL
SKULL:
	.word	27,33,13,19
	.long	>269DAA0
	.long	WHEELPAL
BOULDER1:
	.word	27,32,13,17
	.long	>269F780
	.long	WHEELPAL
RADI1:
	.word	25,25,12,10
	.long	>26A1380
RADI2:
	.word	25,25,12,10
	.long	>26A2960
RADI3:
	.word	25,25,12,10
	.long	>26A3F40
PALM2:
	.word	32,46,16,29
	.long	>26A5520
GEM2:
	.word	10,8,5,31
	.long	>26A8320
DESHOMC1:
	.word	45,44,44,15
	.long	>26A8620
DESHOMC2:
	.word	44,43,2,17
	.long	>26AC820
DESHOML1:
	.word	33,38,14,-4
	.long	>26B0340
BARL2:
	.word	7,103,4,2
	.long	>2903EE0
	.long	GREEN16
BART2:
	.word	113,8,0,4
	.long	>29058A0
	.long	GREEN16
ARROW2:
	.word	24,21,14,-12
	.long	>29075A0
ARROW3:
	.word	30,15,4,-11
	.long	>2908560
BARL1:
	.word	1,99,0,0
	.long	>2909460
BARL3:
	.word	14,105,7,3
	.long	>290A0C0
BARL4:
	.word	14,108,5,4
	.long	>290D540
BARL5:
	.word	22,124,15,11
	.long	>2910B40
BART1:
	.word	112,1,-1,0
	.long	>2916840
BART3:
	.word	106,15,-7,6
	.long	>2916BC0
BART4:
	.word	109,14,-4,6
	.long	>2919E60
BART5:
	.word	112,20,-1,13
	.long	>291CF60
EXCLA2:
	.word	19,32,10,-8
	.long	>2921560
EXCLA3:
	.word	25,37,14,-3
	.long	>2922960
EXCLA4:
	.word	23,35,12,-5
	.long	>29249C0
PINWEEL2:
	.word	66,63,31,31
	.long	>2926400
PINWEEL3:
	.word	44,61,21,31
	.long	>292E9E0
PINWEEL4:
	.word	71,85,33,43
	.long	>2933DC0
PINWEEL5:
	.word	49,57,23,25
	.long	>293FD00
PINWEEL6:
	.word	50,54,22,24
	.long	>29459A0
PINWEEL7:
	.word	48,52,25,23
	.long	>294B160
PINWEEL8:
	.word	49,51,24,22
	.long	>294FF60
TRANSF10:
	.word	41,41,21,-10
	.long	>2955240
TRANSF11:
	.word	50,51,24,-5
	.long	>2958AA0
TRANSF2:
	.word	38,34,18,-17
	.long	>295DD80
TRANSF3:
	.word	49,43,23,-13
	.long	>2960800
TRANSF4:
	.word	36,34,17,-16
	.long	>2964DE0
TRANSF5:
	.word	35,35,17,-15
	.long	>2967420
TRANSF6:
	.word	31,31,15,-17
	.long	>2969B80
TRANSF7:
	.word	43,43,21,-12
	.long	>296BA80
TRANSF8:
	.word	34,37,17,-13
	.long	>296F5A0
TRANSF9:
	.word	41,41,21,-10
	.long	>2971F40
TROGBOUN2:
	.word	41,19,18,-29
	.long	>29757A0
TROGBOUN3:
	.word	43,45,19,-9
	.long	>29771C0
TROGBOUN4:
	.word	23,44,10,-4
	.long	>297AFA0
WOW2:
	.word	52,35,23,-19
	.long	>297D0A0
WOW3:
	.word	54,36,24,-18
	.long	>2980980
WOW4a:
	.word	72,51,33,-9
	.long	>2984880
WOW4b:
	.word	99,72,47,0
	.long	>298BB40
WOW4c:
	.word	77,53,38,-11
	.long	>2999C40
WOW4d:
	.word	68,41,27,-19
	.long	>29A20C0
YO2:
	.word	41,43,19,-4
	.long	>29A77E0
YO3:
	.word	34,36,14,-10
	.long	>29AB300
YO4:
	.word	34,36,14,-10
	.long	>29ADB80
YO5:
	.word	27,26,9,-13
	.long	>29B0400
FIREWERK1:
	.word	32,32,16,-13
	.long	>29B1AC0
FIREWERK2:
	.word	41,43,20,-7
	.long	>29B3AC0
FIREWERK3:
	.word	49,49,24,-5
	.long	>29B75E0
FIREWERK4:
	.word	53,53,26,-3
	.long	>29BC580
ROCKET1:
	.word	10,65,7,-152
	.long	>29C2240
ROCKET2:
	.word	23,76,11,-102
	.long	>29C3AA0
ROCKET3:
	.word	32,51,17,-92
	.long	>29C73A0
ROCKET4:
	.word	37,39,18,-77
	.long	>29CA6A0
ROCKET5:
	.word	31,42,15,-60
	.long	>29CD760
ROCKET6:
	.word	24,45,11,-40
	.long	>29D0160
ROCKET7:
	.word	15,52,6,-20
	.long	>29D2320
ARROW1:
	.word	25,18,12,-12
	.long	>29D3D20
EXCLA1:
	.word	11,18,4,-18
	.long	>29D4CE0
PINWEEL1:
	.word	48,51,23,26
	.long	>29D53A0
TRANSF1:
	.word	36,34,16,-17
	.long	>29DA020
TROGBOUN1:
	.word	54,25,23,-34
	.long	>29DC660
YO1:
	.word	39,43,17,-5
	.long	>29DF220
WOW1:
	.word	43,29,19,-21
	.long	>29E27E0
CUBE5:
	.word	10,12,6,6
	.long	>29E4FC0
	.long	BLUE16
SHIELD1:
	.word	23,23,11,-23
	.long	>29E5440
	.long	PINK16
SHOE1:
	.word	8,8,5,-2
	.long	>29E6580
	.long	FIXED3
FIREBALL1:
	.word	14,12,6,-21
	.long	>29E6780
	.long	flame
CUBE10:
	.word	10,11,6,5
	.long	>29E6D80
CUBE11:
	.word	14,13,8,5
	.long	>29E71A0
CUBE12:
	.word	18,14,10,3
	.long	>29E7820
CUBE13:
	.word	21,12,11,0
	.long	>29E80E0
CUBE14:
	.word	23,11,12,-2
	.long	>29E89E0
CUBE15:
	.word	25,13,14,-2
	.long	>29E9220
CUBE16:
	.word	25,13,14,-2
	.long	>29E9D80
CUBE17:
	.word	25,13,13,-2
	.long	>29EA8E0
CUBE5a:
	.word	14,14,8,8
	.long	>29EB440
CUBE6:
	.word	10,12,6,6
	.long	>29EBB40
CUBE7:
	.word	10,12,6,6
	.long	>29EBFC0
CUBE8:
	.word	10,12,6,6
	.long	>29EC440
CUBE9:
	.word	10,12,6,6
	.long	>29EC8C0
SHIELD2:
	.word	25,25,12,-22
	.long	>29ECD40
SHIELD3:
	.word	25,25,12,-22
	.long	>29EE320
SHOE2:
	.word	12,13,7,3
	.long	>29EF900
SHOE3:
	.word	26,20,14,6
	.long	>29EFDE0
SHOE4:
	.word	16,16,9,6
	.long	>29F0F60
CHILI0:
	.word	22,13,9,3
	.long	>29F1760
CHILI1:
	.word	22,16,9,6
	.long	>29F2120
CHILI2:
	.word	22,14,9,4
	.long	>29F2D20
CHILI3:
	.word	22,17,9,7
	.long	>29F37A0
CHILI4:
	.word	22,14,9,4
	.long	>29F4460
CHILI5:
	.word	22,17,9,7
	.long	>29F4EE0
FIREBALL2:
	.word	11,12,4,-20
	.long	>29F5BA0
FIREBALL3:
	.word	11,11,4,-20
	.long	>29F6020
FIREBALL4:
	.word	11,10,4,-22
	.long	>29F6440
FIREBALLP0F1:
	.word	3,11,0,-19
	.long	>29F6800
FIREBALLP0F2:
	.word	8,10,2,-22
	.long	>29F6960
FIREBALLP0F3:
	.word	23,8,9,-23
	.long	>29F6BE0
FIREBALLP4F1:
	.word	11,3,5,-25
	.long	>29F71E0
FIREBALLP4F2:
	.word	10,8,4,-22
	.long	>29F7300
FIREBALLP4F3:
	.word	8,17,2,-18
	.long	>29F7600
SHIELD4:
	.word	27,27,13,-21
	.long	>29F7A40
FIREBALLO1:
	.word	7,16,1,-12
	.long	>29F91E0
FIREBALLO2:
	.word	6,19,0,-5
	.long	>29F95E0
FIREBALLO3:
	.word	4,13,0,-1
	.long	>29F9AA0
PXHBON:
	.word	25,4,13,1
	.long	>2A0ECE0
	.long	FIXED3
PXVBON:
	.word	4,25,2,12
	.long	>2A0F060
	.long	FIXED3
GEMDIAMOND:
	.word	9,15,5,6
	.long	>2A0FA40
	.long	GREY16
GEMSPHERE:
	.word	13,12,6,4
	.long	>2A0FFE0
	.long	GREEN16
GEMSQUARE:
	.word	10,12,5,4
	.long	>2A105E0
	.long	RED16
TROGMOUTH:
	.word	41,54,21,33
	.long	>2B50520
	.long	FIXED3
MOUTHBACK:
	.word	28,26,15,5
	.long	>2B54F60
	.long	NOYLANDY
