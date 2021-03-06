unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, IniFiles, StdCtrls, ExtCtrls, shellAPI, Buttons, PngImage, ComCtrls,
  Gauges;

type
  TForm1 = class(TForm)
    Timer1: TTimer;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Gauge1: TGauge;
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormResize(Sender: TObject);
    procedure FormDblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  adresar:string;
  doba:integer;
  soubor:string;
  start:TDateTime;
  konec:boolean;
  cela:boolean;
  barva:TColor;
  barvaPisma:TColor;
  logo:string;
  preskocit:boolean;
  odpocet:boolean;
  logoIMG: Timage;
  jazyk:string;
  nenalezen: string;
  startuji: String;

implementation

{$R *.dfm}

function HtmlToColor(Color: string): TColor;
begin
  if (copy(color,1,1)='#') or (copy(color,1,1)='$') then
    color:=copy(color,2,6);
  
  Result := StringToColor('$' + Copy(Color, 6, 2) + Copy(Color, 4, 2) + Copy(Color, 2, 2));
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  MyIniFile: TIniFile;
begin
  konec:=false;
  adresar:=ExtractFilePath(Application.ExeName);
  MyIniFile := TIniFile.Create( ChangeFileExt( Application.ExeName, '.ini' ) );
  with MyIniFile do
  begin
    doba := ReadInteger('nastaveni', 'cekani', 10);
    soubor := ReadString('nastaveni', 'soubor', '');
    cela := ReadBool('nastaveni', 'cela', true);
    preskocit := ReadBool('nastaveni', 'preskocit', true);
    barva := StringToColor(ReadString('nastaveni', 'barvaPozadi', '$000000'));
    barvaPisma := StringToColor(ReadString('nastaveni', 'barvaPisma', '$ffffff'));
    logo := ReadString('nastaveni', 'logo','');
    if ExtractFilePath(logo) = '' then logo := adresar + logo;
    odpocet := ReadBool('nastaveni', 'odpocet', true);
    jazyk := ReadString('nastaveni', 'jazyk','en');
  end;
  MyIniFile.Free;

// popisky jazykove mutace
  MyIniFile := TIniFile.Create(adresar+'/'+jazyk+'.txt');
  with MyIniFile do
  begin
    Label1.Caption := ReadString('language', 'program',Label1.Caption);
    Label2.Caption := ReadString('language', 'budeSpustenZa',Label2.Caption);
    Nenalezen := ReadString('language', 'nenalezen','Nenalezen');
    Startuji := ReadString('language', 'start','Nenalezen');
  end;
  MyIniFile.Free;

  start:=now;
  if cela then
  begin
    Form1.BorderStyle:=bsNone;
    Form1.FormStyle:=fsStayOnTop;
    Form1.WindowState:=wsMaximized;
  end;
  Form1.Color:=barva;
  Label1.Font.Color:=barvaPisma;
  Label2.Font.Color:=barvaPisma;
  Label3.Font.Color:=barvaPisma;
  Gauge1.ForeColor:=barva;
  if fileExists(logo) then
  begin
    logoIMG:=tImage.Create(Form1);
    logoIMG.Name:='Ilogo';
    logoIMG.Parent:=Form1;
    logoIMG.OnDblClick:=FormDblClick;
  end;
end;

procedure TForm1.FormDblClick(Sender: TObject);
begin
  if preskocit then  doba := 0;

end;

procedure TForm1.FormResize(Sender: TObject);
begin
  if FindComponent('Ilogo') <> nil then
  begin
    logoIMG.Picture.LoadFromFile(logo);
    logoIMG.AutoSize:=false;
    logoIMG.Proportional:=true;
    logoIMG.Stretch:=true;
    logoIMG.Width:=form1.ClientWidth-40;
    logoIMG.Height:=logoIMG.Picture.Height * logoIMG.Width DIV logoIMG.Picture.Width;
    logoIMG.Left:=20;
    logoIMG.Top:=(form1.ClientHeight-logoIMG.PIcture.Height) div 2;
    Gauge1.Top:=logoIMG.Top+logoIMG.Height+20;
    Gauge1.left:=logoIMG.Left;
    Gauge1.width:=logoIMG.Width;
  end;

  Label1.Top:=form1.ClientHeight-20-LAbel2.Height-LAbel1.Height;
  Label2.Top:=form1.ClientHeight-10-LAbel2.Height;
  Label3.Top:=form1.ClientHeight-10-LAbel3.Height;
  Label3.Caption:=IntToStr(doba);
  Gauge1.MinValue:=0;
  Gauge1.MaxValue:=doba * 10;
  Gauge1.Progress:=0;
  Gauge1.show;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var zbyva:TdateTime;
begin
  if not FileExists(soubor) then
  begin
    Timer1.Enabled:=false;
    Gauge1.Hide;
    ShowMessage(Nenalezen+#13+#13+soubor);
    konec:=true;
    Form1.Close;
  end;

  zbyva:=start+(doba/86400)-now;
  label3.Caption:=FormatDateTime('s', zbyva);
  Gauge1.Progress:=round((doba - zbyva * 86400) * 10);
  Gauge1.Repaint;

  if zbyva<=0 then
  begin
    Timer1.Enabled:=false;
    Label2.Caption:=Startuji;
    Label3.hide;
    form1.Repaint;
    ShellExecute(Application.Handle,'open',PChar(soubor), nil, nil, sw_shownormal);
    konec:=true;
    form1.Close;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 if not preskocit and not konec then Action:=caNone;
end;

end.
