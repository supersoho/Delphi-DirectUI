unit GraphicCompression;

// Support unit for GraphicEx.pas
// GraphicCompression contains routines to compress and decompress data using various compression
// methods. Currently supported methods are:
// - LZW (Lempel-Ziff-Welch)
// - RLE (run length encoding)

interface

uses
  Classes;

const // LZW encoding and decoding support
  ClearCode = 256;
  EOICode = 257;

type
  TSmoothRange = 0..4;

  PByte = ^Byte;
  
  TLZWTableEntry = record
    Index: Word;
    Prefix: Word;
    Suffix,
    FirstByte: Byte;
  end;

  PCluster = ^TCluster;
  TCluster = record
    Index: Word;
    Next: PCluster;
  end;

  TByteStream = array[0..0] of Byte;
  PByteStream = ^TByteStream;

  // Lempel/Ziff/Welch encoder/decoder class
  TLZW = class(TObject)
  private
    FCodeAddress,
    FDestination: PByte;
    FCodeLength,
    FBorrowedBits: Byte;
    FCode,
    FOldCode,
    FLastEntry: Word;
    FBytesRead: Cardinal;
    FLZWTable:  array[0..4095] of TLZWTableEntry;
    FClusters: array[0..4095] of PCluster;
    function GetNextCode: Word;
    procedure Initialize;
    procedure ReleaseClusters;
    procedure WriteBytes(Entry: TLZWTableEntry);
    procedure AddEntry(Entry: TLZWTableEntry);
    function Concatenation(PPrefix: Word; LastByte: Byte; Index: Word): TLZWTableEntry;
    procedure AddTableEntry(Entry: TLZWTableEntry);
    procedure WriteCodeToStream(Code: Word);
    function CodeFromString(Str: TLZWTableEntry): Word;
  public
    procedure DecodeLZW(Source, Dest: Pointer);
    procedure EncodeLZW(Source, Dest: Pointer; var FByteCounts: Cardinal);
    procedure SmoothEncodeLZW(Source, Dest: Pointer; SmoothRange: TSmoothRange; var FByteCounts: Cardinal);
  end;

function DecodeRLE(const Source, Target: Pointer; Count, ColorDepth: Cardinal): Integer;
function EncodeRLE(const Source, Target: Pointer; Count, BPP: Integer): Integer;

//----------------------------------------------------------------------------------------------------------------------

implementation

//----------------- LZW encoder/decoder helper class -------------------------------------------------------------------

function TLZW.Concatenation(PPrefix: Word; LastByte: Byte; Index: Word): TLZWTableEntry;

begin
  if PPrefix = ClearCode then
  begin
    Result.Index := LastByte;
    Result.FirstByte := LastByte;
    Result.Prefix := PPrefix;
    Result.Suffix := LastByte;
  end
  else
  begin
    Result.Index := Index;
    Result.FirstByte := FLZWTable[PPrefix].FirstByte;
    Result.Prefix := FLZWTable[PPrefix].Index;
    Result.Suffix := LastByte;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TLZW.Initialize;

var
  I: Word;

begin
  for I := 0 to 255 do
    with FLZWTable[I] do
    begin
      Index := I;
      Prefix := 256;
      Suffix := I;
      FirstByte := I;
    end;

  with FLZWTable[256] do
  begin
    Index := 256;
    Prefix := 256;
    Suffix := 0;
    FirstByte := 0;
  end;

  with FLZWTable[257] do
  begin
    Index := 257;
    Prefix := 256;
    Suffix := 0;
    FirstByte := 0;
  end;

  for I := 258 to 4095 do
    with FLZWTable[I] do
    begin
      Index := I;
      Prefix := 256;
      Suffix := 0;
      FirstByte := 0;
    end;
    
  FLastEntry := 257;
  FCodeLength := 9;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TLZW.ReleaseClusters;

var
  I: Word;
  WorkCluster: PCluster;
  
begin
  for I := 0 to 4095 do
  begin
    while Assigned(FClusters[I]) do
    begin
      WorkCluster := FClusters[I];
      FClusters[I] := FClusters[I].Next;
      Dispose(WorkCluster);
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TLZW.WriteBytes(Entry: TLZWTableEntry);

begin
  if Entry.Prefix = ClearCode then
  begin
    FDestination^ := Entry.Suffix;
    Inc(FDestination);
  end
  else
  begin
    WriteBytes(FLZWTable[Entry.Prefix]);
    FDestination^ := Entry.Suffix;
    Inc(FDestination);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TLZW.AddEntry(Entry: TLZWTableEntry);

