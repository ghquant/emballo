{   Copyright 2010 - Magno Machado Paulo (magnomp@gmail.com)

    This file is part of Emballo.

    Emballo is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Emballo is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Emballo. If not, see <http://www.gnu.org/licenses/>. }

unit EbAbstractWrapperFactory;

interface

uses
  EbFactory;

type
  { Base factory class for factories that act like wrappers arround
    other factories }
  TAbstractWrapperFactory = class abstract(TInterfacedObject, IFactory)
  private
    function GetGUID: TGUID;
  protected
    FActualFactory: IFactory;
    function GetInstance: IInterface; virtual; abstract;
  public
    constructor Create(const ActualFactory: IFactory);
  end;

implementation

{ TAbstractWrapperFactory }

constructor TAbstractWrapperFactory.Create(const ActualFactory: IFactory);
begin
  FActualFactory := ActualFactory;
end;

function TAbstractWrapperFactory.GetGUID: TGUID;
begin
  Result := FActualFactory.GUID;
end;

end.
