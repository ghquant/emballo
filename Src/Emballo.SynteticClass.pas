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

unit Emballo.SynteticClass;

interface

uses
  Emballo.RuntimeCodeGeneration.AsmBlock;

type
  TInstanceFinalizer = reference to procedure(const Instance: TObject);

  PClass = ^TClass;
  PSafeCallException = function  (Self: TObject; ExceptObject:
    TObject; ExceptAddr: Pointer): HResult;
  PAfterConstruction = procedure (Self: TObject);
  PBeforeDestruction = procedure (Self: TObject);
  PDispatch          = procedure (Self: TObject; var Message);
  PDefaultHandler    = procedure (Self: TObject; var Message);
  PNewInstance       = function  (Self: TClass) : TObject;
  PFreeInstance      = procedure (Self: TObject);
  TDestroy           = procedure (OuterMost: ShortInt) of object;
  TObjectVirtualMethods = packed record
    A, B, C: Pointer;
    SafeCallException : Pointer;
    AfterConstruction : Pointer;
    BeforeDestruction : Pointer;
    Dispatch          : Pointer;
    DefaultHandler    : Pointer;
    NewInstance       : Pointer;
    FreeInstance      : Pointer;
    Destroy           : Pointer;
  end;
  PClassRec = ^TClassRec;
  TClassRec = packed record
    SelfPtr           : TClass;
    IntfTable         : PInterfaceTable;
    AutoTable         : Pointer;
    InitTable         : Pointer;
    TypeInfo          : Pointer;
    FieldTable        : Pointer;
    MethodTable       : Pointer;
    DynamicTable      : Pointer;
    ClassName         : PShortString;
    InstanceSize      : Longint;
    Parent            : PClass;
    DefaultVirtualMethods: TObjectVirtualMethods;
  end;

  TSynteticClassRec = packed record
    AdicionalInstanceSize: Integer;
    ClassRec: TClassRec;
  end;
  PSynteticClassRec = ^TSynteticClassRec;

  TVmtEntry = record
    Index: Integer;
    Address: Pointer;
  end;

  { Manages a runtime-generated metaclass }
  TSynteticClass = class
  private
    FClassName: ShortString;
    FClassRec: PSynteticClassRec;
    FFinalizer: TInstanceFinalizer;
    FOldDestroy: Pointer;
    FNewDestroy: TAsmBlock;
    FFreeOnInstanceDestroy: Boolean;
    function GetMetaclass: TClass;
    function GetVirtualMethodAddress(const Index: Integer): Pointer;
    procedure SetVirtualMethodAddress(const Index: Integer; const Value: Pointer);
    function EnumerateVirtualMethods(const ParentClass: TClass): TArray<TVmtEntry>;
    procedure CreateNewDestroy;
    procedure NewDestroy(Instance: TObject; OuterMost: ShortInt);
  public
    constructor Create(const ClassName: ShortString; const Parent: TClass;
      const AditionalInstanceSize: Integer; const ImplementedInterfaces: TArray<TGUID>;
      const FreeOnInstanceDestroy: Boolean);
    destructor Destroy; override;

    { Returns the new metaclass }
    property Metaclass: TClass read GetMetaclass;

    property VirtualMethodAddress[const Index: Integer]: Pointer read
      GetVirtualMethodAddress write SetVirtualMethodAddress;

    property Finalizer: TInstanceFinalizer read FFinalizer write FFinalizer;
  end;

function GetAditionalData(const Instance: TObject): Pointer;
procedure SetAditionalData(const Instance: TObject; const Data);

implementation

uses
  Rtti, TypInfo, Generics.Defaults, Generics.Collections;

function GetAditionalInstanceSize(const SynteticClass: TClass): Integer;
var
  SynteticClassRec: PSynteticClassRec;
begin
  SynteticClassRec := PSynteticClassRec(Pointer(Integer(SynteticClass) - SizeOf(TSynteticClassRec)));

  Result := SynteticClassRec.AdicionalInstanceSize;
end;

function GetAditionalData(const Instance: TObject): Pointer;
var
  Address: Integer;
begin
  Address := Integer(Instance);
  Address := Address + Instance.InstanceSize;

  { RTL considers an implicit TMonitor field as the last field on the object }
  Address := Address - SizeOf(Pointer);

  Address := Address - GetAditionalInstanceSize(Instance.ClassType);

  { Take into account a pointer to each implemented interface }
  if Instance.ClassType.GetInterfaceTable <> Nil then
    Address := Address - Instance.ClassType.GetInterfaceTable.EntryCount*SizeOf(Pointer);


  Result := Pointer(Address);
end;

procedure SetAditionalData(const Instance: TObject; const Data);
begin
  Move(Data, GetAditionalData(Instance)^, GetAditionalInstanceSize(Instance.ClassType));
end;

{ TSynteticClass }

constructor TSynteticClass.Create(const ClassName: ShortString; const Parent: TClass;
  const AditionalInstanceSize: Integer; const ImplementedInterfaces: TArray<TGUID>;
  const FreeOnInstanceDestroy: Boolean);
var
  ParentClassRec: PClassRec;
  VmtEntries: TArray<TVmtEntry>;
  NumVmtEntries: Integer;
  i: Integer;
