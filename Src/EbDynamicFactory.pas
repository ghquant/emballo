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

unit EbDynamicFactory;

interface

uses
  EbFactory;

type
  { A factory thet relies on EbInsantiator.TInstantiator to dynamicaly build
    the instances }
  TDynamicFactory = class(TInterfacedObject, IFactory)
  private
    FGUID: TGUID;
    FImplementor: TClass;
    function GetGUID: TGUID;
    function GetInstance: IInterface;
  public
    constructor Create(GUID: TGUID; Implementor: TClass);
  end;

implementation

uses EbInstantiator, SysUtils;

{ TDynamicFactory }

constructor TDynamicFactory.Create(GUID: TGUID; Implementor: TClass);
begin
  FGUID := GUID;
  FImplementor := Implementor;
end;

function TDynamicFactory.GetGUID: TGUID;
begin
  Result := FGUID;
end;

function TDynamicFactory.GetInstance: IInterface;
var
  Inst: TInstantiator;
  LInstance: TObject;
begin
  Inst := TInstantiator.Create;
  try
    LInstance := Inst.Instantiate(FImplementor);
    Supports(LInstance, FGUID, Result);
  finally
    Inst.Free;
  end;
end;

end.
