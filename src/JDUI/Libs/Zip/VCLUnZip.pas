{ ********************************************************************************** }
{                                                                                    }
{   COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: VCLUnZip.pas                                                      }
{     Description: VCLUnZip component - native Delphi unzip component.               }
{     Date:        March 1997                                                        }
{     Author:      Kevin Boylan, vclzip@bigfoot.com                                 }
{                                                                                    }
{                                                                                    }
{ ********************************************************************************** }
unit VCLUnZip;

{$P-}                                                   { turn off open parameters }
{$R-}                                                   { 3/10/98 2.03 }
{$Q-}                                                   { 3/10/98 2.03 }
{$B-} { turn off complete boolean eval }                { 12/24/98  2.17 }

{$I KPDEFS.INC}

interface

uses
   {$IFDEF WIN32}
   Windows,
   {$ELSE}
   WinTypes, WinProcs,
   {$ENDIF}
   {$IFNDEF INT64STREAMS}
   kphstrms,
   {$ENDIF}
   SysUtils, Classes,
   kpSmall,
{$IFNDEF KPSMALL}
   Controls, Forms, Dialogs, FileCtrl,
{$ENDIF}
   kpUtilsUnicode, kpCntn, kpMatch, KpLib, kpZipObj, kpzcnst, kpaes;

{$I kpZTypes.Pas}

const
   kpThisVersion         = 451; {added this constant 3/1/98 initially for version 2.03}
   kpThisBuild           = 1;
   kpThisReleaseLevel    = 'Release';
   ZLIB_VERSION          = '1.2.3';

   {$IFDEF WIN32}
   DEF_BUFSTREAMSIZE      = 8192;   { Changed back to 8192 7/20/01  2.21+ }
   {$ELSE}                          { Larger values can cause memory problems }
   DEF_BUFSTREAMSIZE      = 8192;   { Changed back to 8192 7/20/01  2.21+ }
   {$ENDIF}

type

   TMultiMode = (mmNone, mmSpan, mmBlocks);
   TIncompleteZipMode = (izAssumeMulti, izAssumeBad, izAssumeNotAZip);
   TUZOverwriteMode = (Prompt, Always, Never, ifNewer, ifOlder);  { added ifNewer,ifOlder 8/2/98  2.14 }
   TSkipReason = (srBadPassword, srNoOverwrite, srFileOpenError, srCreateError, srExcludeList, srArchiveBitNotSet,srNoFileToFreshen,srSkippedInStartZip);
   TSplitPartType = (spFirst, spMiddle, spLast);
   TOperationMode = (omZip, omUnZip, omNone);
   TBlockMode = (bmStandard, bmClassic);

   {Decryption}

   DecryptKey = array[0..2] of LongInt;
   DecryptHeaderPtr = ^DecryptHeaderType;
   DecryptHeaderType = array[0..11] of BYTE;

   { Exceptions }
   EVCLZipException = class(Exception);                         { 6/25/03 3.02 }
   EBadZipFile = class(EVCLZipException);
   EFileNotAllThere = class(EVCLZipException);
   EIncompleteZip = class(EVCLZipException);
   ENotAZipFile = class(EVCLZipException);
   EFatalUnzipError = class(EVCLZipException);
   EUserCanceled = class(EVCLZipException);
   EInvalidPassword = class(EVCLZipException);
   EBiggerThanUncompressed = class(EVCLZipException);          { 4/16/98 2.11 }
   ENotEnoughRoom = class(EVCLZipException);
   ECantWriteUCF = class(EVCLZipException);
   ECanceledUnzipToBuffer = class(EVCLZipException);
   EConfigFileSaveError = class(EVCLZipException);


   { Event types }

   TStartUnzipInfo = procedure(Sender: TObject; NumFiles: Integer;
      TotalBytes: Comp; var StopNow: Boolean) of object;
   TStartUnZipEvent = procedure(Sender: TObject; FileIndex: Integer;
      var FName: kpWString; var Skip: Boolean) of object;
   TEndUnZipEvent = procedure(Sender: TObject; FileIndex: Integer; FName: kpWString) of object;
   TFilePercentDone = procedure(Sender: TObject; Percent: LongInt) of object;
   TTotalPercentDone = procedure(Sender: TObject; Percent: LongInt) of object;
   TPromptForOverwrite = procedure(Sender: TObject; var OverWriteIt: Boolean;
      FileIndex: Integer; var FName: kpWString) of object;
   TSkippingFile = procedure(Sender: TObject; Reason: TSkipReason; FName: kpWString;
      FileIndex: Integer; var Retry: Boolean) of object;
   TBadPassword = procedure(Sender: TObject; FileIndex: Integer; var NewPassword: AnsiString) of
      object;
   TBadCRC = procedure(Sender: TObject; CalcCRC, StoredCRC: LongInt;
      FileIndex: Integer) of object;
   TIncompleteZip = procedure(Sender: TObject; var IncompleteMode: TIncompleteZipMode) of
      object;
   TGetNextDisk = procedure(Sender: TObject; NextDisk: Integer; var FName: kpWString) of object;
   TUnZipComplete = procedure(sender: TObject; FileCount: Integer) of object;
   TGetNextBuffer = procedure(Sender: TObject; var Buffer: PAnsiChar; FName: kpWString; AmountUsed:
      LongInt;
      BufferNum: Integer; var Quit: Boolean) of object;
   TDecryptEvent = procedure(Sender: TObject; buffer: BytePtr; length: Integer;
                             Password: AnsiString ) of object;
   TFileNameForSplitPartEvent = procedure(Sender: TObject; var FName: kpWString; PartNum: Integer;
                SplitType: TSplitPartType) of object;
   THandleMessageEvent = procedure(Sender: TObject; const MessageID: Integer; const Msg1: String; const Msg2: String; const flags: LongWord; var Return: Integer) of Object;

   {$IFNDEF WIN32}
   DWORD = LongInt;
   {$ENDIF}

   TVCLUnZip = class(TComponent)
   PRIVATE
      { Private declarations }
      FZipName: kpWString;
      FDestDir: kpWString;
      FSortMode: TZipSortMode;
      FReCreateDir: Boolean;
      FOverwriteMode: TUZOverwriteMode;
      FFilesList: TkpStrings;
      FDoAll: Boolean;
      FPassword: AnsiString;
      FIncompleteZipMode: TIncompleteZipMode;
      FKeepZipOpen: Boolean;
      FDoProcessMessages: Boolean;
      FNumDisks: Integer;
      FRetainAttributes: Boolean;
      FThisVersion: Integer;
      FThisBuild: Integer;
      FThisReleaseLevel: String;
      FReplaceReadOnly: Boolean;
      FNumSelected: Integer;
      FBufferLength: LongInt;                           { 8/23/99  2.18+ }
      FImproperZip: Boolean;                            { 2/19/00  2.20+ }
      FEncryptBeforeCompress: Boolean;                  { 12/9/01 2.22+ }
      FOEMConvert: TOEMConvert;                             { 2/17/02 2.22+ }

      { Event variables }
      FOnStartUnzipInfo: TStartUnzipInfo;
      FOnStartUnZip: TStartUnZipEvent;
      FOnEndUnZip: TEndUnZipEvent;
      FOnPromptForOverwrite: TPromptForOverwrite;
      FOnBadPassword: TBadPassword;
      FOnBadCRC: TBadCRC;
      FOnInCompleteZip: TInCompleteZip;
      FOnUnzipComplete: TUnZipComplete;
      FOnGetNextBuffer: TGetNextBuffer;
      FOnDecrypt: TDecryptEvent;

      function ProcessIntegrityCheck(Index: Integer): Boolean; { 8/15/99 2.18+ }

      { Decrypt }
   PROTECTED
      FOnFilePercentDone: TFilePercentDone;
      FOnTotalPercentDone: TTotalPercentDone;
      FOnSkippingFile: TSkippingFile;
      FOnGetNextDisk: TGetNextDisk;
      FOnFileNameForSplitPart: TFileNameForSplitPartEvent;
      FOnHandleMessage: THandleMessageEvent;
      FArchiveStream: TkpStream;
      FArchiveTStream: TStream;
      FOperationMode: TOperationMode;
      FBlockMode: TBlockMode;
      FBusy: Boolean;
      FRootDir: kpWString;
      FRelativePathList: TkpStrings;
      FTestMode: Boolean;                               { 12/3/98  2.17P+ }
      FFlushFilesOnClose: Boolean;                      { 10/11/99 2.18+ }
      FBufferedStreamSize: Integer;                    { 05/13/00 2.20+ }
      ArchiveIsStream: Boolean;
      FCheckDiskLabels: Boolean;
      FMultiMode: TMultiMode;
      file_info: TZipHeaderInfo;
      files: TSortedZip;
      sortfiles: TSortedZip;
      filesDate: TDateTime;
      ZipIsBad: Boolean;
      CurrentDisk: LongWord;
      theZipFile: TkpStream;
      Crc32Val: U_LONG;
      lrec: local_file_header;
      {crec: central_file_header;}                      { Removed 4/22/02 2.23+ }
      ecrec: TEndCentral;
      ZipCommentPos: BIGINT;
      UnZippingSelected: Boolean;                       { 6/27/99 2.18+ }

      tmpMStr: string;
      Key: DecryptKey;
      CancelOperation: Boolean;
      PauseOperation: Boolean;
      ZipStream: TkpStream;
      StreamZipping: Boolean;
      MemZipping: Boolean;
      MemBuffer: PAnsiChar;
      MemLen: BIGINT;
      MemLeft: BIGINT;
      CurrMem: PAnsiChar;
      Fixing: Boolean;
      DR: Boolean;
      FZipNameNoExtension: kpWString;

      //AES Encryption
        rng:                array[0..0] of prng_ctx;
        zcx:                array[0..0] of fcrypt_ctx;



      TotalUncompressedSize: Comp;
      TotalBytesDone: Comp;

      procedure OpenZip;
      procedure CloseZip;
      function GetCount: Integer;
      procedure GetFileInfo(infofile: TkpStream);
      function GetZipName: kpWString;
      procedure SetZipName(ZName: kpWString); VIRTUAL;
      procedure SetArchiveStream(theStream: TkpStream);
      function GetDestDir: kpWString;
      procedure SetDestDir(DDir: kpWString);
      procedure SetRootDir(Value: kpWString);
      function StripRelativePath( var path: kpWString ): kpWString;
      function UnZipFiles(zip_in_file: TkpStream): Integer;
      function UpdCRC(Octet: Byte; Crc: U_LONG): U_LONG;
      function SwapDisk(NewDisk: Integer): TkpStream;
      procedure SetFileComment(Index: Integer; theComment: AnsiString);
      procedure SetZipComment(theComment: AnsiString);
      procedure WriteNumDisks(NumberOfDisks: Integer);
      procedure NewDiskEvent(Sender: TObject; var S: TkpStream);
      procedure SetThisVersion(v: Integer);
      procedure SetThisBuild(b: Integer);
      procedure SetThisReleaseLevel(l: String);
      function GetCheckDiskLabels: Boolean; VIRTUAL;
      procedure SetCheckDiskLabels(Value: Boolean); VIRTUAL;
      function CreateNewZipHeader: TZipHeaderInfo;
      function SetBusy( value: Boolean ): Boolean;
      function SetOperationMode( value: TOperationMode ): TOperationMode;



      { GetMultiMode and SetMultiMode added 3/10/98 for 2.03}
      function GetMultiMode: TMultiMode; VIRTUAL;
      procedure SetMultiMode(Value: TMultiMode); VIRTUAL;

      { List functions }
      procedure SetFilesList(Value: TkpStrings);
      function GetFilename(Index: Integer): TZipFilename;
      function GetPathname(Index: Integer): TZipPathname;
      function GetFullname(Index: Integer): kpWString;
      function GetCompressMethod(Index: Integer): WORD;
      function GetCompressMethodStr(Index: Integer): string;
      function GetDateTime(Index: Integer): TDateTime;
      function GetCrc(Index: Integer): U_LONG;
      function GetCompressedSize(Index: Integer): BIGINT;
      function GetUnCompressedSize(Index: Integer): BIGINT;
      function GetExternalFileAttributes(Index: Integer): U_LONG;
      function GetIsEncrypted(Index: Integer): Boolean;
      function GetHasComment(Index: Integer): Boolean;
      function GetFileComment(Index: Integer): AnsiString;
      function GetFileIsOK(Index: Integer): Boolean;    { 12/3/98  2.17P+ }
      function GetDiskNo(Index: Integer): Integer;
      function GetSelected(Index: Integer): Boolean;    {6/27/99 2.18+ }
      procedure SetSelected(Index: Integer; Value: Boolean);
      function GetEncryptionStrength(Index: Integer): TEncryptStrength;
     {$IFDEF ISDELPHI}
      function GetDecryptHeader(Index: Integer): DecryptHeaderType;
      {$ENDIF}
      function GetZipHasComment: Boolean;
      function GetZipComment: AnsiString;
      function GetZipSize: BIGINT;
      function GetIsZip64: Boolean;

      {Decryption}
      function DecryptTheHeader(Passwrd: AnsiString; zfile: TkpStream): BYTE;
      function DecrypteAESHeader(pwd: AnsiString; var zfile: TkpStream): boolean;
      procedure update_keys(ch: AnsiChar);
      function decrypt_byte: BYTE;
      procedure Init_Keys(Passwrd: Ansistring);
      procedure Update_CRC_buff(bufptr: BYTEPTR; num_to_update: LongInt);
      procedure DoFileNameForSplitPart(var FName: kpWString; PartNum: Integer;
                SplitType: TSplitPartType);
      procedure DoGetNextDisk(NextDisk: Integer; var FName: kpWString);
      function DoHandleMessage(const MessageID: Integer; const Msg1: String; const Msg2: String; const flags: LongWord ): Integer;


      procedure Loaded; OVERRIDE;

      procedure DoPause;

   PUBLIC
      { Public declarations }
      constructor Create(AOwner: TComponent); OVERRIDE;
      destructor Destroy; OVERRIDE;
      procedure Assign(Source: TPersistent); OVERRIDE;  { 6/27/99 2.18+ }
      procedure ReadZip;
      function UnZip: Integer;
      function UnZipSelected: Integer;
      procedure ClearSelected;
      procedure ClearZip;
      procedure FillList(FilesList: TStrings);
      procedure Sort(SMode: TZipSortMode);
      procedure CancelTheOperation;
      procedure PauseTheOperation;
      procedure RestartTheOperation;
      procedure AskForNewDisk(NewDisk: Integer);
      procedure DefaultGetNextDisk(Sender: TObject; NextDisk: Integer; var FName: kpWString);
      procedure DefaultFileNameForSplitPart(Sender: TObject; var FName: kpWString; PartNum: Integer;
                SplitType: TSplitPartType);
      function DefaultHandleMessage(const MessageID: Integer; const Msg1: String; const Msg2: String; const flags: LongWord): Integer;
      function UnZipToStream(theStream: TkpStream; FName: kpWString): Integer;
      {$IFNDEF INT64STREAMS} overload;
      function UnZipToStream(theStream: TMemoryStream; FName: kpWString): Integer; overload;
      function UnZipToStreamByIndex(theStream: TStream; Index: Integer): Integer; overload;
      {$ENDIF}
      function UnZipToStreamByIndex(theStream: TkpStream; Index: Integer): Integer;
      {$IFNDEF INT64STREAMS} overload;
      {$ENDIF}
      function UnZipToBuffer(var Buffer: PAnsiChar; FName: kpWString): Integer;
      function UnZipToBufferByIndex(var Buffer: PAnsiChar; Index: Integer): Integer;

      procedure ZLibDecompressStream(inStream, outStream: TStream; HttpCompression: Boolean = False);
      procedure ZLibDecompressBuffer(const inBuffer: Pointer; inSize: Integer;
                  out outBuffer: Pointer; out outSize: Integer; outEstimate: Integer = 0; HttpCompression: Boolean = False);
      function ZLibDecompressString(const s: string; HttpCompression: Boolean = False): String;

      procedure ResetFileIsOK(Index: Integer);
      function CheckArchive: Boolean;
      function DecryptHeaderByte(Passwrd: Ansistring; dh: DecryptHeaderType): BYTE;
      procedure decrypt_buff(bufptr: BYTEPTR; num_to_decrypt: LongInt);
      { The following two are for BCB because of difficulties passing the DecryptHeaderType }
      procedure GetDecryptHeaderPtr(Index: Integer; dhPtr: BytePtr); { 8/8/99  2.18+ }
      function DecryptHeaderByteByPtr(Passwrd: AnsiString; dh: BytePtr): Byte; { 8/8/99  2.18+ }

      { -------- }
      property ArchiveStream: TkpStream READ theZipFile WRITE SetArchiveStream;
      property Count: Integer READ GetCount;
      property Filename[Index: Integer]: TZipFilename READ GetFilename;
      property Pathname[Index: Integer]: TZipPathname READ GetPathname;
      property FullName[Index: Integer]: kpWString READ GetFullName;
      property CompressMethod[Index: Integer]: WORD READ GetCompressMethod;
      property CompressMethodStr[Index: Integer]: string READ GetCompressMethodStr;
      property DateTime[Index: Integer]: TDateTime READ GetDateTime;
      property Crc[Index: Integer]: U_LONG READ GetCrc;
      property CompressedSize[Index: Integer]: BIGINT READ GetCompressedSize;
      property UnCompressedSize[Index: Integer]: BIGINT READ GetUnCompressedSize;
      property ExternalFileAttributes[Index: Integer]: U_LONG READ GetExternalFileAttributes;
      property IsEncrypted[Index: Integer]: Boolean READ GetIsEncrypted;
      property FileHasComment[Index: Integer]: Boolean READ GetHasComment;
      property FileComment[Index: Integer]: AnsiString READ GetFileComment;
      property FileIsOK[Index: Integer]: Boolean READ GetFileIsOK; { 12/3/98 2.17P+ }
      property DiskNo[Index: Integer]: Integer READ GetDiskNo;
      property Selected[Index: Integer]: Boolean READ GetSelected WRITE SetSelected;  { 6/27/99 2.18+ }
      property EncryptionStrength[Index: Integer]: TEncryptStrength read GetEncryptionStrength;
      property ZipComment: AnsiString READ GetZipComment;
      property Password: AnsiString READ FPassword WRITE FPassword;
      property ZipHasComment: Boolean READ GetZipHasComment;
      property NumDisks: Integer READ FNumDisks;
      property ZipSize: BIGINT READ GetZipSize;
      property CheckDiskLabels: Boolean READ GetCheckDiskLabels WRITE SetCheckDiskLabels DEFAULT
         True;
      property MultiMode: TMultiMode READ GetMultiMode WRITE SetMultiMode DEFAULT mmNone;
      property Busy: Boolean READ FBusy DEFAULT False;
      {$IFDEF ISDELPHI}
      property DecryptHeader[Index: Integer]: DecryptHeaderType READ GetDecryptHeader;
      {$ENDIF}
      property NumSelected: Integer READ FNumSelected;
      property BufferLength: LongInt READ FBufferLength WRITE FBufferLength DEFAULT 0;
      property ImproperZip: Boolean READ FImproperZip DEFAULT False;  { 2/19/00  2.20+ }
      property BufferedStreamSize: Integer READ FBufferedStreamSize
                 WRITE FBufferedStreamSize DEFAULT DEF_BUFSTREAMSIZE;
      property EncryptBeforeCompress: Boolean read FEncryptBeforeCompress write FEncryptBeforeCompress
                 default False;
      property OperationMode: TOperationMode read FOperationMode;
      property isZip64: Boolean read GetIsZip64;

   PUBLISHED
      { Published declarations }
      property ThisVersion: Integer READ FThisVersion WRITE SetThisVersion DEFAULT
         kpThisVersion;
      property ThisBuild: Integer READ FThisBuild WRITE SetThisBuild DEFAULT
         kpThisBuild;
      property ThisReleaseLevel: String READ FThisReleaseLevel WRITE SetThisReleaseLevel;
      property ZipName: kpWString READ GetZipName WRITE SetZipName;
      property DestDir: kpWString READ GetDestDir WRITE SetDestDir;
      property RootDir: kpWString READ FRootDir WRITE SetRootDir;
      property RelativePathList: TkpStrings READ FRelativePathList WRITE FRelativePathList;
      property SortMode: TZipSortMode READ FSortMode WRITE FSortMode DEFAULT ByNone;
      property RecreateDirs: Boolean READ FRecreateDir WRITE FRecreateDir DEFAULT False;
      property OverwriteMode: TUZOverwriteMode READ FOverwriteMode
         WRITE FOverwriteMode DEFAULT Prompt;
      property FilesList: TkpStrings READ FFilesList WRITE SetFilesList;
      property DoAll: Boolean READ FDoAll WRITE FDoAll DEFAULT False;
      property IncompleteZipMode: TIncompleteZipMode READ FIncompleteZipMode
         WRITE FIncompleteZipMode DEFAULT izAssumeMulti;
      property KeepZipOpen: Boolean READ FKeepZipOpen WRITE FKeepZipOpen DEFAULT False;
      property DoProcessMessages: Boolean READ FDoProcessMessages WRITE FDoProcessMessages
         DEFAULT True;
      property RetainAttributes: Boolean READ FRetainAttributes WRITE FRetainAttributes DEFAULT
         True;
      property ReplaceReadOnly: Boolean READ FReplaceReadOnly WRITE FReplaceReadOnly DEFAULT
         False;
      property FlushFilesOnClose: Boolean READ FFlushFilesOnClose WRITE FFlushFilesOnClose
         DEFAULT False;
      property BlockMode: TBlockMode read FBlockMode write FBlockMode default bmStandard;
      { Event Properties }
      property OnStartUnZipInfo: TStartUnzipInfo READ FOnStartUnzipInfo
         WRITE FOnStartUnzipInfo;
      property OnFilePercentDone: TFilePercentDone READ FOnFilePercentDone
         WRITE FOnFilePercentDone;
      property OnTotalPercentDone: TTotalPercentDone READ FOnTotalPercentDone
         WRITE FOnTotalPercentDone;
      property OnStartUnZip: TStartUnZipEvent READ FOnStartUnZip WRITE FOnStartUnZip;
      property OnEndUnZip: TEndUnZipEvent READ FOnEndUnZip WRITE FOnEndUnZip;
      property OnPromptForOverwrite: TPromptForOverwrite READ FOnPromptForOverwrite
         WRITE FOnPromptForOverwrite;
      property OnSkippingFile: TSkippingFile READ FOnSkippingFile WRITE FOnSkippingFile;
      property OnBadPassword: TBadPassword READ FOnBadPassword WRITE FOnBadPassword;
      property OnBadCRC: TBadCRC READ FOnBadCRC WRITE FOnBadCRC;
      property OnInCompleteZip: TInCompleteZip READ FOnInCompleteZip WRITE FOnInCompleteZip;
      property OnGetNextDisk: TGetNextDisk READ FOnGetNextDisk WRITE FOnGetNextDisk;
      property OnUnZipComplete: TUnZipComplete READ FOnUnZipComplete WRITE FOnUnZipComplete;
      property OnGetNextBuffer: TGetNextBuffer READ FOnGetNextBuffer WRITE FOnGetNextBuffer;
      property OnDecrypt: TDecryptEvent READ FOnDecrypt WRITE FOnDecrypt;
      {$IFDEF SUPPORT_UNICODE}
      property OEMConvert: TOEMConvert read FOEMConvert write FOEMConvert default oemFlexible;
      {$ELSE}
      property OEMConvert: TOEMConvert read FOEMConvert write FOEMConvert default oemAlways;
      {$ENDIF}
      property OnFileNameForSplitPart: TFileNameForSplitPartEvent read FOnFileNameForSplitPart
            write FOnFileNameForSplitPart;
      property OnHandleMessage: THandleMessageEvent read FOnHandleMessage write FOnHandleMessage;


   end;

   {$IFNDEF KPSMALL}
