program sda;

{$INCLUDE 'sda.inc'}

{$R 'dlg.res' 'dlg.rc'}

uses
  sdaButtonControl in '..\sdaControl\sdaButtonControl.pas',
  sdaDialogControl in '..\sdaControl\sdaDialogControl.pas',
  sdaImageListControl in '..\sdaControl\sdaImageListControl.pas',
  sdaMenuControl in '..\sdaControl\sdaMenuControl.pas',
  sdaNotifyIcon in '..\sdaControl\sdaNotifyIcon.pas',
  sdaProgressBarControl in '..\sdaControl\sdaProgressBarControl.pas',
  sdaToolTipControl in '..\sdaControl\sdaToolTipControl.pas',
  sdaWindowControl in '..\sdaControl\sdaWindowControl.pas',
  sdaDialogCreate in '..\sdaCreate\sdaDialogCreate.pas',
  sdaWindowCreate in '..\sdaCreate\sdaWindowCreate.pas',
  sdaActiveX in '..\sdaUnits\sdaActiveX.pas',
  sdaApplication in '..\sdaUnits\sdaApplication.pas',
  sdaClasses in '..\sdaUnits\sdaClasses.pas',
  sdaGraphics in '..\sdaUnits\sdaGraphics.pas',
  sdaHelpers in '..\sdaUnits\sdaHelpers.pas',
  sdaIniFile in '..\sdaUnits\sdaIniFile.pas',
  sdaInput in '..\sdaUnits\sdaInput.pas',
  sdaMessages in '..\sdaUnits\sdaMessages.pas',
  sdaScreen in '..\sdaUnits\sdaScreen.pas',
  sdaSystem in '..\sdaUnits\sdaSystem.pas',
  sdaSysUtils in '..\sdaUnits\sdaSysUtils.pas',
  sdaWindows in '..\sdaUnits\sdaWindows.pas',
  sdaStaticControl in '..\sdaControl\sdaStaticControl.pas',
  sdaAccelControl in '..\sdaControl\sdaAccelControl.pas',
  sdaSyncObj in '..\sdaUnits\sdaSyncObj.pas',
  sdaThreadCreate in '..\sdaCreate\sdaThreadCreate.pas',
  sdaThreadControl in '..\sdaControl\sdaThreadControl.pas',
  sdaProcessControl in '..\sdaControl\sdaProcessControl.pas',
  sdaModule in '..\sdaUnits\sdaModule.pas',
  sdaHeapControl in '..\sdaControl\sdaHeapControl.pas',
  sdaWinSock in '..\sdaUnits\sdaWinSock.pas',
  sdaSocketControl in '..\sdaControl\sdaSocketControl.pas',
  sdaEditControl in '..\sdaControl\sdaEditControl.pas';

const
  IDCTL_LABEL_HINT    = 101;
  IDCTL_PROGRESSBAR   = 102;
  IDPAUSE             = 103;
  IDCTL_LABEL_SUBHINT = 105;

type
  TAppDlg = class(TSdaDialogObject)
  private
    FTray: TSdaNotifyIcon;
    FTip: TSdaToolTipControl;
    FEdit: TSdaEditControl;
  protected
    function InitDialog(AFocusControl: HWND): Boolean; override;
    function CommandEvent(ItemID: Integer; EventCode: Integer): Boolean; override;
    procedure BeforeDestroyHandle; override;
  end;

{ TAppDlg }

procedure TAppDlg.BeforeDestroyHandle;
begin
  FTray.HideIcon;
end;

function TAppDlg.CommandEvent(ItemID, EventCode: Integer): Boolean;
begin
  if ItemID = IDCANCEL then
  begin
    if Application.ModalLevel > 0 then Application.EndModal(IDCANCEL)
      else Application.Terminate;
    Result := true;
  end else
  if ItemID = IDPAUSE then
  begin
    SdaShowMessage(FEdit.SelText);
//    FTray.ShowBalloonHint('Hello', 'Hello, World!', BalloonInfo, 10);
    Result := true;
  end else
  begin
    Result := inherited;
  end;
end;

function TAppDlg.InitDialog(AFocusControl: HWND): Boolean;
var
  c: TSdaWindowControl;
  pb: TSdaProgressBarControl;
begin
  c := Handle;
  c.Left := (Screen.Width - c.Width) div 2;
  c.Top := (Screen.Height - c.Height) div 2;
  Result := inherited InitDialog(AFocusControl);

  FTray.Window := Handle;
  FTray.ID := 1;
  FTray.Message := WM_USER + 1000;
  FTray.Icon := LoadImage(HInstance, '#1', IMAGE_ICON, 16, 16, LR_COLOR);
  FTray.Hint := 'Hello, World!';
  FTray.ShowIcon;

  FTip := TSdaToolTipControl.CreateHandle(TTS_BALLOON);
  c := TSdaDialogControl(Handle).ItemHandle[IDPAUSE];
  FTip.Window := c.Handle;
  FTip.Title := 'Tray icon';
  FTip.TitleIcon := TTI_INFO;
  FTip.AddTool(1, 'Press this button to display message in tray', c.ClientRect, TTF_SUBCLASS or TTF_CENTERTIP);

  pb.Handle := TSdaDialogControl(Handle).ItemHandle[IDCTL_PROGRESSBAR];
  pb.Style := PBS_MARQUEE;
//  pb.EnableMarquee(40);

  FEdit := TSdaEditControl.CreateHandle(WS_CHILD or WS_VISIBLE or ES_MULTILINE or
    ES_WANTRETURN or ES_AUTOVSCROLL or ES_NOHIDESEL, Handle, 'Hello');
  TSdaWindowControl(FEdit.Handle).SetBounds(10, 10, 200, 100);
  FEdit.VerticalScroll := true;

  ShowWindow(Handle, SW_SHOW);
end;

{ $APPTYPE CONSOLE}

begin
  SdaApplicationInitialize;
  try
    TAppDlg.CreateHandle(100);
    Application.Run;
  finally
    SdaApplicationFinalize;
  end;
end.
