program DirectUIDemo;

{$DEFINE USE_GDIPLUS}

uses
  GR32,
  ceflib,
  jinTextDraw,
  SysUtils,
  jinUtils,
  JDUIUtils,
  IOUtils,
  Forms,
  DemoFrm in 'DemoFrm.pas' {DemoForm},
  ScreenshotFrm in 'ScreenshotFrm.pas' {ScreenshotForm},
  ScreenshotToolFrm in 'ScreenshotToolFrm.pas' {ScreenshotToolForm},
  AnimateFrm in 'AnimateFrm.pas' {AnimateForm},
  jduMessageBoxFrm in 'jduMessageBoxFrm.pas' {JDUIMessageBoxForm};

{$R *.res}
{$R dpi.res}

type
  TCustomBrowserProcessHandler = class(TCefBrowserProcessHandlerOwn)
  private
  protected
    procedure OnContextInitialized; override;
    procedure OnBeforeChildProcessLaunch(const commandLine: ICefCommandLine); override;
    procedure OnRenderProcessThreadCreated(const extraInfo: ICefListValue); override;
  end;


procedure SetCommandLine(const commandLine: ICefCommandLine);
begin
  commandLine.AppendSwitch('disable-web-security');
  commandLine.AppendSwitch('allow-running-insecure-content');
  commandLine.AppendSwitch('no-sandbox');

  commandLine.AppendSwitch('enable-peer-connection');
  commandLine.AppendSwitch('enable-media-stream');
  commandLine.AppendSwitch('enable-webrtc-vp9-support');
  commandLine.AppendSwitch('enable-accelerated-compositing');
  commandLine.AppendSwitch('enable-webgl');

  commandLine.AppendSwitch('off-screen-rendering-enabled');
  commandLine.AppendSwitchWithValue('off-screen-frame-rate', '60');
  commandLine.AppendSwitch('disable-gpu');
  commandLine.AppendSwitch('disable-gpu-compositing');
  commandLine.AppendSwitch('disable-gpu-vsync');

  commandLine.AppendSwitch('process-per-site');
  commandLine.AppendSwitch('renderer-process-limit=1');
  commandLine.AppendSwitch('in-process-plugins');
  commandLine.AppendSwitch('ppapi-out-of-process');
end;

procedure OnbeforeCmdLine(const processType: ustring;
  const commandLine: ICefCommandLine);
begin
  SetCommandLine(commandLine);
end;

{$region 'TCustomBrowserProcessHandler'}
procedure TCustomBrowserProcessHandler.OnContextInitialized;
begin
  inherited;
end;

procedure TCustomBrowserProcessHandler.OnBeforeChildProcessLaunch(const commandLine: ICefCommandLine);
begin
  inherited;
  SetCommandLine(commandLine);
end;

procedure TCustomBrowserProcessHandler.OnRenderProcessThreadCreated(const extraInfo: ICefListValue);
begin
  inherited;
end;
{$endregion}

begin
  CefLocale := 'zh-CN';
  CefCache := GetSpecialFolderDir(5) + IOUtils.TPath.GetFileNameWithoutExtension(Application.ExeName) + '\Cef3Cache';
  CefSingleProcess := (not VistaUP);
  CefCommandLineArgsDisabled := True;
  CefRemoteDebuggingPort := 9001;
  CefOnBeforeCommandLineProcessing := OnbeforeCmdLine;
  CefBrowserProcessHandler := TCustomBrowserProcessHandler.Create;
  if not CefLoadLibDefault then Exit;

  GR32_TEXT_EMOJI_FONT := ExtractFilePath(Application.ExeName) + 'fonts\Emoji.ttf';
  GR32_TEXT_NORMAL_FONT := ExtractFilePath(Application.ExeName) + 'fonts\Alibaba-PuHuiTi-Regular.ttf';
  GR32_TEXT_BOLD_FONT := ExtractFilePath(Application.ExeName) + 'fonts\Alibaba-PuHuiTi-Medium.ttf';
  GR32_TEXT_HEAVY_FONT := ExtractFilePath(Application.ExeName) + 'fonts\Alibaba-PuHuiTi-Bold.ttf';

  initFreeType;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TDemoForm, DemoForm);
  Application.Run;

  destroyFreeType;

  CefShutDown;
end.
