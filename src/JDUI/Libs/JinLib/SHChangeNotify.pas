unit SHChangeNotify;

interface

uses
  Windows ,Messages ,SysUtils, Classes ,Graphics ,Controls, Forms, Dialogs ,StdCtrls ,shlobj ,Activex;

const
  SHCNE_RENAMEITEM = $1;
  SHCNE_CREATE = $2;
  SHCNE_DELETE = $4;
  SHCNE_MKDIR = $8;
  SHCNE_RMDIR = $10;
  SHCNE_MEDIAINSERTED = $20;
  SHCNE_MEDIAREMOVED = $40;
  SHCNE_DRIVEREMOVED = $80;
  SHCNE_DRIVEADD = $100;
  SHCNE_NETSHARE = $200;
  SHCNE_NETUNSHARE = $400;
  SHCNE_ATTRIBUTES = $800;
  SHCNE_UPDATEDIR = $1000;
  SHCNE_UPDATEITEM = $2000;
  SHCNE_SERVERDISCONNECT = $4000;
  SHCNE_UPDATEIMAGE = $8000;
  SHCNE_DRIVEADDGUI = $10000;
  SHCNE_RENAMEFOLDER = $20000;
  SHCNE_FREESPACE = $40000;
  SHCNE_ASSOCCHANGED = $8000000;
  SHCNE_DISKEVENTS = $2381F;
  SHCNE_GLOBALEVENTS = $C0581E0;
  SHCNE_ALLEVENTS = $7FFFFFFF;
  SHCNE_INTERRUPT = $80000000;
  SHCNF_IDLIST = 0; // LPITEMIDLIST
  SHCNF_PATHA = $1; // path name
  SHCNF_PRINTERA = $2; // printer friendly name
  SHCNF_DWORD = $3; // DWORD
  SHCNF_PATHW = $5; // path name
  SHCNF_PRINTERW = $6; // printer friendly name
  SHCNF_TYPE = $FF;
  SHCNF_FLUSH = $1000;
  SHCNF_FLUSHNOWAIT = $2000;
  SHCNF_PATH = SHCNF_PATHW;
  SHCNF_PRINTER = SHCNF_PRINTERW;
  WM_SHNOTIFY = $401;
  NOERROR = 0;

type
  PSHNOTIFYSTRUCT=^SHNOTIFYSTRUCT;

  SHNOTIFYSTRUCT = record
    dwItem1 : PItemIDList;
    dwItem2 : PItemIDList;
  end;

  PSHFileInfoByte = ^SHFileInfoByte;
  _SHFileInfoByte = record
    hIcon :Integer;
    iIcon :Integer;
    dwAttributes : Integer;
    szDisplayName : array [0..259] of char;
    szTypeName : array [0..79] of char;
  end;

  SHFileInfoByte=_SHFileInfoByte;

  PIDLSTRUCT = ^IDLSTRUCT;
  _IDLSTRUCT = record
    pidl : PItemIDList;
    bWatchSubFolders : Integer;
  end;

  IDLSTRUCT =_IDLSTRUCT;

  function SHNotify_Register(hWnd : Integer) : Bool;

  function SHNotify_UnRegister:Bool;

  function SHEventName(strPath1,strPath2:string;lParam:Integer):string;

  Function SHChangeNotifyDeregister(hNotify:integer):integer;stdcall; external 'Shell32.dll' index 4;

  Function SHChangeNotifyRegister(hWnd,uFlags,dwEventID,uMSG,cItems:LongWord; lpps:PIDLSTRUCT):integer;stdcall;external 'Shell32.dll' index 2;

  Function SHGetFileInfoPidl(pidl:PItemIDList; dwFileAttributes : Integer; psfib : PSHFILEINFOBYTE;
    cbFileInfo : Integer; uFlags : Integer):Integer;stdcall; external 'Shell32.dll' name 'SHGetFileInfoA';

