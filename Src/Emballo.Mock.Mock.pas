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

unit Emballo.Mock.Mock;

interface

uses
  SysUtils,
  Emballo.General,
  Emballo.Mock.MockInternal;

type
  TMock<T:class> = record
  private
    FInternal: IMockInternal<T>;
  public
    function GetObject: T;
    function Expects: T;
    procedure VerifyUsage;
    procedure WillRaise(ExceptionClass: TExceptionClass);
    procedure WillReturn(const Value: Integer);
    class function Create: TMock<T>; static;
    procedure Free;
  end;

implementation

uses
  Emballo.Mock.MockInternalImpl;

{ TMock<T> }

class function TMock<T>.Create: TMock<T>;
begin
  Result.FInternal := TMockInternal<T>.Create;
end;

function TMock<T>.Expects: T;
begin
  Result := FInternal.Expects;
end;

procedure TMock<T>.Free;
begin
  FInternal := Nil;
end;

function TMock<T>.GetObject: T;
begin
  Result := FInternal.GetObject;
end;

procedure TMock<T>.VerifyUsage;
begin
  FInternal.VerifyUsage;
end;

procedure TMock<T>.WillRaise(ExceptionClass: TExceptionClass);
begin
  FInternal.WillRaise(ExceptionClass);
end;

procedure TMock<T>.WillReturn(const Value: Integer);
begin
  FInternal.WillReturn(Value);
end;

end.
