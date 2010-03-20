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

unit Emballo.DllWrapper.ImplTests;

interface

uses
  TestFramework;

type
  {$M+}
  IDllWrapperTest = interface
    ['{11C5E6A9-597F-40DF-9BB1-9374C6139B86}']
    function TestA(A: Byte; B: Integer; C: Extended): Extended; stdcall;
  end;
  {$M-}

  TDllWrapperTests = class(TTestCase)
  private
    FDll: IDllWrapperTest;
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestA;
  end;

implementation

uses Emballo.DllWrapper.Impl;

{ TDllWrapperTests }

procedure TDllWrapperTests.SetUp;
begin
  inherited;
  FDll := TDllWrapper.Create(TypeInfo(IDllWrapperTest), 'DllWrapperTest.dll') as
    IDllWrapperTest;
end;

procedure TDllWrapperTests.TearDown;
begin
  inherited;
  FDll := Nil;
end;

procedure TDllWrapperTests.TestA;
begin
  CheckEquals(1246913668.123, FDll.TestA(100, 12345678, 1234567890.123), 0.0001);
end;

initialization
RegisterTest('Emballo.DllWrapper.Impl', TDllWrapperTests.Suite);

end.
