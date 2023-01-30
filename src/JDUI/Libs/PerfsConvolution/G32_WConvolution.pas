(*

 Adapted for G32 by Vladimir Vasilyev
 http://www.gamedev.narod.ru
 W-develop@mtu-net.ru
 Vladimir@tometric.ru


 References:
 Based on Harm's example of a 3 x 3 convolution using 24-bit bitmaps and scanline
 http://www.users.uswest.net/~sharman1/
 sharman1@uswest.net

*)

unit G32_WConvolution;

interface

Uses GR32,math;

Type
 TColorFunc = function(Color32: TColor32): Integer;
 TColorMode = (cmGray,cmRed,cmGreen,cmBlue,cmColor);


 procedure ConvolveI(ray : array of integer; z : word; aBmp : TBitmap32);
 procedure ConvolveI5x5(ray : array of integer; z : word; aBmp : TBitmap32);
 procedure Kuwahara5x5( aBmp : TBitmap32; ColorMode : TColorMode );

implementation


Uses GR32_Filters,GR32_Blend;


function Set255(Clr : integer) : integer;
asm
  MOV  EAX,Clr  // store value in EAX register (32-bit register)
  CMP  EAX,254  // compare it to 254
  JG   @SETHI   // if greater than 254 then go set to 255 (max value)
  CMP  EAX,1    // if less than 255, compare to 1
  JL   @SETLO   // if less than 1 go set to 0 (min value)
  RET           // otherwise it doesn't change, just exit
@SETHI:         // Set value to 255
  MOV  EAX,255  // Move 255 into the EAX register
  RET           // Exit (result value is the EAX register value)
@SETLO:         // Set value to 0
  MOV  EAX,0    // Move 0 into EAX register
end;            // Result is in EAX


procedure ConvolveI(ray : array of integer; z : word; aBmp : TBitmap32);
var
  O, T, C, B : PColor32Array; // Scanlines
  x, y       : integer;
  tBufr      : TBitmap32; // temp bitmap

  Red,Green,Blue     : Integer;
begin
  tBufr := TBitmap32.Create;
  CheckParams(tBufr,aBmp);
  tBufr.Assign(aBmp);

  for x := 1 to aBmp.Height - 2 do begin  // Walk scanlines
    O := aBmp.ScanLine[x];       // New Target (Original)
    T := tBufr.ScanLine[x-1];    //old x-1  (Top)
    C := tBufr.ScanLine[x];      //old x    (Center)
    B := tBufr.ScanLine[x+1];    //old x+1  (Bottom)
  // Now do the main piece

    for y := 1 to (tBufr.Width - 2) do begin  // Walk pixels

      Red:=Set255(
          (
          (RedComponent(T[y-1])*ray[0]) + (RedComponent(T[y])*ray[1]) + (RedComponent(T[y+1])*ray[2])+
          (RedComponent(C[y-1])*ray[3]) + (RedComponent(C[y])*ray[4]) + (RedComponent(C[y+1])*ray[5])+
          (RedComponent(B[y-1])*ray[6]) + (RedComponent(B[y])*ray[7]) + (RedComponent(B[y+1])*ray[8])
          ) div z );

      Green:=Set255(
          (
          (GreenComponent(T[y-1])*ray[0]) + (GreenComponent(T[y])*ray[1]) + (GreenComponent(T[y+1])*ray[2])+
          (GreenComponent(C[y-1])*ray[3]) + (GreenComponent(C[y])*ray[4]) + (GreenComponent(C[y+1])*ray[5])+
          (GreenComponent(B[y-1])*ray[6]) + (GreenComponent(B[y])*ray[7]) + (GreenComponent(B[y+1])*ray[8])
          ) div z );

      Blue:=Set255(
          (
          (BlueComponent(T[y-1])*ray[0]) + (BlueComponent(T[y])*ray[1]) + (BlueComponent(T[y+1])*ray[2])+
          (BlueComponent(C[y-1])*ray[3]) + (BlueComponent(C[y])*ray[4]) + (BlueComponent(C[y+1])*ray[5])+
          (BlueComponent(B[y-1])*ray[6]) + (BlueComponent(B[y])*ray[7]) + (BlueComponent(B[y+1])*ray[8])
          ) div z );

      O[y]:=Color32(Red, Green, Blue);
    end;
  end;
  tBufr.Free;
