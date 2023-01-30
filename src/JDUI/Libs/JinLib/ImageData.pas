unit ImageData;

interface

uses
  WinApi.Windows, SysUtils, Classes, VCL.Graphics, Gdiplus;

type
  // 插值方式: 缺省(线性插值)，临近，线性，双立方
  TInterpolateMode = (imDefault, imNear, imBilinear, imBicubic);

  // 与GDI+ TBitmapData兼容的图像数据结构
  PImageData = ^TImageData;
  TImageData = packed record
    Width: Integer;                 // 像素宽度
    Height: Integer;                // 像素高度
    Stride: Integer;                // 扫描宽度
    PixelFormat: LongWord;          // GDI+像素格式
    Scan0: Pointer;                 // 扫描行首地址
    case Integer of
      0: (LockMode: byte;           // GDI+锁数据方式
          AllocScan: Boolean;       // 是否分配图像数据内存
          AlphaFlag: Boolean;       // 是否含Alpha
          IpMode: TInterpolateMode);// 插值方式
      1: (Reserved: UINT);          // 保留
  end;

  PARGBQuad = ^TARGBQuad;
  TARGBQuad = packed record
    case Integer of
    0: (Blue, Green, Red, Alpha: Byte);
    1: (Color: TARGB);
  end;

  PGrayTable = ^TGrayTable;
  TGrayTable = array[0..255] of Byte;

  PMMType = ^TMMType;
  TMMType = array[0..3] of Word;

  // 锁定GDI+32位位图扫描线并返回图形数据结构
  function LockGpBitmap(Bmp: TGpBitmap): TImageData;
  // GDI+位图扫描线解锁
  procedure UnlockGpBitmap(Bmp: TGpBitmap; var Data: TImageData);

  // 获取图像数据结构。参数；宽度，高度，扫描线宽度，扫描线地址，像素格式，alpha标记
  function GetImageData(Width, Height, Stride: Integer; Scan0: Pointer;
    format: VCL.Graphics.TPixelFormat; IsAlpha: Boolean): TImageData;
  // 获取新的图像据结构。参数；宽度，高度，像素格式。必须用FreeImageData释放
  function NewImageData(Width, Height: Integer; format: VCL.Graphics.TPixelFormat = pf32bit): TImageData;
  // 获取TBitmap的图像数据结构。
  // 如果IsTo32bit=False，按Bmp像素格式，否则按32位格式获取
  function GetBitmapData(Bmp: TBitmap; IsTo32bit: Boolean = True): TImageData;
  // 获取并返回Data的子图像数据结构（只支持32位）。Scan0=nil失败
  function GetSubImageData(const Data: TImageData; x, y, Width, Height: Integer): TImageData; overload;
  // 如果Data分配了扫描线内存，释放扫描线内存
  procedure FreeImageData(var Data: TImageData);
  // 设置插值方式。返回设置前的值
  function SetInterpolateMode(var Data: TImageData;
    const Value: TInterpolateMode): TInterpolateMode;

  // 设置图像数据操作寄存器（汇编码用）
  procedure _SetDataRegs(const Data: TImageData);
  // 设置图像数据拷贝寄存器（汇编码用）
  procedure _SetCopyRegs(const Dest, Source: TImageData);
  // 翻转图像数据扫描线
  function _InvertScan0(var Data: TImageData): PImageData;
  // 转换浮点数为整数，按无穷大方式保留浮点数小数
  function _Infinity(Value: Single): Integer;
  // 获取并返回Data的边框扩展图像数据结构。Radius：扩展半径
  function _GetExpandData(const Data: TImageData; Radius: Integer): TImageData;
  // PARGB格式转换成ARGB格式
  procedure PArgbConvertArgb(var Data: TImageData);
  // ARGB格式转换成PARGB格式
  procedure ArgbConvertPArgb(var Data: TImageData);

var
  DivTab: array[0..1024] of LongWord; // 汇编用除法转乘法表（被除数0 - 1024）
{$ALIGN 8}
  ArgbTab: array[0..256] of TMMType;  // mmx ARGB 灰度表（0 - 256）
  MMDivTab: array[0..255] of TMMType; // mmx 用除法转乘法表（被除数0 - 255）
{$ALIGN OFF}

implementation

uses GdipExport;

type
  TGpObj = class(TGdiplusBase) end;

// 返回GDI+图像原像素格式（TGpImage.PixelFormat是VCL风格枚举，不再含像素信息）
function GetGpPixelFormat(Bmp: TGpBitmap): Integer;
begin
  GdipGetImagePixelFormat(TGpObj(Bmp).Native, Result);
