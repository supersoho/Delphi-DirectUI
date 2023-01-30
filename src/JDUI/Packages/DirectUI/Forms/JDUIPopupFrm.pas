unit JDUIPopupFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JDUIBaseControl, JDUIControl, JDUIUtils, Vcl.AppEvnts;

type
  TJDUIPopupForm = class(TJDUIForm)
    ApplicationEvents: TApplicationEvents;
    JduFormRes: TJDUIFormRes;
    procedure FormCreate(Sender: TObject);
    procedure ApplicationEventsDeactivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FAutoClose: Boolean;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
    procedure WMMOUSEACTIVATE(var Msg: TWMMOUSEACTIVATE); //message WM_MOUSEACTIVATE;
    procedure WMNCHitTest(var msg: TWMNCHITTEST); message WM_NCHITTEST;
  public
    property AutoClose: Boolean read FAutoClose write FAutoClose;
  end;

var
  jduPopupForm: TJDUIPopupForm;

implementation

{$R *.dfm}

procedure TJDUIPopupForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
  TimeCriticalAnimate := False;
end;

procedure TJDUIPopupForm.WMNCHitTest(var msg: TWMNCHITTEST);
var
  P: TPoint;
  ARect: TRect;
begin
  msg.Result := HTCLIENT;

  P.X := msg.XPos - Left;
  P.Y := msg.YPos - Top;
  ARect := Rect(FormRes.BorderMarginLeft, FormRes.BorderMarginTop, Width - FormRes.BorderMarginRight, Height - FormRes.BorderMarginBottom);
  if not PtInRect(ARect, P) then
  begin
    msg.Result := HTTRANSPARENT;
    Exit;
  end;

end;

procedure TJDUIPopupForm.FormCreate(Sender: TObject);
begin
  //SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_NOACTIVATE);

  //ShowStyle := fssBlendScroll;
  //ShowTime := 0.35;
  TimeCriticalAnimate := True;
  FAutoClose := True;
  AllowResize := False;

  ShowMenuButton := False;
  ShowCloseButton := False;
  ShowMinButton := False;
  ShowMaxOrRestoreButton := False;
  ShowSkinButton := False;
  ShowIcon := False;
  ShowCaption := False;

  Color := $FFFFFFFF;
  BlendBorder := False;
  BorderMask := nil;
  Self.FormRes := Self.JduFormRes;
  //BackRes.FromColor($FFFFFFFF);
  //FormBackRes := BackRes;
end;

procedure TJDUIPopupForm.FormDeactivate(Sender: TObject);
begin
  if not Self.Visible then Exit;
  
  if FAutoClose then Close;
end;

procedure TJDUIPopupForm.WMMOUSEACTIVATE(var Msg: TWMMOUSEACTIVATE);
begin
  Msg.Result := MA_NOACTIVATE;
end;

procedure TJDUIPopupForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    //ExStyle := ExStyle or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE;

    if Owner <> nil then
      if Owner is TForm then
        WndParent := (Owner as TForm).Handle
      else
        WndParent := GetDesktopWindow;
  end;
end;

procedure TJDUIPopupForm.ApplicationEventsDeactivate(Sender: TObject);
begin
  if FAutoClose then Close;
end;

procedure TJDUIPopupForm.CMDialogKey(var Message: TCMDialogKey);
begin
  if (Owner is TForm) then
  begin
    PostMessage((Owner as TForm).Handle, CM_DIALOGKEY, TMessage(Message).WParam, TMessage(Message).LParam);
  end;
end;

end.
