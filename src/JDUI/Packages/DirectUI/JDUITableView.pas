unit JDUITableView;

interface

uses
  WinApi.Windows,
  JDUIUtils,
  JDUIBaseControl,
  Vcl.Graphics,
  Vcl.Controls,
  SysUtils,
  WinApi.Messages,
  Classes,
  TypInfo,
  Forms,
  Generics.Collections;

type
  TJDUITableViewAdapter = class
  private
    FOnNotifyDataChange: TNotifyEvent;
    procedure DoNotifyDataChange;
    property OnNotifyDataChange: TNotifyEvent read FOnNotifyDataChange write FOnNotifyDataChange;
  protected
    function GetCount: Integer; virtual; abstract;
    function GetIsDynamicHeight: Boolean; virtual; abstract;
    function GetControlTypeCount: Integer; virtual; abstract;
    function GetControlType(APosition: Integer): Integer; virtual; abstract;
    procedure GetControl(APosition: Integer; var AControl: TControl; AParent: TJDUIContainer; AWidth, AHeight: Integer); virtual; abstract;
    function GetItemHeight(APosition: Integer; AParent: TJDUIContainer): Cardinal; virtual; abstract;
    function GetItem(APosition: Integer): TObject; virtual; abstract;
    function GetItemID(APosition: Integer): String; virtual; abstract;
  public
    procedure NotifyDataChange; virtual;
  end;

  TTableViewOnGetControlEvent = procedure(Sender: TObject; var AControl: TControl) of object;
  TTableViewOnGetCountEvent = procedure(Sender: TObject; var ACount: Integer) of object;
  TControls = TList<TControl>;
  TJDUICustomTableItem = class(TJDUIContainer)
  protected
  end;

  TJDUICustomTableView = class(TJDUICustomTableItem)
  private
    FScrollBar: TJDUIScrollBar;
    FScrollBarRes: TJDUIScrollBarRes;
    FTransparent: Boolean;
    FBackgroundColor: TColor;
    FReusableControls: TDictionary<Integer, TControls>;
    FShowingControls: TDictionary<String, TControl>;
    FInvalidedItems: TList<String>;
    FTopPosition: Integer;
    FTopScroll: Integer;
    FLockCount: Integer;
    FReAligning: Boolean;
    procedure ReAlignViews(NeedRealignScrollbar: Boolean);
    procedure ClearReusableViews;
    procedure ClearShowingViews;
    procedure PushReusableControl(AType: Integer; AControl: TControl);
    function PopReusableControl(AType: Integer): TControl;
  private
    function GetTopControl: TControl;
  private
    FLastMouseWheelDelta: Integer;
    FAniScroll: TJDUIFormIntAni;
    FShowed,
    FReAligned,
    FScrolling,
    FContentUnderScrollbar: Boolean;
    FContentHeight: Int64;
    FDefaultLineHeight: Integer;
    procedure ReAlignScrollBar;
    procedure ScrollOneRow(AScrollDown: Boolean);
    procedure ScrollPage(AScrollDown: Boolean);
    procedure ScrollBarButtonDown(Sender: TObject; ButtonType: TScrollBarButtonType);
    procedure ScrollBarTrackMove(Sender: TObject; ATrackPos: Int64);
    procedure AniScrollFinish(Sender: TObject);
    procedure AniScrollTick(Sender: TObject);
    function GetShowingControls: TArray<TControl>;
  private
    FAdapter: TJDUITableViewAdapter;
    procedure SetAdapter(Adapter: TJDUITableViewAdapter);
    procedure AdapterNotifyDataChange(Sender: TObject);
    procedure MouseWheel(ADelta: Integer);
  protected
    procedure CMVisibleChanged(var msg: TMessage); message CM_VISIBLECHANGED;
    procedure WMMOUSEWHEEL(var msg: TCMMOUSEWHEEL); message CM_MOUSEWHEEL;
    procedure WMSIZE(var msg: TWMSIZE); message WM_SIZE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AppEventsMessage(var Msg: tagMSG; var Handled: Boolean);

    procedure BeginUpdate;
    procedure EndUpdate;
    procedure ResetAnimate;
    procedure Invalid(AID: String);
    procedure ScrollTo(AIndex: Integer);

    property Adapter: TJDUITableViewAdapter read FAdapter write SetAdapter;
    property TopControl: TControl read GetTopControl;
    property ScrollBarRes: TJDUIScrollBarRes read FScrollBarRes write FScrollBarRes;
    property DefaultLineHeight: Integer read FDefaultLineHeight write FDefaultLineHeight;
    property ShowingControls: TArray<TControl> read GetShowingControls;
  end;

  TJDUITableView = class(TJDUICustomTableView)
  published
    property ScrollBarRes;
    property DefaultLineHeight;
  end;
  procedure Register;

