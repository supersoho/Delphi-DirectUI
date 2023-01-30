unit HardwareID;

interface

uses
  Windows, SysUtils, WinSock, NB30;

Const
  MAX_HOSTNAME_LEN = 128; { from IPTYPES.H }
  MAX_DOMAIN_NAME_LEN = 128;
  MAX_SCOPE_ID_LEN = 256;
  MAX_ADAPTER_NAME_LENGTH = 256;
  MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
  MAX_ADAPTER_ADDRESS_LENGTH = 8;

type
  TIPAddressString = Array [0 .. 4 * 4 - 1] of Char;

  PIPAddrString = ^TIPAddrString;

  TIPAddrString = Record
    Next: PIPAddrString;
    IPAddress: TIPAddressString;
    IPMask: TIPAddressString;
    Context: Integer;
  End;

  PFixedInfo = ^TFixedInfo;

  TFixedInfo = Record { FIXED_INFO }
    HostName: Array [0 .. MAX_HOSTNAME_LEN + 3] of Char;
    DomainName: Array [0 .. MAX_DOMAIN_NAME_LEN + 3] of Char;
    CurrentDNSServer: PIPAddrString;
    DNSServerList: TIPAddrString;
    NodeType: Integer;
    ScopeId: Array [0 .. MAX_SCOPE_ID_LEN + 3] of Char;
    EnableRouting: Integer;
    EnableProxy: Integer;
    EnableDNS: Integer;
  End;

  PIPAdapterInfo = ^TIPAdapterInfo;

  TIPAdapterInfo = Record { IP_ADAPTER_INFO }
    Next: PIPAdapterInfo;
    ComboIndex: Integer;
    AdapterName: Array [0 .. MAX_ADAPTER_NAME_LENGTH + 3] of Char;
    Description: Array [0 .. MAX_ADAPTER_DESCRIPTION_LENGTH + 3] of Char;
    AddressLength: Integer;
    Address: Array [1 .. MAX_ADAPTER_ADDRESS_LENGTH] of Byte;
    Index: Integer;
    _Type: Integer;
    DHCPEnabled: Integer;
    CurrentIPAddress: PIPAddrString;
    IPAddressList: TIPAddrString;
    GatewayList: TIPAddrString;
    DHCPServer: TIPAddrString;
    HaveWINS: Bool;
    PrimaryWINSServer: TIPAddrString;
    SecondaryWINSServer: TIPAddrString;
    LeaseObtained: Integer;
    LeaseExpires: Integer;
  End;

  TCPUID = array [1 .. 4] of Longint;
  TVendor = array [0 .. 11] of Char;

  TSrbIoControl = packed record
    HeaderLength: ULONG;
    Signature: Array [0 .. 7] of Char;
    Timeout: ULONG;
    ControlCode: ULONG;
    ReturnCode: ULONG;
    Length: ULONG;
  end;

  SRB_IO_CONTROL = TSrbIoControl;
  PSrbIoControl = ^TSrbIoControl;

  TIDERegs = packed record
    bFeaturesReg: Byte; // Used for specifying SMART "commands".
    bSectorCountReg: Byte; // IDE sector count register
    bSectorNumberReg: Byte; // IDE sector number register
    bCylLowReg: Byte; // IDE low order cylinder value
    bCylHighReg: Byte; // IDE high order cylinder value
    bDriveHeadReg: Byte; // IDE drive/head register
    bCommandReg: Byte; // Actual IDE command.
    bReserved: Byte; // reserved.  Must be zero.
  end;

  IDEREGS = TIDERegs;
  PIDERegs = ^TIDERegs;

  TSendCmdInParams = packed record
    cBufferSize: DWORD;
    irDriveRegs: TIDERegs;
    bDriveNumber: Byte;
    bReserved: Array [0 .. 2] of Byte;
    dwReserved: Array [0 .. 3] of DWORD;
    bBuffer: Array [0 .. 0] of Byte;
  end;

  SENDCMDINPARAMS = TSendCmdInParams;
  PSendCmdInParams = ^TSendCmdInParams;

  TIdSector = packed record
    wGenConfig: Word;
    wNumCyls: Word;
    wReserved: Word;
    wNumHeads: Word;
    wBytesPerTrack: Word;
    wBytesPerSector: Word;
    wSectorsPerTrack: Word;
    wVendorUnique: Array [0 .. 2] of Word;
    sSerialNumber: Array [0 .. 19] of Char;
    wBufferType: Word;
    wBufferSize: Word;
    wECCSize: Word;
    sFirmwareRev: Array [0 .. 7] of Char;
    sModelNumber: Array [0 .. 39] of Char;
    wMoreVendorUnique: Word;
    wDoubleWordIO: Word;
    wCapabilities: Word;
    wReserved1: Word;
    wPIOTiming: Word;
    wDMATiming: Word;
    wBS: Word;
    wNumCurrentCyls: Word;
    wNumCurrentHeads: Word;
    wNumCurrentSectorsPerTrack: Word;
    ulCurrentSectorCapacity: ULONG;
    wMultSectorStuff: Word;
    ulTotalAddressableSectors: ULONG;
    wSingleWordDMA: Word;
    wMultiWordDMA: Word;
    bReserved: Array [0 .. 127] of Byte;
  end;

  PIdSector = ^TIdSector;

