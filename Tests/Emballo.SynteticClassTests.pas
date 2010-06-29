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

unit Emballo.SynteticClassTests;

interface

uses
  TestFramework;

type
  TBaseClass = class

  end;

  TSynteticClassTests = class(TTestCase)
  published
    procedure FinalizerShouldBeCalledWhenFreeIsCalled;
  end;

implementation

uses
  Emballo.SynteticClass;

{ TSynteticClassTests }

procedure TSynteticClassTests.FinalizerShouldBeCalledWhenFreeIsCalled;
var
  SynteticClass: TSynteticClass;
  CalledFinalizer: Boolean;
  Instance: TObject;
begin
  SynteticClass := TSynteticClass.Create('TSynteticSubClass', TBaseClass, 0);
  try
    SynteticClass.Finalizer := procedure(const Instance: TObject)
    begin
      CalledFinalizer := True;
    end;

    CalledFinalizer := False;

    Instance := SynteticClass.Metaclass.Create;
    Instance.Free;

    CheckTrue(CalledFinalizer, 'Finalizer should be called when an instance is Free''d');
  finally
    SynteticClass.Free;
  end;
end;

initialization
RegisterTest('Emballo', TSynteticClassTests.Suite);

end.
