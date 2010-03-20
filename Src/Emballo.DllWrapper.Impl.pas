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

unit Emballo.DllWrapper.Impl;

interface

uses
  TypInfo,
  Rtti,
  Emballo.DllWrapper,
  Emballo.Interfaces.DynamicInterfaceHelper,
  Emballo.Interfaces.InterfacedObject,
  Emballo.RuntimeCodeGeneration.AsmBlock,
  Emballo.RuntimeCodeGeneration.CallingConventions;

type
  { Define procedures that can generate the method stub to call a specific
    function on the DLL }
  TStubGeneratorProc = procedure(FunctionAddress: Pointer; Method: TRttiMethod;
    AsmBlock: TAsmBlock);

  { This is the base class for implementations of Dll interfaces.
    You DON'T need to inherit from it. Just call it's constructor passing the
    type info of the interface and the name of the wrapped Dll, and the returned
    instance will be dynamically an implementation of that interface }
  TDllWrapper = class(TEbInterfacedObject)
  strict private
    FHandle: HMODULE;
    FStubs: array of TAsmBlock;
    FDynamicInterfaceHelper: TDynamicInterfaceHelper;
    function GetStubGeneratorFor(CallingConvention: TCallConv): TStubGeneratorProc;
  protected
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; override;
  public
    constructor Create(InterfaceTypeInfo: PTypeInfo; const DllName: String);
    destructor Destroy; override;
  end;

  TCalcParamListStackSizeProc = function(Parameters: TArray<TRttiParameter>): Integer;

implementation

uses
  SysUtils,
  Windows;

{ The stdcall, cdecl and pascal calling conventions are very very similar
  from the point of view of the strategy used for generating the stubs.
  In fact, pascal differs from the other two because of the order parameters
  ara pushed on the stack:
  Pascal pushes left-to-right, while stdcall and cdecl pushes right-to-left.
  On pascal, the implicit "Self" is the right-most parameter, while on cdecl and
  stdcall it's the left-most, so, the implicit "Self" is always the last
  argument pushed on the stack.

  This is how it works:
  First I have to figure out how many bytes are used on the stack to represent
  the arguments (not counting the implicit "Self" argument). Let's call this as
  BytesToCopy

  * "esp" poins to the return address
  * "esp + 4" points to the implicit "Self" argument
  * from "esp + 8" to "esp + 8 + BytesToCopy", there are the remaining arguments

  Then, we subtract BytesToCopy bytes from esp. This will reserve space on the
  stack to represent all of the arguments (not counting the implicit "Self").

  After, we call the Move routing to copy BytesToCopy bytes from "esp + 8" to
  "esp - BytesToCopy". This is exactly the same as pushing the arguments again,
  without the implicit "Self".

  After that, we call the Dll routine.

  After the routing runs, if caller has the responsability of cleaning the
  stack, we must add BytesToCopy to "esp" in order to release the space we
  used before to copy the parameters. if Callee has the responsability, then
  we don't have to care about this.

  Finally, the stack is on it's original state. Our copied arguments have gone.

  Now we have to check if callee has the responsability of cleaning the stack.
  If so, we must exit with a
  "ret <BytesToCopy + Bytes of the implicit "Self" argument> in order to clean
  the stack.
  If not, we exit with a single "ret" instruction }
procedure GenericStubGenerator(FunctionAddress: Pointer;
  CallingConvention: ICallingConvention;
  Method: TRttiMethod;
  AsmBlock: TAsmBlock);
var
  BytesToCopy: Integer;
  Parameter: TRttiParameter;
begin
  BytesToCopy := 0;
  for Parameter in Method.GetParameters do
    Inc(BytesToCopy, CallingConvention.NumBytesForPassingParameterOnTheStack(Parameter));

  if BytesToCopy > 0 then
  begin
    { 1. Put on eax the first parameter to the Move routine, which is the
         source address: esp + $08.

      mov eax, esp }
    AsmBlock.PutB($89); AsmBlock.PutB($E0);

    { add eax, $08 }
    AsmBlock.PutB($83); AsmBlock.PutB($C0); AsmBlock.PutB($08);

    { 2. Subtract ByteToCopy bytes from esp to reserve space on the stack

      sub esp, BytesToCopy }
    AsmBlock.PutB($83); AsmBlock.PutB($EC); AsmBlock.PutB(BytesToCopy);

    { 3. Put on edx the second parameter to the Move routine, which is the
          destination address: esp - BytesToCopy

      mov edx, esp }
    AsmBlock.PutB($89); AsmBlock.PutB($E2);

    { 4. Put on ecx the third parameter to the Move routine, which is the
         quantity of bytes to copy: BytesToCopy

      mov ecx, BytesToCopy }
    AsmBlock.PutB($B9); AsmBlock.PutI(BytesToCopy);

    { 5. Call the Move routine to copy the parameters

      call Move }
    AsmBlock.GenCall(@Move);
  end;

  { 6. Call the dll function

    call <dll function> }
  AsmBlock.GenCall(FunctionAddress);

  if CallingConvention.StackCleaningResponsability = scCaller then
  begin
    if BytesToCopy > 0 then
    begin
      { 7. Release the reserved space on the stack

        add esp, BytesToCopy }
      AsmBlock.PutB($83); AsmBlock.PutB($C4); AsmBlock.PutB(BytesToCopy);
    end;

    { 8. Return to the caller

      ret }
    AsmBlock.GenRet;
  end
  else
  begin
    { 7. Return to the caller and clean up the stack

      ret <bytes to copy + bytes of the implicit Self parameter> }
    AsmBlock.GenRet(BytesToCopy + SizeOf(Integer));
  end;
