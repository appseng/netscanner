/// <summary>
///  Реализация сканера сети NetScanner. Модуль содержит набор классов
///  выходных значений сканирования.
/// </summary>
unit NetScanner.Output;

interface

uses
    Windows,
    SysUtils,
    CommCtrl,
    Winsock,
    syncobjs,
    Generics.Collections,
    Generics.Defaults,
    NetScanner.Interfaces,
    NetScanner.System;

type
    /// <summary> Тип выходных значений(соответсвует одной строке, например, в ListView </summary>
    TOutputDataString = class (TInterfacedObject, IOutputDataString)
    private
      FIPAddress: string;
      FDeviceName: string;
      FMACAddress: string;
      FAdapterDescription: string;
      FComment: string;
      function GetIPAddress: string;
      procedure SetIPAddress(Value: string);
      function GetDeviceName: string;
      procedure SetDeviceName(Value: string);
      function GetMACAddress: string;
      procedure SetMACAddress(Value: string);
      function GetAdapterDescription: string;
      procedure SetAdapterDescription(Value: string);
      function GetComment: string;
      procedure SetComment(Value: string);
    protected
    public
      constructor Create(const AIP, ADeviceName, AMAC, ADescription, AComment: string);
      function GetMAC(AValue: array of Byte; ALength: DWORD): string;
      procedure SetMacAndDescription;
      procedure SetNameFromIP;
      procedure SetMacFromIP;
      procedure SetMacFromIP1;
      property IPAddress:  string read GetIPAddress write SetIPAddress;// read FIPAddress write FIPAddress;
      property DeviceName:  string read GetDeviceName write SetDeviceName;// read FDeviceName write FDeviceName;
      property MACAddress:  string read GetMACAddress write SetMACAddress;// read FMACAddress write FMACAddress;
      property AdapterDescription:  string read GetAdapterDescription write SetAdapterDescription;// read FAdapterDescription write FAdapterDescription;
      property Comment:  string read GetComment write SetComment;// read FComment write FComment;
    end;

    /// <summary> Тип контейнер для хранения описаний сетевых интерфейсов </summary>
    TOutputData = class (TInterfacedObject, IOutputData)
    private
      FDataList:  TList<IOutputDataString>;
      FCriticalSectionResults: TCriticalSection;
      FCriticalSectionThreadCount: TCriticalSection;
      FCriticalSectionScanned  :TCriticalSection;
      FScanned:       Integer;
      FThreadsCount:  Integer;
    protected
    public
      constructor Create;
      destructor Destroy; override;
      function GetElement(AI: Integer) :IOutputDataString;
      function Count: Integer;
      procedure IncThreads;
      procedure DecThreads;
      function GetThreadsCount: Integer;
      function GetScanned: Integer;
      procedure IncScanned;
      /// <summary> Добавление строки к списку результатов </summary>
      procedure Add(ADataString: IOutputDataString);
      /// <summary> Получение выходных данных </summary>
      function GetResultsList: IOutputData;
      /// <summary> Количество просканированных адресов </summary>
      property Scanned: Integer read GetScanned;// write SetScanned;
    end;

implementation

constructor TOutputDataString.Create(const AIP, ADeviceName, AMAC, ADescription, AComment: string);
begin
  FIPAddress := AIP;
  FDeviceName := ADeviceName;
  FMACAddress := AMAC;
  FAdapterDescription := ADescription;
  FComment := AComment;
end;

function TOutputDataString.GetIPAddress: string;
begin
  Result := FIPAddress;
end;

procedure TOutputDataString.SetIPAddress(Value: string);
begin
  FIPAddress := Value;
end;

function TOutputDataString.GetDeviceName: string;
begin
  Result :=FDeviceName;
end;

procedure TOutputDataString.SetDeviceName(Value: string);
begin
  FDeviceName := Value;
end;

function TOutputDataString.GetMACAddress: string;
begin
  Result := FMACAddress;
end;

procedure TOutputDataString.SetMACAddress(Value: string);
begin
  FMACAddress := Value;
end;

function TOutputDataString.GetAdapterDescription: string;
begin
  Result := FAdapterDescription;
