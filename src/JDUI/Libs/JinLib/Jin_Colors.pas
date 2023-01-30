{
文件名：JIN_Colors.pas
功  能：此单元定义了进行颜色变换，绘图等功能所必须的方法、过程。
建  立：尹进
历  史：
2005.12.23：补文件说明信息（尹进）
}
unit JIN_Colors;

interface

uses
  WinApi.Windows, WinApi.Messages, GIFImg, pngimage2, pngimage, Graphics, SysUtils, Math, Forms, Classes,
  ExtCtrls, iniFiles, GDIPlus, GDIPOBJ, GDIPAPI, jpeg;

const
   MaxPixelCount = 65536;

type

  TImageAbort = function(Data: Pointer): BOOL; stdcall;

  TIconDirEntry = packed record
    bWidth:Byte;
    bHeight:Byte;
    bColorCount:Byte;
    bReserved:Byte;
    wPlanes:Word;
    wBitCount:Word;
    dwBytesInRes:DWord;
    dwImageOffset:DWord;
  end;

  TIcondir = packed record
    idReserved:Word;
    idType:Word;
    idCount:Word;
    IdEntries:array[1..20] of TIconDirEntry;
  end;

  PRGBTripleArray = ^TRGBTripleArray;
  TRGBTripleArray = array[0..MaxPixelCount - 1] of TRGBTriple;

  TIconButtonState = (ibDown, ibUp, ibClear);

  procedure Grayscale(Const Bitmap:TBitmap);
  procedure PrintBitmap(aCanvas : TCanvas; Dest : TRect; Bitmap : TBitmap);

  function  ConvertBitmapToRTF(const Bitmap: TBitmap): string;
  procedure HSLtoRGB(H, S, L: Double; var R, G, B: Integer);
  procedure RGBtoHSL(R, G, B: Integer; var H, S, L: Double);
  function GetColorHues(AColor:  TColor): Double;
  function GetColorLighte(AColor:  TColor): Double;

  procedure ConvertPngToColorH(DestPng:TPngImage;DestColor:TColor);
  procedure ConvertPngToColorH2(DestPng: pngimage2.TPngImage;DestColor:TColor);
  procedure ConvertPngToColor(DestPng:  TPngImage;  DestColor:  TColor);
  procedure ConvertPngToColor2(DestPng: pngimage2.TPngImage;  DestColor:  TColor);
  procedure ConvertPngToColor3(DestPng: pngimage.TPngImage; DestColor:  TColor);
  procedure ConvertBitmapToColor(DestBitmap:TBitmap;DestColor:TColor);
  procedure ConvertBitmapHSL(DestBitmap:TBitmap; H, S, L: Integer);

  procedure ConvertBitmapToLighter(DestBitmap:TBitmap;FLightAdd:Integer);
  procedure ConvertBitmapToSaturation(DestBitmap:TBitmap;FSaturationAdd:Integer);
  procedure ConvertBitmapToHues(DestBitmap:TBitmap;FHueAdd:Integer);

  function ConvertColorToColor(SourceColor: TColor; DestColor: TColor): TColor;
  function ConvertColorToLighter(SourceColor: TColor; FLightAdd:Integer): TColor;
  function GetBitmapColor(DestBitmap:TBitmap):TColor;

  //平均模糊
  procedure SmoothAverage(SrcBitmap: TBitmap; TargetBitmap: TBitmap; iBlockLen: Integer);
  procedure SmoothAverage2(SrcBitmap: TBitmap; ARect: TRect; iBlockLen: Integer);

  //从位图获取路径
  function GetRegionFromBitmap(StartX, StartY: Integer; DestBitmap:TBitmap; TransparentColor: TColor): HRGN;

  //拉幕方式显示位置
  procedure AnimateShowBitmap(SrcBMP: TBitmap; DestBMP: TBitmap);

  //对图片进行大小变换
  function GetSmallBitmap(AFileName: String; ANewWidth, ANewHeight: Integer; AKeepScale: Boolean = False; AKeepSize: Boolean = True): TBitmap;
  function GetSmallBitmap2(AFileName: String; ANewWidth, ANewHeight: Integer; SrcRect: TRect): TBitmap;
  function GetJpegFromBitmap(ABitmap: TBitmap): TJpegImage;

  //绘制按钮的边框
  procedure DrawIconButton(ACanvas: TCanvas; ADefaultColor, ALightColor, AShadownColor: TColor;
    ARect: TRect; AIconButtonState: TIconButtonState);

  //透明方式绘制图片
  function TransparentBlt2(hdcDest:HDC;nXOriginDest,nYOriginDest,
                         nWidthDest,hHeightDest:integer;
                         hdcSrc:HDC;nXOriginSrc,nYOriginSrc,
                         nWidthSrc,nHeightSrc:integer;
                         crTransparent:UINT):BOOL;stdcall;
  procedure SaveBmpAsIcon(const Bmp: TBitmap; const Icon: string; const SmallIcon: Boolean;
    const Transparent: Boolean; const X, Y: Integer);

  function PrintWindow(SourceWindow: hwnd; Destination: hdc; nFlags: cardinal): bool; stdcall; external 'user32.dll' name 'PrintWindow';

  procedure ZoomBmp(SrcBitmap, DestBitmap: TBitmap; const NewWidth, NewHeight: Integer);
  procedure ZoomGIF(ASrcFileName, ADstFileName: String; ANewWidth, ANewHeight: Integer);
  procedure CopyImageFromHandle(wnd: cardinal; const Abmp: TBitmap);

  procedure GetPngImageByMask(APng, APngMask: TPngImage);

var
  LastConvertColor: TColor;


implementation

var
  AbortSubSize: Integer = 256;

procedure GetThumbnailImage(DC: HDC; AFile: String; AWidth, AHeight: Integer);
var
    graphics: TGPGraphics;
    Image, pThumbnail: TGPImage;
begin
    graphics := TGPGraphics.Create(DC);
    Image := TGPImage.Create(AFile);   //图片
    pThumbnail := image.GetThumbnailImage(AWidth, AHeight, nil, nil);   //创建60   *   48   的缩略图
    graphics.DrawImage(pThumbnail, 0, 0, pThumbnail.GetWidth, pThumbnail.GetHeight);   //画出来
    Image.Free;
    pThumbnail.Free;
    graphics.Free;
end;

procedure SwapRGB(var a, b: Integer);
begin
  Inc(a, b);
  b := a - b;
  Dec(a, b);
end;

procedure CheckRGB(var Value: Integer);
begin
  if Value < 0 then Value := 0
  else if Value > 255 then Value := 255;
end;

procedure AssignRGB(var R, G, B: Byte; intR, intG, intB: Integer);
begin
  R := intR;
  G := intG;
  B := intB;
end;

procedure SetBright(var R, G, B: Byte; bValue: Integer);
var
  intR, intG, intB: Integer;
begin
  intR := R;
  intG := G;
  intB := B;
  if bValue > 0 then
  begin
    Inc(intR, (255 - intR) * bValue div 255);
    Inc(intG, (255 - intG) * bValue div 255);
    Inc(intB, (255 - intB) * bValue div 255);
  end
  else if bValue < 0 then
  begin
    Inc(intR, intR * bValue div 255);
    Inc(intG, intG * bValue div 255);
    Inc(intB, intB * bValue div 255);
  end;
  CheckRGB(intR);
  CheckRGB(intG);
  CheckRGB(intB);
  AssignRGB(R, G, B, intR, intG, intB);
end;

procedure SetHueAndSaturation(var R, G, B: Byte; hValue, sValue: Integer);
var
  intR, intG, intB: Integer;
  H, S, L, Lum: Integer;
  delta, entire: Integer;
  index, extra: Integer;
begin
  intR := R;
  intG := G;
  intB := B;

  if intR < intG then SwapRGB(intR, intG);
  if intR < intB then SwapRGB(intR, intB);
  if intB > intG then SwapRGB(intB, intG);

  delta := intR - intB;
  if delta = 0 then Exit;

  entire := intR + intB;
  L := entire shr 1;
  if L < 128 then
    S := delta * 255 div entire
  else
    S := delta * 255 div (510 - entire);
  if hValue <> 0 then
  begin
    if intR = R then
      H := (G - B) * 60 div delta
    else if intR = G then
      H := (B - R) * 60 div delta + 120
    else
      H := (R - G) * 60 div delta + 240;
    Inc(H, hValue);
    if H < 0 then
      Inc(H, 360)
    else if H > 360 then
      Dec(H, 360);
    index := H div 60;
    extra := H mod 60;
    if (index and 1) <> 0 then
      extra := 60 - extra;
    extra := (extra * 255 + 30) div 60;
    intG := extra - (extra - 128) * (255 - S) div 255;
    Lum := L - 128;
    if Lum > 0 then
      Inc(intG, (((255 - intG) * Lum + 64) div 128))
    else if Lum < 0 then
      Inc(intG, (intG * Lum div 128));
    CheckRGB(intG);
    case index of
      1: SwapRGB(intR, intG);
      2:
      begin
        SwapRGB(intR, intB);
        SwapRGB(intG, intB);
      end;
      3: SwapRGB(intR, intB);
      4:
      begin
        SwapRGB(intR, intG);
        SwapRGB(intG, intB);
      end;
      5: SwapRGB(intG, intB);
    end;
  end
  else
  begin
    intR := R;
    intG := G;
    intB := B;
  end;
  if sValue <> 0 then
  begin
    if sValue > 0 then
    begin
      if sValue + S >= 255 then sValue := S
      else sValue := 255 - sValue;
      sValue := 65025 div sValue - 255;
    end;
    Inc(intR, ((intR - L) * sValue div 255));
    Inc(intG, ((intG - L) * sValue div 255));
    Inc(intB, ((intB - L) * sValue div 255));
    CheckRGB(intR);
    CheckRGB(intG);
    CheckRGB(intB);
  end;
  AssignRGB(R, G, B, intR, intG, intB);
