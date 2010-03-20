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

unit Emballo.Interfaces.Proxy.Impl;

interface

uses
  Rtti,
  TypInfo,
  Emballo.Interfaces.DynamicInterfaceHelper,
  Emballo.Interfaces.InterfacedObject,
  Emballo.Interfaces.Proxy.InvokationHandler,
  Emballo.RuntimeCodeGeneration.AsmBlock;

type
  { Instances of TMethodStub are responsible for maintaining the runtime
    generated implementation of a specific method of the proxied interface.
    The generated implementation must gather the parameters on the
    registers and/or stack, set up the IParameters and call the invokation
    handler }
  TMethodStub = class abstract
  strict private
    FStub: TAsmBlock;
    function GetCode: Pointer;
  strict protected
    FMethod: TRttiMethod;
    FInvokationHandler: TInvokationHandler;
    procedure GenerateStub(Stub: TAsmBlock); virtual; abstract;
    procedure InternalInvokeWrapper(BaseParamStackAddress: Pointer); virtual; abstract;
    procedure InvokeWrapper(BaseParamStackAddress: Pointer);
  public
    constructor Create(Method: TRttiMethod; InvokationHandler: TInvokationHandler);
    destructor Destroy; override;
    property Code: Pointer read GetCode;
  end;
  TMethodStubClass = class of TMethodStub;

  TStdCallMethodStub = class(TMethodStub)
  strict private
    function GetParametersStackSize: TArray<Integer>;
  strict protected
    procedure GenerateStub(Stub: TAsmBlock); override;
    procedure InternalInvokeWrapper(BaseParamStackAddress: Pointer); override;
  end;

  TInterfaceProxy = class(TEbInterfacedObject)
  private
    FInvokationHandler: TInvokationHandler;
    FRttiContext: TRttiContext;

    FDynamicInterfaceHelper: TDynamicInterfaceHelper;

    FMethodStubs: array of TMethodStub;
  protected
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; override; stdcall;
  public
    constructor Create(InterfaceTypeInfo: PTypeInfo; InvokationHandler: TInvokationHandler);
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils,
  Emballo.DI.AbstractFactory,
  Emballo.Interfaces.Proxy.InvokationHandler.ParameterImpl,
  Emballo.RuntimeCodeGeneration.CallingConventions;

{ TInterfaceProxy }

constructor TInterfaceProxy.Create(InterfaceTypeInfo: PTypeInfo;
  InvokationHandler: TInvokationHandler);
var
  InterfaceType: TRttiInterfaceType;
  Methods: TArray<TRttiMethod>;
  Method: TRttiMethod;
  i: Integer;
  MethodPointers: TArray<Pointer>;
begin
  FRttiContext := TRttiContext.Create;
  FInvokationHandler := InvokationHandler;

  InterfaceType := FRttiContext.GetType(InterfaceTypeInfo) as TRttiInterfaceType;

  Methods := InterfaceType.GetMethods;
  SetLength(MethodPointers, Length(Methods));
  SetLength(FMethodStubs, Length(Methods));
  for i := 0 to High(Methods) do
  begin
    Method := Methods[i];

    FMethodStubs[i] := TStdCallMethodStub.Create(Method, FInvokationHandler);

    MethodPointers[i] := FMethodStubs[i].Code;
  end;

  FDynamicInterfaceHelper := TDynamicInterfaceHelper.Create(
    InterfaceType.GUID,
    @TEbInterfacedObject.QueryInterface,
    @TEbInterfacedObject._AddRef,
    @TEbInterfacedObject._Release,
    Self,
    MethodPointers);
end;

destructor TInterfaceProxy.Destroy;
var
  i: Integer;
begin
  FDynamicInterfaceHelper.Free;
  for i := 0 to High(FMethodStubs) do
    FMethodStubs[i].Free;

  FRttiContext.Free;
  inherited;
end;

function TInterfaceProxy.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  Result := FDynamicInterfaceHelper.QueryInterface(IID, Obj);
end;

{ TMethodStub }

constructor TMethodStub.Create(Method: TRttiMethod; InvokationHandler: TInvokationHandler);
begin
  FMethod := Method;
  FInvokationHandler := InvokationHandler;
  FStub := TAsmBlock.Create;
  GenerateStub(FStub);
  FStub.Compile;
end;

destructor TMethodStub.Destroy;
begin
  FStub.Free;
  inherited;
end;

function TMethodStub.GetCode: Pointer;
begin
  Result := FStub.Block;
end;

procedure TMethodStub.InvokeWrapper(BaseParamStackAddress: Pointer);
begin
  InternalInvokeWrapper(BaseParamStackAddress);
end;

{ TStdCallMethodStub }

procedure TStdCallMethodStub.GenerateStub(Stub: TAsmBlock);
var
  ParamSizes: TArray<Integer>;
  TotalParamSize: Integer;
  ParamSize: Integer;
begin
  TotalParamSize := 0;
  ParamSizes := GetParametersStackSize;
  for ParamSize in ParamSizes do
    Inc(TotalParamSize, ParamSize);

  { mov eax, <MethodWrapper instance data> }
  Stub.PutB($B8); Stub.PutI(Integer(Self));

  { lea edx, [esp+$08] }
  Stub.PutB($8D); Stub.PutB($54); Stub.PutB($24); Stub.PutB($08);

  { call TMethodWrapper.Invoke }
  Stub.GenCall(@TMethodStub.InvokeWrapper);

  { ret <Size of all parameters> }
  Stub.GenRet(TotalParamSize + SizeOf(Pointer));
end;

function TStdCallMethodStub.GetParametersStackSize: TArray<Integer>;
var
  i: Integer;
  CallingConvention: ICallingConvention;
begin
  SetLength(Result, Length(FMethod.GetParameters));
  for i := 0 to High(Result) do
  begin
    CallingConvention := GetCallingConvention(ccStdCall);
    Result[i] := CallingConvention.NumBytesForPassingParameterOnTheStack(FMethod.GetParameters[i]);
  end;
end;

procedure TStdCallMethodStub.InternalInvokeWrapper(
  BaseParamStackAddress: Pointer);
var
  Parameters: TArray<IParameter>;
  ParametersStackSize: TArray<Integer>;
  i: Integer;
  CallingConvention: ICallingConvention;
begin
  CallingConvention := GetCallingConvention(ccStdCall);

  ParametersStackSize := GetParametersStackSize;

  SetLength(Parameters, Length(FMethod.GetParameters));
  for i := 0 to High(Parameters) do
  begin
    Parameters[i] := TParameter.Create(BaseParamStackAddress,
                                       CallingConvention.ParameterPassingStrategy(FMethod.GetParameters[i]) = ppByValue,
                                       FMethod.GetParameters[i].ParamType.TypeKind);
    BaseParamStackAddress := Pointer(Integer(BaseParamStackAddress) + ParametersStackSize[i]);
  end;

  FInvokationHandler(FMethod, Parameters, Nil);
end;

end.
