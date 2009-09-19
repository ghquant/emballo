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

unit GreetingServiceImpl;

interface

uses
  Classes, GreetingService, TimeService;

type
  TGreetingService = class(TInterfacedObject, IGreetingService)
  private
    FTimeService: ITimeService;
    function Greeting(const Name: String): String;
  public
    constructor Create;
  end;

implementation

uses
  EBDependencyInjection, EBDIRegistry, DateUtils;

{ TGreetingService }

constructor TGreetingService.Create;
begin
  InjectDependencies(Self);
end;

function TGreetingService.Greeting(const Name: String): String;
var
  Hour: Word;
begin
  Hour := HourOf(FTimeService.CurrentTime);

  if Hour in [6..11] then
    Result := 'Good morning'
  else if Hour in [12..18] then
    Result := 'Good afternoon'
  else
    Result := 'Good evening';

  Result := Result + ', ' + Name + '.';
end;

initialization
GetDIRegistry.RegisterFactory(IGreetingService, TGreetingService, @TGreetingService.Create);

end.
