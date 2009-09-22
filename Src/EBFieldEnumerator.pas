{   Copyright 2009 - Magno Machado Paulo (magnomp@gmail.com)

    This file is part of Emballo.

    Emballo is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Emballo is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Foobar.  If not, see <http://www.gnu.org/licenses/>. }

unit EBFieldEnumerator;

interface

uses
  TypInfo, EBEmballoException;

type
  EFieldNotInterface = class(EEmballo)
  end;

  { Represents a particular instance field on a class and knows how to inject
    data on the correspondent field on an object.
    The field this object represents must be of an interface type }
  IFieldData = interface
    ['{ECFBDD8D-69AC-4208-9BBF-9E50C458795A}']

    function GetDeclaringClass: TClass;
    function GetGuid: TGUID;

    { Class where the field represented by this IFieldData was declared }
    property DeclaringClass: TClass read GetDeclaringClass;

    { Declared interface type of the field represented by this IFieldData }
    property Guid: TGUID read GetGuid;

    { Injects the interface specified by Value into the field represented by this
      IFieldData on the object specified by Instance.

      Value must support the guid specified on the Guid property, or an
      EInvalidType must be raised

      Instance must be of the same type or a subclass of the type specified by
      the DeclaringClass property, or an EInvalidType must be raised }
    procedure Inject(Instance: TObject; Value: IInterface);
  end;

  TFieldsData = array of IFieldData;

  TFieldInfo = packed record
    TypeInfo: PPTypeInfo;
    Offset: Cardinal;
  end;

  PFieldTable = ^TFieldTable;
  TFieldTable = packed record
    X: Word;
    Size: Cardinal;
    Count: Cardinal;
    Fields: array [0..0] of TFieldInfo;
  end;

  TFieldData = class(TInterfacedObject, IFieldData)
  private
    FDeclaringClass: TClass;
    FOffset: Cardinal;
    FGuid: TGUID;
    function GetDeclaringClass: TClass;
    function GetGuid: TGUID;
    procedure Inject(Instance: TObject; Value: IInterface);
  public
    constructor Create(DeclaringClass: TClass; FieldInfo: TFieldInfo);
  end;

{ Returns all the interface fields declared on the specified class and its
  parents. }
function EnumerateFields(ClassType: TClass): TFieldsData;

implementation

uses
  SysUtils, EBInvalidTypeException;

{ This is based on code extracted from TObject.CleanupInstance }
function EnumerateFieldsForClass(ClassType: TClass): TFieldsData;
var
  InitTable: Pointer;
  FT: PFieldTable;
  i: Integer;
  FieldInfo: TFieldInfo;
begin
  InitTable := PPointer(Integer(ClassType) + vmtInitTable)^;

  if not Assigned(InitTable) then
  begin
    { InitTable = Nil means that the class has no fields that I could detect
      here }
    SetLength(Result, 0);
    Exit;
  end;


  FT := PFieldTable(Integer(InitTable) + Byte(PTypeInfo(InitTable).Name[0]));

  SetLength(Result, 0);
  for i := 0 to FT.Count - 1 do
  begin
    FieldInfo := TFieldInfo(Pointer(Integer(@FT.Fields) + SizeOf(TFieldInfo)*i)^);

    if FieldInfo.TypeInfo^.Kind = tkInterface then
    begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := TFieldData.Create(ClassType, FieldInfo);
    end;
  end;
end;

function EnumerateFields(ClassType: TClass): TFieldsData;
var
  FieldsCurrentClass: TFieldsData;
  i: Integer;
begin
  SetLength(Result, 0);
  repeat
    FieldsCurrentClass := EnumerateFieldsForClass(ClassType);
    for i := 0 to High(FieldsCurrentClass) do
    begin
      SetLength(Result, Length(Result) + 1);
      Result[High(Result)] := FieldsCurrentClass[i];
    end;
    ClassType := ClassType.ClassParent;
  until ClassType = TObject;
end;

{ TFieldData }

constructor TFieldData.Create(DeclaringClass: TClass; FieldInfo: TFieldInfo);
begin
  if FieldInfo.TypeInfo^.Kind <> tkInterface then
    raise EFieldNotInterface.Create('Field type isn''t an interface');

  FDeclaringClass := DeclaringClass;
  FOffset := FieldInfo.Offset;
  FGuid := GetTypeData(FieldInfo.TypeInfo^).Guid;
end;

function TFieldData.GetDeclaringClass: TClass;
begin
  Result := FDeclaringClass;
end;

function TFieldData.GetGuid: TGUID;
begin
  Result := FGuid;
end;

procedure TFieldData.Inject(Instance: TObject; Value: IInterface);
var
  FieldPointer: PPointer;
  P: Pointer;
begin
  if not Supports(Value, GetGuid, P) then
    raise EInvalidType.Create('The injected value must support the field type');
  try
    if not Instance.InheritsFrom(GetDeclaringClass) then
      raise EInvalidType.Create('The object to receive the injection must be the same or a subclass of the class where the field was declared');

    FieldPointer := Pointer(Cardinal(Instance) + FOffset);

    { If the field has already been assigned, we have to _Release the current
      value before assign the new one }
    if Assigned(FieldPointer^) then
      IInterface(FieldPointer^)._Release;

    FieldPointer^ := P;

    { We made the assignment as a pointer move operation. This doesnt increment
      the ref count, so we have to do it by ourselves }
    Value._AddRef;
  finally
    { The call to supports made above had incremented the ref count. So here we
      have to decrease it }
    Value._Release;
  end;
end;

end.
