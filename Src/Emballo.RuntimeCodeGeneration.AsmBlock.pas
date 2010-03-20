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

unit Emballo.RuntimeCodeGeneration.AsmBlock;

interface

type
  TRelativeAddressFix = record
    Position: Integer;
    Destination: Pointer;
  end;

  { Helper class to manage a block of runtime generated machine code }
  TAsmBlock = class
  strict private
    FBlock: Pointer;
    FOriginalProtectFlags: Cardinal;
    FRelativeAddressFixes: array of TRelativeAddressFix;
    FBytes: array of Byte;
  public
    destructor Destroy; override;

    { Points to the generated code block. Before using it, you must call
      Compile }
    property Block: Pointer read FBlock;

    { General purpose routines to put arbitrary bytes on the code block }
    procedure Put(const Value; Size: Integer);
    procedure PutB(Value: Byte);
    procedure PutI(Value: Integer);
    procedure PutP(Value: Pointer);
    procedure PutW(Value: Word);

    { Produces a "call" instruction to the Destination address }
    procedure GenCall(Destination: Pointer);

    { Produces a "jmp" instruction to the Destination address }
    procedure GenJmp(Destination: Pointer);

    { Produces a "ret" instruction }
    procedure GenRet; overload;

    { Produces a "ret BytesToReleaseOnStack" instruction }
    procedure GenRet(BytesToReleaseOnStack: Word); overload;

    { Prepares the machine code block to be used.
      You must call it after you finished to put the instructions on the block }
    procedure Compile;
  end;

implementation

uses
  Windows, SysUtils;

{ TAsmBlock }

procedure TAsmBlock.Compile;
var
  RelativeAddressFix: TRelativeAddressFix;
  OffsetAddress: Pointer;
  NextInstructionAddress: Integer;
  Offset: Integer;
begin
  GetMem(FBlock, Length(FBytes));
  for RelativeAddressFix in FRelativeAddressFixes do
  begin
    OffsetAddress := Pointer(Integer(FBlock) + RelativeAddressFix.Position);
    NextInstructionAddress := Integer(OffsetAddress) + SizeOf(Pointer);
    Offset := Integer(RelativeAddressFix.Destination) - Integer(NextInstructionAddress);
    Move(Offset, FBytes[RelativeAddressFix.Position], SizeOf(Integer));
  end;
  Move(FBytes[0], FBlock^, Length(FBytes));

  Win32Check(VirtualProtect(FBlock, Length(FBytes), PAGE_EXECUTE_READWRITE,
    FOriginalProtectFlags));
end;

destructor TAsmBlock.Destroy;
begin
  Win32Check(VirtualProtect(FBlock, Length(FBytes), FOriginalProtectFlags,
    FOriginalProtectFlags));
  FreeMem(FBlock);
  inherited;
end;

procedure TAsmBlock.GenRet(BytesToReleaseOnStack: Word);
begin
  PutB($C2);
  PutW(BytesToReleaseOnStack);
end;

procedure TAsmBlock.GenRet;
begin
  PutB($C3);
end;

procedure TAsmBlock.Put(const Value; Size: Integer);
begin
  SetLength(FBytes, Length(FBytes) + Size);
  Move(Value, FBytes[Length(FBytes) - Size], Size);
end;

procedure TAsmBlock.PutB(Value: Byte);
begin
  Put(Value, SizeOf(Byte));
end;

procedure TAsmBlock.GenCall(Destination: Pointer);
begin
  PutB($E8);
  SetLength(FRelativeAddressFixes, Length(FRelativeAddressFixes) + 1);
  FRelativeAddressFixes[High(FRelativeAddressFixes)].Position := Length(FBytes);
  FRelativeAddressFixes[High(FRelativeAddressFixes)].Destination := Destination;

  { Put any pointer, just to reserve space. It will be corrected later }
  PutP(Destination);
end;

procedure TAsmBlock.PutI(Value: Integer);
begin
  Put(Value, SizeOf(Integer));
end;

procedure TAsmBlock.GenJmp(Destination: Pointer);
begin
  PutB($E9);
  SetLength(FRelativeAddressFixes, Length(FRelativeAddressFixes) + 1);
  FRelativeAddressFixes[High(FRelativeAddressFixes)].Position := Length(FBytes);
  FRelativeAddressFixes[High(FRelativeAddressFixes)].Destination := Destination;

  { Put any pointer, just to reserve space. It will be corrected later }
  PutP(Destination);
end;

procedure TAsmBlock.PutP(Value: Pointer);
begin
  Put(Value, SizeOf(Pointer));
end;

procedure TAsmBlock.PutW(Value: Word);
begin
  Put(Value, SizeOf(Word));
end;

end.