implementation

{$region 'TTableViewAdapter'}
procedure TJDUITableViewAdapter.NotifyDataChange;
begin
  DoNotifyDataChange;
end;

procedure TJDUITableViewAdapter.DoNotifyDataChange;
begin
  if Assigned(FOnNotifyDataChange) then FOnNotifyDataChange(Self);  
end;
{$endregion}

{$region 'TJDUICustomTableItem'}
//procedure TJDUICustomTableItem.WMPaint(var Message: TWMPaint);
//begin
//  Message.Result := 1;
//end;
//
//procedure TJDUICustomTableItem.WMPrintClient(var Message: TWMPrintClient);
//begin
//  Message.Result := 1;
//end;
//
//procedure TJDUICustomTableItem.CMInvalidate(var Message: TMessage);
//begin
//  Message.Result := 1;
//end;
{$endregion}

{$region 'TJDUICustomTableView'}
constructor TJDUICustomTableView.Create(AOwner: TComponent);
begin
  FShowed := False;
  FReAligned := False;
  inherited Create(AOwner);
  FReusableControls := TDictionary<Integer, TControls>.Create;
  FShowingControls := TDictionary<String, TControl>.Create;
  FInvalidedItems := TList<String>.Create;
end;

destructor TJDUICustomTableView.Destroy;
begin
  try
    ClearReusableViews;
    FreeAndNil(FReusableControls);
    ClearShowingViews;
    FreeAndNil(FShowingControls);
    FreeAndNil(FInvalidedItems);
    FreeAndNil(FAdapter);
  finally
    inherited Destroy;
  end;
end;

procedure TJDUICustomTableView.SetAdapter(Adapter: TJDUITableViewAdapter);
begin
  if FAdapter = Adapter then Exit;
  if Assigned(FAdapter) then FAdapter.OnNotifyDataChange := nil;

  FreeAndNil(FAdapter);
  FAdapter := Adapter;
  if Assigned(FAdapter) then FAdapter.OnNotifyDataChange := AdapterNotifyDataChange;
end;

procedure TJDUICustomTableView.AdapterNotifyDataChange(Sender: TObject);
var
  Control: TControl;
begin

  Self.LockRepaint;
  try
    for Control in FShowingControls.Values do
    begin
      Control.Visible := False;
    end;

    ReAlignViews(True);
    ReAlignControls;
  finally
    Self.UnLockRepaint;
  end;
end;

procedure TJDUICustomTableView.ClearShowingViews;
var
  Control: TControl;
begin
  for Control in FShowingControls.Values do
  begin
    Control.Free;
  end;
  FShowingControls.Clear;
  FInvalidedItems.Clear;
end;

procedure TJDUICustomTableView.ClearReusableViews;
var
  iLoop: Integer;
  Control: TControl;
  Controls: TControls;
begin
  for Controls in FReusableControls.Values do
  begin
    for iLoop := Controls.Count - 1 downto 0 do
    begin
      Control := Controls[iLoop];
      FreeAndNil(Control);
    end;
    Controls.Clear;
    Controls.Free;
  end;
  FReusableControls.Clear;
end;

procedure TJDUICustomTableView.BeginUpdate;
begin
  Inc(FLockCount);
  if Assigned(BaseForm) then BaseForm.LockRepaint;
