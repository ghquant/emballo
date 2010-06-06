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

unit Emballo.Persistence.Mapping.ClassMapping;

interface

type
  { Represents the mapping between a class and a table }
  TClassMapping = class
  private
    FMappedClass: TClass;
    FMappedTable: String;
  public
    constructor Create(MappedClass: TClass; const MappedTable: String);
    property MappedClass: TClass read FMappedClass;
    property MappedTable: String read FMappedTable;
  end;

implementation

{ TClassMapping }

constructor TClassMapping.Create(MappedClass: TClass;
  const MappedTable: String);
begin
  FMappedClass := MappedClass;
  FMappedTable := MappedTable;
end;

end.
