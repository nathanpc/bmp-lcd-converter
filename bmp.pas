unit BMP;

interface
type
    TBMP = record
        header: record
            Signature: string;
            FileSize: LongWord;
            Reserved: array [0..3] of byte;
            DataOffset: LongWord;
        end;
        info: record
            Size: LongWord;
            Width: LongWord;
            Height: LongWord;
            Planes: LongWord;
            ColorDepth: LongWord;
            Compression: LongWord;
            ImageSize: LongWord;
            xPixelsPerM: LongWord;
            yPixelsPerM: LongWord;
            ColorsUsed: LongWord;
            ColorsImportant: LongWord;
        end;
        { TODO: Include space for color table. }
        image: array of array of boolean;
    end;

var
    Bitmap: TBMP;

procedure PrintHeaders;
procedure PrintImage;
procedure OpenBitmapFile(bmp_file: string);
procedure CloseBitmapFile;

implementation
uses
    SysUtils, StrUtils, Math, BitOp;
var
    BMPFile: file;

{ Converts a byte array to integer. }
function ByteArrToInt(data: array of byte; length: integer): LongWord;
begin
    if length = 2 then
        ByteArrToInt := LongWord((data[1] shl 8) or data[0])
    else if length = 4 then
        ByteArrToInt := LongWord((data[3] shl 24) or (data[2] shl 16) or (data[1] shl 8) or data[0])
    else
        WriteLn('ByteArrToInt: Unsupported array length');
end;

procedure PrintHeaders;
begin
    WriteLn('Header');
    WriteLn('  Signature:   ' + Bitmap.header.Signature);
    WriteLn('  File Size:   ' + IntToStr(Bitmap.header.FileSize));
    WriteLn('  Reserved:    ' + IntToHex(Bitmap.header.Reserved[0], 2) + ' ' + IntToHex(Bitmap.header.Reserved[1], 2) + ' ' + IntToHex(Bitmap.header.Reserved[2], 2) + ' ' + IntToHex(Bitmap.header.Reserved[3], 2));
    WriteLn('  Data Offset: ' + IntToStr(Bitmap.header.DataOffset));

    WriteLn('Info Header');
    WriteLn('  Size:             ' + IntToStr(Bitmap.info.Size));
    WriteLn('  Width:            ' + IntToStr(Bitmap.info.Width) + ' (' + IntToStr(ceil(Bitmap.info.Width / 32)) + ' chunks)');
    WriteLn('  Height:           ' + IntToStr(Bitmap.info.Height));
    WriteLn('  Planes:           ' + IntToStr(Bitmap.info.Planes));
    WriteLn('  Color Depth:      ' + IntToStr(Bitmap.info.ColorDepth));
    WriteLn('  Compression:      ' + IntToStr(Bitmap.info.Compression));
    WriteLn('  Image Size:       ' + IntToStr(Bitmap.info.ImageSize));
    WriteLn('  xPixelsPerM:      ' + IntToStr(Bitmap.info.xPixelsPerM));
    WriteLn('  yPixelsPerM:      ' + IntToStr(Bitmap.info.yPixelsPerM));
    WriteLn('  Colors Used:      ' + IntToStr(Bitmap.info.ColorsUsed));
    WriteLn('  Colors Important: ' + IntToStr(Bitmap.info.ColorsImportant));
end;

{ Parse the bitmap file headers. }
procedure ParseHeaders;
var
    data: array [0..3] of byte;