end;

procedure TOutputDataString.SetAdapterDescription(Value: string);
begin
  FAdapterDescription := Value;
end;

function TOutputDataString.GetComment: string;
begin
  Result := FComment;
end;

procedure TOutputDataString.SetComment(Value: string);
begin
  FComment := Value;
end;

procedure TOutputDataString.SetNameFromIP;
var
  WSA: TWSAData;
  Host: PHostEnt;
  Addr: ULONG;
  Err: Integer;
begin
  Err := WSAStartup(WSA_TYPE, WSA);
  if Err <> 0 then  // Лучше пользоваться такой конструкцией,
  begin             // чтобы в случае ошибки можно было увидеть ее код.
    //ShowMessage(SysErrorMessage(GetLastError));
    Exit;
  end;
  try
    Addr := inet_addr(PAnsiChar(PAnsiString(AnsiString(Self.FIPAddress))));
    if Addr = INADDR_NONE then
    begin
      //ShowMessage(SysErrorMessage(GetLastError));
      WSACleanup;
      Exit;
    end;
    Host := gethostbyaddr(@Addr, SizeOf(Addr), PF_INET);
    if Assigned(Host) then  // Обязательная проверка, в противном случае, при
      Self.FDeviceName := string(Host.h_name) // отсутствии компьютера с заданым IP, получим AV
    //else
      //ShowMessage(SysErrorMessage(GetLastError));
  finally
    WSACleanup;
  end;
end;

procedure TOutputDataString.SetMacFromIP;
var
 DestIP: ULONG;
 PMacAddr: TMacAddress;
 PhyAddrLen: ULONG;
 MAC:  string;
begin
  DestIP := inet_addr(PAnsiChar(PAnsiString(AnsiString(Self.FIPAddress))));
  PhyAddrLen := 6;
  SendArp(DestIP, 0, @PMacAddr, PhyAddrLen);
  MAC := GetMAC(PMacAddr, PhyAddrLen);
  if MAC <> '00-00-00-00-00-00' then
    Self.FMACAddress := MAC;//GetMAC(pMacAddr, PhyAddrLen);
end;

procedure TOutputDataString.SetMacFromIP1;
// Получаем IP адрес
function GetDottedIPFromInAddr(const AInAddr: Integer): string;
begin
  Result := '';
  Result := IntToStr(FOURTH_IPADDRESS(AInAddr));
  Result := Result + '.' + IntToStr(THIRD_IPADDRESS(AInAddr));
  Result := Result + '.' + IntToStr(SECOND_IPADDRESS(AInAddr));
  Result := Result + '.' + IntToStr(FIRST_IPADDRESS(AInAddr));
end;
 // Основная функция
var
  Table: TMibIPNetTable;
  Size: Integer;
  CatchIP, MAC: string;
  Err, I: Integer;
begin
  Self.FMACAddress := RES_UNKNOWN;
  Size := SizeOf(Table);                      // Ну тут все просто...
  Err := GetIpNetTable(@Table, @Size, False); // Выполняем...
  if Err = NO_ERROR then                     // Проверка на ошибку...
    // Теперь мы имеем таблицу из IP адресов и соответсвующих им MAC адресов
    for I := 0 to Table.dwNumEntries - 1 do     // Ищем нужный IP ...
    begin
      CatchIP := GetDottedIPFromInAddr(Table.Table[I].dwAddr);
      if CatchIP = Self.FIPAddress then                      // И выводим его МАС ...
      begin
        MAC := GetMAC(Table.Table[I].bPhysAddr, Table.Table[I].dwPhysAddrLen);
        if MAC <> '00-00-00-00-00-00' then
          Self.FMACAddress := MAC;

        Break;
      end;
    end;
end;

function TOutputDataString.GetMAC(AValue: array of Byte; ALength: DWORD): string;
var
  I: Integer;
begin
  if ALength = 0 then
    Result := RES_UNKNOWN
  else
  begin
    Result := '';
    for I:= 0 to ALength -2 do
      Result := Result + IntToHex(AValue[i], 2) + '-';

    Result := Result + IntToHex(AValue[ALength-1], 2);
  end;
