unit GR32_CFDG;

interface

uses
  GR32, GR32_VectorGraphics, GR32_Transforms;

const
  DefaultNestingLevel = 30000;

type
  THSBAQuad = record
    H, S, B, A: TFloat;
  end;

  TFloatMatrix2 = array [0..1] of array [0..1] of TFloat;

  PCFDGEntry = ^TCFDGEntry;
  TCFDGEntry = record
    X, Y: TFloat;
    Matrix: TFloatMatrix2;
    Color: THSBAQuad;
  end;

  TCFDGStack = array of TCFDGEntry;

  { TCustomCFDGRenderer is a class that is used by the CFDG parser when
    rendering to the display. }
  TCustomCFDGRenderer = class(TNotifiablePersistent)
  private
    FStack: TCFDGStack;
    FStackIndex: Integer;
    FEntry: TCFDGEntry;
    FNestingLevel: Integer;
    FThreshold: TFloat;
    procedure SetNestingLevel(const Value: Integer); 
    function GetMatrix: TFloatMatrix2;
    procedure SetMatrix(const Value: TFloatMatrix2);
    procedure SetThreshold(const Value: TFloat);
  public
    constructor Create; virtual;
    function Push: Boolean; virtual;
    procedure Pop; virtual;
    procedure Translate(const Dx, Dy: TFloat); virtual;
    procedure Transform(const Dx, Dy: TFloat; out DstX, DstY: TFloat); virtual;
    procedure Rotate(const Theta: TFloat); virtual;
    procedure Flip(const Theta: TFloat); virtual;
    procedure Scale(const S: TFloat); overload;
    procedure Scale(const Sx, Sy: TFloat); overload; virtual;
    procedure Skew(const Fx, Fy: TFloat); virtual;
    procedure AddAlpha(A: TFloat); virtual;
    procedure AddHue(H: TFloat); virtual;
    procedure AddSat(S: TFloat); virtual;
    procedure AddBrightness(B: TFloat); virtual;
    procedure AddColor(const Color: THSBAQuad); virtual;
    procedure DrawCircle; virtual;
    procedure DrawTriangle; virtual;
    procedure DrawSquare; virtual;
    procedure Update; virtual;
    property NestingLevel: Integer read FNestingLevel write SetNestingLevel;
    property Matrix: TFloatMatrix2 read GetMatrix write SetMatrix;
    property Entry: TCFDGEntry read FEntry write FEntry;
    property Threshold: TFloat read FThreshold write SetThreshold;
  end;

  TCFDGRenderer = class(TCustomCFDGRenderer)
  private
    FRenderer: TCustomVectorGraphics;
    procedure SetRenderer(const Value: TCustomVectorGraphics);
  public
    procedure Rotate(const Theta: TFloat); override;
    procedure Flip(const Theta: TFloat); override;
    procedure Scale(const Sx, Sy: TFloat); overload; override;
    procedure Skew(const Fx, Fy: TFloat); override;
    procedure AddAlpha(A: TFloat); override;
    procedure AddHue(H: TFloat); override;
    procedure AddSat(S: TFloat); override;
    procedure AddBrightness(B: TFloat); override;
    procedure AddColor(const Color: THSBAQuad); override;
    procedure DrawCircle; override;
    procedure DrawTriangle; override;
    procedure DrawSquare; override;
    procedure Update; override;
    property Renderer: TCustomVectorGraphics read FRenderer write SetRenderer;
  end;

  TCFDGBoundsRenderer = class(TCustomCFDGRenderer)
  private
    FBounds: TFloatRect;
    FPixelCount: Integer;
    procedure SetPixelCount(const Value: Integer);
  public
    constructor Create; override;
    function Push: Boolean; override;
    procedure AddPoint(const X, Y: TFloat);
    procedure AddColor(const Color: THSBAQuad); override;
    procedure DrawCircle; override;
    procedure DrawTriangle; override;
    procedure DrawSquare; override;
    property Bounds: TFloatRect read FBounds write FBounds;
    property PixelCount: Integer read FPixelCount write SetPixelCount;
  end;

