unit jduMessageBoxFrm;

interface

uses
  JDUIUtils,
  JDUIBaseControl, JDUIControl, PngImage2, System.Generics.Collections,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList;

type
  TJDUIMessageBoxForm = class(TJDUIForm)
    jduContainer: TJDUIContainer;
    btOK: TJDUIButton;
    btCancel: TJDUIButton;
    btYes: TJDUIButton;
    btNO: TJDUIButton;
    btAbort: TJDUIButton;
    btRetry: TJDUIButton;
    btIgnore: TJDUIButton;
    lbText: TJDUIEditOSR;
    jdu9GButtonLigntHover: TJDUINineGridsRes;
    jdu9GButtonLigntNormal: TJDUINineGridsRes;
    jdu9GButtonLigntDown: TJDUINineGridsRes;
    jdu9GLightGrayHover: TJDUINineGridsRes;
    jdu9GLightGrayNormal: TJDUINineGridsRes;
    jdu9GLightGrayDown: TJDUINineGridsRes;
    pnlTitleBackground: TJDUIPanel;
    jduButtonTitle: TJDUIButton;
    jdu9GCloseFormButton: TJDUINineGridsRes;
    jdu9GCloseDownFormButton: TJDUINineGridsRes;
    jdu9GOtherFormButton: TJDUINineGridsRes;
    jdu9GOtherDownFormButton: TJDUINineGridsRes;
    JduFormBackRes: TJDUIFormBackRes;
    JduFormRes: TJDUIFormRes;
    jduBorderMask: TJDUIBorderMask;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    FText, FCaption: String;
    FType: UINT;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  function jduMessageBox(AWnd: HWND; AText, ACaption: String; AType: UINT;
                         AShowStyle: TJDUIFormShowStyle = fssSliderBottom;
                         AShowTime: Single = 0.25;
                         AHidetyle: TJDUIFormShowStyle = fssSliderRight;
                         AHideTime: Single = 0.25): Integer;

const
  MB_DONTALERT = $F0000000;

implementation

var
  ParentWnd: HWND;

{$R *.dfm}

function jduMessageBox(AWnd: HWND; AText, ACaption: String; AType: UINT;
                       AShowStyle: TJDUIFormShowStyle;
                       AShowTime: Single;
                       AHidetyle: TJDUIFormShowStyle;
                       AHideTime: Single): Integer;
var
  AForm: TJDUIMessageBoxForm;
begin
  ParentWnd := AWnd;
  AForm := TJDUIMessageBoxForm.Create(nil);
  try
    AForm.ShowStyle := AShowStyle;
    AForm.ShowTime := AShowTime;
    AForm.HideStyle := AHidetyle;
    AForm.HideTime := AHideTime;
    AForm.SliderValue := GetDPISize(80);

    AForm.FText := AText;
    AForm.FCaption := ACaption;
    AForm.FType := AType;

    Result := AForm.ShowModal;
  finally
    FreeAndNil(AForm);
    ParentWnd := 0;
  end;
end;

constructor TJDUIMessageBoxForm.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TJDUIMessageBoxForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    WndParent := ParentWnd;
  end;
end;

procedure TJDUIMessageBoxForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  SliderValue := GetDPISize(120);
end;

procedure TJDUIMessageBoxForm.FormCreate(Sender: TObject);
begin
  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);

  BlendBorder := True;
  AllowResize := False;
  ShowIcon := False;
  ShowCaption := False;
  ShowSkinButton := False;
  ShowMaxOrRestoreButton := False;
  ShowMinButton := False;
  EnabledGlass := False;
  DWMEnabled := False;

  BorderMask := jduBorderMask;
  Color := $FFFFFFFF;

  WorkAreaAlpha := 255;
  JduFormBackRes.FromColor(Color);
  FormBackRes := JduFormBackRes;
  FormRes := JduFormRes;

  jdu9GLightGrayNormal.ChangeToColor($9D9D9D, True);
  jdu9GLightGrayHover.ChangeToColor($8D8D8D, True);
  jdu9GLightGrayDown.ChangeToColor($7D7D7D, True);