function IsCPUID_Available: Boolean; register;
function GetCPUID: TCPUID; assembler; register;
function GetCPUVendor: TVendor; assembler; register;
function GetIdeDiskSerialNumber: String;
function GetNetBIOSAddress: string;
function GetHDNumber(Drv: String): DWORD; // 得到硬盘序列号
function GetMacNo: String;

const
  ID_BIT = $200000; // EFLAGS ID bit
  IDE_ID_FUNCTION = $EC;
  IDENTIFY_BUFFER_SIZE = 512;
  DFP_RECEIVE_DRIVE_DATA = $0007C088;
  IOCTL_SCSI_MINIPORT = $0004D008;
  IOCTL_SCSI_MINIPORT_IDENTIFY = $001B0501;
  DataSize = sizeof(TSendCmdInParams) - 1 + IDENTIFY_BUFFER_SIZE;
  BufferSize = sizeof(SRB_IO_CONTROL) + DataSize;
  W9xBufferSize = IDENTIFY_BUFFER_SIZE + 16;

implementation

Function GetAdaptersInfo(AI: PIPAdapterInfo; Var BufLen: Integer): Integer;
  StdCall; External 'iphlpapi.dll' Name 'GetAdaptersInfo';

function GetMacNo: String;
Var
  AI, Work: PIPAdapterInfo;
  Size: Integer;
  Res: Integer;
  I: Integer;

  Function MACToStr(ByteArr: PByte; Len: Integer): String;
  Begin
    Result := '';
    While (Len > 0) do
    Begin
      Result := Result + IntToHex(ByteArr^, 2) + '-';
      ByteArr := Pointer(Integer(ByteArr) + sizeof(Byte));
      Dec(Len);
    End;
    SetLength(Result, Length(Result) - 1); { remove last dash }
  End;

  Function GetAddrString(Addr: PIPAddrString): String;
  Begin
    Result := '';
    While (Addr <> nil) do
    Begin
      Result := Result + 'A: ' + Addr^.IPAddress + ' M: ' + Addr^.IPMask + #13;
      Addr := Addr^.Next;
    End;
  End;

begin
  Result := '';

  Size := 5120;
  GetMem(AI, Size);
  Res := GetAdaptersInfo(AI, Size);
  If (Res <> ERROR_SUCCESS) Then
  Begin
    SetLastError(Res);
    RaiseLastWin32Error;
  End;

  Begin
    Work := AI;
    I := 1;
    Repeat
      // Add('');
      // Add('Adapter ' + IntToStr(I));
      // Add(' ComboIndex: ' + IntToStr(Work^.ComboIndex));
      // Add(' Adapter name: ' + Work^.AdapterName);
      // Add(' Description: ' + Work^.Description);
      Result := Result + MACToStr(@Work^.Address, Work^.AddressLength);
      // Add(' Index: ' + IntToStr(Work^.Index));
      // Add(' Type: ' + IntToStr(Work^._Type));
      // Add(' DHCP: ' + IntToStr(Work^.DHCPEnabled));
      // Add(' Current IP: ' + GetAddrString(Work^.CurrentIPAddress));
      // Add(' IP addresses: ' + GetAddrString(@Work^.IPAddressList));
      // Add(' Gateways: ' + GetAddrString(@Work^.GatewayList));
      // Add(' DHCP servers: ' + GetAddrString(@Work^.DHCPServer));
      // Add(' Has WINS: ' + IntToStr(Integer(Work^.HaveWINS)));
      // Add(' Primary WINS: ' + GetAddrString(@Work^.PrimaryWINSServer));
      // Add(' Secondary WINS: ' + GetAddrString(@Work^.SecondaryWINSServer));
      // Add(' Lease obtained: ' + TimeTToDateTimeStr(Work^.LeaseObtained));
      // Add(' Lease expires: ' + TimeTToDateTimeStr(Work^.LeaseExpires));
      Inc(I);
      Work := Work^.Next;
    Until (Work = nil);
  End;
  FreeMem(AI);
