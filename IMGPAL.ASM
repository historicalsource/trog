	.FILE 'imgpal.asm'
	.OPTION B,D,L,T

	.include imgtbl.glo
	.DATA
	.even

YELLOW16:
	.word	 16
	.word	>0,>39CE,>66E3,>2C20,>34A0,>4D20,>5160,>5DA0
	.word	>65E0,>6A20,>7260,>76A0,>7B00,>77A0,>7FE0,>6F7B

PINK16:
	.word	 16
	.word	>0,>39CE,>6C78,>2004,>2806,>3007,>3409,>400B
	.word	>480E,>5410,>6011,>6813,>7015,>741A,>7C1F,>6F7B

FIXED3:
	.word	 12
	.word	>0,>20C3,>3568,>4A0D,>5A91,>1CA,>2A6C,>38E0
	.word	>5160,>6A20,>76E0,>77A0

BLUE16:
	.word	 16
	.word	>0,>39CE,>87C,>7,>9,>C,>F,>12
	.word	>16,>19,>1E,>1F,>BF,>FF,>1BF,>6F7B

RED16:
	.word	 16
	.word	>0,>39CE,>714A,>2800,>3400,>4000,>4C00,>5000
	.word	>5C00,>6400,>6C00,>7400,>7C00,>7CE0,>7D20,>6F7B

trogcol:
	.word	 16
	.word	>0,>0,>2880,>34A0,>40C0,>3524,>3D65,>5100
	.word	>4586,>7560,>7667,>5A08,>6A69,>7ACB,>7712,>737A

flame:
	.word	 16
	.word	>0,>1C01,>C20,>5000,>64E0,>7D80,>7E00,>7F07
	.word	>7F88,>7FCC,>7FED,>7FF5,>30A1,>2441,>10C4,>18C3

WHEELPAL:
	.word	 16
	.word	>0,>C42,>34A0,>18A5,>2507,>3548,>398B,>3DAC
	.word	>49AB,>5100,>4E30,>5651,>5A72,>5E93,>62B4,>6B17

CAVSIN:
	.word	  7
	.word	>0,>7CC0,>3000,>77A0,>5540,>0,>7FFF

DUXPAL:
	.word	 10
	.word	>0,>7C00,>6739,>1F,>35AD,>77A0,>741A,>3A0
	.word	>0,>10

ball4:
	.word	 16
	.word	>0,>16,>14B7,>2959,>39DA,>3DFA,>421B,>4A5B
	.word	>529C,>56BC,>5ADD,>5EFD,>631D,>673D,>6F7E,>7FFF

will:
	.word	  3
	.word	>0,>0,>7BDE

play6:
	.word	  3
	.word	>0,>0,>7FFF

midway:
	.word	  4
	.word	>0,>7BDE,>1FF,>3B1F

NOYLAND1:
	.word	 16
	.word	>0,>2C81,>3D04,>104,>124,>80,>C0,>E0
	.word	>945,>1401,>1C01,>2441,>100,>38E3,>30A1,>0

SPRINGLA:
	.word	 16
	.word	>0,>1CE7,>3DEF,>2508,>2529,>C63,>1484,>14A5
	.word	>2D6B,>C42,>1484,>14A5,>1CC6,>358C,>2508,>0

TUNPAL:
	.word	 12
	.word	>0,>6F7B,>5AD6,>4631,>318C,>1CE7,>842,>0
	.word	>0,>0,>0,>0

WARMGRAY:
	.word	 16
	.word	>0,>1040,>1460,>1881,>1CA2,>20C3,>24E4,>2905
	.word	>2D26,>3568,>41CB,>4A0D,>524F,>5A91,>62D3,>7357

tlopal8:
	.word	  4
	.word	>0,>0,>2F,>7820

VOLROCK1:
	.word	 16
	.word	>0,>3CA2,>4525,>2CA2,>34A1,>1C41,>2461,>2481
	.word	>34C1,>1C22,>2422,>2421,>2CA1,>4504,>3CC2,>C21

NOYLANDY:
	.word	 16
	.word	>0,>2C81,>4D40,>4520,>4940,>2860,>38A0,>3CE0
	.word	>4D60,>1401,>1C01,>2441,>4500,>38E3,>30A1,>0

NOYPINK:
	.word	 16
	.word	>0,>2C81,>3D04,>3866,>3CA7,>2000,>2802,>3003
	.word	>44C7,>1401,>1C01,>2441,>3424,>38E3,>30A1,>0

landblu1:
	.word	 16
	.word	>0,>2C81,>3D04,>E9,>10A,>86,>A7,>C8
	.word	>12B,>1401,>1C01,>2441,>C9,>38E3,>30A1,>0

bflesh:
	.word	 16
	.word	>0,>0,>1061,>1CA2,>24E3,>2D04,>3545,>3D65
	.word	>49A6,>51E7,>5A08,>6249,>6A69,>72AA,>7ACB,>7EEB

bfur:
	.word	 16
	.word	>0,>0,>1040,>2460,>2C80,>38A0,>44C0,>4CE0
	.word	>5500,>5900,>6120,>6540,>6D40,>7140,>7560,>7960

gray15:
	.word	 16
	.word	>0,>0,>421,>1083,>14A4,>18C5,>1CE6,>2107
	.word	>2528,>2949,>318B,>39CD,>420F,>4A51,>5293,>62F7

PURPFUR:
	.word	 16
	.word	>0,>0,>2408,>3008,>3407,>3524,>3D65,>480D
	.word	>4586,>58CF,>7667,>5A08,>6A69,>7ACB,>7712,>737A

GREENFUR:
	.word	 16
	.word	>0,>0,>C0,>100,>1141,>3524,>3D65,>21C0
	.word	>4586,>3E40,>7667,>5A08,>6A69,>7ACB,>7712,>737A

BLUEFUR:
	.word	 16
	.word	>0,>0,>6,>C0B,>1810,>3524,>3D65,>1CD4
	.word	>4586,>157F,>7667,>5A08,>6A69,>7ACB,>7712,>737A

REDFUR:
	.word	 16
	.word	>0,>0,>2000,>2C00,>3800,>3524,>3D65,>5000
	.word	>4586,>7C00,>7667,>5A08,>6A69,>7ACB,>7712,>737A

BLUZOM:
	.word	 16
	.word	>0,>0,>2408,>3008,>3407,>10EB,>152C,>480D
	.word	>198E,>58CF,>2A6C,>E0D,>1E6E,>2ED0,>2B17,>737A

beye:
	.word	 16
	.word	>0,>0,>420,>821,>C20,>1020,>18A3,>420F
	.word	>5AD5,>6B38,>6F7A,>739C,>7BBD,>7BDE,>7FDE,>7FFF

GAMEFIX:
	.word	 11
	.word	>0,>7C00,>5C00,>FF,>7A80,>77A0,>6C18,>3007
	.word	>0,>16,>4D20

PLNTPOST:
	.word	 16
	.word	>0,>C0,>100,>120,>140,>1A0,>1E0,>200
	.word	>221,>2C0,>2860,>38A0,>4500,>20C3,>1CA3,>1482

GREEN16:
	.word	 16
	.word	>0,>39CE,>46CB,>C0,>121,>141,>161,>1A1
	.word	>1E1,>221,>261,>281,>2A1,>2E2,>3C2,>6F7B

GREY16:
	.word	 16
	.word	>0,>39CE,>739C,>294A,>35AD,>4631,>4A52,>4E73
	.word	>56B5,>5AD6,>5EF7,>6739,>6F7B,>77BD,>7BDE,>6F7B
