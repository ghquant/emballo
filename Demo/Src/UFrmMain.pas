{   Copyright 2010 - Magno Machado Paulo (magnomp@gmail.com)

    This file is part of Emballo.

    Emballo is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as
    published by the Free Software Foundation, either version 3 of
    the License, or (at your option) any later version.

    Emballo is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public
    License along with Emballo.
    If not, see <http://www.gnu.org/licenses/>. }

unit UFrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TFrmMain = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  end;

var
  FrmMain: TFrmMain;

implementation

uses
  UGreetingService, Emballo.DI.Core;

{$R *.dfm}

procedure TFrmMain.Button1Click(Sender: TObject);
var
  GreetingService: IGreetingService;
begin
  GreetingService := DIService.Get<IGreetingService>;
  ShowMessage(GreetingService.Greeting);
end;

end.
