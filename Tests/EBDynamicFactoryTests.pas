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

unit EBDynamicFactoryTests;

interface

uses
  TestFramework;

type
  TDynamicFactoryTests = class(TTestCase)
  published
    procedure TestInstantiate;
    procedure TestConstructor;
  end;

implementation

uses
  EBFactory, EBDynamicFactory, EBFieldEnumerator, EBInvalidTypeException;

type
  IMyInterface = interface
    ['{AE8806A6-19F2-45CE-A3F4-824FDC867E80}']
    function GetTestValue: Integer;
  end;

  IOtherInterface = interface
    ['{76B36C42-4F4D-4515-8F4E-D37BA30E3A04}']
  end;

  TMyClass = class(TInterfacedObject, IMyInterface)
  private
    FTestValue: Integer;
    function GetTestValue: Integer;
  public
    constructor Create;
  end;

  TSomeObject = class
  private
    FMyInterface: IMyInterface;
    FOtherInterface: IOtherInterface;
  end;

{ TDynamicFactoryTests }

procedure TDynamicFactoryTests.TestConstructor;
var
  Factory: IFactory;
begin
  try
    Factory := TDynamicFactory.Create(IOtherInterface, TMyClass, @TMyClass.Create);
    Fail('Creating TDynamicFactory with incompatible Guid and Class reference should raise an exception');
  except
    on EInvalidType do CheckTrue(True);
  end;
end;

procedure TDynamicFactoryTests.TestInstantiate;
var
  Factory: IFactory;
  Fields: TFieldsData;
  I: IInterface;
begin
  Fields := EnumerateFields(TSomeObject);
  Factory := TDynamicFactory.Create(IMyInterface, TMyClass, @TMyClass.Create);
  I := Factory.Instantiate(Nil, Fields[0]);
  CheckTrue(Assigned(I));
  CheckEquals(10, (I as IMyInterface).GetTestValue);

  I := Factory.Instantiate(Nil, Fields[1]);
  CheckFalse(Assigned(I));
end;

{ TMyClass }

constructor TMyClass.Create;
begin
  FTestValue := 10;
end;

function TMyClass.GetTestValue: Integer;
begin
  Result := FTestValue;
end;

initialization
RegisterTest(TDynamicFactoryTests.Suite);

end.
