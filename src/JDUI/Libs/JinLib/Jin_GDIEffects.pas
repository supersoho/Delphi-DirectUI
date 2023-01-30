unit Jin_GDIEffects;

interface

uses
  GDIPlus, ImageData, WinApi.Windows, WinApi.Messages, SysUtils, Classes, Vcl.Graphics;

  procedure DrawShadowString(const g: TGpGraphics; const str: WideString;
      const font: TGpFont; const origin: TGpPointF;
      ShadowSize, Distance: LongWord; Angle: Single = 60;
      Color: TARGB = $C0000000; Expand: LongWord = 0;
      const x2: Integer = 0; const y2: Integer = 0;
      const format: TGpStringFormat = nil);
  procedure DrawShadow(const g: TGpGraphics; const Bitmap: TGpBitmap;
    const layoutRect: TGpRectF; ShadowSize, Distance: LongWord;
    Angle: Single; Color: TARGB; Expand: LongWord);
  procedure ImageBlur(var Data: TImageData);
  procedure ImageGaussiabBlur(var Data: TImageData; Q: double; Radius: Integer);

implementation
procedure CrossBlur(var Dest: TImageData; const Source: TImageData; Weights: Pointer; Size: Integer);
var
  height, srcStride: Integer;
  _weights: Pointer;
  dstOffset, srcOffset: Integer;
  reds, greens, blues: Integer;
asm
    push    esi
    push    edi
    push    ebx
    mov     _Weights, ecx
    mov     ecx, [edx].TImageData.Stride
    mov     srcStride, ecx
    call    _SetCopyRegs
    mov     height, edx
    mov     dstOffset, ebx
    push    esi
    push    edi
    push    edx
    push    ecx
    push    eax

    // blur col

    add     ecx, Size           // width = Source.Width
    dec     ecx
    mov     edi, _weights       // edi = weights
@@cyLoop:
    push    ecx
@@cxLoop:
    push    ecx
    push    esi
    push    edi
    xor     ebx, ebx
    mov     reds, ebx
    mov     greens, ebx
    mov     blues, ebx
    mov     ecx, Size
@@cblurLoop:
    movzx   eax, [esi].TARGBQuad.Blue
    movzx   edx, [esi].TARGBQuad.Green
    imul    eax, [edi]
    imul    edx, [edi]
    add     blues, eax
    add     greens, edx
    movzx   eax, [esi].TARGBQuad.Red
    movzx   edx, [esi].TARGBQuad.Alpha
    imul    eax, [edi]
    imul    edx, [edi]
    add     reds, eax
    add     ebx, edx
    add     edi, 4
    add     esi, srcStride
    loop    @@cblurLoop
    pop     edi
    pop     esi
    mov     eax, blues
    mov     edx, greens
    mov     ecx, reds
    shr     eax, 16
    shr     edx, 16
    shr     ecx, 16
    shr     ebx, 16
    mov     [esi].TARGBQuad.Blue, al
    mov     [esi].TARGBQuad.Green, dl
    mov     [esi].TARGBQuad.Red, cl
    mov     [esi].TARGBQuad.Alpha, bl
    add     esi, 4
    pop     ecx
    loop    @@cxLoop
    pop     ecx
    dec     height
    jnz     @@cyLoop

    pop     srcOffset
    pop     ecx
    pop     height
    pop     edi
    pop     esi

    // blur row

@@ryLoop:
    push    ecx
@@rxLoop:
    push    ecx
    push    esi
    push    edi
    xor     ebx, ebx
    mov     reds, ebx
    mov     greens, ebx
    mov     blues, ebx
    mov     ecx, Size
    mov     edi, _weights
@@rblurLoop:
    movzx   eax, [esi].TARGBQuad.Blue
    movzx   edx, [esi].TARGBQuad.Green
    imul    eax, [edi]
    imul    edx, [edi]
    add     blues, eax
    add     greens, edx
    movzx   eax, [esi].TARGBQuad.Red
    movzx   edx, [esi].TARGBQuad.Alpha
    imul    eax, [edi]
    imul    edx, [edi]
    add     reds, eax
    add     ebx, edx
    add     edi, 4
    add     esi, 4
    loop    @@rblurLoop
    pop     edi
    pop     esi
    mov     eax, blues
    mov     edx, greens
    mov     ecx, reds
    shr     eax, 16
    shr     edx, 16
    shr     ecx, 16
    shr     ebx, 16
    mov     [edi].TARGBQuad.Blue, al
    mov     [edi].TARGBQuad.Green, dl
    mov     [edi].TARGBQuad.Red, cl
    mov     [edi].TARGBQuad.Alpha, bl
    add     esi, 4
    add     edi, 4
    pop     ecx
    loop    @@rxLoop
    add     esi, srcOffset
    add     edi, dstOffset
    pop     ecx
    dec     height
    jnz     @@ryLoop
    pop     ebx
    pop     edi
    pop     esi