end;

function GetHDNumber(Drv: String): DWORD; // 得到硬盘序列号
var
  VolumeSerialNumber: DWORD;
  MaximumComponentLength: DWORD;
  FileSystemFlags: DWORD;
begin
  if Drv[Length(Drv)] = ':' then
    Drv := Drv + '\';
  GetVolumeInformation(pChar(Drv), nil, 0, @VolumeSerialNumber,
    MaximumComponentLength, FileSystemFlags, nil, 0);
  Result := (VolumeSerialNumber);
end;

function IsCPUID_Available: Boolean; register;
asm
  PUSHFD							{ direct access to flags no possible, only via stack }
  POP     EAX					{ flags to EAX }
  MOV     EDX,EAX			{ save current flags }
  XOR     EAX,ID_BIT	{ not ID bit }
  PUSH    EAX					{ onto stack }
  POPFD								{ from stack to flags, with not ID bit }
  PUSHFD							{ back to stack }
  POP     EAX					{ get back to EAX }
  XOR     EAX,EDX			{ check if ID bit affected }
  JZ      @exit				{ no, CPUID not availavle }
  MOV     AL,True			{ Result=True }
@exit:
end;

function GetCPUID: TCPUID; assembler; register;
asm
  PUSH    EBX         { Save affected register }
  PUSH    EDI
  MOV     EDI,EAX     { @Resukt }
  MOV     EAX,1
  DW      $A20F       { CPUID Command }
  STOSD			          { CPUID[1] }
  MOV     EAX,EBX
  STOSD               { CPUID[2] }
  MOV     EAX,ECX
  STOSD               { CPUID[3] }
  MOV     EAX,EDX
  STOSD               { CPUID[4] }
  POP     EDI					{ Restore registers }
  POP     EBX
end;

function GetCPUVendor: TVendor; assembler; register;
asm
  PUSH    EBX					{ Save affected register }
  PUSH    EDI
  MOV     EDI,EAX			{ @Result (TVendor) }
  MOV     EAX,0
  DW      $A20F				{ CPUID Command }
  MOV     EAX,EBX
  XCHG		EBX,ECX     { save ECX result }
  MOV			ECX,4
@1:
  STOSB
  SHR     EAX,8
  LOOP    @1
  MOV     EAX,EDX
  MOV			ECX,4
@2:
  STOSB
  SHR     EAX,8
  LOOP    @2
  MOV     EAX,EBX
  MOV			ECX,4
@3:
  STOSB
  SHR     EAX,8
  LOOP    @3
  POP     EDI					{ Restore registers }
  POP     EBX
end;

procedure ChangeByteOrder(var Data; Size: Integer);
var
  ptr: pChar;
  I: Integer;
  c: Char;
begin
  ptr := @Data;
  for I := 0 to (Size shr 1) - 1 do
  begin
    c := ptr^;
    ptr^ := (ptr + 1)^;
    (ptr + 1)^ := c;
    Inc(ptr, 2);
  end;
end;

function GetIdeDiskSerialNumber: String;
var
  hDevice: THandle;
  cbBytesReturned: DWORD;
  pInData: PSendCmdInParams;
  pOutData: Pointer; // PSendCmdOutParams
  Buffer: Array [0 .. BufferSize - 1] of Byte;
  srbControl: TSrbIoControl absolute Buffer;
