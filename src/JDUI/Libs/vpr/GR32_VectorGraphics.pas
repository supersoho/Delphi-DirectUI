unit GR32_VectorGraphics;

(* ***** BEGIN LICENSE BLOCK *****
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
 * The Original Code is Vectorial Polygon Rasterizer for Graphics32
 *
 * The Initial Developer of the Original Code is
 * Mattias Andersson <mattias@centaurix.com>
 *
 * Portions created by the Initial Developer are Copyright (C) 2008-2009
 * the Initial Developer. All Rights Reserved.
 *
 * Contributor(s):
 *
 * ***** END LICENSE BLOCK ***** *)

interface

uses
  Classes, GR32, GR32_Transforms, GR32_VectorUtils;

type
  { TCustomVectorGraphics }
  TCustomVectorGraphics = class(TPersistent)
  private
  public
    procedure SetStrokeDashArray(const DashArray: array of TFloat); virtual; abstract;
    procedure SetStrokeDashOffset(const Offset: TFloat); virtual; abstract;
    procedure SetStrokeColor(const Color: TColor32); virtual; abstract;
    procedure SetFillColor(const Color: TColor32); virtual; abstract;
    procedure SetFillOpacity(const Opacity: TFloat); virtual; abstract;
    procedure SetStrokeOpacity(const Opacity: TFloat); virtual; abstract;
    procedure SetStrokeWidth(const Width: TFloat); virtual; abstract;
    procedure SetJoinStyle(const Value: TJoinStyle); virtual; abstract;
    procedure SetEndStyle(const Value: TEndStyle); virtual; abstract;
    procedure MoveTo(const X, Y: TFloat); overload;
    procedure MoveTo(const P: TFloatPoint); overload; virtual; abstract;
    procedure LineTo(const X, Y: TFloat); overload;
    procedure LineTo(const P: TFloatPoint); overload; virtual; abstract;
    procedure CurveTo(const X1, Y1, X2, Y2, X, Y: TFloat); overload;
    procedure CurveTo(const P1, P2, P: TFloatPoint); overload; virtual; abstract;
    procedure BeginPath; virtual; abstract;
    procedure EndPath; virtual; abstract;
    procedure ClosePath; virtual; abstract;
  end;

  // TPathRenderer.RenderObject(VectorObject);
  TPathCommand = (pcEndOfFile, pcBeginPath, pcEndPath, pcMoveTo, pcLineTo, pcCurveTo, pcClosePath, pcSetStrokeColor,
    pcSetFillColor, pcSetStrokeOpacity, pcSetFillOpacity, pcSetStrokeWidth);

  { TVectorStorage }
  TVectorStorage = class(TCustomVectorGraphics)
  private
    FStream: TStream;
    procedure WritePoint(const Point: TFloatPoint);
    procedure WriteColor(const Color: TColor32);
    procedure WriteFloat(const Value: TFloat);
    procedure WriteCommand(Command: TPathCommand);
    function ReadPoint: TFloatPoint;
    function ReadColor: TColor32;
    function ReadFloat: TFloat;
    function ReadCommand: TPathCommand;
    procedure WriteData(Dest: TCustomVectorGraphics);
  protected
    procedure AssignTo(Dest: TPersistent); override;
  public
    constructor Create;
    destructor Destroy; override;
    function GetStream: TStream; virtual;
    procedure SetStrokeColor(const Color: TColor32); override;
    procedure SetFillColor(const Color: TColor32); override;
    procedure SetFillOpacity(const Opacity: TFloat); override;
    procedure SetStrokeOpacity(const Opacity: TFloat); override;
    procedure SetStrokeWidth(const Width: TFloat); override;
    procedure MoveTo(const P: TFloatPoint); override;
    procedure LineTo(const P: TFloatPoint); override;
    procedure CurveTo(const P1, P2, P: TFloatPoint); override;
    procedure BeginPath; override;
    procedure EndPath; override;
    procedure ClosePath; override;
  end;

  { TPathRenderer }
  TPathRenderer = class(TCustomVectorGraphics)
  private
    FStrokeWidth: TFloat;
    FStrokeColor: TColor32;
    FFillColor: TColor32;
    FFillOpacity: TFloat;
    FCurrentPoint: TFloatPoint;
    FBitmap: TBitmap32;
    FPath: TArrayOfArrayOfFloatPoint;
    FPoints: TArrayOfFloatPoint;
    FPointIndex: Integer;
    FStrokeOpacity: TFloat;
    FStrokeDashOffset: TFloat;
    FStrokeDashArray: TArrayOfFloat;
    FJoinStyle: TJoinStyle;
    FEndStyle: TEndStyle;
    FTransform: TTransformation;
    procedure SetBitmap(const Value: TBitmap32);
    procedure SetTransform(const Value: TTransformation);
  protected
    procedure AddPoint(const Point: TFloatPoint);
    property CurrentPoint: TFloatPoint read FCurrentPoint;
  public
    constructor Create;
    procedure SetFillColor(const Color: TColor32); override;
    procedure SetStrokeColor(const Color: TColor32); override;
    procedure SetStrokeWidth(const Value: TFloat); override;
    procedure SetStrokeDashArray(const DashArray: array of TFloat); override;
    procedure SetStrokeDashOffset(const Offset: TFloat); override;
    procedure SetFillOpacity(const Value: TFloat); override;
    procedure SetStrokeOpacity(const Value: TFloat); override;
    procedure SetJoinStyle(const Value: TJoinStyle); override;
    procedure SetEndStyle(const Value: TEndStyle); override;
    procedure MoveTo(const P: TFloatPoint); override;
    procedure LineTo(const P: TFloatPoint); override;
    procedure CurveTo(const P1, P2, P: TFloatPoint); override;
    procedure ClosePath; override;
    procedure BeginPath; override;
    procedure EndPath; override;
    procedure DrawPath;
    property StrokeWidth: TFloat read FStrokeWidth write SetStrokeWidth;
    property StrokeColor: TColor32 read FStrokeColor write SetStrokeColor;
    property StrokeOpacity: TFloat read FStrokeOpacity write SetStrokeOpacity;
    property FillColor: TColor32 read FFillColor write SetFillColor;
    property FillOpacity: TFloat read FFillOpacity write SetFillOpacity;
    property Bitmap: TBitmap32 read FBitmap write SetBitmap;
    property Transform: TTransformation read FTransform write SetTransform;
    property JoinStyle: TJoinStyle read FJoinStyle write SetJoinStyle;
    property EndStyle: TEndStyle read FEndStyle write SetEndStyle;
  end;

