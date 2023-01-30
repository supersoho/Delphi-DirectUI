{ -----------------------------------------------------------------------------
  单元名： Jin_Utils
  作  者： 尹进
  说  明： 各种常用功能类或函数
  历  史： 2012-03-30 第一次创建
  ----------------------------------------------------------------------------- }
unit JinUtils;

interface

uses
  ExifInfo,
  ImageData, Gdiplus, DateUtils, IOUtils,
  WinApi.ShlObj, EncdDecd, WinApi.Windows, WinApi.Messages, SysUtils, VCL.Graphics, VCL.Forms,
  StrUtils, WinApi.ShellAPI,
  WinApi.ActiveX,
  VCL.Imaging.jpeg, PngImage2, VCL.Imaging.PngImage, System.Win.ComObj, Classes,
  GDIPUTIL, GDIPOBJ, GDIPAPI, Types,
  GR32, JwaMsi, WinApi.Tlhelp32, WinApi.PSAPI, VCL.Controls, System.Win.Registry, zlib, SevenZip, CnMD5,
  VCL.Imaging.gifimg,
  GR32_Resamplers, WinApi.mmsystem, DiskInfo,
  WinApi.Commctrl, VCL.Dialogs, VCL.Menus;

const
  BlankFileMD5 = 'FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF';

  SHIL_LARGE = $00;
  // The image size is normally 32x32 pixels. However, if the Use large icons option is selected from the Effects section of the Appearance tab in Display Properties, the image is 48x48 pixels.
  SHIL_SMALL = $01;
  // These images are the Shell standard small icon size of 16x16, but the size can be customized by the user.
  SHIL_EXTRALARGE = $02;
  // These images are the Shell standard extra-large icon size. This is typically 48x48, but the size can be customized by the user.
  SHIL_SYSSMALL = $03;
  // These images are the size specified by GetSystemMetrics called with SM_CXSMICON and GetSystemMetrics called with SM_CYSMICON.
  SHIL_JUMBO = $04;
  // Windows Vista and later. The image is normally 256x256 pixels.
  IID_IImageList: TGUID = '{46EB5926-582E-4017-9FDF-E8998DAA0950}';

  CCH_MAXNAME = 255; // 描述的缓冲区的大小

  LNK_RUN_MIN = 7; // 运行时最小化

  LNK_RUN_MAX = 3; // 运行是最大化

  LNK_RUN_NORMAL = 1; // 正常窗口

type
  PAlphaRGBTripleArray = ^TAlphaRGBTripleArray;
  TAlphaRGBTripleArray = array [0 .. 999] of TRGBQuad;
  TFileTimes = (ftLastAccess, ftLastWrite, ftCreation);

  TIconDirectoryEntry = packed record
    bWidth: Byte;
    bHeight: Byte;
    bColorCount: Byte;
    bReserved: Byte;
    wPlanes: Word;
    wBitCount: Word;
    dwBytesInRes: DWord;
    dwImageOffset: DWord;
  end;

  TIcondir = packed record
    idReserved: Word;
    idType: Word;
    idCount: Word;
    IdEntries: array [1 .. 20] of TIconDirectoryEntry;
  end;

  TjinTickCount = class
  private
    FFrequency, FStartTick, FEndTick: Int64;
  public
    constructor Create;
    destructor Destroy; override;

    procedure BeginGetMillisecond;
    function GetMillisecond: Extended;
    function GetStepValue(ATotalMillisecond, ATotalSpace: Integer;
      AMinStepTime: Integer = 5): Extended;
    procedure Wait(ATotalMillisecond, ATotalSpace, AStepValue: Extended;
      ASleep: Boolean = False);
  end;

  TRegNotifyChangeThread = class(TThread)
  private
    FNotifyEvent: THandle;
    FHKey: HKEY;
    FRootKey: HKEY;
    FKey: String;
    FOnChanged: TNotifyEvent;
    procedure DoChanged;
  protected
    procedure Execute; override;
  public
    constructor Create(ARootKey: HKEY; AKey: String);
    destructor Destroy; override;
    procedure StopWatch;

    property OnChanged: TNotifyEvent read FOnChanged write FOnChanged;
  end;

  TGetMD5ProgressEvent = procedure(Sender: TObject; ATotal, AProgress: Int64)
    of object;

  TGetMD5Thread = class(TThread)
  public
    FFile: String;
    FNeedTemp: Boolean;
    FExpMessage: String;
    FResult: String;
    FTotal, FProgress: Int64;
    FCanceled: Boolean;
    FOnProgress: TGetMD5ProgressEvent;
    FOnThreadBegin: TNotifyEvent;
    procedure MD5CalcProgressFunc(ATotal, AProgress: Int64;
      var Cancel: Boolean);
    procedure OnEnd;
  protected
    procedure Execute; override;
    procedure DoProgress(ATotal, AProgress: Int64);
    procedure DoThreadBegin;
  public
    constructor Create(AFile: String);
    destructor Destroy; override;
    procedure Cancel;
    property FileName: String read FFile write FFile;
    property Result: String read FResult;
    property Canceled: Boolean read FCanceled;
    property ExpMessage: String read FExpMessage;
    property OnProgress: TGetMD5ProgressEvent read FOnProgress
      write FOnProgress;
    property OnThreadBegin: TNotifyEvent read FOnThreadBegin
      write FOnThreadBegin;
  end;

  THintWin = class(THintWindow)
  private
    FParentHandle: THandle;
    FLastActive: THandle;
  public
    procedure ShowHint(hwnd: Cardinal; pt: TPoint; Const AHint: string);
    property ParentHandle: THandle read FParentHandle write FParentHandle;
  end;

  TJIN_TickCount = class
  private
    FFrequency, FStartTick, FEndTick: Int64;
  protected
  public
    constructor Create;
    destructor Destroy; override;

    procedure BeginGetMillisecond;
    function GetMillisecond: Extended;
    function GetStepValue(ATotalMillisecond, ATotalSpace: Integer;
      AMinStepTime: Integer = 5): Extended;
    procedure Wait(ATotalMillisecond, ATotalSpace, AStepValue: Extended;
      ASleep: Boolean = False);
  end;

  TOpenURLThread = class(TThread)
  private
    FURL: String;
    function Regkey(Key: HKEY; Subkey: String; var Data: String): Longint;
    procedure OpenURL(URL: string);
  protected
    procedure Execute; override;
  public
    constructor Create(AURL: String);
    destructor Destroy; override;
  end;

  TOpenImageThread = class(TThread)
  private
    FImageFileName: String;
  protected
    procedure Execute; override;
  public
    constructor Create(AImageFileName: String);
    destructor Destroy; override;
  end;

  TSFastRLE = class(TObject)
  private
    t, s: Pointer;
    function PackSeg(Source, Target: Pointer; SourceSize: Word): Word;
    function UnPackSeg(Source, Target: Pointer; SourceSize: Word): Word;
  protected
  public
    Constructor Create;
    Destructor Destroy; override;
    function Pack(Source, Target: Pointer; SourceSize: Longint): Longint;
    { Return TargetSize }
    function UnPack(Source, Target: Pointer; SourceSize: Longint): Longint;
    { Return TargetSize }
    function PackString(Source: AnsiString): AnsiString;
    function UnPackString(Source: AnsiString): AnsiString;
    function PackFile(SourceFileName, TargetFileName: String): Boolean;
    { Return FALSE if IOError }
    function UnPackFile(SourceFileName, TargetFileName: String): Boolean;
    { Return FALSE if IOError }
  end;

  TJinThread = class(TThread)
  public
    function WaitForTimeOut(ATimeOut: Integer): LongWord;
  end;

  TZoomAction = (zaMinimize, zaMaximize);
  T_ChangeWindowMessageFilter = function(uMessageID: UINT; bAllow: DWord)
    : Boolean; stdcall;

  LINK_FILE_INFO = record
    FileName: array [0 .. MAX_PATH] of AnsiChar; // 目标文件名
    WorkDirectory: array [0 .. MAX_PATH] of AnsiChar; // 工作目录或者起始目录
    IconLocation: array [0 .. MAX_PATH] of AnsiChar; // 图标文件名
    iconIndex: Integer; // 图标索引
    Arguments: array [0 .. MAX_PATH] of AnsiChar; // 程序运行的参数
    Description: array [0 .. CCH_MAXNAME] of AnsiChar; // 快捷方式的描述
    ItemIDList: PItemIDList; // 只供读取使用
    RelativePath: array [0 .. 255] of AnsiChar; // 相对目录，只能设置
    ShowState: Integer; // 运行时的窗口状态
    HotKey: Word; // 快捷键
  end;

  SHQUERYRBINFO = packed record
    cbSize: Integer; { 记录大小 }
    i64Size: Int64; { 回收站大小 }
    i64NumItems: Int64; { 回收站项数 }
  end;

  pshqueryrbinfo = ^SHQUERYRBINFO;

  TUnzipFileOverride = procedure(AFilename: String; var Cancel: Boolean)
    of Object;
  TUnzipFileEvent = procedure(AFilename: String) of Object;

  TProcessRecord = record
    PID: Cardinal;
    Name: string;
    ParentID: Cardinal;
    ThreadCount: Cardinal;
    PriClassBase: Integer;
  end;

  TImageType = (IT_None, IT_Error, IT_Bmp, IT_JPEG, IT_GIF, IT_PCX, IT_PNG,
    IT_PSD, IT_RAS, IT_SGI, IT_TIFF);

  TProcessArray = array of TProcessRecord;
  function GetProcessList(const IncludeThreads, IncludeWindows: Boolean) : TProcessArray;

{ 检索回收站信息 }
function SHQueryRecycleBinA(pszrtootpath: pansichar;
  QUERYRBINFO: pshqueryrbinfo): Integer; stdcall; external 'shell32';
function CheckTrashEmplty: Boolean;
function GetHTTPLocalPath: String;
function OpenSpecialFolder(Flag: Integer; Handle: hwnd = 0): Boolean;
function GetSpecialFolderDir(const folderid: Integer): string;
function ReplaceSystemReplaceID(AFile: string): string;
function GetSpecialFolderPIDL(const folderid: Integer): PItemIDList;
function GetFileLength(AFilename: String; ADenyWrite: Boolean): Int64;
function TestOpenFileForWrite(AFilename: String): Boolean;
function GetDirectorySize(Path: String): Integer;
procedure CopyDirectory(SrcPath, DstPath: String);
procedure DeleteDirectoryTree(APath: String);
function GetPYIndexString(ChString: AnsiString): string;
function ChnToPY(Value: AnsiString): string;
function GetDomainFromURL(AURL: String): String;

function GetDiskSize(ADisk: String): Int64;
function GetFreeDiskSize(ADisk: String): Int64;
function URLEncode(const s: UTF8String; const InQueryString: Boolean)
  : UTF8String;
function URLDecode(const s: UTF8String): UTF8String;
function BitmapToString(img: TBitmap): string;
function JpegToString(img: TJpegImage): string;
function PngToString(img: TPngImage): string;
function StreamToString(AStream: TStream): string;
function StringToStream(imgStr: string): TStream;
function StringToBitmap(imgStr: string): TBitmap;
function StringToJpeg(imgStr: string): TJpegImage;
function WinUserName: string;
function GetDesktopParentWindow: THandle;
function ForceForeGroundWindow(hwnd: THandle): Boolean;
procedure ChangeWindowMessageFilter(uMessageID: UINT);
// procedure ClearMemory(dwMinimumWorkingSetSize: DWORD = $FFFFFFFF; dwMaximumWorkingSetSize: DWORD = $FFFFFFFF);
procedure ClearMemory(dwMinimumWorkingSetSize: DWord = $1000000;
  dwMaximumWorkingSetSize: DWord = $2000000);
function GetFileTime(FileName: string; TimeFlag: Integer): TDateTime;

function ExtractIcons(ASrcFile, ADstFile: String; iconSize: Integer;
  iconIndex: Integer): Boolean;

procedure ImageToJpg(ABitmap: TBitmap32; ADstFile: String);
procedure ImageToPng(ABitmap: TBitmap32; ADstFile: String); overload;
procedure ImageToPng(ASrcFile, ADstFile: String); overload;
function ImageToPng(ASrcFile, ADstFile: String; AWidth, AHeight: Integer;
  AHighQulity: Boolean; ABackColor: TColor32 = $00000000;
  AGray: Boolean = False): Boolean; overload;

procedure GetPngByBitmap32(ABitmap32: TBitmap32; APngImage: TPngImage);
  overload;
procedure GetPngByBitmap32(ABitmap32: TBitmap32;
  APngImage: PngImage2.TPngImage); overload;
procedure IconHandleToPng(AIconHandle: Integer; ADstFile: String);
Procedure GetIconFromFileExt(AFile: String; var aIcon: TIcon);
procedure GetFileIcon(ASrcFile, ADstFile: String);
procedure GetFileIconToPng(ASrcFile, ADstFile: String);
function GetLinkFileName(sLinkFileName: String;
  out sTargetFileName: String): Boolean;
procedure getExecData(lnkName: String; var execName: String);
procedure GetThumbnailImage(ASrcFile, ADstFile: String; iconSize: Integer;
  fast: Boolean = False);
procedure GetThumbnailImageByGDIPlus(ASrcFile, ADstFile: String;
  iconSize: Integer);
function GetThumbnailJpegImageByGDIPlus(ASrcFile, ADstFile: String;
  iconSize: Integer; AQuality: Integer = 75): Boolean;
function GetThumbnailBitmap32ByGDIPlus(ASrcFile: String; iconSize: Integer;
  var scale: Boolean; ABackColor: TColor32 = $00000000): TBitmap32;
function GetJpegFile(ABitmap32: TBitmap32): TJpegImage; overload;
procedure GetJpegFile(ABitmap32: TBitmap32; AJpegFile: String); overload;
procedure GetJpegFile(ABitmap32: TBitmap32; ARect: TRect; AJpegFile: String); overload;
procedure GetJpegFile(ABitmap: TBitmap; AJpegFile: String); overload;
procedure GetJpegFile(ABitmapFile, AJpegFile: String); overload;
procedure GetPngFile(ABitmap32: TBitmap32; APngFile: String; ASize: Integer = 0;
  ABackColor: TColor32 = $00000000; AHiQuality: Boolean = True); overload;
procedure GetPngFile(ABitmap: TBitmap; APngFile: String); overload;
function GetBitmap32(AFile: String): TBitmap32;
function GetBitmap32ByBitmap(ABitmap: TBitmap): TBitmap32;
procedure ResizeBitmap32(ABitmap32: TBitmap32; AWidth, AHeight: Integer;
  AHiQuality: Boolean);
procedure SaveImageTo(ASrcFile, ADstFile: String);

procedure GetJPGSize(const sFile: string; var wWidth, wHeight: Word);
procedure GetPNGSize(const sFile: string; var wWidth, wHeight: Word);
procedure GetIMGSize(const sFile: string; var wWidth, wHeight: Word);
procedure GetGIFSize(const sGIFFile: string; var wWidth, wHeight: Word);
function CheckIfGIF(const sFile: string): Boolean;
function FetchBitmapHeader(PictFileName: String; Var wd, ht: Word): Boolean;

function GetIconFromPngFile(AFile: String): TIcon;
function GetIconFromPngFile2(AFile: String): TIcon;
function GetIconFromPngImage(APngImage: TPngImage): TIcon;
procedure SetFormIconsFile(FormHandle: hwnd; AFile: String);
procedure SetFormIconsByIconHandle(FormHandle: hwnd; hIconS, hIconL: Integer);
procedure SetFormIconsByRes(AResHandle: THandle; FormHandle: hwnd;
  SmallIconName, LargeIconName: string);

function GetLinksDirInWin7: String;
procedure CreateLink(const lnkFile, Target, arg, workdir, Description: String;
  icon: String; iconIndex: Integer);

function LinkFileInfo(const lnkFileName: string; var info: LINK_FILE_INFO;
  const bSet: Boolean): Boolean;
function CreateLinkFile(const info: LINK_FILE_INFO;
  const DestFileName: string = ''): Boolean;
function ShortCutToString(const HotKey: Word): string;

function SystemDeleteFiles(const Source: string; Silent: Boolean = False;
  ToTrash: Boolean = True): Boolean;
function GetRemovableLogicalDrives: WideString;
function GetHarddiskDrives: WideString;
procedure GetHardDiskPartitionInfo(const DriveLetter: Char;
  var VolumeName, VolumeSerialNumber, PartitionType: string;
  var TotalSpace, TotalFreeSpace: Int64);

function ShortPathToLongPath(const AShortName: string): string;

function PrivateExtractIcons(lpszFile: PWideChar;
  nIconIndex, cxIcon, cyIcon: Integer; phicon: PHandle; piconid: PDWORD;
  nIcons, flags: DWord): DWord; stdcall;
  external 'User32.dll' name 'PrivateExtractIconsW';

Procedure GetIconFromFile(AFile: String; var aIcon: TIcon; SHIL_FLAG: Cardinal);
function GetLongPathName(Src, Dest: PChar; cch: DWord): DWord; stdcall;
  external 'Kernel32.dll' name 'GetLongPathNameW';
function Wow64DisableWow64FsRedirection(out OldValue: PVOID): BOOL; stdcall;
  external 'Kernel32.dll' delayed;
function Wow64RevertWow64FsRedirection(const OldValue: PVOID): BOOL; stdcall;
  external 'Kernel32.dll' delayed; // only for JWA &lt; 2.4

function WaitExecute(const FileName, Parameters, Directory: string;
  ShowWindow: Cardinal; AWaitExit: Boolean; var ExitCode: Cardinal): Boolean;
function CreateOneDir(ADir: String): Boolean;
function CheckUnZipedFile(AZipFile, ADestDir: String; APass: String = ''): Boolean;
function UnZip(AZipFile, ADestDir: String; APass: String = ''; UnzipFileOverride: TUnzipFileOverride = nil; UnzipFileEvent: TUnzipFileEvent = nil): Boolean;
function ZipString(AText: String): String;
function UnZipString(AText: String): String;
function GetFileVersion(FileName: string): string;
function IsNumberic(Vaule: String): Boolean;
procedure StreachDraw(SrcBitmap, DstBitmap: GR32.TBitmap32;
  ASrcRect, ADstRect: TRect; ALowQuality: Boolean = False);
procedure PlayWaveSound(FileName: string);
function SetFileLastAccess(const FileName: string;
  const DateTime: TDateTime): Boolean;
function SetFileLastWrite(const FileName: string;
  const DateTime: TDateTime): Boolean;
function SetFileCreation(const FileName: string;
  const DateTime: TDateTime): Boolean;
function GetBitmap32ByPngImage(APngImage: PngImage2.TPngImage;
  ABitmap32: GR32.TBitmap32 = nil; ABackground: TColor32 = $00000000): GR32.TBitmap32; overload;
function GetBitmap32ByPngImage(APngImage: TPngImage;
  ABitmap32: GR32.TBitmap32 = nil): GR32.TBitmap32; overload;

function GetStdGPImageByBitmap(ABitmap: GR32.TBitmap32): TGPImage;
function GetGPImageByBitmap(ABitmap: GR32.TBitmap32): Gdiplus.TGPBitmap;
function GetGPImageByBitmapArea(ABitmap: GR32.TBitmap32; X, Y, W, H: Integer)
  : Gdiplus.TGPBitmap;

procedure CopyImageFromHandle(wnd: Cardinal; const Abmp: TBitmap32);
procedure Bitmap32PArgbConvertArgb(ABitmap: GR32.TBitmap32; iTimes: Integer = 1); overload;
procedure Bitmap32PArgbConvertArgb(ABitmap: GR32.TBitmap32;
  X, Y, W, H: Integer); overload;

function GetWorkAreaRect: TRect;
function GetWorkAreaLeft: Integer;
function GetWorkAreaTop: Integer;
function GetWorkAreaWidth: Integer;
function GetWorkAreaHeight: Integer;

function GetRandomID: String;

function CompareStrASM(const S1, S2: string): Integer;
function CompareString(AText, BText: String): Integer;

procedure ZLibCompress(const inBuffer: Pointer; inSize: Integer;
  const outBuffer: Pointer; out outSize: Integer; level: TZCompressionLevel);
procedure ZLibDecompress(const inBuffer: Pointer; inSize: Integer;
  const outBuffer: Pointer; out outSize: Integer);
function EncodeString(const Input: string): string;
function cursorstoptime:integer;//返回没有键盘和鼠标事件的时间,以1/1000秒为单位
function CheckFileHasAccess(const FileName: string): Boolean;
function CheckDirHasAccess(const DirName: string): Boolean;
function GetFileContent(AStream: TStream): String; overload;
function GetFileContent(AFile: String): String; overload;

function CheckImageType(FileName: string): TImageType;

function GetJpegOrientation(AFile: String): TExifOrientation;
procedure FixBitmap32Orientation(ABitmap32: TBitmap32; AOrientation: TExifOrientation);

function DeCompressStream(AStream: TMemoryStream): TMemoryStream;
function CompressStream(ASrcStream:  TMemoryStream): TMemoryStream;
function FastCompressStream(ASrcStream:  TMemoryStream): TMemoryStream;

function ProcessRunning(AFile: String): Boolean;
function IsFileInUse(fName : string) : boolean;


function CheckNetFrameWork(sVersion:string): Boolean;   //if CheckNetFrameWork('v4') or CheckNetFrameWork('v4.0') then

procedure WriteSet(AKey, AValue: String);
function ReadSet(AKey: String): String;
function GetStringByDatTime(DateTime: TDateTime): String;

var
  IsVista, Is64Bit: Boolean;
  EnableLogDebug: Boolean;

implementation

var
  FSection: TRTLCriticalSection;
  FLogSection: TRTLCriticalSection;
  FMD5Section: TRTLCriticalSection;
  AlphaMatrix: TColorMatrix = ((1.0, 0.0, 0.0, 0.0, 0.0),
    (0.0, 1.0, 0.0, 0.0, 0.0), (0.0, 0.0, 1.0, 0.0, 0.0),
    (0.0, 0.0, 0.0, 1.0, 0.0), (0.0, 0.0, 0.0, 0.0, 1.0));

const
  EncodeTable: array [0 .. 63] of AnsiChar = AnsiString
    ('ABCDEFGHIJKLMNOPQRSTUVWXYZ') + AnsiString('abcdefghijklmnopqrstuvwxyz') +
    AnsiString('0123456789+/');

  DecodeTable: array [#0 .. #127] of Integer = (Byte('='), 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
    64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 62,
    64, 64, 64, 63, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 64, 64,
    64, 64, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
    19, 20, 21, 22, 23, 24, 25, 64, 64, 64, 64, 64, 64, 26, 27, 28, 29, 30, 31,
    32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50,
    51, 64, 64, 64, 64, 64);

type
  PPacket = ^TPacket;

  TPacket = packed record
    case Integer of
      0:
        (b0, b1, b2, b3: Byte);
      1:
        (i: Integer);
      2:
        (a: array [0 .. 3] of Byte);
      3:
        (c: array [0 .. 3] of AnsiChar);
  end;


const
  FILE_READ_DATA = $0001;
  FILE_WRITE_DATA = $0002;
  FILE_APPEND_DATA = $0004;
  FILE_READ_EA = $0008;
  FILE_WRITE_EA = $0010;
  FILE_EXECUTE = $0020;
  FILE_READ_ATTRIBUTES = $0080;
  FILE_WRITE_ATTRIBUTES = $0100;
  FILE_GENERIC_READ = (STANDARD_RIGHTS_READ or FILE_READ_DATA or
    FILE_READ_ATTRIBUTES or FILE_READ_EA or SYNCHRONIZE);
  FILE_GENERIC_WRITE = (STANDARD_RIGHTS_WRITE or FILE_WRITE_DATA or
    FILE_WRITE_ATTRIBUTES or FILE_WRITE_EA or FILE_APPEND_DATA or SYNCHRONIZE);
  FILE_GENERIC_EXECUTE = (STANDARD_RIGHTS_EXECUTE or FILE_READ_ATTRIBUTES or
    FILE_EXECUTE or SYNCHRONIZE);
  FILE_ALL_ACCESS = STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $1FF;

function ReadSet(AKey: String): String;
var
  TempReg: TRegistry;
  AGUID: TGUID;
