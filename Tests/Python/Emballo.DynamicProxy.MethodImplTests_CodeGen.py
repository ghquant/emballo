import sys

BASE_FILE = "..\Emballo.DynamicProxy.MethodImplTests";

SOURCE = BASE_FILE + "_Register.pas";

def changeFile(callingConvention):
  handle = open(SOURCE, "r");
  content = handle.readlines();
  handle.close();
  i = 0;
  while (i < len(content)):
    line = content[i];
    line = line.replace("; register;", "; " + callingConvention + ";");
    line = line.replace("MethodImplTests_Register", "MethodImplTests_" + callingConvention.title());
    content.pop(i);
    content.insert(i, line);
    i = i + 1;

  handle = open(BASE_FILE + "_" + callingConvention.title() + ".pas", "w");
  for line in content:
    handle.write(line);
  handle.close();

changeFile("stdcall");
changeFile("cdecl");
changeFile("pascal");