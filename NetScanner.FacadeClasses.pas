/// <summary>
///  ���������� ������� ���� NetScanner. ������ �������� �����
///  ������� ������� ������� �������.
/// </summary>
unit NetScanner.FacadeClasses;

interface

uses
  SysUtils,
  NetScanner.Work,
  NetScanner.Interfaces;

type
    /// <summary> ����� ��� �������, ������������, ��������� ������������ </summary>
    TNetScannerManagement = class(TInterfacedObject, IScanningManagement)
    private
      FNetScannerWorkThread:     TNetScannerWorkThread;
    protected
    public
      //constructor Create(AInputData: TInputData);
      destructor Destroy; override;
      /// <summary> ��������� ����� ������������ </summary>
      function StartScanning(AInputData: IInputData): IScanningResults;
      /// <summary> �������������, ������������ ������������ </summary>
      procedure PausePlayScanning;
      /// <summary> ���������� ������������ </summary>
      procedure StopScanning;
      /// <summary> ��������� ��������� ������, ������������ ������������ </summary>
      function GetScanningState: Integer;
      //property InputData: TInputData read FInputData write FInputData;
      /// <summary> ����� �� ������� ���������� </summary>
      //function IsCanClose: Boolean;
    end;

    /// <summary> ����� � ������������ ������������ </summary>
    TNetScannerResults = class(TInterfacedObject,IScanningResults)
    private
      FNetScannerWorkThread: INetScannerWorkThread;
    protected
    public
      constructor Create(FNetScannerWorkThread: INetScannerWorkThread);
      destructor Destroy; override;
      /// <summary> �������� �������������� ������ </summary>
      function GetResultsList:  IOutputData;
      /// <summary> �������� ����� ���������������� </summary>
      function GetScanned: Integer;
      /// <summary> �������� ����� ����������� </summary>
      function GetAllScanning: Integer;
      /// <summary> �������� �������������� </summary>
      function GetScanLeft: Integer;
      /// <summary> ����� �� ������� ���������� </summary>
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
      // ������������� �������
      // wait-������� ����� ���������� ���������� �����
      FNetScannerWorkThread.IsPaused := False; //Start
      FNetScannerWorkThread.Event.SetEvent;
    end
    else if not FNetScannerWorkThread.IsThreadTerminated then
    begin
      // wait-������� ��������� ���������� ���� ������
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
