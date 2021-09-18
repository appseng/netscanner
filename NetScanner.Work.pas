/// <summary>
///  Реализация сканера сети NetScanner. Модуль содержит набор классов:
///  класс входных данных, классы потоков.
/// </summary>
unit NetScanner.Work;

interface

uses
  Windows,
  SysUtils,
  Classes,
  Dialogs,
  Winsock,
  CommCtrl,
  syncobjs,
  Generics.Collections,
  Generics.Defaults,
  NetScanner.System,
  NetScanner.Interfaces,
  NetScanner.Output;

type
    // опережающее объявление
    TNetScannerWorkThread = class;
    /// <summary> Общий тип входных данных </summary>
    TInputData = class (TInterfacedObject, IInputData)
    private
    protected
      FData:          TStringList;
      FLocalhostIP:   TStringList;
      FGateway:       TStringList;
      FWorkThread:    INetScannerWorkThread;
      FSem:           THandle;
      FScanning:      Integer;
      FAllScanning:   Integer;
      FPaused:        Boolean;
      /// </summary> Создания потока с входными данными A# и выходными в AOutData </summary>
      procedure CreateThread(A1,A2,A3,A4: Byte; AOutData: IOutputData); overload;
      procedure CreateThread(IP: string; AOutData: IOutputData); overload;
      /// <summary> Получить IP локального компьютера </summary>
      function GetLocalIP: TStringList;
      /// <summary> Получить IP основного шлюза </summary>
      function GetGateway: TStringList;

      function GetScanning: Integer;
      function GetAllScanning: Integer;
      function GetSem: THandle;
      procedure SetSem(AValue: THandle);
      function GetPaused: Boolean;
      procedure SetPaused(AValue: Boolean);
      function GetWorkThread: INetScannerWorkThread;
      procedure SetWorkThread(AValue: INetScannerWorkThread);
    public
      constructor Create;
      destructor Destroy; override;
      /// <summary> Задать входные данные </summary>
      procedure SetData(AAddressList: TStringList);overload;virtual;abstract;
      procedure SetData(const A1,A2: string);overload;virtual;abstract;
      /// <summary> Процедура сканирования </summary>
      procedure Scan(AOutputD: IOutputData);virtual;abstract;
      /// <summary> Текущий порядковый номер сканируемого адреса </summary>
      property Scanning: Integer read GetScanning;
      /// <summary> Всего предстоит просканировать </summary>
      property AllScanning: Integer read GetAllScanning;
      /// <summary> Семафор, для ограничения числа запущенных сканирований </summary>
      property Sem: THandle read GetSem write SetSem;
       /// <summary> Флаг показывающий нахождение процесса поиска на паузе </summary>
      property IsPaused: Boolean read GetPaused write SetPaused;
      /// <summary> Рабочий поток </summary>
      property WorkThread: INetScannerWorkThread read GetWorkThread write SetWorkThread;
    end;

    /// <summary> Тип входных данных для сканирования диапазаона </summary>
    TInputRange = class(TInputData)
    private
    protected
    public
      procedure SetData(const IPFrom, IPTo: string);override;
      //procedure SetData(AAddressList: TStringList);override;
      procedure Scan(AOutData: IOutputData);override;
    end;

    /// <summary> Тип входных данных для сканирования по маске </summary>
    TInputMaskIP = class(TInputData)
    private
    protected
    public
      procedure SetData(const IP, Mask: string);override;
      //procedure SetData(AAddressList: TStringList);override;
      procedure Scan(AOutData: IOutputData);override;
    end;

    /// <summary> Тип входных данных для сканирования по GUID </summary>
    TInputGUID = class(TInputData)
    private
    protected
      function GetIPAndMaskByGuid(AAdapterName: string): TStringList;
    public
      procedure SetData(const GUID,Null: string);override;
      //procedure SetData(AAddressList: TStringList);override;
      procedure Scan(AOutData: IOutputData);override;
    end;

    TInputAddressList = class(TInputData)
    private
    protected
    public
      procedure SetData(AAddressList: TStringList); override;
      procedure Scan(AOutData: IOutputData);override;
    end;

    /// <summary> Рабочий поток, контролирует запуск сканирования IP-адресов </summary>
    TNetScannerWorkThread = class(TThread, INetScannerWorkThread)
    private
      FOutputData:  IOutputData;
      FInputData:   IInputData;
      FPaused:      Boolean;
      FEvent:       TEvent;
      function GetScanning: Integer;
      function GetScanned: Integer;
      function GetAllScanning: Integer;
      function GetScanLeft: Integer;
      function GetTerminated: Boolean;
      function GetPaused: Boolean;
      procedure SetPaused(AValue: Boolean);
      function GetEvent: TEvent;
      procedure SetAEvent(AValue: TEvent);
      function GetInputData: IInputData;
      procedure SetInputData(AValue: IInputData);
    protected
      procedure Execute; override;
    public
      constructor Create(AInputData: IInputData);
      destructor Destroy; override;
      function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
      function _AddRef: Integer; stdcall;
      function _Release: Integer; stdcall;
      /// <summary> Получение итоговых результатов сканирования </summary>
      function GetResultsList:  IOutputData;
      /// <summary> Порядковый номер сканируемого </summary>
      property Scanning: Integer read GetScanning;
      /// <summary> Просканированно </summary>
      property Scanned: Integer read GetScanned;
      /// <summary> Всего просканировать </summary>
      property AllScanning: Integer read GetAllScanning;
      /// <summary> Осталось просканировать </summary>
      property ScanLeft: Integer read GetScanLeft;
      /// <summary> Находится ли поток в состояние паузы </summary>
      property IsPaused: Boolean read GetPaused write SetPaused;
      property Event: TEvent read GetEvent write SetAEvent;
      /// <summary> Установлен ли флаг Terminated </summary>
      property IsThreadTerminated: Boolean read GetTerminated;
      /// <summary> Получить, задать поле входных данных </summary>
      property InputData : IInputData read GetInputData write SetInputData;
    end;

    /// <summary> Рабочий поток сетевого сканирования конкретного IP </summary>
    TThreadScanIP = class(TThread)
    private
      FIP:            string;
      FLocalhostIP:   Boolean;
      FGateway:       Boolean;
      FOutputData:    IOutputData;
      FSem:           THandle;
    protected
      procedure ScanIP;
      procedure Execute; override;
    public
      destructor Destroy; override;
      /// <summary> Добавить данные к выходным значениям </summary>
      procedure ItemAdd(const AItem: IOutputDataString); virtual;
      /// <summary> IP текущего сканиреумого адреса </summary>
      property IP: string read FIP write FIP;
      /// <summary> Пометка, является ли текущий адрес адресом локального ПК </summary>
      property IsLocalhostIP: Boolean read FLocalhostIP write FLocalhostIP;
      /// <summary> Пометка, является ли текущий адрес адресом основного шлюза </summary>
      property IsGateway: Boolean read FGateway write FGateway;
      /// <summary> Выходные данные </summary>
      property OutputData: IOutputData write FOutputData;
      /// <summary> Хендл семафора </summary>
      property Sem: THandle read FSem write FSem;
    end;

