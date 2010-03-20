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

unit Emballo.Interfaces.Proxy.ImplTests;

interface

uses
  TestFramework;

type
  {$M+}
  ITestInterface = interface
    ['{2FD757BE-187D-4791-90C2-DB7495E561BB}']

    procedure TestCaseA(A: Byte; B: Integer; C: Double; out D: Double;
      var E: String); stdcall;
  end;
  {$M-}

  TInterfaceProxyTests = class(TTestCase)
  published
    procedure TestIntegerParamStdCall;
  end;

implementation

uses
  Rtti,
  Emballo.Interfaces.Proxy.InvokationHandler,
  Emballo.Interfaces.Proxy.Impl;

function NewProxy(InvokationHandler: TInvokationHandler): ITestInterface;
begin
  Result := TInterfaceProxy.Create(TypeInfo(ITestInterface), InvokationHandler) as ITestInterface;
end;

{ TInterfaceProxyTests }

procedure TInterfaceProxyTests.TestIntegerParamStdCall;
var
  Test: ITestInterface;
  D: Double;
  E: String;
begin
  Test := NewProxy(procedure(Method: TRttiMethod;
    Parameters: TArray<IParameter>; Result: IParameter)
  begin
    CheckEquals(10, Parameters[0].AsByte, 'Error reading paameters');
    CheckEquals(12345678, Parameters[1].AsInteger, 'Error reading parameters');
    CheckEquals(3.1415, Parameters[2].AsDouble, 0.00001, 'Error reading parameters');
    Parameters[3].AsDouble := 1234.56;
    CheckEquals('BeforeCall', Parameters[4].AsString, 'Error reading parameters');
    Parameters[4].AsString := 'AfterCall';
  end);

  E := 'BeforeCall';
  Test.TestCaseA(10, 12345678, 3.1415, D, E);
  CheckEquals(1234.56, D, 0.001, 'Error with out parameter');
  CheckEquals('AfterCall', E, 'Error with var parameter');
end;

initialization
RegisterTest('Emballo.Interfaces.Proxy', TInterfaceProxyTests.Suite);

end.