end;

procedure ImageGaussiabBlur(var Data: TImageData; Q: double; Radius: Integer);
var
  src: TImageData;
  fweights: array of Single;
  weights: array of Integer;
  i, size: Integer;
  fx: Double;
begin
  if Radius <= 0 then
  begin
    if Abs(Q) < 1.0 then Radius := 1
    else Radius := Round(Abs(Q)) + 2;
  end;
  size := Radius shl 1 + 1;
  SetLength(fweights, size);
  for i := 1 to Radius do
  begin
    fx := i / Q;
    fweights[Radius + i] := exp(-fx * fx / 2);
    fweights[Radius - i] := fweights[Radius + i];
  end;
  fweights[Radius] := 1.0;
  fx := 0.0;
  for i := 0 to size - 1 do
    fx := fx + fweights[i];
  SetLength(weights, size);
  for i := 0 to size - 1 do
    weights[i] := Round(fweights[i] / fx * 65536.0);
  SetLength(fweights, 0);
  src := _GetExpandData(Data, Radius);
  CrossBlur(Data, src, weights, size);
  FreeImageData(src);
end;

procedure DoBlur(var Dest: TImageData; const Source: TImageData);
asm
    push      ebp
    push      esi
    push      edi
    push      ebx
    mov       ebp, [edx].TImageData.Stride
    call      _SetCopyRegs
    pxor      mm7, mm7
    pcmpeqw   mm5, mm5
    psrlw     mm5, 15
    psllw     mm5, 2
@@yLoop:
    push      ecx
@@xLoop:
    // dest.argb = (center * 4 + up + down + left + right + 4) / 8
    movd      mm2, [esi+4]      // up
    movd      mm1, [esi+ebp]    // left
    movd      mm0, [esi+ebp+4]  // center
    movd      mm3, [esi+ebp+8]  // right
    movd      mm4, [esi+ebp*2+4]// down
    punpcklbw mm0, mm7
    punpcklbw mm1, mm7
    punpcklbw mm2, mm7
    punpcklbw mm3, mm7
    punpcklbw mm4, mm7
    psllw     mm0, 2
    paddw     mm0, mm1
    paddw     mm0, mm2
    paddw     mm0, mm3
    paddw     mm0, mm4
    paddw     mm0, mm5
    psrlw     mm0, 3
    packuswb  mm0, mm7
    movd      [edi], mm0
    add       esi, 4
    add       edi, 4
    loop      @@xLoop
    pop       ecx
    add       esi, eax
    add       edi, ebx
    dec       edx
    jnz       @@yLoop
    pop       ebx
    pop       edi
    pop       esi
    pop       ebp
    emms
end;

procedure ImageBlur(var Data: TImageData);
var
  src: TImageData;
begin
  if Data.AlphaFlag then
    ArgbConvertPArgb(Data);
  src := _GetExpandData(Data, 1);
  DoBlur(Data, src);
  if Data.AlphaFlag then
    PArgbConvertArgb(Data);
  FreeImageData(src);
end;

// 卷积处理阴影效果。Data: GDI+位图数据，要求32位ARGB格式; Source: 复制的源
// ConvolMatrix: 卷积矩阵; MatrixSize：矩阵大小, Nuclear: 卷积核（必须大于0）
procedure MakeShadow(Data: TBitmapData; Source: Pointer;
    ConvolMatrix: array of Integer; MatrixSize, Nuclear: LongWord);
var
  Radius, mSize, rSize: LongWord;
  x, y: LongWord;
  Width, Height: Integer;
  Matrix: Pointer;
