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

program EmballoTests;
{

  Delphi DUnit Test Project
  -------------------------
  This project contains the DUnit test framework and the GUI/Console test runners.
  Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
  to use the console test runner.  Otherwise the GUI test runner will be used by
  default.

}

{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  Emballo.DI.InstantiatorTests in '..\Tests\Emballo.DI.InstantiatorTests.pas',
  Emballo.DI.CoreTests in '..\Tests\Emballo.DI.CoreTests.pas',
  Emballo.DI.PreBuiltFactoryTests in '..\Tests\Emballo.DI.PreBuiltFactoryTests.pas',
  Emballo.DI.PoolFactoryTests in '..\Tests\Emballo.DI.PoolFactoryTests.pas',
  Emballo.DI.DelegateFactory in '..\Tests\Emballo.DI.DelegateFactory.pas',
  Emballo.DI.RegisterImplTests in '..\Tests\Emballo.DI.RegisterImplTests.pas',
  Emballo.DI.StubFactory in '..\Tests\Emballo.DI.StubFactory.pas',
  Emballo.DynamicProxy.ImplTests in '..\Tests\Emballo.DynamicProxy.ImplTests.pas',
  Emballo.DllWrapper.ImplTests in '..\Tests\Emballo.DllWrapper.ImplTests.pas',
  Emballo.Hash.Md5AlgorithmTests in '..\Tests\Emballo.Hash.Md5AlgorithmTests.pas',
  Emballo.DynamicProxy.MethodImplTests in '..\Tests\Emballo.DynamicProxy.MethodImplTests.pas',
  Emballo.SynteticClassTests in '..\Tests\Emballo.SynteticClassTests.pas',
  Emballo.Mock.MockTests in '..\Tests\Emballo.Mock.MockTests.pas',
  Emballo.DynamicProxy.InterfaceProxyTests in '..\Tests\Emballo.DynamicProxy.InterfaceProxyTests.pas',
  Emballo.Mock.EqualsParameterMatcherTests in '..\Tests\Emballo.Mock.EqualsParameterMatcherTests.pas';

{$R *.RES}

begin
  Application.Initialize;
  ReportMemoryLeaksOnShutdown := True;
  if IsConsole then
    with TextTestRunner.RunRegisteredTests do
      Free
  else
    GUITestRunner.RunRegisteredTests;
end.

