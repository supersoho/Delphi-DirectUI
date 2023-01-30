{ ********************************************************************************** }
{                                                                                    }
{   COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: UnZipObj.Pas                                                      }
{     Description: VCLUnZip/VCLZip component - native Delphi unzip component.        }
{     Date:        May 1997                                                          }
{     Author:      Kevin Boylan, boylank@bigfoot.com                                 }
{                                                                                    }
{                                                                                    }
{ ********************************************************************************** }
unit kpZipObj;

{$P-} { turn off open parameters }
{$R-} { 3/10/98 2.03 }
{$Q-} { 3/10/98 2.03 }
{$B-} { turn off complete boolean eval } { 12/24/98  2.17 }
{$T-} { untyped @ }

{$I KPDEFS.INC}

interface

uses
{$IFDEF WIN32}
  Windows,
{$ELSE}
  WinTypes, WinProcs,
{$ENDIF}
{$IFNDEF INT64STREAMS}
  kpHstrms,
{$ENDIF}
{$IFDEF IMPLEMENT_UNICODE}
  {$IFDEF DEBUG_UNICODE}
  TnTDialogs,
  {$ENDIF}
{$ENDIF}
  kpUtilsUnicode, SysUtils, Classes, kpCntn;

type
  cpltype = array[0..30] of WORD;
  cpdtype = array[0..29] of WORD;
  TEncryptStrength = (esPKStandard,esAES128, esAES192, esAES256);

{$IFDEF ISBCB}
  U_LONG = DWORD;
  LongInt = Integer;
  Comp = Double;
{$ENDIF}
{$IFDEF ISDELPHI4}
  U_LONG = Cardinal;
{$ENDIF}
{$IFDEF ISDELPHI3}
  U_LONG = LongInt;
{$ENDIF}
{$IFDEF ISDELPHI2}
  U_LONG = LongInt;
{$ENDIF}
{$IFDEF ISDELPHI1}
  U_LONG = LongInt;
{$ENDIF}

{$I kpZConst.Pas}
{$I kpZTypes.Pas}

  const
    ZIP64_TAG = $0001;
    NTFS_TAG = $000A;
    AES_TAG = $9901;
    UPATH_TAG = $7075;

var
  CENTSIG: LongInt; { = $02014b50 }
  LOCSIG: LongInt; { = $04034b50 }
  ENDSIG: LongInt; { = $06054b50 }
  ZIP64EOC: LongInt; { =  $06064b50 }
  ZIP64EOCL: LongInt; { = $07064b50 }
  LOC4: Byte; { = $50  Last byte of LOCSIG }
  LOC3: Byte; { = $4b  3rd byte of LOCSIG }
  LOC2: Byte; { = $03  2nd byte of LOCSIG }
  LOC1: Byte; { = $04  1st byte of LOCSIG }
  END4: Byte; { = $50  Last byte of ENDSIG }
  EncryptionStrengths: Array [0..3] of TEncryptStrength = (esPKStandard, esAES128, esAES192, esAES256);

type
{*********************  HEADER INFO  **************************************}

   THeaderType = (htLocal, htCentral);
   TOEMConvert = ({$IFNDEF SUPPORT_UNICODE}oemAlways,{$ENDIF}oemNever,oemFlexible);

  SignatureType = packed record
    case Integer of
      0: (Sig: LongInt); { $04034b50    }
      1: (ID1, ID2: WORD); { $4b50, $0403 }
  end;

  local_file_header = packed record
    Signature: SignatureType;
    version_needed_to_extract: WORD;
    general_purpose_bit_flag: WORD;
    compression_method: WORD;
    last_mod_file_date_time: U_LONG;
    crc32: U_LONG;
    compressed_size: FILE_INT;
    uncompressed_size: FILE_INT;
    filename_length: WORD;
    extra_field_length: WORD;
  end;
  localPtr = ^local_file_header;

  central_file_header = packed record
    Signature: SignatureType;
    version_made_by: WORD;
    version_needed_to_extract: WORD;
    general_purpose_bit_flag: WORD;
    compression_method: WORD;
    last_mod_file_date_time: U_LONG;
    crc32: U_LONG;
    compressed_size: FILE_INT;
    uncompressed_size: FILE_INT;
    filename_length: WORD;
    extra_field_length: WORD;
    file_comment_length: WORD;
    disk_number_start: WORD;
    internal_file_attributes: WORD;
    external_file_attributes: U_LONG;
    relative_offset: FILE_INT;
  end;
  centralPtr = ^central_file_header;

  zip64_Extra_Field = packed record
    Tag: WORD; { $0001 }
    Size: WORD;
    Uncompressed_Size: BIGINT;
    Compressed_Size: BIGINT;
    Relative_Offset: BIGINT;
    DiskStart: LongWord;
  end;
  zip64_Extra_FieldPtr = ^zip64_Extra_Field;

  AES_Extra_Field = packed record
    Tag: WORD;  { $9901 }
    Size: WORD;
    Version: WORD;
    Vendor_id: array [0..1] of AnsiChar; { "AE" }
    Strength: BYTE; {1=128,2=192,3=256}
    compression_method: WORD;
  end;
  AES_Extra_FieldPtr = ^AES_Extra_Field;

  UPATH_Extra_Field = packed record
    Tag: WORD;  { $7075 }
    Size: WORD;
    Version: BYTE;
    NameCRC32: LongWord;
  end;
  UPATH_Extra_FieldPtr = ^UPATH_Extra_Field;

  data_descriptor_20 = packed record
    crc32:              ULONG;
    compressed_size:    FILE_INT;
    uncompressed_size:  FILE_INT;
  end;

  data_descriptor_zip64 = packed record
    crc32:              ULONG;
    compressed_size:    BIGINT;
    uncompressed_size:  BIGINT;
  end;

  NTFS_extra_field = packed record
    Tag: WORD; { $000a }
    Size: WORD;
    Reserved: LongWord;
    Tag1: WORD; { $0001 }
    Size1: WORD;
    Mtime: BIGINT;
    Atime: BIGINT;
    Ctime: BIGINT;
  end;
  NTFS_extra_fieldPtr = ^NTFS_extra_field;

  TZipHeaderInfo = class(TPersistent) {****************TZipHeaderInfo******************}
  { This class contains all the information reflected in both the central and local
    headers for a particular compressed file within a zip file }
  private
{$IFDEF KPDEMO}
    DR: Boolean;
{$ENDIF}
    Fversion_made_by: WORD;
    Fversion_needed_to_extract: WORD;
    Fgeneral_purpose_bit_flag: WORD;
    Flast_mod_file_date_time: U_LONG;
    Fcrc32: U_LONG;
    Fcompressed_size: FILE_INT;
    Funcompressed_size: FILE_INT;
    Ffilename_length: WORD;
    FCextra_field_length: WORD;
    FLextra_field_length: WORD;
    Ffile_comment_length: WORD;
    Fdisk_number_start: WORD;
    Finternal_file_attributes: WORD;
    Fexternal_file_attributes: U_LONG;
    Frelative_offset: FILE_INT;
    Fcentral_offset: BIGINT;
    Ffilename: kpWString;
    Fdirectory: kpWString;
    FZip64_Extended: zip64_Extra_FieldPtr;
    FAES_Extra: AES_Extra_FieldPtr;
    UPATH_Extra: UPATH_Extra_FieldPtr;
    FEncryptionStrength: TEncryptStrength;
    Ffilecomment: AnsiString;
    FMatchFlag: Boolean;
    FFileIsOK: Byte;
    FSelected: Boolean;
    FOEMConvert: TOEMConvert; { 2/17/02  2.22+ }
    FOriginalExtraOffset: BIGINT;
    FOriginalCExtra_field_length: WORD;
    FOriginalZip64_Extra_length: WORD;

  protected
    function GetHasComment: Boolean;
    function GetIsEncrypted: Boolean;
    function GetHasDescriptor: Boolean;
    function Getfilecomment(S: TkpStream): AnsiString;

    function GetLocalSize: Integer;
    function GetCentralSize: Integer;
    procedure Setfilename(FName: kpWString);
    procedure Setdirectory(Directory: kpWString);
    procedure SetFileComment(FComment: AnsiString);

    function GetCompressedSize: BIGINT;
    procedure SetCompressedSize(size: BIGINT);
    function GetUnCompressedSize: BIGINT;
    procedure SetUnCompressedSize(size: BIGINT);
    function GetNewZip64Extended: zip64_Extra_FieldPtr;
    function FZip64_Extended_Instance: zip64_Extra_FieldPtr;
    function GetNewAES_Extra_Instance: AES_Extra_FieldPtr;
    function FAES_Extra_Instance: AES_Extra_FieldPtr;
    function GetNewUPATH_Extra_Instance: UPATH_Extra_FieldPtr;
    function UPATH_Extra_Instance: UPATH_Extra_FieldPtr;
    procedure WriteAESExtra(S:TkpStream);
    procedure GetExtraFields(S: TkpStream);
    function GetRelativeOffset: BIGINT;
    procedure SetRelativeOffset(offset: BIGINT);
    function GetDisk_number_start: LongWord;
    procedure SetDisk_number_start(disk: LongWord);
    function GetCompression_Method: WORD;

    function Zip64ExtraSize(ht: THeaderType): Word;
    procedure WriteZip64Extra(S: TkpStream; ht: THeaderType);

    function ToOEM(var fname: kpWString): boolean; { 2/17/02  2.22+ }
    function FromOEM(var fname: AnsiString): Boolean; { 2/17/02  2.22+ }

  public
    Fcompression_method: WORD;  { Just so can get directly to it if needed like in Assign }
    constructor Create;
    constructor InitWithCentral(crec: centralPtr; FName: kpWString);
    constructor InitWithLocal(lrec: localPtr; FName: kpWString);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure AssignTo(Dest: TPersistent); override;

    procedure SetFromCentral(crec: centralPtr; FName: kpWString);
    procedure SetFromLocal(lrec: localPtr; FName: kpWString);
    procedure Clear;
    procedure SaveCentralToStream(S: TkpStream; TempFile: TkpStream; UsingTemp: Boolean);
    procedure SaveLocalToStream(S: TkpStream);
    function WriteDataDescriptor(S: TkpStream): Boolean;
    function ReadCentralFromStream(var S: TkpStream; NewDiskEvent: TNewDiskEvent):
      Boolean;
    function ReadLocalFromStream(S: TkpStream): Boolean;

    procedure SetDateTime(DateTime: TDateTime);
    procedure SetNewFileComment(NewComment: AnsiString);

    property version_made_by: WORD read Fversion_made_by write Fversion_made_by;
    property version_needed_to_extract: WORD read Fversion_needed_to_extract
      write Fversion_needed_to_extract;
    property general_purpose_bit_flag: WORD read Fgeneral_purpose_bit_flag
      write Fgeneral_purpose_bit_flag;
    property compression_method: WORD read GetCompression_method write Fcompression_method;
    property last_mod_file_date_time: U_LONG read Flast_mod_file_date_time
      write Flast_mod_file_date_time;
    property crc32: U_LONG read Fcrc32 write Fcrc32;
    property compressed_size: BIGINT read GetCompressedSize write SetCompressedSize;
    property uncompressed_size: BIGINT read GetUnCompressedSize write
      SetUnCompressedSize;
    property filename_length: WORD read Ffilename_length write Ffilename_length;
    property Cextra_field_length: WORD read FCextra_field_length write
      FCextra_field_length;
    property Lextra_field_length: WORD read FLextra_field_length write
      FLextra_field_length;
    property file_comment_length: WORD read Ffile_comment_length write
      Ffile_comment_length;