implementation

uses
  GR32_PolygonsEx, GR32_Polygons;
  
type
  TAddPointEvent = procedure(const Point: TFloatPoint) of object;

var
  BezierTolerance: Single = 0.25;

function Flatness(P1, P2, P3, P4: TFloatPoint): Single;
begin
  Result :=
    Abs(P1.X + P3.X - 2*P2.X) +
    Abs(P1.Y + P3.Y - 2*P2.Y) +
    Abs(P2.X + P4.X - 2*P3.X) +
    Abs(P2.Y + P4.Y - 2*P3.Y);
end;

procedure BezierCurve(const P1, P2, P3, P4: TFloatPoint; const AddPoint: TAddPointEvent);
var
  P12, P23, P34, P123, P234, P1234: TFloatPoint;
begin
  if Flatness(P1, P2, P3, P4) < BezierTolerance then
  begin
    AddPoint(P1);
  end
  else
  begin
    P12.X   := (P1.X + P2.X) * 0.5;
    P12.Y   := (P1.Y + P2.Y) * 0.5;
    P23.X   := (P2.X + P3.X) * 0.5;
    P23.Y   := (P2.Y + P3.Y) * 0.5;
    P34.X   := (P3.X + P4.X) * 0.5;
    P34.Y   := (P3.Y + P4.Y) * 0.5;
    P123.X  := (P12.X + P23.X) * 0.5;
    P123.Y  := (P12.Y + P23.Y) * 0.5;
    P234.X  := (P23.X + P34.X) * 0.5;
    P234.Y  := (P23.Y + P34.Y) * 0.5;
    P1234.X := (P123.X + P234.X) * 0.5;
    P1234.Y := (P123.Y + P234.Y) * 0.5;

    BezierCurve(P1, P12, P123, P1234, AddPoint);
    BezierCurve(P1234, P234, P34, P4, AddPoint);
  end;
end;

{ TPathRenderer }

procedure TPathRenderer.ClosePath;
var
  N: Integer;
begin
  N := Length(FPath);
  SetLength(FPath, N + 1);
  FPath[N] := Copy(FPoints, 0, FPointIndex);
  FPoints := nil;
  FPointIndex := 0;  
end;

procedure TPathRenderer.MoveTo(const P: TFloatPoint);
begin
  FCurrentPoint := P;
  if Length(FPoints) <> 0 then
    ClosePath;
  AddPoint(P);
end;

