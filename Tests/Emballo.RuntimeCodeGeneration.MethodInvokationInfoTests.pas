unit Emballo.RuntimeCodeGeneration.MethodInvokationInfoTests;

interface

uses
  TestFramework,
  RTTI,
  Emballo.RuntimeCodeGeneration.MethodInvokationInfo;

type
  TTestClass = class
  public
    procedure ParameterlessProcedureRegister; register;
    function ParameterlessFunctionRegister: Integer; register;
    procedure ParameterlessProcedureStdcall; stdcall;
    procedure IntegerParameterProcedureRegister(X: Integer); register;
    procedure ParameterProcedureRegisterA(A, B: Integer; C: String; D: Boolean); register;
    function ManagedResultRegisterFunctionA: String; register;
    procedure ProcedureWithPrimitiveParametersRegister(A: Integer; B: Boolean; C: ShortInt); register;
    procedure ProcedureWithStringOutParameterRegister(out X: String); register;
  end;

  TMethodInvokationInfoTests = class(TTestCase)
  private
    FRttiContext: TRttiContext;
    function GetInvokationInfo(const MethodName: String): TMethodInvokationInfo;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure ShouldGetSelfParameter;
    procedure HasResultShouldReturnFalseIfTheMethodDoesntHaveAResultOrTrueIfItDoes;
    procedure ParamCountShouldNotAccountForImplicitParameters;
    procedure ShouldGetResultInfo;
    procedure RegisterTriesToPassParametersLeftToRightOnEaxEdxEcxAndThenOnTheStack;
    procedure FunctionThatReturnsAManagedTypeOnRegisterPassTheResultAsARightMostOutputParameter;
    procedure PrimitiveParametersAreAlwaysPassedByValue;
    procedure OutParametersArePassedByReference;
  end;

implementation

{ TTestClass }

procedure TTestClass.IntegerParameterProcedureRegister(X: Integer);
begin

end;

function TTestClass.ManagedResultRegisterFunctionA: String;
begin
  Result := '';
end;

function TTestClass.ParameterlessFunctionRegister: Integer;
begin
  Result := 0;
end;

procedure TTestClass.ParameterlessProcedureRegister;
begin

end;

procedure TTestClass.ParameterlessProcedureStdcall;
begin

end;

procedure TTestClass.ParameterProcedureRegisterA(A, B: Integer; C: String; D: Boolean);
begin

end;

procedure TTestClass.ProcedureWithPrimitiveParametersRegister(A: Integer;
  B: Boolean; C: ShortInt);
begin

end;

procedure TTestClass.ProcedureWithStringOutParameterRegister(out X: String);
begin

end;

{ TMethodInvokationInfoTests }

procedure TMethodInvokationInfoTests.FunctionThatReturnsAManagedTypeOnRegisterPassTheResultAsARightMostOutputParameter;
var
  InvokationInfo: TMethodInvokationInfo;
begin
  InvokationInfo := GetInvokationInfo('ManagedResultRegisterFunctionA');
  try
    CheckTrue(InvokationInfo.ResultInfo.Location = plEdx);
    CheckFalse(InvokationInfo.ResultInfo.ByValue);
  finally
    InvokationInfo.Free;
  end;
end;

function TMethodInvokationInfoTests.GetInvokationInfo(
  const MethodName: String): TMethodInvokationInfo;
begin
  Result := TMethodInvokationInfo.Create(FRttiContext.GetType(TTestClass).GetMethod(MethodName));
end;

procedure TMethodInvokationInfoTests.HasResultShouldReturnFalseIfTheMethodDoesntHaveAResultOrTrueIfItDoes;
var
  InvokationInfo: TMethodInvokationInfo;
begin
  InvokationInfo := GetInvokationInfo('ParameterlessProcedureRegister');
  try
    CheckFalse(InvokationInfo.HasResult);
  finally
    InvokationInfo.Free;
  end;

  InvokationInfo := GetInvokationInfo('ParameterlessFunctionRegister');
  try
    CheckTrue(InvokationInfo.HasResult);
  finally
    InvokationInfo.Free;
  end;
end;

procedure TMethodInvokationInfoTests.OutParametersArePassedByReference;
var
  InvokationInfo: TMethodInvokationInfo;
  Info: TParamInfo;
