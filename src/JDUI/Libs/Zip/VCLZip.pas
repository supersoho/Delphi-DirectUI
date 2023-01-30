{ ********************************************************************************** }
{                                                                                    }
{   COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: VCLZip.pas                                                        }
{     Description: VCLZip component - native Delphi unzip component.                 }
{     Date:        March 1997                                                        }
{     Author:      Kevin Boylan, vclzip@bigfoot.com                                 }
{                                                                                    }
{                                                                                    }
{ ********************************************************************************** }
unit VCLZip;

{$I KPDEFS.INC}

{$P-} { turn off open parameters }
{$R-} { 3/10/98 2.03 }
{$Q-} { 3/10/98 2.03 }
{$B-} { turn off complete boolean eval } { 12/24/98  2.17 }

interface

uses
  Windows,
  SysUtils, Messages, Classes,
  kpSmall,
{$IFNDEF INT64STREAMS}
  kphstrms,
{$ENDIF}
{$IFNDEF KPSMALL}
  Dialogs, Forms, Controls,
{$ENDIF}
  kpUtilsUnicode, KpLib, VCLUnZip, kpZipObj, kpMatch, kpzcnst, kpaes;

{$IFOPT C+}
{$DEFINE ASSERTS}
{$ENDIF}

type
  usigned = word;
  WPos = WORD;
  IPos = usigned;
  uch = Byte;
  EInvalidMatch = class(Exception);
  ct_dataPtr = ^ct_data;
  ct_data = packed record
    fc: record
      case Integer of
        0: (freq: WORD);
        1: (code: WORD);
    end;
    dl: record
      case Integer of
        0: (dad: WORD);
        1: (len: WORD);
    end;
  end;
  ct_dataArrayPtr = ^ct_dataArray;
  ct_dataArray = array[0..(MAX_USHORT div SizeOf(ct_data)) - 1] of ct_data;
  static_ltreePtr = ^static_ltree_type;
  static_dtreePtr = ^static_dtree_type;
  static_ltree_type = array[0..L_CODES + 1] of ct_data;
  static_dtree_type = array[0..D_CODES - 1] of ct_data;

  windowtypePtr = ^windowtype;
  prevtypePtr = ^prevtype;
  headtypePtr = ^headtype;
  l_buftypePtr = ^l_buftype;
  d_buftypePtr = ^d_buftype;
  flag_buftypePtr = ^flag_buftype;

{$IFDEF WIN32}
  windowtype = array[0..2 * WSIZE - 1] of uch;
  prevtype = array[0..WSIZE - 1] of WPos;
  headtype = array[0..HASH_SIZE - 1] of WPos;
  l_buftype = array[0..LIT_BUFSIZE - 1] of Byte;
  d_buftype = array[0..DIST_BUFSIZE - 1] of WORD;
  flag_buftype = array[0..(LIT_BUFSIZE div 8) - 1] of Byte;
{$ELSE}
  windowtype = array[0..0] of Byte;
  prevtype = array[0..0] of Word;
  headtype = array[0..0] of Word;
  l_buftype = array[0..0] of Byte;
  d_buftype = array[0..0] of Word;
  flag_buftype = array[0..0] of Byte;
{$ENDIF}

  TZipAction = (zaUpdate, zaReplace, zaFreshen);

  TStartZipInfo = procedure(Sender: TObject; NumFiles: Integer; TotalBytes: Comp;
    var EndCentralRecord: TEndCentral; var StopNow: Boolean) of object;
  TStartZipEvent = procedure(Sender: TObject; FName: kpWString;
    var ZipHeader: TZipHeaderInfo; var Skip: Boolean) of object;
  TEndZipFileEvent = procedure(Sender: TObject; FName: kpWString; UncompressedSize,
    CompressedSize, CurrentZipSize: BIGINT) of object;
  TDisposeEvent = procedure(Sender: TObject; FName: kpWString; var Skip: Boolean) of object;
  TDeleteEvent = procedure(Sender: TObject; FName: kpWString; var Skip: Boolean) of object;
  TNoSuchFileEvent = procedure(Sender: TObject; FName: kpWString) of object;
  TZipComplete = procedure(Sender: TObject; FileCount: Integer) of object;
  TUpdateAction = (uaReplacing, uaKeeping); { 7/5/99  2.18+ }
  TUpdateEvent = procedure(Sender: TObject; UDAction: TUpdateAction;
    FileIndex: Integer) of object; { 7/5/99  2.18+ }
  TPrepareNextDisk = procedure(Sender: TObject; DiskNum: Integer) of object; { 7/9/00 2.21b3+ }
  TOnRecursingFile = procedure(Sender: TObject; FName: kpWString) of object; { 7/9/01 2.21+ }
  TEncryptEvent = procedure(Sender: TObject; buffer: BytePtr; length: Integer;
    Password: AnsiString) of object; {12/8/01 2.22+}
  TOnStartSpanCopy = procedure(Sender: TObject; FName: kpWString; FileSize: BIGINT) of object;
  TOnGetNextStreamEvent = procedure(Sender: TObject; var stream: TKPStream; var NextFileName: kpWString) of object;
  {$IFNDEF INT64STREAMS}
  TOnGetNextTStreamEvent = procedure(Sender: TObject; var stream: TStream; var NextFileName: kpWString) of object;
  {$ENDIF}
  TMultiZipInfo = class(TPersistent)
  private
    FBlockSize: Int64;
    FFirstBlockSize: Int64;
    FSaveOnFirstDisk: Int64; { 8/15/99 2.18+ }
    FSaveZipInfo: Boolean; { 8/15/99 2.18+ }
    FMultiMode: TMultiMode;
    FCheckDiskLabels: Boolean;
    FWriteDiskLabels: Boolean;

  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
  published
    property BlockSize: Int64 read FBlockSize write FBlockSize default 1457600;
    property FirstBlockSize: Int64 read FFirstBlockSize write FFirstBlockSize default 0;
    property SaveOnFirstDisk: Int64 read FSaveOnFirstDisk write FSaveOnFirstDisk default 0;
    property SaveZipInfoOnFirstDisk: Boolean read FSaveZipInfo write FSaveZipInfo default False;
    property MultiMode: TMultiMode read FMultiMode write FMultiMode default mmNone;
    property CheckDiskLabels: Boolean read FCheckDiskLabels write FCheckDiskLabels default True;
    property WriteDiskLabels: Boolean read FWriteDiskLabels write FWriteDiskLabels default True;
  end;

  TVCLZip = class(TVCLUnZip)
  private
    FPackLevel: Integer;
    FRecurse: Boolean;
    FDispose: Boolean;
    FStorePaths: Boolean;
    FRelativePaths: Boolean;
    FStoreVolumes: Boolean;
    FZipAction: TZipAction;
    FBlockSize: Int64;
    FMultiZipInfo: TMultiZipInfo;
    FStore83Names: Boolean;
    FTempPath: kpWString;
    FSkipIfArchiveBitNotSet: Boolean; { 7/4/98 2.13 }
    FResetArchiveBitOnZip: Boolean; { Added 4-Jun-98 SPF 2.13 }
    FExcludeList: TkpStrings; { 9/27/98  2.15 }
    FNoCompressList: TkpStrings; { 9/27/98  2.15 }
    FOnZipComplete: TZipComplete;
    FOnStartZipInfo: TStartZipInfo;
    FOnStartZip: TStartZipEvent;
    FOnDisposeFile: TDisposeEvent;
    FOnEndZip: TEndZipFileEvent;
    FOnDeleteEntry: TDeleteEvent;
    FOnNoSuchFile: TNoSuchFileEvent;
    FOnUpdate: TUpdateEvent; { 7/5/99  2.18+ }
    FOnPrepareNextDisk: TPrepareNextDisk; { 7/9/00 2.21b3+ }
    FOnRecursingFile: TOnRecursingFile; { 7/9/01 2.21+ }
    FOnEncrypt: TEncryptEvent; { 12/8/01 2.22+ }
    FOnStartSpanCopy: TOnStartSpanCopy;
    FOnGetNextStream: TOnGetNextStreamEvent;
    {$IFNDEF INT64STREAMS}
    FOnGetNextTStream: TOnGetNextTStreamEvent;
    {$ENDIF}

    AmountWritten: BIGINT;
    AmountToWrite: BIGINT;
    FilenameSize: BIGINT;
    UsingTempFile: Boolean;
    CreatingSFX: Boolean;
    SFXStubFile: TLFNFileStream;
    FPreserveStubs: Boolean;
    FAddDirEntries: Boolean;
    FFileOpenMode: Word;
    FSearchAttribute: Integer;
    FFreeStream: Boolean;
    FEncryptStrength: TEncryptStrength;

  protected
    { Protected declarations }
    zfile: TkpStream; { output compression file }
    IFile: TkpStream; { input file to compress }
    mfile: TkpStream; { temporary file during spanned file creation }
    IFileName: kpWString;
    isize: LongInt;
    tmpfiles: TSortedZip;
    tmpfiles2: TSortedZip;
    tmpecrec: TEndCentral;
    tmpfile_info: TZipHeaderInfo;
    tmpZipName: kpWString;
    mZipName: kpWString;
    Deleting: Boolean;
    FileBytes: BIGINT;
    SaveNewName: kpWString;

    static_ltree: static_ltree_type;
    static_dtree: static_dtree_type;
    bl_count: array[0..MAX_ZBITS] of WORD;
    base_dist: array[0..D_CODES - 1] of Integer;
    length_code: array[0..MAX_MATCH - MIN_MATCH] of Byte;
    dist_code: array[0..511] of Byte;
    base_length: array[0..LENGTH_CODES - 1] of Integer;
    TRInitialized: Boolean;
{$IFDEF WIN16}
    windowObj: TkpHugeByteArray;
    prevObj: TkpHugeWordArray;
    headObj: TkpHugeWordArray;
    l_bufObj: TkpHugeByteArray;
    d_bufObj: TkpHugeWordArray;
    flag_bufObj: TkpHugeByteArray;
{$ENDIF}
    window: windowtypePtr;
    prev: prevtypePtr;
    head: headtypePtr;
    l_buf: l_buftypePtr;
    d_buf: d_buftypePtr;
    flag_buf: flag_buftypePtr;
    aes_authentication: array [0..15] of byte; //PWD_VER_TYPE;


    function zfwrite(buf: BytePtr; item_size, nb: Integer): LongInt;
    function zencode(c: Byte): Byte;
    function file_read(w: BytePtr; size: Integer): LongInt;
    procedure CreateTempZip;
    function kpDeflate( var totalRead: BIGINT ): BIGINT;
    function ProcessFiles: Integer;
    function AddFileToZip(FName: kpWString): Boolean;
    {procedure MoveExistingFiles;}
    procedure MoveFile(Index: Integer);
    procedure MoveTempFile;
    procedure StaticInit;
    procedure CryptHead(passwrd: AnsiString);
    procedure CryptPKHead(passwrd: AnsiString);
    procedure CryptAESHead(passwrd: AnsiString);
    procedure WriteAESAuthentication(stream: TkpStream);

    procedure SetZipName(ZName: kpWString); override;
    function GetIsModified: Boolean;
    procedure SetMultiZipInfo(Value: TMultiZipInfo);
    function GetCheckDiskLabels: Boolean; override;
    procedure SetStoreVolumes(Value: Boolean);
    function GetMultiMode: TMultiMode; override;
    procedure SetCheckDiskLabels(Value: Boolean); override;
    procedure SetMultiMode(Value: TMultiMode); override;
    procedure ResetArchiveBit(AFileName: kpWString); { Added 4-Jun-98 SPF 2.13? }
    function DiskRoom: BIGINT;
    function RoomLeft: BIGINT;
    procedure NextPart;
    procedure LabelDisk;
    procedure SaveZipInfoToFile(Filename: kpWString); { 8/14/99 2.18+ }

    procedure SetDateTime(Index: Integer; DT: TDateTime);
    procedure SetPathname(Index: Integer; Value: TZipPathname);
    procedure SetFilename(Index: Integer; Value: kpWString);
    procedure SetStorePaths(Value: Boolean);
    procedure SetRelativePaths(Value: Boolean);

    function TemporaryPath: kpWString;
    procedure SetExcludeList(Value: TkpStrings); { 9/27/98  2.15 }
    procedure SetNoCompressList(Value: TkpStrings); { 9/27/98  2.15 }
    function IsInExcludeList(N: kpWString): Boolean; { 9/27/98  2.15 }
    function IsInNoCompressList(N: kpWString): Boolean; { 9/27/98  2.15 }

    function GetsaHidden: Boolean;
    procedure SetsaHidden(value: Boolean);
    function GetsaSysFile: Boolean;
    procedure SetsaSysFile(value: Boolean);
    function GetsaReadOnly: Boolean;
    procedure SetsaReadOnly(value: Boolean);
    function GetsaArchive: Boolean;
    procedure SetsaArchive(value: Boolean);

    procedure ExpandForWildCards;    { 8/24/03  3.02+ }
    function ComparePath(P: kpWString):kpWString;


    procedure Loaded; override;

  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override; { 6/27/99 2.18+ }
    function Zip: Integer;
    procedure ExpandFilesList(var NumFiles: Integer; var TotalBytes: Comp);
    function DeleteEntries: Integer;
    procedure SaveModifiedZipFile;
    function ZipFromStream(theStream: TkpStream; FName: kpWString): Integer; overload;
    function ZipFromStream(theStream: TkpStream; FName: kpWString; FreeStreamWhenDone: Boolean): Integer; overload;
    {$IFNDEF INT64STREAMS}
     function ZipFromStream(theStream: TStream; FName: kpWString; FreeStreamWhenDone: Boolean): Integer; overload;
    {$ENDIF}
    function FixZip(InputFile, OutputFile: kpWString): Integer;
    procedure MakeSFX(SFXStub: kpWString; ModHeaders: Boolean);
    function MakeNewSFX(SFXStub: kpWString; FName: kpWString; Options: PAnsiChar;
      OptionsLen: Integer): Integer;
    function ZipFromBuffer(Buffer: PAnsiChar; Amount: Longint; FName: kpWString): Integer;
    procedure SFXToZip(DeleteSFX: Boolean);
    procedure encrypt_buff(buff: BytePtr; length: LongInt);
    function Split(DeleteOriginal: boolean): boolean; { 6/15/02  2.23+ }

    procedure ZLibCompressStream(inStream, outStream: TStream; HttpCompression: Boolean = False);
    procedure ZLibCompressBuffer(const inBuffer: Pointer; inSize: Integer;
                              out outBuffer: Pointer; out outSize: Integer; HttpCompression: Boolean = False);
    function ZLibCompressStr(const s: string; HttpCompression: Boolean = False): string;
    function ZLibCompressString(const s: string; HttpCompression: Boolean = False): string;

    property DateTime[Index: Integer]: TDateTime read GetDateTime write SetDateTime;
    property FileComment[Index: Integer]: AnsiString read GetFileComment write SetFileComment;
    property ZipComment: AnsiString read GetZipComment write SetZipComment;
    property IsModified: Boolean read GetIsModified;
    property CheckDiskLabels: Boolean read GetCheckDiskLabels write SetCheckDiskLabels;
    property MultiMode: TMultiMode read GetMultiMode write SetMultiMode;

    property Pathname[Index: Integer]: TZipPathname read GetPathname write SetPathname;
    property Filename[Index: Integer]: kpWString read GetFilename write SetFilename;
    property PreserveStubs: Boolean read FPreserveStubs write FPreserveStubs default False;
    property FileOpenMode: Word read FFileOpenMode write FFileOpenMode default fmShareDenyNone;

  published
    { Published declarations }
    property PackLevel: Integer read FPackLevel write FPackLevel default 6;
    property Recurse: Boolean read FRecurse write FRecurse default False;
    property Dispose: Boolean read FDispose write FDispose default False;
    property StorePaths: Boolean read FStorePaths write SetStorePaths default False;
    property RelativePaths: Boolean read FRelativePaths write SetRelativePaths default False;
    property StoreVolumes: Boolean read FStoreVolumes write SetStoreVolumes default False;
    property ZipAction: TZipAction read FZipAction write FZipAction default zaUpdate;
    property MultiZipInfo: TMultiZipInfo read FMultiZipInfo write SetMultiZipInfo;
    property Store83Names: Boolean read FStore83Names write FStore83Names default False;
    property TempPath: kpWString read FTempPath write FTempPath; { 5/5/98  2.12 }
    property SkipIfArchiveBitNotSet: Boolean read FSkipIfArchiveBitNotSet
      write FSkipIfArchiveBitNotSet default False; { 7/4/98  2.13 }
    property ResetArchiveBitOnZip: Boolean read FResetArchiveBitOnZip
      write FResetArchiveBitOnZip default False; { Added 4-Jun-98 SPF 2.13? }
    property ExcludeList: TkpStrings read FExcludeList write SetExcludeList; { 9/27/98  2.15 }
    property NoCompressList: TkpStrings read FNoCompressList write SetNoCompressList; { 9/27/98  2.15 }
    property AddDirEntriesOnRecurse: Boolean read FAddDirEntries write FAddDirEntries default False;
    property IncludeHiddenFiles: Boolean read GetsaHidden write SetsaHidden default False;
    property IncludeSysFiles: Boolean read GetsaSysFile write SetsaSysFile default False;
    property IncludeReadOnlyFiles: Boolean read GetsaReadOnly write SetsaReadOnly default True;
    property IncludeArchiveFiles: Boolean read GetsaArchive write SetsaArchive default True;
    property EncryptStrength: TEncryptStrength read FEncryptStrength write FEncryptStrength default esPKStandard;

    { Event Properties }
    property OnStartZip: TStartZipEvent read FOnStartZip write FOnStartZip;
    property OnStartZipInfo: TStartZipInfo read FOnStartZipInfo write FOnStartZipInfo;
    property OnEndZip: TEndZipFileEvent read FOnEndZip write FOnEndZip;
    property OnDisposeFile: TDisposeEvent read FOnDisposeFile write FOnDisposeFile;
    property OnDeleteEntry: TDeleteEvent read FOnDeleteEntry write FOnDeleteEntry;
    property OnNoSuchFile: TNoSuchFileEvent read FOnNoSuchFile write FOnNoSuchFile;
    property OnZipComplete: TZipComplete read FOnZipComplete write FOnZipComplete;
    property OnUpdate: TUpdateEvent read FOnUpdate write FOnUpdate; { 7/5/99  2.18+ }
    property OnPrepareNextDisk: TPrepareNextDisk read FOnPrepareNextDisk write FOnPrepareNextDisk;
    property OnRecursingFile: TOnRecursingFile read FOnRecursingFile write FOnRecursingFile;
    property OnEncrypt: TEncryptEvent read FOnEncrypt write FOnEncrypt; { 12/8/01 2.22+ }
    property OnStartSpanCopy: TOnStartSpanCopy read FOnStartSpanCopy write FOnStartSpanCopy;
    property OnGetNextStream: TOnGetNextStreamEvent read FOnGetNextStream write FOnGetNextStream;
    {$IFNDEF INT64STREAMS}
    property OnGetNextTStream: TOnGetNextTStreamEvent read FOnGetNextTStream write FOnGetNextTStream;
    {$ENDIF}
  end;