end;

procedure ConvolveI5x5(ray : array of integer; z : word; aBmp : TBitmap32);
var
  O, T,T2, C, B, B2 : PColor32Array; // Scanlines
  x, y              : integer;
  tBufr             : TBitmap32; // temp bitmap
  Red,Green,Blue    : Integer;

begin
  tBufr := TBitmap32.Create;
  CheckParams(tBufr,aBmp);
  tBufr.Assign(aBmp);

  for x := 2 to aBmp.Height - 3 do begin // Walk scanlines
    O := aBmp.ScanLine[x];     // New Target (Original)
    T2:= tBufr.ScanLine[x-2];  //old x-2  (Top)
    T := tBufr.ScanLine[x-1];  //old x-1  (Top)
    C := tBufr.ScanLine[x];    //old x    (Center)
    B := tBufr.ScanLine[x+1];  //old x+1  (Bottom)
    B2:= tBufr.ScanLine[x+2];  //old x+2  (Bottom)

  // Now do the main piece
    for y := 2 to (tBufr.Width - 3) do begin  // Walk pixels

    //NS:=0;
    //for i:=0 to 4 do

      Red := Set255(
         (
RedComponent(T2[y-2])*ray[0] + RedComponent(T2[y-1])*ray[1] + RedComponent(T2[y])*ray[2] + RedComponent(T2[y+1])*ray[3] + RedComponent(T2[y+2])*ray[4]+
RedComponent( T[y-2])*ray[5] + RedComponent( T[y-1])*ray[6] + RedComponent( T[y])*ray[7] + RedComponent( T[y+1])*ray[8] + RedComponent( T[y+2])*ray[9]+
RedComponent( C[y-2])*ray[10]+ RedComponent( C[y-1])*ray[11]+ RedComponent( C[y])*ray[12]+ RedComponent( C[y+1])*ray[13]+ RedComponent( C[y+2])*ray[14]+
RedComponent( B[y-2])*ray[15]+ RedComponent( B[y-1])*ray[16]+ RedComponent( B[y])*ray[17]+ RedComponent( B[y+1])*ray[18]+ RedComponent( B[y+2])*ray[19]+
RedComponent(B2[y-2])*ray[20]+ RedComponent(B2[y-1])*ray[21]+ RedComponent(B2[y])*ray[22]+ RedComponent(B2[y+1])*ray[23]+ RedComponent(B2[y+2])*ray[24]
          ) div z   );

      Blue := Set255(
         (
BlueComponent(T2[y-2])*ray[0] + BlueComponent(T2[y-1])*ray[1] + BlueComponent(T2[y])*ray[2] + BlueComponent(T2[y+1])*ray[3] + BlueComponent(T2[y+2])*ray[4]+
BlueComponent( T[y-2])*ray[5] + BlueComponent( T[y-1])*ray[6] + BlueComponent( T[y])*ray[7] + BlueComponent( T[y+1])*ray[8] + BlueComponent( T[y+2])*ray[9]+
BlueComponent( C[y-2])*ray[10]+ BlueComponent( C[y-1])*ray[11]+ BlueComponent( C[y])*ray[12]+ BlueComponent( C[y+1])*ray[13]+ BlueComponent( C[y+2])*ray[14]+
BlueComponent( B[y-2])*ray[15]+ BlueComponent( B[y-1])*ray[16]+ BlueComponent( B[y])*ray[17]+ BlueComponent( B[y+1])*ray[18]+ BlueComponent( B[y+2])*ray[19]+
BlueComponent(B2[y-2])*ray[20]+ BlueComponent(B2[y-1])*ray[21]+ BlueComponent(B2[y])*ray[22]+ BlueComponent(B2[y+1])*ray[23]+ BlueComponent(B2[y+2])*ray[24]
          ) div z );

      Green := Set255(
         (
GreenComponent(T2[y-2])*ray[0] + GreenComponent(T2[y-1])*ray[1] + GreenComponent(T2[y])*ray[2] + GreenComponent(T2[y+1])*ray[3] + GreenComponent(T2[y+2])*ray[4]+
GreenComponent( T[y-2])*ray[5] + GreenComponent( T[y-1])*ray[6] + GreenComponent( T[y])*ray[7] + GreenComponent( T[y+1])*ray[8] + GreenComponent( T[y+2])*ray[9]+
GreenComponent( C[y-2])*ray[10]+ GreenComponent( C[y-1])*ray[11]+ GreenComponent( C[y])*ray[12]+ GreenComponent( C[y+1])*ray[13]+ GreenComponent( C[y+2])*ray[14]+
GreenComponent( B[y-2])*ray[15]+ GreenComponent( B[y-1])*ray[16]+ GreenComponent( B[y])*ray[17]+ GreenComponent( B[y+1])*ray[18]+ GreenComponent( B[y+2])*ray[19]+
GreenComponent(B2[y-2])*ray[20]+ GreenComponent(B2[y-1])*ray[21]+ GreenComponent(B2[y])*ray[22]+ GreenComponent(B2[y+1])*ray[23]+ GreenComponent(B2[y+2])*ray[24]
          ) div z    );

      O[y]:=Color32(Red, Green, Blue);

    end;
  end;

  tBufr.Free;


