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

unit Emballo.Hash.BaseAlgorithm;

interface

uses
  Classes, Emballo.Hash.Algorithm;

type
  TBaseHashAlgorithm = class(TInterfacedObject, IHashAlgorithm)
  private
    function FromString(const Str: String): String; overload;
    function FromString(const Str: AnsiString): String; overload;
    function FromStream(const Stream: TStream): String;
  protected
    function FromMemory(const Memory: Pointer; Size: Integer): String; virtual; abstract;
    function SameHashes(const Hash1, Hash2: String): Boolean; virtual; abstract;
  end;

implementation

{ TBaseHashAlgorithm }

function TBaseHashAlgorithm.FromString(const Str: String): String;
begin
  Result := FromMemory(@Str[1], Length(Str)*SizeOf(Char));
end;

function TBaseHashAlgorithm.FromStream(const Stream: TStream): String;
var
  Memory: TMemoryStream;
begin
  Memory := TMemoryStream.Create;
  try
    Memory.CopyFrom(Stream, Stream.Size);

    Result := FromMemory(Memory.Memory, Memory.Size);
  finally
    Memory.Free;
  end;
end;

function TBaseHashAlgorithm.FromString(const Str: AnsiString): String;
begin
  Result := FromMemory(@Str[1], Length(Str)*SizeOf(AnsiChar));
end;

end.
