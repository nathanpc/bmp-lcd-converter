program bmp2lcd;

uses
    bmp;
begin
    OpenBitmapFile('test.bmp');
    PrintHeaders;
    WriteLn;
    WriteLn('Image:');
    PrintImage;
    CloseBitmapFile;
end.
