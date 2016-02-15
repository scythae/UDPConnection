unit uUDPReceiver;

interface

uses
  Windows, WinSock, SysUtils, Messages, Classes, Controls, Dialogs;

const
  WM_RECEIVE = WM_USER + 1;

type
  TUDPReceiver = class(TThread)
  private
    FSocket: TSocket;
    FOwner: TWinControl;
    FMsg: AnsiString;
    procedure Execute; override;
    procedure Retranslate();
    procedure Receive();
  public
    constructor Create(AOwner: TWinControl; ASocket: TSocket);
  end;

implementation

constructor TUDPReceiver.Create(AOwner: TWinControl; ASocket: TSocket);
begin
  inherited Create(False);
  FOwner := AOwner;
  FSocket := ASocket;
end;

procedure TUDPReceiver.Receive;
const
  Buf_length = 256;
var
  Buf: array [0..Buf_length - 1] of Byte;
  SenderInfo: TSockAddrIn;
  SenderInfoSize: Integer;
  Received: Integer;
  Err: Integer;
  ErrString: string;
  ErrStringLen: Integer;
begin
  if FSocket = 0 then
    Exit();

  //FormatMessage()
  SenderInfoSize := SizeOf(SenderInfo);
  Received := recvfrom(FSocket, Buf, Buf_length, 0, SenderInfo, SenderInfoSize);
  if Received = SOCKET_ERROR then
  begin
    Err := WSAGetLastError();
    if Err  = 123 then
    begin
      SetLength(ErrString, MAX_PATH);
      ErrStringLen := FormatMessage(0, nil, Err, 0, PChar(ErrString), MAX_PATH, nil);
      SetLength(ErrString, ErrStringLen);
      ShowMessage(ErrString);
    end;

  end;
end;

procedure TUDPReceiver.Retranslate;
begin
  If Assigned(FOwner) then
    PostMessage(FOwner.Handle, WM_RECEIVE, 0, 0);
end;

procedure TUDPReceiver.Execute;
begin
  inherited;
  while not Terminated do
    Receive();
end;

end.
