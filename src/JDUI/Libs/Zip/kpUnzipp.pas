{ ********************************************************************************** }
{                                                                                    }
{   COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: Unzipp.pas                                                        }
{     Description: VCLUnZip component - native Delphi unzip component.               }
{     Date:        March 1997                                                        }
{     Author:      Kevin Boylan, boylank@bigfoot.com                                 }
{                                                                                    }
{                                                                                    }
{ ********************************************************************************** }


{$P-} { turn off open parameters }
{$Q-} { turn off overflow checking }
{$R-} { turn off range checking }
{$B-} { turn off complete boolean eval } { 12/24/98  2.17 }

function TVCLUnZip.UnZipFiles( zip_in_file: TkpStream ): Integer;
var
   csize: BIGINT;
    ucsize: BIGINT;
    area: ^work;
    outcnt: WORD;
    hufts: WORD;
    slide: slidearrayptr;
   inbuf,
    inptr,
    outbuf,
    outptr: BYTEPTR;
    incnt: WORD;
    bitbuf: U_LONG;
    bits_left: WORD;
    zipeof: LongBool;
    outpos: BIGINT;
    zip_out_file: TkpStream;
    bytebuf: WORD;
    FileCount: Integer;
    RepeatFile: Boolean;
    NumUnZipped: Integer;
    Retry: Boolean;

{$I kpFile.Pas}

{****************************************************************************}
function huft_free(var t: huftptr): short_int;
var
 p: huftarrayptr;
  q,z:   huftptr;
begin
{ t =  table to free }
{ Free the malloc'ed tables built by huft_build(), which makes a linked
   list of the tables it made, with the links in a dummy first entry of
   each table. }
{ Go through linked lIst, freeing from the malloced (t[-1]) address. }
  z := t;
try
  while (z <> nil) do
   begin
     Dec(z);
     p := huftarrayptr(z);
     q := z^.v.t;
     StrDispose( PAnsiChar(p) );
     {FreeMem(p);}
     z := q;
   end;
  t := nil;
  Result := 0;
except
  t := nil;
  Result := 1;
  exit;
end;
end;

{****************************************************************************}
function huft_build(b: array of WORD; n,s: WORD; d,e: array of WORD;
        t:huftptrptr; var m: short_int): short_int;
{ b =   code lengths in bits (all assumed <= BMAX) }
{ n =  number of codes (assumed <= N_MAX)     }
{ s =  number of simple-valued codes (0..s-1)   }
{ d =  list of base values for non-simple codes   }
{ e =  list of extra bits for non-simple codes   }
{ t =  result: starting table         }
{ m =  maximum lookup bits, returns actual    }
{ Given a list of code lengths and a maximum table size, make a set of
   tables to decode that set of codes.  Return zero on success, one if
   the given code set is incomplete (the tables are still built in this
   case), two if the input is invalid (all zero length codes or an
   oversubscribed set of lengths), and three if not enough memory. }
var
  a:  WORD;                    { counter for codes of length k }
  c:  array[0..BMAX] of WORD;  { bit length count table }
  f:  WORD;                    { i repeats in table every f entries }
  g:  short_int;                   { maximum code length }
  h:  short_int;                   { table level }
  i:  WORD;              { counter, current code }
  j:  WORD;              { counter }
  k:  short_int;                 { number of bits in current code }
  l:  short_int;                    { bits per table (returned in m) }
  p:  Integer;             { pointer into c[], b[], or v[] }
  q:  huftarrayptr;      { points to current table }
  r:  huft;                  { table entry for structure assignment }
  u:  array[0..BMAX-1] of huftarrayptr; { table stack }
 v:  array[0..N_MAX-1] of WORD; { values in order of bit length }
  w:  short_int;                 { bits before this table == (l * h) }
  x:  array[0..BMAX] of WORD;   { bit offsets, then code stack }
  xp: Integer;                  { pointer into x }
  y:  short_int;                  { number of dummy codes added }
  z:  WORD;                    { number of entries in current table }