end;

function LockGpBitmap(Bmp: TGpBitmap): TImageData;
var
  Format: Integer;
begin
  Format := GetGpPixelFormat(Bmp);
  TBitmapData(Result) := Bmp.LockBits(GpRect(0, 0, Bmp.Width, Bmp.Height),
    [imRead, imWrite], pf32bppARGB);
  Result.AlphaFlag := (format and $00040000) <> 0;
end;

procedure UnlockGpBitmap(Bmp: TGpBitmap; var Data: TImageData);
begin
  Data.Reserved := Data.Reserved and $ff;
  Bmp.UnlockBits(TBitmapData(Data));
end;

function GetImageData(Width, Height, Stride: Integer; Scan0: Pointer;
    format: VCL.Graphics.TPixelFormat; IsAlpha: Boolean): TImageData;
const
  Bits: array [pf1bit..pf32bit] of LongWord = ($100, $400, $800, $1005, $1000, $1800, $2000);
begin
  if (format < pf1bit) or (format > pf32bit) then
    raise Exception.Create('Does not support the pixel format images.');
  Result.Width := Width;
  Result.Height := Height;
  Result.Scan0 := Scan0;
  Result.PixelFormat := Bits[format];
  if Stride = 0 then
    Result.Stride := ((Width * (Result.PixelFormat shr 8) + 31) and not 31) shr 3
  else
    Result.Stride := Stride;
  Result.Reserved := DWORD(IsAlpha) shl 16;
end;

function NewImageData(Width, Height: Integer; format: VCL.Graphics.TPixelFormat): TImageData;
begin
  Result := GetImageData(Width, Height, 0, nil, format, format = pf32bit);
  Result.Scan0 :=  GlobalAllocPtr(GHND, Height * Result.Stride);
  if Result.Scan0 = nil then
    raise EOutOfMemory.Create('Scan line image memory allocation failed.');
  Result.AllocScan := True;
end;

function GetBitmapData(Bmp: TBitmap; IsTo32bit: Boolean): TImageData;

  procedure FillAlpha;
  asm
    mov   eax, Result
    mov   edx, [eax].TImageData.Scan0
    mov   ecx, [eax].TImageData.Width
    imul  ecx, [eax].TImageData.Height
    mov   eax, 0ff000000h
@@Loop:
    or    [edx], eax
    add   edx, 4
    loop  @@Loop
  end;

var
  OldFormat: VCL.Graphics.TPixelFormat;
begin
  with Bmp do
  begin
    OldFormat := PixelFormat;
    if IsTo32bit then PixelFormat := pf32bit;
    Result := GetImageData(Width, Height, 0, ScanLine[Height - 1], PixelFormat, OldFormat = pf32bit);
    if (OldFormat <> pf32bit) and IsTo32bit then
      FillAlpha;
  end;
  _InvertScan0(Result); // Windows bitmap
end;

function GetSubImageData(const Data: TImageData; x, y, Width, Height: Integer): TImageData;
asm
    push    esi
    push    edi
    mov     esi, Width
    add     esi, edx
    jle     @@err
    cmp     esi, [eax].TImageData.Width
    cmova   esi, [eax].TImageData.Width
    mov     edi, [eax].TImageData.Scan0
    test    edx, edx
    jle     @@1
    sub     esi, edx
    jle     @@err
    shl     edx, 2
    add     edi, edx
@@1:
    mov     edx, Height
    add     edx, ecx
    jle     @@err
    cmp     edx, [eax].TImageData.Height
    cmova   edx, [eax].TImageData.Height
    test    ecx, ecx
    jle     @@2
    sub     edx, ecx
    jle     @@err
    imul    ecx, [eax].TImageData.Stride
    add     edi, ecx
@@2:
    mov     ecx, Result
    mov     [ecx].TImageData.Width, esi
    mov     [ecx].TImageData.Height, edx
    mov     [ecx].TImageData.Scan0, edi
    mov     edx, [eax].TImageData.PixelFormat
    mov     [ecx].TImageData.PixelFormat, edx
    mov     edx, [eax].TImageData.Stride
    mov     [ecx].TImageData.Stride, edx
    mov     edx, [eax].TImageData.Reserved
    mov     [ecx].TImageData.Reserved, edx
    mov     [ecx].TImageData.AllocScan, False
    clc
    jmp     @@Exit