end;


procedure Kuwahara5x5( aBmp : TBitmap32; ColorMode : TColorMode );
Var
  O, T,T2,C,B,B2  : PColor32Array; // Scanlines
  NS,i,j,k,n      : integer;
  x, y            : integer;
  tBufr           : TBitmap32; // temp bitmap
  Red,Green,Blue  : Integer;

  Region1         : array of Double;
  Region2         : array of Double;
  Region3         : array of Double;
  Region4         : array of Double;

  Mean            : array[1..4] of Extended;
  StdDev          : array[1..4] of Extended;

  minStdDev       : Extended;

  ColorFunc       : TColorFunc;
  Color           : array [0..3] of integer;
  step            : integer;
  c1,c2           : integer;
Begin

tBufr := TBitmap32.Create;
Try

  CheckParams(tBufr,aBmp);
  tBufr.Assign(aBmp);


  for x := 2 to aBmp.Height - 3 do
  begin
    O := aBmp.ScanLine[x];     // New Target (Original)

    T2:= tBufr.ScanLine[x-2];  //old x-2  (Top)
    T := tBufr.ScanLine[x-1];  //old x-1  (Top)
    C := tBufr.ScanLine[x];    //old x    (Center)
    B := tBufr.ScanLine[x+1];  //old x+1  (Bottom)
    B2:= tBufr.ScanLine[x+2];  //old x+2  (Bottom)


    //Now slide the region 5x5
    for y := 2 to (tBufr.Width - 3) do
     begin


          //fill regions array
          SetLength(Region1,6);
          SetLength(Region2,6);
          SetLength(Region3,6);
          SetLength(Region4,6);


          Case ColorMode of
             cmColor : begin
                        c1:=1;
                        c2:=3;
                       end;
             else
                        c1:=Ord(ColorMode);
                        c2:=Ord(ColorMode);
             end;

          for step:=c1 to c2 do
          begin

             case step of
               0 : ColorFunc:=Intensity;
               1 : ColorFunc:=RedComponent;
               2 : ColorFunc:=GreenComponent;
               else ColorFunc:=BlueComponent;
             end;

             for i:=0 to 2 do
               for j:=0 to 1 do
                begin
                   k:=j*3+i;
                   case j of
                     0 : Region1[k]:=ColorFunc(T[y-i]);
                     1 : Region1[k]:=ColorFunc(T2[y-i]);
                   end;
                end;

             for i:=0 to 2 do
               for j:=0 to 1 do
                begin
                   k:=j*3+i;
                   case j of
                     0 : Region4[k]:=ColorFunc(B[y+i]);
                     1 : Region4[k]:=ColorFunc(B2[y+i]);
                   end;
                end;

             for i:=0 to 1 do
               for j:=0 to 2 do
                begin
                   k:=j*2+i;
                   case j of
                     0 : Region2[k]:=ColorFunc(C[y+i]);
                     1 : Region2[k]:=ColorFunc(T[y+i]);
                     2 : Region2[k]:=ColorFunc(T2[y+i]);
                   end;
                end;

             for i:=0 to 1 do
               for j:=0 to 2 do
                begin
                   k:=j*2+i;
                   case j of
                     0 : Region3[k]:=ColorFunc(C[y-i]);
                     1 : Region3[k]:=ColorFunc(B[y-i]);
                     2 : Region3[k]:=ColorFunc(B2[y-i]);
                   end;
                end;

             //MeanAndStdDev(Region1, Mean[1], StdDev[1]);
             //MeanAndStdDev(Region2, Mean[2], StdDev[2]);
             //MeanAndStdDev(Region3, Mean[3], StdDev[3]);
             //MeanAndStdDev(Region4, Mean[4], StdDev[4]);

             minStdDev:=StdDev[1];
             n:=1;
             for i:=2 to 4 do
              if StdDev[i]<minStdDev then
               begin
                 minStdDev:=StdDev[i];
                 n:=i;
               end;

             Color[step]:=Round(Mean[n]);

          end;//step

          Case ColorMode of
             cmGray  : O[y]:=Gray32( Color[0] );
             cmRed   : O[y]:=Color32(Color[1],0,0);
             cmGreen : O[y]:=Color32(0,Color[2],0);
             cmBlue  : O[y]:=Color32(0,0,Color[3]);
             cmColor : O[y]:=Color32(Color[1],Color[2],Color[3]);
          end;

    end;//y
  end;//x

