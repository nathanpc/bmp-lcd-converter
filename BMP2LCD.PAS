program bmp2lcd;

uses
    bmp;
begin
    OpenBitmapFile('test.bmp');
    PrintHeaders;
    CloseBitmapFile;
end.
