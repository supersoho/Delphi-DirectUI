{$Q-}
{$R-}
{$T-}

unit uClass;

interface

const
{ TStream seek origins }
  soFromBeginning = 0;
  soFromCurrent = 1;
  soFromEnd = 2;

  fmCreate = $FFFF;
  fmOpenRead       = $0000;
  fmOpenWrite      = $0001;
  fmOpenReadWrite  = $0002;
  fmShareCompat    = $0000 platform; // DOS compatibility mode is not portable
  fmShareExclusive = $0010;
  fmShareDenyWrite = $0020;
  fmShareDenyRead  = $0030 platform; // write-only not supported on all platforms
  fmShareDenyNone  = $0040;
  faReadOnly  = $00000001 platform;
  faHidden    = $00000002 platform;
  faSysFile   = $00000004 platform;
  faVolumeID  = $00000008 platform deprecated;  // not used in Win32
  faDirectory = $00000010;
  faArchive   = $00000020 platform;
  faSymLink   = $00000040 platform;
  faAnyFile   = $0000003F;

type
  Int64Rec = packed record
    case Integer of
      0: (Lo, Hi: Cardinal);
      1: (Cardinals: array [0..1] of Cardinal);
      2: (Words: array [0..3] of Word);
      3: (Bytes: array [0..7] of Byte);
  end;


{ TStream seek origins }
  TSeekOrigin = (soBeginning, soCurrent, soEnd);
  TStream = class;

{ TStream abstract class }

  TStream = class(TObject)
  private
    function GetPosition: Int64;
    procedure SetPosition(const Pos: Int64);
    procedure SetSize64(const NewSize: Int64);
  protected
    function GetSize: Int64; virtual;
    procedure SetSize(NewSize: Longint); overload; virtual;
    procedure SetSize(const NewSize: Int64); overload; virtual;
  public
    function Read(var Buffer; Count: Longint): Longint; virtual; abstract;
    function Write(const Buffer; Count: Longint): Longint; virtual; abstract;
    function Seek(Offset: Longint; Origin: Word): Longint; overload; virtual;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; overload; virtual;
    procedure ReadBuffer(var Buffer; Count: Longint);
    procedure WriteBuffer(const Buffer; Count: Longint);
    function CopyFrom(Source: TStream; Count: Int64): Int64;
    procedure WriteResourceHeader(const ResName: string; out FixupInfo: Integer);
    procedure FixupResourceHeader(FixupInfo: Integer);
    procedure ReadResHeader;
    property Position: Int64 read GetPosition write SetPosition;
    property Size: Int64 read GetSize write SetSize64;
  end;

  IStreamPersist = interface
    ['{B8CD12A3-267A-11D4-83DA-00C04F60B2DD}']
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
  end;

{ THandleStream class }

  THandleStream = class(TStream)
  protected
    FHandle: Integer;
    procedure SetSize(NewSize: Longint); override;
    procedure SetSize(const NewSize: Int64); override;
  public
    constructor Create(AHandle: Integer);
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
    property Handle: Integer read FHandle;
  end;

{ TFileStream class }

  TFileStream = class(THandleStream)
  strict private
    FFileName: string;
  public
    constructor Create(const AFileName: string; Mode: Word); overload;
    constructor Create(const AFileName: string; Mode: Word; Rights: Cardinal); overload;
    destructor Destroy; override;
    property FileName: string read FFileName;
  end;

{ TCustomMemoryStream abstract class }

  TCustomMemoryStream = class(TStream)
  private
    FMemory: Pointer;
    FSize, FPosition: Longint;
  protected
    procedure SetPointer(Ptr: Pointer; Size: Longint);
  public
    function Read(var Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    property Memory: Pointer read FMemory;
  end;

{ TMemoryStream }

  TMemoryStream = class(TCustomMemoryStream)
  private
    FCapacity: Longint;
    procedure SetCapacity(NewCapacity: Longint);
  protected
    function Realloc(var NewCapacity: Longint): Pointer; virtual;
    property Capacity: Longint read FCapacity write SetCapacity;
  public
    destructor Destroy; override;
    procedure Clear;
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);
    procedure SetSize(NewSize: Longint); override;
    function Write(const Buffer; Count: Longint): Longint; override;
  end;

