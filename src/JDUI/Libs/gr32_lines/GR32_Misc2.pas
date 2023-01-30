unit GR32_Misc2;

(* BEGIN LICENSE BLOCK *********************************************************
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is GR32_Misc2.
 * The Initial Developer of the Original Code is Angus Johnson and is
 * Copyright (C) 2009-2010 the Initial Developer. All Rights Reserved.
 *
 * Version 3.92 (Last updated 10-Nov-2010)
 *
 * END LICENSE BLOCK **********************************************************)


interface

{$I GR32.inc}

{$IFDEF COMPILER7}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CAST OFF}
{$ENDIF}

//Use GDI+ if you wish to load or save images in formats other than BMP ...
//(ie JPG, GIF, PNG, TIF, WMF & EMF formats)
{$DEFINE USE_GDIPLUS}


uses
{$IFDEF USE_GDIPLUS}
  GDIPAPI,
{$ENDIF}
  Windows, Types, SysUtils, classes, ActiveX, Graphics, GR32;


{$IFNDEF UNICODE}
type
  UnicodeString = WideString;
{$ENDIF}

function LoadPicFromStream(stream: TStream; pic: TBitmap32): boolean;

function LoadPicFromFile(const picFile: UnicodeString; pic: TBitmap32): boolean;

function SavePicToStream(stream: TStream; pic: TBitmap32;
  format: string = ''): boolean; //format: 'bmp','jpg','png','gif' etc

function SavePicToFile(const picFile: UnicodeString; pic: TBitmap32): boolean;

{$IFDEF USE_GDIPLUS}

type
  TBitmapPage = class
  public
    Bitmap          : TBitmap32;
    Transparent     : boolean;
    TransparentColor: TColor32;
    DelayInterval   : integer;
    constructor Create;
    destructor Destroy; override;
  end;

  TGdipGraphic = class(TGraphic)
  private
    FBitmapList: TList;
    FCurrentBitmapIdx: integer;
    FLoopCount: integer;
    FFormat: string;
    function GetCurrentBitmap: TBitmap32;
    procedure SetCurrentBitmapIdx(index: integer);
    function GetBitmapCount: integer;
    function GetDelay: integer;
  protected
    procedure Draw(ACanvas: TCanvas; const Rect: TRect); override;
    function Equals(Graphic: TGraphic): Boolean; override;
    function GetEmpty: Boolean; override;
    function GetHeight: Integer; override;
    function GetTransparent: Boolean; override;
    function GetWidth: Integer; override;
    procedure SetHeight(Value: Integer); override;
    procedure SetTransparent(Value: Boolean); override;
    procedure SetWidth(Value: Integer); override;
    function GetTransparentColor: TColor32;
    procedure SetTransparentColor(value: TColor32);
    function AddBitmap: TBitmapPage;
    function CurrentBitmapPage: TBitmapPage;
  public
    constructor Create; override;
    destructor Destroy; override;
    procedure LoadFromFile(const Filename: string); override;
    procedure LoadFromStream(Stream: TStream); override;
    procedure LoadFromIStream(stream: IStream);
    procedure SaveToStream(Stream: TStream); override;
    procedure SaveToStreamUsingFormat(Stream: TStream; const format: string);
    procedure LoadFromClipboardFormat(AFormat: Word; AData: THandle;
      APalette: HPALETTE); override;
    procedure SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
      var APalette: HPALETTE); override;

    property Transparent: boolean read GetTransparent write SetTransparent;
    property TransparentColor: TColor32
      read GetTransparentColor write SetTransparentColor;

    procedure ClearBitmaps;
    procedure NextBitmap;
    procedure PriorBitmap;
    property Count: integer read GetBitmapCount;
    property CurrentBitmap: TBitmap32 read GetCurrentBitmap;
    property CurrentIndex: integer read FCurrentBitmapIdx write SetCurrentBitmapIdx;
    property CurrentDelayInterval: integer read GetDelay;
    property FileFormat: string read FFormat write FFormat;
    property LoopCount: integer read FLoopCount;
  end;

{$ENDIF}

implementation

uses Math;

{$IFDEF USE_GDIPLUS}

//------------------------------------------------------------------------------
// TStreamAdapterEx class
//------------------------------------------------------------------------------

type
  TStreamAdapterEx = class(TStreamAdapter)
  public
    function Stat(out statstg: TStatStg; grfStatFlag: DWORD): HResult; override; stdcall;
  end;

function TStreamAdapterEx.Stat(out statstg: TStatStg; grfStatFlag: DWORD): HResult;
begin
  Result := inherited Stat(statstg, grfStatFlag);
  statstg.pwcsName := nil;
