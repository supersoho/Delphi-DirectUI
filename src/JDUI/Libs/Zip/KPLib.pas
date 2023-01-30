unit KpLib;

{$P-}                                                   { turn off open parameters }
{$R-}                                                   { 12/24/98 2.17 }
{$Q-}                                                   { 12/24/98 2.17 }
{$B-} { turn off complete boolean eval }                { 12/24/98  2.17 }
{$V-} { turn off strict var strings }                   { 02/10/99  2.17+ }

interface

{$I KPDEFS.INC}

uses
   Windows,
   {$IFNDEF NOSTREAMBUFF}
   kpSStrm,
   {$ENDIF}
   {$IFNDEF INT64STREAMS}
   kpHstrms,
   {$ENDIF}
   {$IFNDEF ISCLX}
   FileCtrl,
   {$ENDIF}
   SysUtils,
   kpSmall,
   Classes,
   kpUtilsUnicode, kpMatch, kpZipObj, kpzcnst;

const
   WILDCARD_RECURSE           = '>';
   WILDCARD_NORECURSE         = '|';
   DEF_BUFSTREAMSIZE      = 8192;

type
   BYTEPTR = ^Byte;
   PSearchRec = ^kpTSearchRec;

   {$IFDEF NODISKUTILS}
   str11 = string[11];
   {$ENDIF}

   {$IFDEF ISBCB}
   Comp = Double;
   {$ENDIF}

   {$IFNDEF NOSTREAMBUFF}
   TLFNFileStream = class(TS_BufferStream)
      theFile: TkpFileStream;
      function GetHandle: Integer;
      function GetSize: Int64; {$IFDEF ISDELPHI7}override;{$ENDIF}
  protected
    procedure SetSizeInt64(const NewSize: Int64);
    procedure SetSize(const NewSize: Int64); overload; override;
    procedure SetSize(const NewSize: LongInt); reintroduce; overload;
      {$ELSE}
   TLFNFileStream = class(TkpFileStream)
      {$ENDIF}
   PUBLIC
      constructor CreateFile(const FileName: kpWstring; Mode: Word; FlushOut: Boolean;
                             BufSize: Integer);
      destructor Destroy; OVERRIDE;
      {$IFNDEF NOSTREAMBUFF}
      property Size: Int64 READ GetSize WRITE SetSizeInt64;
      property Handle: Integer READ GetHandle;
      {$ENDIF}
   end;

   TConversionOperation = (SHORTEN, LENGTHEN);

   TSearchData = class(TObject)
   PUBLIC
      Directory: kpWstring;
      Pattern: kpWString;
      SearchResult: Integer;
      SearchRec: kpTSearchRec;
      NoFiles: Boolean;
      procedure Next;
      constructor Create(Path: kpWstring; MatchPattern: kpWstring; SearchAttr: Integer);
      destructor Destroy; OVERRIDE;
   end;

   TDirSearch = class
   PRIVATE
      FDirStack: array[0..20] of TSearchData;
      FCurrentLevel: Integer;
      FPattern: kpWstring;
      FRecurse: Boolean;
      FWildDirStack: TkpStrings;
      FNumWildDirs: Integer;
      FWildDirID: Integer;
      FSearchAttr: Integer;

      function IsChildDir(SR: kpTSearchRec): Boolean;
      function IsDir(SR: kpTSearchRec): Boolean;
   PUBLIC
      constructor Create(const StartingDir: kpWstring; Pattern: kpWstring; RecurseDirs: Boolean; SearchAttr: Integer);
      destructor Destroy; OVERRIDE;
      function NextFile(var SR: kpTSearchRec): kpWstring;
      property Recurse: Boolean READ FRecurse WRITE FRecurse DEFAULT False;
   end;

function kpmin(a, b: BIGINT): BIGINT;
function kpmax(a, b: BIGINT): BIGINT;

function CRate(uc, c: BIGINT): LongInt;
function CBigRate(uc, c: Comp): LongInt;
function BlockCompare(const Buf1, Buf2; Count: Integer): Boolean;
function DOSToUnixFilename(fn: kpPChar): kpPChar;
function UnixToDOSFilename(fn: kpPChar): kpPChar;
function RightStr(str: kpWstring; count: Integer): kpWstring;
function LeftStr(str: kpWstring; count: Integer): kpWstring;
function IsWildCard(fname: kpWstring): Boolean;
function FileDate(fname: kpWstring): TDateTime;
// function kpFileAge(const PathName: string): Integer;
function GoodTimeStamp(theTimeStamp: LongInt): LongInt;

