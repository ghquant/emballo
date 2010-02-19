unit EbDelegateFactory;

interface

uses
  EbAbstractFactory;

type
  TGetInstance = reference to function: IInterface;

  IDelegateFactory = interface
    ['{997E1AFD-9B52-4BF4-85DC-F2A5E8CA693D}']
    procedure SetGetInstance(Value: TGetInstance);
  end;

  TDelegateFactory = class(TAbstractFactory, IDelegateFactory)
  private
    FGetInstance: TGetInstance;
    procedure SetGetInstance(Value: TGetInstance);
  protected
    function GetInstance: IInterface; override;
  end;

implementation

{ TDelegateFactory }

function TDelegateFactory.GetInstance: IInterface;
begin
  Result := FGetInstance;
end;

procedure TDelegateFactory.SetGetInstance(Value: TGetInstance);
begin
  FGetInstance := Value;
end;

end.