end;

//------------------------------------------------------------------------------
// TBitmapPage methods ...
//------------------------------------------------------------------------------

constructor TBitmapPage.Create;
begin
  Bitmap := TBitmap32.Create;
  Bitmap.DrawMode := dmBlend;
end;
//------------------------------------------------------------------------------

destructor TBitmapPage.Destroy;
begin
  Bitmap.Free;
end;

//------------------------------------------------------------------------------
// Unit functions ...
//------------------------------------------------------------------------------

function LoadPicFromStreamGdiPlus(stream: TStream; pic: TBitmap32): boolean;
var
  StreamAdapter: IStream;
  bitmapData: TBitmapData;
  rec: TGPRect;
  gdipBitmap: pointer;
begin
  result := false;
  StreamAdapter := TStreamAdapterEx.Create(stream);
  try try
    gdipBitmap := nil;
    if GdipCreateBitmapFromStream(StreamAdapter, gdipBitmap) <> Ok then exit;
    rec.X := 0; rec.Y := 0;
    GdipGetImageWidth(gdipBitmap, UINT(rec.width));
    GdipGetImageHeight(gdipBitmap, UINT(rec.height));
    if GdipBitmapLockBits(gdipBitmap, @rec,
      ImageLockModeRead,PixelFormat32bppARGB, @bitmapData) = Ok then
    begin
      with bitmapData do
      begin
        pic.SetSize(Width, Height);
        move(Scan0^, pic.Bits^, Stride* integer(Height));
      end;
      GdipBitmapUnlockBits(gdipBitmap, @bitmapData);
      result := not pic.Empty;
    end;
    GdipDisposeImage(gdipBitmap);
  finally
    StreamAdapter := nil;
  end;
  except
    pic.Delete;
  end;
end;
//------------------------------------------------------------------------------

function LoadPicFromFileGdiPlus(const picFile: UnicodeString; pic: TBitmap32): boolean;
var
  bitmapData: TBitmapData;
  rec: TGPRect;
  gdipBitmap: pointer;
begin
  result := false;
  if not assigned(pic) or not FileExists(picFile) then exit;
  try
    gdipBitmap := nil;
    if GdipCreateBitmapFromFile(PWideChar(picFile), gdipBitmap) <> Ok then exit;
    rec.X := 0; rec.Y := 0;
    GdipGetImageWidth(gdipBitmap, UINT(rec.width));
    GdipGetImageHeight(gdipBitmap, UINT(rec.height));
    if GdipBitmapLockBits(gdipBitmap, @rec,
      ImageLockModeRead,PixelFormat32bppARGB, @bitmapData) = Ok then
    begin
      with bitmapData do
      begin
        pic.SetSize(Width, Height);
        move(Scan0^, pic.Bits^, Stride* integer(Height));
      end;
      GdipBitmapUnlockBits(gdipBitmap, @bitmapData);
      result := not pic.Empty;
    end;
    GdipDisposeImage(gdipBitmap);
  except
    pic.Delete;
  end;
end;
//------------------------------------------------------------------------------

//GetEncoderClsid - needed for saving a TGPImage to file
//see http://msdn.microsoft.com/en-us/library/ms533843%28VS.85%29.aspx
function GetEncoderClsid(const Format: WideString; var Clsid: TGUID): Boolean;
var
  i, num, size: cardinal;
  imageEncoders, encoderItem: PImageCodecInfo;
begin
  result := false;
  GdipGetImageEncodersSize(num, size);
  GetMem(imageEncoders, size);
  try
    GdipGetImageEncoders(num, size, imageEncoders);
    encoderItem := imageEncoders;
    for i := 0 to num - 1 do
    begin
      if Format = encoderItem.MimeType then
      begin
        Clsid := encoderItem.Clsid;
        result := true;
        exit;
      end;
      inc(encoderItem);
    end;
  finally
    FreeMem(imageEncoders);
  end;
end;
//------------------------------------------------------------------------------
{$ENDIF}

type
  TImageHeaderType = (htUnknown, htBmpFile, htBmpCore, htBmpInfo,
    htPng, htJpg, htGif, htTif, htEmf, htWmf, htIco);

function GetImageHeaderType(stream: TStream): TImageHeaderType;
var
  size: integer;
  buff: DWord;
