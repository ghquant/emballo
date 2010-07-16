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

unit Emballo.Mock.MockInternal;

interface

uses
  SysUtils,
  Emballo.Mock.When;

type
  TExceptionClass = class of Exception;

  IMockInternal<T:class> = interface
    ['{34CB781C-7C84-47A7-B829-35D3AA6DE766}']

    function GetObject: T;

    function Expects: T;

    procedure VerifyUsage;

    function WillRaise(ExceptionClass: TExceptionClass): IWhen<T>;

    function WillReturn(const Value: Integer): IWhen<T>;
  end;

implementation

end.
