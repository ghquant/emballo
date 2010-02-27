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

unit EbPreBuiltFactory;

interface

uses
  EbAbstractFactory;

type
  { A factory that will always return the same instance. Like a singleton }
  TPreBuiltFactory = class(TAbstractFactory)
  private
    FInstance: IInterface;
  protected
    function GetInstance: IInterface; override;
  public
    constructor Create(GUID: TGUID; const Instance: IInterface);
  end;

implementation

uses
  SysUtils;

{ TPreBuiltFactory }

constructor TPreBuiltFactory.Create(GUID: TGUID; const Instance: IInterface);
begin
  inherited Create(GUID);
  if not Assigned(Instance) then
    raise EArgumentException.Create('TPreBuiltFactory requires a not Nil instance');

  FInstance := Instance;
end;

function TPreBuiltFactory.GetInstance: IInterface;
begin
  Result := FInstance;
end;

end.