end;

procedure TJDUICustomTableView.EndUpdate;
begin
  if Assigned(BaseForm) then BaseForm.UnLockRepaint;
  Dec(FLockCount);
  if FLockCount < 0 then FLockCount := 0;

  if (FLockCount = 0) and (Visible) then ReAlignViews(True);
end;

procedure TJDUICustomTableView.CMVisibleChanged(var msg: TMessage);
begin
  inherited;

  if Visible then
  begin
    ReAlignViews(True);
    FShowed := True;
  end;
end;

procedure TJDUICustomTableView.WMSIZE(var msg: TWMSIZE);
begin
  inherited;

  if not Visible then Exit;
  if Left > Parent.Width then Exit;
  if Left + Width < 0 then Exit;

  ReAlignViews(True);
  ReAlignControls;
  FShowed := True;
end;

procedure TJDUICustomTableView.ResetAnimate;
begin
  FReAligned := False;
  FShowed := False;
  if Assigned(FScrollBar) then FScrollBar.Visible := False;
end;

procedure TJDUICustomTableView.Invalid(AID: String);
begin
  if not FInvalidedItems.Contains(AID) then FInvalidedItems.Add(AID);
end;

procedure TJDUICustomTableView.ScrollTo(AIndex: Integer);
var
  iCount,
  iTop, iBottom, iHeight, iLoop: Integer;
  AStopTrackPos: Integer;
begin
  if AIndex < 0 then Exit;
  if not Assigned(FScrollBar) then Exit;
  if not FScrollBar.Visible then Exit;

  iTop := 0;
  iHeight := 0;
  iBottom := 0;
  iCount := Adapter.GetCount;
  for iLoop := 0 to AIndex do
  begin
    iHeight := Adapter.GetItemHeight(iLoop, Self);
    Inc(iBottom, iHeight);
    iTop := iBottom - iHeight;
  end;

  if (FScrollBar.TrackPos > iTop) then
  begin
    AStopTrackPos := iTop;
  end
  else
  if (FScrollBar.TrackPos + FScrollBar.InVisibleRange < iBottom) then
  begin
    AStopTrackPos := iBottom - FScrollBar.InVisibleRange;
  end
  else
  begin
    Exit;
  end;

  if Assigned(FAniScroll) then
    FAniScroll.Stop(False);
  FreeAndNil(FAniScroll);
  FAniScroll := TJDUIFormIntAni.Create(Self.BaseForm);
  FAniScroll.Duration := 0.3;
  FAniScroll.AnimationType := jduAnimationOut;
  FAniScroll.Interpolation := jduInterpolationQuadratic;
  FAniScroll.RealTime := True;
  FAniScroll.StartValue := FScrollBar.TrackPos;
  FAniScroll.StopValue := AStopTrackPos;
  FAniScroll.OnFinish := AniScrollFinish;
  FAniScroll.OnTick := AniScrollTick;
  FAniScroll.Start;
end;

procedure TJDUICustomTableView.ReAlignViews(NeedRealignScrollbar: Boolean);
var
  AID: String;
  ATop,
  AHeight,
  ACount,
  APosition: Integer;
  AControl: TControl;
  ATypeCount: Integer;
  AType: Integer;
  ADynamicHeight: Boolean;
  AVisibleItems: TList<String>;
  ASizing: Boolean;
