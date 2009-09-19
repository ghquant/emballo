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

unit EBDependencyInjection;

interface

procedure InjectDependencies(Instance: TObject);

implementation

uses
  EBFieldEnumerator, EBDIRegistry, SysUtils;

procedure InjectDependencies(Instance: TObject);
var
  Fields: TFieldsData;
  Dependency: IInterface;
  i: Integer;
begin
  Fields := EnumerateFields(Instance.ClassType);

  for i := 0 to High(Fields) do
  begin
    Dependency := GetDIRegistry.Instantiate(Instance, Fields[i]);

    if Assigned(Dependency) then
      Fields[i].Inject(Instance, Dependency);
  end;
end;

end.
