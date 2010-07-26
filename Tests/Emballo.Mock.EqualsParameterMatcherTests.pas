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

unit Emballo.Mock.EqualsParameterMatcherTests;

interface

uses
  TestFramework;

type
  TEqualsParameterMatcherTests = class(TTestCase)
  published
    procedure ShouldMatchOnEqualValueInteger;
    procedure ShouldNotMatchOnDifferentValueInteger;
  end;

implementation

uses
  Emballo.Mock.EqualsParameterMatcher,
  Emballo.Mock.ParameterMatcher;

{ TEqualsParameterMatcherTests }

procedure TEqualsParameterMatcherTests.ShouldMatchOnEqualValueInteger;
var
  Matcher: IParameterMatcher;
begin
  Matcher := TEqualsParameterMatcher<Integer>.Create(1);
  CheckTrue(Matcher.Match(1));
end;

procedure TEqualsParameterMatcherTests.ShouldNotMatchOnDifferentValueInteger;
var
  Matcher: IParameterMatcher;
begin
  Matcher := TEqualsParameterMatcher<Integer>.Create(1);
  CheckFalse(Matcher.Match(2));

  Matcher := TEqualsParameterMatcher<Integer>.Create(11);
  CheckFalse(Matcher.Match(20));
end;

initialization
RegisterTest('Emballo.Mock', TEqualsParameterMatcherTests.Suite);

end.