begin
  if not Assigned(Adapter) then Exit;
  if FReAligning then Exit;

  ACount := Adapter.GetCount;

  ATypeCount := Adapter.GetControlTypeCount;
  ADynamicHeight := Adapter.GetIsDynamicHeight; //是否动态ContentHeight, 即每一行的高度不是固定的(或是未知的) 滚动时要不断调整滚动条的长度（类似Android）。
  ATop := 0;
  if not ADynamicHeight then
  begin
    if Assigned(FScrollBar) and FScrollBar.Visible then
      ATop := -FScrollBar.TrackPos;
  end
  else
  begin

  end;

  APosition := 0;
  FContentHeight := 0;

  FReAligning := True;
  AVisibleItems := TList<String>.Create;
  if Assigned(BaseForm) then
  begin
    BaseForm.LockRepaint;
    ASizing := BaseForm.Sizing;
    BaseForm.Sizing := True; //FScrolling;
  end;
  Self.LockRepaint;
  try
    while (APosition < ACount) do
    begin
      AType := Adapter.GetControlType(APosition);
      AID := Adapter.GetItemID(APosition);

      if not ADynamicHeight then
      begin
        {$region 'IOS模式，每一行的高度均为已知数'}
        AHeight := Adapter.GetItemHeight(APosition, Self);
        FContentHeight := FContentHeight + AHeight;
        if (ATop >= Height) or (ATop + AHeight <= 0) then
        begin
          if FShowingControls.ContainsKey(AID) then
          begin
            PushReusableControl(AType, FShowingControls[AID]);
            FShowingControls.Remove(AID);
          end;
        end
        else if FShowingControls.ContainsKey(AID) then
        begin
          AControl := FShowingControls[AID];
          if (FInvalidedItems.Contains(AID)) or (AControl.Parent <> Self) or (not AControl.Visible) then
          begin
            FInvalidedItems.Remove(AID);
            Adapter.GetControl(APosition, AControl, Self, Width - 10, AHeight);
          end;
          AControl.Visible := True;
          AControl.SetBounds(0, ATop, Width - 10, AHeight);
          //if (AControl is TJDUIContainer) then (AControl as TJDUIContainer).ReAlignControls;

          AVisibleItems.Add(AID);
        end
        else
        begin
          AControl := PopReusableControl(AType);
          Adapter.GetControl(APosition, AControl, Self, Width - 10, AHeight);
          AControl.SetBounds(0, ATop, Width - 10, AHeight);
          AControl.Visible := True;
          //if (AControl is TJDUIContainer) then (AControl as TJDUIContainer).ReAlignControls;

          if FShowingControls.ContainsKey(AID) then FShowingControls.Remove(AID);
          FShowingControls.Add(AID, AControl);
          AVisibleItems.Add(AID);
        end;
        Inc(ATop, AHeight);
        {$endregion}
      end
      else
      begin
        {$region 'Android模式，每一行的高度均为未知数（动态计算得出）'}
        if (APosition < FTopPosition) or (ATop >= Height) then
        begin
          if FShowingControls.ContainsKey(AID) then
          begin
            PushReusableControl(AType, FShowingControls[AID]);
            FShowingControls.Remove(AID);
          end;
        end
        else
        begin
          AControl := PopReusableControl(AType);
          Adapter.GetControl(APosition, AControl, Self, Width, AControl.Height);
          if AControl.Width <> Width then AControl.Width := Width;
          AControl.SetBounds(0, ATop, AControl.Width, AControl.Height);
        end;
        {$endregion}
      end;

      Inc(APosition);
    end;

    for AID in Self.FShowingControls.Keys do
    begin
      if AVisibleItems.Contains(AID) then continue;

      PushReusableControl(AType, FShowingControls[AID]);
      FShowingControls.Remove(AID);
    end;
  finally
    Self.UnLockRepaint;
    if NeedRealignScrollbar then
    begin
      ReAlignScrollBar;
    end;
    ReAlignControls;
    if Assigned(BaseForm) then
    begin
      BaseForm.Sizing := ASizing;
      BaseForm.UnLockRepaint;
    end;
    FReAligned := True;
    FReAligning := False;
    AVisibleItems.Free;
  end;
end;

function TJDUICustomTableView.GetTopControl: TControl;
begin
  Result := nil;
end;

function TJDUICustomTableView.GetShowingControls: TArray<TControl>;
begin
  Result := FShowingControls.Values.ToArray;
end;

procedure TJDUICustomTableView.ReAlignScrollBar;
var
  ANeedRepaint,
  AOldVisible,
  ANewVisible,
  AOldReAligning: Boolean;
  AOldTrackPos: Int64;
  ADelay: Single;

  iLoop: Integer;
