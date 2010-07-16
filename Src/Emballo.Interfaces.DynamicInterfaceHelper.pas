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

unit Emballo.Interfaces.DynamicInterfaceHelper;

interface

uses
  Emballo.RuntimeCodeGeneration.AsmBlock;

type
  { This is a helper for classes that dynamically implements interfaces }
  TDynamicInterfaceHelper = class
  private
    FGUID: TGUID;
    FQueryInterfaceAddress: Pointer;
    FAddRefAddress: Pointer;
    FReleaseAddress: Pointer;
    FInstance: Pointer;

    FQueryInterfaceStub: TAsmBlock;
    FAddRefStub: TAsmBlock;
    FReleaseStub: TAsmBlock;

    FMethods: array of Pointer;

    FInterface: Pointer;

    FOffset: Integer;

    procedure BuildStub(Block: TAsmBlock; Destination: Pointer);
    function GetVTable: Pointer;
  public
    { GUID is the identifier of the dynamically implemented interface,
      QueryInterfaceAddress, AddRefAddress and ReleaseAddress are the
      addresses of the implementation of these methods.
      MethodsAddress is an array where each element is an array of pointers
      to the implementations of the methods of the interface (not counting
      those inherited from IInterface).
      Instance is the instance of the object that will be dynamically
      implementing the interface }
    constructor Create(GUID: TGUID; QueryInterfaceAddress, AddRefAddress,
      ReleaseAddress, Instance: Pointer; MethodsAddresses: array of Pointer; Offset: Integer);
    destructor Destroy; override;

    function QueryInterface(IID: TGUID; out Obj): HRESULT; stdcall;

    property VTable: Pointer read GetVTable;
  end;

implementation

uses
  SysUtils;

{ TDynamicInterfaceHelper }

procedure TDynamicInterfaceHelper.BuildStub(Block: TAsmBlock;
  Destination: Pointer);
var
  Increment: Integer;
begin
  { 1. Correct the Self parameter }
  Increment := Integer(FInstance) - Integer(FInterface);
  { add [esp+$04], Increment }
  Block.PutB($81); Block.PutB($44); Block.PutB($24); Block.PutB($04); Block.PutI(Increment);

  { 2. Jump to the actual method }
  { jmp Destination }
  Block.GenJmp(Destination);

  Block.Compile;
end;

constructor TDynamicInterfaceHelper.Create(GUID: TGUID; QueryInterfaceAddress,
  AddRefAddress, ReleaseAddress, Instance: Pointer;
  MethodsAddresses: array of Pointer; Offset: Integer);
begin
  FInstance := Instance;

  FOffset := Offset;

  GetMem(FInterface, SizeOf(Pointer));

  SetLength(FMethods, Length(MethodsAddresses) + 3);

  FGUID := GUID;
  FQueryInterfaceAddress := QueryInterfaceAddress;
  FAddRefAddress := AddRefAddress;
  FReleaseAddress := ReleaseAddress;

  FQueryInterfaceStub := TAsmBlock.Create;
  BuildStub(FQueryInterfaceStub, FQueryInterfaceAddress);

  FAddRefStub := TAsmBlock.Create;
  BuildStub(FAddRefStub, FAddRefAddress);

  FReleaseStub := TAsmBlock.Create;
  BuildStub(FReleaseStub, FReleaseAddress);

  FMethods[0] := FQueryInterfaceStub.Block;
  FMethods[1] := FAddRefStub.Block;
  FMethods[2] := FReleaseStub.Block;

  Move(MethodsAddresses[0], FMethods[3], Length(MethodsAddresses)*SizeOf(Pointer));

  Pointer(FInterface^) := @FMethods[0];
end;

destructor TDynamicInterfaceHelper.Destroy;
begin
  FQueryInterfaceStub.Free;
  FAddRefStub.Free;
  FReleaseStub.Free;
  FreeMem(FInterface);
  inherited;
end;

function TDynamicInterfaceHelper.GetVTable: Pointer;
begin
  Result := @FMethods[0];
end;

function TDynamicInterfaceHelper.QueryInterface(IID: TGUID; out Obj): HRESULT;
var
  OriginalQI: function(const IID: TGUID; out Obj): HRESULT of object; stdcall;
begin
  if IsEqualGUID(IID, FGUID) then
  begin
    Pointer(Obj) := FInterface;
    Result := 0;
  end
  else
  begin
    TMethod(OriginalQI).Code := FQueryInterfaceAddress;
    TMethod(OriginalQI).Data := FInstance;

    Result := OriginalQI(IID, Obj);
  end;
end;

end.
