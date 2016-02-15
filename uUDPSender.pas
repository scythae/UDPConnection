unit uUDPSender;

interface

uses
  Windows, WinSock, SysUtils, Dialogs, Classes, StrUtils,
  SyncObjs, uSocketUtils;

type
  TUDPSender = class(TThread)
  private
    FMsg: AnsiString;
    FSocket: TSocket;
    FCriticalSection: TCriticalSection;
    procedure Execute; override;
    procedure Send();
  public
    constructor Create(ASocket: TSocket);
    destructor Destroy; override;
    procedure PrepareMessage(AMsg: AnsiString);
  end;

implementation

{ TSender }

constructor TUDPSender.Create(ASocket: TSocket);
begin
  inherited Create(False);
  FSocket := ASocket;
  FCriticalSection := TCriticalSection.Create();
end;

destructor TUDPSender.Destroy;
begin
  FreeAndNil(FCriticalSection);
  inherited;
end;

procedure TUDPSender.Execute;
begin
  inherited;
  while not Terminated do
    Send();
end;

procedure TUDPSender.PrepareMessage(AMsg: AnsiString);
begin
  FCriticalSection.Enter;

  FMsg := AMsg;

  FCriticalSection.Leave;
end;

procedure TUDPSender.Send;
var
  SenderInfo: TSockAddrIn;
  Sent: Integer;
begin
  if Length(FMsg) = 0 then
    Exit();

  if FSocket = 0 then
    Exit();

  FMsg := StrUtils.LeftStr(FMsg, 256);

  FillChar(SenderInfo, SizeOf(SenderInfo), 0);
  SenderInfo := MakeSockAddrIn('127.0.0.1', 10000);
  Sent := sendto(FSocket, FMsg, Length(FMsg), 0, SenderInfo,
    SizeOf(SenderInfo));
  if Sent = SOCKET_ERROR then
    ShowMessage('Winsock error. Code: ' +
    IntToStr(WSAGetLastError()));

  Setlength(FMsg, 0);
end;

end.
