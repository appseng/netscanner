/// <summary>
/// Тестовый интерфейс для набора классов из наймспейса NetScanner
/// </summary>
unit NetScanner.Forms.TestForm;

interface

uses
  Windows,
  SysUtils,
  Forms,
  StdCtrls,
  ComCtrls,
  Controls,
  Classes,
  NetScanner.FacadeClasses,
  NetScanner.Interfaces,
  NetScanner.Work;

type
  TForm1 = class(TForm)
    ScanningResult: TListView;
    gbAddrRange: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    RadioRange: TRadioButton;
    RadioMask: TRadioButton;
    RadioGuid: TRadioButton;
    IPAddress: TEdit;
    Mask: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    GUID: TEdit;
    IPFrom: TEdit;
    IPTo: TEdit;
    scanbutton: TButton;
    UpdataResults: TButton;
    Numbers: TLabel;
    Pause: TButton;
    Stop: TButton;
    AddressList: TMemo;
    RadioAddressList: TRadioButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure scanbuttonClick(Sender: TObject);
    procedure UpdataResultsClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure PauseClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    //NetScannerFacade: TNetScannerFacade;
    //NetScannerFacade:       TNetScannerFacade;
    FScanningResults:        IScanningResults;
    FScanningManagement:     IScanningManagement;
  public
    procedure SetScanResults;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

//

//////////TForm1.start////////////////////////
//Получение списка
procedure TForm1.SetScanResults;
var
  I:  integer;
  Item: IOutputDataString;
  sritem: TListItem;
  res: IOutputData;
//  ScanningRes: TNetScannerResults;
begin
if FScanningResults <> nil then
  begin
  self.ScanningResult.Clear;

  //ScanningRes := TNetScannerResults(FScanningResults);
  res := FScanningResults.GetResultsList;// as IOutputData;
  if res = nil then
    Exit;

  for I := 0 to res.Count-1 do
    begin
    item := res.GetElement(I);
    sritem := ScanningResult.Items.Add;
    sritem.Caption := item.IPAddress;
    sritem.SubItems.Add(item.DeviceName);
    sritem.SubItems.Add(item.MACAddress);
    sritem.SubItems.Add(item.AdapterDescription);
    sritem.SubItems.Add(item.Comment);
    end;
  end;
end;

procedure TForm1.UpdataResultsClick(Sender: TObject);
begin
  self.SetScanResults;
  (**)
  if FScanningResults <> nil then
  begin
    Numbers.Caption := 'Всего сканировать: '+IntToStr(FScanningResults.GetAllScanning)
    +', просканированно: '+IntToStr(FScanningResults.GetScanned)
    +', осталось: '+IntToStr(FScanningResults.GetScanLeft);
  end;
  (**)
end;

procedure TForm1.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if Assigned(FScanningResults) then// and Assigned(FScanningManagement) then
    CanClose := FScanningResults.IsCanClose;// and FScanningManagement.IsCanClose
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  FScanningManagement := TNetScannerManagement.Create;
end;

procedure TForm1.PauseClick(Sender: TObject);
begin
  FScanningManagement.PausePlayScanning;
end;

procedure TForm1.StopClick(Sender: TObject);
begin
  FScanningManagement.StopScanning;
end;

procedure TForm1.scanbuttonClick(Sender: TObject);
var
  InputData:  IInputData;
  Params:     TStringList;
  I:          Integer;
begin
// подключен ли компьютер к сети
if GetSystemMetrics(SM_NETWORK) and $01=$01 then
  // в случае,если подключен
  if RadioRange.Checked then
    begin
      InputData := TInputRange.Create;
      InputData.SetData(IPFrom.Text, IPTo.Text);
      //self.NetScannerFacade.Scan(InputData);
      //if NetScannerFacade <> nil then
      //  NetScannerFacade.Free;

      //NetScannerFacade := TNetScannerFacade.Create(InputData);
      FScanningResults := FScanningManagement.StartScanning(InputData);
    end
  else if RadioMask.Checked then
    begin
      InputData := TInputMaskIP.Create;
      InputData.SetData(IPAddress.Text,Mask.Text);

      FScanningResults := FScanningManagement.StartScanning(InputData);
    end
  else if RadioGuid.Checked then
    begin
      InputData := TInputGUID.Create;
      InputData.SetData(self.GUID.Text,'');

      FScanningResults := FScanningManagement.StartScanning(InputData);
    end
  else if RadioAddressList.Checked then
    begin
      InputData := TInputAddressList.Create;
      Params := TStringList.Create;
      for i := 0 to AddressList.Lines.Count-1 do
        Params.Add(AddressList.Lines[I]);

      InputData.SetData(Params);

      FScanningResults := FScanningManagement.StartScanning(InputData);
      FreeAndNil(Params);
    end;
end;

// closing main form
procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  //FreeAndNil(FScanningResults);
  //FreeAndNil(FScanningManagement);
end;

end.
