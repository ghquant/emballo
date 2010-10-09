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

unit Emballo.DynamicProxy.MethodImpl;

interface

uses
  Rtti,
  Emballo.DynamicProxy.InvokationHandler,
  Emballo.DynamicProxy.NativeToInvokationHandlerBridge,
  Emballo.RuntimeCodeGeneration.AsmBlock;

type
  TMethodImpl = class
  private
    FGeneratedMethod: TAsmBlock;
    FInvokationHandler: TInvokationHandlerAnonMethod;
    FMethod: TRttiMethod;
    FRttiContext: TRttiContext;
    FBridge: TNativeToInvokationHandlerBridge;
    function OffsetToInitialStackPosition(const SizeOfResult: Integer): Integer;
    function GetCodeAddress: Pointer;
    procedure GenerateReturnCode;
    procedure GenerateMethod;
    procedure CallInvokationHander(const ParamsBaseStackAddress: Pointer;
      Eax, Edx, Ecx, ResultValue: Pointer); stdcall;
  public
    constructor Create(const RttiContext: TRttiContext; const Method: TRttiMethod;
      const InvokationHandler: TInvokationHandlerAnonMethod);
    destructor Destroy; override;
    property CodeAddress: Pointer read GetCodeAddress;
  end;

implementation

uses
  Windows,
  Emballo.RuntimeCodeGeneration.CallingConventions, TypInfo,
  Emballo.DynamicProxy.InvokationHandler.ParameterImpl,
  Emballo.RuntimeCodeGeneration.MethodInvokationInfo;

procedure _UStrAsg(var Dest: UnicodeString; const Source: UnicodeString);
asm
  call System.@UStrAsg
end;

{ TMethodImpl }

procedure TMethodImpl.CallInvokationHander(const ParamsBaseStackAddress: Pointer;
  Eax, Edx, Ecx, ResultValue: Pointer);

  function BuildParam(Info: TParamInfo; RttiInfo: TRttiType; IsResult: Boolean): IParameter;
  begin
    if IsResult then
      Result := TParameter.Create(@ResultValue, False, RttiInfo.TypeKind)
    else
    begin
      case Info.Location of
        plStack: Result := TParameter.Create(Pointer(Integer(ParamsBaseStackAddress) + Info.StackOffset), Info.ByValue, RttiInfo.TypeKind);
        plEax: Result := TParameter.Create(PPointer(Eax), Info.ByValue, RttiInfo.TypeKind);
        plEcx: Result := TParameter.Create(PPointer(Ecx), Info.ByValue, RttiInfo.TypeKind);
        plEdx: Result := TParameter.Create(PPointer(Edx), Info.ByValue, RttiInfo.TypeKind);
      end;
    end;
  end;

var
  ParamInfo: TParamInfo;
  InvokationInfo: TMethodInvokationInfo;
  RttiParams: TArray<TRttiParameter>;
  Params: TArray<IParameter>;
  i: Integer;
  Result: IParameter;
begin
  InvokationInfo := TMethodInvokationInfo.Create(FMethod);
  try
    RttiParams := FMethod.GetParameters;
    SetLength(Params, Length(RttiParams));
    for i := 0 to High(Params) do
    begin
      ParamInfo := InvokationInfo.Params[i];
      Params[i] := BuildParam(ParamInfo, RttiParams[i].ParamType, False);
    end;

    if InvokationInfo.HasResult then
      Result := BuildParam(InvokationInfo.ResultInfo, FMethod.ReturnType, True)
    else
      Result := Nil;
  finally
    InvokationInfo.Free;
  end;

  FInvokationHandler(FMethod, Params, Result);
end;

constructor TMethodImpl.Create(const RttiContext: TRttiContext; const Method: TRttiMethod;
  const InvokationHandler: TInvokationHandlerAnonMethod);
begin
  FRttiContext := RttiContext;
  FGeneratedMethod := TAsmBlock.Create;
  FInvokationHandler := InvokationHandler;
  FMethod := Method;
  GenerateMethod;
  FGeneratedMethod.Compile;
end;

destructor TMethodImpl.Destroy;
begin
  FGeneratedMethod.Free;
  inherited;
end;

procedure TMethodImpl.GenerateMethod;
var
  CallingConvention: ICallingConvention;
  NumBytes: Integer;
  Param: TRttiParameter;
  SizeOfResult: Integer;
