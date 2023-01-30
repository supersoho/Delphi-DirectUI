unit G32_Convolution;

interface

uses
  Windows,
  Classes, SysUtils,
  GR32,
//
//  G32_Types,
//
  GR32_Blend;

procedure ApplyConv3x3(Src, Dst: TBitmap32; ParamString: string);

implementation

Type
  TMMXRegister = packed record
  case Integer of
    0: (B0,B1,B2,B3,B4,B5,B6,B7: Byte);
    1: (W0,W1,W2,W3: Word);
  end;

//var
//  mmxRes: TMMXRegister;


procedure SetMMX_W(Var R: TMMXRegister; Value: integer);
begin
  R.W0 := word(Value);
  R.W1 := word(Value);
  R.W2 := word(Value);
  R.W3 := word(Value);
end;

procedure ApplyConv3x3(Src, Dst: TBitmap32; ParamString: string);
var
  I,J: Integer;
  A1,A2,A3,B1,B2,B3,C1,C2,C3: TColor32;
  D: TColor32;
  // Prepared An,Bn,Cn
  mvA1, mvA2, mvA3,
  mvB1 ,mvB2 ,mvB3,
  mvC1, mvC2, mvC3: TMMXRegister;
begin
  // w0..w3
  // B           G            R             A

  // Edge Finder
  SetMMX_W(mvA1, -1); SetMMX_W(mvA2, -1); SetMMX_W(mvA3, -1);
  SetMMX_W(mvB1, -1); SetMMX_W(mvB2, 9);  SetMMX_W(mvB3, -1);
  SetMMX_W(mvC1, -1); SetMMX_W(mvC2, -1); SetMMX_W(mvC3, -1);


//  CheckParams(Dst, Src);
  Dst.SetSize(Src.Width, Src.Height);

  for J := 1 to Src.Height - 2 do
  for I := 1 to Src.Width - 2 do
  begin
    A1 := Src.Pixel[I-1, J-1];   A2 := Src.Pixel[I, J-1];  A3 := Src.Pixel[I+1, J-1];
    B1 := Src.Pixel[I-1, J];     B2 := Src.Pixel[I, J];    B3 := Src.Pixel[I+1, J];
    C1 := Src.Pixel[I-1, J+1];   C2 := Src.Pixel[I, J+1];  C3 := Src.Pixel[I+1, J+1];

    asm
      // Const 0
      pxor mm0, mm0;
      // Clear Accumulator
      pxor mm7, mm7;

      // Process A Row
      movd mm1, [A1];      // Load Source mm1
      punpcklbw mm1, mm0   // B-W low byte == $00
      movq mm2, [mvA1];    // Load Filter mm2
      pmullw mm1, mm2;     // Mult
      paddsw mm7, mm1      // Add

      movd mm1, [A2];      // Load Source mm1
      punpcklbw mm1, mm0   // B-W low byte == $00
      movq mm2, [mvA2];    // Load Filter mm2
      pmullw mm1, mm2;     // Mult
      paddsw mm7, mm1      // Add

      movd mm1, [A3];      // Load Source mm1
      punpcklbw mm1, mm0   // B-W low byte == $00
      movq mm2, [mvA3];    // Load Filter mm2
      pmullw mm1, mm2;     // Mult
      paddsw mm7, mm1;     // Add

      // Process B Row
      movd mm1, [B1];      // Load Source mm1
      punpcklbw mm1, mm0   // B-W low byte == $00
      movq mm2, [mvB1];    // Load Filter mm2
      pmullw mm1, mm2;     // Mult
      paddsw mm7, mm1      // Add

      movd mm1, [B2];      // Load Source mm1
      punpcklbw mm1, mm0   // B-W low byte == $00
      movq mm2, [mvB2];    // Load Filter mm2
      pmullw mm1, mm2;     // Mult
      paddsw mm7, mm1      // Add

      movd mm1, [B3];      // Load Source mm1
      punpcklbw mm1, mm0   // B-W low byte == $00
      movq mm2, [mvB3];    // Load Filter mm2
      pmullw mm1, mm2;     // Mult
      paddsw mm7, mm1;     // Add

      // Process C Row
      movd mm1, [C1];      // Load Source mm1
      punpcklbw mm1, mm0   // B-W low byte == $00
      movq mm2, [mvC1];    // Load Filter mm2
      pmullw mm1, mm2;     // Mult
      paddsw mm7, mm1      // Add

      movd mm1, [C2];      // Load Source mm1
      punpcklbw mm1, mm0   // B-W low byte == $00
      movq mm2, [mvC2];    // Load Filter mm2
      pmullw mm1, mm2;     // Mult
      paddsw mm7, mm1      // Add

      movd mm1, [C3];      // Load Source mm1
      punpcklbw mm1, mm0   // B-W low byte == $00
      movq mm2, [mvC3];    // Load Filter mm2
      pmullw mm1, mm2;     // Mult
      paddsw mm7, mm1;     // Add


//      psrlw mm7, 2;        // Div 4

      // Pack back
 //     packssdw mm7,mm7
      packuswb mm7,mm7

      movd eax, mm7;
      or eax, $FF000000;       // Keep Alpha
      mov [D], eax;            // Store Result
    end;

    // Write Back
    Dst.Pixel[I,J] := D;
  end;
  asm
    EMMS;
  end;

  Dst.Changed;
end;

end.