implementation

function TInputData.GetScanning: Integer;
begin
  Result := FScanning;
end;

function TInputData.GetAllScanning: Integer;
begin
  Result := FAllScanning;
end;

function TInputData.GetSem: THandle;
begin
  Result := FSem;
end;

procedure TInputData.SetSem(AValue: THandle);
begin
  FSem := AValue;
end;

function TInputData.GetPaused: Boolean;
begin
  Result := FPaused;
end;

procedure TInputData.SetPaused(AValue: Boolean);
begin
  FPaused := AValue;
end;

function TInputData.GetWorkThread: INetScannerWorkThread;
begin
  Result := FWorkThread;
end;

procedure TInputData.SetWorkThread(AValue: INetScannerWorkThread);
begin
  FWorkThread := AValue;
end;

constructor TInputData.Create;
begin
  Self.FData := TStringList.Create;
  Self.FLocalhostIP := GetLocalIP;
  Self.FGateway := GetGateway;
end;

destructor TInputData.Destroy;
begin
  FreeAndNil(FData);//.Free;
  FreeAndNil(FLocalhostIP);//.Free;
  FreeAndNil(FGateway);//Free;
  inherited;
end;

function TInputData.GetLocalIP: TStringList;
type
 TaPInAddr=array [0..10] of PInAddr;
 PaPInAddr=^TaPInAddr;
