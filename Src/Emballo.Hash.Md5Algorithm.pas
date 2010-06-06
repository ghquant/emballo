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

unit Emballo.Hash.Md5Algorithm;

interface

uses
  Emballo.Hash.BaseAlgorithm;

type
  TMd5Algorithm = class(TBaseHashAlgorithm)
  protected
    function FromMemory(const Memory: Pointer; Size: Integer): String; override;
    function SameHashes(const Hash1: String; const Hash2: String): Boolean; override;
  end;

implementation

uses
  Emballo.Hash.Impl.Md5, SysUtils;

{ TMd5Algorithm }

function TMd5Algorithm.FromMemory(const Memory: Pointer; Size: Integer): String;
begin
  Result := MD5Print(MD5Memory(Memory, Size));
end;

function TMd5Algorithm.SameHashes(const Hash1, Hash2: String): Boolean;
begin
  Result := AnsiSameText(Hash1, Hash2);
end;

end.
