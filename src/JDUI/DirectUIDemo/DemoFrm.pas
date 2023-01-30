unit DemoFrm;

interface

uses
  ceflib, cefvcl, gr32, jinUtils, JDUIUtils, JDUIControl, JDUIBaseControl, WinApi.Windows, WinApi.Messages, SysUtils, Variants, Classes, Graphics, PngImage2, IOUtils,
  Controls, Forms, Dialogs, System.Generics.Collections, JDUITableView, Vcl.ExtCtrls, Math, Vcl.AppEvnts, Vcl.Menus, Vcl.ExtDlgs,
  ScreenshotFrm,
  AnimateFrm,
  jduMessageBoxFrm;

type
  TSkin = class
  private
    FSkinName: String;
    FSkinFile: String;
    FSkinColor: TColor32;
    FBackDrawType: TJDUIBackDrawType;
  end;

  TDemoForm = class(TJDUIForm)
    jdu9GCloseFormButton: TJDUINineGridsRes;
    jdu9GCloseDownFormButton: TJDUINineGridsRes;
    jdu9GOtherFormButton: TJDUINineGridsRes;
    jdu9GOtherDownFormButton: TJDUINineGridsRes;
    jduBorderMask: TJDUIBorderMask;
    JduFormRes: TJDUIFormRes;
    JduFormBackRes: TJDUIFormBackRes;
    IconCreaterCircle: TJDUIIconCreater;
    IconCreaterRoundBorder: TJDUIIconCreater;
    jduContainerClient: TJDUIContainer;
    jduContainerTop: TJDUIContainer;
    jduContainerPages: TJDUIContainer;
    jduPanelBackground: TJDUIPanel;
    jdu9GTabHover: TJDUINineGridsRes;
    jdu9GTabSelected: TJDUINineGridsRes;
    jduTab0: TJDUIButton;
    jdu9GTabNormal: TJDUINineGridsRes;
    jduTab5: TJDUIButton;
    jduTab6: TJDUIButton;
    jduTab1: TJDUIButton;
    jduTab2: TJDUIButton;
    jduTab3: TJDUIButton;
    jduTab4: TJDUIButton;
    jduPage0: TJDUIContainer;
    jduBottom: TJDUIContainer;
    jduPanel1: TJDUIPanel;
    tbSkinAlpha: TJDUITrackBar;
    jdu9GProgressBack: TJDUINineGridsRes;
    jdu9GProgressFore: TJDUINineGridsRes;
    jduButton1: TJDUIButton;
    jduPage1: TJDUIContainer;
    jduPage2: TJDUIContainer;
    jduPage3: TJDUIContainer;
    jduPage4: TJDUIContainer;
    jduPage5: TJDUIContainer;
    jduPage6: TJDUIContainer;
    jduListViewRes: TJDUIListViewRes;
    jduScrollBarRes: TJDUIScrollBarRes;
    jdu9GSpeedBtn: TJDUINineGridsRes;
    jdu9GEdit: TJDUINineGridsRes;
    jdu9GEditHover: TJDUINineGridsRes;
    jdu9GEditFocus: TJDUINineGridsRes;
    jdu9GppmGray: TJDUINineGridsRes;
    cbSkins: TJDUIComboBox;
    jduButton2: TJDUIButton;
    jduButton3: TJDUIButton;
    jduButton4: TJDUIButton;
    jduButton5: TJDUIButton;
    jduButton6: TJDUIButton;
    jduButton7: TJDUIButton;
    jduButton8: TJDUIButton;
    jdu9GButtonLigntHover: TJDUINineGridsRes;
    jdu9GButtonLigntNormal: TJDUINineGridsRes;
    jdu9GButtonLigntDown: TJDUINineGridsRes;
    jdu9GLightBlueHover: TJDUINineGridsRes;
    jdu9GLightBlueNormal: TJDUINineGridsRes;
    jdu9GLightBlueDown: TJDUINineGridsRes;
    jdu9GLightYellowHover: TJDUINineGridsRes;
    jdu9GLightYellowNormal: TJDUINineGridsRes;
    jdu9GLightYellowDown: TJDUINineGridsRes;
    jdu9GLightGrayHover: TJDUINineGridsRes;
    jdu9GLightGrayNormal: TJDUINineGridsRes;
    jdu9GLightGrayDown: TJDUINineGridsRes;
    jdu9GLightRedHover: TJDUINineGridsRes;
    jdu9GLightRedNormal: TJDUINineGridsRes;
    jdu9GLightRedDown: TJDUINineGridsRes;
    jduButton9: TJDUIButton;
    jduButton10: TJDUIButton;
    jduButton11: TJDUIButton;
    jduButton12: TJDUIButton;
    jduButton13: TJDUIButton;
    jduButton14: TJDUIButton;
    btArrow: TJDUIButton;
    btRect: TJDUIButton;
    btCircle: TJDUIButton;
    btPen: TJDUIButton;
    btUndo: TJDUIButton;
    btSave: TJDUIButton;
    btCancel: TJDUIButton;
    btOK: TJDUIButton;
    jduButton15: TJDUIButton;
    jduCheckBoxRes1: TJDUICheckBoxRes;
    jduCheckBoxRes2: TJDUICheckBoxRes;
    jduCheckBox0: TJDUICheckBox;
    jduCheckBox1: TJDUICheckBox;
    jduCheckBox2: TJDUICheckBox;
    jduCheckBox3: TJDUICheckBox;
    jduCheckBoxRes3: TJDUICheckBoxRes;
    jduRadioButton1: TJDUIRadioButton;
    jduRadioButton2: TJDUIRadioButton;
    jduButton16: TJDUIButton;
    jduProgressBar1: TJDUIProgressBar;
    jduTrackBar1: TJDUITrackBar;
    btStartProgress: TJDUIButton;
    TimerProgress: TTimer;
    jduButton17: TJDUIButton;
    btImage: TJDUIButton;
    jdu9GRoundBack: TJDUINineGridsRes;
    jdu9GRoundBackHover: TJDUINineGridsRes;
    jduButton18: TJDUIButton;
    jduContainer1: TJDUIContainer;
    jduPanel2: TJDUIPanel;
    jduListView: TJDUIListView;
    jdu9GTreeHover: TJDUINineGridsRes;
    jdu9GTreeSel: TJDUINineGridsRes;
    cbShowBigImage: TJDUICheckBox;
    cbShowCheckbox: TJDUICheckBox;
    jduButton19: TJDUIButton;
    jduButton20: TJDUIButton;
    btOpenAll: TJDUIButton;
    btCloseAll: TJDUIButton;
    btDeleteTreeNode: TJDUIButton;
    btAddTreeNodeBefore: TJDUIButton;
    btAddTreeNodeAfter: TJDUIButton;
    jdu9GCard: TJDUINineGridsRes;
    btListBackCard: TJDUIButton;
    jduContainer2: TJDUIContainer;
    jduContainer3: TJDUIContainer;
    jduPanel6: TJDUIPanel;
    btNO: TJDUIButton;
    btProduct: TJDUIButton;
    btTotal: TJDUIButton;
    btAvailability: TJDUIButton;
    jduTableView: TJDUITableView;
    jduContainer4: TJDUIContainer;
    ApplicationEvents: TApplicationEvents;
    jduGridView: TJDUIListView;
    jduContainerInput: TJDUIContainer;
    jduInputTop: TJDUIContainer;
    btAddImage: TJDUIButton;
    btCopyScreen: TJDUIButton;
    edFontSize: TJDUIComboBox;
    cbLineSpace: TJDUIComboBox;
    jduImage2: TJDUIImage;
    btBold: TJDUIButton;
    btUnderLine: TJDUIButton;
    btSUB: TJDUIButton;
    btSUP: TJDUIButton;
    btItalic: TJDUIButton;
    edMessageInput: TJDUIEditOSR;
    jduPanel3: TJDUIPanel;
    jdu9GppmSelected: TJDUINineGridsRes;
    pmInput: TPopupMenu;
    miCut: TMenuItem;
    miCopy: TMenuItem;
    miPast: TMenuItem;
    miSelAll: TMenuItem;
    jpmInput: TJDUIPopupMenu;
    ppmRes: TJDUIPopupMenuRes;
    OpenPictureDialog: TOpenPictureDialog;
    jduWebView: TJDUIWebView;
    jduImageLoading: TJDUIImageLoading;
    jduButton21: TJDUIButton;
    btAnimateLeft: TJDUIButton;
    jduPanelAnimateBox: TJDUIPanel;
    jduButton23: TJDUIButton;
    cbInterpolationType: TJDUIComboBox;
    jduButton24: TJDUIButton;
    tbAnimateTime: TJDUITrackBar;
    btAnimateTime: TJDUIButton;
    rbAnimationIn: TJDUIRadioButton;
    rbAnimationOut: TJDUIRadioButton;
    rbAnimationInOut: TJDUIRadioButton;
    jduButton26: TJDUIButton;
    btAnimateColor: TJDUIButton;
    btAnimateAlpha: TJDUIButton;
    btAnimateZoom: TJDUIButton;
    btAnimateLeftColor: TJDUIButton;
    btAnimateAlphaZoom: TJDUIButton;
    btAnimateLeftAlpha: TJDUIButton;
    btAnimateColorZoom: TJDUIButton;
    TimerForResetAnimation: TTimer;
    btAnimateAll: TJDUIButton;
    jduButton22: TJDUIButton;
    jduButton25: TJDUIButton;
    jduButton27: TJDUIButton;
    cbAnimateOpenStyle: TJDUIComboBox;
    tbAnimateOpenTime: TJDUITrackBar;
    jduButton28: TJDUIButton;
    jduButton29: TJDUIButton;
    cbAnimateCloseStyle: TJDUIComboBox;
    tbAnimateCloseTime: TJDUITrackBar;
    btAnimateOpenWindow: TJDUIButton;
    btAnimateOpenTime: TJDUIButton;
    btAnimateCloseTime: TJDUIButton;
    jduScrollView1: TJDUIScrollView;
    jduContainerPage6: TJDUIContainer;
    jduScrollView2: TJDUIScrollView;
    jduContainer6: TJDUIContainer;
    jduButton30: TJDUIButton;
    TimerForResetAllAnimateControls: TTimer;
    btJumpSelected: TJDUIButton;
    btStopJumpSelected: TJDUIButton;
    JDUIButton1: TJDUIButton;
    JDUIButton2: TJDUIButton;
    JDUIButton3: TJDUIButton;
    JDUIButton4: TJDUIButton;
    jduTitle: TJDUIContainer;
    btTitle: TJDUIButton;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure jduTab0Click(Sender: TObject);
    procedure tbSkinAlphaChange(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure cbSkinsChange(Sender: TObject);
    procedure btStartProgressClick(Sender: TObject);
    procedure TimerProgressTimer(Sender: TObject);
    procedure jduTrackBar1Change(Sender: TObject);
    procedure jduButton18Click(Sender: TObject);
    procedure cbShowCheckboxChanged(Sender: TObject);
    procedure cbShowBigImageChanged(Sender: TObject);
    procedure btCloseAllClick(Sender: TObject);
    procedure btOpenAllClick(Sender: TObject);
    procedure jduListViewItemSelected(Sender: TObject; AItem: TJDUIListItem);
    procedure btDeleteTreeNodeClick(Sender: TObject);
    procedure btAddTreeNodeBeforeClick(Sender: TObject);
    procedure btAddTreeNodeAfterClick(Sender: TObject);
    procedure jduPage2Resize(Sender: TObject);
    procedure ApplicationEventsMessage(var Msg: tagMSG; var Handled: Boolean);
    procedure edFontSizeChange(Sender: TObject);
    procedure cbLineSpaceChange(Sender: TObject);
    procedure edMessageInputChange(Sender: TObject);
    procedure edMessageInputEditMouseUP(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure miCutClick(Sender: TObject);
    procedure miPastClick(Sender: TObject);
    procedure miSelAllClick(Sender: TObject);
    procedure miCopyClick(Sender: TObject);
    procedure pmInputPopup(Sender: TObject);
    procedure btAddImageClick(Sender: TObject);
    procedure btBoldClick(Sender: TObject);
    procedure btItalicClick(Sender: TObject);
    procedure btUnderLineClick(Sender: TObject);
    procedure btSUBClick(Sender: TObject);
    procedure btSUPClick(Sender: TObject);
    procedure btCopyScreenClick(Sender: TObject);
    procedure ApplicationEventsException(Sender: TObject; E: Exception);
    procedure jduWebViewLoadEnd(Sender: TObject);
    procedure jduImageLoadingStart(Sender: TObject);
    procedure jduImageLoadingStop(Sender: TObject);
    procedure tbAnimateTimeChange(Sender: TObject);
    procedure btAnimateLeftClick(Sender: TObject);
    procedure btAnimateColorClick(Sender: TObject);
    procedure btAnimateAlphaClick(Sender: TObject);
    procedure TimerForResetAnimationTimer(Sender: TObject);
    procedure btAnimateZoomClick(Sender: TObject);
    procedure btAnimateLeftColorClick(Sender: TObject);
    procedure btAnimateAlphaZoomClick(Sender: TObject);
    procedure btAnimateLeftAlphaClick(Sender: TObject);
    procedure btAnimateColorZoomClick(Sender: TObject);
    procedure btAnimateAllClick(Sender: TObject);
    procedure tbAnimateOpenTimeChange(Sender: TObject);
    procedure tbAnimateCloseTimeChange(Sender: TObject);
    procedure btAnimateOpenWindowClick(Sender: TObject);
    procedure jduButton30Click(Sender: TObject);
    procedure TimerForResetAllAnimateControlsTimer(Sender: TObject);
    procedure btJumpSelectedClick(Sender: TObject);
    procedure btStopJumpSelectedClick(Sender: TObject);
    procedure JDUIButton1Click(Sender: TObject);
    procedure JDUIButton2Click(Sender: TObject);
    procedure JDUIButton3Click(Sender: TObject);
    procedure JDUIButton4Click(Sender: TObject);
  private
    FLastWindowState: TWindowState;
    FSkins: TList<TSkin>;
    procedure AnimateSwichControl(AContainer1, AContainer2: TJDUIContainer; Animate: Boolean; EndCallBack: TNotifyEvent; ADuration: Single);
    procedure TabSwitchEnd(Sender: TObject);
    procedure AnimatedShow(Sender: TObject);
    procedure ResetAnimiteBox(Sender: TObject);
    procedure InitAnimation;
    procedure InitEdit;
    procedure InitGridView;
    procedure InitTreeView;
    procedure InitViews;
    procedure UninitViews;
    procedure ScreenshotDeactivate(Sender: TObject);
    procedure ScreenshotDone(Sender: TObject);
  public
    { Public declarations }
  end;

  TListView = class(TJDUICustomTableItem)
  private
    FPosition: Integer;
    FButtonNO: TJDUIButton;
    FImageProject: TJDUIImage;
    FButtonProduct: TJDUIButton;
    FButtonAvailability: TJDUIButton;
    FButtonTotal: TJDUIButton;
    FPanelAvailability: TJDUIPanel;
    FPanel: TJDUIPanel;
    procedure UpdateView(APosition: Integer);
  public
    Constructor Create(AOwner: TComponent); override;
    Destructor Destroy; override;
  end;

  TTableViewListAdapter = class(TJDUITableViewAdapter)
  private
  protected
    function GetCount: Integer; override;
    function GetIsDynamicHeight: Boolean; override;
    function GetControlTypeCount: Integer; override;
    function GetControlType(APosition: Integer): Integer; override;
    procedure GetControl(APosition: Integer; var AControl: TControl;
      AParent: TJDUIContainer; AWidth, AHeight: Integer); override;
    function GetItemHeight(APosition: Integer; AParent: TJDUIContainer)
      : Cardinal; override;
    function GetItem(APosition: Integer): TObject; override;
    function GetItemID(APosition: Integer): String; override;
  end;

var
  DemoForm: TDemoForm;

implementation

{$R *.dfm}
const
  PRODUCTS:array[0..3, 0..3] of String =(('Women¡¯s Vintage Peacoat','320 In Stock','$3369E4A6','$29,192'),
                                         ('Women¡¯s Oatmeal Sweater','Out of Stock','$33FF7285','$29,192'),
                                         ('Women¡¯s Denim Shirt',    '3 In Stock',  '$33FFCA83','$29,192'),
                                         ('Women¡¯s Vintage Peacoat','3 In Stock',  '$33FFCA83','$29,192'));

function CompressImage(AFile: String): String;
var
  ABitmap32: TBitmap32;
  ATeampFileName: String;
  APngImage: PngImage2.TPngImage;
begin
    if SameText(ExtractFileExt(AFile), '.gif') then Exit(AFile);

    ATeampFileName := IOUtils.TPath.GetTempFileName;
    ATeampFileName := ATeampFileName.Replace
      (ExtractFileExt(ATeampFileName), '');
    ATeampFileName := ATeampFileName + '.png';
    try
      ABitmap32 := nil;
      if SameText(ExtractFileExt(AFile), '.png') then
      begin
        APngImage := PngImage2.TPngImage.Create;
        try
          try
            APngImage.LoadFromFile(AFile);
            ABitmap32 := GetBitmap32ByPngImage(APngImage);
          except
          end;
        finally
          APngImage.Free;
        end;
      end;

      if ABitmap32 = nil then
        ABitmap32 := GetBitmap32(AFile);

      if (ABitmap32.Width > 1000) or (ABitmap32.Height > 1000) then
      begin
        if ABitmap32.Width > ABitmap32.Height then
          ResizeBitmap32(ABitmap32, 1000,
            Round(1000 * (ABitmap32.Height / ABitmap32.Width)), True)
        else
          ResizeBitmap32(ABitmap32,
            Round(1000 * (ABitmap32.Width / ABitmap32.Height)), 1000, True);
      end;
      GetPngFile(ABitmap32, ATeampFileName);
    finally
      FreeAndNil(ABitmap32);
    end;

    Result := ATeampFileName;
end;


{$REGION 'TListView'}
procedure TListView.UpdateView(APosition: Integer);
var
  iIndex: Integer;
begin
  iIndex := APosition mod 4;
  Self.LockRepaint;
  try
    if (FPanel = nil) then
    begin
      FPanel := TJDUIPanel.Create(Self);
      FPanel.Parent := Self;
      FPanel.Color := $FF000000;
      FPanel.BorderColor := $FFf5f5f5;
      FPanel.Borders := [pbkBottomLine];
      FPanel.CreateCanvas(False);
    end;
    FPanel.SetBounds(0, Height - 1, Width, 1);
    FPanel.Layer.BringToFront;

    if (FButtonNO = nil) then
    begin
      FButtonNO := TJDUIButton.Create(Self);
      FButtonNO.Parent := Self;
      FButtonNO.Font.Size := 11;
      FButtonNO.Font.Color := $FF4D4F5C;
      FButtonNO.Font.Style := [];
      FButtonNO.ShowShadown := False;
      FButtonNO.ImageAlign := iatLeft;
      FButtonNO.CreateCanvas(False);
    end;
    FButtonNO.SetBounds(DemoForm.btNO.Left - 12, (Height - DemoForm.btNO.Height) div 2, DemoForm.btNO.Width, DemoForm.btNO.Height);
    FButtonNO.Caption := IntToStr(APosition + 1);
    FButtonNO.Layer.BringToFront;

    if (FImageProject = nil) then
    begin
      FImageProject := TJDUIImage.Create(Self);
      FImageProject.Parent := Self;
      FImageProject.CreateCanvas(False);
    end;
    FImageProject.SetBounds(DemoForm.btProduct.Left - 12, (Height - 42) div 2, 42, 42);
    if FPosition <> APosition then FImageProject.LoadFromFile(ExtractFilePath(Application.ExeName) + Format('images\ProductImg%d.png', [iIndex]));
    FImageProject.Layer.BringToFront;

    if (FButtonProduct = nil) then
    begin
      FButtonProduct := TJDUIButton.Create(Self);
      FButtonProduct.Parent := Self;
      FButtonProduct.Font.Size := 11;
      FButtonProduct.Font.Color := $FF4D4F5C;
      FButtonProduct.Font.Style := [];
      FButtonProduct.ShowShadown := False;
      FButtonProduct.ImageAlign := iatLeft;
      FButtonProduct.CreateCanvas(False);
    end;
    FButtonProduct.SetBounds(DemoForm.btProduct.Left + 50 - 12, (Height - DemoForm.btProduct.Height) div 2, DemoForm.btProduct.Width - 50, DemoForm.btProduct.Height);
    FButtonProduct.Caption := PRODUCTS[iIndex][0];
    FButtonProduct.Layer.BringToFront;

    if (FPanelAvailability = nil) then
    begin
      FPanelAvailability := TJDUIPanel.Create(Self);
      FPanelAvailability.Parent := Self;
      FPanelAvailability.CreateCanvas(False);
    end;
    FPanelAvailability.SetBounds(DemoForm.btAvailability.Left - 12, (Height - DemoForm.btAvailability.Height) div 2, DemoForm.btAvailability.Width, DemoForm.btAvailability.Height);
    FPanelAvailability.Color := StrToInt(PRODUCTS[iIndex][2]);
    FPanelAvailability.Layer.BringToFront;

    if (FButtonAvailability = nil) then
    begin
      FButtonAvailability := TJDUIButton.Create(Self);
      FButtonAvailability.Parent := Self;
      FButtonAvailability.Font.Size := 10;
      FButtonAvailability.Font.Color := $FF4D4F5C;
      FButtonAvailability.Font.Style := [];
      FButtonAvailability.ShowShadown := False;
      FButtonAvailability.ImageAlign := iatTop;
      FButtonAvailability.CreateCanvas(False);
    end;
    FButtonAvailability.SetBounds(DemoForm.btAvailability.Left - 12, (Height - DemoForm.btAvailability.Height) div 2, DemoForm.btAvailability.Width, DemoForm.btAvailability.Height);
    FButtonAvailability.Caption := PRODUCTS[iIndex][1];
    FButtonAvailability.Layer.BringToFront;

    if (FButtonTotal = nil) then
    begin
      FButtonTotal := TJDUIButton.Create(Self);
      FButtonTotal.Parent := Self;
      FButtonTotal.Font.Size := 11;
      FButtonTotal.Font.Color := $FF4D4F5C;
      FButtonTotal.Font.Style := [];
      FButtonTotal.ShowShadown := False;
      FButtonTotal.ImageAlign := iatLeft;
      FButtonTotal.CreateCanvas(False);
    end;
    FButtonTotal.SetBounds(DemoForm.btTotal.Left - 12, (Height - DemoForm.btTotal.Height) div 2, DemoForm.btTotal.Width, DemoForm.btTotal.Height);
    FButtonTotal.Caption := PRODUCTS[iIndex][3];
    FButtonTotal.Layer.BringToFront;
  finally
    Self.UnLockRepaint;
    FPosition := APosition;
  end;
end;

constructor TListView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPosition := -1;
end;

destructor TListView.Destroy;
begin
  inherited Destroy;
end;
{$ENDREGION}

{$REGION 'TTableViewSkinAdapter'}

function TTableViewListAdapter.GetCount: Integer;
begin
  result := 10000;
end;

function TTableViewListAdapter.GetIsDynamicHeight: Boolean;
begin
  result := False;
end;

function TTableViewListAdapter.GetControlTypeCount: Integer;
begin
  result := 1;
end;

function TTableViewListAdapter.GetControlType
  (APosition: Integer): Integer;
begin
  Exit(0);
end;

procedure TTableViewListAdapter.GetControl(APosition: Integer;
  var AControl: TControl; AParent: TJDUIContainer; AWidth, AHeight: Integer);
var
  AItemControl: TListView;
begin
  if AControl = nil then
  begin
    AControl := TListView.Create(AParent);
    AControl.Parent := AParent;
    AItemControl := TListView(AControl);
  end
  else
  begin
    AItemControl := TListView(AControl);
  end;
  AItemControl.Width := AWidth - 2;
  AItemControl.Height := AHeight;
  AItemControl.UpdateView(APosition);
end;

function TTableViewListAdapter.GetItemHeight(APosition: Integer;
  AParent: TJDUIContainer): Cardinal;
begin
  Result := 60;
end;

function TTableViewListAdapter.GetItem
  (APosition: Integer): TObject;
begin
  result := nil
end;

function TTableViewListAdapter.GetItemID
  (APosition: Integer): String;
begin
  result := IntToStr(APosition);
end;

{$ENDREGION}

procedure TDemoForm.FormCreate(Sender: TObject);
begin
  OnAnimatedShow := AnimatedShow;
  AllowResize := True;
  ShowIcon := False;
  ShowCaption := False;
  ShowSkinButton := False;
  ShowMaxOrRestoreButton := True;
  ShowMinButton := True;

  EnabledGlass := VistaUP and (not Win8) and (not Win10);
  DWMEnabled := EnabledGlass;

  BlendBorder := True;


  Self.ShowStyle := fssZoom;
  Self.HideStyle := fssZoom;

  Self.ShowTime := 0.6;
  Self.HideTime := 0.6;


  BorderMask := jduBorderMask;

  WorkAreaAlpha := 255;
  FormBackRes := jduFormBackRes;

  FormBackRes.FromFile(ExtractFilePath(Application.ExeName) + 'skins\skin1.jpg', bdtStretch);
  FormRes := JduFormRes;

  InitViews;
end;

procedure TDemoForm.FormDestroy(Sender: TObject);
begin
  UninitViews;
end;

procedure TDemoForm.btStartProgressClick(Sender: TObject);
begin
  if not TimerProgress.Enabled then
  begin
    TimerProgress.Enabled := True;
    btStartProgress.Caption := 'stop';
    TimerProgressTimer(nil);
  end
  else
  begin
    TimerProgress.Enabled := False;
    btStartProgress.Caption := 'start'
  end;
end;

procedure TDemoForm.btSUBClick(Sender: TObject);
begin
  edMessageInput.EditOSR.SelectedSUB := btSUB.ShowNineGridsType = ngtHover;
end;

procedure TDemoForm.btSUPClick(Sender: TObject);
begin
  edMessageInput.EditOSR.SelectedSUP := btSUP.ShowNineGridsType = ngtHover;
end;

procedure TDemoForm.btUnderLineClick(Sender: TObject);
begin
  edMessageInput.EditOSR.SelectedUnderLine := btUnderLine.ShowNineGridsType = ngtHover;
end;

procedure TDemoForm.TimerProgressTimer(Sender: TObject);
begin
  if (TimerProgress.Tag = 1) and (jduProgressBar1.Value >= jduProgressBar1.Max) then TimerProgress.Tag := -1;
  if (TimerProgress.Tag = -1) and (jduProgressBar1.Value <= jduProgressBar1.Min) then TimerProgress.Tag := 1;

  jduProgressBar1.AnimateInteger('Value', jduProgressBar1.Value + 10 * TimerProgress.Tag, 0.3);
end;

procedure TDemoForm.jduTrackBar1Change(Sender: TObject);
begin
  if not TimerProgress.Enabled then
  begin
    jduProgressBar1.Value := jduTrackBar1.Value;
  end;
end;

procedure TDemoForm.jduWebViewLoadEnd(Sender: TObject);
begin
  jduImageLoading.Stop;
end;

procedure TDemoForm.miCopyClick(Sender: TObject);
begin
  Popuping := False;
  edMessageInput.CopySelected;
end;

procedure TDemoForm.miCutClick(Sender: TObject);
begin
  Popuping := False;
  edMessageInput.CutSelected;
end;

procedure TDemoForm.miPastClick(Sender: TObject);
begin
  Popuping := False;
  edMessageInput.PasteFromClipboard;
end;

procedure TDemoForm.miSelAllClick(Sender: TObject);
begin
  Popuping := False;
  edMessageInput.SelectedAll;
end;

procedure TDemoForm.pmInputPopup(Sender: TObject);
begin
  miCut.Enabled := edMessageInput.SelLength > 0;
  miCopy.Enabled := miCut.Enabled;
  miPast.Enabled := edMessageInput.CanPast;
  miSelAll.Enabled := edMessageInput.EditOSR.GetLength > 0;
end;

procedure TDemoForm.ApplicationEventsException(Sender: TObject; E: Exception);
begin
//
end;

procedure TDemoForm.ApplicationEventsMessage(var Msg: tagMSG; var Handled: Boolean);
begin
  jduTableView.AppEventsMessage(Msg, Handled);
  if Handled then Exit;

  jduWebView.AppEventsMessage(Msg, Handled);
  if Handled then Exit;

  jduScrollView1.AppEventsMessage(Msg, Handled);
  if Handled then Exit;

  jduScrollView2.AppEventsMessage(Msg, Handled);
  if Handled then Exit;
end;

procedure TDemoForm.btAddImageClick(Sender: TObject);
var
  ACompressedFile: String;
begin
  Self.Popuping := True;
  try
    if OpenPictureDialog.Execute(Self.Handle) then
    begin
      ACompressedFile := CompressImage(OpenPictureDialog.FileName);
      edMessageInput.AddImage(ACompressedFile, ACompressedFile);
    end;
  finally
    Self.Popuping := False;
  end;
end;

procedure TDemoForm.btAddTreeNodeAfterClick(Sender: TObject);
var
  AItem: TJDUIListItem;
  AID: Cardinal;
begin
  jduListView.LockRepaint;
  try
    AID := GetTickCount;
    AItem := jduListView.Selected.ParentItem.Items.InsertAfter(Format('%d', [AID]), jduListView.Selected, False);
    AItem.Caption := Format('TreeNode_%d', [GetTickCount]);
    AItem.Caption3 := Format('Subtitle_%d', [AID]);
    AItem.Image := ExtractFilePath(Application.ExeName) + Format('images\avatar (%d).png', [1 + AID mod 10]);
    AItem.MakeVisible;
  finally
    jduListView.UnLockRepaint;
  end;
end;

procedure TDemoForm.btAddTreeNodeBeforeClick(Sender: TObject);
var
  AItem: TJDUIListItem;
  AID: Cardinal;
begin
  jduListView.LockRepaint;
  try
    AID := GetTickCount;
    AItem := jduListView.Selected.ParentItem.Items.InsertBefore(Format('%d', [AID]), jduListView.Selected, False);
    AItem.Caption := Format('TreeNode_%d', [GetTickCount]);
    AItem.Caption3 := Format('Subtitle_%d', [AID]);
    AItem.Image := ExtractFilePath(Application.ExeName) + Format('images\avatar (%d).png', [1 + AID mod 10]);
    AItem.MakeVisible;
  finally
    jduListView.UnLockRepaint;
  end;
end;

procedure TDemoForm.btBoldClick(Sender: TObject);
begin
  edMessageInput.EditOSR.SelectedBold := btBold.ShowNineGridsType = ngtHover;
end;

procedure TDemoForm.btCloseAllClick(Sender: TObject);
var
  AItem: TJDUIListItem;
begin
  jduListView.LockRepaint;
  try
    for AItem in jduListView.AllItems do
    begin
      if AItem.Group then AItem.Closed := True;
    end;
    jduListViewItemSelected(jduListView, jduListView.Selected);
  finally
    jduListView.UnLockRepaint;
  end;
end;

procedure TDemoForm.btCopyScreenClick(Sender: TObject);
begin
  ShowStyle := fssNone;
  FLastWindowState := WindowState;
  Hide;

  FreeAndNil(ScreenshotForm);
  ScreenshotForm := TScreenshotForm.Create(Self);
  ScreenshotForm.OnDeactivate := ScreenshotDeactivate;
  ScreenshotForm.OnScreenshotDone := ScreenshotDone;
  ScreenshotForm.Show;
  ScreenshotForm.BringToFront;
end;

procedure TDemoForm.ScreenshotDeactivate(Sender: TObject);
begin
  Show;
end;

procedure TDemoForm.ScreenshotDone(Sender: TObject);
begin
  try
    SendMessage(Handle, WM_SYSCOMMAND, SC_RESTORE, 0);
    if CanFocus then
      SetFocus;
    if edMessageInput.CanFocus then
      edMessageInput.SetFocus;
  finally
    edMessageInput.AddBitmap('', ScreenshotForm.ScreenshotBitmap);
  end;
end;

procedure TDemoForm.btDeleteTreeNodeClick(Sender: TObject);
var
  ANext: TJDUIListItem;
begin
  LockRepaint;
  try
    ANext := jduListView.Selected.GetNext;
    jduListView.Selected.ParentItem.Items.Delete(jduListView.Selected);
    ANext.Selected := True;
    jduListViewItemSelected(jduListView, ANext);
  finally
    UnLockRepaint;
  end;
end;

procedure TDemoForm.btJumpSelectedClick(Sender: TObject);
begin
  jduListView.Selected.Jump;
end;

procedure TDemoForm.btStopJumpSelectedClick(Sender: TObject);
begin
  jduListView.Selected.StopJump;
end;

procedure TDemoForm.btItalicClick(Sender: TObject);
begin
  edMessageInput.EditOSR.SelectedItalic := btItalic.ShowNineGridsType = ngtHover;
end;

procedure TDemoForm.btOpenAllClick(Sender: TObject);
var
  AItem: TJDUIListItem;
begin
  jduListView.LockRepaint;
  try
    for AItem in jduListView.AllItems do
    begin
      if AItem.Group then AItem.Closed := False;
    end;
  finally
    jduListView.UnLockRepaint;
  end;
end;

procedure TDemoForm.cbLineSpaceChange(Sender: TObject);
begin
  edMessageInput.LineSpace := 2 + Integer(cbLineSpace.ItemIndex);
end;

procedure TDemoForm.cbShowBigImageChanged(Sender: TObject);
begin
  jduListView.LockRepaint;
  try
    jduListView.ItemHeight := Math.IfThen(cbShowBigImage.Checked, 60, 35);
    jduListView.ItemSelHeight := jduListView.ItemHeight;
  finally
    jduListView.UnLockRepaint;
  end;
end;

procedure TDemoForm.cbShowCheckboxChanged(Sender: TObject);
begin
  jduListView.ShowCheckBox := cbShowCheckbox.Checked;
end;

procedure TDemoForm.cbSkinsChange(Sender: TObject);
var
  ASkin: TSkin;
begin
  ASkin := FSkins[cbSkins.ItemIndex];
  if ASkin.FSkinColor > 0 then
    Self.ChangeBack(ASkin.FSkinColor)
  else
    Self.ChangeBack(ASkin.FSkinFile, ASkin.FBackDrawType);
end;

procedure TDemoForm.edFontSizeChange(Sender: TObject);
begin
  case edFontSize.ItemIndex of
    0: edMessageInput.Font.Size := 10;
    1: edMessageInput.Font.Size := 14;
    2: edMessageInput.Font.Size := 18;
  end;
end;

procedure TDemoForm.edMessageInputChange(Sender: TObject);
begin
  Self.LockRepaint;
  try
    Self.btBold.Enabled := (edMessageInput.EditOSR.SelLength > 0) and
      (not edMessageInput.EditOSR.SelectedImage);
    Self.btUnderLine.Enabled := (edMessageInput.EditOSR.SelLength > 0) and
      (not edMessageInput.EditOSR.SelectedImage);
    Self.btSUB.Enabled := (edMessageInput.EditOSR.SelLength > 0) and
      (not edMessageInput.EditOSR.SelectedImage);
    Self.btSUP.Enabled := (edMessageInput.EditOSR.SelLength > 0) and
      (not edMessageInput.EditOSR.SelectedImage);
    Self.btItalic.Enabled := (edMessageInput.EditOSR.SelLength > 0) and
      (not edMessageInput.EditOSR.SelectedImage);

    if edMessageInput.EditOSR.SelectedBold then
    begin
      Self.btBold.NineGridsRes := jdu9GppmSelected;
      Self.btBold.ShowNineGridsType := ngtAlways;
    end
    else
    begin
      Self.btBold.NineGridsRes := jdu9GLightGrayNormal;
      Self.btBold.ShowNineGridsType := ngtHover;
    end;

    if edMessageInput.EditOSR.SelectedUnderLine then
    begin
      Self.btUnderLine.NineGridsRes := jdu9GppmSelected;
      Self.btUnderLine.ShowNineGridsType := ngtAlways;
    end
    else
    begin
      Self.btUnderLine.NineGridsRes := jdu9GLightGrayNormal;
      Self.btUnderLine.ShowNineGridsType := ngtHover;
    end;

    if edMessageInput.EditOSR.SelectedItalic then
    begin
      Self.btItalic.NineGridsRes := jdu9GppmSelected;
      Self.btItalic.ShowNineGridsType := ngtAlways;
    end
    else
    begin
      Self.btItalic.NineGridsRes := jdu9GLightGrayNormal;
      Self.btItalic.ShowNineGridsType := ngtHover;
    end;

    if edMessageInput.EditOSR.SelectedSUB then
    begin
      Self.btSUB.NineGridsRes := jdu9GppmSelected;
      Self.btSUB.ShowNineGridsType := ngtAlways;
    end
    else
    begin
      Self.btSUB.NineGridsRes := jdu9GLightGrayNormal;
      Self.btSUB.ShowNineGridsType := ngtHover;
    end;

    if edMessageInput.EditOSR.SelectedSUP then
    begin
      Self.btSUP.NineGridsRes := jdu9GppmSelected;
      Self.btSUP.ShowNineGridsType := ngtAlways;
    end
    else
    begin
      Self.btSUP.NineGridsRes := jdu9GLightGrayNormal;
      Self.btSUP.ShowNineGridsType := ngtHover;
    end;
  finally
    Self.UnLockRepaint;
  end;
end;

procedure TDemoForm.edMessageInputEditMouseUP(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  pt: TPoint;
begin
  if Button <> mbRight then
    Exit;

  Popuping := True;
  pt := Mouse.CursorPos;
  jpmInput.Popup(pt.X, pt.Y, Self);
end;

procedure TDemoForm.InitAnimation;
begin
  tbAnimateTime.Value := 800;

  Self.cbInterpolationType.Items.Add.Caption := 'Linear';
  Self.cbInterpolationType.Items.Add.Caption := 'Quadratic';
  Self.cbInterpolationType.Items.Add.Caption := 'Cubic';
  Self.cbInterpolationType.Items.Add.Caption := 'Quartic';
  Self.cbInterpolationType.Items.Add.Caption := 'Quintic';
  Self.cbInterpolationType.Items.Add.Caption := 'Sinusoidal';
  Self.cbInterpolationType.Items.Add.Caption := 'Exponential';
  Self.cbInterpolationType.Items.Add.Caption := 'Circular';
  Self.cbInterpolationType.Items.Add.Caption := 'Elastic';
  Self.cbInterpolationType.Items.Add.Caption := 'Back';
  Self.cbInterpolationType.Items.Add.Caption := 'Bounce';
  Self.cbInterpolationType.ItemIndex := 2;

  Self.cbAnimateOpenStyle.Items.Add.Caption := 'Blend';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'ZoomInOut';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'Zoom';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'Jump';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'Spring';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'BlendScroll';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'BlendScrollRight';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'SliderLeft';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'SliderTop';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'SliderRight';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'SliderBottom';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'WarpingLeft';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'Bloat';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'CutTop';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'CutBottom';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'CutLeft';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'CutRight';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'ZoomSliderLeft';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'ZoomSliderTop';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'ZoomSliderRight';
  Self.cbAnimateOpenStyle.Items.Add.Caption := 'ZoomSliderBottom';
  Self.cbAnimateOpenStyle.ItemIndex := 12;

  Self.cbAnimateCloseStyle.Items.Add.Caption := 'Blend';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'ZoomInOut';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'Zoom';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'Jump';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'Spring';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'BlendScroll';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'BlendScrollRight';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'SliderLeft';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'SliderTop';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'SliderRight';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'SliderBottom';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'WarpingLeft';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'Bloat';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'CutTop';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'CutBottom';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'CutLeft';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'CutRight';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'ZoomSliderLeft';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'ZoomSliderTop';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'ZoomSliderRight';
  Self.cbAnimateCloseStyle.Items.Add.Caption := 'ZoomSliderBottom';
  Self.cbAnimateCloseStyle.ItemIndex := 12;

end;

procedure TDemoForm.InitEdit;
begin
  edFontSize.Items.Add.Caption := 'Small text';
  edFontSize.Items.Add.Caption := 'Medium text';
  edFontSize.Items.Add.Caption := 'Large text';
  edFontSize.ItemIndex := 0;

  cbLineSpace.Items.Add.Caption := '1.0 line spacing';
  cbLineSpace.Items.Add.Caption := '1.2 line spacing';
  cbLineSpace.Items.Add.Caption := '1.4 line spacing';
  cbLineSpace.Items.Add.Caption := '1.6 line spacing';
  cbLineSpace.Items.Add.Caption := '1.8 line spacing';
  cbLineSpace.Items.Add.Caption := '2.0 line spacing';
  cbLineSpace.Items.Add.Caption := '2.2 line spacing';
  cbLineSpace.Items.Add.Caption := '2.4 line spacing';
  cbLineSpace.Items.Add.Caption := '2.6 line spacing';
  cbLineSpace.Items.Add.Caption := '2.8 line spacing';
  cbLineSpace.Items.Add.Caption := '3.0 line spacing';
  cbLineSpace.ItemIndex := 0;

  Self.edMessageInput.EditOSR.AllowDragImageSize := True;
end;

procedure TDemoForm.InitGridView;
var
  AItem: TJDUIListItem;
  iLoop: Integer;
begin
  for iLoop := 0 to 30 do
  begin
    AItem := jduGridView.Items.Add(Format('%d', [iLoop]), False);
    AItem.Caption := Format('ITEM_%d', [iLoop]);
    AItem.Image := ExtractFilePath(Application.ExeName) + Format('images\app (%d).png', [1 + iLoop mod 31]);
  end;
end;

procedure TDemoForm.InitTreeView;
var
  AGroup1, AGroup2,
  AItem: TJDUIListItem;
  iLoop, jLoop, kLoop, iLevel2Count, iLevel3Count: Integer;
begin
  jduListView.BeginUpdate;
  try
    for iLoop := 0 to 10 do
    begin
      AGroup1 := jduListView.Items.Add(Format('%d', [iLoop]), True);
      AGroup1.Caption := Format('TreeNode_%d', [iLoop]);
      AGroup1.Closed := iLoop > 0;

      randomize;
      iLevel2Count := 3 + random(5);
      for jLoop := 0 to iLevel2Count do
      begin
        AGroup2 := AGroup1.Items.Add(Format('%d_%d', [iLoop, jLoop]), True);
        AGroup2.Caption := Format('TreeNode_%d_%d', [iLoop, jLoop]);
        AGroup2.Closed := (iLoop > 0) or (jLoop > 0);
        randomize;
        iLevel3Count := 5 + random(30);
        for kLoop := 0 to iLevel3Count do
        begin
          AItem := AGroup2.Items.Add(Format('%d_%d_%d', [iLoop, jLoop, kLoop]), False);
          AItem.Caption := Format('TreeNode_%d_%d_%d', [iLoop, jLoop, kLoop]);
          AItem.Caption3 := Format('Subtitle_%d_%d_%d', [iLoop, jLoop, kLoop]);
          AItem.Image := ExtractFilePath(Application.ExeName) + Format('images\avatar (%d).png', [1 + kLoop mod 10]);
        end;
      end;
    end;
  finally
    jduListView.EndUpdate;
  end;
end;

procedure TDemoForm.InitViews;
var
  iLoop: Integer;
  ASkin: TSkin;
  procedure AddSkin(ASkinName, ASkinFile: String; ASkinColor: TColor32; ABackDrawType: TJDUIBackDrawType);
  begin
    ASkin := TSkin.Create;
    ASkin.FSkinName := ASkinName;
    ASkin.FSkinFile := ASkinFile;
    ASkin.FSkinColor := ASkinColor;
    ASkin.FBackDrawType := ABackDrawType;
    FSkins.Add(ASkin);
  end;
begin
  Self.LockRepaint;
  try
    jdu9GLightBlueNormal.ChangeToColor($FAAA63, True);
    jdu9GLightBlueHover.ChangeToColor($DE9758, True);
    jdu9GLightBlueDown.ChangeToColor($C9884F, True);

    jdu9GLightYellowNormal.ChangeToColor($0098FF, True);
    jdu9GLightYellowHover.ChangeToColor($008DED, True);
    jdu9GLightYellowDown.ChangeToColor($0081D8, True);

    jdu9GLightGrayNormal.ChangeToColor($DDDDDD, True);
    jdu9GLightGrayHover.ChangeToColor($DADADA, True);
    jdu9GLightGrayDown.ChangeToColor($D8D8D8, True);

    jdu9GLightRedNormal.ChangeToColor($5050FF, True);
    jdu9GLightRedHover.ChangeToColor($5050E0, True);
    jdu9GLightRedDown.ChangeToColor($5050D0, True);


    FSkins := TList<TSkin>.Create;
    tbSkinAlpha.Value := WorkAreaAlpha;

    for iLoop := 1 to 5 do
    begin
      AddSkin(' Image skin '+ IntToStr(iLoop),
      ExtractFilePath(Application.ExeName) + 'skins\skin' + IntToStr(iLoop) + '.jpg', 0, bdtStretch);
    end;

    AddSkin(' Solid skin (#29B6F6)', '', $FF29B6F6, bdtStretch);
    AddSkin(' Solid skin (#9575CD)', '', $FF9575CD, bdtStretch);
    AddSkin(' Solid skin (#F06292)', '', $FFF06292, bdtStretch);
    AddSkin(' Solid skin (#8BC34A)', '', $FF8BC34A, bdtStretch);
    AddSkin(' solid skin (#4DB6AC)', '', $FF4DB6AC, bdtStretch);
    AddSkin(' solid skin (#FFA000)', '', $FFFFA000, bdtStretch);

    for ASkin in FSkins do
      cbSkins.Items.Add.Caption := ASkin.FSkinName;
    cbSkins.OnChange := nil;
    cbSkins.ItemIndex := 0;
    cbSkins.OnChange := cbSkinsChange;

    InitTreeView;
    InitGridView;
    InitEdit;
    InitAnimation;

    jduPanelBackground.CreateCanvas(False);
    jduPanelBackground.Layer.SendToBack;
  finally
    Self.UnLockRepaint;
  end;
end;

procedure TDemoForm.UninitViews;
var
  ASkin: TSkin;
begin
  for ASkin in FSkins do ASkin.Free;
  FreeAndNil(FSkins);
end;

procedure TDemoForm.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Button = mbLeft) then
  begin
    ReleaseCapture;
    Perform(WM_SYSCOMMAND, $F012, 0);
  end;
end;

procedure TDemoForm.jduButton18Click(Sender: TObject);
begin
  if btImage.Tag = 0 then
  begin
    btImage.Tag := 1;
    btImage.NewPicture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'images\headimage1.png');
  end
  else
  begin
    btImage.Tag := 0;
    btImage.NewPicture.LoadFromFile(ExtractFilePath(Application.ExeName) + 'images\headimage2.png');
  end;

  randomize;
  btImage.AnimateInType := TJDUIButtonAnimateType(1 + random(5));
  btImage.AnimateSwitchToNewPicture(True);
end;

procedure TDemoForm.jduButton30Click(Sender: TObject);
var
  AControl: TJDUIControl;
  iLoop: Integer;
begin
  TimerForResetAllAnimateControls.Enabled := False;
  for iLoop := 0 to jduContainerPage6.ControlCount - 1 do
  begin
    AControl := jduContainerPage6.Controls[iLoop] as TJDUIControl;
    if AControl.Tag = 0 then AControl.Tag := AControl.Top;
    AControl.AnimateInteger('Top', jduPage6.Height, Self.tbAnimateTime.Value / 1000, iLoop * 0.02,
                                  TJDUIAnimationType(Math.IfThen(rbAnimationIn.Checked, 0, Math.IfThen(rbAnimationOut.Checked, 1, 2))),
                                  TJDUIInterpolationType(cbInterpolationType.ItemIndex),
                                  False,
                                  False,
                                  False,
                                  nil);
    AControl.AnimateInteger('Alpha', 0, Self.tbAnimateTime.Value / 1000, iLoop * 0.02,
                                  TJDUIAnimationType(Math.IfThen(rbAnimationIn.Checked, 0, Math.IfThen(rbAnimationOut.Checked, 1, 2))),
                                  TJDUIInterpolationType(cbInterpolationType.ItemIndex),
                                  False,
                                  False,
                                  False,
                                  nil);
  end;
  TimerForResetAllAnimateControls.Interval := Self.tbAnimateTime.Value + 1000;
  TimerForResetAllAnimateControls.Enabled := True;
end;

procedure TDemoForm.JDUIButton1Click(Sender: TObject);
begin
  jduMessageBox(Handle, ' Hello£¬Welcome£¡', 'Title',  MB_OK);
end;

procedure TDemoForm.JDUIButton2Click(Sender: TObject);
begin
  jduMessageBox(Handle, ' Hello£¬Welcome£¡', 'Title',  MB_OKCANCEL);
end;

procedure TDemoForm.JDUIButton3Click(Sender: TObject);
begin
  jduMessageBox(Handle, ' Hello£¬Welcome£¡', 'Title',  MB_YESNO);
end;

procedure TDemoForm.JDUIButton4Click(Sender: TObject);
begin
  jduMessageBox(Handle, ' Hello£¬Welcome£¡', 'Title',  MB_ABORTRETRYIGNORE);
end;

procedure TDemoForm.TimerForResetAllAnimateControlsTimer(Sender: TObject);
var
  AControl: TJDUIControl;
  iLoop: Integer;
begin
  TimerForResetAllAnimateControls.Enabled := False;
  for iLoop := 0 to jduContainerPage6.ControlCount - 1 do
  begin
    AControl := jduContainerPage6.Controls[iLoop] as TJDUIControl;
    AControl.Top := -AControl.Height;

    AControl.AnimateInteger('Top', AControl.Tag, Self.tbAnimateTime.Value / 1000, iLoop * 0.02,
                                  TJDUIAnimationType(Math.IfThen(rbAnimationIn.Checked, 0, Math.IfThen(rbAnimationOut.Checked, 1, 2))),
                                  TJDUIInterpolationType(cbInterpolationType.ItemIndex),
                                  False,
                                  False,
                                  False,
                                  nil);
    AControl.AnimateInteger('Alpha', 255, Self.tbAnimateTime.Value / 1000, iLoop * 0.02,
                                  TJDUIAnimationType(Math.IfThen(rbAnimationIn.Checked, 0, Math.IfThen(rbAnimationOut.Checked, 1, 2))),
                                  TJDUIInterpolationType(cbInterpolationType.ItemIndex),
                                  False,
                                  False,
                                  False,
                                  nil);
  end;
end;

procedure TDemoForm.btAnimateLeftAlphaClick(Sender: TObject);
begin
  Self.btAnimateLeft.Click;
  Self.btAnimateAlpha.Click;
end;

procedure TDemoForm.btAnimateLeftClick(Sender: TObject);
begin
  TimerForResetAnimation.Enabled := False;
  jduPanelAnimateBox.AnimateInteger('Left', 538, Self.tbAnimateTime.Value / 1000, 0,
                                  TJDUIAnimationType(Math.IfThen(rbAnimationIn.Checked, 0, Math.IfThen(rbAnimationOut.Checked, 1, 2))),
                                  TJDUIInterpolationType(cbInterpolationType.ItemIndex),
                                  False,
                                  False,
                                  False,
                                  ResetAnimiteBox);
end;

procedure TDemoForm.btAnimateLeftColorClick(Sender: TObject);
begin
  Self.btAnimateLeft.Click;
  Self.btAnimateColor.Click;
end;

procedure TDemoForm.btAnimateOpenWindowClick(Sender: TObject);
var
  AnimateForm: TAnimateForm;
begin
  AnimateForm := TAnimateForm.Create(Self);
  try
    AnimateForm.ShowStyle := TJDUIFormShowStyle(cbAnimateOpenStyle.ItemIndex + 1);
    AnimateForm.HideStyle := TJDUIFormShowStyle(cbAnimateCloseStyle.ItemIndex + 1);
    AnimateForm.ShowTime := Self.tbAnimateOpenTime.Value / 1000;
    AnimateForm.HideTime := Self.tbAnimateCloseTime.Value / 1000;
    AnimateForm.ShowModal;
  finally
    AnimateForm.Free;
  end;
end;

procedure TDemoForm.btAnimateColorClick(Sender: TObject);
begin
  TimerForResetAnimation.Enabled := False;
  jduPanelAnimateBox.AnimateColor('Color', $FFD7303D, Self.tbAnimateTime.Value / 1000, 0,
                                  TJDUIAnimationType(Math.IfThen(rbAnimationIn.Checked, 0, Math.IfThen(rbAnimationOut.Checked, 1, 2))),
                                  TJDUIInterpolationType(cbInterpolationType.ItemIndex),
                                  False,
                                  False,
                                  False,
                                  ResetAnimiteBox);
end;

procedure TDemoForm.btAnimateColorZoomClick(Sender: TObject);
begin
  Self.btAnimateZoom.Click;
  Self.btAnimateColor.Click;
end;

procedure TDemoForm.btAnimateAllClick(Sender: TObject);
begin
  Self.btAnimateLeft.Click;
  Self.btAnimateAlpha.Click;
  Self.btAnimateZoom.Click;
  Self.btAnimateColor.Click;
end;

procedure TDemoForm.btAnimateAlphaClick(Sender: TObject);
begin
  TimerForResetAnimation.Enabled := False;
  jduPanelAnimateBox.AnimateInteger('Alpha', 0, Self.tbAnimateTime.Value / 1000, 0,
                                    TJDUIAnimationType(Math.IfThen(rbAnimationIn.Checked, 0, Math.IfThen(rbAnimationOut.Checked, 1, 2))),
                                    TJDUIInterpolationType(cbInterpolationType.ItemIndex),
                                    False,
                                    True,
                                    False,
                                    ResetAnimiteBox);
end;

procedure TDemoForm.btAnimateAlphaZoomClick(Sender: TObject);
begin
  Self.btAnimateAlpha.Click;
  Self.btAnimateZoom.Click;
end;

procedure TDemoForm.btAnimateZoomClick(Sender: TObject);
begin
  TimerForResetAnimation.Enabled := False;
  jduPanelAnimateBox.AnimateZoom(10, 100, Self.tbAnimateTime.Value / 1000, 0,
                                    TJDUIAnimationType(Math.IfThen(rbAnimationIn.Checked, 0, Math.IfThen(rbAnimationOut.Checked, 1, 2))),
                                    TJDUIInterpolationType(cbInterpolationType.ItemIndex),
                                    False,
                                    False,
                                    False,
                                    ResetAnimiteBox);
end;

procedure TDemoForm.TimerForResetAnimationTimer(Sender: TObject);
begin
  TimerForResetAnimation.Enabled := False;
  jduPanelAnimateBox.AnimateStopAll;
  jduPanelAnimateBox.AnimateInteger('Alpha', 255, Self.tbAnimateTime.Value / 1000, 0,
                                    TJDUIAnimationType(Math.IfThen(rbAnimationIn.Checked, 0, Math.IfThen(rbAnimationOut.Checked, 1, 2))),
                                    TJDUIInterpolationType(cbInterpolationType.ItemIndex),
                                    False,
                                    False,
                                    False,
                                    nil);
  jduPanelAnimateBox.AnimateColor('Color', $FF38AFFA, Self.tbAnimateTime.Value / 1000, 0,
                                  TJDUIAnimationType(Math.IfThen(rbAnimationIn.Checked, 0, Math.IfThen(rbAnimationOut.Checked, 1, 2))),
                                  TJDUIInterpolationType(cbInterpolationType.ItemIndex),
                                  False,
                                  True,
                                  False,
                                  nil);
  jduPanelAnimateBox.AnimateInteger('Left', 38, Self.tbAnimateTime.Value / 1000, 0,
                                  TJDUIAnimationType(Math.IfThen(rbAnimationIn.Checked, 0, Math.IfThen(rbAnimationOut.Checked, 1, 2))),
                                  TJDUIInterpolationType(cbInterpolationType.ItemIndex),
                                  False,
                                  False,
                                  False,
                                  nil);
end;

procedure TDemoForm.ResetAnimiteBox(Sender: TObject);
begin
  TimerForResetAnimation.Enabled := True;
end;

procedure TDemoForm.jduImageLoadingStart(Sender: TObject);
begin
  jduImageLoading.Show;
end;

procedure TDemoForm.jduImageLoadingStop(Sender: TObject);
begin
  jduImageLoading.Hide;
end;

procedure TDemoForm.jduListViewItemSelected(Sender: TObject; AItem: TJDUIListItem);
begin
  Self.LockRepaint;
  try
    btAddTreeNodeAfter.Enabled := (AItem <> nil) and (not AItem.Group);
    btAddTreeNodeBefore.Enabled := btAddTreeNodeAfter.Enabled;
    btDeleteTreeNode.Enabled := btAddTreeNodeAfter.Enabled;
    btStopJumpSelected.Enabled := btAddTreeNodeAfter.Enabled;
    btJumpSelected.Enabled := btAddTreeNodeAfter.Enabled;
  finally
    Self.UnLockRepaint;
  end;
end;

procedure TDemoForm.jduPage2Resize(Sender: TObject);
begin
  if (jduTableView.Adapter <> nil) and jduPage2.Visible then jduTableView.Adapter.NotifyDataChange;
end;

procedure TDemoForm.jduTab0Click(Sender: TObject);
  procedure SetButtonState(Button: TJDUIButton; ClickButton: TJDUIButton);
  begin
    Button.Down := ClickButton = Button;
    if Button.Down then
      Button.Font.Color := $00333333
    else
      Button.Font.Color := $00777777;
  end;
var
  AContainer1,
  AContainer2: TJDUIContainer;
begin
  Self.LockRepaint;
  try
    if jduTab0.Down then AContainer2 := jduPage0;
    if jduTab1.Down then AContainer2 := jduPage1;
    if jduTab2.Down then AContainer2 := jduPage2;
    if jduTab3.Down then AContainer2 := jduPage3;
    if jduTab4.Down then AContainer2 := jduPage4;
    if jduTab5.Down then AContainer2 := jduPage5;
    if jduTab6.Down then AContainer2 := jduPage6;

    SetButtonState(jduTab0, Sender as TJDUIButton);
    SetButtonState(jduTab1, Sender as TJDUIButton);
    SetButtonState(jduTab2, Sender as TJDUIButton);
    SetButtonState(jduTab3, Sender as TJDUIButton);
    SetButtonState(jduTab4, Sender as TJDUIButton);
    SetButtonState(jduTab5, Sender as TJDUIButton);
    SetButtonState(jduTab6, Sender as TJDUIButton);

    if jduTab0.Down then AContainer1 := jduPage0;
    if jduTab1.Down then AContainer1 := jduPage1;
    if jduTab2.Down then AContainer1 := jduPage2;
    if jduTab3.Down then AContainer1 := jduPage3;
    if jduTab4.Down then AContainer1 := jduPage4;
    if jduTab5.Down then AContainer1 := jduPage5;
    if jduTab6.Down then AContainer1 := jduPage6;

    if jduTab2.Down then
    begin
      btListBackCard.CreateCanvas(False);
      btListBackCard.Layer.SendToBack;
      if (jduTableView.Adapter = nil) then jduTableView.Adapter := TTableViewListAdapter.Create;
      jduTableView.Adapter.NotifyDataChange;
    end;

    if jduTab3.Down then
    begin
      jduGridView.ReAlignAll;
    end;

    if jduTab5.Down then
    begin
      if jduWebView.Tag = 0 then
      begin
        jduWebView.Tag := 1;
        jduImageLoading.Start;
        jduWebView.Load('https://html5test.com');
      end;
    end;
    AnimateSwichControl(AContainer1, AContainer2, True, TabSwitchEnd, 0.18);
  finally
    Self.UnLockRepaint;
  end;
end;

procedure TDemoForm.TabSwitchEnd(Sender: TObject);
procedure CheckSwitchControl(AControl: TControl);
begin
  if AControl.Left >= AControl.Parent.Width then
    AControl.Visible := False
  else if AControl.Left + AControl.Width <= 0 then
    AControl.Visible := False;

  if AControl.Left  = 0 then
    AControl.Align := alClient;
end;
begin
  CheckSwitchControl(jduPage0);
  CheckSwitchControl(jduPage1);
  CheckSwitchControl(jduPage2);
  CheckSwitchControl(jduPage3);
  CheckSwitchControl(jduPage4);
  CheckSwitchControl(jduPage5);
  CheckSwitchControl(jduPage6);
end;

procedure TDemoForm.AnimateSwichControl(AContainer1, AContainer2: TJDUIContainer; Animate: Boolean; EndCallBack: TNotifyEvent; ADuration: Single);
var
  AHeight: Integer;
begin
  if AContainer1 = AContainer2 then
  begin
    Exit;
  end;

  Animate := Animate and Animation;
  Self.LockRepaint;
  AHeight := AContainer1.Height;
  try
    AContainer1.AnimateStop('Left');
    if AContainer2 <> nil then
    begin
      AContainer2.AnimateStop('Left');
      AHeight := AContainer2.Height;
      AContainer2.Align := alNone;
      if Animate then
      begin
        if AContainer2.Tag > AContainer1.Tag then
          AContainer2.Left := 0
        else
          AContainer2.Left := 0;
      end
      else
      begin
          AContainer2.Left := AContainer1.Left
      end;
      AContainer2.SetBounds(AContainer2.Left, AContainer2.Top, AContainer2.Parent.Width, AHeight);
    end;

    AContainer1.Align := alNone;
    AContainer1.Animation := False;
    AContainer1.Visible := True;
    if Animate then
    begin
      if AContainer2.Tag > AContainer1.Tag then
        AContainer1.SetBounds(AContainer2.Left - AContainer2.Parent.Width, AContainer2.Top, AContainer1.Parent.Width, AHeight)
      else
        AContainer1.SetBounds(AContainer2.Left + AContainer2.Parent.Width, AContainer2.Top, AContainer1.Parent.Width, AHeight);
    end
    else
    begin
      AContainer1.SetBounds(0, AContainer1.Top, AContainer1.Parent.Width, AHeight);
    end;

    if Animate then
    begin
      if AContainer2.Tag > AContainer1.Tag then
        AContainer2.AnimateInteger('Left', AContainer1.Parent.Width, ADuration, 0, jduAnimationOut, jduInterpolationCubic, False, True, False, EndCallBack)
      else
        AContainer2.AnimateInteger('Left', -AContainer2.Parent.Width, ADuration, 0, jduAnimationOut, jduInterpolationCubic, False, True, False, EndCallBack);

      AContainer1.AnimateInteger('Left', 0, ADuration, 0, jduAnimationOut, jduInterpolationCubic, False, True, False);
    end;
  finally
    try
      AContainer1.Anchors := [akLeft, akTop, akRight, akBottom];
      if AContainer2 <> nil then
        AContainer2.Anchors := [akRight, akTop];

      if (not Animate) then
        if Assigned(AContainer2) then
        begin
          AContainer2.Visible := False;
          AContainer2.Align := alClient;
        end;

      if (not Animate) then
        if Assigned(AContainer1) then
          AContainer1.ReAlignControls;
    finally
      UnLockRepaint;
    end;
  end;
end;

procedure TDemoForm.tbAnimateCloseTimeChange(Sender: TObject);
begin
  btAnimateCloseTime.Caption := IntToStr(tbAnimateCloseTime.Value);
end;

procedure TDemoForm.tbAnimateOpenTimeChange(Sender: TObject);
begin
  btAnimateOpenTime.Caption := IntToStr(tbAnimateOpenTime.Value);
end;

procedure TDemoForm.tbAnimateTimeChange(Sender: TObject);
begin
  btAnimateTime.Caption := IntToStr(tbAnimateTime.Value);
end;

procedure TDemoForm.tbSkinAlphaChange(Sender: TObject);
begin
  WorkAreaAlpha := tbSkinAlpha.Value;
end;

procedure TDemoForm.AnimatedShow(Sender: TObject);
begin

end;

end.
