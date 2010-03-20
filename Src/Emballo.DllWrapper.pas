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

unit Emballo.DllWrapper;

interface

uses
  TypInfo, SysUtils, Rtti, Emballo.RuntimeCodeGeneration.AsmBlock;

type
  { Base exception for all other DllWrapper related exceptions }
  EDllWrapper = class abstract(Exception)
  end;

  { Raised when we can`t load the dll }
  ECantLoadDll = class(EDllWrapper)
  public
    constructor Create(const DllName: String; const ErrorCode: Integer);
  end;

  { Raised on an attempt to create a dll wrapper for a typa that is not an
    interface }
  ENotAnInterface = class(EDllWrapper)
  public
    constructor Create;
  end;

  { Raised when the interface has a method that can't be found on the dll }
  EMethodNotFound = class(EDllWrapper)
  public
    constructor Create(const MethodName, DllName: String);
  end;

  { Raised when the interface has a method with a unsupported calling convention }
  EUnsupportedCallingConvention = class(EDllWrapper)
  public
    constructor Create(const MethodName, CallingConvention: String);
  end;

  TDllWrapperService = class
  public
    function Get<WrapperInterface>(const DllName: String): WrapperInterface; overload;
    function Get(InterfaceTypeInfo: PTypeInfo;
      const DllName: String): IInterface; overload;
  end;

function DllWrapperService: TDllWrapperService;

implementation

uses
  Windows,
  Emballo.DllWrapper.Impl;

resourcestring
  SCantLoadDll = 'Can''t load DLL ''%s''.'#13#10 +
                 'Error: %s';

  SNotAnInterface = 'DllWrapper must be used only with interfaces';

  SMethodNotFound = 'Method ''%s'' not found on DLL ''%s''';

  SInvalidCallingConvention = 'Method ''%s'' uses an invalid calling convention: %s''';


function DllWrapperService: TDllWrapperService;
begin
  Result := Nil;
end;

{ ECantLoadDll }

constructor ECantLoadDll.Create(const DllName: String;
  const ErrorCode: Integer);
begin
  inherited CreateResFmt(@SCantLoadDll, [DllName, SysErrorMessage(ErrorCode)]);
end;

{ TDllWrapperService }

function TDllWrapperService.Get(InterfaceTypeInfo: PTypeInfo;
  const DllName: String): IInterface;
begin
  Result := TDllWrapper.Create(InterfaceTypeInfo, DllName);
end;

function TDllWrapperService.Get<WrapperInterface>(
  const DllName: String): WrapperInterface;
var
  Wrapper: IInterface;
  Ctx: TRttiContext;
  GUID: TGUID;
begin
  Wrapper := Get(TypeInfo(WrapperInterface), DllName);

  Ctx := TRttiContext.Create;
  try
    GUID := (Ctx.GetType(TypeInfo(WrapperInterface)) as TRttiInterfaceType).GUID;
  finally
    Ctx.Free;
  end;

  Supports(Wrapper, GUID, Result);
end;

{ ENotAnInterface }

constructor ENotAnInterface.Create;
begin
  inherited CreateRes(@SNotAnInterface);
end;

{ EMethodNotFound }

constructor EMethodNotFound.Create(const MethodName, DllName: String);
begin
  inherited CreateResFmt(@SMethodNotFound, [MethodName, DllName]);
end;

{ EUnsupportedCallingConvention }

constructor EUnsupportedCallingConvention.Create(const MethodName,
  CallingConvention: String);
begin
  inherited CreateResFmt(@SInvalidCallingConvention, [MethodName,
    CallingConvention]);
end;

end.
