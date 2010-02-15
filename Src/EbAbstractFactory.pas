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

unit EbAbstractFactory;

interface

uses
  EbFactory;

type
  { Base class for implementing factories }
  TAbstractFactory = class abstract(TInterfacedObject, IFactory)
  private
    FGUID: TGUID;
  protected
    function GetGUID: TGUID;
    function GetInstance: IInterface; virtual; abstract;
  public
    constructor Create(GUID: TGUID);
  end;

implementation

{ TAbstractFactory }

constructor TAbstractFactory.Create(GUID: TGUID);
begin
  FGUID := GUID;
end;

function TAbstractFactory.GetGUID: TGUID;
begin
  Result := FGUID;
end;

end.