end;

function _CheckRgb(Rgb: Integer): Integer;
asm
    test    eax, eax
    jge     @@1
    xor     eax, eax
    ret
@@1:
    cmp     eax, 255
    jle     @@2
    mov     eax, 255
@@2:
end;

function ImageSetAbortBlockSize(Size: Integer): Integer;
begin
  Result := AbortSubSize;
  if Size > 0 then
    AbortSubSize := Size;
end;

procedure CopyImageFromHandle(wnd: cardinal; const Abmp: TBitmap);
var
  rec: TRect;
  FCanvas:TCanvas;
  DC:HDC;
begin
  GetWindowRect(wnd, rec);
  try
    Abmp.SetSize(rec.Right - rec.Left, rec.Bottom - rec.Top);

    FCanvas := TCanvas.Create();
    DC := GetDC(0);
    try
      FCanvas.Handle := DC;
      Abmp.Canvas.CopyRect(Rect(0,0, Abmp.Width, Abmp.Height),
                              FCanvas,
                              Rect(rec.Left, rec.Top, rec.Right, rec.Bottom));
    finally
      FCanvas.Free;
      ReleaseDC (0, DC);
    end;
  finally
  end;
end;

procedure ZoomBmp(SrcBitmap, DestBitmap: TBitmap; const NewWidth, NewHeight: Integer);
var
  Bmp: TBitmap;
begin
  Bmp := TBitmap.Create;
  try
    Bmp.Width := NewWidth;
    Bmp.Height := NewHeight;
    SetStretchBltMode(Bmp.Canvas.Handle, HALFTONE); //加此句效果好
    StretchBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
      SrcBitmap.Canvas.Handle, 0, 0, SrcBitmap.Width, SrcBitmap.Height, SRCCOPY);
    DestBitmap.Assign(Bmp);
  finally
    if Assigned(Bmp) then
      Bmp.Free;
  end;
end;

procedure ZoomGIF(ASrcFileName, ADstFileName: String; ANewWidth, ANewHeight: Integer);
var
  AGIFImage: TGIFImage;
  AGIFImage2: TGIFImage;
  i: Integer;
  AFrame: TGIFFrame;
begin
  AGIFImage := TGIFImage.Create;
  AGIFImage2 := TGIFImage.Create;
  try
    AGIFImage.LoadFromFile(ASrcFileName);
    for i := 0 to AGIFImage.Images.Count - 1 do
    begin
      ZoomBmp(AGIFImage.Images[i].Bitmap, AGIFImage.Images[i].Bitmap, ANewWidth, ANewHeight);
      AFrame := TGIFFrame.Create(AGIFImage2);
      AFrame.Assign(AGIFImage.Images[i].Bitmap);
      AGIFImage2.Images.Add(AFrame);
    end;

    AGIFImage2.Width := ANewWidth;
    AGIFImage2.Height := ANewHeight;
    AGIFImage2.SaveToFile(ADstFileName);
  finally
    if Assigned(AGIFImage) then
      AGIFImage.Free;
    if Assigned(AGIFImage2) then
      AGIFImage2.Free;
  end;
end;



procedure SaveBmpAsIcon(const Bmp: TBitmap; const Icon: string; const SmallIcon: Boolean;
const Transparent: Boolean; const X, Y: Integer);
//  Bmp        : Bitmap图片
//  Icon       : 最终输出的icon文件全路径和文件名。如果文件已经存在则会将其覆盖
//  SmallIcon  : True: 16x16 图标, False: 32x32 图标
//  Transparent: 确定是否按照参数X,Y的坐标色生成透明图标
//  X, Y       : 此参数指明坐标下的色值将会作为透明色替换全图
var
  PBI, MPBI: PBitmapInfo;
  IHS, MIHS, ImageSize, MImageSize: DWord;
  bmBuffer, MaskBuffer: Pointer;
  TID: TIconDir;
  TBIH: TBitmapInfoHeader;
  Bmx, Bmm: TBitmap;
  TranspCol: TColor;
  I, J: Integer;
begin
  Bmx:= TBitmap.Create;
  Bmm:= TBitmap.Create;
  try
    if SmallIcon then
    begin
      Bmx.Width:= GetSystemMetrics(SM_CXSMICON);
      Bmx.Height:= GetSystemMetrics(SM_CYSMICON);
    end
    else
    begin
      Bmx.Width:= GetSystemMetrics(SM_CXICON);
      Bmx.Height:= GetSystemMetrics(SM_CYICON);
    end;

    bmx.pixelformat := pf24bit;
    Bmx.Canvas.StretchDraw(Rect(0, 0, Bmx.Width, Bmx.Height), Bmp);
    TranspCol:= Bmx.Canvas.Pixels[X, Y];
    Bmm.Assign(Bmx);
    Bmm.Mask(TranspCol);
    GetDIBSizes(Bmm.Handle, MIHS, MImageSize);
    GetDIBSizes(Bmx.Handle, IHS, ImageSize);
    MaskBuffer:= AllocMem(MImageSize);
    bmBuffer:= AllocMem(ImageSize);
    MPBI:= AllocMem(MIHS);
    PBI:= AllocMem(IHS);
    try
      if Transparent then
      begin
        for I:=0 to Bmx.Width-1 do
          for J:=0 to Bmx.Height-1 do
            if Bmx.Canvas.Pixels[I, J] = TranspCol then
              Bmx.Canvas.Pixels[I, J]:= 0;

        with MPBI^.bmiHeader do
        begin
          biSize:= SizeOf(TBitmapInfoHeader);
          biWidth:= Bmm.Width;
          biHeight:= Bmm.Height;
          biPlanes:= 1;
          biBitCount:= 1;
          biCompression:= BI_RGB;
          biSizeImage:= MImageSize;
          biXPelsPerMeter:= 0;
          biYPelsPerMeter:= 0;
          biClrUsed:= 2;
          biClrImportant:= 2;
        end;

        GetDIBits(Bmm.Canvas.Handle, Bmm.Handle, 0, Bmm.height, MaskBuffer, MPBI^, DIB_RGB_COLORS);
      end;

      with PBI^.bmiHeader do
      begin
        biSize:= SizeOf(TBitmapInfoHeader);
        biWidth:= Bmx.Width;
        biHeight:= Bmx.Height;
        biPlanes:= 1;
        biBitCount:= 24;
        biCompression:= BI_RGB;
        biSizeImage:= ImageSize;
        biXPelsPerMeter:= 0;
        biYPelsPerMeter:= 0;
        biClrUsed:= 0;
        biClrImportant:= 0;
      end;

      GetDIBits(Bmx.Canvas.Handle, Bmx.Handle, 0, Bmx.Height, bmBuffer, PBI^, DIB_RGB_COLORS);
      with TBIH do
      begin
        biSize:= 40;
        biWidth:= Bmx.Width;
        biHeight:= Bmx.Height * 2;
        biPlanes:= 1;
        biBitCount:= 24;
        biCompression:= 0;
        biSizeImage:= ImageSize;
        biXPelsPerMeter:= 0;
        biYPelsPerMeter:= 0;
        biClrUsed:= 0;
        biClrImportant:= 0;
      end;

      with TID do
      begin
        idReserved:=0;
        idType:=1;
        idCount:=1;
        with idEntries[1] do
        begin
          bWidth:=bmx.width;
          bHeight:=bmx.height;
          bColorCount:=0;
          bReserved:=0;
          wPlanes:=1;
          wBitCount:=24;
          dwBytesInRes:= SizeOf(TBitmapInfoHeader) + TBIH.biSizeImage + MImageSize;
          dwImageOffset:= 6 + TID.idCount * SizeOf(TIconDirEntry);
        end;
      end;

      with TFileStream.Create(Icon, fmCreate) do
      try
        Write(TID, 6 + TID.idCount * SizeOf(TIconDirEntry));
        Write(TBIH, SizeOf(TBitmapInfoheader));
        Write(bmBuffer^, TBIH.biSizeImage);
        Write(maskBuffer^, MImageSize);
      finally
        Free;
      end;
    finally
      FreeMem(MaskBuffer);
      FreeMem(bmBuffer);
      FreeMem(MPBI);
      FreeMem(PBI);
    end;
  finally
    Bmx.free;
    Bmm.free;
  end;
