{   Copyright 2009 - Magno Machado Paulo (magnomp@gmail.com)

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

unit TimeServiceImpl;

interface

uses
  EBInjectable, TimeService;

type
  TTimeServiceImpl = class(TInjectable, ITimeService)
  private
    function CurrentTime: TDateTime;
  end;

implementation

uses
  SysUtils, EBDIRegistry;

{ TTimeServiceImpl }

function TTimeServiceImpl.CurrentTime: TDateTime;
begin
  Result := Time;
end;

initialization
GetDIRegistry.RegisterFactory(ITimeService, TTimeServiceImpl);

end.
