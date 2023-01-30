//进程间共享数据方案

unit Jin_ShareMem;

interface

uses
  SysUtils, Windows, Messages, Classes, SyncObjs;

type
  TJinGlobalShareData = Record
    Data:array[0..7999] of Byte;
    Len: Integer;
  end;
  PJinGlobalShareData = ^TJinGlobalShareData;

  TJinGlobalShareMemory = class
  private
    FCreater: Boolean;
    FMapMemName: String;
    FDataPointer: PJinGlobalShareData;
    FFileMappingHandle: THandle;
    FCriticalSection:TCriticalSection;

    function GetPubMemData: Boolean;
    procedure CreatePubMemData;
  public
    constructor Create(AName: String; ACreater: Boolean);
    destructor Destroy; override;
    procedure Lock;
    procedure Unlock;

    procedure SetShareString(Value: String);
    function GetShareString: String;
  end;

implementation

function TJinGlobalShareMemory.GetPubMemData:Boolean;
begin
   Result := False;
   FDataPointer := nil;
   FFileMappingHandle := OpenFileMapping(FILE_MAP_ALL_ACCESS, FALSE, PChar(FMapMemName));
   if FFileMappingHandle <> 0 then
   begin
    FDataPointer := MapViewOfFile(FFileMappingHandle, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(TJinGlobalShareData));
    Result := True;
   end;
end;

procedure TJinGlobalShareMemory.CreatePubMemData;
begin
   FDataPointer := nil;
   FFileMappingHandle := CreateFileMapping($ffffffff, nil, PAGE_READWRITE or SEC_COMMIT, 0, SizeOf(TJinGlobalShareData), PChar(FMapMemName));
   if FFileMappingHandle <> 0 then
   begin
    FDataPointer := MapViewOfFile(FFileMappingHandle, FILE_MAP_ALL_ACCESS, 0, 0, SizeOf(TJinGlobalShareData));
   end;
end;

procedure TJinGlobalShareMemory.Lock;
begin
  if FCriticalSection = nil then FCriticalSection := TCriticalSection.Create;
  FCriticalSection.Enter;
end;

procedure TJinGlobalShareMemory.Unlock;
begin
 FCriticalSection.Leave;
end;

procedure TJinGlobalShareMemory.SetShareString(Value: String);
var
  uStr: UTF8String;
begin
  if FDataPointer = nil then Exit;

  Lock;
  try
    uStr := UTF8Encode(Value);
    FDataPointer.Len := Length(uStr);
    CopyMemory(@(FDataPointer.Data[0]), PAnsiChar(uStr), FDataPointer.Len);
  finally
    UnLock;
  end;
end;

function TJinGlobalShareMemory.GetShareString: String;
var
  uStr: UTF8String;
begin
  Result := '';
  if FDataPointer = nil then Exit;

  Lock;
  try
    SetLength(uStr, FDataPointer.Len);
    CopyMemory(PAnsiChar(uStr), @(FDataPointer.Data[0]), FDataPointer.Len);

    Result := UTF8ToUnicodeString(uStr);
  finally
    UnLock;
  end;
end;

constructor TJinGlobalShareMemory.Create(AName: String; ACreater: Boolean);
begin
  FFileMappingHandle := 0;
  FMapMemName := AName;
  FCreater := ACreater;

  if FCreater then
    CreatePubMemData
  else
    GetPubMemData;
end;

destructor TJinGlobalShareMemory.Destroy;
begin
  try
    if FCreater then
    begin
      if FDataPointer <> nil then
      begin
        SetShareString('');
        UnmapViewOfFile(FDataPointer);
        CloseHandle(FFileMappingHandle);
        FDataPointer := nil;
      end;
    end
    else
    begin
      CloseHandle(FFileMappingHandle);
    end;
  finally
    FreeAndNil(FCriticalSection);
    inherited Destroy;
  end;
end;

end.
