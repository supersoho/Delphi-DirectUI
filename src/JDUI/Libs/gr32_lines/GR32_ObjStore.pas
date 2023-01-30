unit GR32_ObjStore;

(* ***** BEGIN LICENSE BLOCK *****
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 * http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 * for the specific language governing rights and limitations under the
 * License.
 *
 * The Original Code is Graphics32
 * The Initial Developer of the Original Code is Alex A. Denisov
 * Portions created by the Initial Developer are Copyright (C) 2000-2007
 * the Initial Developer. All Rights Reserved.
 *
 * The Initial Developer of the code in GR32_ObjStore.pas is Angus Johnson
 * <angus@angusj.com>. GR32_Objects.pas code is Copyright (C) 2009.
 * All Rights Reserved.
 *
 * Version 0.58 alpha (Last updated 10-Nov-2010)
 *
 * ***** END LICENSE BLOCK ***** *)

interface

{$INCLUDE GR32.inc}

{$IFDEF COMPILER7}
{$WARN UNSAFE_CODE OFF}
{$WARN UNSAFE_TYPE OFF}
{$WARN UNSAFE_CAST OFF}
{$ENDIF}

uses
{$IFDEF CLX}
  Qt, QControls, QGraphics, QForms,
  {$IFDEF LINUX}Libc, {$ENDIF}
  {$IFDEF MSWINDOWS}Windows, {$ENDIF}
{$ELSE}
  Windows, Controls, Graphics, Forms,
{$ENDIF}
  Types, Classes, SysUtils, Math, GR32, GR32_Layers, GR32_Objects,
  TypInfo, ZLib, Variants;

procedure SaveObjectToStream(drawObj: TDrawObjLayerBase; stream: TStream);
procedure LoadObjectsFromStream(owner: TLayerCollection; stream: TStream);

implementation

uses GR32_Lines;

{$IFNDEF UNICODE}
type
  UnicodeString = WideString;
{$ENDIF}

//------------------------------------------------------------------------------
// Miscellaneous functions ...
//------------------------------------------------------------------------------

function SwapLFsToESCs(const us: UnicodeString): UnicodeString;
var
  i: integer;
begin
  result := us;
  for i := length(result) downto 1 do
    if result[i] = #10 then result[i] := #27
    else if result[i] = #13 then delete(result,i,1);
end;
//------------------------------------------------------------------------------

function SwapESCsToLFs(const us: UnicodeString): UnicodeString;
var
  i: integer;
begin
  result := us;
  for i := 1 to length(result) do if result[i] = #27 then result[i] := #10;
end;
//------------------------------------------------------------------------------

function ReadLine(stream: TStream; out s: string): boolean;
const
  buff_size = 512;
var
  tmpStr: string;
  LfPos, bytesRead: integer;
  buff: array [0 .. buff_size-1] of AnsiChar;
