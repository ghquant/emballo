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

unit EbRegisterImpl;

interface

uses
  EbRegister, EbFactory, Generics.Collections;

type
  TRegister = class(TInterfacedObject, IRegister)
  private
    FFactory: IFactory;
    FRegistry: TList<IFactory>;
    function Singleton: IRegister;
    function Pool(Max: Integer): IRegister;
    procedure Done;
  public
    constructor Create(const Factory: IFactory; const Registry: TList<IFactory>);
  end;

implementation

uses
  EbSingletonFactory, EbPoolFactory;

{ TRegister }

constructor TRegister.Create(const Factory: IFactory;
  const Registry: TList<IFactory>);
begin
  FFactory := Factory;
  FRegistry := Registry;
end;

procedure TRegister.Done;
begin
  FRegistry.Add(FFactory);
end;

function TRegister.Pool(Max: Integer): IRegister;
begin
  FFactory := TPoolFactory.Create(FFactory, Max);
  Result := Self;
end;

function TRegister.Singleton: IRegister;
begin
  FFactory := TSingletonFactory.Create(FFactory);
  Result := Self;
end;

end.
