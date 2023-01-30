{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10032: kphstrms.pas 
{
{   Rev 1.0    8/14/2005 1:10:08 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.15    10/11/2004 5:18:24 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.14    12/30/2003 11:01:12 AM  Supervisor    Version: VCLZip 3.X
{ Fix SaveToStream
}
{
{   Rev 1.13    12/30/2003 9:29:56 AM  Supervisor    Version: VCLZip 3.X
{ Fix CurrentPosition
}
{
{   Rev 1.12    12/16/2003 12:36:54 PM  Supervisor    Version: VCLZip 3.X
{ Get rid of abstract warning.
}
{
{   Rev 1.11    12/16/2003 8:59:56 AM  Supervisor    Version: VCLZip 3.X
{ GetStream and GetTStream stuff
}
{
{   Rev 1.10    12/13/2003 9:07:46 PM  Supervisor    Version: VCLZip 3.X
{ Fix GetStream
}
{
{   Rev 1.9    11/1/2003 8:11:38 PM  Supervisor    Version: VCLZip 3.X
{ Add overloaded ZipFromStream and UnZipToStreams for TStreams
}
{
{   Rev 1.8    9/8/2003 5:41:16 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.7    9/1/2003 10:58:38 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.6    9/1/2003 10:47:48 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.5    5/31/2003 3:57:46 PM  Kevin    Version: VCLZip 3.X
{ After D4 Fixes
}
{
{   Rev 1.4    5/23/2003 5:07:12 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.3    5/23/2003 2:36:30 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.2    5/20/2003 10:46:22 PM  Kevin    Version: VCLZip3.00z64c
}
{
{   Rev 1.1    5/19/2003 10:45:04 PM  Supervisor
{ After fixing streams.  VCLZip still uses ErrorRpt.  Also added setting of
{ capacity on the sorted containers to alleviate the memory problem caused by
{ growing array.
}
{
{   Rev 1.0    10/15/2002 8:15:14 PM  Supervisor
}
{
{   Rev 1.0    9/3/2002 10:09:44 PM  Supervisor    Version: 2.23+
{ New file containg streams capable of handling large files
}
{
{   Rev 1.0    9/3/2002 8:06:22 PM  Supervisor    Version: Baseline 2.23+
{ VCLZip 2.23+ baseline before modifying to version 3.0 to handle 4 gig files
}
unit kphstrms;

interface

uses SysUtils, Windows, Classes;

{$I KPDEFS.INC}


type

  TSeekOrigin = (soBeginning,soCurrent,soEnd);

{ TkpHugeStream abstract class }

  TkpHugeStream = class(TObject)
  private
    function GetPosition: Int64;
    procedure SetPosition(Pos: Int64);
    function GetSize: Int64;
  protected
    procedure SetSize(const NewSize: Int64); virtual;
  public
    function Read(var Buffer; Count: Longint): Longint; virtual; abstract;
    function Write(const Buffer; Count: Longint): Longint; virtual; abstract;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual; abstract;
    procedure ReadBuffer(var Buffer; Count: Longint);
    procedure WriteBuffer(const Buffer; Count: Longint);
    function CopyFrom(Source: TkpHugeStream; Count: Int64): Int64; overload;
    function CopyFrom(Source: TStream; Count: Integer): Integer; overload;
    procedure SaveToStream(Stream: TStream); virtual; abstract;
    function GetStream: TStream; virtual; abstract;
    procedure GetTStream(stream: TStream); virtual;
    property Position: Int64 read GetPosition write SetPosition;
    property Size: Int64 read GetSize write SetSize;
  end;

{ TkpHugeHandleStream class }

  TkpHugeHandleStream = class(TkpHugeStream)
  private
    FHandle: Integer;
  protected
    procedure SetSize(const NewSize: Int64); override;
  public
    constructor Create(AHandle: Integer); overload;
    constructor Create(Stream: THandleStream); overload;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    function GetStream: TStream; override;
    procedure SaveToStream(Stream: TStream); override;
    property Handle: Integer read FHandle;
  end;

{ TkpHugeFileStream class }

  TkpHugeFileStream = class(TkpHugeHandleStream)
  public
    constructor Create(const FileName: string; Mode: Word);
    destructor Destroy; override;
  end;

  { TkpHugeCustomMemoryStream abstract class }

  TkpHugeCustomMemoryStream = class(TkpHugeStream)
  private
    FMemory: Pointer;
    FSize, FPosition: LongInt;
  protected
    procedure SetPointer(Ptr: Pointer; Size: LongInt);
  public
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; overload; override;
    function Seek(Offset: Longint; Origin: Word): Longint; reintroduce; overload;
    procedure SaveToStream(Stream: TkpHugeStream); reintroduce; overload;
    procedure SaveToStream(Stream: TStream); overload; override;
    procedure SaveToFile(const FileName: string);
    function GetStream: TStream; override;
    procedure GetTStream(stream: TStream); override;
    property Memory: Pointer read FMemory;
  end;

{ TkpHugeMemoryStream }

  TkpHugeMemoryStream = class(TkpHugeCustomMemoryStream)
  private
    FCapacity: LongInt;
    procedure SetCapacity(NewCapacity: LongInt);
  protected
    function Realloc(var NewCapacity: Longint): Pointer; virtual;
    property Capacity: Longint read FCapacity write SetCapacity;
  public
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromStream(Stream: TkpHugeStream);
    procedure LoadFromFile(const FileName: string);
    procedure SetSize(const NewSize: Int64); override;
    function Write(const Buffer; Count: Longint): Longint; override;
  end;


implementation

uses
{$IFDEF ISCLX}
  RTLConsts;
{$ELSE}
  Consts;
{$ENDIF}

{ TkpHugeStream }

function TkpHugeStream.GetPosition: Int64;
begin
  Result := Seek(0, soCurrent);
end;

procedure TkpHugeStream.SetPosition(Pos: Int64);
begin
  Seek(Pos, soBeginning);
end;

function TkpHugeStream.GetSize: Int64;
var
  Pos: Int64;
begin
  Pos := Seek(0, soCurrent);
  Result := Seek(0, soEnd);
  Seek(Pos, soBeginning);
end;

procedure TkpHugeStream.SetSize(const NewSize: Int64);
begin
  // default = do nothing  (read-only streams, etc)
end;

procedure TkpHugeStream.GetTStream(stream: TStream);
begin
  // Not implemented.  Just to supress warnings.
end;


procedure TkpHugeStream.ReadBuffer(var Buffer; Count: Longint);
begin
  if (Count <> 0) and (Read(Buffer, Count) <> Count) then
    raise EReadError.Create(SReadError);
end;

procedure TkpHugeStream.WriteBuffer(const Buffer; Count: Longint);
begin
  if (Count <> 0) and (Write(Buffer, Count) <> Count) then
    raise EWriteError.Create(SWriteError);
end;

function TkpHugeStream.CopyFrom(Source: TkpHugeStream; Count: Int64): Int64;
const
  MaxBufSize = $F000;
var
  BufSize, N: Integer;
  Buffer: PChar;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end;
  Result := Count;
  if Count > MaxBufSize then BufSize := MaxBufSize else BufSize := Count;
  GetMem(Buffer, BufSize);
  try
    while Count <> 0 do
    begin
      if Count > BufSize then N := BufSize else N := Count;
      Source.ReadBuffer(Buffer^, N);
      WriteBuffer(Buffer^, N);
      Dec(Count, N);
    end;
  finally
    FreeMem(Buffer, BufSize);
  end;
end;

function TkpHugeStream.CopyFrom(Source: TStream; Count: Integer): Integer;
const
  MaxBufSize = $F000;
var
  BufSize, N: Integer;
  Buffer: PChar;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end;
  Result := Count;
  if Count > MaxBufSize then BufSize := MaxBufSize else BufSize := Count;
  GetMem(Buffer, BufSize);
  try
    while Count <> 0 do
    begin
      if Count > BufSize then N := BufSize else N := Count;
      Source.ReadBuffer(Buffer^, N);
      WriteBuffer(Buffer^, N);
      Dec(Count, N);
    end;
  finally
    FreeMem(Buffer, BufSize);
  end;
end;


{ TkpHugeHandleStream }

constructor TkpHugeHandleStream.Create(AHandle: Integer);
begin
  FHandle := AHandle;
end;

constructor TkpHugeHandleStream.Create(Stream: THandleStream);
begin
  FHandle := Stream.Handle;
end;

function TkpHugeHandleStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := FileRead(FHandle, Buffer, Count);
  if Result = -1 then Result := 0;
end;

function TkpHugeHandleStream.Write(const Buffer; Count: Longint): Longint;
begin
  Result := FileWrite(FHandle, Buffer, Count);
  if Result = -1 then Result := 0;
end;

function TkpHugeHandleStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  Result := FileSeek(FHandle, Offset, Ord(Origin));
end;

procedure TkpHugeHandleStream.SetSize(const NewSize: Int64);
begin
  Seek(NewSize, soBeginning);
  Win32Check(SetEndOfFile(FHandle));
end;

function TkpHugeHandleStream.GetStream: TStream;
begin
     Result := THandleStream.Create(FHandle);
     FHandle := -1;
end;

procedure TkpHugeHandleStream.SaveToStream(Stream: TStream);
var
  hs: THandleStream;
begin
  hs := THandleStream.Create(FHandle);
  Stream.CopyFrom(hs,GetSize);
  hs.Free;
end;


{ TkpHugeFileStream }

constructor TkpHugeFileStream.Create(const FileName: string; Mode: Word);
begin
  if Mode = fmCreate then
  begin
    FHandle := FileCreate(FileName);
    if FHandle < 0 then
      raise EFCreateError.CreateFmt(SFCreateError, [FileName]);
  end else
  begin
    FHandle := FileOpen(FileName, Mode);
    if FHandle < 0 then
      raise EFOpenError.CreateFmt(SFOpenError, [FileName]);
  end;
end;

destructor TkpHugeFileStream.Destroy;
begin
  if FHandle >= 0 then FileClose(FHandle);
end;

{ TkpHugeCustomMemoryStream }

procedure TkpHugeCustomMemoryStream.SetPointer(Ptr: Pointer; Size: LongInt);
begin
  FMemory := Ptr;
  FSize := Size;
end;

function TkpHugeCustomMemoryStream.Read(var Buffer; Count: Longint): Longint;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    Result := FSize - FPosition;
    if Result > 0 then
    begin
      if Result > Count then Result := Count;
      Move(Pointer(Longint(FMemory) + FPosition)^, Buffer, Result);
      Inc(FPosition, Result);
      Exit;
    end;
  end;
  Result := 0;
end;

function TkpHugeCustomMemoryStream.Write(const Buffer; Count: Longint): Longint;
begin
     Result := 0;
end;

function TkpHugeCustomMemoryStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  case Origin of
    soBeginning: FPosition := Offset;
    soCurrent: Inc(FPosition, Offset);
    soEnd: FPosition := FSize + Offset;
  end;
  Result := FPosition;
end;

function TkpHugeCustomMemoryStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: Inc(FPosition, Offset);
    soFromEnd: FPosition := FSize + Offset;
  end;
  Result := FPosition;
end;

procedure TkpHugeCustomMemoryStream.SaveToStream(Stream: TkpHugeStream);
var
  CurrentPosition: Int64;
begin
  if FSize <> 0 then
  begin
     CurrentPosition := Stream.Position;
     If (Stream.Size < FSize) then
        Stream.Size := FSize;
     Stream.Position := 0;
     Stream.WriteBuffer(FMemory^, FSize);
     If (CurrentPosition < Stream.Size) then
      Stream.Position := CurrentPosition
     Else
      Stream.Seek(0,soEnd);
  end;
end;

procedure TkpHugeCustomMemoryStream.SaveToStream(Stream: TStream);
var
  CurrentPosition: LongInt;
begin
  if FSize <> 0 then
  begin
     CurrentPosition := Stream.Position;
     If (Stream.Size < FSize) then
        Stream.Size := FSize;
     Stream.Position := 0;
     Stream.WriteBuffer(FMemory^, FSize);
     If (CurrentPosition < Stream.Size) then
      Stream.Position := CurrentPosition
     Else
      Stream.Seek(0,soFromEnd);
  end;
end;


procedure TkpHugeCustomMemoryStream.SaveToFile(const FileName: string);
var
  Stream: TkpHugeStream;
begin
  Stream := TkpHugeFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

function TkpHugeCustomMemoryStream.GetStream: TStream;
begin
     Result := TMemoryStream.Create;
     SaveToStream(Result);
end;

procedure TkpHugeCustomMemoryStream.GetTStream(stream: TStream);
begin
     SaveToStream(stream);
end;


{ TkpHugeMemoryStream }

const
  MemoryDelta = $2000; { Must be a power of 2 }

destructor TkpHugeMemoryStream.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TkpHugeMemoryStream.Clear;
begin
  SetCapacity(0);
  FSize := 0;
  FPosition := 0;
end;

procedure TkpHugeMemoryStream.LoadFromStream(Stream: TkpHugeStream);
var
  Count: Longint;
begin
  Stream.Position := 0;
  Count := Stream.Size;
  SetSize(Count);
  if Count <> 0 then Stream.ReadBuffer(FMemory^, Count);
end;

procedure TkpHugeMemoryStream.LoadFromFile(const FileName: string);
var
  Stream: TkpHugeStream;
begin
  Stream := TkpHugeFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TkpHugeMemoryStream.SetCapacity(NewCapacity: LongInt);
begin
  SetPointer(Realloc(NewCapacity), FSize);
  FCapacity := NewCapacity;
end;

procedure TkpHugeMemoryStream.SetSize(const NewSize: Int64);
var
  OldPosition: LongInt;
begin
  OldPosition := FPosition;
  SetCapacity(NewSize);
  FSize := NewSize;
  if OldPosition > NewSize then Seek(0, soEnd);
end;

function TkpHugeMemoryStream.Realloc(var NewCapacity: Longint): Pointer;
begin
  if NewCapacity > 0 then
    NewCapacity := (NewCapacity + (MemoryDelta - 1)) and not (MemoryDelta - 1);
  Result := Memory;
  if NewCapacity <> FCapacity then
  begin
    if NewCapacity = 0 then
    begin
      GlobalFreePtr(Memory);
      Result := nil;
    end else
    begin
      if Capacity = 0 then
        Result := GlobalAllocPtr(HeapAllocFlags, NewCapacity)
      else
        Result := GlobalReallocPtr(Memory, NewCapacity, HeapAllocFlags);
      if Result = nil then raise EStreamError.Create(SMemoryStreamError);
    end;
  end;
end;

function TkpHugeMemoryStream.Write(const Buffer; Count: Longint): Longint;
var
  Pos: Longint;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    Pos := FPosition + Count;
    if Pos > 0 then
    begin
      if Pos > FSize then
      begin
        if Pos > FCapacity then
          SetCapacity(Pos);
        FSize := Pos;
      end;
      System.Move(Buffer, Pointer(Longint(FMemory) + FPosition)^, Count);
      FPosition := Pos;
      Result := Count;
      Exit;
    end;
  end;
  Result := 0;
end;

end.
