{   Copyright 2010 - Magno Machado Paulo (magnomp@gmail.com)

    This file is part of Emballo.

    Emballo is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Emballo is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>. }

unit UFrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ebregistry, ebdynamicfactory, ebpoolfactory;

type
  TFrmMain = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  UGreetingService, EbCore;

type
  ITeste = interface
    ['{A6189EC3-2E95-4CE5-AF7C-D867967F40DE}']
  end;

  TTeste = class(TInterfacedObject, ITeste)

  end;

{$R *.dfm}

procedure TFrmMain.Button1Click(Sender: TObject);
var
  GreetingService: IGreetingService;
  T1, T2, T3, T4, T5, T6: ITeste;
begin
  T1 := Emballo.Get<ITeste>;
  T2 := Emballo.Get<ITeste>;
  T3 := Emballo.Get<ITeste>;
  T4 := Emballo.Get<ITeste>;
  T5 := Emballo.Get<ITeste>;
  T6 := Emballo.Get<ITeste>;
  T6 := Nil;
  T5 := Nil;
  T4 := Nil;
  T3 := Nil;
  T2 := Nil;
  T1 := Nil;
  T1 := Emballo.Get<ITeste>;
  GreetingService := Emballo.Get<IGreetingService>;
  ShowMessage(GreetingService.Greeting);
end;

initialization
RegisterFactory(ITeste, TTeste).Pool(0, 5).Done;

end.
