unit uUDPConnection;

interface

uses
  Windows, WinSock, SysUtils, Dialogs, Classes, Controls,
  Messages,
  AnsiStrings;

const
  WM_SOCKET = WM_USER + 1;
  MessageBufferLength_Max = 65535;
  INADDR_ANY_asstring = '0.0.0.0';

type
  TNotifyReceive = procedure(Sender: TObject; TextMsg: string) of object;

  TUDPConnection = class(TWinControl)
  private
    FSocket: TSocket;
    FRecipientInfo: TSockAddrIn;
    FMessageBufferLength: Integer;
    FOnReceive: TNotifyReceive;
    procedure SetMessageBufferLength(const Value: Integer);
    procedure ParseAddressAndPortString(const AddressAndPort: string;
      out Address: string; out Port: Integer);
    procedure RaiseIncorrectAddress;
    property MessageBufferLength: Integer read FMessageBufferLength write SetMessageBufferLength;
    procedure ShowWSAError();
    function Init(): Boolean;
    procedure CreateSocket();
    procedure TurnOnAsyncState();
    procedure BindToPort(Port: Integer);
    procedure DestroySocket();
    procedure TryReceive();
    procedure OnWMSocket(var Msg: TMsg); message WM_SOCKET;
    procedure SendTo(RecipientInfo: TSockAddrIn; TextMsg: string);
    function MakeSockAddrIn(AddressAndPort: string): TSockAddrIn; overload;
    function MakeSockAddrIn(Address: string; Port: Cardinal): TSockAddrIn; overload;
    function MakeSockAddrIn(): TSockAddrIn; overload;
  protected
    procedure DoReceive(TextMsg: string);
  public
    constructor Create(AOwner: TWinControl; ListeningPort: Integer;
      MessageBufferLength: Integer = 256);
    destructor Destroy(); override;
    procedure SetRecipientsAddressAndPort(Address: string;
      APort: Integer); overload;
    procedure SetRecipientsAddressAndPort(AddressAndPort: string); overload;
    procedure Send(const TextMsg: string); overload;
    procedure Send(const Address: string; const Port: Integer;
      const TextMsg: string); overload;
    procedure Send(const AddressAndPort: string;
      const TextMsg: string); overload;
    property OnReceive: TNotifyReceive read FOnReceive write FOnReceive;
  end;

implementation

constructor TUDPConnection.Create(AOwner: TWinControl; ListeningPort: Integer;
  MessageBufferLength: Integer = 256);
begin
  if not Init then
    raise Exception.Create('Winsock initialization error.');

  inherited Create(AOwner);
  Self.Parent := AOwner;

  Self.MessageBufferLength := MessageBufferLength;

  CreateSocket();
  TurnOnAsyncState();
  BindToPort(ListeningPort);
end;

function TUDPConnection.Init(): Boolean;
var
  Winsock_version: Word;
  Winsock_error: Integer;
  Winsock_data: WSADATA;
begin
  Winsock_version := MakeWord(2, 0);
  Winsock_error := WSAStartup(Winsock_version, Winsock_data);
  Result := (Winsock_error = 0);
end;

procedure TUDPConnection.SetMessageBufferLength(const Value: Integer);
begin
  if Value < MessageBufferLength_Max then
    FMessageBufferLength := Value
  else
    FMessageBufferLength := MessageBufferLength_Max;
end;

procedure TUDPConnection.CreateSocket();
begin
  FSocket := Socket(PF_INET, SOCK_DGRAM, 0);
  if FSocket = INVALID_SOCKET then
    ShowWSAError();
end;

procedure TUDPConnection.ShowWSAError;
begin
  ShowMessage('Winsock error. Code: ' + IntToStr(WSAGetLastError()));
end;

procedure TUDPConnection.TurnOnAsyncState;
var
  AsyncSelected: Integer;
begin
  AsyncSelected := WSAAsyncSelect(FSocket, Self.Handle, WM_SOCKET, FD_READ);
  if AsyncSelected = SOCKET_ERROR then
    ShowWSAError();
end;

procedure TUDPConnection.BindToPort(Port: Integer);
var
  SockAddrIn: TSockAddrIn;
  Bound: Integer;
begin
  SockAddrIn := MakeSockAddrIn(INADDR_ANY_asstring, Port);
  Bound := bind(FSocket, SockAddrIn, SizeOf(SockAddrIn));
  if Bound = SOCKET_ERROR then
    ShowWSAError();
end;

destructor TUDPConnection.Destroy;
begin
  DestroySocket();
  WSACleanUp();

  inherited;
end;

