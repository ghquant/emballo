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

program Greeting;

uses
  Forms,
  GreetingForm_F in '..\Src\GreetingForm_F.pas' {GreetingForm},
  TimeService in '..\Src\TimeService.pas',
  TimeServiceImpl in '..\Src\TimeServiceImpl.pas',
  GreetingService in '..\Src\GreetingService.pas',
  GreetingServiceImpl in '..\Src\GreetingServiceImpl.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TGreetingForm, GreetingForm);
  Application.Run;
end.
