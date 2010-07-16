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

unit Emballo.Mock.MockInternalImpl;

interface

uses
  SysUtils,
  Classes,
  Generics.Collections,
  Emballo.General,
  Emballo.Mock.ExpectedMethodCall,
  Emballo.Mock.MockInternal,
  Emballo.Mock.When;

type
  TMockState = (msCheckingUsage, msWaitingExpectation, msDefiningExpectation);

  TMockInternal<T:class> = class(TInterfacedObject, IMockInternal<T>, IWhen<T>)
  private
    FObject: T;
    FState: TMockState;
    FExpectedCalls: TList<TExpectedMethodCall>;
    FCurrentExpectation: TExpectedMethodCall;
    function GetObject: T;
    function Expects: T;
    procedure VerifyUsage;
    function WillRaise(ExceptionClass: TExceptionClass): IWhen<T>;
    procedure WillReturn(const Value: Integer);
    function When: T;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  Emballo.DynamicProxy.DynamicProxyService,
  Emballo.DynamicProxy.InvokationHandler,
  Rtti,
  Emballo.Mock.DummyMethodAction,
  Emballo.Mock.UnexpectedUsage,
  Emballo.Mock.RaiseExceptionClassMethodAction,
  Emballo.Mock.ReturnValueMethodAction;

{ TMockInternal<T> }

constructor TMockInternal<T>.Create;
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
      msDefiningExpectation:
      begin
        FState := msCheckingUsage;
        FCurrentExpectation.Method := Method;
        FExpectedCalls.Add(FCurrentExpectation);
      end;
    end;
  end;

  FState := msCheckingUsage;

  FObject := DynamicProxyService.Get<T>(InvokationHandler);
end;

destructor TMockInternal<T>.Destroy;
var
  O: TExpectedMethodCall;
begin
  FObject.Free;
  for O in FExpectedCalls do
    O.Free;
  FExpectedCalls.Free;
  inherited;
end;

function TMockInternal<T>.Expects: T;
begin
  FCurrentExpectation := TExpectedMethodCall.Create;
  FCurrentExpectation.Action := TDummyMethodAction.Create;
  Result := FObject;
  FState := msDefiningExpectation;
end;

function TMockInternal<T>.GetObject: T;
begin
  Result := FObject;
end;

procedure TMockInternal<T>.VerifyUsage;
begin
  if FExpectedCalls.Count > 0 then
    raise EUnexpectedUsage.Create('Expected calls didn''t happen');
end;

function TMockInternal<T>.When: T;
begin
  Result := FObject;
end;

function TMockInternal<T>.WillRaise(ExceptionClass: TExceptionClass): IWhen<T>;
begin
  FCurrentExpectation := TExpectedMethodCall.Create;
  FCurrentExpectation.Action := TRaiseExceptionClassMethodAction.Create(ExceptionClass);
  Result := Self;
  FState := msDefiningExpectation;
end;

procedure TMockInternal<T>.WillReturn(const Value: Integer);
begin
  FCurrentExpectation.Action := TReturnValueMethodAction<Integer>.Create(Value);
end;

end.
