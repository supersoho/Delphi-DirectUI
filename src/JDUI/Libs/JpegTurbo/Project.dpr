program Project;

uses
  Vcl.Forms,
  DelphiJpegTurbo in 'DelphiJpegTurbo.pas' {Form1},
  cgJpeg in 'cgJpeg.pas',
  libJPEG in 'libJPEG.pas',
  U_threadChargement in 'U_threadChargement.pas',
  U_threadChargement_2 in 'U_threadChargement_2.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
