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

unit Emballo.Mock.RaiseExceptionClassMethodAction;

interface

uses
  Emballo.General,
  Emballo.DynamicProxy.InvokationHandler,
  Emballo.Mock.MethodAction;

type
  TRaiseExceptionClassMethodAction = class(TInterfacedObject, IMethodAction)
  private
    FExceptionClass: TExceptionClass;
    procedure Execute(const ResultParameter: IParameter);
  public
    constructor Create(const ExceptionClass: TExceptionClass);
  end;

implementation

{ TRaiseExceptionClassMethodAction }

constructor TRaiseExceptionClassMethodAction.Create(
  const ExceptionClass: TExceptionClass);
begin
  FExceptionClass := ExceptionClass;
end;

procedure TRaiseExceptionClassMethodAction.Execute;
begin
  raise FExceptionClass.Create('Error Message');
end;

end.
