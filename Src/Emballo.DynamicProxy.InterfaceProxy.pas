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

unit Emballo.DynamicProxy.InterfaceProxy;

interface

uses
  TypInfo,
  Rtti,
  Emballo.Interfaces.DynamicInterfaceHelper,
  Emballo.DynamicProxy.InvokationHandler,
  Emballo.DynamicProxy.MethodImpl,
  Emballo.RuntimeCodeGeneration.AsmBlock;

type
  TInterfaceProxy = class
  private
    FMethods: TArray<TMethodImpl>;
    FInterfaceStubs: TArray<TAsmBlock>;
    FStubsAddresses: array of Pointer;
    FRttiContext: TRttiContext;
    FHelper: TDynamicInterfaceHelper;
    FGuid: TGUID;
    function GetVTable: Pointer;
    procedure GenerateStub(const AsmBlock: TAsmBlock; const CallingConvention: TCallConv;
      const MethodAddress: Pointer; const Offset: Integer);
  public
    property Guid: TGUID read FGuid;
    constructor Create(const Instance: TObject; const AddRef, QueryInterface,
      Release: Pointer; const InterfaceTypeInfo: PTypeInfo;
      const InvokationHandler: TInvokationHandlerAnonMethod; Offset: Integer);
    destructor Destroy; override;
    procedure GetInterface(out Obj);
    property VTable: Pointer read GetVTable;
  end;

implementation

const
  IINTERFACE_METHOD_COUNT = 0; { Looks like Delphi RTTI doesn't consider the IInterface
  methods. If someday it does, then change this const }

{ TInterfaceProxy }

constructor TInterfaceProxy.Create(const Instance: TObject; const AddRef, QueryInterface,
  Release: Pointer; const InterfaceTypeInfo: PTypeInfo;
  const InvokationHandler: TInvokationHandlerAnonMethod; Offset: Integer);
var
  RttiType: TRttiType;
  i: Integer;
  Methods: TArray<TRttiMethod>;
  MethodAddresses: array of Pointer;
begin
  FRttiContext := TRttiContext.Create;
  RttiType := FRttiContext.GetType(InterfaceTypeInfo);
  FGuid := (RttiType as TRttiInterfaceType).GUID;
  Methods := RttiType.GetMethods;
  SetLength(FMethods, Length(Methods) - IINTERFACE_METHOD_COUNT);
  SetLength(MethodAddresses, Length(FMethods));

  for i := 0 to Length(Methods) - IINTERFACE_METHOD_COUNT - 1 do
    FMethods[i] := TMethodImpl.Create(FRttiContext, Methods[i], InvokationHandler);

  SetLength(FInterfaceStubs, Length(Methods) + 3);
  SetLength(FStubsAddresses, Length(FInterfaceStubs));
  for i := 0 to High(FInterfaceStubs) do
  begin
    FInterfaceStubs[i] := TAsmBlock.Create;
    case i of
      0: GenerateStub(FInterfaceStubs[i], ccStdCall, QueryInterface, Offset);
      1: GenerateStub(FInterfaceStubs[i], ccStdCall, AddRef, Offset);
      2: GenerateStub(FInterfaceStubs[i], ccStdCall, Release, Offset);
      else
      begin
        GenerateStub(FInterfaceStubs[i], Methods[i - 3].CallingConvention,
          FMethods[i - 3].CodeAddress, Offset);
      end;
    end;
    FInterfaceStubs[i].Compile;
    FStubsAddresses[i] := FInterfaceStubs[i].Block;
  end;
end;

destructor TInterfaceProxy.Destroy;
var
  i: Integer;
begin
  for i := 0 to High(FInterfaceStubs) do
    FInterfaceStubs[i].Free;

  for i := 0 to High(FMethods) do
    FMethods[i].Free;

  FRttiContext.Free;
  inherited;
end;

procedure TInterfaceProxy.GenerateStub(const AsmBlock: TAsmBlock;
  const CallingConvention: TCallConv; const MethodAddress: Pointer; const Offset: Integer);
begin
  if CallingConvention = ccReg then
  begin
    { add eax, -Offset }
    AsmBlock.PutB([$83, $C0, Byte(-Offset)]);
  end
  else
  begin
    { add dword ptr [esp+$04], -Offset }
    AsmBlock.PutB([$83, $44, $24, $04, Byte(-Offset)]);
  end;
  AsmBlock.GenJmp(MethodAddress);
end;

procedure TInterfaceProxy.GetInterface(out Obj);
begin
  FHelper.QueryInterface(FGuid, Obj);
end;

function TInterfaceProxy.GetVTable: Pointer;
begin
  Result := @FStubsAddresses[0];
end;

end.
