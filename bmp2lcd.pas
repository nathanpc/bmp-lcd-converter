program bmp2lcd;

uses
    bmp;
begin
    OpenBitmapFile('test4.bmp');
    PrintHeaders;
    WriteLn;
    WriteLn('Image:');
    PrintImage;
    CloseBitmapFile;
end.
