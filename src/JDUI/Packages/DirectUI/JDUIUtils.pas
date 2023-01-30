{
================================================================================
* 项目名称：DirectUI控件
* 单元名称：DirectUI公共类型方法库
* 单元作者：尹进 supersoho@163.com 32702924@qq.com
* 备    注：
* 修改记录：2013.04.05 V1.0 创建单元
================================================================================
}

unit JDUIUtils;

interface

uses
  jinTextDraw,
  System.Win.Registry,
  System.Win.ComObj,
  Variants,
  JDUIFonts,
  GR32,
  GR32_Math,
  GR32_Image,
  GR32_Layers,
  GR32_Transforms,
  GR32_Resamplers,
  GR32_Backends,
  GR32_Polygons,
  GR32_Blend,
  Imaging,
  ImagingClasses,
  ImagingTypes,
  ImagingComponents,
  Generics.Collections,
  Vcl.Dialogs,
  WinApi.Windows,
  Classes,
  EncdDecd,
  Math,
  WinApi.ShlObj,
  SysUtils,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Graphics,
  Vcl.Imaging.jpeg,
  Vcl.Forms,
  WinApi.ShellApi,
  IOUtils,
  StrUtils,
  WinApi.ActiveX,
  GdipTypes,
  GdiPlus,
  Vcl.Imaging.pngimage,
  Vcl.Imaging.GIFImg,
  PerlRegEx,
  pngimage2,
  ImageData,
  Base64,
  Jin_GDIEffects,
  jinUtils,
  System.Types,
  FreeType;

const
  MinNumberOfProcessors = 1;
type
  NET_API_STATUS = DWORD;


  _SERVER_INFO_101 = record
    sv101_platform_id: DWORD;
    sv101_name: LPWSTR;
    sv101_version_major: DWORD;
    sv101_version_minor: DWORD;
    sv101_type: DWORD;
    sv101_comment: LPWSTR;
  end;
  SERVER_INFO_101 = _SERVER_INFO_101;
  PSERVER_INFO_101 = ^SERVER_INFO_101;
  LPSERVER_INFO_101 = PSERVER_INFO_101;


const
  MAJOR_VERSION_MASK = $0F;


function NetServerGetInfo(servername: LPWSTR; level: DWORD; var bufptr): NET_API_STATUS; stdcall; external 'Netapi32.dll' Delayed;
function NetApiBufferFree(Buffer: Pointer): NET_API_STATUS; stdcall; external 'Netapi32.dll' Delayed;

type
  pfnRtlGetVersion = function(var RTL_OSVERSIONINFOEXW): LongInt; stdcall;

type
  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array[0..2560 - 1] of TRGBTriple;

  TjinGIFImage = class
  private
    FGIF: TMultiImage;
    FBitmap: TBitmap32;
    FBitmaps: TList<TBitmap32>;
    FDelayTimes: TList<Integer>;
    FWidth,
    FHeight: Integer;
    function GetCount: Integer;
    function GetBitmapByIndex(AIndex: Integer): TBitmap32;
    function GetDelayByIndex(AIndex: Integer): Integer;
    function GetTotalDelayByIndex(AIndex: Integer): Integer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;

    procedure LoadFromFile(AFile: String);
    procedure LoadFromGIFImage(AGIFImage: TGIFImage);

    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property Count: Integer read GetCount;
    property Bitmap[AIndex: Integer]: TBitmap32 read GetBitmapByIndex;
    property Delay[AIndex: Integer]: Integer read GetDelayByIndex;
    property TotalDelay[AIndex: Integer]: Integer read GetTotalDelayByIndex;
  end;

  TPixelCombine = class
    class procedure PixelCombine(S: GR32.TColor32; var D: GR32.TColor32; M: GR32.TColor32);
  end;

  procedure ColorHSLtoRGB(H, S, L: Double; var R, G, B: Integer);
  procedure ColorRGBtoHSL(R, G, B: Integer; var H, S, L: Double);
  procedure ColorRGBtoHSL2(R, G, B: Integer; var H, S, L: Double);
  function GetBitmapColor(DestBitmap:TBitmap):TColor;
  procedure ConvertBitmap32Color(ABitmap32:TBitmap32; AColor:TColor);
  procedure ConvertBitmap32ColorFull(ABitmap32:TBitmap32; AColor:TColor);
  function GetBitmap32ByPngImage(APngImage: TPngImage; ABackColor: TColor32 = $00000000; ABitmap32: TBitmap32 = nil): TBitmap32;
  function GetBitmap32ByPngImage3(APngImage: TPngImage; ABackColor: TColor32 = $00000000; ABitmap32: TBitmap32 = nil): TBitmap32;
  procedure ResizeBitmap32(ABitmap32: TBitmap32; AWidth, AHeight: Integer; AHiQuality: Boolean; AMiddleQuality: Boolean = False);
  function GetPngFromBitmap(ABitmap32: TBitmap32; AWidth, AHeight: Integer; AHiQuality: Boolean): Vcl.Imaging.pngimage.TPngImage;
  function GetPng2FromBitmap(ABitmap32: TBitmap32; AWidth, AHeight: Integer; AHiQuality: Boolean): TPngImage;
  function GetPngFromBitmap32(ABitmap32: TBitmap32): pngimage2.TPngImage;
  procedure ReverseBitmap32(ABitmap32: TBitmap32);
  function GetPng2(APngImage: Vcl.Imaging.pngimage.TPngImage) : TPngImage;

  function BitmapToString(img:TBitmap):string ;
  function JpegToString(img:TJpegImage):string ;
  function PngToString(img: TPngImage):string ;
  function StreamToString(AStream: TStream):string ;
  procedure StringToStream(imgStr: string; ms: TStream);
  function FileToString(AFile: String):string;
  function StringToBitmap(imgStr:string):TBitmap;
  function StringToJpeg(imgStr:string):TJpegImage;
  function StringToPng(imgStr:string):TPngImage;

  function GetToken(var S: AnsiString; Separators: AnsiString; Stop: AnsiString = ''): AnsiString;

  function GetSpecialFolderDir(const folderid: Integer): string;
  function GetFileSize(AFileName: String): Int64;

  procedure ScaleRot(SrcBitmap, DstBitmap: TBitmap32; cx, cy, Alpha: Single; AHighQuaility: Boolean = False);
  procedure DottedRect(const bmp:TBitmap32; rect: TRect);
  function GetBitmapByPngAndBitmap(var APng: TPngImage; var ABitmap: TBitmap32; Designing: Boolean): TBitmap32; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
  procedure GetBitmapByPngAndBytes(var APng: TPngImage; var ABytes: PByte; var ASize: TSize; var AStoreBMP: TBitmap32; Designing: Boolean); {$IFDEF USEINLINING} inline; {$ENDIF}
  function GetBitsByPngAndBytes(var APng: TPngImage; var ABytes: PByte; var ASize: TSize; Designing: Boolean; ABackColor: TColor32 = $00000000): PByte; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
  function GetBitmap32ByFile(AFile: String; ABackColor: TColor32 = $00000000): TBitmap32;  {$IFDEF USEINLINING} inline; {$ENDIF}
  procedure CopyBitmap32Alpha(ASrcBitmap, ADstBitmap: GR32.TBitmap32);overload;
  procedure CopyBitmap32Alpha(ASrcBitmap, ADstBitmap: GR32.TBitmap32; ADstRect: TRect; ABackgroundMode: Boolean);overload;
  function GetGUID: String;
  function ForceForeGroundWindow(hwnd: THandle): boolean;
  function SetHTMLFormat(HTMLStr: UTF8String): UTF8String;
  function SetUnicodeHTMLFormat(HTMLStr: String): String;

  procedure CopyHTMLToClipBoard(const str: String; const hStr: String = '');
  procedure CopyHTMLToClipBoardUTF8(const str: String; const hStr: UTF8String = '');
  function GetHTMLUBBCode(AHTML: String; var ABaseURL: String): String;
  function StrHtmlEncode (const AStr: String): String;
  function StrHtmlDecode (const AStr: String): String;

  procedure GetFileExtIcon(AExt: String; AIcon: TIcon); overload;
  procedure GetFileExtIcon(AExt: String; AFile: String); overload;
  procedure GetFileExtPng(AExt: String; AFile: String);
  function MergeReg_ASM(src, dst: Cardinal): Cardinal;

  function GetFontBitmap(AFont: TFont): TBitmap32;
  function GetTextHeight(AFont: TFont): Integer;

  procedure GetWindowDPI;
  procedure SetFontSize(AFont: TFont);
  procedure RestoreFontSize(AFont: TFont);
  function GetDPISize(ASize: Integer; ADPI: Integer): Integer; overload; inline;
  function GetDPISize(ASize: Integer): Integer; overload; inline;
  function GetDesignSize(ASize: Integer): Integer; inline;
  function GetDPIScale: Single; inline;
  function Get2XImageFile(AFile: String): String;
  function GetCenterFormPosition(var AWidth, AHeight: Integer; AParent: TForm; UserDPISize: Boolean = True): TPoint;
  function WriteWebBrowserAppNameToReg(AppExeName: String): Boolean;

  procedure SaveUTFFile(const FileName: string; S: string; WriteHeader: Boolean = True);
  function LoadUTFFile(const FileName: string; ReadHeader: Boolean = True): string;

const
  DesignDPI = 96;
  TTFDPIScale = 1.25;

var
  TimeCriticalAnimate: Boolean;
  WindowDPI: Integer;
  AppQuiting: Boolean;
  NumberOfProcessors: Integer;
  EnableAnimate,
  EnableLayeredWindow,
  Win8,
  Win7,
  VistaUP: Boolean;
  Win10: Boolean;

  FontBitmaps: TDictionary<String, TBitmap32>;
  TextHeights: TDictionary<String, Integer>;

  m_nBaseLine: Integer;
  library_: FT_Library;
  Error_: FT_Error;
  face: FT_Face;

implementation

type
  TPngArray = array of TPngImage;

const
  EncodeTable: array[0..63] of AnsiChar =
    AnsiString('ABCDEFGHIJKLMNOPQRSTUVWXYZ') +
    AnsiString('abcdefghijklmnopqrstuvwxyz') +
    AnsiString('0123456789+/');

  DecodeTable: array[#0..#127] of Integer = (
    Byte('='), 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
           64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64,
           64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 64, 62, 64, 64, 64, 63,
           52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 64, 64, 64, 64, 64, 64,
           64,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
           15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 64, 64, 64, 64, 64,
           64, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
           41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 64, 64, 64, 64, 64);

type
  PPacket = ^TPacket;
  TPacket = packed record
    case Integer of
      0: (b0, b1, b2, b3: Byte);
      1: (i: Integer);
      2: (a: array[0..3] of Byte);
      3: (c: array[0..3] of AnsiChar);
  end;

function IsWin64: Boolean;
var
  Kernel32Handle: THandle;
  IsWow64Process: function(Handle: THandle; var Res: BOOL): BOOL; stdcall;
  GetNativeSystemInfo: procedure(var lpSystemInfo: TSystemInfo); stdcall;
  isWoW64: Bool;
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
    IsWOW64Process := GetProcAddress(Kernel32Handle,'IsWow64Process');
    GetNativeSystemInfo := GetProcAddress(Kernel32Handle,'GetNativeSystemInfo');
    if Assigned(IsWow64Process) then
    begin
      IsWow64Process(GetCurrentProcess,isWoW64);
      Result := isWoW64 and Assigned(GetNativeSystemInfo);
      if Result then
      begin
        GetNativeSystemInfo(SystemInfo);
        Result := (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64) or
                  (SystemInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_IA64);
      end;
    end
    else Result := False;
  end
  else Result := False;
end;

function WriteWebBrowserAppNameToReg(AppExeName: String): Boolean;
var
  reg :TRegistry;
  sPath,sAppName:String;
