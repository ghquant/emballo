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

unit Emballo.RuntimeCodeGeneration.CallingConventions;

interface

uses
  Rtti,
  TypInfo;

type
  TStackCleaningResponsability = (scCaller, scCallee);
  TParameterPassingStrategy = (ppByValue, ppByRef);
  TParametersPassingOrder = (poLeftToRight, poRightToLeft);

  ICallingConvention = interface
    ['{8ABDB7FB-CEFA-444C-944F-615C4BD05E1D}']
    function GetStackCleaningResponsability: TStackCleaningResponsability;
    function GetName: String;

    function NumBytesForPassingParameterOnTheStack(const Parameter: TRttiParameter): Integer; overload;
    function NumBytesForPassingParameterOnTheStack(const ParamType: TRttiType;
      const Flags: TParamFlags): Integer; overload;

    function ParameterPassingStrategy(const Parameter: TRttiParameter): TParameterPassingStrategy; overload;
    function ParameterPassingStrategy(const Info: PTypeInfo;
      const Flags: TParamFlags): TParameterPassingStrategy; overload;
    function GetParametersPassingOrder: TParametersPassingOrder;
    property StackCleaningResponsability: TStackCleaningResponsability read
      GetStackCleaningResponsability;
    property Name: String read GetName;
    property ParametersPassingOrder: TParametersPassingOrder read GetParametersPassingOrder;
  end;

  TCallingConvention = class(TInterfacedObject, ICallingConvention)
  private
    FName: String;
    FCallConv: TCallConv;
    FStackCleaningResponsability: TStackCleaningResponsability;

    function GetName: String;
    function GetStackCleaningResponsability: TStackCleaningResponsability;
    function NumBytesForPassingParameterOnTheStack(const Parameter: TRttiParameter): Integer; overload;
    function ParameterPassingStrategy(const Parameter: TRttiParameter): TParameterPassingStrategy; overload;
    function ParameterPassingStrategy(const Info: PTypeInfo;
      const Flags: TParamFlags): TParameterPassingStrategy; overload;
    function NumBytesForPassingParameterOnTheStack(const ParamType: TRttiType;
      const Flags: TParamFlags): Integer; overload;
    function GetParametersPassingOrder: TParametersPassingOrder;
  public
    constructor Create(const Name: String; CallConv: TCallConv;
      StackCleaningResponsability: TStackCleaningResponsability);
  end;

function GetCallingConvention(CallingConvention: TCallConv): ICallingConvention;

implementation

var
  CallingConventions: array[TCallConv] of ICallingConvention;

{ Copied from Rtti.pas }
function PassByRef(TypeInfo: PTypeInfo; CC: TCallConv): Boolean;
begin
  if TypeInfo = nil then
    Exit(False);

  case TypeInfo^.Kind of
    tkVariant: // like tkRecord, but hard-coded size
      Result := CC in [ccPascal, ccReg];

    tkRecord:
      if CC in [ccCdecl, ccStdCall] then
        Result := False
      else
        Result := GetTypeData(TypeInfo)^.RecSize > SizeOf(Pointer);

    tkArray:
        Result := GetTypeData(TypeInfo)^.ArrayData.Size > SizeOf(Pointer);
    tkString:
      Result := GetTypeData(TypeInfo)^.MaxLength > SizeOf(Pointer);
  else
    Result := False;
  end;
end;

function GetCallingConvention(CallingConvention: TCallConv): ICallingConvention;
begin
  Result := CallingConventions[CallingConvention];
end;

{ TCallingConvention }

constructor TCallingConvention.Create(const Name: String; CallConv: TCallConv;
  StackCleaningResponsability: TStackCleaningResponsability);
begin
  FName := Name;
  FCallConv := CallConv;
  FStackCleaningResponsability := StackCleaningResponsability;
end;

function TCallingConvention.GetName: String;
begin
  Result := FName;
end;

function TCallingConvention.GetParametersPassingOrder: TParametersPassingOrder;
begin
  if FCallConv in [ccPascal, ccReg] then
    Result := poLeftToRight
  else
    Result := poRightToLeft;
end;

function TCallingConvention.GetStackCleaningResponsability: TStackCleaningResponsability;
begin
  Result := FStackCleaningResponsability;
end;

function TCallingConvention.NumBytesForPassingParameterOnTheStack(
  const ParamType: TRttiType; const Flags: TParamFlags): Integer;
begin
  if ParameterPassingStrategy(ParamType.Handle, Flags) = ppByRef then
    Result := SizeOf(Pointer)
  else
  begin
    Result := (((ParamType.TypeSize - 1) div SizeOf(Pointer)) + 1)*SizeOf(Pointer);

    { Each array parameter has an implicit parameter for the array length }
    if pfArray in Flags then
      Inc(Result, SizeOf(Integer));
  end;
end;

function TCallingConvention.ParameterPassingStrategy(const Info: PTypeInfo;
  const Flags: TParamFlags): TParameterPassingStrategy;
begin
  if pfVar in Flags then
    Result := ppByRef
  else if pfOut in Flags then
    Result := ppByRef
  else
  begin
    if PassByRef(Info, FCallConv) then
      Result := ppByRef
    else
      Result := ppByValue;
  end;
end;

function TCallingConvention.NumBytesForPassingParameterOnTheStack(
  const Parameter: TRttiParameter): Integer;
begin
  Result := NumBytesForPassingParameterOnTheStack(Parameter.ParamType,
    Parameter.Flags);
end;

function TCallingConvention.ParameterPassingStrategy(
  const Parameter: TRttiParameter): TParameterPassingStrategy;
begin
  Result := ParameterPassingStrategy(Parameter.ParamType.Handle, Parameter.Flags);
end;

initialization
CallingConventions[ccReg] := TCallingConvention.Create('register', ccReg, scCaller);
CallingConventions[ccCdecl] := TCallingConvention.Create('cdecl', ccCdecl, scCaller);
CallingConventions[ccPascal] := TCallingConvention.Create('pascal', ccPascal, scCallee);
CallingConventions[ccStdCall] := TCallingConvention.Create('stdcall', ccStdCall, scCallee);
CallingConventions[ccSafeCall] := TCallingConvention.Create('safecall', ccSafeCall, scCaller);

end.
