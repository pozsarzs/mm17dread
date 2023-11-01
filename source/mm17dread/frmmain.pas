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
  StdCtrls, Buttons, ExtCtrls, ValEdit, XMLPropStorage, StrUtils, process,
  untcommonproc;

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
  CNTVER:  string = '0.1.0';

resourcestring
  MESSAGE01 = 'Cannot read configuration file!';
  MESSAGE02 = 'Cannot write configuration file!';
  MESSAGE03 = 'Cannot read data from this URL!';
  MESSAGE04 = 'Not compatible controller!';
  MESSAGE05 = 'name';
  MESSAGE06 = 'value';
  MESSAGE07 = 'device';
  MESSAGE08 = 'sw. version';
  MESSAGE09 = 'MAC address';
  MESSAGE10 = 'IP address';
  MESSAGE11 = 'Modbus/RTU UID';
  MESSAGE12 = 'serial port speed [baud]';
  MESSAGE13 = 'RHint [%]';
  MESSAGE14 = 'Tint [°C]';
  MESSAGE15 = 'Text [°C]';
  MESSAGE16 = 'green LED';
  MESSAGE17 = 'yellow LED';
  MESSAGE18 = 'red LED';
  MESSAGE19 = 'Cannot run default webbrowser!';

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
  i,j, k: integer;
const
  t: array[1..12] of string =('name','version','mac_address','ip_address',
                              'modbus_uid','com_speed','rhint','tint',
                              'text','ledg','ledy','ledr');

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
  // get software information
  if getdatafromdevice(ComboBox1.Text, 0) then
  begin
    for k := 1 to 2 do
    begin
      for i := 0 to Value.Count - 1 do
      begin
        j := findpart(t[k], Value.Strings[i]);
        if j <> 0 then break;
      end;
      if j <> 0 then
      begin
        Value.Strings[i] := stringreplace(Value.Strings[i], '<' + t[k] + '>', '', [rfReplaceAll]);
        Value.Strings[i] := stringreplace(Value.Strings[i], '</' + t[k] + '>', '', [rfReplaceAll]);
        Value.Strings[i] := rmchr1(Value.Strings[i]);
        ValueListEditor1.Cells[1, k] := Value.Strings[i];
      end;
    end;
  end else
  begin
    ShowMessage(MESSAGE03);
    exit;
  end;
  // check compatibility
  if (CNTNAME = ValueListEditor1.Cells[1, 1]) and
     (CNTVER = ValueListEditor1.Cells[1, 2])
  then
    StatusBar1.Panels.Items[0].Text := ' ' + ValueListEditor1.Cells[1, 1] + ' v' + ValueListEditor1.Cells[1, 2]
  else
  begin
    ShowMessage(MESSAGE04);
    StatusBar1.Panels.Items[0].Text := '';
    exit;
  end;
  // get summary
  if getdatafromdevice(ComboBox1.Text, 0) then
  begin
    for k := 3 to 12 do
    begin
      for i := 0 to Value.Count - 1 do
      begin
        j := findpart(t[k], Value.Strings[i]);
        if j <> 0 then break;
      end;
      if j <> 0 then
      begin
        Value.Strings[i] := stringreplace(Value.Strings[i], '<' + t[k] + '>', '', [rfReplaceAll]);
        Value.Strings[i] := stringreplace(Value.Strings[i], '</' + t[k] + '>', '', [rfReplaceAll]);
        Value.Strings[i] := rmchr1(Value.Strings[i]);
        ValueListEditor1.Cells[1, k] := Value.Strings[i];
      end;
    end;
  end else
  begin
    ShowMessage(MESSAGE03);
    exit;
  end;
  // display
  Label3.Caption := ValueListEditor1.Cells[1, 7] + ' %';
  Label4.Caption := ValueListEditor1.Cells[1, 8] + ' °C';
  Label18.Caption := ValueListEditor1.Cells[1, 9] + ' °C';
  // LEDs
  if ValueListEditor1.Cells[1, 10].ToBoolean
  then
    Shape3.Brush.Color:=clLime
  else
    Shape3.Brush.Color:=clGreen;
  if ValueListEditor1.Cells[1, 11].ToBoolean
  then
    Shape4.Brush.Color:=clYellow
  else
    Shape4.Brush.Color:=clOlive;
  if ValueListEditor1.Cells[1, 12].ToBoolean
  then
    Shape5.Brush.Color:=clRed
  else
    Shape5.Brush.Color:=clMaroon;
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
  end else
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
      ShowMessage(MESSAGE19);
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
  ValueListEditor1.Cells[0, 9] := MESSAGE15;
  ValueListEditor1.Cells[0, 10] := MESSAGE16;
  ValueListEditor1.Cells[0, 11] := MESSAGE17;
  ValueListEditor1.Cells[0, 12] := MESSAGE18;
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
