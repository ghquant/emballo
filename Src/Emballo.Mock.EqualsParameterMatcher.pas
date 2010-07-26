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

unit Emballo.Mock.EqualsParameterMatcher;

interface

uses
  Emballo.Mock.ParameterMatcher;

type
  TEqualsParameterMatcher<T> = class(TInterfacedObject, IParameterMatcher)
  private
    FValue: T;
    function Match(const Value: Variant): Boolean;
  public
    constructor Create(const Value: T);
  end;

implementation

{ TEqualsParameterMatcher<T> }

constructor TEqualsParameterMatcher<T>.Create(const Value: T);
begin
  FValue := Value;
end;

function TEqualsParameterMatcher<T>.Match(const Value: Variant): Boolean;
begin
  Result := PInteger(@FValue)^ = Value;
end;

end.