begin
  if not Assigned(FScrollBar) then
  begin
    FScrollBar := TJDUIScrollBar.Create(Self);
    FScrollBar.Parent := Self;
    FScrollBar.Visible := False;
    FScrollBar.OnButtonDown := ScrollBarButtonDown;
    FScrollBar.OnTrackMove := ScrollBarTrackMove;
    FScrollBar.EnableParentClip := False;
  end;

  if not Assigned(FScrollBarRes) then
  begin
    FScrollBar.Visible := False;
    Exit;
  end;

  FScrollBar.ScrollBarRes := FScrollBarRes;
  FScrollBar.SetBounds(Width - FScrollBar.MinWidth - FScrollBarRes.HMargin, 0, FScrollBar.MinWidth, Height);

  ANeedRepaint := False;
  if (FScrollBar.Max <> FContentHeight) or
     (FScrollBar.InVisibleRange <> Height) then
  begin
    FScrollBar.Max := FContentHeight;
    FScrollBar.InVisibleRange := Height;

    AOldTrackPos := FScrollBar.TrackPos;
    FScrollBar.TrackPos := FScrollBar.TrackPos;
    if AOldTrackPos <> FScrollBar.TrackPos then
    begin
      FReAligning := False;
      ReAlignViews(False);
      Exit;
    end;
    ANeedRepaint := True;
  end;

  AOldVisible := FScrollBar.Visible;
  ANewVisible := FScrollBar.Max > FScrollBar.InVisibleRange;
  if FScrollBar.Visible <> ANewVisible then
  begin
    FScrollBar.Visible := ANewVisible;
    if ANewVisible then
      FScrollBar.BringToFront;
  end;
  if ANeedRepaint then FScrollBar.ForceRePaint;

  if (AOldVisible <> ANewVisible) and (not FContentUnderScrollbar) then
  begin
    AOldReAligning := FReAligning;
    FReAligning := False;
    ReAlignViews(False);
    FReAligning := AOldReAligning;
  end;

  if ANewVisible and FContentUnderScrollbar then
  begin
    if Clips.Right <> FScrollBar.Width + FScrollBar.ScrollBarRes.HMargin * 2 then
      Clips.Right := FScrollBar.Width + FScrollBar.ScrollBarRes.HMargin * 2;
  end
  else
  begin
    if Clips.Right <> 0 then
      Clips.Right := 0;
  end;
end;

procedure TJDUICustomTableView.AniScrollFinish(Sender: TObject);
begin
  FreeAndNil(FAniScroll);
end;

procedure TJDUICustomTableView.AniScrollTick(Sender: TObject);
var
  AValue: Integer;
begin
  if Assigned(FScrollBar) then
  begin
    FScrolling := True;
    try
      AValue := FAniScroll.GetValue;
      if AValue < FScrollBar.GetMinTrackPos then AValue := FScrollBar.GetMinTrackPos;
      if AValue > FScrollBar.GetMaxTrackPos then AValue := FScrollBar.GetMaxTrackPos;
      FScrollBar.TrackPos := AValue;
      if (FAniScroll.StartValue <> FScrollBar.TrackPos) and ((FScrollBar.TrackPos <= FScrollBar.GetMinTrackPos) or (FScrollBar.TrackPos >= FScrollBar.GetMaxTrackPos)) then
      begin
        FAniScroll.Running := False;
      end;

      ReAlignViews(True);
    finally
      FScrolling := False;
    end;
  end;
end;

procedure TJDUICustomTableView.ScrollBarTrackMove(Sender: TObject; ATrackPos: Int64);
var
  AStartValue: Integer;
  AStopValue: Integer;