//procedure ForceDirs(Dir: string);
//function DirExists(Dir: string): Boolean;
//function File_Exists(const FileName: string): Boolean;
procedure GetDirectory(D: Byte; var S: string);
procedure ChDirectory(const S: kpWstring);
function DoRenameCopy(const FromFile, ToFile: kpWstring): boolean;
procedure FileCopy(const FromFile, ToFile: kpWstring);
function PCharToStr(CStr: kpPChar): kpWString;
function StrToPChar(Str: kpWString): kpPChar;

function GetVolumeLabel(Disk: String): String;
function SetVolLabel(Disk, NewLabel: String): LongBool;
function isDriveRemovable(Drive: String): Boolean;

function TempFileName(Pathname: kpWstring): kpWstring;
function OemFilter(fname: kpWstring): kpWstring;
function isOEM(fname: kpWstring): boolean;

{$IFNDEF Ver100}
procedure Assert(Value: Boolean; Msg: string);
{$ENDIF}

function StringAsPChar(var S: string): kpPChar;

{$IFNDEF NOLONGNAMES}
function LFN_ConvertLFName(LName: kpWString; ConvertOperation: TConversionOperation): kpWString;
{$ENDIF}

implementation

const
   WildCardChars : array [0..4] of kpChar =
      ('*', '?', MATCH_CHAR_RANGE_OPEN, WILDCARD_RECURSE, WILDCARD_NORECURSE);  { Removed ] added > and <  7/24/98 }

constructor TLFNFileStream.CreateFile(const FileName: kpWstring; Mode: Word; FlushOut: Boolean;
                                      BufSize: Integer);
var
   FName                      : kpWstring;
begin
   FName := FileName;
   {$IFNDEF NOSTREAMBUFF}
   theFile := TkpFileStream.Create(FName, Mode);
   inherited Create(theFile, BufSize);
   { Only if one of the write mode bits are set }
   FlushOnDestroy := FlushOut and ((Mode and 3) > 0);
   {$ELSE}
   inherited Create(FName, Mode);
   {$ENDIF}
end;

destructor TLFNFileStream.Destroy;
begin
   inherited Destroy;
   {$IFNDEF NOSTREAMBUFF}
   theFile.Free; { Must Free after calling inherited Destroy so that }
   {$ENDIF} { buffers can be flushed out by Destroy }
end;

{$IFNDEF NOSTREAMBUFF}

function TLFNFileStream.GetHandle: Integer;
begin
   Result := theFile.Handle;
end;

function TLFNFileStream.GetSize: Int64;
var
  Pos: Int64;
begin
  Pos := Seek(0, soCurrent);
  Result := Seek(0, soEnd);
  Seek(Pos, soBeginning);
end;

procedure TLFNFileStream.SetSizeInt64(const NewSize: Int64);
begin
  theFile.Size := NewSize;
end;

procedure TLFNFileStream.SetSize(const NewSize: Int64);
begin
  SetSizeInt64(NewSize);
end;

procedure TLFNFileStream.SetSize(const NewSize: LongInt);
begin
  SetSizeInt64(Int64(NewSize));
end;

{$ENDIF}

constructor TSearchData.Create(Path: kpWstring; MatchPattern: kpWstring; SearchAttr: Integer);
begin
   NoFiles := False;
   Directory := Path;
   if RightStr(Directory, 1) <> '\' then
      Directory := Directory + '\';
   Pattern := MatchPattern;
   // FindClose is in Destroy...
   SearchResult := kpFindFirst(Directory + '*.*', SearchAttr, SearchRec);
   if SearchResult <> 0 then {This should never happen though since we always use *.*}
      NoFiles := True; {to avoid hanging on NT systems with empty directories}
end;

destructor TSearchData.Destroy;
begin
   if not NoFiles then
      kpFindClose(SearchRec); {don't call if FindFirst didn't find any files}
   inherited Destroy;
end;

procedure TSearchData.Next;
begin
   if (SearchResult = 0) then
      SearchResult := kpFindnext(SearchRec);
end;

