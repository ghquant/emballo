unit EbPoolFactoryTests;

interface

uses
  TestFramework;

type
  TPoolFactoryTests = class(TTestCase)
  published
    procedure TestGetInstance;
  end;

implementation

uses
  EbDelegateFactory, EbFactory, EbPoolFactory;

type
  TDestroyEvent = reference to procedure;
  ITestService = interface
    ['{6E4B865C-91E5-4F6B-BB0C-E3FFB706D531}']
    procedure SetDestroyEvent(Value: TDestroyEvent);
  end;

  TTestService = class(TInterfacedObject, ITestService)
  private
    FDestroyEvent: TDestroyEvent;
    procedure SetDestroyEvent(Value: TDestroyEvent);
  public
    destructor Destroy; override;
  end;

{ TPoolFactoryTests }

procedure TPoolFactoryTests.TestGetInstance;
var
  DelegateFactory: IDelegateFactory;
  PoolFactory: IFactory;
  InvokedFactory: Boolean;
  Instance1, Instance2: ITestService;
begin
  DelegateFactory := TDelegateFactory.Create(ITestService);
  PoolFactory := TPoolFactory.Create(DelegateFactory as IFactory, 1);
  DelegateFactory.SetGetInstance(function: IInterface
  begin
    InvokedFactory := True;
    Result := TTestService.Create;
  end);
  InvokedFactory := False;
  Instance1 := PoolFactory.GetInstance as ITestService;
  CheckTrue(InvokedFactory, 'There were no object on the pool, so it should get from the underlying factory');

  InvokedFactory := False;
  Instance2 := PoolFactory.GetInstance as ITestService;
  CheckTrue(InvokedFactory, 'There were no object on the pool, so it should get from the underlying factory');

  Instance1.SetDestroyEvent(procedure
  begin
    Fail('Object should return to the pool instead of being destroyed');
  end);
  (Instance1 as IInterface)._Release;
  Instance1 := Nil; { It should go to the pool now }

  InvokedFactory := False;
  Instance1 := PoolFactory.GetInstance as ITestService;
  CheckFalse(InvokedFactory, 'There''s one available object on the pool, so the factory must return it');
end;

{ TTestService }

destructor TTestService.Destroy;
begin
  FDestroyEvent;
  inherited;
end;

procedure TTestService.SetDestroyEvent(Value: TDestroyEvent);
begin
  FDestroyEvent := Value;
end;

initialization
RegisterTest(TPoolFactoryTests.Suite);

end.