begin
  if Assigned(FScrollBar) then
  begin
    FScrolling := True;
    try
      if Assigned(FAniScroll) then FAniScroll.Stop(False);
      if (FScrollBar.TrackPos <> ATrackPos) then
      begin
        FScrollBar.TrackPos := ATrackPos;
        if FScrollBar.TrackPos = 0 then
        begin
          OutputDebugString(PChar(Format('FScrollBar.TrackPos := %d', [FScrollBar.TrackPos])));
        end;
        ReAlignViews(True);
      end;
    finally
      FScrolling := False;
    end;
  end;
end;

procedure TJDUICustomTableView.ScrollBarButtonDown(Sender: TObject; ButtonType: TScrollBarButtonType);
begin
  if ButtonType = btTop then
  begin
    ScrollOneRow(False);
  end
  else if (ButtonType = btBottom) then
  begin
    ScrollOneRow(True);
  end
  else if (ButtonType = btBackgroundUP) then
  begin
    ScrollPage(False);
  end
  else if (ButtonType = btBackgroundDown) then
  begin
    ScrollPage(True);
  end;
end;

procedure TJDUICustomTableView.ScrollOneRow(AScrollDown: Boolean);
var
  AStartValue: Integer;
  AStopValue: Integer;
begin
  if Animation then
  begin
    if Assigned(FAniScroll) then
    begin
      AStartValue := FAniScroll.GetValue;
      if AScrollDown then
        AStopValue := FAniScroll.StopValue + GetDPISize(FDefaultLineHeight)
      else
        AStopValue := FAniScroll.StopValue - GetDPISize(FDefaultLineHeight);
      FAniScroll.Stop(False);
    end
    else
    begin
      AStartValue := FScrollBar.TrackPos;
      if AScrollDown then
        AStopValue := FScrollBar.TrackPos + GetDPISize(FDefaultLineHeight)
      else
        AStopValue := FScrollBar.TrackPos - GetDPISize(FDefaultLineHeight);
    end;

    if AStopValue < FScrollBar.GetMinTrackPos then AStopValue := FScrollBar.GetMinTrackPos;
    if AStopValue > FScrollBar.GetMaxTrackPos then AStopValue := FScrollBar.GetMaxTrackPos;

    FAniScroll := TJDUIFormIntAni.Create(BaseForm);
    FAniScroll.Duration := 0.5;
    FAniScroll.AnimationType := jduAnimationOut;
    FAniScroll.Interpolation := jduInterpolationQuintic;
    FAniScroll.RealTime := False;
    FAniScroll.OnFinish := AniScrollFinish;
    FAniScroll.OnTick := AniScrollTick;
    FAniScroll.StartValue := AStartValue;
    FAniScroll.StopValue := AStopValue;
    FAniScroll.Start;
  end
  else
  begin
    FScrolling := True;
    try
      if AScrollDown then
        FScrollBar.TrackPos := FScrollBar.TrackPos + GetDPISize(FDefaultLineHeight)
      else
        FScrollBar.TrackPos := FScrollBar.TrackPos - GetDPISize(FDefaultLineHeight);

      RealignViews(True);
    finally
      FScrolling := False;
    end;
  end;
end;

procedure TJDUICustomTableView.ScrollPage(AScrollDown: Boolean);
var
  AStartValue: Integer;
  AStopValue: Integer;
