{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10034: kpInflt.pas 
{
{   Rev 1.0    8/14/2005 1:10:08 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.0    10/15/2002 8:15:14 PM  Supervisor
}
{
{   Rev 1.1    9/18/2002 12:45:48 PM  Supervisor
{ Added ZLib
}
{
{   Rev 1.0    9/3/2002 8:16:50 PM  Supervisor
}
{ ********************************************************************************** }
{                                                                                    }
{ 	 COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: Inflate.pas                                                       }
{     Description: VCLUnZip component - native Delphi unzip component.               }
{     Date:        March 1997                                                        }
{     Author:      Kevin Boylan, boylank@bigfoot.com                                 }
{                                                                                    }
{                                                                                    }
{ ********************************************************************************** }

{$IFNDEF USE_ZLIB}

{$Q-}
{$R-}

procedure kpInflate;
var
	wp: WORD;
  bb: U_LONG;
  bk: WORD;
  lbits: short_int;          { bits in base literal/length lookup table }
	dbits: short_int;          { bits in base distance lookup table }

{****************************************************************************}
function inflate_codes( tl, td: huftptr; bl, bd: short_int ): short_int;
{ tl,td = literal/length and distance decoder tables }
{ bl, bd = number of bits decoded by tl[] and td[] }
{ inflate (decompress) the codes in a deflated (compressed) block.
   Return an error code or zero if it all goes ok. }
var
	e: 		WORD;            	{ table entry flag/number of extra bits }
  n,d: 		WORD;             { length and index for copy }
  w:			WORD;            	{ current window position }
  t:			huftptr;    		{ pointer to table entry }
  ml,md:   WORD;            	{ masks for bl and bd bits }
  b:			U_LONG;         	{ bit buffer }
  k:			WORD;            	{ number of bits in bit buffer }
begin
  { make local copies of globals }
  b := bb;                       { initialize bit buffer }
  k := bk;
  w := wp;                       { initialize window position }

  { inflate the coded data }
  ml := mask_bits[bl];           { precompute masks for speed }
  md := mask_bits[bd];
  while True do                     { do until end of block }
   begin
    NEEDBITS(bl,b,k);
    t := tl;

    if (t = nil) then
     begin
        Result := 1;
        exit;
     end;

    Inc(t,WORD(b) and ml);
    e := t^.e;
    if (e  > 16) then
      Repeat
        if (e = 99) then
         begin
          Result := 1;
          exit;
         end;
        DUMPBITS(t^.b,b,k);
        Dec(e,16);
        NEEDBITS(e,b,k);
        t := t^.v.t;
        Inc(t,WORD(b) and mask_bits[e]);
        e := t^.e;
      Until ( e <= 16);
    DUMPBITS(t^.b,b,k);
    if (e = 16) then               { then it's a literal }
     begin
	  		slide^[w] := BYTE(t^.v.n);
        Inc(w);
      	if (w >= WSIZE) then
      	 begin
        	flushslide(w);
        	w := 0;
      	 end;
     end
    else                        { it's an EOB or a length }
     begin
      { exit if end of block }
      if (e = 15) then
        break;

      { get length of block to copy }
      NEEDBITS(e,b,k);
      n := t^.v.n + (WORD(b) and mask_bits[e]);
      DUMPBITS(e,b,k);

      { decode distance of block to copy }
      NEEDBITS(bd,b,k);
      t := td;
      Inc(t,WORD(b) and md);
      e := t^.e;
      if (e  > 16) then
        Repeat
          if (e = 99) then
           begin
            Result := 1;
            exit;
           end;
          DUMPBITS(t^.b,b,k);
          Dec(e,16);
          NEEDBITS(e,b,k);
          t := t^.v.t;
          Inc(t,WORD(b) and mask_bits[e]);
          e := t^.e;
        Until ( e<=16 );
      DUMPBITS(t^.b,b,k);
      NEEDBITS(e,b,k);
      d := w - t^.v.n - (WORD(b) and mask_bits[e]);
      DUMPBITS(e,b,k);

      { do the copy }
      Repeat
      	d := d and (WSIZE-1);
      	if (d > w) then
        	e := WSIZE - d
        else
        	e := WSIZE - w;
        if (e > n) then
        	e := n;
        Dec(n,e);
        if ((w - d) >= e) then        { (this test assumes unsigned short_int comparison) }
         begin
          MoveMemory(@(slide^[w]), @(slide^[d]), e);
          Inc(w,e);
          Inc(d,e);
         end
        else                      { do it slow to avoid memcpy() overlap }
          Repeat
            slide^[w] := slide^[d];
            Inc(w);
            Inc(d);
            Dec(e);
          Until (e = 0);
        if (w >= WSIZE) then
         begin
          flushslide(w);
          w := 0;
         end;
      Until (n = 0);
     end;
   end; { while True }

   { restore the globals from the locals }
   wp := w;		{ restore global window pointer }
   bb := b;      { restore global bit buffer }
   bk := k;

   Result := 0;   { Done }
end;

{****************************************************************************}
function inflate_dynamic: short_int;
{ decompress an inflated type 2 (dynamic Huffman codes) block. }
var
	i: short_int;							{ temporary variables }
	j: WORD;
	l: WORD;											{ last length }
	m: WORD;											{ mask for bit lengths table }
	n: WORD;											{ number of lengths to get }
	tl: huftptr;									{ literal/length code table }
	td: huftptr;									{ distance code table }
	bl: short_int;										{ lookup bits for tl }
	bd: short_int;										{ lookup bits for td }
	nb: WORD;										{ number of bit length codes }
	nl: WORD;										{ number of literal/length codes }
	nd: WORD;										{ number of distance codes }
	ll: llarraytype;								{ literal/length and distance code lengths }
  llptr: llarrayptr;
	b: U_LONG;										{ bit buffer }
	k: WORD;											{ number of bits in bit buffer }

begin
  tl := nil;
  td := nil;
  { make local bit buffer }
  b := bb;
  k := bk;
try
  { read in table lengths }
  NEEDBITS(5,b,k);
  nl := 257 + (b and $1f);      { number of literal/length codes }
  DUMPBITS(5,b,k);
  NEEDBITS(5,b,k);
  nd := 1 + (b and $1f);        { number of distance codes }
  DUMPBITS(5,b,k);
  NEEDBITS(4,b,k);
  nb := 4 + (b and $f);         { number of bit length codes }
  DUMPBITS(4,b,k);
  if (nl > 286) or (nd > 30) then
   begin
    Result := 1;                   { bad lengths }
    exit;
   end;

  { read in bit-length-code lengths }
  j := 0;
  while (j < nb) do
   begin
    NEEDBITS(3,b,k);
    ll[border[j]] := b and 7;
    DUMPBITS(3,b,k);
    Inc(j);
   end;
  while (j < 19) do
   begin
   	ll[border[j]] := 0;
     Inc(j);
   end;

  { build decoding table for trees--single level, 7 bit lookup }
  bl := 7;
  i := huft_build(ll, 19, 19, [0], [0], @tl, bl);
  if (i <> 0) then
   begin
    if (i = 1) then
      huft_free(tl);
    	 Result := i;                   { incomplete code set }
      exit;
   end;

  { read in literal and distance code lengths }
  n := nl + nd;
  m := mask_bits[bl];
  i := 0;
  l := 0;

  while (WORD(i) < n) do
   begin
    NEEDBITS(bl,b,k);
    td := tl;
    Inc(td,(b and m));
    j := td^.b;
    {j = (td = tl + ((unsigned short_int)b & m))->b;}
    DUMPBITS(j,b,k);
    j := td^.v.n;
    if (j < 16) then            	{ length of code in bits (0..15) }
     begin
      ll[i] := j;          			{ save last length in l }
      l := j;
      Inc(i);
     end
    else if (j = 16) then          { repeat last length 3 to 6 times }
     begin
      NEEDBITS(2,b,k);
      j := 3 + (b and 3);
      DUMPBITS(2,b,k);
      if ((i + j) > n) then
       begin
        Result := 1;
        exit;
       end;
      while (j>0) do
       begin
        ll[i] := l;
        Inc(i);
        Dec(j);
       end;
     end
    else if (j = 17) then           { 3 to 10 zero length codes }
     begin
      NEEDBITS(3,b,k);
      j := 3 + (b and 7);
      DUMPBITS(3,b,k);
      if ((i + j) > n) then
       begin
        Result := 1;
        exit;
       end;
      while (j>0) do
       begin
        ll[i] := 0;
        Inc(i);
        Dec(j);
       end;
      l := 0;
     end
    else                        { j == 18: 11 to 138 zero length codes }
     begin
      NEEDBITS(7,b,k);
      j := 11 + (b and $7f);
      DUMPBITS(7,b,k);
      if ((i + j) > n) then
       begin
        Result := 1;
        exit;
       end;
      while (j>0) do
       begin
        ll[i] := 0;
        Inc(i);
        Dec(j);
       end;
      l := 0;
     end;
   end;  { while (i < n) do }


  { free decoding table for trees }
  huft_free(tl);


  { restore the global bit buffer }
  bb := b;
  bk := k;


  { build the decoding tables for literal/length and distance codes }
  bl := lbits;
  i := huft_build(ll, nl, 257, cplens, cplext, @tl, bl);

  if (i <> 0) then
   begin
    if (i = 1) then
      huft_free(tl);
    Result := i;                   { incomplete code set }
    exit;
   end;
  bd := dbits;
  llptr := llarrayptr(@ll[nl]); { added typecast 5/18/98  2.13 }
  i := huft_build(llptr^, nd, 0, cpdist, cpdext, @td, bd);
  if (i <> 0) then
   begin
    if (i = 1) then
      huft_free(td);
    huft_free(tl);
    Result := i;                   { incomplete code set }
    exit;
   end;

  { decompress until an end-of-block code }
  if (inflate_codes(tl, td, bl, bd) <> 0) then
   begin
    Result := 1;
     huft_free(tl);
     huft_free(td);
    exit;
   end;

  huft_free(tl);
  huft_free(td);
  Result := 0;

except
  { free the decoding tables, return }
  on EUserCanceled do
   begin
     huft_free(tl);
     huft_free(td);
     raise;
   end
  else
   begin
     huft_free(tl);
     huft_free(td);
     Result := 1;
   end;
end;

end;

{****************************************************************************}
function inflate_stored: short_int;
var
	n:		WORD;           { number of bytes in block }
	w:		WORD;           { number of bytes in block }
	b:		U_LONG;        { bit buffer }
	k:		WORD;           { number of bits in bit buffer }
  tmp:	WORD;
begin

  { make local copies of globals }
  b := bb;                       { initialize bit buffer }
  k := bk;
  w := wp;                       { initialize window position }


  { go to byte boundary }
  n := k and 7;
  DUMPBITS(n,b,k);


  { get the length and its complement }
  NEEDBITS(16,b,k);
  n := (WORD(b) and $ffff);
  DUMPBITS(16,b,k);
  NEEDBITS(16,b,k);
  tmp := WORD(((not b) and ($ffff)));
  if (n <> tmp) then
   begin
    Result := 1;
    exit;
   end;                   { error in compressed data }
  DUMPBITS(16,b,k);


  { read and output the compressed data }
  while (n <> 0) do
   begin
    NEEDBITS(8,b,k);
    slide^[w] := b;
    Inc(w);
    if (w = WSIZE) then
     begin
      flushslide(w);
      w := 0;
     end;
    DUMPBITS(8,b,k);
    Dec(n);
   end;


  { restore the globals from the locals }
  wp := w;                       { restore global window pointer }
  bb := b;                       { restore global bit buffer }
  bk := k;
  Result := 0;


end;

{****************************************************************************}
function inflate_fixed: short_int;
var
  i:			short_int;                	{ temporary variable }
  tl:		huftptr;      				{ literal/length code table }
  td:		huftptr;      				{ distance code table }
  bl:		short_int;               	{ lookup bits for tl }
  bd:		short_int;               	{ lookup bits for td }
  l:			array[0..287] of WORD;	{ length list for huft_build }
{ decompress an inflated type 1 (fixed Huffman codes) block.  We should
   either replace this with a custom decoder, or at least precompute the
   Huffman tables. }
begin
  tl := nil;
  td := nil;
  { set up literal table }
  for i := 0 to 143 do
    l[i] := 8;
  for I := 144 to 255 do
    l[i] := 9;
  for i := 256 to 279 do
    l[i] := 7;
  for i := 280 to 287 do          { make a complete, but wrong code set }
    l[i] := 8;
  bl := 7;
try
  i := huft_build(l, 288, 257, cplens, cplext, @tl, bl);
  if ( i <> 0) then
   begin
    Result := i;
    exit;
   end;

  { set up distance table }
  for i := 0 to 29 do      { make an incomplete code set }
    l[i] := 5;
  bd := 5;
  i := huft_build(l, 30, 0, cpdist, cpdext, @td, bd);
  if (i > 1) then
   begin
    huft_free(tl);
    Result := i;
    exit;
   end;

  { decompress until an end-of-block code }
  if (inflate_codes(tl, td, bl, bd) <> 0) then
   begin
    Result := 1;
     huft_free(tl);
     huft_free(td);
    exit;
   end;

  { free the decoding tables, return }
  huft_free(tl);
  huft_free(td);
  Result := 0;

except
  on EUserCanceled do
   begin
     huft_free(tl);
     huft_free(td);
     raise;
   end
  else
   begin
     huft_free(tl);
     huft_free(td);
     Result := 1;
   end;
end;
end;


{****************************************************************************}
function inflate_block(var e:short_int): short_int;
var
  t: WORD;           { block type }
  b: U_LONG;     		{ bit buffer }
  k: WORD;  			{ number of bits in bit buffer }

begin
{e = last block flag }
{ decompress an inflated block }
{ make local bit buffer }
  b := bb;
  k := bk;

  { read in last block bit }
  NEEDBITS(1,b,k);
  e := b and 1;
  DUMPBITS(1,b,k);

  { read in block type }
  NEEDBITS(2,b,k);
  t := b and 3;
  DUMPBITS(2,b,k);

  { restore the global bit buffer }
  bb := b;
  bk := k;

try
  { inflate that block type }
  if (t = 2) then
  	Result := inflate_dynamic
  else if (t = 0) then
  	Result := inflate_stored
  else if (t = 1) then
  	Result := inflate_fixed
  else { bad block type }
  	Result := 2;
except
  on EUserCanceled do
     raise
  else
     Result := 1;
end;
end;

{*********************** main inflate procedure **********************}
var
  e: short_int;                	{ last block flag }
  h: WORD;       				{ maximum struct huft's malloc'ed }
begin
{ decompress an inflated entry }
  { initialize window, bit buffer }
  wp := 0;
  bk := 0;
  bb := 0;
  lbits := 9;
  dbits := 6;
  { decompress until the last block }
  h := 0;
  Repeat
    hufts := 0;
    if (inflate_block(e) <> 0) then
      exit;
    if (hufts > h) then
      h := hufts;
  Until(e <> 0);

  { flush out slide }
  flushslide(wp);
  xFlushOutput;
end;

{$ENDIF}

{   Sat 04 Jul 1998   16:23:24  Supervisor
{ Modified ULONG to U_LONG because of ULONG
{ definition in C++ Builder.
}
{
{   Mon 27 Apr 1998   17:26:16  Supervisor
{ Modified to get rid of some memory leak
}


