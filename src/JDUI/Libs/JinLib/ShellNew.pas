unit ShellNew;

interface

uses
  Windows, StrUtils, Registry, ActiveX, ShlObj, ShellApi, Classes, SysUtils, JinUtils,
  Generics.Collections;

type
  PShellNew = ^TShellNew;
  TShellNew = record
    Ext,
    TypeName,
    SrcFileName: String;
  end;


  function GetShellNewList: TArray<TShellNew>;

implementation

var
  FTypeNames: TStringList;

function GetTypeNameFromFile(AFileName: String): String;
var
  FileExt,
  TempFileName: String;
  TempFile: array[0..MAX_PATH] of char;
  SHFI:TSHFileInfo;
begin
  try
    FileExt := ExtractFileExt(AFileName);
    if FTypeNames.IndexOfName(FileExt) >= 0 then
    begin
      Result := FTypeNames.Values[FileExt];
      Exit;
    end;

    if not FileExists(AFileName) then
    begin
      FileExt := ExtractFileExt(AFileName);

      GetTempPath(MAX_PATH, TempFile);
      GetTempFileName(TempFile,
              PChar(IntToStr(GetTickCount)),
              GetTickCount,
              TempFile);
      TempFileName := ReplaceStr(TempFile, ExtractFileExt(TempFile), FileExt);
      TFileStream.Create(TempFileName, fmCreate).Free;

      SHGetFileInfo(PChar(TempFileName), 0, SHFI, SizeOf(SHFI), SHGFI_TYPENAME);
      Result := SHFI.szTypeName;

      FTypeNames.Add(FileExt + '=' + Result);

      DeleteFile(PChar(TempFileName));
      Exit;
    end;

    CoInitialize(nil);
    try
      SHGetFileInfo(PChar(AFileName), 0, SHFI, SizeOf(SHFI), SHGFI_TYPENAME);
      Result := SHFI.szTypeName;
      FTypeNames.Add(FileExt + '=' + Result);
    finally
      CoUninitialize;
    end;
  except
  end;
end;


function GetKeyValue(AKey, AValue:String): String;
var
  RegTemp: TRegistry;
begin
  Result := '';
  RegTemp := TRegistry.Create(KEY_READ);
  try
    RegTemp.RootKey := HKEY_CLASSES_ROOT;
    if RegTemp.OpenKey(AKey, False) then
      Result := RegTemp.ReadString(AValue);
  finally
    RegTemp.Free;
  end;
end;

function GetShellNewList: TArray<TShellNew>;
var
  Reg: TRegistry;
  RegSub: TRegistry;
  valueType: DWORD;
  valueLen: DWORD;
  p, buffer: PChar;
  ASubStrings2,
  AStrings: TStringList;
  ASubStrings: TStringList;
  iLoop, jLoop: Integer;
  AShellNew: TShellNew;
  AKey,
  ATypeName: String;
  oldValue : Pointer;
begin
  Reg := TRegistry.Create(KEY_READ);
  RegSub := TRegistry.Create(KEY_READ);
  AStrings := TStringList.Create;
  ASubStrings := TStringList.Create;
  ASubStrings2 := TStringList.Create;
  if Is64Bit then Wow64DisableWow64FsRedirection(oldValue);
  try
    Reg.RootKey := HKEY_CURRENT_USER;
    if Reg.OpenKey('Software\Microsoft\Windows\CurrentVersion\Explorer\Discardable\PostSetup\ShellNew', False) then
    begin
      if IsVista then
      begin
        SetLastError(RegQueryValueEx(Reg.CurrentKey, PChar('Classes'), nil, @valueType,nil, @valueLen));
        if GetLastError = ERROR_SUCCESS then
        if valueType = REG_MULTI_SZ then
        begin
          GetMem(buffer, valueLen) ;
          try
           RegQueryValueEx(Reg.CurrentKey, PChar('Classes'), nil, nil, PBYTE(buffer), @valueLen) ;
           p := buffer ;
           while p^ <> #0 do
           begin
              AStrings.Add(p) ;
              Inc(p, lstrlen(p) + 1)
           end
          finally
            FreeMem(buffer)
          end;
        end;
      end
      else
      begin
        Reg.GetValueNames(AStrings);
      end;
      Reg.CloseKey;
    end;

    Reg.RootKey := HKEY_CLASSES_ROOT;
    if Reg.OpenKey('', False) then
    begin
      ASubStrings.Clear;
      Reg.GetKeyNames(ASubStrings);

      for iLoop := 0 to ASubStrings.Count - 1 do
      begin
        RegSub.RootKey := HKEY_CLASSES_ROOT;
        if not IsVista then
        begin
          ATypeName := GetKeyValue(GetKeyValue(ASubStrings[iLoop], ''), '');
          if AStrings.IndexOf(ATypeName) < 0 then Continue;
        end
        else
        begin
          if AStrings.IndexOf(ASubStrings[iLoop]) < 0 then Continue;
        end;

        AShellNew.Ext := ASubStrings[iLoop];
        AKey := ASubStrings[iLoop] + '\' + GetKeyValue(ASubStrings[iLoop], '') + '\ShellNew';

        RegSub.CloseKey;
        if RegSub.OpenKey(AKey, False) then
        begin

        end
        else if RegSub.OpenKey(ASubStrings[iLoop] + '\ShellNew', False) then
        begin

        end
        else
          Continue;

        //ASubStrings2.Clear;
        //RegSub.GetValueNames(ASubStrings2);


        if RegSub.ValueExists('Handler') then
          Continue;
        if RegSub.ValueExists('FileName') then
        begin
          AShellNew.SrcFileName := RegSub.ReadString('FileName');
          AShellNew.SrcFileName := ReplaceSystemReplaceID(AShellNew.SrcFileName);
          if not FileExists(AShellNew.SrcFileName) then
          begin
            AShellNew.SrcFileName := GetSpecialFolderDir(CSIDL_WINDOWS) + 'ShellNew\' + AShellNew.SrcFileName;
            if not FileExists(AShellNew.SrcFileName) then
              Continue;
          end;
        end
        else if RegSub.ValueExists('NullFile') then
        begin
          AShellNew.SrcFileName := RegSub.ReadString('NullFile');
        end
        else
          Continue;

        AShellNew.TypeName := GetTypeNameFromFile(AShellNew.Ext);
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := AShellNew;

        RegSub.CloseKey;
      end;
    end;
  finally
    Reg.Free;
    RegSub.Free;
    ASubStrings.Free;
    ASubStrings2.Free;
    AStrings.Free;
    if Is64Bit then Wow64RevertWow64FsRedirection(oldValue);
  end;
end;


initialization
  FTypeNames := TStringList.Create;

finalization
  FreeAndNil(FTypeNames);


end.
