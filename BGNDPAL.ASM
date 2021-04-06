	.OPTION	B,D,L,T
	.include	"BGNDTBL.GLO"
	.DATA
land:	;PAL #2
	.word	16	;pal size
	.word >0,>2C81,>3D04,>14E5,>1906,>882,>CA3,>10C4,>1527,>1401
	.word >1C01,>2441,>18C3,>38E3,>30A1,>0

FACEPALS:
	.long	trogcol
	.long	PINK16
	.long	land
troglogo:	;PAL #1
	.word	9	;pal size
	.word >0,>0,>2F,>C96,>7820,>7FFF,>0,>2F,>7820
TLOGO:	;PAL #2
	.word	5	;pal size
	.word >0,>0,>2F,>11,>7820

LOGPALS:
	.long	tlopal8
	.long	troglogo
	.long	TLOGO
LAVA2:	;PAL #0
	.word	16	;pal size
	.word >0,>3C00,>3000,>3400,>3C00,>3C00,>3400,>3C00,>3C00,>4400
	.word >4800,>3C00,>3C00,>3C00,>3C00,>3C00
WAWA2:	;PAL #1
	.word	16	;pal size
	.word >0,>D3,>6D,>8D,>AE,>AE,>8D,>AE,>AE,>D1
	.word >F3,>AE,>AE,>AE,>AE,>AE
POSTPAL3:	;PAL #3
	.word	16	;pal size
	.word >0,>20C3,>2905,>2D26,>3568,>41CB,>4A0D,>524F,>5A91,>62D3
	.word >882,>CC3,>10E4,>20C3,>1CA3,>1482
LAVPOST2:	;PAL #5
	.word	16	;pal size
	.word >0,>2460,>1841,>2C83,>2420,>2C40,>3060,>38A0,>4500,>4D42
	.word >5584,>5DC6,>6608,>38E3,>30A1,>0

ISLEPALS:
	.long	LAVA2
	.long	WAWA2
	.long	NOYLAND1
	.long	POSTPAL3
	.long	VOLROCK1
	.long	LAVPOST2
LITGRAY:	;PAL #0
	.word	16	;pal size
	.word >0,>420,>841,>1083,>14A4,>1CC5,>2507,>2949,>358A,>39AC
	.word >3DCD,>41EE,>460F,>4A30,>5272,>5AB4
DKGRAY:	;PAL #1
	.word	16	;pal size
	.word >0,>420,>841,>C62,>1083,>18A4,>1CE6,>2107,>2528,>2949
	.word >2D6A,>318B,>358C,>39CD,>41EE,>4A30
PURP15:	;PAL #3
	.word	16	;pal size
	.word >0,>401,>401,>803,>C04,>1025,>1446,>1867,>1C88,>20A9
	.word >28EB,>312D,>396F,>41B1,>49F3,>5A57
BGRAY15:	;PAL #4
	.word	16	;pal size
	.word >0,>821,>821,>821,>821,>821,>842,>863,>C84,>10A5
	.word >18E7,>2129,>296B,>31AD,>39EF,>4A53
RED1115:	;PAL #5
	.word	16	;pal size
	.word >0,>C01,>1001,>1C01,>2001,>2401,>2801,>2C21,>3042,>3463
	.word >3CA5,>44E7,>4D29,>556B,>5DAD,>6E11
GREEN15:	;PAL #6
	.word	16	;pal size
	.word >0,>401,>421,>483,>4A4,>4C5,>4E6,>907,>D28,>1149
	.word >198B,>21CD,>2A0F,>3251,>3A93,>4AF7
BLUE15:	;PAL #7
	.word	16	;pal size
	.word >0,>C44,>C44,>C46,>C67,>C88,>CA9,>10CA,>14EB,>190C
	.word >214E,>2990,>31D2,>3A14,>4256,>52BA
CAVSIGN:	;PAL #9
	.word	6	;pal size
	.word >0,>6400,>3000,>77A0,>4500,>0

CAVEPALS:
	.long	LITGRAY
	.long	DKGRAY
	.long	gray15
	.long	PURP15
	.long	BGRAY15
	.long	RED1115
	.long	GREEN15
	.long	BLUE15
	.long	trogcol
	.long	CAVSIGN
POSTPINK:	;PAL #0
	.word	16	;pal size
	.word >0,>20C3,>2905,>2D26,>3568,>41CB,>4A0D,>524F,>5A91,>62D3
	.word >2043,>2842,>3084,>20C3,>1CA3,>1482
POSTSY:	;PAL #3
	.word	16	;pal size
	.word >0,>20C3,>2905,>2D26,>3568,>41CB,>4A0D,>524F,>5A91,>62D3
	.word >2440,>3080,>3CE0,>20C3,>1CA3,>1482
GRAYSHAP:	;PAL #5
	.word	16	;pal size
	.word >0,>18E7,>296B,>39EF,>4A73,>18E7,>296B,>39EF,>4A73,>18E7
	.word >296B,>39EF,>4A73,>86,>A7,>C8

FUT1PALS:
	.long	POSTPINK
	.long	NOYPINK
	.long	WAWA2
	.long	POSTSY
	.long	NOYLANDY
	.long	GRAYSHAP
	.long	landblu1
IVORYPST:	;PAL #1
	.word	16	;pal size
	.word >0,>2108,>2D6B,>4631,>6318,>2108,>2D6B,>4210,>6318,>2108
	.word >2D6B,>4A52,>6318,>882,>CC3,>10E4
GREENPST:	;PAL #3
	.word	16	;pal size
	.word >0,>140,>180,>240,>3A0,>140,>180,>240,>3A0,>140
	.word >180,>240,>3A0,>1082,>14A4,>1CC6

FUT2PALS:
	.long	LAVA2
	.long	IVORYPST
	.long	NOYLAND1
	.long	GREENPST
	.long	SPRINGLA
	.long	WAWA2
COIN:	;PAL #0
	.word	16	;pal size
	.word >0,>0,>1087,>18C9,>1CEA,>252C,>14A8,>C66,>252E,>51A6
	.word >24A2,>2CE5,>4945,>5A08,>210B,>1C60

ITPAPALS:
	.long	COIN

DSRTPALS:
	.long	PLNTPOST
	.long	WAWA2
	.long	NOYLANDY

W2PALS:
	.long	POSTPAL3
	.long	WAWA2
	.long	NOYLAND1

WX6PALS:
	.long	POSTPAL3
	.long	WAWA2
	.long	NOYLAND1

WV1PALS:
	.long	LAVA2
	.long	LAVPOST2
	.long	VOLROCK1

X2PALS:
	.long	POSTPAL3
	.long	WAWA2
	.long	NOYLAND1

X3PALS:
	.long	POSTPAL3
	.long	WAWA2
	.long	NOYLAND1

WX5PALS:
	.long	POSTPAL3
	.long	WAWA2
	.long	NOYLAND1
