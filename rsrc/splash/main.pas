unit Main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  ComCtrls, StdCtrls;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    pnlImage: TImage;
    pnlImageContainer: TPanel;
    pnlSplash: TPanel;
    pnlSplashBack: TPanel;
    pbWait: TProgressBar;
    tmrParentWatchDog: TTimer;
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure tmrParentWatchDogTimer(Sender: TObject);
  private
    fParentProcessId: LongWord;
  public
    property ParentProcessId: LongWord
      read fParentProcessId write fParentProcessId;
  end;

var
  frmMain: TfrmMain;

procedure SetPanelText(const Message: string);

implementation

uses
  SysTools;

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Delay(1500);
  Application.Terminate;
end;

procedure TfrmMain.tmrParentWatchDogTimer(Sender: TObject);
begin
  if not IsProcessRunning(ParentProcessId) then
  begin
    tmrParentWatchDog.Enabled := False;
    Close;
  end;
end;

procedure SetPanelText(const Message: string);
begin
  frmMain.pnlSplash.Caption := Message + ' ... Please wait.';
end;

end.