end;

function TransparentBlt2(hdcDest:HDC;nXOriginDest,nYOriginDest,
                         nWidthDest,hHeightDest:integer;
                         hdcSrc:HDC;nXOriginSrc,nYOriginSrc,
                         nWidthSrc,nHeightSrc:integer;
                         crTransparent:UINT):BOOL;stdcall;
var
  hdcMem,hdcBack,hdcObject,hdcSave,hdcTemp:HDC;
  bmAndBack,bmAndObject,bmAndMem,bmSave:HBITMAP;
  bmBackOld,bmObjectOld,bmMemOld,bmSaveOld:HBITMAP;
  cColor:COLORREF;
  bm:HBITMAP;
begin
  hdcTemp := CreateCompatibleDC(hdcSrc);
  bm:=CreateCompatibleBitmap(hdcSrc,nWidthSrc,nHeightSrc);
  SelectObject(hdcTemp,bm);

  BitBlt(hdcTemp,0,0,nWidthSrc,nHeightSrc,hdcSrc,nXOriginSrc,nYOriginSrc,SRCCOPY);

  hdcBack := CreateCompatibleDC(hdcDest);
  hdcObject := CreateCompatibleDC(hdcDest);
  hdcMem := CreateCompatibleDC(hdcDest);
  hdcSave := CreateCompatibleDC(hdcDest);

  bmAndBack := CreateBitmap(nWidthSrc,nHeightSrc,1,1,nil);
  bmAndObject := CreateBitmap(nWidthSrc,nHeightSrc,1,1,nil);
  bmAndMem := CreateCompatibleBitmap(hdcDest,nWidthSrc,nHeightSrc);
  bmSave := CreateCompatibleBitmap(hdcDest,nWidthSrc,nHeightSrc);

  bmBackOld := SelectObject(hdcBack, bmAndBack);
  bmObjectOld := SelectObject(hdcObject, bmAndObject);
  bmMemOld := SelectObject(hdcMem, bmAndMem);
  bmSaveOld := SelectObject(hdcSave, bmSave);

  SetMapMode(hdcTemp,GetMapMode(hdcDest));
  BitBlt(hdcSave,0,0,nWidthSrc,nHeightSrc,hdcTemp,0,0,SRCCOPY);

  cColor := SetBkColor(hdcTemp, crTransparent);
  BitBlt(hdcObject,0,0,nWidthSrc,nHeightSrc,hdcTemp,0,0,SRCCOPY);

  SetBkColor(hdcTemp,cColor);
  BitBlt(hdcBack,0,0,nWidthSrc,nHeightSrc,hdcObject,0,0,NOTSRCCOPY);

  BitBlt(hdcMem,0,0,nWidthSrc,nHeightSrc,hdcDest,nXOriginDest,nYOriginDest,SRCCOPY);
  BitBlt(hdcMem,0,0,nWidthSrc,nHeightSrc,hdcObject,0,0,SRCAND);
  BitBlt(hdcTemp,0,0,nWidthSrc,nHeightSrc,hdcBack,0,0,SRCAND);
  BitBlt(hdcMem,0,0,nWidthSrc,nHeightSrc,hdcTemp,0,0,SRCPAINT);
  BitBlt(hdcDest,nXOriginDest,nYOriginDest,nWidthSrc,nHeightSrc,hdcMem,0,0,SRCCOPY);
  BitBlt(hdcTemp,0,0,nWidthSrc,nHeightSrc,hdcSave,0,0,SRCCOPY);

  DeleteObject(SelectObject(hdcBack, bmBackOld));
  DeleteObject(SelectObject(hdcObject, bmObjectOld));
  DeleteObject(SelectObject(hdcMem, bmMemOld));
  DeleteObject(SelectObject(hdcSave, bmSaveOld));
  DeleteObject(bm);

  DeleteDC(hdcMem);
  DeleteDC(hdcBack);
  DeleteDC(hdcObject);
  DeleteDC(hdcSave);
  DeleteDC(hdcTemp);

  Result:=BOOL(1);
end;

//------------------------------------------------------------------------------
procedure DrawIconButton(ACanvas: TCanvas; ADefaultColor, ALightColor, AShadownColor: TColor;
  ARect: TRect; AIconButtonState: TIconButtonState);
begin
    //------------------
    if AIconButtonState = ibClear then
      ACanvas.Pen.Color := ADefaultColor
    else if AIconButtonState = ibDown then
      ACanvas.Pen.Color := AShadownColor
    else
      ACanvas.Pen.Color := ALightColor;

    ACanvas.MoveTo(ARect.Left, ARect.Top + 1);
    ACanvas.LineTo(ARect.Left, ARect.Bottom - 1);

    ACanvas.MoveTo(ARect.Left + 1, ARect.Top);
    ACanvas.LineTo(ARect.Right - 1, ARect.Top);

    //------------------
    //------------------
    if AIconButtonState = ibClear then
      ACanvas.Pen.Color := ADefaultColor
    else if AIconButtonState = ibDown then
      ACanvas.Pen.Color := ALightColor
    else
      ACanvas.Pen.Color := AShadownColor;

    ACanvas.MoveTo(ARect.Right - 1, ARect.Top + 1);
    ACanvas.LineTo(ARect.Right - 1, ARect.Bottom  - 1);

    ACanvas.MoveTo(ARect.Right - 2, ARect.Bottom  - 1);
    ACanvas.LineTo(ARect.Left, ARect.Bottom - 1);
end;

function GetJpegFromBitmap(ABitmap: TBitmap): TJpegImage;
Var
  Jpg : TJpegImage;
begin
  Jpg :=TJpegImage.Create;
  Jpg.Assign(ABitmap);
  Exit(Jpg);
end;

function GetSmallBitmap2(AFileName: String; ANewWidth, ANewHeight: Integer; SrcRect: TRect): TBitmap;
var
  Bitmap2: TBitmap;
  g: TGPGraphics;
  img: TGPImage;
  rt: TGPRect;
begin
  Result := nil;

  Bitmap2 := TBitmap.Create;
  Bitmap2.SetSize(ANewWidth, ANewHeight);
  try
    try
      g := TGPGraphics.Create(Bitmap2.Canvas.Handle);
      try
        img := TGPImage.Create(AFileName);
        try
          rt := MakeRect(0, 0, ANewWidth, ANewHeight);
          g.SetInterpolationMode(InterpolationModeHighQualityBicubic);
          g.DrawImage(img, rt, SrcRect.Left, SrcRect.Top, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, UnitPixel);
        finally
          FreeAndNil(img);
        end;
      finally
        FreeAndNil(g);
      end;
      Result := Bitmap2;
    except
    end;
  finally
    if Result = nil then Bitmap2.Free;
  end;
end;

//------------------------------------------------------------------------------
function GetSmallBitmap(AFileName: String; ANewWidth, ANewHeight: Integer; AKeepScale: Boolean = False; AKeepSize: Boolean = True): TBitmap;
var
  Bitmap2: TBitmap;

  Rect2: TRect;
  g: TGPGraphics;
  img: TGPImage;
  rt: TGPRect;
