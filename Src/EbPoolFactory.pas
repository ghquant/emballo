{   Copyright 2010 - Magno Machado Paulo (magnomp@gmail.com)

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

unit EbPoolFactory;

interface

uses
  EbAbstractWrapperFactory, Ebfactory, Classes;

type
  TStub = array[0..MAXINT - 1] of Byte;
  PStub = ^TStub;

  TPoolFactory = class(TAbstractWrapperFactory)
  private
    FPatchedInterface: Boolean;
    FReleaseStub: PStub;
    FOriginalRelease: Pointer;
    FMax: Integer;
    FPool: IInterfaceList;
    FUnavailable: TList;
    function HackedRelease(Obj: TObject): Integer;
    procedure PatchInterfaceIdNeeded(Intf: Pointer);
    procedure GenerateReleaseStub;
  protected
    function GetInstance: IInterface; override;
  public
    constructor Create(const ActualFactory: IFactory; Max: Integer);
    destructor Destroy; override;
  end;

implementation

uses
  Windows, SysUtils, dialogs;

type
  TArrayOfPointer = array[0..(MAXINT div SizeOf(Pointer)) - 1] of Pointer;
  PArrayOfPointer = ^TArrayOfPointer;
  PPArrayOfPointer = ^PArrayOfPointer;

{ TPoolFactory }

constructor TPoolFactory.Create(const ActualFactory: IFactory; Max: Integer);
begin
  inherited Create(ActualFactory);
  FMax := Max;
  FPool := TInterfaceList.Create;
  FUnavailable := TList.Create; { It MUST be a list of raw pointers because we
    need fine controu about ref. couting when inserting and removing items on
    the list }
end;

destructor TPoolFactory.Destroy;
begin
  FUnavailable.Free;
  FreeMem(FReleaseStub);
  inherited;
end;

procedure TPoolFactory.GenerateReleaseStub;
var
  Counter: Integer;

  procedure Put(const Bytes; Size: Integer); overload;
  begin
    Move(Bytes, FReleaseStub^[Counter], Size);
    Inc(Counter, Size);
  end;

  procedure Put(B: Byte); overload;
  begin
    Put(B, 1);
  end;

  procedure Put(I: Integer); overload;
  begin
    Put(I, SizeOf(Integer));
  end;


begin
  { Stub generated stub would be like:
    function GeneratedStub(Self: TObject): Integer; stdcall;
    begin
      Result := <this TPoolFactory instance>.HackedRelease(Self);
    end;}

  GetMem(FReleaseStub, 17);
  Counter := 0;
  { mov edx, [esp + $04]
    Takes the first parameter (the "Self") and prepares to pass it as the
    second parameter to the TPoolFactory.HackedRelease method }
  Put($8B); Put($54); Put($24); Put($04);

  { mov eax, <pointer to this TPoolFactory instance>
    We'll move the address of this TPoolFactory into eax in order to pass it to
    our HackedRelease method }
  Put($B8); Put(Integer(Self));

  { call <offset to TPoolFactory.HackedRelease
    Now it's OK to call our TPoolFactory.HackedRelease method }
  Put($E8); Put(Integer(@TPoolFactory.HackedRelease) - Integer(FReleaseStub) - Counter - 4);

  { ret $0004
    Return to the caller }
  Put($C2); Put($04); Put($00);
end;

function TPoolFactory.GetInstance: IInterface;
begin
  if FPool.Count > 0 then
  begin
    Result := FPool[0];
    FPool.Delete(0);
  end
  else
    Result := FActualFactory.GetInstance;

  FUnavailable.Add(Pointer(Result));
  Result._AddRef;

  PatchInterfaceIdNeeded(Pointer(Result));
end;

function TPoolFactory.HackedRelease(Obj: TObject): Integer;
var
  OriginalRelease: function: Integer of object; stdcall;
  Intf: Pointer;
  Intf2: IInterface;
begin
  TMethod(OriginalRelease).Code := FOriginalRelease;
  TMethod(OriginalRelease).Data := Obj;
  Result := OriginalRelease;

  { Do not count the reference held on FUnavailable. For the outside world,
    it will look like there's no reference here }
  Dec(Result);
  if Result = 0 then
  begin
    { Now, when ref. count reaches zero, it means that the only remaining
      reference is the one stored on FUnavailable. In other words: The object
      not in use anymore, and can now return to the pool or be freed }

    Supports(Obj, IInterface, Intf);
    { The Supports() above addref'd the object, so we undo this now }
    OriginalRelease;

    if FPool.Count < FMax then
    begin
      { If there's free space on the pool, then return the object to the pool }
      Supports(Obj, IInterface, Intf2);
      FPool.Add(Intf2);
      Intf2 := Nil;
      FUnavailable.Remove(Obj);
      { As we removed from the pool, now decrease the ref. count }
      OriginalRelease;
    end
    else
    begin
      { The pool is full. So, we'll really free the object. For that, we call
        the original Release method once again }
      OriginalRelease;
    end;
  end;
end;

procedure TPoolFactory.PatchInterfaceIdNeeded(Intf: Pointer);
const
  RELEASE_INDEX = 2;
var
  M: PArrayOfPointer;
  Stub: PStub;
  OldProtect: Cardinal;
  JmpOffset: Integer;
begin
  if FPatchedInterface then
    Exit;

  GenerateReleaseStub;

  FPatchedInterface := True;
  M := PPArrayOfPointer(Intf)^;
  if not VirtualProtect(M^[RELEASE_INDEX], SizeOf(Pointer), PAGE_EXECUTE_READWRITE, OldProtect) then
    RaiseLastOSError;

  Stub := PStub(M^[RELEASE_INDEX]);
  Move(Stub^[6], JmpOffset, SizeOf(Integer));
  FOriginalRelease := Pointer(Integer(Stub) + 10 + JmpOffset);
  JmpOffset := Integer(FReleaseStub) - (Integer(Stub) + 10);
  Move(JmpOffset, Stub^[6], SizeOf(Integer));
  if not VirtualProtect(M^[RELEASE_INDEX], SizeOf(Pointer), OldProtect, OldProtect) then
    RaiseLastOSError;
 end;

end.
