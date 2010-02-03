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

unit EbRegistry;

interface

uses
  EbFactory, EbSingletonFactory, EbUtil;

type
  { The way the framework will manage instances of each interface }
  TLifeCycleManagement = (lcNone, { No special treatment }
                          lcSingleton { Instances get cached, so that the
                                        framework will always return the same
                                        instance}
                         , teste);

{ Register a generic factory }
procedure RegisterFactory(const Factory: IFactory;
  LifeCycleManagement: TLifeCycleManagement = lcNone); overload;

{ Register a factory that will always return a new instance of the class
  specified by the "Implementor" argument when an instance of interface
  specified by "GUID" parameter is requested }
procedure RegisterFactory(const GUID: TGUID; Implementor: TClass;
  LifeCycleManagement: TLifeCycleManagement = lcNone); overload;

{ Register a factory that will always return the object referenced by the
  "Instance" parameter when an instance of the interface specified by "GUID"
  parameter is requested }
procedure RegisterFactory(const GUID: TGUID; const Instance: IInterface); overload;

{ Tries to get an instance of the interface specified by the "GUID" parameter.
  if it succeds, the instance is put on the "Instance" parameter, and the
  function returns True. Otherwise, it returns False.
  This function tries to get the instance within all of the already registered
  factories }
function TryBuild(GUID: TGUID; out Instance: IInterface): Boolean;

{ Removes all of the already registered factories }
procedure ClearRegistry;

implementation

uses
  Generics.Collections, EbDynamicFactory, EbPreBuiltFactory, SysUtils;

var
  Factories: TList<IFactory>;

procedure RegisterFactory(const Factory: IFactory;
  LifeCycleManagement: TLifeCycleManagement);
var
  NewFactory: IFactory;
begin
  case LifeCycleManagement of
    lcNone: NewFactory := Factory;
    lcSingleton: NewFactory := TSingletonFactory.Create(Factory);
    else NotCoveredEnumValue(TypeInfo(TLifeCycleManagement), Ord(LifeCycleManagement));
  end;

  Factories.Add(NewFactory);
end;

procedure RegisterFactory(const GUID: TGUID; Implementor: TClass;
  LifeCycleManagement: TLifeCycleManagement);
begin
  RegisterFactory(TDynamicFactory.Create(GUID, Implementor), LifeCycleManagement);
end;

procedure RegisterFactory(const GUID: TGUID; const Instance: IInterface); overload;
begin
  RegisterFactory(TPreBuiltFactory.Create(GUID, Instance), lcNone);
end;

function TryBuild(GUID: TGUID; out Instance: IInterface): Boolean;
var
  Factory: IFactory;
begin
  for Factory in Factories do
  begin
    if IsEqualGUID(GUID, Factory.GUID) then
    begin
      Instance := Factory.GetInstance;
      Exit(True);
    end;
  end;
  Result := False;
end;

procedure ClearRegistry;
begin
  Factories.Clear;
end;

initialization
Factories := TList<IFactory>.Create;

finalization
Factories.Free;

end.
