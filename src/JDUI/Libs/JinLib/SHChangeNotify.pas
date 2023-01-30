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
  case lParam of //���ݲ���������ʾ��Ϣ
    SHCNE_RENAMEITEM: sEvent := '�������ļ�'+strPath1+'Ϊ'+strpath2;
    SHCNE_CREATE: sEvent := '�����ļ� �ļ�����'+strPath1;
    SHCNE_DELETE: sEvent := 'ɾ���ļ� �ļ�����'+strPath1;
    SHCNE_MKDIR: sEvent := '�½�Ŀ¼ Ŀ¼����'+strPath1;
    SHCNE_RMDIR: sEvent := 'ɾ��Ŀ¼ Ŀ¼����'+strPath1;
    SHCNE_MEDIAINSERTED: sEvent := strPath1+'�в�����ƶ��洢����';
    SHCNE_MEDIAREMOVED: sEvent := strPath1+'����ȥ���ƶ��洢����'+strPath1+' '+strpath2;
    SHCNE_DRIVEREMOVED: sEvent := '��ȥ������'+strPath1;
    SHCNE_DRIVEADD: sEvent := '���������'+strPath1;
    SHCNE_NETSHARE: sEvent := '�ı�Ŀ¼'+strPath1+'�Ĺ�������';
    SHCNE_ATTRIBUTES: sEvent := '�ı��ļ�Ŀ¼���� �ļ���'+strPath1;
    SHCNE_UPDATEDIR: sEvent := '����Ŀ¼'+strPath1;
    SHCNE_UPDATEITEM: sEvent := '�����ļ� �ļ�����'+strPath1;
    SHCNE_SERVERDISCONNECT: sEvent := '�Ͽ��������������'+strPath1+' '+strpath2;
    SHCNE_UPDATEIMAGE: sEvent := 'SHCNE_UPDATEIMAGE';
    SHCNE_DRIVEADDGUI: sEvent := 'SHCNE_DRIVEADDGUI';
    SHCNE_RENAMEFOLDER: sEvent := '�������ļ���'+strPath1+'Ϊ'+strpath2;
    SHCNE_FREESPACE: sEvent := '���̿ռ��С�ı�';
    SHCNE_ASSOCCHANGED: sEvent := '�ı��ļ�����';
  else
    sEvent:='δ֪����'+IntToStr(lParam);
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
  begin //��ȡ�����ļ��е�Pidl
    if SHGetSpecialFolderLocation(0, CSIDL_DESKTOP, m_pidlDesktop) <> NOERROR then
    begin
      Result := False;
      Exit;
    end;

    if Boolean(m_pidlDesktop) then
    begin
      ps.bWatchSubFolders := 1;
      ps.pidl := m_pidlDesktop;// ����SHChangeNotifyRegister����ע��ϵͳ��Ϣ����
      m_hSHNotify := SHChangeNotifyRegister(hWnd,(SHCNF_TYPE Or SHCNF_IDLIST),(SHCNE_ALLEVENTS Or SHCNE_INTERRUPT),WM_SHNOTIFY,1,ps);
      Result := Boolean(m_hSHNotify);
    end
    else // ������ִ����ʹ�� CoTaskMemFree�������ͷž��
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
  If Boolean(m_hSHNotify) then //ȡ��ϵͳ��Ϣ���ӣ�ͬʱ�ͷ������Pidl
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
