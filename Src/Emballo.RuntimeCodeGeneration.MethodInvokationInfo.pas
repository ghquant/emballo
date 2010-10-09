unit Emballo.RuntimeCodeGeneration.MethodInvokationInfo;

interface

uses
  Rtti;

type
  TParamLocation = (plEax, plEdx, plEcx, plStack);

  TParamKind = (pkImplicitArgument, pkResult);

  TParamInfo = record
    Location: TParamLocation;
    Kind: TParamKind;
    StackOffset: Integer;
    ByValue: Boolean;
  end;

  TMethodInvokationInfo = class
  private
    FResultInfo: TParamInfo;
    FSelfParamInfo: TParamInfo;
    FHasResult: Boolean;
    FParams: array of TParamInfo;

    procedure GenerateSelfParamInfo(const Method: TRttiMethod);
    procedure GenerateResultInfo(const Method: TRttiMethod);
    procedure GenerateParametersInfo(const Method: TRttiMethod);
    function GetParams(Index: Integer): TParamInfo;
    function GetParamCount: Integer;
  public
    constructor Create(const Method: TRttiMethod);

    property ResultInfo: TParamInfo read FResultInfo;
    property SelfParamInfo: TParamInfo read FSelfParamInfo;
    property HasResult: Boolean read FHasResult;
    property ParamCount: Integer read GetParamCount;
    property Params[Index: Integer]: TParamInfo read GetParams;
  end;

implementation

uses
  TypInfo;

{ TMethodInvokationInfo }

constructor TMethodInvokationInfo.Create(const Method: TRttiMethod);
begin
  GenerateSelfParamInfo(Method);
  GenerateParametersInfo(Method);
  GenerateResultInfo(Method);
end;

procedure TMethodInvokationInfo.GenerateParametersInfo(
  const Method: TRttiMethod);
var
  CurrentLocation: TParamLocation;
  CurrentStackOffset: Integer;
  i: Integer;
begin
  SetLength(FParams, Length(Method.GetParameters));

  if Method.CallingConvention = ccReg then
  begin
    CurrentLocation := plEdx; { Skip the implicit Self, that would be on EAX }
    CurrentStackOffset := 0;
  end
  else
  begin
    CurrentLocation := plStack;
    CurrentStackOffset := SizeOf(Pointer); { Skip the implicit Self, that would
                                             be on offset 0 }
  end;

  for i := 0 to High(FParams) do
  begin
    FParams[i].Location := CurrentLocation;
    if CurrentLocation in [plEax..plEcx] then
      Inc(CurrentLocation);

    if FParams[i].Location = plStack then
    begin
      FParams[i].StackOffset := CurrentStackOffset;
      Inc(CurrentStackOffset, SizeOf(Integer));
    end;

    FParams[i].ByValue := not (pfOut in Method.GetParameters[i].Flags);
  end;
end;

procedure TMethodInvokationInfo.GenerateResultInfo(const Method: TRttiMethod);
begin
  FHasResult := Assigned(Method.ReturnType);

  if not HasResult then
    Exit;

  FResultInfo.Kind := pkResult;
  if Method.ReturnType.IsManaged then
  begin
    if ParamCount = 0 then
    begin
      if Method.CallingConvention = ccReg then
        FResultInfo.Location := plEdx
      else
      begin
        FResultInfo.Location := plStack;
        if Method.CallingConvention <> ccPascal then
          FResultInfo.StackOffset := 0
        else
          FResultInfo.StackOffset := SizeOf(Integer);
      end;
    end
    else
    begin
      FResultInfo.Location := Params[ParamCount - 1].Location;
      if FResultInfo.Location in [plEax..plEcx] then
        Inc(FResultInfo.Location)
      else
      begin
        Inc(FResultInfo.StackOffset, SizeOf(Integer));
        if Method.CallingConvention in [ccCdecl, ccStdCall] then
        begin
          { The implicit Result is passed after the implicit Self parameter }
          Inc(FResultInfo.StackOffset, SizeOf(Integer));
        end;
      end;
    end;
    FResultInfo.ByValue := False;
  end
  else
  begin
    FResultInfo.Location := plEax;
    FResultInfo.ByValue := True;
  end;
end;

procedure TMethodInvokationInfo.GenerateSelfParamInfo(const Method: TRttiMethod);
begin
  FSelfParamInfo.Kind := pkImplicitArgument;
  if Method.CallingConvention = ccReg then
    FSelfParamInfo.Location := plEax
  else
    FSelfParamInfo.Location := plStack;
end;

function TMethodInvokationInfo.GetParamCount: Integer;
begin
  Result := Length(FParams);
end;

function TMethodInvokationInfo.GetParams(Index: Integer): TParamInfo;
begin
  Result := FParams[Index];
end;

end.
