{$Q-}
{$R-}
{$T-}

unit UBufferedFS;

interface

uses uClass;

const BufferSize=$10000;//64K

type TBFSMode=(BFMRead,BFMWrite);

     TBufferedFS=class(TFileStream)
       private
         membuffer:array [0..BufferSize-1] of byte;
         bytesinbuffer:integer;
         bufferpos:integer;
         bufferdirty:boolean;
         Mode:TBFSMode;
         procedure Init;
         procedure Flush;
         procedure ReadBuffer;
       public
         constructor Create(const FileName: string; Mode: Word); overload;
         constructor Create(const FileName: string; Mode: Word; Rights: Cardinal); overload;
         destructor Destroy; override;
         function Read(var Buffer; Count: Longint): Longint; override;
         function Write(const Buffer; Count: Longint): Longint; override;
         function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; override;
       end;

type TByteArray = array of byte;
     PByteArray = ^TByteArray;

implementation

function MovePointer(const P:pointer;const dist:integer):pointer;
begin
result:=pointer(integer(p)+dist);
end;

procedure TBufferedFS.Init;
begin
bytesinbuffer:=0;
bufferpos:=0;
bufferdirty:=false;
mode:=BFMWrite;
end;

procedure TBufferedFS.Flush;
begin
if bufferdirty then
   inherited Write(membuffer[0],bufferpos);
bufferdirty:=false;
bytesinbuffer:=0;
bufferpos:=0;
end;

constructor TBufferedFS.Create(const FileName: string; Mode: Word);
begin
inherited;
init;
end;

constructor TBufferedFS.Create(const FileName: string; Mode: Word; Rights: Cardinal);
begin
inherited;
init;
end;

destructor TBufferedFS.Destroy;
begin
flush;
inherited;
end;

procedure TBufferedFS.ReadBuffer;
begin
flush;
bytesinbuffer:=inherited Read(membuffer,buffersize);
bufferpos:=0;
end;

function TBufferedFS.Read(var Buffer; Count: Longint): Longint;
var p:PByteArray;
    bytestoread:integer;
    b:integer;
begin
if Mode=BFMWrite then flush;
mode:=BFMRead;
result:=0;
if count<=bytesinbuffer then begin
   //all data already in buffer
   move(membuffer[bufferpos],buffer,count);
   bytesinbuffer:=bytesinbuffer-count;
   bufferpos:=bufferpos+count;
   result:=count;
   end else begin
       bytestoread:=count;
       if (bytestoread<>0)and(bytesinbuffer<>0) then begin
          //read data remaining in buffer and increment data pointer
          b:=Read(buffer,bytesinbuffer);
          p:=PByteArray(@(TByteArray(buffer)[b]));
          bytestoread:=bytestoread-b;
          result:=b;
          end else p:=@buffer;
       if bytestoread>=BufferSize then begin
          //data to read is larger than the buffer, read it directly
          result:=result+inherited Read(p^,bytestoread);
          end else begin
              //refill buffer
              ReadBuffer;
              //recurse
              result:=result+Read(p^,Min(bytestoread,bytesinbuffer));
              end;
       end;
end;

function TBufferedFS.Write(const Buffer; Count: Longint): Longint;
var p:pointer;
    bytestowrite:integer;
    b:integer;
begin
if mode=BFMRead then begin
   seek(-BufferSize+bufferpos,soFromCurrent);
   bytesinbuffer:=0;
   bufferpos:=0;
   end;
mode:=BFMWrite;
result:=0;
if count<=BufferSize-bytesinbuffer then begin
   //all data fits in buffer
   bufferdirty:=true;
   move(buffer,membuffer[bufferpos],count);
   bytesinbuffer:=bytesinbuffer+count;
   bufferpos:=bufferpos+count;
   result:=count;
   end else begin
       bytestowrite:=count;
       if (bytestowrite<>0)and(bytesinbuffer<>BufferSize)and(bytesinbuffer<>0) then begin
          //write data to remaining space in buffer and increment data pointer
          b:=Write(buffer,BufferSize-bytesinbuffer);
          p:=MovePointer(@buffer,b);
          bytestowrite:=bytestowrite-b;
          result:=b;
          end else p:=@buffer;
       if bytestowrite>=BufferSize then begin
          //empty buffer
          Flush;
          //data to write is larger than the buffer, write it directly
          result:=result+inherited Write(p^,bytestowrite);
          end else begin
              //empty buffer
              Flush;
              //recurse
              result:=result+Write(p^,bytestowrite);
              end;
       end;
end;

function TBufferedFS.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
if (Origin=soCurrent)and(Offset=0) then result:=inherited seek(Offset,origin)+bufferpos
   else begin
        flush;
        result:=inherited Seek(offset,origin);
        end;
end;

end.
