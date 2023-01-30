unit ScreenshotToolFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Jin_Colors, JDUIUtils, JDUIControl, JDUIBaseControl, jinUtils, pngimage2, gr32;

type
  TToolSize = (tsSmall = 0, tsMiddle = 1, tsBig = 2);
  TActionType = (atNone = -1, atArrow = 0, atRect = 1, atCircle = 2, atPen = 3, atText = 4, actUndo = 5, actSave = 6, actQuit = 7, actOK = 8);
  TScreenshotToolActionEvent = procedure(Sender: TObject; ActionType: TActionType) of object;
  TScreenshotToolForm = class(TJDUIForm)
    btArrow: TJDUIButton;
    btRect: TJDUIButton;
    btCircle: TJDUIButton;
    btPen: TJDUIButton;
    jduImage1: TJDUIImage;
    btSave: TJDUIButton;
    btUndo: TJDUIButton;
    btOK: TJDUIButton;
    btCancel: TJDUIButton;
    jduImage2: TJDUIImage;
    btColor0: TJDUIButton;
    btColor1: TJDUIButton;
    btColor2: TJDUIButton;
    btColor3: TJDUIButton;
    btColor4: TJDUIButton;
    btColor5: TJDUIButton;
    btColor6: TJDUIButton;
    btColor7: TJDUIButton;
    btColor8: TJDUIButton;
    btColor9: TJDUIButton;
    btColor10: TJDUIButton;
    btColor11: TJDUIButton;
    btColor12: TJDUIButton;
    btColor13: TJDUIButton;
    btColor14: TJDUIButton;
    btColor15: TJDUIButton;
    btColor16: TJDUIButton;
    btColor17: TJDUIButton;
    btColorActive: TJDUIButton;
    btSmall: TJDUIButton;
    btMiddle: TJDUIButton;
    btBig: TJDUIButton;
    JduFormRes: TJDUIFormRes;
    JduFormBackRes: TJDUIFormBackRes;
    jdu9GSpeedBtn: TJDUINineGridsRes;
    jdu9GppmGray: TJDUINineGridsRes;
    procedure FormCreate(Sender: TObject);
    procedure btArrowMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure btColor1Click(Sender: TObject);
    procedure btBigClick(Sender: TObject);
  private
    FOnScreenshotToolAction: TScreenshotToolActionEvent;
    FOnActionColorChanged: TNotifyEvent;
    FOnToolSizeChanged: TNotifyEvent;
    FAction: TActionType;
    FActiveColor: TColor;
    FToolSize: TToolSize;
    procedure InitColors;
    procedure SetColor(AColor: TColor);
    procedure SetToolSize(AToolSize: TToolSize);
    procedure OpenToolSet;
    procedure CloseToolSet;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoAction(ActionType: TActionType);
    procedure DoActionColorChanged;
    procedure DoToolSizeChanged;
  public
    procedure ResetAction;
    procedure SetAction(ActionType: TActionType);
    property OnScreenshotToolAction: TScreenshotToolActionEvent read FOnScreenshotToolAction write FOnScreenshotToolAction;
    property OnActionColorChanged: TNotifyEvent read FOnActionColorChanged write FOnActionColorChanged;
    property OnToolSizeChanged: TNotifyEvent read FOnToolSizeChanged write FOnToolSizeChanged;
    property ActiveColor: TColor read FActiveColor;
    property ToolSize: TToolSize read FToolSize;
  end;

var
  ScreenshotToolForm: TScreenshotToolForm;

implementation

const StandardColors: Array[0..17] of TColor = (clBlack,
  clMaroon,
  clGreen,
  clOlive,
  clNavy,
  clPurple,
  clTeal,
  clGray,
  clSilver,
  clRed,
  clLime,
  $004080FF{clYellow},
  clBlue,
  clFuchsia,
  clAqua,
  clLtGray,
  clDkGray,
  clWhite);

{$R *.dfm}

