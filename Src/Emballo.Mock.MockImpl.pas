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

unit Emballo.Mock.MockImpl;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  Emballo.General,
  Emballo.Mock.ExpectedMethodCall,
  Emballo.Mock.Mock;

type
  TMockState = (msCheckingUsage, msWaitingExpectation);

  TMock<T:class> = class(TInterfacedObject, IMock<T>)
  private
    FObject: T;
    FState: TMockState;
    FExpectedCalls: TList<TExpectedMethodCall>;
    FCurrentExpectation: TExpectedMethodCall;
    function GetObject: T;
    function Expects: T;
    procedure VerifyUsage;
    procedure WillRaise(ExceptionClass: TExceptionClass);
    procedure WillReturn(const Value: Integer);
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  Emballo.DynamicProxy.DynamicProxyService,
  Emballo.DynamicProxy.InvokationHandler,
  Rtti, Emballo.Mock.DummyMethodAction, Emballo.Mock.RaiseExceptionClassMethodAction,
  Emballo.Mock.ReturnValueMethodAction;

{ TMock<T> }

constructor TMock<T>.Create;
var
  InvokationHandler: TInvokationHandlerAnonMethod;
begin
  FExpectedCalls := TList<TExpectedMethodCall>.Create;

  InvokationHandler := procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter)
  begin
    case FState of
      msCheckingUsage:
      begin
        if (FExpectedCalls.Count = 0) or (not FExpectedCalls[0].Method.Equals(Method)) then
          raise EUnexpectedUsage.Create('Error Message');

        FExpectedCalls[0].Action.Execute(Result);
        FExpectedCalls[0].Free;
        FExpectedCalls.Delete(0);
      end;
      msWaitingExpectation:
      begin
        FState := msCheckingUsage;
        FCurrentExpectation := TExpectedMethodCall.Create(Method);
        FCurrentExpectation.Action := TDummyMethodAction.Create;
        FExpectedCalls.Add(FCurrentExpectation);
      end;
    end;
  end;

  FState := msCheckingUsage;

  FObject := DynamicProxyService.Get<T>(InvokationHandler);
end;

destructor TMock<T>.Destroy;
var
  O: TExpectedMethodCall;
begin
  FObject.Free;
  for O in FExpectedCalls do
    O.Free;
  FExpectedCalls.Free;
  inherited;
end;

function TMock<T>.Expects: T;
begin
  Result := FObject;
  FState := msWaitingExpectation;
end;

function TMock<T>.GetObject: T;
begin
  Result := FObject;
end;

procedure TMock<T>.VerifyUsage;
begin
  if FExpectedCalls.Count > 0 then
    raise EUnexpectedUsage.Create('Expected calls didn''t happen');
end;

procedure TMock<T>.WillRaise(ExceptionClass: TExceptionClass);
begin
  FCurrentExpectation.Action := TRaiseExceptionClassMethodAction.Create(ExceptionClass);
end;

procedure TMock<T>.WillReturn(const Value: Integer);
begin
  FCurrentExpectation.Action := TReturnValueMethodAction<Integer>.Create(Value);
end;

end.
