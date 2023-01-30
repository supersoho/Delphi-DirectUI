unit AnimateFrm;

interface

uses
  gr32, jinUtils, JDUIUtils, JDUIControl, JDUIBaseControl, Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs;

type
  TAnimateForm = class(TJDUIForm)
    JduFormBackRes: TJDUIFormBackRes;
    jduImage1: TJDUIImage;
    btAnimateCloseWindow: TJDUIButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btAnimateCloseWindowClick(Sender: TObject);
  private
    procedure AnimatedShow(Sender: TObject);
  public
    { Public declarations }
  end;

implementation

uses DemoFrm;

{$R *.dfm}

procedure TAnimateForm.btAnimateCloseWindowClick(Sender: TObject);
begin
  CloseForm;
end;

procedure TAnimateForm.FormCreate(Sender: TObject);
begin
  TimeCriticalAnimate := True;
  OnAnimatedShow := AnimatedShow;

  AllowResize := False;
  ShowIcon := False;
  ShowCaption := False;
  ShowSkinButton := False;
  ShowMaxOrRestoreButton := False;
  Self.ShowCloseButton := False;
  ShowMinButton := False;
  EnabledGlass := True;
  DWMEnabled := True;

  BlendBorder := True;

  BorderMask := DemoForm.jduBorderMask;

  WorkAreaAlpha := 255;
  FormBackRes := jduFormBackRes;

  FormBackRes.FromColor($FFFAFAFA);
  FormRes := DemoForm.JduFormRes;

  Self.SliderValue := 200;
end;

procedure TAnimateForm.FormDestroy(Sender: TObject);
begin
  TimeCriticalAnimate := False;
end;

procedure TAnimateForm.AnimatedShow(Sender: TObject);
begin

end;

end.