//    property disk_number_start: WORD read Fdisk_number_start write Fdisk_number_start;
    property disk_number_start: LongWord read GetDisk_number_start write
      SetDisk_number_start;
    property internal_file_attributes: WORD read Finternal_file_attributes
      write Finternal_file_attributes;
    property external_file_attributes: U_LONG read Fexternal_file_attributes
      write Fexternal_file_attributes;
//    property relative_offset: FILE_INT read Frelative_offset write Frelative_offset;
    property relative_offset: BIGINT read GetRelativeOffset write SetRelativeOffset;
    property central_offset: BIGINT read FCentral_Offset write FCentral_Offset;
    property filename: kpWString read Ffilename write Setfilename;
    property directory: kpWString read Fdirectory write Setdirectory;
    property MatchFlag: Boolean read FMatchFlag write FMatchFlag;
    property HasComment: Boolean read GetHasComment;
    property Encrypted: Boolean read GetIsEncrypted;
    property HasDescriptor: Boolean read GetHasDescriptor;
    property filecomment: AnsiString read FFilecomment write SetFileComment;
    property LocalSize: Integer read GetLocalSize;
    property CentralSize: Integer read GetCentralSize;
    property FileIsOK: Byte read FFileIsOK write FFileIsOK;
    property Selected: Boolean read FSelected write FSelected;
    property OEMConvert: TOEMConvert read FOEMConvert write FOEMConvert; { 2/17/02  2.22+ }
    property EncryptionStrength: TEncryptStrength read FEncryptionStrength write FEncryptionStrength default esPKStandard;

  end;

{****************************  END OF CENTRAL  **********************************}

  zip64_end_of_central = packed record
    ID: LongInt; { $06064b50}
    size: BIGINT;
    version_made_by: WORD;
    version_needed: WORD;
    this_disk: LongWord;
    start_central_disk: LongWord;
    num_entries_this_disk: BIGINT;
    num_entries: BIGINT;
    size_central: BIGINT;
    offset_central: BIGINT;
  end;

  zip64_end_of_centralPtr = ^zip64_end_of_central;

  zip64_end_of_central_locator = packed record
    ID: LongInt; { $07064b50}
    num_disk_start_zip64_end_central: FILE_INT;
    offset_zip64_end_central: BIGINT;
    num_disks: FILE_INT;
  end;

  zip64_end_of_central_locatorPtr = ^zip64_end_of_central_locator;

  end_of_central = packed record
    ID: LongInt; { $06054b50 }
    this_disk: WORD;
    start_central_disk: WORD;
    num_entries_this_disk: WORD;
    num_entries: WORD;
    size_central: LongWord;
    offset_central: FILE_INT;
    zip_comment_length: WORD;
  end;

  end_of_centralPtr = ^end_of_central;

  TEndCentral = class(TPersistent) {********************TEndCentral******************}
  { This class contains all information contained in the end of central record
    for a zip file, plus some other pertinent information }
  private
    Fecrec: end_of_central;
    FZipComment: AnsiString;
    FZipCommentPos: BIGINT;
    FModified: Boolean;
    FZip64EOC: zip64_end_of_centralPtr;
    FZip64EOCL: zip64_end_of_central_locatorPtr;

  protected
    function GetZipHasComment: Boolean;
    function GetZipComment(S: TkpStream): AnsiString;
    function GetEndCentralSize: LongInt;

    function GetThis_Disk: LongWord;
    procedure SetThis_Disk(disk: LongWord);
    function GetStart_Central_Disk: LongWord;
    procedure SetStart_Central_Disk(disk: LongWord);
    function GetNum_Entries_This_Disk: LongWord;
    procedure SetNum_Entries_This_Disk(entries: LongWord);
    function GetNum_Entries: BIGINT;
    procedure SetNum_Entries(entries: BIGINT);
    function GetSize_Central: BIGINT;
    procedure SetSize_Central(size: BIGINT);
    function GetOffset_Central: BIGINT;
    procedure SetOffset_Central(offset: BIGINT);

    function Getnum_disk_start_zip64_end_central: LongWord;
    procedure Setnum_disk_start_zip64_end_central(numDisk: LongWord);
    function Getoffset_zip64_end_central: BIGINT;
    procedure Setoffset_zip64_end_central(offset: BIGINT);
    function Getnum_disks: LongWord;
    procedure Setnum_disks(numDisks: LongWord);

    function GetNewFZip64EOC: zip64_end_of_centralPtr;
    function GetNewFZip64EOCL: zip64_end_of_central_locatorPtr;
    function FZip64EOC_Instance: zip64_end_of_centralPtr;
    function FZip64EOCL_Instance: zip64_end_of_central_locatorPtr;

    property ecrec: end_of_central read Fecrec write Fecrec;
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetNewZipComment(NewComment: AnsiString);

    procedure Assign(Source: TPersistent); override;
    procedure AssignTo(Dest: TPersistent); override;
    procedure SetFromEndCentral(crec: end_of_centralPtr);

    procedure Clear;
    procedure SaveToStream(S: TkpStream);
    function ReadFromStream(S: TkpStream): Boolean;

    property ID: LongInt read Fecrec.ID write Fecrec.ID;
    property this_disk: LongWord read GetThis_Disk write SetThis_Disk;
    property start_central_disk: LongWord read GetStart_Central_Disk
      write SetStart_Central_Disk;
    property num_entries_this_disk: LongWord read GetNum_Entries_This_Disk
      write SetNum_Entries_This_Disk;
    property num_entries: BIGINT read GetNum_Entries write SetNum_Entries;
    property size_central: BIGINT read GetSize_Central write SetSize_Central;
    property offset_central: BIGINT read GetOffset_Central write SetOffset_Central;
    property zip_comment_length: WORD read Fecrec.zip_comment_length
      write Fecrec.zip_comment_length;
    property ZipHasComment: Boolean read GetZipHasComment;
    property ZipCommentPos: BIGINT read FZipCommentPos write FZipCommentPos;
    property ZipComment: AnsiString read FZipComment write FZipComment;
    property Modified: Boolean read FModified write FModified default False;
    property EndCentralSize: LongInt read GetEndCentralSize;
    property num_disk_start_zip64_end_central: LongWord read
      Getnum_disk_start_zip64_end_central write
      Setnum_disk_start_zip64_end_central;
    property offset_zip64_end_central: BIGINT read Getoffset_zip64_end_central write
      Setoffset_zip64_end_central;
    property num_disks: LongWord read Getnum_disks write Setnum_disks;
  end;

{*******************************  ZIP SORTING  ***************************************}

  TZipSortMode = (ByName, ByFileName, ByDirectoryName, ByDate, ByCompressedSize,
    ByUnCompressedSize, ByRate, ByNone);

  TSortedZip = class(TSortedObjectList)
  { This class holds a sorted collection of TZipHeaderInfo objects }
  private
    FSortMode: TZipSortMode;
    FFilesDate: TDateTime;
    FIsZip64: Boolean;
  public
    constructor Create(WithDuplicates: TDuplicates);
    Function AddObject(Item: tObject): Integer; override;
    function Compare(Key1, Key2: Pointer): integer; override;
    property SortMode: TZipSortMode read FSortMode write FSortMode default ByNone;
    property filesdate: TDateTime read FFilesDate write FFilesDate;
    property isZip64: Boolean read FIsZip64;
  end;

{$IFDEF KPDEMO}
function DRun: Boolean;
{$ENDIF}

procedure setZipSignatures(csig, lsig, esig: LongInt);