{$IFNDEF FULLPACK}
procedure Register;
{$ENDIF}

implementation

uses
{$IFDEF KPDEBUG}
ErrorRpt,
{$ENDIF}
kpDiskIOs;

{$IFDEF USE_ZLIB}

function TVCLZip.kpDeflate( var totalRead: BIGINT): BIGINT;
const
  INBLKSIZ = 65535;
  OUTBLKSIZ = 65535;
var
  ucBuf: PAnsiChar;
  cBuf: PAnsiChar;
  strm: TZStreamRec;
  count: Integer;
  Param: Integer;
  Stat: Integer;
  totalbytes: BIGINT;
begin
  FillChar(strm, sizeof(strm), 0);
  strm.zalloc := zcalloc;
  strm.zfree := zcfree;
  GetMem(ucBuf, INBLKSIZ);
  GetMem(cBuf, OUTBLKSIZ);
  totalbytes := 0;
  totalRead := 0;
  try
    strm.next_in := ucBuf;
    strm.next_out := cBuf;
    strm.avail_out := OUTBLKSIZ;
    strm.avail_in := file_read(BytePtr(ucBuf), INBLKSIZ);
    Inc(totalRead,strm.avail_in);
    CCheck(deflateInit2_(strm, PackLevel, 8, -15, 8, 0, ZLIB_VERSION, sizeof(strm)));
    Param := Z_NO_FLUSH;
    repeat
      if (strm.avail_in = 0) and (Param = Z_NO_FLUSH) then
      begin
        strm.avail_in := file_read(BytePtr(ucBuf), INBLKSIZ);
        Inc(totalRead,strm.avail_in);
        if (strm.avail_in = 0) then
          Param := Z_FINISH;
        strm.next_in := ucBuf;
      end;
      Stat := deflate(strm, Param);
      CCheck(Stat);
      if (strm.avail_out = 0) or (param = Z_FINISH) then
      begin
        count := OUTBLKSIZ - strm.avail_out;
        if (count > 0) then
        begin
          zfwrite(BytePtr(cBuf), 1, count);
          Inc(totalbytes, count);
        end;
        strm.next_out := cBuf;
        strm.avail_out := OUTBLKSIZ;
      end;
    until Stat = Z_STREAM_END;
    CCheck(deflateEnd(strm));
  finally
    FreeMem(ucBuf, INBLKSIZ);
    FreeMem(cBuf, OUTBLKSIZ);
  end;
  Result := totalbytes;
end;
{$ELSE}
{$I kpDFLT.PAS}
{$ENDIF}

constructor TMultiZipInfo.Create;
begin
  inherited Create;
  MultiMode := mmNone;
  FBlockSize := 1457600;
  FFirstBlockSize := 0;
  FSaveOnFirstDisk := 0;
  FSaveZipInfo := False;
  CheckDiskLabels := True;
  FWriteDiskLabels := True;
end;

procedure TMultiZipInfo.Assign(Source: TPersistent);
var
  Src: TMultiZipInfo;
begin
  if Source is TMultiZipInfo then
  begin
    Src := TMultiZipInfo(Source);
    FMultiMode := Src.MultiMode;
    FBlockSize := Src.BlockSize;
    FFirstBlockSize := Src.FirstBlockSize;
    FSaveOnFirstDisk := Src.SaveOnFirstDisk;
    FSaveZipInfo := Src.FSaveZipInfo;
    FCheckDiskLabels := Src.CheckDiskLabels;
    FWriteDiskLabels := Src.WriteDiskLabels;
  end
  else inherited Assign(Source);
end;

constructor TVCLZip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMultiZipInfo := TMultiZipInfo.Create;
  FPackLevel := 6;
  FRecurse := False;
  FDispose := False;
  FStorePaths := False;
  FStoreVolumes := False;
  FZipAction := zaUpdate; {update only if newer}
  FBlockSize := 1457600;
  FRelativePaths := False;
  FStore83Names := False;
  FTempPath := '';
  Deleting := False;
  zfile := nil;
  tmpfiles := nil;
  tmpecrec := nil;
  TRInitialized := False;
  SaveNewName := '';
{$IFNDEF USE_ZLIB}
  StaticInit;
{$ENDIF}
  CreatingSFX := False;
  FSkipIfArchiveBitNotSet := False; { 7/4/98 2.13 }
  FResetArchiveBitOnZip := False; { Added 4-Jun-98 SPF 2.13? }
  FExcludeList := TkpStringList.Create; { 9/27/98  2.15 }
  FnoCompressList := TkpStringList.Create; { 9/27/98  2.15 }
  FPreserveStubs := False; { 01/12/99  2.17 }
  FAddDirEntries := False; { 06/09/99 2.18+ }
  FFileOpenMode := fmShareDenyNone; { 10/17/99 2.18+ } { changed back to fmShareDenyNone }
                                                        { 05/13/00 2.20+  }
  FSearchAttribute := faAnyFile;
  IncludeHiddenFiles := False;
  IncludeSysFiles := False;
  IncludeReadOnlyFiles := True;
  IncludeArchiveFiles := True;
  FEncryptStrength := esPKStandard;
  //NTSetPrivilege(SE_BACKUP_NAME, true);
end;

destructor TVCLZip.Destroy;
begin
  FMultiZipInfo.Free;
  FMultiZipInfo := nil; { 4/25/98  2.11 }
  if (FExcludeList <> nil) then
    FExcludeList.Free; { 9/27/98  2.15 }
  if (FNoCompressList <> nil) then
    FNoCompressList.Free; { 9/27/98  2.15 }
  //NTSetPrivilege(SE_BACKUP_NAME, false);
  inherited Destroy;
end;

procedure TVCLZip.Loaded;
begin
  inherited Loaded;
  SetCheckDiskLabels(FMultiZipInfo.CheckDiskLabels);
  SetMultiMode(FMultiZipInfo.MultiMode);
end;

procedure TVCLZip.StaticInit;
begin
  ZeroMemory(@static_ltree, SizeOf(static_ltree));
  ZeroMemory(@static_dtree, SizeOf(static_dtree));
  ZeroMemory(@bl_count, SizeOf(bl_count));
  ZeroMemory(@base_dist, SizeOf(base_dist));
  ZeroMemory(@length_code, SizeOf(length_code));
  ZeroMemory(@dist_code, SizeOf(dist_code));
  ZeroMemory(@base_length, SizeOf(base_length));
end;

procedure TVCLZip.Assign(Source: TPersistent); { 6/27/99 2.18+ }
begin
  if source is TVCLZip then
  begin
    inherited Assign(Source);
    FPackLevel := TVCLZip(Source).PackLevel;
    FRecurse := TVCLZip(Source).Recurse;
    FDispose := TVCLZip(Source).Dispose;
    FStorePaths := TVCLZip(Source).StorePaths;
    FRelativePaths := TVCLZip(Source).RelativePaths;
    FStoreVolumes := TVCLZip(Source).StoreVolumes;
    FZipAction := TVCLZip(Source).ZipAction;
    FMultiZipInfo.Assign(TVCLZip(Source).MultiZipInfo);
    FStore83Names := TVCLZip(Source).Store83Names;
    FTempPath := TVCLZip(Source).TempPath; { 5/5/98  2.12 }
    FSkipIfArchiveBitNotSet := TVCLZip(Source).SkipIfArchiveBitNotSet; {
7/4/98  2.13 }
    FResetArchiveBitOnZip := TVCLZip(Source).ResetArchiveBitOnZip; {
Added 4-Jun-98 SPF 2.13? }
    FExcludeList.Assign(TVCLZip(Source).ExcludeList); { 9/27/98  2.15 }

    FNoCompressList.Assign(TVCLZip(Source).NoCompressList); { 9/27/98
2.15 }

    FPreserveStubs := TVCLZip(Source).PreserveStubs; { 01/12/99  2.17 }
    FAddDirEntries := TVCLZip(Source).AddDirEntriesOnRecurse; { 06/09/99 2.18+ }
    { Event Properties }
    FOnStartZip := TVCLZip(Source).OnStartZip;
    FOnStartZipInfo := TVCLZip(Source).OnStartZipInfo;
    FOnEndZip := TVCLZip(Source).OnEndZip;
    FOnDisposeFile := TVCLZip(Source).OnDisposeFile;
    FOnDeleteEntry := TVCLZip(Source).OnDeleteEntry;
    FOnNoSuchFile := TVCLZip(Source).OnNoSuchFile;
    FOnZipComplete := TVCLZip(Source).OnZipComplete;
    FOnUpdate := TVCLZip(Source).OnUpdate;
  end
  else
    inherited Assign(Source);

end;

procedure TVClZip.SetPathname(Index: Integer; Value: TZipPathname);
var
  finfo: TZipHeaderInfo;
  tmpValue: kpWString;
