unit BitOp;

interface

function ReverseBits(b: byte): byte;
procedure ClearBit(var Value: QWord; Index: Byte);
procedure SetBit(var Value: QWord; Index: Byte);
procedure PutBit(var Value: QWord; Index: Byte; State: Boolean);
function GetBit(Value: QWord; Index: Byte): Boolean;

implementation

{ Reverse the bits in a byte. }
function ReverseBits(b: byte): byte;
var
    Result: byte;
    i: integer;
begin
    Result := 0;

    for i := 1 to 8 do
    begin
        Result := (Result shl 1) or (b and 1);
        b := b shr 1;
    end;

    ReverseBits := Result;
end;

{ Clears a specific bit in a byte. }
procedure ClearBit(var Value: QWord; Index: Byte);
begin
    Value := Value and ((QWord(1) shl Index) xor High(QWord));
end;

{ Sets a specific bit in a byte. }
procedure SetBit(var Value: QWord; Index: Byte);
begin
    Value:=  Value or (QWord(1) shl Index);
end;

{ Puts a specific bit in a byte. }
procedure PutBit(var Value: QWord; Index: Byte; State: Boolean);
begin
    Value := (Value and ((QWord(1) shl Index) xor High(QWord))) or (QWord(State) shl Index);
end;

{ Gets a specific bit in a byte. }
function GetBit(Value: QWord; Index: Byte): Boolean;
begin
    GetBit := ((Value shr Index) and 1) = 1;
end;

end.