begin
  FLZWTable[Entry.Index] := Entry;
  FLastEntry := Entry.Index;
  case FLastEntry of
    510,
    1022,
    2046:
      Inc(FCodeLength);
    4093:
      FCodeLength := 9;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function TLZW.GetNextCode: Word; assembler;

// EAX contains self reference

asm
                   PUSH EBX
                   PUSH ESI
                   MOV ESI, EAX        // keep self reference for further access
                   MOV EBX, [ESI.FCodeAddress]
                   MOV CH, 16
                   ADD CH, [ESI.FBorrowedBits]
                   SUB CH, [ESI.FCodeLength]
                   CMP CH, 8
                   JG @@TwoBytes
                   JMP @@ThreeBytes

   @@TwoBytes:     MOV AH, [EBX]
                   MOV AL, [EBX + 1]
                   MOV CL, 8
                   SUB CL, [ESI.FBorrowedBits]
                   SHL AH, CL
                   SHR AH, CL
                   MOV CL, [ESI.FBorrowedBits]
                   ADD CL, 8
                   SUB CL, [ESI.FCodeLength]
                   SHR AL, CL
                   SHL AL, CL
                   SHR AX, CL
                   MOV [ESI.FBorrowedBits], CL
                   INC [ESI.FCodeAddress]
                   JMP @@Finished

   @@ThreeBytes:   MOV AH, [EBX]
                   MOV AL, [EBX + 1]
                   MOV DL, [EBX + 2]
                   MOV CL, 8
                   SUB CL, [ESI.FBorrowedBits]
                   SHL AX, CL
                   SHR AX, CL
                   MOV CL, CH
                   SHR DL, CL
                   MOV CH, 8
                   SUB CH, CL
                   XCHG CL, CH
                   SHL AX, CL
                   XOR DH, DH
                   OR AX, DX
                   MOV [ESI.FBorrowedBits], CH
                   ADD [ESI.FCodeAddress], 2
   @@Finished:     // AX already contains Result
                   POP ESI
                   POP EBX
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TLZW.DecodeLZW(Source, Dest: Pointer);

begin
  FDestination := Dest;
  FBorrowedBits := 8;
  FCodeLength := 9;
  FBytesRead := 0;
  FCodeAddress := Source;
  Initialize;
  FOldCode := 256;
  FCode := GetNextCode;
  while FCode <> EOICode do
  begin
    if FCode = ClearCode then
    begin
      Initialize;
      FCode := GetNextCode;
      if FCode = EOICode then Break;
      WriteBytes(FLZWTable[FCode]);
      FOldCode := FCode;
    end
    else
    begin
      if FCode<=FLastEntry then
      begin
        WriteBytes(FLZWTable[FCode]);
        AddEntry(Concatenation(FOldCode, FLZWTable[FCode].FirstByte, FLastEntry + 1));
        FOldCode := FCode;
      end
      else
      begin
          if FCode > (FLastEntry + 1) then Break
                                      else
          begin
            WriteBytes(Concatenation(FOldCode, FLZWTable[FOldCode].FirstByte, FLastEntry + 1));
            AddEntry(Concatenation(FOldCode, FLZWTable[FOldCode].FirstByte, FLastEntry + 1));
            FOldCode := FCode;
          end;
      end;
    end;
    FCode := GetNextCode;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TLZW.WriteCodeToStream(Code: Word); assembler;

// EAX contains Self reference and DX Code 

asm
                   PUSH EBX
                   PUSH ESI
                   MOV ESI, EAX
                   MOV AX, DX
                   MOV CH, [ESI.FCodeLength]
                   SUB CH, [ESI.FBorrowedBits]
                   CMP CH, 8
                   JGE @@ThreeBytes
                   JMP @@TwoBytes

     @@TwoBytes:   MOV EBX, [ESI.FDestination]
                   MOV CL,8
                   ADD CL, [ESI.FBorrowedBits]
                   SUB CL, [ESI.FCodeLength]
                   SHL AX, CL
                   OR [EBX],AH
                   INC EBX
                   OR [EBX], AL
                   MOV [ESI.FDestination], EBX
                   MOV [ESI.FBorrowedBits], CL
                   JMP @@Finished

     @@ThreeBytes: MOV EBX, [ESI.FDestination]
                   MOV DX, AX
                   MOV CL, [ESI.FCodeLength]
                   SUB CL, 8
                   SUB CL, [ESI.FBorrowedBits]
                   SHR AX, CL
                   SHL AX, CL
                   SUB DX, AX
                   SHR AX, CL
                   OR [EBX],AH
                   INC EBX
                   OR [EBX],AL
                   INC EBX
                   MOV CH, 8
                   SUB CH, CL
                   XCHG CH, CL
                   SHL DL, CL
                   OR [EBX],DL
                   MOV [ESI.FDestination], EBX
                   MOV [ESI.FBorrowedBits], CL
     @@Finished:   POP ESI
                   POP EBX
