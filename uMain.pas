﻿unit uMain;

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
    procedure SetAddressToConnect(const Value: string);
    procedure SetMyPort(const Value: Integer);
    procedure SetPortToConnect(const Value: Integer);
    function GetAddressToConnect(): string;
    function GetMyPort(): Integer;
    function GetPortToConnect(): Integer;
  public
    property AddressToConnect: string read GetAddressToConnect write SetAddressToConnect;
    property MyPort: Integer  read GetMyPort write SetMyPort;
    property PortToConnect: Integer  read GetPortToConnect write SetPortToConnect;
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
    UDPConnection := TUDPConnection.Create(Self, MyPort, 256);
    UDPConnection.SetRecipientsAddressAndPort(AddressToConnect, PortToConnect);
    UDPConnection.OnReceive := OnReceive;
  except
    FreeAndNil(UDPConnection);
    ShowMessage('Incorrect address or port.');
  end;
end;

procedure TfrMain.btSendClick(Sender: TObject);
var
  TextToSend: string;
begin
  TextToSend := mMyMsg.Text;
  if TextToSend = '' then
    Exit();

  try
    FUDPConnection.Send(TextToSend);
    AddMessageToChat(TextToSend, sMe);
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

function TfrMain.GetAddressToConnect: string;
begin
  Result := eAddressToConnect.Text;
end;
procedure TfrMain.SetAddressToConnect(const Value: string);
begin
  eAddressToConnect.Text := Value;
end;

function TfrMain.GetMyPort: Integer;
begin
  Result := StrToInt(eMyPort.Text);
end;
procedure TfrMain.SetMyPort(const Value: Integer);
begin
  eMyPort.Text := IntToStr(Value);
end;

function TfrMain.GetPortToConnect: Integer;
begin
  Result := StrToInt(ePortToConnect.Text);
end;
procedure TfrMain.SetPortToConnect(const Value: Integer);
begin
  ePortToConnect.Text := IntToStr(Value);
end;

end.

