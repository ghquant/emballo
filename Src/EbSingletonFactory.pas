{   Copyright 2010 - Magno Machado Paulo (magnomp@gmail.com)

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

unit EbSingletonFactory;

interface

uses
  EbFactory;

type
  { A factory that will always return the same instance. Like a singleton }
  TSingletonFactory = class(TInterfacedObject, IFactory)
  private
    FIntf: TGUID;
    FInstance: IInterface;
    function TryBuild(Intf: TGUID; out Instance: IInterface): Boolean;
  public
    constructor Create(Intf: TGUID; const Instance: IInterface);
  end;

implementation

uses
  SysUtils;

{ TSingletonFactory }

constructor TSingletonFactory.Create(Intf: TGUID; const Instance: IInterface);
begin
  FIntf := Intf;
  FInstance := Instance;
end;

function TSingletonFactory.TryBuild(Intf: TGUID;
  out Instance: IInterface): Boolean;
begin
  Result := IsEqualGUID(FIntf, Intf);
  if Result then
    Instance := FInstance;
end;

end.