begin
  InvokationInfo := GetInvokationInfo('ProcedureWithStringOutParameterRegister');
  try
    Info := InvokationInfo.Params[0];
    CheckFalse(Info.ByValue);
  finally
    InvokationInfo.Free;
  end;
end;

procedure TMethodInvokationInfoTests.ParamCountShouldNotAccountForImplicitParameters;
var
  InvokationInfo: TMethodInvokationInfo;
  Info: TParamInfo;
begin
  InvokationInfo := GetInvokationInfo('ParameterlessProcedureRegister');
  try
    CheckEquals(0, InvokationInfo.ParamCount);
  finally
    InvokationInfo.Free;
  end;

  InvokationInfo := GetInvokationInfo('ParameterlessFunctionRegister');
  try
    CheckEquals(0, InvokationInfo.ParamCount);
  finally
    InvokationInfo.Free;
  end;

  InvokationInfo := GetInvokationInfo('IntegerParameterProcedureRegister');
  try
    CheckEquals(1, InvokationInfo.ParamCount);
  finally
    InvokationInfo.Free;
  end;
end;

procedure TMethodInvokationInfoTests.PrimitiveParametersAreAlwaysPassedByValue;
var
  InvokationInfo: TMethodInvokationInfo;
  Info: TParamInfo;
begin
  InvokationInfo := GetInvokationInfo('ProcedureWithPrimitiveParametersRegister');
  try
    Info := InvokationInfo.Params[0];
    CheckTrue(Info.ByValue);

    Info := InvokationInfo.Params[1];
    CheckTrue(Info.ByValue);

    Info := InvokationInfo.Params[2];
    CheckTrue(Info.ByValue);
  finally
    InvokationInfo.Free;
  end;
end;

procedure TMethodInvokationInfoTests.RegisterTriesToPassParametersLeftToRightOnEaxEdxEcxAndThenOnTheStack;
var
  InvokationInfo: TMethodInvokationInfo;
  Info: TParamInfo;
begin
  InvokationInfo := GetInvokationInfo('ParameterProcedureRegisterA');
  try
    Info := InvokationInfo.Params[0];
    CheckTrue(Info.Location = plEdx);

    Info := InvokationInfo.Params[1];
    CheckTrue(Info.Location = plEcx);

    Info := InvokationInfo.Params[2];
    CheckTrue(Info.Location = plStack);
    CheckEquals(0*SizeOf(Integer), Info.StackOffset);

    Info := InvokationInfo.Params[3];
    CheckTrue(Info.Location = plStack);
    CheckEquals(1*SizeOf(Integer), Info.StackOffset);
  finally
    InvokationInfo.Free;
  end;
end;

procedure TMethodInvokationInfoTests.SetUp;
begin
  inherited;
  FRttiContext := TRttiContext.Create;
end;

procedure TMethodInvokationInfoTests.ShouldGetResultInfo;
var
  InvokationInfo: TMethodInvokationInfo;
  Info: TParamInfo;
begin
  InvokationInfo := GetInvokationInfo('ParameterlessFunctionRegister');
  try
    Info := InvokationInfo.ResultInfo;
    CheckTrue(Info.Location = plEax);
    CheckTrue(Info.Kind = pkResult);
  finally
    InvokationInfo.Free;
  end;
end;

procedure TMethodInvokationInfoTests.ShouldGetSelfParameter;
var
  InvokationInfo: TMethodInvokationInfo;
  Info: TParamInfo;
begin
  InvokationInfo := GetInvokationInfo('ParameterlessProcedureRegister');
  try
    Info := InvokationInfo.SelfParamInfo;
    CheckTrue(Info.Kind = pkImplicitArgument);
    CheckTrue(Info.Location = plEax);
  finally
    InvokationInfo.Free;
  end;

  InvokationInfo := GetInvokationInfo('ParameterlessProcedureStdcall');
  try
    Info := InvokationInfo.SelfParamInfo;
    CheckTrue(Info.Kind = pkImplicitArgument);
    CheckTrue(Info.Location = plStack);
  finally
    InvokationInfo.Free;
  end;
end;

procedure TMethodInvokationInfoTests.TearDown;
begin
  inherited;
  FRttiContext.Free;
end;

initialization
RegisterTest('Emballo.RuntimeCodeGenerator', TMethodInvokationInfoTests.Suite);

end.
