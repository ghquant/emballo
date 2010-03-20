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

unit UGreetingServiceImpl;

interface

uses
  UGreetingService, UTimeService;

type
  { This implementation of IGreetingService gets its instance of ITimeService
    through a parameter on its constructor. When this class is instantiated
    via Emballo, this parameter is automatically resolved }
  TGreetingServiceWithConstructorInjection = class(TInterfacedObject, IGreetingService)
  private
    FTimeService: ITimeService;
    function GetGreeting: string;
  public
    constructor Create(const TimeService: ITimeService);
  end;

  { This implementation of IGreetingService manually asks the framework for an
    instance of ITimeService every time it is needed }
  TGreetingServiceManualyGetTimeService = class(TInterfacedObject, IGreetingService)
  private
    function GetGreeting: string;
  end;

implementation

uses
  DateUtils, Emballo.DI.Core;

{ TGreetingServiceWithConstructorInjection }

constructor TGreetingServiceWithConstructorInjection.Create(const TimeService: ITimeService);
begin
  FTimeService := TimeService;
end;

function TGreetingServiceWithConstructorInjection.GetGreeting: string;
var
  Hour: Word;
begin
  Hour := HourOf(FTimeService.Now);
  if Hour in [6..11] then
    Result := 'Good morning'
  else if Hour in [12..18] then
    Result := 'Good afternoon'
  else
    Result := 'Good evening';
end;

{ TGreetingServiceManualyGetTimeService }

function TGreetingServiceManualyGetTimeService.GetGreeting: string;
var
  Hour: Word;
  TimeService: ITimeService;
begin
  TimeService := DIService.Get<ITimeService>;
  Hour := HourOf(TimeService.Now);
  if Hour in [6..11] then
    Result := 'Good morning'
  else if Hour in [12..18] then
    Result := 'Good afternoon'
  else
    Result := 'Good evening';
end;

end.