function FileExists(const FileName: string): Boolean;

function Min(a, b: Integer): Integer;
function Max(a, b: Integer): Integer;

implementation

uses
  Windows;

function Min(a, b: Integer): Integer;
begin
  if a < b then
    result := a
  else
    result := b;
end;

function Max(a, b: Integer): Integer;
begin
  if a > b then
    result := a
  else
    result := b;
end;

{ File management routines }

function FileExists(const FileName: string): Boolean;
var
  Code: Integer;
begin
  Code := GetFileAttributes(PChar(FileName));
  Result := (Code <> -1) and (FILE_ATTRIBUTE_DIRECTORY and Code = 0);
end;

function FileOpen(const FileName: string; Mode: LongWord): Integer;
{$IFDEF MSWINDOWS}
const
  AccessMode: array[0..2] of LongWord = (
    GENERIC_READ,
    GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of LongWord = (
    0,
    0,
    FILE_SHARE_READ,
    FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  Result := -1;
  if ((Mode and 3) <= fmOpenReadWrite) and
    ((Mode and $F0) <= fmShareDenyNone) then
    Result := Integer(CreateFile(PChar(FileName), AccessMode[Mode and 3],
      ShareMode[(Mode and $F0) shr 4], nil, OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL, 0));
end;
{$ENDIF}
{$IFDEF LINUX}
const
  ShareMode: array[0..fmShareDenyNone shr 4] of Byte = (
    0,        //No share mode specified
    F_WRLCK,  //fmShareExclusive
    F_RDLCK,  //fmShareDenyWrite
    0);       //fmShareDenyNone
var
  FileHandle, Tvar: Integer;
  LockVar: TFlock;
  smode: Byte;
begin
  Result := -1;
  if FileExists(FileName) and
     ((Mode and 3) <= fmOpenReadWrite) and
     ((Mode and $F0) <= fmShareDenyNone) then
  begin
    FileHandle := open(PChar(FileName), (Mode and 3), FileAccessRights);

    if FileHandle = -1 then  Exit;

    smode := Mode and $F0 shr 4;
    if ShareMode[smode] <> 0 then
    begin
      with LockVar do
      begin
        l_whence := SEEK_SET;
        l_start := 0;
        l_len := 0;
        l_type := ShareMode[smode];
      end;
      Tvar :=  fcntl(FileHandle, F_SETLK, LockVar);
      if Tvar = -1 then
      begin
        __close(FileHandle);
        Exit;
      end;
    end;
    Result := FileHandle;
  end;
end;
{$ENDIF}

function FileCreate(const FileName: string): Integer; overload;
{$IFDEF MSWINDOWS}
begin
  Result := Integer(CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE,
    0, nil, CREATE_ALWAYS, FILE_ATTRIBUTE_NORMAL, 0));
end;
{$ENDIF}
{$IFDEF LINUX}
begin
  Result := FileCreate(FileName, FileAccessRights);
end;
{$ENDIF}

function FileCreate(const FileName: string; Rights: Integer): Integer; overload
{$IFDEF MSWINDOWS}
begin
  Result := FileCreate(FileName);
end;
{$ENDIF}
{$IFDEF LINUX}
begin
  Result := Integer(open(PChar(FileName), O_RDWR or O_CREAT or O_TRUNC, Rights));
end;
{$ENDIF}

function FileRead(Handle: Integer; var Buffer; Count: LongWord): Integer;
begin
{$IFDEF MSWINDOWS}
  if not ReadFile(THandle(Handle), Buffer, Count, LongWord(Result), nil) then
    Result := -1;
{$ENDIF}
{$IFDEF LINUX}
  Result := __read(Handle, Buffer, Count);
{$ENDIF}
end;

function FileWrite(Handle: Integer; const Buffer; Count: LongWord): Integer;
begin
{$IFDEF MSWINDOWS}
  if not WriteFile(THandle(Handle), Buffer, Count, LongWord(Result), nil) then
    Result := -1;
{$ENDIF}
{$IFDEF LINUX}
  Result := __write(Handle, Buffer, Count);
{$ENDIF}
end;

function FileSeek(Handle, Offset, Origin: Integer): Integer; overload;
begin
{$IFDEF MSWINDOWS}
  Result := SetFilePointer(THandle(Handle), Offset, nil, Origin);
{$ENDIF}
{$IFDEF LINUX}
  Result := __lseek(Handle, Offset, Origin);
{$ENDIF}
end;

function FileSeek(Handle: Integer; const Offset: Int64; Origin: Integer): Int64; overload;
{$IFDEF MSWINDOWS}
begin
  Result := Offset;
  Int64Rec(Result).Lo := SetFilePointer(THandle(Handle), Int64Rec(Result).Lo,
    @Int64Rec(Result).Hi, Origin);
  if (Int64Rec(Result).Lo = $FFFFFFFF) and (GetLastError <> 0) then
    Int64Rec(Result).Hi := $FFFFFFFF;
end;
{$ENDIF}
{$IFDEF LINUX}
var
  Temp: Integer;
begin
  Temp := Offset;  // allow for range-checking
  Result := FileSeek(Handle, Temp, Origin);
end;
{$ENDIF}

procedure FileClose(Handle: Integer);
begin
{$IFDEF MSWINDOWS}
  CloseHandle(THandle(Handle));
{$ENDIF}
{$IFDEF LINUX}
  __close(Handle); // No need to unlock since all locks are released on close.
{$ENDIF}
end;

function Win32Check(RetVal: BOOL): BOOL;
begin
  if not RetVal then Raise TObject.Create;
  Result := RetVal;
end;

{ TStream }

function TStream.GetPosition: Int64;
begin
  Result := Seek(0, soCurrent);
end;

procedure TStream.SetPosition(const Pos: Int64);
begin
  Seek(Pos, soBeginning);
end;

function TStream.GetSize: Int64;
var
  Pos: Int64;
begin
  Pos := Seek(0, soCurrent);
  Result := Seek(0, soEnd);
  Seek(Pos, soBeginning);
end;

procedure TStream.SetSize(NewSize: Longint);
begin
  // default = do nothing  (read-only streams, etc)
  // descendents should implement this method to call the Int64 sibling
end;

procedure TStream.SetSize64(const NewSize: Int64);
begin
  SetSize(NewSize);
end;

procedure TStream.SetSize(const NewSize: Int64);
begin
{ For compatibility with old stream implementations, this new 64 bit SetSize
  calls the old 32 bit SetSize.  Descendent classes that override this
  64 bit SetSize MUST NOT call inherited. Descendent classes that implement
  64 bit SetSize should reimplement their 32 bit SetSize to call their 64 bit
  version.}
  if (NewSize < Low(Longint)) or (NewSize > High(Longint)) then
    raise TObject.Create;
  SetSize(Longint(NewSize));
end;

function TStream.Seek(Offset: Longint; Origin: Word): Longint;

  procedure RaiseException;
  begin
    raise TObject.Create;
  end;

type
  TSeek64 = function (const Offset: Int64; Origin: TSeekOrigin): Int64 of object;
var
  Impl: TSeek64;
  Base: TSeek64;
  ClassTStream: TClass;
begin
{ Deflect 32 seek requests to the 64 bit seek, if 64 bit is implemented.
  No existing TStream classes should call this method, since it was originally
  abstract.  Descendent classes MUST implement at least one of either
  the 32 bit or the 64 bit version, and must not call the inherited
  default implementation. }
  Impl := Seek;
  ClassTStream := Self.ClassType;
  while (ClassTStream <> nil) and (ClassTStream <> TStream) do
    ClassTStream := ClassTStream.ClassParent;
  if ClassTStream = nil then RaiseException;
  Base := TStream(@ClassTStream).Seek;
  if TMethod(Impl).Code = TMethod(Base).Code then
    RaiseException;
  Result := Seek(Int64(Offset), TSeekOrigin(Origin));
end;

function TStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
{ Default implementation of 64 bit seek is to deflect to existing 32 bit seek.
  Descendents that override 64 bit seek must not call this default implementation. }
  if (Offset < Low(Longint)) or (Offset > High(Longint)) then
    raise TObject.Create;
  Result := Seek(Longint(Offset), Ord(Origin));
end;

procedure TStream.ReadBuffer(var Buffer; Count: Longint);
begin
  if (Count <> 0) and (Read(Buffer, Count) <> Count) then
    raise TObject.Create;
end;

procedure TStream.WriteBuffer(const Buffer; Count: Longint);
begin
  if (Count <> 0) and (Write(Buffer, Count) <> Count) then
    raise TObject.Create;
end;

function TStream.CopyFrom(Source: TStream; Count: Int64): Int64;
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

function StrLen(const Str: PChar): Cardinal;
asm
  {Check the first byte}
  cmp byte ptr [eax], 0
  je @ZeroLength
  {Get the negative of the string start in edx}
  mov edx, eax
  neg edx
  {Word align}
  add eax, 1
  and eax, -2
@ScanLoop:
  mov cx, [eax]
  add eax, 2
  test cl, ch
  jnz @ScanLoop
  test cl, cl
  jz @ReturnLess2
  test ch, ch
  jnz @ScanLoop
  lea eax, [eax + edx - 1]
  ret
@ReturnLess2:
  lea eax, [eax + edx - 2]
  ret
@ZeroLength:
  xor eax, eax
end;

function StrUpper(Str: PChar): PChar; assembler;
asm
        PUSH    ESI
        MOV     ESI,Str
        MOV     EDX,Str
@@1:    LODSB
        OR      AL,AL
        JE      @@2
        CMP     AL,'a'
        JB      @@1
        CMP     AL,'z'
        JA      @@1
        SUB     AL,20H
        MOV     [ESI-1],AL
        JMP     @@1
@@2:    XCHG    EAX,EDX
        POP     ESI
end;

function StrLCopy(Dest: PChar; const Source: PChar; MaxLen: Cardinal): PChar; assembler;
asm
        PUSH    EDI
        PUSH    ESI
        PUSH    EBX
        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EBX,ECX
        XOR     AL,AL
        TEST    ECX,ECX
        JZ      @@1
        REPNE   SCASB
        JNE     @@1
        INC     ECX
@@1:    SUB     EBX,ECX
        MOV     EDI,ESI
        MOV     ESI,EDX
        MOV     EDX,EDI
        MOV     ECX,EBX
        SHR     ECX,2
        REP     MOVSD
        MOV     ECX,EBX
        AND     ECX,3
        REP     MOVSB
        STOSB
        MOV     EAX,EDX
        POP     EBX
        POP     ESI
        POP     EDI
end;

function StrPLCopy(Dest: PChar; const Source: string;
  MaxLen: Cardinal): PChar;
begin
  Result := StrLCopy(Dest, PChar(Source), MaxLen);
end;

procedure TStream.WriteResourceHeader(const ResName: string; out FixupInfo: Integer);
var
  HeaderSize: Integer;
  Header: array[0..79] of Char;
begin
  Byte((@Header[0])^) := $FF;
  Word((@Header[1])^) := 10;
  HeaderSize := StrLen(StrUpper(StrPLCopy(@Header[3], ResName, 63))) + 10;
  Word((@Header[HeaderSize - 6])^) := $1030;
  Longint((@Header[HeaderSize - 4])^) := 0;
  WriteBuffer(Header, HeaderSize);
  FixupInfo := Position;
end;

procedure TStream.FixupResourceHeader(FixupInfo: Integer);
var
  ImageSize: Integer;
begin
  ImageSize := Position - FixupInfo;
  Position := FixupInfo - 4;
  WriteBuffer(ImageSize, SizeOf(Longint));
  Position := FixupInfo + ImageSize;
end;

procedure TStream.ReadResHeader;
var
  ReadCount: Cardinal;
  Header: array[0..79] of Char;
begin
  FillChar(Header, SizeOf(Header), 0);
  ReadCount := Read(Header, SizeOf(Header) - 1);
  if (Byte((@Header[0])^) = $FF) and (Word((@Header[1])^) = 10) then
    Seek(StrLen(Header + 3) + 10 - ReadCount, 1)
  else
    raise TObject.Create;
end;

{ THandleStream }

constructor THandleStream.Create(AHandle: Integer);
begin
  inherited Create;
  FHandle := AHandle;
end;

function THandleStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := FileRead(FHandle, Buffer, Count);
  if Result = -1 then Result := 0;
end;

function THandleStream.Write(const Buffer; Count: Longint): Longint;
begin
  Result := FileWrite(FHandle, Buffer, Count);
  if Result = -1 then Result := 0;
end;

function THandleStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  Result := FileSeek(FHandle, Offset, Ord(Origin));
end;

procedure THandleStream.SetSize(NewSize: Longint);
begin
  SetSize(Int64(NewSize));
end;

procedure THandleStream.SetSize(const NewSize: Int64);
begin
  Seek(NewSize, soBeginning);
{$IFDEF MSWINDOWS}
  Win32Check(SetEndOfFile(FHandle));
{$ELSE}
  if ftruncate(FHandle, Position) = -1 then
    raise EStreamError(sStreamSetSize);
{$ENDIF}
end;

{ TFileStream }

constructor TFileStream.Create(const AFileName: string; Mode: Word);
begin
{$IFDEF MSWINDOWS}
  Create(AFilename, Mode, 0);
{$ELSE}
  Create(AFilename, Mode, FileAccessRights);
{$ENDIF}
end;

constructor TFileStream.Create(const AFileName: string; Mode: Word; Rights: Cardinal);
begin
  if Mode = fmCreate then
  begin
    inherited Create(FileCreate(AFileName, Rights));
    if FHandle < 0 then
      raise TObject.Create;
  end
  else
  begin
    inherited Create(FileOpen(AFileName, Mode));
    if FHandle < 0 then
      raise TObject.Create;
  end;
  FFileName := AFileName;
end;

destructor TFileStream.Destroy;
begin
  if FHandle >= 0 then FileClose(FHandle);
  inherited Destroy;
end;

{ TCustomMemoryStream }

procedure TCustomMemoryStream.SetPointer(Ptr: Pointer; Size: Longint);
begin
  FMemory := Ptr;
  FSize := Size;
end;

function TCustomMemoryStream.Read(var Buffer; Count: Longint): Longint;
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

function TCustomMemoryStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: Inc(FPosition, Offset);
    soFromEnd: FPosition := FSize + Offset;
  end;
  Result := FPosition;
end;

procedure TCustomMemoryStream.SaveToStream(Stream: TStream);
begin
  if FSize <> 0 then Stream.WriteBuffer(FMemory^, FSize);
end;

procedure TCustomMemoryStream.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

{ TMemoryStream }

const
  MemoryDelta = $2000; { Must be a power of 2 }

destructor TMemoryStream.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TMemoryStream.Clear;
begin
  SetCapacity(0);
  FSize := 0;
  FPosition := 0;
end;

procedure TMemoryStream.LoadFromStream(Stream: TStream);
var
  Count: Longint;
begin
  Stream.Position := 0;
  Count := Stream.Size;
  SetSize(Count);
  if Count <> 0 then Stream.ReadBuffer(FMemory^, Count);
end;

procedure TMemoryStream.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TMemoryStream.SetCapacity(NewCapacity: Longint);
begin
  SetPointer(Realloc(NewCapacity), FSize);
  FCapacity := NewCapacity;
end;

procedure TMemoryStream.SetSize(NewSize: Longint);
var
  OldPosition: Longint;
begin
  OldPosition := FPosition;
  SetCapacity(NewSize);
  FSize := NewSize;
  if OldPosition > NewSize then Seek(0, soFromEnd);
end;

function TMemoryStream.Realloc(var NewCapacity: Longint): Pointer;
begin
  if (NewCapacity > 0) and (NewCapacity <> FSize) then
    NewCapacity := (NewCapacity + (MemoryDelta - 1)) and not (MemoryDelta - 1);
  Result := Memory;
  if NewCapacity <> FCapacity then
  begin
    if NewCapacity = 0 then
    begin
      FreeMem(Memory);
      Result := nil;
    end else
    begin
      if Capacity = 0 then
        GetMem(Result, NewCapacity)
      else
        ReallocMem(Result, NewCapacity);
      if Result = nil then raise TObject.Create;
    end;
  end;
end;

function TMemoryStream.Write(const Buffer; Count: Longint): Longint;
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