end;

//----------------------------------------------------------------------------------------------------------------------

function TLZW.CodeFromString(Str: TLZWTableEntry): Word;

var
  WorkCluster: PCluster;
  
begin
  if Str.Prefix = 256 then Result := Str.Index
                      else
  begin
    WorkCluster := FClusters[Str.Prefix];
    if WorkCluster = nil then Result := 4095
                         else
    begin
      while Assigned(WorkCluster.Next) do
        if Str.Suffix <> FLZWTable[WorkCluster.Index].Suffix then WorkCluster := WorkCluster.Next
                                                             else Break;
      if Str.Suffix = FLZWTable[WorkCluster.Index].Suffix then Result := WorkCluster.Index
                                                          else Result := 4095;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TLZW.AddTableEntry(Entry: TLZWTableEntry);

var
  WorkCluster: PCluster;

begin
  FLZWTable[Entry.Index] := Entry;
  FLastEntry := Entry.Index;
  if FClusters[FLZWTable[FLastEntry].Prefix] = nil then
  begin
    New(FClusters[FLZWTable[FLastEntry].Prefix]);
    FClusters[FLZWTable[FLastEntry].Prefix].Index := FLastEntry;
    FClusters[FLZWTable[FLastEntry].Prefix].Next := nil;
  end
  else
  begin
    WorkCluster := FClusters[FLZWTable[FLastEntry].Prefix];
    while Assigned(WorkCluster.Next) do WorkCluster := WorkCluster.Next;
    New(WorkCluster.Next);
    WorkCluster.Next.Index := FLastEntry;
    WorkCluster.Next.Next := nil;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TLZW.EncodeLZW(Source, Dest: Pointer; var FByteCounts: Cardinal);

var
  vPrefix,
  CurrEntry: TLZWTableEntry;
  CurrCode: Word;
  I: Integer;
  Stream: PByteStream;

begin
  FDestination := Dest;
  Initialize;
  ReleaseClusters;
  FBorrowedBits := 8;
  WriteCodeToStream(ClearCode);
  FCodeAddress := Source;
  Stream := Source;
  FBytesRead := 0;
  vPrefix := FLZWTable[ClearCode];
  for I := 0 to  FByteCounts - 1 do
  begin
    CurrEntry := Concatenation(vPrefix.Index, Stream[I], FLastEntry + 1);
    CurrCode := CodeFromString(CurrEntry);
    if CurrCode <= FLastEntry then vPrefix := FLZWTable[CurrCode]
                              else
    begin
      WriteCodeToStream(vPrefix.Index);
      AddTableEntry(CurrEntry);
      vPrefix := FLZWTable[Stream[I]];
      case FLastEntry of
        511,
        1023,
        2047:
          Inc(FCodeLength);
        4093:
          begin
            WriteCodeToStream(ClearCode);
            FCodeLength := 9;
            ReleaseClusters;
            FLastEntry := EOICode;
         end;
      end;
    end;
  end;
  WriteCodeToStream(CodeFromString(vPrefix));
  WriteCodeToStream(EOICode);
  ReleaseClusters;
  FByteCounts := 1 + Cardinal(FDestination) - Cardinal(Dest);
end;

//----------------------------------------------------------------------------------------------------------------------

procedure TLZW.SmoothEncodeLZW(Source, Dest: Pointer; SmoothRange: TSmoothRange; var FByteCounts: Cardinal);

var
  CByte,
  ByteMask: Byte;
  vPrefix,
  CurrEntry: TLZWTableEntry;
  CurrCode: Word;
  I: Integer;
  Stream: PByteStream;