begin
  Result := nil;

  Bitmap2 := TBitmap.Create;
  Bitmap2.SetSize(ANewWidth, ANewHeight);
  try
    g := TGPGraphics.Create(Bitmap2.Canvas.Handle);
    try
      img := TGPImage.Create(AFileName);
      try
      if AKeepSize and (img.GetWidth < ANewWidth) and (img.GetHeight < ANewHeight) and (AKeepScale) then
      begin
        Rect2.Left := (ANewWidth - img.GetWidth) div 2;
        Rect2.Top := (ANewHeight - img.GetHeight) div 2;
        Rect2.Right := Rect2.Left + img.GetWidth;
        Rect2.Bottom := Rect2.Top + img.GetHeight;
      end
      else
      begin
        if not AKeepScale then
        begin
          Rect2.Left := 0;
          Rect2.Top := 0;
          Rect2.Right := ANewWidth;
          Rect2.Bottom := ANewHeight;
        end
        else
        begin
          if img.GetWidth > img.GetHeight then
          begin
            Rect2.Left := 0;
            Rect2.Right := ANewWidth;
            Rect2.Bottom := Round(ANewWidth * (img.GetHeight / img.GetWidth));
            Rect2.Top := (ANewHeight - Rect2.Bottom) div 2;
            Rect2.Bottom := Rect2.Bottom + Rect2.Top;
          end
          else
          begin
            Rect2.Top := 0;
            Rect2.Bottom := ANewHeight;
            Rect2.Right := Round(ANewHeight * (img.GetWidth / img.GetHeight));
            Rect2.Left := (ANewWidth - Rect2.Right) div 2;
            Rect2.Right := Rect2.Right + Rect2.Left;
          end
        end;
      end;

      rt := MakeRect(Rect2.Left, Rect2.Top, Rect2.Right - Rect2.Left, Rect2.Bottom - Rect2.Top);
      g.SetInterpolationMode(2);
      if not AKeepScale then
      begin
        if img.GetWidth > img.GetHeight then
        begin
          g.DrawImage(img, rt, (img.GetWidth - img.GetHeight) div 2, 0, img.GetHeight, img.GetHeight, UnitPixel)
        end
        else
        begin
          g.DrawImage(img, rt, 0, (img.GetHeight - img.GetWidth) div 2, img.GetWidth, img.GetWidth, UnitPixel)
        end;
      end
      else
      begin
        g.DrawImage(img, rt, 0, 0, img.GetWidth, img.GetHeight, UnitPixel);
      end;

      {
      if True or (LimitRight <= 0) or (LimitBottom <= 0) or ((LimitLeft < Rect2.Left) and (LimitTop < Rect2.Top)) then
      begin
        rt := MakeRect(Rect2.Left, Rect2.Top, Rect2.Right - Rect2.Left, Rect2.Bottom - Rect2.Top);
        g.SetInterpolationMode(InterpolationModeHighQualityBicubic);
        g.DrawImage(img, rt, 0, 0, img.GetWidth, img.GetHeight, UnitPixel);
      end
      else
      begin
        if LimitLeft < Rect2.Left then LimitLeft := Rect2.Left;
        if LimitTop < Rect2.Top then LimitTop := Rect2.Top;
        if LimitRight > Rect2.Right then LimitRight := Rect2.Right;
        if LimitBottom > Rect2.Bottom then LimitBottom := Rect2.Bottom;

        rt := MakeRect(LimitLeft, LimitTop, LimitRight - LimitLeft, LimitBottom - LimitTop);
        g.SetInterpolationMode(InterpolationModeHighQualityBicubic);
        g.DrawImage(img, rt, Round(img.GetWidth * (LimitLeft - Rect2.Left) / (Rect2.Right - Rect2.Left)), Round(img.GetHeight * (LimitTop - Rect2.Top) / (Rect2.Bottom - Rect2.Top)), Round(img.GetWidth * (LimitRight - LimitLeft) / (Rect2.Right - Rect2.Left)), Round(img.GetHeight * (LimitBottom - LimitTop) / (Rect2.Bottom - Rect2.Top)), UnitPixel);
      end;
      }
      finally
        FreeAndNil(img);
      end;
    finally
      FreeAndNil(g);
    end;

    Result := Bitmap2;
  finally
    if Result = nil then Bitmap2.Free;
  end;
end;

//------------------------------------------------------------------------------
procedure AnimateShowBitmap(SrcBMP: TBitmap; DestBMP: TBitmap);
var
  iLoop: Integer;
  TempBitmap1,
  TempBitmap2: TBitmap;
begin
  TempBitmap1 := TBitmap.Create;
  TempBitmap2 := TBitmap.Create;
  try
    TempBitmap1.Assign(SrcBMP);

    TempBitmap2.SetSize(DestBMP.Width, DestBMP.Height);
    TempBitmap2.Canvas.StretchDraw(Rect(0, 0, DestBMP.Width, DestBMP.Height),
                                  TempBitmap1);
    for iLoop := 0 to TempBitmap2.Height - 1 do
    begin
      if (DestBMP = nil) or (SrcBMP = nil) then Exit;

      DestBMP.Canvas.CopyRect(Rect(0, iLoop, TempBitmap2.Width, iLoop + 1),
                              TempBitmap2.Canvas,
                              Rect(0, iLoop, TempBitmap2.Width, iLoop + 1));
      Sleep(5);
    end;
  finally
    TempBitmap2.free;
    TempBitmap1.free;
  end;
end;

//------------------------------------------------------------------------------
 function GetRegionFromBitmap(StartX, StartY: Integer; DestBitmap:TBitmap; TransparentColor: TColor): HRGN;
 var
  Region1,
  Region2 :HRGN;

  X, Y, ScanlineBytes: Integer;
  P: PRGBTripleArray;
begin
  Region1 := CreateRectRgn(StartX, StartY, StartX, StartY);
  if not DestBitmap.Empty then
  begin
    P := DestBitmap.ScanLine[0];

    ScanlineBytes := Integer(DestBitmap.ScanLine[1]) - Integer(DestBitmap.ScanLine[0]);
    for Y := 0 to DestBitmap.Height - 1 do
    begin
      for X := 0 to DestBitmap.Width - 1 do
      begin
        if TransparentColor = p[X].rgbtBlue * 256 * 256 + p[X].rgbtGreen * 256 + p[X].rgbtBlue then continue;

        Region2 := CreateRectRgn(StartX + X, StartY + Y, StartX + X + 1, StartY + Y + 1);
        CombineRgn(Region1, Region1, Region2, RGN_OR);
        DeleteObject(Region2);
      end;
      Inc(Integer(P), ScanlineBytes);
    end;

  end;
  Result := Region1;
end;

//------------------------------------------------------------------------------
{将Bitmap转换为RTF格式}
function ConvertBitmapToRTF(const Bitmap: TBitmap): string;
var
  bi, bb: string;
  bis, bbs: Cardinal;
  achar: string[2];
  Buffer: string;
  I: Integer;
type
  PWord = ^Word;
begin
  GetDIBSizes(Bitmap.Handle, bis, bbs);
  SetLength(bi, bis);
  SetLength(bb, bbs);
  GetDIB(Bitmap.Handle, Bitmap.Palette, PChar(bi)^, PChar(bb)^);
  SetLength(Buffer, (Length(bb) + Length(bi)) * 2);
  i := 1;
  for bis := 1 to Length(bi) do
  begin
    achar := IntToHex(Integer(bi[bis]), 2);
    PWord(@Buffer[i])^ := PWord(@achar[1])^;
    inc(i, 2);
  end;
  for bbs := 1 to Length(bb) do
  begin
    achar := IntToHex(Integer(bb[bbs]), 2);
    PWord(@Buffer[i])^ := PWord(@achar[1])^;
    inc(i, 2);
  end;
  Result := '{\rtf1 {\pict\dibitmap ' + Buffer + ' }}';
end;

procedure ConvertBitmapToHues(DestBitmap:TBitmap;FHueAdd:Integer);
var
   x, y, ScanlineBytes: integer;
   p: prgbtriplearray;
   RVALUE, bvalue, gvalue: integer;
   hVALUE, sVALUE, lVALUE: Double;
begin
   if not DestBitmap.Empty then
   begin
    DestBitmap.PixelFormat:=pf24bit;
    p := DestBitmap.ScanLine[0];
    ScanlineBytes := integer(DestBitmap.ScanLine[1]) - integer(DestBitmap.ScanLine[0]);
    for y := 0 to DestBitmap.Height - 1 do
    begin
      for x := 0 to DestBitmap.Width - 1 do
      begin
        RVALUE := p[x].rgbtRed;
        gVALUE := p[x].rgbtGreen;
        bVALUE := p[x].rgbtBlue;
        RGBtoHSL(RVALUE, gVALUE, bVALUE, hVALUE, sVALUE, lVALUE);
        hVALUE := (hVALUE + FHueAdd);
        if hValue >= 360 then hValue := hValue - 360;

        HSLtorgb(hVALUE, sVALUE, lVALUE, rVALUE, gVALUE, bVALUE);
        p[x].rgbtRed := RVALUE;
        p[x].rgbtGreen := gVALUE;
        p[x].rgbtBlue := bVALUE;
      end;
      inc(integer(p), ScanlineBytes);
    end;
  end;
end;

//------------------------------------------------------------------------------
{改变Bitmap的饱和度}
procedure ConvertBitmapToSaturation(DestBitmap:TBitmap;FSaturationAdd:Integer);
var
   x, y, ScanlineBytes: integer;
   p: prgbtriplearray;
   RVALUE, bvalue, gvalue: integer;
   hVALUE, sVALUE, lVALUE: Double;
begin
   if not DestBitmap.Empty then
   begin
    DestBitmap.PixelFormat:=pf24bit;
    p := DestBitmap.ScanLine[0];
    ScanlineBytes := integer(DestBitmap.ScanLine[1]) - integer(DestBitmap.ScanLine[0]);
    for y := 0 to DestBitmap.Height - 1 do
    begin
      for x := 0 to DestBitmap.Width - 1 do
      begin
        RVALUE := p[x].rgbtRed;
        gVALUE := p[x].rgbtGreen;
        bVALUE := p[x].rgbtBlue;
        RGBtoHSL(RVALUE, gVALUE, bVALUE, hVALUE, sVALUE, lVALUE);
        sVALUE := min(100, sVALUE + FSaturationAdd);
        HSLtorgb(hVALUE, sVALUE, lVALUE, rVALUE, gVALUE, bVALUE);
        p[x].rgbtRed := RVALUE;
        p[x].rgbtGreen := gVALUE;
        p[x].rgbtBlue := bVALUE;
      end;
      inc(integer(p), ScanlineBytes);
    end;
  end;
