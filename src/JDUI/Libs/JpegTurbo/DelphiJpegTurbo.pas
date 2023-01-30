Unit DelphiJpegTurbo;

Interface

Uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, cgJpeg, U_threadChargement, generics.collections, U_threadChargement_2, Vcl.ComCtrls, Vcl.Mask,
  Vcl.Samples.Spin;

Type
  TForm1 = Class(TForm)
    Image1: TImage;
    Image2: TImage;
    Button1: TButton;
    Button2: TButton;
    Timer1: TTimer;
    CheckBox1: TCheckBox;
    Button3: TButton;
    Image3: TImage;
    Image4: TImage;
    Image5: TImage;
    Image6: TImage;
    Button4: TButton;
    ProgressBar1: TProgressBar;
    RxSpinEdit1: TSpinEdit;
    Image7: TImage;
    loadjpg: TButton;
    Procedure Button1Click(Sender: TObject);
    Procedure FormCreate(Sender: TObject);
    Procedure Button2Click(Sender: TObject);
    Procedure Timer1Timer(Sender: TObject);
    Procedure Button3Click(Sender: TObject);
    Procedure Button4Click(Sender: TObject);
    procedure loadjpgClick(Sender: TObject);
  Private
    { Déclarations privées }
  Public
    { Déclarations publiques }
  End;

Var
  Form1: TForm1;

Const
  TAILLE_BUFFER_LECTURE = 500 * 1024;
Function indexer(nomFichier: String; pb_avancement: TProgressBar): TList<integer>;

Implementation

Var
  cpt, oldcpt: integer;
{$R *.dfm}

Procedure TForm1.Button1Click(Sender: TObject);
Var
  jpg1, jpg2, jpg3, jpg4, jpg5, jpg6: TJpegImage;

Begin

  For cpt := 0 To 100000 Do
  Begin
    If CheckBox1.Checked Then
      exit;
    jpg1 := TJpegImage.Create;
    jpg2 := TJpegImage.Create;
    jpg3 := TJpegImage.Create;
    jpg4 := TJpegImage.Create;
    jpg5 := TJpegImage.Create;
    jpg6 := TJpegImage.Create;
    If (cpt Mod 2 = 0) Then
    Begin
      jpg1.LoadFromFile('1.jpg');
      jpg2.LoadFromFile('2.jpg');
      jpg3.LoadFromFile('1.jpg');
      jpg4.LoadFromFile('2.jpg');
      jpg5.LoadFromFile('1.jpg');
      jpg6.LoadFromFile('2.jpg');
    End Else Begin
      jpg1.LoadFromFile('2.jpg');
      jpg2.LoadFromFile('1.jpg');
      jpg3.LoadFromFile('2.jpg');
      jpg4.LoadFromFile('1.jpg');
      jpg5.LoadFromFile('2.jpg');
      jpg6.LoadFromFile('1.jpg');
    End;

    image1.Picture.Bitmap.Canvas.Draw(0, 0, jpg1);
    image2.Picture.Bitmap.Canvas.Draw(0, 0, jpg2);
    image3.Picture.Bitmap.Canvas.Draw(0, 0, jpg1);
    image4.Picture.Bitmap.Canvas.Draw(0, 0, jpg2);
    image5.Picture.Bitmap.Canvas.Draw(0, 0, jpg1);
    image6.Picture.Bitmap.Canvas.Draw(0, 0, jpg2);
    jpg1.Free;
    jpg2.Free;
    jpg3.Free;
    jpg4.Free;
    jpg5.Free;
    jpg6.Free;
    Application.ProcessMessages;

  End;
End;

Procedure TForm1.Button2Click(Sender: TObject);
Var
  thRenduArray_hdl: Array [0 .. 5] Of THandle;
  thRenduArray: Array [0 .. 5] Of TThreadChargement;
  imageArray: Array [0 .. 5] Of timage;
  fichierArray: Array [0 .. 5] Of String;
  cptIm: integer;
Begin
  imageArray[0] := image1;
  imageArray[1] := image2;
  imageArray[2] := image3;
  imageArray[3] := image4;
  imageArray[4] := image5;
  imageArray[5] := image6;

  For cpt := 0 To 100000 Do
  Begin
    If CheckBox1.Checked Then
      exit;
    If (cpt Mod 2 = 0) Then
    Begin
      fichierArray[0] := '1.jpg';
      fichierArray[1] := '2.jpg';
      fichierArray[2] := '1.jpg';
      fichierArray[3] := '2.jpg';
      fichierArray[4] := '1.jpg';
      fichierArray[5] := '2.jpg';
    End Else Begin
      fichierArray[0] := '2.jpg';
      fichierArray[1] := '1.jpg';
      fichierArray[2] := '2.jpg';
      fichierArray[3] := '1.jpg';
      fichierArray[4] := '2.jpg';
      fichierArray[5] := '1.jpg';
    End;
    For cptIm := 0 To 5 Do
    Begin

      thRenduArray[cptIm] := TThreadChargement.create(true);
      thRenduArray_hdl[cptIm] := thRenduArray[cptIm].Handle;
      thRenduArray[cptIm].Go(fichierArray[cptIm], imageArray[cptIm].Picture.Bitmap, imageArray[cptIm].Width, imageArray[cptIm].Height);
    End;
    WaitForMultipleObjects(6, @thRenduArray_hdl[0], true, 1000);
    Application.ProcessMessages;

  End;
