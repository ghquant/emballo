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
  Emballo.Interfaces.InterfacedObject,
  Emballo.DynamicProxy.InterfaceProxy,
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
    FProxyObject: TObject;
    FSupportedInterfaces: TArray<TInterfaceProxy>;
    FNewDestroy: TAsmBlock;
    FOriginalDestroy: Pointer;
    procedure NewDestroy(Instance: TObject; Outermost: SmallInt);
    procedure GenerateNewDestroy;
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
  Emballo.RuntimeCodeGeneration.CallingConventions,
  Emballo.Rtti;

type
  TInterfacedObjectHack = class(TInterfacedObject)

  end;

{ TDynamicProxy }

constructor TDynamicProxy.Create(const ParentClass: TClass;
  ImplementedInterfaces: TArray<PTypeInfo>; InvokationHandler: TInvokationHandlerAnonMethod);
var
  i: Integer;
  LParentClass: TClass;
  Instantiator: TInstantiator;
  ImplementedInterfacesGuids: TArray<TGUID>;
  IOffset: Integer;
  VTable: Pointer;
  MethodDestroy: TRttiMethod;
begin
  FRttiContext := TRttiContext.Create;
  FInvokationHandler := InvokationHandler;

  if Assigned(ParentClass) then
    LParentClass := ParentClass
  else if Length(ImplementedInterfaces) = 0 then
    LParentClass := TObject
  else
    LParentClass := TInterfacedObject;

  SetLength(ImplementedInterfacesGuids, Length(ImplementedInterfaces));
  for i := 0 to High(ImplementedInterfaces) do
    ImplementedInterfacesGuids[i] := GetGuidFromTypeInfo(ImplementedInterfaces[i]);


  FSynteticClass := TSynteticClass.Create(LParentClass.ClassName, LParentClass,
    SizeOf(Pointer), ImplementedInterfacesGuids, True);

  Instantiator := TInstantiator.Create;
  try
    FProxyObject := Instantiator.Instantiate(FSynteticClass.Metaclass);
  finally
    Instantiator.Free;
  end;

  SetAditionalData(FProxyObject, Self);

  OverrideVirtualMethods(LParentClass);

  MethodDestroy := FRttiContext.GetType(LParentClass).GetMethod('Destroy');
  FOriginalDestroy := FSynteticClass.VirtualMethodAddress[MethodDestroy.VirtualIndex];

  GenerateNewDestroy;

  FSynteticClass.VirtualMethodAddress[MethodDestroy.VirtualIndex] := FNewDestroy.Block;

  SetLength(FSupportedInterfaces, Length(ImplementedInterfaces));
  for i := 0 to High(ImplementedInterfaces) do
  begin
    IOffset := FSynteticClass.Metaclass.GetInterfaceTable.Entries[i].IOffset;

    FSupportedInterfaces[i] := TInterfaceProxy.Create(FProxyObject, @TInterfacedObjectHack._AddRef,
      @TInterfacedObjectHack.QueryInterface, @TInterfacedObjectHack._Release, ImplementedInterfaces[i],
      InvokationHandler, IOffset);

    FSynteticClass.Metaclass.GetInterfaceTable.Entries[i].VTable := FSupportedInterfaces[i].VTable;

    VTable := FSynteticClass.Metaclass.GetInterfaceTable.Entries[i].VTable;

    Move(VTable, Pointer(Integer(FProxyObject) + IOffset)^, SizeOf(Integer));
  end;
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
  P: TInterfaceProxy;
begin
  for M in FParentClassVirtualMethods do
    M.Free;

  for P in FSupportedInterfaces do
    P.Free;

  FNewDestroy.Free;

  FRttiContext.Free;
  inherited;
end;

procedure TDynamicProxy.GenerateNewDestroy;
begin
  FNewDestroy := TAsmBlock.Create;

  { mov ecx, edx }
  FNewDestroy.PutB([$8B, $CA]);

  { mov edx, Self }
  FNewDestroy.PutB($BA); FNewDestroy.PutI(Integer(Self));

  { xchg eax, edx }
  FNewDestroy.PutB($92);

  FNewDestroy.GenJmp(@TDynamicProxy.NewDestroy);

  FNewDestroy.Compile;
end;

procedure TDynamicProxy.NewDestroy(Instance: TObject; Outermost: SmallInt);
var
  Original: procedure(Outermost: Smallint) of object;
begin
  TMethod(Original).Code := FOriginalDestroy;
  TMethod(Original).Data := Instance;
  Original(Outermost);

  Free;
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
        MethodImpl := TMethodImpl.Create(FRttiContext, Method, FInvokationHandler);
        FParentClassVirtualMethods[High(FParentClassVirtualMethods)] := MethodImpl;
        FSynteticClass.VirtualMethodAddress[Method.VirtualIndex] := MethodImpl.CodeAddress;
      end;
    end;
  end;
end;

function TDynamicProxy.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

end.