constructor TDirSearch.Create(const StartingDir: kpWstring; Pattern: kpWstring; RecurseDirs: Boolean; SearchAttr: Integer);

   procedure ParseWildDir(var wilddir: kpWstring);
   var
      i, j                    : Integer;
      Remaining               : kpWstring;
   begin
      i := 1;
      while (i <= Length(wilddir)) and not (inOpArray(wilddir[i], WildCardChars)) do
         Inc(i);
      j := i;
      while (wilddir[j] <> '\') do
         Dec(j);
      Remaining := RightStr(wilddir, Length(wilddir) - j);
      wilddir := LeftStr(wilddir, j);
      i := 1;
      j := 0;
      while (i <= Length(Remaining)) do
      begin
         if (Remaining[i] = '\') then
         begin
            FWildDirStack.Add(LeftStr(Remaining, i - 1));
            Remaining := RightStr(Remaining, Length(Remaining) - i);
            i := 1;
            Inc(j);
         end
         else
            Inc(i);
      end;
      FNumWildDirs := j;
   end;

var
   StartDir                   : kpWstring;
   thisPattern                : kpWstring;
begin
   inherited Create;
   FSearchAttr := SearchAttr;
   StartDir := StartingDir;
   if RightStr(StartDir, 1) <> '\' then
      StartDir := StartDir + '\';
   if IsWildCard(StartDir) then
   begin
      FWildDirStack := TkpStringList.Create;
      ParseWildDir(StartDir);
      FWildDirID := 0;
   end
   else
   begin
      FWildDirID := -1;
      FNumWildDirs := 0;
      FWildDirStack := nil;
   end;
   FCurrentLevel := 0;
   FPattern := Pattern;
   if FNumWildDirs > 0 then
      thisPattern := FWildDirStack[0]
   else
      thisPattern := FPattern;
   FDirStack[FCurrentLevel] := TSearchData.Create(StartDir, thisPattern, FSearchAttr);
   FRecurse := RecurseDirs;
end;

destructor TDirSearch.Destroy;
begin
   FWildDirStack.Free;
end;

function TDirSearch.IsChildDir(SR: kpTSearchRec): Boolean;
begin
   Result := (SR.Attr and faDirectory > 0) and (SR.Name <> '.') and (SR.Name <> '..');
end;

function TDirSearch.IsDir(SR: kpTSearchRec): Boolean;
begin
   Result := (SR.Attr and faDirectory > 0);
end;

function TDirSearch.NextFile(var SR: kpTSearchRec): kpWstring;
var
   FullDir                    : kpWstring;
   SData                      : TSearchData;
begin
   SData := FDirStack[FCurrentLevel];
   while True do
   begin
      if SData.SearchResult <> 0 then
      begin
         SData.Free;
         FDirStack[FCurrentLevel] := nil;
         if FCurrentLevel = 0 then
         begin
            Result := '';                               {Thats it folks!}
            break;
         end;
         Dec(FCurrentLevel);                            { Pop back up a level }
         SData := FDirStack[FCurrentLevel];
         {ChDirectory( SData.Directory );}
         {GetDirectory( 0, dbgFullDir );}
         if (FCurrentLevel < FNumWildDirs) then
            Dec(FWildDirID);
         SData.Next;
      end;
      { Added wildcards-in-paths feature 7/22/98  2.14 }
      if (FCurrentLevel < FNumWildDirs) then
      begin
         while ((SData.SearchResult = 0) and ((not IsChildDir(SData.SearchRec)) or
            (not IsMatch(FWildDirStack[FWildDirID], SData.SearchRec.Name)))) do
            SData.Next;
         if (SData.SearchResult = 0) then
         begin
            Inc(FCurrentLevel);
            {ChDirectory( SData.SearchRec.Name );}
            {GetDirectory( 0, FullDir );}{ Get full directory name }
            FullDir := SData.Directory + SData.SearchRec.Name;
            Inc(FWildDirID);
            if (FCurrentLevel < FNumWildDirs) then
               FDirStack[FCurrentLevel] := TSearchData.Create(FullDir,
                  FWildDirStack[FWildDirID],FSearchAttr)
            else
               FDirStack[FCurrentLevel] := TSearchData.Create(FullDir, FPattern, FSearchAttr);
            SData := FDirStack[FCurrentLevel];
            SData.Next;
         end;
         Continue;
      end;
      while ((SData.SearchResult = 0) and (IsDir(SData.SearchRec) and (not FRecurse))) do
         SData.Next;
      if (SData.SearchResult = 0) and (IsChildDir(SData.SearchRec)) and (FRecurse) then
      begin
         Inc(FCurrentLevel);
         {ChDirectory( SData.SearchRec.Name );}
         {GetDirectory( 0, FullDir );}{ Get full directory name }
         FullDir := SData.Directory + SData.SearchRec.Name;
         FDirStack[FCurrentLevel] := TSearchData.Create(FullDir, FPattern, FSearchAttr);
         {SData := FDirStack[FCurrentLevel];}
         Result := FullDir + '\';
         Break;
      end
      else
         if (SData.SearchResult = 0) and (not IsDir(SData.SearchRec)) then
         begin
            if kpExtractFileExt(SData.SearchRec.Name) = '' then { this gets files with }
               SData.SearchRec.Name := SData.SearchRec.Name + '.'; { no extention         }
            if IsMatch(FPattern, SData.SearchRec.Name) then
            begin
               if SData.SearchRec.Name[Length(SData.SearchRec.Name)] = '.' then
                  SetLength(SData.SearchRec.Name, Length(SData.SearchRec.Name) - 1);
               //SR.Size := SData.SearchRec.Size; { Modified for D2 mem leak 4/15/99  2.17+}
               SR := SData.SearchRec;
               Result := SData.Directory + SData.SearchRec.Name;
               SData.Next;
               Break;
            end
            else
               SData.Next;
         end
         else
            SData.Next;
   end;
end;

function kpmin(a, b: BIGINT): BIGINT;
begin
   if a < b then
      Result := a
   else
      Result := b;
end;

function kpmax(a, b: BIGINT): BIGINT;
begin
   if a > b then
      Result := a
   else
      Result := b;
end;

function CRate(uc, c: BIGINT): LongInt;
var
   R, S                       : Extended;
begin
   if uc = c then
    result := 100
   else
    begin
      if uc > 0 then
        begin
          S := c;
          S := S * 100;
          R := S / uc;
        end
        else
          R := 0;
      Result := kpmin(Round(R), 100);
    end;
end;

function CBigRate(uc, c: Comp): LongInt;
var
   R                          : Comp;
begin
   {$IFDEF ASSERTS}
   Assert(c <= uc, 'Total Done more than total');
   {$ENDIF}
   if uc > 0 then
   begin
      R := (c * 100) / uc;
   end
   else
      R := 0;
   Result := kpmin(Round(R), 100);
end;

function DOSToUnixFilename(fn: kpPChar): kpPChar;
var
   slash                      : kpPChar;
begin
   slash := kpStrScan(fn, kpChar('\'));
   while (slash <> nil) do
   begin
      slash[0] := '/';
      slash := kpStrScan(fn, kpChar('\'));
   end;
   Result := fn;
end;

function UnixToDOSFilename(fn: kpPChar): kpPChar;
var
   slash                      : kpPChar;
begin
   slash := kpStrScan(fn, kpChar('/'));
   while (slash <> nil) do
   begin
      slash[0] := '\';
      slash := kpStrScan(fn, kpChar('/'));
   end;
   Result := fn;
end;

function RightStr(str: kpWstring; count: Integer): kpWstring;
begin
   Result := Copy(str, kpmax(1, Length(str) - (count - 1)), count);
end;

function LeftStr(str: kpWstring; count: Integer): kpWstring;
begin
   Result := Copy(str, 1, count);
end;

function IsWildCard(fname: kpWstring): Boolean;
var
   i                          : Integer;
begin
   i := 1;
   while (i <= Length(fname)) and not (inOpArray(fname[i], WildCardChars)) do
      Inc(i);
   if i > Length(fname) then
      Result := False
   else
      Result := True;
end;

{ Added 4/21/98  2.11  to avoid date/time conversion exceptions }

function GoodTimeStamp(theTimeStamp: LongInt): LongInt;
var
   Hour, Min, Sec             : WORD;
   Year, Month, Day           : WORD;
   Modified                   : Boolean;
begin
   Result := theTimeStamp;
   Hour := LongRec(Result).Lo shr 11;
   Min := LongRec(Result).Lo shr 5 and 63;
   Sec := LongRec(Result).Lo and 31 shl 1;

   Year := LongRec(Result).Hi shr 9 + 1980;
   Month := LongRec(Result).Hi shr 5 and 15;
   Day := LongRec(Result).Hi and 31;

   Modified := False;
   if Hour > 23 then
   begin
      Modified := True;
      Hour := 23;
   end;
   if Min > 59 then
   begin
      Modified := True;
      Min := 59;
   end;
   if Sec > 59 then
   begin
      Modified := True;
      Sec := 59;
   end;
   if Year < 1980 then
   begin
      Modified := True;
      Year := 1980;
   end;
   if Year > 2099 then
   begin
      Modified := True;
      Year := 2099;
   end;
   if Month > 12 then
   begin
      Modified := True;
      Month := 12;
   end;
   if Month < 1 then
   begin
      Modified := True;
      Month := 1;
   end;
   if Day > 31 then
   begin
      Modified := True;
      Day := 31;
   end;
   if Day < 1 then
   begin
      Modified := True;
      Day := 1;
   end;

   if Modified then
   begin
      LongRec(Result).Hi := Day or (Month shl 5) or ((Year - 1980) shl 9);
      LongRec(Result).Lo := (Sec shr 1) or (Min shl 5) or (Hour shl 11);
   end;

end;

function FileDate(fname: kpWstring): TDateTime;
{
var
  f: Integer;
}
begin
   { Converted to using FileAge 3/29/98 2.1 }
    try
      if (fname <> '') and (fname[Length(fname)] = '\') then
        Delete(fname,Length(fname),1);
      Result := FileDateToDateTime(GoodTimeStamp(kpFileAge(fname)));
   except
      Result := Now;
   end;
end;

procedure GetDirectory(D: Byte; var S: string);
begin
   GetDir(D, S);
end;

procedure ChDirectory(const S: kpWstring);
begin
   ChDir(S);
end;

function DoRenameCopy(const FromFile, ToFile: kpWstring): boolean;
var
  tmpFilename1, tmpFilename2:  kpWString;
begin
  result := false;
  if (kpCompareText(kpExtractFileDrive(FromFile), kpExtractFileDrive(ToFile)) = 0) then
  begin
    try
      tmpFilename1 := ToFile + '$$$';
      kpRenameFile(FromFile, tmpFileName1);
      tmpFilename2 := ToFile + '$$';
      kpRenameFile(ToFile, tmpFilename2);
      kpRenameFile(tmpFilename1, ToFile);
      kpDeleteFile(tmpFilename2);
      result := true;
    except
    end;
  end;
end;


procedure FileCopy(const FromFile, ToFile: kpWstring);
var
   S, T                       : TLFNFileStream;
   msg1, msg2                 : string;
begin
   if DoRenameCopy(FromFile, ToFile) then exit;  { 2.21b4+ }
   S := TLFNFileStream.CreateFile(FromFile, fmOpenRead, false, DEF_BUFSTREAMSIZE);
   try
      T := TLFNFileStream.CreateFile(ToFile, fmOpenWrite or fmCreate, false, DEF_BUFSTREAMSIZE);
      try
         if T.CopyFrom(S, 0) = 0 then
         begin
            msg1 := LoadStr(IDS_NOCOPY) + FromFile + ' -> ' + ToFile;
            msg2 := LoadStr(IDS_ERROR);
            raise Exception.Create(msg2 + ': ' + msg1);
            // MessageBox(0, StringAsPChar(msg1), StringAsPChar(msg2), MB_OK);
         end;
      finally
         T.Free;
      end;
   finally
      S.Free;
   end;
end;


function PCharToStr(CStr: kpPChar): kpWString;
begin
   if CStr = nil then
      Result := ''
   else
   begin
      {$IFDEF WIN32}
      SetLength(Result, kpStrLen(CStr));
      Move(CStr^, Result[1], Length(Result)*SizeOf(Char));
      {$ELSE}
      Result := StrPas(CStr);
      {$ENDIF}
   end;
end;

function StrToPChar(Str: kpWString): kpPChar;
begin
   if Str = '' then
      Result := nil
   else
   begin
      Result := kpStrAlloc(Length(Str) + 1);
      kpStrCopy(Result, kpPChar(Str));
   end;
end;

function SetVolLabel(Disk, NewLabel: String): LongBool;
begin
   {$IFNDEF NODISKUTILS}
   { Make sure label is deleted first }
   SetVolumeLabel(PChar(Disk), nil);
   { Set the new label }
   Result := SetVolumeLabel(PChar(Disk), PChar(NewLabel));
   {$ELSE}
   Result := False;
   {$ENDIF}
end;

function isDriveRemovable(Drive: String): Boolean;
{$IFNDEF WIN32}
var
  DiskNo:  Integer;
{$ENDIF}
begin
  Result := False;
  if (GetDriveType(PChar(Drive)) = DRIVE_REMOVABLE) or
     (GetDriveType(PChar(Drive)) = DRIVE_CDROM) then
  Result := True;
end;

function GetVolumeLabel(Disk: String): String;
{$IFNDEF NODISKUTILS}
var
   Dummy2, Dummy3             : DWORD;
   DiskLabel                  : array[0..13] of Char;
   {$ENDIF}
begin
   {$IFNDEF NODISKUTILS}
   GetVolumeInformation(PChar(Disk), DiskLabel, SizeOf(DiskLabel),
      nil, Dummy2, Dummy3, nil, 0);
   Result := StrPas(DiskLabel);
   {$ELSE}
   Result := '';
   {$ENDIF}
end;

{ Added 5/5/98  2.12 }

function TempFileName(Pathname: kpWstring): kpWstring;
var
   TmpFileName                : array[0..255] of kpChar;
begin
   kpGetTempFileName(kpPChar(Pathname), 'KPZ', 0, TmpFileName);
   Result := kpWString(TmpFileName);
end;

function OemFilter(fname: kpWstring): kpWString;
var
  tempString: String;
begin
   tempString := fname;
   CharToOem(@tempString[1], @tempString[1]);
   OemToChar(@tempString[1], @tempString[1]);
   result := tempString;
end;

function isOEM(fname: kpWstring): boolean;
var
  testString: kpWstring;
begin
  testString := OemFilter(fname);
  result := kpCompareText(fname, testString) = 0;
end;

{$IFNDEF Ver100}
{ A very simple assert routine for D1 and D2 }

procedure Assert(Value: Boolean; Msg: string);
begin
   {$IFDEF ASSERTS}
   if not Value then
      ShowMessage(Msg);
   {$ENDIF}
end;
{$ENDIF}

function BlockCompare(const Buf1, Buf2; Count: Integer): Boolean;
type
   BufArray = array[0..MAXINT-1] of AnsiChar;
var
   I                          : Integer;
begin
   Result := False;
   for I := 0 to Count - 1 do
      if BufArray(Buf1)[I] <> BufArray(Buf2)[I] then Exit;
   Result := True;
end;

function StringAsPChar(var S: string): kpPChar;
begin
   {$WARNINGS OFF}
   Result := kpPChar(S);
   {$WARNINGS ON}
end;


{$IFNDEF NOLONGNAMES}

function LFN_ConvertLFName(LName: kpWString; ConvertOperation: TConversionOperation): kpWString;
var
   tempOrigPath               : array[0..255] of kpChar;
   tempNewPath                : kpWString;
   p                          : kpPChar;
   count, i, j                : Integer;
   r                          : LongInt;
   ffd                        : kpTWIN32FindData;
   EndSlash                   : Boolean;
   HasDrive                   : Boolean;                { For UNC's 3/26/98  2.1 }
begin
   HasDrive := False;
   count := 0;
   EndSlash := False;
   tempNewPath := '';
   tempOrigPath[0] := #0;
   if (LName[2] = ':') and (LName[3] <> '\') then
      Insert('\', LName, 3);
   if (LName[Length(LName)] = '\') then
   begin
      EndSlash := True;
      SetLength(LName, Length(LName) - 1);
   end;
   if (LName[1] = '\') then
   begin
      tempNewPath := '\';
      j := 2
   end
   else
      if ExtractFileDrive(LName) <> '' then             { For UNC's 3/26/98  2.1 }
      begin
         j := Length(ExtractFileDrive(LName)) + 1;
         HasDrive := True;
      end
      else
         j := 1;
   for i := j to Length(LName) do
      if LName[i] = '\' then
      begin
         LName[i] := #0;
         Inc(count);
      end;
   LName[Length(LName) + 1] := #0;
   if HasDrive then
      j := 1;                                           { 4/12/98 2.11 }
   p := @LName[j];
   if HasDrive then
   begin
      kpStrCopy(tempOrigPath, p);
      kpStrCat(tempOrigPath, '\');
      tempNewPath := kpWString(p) + '\';
      p := kpStrEnd(p);
      p^ := '\';
      Inc(p);
      Dec(count);
   end;
   for i := 0 to count do
   begin
      kpStrCat(tempOrigPath, p);
      {$IFDEF WIN32}
      r := kpFindFirstFile(tempOrigPath, ffd);
      {$ELSE}
      r := W32FindFirstFile(tempOrigPath, ffd, id_W32FindFirstFile);
      {$ENDIF}
      if ConvertOperation = LENGTHEN then
      begin
         if (r <> -1) then
            tempNewPath := tempNewPath + kpWString(ffd.cFileName) + '\'
      end
      else
      begin
         if (r <> -1) and (kpWString(ffd.cAlternateFileName) <> '') then
            tempNewPath := tempNewPath + kpWString(ffd.cAlternateFileName) + '\'
         else
            tempNewPath := tempNewPath + kpWString(p) + '\';
      end;
      kpStrCat(tempOrigPath, '\');
      p := kpStrEnd(p);
      p^ := '\';
      Inc(p);
      if (r <> -1) then
         {$IFDEF WIN32}
         Windows.FindClose(r);
      {$ELSE}
         W32FindClose(r, id_W32FindClose);
      {$ENDIF}
   end;
   if not EndSlash then
      SetLength(tempNewPath, Length(tempNewPath) - 1);
   Result := tempNewPath;
end;
{$ENDIF}


   { $Id: KPLib.pas,v 1.28 2000-12-16 16:50:09-05 kp Exp kp $ }

   { $Log:  10036: KPLib.pas 
{
{   Rev 1.0.1.3    11/30/2008 1:44:04 PM  Delphi7    Version: VCLZip Version 4.50
{ Modifications for 4.50
}
{
{   Rev 1.0.1.2    4/17/2008 3:48:50 PM  Delphi7    Version: VCLZip Pro 4.10 Beta
{ remove Unicode.pas from USES
}
{
{   Rev 1.0.1.1    4/17/2008 1:51:48 PM  Delphi7    Version: VCLZip Pro 4.10 Beta
{ Add Unicode stuff
}
{
{   Rev 1.0.1.0    12/27/2007 4:51:48 PM  Delphi7    Version: VCLZip Pro Encryption 4.0 b1
{ Update from 3.X changes
}
{
{   Rev 1.0    8/14/2005 1:10:08 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.15    10/11/2004 5:18:24 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.14    7/27/2004 11:04:26 PM  Supervisor    Version: VCLZip 3.X
{ Added WinZip ansi/oem compatability
}
{
{   Rev 1.13    7/19/2004 7:56:02 PM  Supervisor    Version: VCLZip 3.X
{ Fixed problem with GetSize.
}
{
{   Rev 1.12    10/9/2003 10:48:38 PM  Supervisor    Version: VCLZip 3.X
{ Added FindClose, but it's in 16bit and added a comment.
}
{
{   Rev 1.11    10/5/2003 11:32:08 AM  Supervisor    Version: VCLZip 3.X
{ FIx problem with FileExists and FileAge for directories. Directories now get
{ proper timestamp and don't get replaced everytime on zaFreshen
}
{
{   Rev 1.10    9/8/2003 5:41:26 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.9    9/7/2003 9:38:30 AM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.8    9/3/2003 7:14:02 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.7    8/12/2003 5:23:48 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.6    5/19/2003 10:45:04 PM  Supervisor
{ After fixing streams.  VCLZip still uses ErrorRpt.  Also added setting of
{ capacity on the sorted containers to alleviate the memory problem caused by
{ growing array.
}
{
{   Rev 1.5    5/6/2003 6:11:42 PM  Supervisor
}
{
{   Rev 1.4    5/3/2003 6:33:32 PM  Supervisor
}
{
{   Rev 1.3    1/29/2003 10:32:24 PM  Supervisor
{ Added SearchAttribute feature
}
{
{   Rev 1.2    1/18/2003 6:01:00 PM  Supervisor
}
{
{   Rev 1.1    1/10/2003 7:13:54 PM  Supervisor
}
{
{   Rev 1.0    10/15/2002 8:15:16 PM  Supervisor
}
{
{   Rev 1.3    9/7/2002 8:48:50 AM  Supervisor
{ Last modifications for FILE_INT
}
{
{   Rev 1.2    9/3/2002 11:32:46 PM  Supervisor
{ Mod for FILE_INT
}
{
{   Rev 1.1    9/3/2002 10:53:24 PM  Supervisor
{ Mod for FILE_INT
}
{
{   Rev 1.0    9/3/2002 8:16:50 PM  Supervisor
}
   { Revision 1.28  2000-12-16 16:50:09-05  kp
   { 2.21 Final Release 12/12/00
   {
   { Revision 1.27  2000-05-21 18:47:52-04  kp
   { - Moved declarations of signature globals out and into kpzipobj.
   {
   { Revision 1.26  2000-05-13 17:03:38-04  kp
   { - Added code to handle BufferedStreamSize property for TLFNFileStream
   { - Changed zip signature constants to real global variables.  Setting of these variables
   {   happens in kpzipobj.pas Initialization section
   {
   { Revision 1.25  1999-12-05 09:30:54-05  kp
   { - Added BIGINT def to kpmin and kpmax
   { - Got rid of kpDiskFree
   {
   { Revision 1.24  1999-10-17 12:08:16-04  kp
   { - Removed $IFNDEF ISBCB from kpmin and kpmax
   {
   { Revision 1.23  1999-10-17 12:00:50-04  kp
   { - Changed min and max to kpmin and kpmax
   {
   { Revision 1.22  1999-10-11 20:40:10-04  kp
   { - Added flushing parameter to TLFNFileStream
   {
   { Revision 1.21  1999-09-16 20:09:00-04  kp
   { - Moved defines to KPDEFS.INC
   {
   { Revision 1.20  1999-09-14 21:28:55-04  kp
   { - Removed FlushAlways stuff from this file
   { - Added Trim function for D1
   {
   { Revision 1.19  1999-09-01 18:26:44-04  kp
   { - Added capability to flush buffered stream to disk after every flush of the buffered streams
   {   buffer.  Used the OnFlushBuffer event to do it.
   {
   { Revision 1.18  1999-08-25 19:04:01-04  kp
   { - Fixes for D1
   {
   { Revision 1.17  1999-06-27 13:53:29-04  kp
   { - Minor fix to kpDiskFree  (changed Integer to DWORD)
   {
   { Revision 1.16  1999-06-18 16:45:59-04  kp
   { - Modified to handle adding directory entries when doing recursive zips (AddDirEntries property)
   {
   { Revision 1.15  1999-06-01 21:56:57-04  kp
   { - Ran through the formatter
   {
   { Revision 1.14  1999-04-24 21:12:58-04  kp
   { - Fixed D2 memory leak
   {
   { Revision 1.13  1999-04-10 10:20:53-04  kp
   { - Added conditionals so that NOLONGNAMES and NODISKUTILS wont get set in 32bit
   { - Added code to SetVolLabel to delete label before setting it.
   {
   { Revision 1.12  1999-03-30 19:43:22-05  kp
   { - Modified so that defining MAKESMALL will create a much smaller component.
   {
   { Revision 1.11  1999-03-23 17:43:40-05  kp
   { - added ifdef around DWord definition
   {
   { Revision 1.10  1999-03-22 17:35:29-05  kp
   { - moved comments to bottom
   { - removed dependency on kpDrvs (affects D1 only)
   { - added asserts ifdef to CBigRate
   {
   { Revision 1.9  1999-03-20 11:45:05-05  kp
   { - Fixed problem where setting ZipComment to '' caused an access violation
   {
   { Revision 1.8  1999-03-15 21:58:58-05  kp
   { <>
   {
   { Revision 1.7  1999-03-14 21:32:07-05  kp
   { - Fixed problem of With SData not working
   {
   { Revision 1.6  1999-02-10 18:12:26-05  kp
   { Added directive to turn off Strict Var Strings compiler option
   {
   { Revision 1.4  1999-01-25 19:13:01-05  kp
   { Modifed compiler directives
   { }

   { Sun 10 May 1998   16:58:46  Version: 2.12
   { - Added TempPath property
   { - Fixed RelativePaths bug
   { - Fixed bug related to files in FilesList that don't exist
   }
   {
   {  Mon 27 Apr 1998   18:37:41  Version: 2.11
   { Added ExtractDeviceDrive and GoodTimeStamp
   }
   {
   { Tue 24 Mar 1998   19:00:23
   { Modifications to allow files and paths to be stored in DOS
   { 8.3 filename format.  New property is Store83Names.
   }
   {
   { Wed 11 Mar 1998   21:10:16  Version: 2.03
   { Version 2.03 Files containing many fixes
   }

   { Sun 01 Mar 1998   10:25:17
   { Modified so that D1 would recognize NT.  Modified return
   { values for W32FindFirstFile to be LongInt instead of
   { Integer.
   }

end.