procedure TPathRenderer.SetBitmap(const Value: TBitmap32);
begin
  FBitmap := Value;
end;

procedure TPathRenderer.SetFillColor(const Color: TColor32);
begin
  FFillColor := Color;
end;

procedure TPathRenderer.SetFillOpacity(const Value: TFloat);
begin
  FFillOpacity := Value;
end;

procedure TPathRenderer.SetStrokeColor(const Color: TColor32);
begin
  FStrokeColor := Color;
end;

procedure TPathRenderer.SetStrokeWidth(const Value: TFloat);
begin
  FStrokeWidth := Value;
end;

procedure TPathRenderer.CurveTo(const P1, P2, P: TFloatPoint);
begin
  BezierCurve(FCurrentPoint, P1, P2, P, AddPoint);
  FCurrentPoint := P;
end;

procedure TPathRenderer.LineTo(const P: TFloatPoint);
begin
  AddPoint(P);
  FCurrentPoint := P;
end;

procedure TPathRenderer.BeginPath;
begin
  FPath := nil;
  FPoints := nil;
  FPointIndex := 0;
end;

procedure TPathRenderer.SetStrokeOpacity(const Value: TFloat);
begin
  FStrokeOpacity := Value;
end;

procedure TPathRenderer.AddPoint(const Point: TFloatPoint);
var
  L: Integer;
begin
  L := Length(FPoints);
  if FPointIndex >= L then SetLength(FPoints, 2 * (L + 1));
  if Assigned(FTransform) then
    FPoints[FPointIndex] := FTransform.Transform(Point)
  else
    FPoints[FPointIndex] := Point;
  Inc(FPointIndex);
end;

procedure TPathRenderer.DrawPath;
var
  FC, SC: TColor32;
begin
  FC := FFillColor and $ffffff or (TColor32(Round(FFillOpacity * 255)) shl 24);
  SC := FStrokeColor and $ffffff or (TColor32(Round(FStrokeOpacity * 255)) shl 24);
  PolyPolygonFS(FBitmap, FPath, FC, pfWinding);
  if (FStrokeWidth > 0) and (FStrokeColor shr 24 <> 0) then
  begin
    PolyPolylineFS(FBitmap, FPath, SC, True, FStrokeWidth, FJoinStyle, FEndStyle);
    if Length(FPoints) > 0 then
      PolylineFS(FBitmap, Copy(FPoints, 0, FPointIndex), SC, False, FStrokeWidth, FJoinStyle, FEndStyle);
  end;
end;

procedure TPathRenderer.EndPath;
begin
  DrawPath;
end;

constructor TPathRenderer.Create;
begin
  FFillOpacity := 1;
  FStrokeOpacity := 1;
end;

procedure TPathRenderer.SetTransform(const Value: TTransformation);
begin
  FTransform := Value;
end;

procedure TPathRenderer.SetEndStyle(const Value: TEndStyle);
begin
  FEndStyle := Value;
end;

procedure TPathRenderer.SetJoinStyle(const Value: TJoinStyle);
begin
  FJoinStyle := Value;
end;

procedure TPathRenderer.SetStrokeDashArray(
  const DashArray: array of TFloat);
var
  L: Integer;
begin
  L := Length(DashArray);
  SetLength(FStrokeDashArray, L);
  Move(DashArray[0], FStrokeDashArray[0], L * SizeOf(TFloat));
end;

procedure TPathRenderer.SetStrokeDashOffset(const Offset: TFloat);
begin
  FStrokeDashOffset := Offset;
end;

{ TCustomVectorGraphics }

procedure TCustomVectorGraphics.CurveTo(const X1, Y1, X2, Y2, X, Y: TFloat);
begin
  CurveTo(FloatPoint(X1, Y1), FloatPoint(X2, Y2), FloatPoint(X, Y));
end;

procedure TCustomVectorGraphics.LineTo(const X, Y: TFloat);
begin
  LineTo(FloatPoint(X, Y));
end;

procedure TCustomVectorGraphics.MoveTo(const X, Y: TFloat);
begin
  MoveTo(FloatPoint(X, Y));
end;

{ TVectorStorage }

procedure TVectorStorage.AssignTo(Dest: TPersistent);
begin
  if Dest is TCustomVectorGraphics then
    WriteData(TCustomVectorGraphics(Dest));
end;

procedure TVectorStorage.ClosePath;
begin
  WriteCommand(pcClosePath);
end;

constructor TVectorStorage.Create;
begin
  FStream := GetStream;
end;

