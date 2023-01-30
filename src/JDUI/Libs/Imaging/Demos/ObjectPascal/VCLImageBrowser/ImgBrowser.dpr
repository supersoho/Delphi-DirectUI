program ImgBrowser;

uses
  ExceptionLog,
  Forms,
  Main;

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'VCL Image Browser';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
