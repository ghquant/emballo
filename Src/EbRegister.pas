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

unit EbRegister;

interface

type
  { This interface handles the registration of a factory within the framework.
    Before registering the factory, it can decorate the base factory in
    different ways, for exemple to work as a singleton }
  IRegister = interface
    ['{0A2FD56B-0A72-4DA4-8454-A526DDD04B80}']

    { Decorates the factory to work as a singleton. That is, after getting the
      instance for the first time, it will be cached }
    function Singleton: IRegister;

    { Decorates the factory to work with a pool. That is, when an interface
      isn't used anyware (in other words, ref. count reaches zero) it is stored
      in a pool instead of being freed. The next time an interface is needed,
      it will be obtained from the pool. The max parameter specifies the maximum
      quantity of objects that can be stored on the pool. Unused interfaces will
      be automatically freed when ref. count reaches zero if the pool is full.
      This is useful for objects that are expensive to instantiate, like
      database connections }
    function Pool(Max: Integer): IRegister;

    { Do the registration }
    procedure Done;
  end;

implementation

end.