@@err:
    mov     [ecx].TImageData.Scan0, 0
    stc
@@Exit:
    pop     edi
    pop     esi
end;

procedure FreeImageData(var Data: TImageData);
begin
  if Data.AllocScan and (Data.Scan0 <> nil) then
  begin
    if Data.Stride < 0 then
      _InvertScan0(Data);
    GlobalFreePtr(Data.Scan0);
    Data.Reserved := 0;
  end;
end;

function SetInterpolateMode(var Data: TImageData; const Value: TInterpolateMode): TInterpolateMode;
begin
  Result := Data.IpMode;
  Data.IpMode := Value;
end;

function _InvertScan0(var Data: TImageData): PImageData;
asm
    push    edx
    mov     edx, [eax].TImageData.Height
    dec     edx
    imul    edx, [eax].TImageData.Stride
    add     [eax].TImageData.Scan0, edx
    neg     [eax].TImageData.Stride
    pop     edx
end;

// <-- edi Scan0
// <-- ebx ScanOffset
// <-- ecx Width
// <-- edx Height
procedure _SetDataRegs(const Data: TImageData);
asm
    mov     edi, [eax].TImageData.Scan0
    mov     ecx, [eax].TImageData.Width
    movzx   edx, byte ptr[eax].TImageData.PixelFormat[1]
    imul    edx, ecx
    add     edx, 7
    shr     edx, 3
    mov     ebx, [eax].TImageData.Stride
    sub     ebx, edx
    mov     edx, [eax].TImageData.Height
end;

// <-- edi dest   Scan0
// <-- ebx dest   ScanOffset
// <-- esi source Scan0
// <-- eax source ScanOffset
// <-- ecx width
// <-- edx height
procedure _SetCopyRegs(const Dest, Source: TImageData);
asm
    mov     ecx, [edx].TImageData.Width // ecx = min(source.Width, dest.Width)
    cmp     ecx, [eax].TImageData.Width
    cmova   ecx, [eax].TImageData.Width
    movzx   esi, byte ptr[edx].TImageData.PixelFormat[1]
    imul    esi, ecx
    add     esi, 7
    shr     esi, 3
    mov     ebx, [edx].TImageData.Stride
    sub     ebx, esi
    push    ebx                         // eax = source.Stride - (PixelBits * width + 7) / 8
    movzx   esi, byte ptr[eax].TImageData.PixelFormat[1]
    imul    esi, ecx
    add     esi, 7
    shr     esi, 3
    mov     ebx, [eax].TImageData.Stride
    sub     ebx, esi                    // ebx = dest.Stride - (PixelBits * width + 7) / 8
    mov     esi, [edx].TImageData.Scan0 // esi = source.Scan0
    mov     edi, [eax].TImageData.Scan0 // edi = dest.Scan0
    mov     edx, [edx].TImageData.Height// edx = min(source.Height, dest.Height)
    cmp     edx, [eax].TImageData.Height
    cmova   edx, [eax].TImageData.Height
    pop     eax
end;

function _Infinity(Value: Single): Integer;
asm
    fld     Value
    sub     esp, 8
    fstcw   word ptr [esp]
    fstcw   word ptr [esp+2]
    fwait
    or      word ptr [esp+2], 0b00h
    fldcw   word ptr [esp+2]
    fistp   dword ptr [esp+4]
    fwait
    fldcw   word ptr [esp]
    pop     eax
    pop     eax
end;

function _GetExpandData(const Data: TImageData; Radius: Integer): TImageData;
var
  Width, SrcOffset: Integer;
asm
    push    esi
    push    edi
    push    ebx
    push    ecx
    push    ecx         // NewImageData param: Result
    mov     edi, eax
    mov     ebx, edx
    shl     edx, 1      // Size = Radius * 2
    mov     eax, [edi].TImageData.Width
    add     eax, edx
    add     edx, [edi].TImageData.Height
    mov     ecx, pf32bit
    call    NewImageData// Result = NewImageData(Data.Width + Size, Data.Height + Size, pf32bit)
    mov     eax, [edi].TImageData.Stride
    mov     ecx, [edi].TImageData.Width
    mov     edx, [edi].TImageData.Height
    mov     esi, [edi].TImageData.Scan0
    mov     Width, ecx
    shl     ecx, 2
    sub     eax, ecx
    mov     SrcOffset, eax
    pop     eax         // eax = Result
    mov     cx, word ptr[edi].TImageData.AlphaFlag
    mov     word ptr[eax].TImageData.AlphaFlag, cx
    mov     edi, [eax].TImageData.Stride
    imul    edi, ebx
    add       edi, [eax].TImageData.Scan0
    push    [eax].TImageData.Scan0
    push    edi
    push    eax
