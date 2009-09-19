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

unit GreetingServiceImplTests;

interface

uses
  TestFramework, TimeService;

type
  IMockTimeService = interface(ITimeService)
    ['{2C52E9C7-2408-4BB2-84DA-0052181F6080}']
    procedure SetCurrentTime(CurrentTime: TDateTime);
  end;

  TMockTimeService = class(TInterfacedObject, ITimeService, IMockTimeService)
  private
    FCurrentTime: TDateTime;

    procedure SetCurrentTime(CurrentTime: TDateTime);
    function CurrentTime: TDateTime;
  end;

  TGreetingServiceTests = class(TTestCase)
  private
    FTimeService: IMockTimeService;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestGreeting;
  end;

implementation

uses
  EBDIRegistry, GreetingServiceImpl, GreetingService, SysUtils;

{ TMockTimeService }

function TMockTimeService.CurrentTime: TDateTime;
begin
  Result := FCurrentTime;
end;

procedure TMockTimeService.SetCurrentTime(CurrentTime: TDateTime);
begin
  FCurrentTime := CurrentTime;
end;

{ TGreetingServiceTests }

procedure TGreetingServiceTests.SetUp;
begin
  inherited;
  FTimeService := TMockTimeService.Create;
  GetDIRegistry.RegisterFactory(ITimeService, FTimeService);
end;

procedure TGreetingServiceTests.TearDown;
begin
  inherited;
  GetDIRegistry.Clear;
end;

procedure TGreetingServiceTests.TestGreeting;
var
  Greeting: IGreetingService;
begin
  Greeting := TGreetingService.Create;

  FTimeService.SetCurrentTime(EncodeTime(6, 0, 0, 0));
  CheckEquals('Good morning, Test.', Greeting.Greeting('Test'));

  FTimeService.SetCurrentTime(EncodeTime(11, 59, 59, 999));
  CheckEquals('Good morning, Test.', Greeting.Greeting('Test'));

  FTimeService.SetCurrentTime(EncodeTime(12, 0, 0, 0));
  CheckEquals('Good afternoon, Test.', Greeting.Greeting('Test'));

  FTimeService.SetCurrentTime(EncodeTime(18, 59, 59, 999));
  CheckEquals('Good afternoon, Test.', Greeting.Greeting('Test'));

  FTimeService.SetCurrentTime(EncodeTime(19, 0, 0, 0));
  CheckEquals('Good evening, Test.', Greeting.Greeting('Test'));

  FTimeService.SetCurrentTime(EncodeTime(5, 59, 59, 999));
  CheckEquals('Good evening, Test.', Greeting.Greeting('Test'));
end;

initialization
RegisterTest(TGreetingServiceTests.Suite);

end.