begin
  Result := '';
  try
    TempReg := TRegistry.Create;
    try
      TempReg.RootKey := HKEY_CURRENT_USER;
      if TempReg.OpenKey('\Software\' + ExtractFileName(Application.ExeName) + '\Sets', True) then
      begin
        if TempReg.ValueExists(AKey) then Result := TempReg.ReadString(AKey);
      end;
    finally
      TempReg.Free;
    end;
  except
  end;
end;

procedure WriteSet(AKey, AValue: String);
var
  TempReg: TRegistry;
  AGUID: TGUID;
begin
  try
    TempReg := TRegistry.Create;
    try
      TempReg.RootKey := HKEY_CURRENT_USER;
      if TempReg.OpenKey('\Software\' + ExtractFileName(Application.ExeName) + '\Sets', True) then
      begin
        TempReg.WriteString(AKey, AValue);
      end;
    finally
      TempReg.Free;
    end;
  except
  end;
end;

function GetStringByDatTime(DateTime: TDateTime): String;
var
  ASetting: TFormatSettings;
begin
  GetLocaleFormatSettings(GetUserDefaultLCID, ASetting);
  ASetting.ShortDateFormat := 'yyyy-MM-dd';
  ASetting.DateSeparator := '-';
  ASetting.TimeSeparator := ':';
  ASetting.LongTimeFormat := 'hh:mm:ss';

  Result := DateTimeToStr(DateTime, ASetting);
end;

function CheckNetFrameWork(sVersion:string): Boolean;
var
  ff:boolean;
  sqlstr,DBServerName,DBName,DBID,DBPwd:string;
  reg:TRegistry;
begin
  Result := False;
  try
    Reg:= TRegistry.Create;
    try
      Reg.RootKey := HKEY_LOCAL_MACHINE ;
      if Reg.OpenKeyReadOnly('\Software\Microsoft\NET Framework Setup\NDP\'+sVersion) then
      begin
        Result := True;
        reg.CloseKey;
      end
    finally
      reg.Free;
    end;
  except
  end;
end;

function IsFileInUse(fName: string): Boolean;
var
  HFileRes: HFILE;
begin
  Result := False; // 返回值为假(即文件不被使用)
  if not FileExists(fName) then
    exit; // 如果文件不存在则退出
  HFileRes := CreateFile(PChar(fName), GENERIC_READ or GENERIC_WRITE,
    0 { this is the trick! } , nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
   Result := (HFileRes = INVALID_HANDLE_VALUE); //如果CreateFile返回失败 那么Result为真(即文件正在被使用)
   if not Result then //如果CreateFile函数返回是成功
   CloseHandle(HFileRes);   //那么关闭句柄
end;

function CheckFileAccess(const FileName: string; const CheckedAccess: Cardinal): Cardinal;
var Token: THandle;
    Status: LongBool;
    Access: Cardinal;
    SecDescSize: Cardinal;
    PrivSetSize: Cardinal;
    PrivSet: PRIVILEGE_SET;
    Mapping: GENERIC_MAPPING;
    SecDesc: PSECURITY_DESCRIPTOR;
begin
  Result := 0;
  GetFileSecurity(PChar(Filename), OWNER_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION, nil, 0, SecDescSize);
  SecDesc := GetMemory(SecDescSize);

  if GetFileSecurity(PChar(Filename), OWNER_SECURITY_INFORMATION or GROUP_SECURITY_INFORMATION or DACL_SECURITY_INFORMATION, SecDesc, SecDescSize, SecDescSize) then
  begin
    ImpersonateSelf(SecurityImpersonation);
    OpenThreadToken(GetCurrentThread, TOKEN_QUERY, False, Token);
    if Token <> 0 then
    begin
      Mapping.GenericRead := FILE_GENERIC_READ;
      Mapping.GenericWrite := FILE_GENERIC_WRITE;
      Mapping.GenericExecute := FILE_GENERIC_EXECUTE;
      Mapping.GenericAll := FILE_ALL_ACCESS;

      MapGenericMask(Access, Mapping);
      PrivSetSize := SizeOf(PrivSet);
      AccessCheck(SecDesc, Token, CheckedAccess, Mapping, PrivSet, PrivSetSize, Access, Status);
      CloseHandle(Token);
      if Status then
        Result := Access;
    end;
  end;

  FreeMem(SecDesc, SecDescSize);
end;

function GetProcessList2(const IncludeThreads, IncludeWindows: Boolean)
  : TProcessArray;
var
  hSnapshot: THandle;
  i: Integer;
  // Threads: TpzThreadArray;
  pe: TProcessEntry32;
  // m: Cardinal;
  hProcess: THandle;
  _hModule: HMODULE;
  needed: Cardinal;
  buffer: array [0 .. MAX_PATH] of Char;
begin
  Result := nil;

  hSnapshot := CreateToolHelp32Snapshot(TH32CS_SnapProcess, 0);
  if hSnapshot = INVALID_HANDLE_VALUE then
    Exit;

  try
    ZeroMemory(@pe, SizeOf(pe));
    pe.dwSize := SizeOf(pe);

    if Process32First(hSnapshot, pe) then
      repeat
        //if pe.cntThreads > 5 then
        begin
          SetLength(Result, Length(Result) + 1);
          i := High(Result);
          Result[i].PID := pe.th32ProcessID;
          Result[i].Name := pe.szExeFile;
          Result[i].ParentID := pe.th32ParentProcessID;
          Result[i].ThreadCount := pe.cntThreads;
          Result[i].PriClassBase := pe.pcPriClassBase;
        end;

        hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
          False, pe.cntThreads);
        if hProcess <> 0 then
        begin
          if EnumProcessModules(hProcess, @_hModule, SizeOf(HMODULE), needed)
          then
            if GetModuleFileNameEx(hProcess, _hModule, @buffer[0], MAX_PATH) > 0
            then
              if GetLongPathName(@buffer[0], @buffer[0], MAX_PATH) > 0 then
                Result[i].Name := PChar(@buffer[0]);

          CloseHandle(hProcess);
        end;
        //OutputDebugString(PChar(Result[i].Name));
      until not Process32Next(hSnapshot, pe);

  finally
    CloseHandle(hSnapshot);
  end;
end;

function ProcessRunning(AFile: String): Boolean;
var
  AProcess: TProcessRecord;
  AProcessArray: TProcessArray;
  iLoop: Integer;
begin
  Result := False;
  AProcessArray := GetProcessList2(False, False);
  for iLoop := Low(AProcessArray) to High(AProcessArray) do
  begin
    AProcess := AProcessArray[iLoop];
    if SameText(AProcess.Name, AFile) then
    begin
      Exit(True);
    end;
  end;
end;

function IsDirectoryWriteable(const AName: string): Boolean;
var
  i: Integer;
  FileName: String;
  H: THandle;
begin
  i := 1;
  repeat
    FileName := IncludeTrailingPathDelimiter(AName) + 'temp_access' + IntToStr(i) + '.tmp';
    Inc(i);
  until not FileExists(FileName);

  H := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE, 0, nil,
    CREATE_NEW, FILE_ATTRIBUTE_TEMPORARY or FILE_FLAG_DELETE_ON_CLOSE, 0);
  try
    Result := H <> INVALID_HANDLE_VALUE;
    if Result then CloseHandle(H);
  finally
    DeleteFile(FileName);
  end;
end;

function CheckFileHasAccess(const FileName: string): Boolean;
begin
  Result := CheckDirHasAccess(ExtractFilePath(FileName));
end;

function CheckDirHasAccess(const DirName: string): Boolean;
begin
  Result := CheckFileAccess(DirName, FILE_GENERIC_WRITE) = FILE_GENERIC_WRITE;
  if Result then Result := IsDirectoryWriteable(DirName);

end;

function cursorstoptime:integer;//返回没有键盘和鼠标事件的时间,以1/1000秒为单位
var
  linput:tlastinputinfo;
begin
  linput.cbSize:=sizeof(tlastinputinfo);
  getlastinputinfo(linput);
  result:=gettickcount()-linput.dwTime;
end;

function GetFileContent(AStream: TStream): String; overload;
var
  str: AnsiString;
  wstr: Widestring;
  Len: Integer;
begin
  AStream.Position := 0;
  Len := AStream.Size;
  setLength(str, 3);
  AStream.Read(str[1], 3);
  if copy(str, 1, 2) = #$FF#$FE then
  begin
    // Unicode编码=====================
    wstr := '';
    AStream.Position := 2;
    setLength(str, Len - 2);
    AStream.Read(str[1], Len - 2);
    if (Length(str) >= 2) then
    begin
      setLength(wstr, Length(str) div 2 + Length(str) mod 2);
      Move(str[1], wstr[1], Length(str));
    end;
    Result := wstr;
    exit;
  end
  else if str = #$EF#$BB#$BF then
  begin
    // UTF8编码========================
    setLength(str, Len - 3);
    AStream.Read(str[1], Len - 3);
    Result := Utf8ToUnicodeString(str);
    exit;
  end
  else
  begin
    SetLength(str, AStream.Size);
    AStream.Position := 0;
    AStream.Read(str[1], AStream.Size);
    Result := String(str);
  end;
end;

function GetFileContent(AFile: String): String; overload;
var
  str: AnsiString;
  wstr: Widestring;
  fs: TFileStream;
  Len: Integer;
begin
  fs := TFileStream.Create(AFile, fmShareDenyNone or fmOpenRead);
  try
    Result := GetFileContent(fs);
  finally
    fs.Free;
  end;
end;

function FastCompressStream(ASrcStream:  TMemoryStream): TMemoryStream;
var
  ADzStream: TMemoryStream;
  ADstStream: TMemoryStream;
  iLength: Integer;
  pDst: Pointer;
begin
    ADstStream := TMemoryStream.Create;
    try
      ASrcStream.Position := 0;
      pDst := nil;
      ZCompress(ASrcStream.Memory, ASrcStream.Size, pDst, iLength, zcFastest);
      ADstStream.Size := iLength;
      CopyMemory(ADstStream.Memory, pDst, iLength);
      FreeMem(pDst, iLength);

      ADstStream.Position := 0;
    finally
      Result := ADstStream;
    end;
end;

function CompressStream(ASrcStream:  TMemoryStream): TMemoryStream;
var
  ADzStream: TMemoryStream;
  ADstStream: TMemoryStream;
  iLength: Integer;
  pDst: Pointer;
begin
    ADstStream := TMemoryStream.Create;
    try
      ASrcStream.Position := 0;
      pDst := nil;
      ZCompress(ASrcStream.Memory, ASrcStream.Size, pDst, iLength, zcMax);
      ADstStream.Size := iLength;
      CopyMemory(ADstStream.Memory, pDst, iLength);
      FreeMem(pDst, iLength);

      ADstStream.Position := 0;
    finally
      Result := ADstStream;
    end;
end;

function DeCompressStream(AStream: TMemoryStream): TMemoryStream;
var
  iLength: Integer;
  pDst: Pointer;
  ADstStream: TMemoryStream;
begin
    Result := TMemoryStream.Create;
    AStream.Position := 0;
    ZDeCompress(AStream.Memory, AStream.Size, pDst, iLength);
    Result.Size := iLength;
    CopyMemory(Result.Memory, pDst, iLength);
    FreeMem(pDst, iLength);
    Result.Position := 0;
end;

function TJinThread.WaitForTimeOut(ATimeOut: Integer): LongWord;
var
  AHandle: THandle;
  WaitResult: Cardinal;
  Msg: TMsg;
  iTicket: Integer;
begin
  AHandle := Handle;

  WaitResult := 0;
  iTicket := GetTickCount;
  repeat
    WaitResult := WaitForSingleObject(AHandle, 30);
    CheckThreadError(WaitResult <> WAIT_FAILED);
    Application.ProcessMessages;
  until (WaitResult = WAIT_OBJECT_0) or (GetTickCount - iTicket > ATimeOut);

  CheckThreadError(GetExitCodeThread(AHandle, Result));
end;

{$REGION 'TjinTickCount'}

constructor TjinTickCount.Create;
begin

end;

destructor TjinTickCount.Destroy;
begin
  inherited Destroy;
end;

procedure TjinTickCount.BeginGetMillisecond;
begin
  QueryPerformanceFrequency(FFrequency);
  QueryPerformanceCounter(FStartTick);
end;

function TjinTickCount.GetMillisecond: Extended;
begin
  QueryPerformanceCounter(FEndTick);
  Result := ((FEndTick - FStartTick) / FFrequency) * 1000;
end;

function TjinTickCount.GetStepValue(ATotalMillisecond, ATotalSpace: Integer;
  AMinStepTime: Integer = 5): Extended;
begin
  Result := Round(ATotalSpace / (ATotalMillisecond / GetMillisecond));
  if Result > ATotalSpace / AMinStepTime then
    Result := ATotalSpace / AMinStepTime;
  if Result < 1 then
    Result := 1;
end;

procedure TjinTickCount.Wait(ATotalMillisecond, ATotalSpace,
  AStepValue: Extended; ASleep: Boolean = False);
begin
  if ATotalSpace = 0 then
    Exit;

  while GetMillisecond < ATotalMillisecond / (ATotalSpace / AStepValue) do
  begin
    if ASleep then
    begin
      Sleep(1);
    end;
  end;
end;
{$ENDREGION}

{$REGION 'ZLib相关'}

function ZLibCompressCheck(code: Integer): Integer;
begin
  Result := code;

  if code < 0 then
  begin
    raise EZCompressionError.Create(string(_z_errmsg[2 - code]));
  end;
end;

function ZLibDecompressCheck(code: Integer): Integer;
begin
  Result := code;

  if code < 0 then
  begin
    raise EZDecompressionError.Create(string(_z_errmsg[2 - code]));
  end;
end;

procedure ZLibCompress(const inBuffer: Pointer; inSize: Integer;
  const outBuffer: Pointer; out outSize: Integer; level: TZCompressionLevel);
const
  delta = 256;
var
  zstream: TZStreamRec;
begin
  FillChar(zstream, SizeOf(TZStreamRec), 0);

  outSize := ((inSize + (inSize div 10) + 12) + 255) and not 255;
  try
    zstream.next_in := inBuffer;
    zstream.avail_in := inSize;
    zstream.next_out := outBuffer;
    zstream.avail_out := outSize;

    ZLibCompressCheck(DeflateInit(zstream, ZLevels[level]));

    try
      while ZLibCompressCheck(deflate(zstream, Z_FINISH)) <> Z_STREAM_END do
      begin
        Inc(outSize, delta);
        zstream.next_out := PByte(outBuffer) + zstream.total_out;
        zstream.avail_out := delta;
      end;
    finally
      ZLibCompressCheck(deflateEnd(zstream));
    end;
    outSize := zstream.total_out;
  except
    raise;
  end;
end;

procedure ZLibDecompress(const inBuffer: Pointer; inSize: Integer;
  const outBuffer: Pointer; out outSize: Integer);
var
  zstream: TZStreamRec;
  delta: Integer;
begin
  FillChar(zstream, SizeOf(TZStreamRec), 0);

  delta := (inSize + 255) and not 255;
  outSize := delta;

  try
    zstream.next_in := inBuffer;
    zstream.avail_in := inSize;
    zstream.next_out := outBuffer;
    zstream.avail_out := outSize;

    ZLibDecompressCheck(InflateInit(zstream));

    try
      while ZLibDecompressCheck(inflate(zstream, Z_NO_FLUSH)) <> Z_STREAM_END do
      begin
        Inc(outSize, delta);
        zstream.next_out := PByte(outBuffer) + zstream.total_out;
        zstream.avail_out := delta;
      end;
    finally
      ZLibDecompressCheck(inflateEnd(zstream));
    end;
    outSize := zstream.total_out;
  except
    raise;
  end;
end;
{$ENDREGION}

function CompareString(AText, BText: String): Integer;
var
  iLoop: Integer;
  AAnsiText, BAnsiText: AnsiString;
begin
  Result := 0;
  AAnsiText := AnsiString(AText);
  BAnsiText := AnsiString(BText);
  iLoop := 1;
  while (iLoop <= Length(AAnsiText)) and (iLoop <= Length(BAnsiText)) do
  begin
    if AAnsiText[iLoop] <> BAnsiText[iLoop] then
    begin
      Result := Word(AAnsiText[iLoop]) - Word(BAnsiText[iLoop]);
      Exit;
    end;
    Inc(iLoop);
  end;

  if Length(AAnsiText) > Length(BAnsiText) then
    Result := 1
  else if Length(AAnsiText) < Length(BAnsiText) then
    Result := -1;
end;

function CompareStrASM(const S1, S2: string): Integer;
asm // StackAligned
  { On entry:
  eax = @S1[1]
  edx = @S2[1]
  On exit:
  Result in eax:
  0 if S1 = S2,
  > 0 if S1 > S2,
  < 0 if S1 < S2
  Code size:
  101 bytes }
  CMP EAX, EDX
  JE @SameString
  { Is either of the strings perhaps nil? }
  TEST EAX, EDX
  JZ @PossibleNilString
  { Compare the first four characters (there has to be a trailing #0). In random
  string compares this can save a lot of CPU time. }
@BothNonNil:
  { Compare the first character }
  MOVZX ECX, WORD PTR [EDX]
  CMP CX, [EAX]
  JE @FirstCharacterSame
  { First character differs }
  MOVZX EAX, WORD PTR [EAX]
  SUB EAX, ECX
  JMP @Done
@FirstCharacterSame:
  { Save ebx }
  PUSH EBX
  { Set ebx = length(S1) }
  MOV EBX, [EAX - 4]
  XOR ECX, ECX
  { Set ebx = length(S1) - length(S2) }
  SUB EBX, [EDX - 4]
  { Save the length difference on the stack }
  PUSH EBX
  { Set ecx = 0 if length(S1) < length(S2), $ffffffff otherwise }
  ADC ECX, -1
  { Set ecx = - min(length(S1), length(S2)) }
  AND ECX, EBX
  SUB ECX, [EAX - 4]
  SAL ECX, 1
  { Adjust the pointers to be negative based }
  SUB EAX, ECX
  SUB EDX, ECX
@CompareLoop:
  MOV EBX, [EAX + ECX]
  XOR EBX, [EDX + ECX]
  JNZ @Mismatch
  ADD ECX, 4
  JS @CompareLoop
  { All characters match - return the difference in length }
@MatchUpToLength:
  POP EAX
  POP EBX
@Done:
  RET
@Mismatch:
  BSF EBX, EBX
  SHR EBX, 4
  ADD EBX, EBX
  ADD ECX, EBX
  JNS @MatchUpToLength
  MOVZX EAX, WORD PTR [EAX + ECX]
  MOVZX EDX, WORD PTR [EDX + ECX]
  SUB EAX, EDX
  POP EBX
  POP EBX
  JMP @Done
  { It is the same string }
@SameString:
  XOR EAX, EAX
  RET
  { Good possibility that at least one of the strings are nil }
@PossibleNilString:
  TEST EAX, EAX
  JZ @FirstStringNil
  TEST EDX, EDX
  JNZ @BothNonNil
  { Return first string length: second string is nil }
  MOV EAX, [EAX - 4]
  RET
@FirstStringNil:
  { Return 0 - length(S2): first string is nil }
  SUB EAX, [EDX - 4]
end;

function GetRandomID: String;
var
  GUID: TGUID;
begin
  CoInitialize(nil);
  try
    CoCreateGUID(GUID);
    Result := MD5Print(CnMD5.MD5String(GUIDToString(GUID)));
  finally
    CoUninitialize;
  end;
end;

function GetWorkAreaLeft: Integer;
begin
  Result := GetWorkAreaRect.Left;
end;

function GetWorkAreaTop: Integer;
begin
  Result := GetWorkAreaRect.Top;
end;

function GetWorkAreaWidth: Integer;
begin
  Result := GetWorkAreaRect.Width;
end;

function GetWorkAreaHeight: Integer;
begin
  Result := GetWorkAreaRect.Height;
end;

function GetWorkAreaRect: TRect;
var
  abd: TAPPBARDATA;
  hwndTaskBar: hwnd;
  nState: UINT;
  hdcScreen: HDC;
  AutoHide: Boolean;
begin
  try
    abd.cbSize := SizeOf(abd);
    hwndTaskBar := FindWindow('Shell_TrayWnd', NIL);
    abd.hwnd := hwndTaskBar;
    nState := SHAppBarMessage(ABM_GETSTATE, abd);
    SHAppBarMessage(ABM_GETTASKBARPOS, abd);

    AutoHide := (nState and ABS_AUTOHIDE) <> 0;

    if AutoHide then
    begin
      hdcScreen := CreateDC('DISPLAY', nil, nil, nil);
      Result.Left := 0;
      Result.Right := GetDeviceCaps(hdcScreen, HORZRES);

      Result.Top := 0;
      Result.Bottom := GetDeviceCaps(hdcScreen, VERTRES);
      DeleteDC(hdcScreen);
      Exit;
    end;

    case abd.uEdge of
      ABE_TOP:
        begin
          Result.Left := 0;
          Result.Right := abd.rc.Right;

          Result.Top := abd.rc.Bottom;

          hdcScreen := CreateDC('DISPLAY', nil, nil, nil);
          Result.Bottom := GetDeviceCaps(hdcScreen, VERTRES);
          DeleteDC(hdcScreen);
        end;

      ABE_BOTTOM:
        begin
          Result.Left := 0;
          Result.Right := abd.rc.Right;

          Result.Top := 0;
          Result.Bottom := abd.rc.Top;
        end;

      ABE_LEFT:
        begin
          hdcScreen := CreateDC('DISPLAY', nil, nil, nil);

          Result.Left := abd.rc.Left;
          Result.Right := GetDeviceCaps(hdcScreen, HORZRES);

          Result.Top := 0;
          Result.Bottom := abd.rc.Bottom;

          DeleteDC(hdcScreen);
        end;

      ABE_RIGHT:
        begin
          Result.Left := 0;
          Result.Right := abd.rc.Left;

          Result.Top := 0;
          Result.Bottom := abd.rc.Bottom;
        end;
    end;
  except
    Result := Screen.WorkAreaRect;
  end;


  // if((nState and ABS_ALWAYSONTOP) <> 0) then

  // if((nState and ABS_AUTOHIDE) <> 0) then
end;

procedure CopyImageFromHandle(wnd: Cardinal; const Abmp: TBitmap32);
var
  rec: TRect;
  FCanvas: TCanvas;
  DC: HDC;
begin
  GetWindowRect(wnd, rec);
  try
    Abmp.SetSize(rec.Right - rec.Left, rec.Bottom - rec.Top);

    FCanvas := TCanvas.Create();
    DC := GetDC(wnd);
    try
      FCanvas.Handle := DC;
      Abmp.Canvas.CopyRect(Rect(0, 0, Abmp.Width, Abmp.Height), FCanvas,
        Rect(rec.Left, rec.Top, rec.Right, rec.Bottom));
    finally
      FCanvas.Free;
      ReleaseDC(wnd, DC);
    end;
  finally
  end;
end;


procedure Bitmap32PArgbConvertArgb(ABitmap: GR32.TBitmap32; iTimes: Integer = 1); inline;
var
  AGPBitmap: Gdiplus.TGPBitmap;
  AImageData: TImageData;
  ASetted: Boolean;
  iLoop: Integer;
begin
  AGPBitmap := GetGPImageByBitmap(ABitmap);
  AImageData := LockGpBitmap(AGPBitmap);
  for iLoop := 1 to iTimes do PArgbConvertArgb(AImageData);
  UnlockGpBitmap(AGPBitmap, AImageData);
end;

procedure Bitmap32PArgbConvertArgb(ABitmap: GR32.TBitmap32;
  X, Y, W, H: Integer); inline;
var
  AGPBitmap: Gdiplus.TGPBitmap;
  AImageData: TImageData;
  ASetted: Boolean;
begin
  AGPBitmap := GetGPImageByBitmapArea(ABitmap, X, Y, W, H);
  AImageData := LockGpBitmap(AGPBitmap);
  PArgbConvertArgb(AImageData);
  UnlockGpBitmap(AGPBitmap, AImageData);
end;

function GetBitmap32ByPngImage(APngImage: PngImage2.TPngImage;
  ABitmap32: GR32.TBitmap32 = nil; ABackground: TColor32 = $00000000): GR32.TBitmap32;
// var
// AStream: TMemoryStream;
begin
  if ABitmap32 = nil then
    Result := GR32.TBitmap32.Create
  else
    Result := ABitmap32;
  {
    with TPortableNetworkGraphic32.Create do
    try
    AStream := TMemoryStream.Create;
    APngImage.SaveToStream(AStream);
    AStream.Position := 0;
    AdaptiveFilterMethods := [aafmSub, aafmUp, aafmAverage];
    LoadFromStream(AStream);
    AssignTo(ABitmap32);
    finally
    AStream.Free;
    Free;
    end;
  }
  Result.SetSize(APngImage.Width, APngImage.Height);
  Result.Clear(ABackground);
  APngImage.OldMode := ABackground <> 0;
  APngImage.Draw(Result.Canvas, Rect(0, 0, APngImage.Width, APngImage.Height));
end;

function GetBitmap32ByBitmap(ABitmap: TBitmap): TBitmap32;
begin
  Result := GR32.TBitmap32.Create;
  Result.SetSize(ABitmap.Width, ABitmap.Height);
  Result.Clear($00000000);
  Result.Canvas.Draw(0, 0, ABitmap);
end;

function GetBitmap32ByPngImage(APngImage: TPngImage;
  ABitmap32: GR32.TBitmap32 = nil): GR32.TBitmap32;
var
  APngImage2: PngImage2.TPngImage;
  AStream: TMemoryStream;
begin
  if ABitmap32 = nil then
    Result := GR32.TBitmap32.Create
  else
    Result := ABitmap32;

  APngImage2 := PngImage2.TPngImage.Create;
  try
    AStream := TMemoryStream.Create;
    try
      APngImage.SaveToStream(AStream);
      AStream.Position := 0;
      APngImage2.LoadFromStream(AStream);
    finally
      AStream.Free;
    end;

    Result.SetSize(APngImage.Width, APngImage.Height);
    Result.Clear($00000000);

    APngImage2.OldMode := False;
    APngImage2.Draw(Result.Canvas, Rect(0, 0, APngImage.Width, APngImage.Height));
  finally
    APngImage2.Free;
  end;
  //Bitmap32PArgbConvertArgb(Result);
end;

function SetFileTimesHelper(const FileName: string; const DateTime: TDateTime;
  Times: TFileTimes): Boolean;
var
  Handle: THandle;
  FileTime: TFileTime;
  SystemTime: TSystemTime;
begin
  Result := False;
  Handle := CreateFile(PChar(FileName), GENERIC_WRITE, FILE_SHARE_READ, nil,
    OPEN_EXISTING, 0, 0);
  if Handle <> INVALID_HANDLE_VALUE then
    try
      SysUtils.DateTimeToSystemTime(DateTime, SystemTime);
      if WinApi.Windows.SystemTimeToFileTime(SystemTime, FileTime) then
      begin
        case Times of
          ftLastAccess:
            Result := SetFileTime(Handle, nil, @FileTime, nil);
          ftLastWrite:
            Result := SetFileTime(Handle, nil, nil, @FileTime);
          ftCreation:
            Result := SetFileTime(Handle, @FileTime, nil, nil);
        end;
      end;
    finally
      CloseHandle(Handle);
    end;
end;

// --------------------------------------------------------------------------------------------------

function SetFileLastAccess(const FileName: string;
  const DateTime: TDateTime): Boolean;
begin
  Result := SetFileTimesHelper(FileName, DateTime, ftLastAccess);
end;

// --------------------------------------------------------------------------------------------------

function SetFileLastWrite(const FileName: string;
  const DateTime: TDateTime): Boolean;
begin
  Result := SetFileTimesHelper(FileName, DateTime, ftLastWrite);
end;

// --------------------------------------------------------------------------------------------------

function SetFileCreation(const FileName: string;
  const DateTime: TDateTime): Boolean;
begin
  Result := SetFileTimesHelper(FileName, DateTime, ftCreation);
end;

procedure PlayWaveSound(FileName: string);
begin
  try
    if FileName = '' then
      PlaySound(nil, 0, 0)
    else
      PlaySound(PChar(FileName), 0, SND_ASYNC or SND_FILENAME or SND_NODEFAULT or SND_NOSTOP);
  except
  end;
end;

function GetStdGPImageByBitmap(ABitmap: GR32.TBitmap32): TGPImage;
begin
  Result := TGPBitmap.Create(ABitmap.Width, ABitmap.Height,
    ((ABitmap.Width * 32 + 31) and $FFFFFFE0) shr 3, PixelFormat32bppPARGB,
    PByte(ABitmap.ScanLine[0]));
  Result.RotateFlip(Rotate180FlipX);
  Result.RotateFlip(Rotate180FlipX);
end;

function GetGPImageByBitmap(ABitmap: GR32.TBitmap32): Gdiplus.TGPBitmap;
begin
  // Result := TGpBitmap.FromHBITMAP(ABitmap.BitmapHandle, PixelFormat32bppPARGB);
  // Result := TGpBitmap.Create(ABitmap.BitmapInfo, PByte(ABitmap.ScanLine[0]));
  Result := Gdiplus.TGPBitmap.Create(ABitmap.Width, ABitmap.Height,
    ((ABitmap.Width * 32 + 31) and $FFFFFFE0) shr 3, pf32bppARGB,
    ABitmap.ScanLine[0]);
  // Result.RotateFlip(rfX180);
  // Result.RotateFlip(rfX180);
end;

function GetGPImageByBitmapArea(ABitmap: GR32.TBitmap32; X, Y, W, H: Integer)
  : Gdiplus.TGPBitmap;
begin
  Result := Gdiplus.TGPBitmap.Create(W, H,
    ((ABitmap.Width * 32 + 31) and $FFFFFFE0) shr 3, pf32bppARGB,
    @ABitmap.Bits[X + Y * ABitmap.Width]);
end;

procedure StreachDraw(SrcBitmap, DstBitmap: GR32.TBitmap32;
  ASrcRect, ADstRect: TRect; ALowQuality: Boolean = False);
var
  AGPGraph: GDIPOBJ.TGPGraphics;
  AGPImage: GDIPOBJ.TGPImage;
  pt: TGPPointF;
  ARect: TGPRect;
  ImageAttributes: TGPImageAttributes;
begin
  // if (DstBitmap.Empty) or (DstBitmap.Width = 0) or (DstBitmap.Height = 0) then Exit;

  EnterCriticalSection(FSection);
  DstBitmap.Canvas.Lock;
  try
    AGPImage := GetStdGPImageByBitmap(SrcBitmap);

    AGPGraph := GDIPOBJ.TGPGraphics.Create(DstBitmap.Canvas.Handle);
    ImageAttributes := TGPImageAttributes.Create;
    try
      if ALowQuality then
        AGPGraph.SetInterpolationMode(InterpolationModeInvalid)
      else
        AGPGraph.SetInterpolationMode(InterpolationModeHighQuality);
      ARect := GDIPAPI.MakeRect(ADstRect.Left, ADstRect.Top,
        ADstRect.Right - ADstRect.Left, ADstRect.Bottom - ADstRect.Top);

      if SrcBitmap.MasterAlpha < 255 then
      begin
        AlphaMatrix[3, 3] := SrcBitmap.MasterAlpha / 255;
        ImageAttributes.SetColorMatrix(AlphaMatrix);
        AGPGraph.DrawImage(AGPImage, ARect, ASrcRect.Left, ASrcRect.Top,
          ASrcRect.Right - ASrcRect.Left, ASrcRect.Bottom - ASrcRect.Top,
          UnitPixel, ImageAttributes);
      end
      else
      begin
        AGPGraph.DrawImage(AGPImage, ARect, ASrcRect.Left, ASrcRect.Top,
          ASrcRect.Right - ASrcRect.Left, ASrcRect.Bottom - ASrcRect.Top,
          UnitPixel);
      end;
    finally
      ImageAttributes.Free;
      AGPGraph.Free;
      AGPImage.Free;
    end;
  finally
    DstBitmap.Canvas.Unlock;
    LeaveCriticalSection(FSection);
  end;
end;

function CreateOneDir(ADir: String): Boolean;
var
  StrDir: String;
  ADirList: TStringDynArray;
  iLoop: Integer;
begin
  if Copy(ADir, Length(ADir), 1) = '\' then
    ADir := Copy(ADir, 1, Length(ADir) - 1);

  StrDir := '';
  ADirList := SplitString(ADir, '\');
  for iLoop := Low(ADirList) to High(ADirList) do
  begin
    StrDir := StrDir + ADirList[iLoop] + '\';
    if not DirectoryExists(StrDir) then
      CreateDir(StrDir);
  end;

  Result := DirectoryExists(ADir);
end;

function BytesOf(const Val: RawByteString): TBytes;
var
  Len: Integer;
begin
  Len := Length(Val);
  SetLength(Result, Len);
  Move(Val[1], Result[0], Len);
end;

function BytesToString(ABytes: TBytes): String;
begin
  SetLength(Result, Length(ABytes) * 2);
  BinToHex(@ABytes[0], PChar(Result), Length(ABytes));
end;

function StringToBytes(AText: String): TBytes;
begin
  SetLength(Result, Length(AText) div 2);
  HexToBin(PChar(AText), @Result[0], Length(Result));
end;

function ZipString(AText: String): String;
var
  ABytes: TBytes;
begin
  if AText = '' then
    Exit('');

  ABytes := ZCompressStr(AText, zcDefault);
  Result := BytesToString(ABytes);
end;

function UnZipString(AText: String): String;
begin
  if AText = '' then
    Exit('');
  try
    Result := zlib.ZDecompressStr(StringToBytes(AText));
  except
    Result := '';
  end;
end;

function CheckUnZipedFile(AZipFile, ADestDir: String;  APass: String = ''): Boolean;
var
  iLoop: Integer;
  AFilename: String;
  A7zInArchive: I7zInArchive;
begin
  Result := False;
  A7zInArchive := CreateInArchive(CLSID_CFormatZip);
  try
    with A7zInArchive do
    begin
      if APass <> '' then SetPassword(APass);
      OpenFile(AZipFile);
      try
        for iLoop := 0 to NumberOfItems - 1 do
        begin
          AFilename := ItemPath[iLoop];
          if AFilename = '' then Continue;

          if ItemIsFolder[iLoop] then Continue;
          if not FileExists(ADestDir + AFilename) then Exit;
          if ItemSize[iLoop] <> GetFileLength(ADestDir + AFilename, False) then Exit;
        end;
      finally
        Close;
      end;
    end;
    Result := True;
  finally
    A7zInArchive := nil;
  end;
end;

function UnZip(AZipFile, ADestDir: String; APass: String = ''; UnzipFileOverride: TUnzipFileOverride = nil; UnzipFileEvent: TUnzipFileEvent = nil): Boolean;
var
  iLoop: Integer;
  AFilename: String;
  AFileStream: TFileStream;
  Cancel: Boolean;
  A7zInArchive: I7zInArchive;
begin
  Result := False;
  A7zInArchive := CreateInArchive(CLSID_CFormatZip);
  try
    with A7zInArchive do
    begin
      if APass <> '' then SetPassword(APass);
      OpenFile(AZipFile);
      try
        for iLoop := 0 to NumberOfItems - 1 do
        begin
          AFilename := ItemPath[iLoop];
          if AFilename = '' then
            Continue;

          if ItemIsFolder[iLoop] then
          begin
            CreateOneDir(ADestDir + AFilename);
            Continue;
          end;
          CreateOneDir(ADestDir + ExtractFilePath(AFilename));

          try
            while True do
            begin
              try
                if FileExists(ADestDir + AFilename) then
                  DeleteFile(ADestDir + AFilename);

                AFileStream := TFileStream.Create(ADestDir + AFilename, fmCreate,
                  fmShareExclusive);
                Break;
              except
                if Assigned(UnzipFileOverride) then
                begin
                  Cancel := False;
                  UnzipFileOverride(ADestDir + AFilename, Cancel);
                  if Cancel then Exit;
                end
                else
                begin
                  Exit;
                  {
                  if MessageBox(0,
                    PChar('解压文件 ' + AFilename + ' 失败！'),
                    '提示', MB_ICONINFORMATION OR MB_RETRYCANCEL) = IDCANCEL then
                    Exit;
                  }
                end;
              end;
            end;

            ExtractItem(iLoop, AFileStream, False);
          finally
            AFilename := AFileStream.FileName;
            FreeAndNil(AFileStream);
            if Assigned(UnzipFileEvent) and FileExists(AFilename) then UnzipFileEvent(AFilename);
          end;
        end;
      finally
        Close;
      end;
      // ExtractTo(ADestDir);
    end;
    Result := True;
  finally
    A7zInArchive := nil;
  end;
end;

function IsNumberic(Vaule: String): Boolean;
var
  i: Integer;
begin
  Result := True;
  Vaule := Trim(Vaule);
  for i := 1 to Length(Vaule) do
  begin
    if not(Vaule[i] in ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.']) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

function GetFileVersion(FileName: string): string;
type
  PVerInfo = ^TVS_FIXEDFILEINFO;

  TVS_FIXEDFILEINFO = record
    dwSignature: Longint;
    dwStrucVersion: Longint;
    dwFileVersionMS: Longint;
    dwFileVersionLS: Longint;
    dwFileFlagsMask: Longint;
    dwFileFlags: Longint;
    dwFileOS: Longint;
    dwFileType: Longint;
    dwFileSubtype: Longint;
    dwFileDateMS: Longint;
    dwFileDateLS: Longint;
  end;
var
  ExeNames: array [0 .. 255] of Char;
  zKeyPath: array [0 .. 255] of Char;
  VerInfo: PVerInfo;
  Buf: Pointer;
  Sz: Word;
  L, Len: Cardinal;
begin
  StrPCopy(ExeNames, FileName);
  Sz := GetFileVersionInfoSize(ExeNames, L);
  if Sz = 0 then
  begin
    Result := '';
    Exit;
  end;

  try
    GetMem(Buf, Sz);
    try
      GetFileVersionInfo(ExeNames, 0, Sz, Buf);
      if VerQueryValue(Buf, '\', Pointer(VerInfo), Len) then
      begin
        Result := IntToStr(HIWORD(VerInfo.dwFileVersionMS)) + '.' +
          IntToStr(LOWORD(VerInfo.dwFileVersionMS)) + '.' +
          IntToStr(HIWORD(VerInfo.dwFileVersionLS)) + '.' +
          IntToStr(LOWORD(VerInfo.dwFileVersionLS));

      end;
    finally
      FreeMem(Buf);
    end;
  except
    Result := '-1';
  end;
end;

procedure EncodePacket(const Packet: TPacket; NumChars: Integer;
  OutBuf: pansichar);
begin
  OutBuf[0] := EncodeTable[Packet.a[0] shr 2];
  OutBuf[1] := EncodeTable[((Packet.a[0] shl 4) or (Packet.a[1] shr 4)) and
    $0000003F];
  if NumChars < 2 then
    OutBuf[2] := '='
  else
    OutBuf[2] := EncodeTable[((Packet.a[1] shl 2) or (Packet.a[2] shr 6)) and
      $0000003F];
  if NumChars < 3 then
    OutBuf[3] := '='
  else
    OutBuf[3] := EncodeTable[Packet.a[2] and $0000003F];
end;

function DecodePacket(InBuf: pansichar; var nChars: Integer): TPacket;
begin
  Result.a[0] := (DecodeTable[InBuf[0]] shl 2) or (DecodeTable[InBuf[1]] shr 4);
  nChars := 1;
  if InBuf[2] <> '=' then
  begin
    Inc(nChars);
    Result.a[1] := Byte((DecodeTable[InBuf[1]] shl 4) or
      (DecodeTable[InBuf[2]] shr 2));
  end;
  if InBuf[3] <> '=' then
  begin
    Inc(nChars);
    Result.a[2] := Byte((DecodeTable[InBuf[2]] shl 6) or DecodeTable[InBuf[3]]);
  end;
end;

function EncodeString(const Input: string): string;
var
  InStr, OutStr: TStringStream;
begin
  InStr := TStringStream.Create(Input, TEncoding.UTF8);
  try
    OutStr := TStringStream.Create('');
    try
      EncodeStream(InStr, OutStr);
      Result := OutStr.DataString;
    finally
      OutStr.Free;
    end;
  finally
    InStr.Free;
  end;
end;

procedure EncodeStream(Input, Output: TStream);
type
  PInteger = ^Integer;
var
  InBuf: array [0 .. 509] of Byte;
  OutBuf: array [0 .. 1023] of AnsiChar;
  BufPtr: pansichar;
  i, J, K, BytesRead: Integer;
  Packet: TPacket;
begin
  K := 0;
  repeat
    BytesRead := Input.Read(InBuf, SizeOf(InBuf));
    i := 0;
    BufPtr := OutBuf;
    while i < BytesRead do
    begin
      if BytesRead - i < 3 then
        J := BytesRead - i
      else
        J := 3;
      Packet.i := 0;
      Packet.b0 := InBuf[i];
      if J > 1 then
        Packet.b1 := InBuf[i + 1];
      if J > 2 then
        Packet.b2 := InBuf[i + 2];
      EncodePacket(Packet, J, BufPtr);
      Inc(i, 3);
      Inc(BufPtr, 4);
      Inc(K, 4);
      { if K > 75 then
        begin
        BufPtr[0] := #$0D;
        BufPtr[1] := #$0A;
        Inc(BufPtr, 2);
        K := 0;
        end; }
    end;
    Output.Write(OutBuf, BufPtr - PChar(@OutBuf));
  until BytesRead = 0;
end;

procedure DecodeStream(Input, Output: TStream);
var
  InBuf: array [0 .. 75] of AnsiChar;
  OutBuf: array [0 .. 60] of Byte;
  InBufPtr, OutBufPtr: pansichar;
  i, J, K, BytesRead: Integer;
  Packet: TPacket;

  procedure SkipWhite;
  var
    c: AnsiChar;
    NumRead: Integer;
  begin
    while True do
    begin
      NumRead := Input.Read(c, 1);
      if NumRead = 1 then
      begin
        if c in ['0' .. '9', 'A' .. 'Z', 'a' .. 'z', '+', '/', '='] then
        begin
          Input.Position := Input.Position - 1;
          Break;
        end;
      end
      else
        Break;
    end;
  end;

  function ReadInput: Integer;
  var
    WhiteFound, EndReached: Boolean;
    CntRead, Idx, IdxEnd: Integer;
  begin
    IdxEnd := 0;
    repeat
      WhiteFound := False;
      CntRead := Input.Read(InBuf[IdxEnd], (SizeOf(InBuf) - IdxEnd));
      EndReached := CntRead < (SizeOf(InBuf) - IdxEnd);
      Idx := IdxEnd;
      IdxEnd := CntRead + IdxEnd;
      while (Idx < IdxEnd) do
      begin
        if not(InBuf[Idx] in ['0' .. '9', 'A' .. 'Z', 'a' .. 'z', '+', '/', '='])
        then
        begin
          Dec(IdxEnd);
          if Idx < IdxEnd then
            Move(InBuf[Idx + 1], InBuf[Idx], IdxEnd - Idx);
          WhiteFound := True;
        end
        else
          Inc(Idx);
      end;
    until (not WhiteFound) or (EndReached);
    Result := IdxEnd;
  end;

begin
  repeat
    SkipWhite;
    BytesRead := ReadInput;
    InBufPtr := InBuf;
    OutBufPtr := @OutBuf;
    i := 0;
    while i < BytesRead do
    begin
      Packet := DecodePacket(InBufPtr, J);
      K := 0;
      while J > 0 do
      begin
        OutBufPtr^ := AnsiChar(Packet.a[K]);
        Inc(OutBufPtr);
        Dec(J);
        Inc(K);
      end;
      Inc(InBufPtr, 4);
      Inc(i, 4);
    end;
    Output.Write(OutBuf, OutBufPtr - pansichar(@OutBuf));
  until BytesRead = 0;
end;

/// 将Jpeg转化为base64字符串
function JpegToString(img: TJpegImage): string;
var
  ms: TMemoryStream;
  ss: TStringStream;
  s: string;
begin
  ms := TMemoryStream.Create;
  img.SaveToStream(ms);
  ss := TStringStream.Create('');
  ms.Position := 0;
  EncodeStream(ms, ss); // 将内存流编码为base64字符流
  s := ss.DataString;
  ms.Free;
  ss.Free;
  Result := s;
end;

function PngToString(img: TPngImage): string;
var
  ms: TMemoryStream;
  ss: TStringStream;
  s: string;
begin
  ms := TMemoryStream.Create;
  img.SaveToStream(ms);
  ss := TStringStream.Create('');
  ms.Position := 0;
  EncodeStream(ms, ss); // 将内存流编码为base64字符流
  s := ss.DataString;
  ms.Free;
  ss.Free;
  Result := s;
end;

function StreamToString(AStream: TStream): string;
var
  ss: TStringStream;
  s: string;
begin
  ss := TStringStream.Create('');
  AStream.Position := 0;
  EncodeStream(AStream, ss); // 将内存流编码为base64字符流
  s := ss.DataString;
  ss.Free;
  Result := s;
end;

function StringToStream(imgStr: string): TStream;
var
  ss: TStringStream;
  ms: TMemoryStream;
begin
  ss := TStringStream.Create(imgStr);
  ms := TMemoryStream.Create;
  DecodeStream(ss, ms); // 将base64字符流还原为内存流
  ms.Position := 0;
  ss.Free;
  Result := ms;
end;

/// 将Bitmap位图转化为base64字符串
function BitmapToString(img: TBitmap): string;
var
  ms: TMemoryStream;
  ss: TStringStream;
  s: string;
begin
  ms := TMemoryStream.Create;
  img.SaveToStream(ms);
  ss := TStringStream.Create('');
  ms.Position := 0;
  EncodeStream(ms, ss); // 将内存流编码为base64字符流
  s := ss.DataString;
  ms.Free;
  ss.Free;
  Result := s;
end;

/// 将base64字符串转化为Bitmap位图
function StringToBitmap(imgStr: string): TBitmap;
var
  ss: TStringStream;
  ms: TMemoryStream;
  bitmap: TBitmap;
begin
  ss := TStringStream.Create(imgStr);
  ms := TMemoryStream.Create;
  DecodeStream(ss, ms); // 将base64字符流还原为内存流
  ms.Position := 0;
  bitmap := TBitmap.Create;
  bitmap.LoadFromStream(ms);
  ss.Free;
  ms.Free;
  Result := bitmap;
end;

/// 将base64字符串转化为Bitmap位图
function StringToJpeg(imgStr: string): TJpegImage;
var
  ss: TStringStream;
  ms: TMemoryStream;
  jpeg: TJpegImage;
begin
  ss := TStringStream.Create(imgStr);
  ms := TMemoryStream.Create;
  DecodeStream(ss, ms); // 将base64字符流还原为内存流
  ms.Position := 0;
  jpeg := TJpegImage.Create;
  jpeg.LoadFromStream(ms);
  ss.Free;
  ms.Free;
  Result := jpeg;
end;

function PidlFree(var IdList: PItemIDList): Boolean;
var
  Malloc: IMalloc;
begin
  CoInitialize(nil);
  try
    Result := False;
    if IdList = nil then
      Result := True
    else
    begin
      if Succeeded(SHGetMalloc(Malloc)) and (Malloc.DidAlloc(IdList) > 0) then
      begin
        Malloc.Free(IdList);
        IdList := nil;
        Result := True;
      end;
    end;
  finally
    CoUninitialize;
  end;
end;

function GetProcessList(const IncludeThreads, IncludeWindows: Boolean)
  : TProcessArray;
var
  hSnapshot: THandle;
  i: Integer;
  // Threads: TpzThreadArray;
  pe: TProcessEntry32;
  // m: Cardinal;
  hProcess: THandle;
  _hModule: HMODULE;
  needed: Cardinal;
  buffer: array [0 .. MAX_PATH] of Char;
begin
  Result := nil;

  hSnapshot := CreateToolHelp32Snapshot(TH32CS_SnapProcess, 0);
  if hSnapshot = INVALID_HANDLE_VALUE then
    Exit;

  try
    ZeroMemory(@pe, SizeOf(pe));
    pe.dwSize := SizeOf(pe);

    if Process32First(hSnapshot, pe) then
      repeat
        SetLength(Result, Length(Result) + 1);
        i := High(Result);
        Result[i].PID := pe.th32ProcessID;
        Result[i].Name := pe.szExeFile;
        Result[i].ParentID := pe.th32ParentProcessID;
        Result[i].ThreadCount := pe.cntThreads;
        Result[i].PriClassBase := pe.pcPriClassBase;

        hProcess := OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ,
          False, Result[i].PID);
        if hProcess <> 0 then
        begin
          if EnumProcessModules(hProcess, @_hModule, SizeOf(HMODULE), needed)
          then
            if GetModuleFileNameEx(hProcess, _hModule, @buffer[0], MAX_PATH) > 0
            then
              if GetLongPathName(@buffer[0], @buffer[0], MAX_PATH) > 0 then
                Result[i].Name := PChar(@buffer[0]);

          CloseHandle(hProcess);
        end;
      until not Process32Next(hSnapshot, pe);

  finally
    CloseHandle(hSnapshot);
  end;
end;

function WaitExecute(const FileName, Parameters, Directory: string;
  ShowWindow: Cardinal; AWaitExit: Boolean; var ExitCode: Cardinal): Boolean;
var
  si: STARTUPINFO;
  pi: PROCESS_INFORMATION;
  pdir: PChar;
begin
  Result := False;

  ZeroMemory(@si, SizeOf(si));
  si.cb := SizeOf(si);
  si.dwFlags := STARTF_USESHOWWINDOW;
  si.wShowWindow := ShowWindow;
  ZeroMemory(@pi, SizeOf(pi));

  if Directory = '' then
    pdir := nil
  else
    pdir := PChar(Directory);

  try
    if CreateProcess(nil, PChar(Format('"%s" %s', [FileName, Parameters])), nil,
      nil, False, 0, nil, pdir, si, pi) then
    begin
      try
        while AWaitExit do
        begin
          //if WaitForSingleObject(pi.hProcess, INFINITE) = WAIT_OBJECT_0 then
          if WaitForSingleObject(pi.hProcess, 50) = WAIT_OBJECT_0 then
          begin
            Result := GetExitCodeProcess(pi.hProcess, ExitCode);
            Break;
          end
          else
          begin
            Application.ProcessMessages;
          end;
        end;
      finally
        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
      end;
    end;
  except
    Result := False;
  end;
end;

{
  得到文件的时间信息
  TimeFlag
  := 1    返回文件创建时间
  := 2    返回文件修改时间
  := 3    返回上次访问文件的时间
}
function GetFileTime(FileName: string; TimeFlag: Integer): TDateTime;
var
  LocalFileTime: TFileTime;
  FHandle: Cardinal;
  DosFileTime: DWord;
  FindData: TWin32FindData;
  CreationTime, LastAccessTime, LastWriteTime: TDateTime;
begin
  Result := 0;
  try
    if DirectoryExists(FileName) then
    begin
      case TimeFlag of
        1:
          begin
            Result := IOUtils.TDirectory.GetCreationTime(FileName);
          end;
        2:
          begin
            Result := IOUtils.TDirectory.GetLastWriteTime(FileName);
          end;
        3:
          begin
            Result := IOUtils.TDirectory.GetLastAccessTime(FileName);
          end;
      end;
    end
    else if FileExists(FileName) then
    begin
      case TimeFlag of
        1:
          begin
            Result := IOUtils.TFile.GetCreationTime(FileName);
          end;
        2:
          begin
            Result := IOUtils.TFile.GetLastWriteTime(FileName);
          end;
        3:
          begin
            Result := IOUtils.TFile.GetLastAccessTime(FileName);
          end;
      end;
    end
    else
    begin
      Result := 0;
    end;
  except
    Result := 0;
  end;
end;

// procedure ClearMemory(dwMinimumWorkingSetSize: DWORD = $FFFFFFFF; dwMaximumWorkingSetSize: DWORD = $FFFFFFFF);
procedure ClearMemory(dwMinimumWorkingSetSize: DWord;
  dwMaximumWorkingSetSize: DWord);
begin
//  if Win32Platform = VER_PLATFORM_WIN32_NT then
//  begin
//    SetProcessWorkingSetSize(GetCurrentProcess, dwMinimumWorkingSetSize,
//      dwMaximumWorkingSetSize);
//  end;
end;

procedure CopyBitmap32AlphaValueToPng(ABitmap: GR32.TBitmap32; APng: TPngImage); overload;
var
  P1: PByteArray;
  P2: PColor32EntryArray;
  ScanlineBytes, X, Y: Integer;
begin
  APng.CreateAlpha;
  ScanlineBytes := Integer(ABitmap.ScanLine[1]) - Integer(ABitmap.ScanLine[0]);
  P2 := PColor32EntryArray(ABitmap.ScanLine[0]);
  for Y := 0 to APng.Height - 1 do
  begin
    P1 := PByteArray(APng.AlphaScanline[Y]);
    for X := 0 to APng.Width - 1 do
    begin
      P1[X] := P2[X].a;
    end;
    Inc(Integer(P2), ScanlineBytes);
  end;
end;

procedure CopyBitmap32AlphaValueToPng(ABitmap: GR32.TBitmap32; APng: PngImage2.TPngImage); overload;
var
  P1: PByteArray;
  P2: PColor32EntryArray;
  ScanlineBytes, X, Y: Integer;
begin
  APng.CreateAlpha;
  ScanlineBytes := Integer(ABitmap.ScanLine[1]) - Integer(ABitmap.ScanLine[0]);
  P2 := PColor32EntryArray(ABitmap.ScanLine[0]);
  for Y := 0 to APng.Height - 1 do
  begin
    P1 := PByteArray(APng.AlphaScanline[Y]);
    for X := 0 to APng.Width - 1 do
    begin
      P1[X] := P2[X].a;
    end;
    Inc(Integer(P2), ScanlineBytes);
  end;
end;

procedure CopyBitmapAlphaValueToPng(ABitmap: TBitmap32;
  APng: TPngImage); overload;
var
  P1: PByteArray;
  P2: PColor32EntryArray;
  ScanlineBytes, X, Y: Integer;
begin
  APng.CreateAlpha;
  ScanlineBytes := Integer(ABitmap.ScanLine[1]) - Integer(ABitmap.ScanLine[0]);
  P2 := PColor32EntryArray(ABitmap.ScanLine[0]);
  for Y := 0 to APng.Height - 1 do
  begin
    P1 := PByteArray(APng.AlphaScanline[Y]);
    for X := 0 to APng.Width - 1 do
    begin
      P1[X] := P2[X].a;
    end;
    Inc(Integer(P2), ScanlineBytes);
  end;
end;

procedure CopyBitmapAlphaValueToPng(ABitmap: TBitmap32;
  APng: PngImage2.TPngImage); overload;
var
  P1: PByteArray;
  P2: PColor32EntryArray;
  ScanlineBytes, X, Y: Integer;
begin
  APng.CreateAlpha;
  ScanlineBytes := Integer(ABitmap.ScanLine[1]) - Integer(ABitmap.ScanLine[0]);
  P2 := PColor32EntryArray(ABitmap.ScanLine[0]);
  for Y := 0 to APng.Height - 1 do
  begin
    P1 := PByteArray(APng.AlphaScanline[Y]);
    for X := 0 to APng.Width - 1 do
    begin
      P1[X] := P2[X].a;
    end;
    Inc(Integer(P2), ScanlineBytes);
  end;
end;

procedure ResetPngAlpha(APng: TPngImage; Alpha: Byte);
var
  P1: PByteArray;
  P2: PColor32EntryArray;
  ScanlineBytes, X, Y: Integer;
begin
  for Y := 0 to APng.Height - 1 do
  begin
    P1 := PByteArray(APng.AlphaScanline[Y]);
    for X := 0 to APng.Width - 1 do
    begin
      P1[X] := Alpha;
    end;
    Inc(Integer(P2), ScanlineBytes);
  end;
end;

function CheckBitmap32HasAlphaBit(ABitmap: GR32.TBitmap32;
  AWidth: Integer): Boolean;
var
  P: PColor32EntryArray;
  ScanlineBytes, X, Y: Integer;
begin
  Result := False;
  ScanlineBytes := Integer(ABitmap.ScanLine[1]) - Integer(ABitmap.ScanLine[0]);
  P := PColor32EntryArray(ABitmap.ScanLine[0]);
  for Y := 0 to ABitmap.Height - 1 do
  begin
    for X := 0 to ABitmap.Width - 1 do
    begin
      // if (P[x].A > 0) and (P[x].A < 255) then
      if (P[X].a > 0) and ((X >= AWidth) or (Y >= AWidth)) then
      begin
        Result := True;
        Exit;
      end;
    end;
    Inc(Integer(P), ScanlineBytes);
  end;
end;

function CheckBitmap32Empty(ABitmap: GR32.TBitmap32): Boolean;
var
  P: PColor32EntryArray;
  ScanlineBytes, X, Y: Integer;
begin
  Result := True;
  ScanlineBytes := Integer(ABitmap.ScanLine[1]) - Integer(ABitmap.ScanLine[0]);
  P := PColor32EntryArray(ABitmap.ScanLine[0]);
  for Y := 0 to ABitmap.Height - 1 do
  begin
    for X := 0 to ABitmap.Width - 1 do
    begin
      if P[X].a > 0 then
      begin
        Result := False;
        Exit;
      end;
    end;
    Inc(Integer(P), ScanlineBytes);
  end;
end;

function ResetBimtap32Alpha(ABitmap: GR32.TBitmap32): Boolean;
var
  P: PColor32EntryArray;
  ScanlineBytes, X, Y: Integer;
begin
  Result := True;
  ScanlineBytes := Integer(ABitmap.ScanLine[1]) - Integer(ABitmap.ScanLine[0]);
  P := PColor32EntryArray(ABitmap.ScanLine[0]);
  for Y := 0 to ABitmap.Height - 1 do
  begin
    for X := 0 to ABitmap.Width - 1 do
    begin
      if (P[X].B = $FF) and (P[X].R = $FF) and (P[X].G = 0) then
        P[X].a := 0
      else
        P[X].a := $FF;
    end;
    Inc(Integer(P), ScanlineBytes);
  end;
end;

function ShortPathToLongPath(const AShortName: string): string;
var
  Sz: array [0 .. MAX_PATH - 1] of Char;
begin
  FillChar(Sz, SizeOf(Sz), 0);
  GetLongPathName(PChar(AShortName), Sz, MAX_PATH);
  Result := string(Sz);
end;

function GetImageListSH(SHIL_FLAG: Cardinal): HIMAGELIST;
type
  _SHGetImageList = function(iImageList: Integer; const riid: TGUID;
    var ppv: Pointer): hResult; stdcall;
var
  Handle: THandle;
  SHGetImageList: _SHGetImageList;
begin
  Result := 0;
  Handle := LoadLibrary('Shell32.dll');
  if Handle <> S_OK then
    try
      SHGetImageList := GetProcAddress(Handle, PChar(727));
      if Assigned(SHGetImageList) and (Win32Platform = VER_PLATFORM_WIN32_NT)
      then
        SHGetImageList(SHIL_FLAG, IID_IImageList, Pointer(Result));
    finally
      FreeLibrary(Handle);
    end;
end;

function CheckIconIs32Bit(const AIconHandle: Integer; AWidth: Integer): Boolean;
var
  ABitmap: GR32.TBitmap32;
  hIcon: TIcon;
begin
  ABitmap := GR32.TBitmap32.Create;
  hIcon := TIcon.Create;
  try
    hIcon.Handle := AIconHandle;
    ABitmap.SetSize(hIcon.Width, hIcon.Height);

    ABitmap.Clear($00000000);
    DrawIconEx(ABitmap.Canvas.Handle, 0, 0, hIcon.Handle, hIcon.Width,
      hIcon.Height, 0, 0, DI_NORMAL);

    Result := CheckBitmap32HasAlphaBit(ABitmap, AWidth);
  finally
    ABitmap.Free;
    hIcon.Free;
  end;
end;

Procedure GetIconFromFile(AFile: String; var aIcon: TIcon; SHIL_FLAG: Cardinal);
var
  aImgList: HIMAGELIST;
  SFI: TSHFileInfo;
begin
  { if DirectoryExists(aFile) then
    begin
    SHGetFileInfo(PChar(aFile), 0, SFI, SizeOf(SFI), SHGFI_ICON or
    SHGFI_LARGEICON);
    aIcon.Handle := SFI.hIcon;
    Exit;
    end; }

  SHGetFileInfo(PChar(AFile), FILE_ATTRIBUTE_NORMAL, SFI, SizeOf(TSHFileInfo),
    SHGFI_ICON or SHGFI_LARGEICON or SHGFI_SHELLICONSIZE or
    SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES);
  aImgList := GetImageListSH(SHIL_FLAG);
  aIcon.Handle := ImageList_GetIcon(aImgList, SFI.iIcon, ILD_IMAGE);
  // SFI.iIcon 可替换成 Pred(ImageList_GetImageCount(aImgList))

  if not CheckIconIs32Bit(aIcon.Handle, 48) then
  begin
    if SHIL_FLAG = SHIL_JUMBO then
    begin
      SHGetFileInfo(PChar(AFile), FILE_ATTRIBUTE_NORMAL, SFI,
        SizeOf(TSHFileInfo), SHGFI_ICON or SHGFI_LARGEICON or
        SHGFI_SHELLICONSIZE or SHGFI_SYSICONINDEX or SHGFI_USEFILEATTRIBUTES);
      aImgList := GetImageListSH(SHIL_EXTRALARGE);
      aIcon.Handle := ImageList_GetIcon(aImgList, SFI.iIcon, ILD_IMAGE);
      // SFI.iIcon 可替换成 Pred(ImageList_GetImageCount(aImgList))

      if CheckIconIs32Bit(aIcon.Handle, 32) then
      begin
        aIcon.Handle := ImageList_GetIcon(aImgList, SFI.iIcon, ILD_IMAGE);
        // SFI.iIcon 可替换成 Pred(ImageList_GetImageCount(aImgList))
        Exit;
      end;
    end;

    aIcon.Handle := SFI.hIcon;
  end
  else
  begin
    aIcon.Handle := ImageList_GetIcon(aImgList, SFI.iIcon, ILD_IMAGE);
    // SFI.iIcon 可替换成 Pred(ImageList_GetImageCount(aImgList))
  end;
end;

Procedure GetIconFromFileExt(AFile: String; var aIcon: TIcon);
var
  FileExt, FFileExtImage, IconTempFileName: String;
  TempFile: array [0 .. MAX_PATH] of Char;
  SHFI: TSHFileInfo;
begin
  FileExt := ExtractFileExt(AFile);
  GetTempPath(MAX_PATH, TempFile);
  GetTempFileName(TempFile, PChar(FileExt), GetTickCount, TempFile);
  IconTempFileName := ReplaceStr(TempFile, ExtractFileExt(TempFile), FileExt);
  TFileStream.Create(IconTempFileName, fmCreate).Free;
  SHGetFileInfo(PChar(IconTempFileName), 0, SHFI, SizeOf(SHFI),
    SHGFI_ICON or SHGFI_LARGEICON);
  DeleteFile(PChar(IconTempFileName));
  aIcon.Handle := SHFI.hIcon;
end;

procedure GetFileIcon(ASrcFile, ADstFile: String);
var
  hIcon: TIcon;
begin
  hIcon := TIcon.Create;
  try
    if IsVista then
      GetIconFromFile(ASrcFile, hIcon, SHIL_JUMBO)
    else
      GetIconFromFile(ASrcFile, hIcon, SHIL_EXTRALARGE);
  finally
    hIcon.Free;
  end;
end;

procedure GetPngByBitmap32(ABitmap32: TBitmap32; APngImage: TPngImage);
begin
  APngImage.Assign(ABitmap32);
  CopyBitmapAlphaValueToPng(ABitmap32, APngImage);
end;

procedure GetPngByBitmap32(ABitmap32: TBitmap32;
  APngImage: PngImage2.TPngImage);
var
  ABitmap: TBitmap;
begin
  ABitmap := TBitmap.Create;
  try
    ABitmap.SetSize(ABitmap32.Width, ABitmap32.Height);
    ABitmap32.DrawTo(ABitmap.Canvas.Handle, 0, 0);

    APngImage.Assign(ABitmap);
    CopyBitmap32AlphaValueToPng(ABitmap32, APngImage);
  finally
    ABitmap.Free;
  end;
end;

procedure ImageToPng(ABitmap: TBitmap32; ADstFile: String);
var
  GPImage: TGPImage;
  GUID: TGUID;
begin
  GPImage := GetStdGPImageByBitmap(ABitmap);
  try
    GetEncoderClsid('image/png', GUID);
    GPImage.Save(ADstFile, GUID);
  finally
    GPImage.Free;
  end;
end;

procedure ImageToJpg(ABitmap: TBitmap32; ADstFile: String);
var
  GPImage: TGPImage;
  GUID: TGUID;
  params: TEncoderParameters;
  quality: Integer;
begin
  GPImage := GetStdGPImageByBitmap(ABitmap);
  try
    GetEncoderClsid('image/jpeg', GUID);
    params.Count := 1;
    params.Parameter[0].GUID := EncoderQuality;
    params.Parameter[0].Type_ := EncoderParameterValueTypeLong;
    params.Parameter[0].NumberOfValues := 1;
    quality := 90;
    params.Parameter[0].Value := @quality;
    GPImage.Save(ADstFile, GUID, @params);
  finally
    GPImage.Free;
  end;
end;

procedure ImageToPng(ASrcFile, ADstFile: String);
var
  GPImage: TGPImage;
  GUID: TGUID;
begin
  GPImage := TGPImage.Create(ASrcFile);
  try
    GetEncoderClsid('image/png', GUID);
    GPImage.Save(ADstFile, GUID);
  finally
    GPImage.Free;
  end;
end;

procedure IconHandleToPng(AIconHandle: Integer; ADstFile: String);
var
  ABitmap: GR32.TBitmap32;
  hIcon: TIcon;
  Graphics: TGPGraphics;
  GPImage: TGPImage;

  ADstLeft, ADstTop, ASrcWidth, ASrcHeight, ADstWidth, ADstHeight: Integer;
  GUID: TGUID;
  ABitmap72: GR32.TBitmap32;
begin
  hIcon := TIcon.Create;
  ABitmap := GR32.TBitmap32.Create;
  ABitmap72 := GR32.TBitmap32.Create;
  try
    hIcon.Handle := AIconHandle;
    ABitmap.SetSize(hIcon.Width, hIcon.Height);

    ABitmap.Clear($00000000);
    DrawIconEx(ABitmap.Canvas.Handle, 0, 0, hIcon.Handle, hIcon.Width,
      hIcon.Height, 0, 0, DI_NORMAL);

    if CheckBitmap32Empty(ABitmap) then
    begin
      ABitmap.Clear($FFFF00FF);
      DrawIconEx(ABitmap.Canvas.Handle, 0, 0, hIcon.Handle, hIcon.Width,
        hIcon.Height, 0, 0, DI_NORMAL);
      ResetBimtap32Alpha(ABitmap);
    end;

    if CheckBitmap32Empty(ABitmap) then
      Exit;

    ABitmap72.SetSize(72, 72);
    ABitmap72.Clear($00000000);
    StreachDraw(ABitmap, ABitmap72, Rect(0, 0, ABitmap.Width, ABitmap.Height),
      Rect(0, 0, ABitmap72.Width, ABitmap72.Height));

    GPImage := GetStdGPImageByBitmap(ABitmap72);
    try
      GetEncoderClsid('image/png', GUID);
      GPImage.Save(ADstFile, GUID);
    finally
      GPImage.Free;
    end;
  finally
    ABitmap72.Free;
    ABitmap.Free;
    hIcon.Free;
  end;
end;

{
  procedure IconHandleToPng(AIconHandle: Integer; ADstFile: String);
  var
  APngImage: TPngImage;
  ABitmap: GR32.TBitmap32;
  ABitmap72: GR32.TBitmap32;
  ABitmapFull: Image32.TBitmap32;
  hIcon: TIcon;
  ASize: Integer;
  begin
  APngImage := TPngImage.Create;
  ABitmap := GR32.TBitmap32.Create;
  ABitmap72 := GR32.TBitmap32.Create;
  ABitmapFull := Image32.TBitmap32.Create;
  hIcon := TIcon.Create;
  try
  hIcon.Handle := AIconHandle;
  ABitmap.SetSize(hIcon.Width, hIcon.Height);

  ABitmap.Clear($00000000);
  DrawIconEx(ABitmap.Canvas.Handle, 0, 0, hIcon.Handle, hIcon.Width,
  hIcon.Height, 0, 0, DI_NORMAL);

  if CheckBitmap32Empty(ABitmap) then
  begin
  ABitmap.Clear($FFFF00FF);
  DrawIconEx(ABitmap.Canvas.Handle, 0, 0, hIcon.Handle, hIcon.Width,
  hIcon.Height, 0, 0, DI_NORMAL);
  ResetBimtap32Alpha(ABitmap);
  end;

  if ABitmap.Width > 72 then
  ASize := 72
  else
  ASize := 72;//ABitmap.Width;

  ABitmap72.SetSize(ASize, ASize);
  ABitmap72.Clear($00000000);


  //ABitmap.ResamplerClassName := 'TLinearResampler';

  //if ABitmap.Width > ABitmap72.Width then
  //begin
  //  ABitmap.ResamplerClassName := 'TLinearResampler';
  //end
  //else
  begin
  with TKernelResampler.Create(ABitmap) do
  begin
  KernelMode := kmTableNearest;
  TableSize := 16;
  Kernel := TLanczosKernel.Create;
  end;
  end;

  //ABitmap.DrawMode := dmBlend;
  //ABitmap.DrawTo(ABitmap72, Rect(0, 0,ABitmap72.Width, ABitmap72.Height), Rect(0, 0,ABitmap.Width, ABitmap.Height));
  StreachDraw(ABitmap, ABitmap72, Rect(0, 0,ABitmap.Width, ABitmap.Height), Rect(0, 0,ABitmap72.Width, ABitmap72.Height));


  ABitmapFull.SetSize(ASize, ASize);
  ABitmapFull.Clear($00000000);
  ABitmap72.DrawTo(ABitmapFull.Canvas.Handle, 0, 0);

  APngImage.Assign(ABitmapFull);
  CopyBitmap32AlphaValueToPng(ABitmap72, APngImage);

  APngImage.SaveToFile(ADstFile);
  finally
  hIcon.Free;

  ABitmapFull.Free;
  ABitmap72.Free;
  ABitmap.Free;
  APngImage.Free;
  end;
  end;
}

procedure GetFileIconToPng(ASrcFile, ADstFile: String);
var
  hIcon: TIcon;
begin
  hIcon := TIcon.Create;
  try
    if IsVista then
      GetIconFromFile(ASrcFile, hIcon, SHIL_JUMBO)
    else
      GetIconFromFile(ASrcFile, hIcon, SHIL_EXTRALARGE);
    IconHandleToPng(hIcon.Handle, ADstFile);

  finally
    hIcon.Free;
  end;
end;

function GetBitmap32(AFile: String): TBitmap32;
var
  APngImage: PngImage2.TPngImage;
  ATempFile: String;
begin
  if SameText(ExtractFileExt(AFile), '.png') then
  begin
    APngImage := PngImage2.TPngImage.Create;
    try
      try
        APngImage.LoadFromFile(AFile);
        Result := GetBitmap32ByPngImage(APngImage);
      except
        Result := TBitmap32.Create;
      end;
    finally
      APngImage.Free;
    end;
  end
  else
  begin
    Result := TBitmap32.Create;
  end;

  try
    if Result.Empty then
      Result.LoadFromFile(AFile);
  except
    try
      ATempFile := IOUtils.TPath.GetTempFileName + '.jpg';
      CopyFile(PChar(AFile), PChar(ATempFile), False);
      Result.LoadFromFile(ATempFile);
    except
      try
        APngImage := PngImage2.TPngImage.Create;
        try
          APngImage.LoadFromFile(AFile);
          FreeAndNil(Result);
          Result := GetBitmap32ByPngImage(APngImage);
        finally
          APngImage.Free;
        end;
      except
        Result := TBitmap32.Create;
      end;
    end;
  end;
end;

procedure GetPngFile(ABitmap: TBitmap; APngFile: String);
var
  APng: TPngImage;
begin
  APng := TPngImage.Create;
  try
    APng.Assign(ABitmap);
    APng.SaveToFile(APngFile);
  finally
    APng.Free;
  end;
end;

procedure SaveImageTo(ASrcFile, ADstFile: String);
begin

end;

procedure ResizeBitmap32(ABitmap32: TBitmap32; AWidth, AHeight: Integer;
  AHiQuality: Boolean);
var
  Abmp: TBitmap32;
begin
  if (ABitmap32.Empty) or ((ABitmap32.Width = AWidth) and (ABitmap32.Height = AHeight)) then Exit;

  Abmp := TBitmap32.Create;
  Abmp.Clear;
  try
    if (ABitmap32.Width * 2 = AWidth) and (ABitmap32.Height * 2 = AHeight) then
    begin
      ABitmap32.ResamplerClassName := 'TNearestResampler';
    end
    else if AHiQuality then
    begin
      with TKernelResampler.Create(ABitmap32) do
      begin
        KernelMode := kmTableNearest;
        TableSize := 16;
        Kernel := TLanczosKernel.Create;
      end;
    end
    else
    begin
      ABitmap32.ResamplerClassName := 'TDraftResampler'; // 'TLinearResampler';
    end;
    Abmp.SetSize(AWidth, AHeight);
    ABitmap32.DrawTo(Abmp, Rect(0, 0, Abmp.Width, Abmp.Height),
      Rect(0, 0, ABitmap32.Width, ABitmap32.Height));
    ABitmap32.Assign(Abmp);
  finally
    FreeAndNil(Abmp);
  end;
end;

procedure GetPngFile(ABitmap32: TBitmap32; APngFile: String; ASize: Integer = 0;
  ABackColor: TColor32 = $00000000; AHiQuality: Boolean = True);
var
  APng: TPngImage;
  ABitmap: TBitmap;
  ANewBitmap32: TBitmap32;
begin
  APng := TPngImage.Create;
  ABitmap := TBitmap.Create;
  try
    if ASize <= 0 then
    begin
      ABitmap.SetSize(ABitmap32.Width, ABitmap32.Height);
      ABitmap32.DrawTo(ABitmap.Canvas.Handle, 0, 0);
      APng.Assign(ABitmap);
      CopyBitmap32AlphaValueToPng(ABitmap32, APng);
    end
    else
    begin
      ANewBitmap32 := TBitmap32.Create;
      try
        if ABackColor <> $00000000 then
        begin
          ANewBitmap32.SetSize(ABitmap32.Width, ABitmap32.Height);
          ANewBitmap32.Clear(ABackColor);
          ABitmap32.DrawMode := dmBlend;
          ABitmap32.DrawTo(ANewBitmap32, 0, 0);
        end
        else
        begin
          ANewBitmap32.Assign(ABitmap32);
        end;
        ResizeBitmap32(ANewBitmap32, ASize, ASize, AHiQuality);
        ABitmap.SetSize(ANewBitmap32.Width, ANewBitmap32.Height);
        ANewBitmap32.DrawTo(ABitmap.Canvas.Handle, 0, 0);
        APng.Assign(ABitmap);
        CopyBitmap32AlphaValueToPng(ANewBitmap32, APng);
      finally
        ANewBitmap32.Free;
      end;
    end;

    try
      // DeleteFile(APngFile);
      APng.SaveToFile(APngFile);
    except
    end;
  finally
    ABitmap.Free;
    APng.Free;
  end;
end;

procedure GetJpegFile(ABitmap: TBitmap; AJpegFile: String);
var
  Jpg: TJpegImage;
begin
  Jpg := TJpegImage.Create;
  try
    Jpg.Assign(ABitmap);
    Jpg.CompressionQuality := 90;
    Jpg.Compress;
    Jpg.SaveToFile(AJpegFile);
  finally
    Jpg.Free;
  end
end;

procedure GetJpegFile(ABitmapFile, AJpegFile: String);
var
  ABitmap: TBitmap;
begin
  ABitmap := TBitmap.Create;
  try
    ABitmap.LoadFromFile(ABitmapFile);
    GetJpegFile(ABitmap, AJpegFile);
  finally
    ABitmap.Free;
  end
end;

function GetJpegFile(ABitmap32: TBitmap32): TJpegImage; overload;
var
  ABitmap: TBitmap;
begin
  Result := TJpegImage.Create;
  ABitmap := TBitmap.Create;
  try
    ABitmap.SetSize(ABitmap32.Width, ABitmap32.Height);
    ABitmap32.DrawTo(ABitmap.Canvas.Handle, 0, 0);
    Result.Assign(ABitmap);
    //Result.CompressionQuality := 90;
    //Result.Compress;
  finally
    ABitmap.Free;
  end
end;

procedure GetJpegFile(ABitmap32: TBitmap32; AJpegFile: String);
var
  Jpg: TJpegImage;
  ABitmap: TBitmap;
begin
  Jpg := TJpegImage.Create;
  ABitmap := TBitmap.Create;
  try
    ABitmap.SetSize(ABitmap32.Width, ABitmap32.Height);
    ABitmap32.DrawTo(ABitmap.Canvas.Handle, 0, 0);
    Jpg.Assign(ABitmap);
    // Jpg.CompressionQuality := 90;
    // Jpg.Compress;
    Jpg.SaveToFile(AJpegFile);
  finally
    ABitmap.Free;
    Jpg.Free;
  end
end;

procedure GetJpegFile(ABitmap32: TBitmap32; ARect: TRect; AJpegFile: String); overload;
var
  Jpg: TJpegImage;
  ABitmap: TBitmap;
begin
  Jpg := TJpegImage.Create;
  ABitmap := TBitmap.Create;
  try
    ABitmap.SetSize(ARect.Width, ARect.Height);
    ABitmap32.DrawTo(ABitmap.Canvas.Handle, Rect(0, 0, ARect.Width, ARect.Height), ARect);
    Jpg.Assign(ABitmap);
    // Jpg.CompressionQuality := 90;
    // Jpg.Compress;
    Jpg.SaveToFile(AJpegFile);
  finally
    ABitmap.Free;
    Jpg.Free;
  end
end;

function ReadMMWord(F: TFileStream): Word;
type
  TMotorolaWord = record
    case Byte of
      0:
        (Value: Word);
      1:
        (Byte1, Byte2: Byte);
  end;
var
  MW: TMotorolaWord;
begin
  { It would probably be better to just read these two bytes in normally }
  { and then do a small ASM routine to swap them.  But we aren't talking }
  { about reading entire files, so I doubt the performance gain would be }
  { worth the trouble. }
  F.Read(MW.Byte2, SizeOf(Byte));
  F.Read(MW.Byte1, SizeOf(Byte));
  Result := MW.Value;
end;

procedure GetJPGSize(const sFile: string; var wWidth, wHeight: Word);
const
  ValidSig: array [0 .. 1] of Byte = ($FF, $D8);
  Parameterless = [$01, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7];
var
  Sig: array [0 .. 1] of Byte;
  F: TFileStream;
  X: Integer;
  Seg: Byte;
  Dummy: array [0 .. 15] of Byte;
  Len: Word;
  ReadLen: Longint;
begin
  FillChar(Sig, SizeOf(Sig), #0);
  try
    F := TFileStream.Create(sFile, fmOpenRead);
    try
      ReadLen := F.Read(Sig[0], SizeOf(Sig));

      for X := Low(Sig) to High(Sig) do
        if Sig[X] <> ValidSig[X] then
          ReadLen := 0;

      if ReadLen > 0 then
      begin
        ReadLen := F.Read(Seg, 1);
        while (Seg = $FF) and (ReadLen > 0) do
        begin
          ReadLen := F.Read(Seg, 1);
          if Seg <> $FF then
          begin
            if (Seg = $C0) or (Seg = $C1) then
            begin
              ReadLen := F.Read(Dummy[0], 3); { don't need these bytes }
              wHeight := ReadMMWord(F);
              wWidth := ReadMMWord(F);
            end
            else
            begin
              if not(Seg in Parameterless) then
              begin
                Len := ReadMMWord(F);
                F.Seek(Len - 2, 1);
                F.Read(Seg, 1);
              end
              else
                Seg := $FF; { Fake it to keep looping. }
            end;
          end;
        end;
      end;
    finally
      F.Free;
    end;
  except
  end;
end;

procedure GetPNGSize(const sFile: string; var wWidth, wHeight: Word);
type
  TPNGSig = array [0 .. 7] of Byte;
const
  ValidSig: TPNGSig = (137, 80, 78, 71, 13, 10, 26, 10);
var
  Sig: TPNGSig;
  F: TFileStream;
  X: Integer;
begin
  FillChar(Sig, SizeOf(Sig), #0);
  try
    F := TFileStream.Create(sFile, fmOpenRead);
    try
      F.Read(Sig[0], SizeOf(Sig));
      for X := Low(Sig) to High(Sig) do
        if Sig[X] <> ValidSig[X] then
          Exit;
      F.Seek(18, 0);
      wWidth := ReadMMWord(F);
      F.Seek(22, 0);
      wHeight := ReadMMWord(F);
    finally
      F.Free;
    end;
  except
  end;
end;

function CheckIfGIF(const sFile: string): Boolean;
type
  TGIFHeader = record
    Sig: array [0 .. 5] of AnsiChar;
    ScreenWidth, ScreenHeight: Word;
    flags, Background, Aspect: Byte;
  end;

  TGIFImageBlock = record
    Left, Top, Width, Height: Word;
    flags: Byte;
  end;
var
  F: file;
  Header: TGIFHeader;
  nResult: Integer;
begin
  Result := False;
  if not FileExists(sFile) then
    Exit;

  try
{$I-}
    FileMode := 0; { read-only }
    AssignFile(F, sFile);
    reset(F, 1);
    try
      if IOResult <> 0 then
        Exit;

      BlockRead(F, Header, SizeOf(TGIFHeader), nResult);
      if (nResult <> SizeOf(TGIFHeader)) or (IOResult <> 0) or
        (StrLComp('GIF', Header.Sig, 3) <> 0) then
      begin
        Exit;
      end;
    finally
      close(F);
    end;
{$I+}
    Result := True;
  except
  end;
end;

procedure GetGIFSize(const sGIFFile: string; var wWidth, wHeight: Word);
type
  TGIFHeader = record
    Sig: array [0 .. 5] of AnsiChar;
    ScreenWidth, ScreenHeight: Word;
    flags, Background, Aspect: Byte;
  end;

  TGIFImageBlock = record
    Left, Top, Width, Height: Word;
    flags: Byte;
  end;
var
  F: file;
  Header: TGIFHeader;
  ImageBlock: TGIFImageBlock;
  nResult: Integer;
  X: Integer;
  c: AnsiChar;
  DimensionsFound: Boolean;
begin
  wWidth := 0;
  wHeight := 0;

  if sGIFFile = '' then
    Exit;
  if not FileExists(sGIFFile) then
    Exit;
  try

{$I-}
    FileMode := 0; { read-only }
    AssignFile(F, sGIFFile);
    reset(F, 1);
    try
      if IOResult <> 0 then
        Exit;

      { Read header and ensure valid file. }
      BlockRead(F, Header, SizeOf(TGIFHeader), nResult);
      if (nResult <> SizeOf(TGIFHeader)) or (IOResult <> 0) or
        (StrLComp('GIF', Header.Sig, 3) <> 0) then
      begin
        { Image file invalid }
        close(F);
        Exit;
      end;

      wWidth := Header.ScreenWidth;
      wHeight := Header.ScreenHeight;
    finally
      close(F);
    end;
{$I+}
  except
  end;
end;

function GoodFileRead(fhdl: THandle; buffer: Pointer; readsize: DWord): Boolean;
var
  NumRead: DWord;
  retval: Boolean;
begin
  retval := ReadFile(fhdl, buffer^, readsize, NumRead, Nil);
  Result := retval And (readsize = NumRead);
end;

function ReadMWord(fh: HFile; Var Value: Word): Boolean;
type
  TMotorolaWord = record
    case Byte of
      0:
        (Value: Word);
      1:
        (Byte1, Byte2: Byte);
  end;
var
  MW: TMotorolaWord;
  NumRead: DWord;
begin
  { It would probably be better to just read these two bytes in normally and
    then do a small ASM routine to swap them.  But we aren't talking about
    reading entire files, so I doubt the performance gain would be worth the
    trouble. }
  Result := False;
  if ReadFile(fh, MW.Byte2, SizeOf(Byte), NumRead, nil) then
    if ReadFile(fh, MW.Byte1, SizeOf(Byte), NumRead, nil) then
      Result := True;
  Value := MW.Value;
end;

function ImageType(Fname: String): Smallint;
var
  ImgExt: String;
  Itype: Smallint;
begin
  ImgExt := UpperCase(ExtractFileExt(Fname));
  if ImgExt = '.BMP' then
    Itype := 1
  else if (ImgExt = '.JPEG') or (ImgExt = '.JPG') then
    Itype := 2
  else
    Itype := 0;
  Result := Itype;
end;

function FetchBitmapHeader(PictFileName: String; Var wd, ht: Word): Boolean;
{ similar routine is in "BitmapRegion" routine }
label ErrExit;
const
  ValidSig: array [0 .. 1] of Byte = ($FF, $D8);
  Parameterless = [$01, $D0, $D1, $D2, $D3, $D4, $D5, $D6, $D7];
  BmpSig = $4D42;
var
  { Err : Boolean; }
  fh: HFile;
  { tof : TOFSTRUCT; }
  bf: TBITMAPFILEHEADER;
  bh: TBITMAPINFOHEADER;
  { JpgImg  : TJPEGImage; }
  Itype: Smallint;
  Sig: array [0 .. 1] of Byte;
  X: Integer;
  Seg: Byte;
  Dummy: array [0 .. 15] of Byte;
  skipLen: Word;
  OkBmp, Readgood: Boolean;
begin
  { Open the file and get a handle to it's BITMAPINFO }
  OkBmp := False;
  Itype := ImageType(PictFileName);
  fh := CreateFile(PChar(PictFileName), GENERIC_READ, FILE_SHARE_READ, Nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if (fh = INVALID_HANDLE_VALUE) then
    goto ErrExit;
  if Itype = 1 then
  begin
    { read the BITMAPFILEHEADER }
    if not GoodFileRead(fh, @bf, SizeOf(bf)) then
      goto ErrExit;
    if (bf.bfType <> BmpSig) then { 'BM' }
      goto ErrExit;
    if not GoodFileRead(fh, @bh, SizeOf(bh)) then
      goto ErrExit;
    { for now, don't even deal with CORE headers }
    if (bh.biSize = SizeOf(TBITMAPCOREHEADER)) then
      goto ErrExit;
    wd := bh.biWidth;
    ht := bh.biheight;
    OkBmp := True;
  end
  else if (Itype = 2) then
  begin
    FillChar(Sig, SizeOf(Sig), #0);
    if not GoodFileRead(fh, @Sig[0], SizeOf(Sig)) then
      goto ErrExit;
    for X := Low(Sig) to High(Sig) do
      if Sig[X] <> ValidSig[X] then
        goto ErrExit;
    Readgood := GoodFileRead(fh, @Seg, SizeOf(Seg));
    while (Seg = $FF) and Readgood do
    begin
      Readgood := GoodFileRead(fh, @Seg, SizeOf(Seg));
      if Seg <> $FF then
      begin
        if (Seg = $C0) or (Seg = $C1) or (Seg = $C2) then
        begin
          Readgood := GoodFileRead(fh, @Dummy[0], 3); { don't need these bytes }
          if ReadMWord(fh, ht) and ReadMWord(fh, wd) then
            OkBmp := True;
        end
        else
        begin
          if not(Seg in Parameterless) then
          begin
            ReadMWord(fh, skipLen);
            SetFilePointer(fh, skipLen - 2, nil, FILE_CURRENT);
            GoodFileRead(fh, @Seg, SizeOf(Seg));
          end
          else
            Seg := $FF; { Fake it to keep looping }
        end;
      end;
    end;
  end;
ErrExit:
  CloseHandle(fh);
  Result := OkBmp;
end;

function GetJpegOrientation(AFile: String): TExifOrientation;
var
  ExifInfo: TExifInfo;
begin
  ExifInfo := TExifInfo.Create(nil);
  try
    try
      ExifInfo.ImageFileName := AFile;
      Result := ExifInfo.Orientation;
    except
      Result := eoReserved;
    end;
  finally
    ExifInfo.Free;
  end;
end;

function CheckImageType(FileName: string): TImageType;
var
  MyImage: TMemoryStream;
  Buffer: Word;
begin
  MyImage := TMemoryStream.Create;
  try
    MyImage.LoadFromFile(FileName);
    MyImage.Position := 0;
    if MyImage.Size = 0 then // 如果文件大小等于0，那么错误(
    begin
      Result := IT_Error;
      Exit;
    end;
    MyImage.ReadBuffer(Buffer, 2); //读取文件的前２个字节,放到Buffer里面

    case Buffer of
      $4D42:
        Result := IT_Bmp;
      $D8FF:
        Result := IT_JPEG;
      $4947:
        Result := IT_GIF;
      $050A:
        Result := IT_PCX;
      $5089:
        Result := IT_PNG;
      $4238:
        Result := IT_PSD;
      $A659:
        Result := IT_RAS;
      $DA01:
        Result := IT_SGI;
      $4949:
        Result := IT_TIFF;
    else
      Result := IT_None;
    end;
  finally
    MyImage.Free;
  end;
end;

procedure FixBitmap32Orientation(ABitmap32: TBitmap32; AOrientation: TExifOrientation);
begin
  if AOrientation = eoReserved then Exit;
  case AOrientation of
    eoTopLeft:
    begin
      //正常
    end;
    eoTopRight:
    begin
      //正常，镜像
    end;
    eoBottomRight:
    begin
      //颠倒的
      ABitmap32.Rotate180;
    end;
    eoBottomLeft:
    begin
      //颠倒的，镜像
      ABitmap32.Rotate180;
    end;
    eoLeftTop:
    begin
      ABitmap32.Rotate90;
    end;
    eoRightTop:
    begin
      ABitmap32.Rotate90;
    end;
    eoRightBottom:
    begin
      ABitmap32.Rotate270;
    end;
    eoLeftBottom:
    begin
      ABitmap32.Rotate270;
    end;
   end;
end;


procedure GetIMGSize(const sFile: string; var wWidth, wHeight: Word);
var
  AWidth, AHeight: Word;
  AGIFImage: TGIFImage;
  APicture: TPicture;
begin
  AWidth := 0;
  AHeight := 0;
  GetPNGSize(sFile, AWidth, AHeight);
  if (AWidth > 0) and (AHeight > 0) and (AWidth < 10000) and (AHeight < 10000)
  then
  begin
    wWidth := AWidth;
    wHeight := AHeight;
    Exit;
  end;

  GetGIFSize(sFile, AWidth, AHeight);
  if (AWidth > 0) and (AHeight > 0) and (AWidth < 10000) and (AHeight < 10000)
  then
  begin
    wWidth := AWidth;
    wHeight := AHeight;
    Exit;
  end;

  if CheckIfGIF(sFile) then
  begin
    AGIFImage := TGIFImage.Create;
    try
      try
        wWidth := AGIFImage.Width;
        wHeight := AGIFImage.Height;
        Exit;
      except
      end;
    finally
      AGIFImage.Free;
    end;
  end;

  GetJPGSize(sFile, AWidth, AHeight);
  if (AWidth > 0) and (AHeight > 0) and (AWidth < 10000) and (AHeight < 10000) then
  begin
    case GetJpegOrientation(sFile) of
      eoBottomRight, eoBottomLeft, eoReserved:
      begin
        wWidth := AWidth;
        wHeight := AHeight;
      end
      else
      begin
        wWidth := AHeight;
        wHeight := AWidth;
      end;
    end;
    Exit;
  end;

  FetchBitmapHeader(sFile, AWidth, AHeight);
  if (AWidth > 0) and (AHeight > 0) and (AWidth < 10000) and (AHeight < 10000) then
  begin
    wWidth := AWidth;
    wHeight := AHeight;
    Exit;
  end;

  APicture := TPicture.Create;
  try
    try
      APicture.LoadFromFile(sFile);
      wWidth := APicture.Width;
      wHeight := APicture.Height;
    except
    end;
  finally
    APicture.Free;
  end;
end;

function ImageToPng(ASrcFile, ADstFile: String; AWidth, AHeight: Integer;
  AHighQulity: Boolean; ABackColor: TColor32 = $00000000;
  AGray: Boolean = False): Boolean;
var
  APng: TPngImage;
  APngImage: PngImage2.TPngImage;
  ABitmap32: TBitmap32;
  ABitmap32Target: TBitmap32;
  ABitmap: TBitmap;
  T1: Cardinal;
begin
  T1 := GetTickCount;
  ABitmap32 := GetBitmap32(ASrcFile);
  if AGray then
    ABitmap32.GrayScale();

  Result := not ABitmap32.Empty;
  try
    if not Result then
      Exit;

    ABitmap32Target := TBitmap32.Create;
    try
      ABitmap32Target.SetSize(AWidth, AHeight);
      if not AHighQulity then
      begin
        ABitmap32.ResamplerClassName := 'TLinearResampler';
      end
      else
      begin
        with TKernelResampler.Create(ABitmap32) do
        begin
          KernelMode := kmTableNearest;
          TableSize := 16;
          Kernel := TLanczosKernel.Create;
        end;
      end;

      if ABackColor = $00000000 then
      begin
        ABitmap32.DrawTo(ABitmap32Target, Rect(0, 0, AWidth, AWidth),
          Rect(0, 0, ABitmap32.Width, ABitmap32.Height));
      end
      else
      begin
        ABitmap32.CombineMode := cmBlend;
        ABitmap32Target.Clear(ABackColor);
        ABitmap32.DrawTo(ABitmap32Target, Rect(0, 0, AWidth, AWidth),
          Rect(0, 0, ABitmap32.Width, ABitmap32.Height));
      end;

      FixBitmap32Orientation(ABitmap32Target, GetJpegOrientation(ASrcFile));
      ABitmap := TBitmap.Create;
      try
        ABitmap.SetSize(ABitmap32Target.Width, ABitmap32Target.Height);
        ABitmap32Target.DrawTo(ABitmap.Canvas.Handle, 0, 0);

        APng := TPngImage.Create;
        try
          APng.Assign(ABitmap);
          CopyBitmap32AlphaValueToPng(ABitmap32Target, APng);
          APng.SaveToFile(ADstFile);
        finally
          APng.Free;
        end;
      finally
        ABitmap.Free;
      end;
    finally
      ABitmap32Target.Free;
    end;
  finally
    FreeAndNil(ABitmap32);
  end;
end;

procedure GetThumbnailImage(ASrcFile, ADstFile: String; iconSize: Integer;
  fast: Boolean = False);
var
  Jpg: TJpegImage;
  APng: TPngImage;
  APngImage: PngImage2.TPngImage;
  ABitmap32: TBitmap32;
  ABitmap32Target: TBitmap32;
  ABitmap: TBitmap;
  ASrcWidth, ASrcHeight, ADstWidth, ADstHeight: Integer;
  T1: Cardinal;
begin
  T1 := GetTickCount;
  ABitmap32 := GetBitmap32(ASrcFile);
  try

    ASrcWidth := ABitmap32.Width;
    ASrcHeight := ABitmap32.Height;
    if (ASrcWidth > iconSize) or (ASrcHeight > iconSize) then
    begin
      if ASrcWidth > ASrcHeight then
      begin
        ADstWidth := iconSize;
        ADstHeight := Round(iconSize * (ASrcHeight / ASrcWidth));
      end
      else
      begin
        ADstWidth := Round(iconSize * (ASrcWidth / ASrcHeight));
        ADstHeight := iconSize;
      end;
    end
    else
    begin
      ADstWidth := ASrcWidth;
      ADstHeight := ASrcHeight;
    end;

    ABitmap32Target := TBitmap32.Create;
    try
      ABitmap32Target.SetSize(ADstWidth, ADstHeight);
      ABitmap32.ResamplerClassName := 'TDraftResampler'; // TLinearResampler
      ABitmap32.DrawTo(ABitmap32Target, Rect(0, 0, ADstWidth, ADstHeight),
        Rect(0, 0, ASrcWidth, ASrcHeight));

      {
        if SameText(ExtractFileExt(ASrcFile), '.png') or (fast) then
        begin
        ABitmap32Target.SaveToFile(ADstFile);
        Exit;
        end;
      }

      FixBitmap32Orientation(ABitmap32Target, GetJpegOrientation(ASrcFile));

      ABitmap := TBitmap.Create;
      try
        ABitmap.SetSize(ABitmap32Target.Width, ABitmap32Target.Height);
        ABitmap32Target.DrawTo(ABitmap.Canvas.Handle, 0, 0);

        if True or SameText(ExtractFileExt(ASrcFile), '.png') then
        begin
          APng := TPngImage.Create;
          try
            APng.Assign(ABitmap);
            CopyBitmap32AlphaValueToPng(ABitmap32Target, APng);
            APng.SaveToFile(ADstFile);
          finally
            APng.Free;
          end;
        end
        else
        begin
          Jpg := TJpegImage.Create;
          try
            Jpg.Assign(ABitmap);
            Jpg.JPEGNeeded;
            Jpg.CompressionQuality := 80;
            Jpg.DIBNeeded();
            Jpg.Compress;
            Jpg.SaveToFile(ADstFile);
          finally
            Jpg.Free;
          end
        end;
      finally
        ABitmap.Free;
      end;
    finally
      ABitmap32Target.Free;
    end;
  finally
    FreeAndNil(ABitmap32);
    // Vcl.Dialogs.ShowMessage(IntToStr(GetTickCount - T1));
  end;
end;

function GetThumbnailJpegImageByGDIPlus(ASrcFile, ADstFile: String;
  iconSize: Integer; AQuality: Integer = 75): Boolean;
var
  Bitmap32: GR32.TBitmap32;
  Graphics: TGPGraphics;
  Image, GPImage, pThumbnail: TGPImage;

  ADstLeft, ADstTop, ASrcWidth, ASrcHeight, ADstWidth, ADstHeight: Integer;
  GUID: TGUID;
  params: TEncoderParameters;
  quality: Integer;
begin
  Image := TGPImage.Create(ASrcFile);
  try
    ASrcWidth := Image.GetWidth;
    ASrcHeight := Image.GetHeight;
    if (ASrcWidth = 0) or (ASrcHeight = 0) then raise Exception.Create('invalid image');

    if (ASrcWidth > iconSize) or (ASrcHeight > iconSize) then
    begin
      if ASrcWidth > ASrcHeight then
      begin
        ADstWidth := iconSize;
        ADstHeight := Round(iconSize * (ASrcHeight / ASrcWidth));
      end
      else
      begin
        ADstWidth := Round(iconSize * (ASrcWidth / ASrcHeight));
        ADstHeight := iconSize;
      end;
      ADstLeft := 0; // (iconSize - ADstWidth) div 2;
      ADstTop := 0; // (iconSize - ADstHeight) div 2;
    end
    else
    begin
      ADstWidth := ASrcWidth;
      ADstHeight := ASrcHeight;
      ADstLeft := 0;
      ADstTop := 0;
    end;

    Bitmap32 := GR32.TBitmap32.Create;
    Bitmap32.SetSize(ADstWidth, ADstHeight);
    Bitmap32.Clear($00000000);
    Graphics := TGPGraphics.Create(Bitmap32.Canvas.Handle);
    try
      Graphics.DrawImage(Image, ADstLeft, ADstTop, ADstWidth, ADstHeight);
      GetEncoderClsid('image/jpeg', GUID);
      FixBitmap32Orientation(Bitmap32, GetJpegOrientation(ASrcFile));
      GPImage := GetStdGPImageByBitmap(Bitmap32);
      try
        params.Count := 1;
        params.Parameter[0].GUID := EncoderQuality;
        params.Parameter[0].Type_ := EncoderParameterValueTypeLong;
        params.Parameter[0].NumberOfValues := 1;
        quality := AQuality;
        params.Parameter[0].Value := @quality;
        GPImage.Save(ADstFile, GUID, @params);
      finally
        GPImage.Free;
      end;
    finally
      Graphics.Free;
      Bitmap32.Free;
    end;
  finally
    Image.Free;
  end;
end;

procedure GetThumbnailImageByGDIPlus(ASrcFile, ADstFile: String;
  iconSize: Integer);
var
  Bitmap32: GR32.TBitmap32;
  Graphics: TGPGraphics;
  Image, GPImage, pThumbnail: TGPImage;

  ADstLeft, ADstTop, ASrcWidth, ASrcHeight, ADstWidth, ADstHeight: Integer;
  GUID: TGUID;
begin
  Image := TGPImage.Create(ASrcFile);
  try
    ASrcWidth := Image.GetWidth;
    ASrcHeight := Image.GetHeight;
    if (ASrcWidth = 0) or (ASrcHeight = 0) then
      raise Exception.Create('invalid image');

    if (ASrcWidth > iconSize) or (ASrcHeight > iconSize) then
    begin
      if ASrcWidth > ASrcHeight then
      begin
        ADstWidth := iconSize;
        ADstHeight := Round(iconSize * (ASrcHeight / ASrcWidth));
      end
      else
      begin
        ADstWidth := Round(iconSize * (ASrcWidth / ASrcHeight));
        ADstHeight := iconSize;
      end;
      ADstLeft := 0; // (iconSize - ADstWidth) div 2;
      ADstTop := 0; // (iconSize - ADstHeight) div 2;
    end
    else
    begin
      ADstWidth := ASrcWidth;
      ADstHeight := ASrcHeight;
      ADstLeft := 0;
      ADstTop := 0;
    end;

    Bitmap32 := GR32.TBitmap32.Create;
    Bitmap32.SetSize(ADstWidth, ADstHeight);
    Bitmap32.Clear($00000000);
    Graphics := TGPGraphics.Create(Bitmap32.Canvas.Handle);
    try
      Graphics.DrawImage(Image, ADstLeft, ADstTop, ADstWidth, ADstHeight);
      GetEncoderClsid('image/png', GUID);
      FixBitmap32Orientation(Bitmap32, GetJpegOrientation(ASrcFile));
      GPImage := GetStdGPImageByBitmap(Bitmap32);
      try
        GPImage.Save(ADstFile, GUID);
      finally
        GPImage.Free;
      end;
      // pThumbnail := image.GetThumbnailImage(ADstWidth, ADstHeight, nil, nil);
      // pThumbnail.Save(ADstFile, Guid);
    finally
      Graphics.Free;
      Bitmap32.Free;
      // pThumbnail.Free;
    end;
  finally
    Image.Free;
  end;
end;

function GetThumbnailBitmap32ByGDIPlus(ASrcFile: String; iconSize: Integer;
  var scale: Boolean; ABackColor: TColor32 = $00000000): TBitmap32;
var
  Graphics: TGPGraphics;
  Image, GPImage: TGPImage;

  ADstLeft, ADstTop, ASrcWidth, ASrcHeight, ADstWidth, ADstHeight: Integer;
begin
  Image := TGPImage.Create(ASrcFile);

  ASrcWidth := Image.GetWidth;
  ASrcHeight := Image.GetHeight;

  if (ASrcWidth > iconSize) or (ASrcHeight > iconSize) then
  begin
    scale := True;
    if ASrcWidth > ASrcHeight then
    begin
      ADstWidth := iconSize;
      ADstHeight := Round(iconSize * (ASrcHeight / ASrcWidth));
    end
    else
    begin
      ADstWidth := Round(iconSize * (ASrcWidth / ASrcHeight));
      ADstHeight := iconSize;
    end;
    ADstLeft := 0; // (iconSize - ADstWidth) div 2;
    ADstTop := 0; // (iconSize - ADstHeight) div 2;
  end
  else
  begin
    scale := False;
    ADstWidth := ASrcWidth;
    ADstHeight := ASrcHeight;
    ADstLeft := 0;
    ADstTop := 0;
  end;

  Result := TBitmap32.Create;
  Result.SetSize(ADstWidth, ADstHeight);
  Result.Clear(ABackColor);
  Graphics := TGPGraphics.Create(Result.Canvas.Handle);
  try
    Graphics.DrawImage(Image, ADstLeft, ADstTop, ADstWidth, ADstHeight);
  finally
    Image.Free;
    Graphics.Free;
  end;
  FixBitmap32Orientation(Result, GetJpegOrientation(ASrcFile));
end;

function IsWriting(AFile: String): Boolean;
var
  Attribute: Integer;
begin
  Result := False;
  Attribute := FileGetAttr(AFile);
  try
    if not SetFileAttributes(PChar(AFile), FILE_ATTRIBUTE_ARCHIVE) then
    begin
      Result := True;
      Exit;
    end;
  finally
    FileSetAttr(AFile, Attribute);
  end;
end;

function ExtractIcons(ASrcFile, ADstFile: String; iconSize: Integer;
  iconIndex: Integer): Boolean;
var
  hIcon: THandle;
  nIconId: DWord;
  OldValue: Pointer;
begin
  // if IsWriting(ASrcFile) then Exit;

  try
    if Is64Bit then
      Wow64DisableWow64FsRedirection(OldValue);
    try
      nIconId := iconIndex;

      if (GetFileLength(ASrcFile, False) > 0) and
        (SameText('.jpg', ExtractFileExt(ASrcFile)) or SameText('.tif',
        ExtractFileExt(ASrcFile)) or SameText('.bmp', ExtractFileExt(ASrcFile))
        or SameText('.png', ExtractFileExt(ASrcFile))) then
      begin
        GetThumbnailImage(ASrcFile, ADstFile, 72);
      end
      else if DirectoryExists(ASrcFile) then
        GetFileIconToPng(ASrcFile, ADstFile)
      else if PrivateExtractIcons(PWideChar(ASrcFile), 0, iconSize, iconSize,
        @hIcon, @nIconId, 1, LR_LOADFROMFILE) <> 0 then
      begin
        try
          IconHandleToPng(hIcon, ADstFile);
        finally
          DestroyIcon(hIcon);
        end;
      end
      else
      begin
        GetFileIconToPng(ASrcFile, ADstFile)
      end;
    finally
      if Is64Bit then
        Wow64RevertWow64FsRedirection(OldValue);
    end;
  except

  end;
end;

function PngToIco(const AInPngFile, AOutIcoFile: string): Boolean;
var
  aIcon: TIcon;
  AHICON: hIcon;
  AGPBitmap: TGPBitmap;
begin
  Result := True;
  try
    if FileExists(AOutIcoFile) then
      DeleteFile(AOutIcoFile);
    AGPBitmap := TGPBitmap.Create(AInPngFile);
    try
      AGPBitmap.GetHICON(AHICON);
      aIcon := TIcon.Create;
      try
        aIcon.Handle := AHICON;
        aIcon.SaveToFile(AOutIcoFile);
      finally
        aIcon.Free;
      end;
    finally
      AGPBitmap.Free;
    end;
  except
    Result := False;
  end;
end;

function GetIconFromPngImage2(APngImage: TPngImage): TIcon;
var
  AHICON: hIcon;
  AGPBitmap: Gdiplus.TGPBitmap;
  ABitmap32: TBitmap32;
begin
  Result := TIcon.Create;
  ABitmap32 := JinUtils.GetBitmap32ByPngImage(APngImage);
  AGPBitmap := JinUtils.GetGPImageByBitmap(ABitmap32);
  try
    AHICON := AGPBitmap.GetHICON;
    Result.Handle := AHICON;
  finally
    AGPBitmap.Free;
    ABitmap32.Free;
  end;
end;

function GetIconFromPngImage(APngImage: TPngImage): TIcon;
var
  BmImg: TBitmap;
  IconInfo: TIconInfo;
  Ico: TIcon;
begin
  BmImg := TBitmap.Create;
  try
    BmImg.PixelFormat := pf32bit;
    BmImg.Assign(APngImage);

    FillChar(IconInfo, SizeOf(IconInfo), 0);
    IconInfo.fIcon := True;
    IconInfo.hbmMask := BmImg.MaskHandle;
    IconInfo.hbmColor := BmImg.Handle;

    Ico := TIcon.Create;
    Ico.Handle := CreateIconIndirect(IconInfo);
    Result := Ico;
  finally
    BmImg.Free;
  end;
end;

function GetIconFromPngFile(AFile: String): TIcon;
var
  AHICON: hIcon;
  AGPBitmap: Gdiplus.TGPBitmap;
  AImageData: TImageData;
begin
  Result := TIcon.Create;

  AGPBitmap := Gdiplus.TGPBitmap.Create(AFile);
  try
    AImageData := LockGpBitmap(AGPBitmap);
    PArgbConvertArgb(AImageData);
    UnlockGpBitmap(AGPBitmap, AImageData);
    AHICON := AGPBitmap.GetHICON();
    Result.Handle := AHICON;
  finally
    AGPBitmap.Free;
  end;
end;

function GetIconFromPngFile2(AFile: String): TIcon;
var
  BmImg: TBitmap;
  BmpMask: TBitmap;
  IconInfo: TIconInfo;
  Ico: TIcon;
  APngImage: TPngImage;
begin
  BmImg := TBitmap.Create;
  BmpMask := TBitmap.Create;
  APngImage := TPngImage.Create;
  APngImage.LoadFromFile(AFile);
  try
    BmImg.PixelFormat := pf32bit;
    BmImg.SetSize(APngImage.Width, APngImage.Height);

    //APngImage.Draw(BmImg.Canvas, Rect(0, 0, APngImage.Width, APngImage.Height));
    BmImg.Assign(APngImage);
    BmpMask.Canvas.Brush.Color := clBlack;
    BmpMask.SetSize(BmImg.Width, BmImg.Height);

    FillChar(IconInfo, SizeOf(IconInfo), 0);
    IconInfo.fIcon := True;
    IconInfo.hbmMask := BmpMask.MaskHandle;
    IconInfo.hbmColor := BmImg.Handle;

    Ico := TIcon.Create;
    Ico.Handle := CreateIconIndirect(IconInfo);
    Result := Ico;
  finally
    APngImage.Free;
    BmImg.Free;
    BmpMask.Free;
  end;
end;

function GetIconFromPngImage3(APngImage: TPngImage): TIcon;
type
  TRGBTripleArray = array [Word] of TRGBTriple;
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBQuadArray = array [Word] of TRGBQuad;
  PRGBQuadArray = ^TRGBQuadArray;
var
  ms: TMemoryStream;
  BmImg, BmMaskImg: TBitmap;
  rgbL: PRGBTripleArray;
  alphaL: VCL.Imaging.PngImage.PByteArray;
  destBmL: PRGBQuadArray;
  X, Y: Integer;
  IconDir: TIcondir;
  IconDirectoryEntry: TIconDirectoryEntry;
  ColorInfoHeaderSize, ColorImageSize, MaskInfoHeaderSize, MaskImageSize: DWord;
  ColorInfoHeader, ColorImage, MaskInfoHeader, MaskImage: Pointer;
begin
  Result := nil;
  try
    BmImg := TBitmap.Create;
    BmMaskImg := TBitmap.Create;
    try
      BmImg.PixelFormat := pf32bit;
      BmMaskImg.PixelFormat := pf1bit;
      BmMaskImg.Monochrome := True;
      BmImg.Width := APngImage.Width;
      BmImg.Height := APngImage.Height;
      BmMaskImg.Width := APngImage.Width;
      BmMaskImg.Height := APngImage.Height;

      for Y := 0 to APngImage.Height - 1 do
      begin
        rgbL := APngImage.ScanLine[Y];
        alphaL := APngImage.AlphaScanline[Y];
        destBmL := BmImg.ScanLine[Y];
        for X := 0 to APngImage.Width - 1 do
        begin
          // AND Mask
          if alphaL[X] > 0 then
            BmMaskImg.Canvas.Pixels[X, Y] := clBlack
          else
            BmMaskImg.Canvas.Pixels[X, Y] := clWhite;

          // XOR Mask
          destBmL[X].rgbBlue := rgbL[X].rgbtBlue;
          destBmL[X].rgbGreen := rgbL[X].rgbtGreen;
          destBmL[X].rgbRed := rgbL[X].rgbtRed;
          destBmL[X].rgbReserved := alphaL[X];
        end;
      end;

      // get sizes
      GetDIBSizes(BmImg.Handle, ColorInfoHeaderSize, ColorImageSize);
      GetDIBSizes(BmMaskImg.Handle, MaskInfoHeaderSize, MaskImageSize);

      // allocate memory
      GetMem(ColorInfoHeader, ColorInfoHeaderSize);
      GetMem(MaskInfoHeader, MaskInfoHeaderSize);
      GetMem(ColorImage, ColorImageSize);
      GetMem(MaskImage, MaskImageSize);
      try
        // get colored and masked bitmap header and image bytes
        GetDIB(BmImg.Handle, 0, ColorInfoHeader^, ColorImage^);
        GetDIB(BmMaskImg.Handle, 0, MaskInfoHeader^, MaskImage^);

        ZeroMemory(@IconDir, SizeOf(IconDir));
        ZeroMemory(@IconDirectoryEntry, SizeOf(TIconDirectoryEntry));

        // icon dir
        with IconDir do
        begin
          idReserved := 0;
          idType := rc3_Icon;
          idCount := 1; // 1 icon
        end;

        // dir entries - 1 icon for now
        with IconDirectoryEntry do
        begin
          bWidth := PBitmapInfoHeader(ColorInfoHeader)^.biWidth and $FF;
          bHeight := PBitmapInfoHeader(ColorInfoHeader)^.biheight and $FF;
          bColorCount := 0; // set max colors
          wPlanes := PBitmapInfoHeader(ColorInfoHeader)^.biPlanes;
          wBitCount := PBitmapInfoHeader(ColorInfoHeader)^.biBitCount;
          dwBytesInRes := ColorInfoHeaderSize + ColorImageSize + MaskImageSize;
          dwImageOffset := SizeOf(TIcondir) + SizeOf(TIconDirectoryEntry);
        end;

        // color height includes mask bits - so double it
        PBitmapInfoHeader(ColorInfoHeader)^.biheight :=
          PBitmapInfoHeader(ColorInfoHeader)^.biheight * 2;

        // celar stream where will be new icon
        ms := TMemoryStream.Create;
        try
          // write headers to stream
          ms.Write(IconDir, SizeOf(TIcondir));
          ms.Write(IconDirectoryEntry, SizeOf(TIconDirectoryEntry));
          // write data to stream
          ms.Write(ColorInfoHeader^, ColorInfoHeaderSize);
          ms.Write(ColorImage^, ColorImageSize);
          ms.Write(MaskImage^, MaskImageSize);
          Result := TIcon.Create;
          ms.Position := 0;
          Result.LoadFromStream(ms);
          Result.SaveToFile('F:\1.ico');
        finally
          ms.Free;
        end;
      finally
        FreeMem(ColorInfoHeader);
        FreeMem(MaskInfoHeader);
        FreeMem(ColorImage);
        FreeMem(MaskImage);
      end;
    finally
      BmMaskImg.Free;
      BmImg.Free;
    end;
  except
  end;
end;

procedure SetFormIconsFile(FormHandle: hwnd; AFile: String);
var
  hIcon: THandle;
  nIconId: DWord;
begin
  if PrivateExtractIcons(PWideChar(AFile), 0, 16, 16, @hIcon, @nIconId, 1,
    LR_LOADFROMFILE) <> 0 then
  begin
    if hIcon > 0 then
    begin
      SendMessage(FormHandle, WM_SETICON, ICON_SMALL, hIcon);
      DestroyIcon(hIcon);
    end;
  end;

  if PrivateExtractIcons(PWideChar(AFile), 0, 32, 32, @hIcon, @nIconId, 1,
    LR_LOADFROMFILE) <> 0 then
  begin
    if hIcon > 0 then
    begin
      SendMessage(FormHandle, WM_SETICON, ICON_BIG, hIcon);
      DestroyIcon(hIcon);
    end;
  end;
end;

procedure SetFormIconsByRes(AResHandle: THandle; FormHandle: hwnd;
  SmallIconName, LargeIconName: string);
var
  hIconS, hIconL: Integer;
begin
  hIconS := LoadIcon(AResHandle, PChar(SmallIconName));
  if hIconS > 0 then
  begin
    hIconS := SendMessage(FormHandle, WM_SETICON, ICON_SMALL, hIconS);
    if hIconS > 0 then
      DestroyIcon(hIconS);
  end;

  hIconL := LoadIcon(AResHandle, PChar(LargeIconName));
  if hIconL > 0 then
  begin
    hIconL := SendMessage(FormHandle, WM_SETICON, ICON_BIG, hIconL);
    if hIconL > 0 then
      DestroyIcon(hIconL);
  end;
end;

procedure SetFormIconsByIconHandle(FormHandle: hwnd; hIconS, hIconL: Integer);
begin
  if hIconL > 0 then
  begin
    hIconL := SendMessage(FormHandle, WM_SETICON, ICON_BIG, hIconL);
    if hIconL > 0 then
      DestroyIcon(hIconL);
  end;

  if hIconS > 0 then
  begin
    hIconS := SendMessage(FormHandle, WM_SETICON, ICON_SMALL, hIconS);
    if hIconS > 0 then
      DestroyIcon(hIconS);
  end;
end;

function GetLinkFileName(sLinkFileName: String;
  out sTargetFileName: String): Boolean;
const
  IID_IPersistFile: TGUID = '{0000010B-0000-0000-C000-000000000046}';
var
  psl: IShelllink;
  ppf: IPersistFile;
  hres, nLen: Integer;
  pfd: TWin32FindData;
  pTargetFile: pansichar;
begin
  CoInitialize(nil);
  try
    Result := False;
    cocreateinstance(clsid_shelllink, nil, clsctx_inproc_server,
      IID_IShellLinkA, psl);
    if (Succeeded(hres)) then
    begin
      hres := psl.QueryInterface(IID_IPersistFile, ppf);
      if (Succeeded(hres)) then
      begin
        ppf.Load(PWideChar(sLinkFileName), STGM_READ);
        GetMem(pTargetFile, MAX_PATH);
        ZeroMemory(pTargetFile, MAX_PATH);
        hres := psl.GetPath(PWideChar(pTargetFile), MAX_PATH, pfd,
          SLGP_UNCPRIORITY);
        if (Succeeded(hres)) then
        begin
          sTargetFileName := StrPas(pTargetFile);
          Result := True;
        end;
        FreeMem(pTargetFile);
      end;
    end;
  finally
    CoUninitialize;
  end;

end;

procedure getExecData(lnkName: String; var execName: String);
var
  prodCode: array [0 .. MAX_PATH] of Char;
  featureId: array [0 .. MAX_PATH] of Char;
  compCode: array [0 .. MAX_PATH] of Char;
  APath: array [0 .. MAX_PATH] of Char;
  pathLength: DWord;
  RET: UINT;
begin
  RET := MsiGetShortcutTarget(PChar(lnkName), prodCode, featureId, compCode);
  if RET = ERROR_SUCCESS then
  begin
    pathLength := SizeOf(APath);
    ZeroMemory(@APath, SizeOf(APath));

    RET := MsiGetComponentPath(prodCode, compCode, APath, @pathLength);
    if RET = INSTALLSTATE_LOCAL then
      execName := APath;
  end;
end;

function GetLinksDirInWin7: String;
var
  Reg: TRegistry;
begin
  Result := '';
  Reg := TRegistry.Create(KEY_READ);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey
      ('Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders', False)
    then
    begin
      Result := Reg.ReadString('{BFB9D5E0-C6A9-404C-B2B2-AE6DB6AF4968}');
    end;
  finally
    Reg.Free;
  end;
end;

procedure CreateLink(const lnkFile, Target, arg, workdir, Description: String;
  icon: String; iconIndex: Integer);
var
  vObject: IUnknown;
  vShellLink: IShelllink;
  vPersistFile: IPersistFile;
  vLinkFilename: WideString;
  vlinkshortname: string;
begin
  CoInitialize(nil);
  try
    vObject := CreateComObject(clsid_shelllink);
    vShellLink := vObject as IShelllink;
    vPersistFile := vObject as IPersistFile;
    vShellLink.SetPath(PChar(Target));
    vShellLink.SetWorkingDirectory(PChar(workdir));
    vShellLink.SetArguments(PChar(arg));
    vShellLink.SetDescription(PChar(Description));
    vShellLink.SetIconLocation(PChar(icon), iconIndex);

    vLinkFilename := lnkFile;
    vPersistFile.Save(pWChar(vLinkFilename), False);
  finally
    CoUninitialize;
  end;
end;

function LinkFileInfo(const lnkFileName: string; var info: LINK_FILE_INFO;
  const bSet: Boolean): Boolean;
var
  hr: hResult;
  psl: IShelllink;
  wfd: win32_find_data;
  ppf: IPersistFile;
begin
  CoInitialize(nil);
  try
    Result := False;
    if (Succeeded(cocreateinstance(clsid_shelllink, nil, clsctx_inproc_server,
      IID_IShellLinkA, psl))) then
    begin
      hr := psl.QueryInterface(IPersistFile, ppf);
      if Succeeded(hr) then
      begin
        hr := ppf.Load(PWideChar(lnkFileName), STGM_READ);
        if Succeeded(hr) then
        begin
          hr := psl.Resolve(0, SLR_NO_UI or SLR_NOUPDATE or SLR_NOSEARCH);
          if Succeeded(hr) then
          begin
            if bSet then
            begin
              psl.SetArguments(PWideChar(@info.Arguments[0]));
              psl.SetDescription(PWideChar(@info.Description[0]));
              psl.SetHotkey(info.HotKey);
              psl.SetIconLocation(PWideChar(@info.IconLocation[0]),
                info.iconIndex);
              psl.SetIDList(info.ItemIDList);
              psl.SetPath(PWideChar(@info.FileName[0]));
              psl.SetShowCmd(info.ShowState);
              psl.SetRelativePath(PWideChar(@info.RelativePath[0]), 0);
              psl.SetWorkingDirectory(PWideChar(@info.WorkDirectory[0]));
              Result := Succeeded(psl.Resolve(0, SLR_UPDATE));
            end
            else
            begin
              psl.GetPath(PWideChar(@info.FileName[0]), MAX_PATH, wfd,
                SLGP_SHORTPATH);
              psl.GetIconLocation(PWideChar(@info.IconLocation[0]), MAX_PATH,
                info.iconIndex);
              psl.GetWorkingDirectory(PWideChar(@info.WorkDirectory[0]),
                MAX_PATH);
              psl.GetDescription(PWideChar(@info.Description[0]), CCH_MAXNAME);
              psl.GetArguments(PWideChar(@info.Arguments[0]), MAX_PATH);
              psl.GetHotkey(info.HotKey);
              psl.GetIDList(info.ItemIDList);
              psl.GetShowCmd(info.ShowState);
              Result := True;
            end;
          end;
        end;
      end;
    end;
  finally
    CoUninitialize;
  end;

end;

function IsWin64: Boolean;
var
  Kernel32Handle: THandle;
  IsWow64Process: function(Handle: WinApi.Windows.THandle; var Res: WinApi.Windows.BOOL)
    : WinApi.Windows.BOOL; stdcall;
  GetNativeSystemInfo: procedure(var lpSystemInfo: TSystemInfo); stdcall;
  isWoW64: BOOL;
  SystemInfo: TSystemInfo;
const
  PROCESSOR_ARCHITECTURE_AMD64 = 9;
  PROCESSOR_ARCHITECTURE_IA64 = 6;
begin
  Kernel32Handle := GetModuleHandle('KERNEL32.DLL');
  if Kernel32Handle = 0 then
    Kernel32Handle := LoadLibrary('KERNEL32.DLL');
  if Kernel32Handle <> 0 then
  begin
    IsWow64Process := GetProcAddress(Kernel32Handle, 'IsWow64Process');
    GetNativeSystemInfo := GetProcAddress(Kernel32Handle,
      'GetNativeSystemInfo');
    if Assigned(IsWow64Process) then
    begin
      IsWow64Process(GetCurrentProcess, isWoW64);
      Result := isWoW64 and Assigned(GetNativeSystemInfo);
      if Result then
      begin
        GetNativeSystemInfo(SystemInfo);
        Result := (SystemInfo.wProcessorArchitecture =
          PROCESSOR_ARCHITECTURE_AMD64) or
          (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_IA64);
      end;
    end
    else
      Result := False;
  end
  else
    Result := False;
end;

function CreateLinkFile(const info: LINK_FILE_INFO;
  const DestFileName: string = ''): Boolean;
var
  anobj: IUnknown;
  shlink: IShelllink;
  pFile: IPersistFile;
  wFileName: WideString;
begin
  CoInitialize(nil);
  try
    wFileName := DestFileName;
    anobj := CreateComObject(clsid_shelllink);
    shlink := anobj as IShelllink;
    pFile := anobj as IPersistFile;
    shlink.SetPath(PWideChar(@info.FileName[0]));
    shlink.SetWorkingDirectory(PWideChar(@info.WorkDirectory[0]));
    shlink.SetDescription(PWideChar(@info.Description[0]));
    shlink.SetArguments(PWideChar(@info.Arguments[0]));
    shlink.SetIconLocation(PWideChar(@info.IconLocation[0]), info.iconIndex);
    shlink.SetHotkey(info.HotKey);
    shlink.SetShowCmd(info.ShowState);
    shlink.SetRelativePath(PWideChar(@info.RelativePath[0]), 0);
    if DestFileName = '' then
      wFileName := ChangeFileExt(info.FileName, 'lnk');
    Result := Succeeded(pFile.Save(pWChar(wFileName), False));
  finally
    CoUninitialize;
  end;
end;

function ShortCutToString(const HotKey: Word): string;
var
  shift: tshiftstate;
begin
  shift := [];
  if ((wordrec(HotKey).hi shr 0) and 1) <> 0 then
    include(shift, ssshift);

  if ((wordrec(HotKey).hi shr 1) and 1) <> 0 then
    include(shift, ssctrl);

  if ((wordrec(HotKey).hi shr 2) and 1) <> 0 then
    include(shift, ssalt);

  Result := shortcuttotext(shortcut(wordrec(HotKey).lo, shift));
end;

function GetRemovableLogicalDrives: WideString;
var
  drives: set of 0 .. 25;
  drive: Integer;
  wstr: string;
begin
  Result := '';
  DWord(drives) := WinApi.Windows.GetLogicalDrives;
  for drive := 2 to 25 do
  begin
    if drive in drives then
    begin
      wstr := Chr(drive + Ord('A'));
      if (wstr <> 'A') and (wstr <> 'B') and (wstr <> '') then
      begin
        if CheckIsUSBPart(Chr(drive + Ord('A'))) then
        begin
          if Result = '' then
            Result := (wstr + ':')
          else
            Result := Result + ',' + (wstr + ':');
        end;
      end;
      {
        if getDrivetype(pchar(wstr + ':')) = DRIVE_REMOVABLE then
        begin
        if result = '' then
        result := (wstr + ':')
        else
        result := result + ',' + (wstr + ':');
        end
        else
        continue;
      }
    end;
  end;
end;

function GetHarddiskDrives: WideString;
var
  drives: set of 0 .. 25;
  drive: Integer;
  wstr: string;
begin
  Result := '';
  DWord(drives) := WinApi.Windows.GetLogicalDrives;
  for drive := 2 to 25 do
  begin
    if drive in drives then
    begin
      wstr := Chr(drive + Ord('A'));
      if (wstr <> 'A') and (wstr <> 'B') and (wstr <> '') then
      begin
        if getDrivetype(PChar(wstr + ':')) <> DRIVE_FIXED then
          Continue;

        if not CheckIsUSBPart(Chr(drive + Ord('A'))) then
        begin
          if Result = '' then
            Result := (wstr + ':')
          else
            Result := Result + ',' + (wstr + ':');
        end;
      end;
    end;
  end;
end;

function SystemDeleteFiles(const Source: string; Silent: Boolean = False;
  ToTrash: Boolean = True): Boolean;
var
  fo: TSHFILEOPSTRUCT;
begin
  FillChar(fo, SizeOf(fo), 0);
  with fo do
  begin
    wnd := 0;
    wFunc := FO_DELETE;
    pFrom := PChar(Source + #0);
    pTo := nil;
    fFlags := 0;
    if Silent then
      fFlags := fFlags or { FOF_SILENT or } FOF_NOCONFIRMATION;
    if ToTrash then
      fFlags := fFlags or FOF_ALLOWUNDO;
  end;
  Result := (SHFileOperation(fo) = 0);
end;

procedure GetHardDiskPartitionInfo(const DriveLetter: Char;
  var VolumeName, VolumeSerialNumber, PartitionType: string;
  var TotalSpace, TotalFreeSpace: Int64);
var
  NotUsed: DWord;
  VolumeFlags: DWord;
  VolumeInfo: array [0 .. MAX_PATH] of Char;
  VSNumber: DWord;
  PType: array [0 .. 32] of Char;
  VName: array [0 .. 32] of Char;
  FreeS, TotalS: Int64;
  TotalF: Int64;
begin
  if GetVolumeInformation(PChar(DriveLetter + ':\'), @VName, SizeOf(VolumeInfo),
    @VSNumber, NotUsed, VolumeFlags, PType, 32) then
  begin
    VolumeName := StrPas(VName);
    VolumeSerialNumber := InttoHex(VSNumber, 8);
    PartitionType := StrPas(PType);
    FreeS := 0;
    TotalS := 0;
    TotalF := 0;
    if GetDiskFreeSpaceEx(PChar(DriveLetter + ':\'), FreeS, TotalS, @TotalF)
    then
    begin
      TotalSpace := TotalS;
      TotalFreeSpace := TotalF;
    end
    else
    begin
      TotalSpace := TotalS;
      TotalFreeSpace := TotalF;
    end;
  end
  else
  begin
    VolumeName := '';
    VolumeSerialNumber := '';
    PartitionType := '';
    TotalSpace := 0;
    TotalFreeSpace := 0;
  end;
end;

procedure ChangeWindowMessageFilter(uMessageID: UINT);
var
  DLL_Handle: Integer;
  _ChangeWindowMessageFilter: T_ChangeWindowMessageFilter;
begin
  if not IsVista then
    Exit;
  try
    DLL_Handle := LoadLibrary('user32.dll');
    if DLL_Handle <> 0 then
    begin
      try
        _ChangeWindowMessageFilter := GetProcAddress(DLL_Handle,
          'ChangeWindowMessageFilter');
        if Assigned(_ChangeWindowMessageFilter) then
        begin
          _ChangeWindowMessageFilter(uMessageID, 1);
        end;
      finally
        FreeLibrary(DLL_Handle);
      end;
    end;
  except
  end;
end;

{ 窗口的动态效果 }
// ------------------------------------------------------------------------------
procedure ZoomEffect(theForm: TCustomForm; theOperation: TZoomAction);
var
  rcStart: TRect;
  rcEnd: TRect;
  rcTray: TRect;
  hwndTray: hwnd;
  hwndChild: hwnd;
begin
  { Find the system tray area bounding rectangle }
  hwndTray := FindWindow('Shell_TrayWnd', nil);
  hwndChild := FindWindowEx(hwndTray, 0, 'TrayNotifyWnd', nil);
  GetWindowRect(hwndChild, rcTray);

  { Check for minimize/maximize and swap start/end }
  if theOperation = zaMinimize then
  begin
    rcStart := theForm.BoundsRect;
    rcEnd := rcTray;
  end
  else
  begin
    rcEnd := theForm.BoundsRect;
    rcStart := rcTray;
  end;
  { Here the magic happens... }
  DrawAnimatedRects(theForm.Handle, IDANI_CAPTION, rcStart, rcEnd)
end;

{ 使某窗口置顶 }
// ------------------------------------------------------------------------------
function ForceForeGroundWindow(hwnd: THandle): Boolean;
const
  SPI_GETFOREGROUNDLOCKTIMEOUT = $2000;
  SPI_SETFOREGROUNDLOCKTIMEOUT = $2001;
var
  ForegroundThreadID: DWord;
  ThisThreadID: DWord;
  timeout: DWord;
begin
  if IsIconic(hwnd) then
    ShowWindow(hwnd, SW_RESTORE); // 如果窗口最小化

  { if GetForegroundWindow = hwnd then
    Result := true
    else }
  begin
    if ((Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion > 4)) or
      ((Win32Platform = VER_PLATFORM_WIN32_WINDOWS) and
      ((Win32MajorVersion > 4) or ((Win32MajorVersion = 4) and
      (Win32MinorVersion > 0)))) then
    begin
      Result := False;
      ForegroundThreadID := GetWindowThreadProcessID(GetForegroundWindow, nil);
      ThisThreadID := GetWindowThreadProcessID(hwnd, nil);
      if AttachThreadInput(ThisThreadID, ForegroundThreadID, True) then
      begin
        BringWindowToTop(hwnd);
        SetForegroundWindow(hwnd);
        AttachThreadInput(ThisThreadID, ForegroundThreadID, False);
        Result := (GetForegroundWindow = hwnd);
      end;
      if not Result then
      begin
        SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @timeout, 0);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(0),
          SPIF_SENDCHANGE);
        BringWindowToTop(hwnd);
        SetForegroundWindow(hwnd);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(timeout),
          SPIF_SENDCHANGE);
      end;
    end
    else
    begin
      BringWindowToTop(hwnd);
      SetForegroundWindow(hwnd);
    end;

    Result := (GetForegroundWindow = hwnd);
  end;
end;

function GetDesktopParentWindow: THandle;
var
  hDesktop, hShellDefView, hSysListView32: THandle;
begin
  hDesktop := FindWindow('Progman', nil);
  hShellDefView := FindWindowEx(hDesktop, 0, 'SHELLDLL_DefView', nil);
  hSysListView32 := FindWindowEx(hShellDefView, 0, 'SysListView32', nil);

  if (hSysListView32 = 0) then
  begin
    hShellDefView := 0;
    hDesktop := 0;
    hSysListView32 := 0;
    while (hSysListView32 = 0) do
    begin
      hDesktop := FindWindowEx(0, hDesktop, 'WorkerW', nil);
      if (hDesktop = 0) then
        Break;

      hShellDefView := FindWindowEx(hDesktop, 0, 'SHELLDLL_DefView', nil);
      if (hShellDefView = 0) then
        Continue;

      hSysListView32 := FindWindowEx(hShellDefView, 0, 'SysListView32', nil);
    end;
  end
  else
  begin
    hSysListView32 := hSysListView32;
  end;

  if not IsVista then
    Result := hSysListView32
  else
    Result := hSysListView32;
end;

function WinUserName: string;
var
  FStr: PChar;
  FSize: Cardinal;
begin
  FSize := 255;
  GetMem(FStr, FSize);
  GetUserName(FStr, FSize);
  Result := FStr;
  FreeMem(FStr);
end;

function URLDecode(const s: UTF8String): UTF8String;
var
  Idx: Integer; // loops thru chars in string
  Hex: UTF8String; // string of hex characters
  code: Integer; // hex character code (-1 on error)
begin
  // Intialise result and string index
  Result := '';
  Idx := 1;
  // Loop thru string decoding each character
  while Idx <= Length(s) do
  begin
    case s[Idx] of
      '%':
        begin
          // % should be followed by two hex digits - exception otherwise
          if Idx <= Length(s) - 2 then
          begin
            // there are sufficient digits - try to decode hex digits
            Hex := s[Idx + 1] + s[Idx + 2];
            code := SysUtils.StrToIntDef('$' + UTF8ToUnicodeString(Hex), -1);
            Inc(Idx, 2);
          end
          else
            // insufficient digits - error
            code := -1;
          // check for error and raise exception if found
          if code = -1 then
            raise SysUtils.EConvertError.Create('Invalid hex digit in URL');
          // decoded OK - add character to result
          Result := Result + UTF8Encode(Chr(code));
        end;
      '+':
        // + is decoded as a space
        Result := Result + ' '
    else
      // All other characters pass thru unchanged
      Result := Result + UTF8Encode(s[Idx]);
    end;
    Inc(Idx);
  end;
end;

function URLEncode(const s: UTF8String; const InQueryString: Boolean)
  : UTF8String;
var
  Idx: Integer; // loops thru characters in string
begin
  Result := '';
  for Idx := 1 to Length(s) do
  begin
    case s[Idx] of
      'A' .. 'Z', 'a' .. 'z', '0' .. '9', '-', '_', '.':
        Result := Result + UTF8Encode(s[Idx]);
      ' ':
        if InQueryString then
          Result := Result + '+'
        else
          Result := Result + '%20';
    else
      begin
        //if Ord(s[Idx]) > 128 then
          Result := Result + '%' + UTF8Encode(SysUtils.InttoHex(Ord(s[Idx]), 2));
        //else
        //  Result := Result + UTF8Encode(s[Idx]);
      end;
    end;
  end;
end;

const
  py: array [216 .. 247] of AnsiString = (
    { 216 } 'CJWGNSPGCGNESYPB' + 'TYYZDXYKYGTDJNMJ' + 'QMBSGZSCYJSYYZPG' +
    { 216 } 'KBZGYCYWYKGKLJSW' + 'KPJQHYZWDDZLSGMR' + 'YPYWWCCKZNKYDG',
    { 217 } 'TTNJJEYKKZYTCJNM' + 'CYLQLYPYQFQRPZSL' + 'WBTGKJFYXJWZLTBN' +
    { 217 } 'CXJJJJZXDTTSQZYC' + 'DXXHGCKBPHFFSSYY' + 'BGMXLPBYLLLHLX',
    { 218 } 'SPZMYJHSOJNGHDZQ' + 'YKLGJHXGQZHXQGKE' + 'ZZWYSCSCJXYEYXAD' +
    { 218 } 'ZPMDSSMZJZQJYZCD' + 'JEWQJBDZBXGZNZCP' + 'WHKXHQKMWFBPBY',
    { 219 } 'DTJZZKQHYLYGXFPT' + 'YJYYZPSZLFCHMQSH' + 'GMXXSXJJSDCSBBQB' +
    { 219 } 'EFSJYHXWGZKPYLQB' + 'GLDLCCTNMAYDDKSS' + 'NGYCSGXLYZAYBN',
    { 220 } 'PTSDKDYLHGYMYLCX' + 'PYCJNDQJWXQXFYYF' + 'JLEJBZRXCCQWQQSB' +
    { 220 } 'ZKYMGPLBMJRQCFLN' + 'YMYQMSQYRBCJTHZT' + 'QFRXQHXMJJCJLX',
    { 221 } 'QGJMSHZKBSWYEMYL' + 'TXFSYDSGLYCJQXSJ' + 'NQBSCTYHBFTDCYZD' +
    { 221 } 'JWYGHQFRXWCKQKXE' + 'BPTLPXJZSRMEBWHJ' + 'LBJSLYYSMDXLCL',
    { 222 } 'QKXLHXJRZJMFQHXH' + 'WYWSBHTRXXGLHQHF' + 'NMCYKLDYXZPWLGGS' +
    { 222 } 'MTCFPAJJZYLJTYAN' + 'JGBJPLQGDZYQYAXB' + 'KYSECJSZNSLYZH',
    { 223 } 'ZXLZCGHPXZHZNYTD' + 'SBCJKDLZAYFMYDLE' + 'BBGQYZKXGLDNDNYS' +
    { 223 } 'KJSHDLYXBCGHXYPK' + 'DQMMZNGMMCLGWZSZ' + 'XZJFZNMLZZTHCS',
    { 224 } 'YDBDLLSCDDNLKJYK' + 'JSYCJLKOHQASDKNH' + 'CSGANHDAASHTCPLC' +
    { 224 } 'PQYBSDMPJLPCJOQL' + 'CDHJJYSPRCHNKNNL' + 'HLYYQYHWZPTCZG',
    { 225 } 'WWMZFFJQQQQYXACL' + 'BHKDJXDGMMYDJXZL' + 'LSYGXGKJRYWZWYCL' +
    { 225 } 'ZMSSJZLDBYDCPCXY' + 'HLXCHYZJQSQQAGMN' + 'YXPFRKSSBJLYXY',
    { 226 } 'SYGLNSCMHCWWMNZJ' + 'JLXXHCHSYD CTXRY' + 'CYXBYHCSMXJSZNPW' +
    { 226 } 'GPXXTAYBGAJCXLYS' + 'DCCWZOCWKCCSBNHC' + 'PDYZNFCYYTYCKX',
    { 227 } 'KYBSQKKYTQQXFCWC' + 'HCYKELZQBSQYJQCC' + 'LMTHSYWHMKTLKJLY' +
    { 227 } 'CXWHEQQHTQHZPQSQ' + 'SCFYMMDMGBWHWLGS' + 'LLYSDLMLXPTHMJ',
    { 228 } 'HWLJZYHZJXHTXJLH' + 'XRSWLWZJCBXMHZQX' + 'SDZPMGFCSGLSXYMJ' +
    { 228 } 'SHXPJXWMYQKSMYPL' + 'RTHBXFTPMHYXLCHL' + 'HLZYLXGSSSSTCL',
    { 229 } 'SLDCLRPBHZHXYYFH' + 'BBGDMYCNQQWLQHJJ' + 'ZYWJZYEJJDHPBLQX' +
    { 229 } 'TQKWHLCHQXAGTLXL' + 'JXMSLXHTZKZJECXJ' + 'CJNMFBYCSFYWYB',
    { 230 } 'JZGNYSDZSQYRSLJP' + 'CLPWXSDWEJBJCBCN' + 'AYTWGMPABCLYQPCL' +
    { 230 } 'ZXSBNMSGGFNZJJBZ' + 'SFZYNDXHPLQKZCZW' + 'ALSBCCJXJYZHWK',
    { 231 } 'YPSGXFZFCDKHJGXD' + 'LQFSGDSLQWZKXTMH' + 'SBGZMJZRGLYJBPML' +
    { 231 } 'MSXLZJQQHZSJCZYD' + 'JWBMJKLDDPMJEGXY' + 'HYLXHLQYQHKYCW',
    { 232 } 'CJMYYXNATJHYCCXZ' + 'PCQLBZWWYTWBQCML' + 'PMYRJCCCXFPZNZZL' +
    { 232 } 'JPLXXYZTZLGDLDCK' + 'LYRLZGQTGJHHGJLJ' + 'AXFGFJZSLCFDQZ',
    { 233 } 'LCLGJDJCSNCLLJPJ' + 'QDCCLCJXMYZFTSXG' + 'CGSBRZXJQQCTZHGY' +
    { 233 } 'QTJQQLZXJYLYLBCY' + 'AMCSTYLPDJBYREGK' + 'JZYZHLYSZQLZNW',
    { 234 } 'CZCLLWJQJJJKDGJZ' + 'OLBBZPPGLGHTGZXY' + 'GHZMYCNQSYCYHBHG' +
    { 234 } 'XKAMTXYXNBSKYZZG' + 'JZLQJDFCJXDYGJQJ' + 'JPMGWGJJJPKQSB',
    { 235 } 'GBMMCJSSCLPQPDXC' + 'DYYKYWCJDDYYGYWR' + 'HJRTGZNYQLDKLJSZ' +
    { 235 } 'ZGZQZJGDYKSHPZMT' + 'LCPWNJAFYZDJCNMW' + 'ESCYGLBTZCGMSS',
    { 236 } 'LLYXQSXSBSJSBBGG' + 'GHFJLYPMZJNLYYWD' + 'QSHZXTYYWHMCYHYW' +
    { 236 } 'DBXBTLMSYYYFSXJC' + 'SDXXLHJHF SXZQHF' + 'ZMZCZTQCXZXRTT',
    { 237 } 'DJHNNYZQQMNQDMMG' + 'LYDXMJGDHCDYZBFF' + 'ALLZTDLTFXMXQZDN' +
    { 237 } 'GWQDBDCZJDXBZGSQ' + 'QDDJCMBKZFFXMKDM' + 'DSYYSZCMLJDSYN',
    { 238 } 'SPRSKMKMPCKLGDBQ' + 'TFZSWTFGGLYPLLJZ' + 'HGJJGYPZLTCSMCNB' +
    { 238 } 'TJBQFKTHBYZGKPBB' + 'YMTDSSXTBNPDKLEY' + 'CJNYCDYKZDDHQH',
    { 239 } 'SDZSCTARLLTKZLGE' + 'CLLKJLQJAQNBDKKG' + 'HPJTZQKSECSHALQF' +
    { 239 } 'MMGJNLYJBBTMLYZX' + 'DCJPLDLPCQDHZYCB' + 'ZSCZBZMSLJFLKR',
    { 240 } 'ZJSNFRGJHXPDHYJY' + 'BZGDLJCSEZGXLBLH' + 'YXTWMABCHECMWYJY' +
    { 240 } 'ZLLJJYHLGBDJLSLY' + 'GKDZPZXJYYZLWCXS' + 'ZFGWYYDLYHCLJS',
    { 241 } 'CMBJHBLYZLYCBLYD' + 'PDQYSXQZBYTDKYYJ' + 'YYCNRJMPDJGKLCLJ' +
    { 241 } 'BCTBJDDBBLBLCZQR' + 'PPXJCGLZCSHLTOLJ' + 'NMDDDLNGKAQHQH',
    { 242 } 'JHYKHEZNMSHRP QQ' + 'JCHGMFPRXHJGDYCH' + 'GHLYRZQLCYQJNZSQ' +
    { 242 } 'TKQJYMSZSWLCFQQQ' + 'XYFGGYPTQWLMCRNF' + 'KKFSYYLQBMQAMM',
    { 243 } 'MYXCTPSHCPTXXZZS' + 'MPHPSHMCLMLDQFYQ' + 'XSZYJDJJZZHQPDSZ' +
    { 243 } 'GLSTJBCKBXYQZJSG' + 'PSXQZQZRQTBDKYXZ' + 'KHHGFLBCSMDLDG',
    { 244 } 'DZDBLZYYCXNNCSYB' + 'ZBFGLZZXSWMSCCMQ' + 'NJQSBDQSJTXXMBLT' +
    { 244 } 'XZCLZSHZCXRQJGJY' + 'LXZFJPHYXZQQYDFQ' + 'JJLZZNZJCDGZYG',
    { 245 } 'CTXMZYSCTLKPHTXH' + 'TLBJXJLXSCDQXCBB' + 'TJFQZFSLTJBTKQBX' +
    { 245 } 'XJJLJCHCZDBZJDCZ' + 'JDCPRNPQCJPFCZLC' + 'LZXBDMXMPHJSGZ',
    { 246 } 'GSZZQLYLWTJPFSYA' + 'SMCJBTZYYCWMYTCS' + 'JJLQCQLWZMALBXYF' +
    { 246 } 'BPNLSFHTGJWEJJXX' + 'GLLJSTGSHJQLZFKC' + 'GNNDSZFDEQFHBS',
    { 247 } 'AQTGYLBXMMYGSZLD' + 'YDQMJJRGBJTKGDHG' + 'KBLQKBDMBYLXWCXY' +
    { 247 } 'TTYBKMRTJZXQJBHL' + 'MHMJJZMQASLDCYXY' + 'QDLQCAFYWYXQHZ');

function ChnPy(Value: array of AnsiChar): AnsiChar;
begin
  Result := #0;
  case Byte(Value[0]) of
    176:
      case Byte(Value[1]) of
        161 .. 196:
          Result := 'A';
        197 .. 254:
          Result := 'B';
      end; { case }
    177:
      Result := 'B';
    178:
      case Byte(Value[1]) of
        161 .. 192:
          Result := 'B';
        193 .. 205:
          Result := 'C';
        206:
          Result := 'S'; // 参
        207 .. 254:
          Result := 'C';
      end; { case }
    179:
      Result := 'C';
    180:
      case Byte(Value[1]) of
        161 .. 237:
          Result := 'C';
        238 .. 254:
          Result := 'D';
      end; { case }
    181:
      Result := 'D';
    182:
      case Byte(Value[1]) of
        161 .. 233:
          Result := 'D';
        234 .. 254:
          Result := 'E';
      end; { case }
    183:
      case Byte(Value[1]) of
        161:
          Result := 'E';
        162 .. 254:
          Result := 'F';
      end; { case }
    184:
      case Byte(Value[1]) of
        161 .. 192:
          Result := 'F';
        193 .. 254:
          Result := 'G';
      end; { case }
    185:
      case Byte(Value[1]) of
        161 .. 253:
          Result := 'G';
        254:
          Result := 'H';
      end; { case }
    186:
      Result := 'H';
    187:
      case Byte(Value[1]) of
        161 .. 246:
          Result := 'H';
        247 .. 254:
          Result := 'J';
      end; { case }
    188 .. 190:
      Result := 'J';
    191:
      case Byte(Value[1]) of
        161 .. 165:
          Result := 'J';
        166 .. 254:
          Result := 'K';
      end; { case }
    192:
      case Byte(Value[1]) of
        161 .. 171:
          Result := 'K';
        172 .. 254:
          Result := 'L';
      end; { case }
    193:
      Result := 'L';
    194:
      case Byte(Value[1]) of
        161 .. 231:
          Result := 'L';
        232 .. 254:
          Result := 'M';
      end; { case }
    195:
      Result := 'M';
    196:
      case Byte(Value[1]) of
        161 .. 194:
          Result := 'M';
        195 .. 254:
          Result := 'N';
      end; { case }
    197:
      case Byte(Value[1]) of
        161 .. 181:
          Result := 'N';
        182 .. 189:
          Result := 'O';
        190 .. 254:
          Result := 'P';
      end; { case }
    198:
      case Byte(Value[1]) of
        161 .. 217:
          Result := 'P';
        218 .. 254:
          Result := 'Q';
      end; { case }
    199:
      Result := 'Q';
    200:
      case Byte(Value[1]) of
        161 .. 186:
          Result := 'Q';
        187 .. 245:
          Result := 'R';
        246 .. 254:
          Result := 'S';
      end; { case }
    201 .. 202:
      Result := 'S';
    203:
      case Byte(Value[1]) of
        161 .. 249:
          Result := 'S';
        250 .. 254:
          Result := 'T';
      end; { case }
    204:
      Result := 'T';
    205:
      case Byte(Value[1]) of
        161 .. 217:
          Result := 'T';
        218 .. 254:
          Result := 'W';
      end; { case }
    206:
      case Byte(Value[1]) of
        161 .. 243:
          Result := 'W';
        244 .. 254:
          Result := 'X';
      end; { case }
    207 .. 208:
      Result := 'X';
    209:
      case Byte(Value[1]) of
        161 .. 184:
          Result := 'X';
        185 .. 254:
          Result := 'Y';
      end; { case }
    210 .. 211:
      Result := 'Y';
    212:
      case Byte(Value[1]) of
        161 .. 208:
          Result := 'Y';
        209 .. 254:
          Result := 'Z';
      end; { case }
    213 .. 215:
      Result := 'Z';
    216 .. 247:
      Result := py[Byte(Value[0])][Byte(Value[1]) - 160];
  end; { case }
end;

function ChnToPY(Value: AnsiString): string;
var
  i, L: Integer;
  c: array [0 .. 1] of AnsiChar;
  R: AnsiChar;
begin
  Result := '';
  L := Length(Value);
  i := 1;
  while i <= (L - 1) do
  begin
    if Value[i] < #160 then
    begin
      Result := Result + Value[i];
      Inc(i);
    end
    else
    begin
      c[0] := Value[i];
      c[1] := Value[i + 1];
      R := ChnPy(c);
      if R <> #0 then
        Result := Result + R;
      Inc(i, 2);
    end;
  end;
  if i = L then
    Result := Result + Value[L];
end;

function GetPYIndexString(ChString: AnsiString): String;
var
  i: Integer;
begin // 根据一个汉字字符串取得拼音字头，不对汉字字符串做校验
  Result := '';
  if ChString = '' then
    Result := '';

  i := 1;
  while i <= Length(ChString) do
  begin
    case Word(ChString[i]) shl 8 + Word(ChString[i + 1]) of
      $B0A1 .. $B0C4:
        Result := Result + 'A';
      $B0C5 .. $B2C0:
        Result := Result + 'B';
      $B2C1 .. $B4ED:
        Result := Result + 'C';
      $B4EE .. $B6E9:
        Result := Result + 'D';
      $B6EA .. $B7A1:
        Result := Result + 'E';
      $B7A2 .. $B8C0:
        Result := Result + 'F';
      $B8C1 .. $B9FD:
        Result := Result + 'G';
      $B9FE .. $BBF6:
        Result := Result + 'H';
      $BBF7 .. $BFA5:
        Result := Result + 'J';
      $BFA6 .. $C0AB:
        Result := Result + 'K';
      $C0AC .. $C2E7:
        Result := Result + 'L';
      $C2E8 .. $C4C2:
        Result := Result + 'M';
      $C4C3 .. $C5B5:
        Result := Result + 'N';
      $C5B6 .. $C5BD:
        Result := Result + 'O';
      $C5BE .. $C6D9:
        Result := Result + 'P';
      $C6DA .. $C8BA:
        Result := Result + 'Q';
      $C8BB .. $C8F5:
        Result := Result + 'R';
      $C8F6 .. $CBF9:
        Result := Result + 'S';
      $CBFA .. $CDD9:
        Result := Result + 'T';
      $CDDA .. $CEF3:
        Result := Result + 'W';
      $CEF4 .. $D188:
        Result := Result + 'X';
      $D1B9 .. $D4D0:
        Result := Result + 'Y';
      $D4D1 .. $D7F9:
        Result := Result + 'Z';
    else
      begin
        Result := Result + ChString[i];
        Inc(i, -1);
      end;
    end;

    Inc(i, 2);
  end;
end;

function GetDomainFromURL(AURL: String): String;
var
  iIndex: Integer;
begin
  Result := LowerCase(AURL).Replace('\', '/');
  if Result.StartsWith('http://') then
    Delete(Result,1, Length('http://'));
  if Result.StartsWith('https://') then
    Delete(Result,1, Length('https://'));

  try
    iIndex := Result.IndexOf('/');
    if iIndex > 1 then
      Delete(Result, iIndex + 1, Length(Result) - iIndex);
  except
  end;
end;

function GetFreeDiskSize(ADisk: String): Int64;
var
  total_space: string;
  freeavailable, TotalSpace, totalfree: Int64;
begin
  Result := -1;
  if getDrivetype(PChar(ADisk)) = DRIVE_FIXED then
  begin
    if GetDiskFreeSpaceEx(PChar(ADisk), freeavailable, TotalSpace, @totalfree)
    then
    begin
      total_space := floattostr(TotalSpace div (1024 * 1024)) + 'MB';
      Result := totalfree;
    end;
  end;
end;

function GetDiskSize(ADisk: String): Int64;
var
  freeavailable, TotalSpace, totalfree: Int64;
begin
  Result := -1;
  if getDrivetype(PChar(ADisk)) = DRIVE_FIXED then
  begin
    if GetDiskFreeSpaceEx(PChar(ADisk), freeavailable, TotalSpace, @totalfree)
    then
    begin
      Result := TotalSpace;
    end;
  end;
end;

// ------------------------------------------------------------------------------
function GetDirectorySize(Path: String): Integer;
var
  SR: TSearchRec;
begin
  Result := 0;
  if FindFirst(Path + '*.*', faAnyFile, SR) = 0 then
  begin
    if (SR.Name <> '.') and (SR.Name <> '..') and (SR.Attr = faDirectory) then
      Result := Result + GetDirectorySize(Path + SR.Name + '\')
    else
      Result := Result + SR.Size;
    while FindNext(SR) = 0 do
      if (SR.Name <> '.') and (SR.Name <> '..') and (SR.Attr = faDirectory) then
        Result := Result + GetDirectorySize(Path + SR.Name + '\')
      else
        Result := Result + SR.Size;
    FindClose(SR);
  end;
end;

procedure DeleteDirectoryTree(APath: String);
var
  SR: TSearchRec;
begin
  if FindFirst(APath + '*.*', faAnyFile, SR) = 0 then
  begin
    if (SR.Name <> '.') and (SR.Name <> '..') and (SR.Attr = faDirectory) then
    begin
      DeleteDirectoryTree(APath + SR.Name + '\');
      RemoveDirectory(PChar(APath + SR.Name));
    end
    else
      DeleteFile(APath + SR.Name);

    while FindNext(SR) = 0 do
    begin
      if (SR.Name <> '.') and (SR.Name <> '..') and (SR.Attr = faDirectory) then
      begin
        DeleteDirectoryTree(APath + SR.Name + '\');
        // RemoveDirectory(PChar(APath + SR.Name));
      end
      else
        DeleteFile(APath + SR.Name);
    end;
    FindClose(SR);
  end;
  RemoveDirectory(PChar(APath));
end;

procedure CopyDirectory(SrcPath, DstPath: String);
var
  SR: TSearchRec;
begin
  if not DirectoryExists(DstPath) then
    CreateDir(DstPath);

  if FindFirst(SrcPath + '*.*', faAnyFile, SR) = 0 then
  begin
    if (SR.Name <> '.') and (SR.Name <> '..') and (SR.Attr = faDirectory) then
      CopyDirectory(SrcPath + SR.Name + '\', DstPath + SR.Name + '\')
    else if (SR.Name <> '.') and (SR.Name <> '..') then
    begin
      CopyFile(PChar(SrcPath + SR.Name), PChar(DstPath + SR.Name), False);
    end;

    while FindNext(SR) = 0 do
    begin
      if (SR.Name <> '.') and (SR.Name <> '..') and (SR.Attr = faDirectory) then
        CopyDirectory(SrcPath + SR.Name + '\', DstPath + SR.Name + '\')
      else
      begin
        if (SR.Name <> '.') and (SR.Name <> '..') then
          CopyFile(PChar(SrcPath + SR.Name), PChar(DstPath + SR.Name), False);
      end;
    end;
    FindClose(SR);
  end;
end;

function TestOpenFileForWrite(AFilename: String): Boolean;
var
  FileHandle: Integer;
begin
  Result := True;
  if not FileExists(AFilename) then
    Exit;

  FileHandle := FileOpen(AFilename, fmOpenWrite or fmShareDenyWrite);
  if FileHandle = -1 then
    Result := False
  else
    FileClose(FileHandle);
end;

// ------------------------------------------------------------------------------
function GetFileLength(AFilename: String; ADenyWrite: Boolean): Int64;
var
  FileHandle: Integer;
begin
  try
    if not FileExists(AFilename) then
    begin
      Result := -2;
    end
    else
    begin
      if ADenyWrite then
        FileHandle := FileOpen(AFilename, fmOpenRead or fmShareDenyWrite)
      else
        FileHandle := FileOpen(AFilename, fmOpenRead or fmShareDenyNone);
      if FileHandle = -1 then
      begin
        Result := -1;
      end
      else
      begin
        try
          Result := WinApi.Windows.GetFileSize(FileHandle, nil);
        finally
          FileClose(FileHandle);
        end;
      end;
    end;
  except
    Result := -1;
  end;
end;

{ 删除文件夹中的文件 }
// ------------------------------------------------------------------------------
procedure DeleteFilesOfDir(const Path, Files: string);
var
  DirName: string;
  FileOp: TSHFILEOPSTRUCT;
begin
  DirName := Path + Files + #0;
  with FileOp do
  begin
    wnd := 0;
    wFunc := FO_DELETE;
    pFrom := PChar(DirName);
    pTo := nil;
    fFlags := FOF_Silent + FOF_NOCONFIRMATION;
    fAnyOperationsAborted := False;
    hNameMappings := nil;
    lpszProgressTitle := nil
  end;
  SHFileOperation(FileOp);
end;

function GetHTTPLocalPath: String;
begin
  Result := ReplaceText(ExtractFilePath(Application.ExeName), '\', '/');
end;

function OpenSpecialFolder(Flag: Integer; Handle: hwnd = 0): Boolean;
// 这里的Flag就是我们需要打开的文件夹的CSIDL值
  Procedure FreePidl(pidl: PItemIDList); // 释放掉PItemIDList实例
  var
    allocator: IMalloc;
  begin
    CoInitialize(nil);
    try
      if Succeeded(WinApi.ShlObj.SHGetMalloc(allocator)) then
      begin
        allocator.Free(pidl);
        {$IFDEF VER90}
        allocator.Release;
        {$ENDIF}
      end;
    finally
      CoUninitialize;
    end;
  end;

var
  exInfo: TShellExecuteInfo;
begin
  FillChar(exInfo, SizeOf(exInfo), 0); // 给exInfo设置初始值
  with exInfo do
  begin
    cbSize := SizeOf(exInfo);
    fMask := SEE_MASK_FLAG_DDEWAIT or SEE_MASK_IDLIST;
    wnd := Handle;
    nShow := SW_SHOWNORMAL;
    lpVerb := 'open';
    SHGetSpecialFolderLocation(Handle, Flag, PItemIDList(lpIDList));
    // 定位到由CSIDL值指定的文件夹
  end;
  ShellExecuteEx(@exInfo); // 打开文件夹
  FreePidl(exInfo.lpIDList);
end;

function GetSpecialFolderPIDL(const folderid: Integer): PItemIDList;
var
  pidl: PItemIDList;
begin
  SHGetSpecialFolderLocation(Application.Handle, folderid, pidl);
  Result := pidl;
end;

function ReplaceSystemReplaceID(AFile: string): string;
begin
  Result := AFile;
  Result := ReplaceText(Result, '%windir%', GetSpecialFolderDir(CSIDL_WINDOWS));
  Result := ReplaceText(Result, '%SystemRoot%',
    GetSpecialFolderDir(CSIDL_WINDOWS));
  Result := ReplaceText(Result, '%ProgramFiles%',
    GetSpecialFolderDir(CSIDL_PROGRAM_FILES));
  Result := ReplaceText(Result, '%CommonProgramFiles%',
    GetSpecialFolderDir(CSIDL_PROGRAM_FILES_COMMON));
  Result := ReplaceText(Result, '%APPDATA%',
    GetSpecialFolderDir(CSIDL_APPDATA));

  Result := ReplaceText(Result, '\\', '\');
end;

function GetSpecialFolderDir(const folderid: Integer): string;
var
  pidl: PItemIDList;
  buffer: array [0 .. 255] of Char;
begin
  SHGetSpecialFolderLocation(Application.Handle, folderid, pidl);
  SHGetPathFromIDList(pidl, buffer);
  PidlFree(pidl);
  Result := StrPas(buffer) + '\';
end;

function CheckTrashEmplty: Boolean;
var
  rbinfo: SHQUERYRBINFO;
  drives: set of 0 .. 25;
  drive: Integer;
  wstr: WideString;
begin
  try
    Result := True;
    DWord(drives) := WinApi.Windows.GetLogicalDrives;
    for drive := 2 to 25 do
    begin
      if drive in drives then
      begin
        wstr := Chr(drive + Ord('A')) + ':';
        rbinfo.cbSize := SizeOf(rbinfo);
        rbinfo.i64NumItems := 0;
        rbinfo.i64Size := 0;
        SHQueryRecycleBinW(PChar(String(wstr)), @rbinfo);
        if rbinfo.i64NumItems > 0 then
        begin
          Result := False;
          Exit;
        end;
      end;
    end;
  except
  end;
end;

{$REGION 'TGetMD5Thread'}

procedure TGetMD5Thread.Execute;
var
  AFileStream: TFileStream;
  AResult: TMD5Digest;
begin
  FResult := '';
  FreeOnTerminate := True;
  DoThreadBegin;
  try
    AFileStream := TFileStream.Create(FFile, fmOpenRead or fmShareDenyWrite);
    EnterCriticalSection(FMD5Section);
    try
      if AFileStream.Size = 0 then
        FResult := BlankFileMD5
      else
      begin
        FResult := '';
        FillChar(AResult, SizeOf(TMD5Digest), 0);
        if CnMD5.InternalMD5Stream(AFileStream, 1024 * 1024, AResult,
          MD5CalcProgressFunc) then
        begin
          if not FCanceled then
            FResult := CnMD5.MD5Print(AResult);
        end;
      end;
    finally
      LeaveCriticalSection(FMD5Section);
      FreeAndNil(AFileStream);
    end;
  except
    On E: Exception do
    begin
      FExpMessage := E.Message;
      FResult := '';
    end;
  end;
end;

procedure TGetMD5Thread.DoThreadBegin;
begin
  if Assigned(FOnThreadBegin) then
    FOnThreadBegin(Self);
end;

procedure TGetMD5Thread.DoProgress(ATotal, AProgress: Int64);
begin
  if Assigned(FOnProgress) then
    FOnProgress(Self, ATotal, AProgress);
end;

procedure TGetMD5Thread.MD5CalcProgressFunc(ATotal, AProgress: Int64;
  var Cancel: Boolean);
begin
  Cancel := FCanceled;
  FTotal := ATotal;
  FProgress := AProgress;
  DoProgress(FTotal, FProgress);
end;

constructor TGetMD5Thread.Create(AFile: String);
begin
  FExpMessage := '';
  FResult := '';
  FCanceled := False;
  FFile := AFile;
  inherited Create(True);
end;

procedure TGetMD5Thread.Cancel;
begin
  FCanceled := True;
end;

procedure TGetMD5Thread.OnEnd;
var
  iIndex: Integer;
  ANeedPopMission: Boolean;
begin
  if not FCanceled then
  begin
    FResult := '';
  end;
end;

destructor TGetMD5Thread.Destroy;
begin
  try
    Synchronize(OnEnd);
  finally
    inherited Destroy;
  end;
end;
{$ENDREGION}
{$REGION 'TJIN_TickCount'}

constructor TJIN_TickCount.Create;
begin

end;

destructor TJIN_TickCount.Destroy;
begin
  inherited Destroy;
end;

procedure TJIN_TickCount.BeginGetMillisecond;
begin
  QueryPerformanceFrequency(FFrequency);
  QueryPerformanceCounter(FStartTick);
end;

function TJIN_TickCount.GetMillisecond: Extended;
begin
  QueryPerformanceCounter(FEndTick);
  Result := ((FEndTick - FStartTick) / FFrequency) * 1000;
end;

function TJIN_TickCount.GetStepValue(ATotalMillisecond, ATotalSpace: Integer;
  AMinStepTime: Integer = 5): Extended;
begin
  Result := Round(ATotalSpace / (ATotalMillisecond / GetMillisecond));
  if Result > ATotalSpace / AMinStepTime then
    Result := ATotalSpace / AMinStepTime;
  if Result < 1 then
    Result := 1;
end;

procedure TJIN_TickCount.Wait(ATotalMillisecond, ATotalSpace,
  AStepValue: Extended; ASleep: Boolean = False);
begin
  if ATotalSpace = 0 then
    Exit;

  while GetMillisecond < ATotalMillisecond / (ATotalSpace / AStepValue) do
  begin
    if ASleep then
    begin
      Sleep(1);
    end;
  end;
end;
{$ENDREGION}
{$REGION 'TRegNotifyChangeThread'}

procedure TRegNotifyChangeThread.DoChanged;
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self);
end;

procedure TRegNotifyChangeThread.StopWatch;
begin
  FOnChanged := nil;
  if not Terminated then
    Terminate;
  SetEvent(FNotifyEvent);
end;

procedure TRegNotifyChangeThread.Execute;
var
  dwRes: DWord;
begin
  while not Terminated do
  begin
    FNotifyEvent := CreateEvent(nil, False, True,
      PChar('RegistryNotify' + IntToStr(GetTickCount)));
    RegNotifyChangeKeyValue(FHKey, True, REG_NOTIFY_CHANGE_NAME or
      REG_NOTIFY_CHANGE_LAST_SET, FNotifyEvent, True);
    dwRes := WaitForSingleObject(FNotifyEvent, INFINITE); // 监视一分钟
    if dwRes = 0 then
    begin
      Synchronize(DoChanged);
    end;
    CloseHandle(FNotifyEvent);
    FNotifyEvent := 0;
  end;
end;

constructor TRegNotifyChangeThread.Create(ARootKey: HKEY; AKey: String);
begin
  FRootKey := ARootKey;
  FKey := AKey;
  RegOpenKeyEx(FRootKey, PChar(FKey), KEY_READ, KEY_NOTIFY, FHKey);
  inherited Create(True);
end;

destructor TRegNotifyChangeThread.Destroy;
begin
  if FNotifyEvent <> 0 then
    CloseHandle(FNotifyEvent);
  RegCloseKey(FHKey);
  inherited Destroy;
end;
{$ENDREGION}
{$REGION 'TOpenURLThread'}

function TOpenURLThread.Regkey(Key: HKEY; Subkey: string;
  var Data: string): Longint;
var
  H: HKEY;
  tData: array [0 .. 259] of Char;
  dSize: Integer;
begin
  Result := RegOpenKeyEx(Key, PChar(Subkey), 0, KEY_QUERY_VALUE, H);
  if Result = ERROR_SUCCESS then
  begin
    dSize := SizeOf(tData);
    RegQueryValue(H, nil, tData, dSize);
    Data := StrPas(tData);
    RegCloseKey(H);
  end;
end;

procedure TOpenURLThread.OpenURL(URL: String);
var
  P: Integer;
  Key, urlstr: string;
  IEDirectory: string;
begin

  IEDirectory := GetSpecialFolderDir(CSIDL_PROGRAM_FILES);
  IEDirectory := IEDirectory + 'Internet Explorer\';

  if Regkey(HKEY_CLASSES_ROOT, '.htm', Key) = ERROR_SUCCESS then
  begin
    Key := Key + '\shell\open\command';
    if Regkey(HKEY_CLASSES_ROOT, Key, Key) = ERROR_SUCCESS then
    begin
      P := Pos('"%1"', Key);
      if P = 0 then
        P := Pos('%1', Key);
      if P <> 0 then
        SetLength(Key, P - 1);
      urlstr := Key + ' ' + URL;

      if WinExec(pansichar(AnsiString(urlstr)), SW_SHOWNORMAL) < 32 then
      begin
        ShellExecute(Handle, 'open', PChar(IEDirectory + 'iexplore.exe'),
          PChar(FURL), '', SW_SHOWNORMAL);
      end;
    end
    else
    begin
      ShellExecute(Handle, 'open', PChar(IEDirectory + 'iexplore.exe'),
        PChar(FURL), '', SW_SHOWNORMAL);
    end;
  end
  else
  begin
    ShellExecute(Handle, 'open', PChar(IEDirectory + 'iexplore.exe'),
      PChar(FURL), '', SW_SHOWNORMAL);
  end;
end;

procedure TOpenURLThread.Execute;
begin
  //OpenURL(FURL);
  //ShellExecute(handle, 'open', pchar(FURL), PChar(''),'',SW_SHOWNORMAL);
end;

constructor TOpenURLThread.Create(AURL: String);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FURL := AURL;
  //ShellExecute(handle, 'open', pchar(FURL), PChar(''),'',SW_SHOWNORMAL);
  ShellExecute(0, nil, PChar('"' + FURL + '"'),
        PChar(''),
        PChar(ExtractFilePath('')),
        SW_SHOWNORMAL);
end;

destructor TOpenURLThread.Destroy;
begin
  inherited Destroy;
end;
{$ENDREGION}
{$REGION 'TOpenImageThread'}

procedure TOpenImageThread.Execute;
begin
  ShellExecute(0, 'Open', 'rundll32.exe',
    PChar('c:\WINDOWS\system32\shimgvw.dll, ImageView_Fullscreen ' +
    FImageFileName + ''), nil, sw_show);
end;

constructor TOpenImageThread.Create(AImageFileName: String);
begin
  inherited Create(False);
  FreeOnTerminate := True;
  FImageFileName := AImageFileName;
end;

destructor TOpenImageThread.Destroy;
begin
  inherited Destroy;
end;
{$ENDREGION}
{$REGION 'TSFastRLE'}

type
  LongType = record
    case Word of
      0:
        (PTR: Pointer);
      1:
        (Long: Longint);
      2:
        (lo: Word;
          hi: Word);
  end;

constructor TSFastRLE.Create;
begin
  inherited;
  GetMem(s, $FFFF);
  GetMem(t, $FFFF);
end;

destructor TSFastRLE.Destroy;
begin
  FreeMem(t);
  FreeMem(s);
  inherited;
end;

function TSFastRLE.PackSeg(Source, Target: Pointer; SourceSize: Word): Word;
begin
  asm
    push    esi
    push    edi
    push    eax
    push    ebx
    push    ecx
    push    edx

    cld
    xor     ecx, ecx
    mov	cx, SourceSize
    mov	edi, Target

    mov	esi, Source
    add	esi, ecx
    dec	esi
    lodsb
    inc	eax
    mov	[esi], al

    mov	ebx, edi
    add     ebx, ecx
    inc	ebx
    mov	esi, Source
    add     ecx, esi
    add	edi, 2
  @CyclePack:
    cmp	ecx, esi
    je	@Konec
    lodsw
    stosb
    dec	esi
    cmp	al, ah
    jne	@CyclePack
    cmp	ax, [esi+1]
    jne	@CyclePack
    cmp	al, [esi+3]
    jne	@CyclePack
    sub	ebx, 2
    push    edi
    sub     edi, Target
    mov	[ebx], di
    pop     edi
    mov	edx, esi
    add	esi, 3
  @Nimnul:
    inc	esi
    cmp	al, [esi]
    je	@Nimnul
    mov	eax, esi
    sub	eax, edx
    or	ah, ah
    jz	@M256
    mov	byte ptr [edi], 0
    inc	edi
    stosw
    jmp     @CyclePack
  @M256:
    stosb
    jmp     @CyclePack
  @Konec:
    push    ebx
    mov     ebx, Target
    mov     eax, edi
    sub     eax, ebx
    mov	[ebx], ax
    pop     ebx
    inc	ecx
    cmp	ebx, ecx
    je	@Lock1
    mov	esi, ebx
    sub     ebx, Target
    sub     ecx, Source
    sub	ecx, ebx
    rep	movsb
  @Lock1:
    sub     edi, Target
    mov	Result, di

    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    pop     edi
    pop     esi
  end;
end;

function TSFastRLE.UnPackSeg(Source, Target: Pointer; SourceSize: Word): Word;
begin
  asm
    push    esi
    push    edi
    push    eax
    push    ebx
    push    ecx
    push    edx
    cld
    mov	esi, Source
    mov	edi, Target
    mov     ebx, esi
    xor     edx, edx
    mov     dx, SourceSize
    add	ebx, edx
    mov	dx, word ptr [esi]
    add     edx, esi
    add	esi, 2
  @UnPackCycle:
    cmp	edx, ebx
    je	@Konec2
    sub	ebx, 2
    xor     ecx, ecx
    mov	cx, word ptr [ebx]
    add     ecx, Source
    sub	ecx, esi
    dec	ecx
    rep	movsb
    lodsb
    mov	cl, byte ptr [esi]
    inc	esi
    or	cl, cl
    jnz	@Low1
    xor     ecx, ecx
    mov	cx, word ptr [esi]
    add	esi, 2
  @Low1:
    inc	ecx
    rep	stosb
    jmp     @UnPackCycle
  @Konec2:
    mov	ecx, edx
    sub	ecx, esi
    rep	movsb
    sub     edi, Target
    mov     Result, di

    pop     edx
    pop     ecx
    pop     ebx
    pop     eax
    pop     edi
    pop     esi
  end;
end;

function TSFastRLE.Pack(Source, Target: Pointer; SourceSize: Integer): Longint;
var
  W, tmp: Word;
  Sourc, Targ: LongType;
begin
  // Move
  // Move(Source^, Target^, SourceSize);
  // Result:= SourceSize;
  // Exit;

  // RLE Compress
  Sourc.PTR := Source;
  Targ.PTR := Target;
  Result := 0;
  while SourceSize <> 0 do
  begin
    if SourceSize > $FFFA then
      tmp := $FFFA
    else
      tmp := SourceSize;
    Dec(SourceSize, tmp);
    Move(Sourc.PTR^, s^, tmp);
    W := PackSeg(s, t, tmp);
    Inc(Sourc.Long, tmp);
    Move(W, Targ.PTR^, 2);
    Inc(Targ.Long, 2);
    Move(t^, Targ.PTR^, W);
    Inc(Targ.Long, W);
    Result := Result + W + 2;
  end;
end;

function TSFastRLE.UnPack(Source, Target: Pointer; SourceSize: Integer)
  : Longint;
var
  Increment, i: Longint;
  tmp: Word;
  Swap: LongType;
begin
  // Move
  // Move(Source^, Target^, SourceSize);
  // Result:= SourceSize;
  // Exit;

  // RLE Decompress
  Increment := 0;
  Result := 0;
  while SourceSize <> 0 do
  begin
    Swap.PTR := Source;
    Inc(Swap.Long, Increment);
    Move(Swap.PTR^, tmp, 2);
    Inc(Swap.Long, 2);
    Dec(SourceSize, tmp + 2);
    i := UnPackSeg(Swap.PTR, t, tmp);
    Swap.PTR := Target;
    Inc(Swap.Long, Result);
    Inc(Result, i);
    Move(t^, Swap.PTR^, i);
    Inc(Increment, tmp + 2);
  end;
end;

function TSFastRLE.PackFile(SourceFileName, TargetFileName: String): Boolean;
var
  Source, Target: Pointer;
  SourceFile, TargetFile: File;
  RequiredMaxSize, TargetFSize, FSize: Longint;
begin
  AssignFile(SourceFile, SourceFileName);
  reset(SourceFile, 1);
  FSize := FileSize(SourceFile);

  RequiredMaxSize := FSize + (FSize div $FFFF + 1) * 2;
  GetMem(Source, RequiredMaxSize);
  GetMem(Target, RequiredMaxSize);

  BlockRead(SourceFile, Source^, FSize);
  CloseFile(SourceFile);

  TargetFSize := Pack(Source, Target, FSize);

  AssignFile(TargetFile, TargetFileName);
  Rewrite(TargetFile, 1);
  { Also, you may put header }
  BlockWrite(TargetFile, FSize, SizeOf(FSize));
  { Original file size (Only from 3.0) }
  BlockWrite(TargetFile, Target^, TargetFSize);
  CloseFile(TargetFile);

  FreeMem(Target, RequiredMaxSize);
  FreeMem(Source, RequiredMaxSize);

  Result := IOResult = 0;
end;

function TSFastRLE.PackString(Source: AnsiString): AnsiString;
var
  PC, PC2: pansichar;
  ss, TS: Integer;
begin
  ss := ByteLength(Source);
  GetMem(PC, ss);
  GetMem(PC2, ss + 8); // If line can't be packed its size can be longer
  Move(Source[1], PC^, ss);
  TS := Pack(PC, PC2, ss);
  SetLength(Result, TS + 4);
  Move(ss, Result[1], 4);
  Move(PC2^, Result[5], TS);
  FreeMem(PC2);
  FreeMem(PC);
end;

function TSFastRLE.UnPackFile(SourceFileName, TargetFileName: String): Boolean;
var
  Source, Target: Pointer;
  SourceFile, TargetFile: File;
  OriginalFileSize, FSize: Longint;
begin
  AssignFile(SourceFile, SourceFileName);
  reset(SourceFile, 1);
  FSize := FileSize(SourceFile) - SizeOf(OriginalFileSize);

  { Read header ? }
  BlockRead(SourceFile, OriginalFileSize, SizeOf(OriginalFileSize));

  GetMem(Source, FSize);
  GetMem(Target, OriginalFileSize);

  BlockRead(SourceFile, Source^, FSize);
  CloseFile(SourceFile);

  UnPack(Source, Target, FSize);

  AssignFile(TargetFile, TargetFileName);
  Rewrite(TargetFile, 1);
  BlockWrite(TargetFile, Target^, OriginalFileSize);
  CloseFile(TargetFile);

  FreeMem(Target, OriginalFileSize);
  FreeMem(Source, FSize);

  Result := IOResult = 0;
end;

function TSFastRLE.UnPackString(Source: AnsiString): AnsiString;
var
  PC, PC2: pansichar;
  ss, TS: Integer;
begin
  ss := ByteLength(Source) - 4;
  GetMem(PC, ss);
  Move(Source[1], TS, 4);
  GetMem(PC2, TS);
  Move(Source[5], PC^, ss);
  TS := UnPack(PC, PC2, ss);
  SetLength(Result, TS);
  Move(PC2^, Result[1], TS);
  FreeMem(PC2);
  FreeMem(PC);
end;
{$ENDREGION 'TSFastRLE'}

procedure AddTipTool(hwnd: DWord; pt: TPoint; IconType: Integer;
  Title, Text: PChar);
const
  TTS_BALLOON = $0040;
  TTM_SETTITLE = WM_USER + 32;
var
  hWndTip: DWord;
  ToolInfo: TToolInfo;
begin
  hWndTip := CreateWindow(TOOLTIPS_CLASS, nil, WS_POPUP or TTS_NOPREFIX or
    TTS_BALLOON or TTS_ALWAYSTIP, pt.X, pt.Y, 0, 0, hwnd, 0, HInstance, nil);
  if (hWndTip <> 0) then
  begin
    ToolInfo.cbSize := SizeOf(ToolInfo);
    ToolInfo.uFlags := TTF_IDISHWND or TTF_SUBCLASS or TTF_TRANSPARENT;
    ToolInfo.uId := hwnd;
    ToolInfo.lpszText := Text;
    SendMessage(hWndTip, TTM_ADDTOOL, 0, Integer(@ToolInfo));
    SendMessage(hWndTip, TTM_SETTIPBKCOLOR, $EBEBEB, 0); // 设置背景色
    SendMessage(hWndTip, TTM_SETTIPTEXTCOLOR, $808080, 0); // 设置字体颜色
    SendMessage(hWndTip, TTM_SETTITLE, 1, Integer(Title));
  end;
  InitCommonControls();
end;

procedure THintWin.ShowHint(hwnd: Cardinal; pt: TPoint; Const AHint: string);
begin
  if FLastActive <> hwnd then
    AddTipTool(hwnd, pt, 1, '', PChar(AHint));
  FLastActive := hwnd;
end;

initialization

IsVista := CheckWin32Version(6, 0);
Is64Bit := IsWin64;
InitializeCriticalSection(FSection);
InitializeCriticalSection(FMD5Section);
InitializeCriticalSection(FLogSection);


finalization

DeleteCriticalSection(FLogSection);
DeleteCriticalSection(FMD5Section);
DeleteCriticalSection(FSection);

end.
