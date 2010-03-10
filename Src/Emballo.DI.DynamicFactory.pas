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

unit Emballo.DI.DynamicFactory;

interface

uses
  Emballo.DI.AbstractFactory;

type
  { A factory thet relies on EbInsantiator.TInstantiator to dynamicaly build
    the instances }
  TDynamicFactory = class(TAbstractFactory)
  private
    FImplementor: TClass;
  protected
    function GetInstance: IInterface; override;
  public
    constructor Create(GUID: TGUID; Implementor: TClass);
  end;

implementation

uses Emballo.DI.Instantiator, SysUtils;

{ TDynamicFactory }

constructor TDynamicFactory.Create(GUID: TGUID; Implementor: TClass);
begin
  inherited Create(GUID);
  FImplementor := Implementor;
end;

function TDynamicFactory.GetInstance: IInterface;
var
  Inst: TInstantiator;
  LInstance: TObject;
begin
  Inst := TInstantiator.Create;
  try
    LInstance := Inst.Instantiate(FImplementor);
    Supports(LInstance, GetGUID, Result);
  finally
    Inst.Free;
  end;
end;

end.