procedure TVectorStorage.CurveTo(const P1, P2, P: TFloatPoint);
begin
  WriteCommand(pcCurveTo);
  WritePoint(P1);
  WritePoint(P2);
  WritePoint(P);
end;

destructor TVectorStorage.Destroy;
begin
  FStream.Free;
  inherited;
end;

function TVectorStorage.GetStream: TStream;
begin
  Result := FStream;
  if not Assigned(Result) then
    Result := TMemoryStream.Create;
end;

procedure TVectorStorage.LineTo(const P: TFloatPoint);
begin
  WriteCommand(pcLineTo);
  WritePoint(P);
end;

procedure TVectorStorage.MoveTo(const P: TFloatPoint);
begin
  WriteCommand(pcMoveTo);
  WritePoint(P);
end;

procedure TVectorStorage.BeginPath;
begin
  WriteCommand(pcBeginPath);
end;

function TVectorStorage.ReadColor: TColor32;
begin
  FStream.Read(Result, SizeOf(TColor32));
end;

function TVectorStorage.ReadCommand: TPathCommand;
begin
  FStream.Read(Result, SizeOf(TPathCommand));
end;

function TVectorStorage.ReadFloat: TFloat;
begin
  FStream.Read(Result, SizeOf(TFloat));
end;

function TVectorStorage.ReadPoint: TFloatPoint;
begin
  FStream.Read(Result, SizeOf(TFloatPoint));
end;

procedure TVectorStorage.SetFillColor(const Color: TColor32);
begin
  WriteCommand(pcSetFillColor);
  WriteColor(Color);
end;

procedure TVectorStorage.SetFillOpacity(const Opacity: TFloat);
begin
  WriteCommand(pcSetFillOpacity);
  WriteFloat(Opacity);
end;

procedure TVectorStorage.SetStrokeColor(const Color: TColor32);
begin
  WriteCommand(pcSetStrokeColor);
  WriteColor(Color);
end;

procedure TVectorStorage.SetStrokeOpacity(const Opacity: TFloat);
begin
  WriteCommand(pcSetStrokeOpacity);
  WriteFloat(Opacity);
end;

procedure TVectorStorage.WriteColor(const Color: TColor32);
begin
  FStream.Write(Color, SizeOf(TColor32));
end;

procedure TVectorStorage.WriteCommand(Command: TPathCommand);
begin
  FStream.Write(Command, SizeOf(TPathCommand));
end;

//  TPathCommand = (pcEndOfFile, pcMoveTo, pcLineTo, pcCurveTo, pcClosePath, pcSetStrokeColor,
//    pcSetFillColor, psSetStrokeOpacity, pcSetStrokeOpacity, pcSetStrokeWidth);

procedure TVectorStorage.WriteData(Dest: TCustomVectorGraphics);

  procedure ReadCurveTo;
  var
    P1, P2, P: TFloatPoint;
  begin
    P1 := ReadPoint;
    P2 := ReadPoint;
    P := ReadPoint;
    Dest.CurveTo(P1, P2, P);
  end;

begin
  FStream.Seek(soFromBeginning, 0);
  while FStream.Position < FStream.Size do
  begin
    case ReadCommand of
      pcMoveTo: Dest.MoveTo(ReadPoint);
      pcLineTo: Dest.LineTo(ReadPoint);
      pcCurveTo: ReadCurveTo;
      pcBeginPath: Dest.BeginPath;
      pcEndPath: Dest.EndPath;
      pcClosePath: Dest.ClosePath;
      pcSetFillColor: Dest.SetFillColor(ReadColor);
      pcSetFillOpacity: Dest.SetFillOpacity(ReadFloat);
      pcSetStrokeColor: Dest.SetStrokeColor(ReadColor);
      pcSetStrokeOpacity: Dest.SetStrokeOpacity(ReadFloat);
      pcSetStrokeWidth: Dest.SetStrokeWidth(ReadFloat);
      pcEndOfFile: Exit;
    end;
  end;
end;

procedure TVectorStorage.WriteFloat(const Value: TFloat);
begin
  FStream.Write(Value, SizeOf(TFloat));
end;

procedure TVectorStorage.WritePoint(const Point: TFloatPoint);
begin
  FStream.Write(Point, SizeOf(TFloatPoint));
end;

procedure TVectorStorage.EndPath;
begin
  WriteCommand(pcEndPath);
end;

procedure TVectorStorage.SetStrokeWidth(const Width: TFloat);
begin
  WriteCommand(pcSetStrokeWidth);
  WriteFloat(Width);
end;

end.
