/// <summary>
///  Реализация сканера сети NetScanner. Модуль содержит набор
///  главных классов системы классов.
/// </summary>
unit NetScanner.FacadeClasses;

interface

uses
  SysUtils,
  NetScanner.Work,
  NetScanner.Interfaces;

type
    /// <summary> Класс для запуска, приостановки, остановки сканирования </summary>
    TNetScannerManagement = class(TInterfacedObject, IScanningManagement)
    private
      FNetScannerWorkThread:     TNetScannerWorkThread;
    protected
    public
      //constructor Create(AInputData: TInputData);
      destructor Destroy; override;
      /// <summary> Запустить новое сканирование </summary>
      function StartScanning(AInputData: IInputData): IScanningResults;
      /// <summary> Приостановить, возообновить сканирование </summary>
      procedure PausePlayScanning;
      /// <summary> Остановить сканирование </summary>
      procedure StopScanning;
      /// <summary> Получение состояния потока, запускающего сканирования </summary>
      function GetScanningState: Integer;
      //property InputData: TInputData read FInputData write FInputData;
      /// <summary> Можно ли закрыть приложение </summary>
      //function IsCanClose: Boolean;
    end;

    /// <summary> Класс с результатами сканирования </summary>
    TNetScannerResults = class(TInterfacedObject,IScanningResults)
    private
      FNetScannerWorkThread: INetScannerWorkThread;
    protected
    public
      constructor Create(FNetScannerWorkThread: INetScannerWorkThread);
      destructor Destroy; override;
      /// <summary> Получить результирующие данные </summary>
      function GetResultsList:  IOutputData;
      /// <summary> Получить число просканированных </summary>
      function GetScanned: Integer;
      /// <summary> Получить число сканируемых </summary>
      function GetAllScanning: Integer;
      /// <summary> Осталось просканировать </summary>
      function GetScanLeft: Integer;
      /// <summary> Можно ли закрыть приложение </summary>
      function IsCanClose: Boolean;
    end;

implementation

function TNetScannerManagement.StartScanning(AInputData: IInputData): IScanningResults;
begin
  if Assigned(FNetScannerWorkThread) and (GetScanningState = -1) then
  begin
    FNetScannerWorkThread.FreeOnTerminate := True;
    StopScanning;
    //TerminateThread(FNetScannerWorkThread.Handle, 0);
    //FNetScannerWorkThread.Free;
    if Assigned(FNetScannerWorkThread) then
      FreeAndNil(FNetScannerWorkThread);
  end;
  if FNetScannerWorkThread = nil then
  begin
    if Assigned(AInputData) then
    begin
      FNetScannerWorkThread := TNetScannerWorkThread.Create(AInputData);
      FNetScannerWorkThread.Start;
      Result := TNetScannerResults.Create(FNetScannerWorkThread);
    end;
  end;
end;

procedure TNetScannerManagement.PausePlayScanning;
begin
  if (FNetScannerWorkThread <> nil) and (FNetScannerWorkThread.Event <> nil) then
  begin
    if FNetScannerWorkThread.IsPaused then //Suspended then
    begin
      // Устанавливаем событие
      // wait-функция будет фозвращать управление сразу
      FNetScannerWorkThread.IsPaused := False; //Start
      FNetScannerWorkThread.Event.SetEvent;
    end
    else if not FNetScannerWorkThread.IsThreadTerminated then
    begin
      // wait-функция блокирует выполнение кода потока
      FNetScannerWorkThread.Event.ResetEvent;
      FNetScannerWorkThread.IsPaused := True; //Suspend;
    end;
  end;
end;

procedure TNetScannerManagement.StopScanning;
begin
  if (Self <> nil) and (FNetScannerWorkThread <> nil) then
  begin
    FNetScannerWorkThread.Terminate;
    FNetScannerWorkThread.IsPaused := False; //Start
    if Assigned(FNetScannerWorkThread.Event) then
      FNetScannerWorkThread.Event.SetEvent;

    //FNetScannerWorkThread.FreeOnTerminate := True;
  end;
end;

destructor TNetScannerManagement.Destroy;
begin
  if Assigned(FNetScannerWorkThread) then
  begin
    FNetScannerWorkThread.FreeOnTerminate := True;
    StopScanning;
    //TerminateThread(FNetScannerWorkThread.Handle, 0);
    FreeAndNil(FNetScannerWorkThread);
  end;
  //  FNetScannerWorkThread.Free;
  //FInputData.Free;
  inherited;
end;

function TNetScannerManagement.GetScanningState: Integer;
begin
  if FNetScannerWorkThread.IsPaused then //Suspended then
    Result := 0//paused
  else if not FNetScannerWorkThread.IsThreadTerminated then
    Result := 1//running
  else
    Result := -1;//stopped
end;

//function TNetScannerManagement.IsCanClose: Boolean;
//begin
//  Result := Self.GetScanningState = -1
//end;

constructor TNetScannerResults.Create(FNetScannerWorkThread: INetScannerWorkThread);
begin
  Self.FNetScannerWorkThread := FNetScannerWorkThread;// as TNetScannerWorkThread;
end;

destructor TNetScannerResults.Destroy;
begin
  Self.FNetScannerWorkThread := nil;
end;

function TNetScannerResults.GetScanned: Integer;
begin
  if (Self <> nil) and (FNetScannerWorkThread <> nil) then
    Result := FNetScannerWorkThread.Scanned
  else
    Result := 0;
end;

function TNetScannerResults.GetAllScanning: Integer;
begin
  if (Self <> nil) and (FNetScannerWorkThread <> nil) then
    Result := FNetScannerWorkThread.AllScanning
  else
    Result := 0;
end;

function TNetScannerResults.GetScanLeft: Integer;
begin
  if (Self <> nil) and (FNetScannerWorkThread <> nil) then
    Result := FNetScannerWorkThread.ScanLeft
  else
    Result := 0;
end;

function TNetScannerResults.GetResultsList:  IOutputData;
begin
  if (Self <> nil) and (FNetScannerWorkThread <> nil) then
    Result := FNetScannerWorkThread.GetResultsList
  else
    Result := nil;
end;

function TNetScannerResults.IsCanClose: Boolean;
var
  res: IOutputData;
begin
  Result := True;
  res := Self.GetResultsList;
  if Assigned(res) then
    Result := res.GetThreadsCount = 0;
end;

end.