procedure ClearColor(ABitmap: TBitmap32; AColor: TColor);
begin
  ABitmap.Clear(Color32(AColor) or $FF000000);
  ABitmap.FrameRectS(0, 0, ABitmap.Width, ABitmap.Height, $FF808080);
  ABitmap.FrameRectS(1, 1, ABitmap.Width - 1, ABitmap.Height - 1, $EFEFEFEF);
end;

procedure TScreenshotToolForm.ResetAction;
begin
  Self.LockRepaint;
  try
    btArrow.ShowNineGridsType := ngtHover;
    btRect.ShowNineGridsType := ngtHover;
    btCircle.ShowNineGridsType := ngtHover;
    btPen.ShowNineGridsType := ngtHover;
  finally
    Self.UnLockRepaint;
  end;
end;

procedure TScreenshotToolForm.SetAction(ActionType: TActionType);
begin
  ResetAction;
  if ActionType = atArrow then btArrow.ShowNineGridsType := ngtAlways;
  if ActionType = atRect then btRect.ShowNineGridsType := ngtAlways;
  if ActionType = atCircle then btCircle.ShowNineGridsType := ngtAlways;
  if ActionType = atPen then btPen.ShowNineGridsType := ngtAlways;

  DoAction(ActionType);
end;

procedure TScreenshotToolForm.btArrowMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ABtn: TJDUIButton;
begin
  ABtn := Sender as TJDUIButton;
  if ABtn.Tag <= 4 then
  begin
    ResetAction;
    ABtn.ShowNineGridsType := ngtAlways;
  end;
  DoAction(TActionType(ABtn.Tag));
end;

procedure TScreenshotToolForm.btBigClick(Sender: TObject);
begin
  SetToolSize(TToolSize((Sender as TJDUIButton).Tag));
end;

procedure TScreenshotToolForm.btColor1Click(Sender: TObject);
begin
  SetColor(StandardColors[(Sender as TJDUIButton).Tag]);
end;

procedure TScreenshotToolForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    WndParent := (Owner as TForm).Handle;
  end;
end;

procedure TScreenshotToolForm.FormCreate(Sender: TObject);
begin
  if GetTickCount mod 2 = 0 then
    ShowStyle := fssSliderLeft
  else
    ShowStyle := fssZoom;
  ShowTime := 0.3;
  HideStyle := fssSliderRight;
  HideTime := 0.3;
  SliderValue := 100;

  AllowResize := False;
  ShowIcon := False;
  ShowMaxOrRestoreButton := False;
  ShowSkinButton := False;
  ShowMinButton := False;
  ShowCloseButton := False;
  ShowCaption := False;

  InitColors;
  SetToolSize(tsMiddle);

  DWMEnabled := False;
  //WorkAreaAlpha := 230;
  Color := $FFFFFFFF;
  JduFormBackRes.FromColor(Color);
  FormBackRes := JduFormBackRes;
  FormRes := jduFormRes;

  ClientHeight := GetDPISize(27) + GetDPISize(2);

  CoverTop := 0;
  CoverAlpha := 198;
  Cover := True;
end;

procedure TScreenshotToolForm.OpenToolSet;
begin
  //ClientHeight := GetDPISize(27 + 40) + GetDPISize(2) + GetDPISize(10);
  AnimateInteger('ClientHeight', GetDPISize(27 + 40) + GetDPISize(2) + GetDPISize(10), 0.15, 0.0, jduAnimationOut, jduInterpolationSinusoidal, False, False);
end;

procedure TScreenshotToolForm.CloseToolSet;
begin
  //ClientHeight := GetDPISize(27) + GetDPISize(2);
  AnimateInteger('ClientHeight', GetDPISize(27) + GetDPISize(2), 0.15, 0.0, jduAnimationOut, jduInterpolationSinusoidal, False, False);
end;

