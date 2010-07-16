unit Emballo.Mock.MockTests;

interface

uses
  TestFramework,
  SysUtils,
  Emballo.Mock.Mock;

type
  TMocked = class
  public
    procedure Foo; virtual;
    function FooWithIntegerReturn: Integer; virtual;
  end;

  ETestException = class(Exception)
  end;

  TMockTests = class(TTestCase)
  private
    FMock: TMock<TMocked>;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ShouldFailOnUnexpectedCalls;
    procedure ExpectedCallShouldNotFail;
    procedure ShouldRaiseConfiguredException;
    procedure VerifyUsageMustFailIfUsageWasNotAsExpected;
    procedure VerifyUsageMustNotFailIfUsageWasAsExpected;
    procedure MethodShouldReturnSpecifiedValue;
    procedure ShouldBeAbleToCastTheMockToTheMockedType;
  end;

implementation

uses
  Emballo.Mock.UnexpectedUsage;

{ TMockTests }

procedure TMockTests.ExpectedCallShouldNotFail;
begin
  FMock.Expects.Foo;

  FMock.GetObject.Foo;
end;

procedure TMockTests.MethodShouldReturnSpecifiedValue;
var
  ReturnValue: Integer;
begin
  FMock.Expects.FooWithIntegerReturn;
  FMock.WillReturn(10);

  ReturnValue := FMock.GetObject.FooWithIntegerReturn;

  CheckEquals(10, ReturnValue, 'Mocked method should return the specified value');
end;

procedure TMockTests.SetUp;
begin
  inherited;
  FMock := TMock<TMocked>.Create;
end;

procedure TMockTests.ShouldBeAbleToCastTheMockToTheMockedType;
var
  Mocked: TMocked;
begin
  Mocked := FMock;
  CheckTrue(Mocked = FMock.GetObject);
end;

procedure TMockTests.ShouldFailOnUnexpectedCalls;
begin
  try
    FMock.GetObject.Foo;
    Fail('An unexpected usage of the mocked object should raise an EUnexpectedUsage');
  except
    on EUnexpectedUsage do CheckTrue(True);
  end;
end;

procedure TMockTests.ShouldRaiseConfiguredException;
begin
  FMock.WillRaise(ETestException).When.Foo;

  try
    FMock.GetObject.Foo;
    Fail('The configured exception should have been raised');
  except
    on ETestException do CheckTrue(True);
  end;
end;

procedure TMockTests.TearDown;
begin
  inherited;
  FMock.Free;
end;

procedure TMockTests.VerifyUsageMustFailIfUsageWasNotAsExpected;
begin
  FMock.Expects.Foo;

  try
    FMock.VerifyUsage;
    Fail('Mock was expecting a call that didn''t happen. VerifyUsage should have failed');
  except
    on EUnexpectedUsage do CheckTrue(True);
  end;
end;

procedure TMockTests.VerifyUsageMustNotFailIfUsageWasAsExpected;
begin
  FMock.Expects.Foo;

  FMock.GetObject.Foo;

  FMock.VerifyUsage;
end;

{ TMocked }

procedure TMocked.Foo;
begin
end;

function TMocked.FooWithIntegerReturn: Integer;
begin
  Result := 0;
end;

initialization
RegisterTest('Emballo.Mock', TMockTests.Suite);

end.
