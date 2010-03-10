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

unit Emballo.DI.SingletonFactory;

interface

uses
  Emballo.DI.AbstractWrapperFactory;

type
  { A factory that works on top of another factory. At the time of the first
    call to GetInstance, it will use the base factory to get the result and will
    cache it. On later calls, it will always return the cached result }
  TSingletonFactory = class(TAbstractWrapperFactory)
  private
    FInstance: IInterface;
  protected
    function GetInstance: IInterface; override;
  end;


implementation

{ TSingletonFactory }

function TSingletonFactory.GetInstance: IInterface;
begin
  if not Assigned(FInstance) then
    FInstance := FActualFactory.GetInstance;

  Result := FInstance;
end;

end.
