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

unit EBPreBuiltFactory;

interface

uses
  EBFactory, EBFieldEnumerator, Classes;

type
  { A "factory" that instead of creating objects, always return the same pre-built
    object. Useful for unit test. }
  TPreBuiltFactory = class(TInterfacedObject, IFactory)
  private
    FInstance: IInterface;
    FGuid: TGUID;
    function Instantiate(Owner: TObject; Field: IFieldData): IInterface;
  public
    constructor Create(Guid: TGUID; const Instance: IInterface);
  end;

implementation

uses
  SysUtils, EBInvalidTypeException;

{ TPreBuiltFactory }

constructor TPreBuiltFactory.Create(Guid: TGUID; const Instance: IInterface);
begin
  if not Supports(Instance, Guid) then
    raise EInvalidType.Create('Pre built instance must support specified guid');

  FGuid := Guid;
  FInstance := Instance;
end;

function TPreBuiltFactory.Instantiate(Owner: TObject;
  Field: IFieldData): IInterface;
begin
  if IsEqualGUID(Field.Guid, FGuid) then
    Result := FInstance
  else
    Result := Nil;
end;

end.