begin
  s := '';
  result := false;
  while stream.Position < stream.Size do
  begin
    bytesRead := stream.read(buff[0],buff_size);
    if (bytesRead = 0) then exit;
    LfPos := 0;
    while (LfPos < bytesRead) and (buff[LfPos] <> #10) do inc(LfPos);
    if LfPos > 0 then
    begin
      if s <> '' then
      begin
        SetString(tmpStr,buff,LfPos);
        s := s + tmpStr;
      end
      else
        SetString(s,buff,LfPos)
    end;
    if LfPos < bytesRead then
    begin
      stream.Seek(-bytesRead+LfPos+1, soFromCurrent);
      result := stream.Position < stream.Size;
      break;
    end;
  end;
end;
//------------------------------------------------------------------------------

procedure saveLineToStream(const line: string; stream: TStream);
const
  lf: ansiChar = #10;
begin
  if line <> '' then stream.Write(line[1],length(line));
  stream.Write(lf,1);
end;
//------------------------------------------------------------------------------

function DynArraySize(a: Pointer): Integer;
asm
        TEST EAX, EAX
        JZ   @@exit
        MOV  EAX, [EAX-4]
@@exit:
end;
//------------------------------------------------------------------------------

//nb: SavePublishedPropsToStringStream() has been highly customized for
//    TDrawObjLayerBaseClass objects.
procedure SavePublishedPropsToStringStream(obj: TObject;
  const classStr: string; stream: TStream);
var
  i,j: integer;
  f: single;
  td : PTypeData;
  ti: PTypeInfo;
  pl : PPropList;
  PropInfo: PPropInfo;
  propName, s: string;
  subObj: TObject;
  DynArrayTypeInfo: PDynArrayTypeInfo;
  DynArray: pointer;
begin
  ti:=obj.ClassInfo;
  td := GetTypeData(ti);
  GetMem (pl, td^.PropCount*SizeOf(Pointer));
  try
    GetPropInfos(ti,pl);
    for i :=0 to td^.PropCount-1 do
    begin
      PropInfo := pl^[i];
      propName := PropInfo.name;
      if (propName = 'FillColor') then continue;
      case PropInfo.PropType^.Kind of
        tkEnumeration:
          begin
            if GetOrdProp(obj, PropInfo) = PropInfo.Default then continue;
            s := GetEnumProp(obj, PropInfo);
            saveLineToStream(format('%s%s=%s',[classStr,propName,s]),stream);
          end;
        tkInteger:
          begin
            j := GetOrdProp(obj, PropInfo);
            if j <> PropInfo.Default then
            begin
              if GetTypeData(PropInfo.PropType^).OrdType = otULong then
                saveLineToStream(classStr + format('%s=$%8.8x',[ propName, cardinal(j)]),stream)
              else
                saveLineToStream(classStr + format('%s=%d',[ propName, j]),stream);
            end;
          end;
        tkFloat:
          begin
            f := GetFloatProp(obj, PropInfo);
            saveLineToStream(classStr + format('%s=%1.4f',[ propName, f]),stream);
          end;
        tkLString:
          begin
            s := GetStrProp(obj, PropInfo);
            if s <> '' then
              saveLineToStream(format('%s%s=%s',[classStr,propName,s]),stream);
          end;
        tkWString:
          begin
            s := UTF8Encode(SwapLFsToESCs(GetWideStrProp(obj, propName)));
            if s <> '' then
              saveLineToStream(format('%s%s=%s',[classStr,propName,s]),stream);
          end;
        tkSet:
          begin
            s := GetSetProp(obj, PropInfo);
            if s <> '' then
              saveLineToStream(format('%s%s=%s',[classStr,propName,s]),stream);
          end;
        tkClass:
          begin
            subObj := TObject(GetOrdProp(obj, PropInfo));
            if assigned(subObj) then
              if subObj is TComponent then
                saveLineToStream(format('%s%s=%s',[classStr,
                  propName, inttostr(cardinal(subObj))]),stream)
              else
                SavePublishedPropsToStringStream(subObj,
                  classStr + propName + '.', stream);
          end;
        tkDynArray:
          begin
            DynArrayTypeInfo := PDynArrayTypeInfo(PropInfo.PropType^);
            Inc(PAnsiChar(DynArrayTypeInfo), SizeOf(DynArrayTypeInfo.name));
            //we're only interested in single dimensional arrays of integer
            if (DynArrayTypeInfo^.elType <> nil) or
              (DynArrayTypeInfo^.varType <> varInteger) or
              (DynArrayTypeInfo^.elSize <> 4) then continue;
            DynArray := Pointer(GetOrdProp(obj, PropInfo));
            j := DynArraySize(DynArray);
            if j = 0 then continue; //empty array
            s := propName+'=';
            for j := 1 to j-1 do
            begin
              //Regardless of whether these are signed or unsigned integer
              //arrays, they're stored to string in hex format ...
              s := format('%s$%8.8x,',[s, PCardinal(DynArray)^]);
              inc(PAnsiChar(DynArray), 4);
            end;
            s := format('%s$%8.8x',[s, PCardinal(DynArray)^]);
            saveLineToStream(s, stream);
          end;
      end;
    end;
  finally
    FreeMem(pl);
  end;
end;
//------------------------------------------------------------------------------

type
  TDrawObjLayerBaseHack = class(TDrawObjLayerBase);
  TDrawObjGraphicHack = class(TDrawObjGraphic);

procedure ConvertBinaryDataToHexStream(buff: Pointer;
  buffSize: integer; stream: TStream);
const
  BytesPerLine = 32;
var
  i: Integer;
  cnt: Longint;
  Buffer: array[0 .. BytesPerLine -1] of AnsiChar;
  HexText: array[0 .. BytesPerLine*2 -1] of AnsiChar;
  ms: TMemoryStream;
begin
  ms := TMemoryStream.Create;
  try
    //compress the data ...
    with TCompressionStream.Create(clMax, ms) do
    try
      WriteBuffer(buff^,buffSize);
    finally
      Free; //must be freed to flush outStream
    end;
    ms.Position := 0;

    cnt := ms.Size;
    while cnt > 0 do
    begin
      if cnt > 32 then i := 32 else i := cnt;
      ms.ReadBuffer(Buffer, i);
      BinToHex(Buffer, HexText, i);
      saveLineToStream('  ' + copy(HexText, 1, i *2), stream);
      Dec(cnt, i);
    end;
  finally
    ms.Free;
  end;
end;
//------------------------------------------------------------------------------

procedure ConvertHexStreamToBinaryStream(inStream, outStream: TStream);
const
  BufferSize = 4096;
var
  i, len: integer;
  s: string;
  Buffer: array[0 .. BufferSize -1] of AnsiChar;
  ms: TMemoryStream;
  dcs: TDecompressionStream;
begin
  ms := TMemoryStream.Create;
  try
    while ReadLine(inStream, s) do
    begin
      len := length(s);
      if s = '}' then break;
      if (len < 4) or (s[1] <> ' ') or (s[2] <> ' ') then exit;
      i := HexToBin(PAnsiChar(@s[3]), Buffer, BufferSize);
      if i = 0 then exit;
      ms.Write(Buffer[0],i);
    end;
    if ms.Size = 0 then exit;

    ms.Position := 0;
    dcs := TDecompressionStream.Create(ms);
    try
      while true do
      begin
       i := dcs.Read(Buffer, BufferSize);
       if i > 0 then outStream.Write(Buffer, i)
       else Break;
      end;
    finally
      dcs.Free;
    end;

  finally
    ms.Free;
  end;
end;
//------------------------------------------------------------------------------

procedure SaveObjectToStream(drawObj: TDrawObjLayerBase; stream: TStream);
var
  i,j, buffSize: integer;
  s: string;
  buff,p: pointer;
  savedDecimalSeparator: char;
begin
  //savedDecimalSeparator := DecimalSeparator;
  //DecimalSeparator := '.';
  try
    with TDrawObjLayerBaseHack(drawObj) do
    begin
      saveLineToStream('['+ClassName+']', stream);
      for i := 0 to UnpublishedProps.Count -1 do
      begin
        s := UnpublishedProps[i]+'=';
        if UnpublishedProps[i] = 'ControlBtns' then
          for j := 0 to ControlBtnCount -1 do
            with FloatPoint(ControlBtns[j]) do
              s := s + format('%1.2f,%1.2f;',[X,Y])
        else if UnpublishedProps[i] = 'RotationPoint' then
          s := s + format('%1.2f,%1.2f',[RotationPoint.X,RotationPoint.Y])
        else if UnpublishedProps[i] = 'PictureData' then
        begin
          if drawObj is TDrawObjGraphic then
            with TDrawObjGraphicHack(drawObj).Pic do
              if not Empty then
              begin
                //buffer contents: width, height, images bits
                buffSize := Width * Height * sizeof(TColor32) +
                  sizeof(longint) * 2;
                GetMem(buff,buffSize);
                try
                  p := buff;
                  PInteger(p)^ := Width;
                  inc(PInteger(p));
                  PInteger(p)^ := Height;
                  inc(PInteger(p));
                  Move(Bits[0],p^, Width * Height * sizeof(TColor32));
                  saveLineToStream(s + '{', stream);
                  ConvertBinaryDataToHexStream(buff,buffSize,stream);
                  s := '}';
                finally
                  FreeMem(buff);
                end;
              end;
        end
        else
          Raise Exception.Create('Unknown property type: '+UnpublishedProps[i]);

        saveLineToStream(s, stream);
      end;
      SavePublishedPropsToStringStream(drawObj, '', stream);
      saveLineToStream('', stream);
    end;
  finally
    //DecimalSeparator := savedDecimalSeparator;
  end;
end;
//------------------------------------------------------------------------------

procedure GetObjAndPropAndVal(const str: string;
  var Obj: TObject; var prop, val: string);
var
  i,j: integer;
  subObjName: string;
begin
  prop := '';
  i := pos('.', str);
  j := pos('=', str);
  if (j < 2) then exit; //oops!!
  if (i > 0) and (i < j) then
  begin
    subObjName := copy(str,1,i-1);
    if (PropType(obj, subObjName) <> tkClass) then exit;
    Obj := TObject(GetOrdProp(obj,subObjName));
    GetObjAndPropAndVal(copy(str,i+1,512), Obj, prop, val);
  end else
  begin
    prop := copy(str,1,j-1);
    val := copy(str,j+1,512);
  end;
end;
//------------------------------------------------------------------------------

function StrToCardinalDef(const s: string; default: cardinal): cardinal;
var
  code: integer;
begin
  try
    Val(s, result, code);
    if code <> 0 then result := default;
  except
    result := default;
  end;
end;
//------------------------------------------------------------------------------

procedure StrToDynArrayOfCardinal(s: string; var DynArray: pointer);
var
  i, len, oldLen, commaCnt, valStartPos: integer;
  values: array of Cardinal;
  p: PCardinal;
begin
  s := trim(s);
  len := length(s);
  if len = 0 then exit;
  if not (s[len] in [',',';']) then
  begin
    s := s + ',';
    inc(len);
  end;
  commaCnt := 0;
  for i := 1 to len do
    if (s[i] in [',',';']) then
      inc(commaCnt);
  setlength(values, commaCnt);
  commaCnt := 0;
  valStartPos := 1;
  for i := 1 to len do
    if s[i] in [',',';'] then
    begin
      values[commaCnt] :=
        StrToCardinalDef(Copy(s,valStartPos, i-valStartPos), 0);
      valStartPos := i +1;
      inc(commaCnt);
    end;

  len := length(values); //nb: len reassigned
  if assigned(DynArray) then
  begin
    p := DynArray;
    dec(p);
    oldLen := p^;
    dec(p);
    if oldLen <> len then
      ReallocMem(p, sizeof(cardinal)*(len + 2));
    Inc(p);
    p^ := len; //ie new array length
    Inc(p);
  end else
  begin
    GetMem(p,sizeof(cardinal)*(len + 2));
    p^ := 1;   //reference counter
    inc(p);
    p^ := len; //array length
    Inc(p);
  end;
  DynArray := p;
  for i := 0 to len-1 do
  begin
    p^ := values[i];
    Inc(p);
  end;
end;
//------------------------------------------------------------------------------

procedure LoadPublishedPropsFromStream(obj: TPersistent; stream: TStream);
var
  s, propName, propVal: string;
  subObj: TObject;
  PropInfo: PPropInfo;
  DynArrayTypeInfo: PDynArrayTypeInfo;
  DynArray: Pointer;
begin
  if not assigned(obj) or not assigned(stream) then exit;
  while ReadLine(stream, s) do
  begin
    if trim(s) = '' then exit; //ie end of the current object
    subObj := obj;
    GetObjAndPropAndVal(s, subObj, propName, propVal);
    if (propName = '') then exit; //oops!
    PropInfo := GetPropInfo(subObj.ClassType, propName);
    if (PropInfo = nil) then continue; //expected with unpublished properties.
    case PropType(subObj, propName) of
      tkEnumeration: SetEnumProp(subObj, propName, propVal);
      tkInteger:
        if GetTypeData(PropInfo.PropType^).OrdType = otULong then
          SetPropValue(subObj, propName, StrToCardinalDef(propVal,0)) else
          SetPropValue(subObj, propName, strtointdef(propVal,0));
      tkFloat: SetFloatProp(subObj, propName, StrToFloatDef(propVal,0));
      tkLString: SetPropValue(subObj, propName, propVal);
      tkWString: SetPropValue(subObj, propName,
        SwapESCsToLFs(UTF8Decode(propVal))); //nb: #10s are stored as #27s
      tkSet: SetSetProp(subObj, propName, propVal);
      tkClass: ;
      tkDynArray:
        begin
          DynArrayTypeInfo := PDynArrayTypeInfo(PropInfo.PropType^);
          Inc(PAnsiChar(DynArrayTypeInfo), SizeOf(DynArrayTypeInfo.name));
          //we're only interested in single dimensional arrays of TColor32
          if (DynArrayTypeInfo^.elType <> nil) or
            (DynArrayTypeInfo^.varType <> varInteger) then continue;
          //get the existing DynArray, resize and fill it ...
          DynArray := Pointer(GetOrdProp(obj, PropInfo));
          StrToDynArrayOfCardinal(propVal, DynArray);
          //and in case DynArray has been ReAllocMem'd ...
          SetOrdProp(obj, PropInfo, longint(DynArray));
        end;
    end;
  end;
end;
//------------------------------------------------------------------------------

function GetFloatPointsFromString(s: string): TArrayOfFloatPoint;
var
  i, len, commaCnt, comma1: integer;
  values: array of single;
begin
  result := nil;
  len := length(s);
  if len = 0 then exit;
  if not (s[len] in [',',';']) then
  begin
    s := s + ',';
    inc(len);
  end;
  commaCnt := 0;
  for i := 1 to len do if (s[i] in [',',';']) then inc(commaCnt);
  setlength(values, commaCnt);
  commaCnt := 0;
  comma1 := 1;
  for i := 1 to len do
    if (s[i] in [',',';']) then
    begin
      values[commaCnt] := strToFloatDef(Copy(s,comma1, i-comma1),0);
      comma1 := i +1;
      inc(commaCnt);
    end;
  len := length(values) div 2;
  setlength(result, len);
  for i := 0 to len -1 do
  begin
    result[i].X := values[i*2];
    result[i].Y := values[i*2+1];
  end;
end;
//------------------------------------------------------------------------------

procedure LoadObjectsFromStream(owner: TLayerCollection; stream: TStream);
var
  w,h,len: integer;
  s: string;
  PersistentClass: TPersistentClass;
  drawObj: TDrawObjLayerBase;
  CtrlPts,RotatePts: TArrayOfFloatPoint;
  ms: TMemoryStream;
  P: Pointer;
  savedDecimalSeparator: char;
begin
  //savedDecimalSeparator := DecimalSeparator;
  //DecimalSeparator := '.';
  try
    while ReadLine(stream, s) do
    begin
      s := Trim(s);
      len := length(s);
      if len = 0 then continue;
      if (len < 3) or (s[1] <> '[') or (s[len] <> ']') then break;
      PersistentClass := nil;
      try
        PersistentClass := FindClass(copy(s,2,len-2));
      except
      end;
      if not assigned(PersistentClass) then break;
      drawObj := TDrawObjLayerBaseClass(PersistentClass).Create(owner);
      with TDrawObjLayerBaseHack(drawObj) do
      begin
        BeginUpdate;
        //get the ControlButtons ...
        ReadLine(stream, s);
        if Pos('ControlBtns=',s) <> 1 then break;
        delete(s,1,12);
        CtrlPts := GetFloatPointsFromString(s);
        //Get RotationPoint ...
        ReadLine(stream, s);
        if Pos('RotationPoint=',s) <> 1 then break;
        delete(s,1,14);
        RotatePts := GetFloatPointsFromString(s);
        //Get image if TDrawObjGraphic ...
        if drawObj is TDrawObjGraphic then
        begin
          ReadLine(stream, s);
          if s <> 'PictureData={' then break;
          ms := TMemoryStream.Create;
          try
            ConvertHexStreamToBinaryStream(stream, ms);
            if ms.Size > 8 then
            begin
              p := ms.Memory;
              w := PInteger(p)^;
              inc(PInteger(p));
              h := PInteger(p)^;
              inc(PInteger(p));
              if ms.Size = (w*h*sizeof(TColor32)) + SizeOf(integer)*2 then
                with TDrawObjGraphicHack(drawObj).Pic do
                begin
                  SetSize(w,h);
                  move(ms.memory^,bits[0],w*h*sizeof(TColor32));
                end;
            end;
          finally
            ms.free;
          end;
        end;
        LoadPublishedPropsFromStream(drawObj, stream);
        RotationPoint := RotatePts[0];
        SetControlBtns(CtrlPts);
        EndUpdate;
      end;
    end;
  finally
    //DecimalSeparator := savedDecimalSeparator;
  end;
end;
//------------------------------------------------------------------------------

end.
