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

unit Emballo.DynamicProxy.ImplTests;

interface

uses
  TestFramework;

type
  TTestClass = class
  public
    procedure TestCaseA(A: Byte; B: Integer; C: Double; out D: Double;
      var E: String); virtual; abstract;
  end;

  TDynamicProxyTests = class(TTestCase)
  published
    procedure InvokationHandlerShouldBeCalled;
  end;

implementation

uses
  Rtti,
  Emballo.DynamicProxy.InvokationHandler,
  Emballo.DynamicProxy.Impl;

function NewProxy(InvokationHandler: TInvokationHandlerAnonMethod): TTestClass;
begin
  Result := TDynamicProxy.Create(TTestClass, Nil, InvokationHandler).ProxyObject as TTestClass;
end;

{ TDynamicProxyTests }

procedure TDynamicProxyTests.InvokationHandlerShouldBeCalled;
var
  Test: TTestClass;
  Invoked: Boolean;
  D: Double;
  E: String;
  InvokationHandler: TInvokationHandlerAnonMethod;
begin
  InvokationHandler := procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter)
    begin
      Invoked := True;
    end;

  Test := NewProxy(InvokationHandler);
  try
    Invoked := False;
    Test.TestCaseA(0, 0, 0, D, E);
    CheckTrue(Invoked, 'The invokation handler should be called when a virtual method is called');
  finally
    Test.Free;
  end;
end;

initialization
RegisterTest('Emballo.DynamicProxy', TDynamicProxyTests.Suite);

end.

