{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10042: kpSFXOpt.pas 
{
{   Rev 1.0    8/14/2005 1:10:08 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.0    10/15/2002 8:15:18 PM  Supervisor
}
{
{   Rev 1.0    9/3/2002 8:16:50 PM  Supervisor
}
unit kpSFXOpt;

interface

const
  SFXSig         = 'MPU';

type
  TsfxOverwriteMode = (omPrompt, omAlways, omNever);

  sfxSpecialHeader = Record
     Sig:              array [1..3] of Char;
     OptionsByte:      Byte;
     CaptionLen:       Byte;
     ExtractPathLen:   Byte;
     CmdLineLen:       Byte;
     StringData:       array [1..249] of Char;
  end;
procedure setUserCanDisableCmdLine( Value: Boolean );
procedure setUserCanChooseFiles( Value: Boolean );
procedure setUserCanChangeOverwrite( Value: Boolean );
procedure setOverwriteMode( om: TsfxOverwriteMode );
procedure setStringData( sfxCaption, sfxDefPath, sfxCmdLine: String );
procedure setAutoExtract( Value: Boolean );

var
  MPUHeader: sfxSpecialheader;
  OptionsPointer: PChar;
  OptionsSize: Integer;

implementation

const
  DISCMD         = 1;
  CHOOSE_FILES   = 2;
  NO_CHANGE_OVER = 4;
  AUTO_EXTRACT   = 64;
  CONFIRM        = 0;
  ALWAYS         = 8;
  NEVER          = 16;

procedure setUserCanDisableCmdLine( Value: Boolean );
begin
  With MPUHeader do
     If Value then
        OptionsByte := OptionsByte or DISCMD
     Else
        OptionsByte := OptionsByte and (not DISCMD);
end;

procedure setUserCanChooseFiles( Value: Boolean );
begin
  With MPUHeader do
     If Value then
        OptionsByte := OptionsByte or CHOOSE_FILES
     Else
        OptionsByte := OptionsByte and (not CHOOSE_FILES);
end;

procedure setUserCanChangeOverwrite( Value: Boolean );
begin
  With MPUHeader do
     If Value then
        OptionsByte := OptionsByte and (not NO_CHANGE_OVER)
     Else
        OptionsByte := OptionsByte or NO_CHANGE_OVER;
end;

procedure setAutoExtract( Value: Boolean );
begin
  With MPUHeader do
     If Value then
        OptionsByte := OptionsByte or AUTO_EXTRACT
     Else
        OptionsByte := OptionsByte and (not AUTO_EXTRACT);
end;

procedure setOverwriteMode( om: TsfxOverwriteMode );
begin
  With MPUHeader do
     Case om of
        omPrompt:   OptionsByte := (OptionsByte and 7) + CONFIRM;
        omAlways:   OptionsByte := (OptionsByte and 7) + ALWAYS;
        omNever:    OptionsByte := (OptionsByte and 7) + NEVER;
     end;

end;

procedure setStringData( sfxCaption, sfxDefPath, sfxCmdLine: String );
begin
  With MPUHeader do
   begin
     CaptionLen := Length(sfxCaption);
     ExtractPathLen := Length(sfxDefPath);
     CmdLineLen := Length(sfxCmdLine);
     If CaptionLen > 0 then
        System.Move(sfxCaption[1],StringData[1],CaptionLen);
     If ExtractPathLen > 0 then
        System.Move(sfxDefPath[1],StringData[1+CaptionLen],ExtractPathLen);
     If CmdLineLen > 0 then
        System.Move(sfxCmdLine[1],StringData[1+CaptionLen+ExtractPathLen],CmdLineLen);
   end;
end;

{$IFDEF WIN32}
Initialization
{$ELSE}
begin
{$ENDIF}
  With MPUHeader do
   begin
     Sig := SFXSig;
     OptionsByte := OptionsByte and (not DISCMD);
     OptionsByte :=  OptionsByte and (not CHOOSE_FILES);
     OptionsByte := OptionsByte and (not NO_CHANGE_OVER);
     OptionsByte := (OptionsByte and 7) + CONFIRM;
     setStringData('SFX', '', '');
   end;
  OptionsPointer := PChar(@MPUHeader);
  OptionsSize := SizeOf(MPUHeader);

end.
 
