/// <summary>
///  ���������� ������� ���� NetScanner. ������ �������� ����� �����������
///  ����������� ������� �������.
/// </summary>
unit NetScanner.Interfaces;

interface

uses
  Classes,
  Windows,
  syncobjs;

type
    /// <summary> ��������� ����� ������ �������� ������ </summary>
    IOutputDataString = interface
      /// <summary> �������� ���-����� �� ������� Byte � ������ ALength </summary>
      function GetMAC(AValue: array of Byte; ALength: DWORD): string;
      /// <summary> ���������� ����� MACAddress � AdapterDescription ��� ���������� �� </summary>
      procedure SetMacAndDescription;
      /// <summary> ���������� ���� DeviceName </summary>
      procedure SetNameFromIP;
      /// <summary> ���������� ���� MAC ��� ���������� �� </summary>
      procedure SetMacFromIP;
      /// <summary> ���������� ���� MAC ��� ���������� �� </summary>
      procedure SetMacFromIP1;
      // �-�� � ��������� �������
      function GetIPAddress: string;
      procedure SetIPAddress(AValue: string);
      function GetDeviceName: string;
      procedure SetDeviceName(AValue: string);
      function GetMACAddress: string;
      procedure SetMACAddress(AValue: string);
      function GetAdapterDescription: string;
      procedure SetAdapterDescription(AValue: string);
      function GetComment: string;
      procedure SetComment(AValue: string);
      /// <summary> IP-����� </summary>
      property IPAddress: string read GetIPAddress write SetIPAddress;// read FIPAddress write FIPAddress;
      /// <summary> �������� ���������� (��� �����) </summary>
      property DeviceName: string read GetDeviceName write SetDeviceName;// read FDeviceName write FDeviceName;
      /// <summary> ���������� ����� (���-�����) </summary>
      property MACAddress: string read GetMACAddress write SetMACAddress;// read FMACAddress write FMACAddress;
      /// <summary> �������� �������� ���������� </summary>
      property AdapterDescription: string read GetAdapterDescription write SetAdapterDescription;// read FAdapterDescription write FAdapterDescription;
      /// <summary> ���������������� ��� ���������� </summary>
      property Comment: string read GetComment write SetComment;// read FComment write FComment;
    end;

    /// <summary> ��������� ��������� �������� ������ </summary>
    IOutputData = interface
      /// <summary> ���������� ������ � ������ ����������� </summary>
      procedure Add(ADataString: IOutputDataString);
      /// <summary> ��������� �������� ������ </summary>
      function GetResultsList: IOutputData;
      /// <summary> �������� AI-�� ������� </summary>
      function GetElement(AI: Integer): IOutputDataString;
      /// <summary> �������� ����� ��������� </summary>
      function Count: Integer;
      /// <summary> ��������� ����� ���������� ������� <summary>
      procedure IncThreads;
      /// <summary> ��������� ����� ���������� ������� <summary>
      procedure DecThreads;
      /// <summary> �������� ����� ���������� ������� <summary>
      function GetThreadsCount: Integer;
      /// <summary> �������� ����� ���������������� ������� <summary>
      function GetScanned: Integer;
      /// <summary> ��������� ����� ���������������� ������� <summary>
      procedure IncScanned;
     /// <summary> ���������� ���������������� ������� </summary>
      property Scanned: Integer read GetScanned;// write SetScanned;
    end;

    // ����������� ����������
    IInputData = interface;

    /// <summary> ��������� �������� ������ ������� ������������ </summary>
    INetScannerWorkThread = interface
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
      /// <summary> �������� ��������� �������� ��������� </summary>
      function GetResultsList:  IOutputData;
      /// <summary> ���������� ����� ������������ </summary>
      property Scanning: Integer read GetScanning;
      /// <summary> ��������������� </summary>
      property Scanned: Integer read GetScanned;
      /// <summary> ����� �������������� </summary>
      property AllScanning: Integer read GetAllScanning;
      /// <summary> �������� �������������� </summary>
      property ScanLeft: Integer read GetScanLeft;
      /// <summary> �������� ��� ���������� ���� ����� ������������ </summary>
      property IsPaused: Boolean read GetPaused write SetPaused;
      /// <summary> �������� ��� ���������� ������� ����� </summary>
      property Event: TEvent read GetEvent write SetAEvent;
      /// <summary> �������� ���� ���������� ������ </summary>
      property IsThreadTerminated: Boolean read GetTerminated;
      /// <summary> ������� ������ </summary>
      property InputData : IInputData read GetInputData write SetInputData;
    end;

    /// <summary> ��������� ������ ������� ������</summary>
    IInputData = interface
      function GetScanning: Integer;
      function GetAllScanning: Integer;
      function GetSem: THandle;
      procedure SetSem(AValue: THandle);
      function GetPaused: Boolean;
      procedure SetPaused(AValue: Boolean);
      function GetWorkThread: INetScannerWorkThread;
      procedure SetWorkThread(AValue: INetScannerWorkThread);
      /// <summary> ������ ������� ������ </summary>
      procedure SetData(AAddressList: TStringList);overload;//virtual; abstract;
      procedure SetData(const A1,A2: string);overload;
      /// <summary> ��������� ������������ </summary>
      procedure Scan(AOutputD: IOutputData);//virtual;abstract;
      /// <summary> ������� ���������� ����� ������������ ������ </summary>
      property Scanning: Integer read GetScanning;
      /// <summary> ����� ��������� �������������� </summary>
      property AllScanning: Integer read GetAllScanning;
      /// <summary> �������, ��� ����������� ����� ���������� ������������ </summary>
      property Sem: THandle read GetSem write SetSem;
       /// <summary> ���� ������������ ���������� �������� ������ �� ����� </summary>
      property Paused: Boolean read GetPaused write SetPaused;
      /// <summary> ������� ����� ������� ������������ IP-������� </summary>
      property WorkThread: INetScannerWorkThread read GetWorkThread write SetWorkThread;
    end;

    /// <summary> ��������� ��������� ����������� ������������ </summary>
    IScanningResults = interface
      /// <summary> �������� �������������� ������ </summary>
      function GetResultsList:  IOutputData;
      /// <summary> �������� ����� ���������������� </summary>
      function GetScanned: Integer;
      /// <summary> �������� ����� ����������� </summary>
      function GetAllScanning: Integer;
      /// <summary> �������� ����� ���������� �������������� </summary>
      function GetScanLeft: Integer;
      /// <summary> ����� �� ������� ���������� </summary>
      function IsCanClose: Boolean;
    end;

    /// <summary> ��������� ���������� ������������ </summary>
    IScanningManagement = interface
      /// <summary> ������ ����� ������������ � �������� ����������� AInputData</summary>
      function StartScanning(AInputData: IInputData): IScanningResults;
      /// <summary> �������������, ����������� ������������ </summary>
      procedure PausePlayScanning;
      /// <summary> ���������� ������������ </summary>
      procedure StopScanning;
      /// <summary> ��������� ��������� ������, ������������ ������������ </summary>
      function GetScanningState: Integer;
      /// <summary> ����� �� ������� ���������� </summary>
      //function IsCanClose: Boolean;
    end;

implementation

end.