end;

procedure TOutputDataString.SetMacAndDescription;
var
  InterfaceInfo,
  TmpPointer: PIP_ADAPTER_INFO;
  IP: PIP_ADDR_STRING;
  Len: ULONG;
begin
// Смотрим сколько памяти нам требуется?
  if GetAdaptersInfo(nil, Len) = ERROR_BUFFER_OVERFLOW then
  begin
    // Берем нужное кол-во
    GetMem(InterfaceInfo, Len);
    try
      // выполнение функции
      if GetAdaptersInfo(InterfaceInfo, Len) = ERROR_SUCCESS then
      begin
        // Перечисляем все сетевые интерфейсы
        TmpPointer := InterfaceInfo;
        repeat
          IP := @TmpPointer.IpAddressList;
          while (IP <> nil) do
          begin          // Имя сетевого интерфейса
            if Self.FIPAddress=string(IP^.IpAddress.S) then
            begin
              // Описание сетевого интерфейса
              Self.FAdapterDescription := string(TmpPointer^.Description);
              // МАС Адрес
              Self.FMACAddress := GetMAC(TmpPointer^.Address, TmpPointer^.AddressLength);
            end;
            // перечисляем все IP адреса интерфейса
            IP := IP.Next;
          end;
          TmpPointer := TmpPointer.Next;
        until TmpPointer = nil;
      end;
    finally
      // Освобождаем занятую память
      FreeMem(InterfaceInfo);
    end;
  end;
end;

function TOutputData.GetElement(AI: Integer) :IOutputDataString;
//var
//  DataString: IOutputDataString;
begin
  FCriticalSectionResults.Enter;
  if (AI >= 0) and (AI < FDataList.Count) then
  begin
    //DataString :=
    Result := Self.FDataList[AI];;
  end;
  FCriticalSectionResults.Leave;
end;

function TOutputData.Count: Integer;
begin
  FCriticalSectionResults.Enter;
  Result := FDataList.Count;
  FCriticalSectionResults.Leave;
end;

function TOutputData.GetScanned: Integer;
begin
  Result := FScanned;
end;

procedure TOutputData.IncScanned;
begin
  FCriticalSectionScanned.Enter;
  Inc(FScanned);
  FCriticalSectionScanned.Leave;
end;

constructor TOutputData.Create;
begin
  Self.FCriticalSectionResults := TCriticalSection.Create;
  Self.FCriticalSectionThreadCount := TCriticalSection.Create;
  Self.FCriticalSectionScanned := TCriticalSection.Create;
  Self.FDataList := TList<IOutputDataString>.Create;
  Self.FScanned := 0;
end;

destructor TOutputData.Destroy;
begin
  FreeAndNil(Self.FCriticalSectionThreadCount);
  FreeAndNil(Self.FDataList);//.Free;
  FreeAndNil(Self.FCriticalSectionResults);//.Free;
  FreeAndNil(Self.FCriticalSectionScanned);
end;

procedure TOutputData.Add(ADataString: IOutputDataString);
begin
  if (Self <> nil) and(FCriticalSectionResults <> nil) and (FDataList <> nil) then
  begin
    Self.FCriticalSectionResults.Enter;
    Self.FDataList.Add(ADataString);
    Self.FCriticalSectionResults.Leave;
  end
end;

function TOutputData.GetResultsList: IOutputData;
begin
  if (Self <> nil) then //and(FCriticalSection <> nil) then// and (FDataList <> nil) then
    Result := Self
  else
    Result := nil;
end;

procedure TOutputData.IncThreads;
begin
  FCriticalSectionThreadCount.Enter;
  Inc(FThreadsCount);
  FCriticalSectionThreadCount.Leave;
end;

procedure TOutputData.DecThreads;
begin
  FCriticalSectionThreadCount.Enter;
  Dec(FThreadsCount);
  FCriticalSectionThreadCount.Leave;
end;

function TOutputData.GetThreadsCount;
begin
  FCriticalSectionThreadCount.Enter;
  Result:= FThreadsCount;
  FCriticalSectionThreadCount.Leave;
end;

end.