var
  PHE:PHostEnt;
  PPtr:PaPInAddr;
  Buffer:array [0..63] of AnsiChar;
  I:Integer;
  GInitData:TWSADATA;
  Output:  TStringList;
begin
  Result := nil;
  try
    WSAStartup(WSA_TYPE, GInitData);
    GetHostName(Buffer, SizeOf(Buffer));
    PHE:=GetHostByName(buffer);
    if PHE=nil then
      Exit;

    PPtr:=PaPInAddr(PHE^.h_addr_list);
    Output := TStringList.Create;
    I:=0;
    while PPtr^[i]<>nil do
    begin
      Output.Add(string(StrPas(inet_ntoa(PPtr^[i]^))));
      Inc(I);
    end;
    Result := Output;
  finally
    WSACleanup;
  end;
end;

function TInputData.GetGateway: TStringList;
var
  InterfaceInfo,
  TmpPointer: PIP_ADAPTER_INFO;
  Len: ULONG;
  ResultStrings: TStringList;
begin
  ResultStrings := TStringList.Create;
  Result := ResultStrings;
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
          // основной шлюз:
          if string(TmpPointer^.GatewayList.IpAddress.S)<>'' then
            ResultStrings.Add(string(TmpPointer^.GatewayList.IpAddress.S));

          TmpPointer := TmpPointer.Next;
        until TmpPointer = nil;
        // Получаем адрес основного шлюза
      end;
    finally
      // Освобождаем занятую память
      FreeMem(InterfaceInfo);
    end;
  end;
end;

procedure TInputData.CreateThread(IP: string; AOutData: IOutputData);
var
  w:        TThreadScanIP;
  I:        Integer;
  //WaitReturn: DWORD;
begin
  if (Self<> nil) and (Self.FWorkThread <> nil) and (Self.FWorkThread.GetPaused) then
    FWorkThread.Event.Waitfor(infinite);

  if (Self = nil) or (Self.FWorkThread = nil) or (Self.FWorkThread.IsThreadTerminated) then
    Exit;

  //WaitReturn :=
  WaitForSingleObject(FSem, INFINITE);
  //if WaitReturn <> WAIT_OBJECT_0 then
  //  Exit;
  w := TThreadScanIP.Create(true);
  w.Priority:=tplower;
  w.FreeOnTerminate:=true;
  w.IP := IP;
  //w.IP := IntToStr(A1)+'.'+IntToStr(A2)+'.'+IntToStr(A3)+'.'+IntToStr(A4);
  w.Sem := Self.FSem;

  if FGateway <> nil then
    for I := 0 to Self.FGateway.Count-1 do
      if Self.FGateway[I] = w.IP then
      begin
        // для локального адреса ставим пометку, что копмьютер локальный
        w.IsGateway := True;
        //break;
      end;
  //w.LocalhostIP := Self.FLocalhostIP;
  if Self.FLocalhostIP <> nil then
    for I := 0 to Self.FLocalhostIP.Count-1 do
      if Self.FLocalhostIP[I] = w.IP then
      begin
        // для локального адреса ставим пометку, что копмьютер локальный
        w.IsLocalhostIP := True;
        break;
      end;
  w.OutputData := AOutData;
  AOutData := nil;
  w.Start;
  Inc(Self.Fscanning);
end;

procedure TInputData.CreateThread(A1,A2,A3,A4: Byte; AOutData: IOutputData);
begin
  CreateThread(IntToStr(A1)+'.'+IntToStr(A2)+'.'+IntToStr(A3)+'.'+IntToStr(A4), AOutData);
  //w.IP := IntToStr(A1)+'.'+IntToStr(A2)+'.'+IntToStr(A3)+'.'+IntToStr(A4);