end;

procedure TJDUIMessageBoxForm.FormMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) then
  begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, $F012, 0);
  end;
end;

procedure TJDUIMessageBoxForm.FormShow(Sender: TObject);
var
  AFormWidth,
  AFormHeight,
  ATextWidth,
  ATextHeight: Integer;
  AButtons: TList<TJDUIButton>;
  ARect: TRect;
  iLoop, iLeft: Integer;
begin
  AButtons := TList<TJDUIButton>.Create;
  Self.LockRepaint;
  try
    Gradient := True;
    Cover := True;

    Caption := FCaption;
    lbText.Text := FText;

    FType := FType and (not MB_ICONINFORMATION)
                   and (not MB_ICONWARNING)
                   and (not MB_ICONQUESTION)
                   and (not MB_ICONERROR);

    if MB_OKCANCEL = FType then
    begin
      AButtons.Add(btOK);
      AButtons.Add(btCancel);
    end
    else if MB_ABORTRETRYIGNORE = FType then
    begin
      AButtons.Add(btAbort);
      AButtons.Add(btRetry);
      AButtons.Add(btIgnore);
    end
    else if MB_YESNOCANCEL = FType then
    begin
      AButtons.Add(btYes);
      AButtons.Add(btNo);
      AButtons.Add(btCancel);
    end
    else if MB_YESNO = FType then
    begin
      AButtons.Add(btYes);
      AButtons.Add(btNo);
    end
    else if MB_RETRYCANCEL = FType then
    begin
      AButtons.Add(btRetry);
      AButtons.Add(btCancel);
    end
    else
    begin
      AButtons.Add(btOK);
    end;

    AFormWidth := GetDPISize(388);
    if AButtons.Count >= 3 then AFormWidth := GetDPISize(448);

    ATextWidth := lbText.ContentWidth;
    ATextHeight := lbText.ContentHeight;
    AFormHeight := ATextHeight + GetDPISize(197);

    AFormWidth := AFormWidth + GetDPISize(FormRes.BorderMarginRight);
    AFormHeight := AFormHeight + GetDPISize(FormRes.BorderMarginBottom);
    SetBounds(Left - (AFormWidth - Width) div 2, Top, AFormWidth, AFormHeight);


    if not GetWindowRect(ParentWnd, ARect) then  ARect := Screen.DesktopRect;
    Left := ARect.Left + ((ARect.Right - ARect.Left) - Width) div 2;
    Top := ARect.Top + ((ARect.Bottom - ARect.Top) - Height) div 2;

    if Left < 0 then Left := 0;
    if Left + Width > Screen.DesktopRect.Right then Left := Screen.DesktopRect.Right - Width;
    if Top < 0 then Top := 0;
    if Top + Height > Screen.DesktopRect.Bottom then Top := Screen.DesktopRect.Bottom - Height;

    lbText.Width := ATextWidth + GetDPISize(10);
    lbText.Height := ATextHeight + GetDPISize(1);

    lbText.Left := (AFormWidth - ATextWidth) div 2;// - GetDPISize(FormRes.BorderMarginLeft);

    lbText.Top := lbText.Top + GetDPISize(20);
    lbText.AnimateInteger('Top', lbText.Top - GetDPISize(20), 0.35, 0.0, jduAnimationInOut, jduInterpolationQuintic, False, False);
    lbText.Alpha := 0;
    lbText.AnimateInteger('Alpha', 255, 0.35, 0.1, jduAnimationInOut, jduInterpolationSinusoidal, False, False);

    iLeft :=  (AFormWidth - AButtons.Count * (btOk.Width + GetDPISize(10))) div 2 - GetDPISize(FormRes.BorderMarginLeft);
    for iLoop := 0 to AButtons.Count - 1 do
    begin
      AButtons[iLoop].Visible := True;
      AButtons[iLoop].Left := iLeft + GetDPISize(5);
      iLeft  := iLeft + btOk.Width + GetDPISize(10);
    end;

    SetForegroundWindow(Handle);
  finally
    Self.UnLockRepaint;
    AButtons.Free;
  end;
end;

end.