const
  Identity: TFloatMatrix2 = ((1, 0), (0, 1));
  ZeroColor: THSBAQuad = (H: 0; S: 0; B: 0; A: 0);
  DefaultEntry: TCFDGEntry = (
    X: 0; Y: 0;
    Matrix: ((1, 0), (0, 1));
    Color: (H: 0; S: 0; B: 0; A: 0);
  );

function Mult(const M1, M2: TFloatMatrix2): TFloatMatrix2;

function RotationMat(const Theta: TFloat): TFloatMatrix2;
function FlipMat(const Theta: TFloat): TFloatMatrix2;
function ScaleMat(const Sx, Sy: TFloat): TFloatMatrix2;
function SkewMat(const Fx, Fy: TFloat): TFloatMatrix2;

function HSBtoRGB(H, S, B, A: TFloat): TColor32;

implementation

uses
  Math, GR32_Math, GR32_LowLevel, GR32_VectorUtils;

const
  INF: TFloat = 1e20;

function Mult(const M1, M2: TFloatMatrix2): TFloatMatrix2;
begin
  Result[0][0] := M1[0][0] * M2[0][0] + M1[1][0] * M2[0][1];
  Result[0][1] := M1[0][1] * M2[0][0] + M1[1][1] * M2[0][1];
  Result[1][0] := M1[0][0] * M2[1][0] + M1[1][0] * M2[1][1];
  Result[1][1] := M1[0][1] * M2[1][0] + M1[1][1] * M2[1][1];
end;

function RotationMat(const Theta: TFloat): TFloatMatrix2;
const
  DegToRad = Pi/180;
var
  S, C: TFloat;
begin
  SinCos(Theta * DegToRad, S, C);
  Result[0][0] := C;
  Result[0][1] := S;
  Result[1][0] := -S;
  Result[1][1] := C;
end;

function FlipMat(const Theta: TFloat): TFloatMatrix2;
const
  DegToRad = Pi/90;
var
  S, C: TFloat;
begin
  SinCos(Theta * DegToRad, S, C);
  Result[0][0] := C;
  Result[0][1] := S;
  Result[1][0] := S;
  Result[1][1] := -C;
end;

function ScaleMat(const Sx, Sy: TFloat): TFloatMatrix2;
begin
  Result[0][0] := Sx;
  Result[0][1] := 0;
  Result[1][0] := 0;
  Result[1][1] := Sy;
end;

function SkewMat(const Fx, Fy: TFloat): TFloatMatrix2;
const
  DegToRad = Pi/180;
begin
  Result[0, 0] := 1;
  Result[1, 0] := Tan(Fx * DegToRad);
  Result[0, 1] := Tan(Fy * DegToRad);
  Result[1, 1] := 1;
end;

procedure HSVtoRGB(const H, S, V: Integer; var R, G, B: Byte);
const
  divisor: Integer = 255*60;
var
  f, hTemp,
  p, q, t, VS: Integer;
begin
  if S = 0 then  // achromatic:  shades of gray
  begin
    R := V;
    G := V;
    B := V;
  end else
  begin   // chromatic color
    if H = 360 then hTemp := 0
    else hTemp := H;

    f     := hTemp mod 60; // f is IN [0, 59]
    hTemp := hTemp div 60; // h is now IN [0..6]

    VS := V*S;
    p := V - VS div 255;                 // p = v * (1 - s)
    q := V - (VS*f) div divisor;         // q = v * (1 - s*f)
    t := V - (VS*(60 - f)) div divisor;  // t = v * (1 - s * (1 - f))

    case hTemp of
      0:
      begin
        R := V;
        G := t;
        B := p;
      end;
      1:
      begin
        R := q;
        G := V;
        B := p;
      end;
      2:
      begin
        R := p;
        G := V;
        B := t;
      end;
      3:
      begin
        R := p;
        G := q;
        B := V;
      end;
      4:
      begin
        R := t;
        G := p;
        B := V;
      end;
      5:
      begin
        R := V;
        G := p;
        B := q;
      end;
      else begin // should never happen; avoid compiler warning
        R := 0;
        G := 0;
        B := 0;
      end;
    end;
  end;
