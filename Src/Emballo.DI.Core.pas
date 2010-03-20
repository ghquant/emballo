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

unit Emballo.DI.Core;

interface

uses
  SysUtils;

type
  TDIService = class
  public
    function Get<ServiceInterface>: ServiceInterface; overload;
    function Get(GUID: TGUID): IInterface; overload;
  end;

  ECouldNotBuild = class(Exception)
  public
    constructor Create(const GUID: TGUID);
  end;

function DIService: TDIService;

implementation

uses
  Rtti, Emballo.DI.Instantiator, Emballo.DI.Registry, Emballo.Rtti, TypInfo, Emballo.DI.Factory;

function DIService: TDIService;
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

{ TDIService }

function TDIService.Get(GUID: TGUID): IInterface;
var
  Factory: IFactory;
begin
  Factory := GetFactoryFor(GUID);
  if Assigned(Factory) then
    Result := Factory.GetInstance
  else
    raise ECouldNotBuild.Create(GUID);
end;

function TDIService.Get<ServiceInterface>: ServiceInterface;
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
