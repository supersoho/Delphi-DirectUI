unit GR32_RasterizerEx;

{

 Some specific rasterizer,
 see source code for details.

 Version 1.0 (16 oct 2005), contributor Marc LAFON.
 - TBoxRasterizer = a rasterizer the draw quickly an heavly pixelized image.


 ***** BEGIN LICENSE BLOCK *****

 Version: MPL 1.1

 The contents of this file are subject to the Mozilla Public License Version
 1.1 (the "License"); you may not use this file except in compliance with
 the License. You may obtain a copy of the License at
 http://www.mozilla.org/MPL/

 Software distributed under the License is distributed on an "AS IS" basis,
 WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
 for the specific language governing rights and limitations under the
 License.

 ***** END LICENSE BLOCK *****
}

interface


{$I GR32.inc}

uses
  {$IFDEF CLX}
  Qt, Types, {$IFDEF LINUX}Libc, {$ELSE}Windows, {$ENDIF}
  {$ELSE}
  Windows,
  {$ENDIF}
  Classes, GR32, GR32_Rasterizers;

type
  { Conveninece rasteriser used to show preview of long operations
   (e.g. this resterizer can be used during dragdrop operations)
  }
  TBoxRasterizer = class(TRasterizer)
  private
    FBoxSize: Integer;
    procedure SetBoxSize(const Value: Integer);
  protected
    procedure DoRasterize(Dst: TBitmap32; DstRect: TRect); override;
  public
    constructor Create; override;
  published
    {Determine the size, in pixel, of the 'pixel' }
    property BoxSize: Integer read FBoxSize write SetBoxSize default 4;
  end;


implementation

uses
  GR32_Resamplers,Math;

type
  TThreadPersistentAccess = class(TThreadPersistent);

{ TBoxRasterizer }

constructor TBoxRasterizer.Create;
begin
  inherited;
  FBoxSize := 4;
end;

procedure TBoxRasterizer.DoRasterize(Dst: TBitmap32; DstRect: TRect);
var
  I, J, B: Integer;
  GetSample: TGetSampleInt;
begin
  GetSample := Sampler.GetSampleInt;
  Dst.BeginUpdate;
//  W := DstRect.Right - DstRect.Left;
//  H := DstRect.Bottom - DstRect.Top;
  J := DstRect.Top;
  while J < DstRect.Bottom do
  begin
    I := DstRect.Left;
    B := Min(J + FBoxSize, DstRect.Bottom);
    while I < DstRect.Right - FBoxSize do
    begin
      Dst.FillRect(I, J, I + FBoxSize, B, GetSample(I, J));
      Inc(I, FBoxSize);
    end;
    Dst.FillRect(I, J, DstRect.Right, B, GetSample(I, J));
    Inc(J, FBoxSize);
  end;
  if (TThreadPersistentAccess(Dst).UpdateCount = 0) and Assigned(Dst.OnAreaChanged) then
    Dst.OnAreaChanged(Dst, DstRect, AREAINFO_RECT);
  Dst.EndUpdate;
end;

procedure TBoxRasterizer.SetBoxSize(const Value: Integer);
begin
  if (FBoxSize <> Value) and (Value > 1) then
  begin
    FBoxSize := Value;
    Changed;
  end;
end;

end.
