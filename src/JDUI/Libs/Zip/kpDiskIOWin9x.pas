{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10026: kpDiskIOWin9x.pas 
{
{   Rev 1.1    11/30/2008 1:44:04 PM  Delphi7    Version: VCLZip Version 4.50
{ Modifications for 4.50
}
{
{   Rev 1.0    8/14/2005 1:10:08 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.1    9/28/2003 7:56:42 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.0    9/28/2003 2:22:22 PM  Supervisor    Version: VCLZip 3.X
{ Added for capability to get clustersize
}
{ NOTE: This file/unit was renamed for distribution with VCLZip, soley to }
{       avoid any naming collistions  }
{******************************************************************************}
{                                                                              }
{ DiskIOWin9x, Version 1.2                                                     }
{                                                                              }
{ The contents of this file are subject to the Mozilla Public License Version  }
{ 1.1 (the "License"); you may not use this file except in compliance with the }
{ License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{ The Original Code is DiskIOWin9x.pas.                                        }
{                                                                              }
{ The Initial Developer of the Original Code is Peter J. Haas. Portions        }
{ created by Peter J. Haas are Copyright (C) 2001 Peter J. Haas. All Rights    }
{ Reserved.                                                                    }
{                                                                              }
{ Contributor(s):                                                              }
{   Chris Morris, chrismo@homemail.com                                         }
{                                                                              }
{******************************************************************************}
{                                                                              }
{ Contact:                                                                     }
{   EMail:     PeterJHaas@t-online.de                                          }
{   HomePage:  http://home.t-online.de/home/PeterJHaas/delphi.htm              }
{                                                                              }
{                                                                              }
{ Limitations:                                                                 }
{   Delphi 3 to 5                                                              }
{                                                                              }
{ History:                                                                     }
{   2000-12-12  Version 1.0                                                    }
{               - first public version                                         }
{                                                                              }
{   2001-01-25  Version 1.1                                                    }
{               - add EnumOpenFiles                                            }
{                                                                              }
{   2001-08-01  Version 1.2                                                    }
{               - separated files, DiskIOWin9x, DiskIOs, FindFiles             }
{               - use JEDI.INC                                                 }
{               - BugFix IsWin95SR2orHigher (Chris Morris)                     }
{               - add DoIOCTLWithDeviceCatFallBack                             }
{               - add ClearMID, SetMediaID                                     }
{               - rename EnumOpenFiles to GetOpenFileList                      }
{                                                                              }
{******************************************************************************}

unit kpDiskIOWin9x;

{$I JEDI.INC}

{$ALIGN ON, $BOOLEVAL OFF, $LONGSTRINGS ON, $IOCHECKS ON, $WRITEABLECONST OFF}
{$OVERFLOWCHECKS OFF, $RANGECHECKS OFF, $TYPEDADDRESS ON, $MINENUMSIZE 1}

//{$ifndef DELPHI3_UP}
//  Not supported
//{$endif}

interface
uses
  Windows, SysUtils, Classes;

const
  // Performs the specified MS-DOS device I/O control function
  // (Interrupt 21h Function 4400h through 4411h)
  VWIN32_DIOC_DOS_IOCTL = 1;

  // Performs the Absolute Disk Read command (Interrupt 25h)
  VWIN32_DIOC_DOS_INT25 = 2;
  // Performs the Absolute Disk Write command (Interrupt 25h)
  VWIN32_DIOC_DOS_INT26 = 3;

  // Performs Interrupt 13h commands
  VWIN32_DIOC_DOS_INT13 = 4;

  // Performs Interrupt 21h Function 730X commands.
  // This value is supported in Windows 95 OEM Service Release 2 and later.
  VWIN32_DIOC_DOS_DRIVEINFO = 6;

type
  PDEVIOCTL_REGISTERS = ^TDEVIOCTL_REGISTERS;
  TDEVIOCTL_REGISTERS = packed record
    reg_EBX   : DWord;
    reg_EDX   : DWord;
    reg_ECX   : DWord;
    reg_EAX   : DWord;
    reg_EDI   : DWord;
    reg_ESI   : DWord;
    reg_Flags : DWord;
  end;

  PMID = ^TMID;
  TMID = packed record
    midInfoLevel   : Word;
    midSerialNum   : DWord;
    midVolLabel    : array[0..10] of AnsiChar;  // string without termination null
    midFileSysType : array[0..7] of AnsiChar;  // string without termination null
  end;

  PExtGetDskFreSpcStruc = ^TExtGetDskFreSpcStruc;
  TExtGetDskFreSpcStruc = packed record
    ExtFree_Size                     : Word;
    ExtFree_Level                    : Word;    
    ExtFree_SectorsPerCluster        : DWord;
    ExtFree_BytesPerSector           : DWord;
    ExtFree_AvailableClusters        : DWord;
    ExtFree_TotalClusters            : DWord;
    ExtFree_AvailablePhysSectors     : DWord;
    ExtFree_TotalPhysSectors         : DWord;
    ExtFree_AvailableAllocationUnits : DWord;
    ExtFree_TotalAllocationUnits     : DWord;
    ExtFree_Rsvd                     : DWord;
    ExtFree_Rsvd2                    : DWord;
  end;

  PDiskIO = ^TDiskIO;
  TDiskIO = packed record
    diStartSector: DWord;  // sector number to start
    diSectors    : Word;   // number of sectors
    diBuffer     : DWord;  // address of buffer
  end;

  // not change the sequencing
  TDiskIOAccessMode = (dioRead, dioWrite);
  // not change the sequencing
  TDiskIODataMode = (dioUnknown, dioFATData, dioDirectoryData, dioFileData);

function DoIOCTL(var AReg: TDEVIOCTL_REGISTERS; AIOControlCode: DWord): Boolean;

// EAX := $440D
// ECH := try first $48, if fail then fallback to $08
// ECL := Function Code
function DoIOCTLWithDeviceCatFallBack(var AReg: TDEVIOCTL_REGISTERS;
                                      AFunction: Integer): Boolean;

// MediaID functions
// clear the MediaID Structure
procedure ClearMID(var AMID: TMID);

// ADrive:
//   1 = A, 3 = C, 0 = current drive
function GetMediaID(const ADrive: UINT; var AMID: TMID): Boolean;

// ADrive:
//   1 = A, 3 = C, 0 = current drive
function SetMediaID(const ADrive: UINT; const AMID: TMID): Boolean;

// ARootFilename:
//   'C:\' or '\\Server\Share'
function Get_ExtFreeSpace(const ARootFilename: String;
                          var AStruc: TExtGetDskFreSpcStruc): Boolean;

function GetOpenFileList(const ADrive: UINT; AList: TStrings): Boolean;

function Ext_ABSDiskReadWrite(DriveNum: Integer; const DiskIO: TDiskIO;
                              AccessMode: TDiskIOAccessMode;
                              DataMode: TDiskIODataMode): Boolean;

function IsWin95SR2orHigher: Boolean;

implementation

function IsWin95SR2orHigher: Boolean;
begin
  { Chrismo: dwBuildNumber (Win32BuildNumber)
    Windows NT: Identifies the build number of the operating system.
    Windows 95: Identifies the build number of the operating system
    in the low-order word. The high-order word contains the major
    and minor version numbers.}
  Result := (Win32Platform = VER_PLATFORM_WIN32_WINDOWS) and
    ((Win32MajorVersion > 4) or ((Win32MajorVersion = 4) and
    ((Win32MinorVersion > 0) or ((Win32BuildNumber and $0000FFFF) > 1080))));
end;

function DoIOCTL(var AReg: TDEVIOCTL_REGISTERS; AIOControlCode: DWord): Boolean;
var
  DeviceHandle : THandle;
  cb : DWord;
begin
  Result := False;
  AReg.reg_Flags := $0001;  // assume error (carry flag set)
  DeviceHandle := CreateFile('\\.\vwin32', 0,
                             0, Nil, 0, FILE_FLAG_DELETE_ON_CLOSE, 0);
  if DeviceHandle <> INVALID_HANDLE_VALUE then try
    Result := DeviceIoControl(DeviceHandle, AIOControlCode,
                              @AReg, SizeOf(AReg),
                              @AReg, SizeOf(AReg),
                              cb, Nil);
    if Result then begin
      // error if carry flag set
      Result := (AReg.reg_Flags and $0001) = 0;
    end
    else begin
      AReg.reg_EAX := GetLastError;
    end;
  finally
    CloseHandle(DeviceHandle);
  end;
end;

// EAX := $440D
// ECH := try first $48, if fail then fallback to $08
// ECL := Function Code
function DoIOCTLWithDeviceCatFallBack(var AReg: TDEVIOCTL_REGISTERS;
                                      AFunction: Integer): Boolean;
var
  Reg : TDEVIOCTL_REGISTERS;
begin
  Reg := AReg;
  Reg.reg_EAX := $440D;         // IOCTL for block devices
  Reg.reg_ECX := AFunction or $4800;

  Result := DoIOCTL(Reg, VWIN32_DIOC_DOS_IOCTL);
  if not Result then begin
    Reg := AReg;
    Reg.reg_EAX := $440D;         // IOCTL for block devices
    Reg.reg_ECX := AFunction or $0800;

    Result := DoIOCTL(Reg, VWIN32_DIOC_DOS_IOCTL);
  end;
  
  AReg := Reg;
end;

procedure ClearMID(var AMID: TMID);
begin
  AMID.midInfoLevel := 0;
  AMID.midSerialNum := 0;
  FillChar(AMID.midVolLabel, SizeOf(AMID.midVolLabel), ' ');
  FillChar(AMID.midFileSysType, SizeOf(AMID.midFileSysType), ' ');
end;

function GetMediaID(const ADrive: UINT; var AMID: TMID): Boolean;
var
  Reg : TDEVIOCTL_REGISTERS;
begin
  ClearMID(AMID);

  Reg.reg_EBX := ADrive;        // zero-based drive ID
  Reg.reg_EDX := DWord(@AMID);  // receives media ID info

  Result := DoIOCTLWithDeviceCatFallBack(Reg, $66);  // Get Media ID command

  if Not Result then
    SetLastError(Reg.reg_EAX);
end;

function SetMediaID(const ADrive: UINT; const AMID: TMID): Boolean;
var
  Reg : TDEVIOCTL_REGISTERS;
begin
  Reg.reg_EBX := ADrive;        // zero-based drive ID
  Reg.reg_EDX := DWord(@AMID);  // receives media ID info

  Result := DoIOCTLWithDeviceCatFallBack(Reg, $46);  // Set Media ID command

  if Not Result then
    SetLastError(Reg.reg_EAX);
end;

function Get_ExtFreeSpace(const ARootFilename: String;
                          var AStruc: TExtGetDskFreSpcStruc): Boolean;
const
  ExpectLevel = 0;
var
  Reg : TDEVIOCTL_REGISTERS;
begin
  FillChar(AStruc, SizeOf(AStruc), 0);
  AStruc.ExtFree_Level := ExpectLevel;

  Reg.reg_EAX := $7303;                        // Get_ExtFreeSpace
  Reg.reg_EDX := DWord(PChar(ARootFilename));  // RootFilename
  Reg.reg_EDI := DWord(@AStruc);               // Infos
  Reg.reg_ECX := SizeOf(AStruc);

  Result := DoIOCTL(Reg, VWIN32_DIOC_DOS_DRIVEINFO);

  if Not Result then
    SetLastError(Reg.reg_EAX);
end;

function GetOpenFileList(const ADrive: UINT; AList: TStrings): Boolean;
var
  Reg : TDEVIOCTL_REGISTERS;
  FileIndex : Integer;
  FileName : String;
  RootPathName : String;
  MaximumComponentLength : DWord;
begin
  // get max file name length
  if ADrive = 0 then
    RootPathName := ''
  else
    RootPathName := Chr((Ord('A') - 1) + ADrive) + ':\';
  Result := GetVolumeInformation(Pointer(RootPathName), Nil, 0, Nil,
                                 MaximumComponentLength, PDWord(Nil)^, Nil, 0);
  if Not Result then Exit;

  // enum open files
  FileIndex := 0;
  repeat
    SetLength(FileName, MaximumComponentLength);

    Reg.reg_EAX := $440D;         // IOCTL for block devices
    Reg.reg_EBX := ADrive;        // zero-based drive ID
    Reg.reg_ECX := $486D;         // Enumerate Open Files
    Reg.reg_EDX := DWord(Filename);  // path buffer
    Reg.reg_ESI := FileIndex;        // FileIndex
    Reg.reg_EDI := 0;                // EnumType

    Result := DoIOCTL(Reg, VWIN32_DIOC_DOS_IOCTL);

  // mov [OpenMode], ax      ; mode file was opened in
  // mov [FileType], cx      ; normal file or memory-mapped file

    if Result then
      AList.Add(Filename);

    Inc(FileIndex);
  until Not Result;

  Result := Reg.reg_EAX = ERROR_NO_MORE_FILES;
  if Result then
    SetLastError(Reg.reg_EAX)
  else
    SetLastError(ERROR_SUCCESS);
end;

function Ext_ABSDiskReadWrite(DriveNum: Integer; const DiskIO: TDiskIO;
                              AccessMode: TDiskIOAccessMode;
                              DataMode: TDiskIODataMode): Boolean;
var
  Reg : TDEVIOCTL_REGISTERS;
begin
  Reg.reg_ESI := (Ord(AccessMode) and $0001) or
                 ((Ord(DataMode) and $0003) shl 13);
  Reg.reg_ECX := DWord(-1);
  Reg.reg_EBX := DWord(@DiskIO);
  Reg.reg_EDX := DriveNum;

  Reg.reg_EAX := $7305;                        // Ext_ABSDiskReadWrite

  Result := DoIOCTL(Reg, VWIN32_DIOC_DOS_DRIVEINFO);

  if Not Result then
    SetLastError(Reg.reg_EAX);
end;

end.