begin
  result := htUnknown;
  size := stream.size - stream.Position;
  if size < 4 then exit;
  stream.Read(buff, sizeof(DWORD));
  stream.Seek(-sizeof(DWORD), soFromCurrent);
  if Buff = $474E5089 then result := htPng
  else if Buff = $38464947 then result := htGif
  else if LoWord(Buff) = $D8FF then result := htJpg
  else if LoWord(Buff) = $4D42 then result := htBmpFile
  else if (LoWord(Buff) = $4949) or (LoWord(Buff) = $4D4D) then result := htTif
  else if Buff = $1 then result := htEmf
  else if (Buff = $00090001) or (Buff = $9AC6CDD7) then result := htWmf
  else if (Buff = $00010000) then result := htIco
  else if Buff = sizeof(TBitmapInfoHeader) then result := htBmpInfo
  else if Buff = sizeof(TBitmapCoreHeader) then result := htBmpCore;
end;
//------------------------------------------------------------------------------

{$IFDEF USE_GDIPLUS}
function SavePicToStreamGdiPlus(stream: TStream; pic: TBitmap32; const format: string): boolean;
var
  ext: string;
  ImageHeaderType: TImageHeaderType;
  StreamAdapter: IStream;
  gdipBitmap: pointer;
  bitmapData: TBitmapData;
  rec: TGPRect;
  ClassID: TGUID;
begin
  result := false;
  if format = '' then
  begin
    ImageHeaderType := GetImageHeaderType(stream);
    case ImageHeaderType of
      htPng: ext := 'png';
      htJpg: ext := 'jpeg';
      htGif: ext := 'gif';
      htTif: ext := 'tif';
      htEmf: ext := 'emf';
      htWmf: ext := 'wmf';
      htIco: ext := 'icon';
      else ext := 'bmp';
    end;
  end
  else ext := format;

  if ext = 'jpg' then ext := 'jpeg'
  else if ext = 'tif' then ext := 'tiff'
  else if ext = 'ico' then ext := 'icon';
  ext := 'image/' + ext;
  if not assigned(pic) or not GetEncoderClsid(ext, ClassID) then exit;
  StreamAdapter := TStreamAdapterEx.Create(stream);
  try try
    if GdipCreateBitmapFromScan0(pic.Width,pic.Height,
      0,PixelFormat32bppARGB,nil,gdipBitmap) <> Ok then exit;

    rec.X := 0; rec.Y := 0; rec.Width := pic.Width; rec.Height := pic.Height;
    if GdipBitmapLockBits(gdipBitmap, @rec,
      ImageLockModeWrite,PixelFormat32bppARGB, @bitmapData) = Ok then
    begin
      with bitmapData do
      begin
        move(pic.Bits^, Scan0^, Stride* integer(Height));
      end;
      GdipBitmapUnlockBits(gdipBitmap, @bitmapData);
      result := GdipSaveImageToStream(gdipBitmap,
        StreamAdapter, @ClassID, nil) = Ok;
    end;
    GdipDisposeImage(gdipBitmap);
  finally
    StreamAdapter := nil;
  end;
  except
  end;
end;
//------------------------------------------------------------------------------

function SavePicToFileGdiPlus(const picFile: UnicodeString; pic: TBitmap32): boolean;
var
  ext: string;
  gdipBitmap: pointer;
  bitmapData: TBitmapData;
  rec: TGPRect;
  ClassID: TGUID;
begin
  result := false;
  ext := ExtractFileExt(picFile);
  if ext = '' then exit;
  delete(ext,1,1); //trims the period
  ext := lowercase(ext);
  if ext = 'jpg' then ext := 'jpeg'
  else if ext = 'tif' then ext := 'tiff';
  ext := 'image/' + ext;
  if not assigned(pic) or not GetEncoderClsid(ext, ClassID) then exit;
  if GdipCreateBitmapFromScan0(pic.Width,pic.Height,
    0,PixelFormat32bppARGB,nil,gdipBitmap) <> Ok then exit;
  rec.X := 0; rec.Y := 0; rec.Width := pic.Width; rec.Height := pic.Height;
  if GdipBitmapLockBits(gdipBitmap, @rec,
    ImageLockModeWrite,PixelFormat32bppARGB, @bitmapData) = Ok then
  begin
    with bitmapData do
    begin
      move(pic.Bits^, Scan0^, Stride* integer(Height));
    end;
    GdipBitmapUnlockBits(gdipBitmap, @bitmapData);
    if GdipSaveImageToFile(gdipBitmap,
      PWideChar(picFile), @ClassID, nil) = Ok then result := true;
  end;
  GdipDisposeImage(gdipBitmap);
end;
//------------------------------------------------------------------------------
{$ENDIF}

function LoadPicFromStreamGdi(stream: TStream; pic: TBitmap32): boolean;
var
  B: Graphics.TBitmap;
