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

unit Emballo.DI.DelegateFactory;

interface

uses
  Emballo.DI.Factory,
  Emballo.DI.AbstractFactory;

type
  TGetInstance = reference to function: IInterface;

  IDelegateFactory = interface
    ['{997E1AFD-9B52-4BF4-85DC-F2A5E8CA693D}']
    procedure SetGetInstance(Value: TGetInstance);
  end;

  TDelegateFactory = class(TAbstractFactory, IDelegateFactory, IFactory)
  private

    procedure SetGetInstance(Value: TGetInstance);
  protected
    function GetInstance: IInterface; override;
  public
    FGetInstance: TGetInstance;
    destructor Destroy; override;
  end;

implementation

{ TDelegateFactory }

destructor TDelegateFactory.Destroy;
begin
  FGetInstance := Nil;
  inherited;
end;

function TDelegateFactory.GetInstance: IInterface;
begin
  Result := FGetInstance;
end;

procedure TDelegateFactory.SetGetInstance(Value: TGetInstance);
begin
  FGetInstance := Value;
end;

end.