end;

//------------------------------------------------------------------------------
{改变Bitmap的亮度}
procedure ConvertBitmapToLighter(DestBitmap:TBitmap;FLightAdd:Integer);
var
   x, y, ScanlineBytes: integer;
   p: prgbtriplearray;
   RVALUE, bvalue, gvalue: integer;
   hVALUE, sVALUE, lVALUE: Double;
begin
  if not DestBitmap.Empty then
  begin
    DestBitmap.PixelFormat:=pf24bit;
    p := DestBitmap.ScanLine[0];
    ScanlineBytes := integer(DestBitmap.ScanLine[1]) - integer(DestBitmap.ScanLine[0]);
    for y := 0 to DestBitmap.Height - 1 do
    begin
      for x := 0 to DestBitmap.Width - 1 do
      begin
        RVALUE := p[x].rgbtRed;
        gVALUE := p[x].rgbtGreen;
        bVALUE := p[x].rgbtBlue;
        RGBtoHSL(RVALUE, gVALUE, bVALUE, hVALUE, sVALUE, lVALUE);
        lVALUE := min(100, lVALUE + FLightAdd);
        HSLtorgb(hVALUE, sVALUE, lVALUE, rVALUE, gVALUE, bVALUE);
        p[x].rgbtRed := RVALUE;
        p[x].rgbtGreen := gVALUE;
        p[x].rgbtBlue := bVALUE;
      end;
      inc(integer(p), ScanlineBytes);
    end;
  end;
end;

//------------------------------------------------------------------------------
{改变Bitmap的色调}
procedure ConvertBitmapHSL(DestBitmap:TBitmap; H, S, L: Integer);
var
   x, y, ScanlineBytes: integer;
   p: prgbtriplearray;
   RVALUE, bVALUE, GVALUE: integer;
   HVALUE, SVALUE, LVALUE: Double;
begin
  if not DestBitmap.Empty then
  begin
    DestBitmap.PixelFormat := pf24bit;
    p := DestBitmap.ScanLine[0];
    ScanlineBytes := integer(DestBitmap.ScanLine[1]) - integer(DestBitmap.ScanLine[0]);
    for y := 0 to DestBitmap.Height - 1 do
    begin
      for x := 0 to DestBitmap.Width - 1 do
      begin
        RVALUE := p[x].rgbtRed;
        GVALUE := p[x].rgbtGreen;
        BVALUE := p[x].rgbtBlue;

        if L <> 0 then
        begin
          if (L > 0) then
          begin
              RVALUE := RVALUE + (255 - RVALUE) * L div 255;
              GVALUE := GVALUE + (255 - GVALUE) * L div 255;
              BVALUE := BVALUE + (255 - BVALUE) * L div 255;
          end
          else if (L < 0) then
          begin
              RVALUE := RVALUE + RVALUE * L div 255;
              GVALUE := GVALUE + GVALUE * L div 255;
              BVALUE := BVALUE + BVALUE * L div 255;
          end;
        end;


        RGBtoHSL(RVALUE, GVALUE, BVALUE, HVALUE, SVALUE, LVALUE);

        HVALUE := (HVALUE + H);
        if HVALUE >= 360 then HVALUE := HVALUE - 360;
        if HVALUE < 0 then HVALUE := HVALUE + 360;

        HSLtoRGB(HVALUE, Max(0, Min(99, SVALUE + S)), LValue, RVALUE, GVALUE, BVALUE);
        p[x].rgbtRed := RVALUE;
        p[x].rgbtGreen := GVALUE;
        p[x].rgbtBlue := BVALUE;
      end;
      inc(integer(p), ScanlineBytes);
    end;
  end;
end;


{
procedure ConvertBitmapToColor(DestBitmap:TBitmap;DestColor:TColor);
var
   hexString:String;
   x, y, ScanlineBytes: integer;
   p: prgbtriplearray;
   RVALUE, bVALUE, GVALUE: integer;
   HVALUE, SVALUE, LVALUE: Double;
   HNewVALUE, SNewVALUE, LNewVALUE  : Double;
begin
  if not DestBitmap.Empty then
  begin
    hexString:=IntToHex(DestColor,6);
    RGBtoHSL(StrToInt('$'+Copy(hexString,5,2)), StrToInt('$'+Copy(hexString,3,2)), StrToInt('$'+Copy(hexString,1,2)), HNewVALUE, SNewVALUE, LNewVALUE);

    DestBitmap.PixelFormat := pf24bit;
    p := DestBitmap.ScanLine[0];
    ScanlineBytes := integer(DestBitmap.ScanLine[1]) - integer(DestBitmap.ScanLine[0]);
    for y := 0 to DestBitmap.Height - 1 do
    begin
      for x := 0 to DestBitmap.Width - 1 do
      begin
        RVALUE := p[x].rgbtRed;
        GVALUE := p[x].rgbtGreen;
        BVALUE := p[x].rgbtBlue;
        RGBtoHSL(RVALUE, GVALUE, BVALUE, HVALUE, SVALUE, LVALUE);
        HSLtoRGB(HNewVALUE, SNewVALUE, LVALUE, RVALUE, GVALUE, BVALUE);
        p[x].rgbtRed := RVALUE;
        p[x].rgbtGreen := GVALUE;
        p[x].rgbtBlue := BVALUE;
      end;
      inc(integer(p), ScanlineBytes);
    end;
  end;
end;
}
function GetColorHues(AColor:  TColor): Double;
var
   RVALUE, bvalue, gvalue: integer;
   hVALUE, sVALUE, lVALUE: Double;
begin
  rVALUE := StrToInt('$' + Copy(IntToHex(AColor, 6), 5, 2));
  gVALUE := StrToInt('$' + Copy(IntToHex(AColor, 6), 3, 2));
  bVALUE := StrToInt('$' + Copy(IntToHex(AColor, 6), 1, 2));

  RGBtoHSL(rVALUE, gVALUE, bVALUE, hVALUE, sVALUE, lVALUE);

  Result := hVALUE;
end;

function GetColorLighte(AColor:  TColor): Double;
var
   RVALUE, bvalue, gvalue: integer;
   hVALUE, sVALUE, lVALUE: Double;
begin
  rVALUE := StrToInt('$' + Copy(IntToHex(AColor, 6), 5, 2));
  gVALUE := StrToInt('$' + Copy(IntToHex(AColor, 6), 3, 2));
  bVALUE := StrToInt('$' + Copy(IntToHex(AColor, 6), 1, 2));

  RGBtoHSL(rVALUE, gVALUE, bVALUE, hVALUE, sVALUE, lVALUE);

  Result := lVALUE;
end;

//------------------------------------------------------------------------------
{改变Color的亮度}
function ConvertColorToLighter(SourceColor: TColor; FLightAdd:Integer): TColor;
var
   RVALUE, bvalue, gvalue: integer;
   hVALUE, sVALUE, lVALUE: Double;
begin
  rVALUE := StrToInt('$'+Copy(IntToHex(SourceColor,6),5,2));
  gVALUE := StrToInt('$'+Copy(IntToHex(SourceColor,6),3,2));
  bVALUE := StrToInt('$'+Copy(IntToHex(SourceColor,6),1,2));

  RGBtoHSL(rVALUE, gVALUE, bVALUE, hVALUE, sVALUE, lVALUE);
  HSLtoRGB(hVALUE, sVALUE, Max(0, Min(100, lVALUE + FLightAdd)), rVALUE, gVALUE, bVALUE);
  Result := TColor( StrToInt('$' + IntToHex(bVALUE,2) + IntToHex(gVALUE,2) + IntToHex(rVALUE,2)) );
end;

//------------------------------------------------------------------------------
{改变Color的色调}
function ConvertColorToColor(SourceColor: TColor; DestColor: TColor): TColor;
var
   L: Integer;
   hexString:String;
   hNewVALUE, sNewVALUE, lNewVALUE  : Double;
   RVALUE, bvalue, gvalue: integer;
   hVALUE, sVALUE, lVALUE: Double;
