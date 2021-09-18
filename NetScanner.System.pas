/// <summary>
///  ���������� ������� ���� NetScanner. ������ �������� ����� ��������,
///  ��������� �������� ��� ���� ��������� �������.
/// </summary>
unit NetScanner.System;

interface

uses
  Windows;

const
  RES_UNKNOWN = '����������';
  RES_COM_NO  = '�����������';
  RES_ROUTER  = '���� ������';
  RES_COMPUTER= '���� ���������';
  RES_THREAD_COUNT = 50;
  WSA_TYPE = $101; //$202;
  // ��� ������ � ARP (Address Resolution Protocol) ��������
  // ����������� mac-������
  // � ��������� ��� ����������� ��������� �����(�������)
  IPHLPAPI = 'IPHLPAPI.DLL';
  MAX_ADAPTER_ADDRESS_LENGTH = 7;
  MAX_ADAPTER_NAME_LENGTH        = 256;
  MAX_ADAPTER_DESCRIPTION_LENGTH = 128;

type
  LMSTR = LPWSTR;
  NET_API_STATUS = DWORD;

  // ��������� ���� ������������ ��� ������ � Iphlpapi.dll
  // ���������� � Iphlpapi.h

  // ��� ����� ��������� ���
  TMacAddress = array[0..MAX_ADAPTER_ADDRESS_LENGTH] of Byte;

  // ��� ��������� ��� ���������� �������
  TMibIPNetRow = packed record
    dwIndex         : DWORD;
    dwPhysAddrLen   : DWORD;
    bPhysAddr       : TMACAddress;  // ��� ����� � ����� ���!!!
    dwAddr          : DWORD;
    dwType          : DWORD;
  end;

  TMibIPExNetRow = packed record
    wszName          : array[0..255] of WideChar;
    dwIndex          : DWORD;
    dwType           : DWORD;
    dwMtu            : DWORD;
    dwSpeed          : DWORD; // ���������� ������� �������� �������� � ����� � �������
    dwPhysAddrLen    : DWORD;
    bPhysAddr        : TMACAddress;//array[0..7] of Byte; // �������� ���������� ����� ���������� (���� ����� �� ���, ������� ��������������, ��� �����)
    dwAdminStatus    : DWORD;
    dwOperStatus     : DWORD;
    dwLastChange     : DWORD;
    dwInOctets       : DWORD; // �������� ���������� ���� �������� ����� ���������
    dwInUcastPkts    : DWORD;
    dwInNUCastPkts   : DWORD;
    dwInDiscards     : DWORD;
    dwInErrors       : DWORD;
    dwInUnknownProtos: DWORD;
    dwOutOctets      : DWORD; // �������� ���������� ���� ������������ �����������
    dwOutUCastPkts   : DWORD;
    dwOutNUCastPkts  : DWORD;
    dwOutDiscards    : DWORD;
    dwOutErrors      : DWORD;
    dwOutQLen        : DWORD;
    dwDescrLen       : DWORD;
    bDescr           : array[0..255] of AnsiChar; // c������� �������� ����������
  end;

  // �� ����� �������� ������ �����������,
  // � ����� �������� ������...
  TMibIPNetRowArray = array [0..512] of TMibIPNetRow;

  TMibIPExNetRowArray = array [0..512] of TMibIPExNetRow;
 // � ���, ��� � �� ���� ����������, ����� ���...
  // ������������� ���������
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

  /// <summary> ��� ������������ </summary>
  TRadio =(ScanRange, ScanMask, ScanGUID);

  // ��������������� ������ ��� ���� IP_ADAPTER_INFO,
  // ����� ���� ��� ����������� ������� IP �������� ������ � ��������� IP
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

  /// <summary> ��� ���������� �� �������� </summary>
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

  // ��� ������ ������ ������� ������������ ������� ������� �����������
  // �� ��������� ���������� � ���������� � ���
  function GetAdaptersInfo(pAdapterInfo: PIP_ADAPTER_INFO;
    var pOutBufLen: ULONG): DWORD; stdcall; external IPHLPAPI;
var
 GetIfTable:function(pIfTable: PTMibIPExNetTable; pdwSize: PULONG;
                              bOrder: Boolean): DWORD; stdcall;

implementation

end.
