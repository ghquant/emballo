unit Emballo.DynamicProxy.MethodImplTests;

interface

uses
  TestFramework, Rtti, Emballo.DynamicProxy.InvokationHandler, Emballo.DynamicProxy.MethodImpl;

type
  TTestClass = class
  public
    procedure ConstDoubleParamRegisterCallingConvention(const A: Double); register;
    function IntegerResultRegisterCallingConvention: Integer; register;
    function DoubleResultRegisterCallingConvention: Double; register;
  end;

  TMethodImplTests = class(TTestCase)
  private
    FRttiContext: TRttiContext;
    FRttiType: TRttiType;
    function GetMethod(const Name: String;
      const InvokationHandler: TInvokationHandlerAnonMethod): TMethodImpl;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ConstParametersShouldBeReadOnly;
    procedure TestIntegerResult;
    procedure TestDoubleResult;
  end;

implementation

{ TMethodImplTests }

function TMethodImplTests.GetMethod(const Name: String;
  const InvokationHandler: TInvokationHandlerAnonMethod): TMethodImpl;
begin
  Result := TMethodImpl.Create(FRttiType.GetMethod(Name), InvokationHandler);
end;

procedure TMethodImplTests.SetUp;
begin
  inherited;
  FRttiContext := TRttiContext.Create;
  FRttiType := FRttiContext.GetType(TTestClass);
end;

procedure TMethodImplTests.TearDown;
begin
  inherited;
  FRttiContext.Free;
end;

procedure TMethodImplTests.TestDoubleResult;
var
  MethodImpl: TMethodImpl;
  M: function: Double of object;
  InvokationHandler: TInvokationHandlerAnonMethod;
  ReturnValue: Double;
begin
  InvokationHandler := procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter)
  begin
    Result.AsDouble := 3.14;
  end;

  MethodImpl := GetMethod('DoubleResultRegisterCallingConvention', Invokationhandler);
  try
    TMethod(M).Code := MethodImpl.CodeAddress;
    ReturnValue := M;

    CheckEquals(3.14, ReturnValue, 0.001, 'Shoult capture method return value');
  finally
    MethodImpl.Free;
  end;
end;

procedure TMethodImplTests.TestIntegerResult;
var
  MethodImpl: TMethodImpl;
  M: function: Integer of object;
  InvokationHandler: TInvokationHandlerAnonMethod;
  ReturnValue: Integer;
begin
  InvokationHandler := procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter)
  begin
    Result.AsInteger := 20;
  end;

  MethodImpl := GetMethod('IntegerResultRegisterCallingConvention', InvokationHandler);
  try
    TMethod(M).Code := MethodImpl.CodeAddress;
    ReturnValue := M;
    CheckEquals(20, ReturnValue, 'Should capture method return value');
  finally
    MethodImpl.Free;
  end;
end;

procedure TMethodImplTests.ConstParametersShouldBeReadOnly;
var
  MethodImpl: TMethodImpl;
  M: procedure(const A: Double) of object; register;
  InvokationHandler: TInvokationHandlerAnonMethod;
begin
  InvokationHandler := procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter)
  begin
    try
      Parameters[0].AsDouble := 10;
      Fail('Const parameters should be read only');
    except
      on EParameterReadOnly do CheckTrue(True);
    end;
  end;

  MethodImpl := GetMethod('ConstDoubleParamRegisterCallingConvention', InvokationHandler);
  try
    TMethod(M).Code := MethodImpl.CodeAddress;
    M(0);
  finally
    MethodImpl.Free;
  end;
end;

{ TTestClass }

procedure TTestClass.ConstDoubleParamRegisterCallingConvention(const A: Double);
begin

end;

function TTestClass.DoubleResultRegisterCallingConvention: Double;
begin

end;

function TTestClass.IntegerResultRegisterCallingConvention: Integer;
begin

end;

initialization
RegisterTest('Emballo.DynamicProxy', TMethodImplTests.Suite);

end.
