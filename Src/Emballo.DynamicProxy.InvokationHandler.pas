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

unit Emballo.DynamicProxy.InvokationHandler;

interface

uses
  Rtti, SysUtils;

type
  EParameterReadOnly = class(Exception)
  public
    constructor Create;
  end;

  IParameter = interface
    ['{480F5D55-BDF1-4ED0-B106-E64AFF13F47E}']
    function GetAsByte: Byte;
    procedure SetAsByte(Value: Byte);
    function GetAsInteger: Integer;
    procedure SetAsInteger(Value: Integer);
    function GetAsDouble: Double;
    procedure SetAsDouble(Value: Double);
    function GetAsString: String;
    procedure SetAsString(Value: String);
    function GetAsBoolean: Boolean;
    procedure SetAsBoolean(Value: Boolean);

    property AsByte: Byte read GetAsByte write SetAsByte;
    property AsInteger: Integer read GetAsInteger write SetAsInteger;
    property AsDouble: Double read GetAsDouble write SetAsDouble;
    property AsString: String read GetAsString write SetAsString;
    property AsBoolean: Boolean read GetAsBoolean write SetAsBoolean;
  end;

  TInvokationHandlerAnonMethod = reference to procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter);

  TInvokationHandlerMethod = procedure(const Method: TRttiMethod;
    const Parameters: TArray<IParameter>; const Result: IParameter) of object;

implementation

{ EParameterReadOnly }

constructor EParameterReadOnly.Create;
begin
  inherited Create('Parameter is readonly');
end;

end.