var
   OpenZipDlg            : TOpenDialog;
   {$ENDIF}

{$IFNDEF FULLPACK}
procedure Register;
{$ENDIF}
{$IFDEF KPDEMO}
function DelphiIsRunning: Boolean;
{$ENDIF}

{$IFDEF USE_ZLIB}
type
  TZAlloc = function (opaque: Pointer; items, size: Integer): Pointer;
  TZFree  = procedure (opaque, block: Pointer);

  TZCompressionLevel = (zcNone, zcFastest, zcDefault, zcMax);

  {** TZStreamRec ***********************************************************}

  TZStreamRec = packed record
    next_in  : PAnsiChar;     // next input byte
    avail_in : Longint;   // number of bytes available at next_in
    total_in : Longint;   // total nb of input bytes read so far

    next_out : PAnsiChar;     // next output byte should be put here
    avail_out: Longint;   // remaining free space at next_out
    total_out: Longint;   // total nb of bytes output so far

    msg      : PChar;     // last error message, NULL if no error
    state    : Pointer;   // not visible by applications

    zalloc   : TZAlloc;   // used to allocate the internal state
    zfree    : TZFree;    // used to free the internal state
    opaque   : Pointer;   // private data object passed to zalloc and zfree

    data_type: Integer;   // best guess about the data type: ascii or binary
    adler    : Longint;   // adler32 value of the uncompressed data
    reserved : Longint;   // reserved for future use
  end;

type
  EZLibError = class(Exception);

  EZCompressionError = class(EZLibError);
  EZDecompressionError = class(EZLibError);

{** link zlib code **********************************************************}
{$L zlib123\adler32.obj}
{$L zlib123\compress.obj}
{$L zlib123\crc32.obj}
{$L zlib123\deflate.obj}
{$L zlib123\infback.obj}
{$L zlib123\inffast.obj}
{$L zlib123\inflate.obj}
{$L zlib123\inftrees.obj}
{$L zlib123\trees.obj}
procedure adler32; external;
procedure compressBound; external;
procedure crc32; external;
{*****************************************************************************
*  note: do not reorder the above -- doing so will result in external        *
*  functions being undefined                                                 *
*****************************************************************************}


