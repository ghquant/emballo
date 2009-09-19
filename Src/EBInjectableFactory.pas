{   Copyright 2009 - Magno Machado Paulo (magnomp@gmail.com)

    This file is part of Emballo.

    Emballo is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Emballo is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>. }

unit EBInjectableFactory;

interface

uses
  EBInjectable, EBFactory, Classes, EBFieldEnumerator;

type
  { A factory that can instantiate objects from TInjectable }
  TInjectableFactory = class(TInterfacedObject, IFactory)
  private
    FGuid: TGUID;
    FInjectable: TInjectableClass;
    function Instantiate(Owner: TObject; Field: IFieldData): IInterface;
  public
    constructor Create(Guid: TGUID; Injectable: TInjectableClass);
  end;

implementation

uses
  SysUtils, EBInvalidTypeException;

{ TInjectableFactory }

constructor TInjectableFactory.Create(Guid: TGUID;
  Injectable: TInjectableClass);
begin
  if not Supports(Injectable, Guid) then
    raise EInvalidType.Create('TInjectableFactory can only be created with compatible injectable class and guid');

  FGuid := Guid;
  FInjectable := Injectable;
end;

function TInjectableFactory.Instantiate(Owner: TObject;
  Field: IFieldData): IInterface;
begin
  if IsEqualGUID(FGuid, Field.Guid) then
    Result := FInjectable.Create as IInterface
  else
    Result := Nil;
end;

end.
