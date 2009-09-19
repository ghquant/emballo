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

unit EBPreBuiltFactoryTests;

interface

uses
  TestFramework;

type
  TPreBuiltFactoryTests = class(TTestCase)
  published
    procedure TestConstructor;
    procedure TestInstantiate;
  end;

implementation

uses
  EBFactory, EBPreBuiltFactory, Classes, EBInvalidTypeException, EBFieldEnumerator;

type
  IMyInterface = interface
    ['{7EB95A6C-7B4F-4C57-A3D2-F2ACCC26D056}']
  end;

  IUnsupportedInterface = interface
    ['{75C5C0F8-53D0-4242-A37C-1E0D08A92137}']
  end;

  TMyClass = class(TInterfacedObject, IMyInterface)

  end;

  TMyObject = class
    FInterface: IMyInterface;
    FUnsupportedInterface: IUnsupportedInterface;
  end;

{ TPreBuiltFactoryTests }

procedure TPreBuiltFactoryTests.TestConstructor;
var
  Factory: IFactory;
  Instance: IInterface;
begin
  Instance := TMyClass.Create;

  try
    Factory := TPreBuiltFactory.Create(IUnsupportedInterface, Instance);
    Fail('Pre built instance must support specified guid');
  except
    on EInvalidType do CheckTrue(True);
  end;
end;

procedure TPreBuiltFactoryTests.TestInstantiate;
var
  Instance: IInterface;
  Factory: IFactory;
  Fields: TFieldsData;
begin
  Fields := EnumerateFields(TMyObject);
  Instance := TMyClass.Create;
  Factory := TPreBuiltFactory.Create(IMyInterface, Instance);
  CheckTrue(Instance = Factory.Instantiate(Nil, Fields[0]));
  CheckFalse(Assigned(Factory.Instantiate(Nil, Fields[1])));
end;

initialization
RegisterTest(TPreBuiltFactoryTests.Suite);

end.