end;

(*
void HSBColor::getRGBA(agg::rgba& c) const
{
    // Determine which facet of the HSB hexcone we are in and how
	// far we are into this hextant.
    double hue = h / 60.0;; 
    double remainder, hex; 

	for(;;) {
        // try splitting the hue into an integer hextant in [0,6) and
        // a real remainder in [0,1)
		remainder = modf(hue, &hex);
		if (hex > -0.1 && hex < 5.1 && remainder >= 0)
			break;

        // We didn't get the ranges that we wanted. Adjust hue and try again.
		if (hex < 0 || remainder < 0)
			hue += 6.0;
		if (hex > 5.5)
			hue -= 6.0;
	}

	int hextant = (int)(hex + 0.5); // guaranteed to be in 0..5
    
    double p = b * (1 - s);
    double q = b * (1 - (s * remainder));
    double t = b * (1 - (s * (1 - remainder)));
    
    c.a = a;
    switch (hextant) {
        case 0:  
            c.r = b; c.g = t; c.b = p;
            return;
        case 1:  
            c.r = q; c.g = b; c.b = p;
            return;
        case 2:  
            c.r = p; c.g = b; c.b = t;
            return;
        case 3:  
            c.r = p; c.g = q; c.b = b;
            return;
        case 4:
            c.r = t; c.g = p; c.b = b;
            return;
        case 5:
            c.r = b; c.g = p; c.b = q;
            return;
        default: 	// this should never happen
            c.r = 0; c.g = 0; c.b = 0; c.a = 1;
            return;
    }
}
*)
function HSBtoRGB(H, S, B, A: TFloat): TColor32;
const
  DIV60: TFloat = 1/60;
var
  hue, rem: TFloat;
  hex, p, q, t, v: Integer;
begin
  hue := H * DIV60;
  hex := Floor(hue);
  rem := hue - hex;
  hex := Wrap(hex, 5);
  p := Round(b * (1 - s) * 255);
  q := Round(b * (1 - (s * rem)) * 255);
  t := Round(b * (1 - (s * (1 - rem))) * 255);
  v := Round(b * 255);
  case hex of
    0: Result := v shl 16 or t shl 8 or p;
    1: Result := q shl 16 or v shl 8 or p;
    2: Result := p shl 16 or v shl 8 or t;
    3: Result := p shl 16 or q shl 8 or v;
    4: Result := t shl 16 or p shl 8 or v;
    5: Result := v shl 16 or p shl 8 or q;
  end;
  Result := Result or Floor(A * 255) shl 24;
end;

function HSLAtoColor32(const HSLA: THSBAQuad): TColor32;
var
  H, S, L, A: Integer;
  R, G, B: Byte;
begin
  H := Clamp(Round(HSLA.H));
  S := Clamp(Round(HSLA.S*256));
  L := Clamp(Round(HSLA.B*256));
  A := Clamp(Round(HSLA.A*256));
  HSVtoRGB(H, S, L, R, G, B);
  TColor32Entry(Result).R := R;
  TColor32Entry(Result).G := G;
  TColor32Entry(Result).B := B;
  TColor32Entry(Result).A := A;
end;

{ TCustomCFDGRenderer }

function TCustomCFDGRenderer.GetMatrix: TFloatMatrix2;
begin
  Result := FEntry.Matrix;
end;

procedure TCustomCFDGRenderer.SetMatrix(const Value: TFloatMatrix2);
begin
  FEntry.Matrix := Value;
end;

procedure TCustomCFDGRenderer.SetNestingLevel(const Value: Integer);
begin
  if FNestingLevel <> Value then
  begin
    FNestingLevel := Value;
    SetLength(FStack, Value);
    FStackIndex := Value - 1;
  end;
end;

procedure TCustomCFDGRenderer.Pop;
begin
  Inc(FStackIndex);
  FEntry := FStack[FStackIndex];
end;

