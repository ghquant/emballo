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

unit EbSingletonFactory;

interface

uses
  EbAbstractWrapperFactory, EbFactory;

type
  { A factory that works on top of another factory. At the time of the first
    call to GetInstance, it will use the base factory to get the result and will
    cache it. On later calls, it will always return the cached result }
  TSingletonFactory = class(TAbstractWrapperFactory)
  private
    FInstance: IInterface;
  protected
    function GetDeferredFactory: TDeferredFactory; override;
  end;


implementation

{ TSingletonFactory }

function TSingletonFactory.GetDeferredFactory: TDeferredFactory;
begin
  Result := function: IInterface
  begin
    if not Assigned(FInstance) then
      FInstance := FActualFactory.GetDeferredFactory;

    Result := FInstance;
  end;
end;

end.
