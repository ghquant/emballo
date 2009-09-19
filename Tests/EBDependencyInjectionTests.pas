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

unit EBDependencyInjectionTests;

interface

uses
  TestFramework;

type
  TDependencyInjectionTests = class(TTestCase)
  published
    procedure TestInjectDependencies;
  end;

implementation

uses
  EBDependencyInjection, EBDIRegistry, EBFieldEnumerator, SysUtils, EBFactory;

type
  ISomeInterface = interface
    ['{93DCF982-8155-4E3C-8258-A17B9B1DD946}']
  end;

  TSomeInterfaceImpl = class(TInterfacedObject, ISomeInterface)

  end;

  IOtherInterface = interface
    ['{165D1573-08DC-4DF0-9798-BF46FCB6DFB0}']
  end;

  TOtherInterfaceImpl = class(TInterfacedObject, IOtherInterface)

  end;

  INotInjectableInterface = interface
    ['{F45D6813-B911-407C-BF0A-EA4FD5AFCA2C}']
  end;

  TTestObject = class
  private
    FSomeInterface: ISomeInterface;
    FOtherInterface: IOtherInterface;
    FNotInjectableInterface: INotInjectableInterface;
  end;

{ TDependencyInjectionTests }

procedure TDependencyInjectionTests.TestInjectDependencies;
var
  TestObject: TTestObject;
begin
  GetDIRegistry.RegisterFactory(ISomeInterface, TSomeInterfaceImpl, @TSomeInterfaceImpl.Create);
  GetDIRegistry.RegisterFactory(IOtherInterface, TOtherInterfaceImpl, @TOtherInterfaceImpl.Create);

  TestObject := TTestObject.Create;
  try
    InjectDependencies(TestObject);

    CheckTrue(Assigned(TestObject.FSomeInterface));
    CheckTrue(Assigned(TestObject.FOtherInterface));
    CheckFalse(Assigned(TestObject.FNotInjectableInterface));
  finally
    TestObject.Free;
  end;
end;

initialization
RegisterTest(TDependencyInjectionTests.Suite);

end.