begin
  FFreeOnInstanceDestroy := FreeOnInstanceDestroy;
  VmtEntries := EnumerateVirtualMethods(Parent);
  NumVmtEntries := VmtEntries[High(VmtEntries)].Index + 1;

  ParentClassRec := PClassRec(Parent);
  Dec(ParentClassRec);

  FClassName := ClassName;

  GetMem(FClassRec, SizeOf(TSynteticClassRec) + NumVmtEntries*SizeOf(Pointer));

  FClassRec.AdicionalInstanceSize := AditionalInstanceSize;

  Move(ParentClassRec^, FClassRec.ClassRec, SizeOf(TClassRec));
  GetMem(FClassRec.ClassRec.Parent, SizeOf(Pointer));
  FClassRec.ClassRec.ClassName := @FClassName;
  FClassRec.ClassRec.InstanceSize := Parent.InstanceSize + AditionalInstanceSize +
    Length(ImplementedInterfaces)*SizeOf(Pointer);
  Pointer(FClassRec.ClassRec.Parent^) := Parent;

  FOldDestroy := FClassRec.ClassRec.DefaultVirtualMethods.Destroy;
  CreateNewDestroy;
  FClassRec.ClassRec.DefaultVirtualMethods.Destroy := FNewDestroy.Block;

  if Length(ImplementedInterfaces) > 0 then
  begin
    GetMem(FClassRec.ClassRec.IntfTable, SizeOf(Integer) + Length(ImplementedInterfaces)*SizeOf(TInterfaceEntry));
    FClassRec.ClassRec.IntfTable.EntryCount := Length(ImplementedInterfaces);
    for i := 0 to High(ImplementedInterfaces) do
    begin
      FClassRec.ClassRec.IntfTable.Entries[i].IID := ImplementedInterfaces[i];
      FClassRec.ClassRec.IntfTable.Entries[i].IOffset := Parent.InstanceSize - SizeOf(Pointer) + i*SizeOf(Pointer) + AditionalInstanceSize;
    end;
  end
  else
    FClassRec.ClassRec.IntfTable := Nil;
end;

procedure TSynteticClass.CreateNewDestroy;
begin
  FNewDestroy := TAsmBlock.Create;

  { mov ecx, edx }
  FNewDestroy.PutB([$8B, $CA]);

  { mov edx, Self }
  FNewDestroy.PutB($BA); FNewDestroy.PutI(Integer(Self));

  { xchg eax, dcx }
  FNewDestroy.PutB($92);

  { After the parameters are set, just jump into TSynteticClass.NewDestroy.
    Note that this is a jump, not a call. A call would return to it's caller (which happens
    to be the method we're defining here), but we don't want this. The NewDestroy will
    call the Finalizer, which may free this TSynteticClass itself. If that happens,
    we would not want to return here because this memory area would be already free'd }
  FNewDestroy.GenJmp(@TSynteticClass.NewDestroy);

  FNewDestroy.Compile;
end;

destructor TSynteticClass.Destroy;
begin
  FNewDestroy.Free;
  FreeMem(FClassRec.ClassRec.Parent);
  if Assigned(FClassRec.ClassRec.IntfTable) then
    FreeMem(FClassRec.ClassRec.IntfTable);
  FreeMem(FClassRec);
  inherited;
end;

function TSynteticClass.EnumerateVirtualMethods(
  const ParentClass: TClass): TArray<TVmtEntry>;
var
  Ctx: TRttiContext;
  RttiType: TRttiType;
  Methods: TArray<TRttiMethod>;
  Method: TRttiMethod;
begin
  SetLength(Result, 0);
  Ctx := TRttiContext.Create;
  try
    RttiType := Ctx.GetType(ParentClass);

    Methods := RttiType.GetMethods;

    for Method in Methods do
    begin
      if Method.DispatchKind = dkVtable then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)].Index := Method.VirtualIndex;
        Result[High(Result)].Address := Method.CodeAddress;
      end;
    end;
  finally
    Ctx.Free;
  end;

  TArray.Sort<TVmtEntry>(Result, TComparer<TVmtEntry>.Construct(function(const Left, Right: TVmtEntry): Integer
  begin
    Result := Left.Index - Right.Index;
  end));
end;

function TSynteticClass.GetMetaclass: TClass;
begin
  Result := TClass(Pointer(Integer(@FClassRec.ClassRec) + SizeOf(TClassRec)));
end;

function TSynteticClass.GetVirtualMethodAddress(const Index: Integer): Pointer;
var
  Vmt: PPointer;
begin
  Vmt := PPointer(@FClassRec.ClassRec.DefaultVirtualMethods);
  Inc(Vmt, Index + 11);
  Result := Vmt^;
end;

procedure TSynteticClass.NewDestroy(Instance: TObject; OuterMost: ShortInt);
var
  OldDestroy: TDestroy;
begin
  { Save the data needed to call the old destructor before calling the Finalizer,
    because the Finalizer may free this TSynteticClass }
  TMethod(OldDestroy).Data := Instance;
  TMethod(OldDestroy).Code := FOldDestroy;

  if Assigned(Finalizer) then
    Finalizer(Instance);

  OldDestroy(OuterMost);

  if FFreeOnInstanceDestroy then
    Free;
end;

procedure TSynteticClass.SetVirtualMethodAddress(const Index: Integer;
  const Value: Pointer);
var
  Vmt: PPointer;
begin
  Vmt := PPointer(@FClassRec.ClassRec.DefaultVirtualMethods);
  Inc(Vmt, Index + 11);
  Vmt^ := Value;
end;

end.