begin
  ByteMask := ($FF shr SmoothRange) shl SmoothRange;
  FDestination := Dest;
  Initialize;
  ReleaseClusters;
  FBorrowedBits := 8;
  WriteCodeToStream(ClearCode);
  FCodeAddress := Source;
  Stream := Source;
  FBytesRead := 0;
  vPrefix := FLZWTable[ClearCode];
  for I := 0 to  FByteCounts - 1 do
  begin
    CByte := Stream[I] and ByteMask;
    CurrEntry := Concatenation(vPrefix.Index, CByte, FLastEntry + 1);
    CurrCode := CodeFromString(CurrEntry);
    if CurrCode <= FLastEntry then vPrefix := FLZWTable[CurrCode]
                              else
    begin
      WriteCodeToStream(vPrefix.Index);
      AddTableEntry(CurrEntry);
      vPrefix := FLZWTable[CByte];
      case FLastEntry of
        511,
        1023,
        2047:
          Inc(FCodeLength);
        4093:
          begin
            WriteCodeToStream(ClearCode);
            FCodeLength := 9;
            ReleaseClusters;
            FLastEntry := EOICode;
         end;
      end;
    end;
  end;
  WriteCodeToStream(CodeFromString(vPrefix));
  WriteCodeToStream(EOICode);
  ReleaseClusters;
  FByteCounts := 1 + Cardinal(FDestination) - Cardinal(Dest);
end;

//----------------------------------------------------------------------------------------------------------------------

function DecodeRLE(const Source, Target: Pointer; Count, ColorDepth: Cardinal): Integer;

// Decodes RLE compressed data from Source into Target. Count determines size of target buffer and ColorDepth
// the size of one data entry.
// Result is the amount of bytes decoded.

var 
  I: Integer;
  SourcePtr,
  TargetPtr: PByte;
  RunLength: Cardinal;
  Counter: Cardinal;

begin
  Result := 0;
  Counter := 0;
  TargetPtr := Target;
  SourcePtr := Source;
  // unrolled decoder loop to speed up process
  case ColorDepth of
    8:
      while Counter < Count do
      begin
        RunLength := 1 + (SourcePtr^ and $7F);
        if SourcePtr^ > $7F then
        begin
          Inc(SourcePtr);
          for I := 0 to RunLength - 1 do
          begin
            TargetPtr^ := SourcePtr^;
            Inc(TargetPtr);
          end;
          Inc(SourcePtr);
          Inc(Result, 2);
        end
        else
        begin
          Inc(SourcePtr);
          for I := 0 to RunLength - 1 do
          begin
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
          end;
          Inc(Result, RunLength + 1)
        end;
        Inc(Counter, RunLength);
      end;
    15,
    16:
      while Counter < Count do
      begin
        RunLength := 1 + (SourcePtr^ and $7F);
        if SourcePtr^ > $7F then
        begin
          Inc(SourcePtr);
          for I := 0 to RunLength - 1 do
          begin
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
            TargetPtr^ := SourcePtr^;
            Dec(SourcePtr);
            Inc(TargetPtr);
          end;
          Inc(SourcePtr, 2);
          Inc(Result, 3);
        end
        else
        begin
          Inc(SourcePtr);
          for I := 0 to RunLength - 1 do
          begin
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
          end;
          Inc(Result, RunLength * 2 + 1);
        end;
        Inc(Counter, 2 * RunLength);
      end;
    24:
      while Counter < Count do
      begin
        RunLength := 1 + (SourcePtr^ and $7F);
        if SourcePtr^ > $7F then
        begin
          Inc(SourcePtr);
          for I := 0 to RunLength - 1 do
          begin
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
            TargetPtr^ := SourcePtr^;
            Dec(SourcePtr, 2);
            Inc(TargetPtr);
          end;
          Inc(SourcePtr, 3);
          Inc(Result, 4);
        end
        else
        begin
          Inc(SourcePtr);
          for I := 0 to RunLength - 1 do
          begin
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
          end;
          Inc(Result, RunLength * 3 + 1);
        end;
        Inc(Counter, 3 * RunLength);
      end;
    32:
      while Counter < Count do
      begin
        RunLength := 1 + (SourcePtr^ and $7F);
        if SourcePtr^ > $7F then
        begin
          Inc(SourcePtr);
          for I := 0 to RunLength - 1 do
          begin
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
            TargetPtr^ := SourcePtr^;
            Dec(SourcePtr, 3);
            Inc(TargetPtr);
          end;
          Inc(SourcePtr, 4);
          Inc(Result, 5);
        end
        else
        begin
          Inc(SourcePtr);
          for I := 0 to RunLength - 1 do
          begin
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
            TargetPtr^ := SourcePtr^;
            Inc(SourcePtr);
            Inc(TargetPtr);
          end;
          Inc(Result,RunLength * 4 + 1);
        end;
        Inc(Counter, 4 * RunLength);
      end;
    end;
