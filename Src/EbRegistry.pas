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

unit EbRegistry;

interface

uses
  EbFactory, EbRegister, EbRegisterImpl, EbUtil;

{ Returns a registered IFactory that can handle the specified GUID. If none can
  be found, return Nil. }
function GetFactoryFor(GUID: TGUID): IFactory;

{ Starts the registration of a generic IFactory }
function RegisterFactory(const Factory: IFactory): IRegister; overload;

{ Start the registration of a factory that will dynamically build an instance
  given its metaclass }
function RegisterFactory(const GUID: TGUID; Implementor: TClass): IRegister; overload;

{ Starts the registration of a factory that will always return a pre defined
  instance }
function RegisterFactory(const GUID: TGUID; const Instance: IInterface): IRegister; overload;

{ Removes all of the already registered factories }
procedure ClearRegistry;

implementation

uses
  Generics.Collections, EbDynamicFactory, EbPreBuiltFactory, SysUtils,
  EbPoolFactory;

var
  Registry: TList<IFactory>;

function RegisterFactory(const Factory: IFactory): IRegister;
begin
  Result := TRegister.Create(Factory, Registry);
end;

function RegisterFactory(const GUID: TGUID; Implementor: TClass): IRegister;
begin
  Result := RegisterFactory(TDynamicFactory.Create(GUID, Implementor));
end;

function RegisterFactory(const GUID: TGUID; const Instance: IInterface): IRegister;
begin
  Result := RegisterFactory(TPreBuiltFactory.Create(GUID, Instance));
end;

function GetFactoryFor(GUID: TGUID): IFactory;
var
  Factory: IFactory;
begin
  for Factory in Registry do
  begin
    if IsEqualGUID(GUID, Factory.GUID) then
      Exit(Factory);
  end;

  Result := Nil;
end;

procedure ClearRegistry;
begin
  Registry.Clear;
end;

initialization
Registry := TList<IFactory>.Create;

finalization
Registry.Free;

end.