end;

procedure TInputRange.SetData(const IPFrom,IPTo: string);
var
  Addr: ULONG;
begin
  Addr := inet_addr(PAnsiChar(PAnsiString(AnsiString(IPFrom))));
  if Addr = INADDR_NONE then
    raise Exception.Create('Неверно задан параметр');
  Self.FData.Add(IPFrom);
  Addr := inet_addr(PAnsiChar(PAnsiString(AnsiString(IPTo))));
  if Addr = INADDR_NONE then
    raise Exception.Create('Неверно задан параметр');
  Self.FData.Add(IPTo);
  //inherited;
end;

procedure TInputRange.Scan(AOutData: IOutputData);
var
  BeginAddr,EndAddr,N:  Cardinal;
function IP2Int(AIP:string):cardinal;//перевод ip адрес в число
var
  Ok1,Ok2,Ok3,Ok4:string;
begin
  Ok1:=copy(AIP,1,pos('.',AIP)-1);
  delete(AIP,1,length(Ok1)+1);
  Ok2:=copy(AIP,1,pos('.',AIP)-1);
  delete(AIP,1,length(Ok2)+1);
  Ok3:=copy(AIP,1,pos('.',AIP)-1);
  delete(AIP,1,length(Ok3)+1);
  Ok4:=AIP;
  Result:=strtoint(Ok1)*256*256*256+strtoint(Ok2)*256*256+strtoint(Ok3)*256+strtoint(Ok4);
end;
function Int2IP(n:cardinal):string;//перевод числа в ip адресс
var
  Ok1,Ok2,Ok3,Ok4:Byte;
begin
  Ok1:=trunc(n/(256*256*256));
  Ok2:=trunc((n-Ok1*(256*256*256))/(256*256));
  Ok3:=trunc((n-Ok1*(256*256*256)-Ok2*(256*256))/256);
  Ok4:=n-Ok1*(256*256*256)-Ok2*(256*256)-Ok3*256;
  Result:=inttostr(Ok1)+'.'+inttostr(Ok2)+'.'+inttostr(Ok3)+'.'+inttostr(Ok4);
end;
begin
  BeginAddr := IP2Int(Self.FData[0]);
  EndAddr := IP2Int(Self.FData[1]);
  Self.FAllScanning := EndAddr - BeginAddr + 1;
  for N := BeginAddr to EndAddr do
    if (N mod 256) in [0, 255] then
      Dec(Self.FAllScanning);

  for N := BeginAddr to EndAddr do
    if (N mod 256 <> 0 ) and (N mod 256 <> 255) then
      CreateThread(Int2IP(N), AOutData);
end;

procedure TInputMaskIP.SetData(const IP, Mask: string);
var
  Addr: ULONG;
begin
  Addr := inet_addr(PAnsiChar(PAnsiString(AnsiString(IP))));
  if Addr = INADDR_NONE then
    raise Exception.Create('Неверно задан IP-адрес.') ;

  Addr := inet_addr(PAnsiChar(PAnsiString(AnsiString(Mask))));
  if Addr = INADDR_NONE then
    raise Exception.Create('Неверно задана маска сети.') ;

  Self.FData.Add(IP);
  Self.FData.Add(Mask);
  //inherited;
end;

procedure TInputMaskIP.Scan(AOutData: IOutputData);
var
  ArIP:  array[0..3] of Byte;
  I,J,K: Byte;
procedure SetIPElements(AIPFrom:string);
var
  IP :string;
begin
  J := pos('.', AIPFrom);
  ArIP[0] := StrToInt(copy(AIPFrom,0,J-1));
  IP := copy(AIPFrom,J+1,length(AIPFrom)-J+1);
  J := pos('.', IP);
  ArIP[1] :=StrToInt(copy(IP,0,J-1));
  IP := copy(IP,J+1,length(IP)-J+1);
  J := pos('.', IP);
  ArIP[2] := StrToInt(copy(IP,0,J-1));
  IP := copy(IP,J+1,length(IP)-J+1);
  ArIP[3] := StrToInt(IP);
  if (ArIP[0]<1) or (ArIP[0]>254)
     or (ArIP[1]>254)
     or (ArIP[2]>254)
     and (ArIP[3]<1) or (ArIP[3]>254) then
     raise Exception.Create('IP-адрес выходит за допустимый диапазон');;
