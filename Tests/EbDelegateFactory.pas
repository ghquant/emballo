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

unit EbDelegateFactory;

interface

uses
  EbAbstractFactory;

type
  TGetInstance = reference to function: IInterface;

  IDelegateFactory = interface
    ['{997E1AFD-9B52-4BF4-85DC-F2A5E8CA693D}']
    procedure SetGetInstance(Value: TGetInstance);
  end;

  TDelegateFactory = class(TAbstractFactory, IDelegateFactory)
  private
    FGetInstance: TGetInstance;
    procedure SetGetInstance(Value: TGetInstance);
  protected
    function GetInstance: IInterface; override;
  end;

implementation

{ TDelegateFactory }

function TDelegateFactory.GetInstance: IInterface;
begin
  Result := FGetInstance;
end;

procedure TDelegateFactory.SetGetInstance(Value: TGetInstance);
begin
  FGetInstance := Value;
end;

end.