function TCustomCFDGRenderer.Push: Boolean;
begin
  //  Sqr(Matrix[0,0] * Matrix[1,1] - Matrix[1,0] * Matrix[0,1])
  //  DstY := Y + Dx * Matrix[0,1] + Dy * ;

  with FEntry do
    //Result := sqr((Matrix[0][0] + Matrix[0][1])) + sqr((Matrix[1][0] + Matrix[1][1])) > 0.1;
    Result := Abs(Matrix[0,0] * Matrix[1,1] - Matrix[1,0] * Matrix[0,1]) > FThreshold;
  Result := Result and (FStackIndex >= 0);
  if Result then
  begin
    FStack[FStackIndex] := FEntry;
    Dec(FStackIndex);
    Result := True;
  end;
end;


constructor TCustomCFDGRenderer.Create;
begin
  inherited;
  NestingLevel := DefaultNestingLevel;
  FEntry.Matrix := Identity;
  FEntry.Color.A := 1;
  FThreshold := 0.1;
end;

procedure TCustomCFDGRenderer.Update;
begin

end;

procedure TCustomCFDGRenderer.SetThreshold(const Value: TFloat);
begin
  if FThreshold <> Value then
  begin
    FThreshold := Value;
    Changed;
  end;
end;

{ TCFDGRenderer }

procedure TCFDGRenderer.AddAlpha(A: TFloat);
begin
  FEntry.Color.A := FEntry.Color.A + A;
  Renderer.SetFillOpacity(Constrain(FEntry.Color.A, 0, 1));
end;

procedure TCFDGRenderer.AddHue(H: TFloat);
begin
  FEntry.Color.H := FEntry.Color.H + H;
  with FEntry.Color do Renderer.SetFillColor(HSBtoRGB(H, S, B, 1));
end;

procedure TCFDGRenderer.AddBrightness(B: TFloat);
begin
  FEntry.Color.B := FEntry.Color.B + B;
  with FEntry.Color do Renderer.SetFillColor(HSBtoRGB(H, S, B, 1));
end;

procedure TCFDGRenderer.AddSat(S: TFloat);
begin
  FEntry.Color.S := FEntry.Color.S + S;
  with FEntry.Color do Renderer.SetFillColor(HSBtoRGB(H, S, B, 1));
end;

procedure TCFDGRenderer.DrawCircle;
const
  MINSTEPS = 5;
  TWOPI = 2 * Pi;
var
  I, Steps: Integer;
  A, Ax, Ay, X, Y, RadMul: TFloat;
begin
  with FEntry do
    Steps := Max(MINSTEPS, Round(Sqrt(Sqr(Matrix[0][0]) + Sqr(Matrix[0][1]) + Sqr(Matrix[1][0]) + Sqr(Matrix[1][1])) * 0.5));
  RadMul := TWOPI / Steps;

  Renderer.BeginPath;
  Transform(0.5, 0, X, Y);
  Renderer.MoveTo(X, Y);
  for I := 1 to STEPS - 1 do
  begin
    A := I * RadMul;
    SinCos(A, 0.5, Ay, Ax);
    Transform(Ax, Ay, X, Y);
    Renderer.LineTo(X, Y);
  end;

  Renderer.ClosePath;
  Renderer.EndPath;
end;

procedure TCFDGRenderer.Flip(const Theta: TFloat);
const
  DegToRad = Pi/90;
var
  S, C: TFloat;
  M: TFloatMatrix2;
begin
  SinCos(Theta * DegToRad, S, C);
  M[0][0] := C;
  M[0][1] := S;
  M[1][0] := S;
  M[1][1] := -C;
  FEntry.Matrix := Mult(FEntry.Matrix, M);
end;

procedure TCFDGRenderer.Rotate(const Theta: TFloat);
const
  DegToRad = Pi/180;
var
  S, C: TFloat;
  M: TFloatMatrix2;
begin
  SinCos(Theta * DegToRad, S, C);
  M[0][0] := C;
  M[0][1] := S;
  M[1][0] := -S;
  M[1][1] := C;
  FEntry.Matrix := Mult(FEntry.Matrix, M);
