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

unit EBInjectableFactoryTests;

interface

uses
  TestFramework;

type
  TInjectableFactoryTests = class(TTestCase)
  published
    procedure TestInstantiate;
    procedure TestConstructor;
  end;

implementation

uses
  EBInjectable, EBInjectableFactory, EBFactory, EBInvalidTypeException,
  EBFieldEnumerator;

type
  IMyInterface = interface
    ['{A3552385-0BD9-4218-B9FB-C940F59E0646}']
  end;

  IUnsupportedInterface = interface
    ['{AD244712-7233-4565-ACD1-D9E8E9EC2316}']
  end;

  TMyInjectable = class(TInjectable, IMyInterface)

  end;

  TMyClass = class
    FInterface: IMyInterface;
    FUnsupported: IUnsupportedInterface;
  end;

{ TInjectableFactoryTests }

procedure TInjectableFactoryTests.TestConstructor;
var
  Factory: IFactory;
begin
  try
    Factory := TInjectableFactory.Create(IUnsupportedInterface, TMyInjectable);
    Fail('Creating TInjectableFactory with incompatible guid and injectable class must raise an exception');
  except
    on EInvalidType do CheckTrue(True);
  end;

  Factory := TInjectableFactory.Create(IMyInterface, TMyInjectable);
end;

procedure TInjectableFactoryTests.TestInstantiate;
var
  Factory: IFactory;
  MyInterface: IInterface;
  Fields: TFieldsData;
begin
  Fields := EnumerateFields(TMyClass);

  Factory := TInjectableFactory.Create(IMyInterface, TMyInjectable);
  MyInterface := Factory.Instantiate(Nil, Fields[0]);
  CheckTrue(Assigned(MyInterface));

  MyInterface := Factory.Instantiate(Nil, Fields[1]);
  CheckFalse(Assigned(MyInterface));
end;

initialization
RegisterTest(TInjectableFactoryTests.Suite);

end.