end;
// тело ф-ии TInputMaskIP.Scan
begin
  SetIPElements(Self.FData[0]);
  if Self.FData[1] = '255.255.255.0' then
  begin
    Self.FAllScanning := 254;
    for I := 1 to 254 do
    begin
      CreateThread(ArIP[0],ArIP[1],ArIP[2],I,AOutData);
      //inc(Self.scanned);
    end;
  end
  else
    if Self.FData[1] = '255.255.0.0' then
    begin
      Self.FAllScanning := 255*254;
      for I := 0 to 254 do
        for J := 1 to 254 do
        begin
          CreateThread(ArIP[0],ArIP[1],I,J,AOutData);
          //Inc(Self.scanned);
        end;
    end
  else
    if Self.FData[1] = '255.0.0.0' then
    begin
      Self.FAllScanning := 255*255*254;
      for I := 0 to 254 do
        for J := 0 to 254 do
          for K := 1 to 254 do
            begin
            CreateThread(ArIP[0],I,J,K,AOutData);
            //Inc(Self.scanned);
            end;
    end;
end;

procedure TInputGUID.SetData(const GUID,Null: string);
begin
  Self.FData.Add(GUID);
  //inherited;
end;

procedure TInputGUID.Scan;
var
//  I,J,K : Integer;
  ArIP:  array[0..3] of Byte;
  IP, Mask: string;
  IPAndMask:   TStringList;

procedure SetIPElements(AIPFrom:string);
var
  J: Integer;
  IP :string;
begin
  J := pos('.', AIPFrom);
  ArIP[0] := StrToInt(copy(AIPFrom,0,J-1));
  IP := copy(AIPFrom,J+1,length(AIPFrom)-J+1);
  J := pos('.', IP);
  ArIP[1] :=StrToInt(copy(IP,0,J-1));
  IP := copy(IP,J+1,length(IP)-J+1);
  J := pos('.', IP);
  ArIP[2] := StrToInt(copy(IP,0,J-1));
  IP := copy(IP,J+1,length(IP)-J+1);
  ArIP[3] := StrToInt(IP);
  if (ArIP[0]<1) or (ArIP[0]>254)
     or (ArIP[1]>254)
     or (ArIP[2]>254)
     and (ArIP[3]<1) or (ArIP[3]>254) then
     raise Exception.Create('IP-адрес выходит за допустимый диапазон');;
end;

procedure MaskRangeScan;
var
  I,J,K: Byte;
begin
  SetIPElements(IP);
  if Mask = '255.255.255.0' then
    begin
    Self.FAllScanning := 254;
    for I := 1 to 254 do
    begin
      CreateThread(ArIP[0],ArIP[1],ArIP[2],I,AOutData);
      //inc(Self.scanned);
    end;
    end
  else
    if Mask = '255.255.0.0' then
    begin
      Self.FAllScanning := 255*254;
      for I := 0 to 254 do
        for J := 1 to 254 do
        begin
          CreateThread(ArIP[0],ArIP[1],I,J,AOutData);
          //Inc(Self.scanned);
        end;
    end
  else
    if Mask = '255.0.0.0' then
    begin
      Self.FAllScanning := 255*255*254;
      for I := 0 to 254 do
        for J := 0 to 254 do
          for K := 1 to 254 do
          begin
            CreateThread(ArIP[0],I,J,K,AOutData);
            //Inc(Self.scanned);
          end;
    end;
end;
begin
  IPAndMask := GetIPAndMaskByGuid(Self.FData[0]);
  if IPAndMask.Count = 2 then
  begin
    IP := IPAndMask[0];
    Mask := IPAndMask[1];
    MaskRangeScan;
  end;
end;

