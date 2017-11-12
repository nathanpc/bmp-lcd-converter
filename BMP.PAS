unit BMP;

interface
type
    TBMP = record
        header: record
            Signature: string;
            FileSize: integer;
            Reserved: array [0..3] of byte;
            DataOffset: integer;
        end;
        info: record
            Size: integer;
            Width: integer;
            Height: integer;
            Planes: integer;
            ColorDepth: integer;
            Compression: integer;
            ImageSize: integer;
            xPixelsPerM: integer;
            yPixelsPerM: integer;
            ColorsUsed: integer;
            ColorsImportant: integer;
        end;
        { TODO: Include space for color table. }
    end;

var
    Bitmap: TBMP;

procedure PrintHeaders;
procedure OpenBitmapFile(bmp_file: string);
procedure CloseBitmapFile;

implementation
uses
    SysUtils;
var
    BMPFile: file;

{ Converts a byte array to integer. }
function ByteArrToInt(data: array of byte; length: integer): integer;
begin
    if length = 2 then
        ByteArrToInt := integer((data[1] shl 8) or data[0])
    else if length = 4 then
        ByteArrToInt := integer((data[3] shl 24) or (data[2] shl 16) or (data[1] shl 8) or data[0])
    else
        WriteLn('ByteArrToInt: Unsupported array length');
end;

procedure PrintHeaders;
begin
    WriteLn('Header');
    WriteLn('  Signature:   ' + Bitmap.header.Signature);
    WriteLn('  File Size:   ' + IntToStr(Bitmap.header.FileSize));
    WriteLn('  Reserved:    ' + IntToHex(Bitmap.header.Reserved[0], 2) + ' ' + IntToHex(Bitmap.header.Reserved[1], 2) + ' ' + IntToHex(Bitmap.header.Reserved[2], 2) + ' ' + IntToHex(Bitmap.header.Reserved[3], 2));
    WriteLn('  Data Offset: ' + IntToStr(Bitmap.header.FileSize));

    WriteLn('Info Header');
    WriteLn('  Size:             ' + IntToStr(Bitmap.info.Size));
    WriteLn('  Width:            ' + IntToStr(Bitmap.info.Width));
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

{ Opens the bitmap file and reads the headers. }
procedure OpenBitmapFile(bmp_file: string);
begin
    Assign(BMPFile, bmp_file);
    Reset(BMPFile, 1);

    ParseHeaders;
end;

{ Close the bitmap file. }
procedure CloseBitmapFile;
begin
    Close(BMPFile);
end;

end.
