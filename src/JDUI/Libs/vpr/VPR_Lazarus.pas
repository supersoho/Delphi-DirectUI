{ Diese Datei wurde automatisch von Lazarus erzeugt. Sie darf nicht bearbeitet 
  werden!
  Dieser Quelltext dient nur dem Übersetzen und Installieren des Packages.
 }

unit VPR_Lazarus; 

interface

uses
  GR32_PolygonsEx, GR32_VectorUtils, GR32_VectorGraphics, GR32_VPR,
  LazarusPackageIntf;

implementation

procedure Register; 
begin
end; 

initialization
  RegisterPackage('VPR_Lazarus', @Register); 
end.
