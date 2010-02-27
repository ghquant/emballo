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

unit EbRegisterImplTests;

interface

uses
  TestFramework, EbFactory, Generics.Collections;

type
  TRegisterTests = class(TTestCase)
  private
    FRegistry: TList<IFactory>;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestDone;
  end;

implementation

uses
  EbRegister, EbRegisterImpl, EbStubFactory;

{ TRegisterTests }

procedure TRegisterTests.SetUp;
begin
  inherited;
  FRegistry := TList<IFactory>.Create;
end;

procedure TRegisterTests.TearDown;
begin
  inherited;
  FRegistry.Free;
end;

procedure TRegisterTests.TestDone;
var
  Factory: IFactory;
  LRegister: IRegister;
begin
  Factory := TStubFactory.Create;
  LRegister := TRegister.Create(Factory, FRegistry);
  LRegister.Done;
  CheckEquals(1, FRegistry.Count);
  CheckTrue(Factory = FRegistry[0]);
end;

initialization
RegisterTest(TRegisterTests.Suite);

end.