procedure TUDPConnection.DestroySocket;
begin
  if FSocket = INVALID_SOCKET then
    Exit;

  FSocket := CloseSocket(FSocket);
  if FSocket = INVALID_SOCKET then
    ShowWSAError();
end;

procedure TUDPConnection.OnWMSocket(var Msg: TMsg);
begin
  if WSAGetSelectError(Msg.lParam) = 0 then
    TryReceive();
end;

procedure TUDPConnection.TryReceive;
var
  SenderInfo: TSockAddrIn;
  SenderInfoSize: Integer;
  Received: Integer;
  Err: Integer;
  ReceivedMsg: AnsiString;
begin
  if FSocket = 0 then
    Exit();

  SetLength(ReceivedMsg, MessageBufferLength);
  SenderInfoSize := SizeOf(SenderInfo);
  Received := recvfrom(FSocket, ReceivedMsg[1], Length(ReceivedMsg), 0,
    SenderInfo, SenderInfoSize);

  case Received of
    SOCKET_ERROR:
      begin
        Err := WSAGetLastError();
        if Err <> WSAEWOULDBLOCK then
          ShowWSAError();
      end;
    0:
      ShowMessage('Socket closed.');
    else
      begin
        SetLength(ReceivedMsg, Received);
        DoReceive(ReceivedMsg);
      end;
  end;
end;

procedure TUDPConnection.DoReceive(TextMsg: string);
begin
  if Assigned(FOnReceive) then
    FOnReceive(Self, TextMsg);
end;

procedure TUDPConnection.Send(const TextMsg: string);
begin
  SendTo(FRecipientInfo, TextMsg);
end;

procedure TUDPConnection.Send(const Address: string; const Port: Integer;
  const TextMsg: string);
begin
  SendTo(MakeSockAddrIn(Address, Port), TextMsg);
end;

procedure TUDPConnection.Send(const AddressAndPort, TextMsg: string);
begin
  SendTo(MakeSockAddrIn(AddressAndPort), TextMsg);
end;

procedure TUDPConnection.SendTo(RecipientInfo: TSockAddrIn; TextMsg: string);
var
  Sent: Integer;
  TextMsgAnsi: AnsiString;
begin
  if (FSocket = 0) or (TextMsg = '') then
    Exit();

  TextMsgAnsi := TextMsg;
  if Length(TextMsgAnsi) > MessageBufferLength then
    TextMsgAnsi := AnsiStrings.LeftStr(TextMsgAnsi, MessageBufferLength);

  Sent := Winsock.sendto(FSocket, TextMsgAnsi[1], Length(TextMsgAnsi), 0, RecipientInfo,
    SizeOf(RecipientInfo));

  if Sent = SOCKET_ERROR then
    ShowWSAError();
end;

procedure TUDPConnection.SetRecipientsAddressAndPort(
  AddressAndPort: string);
begin
  FRecipientInfo := MakeSockAddrIn(AddressAndPort);
end;

procedure TUDPConnection.SetRecipientsAddressAndPort(Address: string;
  APort: Integer);
begin
  FRecipientInfo := MakeSockAddrIn(Address, APort);
end;

function TUDPConnection.MakeSockAddrIn(AddressAndPort: string): TSockAddrIn;
var
  Address: string;
  Port: Integer;
begin
  ParseAddressAndPortString(AddressAndPort, Address, Port);
  Result := MakeSockAddrIn(Address, Port);
end;

procedure TUDPConnection.ParseAddressAndPortString(const AddressAndPort: string;
  out Address: string; out Port: Integer);
var
  PortStr: string;
  ColonPos: Integer;
begin
  ColonPos := pos(':', AddressAndPort);
  if ColonPos = 0 then
    RaiseIncorrectAddress;

  Address := Copy(AddressAndPort, 1, ColonPos - 1);
  PortStr := Copy(AddressAndPort, ColonPos + 1, Length(AddressAndPort));

  if not TryStrToInt(PortStr, Port) then
    RaiseIncorrectAddress;
end;

procedure TUDPConnection.RaiseIncorrectAddress();
begin
  raise Exception.Create('Incorrect address string.');
end;

function TUDPConnection.MakeSockAddrIn(Address: string; Port: Cardinal): TSockAddrIn;
var
  AddressAnsi: AnsiString;
begin
  Result := MakeSockAddrIn;
  AddressAnsi := Address;

  Result.sin_addr.S_addr := inet_addr(PAnsiChar(AddressAnsi));
  if Integer(Result.sin_addr.S_addr) = Integer(INADDR_NONE) then
    RaiseIncorrectAddress;

  Result.sin_port := htons(Port);
end;

function TUDPConnection.MakeSockAddrIn(): TSockAddrIn;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.sin_family := PF_INET;
end;

end.
