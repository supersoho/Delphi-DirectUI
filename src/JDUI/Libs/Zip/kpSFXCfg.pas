{ $HDR$}
{**********************************************************************}
{ Unit archived using Team Coherence                                   }
{ Team Coherence is Copyright 2002 by Quality Software Components      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.TeamCoherence.com                                         }
{**********************************************************************}
{}
{ $Log:  10012: kpSFXCfg.pas 
{
{   Rev 1.0    8/14/2005 1:07:56 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.0    10/15/2002 8:15:16 PM  Supervisor
}
{
{   Rev 1.0    9/3/2002 8:16:50 PM  Supervisor
}
unit kpSFXCfg;

interface
uses
   Classes;

const
   SFXSig                     = 'MPU';

type
   TsfxOverwriteMode = (omPrompt, omAlways, omNever);

   sfxSpecialHeader = packed record
      Sig: array[1..3] of Char;
      OptionsByte: Byte;
      CaptionLen: Byte;
      ExtractPathLen: Byte;
      CmdLineLen: Byte;
      InfoTextLen: WORD;
      InfoTitleLen: Byte;
   end;

   TSFXConfig = class(TComponent)
   PRIVATE
      FSpecialHeader: sfxSpecialHeader;
      FHeader: PChar;
      FHeaderLen: WORD;
      FUserCanDisableCmdLine: Boolean;
      FUserCanChooseFiles: Boolean;
      FUserCanChangeOverwrite: Boolean;
      FAutoExtract: Boolean;
      FOverwriteMode: TsfxOverwriteMode;
      FCaption: string;
      FDefaultPath: string;
      FCmdLine: string;
      FInfoText: string;
      FInfoTitle: string;
   PUBLIC
      constructor Create(AOwner: TComponent); OVERRIDE;
      destructor Destroy; override;
      procedure CreateHeader;
      property theHeader: PChar read FHeader;
      property HeaderLen: WORD read FHeaderLen;
   PUBLISHED
      property UserCanDisableCmdLine: Boolean READ FUserCanDisableCmdLine WRITE
         FUserCanDisableCmdLine;
      property UserCanChooseFiles: Boolean READ FUserCanChooseFiles WRITE FUserCanChooseFiles;
      property UserCanChangeOverwrite: Boolean READ FUserCanChangeOverwrite WRITE
         FUserCanChangeOverwrite;
      property AutoExtract: Boolean READ FAutoExtract WRITE FAutoExtract DEFAULT False;
      property OverwriteMode: TsfxOverwriteMode READ FOverwriteMode WRITE FOverwriteMode DEFAULT
         omAlways;
      property Caption: string READ FCaption WRITE FCaption;
      property DefaultPath: string READ FDefaultPath WRITE FDefaultPath;
      property CmdLine: string READ FCmdLine WRITE FCmdLine;
      property InfoText: string READ FInfoText WRITE FInfoText;
      property InfoTitle: string READ FInfoTitle WRITE FInfoTitle;
   end;

{$IFNDEF FULLPACK}
  procedure Register;
{$ENDIF}

implementation

const
   DISCMD                     = 1;
   CHOOSE_FILES               = 2;
   NO_CHANGE_OVER             = 4;
   AUTO_EXTRACT               = 64;
   CONFIRM                    = 0;
   ALWAYS                     = 8;
   NEVER                      = 16;

constructor TSFXConfig.Create(AOwner: TComponent);
begin
   inherited Create(AOwner);
   FUserCanDisableCmdLine := False;
   FUserCanChooseFiles := False;
   FUserCanChangeOverwrite := False;
   FAutoExtract := False;
   FOverwriteMode := omAlways;
   FCaption := 'VCLZip Self Extracting Archive';
   FDefaultPath := '';
   FCmdLine := '';
   FInfoText := '';
   FInfoTitle := '';
   with FSpecialHeader do
   begin
      Sig := SFXSig;
      OptionsByte := OptionsByte and (not DISCMD);
      OptionsByte := OptionsByte and (not CHOOSE_FILES);
      OptionsByte := OptionsByte and (not NO_CHANGE_OVER);
      OptionsByte := (OptionsByte and 7) + CONFIRM;
      CaptionLen := Length(FCaption);
      ExtractPathLen := Length(FDefaultPath);
      CmdLineLen := Length(FCmdLine);
      InfoTextLen := Length(FInfoText);
      InfoTitleLen := Length(FInfoTitle);
   end;
   FHeader := nil;
end;

destructor TSFXConfig.Destroy;
begin
  if (FHeader <> nil) then
     FreeMem(FHeader, FHeaderLen);
  inherited Destroy;
end;

procedure TSFXConfig.CreateHeader;
var
   cur                        : PChar;
begin
   with FSpecialHeader do
   begin
      if FUserCanDisableCmdLine then
         OptionsByte := OptionsByte or DISCMD
      else
         OptionsByte := OptionsByte and (not DISCMD);
      if FUserCanChooseFiles then
         OptionsByte := OptionsByte or CHOOSE_FILES
      else
         OptionsByte := OptionsByte and (not CHOOSE_FILES);
      if FUserCanChangeOverwrite then
         OptionsByte := OptionsByte and (not NO_CHANGE_OVER)
      else
         OptionsByte := OptionsByte or NO_CHANGE_OVER;
      case FOverwriteMode of
         omPrompt: OptionsByte := (OptionsByte and 7) + CONFIRM;
         omAlways: OptionsByte := (OptionsByte and 7) + ALWAYS;
         omNever: OptionsByte := (OptionsByte and 7) + NEVER;
      end;
      if FAutoExtract then
        OptionsByte := OptionsByte or AUTO_EXTRACT
      else
        OptionsByte := Optionsbyte and (not AUTO_EXTRACT);
      {$IFDEF KPDEMO}
      FCaption := 'VCLZIP DEMO SFX';
      {$ENDIF}
      {$IFDEF KPSFXDEMO}
      FCaption := 'VCLZIP DEMO SFX';
      {$ENDIF}
      CaptionLen := Length(FCaption);
      ExtractPathLen := Length(FDefaultPath);
      CmdLineLen := Length(FCmdLine);
      InfoTextLen := Length(FInfoText);
      InfoTitleLen := Length(FInfoTitle);
      FHeaderLen := SizeOf(FSpecialHeader) + CaptionLen + ExtractPathLen + CmdLineLen +
         InfoTextLen + InfoTitleLen + SizeOf(FHeaderLen);
   end;
   if FHeader <> nil then
      FreeMem(FHeader, FHeaderLen);
   GetMem(FHeader, FHeaderLen);
   cur := FHeader;
   System.Move(FSpecialHeader, cur^, SizeOf(FSpecialHeader));
   Inc(cur, SizeOf(FSpecialHeader));
   with FSpecialHeader do
   begin
      if CaptionLen > 0 then
      begin
         System.Move(FCaption[1], cur^, CaptionLen);
         Inc(cur, CaptionLen);
      end;
      if ExtractPathLen > 0 then
      begin
         System.Move(FDefaultPath[1], cur^, ExtractPathLen);
         Inc(cur, ExtractPathLen);
      end;
      if CmdLineLen > 0 then
      begin
         System.Move(FCmdLine[1], cur^, CmdLineLen);
         Inc(cur, CmdLineLen);
      end;
      if InfoTextLen > 0 then
      begin
         System.Move(FInfoText[1], cur^, InfoTextLen);
         Inc(cur, InfoTextLen);
      end;
      if InfoTitleLen > 0 then
      begin
         System.Move(FInfoTitle[1], cur^, InfoTitleLen);
         Inc(cur, InfoTitleLen);
      end;
      System.Move(FHeaderLen, cur^, SizeOf(FHeaderLen));
   end;
end;

procedure Register;
begin
  RegisterComponents('VCLZip', [TSFXConfig]);
end;

end.