asm
    push    esi
    push    edi
    push    ebx

    mov     esi, edx              // esi = Source + 3  (Alpha byte)
    add     esi, 3
    mov     edi, [eax + 16]   // edi = Data.Scan0
    mov     Matrix, ecx       // Matrix = ConvolMatrix
    mov     ecx, MatrixSize
    mov     edx, ecx
    dec     ecx
    mov     ebx, [eax]
    sub     ebx, ecx
    mov     Width, ebx        // Width = Data.Width - (MatrixSize - 1)
    mov     ebx, [eax + 4]
    sub     ebx, ecx
    mov     Height, ebx       // Height = Data.Height - (MatrixSize - 1)
    shr     ecx, 1
    mov     Radius, ecx       // Radius = MatrixSize / 2
    mov     eax, [eax + 8]
    mov     mSize, eax
    shl     edx, 2
    sub     mSize, edx        // mSize = Data.Stride - MatrixSize * 4
    add     eax, 4
    imul    eax, ecx
    add     edi, eax          // edi = edi + (Data.Stride * Radius + Radius * 4)
    add     edi, 3            // edi += 3  (Alpha byte)
    shl     ecx, 3
    mov     rSize, ecx        // rSize = Radius * 2 * 4
    mov     ebx, Nuclear      // ebx = Nuclear

    mov     y, 0              // for (y = 0; y < Height; y ++)
  @yLoop:                     // {
    mov     x, 0              //   for (x = 0; x < Width; x ++)
  @xLoop:                     //   {
    push    esi               //     Save(esi)
    push    edi               //     Save(edi)
    mov     edi, Matrix       //     edi = Matrix

    xor     eax, eax          //     eax = 0
    //用卷积矩阵处理Alpha字节
    mov     ecx, MatrixSize   //      for (I = 0; I < MatrixSize; I ++)
  @Loop3:                     //      {
    push    ecx
    mov     ecx, MatrixSize   //        for (J = 0; J <= MatrixSize; J ++)
  @Loop4:                     //        {
    movzx   edx, [esi]        //           edx = *esi  (Alpha byte)
    imul    edx, [edi]
    add     eax, edx          //           eax += edx * *edi
    add     esi, 4            //           esi += 4
    add     edi, 4            //           edi ++
    loop    @Loop4            //        }
    add     esi, mSize        //        esi += mSize
    pop     ecx
    loop    @Loop3            //      }
    cdq
    idiv    ebx               //      eax /= ebx
    pop     edi               //      Result(edi)
    mov     [edi], al         //      *edi = al
    add     edi, 4            //      edi += 4
    pop     esi               //      Reset(esi)  esi += 4
    add     esi, 4

    inc     x
    mov     eax, x
    cmp     eax, Width
    jl      @xLoop            //   }
    add     esi, rSize
    add     edi, rSize
    inc     y
    mov     eax, y
    cmp     eax, Height
    jl      @yLoop            // }

    pop     ebx
    pop     edi
    pop     esi
end;


procedure BackImage(Data: TBitmapData; Dest: Pointer; Color: TARGB);
asm
    push    esi
    push    edi
    mov     esi, [eax + 16]   // esi = Data.Scan0
    mov     edi, edx          // esi = Dest
    mov     edx, ecx          // edx = Color & 0xffffff
    and     edx, 0FFFFFFh
    mov     ecx, [eax]        // ecx = Data.Height * Data.Width
    imul    ecx, [eax + 4]
    cld
  @Loop:                       // for (; ecx >= 0; ecx --)
    or      [esi], edx
    movsd                      //   *edi++ = *esi++ & 0xff000000 | edx
    loop    @Loop
    pop     edi
    pop     esi
end;

// 扩展。Data: GDI+位图数据，32位ARGB格式; Source: 复制的源
// ExpMatrix: 卷积矩阵; MatrixSize：矩阵大小, Alpha: 阴影不透明度
procedure MakeExpand(Data: TBitmapData; Source, ExpMatrix: Pointer;
    MatrixSize: LongWord; Alpha: LongWord);
var
  Radius, mSize, rSize: LongWord;
  x, y: LongWord;
  Width, Height: Integer;
  Matrix: Pointer;
