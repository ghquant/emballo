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

unit EBFieldEnumeratorTests;

interface

uses
  TestFramework;

type
  TFieldEnumeratorTests = class(TTestCase)
  published
    procedure TestEnumerateFields;
  end;

  TFieldDataTests = class(TTestCase)
  published
    procedure TestInject;
  end;

  ITest = interface
    ['{4E8A2077-C436-4B77-A41E-664C325A51B8}']
  end;

  TSuperClass = class
  private
    FFieldA: Integer;
    FFieldB: String;
    FFieldC: IInterface;
  public
    FFieldD: TObject;
  end;

  TSubClass = class(TSuperClass)
  private
    FFieldC: ITest;
  end;

  TClassWithNoFields = class

  end;

  IInterfaceA = interface
    ['{5E48F360-FE8E-410F-9520-3ED38E99B394}']
    function GetReferenceCount: Integer;
  end;

  IInterfaceB = interface
    ['{3DFF7E7C-F9EA-4E7E-93B8-E0D36B6AF7A0}']
  end;

  TInterfaceA = class(TInterfacedObject, IInterfaceA)
    function GetReferenceCount: Integer;
  end;

  TInterfaceB = class(TInterfacedObject, IInterfaceB)

  end;

  TMyObject = class
  private
    FInterfaceA: IInterfaceA;
  end;

implementation

uses
  EBFieldEnumerator, EBInvalidTypeException, SysUtils;

{ TFieldEnumeratorTests }

procedure TFieldEnumeratorTests.TestEnumerateFields;
var
  Fields: TFieldsData;
begin
  Fields := EnumerateFields(TSubClass);

  CheckEquals(2, Length(Fields), 'There are 2 interface fields declared on TSubClass and it''s parents');
  CheckEquals(GUIDToString(ITest), GUIDToString(Fields[0].GUID));
  CheckEquals(GUIDToString(IInterface), GUIDToString(Fields[1].GUID));

  Fields := EnumerateFields(TClassWithNoFields);
  CheckEquals(0, Length(Fields));
end;

{ TFieldDataTests }

procedure TFieldDataTests.TestInject;
var
  Instance: TMyObject;
  Fields: TFieldsData;
  InterfaceA: IInterfaceA;
  O: TObject;
begin
  Fields := EnumerateFields(TMyObject);

  Instance := TMyObject.Create;
  try
    try
      Fields[0].Inject(Instance, TInterfaceB.Create);
      Fail('Trying to inject an different interface type must raise an exception');
    except
      on EInvalidType do CheckTrue(True);
    end;

    try
      O := TObject.Create;
      try
        InterfaceA := TInterfaceA.Create;
        Fields[0].Inject(O, InterfaceA);
      finally
        O.Free;
      end;

      Fail('Trying to inject into an object no compatible with the class where the field was declared must raise an exception');
    except
      on EInvalidType do CheckTrue(True);
    end;

    InterfaceA := TInterfaceA.Create;
    Fields[0].Inject(Instance, InterfaceA);
    CheckTrue(Instance.FInterfaceA = InterfaceA);
    CheckEquals(2, InterfaceA.GetReferenceCount, 'There must be two references now: One for the variable declared here and one for the injected reference');
  finally
    Instance.Free;
  end;
end;

{ TInterfaceA }

function TInterfaceA.GetReferenceCount: Integer;
begin
  Result := FRefCount;
end;

initialization
RegisterTest(TFieldEnumeratorTests.Suite);
RegisterTest(TFieldDataTests.Suite);

end.
