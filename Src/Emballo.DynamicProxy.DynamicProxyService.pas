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

unit Emballo.DynamicProxy.DynamicProxyService;

interface

uses
  Emballo.DynamicProxy.InvokationHandler;

type
  TDynamicProxyService = class
  public
    function Get<T:class>(InvocationHandler: TInvokationHandlerAnonMethod): T; overload;
    function Get<T:class>(InvocationHandler: TInvokationHandlerMethod): T; overload;
  end;

function DynamicProxyService: TDynamicProxyService;

implementation

uses
  Emballo.DynamicProxy.Impl;

function DynamicProxyService: TDynamicProxyService;
begin
  Result := Nil;
end;

{ TDynamicProxyService }

function TDynamicProxyService.Get<T>(InvocationHandler: TInvokationHandlerAnonMethod): T;
var
  Proxy: TDynamicProxy;
begin
  Proxy := TDynamicProxy.Create(TClass(T), Nil, InvocationHandler);
  Result := T(Proxy.ProxyObject);
end;

function TDynamicProxyService.Get<T>(InvocationHandler: TInvokationHandlerMethod): T;
var
  Proxy: TDynamicProxy;
begin
  Proxy := TDynamicProxy.Create(TClass(T), Nil, InvocationHandler);
  Result := T(Proxy.ProxyObject);
end;

end.