var
  m_hSHNotify: Integer;
  m_pidlDesktop: PItemIDList;
  m_SHNotify_Registed: Boolean;

implementation

function SHEventName(strPath1,strPath2:string;lParam:Integer):string;
var
  sEvent:String;
begin
  case lParam of //根据参数设置提示消息
    SHCNE_RENAMEITEM: sEvent := '重命名文件'+strPath1+'为'+strpath2;
    SHCNE_CREATE: sEvent := '建立文件 文件名：'+strPath1;
    SHCNE_DELETE: sEvent := '删除文件 文件名：'+strPath1;
    SHCNE_MKDIR: sEvent := '新建目录 目录名：'+strPath1;
    SHCNE_RMDIR: sEvent := '删除目录 目录名：'+strPath1;
    SHCNE_MEDIAINSERTED: sEvent := strPath1+'中插入可移动存储介质';
    SHCNE_MEDIAREMOVED: sEvent := strPath1+'中移去可移动存储介质'+strPath1+' '+strpath2;
    SHCNE_DRIVEREMOVED: sEvent := '移去驱动器'+strPath1;
    SHCNE_DRIVEADD: sEvent := '添加驱动器'+strPath1;
    SHCNE_NETSHARE: sEvent := '改变目录'+strPath1+'的共享属性';
    SHCNE_ATTRIBUTES: sEvent := '改变文件目录属性 文件名'+strPath1;
    SHCNE_UPDATEDIR: sEvent := '更新目录'+strPath1;
    SHCNE_UPDATEITEM: sEvent := '更新文件 文件名：'+strPath1;
    SHCNE_SERVERDISCONNECT: sEvent := '断开与服务器的连接'+strPath1+' '+strpath2;
    SHCNE_UPDATEIMAGE: sEvent := 'SHCNE_UPDATEIMAGE';
    SHCNE_DRIVEADDGUI: sEvent := 'SHCNE_DRIVEADDGUI';
    SHCNE_RENAMEFOLDER: sEvent := '重命名文件夹'+strPath1+'为'+strpath2;
    SHCNE_FREESPACE: sEvent := '磁盘空间大小改变';
    SHCNE_ASSOCCHANGED: sEvent := '改变文件关联';
  else
    sEvent:='未知操作'+IntToStr(lParam);
  end;

  Result := sEvent;
end;

function SHNotify_Register(hWnd : Integer) : Bool;
var
  ps:PIDLSTRUCT;
begin
  {$R-}
  Result := False;
  new(ps);
  If m_hSHNotify = 0 then
  begin //获取桌面文件夹的Pidl
    if SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, m_pidlDesktop) <> NOERROR then
    begin
      Result := False;
      Exit;
    end;

    if Boolean(m_pidlDesktop) then
    begin
      ps.bWatchSubFolders := 1;
      ps.pidl := m_pidlDesktop;// 利用SHChangeNotifyRegister函数注册系统消息处理
      m_hSHNotify := SHChangeNotifyRegister(hWnd,(SHCNF_TYPE Or SHCNF_IDLIST),(SHCNE_ALLEVENTS Or SHCNE_INTERRUPT),WM_SHNOTIFY,1,ps);
      Result := Boolean(m_hSHNotify);
    end
    else // 如果出现错误就使用 CoTaskMemFree函数来释放句柄
    begin
      CoTaskMemFree(m_pidlDesktop);
    end;

    dispose(ps);
  end;
  {$R+}
end;

function SHNotify_UnRegister:Bool;
begin
  Result := False;
  If Boolean(m_hSHNotify) then //取消系统消息监视，同时释放桌面的Pidl
  begin
    If Boolean(SHChangeNotifyDeregister(m_hSHNotify)) then
    begin
      {$R-}
      m_hSHNotify := 0;
      CoTaskMemFree(m_pidlDesktop);
      Result := True;
      {$R+}
    end;
  end;
end;

end.
