{   Copyright 2009 - Magno Machado Paulo (magnomp@gmail.com)

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

unit GreetingForm_F;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GreetingService, StdCtrls;

type
  TGreetingForm = class(TForm)
    Label1: TLabel;
    edName: TEdit;
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FGreetingService: IGreetingService;
  end;

var
  GreetingForm: TGreetingForm;

implementation

uses
  EBDependencyInjection;

{$R *.dfm}

procedure TGreetingForm.Button1Click(Sender: TObject);
begin
  ShowMessage(FGreetingService.Greeting(edName.Text));
end;

procedure TGreetingForm.FormCreate(Sender: TObject);
begin
  InjectDependencies(Self);
end;

end.