end;

//----------------------------------------------------------------------------------------------------------------------

function GetPixel(P: PByte; BPP: Byte): Cardinal;

// Retrieves a pixel value from a buffer. The actual size and order of the bytes is not important
// since we are only using the value for comparisons with other pixels.

begin
  Result := P^;
  Inc(P);
  Dec(BPP);
  while BPP > 0 do
  begin
    Result := Result shl 8;
    Result := Result or P^;
    Inc(P);
    Dec(BPP);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function CountDiffPixels(P: PByte; BPP: Byte; Count: Integer): Integer;

// counts pixels in buffer until two identical adjacent ones found

var
  N: Integer;
  Pixel,
  NextPixel: Cardinal;

begin
  N := 0;
  NextPixel := 0; // shut up compiler
  if Count = 1 then Result := Count
               else
  begin
    Pixel := GetPixel(P, BPP);
    while Count > 1 do
    begin
      Inc(P, BPP);
      NextPixel := GetPixel(P, BPP);
      if NextPixel = Pixel then Break;
      Pixel := NextPixel;
      Inc(N);
      Dec(Count);
    end;
    if NextPixel = Pixel then Result := N
                         else Result := N + 1;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function CountSamePixels(P: PByte; BPP: Byte; Count: Integer): Integer;

var
  Pixel,
  NextPixel: Cardinal;

begin
  Result := 1;
  Pixel := GetPixel(P, BPP);
  Dec(Count);
  while Count > 0 do
  begin
    Inc(P, BPP);
    NextPixel := GetPixel(P, BPP);
    if NextPixel <> Pixel then Break;
    Inc(Result);
    Dec(Count);
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

function EncodeRLE(const Source, Target: Pointer; Count, BPP: Integer): Integer;

// Encodes "Count" bytes pointed to by Source into the buffer supplied with Target and returns the
// number of bytes stored in Target. BPP denotes bytes per pixel color depth.
// Note: The target buffer must provide enough space to hold the compressed data. Using a size of
//       twice the size of the input buffer is sufficent.

var
  DiffCount, // pixel count until two identical
  SameCount: Integer; // number of identical adjacent pixels
  SourcePtr,
  TargetPtr: PByte;

begin
  Result := 0;
  SourcePtr := Source;
  TargetPtr := Target;
  while Count > 0 do
  begin
    DiffCount := CountDiffPixels(SourcePtr, BPP, Count);
    SameCount := CountSamePixels(SourcePtr, BPP, Count);
    if DiffCount > 128 then DiffCount := 128;
    if SameCount > 128  then SameCount := 128;

    if DiffCount > 0 then
    begin
      // create a raw packet
      TargetPtr^ := DiffCount - 1; Inc(TargetPtr);
      Dec(Count, DiffCount);
      Inc(Result, (DiffCount * BPP) + 1);
      while DiffCount > 0 do
      begin
        TargetPtr^ := SourcePtr^; Inc(SourcePtr); Inc(TargetPtr);
        if BPP > 1 then begin TargetPtr^ := SourcePtr^; Inc(SourcePtr); Inc(TargetPtr); end;
        if BPP > 2 then begin TargetPtr^ := SourcePtr^; Inc(SourcePtr); Inc(TargetPtr); end;
        if BPP > 3 then begin TargetPtr^ := SourcePtr^; Inc(SourcePtr); Inc(TargetPtr); end;
        Dec(DiffCount);
      end;
    end;

    if SameCount > 1 then
    begin
      // create a RLE packet
      TargetPtr^ := (SameCount - 1) or $80; Inc(TargetPtr);
      Dec(Count, SameCount);
      Inc(Result, BPP + 1);
      Inc(SourcePtr, (SameCount - 1) * BPP);
      TargetPtr^ := SourcePtr^; Inc(SourcePtr); Inc(TargetPtr);
      if BPP > 1 then begin TargetPtr^ := SourcePtr^; Inc(SourcePtr); Inc(TargetPtr); end;
      if BPP > 2 then begin TargetPtr^ := SourcePtr^; Inc(SourcePtr); Inc(TargetPtr); end;
      if BPP > 3 then begin TargetPtr^ := SourcePtr^; Inc(SourcePtr); Inc(TargetPtr); end;
    end;
  end;
end;

//----------------------------------------------------------------------------------------------------------------------

end.

