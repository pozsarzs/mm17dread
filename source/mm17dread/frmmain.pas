{ +--------------------------------------------------------------------------+ }
{ | MM17DRead v0.1 * Status reader program for MM17D device                  | }
{ | Copyright (C) 2023 Pozsár Zsolt <pozsarzs@gmail.com>                     | }
{ | frmmain.pas                                                              | }
{ | Main form                                                                | }
{ +--------------------------------------------------------------------------+ }

//   This program is free software: you can redistribute it and/or modify it
// under the terms of the European Union Public License 1.2 version.

//   This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.

unit frmmain;

{$mode objfpc}{$H+}
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  StdCtrls, Buttons, ExtCtrls, ValEdit, StrUtils, process, untcommonproc;

type
  { TForm1 }
  TForm1 = class(TForm)
    Bevel1: TBevel;
    Bevel16: TBevel;
    Bevel2: TBevel;
    Bevel3: TBevel;
    Bevel4: TBevel;
    Button7: TButton;
    CheckBox1: TCheckBox;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Memo1: TMemo;
    PageControl1: TPageControl;
    Process1: TProcess;
    Shape1: TShape;
    Shape15: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Shape4: TShape;
    Shape5: TShape;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    StatusBar1: TStatusBar;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    Timer1: TTimer;
    ValueListEditor1: TValueListEditor;
    procedure Button7Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Label9Click(Sender: TObject);
    procedure Label9MouseEnter(Sender: TObject);
    procedure Label9MouseLeave(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1:   TForm1;
  inifile: string;

const
  CNTNAME: string = 'MM17D';
  CNTVER:  string = '0.1';

resourcestring
  MESSAGE01 = 'Cannot read configuration file!';
  MESSAGE02 = 'Cannot write configuration file!';
  MESSAGE03 = 'Cannot read data from this URL!';
  MESSAGE04 = 'Not compatible controller!';
  MESSAGE05 = 'name';
  MESSAGE06 = 'value';
  MESSAGE07 = 'MAC address:';
  MESSAGE08 = 'IP address:';
  MESSAGE09 = 'Modbus/RTU UID:';
  MESSAGE10 = 'serial port:';
  MESSAGE11 = 'sw. version:';
  MESSAGE12 = 'RHint:';
  MESSAGE13 = 'Tint:';
  MESSAGE14 = 'Text:';
  MESSAGE15 = 'Device sw.:';
  MESSAGE16 = 'Cannot run default webbrowser!';
  MESSAGE17 = 'green LED';
  MESSAGE18 = 'yellow LED';
  MESSAGE19 = 'red LED';

implementation

{$R *.lfm}
{ TForm1 }

// add URL to list
procedure TForm1.SpeedButton2Click(Sender: TObject);
var
  line:    byte;
  thereis: boolean;
begin
  thereis := False;
  if ComboBox1.Items.Count > 0 then
    for line := 0 to ComboBox1.Items.Count - 1 do
      if ComboBox1.Items.Strings[line] = ComboBox1.Text then
        thereis := True;
  if (not thereis) and (ComboBox1.Items.Count < 64) then
    ComboBox1.Items.AddText(ComboBox1.Text);
end;

// remove URL from list
procedure TForm1.SpeedButton3Click(Sender: TObject);
var
  line: byte;
begin
  if ComboBox1.Items.Count > 0 then
  begin
    for line := 0 to ComboBox1.Items.Count - 1 do
      if ComboBox1.Items.Strings[line] = ComboBox1.Text then
        break;
    ComboBox1.Items.Delete(line);
    ComboBox1Change(Sender);
  end;
end;

// event of ComboBox1
procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if length(ComboBox1.Text) = 0 then
  begin
    SpeedButton2.Enabled := False;
    SpeedButton3.Enabled := False;
    Button7.Enabled := False;
  end
  else
  begin
    SpeedButton2.Enabled := True;
    SpeedButton3.Enabled := True;
    Button7.Enabled := True;
  end;
end;

// automatic read from device
procedure TForm1.Timer1Timer(Sender: TObject);
begin
    Timer1.Enabled := false;
    Button7.Click;
    Timer1.Enabled := true;
end;

procedure TForm1.CheckBox1Change(Sender: TObject);
begin
  if CheckBox1.Checked
    then
      Timer1.Enabled := true
    else
      Timer1.Enabled := false;
end;

// refresh displays
procedure TForm1.Button7Click(Sender: TObject);
var
  i,j: integer;
const
  s1a: string = '<br>';
  s1b: string = '<td>';
  s1c: string = '<td align="right">';
  s1d: string = '<td align="center">';
  s1e: string = '</td>';
  s2:  string = 'my MAC address:';
  s3:  string = 'my IP address:';
  s4:  string = 'my Modbus UID:';
  s5:  string = 'serial port parameters:';
  s6:  string = 'software version:';
  s7:  string = '<td>Internal humidity</td>';
  s8:  string = '<td>Internal temperature</td>';
  s9:  string = '<td>External temperature</td>';
  s10:  string = '<td>Status of the green LED</td>';
  s11:  string = '<td>Status of the yellow LED</td>';
  s12:  string = '<td>Status of the red LED</td>';

begin
  // clear pages
  Label3.Caption := '? %';
  Label4.Caption := '? °C';
  Label18.Caption := '? °C';
  ValueListEditor1.Cols[1].Clear;
  ValueListEditor1.Cells[1, 6] := Label3.Caption;
  ValueListEditor1.Cells[1, 7] := Label4.Caption;
  ValueListEditor1.Cells[1, 8] := Label18.Caption;
  Memo1.Clear;
  // get data
  if getdatafromdevice(ComboBox1.Text, 0) then
  begin
    // check software name and version
    for i := 0 to Value.Count - 1 do
    begin
      j := findpart(s6, Value.Strings[i]);
      if j <> 0 then break;
    end;
    if j <> 0 then
    begin
      Value.Strings[i] := stringreplace(Value.Strings[i], s1a, '', [rfReplaceAll]);
      Value.Strings[i] := stringreplace(Value.Strings[i], s6, '', [rfReplaceAll]);
      Value.Strings[i] := rmchr1(Value.Strings[i]);
      ValueListEditor1.Cells[1, 5] := Value.Strings[i];
    end;
    // check compatibility
    if 'v'+CNTVER = ValueListEditor1.Cells[1, 5]
      then
        StatusBar1.Panels.Items[0].Text := MESSAGE15 + ' ' + ValueListEditor1.Cells[1, 5]
      else
      begin
        ShowMessage(MESSAGE04);
        StatusBar1.Panels.Items[0].Text := '';
        exit;
      end;
    // get MAC address
    for i := 0 to Value.Count - 1 do
    begin
      j := findpart(s2, Value.Strings[i]);
      if j <> 0 then break;
    end;
    if j <> 0 then
    begin
      Value.Strings[i] := stringreplace(Value.Strings[i], s1a, '', [rfReplaceAll]);
      Value.Strings[i] := stringreplace(Value.Strings[i], s2, '', [rfReplaceAll]);
      Value.Strings[i] := rmchr1(Value.Strings[i]);
      ValueListEditor1.Cells[1, 1] := Value.Strings[i];
    end;
    // get IP address
    for i := 0 to Value.Count - 1 do
    begin
      j := findpart(s3, Value.Strings[i]);
      if j <> 0 then break;
    end;
    if j <> 0 then
    begin
      Value.Strings[i] := stringreplace(Value.Strings[i], s1a, '', [rfReplaceAll]);
      Value.Strings[i] := stringreplace(Value.Strings[i], s3, '', [rfReplaceAll]);
      Value.Strings[i] := rmchr1(Value.Strings[i]);
      ValueListEditor1.Cells[1, 2] := Value.Strings[i];
    end;
    // get Modbus UID
    for i := 0 to Value.Count - 1 do
    begin
      j := findpart(s4, Value.Strings[i]);
      if j <> 0 then break;
    end;
    if j <> 0 then
    begin
      Value.Strings[i] := stringreplace(Value.Strings[i], s1a, '', [rfReplaceAll]);
      Value.Strings[i] := stringreplace(Value.Strings[i], s4, '', [rfReplaceAll]);
      Value.Strings[i] := rmchr1(Value.Strings[i]);
      ValueListEditor1.Cells[1, 3] := Value.Strings[i];
    end;
    // get serial port parameters
    for i := 0 to Value.Count - 1 do
    begin
      j := findpart(s5, Value.Strings[i]);
      if j <> 0 then break;
    end;
    if j <> 0 then
    begin
      Value.Strings[i] := stringreplace(Value.Strings[i], s1a, '', [rfReplaceAll]);
      Value.Strings[i] := stringreplace(Value.Strings[i], s5, '', [rfReplaceAll]);
      Value.Strings[i] := rmchr3(Value.Strings[i]);
      ValueListEditor1.Cells[1, 4] := Value.Strings[i];
    end;
    // get internal humidity
    for i := 0 to Value.Count - 1 do
    begin
      j := findpart(s7, Value.Strings[i]);
      if j <> 0 then break;
    end;
    if j <> 0 then
    begin
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], s1c, '', [rfReplaceAll]);
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], s1e, '', [rfReplaceAll]);
      Value.Strings[i + 1] := rmchr3(Value.Strings[i + 1]);
      ValueListEditor1.Cells[1, 6] := Value.Strings[i+1];
      Label3.Caption := ValueListEditor1.Cells[1, 6];
    end;
    // get internal temperature
    for i := 0 to Value.Count - 1 do
    begin
      j := findpart(s8, Value.Strings[i]);
      if j <> 0 then break;
    end;
    if j <> 0 then
    begin
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], '&deg;', '°', [rfReplaceAll]);
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], s1c, '', [rfReplaceAll]);
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], s1e, '', [rfReplaceAll]);
      Value.Strings[i + 1] := rmchr3(Value.Strings[i + 1]);
      ValueListEditor1.Cells[1, 7] := Value.Strings[i + 1];
      Label4.Caption := ValueListEditor1.Cells[1, 7];
    end;
    // get external temperature
    for i := 0 to Value.Count - 1 do
    begin
      j := findpart(s9, Value.Strings[i]);
      if j <> 0 then break;
    end;
    if j <> 0 then
    begin
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], '&deg;', '°', [rfReplaceAll]);
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], s1c, '', [rfReplaceAll]);
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], s1e, '', [rfReplaceAll]);
      Value.Strings[i + 1] := rmchr3(Value.Strings[i + 1]);
      ValueListEditor1.Cells[1, 8] := Value.Strings[i + 1];
      Label18.Caption := ValueListEditor1.Cells[1, 8];
    end;
    // get status of the green LED
    for i := 0 to Value.Count - 1 do
    begin
      j := findpart(s10, Value.Strings[i]);
      if j <> 0 then break;
    end;
    if j <> 0 then
    begin
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], s1d, '', [rfReplaceAll]);
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], s1e, '', [rfReplaceAll]);
      Value.Strings[i + 1] := rmchr3(Value.Strings[i + 1]);
      ValueListEditor1.Cells[1, 9] := Value.Strings[i + 1];
      if ValueListEditor1.Cells[1, 9].ToBoolean
      then
        Shape3.Brush.Color:=clLime
      else
        Shape3.Brush.Color:=clGreen;
    end;
    // get status of the green LED
    for i := 0 to Value.Count - 1 do
    begin
      j := findpart(s11, Value.Strings[i]);
      if j <> 0 then break;
    end;
    if j <> 0 then
    begin
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], s1d, '', [rfReplaceAll]);
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], s1e, '', [rfReplaceAll]);
      Value.Strings[i + 1] := rmchr3(Value.Strings[i + 1]);
      ValueListEditor1.Cells[1, 10] := Value.Strings[i + 1];
      if ValueListEditor1.Cells[1, 10].ToBoolean
      then
        Shape4.Brush.Color:=clYellow
      else
        Shape4.Brush.Color:=clOlive;
    end;
    // get status of the red LED
    for i := 0 to Value.Count - 1 do
    begin
      j := findpart(s12, Value.Strings[i]);
      if j <> 0 then break;
    end;
    if j <> 0 then
    begin
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], s1d, '', [rfReplaceAll]);
      Value.Strings[i + 1] := stringreplace(Value.Strings[i + 1], s1e, '', [rfReplaceAll]);
      Value.Strings[i + 1] := rmchr3(Value.Strings[i + 1]);
      ValueListEditor1.Cells[1, 11] := Value.Strings[i + 1];
      if ValueListEditor1.Cells[1, 11].ToBoolean
      then
        Shape5.Brush.Color:=clRed
      else
        Shape5.Brush.Color:=clMaroon;
    end;
  end
  else
  begin
    ShowMessage(MESSAGE03);
    exit;
  end;
  ValueListEditor1.Cells[0, 0] := MESSAGE05;
  ValueListEditor1.Cells[1, 0] := MESSAGE06;
  // get log
  if getdatafromdevice(ComboBox1.Text, 1) then
  begin
    Memo1.Clear;
    for i := 0 to Value.Count - 1 do
      if findpart('<tr><td><pre>', Value.Strings[i]) <> 0 then
      begin
        Value.Strings[i] := rmchr3(Value.Strings[i]);
        Value.Strings[i] := stringreplace(Value.Strings[i], '<tr><td><pre>',
          '', [rfReplaceAll]);
        Value.Strings[i] := stringreplace(Value.Strings[i],
          '</pre></td><td><pre>', #9, [rfReplaceAll]);
        Value.Strings[i] := stringreplace(Value.Strings[i], '</pre></td></tr>',
          '', [rfReplaceAll]);
        Memo1.Lines.Insert(0, Value.Strings[i]);
      end;
    Memo1.SelStart := 0;
  end
  else
  begin
    ShowMessage(MESSAGE03);
    exit;
  end;
end;

// open homepage
procedure TForm1.Label9Click(Sender: TObject);
begin
  if length(BROWSER) > 0 then
  begin
    Process1.Executable := BROWSER;
    Process1.Parameters.Add(Label9.Caption);
    try
      Form1.Process1.Execute;
    except
      ShowMessage(MESSAGE16);
    end;
  end;
end;

procedure TForm1.Label9MouseEnter(Sender: TObject);
begin
  Label9.Font.Color := clPurple;
end;

procedure TForm1.Label9MouseLeave(Sender: TObject);
begin
  Label9.Font.Color := clBlue;
end;

// onCreate event
procedure TForm1.FormCreate(Sender: TObject);
var
  b: byte;
begin
  makeuserdir;
  getlang;
  getexepath;
  Form1.Caption := APPNAME + ' v' + VERSION;
  Label6.Caption := Form1.Caption;
  // load configuration
  inifile := untcommonproc.userdir + DIR_CONFIG + 'mm17dread.ini';
  if FileSearch('mm17dread.ini', untcommonproc.userdir + DIR_CONFIG) <> '' then
    if not loadconfiguration(inifile) then
      ShowMessage(MESSAGE01);
  for b := 0 to 63 do
    if length(urls[b]) > 0 then
      ComboBox1.Items.Add(untcommonproc.urls[b]);
  if ComboBox1.Items.Count > 0 then
  begin
    ComboBox1.ItemIndex := 0;
    Button7.Enabled := true;
    SpeedButton2.Enabled := true;
    SpeedButton3.Enabled := true;
  end;
  // others
  untcommonproc.Value := TStringList.Create;
  ValueListEditor1.Cells[0, 1] := MESSAGE07;
  ValueListEditor1.Cells[0, 2] := MESSAGE08;
  ValueListEditor1.Cells[0, 3] := MESSAGE09;
  ValueListEditor1.Cells[0, 4] := MESSAGE10;
  ValueListEditor1.Cells[0, 5] := MESSAGE11;
  ValueListEditor1.Cells[0, 6] := MESSAGE12;
  ValueListEditor1.Cells[0, 7] := MESSAGE13;
  ValueListEditor1.Cells[0, 8] := MESSAGE14;
  ValueListEditor1.Cells[0, 9] := MESSAGE17;
  ValueListEditor1.Cells[0, 10] := MESSAGE18;
  ValueListEditor1.Cells[0, 11] := MESSAGE19;
end;

// onClose
procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
var
  b: byte;
begin
  for b := 0 to 63 do
    untcommonproc.urls[b] := '';
  if ComboBox1.Items.Count > 0 then
    for b := 0 to ComboBox1.Items.Count - 1 do
      untcommonproc.urls[b] := ComboBox1.Items.Strings[b];
  if not saveconfiguration(inifile) then
    ShowMessage(MESSAGE02);
  untcommonproc.Value.Free;
end;

end.
