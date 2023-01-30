unit JDUITooltipFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.StdCtrls, Vcl.Forms, Vcl.Dialogs, GR32, GR32_IMAGE, JDUIControl, JDUIBaseControl, JDUIUtils, Vcl.ExtCtrls,
  Vcl.AppEvnts;

type
  TTooltopDirection = (ttdTop, ttdBottom, ttdNone);
  TTooltopArrowPosition = (tapLeft, tapMiddle, tapRight);
  TJDUITooltipForm = class(TJDUIForm)
    JduFormRes: TJDUIFormRes;
    JduFormBackRes: TJDUIFormBackRes;
    jduNineGridsRes: TJDUINineGridsRes;
    TimerForClose: TTimer;
    imgArrowUp: TJDUIImage;
    imgArrowDown: TJDUIImage;
    ApplicationEvents: TApplicationEvents;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDeactivate(Sender: TObject);
    procedure TimerForCloseTimer(Sender: TObject);
    procedure ApplicationEventsMessage(var Msg: tagMSG; var Handled: Boolean);
  private
    FCloseing: Boolean;
    FDuration: Single;
    FText: String;
    FDirection: TTooltopDirection;
    FArrowPosition: TTooltopArrowPosition;
    FArrowMargin: Integer;
  protected
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMMOUSEACTIVATE(var Msg: TWMMOUSEACTIVATE);
      message WM_MOUSEACTIVATE;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
  public
    procedure GetSize(AText: String; var AWidth, AHeight: Integer);
  end;


  function ActiveTooltop(AForm: TForm;
                         AText: String;
                         X, Y: Integer;
                         ADuration: Single;
                         ADirection: TTooltopDirection;
                         AArrowPosition: TTooltopArrowPosition;
                         AArrowMargin: Integer = 25): TJDUITooltipForm;

implementation

const TextColor = $FF875f0e;

{$R *.dfm}

function ActiveTooltop(AForm: TForm;
                       AText: String;
                       X, Y: Integer;
                       ADuration: Single;
                       ADirection: TTooltopDirection;
                       AArrowPosition: TTooltopArrowPosition;
                       AArrowMargin: Integer = 25): TJDUITooltipForm;
var
  AWidth, AHeight: Integer;
begin
  Result := TJDUITooltipForm.Create(AForm);
  with Result do
  begin
    Font.Assign(AForm.Font);
    if AForm is TJDUIForm then
      Font.Name := (AForm as TJDUIForm).FormRes.TitleFont.Name;
    FText := AText;
    FDuration := ADuration;
    FDirection := ADirection;
    FArrowPosition := AArrowPosition;
    FArrowMargin := AArrowMargin;
    GetSize(FText, AWidth, AHeight);
    Left := X;

    if AArrowPosition = tapMiddle then
    begin
      Left := X - AWidth div 2;
    end;

    Width := AWidth;
    Height := AHeight;
    if FDirection = ttdNone then
    begin
      SliderValue := 30;
      ShowTime := 1.0;
      HideTime := 0.5;
      ShowStyle := fssBlend;
      HideStyle := fssBlend;
      Top := Y - 9;
    end
    else if FDirection = ttdTop then
    begin
      SliderValue := 30;
      ShowStyle := fssSliderTop;
      //HideStyle := fssSliderTop;
      Top := Y - Height;
    end
    else
    begin
      SliderValue := 30;
      ShowStyle := fssSliderBottom;
      //HideStyle := fssSliderBottom;
      Top := Y;
    end;
    //SetWindowPos(Handle, HWND_TOPMOST,0,0,0,0,SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
    ShowWindow(Handle, SW_SHOWNOACTIVATE);
    Visible := True;
  end;
end;

procedure TJDUITooltipForm.GetSize(AText: String; var AWidth, AHeight: Integer);
begin
  //Canvas.Font.Assign(Self.Font);
  AWidth := GetFontBitmap(Font).TextWidth(AText) + 12 * 2;
  AHeight := GetFontBitmap(Font).TextHeight(AText) + 19 * 2;
end;

procedure TJDUITooltipForm.TimerForCloseTimer(Sender: TObject);
begin
  TimerForClose.Enabled := False;
  if not FCloseing then Close;
end;

procedure TJDUITooltipForm.FormShow(Sender: TObject);
var
  AArrowBMP: TBitmap32;
  AX, AY: Integer;
