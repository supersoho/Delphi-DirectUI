unit JDUIObjects;

interface

uses
  SysUtils,
  Vcl.Graphics,
  Generics.Collections,
  G32_Interface,
  GR32_Misc,
  GR32,
  GR32_Lines;

type
  TJDUIObjects = class
  private
  public
    class function GetCircle(ASize: Integer): TBitmap32;
    class function GetRoundRect(AWidth, AHeight: Integer; ARoundSize: Single; AColor: TColor32): TBitmap32;
  end;

implementation

var
   FObjectCache: TDictionary<String, TBitmap32>;

function GetRoundedFixedRectanglePoints(const Rect: TFloatRect; dx, dy: single): TArrayOfFixedPoint;
var
  i, j, k, arcLen: integer;
  arcs: array [0 .. 3] of TArrayOfFixedPoint;
begin
  //nb: it's simpler to construct the rounded rect in an anti-clockwise
  //direction because that's the direction in which the arc points are returned.

  with Rect do
  begin
    arcs[0] := GetArcPointsEccentric(
      FloatRect(Left, Bottom -dy*2, Left+dx*2, Bottom), rad180, rad270);
    arcs[1] := GetArcPointsEccentric(
      FloatRect(Right-dx*2, Bottom -dy*2, Right, Bottom), rad270, 0);
    arcs[2] := GetArcPointsEccentric(
      FloatRect(Right - dx*2, Top, Right, Top + dy*2), 0, rad90);
    arcs[3] := GetArcPointsEccentric(
      FloatRect(Left, top, Left+dx*2, Top+dy*2), rad90, rad180);

    //close the rectangle
    SetLength(arcs[3], Length(arcs[3])+1);
    arcs[3][Length(arcs[3])-1] := arcs[0][0];
  end;

  //calculate the final number of points to return
  j := 0;
  for i := 0 to 3 do
    Inc(j, Length(arcs[i]));
  SetLength(Result, j);

  j := 0;
  for i := 0 to 3 do
  begin
    arcLen := Length(arcs[i]);
    for k := 0 to arcLen -1 do
      Result[j+k] := arcs[i][k];
    Inc(j, arcLen);
  end;
end;

class function TJDUIObjects.GetCircle(ASize: Integer): TBitmap32;
var
  pts: TArrayOfFixedPoint;
  AKey: String;
begin
  AKey := Format('Circle_%d', [ASize]);
  if FObjectCache.ContainsKey(AKey) then Exit(FObjectCache[AKey]);

  Result := TBitmap32.Create;
  Result.SetSize(ASize, ASize);
  Result.Clear(0);
  //G32_Interface.gEllipse(Result, GR32.FixedRect(0, 0, ASize - 0, ASize - 0), clWhite32, pdoFilling or pdoFloat);
  pts := GetEllipsePoints(FloatRect(0, 0, ASize - 0, ASize - 0));

  SimpleFill(Result, pts, 0, Color32(clWhite));
  FObjectCache.Add(AKey, Result)
end;

class function TJDUIObjects.GetRoundRect(AWidth, AHeight: Integer; ARoundSize: Single; AColor: TColor32): TBitmap32;
var
  pts: TArrayOfFixedPoint;
  AKey: String;
begin
  AKey := Format('RoundRect_%d_%d_%f_%d', [AWidth, AHeight, ARoundSize, AColor]);
  if FObjectCache.ContainsKey(AKey) then Exit(FObjectCache[AKey]);

  Result := TBitmap32.Create;
  Result.SetSize(AWidth, AHeight);
  Result.Clear(0);
  pts := GetRoundedFixedRectanglePoints(FloatRect(0, 0, AWidth, AHeight), ARoundSize, ARoundSize);

  SimpleFill(Result, pts, AColor, AColor);
  FObjectCache.Add(AKey, Result);
end;

procedure ClearObjectCache;
var
  ABitmap: TBitmap32;
begin
  for ABitmap in  FObjectCache.Values do ABitmap.Free;
end;

initialization
   FObjectCache := TDictionary<String, TBitmap32>.Create;

finalization
  ClearObjectCache;
  FObjectCache.Free;

end.
