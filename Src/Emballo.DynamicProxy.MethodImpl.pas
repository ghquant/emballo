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
  Emballo.RuntimeCodeGeneration.AsmBlock;

type
  TMethodImpl = class
  private
    FGeneratedMethod: TAsmBlock;
    FInvokationHandler: TInvokationHandlerAnonMethod;
    FMethod: TRttiMethod;
    function GetCodeAddress: Pointer;
    procedure GenerateReturnCode;
    procedure GenerateMethod;
    procedure CallInvokationHander(const ParamsBaseStackAddress: Pointer;
      Eax, Edx, Ecx, ResultValue: Pointer); stdcall;
  public
    constructor Create(const Method: TRttiMethod;
      const InvokationHandler: TInvokationHandlerAnonMethod);
    destructor Destroy; override;
    property CodeAddress: Pointer read GetCodeAddress;
  end;

implementation

uses
  Emballo.RuntimeCodeGeneration.CallingConventions, TypInfo,
  Emballo.DynamicProxy.InvokationHandler.ParameterImpl;

{ TMethodImpl }

procedure TMethodImpl.CallInvokationHander(const ParamsBaseStackAddress: Pointer;
  Eax, Edx, Ecx, ResultValue: Pointer);

  function CreateParamFromStack(var CurrentStackAddress: PByte;
    const CallingConvention: ICallingConvention; const ByValue: Boolean;
    const Param: TRttiParameter): IParameter;
  begin
    Result := TParameter.Create(CurrentStackAddress, ByValue, Param.ParamType.TypeKind);
    Inc(CurrentStackAddress, CallingConvention.NumBytesForPassingParameterOnTheStack(Param));
  end;

var
  CallingConvention: ICallingConvention;
  Params: TArray<IParameter>;
  Location: (lEdx, lEcx, lStack);
  RttiParameter: TRttiParameter;
  PassByValue: Boolean;
  i: Integer;
  CurrentStackAddress: PByte;
  ResultParam: IParameter;
begin
  CallingConvention := GetCallingConvention(FMethod.CallingConvention);

  CurrentStackAddress := ParamsBaseStackAddress;

  if FMethod.CallingConvention = ccReg then
    Location := lEdx
  else
  begin
    Location := lStack;

    { Skip the implicit "Self" parameter }
    Inc(CurrentStackAddress, SizeOf(Integer));
  end;

  SetLength(Params, Length(FMethod.GetParameters));
  for i := 0 to Length(Params) - 1 do
  begin
    RttiParameter := FMethod.GetParameters[i];
    PassByValue := CallingConvention.ParameterPassingStrategy(RttiParameter) = ppByValue;

    case Location of
      lEdx:
      begin
        if RttiParameter.ParamType.TypeSize > SizeOf(Integer) then
        begin
          Params[i] := CreateParamFromStack(CurrentStackAddress, CallingConvention,
            PassByValue, RttiParameter);
        end
        else
        begin
          Params[i] := TParameter.Create(Edx, PassByValue, RttiParameter.ParamType.TypeKind);
          Inc(Location);
        end;
      end;
      lEcx:
      begin
        if RttiParameter.ParamType.TypeSize > SizeOf(Integer) then
        begin
          Params[i] := CreateParamFromStack(CurrentStackAddress, CallingConvention,
            PassByValue, RttiParameter);
        end
        else
        begin
          Params[i] := TParameter.Create(Ecx, PassByValue, RttiParameter.ParamType.TypeKind);
          Inc(Location);
        end;
      end;
      lStack:
      begin
        Params[i] := CreateParamFromStack(CurrentStackAddress, CallingConvention,
          PassByValue, RttiParameter);
      end;
    end;

  end;

  if Assigned(FMethod.ReturnType) then
  begin
    ResultParam := TParameter.Create(@ResultValue, False, FMethod.ReturnType.TypeKind);
    FInvokationHandler(FMethod, Params, ResultParam);
  end
  else
    FInvokationHandler(FMethod, Params, Nil);
end;

constructor TMethodImpl.Create(const Method: TRttiMethod;
  const InvokationHandler: TInvokationHandlerAnonMethod);
begin
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
  if Assigned(FMethod.ReturnType) then
    SizeOfResult := FMethod.ReturnType.TypeSize
  else
    SizeOfResult := 0;

  { 1. Prepare the stack frame for three integer variables + result variable}
  { push ebp }
  FGeneratedMethod.PutB($55);

  { mov ebp, esp }
  FGeneratedMethod.PutB([$8B, $EC]);

  { add esp, -<space for three integer variables> + SizeOfResult }
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

  { 10. Takes the value of esp as it was at the beginning of this method and put it
    as the 2nd parameter to CallInvokationHandler. This is the base address to access
    the parameters which are on the stack }
  { mov edx, [esp+$04] }
  FGeneratedMethod.PutB([$8D, $54, $24, 8*SizeOf(Integer) + SizeOfResult]);

  { puah edx }
  FGeneratedMethod.PutB($52);

  { 11. Put the implicit Self parameter }
  { push <pointer to this TMethodImpl> }
  FGeneratedMethod.PutB($68); FGeneratedMethod.PutI(Integer(Self));

  { 12. Call the "CallInvokationHandler" }
  { call TMethodImpl.CallInvokationHander }
  FGeneratedMethod.GenCall(@TMethodImpl.CallInvokationHander);

  { 13. If the method has a return value, do it }
  GenerateReturnCode;

  { 14. Undo the stack frame }
  { mov esp, ebp }
  FGeneratedMethod.PutB([$8B, $E5]);

  { pop ebp }
  FGeneratedMethod.PutB($5D);

  { 15. Return to the caller }
  if FMethod.CallingConvention in [ccCdecl, ccReg] then
  begin
    { When cdecl and register, the caller is responsible for cleaning the stack }
    FGeneratedMethod.GenRet
  end
  else
  begin
    CallingConvention := GetCallingConvention(FMethod.CallingConvention);

    NumBytes := 0;
    for Param in FMethod.GetParameters do
      Inc(NumBytes, CallingConvention.NumBytesForPassingParameterOnTheStack(Param));

    { When stdcall and pascal, the callee is responsible for cleaning the stack }
    FGeneratedMethod.GenRet(NumBytes);
  end;
end;

procedure TMethodImpl.GenerateReturnCode;
  procedure ReturnOnEax;
  begin
    { mov eax, [ebp-$10] }
    FGeneratedMethod.PutB([$8B, $45, $F0]);
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
  else
    ReturnOnEax;
end;

function TMethodImpl.GetCodeAddress: Pointer;
begin
  Result := FGeneratedMethod.Block;
end;

end.
