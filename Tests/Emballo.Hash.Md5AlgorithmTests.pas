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

unit Emballo.Hash.Md5AlgorithmTests;

interface

uses
  TestFramework, Emballo.Hash.Algorithm, Emballo.Hash.Md5Algorithm;

type
  TMd5AlgorithmTests = class(TTestCase)
  private
    FMd5: IHashAlgorithm;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestFromMemory;
  end;

implementation

{ TMd5AlgorithmTests }

procedure TMd5AlgorithmTests.SetUp;
begin
  inherited;
  FMd5 := TMd5Algorithm.Create;
end;

procedure TMd5AlgorithmTests.TearDown;
begin
  inherited;
  FMd5 := Nil;
end;

procedure TMd5AlgorithmTests.TestFromMemory;
var
  S: AnsiString;
begin
  S := 'a';
  CheckEquals('0cc175b9c0f1b6a831c399e269772661', FMd5.FromMemory(@S[1], 1));

  CheckEquals('d41d8cd98f00b204e9800998ecf8427e', FMd5.FromMemory(Nil, 0));
end;

initialization
RegisterTest('Emballo.Hash', TMd5AlgorithmTests.Suite);

end.
