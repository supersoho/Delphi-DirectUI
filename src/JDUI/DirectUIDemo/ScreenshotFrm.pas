unit ScreenshotFrm;

interface

uses
  Generics.Collections, JDUIUtils, JDUIControl, JDUIBaseControl, ScreenshotToolFrm, Gr32_Lines, SuperObject, jinUtils, DateUtils,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, GR32, GR32_Image, GR32_Layers, Clipbrd,
  Vcl.AppEvnts, GR32_Objects, GR32_Misc, Vcl.Menus, Vcl.ImgList,
  PngImageList, Vcl.ExtCtrls, System.ImageList;

type
  TSaveDialog = class(Vcl.Dialogs.TSaveDialog)
  protected
    function TaskModalDialog(DialogFunc: Pointer; var DialogData): Bool; override;
  end;

  TDragingType = (dgtNone, dgtMove, dgtLeftTop, dgtTop, dgtRightTop, dgtLeft, dgtRight, dgtLeftBottom, dgtBottom, dgtRightBottom);
  TDrawLayer = class
  private
    FActionType: TActionType;
    FActionArg: ISuperObject;
    FActionArgs: TSuperArray;
    FActionBMP: TBitmap32;
    FColor: TColor;
    FSize: TToolSize;
    function GetSize: Integer;
    function GetColor32: TColor32;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TScreenshotForm = class(TForm)
    Image32: TImage32;
    ApplicationEvents2: TApplicationEvents;
    SaveDialog: TSaveDialog;
    pmMenus: TPopupMenu;
    miArrow: TMenuItem;
    miRect: TMenuItem;
    miCircle: TMenuItem;
    miPen: TMenuItem;
    miText: TMenuItem;
    miOffline: TMenuItem;
    jpmMenus: TJDUIPopupMenu;
    miUndo: TMenuItem;
    miReset: TMenuItem;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    N4: TMenuItem;
    imgMenus: TPngImageList;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Image32MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer; Layer: TCustomLayer);
    procedure ApplicationEvents1Message(var Msg: tagMSG;
      var Handled: Boolean);
    procedure Image32MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure Image32MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
    procedure Image32DblClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ApplicationEvents2Deactivate(Sender: TObject);
    procedure N4Click(Sender: TObject);
    procedure miResetClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    FDragingType: TDragingType;
    FLeftTopRect,
    FTopRect,
    FRightTopRect,
    FLeftRect,
    FLeftBottomRect,
    FBottomRect,
    FRightBottomRect,
    FRightRect: TRect;
    
    FMouseDown: Boolean;
    FSelecting: Boolean;
    FSelected: Boolean;
    FSelectPoint: TPoint;
    FSelectedArea: TRect;

    FSnapped: Boolean;
    FSnappedArea: TRect;
    
    FMagnifyingGlassTimes: Integer;
    FScreen: TBitmap32;
    FMagnifyingGlassLayer: TBitmapLayer;
    FSelectLayer: TBitmapLayer;
    FSnapWinLayer: TBitmapLayer;
    FSelectSizeLayer: TBitmapLayer;

    FOnScreenshotDone: TNotifyEvent;
    FScreenshotBitmap: TBitmap;

    procedure GetScreenshot(bmp: TBitmap32);
    procedure SnapWindow;
    procedure SetMagnifyingGlas(X, Y: Integer);
    procedure SetSelectLayer;
    procedure SetSnapWinLayer;
    procedure CopySelectedBitmap;
    procedure SaveSelectedBitmap(AFile: String);
    procedure GetSelectedBitmap(ABitmap32: TBitmap32);
    function GetSelectedRect: TRect;
    procedure CancelSelected(X, Y: Integer);
  private
    FToolbarForm: TScreenshotToolForm;
    FDrawMode: Boolean;
    FDrawing: Boolean;
    FDrawStartPoint: TPoint;
    FDrawEndPoint: TPoint;
    FDrawActionType: TActionType;
    FDrawLayers: TObjectList<TDrawLayer>;
    FDrawBitmap: TBitmap32;

    procedure DrawBegin(X, Y: Integer);
    procedure Drawing(X, Y: Integer);
    procedure DrawEnd(X, Y: Integer);

    procedure DrawLayer(ADrawLayer: TDrawLayer; ABitmap32: TBitmap32);
    procedure DrawArrow(ADrawLayer: TDrawLayer; ABitmap32: TBitmap32);
    procedure DrawRect(ADrawLayer: TDrawLayer; ABitmap32: TBitmap32);
    procedure DrawCircle(ADrawLayer: TDrawLayer; ABitmap32: TBitmap32);
    procedure DrawPen(ADrawLayer: TDrawLayer; ABitmap32: TBitmap32);

    procedure SetActionArg;
    procedure SetArrowActioArg(ADrawLayer: TDrawLayer);
    procedure SetRectActioArg(ADrawLayer: TDrawLayer);
    procedure SetCircleActioArg(ADrawLayer: TDrawLayer);
    procedure SetPenActioArg(ADrawLayer: TDrawLayer);


    procedure EnterDrawMode;
    procedure LeaveDrawMode;
    procedure ShowToolbar;
    procedure HideToolbar;
    procedure GetDesktopWindowRect;
    procedure ClearRects;
    procedure ToolbarFormAction(Sender: TObject; ActionType: TActionType);
    procedure ToolbarFormDestroy(Sender: TObject);
    procedure ToolbarFormResize(Sender: TObject);
    procedure ToolbarFormActionColorChanged(Sender: TObject);
    procedure ToolbarFormToolSizeChanged(Sender: TObject);
  private
    FAniLeft: TJDUIIntegerAnimation;
    FAniTop: TJDUIIntegerAnimation;
    FAniRight: TJDUIIntegerAnimation;
    FAniBottom: TJDUIIntegerAnimation;
    procedure AniFinish(Sender: TObject);
    procedure AniTick(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoScreenshotDone;
  public
    property ScreenshotBitmap: TBitmap read FScreenshotBitmap;
    property OnScreenshotDone: TNotifyEvent read FOnScreenshotDone write FOnScreenshotDone;
  end;

  TWindowRect = record
    Handle: HWND;
    Rect: TRect;
  end;

var
  TopWindowRects: TList<TWindowRect>;
  ChildWindowRects:  Generics.Collections.TDictionary<HWND, TList<TRect>>;
  ScreenshotForm: TScreenshotForm;

implementation

uses WinApi.CommDlg;

const 
  LineColor = $FFa0ea00;
  //LineColor = $FF00adff;


{$R *.dfm}
function TSaveDialog.TaskModalDialog(DialogFunc: Pointer; var DialogData): Bool;
begin
  TOpenFilename(DialogData).hWndOwner :=(Owner as TWincontrol).handle;
  result := inherited TaskModalDialog(DialogFunc, DialogData);
end;

function TDrawLayer.GetSize: Integer;
begin
  if FSize = tsSmall then
    Result := 1
  else if FSize = tsBig then
    Result := 5
  else
    Result := 3;
end;

function TDrawLayer.GetColor32: TColor32;
begin
  Result := Color32(FColor) or $FF000000;
end;

constructor TDrawLayer.Create;
begin
  FActionArg := TSuperObject.Create;
  FActionArgs := TSuperArray.Create;
end;

destructor TDrawLayer.Destroy;
begin
  try
    FActionArg := nil;
    FActionArgs.Free;
    FreeAndNil(FActionBMP);
  finally
    inherited Destroy;
  end;
end;

procedure TScreenshotForm.GetScreenshot(bmp: TBitmap32);
const
  CAPTUREBLT = $40000000;
var
  //hdcScreen: HDC;
  //hdcCompatible: HDC;
  //hbmScreen: HBITMAP;

  ADC:HDC;
begin
  SetBounds(0, 0, Screen.DesktopWidth, Screen.DesktopHeight);
  FScreen.SetSize(Screen.DesktopWidth, Screen.DesktopHeight);
  Image32.SetBounds(0, 0, Screen.DesktopWidth, Screen.DesktopHeight);
  Image32.Bitmap.SetSize(Screen.DesktopWidth, Screen.DesktopHeight);
  Image32.PaintToCanvas := True;

  ADC := GetDC(0);
  try
    BitBlt(bmp.Canvas.Handle,
      0, 0,
      bmp.Width, bmp.Height,
      ADC,
      0, 0,
      SRCCOPY or CAPTUREBLT);
    bmp.ResetAlpha(255);
  finally
    ReleaseDC(0, ADC);
  end;

  {
  hdcScreen := CreateDC('DISPLAY', nil, nil, nil);
  hdcCompatible := CreateCompatibleDC(hdcScreen);
  hbmScreen := CreateCompatibleBitmap(hdcScreen,
    GetDeviceCaps(hdcScreen, HORZRES),
    GetDeviceCaps(hdcScreen, VERTRES));
  SelectObject(hdcCompatible, hbmScreen);

  BitBlt(bmp.Canvas.Handle,
    0, 0,
    bmp.Width, bmp.Height,
    hdcScreen,
    0, 0,
    SRCCOPY or CAPTUREBLT);
  bmp.ResetAlpha(255);

  DeleteDC(hdcScreen);
  DeleteDC(hdcCompatible);
  DeleteObject(hbmScreen);
  }
end;

procedure TScreenshotForm.ApplicationEvents1Message(var Msg: tagMSG;
  var Handled: Boolean);
begin
  if Msg.message = WM_MOUSEWHEEL then
  begin
    with TWMMouseWheel(Pointer(@Msg.message)^) do
    begin
      if WheelDelta > 0 then Inc(FMagnifyingGlassTimes);
      if WheelDelta < 0 then Dec(FMagnifyingGlassTimes);
      if FMagnifyingGlassTimes < 2 then FMagnifyingGlassTimes := 2;
      if FMagnifyingGlassTimes > 10 then FMagnifyingGlassTimes := 10;
      SetMagnifyingGlas(XPOS, YPOS);
      WheelDelta := 0;
      Result := 1;
      Handled := True;
    end;
  end;

  if Msg.message = WM_RBUTTONDOWN then
  begin
    if FSelected then
    begin
      With TWMMouse(Pointer(@Msg.message)^) do
      begin
        if PtInRect(GetSelectedRect, Pos) then
        begin
          Handled := True;
        end;
      end;
    end;
  end;

  if (Msg.message = WM_MOUSEMOVE) OR (Msg.message = WM_NCMOUSEMOVE) then
  begin
    if Assigned(FToolbarForm) then
      if isChild(FToolbarForm.Handle, Msg.hwnd) or (FToolbarForm.Handle = Msg.hwnd) then
        FToolbarForm.SetFocus;
  end;
end;

procedure TScreenshotForm.ApplicationEvents2Deactivate(Sender: TObject);
begin
  Close;
end;

procedure TScreenshotForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    WndParent := (Owner as TForm).Handle;
  end;
end;

procedure TScreenshotForm.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
  if Owner is TForm then (Owner as TForm).Show;
end;

procedure TScreenshotForm.FormCreate(Sender: TObject);
var
  ABitmap32: TBitmap32;
begin
  FMagnifyingGlassTimes := 4;

  SetWindowLong(Handle, GWL_EXSTYLE, GetWindowLong(Handle, GWL_EXSTYLE) or WS_EX_TOOLWINDOW);

  TopWindowRects := TList<TWindowRect>.Create;
  ChildWindowRects :=  TDictionary<HWND, TList<TRect>>.Create;
  GetDesktopWindowRect;

  FDrawLayers := TObjectList<TDrawLayer>.Create;

  FScreen := TBitmap32.Create;
  GetScreenshot(FScreen);

  FScreen.DrawTo(Image32.Bitmap, 0, 0);

  ABitmap32 := TBitmap32.Create;
  try
    ABitmap32.SetSize(1, 1);
    ABitmap32.Clear($88000000);
    ABitmap32.DrawMode := dmBlend;
    ABitmap32.DrawTo(Image32.Bitmap, Rect(0, 0, Image32.Bitmap.Width, Image32.Bitmap.Height), Rect(0, 0, ABitmap32.Width, ABitmap32.Height));
  finally
    ABitmap32.Free;
  end;

  FMagnifyingGlassLayer := TBitmapLayer.Create(Image32.Layers);
  FMagnifyingGlassLayer.Visible := False;
  FMagnifyingGlassLayer.Bitmap.MasterAlpha := 255;
  FMagnifyingGlassLayer.Bitmap.DrawMode := dmCustom;
  FMagnifyingGlassLayer.Bitmap.OnPixelCombine := GR32.TPixelCombine.PixelCombine;

  FSelectLayer := TBitmapLayer.Create(Image32.Layers);
  FSelectLayer.Visible := False;
  FSelectLayer.Bitmap.MasterAlpha := 255;
  FSelectLayer.Bitmap.DrawMode := dmOpaque;

  FSelectSizeLayer := TBitmapLayer.Create(Image32.Layers);
  FSelectSizeLayer.Visible := False;
  FSelectSizeLayer.Bitmap.MasterAlpha := 255;
  FSelectSizeLayer.Bitmap.DrawMode := dmCustom;
  FSelectSizeLayer.Bitmap.OnPixelCombine := GR32.TPixelCombine.PixelCombine;

  FSnapWinLayer := TBitmapLayer.Create(Image32.Layers);
  FSnapWinLayer.Visible := False;
  FSnapWinLayer.Bitmap.MasterAlpha := 255;
  FSnapWinLayer.Bitmap.DrawMode := dmOpaque;

  FSelected := False;
end;

procedure TScreenshotForm.FormDestroy(Sender: TObject);
begin
  if ScreenshotForm = Self then ScreenshotForm := nil;
  
  Image32.Cursor := crDefault;
  if FAniLeft <> nil then FAniLeft.Stop(False);
  if FAniTop <> nil then FAniTop.Stop(False);
  if FAniRight <> nil then FAniRight.Stop(False);
  if FAniBottom <> nil then FAniBottom.Stop(False);

  FreeAndNil(FSnapWinLayer);
  FreeAndNil(FScreenshotBitmap);
  FreeAndNil(FSelectSizeLayer);
  FreeAndNil(FSelectLayer);
  FreeAndNil(FMagnifyingGlassLayer);
  FreeAndNil(FScreen);
  ScreenshotForm := nil;
  FreeAndNil(FDrawLayers);
  FreeAndNil(FDrawBitmap);

  ClearRects;
  FreeAndNil(TopWindowRects);
  FreeAndNil(ChildWindowRects);
end;

procedure TScreenshotForm.FormShow(Sender: TObject);
begin
  //ApplicationEvents2.OnDeactivate := ApplicationEvents2Deactivate;
end;

procedure TScreenshotForm.DoScreenshotDone;
begin
  if Assigned(FOnScreenshotDone) then FOnScreenshotDone(Self);

end;

procedure TScreenshotForm.SaveSelectedBitmap(AFile: String);
var
  ABitmap32: TBitmap32;
  ATargetRect: TRect;
begin
  ATargetRect := GetSelectedRect;
  if (ATargetRect.Width > 0) and (ATargetRect.Height > 0) then
  begin
    ABitmap32 := TBitmap32.Create;
    try
      ABitmap32.SetSize(ATargetRect.Width, ATargetRect.Height);
      GetSelectedBitmap(ABitmap32);

      if SameText(ExtractFileExt(AFile), '.png') then      
        GetPngFile(ABitmap32, AFile)
      else if SameText(ExtractFileExt(AFile), '.bmp') then      
        ABitmap32.SaveToFile(AFile)
      else    
        ImageToJpg(ABitmap32, AFile);
    finally
      ABitmap32.Free;
    end;
  end;
  Close;
end;

procedure TScreenshotForm.CopySelectedBitmap;
var
  ATargetRect: TRect;
  AFormat : Word;
  AData: THandle;
  APalette: HPALETTE;
  ABitmap32: TBitmap32;
begin
  if not FSelected then Exit;

  ATargetRect := GetSelectedRect;
  if (ATargetRect.Width > 0) and (ATargetRect.Height > 0) then
  begin
    FScreenshotBitmap := TBitmap.Create;
    ABitmap32 := TBitmap32.Create;
    try
      ABitmap32.SetSize(ATargetRect.Width, ATargetRect.Height);
      GetSelectedBitmap(ABitmap32);
      FScreenshotBitmap.SetSize(ATargetRect.Width, ATargetRect.Height);
      ABitmap32.DrawTo(FScreenshotBitmap.Canvas.Handle, Rect(0, 0, FScreenshotBitmap.Width, FScreenshotBitmap.Height), Rect(0, 0, ABitmap32.Width, ABitmap32.Height));

      AFormat := cf_BitMap;
      FScreenshotBitmap.SaveToClipBoardFormat(AFormat, AData, APalette);
      ClipBoard.SetAsHandle(AFormat, AData);

      DoScreenshotDone;
    finally
      ABitmap32.Free;
      FreeAndNil(FScreenshotBitmap);
    end;
  end;
  Close;
end;

function TScreenshotForm.GetSelectedRect: TRect;
var
  AIntTemp: Integer;
begin
  Result := FSelectedArea;
  if Result.Right < Result.Left then
  begin
    AIntTemp := Result.Left;
    Result.Left := Result.Right;
    Result.Right := AIntTemp;
  end;
  if Result.Bottom < Result.Top then
  begin
    AIntTemp := Result.Top;
    Result.Top := Result.Bottom;
    Result.Bottom := AIntTemp;
  end;
  Result.Right := Result.Right + 1;
  Result.Bottom := Result.Bottom + 1;
end;

procedure TScreenshotForm.SetSnapWinLayer;
var
  ATargetRect: TRect;
  ABitmap32: TBitmap32;
  L: TFloatRect;
begin
  Image32.BeginUpdate;
  try
    if ((not FSnapped) or (FSelecting) or (FSelected)) and
       (FAniLeft = nil) and
       (FAniTop = nil) and
       (FAniRight = nil) and
       (FAniBottom = nil) then
    begin
      FSnapWinLayer.Visible := False;
      Exit;
    end;

    ABitmap32 := FSnapWinLayer.Bitmap;
    ABitmap32.BeginUpdate;
    try
      ATargetRect := FSnappedArea;

      ABitmap32.SetSize(ATargetRect.Width, ATargetRect.Height);
      ABitmap32.Clear($00000000);
      L := FloatRect(ATargetRect);
      FScreen.DrawTo(ABitmap32, 0, 0, ATargetRect);
      ABitmap32.FrameRectS(0, 0, ABitmap32.Width, ABitmap32.Height, LineColor);
      ABitmap32.FrameRectS(1, 1, ABitmap32.Width - 1, ABitmap32.Height - 1, LineColor);
      ABitmap32.FrameRectS(2, 2, ABitmap32.Width - 2, ABitmap32.Height - 2, LineColor);
      ABitmap32.FrameRectS(3, 3, ABitmap32.Width - 3, ABitmap32.Height - 3, LineColor);
    finally;
      ABitmap32.EndUpdate;
    end;
    FSnapWinLayer.Visible := True;
    FSnapWinLayer.Location := L;
    FSnapWinLayer.SendToBack;
  finally
    Image32.EndUpdate;
    if Image32.UpdateCount = 0 then Image32.Invalidate;
  end;
end;

procedure TScreenshotForm.GetSelectedBitmap(ABitmap32: TBitmap32);
var
  ATargetRect: TRect;
  iLoop: Integer;
  ADrawLayer: TDrawLayer;
begin
  ATargetRect := GetSelectedRect;
  ABitmap32.SetSize(ATargetRect.Width, ATargetRect.Height);
  ABitmap32.Clear($00000000);
  FScreen.DrawTo(ABitmap32, 0, 0, ATargetRect);

  while FDrawLayers.Count > 15 do
  begin
    if not Assigned(FDrawBitmap) then
    begin
      FDrawBitmap := TBitmap32.Create;
      FDrawBitmap.SetSize(FSelectLayer.Bitmap.Width, FSelectLayer.Bitmap.Height);
      FDrawBitmap.Clear($00000000);
      FDrawBitmap.DrawMode := dmBlend;
    end;
    ADrawLayer := FDrawLayers[0];
    DrawLayer(ADrawLayer, FDrawBitmap);
    FDrawLayers.Delete(0);
  end;

  if Assigned(FDrawBitmap) then FDrawBitmap.DrawTo(ABitmap32, 0, 0);

  for iLoop := 0 to FDrawLayers.Count - 1 do
  begin
    ADrawLayer := FDrawLayers[iLoop];
    DrawLayer(ADrawLayer, ABitmap32);
  end;
end;

procedure TScreenshotForm.SetSelectLayer;
const
  PointW = 19;
  PointH = 5;
var
  ATargetRect: TRect;
  ABitmap32Temp,
  ABitmap32: TBitmap32;
  ASrcRect: TRect;
  ADstRect: TRect;
  L: TFloatRect;
begin
  ATargetRect := GetSelectedRect;
  Image32.BeginUpdate;
  try
    if (not FSelected) and (not FSelecting) or (ATargetRect.Width = 0) or (ATargetRect.Height = 0) then
    begin
      FSelectLayer.Visible := False;
      FSelectSizeLayer.Visible := False;
      Exit;
    end;
    ABitmap32 := FSelectLayer.Bitmap;
    ABitmap32.BeginUpdate;
    try
      L := FloatRect(ATargetRect);

      GetSelectedBitmap(ABitmap32);
      ABitmap32.FrameRectS(0, 0, ABitmap32.Width, ABitmap32.Height, LineColor);
      
      //画光标托动描点
      ABitmap32Temp := TBitmap32.Create;
      try
        ABitmap32Temp.SetSize(1, 1);
        ABitmap32Temp.Clear(LineColor);
        ABitmap32Temp.DrawMode := dmBlend;
        ABitmap32Temp.MasterAlpha := 255;
        ASrcRect := Rect(0, 0, ABitmap32Temp.Width, ABitmap32Temp.Height);

        //上边
        ADstRect := Rect(ABitmap32.Width div 2 - (PointW div 2), 1, ABitmap32.Width div 2 + (PointW div 2), PointH);
        ABitmap32Temp.DrawTo(ABitmap32, ADstRect, ASrcRect);
        FTopRect := ADstRect;
        FTopRect.Top := 0;
        OffsetRect(FTopRect, ATargetRect.Left, ATargetRect.Top);
        
        //左边
        ADstRect := Rect(1, ABitmap32.Height div 2 - (PointW div 2), PointH, ABitmap32.Height div 2 + (PointW div 2));
        ABitmap32Temp.DrawTo(ABitmap32, ADstRect, ASrcRect);
        FLeftRect := ADstRect;
        FLeftRect.Left := 0;
        OffsetRect(FLeftRect, ATargetRect.Left, ATargetRect.Top);

        //右边
        ADstRect := Rect(ABitmap32.Width - PointH, ABitmap32.Height div 2 - (PointW div 2), ABitmap32.Width - 1, ABitmap32.Height div 2 + (PointW div 2));
        ABitmap32Temp.DrawTo(ABitmap32, ADstRect, ASrcRect);
        FRightRect := ADstRect;
        FRightRect.Right := ABitmap32.Width;
        OffsetRect(FRightRect, ATargetRect.Left, ATargetRect.Top);
        
        //下边
        ADstRect := Rect(ABitmap32.Width div 2 - (PointW div 2), ABitmap32.Height - PointH, ABitmap32.Width div 2 + (PointW div 2), ABitmap32.Height - 1);
        ABitmap32Temp.DrawTo(ABitmap32, ADstRect, ASrcRect);
        FBottomRect := ADstRect;
        FBottomRect.Right := ABitmap32.Height + 1;
        OffsetRect(FBottomRect, ATargetRect.Left, ATargetRect.Top);

        //左上角
        ADstRect := Rect(1, 1, PointW, PointH);
        ABitmap32Temp.DrawTo(ABitmap32, ADstRect, ASrcRect);
        ADstRect := Rect(1, 1, PointH, PointW);
        ABitmap32Temp.DrawTo(ABitmap32, ADstRect, ASrcRect);
        FLeftTopRect := Rect(1, 1, PointW div 2, PointW div 2); 
        OffsetRect(FLeftTopRect, ATargetRect.Left, ATargetRect.Top);
          
        //右上角
        ADstRect := Rect(ABitmap32.Width - PointW, 1, ABitmap32.Width - 1, PointH);
        ABitmap32Temp.DrawTo(ABitmap32, ADstRect, ASrcRect);
        ADstRect := Rect(ABitmap32.Width - PointH, 1, ABitmap32.Width - 1, PointW);
        ABitmap32Temp.DrawTo(ABitmap32, ADstRect, ASrcRect);
        FRightTopRect := Rect(ABitmap32.Width - PointW div 2, 1, ABitmap32.Width, PointW div 2); 
        OffsetRect(FRightTopRect, ATargetRect.Left, ATargetRect.Top);
        
        //左下角
        ADstRect := Rect(1, ABitmap32.Height - PointH, PointW, ABitmap32.Height - 1);
        ABitmap32Temp.DrawTo(ABitmap32, ADstRect, ASrcRect);
        ADstRect := Rect(1, ABitmap32.Height - PointW, PointH, ABitmap32.Height - 1);
        ABitmap32Temp.DrawTo(ABitmap32, ADstRect, ASrcRect);
        FLeftBottomRect := Rect(1, ABitmap32.Height - PointW div 2, PointW div 2, ABitmap32.Height); 
        OffsetRect(FLeftBottomRect, ATargetRect.Left, ATargetRect.Top);

        //右下角
        ADstRect := Rect(ABitmap32.Width - PointW, ABitmap32.Height - PointH, ABitmap32.Width - 1, ABitmap32.Height - 1);
        ABitmap32Temp.DrawTo(ABitmap32, ADstRect, ASrcRect);
        ADstRect := Rect(ABitmap32.Width - PointH, ABitmap32.Height - PointW, ABitmap32.Width - 1, ABitmap32.Height - 1);
        ABitmap32Temp.DrawTo(ABitmap32, ADstRect, ASrcRect);
        FRightBottomRect := Rect(ABitmap32.Width - PointW div 2, ABitmap32.Height - PointW div 2, ABitmap32.Width, ABitmap32.Height); 
        OffsetRect(FRightBottomRect, ATargetRect.Left, ATargetRect.Top);
      finally
        ABitmap32Temp.Free;
      end;
    finally
      ABitmap32.EndUpdate;
    end;
    FSelectLayer.Visible := True;
    FSelectLayer.Location := L;
    FSelectLayer.SendToBack;

    ABitmap32 := FSelectSizeLayer.Bitmap;
    ABitmap32.BeginUpdate;
    try    
      ABitmap32.SetSize(GetDPISize(70), GetDPISize(22));
      ABitmap32.Clear($00000000);
      ABitmap32.Font.Size := 8;
      RestoreFontSize(ABitmap32.Font);
      ABitmap32.Font.Name := 'Tahoma';
      ABitmap32.FillRect(0, 0, ABitmap32.Width, ABitmap32.Height, $88000000);
      ABitmap32.RenderText(GetDPISize(5), GetDPISize(5), Format('%d x %d', [ATargetRect.Width, ATargetRect.Height]), $FFFFFFFF, GetDPIScale > TTFDPIScale);

      L := FSelectLayer.Location;
      OffsetRect(L, GetDPISize(3), -GetDPISize(22) - GetDPISize(3));
      if L.Top < 0 then L.Top := FSelectLayer.Location.Top + 3;
      L.Right := L.Left + ABitmap32.Width;
      L.Bottom := L.Top + ABitmap32.Height;
      FSelectSizeLayer.Visible := True;
      FSelectSizeLayer.Location := L;
    finally;
      ABitmap32.EndUpdate;
    end;
  finally
    Image32.EndUpdate;
    if Image32.UpdateCount = 0 then Image32.Invalidate;
  end;
end;

procedure TScreenshotForm.SetMagnifyingGlas(X, Y: Integer);
const
  TextAreaHeight = 50;
var
  ABitmap32Temp,
  ABitmap32: TBitmap32;
  ASrcRect: TRect;
  ADstRect: TRect;
  L: TFloatRect;
  AColor32: TColor32;
  R,
  G,
  B: Byte;
  W, H: Integer;
begin
  Image32.BeginUpdate;
  try
    if FSelected then
    begin
      FMagnifyingGlassLayer.Visible := False;
      Exit;
    end;
    ABitmap32 := FMagnifyingGlassLayer.Bitmap;
    ABitmap32.BeginUpdate;
    try
      ABitmap32.SetSize(GetDPISize(150), GetDPISize(160));
      ABitmap32.Clear($00000000);
      ASrcRect.Left := X;
      if ASrcRect.Left + ABitmap32.Width > Width then ASrcRect.Left := X - ABitmap32.Width;

      ASrcRect.Top := Y + 30;
      if ASrcRect.Top + ABitmap32.Height > Height then ASrcRect.Top := Y - ABitmap32.Height - 30;

      ASrcRect.Right := ASrcRect.Left + ABitmap32.Width;
      ASrcRect.Bottom := ASrcRect.Top + ABitmap32.Height;
      L := FloatRect(ASrcRect);

      //底图
      FScreen.DrawTo(ABitmap32, 0, 0, ASrcRect);

      //放大图
      ASrcRect.Left := X - ABitmap32.Width div (FMagnifyingGlassTimes * 2);
      ASrcRect.Top := Y - (ABitmap32.Height - GetDPISize(TextAreaHeight)) div (FMagnifyingGlassTimes * 2);
      ASrcRect.Right := ASrcRect.Left + ABitmap32.Width div FMagnifyingGlassTimes;
      ASrcRect.Bottom := ASrcRect.Top + (ABitmap32.Height - GetDPISize(TextAreaHeight)) div FMagnifyingGlassTimes;
      FScreen.DrawTo(ABitmap32, Rect(0, 0, ABitmap32.Width, ABitmap32.Height - GetDPISize(TextAreaHeight)), ASrcRect);

      //十字线
      ABitmap32Temp := TBitmap32.Create;
      try
        ABitmap32Temp.SetSize(1, 1);
        ABitmap32Temp.Clear(LineColor);
        ABitmap32Temp.DrawMode := dmBlend;
        ABitmap32Temp.MasterAlpha := 128;
        ABitmap32Temp.DrawTo(ABitmap32,
          Rect(0, (ABitmap32.Height - GetDPISize(TextAreaHeight)) div 2 - 2, ABitmap32.Width, (ABitmap32.Height - GetDPISize(TextAreaHeight)) div 2 + 2),
          Rect(0, 0, ABitmap32Temp.Width, ABitmap32Temp.Height));
        ABitmap32Temp.DrawTo(ABitmap32,
          Rect(ABitmap32.Width div 2 - 2 + 1, 0, ABitmap32.Width div 2 + 2 + 1, ABitmap32.Height - GetDPISize(TextAreaHeight)),
          Rect(0, 0, ABitmap32Temp.Width, ABitmap32Temp.Height));
      finally
        ABitmap32Temp.Free;
      end;

      {$region '文字'}
      ADstRect := Rect(0, ABitmap32.Height - GetDPISize(TextAreaHeight), ABitmap32.Width, ABitmap32.Height);
      ABitmap32.FillRect(ADstRect.Left, ADstRect.Top, ADstRect.Right, ADstRect.Bottom, $88000000);
      if FSnapped then
      begin
        W := Self.FSnappedArea.Width;
        H := Self.FSnappedArea.Height;
      end
      else if FSelecting then
      begin
        W := Self.FSelectedArea.Width + 1;
        H := Self.FSelectedArea.Height + 1;
      end
      else
      begin 
        W := 0;
        H := 0;
      end;
           
      ABitmap32.Font.Size := 8;
      RestoreFontSize(ABitmap32.Font);
      ABitmap32.Font.Name := 'Tahoma';
      ABitmap32.RenderText(ADstRect.Left + GetDPISize(5), ADstRect.Top + GetDPISize(3), Format('%d, %d (%d x %d)', [X, Y, W, H]), $FFFFFFFF, GetDPIScale > TTFDPIScale);

      AColor32 := FScreen.Pixel[X, Y];
      GR32.Color32ToRGB(AColor32, R, G, B);
      ABitmap32.RenderText(ADstRect.Left + GetDPISize(5), ADstRect.Top + GetDPISize(3 + 15), Format('RGB:(%d, %d, %d)', [R, G, B]), $FFFFFFFF, GetDPIScale > TTFDPIScale);
      ABitmap32.RenderText(ADstRect.Left + GetDPISize(5), ADstRect.Top + GetDPISize(3 + 15 + 15), Format('x%d (滚动鼠标滚轮试试看)', [FMagnifyingGlassTimes]), $FFFFFFFF, GetDPIScale > TTFDPIScale);
      {$endregion}

      ABitmap32.FrameRectS(0, 0, ABitmap32.Width, ABitmap32.Height, $88000000);
      ABitmap32.FrameRectS(1, 1, ABitmap32.Width - 1, ABitmap32.Height - 1, $88FFFFFF);
    finally
      ABitmap32.EndUpdate;
    end;
    FMagnifyingGlassLayer.Visible := True;
    FMagnifyingGlassLayer.Location := L;
    FMagnifyingGlassLayer.BringToFront;
  finally
    Image32.EndUpdate;
    if Image32.UpdateCount = 0 then Image32.Invalidate;
  end;
end;

function EnumWindowsProc(AHandle: HWND; lParam: LPARAM):   Boolean; stdcall;
var
  //buf: array[0..255] of Char;
  //hChild,
  hParent: HWND;
  ADstRect, AParentRect:TRect;
  AWindowRect: TWindowRect;
  AList: TList<TRect>;
  dwExStyle: DWORD;
begin
  Result := true;
  if IsWindow(AHandle) and
     IsWindowVisible(AHandle) and
     (not IsIconic(AHandle)) then
  begin
    GetWindowRect(AHandle, ADstRect);
    if (ADstRect.Width > 0) and
       (ADstRect.Height > 0) and
       (ADstRect.Right > 0) and
       (ADstRect.Bottom > 0) then
    begin
      if lParam > 0 then
      begin
        hParent := GetParent(AHandle);
        while hParent <> 0 do
        begin
          GetWindowRect(hParent, AParentRect);
          if ADstRect.Left < AParentRect.Left then ADstRect.Width := 0;
          if ADstRect.Top < AParentRect.Top then ADstRect.Width := 0;

          hParent := GetParent(hParent);
        end;
      end;

      if (ADstRect.Width > 0) and
         (ADstRect.Height > 0) then
      begin
        AWindowRect.Handle := AHandle;
        AWindowRect.Rect := ADstRect;
        if lParam = 0 then
        begin
          TopWindowRects.Add(AWindowRect);
        end
        else
        begin
          if ChildWindowRects.ContainsKey(lParam) then
            AList := ChildWindowRects[lParam]
          else
          begin
            AList := TList<TRect>.Create;
            ChildWindowRects.Add(lParam, AList);
          end;
          AList.Add(ADstRect);
        end;
      end;
    end;

    //dwExStyle := GetWindowLong(AHandle, GWL_EXSTYLE);
    //if ((dwExStyle and WS_EX_LAYERED) <> WS_EX_LAYERED) then
      if lParam = 0 then EnumChildWindows(AHandle, @EnumWindowsProc, AHandle);
  end;
end;

procedure TScreenshotForm.GetDesktopWindowRect;
begin
  EnumWindows(@EnumWindowsProc, 0);
end;

procedure TScreenshotForm.ClearRects;
var
  AList: TList<TRect>;
begin
  for AList in ChildWindowRects.Values do
  begin
    AList.Free;
  end;
  ChildWindowRects.Clear;
end;

procedure TScreenshotForm.SnapWindow;
var
  iLoop, jLoop: Integer;
  ARect:TRect;
  ASnappedArea,
  ALastSnappedArea: TRect;
  ALastSnapped: Boolean;
  AWindowRect: TWindowRect;
  AList: TList<TRect>;
  AStartValue: Integer;
  APoint: TPoint;
begin
  APoint := Mouse.CursorPos;
  if TopWindowRects.Count = 0 then Exit;
  if Self.FSelecting or Self.FSelected then
  begin
    FSnapped := False;
    if Assigned(FAniLeft) then FAniLeft.Stop;
    if Assigned(FAniTop) then FAniTop.Stop;
    if Assigned(FAniRight) then FAniRight.Stop;
    if Assigned(FAniBottom) then FAniBottom.Stop;
    SetSnapWinLayer;
  end;

  if FSnapped then
    ALastSnappedArea := FSnappedArea
  else
    ALastSnappedArea := Rect(Mouse.CursorPos.X,Mouse.CursorPos.Y,Mouse.CursorPos.X,Mouse.CursorPos.Y);
  ASnappedArea := Rect(Mouse.CursorPos.X,Mouse.CursorPos.Y,Mouse.CursorPos.X,Mouse.CursorPos.Y);
  ALastSnapped := FSnapped;
  FSnapped := False;

  for iLoop :=  0 to TopWindowRects.Count - 1  do
  begin
    AWindowRect := TopWindowRects[iLoop];
    ARect := AWindowRect.Rect;
    if (ARect.Width = Screen.DesktopWidth) and (ARect.Height = Screen.DesktopHeight) then Continue;

    if PtInRect(ARect, APoint) then
    begin
      if ChildWindowRects.ContainsKey(AWindowRect.Handle) then
      begin
        AList := ChildWindowRects[AWindowRect.Handle];
        for jLoop :=   0 to AList.Count - 1 do
        begin
          if PtInRect(AList[jLoop], APoint) then
          begin
            ARect := AList[jLoop];
          end;
        end;
      end;
        
      ASnappedArea := ARect;
      FSnapped := True;
      Break;
    end;
  end;


  if (ASnappedArea.Left = ALastSnappedArea.Left) and
     (ASnappedArea.Top = ALastSnappedArea.Top) and
     (ASnappedArea.Bottom = ALastSnappedArea.Bottom) and
     (ASnappedArea.Right = ALastSnappedArea.Right) then
  begin
    if (FSnapped and FSnapWinLayer.Visible) or
       ((not FSnapped) and (not FSnapWinLayer.Visible)) then Exit;
  end;

  if Assigned(FAniLeft) and (ASnappedArea.Left = FAniLeft.StopValue) and
     Assigned(FAniTop) and (ASnappedArea.Top = FAniTop.StopValue) and
     Assigned(FAniBottom) and (ASnappedArea.Bottom = FAniBottom.StopValue) and
     Assigned(FAniRight) and (ASnappedArea.Right = FAniRight.StopValue) then
  begin
    Exit;
  end;


  if (not FSnapped) and (not ALastSnapped) then
  begin
    Exit;
  end;
  
  
  if FAniLeft = nil then
  begin
    if ALastSnapped then
      AStartValue := FSnappedArea.Left
    else
      AStartValue := Mouse.CursorPos.X;
  end
  else
  begin
    AStartValue := FAniLeft.Value;
    FAniLeft.Stop(False);
  end;
  FAniLeft := TJDUIIntegerAnimation.Create;
  FAniLeft.Duration := 0.15;
  FAniLeft.AnimationType := jduAnimationInOut;
  FAniLeft.Interpolation := jduInterpolationQuadratic;
  FAniLeft.RealTime := False;
  FAniLeft.OnFinish := AniFinish;
  FAniLeft.OnTick := AniTick;
  FAniLeft.StartValue := AStartValue;
  FAniLeft.StopValue := ASnappedArea.Left;

  if FAniTop = nil then
  begin
    if ALastSnapped then
      AStartValue := FSnappedArea.Top
    else
      AStartValue := Mouse.CursorPos.Y;
  end
  else
  begin
    AStartValue := FAniTop.Value;
    FAniTop.Stop(False);
  end;
  FAniTop := TJDUIIntegerAnimation.Create;
  FAniTop.Duration := 0.15;
  FAniTop.AnimationType := jduAnimationInOut;
  FAniTop.Interpolation := jduInterpolationQuadratic;
  FAniTop.RealTime := False;
  FAniTop.OnFinish := AniFinish;
  FAniTop.OnTick := AniTick;
  FAniTop.StartValue := AStartValue;
  FAniTop.StopValue := ASnappedArea.Top;

  if FAniRight = nil then
  begin
    if ALastSnapped then
      AStartValue := FSnappedArea.Right
    else
      AStartValue := Mouse.CursorPos.X;
  end
  else
  begin
    AStartValue := FAniRight.Value;
    FAniRight.Stop(False);
  end;
  FAniRight := TJDUIIntegerAnimation.Create;
  FAniRight.Duration := 0.15;
  FAniRight.AnimationType := jduAnimationInOut;
  FAniRight.Interpolation := jduInterpolationQuadratic;
  FAniRight.RealTime := False;
  FAniRight.OnFinish := AniFinish;
  FAniRight.OnTick := AniTick;
  FAniRight.StartValue := AStartValue;
  FAniRight.StopValue := ASnappedArea.Right;

  if FAniBottom = nil then
  begin
    if ALastSnapped then
      AStartValue := FSnappedArea.Bottom
    else
      AStartValue := Mouse.CursorPos.Y;
  end
  else
  begin
    AStartValue := FAniBottom.Value;
    FAniBottom.Stop(False);
  end;
  FAniBottom := TJDUIIntegerAnimation.Create;
  FAniBottom.Duration := 0.15;
  FAniBottom.AnimationType := jduAnimationInOut;
  FAniBottom.Interpolation := jduInterpolationQuadratic;
  FAniBottom.RealTime := False;
  FAniBottom.OnFinish := AniFinish;
  FAniBottom.OnTick := AniTick;
  FAniBottom.StartValue := AStartValue;
  FAniBottom.StopValue := ASnappedArea.Bottom;

  if Width * Height > 2880 * 1800 then
  begin
    FAniTop.Duration := 0;
    FAniLeft.Duration := 0;
    FAniRight.Duration := 0;
    FAniBottom.Duration := 0;
  end;

  Self.Image32.BeginUpdate;
  try
  FSnappedArea := Rect(FAniLeft.StartValue, FAniTop.StartValue, FAniRight.StartValue, FAniBottom.StartValue);
  FAniTop.Start;
  FAniLeft.Start;
  FAniRight.Start;
  FAniBottom.Start;
  Self.SetSnapWinLayer;
  finally
    Self.Image32.EndUpdate;
    Self.Image32.Changed;
    Self.Image32.Update;
  end;
end;

procedure TScreenshotForm.AniFinish(Sender: TObject);
begin
  if Sender = FAniLeft then FreeAndNil(FAniLeft);
  if Sender = FAniTop then FreeAndNil(FAniTop);
  if Sender = FAniRight then FreeAndNil(FAniRight);
  if Sender = FAniBottom then FreeAndNil(FAniBottom);

  SetSnapWinLayer;
  SetMagnifyingGlas(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TScreenshotForm.AniTick(Sender: TObject);
begin
  if Sender = FAniLeft then FSnappedArea.Left := FAniLeft.Value;
  if Sender = FAniTop then FSnappedArea.Top := FAniTop.Value;
  if Sender = FAniRight then FSnappedArea.Right := FAniRight.Value;
  if Sender = FAniBottom then FSnappedArea.Bottom := FAniBottom.Value;

  SetSnapWinLayer;
end;

procedure TScreenshotForm.EnterDrawMode;
var
  ABitmap32: TBitmap32;
  L: TFloatRect;
begin
  if not FDrawMode then
  begin
    FDrawMode := True;
    Image32.Cursor := crCross;
    FDrawLayers.Clear;
    FreeAndNil(FDrawBitmap);
  end;
end;

procedure TScreenshotForm.LeaveDrawMode;
var
  ABitmap32: TBitmap32;
begin
  FDrawMode := False;
  FDrawLayers.Clear;
  FreeAndNil(FDrawBitmap);
  SetSelectLayer;
  if Assigned(FToolbarForm) then FToolbarForm.SetAction(atNone);
end;

procedure TScreenshotForm.N4Click(Sender: TObject);
begin
  if Assigned(FToolbarForm) then FToolbarForm.SetAction(TActionType((Sender as TMenuItem).Tag));
end;

procedure TScreenshotForm.SetActionArg;
var
  ADrawLayer: TDrawLayer;
begin
  if FDrawLayers.Count = 0 then Exit;
  ADrawLayer := FDrawLayers[FDrawLayers.Count - 1];

  if FDrawActionType = atArrow then
    SetArrowActioArg(ADrawLayer)
  else if FDrawActionType = atRect then
    SetRectActioArg(ADrawLayer)
  else if FDrawActionType = atCircle then
    SetCircleActioArg(ADrawLayer)
  else if FDrawActionType = atPen then
    SetPenActioArg(ADrawLayer);
end;


procedure TScreenshotForm.SetRectActioArg(ADrawLayer: TDrawLayer);
begin
  ADrawLayer.FActionArg.I['x1'] := FDrawStartPoint.X;
  ADrawLayer.FActionArg.I['y1'] := FDrawStartPoint.Y;
  ADrawLayer.FActionArg.I['x2'] := FDrawEndPoint.X;
  ADrawLayer.FActionArg.I['y2'] := FDrawEndPoint.Y;

  SetSelectLayer;
end;

procedure TScreenshotForm.SetCircleActioArg(ADrawLayer: TDrawLayer);
begin
  ADrawLayer.FActionArg.I['x1'] := FDrawStartPoint.X;
  ADrawLayer.FActionArg.I['y1'] := FDrawStartPoint.Y;
  ADrawLayer.FActionArg.I['x2'] := FDrawEndPoint.X;
  ADrawLayer.FActionArg.I['y2'] := FDrawEndPoint.Y;

  SetSelectLayer;
end;

procedure TScreenshotForm.SetPenActioArg(ADrawLayer: TDrawLayer);
var
  jsonPoint: ISuperObject;
begin
  jsonPoint := TSuperObject.Create;
  jsonPoint.I['x'] := FDrawEndPoint.X;
  jsonPoint.I['y'] := FDrawEndPoint.Y;
  ADrawLayer.FActionArgs.Add(jsonPoint);
  jsonPoint := nil;

  SetSelectLayer;
end;

procedure TScreenshotForm.SetArrowActioArg(ADrawLayer: TDrawLayer);
begin
  ADrawLayer.FActionArg.I['x1'] := FDrawStartPoint.X;
  ADrawLayer.FActionArg.I['y1'] := FDrawStartPoint.Y;
  ADrawLayer.FActionArg.I['x2'] := FDrawEndPoint.X;
  ADrawLayer.FActionArg.I['y2'] := FDrawEndPoint.Y;

  SetSelectLayer;
end;

procedure TScreenshotForm.DrawLayer(ADrawLayer: TDrawLayer; ABitmap32: TBitmap32);
begin
  if ADrawLayer.FActionType = atArrow then
    DrawArrow(ADrawLayer, ABitmap32)
  else if ADrawLayer.FActionType = atRect then
    DrawRect(ADrawLayer, ABitmap32)
  else if ADrawLayer.FActionType = atCircle then
    DrawCircle(ADrawLayer, ABitmap32)
  else if ADrawLayer.FActionType = atPen then
    DrawPen(ADrawLayer, ABitmap32);
end;

procedure TScreenshotForm.DrawRect(ADrawLayer: TDrawLayer; ABitmap32: TBitmap32);
var
  iTimes: Integer;
  X1, Y1, X2, Y2, I: Integer;
begin
  ABitmap32.BeginUpdate;
  try
    iTimes := ADrawLayer.GetSize;
    while iTimes > 0 do
    begin
      X1 := ADrawLayer.FActionArg.I['x1'];
      Y1 := ADrawLayer.FActionArg.I['y1'];
      X2 := ADrawLayer.FActionArg.I['x2'];
      Y2 := ADrawLayer.FActionArg.I['y2'];

      if X1 > X2 then
      begin
        I := X1;
        X1 := X2;
        X2 := I;
      end;

      if Y1 > Y2 then
      begin
        I := Y1;
        Y1 := Y2;
        Y2 := I;
      end;

      X1 := X1 + iTimes;
      Y1 := Y1 + iTimes;
      X2 := X2 - iTimes;
      Y2 := Y2 - iTimes;

      if X1 < 0 then X1 := 0;
      if X1 > ABitmap32.Width then X1 := ABitmap32.Width;
      if Y1 < 0 then Y1 := 0;
      if Y1 > ABitmap32.Height then Y1 := ABitmap32.Height;

      if X2 < 0 then X2 := 0;
      if X2 > ABitmap32.Width then X2 := ABitmap32.Width;
      if Y2 < 0 then Y2 := 0;
      if Y2 > ABitmap32.Height then Y2 := ABitmap32.Height;

      ABitmap32.FrameRectS(X1, Y1, X2, Y2, ADrawLayer.GetColor32);
      Dec(iTimes);
    end;
  finally
    ABitmap32.EndUpdate;
  end;
end;

procedure TScreenshotForm.DrawCircle(ADrawLayer: TDrawLayer; ABitmap32: TBitmap32);
var
  X1, Y1, X2, Y2: Integer;
  pts, outerPts, innerPts: TArrayOfFixedPoint;
begin
  ABitmap32.BeginUpdate;
  try
    X1 := ADrawLayer.FActionArg.I['x1'];
    Y1 := ADrawLayer.FActionArg.I['y1'];
    X2 := ADrawLayer.FActionArg.I['x2'];
    Y2 := ADrawLayer.FActionArg.I['y2'];
    with TLine32.Create do
    try
      EndStyle := esClosed;
      pts := GetEllipsePoints(FloatRect(X1, Y1, X2, Y2));
      SetPoints(pts);
      Draw(ABitmap32, ADrawLayer.GetSize, ADrawLayer.GetColor32);
    finally
      Free;
    end;
  finally
    ABitmap32.EndUpdate;
  end;
end;

procedure TScreenshotForm.DrawPen(ADrawLayer: TDrawLayer; ABitmap32: TBitmap32);
var
  jsonPoint: ISuperObject;
  iLoop: Integer;
  X1, Y1, X2, Y2: Integer;
begin
  ABitmap32.BeginUpdate;
  try
    X1 := -99999999;
    Y1 := -99999999;
    X2 := -99999999;
    Y2 := -99999999;


    with TLine32.Create do
    try
      for iLoop := 0 to ADrawLayer.FActionArgs.Length - 1 do
      begin  
        jsonPoint := ADrawLayer.FActionArgs[iLoop];
        X2 := jsonPoint.I['x'];
        Y2 := jsonPoint.I['y'];
        jsonPoint := nil;
        if (X1 = -99999999) and (Y1 = -99999999) then
        begin
          X1 := X2;
          Y1 := Y2;
        end;
        
        ArrowStart.Color := ADrawLayer.GetColor32;
        ArrowStart.Pen.Color := ADrawLayer.GetColor32;
        ArrowStart.Pen.Width := 0;
        ArrowEnd.Color := ADrawLayer.GetColor32;
        ArrowEnd.Pen.Width := ADrawLayer.GetSize;
        ArrowEnd.Pen.Color := ADrawLayer.GetColor32;
        SetPoints([FixedPoint(X1, Y1),
                   FixedPoint(X2, Y2)]);
        Draw(ABitmap32, ADrawLayer.GetSize, ADrawLayer.GetColor32);
        
        X1 := X2;
        Y1 := Y2;
      end;
    finally
      Free;
    end;
  finally;
    ABitmap32.EndUpdate;
  end;
end;

procedure TScreenshotForm.DrawArrow(ADrawLayer: TDrawLayer; ABitmap32: TBitmap32);
var
  X1, Y1, X2, Y2: Integer;
begin
  ABitmap32.BeginUpdate;
  try
    X1 := ADrawLayer.FActionArg.I['x1'];
    Y1 := ADrawLayer.FActionArg.I['y1'];
    X2 := ADrawLayer.FActionArg.I['x2'];
    Y2 := ADrawLayer.FActionArg.I['y2'];
    with TLine32.Create do
    try
      ArrowStart.Color := ADrawLayer.GetColor32;
      ArrowStart.Pen.Color := ADrawLayer.GetColor32;
      ArrowStart.Pen.Width := ADrawLayer.GetSize;
      ArrowEnd.Color := ADrawLayer.GetColor32;
      ArrowEnd.Pen.Width := ADrawLayer.GetSize;
      ArrowEnd.Pen.Color := ADrawLayer.GetColor32;
      ArrowEnd.Style := asFourPoint;
      ArrowEnd.Size := 10 + ADrawLayer.GetSize;
      SetPoints([FixedPoint(X1, Y1),
                 FixedPoint(X2, Y2)]);
      Draw(ABitmap32, ADrawLayer.GetSize, ADrawLayer.GetColor32);
    finally
      Free;
    end;
  finally;
    ABitmap32.EndUpdate;
  end;
end;

procedure TScreenshotForm.DrawBegin(X, Y: Integer);
var
  ADrawLayer: TDrawLayer;
begin
  if X < FSelectLayer.Location.Left then X := Round(FSelectLayer.Location.Left);
  if X > FSelectLayer.Location.Right then X := Round(FSelectLayer.Location.Right);
  if Y < FSelectLayer.Location.Top then Y := Round(FSelectLayer.Location.Top);
  if Y > FSelectLayer.Location.Bottom then Y := Round(FSelectLayer.Location.Bottom);

  FDrawing := True;
  FDrawStartPoint := Point(Round(X - FSelectLayer.Location.Left), Round(Y - FSelectLayer.Location.Top));
  FDrawEndPoint := FDrawStartPoint;

  ADrawLayer := TDrawLayer.Create;
  ADrawLayer.FColor := FToolbarForm.ActiveColor;
  ADrawLayer.FSize := FToolbarForm.ToolSize;
  ADrawLayer.FActionType := FDrawActionType;
  FDrawLayers.Add(ADrawLayer);

  SetActionArg
end;

procedure TScreenshotForm.Drawing(X, Y: Integer);
begin
  if X < FSelectLayer.Location.Left then X := Round(FSelectLayer.Location.Left);
  if X > FSelectLayer.Location.Right then X := Round(FSelectLayer.Location.Right);
  if Y < FSelectLayer.Location.Top then Y := Round(FSelectLayer.Location.Top);
  if Y > FSelectLayer.Location.Bottom then Y := Round(FSelectLayer.Location.Bottom);

  if not FDrawing then Exit;
  FDrawEndPoint := Point(Round(X - FSelectLayer.Location.Left), Round(Y - FSelectLayer.Location.Top));

  SetActionArg
end;

procedure TScreenshotForm.DrawEnd(X, Y: Integer);
begin
  if X < FSelectLayer.Location.Left then X := Round(FSelectLayer.Location.Left);
  if X > FSelectLayer.Location.Right then X := Round(FSelectLayer.Location.Right);
  if Y < FSelectLayer.Location.Top then Y := Round(FSelectLayer.Location.Top);
  if Y > FSelectLayer.Location.Bottom then Y := Round(FSelectLayer.Location.Bottom);

  if not FDrawing then Exit;
  FDrawing := False;
  FDrawEndPoint := Point(Round(X - FSelectLayer.Location.Left), Round(Y - FSelectLayer.Location.Top));
  SetActionArg;
end;

procedure TScreenshotForm.miResetClick(Sender: TObject);
begin
  FDrawLayers.Clear;
  LeaveDrawMode;
  CancelSelected(Mouse.CursorPos.X, Mouse.CursorPos.Y);
end;

procedure TScreenshotForm.ToolbarFormAction(Sender: TObject; ActionType: TActionType);
var
  AFile: String;
begin
  if ActionType = actUndo then
  begin
    if FDrawLayers.Count > 0 then
    begin
      FDrawLayers.Delete(FDrawLayers.Count - 1);
      SetSelectLayer;
    end
    else if (FDrawLayers.Count = 0) and FDrawMode then
    begin
      LeaveDrawMode;
    end
    else if not FDrawMode then
      CancelSelected(Mouse.CursorPos.X, Mouse.CursorPos.Y);
    Exit;
  end;

  if ActionType = actSave then
  begin
    SaveDialog.FileName := Format('%s截图%d4%d2%d2%d2%d2%d2%d6', [Application.Title, DateUtils.YearOf(Now), DateUtils.MonthOf(Now), DateUtils.DayOf(Now),DateUtils.HourOf(Now),DateUtils.MinuteOf(Now),DateUtils.SecondOf(Now),DateUtils.MilliSecondOf(Now)]);
    if SaveDialog.Execute(Handle) then
    begin
      AFile := SaveDialog.FileName;      
      if not CheckFileHasAccess(AFile) then
      begin
        raise Exception.Create('选择的目录不具备写入权限，请重新选择！');
        Exit;
      end;
      SaveSelectedBitmap(AFile);
    end;
    Exit;
  end;
  if ActionType = actOK then
  begin
    CopySelectedBitmap;
    Exit;
  end;

  if ActionType = actQuit then
  begin
    Close;
    Exit;
  end;

  FDrawActionType := ActionType;
  FDrawing := False;
  EnterDrawMode;
end;

procedure TScreenshotForm.ToolbarFormDestroy(Sender: TObject);
begin
  FToolbarForm := nil;
end;

procedure TScreenshotForm.ToolbarFormResize(Sender: TObject);
begin
  Self.ShowToolbar;
end;

procedure TScreenshotForm.ToolbarFormActionColorChanged(Sender: TObject);
begin
end;

procedure TScreenshotForm.ToolbarFormToolSizeChanged(Sender: TObject);
begin
end;

procedure TScreenshotForm.ShowToolbar;
var
  ARect: TRect;
  ALeft,
  ATop: Integer;
begin
  if not Assigned(FToolbarForm) then
    FToolbarForm := TScreenshotToolForm.Create(Self);

  ARect := GetSelectedRect;
  ALeft := ARect.Right - FToolbarForm.Width;
  ATop := ARect.Bottom;
  if ALeft < 0 then ALeft := 0;
  if ATop > Height - FToolbarForm.Height then ATop := ARect.Top - FToolbarForm.Height;
  if ATop < 0 then ATop := 0;
  FToolbarForm.SetBounds(ALeft, ATop, FToolbarForm.Width, FToolbarForm.Height);
  FToolbarForm.OnScreenshotToolAction := ToolbarFormAction;
  FToolbarForm.OnDestroy := ToolbarFormDestroy;
  FToolbarForm.OnResize := ToolbarFormResize;
  FToolbarForm.OnActionColorChanged := ToolbarFormActionColorChanged;
  FToolbarForm.OnToolSizeChanged := ToolbarFormToolSizeChanged;
  FToolbarForm.Show;
end;

procedure TScreenshotForm.HideToolbar;
begin
  FreeAndNil(FToolbarForm);
end;

procedure TScreenshotForm.Image32DblClick(Sender: TObject);
begin
  if FSelected then
  begin
    CopySelectedBitmap;
  end;
end;

procedure TScreenshotForm.CancelSelected(X, Y: Integer);
begin
  Image32.Cursor := crDefault;
  FSelected := False;
  FSnappedArea := FSelectedArea;
  FSelectedArea := Rect(0, 0, 0, 0);
  FSnapped := True;
  HideToolbar;
  Image32.BeginUpdate;
  try
    SnapWindow;
    SetSelectLayer;
    SetMagnifyingGlas(X, Y);
  finally
    Image32.EndUpdate;
    Image32.Invalidate;
  end;
end;

procedure TScreenshotForm.Image32MouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  ARect: TRect;
begin
  FMouseDown := False;
  if FDrawMode and (Button = mbLeft) then
  begin
    ARect := GetSelectedRect;
    if (Button = mbLeft) and (FDrawing) and PtInRect(ARect, Point(X, Y)) then
    begin
      DrawEnd(X, Y);
    end;
    Exit;
  end;

  FDragingType := dgtNone;
  if Button = mbRight then
  begin
    if FSelected then
    begin
      ARect := GetSelectedRect;
      if PtInRect(ARect, Point(X, Y)) then
      begin
        jpmMenus.Popup(X, Y, Self);
      end
      else
        CancelSelected(X, Y);
    end
    else
    begin
      Close;
    end;
    Exit;
  end;

  if FSelecting then
  begin
    FSelecting := False;
    if Assigned(FAniLeft) then FAniLeft.Stop;
    if Assigned(FAniTop) then FAniTop.Stop;
    if Assigned(FAniRight) then FAniRight.Stop;
    if Assigned(FAniBottom) then FAniBottom.Stop;
    if FSnapped then
    begin
      FSelectedArea := FSnappedArea;
      FSelectedArea.Right := FSelectedArea.Right - 1;
      FSelectedArea.Bottom := FSelectedArea.Bottom - 1;
    end;
    FSelected := (GetSelectedRect.Width > 0) and (GetSelectedRect.Height > 0);

    Image32.BeginUpdate;
    try
      SetSnapWinLayer;
      SetSelectLayer;
      SetMagnifyingGlas(X, Y);
    finally
      Image32.EndUpdate;
      Image32.Invalidate;
    end;

    if FSelected then    
      ShowToolbar
    else
      HideToolbar;
  end;
end;

procedure TScreenshotForm.Image32MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer;
  Layer: TCustomLayer);
var
  ARect: TRect;
begin
  FMouseDown := True;
  if FDrawMode  then
  begin
    ARect := GetSelectedRect;
    if (Button = mbLeft) and PtInRect(ARect, Point(X, Y)) then
    begin
      DrawBegin(X, Y);
    end;
    Exit;
  end;

  FDragingType := dgtNone;
  FSelectPoint := Point(X, Y);
  if Button = mbRight then
  begin
    Exit;
  end
  else
  begin
    ARect := Self.GetSelectedRect;
    if FSelected and (PtInRect(ARect, Point(X, Y))) then
    begin
      if PtInRect(FLeftTopRect, Point(X, Y)) then
        FDragingType := dgtLeftTop
      else if PtInRect(FRightBottomRect, Point(X, Y)) then   
        FDragingType := dgtRightBottom
      else if PtInRect(FRightTopRect, Point(X, Y)) then
        FDragingType := dgtRightTop
      else if  PtInRect(FLeftBottomRect, Point(X, Y)) then   
        FDragingType := dgtLeftBottom
      else if PtInRect(FLeftRect, Point(X, Y)) then
        FDragingType := dgtLeft
      else if PtInRect(FRightRect, Point(X, Y)) then   
        FDragingType := dgtRight
      else if PtInRect(FTopRect, Point(X, Y)) then
        FDragingType := dgtTop
      else if  PtInRect(FBottomRect, Point(X, Y)) then       
        FDragingType := dgtBottom
      else if Image32.Cursor = crHandPoint then
        FDragingType := dgtMove;
      Exit;
    end
    else
    begin 
      if FSnapped and (not FSelected) then
      begin 
        if Assigned(FAniLeft) then FAniLeft.Stop;
        if Assigned(FAniTop) then FAniTop.Stop;
        if Assigned(FAniRight) then FAniRight.Stop;
        if Assigned(FAniBottom) then FAniBottom.Stop;
      end
      else
      begin
        FSelectedArea.Left := X;
        FSelectedArea.Top := Y;
        FSelectedArea.Right := FSelectedArea.Left;
        FSelectedArea.Bottom := FSelectedArea.Top;
        if FSelected then FSnapped := False;
      end;
    end;
    FSelecting := True;
    FSelected := False;
    HideToolbar;
  end;
  
  Image32.BeginUpdate;
  try
    SetSelectLayer;
    SetMagnifyingGlas(X, Y);
  finally
    Image32.EndUpdate;
    Image32.Invalidate;
  end;
end;

procedure TScreenshotForm.Image32MouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer; Layer: TCustomLayer);
begin
  if FDrawMode then
  begin
    if FDrawing then
      Drawing(X, Y);
    Exit;
  end;

  if FSelected then
  begin
    if not FMouseDown then
    begin
      if PtInRect(FLeftTopRect, Point(X, Y)) or PtInRect(FRightBottomRect, Point(X, Y)) then    
        Image32.Cursor := crSizeNWSE
      else if PtInRect(FRightTopRect, Point(X, Y)) or PtInRect(FLeftBottomRect, Point(X, Y)) then    
        Image32.Cursor := crSizeNESW
      else if PtInRect(FLeftRect, Point(X, Y)) or PtInRect(FRightRect, Point(X, Y)) then    
        Image32.Cursor := crSizeWE
      else if PtInRect(FTopRect, Point(X, Y)) or PtInRect(FBottomRect, Point(X, Y)) then    
        Image32.Cursor := crSizeNS      
      else if PtInRect(FSelectLayer.Location, Point(X, Y)) then    
        Image32.Cursor := crHandPoint
      else
        Image32.Cursor := crDefault;
    end;
  end
  else
  begin
    Image32.Cursor := crDefault;
    if (not FSelecting) then SnapWindow;
  end;
  
  Image32.BeginUpdate;
  try
    if FSelected  then
    begin
      if (FMouseDown) then
      begin
        if FDragingType = dgtLeftTop then
        begin
          FSelectedArea.Left := FSelectedArea.Left + (X - FSelectPoint.X);  
          FSelectedArea.Top := FSelectedArea.Top + (Y - FSelectPoint.Y);  
        end
        else if FDragingType = dgtRightBottom then   
        begin 
          FSelectedArea.Right := FSelectedArea.Right + (X - FSelectPoint.X);  
          FSelectedArea.Bottom := FSelectedArea.Bottom + (Y - FSelectPoint.Y);  
        end
        else if FDragingType = dgtRightTop then
        begin
          FSelectedArea.Right := FSelectedArea.Right + (X - FSelectPoint.X);  
          FSelectedArea.Top := FSelectedArea.Top + (Y - FSelectPoint.Y);  
        end
        else if  FDragingType = dgtLeftBottom then   
        begin 
          FSelectedArea.Left := FSelectedArea.Left + (X - FSelectPoint.X);  
          FSelectedArea.Bottom := FSelectedArea.Bottom + (Y - FSelectPoint.Y);  
        end
        else if FDragingType = dgtLeft then
        begin
          FSelectedArea.Left := FSelectedArea.Left + (X - FSelectPoint.X);  
        end
        else if FDragingType = dgtRight then   
        begin 
          FSelectedArea.Right := FSelectedArea.Right + (X - FSelectPoint.X);  
        end
        else if FDragingType = dgtTop then
        begin
          FSelectedArea.Top := FSelectedArea.Top + (Y - FSelectPoint.Y);  
        end
        else if FDragingType = dgtBottom then       
        begin
          FSelectedArea.Bottom := FSelectedArea.Bottom + (Y - FSelectPoint.Y);  
        end
        else if FDragingType = dgtMove then
        begin
          OffsetRect(FSelectedArea, X - FSelectPoint.X, Y - FSelectPoint.Y); 
          if FSelectedArea.Left < 0 then 
          begin
            X := X + (0 - FSelectedArea.Left);
            OffsetRect(FSelectedArea, 0 - FSelectedArea.Left, 0);
          end;
          if FSelectedArea.Right > Width then 
          begin
            X := X + (Width - FSelectedArea.Right);
            OffsetRect(FSelectedArea, Width - FSelectedArea.Right, 0);
          end;
        
          if FSelectedArea.Top < 0 then 
          begin
            Y := Y + (0 - FSelectedArea.Top);
            OffsetRect(FSelectedArea, 0, 0 - FSelectedArea.Top);
          end;
          if FSelectedArea.Bottom > Height then
          begin
            Y := Y + (Height - FSelectedArea.Bottom);
            OffsetRect(FSelectedArea, 0, Height - FSelectedArea.Bottom);
          end;
        end;

        if FDragingType <> dgtNone then
        begin
          FSelectPoint := Point(X, Y);
          SetSelectLayer;
          ShowToolbar;
        end;
      end;
    end
    else if FSelecting then
    begin
      if FSnapped and ((Abs(FSelectPoint.X - X) >= 5) or (Abs(FSelectPoint.Y - Y) >= 5)) then
      begin
        FSelectedArea.Left := FSelectPoint.X;
        FSelectedArea.Top := FSelectPoint.Y;
        FSelectedArea.Right := X;
        FSelectedArea.Bottom := Y;
        FSnapped := False;
        SetSnapWinLayer;
        //FSelectPoint := Point(X, Y);
        SetSelectLayer;
      end
      else if not FSnapped then           
      begin
        FSelectedArea.Right := X;
        FSelectedArea.Bottom := Y;
        //FSelectedArea.Right := FSelectedArea.Right + (X - FSelectPoint.X);
        //FSelectedArea.Bottom := FSelectedArea.Bottom + (Y - FSelectPoint.Y);
        //FSelectPoint := Point(X, Y);
        SetSelectLayer;
      end;
    end;
    SetMagnifyingGlas(X, Y);
  finally
    Image32.EndUpdate;
    Image32.Invalidate;
  end;
end;

end.
