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

unit Emballo.DynamicProxy.Impl;

interface

uses
  Rtti,
  TypInfo,
  Emballo.Interfaces.DynamicInterfaceHelper,
  Emballo.Interfaces.InterfacedObject,
  Emballo.DynamicProxy.InvokationHandler,
  Emballo.DynamicProxy.MethodImpl,
  Emballo.RuntimeCodeGeneration.AsmBlock,
  Emballo.DI.Instantiator,
  Emballo.SynteticClass, classes;

type
  TDynamicProxy = class(TEbInterfacedObject)
  private
    FInvokationHandler: TInvokationHandlerAnonMethod;
    FRttiContext: TRttiContext;
    FSynteticClass: TSynteticClass;
    FParentClassVirtualMethods: TArray<TMethodImpl>;
    FDynamicInterfaceHelper: TDynamicInterfaceHelper;
    FProxyObject: TObject;
    procedure OverrideVirtualMethods(const ParentClass: TClass);
  protected
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; override; stdcall;
  public
    constructor Create(const ParentClass: TClass; ImplementedInterfaces: TArray<PTypeInfo>;
      InvokationHandler: TInvokationHandlerAnonMethod); overload;
    constructor Create(const ParentClass: TClass; ImplementedInterfaces: TArray<PTypeInfo>;
      InvokationHandler: TInvokationHandlerMethod); overload;
    destructor Destroy; override;
    property ProxyObject: TObject read FProxyObject;
  end;

implementation

uses
  SysUtils,
  Emballo.DI.AbstractFactory,
  Emballo.DynamicProxy.InvokationHandler.ParameterImpl,
  Emballo.RuntimeCodeGeneration.CallingConventions;

{ TDynamicProxy }

constructor TDynamicProxy.Create(const ParentClass: TClass;
  ImplementedInterfaces: TArray<PTypeInfo>; InvokationHandler: TInvokationHandlerAnonMethod);
var
  InterfaceType: TRttiInterfaceType;
  Methods: TArray<TRttiMethod>;
  Method: TRttiMethod;
  i: Integer;
  MethodPointers: TArray<Pointer>;
  LParentClass: TClass;
  Instantiator: TInstantiator;
begin
  FRttiContext := TRttiContext.Create;
  FInvokationHandler := InvokationHandler;

  if Assigned(ParentClass) then
    LParentClass := ParentClass
  else
    LParentClass := TObject;


  FSynteticClass := TSynteticClass.Create(LParentClass.ClassName, LParentClass,
    SizeOf(Pointer));
  FSynteticClass.Finalizer := procedure(const Instance: TObject)
  var
    DynamicProxy: TDynamicProxy;
  begin
    DynamicProxy := TObject(GetAditionalData(Instance)^) as TDynamicProxy;
    DynamicProxy.Free;
  end;

  Instantiator := TInstantiator.Create;
  try
    FProxyObject := Instantiator.Instantiate(FSynteticClass.Metaclass);
  finally
    Instantiator.Free;
  end;

  SetAditionalData(FProxyObject, Self);

  OverrideVirtualMethods(ParentClass);

{  InterfaceType := FRttiContext.GetType(InterfaceTypeInfo) as TRttiInterfaceType;

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
    MethodPointers);       }
end;

constructor TDynamicProxy.Create(const ParentClass: TClass;
  ImplementedInterfaces: TArray<PTypeInfo>; InvokationHandler: TInvokationHandlerMethod);
begin
  Create(ParentClass, ImplementedInterfaces, procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter)
  begin
    InvokationHandler(Method, Parameters, Result);
  end);
end;

destructor TDynamicProxy.Destroy;
var
  M: TMethodImpl;
begin
  for M in FParentClassVirtualMethods do
    M.Free;
  FSynteticClass.Free;
  FDynamicInterfaceHelper.Free;
  FRttiContext.Free;
  inherited;
end;

procedure TDynamicProxy.OverrideVirtualMethods(const ParentClass: TClass);
var
  RttiType: TRttiType;
  Methods: TArray<TRttiMethod>;
  Method: TRttiMethod;
  MethodImpl: TMethodImpl;
begin
  RttiType := FRttiContext.GetType(ParentClass);
  Methods := RttiType.GetMethods;
  for Method in Methods do
  begin
    if (Method.Parent as TRttiType).AsInstance.MetaclassType <> TObject then
    begin
      if Method.DispatchKind = dkVtable then
      begin
        SetLength(FParentClassVirtualMethods, Length(FParentClassVirtualMethods) + 1);
        MethodImpl := TMethodImpl.Create(Method, FInvokationHandler);
        FParentClassVirtualMethods[High(FParentClassVirtualMethods)] := MethodImpl;
        FSynteticClass.VirtualMethodAddress[Method.VirtualIndex] := MethodImpl.CodeAddress;
      end;
    end;
  end;
end;

function TDynamicProxy.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  Result := FDynamicInterfaceHelper.QueryInterface(IID, Obj);
end;

end.
