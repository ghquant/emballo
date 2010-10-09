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
  Rtti,
  Generics.Collections,
  Emballo.DynamicProxy.InvokationHandler,
  Emballo.General,
  Emballo.Mock.ExpectedMethodCall,
  Emballo.Mock.MethodAction,
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
    function IsMatchingCall(const Expected: TExpectedMethodCall; const Method: TRttiMethod;
      const Parameters: array of IParameter): Boolean;
    procedure DefineExpectation(const Method: TRttiMethod; const Parameters: array of IParameter);
    function BeginExpectation(Action: IMethodAction): IWhen<T>;
    function GetObject: T;
    function Expects: T;
    procedure VerifyUsage;
    function WillRaise(ExceptionClass: TExceptionClass): IWhen<T>;
    function WillReturn(const Value: Integer): IWhen<T>; overload;
    function WillReturn(const Value: String): IWhen<T>; overload;
    function When: T;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
  Emballo.DynamicProxy.DynamicProxyService,
  Emballo.Mock.DummyMethodAction,
  Emballo.Mock.UnexpectedUsage,
  Emballo.Mock.RaiseExceptionClassMethodAction,
  Emballo.Mock.ReturnValueMethodAction, Emballo.Mock.ParameterMatcher,
  Emballo.Mock.EqualsParameterMatcher;

{ TMockInternal<T> }

function TMockInternal<T>.BeginExpectation(Action: IMethodAction): IWhen<T>;
begin
  FCurrentExpectation := TExpectedMethodCall.Create;
  FCurrentExpectation.Action := Action;
  Result := Self;
  FState := msDefiningExpectation;
end;

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
        if (FExpectedCalls.Count = 0) or (not IsMatchingCall(FExpectedCalls[0], Method, Parameters)) then
          raise EUnexpectedUsage.Create('Error Message');

        FExpectedCalls[0].Action.Execute(Result);
        FExpectedCalls[0].Free;
        FExpectedCalls.Delete(0);
      end;
      msDefiningExpectation: DefineExpectation(Method, Parameters);
    end;
  end;

  FState := msCheckingUsage;

  FObject := DynamicProxyService.Get<T>(InvokationHandler);
end;

procedure TMockInternal<T>.DefineExpectation(const Method: TRttiMethod;
  const Parameters: array of IParameter);
var
  i: Integer;
  RttiParameters: TArray<TRttiParameter>;
  Matchers: array of IParameterMatcher;
begin
  FState := msCheckingUsage;
  RttiParameters := Method.GetParameters;
  FCurrentExpectation.Method := Method;
  SetLength(Matchers, Length(Parameters));
  for i := 0 to High(Matchers) do
    Matchers[i] := TEqualsParameterMatcher<Integer>.Create(Parameters[i].AsInteger);

  FCurrentExpectation.RegisterParameterMatchers(Matchers);

  FExpectedCalls.Add(FCurrentExpectation);
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
  Result := BeginExpectation(TDummyMethodAction.Create).When;
end;

function TMockInternal<T>.GetObject: T;
begin
  Result := FObject;
end;

function TMockInternal<T>.IsMatchingCall(const Expected: TExpectedMethodCall;
  const Method: TRttiMethod; const Parameters: array of IParameter): Boolean;
var
  i: Integer;
begin
  Result := False;

  if not Expected.Method.Equals(Method) then
    Exit;

  for i := 0 to High(Parameters) do
    if not Expected.ParameterMatcher[i].Match(Parameters[i].AsInteger) then
      Exit;

  Result := True;
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
  Result := BeginExpectation(TRaiseExceptionClassMethodAction.Create(ExceptionClass));
end;

function TMockInternal<T>.WillReturn(const Value: String): IWhen<T>;
begin
  Result := BeginExpectation(TReturnStringValueMethodAction.Create(Value));
end;

function TMockInternal<T>.WillReturn(const Value: Integer): IWhen<T>;
begin
  Result := BeginExpectation(TReturnValueMethodAction<Integer>.Create(Value));
end;

end.