begin
  if (Index > -1) and (Index < Count) then
  begin
    finfo := sortfiles.Items[Index] as TZipHeaderInfo;
    if (Length(Value) > 0) and (Value[Length(Value)] <> '\') then
      tmpValue := Value + '\'
    else
      tmpValue := Value;
    if tmpValue <> finfo.directory then
    begin
      finfo.directory := tmpValue;
      ecrec.Modified := True;
    end;
  end
  else
    raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

procedure TVClZip.SetFilename(Index: Integer; Value: TZipPathname);
var
  finfo: TZipHeaderInfo;
begin
  if (Index > -1) and (Index < Count) then
  begin
    finfo := sortfiles.Items[Index] as TZipHeaderInfo;
    if Value <> finfo.filename then
    begin
      finfo.filename := Value;
      ecrec.Modified := True;
    end;
  end
  else
    raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

procedure TVCLZip.SetMultiZipInfo(Value: TMultiZipInfo);
begin
  FMultiZipInfo.Assign(Value);
end;

function TVCLZip.GetMultiMode: TMultiMode;
begin
  Result := FMultiZipInfo.FMultiMode;
end;

procedure TVCLZip.SetMultiMode(Value: TMultiMode);
begin
  if FMultiZipInfo = nil then { 4/26/98  2.11 }
    exit; { to avoid illegal pointer operation error during Destroy method }
  if Value <> FMultiZipInfo.FMultiMode then
    FMultiZipInfo.FMultiMode := Value;
  FMultiMode := Value;
end;

function TVCLZip.GetCheckDiskLabels: Boolean;
begin
  Result := FMultiZipInfo.CheckDiskLabels;
end;

procedure TVCLZip.SetCheckDiskLabels(Value: Boolean);
begin
  if Value <> FMultiZipInfo.CheckDiskLabels then
    FMultiZipInfo.CheckDiskLabels := Value;
  FCheckDiskLabels := Value;
end;

procedure TVCLZip.SetStoreVolumes(Value: Boolean);
begin
  if Value <> FStoreVolumes then
  begin
    FStoreVolumes := Value;
    if Value = True then
      FStorePaths := True;
  end;
end;

procedure TVCLZip.SetStorePaths(Value: Boolean);
begin
  if Value <> FStorePaths then
  begin
    if Value = False then
    begin
      FStoreVolumes := False;
      FRelativePaths := False;
    end;
    FStorePaths := Value;
  end;
end;

procedure TVCLZip.SetRelativePaths(Value: Boolean);
begin
  if Value <> FRelativePaths then
  begin
    if Value = True then
    begin
      FStorePaths := True;
      FRecurse := True;
    end;
    FRelativePaths := Value;
  end;
end;

{ Added 4-Jun-98 SPF 2.13? }

procedure TVCLZip.ResetArchiveBit(AFileName: kpWString);
begin
  kpFileSetAttributes(AFileName, (kpFileGetAttributes(AFileName) and not faArchive));
end;

function TVCLZip.ZipFromStream(theStream: TkpStream; FName: kpWString): Integer;
begin
  Result := ZipFromStream(theStream,FName,False);
end;

function TVCLZip.ZipFromStream(theStream: TkpStream; FName: kpWString; FreeStreamWhenDone: Boolean): Integer;
begin
  if (Trim(FName) = '') or (TheStream = nil) then
  begin
    result := 0;
    exit;
  end;
  FFreeStream := FreeStreamWhenDone;
  CancelOperation := False;
  StreamZipping := True;
  ZipStream := theStream;
  ZipStream.Position := 0;
  FilesList.Clear;
  FilesList.Add(FName);
  try
    Result := Zip;
  finally
    StreamZipping := False;
    CloseZip;
  end;
end;

{$IFNDEF INT64STREAMS}
 function TVCLZip.ZipFromStream(theStream: TStream; FName: kpWString; FreeStreamWhenDone: Boolean): Integer;
var
   InternalStream:tKpHugeMemoryStream;
   OldBusy: Boolean;
begin
     FFreeStream := True; // Must free TkpHugeStream internal to VCLZip in this case.
     if (TheStream is TMemoryStream) and (not Assigned(OnGetNextTStream)) then
      begin
        // This saves step of copying stream so it's faster and more efficient
        result:=ZipFromBuffer(PAnsiChar(TMemoryStream(TheStream).Memory),TheStream.Size,FName);
        if (FreeStreamWhenDone) then
          theStream.Free;
      end
     else
      begin
        OldBusy := SetBusy(True);
        InternalStream := tKpHugeMemoryStream.Create;
        try
           InternalStream.Size := theStream.Size;
           TheStream.Position:=0;
           InternalStream.CopyFrom(TheStream,TheStream.Size);
           // Free here to save memory as soon as possible.
           if (FreeStreamWhenDone) then
             theStream.Free;
           InternalStream.Position:=0;
           result:=ZipFromStream(InternalStream,FName,FreeStreamWhenDone);
        finally
           SetBusy(OldBusy);
        end;
      end;
end;
{$ENDIF}

function TVCLZip.ZipFromBuffer(Buffer: PAnsiChar; Amount: LongInt; FName: kpWString): Integer;
begin
  Result := 0;
  if (Trim(FName) = '') or (Amount = 0) then
    exit;
  MemBuffer := Buffer;
  CurrMem := Buffer;
  MemLen := Amount;
  MemLeft := Amount;
  MemZipping := True;
  FilesList.Clear;
  FilesList.Add(Fname);
  try
    Result := Zip;
  finally
    MemZipping := False;
    CloseZip;
  end;
end;

function TVCLZip.Zip: Integer;
var
  OldBusy: Boolean;
begin
  OldBusy := SetBusy(True);
  try
    Result := ProcessFiles;
    if Assigned(FOnZipComplete) then FOnZipComplete(self, Result);
  finally
    SetBusy(OldBusy);
  end;
end;

procedure TVCLZip.ExpandFilesList(var NumFiles: Integer; var TotalBytes: Comp);
begin
  ExpandForWildCards;
  NumFiles :=  FilesList.Count;
  TotalBytes := TotalUncompressedSize;
end;

function TVCLZip.IsInExcludeList(N: kpWString): Boolean;
var
  i: Integer;
  M, M1, M2: kpWString; { 11/27/98  2.16+}
begin
  Result := False;
  i := 0;
  M1 := kpLowerCase(kpExtractFilename(N)); { 10/23/98  2.16+ }
  M2 := kpLowerCase(N);
  while i < FExcludeList.Count do
  begin
     {If this exclude list item doesn't include path info then ignore
      path info for the file being tested too}
    if (Pos('\', FExcludeList[i]) = 0) then { 11/27/98  2.16+}
      M := M1
    else
      M := M2;
    if IsMatch(kpLowerCase(FExcludeList[i]), M) then
    begin
      Result := True;
      break;
    end;
    Inc(i);
  end;
end;

function TVCLZip.IsInNoCompressList(N: kpWString): Boolean;
var
  i: Integer;
  M, M1, M2: kpWString;
begin
  Result := False;
  i := 0;
  M1 := kpLowerCase(kpExtractFilename(N)); { 10/23/98  2.16+ }
  M2 := kpLowerCase(N);
  while i < FNoCompressList.Count do
  begin
     {If this exclude list item doesn't include path info then ignore
      path info for the file being tested too}
    if (Pos('\', FNoCompressList[i]) = 0) then { 11/27/98  2.16+}
      M := M1
    else
      M := M2;
    if IsMatch(kpLowerCase(FNoCompressList[i]), M) then
    begin
      Result := True;
      break;
    end;
    Inc(i);
  end;
end;

  function TVCLZip.ComparePath(P: kpWString): kpWString;
  { This function expects P and RootDir to include full path information
    including disk information.  Also it is assumed that if RelativePaths
    is True then the path information for P contains RootDir. }
  begin
    if StorePaths then
    begin
      Result := kpExtractFilePath(P);
      if FRelativePaths then
        Delete(Result, 1, Length(FRootDir))
      else
      begin
        { modified the following to handle UNC paths  3/26/98  2.1 }
        if (not FStoreVolumes) and (ExtractFileDrive(Result) <> '') {(Result[2] = ':')} then
          Result := RightStr(Result, Length(Result) - (Length(ExtractFileDrive(Result)) + 1));
           {Result := RightStr(Result,Length(Result)-3);}
      end;
    end
    else
      Result := '';
  end;

  procedure TVCLZip.ExpandForWildCards;
  var
    i: Integer;
    WildFiles: TkpStrings;
    DirSearch: TDirSearch;
    theFile, StartDir: kpWString;
    SearchRec: kpTSearchRec;
    tmpsearchinfo: TZipHeaderInfo;
    tmpWildCard: kpWString;
    Idx: Integer;
    IsAnEntry: Boolean;
    doRecurse: Boolean;
    tmpWildFile: kpWString;
    tmpName: kpWString;
    Retry: Boolean;
  begin
    WildFiles := TkpStringList.Create;
    TotalUncompressedSize := 0;
    TotalBytesDone := 0;
    i := 0;
    FilenameSize := 0;
    // Dummy call
    DirExists('');
    if ZipAction = zaFreshen then
      Sort(ByName); { so we can check FilesList agains whats there already }
    while (FilesList.Count > 0) and (i < FilesList.Count) do
    begin
      if (FilesList[i][Length(FilesList[i])] = '\') then
      begin
        if (MultiZipInfo.MultiMode <> mmNone) and (MultiZipInfo.SaveZipInfoOnFirstDisk) and (StorePaths) then
          FilenameSize := FileNameSize + Length(FilesList[i]) - 2;
        Inc(i);
        continue; { To explicitly add a plain directory entry  6/9/99 2.18+ }
      end;
      if IsWildcard(FilesList[i]) then
      begin
        WildFiles.Add(FilesList[i]);
        FilesList.Delete(i);
      end
      else
      begin { See if file exists }
        if kpExtractFileDir(FilesList[i]) = '' then
          FilesList[i] := FRootDir + FilesList[i];
        if IsInExcludeList(FilesList[i]) then { 9/28/98  2.15 }
        begin
          if (Assigned(FOnSkippingFile)) then
            FOnSkippingFile(Self, srExcludeList, FilesList[i], -1, Retry);
          FilesList.Delete(i);
          Continue;
        end;
        if (kpFindFirst(FilesList[i], FSearchAttribute, SearchRec) = 0) then
        begin
          if ((FSkipIfArchiveBitNotSet) and ((kpFileGetAttributes(FilesList[i]) and faArchive) = 0)) then
          begin
            if (Assigned(FOnSkippingFile)) then
              FOnSkippingFile(Self, srArchiveBitNotSet, FilesList[i], -1, Retry);
            FilesList.Delete(i);
            kpFindClose(SearchRec);
            Continue; { Skip if only zipping files with archive bit set }
          end;
          if ZipAction = zaFreshen then
          begin
                { Ignore it if it's not already in the zip }
            tmpName := FilesList[i];
            {$IFNDEF SUPPORT_UNICODE}
            if (OEMConvert = oemAlways) then
              OemFilter(tmpName);
            {$ENDIF}
            tmpsearchinfo := CreateNewZipHeader;
            tmpsearchinfo.filename := kpExtractFilename(tmpName);
            tmpsearchinfo.directory := ComparePath(tmpName);
            IsAnEntry := sortfiles.Search(Pointer(tmpsearchinfo), Idx);
            tmpsearchinfo.Free;
            if not IsAnEntry then { Delete this entry from fileslist }
            begin
              if (Assigned(FOnSkippingFile)) then
                FOnSkippingFile(Self, srNoFileToFreshen, FilesList[i], -1, Retry);
              FilesList.Delete(i);
              kpFindClose(SearchRec);
              Continue; { Skip if freshening and file's not in zip already }
            end;
          end;
          TotalUncompressedSize := TotalUncompressedSize + GetFileSize(SearchRec);
          if (MultiZipInfo.MultiMode <> mmNone) and (MultiZipInfo.SaveZipInfoOnFirstDisk) and (StorePaths) then
            FilenameSize := FileNameSize + Length(FilesList[i]) - 2;
          Inc(i);
          kpFindClose(SearchRec); {1/28/98 moved inside here so wouldn't be called if}
        end {FindFirst didn't find anything    v2.00+}
        else
        begin
          if Assigned(FOnNoSuchFile) then
            OnNoSuchFile(Self, FilesList[i]);
              { Moved following line down 1 to fix 'List out of bounds' error. 5/5/98 2.12 }
          FilesList.Delete(i); { No such file to zip }
        end;
      end;
    end;

    if WildFiles.Count > 0 then
      for i := 0 to WildFiles.Count - 1 do
      begin
        { Added recursion override feature 7/22/98  2.14 }
        if (WildFiles[i][1] = WILDCARD_NORECURSE) then { No recursing }
        begin
          doRecurse := False;
          tmpWildFile := WildFiles[i];
          Delete(tmpWildFile, 1, 1);
          WildFiles[i] := tmpWildFile;          
        end
        else if (WildFiles[i][1] = WILDCARD_RECURSE) then { Recurse }
        begin
          doRecurse := True;
          tmpWildFile := WildFiles[i];
          Delete(tmpWildFile, 1, 1);
          WildFiles[i] := tmpWildFile;
        end
        else doRecurse := FRecurse;

        StartDir := kpExtractFileDir(WildFiles[i]);
        if StartDir = '' then
          StartDir := FRootDir;
        { Added check for not IsWildCard because it was stopping the use
          of wildcards in paths.   8/22/01  2.22+  }
        if (not IsWildCard(StartDir)) and (not kpDirectoryExists(StartDir)) then { 10/23/98  2.16+ }
        begin
          if Assigned(FOnNoSuchFile) then
            OnNoSuchFile(Self, WildFiles[i]);
          continue;
        end;
        tmpWildCard := kpExtractFilename(WildFiles[i]);
        { Convert *.* to * so that it will get all files in
          TDirSearch }
        if (tmpWildCard = '*.*') then { 7/9/01  2.21+ }
          tmpWildCard := '*';
        DirSearch := TDirSearch.Create(StartDir, tmpWildCard, doRecurse, FSearchAttribute);
        theFile := DirSearch.NextFile(SearchRec);
        while (theFile <> '') do
        begin
          if (Assigned(FOnRecursingFile)) then
            FOnRecursingFile(Self, theFile);
          if (theFile[Length(theFile)] = '\') then
          begin
            if {(doRecurse) and} (FAddDirEntries) then  {removed reliance on doRecurse 4/21/06}
            begin
              if (MultiZipInfo.MultiMode <> mmNone) and (MultiZipInfo.SaveZipInfoOnFirstDisk) and (StorePaths) then
                FilenameSize := FileNameSize + Length(theFile) - 2;
              FilesList.Add(theFile);
            end;
            theFile := DirSearch.NextFile(SearchRec);
            Continue;
          end;
          if IsInExcludeList(theFile) then { 9/28/98  2.15 }
          begin
            if (Assigned(FOnSkippingFile)) then
              FOnSkippingFile(Self, srExcludeList, theFile, -1, Retry);
            theFile := DirSearch.NextFile(SearchRec);
            Continue;
          end;
          if (DoProcessMessages) then
          begin
            YieldProcess;
            if CancelOperation then
            begin
              CancelOperation := False;
              raise EUserCanceled.Create(LoadStr(IDS_CANCELOPERATION));
            end;
            if PauseOperation then
              DoPause;
          end;
           {Don't archive the archive we are creating right now}
          if (ArchiveIsStream) or (kpCompareText(theFile, ZipName) <> 0) then
          begin
            if ((FSkipIfArchiveBitNotSet) and ((kpFileGetAttributes(theFile) and faArchive) = 0)) then
            begin
              if (Assigned(FOnSkippingFile)) then
                FOnSkippingFile(Self, srArchiveBitNotSet, theFile, -1, Retry);
              theFile := DirSearch.NextFile(SearchRec);
              Continue; { Skip if only zipping files with archive bit set }
            end;
            if ZipAction = zaFreshen then { skip if its not already in zip file }
            begin
                 { Ignore it if it's not already in the zip }
              tmpName := theFile;
              {$IFNDEF SUPPORT_UNICODE}
              if (OEMConvert = oemAlways) then
                OemFilter(tmpName);
              {$ENDIF}
              tmpsearchinfo := CreateNewZipHeader;
              tmpsearchinfo.filename := kpExtractFilename(tmpName);
              tmpsearchinfo.directory := ComparePath(tmpName);
              IsAnEntry := sortfiles.Search(Pointer(tmpsearchinfo), Idx);
              tmpsearchinfo.Free;
              if not IsAnEntry then
              begin
                if (Assigned(FOnSkippingFile)) then
                  FOnSkippingFile(Self, srNoFileToFreshen, theFile, -1, Retry);
                theFile := DirSearch.NextFile(SearchRec);
                Continue; { Skip if freshening and file's not in zip already }
              end;
            end;
            if (MultiZipInfo.MultiMode <> mmNone) and (MultiZipInfo.SaveZipInfoOnFirstDisk) and (StorePaths) then
              FilenameSize := FileNameSize + Length(theFile) - 2;
            FilesList.Add(theFile);
            TotalUncompressedSize := TotalUncompressedSize + GetFileSize(SearchRec);
          end;
          theFile := DirSearch.NextFile(SearchRec);
        end;
        DirSearch.Free;
      end;

    WildFiles.Free;
    if (FilesList.Count > 0) and (FilenameSize > 0) and (MultiZipInfo.MultiMode <> mmNone)
          and (MultiZipInfo.SaveZipInfoOnFirstDisk) and (StorePaths) then
      FilenameSize := FileNameSize div FilesList.Count;
    if ZipAction = zaFreshen then
      Sort(ByNone); { Set back }
  end;


function TVCLZip.ProcessFiles: Integer;
var
  DisposeFiles: TkpStrings;
const
  SPANNED_SIG = $08074b50;
  SPANNED_NOT_SIG = $30304b50;

  procedure AddTheNewFile(i: Integer);

  {$IFDEF KPDEBUG}
    procedure ShowError(reason: string; e: Exception);
    var
      err: TErrorReport;
    begin
      err := TErrorReport.Create(self);
      err.ErrorMemo.Lines.Add(e.Message + ' - ' + reason);
      err.ErrorMemo.Lines.Add('  file = ' + tmpfile_info.directory + tmpfile_info.filename);
      err.ErrorMemo.Lines.Add('  relative_offset = ' + IntToStr(tmpfile_info.relative_offset));
      err.ErrorMemo.Lines.Add('  file position = ' + IntToStr(zfile.Position));
      err.ErrorMemo.Lines.Add('   file size = ' + IntToStr(zfile.Size));
      err.ErrorMemo.Lines.Add('  disk_number_start = ' + IntToStr(tmpfile_info.disk_number_start));
      err.ErrorMemo.Lines.Add('  uncompressed size = ' + IntToStr(tmpfile_info.uncompressed_size));
      err.ErrorMemo.Lines.Add('  compressed size = ' + IntToStr(tmpfile_info.compressed_size));
      err.ErrorMemo.Lines.Add('  number of entries = ' + IntToStr(tmpecrec.num_entries));
      err.ErrorMemo.Lines.Add('  current disk = ' + IntToStr(CurrentDisk));
      err.ErrorMemo.Lines.Add('  ');
      err.ErrorMemo.Lines.Add('  CLOSE WINDOW TO CONTINUE...');
      err.ShowModal;
      err.Free;
    end;
  {$ENDIF}

  begin
    try
      tmpfiles.AddObject(tmpfile_info);
    except
      on e: Exception do
      begin
        {$IFDEF KPDEBUG}
        ShowError('ByName', e);
        exit;
        {$ELSE}
        raise;
        {$ENDIF}
      end;
    end;
    try
      tmpfiles2.AddObject(tmpfile_info);
    except
      on e: Exception do
      begin
        {$IFDEF KPDEBUG}
        ShowError('ByPosition', e);
        exit;
        {$ELSE}
        raise;
        {$ENDIF}
      end;
    end;
    Inc(Result);
    tmpecrec.num_entries := tmpecrec.num_entries + 1;
    //tmpecrec.num_entries_this_disk := tmpecrec.num_entries_this_disk + 1;// Removed 2-28-06
    if Dispose then
      DisposeFiles.Add(FilesList[i]);
  end;

  procedure DisposeOfFiles;
  var
    x: Integer;
    Skip: Boolean;
  begin
    Skip := False;
    for x := 0 to DisposeFiles.Count - 1 do
    begin
      if Assigned(FOnDisposeFile) then
      begin
        Skip := False;
        FOnDisposeFile(Self, DisposeFiles[x], Skip);
      end;
      if not Skip then
        kpDeleteFile(DisposeFiles[x]);
    end;
    DisposeFiles.Free;
    DisposeFiles := nil;
  end;


  procedure MoveExistingFiles;

    function FilesListMatches(FName: kpWString): Boolean;
    var
      tmpFName: kpWString;
    begin
      {$IFNDEF SUPPORT_UNICODE}
      if (OEMConvert = oemAlways) then
        OemFilter(Fname);
      {$ENDIF}
      tmpFName := kpLowerCase(FName);
      if (Deleting) and (IsWildCard(FName)) then
      begin { Wildcards should only be there if deleting }
        if (Pos('\', FName) > 0) then
          Result := IsMatch(tmpFName, kpLowerCase(tmpfile_info.directory + tmpfile_info.filename))
        else
          Result := IsMatch(tmpFName, kpLowerCase(tmpfile_info.filename));
      end
      else
      begin
        if not Deleting then
        begin
          tmpFName := ComparePath(tmpFName) + kpExtractFilename(tmpFName);
        end;
        Result := tmpFName = kpLowerCase(tmpfile_info.directory + tmpfile_info.filename);
      end;
    end;

  var
    i, j: Integer;
    MoveTheFile: Boolean;
    Skip: Boolean;
    SearchRec: kpTSearchRec;

  begin
    if files = nil then { 3/28/98 2.1 }
      exit; { fixed GPF when adding to empty archive }
    for i := 0 to files.Count - 1 do { Check each file in existing zip }
    begin
      //if (Assigned(OnTotalPercentDone)) then
      //  FOnTotalPercentDone(self, CBigRate(files.Count, i + 1));
      tmpfile_info := CreateNewZipHeader;
      tmpfile_info.Assign(files.Items[i] as TZipHeaderInfo);
      if ((i = 0) and (tmpfile_info.relative_offset > 0) and (FPreserveStubs)) then
      begin { save sfx stub from beginning of file }
        theZipFile.Seek(0, soBeginning);
        zfile.CopyFrom(theZipFile, tmpfile_info.relative_offset);
      end;
      if (tmpfile_info.FileIsOK = 2) then { skip files that are corrupted }
      begin
        tmpfile_info.Free;
        continue;
      end;
      if (tmpfile_info.file_comment_length > 0) and (Length(tmpfile_info.filecomment) = 0) then
      begin
        tmpfile_info.filecomment := FileComment[i];
      end;
      MoveTheFile := True;

      if (Deleting) and (tmpfile_info.Selected) then
      begin
        Skip := False;
        tmpfile_info.Selected := False;
        if (assigned(FOnDeleteEntry)) then
          FOnDeleteEntry(Self, tmpfile_info.directory + tmpfile_info.filename, Skip);
        if (not Skip) then
        begin
          Inc(Result);
          MoveTheFile := False;
        end;
      end
      else if (FilesList.Count > 0) then
        for j := 0 to FilesList.Count - 1 do { Compare to each file in FilesList }
        begin
            if CancelOperation then
            begin
              CancelOperation := False;
              raise EUserCanceled.Create(LoadStr(IDS_CANCELOPERATION));
            end;
          if (FilesListMatches(FilesList[j])) then
          begin { This file is in zip file and fileslist too }
            if (StreamZipping) or (MemZipping) or (ZipAction = zaReplace) or
              (Deleting) or (((ZipAction = zaUpdate) or (ZipAction = zaFreshen))
              and (DateTime[i] < FileDate(FilesList[j]))) then
            begin { Don't move files that will be replaced }
              Skip := False;
              if (Deleting) and (Assigned(FOnDeleteEntry)) then
                FOnDeleteEntry(Self, tmpfile_info.directory + tmpfile_info.filename, Skip);
              if (Deleting) and (not Skip) then
                Inc(Result); { 5/18/98  2.13 }
              if not Skip then
              begin
                MoveTheFile := False; { or deleted. }
                if (Deleting) and (not IsWildcard(FilesList[j])) then
                  FilesList.Delete(j); { We're deleting, not zipping }
                if (not Deleting) then
                begin
                  tmpfile_info.Free;
                  tmpfile_info := CreateNewZipHeader;
                  if Assigned(FOnUpdate) then
                    FOnUpdate(self, uaReplacing, i);
                  try
                    if AddFileToZip(FilesList[j]) then
                      AddTheNewFile(j)
                    else
                    begin
                      tmpfile_info.Free;
                      tmpfile_info := nil;
                    end;
                  except
                    tmpfile_info.Free;
                    tmpfile_info := nil;
                    raise;
                  end;
                  FilesList.Delete(j);
                end;
              end
              else
              begin
                MoveTheFile := True; { File should just be saved from current zip }
                FilesList.Delete(j); { because current file is not older }
              end;
            end
            else
            begin
              if Dispose then { 11/23/00  2.21b4+ }
                DisposeFiles.Add(FilesList[j]); { Dispose of original file anyway }
              MoveTheFile := True; { File should just be saved from current zip }
              if kpFindFirst(FilesList[j], FSearchAttribute, SearchRec) = 0 then
              begin
                TotalUncompressedSize := TotalUncompressedSize - GetFileSize(SearchRec)
                                          + tmpfile_info.compressed_size;
                kpFindClose(SearchRec);
              end;
              FilesList.Delete(j); { because disk file is not newer }
            end;
            Break;
          end;
        end;

      if MoveTheFile then { Save this old file into new zip }
      begin
        if (Assigned(FOnUpdate)) then
          FOnUpdate(self, uaKeeping, i);
        MoveFile(i);
        tmpfiles.AddObject(tmpfile_info); { Add info to new stuff }
        tmpfiles2.AddObject(tmpfile_info);
        tmpecrec.num_entries := tmpecrec.num_entries + 1;
        //tmpecrec.num_entries_this_disk := tmpecrec.num_entries_this_disk + 1;// Removed 2-28-06
      end
      else
        if (Deleting) then
          tmpfile_info.Free
    end;
    tmpfile_info := nil;
  end;



{$IFNDEF USE_ZLIB}
  procedure AllocateZipArrays;
  begin
{$IFDEF WIN16}
    if windowObj = nil then
    begin
      windowObj := TkpHugeByteArray.Create(2 * WSIZE);
      window := windowtypePtr(windowObj.AddrOf[0]);
      prevObj := TkpHugeWordArray.Create(WSIZE);
      prev := prevtypePtr(prevObj.AddrOf[0]);
      headObj := TkpHugeWordArray.Create(HASH_SIZE);
      head := headtypePtr(headObj.AddrOf[0]);
      l_bufObj := TkpHugeByteArray.Create(LIT_BUFSIZE);
      l_buf := l_buftypePtr(l_bufObj.AddrOf[0]);
      d_bufObj := TkpHugeWordArray.Create(DIST_BUFSIZE);
      d_buf := d_buftypePtr(d_bufObj.AddrOf[0]);
      flag_bufObj := TkpHugeByteArray.Create(LIT_BUFSIZE div 8);
      flag_buf := flag_buftypePtr(flag_bufObj.AddrOf[0]);
    end;
{$ELSE}
    if window = nil then
    begin
      New(window);
      New(prev);
      New(head);
      New(l_buf);
      New(d_buf);
      New(flag_buf);
    end;
{$ENDIF}
  end;

  procedure DeAllocateZipArrays;
  begin
{$IFDEF WIN16}
    windowObj.Free;
    windowObj := nil;
    prevObj.Free;
    prevObj := nil;
    headObj.Free;
    headObj := nil;
    l_bufObj.Free;
    l_bufObj := nil;
    d_bufObj.Free;
    d_bufObj := nil;
    flag_bufObj.Free;
    flag_bufObj := nil;
{$ELSE}
    System.Dispose(window);
    window := nil;
    System.Dispose(prev);
    prev := nil;
    System.Dispose(head);
    head := nil;
    System.Dispose(l_buf);
    l_buf := nil;
    System.Dispose(d_buf);
    d_buf := nil;
    System.Dispose(flag_buf);
    flag_buf := nil;
{$ENDIF}
  end;
{$ENDIF}

 procedure zipdata( i: Integer);
 begin
         tmpfile_info := CreateNewZipHeader;
        try
          if AddFileToZip(FilesList[i]) then
            AddTheNewFile(i)
          else
          begin
            tmpfile_info.Free;
            tmpfile_info := nil;
          end;
        except
          tmpfile_info.Free;
          tmpfile_info := nil;
          raise;
        end;
 end;

var
  i: Integer;
  FinishedOK: Boolean;
  SaveSortedFiles: TSortedZip;
  SaveSortMode: TZipSortMode;
  SaveKeepZipOpen: Boolean;
  SaveZipName: kpWString;
  StopNow: Boolean;
  TotalCentralSize: LongInt;
  SaveCentralPos: BIGINT;
  temporaryZipName: kpWString;
  nextFile: kpWString;
  OldBusy: Boolean;
  clusterSize: DWORD;
  span_sig: LongInt;
  span_not_sig: LongInt;
  OldOperationMode: TOperationMode;

  {$IFNDEF INT64STREAMS}
  newStream: TStream;
  {$ENDIF}


begin {************** ProcessFiles Main Body ****************}
  Result := 0;
  CancelOperation := False;
  if FilesList = nil then
    exit;
  { Either ZipName or ArchiveStream should be set }
  if ((Trim(ZipName) = '') and (ArchiveStream = nil)) then { 09/07/99 2.18+ }
    exit;
  OldBusy := SetBusy(True);
  FinishedOK := False;
  CurrentDisk := 0;
  SaveSortedFiles := nil;
  if {(SortMode <> byNone) and}(CreatingSFX) then
    SaveSortedFiles := sortfiles
  else
    if (sortfiles <> nil) and (sortfiles <> files) then
      sortfiles.Free;
  SaveSortMode := SortMode;
  SaveKeepZipOpen := KeepZipOpen;
  KeepZipOpen := True;
  sortfiles := files;
  SortMode := ByNone;
  OldOperationMode := SetOperationMode(omZip);

 try { Moved up to here 4/12/98  2.11 }
  if Dispose then
    DisposeFiles := TkpStringList.Create;
  if (not Deleting) and (not StreamZipping) and (not MemZipping) and (FilesList.Count > 0) then
    ExpandForWildCards;

    if (not Deleting) and (FilesList.Count > 0) then
    begin
      StopNow := False;
      if Assigned(FOnStartZipInfo) then
        FOnStartZipInfo(Self, FilesList.Count, TotalUncompressedSize, tmpecrec, StopNow);
      if StopNow then
        raise EUserCanceled.Create(LoadStr(IDS_CANCELZIPOPERATION));
    end;

    if ((ArchiveIsStream) and (Count > 0))
      or ((kpFileExists(ZipName)) and (MultiZipInfo.MultiMode = mmNone)) then
    begin
{$IFNDEF USE_ZLIB} { Added Multimode check 06/11/00  2.21b3+ }
      AllocateZipArrays;
{$ENDIF}
     { create new file in temporary directory }
      UsingTempFile := True;
      if not ArchiveIsStream then
      begin
        {PathSize := GetTempPath( SizeOf(tempPathPStr), @tempPathPStr[0] );}
        { Changed to TempFilename  5/5/98  2.12 }
        tmpZipName := TempFilename(TemporaryPath);
        {tmpZipName := StrPas(tempPathPStr) + ExtractFileName( ZipName );}
      end;
      CreateTempZip;
      OpenZip; { open existing zip so we can move existing files }
      MoveExistingFiles; {Move those existing files}
    end
    else
    begin
{$IFNDEF USE_ZLIB}
      AllocateZipArrays;
{$ENDIF}
      if not ArchiveIsStream then
        tmpZipName := ZipName;
      UsingTempFile := False;
      CreateTempZip;
    end;

      {  Guesstimate space needed for the Zip Configuration File that will go on first disk of
     a spanned zip file if SaveZipInfoOnFirstDisk is True }
  if (MultiZipInfo.MultiMode <> mmNone) and (MultiZipInfo.SaveZipInfoOnFirstDisk) then
  begin
     { We'll pad a little extra because comments aren't figured in and we want to make sure
       we allow for sector's being allocated on disk }
    MultiZipInfo.SaveOnFirstDisk :=
      MultiZipInfo.SaveOnFirstDisk +
      (FilesList.Count * (SizeOf(central_file_header) + FilenameSize)) +
      SizeOf(end_of_central) + ecrec.zip_comment_length + 2048; { + 2048 for some padding }
      if (MultiZipInfo.MultiMode = mmSpan) then
      begin
        try
          clusterSize := GetClusterSize(ExtractFileDrive(ZipName)+'\');
        except
          clusterSize := 4096; // if error just default to 4096
        end;
        MultiZipInfo.SaveOnFirstDisk := MultiZipInfo.SaveOnFirstDisk + clusterSize;
      end;
  end;

  if MultiZipInfo.MultiMode = mmSpan then
    AmountToWrite := DiskRoom - MultiZipInfo.SaveOnFirstDisk
  else if MultiZipInfo.MultiMode = mmBlocks then
  begin
    if (MultiZipInfo.FirstBlockSize = 0) then
      AmountToWrite := MultiZipInfo.BlockSize - MultiZipInfo.SaveOnFirstDisk
    else
      AmountToWrite := MultiZipInfo.FirstBlockSize - MultiZipInfo.SaveOnFirstDisk;
  end;

    if MultiZipInfo.MultiMode <> mmNone then
    begin
      TotalUncompressedSize := TotalUnCompressedSize * 2;
      span_sig := SPANNED_SIG;
      zfile.Write(span_sig,SizeOf(LongInt));
    end;

  { For each file in the FilesList AddFileToZip }
    if (not Deleting) and (FilesList.Count > 0) then
    begin
      if (not StreamZipping) then
      begin
        for i := 0 to FilesList.Count - 1 do
        begin
          zipdata(i);
        end;
      end
      else
      begin
        Repeat
          zipdata(0);
          if (FFreeStream) then
            ZipStream.Free;
          ZipStream := nil;
          if (Assigned(FOnGetNextStream)) {$IFNDEF INT64STREAMS} or (Assigned(FOnGetNextTStream)) {$ENDIF} then
          begin
            FilesList.Clear;
            NextFile := '';
            {$IFNDEF INT64STREAMS}
            if (Assigned(FOnGetNextTStream)) then
            begin
              newStream := nil;
              FOnGetNextTStream(self, newStream, nextFile);
              if (newStream <> nil) then
              begin
                ZipStream := tKpHugeMemoryStream.Create;
                ZipStream.Size := newStream.Size;
                newStream.Position:=0;
                ZipStream.CopyFrom(newStream,newStream.Size);
                if (FFreeStream) then
                  newStream.Free;
              end;
            end
            else
            {$ENDIF}
            if (Assigned(FOnGetNextStream)) then
            begin
              FOnGetNextStream(self, ZipStream, nextFile);
            end;

            if (ZipStream <> nil) then
            begin
              ZipStream.Position := 0;
              FilesList.Add(nextFile);
            end;
          end;
        Until (ZipStream = nil);
      end;
    end; { If not Deleting }

    tmpecrec.offset_central := zfile.Position;
    tmpecrec.start_central_disk := CurrentDisk;
    totalCentralSize := 0;
    saveCentralPos := tmpecrec.offset_central;
    for i := 0 to tmpfiles2.Count - 1 do
    begin
      tmpfile_info := tmpfiles2.Items[i] as TZipHeaderInfo;
      if (MultiZipInfo.MultiMode <> mmNone) and (RoomLeft < tmpfile_info.CentralSize) then
      begin
        Inc(TotalCentralSize, zfile.Position - saveCentralPos);
        saveCentralPos := 0;
        NextPart;
        tmpecrec.num_entries_this_disk := 0;
        if i = 0 then
        begin
          tmpecrec.offset_central := 0;
          tmpecrec.start_central_disk := CurrentDisk;
        end;
      end;
      tmpfile_info.SaveCentralToStream(zfile, theZipFile, UsingTempFile);
      tmpecrec.num_entries_this_disk :=  tmpecrec.num_entries_this_disk + 1;
{ DONE :
Figure out how to handle the extra field length when using a temporary file
if there is a zip64 extra field that WE added. }
//      if (tmpfile_info.Cextra_field_length > 0) and (UsingTempFile) then
//      begin { Copy central directory's extra field } { 04/06/02  2.22+ }
//        theZipFile.Seek(tmpfile_info.central_offset + sizeOf(central_file_header) +
//          tmpfile_info.filename_length, soBeginning);
//        zfile.CopyFrom(theZipFile, tmpfile_info.Cextra_field_length);
//      end;
    end;
    Inc(TotalCentralSize, zfile.Position - saveCentralPos);
    tmpecrec.size_central := TotalCentralSize;
    if (MultiZipInfo.MultiMode <> mmNone) and (RoomLeft < tmpecrec.EndCentralSize) then
      NextPart;
    tmpecrec.this_disk := CurrentDisk;
    tmpecrec.SaveToStream(zfile);
    if MultiZipInfo.MultiMode = mmSpan then
      LabelDisk;
    FinishedOK := True;
  finally
{$IFNDEF USE_ZLIB}
    DeAllocateZipArrays;
{$ENDIF}
    if (not ArchiveIsStream) then
    begin
      if (MultiZipInfo.MultiMode <> mmNone) and (ecrec.num_disks = 1) then
      begin
        // Replace the spanning signature if only one spanned part
        zfile.Seek(0,soBeginning);
        span_not_sig := SPANNED_NOT_SIG;
        zfile.Write(span_not_sig, SizeOf(LongInt));
      end;
      zfile.Free; { close the temp zip file }
      zfile := nil;
    end;
    if FinishedOK then
    begin
      if (not ArchiveIsStream) and (not CreatingSFX) then
        SaveZipName := ZipName;
     { Removed (not ArchiveIsStream) because it was keeping files from getting freed }
     { 01/20/02  2.22+ }
      if (not CreatingSFX) and ({(not ArchiveIsStream) and}(UsingTempFile)) then
        ClearZip;
      if (MultiZipInfo.MultiMode = mmBlocks) then
      begin
        // Last of split parts
        temporaryZipName := FZipNameNoExtension;
        DoFileNameForSplitPart(temporaryZipName,CurrentDisk+1,spLast);
        ZipName := temporaryZipName;
        kpRenameFile(tmpZipName, ZipName);
      end
      else if (not ArchiveIsStream) and (not CreatingSFX) then
        ZipName := SaveZipName;
      if (UsingTempFile) then
        MoveTempFile
      else if ArchiveIsStream then
        zfile := nil; {2/11/98}
      if (Dispose) then
        DisposeOfFiles;

      if not CreatingSFX then
      begin { We'll point everyting to the newly created information }
        ecrec.Assign(tmpecrec);
        files := tmpfiles2;
        sortfiles := files;
        SortMode := ByNone;
      end
      else { We're going back to the same zip file }
      begin
        tmpfiles2.Free;
        tmpfiles2 := nil;
        sortfiles := SaveSortedFiles;
      end;

      if (not ArchiveIsStream) and (not CreatingSFX) then
        filesDate := FileDate(ZipName);
      if (SaveSortMode <> ByName) and (not CreatingSFX) then
        Sort(SaveSortMode)
      else if (not CreatingSFX) then
      begin
        sortfiles := tmpfiles; { already sorted by name }
        tmpfiles := nil;
      end;
      WriteNumDisks(CurrentDisk + 1);

     { Changed to call even if not spanned zip files 9/30/01 2.22+ }
     { When last file skipped OnTotalPercent wasn't being called }
      if {(MultiZipInfo.MultiMode <> mmNone) and}(Assigned(FOnTotalPercentDone)) then
        OnTotalPercentDone(self, 100); { To be sure. 5/23/99 2.18+}

      if (MultiZipInfo.MultiMode <> mmNone) and (MultiZipInfo.SaveZipInfoOnFirstDisk)
        and (ecrec.this_disk > 0) then
      begin
        if MultiZipInfo.MultiMode = mmSpan then
        begin
          AskForNewDisk(1); { Ask for 1st disk }
        end;
        SaveZipInfoToFile(kpChangeFileExt(ZipName, '.zfc'));
      end;

    end
    else
    begin
      tmpfiles2.Free;
      tmpfiles2 := nil;
      SysUtils.DeleteFile(tmpZipName);
    end;

    SortMode := SaveSortMode;
    KeepZipOpen := SaveKeepZipOpen;
    tmpfiles.Free;
    tmpfiles := nil;
    tmpecrec.Free;
    tmpecrec := nil;
    CloseZip;
    if ArchiveIsStream then
      GetFileInfo(theZipFile);
    SetBusy(OldBusy);
    FilesList.Clear; { 6/27/99 2.18+ }
    SetOperationMode(OldOperationMode);
  end;
end;

procedure TVCLZip.CreateTempZip;
begin
  if MultiZipInfo.MultiMode = mmBlocks then
  begin
    //tmpZipName := ChangeFileExt(tmpZipName, '.' + Format('%3.3d', [CurrentDisk + 1]));
    tmpZipName := FZipNameNoExtension;
    DoFileNameForSplitPart(tmpZipName,CurrentDisk+1, spFirst);
  end;
  // Call OnGetNextDisk to get first disk   { 09/13/2003  3.03+ }
  if (MultiZipInfo.MultiMode = mmSpan) then
  begin
    DoGetNextDisk(CurrentDisk+1,tmpZipName);
    if tmpZipName = '' then
      raise EUserCanceled.Create(LoadStr(IDS_CANCELZIPOPERATION));
    if kpFileExists(tmpZipName) then
      kpDeleteFile(tmpZipName); { 10/19/99  2.20b3+ }
    if Assigned(FOnPrepareNextDisk) then
      FOnPrepareNextDisk(self, CurrentDisk + 1);
  end;
  if not ArchiveIsStream then
    zfile := TLFNFileStream.CreateFile(tmpZipName, fmCreate, FFlushFilesOnClose, BufferedStreamSize)
  else
  begin
    if UsingTempFile then
      zfile := TkpMemoryStream.Create
    else
      zfile := theZipFile; {2/11/98}
  end;
  if CreatingSFX then
    zfile.CopyFrom(SFXStubFile, SFXStubFile.Size);
  tmpfiles := TSortedZip.Create(DupError);
  tmpfiles.SortMode := ByName;
  tmpfiles.DestroyObjects := False;
  tmpfiles2 := TSortedZip.Create(DupError);
  tmpfiles2.SortMode := ByNone;
  tmpfiles.Capacity := FilesList.Count + Count;
  tmpfiles2.Capacity := FilesList.Count + Count;
  tmpecrec := TEndCentral.Create;
  if (UsingTempFile) or (ecrec.Modified) then
  begin
    tmpecrec.Assign(ecrec);
    if (tmpecrec.zip_comment_length > 0) and (Length(tmpecrec.ZipComment) = 0) then
      tmpecrec.ZipComment := ZipComment;
    tmpecrec.num_entries := 0;
    tmpecrec.num_entries_this_disk := 0;
    tmpecrec.Modified := False;
  end;
end;

function TVCLZip.DiskRoom: BIGINT;
var
  Disk: Byte;
begin
  if ZipName[2] <> ':' then
    Disk := 0
  else
  begin
    Disk := Ord(ZipName[1]) - 64;
    if Disk > 32 then
      Dec(Disk, 32);
  end;
  Result := DiskFree(Disk);
end;

function TVCLZip.RoomLeft: BIGINT;
begin
  Result := AmountToWrite - zfile.Size;
end;

procedure TVCLZip.LabelDisk;
var
  Disk: String;
  NewLabel: String;
  {Rslt: LongBool;}
begin
  if (MultiZipInfo.MultiMode = mmSpan) and (MultiZipInfo.WriteDiskLabels) then
  begin
    Disk := ExtractFileDrive(ZipName);
    if (isDriveRemovable(Disk)) then
    begin
      NewLabel := 'PKBACK# ' + Format('%3.3d', [CurrentDisk + 1]);
      SetVolLabel(Disk, NewLabel);
    end;
  end;
end;

procedure TVCLZip.NextPart;
var
  saveTmpName: kpWString;
begin
  if MultiZipInfo.MultiMode <> mmNone then
  begin
    if MultiZipInfo.MultiMode = mmSpan then
    begin
        zfile.Free;
        zfile := nil;
        LabelDisk; { Label disk before they change it }
        DoGetNextDisk(CurrentDisk + 2, tmpZipName);
        if tmpZipName = '' then
          raise EUserCanceled.Create(LoadStr(IDS_CANCELZIPOPERATION));
        Inc(CurrentDisk);
        if FileExists(tmpZipName) then
          SysUtils.DeleteFile(tmpZipName); { 10/19/99  2.20b3+ }
        if Assigned(FOnPrepareNextDisk) then
          FOnPrepareNextDisk(self, CurrentDisk + 1);
        AmountToWrite := DiskRoom;
    end
    else
    begin
      zfile.Free;
      zfile := nil;
      saveTmpName := tmpZipName;
      tmpZipName := FZipNameNoExtension;
      DoFileNameForSplitPart(tmpZipName,CurrentDisk+2, spMiddle);
      Inc(CurrentDisk);
      AmountToWrite := MultiZipInfo.BlockSize;
    end;
    zfile := TLFNFileStream.CreateFile(tmpZipName, fmCreate, FFlushFilesOnClose, BufferedStreamSize);
    AmountWritten := 0;
    tmpecrec.num_entries_this_disk := 0;
  end;
end;

function TVCLZip.AddFileToZip(FName: kpWString): Boolean;
var
  SavePos: BIGINT;
  tmpDir: kpWString;
  Idx: Integer;
  Skip: Boolean;
  {tempPathPStr: array [0..PATH_LEN] of char;}
  {PathSize: LongInt;}

  procedure CalcFileCRC;
  { Modified to use a PChar for cbuffer 4/12/98  2.11 }
  const
      {BLKSIZ = OUTBUFSIZ;}
    BLKSIZ = DEF_BUFSTREAMSIZE;
  var
    cbuffer: PAnsiChar;
    AmountRead: BIGINT;
    AmtLeft: BIGINT;
  begin
    AmtLeft := 0;
    cbuffer := nil;

    if (not MemZipping) then
      GetMem(cbuffer, BLKSIZ);
    try
      Crc32Val := $FFFFFFFF;
      if (MemZipping) then
      begin
        cbuffer := MemBuffer;
        AmountRead := kpmin(MemLen, BLKSIZ);
        AmtLeft := MemLen - AmountRead;
      end
      else
        AmountRead := IFile.Read(cbuffer^, BLKSIZ);
      while AmountRead <> 0 do
      begin
        Update_CRC_buff(BytePtr(cbuffer), AmountRead);
        if (MemZipping) then
        begin
          Inc(cbuffer, AmountRead);
          AmountRead := kpmin(AmtLeft, BLKSIZ);
              { Inc(cbuffer, AmountRead); }{ Moved up 2 lines 5/15/00 2.20++ }
          Dec(AmtLeft, AmountRead);
        end
        else
          AmountRead := IFile.Read(cbuffer^, BLKSIZ);
      end;
      if (not MemZipping) then
        IFile.Seek(0, soBeginning);
    finally
      if (not MemZipping) then
        FreeMem(cbuffer, BLKSIZ);
    end;
  end;

  procedure SaveMFile;
  var
    AmtToCopy: BIGINT;
    TotalAmtToCopy: BIGINT;
    progressAmt: BIGINT;
    progressDone: BIGINT;
    progressPartition: BIGINT;
    Percent: LongInt;
  const
    SPAN_BUFFER_SIZE = $4000;
  begin
    if (Assigned(FOnStartSpanCopy)) then
      FOnStartSpanCopy(self, tmpfile_info.filename, mfile.Size);
    progressDone := 0;
    progressAmt := 0;
    if RoomLeft <= 0 then { changed to <= 05/23/00  2.21PR2+ }
      NextPart;
    if Assigned(FOnFilePercentDone) then
    begin
      progressAmt := tmpfile_info.uncompressed_size + mfile.Size;
      progressDone := tmpfile_info.uncompressed_size;
    end;
    if Assigned(FOnTotalPercentDone) then {Need to adjust for the diff since guessed}
      TotalUnCompressedSize := TotalUnCompressedSize - (tmpfile_info.uncompressed_size - mfile.Size);
    mfile.Seek(0, soBeginning);
    TotalAmtToCopy := mfile.Size;
    AmtToCopy := kpmin(RoomLeft, TotalAmtToCopy);
    if (mfile.Size = 0) then
      AmtToCopy := 0;
    while (TotalAmtToCopy > 0) and (AmtToCopy > 0) do
    begin
      Dec(TotalAmtToCopy, AmtToCopy);
      if Assigned(FOnFilePercentDone) or Assigned(FOnTotalPercentDone) then
      begin
        while (AmtToCopy > 0) do
        begin
          progressPartition := kpmin(SPAN_BUFFER_SIZE, AmtToCopy);
          zfile.CopyFrom(mfile, progressPartition);
          Inc(progressDone, progressPartition);
          if Assigned(FOnFilePercentDone) then
          begin
            Percent := CBigRate(progressAmt, progressDone);
            OnFilePercentDone(self, Percent);
          end;
          if Assigned(FOnTotalPercentDone) then
          begin
            TotalBytesDone := TotalBytesDone + progressPartition;
            Percent := CBigRate(TotalUncompressedSize, TotalBytesDone);
            OnTotalPercentDone(self, Percent);
          end;
          Dec(AmtToCopy, progressPartition);
        end;
      end
      else
        zfile.CopyFrom(mfile, AmtToCopy);
      if (TotalAmtToCopy > 0) or (RoomLeft <= 0) then
        NextPart;
      AmtToCopy := kpmin(RoomLeft, TotalAmtToCopy);
    end;
  end;

  procedure StoreFile( var totalRead: BIGINT );
  const
    BLKSIZ = OUTBUFSIZ;
  var
    storeBuf: BytePtr;
    bytesRead: BIGINT;
  begin
    totalRead := 0;
    GetMem(storeBuf, BLKSIZ);
    try
      bytesRead := file_read(storeBuf, BLKSIZ);
      Inc(totalRead, bytesRead);
      while bytesRead > 0 do
      begin
        zfwrite(storeBuf, 1, bytesRead);
        bytesRead := file_read(storeBuf, BLKSIZ);
        Inc(totalRead,bytesRead);
      end;
    finally
      FreeMem(storeBuf, BLKSIZ);
    end;
  end;

var
  tmpRootDir: kpWString;
  DrivePart: string;
  IsDir: Boolean;
  tmpDirName: kpWString;
  SearchRec: TSearchRec;
  Retry: Boolean;
  tmpUncompressedSize: BIGINT;

begin { ************* AddFileToZip Procedure ***************** }
  Result := False;
  FileBytes := 0;
  IFileName := FName;
  tmpRootDir := RootDir; { 5/3/98 2.12 }
  if FName[Length(FName)] = '\' then
    IsDir := True
  else
    IsDir := False;

  if IsDir then
  begin
    if (StreamZipping) or (MemZipping) or (not DirExists(FName)) then
      tmpfile_info.last_mod_file_date_time := DateTimeToFileDate(Now)
    else
    begin
      tmpDirName := Copy(FName, 1, Length(FName) - 1);
      if FindFirst(tmpDirName, FSearchAttribute, SearchRec) = 0 then
      begin
        tmpfile_info.last_mod_file_date_time := SearchRec.Time;
        FindClose(SearchRec); { 09/14/01  2.22+ }
      end
      else
        tmpfile_info.last_mod_file_date_time := DateTimeToFileDate(Now);
    end;
    tmpfile_info.uncompressed_size := 0;
    tmpfile_info.compressed_size := 0;
    tmpfile_info.compression_method := STORED;
    tmpfile_info.internal_file_attributes := BINARY; { assume binary if STOREing - for now. 10/18/98 }
    tmpfile_info.crc32 := 0;
    if DirExists(FName) then
      tmpfile_info.external_file_attributes := kpFileGetAttributes(FName);
  end
  else if (not StreamZipping) and (not MemZipping) and (not IsDir) then
  begin
    if not kpFileExists(FName) then
    begin
      if (Assigned(FOnNoSuchFile)) then
        FOnNoSuchFile(Self, FName);
      exit;
    end;
    tmpfile_info.external_file_attributes := kpFileGetAttributes(FName);
    Retry := False;
    repeat
      try
        {IFile := TLFNFileStream.CreateFile( FName, fmOpenRead or fmShareDenyNone, False );}
        IFile := TLFNFileStream.CreateFile(FName, fmOpenRead or FFileOpenMode, False, BufferedStreamSize);
        Retry := False;
      except
        Retry := False;
        if Assigned(FOnSkippingFile) then
          FOnSkippingFile(self, srFileOpenError, FName, -1, Retry);
        if not Retry then
          exit;
      end;
    until (Retry = False);
    tmpfile_info.last_mod_file_date_time := FileGetDate(TLFNFileStream(IFile).Handle);
  end
  else
  begin
    if (StreamZipping) then
      IFile := ZipStream;
    tmpfile_info.last_mod_file_date_time := DateTimeToFileDate(Now);
  end;
  mfile := nil;
  try
    if (MemZipping) and (not IsDir) then
      tmpfile_info.uncompressed_size := MemLen
    else if (not IsDir) then
      tmpfile_info.uncompressed_size := IFile.Size;
 { TODO : 
If FStore83Names must convert RelativePathList.  Should not be done
here of course. }
    if FStore83Names then
    begin
      FName := LFN_ConvertLFName(FName, SHORTEN);
      if tmpRootDir <> '' then
        tmpRootDir := LFN_ConvertLFName(RootDir, SHORTEN);
    end;
    {$IFNDEF SUPPORT_UNICODE}
    if (OEMConvert = oemAlways) then
      OEMFilter(FName);
    {$ENDIF}
    if (not IsDir) then
      tmpfile_info.filename := kpExtractFileName(FName)
    else
      tmpfile_info.filename := '';

    tmpfile_info.relative_offset := zfile.Position;

    tmpfile_info.internal_file_attributes := BINARY;
    tmpfile_info.disk_number_start := CurrentDisk;
    if FStorePaths then
    begin
      tmpDir := kpExtractFileDir(Fname) + '\';
      if RightStr(tmpDir, 2) = '\\' then {Incase it's the root directory 3/10/98 2.03}
        SetLength(tmpDir, Length(tmpDir) - 1);
      if (FRelativePathList.Count > 0) and (RelativePaths) then
        StripRelativePath(tmpDir);
//      if (tmpRootDir <> '') and (RelativePaths) and (AnsiCompareText(LeftStr(tmpDir, Length(tmpRootDir)), tmpRootDir) = 0) then
//      begin
//        if (AnsiCompareText(tmpRootDir, tmpDir) = 0) then
//          tmpDir := ''
//        else
//          Delete(tmpDir, 1, Length(tmpRootDir));
//      end;
     { added the following 3/26/98 to handle UNC paths. 2.1 }
      if {(not RelativePaths) and}(not FStoreVolumes) and (tmpDir <> '') then
      begin
        DrivePart := ExtractFileDrive(tmpdir);
        if DrivePart <> '' then
          Delete(tmpdir, 1, Length(DrivePart));
        if LeftStr(tmpdir, 1) = '\' then
          Delete(tmpdir, 1, 1);
      end;
      tmpfile_info.directory := tmpDir;
     {The filename_length now gets set automatically when setting the directory
      or filename  Nov 16, 1997 KLB }
  {tmpfile_info.filename_length := Length(tmpfile_info.directory+tmpfile_info.filename);}
    end;
   {The filename_length now gets set automatically when setting the directory
    or filename  Nov 16, 1997 KLB }
 {Else
  tmpfile_info.filename_length := Length(tmpfile_info.filename);}

  { If a file by the same name is already archived then skip this one }
    if tmpfiles.Search(Pointer(tmpfile_info), Idx) then
    begin
      Result := False;
     { This is sort of a cludge but it works for now }
      if Assigned(FOnSkippingFile) then
      begin
        FOnSkippingFile(self, srNoOverwrite, FName, -1, Retry);
      end;
      if (not StreamZipping) and (not MemZipping) and (not IsDir) then
      begin
        TotalUncompressedSize := TotalUncompressedSize - IFile.Size;
        IFile.Free;
        IFile := nil;
      end;
      exit;
    end;

    Skip := False;
    if Assigned(FOnStartZip) then
      FOnStartZip(Self, FName, tmpfile_info, Skip);
    if Skip then
    begin
      if (not StreamZipping) and (not MemZipping) and (not IsDir) then
      begin
        TotalUncompressedSize := TotalUncompressedSize - IFile.Size;
        IFile.Free;
        IFile := nil;
      end;
      if (Assigned(FOnSkippingFile)) then
        FOnSkippingFile(self, srSkippedInStartZip, FName, -1, Retry);
      Result := False;
      exit;
    end;

  if (password <> '') and (not IsDir) then
  begin
    tmpfile_info.general_purpose_bit_flag := tmpfile_info.general_purpose_bit_flag or 1;
    tmpfile_info.EncryptionStrength := FEncryptStrength;
  end;

  {Save local header for now, will update when done}
    if (MultiZipInfo.MultiMode <> mmNone) and (RoomLeft <= tmpfile_info.LocalSize) { and (not IsDir) } then
    begin { 2/1/98 Changed the above from < to <= }
      NextPart;
      tmpfile_info.disk_number_start := CurrentDisk; { 2/1/98 }
      tmpfile_info.relative_offset := 0; { Added 05/23/00 2.21PR2+ }
    end;
    if (MultiZipInfo.MultiMode <> mmNone) and (not IsDir) then
    begin
     {PathSize := GetTempPath( SizeOf(tempPathPStr), @tempPathPStr[0] );}
     { Changed to TempFilename  5/5/98  2.12 }
      mZipName := TempFilename(TemporaryPath);
     {mZipName := StrPas(tempPathPStr) + 'KPy76p09.tmp';}
      mfile := TLFNFileStream.CreateFile(mZipName, fmCreate, FFlushFilesOnClose, BufferedStreamSize);
    end
    else { Added this else 2/5/00 2.20+ }
      tmpfile_info.SaveLocalToStream(zfile);
  {SavePos := zfile.Position;}
    if (IsDir) then
    begin
      if Assigned(FOnEndZip) then
        FOnEndZip(Self, FName, 0, 0, 0);
      Result := True;
      exit;
    end;

    SavePos := zfile.Position;

    if (Password <> '') and (not IsDir) then  // AES Work
    begin
      CalcFileCRC;
      Crc32Val := not Crc32Val;
      tmpfile_info.crc32 := Crc32Val;
      SavePos := zfile.Position;
      crypthead(Password);
    end;
    Crc32Val := $FFFFFFFF;
{$IFDEF KPDEMO}
    if not DR then
      tmpfile_info.filename := '';
{$ENDIF}

  {*************** HERE IS THE CALL TO ZIP ************************}
    if (PackLevel = 0) or (IsInNoCompressList(tmpfile_info.filename)) then { 10/23/98  2.16+ }
    begin
      StoreFile(tmpUncompressedSize);
      tmpfile_info.compressed_size := tmpfile_info.uncompressed_size;
      if (not MemZipping) then
      begin
        if (tmpUncompressedSize < tmpfile_info.uncompressed_size) then
          DoHandleMessage(IDS_BAD_UNCOMPRESSED_SIZE,LoadStr(IDS_BAD_UNCOMPRESSED_SIZE),FName,mb_OK);
        tmpfile_info.uncompressed_size := tmpUncompressedSize;
      end;
      tmpfile_info.compression_method := STORED;
      tmpfile_info.internal_file_attributes := BINARY; { assume binary if STOREing - for now. 10/18/98 }
    end
    else
    begin
      //SavePos := zfile.Position;
      tmpfile_info.compressed_size := kpDeflate(tmpUncompressedSize); { Compress the file!! }
      // Set uncompressed_size here since file could have been in the process of being created
      // or flushed during zipping.
      if (not MemZipping) then
      begin
        if (tmpUncompressedSize < tmpfile_info.uncompressed_size) then
          DoHandleMessage(IDS_BAD_UNCOMPRESSED_SIZE,LoadStr(IDS_BAD_UNCOMPRESSED_SIZE),FName,mb_OK);
        tmpfile_info.uncompressed_size := tmpUncompressedSize;
      end;
    end;
  {****************************************************************}
      if (Password <> '') and (EncryptStrength <> esPKStandard) then
      begin
        if (MultizipInfo.MultiMode = mmNone) then
          WriteAESAuthentication(zfile)
        else
          WriteAESAuthentication(mfile)
      end;
      if (MultizipInfo.MultiMode = mmNone) then
        tmpfile_info.compressed_size := zfile.Position - SavePos
       else
        tmpfile_info.compressed_size := mfile.Size;

{  Assert(  tmpfile_info.compressed_size = zfile.Seek(0, soCurrent) - SavePos, }
{           'Deflate returned wrong compressed size.');         }
    Crc32Val := not Crc32Val;
    tmpfile_info.crc32 := Crc32Val;

{ TODO : Write Data Descriptor if needed }
//    wroteDataDescriptor := tmpfile_info.WriteDataDescriptor(zfile);

    if (PackLevel <= 2) then
         tmpfile_info.general_purpose_bit_flag := tmpfile_info.general_purpose_bit_flag
            or
            FAST
    else
      if (PackLevel >= 8) then
            tmpfile_info.general_purpose_bit_flag := tmpfile_info.general_purpose_bit_flag
               or
               SLOW;
    if Password <> '' then
    begin { Mark the file as encrypted and modify compressed size
            to take into account the 12 byte encryption header    }
      tmpfile_info.general_purpose_bit_flag := tmpfile_info.general_purpose_bit_flag or 1;
      if (MultizipInfo.MultiMode = mmNone) or (PackLevel = 0) then
      begin
//        if (tmpfile_info.EncryptionStrength = esPKStandard) then
//          tmpfile_info.compressed_size := tmpfile_info.compressed_size + 12
//        else
//         begin
//          //tmpfile_info.compressed_size := tmpfile_info.compressed_size +
//          //                  SALT_LENGTH(Ord(file_info.EncryptionStrength))+PWD_VER_LENGTH + 10;
//         end;
      end;
    end;
  { Save the finalized local header }
    SavePos := zfile.Position;
    zfile.Seek(tmpfile_info.relative_offset, soBeginning);
    tmpfile_info.SaveLocalToStream(zfile);
    if MultiZipInfo.MultiMode <> mmNone then
      SaveMFile
    else
      zfile.Seek(SavePos, soBeginning);
    Result := True;
  finally
    mfile.Free;
    mfile := nil;
    SysUtils.DeleteFile(mZipName);
    if (not StreamZipping) and (not MemZipping) then
    begin
      IFile.Free;
      IFile := nil;
    end;
  end;

 { Added 4-Jun-98 by SPF to support reset of archive bit after the file
      has been zipped }
  if FResetArchiveBitOnZip and (not StreamZipping) and (not MemZipping) then
    ResetArchiveBit(FName);

  if Assigned(FOnEndZip) then
    FOnEndZip(Self, FName, tmpfile_info.uncompressed_size,
      tmpfile_info.compressed_size, zfile.Size);

end;

// AES Work

procedure TVCLZip.CryptHead(passwrd: AnsiString);
begin
  if (FEncryptStrength = esPKStandard) then
    CryptPKHead(passwrd)
  else
    CryptAESHead(passwrd);
end;

procedure TVCLZip.CryptAESHead(passwrd: AnsiString);
var
  SaltLen: LongWord;
  mode: Integer;
  salt: array[0..15] of byte;
  pwd_verifier: array [0..15] of byte; //PWD_VER_TYPE;
begin
  ZeroMemory(@rng[0],sizeof(rng));
  ZeroMemory(@salt[0],sizeof(salt));
  ZeroMemory(@zcx[0],sizeof(zcx));
  ZeroMemory(@pwd_verifier[0],sizeof(pwd_verifier));
  mode := Ord(EncryptStrength);
  _prng_init(_entropy_fun, @rng[0]);
  SaltLen := SALT_LENGTH(mode);
  _prng_rand(@salt[0],SaltLen,@rng[0]);

  if MultiZipInfo.MultiMode = mmNone then
    zfile.Write(salt,sizeof(byte)*saltlen)
  else
    mfile.Write(salt,sizeof(byte)*saltlen);

  _fcrypt_init(mode,PAnsiChar(passwrd),length(passwrd),@salt[0],@pwd_verifier[0],@zcx[0]);
  if MultiZipInfo.MultiMode = mmNone then
    zfile.Write(pwd_verifier,PWD_VER_LENGTH)
  else
    mfile.Write(pwd_verifier,PWD_VER_LENGTH);

end;

procedure TVCLZip.CryptPKHead(passwrd: AnsiString);
var
  i: Integer;
  c: Byte;
begin
  Init_Keys(passwrd);
  Randomize;
  for i := 1 to 10 do
  begin
    c := zencode(Byte(random($7FFF) shr 7));
    if MultiZipInfo.MultiMode = mmNone then
      zfile.Write(c, 1)
    else
      mfile.Write(c, 1);
  end;
  c := zencode(LOBYTE(HIWORD(tmpfile_info.crc32)));
  if MultiZipInfo.MultiMode = mmNone then
    zfile.Write(c, 1)
  else
    mfile.Write(c, 1);
  c := zencode(HIBYTE(HIWORD(tmpfile_info.crc32)));
  if MultiZipInfo.MultiMode = mmNone then
    zfile.Write(c, 1)
  else
    mfile.Write(c, 1);
end;

procedure TVCLZip.WriteAESAuthentication(stream: TkpStream);
begin
  ZeroMemory(@aes_authentication[0], sizeof(aes_authentication));
  _fcrypt_end(@aes_authentication[0], @zcx[0]);
  stream.Write(aes_authentication,MAC_LENGTH);
  _prng_end(@rng[0]);
end;

procedure TVCLZip.MoveFile(Index: Integer);

  procedure BlockStreamCopy(Source: TkpStream; Dest: TkpStream; Length: BIGINT);
  var
    BlockSize: BIGINT;
    AmtToCopy: BIGINT;
    Percent: LongInt;
  const
    SPAN_BUFFER_SIZE = $4000;
  begin
    AmtToCopy := Length;
    while (AmtToCopy > 0) do
    begin
      BlockSize := kpmin(SPAN_BUFFER_SIZE, AmtToCopy);
      Dest.CopyFrom(Source, BlockSize);
      if (Assigned(OnFilePercentDone)) then
      begin
        Percent := CBigRate(Length, Length - AmtToCopy);
        FOnFilePercentDone(self, Percent);
      end;
      if Assigned(FOnTotalPercentDone) then
      begin
        TotalBytesDone := TotalBytesDone + BlockSize;
        Percent := CBigRate(TotalUncompressedSize, TotalBytesDone);
        OnTotalPercentDone(self, Percent);
      end;
      if (DoProcessMessages) then
        YieldProcess;
      Dec(AmtToCopy, BlockSize);
    end;
  end;

var
  lrc: local_file_header;
begin
  theZipFile.Seek(tmpfile_info.relative_offset, soBeginning);
  { Filename length may have changed from original so we have to get }
  { it from the original local file header - 10/29/97 KLB }
  theZipFile.Read(lrc, SizeOf(local_file_header));
  theZipFile.Seek(lrc.filename_length, soCurrent);
  tmpfile_info.Lextra_field_length := lrc.extra_field_length; { 11/04/99 2.20b4+ }
  tmpfile_info.relative_offset := zfile.Position;
  { TODO : Mod to save data descriptor }
  // Extended headers won't be needed or saved, so clear the flag that says there is one...
  tmpfile_info.general_purpose_bit_flag := tmpfile_info.general_purpose_bit_flag and (not 8);
  tmpfile_info.SaveLocalToStream(zfile);
  {Added following test for zero length because it was doubling archive size - 01/21/97 KLB}
  if (tmpfile_info.compressed_size + tmpfile_info.Lextra_field_length) > 0 then
    BlockStreamCopy(theZipFile, zfile, tmpfile_info.compressed_size + tmpfile_info.Lextra_field_length);
    //zfile.CopyFrom(theZipFile, tmpfile_info.compressed_size + tmpfile_info.Lextra_field_length);
end;

procedure TVCLZip.MoveTempFile;
begin
  if ArchiveIsStream then
  begin
    theZipFile.Free;
    theZipFile := zfile;
    zfile := nil;
  end
  else
  begin
    if SaveNewName = '' then
    begin
      SysUtils.DeleteFile(ZipName);
      FileCopy(tmpZipName, ZipName);
    end
    else
      FileCopy(tmpZipName, SaveNewName);
    SysUtils.DeleteFile(tmpZipName);
  end;
end;

function TVCLZip.DeleteEntries: Integer;
begin
  if NumSelected > 0 then
    FilesList.Clear;
  Deleting := True;
  Result := ProcessFiles;
  Deleting := False;
end;

procedure TVCLZip.SetZipName(ZName: kpWString);
begin
  if not (csDesigning in ComponentState) then
  begin
    if kpCompareText(ZName, ZipName) = 0 then
      exit;
  end;
  inherited SetZipName(ZName);
end;

procedure TVCLZip.SetDateTime(Index: Integer; DT: TDateTime);
var
  finfo: TZipHeaderInfo;
begin
  if (Index > -1) and (Index < Count) then
  begin
    finfo := sortfiles.Items[Index] as TZipHeaderInfo;
    finfo.SetDateTime(DT);
    ecrec.Modified := True;
  end
  else
    raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

procedure TVCLZip.SaveModifiedZipFile;
begin
  if ecrec.Modified then
  begin
    FilesList.Clear;
    ProcessFiles;
    ecrec.Modified := False;
    ReadZip;
  end;
end;

function TVCLZip.GetIsModified: Boolean;
begin
  Result := ecrec.Modified;
end;

function TVCLZip.FixZip(InputFile, OutputFile: kpWString): Integer;
var
  Canceled: Boolean;
  tmpFilesList: TStrings;
  i: Integer;
{$IFNDEF WIN32}
  j: Boolean;
{$ENDIF}
begin
  Canceled := False;
  Result := 0;
  if InputFile <> '' then
    ZipName := InputFile
  else
    if (Count = 0) or (not ZipIsBad) then
    begin
      try
        ZipName := kpExtractFileDir(ZipName) + '\?';
      except
        on EUserCanceled do
          exit;
      else
        raise; { If not EUserCanceled then re-raise the exception }
      end;
      Fixing := True;
      try
        ReadZip;
        for i := 0 to Count - 1 do
          FileIsOK[i];
      finally
      end;
      Fixing := False;
    end;
  SaveNewName := OutputFile;
{$IFNDEF KPSMALL}
  if OutputFile <> '' then
    SaveNewName := OutputFile
  else
  begin
{ TODO : Need to fix this method for Unicode }  
    OpenZipDlg := TOpenDialog.Create(Application);
    try
      OpenZipDlg.Title := LoadStr(IDS_NEWFIXEDNAME);
      OpenZipDlg.Filter := LoadStr(IDS_ZIPFILESFILTER);
      if kpDirectoryExists(kpExtractFilePath(ZipName)) then
        OpenZipDlg.InitialDir := kpExtractFilePath(ZipName)
      else
        OpenZipDlg.InitialDir := 'C:\';
      if OpenZipDlg.Execute then
        SaveNewName := OpenZipDlg.Filename
      else
        Canceled := True;
    finally
      OpenZipDlg.Free;
    end;
  end;
{$ENDIF}
  if not Canceled then
  begin
    tmpFilesList := TStringList.Create;
    tmpFilesList.Assign(FilesList);
    FilesList.Clear;
    try
      Result := ProcessFiles;
    finally
      FilesList.Assign(tmpFilesList);
      tmpFilesList.Free;
    end;
    ZipName := SaveNewName;
  end;
  SaveNewName := '';
end;

function TVCLZip.MakeNewSFX(SFXStub: kpWString; FName: kpWString; Options: PAnsiChar; OptionsLen: Integer): Integer;
{ Assumed that FilesList will have files to be included in the newly created SFX }
var
  SFXFile: TLFNFileStream;
begin
  result := 0;
  if (FName = '') or (SFXStub = '') then
    exit;
  if kpFileExists(FName) and (kpCompareText(kpExtractFileExt(FName), '.zip') = 0) then
    SaveNewName := kpChangeFileExt(FName, '.exe');
  ZipName := FName;
  if (OptionsLen > 0) then
  begin
    SFXFile := TLFNFileStream.CreateFile(SFXStub, fmOpenRead, False, BufferedStreamSize); { Get the Stub }
    SFXStubFile := TLFNFileStream.CreateFile(TemporaryPath + 'tmpstub.exe', fmCreate, FFlushFilesOnClose,
      BufferedStreamSize);
    SFXStubFile.CopyFrom(SFXFile, SFXFile.Size);
    SFXStubFile.Write(Options^, OptionsLen);
    SFXFile.Free;
    SFXStubFile.Seek(0, soBeginning);
  end
  else
    SFXStubFile := TLFNFileStream.CreateFile(SFXStub, fmOpenRead, False, BufferedStreamSize);

  try
    CreatingSFX := True;
    Result := Zip;
    if (kpCompareText(kpExtractFilename(FName), '.zip') = 0) then
      kpChangeFileExt(FName, '.exe');
  finally
    CreatingSFX := False;
    SFXStubFile.Free;
    SFXStubFile := nil;
    SaveNewName := '';
    if (OptionsLen > 0) or (Options = nil) then
      SysUtils.DeleteFile(TemporaryPath + 'tmpstub.exe');
  end;
end;

procedure TVCLZip.MakeSFX(SFXStub: kpWString; ModHeaders: Boolean);
begin
  if ZipName = '' then
    exit;
  SFXStubFile := TLFNFileStream.CreateFile(SFXStub, fmOpenRead, False, BufferedStreamSize);
  try
    CreatingSFX := True;
    SaveNewName := kpChangeFileExt(ZipName, '.EXE');
    ProcessFiles;
  finally
    CreatingSFX := False;
    SaveNewName := '';
    SFXStubFile.Free;
    SFXStubFile := nil;
  end;
end;

procedure TVCLZip.SFXToZip(DeleteSFX: Boolean);
var
  SaveZipName: kpWString;
begin
  PreserveStubs := False;
  SaveZipName := ZipName;
  SaveNewName := kpChangeFileExt(ZipName, '.zip');
  FilesList.Clear;
  ProcessFiles;
  ClearZip;
  ZipName := SaveNewName;
  SaveNewName := '';
  ReadZip;
  if DeleteSFX then
    DeleteFile(SaveZipName);
  PreserveStubs := True;
end;

procedure TVCLZip.SaveZipInfoToFile(Filename: kpWString);
var
  saveFile: TkpFileStream;
  i: Integer;
begin
  try
    saveFile := TkpFileStream.Create(Filename, fmCreate);
  except
     raise EConfigFileSaveError.Create('Unable to save Zip Configuration File to disk');
  end;

  try
    try
      for i := 0 to files.Count - 1 do
      begin
        tmpfile_info := tmpfiles2.Items[i] as TZipHeaderInfo;
        tmpfile_info.SaveCentralToStream(saveFile, nil, false);
      end;
      ecrec.SaveToStream(saveFile);
    except
      raise EConfigFileSaveError.Create('Unable to save Zip Configuration File to disk');
    end;
  finally
    saveFile.Free;
  end;
end;


{***********************************************************************
 * If requested, encrypt the data in buf, and in any case call fwrite()
 * with the arguments to zfwrite().  Return what fwrite() returns.
 *}

function TVCLZip.zfwrite(buf: BytePtr; item_size, nb: Integer): LongInt;
{    voidp *buf;               /* data buffer */
    extent item_size;         /* size of each item in bytes */
    extent nb;                /* number of items */
    FILE *f;                  /* file to write to */  }
var
  {size:   LongInt;}
  {p:      BytePtr;}
  tAmountToWrite: LongInt;
begin
  Result := 0;
  if (Password <> '') then { key is the global password pointer }
    if (Assigned(FOnEncrypt)) then
    begin
      if (not EncryptBeforeCompress) then
        FOnEncrypt(self, buf, item_size * nb, Password);
    end
    else
    begin
      if (not EncryptBeforeCompress) then
        encrypt_buff(buf, item_size * nb);
    end;

    { Write the buffer out }
  tAmountToWrite := item_size * nb;
  if MultiZipInfo.MultiMode = mmNone then
    Inc(Result, zfile.Write(buf^, tAmountToWrite)) {return fwrite(buf, item_size, nb, f);}
  else
    Inc(Result, mfile.Write(buf^, tAmountToWrite));
  if (Result <> tAmountToWrite) then
    raise ENotEnoughRoom.Create(LoadStr(IDS_NOTENOUGHROOM));
  Inc(AmountWritten, Result);
  if DoProcessMessages then
  begin
    YieldProcess;
    if CancelOperation then
    begin
      CancelOperation := False;
      raise EUserCanceled.Create(LoadStr(IDS_CANCELOPERATION));
    end;
    if PauseOperation then
      DoPause;
  end;
end;

procedure TVCLZip.encrypt_buff(buff: BytePtr; length: LongInt);
var
  p: BytePtr;
  i: LongInt;
begin
  if (EncryptStrength = esPKStandard) then
    begin
      p := buff; { steps through buffer }
      { Encrypt data in buffer }
      for i := 1 to length do
      begin
        p^ := zencode(p^);
        Inc(p);
      end;
    end
  else
    begin // AES Encryption
      _fcrypt_encrypt(buff, length, @zcx[0]);
    end;
end;

function TVCLZip.zencode(c: Byte): Byte;
var
  temp: Byte;
begin
  temp := decrypt_byte;
  update_keys(AnsiChar(c));
  Result := temp xor c;
end;

function TVCLZip.file_read(w: BytePtr; size: Integer): LongInt;
var
  Percent: LongInt;
begin
  if (MemZipping) then { 7/13/98  2.14 }
  begin
    Result := kpmin(MemLeft, size);
    if (Result > 0) then
    begin
      MoveMemory(w, CurrMem, Result);
      Inc(CurrMem, Result);
      Dec(MemLeft, Result);
    end;
  end
  else
    Result := IFile.Read(w^, size);
  if Result = 0 then
  begin
 {    If isize <> tmpfile_info.uncompressed_size then
        ShowMessage('isize <> amtread - ' + IFileName);  }
    exit;
  end;
  if Assigned(FOnFilePercentDone) then
  begin
    Inc(FileBytes, Result);
    Percent := CBigRate(tmpfile_info.uncompressed_size, FileBytes);
    if MultiZipInfo.MultiMode <> mmNone then
      Percent := Percent div 2; {only half the work done, still have to copy to diskette}
    OnFilePercentDone(self, Percent);
  end;
  if Assigned(FOnTotalPercentDone) then
  begin
    TotalBytesDone := TotalBytesDone + Result;
    Percent := CBigRate(TotalUncompressedSize, TotalBytesDone);
    OnTotalPercentDone(self, Percent);
  end;
  Update_CRC_buff(w, Result);
  if (Password <> '') and (Assigned(FOnEncrypt)) and (EncryptBeforeCompress) then
    FOnEncrypt(self, w, Result, Password)
  else if (Password <> '') and (EncryptBeforeCompress) then
    encrypt_buff(w, Result);
  Inc(isize, Result);
end;

{ Added 5/5/98 2.12 }

function TVCLZip.TemporaryPath: kpWString;
var
  tempPathPStr: array[0..300] of char; {Changed to 300 from PATH_LEN  4/15/99  2.17+}
  {PathSize: LongInt;}
begin
  if (FTempPath = '') or (not DirExists(FTempPath)) then
  begin
     {PathSize :=} GetTempPath(Length(tempPathPStr), @tempPathPStr[0]);
    Result := kpWString(tempPathPStr);
  end
  else
    Result := FTempPath;
  if Result[Length(Result)] <> '\' then
    Result := Result + '\';
end;

procedure TVCLZip.SetExcludeList(Value: TkpStrings);
begin
  FExcludeList.Assign(Value);
end;

procedure TVCLZip.SetNoCompressList(Value: TkpStrings);
begin
  FNoCompressList.Assign(Value);
end;

function TVCLZip.Split(DeleteOriginal: boolean): boolean;
var
  TotalBytesToCopy: BIGINT;
  TotalBytesDone: BIGINT;
  TotalCentralSize: LongInt;
  SaveCentralPos: BIGINT;
  tmpFiles: TSortedZip;

  procedure SaveFilePart;
  var
    AmtToCopy: BIGINT;
    TotalAmtToCopy: BIGINT;
    progressAmt: BIGINT;
    progressDone: BIGINT;
    progressPartition: BIGINT;
    Percent: LongInt;
  const
    SPAN_BUFFER_SIZE = $4000;
  begin
    progressDone := 0;
    progressAmt := 0;
    if RoomLeft <= 0 then { changed to <= 05/23/00  2.21PR2+ }
      NextPart;
    TotalAmtToCopy := tmpfile_info.compressed_size + tmpfile_info.Lextra_field_length;
    if Assigned(FOnFilePercentDone) then
    begin
      progressAmt := TotalAmtToCopy;
      progressDone := 0;
    end;
    AmtToCopy := kpmin(RoomLeft, TotalAmtToCopy);
    while (TotalAmtToCopy > 0) and (AmtToCopy > 0) do
    begin
      Dec(TotalAmtToCopy, AmtToCopy);
      if Assigned(FOnFilePercentDone) or Assigned(FOnTotalPercentDone) then
      begin
        while (AmtToCopy > 0) do
        begin
          progressPartition := kpmin(SPAN_BUFFER_SIZE, AmtToCopy);
          zfile.CopyFrom(theZipFile, progressPartition);
          Inc(progressDone, progressPartition);
          if Assigned(FOnFilePercentDone) then
          begin
            Percent := CBigRate(progressAmt, progressDone);
            OnFilePercentDone(self, Percent);
          end;
          if Assigned(FOnTotalPercentDone) then
          begin
            TotalBytesDone := TotalBytesDone + progressPartition;
            Percent := CBigRate(TotalBytesToCopy, TotalBytesDone);
            OnTotalPercentDone(self, Percent);
          end;
          Dec(AmtToCopy, progressPartition);
        end;
      end
      else
        zfile.CopyFrom(theZipFile, AmtToCopy);
      if (TotalAmtToCopy > 0) or (RoomLeft <= 0) then
        NextPart;
      AmtToCopy := kpmin(RoomLeft, TotalAmtToCopy);
    end;
  end;

  procedure SaveCentralAndEnd;
  var
    i: Integer;
  begin
    tmpecrec.offset_central := zfile.Position;
    tmpecrec.start_central_disk := CurrentDisk;
    totalCentralSize := 0;
    saveCentralPos := tmpecrec.offset_central;
    for i := 0 to files.Count - 1 do
    begin
      tmpfile_info := tmpFiles.Items[i] as TZipHeaderInfo;
      if (RoomLeft < tmpfile_info.CentralSize) then
      begin
        Inc(TotalCentralSize, zfile.Position - saveCentralPos);
        saveCentralPos := 0;
        NextPart;
        if i = 0 then
        begin
          tmpecrec.offset_central := 0;
          tmpecrec.start_central_disk := CurrentDisk;
        end;
      end;
      tmpfile_info.SaveCentralToStream(zfile, theZipFile, true);
//      if (tmpfile_info.Cextra_field_length > 0) then
//      begin { Copy central directory's extra field } { 04/06/02  2.22+ }
//        theZipFile.Seek(tmpfile_info.central_offset + sizeOf(central_file_header) +
//          tmpfile_info.filename_length, soBeginning);
//        zfile.CopyFrom(theZipFile, tmpfile_info.Cextra_field_length);
//      end;
    end;
    Inc(TotalCentralSize, zfile.Position - saveCentralPos);
    tmpecrec.size_central := TotalCentralSize;
    if (MultiZipInfo.MultiMode <> mmNone) and (RoomLeft < tmpecrec.EndCentralSize) then
      NextPart;
    tmpecrec.this_disk := CurrentDisk;
    tmpecrec.SaveToStream(zfile);
  end;

var
  lrc: local_file_header;
  i: Integer;
  SaveKeepZipOpen: boolean;
  SaveZipName: kpWString;
  OldBusy: Boolean;
  OldOperationMode: TOperationMode;

begin
  OldOperationMode := SetOperationMode(omZip);
  Result := False;
  SaveKeepZipOpen := KeepZipOpen;
  KeepZipOpen := True;
  ReadZip;
  MultiZipInfo.MultiMode := mmBlocks;
  CancelOperation := False;
  OldBusy := SetBusy(True);
  CurrentDisk := 0;
  KeepZipOpen := True;
  sortfiles := files;
  SortMode := ByNone;
  if (MultiZipInfo.FirstBlockSize = 0) then
    AmountToWrite := MultiZipInfo.BlockSize
  else
    AmountToWrite := MultiZipInfo.FirstBlockSize;
  tmpfiles := TSortedZip.Create(DupError);
  tmpfiles.Capacity := files.Count;
  tmpfiles.SortMode := ByNone;
  try
    TotalBytesToCopy := theZipFile.Size;
    TotalBytesDone := 0;
    //tmpZipName := ChangeFileExt(ZipName, '.' + Format('%3.3d', [CurrentDisk + 1]));
    tmpZipName := ZipName;
    OnFileNameForSplitPart(self, tmpZipName,CurrentDisk+1, spFirst);
    tmpZipName := DestDir + '\' + kpExtractFileName(tmpZipName);
    if (not DirExists(DestDir)) then
      kpForceDirectories(DestDir);
    zfile := TLFNFileStream.CreateFile(tmpZipName, fmCreate, FFlushFilesOnClose, BufferedStreamSize);
    tmpecrec := TEndCentral.Create;

    for i := 0 to files.Count - 1 do
    begin
      tmpfile_info := CreateNewZipHeader;
      tmpfile_info.Assign(files.Items[i] as TZipHeaderInfo);
      if (tmpfile_info.file_comment_length > 0) and (Length(tmpfile_info.filecomment) = 0) then
        tmpfile_info.filecomment := FileComment[i];

      theZipFile.Seek(tmpfile_info.relative_offset, soBeginning);
     { Filename length may have changed from original so we have to get }
     { it from the original local file header - 10/29/97 KLB }
      theZipFile.Read(lrc, SizeOf(local_file_header));
      theZipFile.Seek(lrc.filename_length, soCurrent);
      tmpfile_info.Lextra_field_length := lrc.extra_field_length; { 11/04/99 2.20b4+ }
      tmpfile_info.relative_offset := zfile.Position;
      if (Assigned(FOnUpdate)) then
        FOnUpdate(self, uaKeeping, i);
      if (AmountToWrite <= tmpfile_info.LocalSize) then
      begin { 2/1/98 Changed the above from < to <= }
        NextPart;
        tmpfile_info.disk_number_start := CurrentDisk; { 2/1/98 }
        tmpfile_info.relative_offset := 0; { Added 05/23/00 2.21PR2+ }
      end;
      tmpfile_info.disk_number_start := CurrentDisk;
      tmpfile_info.SaveLocalToStream(zfile);
     {Added following test for zero length because it was doubling archive size - 01/21/97 KLB}
      if (tmpfile_info.compressed_size + tmpfile_info.Lextra_field_length) > 0 then
        SaveFilePart;
      tmpecrec.num_entries := tmpecrec.num_entries + 1;
      tmpecrec.num_entries_this_disk := tmpecrec.num_entries_this_disk + 1;
      tmpfiles.AddObject(tmpfile_info); { Add info to new stuff }
    end;
    SaveCentralAndEnd;
    Result := True;
  finally
    tmpfile_info := nil;
    tmpfiles.Free;
    zfile.Free;
    KeepZipOpen := SaveKeepZipOpen;
    if (Result) and (DeleteOriginal) then
    begin
      SaveZipName := ZipName;
      ClearZip;
      DeleteFile(SaveZipName);
    end;
    if (Result) then
    begin
      OnFileNameForSplitPart(self, tmpZipName, CurrentDisk, spLast);
      ZipName := tmpZipName;
      ReadZip;
    end;
    SetOperationMode(OldOperationMode);
    SetBusy(OldBusy);
  end;
end;

function TVCLZip.GetsaHidden: Boolean;
begin
  Result := (FSearchAttribute and faHidden) <> 0;
end;

procedure TVCLZip.SetsaHidden(value: Boolean);
begin
  if (value) then
    FSearchAttribute := FSearchAttribute or faHidden
  else
    FSearchAttribute := FSearchAttribute and not faHidden;
end;

function TVCLZip.GetsaSysFile: Boolean;
begin
  Result := (FSearchAttribute and faSysFile) <> 0;
end;

procedure TVCLZip.SetsaSysFile(value: Boolean);
begin
  if (value) then
    FSearchAttribute := FSearchAttribute or faSysFile
  else
    FSearchAttribute := FSearchAttribute and not faSysFile;
end;

function TVCLZip.GetsaReadOnly: Boolean;
begin
  Result := (FSearchAttribute and faReadOnly) <> 0;
end;

procedure TVCLZip.SetsaReadOnly(value: Boolean);
begin
  if (value) then
    FSearchAttribute := FSearchAttribute or faReadOnly
  else
    FSearchAttribute := FSearchAttribute and not faReadOnly;
end;

function TVCLZip.GetsaArchive: Boolean;
begin
  Result := (FSearchAttribute and faArchive) <> 0;
end;

procedure TVCLZip.SetsaArchive(value: Boolean);
begin
  if (value) then
    FSearchAttribute := FSearchAttribute or faArchive
  else
    FSearchAttribute := FSearchAttribute and not faArchive;
end;

procedure TVCLZip.ZLibCompressStream(inStream, outStream: TStream; HttpCompression: Boolean = False);
const
  bufferSize = 32768;
var
  zstream: TZStreamRec;
  zresult: Integer;
  inBuffer: array[0..bufferSize - 1] of AnsiChar;
  outBuffer: array[0..bufferSize - 1] of AnsiChar;
  inSize: Integer;
  outSize: Integer;
  done: Integer;
  Percent: Integer;
begin
  FillChar(zstream, SizeOf(TZStreamRec), 0);
  done := 0;

  if (HttpCompression) then
    CCheck(DeflateInit2(zstream, PackLevel, 8, -15, 9, 0))
  else
    CCheck(DeflateInit(zstream, PackLevel));

  inSize := inStream.Read(inBuffer, bufferSize);
  Inc(done,inSize);

  while inSize > 0 do
  begin
    zstream.next_in := inBuffer;
    zstream.avail_in := inSize;

    repeat
      zstream.next_out := outBuffer;
      zstream.avail_out := bufferSize;

      CCheck(deflate(zstream, Z_NO_FLUSH));

      // outSize := zstream.next_out - outBuffer;
      outSize := bufferSize - zstream.avail_out;

      outStream.Write(outBuffer, outSize);
    until (zstream.avail_in = 0) and (zstream.avail_out > 0);
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
    if Assigned(FOnFilePercentDone) then
      begin
        Percent := CBigRate( inStream.Size, done );
        {Percent := min(((outpos * 100) div file_info.uncompressed_size), 100 ); }
        FOnFilePercentDone( self, Percent );
      end;

    inSize := inStream.Read(inBuffer, bufferSize);
    Inc(done,inSize);
  end;

  repeat
    zstream.next_out := outBuffer;
    zstream.avail_out := bufferSize;

    zresult := CCheck(deflate(zstream, Z_FINISH));

    // outSize := zstream.next_out - outBuffer;
    outSize := bufferSize - zstream.avail_out;

    outStream.Write(outBuffer, outSize);
  until (zresult = Z_STREAM_END) and (zstream.avail_out > 0);

  CCheck(deflateEnd(zstream));
end;

procedure TVCLZip.ZLibCompressBuffer(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer; HttpCompression: Boolean = False);
const
  delta = 256;
var
  zstream: TZStreamRec;
begin
  FillChar(zstream, SizeOf(TZStreamRec), 0);

  outSize := ((inSize + (inSize div 10) + 12) + 255) and not 255;
  GetMem(outBuffer, outSize);

  try
    zstream.next_in := inBuffer;
    zstream.avail_in := inSize;
    zstream.next_out := outBuffer;
    zstream.avail_out := outSize;

  if (HttpCompression) then
    CCheck(DeflateInit2(zstream, PackLevel, 8, -15, 9, 0))
  else
    CCheck(DeflateInit(zstream, PackLevel));

    try
      while CCheck(deflate(zstream, Z_FINISH)) <> Z_STREAM_END do
      begin
        Inc(outSize, delta);
        ReallocMem(outBuffer, outSize);

        zstream.next_out := PAnsiChar(Integer(outBuffer) + zstream.total_out);
        zstream.avail_out := delta;
      end;
    finally
      CCheck(deflateEnd(zstream));
    end;

    ReallocMem(outBuffer, zstream.total_out);
    outSize := zstream.total_out;
  except
    FreeMem(outBuffer);
    raise;
  end;
end;

function TVCLZip.ZLibCompressString(const s: string; HttpCompression: Boolean = False): string;
begin
  result := ZLibCompressStr(s,HttpCompression);
end;

function TVCLZip.ZLibCompressStr(const s: string; HttpCompression: Boolean = False): string;
var
  buffer: Pointer;
  size: Integer;
begin
  {$WARNINGS OFF}
  ZLibCompressBuffer(PAnsiChar(s), Length(s)*SizeOf(Char), buffer, size, HttpCompression);
  {$WARNINGS ON}
  SetLength(result, size);
  if (size > 512) then
    move(buffer^, pointer(result)^, size)
  else
      MoveI32(pointer(buffer)^, pointer(result)^, size);
  FreeMem(buffer);
end;

{$IFNDEF FULLPACK}

procedure Register;
begin
  RegisterComponents('VCLZip', [TVCLZip]);
end;
{$ENDIF}


{ $Id: VCLZip.pas,v 1.1 2001-08-12 17:30:41-04 kp Exp kp $ }

{ $Log:  10016: VCLZip.pas 
{
{   Rev 1.6    11/30/2008 1:44:08 PM  Delphi7    Version: VCLZip Version 4.50
{ Modifications for 4.50
}
{
{   Rev 1.5    4/17/2008 1:51:54 PM  Delphi7    Version: VCLZip Pro 4.10 Beta
{ Check for \ at end of FTempPath
}
{
{   Rev 1.4    10/27/2007 10:29:08 PM  Delphi7    Version: VCLZip Pro Encryption 4.0 b1
{ Fix problem with mmBlocks and AES
}
{
{   Rev 1.3    2/12/2007 10:07:58 PM  Encryption
{ AES Encryption
}
{
{   Rev 1.2    10/11/2006 7:19:36 PM  Delphi7
{ - Fix num_entries_this_disk problem (when adding files to existing archive)
{ - Removed reliance on doRecurse for AddDirEntriesOnRecurse
}
{
{   Rev 1.1    2/6/2006 10:59:50 PM  Delphi7
}
{
{   Rev 1.0    8/14/2005 1:07:58 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.15.1.30.1.19    4/7/2005 6:40:10 PM  Supervisor    Version: VCLZip 3.X
{ Add ZLibCompressString which will just call ZLibCompressStr
}
{
{   Rev 1.15.1.30.1.18    4/2/2005 4:58:20 PM  Supervisor    Version: VCLZip 3.X
{ ZLib 1.2.2 default
{ Fixed ZLibDecompressStream
{ Delphi 2005 compatible
{ Other assorted bug fixes
}
{
{   Rev 1.15.1.30.1.17    10/11/2004 5:18:22 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.30.1.16    7/28/2004 8:54:32 PM  Supervisor    Version: VCLZip 3.X
{ TOEMConvert
}
{
{   Rev 1.15.1.30.1.15    7/22/2004 12:41:02 PM  Supervisor    Version: VCLZip 3.X
{ Fixed greater than 65K files problem
{ Fixed problem when CD spanned parts
{ Fixed OperationMode settings
{ Fixed Zip64 EOCL
}
{
{   Rev 1.15.1.30.1.14    7/19/2004 7:56:04 PM  Supervisor    Version: VCLZip 3.X
{ Fixed problem with GetSize.
}
{
{   Rev 1.15.1.30.1.13    1/10/2004 4:03:00 PM  Supervisor    Version: VCLZip 3.X
{ UNKNOWN to BINARY
}
{
{   Rev 1.15.1.30.1.12    12/13/2003 9:09:22 PM  Supervisor    Version: VCLZip 3.X
{ Clear Extended Header flag
}
{
{   Rev 1.15.1.30.1.11    11/30/2003 10:06:46 AM  Supervisor    Version: VCLZip 3.X
{ Use FName as Msg2 instead.
}
{
{   Rev 1.15.1.30.1.10    11/30/2003 9:29:54 AM  Supervisor    Version: VCLZip 3.X
{ Add filename in Msg2 for IDS_BAD_UNCOMPRESSED_SIZE
}
{
{   Rev 1.15.1.30.1.9    11/30/2003 12:01:04 AM  Supervisor    Version: VCLZip 3.X
{ Added check for BAD_UNCOMPRESSED_SIZE
}
{
{   Rev 1.15.1.30.1.8    11/26/2003 4:02:40 PM  Supervisor    Version: VCLZip 3.X
{ Added HttpCompression boolean to all ZLib methods
}
{
{   Rev 1.15.1.30.1.7    11/26/2003 9:20:20 AM  Supervisor    Version: Zlib and GZip
{ More work on ZLib routines.  Includes a test of httpcompression boolean
}
{
{   Rev 1.15.1.30.1.6    11/25/2003 9:39:14 AM  Supervisor    Version: Zlib and GZip
{ Added ZLib routines.
}
{
{   Rev 1.15.1.30.1.5    11/11/2003 4:12:58 PM  Supervisor    Version: 3.04b1
}
{
{   Rev 1.15.1.30.1.4    11/11/2003 4:02:50 PM  Supervisor    Version: 3.04b1
}
{
{   Rev 1.15.1.30.1.3    11/11/2003 1:04:48 PM  Supervisor    Version: 3.04b1
{ Changes for overloaded zipfromstream
}
{
{   Rev 1.15.1.30.1.2    11/1/2003 8:11:40 PM  Supervisor    Version: VCLZip 3.X
{ Add overloaded ZipFromStream and UnZipToStreams for TStreams
}
{
{   Rev 1.15.1.30.1.1    11/1/2003 2:58:28 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.30.1.0    11/1/2003 2:24:02 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.30    10/15/2003 5:49:38 PM  Supervisor    Version: VCLZip 3.X
{ Add missing FindClose's
}
{
{   Rev 1.15.1.29    10/11/2003 12:01:44 AM  Supervisor    Version: VCLZip 3.X
{ Fixed AddDirEntriesOnRecurse.  Was always saving dir entries.
}
{
{   Rev 1.15.1.28    10/9/2003 10:47:54 PM  Supervisor    Version: VCLZip 3.X
{ Added a FindClose, dirs were left open when adding to archives.
}
{
{   Rev 1.15.1.27    10/9/2003 6:58:12 PM  Supervisor    Version: VCLZip 3.X
{ Fix LabelDisk
}
{
{   Rev 1.15.1.26    10/7/2003 7:52:58 AM  Supervisor    Version: VCLZip 3.X
{ Fixed DirExists prolem with root dir.  Went back to old code for DirExists
{ for now.
}
{
{   Rev 1.15.1.25    9/28/2003 8:17:28 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.24    9/28/2003 7:56:42 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.23    9/28/2003 2:27:50 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.22    9/21/2003 1:24:36 PM  Supervisor    Version: VCLZip 3.X
{ Mod to use standard zlib
}
{
{   Rev 1.15.1.21    9/18/2003 5:54:32 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.20    9/13/2003 7:53:22 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.19    9/7/2003 9:38:30 AM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.18    9/2/2003 7:19:10 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.17    9/2/2003 7:47:00 AM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.16    8/30/2003 2:16:18 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.15    8/26/2003 10:45:16 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.14    8/26/2003 8:58:08 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.13    8/24/2003 5:28:38 PM  Supervisor    Version: VCLZip 3.X
{ Added ExpandFilesList
}
{
{   Rev 1.15.1.11    8/19/2003 7:39:50 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.10    8/12/2003 5:23:50 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.8    8/4/2003 10:23:36 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.7    8/4/2003 8:37:54 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.6    7/5/2003 3:58:04 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.5    6/25/2003 6:17:24 PM  Kevin    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.4    6/11/2003 9:53:42 PM  Kevin    Version: VCLZip 3.X
}
{
{   Rev 1.15.1.3    5/25/2003 11:23:44 PM  Supervisor    Version: VCLZip 3.X
{ Wrapped KPSMALL around a new Application.ProcessMessages
}
{
{   Rev 1.15.1.2    5/23/2003 10:00:28 AM  Supervisor    Version: VCLZip3.02 Release Candidate
}
{
{   Rev 1.15.1.1    5/21/2003 11:03:36 PM  Kevin    Version: VCLZip3.02 Release Candidate
{ Modified setting Capacity to include Count to account for files already in
{ zip.
}
{
{   Rev 1.15.1.0    5/21/2003 7:43:48 AM  Supervisor    Version: VCLZip3.00z64c
}
{
{   Rev 1.15    5/20/2003 10:46:24 PM  Kevin    Version: VCLZip3.00z64c
}
{
{   Rev 1.14    5/20/2003 4:44:24 PM  Supervisor
}
{
{   Rev 1.13    5/19/2003 10:45:04 PM  Supervisor
{ After fixing streams.  VCLZip still uses ErrorRpt.  Also added setting of
{ capacity on the sorted containers to alleviate the memory problem caused by
{ growing array.
}
{
{   Rev 1.11    5/6/2003 8:03:34 PM  Supervisor
}
{
{   Rev 1.10    5/6/2003 6:11:40 PM  Supervisor
}
{
{   Rev 1.9    5/3/2003 6:33:34 PM  Supervisor
}
{
{   Rev 1.8    3/31/2003 6:17:54 PM  Supervisor    Version: VCLZip 3.00 Beta
}
{
{   Rev 1.7    3/31/2003 5:55:34 PM  Supervisor    Version: VCLZip 3.00 Beta
{ Added fix for sortfiles memory leak and filecomment memory leak
}
{
{   Rev 1.6    1/29/2003 10:29:42 PM  Supervisor
{ Added SearchAttributes and Pause features
}
{
{   Rev 1.5    1/28/2003 10:51:26 PM  Supervisor
{ Added code for setting Search Attributes
}
{
{   Rev 1.4    1/28/2003 6:53:50 PM  Supervisor
}
{
{   Rev 1.3    1/18/2003 6:38:36 PM  Supervisor
}
{
{   Rev 1.2    1/4/2003 1:28:42 PM  Supervisor
}
{
{   Rev 1.1    10/20/2002 9:23:00 PM  Supervisor
{ Modified to get correct compressed length for spanned files.
}
{
{   Rev 1.0    10/15/2002 8:15:24 PM  Supervisor
}
{
{   Rev 1.4    9/18/2002 12:45:48 PM  Supervisor
{ Added ZLib
}
{
{   Rev 1.3    9/7/2002 8:48:46 AM  Supervisor
{ Last modifications for FILE_INT
}
{
{   Rev 1.2    9/3/2002 11:46:20 PM  Supervisor
{ Mod for FILE_INT
}
{
{   Rev 1.1    9/3/2002 11:32:46 PM  Supervisor
{ Mod for FILE_INT
}
{
{   Rev 1.0    9/3/2002 8:16:54 PM  Supervisor
}
{ Revision 1.1  2001-08-12 17:30:41-04  kp
{ Initial revision
{
{ Revision 1.38  2000-12-16 16:50:09-05  kp
{ 2.21 Final Release 12/12/00
{
{ Revision 1.37  2000-06-04 15:51:57-04  kp
{ - Moved call to ExpandForWildcards to before the guess for space needed for zfc file
{ - Fixed so you could have FilePercentDone without needing TotalPercentDone when
{   creating spanned zip files
{ - Fixed so relative_offset set correctly for spanned zips.  Side effect of removing needless
{   write of header.
{
{ Revision 1.36  2000-05-21 18:43:31-04  kp
{ - Fixed bug where file being compressed with password wasn't getting crc checked properly
    in CalcFileCRC if file bigger then BLKSIZ
{ - Modified buffer size in SaveMFile
{
{ Revision 1.35  2000-05-13 16:50:41-04  kp
{ - Changed default for FileOpenMode back to fmShareDenyNone as it was for all versions
{   except for 2.20
{ - Added code to handle new BufferedStreamSize property
{ - Changed BLKSIZE in CalcFileCRC
{ - Fixed problem where driveparts weren't being stripped if relativepaths wat set true.
{ - Removed unnecessary write of header to floppy during spanned zip creation
{ - Added code to report not enough space to write zfc file with KPSMALL set.
{
{ Revision 1.34  1999-12-05 09:33:01-05  kp
{ - Added BIGINT
{ - Changed register to VCLZip palette
{
{ Revision 1.33  1999-11-09 19:40:16-05  kp
{ - Modified to correctly handle extra fields in headers
{
{ Revision 1.32  1999-11-03 17:34:17-05  kp
{ - Moved check for and deletion of existing file on new diskette to come before
{ determination of diskroom.
{
{ Revision 1.31  1999-10-28 17:56:52-04  kp
{ - Added SetDateTime[Index]
{
{ Revision 1.30  1999-10-24 11:01:17-04  kp
{ - Added some things that are still under development and ifdefed out right now.
{
{ Revision 1.29  1999-10-24 09:31:25-04  kp
{ - Added error checking and notification if zcf file can't be created or written to.
{
{ Revision 1.28  1999-10-20 18:14:19-04  kp
{ - added retry parameter to OnSkippingFile
{ - added delete of file if already exists on newly inserted spanned diskette (2.20b3+)
{
{ Revision 1.27  1999-10-17 12:00:30-04  kp
{ - Changed min and max to kpmin and kpmax
{
{ Revision 1.26  1999-10-17 09:29:05-04  kp
{ - Added FileOpenMode property
{
{ Revision 1.25  1999-10-11 20:10:44-04  kp
{ - Some mods and relocations to multizip operations
{ - Added FlushFilesOnClose property
{
{ Revision 1.24  1999-10-10 21:32:41-04  kp
{ - Added capability to Delete Selected files.
{ - Modified calculation for amount of space to save for SaveZipInfoOnFirstDisk
{ - Moved call to OnTotalPercent 100% for multivolume zipfiles
{
{ Revision 1.23  1999-09-16 20:04:23-04  kp
{ - Moved defines to KPDEFS.INC
{
{ Revision 1.22  1999-09-14 21:32:41-04  kp
{ - Added some checks to make sure that either ZipName or ArchiveStream is set.
{ - Moved guess for space to save for first spanned disk for Zip Configuration File
{   to where it would have and effect
{ - Changed name of local variable to tAmountToWrite in zfwrite since it was the same as
{   a class global.
{
{ Revision 1.21  1999-08-25 19:03:42-04  kp
{ - Fixes for D1
{ - Updated Assign methods
{
{ Revision 1.20  1999-08-25 18:00:03-04  kp
{ - Added capability to read multizip file from first disk
{ - Modified so MakeNewSFX could also add an already existing zip file.
{ - Guesstimate room needed on first disk for Zip Configuration File
{
{ Revision 1.19  1999-07-06 19:57:51-04  kp
{ - Added OnUpdate event
{
{ Revision 1.18  1999-07-05 11:24:25-04  kp
{ - Changed AddDirEntries to AddDirEntriesOnRecurse
{ - Modified so FilesList is cleared when zip operations are done
{ - Modifed so it is possible to assign zip comment when creating new archive without
{   having to do it from the OnStartZipInfo event
{
{ Revision 1.17  1999-06-27 10:16:12-04  kp
{ - Fixed problem with adding directories manually to FilesList
{ - Added Assign method
{
{ Revision 1.16  1999-06-18 16:45:58-04  kp
{ - Modified to handle adding directory entries when doing recursive zips (AddDirEntries property)
{
{ Revision 1.15  1999-06-01 21:59:41-04  kp
{ - Fixed SkipIfArchiveBitNotSet
{ - Added a call to OnTotalPercentDone with 100% done after spanning/block zip complete
{ - Added kpDiskFree to try to handle UNC paths but it won't help with that problem
{
{ Revision 1.14  1999-04-24 21:12:28-04  kp
{ - Added MakeNewSFX
{
{ Revision 1.13  1999-04-10 10:18:29-04  kp
{ - Added conditionals to make sure NOLONGNAMES and NODISKUTILS aren't turned on
{  in 32bit.
{ - Added OnZipComplete event
{ - Slight mod to make progress events work for blocked zip creation too
{
{ Revision 1.12  1999-03-30 19:43:24-05  kp
{ - Modified so that defining MAKESMALL will create a much smaller component.
{
{ Revision 1.11  1999-03-22 17:31:44-05  kp
{ - added support for BCB4
{ - moved comments to bottom
{ - moved strings to string table
{
{ Revision 1.10  1999-03-17 17:10:32-05  kp
{ - Changed the name of ExeToZip to SFXToZip.
{ - Added a Boolean parmeter to SFXToZip to tell whether to delete the old sfx file.
{ - Modified to make OnTotalPercentDone work correctly for spanned disk sets.
{
{ Revision 1.9  1999-03-16 20:13:51-05  kp
{ - Added ExeToZip procedure
{
{ Revision 1.8  1999-03-16 19:21:09-05  kp
{ - Modified to make OnFilePercentDone work across the copy of the compressed file to disk
{   when creating a spanned disk set.
{
{ Revision 1.7  1999-02-08 21:41:00-05  kp
{ Modified FixZip to work with D1.
{
{ Revision 1.6  1999-01-12 20:23:34-05  kp
{ -Slight modifications to the precompiler conditionals
{ -Added the PreserveStubs public property
{ }

{ Sat 04 Jul 1998   16:16:01
{ Added SkipIfArchiveBitNotSet property
{ Added ResetArchiveBitOnZip property
}
{
{  Sun 10 May 1998   16:58:46   Version: 2.12
{ - Added TempPath property
{ - Fixed RelativePaths bug
{ - Fixed bug related to files in FilesList that don't exist
}
{
{ Mon 27 Apr 1998   18:22:44   Version: 2.11
{ Added BCB 3 support
{ Invalid Pointer operation bug fix
{ CalcCRC for D1 bug fix
{ Quit during wildcard expansion bug fix
{ Straightened out some conditional directives
}
{
{  Sun 29 Mar 1998   10:51:35  Version: 2.1
{ Version 2.1 additions
{
{ - Capability of 16bit VCLZip to store long filenames/paths
{ when running on 32 bit OS.
{ - New Store83Names property to force storing short
{ filenames and paths
{ - Better UNC path support.
{ - Fixed a bug to allow adding files to an empty archive.
}
{
{   Tue 24 Mar 1998   19:00:22
{ Modifications to allow files and paths to be stored in DOS
{ 8.3 filename format.  New property is Store83Names.
}
{
{   Wed 11 Mar 1998   21:10:16  Version: 2.03
{ Version 2.03 Files containing many fixes
}

end.