const

  {** flush constants *******************************************************}

  Z_NO_FLUSH      = 0;
  Z_PARTIAL_FLUSH = 1;
  Z_SYNC_FLUSH    = 2;
  Z_FULL_FLUSH    = 3;
  Z_FINISH        = 4;

  {** return codes **********************************************************}

  Z_OK            = 0;
  Z_STREAM_END    = 1;
  Z_NEED_DICT     = 2;
  Z_ERRNO         = (-1);
  Z_STREAM_ERROR  = (-2);
  Z_DATA_ERROR    = (-3);
  Z_MEM_ERROR     = (-4);
  Z_BUF_ERROR     = (-5);
  Z_VERSION_ERROR = (-6);

  {** compression levels ****************************************************}

  Z_NO_COMPRESSION       =   0;
  Z_BEST_SPEED           =   1;
  Z_BEST_COMPRESSION     =   9;
  Z_DEFAULT_COMPRESSION  = (-1);

  {** compression strategies ************************************************}

  Z_FILTERED            = 1;
  Z_HUFFMAN_ONLY        = 2;
  Z_DEFAULT_STRATEGY    = 0;

  {** data types ************************************************************}

  Z_BINARY   = 0;
  Z_ASCII    = 1;
  Z_UNKNOWN  = 2;

  {** compression methods ***************************************************}

  Z_DEFLATED = 8;

  {** return code messages **************************************************}

  _z_errmsg: array[0..9] of PChar = (
    'need dictionary',      // Z_NEED_DICT      (2)
    'stream end',           // Z_STREAM_END     (1)
    '',                     // Z_OK             (0)
    'file error',           // Z_ERRNO          (-1)
    'stream error',         // Z_STREAM_ERROR   (-2)
    'data error',           // Z_DATA_ERROR     (-3)
    'insufficient memory',  // Z_MEM_ERROR      (-4)
    'buffer error',         // Z_BUF_ERROR      (-5)
    'incompatible version', // Z_VERSION_ERROR  (-6)
    ''
  );

  ZLevels: array [TZCompressionLevel] of Shortint = (
    Z_NO_COMPRESSION,
    Z_BEST_SPEED,
    Z_DEFAULT_COMPRESSION,
    Z_BEST_COMPRESSION
  );

  SZInvalid = 'Invalid ZStream operation!';

{** deflate routines ********************************************************}

function deflateInit_(var strm: TZStreamRec; level: Integer; version: PAnsiChar;
  recsize: Integer): Integer; external;

function deflateInit2_(var strm: TZStreamRec; level: Integer; method: Integer;
    windowBits: Integer; memLevel: Integer; strategy: Integer; version: PAnsiChar;
  recsize: Integer): Integer; external;

function deflate(var strm: TZStreamRec; flush: Integer): Integer;
  external;

function deflateEnd(var strm: TZStreamRec): Integer; external;

{** inflate routines ********************************************************}

function inflateInit2_(var strm: TZStreamRec; WindowBits: Integer; version: PAnsiChar;
  recsize: Integer): Integer; external;

function inflateInit_(var strm: TZStreamRec; version: PAnsiChar;
  recsize: Integer): Integer; external;

function inflate(var strm: TZStreamRec; flush: Integer): Integer;
  external;

function inflateEnd(var strm: TZStreamRec): Integer; external;

function inflateReset(var strm: TZStreamRec): Integer; external;

{** custom zlib routines ****************************************************}

function DeflateInit(var stream: TZStreamRec; level: Integer): Integer;
function DeflateInit2(var stream: TZStreamRec; level, method, windowBits,
  memLevel, strategy: Integer): Integer;
function InflateInit(var stream: TZStreamRec): Integer;
function InflateInit2(var stream: TZStreamRec; windowBits: Integer): Integer;
function zcalloc(opaque: Pointer; items, size: Integer): Pointer;
procedure zcfree(opaque, block: Pointer);
function CCheck(code: Integer): Integer;
function DCheck(code: Integer): Integer;
procedure MoveI32(const Source; var Dest; Count: Integer); register;

{$ENDIF}

implementation


{$IFDEF USE_ZLIB}

{** custom zlib routines ****************************************************}

