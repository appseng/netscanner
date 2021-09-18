/// <summary>
///  Реализация сканера сети NetScanner. Модуль содержит набор интерфейсов
///  построенной системы классов.
/// </summary>
unit NetScanner.Interfaces;

interface

uses
  Classes,
  Windows,
  syncobjs;

type
    /// <summary> Интерфейс одной порции выходных данных </summary>
    IOutputDataString = interface
      /// <summary> Получить МАС-адрес из массива Byte и длиной ALength </summary>
      function GetMAC(AValue: array of Byte; ALength: DWORD): string;
      /// <summary> Установить полей MACAddress и AdapterDescription для локального ПК </summary>
      procedure SetMacAndDescription;
      /// <summary> Установить поле DeviceName </summary>
      procedure SetNameFromIP;
      /// <summary> Установить поле MAC для удаленного ПК </summary>
      procedure SetMacFromIP;
      /// <summary> Установить поле MAC для удаленного ПК </summary>
      procedure SetMacFromIP1;
      // ф-ии и процедуры свойств
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
      /// <summary> IP-адрес </summary>
      property IPAddress: string read GetIPAddress write SetIPAddress;// read FIPAddress write FIPAddress;
      /// <summary> Название устройства (имя хоста) </summary>
      property DeviceName: string read GetDeviceName write SetDeviceName;// read FDeviceName write FDeviceName;
      /// <summary> Физический адрес (МАС-адрес) </summary>
      property MACAddress: string read GetMACAddress write SetMACAddress;// read FMACAddress write FMACAddress;
      /// <summary> Название адаптера устройства </summary>
      property AdapterDescription: string read GetAdapterDescription write SetAdapterDescription;// read FAdapterDescription write FAdapterDescription;
      /// <summary> Пользовательское имя устройства </summary>
      property Comment: string read GetComment write SetComment;// read FComment write FComment;
    end;

    /// <summary> Интерфейс хранилища выходных данных </summary>
    IOutputData = interface
      /// <summary> Добавление строки к списку результатов </summary>
      procedure Add(ADataString: IOutputDataString);
      /// <summary> Получение выходных данных </summary>
      function GetResultsList: IOutputData;
      /// <summary> Получить AI-ый элемент </summary>
      function GetElement(AI: Integer): IOutputDataString;
      /// <summary> Получить число элементов </summary>
      function Count: Integer;
      /// <summary> Увеличить число запущенных потоков <summary>
      procedure IncThreads;
      /// <summary> Уменьшить число запущенных потоков <summary>
      procedure DecThreads;
      /// <summary> Получить число запущенных потоков <summary>
      function GetThreadsCount: Integer;
      /// <summary> Получить число просканированных адресов <summary>
      function GetScanned: Integer;
      /// <summary> Увеличить число просканированных адресов <summary>
      procedure IncScanned;
     /// <summary> Количество просканированных адресов </summary>
      property Scanned: Integer read GetScanned;// write SetScanned;
    end;

    // опережающее объявление
    IInputData = interface;

    /// <summary> Интерфейс рабочего потока запуска сканирования </summary>
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
      /// <summary> Получить хранилище выходных элементов </summary>
      function GetResultsList:  IOutputData;
      /// <summary> Порядковый номер сканируемого </summary>
      property Scanning: Integer read GetScanning;
      /// <summary> Просканированно </summary>
      property Scanned: Integer read GetScanned;
      /// <summary> Всего просканировать </summary>
      property AllScanning: Integer read GetAllScanning;
      /// <summary> Осталось просканировать </summary>
      property ScanLeft: Integer read GetScanLeft;
      /// <summary> Получить или установить флаг паузы сканирования </summary>
      property IsPaused: Boolean read GetPaused write SetPaused;
      /// <summary> Получить или установить событие паузы </summary>
      property Event: TEvent read GetEvent write SetAEvent;
      /// <summary> Получить флаг завершения потока </summary>
      property IsThreadTerminated: Boolean read GetTerminated;
      /// <summary> Входные данные </summary>
      property InputData : IInputData read GetInputData write SetInputData;
    end;

    /// <summary> Интерфейс класса входных данных</summary>
    IInputData = interface
      function GetScanning: Integer;
      function GetAllScanning: Integer;
      function GetSem: THandle;
      procedure SetSem(AValue: THandle);
      function GetPaused: Boolean;
      procedure SetPaused(AValue: Boolean);
      function GetWorkThread: INetScannerWorkThread;
      procedure SetWorkThread(AValue: INetScannerWorkThread);
      /// <summary> Задать входные данные </summary>
      procedure SetData(AAddressList: TStringList);overload;//virtual; abstract;
      procedure SetData(const A1,A2: string);overload;
      /// <summary> Процедура сканирования </summary>
      procedure Scan(AOutputD: IOutputData);//virtual;abstract;
      /// <summary> Текущий порядковый номер сканируемого адреса </summary>
      property Scanning: Integer read GetScanning;
      /// <summary> Всего предстоит просканировать </summary>
      property AllScanning: Integer read GetAllScanning;
      /// <summary> Семафор, для ограничения числа запущенных сканирований </summary>
      property Sem: THandle read GetSem write SetSem;
       /// <summary> Флаг показывающий нахождение процесса поиска на паузе </summary>
      property Paused: Boolean read GetPaused write SetPaused;
      /// <summary> Рабочий поток запуска сканирования IP-адресов </summary>
      property WorkThread: INetScannerWorkThread read GetWorkThread write SetWorkThread;
    end;

    /// <summary> Интерфейс получения результатов сканирования </summary>
    IScanningResults = interface
      /// <summary> Получить результирующие данные </summary>
      function GetResultsList:  IOutputData;
      /// <summary> Получить число просканированных </summary>
      function GetScanned: Integer;
      /// <summary> Получить число сканируемых </summary>
      function GetAllScanning: Integer;
      /// <summary> Получить число оставшихся просканировать </summary>
      function GetScanLeft: Integer;
      /// <summary> Можно ли закрыть приложение </summary>
      function IsCanClose: Boolean;
    end;

    /// <summary> Интерфейс управления сканирования </summary>
    IScanningManagement = interface
      /// <summary> Начать новое сканирование с входными параметрами AInputData</summary>
      function StartScanning(AInputData: IInputData): IScanningResults;
      /// <summary> Приостановить, возобновить сканирование </summary>
      procedure PausePlayScanning;
      /// <summary> Остановить сканирование </summary>
      procedure StopScanning;
      /// <summary> Получение состояния потока, запускающего сканирования </summary>
      function GetScanningState: Integer;
      /// <summary> Можно ли закрыть приложение </summary>
      //function IsCanClose: Boolean;
    end;

implementation

end.
