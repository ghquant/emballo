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

unit Emballo.Persistence.Mapping.AttributeMapping;

interface

type
  { This class represents the mapping between one attribute of a mapped class
    and a field on the database table }
  TAttributeMapping = class
  private
    FAttributeName: String;
    FFieldName: String;
  public
    constructor Create(const AttributeName, FieldName: String);
    property AttributeName: String read FAttributeName;
    property FieldName: String read FFieldName;
  end;

implementation

{ TAttributeMapping }

constructor TAttributeMapping.Create(const AttributeName, FieldName: String);
begin
  FAttributeName := AttributeName;
  FFieldName := FieldName;
end;

end.