procedure TScreenshotToolForm.SetToolSize(AToolSize: TToolSize);
begin
  FToolSize := AToolSize;
  Self.LockRepaint;
  try
    btSmall.ShowNineGridsType := ngtHover;
    btMiddle.ShowNineGridsType := ngtHover;
    btBig.ShowNineGridsType := ngtHover;
    if FToolSize = tsSmall then btSmall.ShowNineGridsType := ngtAlways;
    if FToolSize = tsMiddle then btMiddle.ShowNineGridsType := ngtAlways;
    if FToolSize = tsBig then btBig.ShowNineGridsType := ngtAlways;
  finally
    Self.UnLockRepaint;
  end;
  Self.DoToolSizeChanged;
end;

procedure TScreenshotToolForm.SetColor(AColor: TColor);
var
  ABitmap: TBitmap32;
  APngImage: TPngImage;
begin
  FActiveColor := AColor;
  ABitmap := TBitmap32.Create;
  LockRepaint;
  try
    ABitmap.SetSize(btColorActive.PicureWidth, btColorActive.PicureHeight);
    ClearColor(ABitmap, FActiveColor);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColorActive.Picture := APngImage;
    btColorActive.ForceRePaint;
    APngImage.Free;

    //AColor := clGray;
    jin_Colors.ConvertPngToColor2(btSmall.Picture, AColor);
    jin_Colors.ConvertPngToColor2(btMiddle.Picture, AColor);
    jin_Colors.ConvertPngToColor2(btBig.Picture, AColor);

    btSmall.Reset;
    btMiddle.Reset;
    btBig.Reset;
  finally
    Self.UnLockRepaint;
    ABitmap.Free;
  end;
  DoActionColorChanged;
end;

procedure TScreenshotToolForm.InitColors;
var
  ABitmap: TBitmap32;
  APngImage: TPngImage;
begin
  ABitmap := TBitmap32.Create;
  try
    ABitmap.SetSize(GetDPISize(16), GetDPISize(16));

    ClearColor(ABitmap, StandardColors[0]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor0.Picture := APngImage;
    btColor0.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[1]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor1.Picture := APngImage;
    btColor1.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[2]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor2.Picture := APngImage;
    btColor2.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[3]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor3.Picture := APngImage;
    btColor3.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[4]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor4.Picture := APngImage;
    btColor4.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[5]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor5.Picture := APngImage;
    btColor5.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[6]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor6.Picture := APngImage;
    btColor6.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[7]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor7.Picture := APngImage;
    btColor7.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[8]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor8.Picture := APngImage;
    btColor8.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[9]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor9.Picture := APngImage;
    btColor9.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[10]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor10.Picture := APngImage;
    btColor10.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[11]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor11.Picture := APngImage;
    btColor11.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[12]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor12.Picture := APngImage;
    btColor12.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[13]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor13.Picture := APngImage;
    btColor13.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[14]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor14.Picture := APngImage;
    btColor14.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[15]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor15.Picture := APngImage;
    btColor15.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[16]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor16.Picture := APngImage;
    btColor16.UserPicureDPISize := False;
    APngImage.Free;

    ClearColor(ABitmap, StandardColors[17]);
    APngImage := GetPngFromBitmap32(ABitmap);
    btColor17.Picture := APngImage;
    btColor17.UserPicureDPISize := False;
    APngImage.Free;
  finally
    ABitmap.Free;
  end;

  SetColor(clRed);
end;

procedure TScreenshotToolForm.DoActionColorChanged;
begin
  if Assigned(FOnActionColorChanged) then FOnActionColorChanged(Self);
end;

procedure TScreenshotToolForm.DoToolSizeChanged;
begin
  if Assigned(FOnToolSizeChanged) then FOnToolSizeChanged(Self);
end;

procedure TScreenshotToolForm.DoAction(ActionType: TActionType);
begin
  FAction := ActionType;
  if (FAction = atArrow) or
     (FAction = atRect) or
     (FAction = atCircle) or
     (FAction = atPen) or
     (FAction = atText) then
  begin
    OpenToolSet;
  end
  else if FAction = atNone then       
  begin
    CloseToolSet;
  end;
  
  if ActionType = atNone then Exit;

  if Assigned(FOnScreenshotToolAction) then FOnScreenshotToolAction(Self, ActionType);
end;

end.
