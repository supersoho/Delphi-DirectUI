{ ********************************************************************************** }
{                                                                                    }
{ 	 COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: UZConsts.pas                                                      }
{     Description: VCLUnZip component - native Delphi unzip component.               }
{     Date:        March 1997                                                        }
{     Author:      Kevin Boylan, CIS: boylank                                        }
{                                Internet: boylank@compuserve.com                    }
{                                                                                    }
{ ********************************************************************************** }

{ $Log:  10060: kpZConst.pas 
{
{   Rev 1.2    11/30/2008 1:44:06 PM  Delphi7    Version: VCLZip Version 4.50
{ Modifications for 4.50
}
{
{   Rev 1.1    1/25/2008 6:42:40 PM  Delphi7    Version: VCLZip Pro 4.00b2
{ Add AESDEFLATED compression method type
}
{
{   Rev 1.0    8/14/2005 1:10:10 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.1    5/3/2003 6:33:32 PM  Supervisor
}
{
{   Rev 1.0    10/15/2002 8:15:22 PM  Supervisor
}
{
{   Rev 1.0    9/3/2002 8:16:54 PM  Supervisor
}


const
{ UNZIP }
  PATH_LEN = 260;
  FILENAME_LEN = 256;
	MAX_USHORT = $FFFF;
  MAX_SHORT = $7FFF;

  { Integrity Check Constants }  { 12/3/98 2.17P+ }
  icUNDEFINED =  0;
  icFILEOK =     1;
  icFILEBAD =    2;

  { Compression Methods }
  STORED =			0;
  SHRUNK =			1;
  REDUCED1 =		2;
  REDUCED2 =		3;
  REDUCED3 =		4;
  REDUCED4 =		5;
  IMPLODED =		6;
  TOKENIZED =		7;
  DEFLATED =		8;
  AESDEFLATED = 99;

  comp_method: array [0..8] of String[4] =
  (
  	'STOR', 'SHR', 'RED1', 'RED2', 'RED3', 'RED4', 'IMP', 'TOK', 'DEF'
  );
  mask_bits: array [0..16] of WORD =
  (
   	$0000, $0001, $0003, $0007, $000f, $001f, $003f, $007f, $00ff,
   	$01ff, $03ff, $07ff, $0fff, $1fff, $3fff, $7fff, $ffff
   );
  border: array[0..18] of WORD =
  (
  	16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15
  );
  cplens: cpltype =
  (
  	3, 4, 5, 6, 7, 8, 9, 10, 11, 13, 15, 17, 19, 23, 27, 31,
  	35, 43, 51, 59, 67, 83, 99, 115, 131, 163, 195, 227, 258, 0, 0
  );
  cplext: cpltype =
  (
  	0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2,
     3, 3, 3, 3, 4, 4, 4, 4, 5, 5, 5, 5, 0, 99, 99
  );
  cpdist: cpdtype =
  (
  	1, 2, 3, 4, 5, 7, 9, 13, 17, 25, 33, 49, 65, 97, 129, 193, 257, 385, 513,
     769, 1025, 1537, 2049, 3073, 4097, 6145, 8193, 12289, 16385, 24577
  );
  cpdext: cpdtype =
  (
  	0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10,
     11, 11, 12, 12, 13, 13
  );

{$IFNDEF INFLATE_ONLY}
 	cplen2: array[0..63] of WORD =
  (
  	2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17,
     18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34,
     35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51,
     52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65
  );
  cplen3: array[0..63] of WORD =
  (
		3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
     19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
     36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52,
     53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66
  );
  extra: array[0..63] of WORD =
  (
		0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
     0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8
  );
  cpdist4: array[0..63] of WORD =
  (
		1, 65, 129, 193, 257, 321, 385, 449, 513, 577, 641, 705,
     769, 833, 897, 961, 1025, 1089, 1153, 1217, 1281, 1345, 1409, 1473,
     1537, 1601, 1665, 1729, 1793, 1857, 1921, 1985, 2049, 2113, 2177,
     2241, 2305, 2369, 2433, 2497, 2561, 2625, 2689, 2753, 2817, 2881,
     2945, 3009, 3073, 3137, 3201, 3265, 3329, 3393, 3457, 3521, 3585,
     3649, 3713, 3777, 3841, 3905, 3969, 4033
  );
  cpdist8: array[0..63] of WORD =
  (
		1, 129, 257, 385, 513, 641, 769, 897, 1025, 1153, 1281,
     1409, 1537, 1665, 1793, 1921, 2049, 2177, 2305, 2433, 2561, 2689,
     2817, 2945, 3073, 3201, 3329, 3457, 3585, 3713, 3841, 3969, 4097,
     4225, 4353, 4481, 4609, 4737, 4865, 4993, 5121, 5249, 5377, 5505,
     5633, 5761, 5889, 6017, 6145, 6273, 6401, 6529, 6657, 6785, 6913,
     7041, 7169, 7297, 7425, 7553, 7681, 7809, 7937, 8065
  );
  L_table: array[0..4] of WORD = (0, $7f, $3f, $1f, $0f);
  D_shift: array[0..4] of WORD = (0, $07, $06, $05, $04);
  D_mask:  array[0..4] of WORD = (0, $01, $03, $07, $0f);
  B_table: array[0..255] of WORD =
  (
   8, 1, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4, 5,
   5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 6, 6,
   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
   6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 7, 7, 7, 7, 7, 7, 7,
   7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
   7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
   7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
   7, 7, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
   8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
   8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
	 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
   8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
   8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
   8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8,
   8, 8, 8, 8
  );
{$ENDIF}

  CRC_32_TAB : Array[0..255] of U_LONG =
	(
	 $00000000, $77073096, $ee0e612c, $990951ba, $076dc419, $706af48f, $e963a535, $9e6495a3,
	 $0edb8832, $79dcb8a4, $e0d5e91e, $97d2d988, $09b64c2b, $7eb17cbd, $e7b82d07, $90bf1d91,
	 $1db71064, $6ab020f2, $f3b97148, $84be41de, $1adad47d, $6ddde4eb, $f4d4b551, $83d385c7,
	 $136c9856, $646ba8c0, $fd62f97a, $8a65c9ec, $14015c4f, $63066cd9, $fa0f3d63, $8d080df5,
	 $3b6e20c8, $4c69105e, $d56041e4, $a2677172, $3c03e4d1, $4b04d447, $d20d85fd, $a50ab56b,
	 $35b5a8fa, $42b2986c, $dbbbc9d6, $acbcf940, $32d86ce3, $45df5c75, $dcd60dcf, $abd13d59,
	 $26d930ac, $51de003a, $c8d75180, $bfd06116, $21b4f4b5, $56b3c423, $cfba9599, $b8bda50f,
	 $2802b89e, $5f058808, $c60cd9b2, $b10be924, $2f6f7c87, $58684c11, $c1611dab, $b6662d3d,
	 $76dc4190, $01db7106, $98d220bc, $efd5102a, $71b18589, $06b6b51f, $9fbfe4a5, $e8b8d433,
	 $7807c9a2, $0f00f934, $9609a88e, $e10e9818, $7f6a0dbb, $086d3d2d, $91646c97, $e6635c01,
	 $6b6b51f4, $1c6c6162, $856530d8, $f262004e, $6c0695ed, $1b01a57b, $8208f4c1, $f50fc457,
	 $65b0d9c6, $12b7e950, $8bbeb8ea, $fcb9887c, $62dd1ddf, $15da2d49, $8cd37cf3, $fbd44c65,
	 $4db26158, $3ab551ce, $a3bc0074, $d4bb30e2, $4adfa541, $3dd895d7, $a4d1c46d, $d3d6f4fb,
	 $4369e96a, $346ed9fc, $ad678846, $da60b8d0, $44042d73, $33031de5, $aa0a4c5f, $dd0d7cc9,
	 $5005713c, $270241aa, $be0b1010, $c90c2086, $5768b525, $206f85b3, $b966d409, $ce61e49f,
	 $5edef90e, $29d9c998, $b0d09822, $c7d7a8b4, $59b33d17, $2eb40d81, $b7bd5c3b, $c0ba6cad,
	 $edb88320, $9abfb3b6, $03b6e20c, $74b1d29a, $ead54739, $9dd277af, $04db2615, $73dc1683,
	 $e3630b12, $94643b84, $0d6d6a3e, $7a6a5aa8, $e40ecf0b, $9309ff9d, $0a00ae27, $7d079eb1,
	 $f00f9344, $8708a3d2, $1e01f268, $6906c2fe, $f762575d, $806567cb, $196c3671, $6e6b06e7,
	 $fed41b76, $89d32be0, $10da7a5a, $67dd4acc, $f9b9df6f, $8ebeeff9, $17b7be43, $60b08ed5,
	 $d6d6a3e8, $a1d1937e, $38d8c2c4, $4fdff252, $d1bb67f1, $a6bc5767, $3fb506dd, $48b2364b,
	 $d80d2bda, $af0a1b4c, $36034af6, $41047a60, $df60efc3, $a867df55, $316e8eef, $4669be79,
	 $cb61b38c, $bc66831a, $256fd2a0, $5268e236, $cc0c7795, $bb0b4703, $220216b9, $5505262f,
	 $c5ba3bbe, $b2bd0b28, $2bb45a92, $5cb36a04, $c2d7ffa7, $b5d0cf31, $2cd99e8b, $5bdeae1d,
	 $9b64c2b0, $ec63f226, $756aa39c, $026d930a, $9c0906a9, $eb0e363f, $72076785, $05005713,
	 $95bf4a82, $e2b87a14, $7bb12bae, $0cb61b38, $92d28e9b, $e5d5be0d, $7cdcefb7, $0bdbdf21,
	 $86d3d2d4, $f1d4e242, $68ddb3f8, $1fda836e, $81be16cd, $f6b9265b, $6fb077e1, $18b74777,
	 $88085ae6, $ff0f6a70, $66063bca, $11010b5c, $8f659eff, $f862ae69, $616bffd3, $166ccf45,
	 $a00ae278, $d70dd2ee, $4e048354, $3903b3c2, $a7672661, $d06016f7, $4969474d, $3e6e77db,
	 $aed16a4a, $d9d65adc, $40df0b66, $37d83bf0, $a9bcae53, $debb9ec5, $47b2cf7f, $30b5ffe9,
	 $bdbdf21c, $cabac28a, $53b39330, $24b4a3a6, $bad03605, $cdd70693, $54de5729, $23d967bf,
	 $b3667a2e, $c4614ab8, $5d681b02, $2a6f2b94, $b40bbe37, $c30c8ea1, $5a05df1b, $2d02ef8d
  );

  DEF_CENTSIG = $02014b50;
  DEF_LOCSIG = $04034b50;
  DEF_ENDSIG = $06054b50;
  DEF_ZIP64ENDSIG = $06064b50;
  DEF_ZIP64LOCATOR = $07064b50;
  
{$IFDEF SKIPCODE}
  LOC4 = $50; { Last byte of LOCSIG }
  LOC3 = $4b; { 3rd byte of LOCSIG }
  LOC2 = $03; { 2nd byte of LOCSIG }
  LOC1 = $04; { 1st byte of LOCSIG }
  END4 = $50;  { Last byte of ENDSIG }
{$ENDIF}

{ FILE }
  {$IFDEF WIN32}
  INBUFSIZ = $8000;
  {$ELSE}
  INBUFSIZ = $4000;
  {$ENDIF}
  OUTBUFSIZ = INBUFSIZ;
{ INFLATE }
  BMAX = 16;
  N_MAX = 288;

  MAX_BITS = 13;
	HSIZE = 1 shl MAX_BITS;
	WSIZE = $8000;
	{$IFDEF WIN32}
	ZWSIZE = $8000;
	{$ELSE}
	ZWSIZE = $4000;
  {$ENDIF}

{ DEFLATE ************* }
	UNKNOWN  = 2;
	BINARY   = 0;
  ASCII    = 1;
  MIN_MATCH = 3;
  MAX_MATCH = 258;
  MAX_ZBITS = 15;
  LENGTH_CODES = 29;
  LITERALS = 256;
  L_CODES = LITERALS +1+LENGTH_CODES;
  D_CODES = 30;

	HASH_BITS = 15;

  MIN_LOOKAHEAD = MAX_MATCH+MIN_MATCH+1;
  MAX_DIST = WSIZE-MIN_LOOKAHEAD;

  { HASH_SIZE and WSIZE must be powers of two }
  HASH_SIZE = 1 shl HASH_BITS;
  HASH_MASK = HASH_SIZE-1;
  WMASK     = WSIZE-1;

  { Speed options for the general purpose bit flag }
  FAST = 4;
  SLOW = 2;

  { Matches of length 3 are discarded if their distance exceeds TOO_FAR }
  TOO_FAR = 4096;

  H_SHIFT = (HASH_BITS+MIN_MATCH-1) Div MIN_MATCH;
  EQUAL = 0;
  EOFile = -1;
{$IFDEF FULL_SEARCH}
  nice_match = MAX_MATCH;
{$ENDIF}

{ TREES }
  MAX_BL_BITS = 7;
  END_BLOCK = 256;
  BL_CODES = 19;
  STORED_BLOCK = 0;
  STATIC_TREES = 1;
  DYN_TREES = 2;
  LIT_BUFSIZE = $8000;
  DIST_BUFSIZE = LIT_BUFSIZE;
  REP_3_6 = 16;
  REPZ_3_10 = 17;
  REPZ_11_138 = 18;
  HEAP_SIZE = 2*L_CODES+1;
  SMALLEST = 1;
  STORE = 0;
  DEFLATEIT = 8;
  { BITS }
  Buf_size = (8*2*SizeOf(AnsiChar));
{ END DEFLATE *********** }

{$IFNDEF INFLATE_ONLY}
{ UNSHRINK }
	INIT_BITS = 9;
  FIRST_ENT = 257;
  CLEAR = 256;
{ EXPLODE }
{ UNREDUCE }
  DLE = 144;
{$ENDIF}
