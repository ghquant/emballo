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

unit Emballo.DI.CoreTests;

interface

uses
  TestFramework;

type
  TEmballoTests = class(TTestCase)
  published
    procedure TestGet;
  end;

  INotRegisteredInterface = interface
    ['{5AE8F8FE-AE96-4250-B901-884F647EC48B}']
  end;

var
  Info: Pointer;

implementation

uses
  Emballo.DI.Registry, Emballo.DI.Core, SysUtils;

{ TEmballoTests }

procedure TEmballoTests.TestGet;
begin
  { 1. Test if an exception is raised if we call Emballo.Get with a non interface type }
  try
    Emballo.DI.Core.Emballo.Get<TObject>;
    Fail('Calling Emballo.Get with a type other than an interface type must raise a EArgumentException');
  except
    on EArgumentException do CheckTrue(True);
  end;

  { 2. Test if it raises an exception if the instance can't be built }
  try
    Emballo.DI.Core.Emballo.Get<INotRegisteredInterface>;
    Fail('Calling BuildInstance for an interface that can''t be instantiated must raise an ECouldNotBuild');
  except
    on ECouldNotBuild do CheckTrue(True);
  end;
end;

initialization
Info := TypeInfo(INotRegisteredInterface);
RegisterTest(TEmballoTests.Suite);

end.
