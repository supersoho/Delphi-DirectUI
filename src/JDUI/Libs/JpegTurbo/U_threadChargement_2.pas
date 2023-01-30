Unit U_threadChargement_2;

Interface

Uses
  System.Classes, winApi.Windows, Vcl.Graphics, System.SysUtils, cgJpeg, shareMem;

Type
  TThreadChargement2 = Class(TThread)
    Procedure Go(DonneesJpeg: TMemoryStream; bmpVignette: TBitmap; Width, Height: integer; imgBmp: TBitmap);
  Private
    FDonneesJpeg: TMemoryStream;
    FbmpVignette: TBitmap;
    FimgJpeg: TJpegImage;
    FimgBmp: TBitmap;
    FWidth, FHeight: integer;
    sansBmp: Boolean;
    { Déclarations privées }
  Protected
    Procedure Execute; Override;
  End;

Implementation

Procedure TThreadChargement2.Execute;
Var
  i: integer;
Begin
  FimgJpeg := TJpegImage.Create();
  FDonneesJpeg.Seek(0, soBeginning);
  FimgJpeg.LoadFromStream(FDonneesJpeg);
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

  If sansBmp Then
    FimgBmp := TBitmap.Create;

  FimgBmp.Assign(FimgJpeg);
  If sansBmp Then
    FimgBmp.free;

  FimgJpeg.Free;
End;

Procedure TThreadChargement2.Go(DonneesJpeg: TMemoryStream; bmpVignette: TBitmap; Width, Height: integer; imgBmp: TBitmap);
Begin
  FDonneesJpeg := DonneesJpeg;
  FbmpVignette := bmpVignette;
  FimgBmp := imgBmp;
  FWidth := Width;
  FHeight := Height;
  FreeOnTerminate := True;
  Priority := tpNormal;

  If Not(assigned(imgBmp)) Then
    sansBmp := True
  Else
    sansBmp := false;
  Resume;
End;

End.
