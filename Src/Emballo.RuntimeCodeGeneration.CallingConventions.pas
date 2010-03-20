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

  ICallingConvention = interface
    ['{8ABDB7FB-CEFA-444C-944F-615C4BD05E1D}']
    function GetStackCleaningResponsability: TStackCleaningResponsability;
    function GetName: String;

    function NumBytesForPassingParameterOnTheStack(const Parameter: TRttiParameter): Integer;
    function ParameterPassingStrategy(Parameter: TRttiParameter): TParameterPassingStrategy;
    property StackCleaningResponsability: TStackCleaningResponsability read
      GetStackCleaningResponsability;
    property Name: String read GetName;
  end;

  TCallingConvention = class(TInterfacedObject, ICallingConvention)
  private
    FName: String;
    FCallConv: TCallConv;
    FStackCleaningStrategy: TStackCleaningResponsability;

    function GetName: String;
    function GetStackCleaningResponsability: TStackCleaningResponsability;
    function NumBytesForPassingParameterOnTheStack(const Parameter: TRttiParameter): Integer;
    function ParameterPassingStrategy(Parameter: TRttiParameter): TParameterPassingStrategy;
  public
    constructor Create(const Name: String; CallConv: TCallConv;
      StackCleaningStrategy: TStackCleaningResponsability);
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
  StackCleaningStrategy: TStackCleaningResponsability);
begin
  FName := Name;
  FCallConv := CallConv;
  FStackCleaningStrategy := StackCleaningStrategy;
end;

function TCallingConvention.GetName: String;
begin
  Result := FName;
end;

function TCallingConvention.GetStackCleaningResponsability: TStackCleaningResponsability;
begin
  Result := FStackCleaningStrategy;
end;

function TCallingConvention.NumBytesForPassingParameterOnTheStack(
  const Parameter: TRttiParameter): Integer;
begin
  if ParameterPassingStrategy(Parameter) = ppByRef then
    Result := SizeOf(Pointer)
  else
  begin
    Result := (((Parameter.ParamType.TypeSize - 1) div SizeOf(Pointer)) + 1)*SizeOf(Pointer);

    { Each array parameter has an implicit parameter for the array length }
    if pfArray in Parameter.Flags then
      Inc(Result, SizeOf(Integer));
  end;
end;

function TCallingConvention.ParameterPassingStrategy(
  Parameter: TRttiParameter): TParameterPassingStrategy;
begin
  if pfVar in Parameter.Flags then
    Result := ppByRef
  else if pfOut in Parameter.Flags then
    Result := ppByRef
  else
  begin
    if PassByRef(Parameter.ParamType.Handle, FCallConv) then
      Result := ppByRef
    else
      Result := ppByValue;
  end;
end;

initialization
CallingConventions[ccReg] := TCallingConvention.Create('register', ccReg, scCaller);
CallingConventions[ccCdecl] := TCallingConvention.Create('cdecl', ccCdecl, scCaller);
CallingConventions[ccPascal] := TCallingConvention.Create('pascal', ccPascal, scCallee);
CallingConventions[ccStdCall] := TCallingConvention.Create('stdcall', ccStdCall, scCallee);
CallingConventions[ccSafeCall] := TCallingConvention.Create('safecall', ccSafeCall, scCaller);

end.
