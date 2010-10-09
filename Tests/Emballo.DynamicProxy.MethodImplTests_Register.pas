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

{ ******************************* ATENTION *************************************
  * The units Emballo.DynamicProxy.MethodImplTests_SomeCallingConvention are all
  * automatically generated at build time based on the contents of the Register
  * version of the units, so:
  * 1. You should never edit the contents of the other units of this group,
  *    because your changes will be lost as soon as the units are generated again.
  * 2. Any method that is going to be called through the TMethodImpl class and any
  *    procedural type which maps to those methods must declare it's calling
  *    convention, even though it's register. This is necessary for the code
  *    generation script to work }
unit Emballo.DynamicProxy.MethodImplTests_Register;

interface

uses
  TestFramework, Rtti, Emballo.DynamicProxy.InvokationHandler, Emballo.DynamicProxy.MethodImpl;

type
  TTestClass = class
  public
    procedure ConstDoubleParam(const A: Double); register;
    function IntegerResult: Integer; register;
    function DoubleResult: Double; register;
    procedure OutStringParameter(out S: String); register;
    function FunctionWithStringResult: String; register;
  end;

  TMethodImplTests_Register = class(TTestCase)
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
    procedure TestOutStringParameter;
    procedure TestFunctionWithStringResult;
  end;

implementation

{ TMethodImplTests_Register }

function TMethodImplTests_Register.GetMethod(const Name: String;
  const InvokationHandler: TInvokationHandlerAnonMethod): TMethodImpl;
begin
  Result := TMethodImpl.Create(FRttiContext, FRttiType.GetMethod(Name), InvokationHandler);
end;

procedure TMethodImplTests_Register.SetUp;
begin
  inherited;
  FRttiContext := TRttiContext.Create;
  FRttiType := FRttiContext.GetType(TTestClass);
end;

procedure TMethodImplTests_Register.TearDown;
begin
  inherited;
  FRttiContext.Free;
end;

procedure TMethodImplTests_Register.TestDoubleResult;
var
  MethodImpl: TMethodImpl;
  M: function: Double of object; register;
  InvokationHandler: TInvokationHandlerAnonMethod;
  ReturnValue: Double;
begin
  InvokationHandler := procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter)
  begin
    Result.AsDouble := 3.14;
  end;

  MethodImpl := GetMethod('DoubleResult', Invokationhandler);
  try
    TMethod(M).Code := MethodImpl.CodeAddress;
    ReturnValue := M;

    CheckEquals(3.14, ReturnValue, 0.001, 'Shoult capture method return value');
  finally
    MethodImpl.Free;
  end;
end;

procedure TMethodImplTests_Register.TestFunctionWithStringResult;
var
  MethodImpl: TMethodImpl;
  M: function: String of object; register;
  InvokationHandler: TInvokationHandlerAnonMethod;
  ReturnValue: String;
begin
  InvokationHandler := procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter)
  begin
    Result.AsString := 'Test';
  end;

  MethodImpl := GetMethod('FunctionWithStringResult', InvokationHandler);
  try
    TMethod(M).Code := MethodImpl.CodeAddress;
    ReturnValue := M;
    CheckEquals('Test', ReturnValue, 'Should capture method return value');
  finally
    MethodImpl.Free;
  end;
end;

procedure TMethodImplTests_Register.TestIntegerResult;
var
  MethodImpl: TMethodImpl;
  M: function: Integer of object; register;
  InvokationHandler: TInvokationHandlerAnonMethod;
  ReturnValue: Integer;
begin
  InvokationHandler := procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter)
  begin
    Result.AsInteger := 20;
  end;

  MethodImpl := GetMethod('IntegerResult', InvokationHandler);
  try
    TMethod(M).Code := MethodImpl.CodeAddress;
    ReturnValue := M;
    CheckEquals(20, ReturnValue, 'Should capture method return value');
  finally
    MethodImpl.Free;
  end;
end;

procedure TMethodImplTests_Register.TestOutStringParameter;
var
  MethodImpl: TMethodImpl;
  M: procedure(out S: String) of object; register;
  InvokationHandler: TInvokationHandlerAnonMethod;
  Str: String;
begin
  InvokationHandler := procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter)
  begin
    Parameters[0].AsString := 'Test';
  end;

  MethodImpl := GetMethod('OutStringParameter', InvokationHandler);
  try
    TMethod(M).Code := MethodImpl.CodeAddress;
    M(Str);
    CheckEquals('Test', Str);
  finally
    MethodImpl.Free;
  end;
end;

procedure TMethodImplTests_Register.ConstParametersShouldBeReadOnly;
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

  MethodImpl := GetMethod('ConstDoubleParam', InvokationHandler);
  try
    TMethod(M).Code := MethodImpl.CodeAddress;
    M(0);
  finally
    MethodImpl.Free;
  end;
end;

{ TTestClass }

procedure TTestClass.ConstDoubleParam(const A: Double);
begin
end;

function TTestClass.DoubleResult: Double;
begin
  Result := 0;
end;

function TTestClass.FunctionWithStringResult: String;
begin
  Result := '';
end;

function TTestClass.IntegerResult: Integer;
begin
  Result := 0;
end;

procedure TTestClass.OutStringParameter(out S: String);
begin

end;

initialization
RegisterTest('Emballo.DynamicProxy', TMethodImplTests_Register.Suite);

end.
