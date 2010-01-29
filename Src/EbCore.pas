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
  ECouldNotBuild = class(Exception)
  public
    constructor Create(const GUID: TGUID);
  end;

{ Try to inject all of "Instance" fields.
  Only interface fields can be injected.
  Only fields that are set to nil can be injected.
  This kind of injection is called "hidden injection" because the field may be
  completelly hidden inside the class, as it doesn't use property, setter nor
  constructor to do it's job }
procedure HiddenInjection(Instance: TObject);

{ Try to build an instance of the given interface. Raises an ECouldNotBuild
  if no instance can be build }
function BuildInstance(Guid: TGUID): IInterface;

implementation

uses
  Rtti, EbInstantiator, EbRegistry, EbUtil, TypInfo;

procedure HiddenInjection(Instance: TObject);
var
  Ctx: TRttiContext;
  RttiType: TRttiType;
  Fields: TArray<TRttiField>;
  Field: TRttiField;
  InterfaceField: TRttiInterfaceType;
  FieldValue: IInterface;
  Value: TValue;
begin
  Ctx := TRttiContext.Create;
  try
    RttiType := Ctx.GetType(Instance.ClassType);
    Fields := RttiType.GetFields;
    for Field in Fields do
    begin
      Value := Field.GetValue(Instance);
      if Value.IsEmpty then
      begin
        if Field.FieldType.TypeKind = tkInterface then
        begin
          InterfaceField := Field.FieldType as TRttiInterfaceType;
          if TryBuild(InterfaceField.GUID, FieldValue) then
          begin
            TValue.Make(@FieldValue, GetTypeInfoFromGUID(InterfaceField .GUID), Value);
            Field.SetValue(Instance, Value);
          end;
        end;
      end;
    end;
  finally
    Ctx.Free;
  end;
end;

function BuildInstance(Guid: TGUID): IInterface;
begin
  if not TryBuild(Guid, Result) then
    raise ECouldNotBuild.Create(Guid);
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
    RttiType := GetRttiTypeFromGUID(Ctx, GUID);
    InterfaceName := RttiType.Name;
    inherited Create('Could not instantiate ' + InterfaceName);
  finally
    Ctx.Free;
  end;
end;

end.