begin
  { Generate counts for each bit length }
{//$//IFNDEF KPSMALL}
try
{//$//ENDIF}
 ZeroMemory(@c, SizeOf(c));
  p := 0;
  i := n;
  Repeat
    Inc(c[b[p]]);
    Inc(p);
    Dec(i);                  { assume all entries <= BMAX }
  Until (i=0);
  if (c[0] = n) then               { null input--all zero length codes }
   begin
     t^ := nil;
     m := 0;
     Result := 0;
     exit;
   end;

 { Find minimum and maximum length, bound *m by those }
  l := m;
  j := 1;
  while ((j<=BMAX) and (c[j]=0)) do
   Inc(j);
  k := j;                        { minimum code length }
  if (WORD(l) < j) then
    l := j;
  i := BMAX;
  while ((i>0) and (c[i]=0)) do   { changed from >= 7/19/98  2.14}
   Dec(i);
  g := i;                        { maximum code length }
  if (WORD(l) > i) then
    l := i;
  m := l;

  { Adjust last length count to fill out codes, if needed }
  y := short_int(1 shl j);
  while (j<i) do
   begin
    Dec(y,c[j]);
     if y < 0 then
      begin
       Result := 2;
        exit;
      end;
    y := short_int(y shl 1);
     Inc(j);
   end;
  Dec(y,c[i]);
  if y < 0 then
   begin
    Result := 2;
     exit;
   end;
  Inc(c[i],y);

 { Generate starting offsets into the value table for each length }
  x[1] := 0;
  j := 0;
  p := 1;
  xp := 2;
  Dec(i);
  while (i>0) do                 { note that i == g from above }
   begin
    Inc(j,c[p]);
     Inc(p);
     x[xp] := j;
     Inc(xp);
     Dec(i);
   end;

 { Make a table of values in order of bit lengths }
  p := 0;  i := 0;
  Repeat
   j := b[p];
     Inc(p);
     if (j <> 0) then
      begin
      v[x[j]] := i;
        Inc(x[j]);
      end;
   Inc(i);
  Until (i>=n);

  { Generate the Huffman codes and for each, make the table entries }
  x[0] := 0;
  i := 0;                 { first Huffman code is zero }
  p := 0;             { grab values in bit order }
  h := -1;                { no tablEs yet--level -1 }
  w := -l;                { bits decoded == (l * h) }
  u[0] := nil;      { just to keep compilers happy }
  q := nil;         { ditto }
  z := 0;                 { ditto }

 { go through the bit lengths (k already is bits in shortest code) }
  while ( k <= g ) do
   begin
     a := c[k];
     while (a <> 0) do
      begin
       Dec(a);
       { here i is the Huffman code of length k bits for value *p }
       { make tables up to required level }
       while (k > (w + l)) do
        begin
           Inc(h);
           Inc(w,l);                 { previous table always l bits }
           { compute minimum size table less than or equal to l bits }
           z := g - w;
           if (z > WORD(l)) then
              z := l;
           j := k - w;
           f := WORD(WORD(1) shl j);
           if (f > (a+1)) then      { too few codes for k-w bit table }
            begin
              Dec(f,(a+1));         { deduct codes from patterns left }
              xp := k;
              Inc(j);
              while (j < z) do       { try smaller tables up to z bits }
               begin
                 f := WORD(f shl 1);
                 Inc(xp);
                 if (f <= c[xp]) then
                 break;            { enough codes to use up j bits }
                 Dec(f,c[xp]);     { else deduct codes from patterns }
                 Inc(j);
               end;
            end;
           z := WORD(WORD(1) shl j);             { table entries for j-bit table }

         { allocate and link in new table }
           try
              q := huftarrayptr( StrAlloc((z+1)*SizeOf(huft)));
              {GetMem( q, (z+1)*SizeOf(huft));}
           except
              if (h <> 0) then
               begin
                 t^ := @u[0]^[0];
                 huft_free(t^);
               end;
              tmpMStr := LoadStr(IDS_LOWMEM);
              //MessageBox(0, StringAsPChar(tmpMStr),'Error',mb_OK );
              DoHandleMessage(IDS_LOWMEM,StringAsPChar(tmpMStr),'Error',mb_OK );
              Result := 3;
              exit;
           end;

           if q = nil then
            begin
              if (h <> 0) then
               begin
                 t^ := @u[0]^[0];
                 huft_free(t^);
               end;
              tmpMStr := LoadStr(IDS_LOWMEM);
              //MessageBox(0, StringAsPChar(tmpMStr),'Error',mb_OK );
              DoHandleMessage(IDS_LOWMEM,StringAsPChar(tmpMStr),'Error',mb_OK );
              Result := 3;
              exit;
            end;

           Inc(hufts,z + 1);          { track memory usage }
           t^ := @q^[0];
           q^[-1].v.t := nil;
           t := @(q^[-1].v.t);
           { added typecast 5/18/98  2.13 }
           u[h] := huftarrayptr(@q^[0]); { table starts after link }

           { connect to last table, if there is one }
           if (h<>0) then
            begin
              x[h] := i;              { save pattern for backing up }
              r.b := BYTE(l);           { bits to dump before this table }
              r.e := BYTE(16 + j);    { bits in this table }
              r.v.t := @q^[0];         { pointer to this table }
              j := WORD(i shr (w - l));     { (get around Turbo C bug) }
              u[h-1]^[j-1] := r;         { connect to last table }
            end;
        end; { while (a <> 0) do }

        { set up table entry in r }
        r.b := BYTE(k - w);
        if (p >= n) then
           r.e := 99               { out of values--invalid code }
        else if (v[p] < s) then
         begin
           if v[p] < 256 then   { 256 is end-of-block code }
              r.e := 16
           else
              r.e := 15;
           r.v.n := v[p];           { simple code is just the value }
           Inc(p);
         end
        else
         begin
           If v[p]-s < N_MAX then
            begin
              r.e := BYTE(e[v[p] - s]);  { non-simple--look up in lists }
              r.v.n := d[v[p] - s];
              Inc(p);
            end
           Else
              r.e := 99;
         end;

      { fill code-like entries with r }
      f := WORD(WORD(1) shl (k - w));
      j := WORD(i shr w);
      while (j<z) do
       begin
        q^[j] := r;
        Inc(j,f);
       end;

      { backwards increment the k-bit code i }
      j := WORD(WORD(1) shl (k - 1));
      while ((i and j) <> 0) do
       begin
        i := i xor j;
        j := WORD(j shr 1);
       end;
      i := i xor j;

      { backup over finished tables }
      while ((i and (WORD((WORD(1) shl w))-1)) <> x[h]) do
       begin
        Dec(h);                    { don't need to update q }
        Dec(w,l);
       end;
      end;  { while (a <> 0) do }
     Inc(k);
   end;  { while ( k <= g ) do }

   If (y <> 0) and (g <> 1) then
    Result := 1
   else
    Result := 0;
{//$I//FNDEF KPSMALL}
except
  Result := 1;
  Exit;
end;
{//$//ENDIF}
end;

{****************************************************************************}
procedure flushslide(w: WORD);
var
  n: WORD;
  p: BYTEPTR;
begin
{ w = number of bytes to flush }
{ Do the equivalent of OUTB for the bytes slide[0..w-1]. }
  p := @slide^[0];
  while(w <> 0) do
   begin
    n := OUTBUFSIZ - outcnt;
    If n >= w then
      n := w;
    MoveMemory(outptr, p, n);       { try to fill up buffer }
    Inc(outptr,n);
    Inc(outcnt,n);
    If (outcnt = OUTBUFSIZ) then
      xFlushOutput;            { if full, empty }
    Inc(p,n);
    Dec(w,n);
   end;
end;

{*******************  UnZip Methods  *********************}
{$I kpInflt.Pas}
{$IFNDEF INFLATE_ONLY}
{$I kpUnrdc.Pas}
{$I kpExpld.Pas}
{$I kpUshrnk.Pas}
{$ENDIF}
{****************************************************************************}

{$IFDEF USE_ZLIB}

procedure kpInflate;
const
  BUFFERSIZE = OUTBUFSIZ;
var
  zstream: TZStreamRec;
  Param:   Integer;
  Stat:    Integer;
  OK:      Boolean;
begin
  outcnt := kpmin( file_info.compressed_size, OUTBUFSIZ );
  FillChar(zstream, SizeOf(TZStreamRec),0);
  OK := False;
  try
     zstream.next_in := PAnsiChar(inbuf);
     zstream.next_out := PAnsiChar(outbuf);
     zstream.avail_out := BUFFERSIZE;
     incnt := 0;
     ReadByte(bytebuf);
     zstream.avail_in := incnt+1;
     CCheck(InflateInit2_(zstream, -15, zlib_version, sizeof(zstream)));
     Param := Z_NO_FLUSH;
         Repeat
           If (zstream.avail_in = 0) and (Param = Z_NO_FLUSH) then
            begin
              incnt := 0;
              ReadByte(bytebuf);
              zstream.avail_in := incnt+1;
              If (zstream.avail_in = 0) then
                 Param := Z_FINISH;
              zstream.next_in := PAnsiChar(inbuf);
            end;
            Stat := inflate(zstream, Param);
            CCheck(Stat);
            if (zstream.avail_out = 0) or (Stat = Z_STREAM_END) then
             begin
              outcnt := BUFFERSIZE - zstream.avail_out;
              xFlushOutPut;
              zstream.next_out := PAnsiChar(outbuf);
              zstream.avail_out := BUFFERSIZE;
             end;
         Until (Stat = Z_STREAM_END);
         OK := True;
     finally
        if (OK) then
          CCheck(inflateEnd(zstream));
     end;

end;

{$ENDIF}

procedure UnStore;
var
 number_to_read, number_read: BIGINT;
  tmpbuf: BYTEPTR;
begin
 outcnt := kpmin( file_info.compressed_size, OUTBUFSIZ );
 while( file_info.compressed_size > 0 ) do
  begin
     If DoProcessMessages then
      begin
        YieldProcess;
        If CancelOperation then
         begin
           CancelOperation := False;
           raise EUserCanceled.Create(LoadStr(IDS_CANCELOPERATION));
         end;
        If PauseOperation then
           DoPause;
      end;
     number_to_read := kpmin( file_info.compressed_size, LongInt(INBUFSIZ) );
     file_info.compressed_size := file_info.compressed_size - number_to_read;
     number_read := zip_in_file.Read( outbuf^, number_to_read );
     incnt := number_read;
     If (((ecrec.this_disk = 0))
        and (incnt < number_to_read)) then
           raise EFatalUnzipError.Create(LoadStr(IDS_PREMEND));
     tmpbuf := outbuf;
     While (incnt < number_to_read) do  {2/1/98 Changed If to While}
      begin
        zip_in_file := SwapDisk( CurrentDisk+2 );
        If zip_in_file = nil then  {2/1/98}
           raise EUserCanceled.Create(LoadStr(IDS_CANCELOPERATION));
        Inc(tmpbuf,number_read);
        number_read := zip_in_file.Read( tmpbuf^, number_to_read-incnt );
        Inc(incnt, number_read);
      end;

 {$IFDEF SKIPCODE}
     if file_info.Encrypted then         { added 11/2/97 }
     begin
           if (not assigned(FOnDecrypt)) then
              decrypt_buff( outbuf, outcnt )  {     KLB       }
           else
            begin
              FOnDecrypt( self, outbuf, outcnt, Password );
            end;
     end;
 {$ENDIF}
     {file_info.compressed_size := file_info.compressed_size - outcnt;}
     xFlushOutput;
     outcnt := kpmin( file_info.compressed_size, OUTBUFSIZ );
  end;
end;

procedure Skip_Rest;
{ skip past current compressed file to the next one }
begin
 {zip_in_file.Seek( file_info.compressed_size, soFromCurrent );} { Removed 4/22/98 2.11 }
  TotalUncompressedSize := TotalUncompressedSize - file_info.compressed_size;
  Dec(FileCount);
end;

procedure Do_Unzip( Index: Integer );
{ Unzips file[Index] }
var
 MsgArray: array [0..300] of char; {For 16 bit's sake}
 zip_out_file_name: kpWString;
 CRCHighByte, DecryptCRCByte: BYTE;
  {CRCHighWord, DecryptCRCWord: WORD;}
 OverWriteIt: Boolean;
  Skip: Boolean;
 FullPath: kpWString;
  FinishedOK: Boolean;
  FileHandle: Integer;
  InternalDir: kpWString;
  NewPassword: AnsiString;
  AllocatedBuffer: Boolean;
  testDate: TDateTime;
  GoOn, FirstTime: Boolean;
  attrs: Integer;
  tmpMStr2: String;

  function GetFullPath: kpWString;
  begin
    Result := '';
    if (RecreateDirs) and (file_info.directory <> '') then
     begin
        InternalDir := file_info.directory;
        If (RelativePathList.Count > 0) then
          StripRelativePath(InternalDir);
        //If (RootDir <> '') and (AnsiCompareText(LeftStr(InternalDir,Length(RootDir)),RootDir) = 0) then
        //      Delete(InternalDir,1,Length(RootDir));
        { The directory in the zip file could be absolute }
        if (InternalDir <> '') and ((InternalDir[1] = '\') or (InternalDir[2] = ':')) then
         begin
           If DestDir = '' then
              Result := InternalDir
           Else
            begin
              If (InternalDir[1] = '\') then
                 Result := DestDir + InternalDir
              Else
                 Result := DestDir + RightStr( InternalDir, Length(InternalDir)-2);
            end;
         end
        else { otherwise just append it to the destination directory }
           Result := DestDir + '\' + InternalDir;
        {if (not DirExists( FullPath )) and (not FTestMode) then
           kpForceDirectories( FullPath );}  { Create dest directory if it doesn't exist }
     end
    Else
     Result := DestDir + '\';
  end;

var
  SkipCRC_Check: Boolean;
  tmp_buf1,tmp_buf2: array [0..15] of byte; //PWD_VER_TYPE;
  BadAESAuthentication: boolean;

begin
  FinishedOK := False;
  AllocatedBuffer := False;
  zip_out_file_name := '';
  Skip := False;
  RepeatFile := False;
  SkipCRC_Check := False;


  file_info.Assign(sortfiles.Items[Index] as TZipHeaderInfo);  { Make a copy }
  If (file_info.filename <> '') then   { must be a directory entry }
  begin
  If (ecrec.this_disk > 0) and (file_info.disk_number_start <> CurrentDisk) then
        zip_in_file := SwapDisk( file_info.disk_number_start+1 );
  zip_in_file.Seek( file_info.relative_offset, soBeginning );
  zip_in_file.Read( lrec, SizeOf(local_file_header) );
  zip_in_file.Seek( lrec.extra_field_length + lrec.filename_length, soCurrent );
  end;

  FullPath := GetFullPath;

  If file_info.filename = '' then   { it's just a directory entry }
  begin
     {If (RecreateDirs) and (Assigned( FOnStartUnZip )) then
     FOnStartUnZip( self, Index, FullPath, Skip );}
     { Added following 6/27/99 2.18+ }
     if (not StreamZipping) and (not MemZipping) and
        (RecreateDirs) and (not DirExists( FullPath )) then
        kpForceDirectories( FullPath );  { Create dest directory if it doesn't exist }
     If RetainAttributes then
        kpFileSetAttributes( FullPath, file_info.external_file_attributes );
     Inc(NumUnZipped);
     exit;
  end;

  If (not StreamZipping) and (not MemZipping) then
   begin

{$IFDEF SKIPCODE}
    if (RecreateDirs) and (file_info.directory <> '') then
     begin
        InternalDir := file_info.directory;
        If (RootDir <> '') and (kpCompareText(LeftStr(InternalDir,Length(RootDir)),RootDir) = 0) then
              Delete(InternalDir,1,Length(RootDir));
        { The directory in the zip file could be absolute }
        if (InternalDir <> '') and ((InternalDir[1] = '\') or (InternalDir[2] = ':')) then
         begin
           If DestDir = '' then
              FullPath := InternalDir
           Else
            begin
              If (InternalDir[1] = '\') then
                 FullPath := DestDir + InternalDir
              Else
                 FullPath := DestDir + RightStr( InternalDir, Length(InternalDir)-2);
            end;
         end
        else { otherwise just append it to the destination directory }
           FullPath := DestDir + '\' + InternalDir;
        {if (not DirExists( FullPath )) and (not FTestMode) then
           ForceDirs( FullPath );}  { Create dest directory if it doesn't exist }
     end
    Else
     FullPath := DestDir + '\';
{$ENDIF}
    zip_out_file_name := FullPath + file_info.filename;
   end;

{ --------------------------------------------------------------------------------------------}
{ Moved to here, before opening the file and changed the filename parameter to VAR so that }
{ the destination of the file can be changed in the OnStartUnZip event. 03/20/99 2.17+     }
  If Assigned( FOnStartUnZip ) then
  begin
     FOnStartUnZip( self, Index, zip_out_file_name , Skip );
  end;
  If Skip then
     exit;

{ Moved to here since the path and filename might have been changed in the OnStartUnZip event }
{ 03/20/99  2.17+ }
  If (not StreamZipping) and (not MemZipping) and (not FTestMode) then
   begin
     FullPath := kpExtractFileDir(zip_out_file_name);
     if (not kpDirectoryExists(FullPath )) then
        kpForceDirectories(FullPath);  { Create dest directory if it doesn't exist }
   end;
{ --------------------------------------------------------------------------------------------}

 If (file_info.Encrypted) then
  if (file_info.EncryptionStrength = esPKStandard) then
   begin
     NewPassword := Password;
     While NewPassword = Password do
     begin
        If file_info.HasDescriptor then
           CRCHighByte := HIBYTE(LOWORD( file_info.last_mod_file_date_time ))
        Else
           CRCHighByte := HIBYTE(HIWORD( file_info.crc32));
        DecryptCRCByte := DecryptTheHeader( Password, zip_in_file );
        if (CRCHighByte <> DecryptCRCByte) and (Tag = 0) then
         begin
           NewPassword := Password;
           If Assigned( FOnBadPassword ) then
            begin
              FOnBadPassword( self, Index, NewPassword );
              If NewPassword <> Password then
               begin
                 Password := NewPassword;
                 zip_in_file.Seek(-SizeOf(DecryptHeaderType),soCurrent);
                 file_info.compressed_size := file_info.compressed_size + SizeOf(DecryptHeaderType);
                 Continue;
               end;
            end;
           If Assigned( FOnSkippingFile ) then
              FOnSkippingFile( self, srBadPassword, file_info.directory+file_info.filename, Index, Retry );
           Skip_Rest; {skip file}
           exit;
         end
        Else NewPassword := '';
     end;
   end
  else  // AES Encryption
  { TODO : Add capability to skip this check and rely on checking after unzipping }
   begin
      NewPassword := Password;
      While NewPassword = Password do
      begin
        if not(DecrypteAESHeader(NewPassword, zip_in_file)) then
         begin
           NewPassword := Password;
           If Assigned( FOnBadPassword ) then
            begin
              FOnBadPassword( self, Index, NewPassword );
              If NewPassword <> Password then
               begin
                 Password := NewPassword;
                 Continue;
               end;
            end;
           If Assigned( FOnSkippingFile ) then
              FOnSkippingFile( self, srBadPassword, file_info.directory+file_info.filename, Index, Retry );
           Skip_Rest; {skip file}
           exit;
         end
        Else NewPassword := '';
      end;
  end;

 csize := file_info.compressed_size;
 ucsize := file_info.uncompressed_size;

  If (not StreamZipping) and (not MemZipping) then
   begin
	   If (FOverwriteMode <> Always) and (kpFileExists(zip_out_file_name)) then
	    begin
		   If FOverwriteMode = Prompt then  { Allow application to determine if overwrite }
		    begin
			   If Assigned( FOnPromptForOverwrite ) then
			    begin
				   OverWriteIt := False;		{ Assume we skip just to be safe }
				   FOnPromptForOverwrite( self, OverWriteIt, Index, zip_out_file_name );
			    end
			   Else  { FOnPromptForOverwrite event not assigned so we have to ask user ourselves }
			    begin
				   StrPCopy( MsgArray, LoadStr(IDS_REPLACEFILE) + Filename[Index] + '?' );
              tmpMStr := LoadStr(IDS_FILEXISTALERT);
				   //OverWriteIt := MessageBox( 0, MsgArray, StringAsPChar(tmpMStr), MB_YESNO) =  IDYES;
           OverWriteIt := DoHandleMessage(IDS_FILEXISTALERT,MsgArray, StringAsPChar(tmpMStr), MB_YESNO) = IDYES;
			    end;
			   If not OverWriteIt then
			    begin
				   If Assigned( FOnSkippingFile ) then
             	   FOnSkippingFile( self, srNoOverwrite, zip_out_file_name, Index, Retry );
				   Skip_Rest; {skip file}
        	   exit;
            end;
         end
        Else If (FOverwriteMode = Never) then { Never Overwrite }
         begin
           If Assigned( FOnSkippingFile ) then
        	   FOnSkippingFile( self, srNoOverwrite, zip_out_file_name, Index, Retry );
      	   Skip_Rest;  {skip file}
     	   exit;
         end
        Else  { ifNewer and ifOlder   8/2/98  2.14 }
         begin
{ DONE : FileAgeW??? }
           testDate := FileDateToDateTime(kpFileAge(zip_out_file_name));
           If (FOverwriteMode = ifNewer) then
            begin
              If (FileDateToDateTime( file_info.last_mod_file_date_time ) <= testDate) then
               begin
                 If Assigned( FOnSkippingFile ) then
        	         FOnSkippingFile( self, srNoOverwrite, zip_out_file_name, Index, Retry );
      	         Skip_Rest;  {skip file}
     	         exit;
              end;
            end
           Else
            begin
              If (FileDateToDateTime( file_info.last_mod_file_date_time ) >= testDate) then
               begin
                 If Assigned( FOnSkippingFile ) then
        	         FOnSkippingFile( self, srNoOverwrite, zip_out_file_name, Index, Retry );
      	         Skip_Rest;  {skip file}
     	         exit;
               end;
            end;
         end;
	    end;

     GoOn := False;
     FirstTime := True;
     Repeat    { Added ReplaceReadOnly 03/07/99  2.17+ }
        try
	         zip_out_file := TLFNFileStream.CreateFile( zip_out_file_name, fmCreate, FFlushFilesOnClose,
                                                      BufferedStreamSize );
           zip_out_file.Size := file_info.uncompressed_size;
           zip_out_file.Position := 0;
           GoOn := True;
        except
           On EFCreateError do                            {ReadOnly will cause EFCreateError}
            begin
              If FReplaceReadOnly  and FirstTime then
               begin
                 FirstTime := False;                       { We'll only try this once }
                 attrs := kpFileGetAttributes(zip_out_file_name);
                 if ((attrs and faReadOnly) > 0) then
                  begin
                    attrs := attrs and (not faReadOnly);   {Turn off ReadOnly bit}
                    kpFileSetAttributes(zip_out_file_name, attrs)  {And reset the attributes}
                  end;
               end
              else
               begin                                       {Skip if we still can't open or we}
                 If Assigned( FOnSkippingFile ) then       {don't want to replace readonly   }
        	         FOnSkippingFile( self, srCreateError, zip_out_file_name, Index, Retry );
                 Skip_Rest;
                 exit;
               end;
            end;
           else
            begin
              If Assigned( FOnSkippingFile ) then       {can't create the file for some reason }
                 FOnSkippingFile( self, srCreateError, zip_out_file_name, Index, Retry );
              Skip_Rest;
              exit;
            end;
        end;
     Until GoOn;
   end { If not UnZippingToStream }
  Else
   begin
     If (StreamZipping) then
     begin
        if ZipStream.Size = 0 then
          ZipStream.Size := file_info.uncompressed_size;
        zip_out_file := ZipStream;  { UnZipping to a stream }
        zip_out_file.Position := 0;
     end
     Else
      begin   { UnZipping to memory buffer }
        AllocatedBuffer := False;
        If (MemBuffer = nil) then
         begin
           { Added extra byte and zeromemory so buffer can be null terminated string 3-22/08}
           GetMem( MemBuffer, file_info.uncompressed_size+1);
           ZeroMemory(MemBuffer,file_info.uncompressed_size+1);
           AllocatedBuffer := True;
         end;
        CurrMem := MemBuffer;
        MemLeft := file_info.uncompressed_size;
        MemLen :=  file_info.uncompressed_size;
      end;
   end;
try
try
  bits_left := 0;
  bitbuf := 0;
 outpos := 0;
 incnt := 0;
  outcnt := 0;
 inptr := inbuf;
 outptr := outbuf;
  Crc32Val := $FFFFFFFF;
 {CurrentDisk := 0;}

{  Skip := False;
  If Assigned( FOnStartUnZip ) then
     FOnStartUnZip( self, Index, zip_out_file_name, Skip );
  If Skip then
     exit;
}
  {Just incase they did something in an event that changed the filepointer} {4/9/99 2.18b4+}
  zip_in_file.Seek( file_info.relative_offset, soBeginning );
  zip_in_file.Seek( SizeOf(local_file_header) + lrec.extra_field_length +
                    lrec.filename_length, soCurrent );
  If (file_info.Encrypted) then
   begin
    if (file_info.EncryptionStrength = esPKStandard) then
      zip_in_file.Seek( 12, soCurrent ) { If the file is encrypted }
    else
      zip_in_file.Seek(SALT_LENGTH(Ord(file_info.EncryptionStrength))+PWD_VER_LENGTH,soCurrent);
   end;

  Case file_info.compression_method of
     STORED:        UnStore;
     DEFLATED:      kpInflate;
{$IFNDEF INFLATE_ONLY}
     SHRUNK:        UnShrink;
     REDUCED1,
     REDUCED2,
     REDUCED3,
     REDUCED4:      UnReduce;
     IMPLODED:      Explode;
{$ENDIF}
  else
     if (not FTestMode) then
     begin
        TmpMStr := LoadStr(IDS_UNKNOWNMETH);
        TmpMStr2 := LoadStr(IDS_ZIPERROR);
        //MessageBox( 0, StringAsPChar(TmpMStr), StringAsPChar(TmpMStr2), mb_OK );
        DoHandleMessage(IDS_UNKNOWNMETH, StringAsPChar(TmpMStr), StringAsPChar(TmpMStr2), mb_OK );
     end;
  end; { Case }
  FinishedOK := True;
except   { 4/16/98 2.11 }
  On EBiggerThanUncompressed do
     FinishedOK := False;  { Bad CRC should be called later }
  On ECanceledUnZipToBuffer do
    begin
     FinishedOK := False;
     SkipCRC_Check := True;
    end;
end;
finally
  BadAESAuthentication := False;
  If (file_info.Encrypted) and (file_info.EncryptionStrength <> esPKStandard) then
  begin
      _fcrypt_end(@tmp_buf2[0], @zcx[0]);
      zip_in_file.Read(tmp_buf1,MAC_LENGTH);
      if (not CompareMem(@tmp_buf1[0],@tmp_buf2[0],MAC_LENGTH)) then
        BadAESAuthentication := True;
  end;
  If (not StreamZipping) and (not MemZipping) then
   begin
     zip_out_file.Free;
     zip_out_file := nil;
     If (FinishedOK) then
      begin
{ DONE : FileOpenW??? }
        FileHandle := kpFileOpen(zip_out_file_name, fmOpenWrite or fmShareDenyNone);
        FileSetDate(FileHandle, GoodTimeStamp(file_info.last_mod_file_date_time));
        FileClose(FileHandle);
        { Moved the following from before setting date because if read-only setting
          the date was not possible }     { 1/18/00 2.20+ }
        If RetainAttributes then
{ DONE : FileSetAttrW??? }
           kpFileSetAttributes( zip_out_file_name, file_info.external_file_attributes );
      end;
   end;
  If (MemZipping) and (not FinishedOK) then
   begin
     If (AllocatedBuffer) then
        FreeMem(MemBuffer, file_info.uncompressed_size);
     MemBuffer := nil;
   end;
end;  { try }
  Crc32Val := not Crc32Val;
  If (file_info.crc32 <> 0) and (not SkipCRC_Check) and ((Crc32Val <> file_info.crc32) or (BadAESAuthentication)) then
   begin
     If (file_info.Encrypted) then  { bad password entered }
      begin
        If Assigned( FOnBadPassword ) then
         begin
           NewPassword := Password;
           FOnBadPassword( self, Index, NewPassword );
           If NewPassword <> Password then
            begin
              Password := NewPassword;
              RepeatFile := True;
            end;
         end;
        If (not RepeatFile) and Assigned( FOnSkippingFile ) then
           FOnSkippingFile( self, srBadPassword, file_info.directory+file_info.filename, Index, Retry );
      end
     Else If (Assigned( FOnBadCRC )) then
        FOnBadCRC( self, Crc32Val, file_info.crc32, Index );
     If (not StreamZipping) and (not MemZipping) then
{ DONE : DeleteFileW??? }
        kpDeleteFile( zip_out_file_name );
     If (not RepeatFile) then
        Dec(FileCount);
   end
  Else
   begin
     If Assigned( FOnEndUnZip ) then
        FOnEndUnZip( self, Index, zip_out_file_name );
     Inc(NumUnZipped);
   end;
end;

{******************************************************************************************}
var
 i, j: Integer;
 finfo: TZipHeaderInfo;
 StopNow: Boolean;
 CompareFileName: kpWString;
 SaveSortMode: TZipSortMode;
 SaveKeepZipOpen: Boolean;
 OldOperationMode: TOperationMode;
 {FinishedOK: Boolean;}
begin
  {FinishedOK := False;}  { 5/18/98  2.13 }
  {Result := 0;}          { 5/18/98  2.13 }
 OldOperationMode := SetOperationMode(omUnZip);
 CancelOperation := False;
 SaveKeepZipOpen := FKeepZipOpen;
 FKeepZipOpen := True;
 Retry := False;
 New( area );
 slide := @(area^.slide);
 GetMem( inbuf, INBUFSIZ+1 );
 GetMem( outbuf, OUTBUFSIZ+1 );
 If DestDir <> '' then
  begin
     If not kpDirectoryExists(FDestDir) then
        kpForceDirectories(FDestDir);
  end;

 SaveSortMode := ByNone;
 If (ecrec.this_disk <> 0) and (FSortMode <> ByNone) then
  begin
     SaveSortMode := FSortMode;
     Sort(ByNone);
  end;
 inptr := inbuf;
 outptr := outbuf;
try
 TotalUncompressedSize := 0;
 TotalBytesDone := 0;
 FileCount := Count;
 { Determine which files will be extracted }
 For j := 0 to Count-1 do
   begin
      if DoProcessMessages then
      begin
        YieldProcess;
        if CancelOperation then
        begin
          CancelOperation := False;
          raise EUserCanceled.Create(LoadStr(IDS_CANCELOPERATION));
        end;
      end;
     finfo := sortfiles.Items[j] as TZipHeaderInfo;
     finfo.MatchFlag := FDoAll;
     If (finfo.filename = '') and (not RecreateDirs) then  { it's just a dirname }
      begin
        finfo.MatchFlag := False;
        Dec(FileCount);
        continue;
      end;
     i := 0;
     If UnZippingSelected then
      begin
        If finfo.Selected then
         begin
           finfo.MatchFlag := True;
           finfo.Selected := False;
         end;
      end
     Else if (not DoAll) then
      While (i < FFilesList.Count) do  { Compare with fileslist till we find a match }
       begin     { removed check for '\'  5/19/98  2.13 }
        CompareFileName := kpLowerCase(finfo.Directory + finfo.filename);
           If (IsMatch(kpLowerCase(FFilesList[i]), CompareFileName)) then
            begin
              finfo.MatchFlag := True;   { Found a match }
              Break;                     { So we can stop looking }
            end
           Else
              Inc(i);                    { Didn't find a match yet }
       end
     else
      finfo.MatchFlag := True;
     { Removed check for filename <> '' 8/21/01  2.22+ }
     { Wasn't allowing dirs to be restored unless DoAll was set }
     If (finfo.MatchFlag) {and (finfo.filename <> '')} then           { If this file is to be extracted }
        TotalUncompressedSize := TotalUnCompressedSize +  finfo.uncompressed_size
     Else
        Dec(FileCount);                { otherwise one less file to extract }
   end;
 StopNow := False;
 If Assigned( FOnStartUnzipInfo ) then    { Give application a chance to stop it now }
   OnStartUnzipInfo( self, FileCount, TotalUncompressedSize, StopNow );
 NumUnZipped := 0;
 If (FileCount > 0) and (not StopNow) then                     { If not stopping then let's extract the files }
  begin
   If FDoAll then                       { If all files, then do them fast }
    For j := 0 to Count-1 do
         begin
           Repeat
              Do_Unzip( j )
           Until RepeatFile = False;
         end
   Else                                 { otherwise, check their flag first }
    begin
     For i := 0 to Count-1 do
      begin
        finfo := sortfiles.Items[i] as TZipHeaderInfo;
        If finfo.MatchFlag then
            Repeat
              Do_Unzip( i );
            Until RepeatFile = False;
      end;
    end;
  end;
  {FinishedOK := True;}  { 5/18/98  2.13 }
finally
  {If FinishedOK then}   { 5/18/98  2.13 }
     {Result := FileCount;}
  Result := NumUnZipped;
  Dispose( area );
  FreeMem( inbuf, INBUFSIZ+1 );
  FreeMem( outbuf, OUTBUFSIZ+1 );
  FilesList.Clear;  { 6/27/99 2.18+ }
  If (ecrec.this_disk <> 0) and (SaveSortMode <> ByNone) then
     Sort(SaveSortMode);
  if Assigned(FOnUnZipComplete) then FOnUnZipComplete(self, result);
  KeepZipOpen := SaveKeepZipOpen;
  setOperationMode(OldOperationMode);
end; { try/finally }
end; { UnZipp }



{****************************************************************************}
{                            Encryption                                      }
{****************************************************************************}
procedure TVCLUnZip.update_keys( ch: AnsiChar );
begin
  Key[0] := UpdCRC(BYTE(ch), Key[0]);
  Inc(Key[1], Key[0] and $ff);
  Key[1] := Key[1] * 134775813 + 1;
  Key[2] := UpdCRC( BYTE(WORD(Key[1] shr 24)), Key[2] );
end;

function TVCLUnZip.decrypt_byte: BYTE;
var
 temp: WORD;
begin
 temp := WORD(Key[2]) or 2;
  Result := BYTE(WORD(temp * (temp xor 1)) shr 8);
end;

procedure TVCLUnZip.decrypt_buff( bufptr: BYTEPTR; num_to_decrypt: LongInt );
var
 i: Integer;
begin
 if (file_info.EncryptionStrength = esPKStandard) then
 begin
 for i := 0 to num_to_decrypt-1 do
   begin
    bufptr^ := bufptr^ xor decrypt_byte;
     update_keys(AnsiChar(bufptr^));
     Inc(bufptr);
   end;
 end
 else
 begin
  _fcrypt_decrypt(bufptr, num_to_decrypt, @zcx[0]);
 end;
end;

procedure TVCLUnZip.Init_Keys( Passwrd: AnsiString );
var
  i: Integer;
begin
  Key[0] := 305419896;
  Key[1] := 591751049;
  Key[2] := 878082192;

  For i := 1 to Length(Passwrd) do
   update_keys( Passwrd[i] );

end;

function TVCLUnZip.DecryptHeaderByte( Passwrd: AnsiString; dh: DecryptHeaderType ): BYTE;
var
  i: Integer;
  C: BYTE;
begin
  Init_Keys( Passwrd );

  For i := 0 to 11 do
   begin
     C := dh[i] xor decrypt_byte;
     update_keys( AnsiChar(C) );
     dh[i] := C;
   end;
   Result := dh[11];
end;

function TVCLUnZip.DecryptHeaderByteByPtr( Passwrd: AnsiString; dh: BytePtr ): Byte;
var
  dhTemp: DecryptHeaderType;
  i: Integer;
begin
  For i := 0 to 11 do
   begin
     dhTemp[i] := dh^;
     Inc(dh);
   end;
  Result := DecryptHeaderByte( Passwrd, dhTemp );
end;

function TVCLUnZip.DecryptTheHeader( Passwrd: AnsiString; zfile: TkpStream ): BYTE;
var
  aDecryptHeader: DecryptHeaderType;
begin
   zfile.Read( aDecryptHeader, SizeOf(DecryptHeaderType) );
  {Cant't do the following to a property}
  {Dec(file_info.compressed_size, SizeOf(DecryptHeader));}
  file_info.compressed_size := file_info.compressed_size - SizeOf(DecryptHeaderType);

  Result := DecryptHeaderByte(Passwrd, aDecryptHeader);
end;

{****************************************************************************}
{                                   CRC                                      }
{****************************************************************************}
Function TVCLUnZip.UpdCRC(Octet: Byte; Crc: U_LONG) : U_LONG;
Var
   L : U_LONG;
   W : Array[1..4] of Byte Absolute L;
Begin
   Result := CRC_32_TAB[Byte(Crc XOR U_LONG(Octet))] XOR ((Crc SHR 8) AND $00FFFFFF);
end {UpdCRC};

procedure TVCLUnZip.Update_CRC_buff( bufptr: BYTEPTR; num_to_update: LongInt );
var
 i: Integer;
begin
 for i := 0 to num_to_update-1 do
   begin
     Crc32Val := UpdCRC( bufptr^, Crc32Val );
     Inc(bufptr);
   end;
end;

{****************************************************************************}
{                              AES ENCRYPTION                                }
{****************************************************************************}

function TVCLUnZip.DecrypteAESHeader(pwd: AnsiString; var zfile: TkpStream): boolean;
var
  mode: Integer;
  salt: array[0..15] of byte;
  pwd_verifier1,pwd_verifier2: array [0..15] of byte; //PWD_VER_TYPE;
  file_loc: Int64;
begin
  Result := True;
  ZeroMemory(@salt[0],sizeof(salt));
  file_loc := zfile.Position;
  mode := Ord(file_info.EncryptionStrength);
  //ShowMessage('File Location = ' + IntToStr(zfile.Position));
  zfile.Read(salt,SALT_LENGTH(mode));
  ZeroMemory(@zcx[0],sizeof(zcx));
  ZeroMemory(@pwd_verifier1[0],sizeof(pwd_verifier1));
  ZeroMemory(@pwd_verifier2[0],sizeof(pwd_verifier2));
  _fcrypt_init(mode,PAnsiChar(pwd), Length(pwd),
     @salt[0],@pwd_verifier2[0],@zcx[0]);
  zfile.Read(pwd_verifier1,PWD_VER_LENGTH);
  if (not CompareMem(@pwd_verifier1[0],@pwd_verifier2[0],PWD_VER_LENGTH)) then
  begin
    Result := False;
    zfile.Position := file_loc;
    //zfile.Seek(-(SALT_LENGTH(mode)+PWD_VER_LENGTH),soCurrent);
  end
  else
  begin
    file_info.compressed_size := file_info.compressed_size - (SALT_LENGTH(mode)+PWD_VER_LENGTH + 10);
  end;
end;

{ $Id: kpUnzipp.Pas,v 1.1 2001-08-12 17:30:39-04 kp Exp kp $ }

{ $Log:  10054: kpUnzipp.pas 
{
{   Rev 1.7    11/30/2008 1:44:06 PM  Delphi7    Version: VCLZip Version 4.50
{ Modifications for 4.50
}
{
{   Rev 1.6    4/17/2008 1:51:50 PM  Delphi7    Version: VCLZip Pro 4.10 Beta
{ Fix Previous AESDEFLATED fix
}
{
{   Rev 1.5    1/25/2008 6:42:40 PM  Delphi7    Version: VCLZip Pro 4.00b2
{ Add AESDEFLATED compression method
}
{
{   Rev 1.4    12/27/2007 5:57:24 PM  Delphi7    Version: VCLZip Pro Encryption 4.0 b1
{ Add ToDo for Skipping password check
}
{
{   Rev 1.3    12/27/2007 5:31:48 PM  Delphi7    Version: VCLZip Pro Encryption 4.0 b1
}
{
{   Rev 1.2    2/12/2007 10:08:00 PM  Encryption
{ AES Encryption
}
{
{   Rev 1.1    10/11/2006 7:12:52 PM  Delphi7
{ Add code to set attributes on directory files
}
{
{   Rev 1.0    8/14/2005 1:10:08 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.16.1.3    4/2/2005 4:58:22 PM  Supervisor    Version: VCLZip 3.X
{ ZLib 1.2.2 default
{ Fixed ZLibDecompressStream
{ Delphi 2005 compatible
{ Other assorted bug fixes
}
{
{   Rev 1.16.1.2    7/22/2004 12:41:02 PM  Supervisor    Version: VCLZip 3.X
{ Fixed greater than 65K files problem
{ Fixed problem when CD spanned parts
{ Fixed OperationMode settings
{ Fixed Zip64 EOCL
}
{
{   Rev 1.16.1.1    7/19/2004 7:56:04 PM  Supervisor    Version: VCLZip 3.X
{ Fixed problem with GetSize.
}
{
{   Rev 1.16.1.0    11/1/2003 2:27:28 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.16    10/8/2003 10:16:52 PM  Supervisor    Version: VCLZip 3.X
{ Fixed CancelTheOperation exception when unzipping
}
{
{   Rev 1.15    9/17/2003 7:40:22 AM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.14    9/7/2003 9:38:30 AM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.13    9/3/2003 7:07:46 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.12    8/26/2003 10:45:16 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.11    8/26/2003 8:58:08 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.10    8/19/2003 7:40:14 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.9    8/12/2003 5:23:48 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.8    8/7/2003 11:31:44 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.7    6/25/2003 6:16:56 PM  Kevin    Version: VCLZip 3.X
}
{
{   Rev 1.6    5/20/2003 4:44:24 PM  Supervisor
}
{
{   Rev 1.5    5/19/2003 10:45:04 PM  Supervisor
{ After fixing streams.  VCLZip still uses ErrorRpt.  Also added setting of
{ capacity on the sorted containers to alleviate the memory problem caused by
{ growing array.
}
{
{   Rev 1.4    5/3/2003 6:33:32 PM  Supervisor
}
{
{   Rev 1.3    2/13/2003 10:55:40 AM  Supervisor
{ Added DoProcessing Messages to check for which files to be unzipped.
}
{
{   Rev 1.2    1/29/2003 10:30:04 PM  Supervisor
{ Added pause feature
}
{
{   Rev 1.1    1/4/2003 1:53:32 PM  Supervisor
}
{
{   Rev 1.0    10/15/2002 8:15:20 PM  Supervisor
}
{
{   Rev 1.3    9/18/2002 12:45:46 PM  Supervisor
{ Added ZLib
}
{
{   Rev 1.2    9/7/2002 8:48:50 AM  Supervisor
{ Last modifications for FILE_INT
}
{
{   Rev 1.1    9/3/2002 10:39:30 PM  Supervisor
{ Changed appropriate longints to FILE_INTS
}
{
{   Rev 1.0    9/3/2002 8:16:52 PM  Supervisor
}
{ Revision 1.1  2001-08-12 17:30:39-04  kp
{ Initial revision
{
{ Revision 1.30  2000-12-16 16:50:10-05  kp
{ 2.21 Final Release 12/12/00
{
{ Revision 1.29  2000-06-04 15:56:43-04  kp
{ - Fixed problem where directories couldn't be created from directory entries because the
{   fullpath wasn't known yet.  Result of having moved this code to earlier.
{
{ Revision 1.28  2000-05-21 18:46:08-04  kp
{ - Raised num_to_decrypt parameter of decrypt_buff to a LongInt from a WORD to handle longer buffers.
{ - Same as above for Update_CRC_buff
{
{ Revision 1.27  2000-05-13 16:28:07-04  kp
{ - Changed code to better handle unzipping directory entries
{ - Added code for BufferedStreamSize property
{
{ Revision 1.26  1999-11-03 17:38:47-05  kp
{ - removed unnecessary line of code (call to LoadStr) which caused a compiler error
{   when compiling with NO_RES defined.
{ - Added ifdefs around tmpMStr2 which cause compiler error when NO_RES was defined.
{
{ Revision 1.25  1999-10-24 12:13:04-04  kp
{ - Added to keep zip open during unzip operation.
{
{ Revision 1.24  1999-10-20 18:14:53-04  kp
{ - Modified calls to OnSkippingFile to add Retry parameter
{
{ Revision 1.23  1999-10-17 12:01:11-04  kp
{ - Changed min and max to kpmin and kpmax
{
{ Revision 1.22  1999-10-11 20:11:39-04  kp
{ - Added FlushFilesOnClose property
{
{ Revision 1.21  1999-09-14 21:29:30-04  kp
{ - Removed erroneous CurrentDisk := 0
{
{ Revision 1.20  1999-08-25 17:56:58-04  kp
{ - Fixed problem for PRP, resetting inptr and outptr for each file.
{ - DecryptHeader methods for BCB
{
{ Revision 1.19  1999-07-05 11:25:42-04  kp
{ - Modified so FilesList is cleared when unzip operation is done.
{
{ Revision 1.18  1999-06-27 13:58:21-04  kp
{ - Modified so directory entries will cause the directory to be created if not there and
{   RecreateDirs is True
{ - Added code to handle UnZipping Selected files
{ - Added code for DecryptHeader property
{
{ Revision 1.17  1999-04-24 21:13:57-04  kp
{ - Mod for setting zip file pointer if file encrypted
{
{ Revision 1.16  1999-04-10 10:16:15-04  kp
{ - Modified counter for keeping track of how many files unzipped.
{ - Added seek in zip file just before unzipping, just incase filepointer has changed
{ - Added OnUnZipComplete event call
{
{ Revision 1.15  1999-03-30 19:43:23-05  kp
{ - Modified so that defining MAKESMALL will create a much smaller component.
{
{ Revision 1.14  1999-03-25 17:04:39-05  kp
{ - Added additional try...except blocks, mainly for PRP, but also alows for calling
{   huft_free when an exception occurs.
{
{ Revision 1.13  1999-03-23 17:41:48-05  kp
{ - moved comments to bottom
{ - modified huft_build for better error checking
{
{ Revision 1.12  1999-03-22 17:33:59-05  kp
{ - added GoodTime check when setting file date
{
{ Revision 1.11  1999-03-20 18:22:11-05  kp
{ - Modified OnStartUnZip to have FName be a var parameter.
{ - Moved the OnStartUnZip call so that output filename could be changed
{
{ Revision 1.10  1999-03-17 18:25:41-05  kp
{ - Added ReplaceReadOnly property
{
{ Revision 1.9  1999-03-09 22:01:02-05  kp
{ - Fixed problem of not being able to unzip STORED files that span disks in a spanned disk set.
{ - Fixed one small problem with the ifNewer and ifOlder routine
{
{ Revision 1.8  1999-02-27 13:17:10-05  kp
{ - Added the ifNewer and ifOlder options to the OverwriteMode property
{
{ Revision 1.7  1999-02-08 21:42:48-05  kp
{ Version 2.17
{
{ Revision 1.6  1999-01-25 19:13:01-05  kp
{ Modifed compiler directives
{ }

{ 7/9/98 6:47:19 PM
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
{
{ Mon 27 Apr 1998   17:29:58
{ Removed seek in skip_rest.  Added try...except to handle 
{ exception when output file is larger than should be.
}