End;

Procedure TForm1.Button3Click(Sender: TObject);
Var
  indexe: TList<integer>;
  currentCam: integer;
  imageJPEG: TJpegImage;
  fichierMjpeg: TFileStream;
  DonneesJpeg: Array [0 .. 5] Of TMemoryStream;
  thRenduArray: Array [0 .. 5] Of TThreadChargement2;
  thRenduArray_hdl: Array [0 .. 5] Of THandle;
  imageArray: Array [0 .. 5] Of timage;
  fichierIndexeStr: TextFile;
  intTmp: integer;
  rWait: Cardinal;
  numImage: Integer;
Begin
  indexe := TList<integer>.Create;
  AssignFile(fichierIndexeStr, 'index.txt');
  reset(fichierIndexeStr);
  While Not eof(fichierIndexeStr) Do
  Begin
    Readln(fichierIndexeStr, intTmp);
    indexe.Add(intTmp);
  End;
  CloseFile(fichierIndexeStr);

  While Not(CheckBox1.Checked) Do
  Begin

    fichierMjpeg := TFileStream.Create('mjpeg.mjpeg', fmOpenRead);
    For currentCam := 0 To 5 Do
      DonneesJpeg[currentCam] := TMemoryStream.Create;
    imageJPEG := TJPEGImage.Create;

    imageArray[0] := image1;
    imageArray[1] := image2;
    imageArray[2] := image3;
    imageArray[3] := image4;
    imageArray[4] := image5;
    imageArray[5] := image6;

    For numImage := 0 To 100 Do
    Begin
      cpt := numImage;
      If CheckBox1.Checked Then
        break;
      For currentCam := 0 To Round(RxSpinEdit1.Value)-1 Do
      Begin
        DonneesJpeg[currentCam].Seek(0, soBeginning);
        DonneesJpeg[currentCam].CopyFrom(fichierMjpeg, indexe[6 * numImage + currentCam]);
        thRenduArray[currentCam] := TThreadChargement2.create(true);
        thRenduArray_hdl[currentCam] := thRenduArray[currentCam].Handle;
        thRenduArray[currentCam].Go(DonneesJpeg[currentCam], imageArray[currentCam].Picture.Bitmap, imageArray[currentCam].Width,
          imageArray[currentCam].Height, Nil);
      End;
      WaitForMultipleObjects(Round(RxSpinEdit1.Value), @thRenduArray_hdl[0], true, 30000);
      Application.ProcessMessages;
    End;
    fichierMjpeg.Free;
    For currentCam := 0 To 5 Do
      DonneesJpeg[currentCam].Free;
    imageJPEG.Free;
  End;
  indexe.Free;
End;

Function indexer(nomFichier: String; pb_avancement: TProgressBar): TList<integer>;
Var
  fichierMjpeg: File;
  buffer: Array [0 .. TAILLE_BUFFER_LECTURE - 1] Of byte;
  nbOctetsLus: integer;
  currentChar: integer;
  oldCursorFile: integer;
  cursorFile: integer;
  pFinJpeg: integer;
  pDebutJpeg: integer;
  tailleJpeg: integer;
  tailleFichier: integer;
