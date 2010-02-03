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

unit EbUtil;

interface

uses
  TypInfo, SysUtils, Rtti;

type
  EUnknownGUID = class(Exception)
  public
    constructor Create(GUID: TGUID);
  end;

  ENotCoveredEnumValue = class(Exception)
  public
    constructor Create(EnumTypeInfo: PTypeInfo; EnumValue: Integer);
  end;

{ Returns the typeinfo of an interface given it's GUID.
  The interface is searched using Rtti, and if no interface with the given GUID
  can be found, an EUnknownGUID is raised }
function GetTypeInfoFromGUID(GUID: TGUID): PTypeInfo;

function GetRttiTypeFromGUID(Ctx: TRttiContext; GUID: TGUID): TRttiInterfaceType;

procedure NotCoveredEnumValue(EnumTypeInfo: PTypeInfo; EnumValue: Integer);

implementation

function GetRttiTypeFromGUID(Ctx: TRttiContext; GUID: TGUID): TRttiInterfaceType;
var
  Types: TArray<TRttiType>;
  LType: TRttiType;
begin
  Types := Ctx.GetTypes;
  for LType in Types do
  begin
    if LType is TRttiInterfaceType then
    begin
      Result := LType as TRttiInterfaceType;
      if IsEqualGUID(Result.GUID, GUID) then
        Exit;
    end;
  end;

  raise EUnknownGUID.Create(GUID);
end;

function GetTypeInfoFromGUID(GUID: TGUID): PTypeInfo;
var
  Ctx: TRttiContext;
begin
  Ctx := TRttiContext.Create;
  try
    Result := GetRttiTypeFromGUID(Ctx, GUID).Handle;
  finally
    Ctx.Free;
  end;
end;

{ EUnknownGUID }

constructor EUnknownGUID.Create(GUID: TGUID);
begin
  inherited Create('GUID not found: ' + GUIDToString(GUID));
end;

{ ENotCoveredEnumValue }

constructor ENotCoveredEnumValue.Create(EnumTypeInfo: PTypeInfo;
  EnumValue: Integer);
var
  EnumName: String;
begin
  EnumName := GetEnumName(EnumTypeInfo, EnumValue);
  inherited CreateFmt('Forgot to add support to enum value %s somewhere', [EnumName]);
end;

procedure NotCoveredEnumValue(EnumTypeInfo: PTypeInfo; EnumValue: Integer);
begin
  raise ENotCoveredEnumValue.Create(EnumTypeInfo, EnumValue);
end;

end.
