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

unit EbCore;

interface

uses
  SysUtils;

type
  TEmballo = class
  public
    function Get<ServiceInterface>: ServiceInterface; overload;
    function Get(GUID: TGUID): IInterface; overload;
  end;

  ECouldNotBuild = class(Exception)
  public
    constructor Create(const GUID: TGUID);
  end;

function Emballo: TEmballo;

implementation

uses
  Rtti, EbInstantiator, EbRegistry, EbUtil, TypInfo, EbFactory;

function Emballo: TEmballo;
begin
  Result := Nil;
end;

{ ECouldNotBuild }

constructor ECouldNotBuild.Create(const GUID: TGUID);
var
  Ctx: TRttiContext;
  RttiType: TRttiInterfaceType;
  InterfaceName: String;
begin
  Ctx := TRttiContext.Create;
  try
    try
      RttiType := GetRttiTypeFromGUID(Ctx, GUID);
      InterfaceName := RttiType.Name;
    except
      on EUnknownGUID do InterfaceName := GUIDToString(GUID);
    end;
    inherited Create('Could not instantiate ' + InterfaceName);
  finally
    Ctx.Free;
  end;
end;

{ TEmballo }

function TEmballo.Get(GUID: TGUID): IInterface;
var
  DeferredFactory: TDeferredFactory;
begin
  if not TryBuild(GUID, DeferredFactory) then
    raise ECouldNotBuild.Create(GUID);

  Result := DeferredFactory;
end;

function TEmballo.Get<ServiceInterface>: ServiceInterface;
var
  Service: IInterface;
  Ctx: TRttiContext;
  ServiceRttiType: TRttiType;
  ServiceGUID: TGUID;
begin
  Ctx := TRttiContext.Create;
  try
    ServiceRttiType := Ctx.GetType(TypeInfo(ServiceInterface));
    if ServiceRttiType.TypeKind <> tkInterface then
      raise EArgumentException.Create('Emballo.Get must be called only with interface types');

    ServiceGUID := (ServiceRttiType as TRttiInterfaceType).GUID;
    Service := Get(ServiceGUID);

    Supports(Service, ServiceGUID, Result);
  finally
    Ctx.Free;
  end;
end;

end.
