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

unit EBTestCase;

interface

uses
  TestFramework;

type
  { A base test case for testing classes that deppends on Emballo features.
    It'll clear the DIRegistry before and after your test runs. It also provides
    a shortcut for registering mocks on the registry }
  TEmballoTestCase = class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
    procedure RegisterFactory(Guid: TGUID; Instance: IInterface);
  end;

implementation

uses
  EBDIRegistry;

{ TEmballoTestCase }

procedure TEmballoTestCase.RegisterFactory(Guid: TGUID; Instance: IInterface);
begin
  GetDIRegistry.RegisterFactory(Guid, Instance);
end;

procedure TEmballoTestCase.SetUp;
begin
  inherited;
  GetDIRegistry.Clear;
end;

procedure TEmballoTestCase.TearDown;
begin
  inherited;
  GetDIRegistry.Clear;
end;

end.
