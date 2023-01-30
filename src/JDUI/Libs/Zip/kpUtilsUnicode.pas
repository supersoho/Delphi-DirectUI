{ $HDR$}
{**********************************************************************}
{ Description of File:                                                 }
{                                                                      }
{                                                                      }
{ Copyright: 2007                                                           }
{ Original Author:  Kevin Boylan                                                   }
{**********************************************************************}
{}
{ $Log:  10258: kpUtilsUnicode.pas 
{
{   Rev 1.5    5/1/2009 12:16:16 PM  Delphi 2009    Version: VCLZip Version 4.51
{ Change return for kpWideStringToUTF8 to AnsiString instead of UTF8String
}
{
{   Rev 1.4    11/30/2008 1:44:06 PM  Delphi7    Version: VCLZip Version 4.50
{ Modifications for 4.50
}
{
{   Rev 1.3    6/28/2008 1:33:36 PM  Delphi7    Version: VCLZip Pro 4.10 Beta
{ Added code to read Unicode filename extra field
}
{
{   Rev 1.2    5/3/2008 8:21:38 PM  Delphi5    Version: VCLZip Pro 4.10 Beta
{ unicode
}
{
{   Rev 1.1    4/17/2008 3:47:26 PM  Delphi7    Version: VCLZip Pro 4.10 Beta
{ Remove some comments
}
{
{   Rev 1.0    4/17/2008 3:44:28 PM  Delphi7    Version: VCLZip Pro 4.10 Beta
}
unit kpUtilsUnicode;

{$I KPDEFS.INC}
{$WARNINGS OFF}

interface

USES
  Windows, SysUtils, Classes
  {$IFDEF IMPLEMENT_UNICODE}
        ,kpUnicode
  {$ENDIF}
  {$IFDEF ISCLX}
    ,RTLConsts
  {$ENDIF};

const
  SE_CREATE_TOKEN_NAME = 'SeCreateTokenPrivilege';
  SE_ASSIGNPRIMARYTOKEN_NAME = 'SeAssignPrimaryTokenPrivilege';
  SE_LOCK_MEMORY_NAME = 'SeLockMemoryPrivilege';
  SE_INCREASE_QUOTA_NAME = 'SeIncreaseQuotaPrivilege';
  SE_UNSOLICITED_INPUT_NAME = 'SeUnsolicitedInputPrivilege';
  SE_MACHINE_ACCOUNT_NAME = 'SeMachineAccountPrivilege';
  SE_TCB_NAME = 'SeTcbPrivilege';
  SE_SECURITY_NAME = 'SeSecurityPrivilege';
  SE_TAKE_OWNERSHIP_NAME = 'SeTakeOwnershipPrivilege';
  SE_LOAD_DRIVER_NAME = 'SeLoadDriverPrivilege';
  SE_SYSTEM_PROFILE_NAME = 'SeSystemProfilePrivilege';
  SE_SYSTEMTIME_NAME = 'SeSystemtimePrivilege';
  SE_PROF_SINGLE_PROCESS_NAME = 'SeProfileSingleProcessPrivilege';
  SE_INC_BASE_PRIORITY_NAME = 'SeIncreaseBasePriorityPrivilege';
  SE_CREATE_PAGEFILE_NAME = 'SeCreatePagefilePrivilege';
  SE_CREATE_PERMANENT_NAME = 'SeCreatePermanentPrivilege';
  SE_BACKUP_NAME = 'SeBackupPrivilege';
  SE_RESTORE_NAME = 'SeRestorePrivilege';
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
  SE_DEBUG_NAME = 'SeDebugPrivilege';
  SE_AUDIT_NAME = 'SeAuditPrivilege';
  SE_SYSTEM_ENVIRONMENT_NAME = 'SeSystemEnvironmentPrivilege';
  SE_CHANGE_NOTIFY_NAME = 'SeChangeNotifyPrivilege';
  SE_REMOTE_SHUTDOWN_NAME = 'SeRemoteShutdownPrivilege';
  SE_UNDOCK_NAME = 'SeUndockPrivilege';
  SE_SYNC_AGENT_NAME = 'SeSyncAgentPrivilege';
  SE_ENABLE_DELEGATION_NAME = 'SeEnableDelegationPrivilege';
  SE_MANAGE_VOLUME_NAME = 'SeManageVolumePrivilege';


type
{$IFDEF IMPLEMENT_UNICODE}
  TkpWideFileStream = class(THandleStream)
  public
    constructor Create(const FileName: WideString; Mode: Word);
    destructor Destroy; override;
  end;

  TWideSearchRec = record
    Time: Integer;
    Size: Int64;
    Attr: Integer;
    Name: WideString;
    ExcludeAttr: Integer;
    FindHandle: THandle;
    FindData: TWin32FindDataW;
  end;

  kpWString = WideString;
  UTF8String = AnsiString;
  kpTSearchRec = TWideSearchRec;
  TkpFileStream = TkpWideFileStream;
  TkpStrings = TWideStrings;
  TkpStringList = TWideStringList;
  kpChar = WideChar;
  kpPChar = PWideChar;
  kpTWIN32FindData = TWIN32FindDataW;
{$ELSE}
  kpWString = String;
  kpTSearchRec = TSearchRec;
  TkpFileStream = TFileStream;
  TkpStrings = TStrings;
  TkpStringList = TStringList;
  kpTWIN32FindData = TWIN32FindData;
  kpChar = Char;
  kpPChar = PChar;
{$ENDIF}

  function kpUTF8ToWideString(S: AnsiString): kpWString;
  function kpWideStringToUTF8(S: kpWString): AnsiString;

  function kpFindFirst(const Path: kpWString; Attr: Integer; var F: kpTSearchRec): Integer;
  function kpFindNext(var F: kpTSearchRec): Integer;
  procedure kpFindClose(var F: kpTSearchRec);
  function kpFindFirstFile(FileName: kpPChar; var FindFileData: kpTWIN32FindData): THandle;

  function kpDirectoryExists(const Directory: kpWString): Boolean;
  function kpForceDirectories(Dir: kpWString): Boolean;
  function kpFileExists(const FileName: kpWString): Boolean;
  function kpRenameFile(const OldName, NewName: kpWString): Boolean;
  function kpDeleteFile(const FileName: kpWString): Boolean;
  function kpFileOpen(const FileName: kpWString; Mode: LongWord): Integer;
  function kpFileGetAttributes(const FileName: kpWString): DWORD;
  function kpFileSetAttributes(const FileName: kpWString; Attr: Integer): DWORD;
  function kpFileAge(const FileName: kpWString): Integer;
  function GetFileSize(const SearchRec: kpTSearchRec): Int64;
  function kpGetTempFileName(PathName, PrefixString: kpPChar;
                              uUnique: UINT; TempFileName: kpPChar): UINT;

  function kpStrScan(const Str: kpPChar; Chr: kpChar): kpPChar;
  function kpStrLen(Str: kpPChar): Cardinal;
  function kpStrAlloc(Size: Cardinal): kpPChar;
  function kpStrCopy(Dest, Source: kpPChar): kpPChar;
  function kpStrCat(Dest, Source: kpPChar): kpPChar;
  function kpStrEnd(Str: kpPChar): kpPChar;
  procedure kpStrDispose(Str: kpPChar);
  function kpStrComp(Str1, Str2: kpPChar): Integer;
  function kpCompareText(const S1, S2: kpWString): Integer;
  function kpExtractFileDir(const FileName: kpWString): kpWString;
  function kpExtractFilePath(const FileName: kpWString): kpWString;
  function kpExtractFileDrive(const FileName: kpWString): kpWString;
  function kpExtractFileExt(const FileName: kpWString): kpWString;
  function kpExtractFileName(const FileName: kpWString): kpWString;
  function kpChangeFileExt(const FileName, Extension: kpWString): kpWString;

  function kpLowerCase(const S: kpWString): kpWString;


  function inOpArray( W : kpChar; sets : array of kpChar ) : Boolean;

  {$IFDEF IMPLEMENT_UNICODE}
  function FindFirstW(const Path: WideString; Attr: Integer; var  F: TWideSearchRec): Integer;
  function FindMatchingFileW(var F: TWideSearchRec): Integer;
  function FindNextW(var F: TWideSearchRec): Integer;

  function DirectoryExistsW(const Directory: WideString): Boolean;
  function FileExistsW(const FileName: WideString): Boolean;
  function ForceDirectoriesW(Dir: WideString): Boolean;
  function DeleteFileW(const FileName: WideString): Boolean;
  function FileOpenW(const FileName: WideString; Mode: LongWord): Integer;
  function FileOpenForBackupW(const FileName: WideString; Mode: LongWord): Integer;
  function FileAgeW(const FileName: WideString): Integer;
  {$ENDIF}

function NTSetPrivilege(sPrivilege: string; bEnabled: Boolean): Boolean;


implementation


  function kpWideStringToUTF8(S: kpWString): AnsiString;
  begin
    result := UTF8Encode(S);
  end;

  function kpUTF8ToWideString(S: AnsiString): kpWString;
  begin
    result := UTF8Decode(S);
  end;

  function kpFindFirst(const Path: kpWString; Attr: Integer; var F: kpTSearchRec): Integer;
  begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := FindFirstW(Path, Attr, F);
  {$ELSE}
    result := FindFirst(Path, Attr, F);
  {$ENDIF}
  end;

  function kpFindNext(var F: kpTSearchRec): Integer;
  begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := FindNextW(F);
  {$ELSE}
    result := FindNext(F);
  {$ENDIF}
  end;

  procedure kpFindClose(var F: kpTSearchRec);
  begin
  {$IFDEF IMPLEMENT_UNICODE}
    Windows.FindClose(F.FindHandle);
    F.FindHandle := INVALID_HANDLE_VALUE;
  {$ELSE}
    FindClose(F);
  {$ENDIF}
  end;

  function kpFindFirstFile(FileName: kpPChar; var FindFileData: kpTWIN32FindData): THandle;
  begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := FindFirstFileW(FileName, FindFileData);
  {$ELSE}
    result := FindFirstFile(FileName, FindFileData);
  {$ENDIF}
  end;

  function kpFileOpen(const FileName: kpWString; Mode: LongWord): Integer;
  begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := kpUtilsUnicode.FileOpenW(FileName,Mode);
  {$ELSE}
    result := FileOpen(FileName, Mode);
  {$ENDIF}
  end;

  function kpDirectoryExists(const Directory: kpWString): Boolean;
  begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := DirectoryExistsW(Directory);
  {$ELSE}
    result := DirectoryExists(Directory);
  {$ENDIF}
  end;

  function kpForceDirectories(Dir: kpWString): Boolean;
  begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := ForceDirectoriesW(Dir);
  {$ELSE}
    result := ForceDirectories(Dir);
  {$ENDIF}
  end;

  function kpFileExists(const FileName: kpWString): Boolean;
   begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := FileExistsW(FileName);
  {$ELSE}
    result := FileExists(FileName);
  {$ENDIF}
  end;

function kpRenameFile(const OldName, NewName: kpWString): Boolean;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    Result := MoveFileW(PWideChar(OldName), PWideChar(NewName));
  {$ELSE}
    result := RenameFile(OldName, NewName);
  {$ENDIF}
end;

function kpDeleteFile(const FileName: kpWString): Boolean;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := kpUtilsUnicode.DeleteFileW(FileName);
  {$ELSE}
    result := DeleteFile(FileName);
  {$ENDIF}
end;

function kpFileGetAttributes(const FileName: kpWString): DWORD;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := GetFileAttributesW(PWideChar(FileName));
  {$ELSE}
    result := FileGetAttr(FileName);
  {$ENDIF}
end;

function kpFileSetAttributes(const FileName: kpWString; Attr: Integer): DWORD;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    if (SetFileAttributesW(PWideChar(FileName), Attr)) then
      result := 0
    else
      result := 1;
  {$ELSE}
    result := FileSetAttr(FileName, Attr);
  {$ENDIF}
end;

function kpFileAge(const FileName: kpWString): Integer;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := FileAgeW(FileName);
  {$ELSE}
    result := FileAge(FileName);
  {$ENDIF}
end;

function GetFileSize(const SearchRec: kpTSearchRec): Int64;
begin
  {$IFDEF IMPLEMENT_UNICODE}
      Int64Rec(Result).Lo := SearchRec.FindData.nFileSizeLow;
      Int64Rec(Result).Hi := SearchRec.FindData.nFileSizeHigh;
  {$ELSE}
      Result := SearchRec.Size;
  {$ENDIF}
end;

function kpStrScan(const Str: kpPChar; Chr: kpChar): kpPChar;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := StrScanW(Str, Chr);
  {$ELSE}
    result := StrScan(Str, Chr);
  {$ENDIF}
end;

function kpStrLen(Str: kpPChar): Cardinal;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := StrLenW(Str);
  {$ELSE}
    result := StrLen(Str);
  {$ENDIF}
end;

function kpStrAlloc(Size: Cardinal): kpPChar;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := StrAllocW(Size);
  {$ELSE}
    result := StrAlloc(Size);
  {$ENDIF}
end;

function kpStrCopy(Dest, Source: kpPChar): kpPChar;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := StrCopyW(Dest, Source);
  {$ELSE}
    result := StrCopy(Dest, Source);
  {$ENDIF}
end;

function kpGetTempFileName(PathName, PrefixString: kpPChar;
                              uUnique: UINT; TempFileName: kpPChar): UINT;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := GetTempFileNameW(PathName, PreFixString, uUnique, TempFileName);
  {$ELSE}
    result := GetTempFileName(PathName, PreFixString, uUnique, TempFileName);
  {$ENDIF}
end;

function kpStrCat(Dest, Source: kpPChar): kpPChar;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := StrCatW(Dest, Source);
  {$ELSE}
    result := StrCat(Dest, Source);
  {$ENDIF}
end;

function kpStrEnd(Str: kpPChar): kpPChar;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := StrEndW(Str);
  {$ELSE}
    result := StrEnd(Str);
  {$ENDIF}
end;

procedure kpStrDispose(Str: kpPChar);
begin
  {$IFDEF IMPLEMENT_UNICODE}
    StrDisposeW(Str);
  {$ELSE}
    StrDispose(Str);
  {$ENDIF}
end;

function kpStrComp(Str1, Str2: kpPChar): Integer;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := StrCompW(Str1, Str2);
  {$ELSE}
    result := AnsiStrComp(Str1, Str2);
  {$ENDIF}
end;

function kpCompareText(const S1, S2: kpWString): Integer;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    //result := kpUnicode.WideCompareText(S1, S2, GetUserDefaultLCID);
    result := SysUtils.WideCompareText(S1, S2);
  {$ELSE}
    result := CompareText(S1, S2);
  {$ENDIF}
end;

function kpExtractFileDir(const FileName: kpWString): kpWString;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := ExtractFileDirW(FileName);
  {$ELSE}
    result := ExtractFileDir(FileName);
  {$ENDIF}
end;

function kpExtractFilePath(const FileName: kpWString): kpWString;
begin
  result := kpExtractFileDir(FileName);
  if (Length(result) > 0) then
    result := result + '\';
end;

function kpExtractFileDrive(const FileName: kpWString): kpWString;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := ExtractFileDriveW(FileName);
  {$ELSE}
    result := ExtractFileDrive(FileName);
  {$ENDIF}
end;

function kpExtractFileExt(const FileName: kpWString): kpWString;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := ExtractFileExtW(FileName);
  {$ELSE}
    result := ExtractFileExt(FileName);
  {$ENDIF}
end;

function kpExtractFileName(const FileName: kpWString): kpWString;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := ExtractFileNameW(FileName);
  {$ELSE}
    result := ExtractFileName(FileName);
  {$ENDIF}
end;

function kpChangeFileExt(const FileName, Extension: kpWString): kpWString;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    result := ChangeFileExtW(FileName, Extension);
  {$ELSE}
    result := ChangeFileExt(FileName, Extension);
  {$ENDIF}
end;

function inOpArray( W : kpChar; sets : array of kpChar ) : Boolean;
var
  ind : integer;
begin
  Result := true;
  for ind := 0 to High(sets) do
  begin
    if W = sets[ind] then exit;
  end;
  Result := False;
end;

function kpLowerCase(const S: kpWString): kpWString;
begin
  {$IFDEF IMPLEMENT_UNICODE}
    //result := kpUnicode.WideLowercase(S);
    result := SysUtils.WideLowercase(S);
  {$ELSE}
    result := AnsiLowercase(S);
  {$ENDIF}
end;

{$IFDEF IMPLEMENT_UNICODE}
{**********************************************************}

function FindMatchingFileW(var F: TWideSearchRec): Integer;
var
  LocalFileTime: TFileTime;
begin
  with F do
  begin
    while FindData.dwFileAttributes and ExcludeAttr <> 0 do
      if not FindNextFileW(FindHandle, FindData) then
      begin
        Result := GetLastError;
        Exit;
      end;
    FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
    FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi, LongRec(Time).Lo);
    Size := (Int64(FindData.nFileSizeHigh) shl 32) + FindData.nFileSizeLow;
    Attr := FindData.dwFileAttributes;
    Name := FindData.cFileName;
  end;
  Result := 0;
end;

function FindFirstW(const Path: WideString; Attr: Integer; var  F: TWideSearchRec): Integer;
const
  faSpecial = faHidden or faSysFile or faVolumeID or faDirectory;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := FindFirstFileW(PWideChar(Path), F.FindData);
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Result := FindMatchingFileW(F);
    if Result <> 0 then
    begin
      Windows.FindClose(F.FindHandle);
      F.FindHandle := INVALID_HANDLE_VALUE;
    end;
  end else
    Result := GetLastError;
end;

function FindNextW(var F: TWideSearchRec): Integer;
begin
  if FindNextFileW(F.FindHandle, F.FindData) then
    Result := FindMatchingFileW(F) else
    Result := GetLastError;
end;

function DirectoryExistsW(const Directory: WideString): Boolean;
var
  Code: DWORD;
begin
  Code := GetFileAttributesW(PWideChar(Directory));
  Result := (Code <> DWORD(-1)) and (FILE_ATTRIBUTE_DIRECTORY and Code <> 0);
end;

function FileExistsW(const FileName: WideString): Boolean;
var
  Code: DWORD;
begin
  Code := GetFileAttributesW(PWideChar(FileName));
  Result := (Code <> DWORD(-1)) and (FILE_ATTRIBUTE_DIRECTORY and Code = 0);
end;

function ForceDirectoriesW(Dir: kpWString): Boolean;
var
  E: EInOutError;
begin
  Result := True;
  if Dir = '' then
  begin
    E := EInOutError.Create('Unable to create directory');
    E.ErrorCode := 3;
    raise E;
  end;
  if (Dir[Length(Dir)] = '\') then
    SetLength(Dir, Length(Dir)-1);
  if (Length(Dir) < 3) or DirectoryExistsW(Dir)
    or (ExtractFilePath(Dir) = Dir) then Exit; // avoid 'xyz:\' problem.
  Result := ForceDirectoriesW(kpExtractFilePath(Dir)) and CreateDirectoryW(PWideChar(Dir), nil);
end;

function FileCreateW(const FileName: WideString): Integer;
begin
  Result := Integer(CreateFileW(PWideChar(FileName), GENERIC_READ or GENERIC_WRITE,
    0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0));
end;

function FileOpenW(const FileName: WideString; Mode: LongWord): Integer;
const
  AccessMode: array[0..2] of LongWord = (
    GENERIC_READ,
    GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of LongWord = (
    0,
    0,
    FILE_SHARE_READ,
    FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  Result := -1;
  if ((Mode and 3) <= fmOpenReadWrite) and
    ((Mode and $F0) <= fmShareDenyNone) then
    Result := Integer(CreateFileW(PWideChar(FileName), AccessMode[Mode and 3],
      ShareMode[(Mode and $F0) shr 4], nil, OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL, 0));
//  if ((Result = -1) and ((Mode and fmShareDenyNone) = fmShareDenyNone)) then
// begin
//    Result := FileOpenForBackupW( FileName, Mode );
//  end;
end;

function FileOpenForBackupW(const FileName: WideString; Mode: LongWord): Integer;
begin
  Result := Integer(CreateFileW(PWideChar(FileName), 0,
      0, nil, OPEN_EXISTING,
      FILE_FLAG_BACKUP_SEMANTICS, 0));
end;

function DeleteFileW(const FileName: WideString): Boolean;
begin
  Result := Windows.DeleteFileW(PWideChar(FileName));
end;

function FileAgeW(const FileName: WideString): Integer;
var
  Handle: THandle;
  FindData: TWin32FindDataW;
  LocalFileTime: TFileTime;
begin
  Handle := FindFirstFileW(PWideChar(FileName), FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    Windows.FindClose(Handle);
    if (FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY) = 0 then
    begin
      FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
      if FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi, LongRec(Result).Lo) then
        Exit
    end;
  end;
  Result := -1;
end;

{ TkpWideFileStream }

constructor TkpWideFileStream.Create(const FileName: WideString;
  Mode: Word);
begin
  if Mode = fmCreate then
  begin
    inherited Create(FileCreateW(FileName));
    if FHandle < 0 then
      raise Exception.Create(SysErrorMessage(GetLastError));
  end
  else
  begin
    inherited Create(FileOpenW(FileName, Mode));
    if FHandle < 0 then
      raise Exception.Create(SysErrorMessage(GetLastError));
  end;
end;

destructor TkpWideFileStream.Destroy;
begin
  if Handle >= 0 then FileClose(Handle);
  inherited Destroy;
end;

{$ENDIF}

function NTSetPrivilege(sPrivilege: string; bEnabled: Boolean): Boolean;
var
  hToken: THandle;
  TokenPriv: TOKEN_PRIVILEGES;
  PrevTokenPriv: TOKEN_PRIVILEGES;
  ReturnLength: Cardinal;
begin
  Result := True;
  // Only for Windows NT/2000/XP and later.
  if not (Win32Platform = VER_PLATFORM_WIN32_NT) then Exit;

  // obtain the processes token
  if OpenProcessToken(GetCurrentProcess(),
    TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, hToken) then
  begin
    try
      // Get the locally unique identifier (LUID) .
      if LookupPrivilegeValue(nil, PChar(sPrivilege),
        TokenPriv.Privileges[0].Luid) then
      begin
        TokenPriv.PrivilegeCount := 1; // one privilege to set

        case bEnabled of
          True: TokenPriv.Privileges[0].Attributes  := SE_PRIVILEGE_ENABLED;
          False: TokenPriv.Privileges[0].Attributes := 0;
        end;

        ReturnLength := 0; // replaces a var parameter
        PrevTokenPriv := TokenPriv;

        // enable or disable the privilege

        AdjustTokenPrivileges(hToken, False, TokenPriv, SizeOf(PrevTokenPriv),
          PrevTokenPriv, ReturnLength);
      end;
    finally
      CloseHandle(hToken);
    end;
  end;
  // test the return value of AdjustTokenPrivileges.
  Result := GetLastError = ERROR_SUCCESS;
  if not Result then
    raise Exception.Create(SysErrorMessage(GetLastError));
end;



end.
