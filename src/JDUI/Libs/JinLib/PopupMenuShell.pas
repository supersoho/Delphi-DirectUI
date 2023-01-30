unit PopupMenuShell;

interface

uses
  Windows, Generics.Collections, Messages, SysUtils, StrUtils, ComObj, Dialogs,
  ShlObj, ActiveX, SuperObject;

function DisplayContextMenu(const Handle: THandle; const FileName: string;
  Pos: TPoint;
  AEnableDeleteMenu: Boolean = True;
  AAppendMenu: TSuperArray = nil): Cardinal;

function DisplayContextMenuByPItemIDList(const Handle: THandle;
  pidl: PItemIDList; Pos: TPoint;
  AEnableDeleteMenu: Boolean = False;
  AAppendMenu: TSuperArray = nil): Cardinal;

function DisplayComputerContextMenuByPItemIDList(const Handle: THandle;
  pidl: PItemIDList; Pos: TPoint;
  AEnableDeleteMenu: Boolean = False;
  AAppendMenu: TSuperArray = nil): Cardinal;

procedure ShowProperties(Handle: HWND; ItemList: PItemIDList); overload;
procedure ShowProperties(Handle: HWND; const DisplayName: string); overload;

implementation

type
  TUnicodePath = array [0 .. MAX_PATH - 1] of WideChar;

const
  ShenPathSeparator = '\';

Function String2PWideChar(const s: String): PWideChar;
begin
  if s = '' then
  begin
    result := nil;
    exit;
  end;
  result := AllocMem((Length(s) + 1) * sizeOf(WideChar));
  StringToWidechar(s, result, Length(s) * sizeOf(WideChar) + 1);
end;

function PidlFree(var IdList: PItemIDList): Boolean;
var
  Malloc: IMalloc;
begin
  result := False;
  if IdList = nil then
    result := True
  else
  begin
    if Succeeded(SHGetMalloc(Malloc)) and (Malloc.DidAlloc(IdList) > 0) then
    begin
      Malloc.Free(IdList);
      IdList := nil;
      result := True;
    end;
  end;
end;

function MenuCallback(Wnd: HWND; Msg: UINT; wParam: wParam; lParam: lParam)
  : LRESULT; stdcall;
var
  ContextMenu2: IContextMenu2;
begin
  case Msg of
    WM_CREATE:
      begin
        ContextMenu2 := IContextMenu2(PCreateStruct(lParam).lpCreateParams);
        SetWindowLong(Wnd, GWL_USERDATA, Longint(ContextMenu2));
        result := DefWindowProc(Wnd, Msg, wParam, lParam);
      end;
    WM_INITMENUPOPUP:
      begin
        ContextMenu2 := IContextMenu2(GetWindowLong(Wnd, GWL_USERDATA));
        ContextMenu2.HandleMenuMsg(Msg, wParam, lParam);
        result := 0;
      end;
    WM_DRAWITEM, WM_MEASUREITEM:
      begin
        ContextMenu2 := IContextMenu2(GetWindowLong(Wnd, GWL_USERDATA));
        ContextMenu2.HandleMenuMsg(Msg, wParam, lParam);
        result := 1;
      end;
  else
    result := DefWindowProc(Wnd, Msg, wParam, lParam);
  end;
end;

function CreateMenuCallbackWnd(const ContextMenu: IContextMenu2): HWND;
const
  IcmCallbackWnd = 'ICMCALLBACKWND';
var
  WndClass: TWndClass;
