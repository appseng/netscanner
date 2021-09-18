program NetScanner;

uses
  Forms,
  NetScanner.Forms.TestForm in 'NetScanner.Forms.TestForm.pas' {Form1},
  NetScanner.Work in 'NetScanner.Work.pas',
  NetScanner.System in 'NetScanner.System.pas',
  NetScanner.Output in 'NetScanner.Output.pas',
  NetScanner.Interfaces in 'NetScanner.Interfaces.pas',
  NetScanner.FacadeClasses in 'NetScanner.FacadeClasses.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
