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

unit Emballo.TypeWrappers;

interface

uses
  Types, Generics.Collections;

type
  TBeforeChangeEvent<T> = reference to procedure(const Old: T; var New: T;
    out AcceptChange: Boolean);

  TAfterChangeEvent<T> = reference to procedure(const Old, New: T);

  IChangeEventsManager<T> = interface
    ['{21DD7DE6-6E82-48C9-B82F-8DA226F14A58}']
    procedure AddBeforeChangeEvent(const Event: TBeforeChangeEvent<T>);
    procedure AddAfterChangeEvent(const Event: TAfterChangeEvent<T>);
    procedure RemoveBeforeChangeEvent(const Event: TBeforeChangeEvent<T>);
    procedure RemoveAfterChangeEvent(const Event: TAfterChangeEvent<T>);
  end;

  TChangeEventsManager<T> = class(TInterfacedObject, IChangeEventsManager<T>)
  private
    FBeforeChangeEvents: TList<TBeforeChangeEvent<T>>;
    FAfterChangeEvents: TList<TAfterChangeEvent<T>>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddBeforeChangeEvent(const Event: TBeforeChangeEvent<T>);
    procedure AddAfterChangeEvent(const Event: TAfterChangeEvent<T>);
    procedure RemoveBeforeChangeEvent(const Event: TBeforeChangeEvent<T>);
    procedure RemoveAfterChangeEvent(const Event: TAfterChangeEvent<T>);
  end;

  TIntegerWrapper = record
  private
    FValue: Integer;
    FHasValueTag: String;
    procedure SetValue(Value: Integer);
    function GetIsNull: Boolean;
  public
    property Value: Integer read FValue write SetValue;
    property IsNull: Boolean read GetIsNull;
    procedure Clear;
    class operator Implicit(Value: Integer): TIntegerWrapper;
    class operator Implicit(Value: TIntegerWrapper): Integer;
  end;

implementation

{ TIntegerWrapper }

procedure TIntegerWrapper.Clear;
begin
  FHasValueTag := '';
  FValue := 0;
end;

function TIntegerWrapper.GetIsNull: Boolean;
begin
  Result := FHasValueTag = '';
end;

class operator TIntegerWrapper.Implicit(Value: Integer): TIntegerWrapper;
begin
  Result.Value := Value;
end;

class operator TIntegerWrapper.Implicit(Value: TIntegerWrapper): Integer;
begin
  Result := Value.Value;
end;

procedure TIntegerWrapper.SetValue(Value: Integer);
begin
  FValue := Value;
  FHasValueTag := 'X';
end;

{ TChangeEventsManager<T> }

procedure TChangeEventsManager<T>.AddAfterChangeEvent(const Event: TAfterChangeEvent<T>);
begin
  FAfterChangeEvents.Add(Event);
end;

procedure TChangeEventsManager<T>.AddBeforeChangeEvent(
  const Event: TBeforeChangeEvent<T>);
begin
  FBeforeChangeEvents.Add(Event);
end;

constructor TChangeEventsManager<T>.Create;
begin
  FBeforeChangeEvents := TList<TBeforeChangeEvent<T>>.Create;
  FAfterChangeEvents := TList<TAfterChangeEvent<T>>.Create;
end;

destructor TChangeEventsManager<T>.Destroy;
begin
  FBeforeChangeEvents.Free;
  FAfterChangeEvents.Free;
  inherited;
end;

procedure TChangeEventsManager<T>.RemoveAfterChangeEvent(
  const Event: TAfterChangeEvent<T>);
begin
  FAfterChangeEvents.Remove(Event);
end;

procedure TChangeEventsManager<T>.RemoveBeforeChangeEvent(
  const Event: TBeforeChangeEvent<T>);
begin
  FBeforeChangeEvents.Remove(Event);
end;

end.
