Unit U_threadChargement;

Interface

Uses
  System.Classes, winApi.Windows, Vcl.Graphics, System.SysUtils, cgJpeg, shareMem;

Type
  TThreadChargement = Class(TThread)
    Procedure Go(JpegFile: String; bmpVignette: TBitmap; Width, Height: integer);
  Private
    FJpegFile: String;
    FbmpVignette: TBitmap;
    FimgJpeg: TJpegImage;

    FWidth, FHeight: integer;
    sansBmp: Boolean;
    { Déclarations privées }
  Protected
    Procedure Execute; Override;
  End;

Implementation

Procedure TThreadChargement.Execute;
Var
  i: integer;
Begin

  FimgJpeg := TJpegImage.Create();
  FimgJpeg.LoadFromFile(FJpegFile);

  If (FWidth = 0) Or (FHeight = 0) Then
  Begin
    FWidth := FimgJpeg.Width;
    FHeight := FimgJpeg.Height;
  End;
  If assigned(FbmpVignette) Then
  Begin
    FbmpVignette.Canvas.Lock;
    FbmpVignette.SetSize(FWidth, FHeight);
    FbmpVignette.Canvas.StretchDraw(Rect(0, 0, FWidth, FHeight), FimgJpeg);
    FbmpVignette.Canvas.UnLock;
  End;

  FimgJpeg.Free;
End;

Procedure TThreadChargement.Go(JpegFile: String; bmpVignette: TBitmap; Width, Height: integer);
Begin
  FJpegFile := JpegFile;
  FbmpVignette := bmpVignette;
  FWidth := Width;
  FHeight := Height;
  FreeOnTerminate := True;
  Priority := tpNormal;

  Resume;
End;

End.