begin
  FillChar(WndClass, sizeOf(WndClass), #0);
  WndClass.lpszClassName := PChar(IcmCallbackWnd);
  WndClass.lpfnWndProc := @MenuCallback;
  WndClass.hInstance := hInstance;
  Windows.RegisterClass(WndClass);
  result := CreateWindow(IcmCallbackWnd, IcmCallbackWnd, WS_POPUPWINDOW, 0, 0,
    0, 0, 0, 0, hInstance, Pointer(ContextMenu));
end;

function DisplayContextMenuPidl(const Handle: HWND; const Folder: IShellFolder;
  Item: PItemIDList; Pos: TPoint;
  AEnableDeleteMenu: Boolean = True;
  AAppendMenu: TSuperArray = nil): Cardinal;
var
  Cmd: Cardinal;
  ContextMenu: IContextMenu;
  ContextMenu2: IContextMenu2;
  Menu: HMENU;
  MenuSub: HMENU;
  CommandInfo: TCMInvokeCommandInfo;
  CallbackWindow: HWND;
  JsonOneMenu: ISuperObject;
  JsonSubMenu: ISuperObject;
  iLoop,
  jLoop: Integer;
  SubArray: TSuperArray;
  strJson: String;

  pic1: HBITMAP;
  ALastLine: Boolean;
  ACustomID: Generics.Collections.TList<Cardinal>;
begin
  result := 0;
  if (Item = nil) or (Folder = nil) then
    exit;
  Folder.GetUIObjectOf(Handle, 1, Item, IID_IContextMenu, nil,
    Pointer(ContextMenu));

  MenuSub := 0;
  if ContextMenu <> nil then
  begin
    Menu := CreatePopupMenu;
    if Menu <> 0 then
    begin
      if Succeeded(ContextMenu.QueryContextMenu(Menu, 0, 1, $7FFF,
        CMF_EXPLORE)) then
      begin
        CallbackWindow := 0;

        if Succeeded(ContextMenu.QueryInterface(IContextMenu2,
          ContextMenu2)) then
          CallbackWindow := CreateMenuCallbackWnd(ContextMenu2);

        if not AEnableDeleteMenu then
          DeleteMenu(Menu, 18, MF_BYCOMMAND);

        DeleteMenu(Menu, 17, MF_BYCOMMAND); //创建快捷方式功能

        ACustomID := Generics.Collections.TList<Cardinal>.Create;
        if AAppendMenu <> nil then
        begin
          //for iLoop := AAppendMenu.Length - 1 downto 0 do
          for iLoop := 0 to AAppendMenu.Length - 1 do
          begin
            JsonOneMenu := AAppendMenu[iLoop];
            if JsonOneMenu['type'].AsString = 'MF_SEPARATOR' then
              AppendMenu(Menu, MF_SEPARATOR, 0, '')
            else if JsonOneMenu['type'].AsString = 'MF_POPUP' then
            begin
              MenuSub := CreatePopupMenu;
              try
                strJson := JsonOneMenu.AsJSon();
                strJson := ReplaceStr(strJson, '"[', '[');
                strJson := ReplaceStr(strJson, ']"', ']');
                strJson := ReplaceStr(strJson, '\"', '');
                JsonSubMenu := SO(strJson);
                SubArray := JsonSubMenu['menus'].AsArray;
                for jLoop := 0 to SubArray.Length - 1 do
                begin
                  strJson := SubArray[jLoop].AsJSon();
                  ACustomID.Add(SubArray[jLoop]['id'].AsInteger);
                  AppendMenu(MenuSub, MFT_STRING, SubArray[jLoop]['id'].AsInteger, PChar(SubArray[jLoop]['caption'].AsString));
                end;
                //InsertMenu(Menu, 0, MF_POPUP, MenuSub, PChar(JsonOneMenu['caption'].AsString));
                AppendMenu(Menu, MF_POPUP, MenuSub, PChar(JsonOneMenu['caption'].AsString));
              except
              end;
            end
            else
            begin
              ACustomID.Add(JsonOneMenu['id'].AsInteger);
              AppendMenu(Menu, MFT_STRING, JsonOneMenu['id'].AsInteger, PChar(JsonOneMenu['caption'].AsString));
            end;

            //pic1 := LoadImage(HInstance, MakeIntResource(0), IMAGE_BITMAP, 0, 0, LR_LOADMAP3DCOLORS);
            //SetMenuItemBitmaps(Menu, JsonOneMenu['id'].AsInteger, MF_BYCOMMAND ,pic1, pic1);
          end;
          {
          MenuSub := CreatePopupMenu;
          AppendMenu(MenuSub, MFT_STRING, 2001, 'aaa');
          AppendMenu(MenuSub, MFT_STRING, 2002, 'bbb');
          AppendMenu(MenuSub, MFT_STRING, 2003, 'ccc');

          AppendMenu(Menu, MF_POPUP, MenuSub, '11111');
          }

          //删除过多的重复的分隔线SEPARATOR
          ALastLine := True;
          for iLoop := GetMenuItemCount(Menu) - 1 downto 0 do
          begin
            if GetMenuState(Menu, iLoop, MF_BYPOSITION) and MF_SEPARATOR = MF_SEPARATOR then
            begin
              if ALastLine then
                DeleteMenu(Menu, iLoop, MF_BYPOSITION);
              ALastLine := True;
            end
            else
            begin
              ALastLine := False;
            end;
          end;
            
          //AppendMenu(Menu, MF_SEPARATOR, 0, '');
          //AppendMenu(Menu, MFT_STRING, 1000, '重命名(&M)');
        end;

        ClientToScreen(Handle, Pos);
        Cmd := Cardinal(TrackPopupMenu(Menu, TPM_LEFTALIGN or TPM_LEFTBUTTON or
          TPM_RIGHTBUTTON or TPM_RETURNCMD, Pos.X, Pos.Y, 0,
          CallbackWindow, nil));


        result := Cmd;
        if (Cmd <> 0) and (not ACustomID.Contains(Cmd)) then
        begin
          FillChar(CommandInfo, sizeOf(CommandInfo), #0);
          CommandInfo.cbSize := sizeOf(TCMInvokeCommandInfo);
          CommandInfo.HWND := Handle;
          CommandInfo.lpVerb := MakeIntResourceA(Cmd - 1);
          CommandInfo.nShow := SW_SHOWNORMAL;
          //result :=
          Succeeded(ContextMenu.InvokeCommand(CommandInfo));
        end;

        ACustomID.Free;

        if CallbackWindow <> 0 then
          DestroyWindow(CallbackWindow);
      end;

      DestroyMenu(Menu);
      if MenuSub <> 0 then DestroyMenu(MenuSub);
    end;
  end;
end;

function PathAddSeparator(const Path: string): string;
begin
  result := Path;
  if (Length(Path) = 0) or (AnsiLastChar(Path) <> ShenPathSeparator) then
    result := Path + ShenPathSeparator;
end;

function DriveToPidlBind(const DriveName: string; out Folder: IShellFolder)
  : PItemIDList;
var
  Attr: ULONG;
  Eaten: ULONG;
  DesktopFolder: IShellFolder;
  Drives: PItemIDList;
begin
  result := nil;
  if Succeeded(SHGetDesktopFolder(DesktopFolder)) then
  begin
    if Succeeded(SHGetSpecialFolderLocation(0, CSIDL_DRIVES, Drives)) then
    begin
      if Succeeded(DesktopFolder.BindToObject(Drives, nil, IID_IShellFolder,
        Pointer(Folder))) then
      begin
        if Failed(Folder.ParseDisplayName(0, nil, PWideChar(DriveName), Eaten,
          result, Attr)) then
          Folder := nil;
      end;
    end;
    PidlFree(Drives);
  end;
end;

function PathToPidlBind(const FileName: string; out Folder: IShellFolder)
  : PItemIDList;
var
  Attr, Eaten: ULONG;
  PathIdList: PItemIDList;
  DesktopFolder: IShellFolder;
  Path, ItemName: PWideChar;
  s1, s2: string;
begin
  result := nil;

  s1 := ExtractFilePath(FileName);
  s2 := ExtractFileName(FileName);
  Path := String2PWideChar(s1);
  ItemName := String2PWideChar(s2);

  if Succeeded(SHGetDesktopFolder(DesktopFolder)) then
  begin
    if Succeeded(DesktopFolder.ParseDisplayName(0, nil, Path, Eaten, PathIdList,
      Attr)) then
    begin
      if Succeeded(DesktopFolder.BindToObject(PathIdList, nil, IID_IShellFolder,
        Pointer(Folder))) then
      begin
        if Failed(Folder.ParseDisplayName(0, nil, ItemName, Eaten, result, Attr)) then
        begin
          Folder := nil;
          result := DriveToPidlBind(FileName, Folder);
        end;
      end;
      PidlFree(PathIdList);
    end
    else
      result := DriveToPidlBind(FileName, Folder);
  end;

  FreeMem(Path);
  FreeMem(ItemName);
end;

function DisplayContextMenu(const Handle: THandle; const FileName: string;
  Pos: TPoint;
  AEnableDeleteMenu: Boolean = True;
  AAppendMenu: TSuperArray = nil): Cardinal;
var
  ItemIdList: PItemIDList;
  Folder: IShellFolder;
begin
  result := 0;
  ItemIdList := PathToPidlBind(FileName, Folder);

  if ItemIdList <> nil then
  begin
    result := DisplayContextMenuPidl(Handle, Folder, ItemIdList, Pos, AEnableDeleteMenu, AAppendMenu);
    PidlFree(ItemIdList);
  end;
end;

function DisplayContextMenuByPItemIDList(const Handle: THandle;
  pidl: PItemIDList; Pos: TPoint;
  AEnableDeleteMenu: Boolean = False;
  AAppendMenu: TSuperArray = nil): Cardinal;
var
  Desktop: IShellFolder;
  Folder: IShellFolder;
begin
  result := 0;
  if pidl <> nil then
  begin
    OleCheck(SHGetDesktopFolder(Desktop));
    OleCheck(Desktop.BindToObject(pidl, nil, IID_IShellFolder, Folder));
    result := DisplayContextMenuPidl(Handle, Desktop, pidl, Pos, AEnableDeleteMenu, AAppendMenu);
    PidlFree(pidl);
  end;
end;

function DisplayComputerContextMenuByPItemIDList(const Handle: THandle;
  pidl: PItemIDList; Pos: TPoint;
  AEnableDeleteMenu: Boolean = False;
  AAppendMenu: TSuperArray = nil): Cardinal;
var
  Desktop: IShellFolder;
  Folder: IShellFolder;
begin
  result := 0;
  if pidl <> nil then
  begin
    SHGetDesktopFolder(Desktop);
    SHGetSpecialFolderLocation(0, CSIDL_DRIVES, pidl);
    Desktop.BindToObject(pidl, nil, IID_IShellFolder, Pointer(Folder));
    result := DisplayContextMenuPidl(Handle, Desktop, pidl, Pos, AEnableDeleteMenu, AAppendMenu);
    PidlFree(pidl);
  end;
end;

procedure ShowProperties(Handle: HWND; ItemList: PItemIDList); overload;
var
  Desktop: IShellFolder;
  Folder: IShellFolder;
  ParentList: PItemIDList;
  RelativeList: PItemIDList;
  ContextMenu: IContextMenu;
  CommandInfo: TCMInvokeCommandInfo;
Begin
  ParentList := ILClone(ItemList);
  if ParentList <> nil then
    try
      ILRemoveLastID(ParentList);
      OleCheck(SHGetDesktopFolder(Desktop));
      OleCheck(Desktop.BindToObject(ParentList, nil, IID_IShellFolder, Folder));
      RelativeList := ILFindChild(ParentList, ItemList);
      OleCheck(Folder.GetUIObjectOf(Handle, 1, RelativeList, IID_IContextMenu,
        nil, ContextMenu));
      FillChar(CommandInfo, sizeOf(TCMInvokeCommandInfo), #0);
      with CommandInfo do
      begin
        cbSize := sizeOf(TCMInvokeCommandInfo);
        HWND := Handle;
        lpVerb := 'Properties';
        nShow := SW_SHOW;
      end;
      OleCheck(ContextMenu.InvokeCommand(CommandInfo));
    Finally
      ILFree(ParentList);
    end;
end;

procedure ShowProperties(Handle: HWND; const DisplayName: string); overload;
var
  ItemList: PItemIDList;
Begin
  ItemList := ILCreateFromPath(PChar(DisplayName));
  Try
    ShowProperties(Handle, ItemList)
  Finally
    ILFree(ItemList);
  end;
end;

end.
