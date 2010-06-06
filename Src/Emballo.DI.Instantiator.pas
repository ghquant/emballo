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

unit Emballo.DI.Instantiator;

interface

uses
  Rtti, TypInfo, SysUtils;

type
  { This class is used to dynamicaly build a new instance of any class. }
  TInstantiator = class
  private
    FCtx: TRttiContext;
  protected
    { Return the list of constructors of the most specific class on
      AClass' hierarchy that has any constructor. }
    function EnumConstructors(AClass: TClass): TArray<TRttiMethod>;

    function TryExecuteConstructor(AClass: TClass; Ctor: TRttiMethod;
      out Instance: TObject): Boolean;
  public
    constructor Create;
    destructor Destroy; override;

    { This method tries to build an instance of the given class and returns it.

      Let TTheClass be the class we're trying to build.
      First it'll enumerate all of the constructors of the most specific class of
      TTheClass' class hierarchy that has any constructor.

      After that, it'll try to find a suitable constructor and this will be used
      to instantiate the class. An suitable constructor is a constructor whose all
      arguments (if it has any) are interface types, and all of them can be
      instantiated by calling EbRegistry.TryBuild.

      Imagine this class hierarchy:

      type
        TSuperClassA = class
        public
          constructor Create;
        end;

        TSuperClassB = class(TSuperClassA)
        public
          constructor Create(const Name: String);
          constructor Create;
          constructor Create(Owner: ISomeInterface);
        end;

        TTheClass = class(TSuperClassB)
        end;

      If we try to instantiate TTheClass, only TSuperClassB's constructors will
      be used. The first constructor isn't suitable because it takes an argument
      which isn't an interface type. Both the other constructors are suitable and
      will be tryied in the order that they are returned by Delphi's Rtti.

      Let's say the constructor that takes the interface argument is returned
      first. Now we'll try to get an instance of ISomeInterface through
      Ebregistry.TryBuild. If we get the instance, then this will be the choosen
      constructor. Otherwise, we'll try the remaining constructor.

      If after all the class cannot be instantiated, an ENoSuitableConstructor
      will be raised }
    function Instantiate(AClass: TClass): TObject;
  end;

  ENoSuitableConstructor = class(Exception)
  public
    constructor Create(AClass: TClass);
  end;

implementation

uses
  Emballo.DI.Registry, Emballo.Rtti, Emballo.DI.Factory;

{ TInstantiator }

constructor TInstantiator.Create;
begin
  FCtx := TRttiContext.Create;
end;

destructor TInstantiator.Destroy;
begin
  FCtx.Free;
  inherited;
end;

function TInstantiator.EnumConstructors(AClass: TClass): TArray<TRttiMethod>;
var
  Methods: TArray<TRttiMethod>;
  Method: TRttiMethod;
begin
  SetLength(Result, 0);
  while True do
  begin
    Methods := FCtx.GetType(AClass).GetDeclaredMethods;
    for Method in Methods do
    begin
      if Method.IsConstructor then
      begin
        SetLength(Result, Length(Result) + 1);
        Result[High(Result)] := Method;
      end;
    end;

    if AClass = TObject then
      Break;

    if Length(Result) > 0 then
      Break;

    AClass := AClass.ClassParent;
  end;
end;

function TInstantiator.Instantiate(AClass: TClass): TObject;
var
  Constructors: TArray<TRttiMethod>;
  Ctor: TRttiMethod;
begin
  Constructors := EnumConstructors(AClass);
  for Ctor in Constructors do
  begin
    if TryExecuteConstructor(AClass, Ctor, Result) then
      Exit;
  end;

  raise ENoSuitableConstructor.Create(AClass);
end;

function TInstantiator.TryExecuteConstructor(AClass: TClass; Ctor: TRttiMethod;
  out Instance: TObject): Boolean;
var
  Params: TArray<TRttiParameter>;
  Args: TArray<TValue>;
  Factories: TArray<IFactory>;
  ParamInstance: IInterface;
  TypedParamInstance: Pointer;
  ParamType: TRttiInterfaceType;
  i: Integer;
  GUID: TGUID;
begin
  Params := Ctor.GetParameters;
  SetLength(Factories, Length(Params));
  for i := 0 to High(Params) do
  begin
    if Params[i].ParamType.TypeKind = tkInterface then
    begin
      ParamType := (Params[i].ParamType as TRttiInterfaceType);
      GUID := ParamType.GUID;
      Factories[i] := GetFactoryFor(GUID);
      if not Assigned(Factories[i]) then
        Exit(False);
    end
    else
      Exit(False);
  end;

  { If we are here, then all parameters are interface types, and we managed to
    get the deferred factories for all of the parameters. Then we can invoke the
    factories to get the actual instances for the parameters }
  SetLength(Args, Length(Params));
  for i := 0 to High(Params) do
  begin
    ParamType := (Params[i].ParamType as TRttiInterfaceType);
    GUID := ParamType.GUID;

    ParamInstance := Factories[i].GetInstance;
    Supports(ParamInstance, GUID, TypedParamInstance);
    TValue.Make(@TypedParamInstance, ParamType.Handle, Args[i]);
  end;

  Instance := Ctor.Invoke(AClass, Args).AsObject;
  Result := True;
end;

{ ENoSuitableConstructor }

constructor ENoSuitableConstructor.Create(AClass: TClass);
begin
  inherited Create('Couldn''t find a suitable constructor on class ' + AClass.ClassName);
end;

end.
