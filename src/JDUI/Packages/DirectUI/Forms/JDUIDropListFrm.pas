unit JDUIDropListFrm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, JDUIPopupFrm, JDUIBaseControl, Vcl.AppEvnts, JDUIControl;

type
  TJDUIDropListForm = class(TJDUIPopupForm)
    jduListViewRes: TJDUIListViewRes;
    lvItems: TJDUIListView;
    jdu9GTreeSel: TJDUINineGridsRes;
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    procedure CMDialogKey(var Message: TCMDialogKey); message CM_DIALOGKEY;
  public
    { Public declarations }
  end;

var
  jduDropListForm: TJDUIDropListForm;

implementation

{$R *.dfm}

procedure TJDUIDropListForm.FormCreate(Sender: TObject);
begin
  inherited;
  ShowStyle := fssBlendScroll;
  ShowTime := 0.07;
  BlendBorder := False;
  BorderMask := nil;
  Self.FormRes := Self.JduFormRes;
  if Owner is TJDUIForm then
  begin
    lvItems.Font.Size := (Owner as TJDUIForm).Font.Size;
  end;
end;

procedure TJDUIDropListForm.CMDialogKey(var Message: TCMDialogKey);
begin
  Inherited;
  with Message do
  begin
    if (CharCode = VK_DOWN) then
    begin
      lvItems.SelectNext(True);//.MouseEnter;
    end;

    if (CharCode = VK_UP) then
    begin
      lvItems.SelectPrev(True);//.MouseEnter;
    end;

    if (CharCode = VK_RETURN) then
    begin
      if lvItems.Selected <> nil then lvItems.OnItemClick(lvItems, lvItems.Selected);
    end;
  end;
end;

end.
