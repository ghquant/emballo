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

unit Emballo.Hash.Algorithm;

interface

uses
  Classes;

type
  IHashAlgorithm = interface
    ['{CF4FF1BC-1F37-49FE-97D4-627A73A21124}']

    function FromString(const Str: String): String; overload;
    function FromString(const Str: AnsiString): String; overload;
    function FromMemory(const Memory: Pointer; Size: Integer): String;
    function FromStream(const Stream: TStream): String;
    function SameHashes(const Hash1, Hash2: String): Boolean;
  end;

function Md5: IHashAlgorithm;

implementation

uses
  Emballo.Hash.Md5Algorithm;

function Md5: IHashAlgorithm;
begin
  Result := TMd5Algorithm.Create;
end;

end.