begin
    { Header }
    BlockRead(BMPFile, data, 2);
    Bitmap.header.Signature := char(data[0]) + char(data[1]);

    BlockRead(BMPFile, data, 4);
    Bitmap.header.FileSize := ByteArrToInt(data, 4);

    BlockRead(BMPFile, data, 4);
    Bitmap.header.Reserved := data;

    BlockRead(BMPFile, data, 4);
    Bitmap.header.DataOffset := ByteArrToInt(data, 4);

    { Info Header }
    BlockRead(BMPFile, data, 4);
    Bitmap.info.Size := ByteArrToInt(data, 4);

    BlockRead(BMPFile, data, 4);
    Bitmap.info.Width := ByteArrToInt(data, 4);

    BlockRead(BMPFile, data, 4);
    Bitmap.info.Height := ByteArrToInt(data, 4);

    BlockRead(BMPFile, data, 2);
    Bitmap.info.Planes := ByteArrToInt(data, 2);

    BlockRead(BMPFile, data, 2);
    Bitmap.info.ColorDepth := ByteArrToInt(data, 2);

    BlockRead(BMPFile, data, 4);
    Bitmap.info.Compression := ByteArrToInt(data, 4);

    BlockRead(BMPFile, data, 4);
    Bitmap.info.ImageSize := ByteArrToInt(data, 4);

    BlockRead(BMPFile, data, 4);
    Bitmap.info.xPixelsPerM := ByteArrToInt(data, 4);

    BlockRead(BMPFile, data, 4);
    Bitmap.info.yPixelsPerM := ByteArrToInt(data, 4);

    BlockRead(BMPFile, data, 4);
    Bitmap.info.ColorsUsed := ByteArrToInt(data, 4);

    BlockRead(BMPFile, data, 4);
    Bitmap.info.ColorsImportant := ByteArrToInt(data, 4);
end;

procedure ReadImage;
var
    scanlineb: array [0..3] of byte;
    scanline: LongWord;
    line, col: integer;
    height: integer;
    chunk, chunks: integer;
begin
    { Set the number of rows and seek the file to the image data. }
    SetLength(Bitmap.image, Bitmap.info.Height);
    Seek(BMPFile, Bitmap.header.DataOffset);

    { Prepare some dimensions. }
    height := Bitmap.info.Height - 1;
    chunks := ceil(Bitmap.info.Width / 32);

    { Reading the image data. }
    for line := 0 to height do
    begin
        { Set the size of each row. }
        SetLength(Bitmap.image[height - line], Bitmap.info.Width);

        for chunk := 0 to chunks - 1 do
        begin
            { Read a line (32 bits). }
            BlockRead(BMPFile, scanlineb, 4);

            { Reverse the bits since they are LSB-first. }
            scanlineb[0] := ReverseBits(scanlineb[0]);
            scanlineb[1] := ReverseBits(scanlineb[1]);
            scanlineb[2] := ReverseBits(scanlineb[2]);
            scanlineb[3] := ReverseBits(scanlineb[3]);

            { Convert the bytes to a integer of pixels. }
            scanline := ByteArrToInt(scanlineb, 4);

            for col := 0 to 31 do
            begin
                { Store the pixel. }
                Bitmap.image[height - line][col + (32 * chunk)] := GetBit(scanline, col);

                if (col + (32 * chunk)) = Bitmap.info.Width - 1 then
                    Break;
            end;
        end;
    end;
end;

procedure PrintImage;
var
    line, col: integer;
begin
    { Print the top frame. }
    Write(#201);
    for col := 0 to Bitmap.info.Width - 1 do
    begin
        Write(#205);
    end;
    WriteLn(#187);

    { Print the actual image. }
    for line := 0 to Bitmap.info.Height - 1 do
    begin
        Write(#186);
        for col := 0 to Bitmap.info.Width - 1 do
        begin
            if Bitmap.image[line][col] then
                Write(' ')
            else
                Write(#254)
        end;

        WriteLn(#186);
    end;

    { Print the bottom frame. }
    Write(#200);
    for col := 0 to Bitmap.info.Width - 1 do
    begin
        Write(#205);
    end;
    WriteLn(#188);
end;

{ Opens the bitmap file and reads the headers. }
procedure OpenBitmapFile(bmp_file: string);
begin
    { Open the file }
    Assign(BMPFile, bmp_file);
    Reset(BMPFile, 1);

    { Parse the headers and read the image. }
    ParseHeaders;
    ReadImage;
end;

{ Close the bitmap file. }
procedure CloseBitmapFile;
begin
    Close(BMPFile);
end;

end.
