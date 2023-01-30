unit diskInfo;

interface
  uses WinApi.windows,SysUtils;

const
  IOCTL_STORAGE_QUERY_PROPERTY=$2D1400;

type
   //�洢�豸����������
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

   //��ѯ������������ݽṹ
   PSTORAGE_DEVICE_DESCRIPTOR=^STORAGE_DEVICE_DESCRIPTOR;
   STORAGE_DEVICE_DESCRIPTOR=Record
      Version:ULONG;                    // �汾
      Size:ULONG;                       // �ṹ��С
      DeviceType:UCHAR;                 // �豸����
      DeviceTypeModifier:UCHAR;         // SCSI-2������豸����
      RemovableMedia:BOOLEAN;           // �Ƿ���ƶ�
      CommandQueueing:BOOLEAN;          // �Ƿ�֧���������
      VendorIdOffset:ULONG;             // �����趨ֵ��ƫ��
      ProductIdOffset:ULONG;            // ��ƷID��ƫ��
      ProductRevisionOffset:ULONG;      // ��Ʒ�汾��ƫ��
      SerialNumberOffset:ULONG;         // ���кŵ�ƫ��
      BusType:STORAGE_BUS_TYPE;         // ��������
      RawPropertiesLength:ULONG;        // ������������ݳ���
      RawDeviceProperties:UCHAR;        // �������������(�������������Ե�1���ֽ�)
   end;

   //��ѯ������������ݽṹ
   PSTORAGE_PROPERTY_QUERY=^STORAGE_PROPERTY_QUERY;
   STORAGE_PROPERTY_QUERY=Record
      PropertyId:DWord;//STORAGE_PROPERTY_ID;     // �豸/������
      QueryType:DWord;//STORAGE_QUERY_TYPE;       // ��ѯ����
      AdditionalParameters:UCHAR;        // ���������(�������������Ե�1���ֽ�)
    end;

   TRecDisk=Record
     sDrv:char;
     iType:byte;  //0Ӳ�� 1USB��
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
  Query:STORAGE_PROPERTY_QUERY;    // ��ѯ�������
  dwOutBytes:DWORD;                // IOCTL������ݳ���
begin
  // ָ����ѯ��ʽ
  Query.PropertyId:=0;//StorageDeviceProperty;
  Query.QueryType:=0;//PropertyStandardQuery;

  // ��IOCTL_STORAGE_QUERY_PROPERTYȡ�豸������Ϣ
  Result:=DeviceIoControl(hDevice,           // �豸���
      IOCTL_STORAGE_QUERY_PROPERTY,          // ȡ�豸������Ϣ
      @Query, sizeof(Query),// �������ݻ�����
      @DevDesc, Sizeof(DevDesc),              // ������ݻ�����
      dwOutBytes,                           // ������ݳ���
      nil);                   // ��ͬ��I/O
end;


end.