begin
  if not Assigned(FScrollBar) then Exit;
  if not FScrollBar.Visible then Exit;

  if Animation then
  begin
    if Assigned(FAniScroll) then
    begin
      AStartValue := FAniScroll.GetValue;

      if AScrollDown then
        AStopValue := FAniScroll.StopValue + Height
      else
        AStopValue := FAniScroll.StopValue - Height;
      FAniScroll.Stop(False);
    end
    else
    begin
      AStartValue := FScrollBar.TrackPos;

      if AScrollDown then
        AStopValue := FScrollBar.TrackPos + Height
      else
        AStopValue := FScrollBar.TrackPos - Height;
    end;

    if AStopValue < FScrollBar.GetMinTrackPos then AStopValue := FScrollBar.GetMinTrackPos;
    if AStopValue > FScrollBar.GetMaxTrackPos then AStopValue := FScrollBar.GetMaxTrackPos;

    FAniScroll := TJDUIFormIntAni.Create(BaseForm);
    FAniScroll.Duration := 0.5;
    FAniScroll.AnimationType := jduAnimationOut;
    FAniScroll.Interpolation := jduInterpolationQuintic;
    FAniScroll.RealTime := False;
    FAniScroll.OnFinish := AniScrollFinish;
    FAniScroll.OnTick := AniScrollTick;
    FAniScroll.StartValue := AStartValue;
    FAniScroll.StopValue := AStopValue;
    FAniScroll.Start;
  end
  else
  begin
    FScrolling := True;
    try
      if AScrollDown then
        FScrollBar.TrackPos := FScrollBar.TrackPos + FDefaultLineHeight * ((Height div FDefaultLineHeight) + 1)
      else
        FScrollBar.TrackPos := FScrollBar.TrackPos - FDefaultLineHeight * ((Height div FDefaultLineHeight) + 1);

      ReAlignViews(True);
    finally
      FScrolling := False;
    end;
  end;
end;

procedure TJDUICustomTableView.WMMOUSEWHEEL(var msg: TCMMOUSEWHEEL);
begin
  DefaultHandler(Msg);
  if Assigned(FScrollBar) and (FScrollBar.Visible) then
  begin
    MouseWheel(msg.WheelDelta);
  end;
end;

procedure TJDUICustomTableView.MouseWheel(ADelta: Integer);
begin
  if Assigned(FScrollBar) and (FScrollBar.Visible) then
  begin
    FScrolling := True;
    try
      if ADelta > 0 then
      begin
        FScrollBar.TrackPos := FScrollBar.TrackPos - 50;
      end
      else if (ADelta < 0) then
      begin
        FScrollBar.TrackPos := FScrollBar.TrackPos + 50;
      end;

      RealignViews(True);
    finally
      FScrolling := False;
    end;
  end;
end;

procedure TJDUICustomTableView.AppEventsMessage(var Msg: tagMSG; var Handled: Boolean);
var
  pt: TPoint;
  AWMMouseWheel: TWMMouseWheel;
begin
  if not CheckVisible then Exit;
  if (not Assigned(FScrollBar)) or (not FScrollBar.Visible) then Exit;

  if (Msg.message = WM_MOUSEWHEEL) then
  begin
    AWMMouseWheel := TWMMouseWheel(Pointer(@Msg.message)^);
    with AWMMouseWheel do
    begin
      pt := Self.ClientToScreen(Point(0, 0));
      if PtInRect(Rect(pt.X, pt.Y, pt.X + Width, pt.Y + Height), Mouse.CursorPos) then
      begin
        MouseWheel(WheelDelta);
        WheelDelta := 0;
        Result := 1;
        Handled := True;
      end;
    end;
    Exit;
  end;
end;

procedure TJDUICustomTableView.PushReusableControl(AType: Integer; AControl: TControl);
var
  Controls: TControls;
begin
  if FReusableControls.ContainsKey(AType) then
  begin
    Controls := FReusableControls[AType];
  end
  else
  begin
    Controls := TControls.Create;
    FReusableControls.Add(AType, Controls);
  end;

  AControl.Visible := False;
  Controls.Add(AControl);
end;

function TJDUICustomTableView.PopReusableControl(AType: Integer): TControl;
var
  Controls: TControls;
  AControl: TControl;
begin
  if FReusableControls.ContainsKey(AType) then
  begin
    Controls := FReusableControls[AType];
    if Controls.Count = 0 then
    begin
      FReusableControls.Remove(AType);
      Exit(nil);
    end;

    AControl := Controls[0];
    Controls.Delete(0);
    if Controls.Count = 0 then
    begin
      Controls.Free;
      FReusableControls.Remove(AType);
    end;
    AControl.Visible := True;
    Exit(AControl);
  end
  else
  begin
    Exit(nil);
  end;
end;

{$endregion}

procedure Register;
begin
  RegisterComponents('JDUI', [TJDUITableView]);
end;

end.