finally
 tBufr.Free;
end;

end;




{
procedure Contrast(Amount: integer);
var
  x,y: Integer;
  Table1: array [0..255] of Byte;
  i: Byte;
  S,D: pointer;
  Temp1: TDIB;
  color: DWORD;
  P: PByte;
  R, G, B: Byte;

begin
  D := nil;
  S := nil;
  Temp1 := nil;
  for i := 0 to 126 do
    begin
      y := (Abs(128 - i) * Amount) div 256;
      Table1[i] := IntToByte(i - y);
    end;
  for i := 127 to 255 do
    begin
      y := (Abs(128 - i) * Amount) div 256;
      Table1[i] := IntToByte(i + y);
    end;
  case BitCount of
    32 : Exit;  // I haven't bitmap of this type ! Sorry
    24 : ;      // nothing to do
    16 : ;  // I have an artificial bitmap for this type ! i don't sure that it works
    8,4 :
      begin
        Temp1 := TDIB.Create;
        Temp1.Assign(self);
        Temp1.SetSize(Width, Height, BitCount);
        for i := 0 to 255 do
          begin
            with ColorTable[i] do
              begin
                rgbRed := IntToByte(Table1[rgbRed]);
                rgbGreen := IntToByte(Table1[rgbGreen]);
                rgbBlue := IntToByte(Table1[rgbBlue]);
              end;
          end;
        UpdatePalette;
      end;
  else
    // if the number of pixel is equal to 1 then exit of procedure
    Exit;
  end;
  for y := 0 to Pred(Height) do
    begin
      case BitCount of
        24, 16 : D := ScanLine[y];
        8,4  :
          begin
            D := Temp1.ScanLine[y];
            S := Temp1.ScanLine[y];
          end;
      else
      end;
      for x := 0 to Pred(Width) do
        begin
          case BitCount of
            32 : ;
            24 :
              begin
                PBGR(D)^.B := Table1[PBGR(D)^.B];
                PBGR(D)^.G := Table1[PBGR(D)^.G];
                PBGR(D)^.R := Table1[PBGR(D)^.R];
                Inc(PBGR(D));
              end;
            16 :
              begin
                pfGetRGB(NowPixelFormat, PWord(D)^, R, G, B);
                PWord(D)^ := Table1[R] + Table1[G] + Table1[B];
                Inc(PWord(D));
              end;
            8 :
              begin
                with Temp1.ColorTable[PByte(S)^] do
                  color := rgbRed + rgbGreen + rgbBlue;
                Inc(PByte(S));
                PByte(D)^ := color;
                Inc(PByte(D));
              end;
            4 :
              begin
                with Temp1.ColorTable[PByte(S)^] do
                  color := rgbRed + rgbGreen + rgbBlue;
                Inc(PByte(S));
                P := @PArrayByte(D)[X shr 1];
                P^ := (P^ and Mask4n[X and 1]) or (color shl Shift4[X and 1]);
              end;
          else
          end;
        end;
    end;
  Case BitCount of
    8,4 : Temp1.Free;
  else
  end;
end;
}

end.
