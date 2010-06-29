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

unit Emballo.DynamicProxy.InvokationHandler.ParameterImpl;

interface

uses
  TypInfo,
  SysUtils,
  Emballo.DynamicProxy.InvokationHandler;

type
  TParameter = class(TInterfacedObject, IParameter)
  strict private
    FAddress: Pointer;
    FByValue: Boolean;
    procedure CheckCanSetValue;
  strict protected
    function GetAsByte: Byte;
    procedure SetAsByte(Value: Byte);
    function GetAsInteger: Integer;
    procedure SetAsInteger(Value: Integer);
    function GetAsDouble: Double;
    procedure SetAsDouble(Value: Double);
    function GetAsString: String;
    procedure SetAsString(Value: String);
    function GetAsBoolean: Boolean;
    procedure SetAsBoolean(Value: Boolean);
  public
    { Address is the address on the stack where the value is.
      It ByValue = True, then this is the actual value. If ByValue = False,
      it's a pointer to the actual value }
    constructor Create(Address: Pointer; ByValue: Boolean; TypeKind: TTypeKind);
  end;

implementation

{ TParameter }

constructor TParameter.Create(Address: Pointer; ByValue: Boolean; TypeKind: TTypeKind);
begin
  FAddress := Address;
  FByValue := ByValue;
end;

procedure TParameter.CheckCanSetValue;
begin
  if FByValue then
    raise EParameterReadOnly.Create;
end;

function TParameter.GetAsBoolean: Boolean;
begin
  if FByValue then
    Result := Boolean(FAddress^)
  else
    Result := PBoolean(FAddress^)^;
end;

function TParameter.GetAsByte: Byte;
begin
  if FByValue then
    Result := Byte(FAddress^)
  else
    Result := PByte(FAddress^)^;
end;

function TParameter.GetAsDouble: Double;
begin
  if FByValue then
    Result := Double(FAddress^)
  else
    Result := PDouble(FAddress^)^;
end;

function TParameter.GetAsInteger: Integer;
begin
  if FByValue then
    Result := Integer(FAddress^)
  else
    Result := PInteger(FAddress^)^;
end;

function TParameter.GetAsString: String;
begin
  if FByValue then
    Result := String(FAddress^)
  else
    Result := PString(FAddress^)^;
end;

procedure TParameter.SetAsBoolean(Value: Boolean);
begin
  CheckCanSetValue;
  PBoolean(FAddress^)^ := Value;
end;

procedure TParameter.SetAsByte(Value: Byte);
begin
  CheckCanSetValue;
  PByte(FAddress^)^ := Value;
end;

procedure TParameter.SetAsDouble(Value: Double);
begin
  CheckCanSetValue;
  PDouble(FAddress^)^ := Value;
end;

procedure TParameter.SetAsInteger(Value: Integer);
begin
  CheckCanSetValue;
  PInteger(FAddress^)^ := Value;
end;

procedure TParameter.SetAsString(Value: String);
begin
  CheckCanSetValue;
  PString(FAddress^)^ := Value;
end;

end.
