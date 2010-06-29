unit Emballo.Mock.MockImplTests;

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

  TMockImplTests = class(TTestCase)
  private
    FMock: IMock<TMocked>;
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
  end;

implementation

uses
  Emballo.Mock.MockImpl;

{ TMockImplTests }

procedure TMockImplTests.ExpectedCallShouldNotFail;
begin
  FMock.Expects.Foo;

  FMock.GetObject.Foo;
end;

procedure TMockImplTests.MethodShouldReturnSpecifiedValue;
var
  ReturnValue: Integer;
begin
  FMock.Expects.FooWithIntegerReturn;
  FMock.WillReturn(10);

  ReturnValue := FMock.GetObject.FooWithIntegerReturn;

  CheckEquals(10, ReturnValue, 'Mocked method should return the specified value');
end;

procedure TMockImplTests.SetUp;
begin
  inherited;
  FMock := TMock<TMocked>.Create;
end;

procedure TMockImplTests.ShouldFailOnUnexpectedCalls;
begin
  try
    FMock.GetObject.Foo;
    Fail('An unexpected usage of the mocked object should raise an EUnexpectedUsage');
  except
    on EUnexpectedUsage do CheckTrue(True);
  end;
end;

procedure TMockImplTests.ShouldRaiseConfiguredException;
begin
  FMock.Expects.Foo;
  FMock.WillRaise(ETestException);

  try
    FMock.GetObject.Foo;
    Fail('The configured exception should have been raised');
  except
    on ETestException do CheckTrue(True);
  end;
end;

procedure TMockImplTests.TearDown;
begin
  inherited;
  FMock := Nil;
end;

procedure TMockImplTests.VerifyUsageMustFailIfUsageWasNotAsExpected;
begin
  FMock.Expects.Foo;

  try
    FMock.VerifyUsage;
    Fail('Mock was expecting a call that didn''t happen. VerifyUsage should have failed');
  except
    on EUnexpectedUsage do CheckTrue(True);
  end;
end;

procedure TMockImplTests.VerifyUsageMustNotFailIfUsageWasAsExpected;
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
end;

initialization
RegisterTest('Emballo.Mock', TMockImplTests.Suite);

end.
