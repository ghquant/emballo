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

unit Emballo.DI.PoolFactoryTests;

interface

uses
  TestFramework;

type
  TPoolFactoryTests = class(TTestCase)
  published
    procedure TestGetInstance;
    procedure TestFreeWhenPoolIsFull;
    procedure TestDontFreeWhenReturnToPool;
    procedure TestUseServiceAfterReleasingFactory;
  end;

implementation

uses
  Emballo.DI.DelegateFactory, Emballo.DI.Factory, Emballo.DI.PoolFactory, SysUtils;

type
  TDestroyEvent = reference to procedure;
  ITestService = interface
    ['{6E4B865C-91E5-4F6B-BB0C-E3FFB706D531}']
    procedure SetDestroyEvent(Value: TDestroyEvent);
    function GetRefCount: Integer;
  end;

  TTestService = class(TInterfacedObject, ITestService)
  private
    FDestroyEvent: TDestroyEvent;
    procedure SetDestroyEvent(Value: TDestroyEvent);
    function GetRefCount: Integer;
  public
    destructor Destroy; override;
  end;

{ TPoolFactoryTests }

procedure TPoolFactoryTests.TestGetInstance;
var
  DelegateFactory: IDelegateFactory;
  PoolFactory: IFactory;
  InvokedFactory: Boolean;
  InvokedDestroy: Boolean;
  Instance: IInterface;
begin
  DelegateFactory := TDelegateFactory.Create(ITestService);
  PoolFactory := TPoolFactory.Create(DelegateFactory as IFactory, 1);
  DelegateFactory.SetGetInstance(function: IInterface
  begin
    InvokedFactory := True;
    Result := TTestService.Create;
  end);
  InvokedFactory := False;
  Instance := PoolFactory.GetInstance;
  CheckTrue(InvokedFactory, 'There were no object on the pool, so it should get from the underlying factory');
  Instance := Nil;

  InvokedFactory := False;
  Instance := PoolFactory.GetInstance;
  CheckFalse(InvokedFactory, 'There''s one available object on the pool, so the factory must return it');

  Instance := Nil;
end;

procedure TPoolFactoryTests.TestDontFreeWhenReturnToPool;
var
  DelegateFactory: IDelegateFactory;
  PoolFactory: IFactory;
  Instance: ITestService;
  WeakInstance: Pointer;
begin
  DelegateFactory := TDelegateFactory.Create(ITestService);
  DelegateFactory.SetGetInstance(function: IInterface
  begin
    Result := TTestService.Create;
  end);
  PoolFactory := TPoolFactory.Create(DelegateFactory as IFactory, 1);

  Instance := PoolFactory.GetInstance as ITestService;
  WeakInstance := Pointer(Instance);
  Instance.SetDestroyEvent(procedure
  begin
    Fail('When an interface is released and the pool is not full, the interface must return to the pool and not be freed');
  end);
  Instance := Nil;
  ITestService(WeakInstance).SetDestroyEvent(Nil);
end;

procedure TPoolFactoryTests.TestFreeWhenPoolIsFull;
var
  DelegateFactory: IDelegateFactory;
  PoolFactory: IFactory;
  Instance1: ITestService;
  WeakInstance1: Pointer;
  Instance2: ITestService;
  Destroyed: Boolean;
  Tmp: IInterface;
begin
  DelegateFactory := TDelegateFactory.Create(ITestService);
  PoolFactory := TPoolFactory.Create(DelegateFactory as IFactory, 1);
  DelegateFactory.SetGetInstance(function: IInterface
  begin
    Result := TTestService.Create;
  end);
  Tmp := PoolFactory.GetInstance;
  Supports(Tmp, ITestService, Instance1);
  Tmp := Nil;

  WeakInstance1 := Pointer(Instance1);

  Tmp := PoolFactory.GetInstance;
  Supports(Tmp, ITestService, Instance2);
  Tmp := Nil;

  Instance1.SetDestroyEvent(procedure
  begin
    Destroyed := True;
  end);
  Destroyed := False;

  Instance2 := Nil;
  Instance1 := Nil;
  ITestService(WeakInstance1).SetDestroyEvent(Nil);
  CheckTrue(Destroyed, 'Releasing an interface when the pool is full should make the interface to be Free''d immediately');
end;

procedure TPoolFactoryTests.TestUseServiceAfterReleasingFactory;
var
  DelegateFactory: IDelegateFactory;
  PoolFactory: IFactory;
  Instance: ITestService;
  Tmp: IInterface;
  Destroyed: Boolean;
begin
  DelegateFactory := TDelegateFactory.Create(ITestService);
  PoolFactory := TPoolFactory.Create(DelegateFactory as IFactory, 1);
  DelegateFactory.SetGetInstance(function: IInterface
  begin
    Result := TTestService.Create;
  end);

  { First I get an instance, just to make sure the interface has been
    patched. After I can release it }
  Tmp := PoolFactory.GetInstance;
  Supports(Tmp, IInterface, Instance);
  Tmp := Nil;
  Instance := Nil;

  { Now I release the pool itself }
  PoolFactory := Nil;
  DelegateFactory := Nil;

  Instance := TTestService.Create;
  Instance.SetDestroyEvent(procedure
  begin
    Destroyed := True;
  end);
  Destroyed := False;
  Instance := Nil;

  { If I use Destroyed on the call bellow, it's always passed as False, even
    though when Destroyed is True. Perhaps it's a compiller bug, I don't know,
    but using a pointer it works as expected }
  CheckTrue(Destroyed, 'An object created after the pool being used and released, must work normally');
end;

{ TTestService }

destructor TTestService.Destroy;
begin
  if Assigned(FDestroyEvent) then
    FDestroyEvent;
  inherited;
end;

function TTestService.GetRefCount: Integer;
begin
  Result := FRefCount;
end;

procedure TTestService.SetDestroyEvent(Value: TDestroyEvent);
begin
  FDestroyEvent := Value;
end;

initialization
RegisterTest(TPoolFactoryTests.Suite);

end.