implementation {//////////////////////////////////////////////////////////////////////}

uses KpLib;

{*****************  TZipHeaderInfo Methods *********************}

constructor TZipHeaderInfo.Create;
begin
  inherited Create;
  Clear;
end;

destructor TZipHeaderInfo.Destroy;
begin
  if (FAES_Extra <> nil) then
    FreeMem(FAES_Extra, sizeof(AES_Extra_Field));
  if (FZip64_Extended <> nil) then
    FreeMem(FZip64_Extended, sizeof(zip64_Extra_Field));

  inherited Destroy;
end;

procedure TZipHeaderInfo.AssignTo(Dest: TPersistent);
var
  finfo: TZipHeaderInfo;
begin
  if Dest is TZipHeaderInfo then
  begin
    finfo := TZipHeaderInfo(Dest);
    finfo.version_made_by := version_made_by;
    finfo.version_needed_to_extract := version_needed_to_extract;
    finfo.general_purpose_bit_flag := general_purpose_bit_flag;
    finfo.compression_method := Fcompression_method;
    finfo.last_mod_file_date_time := last_mod_file_date_time;
    finfo.crc32 := crc32;
    finfo.compressed_size := compressed_size;
    finfo.uncompressed_size := uncompressed_size;
    finfo.filename_length := filename_length;
    finfo.Cextra_field_length := Cextra_field_length;
    finfo.Lextra_field_length := Lextra_field_length;
    finfo.file_comment_length := file_comment_length;
    finfo.disk_number_start := disk_number_start;
    finfo.internal_file_attributes := internal_file_attributes;
    finfo.external_file_attributes := external_file_attributes;
    finfo.relative_offset := relative_offset;
    finfo.central_offset := central_offset;
    finfo.filename := filename;
    finfo.directory := directory;
    finfo.EncryptionStrength := FEncryptionStrength;
    finfo.FAES_Extra := FAES_Extra;
    if (FAES_Extra <> nil) then
      finfo.FAES_Extra^ := FAES_Extra_Instance^;
    if (FZip64_Extended <> nil) then
      finfo.FZip64_Extended^ := FZip64_Extended_Instance^;
    if (file_comment_length > 0) and (Length(filecomment) > 0) then
    begin
      finfo.filecomment := filecomment;
    end;
    finfo.MatchFlag := MatchFlag;
    finfo.FileIsOK := FFileIsOK;
    finfo.FSelected := FSelected;
  end
  else
    inherited AssignTo(Dest);
end;

procedure TZipHeaderInfo.Assign(Source: TPersistent);
var
  finfo: TZipHeaderInfo;
begin
  if Source is TZipHeaderInfo then
  begin
    finfo := TZipHeaderInfo(Source);
    Fversion_made_by := finfo.version_made_by;
    Fversion_needed_to_extract := finfo.version_needed_to_extract;
    Fgeneral_purpose_bit_flag := finfo.general_purpose_bit_flag;
    Fcompression_method := finfo.Fcompression_method;
    Flast_mod_file_date_time := finfo.last_mod_file_date_time;
    Fcrc32 := finfo.crc32;
    Fcompressed_size := finfo.fcompressed_size;
    Funcompressed_size := finfo.funcompressed_size;
    Ffilename_length := finfo.filename_length;
    FCextra_field_length := finfo.Cextra_field_length;
    FLextra_field_length := finfo.Lextra_field_length;
    Ffile_comment_length := finfo.file_comment_length;
    Fdisk_number_start := finfo.disk_number_start;
    Finternal_file_attributes := finfo.internal_file_attributes;
    Fexternal_file_attributes := finfo.external_file_attributes;
    Frelative_offset := finfo.frelative_offset;
    Fcentral_offset := finfo.fcentral_offset;
    filename := finfo.filename;
    directory := finfo.directory;
    FEncryptionStrength := finfo.EncryptionStrength;
    if (finfo.FAES_Extra <> nil) then
      FAES_Extra_Instance^ := finfo.FAES_Extra^;
    if (finfo.FZip64_Extended <> nil) then
      FZip64_Extended_Instance^ := finfo.FZip64_Extended^;
    if (finfo.file_comment_length > 0) and (Length(finfo.filecomment) > 0) then
    begin
      Ffilecomment := finfo.filecomment;
    end;
    MatchFlag := finfo.MatchFlag;
    FFileIsOK := finfo.FFileIsOK;
    FSelected := finfo.FSelected;
  end
  else
    inherited Assign(Source);
end;

constructor TZipHeaderInfo.InitWithCentral(crec: centralPtr; FName: kpWString);
begin
  inherited Create;
  SetFromCentral(crec, FName);
end;

constructor TZipHeaderInfo.InitWithLocal(lrec: localPtr; FName: kpWString);
begin
  inherited Create;
  SetFromLocal(lrec, FName);
end;

procedure TZipHeaderInfo.SetFromCentral(crec: centralPtr; FName: kpWString);
begin
  Fversion_made_by := crec^.version_made_by;
  Fversion_needed_to_extract := crec^.version_needed_to_extract;
  Fgeneral_purpose_bit_flag := crec^.general_purpose_bit_flag;
  Fcompression_method := crec^.compression_method;
   { GoodTimeStamp 4/21/98  2.11 }
  Flast_mod_file_date_time := GoodTimeStamp(crec^.last_mod_file_date_time);
  Fcrc32 := crec^.crc32;
  Fcompressed_size := crec^.compressed_size;
  Funcompressed_size := crec^.uncompressed_size;
  Ffilename_length := crec^.filename_length;
  FCextra_field_length := crec^.extra_field_length;
  Ffile_comment_length := crec^.file_comment_length;
  Fdisk_number_start := crec^.disk_number_start;
  Finternal_file_attributes := crec^.internal_file_attributes;
  Fexternal_file_attributes := crec^.external_file_attributes;
  Frelative_offset := crec^.relative_offset;
  Fcentral_offset := 0;
  filename := kpExtractFileName(FName);
  directory := kpExtractFilePath(FName);
  Ffilecomment := '';
  FMatchFlag := False;
  FSelected := False;
end;

procedure TZipHeaderInfo.SetFromLocal(lrec: localPtr; FName: kpWString);
begin
  Fversion_made_by := 0;
  Fversion_needed_to_extract := lrec^.version_needed_to_extract;
  Fgeneral_purpose_bit_flag := lrec^.general_purpose_bit_flag;
  Fcompression_method := lrec^.compression_method;
   { GoodTimeStamp 4/21/98  2.11 }
  Flast_mod_file_date_time := GoodTimeStamp(lrec^.last_mod_file_date_time);
  Fcrc32 := lrec^.crc32;
  Fcompressed_size := lrec^.compressed_size;
  Funcompressed_size := lrec^.uncompressed_size;
  Ffilename_length := lrec^.filename_length;
  FLextra_field_length := lrec^.extra_field_length;
  Ffile_comment_length := 0;
  Fdisk_number_start := 0;
  Finternal_file_attributes := 0;
  Fexternal_file_attributes := 0;
  Frelative_offset := 0;
  Fcentral_offset := 0;
  if FName <> '' then
  begin
    filename := kpExtractFilename(FName);
    directory := kpExtractFilePath(FName);
  end
  else
  begin
    filename := '';
    directory := '';
  end;
  Ffilecomment := '';
  FMatchFlag := False;
  FSelected := False;
end;

procedure TZipHeaderInfo.Clear;
begin
  { Set up default values }
  Fversion_made_by := 45;
  Fversion_needed_to_extract := 20;
  Fgeneral_purpose_bit_flag := 0;
  Fcompression_method := 8;
  Flast_mod_file_date_time := 0;
  Fcrc32 := $FFFFFFFF; ;
  Fcompressed_size := 0;
  Funcompressed_size := 0;
  Ffilename_length := 0;
  FCextra_field_length := 0;
  FLextra_field_length := 0;
  Ffile_comment_length := 0;
  Fdisk_number_start := 0;
  Finternal_file_attributes := 1;
  Fexternal_file_attributes := 32;
  Frelative_offset := 0;
  Fcentral_offset := 0;
  Ffilename := '';
  Fdirectory := '';
  if (FZip64_Extended <> nil) then
  begin
    FreeMem(FZip64_Extended, sizeof(zip64_Extra_Field));
    FZip64_Extended := nil;
  end;
  Ffilecomment := '';
  FMatchFlag := False;
  FFileIsOK := 0;
  FSelected := False;
  FOEMConvert := oemNever;
end;

function TZipHeaderInfo.GetRelativeOffset: BIGINT;
begin
  if (FRelative_offset <> $FFFFFFFF) then
    Result := Frelative_offset
  else
    Result := FZip64_Extended^.relative_offset;
end;

procedure TZipHeaderInfo.SetRelativeOffset(offset: BIGINT);
begin
  if (offset <= $FFFFFFFE) then
    FRelative_Offset := offset
  else
  begin
    FZip64_Extended_Instance^.Relative_Offset := offset;
    FRelative_Offset := $FFFFFFFF;
  end;
end;

function TZipHeaderInfo.GetCompressedSize: BIGINT;
begin
  if (Fcompressed_size = $FFFFFFFF) then
    Result := FZip64_Extended^.Compressed_Size
  else
    Result := Fcompressed_size;
end;

procedure TZipHeaderInfo.SetCompressedSize(size: BIGINT);
begin
  if (size <= $FFFFFFFE) then
    Fcompressed_size := size
  else
  begin
    FZip64_Extended_Instance^.Compressed_Size := size;
    Fcompressed_size := $FFFFFFFF;
  end;
end;

function TZipHeaderInfo.GetUnCompressedSize: BIGINT;
begin
  if (Funcompressed_size = $FFFFFFFF) then
    Result := FZip64_Extended^.UnCompressed_Size
  else
    Result := FUnCompressed_size;
end;

procedure TZipHeaderInfo.SetUnCompressedSize(size: BIGINT);
begin
  if (size <= $FFFFFFFE) then
    FUncompressed_size := size
  else
  begin
    FZip64_Extended_Instance^.Uncompressed_Size := size;
    FUncompressed_Size := $FFFFFFFF;
  end;
end;

function TZipHeaderInfo.GetDisk_number_start: LongWord;
begin
  if (Fdisk_number_start < $FFFF) then
    Result := Fdisk_number_start
  else
    Result := FZip64_Extended^.DiskStart;
end;

procedure TZipHeaderInfo.SetDisk_number_start(disk: LongWord);
begin
  if (disk <= $FFFFFFFE) then
    Fdisk_number_start := disk
  else
  begin
    FZip64_Extended_Instance^.DiskStart := disk;
    FUncompressed_Size := $FFFFFFFF;
  end;
end;

procedure TZipHeaderInfo.GetExtraFields(S: TkpStream);
type
  Int64Ptr = ^Int64;
  LongWordPtr = ^LongWord;
  WordPtr = ^Word;
var
  extraBuffer: array of Byte;
  AES_Overlay: AES_Extra_FieldPtr;
  UPATH_Overlay: UPATH_Extra_FieldPtr;
  FName: kpWString;
  UTF8Name: AnsiString;
  NameLength: Integer;
  index: integer;
  Tag, Size: WORD;
begin
  SetLength(extraBuffer, FCextra_field_length);
  S.Read(extraBuffer[0], Cextra_field_length);
  Index := 0;
  while (Index < FCextra_field_length) do
  begin
    Tag := WordPtr(@extraBuffer[Index])^;
    Inc(Index, 2);
    Size := WordPtr(@extraBuffer[Index])^;
    Inc(Index, 2);
    case Tag of
      NTFS_TAG:
        Inc(Index, Size);
      AES_TAG:
        begin
          AES_Overlay := @extraBuffer[Index-4];
          FAES_Extra_Instance^ := AES_Overlay^;
          Inc(Index, Size);
        end;
      ZIP64_TAG:
        begin
          FOriginalZip64_Extra_length := Size + 4; // Total Size
          if (Funcompressed_size = $FFFFFFFF) then
          begin
            FZip64_Extended_Instance^.uncompressed_size := Int64Ptr(@extraBuffer[Index])^;
            Inc(Index, SizeOf(Int64));
          end;
          if (Fcompressed_size = $FFFFFFFF) then
          begin
            FZip64_Extended_Instance^.compressed_size := Int64Ptr(@extraBuffer[Index])^;
            Inc(Index, SizeOf(Int64));
          end;
          if (Frelative_offset = $FFFFFFFF) then
          begin
            FZip64_Extended_Instance^.Relative_Offset := Int64Ptr(@extraBuffer[Index])^;
            Inc(Index, SizeOf(Int64));
          end;
          if (Fdisk_number_start = $FFFF) then
          begin
            FZip64_Extended_Instance^.DiskStart := LongWordPtr(@extraBuffer[Index])^;
            Inc(Index, SizeOf(LongWord));
          end;
        end;
      UPATH_TAG:
        begin
          UPATH_Overlay := @extraBuffer[Index-4];
          UPATH_Extra_Instance^.Size := UPATH_Overlay^.Size;
          UPATH_Extra_Instance^.Version := UPATH_Overlay^.Version;
          UPATH_Extra_Instance^.NameCRC32 := UPATH_Overlay^.NameCRC32;
          Inc(Index,5);
          NameLength := UPATH_Extra_Instance^.Size - (SizeOf(UPATH_Extra_Instance^.Version)
                        + SizeOf(UPATH_Extra_Instance^.NameCRC32));
          SetString(UTF8Name, PAnsiChar(@extraBuffer[Index]), NameLength);
          FName := kpUTF8ToWideString(UTF8Name);
          filename := kpExtractFilename(FName);
          directory := kpExtractFilePath(FName);
          Inc(Index,NameLength);
        end;
    else
      Inc(Index, Size);
    end;
  end;
end;

function TZipHeaderInfo.GetNewZip64Extended: zip64_Extra_FieldPtr;
begin
  Result := AllocMem(SizeOf(zip64_Extra_Field));
  Result^.Tag := 1;
  Result^.Size := 0;
  Result^.Compressed_Size := 0;
  Result^.Uncompressed_Size := 0;
end;

function TZipHeaderInfo.FZip64_Extended_Instance: zip64_Extra_FieldPtr;
begin
  if (FZip64_Extended = nil) then
    FZip64_Extended := GetNewZip64Extended;
  Result := FZip64_Extended;
end;

function TZipHeaderInfo.GetNewAES_Extra_Instance: AES_Extra_FieldPtr;
begin
  Result := AllocMem(SizeOf(AES_Extra_Field));
  Result^.Tag := $9901;
  Result^.Size := 7;
  Result^.Version := 1;
  Result^.Vendor_id := 'AE';
  Result^.Strength := 0;
  Result^.compression_method := 0;
end;

function TZipHeaderInfo.FAES_Extra_Instance: AES_Extra_FieldPtr;
begin
  if (FAES_Extra = nil) then
    FAES_Extra := GetNewAES_Extra_Instance;
  Result := FAES_Extra;
end;

function TZipHeaderInfo.GetNewUPATH_Extra_Instance: UPATH_Extra_FieldPtr;
begin
  Result := AllocMem(SizeOf(UPATH_Extra_Field));
  Result^.Tag := $7075;
  Result^.Size := 0;
  Result^.Version := 1;
  Result^.NameCRC32 := 0;
end;

function TZipHeaderInfo.UPATH_Extra_Instance: UPATH_Extra_FieldPtr;
begin
  if (UPATH_Extra = nil) then
    UPATH_Extra := GetNewUPATH_Extra_Instance;
  Result := UPATH_Extra;
end;

function TZipHeaderInfo.ToOEM(var fname: kpWString): boolean; { 2/17/02  2.22+ }
var
  Dest,Comp: AnsiString;
  fnameIn:   AnsiString;
  testString: kpWString;
  OrgLen:    Integer;
begin
  // Convert only if OEMConvert is True and the Conversion
  // actually works.  If it doesn't work, then there must be
  // one or more characters outside the OEM character set, so
  // set the upper byte of ver_made_by to NTFS instead of DOS
  result := true;
  if (OEMConvert = oemNever) then
  begin
    // Don't convert
    Fversion_made_by := (Fversion_made_by and $00FF) or $0B00;
    general_purpose_bit_flag := general_purpose_bit_flag or 2048;
    result := false;
    exit;
  end;
  {$WARNINGS OFF}
  fnameIn := fname;
  {$WARNINGS ON}
  {$IFNDEF SUPPORT_UNICODE}
  if (OEMConvert = oemAlways) then
  begin
    // This saves string creation
    CharToOemA(@fnameIn[1], @fnameIn[1]);
    {$WARNINGS OFF}
    fname := fnameIn;
    {$WARNINGS ON}
    exit;
  end;
  {$ENDIF}
  {$WARNINGS OFF}
  testString := fnameIn;
  {$WARNINGS ON}
  //WideShowMessage('testString = ' + testString);
  if (kpCompareText(fname,testString) = 0) then
  begin
    // OEMConvert = oemFlexible
    OrgLen := Length(fnameIn);
    SetLength(Dest,OrgLen);
    CharToOemA(@fnameIn[1], @Dest[1]);
    SetLength(Comp,OrgLen);
    OEMToCharA(@Dest[1],@Comp[1]);

    //WideShowMessage('fnameIn = ' + fnameIn);
    //WideShowMessage('Dest = ' + Dest);
    //WideShowMessage('Comp = ' + Comp);
    {$WARNINGS OFF}
    if (kpCompareText(fnameIn,Comp) = 0) then
      // Allow conversion
      fname := Dest
    else
      result := false;
    {$WARNINGS ON}
  end
  else
    result := false;
  if (not result) then
  begin
    // No convertion, set WinZip compatible flag
    Fversion_made_by := (Fversion_made_by and $00FF) or $0B00;
    general_purpose_bit_flag := general_purpose_bit_flag or 2048;
  end;

end;

function TZipHeaderInfo.FromOEM(var fname: AnsiString): Boolean; { 2/17/02  2.22+ }
var
  comp,dest:  AnsiString;
  fnameIn:    AnsiString;
  fnameTest:  kpWString;
  OrgLen:     Integer;
begin
  result := False;
  // Only convert if OEMConvert is oemAlways or high byte of ver_made_by
  // is DOS and not NTFS.
  {$WARNINGS OFF}
  fnameIn := fname;
  {$WARNINGS ON}
  if (general_purpose_bit_flag and 2048 > 0) then
    exit;
  if {$IFNDEF SUPPORT_UNICODE}(OEMConvert = oemAlways) or {$ENDIF} ((OEMConvert = oemFlexible)
      and ((Fversion_made_by and $0B00) <> $0B00)) then
  begin
    OrgLen := Length(fnameIn);
    SetLength(Dest,OrgLen);
    OemToCharA(@fnameIn[1], @Dest[1]);
    SetLength(Comp,OrgLen);
    CharToOemA(@Dest[1], @Comp[1]);
    {$WARNINGS OFF}
    fnameTest := Comp;
    if (kpCompareText(fname,fnameTest) = 0) then
    begin
      // Allow conversion
      fname := Dest;
      Result := True;
    end;
  end;
  {$WARNINGS ON}
end;

  function TZipHeaderInfo.Zip64ExtraSize(ht: THeaderType): Word;
  begin
    Result := 0;
    if (Funcompressed_size = $FFFFFFFF) then
      Inc(Result, SizeOf(Int64));
    if (Fcompressed_size = $FFFFFFFF) or ((ht = htLocal) and (Funcompressed_size = $FFFFFFFF)) then
      Inc(Result, SizeOf(Int64));
    if (Frelative_offset = $FFFFFFFF) then
      Inc(Result, SizeOf(Int64));
    if (Fdisk_number_start = $FFFF) then
      Inc(Result, SizeOf(LongWord));
  end;

  procedure TZipHeaderInfo.WriteZip64Extra(S:TkpStream; ht: THeaderType);
  var
    size: Word;
    Zip64Tag: Word;
    tmpCmprssd: Int64;
  begin
    Zip64Tag := $001;
    S.Write(Zip64Tag, SizeOf(Word));
    size := Zip64ExtraSize(ht);
    S.Write(Size, SizeOf(Word));

    if (Funcompressed_size = $FFFFFFFF) then
      S.Write(FZip64_Extended^.uncompressed_size, SizeOf(Int64));
    if (Fcompressed_size = $FFFFFFFF) or ((ht = htLocal) and (Funcompressed_size = $FFFFFFFF)) then
    begin
      if (Fcompressed_size = $FFFFFFFF) then
        S.Write(FZip64_Extended^.compressed_size, SizeOf(Int64))
      else
      begin
        tmpCmprssd := Int64(Fcompressed_size);
        S.Write(tmpCmprssd, SizeOf(Int64));
      end;
    end;
    if (Frelative_offset = $FFFFFFFF) then
      S.Write(FZip64_Extended^.Relative_Offset, SizeOf(Int64));
    if (Fdisk_number_start = $FFFF) then
      S.Write(FZip64_Extended^.DiskStart, SizeOf(LongWord));
  end;

procedure TZipHeaderInfo.WriteAESExtra(S:TkpStream);
begin
end;

procedure TZipHeaderInfo.SaveCentralToStream(S: TkpStream; TempFile: TkpStream; UsingTemp: Boolean);

  // Writes original extra fields except for Zip64 which
  // is written separately.
  procedure WriteExtraFields;
  var
    extraBuffer: array of Byte;
    Index: Integer;
    Tag, Size: Word;

  begin
    TempFile.Seek(FOriginalExtraOffset, soBeginning);
    SetLength(extraBuffer, FOriginalCExtra_field_length);
    TempFile.Read(extraBuffer[0], FOriginalCExtra_field_length);
    Index := 0;
    while (Index < FOriginalCExtra_field_length) do
    begin
      Tag := WordPtr(@extraBuffer[Index])^;
      Inc(Index, 2);
      Size := WordPtr(@extraBuffer[Index])^;
      Inc(Index, 2);
      case Tag of
        ZIP64_TAG:
          begin
            // Don't write out zip64 extra field here.  Just because there was one, doesn't
            // mean there still should be.
            Inc(Index, Size);
          end;
        AES_TAG:
          begin
            Inc(index, Size);  // We'll write it later
          end;
      else
        begin
          S.Write(extraBuffer[Index - 4], Size + 4);
          Inc(Index, Size);
        end;
      end;
    end;
  end;

var
  fname: kpWString;
  fnameOut: AnsiString;
  SIG: LongInt;
  z64ESize: Integer;
begin
  SIG := CENTSIG;
  S.Write(SIG, SizeOf(LongInt));
  if Ffilename_length > 0 then
  begin
      { Added Copy's because when only Fdirectory existed, changes to fname affected Fdirectory
        8/20/01   2.22+  }
    //WideShowMessage('Filename = ' + Ffilename);
    //testfname := Ffilename;
    //WideShowMessage('UTF8toWide Version: ' + kpWideStringtoUTF8(Ffilename));
    fname := Copy(Fdirectory, 1, Length(Fdirectory)) + Copy(Ffilename, 1, Length(Ffilename));
    DOSToUnixFilename(kpPChar(fname));
    if (not ToOEM(fname)) then
    begin
      fnameOut := kpWideStringToUTF8(fname)
    end
    else
      {$WARNINGS OFF}
      fnameOut := fname;
      {$WARNINGS ON}
    Ffilename_length := Length(fnameOut);
  end;
  S.Write(Fversion_made_by, SizeOf(Fversion_made_by));
  z64ESize := Zip64ExtraSize(htCentral);
  if (z64ESize = 0) then
    Fversion_needed_to_extract := 20
  else
    Fversion_needed_to_extract := 45;
  if (Fcompression_method = 99) then
    Fversion_needed_to_extract := 51;
  S.Write(Fversion_needed_to_extract, SizeOf(Fversion_needed_to_extract));
  S.Write(Fgeneral_purpose_bit_flag, SizeOf(Fgeneral_purpose_bit_flag));
  if (not(Fcompression_method = 99)) and ((Encrypted) and (FEncryptionStrength <> esPKStandard)) then
  begin
    FAES_Extra_Instance^.compression_method := Fcompression_method;
    Fcompression_method := 99;
  end;
  S.Write(Fcompression_method, SizeOf(Fcompression_method));
  S.Write(Flast_mod_file_date_time, SizeOf(Flast_mod_file_date_time));
  S.Write(Fcrc32, SizeOf(Fcrc32));
  S.Write(Fcompressed_size, SizeOf(Fcompressed_size));
  S.Write(Funcompressed_size, SizeOf(Funcompressed_size));
  S.Write(Ffilename_length, SizeOf(Ffilename_length));
  FCextra_field_length := FOriginalCExtra_field_length - FOriginalZip64_Extra_length;
  if (z64ESize > 0) then
    Inc(FCextra_field_length, z64ESize + 4);
  if ( Fcompression_method = 99) then
      Inc(FCextra_field_length, sizeof(AES_Extra_Field));
  S.Write(FCextra_field_length, SizeOf(FCextra_field_length));
  S.Write(Ffile_comment_length, SizeOf(Ffile_comment_length));
  S.Write(Fdisk_number_start, SizeOf(Fdisk_number_start));
  S.Write(Finternal_file_attributes, SizeOf(Finternal_file_attributes));
  S.Write(Fexternal_file_attributes, SizeOf(Fexternal_file_attributes));
  S.Write(Frelative_offset, SizeOf(Frelative_offset));
  if Length(fnameOut) > 0 then
  begin
    S.Write(fnameOut[1], Length(fnameOut));
  end;
  if ((z64ESize = 0) and (FZip64_Extended <> nil)) then
  begin // zip64 extended field may no longer be needed
    FreeMem(FZip64_Extended, SizeOf(zip64_Extra_Field));
    FZip64_Extended := nil;
  end;
  if (FOriginalCExtra_field_length > 0) then
    WriteExtraFields;
  if (z64ESize > 0) then
    WriteZip64Extra(S,htCentral);
  if (Fcompression_method = 99) then // AES Extra Field
  begin
    FAES_Extra_Instance^.Strength := Ord(FEncryptionStrength);
    S.Write(FAES_Extra_Instance^,sizeof(AES_Extra_Field));
  end;
  if (Ffile_comment_length > 0) and (Length(Ffilecomment) > 0) then
    S.Write(Ffilecomment[1], Ffile_comment_length);
end;

procedure TZipHeaderInfo.SaveLocalToStream(S: TkpStream);
var
  fname: kpWString;
  fnameOut: AnsiString;
  SIG: LongInt;
  z64ESize: Integer;
  xfl: Word;
  cs: Cardinal;
begin
  SIG := LOCSIG;

  if Ffilename_length > 0 then
  begin
      { Added Copy's because when only Fdirectory existed, changes to fname affected Fdirectory
        8/20/01   2.22+  }
    //WideShowMessage('Filename = ' + Ffilename);
    fname := Copy(Fdirectory, 1, Length(Fdirectory)) + Copy(Ffilename, 1, Length(Ffilename));
    //WideShowMessage('fname = ' + fname);
    DOSToUnixFilename(kpPChar(fname));
    if (not ToOEM(fname)) then
      fnameOut := kpWideStringToUTF8(fname)
    else
      {$WARNINGS OFF}
      fnameOut := fname;
      {$WARNINGS ON}
    Ffilename_length := Length(fnameOut);
  end;

  relative_offset := S.Position; {2/1/98 Needed for mulitpart archives}
  S.Write(SIG, SizeOf(LongInt));
  z64ESize := Zip64ExtraSize(htLocal);
  if (z64ESize = 0) then
    Fversion_needed_to_extract := 20
  else
    Fversion_needed_to_extract := 45;
  S.Write(Fversion_needed_to_extract, SizeOf(Fversion_needed_to_extract));
  S.Write(Fgeneral_purpose_bit_flag, SizeOf(Fgeneral_purpose_bit_flag));
  if (not(Fcompression_method = 99)) and ((Encrypted) and (FEncryptionStrength <> esPKStandard)) then
  begin
    FAES_Extra_Instance^.compression_method := Fcompression_method;
    Fcompression_method := 99;
  end;
  S.Write(Fcompression_method, SizeOf(Fcompression_method));
  S.Write(Flast_mod_file_date_time, SizeOf(Flast_mod_file_date_time));
  S.Write(Fcrc32, SizeOf(Fcrc32));
  cs := FCompressed_size;
  if (Funcompressed_size = $FFFFFFFF) then
    cs := $FFFFFFFF;
  S.Write(cs, SizeOf(Fcompressed_size));
  S.Write(Funcompressed_size, SizeOf(Funcompressed_size));
  S.Write(Ffilename_length, SizeOf(Ffilename_length));
  xfl := FLextra_field_length;
  if (z64ESize > 0) then
    Inc(xfl, z64ESize+4);
  if (Fcompression_method = 99) then
    Inc(xfl, sizeof(AES_Extra_Field));
  S.Write(xfl, SizeOf(FLextra_field_length));
  if Ffilename_length > 0 then
  begin
    S.Write(fnameOut[1], Ffilename_length);
  end;
  if (z64ESize > 0) then
    WriteZip64Extra(S,htLocal);
  if (Fcompression_method = 99) then // AES Extra Field
  begin
    FAES_Extra_Instance^.Strength := Ord(FEncryptionStrength);
    S.Write(FAES_Extra_Instance^,sizeof(AES_Extra_Field));
  end;
end;

function TZipHeaderInfo.WriteDataDescriptor(S: TkpStream): Boolean;
var
  dd64: data_descriptor_zip64;
begin
    if (Funcompressed_size = $FFFFFFFF) or
     (Fcompressed_size = $FFFFFFFF) then
     begin
      dd64.crc32 := Fcrc32;
      dd64.compressed_size := FZip64_Extended^.compressed_size;
      dd64.uncompressed_size := FZip64_Extended^.uncompressed_size;
      S.Write(dd64,SizeOf(dd64));
      Fgeneral_purpose_bit_flag := Fgeneral_purpose_bit_flag or 8;
      Result := True;
     end
    else
      Result := False;
end;

function TZipHeaderInfo.ReadCentralFromStream(var S: TkpStream; NewDiskEvent:
  TNewDiskEvent): Boolean;
var
  fnameIn: AnsiString;
  fname: kpWString;
  AmtRead: LongInt;
  crec: central_file_header;
  save_offset: BIGINT;
  CSIG: LongInt;
begin
  CSIG := CENTSIG;
{$IFDEF KPDEMO}
  DR := DRun;
{$ENDIF}
  Result := False;
  save_offset := S.Seek(0, soCurrent);
  AmtRead := S.Read(crec, SizeOf(central_file_header));
  if (AmtRead = 0) or
    ((AmtRead <> SizeOf(central_file_header)) and (crec.Signature.Sig = CSIG)) then
    if Assigned(NewDiskEvent) then
    begin
      NewDiskEvent(Self, S);
      Inc(AmtRead, S.Read(crec, SizeOf(central_file_header) - AmtRead));
    end;
  if (AmtRead <> SizeOf(central_file_header)) or (crec.Signature.Sig <> CSIG) then
  begin
    S.Seek(save_offset, soBeginning);
    exit;
  end;

  fname := '';
  if crec.filename_length > 0 then
  begin
    SetLength(fnameIn, crec.filename_length);
    AmtRead := S.Read(fnameIn[1], crec.filename_length);
    if AmtRead <> crec.filename_length then
    begin
      S.Seek(save_offset, soBeginning);
      exit;
    end;

    UnixToDOSFilename(kpPChar(fnameIn));

    if (not FromOEM(fnameIn)) then
      fname := kpUTF8ToWideString(fnameIn)
    else
      fname := fnameIn;
  end;

{$IFDEF KPDEMO}
  if not DR then
    fname := 'xxx';
{$ENDIF}
  { Commented out the following since it should not be skipping past the extra field
    incase they are needed for something }
  {S.Seek(crec.extra_field_length + crec.file_comment_length, soCurrent);}
  SetFromCentral(@crec, fname);
  Fcentral_offset := save_offset;
  if (FCextra_field_length > 0) then
  begin
    FOriginalExtraOffset := S.Position;
    FOriginalCExtra_field_length := FCextra_field_length;
    GetExtraFields(S);
    S.Seek(FOriginalExtraOffset, soBeginning);
  end;
  if (Fcompression_method = 99) then  // AES Compression
  begin
    EncryptionStrength := EncryptionStrengths[FAES_Extra_Instance^.Strength];
    compression_method := FAES_Extra_Instance^.compression_method;
  end;
  Result := True;
end;


function TZipHeaderInfo.ReadLocalFromStream(S: TkpStream): Boolean;
var
  fname: kpWString;
  fnameIn: AnsiString;
  lrec: local_file_header;
  save_offset: BIGINT;
  AmtRead: LongInt;
begin
  Result := False;
  save_offset := S.Seek(0, soCurrent);
  AmtRead := S.Read(lrec, SizeOf(local_file_header));
  if (AmtRead <> SizeOf(local_file_header)) or (lrec.Signature.Sig <> LOCSIG) then
  begin
    S.Seek(save_offset, soBeginning);
    exit;
  end;
  fname := '';
  if lrec.filename_length > 0 then
  begin
    SetLength(fnameIn, lrec.filename_length);
    AmtRead := S.Read(fnameIn[1], lrec.filename_length);
    if AmtRead <> lrec.filename_length then
    begin
      S.Seek(save_offset, soBeginning);
      exit;
    end;
    UnixToDOSFilename(kpPChar(fnameIn));

    if (not FromOEM(fnameIn)) then
      {$WARNINGS OFF}
      fname := kpUTF8ToWideString(fnameIn)
      {$WARNINGS ON}
    else
      fname := fnameIn;

  end;

  SetFromLocal(@lrec, fname);
  Frelative_offset := save_offset;
  if (FLextra_field_length > 0) then
  begin
    save_offset := S.Seek(0, soCurrent);
    GetExtraFields(S);
    S.Seek(save_offset, soBeginning);
  end;
  Result := True;
end;

function TZipHeaderInfo.GetHasComment: Boolean;
begin
  Result := Ffile_comment_length > 0;
end;

procedure TZipHeaderInfo.SetFileComment(FComment: AnsiString);
begin
  FfileComment := FComment;
  Ffile_comment_length := Length(FfileComment);
end;

procedure TZipHeaderInfo.SetNewFileComment(NewComment: AnsiString);
begin
  SetFileComment(NewComment);
end;

function TZipHeaderInfo.Getfilecomment(S: TkpStream): AnsiString;
var
  crec: central_file_header;
begin
  Result := '';
  if HasComment then
  begin
    S.Seek(central_offset, soBeginning);
    S.Read(crec, SizeOf(central_file_header));
    with crec do
    begin
      S.Seek(filename_length + Cextra_field_length, soCurrent);
      SetLength(Result, Ffile_comment_length);
      S.Read(Result[1], Ffile_comment_length);
    end;
  end;
end;

function TZipHeaderInfo.GetIsEncrypted: Boolean;
begin
  Result := ((general_purpose_bit_flag and 1) <> 0) or (Fcompression_method = 99);
end;

function TZipHeaderInfo.GetCompression_Method: WORD;
begin
  Result := Fcompression_method;
  if (Result = 99) and (FAES_Extra <> nil) then
    Result := FAES_Extra^.compression_method;
end;

function TZipHeaderInfo.GetHasDescriptor: Boolean;
begin
  Result := (general_purpose_bit_flag and 8) <> 0;
end;

function TZipHeaderInfo.GetLocalSize: Integer;
begin
  Result := SizeOf(local_file_header) + Ffilename_length + FLextra_field_length;
end;

function TZipHeaderInfo.GetCentralSize: Integer;
begin
  Result := SizeOf(central_file_header) + FFilename_length + FCextra_field_length +
    Ffile_comment_length;
end;

procedure TZipHeaderInfo.Setfilename(FName: kpWString);
begin
  if FName <> Ffilename then
  begin
    Ffilename := FName;
    Ffilename_length := (Length(Fdirectory) + Length(Ffilename))* SizeOf(Char);
  end;
end;

procedure TZipHeaderInfo.Setdirectory(Directory: kpWString);
var
  tmpDirectory: kpWString;
begin
  if (Directory <> '') and (RightStr(Directory, 1) <> '\') then
    tmpDirectory := Directory + '\'
  else
    tmpDirectory := Directory;
  if tmpDirectory <> Fdirectory then
  begin
    Fdirectory := tmpDirectory;
    Ffilename_length := Length(Fdirectory) + Length(Ffilename);
  end;
end;

procedure TZipHeaderInfo.SetDateTime(DateTime: TDateTime);
begin
  Flast_mod_file_date_time := DateTimeToFileDate(DateTime);
end;

{*****************  TEndCentral Methods *********************}

constructor TEndCentral.Create;
begin
  inherited Create;
  Clear;
end;

destructor TEndCentral.Destroy;
begin
  if (FZip64EOCL <> nil) then
    FreeMem(FZip64EOCL, SizeOf(zip64_end_of_central_locator));
  if (FZip64EOC <> nil) then
    FreeMem(FZip64EOC, SizeOf(zip64_end_of_central));
  inherited Destroy;
end;

procedure TEndCentral.AssignTo(Dest: TPersistent);
var
  finfo: TEndCentral;
begin
  if Dest is TEndCentral then
  begin
    finfo := TEndCentral(Dest);
    finfo.ecrec := Fecrec;
    if (Fecrec.zip_comment_length > 0) and (Length(FZipComment) > 0) then
    begin
      finfo.ZipComment := FZipComment;
      finfo.zip_comment_length := Length(finfo.ZipComment);
    end;
    finfo.ZipCommentPos := FZipCommentPos;
  end
  else
    inherited AssignTo(Dest);
end;

procedure TEndCentral.Assign(Source: TPersistent);
var
  finfo: TEndCentral;
begin
  if Source is TEndCentral then
  begin
    finfo := TEndCentral(Source);
    Fecrec := finfo.ecrec;
    if (finfo.zip_comment_length > 0) and (Length(finfo.ZipComment) > 0) then
    begin
      FZipComment :=  finfo.ZipComment;
      Fecrec.zip_comment_length := Length(FZipComment);
    end;
    FZipCommentPos := finfo.ZipCommentPos;
  end
  else
    inherited Assign(Source);
end;

procedure TEndCentral.SetFromEndCentral(crec: end_of_centralPtr);
begin
  Fecrec := crec^;
  FZipCommentPos := 0;
  FZipComment := '';
end;

procedure TEndCentral.Clear;
begin
  with Fecrec do
  begin
    ID := ENDSIG;
    this_disk := 0;
    start_central_disk := 0;
    num_entries_this_disk := 0;
    num_entries := 0;
    size_central := 0;
    offset_central := 0;
    zip_comment_length := 0;
  end;
  FZipComment := '';
  FZipCommentPos := 0;
  FModified := False;
end;

procedure TEndCentral.SaveToStream(S: TkpStream);
var
  Zip64Needed: Boolean;
begin
{ DONE :
Add code to check to see if there SHOULD be a zip64 end of central
record at all. }
  if (FZip64EOC <> nil) then
  begin
    Zip64Needed := False;
    FZip64EOCL_Instance^.offset_zip64_end_central := S.Position;
    FZip64EOCL_Instance^.num_disk_start_zip64_end_central := Fecrec.this_disk;
    FZip64EOCL_Instance^.num_disks := Fecrec.this_disk + 1;
    if (Fecrec.start_central_disk <> $FFFF) then
      FZip64EOC^.start_central_disk := Fecrec.start_central_disk
    else
      Zip64Needed := True;
    if (Fecrec.this_disk <> $FFFF) then
      FZip64EOC^.this_disk := Fecrec.this_disk
    else
      Zip64Needed := True;
    if (Fecrec.num_entries_this_disk <> $FFFF) then
      FZip64EOC^.num_entries_this_disk := Fecrec.num_entries_this_disk
    else
      Zip64Needed := True;
    if (Fecrec.num_entries <> $FFFF) then
      FZip64EOC^.num_entries := Fecrec.num_entries
    else
      Zip64Needed := True;
    if (Fecrec.size_central <> $FFFFFFFF) then
      FZip64EOC^.size_central := Fecrec.size_central
    else
      Zip64Needed := True;
    if (Fecrec.offset_central <> $FFFFFFFF) then
      FZip64EOC^.offset_central := Fecrec.offset_central
    else
      Zip64Needed := True;
    if (Zip64Needed) then
    begin
      S.Write(FZip64EOC^, SizeOf(zip64_end_of_central));
      S.Write(FZip64EOCL^, Sizeof(zip64_end_of_central_locator));
    end
    else
    begin
      FreeMem(FZip64EOC, sizeof(zip64_end_of_central));
      FZip64EOC := nil;
      FreeMem(FZip64EOCL, sizeof(zip64_end_of_central_locator));
      FZip64EOCL := nil;
    end;
  end;
  S.Write(Fecrec, SizeOf(Fecrec));
  if (Fecrec.zip_comment_length > 0) and (Length(FZipComment) > 0) then
    S.Write(FZipComment[1], Length(FZipComment));
end;

function TEndCentral.ReadFromStream(S: TkpStream): Boolean;
var
  tmpBuff: PAnsiChar;
  tmpBuffsize: LongInt;
  peoc: end_of_centralPtr;
  j: LongInt;
  AmtRead: LongInt;
  zip64Locator: zip64_end_of_central_locatorPtr;

const
  TBUFFSIZE = 65535 + SizeOf(end_of_central);
begin
  Result := False;
  if S.Size < sizeof(end_of_central) then
  begin
    if S.Size = 0 then { 7/31/99 2.18+ }
      Result := True; { handle 0 length files }
    exit; { 1/28/98 v2.00+}
  end;
  tmpBuffsize := kpmin(S.Size, TBUFFSIZE);
  S.Seek(-tmpBuffsize, soEnd);
  GetMem(tmpBuff, tmpBuffsize);
  try
    AmtRead := S.Read(tmpBuff^, tmpBuffsize);
    if AmtRead <> tmpBuffsize then
      exit;
    j := tmpBuffsize - (sizeof(end_of_central));
    peoc := nil;
    while (j >= 0) and (peoc = nil) do
    begin
      while (j >= 0) and (Byte(tmpBuff[j]) <> END4) do
        Dec(j);
      if (j < 0) then
        break;
      peoc := end_of_centralPtr(@tmpBuff[j]); { added typecast 5/18/98  2.13 }
      if peoc^.ID <> ENDSIG then
      begin
        Dec(j);
        peoc := nil;
      end;
    end;
    if peoc = nil then
      exit;
    with Fecrec do
    begin
      this_disk := peoc^.this_disk;
      start_central_disk := peoc^.start_central_disk;
      num_entries_this_disk := peoc^.num_entries_this_disk;
      num_entries := peoc^.num_entries;
      size_central := peoc^.size_central;
      offset_central := peoc^.offset_central;
      zip_comment_length := peoc^.zip_comment_length;
     {FZipHasComment := ecrec.zip_comment_length > 0;}
     {ZipCommentPos := S.Size -  Fecrec.zip_comment_length;}{ 06/03/00 2.21b2+ }
      ZipCommentPos := S.Size - tmpBuffsize + j + sizeof(end_of_central);
    end;
    //if (Fecrec.offset_central = $FFFFFFFF) or (FEcrec.num_entries = $FFFF) then
    begin
      j := j - SizeOf(zip64_end_of_central_locator);
      if (j >= 0) then
      begin
      zip64Locator := zip64_end_of_central_locatorPtr(@tmpBuff[j]);
      if (zip64Locator^.ID = ZIP64EOCL) then
      begin
            // FZip64EOCL := AllocMem(SizeOf(zip64_end_of_central_locator));
        FZip64EOCL_Instance^.ID := zip64Locator^.ID;
        FZip64EOCL_Instance^.num_disk_start_zip64_end_central :=
          zip64Locator^.num_disk_start_zip64_end_central;
        FZip64EOCL_Instance^.offset_zip64_end_central :=
          zip64Locator^.offset_zip64_end_central;
        FZip64EOCL_Instance^.num_disks := zip64Locator^.num_disks;
        S.Seek(FZip64EOCL_Instance^.offset_zip64_end_central, soBeginning);
        S.Read(FZip64EOC_Instance^, SizeOf(zip64_end_of_central));
      end;
      end;
    end;
    Result := True;
  finally
    FreeMem(tmpBuff, tmpBuffsize);
  end;
end;

function TEndCentral.GetZipHasComment: Boolean;
begin
  Result := (zip_comment_length > 0);
end;

procedure TEndCentral.SetNewZipComment(NewComment: AnsiString);
begin
  FZipComment := NewComment;
  Fecrec.zip_comment_length := Length(NewComment);
end;

function TEndCentral.GetZipComment(S: TkpStream): AnsiString;
begin
  if Fecrec.zip_comment_length = 0 then
    Result := ''
  else if Length(FZipComment) > 0 then
    Result := FZipComment
  else
    with Fecrec do
    begin
      S.Seek(FZipCommentPos, soBeginning);
      SetLength(Result, zip_comment_length);
      S.Read(Result[1], zip_comment_length);
    end;
end;

function TEndCentral.GetEndCentralSize: LongInt;
begin
  Result := SizeOf(end_of_central) + Fecrec.zip_comment_length;
end;

function TEndCentral.GetThis_Disk: LongWord;
begin
  if (Fecrec.this_disk = $FFFF) and (FZip64EOC <> nil) then
    Result := FZip64EOC^.this_disk
  else
    Result := Fecrec.this_disk;
end;

procedure TEndCentral.SetThis_Disk(disk: LongWord);
begin
  if (disk <= $FFFE) then
    Fecrec.This_Disk := disk
  else
  begin
    FZip64EOC_Instance^.This_Disk := disk;
    Fecrec.This_Disk := $FFFF;
  end;
end;

function TEndCentral.GetStart_Central_Disk: LongWord;
begin
  if (Fecrec.start_central_disk = $FFFF) and (FZip64EOC <> nil) then
    Result := FZip64EOC^.start_central_disk
  else
    Result := Fecrec.start_central_disk;
end;

procedure TEndCentral.SetStart_Central_Disk(disk: LongWord);
begin
  if (disk <= $FFFE) then
    Fecrec.Start_Central_Disk := disk
  else
  begin
    FZip64EOC_Instance^.Start_Central_Disk := disk;
    Fecrec.Start_Central_Disk := $FFFF;
  end;
end;

function TEndCentral.GetNum_Entries_This_Disk: LongWord;
begin
  if (Fecrec.num_entries_this_disk = $FFFF) and (FZip64EOC <> nil) then
    Result := FZip64EOC^.num_entries_this_disk
  else
    Result := Fecrec.num_entries_this_disk;
end;

procedure TEndCentral.SetNum_Entries_This_Disk(entries: LongWord);
begin
  if (entries <= $FFFE) then
  begin
    Fecrec.Num_Entries_This_Disk := entries;
    if (FZip64EOC <> nil) then
      FZip64EOC^.num_entries_this_disk := entries;
  end
  else
  begin
    FZip64EOC_Instance^.Num_Entries_This_Disk := entries;
    Fecrec.Num_Entries_This_Disk := $FFFF;
  end;
end;

function TEndCentral.GetNum_Entries: BIGINT;
begin
  if (Fecrec.num_entries = $FFFF) and (FZip64EOC <> nil) then
    Result := FZip64EOC^.num_entries
  else
    Result := Fecrec.num_entries;
end;

procedure TEndCentral.SetNum_Entries(entries: BIGINT);
begin
  if (entries <= $FFFE) then
  begin
    Fecrec.Num_Entries := entries;
    if (FZip64EOC <> nil) then
      FZip64EOC^.num_entries := entries;
  end
  else
  begin
    FZip64EOC_Instance^.Num_Entries := entries;
    Fecrec.Num_Entries := $FFFF;
  end;
end;

function TEndCentral.GetSize_Central: BIGINT;
begin
  if (Fecrec.size_central = $FFFFFFFF) and (FZip64EOC <> nil) then
    Result := FZip64EOC^.size_central
  else
    Result := Fecrec.size_central;
end;

procedure TEndCentral.SetSize_Central(size: BIGINT);
begin
  if (size <= $FFFFFFFE) then
  begin
    Fecrec.Size_Central := size;
    if (FZip64EOC <> nil) then
      FZip64EOC^.size_central := size;
  end
  else
  begin
    FZip64EOC_Instance^.Size_Central := size;
    Fecrec.Size_Central := $FFFFFFFF;
  end;
end;


function TEndCentral.GetOffset_Central: BIGINT;
begin
  if (Fecrec.offset_central = $FFFFFFFF) and (FZip64EOC <> nil) then
    Result := FZip64EOC^.offset_central
  else
    Result := Fecrec.offset_central;
end;

procedure TEndCentral.SetOffset_Central(offset: BIGINT);
begin
  if (offset <= $FFFFFFFE) then
    Fecrec.offset_central := offset
  else
  begin
    FZip64EOC_Instance^.offset_central := offset;
    Fecrec.offset_central := $FFFFFFFF;
  end;
end;

function TEndCentral.Getnum_disk_start_zip64_end_central: LongWord;
begin
  Result := 0;
  if (FZip64EOCL <> nil) then
    Result := FZip64EOCL^.num_disk_start_zip64_end_central;
end;

procedure TEndCentral.Setnum_disk_start_zip64_end_central(numDisk: LongWord);
begin
  FZip64EOCL_Instance^.num_disk_start_zip64_end_central := numDisk;
end;

function TEndCentral.Getoffset_zip64_end_central: BIGINT;
begin
  Result := 0;
  if (FZip64EOCL <> nil) then
    Result := FZip64EOCL^.offset_zip64_end_central;
end;

procedure TEndCentral.Setoffset_zip64_end_central(offset: BIGINT);
begin
  FZip64EOCL_Instance^.offset_zip64_end_central := offset;
end;

function TEndCentral.Getnum_disks: LongWord;
begin
  Result := 0;
  if (FZip64EOCL <> nil) then
    Result := FZip64EOCL^.num_disks;
end;

procedure TEndCentral.Setnum_disks(numDisks: LongWord);
begin
  FZip64EOCL_Instance^.num_disks := numDisks;
end;

function TEndCentral.GetNewFZip64EOC: zip64_end_of_centralPtr;
begin
  Result := AllocMem(SizeOf(zip64_end_of_central));
  Result^.ID := DEF_ZIP64ENDSIG;
  Result^.size := 44;
  Result^.version_made_by := 45;
  Result^.version_needed := 45;
  Result^.this_disk := 0;
  Result^.start_central_disk := 0;
  Result^.num_entries_this_disk := 0;
  Result^.num_entries := 0;
  Result^.size_central := 0;
  Result^.offset_central := 0;
end;

function TEndCentral.GetNewFZip64EOCL: zip64_end_of_central_locatorPtr;
begin
  Result := AllocMem(SizeOf(zip64_end_of_central_locator));
  Result^.ID := DEF_ZIP64LOCATOR;
  Result^.num_disk_start_zip64_end_central := 0;
  Result^.offset_zip64_end_central := 0;
  Result^.num_disks := 1;
end;

function TEndCentral.FZip64EOC_Instance: zip64_end_of_centralPtr;
begin
  if (FZip64EOC = nil) then
    FZip64EOC := GetNewFZip64EOC;
  Result := FZip64EOC;
end;

function TEndCentral.FZip64EOCL_Instance: zip64_end_of_central_locatorPtr;
begin
  if (FZip64EOCL = nil) then
    FZip64EOCL := GetNewFZip64EOCL;
  Result := FZip64EOCL;
end;

{*****************  TSortedZip Methods *******************}

constructor TSortedZip.Create(WithDuplicates: TDuplicates);
begin
  inherited Create(WithDuplicates);
  SortMode := ByNone;
  FIsZip64 := False;
end;

Function TSortedZip.AddObject(Item: tObject): Integer;
var
  entry: TZipHeaderInfo;
begin
  Result := inherited AddObject(Item);
  if (not FIsZip64) then
  begin
    entry := Item as TZipHeaderInfo;
    if (entry.FZip64_Extended <> nil)
      then FIsZip64 := True;
  end;
end;


function TSortedZip.Compare(Key1, Key2: Pointer): Integer;
var
  K1: TZipHeaderInfo absolute Key1;
  K2: TZipHeaderInfo absolute Key2;
  tmpDateTime1, tmpDateTime2: TDateTime;
  tmpSize: LongInt;
begin
  case FSortMode of
    ByName:
      Result := kpCompareText(K1.directory + K1.filename, K2.directory + K2.filename);
    ByFileName:
      Result := kpCompareText(K1.filename, K2.filename);
    ByDirectoryName:
      Result := kpCompareText(K1.Directory, K2.directory);
    ByDate:
      begin
        try
          tmpDateTime1 := FileDateToDateTime(K1.last_mod_file_date_time);
        except
          tmpDateTime1 := 0;
        end;
        try
          tmpDateTime2 := FileDateToDateTime(K2.last_mod_file_date_time);
        except
          tmpDateTime2 := 0;
        end;
        if (tmpDateTime2 > tmpDateTime1) then
          Result := 1
        else
          Result := -1;
      end;
    ByCompressedSize:
      begin
        tmpSize := K2.compressed_size - K1.compressed_size;
        if (tmpSize > 0) then
          Result := 1
        else
          Result := -1;
      end;
    ByUnCompressedSize:
      begin
        tmpSize := K2.uncompressed_size - K1.uncompressed_size;
        if (tmpSize > 0) then
          Result := 1
        else
          Result := -1;
      end;
    ByRate:
      Result := CBigRate(K2.uncompressed_size, K2.compressed_size) -
        CBigRate(K1.uncompressed_size, K1.compressed_size);
    ByNone:
      begin
        Result := K1.disk_number_start - K2.disk_number_start;
        if Result = 0 then { modified 3/8/98 for 2.03 }
        begin { this fixed the duplicate object bug }
          if K1.relative_offset > K2.relative_offset then
            Result := 1
          else if K1.relative_offset = K2.relative_offset then
            Result := 0
          else
            Result := -1;
        end;
      end;
  else
    Result := -1;
  end;
{
 If Result = 0 then
  Result := -1;
}
end;

{$IFDEF KPDEMO}
function DRun: Boolean;
begin
   Result := (DebugHook <> 0);
end;
{$ENDIF}

procedure setZipSignatures(csig, lsig, esig: LongInt);
begin
  if csig = 0 then
    CENTSIG := DEF_CENTSIG
  else
    CENTSIG := csig;
  if lsig = 0 then
    LOCSIG := DEF_LOCSIG
  else
    LOCSIG := lsig;
  if esig = 0 then
    ENDSIG := DEF_ENDSIG
  else
    ENDSIG := esig;

  ZIP64EOC := DEF_ZIP64ENDSIG;
  ZIP64EOCL := DEF_ZIP64LOCATOR;

{
  DEF_CENTSIG = $02014b50;
  DEF_LOCSIG = $04034b50;
  DEF_ENDSIG = $06054b50;
  DEF_ZIP64ENDSIG = $06064b50;
  DEF_ZI64LOCATOR = $07064b50;
}
  LOC4 := LOBYTE(LOWORD(LOCSIG)); { $50;  Last byte of LOCSIG }
  LOC3 := HIBYTE(LOWORD(LOCSIG)); { $4b;  3rd byte of LOCSIG }
  LOC2 := LOBYTE(HIWORD(LOCSIG)); { $03;  2nd byte of LOCSIG }
  LOC1 := HIBYTE(HIWORD(LOCSIG)); { $04;  1st byte of LOCSIG }
  END4 := LOBYTE(LOWORD(ENDSIG)); { $50;  Last byte of ENDSIG }
end;

(*************************************************)
initialization
(*************************************************)
  setZipSignatures(0, 0, 0);

{ $Id: kpZipObj.pas,v 1.1 2001-08-12 17:30:40-04 kp Exp kp $ }

{ $Log:  10062: kpZipObj.pas 
{
{   Rev 1.8    5/1/2009 12:16:18 PM  Delphi 2009    Version: VCLZip Version 4.51
{ Temporary
}
{
{   Rev 1.7    11/30/2008 1:44:06 PM  Delphi7    Version: VCLZip Version 4.50
{ Modifications for 4.50
}
{
{   Rev 1.6    6/28/2008 1:33:34 PM  Delphi7    Version: VCLZip Pro 4.10 Beta
{ Added code to read Unicode filename extra field
}
{
{   Rev 1.5    4/17/2008 1:51:52 PM  Delphi7    Version: VCLZip Pro 4.10 Beta
{ Add getCompression_Method
}
{
{   Rev 1.4    12/27/2007 5:17:44 PM  Delphi7    Version: VCLZip Pro Encryption 4.0 b1
{ Remove some unused code
}
{
{   Rev 1.3    12/27/2007 4:42:02 PM  Delphi7    Version: VCLZip Pro Encryption 4.0 b1
{ Remove some unused code
}
{
{   Rev 1.2    4/28/2007 2:25:04 PM  Delphi7    Version: VCLZip Pro Encryption 4.0 b1
{ Simplify checking if running under IDE
}
{
{   Rev 1.1    2/12/2007 10:07:58 PM  Encryption
{ Add AES Encryption
}
{
{   Rev 1.0    8/14/2005 1:10:10 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.9.1.6    4/2/2005 4:58:20 PM  Supervisor    Version: VCLZip 3.X
{ ZLib 1.2.2 default
{ Fixed ZLibDecompressStream
{ Delphi 2005 compatible
{ Other assorted bug fixes
}
{
{   Rev 1.9.1.5    7/28/2004 8:54:30 PM  Supervisor    Version: VCLZip 3.X
{ TOEMConvert
}
{
{   Rev 1.9.1.4    7/27/2004 11:04:26 PM  Supervisor    Version: VCLZip 3.X
{ Added WinZip ansi/oem compatability
}
{
{   Rev 1.9.1.3    7/22/2004 12:41:02 PM  Supervisor    Version: VCLZip 3.X
{ Fixed greater than 65K files problem
{ Fixed problem when CD spanned parts
{ Fixed OperationMode settings
{ Fixed Zip64 EOCL
}
{
{   Rev 1.9.1.2    7/19/2004 7:56:04 PM  Supervisor    Version: VCLZip 3.X
{ Fixed problem with GetSize.
}
{
{   Rev 1.9.1.1    1/5/2004 11:31:06 PM  Supervisor    Version: VCLZip 3.X
{ Version_needed_to_extract
}
{
{   Rev 1.9.1.0    11/1/2003 1:30:02 PM  Supervisor    Version: VCLZip 3.X
{ Remove Bogus Headers
}
{
{   Rev 1.9    10/15/2003 10:23:56 PM  Supervisor    Version: VCLZip 3.X
{ Add return value to overloaded AddObject.
}
{
{   Rev 1.8    10/15/2003 5:50:24 PM  Supervisor    Version: VCLZip 3.X
{ Add isZip64 property to TSortedZip
}
{
{   Rev 1.7    5/20/2003 10:46:22 PM  Kevin    Version: VCLZip3.00z64c
}
{
{   Rev 1.6    5/20/2003 4:51:32 PM  Supervisor
{ fixed hints and warnings.  And fixed check for whether zip64eoc is needed.
}
{
{   Rev 1.5    5/19/2003 10:45:04 PM  Supervisor
{ After fixing streams.  VCLZip still uses ErrorRpt.  Also added setting of
{ capacity on the sorted containers to alleviate the memory problem caused by
{ growing array.
}
{
{   Rev 1.3    5/6/2003 6:11:40 PM  Supervisor
}
{
{   Rev 1.2    5/3/2003 6:33:32 PM  Supervisor
}
{
{   Rev 1.1    3/31/2003 6:17:54 PM  Supervisor    Version: VCLZip 3.00 Beta
}
{
{   Rev 1.0    10/15/2002 8:15:22 PM  Supervisor
}
{
{   Rev 1.3    9/7/2002 8:48:48 AM  Supervisor
{ Last modifications for FILE_INT
}
{
{   Rev 1.2    9/3/2002 11:32:46 PM  Supervisor
{ Mod for FILE_INT
}
{
{   Rev 1.1    9/3/2002 10:48:06 PM  Supervisor
{ Mod for FILE_INT
}
{
{   Rev 1.0    9/3/2002 8:16:54 PM  Supervisor
}
{ Revision 1.1  2001-08-12 17:30:40-04  kp
{ Initial revision
{
{ Revision 1.28  2000-12-16 16:50:07-05  kp
{ 2.21 Final Release 12/12/00
{
{ Revision 1.27  2000-06-04 15:59:56-04  kp
{ - Fixed typo in creation of LOC header values.
{ - Changed so FileZipCommentPos is based on end of record instead of end of file.
{ - Reformatted code
{
{ Revision 1.26  2000-05-21 18:44:50-04  kp
{ - Moved declaration of signature globals to here.
{ - Modified setZipSignatures to set default values when passed 0's as values.
{
{ Revision 1.25  2000-05-13 17:07:48-04  kp
{ - Added setZipSignatures procedure
{ - Added code to initialize signatures to default values in Initialization section
{
{ Revision 1.24  1999-11-09 19:41:40-05  kp
{ - Modified to correctly handle extra fields in headers
{ - Removed check for Object Inspector Window in IDE Check
{
{ Revision 1.23  1999-10-24 09:32:11-04  kp
{ - Changed ReadCentralFromStream so the stream passed in is a var parameter.
{
{ Revision 1.22  1999-10-17 12:00:50-04  kp
{ - Changed min and max to kpmin and kpmax
{
{ Revision 1.21  1999-09-16 20:07:56-04  kp
{ - Moved defines to KPDEFS.INC
{
{ Revision 1.20  1999-09-14 21:33:46-04  kp
{ - Added D5 compatibility conditionals
{
{ Revision 1.19  1999-08-25 19:04:01-04  kp
{ - Fixes for D1
{
{ Revision 1.18  1999-08-25 18:00:47-04  kp
{ - Can now open a zero length file as an empty archive.
{
{ Revision 1.17  1999-07-06 19:58:51-04  kp
{ - Added Selected to assign and initialization methods
{
{ Revision 1.16  1999-07-05 11:25:06-04  kp
{ <>
{
{ Revision 1.15  1999-06-27 13:56:10-04  kp
{ - Added the Selected property to the TZipHeaderInfo class
{
{ Revision 1.14  1999-06-06 19:56:57-04  kp
{ - Slight fix for the new sig consts
{
{ Revision 1.13  1999-06-02 10:26:29-04  kp
{ - Added constants for header signatures
{
{ Revision 1.12  1999-06-01 21:53:58-04  kp
{ - Added to the size of the buffer for looking for the end of central record for 32bit.
{
{ Revision 1.11  1999-04-24 21:16:15-04  kp
{ - Fixed small problem with IDE check in BCB4
{
{ Revision 1.10  1999-03-30 19:43:22-05  kp
{ - Modified so that defining MAKESMALL will create a much smaller component.
{
{ Revision 1.9  1999-03-22 17:30:20-05  kp
{ - moved kplib to USES list in implementation
{
{ Revision 1.8  1999-03-22 17:21:16-05  kp
{ - Moved comments to bottom
{
{ Revision 1.7  1999-03-20 11:46:42-05  kp
{ - Fixed problem where setting ZipComment to '' caused an access violation
{
{ Revision 1.6  1999-03-14 21:33:05-05  kp
{ - Made some mods for BCB4
{
{ Revision 1.5  1999-02-17 17:24:36-05  kp
{ Moved AssignTo methods to public instead of private for TZipHeaderInfo and TEndCentral
{
{ Revision 1.4  1999-02-08 21:42:50-05  kp
{ Version 2.17
{
{ Revision 1.3  1999-01-25 19:12:59-05  kp
{ Modifed compiler directives
{ }

{   7/9/98 6:47:20 PM
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
{  Mon 27 Apr 1998   17:30:52
{ Added call to new GoodTimeStamp.
}
{
{ Tue 10 Mar 1998   20:36:37
{ Modified the Compare procedure for the ByNone sort
{ because in Delphi 1 the integer wasn't big enough to
{ handle the difference operation which caused "duplicate
{ object" errors.
}

end.