end;

procedure StdCallStubGenerator(FunctionAddress: Pointer; Method: TRttiMethod;
  AsmBlock: TAsmBlock);
begin
  GenericStubGenerator(FunctionAddress, GetCallingConvention(ccStdCall), Method, AsmBlock);
end;

procedure CdeclStubGenerator(FunctionAddress: Pointer; Method: TRttiMethod;
  AsmBlock: TAsmBlock);
begin
  GenericStubGenerator(FunctionAddress, GetCallingConvention(ccCdecl), Method,
    AsmBlock);
end;

procedure PascalStubGenerator(FunctionAddress: Pointer; Method: TRttiMethod;
  AsmBlock: TAsmBlock);
begin
  GenericStubGenerator(FunctionAddress, GetCallingConvention(ccPascal), Method,
    AsmBlock);
end;

{ TDllWrapper }

constructor TDllWrapper.Create(InterfaceTypeInfo: PTypeInfo;
  const DllName: String);
var
  Ctx: TRttiContext;
  RttiType: TRttiType;
  Method: TRttiMethod;
  Methods: TArray<TRttiMethod>;
  MethodPointers: TArray<Pointer>;
  i: Integer;
  Address: Pointer;
  StubGenerator: TStubGeneratorProc;
begin
  FHandle := LoadLibrary(PChar(DllName));
  if FHandle = 0 then
    raise ECantLoadDll.Create(DllName, GetLastError);

  Ctx := TRttiContext.Create;
  try
    RttiType := Ctx.GetType(InterfaceTypeInfo);
    if RttiType is TRttiInterfaceType then
    begin
      Methods := RttiType.GetDeclaredMethods;
      SetLength(FStubs, Length(Methods));
      SetLength(MethodPointers, Length(Methods));

      for i := 0 to High(Methods) do
      begin
        Method := Methods[i];

        Address := GetProcAddress(FHandle, PChar(Method.Name));

        if not Assigned(AddRess) then
          raise EMethodNotFound.Create(Method.Name, DllName);

        StubGenerator := GetStubGeneratorFor(Method.CallingConvention);
        if not Assigned(StubGenerator) then
        begin
          raise EUnsupportedCallingConvention.Create(Method.Name,
            GetCallingConvention(Method.CallingConvention).Name);
        end;

        FStubs[i] := TAsmBlock.Create;
        StubGenerator(Address, Method, FStubs[i]);
        FStubs[i].Compile;

        MethodPointers[i] := FStubs[i].Block;
      end;
    end
    else
      raise ENotAnInterface.Create;
  finally
    Ctx.Free;
  end;

  FDynamicInterfaceHelper := TDynamicInterfaceHelper.Create(TRttiInterfaceType(RttiType).GUID,
    @TDllWrapper.QueryInterface, @TDllWrapper._AddRef, @TDllWrapper._Release,
    Self, MethodPointers);
end;

destructor TDllWrapper.Destroy;
var
  Stub: TObject;
begin
  FDynamicInterfaceHelper.Free;

  for Stub in FStubs do
    Stub.Free;

  if FHandle <> 0 then
    FreeLibrary(FHandle);
  inherited;
end;

function TDllWrapper.GetStubGeneratorFor(
  CallingConvention: TCallConv): TStubGeneratorProc;
begin
  case CallingConvention of
    ccStdCall: Result := StdCallStubGenerator;
    ccCdecl: Result := CdeclStubGenerator;
    ccPascal: Result := PascalStubGenerator;
    else Result := Nil;
  end;
end;

function TDllWrapper.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  Result := FDynamicInterfaceHelper.QueryInterface(IID, Obj);
end;

end.
