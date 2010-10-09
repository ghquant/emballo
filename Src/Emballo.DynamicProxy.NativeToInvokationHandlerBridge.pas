unit Emballo.DynamicProxy.NativeToInvokationHandlerBridge;

interface

uses
  Emballo.DynamicProxy.InvokationHandler;

type
  TNativeToInvokationHandlerBridge = class abstract
  private
    FInvokationhandler: TInvokationHandlerAnonMethod;

    procedure CallInvokationHandler(const ParamsBaseStackAddress: Pointer; Eax,
      Edx, Ecx, ResultValue: Pointer);
  end;

implementation

{ TNativeToInvokationHandlerBridge }

procedure TNativeToInvokationHandlerBridge.CallInvokationHandler(
  const ParamsBaseStackAddress: Pointer; Eax, Edx, Ecx, ResultValue: Pointer);
begin

end;

end.