begin
  B := Graphics.TBitmap.Create;
  try try
    B.LoadFromStream(stream);
    pic.Assign(B);
  finally
    B.Free;
  end;
  except
    pic.Delete;
  end;
  result := not pic.Empty;
end;
//------------------------------------------------------------------------------

function LoadPicFromFileGdi(const picFile: UnicodeString; pic: TBitmap32): boolean;
var
  B: Graphics.TBitmap;
begin
  result := false;
  if not assigned(pic) or not FileExists(picFile) then exit;
  try
    B := Graphics.TBitmap.Create;
    try
      B.LoadFromFile(picFile);
      pic.Assign(B);
    finally
      B.Free;
    end;
  except
    pic.Delete;
  end;
end;
//------------------------------------------------------------------------------

function SavePicToFileGdi(const picFile: UnicodeString; pic: TBitmap32): boolean;
var
  ext: string;
begin
  ext := ExtractFileExt(picFile);
  ext := lowercase(ext);
  result := ext = '.bmp';
  if result then pic.SaveToFile(picFile);
end;
//------------------------------------------------------------------------------

function GetDInColors(BitCount: Word): Integer;
begin
  case BitCount of
    1, 4, 8: Result := 1 shl BitCount;
  else Result := 0;
  end;
end;
//------------------------------------------------------------------------------

function LoadPicFromStream(stream: TStream; pic: TBitmap32): boolean;
var
  size, ClrUsed: Integer;
  ImageHeaderType: TImageHeaderType;
  BH: PBitmapFileHeader;
  BI: PBitmapInfoHeader;
  BC: PBitmapCoreHeader;
  ms: TMemoryStream;
