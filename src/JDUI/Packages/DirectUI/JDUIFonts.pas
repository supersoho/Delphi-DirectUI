unit JDUIFonts;

interface

uses Classes, Vcl.Graphics, SysUtils, Gr32;

procedure StringToFont(sFont: string; Font: TFont; bIncludeColor: Boolean = True);
function FontToString(Font: TFont; bIncludeColor: Boolean = True): string;

implementation

const
  csfsBold      = 'B';
  csfsItalic    = 'I';
  csfsUnderline = 'U';
  csfsStrikeout = 'S';

  //
  // Expected format:
  //   "Arial", 9, [Bold], [clRed]
  //
procedure StringToFont(sFont: string; Font: TFont; bIncludeColor: Boolean = True);
var
  P     : Integer;
  sStyle: string;
begin
  with Font do
    try
      // get font name
      P := Pos(',', sFont);
      name := Copy(sFont, 1, P - 1);
      Delete(sFont, 1, P);

      // get font size
      P := Pos(',', sFont);
      Size := StrToInt(Copy(sFont, 1, P - 1));
      Delete(sFont, 1, P);

      // get font style
      P := Pos(',', sFont);
      sStyle := Copy(sFont, 1, P - 1);
      Delete(sFont, 1, P);

      // get font color
      if bIncludeColor then
        Color := Color32(StringToColor('$' + Copy(sFont, 1, Length(sFont)))) and $FFFFFF;

      // convert str font style to
      // font style
      Style := [];

      if (Pos(csfsBold, sStyle) > 0) then
        Style := Style + [fsBold];

      if (Pos(csfsItalic, sStyle) > 0) then
        Style := Style + [fsItalic];

      if (Pos(csfsUnderline, sStyle) > 0) then
        Style := Style + [fsUnderline];

      if (Pos(csfsStrikeout, sStyle) > 0) then
        Style := Style + [fsStrikeOut];
    except
    end;
end;

//
// Output format:
//   "ËÎÌו", 9, [B|I|U|S], [ffddff]
//
function FontToString(Font: TFont; bIncludeColor: Boolean = True): string;
var
  sStyle: string;
begin
  if not Assigned(Font) then Exit('');
  
  with Font do
  begin
    // convert font style to string
    sStyle := '';

    if (fsBold in Style) then
      sStyle := sStyle + csfsBold;

    if (fsItalic in Style) then
      sStyle := sStyle + csfsItalic;

    if (fsUnderline in Style) then
      sStyle := sStyle + csfsUnderline;

    if (fsStrikeOut in Style) then
      sStyle := sStyle + csfsStrikeout;

    if ((Length(sStyle) > 0) and ('|' = sStyle[1])) then
      sStyle := Copy(sStyle, 2, Length(sStyle) - 1);

    Result := Format('%s,%d,%s',[name, Size, sStyle]);
    if bIncludeColor then
      Result := Result + Format(',%s',[Format('%0.6x', [Color32(Color) and $FFFFFF])]);
  end;
end;


end.