begin
  hexString:=IntToHex(DestColor,6);
  RGBtoHSL(StrToInt('$'+Copy(hexString,5,2)), StrToInt('$'+Copy(hexString,3,2)), StrToInt('$'+Copy(hexString,1,2)), hNewVALUE, sNewVALUE, lNewVALUE);

  rVALUE := StrToInt('$'+Copy(IntToHex(SourceColor,6),5,2));
  gVALUE := StrToInt('$'+Copy(IntToHex(SourceColor,6),3,2));
  bVALUE := StrToInt('$'+Copy(IntToHex(SourceColor,6),1,2));

  L := 0;
  if LVALUE >= 100 then L := 0;
  RGBtoHSL(rVALUE, gVALUE, bVALUE, hVALUE, sVALUE, lVALUE);
  HSLtoRGB(hNewVALUE, sNewVALUE, lVALUE + L, rVALUE, gVALUE, bVALUE);
  Result := TColor( StrToInt('$' + IntToHex(bVALUE,2) + IntToHex(gVALUE,2) + IntToHex(rVALUE,2)) );
end;

procedure ConvertPngToColor3(DestPng: pngimage.TPngImage; DestColor:  TColor);
var
   L: Integer;
   hexString:String;
   x, y, ScanlineBytes: integer;
   p: prgbtriplearray;
   RVALUE, bVALUE, GVALUE: integer;
   HVALUE, SVALUE, LVALUE: Double;
   HNewVALUE, SNewVALUE, LNewVALUE  : Double;
begin
  if not DestPng.Empty then
  begin
    hexString:=IntToHex(DestColor,6);
    RGBtoHSL(StrToInt('$'+Copy(hexString,5,2)), StrToInt('$'+Copy(hexString,3,2)), StrToInt('$'+Copy(hexString,1,2)), HNewVALUE, SNewVALUE, LNewVALUE);

    L := 0;

    p := DestPng.ScanLine[0];
    ScanlineBytes := integer(DestPng.ScanLine[1]) - integer(DestPng.ScanLine[0]);
    for y := 0 to DestPng.Height - 1 do
    begin
      for x := 0 to DestPng.Width - 1 do
      begin
        RVALUE := p[x].rgbtRed;
        GVALUE := p[x].rgbtGreen;
        BVALUE := p[x].rgbtBlue;
        RGBtoHSL(RVALUE, GVALUE, BVALUE, HVALUE, SVALUE, LVALUE);
        HSLtoRGB(HNewVALUE, SNewVALUE, LNewVALUE, RVALUE, GVALUE, BVALUE);
        p[x].rgbtRed := RVALUE;
        p[x].rgbtGreen := GVALUE;
        p[x].rgbtBlue := BVALUE;
      end;
      inc(integer(p), ScanlineBytes);
    end;
  end;
end;

procedure ConvertPngToColor2(DestPng:pngimage2.TPngImage;DestColor:TColor);
var
   L: Integer;
   hexString:String;
   x, y, ScanlineBytes: integer;
   p: prgbtriplearray;
   RVALUE, bVALUE, GVALUE: integer;
   HVALUE, SVALUE, LVALUE: Double;
   HNewVALUE, SNewVALUE, LNewVALUE  : Double;
begin
  if not DestPng.Empty then
  begin
    hexString:=IntToHex(DestColor,6);
    RGBtoHSL(StrToInt('$'+Copy(hexString,5,2)), StrToInt('$'+Copy(hexString,3,2)), StrToInt('$'+Copy(hexString,1,2)), HNewVALUE, SNewVALUE, LNewVALUE);

    L := 0;

    p := DestPng.ScanLine[0];
    ScanlineBytes := integer(DestPng.ScanLine[1]) - integer(DestPng.ScanLine[0]);
    for y := 0 to DestPng.Height - 1 do
    begin
      for x := 0 to DestPng.Width - 1 do
      begin
        RVALUE := p[x].rgbtRed;
        GVALUE := p[x].rgbtGreen;
        BVALUE := p[x].rgbtBlue;
        RGBtoHSL(RVALUE, GVALUE, BVALUE, HVALUE, SVALUE, LVALUE);
        HSLtoRGB(HNewVALUE, SNewVALUE, LNewVALUE, RVALUE, GVALUE, BVALUE);
        p[x].rgbtRed := RVALUE;
        p[x].rgbtGreen := GVALUE;
        p[x].rgbtBlue := BVALUE;
      end;
      inc(integer(p), ScanlineBytes);
    end;
  end;
end;

procedure ConvertPngToColor(DestPng:TPngImage;DestColor:TColor);
var
   L: Integer;
   hexString:String;
   x, y, ScanlineBytes: integer;
   p: prgbtriplearray;
   RVALUE, bVALUE, GVALUE: integer;
   HVALUE, SVALUE, LVALUE: Double;
   HNewVALUE, SNewVALUE, LNewVALUE  : Double;
begin
  if not DestPng.Empty then
  begin
    hexString:=IntToHex(DestColor,6);
    RGBtoHSL(StrToInt('$'+Copy(hexString,5,2)), StrToInt('$'+Copy(hexString,3,2)), StrToInt('$'+Copy(hexString,1,2)), HNewVALUE, SNewVALUE, LNewVALUE);

    L := 0;

    //DestPng.PixelFormat := pf24bit;
    p := DestPng.ScanLine[0];
    ScanlineBytes := integer(DestPng.ScanLine[1]) - integer(DestPng.ScanLine[0]);
    for y := 0 to DestPng.Height - 1 do
    begin
      for x := 0 to DestPng.Width - 1 do
      begin
        RVALUE := p[x].rgbtRed;
        GVALUE := p[x].rgbtGreen;
        BVALUE := p[x].rgbtBlue;
        RGBtoHSL(RVALUE, GVALUE, BVALUE, HVALUE, SVALUE, LVALUE);
        //HSLtoRGB(Max(0, Min(359, HNewVALUE + H)), Max(0, Min(100, SNewVALUE + S)), Max(0, Min(100, LNewVALUE + L)), RVALUE, GVALUE, BVALUE);
        //if LVALUE >= 100 then L := 0;
        HSLtoRGB(HNewVALUE, SNewVALUE, LVALUE + L, RVALUE, GVALUE, BVALUE);
        p[x].rgbtRed := RVALUE;
        p[x].rgbtGreen := GVALUE;
        p[x].rgbtBlue := BVALUE;
      end;
      inc(integer(p), ScanlineBytes);
    end;
  end;
end;

procedure ConvertPngToColorH2(DestPng:pngImage2.TPngImage;DestColor:TColor);
var
   L: Integer;
   hexString:String;
   x, y, ScanlineBytes: integer;
   p: prgbtriplearray;
   RVALUE, bVALUE, GVALUE: integer;
   HVALUE, SVALUE, LVALUE: Double;
   HNewVALUE, SNewVALUE, LNewVALUE  : Double;
begin
  if not DestPng.Empty then
  begin
    hexString:=IntToHex(DestColor,6);
    RGBtoHSL(StrToInt('$'+Copy(hexString,5,2)), StrToInt('$'+Copy(hexString,3,2)), StrToInt('$'+Copy(hexString,1,2)), HNewVALUE, SNewVALUE, LNewVALUE);

    L := 0;

    //DestPng.PixelFormat := pf24bit;
    p := DestPng.ScanLine[0];
    ScanlineBytes := integer(DestPng.ScanLine[1]) - integer(DestPng.ScanLine[0]);
    for y := 0 to DestPng.Height - 1 do
    begin
      for x := 0 to DestPng.Width - 1 do
      begin
        RVALUE := p[x].rgbtRed;
        GVALUE := p[x].rgbtGreen;
        BVALUE := p[x].rgbtBlue;
        RGBtoHSL(RVALUE, GVALUE, BVALUE, HVALUE, SVALUE, LVALUE);
        //HSLtoRGB(Max(0, Min(359, HNewVALUE + H)), Max(0, Min(100, SNewVALUE + S)), Max(0, Min(100, LNewVALUE + L)), RVALUE, GVALUE, BVALUE);
        //if LVALUE >= 100 then L := 0;
        HSLtoRGB(HNewVALUE, SVALUE, LVALUE + L, RVALUE, GVALUE, BVALUE);
        p[x].rgbtRed := RVALUE;
        p[x].rgbtGreen := GVALUE;
        p[x].rgbtBlue := BVALUE;
      end;
      inc(integer(p), ScanlineBytes);
    end;
  end;
end;

procedure ConvertPngToColorH(DestPng:TPngImage;DestColor:TColor);
var
   L: Integer;
   hexString:String;
   x, y, ScanlineBytes: integer;
   p: prgbtriplearray;
   RVALUE, bVALUE, GVALUE: integer;
   HVALUE, SVALUE, LVALUE: Double;
   HNewVALUE, SNewVALUE, LNewVALUE  : Double;