begin
  result := false;
  if not assigned(pic) or not assigned(stream) then exit;

  ImageHeaderType := GetImageHeaderType(stream);
  if ImageHeaderType in [htBmpInfo, htBmpCore] then
  begin
    //this stream is in BITMAP format but is missing its file header
    //(ie typically a resource stream). So, we need to fix that ...
    ms := TMemoryStream.Create;
    try try
      size := stream.Size - stream.Position;
      ms.SetSize(sizeof(TBitmapFileHeader)+ size);
      FillChar(ms.memory^, sizeof(TBitmapFileHeader), #0);
      ms.Seek(sizeof(TBitmapFileHeader), soFromBeginning);
      ms.CopyFrom(stream, size);
      ms.Position := 0;
      BH := PBitmapFileHeader(ms.memory);
      BH.bfType := $4D42;
      BH.bfSize := ms.Size;
      if ImageHeaderType = htBmpInfo then
      begin
        BI := PBitmapInfoHeader(PAnsiChar(BH)+sizeof(TBitmapFileHeader));
        //this next line should not be necessary but the occasional image has
        //omitted this size which is required whenever the image is compressed.
        if BI.biSizeImage = 0 then BI.biSizeImage := size;
        ClrUsed := BI.biClrUsed;
        if ClrUsed = 0 then
          ClrUsed := GetDInColors(BI.biBitCount);
        BH.bfOffBits :=  ClrUsed * SizeOf(TRgbQuad) +
          sizeof(TBitmapInfoHeader) + sizeof(TBitmapFileHeader);
      end
      else if ImageHeaderType = htBmpCore then
      begin
        BC := PBitmapCoreHeader(PAnsiChar(BH)+sizeof(TBitmapFileHeader));
        ClrUsed := GetDInColors(BC.bcBitCount);
        BH.bfOffBits :=  ClrUsed * SizeOf(TRGBTriple) +
          sizeof(TBitmapCoreHeader) + sizeof(TBitmapFileHeader);
      end;
      result := LoadPicFromStreamGdi(ms, pic);
    finally
      ms.Free;
    end;
    except
      pic.Delete;
    end;
    exit;
  end;

{$IFDEF USE_GDIPLUS}
  result := LoadPicFromStreamGdiPlus(stream, pic);
{$ELSE}
  result := LoadPicFromStreamGdi(stream, pic);
{$ENDIF}
end;
//------------------------------------------------------------------------------

function LoadPicFromFile(const picFile: UnicodeString; pic: TBitmap32): boolean;
begin
{$IFDEF USE_GDIPLUS}
  result := LoadPicFromFileGdiPlus(picFile, pic);
{$ELSE}
  result := (LowerCase(ExtractFileExt(picFile)) = '.bmp') and
    LoadPicFromFileGdi(picFile, pic);
{$ENDIF}
end;
//------------------------------------------------------------------------------

function SavePicToStream(stream: TStream; pic: TBitmap32; format: string = ''): boolean;
begin
  format := lowercase(format);
  if (format <> '') and (format[1] = '.') then delete(format,1,1);
{$IFDEF USE_GDIPLUS}
  result := SavePicToStreamGdiPlus(stream, pic, format);
{$ELSE}
  result := assigned(pic) and assigned(stream)
    and ((format = 'bmp') or (format = ''));
  if result then pic.SaveToStream(stream);
{$ENDIF}
end;
//------------------------------------------------------------------------------

function SavePicToFile(const picFile: UnicodeString; pic: TBitmap32): boolean;
begin
{$IFDEF USE_GDIPLUS}
  result := SavePicToFileGdiPlus(picFile, pic);
{$ELSE}
  result := SavePicToFileGdi(picFile, pic);
{$ENDIF}
end;
//------------------------------------------------------------------------------

{$IFDEF USE_GDIPLUS}
//------------------------------------------------------------------------------
// TGdipGraphic methods ...
//------------------------------------------------------------------------------

constructor TGdipGraphic.Create;
begin
  inherited;
  FBitmapList := TList.Create;
  FCurrentBitmapIdx := -1;
  FFormat := '';
end;
//------------------------------------------------------------------------------

destructor TGdipGraphic.Destroy;
begin
  ClearBitmaps;
  FBitmapList.Free;
  inherited;
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.ClearBitmaps;
var
  i: integer;
begin
  for i := 0 to FBitmapList.Count -1 do
    TBitmapPage(FBitmapList[i]).Free;
  FBitmapList.Clear;
  FCurrentBitmapIdx := -1;
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.NextBitmap;
begin
  if FBitmapList.Count < 2 then exit;
  inc(FCurrentBitmapIdx);
  if FCurrentBitmapIdx = FBitmapList.Count then
    FCurrentBitmapIdx := 0;
  Changed(self);
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.PriorBitmap;
begin
  if FBitmapList.Count < 2 then exit;
  dec(FCurrentBitmapIdx);
  if FCurrentBitmapIdx < 0 then
    FCurrentBitmapIdx := FBitmapList.Count-1;
  Changed(self);
end;
//------------------------------------------------------------------------------

function TGdipGraphic.GetBitmapCount: integer;
begin
  result := FBitmapList.Count;
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.SetCurrentBitmapIdx(index: integer);
begin
  if (index < 0) then index := 0
  else if index >= FBitmapList.Count then index := FBitmapList.Count -1;
  if (index = FCurrentBitmapIdx) or (FCurrentBitmapIdx < 0) then exit;
  FCurrentBitmapIdx := index;
end;
//------------------------------------------------------------------------------

function TGdipGraphic.GetCurrentBitmap: TBitmap32;
begin
  if (FCurrentBitmapIdx < 0) then
    result := nil else
    result := TBitmapPage(FBitmapList[FCurrentBitmapIdx]).Bitmap;
end;
//------------------------------------------------------------------------------

function TGdipGraphic.CurrentBitmapPage: TBitmapPage;
begin
  if (FCurrentBitmapIdx < 0) then
    result := nil else
    result := TBitmapPage(FBitmapList[FCurrentBitmapIdx]);
end;
//------------------------------------------------------------------------------

function TGdipGraphic.GetDelay: integer;
begin
  if (FCurrentBitmapIdx < 0) then
    result := 0 else
    result := TBitmapPage(FBitmapList[FCurrentBitmapIdx]).DelayInterval;
end;
//------------------------------------------------------------------------------

function TGdipGraphic.AddBitmap: TBitmapPage;
begin
  result := TBitmapPage.Create;
  FBitmapList.Add(result);
  if FCurrentBitmapIdx < 0 then  FCurrentBitmapIdx := 0;
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.LoadFromFile(const Filename: string);
begin
  inherited LoadFromFile(Filename);
  FFormat := ExtractFileExt(filename);
  if (FFormat <> '') and (FFormat[1] = '.') then delete(FFormat,1,1);
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.LoadFromStream(stream: TStream);
var
  cnt, size: integer;
  ImageHeaderType: TImageHeaderType;
  BH: PBitmapFileHeader;
  BI: PBitmapInfoHeader;
  BC: PBitmapCoreHeader;
  ms: TMemoryStream;

  procedure StreamToIStreamAndLoad(stream: TStream);
  var
    StreamAdapter: IStream;
  begin
    StreamAdapter := TStreamAdapterEx.Create(stream);
      try
        LoadFromIStream(StreamAdapter);
      finally
        StreamAdapter := nil;
      end;
  end;

begin

  //check on the type of stream ...
  ImageHeaderType := GetImageHeaderType(stream);
  case ImageHeaderType of
    htPng: FFormat := 'png';
    htJpg: FFormat := 'jpg';
    htGif: FFormat := 'gif';
    htTif: FFormat := 'tif';
    htEmf: FFormat := 'emf';
    htWmf: FFormat := 'wmf';
    htIco: FFormat := 'ico';
    else FFormat := 'bmp';
  end;

  if ImageHeaderType in [htBmpInfo, htBmpCore] then
  begin
    //this stream is in BITMAP format but is missing its file header
    //(ie typically bitmap resource streams). We need to fix that ...
    ms := TMemoryStream.Create;
    try
      size := stream.Size - stream.Position;
      ms.SetSize(sizeof(TBitmapFileHeader)+ size);
      FillChar(ms.memory^, sizeof(TBitmapFileHeader), #0);
      ms.Seek(sizeof(TBitmapFileHeader), soFromBeginning);
      ms.CopyFrom(stream, size);
      ms.Position := 0;
      BH := PBitmapFileHeader(ms.memory);
      BH.bfType := $4D42;
      BH.bfSize := ms.Size;
      if ImageHeaderType = htBmpInfo then
      begin
        BI := PBitmapInfoHeader(PAnsiChar(BH)+sizeof(TBitmapFileHeader));
        //this next line should not be necessary but the occasional image has
        //omitted this size which is required whenever the image is compressed.
        if BI.biSizeImage = 0 then BI.biSizeImage := size;
        cnt := BI.biClrUsed;
        if cnt = 0 then
          cnt := GetDInColors(BI.biBitCount);
        BH.bfOffBits :=  cnt * SizeOf(TRgbQuad) +
          sizeof(TBitmapInfoHeader) + sizeof(TBitmapFileHeader);
      end
      else if ImageHeaderType = htBmpCore then
      begin
        BC := PBitmapCoreHeader(PAnsiChar(BH)+sizeof(TBitmapFileHeader));
        cnt := GetDInColors(BC.bcBitCount);
        BH.bfOffBits :=  cnt * SizeOf(TRGBTriple) +
          sizeof(TBitmapCoreHeader) + sizeof(TBitmapFileHeader);
      end;
      StreamToIStreamAndLoad(ms);
    finally
      ms.Free;
    end;
  end
  else
    StreamToIStreamAndLoad(stream);
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.LoadFromIStream(stream: IStream);
var
  i, j, size: integer;
  bitmapData: TBitmapData;
  rec: TGPRect;
  gdipBitmap: pointer;
  cnt, pageCount, buffSize: cardinal;
  PropertyItem: PPropertyItem;
  GUIDs: array of TGUID;
  d: PCardinal;
  delays: array of cardinal;
  sFrameDimensionTimeGUID: string;
  pxlFormat: gdipapi.TPIXELFORMAT;
  ColorPalette: PColorPalette;
  C: PColor32Entry;
  IsAlphaPxlFmt, hasTimeDimension: boolean;
begin
  ClearBitmaps;

  if GdipCreateBitmapFromStream(stream, gdipBitmap) <> OK then exit;
  try
    GdipImageGetFrameDimensionsCount(gdipBitmap, cnt);
    SetLength(GUIDs, cnt);
    GdipImageGetFrameDimensionsList(gdipBitmap, @GUIDs[0], cnt);

    //get the number of bitmaps ...
    GdipImageGetFrameCount(gdipBitmap, @GUIDs[0], pageCount);

    //see if we need to get time delay intervals (ie animated GIFs) ...
    hasTimeDimension := false;
    sFrameDimensionTimeGUID := GUIDToString(FrameDimensionTime);
    for i := 0 to cnt -1 do
      if (GUIDToString(Guids[I]) = sFrameDimensionTimeGUID) then
      begin
        hasTimeDimension := true;
        break;
      end;

    SetLength(delays, pageCount);
    //get animation delay intervals and loop count (if needed) ...
    if hasTimeDimension then
    begin
      //first, get delays ...
      if (GdipGetPropertyItemSize(gdipBitmap,PropertyTagFrameDelay, buffSize) = OK) then
      begin
        GetMem(PropertyItem, buffSize);
        try
          if (GdipGetPropertyItem(gdipBitmap,
                PropertyTagFrameDelay, buffSize, PropertyItem) = OK) and
            (PropertyItem.length = sizeof(cardinal)*pageCount) then
          begin
            d := PCardinal(PropertyItem.value);
            for i := 0 to pageCount -1 do
            begin
              delays[i] := d^ *10;
              inc(d);
            end;
          end;
        finally
          FreeMem(PropertyItem);
        end;
      end;

      //now get loop count ...
      if (GdipGetPropertyItemSize(gdipBitmap,PropertyTagLoopCount, buffSize) = OK) then
      begin
        GetMem(PropertyItem, buffSize);
        try
          GdipGetPropertyItem(gdipBitmap, PropertyTagLoopCount, buffSize, PropertyItem);
          case PropertyItem.length of
            2: FLoopCount := Word(PropertyItem.value^);
            4: FLoopCount := Integer(PropertyItem.value^);
            else FLoopCount := 0;
          end;
        finally
          FreeMem(PropertyItem);
        end;
      end;
    end;

    //add the bitmap(s) ...
    for i := 0 to pageCount -1 do
      with AddBitmap do
      begin
        if GdipImageSelectActiveFrame(gdipBitmap, @GUIDs[0], i) <> OK then break;
        rec.X := 0; rec.Y := 0;
        GdipGetImageWidth(gdipBitmap, UINT(rec.width));
        GdipGetImageHeight(gdipBitmap, UINT(rec.height));
        if (GdipBitmapLockBits(gdipBitmap, @rec,
          ImageLockModeRead, PixelFormat32bppARGB, @bitmapData) = Ok) and
          (bitmapData.Stride = rec.Width *4) then
        try
          //todo - handle negative strides too (ie upside down images)
          with bitmapData do
          begin
            Bitmap.SetSize(Width, Height);
            move(Scan0^, Bitmap.Bits^, Stride* integer(Height));
          end;
        finally
          GdipBitmapUnlockBits(gdipBitmap, @bitmapData);
        end;
        if hasTimeDimension then DelayInterval := Delays[i];

        //check transparency ...
        GdipGetImagePixelFormat(gdipBitmap, pxlFormat);
        IsAlphaPxlFmt := IsAlphaPixelFormat(pxlFormat);
        if IsAlphaPxlFmt then
        begin
          {$R-}
          with Bitmap do
            for j := 0 to width * height -1 do
              if TColor32Entry(Bits[j]).A = 0 then
              begin
                Transparent := true;
                TransparentColor := TColor32Entry(Bits[j]).ARGB or $FF000000;
                break;
              end;
          {$R+}

        end
        else if IsIndexedPixelFormat(pxlFormat) then
        begin
          GdipGetImagePaletteSize(gdipBitmap, size);
          GetMem(ColorPalette, size);
          try
            GdipGetImagePalette(gdipBitmap, ColorPalette, size);
            if (ColorPalette.Flags and Cardinal(PaletteFlagsHasAlpha) <> 0) then
            begin
              C := @ColorPalette.Entries[0];
              for j := 0 to ColorPalette.Count -1 do
                if C.A = 0 then
                begin
                  Transparent := true;
                  TransparentColor := C^.ARGB or $FF000000;
                  break;
                end else
                  inc(C);
            end;
          finally
            FreeMem(ColorPalette);
          end;
        end;
      end;
  finally
    GdipDisposeImage(gdipBitmap);
  end;
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.SaveToStream(Stream: TStream);
begin
  if Count > 0 then
    SavePicToStreamGdiPlus(Stream,CurrentBitmap, FFormat);
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.SaveToStreamUsingFormat(Stream: TStream; const format: string);
begin
  if Count > 0 then
    SavePicToStreamGdiPlus(Stream,CurrentBitmap, format);
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.Draw(ACanvas: TCanvas; const Rect: TRect);
begin
  if not Empty then
    with CurrentBitmap do
      ACanvas.CopyRect(Rect, Canvas, classes.Rect(0,0,width,height));
end;
//------------------------------------------------------------------------------

function TGdipGraphic.Equals(Graphic: TGraphic): Boolean;
var
  i: integer;
  selfBits, graphicBits: PColor32;
begin
  if Empty then
    result := false
  else
    with CurrentBitmap do
    begin
      result := (Graphic is TGdipGraphic) and
        assigned(TGdipGraphic(Graphic).CurrentBitmap) and
        (TGdipGraphic(Graphic).Width = Width) and
        (TGdipGraphic(Graphic).Height = Height);
      if result then
      begin
        result := false;
        selfBits := PColor32(Bits);
        graphicBits := PColor32(TGdipGraphic(Graphic).CurrentBitmap.Bits);
        for i := 0 to Width * Height -1 do
        begin
          if selfBits^ <> graphicBits^ then exit;
          inc(selfBits);
          inc(graphicBits);
        end;
        result := true;
      end;
    end;
end;
//------------------------------------------------------------------------------

function TGdipGraphic.GetEmpty: Boolean;
begin
  result := not assigned(CurrentBitmap) or CurrentBitmap.Empty;
end;
//------------------------------------------------------------------------------

function TGdipGraphic.GetWidth: Integer;
begin
  if Empty then
    result := 0 else
    result := CurrentBitmap.Width;
end;
//------------------------------------------------------------------------------

function TGdipGraphic.GetHeight: Integer;
begin
  if Empty then
    result := 0 else
    result := CurrentBitmap.Height;
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.SetWidth(Value: Integer);
begin
  if assigned(CurrentBitmap) then
    CurrentBitmap.Width := max(0,Value);
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.SetHeight(Value: Integer);
begin
  if assigned(CurrentBitmap) then
    CurrentBitmap.Height := max(0,Value);
end;
//------------------------------------------------------------------------------

function TGdipGraphic.GetTransparent: Boolean;
begin
  if Empty then
    result := false else
    result := TBitmapPage(FBitmapList[FCurrentBitmapIdx]).Transparent;
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.SetTransparent(Value: Boolean);
var
  i: integer;
  c: TColor32;
begin
  if Empty then exit;
  with CurrentBitmapPage do
  begin
    if (Transparent = value) or Bitmap.Empty then exit;
    Transparent := value;
    {$R-}
    with Bitmap do
      if Transparent then
      begin
        c := TransparentColor and $00FFFFFF;
        for i := 0 to width * Height -1 do
          if Bits[i] and $00FFFFFF = c then Bits[i] := Bits[i] and $00FFFFFF;
      end else
      begin
        c := TransparentColor or $FF000000;
        for i := 0 to width * Height -1 do
          if Bits[i] or $FF000000 = c then Bits[i] := Bits[i] or $FF000000;
      end;
    {$R+}
  end;
  Changed(self);
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.LoadFromClipboardFormat(AFormat: Word; AData: THandle;
  APalette: HPALETTE);
var
  b: TBitmap;
begin
  if FCurrentBitmapIdx < 0 then AddBitmap;
  b := TBitmap.Create;
  with b do
  try
    b.LoadFromClipboardFormat(AFormat,AData, APalette);
    if not b.Empty then CurrentBitmap.Assign(b);
  finally
    b.Free;
  end;
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.SaveToClipboardFormat(var AFormat: Word; var AData: THandle;
  var APalette: HPALETTE);
var
  b: TBitmap;
begin
  if not assigned(CurrentBitmap) or CurrentBitmap.Empty then exit;
  b := TBitmap.Create;
  with b do
  try
    b.Assign(CurrentBitmap);
    b.SaveToClipboardFormat(AFormat, AData, APalette);
  finally
    b.Free;
  end;
end;
//------------------------------------------------------------------------------

function TGdipGraphic.GetTransparentColor: TColor32;
begin
  if Empty then result := $0
  else result := TBitmapPage(FBitmapList[FCurrentBitmapIdx]).TransparentColor;
end;
//------------------------------------------------------------------------------

procedure TGdipGraphic.SetTransparentColor(value: TColor32);
begin
  if Empty then exit;
  with TBitmapPage(FBitmapList[FCurrentBitmapIdx]) do
    if not Transparent then
      TransparentColor := value;
end;

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

var
  gdiplusToken: ULONG;

procedure GdiPlusInit;
var
  StartupInput: TGDIPlusStartupInput;
begin
  StartupInput.GdiplusVersion := 1;
  StartupInput.DebugEventCallback := nil;
  StartupInput.SuppressBackgroundThread := False;
  StartupInput.SuppressExternalCodecs   := False;
  if GdiplusStartup(gdiplusToken, @StartupInput, nil) <> OK then
    gdiplusToken := 0;
end;
//------------------------------------------------------------------------------

procedure RegisterGdipGraphics;
begin
  TPicture.RegisterFileFormat('PNG', 'Portable Network Graphics', TGdipGraphic);
  TPicture.RegisterFileFormat('GIF', 'Graphics Interchange Format', TGdipGraphic);
  TPicture.RegisterFileFormat('JPG', 'JPEG Graphics Format', TGdipGraphic);
  TPicture.RegisterFileFormat('TIF', 'Tagged Image File Format', TGdipGraphic);
end;
//------------------------------------------------------------------------------

procedure UnregisterGdipGraphics;
begin
  TPicture.UnregisterGraphicClass(TGdipGraphic);
end;
//------------------------------------------------------------------------------

{$IFDEF USE_GDIPLUS}
initialization
  GdiPlusInit;
  RegisterGdipGraphics;

finalization
  UnregisterGdipGraphics;
  if gdiplusToken <> 0 then GdiplusShutdown(gdiplusToken);
{$ENDIF}
{$ENDIF}

end.
