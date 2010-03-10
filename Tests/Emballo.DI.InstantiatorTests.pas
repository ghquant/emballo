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

unit Emballo.DI.InstantiatorTests;

interface

uses
  TestFramework, Emballo.DI.Instantiator;

type
  TInstantiatorHack = class(TInstantiator)
  end;

  TInstantiatorTests = class(TTestCase)
  private
    FInstantiator: TInstantiatorHack;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestEnumConstructors;
    procedure TestInstantiate;
  end;

implementation

uses
  Rtti;

type
  TTestClassA = class
  public
    constructor OneConstructorFromA;
    constructor AnotherConstructorFromA;
  end;

  TTestClassB = class(TTestClassA)
  end;

  TTestClassWithNoSuitableConstructor = class
  public
    FA: Integer;
    constructor Create(A: Integer);
  end;

{ TInstantiatorTests }

procedure TInstantiatorTests.SetUp;
begin
  inherited;
  FInstantiator := TInstantiatorHack.Create;
end;

procedure TInstantiatorTests.TearDown;
begin
  inherited;
  FInstantiator.Free;
end;

procedure TInstantiatorTests.TestEnumConstructors;
  function ConstructorExists(const Name: String;
    Constructors: TArray<TRttiMethod>): Boolean;
  var
    Ctor: TRttiMethod;
  begin
    Result := False;
    for Ctor in Constructors do
    begin
      Result := Ctor.Name = Name;
      if Result then
        Exit;
    end;
  end;
var
  Constructors: TArray<TRttiMethod>;
begin
  Constructors := FInstantiator.EnumConstructors(TTestClassB);
  CheckEquals(2, Length(Constructors));
  CheckTrue(ConstructorExists('OneConstructorFromA', Constructors));
  CheckTrue(ConstructorExists('AnotherConstructorFromA', Constructors));
end;

procedure TInstantiatorTests.TestInstantiate;
begin
  try
    FInstantiator.Instantiate(TTestClassWithNoSuitableConstructor);
    Fail('Instantiating a class with no suitable constructor should raise an ENoSuitableConstructor');
  except
    on ENoSuitableConstructor do CheckTrue(True);
  end;
end;

{ TTestClassA }

constructor TTestClassA.AnotherConstructorFromA;
begin

end;

constructor TTestClassA.OneConstructorFromA;
begin

end;

{ TTestClassWithNoSuitableConstructor }

constructor TTestClassWithNoSuitableConstructor.Create(A: Integer);
begin
  FA := A;
end;

initialization
RegisterTest(TInstantiatorTests.Suite);

end.