function DeflateInit(var stream: TZStreamRec; level: Integer): Integer;
begin
  result := DeflateInit_(stream, level, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function DeflateInit2(var stream: TZStreamRec; level, method, windowBits,
  memLevel, strategy: Integer): Integer;
begin
  result := DeflateInit2_(stream, level, method, windowBits, memLevel, strategy, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function InflateInit(var stream: TZStreamRec): Integer;
begin
  result := InflateInit_(stream, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function InflateInit2(var stream: TZStreamRec; windowBits: Integer): Integer;
begin
  result := InflateInit2_(stream, windowBits, ZLIB_VERSION, SizeOf(TZStreamRec));
end;

function zcalloc(opaque: Pointer; items, size: Integer): Pointer;
begin
  GetMem(result,items * size);
end;

procedure zcfree(opaque, block: Pointer);
begin
  FreeMem(block);
end;

  procedure _memset(P: Pointer; B: Byte; count: Integer); cdecl;
  begin
     FillChar(P^, count, B);
  end;

  procedure _memcpy(dest, source: Pointer; count: Integer); cdecl;
  begin
     Move(source^, dest^, count);
  end;

function _malloc(Size: Integer): Pointer; cdecl;
begin
  Result := AllocMem(Size);
end;

procedure _free(Block: Pointer); cdecl;
begin
  FreeMem(Block);
end;

function CCheck(code: Integer): Integer;
begin
  Result := code;
  if code < 0 then
    raise EZCompressionError.Create('error'); //!!
end;

function DCheck(code: Integer): Integer;
begin
  Result := code;
  if code < 0 then
    raise EZDecompressionError.Create('error');  //!!
end;

procedure MoveI32(const Source; var Dest; Count: Integer); register;
asm
        cmp   ECX,0
        Je    @JustQuit
        push  ESI
        push  EDI
        mov   ESI, EAX
        mov   EDI, EDX
    @Loop:
	Mov   AL, [ESI]
        Inc   ESI
        mov   [EDI], AL
        Inc   EDI
        Dec   ECX
        Jnz   @Loop
        pop   EDI
        pop   ESI
    @JustQuit:
end;

{$ENDIF}


{$I kpUnzipp.Pas}

{******************************************************************}

constructor TVCLUnZip.Create(AOwner: TComponent);
{$IFDEF KPDEMO}
var
   tmpMstr2              : string;
   {$ENDIF}
begin
   inherited Create(AOwner);
   FSortMode := ByNone;
   FDoAll := False;
   RecreateDirs := False;
   FFilesList := TkpStringList.Create;
   FRelativePathList := TkpStringList.Create;
   file_info := CreateNewZipHeader;        { 4/22/02  2.23+ }
   { file_info := TZipHeaderInfo.Create;}  { Moved to Loaded  2/17/02 2.22+ }
   Password := '';
   ZipIsBad := False;
   theZipFile := nil;
   files := nil;
   sortfiles := nil;
   FIncompleteZipMode := izAssumeMulti;
   ecrec := TEndCentral.Create;
   CancelOperation := False;
   PauseOperation := False;
   FKeepZipOpen := False;
   FDoProcessMessages := True;
   FCheckDiskLabels := True;
   StreamZipping := False;
   MemZipping := False;
   MemBuffer := nil;
   MemLen := 0;
   ArchiveIsStream := False;
   Fixing := False;
   FNumDisks := 1;
   CurrentDisk := 0;
   FRetainAttributes := True;
   FBusy := False;
   FTestMode := False;
   FThisVersion := kpThisVersion;
   FThisBuild := kpThisBuild;
   FThisReleaseLevel := kpThisReleaseLevel;
   FReplaceReadOnly := False;                           { 03/09/99  2.17+ }
   FNumSelected := 0;
   FBufferLength := 0;
   FImproperZip := False;
   FBufferedStreamSize := DEF_BUFSTREAMSIZE;
   FEncryptBeforeCompress := False;
   {$IFDEF SUPPORT_UNICODE}
   FOEMConvert := oemFlexible;                               { 11/20/2008 4.50 }
   {$ELSE}
   FOEMConvert := oemAlways;                                 { 2/17/02 2.22+ }
   {$ENDIF}
   FBlockMode := bmStandard;
   {$IFDEF KPDEMO}
   if not (csDesigning in ComponentState) then
   begin
      DR := DelphiIsRunning;
      if not DelphiIsRunning then
      begin
         tmpMStr := LoadStr(IDS_NOTREGISTERED);
         tmpMStr2 := LoadStr(IDS_WARNING);
         //MessageBox(0, StringAsPChar(tmpMStr), StringAsPChar(tmpMStr2), mb_OK);
         DoHandleMessage(IDS_NOTREGISTERED,tmpMStr, tmpMStr2, mb_OK);
         ExitProcess(1);
      end;
   end;
   {$ENDIF}
end;

destructor TVCLUnZip.Destroy;
begin
   ClearZip;
   if (file_info <> nil) then
      file_info.Free;
   if (ecrec <> nil) then
      ecrec.Free;
   { Moved folowing down two lines 7/10/98  2.13 }
   { Due to a user's reporting that it stopped him from getting "Invalid Pointer Operation"
   { errors.  I was unable to duplicate the problem but the move is safe enough  }
   if (FFilesList <> nil) then
      FFilesList.Free;
   if (FRelativePathList <> nil) then
      FRelativePathList.Free;
   inherited Destroy;
end;

procedure TVCLUnZip.Loaded;
begin
   inherited Loaded;
   FThisVersion := kpThisVersion; { Moved here from constructor 4/22/98 2.11 }
   FThisBuild := kpThisBuild;
   FThisReleaseLevel := kpThisReleaseLevel;
   if (file_info <> nil) then     { 4/22/02  2.23+ }
     file_info.OEMConvert := FOEMConvert;
end;

procedure TVCLUnZip.Assign(Source: TPersistent);        { 6/27/99 2.18+ }
begin
   if source is TVCLUnZip then
   begin
      FZipName := TVCLUnZip(Source).GetZipName;
      FDestDir := TVCLUnZip(Source).GetDestDir;
      FRootDir := TVCLUnZip(Source).FRootDir;
      FSortMode := TVCLUnZip(Source).SortMode;
      FRecreateDir := TVCLUnZip(Source).RecreateDirs;
      FOverwriteMode := TVCLUnZip(Source).OverwriteMode;
      FFilesList.Assign(TVCLUnZip(Source).FilesList);
      FRelativePathList.Assign(TVCLUnZip(Source).RelativePathList);
      FDoAll := TVCLUnZip(Source).DoAll;
      FIncompleteZipMode := TVCLUnZip(Source).IncompleteZipMode;
      FKeepZipOpen := TVCLUnZip(Source).KeepZipOpen;
      FDoProcessMessages := TVCLUnZip(Source).DoProcessMessages;
      FRetainAttributes := TVCLUnZip(Source).RetainAttributes;
      FReplaceReadOnly := TVCLUnZip(Source).ReplaceReadOnly;

      FOnStartUnZipInfo := TVCLUnZip(Source).OnStartUnzipInfo;
      FOnFilePercentDone := TVCLUnZip(Source).OnFilePercentDone;
      FOnTotalPercentDone := TVCLUnZip(Source).OnTotalPercentDone;
      FOnStartUnZip := TVCLUnZip(Source).OnStartUnZip;
      FOnEndUnZip := TVCLUnZip(Source).OnEndUnZip;
      FOnPromptForOverwrite := TVCLUnZip(Source).OnPromptForOverwrite;
      FOnSkippingFile := TVCLUnZip(Source).OnSkippingFile;
      FOnBadPassword := TVCLUnZip(Source).OnBadPassword;
      FOnBadCRC := TVCLUnZip(Source).OnBadCRC;
      FOnInCompleteZip := TVCLUnZip(Source).OnInCompleteZip;
      FOnGetNextDisk := TVCLUnZip(Source).OnGetNextDisk;
      FOnUnzipComplete := TVCLUnzip(Source).OnUnZipComplete;
      FOnGetNextBuffer := TVCLUnzip(Source).OnGetNextBuffer;
      FOnFileNameForSplitPart :=  TVCLUnzip(Source).OnFileNameForSplitPart;
   end
   else
      inherited Assign(Source);
end;

procedure TVCLUnZip.SetZipName(ZName: kpWString);
var
   tempZipName           : kpWString;
   Canceled              : Boolean;
   fnamepos                  : integer;
begin
   if (csDesigning in ComponentState) then
   begin                                                { 4/20/98 2.11 }
      FZipName := ZName;
      exit;
   end;
   if kpCompareText(ZName, FZipName) = 0 then
      exit;
   Canceled := False;
   {$IFNDEF KPSMALL}
   if (ZName <> '') and (ZName[Length(ZName)] = '?') then
   begin
      OpenZipDlg := TOpenDialog.Create(Application);
      try
         OpenZipDlg.Title := LoadStr(IDS_OPENZIP);
         OpenZipDlg.Filter := LoadStr(IDS_ZIPNAMEFILTER);
         if kpDirectoryExists(kpExtractFilePath(ZName)) then
            OpenZipDlg.InitialDir := kpExtractFilePath(ZName)
         else
            OpenZipDlg.InitialDir := 'C:\';
         if OpenZipDlg.Execute then
            tempZipName := OpenZipDlg.Filename
         else
            Canceled := True;
      finally
         OpenZipDlg.Free;
      end;
   end
   else
      {$ENDIF}
      tempZipName := ZName;

   if not Canceled then
   begin
      FZipName := tempZipName;
      // Get filename without extension
      tempZipName := kpExtractFileName(FZipName);
      fnamepos := Pos(tempZipName,FZipName)-1;
      fnamepos := fnamepos + Pos('.',Copy(FZipName,fnamepos,Length(FZipName)-fnamepos))-1;
      FZipNameNoExtension := LeftStr(FZipName,fnamepos-1);
      if (sortfiles <> nil) and (FSortMode <> ByNone) then
         sortfiles.Free;
      sortfiles := nil;
      files.Free;
      files := nil;
      filesDate := 0;
      ecrec.Clear;
      theZipFile.Free;
      theZipFile := nil;
      ZipIsBad := False;
      ArchiveIsStream := False;
   end
   else
      raise EUserCanceled.Create(LoadStr(IDS_CANCELZIPNAME));
end;

function TVCLUnZip.GetZipName: kpWString;
begin
   Result := FZipName;
end;

procedure TVCLUnZip.SetArchiveStream(theStream: TkpStream);
begin
   if theStream = nil then
      theZipFile := nil;
   ClearZip;
   theZipFile := theStream;
   if theZipFile <> nil then
   begin
      FKeepZipOpen := True;
      ArchiveIsStream := True;
   end
   else
      ArchiveIsStream := False;
end;

procedure TVCLUnZip.SetDestDir(DDir: kpWString);
{$IFNDEF KPSMALL}
var
   theDir                : String;
   {$ENDIF}
begin
   {$IFNDEF KPSMALL}
   if DDir = '?' then
   begin
      theDir := FDestDir;
      if not DirExists(theDir + '\') then
         GetDirectory(0, theDir);
      if SelectDirectory(theDir, [sdAllowCreate, sdPerformCreate, sdPrompt], 0) then
         FDestDir := theDir
      else
         raise EUserCanceled.Create(LoadStr(IDS_CANCELDESTDIR));
   end
   else
      {$ENDIF}
   FDestDir := DDir;

   if (FDestDir <> '') and (FDestDir[Length(FDestDir)] = '\') then { Remove slash }
      SetLength(FDestDir, Length(FDestDir) - 1);
end;

function TVCLUnZip.GetDestDir: kpWString;
begin
   Result := FDestDir;
end;

procedure TVCLUnZip.SetRootDir(Value: kpWString);
begin
   if Length(Value) > 0 then
   begin
      if RightStr(Value, 1) <> '\' then
         FRootDir := Value + '\'
      else
         FRootDir := Value;
   end
   else
      FRootDir := '';
   FRelativePathList.Clear;
   FRelativePathList.Add(FRootDir);
end;

function TVCLUnZip.StripRelativePath( var path: kpWString ): kpWString;
var
  i: Integer;
begin
  for i := 0 to FRelativePathList.Count-1 do
   begin
      if (kpCompareText(LeftStr(path,Length(FRelativePathList[i])),FRelativePathList[i]) = 0) then
       begin
        Delete(path,1,Length(RelativePathList[i]));
        break;
       end;
   end;
   Result := path;
end;

procedure TVCLUnZip.SetFilesList(Value: TkpStrings);
begin
   FFilesList.Assign(Value);
end;

{ List Properties }

function TVCLUnZip.GetFilename(Index: Integer): TZipFilename;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.filename;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.GetPathname(Index: Integer): TZipPathname;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.Directory;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.GetFullname(Index: Integer): kpWString;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.Directory + finfo.filename;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.GetCompressMethod(Index: Integer): WORD;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.compression_method;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.GetCompressMethodStr(Index: Integer): string;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      {$WARNINGS OFF}
      Result := comp_method[finfo.compression_method];
      {$WARNINGS ON}
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.GetDateTime(Index: Integer): TDateTime;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      try
         Result := FileDateToDateTime(finfo.last_mod_file_date_time)
      except
         Result := Now;
      end;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.GetCrc(Index: Integer): U_LONG;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.Crc32;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.GetCompressedSize(Index: Integer): BIGINT;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.compressed_size;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.GetUnCompressedSize(Index: Integer): BIGINT;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.uncompressed_size;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.GetExternalFileAttributes(Index: Integer): U_LONG;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.external_file_attributes;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.GetIsEncrypted(Index: Integer): Boolean;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.Encrypted;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.GetHasComment(Index: Integer): Boolean;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.HasComment;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.GetZipHasComment: Boolean;
begin
   Result := ecrec.zip_comment_length > 0;
end;

function TVCLUnZip.GetFileComment(Index: Integer): AnsiString;
var
   finfo                 : TZipHeaderInfo;
   crec                  : central_file_header;
   CommentLength         : LongInt;
   RememberModified      : Boolean;
   RememberPosition      : BIGINT;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      with finfo do
      begin
         if HasComment then
         begin
            RememberPosition := 0;
            if Length(finfo.filecomment) = 0 then
            try
               OpenZip;
               RememberPosition := theZipFile.Position;
               theZipFile.Seek(central_offset, soBeginning);
               theZipFile.Read(crec, SizeOf(central_file_header));
               with crec do
               begin
                  theZipFile.Seek(filename_length + extra_field_length, soCurrent);
                  CommentLength := file_comment_length;
                  SetLength(Result, CommentLength);
                  theZipFile.Read(Result[1], CommentLength);
                  RememberModified := ecrec.Modified;
                  SetFileComment(Index, Result);        { Save it in central header }
                  ecrec.Modified := RememberModified;
               end;
            finally
               theZipFile.Seek(RememberPosition, soBeginning);
               If (MultiMode = mmNone) then
                 CloseZip;
            end
            else
               Result := finfo.filecomment;
         end
         else
            Result := '';                               { No comment }
      end;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

procedure TVCLUnZip.ResetFileIsOK(Index: Integer);
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      finfo.FileIsOK := icUNDEFINED;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.CheckArchive: Boolean;
var
   tmpDoAll              : Boolean;
begin
   tmpDoAll := DoAll;
   DoAll := True;
   Result := ProcessIntegrityCheck(-1);
   DoAll := tmpDoAll;
end;

function TVCLUnZip.GetFileIsOK(Index: Integer): Boolean;
var
   tmpDoAll              : Boolean;
begin
   tmpDoAll := DoAll;
   DoAll := False;
   Result := ProcessIntegrityCheck(Index);
   DoAll := tmpDoAll;
end;

function TVCLUnZip.ProcessIntegrityCheck(Index: Integer): Boolean;
var
   n, r                  : Integer;
   s                     : PAnsiChar;
   saveRecreateDirs      : Boolean;
   saveDestDir           : kpWString;
   finfo                 : TZipHeaderInfo;
begin
   r := icUNDEFINED;
   finfo := nil;
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      r := finfo.FileIsOK;
   end
   else
      if (Index <> -1) then
         raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);

   if (Index <> -1) and (r = icFILEOK) then
      Result := True
   else
      if (Index <> -1) and (r = icFILEBAD) then
         Result := False
      else                                              { r = icUNDEFINED }
      begin
         FTestMode := True;
         saveRecreateDirs := RecreateDirs;
         saveDestDir := DestDir;
         Result := False;
         if (Index <> -1) then
            finfo.FileIsOK := icFILEBAD;
         try
            RecreateDirs := True;
            DestDir := ''; { changed from 'c:\TestZip\' 2/14/99 2.17+ }
            s := PAnsiChar(1);                          { Just to be sure it's not nil }
            n := UnzipToBufferByIndex(s, Index);        { Dummy Buffer }
            if (n > 0) then
            begin
               Result := True;
               if (Index <> -1) then
                  finfo.FileIsOK := icFILEOK
               else
               begin
                  if DoAll then
                  begin
                     if (n < Count) then
                        Result := False;
                  end
                  else
                     if (n <> FNumSelected) then
                        Result := False;
               end;
            end;
         finally
            FTestMode := False;
            RecreateDirs := saveRecreateDirs;
            DestDir := saveDestDir;
         end;
      end;
end;

function TVCLUnZip.GetZipComment: AnsiString;
var
   CommentLength         : LongInt;
   RememberModified      : Boolean;
   RememberPosition      : BIGINT;
begin
   if ecrec.zip_comment_length = 0 then
      Result := ''
   else
      with ecrec do
      begin
         if Length(ecrec.ZipComment) = 0 then
         begin
           OpenZip;
           RememberPosition := theZipFile.Position;
            try
               theZipFile.Seek(ZipCommentPos, soBeginning);
               CommentLength := zip_comment_length;
               SetLength(Result, CommentLength);
               theZipFile.Read(Result[1], CommentLength);
               RememberModified := Modified;
               SetZipComment(Result);                   { Save it in ecrec }
               Modified := RememberModified;
            finally
               theZipFile.Seek(RememberPosition, soBeginning);
               If (MultiMode = mmNone) then
                 CloseZip;
            end;
         end
         else
            Result := ecrec.ZipComment;
      end;
end;

procedure TVCLUnZip.SetZipComment(theComment: AnsiString);
begin
      ecrec.SetNewZipComment(theComment);
      ecrec.Modified := True;
end;

procedure TVCLUnZip.SetFileComment(Index: Integer; theComment: AnsiString);
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      finfo.filecomment := theComment;
      ecrec.Modified := True;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

{ 3/10/98  2.03}
{ These are overriden in VCLZip }

function TVCLUnZip.GetMultiMode: TMultiMode;
begin
   Result := FMultiMode;
end;

{ 3/10/98  2.03}

procedure TVCLUnZip.SetMultiMode(Value: TMultiMode);
begin
   FMultiMode := Value;
end;

function TVCLUnZip.GetDiskNo(Index: Integer): Integer;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.disk_number_start + 1;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

function TVCLUnZip.GetSelected(Index: Integer): Boolean;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      Result := finfo.Selected;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

procedure TVCLUnZip.SetSelected(Index: Integer; Value: Boolean);
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
      if (finfo.Selected <> Value) then
      begin
         finfo.Selected := Value;
         if (Value = True) then
            Inc(FNumSelected)
         else
            Dec(FNumSelected);
      end;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
end;

procedure TVCLUnZip.GetDecryptHeaderPtr(Index: Integer; dhPtr: BytePtr);
var
   dhTemp                : DecryptHeaderType;
   i                     : Integer;
   {$IFNDEF ISDELPHI}
   finfo                 : TZipHeaderInfo;
   lrec                  : local_file_header;
   {$ENDIF}
begin
   if (Index < 0) or (Index >= Count) then
   begin
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
      exit;
   end;
   if (not IsEncrypted[Index]) then
   begin
      for i := 0 to 11 do
      begin
         dhPtr^ := 0;
         Inc(dhPtr);
      end;
      exit;
   end;
   {$IFDEF ISDELPHI}
   dhTemp := GetDecryptHeader(Index);
   for i := 0 to 11 do
   begin
      dhPtr^ := dhTemp[i];
      Inc(dhPtr);
   end;
   {$ELSE}
   finfo := sortfiles.Items[Index] as TZipHeaderInfo;
   with finfo do
   begin
      try
         OpenZip;
         theZipFile.Seek(relative_offset, soBeginning);
         theZipFile.Read(lrec, SizeOf(local_file_header));
         with lrec do
         begin
            theZipFile.Seek(filename_length, soCurrent);
            theZipFile.Read(dhTemp, SizeOf(DecryptHeaderType));
         end;
         for i := 0 to 11 do                            { added this loop 10/23/99  2.20b3+ }
         begin
            dhPtr^ := dhTemp[i];
            Inc(dhPtr);
         end;
      finally
        If (MultiMode = mmNone) then
           CloseZip;
      end;
   end;
   {$ENDIF}
end;

{$IFDEF ISDELPHI}

function TVCLUnZip.GetDecryptHeader(Index: Integer): DecryptHeaderType;
var
   finfo                 : TZipHeaderInfo;
   lrec                  : local_file_header;
   i                     : Integer;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   if (IsEncrypted[Index]) then
      with finfo do
      begin
         try
            OpenZip;
            theZipFile.Seek(relative_offset, soBeginning);
            theZipFile.Read(lrec, SizeOf(local_file_header));
            with lrec do
            begin
               theZipFile.Seek(filename_length, soCurrent);
               theZipFile.Read(Result, SizeOf(DecryptHeaderType));
            end;
         finally
           If (MultiMode = mmNone) then
              CloseZip;
         end
      end
   else
      for i := 0 to 11 do
         Result[i] := 0;
end;
{$ENDIF}

function TVCLUnZip.GetZipSize: BIGINT;
begin
   Result := 0;
   if FZipName <> '' then
   begin
      OpenZip;
      try
         Result := theZipFile.Size;
      finally
        If (MultiMode = mmNone) then
           CloseZip;
      end;
   end;
end;

function TVCLUnZip.GetIsZip64: Boolean;
begin
  Result := (ecrec.offset_central >= $FFFFFFFF) or (ecrec.num_entries >= $FFFF) or (sortfiles.isZip64);
end;

procedure TVCLUnZip.WriteNumDisks(NumberOfDisks: Integer);
begin
   FNumDisks := NumberOfDisks;
end;

{ Added these so that they could be overriden in VCLZip 3/11/98  2.03 }

function TVCLUnZip.GetCheckDiskLabels: Boolean;
begin
   Result := FCheckDiskLabels;
end;

procedure TVCLUnZip.SetCheckDiskLabels(Value: Boolean);
begin
   FCheckDiskLabels := Value;
end;

function TVCLUnZip.UnZip: Integer;
var
  OldBusy: Boolean;
begin
   OldBusy := SetBusy(True);
   CancelOperation := False;
   Result := 0;
   try
      if DestDir <> '?' then
      begin
         { Following Changed from OpenZip which was being bypassed. 03/15/01  2.21+ }
         ReadZip;
         OpenZip;  { Make sure it's open because ReadZip closes it again }
         Result := UnzipFiles(theZipFile);
         CloseZip;
      end;
   finally
      SetBusy(OldBusy);
      CancelOperation := False;
   end;
end;

function TVCLUnZip.UnZipSelected: Integer;
begin
   UnZippingSelected := True;
   Result := UnZip;
   UnZippingSelected := False;
end;

procedure TVCLUnZip.ClearSelected;
var
   i                     : Integer;
begin
   for i := 0 to Count - 1 do
      Selected[i] := False;
   FNumSelected := 0;
end;

function TVCLUnZip.SetBusy( value: Boolean ): Boolean;
begin
  Result := FBusy;
  FBusy := value;
end;

function TVCLUnZip.SetOperationMode( value: TOperationMode ): TOperationMode;
begin
  Result := FOperationMode;
  FOperationMode := value;
end;


function TVCLUnZip.GetEncryptionStrength(Index: Integer): TEncryptStrength;
var
   finfo                 : TZipHeaderInfo;
begin
   if (Index > -1) and (Index < Count) then
   begin
      finfo := sortfiles.Items[Index] as TZipHeaderInfo;
   end
   else
      raise EListError.CreateFmt(LoadStr(IDS_INDEXOUTOFRANGE), [Index]);
   Result := finfo.EncryptionStrength;
end;

function TVCLUnZip.UnZipToStream(theStream: TkpStream; FName: kpWString): Integer;
var
  OldBusy: Boolean;
begin
   Result := 0;
   if (Trim(FName) = '') or (theStream = nil) then
      exit;
   OldBusy := SetBusy(True);
   ZipStream := theStream;
   CancelOperation := False;
   StreamZipping := True;
   OpenZip;
   FilesList.Clear;
   FilesList.Add(FName);
   try
      Result := UnzipFiles(theZipFile);
   finally
      StreamZipping := False;
      CloseZip;
      SetBusy(OldBusy);
      CancelOperation := False;
   end;
end;

{$IFNDEF INT64STREAMS}
function TVCLUnZip.UnZipToStream(theStream: TMemoryStream; FName: kpWString): Integer; 
var
   InternalStream:tkpHugeMemoryStream;
   OldBusy: Boolean;
begin
   Result := 0;
   if (Trim(FName) = '') or (theStream = nil) then
      exit;
   OldBusy := SetBusy(True);
   InternalStream:=tkpHugeMemoryStream.Create;
   try
     result:=UnzipToStream(InternalStream,FName);
     TheStream.Position:=0;
     InternalStream.Position:=0;
     internalStream.SaveToStream(theStream);
   finally
     InternalStream.Free;
     SetBusy(OldBusy);
   end;
end;

function TVCLUnZip.UnZipToStreamByIndex(theStream: TStream; Index: Integer): Integer;
var
  InternalStream: TkpHugeMemoryStream;
  OldBusy: Boolean;
begin
   Result := 0;
   if (theStream = nil) then
      exit;
   OldBusy := SetBusy(True);
   InternalStream:=tkpHugeMemoryStream.Create;
   try
     result:=UnzipToStreamByIndex(InternalStream,Index);
     TheStream.Position:=0;
     InternalStream.Position:=0;
     internalStream.SaveToStream(theStream);
   finally
     InternalStream.Free;
     SetBusy(OldBusy);
   end;
end;
{$ENDIF}

function TVCLUnZip.UnZipToStreamByIndex(theStream: TkpStream; Index: Integer): Integer;
var
  OldBusy: Boolean;
begin
   Result := 0;
   if (theStream = nil) then
      exit;
   OldBusy := SetBusy(True);
   ZipStream := theStream;
   CancelOperation := False;
   StreamZipping := True;
   OpenZip;
   FilesList.Clear;
   try
      Selected[Index] := True;
      UnZippingSelected := True;
      Result := UnzipFiles(theZipFile);
   finally
      StreamZipping := False;
      CloseZip;
      SetBusy(OldBusy);
      CancelOperation := False;
      UnZippingSelected := False;
   end;
end;

function TVCLUnZip.UnZipToBuffer(var Buffer: PAnsiChar; FName: kpWString): Integer;
var
  OldBusy: Boolean;
begin
   Result := 0;
   if (Trim(FName) = '') then
      exit;
   OldBusy := SetBusy(True);
   MemZipping := True;
   OpenZip;                                             { 12/4/98  2.17P+ }
   FilesList.Clear;
   FilesList.Add(FName);
   if (Buffer = nil) then
      MemBuffer := nil
   else
      MemBuffer := Buffer;
   try
      Result := UnzipFiles(theZipFile);
      if (Buffer = nil) then
         Buffer := MemBuffer;
   finally
      MemZipping := False;
      CloseZip;
      SetBusy(OldBusy);
      CancelOperation := False;
      MemBuffer := nil;
   end;
end;

function TVCLUnZip.UnZipToBufferByIndex(var Buffer: PAnsiChar; Index: Integer): Integer;
var
  OldBusy: Boolean;
begin
   OldBusy := SetBusy(True);
   MemZipping := True;
   OpenZip;                                             { 12/4/98  2.17P+ }
   FilesList.Clear;
   if (Buffer = nil) then
      MemBuffer := nil
   else
      MemBuffer := Buffer;
   try
      if Index > -1 then
         Selected[Index] := True;
      if not DoAll then
         UnZippingSelected := True;
      Result := UnzipFiles(theZipFile);
      if (Buffer = nil) then
         Buffer := MemBuffer;
   finally
      MemZipping := False;
      CloseZip;
      SetBusy(OldBusy);
      CancelOperation := False;
      MemBuffer := nil;
      UnZippingSelected := False;
   end;
end;

procedure TVCLUnZip.OpenZip;
{$IFDEF KPDEMO}
var
   tmpMStr2              : string;
   {$ENDIF}
begin
   {$IFDEF KPDEMO}
   if not (csDesigning in ComponentState) then
   begin
      if not DelphiIsRunning then
      begin
         tmpMStr := LoadStr(IDS_NOTREGISTERED);
         tmpMStr2 := LoadStr(IDS_WARNING);
         //MessageBox(0, StringAsPChar(tmpMStr), StringAsPChar(tmpMStr2), mb_OK);
         DoHandleMessage(IDS_NOTREGISTERED,StringAsPChar(tmpMStr), StringAsPChar(tmpMStr2), mb_OK);
         Abort;
      end;
   end;
   {$ENDIF}
   if theZipFile = nil then
      theZipFile := TLFNFileStream.CreateFile(FZipName, fmOpenRead or fmShareDenyWrite,
         FFlushFilesOnClose, BufferedStreamSize);
   if files = nil then
      GetFileInfo(theZipFile)
   else
      if (not ArchiveIsStream) and
         (FileDateToDateTime(FileGetDate(TLFNFileStream(theZipFile).Handle)) <> filesDate) then
         GetFileInfo(theZipFile);
end;

procedure TVCLUnZip.CloseZip;
begin
   { Policy is to never free ArchiveStream, that's up to the application
     Application should set ArchiveStream := nil and close it's own reference
     to the stream
     01/21/02  2.22+   }
   if (not FKeepZipOpen) and (not ArchiveIsStream) then
   begin
      theZipFile.Free;
      theZipFile := nil;
   end;
end;

procedure TVCLUnZip.AskForNewDisk(NewDisk: Integer);
begin
   SwapDisk(NewDisk);
end;

function TVCLUnZip.SwapDisk(NewDisk: Integer): TkpStream;
{ NewDisk is the disk number that the user sees. Starts with 1 }
var
   tmpZipName            : kpWString;
   spType                : TSplitPartType;
   
   function CurrentDiskLabel(NewDisk: Integer): Boolean;
   var
      VolName            : string;
      Disk               : String;
   begin
      {Need to check disk label here}
      if MultiMode = mmSpan then
      begin
         Disk := UpperCase(LeftStr(FZipName, 3));
         VolName := GetVolumeLabel(Disk);
         if RightStr(VolName, 3) = Format('%3.3d', [NewDisk]) then
            Result := True
         else
            Result := False;
      end
      else
         Result := True;
   end;

begin
   theZipFile.Free;
   theZipFile := nil; {1/27/98 to avoid GPF when Freeing file in CloseZip. v2.00+}
   tmpZipName := FZipName;
   if (MultiMode = mmBlocks) then
   begin
    if (FOperationMode = omUnZip) and (NewDisk = NumDisks) then
      spType := spLast
    else if (NewDisk = 1) then
      spType := spFirst
    else
      spType := spMiddle;
    tmpZipName := FZipNameNoExtension;
    DoFileNameForSplitPart(tmpZipName, NewDisk, spType);
   end
   else
   repeat
      repeat
         DoGetNextDisk(NewDisk, tmpZipName);
      until (not CheckDiskLabels) or (tmpZipName = '') or (CurrentDiskLabel(NewDisk));
      if tmpZipName = '' then
         raise EUserCanceled.Create('User canceled loading new disk.');
   until FileExists(tmpZipName); {1/29/98 To avoid problem if file doesn't exist}
   theZipFile := TLFNFileStream.CreateFile(tmpZipName, fmOpenRead or fmShareDenyNone, False, BufferedStreamSize);
   CurrentDisk := NewDisk - 1;                          { CurrentDisk starts with 0 }
   filesDate := FileDateToDateTime(FileGetDate(TLFNFileStream(theZipFile).Handle));
   FZipName := tmpZipName;
   Result := theZipFile;
end;

procedure TVCLUnZip.NewDiskEvent(Sender: TObject; var S: TkpStream);
begin
   SwapDisk(CurrentDisk + 2);
   S := theZipFile;
end;

function TVCLUnZip.CreateNewZipHeader: TZipHeaderInfo;
begin
  Result := TZipHeaderInfo.Create;
  Result.OEMConvert := FOEMConvert;
end;

procedure TVCLUnZip.ClearZip;
var
   SaveKeepZipOpen       : Boolean;
begin
   SaveKeepZipOpen := FKeepZipOpen;
   FKeepZipOpen := False;
   CloseZip;
   FKeepZipOpen := SaveKeepZipOpen;
   if (sortfiles <> nil) and (sortfiles <> files) then
      sortfiles.Free;
   files.Free;
   files := nil;
   sortfiles := nil;
   ecrec.Clear;
   ZipIsBad := False;
   filesDate := 0;
   FNumDisks := 1;
   MultiMode := mmNone;
   if not ArchiveIsStream then
      FZipName := '';
end;

procedure TVCLUnZip.ReadZip;
var
   TryAgain              : Boolean;
   RememberKeepZipOpen   : Boolean;
   OldBusy               : Boolean;
   OldOperationMode      : TOperationMode;
begin
   CancelOperation := False;
   FImproperZip := False;
   OldBusy := SetBusy(True);
   OldOperationMode := SetOperationMode(omUnZip);
   try
    repeat
      TryAgain := False;
      try
         OpenZip;
      except
         on EIncompleteZip do
         begin
            { zip file must be closed in this case  1/25/00 2.20+  }
            RememberKeepZipOpen := KeepZipOpen;
            KeepZipOpen := False;
            CloseZip;
            KeepZipOpen := RememberKeepZipOpen;
            if Assigned(FOnIncompleteZip) then
               tryagain := True;
         end;
      else
         begin
            ClearZip;
            raise; { raise the exception so the application knows }
         end;
      end;
    until (TryAgain = False);
   finally
     CloseZip;
     SetOperationMode(OldOperationMode);
     SetBusy(OldBusy);
   end;
end;

procedure TVCLUnZip.GetFileInfo(infoFile: TkpStream);
var
   finfo                 : TZipHeaderInfo;

   function ReadZipHardWay: Boolean;
   var
      sig                : Byte;
      AmtRead            : BIGINT;
      CancelCheck        : LongInt;
      VerNeeded          : WORD;
   begin
      Result := False;
      if ZipIsBad then  { We've already called this procedure }
        exit;
      ZipIsBad := True;
      FImproperZip := True;
      CancelCheck := 0;
      if files <> nil then
      begin
         files.Free;
         files := nil;
         sortfiles := nil; { to avoid GPF in ClearZip if badzipfile 10/4/01  2.22+ }
      end;
      { 4/19/98  2.11  skip past any sigs in code if sfx }
      if (kpCompareText(kpExtractFileExt(FZipName), '.EXE') = 0) then
         infoFile.Seek(14000, soBeginning)
      else
         infoFile.Seek(0, soBeginning);
      AmtRead := infoFile.Read(sig, SizeOf(sig));
      repeat
         repeat   
            repeat
               repeat
                  while (AmtRead = SizeOf(sig)) and (sig <> LOC4) do
                  begin
                     Inc(CancelCheck);
                     if (DoProcessMessages) and (CancelCheck mod 10240 = 0) then
                     begin
                        YieldProcess;
                        if CancelOperation then
                        begin
                           CancelOperation := False;
                           raise EUserCanceled.Create(LoadStr(IDS_CANCELOPERATION));
                        end;
                        If PauseOperation then
                          DoPause;
                     end;
                     AmtRead := infoFile.Read(sig, SizeOf(sig));
                  end;
                  if AmtRead <> SizeOf(sig) then
                     Result := False
                  else
                     AmtRead := infoFile.Read(sig, SizeOf(sig));
               until (AmtRead <> SizeOf(sig)) or (sig = LOC3);
               AmtRead := infoFile.Read(sig, SizeOf(sig));
            until (AmtRead <> SizeOf(sig)) or (sig = LOC2);
            AmtRead := infoFile.Read(sig, SizeOf(sig));
         until (AmtRead <> SizeOf(sig)) or (sig = LOC1);
         AmtRead := infoFile.Read(VerNeeded, SizeOf(VerNeeded));  { Make sure not a sig in SFX Code }
      until (AmtRead <> SizeOf(VerNeeded)) or (HIBYTE(VerNeeded) < 10);
      if (AmtRead <> SizeOf(VerNeeded)) or (HIBYTE(VerNeeded) > 10) then
         exit;
      infoFile.Seek(-6, soCurrent);
      files := TSortedZip.Create(DupError);
      files.SortMode := ByNone;                         { Force for later compare }
      sortfiles := files;                               { added 3/10/98 2.03 }
      finfo.Free;
      finfo := CreateNewZipHeader;
      while finfo.ReadLocalFromStream(infoFile) do
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
         files.AddObject(finfo);
         if finfo.HasDescriptor then
            infoFile.Seek(finfo.compressed_size + finfo.Lextra_field_length +
               SizeOf(DataDescriptorType), soCurrent)
         else
            infoFile.Seek(finfo.compressed_size + finfo.Lextra_field_length, soCurrent);
         finfo := CreateNewZipHeader;
      end;
      finfo.Free;
      finfo := nil;

      ecrec.this_disk := 0;
      CurrentDisk := 0;
      ecrec.offset_central := infoFile.Seek(0, soCurrent); {assume}
      ecrec.num_entries := Count;

      FNumDisks := ecrec.this_disk + 1;

      Result := True;
   end;

   procedure GetDescriptorInfo;
   var
      savepos            : BIGINT;
      lrecord            : local_file_header;
      drecord            : DataDescriptorType;
   begin
      with finfo do
      begin
         savepos := infoFile.Seek(0, soCurrent);
         infoFile.Seek(relative_offset, soBeginning);
         infoFile.Read(lrecord, SizeOf(lrecord));
         infoFile.Seek(lrecord.filename_length + lrecord.compressed_size +
            lrecord.extra_field_length, soCurrent);
         infoFile.Read(drecord, SizeOf(drecord));
         infoFile.Seek(savepos, soBeginning);
      end;
   end;

var
   tmpfinfo, rem_info    : TZipHeaderInfo;
   i                     : Integer;
   Index                 : Integer;
   {sig                   : U_LONG;}
   saveOffset            : BIGINT;
   RootPath              : kpWString;
   tmpStream             : TkpStream;
   recOK                 : Boolean;
   InfoFromInfoFile      : Boolean;
   rem_efl               : Word;       {1/15/00 2.20+}
   CommentLength         : LongInt;    {2/7/00 2.20+}
   zcomment              : AnsiString;     {2/7/00 2.20+}
   trys                  : Integer;
   OldOperationMode      : TOperationMode;
   {$IFNDEF WIN32}
   Disk                  : Integer;
   {$ENDIF}
begin
   OldOperationMode := SetOperationMode(omUnZip);
  try
   tmpStream := nil;
   rem_info := nil;
   InfoFromInfoFile := False;
   if (not ArchiveIsStream) then
      filesDate := FileDateToDateTime(FileGetDate(TLFNFileStream(infoFile).Handle))
   else
      filesDate := Now;
   if Count > 0 then
   begin  { force sortfiles to nil, avoid GPF in ClearZip if bad zip file 10/5/01  2.22+ }
      if (sortfiles <> nil) and (FSortMode <> ByNone) then
         sortfiles.Free;
      sortfiles := nil;
      files.Free;
      files := nil;
   end;

   recOK := ecrec.ReadFromStream(infoFile);
   { Some things that would indicate a corrupt end of central }
   { 10/5/01  2.22+ }
{    if  (ecrec.this_disk > 999)
     or (ecrec.start_central_disk > 999)
     or (ecrec.start_central_disk > ecrec.this_disk) then
         recOK := false;
}
    if  (ecrec.start_central_disk > ecrec.this_disk) then
         recOK := false;
  if (not recOK) then
   begin
      if (not ArchiveIsStream) and (kpFileExists(kpChangeFileExt(ZipName, '.zfc'))) then
      begin
         tmpStream := infoFile;
         infoFile := TkpFileStream.Create(kpChangeFileExt(ZipName, '.zfc'), fmOpenRead);
         recOK := ecrec.ReadFromStream(infoFile);
         if recOK then
            InfoFromInfoFile := True
         else
         begin
            infoFile.Free;
            infoFile := tmpStream;
         end;
      end;
   end;

   if (not recOK) then { False = couldn't find the end central directory }
   begin
      if not Fixing then
      begin
         if (Assigned(FOnIncompleteZip)) then
            FOnIncompleteZip(Self, FIncompleteZipMode);
         if (FIncompleteZipMode = izAssumeNotAZip) then
            raise ENotAZipFile.Create(LoadStr(IDS_INVALIDZIP));
         if (FIncompleteZipMode = izAssumeMulti) then
         begin { Just return and let them try again with the right disk }
            raise EIncompleteZip.Create(LoadStr(IDS_INCOMPLETEZIP));
         end;
      end;
      if ((FIncompleteZipMode = izAssumeBad) or (Fixing)) then
      begin
         if not ReadZipHardWay then { False = there's no central directories }
         begin
            ClearZip;
            raise EBadZipFile.Create(LoadStr(IDS_INVALIDZIP));
         end;
      end;
   end
   else
   begin                                                { ************* }
      CurrentDisk := ecrec.this_disk;
      if InfoFromInfoFile then
         CurrentDisk := 0;
      if ecrec.this_disk > 0 then
      begin
         { allow MultiMode to be set by user/developer before opening file }
         if (MultiMode = mmNone) then
         begin
           RootPath := UpperCase(LeftStr(FZipName, 3));
           if RootPath[2] <> ':' then
              MultiMode := mmBlocks
           else
              begin
                 if (isDriveRemovable(RootPath)) then
                    MultiMode := mmSpan
                 else
                    MultiMode := mmBlocks;
              end;
         end;
      end
      else
         MultiMode := mmNone;
      { Moved the following down lower 3/10/98  2.03 }
      {     if (ecrec.this_disk > 0) and (ecrec.ZipHasComment) then
         GetZipComment;  }
      { added check for MultiMode <> mmNone because of IMPLODED files that have this_disk = 0 but
      start_central_disk = 1   8/17/98 2.15 }
      if ecrec.num_entries > 0 then
      begin
         if ((not InfoFromInfoFile) and (MultiMode <> mmNone) and (ecrec.start_central_disk <>
            CurrentDisk)) then
            infoFile := SwapDisk(ecrec.start_central_disk + 1);
         if (InfoFromInfoFile) then
            infoFile.Seek(0, soBeginning)
         else
            infoFile.Seek(ecrec.offset_central, soBeginning);
      end;
   end;                                                 { ************* }

   if (Count = 0) then                                  { added test 02/14/99  2.17+ }
   begin
      files := TSortedZip.Create(DupError);
      files.SortMode := ByNone;
      sortfiles := files;                               { added 3/10/98 2.03 }
   end;

   FNumDisks := ecrec.this_disk + 1;
   rem_efl := 0;  { Code to handle extra_field_len with no extra field  1/12/00 2.20+ }
   i := 0;
   while i < ecrec.num_entries do  {for i := 0 to ecrec.num_entries - 1 do}
   begin
     If DoProcessMessages then { added 1/28/2003  3.0 beta }
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
      finfo := CreateNewZipHeader;
      trys := 0;
      Repeat
        if (ZipIsBad) or (MultiMode = mmNone) then
           recOK := finfo.ReadCentralFromStream(infoFile, nil)
        else
           recOK := finfo.ReadCentralFromStream(infoFile, NewDiskEvent);
        Inc(trys);
        if (not recOK) and (trys = 1) and (rem_efl > 0) then
        begin
           if rem_info <> nil then
              rem_info.Cextra_field_length := 0;
           infoFile.Seek(-rem_efl, soCurrent);
           rem_info := nil;
        end;
      Until (recOK) or (trys = 2) or (rem_efl = 0);

      rem_efl := 0;
      if not recOK then
      begin
         if ZipIsBad then  { We've already called ReadZipHardWay }
          begin            { Must not be complete set of centrals }
           finfo.Free;
           finfo := nil;
           break;          { break from while loop }
          end;
         { The following added 11/17/99  2.20b5+ }
{ Since we are past looking for the end of central, we know we have a zip file.
  We'll go ahead and try to ReadZipHardWay and set the new flag property called
  ImproperZip so that it is known that something isn't quite kosher - since no
  call to IncompleteZip is made now.  A spanned zip set will always fail a call
  to ReadZipHardWay.  }
            if (MultiMode <> mmNone) or (not ReadZipHardWay) then
            begin
               finfo.Free;
               finfo := nil;
               ClearZip;
               raise EBadZipFile.Create(LoadStr(IDS_INVALIDZIP));
            end
           else
            begin
              i := 0;    {calling ReadZipHardWay brings us back to 1st central again}
              continue;  {try reading centrals again}
            end;
         {--------------------------  end of mod 11/17/99 2.20b5+}
      end;
      if ZipIsBad then
      begin
         if (files.Search(Pointer(finfo), Index)) then
         begin
            tmpfinfo := files.Items[Index] as TZipHeaderInfo;
            saveOffset := tmpfinfo.relative_offset;
            tmpfinfo.Assign(finfo);
            tmpfinfo.relative_offset := saveOffset;
            rem_info := tmpfinfo;
            { 3/28/00 2,21p1+ }
            infoFile.Seek(finfo.Cextra_field_length + finfo.file_comment_length, soCurrent);
            finfo.Free;
            finfo := nil;
         end
         else { don't mess with it if there's no local header }
         begin
            finfo.Free;
            finfo := nil;
            Inc(i);
            continue;
         end;
      end;
      if not ZipIsBad then
       begin
        try
           files.AddObject(finfo); { If ZipIsBad then it has already been added }
        except
           if (ReadZipHardWay) then
            begin
              i := 0;
              continue;
            end
           else
            begin
               finfo.Free;
               finfo := nil;
               ClearZip;
               raise EBadZipFile.Create(LoadStr(IDS_INVALIDZIP));
            end;
        end;
       end;
      if (ecrec.this_disk > 0) and (finfo.HasComment) then
         GetFileComment(i);
      if (finfo <> nil) then  { 3/28/00 2,21p1+ }
      begin
        infoFile.Seek(finfo.Cextra_field_length + finfo.file_comment_length, soCurrent);
        if (finfo.Cextra_field_length > 0) then
        begin
           rem_efl := finfo.Cextra_field_length;
           rem_info := finfo;
        end;
      end
      else
         rem_efl := 0;
      Inc(i);
   end;                                                 { For loop }

   { Moved the following to here from further up since GetZipComment could not be called
     until the central directories were read  3/10/98  2.03 }
   if (ecrec.this_disk > 0) and (ecrec.ZipHasComment) then
   begin
      if (ecrec.this_disk <> CurrentDisk) and (not InfoFromInfoFile) then
         SwapDisk(ecrec.this_disk + 1);
      if (not InfoFromInfoFile) then
        GetZipComment
      else
       begin
        infoFile.Seek(ecrec.ZipCommentPos, soBeginning);
        CommentLength := ecrec.zip_comment_length;
        SetLength(zcomment, CommentLength);
        infoFile.Read(zcomment[1], CommentLength);
        SetZipComment(zcomment);  { Save it in ecrec }
        ecrec.Modified := False;
       end;
   end;
   if (not InfoFromInfoFile) then
      CurrentDisk := ecrec.this_disk
   else
      CurrentDisk := 0;
   Sort(FSortMode);
   if InfoFromInfoFile then
   begin                                                { Set things back correctly }
      infoFile.Free;
      infoFile := tmpStream;
   end;
  finally
    setOperationMode(OldOperationMode);
  end;
end;


procedure TVCLUnZip.Sort(SMode: TZipSortMode);
var
   i                     : Integer;
begin
   if (sortfiles <> nil) and (sortfiles <> files) and (FSortMode <> ByNone) then
      sortfiles.Free;
   if SMode = ByNone then
      sortfiles := files
   else
   begin
      sortfiles := TSortedZip.Create(dupAccept);
      sortfiles.SortMode := SMode;
      sortfiles.DestroyObjects := False;
      for i := 0 to Count - 1 do
         sortfiles.AddObject(files.Items[i] as TZipHeaderInfo);
   end;
   FSortMode := SMode;
end;

procedure TVCLUnZip.CancelTheOperation;
begin
   CancelOperation := True;
   RestartTheOperation;
end;

procedure TVCLUnZip.PauseTheOperation;
begin
  PauseOperation := True;
  CancelOperation := False;
end;

procedure TVCLUnZip.RestartTheOperation;
begin
  PauseOperation := False;
end;

procedure TVCLUnZip.DoPause;
begin
  Repeat
     Sleep(1000);
     YieldProcess;
  Until (PauseOperation = False);
end;

function TVCLUnZip.GetCount: Integer;
begin
   if files <> nil then
      Result := files.Count
   else
      Result := 0;
end;

procedure TVCLUnZip.FillList(FilesList: TStrings);
var
   AddBuffer             : kpWString;
   i                     : Integer;
   ZipTimeStr            : kpWString;
   ZipDate               : TDateTime;
   ZipDateStr            : kpWString;
   finfo                 : TZipHeaderInfo;
   encryptmark, commentmark: String[1];
begin
   FilesList.Clear;
   for i := 0 to Count - 1 do
   begin
      finfo := sortfiles.Items[i] as TZipHeaderInfo;
      try
         ZipDate := FileDateToDateTime(finfo.last_mod_file_date_time)
      except
         ZipDate := Now;
      end;
      ZipDateStr := Format('%8s', [FormatDateTime('mm/dd/yy', ZipDate)]);
      ZipTimeStr := Format('%7s', [FormatDateTime('hh:mmam/pm', ZipDate)]);
      if (finfo.general_purpose_bit_flag and 1) <> 0 then
         encryptmark := '#'
      else
         encryptmark := '';
      if finfo.HasComment then
         commentmark := '@'
      else
         commentmark := '';
      {$WARNINGS OFF}
      with finfo do
         AddBuffer := filename + encryptmark + commentmark + #9 + ZipDateStr + #9 + ZipTimeStr
            + #9
            + Format('%8d', [uncompressed_size]) + #9 + Format('%8d', [compressed_size]) + #9
            + Format('%3d%s', [CBigRate(uncompressed_size, compressed_size), '%']) + #9
         + comp_method[compression_method] + #9 + Directory;
      FilesList.Add(kpLowerCase(AddBuffer));
      {$WARNINGS ON}
   end;
end;

procedure TVCLUnZip.SetThisVersion(v: Integer);
begin
   FthisVersion := kpThisVersion;
end;

procedure TVCLUnZip.SetThisBuild(b: Integer);
begin
   FthisBuild := kpThisBuild;
end;

procedure TVCLUnZip.SetThisReleaseLevel(l: String);
begin
   FthisReleaseLevel := kpThisReleaseLevel;
end;

function TVCLUnZip.DoHandleMessage(const MessageID: Integer; const Msg1: String; const Msg2: String; const flags: LongWord): Integer;
begin
  If (Assigned(FOnHandleMessage)) then
    FOnHandleMessage(self,MessageID,Msg1,Msg2,flags,Result)
  else
    Result := DefaultHandleMessage(MessageID,Msg1,Msg2,flags);
end;

function TVCLUnZip.DefaultHandleMessage(const MessageID: Integer; const Msg1: String; const Msg2: String; const flags: LongWord): Integer;
var
  m1, m2: PChar;
begin
     m1 := PChar(Msg1);
     m2 := Pchar(Msg2);
     Result := MessageBox(0,m1,m2,flags);
     //StrDispose(m1);
     //StrDispose(m2);
end;


procedure TVCLUnZip.DoGetNextDisk(NextDisk: Integer; var FName: kpWString);
begin
  if (Assigned(FOnGetNextDisk)) then
    FOnGetNextDisk(self,NextDisk,FName)
  else
    DefaultGetNextDisk(self,NextDisk,FName);
end;

procedure TVCLUnZip.DefaultGetNextDisk(Sender: TObject;
   NextDisk: Integer; var FName: kpWString);
var
   MsgArray              : array[0..255] of Char;
   {$IFNDEF KPSMALL}
   SaveCursor            : TCursor;
   {$ENDIF}
begin
   if MultiMode = mmSpan then
   begin
      {$IFNDEF KPSMALL}
      SaveCursor := Screen.Cursor;
      Screen.Cursor := crDefault;
      try
      {$ENDIF}
      StrPCopy(MsgArray, LoadStr(IDS_INSERTDISK) + IntToStr(NextDisk) +
         LoadStr(IDS_OFMULTISET));
      //if MessageBox(0, MsgArray, '', MB_OKCANCEL) = IDCANCEL then
      if (DoHandleMessage(IDS_INSERTDISK, MsgArray, '', MB_OKCANCEL) = IDCANCEL) then
         FName := '';
      {$IFNDEF KPSMALL}
      finally
        Screen.Cursor := SaveCursor;
      end;
      {$ENDIF}
   end;
end;

procedure TVCLUnZip.DoFileNameForSplitPart(var FName: kpWString; PartNum: Integer;
                SplitType: TSplitPartType);
begin
  if (Assigned(FOnFileNameForSplitPart)) then
    FOnFileNameForSplitPart(self,FName,PartNum,SplitType)
  else
    DefaultFileNameForSplitPart(self,FName,PartNum,SplitType);
end;

procedure TVCLUnZip.DefaultFileNameForSplitPart(Sender: TObject; var FName: kpWString; PartNum: Integer;
                SplitType: TSplitPartType);
begin
  if (BlockMode = bmStandard) then
  begin
    if (SplitType = spLast) then
      FName := Fname + '.zip'
    else
      FName := FName + '.' + Format('z%2.2d', [PartNum]);
  end
  else
      FName := FName + '.' + Format('%3.3d', [PartNum]);
end;

procedure TVCLUnZip.ZLibDecompressStream(inStream, outStream: TStream; HttpCompression: Boolean = False);
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
    DCheck(InflateInit2(zstream,-15))
  else
    DCheck(InflateInit(zstream));

  inSize := inStream.Read(inBuffer, bufferSize);
  Inc(done,inSize);

  while inSize > 0 do
  begin
    zstream.next_in := inBuffer;
    zstream.avail_in := inSize;

    repeat
      zstream.next_out := outBuffer;
      zstream.avail_out := bufferSize;
      if (zstream.avail_in > 0) then // added if block 3/18/2007
      begin
        DCheck(inflate(zstream, Z_NO_FLUSH));

        // outSize := zstream.next_out - outBuffer;
        outSize := bufferSize - zstream.avail_out;

        outStream.Write(outBuffer, outSize);
      end;
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

    if zstream.avail_in > 0 then
      zresult := DCheck(inflate(zstream, Z_FINISH))
    else
      zresult := Z_STREAM_END;

    // outSize := zstream.next_out - outBuffer;
    outSize := bufferSize - zstream.avail_out;

    outStream.Write(outBuffer, outSize);
  until (zresult = Z_STREAM_END) and (zstream.avail_out > 0);

  DCheck(inflateEnd(zstream));
end;

procedure TVCLUnZip.ZLibDecompressBuffer(const inBuffer: Pointer; inSize: Integer;
  out outBuffer: Pointer; out outSize: Integer; outEstimate: Integer = 0; HttpCompression: Boolean = False);
var
  zstream: TZStreamRec;
  delta: Integer;
begin
  FillChar(zstream, SizeOf(TZStreamRec), 0);

  delta := (inSize + 255) and not 255;

  if outEstimate = 0 then outSize := delta
  else outSize := outEstimate;

  GetMem(outBuffer, outSize);

  try
    zstream.next_in := inBuffer;
    zstream.avail_in := inSize;
    zstream.next_out := outBuffer;
    zstream.avail_out := outSize;

    if (HttpCompression) then
      DCheck(InflateInit2(zstream,-15))
    else
      DCheck(InflateInit(zstream));

    try
      while DCheck(inflate(zstream, Z_NO_FLUSH)) <> Z_STREAM_END do
      begin
        Inc(outSize, delta);
        ReallocMem(outBuffer, outSize);

        zstream.next_out := PAnsiChar(Integer(outBuffer) + zstream.total_out);
        zstream.avail_out := delta;
      end;
    finally
      DCheck(inflateEnd(zstream));
    end;

    ReallocMem(outBuffer, zstream.total_out);
    outSize := zstream.total_out;
  except
    FreeMem(outBuffer);
    raise;
  end;
end;

function TVCLUnZip.ZLibDecompressString(const s: string; HttpCompression: Boolean = False): String;
var
  outBuf: Pointer;
  outBytes: Integer;
begin
  ZLibDecompressBuffer(pointer(s), Length(s)*SizeOf(Char), outBuf, outBytes, 0, HttpCompression);
  SetLength(Result, outBytes);
  if (outBytes > 512) then
    move(outBuf^, pointer(Result)^, outBytes)
  else
    MoveI32(pointer(outBuf)^, pointer(Result)^, outBytes);
  FreeMem(outBuf);
end;

{$IFDEF KPDEMO}
function DelphiIsRunning: Boolean;
begin
   Result := (DebugHook <> 0);
end;
{$ENDIF}

{$IFNDEF FULLPACK}
procedure Register;
begin
   RegisterComponents('VCLZip', [TVCLUnZip]);
end;
{$ENDIF}


{ $Id: VCLUnZip.pas,v 1.1 2001-08-12 17:30:40-04 kp Exp kp $ }

{ $Log:  10014: VCLUnZip.pas 
{
{   Rev 1.13.1.3    5/1/2009 12:16:16 PM  Delphi 2009    Version: VCLZip Version 4.51
{ Change version to 4.51
}
{
{   Rev 1.13.1.2    1/25/2009 12:01:24 PM  Delphi7    Version: VCLZip Version 4.50
{ Oops!
}
{
{   Rev 1.13.1.1    1/25/2009 11:56:30 AM  Delphi7    Version: VCLZip Version 4.50
{ Fix Demo warning
}
{
{   Rev 1.13.1.0    1/19/2009 6:25:00 PM  Delphi7    Version: VCLZip Version 4.50
{ Change kpThisVersion
}
{
{   Rev 1.13    11/30/2008 1:44:06 PM  Delphi7    Version: VCLZip Version 4.50
{ Modifications for 4.50
}
{
{   Rev 1.12    6/28/2008 7:14:38 PM  Delphi7    Version: VCLZip Pro 4.10 Beta
{ Modify version and build number
}
{
{   Rev 1.11    5/3/2008 8:21:38 PM  Delphi5    Version: VCLZip Pro 4.10 Beta
{ Change call to WideSameText to kpCompareText
}
{
{   Rev 1.10    4/17/2008 1:51:54 PM  Delphi7    Version: VCLZip Pro 4.10 Beta
{ Undo changes to previous AESDEFLATED fix. Not needed here.
}
{
{   Rev 1.9    1/25/2008 6:42:40 PM  Delphi7    Version: VCLZip Pro 4.00b2
}
{
{   Rev 1.8    12/27/2007 5:24:36 PM  Delphi7    Version: VCLZip Pro Encryption 4.0 b1
{ Changes from 3.X
}
{
{   Rev 1.7    4/28/2007 2:25:52 PM  Delphi7    Version: VCLZip Pro Encryption 4.0 b1
{ Simplify checking if running in IDE
}
{
{   Rev 1.6    3/18/2007 3:20:04 PM  Delphi7    Version: VCLZip Pro Encryption 4.0 b1
{ Fixed ZLibDecompressStream Problem
}
{
{   Rev 1.5    2/12/2007 10:08:00 PM  Encryption
{ Added AES and other fixes
}
{
{   Rev 1.4    2/14/2006 9:15:18 AM  Delphi7
{ Update to zlib 1.2.3
}
{
{   Rev 1.3    2/6/2006 10:59:50 PM  Delphi7
{ Work abort issue
}
{
{   Rev 1.2    9/4/2005 11:34:18 AM  Delphi9
{ Testing check for IDE running
}
{
{   Rev 1.1    8/29/2005 5:48:28 PM  Delphi7
{ Change kpThisVersion to 3.06
}
{
{   Rev 1.0    8/14/2005 1:07:56 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.34.1.15    4/2/2005 4:58:20 PM  Supervisor    Version: VCLZip 3.X
{ ZLib 1.2.2 default
{ Fixed ZLibDecompressStream
{ Delphi 2005 compatible
{ Other assorted bug fixes
}
{
{   Rev 1.34.1.14    7/28/2004 8:54:34 PM  Supervisor    Version: VCLZip 3.X
{ TOEMConvert
}
{
{   Rev 1.34.1.13    7/22/2004 12:41:00 PM  Supervisor    Version: VCLZip 3.X
{ Fixed greater than 65K files problem
{ Fixed problem when CD spanned parts
{ Fixed OperationMode settings
{ Fixed Zip64 EOCL
}
{
{   Rev 1.34.1.12    1/19/2004 8:36:44 PM  Supervisor    Version: VCLZip 3.X
{ Removed link to ziputil
}
{
{   Rev 1.34.1.11    12/30/2003 9:26:26 AM  Supervisor    Version: VCLZip 3.X
{ Remove Set and Get ArchiveTStream
}
{
{   Rev 1.34.1.10    12/16/2003 9:08:52 AM  Supervisor    Version: VCLZip 3.X
{ SetArchiveTStream and GetArchiveTStream
}
{
{   Rev 1.34.1.9    12/13/2003 9:08:18 PM  Supervisor    Version: VCLZip 3.X
{ Add SetArchiveTStream and GetArchiveTStream
}
{
{   Rev 1.34.1.8    12/13/2003 2:39:32 PM  Supervisor    Version: VCLZip 3.X
{ ZLIB_VERSION work
}
{
{   Rev 1.34.1.7    11/29/2003 11:59:36 PM  Supervisor    Version: VCLZip 3.X
{ Add DefaultHandleMessage
}
{
{   Rev 1.34.1.6    11/26/2003 4:02:38 PM  Supervisor    Version: VCLZip 3.X
{ Added HttpCompression boolean to all ZLib methods
}
{
{   Rev 1.34.1.5    11/26/2003 9:20:20 AM  Supervisor    Version: Zlib and GZip
{ More work on ZLib routines.  Includes a test of httpcompression boolean
}
{
{   Rev 1.34.1.4    11/25/2003 9:39:12 AM  Supervisor    Version: Zlib and GZip
{ Added ZLib routines.
}
{
{   Rev 1.34.1.3    11/11/2003 1:04:48 PM  Supervisor    Version: 3.04b1
{ Changes for overloaded zipfromstream
}
{
{   Rev 1.34.1.2    11/9/2003 11:47:02 AM  Supervisor    Version: VCLZip 3.X
{ Remove extra .
}
{
{   Rev 1.34.1.1    11/1/2003 8:11:38 PM  Supervisor    Version: VCLZip 3.X
{ Add overloaded ZipFromStream and UnZipToStreams for TStreams
}
{
{   Rev 1.34.1.0    11/1/2003 2:26:58 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.34    10/15/2003 5:49:02 PM  Supervisor    Version: VCLZip 3.X
{ Fix isZip64 and Increment ThisBuild
}
{
{   Rev 1.33    10/11/2003 10:50:42 AM  Supervisor    Version: VCLZip 3.X
{ Build 6
}
{
{   Rev 1.32    10/9/2003 10:38:50 PM  Supervisor    Version: VCLZip 3.X
{ Build 5
}
{
{   Rev 1.31    10/9/2003 6:57:52 PM  Supervisor    Version: VCLZip 3.X
{ Increment ThisBuild
}
{
{   Rev 1.30    10/8/2003 6:41:46 PM  Supervisor    Version: VCLZip 3.X
{ Fixed bmClassic problem, missing '.'
}
{
{   Rev 1.29    10/7/2003 7:52:58 AM  Supervisor    Version: VCLZip 3.X
{ Fixed DirExists prolem with root dir.  Went back to old code for DirExists
{ for now.
}
{
{   Rev 1.28    10/4/2003 9:27:36 AM  Supervisor    Version: VCLZip 3.X
{ Add ThisBuild
}
{
{   Rev 1.27    9/21/2003 1:24:36 PM  Supervisor    Version: VCLZip 3.X
{ Mod to use standard zlib
}
{
{   Rev 1.26    9/7/2003 9:37:42 AM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.25    9/7/2003 9:21:12 AM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.24    9/2/2003 7:19:20 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.23    8/26/2003 10:45:16 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.22    8/26/2003 8:58:08 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.21    8/19/2003 7:39:38 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.20    8/12/2003 5:23:48 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.19    8/7/2003 11:31:28 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.18    8/4/2003 10:23:22 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.17    8/4/2003 8:37:54 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.16    6/25/2003 6:16:46 PM  Kevin    Version: VCLZip 3.X
}
{
{   Rev 1.15    6/11/2003 7:54:08 PM  Kevin    Version: VCLZip 3.X
}
{
{   Rev 1.14    5/25/2003 11:24:28 PM  Supervisor    Version: VCLZip 3.X
{ Wrapped KPSMALL around a new Application.ProcessMessages
}
{
{   Rev 1.13    5/21/2003 7:43:32 AM  Supervisor    Version: VCLZip3.00z64c
}
{
{   Rev 1.12    5/20/2003 10:46:24 PM  Kevin    Version: VCLZip3.00z64c
}
{
{   Rev 1.11    5/19/2003 10:45:04 PM  Supervisor
{ After fixing streams.  VCLZip still uses ErrorRpt.  Also added setting of
{ capacity on the sorted containers to alleviate the memory problem caused by
{ growing array.
}
{
{   Rev 1.10    5/17/2003 7:25:14 AM  Supervisor    Version: Before so to so
{ Save before changing soFrom to so for TStream.Seeks
}
{
{   Rev 1.9    5/6/2003 6:11:40 PM  Supervisor
}
{
{   Rev 1.8    5/3/2003 6:33:32 PM  Supervisor
}
{
{   Rev 1.7    3/31/2003 6:13:28 PM  Supervisor
}
{
{   Rev 1.6    2/13/2003 10:56:14 AM  Supervisor
{ Added DoProcessMessages to ReadZipHardway at end
}
{
{   Rev 1.5    1/29/2003 10:31:30 PM  Supervisor
{ Added Pause feature
}
{
{   Rev 1.4    1/28/2003 6:54:06 PM  Supervisor
}
{
{   Rev 1.3    1/28/2003 7:16:22 AM  Supervisor
}
{
{   Rev 1.2    1/18/2003 6:39:02 PM  Supervisor
}
{
{   Rev 1.1    1/4/2003 1:36:38 PM  Supervisor
}
{
{   Rev 1.0    10/15/2002 8:15:24 PM  Supervisor
}
{
{   Rev 1.5    9/18/2002 12:45:46 PM  Supervisor
{ Added ZLib
}
{
{   Rev 1.4    9/7/2002 8:48:48 AM  Supervisor
{ Last modifications for FILE_INT
}
{
{   Rev 1.3    9/3/2002 11:46:46 PM  Supervisor
{ Mod for FILE_INT
}
{
{   Rev 1.2    9/3/2002 11:32:46 PM  Supervisor
{ Mod for FILE_INT
}
{
{   Rev 1.1    9/3/2002 11:04:40 PM  Supervisor
{ Mod for FILE_INT
}
{
{   Rev 1.0    9/3/2002 8:16:54 PM  Supervisor
}
{ Revision 1.1  2001-08-12 17:30:40-04  kp
{ Initial revision
{
{ Revision 1.37  2000-12-16 16:50:08-05  kp
{ 2.21 Final Release 12/12/00
{
{ Revision 1.36  2000-06-04 15:54:21-04  kp
{ - added code to ReadZipHardWay if AddObject throws exception.  This one caused by
{   a zip with central file header that had a duplicate offset value.
{
{ Revision 1.35  2000-05-21 18:47:05-04  kp
{ - Changed DEF_BUFSTREAMSIZE to $4000 for 16bit.
{
{ Revision 1.34  2000-05-13 16:58:57-04  kp
{ - Added BufferedStreamSize property
{ - Added ECantWriteUCF exception
{ - Added ImproperZip property
{ - Fixed problem of when KeepZipOpen is True and trying to open next disks filepart when
{   doing spanned zip sets.
{ - Fixed problem of extra field, now will handle whether bogus or not.
{ - Improved handling of bad zips beyond the point of looking for end of central
{ - Fixed problem of not being able to get zip comments from zfc file
{
{ Revision 1.33  1999-12-05 09:32:08-05  kp
{ - ran through formatter
{
{ Revision 1.32  1999-11-21 08:49:02-05  kp
{ - added kp to min and max for D1
{ - added integrity checking in reading of zip file
{
{ Revision 1.31  1999-11-09 19:41:01-05  kp
{ - Modified to correctly handle extra fields in headers
{ - Removed check for Object Inspector window in IDE Check
{
{ Revision 1.30  1999-10-24 11:02:25-04  kp
{ - Shored up the GetDecryptHeaderPtr and GetDecryptHeader methods.
{
{ Revision 1.29  1999-10-24 09:34:24-04  kp
{ - Added ENotEnoughRoom exception
{ - Fixed up GetDecryptHeaderPtr a little, still needs some work
{ - Small fix in GetFileInfo for spanned zip files whos central dir doesnt start on last disk
{
{ Revision 1.28  1999-10-20 18:15:25-04  kp
{ - Added Retry parameter to OnSkippingFile
{
{ Revision 1.27  1999-10-11 20:11:11-04  kp
{ - Added FlushFilesOnClose property
{
{ Revision 1.26  1999-09-26 19:57:36-04  kp
{ - Removed defines that had already been moved to kpdefs.inc
{
{ Revision 1.25  1999-09-16 20:08:33-04  kp
{ - Moved defines to KPDEFS.INC
{
{ Revision 1.24  1999-09-14 21:27:27-04  kp
{ - Added compiler detection defines to this file
{ - Removed GetDecryptHeader function from BCB versions
{ - Added a few checks for proper arguments to a few methods
{
{ Revision 1.23  1999-09-01 18:30:01-04  kp
{ - Modified ReadZipHardWay to check for 0-10 right after the sig is found instead of
{   checking to be sure it is zero.
{
{ Revision 1.22  1999-08-25 19:03:42-04  kp
{ - Fixes for D1
{ - Updated Assign methods
{
{ Revision 1.21  1999-08-25 17:54:54-04  kp
{ - Added izAssumeNotAZip IncompleteZipMode and ENotAZipFile exception
{ - Added buffered memory unzipping
{ - Added CheckArchive
{ - Added ability to read zip info on first disk of multizip file
{ - Added DecryptHeader methods for BCB
{ - Added NumSelected
{
{ Revision 1.20  1999-07-06 20:08:10-04  kp
{ - Added the ClearSelected procedure
{
{ Revision 1.19  1999-06-27 13:55:22-04  kp
{ - Added Selected[Index] property and the UnZipSelected, UnZipToBufferByIndex, and
{  UnZipToStreamByIndex methods
{
{ Revision 1.18  1999-06-27 10:17:09-04  kp
{ - Added DecryptHeader property
{ - Added Assign method
{
{ Revision 1.17  1999-06-02 10:27:05-04  kp
{ - Added constants for header signatures
{
{ Revision 1.16  1999-04-24 21:15:11-04  kp
{ - Fixed small problem with IDE check in BCB 4
{
{ Revision 1.15  1999-04-10 10:19:38-04  kp
{ - Added conditionals so that NOLONGNAMES and NODISKUTILS wont get set in 32bit.
{ - Added OnUnZipComplete event.
{
{ Revision 1.14  1999-03-30 19:43:21-05  kp
{ - Modified so that defining MAKESMALL will create a much smaller component.
{
{ Revision 1.13  1999-03-22 17:33:06-05  kp
{ - modified for BCB4
{ - moved comments to bottom
{ - moved strings to string list resource
{
{ Revision 1.12  1999-03-20 18:22:11-05  kp
{ - Modified OnStartUnZip to have FName be a var parameter.
{ - Moved the OnStartUnZip call so that output filename could be changed
{
{ Revision 1.11  1999-03-20 11:45:06-05  kp
{ - Fixed problem where setting ZipComment to '' caused an access violation
{
{ Revision 1.10  1999-03-17 18:25:09-05  kp
{ - Added ReplaceReadOnly property
{
{ Revision 1.9  1999-03-09 21:59:26-05  kp
{ - Fixed problem of disappearing OnGetNextDisk event
{
{ Revision 1.8  1999-02-14 15:33:12-05  kp
{ - Fixed bug that caused a directory called c:\TestZip\ to be created when FileIsOK was called.
{ - Changed AnsiCompareStr to AnsiCompareText in ReadZipHardWay.
{ - Fixed bug that caused ReadZipHardWay's information to be inadvertantly deleted.
{
{ Revision 1.7  1999-01-25 19:08:34-05  kp
{ Added DefaultGetNextDisk
{ Added ResetFileIsOK
{ Removed IsAZipFile
{
{ Revision 1.6  1999-01-12 20:25:16-05  kp
{ -Slight modification to precompiler conditionals
{ -Tightened up CancelTheOperation some
{ }

{ 7/10/98 5:26:10 PM
{ Moved one line in Destroy method becasue a user said
{ that it stopped him from getting "Invalid Pointer
{ Operation" errors.
}
{
{ Sun 10 May 1998   16:58:45  SVersion: 2.12
{ - Added TempPath property
{ - Fixed RelativePaths bug
{ - Fixed bug related to files in FilesList that don't exist
}
{
{ Mon 27 Apr 1998   18:09:07 Version: 2.11
{ Added BCB 3 Support
{ Added kpThisVersion constant
}
{
{ Sun 29 Mar 1998   10:51:34  Version: 2.1
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
{  Tue 24 Mar 1998   19:00:21
{ Modifications to allow files and paths to be stored in DOS
{ 8.3 filename format.  New property is Store83Names.
}
{
{ Wed 11 Mar 1998   21:10:15 Version: 2.03
{ Version 2.03 Files containing many fixes
}

end.


