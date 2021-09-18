/// <summary>
///  Реализация сканера сети NetScanner. Модуль содержит набор констант,
///  системных структур для всех остальных модулей.
/// </summary>
unit NetScanner.System;

interface

uses
  Windows;

const
  RES_UNKNOWN = 'Неизвестно';
  RES_COM_NO  = 'Отсутствует';
  RES_ROUTER  = 'Твой роутер';
  RES_COMPUTER= 'Твой компьютер';
  RES_THREAD_COUNT = 50;
  WSA_TYPE = $101; //$202;
  // Для работы с ARP (Address Resolution Protocol) таблицей
  // определения mac-адреса
  // и константы для определения основного шлюза(роутера)
  IPHLPAPI = 'IPHLPAPI.DLL';
  MAX_ADAPTER_ADDRESS_LENGTH = 7;
  MAX_ADAPTER_NAME_LENGTH        = 256;
  MAX_ADAPTER_DESCRIPTION_LENGTH = 128;

type
  LMSTR = LPWSTR;
  NET_API_STATUS = DWORD;

  // Следующие типы используются для работы с Iphlpapi.dll
  // содержатся в Iphlpapi.h

  // Так будет выглядеть МАС
  TMacAddress = array[0..MAX_ADAPTER_ADDRESS_LENGTH] of Byte;

  // Это структура для единичного запроса
  TMibIPNetRow = packed record
    dwIndex         : DWORD;
    dwPhysAddrLen   : DWORD;
    bPhysAddr       : TMACAddress;  // Вот здесь и лежит МАС!!!
    dwAddr          : DWORD;
    dwType          : DWORD;
  end;

  TMibIPExNetRow = packed record
    wszName          : array[0..255] of WideChar;
    dwIndex          : DWORD;
    dwType           : DWORD;
    dwMtu            : DWORD;
    dwSpeed          : DWORD; // определяет текущую скорость передачи в битах в секунду
    dwPhysAddrLen    : DWORD;
    bPhysAddr        : TMACAddress;//array[0..7] of Byte; // содержит физический адрес интерфейса (если проще то его, немного видоизмененный, МАС адрес)
    dwAdminStatus    : DWORD;
    dwOperStatus     : DWORD;
    dwLastChange     : DWORD;
    dwInOctets       : DWORD; // содержит количество байт принятых через интерфейс
    dwInUcastPkts    : DWORD;
    dwInNUCastPkts   : DWORD;
    dwInDiscards     : DWORD;
    dwInErrors       : DWORD;
    dwInUnknownProtos: DWORD;
    dwOutOctets      : DWORD; // содержит количество байт отправленных интерфейсом
    dwOutUCastPkts   : DWORD;
    dwOutNUCastPkts  : DWORD;
    dwOutDiscards    : DWORD;
    dwOutErrors      : DWORD;
    dwOutQLen        : DWORD;
    dwDescrLen       : DWORD;
    bDescr           : array[0..255] of AnsiChar; // cодержит описание интерфейса
  end;

  // Не будем выделять память динамически,
  // а сразу создадим массив...
  TMibIPNetRowArray = array [0..512] of TMibIPNetRow;

  TMibIPExNetRowArray = array [0..512] of TMibIPExNetRow;
 // А это, как и во всей библиотеке, такая вот...
  // запрашиваемая структура
  PTMibIPNetTable = ^TMibIPNetTable;
  TMibIPNetTable = packed record
    dwNumEntries    : DWORD;
    Table: TMibIPNetRowArray;
  end;

  PTMibIPExNetTable = ^TMibIPExNetTable;
  TMibIPExNetTable = packed record
    dwNumEntries    : DWORD;
    Table: TMibIPExNetRowArray;
  end;

  /// <summary> Тип сканирования </summary>
  TRadio =(ScanRange, ScanMask, ScanGUID);

  // вспомогательные записи для типа IP_ADAPTER_INFO,
  // также типы для определения списков IP основных шлюзов и локальных IP
  time_t = Longint;

  IP_ADDRESS_STRING = record
    S: array [0..15] of AnsiChar;
  end;
  IP_MASK_STRING = IP_ADDRESS_STRING;
  PIP_MASK_STRING = ^IP_MASK_STRING;

  PIP_ADDR_STRING = ^IP_ADDR_STRING;
  IP_ADDR_STRING = record
    Next: PIP_ADDR_STRING;
    IpAddress: IP_ADDRESS_STRING;
    IpMask: IP_MASK_STRING;
    Context: DWORD;
  end;

  /// <summary> Тип информации об адаптере </summary>
  PIP_ADAPTER_INFO = ^IP_ADAPTER_INFO;
  IP_ADAPTER_INFO = record
    Next: PIP_ADAPTER_INFO;
    ComboIndex: DWORD;
    AdapterName: array [0..MAX_ADAPTER_NAME_LENGTH + 3] of AnsiChar;
    Description: array [0..MAX_ADAPTER_DESCRIPTION_LENGTH + 3] of AnsiChar;
    AddressLength: UINT;
    Address: array [0..MAX_ADAPTER_ADDRESS_LENGTH] of BYTE;
    Index: DWORD;
    Type_: UINT;
    DhcpEnabled: UINT;
    CurrentIpAddress: PIP_ADDR_STRING;
    IpAddressList: IP_ADDR_STRING;
    GatewayList: IP_ADDR_STRING;
    DhcpServer: IP_ADDR_STRING;
    HaveWins: BOOL;
    PrimaryWinsServer: IP_ADDR_STRING;
    SecondaryWinsServer: IP_ADDR_STRING;
    LeaseObtained: time_t;
    LeaseExpires: time_t;
  end;

  {$EXTERNALSYM GetIpNetTable}
  function GetIpNetTable(pIpNetTable: PTMibIPNetTable;
    pdwSize: PULONG; bOrder: Boolean): DWORD; stdcall;
  function GetIpNetTable; external IPHLPAPI name 'GetIpNetTable';
  function SendARP(const DestIP, SrcIP: ULONG;
    pMacAddr: PULONG; var PhyAddrLen: ULONG): DWORD; stdcall; external 'IPHLPAPI.DLL';

  // При помощи данной функции определяется наличие сетевых интерфейсов
  // на локальном компьютере и информацию о них
  function GetAdaptersInfo(pAdapterInfo: PIP_ADAPTER_INFO;
    var pOutBufLen: ULONG): DWORD; stdcall; external IPHLPAPI;
var
 GetIfTable:function(pIfTable: PTMibIPExNetTable; pdwSize: PULONG;
                              bOrder: Boolean): DWORD; stdcall;

implementation

end.
