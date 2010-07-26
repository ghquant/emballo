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

unit Emballo.Mock.ExpectedMethodCall;

interface

uses
  Rtti, SysUtils,
  Emballo.DynamicProxy.InvokationHandler,
  Emballo.Mock.MethodAction,
  Emballo.Mock.ParameterMatcher,
  Generics.Collections;

type
  TExpectedMethodCall = class
  private
    FMethod: TRttiMethod;
    FAction: IMethodAction;
    FParameterMatchers: array of IParameterMatcher;
    function GetParameterMatcher(Index: Integer): IParameterMatcher;
  public
    destructor Destroy; override;
    property Method: TRttiMethod read FMethod write FMethod;
    property Action: IMethodAction read FAction write FAction;

    procedure RegisterParameterMatchers(const Matchers: array of IParameterMatcher);
    property ParameterMatcher[Index: Integer]: IParameterMatcher read GetParameterMatcher;
    constructor Create;
  end;

implementation

{ TExpectedMethodCall }

constructor TExpectedMethodCall.Create;
begin

end;

destructor TExpectedMethodCall.Destroy;
begin

  inherited;
end;

function TExpectedMethodCall.GetParameterMatcher(Index: Integer): IParameterMatcher;
begin
  Result := FParameterMatchers[Index];
end;

procedure TExpectedMethodCall.RegisterParameterMatchers(
  const Matchers: array of IParameterMatcher);
var
  i: Integer;
begin
  SetLength(FParameterMatchers, Length(Matchers));
  for i := 0 to High(Matchers) do
    FParameterMatchers[i] := Matchers[i];
end;

end.
