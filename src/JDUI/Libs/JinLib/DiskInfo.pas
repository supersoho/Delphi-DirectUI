unit diskInfo;

interface
  uses WinApi.windows,SysUtils;

const
  IOCTL_STORAGE_QUERY_PROPERTY=$2D1400;

type
   //存储设备的总线类型
   PSTORAGE_BUS_TYPE=^STORAGE_BUS_TYPE;
   STORAGE_BUS_TYPE=(
      BusTypeUnknown = 0,
      BusTypeScsi,
      BusTypeAtapi,
      BusTypeAta,
      BusType1394,
      BusTypeSsa,
      BusTypeFibre,
      BusTypeUsb,
      BusTypeRAID,
      BusTypeMaxReserved = $7F);

   //查询属性输出的数据结构
   PSTORAGE_DEVICE_DESCRIPTOR=^STORAGE_DEVICE_DESCRIPTOR;
   STORAGE_DEVICE_DESCRIPTOR=Record
      Version:ULONG;                    // 版本
      Size:ULONG;                       // 结构大小
      DeviceType:UCHAR;                 // 设备类型
      DeviceTypeModifier:UCHAR;         // SCSI-2额外的设备类型
      RemovableMedia:BOOLEAN;           // 是否可移动
      CommandQueueing:BOOLEAN;          // 是否支持命令队列
      VendorIdOffset:ULONG;             // 厂家设定值的偏移
      ProductIdOffset:ULONG;            // 产品ID的偏移
      ProductRevisionOffset:ULONG;      // 产品版本的偏移
      SerialNumberOffset:ULONG;         // 序列号的偏移
      BusType:STORAGE_BUS_TYPE;         // 总线类型
      RawPropertiesLength:ULONG;        // 额外的属性数据长度
      RawDeviceProperties:UCHAR;        // 额外的属性数据(仅定义了象征性的1个字节)
   end;

   //查询属性输入的数据结构
   PSTORAGE_PROPERTY_QUERY=^STORAGE_PROPERTY_QUERY;
   STORAGE_PROPERTY_QUERY=Record
      PropertyId:DWord;//STORAGE_PROPERTY_ID;     // 设备/适配器
      QueryType:DWord;//STORAGE_QUERY_TYPE;       // 查询类型
      AdditionalParameters:UCHAR;        // 额外的数据(仅定义了象征性的1个字节)
    end;

   TRecDisk=Record
     sDrv:char;
     iType:byte;  //0硬盘 1USB盘
     iTotal:int64;
     iFree:int64;
   end;
   TArrRecDisk=Array[0..25] of  TRecDisk;

  Function GetLocalDiskInfo(var ArrRecDisk:TArrRecDisk):integer;
  Function GetAllLogicalDisk(var sNo:string):integer;
  Function CheckIsUSBPart(cPart:Char):Boolean;
  Function GetDriveProperty(hDevice:THandle;var DevDesc:STORAGE_DEVICE_DESCRIPTOR):Boolean;

implementation

Function GetLocalDiskInfo(var ArrRecDisk:TArrRecDisk):integer;
var
  sPart:string;
  iDrv,i:integer;
begin
  FillChar(ArrRecDisk,Sizeof(ArrRecDisk),#0);
  Result:=GetAllLogicalDisk(sPart);
  if Result=0 then exit;
  for i:=1 to Result do
  begin
    ArrRecDisk[i-1].sDrv:=sPart[i];
    if CheckIsUsbPart(sPart[i]) then
      ArrRecDisk[i-1].iType:=1
    else ArrRecDisk[i-1].iType:=0;
    iDrv:=Ord(Upcase(sPart[i]))-65+1;
    ArrRecDisk[i-1].iTotal:=DiskSize(iDrv);
    ArrRecDisk[i-1].iFree:=DiskFree(iDrv);
  end; {end for i}
end;

Function GetAllLogicalDisk(var sNo:string):integer;
var
  pBuff: array of Char;
  tmpStr:String;
  iType:integer;
begin
  Result:=0;
  sNo:='';
  SetLength(pBuff,500);
  GetLogicalDriveStrings(500, PChar(pBuff));
  while (Length(String(pBuff)) > 0) and (pBuff[0] <> #0) do
  begin
    tmpStr := UpperCase(Copy(string(pBuff), 1, Pos(#0, string(pBuff)) - 2));
    if (tmpStr <>'A:') and (tmpStr<>'B:') and (tmpStr<>'')  then
    begin
      iType := GetDriveType(PChar(tmpStr));
      //if  iType =DRIVE_FIXED then
      begin
        sNo:=sNo+tmpStr[1];
        Result:=Result+1;
      end;
    end;
    pBuff := copy(pBuff, Length(tmpStr) + 2, 255 - Length(tmpStr));
  end; { end while }
  SetLength(pBuff, 0);
  DisPose(PChar(pBuff));
end;

Function CheckIsUSBPart(cPart:Char):Boolean;
var
  fileHandle:THandle;
  sDevice:string;
  DevDesc:STORAGE_DEVICE_DESCRIPTOR;
begin
  Result:=False;
  sDevice:='\\.\'+cPart+':';
  fileHandle := CreateFile(Pchar(sDevice), Generic_Read or Generic_Write,
                    File_Share_Read or File_Share_Write, nil, Open_Existing, 0, 0) ;
  if (fileHandle = INVALID_HANDLE_VALUE) then Exit;
  try
    if GetDriveProperty(fileHandle,DevDesc) then
       if DevDesc.BusType in [BusTypeUsb{BusTypeScsi,BusTypeAtapi,BusTypeAta,BusType1394,
                              BusTypeSsa,BusTypeFibre,BusTypeRAID}] then
          Result:=True;
  finally
    CloseHandle(fileHandle);
  end;
end;

Function GetDriveProperty(hDevice:THandle;var DevDesc:STORAGE_DEVICE_DESCRIPTOR):Boolean;
var
  Query:STORAGE_PROPERTY_QUERY;    // 查询输入参数
  dwOutBytes:DWORD;                // IOCTL输出数据长度
begin
  // 指定查询方式
  Query.PropertyId:=0;//StorageDeviceProperty;
  Query.QueryType:=0;//PropertyStandardQuery;

  // 用IOCTL_STORAGE_QUERY_PROPERTY取设备属性信息
  Result:=DeviceIoControl(hDevice,           // 设备句柄
      IOCTL_STORAGE_QUERY_PROPERTY,          // 取设备属性信息
      @Query, sizeof(Query),// 输入数据缓冲区
      @DevDesc, Sizeof(DevDesc),              // 输出数据缓冲区
      dwOutBytes,                           // 输出数据长度
      nil);                   // 用同步I/O
end;


end.