end;

procedure TCFDGRenderer.Scale(const Sx, Sy: TFloat);
var
  M: TFloatMatrix2;
begin
  M[0][0] := Sx;
  M[0][1] := 0;
  M[1][0] := 0;
  M[1][1] := Sy;
  FEntry.Matrix := Mult(FEntry.Matrix, M);
end;

procedure TCFDGRenderer.Skew(const Fx, Fy: TFloat);
var
  M: TFloatMatrix2;
begin
  M := Identity;
  M[1, 0] := Fx;
  M[0, 1] := Fy;
  FEntry.Matrix := Mult(FEntry.Matrix, M);
end;

procedure TCustomCFDGRenderer.Translate(const Dx, Dy: TFloat);
begin
  with FEntry do
  begin
    X := X + Dx * Matrix[0,0] + Dy * Matrix[1,0];
    Y := Y + Dx * Matrix[0,1] + Dy * Matrix[1,1];
  end;
end;

procedure TCustomCFDGRenderer.Transform(const Dx, Dy: TFloat; out DstX, DstY: TFloat);
begin
  with FEntry do
  begin
    DstX := X + Dx * Matrix[0,0] + Dy * Matrix[1,0];
    DstY := Y + Dx * Matrix[0,1] + Dy * Matrix[1,1];
  end;
end;

procedure TCFDGRenderer.SetRenderer(const Value: TCustomVectorGraphics);
begin
  if FRenderer <> Value then
  begin
    FRenderer := Value;
    Changed;
  end;
end;

procedure TCFDGRenderer.AddColor(const Color: THSBAQuad);
begin
  with FEntry.Color do
  begin
    H := H + Color.H;
    S := Constrain(S + Color.S, 0, 1);
    B := Constrain(B + Color.B, 0, 1);
    A := Constrain(A + Color.A, 0, 1);
    Renderer.SetFillColor(HSBtoRGB(H, S, B, 1));
    Renderer.SetFillOpacity(A);
  end;
end;

procedure TCFDGRenderer.DrawSquare;
var
  X, Y: TFloat;
begin
  Renderer.BeginPath;
  Transform(-0.5, -0.5, X, Y);
  Renderer.MoveTo(X, Y);
  Transform(0.5, -0.5, X, Y);
  Renderer.LineTo(X, Y);
  Transform(0.5, 0.5, X, Y);
  Renderer.LineTo(X, Y);
  Transform(-0.5, 0.5, X, Y);
  Renderer.LineTo(X, Y);
  Renderer.ClosePath;
  Renderer.EndPath;
end;

procedure TCFDGRenderer.DrawTriangle;
const
  V1: TFloatPoint = (X:    0; Y:  0.58253);
  V2: TFloatPoint = (X: -0.5; Y: -0.28349);
  V3: TFloatPoint = (X:  0.5; Y: -0.28349);
var
  X, Y: TFloat;
begin
  Renderer.BeginPath;
  Transform(V1.X, V1.Y, X, Y);
  Renderer.MoveTo(X, Y);
  Transform(V2.X, V2.Y, X, Y);
  Renderer.LineTo(X, Y);
  Transform(V3.X, V3.Y, X, Y);
  Renderer.LineTo(X, Y);
  Renderer.ClosePath;
  Renderer.EndPath;
end;

procedure TCFDGRenderer.Update;
begin
  with FEntry.Color do
  begin
    Renderer.SetFillColor(HSBtoRGB(H, S, B, 1));
    Renderer.SetFillOpacity(A);
  end;
end;

{ TCFDGBoundsRenderer }

procedure TCFDGBoundsRenderer.AddColor(const Color: THSBAQuad);
begin

end;

procedure TCFDGBoundsRenderer.AddPoint(const X, Y: TFloat);
begin
  if FBounds.Left > X then FBounds.Left := X;
  if FBounds.Right < X then FBounds.Right := X;
  if FBounds.Top > Y then FBounds.Top := Y;
  if FBounds.Bottom < Y then FBounds.Bottom := Y;