begin
  CallingConvention := GetCallingConvention(FMethod.CallingConvention);

  { Calculates the size of the return type, if any. Remember that managed
    return types are treated as out parameters, which are passed as the last
    parameter }
  if Assigned(FMethod.ReturnType) then
    SizeOfResult := FMethod.ReturnType.TypeSize
  else
    SizeOfResult := 0;

  { 1. Prepare the stack frame for three integer variables + result variable}
  { push ebp }
  FGeneratedMethod.PutB($55);

  { mov ebp, esp }
  FGeneratedMethod.PutB([$8B, $EC]);

  { add esp, -(<space for three integer variables> + SizeOfResult) }
  FGeneratedMethod.PutB([$83, $C4, Byte(-3*SizeOf(Integer) - SizeOfResult)]);

  { 3. Save the current eax value }
  { mov [ebp-$04], eax }
  FGeneratedMethod.PutB([$89, $45, $FC]);

  { 4. Save the current edx value }
  { mov [ebp-$08], edx }
  FGeneratedMethod.PutB([$89, $55, $F8]);

  { 5. Save the current ecx value }
  { mov [ebp-$0c], ecx }
  FGeneratedMethod.PutB([$89, $4D, $F4]);

  { 6. Pass the result buffer }
  { lea edx, [ebp-$10] }
  FGeneratedMethod.PutB([$8D, $55, $F0]);

  { push edx }
  FGeneratedMethod.PutB($52);

  { 7. Put the stored ecx value as the 5th parameter to CallInvokationHander }
  { lea edx, [ebp-$0c] }
  FGeneratedMethod.PutB([$8D, $55, $F4]);

  { push edx }
  FGeneratedMethod.PutB($52);

  { 8. Put the stored edx value as the 4th parameter to CallInvokationHander }
  { lea edx, [ebp-$08] }
  FGeneratedMethod.PutB([$8D, $55, $F8]);

  { push edx }
  FGeneratedMethod.PutB($52);

  { 9. Put the stored eax value as the 3rd parameter to CallInvokationHander }
  { lea edx, [ebp-$04] }
  FGeneratedMethod.PutB([$8d, $55, $FC]);

  { push edx }
  FGeneratedMethod.PutB($52);

  { 10. Takes the value of the first parameter on the stack (if there's any) and
        put it as the 2nd parameter to CallInvokationHandler }
  { mov edx, N] }
  FGeneratedMethod.PutB([$8D, $54, $24, OffsetToInitialStackPosition(SizeOfResult)]);

  { puah edx }
  FGeneratedMethod.PutB($52);

  { 11. Put the implicit Self parameter }
  { push <pointer to this TMethodImpl> }
  FGeneratedMethod.PutB($68); FGeneratedMethod.PutI(Integer(Self));

  { 12. If the result is managed, initialize our local variable to zero }
  if Assigned(FMethod.ReturnType) and FMethod.ReturnType.IsManaged then
  begin
    { mov ebp-$10, 0 }
    FGeneratedMethod.PutB([$C7, $45, $F0, $00, $00, $00, $00]);
  end;

  { 13. Call the "CallInvokationHandler" }
  { call TMethodImpl.CallInvokationHander }
  FGeneratedMethod.GenCall(@TMethodImpl.CallInvokationHander);

  { 14. If the method has a return value, do it }
  GenerateReturnCode;

  { 15. Undo the stack frame }
  { mov esp, ebp }
  FGeneratedMethod.PutB([$8B, $E5]);

  { pop ebp }
  FGeneratedMethod.PutB($5D);

  { 16. Return to the caller }
  if CallingConvention.StackCleaningResponsability = scCaller then
    FGeneratedMethod.GenRet
  else
  begin
    NumBytes := 0;
    for Param in FMethod.GetParameters do
      Inc(NumBytes, CallingConvention.NumBytesForPassingParameterOnTheStack(Param));

    if Assigned(FMethod.ReturnType) and FMethod.ReturnType.IsManaged then
      Inc(NumBytes, SizeOf(Pointer));

    FGeneratedMethod.GenRet(NumBytes);
  end;
end;

procedure TMethodImpl.GenerateReturnCode;
  procedure ReturnOnEax;
  begin
    { mov eax, [ebp-$10] }
    FGeneratedMethod.PutB([$8B, $45, $F0]);
  end;

  procedure ReturnString;
  var
    Info: TMethodInvokationInfo;
  begin
    Info := TMethodInvokationInfo.Create(FMethod);
    try
      { We have to put on eax the value that was initialy on the location where
        we are suposed to return the result string. This value is the pointer
        of the String variable that we have to set }
      case Info.ResultInfo.Location of
        plEax:
        begin
          { mov eax, [ebp-$4] }
          FGeneratedMethod.PutB([$8B, $45, $FC]);
        end;
        plEdx:
        begin
          { mov eax, [ebp-$08] }
          FGeneratedMethod.PutB([$8B, $45, $F8]);
        end;
        plStack:
        begin
          { mov eax, [ebp-Info.ResultInfo.StackOffset] }
          FGeneratedMethod.PutB([$8B, $45, Byte((2*SizeOf(Integer) + Info.ResultInfo.StackOffset))]);
        end;
      end;

      { mov edx, [ebp-$10] }
      FGeneratedMethod.PutB([$8B, $55, $F0]);
      { call _UStrAsn }
      FGeneratedMethod.GenCall(@_UStrAsg);
    finally
      Info.Free;
    end;
  end;

  procedure ReturnFloat;
  begin
    { fld qword ptr [esp-$10] }
    FGeneratedMethod.PutB([$DD, $45, $F0]);
  end;
begin
  if not Assigned(FMethod.ReturnType) then
    Exit;

  if FMethod.ReturnType.TypeKind = tkFloat then
    ReturnFloat
  else if FMethod.ReturnType.TypeKind = tkUString then
    ReturnString
  else
    ReturnOnEax;
end;

function TMethodImpl.GetCodeAddress: Pointer;
begin
  Result := FGeneratedMethod.Block;
end;

function TMethodImpl.OffsetToInitialStackPosition(
  const SizeOfResult: Integer): Integer;
begin
  Result := 9*SizeOf(Integer) + SizeOfResult;
end;

end.