asm
    push    esi
    push    edi
    push    ebx
    mov     esi, edx          // esi = Source
    mov     edi, [eax + 16]   // edi = Data.Scan0 + 3 (Alpha byte)
    add     edi, 3
    mov     Matrix, ecx       // Matrix = ExpMatrix
    mov     ecx, MatrixSize
    mov     edx, ecx
    dec     ecx
    mov     ebx, [eax]
    sub     ebx, ecx
    mov     Width, ebx        // Width = Data.Width - (MatrixSize - 1)
    mov     ebx, [eax + 4]
    sub     ebx, ecx
    mov     Height, ebx       // Height = Data.Height - (MatrixSize - 1)
    shr     ecx, 1
    mov     Radius, ecx       // Radius = MatrixSize / 2
    mov     eax, [eax + 8]
    mov     mSize, eax
    shl     edx, 2
    sub     mSize, edx        // mSize = Data.Stride - MatrixSize * 4
    add     eax, 4
    imul    eax, ecx
    add     eax, 3
    add     esi, eax          // esi = esi + (Data.Stride * Radius + Radius * 4 + 3)
    shl     ecx, 3
    mov     rSize, ecx        // rSize = Radius * 2 * 4
    mov     y, 0              // for (y = 0; y < Height; y ++)
  @yLoop:                     //
    mov     x, 0              //   for (x = 0; x < Width; x ++)
  @xLoop:                     //
    cmp     byte ptr [esi], 0 //     if (*esi != 0)
    jz      @NextPixel        //
    push    edi               //       Save(edi)
    mov     ebx, Matrix       //       ebx = Matrix + 3 (Alpha byte)
    add     ebx, 3
    mov     ecx, MatrixSize   //       for (I = 0; I < MatrixSize; I ++)
  @Loop3:                     //
    push    ecx
    mov     ecx, MatrixSize   //         for (J = 0; J <= MatrixSize; J ++)
  @Loop4:                     //
    movzx   eax, [ebx]        //           eax = *ebx | *edi
    movzx   edx, [edi]
    or      eax, edx
    cmp     eax, Alpha        //           if (eax > Alpha) eax = Alpha
    jle     @001
    mov     eax, Alpha
  @001:
    mov     [edi], al         //           *edi = al
    add     edi, 4            //           edi += 4
    add     ebx, 4            //           ebx += 4
    loop    @Loop4            //
    add     edi, mSize        //         edi += mSize
    pop     ecx
    loop    @Loop3            //
    pop     edi               //       eset(edi)
  @NextPixel:                 //
    add     edi, 4            //     edi += 4
    add     esi, 4            //     esi += 4
    inc     x
    mov     eax, x
    cmp     eax, Width
    jl      @xLoop            //
    add     esi, rSize
    add     edi, rSize
    inc     y
    mov     eax, y
    cmp     eax, Height
    jl      @yLoop            //
    pop     ebx
    pop     edi
    pop     esi
end;

procedure GdipShadow(Data: TBitmapData; Buf: Pointer; Radius: LongWord);
var
  Gauss: array of Integer;
  Q: Double;
  x, y, n, z: Integer;
  p: PInteger;
begin
  // 根据半径计算高斯模糊矩阵
  Q := Radius / 2;
  if Q = 0 then Q := 0.1;
  n := Radius shl 1 + 1;
  SetLength(Gauss, n * n);
  p := @Gauss[0];
  z := 0;
  for x := -Radius to Radius do
    for y := -Radius to Radius do
    begin
      p^ := Round(Exp(-(x * x + y * y) / (2.0 * Q * Q)) / (2.0 * PI * Q * Q) * 1000.0);
      Inc(z, p^);
      Inc(p);
    end;
  MakeShadow(Data, Buf, Gauss, n, z);
end;
procedure GdipBorder(Data: TBitmapData; Buf: Pointer; Expand: LongWord; Color: TARGB);
var
  bmp: TGpBitmap;
  bg: TGpGraphics;
  r: Integer;
  Data1: TBitmapData;
  Size: Integer;
begin
  r := Expand shl 1 + 1;
  Size := r + 2;
  bmp := TGpBitmap.Create(Size, Size, pf32bppARGB);
  bg := TGpGraphics.Create(bmp);
  try
    // 制造一个直径=r，消除锯齿后的圆作为描边（或扩展）的位图画笔
    bg.SmoothingMode := smAntiAlias;
    bg.PixelOffsetMode := pmHighQuality;
    bg.FillEllipse(Brushs[Color], 1, 1, r, r);
    Data1 := bmp.LockBits(GpRect(0, 0, Size, Size), [imRead], pf32bppARGB);
    try
      // 用位图画笔扩展图像
      MakeExpand(Data, Buf, Data1.Scan0, Size, Color shr 24);
    finally
      bmp.UnlockBits(Data1);
    end;
  finally
    bg.Free;
    bmp.Free;
  end;
end;
procedure DrawShadow(const g: TGpGraphics; const Bitmap: TGpBitmap;
    const layoutRect: TGpRectF; ShadowSize, Distance: LongWord;
    Angle: Single; Color: TARGB; Expand: LongWord);
var
  dr, sr: TGpRectF;
  Data: TBitmapData;
  Buf: Pointer;
  SaveScan0: Pointer;