function TInputGUID.GetIPAndMaskByGuid(AAdapterName: string): TStringList;
var
  InterfaceInfo,
  TmpPointer: PIP_ADAPTER_INFO;
  IP: PIP_ADDR_STRING;
  Len: ULONG;
  Ext:        boolean;
  AdapterNameEx:    string;
  AdapterNameList:      TStringList;
begin
  Result := nil;
  // Смотрим сколько памяти нам требуется?
  if GetAdaptersInfo(nil, Len) = ERROR_BUFFER_OVERFLOW then
  begin
    // Берем нужное кол-во
    GetMem(InterfaceInfo, Len);
    try
      // выполнение функции
      if GetAdaptersInfo(InterfaceInfo, Len) = ERROR_SUCCESS then
      begin
        Ext := false;
        AdapterNameList := TStringList.Create;
         // Перечисляем все сетевые интерфейсы
        TmpPointer := InterfaceInfo;
        repeat
          // Имя сетевого интерфейса
          AdapterNameEx := string(TmpPointer^.AdapterName);
          //AdapterName := AdapterNameEx;
          //for
          if AAdapterName = AdapterNameEx then
          begin
            Ext := true;
            //Alist.Add(TmpPointer^.AdapterName);
            // перечисляем все IP адреса интерфейса
            IP := @TmpPointer.IpAddressList;
            //repeat
            AdapterNameList.Add(string(IP^.IpAddress.S));
            AdapterNameList.Add(string(IP^.IpMask.S));
            //  IP := IP.Next;
            //until IP = nil;
          end;
          TmpPointer := TmpPointer.Next;
        until (TmpPointer = nil) or ext;
        Result := AdapterNameList;
      end;
    finally
      // Освобождаем занятую память
      FreeMem(InterfaceInfo);
    end;
  end;
end;

procedure TInputAddressList.SetData(AAddressList: TStringList);
var
  Addr: ULONG;
  I:    Integer;
begin
  for I := 0 to AAddressList.Count-1 do
  begin
    Addr := inet_addr(PAnsiChar(PAnsiString(AnsiString(AAddressList[I]))));
    if Addr = INADDR_NONE then
    begin
      ShowMessage('Неверно задан IP-aдрес.');
      Continue;
    end;

    Self.FData.Add(AAddressList[I]);
  end;
  //inherited;
end;

procedure TInputAddressList.Scan(AOutData: IOutputData);
var
  I: Integer;
begin
  FAllScanning := FData.Count;
  for I := 0 to FData.Count-1 do
    CreateThread(FData[I],AOutData);
end;

function TNetScannerWorkThread.GetPaused: Boolean;
begin
  Result := FPaused;
end;

procedure TNetScannerWorkThread.SetPaused(AValue: Boolean);
begin
  FPaused := AValue;
end;

function TNetScannerWorkThread.GetEvent: TEvent;
begin
  Result := FEvent;
end;

procedure TNetScannerWorkThread.SetAEvent(AValue: TEvent);
begin
  FEvent := AValue;
end;

function TNetScannerWorkThread.GetInputData: IInputData;
begin
  Result := FInputData;
end;

procedure TNetScannerWorkThread.SetInputData(AValue: IInputData);
begin
  FInputData := AValue;
end;

