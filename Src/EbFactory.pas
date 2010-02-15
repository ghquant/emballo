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

unit EbFactory;

interface

type
  { This represents anonymous methods that are returned by IFactories and are
    the actual objects that have the responsability of getting the instances. }
  TDeferredFactory = reference to function: IInterface;

  { Base interface for implementing factories.
    An factory is an object called by the framework when it needs instances of
    given interfaces. The programmer can implement it in different ways to
    implement a number of strategies to get instances of interfaces, aside that
    already implemented by the framework }
  IFactory = interface
    ['{F5603417-3D80-4735-B66D-84FFAC15770B}']

    function GetGUID: TGUID;

    { The GUID that this factory can handle }
    property GUID: TGUID read GetGUID;

    { This method is called when the framework needs an instance the interface
      handled by this factory.
      The programmer is free to decide if the instance will be built inside or
      outside the TDeferredFactory, but it's better to do it inside the
      TDeferredFactory as the framework can postpone the deferred factory
      invocation until it's really necessary (In fact, there will be situations
      that a TDeferredFactory returned here will never be invoked }
    function GetDeferredFactory: TDeferredFactory;
  end;

implementation

end.