begin
  Data := Bitmap.LockBits(GpRect(0, 0, Bitmap.Width, Bitmap.Height),
                          [imRead, imWrite], pf32bppARGB);
  GetMem(Buf, Data.Height * Data.Stride);
  try
    BackImage(Data, Buf, Color);   // 备份图像数据，同时替换阴影颜色
    if Expand > ShadowSize then
      Expand := ShadowSize;
    if Expand <> 0 then            // 处理文字阴影扩展
      if Expand <> ShadowSize then
      begin
        SaveScan0 := Data.Scan0;
        Data.Scan0 := Buf;
        GdipBorder(Data, SaveScan0, Expand, Color);
        Data.Scan0 := SaveScan0;
      end else
        GdipBorder(Data, Buf, Expand, Color);

    if ShadowSize > 0 then
      if Expand <> ShadowSize then   // 处理文字阴影效果
        GdipShadow(Data, Buf, ShadowSize - Expand);
  finally
    FreeMem(Buf);
    Bitmap.UnlockBits(Data);
  end;
  sr := GpRect(0.0, 0.0, Data.Width, Data.Height);
  dr := GpRect(layoutRect.Point, sr.Size);
  // 根据角度计算阴影位图在目标画布的偏移量
  Offset(dr, Cos(PI * Angle / 180) * Distance - ShadowSize - 1,
         Sin(PI * Angle / 180) * Distance - ShadowSize - 1);
  // 输出阴影位图到目标画布
  g.DrawImage(Bitmap, dr, sr.X, sr.Y, sr.Width, sr.Height, utPixel);
end;
// 计算并输出文字阴影效果
// g: 文字输出的画布; str要输出的文字; font: 字体; layoutRect: 限定的文字输出范围
// ShadowSize: 总的阴影大小; Distance: 阴影距离;
// Angle: 阴影输出角度(左边平行处为0度。顺时针方向)
// Color: 阴影颜色; Expand: 阴影扩展大小; format: 文字输出格式
procedure DrawShadowString2(const g: TGpGraphics; const str: WideString;
    const font: TGpFont; const layoutRect: TGpRectF;
    ShadowSize, Distance: LongWord; Angle: Single = 60;
    Color: TARGB = $C0000000; Expand: LongWord = 0;
    const format: TGpStringFormat = nil;
    const x2: Integer = 0; const y2: Integer = 0);
var
  Bmp: TGpBitmap;
  Bg: TGpGraphics;
  AWidth, AHeight: Single;
begin
    // 建立透明的32位ARGB阴影位图，大小为layoutRect长、宽度 + ShadowSize * 2 + 2
    Bmp := TGpBitmap.Create(Round(layoutRect.Width + 0.5) + ShadowSize shl 2 + 2,
                            Round(layoutRect.Height + 0.5) + ShadowSize shl 2 + 2,
                            pf32bppARGB);
    Bg := TGpGraphics.Create(Bmp);
    try
      //Bg.TextRenderingHint := thSingleBitPerPixelGridFit;
      // 以Color不透明度的黑色画刷，在ShadowSize + 1处输出文字到位图画布。
      // 方便黑色以外的阴影颜色替换（直接用Color画，模糊处理后很难看）

      if x2 > 0 then
        AWidth := x2 - layoutRect.X
      else
      begin
        AWidth := layoutRect.Width;
      end;

      if y2 > 0 then
        AHeight := y2 - layoutRect.Y
      else
      begin
        AHeight := layoutRect.Height;
      end;

      Bg.DrawString(str, font, Brushs[Color], //Brushs[Color and $FF000000],     //Brushs[ARGB(ShadowAlpha, kcBlack)
                    GpRect(ShadowSize shl 1 + 1, ShadowSize shl 1 + 1,
                    AWidth, AHeight), format);
      DrawShadow(g, Bmp, layoutRect, ShadowSize, Distance, Angle, Color, Expand);
    finally
      Bg.Free;
      Bmp.Free;
    end;
end;
// 计算并输出文字阴影效果，除以输出点origin替代上面布局矩形外，其他参数同上
procedure DrawShadowString(const g: TGpGraphics; const str: WideString;
    const font: TGpFont; const origin: TGpPointF;
    ShadowSize, Distance: LongWord; Angle: Single = 60;
    Color: TARGB = $C0000000; Expand: LongWord = 0;
    const x2: Integer = 0; const y2: Integer = 0;
    const format: TGpStringFormat = nil);
begin
    DrawShadowString2(g, str, font, g.MeasureString(str, font, origin, format),
                   ShadowSize, Distance, Angle, Color, Expand, format, x2, y2)
end;


end.