function TNetScannerWorkThread.QueryInterface(const IID:TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := Windows.E_NoInterface;
end;

function TNetScannerWorkThread._AddRef: Integer;
begin
  Result := -1
end;

function TNetScannerWorkThread._Release: Integer;
begin
  Result := -1
end;

function TNetScannerWorkThread.GetTerminated: Boolean;
begin
  Result := Self.Terminated;
end;

function TNetScannerWorkThread.GetScanning: Integer;
begin
  if (Self <> nil) and (Self.FInputData <> nil) then
    Result := Self.FInputData.Scanning
  else
    Result := 0;
end;

function TNetScannerWorkThread.GetAllScanning: Integer;
begin
  if (Self <> nil) and (Self.FInputData <> nil) then
    Result := Self.FInputData.AllScanning
  else
    Result := 0;
end;

function TNetScannerWorkThread.GetScanLeft: Integer;
begin
  if Self <> nil then
    Result := Self.GetAllScanning - Self.GetScanned
  else
    Result := 0;
end;

function TNetScannerWorkThread.GetScanned: Integer;
begin
  if (Self <> nil) and (Self.FOutputData <> nil) then
    Result := Self.FOutputData.Scanned
  else
    Result := 0;
end;

function TNetScannerWorkThread.GetResultsList:  IOutputData;
begin
  if (Self <> nil) and (Self.FOutputData <> nil) then
    Result := Self.FOutputData.GetResultsList;
end;

procedure TNetScannerWorkThread.Execute;
begin
  try
    if Self.FOutputData <> nil then
      Self.FInputData.Scan(Self.FOutputData);
  finally
    Self.Terminate;
  end;
end;

constructor TNetScannerWorkThread.Create(AInputData: IInputData);
//var
//  WorkThread: INetScannerWorkThread;
begin
  inherited Create(True);
  Self.Priority := tpLower;
  if AInputData = nil then
    raise Exception.Create('Передан параметр, равный nil');

  Self.FInputData := AInputData;
  //WorkThread := Self;
  Self.FInputData.WorkThread := Self;
  Self.FInputData.Sem := CreateSemaphore(nil, RES_THREAD_COUNT, RES_THREAD_COUNT, nil);
  // Создаем событие до того как будем его использовать
  Self.Event :=TEvent.Create(nil,true,true,'');
  Self.FOutputData := TOutputData.Create;
end;

destructor TNetScannerWorkThread.Destroy;
begin
  if Assigned(Self)then
  begin
    if Assigned(FInputData) then
    begin
      CloseHandle(Self.FInputData.Sem);
      Self.FInputData := nil;
    end;
    if Assigned(FOutputData) then
      //FreeAndNil(FOutputData);
      FOutputData := nil;

    if Assigned(Self.Event) then
      // Удаляем событие
      FreeAndNil(FEvent);//.Free;
  end;
  //inherited;
end;

destructor TThreadScanIP.Destroy;
begin
  FOutputData := nil;
end;

procedure TThreadScanIP.Execute;
begin
  try
    if Assigned(FOutputData) then
      FOutputData.IncThreads;

    try
      ScanIP;

    except
      on E : Exception do
        begin
        ShowMessage(E.Message);
        end;
    end;
  finally
    if Assigned(FOutputData) then
    begin
      FOutputData.IncScanned;
      FOutputData.DecThreads;
    end;
    ReleaseSemaphore(Sem, 1, nil);
  end;
end;

procedure TThreadScanIP.ScanIP;
var
  Item:     TOutputDataString;
  I:        Integer;
begin
  Item:= TOutputDataString.Create(Self.FIP,
                                  RES_UNKNOWN,
                                  RES_UNKNOWN,
                                  RES_UNKNOWN,
                                  RES_UNKNOWN);
  if Self.FLocalhostIP then
  begin
    // для локального адреса ставим пометку, что копмьютер локальный
    Item.Comment := RES_COMPUTER;
    // устанавливает поля: мас-адрес и описание для локального пк
    Item.SetMacAndDescription;
  end
  else
  begin
  // установка MAC-адреса
  // (корректно только для удаленных пк)
    Item.SetMacFromIP;
    if item.MACAddress = RES_UNKNOWN then
      Item.SetMacFromIP1;
  end;

  // установка поле имя в классе
  Item.SetNameFromIP;
  /// определяем является ли имя сетевого интерфейса фиктивным: 0 - нет, не 0 - да.
  I := pos('.loc',Item.DeviceName);
  if i <> 0 then
    item.DeviceName := RES_UNKNOWN;

  if ((item.MACAddress <> RES_UNKNOWN) and (item.MACAddress <> '00-00-00-00-00-00')) or (item.DeviceName <> RES_UNKNOWN) then
  begin
    if Self.FGateway then
      item.Comment := RES_ROUTER;

    ItemAdd(item);
  end
  else
    FreeAndNil(Item);//.Free
end;

procedure TThreadScanIP.ItemAdd(const AItem: IOutputDataString);
begin
  Self.FOutputData.Add(AItem);
end;

end.
