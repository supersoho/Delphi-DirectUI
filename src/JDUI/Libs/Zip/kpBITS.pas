{ ********************************************************************************** }
{                                                                                    }
{ 	 COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: Bits.pas                                                          }
{     Description: VCLZip component - native Delphi zip component.                   }
{     Date:        March 1997                                                        }
{     Author:      Kevin Boylan, CIS: boylank                                        }
{                                Internet: boylank@compuserve.com                    }
{                                                                                    }
{ ********************************************************************************** }

{ $Log:  10018: kpBITS.pas 
{
{   Rev 1.0    8/14/2005 1:10:06 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.0    10/15/2002 8:15:12 PM  Supervisor
}
{
{   Rev 1.0    9/3/2002 8:16:56 PM  Supervisor
}
{
{   Rev 1.1    7/9/98 6:47:17 PM  Supervisor
{ Version 2.13
{ 
{ 1) New property ResetArchiveBitOnZip causes each file's 
{ archive bit to be turned  off after being zipped.
{ 
{ 2) New Property SkipIfArchiveBitNotSet causes files 
{ who's archive bit is not set to be skipped during zipping 
{ operations.
{ 
{ 3) A few modifications were made to allow more 
{ compatibility with BCB 1.
{ 
{ 4) Modified how directory information is used when 
{ comparing filenames to be unzipped.  Now it is always 
{ used.
}

{$P-} { turn off open parameters }
{$Q-} { turn off overflow checking }
{$R-} { turn off range checking }
{$B-} { turn off complete boolean eval } { 12/24/98  2.17 }


{* ===========================================================================
 * Initialize the bit string routines. 
 *} 
procedure bi_init;
    {zipfile = output zip file, NULL for in-memory compression }
begin
    bi_buf := 0;
    bi_valid := 0;
{$IFOPT D+}
{$IFDEF KPDEBUG}
    bits_sent := 0;
{$ENDIF}
{$ENDIF}
    {* Set the defaults for file compression. They are set by memcompress
     * for in-memory compression.
     *}
    if (zfile <> nil) then
     begin
        out_buf := ByteArrayPtr(@file_outbuf[0]);  { added typecast 5/18/98  2.13 }
        out_size := SizeOf(file_outbuf);
        out_offset := 0;
        read_buf  := file_read;
     end;
end;

{* ===========================================================================
 * Reverse the first len bits of a code, using straightforward code (a faster
 * method would use a table)
 * IN assertion: 1 <= len <= 15
 *}
function bi_reverse(code: usigned; len: LongInt): usigned;
var
  { code    = the value to invert }
  { len     = its bit length }
  res: usigned;
begin
  res := 0;
  Repeat
     res := res or (code and 1);
     code := code shr 1;
     res := res shl 1;
     Dec(len);
  Until len = 0;
  Result := res shr 1;
end;

procedure flush_outbuf(w, bytes: usigned); forward;

{* Output a 16 bit value to the bit stream, lower (oldest) byte first *}
procedure PUTSHORT(w: WORD);
begin
  if (out_offset < out_size-1) then
   begin
    {out_buf^[out_offset] := w and $ff;}
    out_buf^[out_offset] := LOBYTE(w);
    Inc(out_offset);
    {out_buf^[out_offset] := w shr 8;}
    out_buf^[out_offset] := HIBYTE(w);
    Inc(out_offset);
   end
  Else
    flush_outbuf(w,2);
end;

procedure PUTBYTE(b: usigned);
begin
  if (out_offset < out_size) then
   begin
    out_buf^[out_offset] := LOBYTE(b);
    Inc(out_offset);
   end
  Else
    flush_outbuf(b,1);
end;

{* ===========================================================================
 * Send a value on a given number of bits.
 * IN assertion: length <= 16 and value fits in length bits.
 *}
procedure send_bits(value, blength: LongInt);
    { value   = value to send }
    { length  = number of bits }
begin
    {$IFDEF ASSERTS}
    Assert((blength > 0) and (blength <= 15), 'invalid length in send_bits');
    {$ENDIF}
    {$IFDEF KPDEBUG}
    Inc(bits_sent,blength);
    {$ENDIF}
    {* If not enough room in bi_buf, use (valid) bits from bi_buf and
     * (16 - bi_valid) bits from value, leaving (width - (16-bi_valid))
     * unused bits in value.
     *}
    if (bi_valid > Buf_size - blength) then
     begin
        bi_buf := bi_buf or (value shl bi_valid);
        PUTSHORT(bi_buf);
        bi_buf := WORD(value) shr (Buf_size - bi_valid);
        bi_valid := bi_valid + (blength - Buf_size);
     end
    Else
     begin
        bi_buf := bi_buf or (value shl bi_valid);
        Inc(bi_valid,blength);
     end;
end;

{* ===========================================================================
 * Flush the current output buffer.
 *}
procedure flush_outbuf(w, bytes: usigned);
    { w       = value to flush }
    { bytes   = number of bytes to flush (0, 1 or 2) }
begin
    if (zfile = nil) then
     begin
        {error("output buffer too small for in-memory compression");}
     end;

    { Encrypt and write the output buffer: }
    if (out_offset <> 0) then
     begin
        zfwrite(@out_buf^[0], 1, out_offset);
        {if (ferror(zfile)) error ("write error on zip file");}
     end;
    out_offset := 0;
    if (bytes = 2) then
        PUTSHORT(w)
    Else if (bytes = 1) then
     begin
        out_buf^[out_offset] := LOBYTE(w);
        Inc(out_offset);
     end;
end;

{* ===========================================================================
 * Write out any remaining bits in an incomplete byte.
 *}
procedure bi_windup;
begin
    if (bi_valid > 8) then
        PUTSHORT(bi_buf)
    Else if (bi_valid > 0) then
        PUTBYTE(bi_buf);
    if (zfile <> nil) then
        flush_outbuf(0, 0);

    bi_buf := 0;
    bi_valid := 0;
{$IFOPT D+}
{$IFDEF KPDEBUG}
    bits_sent := (bits_sent+7) and (not 7);
{$ENDIF}
{$ENDIF}
end;

{* ===========================================================================
 * Copy a stored block to the zip file, storing first the length and its
 * one's complement if requested.
 *}
procedure copy_block(block: BytePtr; len: usigned; header: Integer);
    { block      = the input data }
    { len        = its length }
    { header     = true if block header must be written }
begin
    bi_windup;              { align on byte boundary }

    if (header <> 0) then
     begin
        PUTSHORT(WORD(len));
        PUTSHORT(WORD(not len));
        {$IFOPT D+}
        {$IFDEF KPDEBUG}
        Inc(bits_sent,2*16);
        {$ENDIF}
        {$ENDIF}
     end;
    if (zfile <> nil) then
     begin
        flush_outbuf(0, 0);
        zfwrite(block, 1, len);
        {if (ferror(zfile)) error ("write error on zip file");}
     end
    Else if (out_offset + len > out_size) then
        {error("output buffer too small for in-memory compression");}
    Else
     begin
        MoveMemory(@out_buf^[out_offset], block, len);
        Inc(out_offset,len);
     end;
end;