begin
  if not DestPng.Empty then
  begin
    hexString:=IntToHex(DestColor,6);
    RGBtoHSL(StrToInt('$'+Copy(hexString,5,2)), StrToInt('$'+Copy(hexString,3,2)), StrToInt('$'+Copy(hexString,1,2)), HNewVALUE, SNewVALUE, LNewVALUE);

    L := 0;

    //DestPng.PixelFormat := pf24bit;
    p := DestPng.ScanLine[0];
    ScanlineBytes := integer(DestPng.ScanLine[1]) - integer(DestPng.ScanLine[0]);
    for y := 0 to DestPng.Height - 1 do
    begin
      for x := 0 to DestPng.Width - 1 do
      begin
        RVALUE := p[x].rgbtRed;
        GVALUE := p[x].rgbtGreen;
        BVALUE := p[x].rgbtBlue;
        RGBtoHSL(RVALUE, GVALUE, BVALUE, HVALUE, SVALUE, LVALUE);
        //HSLtoRGB(Max(0, Min(359, HNewVALUE + H)), Max(0, Min(100, SNewVALUE + S)), Max(0, Min(100, LNewVALUE + L)), RVALUE, GVALUE, BVALUE);
        //if LVALUE >= 100 then L := 0;
        HSLtoRGB(HNewVALUE, SVALUE, LVALUE + L, RVALUE, GVALUE, BVALUE);
        p[x].rgbtRed := RVALUE;
        p[x].rgbtGreen := GVALUE;
        p[x].rgbtBlue := BVALUE;
      end;
      inc(integer(p), ScanlineBytes);
    end;
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
   HTotal: array[0..360] of Integer;
   RTotal, GTotal, BTotal: Int64;
begin
  RTotal := 0;
  GTotal := 0;
  BTotal := 0;
  for iLoop := 0 to 360 do
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
      ScanlineBytes := integer(DestBitmap.ScanLine[1]) - integer(DestBitmap.ScanLine[0]);
      try
        for y := 0 to DestBitmap.Height - 1 do
        begin
          for x := 0 to DestBitmap.Width - 1 do
          begin
            RVALUE := p[x].rgbtRed;
            GVALUE := p[x].rgbtGreen;
            BVALUE := p[x].rgbtBlue;
            RGBtoHSL(RVALUE, GVALUE, BVALUE, HVALUE, SVALUE, LVALUE);
            Inc(LTotal, Round(LVALUE));
            Inc(STotal, Round(SVALUE));

            HTotal[Round(HVALUE) div 1] := HTotal[Round(HVALUE) div 1] + 1;
          end;
          inc(integer(p), ScanlineBytes);
        end;
      except
      end;
      HVALUE := 0;
      for iLoop := 0 to 360 do
      begin
        if HTotal[iLoop] > HTotal[Round(HVALUE)] then HVALUE := iLoop * 1;
      end;
      HSLtoRGB(HVALUE, Min(STotal / (DestBitmap.Height * DestBitmap.Width), 60), LTotal / (DestBitmap.Height * DestBitmap.Width), RVALUE, GVALUE, BVALUE);
      //HSLtoRGB(HVALUE, 40, 70, RVALUE, GVALUE, BVALUE);
      Result := BVALUE * 256 * 256 + GVALUE * 256 + RVALUE;
    end;
  except
  end;
end;

//------------------------------------------------------------------------------
{改变Bitmap的色调}
procedure ConvertBitmapToColor(DestBitmap:TBitmap;DestColor:TColor);
var
   L: Integer;
   hexString:String;
   x, y, ScanlineBytes: integer;
   p: prgbtriplearray;
   RVALUE, bVALUE, GVALUE: integer;
   HVALUE, SVALUE, LVALUE: Double;
   HNewVALUE, SNewVALUE, LNewVALUE  : Double;
begin
  try
  if not DestBitmap.Empty then
  begin
    hexString:=IntToHex(DestColor,6);
    RGBtoHSL(StrToInt('$'+Copy(hexString,5,2)), StrToInt('$'+Copy(hexString,3,2)), StrToInt('$'+Copy(hexString,1,2)), HNewVALUE, SNewVALUE, LNewVALUE);

    L := 0;

    DestBitmap.PixelFormat := pf24bit;
    p := DestBitmap.ScanLine[0];
    ScanlineBytes := integer(DestBitmap.ScanLine[1]) - integer(DestBitmap.ScanLine[0]);
    for y := 0 to DestBitmap.Height - 1 do
    begin
      for x := 0 to DestBitmap.Width - 1 do
      begin
        RVALUE := p[x].rgbtRed;
        GVALUE := p[x].rgbtGreen;
        BVALUE := p[x].rgbtBlue;
        RGBtoHSL(RVALUE, GVALUE, BVALUE, HVALUE, SVALUE, LVALUE);
        //HSLtoRGB(Max(0, Min(359, HNewVALUE + H)), Max(0, Min(100, SNewVALUE + S)), Max(0, Min(100, LNewVALUE + L)), RVALUE, GVALUE, BVALUE);
        //if LVALUE >= 100 then L := 0;
        HSLtoRGB(HNewVALUE, SNewVALUE, LVALUE + L, RVALUE, GVALUE, BVALUE);
        p[x].rgbtRed := RVALUE;
        p[x].rgbtGreen := GVALUE;
        p[x].rgbtBlue := BVALUE;
      end;
      inc(integer(p), ScanlineBytes);
    end;
  end;
  except
    //on E: Exception do MessageBox(0, PChar(E.Message), '', 0);
  end;
end;

//------------------------------------------------------------------------------
{hsl颜色空间到rgb空间的转换}
procedure HSLtoRGB(H, S, L: Double; var R, G, B: Integer);
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
procedure RGBtoHSL(R, G, B: Integer; var H, S, L: Double);
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
procedure Grayscale(Const Bitmap:TBitmap);
var
  X: Integer;
  Y: Integer;
  PRGB: pRGBTriple;
  Gray: Byte;
begin
  Bitmap.HandleType:=bmDIB;
  Bitmap.PixelFormat:=pf24bit;
  for Y := 0 to (Bitmap.Height - 1) do
  begin
    PRGB := Bitmap.ScanLine[Y];
    for X := 0 to (Bitmap.Width - 1) do
    begin
      Gray := (77 * PRGB^.rgbtRed + 151 * PRGB^.rgbtGreen + 28 * PRGB^.rgbtBlue) shr 8;
      PRGB^.rgbtRed:=Gray;
      PRGB^.rgbtGreen:=Gray;
      PRGB^.rgbtBlue:=Gray;
      Inc(PRGB);
    end;
  end;
end;

//------------------------------------------------------------------------------
procedure PrintBitmap(ACanvas: TCanvas; Dest: TRect; Bitmap: TBitmap);
var
    Info : PBitmapInfo;
    InfoSize : DWORD;
    Image : Pointer;
{$ifdef ver80}
    ImageSize : Longint;
{$else}
    ImageSize : DWord;
{$endif}
begin
    with Bitmap do
    begin
      GetDIBSizes(Handle, InfoSize, ImageSize);
      Info := AllocMem(InfoSize);
      try
        Image := AllocMem(ImageSize);
        try
          GetDIB(Handle, Palette, Info^, Image^);
          if not Monochrome then
            SetStretchBltMode(ACanvas.Handle, STRETCH_DELETESCANS);
          with Info^.bmiHeader do
            StretchDIBits(aCanvas.Handle, Dest.Left, Dest.Top,
              Dest.RIght - Dest.Left, Dest.Bottom - Dest.Top,
              0, 0, biWidth, biHeight, Image, Info^, DIB_RGB_COLORS, SRCCOPY);
        finally
          FreeMem(Image, ImageSize);
        end;
      finally
        FreeMem(Info, InfoSize);
      end;
    end;
end;

//------------------------------------------------------------------------------
procedure SmoothAverage2(SrcBitmap: TBitmap; ARect: TRect; iBlockLen: Integer);
var
  iXStart,
  iYStart,
  iXEnd,
  iYEnd,
  iNum,
  iFirstR,
  iFirstG,
  iFirstB,
  iCurrR,
  iCurrG,
  iCurrB,
  x,
  y,
  ny,
  nx,
  iy,
  ix: Integer;

  DestBitmap,
  OldBitmap: TBitmap;

  pPixel,
  pUp,
  pDown,
  pWrite,
  pLeftRight: PRGBTripleArray;

  R,SR: TRect;

  StartTicket: Cardinal;