begin
  Result := True;
  reg := TRegistry.Create;
  try
    try
      reg.RootKey := HKEY_LOCAL_MACHINE;
      sPath := 'SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
      if isWin64 then sPath := 'SOFTWARE\Wow6432Node\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_BROWSER_EMULATION';
      if reg.OpenKey(sPath, True) then
      begin
        sAppName := AppExeName;
        if (not reg.ValueExists(sAppName)) or (reg.ReadInteger(sAppName) <> 11001) then
        begin
          reg.WriteInteger(sAppName, 11001);
        end;
      end;
      reg.CloseKey;
    except
      Result := False;
    end;
  finally
    FreeAndNil(reg);
  end;
end;

function GetCenterFormPosition(var AWidth, AHeight: Integer; AParent: TForm; UserDPISize: Boolean = True): TPoint;
var
  ARect: TRect;
  Monitor: TMonitor;
begin
  if UserDPISize then
  begin
    AWidth := GetDPISize(AWidth);
    AHeight := GetDPISize(AHeight);
  end;

  if AParent = nil then
  begin
    Monitor := Screen.MonitorFromWindow(Application.ActiveFormHandle);
    if Monitor = nil then Monitor := Screen.MonitorFromPoint(Mouse.CursorPos);
    ARect := Monitor.WorkareaRect;
  end
  else
  begin
    Monitor := AParent.Monitor;
    GetWindowRect(AParent.Handle, ARect);
  end;

  if AWidth > Monitor.WorkareaRect.Width - GetDPISize(10) then AWidth := Monitor.WorkareaRect.Width - GetDPISize(10);
  if AHeight > Monitor.WorkareaRect.Height - GetDPISize(10) then AHeight := Monitor.WorkareaRect.Height - GetDPISize(10);

  Result.X := ARect.Left + ((ARect.Right - ARect.Left) - AWidth) div 2;
  Result.Y := ARect.Top + ((ARect.Bottom - ARect.Top) - AHeight) div 2;

  if Result.X + AWidth > Monitor.Left + Monitor.Width then Result.X := Monitor.Left + Monitor.Width - AWidth;
  if Result.Y + AHeight > Monitor.Top + Monitor.Height then Result.Y := Monitor.Top + Monitor.Height - AHeight;
  if Result.X < 0 then Result.X := 0;
  if Result.Y < 0 then Result.Y := 0;
end;

{$O-}
class procedure TPixelCombine.PixelCombine(S: GR32.TColor32; var D: GR32.TColor32; M: GR32.TColor32);
begin
  try
    D := MergeReg_ASM(S, D);
  except
  end;
  //D := GR32_Blend.MergeReg(S, D);
end;

function MergeReg_ASM(src, dst: Cardinal): Cardinal;
begin
  asm
    mov eax,$FF000000 //Alpha mask
    mov ebx,$FFFFFFFF //255-Alpha mask

    pxor mm7,mm7
    movd mm5,eax
    movd mm6,ebx
    punpcklbw mm5,mm7 //mm5=alpha mask
    punpcklbw mm6,mm7 //mm6=(255-alpha) mask

    //Alpha Blend:
    movd mm0,src      //mm0=packed src
    punpcklbw mm0,mm7 //mm0=unpacked src
    movq mm2,mm0      //mm2=unpacked src
    punpckhwd mm0,mm0
    movd mm3,dst      //mm3=packed dst
    punpckhdq mm0,mm0 //mm0=unpacked src alpha bit
    movq mm1,mm6
    punpcklbw mm3,mm7 //mm3=dst

    psubb mm1,mm0     //mm1=255-src alpha bit
    paddusb mm0,mm5   //mm0=current unpacked src alpha bit
    pmullw mm2,mm0    //mm2=src*srcAlpha
    pmullw mm3,mm1    //mm3=dst*(255-srcAlpha)
    paddusw mm3,mm2   //mm3=src*srcAlpha+dst*(255-srcAlpha)
    psrlw mm3,8       //mm3=src*srcAlpha/256+dst*(255-srcAlpha)/256
    packuswb mm3,mm7  //mm3=packed dst
    movd dst, mm3
    emms
  end;
  Result := dst;
end;
{$O+}

procedure EncodePacket(const Packet: TPacket; NumChars: Integer; OutBuf: PAnsiChar);
begin
  OutBuf[0] := EnCodeTable[Packet.a[0] shr 2];
  OutBuf[1] := EnCodeTable[((Packet.a[0] shl 4) or (Packet.a[1] shr 4)) and $0000003f];
  if NumChars < 2 then
    OutBuf[2] := '='
  else OutBuf[2] := EnCodeTable[((Packet.a[1] shl 2) or (Packet.a[2] shr 6)) and $0000003f];
  if NumChars < 3 then
    OutBuf[3] := '='
  else OutBuf[3] := EnCodeTable[Packet.a[2] and $0000003f];
end;

function DecodePacket(InBuf: PAnsiChar; var nChars: Integer): TPacket;
begin
  Result.a[0] := (DecodeTable[InBuf[0]] shl 2) or
    (DecodeTable[InBuf[1]] shr 4);
  NChars := 1;
  if InBuf[2] <> '=' then
  begin
    Inc(NChars);
    Result.a[1] := Byte((DecodeTable[InBuf[1]] shl 4) or (DecodeTable[InBuf[2]] shr 2));
  end;
  if InBuf[3] <> '=' then
  begin
    Inc(NChars);
    Result.a[2] := Byte((DecodeTable[InBuf[2]] shl 6) or DecodeTable[InBuf[3]]);
  end;
end;

procedure EncodeStream(Input, Output: TStream);
type
  PInteger = ^Integer;
var
  InBuf: array[0..509] of Byte;
  OutBuf: array[0..1023] of AnsiChar;
  BufPtr: PAnsiChar;
  I, J, K, BytesRead: Integer;
  Packet: TPacket;
begin
  K := 0;
  repeat
    BytesRead := Input.Read(InBuf, SizeOf(InBuf));
    I := 0;
    BufPtr := OutBuf;
    while I < BytesRead do
    begin
      if BytesRead - I < 3 then
        J := BytesRead - I
      else J := 3;
      Packet.i := 0;
      Packet.b0 := InBuf[I];
      if J > 1 then
        Packet.b1 := InBuf[I + 1];
      if J > 2 then
        Packet.b2 := InBuf[I + 2];
      EncodePacket(Packet, J, BufPtr);
      Inc(I, 3);
      Inc(BufPtr, 4);
      Inc(K, 4);
      {if K > 75 then
      begin
        BufPtr[0] := #$0D;
        BufPtr[1] := #$0A;
        Inc(BufPtr, 2);
        K := 0;
      end; }
    end;
    Output.Write(Outbuf, BufPtr - PChar(@OutBuf));
  until BytesRead = 0;
end;

procedure DecodeStream(Input, Output: TStream);
var
  InBuf: array[0..75] of AnsiChar;
  OutBuf: array[0..60] of Byte;
  InBufPtr, OutBufPtr: PAnsiChar;
  I, J, K, BytesRead: Integer;
  Packet: TPacket;

  procedure SkipWhite;
  var
    C: AnsiChar;
    NumRead: Integer;
  begin
    while True do
    begin
      NumRead := Input.Read(C, 1);
      if NumRead = 1 then
      begin
        if C in ['0'..'9','A'..'Z','a'..'z','+','/','='] then
        begin
          Input.Position := Input.Position - 1;
          Break;
        end;
      end else Break;
    end;
  end;

  function ReadInput: Integer;
  var
    WhiteFound, EndReached : Boolean;
    CntRead, Idx, IdxEnd: Integer;
  begin
    IdxEnd:= 0;
    repeat
      WhiteFound := False;
      CntRead := Input.Read(InBuf[IdxEnd], (SizeOf(InBuf)-IdxEnd));
      EndReached := CntRead < (SizeOf(InBuf)-IdxEnd);
      Idx := IdxEnd;
      IdxEnd := CntRead + IdxEnd;
      while (Idx < IdxEnd) do
      begin
        if not (InBuf[Idx] in ['0'..'9','A'..'Z','a'..'z','+','/','=']) then
        begin
          Dec(IdxEnd);
          if Idx < IdxEnd then
            Move(InBuf[Idx+1], InBuf[Idx], IdxEnd-Idx);
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
    I := 0;
    while I < BytesRead do
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
      Inc(I, 4);
    end;
    Output.Write(OutBuf, OutBufPtr - PAnsiChar(@OutBuf));
  until BytesRead = 0;
end;

{$region 'RTTI'}
function GetToken(var S: AnsiString; Separators: AnsiString; Stop: AnsiString = ''): AnsiString;
var
  i, Len: integer;
  CopyS: AnsiString;
begin
  Result := '';
  CopyS := S;
  Len := Length(CopyS);
  for i := 1 to Len do
  begin
    if Pos(CopyS[i], Stop) > 0 then
      Break;
    Delete(S, 1, 1);
    if Pos(CopyS[i], Separators) > 0 then
    begin
      Result := Result;
      Break;
    end;
    Result := Result + CopyS[i];
  end;
  Result := Trim(Result);
  S := Trim(S);
end;
{$endregion}


// UTF-8文件写入函数
procedure SaveUTFFile(const FileName: string; S: string; WriteHeader: Boolean = True);
var
  MemStream: TMemoryStream;
  Content, HeaderStr: UTF8String;
begin
  if S = '' then Exit;

  MemStream := TMemoryStream.Create;
  try
    if WriteHeader then
    begin
      SetLength(HeaderStr, 3);
      HeaderStr[1] := #$EF;
      HeaderStr[2] := #$BB;
      HeaderStr[3] := #$BF;
      MemStream.Write(HeaderStr[1], 3);
    end;
    Content := UTF8Encode(S);
    MemStream.Write(Content[1], Length(Content));
    MemStream.Position := 0;
    MemStream.SaveToFile(FileName);
  finally
    MemStream.Free;
  end;
end;


// UtF-8文件读取函数
function LoadUTFFile(const FileName: string; ReadHeader: Boolean = True): string;
var
  MemStream: TMemoryStream;
  S, HeaderStr:UTF8String;