end;

constructor TCFDGBoundsRenderer.Create;
begin
  inherited;
  FBounds.Left := INF;
  FBounds.Top := INF;
  FBounds.Right := -INF;
  FBounds.Bottom := -INF;
end;

procedure TCFDGBoundsRenderer.DrawCircle;
var
  Vx, Vy: TFloat;
begin
  with FEntry do
  begin
    Transform(-0.5, 0, Vx, Vy);
    AddPoint(Vx, Vy);
    Transform(0.5, 0, Vx, Vy);
    AddPoint(Vx, Vy);
    Transform(0, -0.5, Vx, Vy);
    AddPoint(Vx, Vy);
    Transform(0, 0.5, Vx, Vy);
    AddPoint(Vx, Vy);
  end;
end;

procedure TCFDGBoundsRenderer.DrawSquare;
var
  X, Y: TFloat;
begin
  Transform(-0.5, -0.5, X, Y);
  AddPoint(X, Y);
  Transform(0.5, -0.5, X, Y);
  AddPoint(X, Y);
  Transform(0.5, 0.5, X, Y);
  AddPoint(X, Y);
  Transform(-0.5, 0.5, X, Y);
  AddPoint(X, Y);
end;

procedure TCFDGBoundsRenderer.DrawTriangle;
const
  V1: TFloatPoint = (X:    0; Y:  0.58253);
  V2: TFloatPoint = (X: -0.5; Y: -0.28349);
  V3: TFloatPoint = (X:  0.5; Y: -0.28349);
var
  X, Y: TFloat;
begin
  Transform(V1.X, V1.Y, X, Y);
  AddPoint(X, Y);
  Transform(V2.X, V2.Y, X, Y);
  AddPoint(X, Y);
  Transform(V3.X, V3.Y, X, Y);
  AddPoint(X, Y);
end;

function TCFDGBoundsRenderer.Push: Boolean;
var
  W, H: TFloat;
begin
  W := Max(FBounds.Right - FBounds.Left, 0.01);
  H := Max(FBounds.Bottom - FBounds.Top, 0.01);
  with FEntry do
    //Result := sqr((Matrix[0][0] + Matrix[0][1]) / W) + sqr((Matrix[1][0] + Matrix[1][1]) / H) > 0.000001;
    Result := Abs(FPixelCount * (Matrix[0,0] * Matrix[1,1] - Matrix[1,0] * Matrix[0,1]) / (W * H)) > 0.3;

  Result := Result and (FStackIndex >= 0);
  if Result then
  begin
    FStack[FStackIndex] := FEntry;
    Dec(FStackIndex);
    Result := True;
  end;
end;

procedure TCFDGBoundsRenderer.SetPixelCount(const Value: Integer);
begin
  FPixelCount := Value;
end;

{ TCustomCFDGRenderer }

procedure TCustomCFDGRenderer.AddAlpha(A: TFloat);
begin

end;

procedure TCustomCFDGRenderer.AddBrightness(B: TFloat);
begin

end;

procedure TCustomCFDGRenderer.AddColor(const Color: THSBAQuad);
begin

end;

procedure TCustomCFDGRenderer.AddHue(H: TFloat);
begin

end;

procedure TCustomCFDGRenderer.AddSat(S: TFloat);
begin

end;

procedure TCustomCFDGRenderer.DrawCircle;
begin

end;

procedure TCustomCFDGRenderer.DrawSquare;
begin

end;

procedure TCustomCFDGRenderer.DrawTriangle;
begin

end;

procedure TCustomCFDGRenderer.Flip(const Theta: TFloat);
begin

end;

procedure TCustomCFDGRenderer.Rotate(const Theta: TFloat);
begin

end;

procedure TCustomCFDGRenderer.Scale(const Sx, Sy: TFloat);
begin

end;

procedure TCustomCFDGRenderer.Scale(const S: TFloat);
begin
  Scale(S, S);
end;

procedure TCustomCFDGRenderer.Skew(const Fx, Fy: TFloat);
begin

end;

end.
