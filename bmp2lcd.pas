program bmp2lcd;

uses
    bmp;

procedure PrintHelp;
begin
    WriteLn('usage: bmp2lcd <type> <bmp_file>');
    WriteLn;
    WriteLn('LCD Types Available:');
    WriteLn('  - [pcd8544] PCD8544 (aka Nokia 5110 LCD)');
    WriteLn;
    WriteLn('The bitmap files must be saved as monochrome (1-bit color depth) and have no compression applied. The simplest way to achieve this is to use MS Paint, go to File->Save As... and select "Monochrome Bitmap"');
    WriteLn;
    WriteLn('Built by Nathan Campos <http://nathancampos.me/>');
    Halt;
end;

begin
    if ParamCount < 2 then
        PrintHelp;

    OpenBitmapFile(ParamStr(2));
    PrintHeaders;
    WriteLn;
    WriteLn('Image:');
    PrintImage;
    CloseBitmapFile;
end.