Begin
  If Not FileExists(nomFichier) Then
  Begin
    result := Nil;
    exit;
  End;
  result := TList<integer>.Create();
  currentChar := 0;
  oldCursorFile := 0;
  cursorFile := 0;
  pFinJpeg := 0;
  pDebutJpeg := 0;
  tailleJpeg := 0;
  AssignFile(fichierMjpeg, nomFichier);
  Reset(fichierMjpeg, 1);
  tailleFichier := FileSize(fichierMjpeg);
  If tailleFichier = 0 Then
  Begin
    exit;
  End;
  pb_avancement.Max := 100;
  Repeat
    blockread(fichierMjpeg, buffer, TAILLE_BUFFER_LECTURE, nbOctetsLus);
    // Read and display one byte at a time
    oldCursorFile := cursorFile;
    cursorFile := cursorFile + nbOctetsLus;
    For currentChar := 0 To nbOctetsLus - 1 Do
    Begin
      If (buffer[currentChar] = $FF) Then
      Begin
        If (currentChar < nbOctetsLus - 1) Then
        Begin
          If (buffer[currentChar + 1] = $D8) Then
          Begin
            pDebutJpeg := pFinJpeg;
            pFinJpeg := currentChar + oldCursorFile;
            tailleJpeg := pFinJpeg - pDebutJpeg;
            result.add(tailleJpeg);
          End;
        End Else Begin
          blockread(fichierMjpeg, buffer, 1, nbOctetsLus); // on lit 1 seul octet, juste pour voir si c'est le D8 du marqueur FFD8
          If nbOctetsLus = 1 Then
          Begin
            cursorFile := cursorFile + nbOctetsLus;
            If (buffer[0] = $D8) Then
            Begin
              pDebutJpeg := pFinJpeg;
              pFinJpeg := currentChar + oldCursorFile;
              tailleJpeg := pFinJpeg - pDebutJpeg;
              result.add(tailleJpeg);
              // frmSpider.Memo1.Lines.add('jpg de ' + inttostr(tailleJpeg) + ' trouve @' + inttostr(pDebutJpeg));
            End;
          End
        End
      End Else Begin
        // caratère quelconque, rien a faire pour l'instant.
      End;
    End;
    pb_avancement.Position := Round(100 * (cursorFile / tailleFichier));
    Application.ProcessMessages;
  Until nbOctetsLus = 0;

  tailleJpeg := tailleFichier - pFinJpeg;
  result.add(tailleJpeg);

  closefile(fichierMjpeg);
End;

Procedure TForm1.Button4Click(Sender: TObject);
Var
  FMJPEG, FJPEG: TFileStream;
  i, nbImage: integer;
  indexe: TList<integer>;
  cpt: integer;
  fichierIndexeStr: TextFile;
Begin
  // Concatener
  nbImage := 200;
  ProgressBar1.Position := 0;
  ProgressBar1.Max := nbImage;
  FMJPEG := TFileStream.Create('mjpeg.mjpeg', fmCreate);
  For i := 0 To nbImage Do

  Begin
    FJPEG := TFileStream.Create('1.jpg', fmOpenRead);
    FMJPEG.CopyFrom(FJPEG, FJPEG.Size);
    FJPEG.Free;

    FJPEG := TFileStream.Create('2.jpg', fmOpenRead);
    FMJPEG.CopyFrom(FJPEG, FJPEG.Size);
    FJPEG.Free;

    FJPEG := TFileStream.Create('1.jpg', fmOpenRead);
    FMJPEG.CopyFrom(FJPEG, FJPEG.Size);
    FJPEG.Free;

    FJPEG := TFileStream.Create('2.jpg', fmOpenRead);
    FMJPEG.CopyFrom(FJPEG, FJPEG.Size);
    FJPEG.Free;

    FJPEG := TFileStream.Create('1.jpg', fmOpenRead);
    FMJPEG.CopyFrom(FJPEG, FJPEG.Size);
    FJPEG.Free;

    ProgressBar1.Position := ProgressBar1.Position + 1;
  End;
  FMJPEG.Free;

  // indexer
  indexe := indexer('mjpeg.mjpeg', ProgressBar1);
  indexe.Delete(0);
  AssignFile(fichierIndexeStr, 'index.txt');
  rewrite(fichierIndexeStr);
  For cpt := 0 To indexe.Count - 1 Do
    WriteLn(fichierIndexeStr, inttostr(indexe[cpt]));
  CloseFile(fichierIndexeStr);
End;

Procedure TForm1.FormCreate(Sender: TObject);
Begin
  image1.Picture.Bitmap.SetSize(1600, 1200);
  image2.Picture.Bitmap.SetSize(1600, 1200);
  image3.Picture.Bitmap.SetSize(1600, 1200);
  image4.Picture.Bitmap.SetSize(1600, 1200);
  image5.Picture.Bitmap.SetSize(1600, 1200);
  image6.Picture.Bitmap.SetSize(1600, 1200);
End;

procedure TForm1.loadjpgClick(Sender: TObject);
var
  AJpg: TJpegImage;
  T1: Cardinal;
begin
  T1 := GetTickCount;
  AJpg := TJpegImage.Create;
  try
    AJpg.LoadFromFile('C:\Users\jin\Desktop\Mac_book_pro_retina129.jpg');
    Image7.Picture.Bitmap := AJpg;
  finally
    AJpg.Free;
    loadjpg.Caption := IntToStr(GetTickCount - T1);
  end;
end;

Procedure TForm1.Timer1Timer(Sender: TObject);
Begin
  caption := inttostr(cpt - oldcpt) + 'fps';
  oldcpt := cpt;
End;

End.
