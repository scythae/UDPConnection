unit uMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, uUDPConnection, StdCtrls, StrUtils, Winsock, ExtCtrls, ComCtrls;

type
  TSide = (sMe, sOpposite);

  TfrMain = class(TForm)
    btSend: TButton;
    eMyPort: TEdit;
    btConnect: TButton;
    gbSettings: TGroupBox;
    lMyPort: TLabel;
    lPortToConnect: TLabel;
    ePortToConnect: TEdit;
    eAddressToConnect: TEdit;
    lAddressToConnect: TLabel;
    gbMessages: TGroupBox;
    splSettings: TSplitter;
    mMyMsg: TMemo;
    Splitter1: TSplitter;
    reCommonMsg: TRichEdit;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btSendClick(Sender: TObject);
    procedure btConnectClick(Sender: TObject);
  private
    FUDPConnection: TUDPConnection;
    procedure PrepareConnection(var UDPConnection: TUDPConnection);
    procedure OnReceive(Sender: TObject; TextMsg: string);
    procedure AddMessageToChat(TextMsg: string; Side: TSide);
  public
    { Public declarations }
  end;

var
  frMain: TfrMain;

implementation

{$R *.dfm}

procedure TfrMain.FormCreate(Sender: TObject);
begin
  ReportMemoryLeaksOnShutdown := True;
end;

procedure TfrMain.btConnectClick(Sender: TObject);
begin
  PrepareConnection(FUDPConnection);
end;

procedure TfrMain.PrepareConnection(var UDPConnection: TUDPConnection);
begin
  FreeAndNil(UDPConnection);

  try
    UDPConnection := TUDPConnection.Create(Self, StrToInt(eMyPort.Text), 256);
    UDPConnection.SetRecipientsAddressAndPort(
      eAddressToConnect.Text, StrToInt(ePortToConnect.Text));
    UDPConnection.OnReceive := OnReceive;
  except
    FreeAndNil(UDPConnection);
    ShowMessage('Incorrect address or port.');
  end;
end;

procedure TfrMain.btSendClick(Sender: TObject);
var
  S: string;
begin
  S := mMyMsg.Text;
  if S = '' then
    Exit();

  try
    FUDPConnection.Send(S);
    AddMessageToChat(s, sMe);
  except
    ShowMessage('There''s no connection.');
  end;
end;

procedure TfrMain.AddMessageToChat(TextMsg: string; Side: TSide);
var
  SideSuffix: string;
begin
  case Side of
    sMe: SideSuffix := '[From me]';
    sOpposite: SideSuffix := '[To me]';
  end;

  reCommonMsg.Lines.Add(TimeToStr(now) + ' ' + SideSuffix + ': ' + TextMsg);
end;


procedure TfrMain.OnReceive(Sender: TObject; TextMsg: string);
begin
  if TextMsg = #0 then
    Exit();

  AddMessageToChat(TextMsg, sOpposite);
end;

procedure TfrMain.FormDestroy(Sender: TObject);
begin
  FreeAndNil(FUDPConnection);
end;

end.

