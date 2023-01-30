{**********************************************************************}
{ Unit archived using GP-Version                                       }
{ GP-Version is Copyright 1997 by Quality Software Components Ltd      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.qsc.u-net.com                                             }
{**********************************************************************}

{ $Log:  10028: kpExpld.pas 
{
{   Rev 1.0    8/14/2005 1:10:08 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.0    10/15/2002 8:15:14 PM  Supervisor
}
{
{   Rev 1.0    9/3/2002 8:16:48 PM  Supervisor
}
{
{   Rev 1.1    Sat 04 Jul 1998   16:25:01  Supervisor
{ Modified ULONG to U_LONG because of ULONG 
{ definition in C++ Builder.
}

{ ********************************************************************************** }
{                                                                                    }
{ 	 COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: Explode.pas                                                       }
{     Description: VCLUnZip component - native Delphi unzip component.               }
{     Date:        March 1997                                                        }
{     Author:      Kevin Boylan, CIS: boylank                                        }
{                                Internet: boylank@compuserve.com                    }
{                                                                                    }
{ ********************************************************************************** }

{$Q-} { turn off overflow checking }
{$R-} { turn off range checking }

procedure Explode;
{ Explode an imploded compressed stream.  Based on the general purpose
   bit flag, decide on coded or uncoded literals, and an 8K or 4K sliding
   window.  Construct the literal (if any), length, and distance codes and
   the tables needed to decode them (using huft_build() from inflate.c),
   and call the appropriate routine for the type of data in the remainder
   of the stream.  The four routines are nearly identical, differing only
   in whether the literal is decoded or simply read in, and in how many
   bits are read in, uncoded, for the low distance bits. }

function get_tree(var l: llarraytype; n: WORD): short_int;
var
	i:		WORD;                 { bytes remaining in list }
  k:		WORD;                 { lengths entered }
  j:		WORD;                 { number of codes }
  b:		WORD;                 { bit length for those codes }
{ unsigned short_int *l; }           { bit lengths }
{ unsigned short_int n;  }           { number expected }
{ Get the bit lengths for a code representation from the compressed
   stream.  If get_tree() returns 4, then there is an error in the data.
   Otherwise zero is returned. }
begin
  { get bit lengths }
  ReadByte(bytebuf);
  i := bytebuf + 1;                      { length/count pairs to read }
  k := 0;                                 { next code }
  Repeat
    ReadByte(bytebuf);
    j := bytebuf;
    b := (j and $f) + 1;      { bits in code (1..16) }
    j := ((j and $f0) shr 4) + 1;          { codes with those bits (1..16) }
    if (k + j) > n then
     begin
      Result := 4;                         { don't overflow l[] }
      exit;
     end;
    Repeat
      l[k] := b;
      Inc(k);
      Dec(j);
    Until j = 0; { while (--j); }
    Dec(i);
  Until i = 0; { while (--i); }
  if k <> n then
  	Result := 4
  else
  	Result := 0;    { should have read n of them }
end;


function explode_lit(which: Integer; tb, tl, td: huftptr; bb, bl, bd: short_int): short_int;
{ struct huft *tb, *tl, *td; }     { literal, length, and distance tables }
{ short_int bb, bl, bd;          }     { number of bits decoded by those }
{ Decompress the imploded data using coded literals and an 8K sliding
   window. }
var
	s:				LongInt;      { bytes to decompress }
  e:				WORD;         { table entry flag/number of extra bits }
  n,d:			WORD;         { length and index for copy }
  w:				WORD;         { current window position }
  t:				huftptr;      { pointer to table entry }
  mb,ml,md:	WORD;         { masks for bb, bl, and bd bits }
  b:				U_LONG;        { bit buffer }
  k:				WORD;         { number of bits in bit buffer }
  u:				WORD;         { true if unflushed }
begin
  { explode the coded data }
  b := 0;
  k := 0;
  w := 0;                			{ initialize bit buffer, window }
  u := 1;                       { buffer unflushed }
  mb := mask_bits[bb];          { precompute masks for speed }
  ml := mask_bits[bl];
  md := mask_bits[bd];
  s := ucsize;
  while (s > 0) do                 		{ do until ucsize bytes uncompressed }
   begin
    NEEDBITS(1,b,k);
    if (b and 1) <> 0 then                  	{ then literal--decode it }
     begin
      DUMPBITS(1,b,k);
      Dec(s);
      NEEDBITS(WORD(bb),b,k);    			{ get coded literal }
      t := tb;
      Inc(t,(not(WORD(b))) and mb);
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
          Inc(t,(not(WORD(b))) and mask_bits[e]);
          e := t^.e;
        Until e <= 16; 
      DUMPBITS(t^.b,b,k);
	    slide^[w] := BYTE(t^.v.n);
      Inc(w);
      if (w = WSIZE) then
       begin
        flushslide(w);
        w := 0;
        u := 0;
       end;
     end
    else                        { else distance/length }
     begin
      DUMPBITS(1,b,k);
      { get distance low bits }
      if which = 8 then           { explode_lit8 }
       begin
      	NEEDBITS(7,b,k);
      	d := WORD(b) and $7f;
      	DUMPBITS(7,b,k);
       end
      else                         { explode_lit4 }
       begin
      	NEEDBITS(6,b,k);
      	d := WORD(b) and $3f;
      	DUMPBITS(6,b,k)
       end;
      NEEDBITS(WORD(bd),b,k);    { get coded distance high bits }
      t := td;
      Inc(t,(not(WORD(b))) and md);
      e := t^.e;
      if (e > 16) then
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
          Inc(t,(not(WORD(b))) and mask_bits[e]);
          e := t^.e;
        Until e <= 16; 
      DUMPBITS(t^.b,b,k);
      d := w - d - t^.v.n;       { construct offset }
      NEEDBITS(WORD(bl),b,k);    { get coded length }
      t := tl;
      Inc(t,(not(WORD(b))) and ml);
      e := t^.e;
      if (e > 16) then
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
          Inc(t,(not(WORD(b))) and mask_bits[e]);
          e := t^.e;
        Until e <= 16; 
      DUMPBITS(t^.b,b,k);
      n := t^.v.n;
      if (e <> 0) then                    { get length extra bits }
       begin
        NEEDBITS(8,b,k);
        Inc(n,WORD(b) and $ff);
        DUMPBITS(8,b,k)
       end;

      { do the copy }
      Dec(s,n);
      Repeat
      	d := d and (WSIZE-1);
        if d > w then
        	e := WSIZE - d
        else
        	e := WSIZE - w;
        if e > n then
        	e := n;
        Dec(n,e);
        if (u <> 0) and (w <= d) then
         begin
          ZeroMemory(@(slide^[w]), e);
          Inc(w,e);
          Inc(d,e);
         end
        else
          if (w - d >= e) then      { this test assumes unsigned short_int comparison }
           begin
           MoveMemory(@(slide^[w]), @(slide^[d]), e);
            Inc(w,e);
            Inc(d,e);
           end
          else                  { do it slow to avoid memcpy() overlap }
            Repeat
              slide^[w] := slide^[d];
              Inc(w);
              Inc(d);
              Dec(e);
            Until e = 0; 
        if (w = WSIZE) then
         begin
          flushslide(w);
          w := 0;
          u := 0;
         end;
      Until n = 0; 
     end;
   end;

  { flush out slide }
  flushslide(w);
  if csize = 0 then     { should have read csize bytes }
  	Result := 0
  else
  	Result := 5;
end;

function explode_nolit(which: Integer; tl, td: huftptr; bl, bd: short_int): short_int;
{ struct huft *tl, *td; }    { length and distance decoder tables }
{ short_int bl, bd;         }    { number of bits decoded by tl[] and td[] }
{ Decompress the imploded data using uncoded literals and an 8K or 4K sliding
   window. }
var
	s:				LongInt;      { bytes to decompress }
  e:				WORD;         { table entry flag/number of extra bits }
  n,d:			WORD;         { length and index for copy }
  w:				WORD;         { current window position }
  t:				huftptr;      { pointer to table entry }
  ml,md:  		WORD;         { masks for bl and bd bits }
  b:				U_LONG;        { bit buffer }
  k:				WORD;         { number of bits in bit buffer }
  u:				WORD;         { true if unflushed }
begin
  { explode the coded data }
  b := 0;
  k := 0;
  w := 0;                { initialize bit buffer, window }
  u := 1;                        { buffer unflushed }
  ml := mask_bits[bl];           { precompute masks for speed }
  md := mask_bits[bd];
  s := ucsize;
  while (s > 0) do                { do until ucsize bytes uncompressed }
   begin
    NEEDBITS(1,b,k);
    if (b and 1) <> 0 then                  { then literal--get eight bits }
     begin
      DUMPBITS(1,b,k);
      Dec(s);
      NEEDBITS(8,b,k);
	    slide^[w] := BYTE(b);
      Inc(w);
      if (w = WSIZE) then
       begin
        flushslide(w);
        w := 0;
        u := 0;
       end;
      DUMPBITS(8,b,k);
     end
    else                        { else distance/length }
     begin
      DUMPBITS(1,b,k);
      if which = 8 then
       begin
      	NEEDBITS(7,b,k);               { get distance low bits }
      	d := WORD(b) and $7f;
      	DUMPBITS(7,b,k);
       end
      else
       begin
      	NEEDBITS(6,b,k);               { get distance low bits }
      	d := WORD(b) and $3f;
      	DUMPBITS(6,b,k);
       end;
      NEEDBITS(WORD(bd),b,k);    { get coded distance high bits }
      t := td;
      Inc(t,(not(WORD(b))) and md);
      e := t^.e;
      if (e > 16) then
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
          Inc(t,(not(WORD(b))) and mask_bits[e]);
          e := t^.e;
        Until e <= 16; 
      DUMPBITS(t^.b,b,k);
      d := w - d - t^.v.n;       { construct offset }
      NEEDBITS(WORD(bl),b,k);    { get coded length }
      t := tl;
      Inc(t,(not(WORD(b))) and ml);
      e := t^.e;
      if (e > 16) then
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
          Inc(t,(not(WORD(b))) and mask_bits[e]);
          e := t^.e;
        Until e <= 16; 
      DUMPBITS(t^.b,b,k);
      n := t^.v.n;
      if (e <> 0) then                    { get length extra bits }
       begin
        NEEDBITS(8,b,k);
        Inc(n,WORD(b) and $ff);
        DUMPBITS(8,b,k);
       end;

      { do the copy }
      Dec(s,n);
      Repeat
      	d := d and (WSIZE-1);
        if d > w then
        	e := WSIZE - d
        else
        	e := WSIZE - w;
        if e > n then
        	e := n;
        Dec(n,e);
        if (u <> 0) and (w <= d) then
         begin
         	ZeroMemory( @(slide^[w]), e );
          Inc(w,e);
          Inc(d,e);
         end
        else
          if (w - d >= e) then      { (this test assumes unsigned short_int comparison) }
           begin
            MoveMemory(@(slide^[w]), @(slide^[d]), e);
            Inc(w,e);
            Inc(d,e);
           end
          else                  { do it slow to avoid memcpy() overlap }
            Repeat
              slide^[w] := slide^[d];
              Inc(w);
              Inc(d);
              Dec(e);
            Until e = 0;
        if (w = WSIZE) then
         begin
          flushslide(w);
          w := 0;
          u := 0;
         end;
      Until n = 0;
     end;
	 end;

  { flush out slide }
  flushslide(w);
  if csize = 0 then      { should have read csize bytes }
  	Result := 0
  else
  	Result := 5;
end;


{ Main Explode Procedure }
var
	r:		WORD;                  { return codes }
  tb:	huftptr;               { literal code table }
  tl:	huftptr;               { length code table }
  td:	huftptr;               { distance code table }
  bb:	short_int;                 { bits for tb }
  bl:	short_int;                 { bits for tl }
  bd:	short_int;                 { bits for td }
  l:		llarraytype; 			  { bit lengths for codes }

   { Tune base table sizes.  Note: I thought that to truly optimize speed,
     I would have to select different bl, bd, and bb values for different
     compressed file sizes.  I was suprised to find out the the values of
     7, 7, and 9 worked best over a very wide range of sizes, except that
     bd = 8 worked marginally better for large compressed sizes. }
begin
  bl := 7;
  if csize > 200000 then
  	bd := 8
  else
  	bd := 7;
  { With literal tree--minimum match length is 3 }
  hufts := 0;                    { initialze huft's malloc'ed }
  if (file_info.general_purpose_bit_flag and 4) <> 0 then
  begin
    bb := 9;                     { base table size for literals }
    r := get_tree(l, 256);
    if (r <> 0) then
     begin
{     	Result := r; }
        exit;
     end;
    r := huft_build(l, 256, 256, [0], [0], @tb, bb);
    if (r <> 0) then
     begin
      if (r = 1) then
        huft_free(tb);
{      Result := r; }
      exit;
     end;
    r := get_tree(l, 64);
    if (r <> 0) then
     begin
{     	Result := r; }
        exit;
     end;
    r := huft_build(l, 64, 0, cplen3, extra, @tl, bl);
    if (r <> 0) then
     begin
      if (r = 1) then
        huft_free(tl);
      huft_free(tb);
{      Result := r; }
      exit;
     end;
    r := get_tree(l, 64);
    if (r <> 0) then
     begin
{      Result := r; }
      exit;
     end;
    if (file_info.general_purpose_bit_flag and 2) <> 0 then      { true if 8K }
     begin
      r := huft_build(l, 64, 0, cpdist8, extra, @td, bd);
      if (r <> 0) then
       begin
        if (r = 1) then
          huft_free(td);
        huft_free(tl);
        huft_free(tb);
{        Result := r; }
        exit;
       end;
      {r :=} explode_lit(8, tb, tl, td, bb, bl, bd);
     end
    else                                        { else 4K }
     begin
      r := huft_build(l, 64, 0, cpdist4, extra, @td, bd);
      if (r <> 0) then
       begin
        if (r = 1) then
          huft_free(td);
        huft_free(tl);
        huft_free(tb);
{        Result := r; }
        exit;
       end;
      {r :=} explode_lit(4, tb, tl, td, bb, bl, bd);
     end;
    huft_free(td);
    huft_free(tl);
    huft_free(tb);
   end
  else
  { No literal tree--minimum match length is 2 }
   begin
    r := get_tree(l, 64);
    if (r <> 0) then
     begin
{      Result := r; }
      exit;
     end;
    r := huft_build(l, 64, 0, cplen2, extra, @tl, bl);
    if (r <> 0) then
     begin
      if (r = 1) then
        huft_free(tl);
{      Result := r; }
      exit;
     end;
    r := get_tree(l, 64);
    if (r <> 0) then
     begin
{      Result := r; }
      exit;
     end;
    if (file_info.general_purpose_bit_flag and 2) <> 0 then     { true if 8K }
     begin
      r := huft_build(l, 64, 0, cpdist8, extra, @td, bd);
      if (r <> 0) then
       begin
        if (r = 1) then
          huft_free(td);
        huft_free(tl);
{        Result := r; }
        exit;
       end;
      {r :=} explode_nolit(8, tl, td, bl, bd);
     end
    else                                        { else 4K }
     begin
      r := huft_build(l, 64, 0, cpdist4, extra, @td, bd);
      if (r <> 0) then
       begin
        if (r = 1) then
          huft_free(td);
        huft_free(tl);
{        Result := r; }
        exit;
       end;
      {r :=} explode_nolit(4, tl, td, bl, bd);
     end;
    huft_free(td);
    huft_free(tl);
   end;
   xFlushOutput;
{  Result := r; }
end;