begin
  Result:='';
  if not FileExists(FileName) then Exit;
  MemStream := TMemoryStream.Create;
  try
    MemStream.LoadFromFile(FileName);
    if ReadHeader then
    begin
      SetLength(HeaderStr, 3);
      MemStream.Read(HeaderStr[1], 3);
      if (HeaderStr[1] = #$EF) and (HeaderStr[2] = #$BB) and (HeaderStr[3] = #$BF) then
      begin
        SetLength(S, MemStream.Size - 3);
        MemStream.Read(S[1], MemStream.Size - 3);
      end;
    end else
    begin
      SetLength(S, MemStream.Size);
      MemStream.Read(S[1], MemStream.Size);
    end;

    Result := UTF8ToUnicodeString(S);
  finally
    MemStream.Free;
  end;
end;

{$region '系统相关'}
function SetUnicodeHTMLFormat(HTMLStr: String): String;
const
  CrLf = #$D#$A;
begin
  Result := 'Version:0.9' + CrLf;
  Result := Result + 'StartHTML:11111111' + CrLf;
  Result := Result + 'EndHTML:$$$$$$$$' + CrLf;
  Result := Result + 'StartFragment:22222222' + CrLf;
  Result := Result + 'EndFragment:&&&&&&&&' + CrLf;
  Result := Result + '<!doctype html><html><body>' + CrLf;
  Result := ReplaceStr(Result, '11111111', Format('%.8d', [Length(Result)]));
  Result := Result + '<!--StartFragment-->';
  Result := Result + '<DIV>' + CrLf;
  Result := ReplaceStr(Result, '22222222', Format('%.8d', [Length(Result)]));
  Result := Result + HTMLStr + CrLf;
  Result := Result + '</DIV>';
  Result := ReplaceStr(Result, '&&&&&&&&', Format('%.8d', [Length(Result)]));
  Result := Result + '<!--EndFragment-->' + CrLf;
  Result := Result + '</body>' + CrLf;
  Result := Result + '</html>';
  Result := ReplaceStr(Result, '$$$$$$$$', Format('%.8d', [Length(Result)]));
end;

function SetHTMLFormat(HTMLStr: UTF8String): UTF8String;
const
  CrLf = #$D#$A;
begin
  Result := 'Version:0.9' + CrLf;
  Result := Result + 'StartHTML:11111111' + CrLf;
  Result := Result + 'EndHTML:$$$$$$$$' + CrLf;
  Result := Result + 'StartFragment:22222222' + CrLf;
  Result := Result + 'EndFragment:&&&&&&&&' + CrLf;
  Result := Result + '<!doctype html><html><body>' + CrLf;
  Result := ReplaceStr(Result, '11111111', Format('%.8d', [Length(Result)]));
  Result := Result + '<!--StartFragment-->';
  Result := Result + '<DIV>' + CrLf;
  Result := ReplaceStr(Result, '22222222', Format('%.8d', [Length(Result)]));
  Result := Result + HTMLStr + CrLf;
  Result := Result + '</DIV>';
  Result := ReplaceStr(Result, '&&&&&&&&', Format('%.8d', [Length(Result)]));
  Result := Result + '<!--EndFragment-->' + CrLf;
  Result := Result + '</body>' + CrLf;
  Result := Result + '</html>';
  Result := ReplaceStr(Result, '$$$$$$$$', Format('%.8d', [Length(Result)]));
end;

procedure CopyHTMLToClipBoardUTF8(const str: String; const hStr: UTF8String = '');
var
  gMem: HGLOBAL;
  pStr: PAnsiChar;
  String1: String;
  Format1: UINT;

  String2: UTF8String;
  Format2: UINT;
  i: Integer;
begin
  gMem := 0;
  Win32Check(OpenClipBoard(0));
  Win32Check(EmptyClipBoard);
  try
    if str <> '' then
    begin
      Format1 := CF_UNICODETEXT;
      String1 := str;
      gMem := GlobalAlloc(GMEM_DDESHARE + GMEM_MOVEABLE,
                  (StrLen(PChar(String1)) * SizeOf(Char)) + SizeOf(Char));
      try
        Win32Check(gMem <> 0);
        pStr := GlobalLock(gMem);
        Win32Check(pStr <> nil);
        CopyMemory(pStr, PChar(String1),
                       (StrLen(PChar(String1)) * SizeOf(Char)) + SizeOf(Char));
      finally
        GlobalUnlock(gMem);
      end;
      Win32Check(gMem <> 0);
      SetClipboardData(Format1, gMem);
      Win32Check(gMem <> 0);
      gMem := 0;
    end;

    if hStr <> '' then
    begin
      Format2 := RegisterClipboardFormat('HTML Format');
      String2 := SetHTMLFormat(hStr);
      gMem := GlobalAlloc(GMEM_DDESHARE + GMEM_MOVEABLE,
                  (StrLen(PAnsiChar(String2)) * SizeOf(AnsiChar)) + SizeOf(AnsiChar));
      try
        Win32Check(gMem <> 0);
        pStr := GlobalLock(gMem);
        Win32Check(pStr <> nil);
        CopyMemory(pStr, PAnsiChar(String2),
                       (StrLen(PAnsiChar(String2)) * SizeOf(AnsiChar)) + SizeOf(AnsiChar));
      finally
        GlobalUnlock(gMem);
      end;
      Win32Check(gMem <> 0);
      SetClipboardData(Format2, gMem);
      Win32Check(gMem <> 0);
      gMem := 0;
    end;
  finally
    Win32Check(CloseClipBoard);
  end;
end;

procedure CopyHTMLToClipBoard(const str: String; const hStr: String = '');
var
  gMem: HGLOBAL;
  pStr: PAnsiChar;
  Strings: array of String;
  Formats: array of UINT;
  i: Integer;
begin
  gMem := 0;
  Win32Check(OpenClipBoard(0));
  try
    SetLength(Strings, 1);
    SetLength(Formats, 1);
    Formats[0] := CF_UNICODETEXT;
    Strings[0] := str;

    if hStr <> '' then
    begin
      SetLength(Strings, 2);
      SetLength(Formats, 2);
      Formats[1] := RegisterClipboardFormat('HTML Format');
      Strings[1] := SetHTMLFormat(hStr);
    end;

    Win32Check(EmptyClipBoard);
    for i := 0 to High(Strings) do
    begin
      if Strings[i] = '' then Continue;
      gMem := GlobalAlloc(GMEM_DDESHARE + GMEM_MOVEABLE,
                  (StrLen(PChar(Strings[i])) * SizeOf(Char)) + SizeOf(Char));
      try
        Win32Check(gMem <> 0);
        pStr := GlobalLock(gMem);
        Win32Check(pStr <> nil);
        CopyMemory(pStr, PChar(Strings[i]),
                       (StrLen(PChar(Strings[i])) * SizeOf(Char)) + SizeOf(Char));
      finally
        GlobalUnlock(gMem);
      end;
      Win32Check(gMem <> 0);
      SetClipboardData(Formats[i], gMem);
      Win32Check(gMem <> 0);
      gMem := 0;
    end;
  finally
    Win32Check(CloseClipBoard);
  end;
end;

function StrHtmlEncode (const AStr: String): String;
begin
  Result := StringReplace(AStr,   '&', '&amp;',[rfReplaceAll]); {do not localize}
  Result := StringReplace(Result, '<', '&lt;',[rfReplaceAll]); {do not localize}
  Result := StringReplace(Result, '>', '&gt;',[rfReplaceAll]); {do not localize}
  Result := StringReplace(Result, '"', '&quot;' ,[rfReplaceAll]); {do not localize}
  Result := StringReplace(Result, ' ', '&nbsp;' ,[rfReplaceAll]); {do not localize}
  Result := StringReplace(Result, #$D#$A, '<br>' ,[rfReplaceAll]); {do not localize}
end;

function StrHtmlDecode (const AStr: String): String;
begin
  Result := StringReplace(AStr,   '&quot;', '"',[rfReplaceAll]); {do not localize}
  Result := StringReplace(Result, '&gt;',   '>',[rfReplaceAll]); {do not localize}
  Result := StringReplace(Result, '&lt;',   '<',[rfReplaceAll]); {do not localize}
  Result := StringReplace(Result, '&amp;',  '&',[rfReplaceAll]); {do not localize}
  Result := StringReplace(Result, '&nbsp;',  ' ',[rfReplaceAll]); {do not localize}
  Result := StringReplace(Result, '<br>', #$D#$A ,[rfReplaceAll]); {do not localize}
end;

function GetHTMLUBBCode(AHTML: String; var ABaseURL: String): String;
var
  iIndex1: Integer;
  StrStartFragment,
  StrEndFragment: String;

  iStartFragment,
  iEndFragment: Integer;
  reg: TPerlRegEx;
begin
  Result := '';

  iIndex1 := Pos('SourceURL:', AHTML);
  if iIndex1 > 0 then
  begin
    ABaseURL := Copy(AHTML, iIndex1 + Length('SourceURL:'), 100);
    iIndex1 := Pos(#$D, ABaseURL);
    if iIndex1 > 0 then
    begin
      ABaseURL := Copy(ABaseURL, 1, iIndex1 - 1);
    end;
  end;

  iIndex1 := Pos('StartFragment:', AHTML);
  if iIndex1 = 0 then Exit;
  StrStartFragment := Copy(AHTML, iIndex1 + Length('StartFragment:'), 12);
  iIndex1 := Pos(#$D, StrStartFragment);
  if iIndex1 = 0 then Exit;
  StrStartFragment := Copy(StrStartFragment, 1, iIndex1 - 1);

  iIndex1 := Pos('EndFragment:', AHTML);
  if iIndex1 = 0 then Exit;
  StrEndFragment := Copy(AHTML, iIndex1 + Length('EndFragment:'), 12);
  iIndex1 := Pos(#$D, StrEndFragment);
  if iIndex1 = 0 then Exit;
  StrEndFragment := Copy(StrEndFragment, 1, iIndex1 - 1);

  iStartFragment := StrToInt(StrStartFragment);
  iEndFragment := StrToInt(StrEndFragment);

  Result := UTF8ToString(MidStr(UTF8Encode(AHTML), iStartFragment + 1, iEndFragment - iStartFragment));

  reg := TPerlRegEx.Create;
  reg.Subject := UTF8Encode(Result);
  //reg.Subject := UTF8Encode(LowerCase(Result));

  reg.RegEx   := #$D#$A;
  reg.Replacement := '';
  reg.Options := [preCaseLess];
  reg.ReplaceAll;

  reg.RegEx   := '</p>';
  reg.Replacement := #$D#$A;
  reg.Options := [preCaseLess];
  reg.ReplaceAll;

  reg.RegEx   := '</div>';
  reg.Replacement := #$D#$A;
  reg.Options := [preCaseLess];
  reg.ReplaceAll;

  reg.RegEx   := '<br>';
  reg.Replacement := #$D#$A;
  reg.Options := [preCaseLess];
  reg.ReplaceAll;
  {
  reg.RegEx   := '<script[^>]*?>([\w\W]*?)<\/script>';
  reg.Replacement := '';
  reg.Options := [preCaseLess];
  reg.ReplaceAll;

  reg.RegEx   := '<font[^>]+color=([^ >]+)[^>]*>(.*?)<\/font>';
  reg.Replacement := '';//'$2';
  reg.Options := [preCaseLess];
  reg.ReplaceAll;
  }

  reg.RegEx   := '<img[^>]+tag="([^"]+)"[^>]*>';
  reg.Replacement := '[tag]$1[/tag]';
  reg.Options := [preCaseLess];
  reg.ReplaceAll;

  reg.RegEx   := '<img[^>]+file="([^"]+)"[^>]*>';
  reg.Replacement := '[img]file:///$1[/img]';
  reg.Options := [preCaseLess];
  reg.ReplaceAll;

  reg.RegEx   := '<img[^>]+src="([^"]+)"[^>]*>';
  reg.Replacement := '[img]$1[/img]';
  reg.Options := [preCaseLess];
  reg.ReplaceAll;

  reg.RegEx   := '<[^>]*?>';
  reg.Replacement := '';
  reg.Options := [preCaseLess];
  reg.ReplaceAll;

  reg.RegEx   := '&amp;';
  reg.Replacement := '&';
  reg.Options := [preCaseLess];
  reg.ReplaceAll;

  reg.RegEx   := '&lt;';
  reg.Replacement := '<';
  reg.Options := [preCaseLess];
  reg.ReplaceAll;

  reg.RegEx   := '&gt;';
  reg.Replacement := '>';
  reg.Options := [preCaseLess];
  reg.ReplaceAll;

  reg.RegEx   := '&nbsp;';
  reg.Replacement := ' ';
  reg.Options := [preCaseLess];
  reg.ReplaceAll;

  reg.RegEx   := '&quot;';
  reg.Replacement := '"';
  reg.Options := [preCaseLess];
  reg.ReplaceAll;

  Result := UTF8ToString(reg.Subject);

  Result := Result.Replace(#$D#$A#$D#$A, #$D#$A, [rfReplaceAll]);
  if Result.EndsWith(#$D#$A) then Result := Result.Remove(Length(Result) - 2);

  FreeAndNil(reg);
end;

function ForceForeGroundWindow(hwnd: THandle): boolean;
const
  SPI_GETFOREGROUNDLOCKTIMEOUT = $2000;
  SPI_SETFOREGROUNDLOCKTIMEOUT = $2001;
var
  ForegroundThreadID: DWORD;
  ThisThreadID : DWORD;
  timeout : DWORD;
begin
  if IsIconic(hwnd) then ShowWindow(hwnd, SW_RESTORE);  //如果窗口最小化

  {if GetForegroundWindow = hwnd then
    Result := true
  else}
  begin
    if ((Win32Platform = VER_PLATFORM_WIN32_NT) and (Win32MajorVersion > 4))
        or((Win32Platform = VER_PLATFORM_WIN32_WINDOWS) and
             ((Win32MajorVersion > 4) or ((Win32MajorVersion = 4) and
                    (Win32MinorVersion > 0)))) then
    begin
      Result := false;
      ForegroundThreadID :=
      GetWindowThreadProcessID(GetForegroundWindow, nil);
      ThisThreadID := GetWindowThreadPRocessId(hwnd, nil);
      if AttachThreadInput(ThisThreadID, ForegroundThreadID, true) then
      begin
        BringWindowToTop(hwnd);
        SetForegroundWindow(hwnd);
        AttachThreadInput(ThisThreadID, ForegroundThreadID, false);
        Result := (GetForegroundWindow = hwnd);
      end;
      if not Result then
      begin
        SystemParametersInfo(SPI_GETFOREGROUNDLOCKTIMEOUT, 0, @timeout, 0);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0, TObject(0),SPIF_SENDCHANGE);
        BringWindowToTop(hwnd);
        SetForegroundWindow(hWnd);
        SystemParametersInfo(SPI_SETFOREGROUNDLOCKTIMEOUT, 0,TObject(timeout), SPIF_SENDCHANGE);
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

function GetGUID: String;
var
  GUID: TGUID;
begin
  CoCreateGUID(GUID);
  Result := ReplaceStr(ReplaceStr(GUIDToString(GUID), '{', ''), '}', '');
end;

function PidlFree(var IdList: PItemIdList): Boolean;
var
  Malloc: IMalloc;
begin
  result := False;
  if IdList = nil then
    result := True
  else
  begin
    if Succeeded(SHGetMalloc(Malloc)) and (Malloc.DidAlloc(IdList) > 0) then
    begin
      Malloc.Free(IdList);
      IdList := nil;
      result := True;
    end;
  end;
end;

function GetSpecialFolderDir(const folderid: Integer): string;
var
  pidl: PItemIDList;
  buffer: array [0 .. 255] of char;
begin
  SHGetSpecialFolderLocation(Application.Handle, folderid, pidl);
  SHGetPathFromIDList(pidl, buffer);
  PidlFree(pidl);
  Result := StrPas(buffer) + '\';
end;

function GetFileSize(AFileName: String): Int64;
var
  FileHandle:Integer;
begin
  try
    if not FileExists(AFileName) then
    begin
      Result := 0;
    end
    else
    begin
      FileHandle := FileOpen(AFileName, fmOpenRead or fmShareDenyNone);
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
    Result := 0;
  end;
end;

{$endregion}

{$region '图形相关'}
{
procedure IconHandleToPng(AIconHandle: Integer; ADstFile: String);
var
  ABitmap: GR32.TBitmap32;
  hIcon: TIcon;
  graphics: TGPGraphics;
  GPImage: TGPImage;

  ADstLeft,
  ADstTop,
  ASrcWidth,
  ASrcHeight,
  ADstWidth,
  ADstHeight: Integer;
  Guid: TGuid;
  ABitmap32: GR32.TBitmap32;
begin
  hIcon := TIcon.Create;
  ABitmap := GR32.TBitmap32.Create;
  ABitmap32 := GR32.TBitmap32.Create;
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

    if CheckBitmap32Empty(ABitmap) then Exit;

    ABitmap32.SetSize(32, 32);
    ABitmap32.Clear($00000000);
    StreachDraw(ABitmap, ABitmap32, Rect(0, 0,ABitmap.Width, ABitmap.Height), Rect(0, 0,ABitmap32.Width, ABitmap32.Height));

    GPImage := GetGPImageByBitmap(ABitmap32);
    try
      GetEncoderClsid('image/png', Guid);
      GPImage.Save(ADstFile, Guid);
    finally
      GPImage.Free;
    end;
  finally
    ABitmap32.Free;
    ABitmap.Free;
    hIcon.Free;
  end;
end;
}
procedure GetFileExtIcon(AExt: String; AIcon: TIcon);
var
  SHFI:TSHFileInfo;
  IconTempFileName: String;
begin
  try
    IconTempFileName := IOUtils.TPath.GetTempPath + 'ExtTest' + AExt;

    try
      if not FileExists(IconTempFileName) then
        TFileStream.Create(IconTempFileName, fmCreate).Free;
    finally
      SHGetFileInfo(PChar(IconTempFileName), 0, SHFI, SizeOf(SHFI), SHGFI_ICON or SHGFI_TYPENAME);
      DeleteFile(PChar(IconTempFileName));
    end;

    AIcon.Handle := SHFI.hIcon;
  except
  end;
end;

procedure GetFileExtIcon(AExt: String; AFile: String);
var
  AIcon: TIcon;
begin
  try
    AIcon := TIcon.Create;
    try
      GetFileExtIcon(AExt, AIcon);
      AIcon.SaveToFile(AFile);
    finally
      AIcon.Free;
    end;
  except
  end;
end;

procedure GetFileExtPng(AExt: String; AFile: String);
begin

end;

function JpegToString(img: TJpegImage):string ;
var
  ms:TMemoryStream;
  ss:TStringStream;
  s:string;
begin
    ms := TMemoryStream.Create;
    img.SaveToStream(ms);
    ss := TStringStream.Create('');
    ms.Position:=0;
    EncodeStream(ms,ss);//将内存流编码为base64字符流
    s:=ss.DataString;
    ms.Free;
    ss.Free;
    result:=s;
end;

function PngToString(img: TPngImage):string ;
var
  ms:TMemoryStream;
  ss:TStringStream;
  s:string;
begin
    ms := TMemoryStream.Create;
    img.SaveToStream(ms);
    ss := TStringStream.Create('');
    ms.Position:=0;
    EncodeStream(ms,ss);//将内存流编码为base64字符流
    s:=ss.DataString;
    ms.Free;
    ss.Free;
    result:=s;
end;

function StreamToString(AStream: TStream):string ;
var
  ss:TStringStream;
  s:string;
begin
    ss := TStringStream.Create('');
    AStream.Position:=0;
    EncodeStream(AStream,ss);//将内存流编码为base64字符流
    s:=ss.DataString;
    ss.Free;
    result:=s;
end;

procedure StringToStream(imgStr: string; ms: TStream);
var
  ss: TStringStream;
begin
  ss := TStringStream.Create(imgStr);
  DecodeStream(ss, ms); // 将base64字符流还原为内存流
  ms.Position := 0;
  ss.Free;
end;

function StrAlloc(Size: Cardinal): PAnsiChar;
begin
  Inc(Size, SizeOf(Cardinal));
  GetMem(Result, Size);
  Cardinal(Pointer(Result)^) := Size;
  Inc(Result, SizeOf(Cardinal));
end;

function FileToString(AFile: String):string;
var
  AStream: TMemoryStream;
  Buff: Array of PAnsiChar;
  Size: Integer;
begin
  try
    AStream := TMemoryStream.Create;
    AStream.LoadFromFile(AFile);
    try
      //Size := Base64EncodeBufSize(AStream.Size);
      //SetLength(Buff, Size);
      AStream.Position := 0;
      Result := Base64Encode(AStream.Memory^, AStream.Size);
      //Result := StrPas(Buff[0]);
      //SetLength(Buff, 0);
      //FreeMem(Buff);
      //Result := EncdDecd.EncodeBase64(AStream, AStream.Size);
      //Result := StreamToString(AStream);
    finally
      FreeAndNil(AStream);
    end;
  except
  end;
end;

function BitmapToString(img: TBitmap):string ;
var
  ms:TMemoryStream;
  ss:TStringStream;
  s:string;
begin
    ms := TMemoryStream.Create;
    img.SaveToStream(ms);
    ss := TStringStream.Create('');
    ms.Position:=0;
    EncodeStream(ms,ss);//将内存流编码为base64字符流
    s:=ss.DataString;
    ms.Free;
    ss.Free;
    result:=s;
end;

function StringToBitmap(imgStr:string):TBitmap;
var ss:TStringStream;
    ms:TMemoryStream;
    bitmap:TBitmap;
begin
    ss := TStringStream.Create(imgStr);
    ms := TMemoryStream.Create;
    DecodeStream(ss,ms);//将base64字符流还原为内存流
    ms.Position:=0;
    bitmap := TBitmap.Create;
    bitmap.LoadFromStream(ms);
    ss.Free;
    ms.Free;
    result :=bitmap;
end;

function StringToJpeg(imgStr:string):TJpegImage;
var ss:TStringStream;
    ms:TMemoryStream;
    jpeg:TJpegImage;
begin
    ss := TStringStream.Create(imgStr);
    ms := TMemoryStream.Create;
    DecodeStream(ss,ms);//将base64字符流还原为内存流
    ms.Position:=0;
    jpeg := TJpegImage.Create;
    jpeg.LoadFromStream(ms);
    ss.Free;
    ms.Free;
    result := jpeg;
end;

function StringToPng(imgStr:string):TPngImage;
var
  ss:TStringStream;
  ms:TMemoryStream;
  png:TPngImage;
begin
  ss := TStringStream.Create(imgStr);
  ms := TMemoryStream.Create;
  DecodeStream(ss,ms);//将base64字符流还原为内存流
  ms.Position:=0;
  png := TPngImage.Create;
  png.LoadFromStream(ms);
  ss.Free;
  ms.Free;
  result := png;
end;

procedure CopyPng(const Src: TPngImage; dest: TPngImage;
  const sOffset: Integer);
var
  i, j, s: Integer;
  p1, p2: PByteArray;
  pa1, pa2: PByteArray;
begin
  for i := 0 to Src.Height - 1 do
  begin
    p1 := Src.Scanline[i];
    p2 := dest.Scanline[i];
    pa1 := Src.AlphaScanline[i];
    pa2 := dest.AlphaScanline[i];
    for j := 0 to dest.Width - 1 do
    begin
      s := j + sOffset;
      p2[3 * j] := p1[3 * s];
      p2[3 * j + 1] := p1[3 * s + 1];
      p2[3 * j + 2] := p1[3 * s + 2];
      pa2[j] := pa1[s];
    end;
  end;
end;

function SplitePng(const Src: TPngImage; Count: Integer): TPngArray;
var
  i, lwidth, loffset: Integer;
begin
  SetLength(Result, Count);
  lwidth := Src.Width div Count;
  loffset := 0;
  for i := 0 to Count - 1 do
  begin
    Result[i] := TPngImage.CreateBlank(COLOR_RGBALPHA, 8, lwidth, Src.Height);
    CopyPng(Src, Result[i], loffset);
    Inc(loffset, lwidth);
  end;
end;

const
  _fc0: Single    = 0.0;
  _fcd5: Single   = 0.5;
  _fc1: Single    = 1.0;
  _fc2: Single    = 2.0;
  _fc6: Single    = 6.0;
  _fc60: Single   = 60.0;
  _fc255: Single  = 255.0;
  _fc360: Single  = 360.0;
  _fc510: Single  = 510.0;

procedure ColorToHSL(var H, S, L: Single; Color: TARGB);
var
  rgbMax: LongWord;
asm
    push      eax
    push      edx
    push      ecx
    movzx     ecx, Color.TARGBQuad.Blue
    movzx     edx, Color.TARGBQuad.Green
    movzx     eax, Color.TARGBQuad.Red
    cmp       ecx, edx        // ecx = rgbMax
    jge       @@1             // edx = rgbMin
    xchg      ecx, edx
@@1:
    cmp       ecx, eax
    jge       @@2
    xchg      ecx, eax
@@2:
    cmp       edx, eax
    cmova     edx, eax
    mov       rgbMax, ecx
    mov       eax, ecx
    add       ecx, edx        // ecx = rgbMax + rgbMin
    sub       eax, edx        // delta = rgbMax - rgbmin
    cvtsi2ss  xmm0, ecx
    divss     xmm0, _fc510
    pop       edx
    movss     [edx], xmm0     // *L = (rgbMax + rgbMin) / 255 / 2
    jnz       @@3
    pop       ecx             // if (delta == 0)
    pop       edx             // {
    mov       [ecx], eax      //   *H = *S = 0
    mov       [edx], eax      //   return
    jmp       @@Exit          // }
@@3:
    comiss    xmm0, _fcd5
    jb        @@4
    neg       ecx
    add       ecx, 510        // if (L < 128) ecx = 510 - ecx
@@4:
    pop       edx
    cvtsi2ss  xmm0, eax
    cvtsi2ss  xmm1, ecx
    movaps    xmm2, xmm0
    divss     xmm0, xmm1
    movss     [edx], xmm0     // *S = delta / ecx
    mov       eax, rgbMax
    cmp       al, Color.TARGBQuad.Red
    jne       @@5
    movzx     eax, Color.TARGBQuad.Green
    movzx     edx, Color.TARGBQuad.Blue
    xor       ecx, ecx        // if (R == rgbMax) eax = G - B; add = 0
    jmp       @@7
@@5:
    cmp       al, Color.TARGBQuad.Green
    jne       @@6
    movzx     eax, Color.TARGBQuad.Blue
    movzx     edx, Color.TARGBQuad.Red
    mov       ecx, 120         // if (G == rgbMax) eax = B - R; add = 120
    jmp       @@7
@@6:
    movzx     eax, Color.TARGBQuad.Red
    movzx     edx, Color.TARGBQuad.Green
    mov       ecx, 240         // if (B == rgbMax) eax = R - G; add = 240
@@7:
    sub       eax, edx
    cvtsi2ss  xmm0, eax
    cvtsi2ss  xmm1, ecx
    mulss     xmm0, _fc60
    divss     xmm0, xmm2
    addss     xmm0, xmm1      // H = eax * 60 / delta + add
    comiss    xmm0, _fc0
    jae       @@8
    addss     xmm0, _fc360
@@8:
    pop       eax
    movss     [eax], xmm0
@@Exit:
end;

function HSLToColor(H, S, L: Single): TARGB;
asm
    movss     xmm0, H
    comiss    xmm0, _fc0
    jae       @@1
    addss     xmm0, _fc360
    jmp       @@2
@@1:
    comiss    xmm0, _fc360
    jb        @@2
    subss     xmm0, _fc360
@@2:
    movss     xmm3, _fc1
    divss     xmm0, _fc60
    cvtss2si  edx, xmm0       // index = Round(H)
    cvtsi2ss  xmm1, edx
    subss     xmm0, xmm1      // extra = H - index
    comiss    xmm0, _fc0      // if (extra < 0) // 如果index发生五入
    jae       @@3             // {
    dec       edx             //   index --
    addss     xmm0, xmm3      //   extra ++
@@3:                          // }
    test      edx, 1
    jz        @@4
    movaps    xmm1, xmm0
    movaps    xmm0, xmm3
    subss     xmm0, xmm1      // if (index & 1) extra = 1 - extra
@@4:
    movss     xmm2, S
    movss     xmm4, L
    minss     xmm2, xmm3
    minss     xmm4, xmm3
    maxss     xmm2, _fc0
    maxss     xmm4, _fc0
    pslldq    xmm0, 4         //            max  mid  min
    movlhps   xmm0, xmm3      // xmm0 = 0.0 1.0 extra 0.0
    movaps    xmm1, xmm0
    subss     xmm3, xmm2
    movss     xmm2, _fcd5
    pshufd    xmm2, xmm2, 0
    pshufd    xmm3, xmm3, 0
    subps     xmm1, xmm2
    mulps     xmm1, xmm3
    subps     xmm0, xmm1      // xmm0 = xmm0 - (xmm0 - 0.5) * (1.0 - S);
    movaps    xmm1, xmm0
    subss     xmm4, xmm2
    mulss     xmm4, _fc2      // xmm4 = (L - 0.5) * 2
    comiss    xmm4, _fc0
    jb        @@5
    movss     xmm0, _fc1
    pshufd    xmm0, xmm0, 0
    subps     xmm0, xmm1      // if (xmm4 >= 0) xmm0 = 1 - xmm0
@@5:
    movss     xmm3, _fc255
    pshufd    xmm4, xmm4, 0
    pshufd    xmm3, xmm3, 0
    mulps     xmm0, xmm4
    addps     xmm0, xmm1
    mulps     xmm0, xmm3      // xmm0 = (xmm0 + xmm0 * xmm4) * 255
    jmp       @@jmpTable[edx*4].Pointer
@@jmpTable:   dd  offset  @@H60
              dd  offset  @@H120
              dd  offset  @@H180
              dd  offset  @@H240
              dd  offset  @@H300
              dd  offset  @@H360
@@H360:                       // 300 - 359
    pshufd    xmm0, xmm0, 11100001b
    jmp       @@H60
@@H300:                       // 240 - 299
    pshufd    xmm0, xmm0, 11010010b
    jmp       @@H60
@@H240:                       // 180 - 239
    pshufd    xmm0, xmm0, 11000110b
    jmp       @@H60
@@H180:                       // 120 - 179
    pshufd    xmm0, xmm0, 11001001b
    jmp       @@H60
@@H120:                       // 60 - 119
    pshufd    xmm0, xmm0, 11011000b
@@H60:                        // 0 - 59
    cvtps2dq  xmm0, xmm0
    packssdw  xmm0, xmm0
    packuswb  xmm0, xmm0
    movd      eax, xmm0
    //or        eax, 0ff000000h
end;

//------------------------------------------------------------------------------
procedure ColorHSLtoRGB(H, S, L: Double; var R, G, B: Integer);
var //类似于返回多个值的函数
   Sat, Lum: Double;
begin
   R := 0;
   G := 0;
   B := 0;
   if (H < 360) and (H >= 0) and (S <= 100) and (S >= 0) and (L <= 100) and (L
      >=
      0) then
      begin
         if H <= 60 then
            begin
               R := 255;
               G := Round((255 / 60) * H);
               B := 0;
            end
         else if H <= 120 then
            begin
               R := Round(255 - (255 / 60) * (H - 60));
               G := 255;
               B := 0;
            end
         else if H <= 180 then
            begin
               R := 0;
               G := 255;
               B := Round((255 / 60) * (H - 120));
            end
         else if H <= 240 then
            begin
               R := 0;
               G := Round(255 - (255 / 60) * (H - 180));
               B := 255;
            end
         else if H <= 300 then
            begin
               R := Round((255 / 60) * (H - 240));
               G := 0;
               B := 255;
            end
         else if H < 360 then
            begin
               R := 255;
               G := 0;
               B := Round(255 - (255 / 60) * (H - 300));
            end;

         Sat := Abs((S - 100) / 100);
         R := Round(R - ((R - 128) * Sat));
         G := Round(G - ((G - 128) * Sat));
         B := Round(B - ((B - 128) * Sat));

         Lum := (L - 50) / 50;
         if Lum > 0 then
            begin
               R := Round(R + ((255 - R) * Lum));
               G := Round(G + ((255 - G) * Lum));
               B := Round(B + ((255 - B) * Lum));
            end
         else if Lum < 0 then
            begin
               R := Round(R + (R * Lum));
               G := Round(G + (G * Lum));
               B := Round(B + (B * Lum));
            end;
      end;
end;

//------------------------------------------------------------------------------
{RGB空间到HSL空间的转换}
procedure ColorRGBtoHSL(R, G, B: Integer; var H, S, L: Double);
var
   Delta: Double;
   CMax, CMin: Double;
   Red, Green, Blue, Hue, Sat, Lum: Double;
begin
   Red := R / 255;
   Green := G / 255;
   Blue := B / 255;
   CMax := Max(Red, Max(Green, Blue));
   CMin := Min(Red, Min(Green, Blue));
   Lum := (CMax + CMin) / 2;
   if CMax = CMin then
      begin
         Sat := 0;
         Hue := 0;
      end
   else
      begin
         if Lum < 0.5 then
            Sat := (CMax - CMin) / (CMax + CMin)
         else
            Sat := (cmax - cmin) / (2 - cmax - cmin);
         delta := CMax - CMin;
         if Red = CMax then
            Hue := (Green - Blue) / Delta
         else if Green = CMax then
            Hue := 2 + (Blue - Red) / Delta
         else
            Hue := 4.0 + (Red - Green) / Delta;
         Hue := Hue / 6;
         if Hue < 0 then
            Hue := Hue + 1;
      end;
   H := (Hue * 360);
   S := (Sat * 100);
   L := (Lum * 100);
end;
//------------------------------------------------------------------------------
{RGB空间到HSL空间的转换}
procedure ColorRGBtoHSL2(R, G, B: Integer; var H, S, L: Double);
var
   Delta: Double;
   CMax, CMin: Double;
   Red, Green, Blue, Hue, Sat, Lum: Double;
begin
   Red := R / 255;
   Green := G / 255;
   Blue := B / 255;
   CMax := Max(Red, Max(Green, Blue));
   CMin := Min(Red, Min(Green, Blue));
   Lum := (77 * Red + 151 * Green + 28 * Blue);//(CMax + CMin) / 2;
   if CMax = CMin then
      begin
         Sat := 0;
         Hue := 0;
      end
   else
      begin
         if Lum < 0.5 then
            Sat := (CMax - CMin) / (CMax + CMin)
         else
            Sat := (cmax - cmin) / (2 - cmax - cmin);
         delta := CMax - CMin;
         if Red = CMax then
            Hue := (Green - Blue) / Delta
         else if Green = CMax then
            Hue := 2 + (Blue - Red) / Delta
         else
            Hue := 4.0 + (Red - Green) / Delta;
         Hue := Hue / 6;
         if Hue < 0 then
            Hue := Hue + 1;
      end;
   H := (Hue * 360);
   S := (Sat * 100);
   L := (Lum * 100 / 256);
end;

procedure ConvertBitmap32Color(ABitmap32:TBitmap32; AColor:TColor);
var
   L: Integer;
   hexString:String;
   ScanlineBytes, x, y: integer;
   P: PColor32EntryArray;
   RVALUE, bVALUE, GVALUE: integer;
   HVALUE, SVALUE, LVALUE: Double;//Single;
   HNewVALUE, SNewVALUE, LNewVALUE: Double;//Single;
begin
  try
    if not ABitmap32.Empty then
    begin
      //ColorToHSL(HNewVALUE, SNewVALUE, LNewVALUE, AColor);
      hexString := IntToHex(AColor,6);
      ColorRGBtoHSL(StrToInt('$'+Copy(hexString,5,2)), StrToInt('$'+Copy(hexString,3,2)), StrToInt('$'+Copy(hexString,1,2)), HNewVALUE, SNewVALUE, LNewVALUE);

      L := 0;

      ScanlineBytes := Integer(ABitmap32.ScanLine[1]) - Integer(ABitmap32.ScanLine[0]);
      P := PColor32EntryArray(ABitmap32.ScanLine[0]);
      for y := 0 to ABitmap32.Height - 1 do
      begin
        for x := 0 to ABitmap32.Width - 1 do
        begin
          //ColorToHSL(HVALUE, SVALUE, LVALUE, TColor(p[x]));
          //p[x] := TColor32Entry(HSLToColor(HNewVALUE, SNewVALUE, LVALUE + L));
          RVALUE := p[x].R;
          GVALUE := p[x].G;
          BVALUE := p[x].B;
          ColorRGBtoHSL(RVALUE, GVALUE, BVALUE, HVALUE, SVALUE, LVALUE);
          ColorHSLtoRGB(HNewVALUE, SNewVALUE, LVALUE + L, RVALUE, GVALUE, BVALUE);
          p[x].R := RVALUE;
          p[x].G := GVALUE;
          p[x].B := BVALUE;
        end;
        inc(integer(p), ScanlineBytes);
      end;
    end;
  except
    //on E: Exception do MessageBox(0, PChar(E.Message), '', 0);
  end;
end;

procedure ConvertBitmap32ColorFull(ABitmap32:TBitmap32; AColor:TColor);
var
   L: Integer;
   hexString:String;
   ScanlineBytes, x, y: integer;
   P: PColor32EntryArray;
   RVALUE, bVALUE, GVALUE: integer;
   HVALUE, SVALUE, LVALUE: Double;//Single;
   HNewVALUE, SNewVALUE, LNewVALUE: Double;//Single;
begin
  try
    if not ABitmap32.Empty then
    begin
      //ColorToHSL(HNewVALUE, SNewVALUE, LNewVALUE, AColor);
      hexString := IntToHex(AColor,6);
      ColorRGBtoHSL(StrToInt('$'+Copy(hexString,5,2)), StrToInt('$'+Copy(hexString,3,2)), StrToInt('$'+Copy(hexString,1,2)), HNewVALUE, SNewVALUE, LNewVALUE);

      L := 0;

      ScanlineBytes := Integer(ABitmap32.ScanLine[1]) - Integer(ABitmap32.ScanLine[0]);
      P := PColor32EntryArray(ABitmap32.ScanLine[0]);
      for y := 0 to ABitmap32.Height - 1 do
      begin
        for x := 0 to ABitmap32.Width - 1 do
        begin
          //ColorToHSL(HVALUE, SVALUE, LVALUE, TColor(p[x]));
          //p[x] := TColor32Entry(HSLToColor(HNewVALUE, SNewVALUE, LVALUE + L));
          RVALUE := p[x].R;
          GVALUE := p[x].G;
          BVALUE := p[x].B;
          ColorRGBtoHSL(RVALUE, GVALUE, BVALUE, HVALUE, SVALUE, LVALUE);
          ColorHSLtoRGB(HNewVALUE, SNewVALUE, LNewVALUE, RVALUE, GVALUE, BVALUE);
          p[x].R := RVALUE;
          p[x].G := GVALUE;
          p[x].B := BVALUE;
        end;
        inc(integer(p), ScanlineBytes);
      end;
    end;
  except
    //on E: Exception do MessageBox(0, PChar(E.Message), '', 0);
  end;
end;


function GetBitmapColor(DestBitmap:TBitmap):TColor;
var
   L: Integer;
   hexString:String;
   x, y, ScanlineBytes: integer;
   p: prgbtriplearray;
   RVALUE, BVALUE, GVALUE: integer;
   HVALUE, SVALUE, LVALUE: Double;

   iLoop: Integer;
   STotal,
   LTotal: Int64;
   HTotal: array[0..36] of Integer;
   RTotal, GTotal, BTotal: Int64;
begin
  RTotal := 0;
  GTotal := 0;
  BTotal := 0;
  for iLoop := 0 to 36 do
  begin
    HTotal[iLoop] := 0;
  end;

  STotal := 0;
  LTotal := 0;

  try
    if not DestBitmap.Empty then
    begin
      DestBitmap.PixelFormat := pf24bit;
      p := DestBitmap.ScanLine[0];
      //ScanlineBytes := Abs(integer(DestBitmap.ScanLine[1]) - integer(DestBitmap.ScanLine[0]));

      if DestBitmap.Height > 1 then
        ScanlineBytes := integer(DestBitmap.ScanLine[1]) - integer(DestBitmap.ScanLine[0])
      else
        ScanlineBytes := 0;
      try
        for y := 0 to DestBitmap.Height - 1 do
        begin
          for x := 0 to DestBitmap.Width - 1 do
          begin
            RVALUE := p[x].rgbtRed;
            GVALUE := p[x].rgbtGreen;
            BVALUE := p[x].rgbtBlue;
            ColorRGBtoHSL(RVALUE, GVALUE, BVALUE, HVALUE, SVALUE, LVALUE);
            Inc(LTotal, Round(LVALUE));
            Inc(STotal, Round(SVALUE));

            HTotal[Round(HVALUE) div 10] := HTotal[Round(HVALUE) div 10] + 1;
          end;
          inc(integer(p), ScanlineBytes);
        end;
      except
      end;
      HVALUE := 0;
      for iLoop := 0 to 36 do
      begin
        if HTotal[iLoop] > HTotal[Round(HVALUE) div 10] then HVALUE := iLoop * 10;
      end;
      ColorHSLtoRGB(HVALUE, Min(STotal / (DestBitmap.Height * DestBitmap.Width), 60), LTotal / (DestBitmap.Height * DestBitmap.Width), RVALUE, GVALUE, BVALUE);
      //HSLtoRGB(HVALUE, 40, 70, RVALUE, GVALUE, BVALUE);
      Result := BVALUE * 256 * 256 + GVALUE * 256 + RVALUE;
    end;
  except
  end;
end;

procedure ScaleRot(SrcBitmap, DstBitmap: TBitmap32; cx, cy, Alpha: Single; AHighQuaility: Boolean = False);
var
  SrcR: Integer;
  SrcB: Integer;
  T: TAffineTransformation;
  Sn, Cn: TFloat;
  Sx, Sy, Scale: Single;
begin
  SrcR := SrcBitmap.Width;
  SrcB := SrcBitmap.Height;
  T := TAffineTransformation.Create;
  T.SrcRect := FloatRect(0, 0, SrcR, SrcB);
  try
    T.Clear;
    T.Rotate(cx, cy, Alpha);
    DstBitmap.Clear($00000000);
    if AHighQuaility then
    begin
      SrcBitmap.ResamplerClassName := 'TDraftResampler';
      DstBitmap.ResamplerClassName := 'TDraftResampler';
//      with TKernelResampler.Create(SrcBitmap) do
//      begin
//        KernelMode := kmTableNearest;
//        TableSize := 16;
//        Kernel := TLanczosKernel.Create;
//      end;
//      with TKernelResampler.Create(DstBitmap) do
//      begin
//        KernelMode := kmTableNearest;
//        TableSize := 16;
//        Kernel := TLanczosKernel.Create;
//      end;
    end;
    Transform(DstBitmap, SrcBitmap, T);
  finally
    T.Free;
  end;
end;

procedure DottedRect(const bmp:TBitmap32; rect: TRect);
const
  whiteColor = $AA000000;
  blackColor = $AAFFFFFF;
var
  i: Integer;
begin
  bmp.MoveTo(rect.Left, rect.Top);
  i := rect.Left;
  while i <= rect.Right do
  begin
    bmp.PenColor := whiteColor;
    bmp.LineToTS(i + 1, rect.Top);
    inc(i, 1);
    bmp.PenColor := blackColor;
    bmp.LineToTS(i + 1, rect.Top);
    inc(i, 1);
    bmp.MoveTo(i, rect.Top);
  end;

  bmp.MoveTo(rect.Right - 1, rect.Top);
  if i = rect.Right then
  begin
    i := rect.Top;
    bmp.PenColor := blackColor;
    bmp.LineToTS(rect.Right - 1, i + 1);
    inc(i, 1);
  end
  else
    i := rect.Top;

  while i <= rect.Bottom do
  begin
    bmp.PenColor := whiteColor;
    bmp.LineToTS(rect.Right - 1, i + 1);
    inc(i, 1);
    bmp.PenColor := blackColor;
    bmp.LineToTS(rect.Right - 1, i + 1);
    inc(i, 1);
    bmp.MoveTo(rect.Right - 1, i);
  end;

  bmp.MoveTo(rect.Left, rect.Top + 1);
  i := rect.Top + 1;
  bmp.PenColor := blackColor;
  bmp.LineToTS(rect.Left, i + 1);
  inc(i, 1);
  while i <= rect.Bottom do
  begin
    bmp.PenColor := whiteColor;
    bmp.LineToTS(rect.Left, i + 1);
    inc(i, 1);
    bmp.PenColor := blackColor;
    bmp.LineToTS(rect.Left, i + 1);
    inc(i, 1);
    bmp.MoveTo(rect.Left, i);
  end;

  bmp.MoveTo(rect.Left, rect.Bottom - 1);
  if i = rect.Bottom + 1 then
  begin
    i := rect.Left;
    bmp.PenColor := blackColor;
    bmp.LineToTS(i + 1, rect.Bottom - 1);
    inc(i, 1);
  end
  else
    i := rect.Left;
  while i < rect.Right - 1 do
  begin
    bmp.PenColor := whiteColor;
    bmp.LineToTS(i + 1, rect.Bottom - 1);
    inc(i, 1);
    bmp.PenColor := blackColor;
    if i < rect.Right - 1 then bmp.LineToTS(i + 1, rect.Bottom - 1);
    inc(i, 1);
    bmp.MoveTo(i, rect.Bottom - 1);
  end;


  //bmp.FrameRectTS(rect, $88888888);
end;

procedure CopyBitmap32Alpha(ASrcBitmap, ADstBitmap: GR32.TBitmap32);
var
  P1: PColor32EntryArray;
  P2: PColor32EntryArray;
  ScanlineBytes, x, y: Integer;
begin
  if (ASrcBitmap.Width <> ADstBitmap.Width) or
     (ASrcBitmap.Height <> ADstBitmap.Height) then Exit;
  
  ScanlineBytes := Integer(ASrcBitmap.ScanLine[1]) - Integer(ASrcBitmap.ScanLine[0]);

  P1 := PColor32EntryArray(ASrcBitmap.ScanLine[0]);
  P2 := PColor32EntryArray(ADstBitmap.ScanLine[0]);

  for y := 0 to ADstBitmap.Height - 1 do
  begin
    for x := 0 to ADstBitmap.Width - 1 do
    begin
      P2[x].A := (P2[x].A * P1[x].A) shr 8;
    end;
    Inc(Integer(P1), ScanlineBytes);
    Inc(Integer(P2), ScanlineBytes);
  end;
end;

procedure CopyBitmap32Alpha(ASrcBitmap, ADstBitmap: GR32.TBitmap32; ADstRect: TRect; ABackgroundMode: Boolean);
var
  P1: PColor32EntryArray;
  P2: PColor32EntryArray;
  ScanlineBytes1, ScanlineBytes2, x, y: Integer;
begin
  ScanlineBytes1 := Integer(ASrcBitmap.ScanLine[1]) - Integer(ASrcBitmap.ScanLine[0]);
  ScanlineBytes2 := Integer(ADstBitmap.ScanLine[1]) - Integer(ADstBitmap.ScanLine[0]);

  P1 := PColor32EntryArray(ASrcBitmap.ScanLine[0]);
  P2 := PColor32EntryArray(ADstBitmap.ScanLine[0]);

  Inc(Integer(P2), ADstRect.Top * ScanlineBytes2);
  for y := ADstRect.Top to ADstRect.Bottom - 1 do
  begin
    for x := ADstRect.Left to ADstRect.Right - 1 do
    begin
      if ABackgroundMode then
      begin
        P2[x].A := (P2[x].A * P1[x - ADstRect.Left].A) shr 8;
        P2[x].R := (P2[x].R * P1[x - ADstRect.Left].A) shr 8;
        P2[x].G := (P2[x].G * P1[x - ADstRect.Left].A) shr 8;
        P2[x].B := (P2[x].B * P1[x - ADstRect.Left].A) shr 8;
      end
      else
      begin
        P2[x].A := P1[x - ADstRect.Left].A;//(P2[x].A * P1[x - ADstRect.Left].A) shr 8;
      end;
    end;
    Inc(Integer(P1), ScanlineBytes1);
    Inc(Integer(P2), ScanlineBytes2);
  end;
end;

procedure GetBitmapByPngAndBytes(var APng: TPngImage; var ABytes: PByte; var ASize: TSize; var AStoreBMP: TBitmap32; Designing: Boolean); {$IFDEF USEINLINING} inline; {$ENDIF}
begin
  if ABytes <> nil then
  begin
    AStoreBMP.SetSize(ASize.Width, ASize.Height);
    Move(ABytes^, AStoreBMP.Bits^, AStoreBMP.Width * AStoreBMP.Height * 4);
  end
  else
  begin
    if APng <> nil then 
    begin
      GetBitmap32ByPngImage(APng, 0, AStoreBMP);
      ASize.Width := AStoreBMP.Width;
      ASize.Height := AStoreBMP.Height;
      GetMem(ABytes, AStoreBMP.Width * AStoreBMP.Height * 4);
      Move(AStoreBMP.Bits^, ABytes^, AStoreBMP.Width * AStoreBMP.Height * 4);
    end
    else
    begin
      AStoreBMP.SetSize(0, 0);
      Exit;
    end;
  end;

  if Designing then Exit;
  FreeAndNil(APng);
  //APng := TPngImage.Create;
end;

function GetBitsByPngAndBytes(var APng: TPngImage; var ABytes: PByte; var ASize: TSize; Designing: Boolean; ABackColor: TColor32 = $00000000): PByte; {$IFDEF USEINLINING} inline; {$ENDIF}
var
  ABitmap: TBitmap32;
begin
  if ABytes <> nil then
  begin
    Result := ABytes;
  end
  else
  begin
    ABitmap := GetBitmap32ByPngImage(APng, ABackColor);
    try
      ASize.Width := ABitmap.Width;
      ASize.Height := ABitmap.Height;
      GetMem(ABytes, ABitmap.Width * ABitmap.Height * 4);
      Move(ABitmap.Bits^, ABytes^, ABitmap.Width * ABitmap.Height * 4);
      Result := ABytes;
    finally
      ABitmap.Free;
    end;
  end;

  if Designing then Exit;
  FreeAndNil(APng);
  //APng := TPngImage.Create;
end;

function GetBitmapByPngAndBitmap(var APng: TPngImage; var ABitmap: TBitmap32; Designing: Boolean): TBitmap32; {$IFDEF USEINLINING} inline; {$ENDIF}
begin
  if ABitmap <> nil then
  begin
    Result := ABitmap;
    Exit;
  end;

  ABitmap := GetBitmap32ByPngImage(APng);
  Result := ABitmap;

  if Designing then Exit;
  FreeAndNil(APng);
  APng := TPngImage.Create;
end;

function GetBitmap32ByFile(AFile: String; ABackColor: TColor32 = $00000000): TBitmap32;
var
  APngImage: TPngImage;
  AGIFImage: TjinGIFImage;
begin
  Result := nil;
  if SameText(ExtractFileExt(AFile), '.gif') then
  begin
    AGIFImage := TjinGIFImage.Create;
    try
      try
        Result := TBitmap32.Create;
        AGIFImage.LoadFromFile(AFile);
        Result.Assign(AGIFImage.Bitmap[0]);
        Exit;
      except
      end;
    finally
      AGIFImage.Free;
    end;
  end
  else if SameText(ExtractFileExt(AFile), '.png') then
  begin
    APngImage := TPngImage.Create;
    try
      try
        APngImage.LoadFromFile(AFile);
        if not APngImage.Empty then
        begin
          Result := GetBitmap32ByPngImage(APngImage, ABackColor);
          Exit;
        end;
      except
      end;
    finally
      APngImage.Free;
    end;
  end;

  Result := TBitmap32.Create;
  try
    Result.LoadFromFile(AFile);
  except
  end;
end;

procedure LoadPNGIntoBitmap32(DstBitmap: TBitmap32; SrcStream: TStream; out AlphaChannelUsed: Boolean); overload;
var
  PNGObject: TPNGObject;
  TransparentColor: TColor32;
  PixelPtr: PColor32;
  AlphaPtr: PByte;
  ScanPtr: PRGBTriple;
  X, Y: Integer;
begin
  try
    PNGObject := TPngObject.Create;
    PNGObject.LoadFromStream(SrcStream);
    DstBitmap.SetSize(PNGObject.Width, PNGObject.Height);
    //DstBitmap.Assign(PNGObject); // does not work with NoDIB
    DstBitmap.ResetAlpha;
    DstBitmap.DeleteCanvas;


    case PNGObject.TransparencyMode of
      ptmPartial:
        begin
          if (PNGObject.Header.ColorType = COLOR_GRAYSCALEALPHA) or
             (PNGObject.Header.ColorType = COLOR_RGBALPHA) then
          begin
            PixelPtr := PColor32(@DstBitmap.Bits[0]);
            for Y := 0 to DstBitmap.Height - 1 do
            begin
              ScanPtr := PRGBTriple(PNGObject.Scanline[Y]);
              AlphaPtr := PByte(PNGObject.AlphaScanline[Y]);
              for X := 0 to DstBitmap.Width - 1 do
              begin
                PixelPtr^ :=
                  (TRGBTriple(ScanPtr^).rgbtBlue) or
                  (TRGBTriple(ScanPtr^).rgbtGreen shl 8) or
                  (TRGBTriple(ScanPtr^).rgbtRed shl 16) or
                  (TColor32(AlphaPtr^) shl 24);
                Inc(PixelPtr);
                Inc(AlphaPtr);
                Inc(ScanPtr);
              end;
            end;
            AlphaChannelUsed := True;
            DstBitmap.DrawMode := dmBlend;
          end;
        end;
      ptmBit:
        begin
          TransparentColor := Color32(PNGObject.TransparentColor);
          PixelPtr := PColor32(@DstBitmap.Bits[0]);
          for Y := 0 to DstBitmap.Height - 1 do
          begin
            for X := 0 to DstBitmap.Width - 1 do
            begin
              PixelPtr^ :=  Color32(PNGObject.Pixels[X, Y]);
              Inc(PixelPtr);
            end;
          end;
          DstBitmap.OuterColor := TransparentColor;
          AlphaChannelUsed := True;
          DstBitmap.DrawMode := dmTransparent;
        end;
      ptmNone:
      begin
        PixelPtr := PColor32(@DstBitmap.Bits[0]);
        for Y := 0 to DstBitmap.Height - 1 do
        begin
          for X := 0 to DstBitmap.Width - 1 do
          begin
            PixelPtr^ := Color32(PNGObject.Pixels[X, Y]);
            Inc(PixelPtr);
          end;
        end;
        AlphaChannelUsed := False;
        DstBitmap.DrawMode := dmOpaque;
      end;
    end;
  finally
    FreeAndNil(PNGObject);
  end;
end;

{
function GetBitmap32ByPngImage(APngImage: TPngImage; ABackColor: TColor32 = $00000000; ABitmap32: TBitmap32 = nil): TBitmap32;
var
  AStream: TMemoryStream;
  Transparent: Boolean;
begin
  if ABitmap32 = nil then
    Result := TBitmap32.Create
  else
    Result := ABitmap32;

  AStream := TMemoryStream.Create;
  try
    APngImage.SaveToStream(AStream);
    AStream.Position := 0;
    LoadPNGintoBitmap32(Result, AStream, Transparent);
    //Result.SaveToFile('F:\1.bmp');
  finally
    AStream.Free;
  end;
end;
}

function GetBitmap32ByPngImage(APngImage: TPngImage; ABackColor: TColor32 = $00000000; ABitmap32: TBitmap32 = nil): TBitmap32;
var
  ATemp: TBitmap32;
begin
  if ABitmap32 = nil then
    Result := TBitmap32.Create
  else
    Result := ABitmap32;

  ATemp := TBitmap32.Create;
  try
    ATemp.SetSize(APngImage.Width, APngImage.Height);
    if ABackColor > 0 then ATemp.Clear(ABackColor);

    if not APngImage.Empty then
    begin
      if ABackColor = 0 then APngImage.OldMode := False;
      APngImage.Draw(ATemp.Canvas, Rect(0, 0, APngImage.Width, APngImage.Height));
      //if (APngImage.BitCount = 8) then ATemp.ResetAlpha(255);
    end;
    Result.Assign(ATemp);
  finally
    ATemp.Free;
  end;
end;

function GetBitmap32ByPngImage3(APngImage: TPngImage; ABackColor: TColor32 = $00000000; ABitmap32: TBitmap32 = nil): TBitmap32;
var
  p1: pngimage2.PByteArray;
  pa1: pngimage2.PByteArray;
  P2: PColor32EntryArray;
  ScanlineBytes, x, y: Integer;
begin
  if ABitmap32 = nil then
    Result := TBitmap32.Create
  else
    Result := ABitmap32;

  Result.SetSize(APngImage.Width, APngImage.Height);
  Result.Clear(ABackColor);

  ScanlineBytes := Integer(Result.ScanLine[1]) - Integer(Result.ScanLine[0]);
  P2 := PColor32EntryArray(Result.ScanLine[0]);
  for y := 0 to Result.Height - 1 do
  begin
    p1 := APngImage.Scanline[y];
    pa1 := APngImage.AlphaScanline[y];
    for x := 0 to Result.Width - 1 do
    begin
      P2[x].B := p1[3 * x];
      P2[x].G := p1[3 * x + 1];
      P2[x].R := p1[3 * x + 2];
      P2[x].A := pa1[x];
    end;
    Inc(Integer(P2), ScanlineBytes);
  end;
end;

function GetPngFromBitmap32(ABitmap32: TBitmap32): pngimage2.TPngImage;
var
  p1: pngimage2.PByteArray;
  pa1: pngimage2.PByteArray;
  P2: PColor32EntryArray;
  ScanlineBytes, x, y: Integer;
begin
  Result := pngimage2.TPngImage.CreateBlank(COLOR_RGBALPHA, 8, ABitmap32.Width, ABitmap32.Height);

  ScanlineBytes := Integer(ABitmap32.ScanLine[1]) - Integer(ABitmap32.ScanLine[0]);
  P2 := PColor32EntryArray(ABitmap32.ScanLine[0]);
  for y := 0 to Result.Height - 1 do
  begin
    p1 := Result.Scanline[y];
    pa1 := Result.AlphaScanline[y];
    for x := 0 to Result.Width - 1 do
    begin
      p1[3 * x] := P2[x].B;
      p1[3 * x + 1] := P2[x].G;
      p1[3 * x + 2] := P2[x].R;
      pa1[x] := P2[x].A;
    end;
    Inc(Integer(P2), ScanlineBytes);
  end;
end;
//*********************************************************
// convert Bitmap32 to PNG image
// input:   sourceBitmap      source bitmap 32 bit
//          paletted          =true: PixelFormat is pf8bit
//          transparent       =true: transparent pixels
//          bgColor           background color
//          compressionLevel  compression level, range 0..9, default = 9
//          interlaceMethod   interlaced method, use imNone or imAdam7
// return:  tPNGObject        PNG image object
//---------------------------------------------------------
function Bitmap32ToPNG (sourceBitmap: TBitmap32;
                         paletted, transparent: Boolean;
                         bgColor: TColor;
                         compressionLevel: TCompressionLevel = 9;
                         interlaceMethod: Vcl.Imaging.pngimage.TInterlaceMethod = Vcl.Imaging.pngimage.imNone):
Vcl.Imaging.pngimage.TPngImage;
var
   bm: TBitmap;
   png: Vcl.Imaging.pngimage.TPngImage;
   TRNS: Vcl.Imaging.pngimage.TCHUNKtRNS;
   p: Vcl.Imaging.pngimage.PByteArray;
   x, y: Integer;
begin
   Result := nil;
   png := Vcl.Imaging.pngimage.TPngImage.Create;
   try
     bm := TBitmap.Create;
     try
       bm.Assign (sourceBitmap);        // convert data into bitmap
       // force paletted on TBitmap, transparent for the web must be 8bit
       if paletted then
         bm.PixelFormat := pf8bit;
       png.interlaceMethod := interlaceMethod;
       png.compressionLevel := compressionLevel;
       png.Assign(bm);                  // convert bitmap into PNG
     finally
       FreeAndNil(bm);
     end;
     if transparent then begin
       if png.Header.ColorType in [COLOR_PALETTE] then begin
         if (png.Chunks.ItemFromClass(Vcl.Imaging.pngimage.TChunktRNS) = nil) then
            png.CreateAlpha;
         TRNS := png.Chunks.ItemFromClass(Vcl.Imaging.pngimage.TChunktRNS) as Vcl.Imaging.pngimage.TChunktRNS;
         if Assigned(TRNS) then TRNS.TransparentColor := bgColor;
       end;
       if png.Header.ColorType in [COLOR_RGB, COLOR_GRAYSCALE] then
          png.CreateAlpha;
       if png.Header.ColorType in [COLOR_RGBALPHA, COLOR_GRAYSCALEALPHA] then
       begin
         for y := 0 to png.Header.Height - 1 do begin
           p := png.AlphaScanline[y];
           for x := 0 to png.Header.Width - 1
           do p[x] := AlphaComponent(sourceBitmap.Pixel[x,y]);  //
         end;
       end;
     end;
     Result := png;
   except
     png.Free;
   end;
end;


function GetPng2(APngImage: Vcl.Imaging.pngimage.TPngImage) : TPngImage;
var
  AStream: TMemoryStream;
begin
  Result := TPngImage.Create;
  AStream := TMemoryStream.Create;
  try
    APngImage.SaveToStream(AStream);
    AStream.Position := 0;
    Result.LoadFromStream(AStream);
  finally
    AStream.Free;
  end;
end;

function GetPngFromBitmap(ABitmap32: TBitmap32; AWidth, AHeight: Integer; AHiQuality: Boolean): Vcl.Imaging.pngimage.TPngImage;
var
  p1: Vcl.Imaging.pngimage.PByteArray;
  pa1: Vcl.Imaging.pngimage.PByteArray;
  P2: PColor32EntryArray;
  ScanlineBytes, x, y: Integer;
  ABitmap: TBitmap32;
begin

  ResizeBitmap32(ABitmap32, AWidth, AHeight, AHiQuality);
  ScanlineBytes := Integer(ABitmap32.ScanLine[1]) - Integer(ABitmap32.ScanLine[0]);


  ABitmap32.DrawMode := dmCustom;
  ABitmap32.OnPixelCombine := GR32.TPixelCombine.PixelCombine;
  ABitmap32.DrawTo(ABitmap32, 0, 0);

  //Result := Bitmap32ToPNG(ABitmap32, false, true, 0);
  Result := Vcl.Imaging.pngimage.TPngImage.CreateBlank(COLOR_RGBALPHA, 8, AWidth, AHeight);
  P2 := PColor32EntryArray(ABitmap32.ScanLine[0]);
  for y := 0 to Result.Height - 1 do
  begin
    p1 := Result.Scanline[y];
    pa1 := Result.AlphaScanline[y];
    for x := 0 to Result.Width - 1 do
    begin
      p1[3 * x] := P2[x].B;
      p1[3 * x + 1] := P2[x].G;
      p1[3 * x + 2] := P2[x].R;
      pa1[x] := P2[x].A;
    end;
    Inc(Integer(P2), ScanlineBytes);
  end;
end;


function GetPng2FromBitmap(ABitmap32: TBitmap32; AWidth, AHeight: Integer; AHiQuality: Boolean): TPngImage;
var
  p1: PByteArray;
  pa1: PByteArray;
  P2: PColor32EntryArray;
  ScanlineBytes, x, y: Integer;
begin
  Result := TPngImage.CreateBlank(COLOR_RGBALPHA, 8, AWidth, AHeight);

  ResizeBitmap32(ABitmap32, AWidth, AHeight, AHiQuality);
  ScanlineBytes := Integer(ABitmap32.ScanLine[1]) - Integer(ABitmap32.ScanLine[0]);

  P2 := PColor32EntryArray(ABitmap32.ScanLine[0]);
  for y := 0 to Result.Height - 1 do
  begin
    p1 := Result.Scanline[y];
    pa1 := Result.AlphaScanline[y];
    for x := 0 to Result.Width - 1 do
    begin
      p1[3 * x] := P2[x].B;
      p1[3 * x + 1] := P2[x].G;
      p1[3 * x + 2] := P2[x].R;
      pa1[x] := P2[x].A;
    end;
    Inc(Integer(P2), ScanlineBytes);
  end;
end;

procedure ReverseBitmap32(ABitmap32: TBitmap32);
var
  P: PColor32EntryArray;
  ScanlineBytes, x, y: Integer;
begin
  ScanlineBytes := Integer(ABitmap32.ScanLine[1]) - Integer(ABitmap32.ScanLine[0]);

  P := PColor32EntryArray(ABitmap32.ScanLine[0]);
  for y := 0 to ABitmap32.Height - 1 do
  begin
    for x := 0 to ABitmap32.Width - 1 do
    begin
      P[x].B := 255 - P[x].B;
      P[x].G := 255 - P[x].G;
      P[x].R := 255 - P[x].R;
    end;
    Inc(Integer(P), ScanlineBytes);
  end;
end;

procedure ResizeBitmap32(ABitmap32: TBitmap32; AWidth, AHeight: Integer; AHiQuality: Boolean; AMiddleQuality: Boolean = False);
var
  ABMP: TBitmap32;
begin
  if (ABitmap32.Empty) or ((ABitmap32.Width = AWidth) and (ABitmap32.Height = AHeight)) then Exit;

  ABMP := TBitmap32.Create;
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
    else if AMiddleQuality then
    begin
      ABitmap32.ResamplerClassName := 'TLinearResampler';
    end
    else
    begin
      ABitmap32.ResamplerClassName := 'TDraftResampler';//'TLinearResampler';
    end;
    ABMP.SetSize(AWidth, AHeight);
    ABitmap32.DrawTo(ABMP, Rect(0, 0, ABMP.Width, ABMP.Height), Rect(0, 0, ABitmap32.Width, ABitmap32.Height));
    ABitmap32.Assign(ABMP);
  finally
    FreeAndNil(ABMP);
  end;
end;

{$endregion}

{$region 'TjinGIFImage'}
function TjinGIFImage.GetCount: Integer;
begin
  Result := FDelayTimes.Count
end;

function TjinGIFImage.GetBitmapByIndex(AIndex: Integer): TBitmap32;
begin
  if FBitmap = nil then FBitmap := TBitmap32.Create;
  FBitmap.SetSize(Width, Height);
  FBitmap.Clear($00000000);
  FGIF.ActiveImage := AIndex;
  ImagingComponents.DisplayImage(FBitmap.Canvas, Rect(0, 0, FGIF.Width, FGIF.Height), FGIF);
  Result := FBitmap;
end;

function TjinGIFImage.GetDelayByIndex(AIndex: Integer): Integer;
begin
  Result := FDelayTimes[AIndex];
end;

function TjinGIFImage.GetTotalDelayByIndex(AIndex: Integer): Integer;
var
  iLoop: Integer;
begin
  Result := 0;

  for iLoop := 0 to AIndex do
  begin
    Result := Result + FDelayTimes[iLoop];
  end;
end;

procedure TjinGIFImage.Clear;
begin
  FDelayTimes.Clear;
  while FBitmaps.Count > 0 do
  begin
    FBitmaps[0].Free;
    FBitmaps.Delete(0);
  end;

  FreeAndNil(Self.FBitmap);
  FreeAndNil(Self.FGIF);
end;

constructor TjinGIFImage.Create;
begin
  FBitmaps := TList<TBitmap32>.Create;
  FDelayTimes := TList<Integer>.Create;
  FWidth := 0;
  FHeight := 0;
end;

destructor TjinGIFImage.Destroy;
begin
  try
    Clear;
    FreeAndNil(FBitmaps);
    FreeAndNil(FDelayTimes);
    FreeAndNil(FBitmap);
    FreeAndNil(FGIF);
  finally
    inherited Destroy;
  end;
end;

procedure TjinGIFImage.LoadFromFile(AFile: String);
var
  iLoop,
  iCount,
  iDelay: Integer;
  GIFFormat: TImageFileFormat;
begin
  Clear;

  if FGIF = nil then
    FGIF := TMultiImage.Create;
  GIFFormat := FGIF.LoadMultiFromFileEx(AFile);
  if FGIF.Format <> ifA8R8G8B8 then FGIF.ConvertImages(ifA8R8G8B8);
  iCount := FGIF.ImageCount;
  FWidth := FGIF.Width;
  FHeight := FGIF.Height;
  for iLoop := 0 to iCount - 1 do
  begin
    iDelay := StrToInt(GIFFormat.DelayTimeLists[iLoop]);
    if iDelay = 1 then iDelay := 10;

    FDelayTimes.Add(iDelay * 10);
  end;
  GIFFormat.Free;
end;

procedure TjinGIFImage.LoadFromGIFImage(AGIFImage: TGIFImage);
begin

end;
{$endregion}

function GetFontBitmap(AFont: TFont): TBitmap32;
var
  AKey: String;
begin
  AKey := FontToString(AFont, False);
  if FontBitmaps.ContainsKey(AKey) then
  begin
    Result := FontBitmaps[AKey];
  end
  else
  begin
    Result := TBitmap32.Create;
    Result.SetSize(8, 8);
    Result.Canvas.Font.Assign(AFont);
    Result.Font.Assign(AFont);
    if (GR32_TEXT_NORMAL_FONT.Length > 0) and (GR32_TEXT_BOLD_FONT.Length > 0) and FreeTypeInited then
    begin
      Result.Font.Size := GetDPISize(Result.Font.Size);
    end;
    FontBitmaps.Add(AKey, Result);
  end;
end;

function GetTextHeight(AFont: TFont): Integer;
var
  AKey: String;
begin
  AKey := FontToString(AFont, False);
  if TextHeights.ContainsKey(AKey) then
  begin
    Result := TextHeights[AKey];
  end
  else
  begin
    Result := GetFontBitmap(AFont).TextExtent('中').Height;
    TextHeights.Add(AKey, Result);
  end;
end;

procedure ClearFontBitmaps;
var
  ABitmap: TBitmap32;
begin
  for ABitmap in FontBitmaps.Values do ABitmap.Free;
end;

procedure GetWindowDPI;
var
  DC: HDC;
begin
  DC := GetDC(0);
  WindowDPI := GetDeviceCaps(DC, logpixelsx);
  ReleaseDC(0, DC);
end;

procedure SetFontSize(AFont: TFont);
begin
  AFont.Height := -MulDiv(AFont.Size, WindowDPI, 72);
end;

procedure RestoreFontSize(AFont: TFont);
begin
  AFont.Size := -MulDiv(AFont.Height, 72, WindowDPI);
end;

function GetDPISize(ASize: Integer; ADPI: Integer): Integer; inline;
begin
  if ADPI > 72 then
    Result := MulDIV(ASize, ADPI, 72)
  else
    Result := ASize;
end;

function GetDPISize(ASize: Integer): Integer; inline;
begin
  if WindowDPI > DesignDPI then
    Result := MulDIV(ASize, WindowDPI, DesignDPI)
  else
    Result := ASize;
end;

function GetDesignSize(ASize: Integer): Integer; inline;
begin
  if WindowDPI > DesignDPI then
    Result := MulDIV(ASize, DesignDPI, WindowDPI)
  else
    Result := ASize;
end;

function GetDPIScale: Single; inline;
begin
  if WindowDPI > DesignDPI then
    Result := WindowDPI / DesignDPI
  else
    Result := 1.0;
end;

function Get2XImageFile(AFile: String): String;
var
  A2XFile: String;
begin
  if GetDPIScale < 1.5 then Exit(AFile);

  A2XFile := ExtractFilePath(AFile) +
                  IOUtils.TPath.GetFileNameWithoutExtension(ExtractFileName(AFile)) + '@2x' + ExtractFileExt(AFile);
  if FileExists(A2XFile) then
    Result := A2XFile
  else
    Result := AFile;
end;


function GetIfWin10: Boolean;
type
  pfnRtlGetVersion = function(var RTL_OSVERSIONINFOEXW): LongInt; stdcall;
var
  Buffer: PSERVER_INFO_101;
  ver: RTL_OSVERSIONINFOEXW;
  RtlGetVersion: pfnRtlGetVersion;
begin
  Result := False;
  Buffer := nil;
  try
    @RtlGetVersion := GetProcAddress(GetModuleHandle('ntdll.dll'), 'RtlGetVersion');
    if Assigned(RtlGetVersion) then
    begin
      ZeroMemory(@ver, SizeOf(ver));
      ver.dwOSVersionInfoSize := SizeOf(ver);

      if RtlGetVersion(ver) = 0 then
      begin
        if ver.dwMajorVersion >= 10 then Exit(True);
      end;
    end;


    if NetServerGetInfo(nil, 101, Buffer) = NO_ERROR then
    try
      if Buffer.sv101_version_major >= 10 then Exit(True);
    finally
      NetApiBufferFree(Buffer);
    end;
  except
  end;
end;

initialization
  AppQuiting := False;
  try
    NumberOfProcessors := TThread.ProcessorCount;
  except
    NumberOfProcessors := 1;
  end;

  VistaUP := CheckWin32Version(6, 0);
  Win7 := CheckWin32Version(6, 1);
  Win8 := CheckWin32Version(6, 2);
  if Win8 then
    Win10 := GetIfWin10
  else
    Win10 := False;

  EnableAnimate := (NumberOfProcessors >= MinNumberOfProcessors);
  EnableLayeredWindow := True;

  FontBitmaps := TDictionary<String, TBitmap32>.Create;
  TextHeights := TDictionary<String, Integer>.Create;

finalization
  ClearFontBitmaps;
  FreeAndNil(FontBitmaps);
  FreeAndNil(TextHeights);
end.