@@cLoop:
    mov     eax, [esi]
    mov       ecx, ebx
    rep     stosd
    mov     ecx, Width
    rep     movsd
    mov     eax, [esi-4]
    mov     ecx, ebx
    rep       stosd
    add     esi, SrcOffset
    dec     edx
    jnz     @@cLoop
    pop     eax         // eax = Result
    mov     esi, edi
    sub     esi, [eax].TImageData.Stride
    mov     edx, [eax].TImageData.Width
    push    ebx
@@bLoop:
    push    esi
    mov     ecx, edx
    rep     movsd
    pop     esi
    dec     ebx
    jnz     @@bLoop
    pop     ebx
    pop     esi
    pop     edi
@@tLoop:
    push    esi
    mov     ecx, edx
    rep     movsd
    pop     esi
    dec     ebx
    jnz     @@tLoop
    pop     ebx
    pop     edi
    pop     esi
@@Exit:
end;

procedure PArgbConvertArgb(var Data: TImageData);
asm
    push      edi
    push      ebx
    call      _SetDataRegs
    mov       eax, 255
    cvtsi2ss  xmm6, eax
    pshufd    xmm6, xmm6, 0
    pxor      xmm7, xmm7
@@yLoop:
    push      ecx
@@xLoop:
    movd      xmm0, [edi]
    punpcklbw xmm0, xmm7
    punpcklwd xmm0, xmm7
    cvtdq2ps  xmm0, xmm0
    pshufd    xmm1, xmm0, 255
    mulps     xmm0, xmm6
    divps     xmm0, xmm1
    cvtps2dq  xmm0, xmm0
    packssdw  xmm0, xmm7
    packuswb  xmm0, xmm7
    mov       al, [edi].TARGBQuad.Alpha
    movd      [edi], xmm0
    mov       [edi].TARGBQuad.Alpha, al
    add       edi, 4
    loop      @@xLoop
    add       edi, ebx
    pop       ecx
    dec       edx
    jnz       @@yLoop
    pop       ebx
    pop       edi
end;

procedure ArgbConvertPArgb(var Data: TImageData);
asm
    push      edi
    push      ebx
    call      _SetDataRegs
    mov       eax, 255
    cvtsi2ss  xmm6, eax
    pshufd    xmm6, xmm6, 0
    pxor      xmm7, xmm7
@@yLoop:
    push      ecx
@@xLoop:
    movd      xmm0, [edi]
    punpcklbw xmm0, xmm7
    punpcklwd xmm0, xmm7
    cvtdq2ps  xmm0, xmm0
    pshufd    xmm1, xmm0, 255
    mulps     xmm0, xmm1
    divps     xmm0, xmm6
    cvtps2dq  xmm0, xmm0
    packssdw  xmm0, xmm7
    packuswb  xmm0, xmm7
    mov       al, [edi].TARGBQuad.Alpha
    movd      [edi], xmm0
    mov       [edi].TARGBQuad.Alpha, al
    add       edi, 4
    loop      @@xLoop
    add       edi, ebx
    pop       ecx
    dec       edx
    jnz       @@yLoop
    pop       ebx
    pop       edi
end;

procedure InitArgbTable;
asm
    push    edi
    lea     edi, ArgbTab
    xor     eax, eax
@@Loop:
    stosw
    stosw
    stosw
    stosw
    inc     eax
    cmp     eax, 256
    jle     @@Loop
    pop     edi
end;

procedure InitDivTable;
asm
    push    edi
    lea     edi, DivTab
    mov     eax, -1
    stosd
    stosd
    mov     ecx, 2
@@Loop:
    mov     eax, ecx
    dec     eax
    mov     edx, 1
    div     ecx
    stosd
    inc     ecx
    cmp     ecx, 1024
    jle     @@Loop

    lea     edi, MMDivTab
    mov     eax, -1
    stosd
    stosd
    stosd
    stosd
    mov     ecx, 2
@@Loop2:
    mov     eax, ecx
    dec     eax
    or      eax, 10000h
    xor     edx, edx
    div     ecx
    stosw
    stosw
    stosw
    stosw
    inc     ecx
    cmp     ecx, 256
    jl      @@Loop2
    pop     edi
end;

initialization
begin
  InitArgbTable;
  InitDivTable;
end;

end.
