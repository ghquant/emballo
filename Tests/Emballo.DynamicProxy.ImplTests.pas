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

  {$M+}
  ITestInterface = interface
    ['{CC2E979B-2ACF-43AA-BEF2-536DCCA1A7A5}']
    procedure Foo;
  end;
  {$M-}

  TDynamicProxyTests = class(TTestCase)
  published
    procedure InvokationHandlerShouldBeCalled;
    procedure TestInterfaceProxy;
    procedure VerifyCanCallInterfaceMethods;
  end;

implementation

uses
  Rtti,
  TypInfo,
  SysUtils,
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

procedure TDynamicProxyTests.TestInterfaceProxy;
var
  P: TDynamicProxy;
  Intf: TArray<PTypeInfo>;
  InvokationHandler: TInvokationHandlerAnonMethod;
  TestInterface: ITestInterface;
begin
  InvokationHandler := procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter)
    begin
    end;

  SetLength(Intf, 1);
  Intf[0] := TypeInfo(ITestInterface);
  P := TDynamicProxy.Create(Nil, Intf, InvokationHandler);
  P.ProxyObject.GetInterface(ITestInterface, TestInterface);

  CheckTrue(Supports(P.ProxyObject, ITestInterface), 'The returned proxy should support the required interfaces');

  TestInterface := Nil;
end;

procedure TDynamicProxyTests.VerifyCanCallInterfaceMethods;
var
  P: TDynamicProxy;
  Intf: TArray<PTypeInfo>;
  InvokationHandler: TInvokationHandlerAnonMethod;
  TestInterface: ITestInterface;
begin
  InvokationHandler := procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter)
    begin
    end;

  SetLength(Intf, 1);
  Intf[0] := TypeInfo(ITestInterface);
  P := TDynamicProxy.Create(Nil, Intf, InvokationHandler);
  Supports(P.ProxyObject, ITestInterface, TestInterface);
  TestInterface.Foo;
end;

initialization
RegisterTest('Emballo.DynamicProxy', TDynamicProxyTests.Suite);

end.

