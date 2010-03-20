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

unit Emballo.Interfaces.InterfacedObject;

interface

type
  { Very similar to System.TInterfacedObject, but here QueryInterface/_AddRef/
    _Release are virtuals }
  TEbInterfacedObject = class(TObject, IInterface)
  private
    FRefCount: Integer;
  protected
    function QueryInterface(const IID: TGUID; out Obj): HRESULT; virtual; stdcall;
    function _AddRef: Integer; virtual; stdcall;
    function _Release: Integer;  virtual; stdcall;
  public
    class function NewInstance: TObject; override;
  end;

implementation

{ TInterfacedObject }

class function TEbInterfacedObject.NewInstance: TObject;
begin
  { Copied from System.TInterfacedObject }
  Result := inherited NewInstance;
  TEbInterfacedObject(Result).FRefCount := 1;
end;

function TEbInterfacedObject.QueryInterface(const IID: TGUID; out Obj): HRESULT;
begin
  if GetInterface(IID, Obj) then
    Result := 0
  else
    Result := E_NOINTERFACE;
end;

function TEbInterfacedObject._AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TEbInterfacedObject._Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if FRefCount = 0 then
    Free;
end;

end.
