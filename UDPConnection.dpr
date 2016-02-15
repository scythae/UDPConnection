program UDPConnection;

uses
  Forms,
  uMain in 'uMain.pas' {frMain},
  uUDPConnection in 'uUDPConnection.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrMain, frMain);
  Application.Run;
end.
