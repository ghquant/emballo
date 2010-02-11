unit EbPreBuiltFactoryTests;

interface

uses
  TestFramework;

type
  TPreBuiltFactoryTests = class(TTestCase)
  published
    procedure TestConstructWithNilInstance;
  end;

implementation

uses
  EbFactory, EbPreBuiltFactory, SysUtils;

{ TPreBuiltFactoryTests }

procedure TPreBuiltFactoryTests.TestConstructWithNilInstance;
var
  Factory: IFactory;
begin
  try
    Factory := TPreBuiltFactory.Create(IInterface, Nil);
    Fail('Instantiating TPreBuiltFactory with instance as Nil must raise an EArgumentException');
  except
    on EArgumentException do CheckTrue(True);
  end;
end;

initialization
RegisterTest(TPreBuiltFactoryTests.Suite);

end.
