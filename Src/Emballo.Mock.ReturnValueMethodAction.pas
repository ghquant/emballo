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

unit Emballo.Mock.ReturnValueMethodAction;

interface

uses
  Emballo.DynamicProxy.InvokationHandler,
  Emballo.Mock.MethodAction;

type
  TReturnValueMethodAction<T> = class(TInterfacedObject, IMethodAction)
  private
    FValue: T;
    FStrValue: String;
  protected
    procedure Execute(const ResultParameter: IParameter); virtual;
  public
    constructor Create(const Value: T);
  end;

  TReturnStringValueMethodAction = class(TReturnValueMethodAction<String>)
  protected
    procedure Execute(const ResultParameter: IParameter); override;
  end;

implementation

uses
  TypInfo, SysUtils;

{ TReturnValueMethodAction<T> }

constructor TReturnValueMethodAction<T>.Create(const Value: T);
begin
  FValue := Value;
end;

procedure TReturnValueMethodAction<T>.Execute(const ResultParameter: IParameter);
begin
  case PTypeInfo(TypeInfo(T)).Kind of
    tkInteger: ResultParameter.AsInteger := PInteger(@FValue)^;
  end;
end;

{ TReturnStringValueMethodAction }

procedure TReturnStringValueMethodAction.Execute(
  const ResultParameter: IParameter);
begin
  ResultParameter.AsString := FValue;
end;

end.
