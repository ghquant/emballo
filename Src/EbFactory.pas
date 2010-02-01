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
  { Base interface for implementing factories.
    An factory is an object responsible for returning instances of given
    interfaces. The programmer can implement it in different ways to implement
    a number of strategies to get instances of interfaces, aside that already
    implemented by the framework }
  IFactory = interface
    ['{F5603417-3D80-4735-B66D-84FFAC15770B}']

    function GetGUID: TGUID;

    property GUID: TGUID read GetGUID;

    { This method is called when the framework needs an instance the interface
      handled by this factory. }
    function GetInstance: IInterface;
  end;

implementation

end.