begin
  TimerForClose.Enabled := FDuration > 0;
  TimerForClose.Interval := Round(FDuration * 1000);

  jduFormBackRes.Bitmap.SetSize(Width, Height);
  jduFormBackRes.Bitmap.Clear($00000000);
  jduNineGridsRes.Draw(jduFormBackRes.Bitmap, Rect(0, 0, Width, Height), True, 255);

  if FDirection <> ttdNone then
  begin
    if FDirection = ttdTop then
      AArrowBMP := GetBitmap32ByPngImage(imgArrowDown.Picture)
    else
      AArrowBMP := GetBitmap32ByPngImage(imgArrowUp.Picture);

    try
      if FDirection = ttdBottom then
        AY := 0
      else
        Ay := Height - AArrowBMP.Height;

      if FArrowPosition = tapLeft then
        AX := GetDPISize(FArrowMargin)
      else if FArrowPosition = tapRight then
        AX := Width - GetDPISize(FArrowMargin) - AArrowBMP.Width
      else
        AX := (Width - AArrowBMP.Width) div 2;

      AArrowBMP.DrawTo(jduFormBackRes.Bitmap, AX, AY);
    finally
      FreeAndNil(AArrowBMP);
    end;
  end;

  Font.Color := clWhite;
  DrawText(jduFormBackRes.Bitmap, FText, Font, False, 0, Rect(10, 10 + 1, Width - 10, Height - 13 + 1), TAlignment.taLeftJustify, tlCenter, epNone);
  Font.Color := TextColor;
  DrawText(jduFormBackRes.Bitmap, FText, Font, False, 0, Rect(10, 10, Width - 10, Height - 13), TAlignment.taLeftJustify, tlCenter, epNone);

  LayeredWindow := True;
  ARGBMode := True;
  FormBackRes := jduFormBackRes;
  FormRes := jduFormRes;
end;

procedure TJDUITooltipForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FCloseing := True;
  Action := caFree;
end;

procedure TJDUITooltipForm.ApplicationEventsMessage(var Msg: tagMSG;
  var Handled: Boolean);
begin
  //if IsChild((Owner as TForm).Handle,  Msg.hwnd) or ((Owner as TForm).Handle = Msg.hwnd) then
  if Self.FDuration > 0 then
  begin
    if (Msg.message = CM_DIALOGKEY) or
       (Msg.message = CM_ACTIVATE) or
       (Msg.message = CM_DEACTIVATE) or
       (Msg.message = WM_MOUSEACTIVATE) or
       (Msg.message = WM_KEYDOWN) or
       (Msg.message = WM_SYSKEYDOWN) or
       (Msg.message = WM_SHOWWINDOW) or
       (Msg.message = WM_LBUTTONDOWN) or
       (Msg.message = WM_MBUTTONDOWN) or
       (Msg.message = WM_RBUTTONDOWN) then
    begin
      if not FCloseing then Close;
    end;
  end;
end;

procedure TJDUITooltipForm.CMDialogKey(var Message: TCMDialogKey);
begin
  //inherited;
  if (Owner is TForm) then
  begin
    PostMessage((Owner as TForm).Handle, CM_DIALOGKEY, TMessage(Message).WParam, TMessage(Message).LParam);
    //(Owner as TForm).Perform(CM_DIALOGKEY, TMessage(Message).WParam, TMessage(Message).LParam);
  end;
end;

procedure TJDUITooltipForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    ExStyle := ExStyle or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE;

    if Owner <> nil then
      if Owner is TForm then
        WndParent := (Owner as TForm).Handle;
  end;
end;

procedure TJDUITooltipForm.WMNCHitTest(var Message: TWMNCHitTest);
begin
  Message.Result := HTTRANSPARENT;
end;

procedure TJDUITooltipForm.WMMOUSEACTIVATE(var Msg: TWMMOUSEACTIVATE);
begin
  Msg.Result := MA_NOACTIVATE;
end;

procedure TJDUITooltipForm.FormCreate(Sender: TObject);
begin
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_NOACTIVATE);

  ShowStyle := fssZoom;
  ShowTime := 0.25;
  //HideStyle := fssZoom;
  //HideTime := 0.20;

  AllowResize := False;

  ShowMenuButton := False;
  ShowCloseButton := False;
  ShowMinButton := False;
  ShowMaxOrRestoreButton := False;
  ShowSkinButton := False;
  ShowIcon := False;
  ShowCaption := False;
  SingleBackImageMode := True;
end;

procedure TJDUITooltipForm.FormDeactivate(Sender: TObject);
begin
  if not FCloseing then Close;
end;

end.
