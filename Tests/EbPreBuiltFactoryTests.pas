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

unit EbPreBuiltFactoryTests;

interface

uses
  TestFramework;

type
  TPreBuiltFactoryTests = class(TTestCase)
  published
    procedure TestConstructWithNilInstance;
  end;

implementation

uses
  EbFactory, EbPreBuiltFactory, SysUtils;

{ TPreBuiltFactoryTests }

procedure TPreBuiltFactoryTests.TestConstructWithNilInstance;
var
  Factory: IFactory;
begin
  try
    Factory := TPreBuiltFactory.Create(IInterface, Nil);
    Fail('Instantiating TPreBuiltFactory with instance as Nil must raise an EArgumentException');
  except
    on EArgumentException do CheckTrue(True);
  end;
end;

initialization
RegisterTest(TPreBuiltFactoryTests.Suite);

end.