begin
  SR.Left := ARect.Left - iBlockLen;
  SR.Top := ARect.Top - iBlockLen;
  SR.Right := ARect.Right + iBlockLen;
  SR.Bottom := ARect.Bottom + iBlockLen;

  OldBitmap := TBitmap.Create;
  OldBitmap.PixelFormat := pf24bit;
  OldBitmap.Width := (ARect.Right - ARect.Left);
  OldBitmap.Height := (ARect.Bottom - ARect.Top);

  DestBitmap := TBitmap.Create;
  DestBitmap.PixelFormat:=pf24bit;
  DestBitmap.Width := OldBitmap.Width;
  DestBitmap.Height := OldBitmap.Height;

  try
    R.Left := 0;
    R.Top := 0;
    R.Right := OldBitmap.Width;
    R.Bottom := OldBitmap.Height;
    OldBitmap.Canvas.CopyRect(R, SrcBitmap.Canvas, SR);

    iNum := iBlockLen * iBlockLen;

    iXStart := iBlockLen div 2; // 左上角的起始位置
    iYStart := iXStart;

    iXEnd := OldBitmap.Width - iBlockLen ;	// X结束位置
    iYEnd := OldBitmap.Height - iBlockLen ;	// Y结束位置

    iFirstR := 0;
    iFirstG := 0;
    iFirstB := 0; // 每行第一子块RGB和

    for y := 0 to iYEnd do
    begin
      if (y = 0) then // 计算第一个块 (左上角)
      begin
        for ny := 0 to iBlockLen - 1 do
        begin
          pPixel := OldBitmap.ScanLine[ny];
          for nx := 0 to iBlockLen - 1 do
          begin
            Inc(iFirstB, pPixel[nx].rgbtBlue);
            Inc(iFirstG, pPixel[nx].rgbtGreen);
            Inc(iFirstR, pPixel[nx].rgbtRed);
          end;
        end;
      end
      else // y方向下移块
      begin
        pUp := OldBitmap.ScanLine[y - 1];
        pDown := OldBitmap.ScanLine[y - 1 + iBlockLen];
        for nx := 0 to iBlockLen - 1 do
        begin
          iFirstB := iFirstB - pUp[nx].rgbtBlue + pDown[nx].rgbtBlue;
          iFirstG := iFirstG - pUp[nx].rgbtGreen + pDown[nx].rgbtGreen ;
          iFirstR := iFirstR - pUp[nx].rgbtRed + pDown[nx].rgbtRed;
        end;
      end;

      // 设置每行第一个象素
      pWrite := DestBitmap.ScanLine[y + iYStart];
      ix := iXStart;

      pWrite[ix].rgbtBlue := Round(iFirstB / iNum);
      pWrite[ix].rgbtGreen := Round(iFirstG / iNum);
      pWrite[ix].rgbtRed := Round(iFirstR / iNum);
      Inc(ix);

      // x方向推移块
      iCurrR := iFirstR;
      iCurrG := iFirstG;
      iCurrB := iFirstB;

      for x := 1 to iXEnd do
      begin
        // 减左列加右列
        for iy := 0 to iBlockLen - 1 do
        begin
          pLeftRight := OldBitmap.ScanLine[y + iy];
          iCurrB := iCurrB - pLeftRight[x - 1].rgbtBlue + pLeftRight[x + iBlockLen - 1].rgbtBlue;
          iCurrG := iCurrG - pLeftRight[x - 1].rgbtGreen + pLeftRight[x + iBlockLen - 1].rgbtGreen;
          iCurrR := iCurrR - pLeftRight[x - 1].rgbtRed + pLeftRight[x + iBlockLen - 1].rgbtRed;
        end;

        // 设置象素值
        pWrite[ix].rgbtBlue := Round(iCurrB / iNum);
        pWrite[ix].rgbtGreen := Round(iCurrG / iNum);
        pWrite[ix].rgbtRed := Round(iCurrR / iNum);
        Inc(ix);
      end;
    end;

    R.Left := R.Left + 1;
    R.Top := R.Top + 1;
    R.Right := R.Right - 1;
    R.Bottom := R.Bottom - 1;
    SrcBitmap.Canvas.CopyRect(SR, DestBitmap.Canvas, R);
  finally
    FreeAndNil(OldBitmap);
    FreeAndNil(DestBitmap);
  end;
end;

//------------------------------------------------------------------------------
procedure SmoothAverage(SrcBitmap: TBitmap; TargetBitmap: TBitmap; iBlockLen: Integer);
var
  iXStart,
  iYStart,
  iXEnd,
  iYEnd,
  iNum,
  iFirstR,
  iFirstG,
  iFirstB,
  iCurrR,
  iCurrG,
  iCurrB,
  x,
  y,
  ny,
  nx,
  iy,
  ix: Integer;

  pPixel,
  pUp,
  pDown,
  pWrite,
  pLeftRight: PRGBTripleArray;

  OldBitmap: TBitmap;
  DestBitmap: TBitmap;

  R,SR: TRect;

  StartTicket: Cardinal;
begin
  DestBitmap := TBitmap.Create;
  DestBitmap.PixelFormat:=pf24bit;
  DestBitmap.Width := SrcBitmap.Width + iBlockLen * 2;
  DestBitmap.Height := SrcBitmap.Height + iBlockLen * 2;

  OldBitmap := TBitmap.Create;
  OldBitmap.PixelFormat:=pf24bit;
  OldBitmap.Width := SrcBitmap.Width + iBlockLen * 2;
  OldBitmap.Height := SrcBitmap.Height + iBlockLen * 2;

  SR.Left := 0;
  SR.Top := 0;
  SR.Right := SrcBitmap.Width;
  SR.Bottom := SrcBitmap.Height;

  R.Left := iBlockLen;
  R.Top := iBlockLen;
  R.Right := OldBitmap.Width - iBlockLen;
  R.Bottom := OldBitmap.Height - iBlockLen;
  OldBitmap.Canvas.CopyRect(R, SrcBitmap.Canvas, SR);

  iNum := iBlockLen * iBlockLen;

  iXStart := iBlockLen div 2; // 左上角的起始位置
  iYStart := iXStart;

  iXEnd := DestBitmap.Width - iBlockLen ;	// X结束位置
  iYEnd := DestBitmap.Height - iBlockLen ;	// Y结束位置

  iFirstR := 0;
  iFirstG := 0;
  iFirstB := 0; // 每行第一子块RGB和

  for y := 0 to iYEnd do
  begin
    if (y = 0) then // 计算第一个块 (左上角)
    begin
      for ny := 0 to iBlockLen - 1 do
			begin
        pPixel := OldBitmap.ScanLine[ny];
        for nx := 0 to iBlockLen - 1 do
        begin
          Inc(iFirstB, pPixel[nx].rgbtBlue);
          Inc(iFirstG, pPixel[nx].rgbtGreen);
          Inc(iFirstR, pPixel[nx].rgbtRed);
        end;
      end;
    end
    else // y方向下移块
    begin
      pUp := OldBitmap.ScanLine[y - 1];
      pDown := OldBitmap.ScanLine[y - 1 + iBlockLen];
      for nx := 0 to iBlockLen - 1 do
      begin
        iFirstB := iFirstB - pUp[nx].rgbtBlue + pDown[nx].rgbtBlue;
        iFirstG := iFirstG - pUp[nx].rgbtGreen + pDown[nx].rgbtGreen ;
        iFirstR := iFirstR - pUp[nx].rgbtRed + pDown[nx].rgbtRed;
      end;
    end;

    // 设置每行第一个象素
    pWrite := DestBitmap.ScanLine[y + iYStart];
    ix := iXStart;

    pWrite[ix].rgbtBlue := Round(iFirstB / iNum);
    pWrite[ix].rgbtGreen := Round(iFirstG / iNum);
    pWrite[ix].rgbtRed := Round(iFirstR / iNum);
    Inc(ix);

    // x方向推移块
    iCurrR := iFirstR;
    iCurrG := iFirstG;
    iCurrB := iFirstB;

    for x := 1 to iXEnd do
    begin
      // 减左列加右列
      for iy := 0 to iBlockLen - 1 do
			begin
        pLeftRight := OldBitmap.ScanLine[y + iy];
        iCurrB := iCurrB - pLeftRight[x - 1].rgbtBlue + pLeftRight[x + iBlockLen - 1].rgbtBlue;
        iCurrG := iCurrG - pLeftRight[x - 1].rgbtGreen + pLeftRight[x + iBlockLen - 1].rgbtGreen;
        iCurrR := iCurrR - pLeftRight[x - 1].rgbtRed + pLeftRight[x + iBlockLen - 1].rgbtRed;
			end;

      // 设置象素值
      pWrite[ix].rgbtBlue := Round(iCurrB / iNum);
      pWrite[ix].rgbtGreen := Round(iCurrG / iNum);
      pWrite[ix].rgbtRed := Round(iCurrR / iNum);
      Inc(ix);
    end;
  end;

  SR.Left := 0;
  SR.Top := 0;
  SR.Right := SrcBitmap.Width;
  SR.Bottom := SrcBitmap.Height;

  R.Left := iBlockLen;
  R.Top := iBlockLen;
  R.Right := OldBitmap.Width - iBlockLen;
  R.Bottom := OldBitmap.Height - iBlockLen;
  TargetBitmap.Canvas.CopyRect(SR, DestBitmap.Canvas, R);
end;

procedure GetPngImageByMask(APng, APngMask: TPngImage);
var
  P1, P2:PByteArray;
  x, y:integer;
begin
  for x:= 0 to APng.Height - 1 do
  begin
    P1 := pByteArray(APng.AlphaScanline[x]);
    P2 := pByteArray(APngMask.AlphaScanline[x]);
    for y:= 0 to APng.Width - 1 do
    begin
      P1[y] := P2[y];
    end;
  end;
end;

initialization
  LastConvertColor := 0;

end.

