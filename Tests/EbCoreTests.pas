{   Copyright 2010 - Magno Machado Paulo (magnomp@gmail.com)

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

unit EbCoreTests;

interface

uses
  TestFramework;

type
  TEbCoreTests = class(TTestCase)
  protected
    procedure TearDown; override;
  published
    procedure TestHiddenInjection;
    procedure TestBuildInstance;
  end;

  IDependency = interface
    ['{4E6BF186-C440-43D8-A7BA-DF50A54A1ACD}']
    function GetId: Integer;
    procedure SetId(Value: Integer);
  end;

  INotRegisteredInterface = interface
    ['{5AE8F8FE-AE96-4250-B901-884F647EC48B}']
  end;

  TDependency = class(TInterfacedObject, IDependency)
  private
    FId: Integer;
    function GetId: Integer;
    procedure SetId(Value: Integer);
  end;

  TClient = class
    FDependency: IDependency;
  end;

  TClientWithTwoDependencies = class
    FDependency1, FDependency2: IDependency;
  end;

var
  Info: Pointer;

implementation

uses
  EbRegistry, EbCore;

{ TEbCoreTests }

procedure TEbCoreTests.TearDown;
begin
  inherited;
  ClearRegistry;
end;

procedure TEbCoreTests.TestBuildInstance;
var
  Instance: INotRegisteredInterface;
begin
  { 1. Test if it raises an exception if the instance can't be built }
  try
    Instance := BuildInstance(INotRegisteredInterface) as INotRegisteredInterface;
    Fail('Calling BuildInstance for an interface that can''t be instantiated must raise an ECouldNotBuild');
  except
    on ECouldNotBuild do CheckTrue(True);
  end;
end;

procedure TEbCoreTests.TestHiddenInjection;
var
  Cli: TClient;
  Cli2: TClientWithTwoDependencies;
begin
  { 1. Test if only fields set to nil are touched }
  RegisterFactory(IDependency, TDependency);
  Cli := TClient.Create;
  Cli.FDependency := TDependency.Create;
  Cli.FDependency.SetId(1);
  HiddenInjection(Cli);
  CheckEquals(1, Cli.FDependency.GetId, 'InjectDependencies should preserve field values when the fields are already set');

  { 2. Test if all available fields are injected }
  Cli2 := TClientWithTwoDependencies.Create;
  HiddenInjection(Cli2);
  CheckNotNull(Cli2.FDependency1, 'InjectDependencies must inject into all injectable fields');
  CheckNotNull(Cli2.FDependency2, 'InjectDependencies must inject into all injectable fields');
end;

{ TDependency }

function TDependency.GetId: Integer;
begin
  Result := FId;
end;

procedure TDependency.SetId(Value: Integer);
begin
  FId := Value;
end;

initialization
Info := TypeInfo(INotRegisteredInterface);
RegisterTest(TEbCoreTests.Suite);

end.
