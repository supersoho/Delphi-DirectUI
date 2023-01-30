unit jinTextDraw;

interface

uses System.SysUtils, System.Classes, Generics.Collections, VCL.Graphics, FreeType, Math;

procedure initFreeType;
procedure destroyFreeType;
function getFreeTypeFace(normalFontFile, boldFontFile, heavyFontFile: String; font: TFont): FT_Face;
function getFreeTypeEmojiFace(emojiFontFile: String; font: TFont): FT_Face;
function getFreeTypeGlyph(char: Char; face: FT_Face; font: TFont): FT_Glyph;
procedure setFreeTypeGlyph(char: Char; glyph: FT_Glyph; font: TFont);

var
  FreeTypeInited: Boolean = False;
  FreeTypeLibrary: FT_Library;

implementation

var
  Faces: TDictionary<String, FT_Face>;
  Texts: TDictionary<String, FT_Glyph>;

function getFreeTypeGlyph(char: Char; face: FT_Face; font: TFont): FT_Glyph;
var
  AKey: String;
begin
  Result := nil;
  AKey := Format('%s_%d_%d_%d_%d', [char, Math.IfThen(fsStrikeOut in font.Style, 1, 0), Math.IfThen(fsBold in font.Style, 1, 0), Math.IfThen(fsItalic in font.Style, 1, 0), font.Size]);
  if Texts.ContainsKey(AKey) then Exit(Texts[AKey]);
end;

procedure setFreeTypeGlyph(char: Char; glyph: FT_Glyph; font: TFont);
var
  AKey: String;
begin
  AKey := Format('%s_%d_%d_%d_%d', [char, Math.IfThen(fsStrikeOut in font.Style, 1, 0), Math.IfThen(fsBold in font.Style, 1, 0), Math.IfThen(fsItalic in font.Style, 1, 0), font.Size]);
  if not Texts.ContainsKey(AKey) then
  begin
    Texts.Add(AKey, glyph);
  end;
end;

function getFreeTypeEmojiFace(emojiFontFile: String; font: TFont): FT_Face;
var
  AKey: String;
  face: FT_Face;
  matrix: FT_Matrix;
begin
  AKey := Format('%s_%d_%d', [emojiFontFile, font.Size, Math.IfThen(fsItalic in font.Style, 1, 0)]);
  if Faces.ContainsKey(AKey) then Exit(Faces[AKey]);

  Result := nil;
  if FT_New_Face(FreeTypeLibrary, pAnsiChar(AnsiString(emojiFontFile)), 0, @face) <> 0 then Exit;
  if FT_Set_Char_Size(face, 0, (Font.Size) shl 6, 96, 96) <> 0 then Exit;
  //if FT_Outline_Embolden(@(face^.glyph^.outline), 16) <> 0 then Exit;

  if fsItalic in font.Style then
  begin
    matrix.xx := $10000;
    matrix.xy := Round(0.3 * $10000); //0.5 倾斜度，越大就越斜
    matrix.yx := 0;
    matrix.yy := $10000;
    FT_Set_Transform(face, @matrix, 0);
  end;

  Result := face;
  Faces.Add(AKey, face);
end;

function getFreeTypeFace(normalFontFile, boldFontFile, heavyFontFile: String; font: TFont): FT_Face;
var
  AFontFile,
  AKey: String;
  face: FT_Face;
  AMemoryStream: TMemoryStream;
  matrix: FT_Matrix;
begin
  if fsStrikeOut in font.Style then
    AFontFile := heavyFontFile
  else if fsBold in font.Style then
    AFontFile := boldFontFile
  else
    AFontFile := normalFontFile;

  AKey := Format('%s_%d_%d', [AFontFile, font.Size, Math.IfThen(fsItalic in font.Style, 1, 0)]);
  if Faces.ContainsKey(AKey) then Exit(Faces[AKey]);

  Result := nil;

//  AMemoryStream := TMemoryStream.Create;
//  AMemoryStream.LoadFromFile(AFontFile);
//  AMemoryStream.Position := 0;
//  if FT_New_Memory_Face(FreeTypeLibrary, AMemoryStream.Memory, AMemoryStream.Size, 0, @face) <> 0 then Exit;

  if FT_New_Face(FreeTypeLibrary, pAnsiChar(AnsiString(AFontFile)), 0, @face) <> 0 then Exit;
  if FT_Set_Char_Size(face, 0, (Font.Size) shl 6, 96, 96) <> 0 then Exit;

  //if FT_Outline_Embolden(@(face^.glyph^.outline), 16) <> 0 then Exit;

  if fsItalic in font.Style then
  begin
    matrix.xx := $10000;
    matrix.xy := Round(0.3 * $10000); //0.5 倾斜度，越大就越斜
    matrix.yx := 0;
    matrix.yy := $10000;
    FT_Set_Transform(face, @matrix, 0);
  end;

  Result := face;
  Faces.Add(AKey, face);

end;

procedure initFreeType;
begin
  if not init_FreeType2 then Exit;
  if FT_Init_FreeType(@FreeTypeLibrary) <> 0 then Exit;
  //FT_Library_SetLcdFilter(FreeTypeLibrary, FT_LCD_FILTER_LIGHT);

  Faces := TDictionary<String, FT_Face>.Create;
  Texts := TDictionary<String, FT_Glyph>.Create;

  FreeTypeInited := True;
end;

procedure destroyFreeType;
var
  face: FT_Face;
  glyph: FT_Glyph;
begin
  if not FreeTypeInited then Exit;

  for glyph in Texts.Values do FT_Done_Glyph(glyph);
  FreeAndNil(Texts);

  for face in Faces.Values do FT_Done_Face(face);
  FreeAndNil(Faces);

  FT_Done_FreeType(FreeTypeLibrary);
  FreeTypeLibrary := nil;

  quit_FreeType2;
  FreeTypeInited := False;
end;

end.
