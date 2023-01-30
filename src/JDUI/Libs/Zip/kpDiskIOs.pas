{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10024: kpDiskIOs.pas 
{
{   Rev 1.0    8/14/2005 1:10:08 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.3    12/16/2003 8:58:14 AM  Supervisor    Version: VCLZip 3.X
{ WARNINGS OFF
}
{
{   Rev 1.2    11/29/2003 11:56:32 PM  Supervisor    Version: VCLZip 3.X
{ Turn off SYMBOL_DEPRECIATED warnings
}
{
{   Rev 1.1    9/28/2003 7:56:42 PM  Supervisor    Version: VCLZip 3.X
}
{
{   Rev 1.0    9/28/2003 2:22:20 PM  Supervisor    Version: VCLZip 3.X
{ Added for capability to get clustersize
}
{ NOTE: This file/unit was renamed for distribution with VCLZip, soley to }
{       avoid any naming collistions  }
{******************************************************************************}
{                                                                              }
{ DiskIOs, Version 1.2                                                         }
{                                                                              }
{ The contents of this file are subject to the Mozilla Public License Version  }
{ 1.1 (the "License"); you may not use this file except in compliance with the }
{ License. You may obtain a copy of the License at http://www.mozilla.org/MPL/ }
{                                                                              }
{ Software distributed under the License is distributed on an "AS IS" basis,   }
{ WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for }
{ the specific language governing rights and limitations under the License.    }
{                                                                              }
{ The Original Code is DiskIOs.pas.                                            }
{                                                                              }
{ The Initial Developer of the Original Code is Peter J. Haas. Portions        }
{ created by Peter J. Haas are Copyright (C) 2000 Peter J. Haas. All Rights    }
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
{   2001-08-01  Version 1.2                                                    }
{               - separated files, DiskIOWin9x, DiskIOs, FindFiles             }
{               - use JEDI.INC                                                 }
{               - Bugfix GetDiskFreeSpace (Chris Morris)                       }
{                                                                              }
{******************************************************************************}

unit kpDiskIOs;

{$I JEDI.INC}

{$ALIGN ON, $BOOLEVAL OFF, $LONGSTRINGS ON, $IOCHECKS ON, $WRITEABLECONST OFF}
{$OVERFLOWCHECKS OFF, $RANGECHECKS OFF, $TYPEDADDRESS ON, $MINENUMSIZE 1}

{$WARNINGS OFF}

//{$ifndef DELPHI3_UP}
//  Not supported
//{$endif}

interface
uses
  Windows, SysUtils;

// Get cluster size
// ARootFilename:
//   'C:\' or '\\Server\Share'
function GetClusterSize(const ARootFilename: String): DWord;

implementation
uses
  kpDiskIOWin9x;

// corrected for WinNT by Chris Morris
function GetClusterSize(const ARootFilename: String): DWord;
var
  Struc : TExtGetDskFreSpcStruc;
  SectorsPerCluster : DWord;
  BytesPerSector : DWord;
  FreeClusters: DWord;
  TotalClusters: DWord;
begin
  if IsWin95SR2orHigher then
  begin
    if Not Get_ExtFreeSpace(ARootFilename, Struc) then
      RaiseLastWin32Error;
    Result := Struc.ExtFree_SectorsPerCluster * Struc.ExtFree_BytesPerSector;
  end
  else
  begin
    if Not GetDiskFreeSpace(PChar(ARootFilename),
                            SectorsPerCluster, BytesPerSector,
                            FreeClusters, TotalClusters) then
      RaiseLastWin32Error;
    Result := SectorsPerCluster * BytesPerSector;
  end;
end;

end.