begin
  Result := '';
  try
    FillChar(Buffer, BufferSize, #0);
    if Win32Platform = VER_PLATFORM_WIN32_NT then
    begin // Windows NT, Windows 2000
      // Get SCSI port handle
      hDevice := CreateFile('\\.\Scsi0:', GENERIC_READ or GENERIC_WRITE,
        FILE_SHARE_READ or FILE_SHARE_WRITE, nil, OPEN_EXISTING, 0, 0);
      if hDevice = INVALID_HANDLE_VALUE then
        exit;
      try
        srbControl.HeaderLength := sizeof(SRB_IO_CONTROL);
        System.Move('SCSIDISK', srbControl.Signature, 8);
        srbControl.Timeout := 2;
        srbControl.Length := DataSize;
        srbControl.ControlCode := IOCTL_SCSI_MINIPORT_IDENTIFY;
        pInData := PSendCmdInParams(pChar(@Buffer) + sizeof(SRB_IO_CONTROL));
        pOutData := pInData;
        with pInData^ do
        begin
          cBufferSize := IDENTIFY_BUFFER_SIZE;
          bDriveNumber := 0;
          with irDriveRegs do
          begin
            bFeaturesReg := 0;
            bSectorCountReg := 1;
            bSectorNumberReg := 1;
            bCylLowReg := 0;
            bCylHighReg := 0;
            bDriveHeadReg := $A0;
            bCommandReg := IDE_ID_FUNCTION;
          end;
        end;
        if not DeviceIoControl(hDevice, IOCTL_SCSI_MINIPORT, @Buffer,
          BufferSize, @Buffer, BufferSize, cbBytesReturned, nil) then
          exit;
      finally
        CloseHandle(hDevice);
      end;
    end
    else
    begin // Windows 95 OSR2, Windows 98
      hDevice := CreateFile('\\.\SMARTVSD', 0, 0, nil, CREATE_NEW, 0, 0);
      if hDevice = INVALID_HANDLE_VALUE then
        exit;
      try
        pInData := PSendCmdInParams(@Buffer);
        pOutData := @pInData^.bBuffer;
        with pInData^ do
        begin
          cBufferSize := IDENTIFY_BUFFER_SIZE;
          bDriveNumber := 0;
          with irDriveRegs do
          begin
            bFeaturesReg := 0;
            bSectorCountReg := 1;
            bSectorNumberReg := 1;
            bCylLowReg := 0;
            bCylHighReg := 0;
            bDriveHeadReg := $A0;
            bCommandReg := IDE_ID_FUNCTION;
          end;
        end;
        if not DeviceIoControl(hDevice, DFP_RECEIVE_DRIVE_DATA, pInData,
          sizeof(TSendCmdInParams) - 1, pOutData, W9xBufferSize,
          cbBytesReturned, nil) then
          exit;
      finally
        CloseHandle(hDevice);
      end;
    end;
    with PIdSector(PAnsiChar(pOutData) + 16)^ do
    begin
      ChangeByteOrder(sSerialNumber, sizeof(sSerialNumber));
      SetString(Result, sSerialNumber, sizeof(sSerialNumber));
    end;
  except
  end;
end;

{ ------------------------------------------------------------------------------ }
function GetNetBIOSAddress: string;
var
  ncb: TNCB;
  status: TAdapterStatus;
  lanenum: TLanaEnum;

  procedure ResetAdapter(num: Char);
  begin
    FillChar(ncb, sizeof(ncb), 0);
    ncb.ncb_command := Char(NCBRESET);
    ncb.ncb_lana_num := AnsiChar(num);
    Netbios(@ncb);
  end;

var
  lanNum: Char;
  Address: record part1: Longint;
  part2: Word; // Smallint;
end
absolute status;

begin
  Result := '';
  try
    FillChar(ncb, sizeof(ncb), 0);
    ncb.ncb_command := Char(NCBENUM);
    ncb.ncb_buffer := @lanenum;
    ncb.ncb_length := sizeof(lanenum);
    Netbios(@ncb);

    if lanenum.Length = #0 then
      exit;
    lanNum := Char(lanenum.lana[0]);

    ResetAdapter(lanNum);

    FillChar(ncb, sizeof(ncb), 0);
    ncb.ncb_command := Char(NCBASTAT);
    ncb.ncb_lana_num := AnsiChar(lanNum);
    ncb.ncb_callname[0] := '*';
    ncb.ncb_buffer := @status;
    ncb.ncb_length := sizeof(status);
    Netbios(@ncb);
    ResetAdapter(lanNum);

    Result := Format('%x%x', [Address.part1, Address.part2]);
  except
  end;
end;

end.
