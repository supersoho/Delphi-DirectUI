unit ExifInfo;

// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// XX  Exif情報取得コンポーネント TExifInfo  Version 3.0                      XX
// XX                                    Copyright(c) みず                    XX
// XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

interface

uses
  Classes, SysUtils, Math, Vcl.Graphics, Vcl.Imaging.jpeg;

const
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %% 定数定義                                                            %%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  // TIFF IFD タグ
  Exif_SOI = $FFD8;
  Exif_SOF0 = $FFC0;
  Exif_APP1 = $FFE1;
  Exif_ImageWidth = $0100;
  Exif_ImageLength = $0101;
  Exif_BitsPerSample = $0102;
  Exif_Compression = $0103;
  Exif_Photometric = $0106;
  Exif_Orientation = $0112;
  Exif_SamplesPerPixel = $0115;
  Exif_PlanarConfiguration = $011C;
  Exif_YCbCrSubSampling = $0212;
  Exif_YCbCrPositioning = $0213;
  Exif_XResolution = $011A;
  Exif_YResolution = $011B;
  Exif_ResolutionUnit = $0128;
  Exif_StripOffsets = $0111;
  Exif_RowsPerStrip = $0116;
  Exif_StripByteCounts = $0117;
  Exif_JPEGInterchangeFormat = $0201;
  Exif_JPEGInterchangeFormatLength = $0202;
  Exif_TransferFunction = $012D;
  Exif_WhitePoint = $013E;
  Exif_PrimaryChromaticities = $013F;
  Exif_YCbCrCoefficients = $0211;
  Exif_ReferenceBlackWhite = $0214;
  Exif_DateTime = $0132;
  Exif_ImageDescription = $010E;
  Exif_Make = $010F;
  Exif_Model = $0110;
  Exif_Software = $0131;
  Exif_Artist = $013B;
  Exif_Copyright = $8298;
  Exif_ExifIFDPointer = $8769;
  Exif_GPSInfoIFDPointer = $8825;

  // Exif IFD タグ
  Exif_ExifVersion = $9000;
  Exif_FlashPixVersion = $A000;
  Exif_ColorSpace = $A001;
  Exif_ComponentsConfiguration = $9101;
  Exif_CompressedBitsPerPixel = $9102;
  Exif_PixelXDimension = $A002;
  Exif_PixelYDimension = $A003;
  Exif_MakerNote = $927C;
  Exif_UserComment = $9286;
  Exif_RelatedSoundFile = $A004;
  Exif_DateTimeOriginal = $9003;
  Exif_DateTimeDigitized = $9004;
  Exif_SubSecTime = $9290;
  Exif_SubSecTimeOriginal = $9291;
  Exif_SubSecTimeDigitized = $9292;
  Exif_ExposureTime = $829A;
  Exif_FNumber = $829D;
  Exif_ExposureProgram = $8822;
  Exif_SpectralSensitivity = $8824;
  Exif_ISOSpeedRatings = $8827;
  Exif_OECF = $8828;
  Exif_ShutterSpeedValue = $9201;
  Exif_ApertureValue = $9202;
  Exif_BrightnessValue = $9203;
  Exif_ExposureBiasValue = $9204;
  Exif_MaxApertureValue = $9205;
  Exif_SubjectDistance = $9206;
  Exif_MeteringMode = $9207;
  Exif_LightSource = $9208;
  Exif_Flash = $9209;
  Exif_FocalLength = $920A;
  Exif_FlashEnergy = $A20B;
  Exif_SpatialFrequencyResponse = $A20C;
  Exif_FocalPlaneXResolution = $A20E;
  Exif_FocalPlaneYResolution = $A20F;
  Exif_FocalPlaneResolutionUnit = $A210;
  Exif_SubjectLocation = $A214;
  Exif_ExposureIndex = $A215;
  Exif_SensingMethod = $A217;
  Exif_FileSource = $A300;
  Exif_SceneType = $A301;
  Exif_CFAPattern = $A302;
  Exif_InteroperabilityIFDPointer = $A005;

  // GPS IFD タグ
  Exif_GPSVersionID = $0000;
  Exif_GPSLatitudeRef = $0001;
  Exif_GPSLatitude = $0002;
  Exif_GPSLongitudeRef = $0003;
  Exif_GPSLongitude = $0004;
  Exif_GPSAltitudeRef = $0005;
  Exif_GPSAltitude = $0006;
  Exif_GPSTimeStamp = $0007;
  Exif_GPSSatellites = $0008;
  Exif_GPSStatus = $0009;
  Exif_GPSMeasureMode = $000A;
  Exif_GPSDOP = $000B;
  Exif_GPSSpeedRef = $000C;
  Exif_GPSSpeed = $000D;
  Exif_GPSTrackRef = $000E;
  Exif_GPSTrack = $000F;
  Exif_GPSImgDirectionRef = $0010;
  Exif_GPSImgDirection = $0011;
  Exif_GPSMapDatum = $0012;
  Exif_GPSDestLatitudeRef = $0013;
  Exif_GPSDestLatitude = $0014;
  Exif_GPSDestLongitudeRef = $0015;
  Exif_GPSDestLongitude = $0016;
  Exif_GPSDestBearingRef = $0017;
  Exif_GPSDestBearing = $0018;
  Exif_GPSDestDistanceRef = $0019;
  Exif_GPSDestDistance = $001A;

  // Interoperability IFD タグ
  Exif_InteroperabilityIndex = $0001;
  Exif_InteroperabilityVersion = $0002;
  Exif_RelatedImageFileFormat = $1000;
  Exif_RelatedImageWidth = $1001;
  Exif_RelatedImageLength = $1002;

  // エラーコード
  ERR_FILENOTEXIST = -1;
  ERR_NOTEXIF = -2;
  ERR_USERCOMMENT = -3;
  ERR_ASCIIONLY = -4;
  ERR_FAILEDREAD = -5;
  ERR_OUTOFRANGE = -6;
  ERR_TAGNOTFOUND = -7;
  ERR_FAILEDSTRTODATE = -8;

resourcestring
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %% リソース文字列定義                                                  %%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // 文字列値
  exstrAther = 'その他';
  exstrReserved = '';
  exstrUndefined = '未定義';
  exstrUnknown = '';

type
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %% 型定義                                                              %%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  // バイト並び
  TExifByteOrder = (boII = $4949, boMM = $4D4D);
  // データ記録形式
  TExifFormat = (efUByte = 1, efAscii, efUShort, efULong, efURational, efByte,
                 efUndefined, efShort, efLong, efRational, efFloat, efDFloat);
  // 分数データ型
  TSignedRational = record
    Namerator: LongInt;
    Denominator: LongInt;
  end;
  PSignedRational = ^TSignedRational;
  
  TUnsignedRational = record
    Namerator: LongWord;
    Denominator: LongWord;
  end;
  PUnsignedRational = ^TUnsignedRational;
  // 画像方向
  TExifOrientation = (eoReserved, eoTopLeft, eoTopRight, eoBottomRight,
                      eoBottomLeft, eoLeftTop, eoRightTop, eoRightBottom,
                      eoLeftBottom);
  // 画像データ並び
  TExifPlanarConfiguration = (pcReserved, pcChunkey, pcPlanar);
  // サブサンプリング
  TExifSubSampling = (ssReserved, ss422, ss420);
  // ポジショニング
  TExifYCbCrPositioning = (epReserved, epCentered, epCosited);
  // ユーザコメントの記録方法
  TExifUserCommentStyle = (ucAscii, ucJIS, ucUnicode, ucUndefined, ucUnknown);
  // ストロボのリターン
  TExifFlashReturn = (frNoDetector, frUndetect, frDetect, frReserved);
  // IFD
  TExifIFD = (eiTIFF, eiExif, eiGPS, eiInteroperability);

  // イベント型
  TExifReadErrorEvent = procedure(Sender: TObject; ErrCode: Integer;
                                  var AllowError: Boolean) of object;

  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %% クラス定義                                                          %%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  // %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  TEntryItems = class;
  TExifInfo = class;

  // ########################################################################
  // ## class: ExifErrorクラス                                           ####
  // ########################################################################
  EExifError = class(Exception)
  public
    // ***********************************Public**
    // =================================Method==
    constructor Create(const Msg: string);
  end;

  // ########################################################################
  // ## class: 分数値                                                    ####
  // ########################################################################
  TExifRational = class(TPersistent)
  private
    // **********************************Private**
    // ==================================Field==
    FDenominator: Integer;
    FNamerator: Integer;
    FOwner: TExifInfo;
    // =================================Method==
    // -------------------------------Access--
    function GetText: string;
    function GetValue: Double;
  protected
    // ********************************Protected**
    // =================================Method==
    procedure Clear;
    procedure SetSingedValues(ANamerator, ADenominator: Integer); overload;
    procedure SetSingedValues(pRational: PSignedRational); overload;
    procedure SetValues(ANamerator, ADenominator: LongWord); overload;
    procedure SetValues(pRational: PUnsignedRational); overload;
  public
    // ***********************************Public**
    // =================================Method==
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    // ===============================Property==
    property Denominator: Integer read FDenominator;
    property Namerator: Integer read FNamerator;
    property Text: string read GetText;
    property Value: Double read GetValue;
  end;

  // ########################################################################
  // ## class: TEntryItem                                                ####
  // ########################################################################
  TEntryItem = class(TCollectionItem)
  private
    // **********************************Private**
    // ==================================Field==
    FDataCount: Integer;
    FDataOffset: Cardinal;
    FDatas: TList;
    FExifDataCount: Cardinal;
    FFormat: TExifFormat;
    FIFD: TExifIFD;
    FOffset: Cardinal;
    FPosition: Cardinal;
    FTag: Word;
    // =================================Method==
    procedure CopyDatas(Source: TEntryItem);
    // -------------------------------Access--
    function GetDatas(Index: Integer): Pointer;
    function GetEntrySize: Word;
    function GetExif: TExifInfo;
    function GetIFDNumber: TExifIFD;
  protected
    // ********************************Protected**
    // =================================Method==
    procedure AddPointer(P: Pointer; AFormat: TExifFormat);
    procedure AddString(const S: string);
    procedure DeleteData(Index: Integer); virtual;
    procedure ReadExifData(Stream: TStream); virtual;
    function SaveEntry(Stream: TStream): LongWord;
    procedure SetTag(ATag: Word);
    procedure SetULongData(Index: Integer; Value: LongWord);
    function WriteData(Stream: TStream; Order: TExifByteOrder): Integer;
    // ===============================Property==
    property Data[Index: Integer]: Pointer read GetDatas;
    property DataOffset: Cardinal read FDataOffset write FDataOffset;
    property Exif: TExifInfo read GetExif;
    property IFD: TExifIFD read FIFD write FIFD;
    property Position: Cardinal read FPosition write FPosition;
  public
    // ***********************************Public**
    // =================================Method==
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure Clear;
    function GetStringData: string;
    function GetUByteData(Index: Integer): Byte;
    function GetULongData(Index: Integer): LongWord;
    function GetUShortData(Index: Integer): Word;
    procedure LoadFromStream(Stream: TStream); virtual;
    // ===============================Property==
    property DataCount: Integer read FDataCount;
    property EntrySize: Word read GetEntrySize;
    property IFDNumber: TExifIFD read GetIFDNumber;
    property Format: TExifFormat read FFormat;
    property Tag: Word read FTag;
  end;

  // ########################################################################
  // ## class: TEntryItems                                               ####
  // ########################################################################
  TEntryItems = class(TCollection)
  private
    // **********************************Private**
    // ==================================Field==
    FCardinalPoint: Int64;
    FOwner: TExifInfo;
    // =================================Method==
    function IFDSize(AIFD: TExifIFD): Word;
    // -------------------------------Access--
    function GetDataSize: Word;
    function GetItems(Index: Integer): TEntryItem;
    procedure SetItems(Index: Integer; const Value: TEntryItem);
  protected
    // ********************************Protected**
    // =================================Method==
    function AddTag(ATag: Word): TEntryItem;
    function GetOwner: TPersistent; override;
    procedure SaveToStream(Stream: TStream; NextExist: Boolean);
    procedure WriteStringData(ATag: Word; AIFD: TExifIFD; const S: string);
    // ===============================Property==
    property CardinalPoint: Int64 read FCardinalPoint write FCardinalPoint;
  public
    // ***********************************Public**
    // =================================Method==
    constructor Create(AOwner: TExifInfo; AItemClass: TCollectionItemClass);
    procedure Assign(Source: TPersistent); override;
    function Add: TEntryItem;
    function IFDEntryCount(AIFD: TExifIFD): Integer;
    function IndexOfTag(ATag: Word; AIFD: TExifIFD): Integer;
    // ===============================Property==
    property DataSize: Word read GetDataSize;
    property Items[Index: Integer]: TEntryItem read GetItems
        write SetItems; default;
  end;

  // ########################################################################
  // ## class: TExifInfo                                                 ####
  // ########################################################################
  TExifInfo = class(TComponent)
  private
    // **********************************Private**
    // ==================================Field==
    FApp1Position: Int64;
    FByteOrder: TExifByteOrder;
    FDoneAnalyzeJpeg: Boolean;
    FEntrys: TEntryItems;
    FImageFileName: TFileName;
    FJpegHeight: Integer;
    FJpegWidth: Integer;
    FOffsetCardinalPoint: Int64;
    FOnError: TExifReadErrorEvent;
    FOnUpdate: TNotifyEvent;
    FRationalValue: TExifRational;
    FSearchBytes: Integer;
    FThmEntrys: TEntryItems;
    // =================================Method==
    function AnalyzeExif: Boolean;
    function AnalyzeIFD(Stream: TStream; const IFDNumber: TExifIFD): Cardinal;
    procedure AnalyzeJpegHeader;
    function AnalyzeThmIFD(Stream: TStream; const IFDNumber: TExifIFD): Cardinal;
    function AnalyzeTiffHeader(Stream: TStream): Cardinal;
    procedure ExtractThumbnail(const FileName: string; Thumb: TJPEGImage);
    function FindApp1Marker(const FileName: string): Int64;
    function GetSRatioValue(ATag: Word; AIFD: TExifIFD): TExifRational;
    function GetTagPointer(ATag: Word; AIFD: TExifIFD;
        AllowError: Boolean): Pointer;
    function GetTagString(ATag: Word; AIFD: TExifIFD;
        AllowError: Boolean): string;
    function GetTagUByte(ATag: Word; DataIndex: Integer; AIFD: TExifIFD;
        AllowError: Boolean): Byte;
    function GetTagULong(ATag: Word; DataIndex: Integer; AIFD: TExifIFD;
        AllowError: Boolean): LongWord;
    function GetTagUShort(ATag: Word; DataIndex: Integer; AIFD: TExifIFD;
        AllowError: Boolean): Word;
    function GetURatioValue(ATag: Word; AIFD: TExifIFD): TExifRational;
    procedure SeekExifHeader(Stream: TStream);
    // -------------------------------Access--
    function GetApertureValue: TExifRational;
    function GetArtist: string;
    function GetBitsPerSample(Index: Integer): Integer;
    function GetBrightnessValue: TExifRational;
    function GetColorSpace: Integer;
    function GetColorSpaceText: string;
    function GetComponentsConfiguration(Index: Integer): Integer;
    function GetComponentsConfigurationText: string;
    function GetCompressedBitsPerPixel: TExifRational;
    function GetCompression: Integer;
    function GetCompressionText: string;
    function GetCopyright: string;
    function GetDateTime: TDateTime;
    function GetDateTimeDigitized: TDateTime;
    function GetDateTimeDigitizedText: string;
    function GetDateTimeOriginal: TDateTime;
    function GetDateTimeOriginalText: string;
    function GetDateTimeText: string;
    function GetExifIFDPointer: LongWord;
    function GetExifVersion: string;
    function GetExposureBiasValue: TExifRational;
    function GetExposureIndex: TExifRational;
    function GetExposureProgram: Integer;
    function GetExposureProgramText: string;
    function GetExposureTime: TExifRational;
    function GetFileSource: Integer;
    function GetFlash: Boolean;
    function GetFlashEnergy: TExifRational;
    function GetFlashPixVersion: string;
    function GetFlashReturn: TExifFlashReturn;
    function GetFlashValue: Integer;
    function GetFNumber: TExifRational;
    function GetFocalLength: TExifRational;
    function GetFocalPlaneResolutionUnit: Integer;
    function GetFocalPlaneResolutionUnitText: string;
    function GetFocalPlaneXResolution: TExifRational;
    function GetFocalPlaneYResolution: TExifRational;
    function GetGPSAltitude: TExifRational;
    function GetGPSAltitudeRef: Integer;
    function GetGPSDestBearing: TExifRational;
    function GetGPSDestBearingRef: Char;
    function GetGPSDestDistance: TExifRational;
    function GetGPSDestDistanceRef: Char;
    function GetGPSDestLatitude(Index: Integer): TExifRational;
    function GetGPSDestLatitudeRef: Char;
    function GetGPSDestLongitude(Index: Integer): TExifRational;
    function GetGPSDestLongitudeRef: Char;
    function GetGPSDOP: TExifRational;
    function GetGPSImgDirection: TExifRational;
    function GetGPSImgDirectionRef: Char;
    function GetGPSInfoIFDPointer: LongWord;
    function GetGPSLatitude(Index: Integer): TExifRational;
    function GetGPSLatitudeRef: Char;
    function GetGPSLongitude(Index: Integer): TExifRational;
    function GetGPSLongitudeRef: Char;
    function GetGPSMapDatum: string;
    function GetGPSMeasureMode: Char;
    function GetGPSSatellites: string;
    function GetGPSSpeed: TExifRational;
    function GetGPSSpeedRef: Char;
    function GetGPSStatus: Char;
    function GetGPSTimeStamp(Index: Integer): TExifRational;
    function GetGPSTrack: TExifRational;
    function GetGPSTrackRef: Char;
    function GetGPSVersionID(Index: Integer): Integer;
    function GetImageDescription: string;
    function GetImageLength: Integer;
    function GetImageWidth: Integer;
    function GetInteroperabilityIFDPointer: LongWord;
    function GetInteroperabilityIndex: string;
    function GetInteroperabilityVersion: string;
    function GetISOSpeedRatingCount: Integer;
    function GetISOSpeedRatings(Index: Integer): Integer;
    function GetLightSource: Integer;
    function GetLightSourceText: string;
    function GetMake: string;
    function GetMaxApatureValue: TExifRational;
    function GetMeteringMode: Integer;
    function GetMeteringModeText: string;
    function GetMinFNumber: Double;
    function GetModel: string;
    function GetOrientation: TExifOrientation;
    function GetPhotometric: Integer;
    function GetPhtometricText: string;
    function GetPixelXDimension: Integer;
    function GetPixelYDimension: Integer;
    function GetPlanarConfiguration: TExifPlanarConfiguration;
    function GetPrimaryChromaticities(Index: Integer): TExifRational;
    function GetReferenceBlackWhite(Index: Integer): TExifRational;
    function GetResolutionUnit: Integer;
    function GetResolutionUnitText: string;
    function GetRelatedImageFileFormat: string;
    function GetRelatedImageLength: Integer;
    function GetRelatedImageWidth: Integer;
    function GetRelatedSoundFile: string;
    function GetRowsPerStrip: Integer;
    function GetSamplesPerPixel: Integer;
    function GetSceneType: Integer;
    function GetSensingMethod: Integer;
    function GetSensingMethodText: string;
    function GetShutterSpeedTime: Double;
    function GetShutterSpeedValue: TExifRational;
    function GetSoftware: string;
    function GetSpectralSensivity: string;
    function GetStripByteCounts(Index: Integer): Integer;
    function GetStripByteCountsCount: Integer;
    function GetStripOffsets(Index: Integer): Cardinal;
    function GetStripOffsetsCount: Integer;
    function GetStripsPerImage: Integer;
    function GetSubjectDistance: TExifRational;
    function GetSubjectLocation(const Index: Integer): Integer;
    function GetSubsecTime: Integer;
    function GetSubsecTimeDigitized: Integer;
    function GetSubsecTimeOriginal: Integer;
    function GetThmArtist: string;
    function GetThmBitsPerSample(Index: Integer): Integer;
    function GetThmCompression: Integer;
    function GetThmCompressionText: string;
    function GetThmCopyright: string;
    function GetThmDateTime: TDateTime;
    function GetThmDateTimeText: string;
    function GetThmExifIFDPointer: LongWord;
    function GetThmImageDescription: string;
    function GetThmImageLength: Integer;
    function GetThmImageWidth: Integer;
    function GetThmInteroperabilityIFDPointer: LongWord;
    function GetThmInteroperabilityIndex: string;
    function GetThmJPEGInterchangeFormat: Cardinal;
    function GetThmJPEGInterchangeFormatLength: Cardinal;
    function GetThmMake: string;
    function GetThmModel: string;
    function GetThmOrientation: TExifOrientation;
    function GetThmPhotometric: Integer;
    function GetThmPhotometricText: string;
    function GetThmPlanarConfiguration: TExifPlanarConfiguration;
    function GetThmPrimaryChromaticities(Index: Integer): TExifRational;
    function GetThmResolutionUnit: Integer;
    function GetThmResolutionUnitText: string;
    function GetThmRowsPerStrip: Integer;
    function GetThmSamplesPerPixel: Integer;
    function GetThmSoftware: string;
    function GetThmStripByteCounts(Index: Integer): Integer;
    function GetThmStripByteCountsCount: Integer;
    function GetThmStripOffsets(Index: Integer): Cardinal;
    function GetThmStripOffsetsCount: Integer;
    function GetThmTransferFunction(Index: Integer): Word;
    function GetThmWhitePoint(Index: Integer): TExifRational;
    function GetThmXResolution: TExifRational;
    function GetThmYCbCrCoefficients(Index: Integer): TExifRational;
    function GetThmYCbCrPositioning: TExifYCbCrPositioning;
    function GetThmYCbCrSubSampling: TExifSubSampling;
    function GetThmYResolution: TExifRational;
    function GetTransferFunction(Index: Integer): Word;
    function GetUserComment: WideString;
    function GetUserCommentStyle: TExifUserCommentStyle;
    function GetWhitePoint(Index: Integer): TExifRational;
    function GetXResolution: TExifRational;
    function GetYCbCrCoefficients(Index: Integer): TExifRational;
    function GetYCbCrPositioning: TExifYCbCrPositioning;
    function GetYCbCrSubSampling: TExifSubSampling;
    function GetYResolution: TExifRational;
    procedure SetArtist(const Value: string);
    procedure SetCopyright(const Value: string);
    procedure SetDateTime(const Value: TDateTime);
    procedure SetDateTimeDigitized(const Value: TDateTime);
    procedure SetDateTimeDigitizedText(const Value: string);
    procedure SetDateTimeOriginal(const Value: TDateTime);
    procedure SetDateTimeOriginalText(const Value: string);
    procedure SetDateTimeText(const Value: string);
    procedure SetFileSource(const Value: Integer);
    procedure SetImageDescription(const Value: string);
    procedure SetImageFileName(const Value: TFileName);
    procedure SetMake(const Value: string);
    procedure SetModel(const Value: string);
    procedure SetSceneType(const Value: Integer);
    procedure SetSoftware(const Value: string);
    procedure SetSubsecTime(const Value: Integer);
    procedure SetSubsecTimeOriginal(const Value: Integer);
    procedure SetSubsecTimeDigitized(const Value: Integer);
    procedure SetThmArtist(const Value: string);
    procedure SetThmCopyright(const Value: string);
    procedure SetThmDateTime(const Value: TDateTime);
    procedure SetThmDateTimeText(const Value: string);
    procedure SetThmImageDescription(const Value: string);
    procedure SetThmMake(const Value: string);
    procedure SetThmModel(const Value: string);
    procedure SetThmSoftware(const Value: string);
    procedure SetUserComment(const Value: WideString);
  protected
    // ********************************Protected**
    // =================================Method==
    procedure ObjectDeletion(AObject: TObject); virtual;
    // --------------------------------Event--
    procedure DoError(ACode: Integer); dynamic;
    procedure DoUpdate; virtual;
    // ===============================Property==
    property StripsPerImage: Integer read GetStripsPerImage;
  public
    // ***********************************Public**
    // =================================Method==
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function CopyFromMakerNote(Stream: TStream): Int64;
    procedure GetThumbnail(Thumb: TBitmap); overload;
    procedure GetThumbnail(Thumb: TJPEGImage); overload;
    function IsExif(const FileName: string): Boolean;
    function TagExists(ATag: Word; AIFD: TExifIFD): Boolean;
    function ThmTagExists(ATag: Word; AIFD: TExifIFD): Boolean;
    function WriteExif(const DestFileName: TFileName;
        IncludeThumbnail: Boolean): Boolean;
    function WriteToMakerNote(Stream: TStream; ASize: Int64): Int64;
    procedure WriteUserComment(const Comment: string;
        Code: TExifUserCommentStyle);
    // ===============================Property==
    property ApertureValue: TExifRational read GetApertureValue;
    property Artist: string read GetArtist write SetArtist;
    property BitsPerSample[Index: Integer]: Integer read GetBitsPerSample;
    property BrightnessValue: TExifRational read GetBrightnessValue;
    property ByteOrder: TExifByteOrder read FByteOrder;
    property ColorSpace: Integer read GetColorSpace;
    property ColorSpaceText: string read GetColorSpaceText;
    property ComponentsConfiguration[Index: Integer]: Integer
        read GetComponentsConfiguration;
    property ComponentsConfigurationText: string
        read GetComponentsConfigurationText;
    property CompressedBitsPerPixel: TExifRational
        read GetCompressedBitsPerPixel;
    property Compression: Integer read GetCompression;
    property CompressionText: string read GetCompressionText;
    property Copyright: string read GetCopyright write SetCopyright;
    property DateTime: TDateTime read GetDateTime write SetDateTime;
    property DateTimeDigitized: TDateTime read GetDateTimeDigitized
        write SetDateTimeDigitized;
    property DateTimeDigitizedText: string read GetDateTimeDigitizedText
        write SetDateTimeDigitizedText;
    property DateTimeOriginal: TDateTime read GetDateTimeOriginal
        write SetDateTimeOriginal;
    property DateTimeOriginalText: string read GetDateTimeOriginalText
        write SetDateTimeOriginalText;
    property DateTimeText: string read GetDateTimeText write SetDateTimeText;
    property ExifIFDPointer: LongWord read GetExifIFDPointer;
    property ExifVersion: string read GetExifVersion;
    property ExposureBiasValue: TExifRational read GetExposureBiasValue;
    property ExposureIndex: TExifRational read GetExposureIndex;
    property ExposureProgram: Integer read GetExposureProgram;
    property ExposureProgramText: string read GetExposureProgramText;
    property ExposureTime: TExifRational read GetExposureTime;
    property FileSource: Integer read GetFileSource write SetFileSource;
    property Flash: Boolean read GetFlash;
    property FlashEnergy: TExifRational read GetFlashEnergy;
    property FlashPixVersion: string read GetFlashPixVersion;
    property FlashReturn: TExifFlashReturn read GetFlashReturn;
    property FlashValue: Integer read GetFlashValue;
    property FNumber: TExifRational read GetFNumber;
    property FocalLength: TExifRational read GetFocalLength;
    property FocalPlaneResolutionUnit: Integer
        read GetFocalPlaneResolutionUnit;
    property FocalPlaneResolutionUnitText: string
        read GetFocalPlaneResolutionUnitText;
    property FocalPlaneXResolution: TExifRational
        read GetFocalPlaneXResolution;
    property FocalPlaneYResolution: TExifRational
        read GetFocalPlaneYResolution;
    property GPSAltitude: TExifRational read GetGPSAltitude;
    property GPSAltitudeRef: Integer read GetGPSAltitudeRef;
    property GPSDestBearing: TExifRational read GetGPSDestBearing;
    property GPSDestBearingRef: Char read GetGPSDestBearingRef;
    property GPSDestDistance: TExifRational read GetGPSDestDistance;
    property GPSDestDistanceRef: Char read GetGPSDestDistanceRef;
    property GPSDestLatitude[Index: Integer]: TExifRational
        read GetGPSDestLatitude;
    property GPSDestLatitudeRef: Char read GetGPSDestLatitudeRef;
    property GPSDestLongitude[Index: Integer]: TExifRational
        read GetGPSDestLongitude;
    property GPSDestLongitudeRef: Char read GetGPSDestLongitudeRef;
    property GPSDOP: TExifRational read GetGPSDOP;
    property GPSImgDirection: TExifRational read GetGPSImgDirection;
    property GPSImgDirectionRef: Char read GetGPSImgDirectionRef;
    property GPSInfoIFDPointer: LongWord read GetGPSInfoIFDPointer;
    property GPSLatitude[Index: Integer]: TExifRational read GetGPSLatitude;
    property GPSLatitudeRef: Char read GetGPSLatitudeRef;
    property GPSLongitude[Index: Integer]: TExifRational read GetGPSLongitude;
    property GPSLongitudeRef: Char read GetGPSLongitudeRef;
    property GPSMapDatum: string read GetGPSMapDatum;
    property GPSMeasureMode: Char read GetGPSMeasureMode;
    property GPSSatellites: string read GetGPSSatellites;
    property GPSSpeed: TExifRational read GetGPSSpeed;
    property GPSSpeedRef: Char read GetGPSSpeedRef;
    property GPSStatus: Char read GetGPSStatus;
    property GPSTimeStamp[Index: Integer]: TExifRational read GetGPSTimeStamp;
    property GPSTrack: TExifRational read GetGPSTrack;
    property GPSTrackRef: Char read GetGPSTrackRef;
    property GPSVersionID[Index: Integer]: Integer read GetGPSVersionID;
    property ImageDescription: string read GetImageDescription
        write SetImageDescription;
    property ImageLength: Integer read GetImageLength;
    property ImageWidth: Integer read GetImageWidth;
    property InteroperabilityIFDPointer: LongWord
        read GetInteroperabilityIFDPointer;
    property InteroperabilityIndex: string read GetInteroperabilityIndex;
    property InteroperabilityVersion: string read GetInteroperabilityVersion;
    property ISOSpeedRatingCount: Integer read GetISOSpeedRatingCount;
    property ISOSpeedRatings[Index: Integer]: Integer
        read GetISOSpeedRatings;
    property LightSource: Integer read GetLightSource;
    property LightSourceText: string read GetLightSourceText;
    property Make: string read GetMake write SetMake;
    property MaxApatureValue: TExifRational read GetMaxApatureValue;
    property MeteringMode: Integer read GetMeteringMode;
    property MeteringModeText: string read GetMeteringModeText;
    property MinFNumber: Double read GetMinFNumber;
    property Model: string read GetModel write SetModel;
    property Orientation: TExifOrientation read GetOrientation;
    property Photometric: Integer read GetPhotometric;
    property PhotometricText: string read GetPhtometricText;
    property PixelXDimension: Integer read GetPixelXDimension;
    property PixelYDimension: Integer read GetPixelYDimension;
    property PlanarConfiguration: TExifPlanarConfiguration
        read GetPlanarConfiguration;
    property PrimaryChromaticities[Index: Integer]: TExifRational
        read GetPrimaryChromaticities;
    property ReferenceBlackWhite[Index: Integer]: TExifRational
        read GetReferenceBlackWhite;
    property ResolutionUnit: Integer read GetResolutionUnit;
    property ResolutionUnitText: string read GetResolutionUnitText;
    property RelatedImageFileFormat: string read GetRelatedImageFileFormat;
    property RelatedImageLength: Integer read GetRelatedImageLength;
    property RelatedImageWidth: Integer read GetRelatedImageWidth;
    property RelatedSoundFile: string read GetRelatedSoundFile;
    property RowsPerStrip: Integer read GetRowsPerStrip;
    property SamplesPerPixel: Integer read GetSamplesPerPixel;
    property SceneType: Integer read GetSceneType write SetSceneType;
    property SensingMethod: Integer read GetSensingMethod;
    property SensingMethodText: string read GetSensingMethodText;
    property ShutterSpeedTime: Double read GetShutterSpeedTime;
    property ShutterSpeedValue: TExifRational read GetShutterSpeedValue;
    property Software: string read GetSoftware write SetSoftware;
    property SpectralSensivity: string read GetSpectralSensivity;
    property StripByteCounts[Index: Integer]: Integer read GetStripByteCounts;
    property StripByteCountsCount: Integer read GetStripByteCountsCount;
    property StripOffsets[Index: Integer]: Cardinal read GetStripOffsets;
    property StripOffsetsCount: Integer read GetStripOffsetsCount;
    property SubjectDistance: TExifRational read GetSubjectDistance;
    property SubjectLocationX: Integer index 0 read GetSubjectLocation;
    property SubjectLocationY: Integer index 1 read GetSubjectLocation;
    property SubsecTime: Integer read GetSubsecTime write SetSubsecTime;
    property SubsecTimeDigitized: Integer read GetSubsecTimeDigitized
        write SetSubsecTimeDigitized;
    property SubsecTimeOriginal: Integer read GetSubsecTimeOriginal
        write SetSubsecTimeOriginal;
    property ThmArtist: string read GetThmArtist write SetThmArtist;
    property ThmBitsPerSample[Index: Integer]: Integer read GetThmBitsPerSample;
    property ThmCompression: Integer read GetThmCompression;
    property ThmCompressionText: string read GetThmCompressionText;
    property ThmCopyright: string read GetThmCopyright write SetThmCopyright;
    property ThmDateTime: TDateTime read GetThmDateTime write SetThmDateTime;
    property ThmDateTimeText: string read GetThmDateTimeText
        write SetThmDateTimeText;
    property ThmExifIFDPointer: LongWord read GetThmExifIFDPointer;
    property ThmImageDescription: string read GetThmImageDescription
        write SetThmImageDescription;
    property ThmImageLength: Integer read GetThmImageLength;
    property ThmImageWidth: Integer read GetThmImageWidth;
    property ThmInteroperabilityIFDPointer: LongWord
        read GetThmInteroperabilityIFDPointer;
    property ThmInteroperabilityIndex: string read GetThmInteroperabilityIndex;
    property ThmJPEGInterchangeFormat: Cardinal read GetThmJPEGInterchangeFormat;
    property ThmJPEGInterchangeFormatLength: Cardinal
        read GetThmJPEGInterchangeFormatLength;
    property ThmMake: string read GetThmMake write SetThmMake;
    property ThmModel: string read GetThmModel write SetThmModel;
    property ThmOrientation: TExifOrientation read GetThmOrientation;
    property ThmPhotometric: Integer read GetThmPhotometric;
    property ThmPhotometricText: string read GetThmPhotometricText;
    property ThmPlanarConfiguration: TExifPlanarConfiguration
        read GetThmPlanarConfiguration;
    property ThmPrimaryChromaticities[Index: Integer]: TExifRational
        read GetThmPrimaryChromaticities;
    property ThmResolutionUnit: Integer read GetThmResolutionUnit;
    property ThmResolutionUnitText: string read GetThmResolutionUnitText;
    property ThmRowsPerStrip: Integer read GetThmRowsPerStrip;
    property ThmSamplesPerPixel: Integer read GetThmSamplesPerPixel;
    property ThmSoftware: string read GetThmSoftware write SetThmSoftware;
    property ThmStripByteCounts[Index: Integer]: Integer
        read GetThmStripByteCounts;
    property ThmStripByteCountsCount: Integer read GetThmStripByteCountsCount;
    property ThmStripOffsets[Index: Integer]: Cardinal read GetThmStripOffsets;
    property ThmStripOffsetsCount: Integer read GetThmStripOffsetsCount;
    property ThmTransferFunction[Index: Integer]: Word
        read GetThmTransferFunction;
    property ThmWhitePoint[Index: Integer]: TExifRational read GetThmWhitePoint;
    property ThmXResolution: TExifRational read GetThmXResolution;
    property ThmYCbCrCoefficients[Index: Integer]: TExifRational
        read GetThmYCbCrCoefficients;
    property ThmYCbCrPositioning: TExifYCbCrPositioning
        read GetThmYCbCrPositioning;
    property ThmYCbCrSubSampling: TExifSubSampling read GetThmYCbCrSubSampling;
    property ThmYResolution: TExifRational read GetThmYResolution;
    property TransferFunction[Index: Integer]: Word read GetTransferFunction;
    property UserComment: WideString read GetUserComment write SetUserComment;
    property UserCommentStyle: TExifUserCommentStyle read GetUserCommentStyle;
    property WhitePoint[Index: Integer]: TExifRational read GetWhitePoint;
    property XResolution: TExifRational read GetXResolution;
    property YCbCrCoefficients[Index: Integer]: TExifRational
        read GetYCbCrCoefficients;
    property YCbCrPositioning: TExifYCbCrPositioning read GetYCbCrPositioning;
    property YCbCrSubSampling: TExifSubSampling read GetYCbCrSubSampling;
    property YResolution: TExifRational read GetYResolution;
  published
    // ********************************Published**
    // ===============================Property==
    property ImageFileName: TFileName read FImageFileName write SetImageFileName;
    // ==================================Event==
    property OnError: TExifReadErrorEvent read FOnError write FOnError;
    property OnUpdate: TNotifyEvent read FOnUpdate write FOnUpdate;
  end;

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %% 関数・手続き宣言                                                      %%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function IsAscii(const S: string): Boolean;
procedure Register;

implementation

// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
// |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %% ローカル定数定義                                                      %%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
const
  intFormatBytes: array[TExifFormat] of Byte =
      (1, 1, 2, 4, 8, 1, 1, 2, 4, 8, 4, 8);
  intExifHeaderSize = 6;
  intTIFFHeaderSize = 8;
  intEntrySize = 12;

  JPEG_SOF3 = $FFC3;
  JPEG_SOF5 = $FFC5;
  JPEG_SOF7 = $FFC7;
  JPEG_SOF9 = $FFC9;
  JPEG_SOF11 = $FFCB;
  JPEG_SOF13 = $FFCD;
  JPEG_SOF15 = $FFCF;

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %% ローカルリソース文字列定義                                            %%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resourcestring
  // メッセージ
  MSG_NOTEXISTFILE = 'ファイルが見つかりません';
  MSG_NOTEXIF = 'Exif、またはDCF形式ではありません';
  MSG_CANNOTREADUSERCOMMENT = 'ユーザコメントは不明な形式です';
  MSG_CANTWRITENOTASCII = 'ASCII文字以外は書き込みできません';
  MSG_FOULEDSTREAM = '不正なストリーム';
  MSG_OUTOFINDEX = '不正なインデックス';
  MSG_TAGNOTFOUND = 'タグが見つかりません';
  MSG_UNDEFDATETIME = '日時は不明です';
  MSG_ATHERERROR = '不明なエラーです';
  MSG_NOTIMAGE = '有効な画像ファイルではありません';

  Compress_None = '非圧縮';
  Compress_Jpeg = 'JPEG';
  Photometric_RGB = 'RGB';
  Photometric_YCbCr = 'YCbCr';
  Resolution_Inch = 'インチ';
  Resolution_CM = 'センチメートル';
  ColorSpace_sRGB = 'sRGB';
  ColorSpace_Uncalibrated = 'Uncalibrated';
  Metering_Average = '平均';
  Metering_CenterWeighted = '中央重点';
  Metering_Spot = 'スポット';
  Metering_MultiSpot = 'マルチスポット';
  Metering_Pattern = '分割測光';
  Metering_Partial = '部分測光';
  LightSource_1 = '昼光';
  LightSource_2 = '蛍光灯';
  LightSource_3 = 'タングステン';
  LightSource_17 = '標準光 A';
  LightSource_18 = '標準光 B';
  LightSource_19 = '標準光 C';
  LightSource_20 = 'D55';
  LightSource_21 = 'D65';
  LightSource_22 = 'D75';
  ExProgram_Manual = 'マニュアル';
  ExProgram_Normal = 'ノーマルプログラム';
  ExProgram_Exposure = '露出優先';
  ExProgram_Shutter = 'シャッタ優先';
  ExProgram_Creative = 'creativeプログラム';
  ExProgram_Action = 'actionプログラム';
  ExProgram_Portrait = 'ポートレイトモード';
  ExProgram_Landscape = 'ランドスケープモード';
  SensingMethod_1Chip = '単チップカラーセンサ';
  SensingMethod_2Chip = '2チップカラーセンサ';
  SensingMethod_3Chip = '3チップカラーセンサ';
  SensingMethod_SeekColor = '色順次カラーセンサ';
  SensingMethod_3Line = '3線リニアセンサ';
  SensingMethod_SeekLinear = '色順次リニアセンサ';

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %% ローカル型定義                                                        %%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
type
  TJISEscCode = (ecKIN1, ecKIN2, ecKIN3, ecKIN4, ecKOUT1, ecKOUT2, ecAscii,
                 ecHanKana);
  TJISEscCodes = set of TJISEscCode;
  TJISShiftMode = (jsKanji, jsAscii, jsHanKana);

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %% 関数・手続き 実装                                                     %%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// ==========================================================================
// == G Proc: コンポーネント登録                                         ====
// ==========================================================================
procedure Register;
begin
  RegisterComponents('MyCompo', [TExifInfo]);
end;

// ==========================================================================
// == L func: Word値の読み取り                                           ====
// ==========================================================================
function ReadWord(Stream: TStream; Order: TExifByteOrder): Word;
var
  Buffer: array[0..1] of Byte;
begin
  Stream.ReadBuffer(Buffer[0], 1);
  Stream.ReadBuffer(Buffer[1], 1);
  case Order of
    boII: Result := Word(Buffer[1]) shl 8 + Word(Buffer[0]);
    else  Result := Word(Buffer[0]) shl 8 + Word(Buffer[1]);
  end;
end;

// ==========================================================================
// == L func: データ形式のバイト数を取得                                 ====
// ==========================================================================
function FormatByteLength(AFormat: TExifFormat): Cardinal;
begin
  Result := intFormatBytes[AFormat];
end;

// ==========================================================================
// == L func: 整数値が範囲内にあるか検査                                 ====
// ==========================================================================
function InRange(AValue, AMin, AMax: Integer): Boolean;
begin
  Result := (AValue >= AMin) and (AValue <= AMax);
end;

// ==========================================================================
// == G func: ASCII文字列か確認                                          ====
// ==========================================================================
function IsAscii(const S: string): Boolean;
var
  CountNotAscii, L: Integer;
begin
  CountNotAscii := 0;
  for L := 1 to Length(S) do
    if ByteType(S, L) <> mbSingleByte then Inc(CountNotAscii);
  Result := CountNotAscii = 0;
end;

// ==========================================================================
// == L func: メモリから文字列を読み取る                                 ====
// ==========================================================================
function ReadAsciiFromMemory(Mem: TMemoryStream): string;
var
  Buffer: Byte;
begin
  Result := '';
  while Mem.Position < Mem.Size do
  begin
    Mem.ReadBuffer(Buffer, 1);
    Result := Result + Chr(Buffer);
  end;
end;

// ==========================================================================
// == L func: Double値の読み取り                                         ====
// ==========================================================================
function ReadDouble(Stream: TStream; Order: TExifByteOrder): Double;
var
  Buffer: Byte;
  L: Integer;
  pBuffer: PChar;
begin
  GetMem(pBuffer, 8);
  try
    if Order = boII then
      for L := 7 downto 0 do
      begin
        Stream.ReadBuffer(Buffer, 1);
        pBuffer[L] := Chr(Buffer);
      end
    else
      for L := 0 to 7 do
      begin
        Stream.ReadBuffer(Buffer, 1);
        pBuffer[L] := Chr(Buffer);
      end;
    Result := PDouble(pBuffer)^;
  finally
    FreeMem(pBuffer, 8);
  end;
end;

// ==========================================================================
// == L func: メモリからJIS文字列の読み取り                              ====
// ==========================================================================
function ReadJISFromMemory(Mem: TMemoryStream): string;
var
  Buffer, Buf2: Byte;
  Flag: Boolean;
  pBuf: PChar;
  SaveCount: Integer;
  ShiftMode: TJISShiftMode;
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // ++ func: エスケープシーケンスチェックループ                      ++++
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  function EscCheckLoop: Boolean;
  var
    Escs: TJISEscCodes;
    NewShiftMode: TJISShiftMode;
    Num: Integer;
  begin
    SaveCount := 0;
    Escs := [];
    Num := 0;
    Result := False;
    if Mem.Position < Mem.Size then
    begin
      repeat
        Mem.ReadBuffer(Buffer, 1);
        Inc(SaveCount);
        case Num of
          0:
            case Buffer of
              36: Escs := [ecKIN1, ecKIN2, ecKIN4];
              38: Escs := [ecKIN3];
              40: Escs := [ecKOUT1, ecKOUT2, ecAscii, ecHanKana];
              else Escs := [];
            end;
          1:
            begin
              case Buffer of
                40: Escs := Escs * [ecKIN4];
                64: Escs := Escs * [ecKIN1, ecKIN3];
                66: Escs := Escs * [ecKIN2, ecAscii];
                72: Escs := Escs * [ecKOUT2];
                73: Escs := Escs * [ecHanKana];
                74: Escs := Escs * [ecKOUT1];
                else Escs := [];
              end;
              Result := (Escs = [ecKIN1]) or (Escs = [ecKIN2]) or
                        (Escs = [ecKOUT1]) or (Escs = [ecKOUT2]) or
                        (Escs = [ecAscii]) or (escs = [ecHanKana]);
            end;
          2:
            begin
              case Buffer of
                27: Escs := Escs * [ecKIN3];
                68: Escs := Escs * [ecKIN4];
                else Escs := [];
              end;
              Result := (Escs = [ecKIN4]);
            end;
          3:
            case Buffer of
              36: Escs := Escs * [ecKIN3];
              else Escs := [];
            end;
          4:
            begin
              case Buffer of
                66: Escs := Escs * [ecKIN3];
                else Escs := [];
              end;
              Result := (Escs = [ecKIN3]);
            end;
        end;
        Inc(Num);
      until (Escs = []) or Result or (Mem.Position >= Mem.Size);
      if Result then
      begin
        if Escs * [ecKIN1, ecKIN2, ecKIN3, ecKIN4] <> [] then
          NewShiftMode := jsKanji
        else if Escs * [ecKOUT1, ecKOUT2, ecAscii] <> [] then
          NewShiftMode := jsAscii
        else
          NewShiftMode := jsHanKana;
        ShiftMode := NewShiftMode;
      end;
    end;
  end;
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
begin
  Result := '';
  ShiftMode := jsAscii;
  pBuf := StrAlloc(3);
  try
    while Mem.Position < Mem.Size do
    begin
      Mem.ReadBuffer(Buffer, 1);
      case Buffer of
        $1B:
          begin
            if not EscCheckLoop then Mem.Seek(-SaveCount, soCurrent);
            Flag := True;
          end;
        else Flag := False;
      end;
      if not Flag then
        case ShiftMode of
          jsKanji:  // 漢字
            begin
              Mem.ReadBuffer(Buf2, 1);
              // 第2バイト変換
              if Odd(Buf2) then Inc(Buf2, $1F) else Inc(Buf2, $7D);
              if Buf2 > $7E then Inc(Buf2);
              // 第1バイト変換
              if Buffer < $5F then Buffer := (Buffer + 1) div 2 + $70
              else Buffer := (Buffer + 1) div 2 + $B0;
              pBuf[0] := Chr(Buffer);
              pBuf[1] := Chr(Buf2);
              pBuf[2] := #0;
              Result := Result + string(pBuf);
            end;
          jsAscii:  // ASCII
            Result := Result + Chr(Buffer);
          else      // 半角カタカナ
            begin
              Inc(Buffer, $80);
              Result := Result + Chr(Buffer);
            end;
        end;
    end;
  finally
    StrDispose(pBuf);
  end;
end;

// ==========================================================================
// == L func: LongInt値の読み取り                                        ====
// ==========================================================================
function ReadLong(Stream: TStream; Order: TExifByteOrder): LongInt;
var
  Buffer: Byte;
  L, Shift: Integer;
  Longs: array[0..3] of LongInt;
begin
  Result := 0;
  for L := 0 to 3 do
  begin
    Stream.ReadBuffer(Buffer, 1);
    Longs[L] := LongInt(Buffer);
  end;
  if Order = boII then
  begin
    Shift := 0;
    for L := 0 to 3 do
    begin
      Result := Result + Longs[L] shl Shift;
      Inc(Shift, 8);
    end;
  end
  else
  begin
    Shift := 24;
    for L := 0 to 3 do
    begin
      Result := Result + Longs[L] shl Shift;
      Dec(Shift, 8);
    end;
  end;
end;

// ==========================================================================
// == L func: SmallInt値の読み取り                                       ====
// ==========================================================================
function ReadSmall(Stream: TStream; Order: TExifByteOrder): SmallInt;
var
  Buffer: Byte;
begin
  if Order = boII then
  begin
    Stream.ReadBuffer(Buffer, 1);
    Result := SmallInt(Buffer);
    Stream.ReadBuffer(Buffer, 1);
    Result := Result + SmallInt(Buffer) shl 8;
  end
  else
  begin
    Stream.ReadBuffer(Buffer, 1);
    Result := SmallInt(Buffer) shl 8;
    Stream.ReadBuffer(Buffer, 1);
    Result := Result + SmallInt(Buffer);
  end;
end;

// ==========================================================================
// == L func: LongWord値の読み取り                                       ====
// ==========================================================================
function ReadULong(Stream: TStream; Order: TExifByteOrder): LongWord;
var
  Buffer: Byte;
  L: Integer;
  Shift: Integer;
begin
  Result := 0;
  if Order = boII then
  begin
    Shift := 0;
    for L := 0 to 3 do
    begin
      Stream.ReadBuffer(Buffer, 1);
      Result := Result + LongWord(Buffer) shl Shift;
      Inc(Shift, 8);
    end;
  end
  else
  begin
    Shift := 24;
    for L := 0 to 3 do
    begin
      Stream.ReadBuffer(Buffer, 1);
      Result := Result + LongWord(Buffer) shl Shift;
      Dec(Shift, 8);
    end;
  end;
end;

// ==========================================================================
// == L func: Unicodeの読み取り                                          ====
// ==========================================================================
function ReadUnicodeFromMemory(Mem: TMemoryStream): WideString;
var
  BufWord: Word;
  Order: TExifByteOrder;
  pWc: PWideChar;
  Wc: WideChar;
begin
  Result := '';
  Order := boMM;
  // BOM確認
  BufWord := ReadWord(Mem, Order);
  if BufWord = $FFFE then Order := boII
  else if BufWord <> $FEFF then Mem.Seek(-2, soCurrent);
  // 読み取り
  while Mem.Position < Mem.Size do
  begin
    BufWord := ReadWord(Mem, Order);
    pWc := @BufWord;
    Wc := pWc^;
    Result := Result + Wc;
  end;
end;

// ==========================================================================
// == L func: Single値の読み取り                                         ====
// ==========================================================================
function ReadSingle(Stream: TStream; Order: TExifByteOrder): Single;
var
  Buffer: LongWord;
  P: Pointer;
begin
  Buffer := ReadULong(Stream, Order);
  P := @Buffer;
  Result := PSingle(P)^;
end;

// ==========================================================================
// == L func: 文字列からTDateTime値を取得                                ====
// ==========================================================================
function StringDateTime(const S: string): TDateTime;
var
  Cp, DIndex, ErrCount: Integer;
  Dates: array[0..5] of string;
  Vs: array[0..5] of Word;
begin
  Cp := AnsiPos(':', S);
  if Cp = 0 then raise EExifError.Create(MSG_UNDEFDATETIME);
  Dates[0] := Trim(Copy(S, 1, 4));
  Cp := 6;
  for DIndex := 1 to 2 do
  begin
    Dates[DIndex] := Trim(Copy(S, Cp, 2));
    Inc(Cp, 3);
  end;
  Inc(Cp);
  for DIndex := 3 to 5 do
  begin
    Dates[DIndex] := Trim(Copy(S, Cp, 2));
    Inc(Cp, 3);
  end;
  ErrCount := 0;
  for DIndex := 0 to 5 do
  begin
    Vs[DIndex] := Word(StrToIntDef(Dates[DIndex], 65535));
    if Vs[DIndex] = 65535 then Inc(ErrCount);
  end;
  if ErrCount > 0 then raise EExifError.Create(MSG_UNDEFDATETIME);
  Result := EncodeDate(Vs[0], Vs[1], Vs[2]) + EncodeTime(Vs[3], Vs[4], Vs[5], 0);
end;

// ==========================================================================
// == L proc: 文字列をJISで書き込む                                      ====
// ==========================================================================
procedure WriteJISToMemory(Mem: TMemoryStream; const S: string);
const
  EscBytes: array[TJISShiftMode, 0..2] of Byte =
      (($1B, $24, $42), ($1B, $28, $42), ($1B, $28, $49));
var
  Buf, Buf2: Byte;
  Ch: Char;
  CIndex, CLen, L: Integer;
  Shift: TJISShiftMode;
begin
  Shift := jsAscii;
  CIndex := 1;
  CLen := Length(S);
  while CIndex <= CLen do
  begin
    case ByteType(S, CIndex) of
      mbSingleByte:
        begin
          Ch := S[CIndex];
          if InRange(Ord(Ch), $A1, $DF) then
          begin
            if Shift <> jsHanKana then
            begin
              Shift := jsHanKana;
              for L := 0 to 2 do
              begin
                Buf := EscBytes[Shift, L];
                Mem.WriteBuffer(Buf, 1);
              end;
            end;
            Buf := Ord(Ch);
            Dec(Buf, $80);
            Mem.WriteBuffer(Buf, 1);
          end
          else
          begin
            if Shift <> jsAscii then
            begin
              Shift := jsAscii;
              for L := 0 to 2 do
              begin
                Buf := EscBytes[Shift, L];
                Mem.WriteBuffer(Buf, 1);
              end;
            end;
            Buf := Ord(Ch);
            Mem.WriteBuffer(Buf, 1);
          end;
        end;
      mbLeadByte:
        begin
          if Shift <> jsKanji then
          begin
            Shift := jsKanji;
            for L := 0 to 2 do
            begin
              Buf := EscBytes[Shift, L];
              Mem.WriteBuffer(Buf, 1);
            end;
          end;
          Buf := Ord(S[CIndex]);
          Inc(CIndex);
          Buf2 := Ord(S[CIndex]);
          if Buf2 < $9F then
          begin
            if Buf < $A0 then Buf := (Buf - $81) * 2 + $21
            else Buf := (Buf - $E0) * 2 + $5F;
            if Buf2 > $7F then Dec(Buf2);
            Dec(Buf2, $1F);
          end
          else
          begin
            if Buf < $A0 then Buf := (Buf - $81) * 2 + $22
            else Buf := (Buf - $E0) * 2 + $60;
            Dec(Buf2, $7E);
          end;
          Mem.WriteBuffer(Buf, 1);
          Mem.WriteBuffer(Buf2, 1);
        end;
    end;
    Inc(CIndex);
  end;
end;

// ==========================================================================
// == L proc: LongWord値を書き込む                                       ====
// ==========================================================================
procedure WriteLongWord(Stream: TStream; Value: LongWord; Order: TExifByteOrder);
var
  Buffer: Byte;
  L: Integer;
  P: PChar;
  V: LongWord;
begin
  V := Value;
  P := @V;
  if Order = boMM then
    for L := 3 downto 0 do
    begin
      Buffer := Ord(P[L]);
      Stream.WriteBuffer(Buffer, 1);
    end
  else
    for L := 0 to 3 do
    begin
      Buffer := Ord(P[L]);
      Stream.WriteBuffer(Buffer, 1);
    end;
end;

// ==========================================================================
// == L proc: 文字列をUnicodeで書き込む                                  ====
// ==========================================================================
procedure WriteUnicodeToMemory(Mem: TMemoryStream; const S: string);
var
  Buf: Word;
  CIndex, CLen: Integer;
  P: Pointer;
  Wc: WideChar;
  Ws: WideString;
begin
  Ws := S;
  CIndex := 1;
  CLen := Length(Ws);
  // BOM
  Buf := $FEFF;
  Mem.WriteBuffer(Buf, 2);
  // 文字列
  while CIndex <= CLen do
  begin
    Wc := Ws[CIndex];
    P := @Wc;
    Mem.WriteBuffer(PWord(P)^, 2);
    Inc(CIndex);
  end;
end;

// ==========================================================================
// == L proc: Word値を書き込む                                           ====
// ==========================================================================
procedure WriteWord(Stream: TStream; const Value: Word; Order: TExifByteOrder);
var
  Buffer: Byte;
begin
  if Order = boII then
  begin
    Buffer := Lo(Value);
    Stream.WriteBuffer(Buffer, 1);
    Buffer := Hi(Value);
    Stream.WriteBuffer(Buffer, 1);
  end
  else
  begin
    Buffer := Hi(Value);
    Stream.WriteBuffer(Buffer, 1);
    Buffer := Lo(Value);
    Stream.WriteBuffer(Buffer, 1);
  end;
end;

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %% { TExifInfo 実装 }                                                    %%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// ==========================================================================
// == method: Exifデータの解析                                           ====
// ==========================================================================
function TExifInfo.AnalyzeExif: Boolean;
var
  Image: TFileStream;
  Offset, TempOffset: Cardinal;
  TiffPos: Int64;
begin
  Result := False;
  try
    Image := TFileStream.Create(FImageFileName, fmOpenRead);
    try
      Image.Seek(FApp1Position, soBeginning);
      // Exifヘッダをとばす
      SeekExifHeader(Image);
      // TIFFヘッダ解析
      TiffPos := Image.Position;
      FEntrys.CardinalPoint := TiffPos;
      FThmEntrys.CardinalPoint := TiffPos;
      FOffsetCardinalPoint := TiffPos;
      Offset := AnalyzeTiffHeader(Image);
      Image.Seek(Int64(Offset) + TiffPos, soBeginning);
      // メインIFD解析
      FEntrys.BeginUpdate;
      try
        // IFD0
        Offset := AnalyzeIFD(Image, eiTIFF);
        // ExifIFD
        TempOffset := GetExifIFDPointer;
        if TempOffset > 0 then
        begin
          Image.Seek(Int64(TempOffset) + TiffPos, soBeginning);
          AnalyzeIFD(Image, eiExif);
        end;
        // GPSIFD
        TempOffset := GetGPSInfoIFDPointer;
        if TempOffset > 0 then
        begin
          Image.Seek(Int64(TempOffset) + TiffPos, soBeginning);
          AnalyzeIFD(Image, eiGPS);
        end;
        // 互換性IFD
        TempOffset := GetInteroperabilityIFDPointer;
        if TempOffset > 0 then
        begin
          Image.Seek(Int64(TempOffset) + TiffPos, soBeginning);
          AnalyzeIFD(Image, eiInteroperability);
        end;
      finally
        FEntrys.EndUpdate;
      end;
      // サムネイルIFD解析
      if Offset > 0 then
      begin
        FThmEntrys.BeginUpdate;
        try
          // IFD1
          Image.Seek(Int64(Offset) + TiffPos, soBeginning);
          AnalyzeThmIFD(Image, eiTIFF);
          // ExifIFD
          Offset := GetThmExifIFDPointer;
          if Offset > 0 then
          begin
            Image.Seek(Int64(Offset) + TiffPos, soBeginning);
            AnalyzeIFD(Image, eiExif);
          end;
          // 互換性IFD
          Offset := GetThmInteroperabilityIFDPointer;
          if Offset > 0 then
          begin
            Image.Seek(Int64(Offset) + TiffPos, soBeginning);
            AnalyzeThmIFD(Image, eiInteroperability);
          end;
        finally
          FThmEntrys.EndUpdate;
        end;
      end;
    finally
      Image.Free;
    end;
    Result := True;
    DoUpdate;
  except
    //
  end;
end;

// ==========================================================================
// == method: IFD部の解析                                                ====
// ==========================================================================
function TExifInfo.AnalyzeIFD(Stream: TStream;
  const IFDNumber: TExifIFD): Cardinal;
var
  Entry: TEntryItem;
  EntryCount, LEntry: Integer;
begin
  EntryCount := Integer(ReadWord(Stream, FByteOrder));
  for LEntry := 1 to EntryCount do
  begin
    Entry := FEntrys.Add;
    Entry.IFD := IFDNumber;
    Entry.LoadFromStream(Stream);
  end;
  Result := ReadULong(Stream, FByteOrder);
end;

// ==========================================================================
// == method: JPEGヘッダの解析                                           ====
// ==========================================================================
procedure TExifInfo.AnalyzeJpegHeader;
var
  Hit: Boolean;
  Image: TFileStream;
  Marker, SegmentLength: Word;
begin
  FJpegHeight := 0;
  FJpegWidth := 0;
  FDoneAnalyzeJpeg := True;
  if FImageFileName = '' then Exit;
  if not FileExists(FImageFileName) then Exit;
  // 解析
  Image := TFileStream.Create(FImageFileName, fmOpenRead);
  try
    // SOI確認
    Image.Seek(0, soBeginning);
    Marker := ReadWord(Image, boMM);
    if Marker = Exif_SOI then
    begin
      // SOFn検索
      repeat
        Marker := ReadWord(Image, boMM);
        SegmentLength := ReadWord(Image, boMM);
        Hit := InRange(Marker, Exif_SOF0, JPEG_SOF3) or
               InRange(Marker, JPEG_SOF5, JPEG_SOF7) or
               InRange(Marker, JPEG_SOF9, JPEG_SOF11) or
               InRange(Marker, JPEG_SOF13, JPEG_SOF15);
        if not Hit then Image.Seek(SegmentLength - 2, soCurrent);
      until Hit;
      // SOFn解析
      // サンプル精度スキップ
      Image.Seek(1, soCurrent);
      // サイズ
      FJpegHeight := Integer(ReadWord(Image, boMM));
      FJpegWidth := Integer(ReadWord(Image, boMM));
    end;
  finally
    Image.Free;
  end;
end;

// ==========================================================================
// == method: サムネイルIFD解析                                          ====
// ==========================================================================
function TExifInfo.AnalyzeThmIFD(Stream: TStream;
  const IFDNumber: TExifIFD): Cardinal;
var
  Entry: TEntryItem;
  EntryCount, LEntry: Integer;
begin
  EntryCount := Integer(ReadWord(Stream, FByteOrder));
  for LEntry := 1 to EntryCount do
  begin
    Entry := FThmEntrys.Add;
    Entry.IFD := IFDNumber;
    Entry.LoadFromStream(Stream);
  end;
  Result := ReadULong(Stream, FByteOrder);
end;

// ==========================================================================
// == method: TIFFヘッダ部の解析                                         ====
// ==========================================================================
function TExifInfo.AnalyzeTiffHeader(Stream: TStream): Cardinal;
var
  BufWord: Word;
begin
  // 格納形式
  Stream.ReadBuffer(BufWord, 2);
  FByteOrder := TExifByteOrder(BufWord);
  // 最初のIFDへのオフセット
  Stream.Seek(2, soCurrent);
  Result := ReadULong(Stream, FByteOrder);
end;

// ==========================================================================
// == method: メーカーノートの取得                                       ====
// ==========================================================================
function TExifInfo.CopyFromMakerNote(Stream: TStream): Int64;
var
  Mem: TMemoryStream;
begin
  Mem := TMemoryStream(GetTagPointer(Exif_MakerNote, eiExif, True));
  Mem.Position := 0;
  Result := Stream.CopyFrom(Mem, Mem.Size);
end;

// ==========================================================================
// == method: コンストラクタ                                             ====
// ==========================================================================
constructor TExifInfo.Create(AOwner: TComponent);
begin
  inherited;
  FEntrys := TEntryItems.Create(Self, TEntryItem);
  FThmEntrys := TEntryItems.Create(Self, TEntryItem);
  FRationalValue := TExifRational.Create(Self);
end;

// ==========================================================================
// == method: デストラクタ                                               ====
// ==========================================================================
destructor TExifInfo.Destroy;
begin
  FEntrys.Free;
  FThmEntrys.Free;
  FRationalValue.Free;
  inherited;
end;

// ==========================================================================
// == event: OnError                                                     ====
// ==========================================================================
procedure TExifInfo.DoError(ACode: Integer);
var
  AllowError: Boolean;
  Msg: string;
begin
  AllowError := False;
  if Assigned(FOnError) then FOnError(Self, ACode, AllowError);
  if AllowError then
  begin
    case ACode of
      ERR_FILENOTEXIST   : Msg := MSG_NOTEXISTFILE;
      ERR_NOTEXIF        : Msg := MSG_NOTEXIF;
      ERR_USERCOMMENT    : Msg := MSG_CANNOTREADUSERCOMMENT;
      ERR_ASCIIONLY      : Msg := MSG_CANTWRITENOTASCII;
      ERR_FAILEDREAD     : Msg := MSG_FOULEDSTREAM;
      ERR_OUTOFRANGE     : Msg := MSG_OUTOFINDEX;
      ERR_TAGNOTFOUND    : Msg := MSG_TAGNOTFOUND;
      ERR_FAILEDSTRTODATE: Msg := MSG_UNDEFDATETIME;
      else                 Msg := MSG_ATHERERROR;
    end;
    raise EExifError.Create(Msg);
  end;
end;

// ==========================================================================
// == event: OnUpdate                                                    ====
// ==========================================================================
procedure TExifInfo.DoUpdate;
begin
  if Assigned(FOnUpdate) and not (csDestroying in ComponentState) then
    FOnUpdate(Self);
end;

// ==========================================================================
// == method: ファイルからサムネイルを作成                               ====
// ==========================================================================
procedure TExifInfo.ExtractThumbnail(const FileName: string; Thumb: TJPEGImage);
var
  Bmp, Temp: TBitmap;
  Jpg: TJPEGImage;
  Rx, Ry, R: Double;
  W, H: Integer;
begin
  Bmp := TBitmap.Create;
  try
    Jpg := TJPEGImage.Create;
    try
      Jpg.LoadFromFile(FileName);
      Bmp.Assign(Jpg);
    finally
      Jpg.Free;
    end;
    Rx := 160 / Bmp.Width;
    Ry := 120 / Bmp.Height;
    if Rx > Ry then R := Ry else R := Rx;
    if R > 1.0 then R := 1.0;
    W := Trunc(R * Bmp.Width);
    H := Trunc(R * Bmp.Height);
    Temp := TBitmap.Create;
    try
      Temp.PixelFormat := pf24bit;
      Temp.Width := W;
      Temp.Height := H;
      Temp.Canvas.StretchDraw(Rect(0, 0, W, H), Bmp);
      Thumb.Assign(Temp);
    finally
      Temp.Free;
    end;
  finally
    Bmp.Free;
  end;
end;

// ==========================================================================
// == method: APP1マーカーの位置を検索                                   ====
// ==========================================================================
function TExifInfo.FindApp1Marker(const FileName: string): Int64;
var
  BufByte: Byte;
  BufWord: Word;
  BytePos: Int64;
  Image: TFileStream;
begin
  Result := -1;
  try
    Image := TFileStream.Create(FileName, fmOpenRead);
    try
      Image.Seek(0, soBeginning);
      BytePos := 0;
      // JPEG確認
      BufWord := ReadWord(Image, boMM);
      if BufWord = Exif_SOI then
      begin
        // APP1検索
        BufWord := 0;
        repeat
          Image.ReadBuffer(BufByte, 1);
          Inc(BytePos);
          if BufByte = $FF then
          begin
            Image.ReadBuffer(BufByte, 1);
            if BufByte = $E1 then BufWord := Exif_APP1
            else Image.Seek(-1, soCurrent);
          end;
        until (BufWord = Exif_APP1) or (BytePos > FSearchBytes);
        if BufWord = Exif_APP1 then Result := Image.Position - 2;
      end;
    finally
      Image.Free;
    end;
  except
    //
  end;
end;

// ==========================================================================
// == get: ApertureValue                                                 ====
// ==========================================================================
function TExifInfo.GetApertureValue: TExifRational;
begin
  Result := GetURatioValue(Exif_ApertureValue, eiExif);
end;

// ==========================================================================
// == get: Artist                                                        ====
// ==========================================================================
function TExifInfo.GetArtist: string;
begin
  Result := GetTagString(Exif_Artist, eiTIFF, False);
  if Result = '' then Result := exstrUnknown;
end;

// ==========================================================================
// == get: BitsPerSample                                                 ====
// ==========================================================================
function TExifInfo.GetBitsPerSample(Index: Integer): Integer;
var
  Entry: TEntryItem;
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FEntrys.IndexOfTag(Exif_BitsPerSample, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    Entry := FEntrys[EntryIndex];
    if not InRange(Index, 0, Entry.DataCount - 1) then DoError(ERR_OUTOFRANGE)
    else Result := Entry.GetUShortData(Index);
  end;
end;

// ==========================================================================
// == get: BrightnessValue                                               ====
// ==========================================================================
function TExifInfo.GetBrightnessValue: TExifRational;
begin
  Result := GetSRatioValue(Exif_BrightnessValue, eiExif);
end;

// ==========================================================================
// == get: ColorSpace                                                    ====
// ==========================================================================
function TExifInfo.GetColorSpace: Integer;
begin
  Result := Integer(GetTagUShort(Exif_ColorSpace, 0, eiExif, True));
end;

// ==========================================================================
// == get: ColorSpaceText                                                ====
// ==========================================================================
function TExifInfo.GetColorSpaceText: string;
begin
  case GetColorSpace of
    1    : Result := ColorSpace_sRGB;
    $FFFF: Result := ColorSpace_Uncalibrated;
    else   Result := exstrReserved;
  end;
end;

// ==========================================================================
// == get: ComponentsConfiguration                                       ====
// ==========================================================================
function TExifInfo.GetComponentsConfiguration(Index: Integer): Integer;
var
  Buffer: Byte;
  Mem: TMemoryStream;
begin
  if not InRange(Index, 0, 3) then
  begin
    DoError(ERR_OUTOFRANGE);
    Result := 0;
  end
  else
  begin
    Mem := TMemoryStream(GetTagPointer(Exif_ComponentsConfiguration, eiExif,
                         True));
    Mem.Position := Index - 1;
    Mem.ReadBuffer(Buffer, 1);
    Result := Integer(Buffer);
  end;
end;

// ==========================================================================
// == get: ComponentsConfigurationText                                   ====
// ==========================================================================
function TExifInfo.GetComponentsConfigurationText: string;
const
  Texts: array[0..6] of string = (' ', 'Y', 'Cb', 'Cr', 'R', 'G', 'B');
var
  Buffer: Byte;
  Mem: TMemoryStream;
begin
  Mem := TMemoryStream(GetTagPointer(Exif_ComponentsConfiguration, eiExif, True));
  Mem.Position := 0;
  Result := '';
  while Mem.Position < Mem.Size do
  begin
    Mem.ReadBuffer(Buffer, 1);
    if InRange(Buffer, 0, 6) then Result := Result + Texts[Buffer]
    else Result := Result + Texts[0];
  end;
end;

// ==========================================================================
// == get: CompressedBitsPerPixel                                        ====
// ==========================================================================
function TExifInfo.GetCompressedBitsPerPixel: TExifRational;
begin
  Result := GetURatioValue(Exif_CompressedBitsPerPixel, eiExif);
end;

// ==========================================================================
// == get: Compression                                                   ====
// ==========================================================================
function TExifInfo.GetCompression: Integer;
begin
  Result := Integer(GetTagULong(Exif_Compression, 0, eiTIFF, True));
end;

// ==========================================================================
// == get: CompressionText                                               ====
// ==========================================================================
function TExifInfo.GetCompressionText: string;
begin
  case GetCompression of
    1: Result := Compress_None;
    6: Result := Compress_Jpeg;
    else Result := exstrReserved;
  end;
end;

// ==========================================================================
// == get: Copyright                                                     ====
// ==========================================================================
function TExifInfo.GetCopyright: string;
begin
  Result := GetTagString(Exif_Copyright, eiTIFF, False);
  if Result = '' then Result := exstrUnknown;
end;

// ==========================================================================
// == get: DateTime                                                      ====
// ==========================================================================
function TExifInfo.GetDateTime: TDateTime;
begin
  Result := StringDateTime(GetDateTimeText);
end;

// ==========================================================================
// == get: DateTimeDigitized                                             ====
// ==========================================================================
function TExifInfo.GetDateTimeDigitized: TDateTime;
begin
  Result := StringDateTime(GetDateTimeDigitizedText);
end;

// ==========================================================================
// == get: DateTimeDigitizedText                                         ====
// ==========================================================================
function TExifInfo.GetDateTimeDigitizedText: string;
begin
  Result := GetTagString(Exif_DateTimeDigitized, eiExif, False);
  if Result = '' then Result := exstrUnknown;
end;

// ==========================================================================
// == get: DateTimeOriginal                                              ====
// ==========================================================================
function TExifInfo.GetDateTimeOriginal: TDateTime;
begin
  Result := StringDateTime(GetDateTimeOriginalText);
end;

// ==========================================================================
// == get: DateTimeOriginalText                                          ====
// ==========================================================================
function TExifInfo.GetDateTimeOriginalText: string;
begin
  Result := GetTagString(Exif_DateTimeOriginal, eiExif, False);
  if Result = '' then Result := exstrUnknown;
end;

// ==========================================================================
// == get: DateTimeText                                                  ====
// ==========================================================================
function TExifInfo.GetDateTimeText: string;
begin
  Result := GetTagString(Exif_DateTime, eiTIFF, False);
  if Result = '' then Result := exstrUnknown;
end;

// ==========================================================================
// == get: ExifIFDPointer                                                ====
// ==========================================================================
function TExifInfo.GetExifIFDPointer: LongWord;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag($8769, eiTIFF);
  if EntryIndex = -1 then Result := 0
  else Result := FEntrys[EntryIndex].GetULongData(0);
end;

// ==========================================================================
// == get: ExifVersion                                                   ====
// ==========================================================================
function TExifInfo.GetExifVersion: string;
var
  BufByte: Byte;
  Mem: TMemoryStream;
begin
  Mem := TMemoryStream(GetTagPointer(Exif_ExifVersion, eiExif, True));
  Mem.Position := 0;
  Result := '';
  while Mem.Position < Mem.Size do
  begin
    Mem.ReadBuffer(BufByte, 1);
    Result := Result + Chr(BufByte);
  end;
end;

// ==========================================================================
// == get: ExposureBiasValue                                             ====
// ==========================================================================
function TExifInfo.GetExposureBiasValue: TExifRational;
begin
  Result := GetSRatioValue(Exif_ExposureBiasValue, eiExif);
end;

// ==========================================================================
// == get: ExposureIndex                                                 ====
// ==========================================================================
function TExifInfo.GetExposureIndex: TExifRational;
begin
  Result := GetURatioValue(Exif_ExposureIndex, eiExif);
end;

// ==========================================================================
// == get: ExposureProgram                                               ====
// ==========================================================================
function TExifInfo.GetExposureProgram: Integer;
begin
  Result := Integer(GetTagUShort(Exif_ExposureProgram, 0, eiExif, True));
end;

// ==========================================================================
// == get: ExposureProgramText                                           ====
// ==========================================================================
function TExifInfo.GetExposureProgramText: string;
begin
  case GetExposureProgram of
    0: Result := exstrUndefined;
    1: Result := ExProgram_Manual;
    2: Result := ExProgram_Normal;
    3: Result := ExProgram_Exposure;
    4: Result := ExProgram_Shutter;
    5: Result := ExProgram_Creative;
    6: Result := ExProgram_Action;
    7: Result := ExProgram_Portrait;
    8: Result := ExProgram_Landscape;
    else Result := exstrReserved;
  end;
end;

// ==========================================================================
// == get: ExposureTime                                                  ====
// ==========================================================================
function TExifInfo.GetExposureTime: TExifRational;
begin
  Result := GetURatioValue(Exif_ExposureTime, eiExif);
end;

// ==========================================================================
// == get: FileSource                                                    ====
// ==========================================================================
function TExifInfo.GetFileSource: Integer;
var
  Buffer: Byte;
  Mem: TMemoryStream;
begin
  Mem := TMemoryStream(GetTagPointer(Exif_FileSource, eiExif, False));
  if Mem = nil then Result := 3
  else
  begin
    Mem.Position := 0;
    Mem.ReadBuffer(Buffer, 1);
    Result := Integer(Buffer);
  end;
end;

// ==========================================================================
// == get: Flash                                                         ====
// ==========================================================================
function TExifInfo.GetFlash: Boolean;
var
  V: Integer;
begin
  V := GetFlashValue;
  Result := (V and 1 <> 0);
end;

// ==========================================================================
// == get: FlashEnergy                                                   ====
// ==========================================================================
function TExifInfo.GetFlashEnergy: TExifRational;
begin
  Result := GetURatioValue(Exif_FlashEnergy, eiExif);
end;

// ==========================================================================
// == get: FlashPixVersion                                               ====
// ==========================================================================
function TExifInfo.GetFlashPixVersion: string;
var
  BufByte: Byte;
  Mem: TMemoryStream;
begin
  Mem := TMemoryStream(GetTagPointer(Exif_FlashPixVersion, eiExif, True));
  Mem.Position := 0;
  Result := '';
  while Mem.Position < Mem.Size do
  begin
    Mem.ReadBuffer(BufByte, 1);
    Result := Result + Chr(BufByte);
  end;
end;

// ==========================================================================
// == get: FlashReturn                                                   ====
// ==========================================================================
function TExifInfo.GetFlashReturn: TExifFlashReturn;
var
  V: Integer;
begin
  V := (GetFlashValue and 6) shr 1;
  case V of
    0: Result := frNoDetector;
    1: Result := frReserved;
    2: Result := frUndetect;
    3: Result := frDetect;
    else Result := frReserved;
  end;
end;

// ==========================================================================
// == get: FlashValue                                                    ====
// ==========================================================================
function TExifInfo.GetFlashValue: Integer;
begin
  Result := Integer(GetTagUShort(Exif_Flash, 0, eiExif, True));
end;

// ==========================================================================
// == get: FNumber                                                       ====
// ==========================================================================
function TExifInfo.GetFNumber: TExifRational;
begin
  Result := GetURatioValue(Exif_FNumber, eiExif);
end;

// ==========================================================================
// == get: FocalLength                                                   ====
// ==========================================================================
function TExifInfo.GetFocalLength: TExifRational;
begin
  Result := GetURatioValue(Exif_FocalLength, eiExif);
end;

// ==========================================================================
// == get: FocalPlaneResolutionUnit                                      ====
// ==========================================================================
function TExifInfo.GetFocalPlaneResolutionUnit: Integer;
begin
  Result := Integer(GetTagUShort(Exif_FocalPlaneResolutionUnit, 0, eiExif, False));
  if Result = 0 then Result := 2;
end;

// ==========================================================================
// == get: FocalPlaneResolutionUnitText                                  ====
// ==========================================================================
function TExifInfo.GetFocalPlaneResolutionUnitText: string;
begin
  case GetFocalPlaneResolutionUnit of
    2: Result := Resolution_Inch;
    3: Result := Resolution_CM;
    else Result := exstrReserved;
  end;
end;

// ==========================================================================
// == get: FocalPlaneXResolution                                         ====
// ==========================================================================
function TExifInfo.GetFocalPlaneXResolution: TExifRational;
begin
  Result := GetURatioValue(Exif_FocalPlaneXResolution, eiExif);
end;

// ==========================================================================
// == get: FocalPlaneYResolution                                         ====
// ==========================================================================
function TExifInfo.GetFocalPlaneYResolution: TExifRational;
begin
  Result := GetURatioValue(Exif_FocalPlaneYResolution, eiExif);
end;

// ==========================================================================
// == get: GPSAltitude                                                   ====
// ==========================================================================
function TExifInfo.GetGPSAltitude: TExifRational;
begin
  Result := GetURatioValue(Exif_GPSAltitude, eiGPS);
end;

// ==========================================================================
// == get: GPSAltitudeRef                                                ====
// ==========================================================================
function TExifInfo.GetGPSAltitudeRef: Integer;
begin
  Result := GetTagUByte(Exif_GPSAltitudeRef, 0, eiGPS, False);
end;

// ==========================================================================
// == get: GPSDestBearing                                                ====
// ==========================================================================
function TExifInfo.GetGPSDestBearing: TExifRational;
begin
  Result := GetURatioValue(Exif_GPSDestBearing, eiGPS);
end;

// ==========================================================================
// == get: GPSDestBearingRef                                             ====
// ==========================================================================
function TExifInfo.GetGPSDestBearingRef: Char;
var
  S: string;
begin
  S := GetTagString(Exif_GPSDestBearingRef, eiGPS, True);
  Result := S[1];
end;

// ==========================================================================
// == get: GPSDestDistance                                               ====
// ==========================================================================
function TExifInfo.GetGPSDestDistance: TExifRational;
begin
  Result := GetURatioValue(Exif_GPSDestDistance, eiGPS);
end;

// ==========================================================================
// == get: GPSDestDistanceRef                                            ====
// ==========================================================================
function TExifInfo.GetGPSDestDistanceRef: Char;
var
  S: string;
begin
  S := GetTagString(Exif_GPSDestDistanceRef, eiGPS, True);
  Result := S[1];
end;

// ==========================================================================
// == get: GPSDestLatitude                                               ====
// ==========================================================================
function TExifInfo.GetGPSDestLatitude(Index: Integer): TExifRational;
var
  EntryIndex: Integer;
  P: PUnsignedRational;
begin
  Result := FRationalValue;
  if not InRange(Index, 0, 2) then DoError(ERR_OUTOFRANGE)
  else
  begin
    EntryIndex := FEntrys.IndexOfTag(Exif_GPSDestLatitude, eiGPS);
    if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
    else
    begin
      P := FEntrys[EntryIndex].Data[Index];
      Result.SetValues(P);
    end;
  end;
end;

// ==========================================================================
// == get: GPSDestLatitudeRef                                            ====
// ==========================================================================
function TExifInfo.GetGPSDestLatitudeRef: Char;
var
  S: string;
begin
  S := GetTagString(Exif_GPSDestLatitudeRef, eiGPS, True);
  Result := S[1];
end;

// ==========================================================================
// == get: GPSDestLongitude                                              ====
// ==========================================================================
function TExifInfo.GetGPSDestLongitude(Index: Integer): TExifRational;
var
  EntryIndex: Integer;
  P: PUnsignedRational;
begin
  Result := FRationalValue;
  if not InRange(Index, 0, 2) then DoError(ERR_OUTOFRANGE)
  else
  begin
    EntryIndex := FEntrys.IndexOfTag(Exif_GPSDestLongitude, eiGPS);
    if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
    else
    begin
      P := FEntrys[EntryIndex].Data[Index];
      FRationalValue.SetValues(P);
    end;
  end;
end;

// ==========================================================================
// == get: GPSDestLongitudeRef                                           ====
// ==========================================================================
function TExifInfo.GetGPSDestLongitudeRef: Char;
var
  S: string;
begin
  S := GetTagString(Exif_GPSDestLongitudeRef, eiGPS, True);
  Result := S[1];
end;

// ==========================================================================
// == get: GPSDOP                                                        ====
// ==========================================================================
function TExifInfo.GetGPSDOP: TExifRational;
begin
  Result := GetURatioValue(Exif_GPSDOP, eiGPS);
end;

// ==========================================================================
// == get: GPSImgDirection                                               ====
// ==========================================================================
function TExifInfo.GetGPSImgDirection: TExifRational;
begin
  Result := GetURatioValue(Exif_GPSImgDirection, eiGPS);
end;

// ==========================================================================
// == get: GPSImgDirectionRef                                            ====
// ==========================================================================
function TExifInfo.GetGPSImgDirectionRef: Char;
var
  S: string;
begin
  S := GetTagString(Exif_GPSImgDirectionRef, eiGPS, True);
  Result := S[1];
end;

// ==========================================================================
// == get: GPSInfoIFDPointer                                             ====
// ==========================================================================
function TExifInfo.GetGPSInfoIFDPointer: LongWord;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag($8825, eiTIFF);
  if EntryIndex = -1 then Result := 0
  else Result := FEntrys[EntryIndex].GetULongData(0);
end;

// ==========================================================================
// == get: GPSLatitude                                                   ====
// ==========================================================================
function TExifInfo.GetGPSLatitude(Index: Integer): TExifRational;
var
  EntryIndex: Integer;
  P: PUnsignedRational;
begin
  Result := FRationalValue;
  EntryIndex := FEntrys.IndexOfTag(Exif_GPSLatitude, eiGPS);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    if not InRange(Index, 0, 2) then DoError(ERR_OUTOFRANGE)
    else
    begin
      P := FEntrys[EntryIndex].Data[Index];
      FRationalValue.SetValues(P);
    end;
  end;
end;

// ==========================================================================
// == get: GPSLatitudeRef                                                ====
// ==========================================================================
function TExifInfo.GetGPSLatitudeRef: Char;
var
  S: string;
begin
  S := GetTagString(Exif_GPSLatitudeRef, eiGPS, True);
  Result := S[1];
end;

// ==========================================================================
// == get: GPSLongitude                                                  ====
// ==========================================================================
function TExifInfo.GetGPSLongitude(Index: Integer): TExifRational;
var
  EntryIndex: Integer;
  P: PUnsignedRational;
begin
  Result := FRationalValue;
  EntryIndex := FEntrys.IndexOfTag(Exif_GPSLongitude, eiGPS);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    if not InRange(Index, 0, 2) then DoError(ERR_OUTOFRANGE)
    else
    begin
      P := FEntrys[EntryIndex].Data[Index];
      FRationalValue.SetValues(P);
    end;
  end;
end;

// ==========================================================================
// == get: GPSLongitudeRef                                               ====
// ==========================================================================
function TExifInfo.GetGPSLongitudeRef: Char;
var
  S: string;
begin
  S := GetTagString(Exif_GPSLongitudeRef, eiGPS, True);
  Result := S[1];
end;

// ==========================================================================
// == get: GPSMapDatum                                                   ====
// ==========================================================================
function TExifInfo.GetGPSMapDatum: string;
begin
  Result := GetTagString(Exif_GPSMapDatum, eiGPS, True);
end;

// ==========================================================================
// == get: GPSMeasureMode                                                ====
// ==========================================================================
function TExifInfo.GetGPSMeasureMode: Char;
var
  S: string;
begin
  S := GetTagString(Exif_GPSMeasureMode, eiGPS, True);
  Result := S[1];
end;

// ==========================================================================
// == get: GPSSatellites                                                 ====
// ==========================================================================
function TExifInfo.GetGPSSatellites: string;
begin
  Result := GetTagString(Exif_GPSSatellites, eiGPS, True);
end;

// ==========================================================================
// == get: GPSSpeed                                                      ====
// ==========================================================================
function TExifInfo.GetGPSSpeed: TExifRational;
begin
  Result := GetURatioValue(Exif_GPSSpeed, eiGPS);
end;

// ==========================================================================
// == get: GPSSpeedRef                                                   ====
// ==========================================================================
function TExifInfo.GetGPSSpeedRef: Char;
var
  S: string;
begin
  S := GetTagString(Exif_GPSSpeedRef, eiGPS, True);
  Result := S[1];
end;

// ==========================================================================
// == get: GPSStatus                                                     ====
// ==========================================================================
function TExifInfo.GetGPSStatus: Char;
var
  S: string;
begin
  S := GetTagString(Exif_GPSStatus, eiGPS, True);
  Result := S[1];
end;

// ==========================================================================
// == get: GPSTimeStamp                                                  ====
// ==========================================================================
function TExifInfo.GetGPSTimeStamp(Index: Integer): TExifRational;
var
  EntryIndex: Integer;
  P: PUnsignedRational;
begin
  Result := FRationalValue;
  if not InRange(Index, 0, 2) then DoError(ERR_OUTOFRANGE)
  else
  begin
    EntryIndex := FEntrys.IndexOfTag(Exif_GPSTimeStamp, eiGPS);
    if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
    else
    begin
      P := FEntrys[EntryIndex].Data[Index];
      FRationalValue.SetValues(P);
    end;
  end;
end;

// ==========================================================================
// == get: GPSTrack                                                      ====
// ==========================================================================
function TExifInfo.GetGPSTrack: TExifRational;
begin
  Result := GetURatioValue(Exif_GPSTrack, eiGPS);
end;

// ==========================================================================
// == get: GPSTrackRef                                                   ====
// ==========================================================================
function TExifInfo.GetGPSTrackRef: Char;
var
  S: string;
begin
  S := GetTagString(Exif_GPSTrackRef, eiGPS, True);
  Result := S[1];
end;

// ==========================================================================
// == get: GPSVersionId                                                  ====
// ==========================================================================
function TExifInfo.GetGPSVersionID(Index: Integer): Integer;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag(Exif_GPSVersionID, eiGPS);
  if EntryIndex = -1 then
    case Index of
      0: Result := 2;
      1: Result := 0;
      2: Result := 0;
      3: Result := 0;
      else
        begin
          DoError(ERR_OUTOFRANGE);
          Result := 0;
        end;
    end
  else
  begin
    if not InRange(Index, 0, 3) then
    begin
      DoError(ERR_OUTOFRANGE);
      Result := 0;
    end
    else Result := FEntrys[EntryIndex].GetUByteData(Index);
  end;
end;

// ==========================================================================
// == get: ImageDescription                                              ====
// ==========================================================================
function TExifInfo.GetImageDescription: string;
begin
  Result := GetTagString(Exif_ImageDescription, eiTIFF, True);
end;

// ==========================================================================
// == get: ImageLength                                                   ====
// ==========================================================================
function TExifInfo.GetImageLength: Integer;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FEntrys.IndexOfTag(Exif_ImageLength, eiTIFF);
  if EntryIndex = -1 then
  begin
    if not FDoneAnalyzeJpeg then AnalyzeJpegHeader;
    Result := FJpegHeight;
  end
  else
  begin
    case FEntrys[EntryIndex].Format of
      efUShort: Result := Integer(FEntrys[EntryIndex].GetUShortData(0));
      efULong : Result := Integer(FEntrys[EntryIndex].GetULongData(0));
    end;
  end;
end;

// ==========================================================================
// == get: ImageWidth                                                    ====
// ==========================================================================
function TExifInfo.GetImageWidth: Integer;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag(Exif_ImageWidth, eiTIFF);
  if EntryIndex = -1 then
  begin
    if not FDoneAnalyzeJpeg then AnalyzeJpegHeader;
    Result := FJpegWidth;
  end
  else
  begin
    case FEntrys[EntryIndex].Format of
      efUShort: Result := Integer(FEntrys[EntryIndex].GetUShortData(0));
      efULong : Result := Integer(FEntrys[EntryIndex].GetULongData(0));
      else
        begin
          DoError(ERR_FAILEDREAD);
          Result := 0;
        end;
    end;
  end;
end;

// ==========================================================================
// == get: InteroperabilityIFDPointer                                    ====
// ==========================================================================
function TExifInfo.GetInteroperabilityIFDPointer: LongWord;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag($A005, eiExif);
  if EntryIndex = -1 then Result := 0
  else Result := FEntrys[EntryIndex].GetULongData(0);
end;

// ==========================================================================
// == get: InteroperabilityIndex                                         ====
// ==========================================================================
function TExifInfo.GetInteroperabilityIndex: string;
begin
  Result := GetTagString(Exif_InteroperabilityIndex, eiInteroperability, True);
end;

// ==========================================================================
// == get: InteroperabilityVersion                                       ====
// ==========================================================================
function TExifInfo.GetInteroperabilityVersion: string;
var
  BufByte: Byte;
  Mem: TMemoryStream;
begin
  Mem := TMemoryStream(GetTagPointer(Exif_InteroperabilityVersion,
                                     eiInteroperability, True));
  Mem.Position := 0;
  while Mem.Position < Mem.Size do
  begin
    Mem.ReadBuffer(BufByte, 1);
    Result := Result + Chr(BufByte);
  end;
end;

// ==========================================================================
// == get: ISOSpeedRatingCount                                           ====
// ==========================================================================
function TExifInfo.GetISOSpeedRatingCount: Integer;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag(Exif_ISOSpeedRatings, eiExif);
  if EntryIndex = -1 then Result := 0
  else Result := FEntrys[EntryIndex].DataCount;
end;

// ==========================================================================
// == get: ISOSpeedRatings                                               ====
// ==========================================================================
function TExifInfo.GetISOSpeedRatings(Index: Integer): Integer;
begin
  Result := Integer(GetTagUShort(Exif_ISOSpeedRatings, Index, eiExif, True));
end;

// ==========================================================================
// == get: LightSource                                                   ====
// ==========================================================================
function TExifInfo.GetLightSource: Integer;
begin
  Result := Integer(GetTagUShort(Exif_LightSource, 0, eiExif, False));
end;

// ==========================================================================
// == get: LightSourceText                                               ====
// ==========================================================================
function TExifInfo.GetLightSourceText: string;
begin
  case GetLightSource of
    0  : Result := exstrUnknown;
    1  : Result := LightSource_1;
    2  : Result := LightSource_2;
    3  : Result := LightSource_3;
    17 : Result := LightSource_17;
    18 : Result := LightSource_18;
    19 : Result := LightSource_19;
    20 : Result := LightSource_20;
    21 : Result := LightSource_21;
    22 : Result := LightSource_22;
    255: Result := exstrAther;
    else Result := exstrReserved;
  end;
end;

// ==========================================================================
// == get: Make                                                          ====
// ==========================================================================
function TExifInfo.GetMake: string;
begin
  Result := GetTagString(Exif_Make, eiTIFF, False);
  if Result = '' then Result := exstrUnknown;
end;

// ==========================================================================
// == get: MaxApatureValue                                               ====
// ==========================================================================
function TExifInfo.GetMaxApatureValue: TExifRational;
begin
  Result := GetURatioValue(Exif_MaxApertureValue, eiExif);
end;

// ==========================================================================
// == get: MeteringMode                                                  ====
// ==========================================================================
function TExifInfo.GetMeteringMode: Integer;
begin
  Result := Integer(GetTagUShort(Exif_MeteringMode, 0, eiExif, True));
end;

// ==========================================================================
// == get: MeteringModeText                                              ====
// ==========================================================================
function TExifInfo.GetMeteringModeText: string;
begin
  case GetMeteringMode of
    0  : Result := exstrUnknown;
    1  : Result := Metering_Average;
    2  : Result := Metering_CenterWeighted;
    3  : Result := Metering_Spot;
    4  : Result := Metering_MultiSpot;
    5  : Result := Metering_Pattern;
    6  : Result := Metering_Partial;
    255: Result := exstrAther;
    else Result := exstrReserved;
  end;
end;

// ==========================================================================
// == get: MinFNumber                                                    ====
// ==========================================================================
function TExifInfo.GetMinFNumber: Double;
begin
  Result := MaxApatureValue.Value;
  Result := Power(Sqrt(2.0), Result);
end;

// ==========================================================================
// == get: Model                                                         ====
// ==========================================================================
function TExifInfo.GetModel: string;
begin
  Result := GetTagString(Exif_Model, eiTIFF, False);
  if Result = '' then Result := exstrUnknown;
end;

// ==========================================================================
// == get: Orientation                                                   ====
// ==========================================================================
function TExifInfo.GetOrientation: TExifOrientation;
var
  EntryIndex: Integer;
  Res: Word;
begin
  EntryIndex := FEntrys.IndexOfTag(Exif_Orientation, eiTIFF);
  if EntryIndex = -1 then Result := eoTopLeft
  else
  begin
    Res := FEntrys[EntryIndex].GetUShortData(0);
    if InRange(Res, Ord(eoReserved), Ord(eoLeftBottom)) then
      Result := TExifOrientation(Res)
    else
      Result := eoReserved;
  end;
end;

// ==========================================================================
// == get: Photometric                                                   ====
// ==========================================================================
function TExifInfo.GetPhotometric: Integer;
begin
  Result := Integer(GetTagUShort(Exif_Photometric, 0, eiTIFF, True));
end;

// ==========================================================================
// == get: PhotometricText                                               ====
// ==========================================================================
function TExifInfo.GetPhtometricText: string;
begin
  case GetPhotometric of
    2: Result := Photometric_RGB;
    6: Result := Photometric_YCbCr;
    else Result := exstrReserved;
  end;
end;

// ==========================================================================
// == get: PixelXDimension                                               ====
// ==========================================================================
function TExifInfo.GetPixelXDimension: Integer;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FEntrys.IndexOfTag(Exif_PixelXDimension, eiExif);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
    case FEntrys[EntryIndex].Format of
      efUShort: Result := Integer(FEntrys[EntryIndex].GetUShortData(0));
      efULong : Result := Integer(FEntrys[EntryIndex].GetULongData(0));
      else DoError(ERR_FAILEDREAD);
    end;
end;

// ==========================================================================
// == get: PixelYDimension                                               ====
// ==========================================================================
function TExifInfo.GetPixelYDimension: Integer;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FEntrys.IndexOfTag(Exif_PixelYDimension, eiExif);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
    case FEntrys[EntryIndex].Format of
      efUShort: Result := Integer(FEntrys[EntryIndex].GetUShortData(0));
      efULong : Result := Integer(FEntrys[EntryIndex].GetULongData(0));
      else DoError(ERR_FAILEDREAD);
    end;
end;

// ==========================================================================
// == get: PlanarConfiguration                                           ====
// ==========================================================================
function TExifInfo.GetPlanarConfiguration: TExifPlanarConfiguration;
var
  EntryIndex: Integer;
  Res: Word;
begin
  EntryIndex := FEntrys.IndexOfTag(Exif_PlanarConfiguration, eiTIFF);
  if EntryIndex = -1 then Result := pcChunkey
  else
  begin
    Res := FEntrys[EntryIndex].GetUShortData(0);
    case Res of
      1: Result := pcChunkey;
      2: Result := pcPlanar;
      else Result := pcReserved;
    end;
  end;
end;

// ==========================================================================
// == get: PrimaryChromaticities                                         ====
// ==========================================================================
function TExifInfo.GetPrimaryChromaticities(Index: Integer): TExifRational;
var
  EntryIndex: Integer;
  P: PUnsignedRational;
begin
  Result := FRationalValue;
  EntryIndex := FEntrys.IndexOfTag(Exif_PrimaryChromaticities, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    if not InRange(Index, 0, 5) then DoError(ERR_OUTOFRANGE)
    else
    begin
      P := FEntrys[EntryIndex].Data[Index];
      FRationalValue.SetValues(P);
    end;
  end;
end;

// ==========================================================================
// == get: ReferenceBlackWhite                                           ====
// ==========================================================================
function TExifInfo.GetReferenceBlackWhite(Index: Integer): TExifRational;
var
  EntryIndex: Integer;
  P: PUnsignedRational;
begin
  Result := FRationalValue;
  EntryIndex := FEntrys.IndexOfTag(Exif_ReferenceBlackWhite, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    if not InRange(Index, 0, 5) then DoError(ERR_OUTOFRANGE)
    else
    begin
      P := FEntrys[EntryIndex].Data[Index];
      FRationalValue.SetValues(P);
    end;
  end;
end;

// ==========================================================================
// == get: RelatedImageFileFormat                                        ====
// ==========================================================================
function TExifInfo.GetRelatedImageFileFormat: string;
begin
  Result := GetTagString(Exif_RelatedImageFileFormat,
                         eiInteroperability, True);
end;

// ==========================================================================
// == get: RelatedImageLength                                            ====
// ==========================================================================
function TExifInfo.GetRelatedImageLength: Integer;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FEntrys.IndexOfTag(Exif_RelatedImageLength, eiInteroperability);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
    case FEntrys[EntryIndex].Format of
      efUShort: Result := Integer(FEntrys[EntryIndex].GetUShortData(0));
      efULong : Result := Integer(FEntrys[EntryIndex].GetULongData(0));
      else DoError(ERR_FAILEDREAD);
    end;
end;

// ==========================================================================
// == get: RelatedImageWidth                                             ====
// ==========================================================================
function TExifInfo.GetRelatedImageWidth: Integer;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FEntrys.IndexOfTag(Exif_RelatedImageWidth, eiInteroperability);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
    case FEntrys[EntryIndex].Format of
      efUShort: Result := Integer(FEntrys[EntryIndex].GetUShortData(0));
      efULong : Result := Integer(FEntrys[EntryIndex].GetULongData(0));
      else DoError(ERR_FAILEDREAD);
    end;
end;

// ==========================================================================
// == get: RelatedSoundFile                                              ====
// ==========================================================================
function TExifInfo.GetRelatedSoundFile: string;
begin
  Result := GetTagString(Exif_RelatedSoundFile, eiExif, True);
end;

// ==========================================================================
// == get: ResolutionUnit                                                ====
// ==========================================================================
function TExifInfo.GetResolutionUnit: Integer;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag(Exif_ResolutionUnit, eiTIFF);
  if EntryIndex = -1 then Result := 2
  else Result := Integer(FEntrys[EntryIndex].GetUShortData(0));
end;

// ==========================================================================
// == get: ResolutionUnitText                                            ====
// ==========================================================================
function TExifInfo.GetResolutionUnitText: string;
begin
  case GetResolutionUnit of
    2: Result := Resolution_Inch;
    3: Result := Resolution_CM;
    else Result := exstrReserved;
  end;
end;

// ==========================================================================
// == get: RowsPerStrip                                                  ====
// ==========================================================================
function TExifInfo.GetRowsPerStrip: Integer;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FEntrys.IndexOfTag(Exif_RowsPerStrip, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
    case FEntrys[EntryIndex].Format of
      efUShort: Result := Integer(FEntrys[EntryIndex].GetUShortData(0));
      efULong : Result := Integer(FEntrys[EntryIndex].GetULongData(0));
      else DoError(ERR_FAILEDREAD);
    end;
end;

// ==========================================================================
// == get: SamplesPerPixel                                               ====
// ==========================================================================
function TExifInfo.GetSamplesPerPixel: Integer;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag(Exif_SamplesPerPixel, eiTIFF);
  if EntryIndex = -1 then Result := 3
  else Result := Integer(FEntrys[EntryIndex].GetUShortData(0));
end;

// ==========================================================================
// == get: SceneType                                                     ====
// ==========================================================================
function TExifInfo.GetSceneType: Integer;
var
  Buffer: Byte;
  Mem: TMemoryStream;
begin
  Mem := TMemoryStream(GetTagPointer(Exif_SceneType, eiExif, False));
  if Mem = nil then Result := 1
  else
  begin
    Mem.Position := 0;
    Mem.ReadBuffer(Buffer, 1);
    Result := Integer(Buffer);
  end;
end;

// ==========================================================================
// == get: SensingMethod                                                 ====
// ==========================================================================
function TExifInfo.GetSensingMethod: Integer;
begin
  Result := Integer(GetTagUShort(Exif_SensingMethod, 0, eiExif, True));
end;

// ==========================================================================
// == get: SensingMethodText                                             ====
// ==========================================================================
function TExifInfo.GetSensingMethodText: string;
begin
  case GetSensingMethod of
    1: Result := exstrUndefined;
    2: Result := SensingMethod_1Chip;
    3: Result := SensingMethod_2Chip;
    4: Result := SensingMethod_3Chip;
    5: Result := SensingMethod_SeekColor;
    7: Result := SensingMethod_3Line;
    8: Result := SensingMethod_SeekLinear;
    else Result := exstrReserved;
  end;
end;

// ==========================================================================
// == get: ShutterSpeedValue                                             ====
// ==========================================================================
function TExifInfo.GetShutterSpeedTime: Double;
begin
  Result := ShutterSpeedValue.Value;
  Result := 1.0 / Power(2.0, Result);
end;

// ==========================================================================
// == get: ShutterSpeedValue                                             ====
// ==========================================================================
function TExifInfo.GetShutterSpeedValue: TExifRational;
begin
  Result := GetSRatioValue(Exif_ShutterSpeedValue, eiExif);
end;

// ==========================================================================
// == get: Software                                                      ====
// ==========================================================================
function TExifInfo.GetSoftware: string;
begin
  Result := GetTagString(Exif_Software, eiTIFF, False);
  if Result = '' then Result := exstrUnknown;
end;

// ==========================================================================
// == get: SpectralSensivity                                             ====
// ==========================================================================
function TExifInfo.GetSpectralSensivity: string;
begin
  Result := GetTagString(Exif_SpectralSensitivity, eiExif, True);
end;

// ==========================================================================
// == method: 符号付き分数の取得                                         ====
// ==========================================================================
function TExifInfo.GetSRatioValue(ATag: Word; AIFD: TExifIFD): TExifRational;
var
  P: PSignedRational;
begin
  P := GetTagPointer(ATag, AIFD, True);
  FRationalValue.SetSingedValues(P);
  Result := FRationalValue;
end;

// ==========================================================================
// == get: StripByteCounts                                               ====
// ==========================================================================
function TExifInfo.GetStripByteCounts(Index: Integer): Integer;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FEntrys.IndexOfTag(Exif_StripByteCounts, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
    case FEntrys[EntryIndex].Format of
      efUShort: Result := Integer(FEntrys[EntryIndex].GetUShortData(Index));
      efULong : Result := Integer(FEntrys[EntryIndex].GetULongData(Index));
      else      DoError(ERR_FAILEDREAD);
    end;
end;

// ==========================================================================
// == get: StripByteCountsCount                                          ====
// ==========================================================================
function TExifInfo.GetStripByteCountsCount: Integer;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag(Exif_StripByteCounts, eiTIFF);
  if EntryIndex = -1 then Result := 0
  else Result := FEntrys[EntryIndex].DataCount;
end;

// ==========================================================================
// == get: StripOffsets                                                  ====
// ==========================================================================
function TExifInfo.GetStripOffsets(Index: Integer): Cardinal;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FEntrys.IndexOfTag(Exif_StripOffsets, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
    case FEntrys[EntryIndex].Format of
      efUShort: Result := FEntrys[EntryIndex].GetUShortData(Index);
      efULong : Result := FEntrys[EntryIndex].GetULongData(Index);
      else DoError(ERR_FAILEDREAD);
    end;
end;

// ==========================================================================
// == get: StripOffsetsCount                                             ====
// ==========================================================================
function TExifInfo.GetStripOffsetsCount: Integer;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag(Exif_StripOffsets, eiTIFF);
  if EntryIndex = -1 then Result := 0
  else Result := FEntrys[EntryIndex].DataCount;
end;

// ==========================================================================
// == get: StripsPerImage                                                ====
// ==========================================================================
function TExifInfo.GetStripsPerImage: Integer;
var
  RowStrip: Integer;
begin
  RowStrip := GetRowsPerStrip;
  Result := Trunc((GetImageLength + RowStrip - 1) / RowStrip);
end;

// ==========================================================================
// == get: SubjectDistance                                               ====
// ==========================================================================
function TExifInfo.GetSubjectDistance: TExifRational;
begin
  Result := GetURatioValue(Exif_SubjectDistance, eiExif);
end;

// ==========================================================================
// == get: SubjectLocation                                               ====
// ==========================================================================
function TExifInfo.GetSubjectLocation(const Index: Integer): Integer;
begin
  Result := Integer(GetTagUShort(Exif_SubjectLocation, Index, eiExif, True));
end;

// ==========================================================================
// == get: SubsecTime                                                    ====
// ==========================================================================
function TExifInfo.GetSubsecTime: Integer;
var
  S: string;
begin
  Result := 0;
  S := GetTagString(Exif_SubSecTime, eiExif, True);
  if not TryStrToInt(S, Result) then DoError(ERR_FAILEDSTRTODATE);
end;

// ==========================================================================
// == get: SubsecTimeDigitized                                           ====
// ==========================================================================
function TExifInfo.GetSubsecTimeDigitized: Integer;
var
  S: string;
begin
  Result := 0;
  S := GetTagString(Exif_SubSecTimeDigitized, eiExif, True);
  if not TryStrToInt(S, Result) then DoError(ERR_FAILEDSTRTODATE);
end;

// ==========================================================================
// == get: SubsecTimeOriginal                                            ====
// ==========================================================================
function TExifInfo.GetSubsecTimeOriginal: Integer;
var
  S: string;
begin
  Result := 0;
  S := GetTagString(Exif_SubSecTimeOriginal, eiExif, True);
  if not TryStrToInt(S, Result) then DoError(ERR_FAILEDSTRTODATE);
end;

// ==========================================================================
// == method: タグの値をポインタで取得                                   ====
// ==========================================================================
function TExifInfo.GetTagPointer(ATag: Word; AIFD: TExifIFD;
  AllowError: Boolean): Pointer;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag(ATag, AIFD);
  if EntryIndex = -1 then
  begin
    Result := nil;
    if AllowError then DoError(ERR_TAGNOTFOUND);
  end
  else
    Result := FEntrys[EntryIndex].Data[0];
end;

// ==========================================================================
// == method: タグの値を文字列値で取得                                   ====
// ==========================================================================
function TExifInfo.GetTagString(ATag: Word; AIFD: TExifIFD;
  AllowError: Boolean): string;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag(ATag, AIFD);
  if EntryIndex = -1 then
  begin
    Result := '';
    if AllowError then DoError(ERR_TAGNOTFOUND);
  end
  else
    Result := FEntrys[EntryIndex].GetStringData;
end;

// ==========================================================================
// == method: タグの値をByte値で取得                                     ====
// ==========================================================================
function TExifInfo.GetTagUByte(ATag: Word; DataIndex: Integer; AIFD: TExifIFD;
  AllowError: Boolean): Byte;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag(ATag, AIFD);
  if EntryIndex = -1 then
  begin
    Result := 0;
    if AllowError then DoError(ERR_TAGNOTFOUND);
  end
  else
    Result := FEntrys[EntryIndex].GetUByteData(DataIndex);
end;

// ==========================================================================
// == method: タグの値をLongWord値で取得                                 ====
// ==========================================================================
function TExifInfo.GetTagULong(ATag: Word; DataIndex: Integer; AIFD: TExifIFD;
  AllowError: Boolean): LongWord;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag(ATag, AIFD);
  if EntryIndex = -1 then
  begin
    Result := 0;
    if AllowError then DoError(ERR_TAGNOTFOUND);
  end
  else
    Result := FEntrys[EntryIndex].GetULongData(DataIndex);
end;

// ==========================================================================
// == method: タグからWord値を取得                                       ====
// ==========================================================================
function TExifInfo.GetTagUShort(ATag: Word; DataIndex: Integer; AIFD: TExifIFD;
  AllowError: Boolean): Word;
var
  EntryIndex: Integer;
begin
  EntryIndex := FEntrys.IndexOfTag(ATag, AIFD);
  if EntryIndex = -1 then
  begin
    Result := 0;
    if AllowError then DoError(ERR_TAGNOTFOUND);
  end
  else
    Result := FEntrys[EntryIndex].GetUShortData(DataIndex);
end;

// ==========================================================================
// == get: ThmArtist                                                     ====
// ==========================================================================
function TExifInfo.GetThmArtist: string;
var
  EntryIndex: Integer;
  P: PChar;
begin
  Result := exstrUnknown;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_Artist, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    P := FThmEntrys[EntryIndex].Data[0];
    if Assigned(P) then Result := string(P);
  end;
end;

// ==========================================================================
// == get: ThmBitsPerSample                                              ====
// ==========================================================================
function TExifInfo.GetThmBitsPerSample(Index: Integer): Integer;
var
  EntryIndex: Integer;
begin
  Result := 8;
  if not InRange(Index, 0, 2) then DoError(ERR_OUTOFRANGE)
  else
  begin
    EntryIndex := FThmEntrys.IndexOfTag(Exif_BitsPerSample, eiTIFF);
    if EntryIndex >=0 then
      Result := Integer(FThmEntrys[EntryIndex].GetUShortData(Index));
  end;
end;

// ==========================================================================
// == get: ThmCompression                                                ====
// ==========================================================================
function TExifInfo.GetThmCompression: Integer;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_Compression, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else Result := Integer(FThmEntrys[EntryIndex].GetUShortData(0));
end;

// ==========================================================================
// == get: ThmCompressionText                                            ====
// ==========================================================================
function TExifInfo.GetThmCompressionText: string;
begin
  case GetThmCompression of
    1: Result := Compress_None;
    6: Result := Compress_Jpeg;
    else Result := exstrReserved;
  end;
end;

// ==========================================================================
// == get: ThmCopyright                                                  ====
// ==========================================================================
function TExifInfo.GetThmCopyright: string;
var
  EntryIndex: Integer;
  P: PChar;
begin
  Result := exstrUnknown;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_Copyright, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    P := FThmEntrys[EntryIndex].Data[0];
    if Assigned(P) then Result := string(P);
  end;
end;

// ==========================================================================
// == get: ThmDateTime                                                   ====
// ==========================================================================
function TExifInfo.GetThmDateTime: TDateTime;
begin
  Result := StringDateTime(GetThmDateTimeText);
end;

// ==========================================================================
// == get: ThmDateTimeText                                               ====
// ==========================================================================
function TExifInfo.GetThmDateTimeText: string;
var
  EntryIndex: Integer;
  P: PChar;
begin
  EntryIndex := FThmEntrys.IndexOfTag(Exif_DateTime, eiTIFF);
  if EntryIndex = -1 then Result := exstrUnknown
  else
  begin
    P := FThmEntrys[EntryIndex].Data[0];
    if P = nil then Result := exstrUnknown else Result := string(P);
  end;
end;

// ==========================================================================
// == get: ThmExifIFDPointer                                             ====
// ==========================================================================
function TExifInfo.GetThmExifIFDPointer: LongWord;
var
  EntryIndex: Integer;
begin
  EntryIndex := FThmEntrys.IndexOfTag($8769, eiTIFF);
  if EntryIndex = -1 then Result := 0
  else Result := FThmEntrys[EntryIndex].GetULongData(0);
end;

// ==========================================================================
// == get: ThmImageDescription                                           ====
// ==========================================================================
function TExifInfo.GetThmImageDescription: string;
var
  EntryIndex: Integer;
  P: PChar;
begin
  Result := exstrUnknown;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_ImageDescription, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    P := FThmEntrys[EntryIndex].Data[0];
    if Assigned(P) then Result := string(P);
  end;
end;

// ==========================================================================
// == get: ThmImageLength                                                ====
// ==========================================================================
function TExifInfo.GetThmImageLength: Integer;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_ImageLength, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
    case FThmEntrys[EntryIndex].Format of
      efUShort: Result := Integer(FThmEntrys[EntryIndex].GetUShortData(0));
      efULong : Result := Integer(FThmEntrys[EntryIndex].GetULongData(0));
      else DoError(ERR_FAILEDREAD);
    end;
end;

// ==========================================================================
// == get: ThmImageWidth                                                 ====
// ==========================================================================
function TExifInfo.GetThmImageWidth: Integer;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_ImageWidth, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
    case FThmEntrys[EntryIndex].Format of
      efUShort: Result := Integer(FThmEntrys[EntryIndex].GetUShortData(0));
      efULong : Result := Integer(FThmEntrys[EntryIndex].GetULongData(0));
      else DoError(ERR_FAILEDREAD);
    end;
end;

// ==========================================================================
// == get: ThmInteroperabilityIFDPointer                                 ====
// ==========================================================================
function TExifInfo.GetThmInteroperabilityIFDPointer: LongWord;
var
  EntryIndex: Integer;
begin
  EntryIndex := FThmEntrys.IndexOfTag(Exif_InteroperabilityIFDPointer, eiExif);
  if EntryIndex = -1 then Result := 0
  else Result := FThmEntrys[EntryIndex].GetULongData(0);
end;

// ==========================================================================
// == get: ThmInteroperabilityIndex                                      ====
// ==========================================================================
function TExifInfo.GetThmInteroperabilityIndex: string;
var
  EntryIndex: Integer;
  P: PChar;
begin
  Result := exstrUnknown;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_InteroperabilityIndex,
                                      eiInteroperability);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    P := FThmEntrys[EntryIndex].Data[0];
    if P = nil then DoError(ERR_FAILEDREAD) else Result := string(P);
  end;
end;

// ==========================================================================
// == get: ThmJPEGInterchangeFormat                                      ====
// ==========================================================================
function TExifInfo.GetThmJPEGInterchangeFormat: Cardinal;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_JPEGInterchangeFormat, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else Result := FThmEntrys[EntryIndex].GetULongData(0);
end;

// ==========================================================================
// == get: ThmJPEGInterchangeFormatLength                                ====
// ==========================================================================
function TExifInfo.GetThmJPEGInterchangeFormatLength: Cardinal;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_JPEGInterchangeFormatLength, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else Result := FThmEntrys[EntryIndex].GetULongData(0);
end;

// ==========================================================================
// == get: ThmMake                                                       ====
// ==========================================================================
function TExifInfo.GetThmMake: string;
var
  EntryIndex: Integer;
  P: PChar;
begin
  Result := exstrUnknown;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_Make, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    P := FThmEntrys[EntryIndex].Data[0];
    if Assigned(P) then Result := string(P);
  end;
end;

// ==========================================================================
// == get: ThmModel                                                      ====
// ==========================================================================
function TExifInfo.GetThmModel: string;
var
  EntryIndex: Integer;
  P: PChar;
begin
  Result := exstrUnknown;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_Model, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    P := FThmEntrys[EntryIndex].Data[0];
    if Assigned(P) then Result := string(P);
  end;
end;

// ==========================================================================
// == get: ThmOrientation                                                ====
// ==========================================================================
function TExifInfo.GetThmOrientation: TExifOrientation;
var
  EntryIndex: Integer;
  V: Word;
begin
  EntryIndex := FThmEntrys.IndexOfTag(Exif_Orientation, eiTIFF);
  if EntryIndex = -1 then Result := eoTopLeft
  else
  begin
    V := FThmEntrys[EntryIndex].GetUShortData(0);
    if InRange(V, 1, 8) then Result := TExifOrientation(V)
    else Result := eoReserved;
  end;
end;

// ==========================================================================
// == get: ThmPhotometric                                                ====
// ==========================================================================
function TExifInfo.GetThmPhotometric: Integer;
var
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_Photometric, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else Result := Integer(FThmEntrys[EntryIndex].GetUShortData(0));
end;

// ==========================================================================
// == get: ThmPhotometricText                                            ====
// ==========================================================================
function TExifInfo.GetThmPhotometricText: string;
begin
  case GetThmPhotometric of
    2: Result := Photometric_RGB;
    6: Result := Photometric_YCbCr;
    else Result := exstrReserved;
  end;
end;

// ==========================================================================
// == get: ThmPlanarConfiguration                                        ====
// ==========================================================================
function TExifInfo.GetThmPlanarConfiguration: TExifPlanarConfiguration;
var
  EntryIndex: Integer;
  V: Word;
begin
  EntryIndex := FThmEntrys.IndexOfTag(Exif_PlanarConfiguration, eiTIFF);
  if EntryIndex = -1 then Result := pcChunkey
  else
  begin
    V := FThmEntrys[EntryIndex].GetUShortData(0);
    if InRange(V, 1, 2) then Result := TExifPlanarConfiguration(V)
    else Result := pcReserved;
  end;
end;

// ==========================================================================
// == get: ThmPrimaryChromaticities                                      ====
// ==========================================================================
function TExifInfo.GetThmPrimaryChromaticities(Index: Integer): TExifRational;
var
  EntryIndex: Integer;
  P: PUnsignedRational;
begin
  Result := FRationalValue;
  if not InRange(Index, 0, 5) then DoError(ERR_OUTOFRANGE)
  else
  begin
    EntryIndex := FThmEntrys.IndexOfTag(Exif_PrimaryChromaticities, eiTIFF);
    if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
    else
    begin
      P := FThmEntrys[EntryIndex].Data[Index];
      FRationalValue.SetValues(P);
    end;
  end;
end;

// ==========================================================================
// == get: ThmResolutionUnit                                             ====
// ==========================================================================
function TExifInfo.GetThmResolutionUnit: Integer;
var
  EntryIndex: Integer;
begin
  EntryIndex := FThmEntrys.IndexOfTag(Exif_ResolutionUnit, eiTIFF);
  if EntryIndex = -1 then Result := 2
  else Result := Integer(FThmEntrys[EntryIndex].GetUShortData(0));
end;

// ==========================================================================
// == get: ThmResolutionUnitText                                         ====
// ==========================================================================
function TExifInfo.GetThmResolutionUnitText: string;
begin
  case GetThmResolutionUnit of
    2: Result := Resolution_Inch;
    3: Result := Resolution_CM;
    else Result := exstrReserved;
  end;
end;

// ==========================================================================
// == get: ThmRowsPerStrip                                               ====
// ==========================================================================
function TExifInfo.GetThmRowsPerStrip: Integer;
var
  Entry: TEntryItem;
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_RowsPerStrip, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    Entry := FThmEntrys[EntryIndex];
    case Entry.Format of
      efUShort: Result := Integer(Entry.GetUShortData(0));
      efULong : Result := Integer(Entry.GetULongData(0));
      else DoError(ERR_FAILEDREAD);
    end;
  end;
end;

// ==========================================================================
// == get: ThmSamplesPerPixel                                            ====
// ==========================================================================
function TExifInfo.GetThmSamplesPerPixel: Integer;
var
  EntryIndex: Integer;
begin
  EntryIndex := FThmEntrys.IndexOfTag(Exif_SamplesPerPixel, eiTIFF);
  if EntryIndex = -1 then Result := 3
  else Result := Integer(FThmEntrys[EntryIndex].GetUShortData(0));
end;

// ==========================================================================
// == get: ThmSoftware                                                   ====
// ==========================================================================
function TExifInfo.GetThmSoftware: string;
var
  EntryIndex: Integer;
  P: PChar;
begin
  Result := exstrUnknown;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_Software, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    P := FThmEntrys[EntryIndex].Data[0];
    if Assigned(P) then Result := string(P);
  end;
end;

// ==========================================================================
// == get: ThmStripByteCounts                                            ====
// ==========================================================================
function TExifInfo.GetThmStripByteCounts(Index: Integer): Integer;
var
  Entry: TEntryItem;
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_StripByteCounts, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    Entry := FThmEntrys[EntryIndex];
    if not InRange(Index, 0, Entry.DataCount - 1) then DoError(ERR_OUTOFRANGE)
    else
      case Entry.Format of
        efUShort: Result := Integer(Entry.GetUShortData(Index));
        efULong : Result := Integer(Entry.GetULongData(Index));
        else DoError(ERR_FAILEDREAD);
      end;
  end;
end;

// ==========================================================================
// == get: ThmStripByteCountsCount                                       ====
// ==========================================================================
function TExifInfo.GetThmStripByteCountsCount: Integer;
var
  EntryIndex: Integer;
begin
  EntryIndex := FThmEntrys.IndexOfTag(Exif_StripByteCounts, eiTIFF);
  if EntryIndex = -1 then Result := 0
  else Result := FThmEntrys[EntryIndex].DataCount;
end;

// ==========================================================================
// == get: ThmStripOffsets                                               ====
// ==========================================================================
function TExifInfo.GetThmStripOffsets(Index: Integer): Cardinal;
var
  Entry: TEntryItem;
  EntryIndex: Integer;
begin
  Result := 0;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_StripOffsets, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    Entry := FThmEntrys[EntryIndex];
    if not InRange(Index, 0, Entry.DataCount - 1) then DoError(ERR_OUTOFRANGE)
    else
      case Entry.Format of
        efUShort: Result := Entry.GetUShortData(Index);
        efULong : Result := Entry.GetULongData(Index);
        else DoError(ERR_FAILEDREAD);
      end;
  end;
end;

// ==========================================================================
// == get: ThmStripOffsetsCount                                          ====
// ==========================================================================
function TExifInfo.GetThmStripOffsetsCount: Integer;
var
  EntryIndex: Integer;
begin
  EntryIndex := FThmEntrys.IndexOfTag(Exif_StripOffsets, eiTIFF);
  if EntryIndex = -1 then Result := 0
  else Result := FThmEntrys[EntryIndex].DataCount;
end;

// ==========================================================================
// == get: ThmTransferFunction                                           ====
// ==========================================================================
function TExifInfo.GetThmTransferFunction(Index: Integer): Word;
var
  EntryIndex: Integer;
begin
  Result := 0;
  if not InRange(Index, 0, 766) then DoError(ERR_OUTOFRANGE)
  else
  begin
    EntryIndex := FThmEntrys.IndexOfTag(Exif_TransferFunction, eiTIFF);
    if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
    else Result := FThmEntrys[EntryIndex].GetUShortData(Index);
  end;
end;

// ==========================================================================
// == get: ThmWhitePoint                                                 ====
// ==========================================================================
function TExifInfo.GetThmWhitePoint(Index: Integer): TExifRational;
var
  EntryIndex: Integer;
  P: PUnsignedRational;
begin
  Result := FRationalValue;
  if not InRange(Index, 0, 1) then DoError(ERR_OUTOFRANGE)
  else
  begin
    EntryIndex := FThmEntrys.IndexOfTag(Exif_WhitePoint, eiTIFF);
    if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
    else
    begin
      P := FThmEntrys[EntryIndex].Data[Index];
      FRationalValue.SetValues(P);
    end;
  end;
end;

// ==========================================================================
// == get: ThmXResolution                                                ====
// ==========================================================================
function TExifInfo.GetThmXResolution: TExifRational;
var
  EntryIndex: Integer;
  P: PUnsignedRational;
begin
  EntryIndex := FThmEntrys.IndexOfTag(Exif_XResolution, eiTIFF);
  if EntryIndex = -1 then FRationalValue.SetValues(72, 1)
  else
  begin
    P := FThmEntrys[EntryIndex].Data[0];
    FRationalValue.SetValues(P);
  end;
  Result := FRationalValue;
end;

// ==========================================================================
// == get: ThmYCbCrCoefficients                                          ====
// ==========================================================================
function TExifInfo.GetThmYCbCrCoefficients(Index: Integer): TExifRational;
var
  EntryIndex: Integer;
  P: PUnsignedRational;
begin
  Result := FRationalValue;
  if not InRange(Index, 0, 2) then DoError(ERR_OUTOFRANGE)
  else
  begin
    EntryIndex := FThmEntrys.IndexOfTag(Exif_YCbCrCoefficients, eiTIFF);
    if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
    else
    begin
      P := FThmEntrys[EntryIndex].Data[Index];
      FRationalValue.SetValues(P);
    end;
  end;
end;

// ==========================================================================
// == get: ThmYCbCrPositioning                                           ====
// ==========================================================================
function TExifInfo.GetThmYCbCrPositioning: TExifYCbCrPositioning;
var
  EntryIndex: Integer;
begin
  Result := epReserved;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_YCbCrPositioning, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
    case FThmEntrys[EntryIndex].GetUShortData(0) of
      1: Result := epCentered;
      2: Result := epCosited;
    end;
end;

// ==========================================================================
// == get: ThmYCbCrSubSampling                                           ====
// ==========================================================================
function TExifInfo.GetThmYCbCrSubSampling: TExifSubSampling;
var
  EntryIndex: Integer;
  Num1, Num2: Word;
begin
  Result := ssReserved;
  EntryIndex := FThmEntrys.IndexOfTag(Exif_YCbCrSubSampling, eiExif);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    Num1 := FThmEntrys[EntryIndex].GetUShortData(0);
    if Num1 = 2 then
    begin
      Num2 := FThmEntrys[EntryIndex].GetUShortData(1);
      case Num2 of
        1: Result := ss422;
        2: Result := ss420;
      end;
    end;
  end;
end;

// ==========================================================================
// == get: ThmYResolution                                                ====
// ==========================================================================
function TExifInfo.GetThmYResolution: TExifRational;
var
  EntryIndex: Integer;
  P: PUnsignedRational;
begin
  EntryIndex := FThmEntrys.IndexOfTag(Exif_YResolution, eiTIFF);
  if EntryIndex = -1 then FRationalValue.SetValues(72, 1)
  else
  begin
    P := FThmEntrys[EntryIndex].Data[0];
    FRationalValue.SetValues(P);
  end;
  Result := FRationalValue;
end;

// ==========================================================================
// == method: サムネイルの取得                                           ====
// ==========================================================================
procedure TExifInfo.GetThumbnail(Thumb: TBitmap);
var
  Jpg: TJPEGImage;
begin
  Jpg := TJPEGImage.Create;
  try
    GetThumbnail(Jpg);
    Thumb.Assign(Jpg);
  finally
    Jpg.Free;
  end;
end;

// ==========================================================================
// == method: サムネイルの取得                                           ====
// ==========================================================================
procedure TExifInfo.GetThumbnail(Thumb: TJPEGImage);
var
  EntryIndex: Integer;
  Image: TFileStream;
  ImagePos: Cardinal;
  isJpegThumbnail: Boolean;
begin
  EntryIndex := FThmEntrys.IndexOfTag(Exif_Compression, eiTIFF);
  isJpegThumbnail := EntryIndex >= 0;
  if isJpegThumbnail then isJpegThumbnail := (GetThmCompression = 6);
  if isJpegThumbnail then
  begin
    ImagePos := GetThmJPEGInterchangeFormat;
    isJpegThumbnail := ImagePos > 0;
  end
  else ImagePos := 0;
  if isJpegThumbnail then
  begin
    Image := TFileStream.Create(FImageFileName, fmOpenRead);
    try
      Image.Seek(FOffsetCardinalPoint + Int64(ImagePos), soBeginning);
      Thumb.LoadFromStream(Image);
    finally
      Image.Free;
    end;
  end
  else ExtractThumbnail(FImageFileName, Thumb);
end;

// ==========================================================================
// == get: TransferFunction                                              ====
// ==========================================================================
function TExifInfo.GetTransferFunction(Index: Integer): Word;
begin
  Result := 0;
  if not InRange(Index, 0, 767) then DoError(ERR_OUTOFRANGE)
  else Result := GetTagUShort(Exif_TransferFunction, Index, eiTIFF, True);
end;

// ==========================================================================
// == method: 符号なし分数の取得                                         ====
// ==========================================================================
function TExifInfo.GetURatioValue(ATag: Word; AIFD: TExifIFD): TExifRational;
var
  P: PUnsignedRational;
begin
  P := GetTagPointer(ATag, AIFD, True);
  FRationalValue.SetValues(P);
  Result := FRationalValue;
end;

// ==========================================================================
// == get: UserComment                                                   ====
// ==========================================================================
function TExifInfo.GetUserComment: WideString;
var
  CommentStyle: TExifUserCommentStyle;
  Mem: TMemoryStream;
begin
  Result := exstrUnknown;
  CommentStyle := GetUserCommentStyle;
  Mem := TMemoryStream(GetTagPointer(Exif_UserComment, eiExif, True));
  Mem.Position := 8;
  case CommentStyle of
    ucAscii  : Result := ReadAsciiFromMemory(Mem);
    ucJIS    : Result := ReadJISFromMemory(Mem);
    ucUnicode: Result := ReadUnicodeFromMemory(Mem);
    else       Result := ReadAsciiFromMemory(Mem);
  end;
end;

// ==========================================================================
// == get: UserCommentStyle                                              ====
// ==========================================================================
function TExifInfo.GetUserCommentStyle: TExifUserCommentStyle;
var
  Buffer: Byte;
  L: Integer;
  Mem: TMemoryStream;
  Styles: string;
begin
  Result := ucUnknown;
  Mem := TMemoryStream(GetTagPointer(Exif_UserComment, eiExif, False));
  if Assigned(Mem) then
  begin
    Mem.Position := 0;
    Styles := '';
    for L := 0 to 7 do
    begin
      Mem.ReadBuffer(Buffer, 1);
      if Buffer <> 0 then Styles := Styles + Chr(Buffer);
    end;
    if Styles = 'ASCII' then Result := ucAscii;
    if Styles = 'JIS' then Result := ucJIS;
    if Styles = 'UNICODE' then Result := ucUnicode;
    if Styles = '' then Result := ucUndefined;
  end;
end;

// ==========================================================================
// == get: WhitePoint                                                    ====
// ==========================================================================
function TExifInfo.GetWhitePoint(Index: Integer): TExifRational;
var
  EntryIndex: Integer;
  P: Pointer;
begin
  Result := FRationalValue;
  EntryIndex := FEntrys.IndexOfTag(Exif_WhitePoint, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    if not InRange(Index, 0, 1) then DoError(ERR_OUTOFRANGE)
    else
    begin
      P := FEntrys[EntryIndex].Data[Index];
      FRationalValue.SetValues(PUnsignedRational(P));
    end;
  end;
end;

// ==========================================================================
// == get: XResolution                                                   ====
// ==========================================================================
function TExifInfo.GetXResolution: TExifRational;
var
  EntryIndex: Integer;
  P: Pointer;
begin
  EntryIndex := FEntrys.IndexOfTag(Exif_XResolution, eiTIFF);
  if EntryIndex = -1 then FRationalValue.SetValues(72, 1)
  else
  begin
    P := FEntrys[EntryIndex].Data[0];
    FRationalValue.SetValues(PUnsignedRational(P));
  end;
  Result := FRationalValue;
end;

// ==========================================================================
// == get: YCbCrCoefficients                                             ====
// ==========================================================================
function TExifInfo.GetYCbCrCoefficients(Index: Integer): TExifRational;
var
  EntryIndex: Integer;
  P: PUnsignedRational;
begin
  Result := FRationalValue;
  EntryIndex := FEntrys.IndexOfTag(Exif_YCbCrCoefficients, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    if not InRange(Index, 0, 2) then DoError(ERR_OUTOFRANGE)
    else
    begin
      P := FEntrys[EntryIndex].Data[Index];
      FRationalValue.SetValues(P);
    end;
  end;
end;

// ==========================================================================
// == get: YCbCrPositioning                                              ====
// ==========================================================================
function TExifInfo.GetYCbCrPositioning: TExifYCbCrPositioning;
var
  EntryIndex: Integer;
  Res: Word;
begin
  EntryIndex := FEntrys.IndexOfTag(Exif_YCbCrPositioning, eiTIFF);
  if EntryIndex = -1 then Result := epCentered
  else
  begin
    Res := FEntrys[EntryIndex].GetUShortData(0);
    case Res of
      1: Result := epCentered;
      2: Result := epCosited;
      else Result := epReserved;
    end;
  end;
end;

// ==========================================================================
// == get: YCbCrSubSampling                                              ====
// ==========================================================================
function TExifInfo.GetYCbCrSubSampling: TExifSubSampling;
var
  EntryIndex: Integer;
  Num1, Num2: Word;
begin
  Result := ssReserved;
  EntryIndex := FEntrys.IndexOfTag(Exif_YCbCrSubSampling, eiTIFF);
  if EntryIndex = -1 then DoError(ERR_TAGNOTFOUND)
  else
  begin
    Num1 := FEntrys[EntryIndex].GetUShortData(0);
    Num2 := FEntrys[EntryIndex].GetUShortData(1);
    if Num1 = 2 then
      case Num2 of
        1: Result := ss422;
        2: Result := ss420;
      end;
  end;
end;

// ==========================================================================
// == get: YResolution                                                   ====
// ==========================================================================
function TExifInfo.GetYResolution: TExifRational;
var
  EntryIndex: Integer;
  P: Pointer;
begin
  EntryIndex := FEntrys.IndexOfTag(Exif_YResolution, eiTIFF);
  if EntryIndex = -1 then FRationalValue.SetValues(72, 1)
  else
  begin
    P := FEntrys[EntryIndex].Data[0];
    FRationalValue.SetValues(PUnsignedRational(P));
  end;
  Result := FRationalValue;
end;

// ==========================================================================
// == method: Exif、DCF形式か調べる                                      ====
// ==========================================================================
function TExifInfo.IsExif(const FileName: string): Boolean;
begin
  Result := FindApp1Marker(FileName) > 0;
end;

// ==========================================================================
// == vir method: オブジェクトが破棄される                               ====
// ==========================================================================
procedure TExifInfo.ObjectDeletion(AObject: TObject);
begin
  if not (csDestroying in ComponentState) then
  begin
    if AObject = FRationalValue then FRationalValue := TExifRational.Create(Self);
  end;
end;

// ==========================================================================
// == method: Exifヘッダをとばす                                         ====
// ==========================================================================
procedure TExifInfo.SeekExifHeader(Stream: TStream);
var
  Buffer: Byte;
  NullCount: Integer;
begin
  NullCount := 0;
  repeat
    Stream.ReadBuffer(Buffer, 1);
    if Buffer = 0 then Inc(NullCount);
  until (NullCount = 2) or ((NullCount > 1) and (Buffer <> 0));
  if Buffer <> 0 then Stream.Seek(-1, soCurrent);
end;

// ==========================================================================
// == set: Artist                                                        ====
// ==========================================================================
procedure TExifInfo.SetArtist(const Value: string);
begin
  if IsAscii(Value) then
    FEntrys.WriteStringData(Exif_Artist, eiTIFF, Value)
  else
    DoError(ERR_ASCIIONLY);
end;

// ==========================================================================
// == set: Copyright                                                     ====
// ==========================================================================
procedure TExifInfo.SetCopyright(const Value: string);
begin
  if IsAscii(Value) then
    FEntrys.WriteStringData(Exif_Copyright, eiTIFF, Value)
  else
    DoError(ERR_ASCIIONLY);
end;

// ==========================================================================
// == set: DateTime                                                      ====
// ==========================================================================
procedure TExifInfo.SetDateTime(const Value: TDateTime);
var
  S: string;
  Y, Mon, D, H, Min, Sec, MSec: Word;
begin
  DecodeDate(Value, Y, Mon, D);
  DecodeTime(Value, H, Min, Sec, MSec);
  S := Format('%.4d:%.2d:%.2d %.2d:%.2d:%.2d', [Y, Mon, D, H, Min, Sec]);
  SetDateTimeText(S);
end;

// ==========================================================================
// == set: DateTimeDigitized                                             ====
// ==========================================================================
procedure TExifInfo.SetDateTimeDigitized(const Value: TDateTime);
var
  S: string;
  Y, Mon, D, H, Min, Sec, MSec: Word;
begin
  DecodeDate(Value, Y, Mon, D);
  DecodeTime(Value, H, Min, Sec, MSec);
  S := Format('%.4d:%.2d:%.2d %.2d:%.2d:%.2d', [Y, Mon, D, H, Min, Sec]);
  SetDateTimeDigitizedText(S);
end;

// ==========================================================================
// == set: DateTimeDigitizedText                                         ====
// ==========================================================================
procedure TExifInfo.SetDateTimeDigitizedText(const Value: string);
var
  S: string;
begin
  if Length(Value) > 19 then S := Copy(Value, 1, 19) else S := Value;
  if Length(S) < 19 then S := S + StringOfChar(' ', 19 - Length(S));
  FEntrys.WriteStringData(Exif_DateTimeDigitized, eiExif, S);
end;

// ==========================================================================
// == set: DateTimeOriginal                                              ====
// ==========================================================================
procedure TExifInfo.SetDateTimeOriginal(const Value: TDateTime);
var
  S: string;
  Y, Mon, D, H, Min, Sec, MSec: Word;
begin
  DecodeDate(Value, Y, Mon, D);
  DecodeTime(Value, H, Min, Sec, MSec);
  S := Format('%.4d:%.2d:%.2d %.2d:%.2d:%.2d', [Y, Mon, D, H, Min, Sec]);
  SetDateTimeOriginalText(S);
end;

// ==========================================================================
// == set: DateTimeOriginalText                                          ====
// ==========================================================================
procedure TExifInfo.SetDateTimeOriginalText(const Value: string);
var
  S: string;
begin
  if Length(Value) > 19 then S := Copy(Value, 1, 19) else S := Value;
  if Length(S) < 19 then S := S + StringOfChar(' ', 19 - Length(S));
  FEntrys.WriteStringData(Exif_DateTimeOriginal, eiExif, S);
end;

// ==========================================================================
// == set: DateTimeText                                                  ====
// ==========================================================================
procedure TExifInfo.SetDateTimeText(const Value: string);
var
  S: string;
begin
  // 19文字に限定
  if Length(Value) > 19 then S := Copy(Value, 1, 19) else S := Value;
  if Length(S) < 19 then S := S + StringOfChar(' ', 19 - Length(S));
  // 書き込み
  FEntrys.WriteStringData(Exif_DateTime, eiTIFF, S);
end;

// ==========================================================================
// == set: FileSource                                                    ====
// ==========================================================================
procedure TExifInfo.SetFileSource(const Value: Integer);
var
  Buffer: Byte;
  Entry: TEntryItem;
  Mem: TMemoryStream;
begin
  Mem := TMemoryStream(GetTagPointer(Exif_FileSource, eiExif, False));
  if Mem = nil then
  begin
    Mem := TMemoryStream.Create;
    Entry := FEntrys.AddTag(Exif_FileSource);
    Entry.IFD := eiExif;
    Entry.AddPointer(Mem, efUndefined);
  end;
  Mem.Position := 0;
  Buffer := Byte(Value);
  Mem.WriteBuffer(Buffer, 1);
end;

// ==========================================================================
// == set: ImageDescription                                              ====
// ==========================================================================
procedure TExifInfo.SetImageDescription(const Value: string);
begin
  if not IsAscii(Value) then DoError(ERR_ASCIIONLY)
  else FEntrys.WriteStringData(Exif_ImageDescription, eiTIFF, Value);
end;

// ==========================================================================
// == set: ImageFileName                                                 ====
// ==========================================================================
procedure TExifInfo.SetImageFileName(const Value: TFileName);
begin
  FImageFileName := Value;
  FEntrys.Clear;
  FThmEntrys.Clear;
  FDoneAnalyzeJpeg := False;
  DoUpdate;
  if FImageFileName <> '' then
    if FileExists(FImageFileName) then
    begin
      FApp1Position := FindApp1Marker(FImageFileName);
      if FApp1Position = -1 then
      begin
        DoError(ERR_NOTEXIF);
        Exit;
      end;
      if not AnalyzeExif then DoError(ERR_FAILEDREAD);
    end
    else DoError(ERR_FILENOTEXIST);
end;

// ==========================================================================
// == set: Make                                                          ====
// ==========================================================================
procedure TExifInfo.SetMake(const Value: string);
begin
  if IsAscii(Value) then
    FEntrys.WriteStringData(Exif_Make, eiTIFF, Value)
  else
    DoError(ERR_ASCIIONLY);
end;

// ==========================================================================
// == set: Model                                                         ====
// ==========================================================================
procedure TExifInfo.SetModel(const Value: string);
begin
  FEntrys.WriteStringData(Exif_Model, eiTIFF, Value);
end;

// ==========================================================================
// == set: SceneType                                                     ====
// ==========================================================================
procedure TExifInfo.SetSceneType(const Value: Integer);
var
  Buffer: Byte;
  Entry: TEntryItem;
  Mem: TMemoryStream;
begin
  Mem := TMemoryStream(GetTagPointer(Exif_SceneType, eiExif, False));
  if Mem = nil then
  begin
    Mem := TMemoryStream.Create;
    Entry := FEntrys.AddTag(Exif_SceneType);
    Entry.IFD := eiExif;
    Entry.AddPointer(Mem, efUndefined);
  end;
  Mem.Position := 0;
  Buffer := Byte(Value);
  Mem.WriteBuffer(Buffer, 1);
end;

// ==========================================================================
// == set: Software                                                      ====
// ==========================================================================
procedure TExifInfo.SetSoftware(const Value: string);
begin
  if IsAscii(Value) then
    FEntrys.WriteStringData(Exif_Software, eiTIFF, Value)
  else
    DoError(ERR_ASCIIONLY);
end;

// ==========================================================================
// == set: SubsecTime                                                    ====
// ==========================================================================
procedure TExifInfo.SetSubsecTime(const Value: Integer);
begin
  FEntrys.WriteStringData(Exif_SubSecTime, eiExif, IntToStr(Value));
end;

// ==========================================================================
// == set: SubsecTimeDigitized                                           ====
// ==========================================================================
procedure TExifInfo.SetSubsecTimeDigitized(const Value: Integer);
begin
  FEntrys.WriteStringData(Exif_SubSecTimeDigitized, eiExif,
                          IntToStr(Value));
end;

// ==========================================================================
// == set: SubsecTimeOriginal                                            ====
// ==========================================================================
procedure TExifInfo.SetSubsecTimeOriginal(const Value: Integer);
begin
  FEntrys.WriteStringData(Exif_SubSecTimeOriginal, eiExif,
                          IntToStr(Value));
end;

// ==========================================================================
// == set: ThmArtist                                                     ====
// ==========================================================================
procedure TExifInfo.SetThmArtist(const Value: string);
begin
  if not IsAscii(Value) then DoError(ERR_ASCIIONLY)
  else FThmEntrys.WriteStringData(Exif_Artist, eiTIFF, Value);
end;

// ==========================================================================
// == set: ThmCopyright                                                  ====
// ==========================================================================
procedure TExifInfo.SetThmCopyright(const Value: string);
begin
  if not IsAscii(Value) then DoError(ERR_ASCIIONLY)
  else FThmEntrys.WriteStringData(Exif_Copyright, eiTIFF, Value);
end;

// ==========================================================================
// == set: ThmDateTime                                                   ====
// ==========================================================================
procedure TExifInfo.SetThmDateTime(const Value: TDateTime);
var
  S: string;
  Y, Mon, D, H, Min, Sec, MSec: Word;
begin
  DecodeDate(Value, Y, Mon, D);
  DecodeTime(Value, H, Min, Sec, MSec);
  S := Format('%.4d:%.2d:%.2d %.2d:%.2d:%.2d', [Y, Mon, D, H, Min, Sec]);
  SetDateTimeText(S);
end;

// ==========================================================================
// == set: ThmDateTimeText                                               ====
// ==========================================================================
procedure TExifInfo.SetThmDateTimeText(const Value: string);
var
  S: string;
begin
  if Length(Value) > 19 then S := Copy(Value, 1, 19) else S := Value;
  if Length(S) < 19 then S := S + StringOfChar(' ', 19 - Length(S));
  FThmEntrys.WriteStringData(Exif_DateTime, eiTIFF, S);
end;

// ==========================================================================
// == set: ThmImageDescription                                           ====
// ==========================================================================
procedure TExifInfo.SetThmImageDescription(const Value: string);
begin
  if not IsAscii(Value) then DoError(ERR_ASCIIONLY)
  else FThmEntrys.WriteStringData(Exif_ImageDescription, eiTIFF, Value);
end;

// ==========================================================================
// == set: ThmMake                                                       ====
// ==========================================================================
procedure TExifInfo.SetThmMake(const Value: string);
begin
  if not IsAscii(Value) then DoError(ERR_ASCIIONLY)
  else FThmEntrys.WriteStringData(Exif_ImageDescription, eiTIFF, Value);
end;

// ==========================================================================
// == set: ThmModel                                                      ====
// ==========================================================================
procedure TExifInfo.SetThmModel(const Value: string);
begin
  if not IsAscii(Value) then DoError(ERR_ASCIIONLY)
  else FThmEntrys.WriteStringData(Exif_Model, eiTIFF, Value);
end;

// ==========================================================================
// == set: ThmSoftware                                                   ====
// ==========================================================================
procedure TExifInfo.SetThmSoftware(const Value: string);
begin
  if not IsAscii(Value) then DoError(ERR_ASCIIONLY)
  else FThmEntrys.WriteStringData(Exif_Software, eiTIFF, Value);
end;

// ==========================================================================
// == set: UserComment                                                   ====
// ==========================================================================
procedure TExifInfo.SetUserComment(const Value: WideString);
begin
  WriteUserComment(Value, GetUserCommentStyle);
end;

// ==========================================================================
// == method: タグが存在するか検査                                       ====
// ==========================================================================
function TExifInfo.TagExists(ATag: Word; AIFD: TExifIFD): Boolean;
begin
  Result := (FEntrys.IndexOfTag(ATag, AIFD) >= 0);
end;

// ==========================================================================
// == method: サムネイル情報にタグが存在するか検査                       ====
// ==========================================================================
function TExifInfo.ThmTagExists(ATag: Word; AIFD: TExifIFD): Boolean;
begin
  Result := (FThmEntrys.IndexOfTag(ATag, AIFD) >= 0);
end;

// ==========================================================================
// == method: Exifデータの書き込み                                       ====
// ==========================================================================
function TExifInfo.WriteExif(const DestFileName: TFileName;
  IncludeThumbnail: Boolean): Boolean;
const
  ExifHeader: array[0..5] of Byte = ($45, $78, $69, $66, $00, $00);
var
  App1: Int64;
  App1Size: Word;
  BufByte: Byte;
  Dest: TFileStream;
  Entry: TEntryItem;
  EntryIndex: Integer;
  L: Integer;
  Temp, ThumbMem: TMemoryStream;
  Thumb: TJPEGImage;
begin
  Result := FileExists(DestFileName);
  if Result then
  begin
    App1 := FindApp1Marker(DestFileName);
    Temp := TMemoryStream.Create;
    try
      WriteWord(Temp, $FFD8, boMM);
      if App1 > 2 then
      begin
        Dest := TFileStream.Create(DestFileName, fmOpenRead);
        try
          Dest.Seek(2, soBeginning);
          Temp.CopyFrom(Dest, App1 - Dest.Position);
        finally
          Dest.Free;
        end;
      end;
      // Exif書き込み
      WriteWord(Temp, $FFE1, boMM);
      App1Size := intExifHeaderSize + intTIFFHeaderSize + 2 + FEntrys.DataSize;
      if IncludeThumbnail then
      begin
        ThumbMem := TMemoryStream.Create;
        try
          Thumb := TJPEGImage.Create;
          try
            App1Size := App1Size + FThmEntrys.DataSize;
            ExtractThumbnail(DestFileName, Thumb);
            Thumb.SaveToStream(ThumbMem);
            App1Size := App1Size + ThumbMem.Size;
          finally
            Thumb.Free;
          end;
        except
          FreeAndNil(ThumbMem);
          IncludeThumbnail := False;
          App1Size := intExifHeaderSize + intTIFFHeaderSize + 2 +
                      FEntrys.DataSize;
        end;
      end
      else
        ThumbMem := nil;
      try
        WriteWord(Temp, App1Size, boMM);
        // Exifヘッダ
        for L := 0 to 5 do
        begin
          BufByte := ExifHeader[L];
          Temp.WriteBuffer(BufByte, 1);
        end;
        // TIFFヘッダ
        FEntrys.CardinalPoint := Temp.Position;
        FThmEntrys.CardinalPoint := Temp.Position;
        WriteWord(Temp, Word(FByteOrder), FByteOrder);
        WriteWord(Temp, $002A, FByteOrder);
        WriteLongWord(Temp, $00000008, FByteOrder);
        // メインIFD
        FEntrys.SaveToStream(Temp, IncludeThumbnail);
        // サムネイルIFD
        if IncludeThumbnail then
        begin
          EntryIndex := FThmEntrys.IndexOfTag(Exif_JPEGInterchangeFormatLength,
                                              eiTIFF);
          if EntryIndex = -1 then
          begin
            Entry := FThmEntrys.AddTag(Exif_JPEGInterchangeFormatLength);
            Entry.IFD := eiTIFF;
            Entry.SetULongData(0, ThumbMem.Size);
          end
          else
            FThmEntrys[EntryIndex].SetULongData(0, ThumbMem.Size);
          EntryIndex := FThmEntrys.IndexOfTag(Exif_JPEGInterchangeFormat, eiTIFF);
          if EntryIndex = -1 then
          begin
            Entry := FThmEntrys.AddTag(Exif_JPEGInterchangeFormat);
            Entry.IFD := eiTIFF;
          end;
          FThmEntrys.SaveToStream(Temp, False);
          Temp.CopyFrom(ThumbMem, 0);
        end;
      finally
        if Assigned(ThumbMem) then ThumbMem.Free;
      end;
      // 残りデータの記録
      Dest := TFileStream.Create(DestFileName, fmOpenRead);
      try
        if App1 >= 2 then
        begin
          Dest.Seek(App1 + 2, soBeginning);
          App1Size := ReadWord(Dest, boMM);
          Dest.Seek(App1Size - 2, soCurrent);
        end
        else
        begin
          Dest.Seek(0, soBeginning);
          App1Size := ReadWord(Dest, boMM);
          if App1Size <> $FFD8 then raise EExifError.Create(MSG_NOTIMAGE);
        end;
        Temp.CopyFrom(Dest, Dest.Size - Dest.Position);
      finally
        Dest.Free;
      end;
      Temp.SaveToFile(DestFileName);
    finally
      Temp.Free;
    end;
  end;
end;

// ==========================================================================
// == method: メーカーノートにストリームを書き込む                       ====
// ==========================================================================
function TExifInfo.WriteToMakerNote(Stream: TStream; ASize: Int64): Int64;
var
  Entry: TEntryItem;
  Mem: TMemoryStream;
begin
  Mem := TMemoryStream(GetTagPointer(Exif_MakerNote, eiExif, False));
  if Mem = nil then
  begin
    Mem := TMemoryStream.Create;
    Entry := FEntrys.AddTag(Exif_MakerNote);
    Entry.IFD := eiExif;
    Entry.AddPointer(Mem, efUndefined);
  end;
  if ASize <= 0 then ASize := Stream.Size;
  if Mem.Size > ASize then Mem.Size := ASize;
  Mem.Position := 0;
  Result := Mem.CopyFrom(Stream, ASize);
end;

// ==========================================================================
// == method: ユーザーコメントの書き込み                                 ====
// ==========================================================================
procedure TExifInfo.WriteUserComment(const Comment: string;
  Code: TExifUserCommentStyle);
const
  Marker: array[TExifUserCommentStyle, 0..7] of Byte =
      (($41,$53,$43,$49,$49,$00,$00,$00), ($4A,$49,$53,$00,$00,$00,$00,$00),
       ($55,$4E,$49,$43,$4F,$44,$45,$00), ($00,$00,$00,$00,$00,$00,$00,$00),
       ($00,$00,$00,$00,$00,$00,$00,$00));
var
  BufByte: Byte;
  Entry: TEntryItem;
  L: Integer;
  Mem: TMemoryStream;
begin
  if (Code = ucAscii) and not IsAscii(Comment) then
  begin
    DoError(ERR_ASCIIONLY);
    Exit;
  end;
  if Code = ucUnknown then Code := ucUndefined;
  Mem := TMemoryStream(GetTagPointer(Exif_UserComment, eiExif, False));
  if Mem = nil then
  begin
    Mem := TMemoryStream.Create;
    Entry := FEntrys.AddTag(Exif_UserComment);
    Entry.IFD := eiExif;
    Entry.AddPointer(Mem, efUndefined);
  end;
  Mem.Position := 0;
  for L := 0 to 7 do
  begin
    BufByte := Marker[Code, L];
    Mem.WriteBuffer(BufByte, 1);
  end;
  case Code of
    ucAscii  : Mem.WriteBuffer(PChar(Comment)^, Length(Comment));
    ucJIS    : WriteJISToMemory(Mem, Comment);
    ucUnicode: WriteUnicodeToMemory(Mem, Comment);
    else       Mem.WriteBuffer(PChar(Comment)^, Length(Comment));
  end;
end;

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %% { TEntryItems 実装 }                                                  %%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// ==========================================================================
// == method: アイテムの追加                                             ====
// ==========================================================================
function TEntryItems.Add: TEntryItem;
begin
  Result := TEntryItem(inherited Add);
end;

// ==========================================================================
// == method: タグを指定してアイテムの追加                               ====
// ==========================================================================
function TEntryItems.AddTag(ATag: Word): TEntryItem;
begin
  Result := TEntryItem(inherited Add);
  Result.SetTag(ATag);
end;

// ==========================================================================
// == ov method: Assign                                                  ====
// ==========================================================================
procedure TEntryItems.Assign(Source: TPersistent);
begin
  if Source is TEntryItems then
    FCardinalPoint := TEntryItems(Source).FCardinalPoint;
  inherited;
end;

// ==========================================================================
// == method: コンストラクタ                                             ====
// ==========================================================================
constructor TEntryItems.Create(AOwner: TExifInfo;
  AItemClass: TCollectionItemClass);
begin
  inherited Create(AItemClass);
  if Assigned(AOwner) then FOwner := AOwner;
end;

// ==========================================================================
// == get: DataSize                                                      ====
// ==========================================================================
function TEntryItems.GetDataSize: Word;
var
  Le: TExifIFD;
begin
  Result := 0;
  for Le := Low(TExifIFD) to High(TExifIFD) do
    Result := Result + IFDSize(Le);
end;

// ==========================================================================
// == get: Items                                                         ====
// ==========================================================================
function TEntryItems.GetItems(Index: Integer): TEntryItem;
begin
  Result := TEntryItem(inherited GetItem(Index));
end;

// ==========================================================================
// == ov method: GetOwner                                                ====
// ==========================================================================
function TEntryItems.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

// ==========================================================================
// == method: IFDエントリ数を返す                                        ====
// ==========================================================================
function TEntryItems.IFDEntryCount(AIFD: TExifIFD): Integer;
var
  L: Integer;
begin
  Result := 0;
  for L := 0 to Count - 1 do
    if Items[L].IFD = AIFD then Inc(Result);
end;

// ==========================================================================
// == method: IFDの書き込みに必要な容量を取得                            ====
// ==========================================================================
function TEntryItems.IFDSize(AIFD: TExifIFD): Word;
var
  Ec, L: Integer;
  Size: Word;
begin
  Ec := IFDEntryCount(AIFD);
  Result := 0;
  if Ec > 0 then
  begin
    Inc(Result, 6);
    for L := 0 to Count - 1 do
      if Items[L].IFD = AIFD then
      begin
        Size := Items[L].EntrySize;
        Inc(Result, Size);
      end;
  end;
end;

// ==========================================================================
// == method: タグの検索                                                 ====
// ==========================================================================
function TEntryItems.IndexOfTag(ATag: Word; AIFD: TExifIFD): Integer;
var
  L: Integer;
begin
  Result := -1;
  L := 0;
  while (Result = -1) and (L < Count) do
    if (Items[L].Tag = ATag) and (Items[L].IFD = AIFD) then Result := L
    else Inc(L);
end;

// ==========================================================================
// == method: ストリームに書き込む                                       ====
// ==========================================================================
procedure TEntryItems.SaveToStream(Stream: TStream; NextExist: Boolean);
var
  EntryIndex: Integer;
  IFDPos: array[TExifIFD] of Cardinal;
  L: Integer;
  NowIFD: TExifIFD;
  Offset, Size, IFDCount, TagPos: LongWord;
begin
  // 記録位置調整
  TagPos := Stream.Position - FCardinalPoint + 2;
  for NowIFD := Low(TExifIFD) to High(TExifIFD) do
  begin
    IFDCount := IFDEntryCount(NowIFD);
    Offset := IFDCount * intEntrySize + 4 + TagPos;
    IFDPos[NowIFD] := TagPos - 2;
    if IFDCount >= 1 then
    begin
      for L := 0 to Count - 1 do
        if Items[L].IFD = NowIFD then
        begin
          Items[L].Position := TagPos;
          Size := Items[L].EntrySize - intEntrySize;
          if Size >= 1 then
          begin
            Items[L].DataOffset := Offset;
            Inc(Offset, Size);
          end
          else Items[L].DataOffset := 0;
          Inc(TagPos, intEntrySize);
        end;
      TagPos := Offset + 2;
    end;
  end;
  Dec(TagPos, 2);
  // データ調整
  EntryIndex := IndexOfTag(Exif_JPEGInterchangeFormat, eiTIFF);
  if EntryIndex >= 0 then
    Items[EntryIndex].SetULongData(0, TagPos);
  EntryIndex := IndexOfTag(Exif_ExifIFDPointer, eiTIFF);
  if EntryIndex >= 0 then
    Items[EntryIndex].SetULongData(0, IFDPos[eiExif]);
  EntryIndex := IndexOfTag(Exif_GPSInfoIFDPointer, eiTIFF);
  if EntryIndex >= 0 then
    Items[EntryIndex].SetULongData(0, IFDPos[eiGPS]);
  EntryIndex := IndexOfTag(Exif_InteroperabilityIFDPointer, eiExif);
  if EntryIndex >= 0 then
    Items[EntryIndex].SetULongData(0, IFDPos[eiInteroperability]);
  // 記録
  for NowIFD := Low(TExifIFD) to High(TExifIFD) do
  begin
    IFDCount := IFDEntryCount(NowIFD);
    if IFDCount > 0 then
    begin
      // エントリ数
      WriteWord(Stream, IFDCount, FOwner.ByteOrder);
      // エントリ
      for L := 0 to Count - 1 do
        if Items[L].IFD = NowIFD then Items[L].SaveEntry(Stream);
      // オフセット
      if NextExist and (NowIFD = eiTIFF) then
        WriteLongWord(Stream, TagPos, FOwner.ByteOrder)
      else
        WriteLongWord(Stream, 0, FOwner.ByteOrder);
      // データ
      for L := 0 to Count - 1 do
        if Items[L].IFD = NowIFD then
          if Items[L].DataOffset > 0 then
            Items[L].WriteData(Stream, FOwner.ByteOrder);
    end;
  end;
end;

// ==========================================================================
// == set: Items                                                         ====
// ==========================================================================
procedure TEntryItems.SetItems(Index: Integer; const Value: TEntryItem);
begin
  inherited SetItem(Index, Value);
end;

// ==========================================================================
// == method: 文字列値の書き込み                                         ====
// ==========================================================================
procedure TEntryItems.WriteStringData(ATag: Word; AIFD: TExifIFD;
  const S: string);
var
  Entry: TEntryItem;
  EntryIndex: Integer;
begin
  EntryIndex := IndexOfTag(ATag, AIFD);
  if EntryIndex = -1 then
  begin
    Entry := AddTag(ATag);
    Entry.IFD := AIFD;
  end
  else Entry := Items[EntryIndex];
  Entry.AddString(S);
end;

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %% { TEntryItem 実装 }                                                   %%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// ==========================================================================
// == method: ポインタの追加                                             ====
// ==========================================================================
procedure TEntryItem.AddPointer(P: Pointer; AFormat: TExifFormat);
begin
  FDatas.Add(P);
  FDataCount := FDatas.Count;
  FFormat := AFormat;
end;

// ==========================================================================
// == method: 文字列データの追加                                         ====
// ==========================================================================
procedure TEntryItem.AddString(const S: string);
var
  P: PChar;
begin
  Clear;
  FFormat := efAscii;
  P := StrAlloc(Length(S) + 1);
  P := StrPCopy(P, S);
  FDatas.Add(P);
  FDataCount := FDatas.Count;
end;

// ==========================================================================
// == ov method: Assign                                                  ====
// ==========================================================================
procedure TEntryItem.Assign(Source: TPersistent);
begin
  if Source is TEntryItem then
    with TEntryItem(Source) do
    begin
      Self.FDataCount := FDataCount;
      Self.FDataOffset := FDataOffset;
      Self.Clear;
      Self.CopyDatas(TEntryItem(Source));
      Self.FExifDataCount := FExifDataCount;
      Self.FFormat := FFormat;
      Self.FIFD := FIFD;
      Self.FOffset := FOffset;
      Self.FPosition := FPosition;
      Self.FTag := FTag;
    end
  else
    inherited;
end;

// ==========================================================================
// == method: データのクリア                                             ====
// ==========================================================================
procedure TEntryItem.Clear;
var
  L: Integer;
begin
  for L := FDatas.Count - 1 downto 0 do
    DeleteData(L);
end;

// ==========================================================================
// == method: データのコピー                                             ====
// ==========================================================================
procedure TEntryItem.CopyDatas(Source: TEntryItem);
var
  L: Integer;
  Mem: TMemoryStream;
  pAscii: PChar;
  pByteData: PByte;
  pDblFloat: PDouble;
  pFloat: PSingle;
  pLong: PLongWord;
  pRatio: PUnsignedRational;
  pShort: PWord;
  S: string;
begin
  for L := 0 to Source.FDatas.Count - 1 do
    case Source.Format of
      efUByte, efByte:
        begin
          New(pByteData);
          pByteData^ := PByte(FDatas[L])^;
          FDatas.Add(pByteData);
        end;
      efAscii:
        begin
          S := string(PChar(FDatas[L]));
          pAscii := StrAlloc(Length(S) + 1);
          StrPCopy(pAscii, S);
          FDatas.Add(pAscii);
        end;
      efUShort, efShort:
        begin
          New(pShort);
          pShort^ := PWord(FDatas[L])^;
          FDatas.Add(pShort);
        end;
      efULong, efLong:
        begin
          New(pLong);
          pLong^ := PLongWord(FDatas[L])^;
          FDatas.Add(pLong);
        end;
      efURational, efRational:
        begin
          New(pRatio);
          pRatio^ := PUnsignedRational(FDatas[L])^;
          FDatas.Add(pRatio);
        end;
      efUndefined:
        begin
          Mem := TMemoryStream.Create;
          Mem.CopyFrom(TMemoryStream(FDatas[L]), 0);
          FDatas.Add(Mem);
        end;
      efFloat:
        begin
          New(pFloat);
          pFloat^ := PSingle(FDatas[L])^;
          FDatas.Add(pFloat);
        end;
      else
        begin
          New(pDblFloat);
          pDblFloat^ := PDouble(FDatas[L])^;
          FDatas.Add(pDblFloat);
        end;
    end;
end;

// ==========================================================================
// == method: コンストラクタ                                             ====
// ==========================================================================
constructor TEntryItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FDatas := TList.Create;
end;

// ==========================================================================
// == method: データの削除                                               ====
// ==========================================================================
procedure TEntryItem.DeleteData(Index: Integer);
var
  P: Pointer;
begin
  P := FDatas[Index];
  FDatas[Index] := nil;
  case FFormat of
    efUByte    : Dispose(PByte(P));
    efAscii    : StrDispose(PChar(P));
    efUShort   : Dispose(PWord(P));
    efULong    : Dispose(PLongWord(P));
    efURational: Dispose(PUnsignedRational(P));
    efByte     : Dispose(PShortInt(P));
    efUndefined: TMemoryStream(P).Free;
    efShort    : Dispose(PSmallInt(P));
    efLong     : Dispose(PLongInt(P));
    efRational : Dispose(PSignedRational(P));
    efFloat    : Dispose(PSingle(P));
    else         Dispose(PDouble(P));
  end;
  FDatas.Delete(Index);
  FDataCount := FDatas.Count;
end;

// ==========================================================================
// == method: デストラクタ                                               ====
// ==========================================================================
destructor TEntryItem.Destroy;
begin
  Clear;
  FDatas.Free;
  inherited;
end;

// ==========================================================================
// == get: Data                                                          ====
// ==========================================================================
function TEntryItem.GetDatas(Index: Integer): Pointer;
begin
  Result := FDatas[Index];
end;

// ==========================================================================
// == get: EntrySize                                                     ====
// ==========================================================================
function TEntryItem.GetEntrySize: Word;
var
  P: PChar;
  Size: Cardinal;
begin
  Result := 12;
  // データ数
  case FFormat of
    efAscii:
      begin
        P := FDatas[0];
        FExifDataCount := Cardinal(Length(string(P))) + 1;
      end;
    efUndefined: FExifDataCount := Cardinal(TMemoryStream(FDatas[0]).Size);
    else         FExifDataCount := Cardinal(FDatas.Count);
  end;
  // データサイズ
  case FFormat of
    efUByte    : Size := FExifDataCount;
    efAscii    : Size := FExifDataCount;
    efUShort   : Size := FExifDataCount * 2;
    efULong    : Size := FExifDataCount * 4;
    efURational: Size := FExifDataCount * 8;
    efByte     : Size := FExifDataCount;
    efUndefined: Size := FExifDataCount;
    efShort    : Size := FExifDataCount * 2;
    efLong     : Size := FExifDataCount * 4;
    efRational : Size := FExifDataCount * 8;
    efFloat    : Size := FExifDataCount * 4;
    else         Size := FExifDataCount * 8;
  end;
  if Size > 4 then Inc(Result, Size);
end;

// ==========================================================================
// == get: Exif                                                          ====
// ==========================================================================
function TEntryItem.GetExif: TExifInfo;
begin
  Result := nil;
  if Collection is TEntryItems then
    if TEntryItems(Collection).Owner is TExifInfo then
      Result := TExifInfo(TEntryItems(Collection).Owner);
end;

// ==========================================================================
// == get: IFDNumber                                                     ====
// ==========================================================================
function TEntryItem.GetIFDNumber: TExifIFD;
begin
  Result := FIFD;
end;

// ==========================================================================
// == method: 文字列の取得                                               ====
// ==========================================================================
function TEntryItem.GetStringData: string;
var
  P: PChar;
begin
  if FFormat <> efAscii then Result := ''
  else
  begin
    P := FDatas[0];
    Result := string(P);
  end;
end;

// ==========================================================================
// == method: Byte値の取得                                               ====
// ==========================================================================
function TEntryItem.GetUByteData(Index: Integer): Byte;
var
  P: PByte;
begin
  if (FFormat <> efUByte) or not InRange(Index, 0, FDataCount - 1) then
    Result := 0
  else
  begin
    P := FDatas[Index];
    Result := P^;
  end;
end;

// ==========================================================================
// == method: LongWord値の取得                                           ====
// ==========================================================================
function TEntryItem.GetULongData(Index: Integer): LongWord;
var
  P: PLongWord;
begin
  if (FFormat <> efULong) or not InRange(Index, 0, FDataCount - 1) then
    Result := 0
  else
  begin
    P := FDatas[Index];
    Result := P^;
  end;
end;

// ==========================================================================
// == method: Word値の取得                                               ====
// ==========================================================================
function TEntryItem.GetUShortData(Index: Integer): Word;
var
  P: PWord;
begin
  if (FFormat <> efUShort) or not InRange(Index, 0, FDataCount - 1) then
    Result := 0
  else
  begin
    P := FDatas[Index];
    Result := P^;
  end;
end;

// ==========================================================================
// == vir method: ストリームからエントリデータを読み取る                 ====
// ==========================================================================
procedure TEntryItem.LoadFromStream(Stream: TStream);
var
  BytesLen: Cardinal;
  Items: TEntryItems;
  Order: TExifByteOrder;
  TempPos: Int64;
begin
  // タグ
  if Assigned(Exif) then Order := Exif.ByteOrder else Order := boII;
  if Collection is TEntryItems then Items := TEntryItems(Collection)
  else Items := nil;
  FTag := ReadWord(Stream, Order);
  // フォーマット
  FFormat := TExifFormat(ReadWord(Stream, Order));
  // データ数
  FExifDataCount := ReadULong(Stream, Order);
  // データ、またはオフセット
  BytesLen := FormatByteLength(FFormat) * FExifDataCount;
  if BytesLen <= 4 then
  begin
    // 即値
    FOffset := 0;
    ReadExifData(Stream);
    Stream.Seek(4 - BytesLen, soCurrent);
  end
  else
  begin
    // オフセット
    TempPos := Stream.Position;
    FOffset := ReadULong(Stream, Order);
    Stream.Seek(Items.CardinalPoint + Int64(FOffset), soBeginning);
    ReadExifData(Stream);
    Stream.Seek(TempPos + 4, soBeginning);
  end;
end;

// ==========================================================================
// == vir method: ストリームからデータを読み取る                         ====
// ==========================================================================
procedure TEntryItem.ReadExifData(Stream: TStream);
var
  BufByte: Byte;
  L: Cardinal;
  Mem: TMemoryStream;
  Order: TExifByteOrder;
  pAscii: PChar;
  pByteData: PByte;
  pDoubleData: PDouble;
  pLongData: PLongInt;
  pRational: PSignedRational;
  pShortData: PShortInt;
  pSingleData: PSingle;
  pSmallData: PSmallInt;
  pULongData: PLongWord;
  pURational: PUnsignedRational;
  pWordData: PWord;
begin
  FDataCount := Integer(FExifDataCount);
  if Assigned(Exif) then Order := Exif.ByteOrder else Order := boII;
  case FFormat of
    efUByte:  // 符号なしバイト(Byte)
      begin
        for L := 1 to FExifDataCount do
        begin
          New(pByteData);
          FDatas.Add(pByteData);
          Stream.ReadBuffer(pByteData^, 1);
        end;
      end;
    efAscii:  // アスキー文字列
      if FExifDataCount > 0 then
      begin
        pAscii := StrAlloc(FExifDataCount);
        for L := 1 to FExifDataCount do
        begin
          Stream.ReadBuffer(BufByte, 1);
          pAscii[L - 1] := Chr(BufByte);
        end;
        FDatas.Add(pAscii);
        FDataCount := 1;
      end;
    efUShort: // 符号なしショート(Word)
      begin
        for L := 1 to FExifDataCount do
        begin
          New(pWordData);
          FDatas.Add(pWordData);
          pWordData^ := ReadWord(Stream, Order);
        end;
      end;
    efULong:  // 符号なしロング(LongWord)
      begin
        for L := 1 to FExifDataCount do
        begin
          New(pULongData);
          FDatas.Add(pULongData);
          pULongData^ := ReadULong(Stream, Order);
        end;
      end;
    efURational:  // 符号なし分数
      begin
        for L := 1 to FExifDataCount do
        begin
          New(pURational);
          with pURational^ do
          begin
            Namerator := ReadULong(Stream, Order);
            Denominator := ReadULong(Stream, Order);
          end;
          FDatas.Add(pURational);
        end;
      end;
    efByte: // 符号付きバイト(ShortInt)
      begin
        for L := 1 to FExifDataCount do
        begin
          New(pShortData);
          FDatas.Add(pShortData);
          Stream.ReadBuffer(pShortData^, 1);
        end;
      end;
    efUndefined:  // 不明
      begin
        FDataCount := 1;
        Mem := TMemoryStream.Create;
        if FExifDataCount > 0 then Mem.CopyFrom(Stream, FExifDataCount);
        Mem.Position := 0;
        FDatas.Add(Mem);
      end;
    efShort:  // 符号なしショート(SmallInt)
      begin
        for L := 1 to FExifDataCount do
        begin
          New(pSmallData);
          FDatas.Add(pSmallData);
          pSmallData^ := ReadSmall(Stream, Order);
        end;
      end;
    efLong: // 符号なしロング(LongInt)
      begin
        for L := 1 to FExifDataCount do
        begin
          New(pLongData);
          FDatas.Add(pLongData);
          pLongData^ := ReadLong(Stream, Order);
        end;
      end;
    efRational: // 符号なし分数
      begin
        for L := 1 to FExifDataCount do
        begin
          New(pRational);
          with pRational^ do
          begin
            Namerator := ReadLong(Stream, Order);
            Denominator := ReadLong(Stream, Order);
          end;
          FDatas.Add(pRational);
        end;
      end;
    efFloat:  // シングル実数
      begin
        for L := 1 to FExifDataCount do
        begin
          New(pSingleData);
          FDatas.Add(pSingleData);
          pSingleData^ := ReadSingle(Stream, Order);
        end;
      end;
    else     // ダブル実数
      begin
        for L := 1 to FExifDataCount do
        begin
          New(pDoubleData);
          FDatas.Add(pDoubleData);
          pDoubleData^ := ReadDouble(Stream, Order);
        end;
      end;
  end;
end;

// ==========================================================================
// == method: ストリームに書き込む                                       ====
// ==========================================================================
function TEntryItem.SaveEntry(Stream: TStream): LongWord;
var
  Buffer: Byte;
  Order: TExifByteOrder;
  Size: Cardinal;
  Zero, L: Integer;
begin
  if Assigned(Exif) then Order := Exif.ByteOrder else Order := boII;
  WriteWord(Stream, FTag, Order);
  WriteWord(Stream, Word(FFormat), Order);
  WriteLongWord(Stream, FExifDataCount, Order);
  Size := GetEntrySize - intEntrySize;
  if Size >= 1 then
  begin
    Result := Size;
    WriteLongWord(Stream, FDataOffset, Order);
  end
  else
  begin
    Result := 0;
    case FFormat of
      efUByte    : Zero := 4 - WriteData(Stream, Order);
      efAscii    : Zero := 4 - WriteData(Stream, Order);
      efUShort   : Zero := 4 - WriteData(Stream, Order);
      efULong    : Zero := 4 - WriteData(Stream, Order);
      efByte     : Zero := 4 - WriteData(Stream, Order);
      efUndefined: Zero := 4 - WriteData(Stream, Order);
      efShort    : Zero := 4 - WriteData(Stream, Order);
      efLong     : Zero := 4 - WriteData(Stream, Order);
      efFloat    : Zero := 4 - WriteData(Stream, Order);
      else         Zero := 0;
    end;
    if Zero > 0 then
    begin
      Buffer := 0;
      for L := 1 to Zero do
        Stream.WriteBuffer(Buffer, 1);
    end; 
  end;
end;

// ==========================================================================
// == method:タグの設定                                                  ====
// ==========================================================================
procedure TEntryItem.SetTag(ATag: Word);
begin
  FTag := ATag;
end;

// ==========================================================================
// == method: LongWord値の設定                                           ====
// ==========================================================================
procedure TEntryItem.SetULongData(Index: Integer; Value: LongWord);
var
  L: Integer;
  P: PLongWord;
begin
  if FFormat <> efULong then
  begin
    Clear;
    FFormat := efULong;
    for L := 0 to Index do
    begin
      New(P);
      P^ := 0;
      FDatas.Add(P);
    end;
  end;
  P := FDatas[Index];
  P^ := Value;
end;

// ==========================================================================
// == method: データをストリームに書き込む                               ====
// ==========================================================================
function TEntryItem.WriteData(Stream: TStream; Order: TExifByteOrder): Integer;
var
  BufByte: Byte;
  L, L2: Integer;
  Mem: TMemoryStream;
  pAscii: PChar;
  pByteData: PByte;
  pShortData: PShortInt;
  pULongData: PLongWord;
  pURational: PUnsignedRational;
  pWordData: PWord;
  S: string;
begin
  case FFormat of
    efUByte:
      begin
        for L := 0 to FDatas.Count - 1 do
        begin
          pByteData := FDatas[L];
          Stream.WriteBuffer(pByteData^, 1);
        end;
        Result := FDatas.Count;
      end;
    efAscii:
      begin
        pAscii := FDatas[0];
        S := string(pAscii);
        Result := Length(S) + 1;
        Stream.WriteBuffer(PChar(S)^, Result);
      end;
    efUShort, efShort:
      begin
        Result := FDatas.Count * 2;
        for L := 0 to FDatas.Count - 1 do
        begin
          pWordData := FDatas[L];
          WriteWord(Stream, pWordData^, Order);
        end;
      end;
    efULong, efLong, efFloat:
      begin
        Result := FDatas.Count * 4;
        for L := 0 to FDatas.Count - 1 do
        begin
          pULongData := FDatas[L];
          WriteLongWord(Stream, pULongData^, Order);
        end;
      end;
    efURational, efRational:
      begin
        Result := FDatas.Count * 8;
        for L := 0 to FDatas.Count - 1 do
        begin
          pURational := FDatas[L];
          WriteLongWord(Stream, pURational^.Namerator, Order);
          WriteLongWord(Stream, pURational^.Denominator, Order);
        end;
      end;
    efByte:
      begin
        Result := FDatas.Count;
        for L := 0 to Result - 1 do
        begin
          pShortData := FDatas[L];
          Stream.WriteBuffer(pShortData^, 1);
        end;
      end;
    efUndefined:
      begin
        Mem := TMemoryStream(FDatas[0]);
        Result := Mem.Size;
        Mem.Position := 0;
        Stream.CopyFrom(Mem, 0);
      end;
    efDFloat:
      begin
        Result := FDatas.Count * 8;
        for L := 0 to FDatas.Count - 1 do
        begin
          pAscii := FDatas[L];
          if Order = boII then
            for L2 := 7 downto 0 do
            begin
              BufByte := Byte(pAscii[L]);
              Stream.WriteBuffer(BufByte, 1);
            end
          else
            for L2 := 0 to 7 do
            begin
              BufByte := Byte(pAscii[L]);
              Stream.WriteBuffer(BufByte, 1);
            end;
        end;
      end;
    else Result := 0;
  end;
end;

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %% { TExifRational 実装 }                                                %%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// ==========================================================================
// == ov method: Assign                                                  ====
// ==========================================================================
procedure TExifRational.Assign(Source: TPersistent);
begin
  if Source is TExifRational then
    with TExifRational(Source) do
    begin
      Self.FDenominator := FDenominator;
      Self.FNamerator := FNamerator;
    end
  else
    inherited;
end;

// ==========================================================================
// == method: 数値のクリア                                               ====
// ==========================================================================
procedure TExifRational.Clear;
begin
  FDenominator := 0;
  FNamerator := 0;
end;

// ==========================================================================
// == method: コンストラクタ                                             ====
// ==========================================================================
constructor TExifRational.Create(AOwner: TComponent);
begin
  inherited Create;
  if AOwner is TExifInfo then FOwner := TExifInfo(AOwner);
end;

// ==========================================================================
// == method: デストラクタ                                               ====
// ==========================================================================
destructor TExifRational.Destroy;
begin
  if Assigned(FOwner) then FOwner.ObjectDeletion(Self);
  inherited;
end;

// ==========================================================================
// == get: Text                                                         ====
// ==========================================================================
function TExifRational.GetText: string;
var
  Signed: Boolean;
begin
  Signed := (FNamerator < 0) xor (FDenominator < 0);
  Result := Format('%d/%d', [Abs(FNamerator), Abs(FDenominator)]);
  if Signed then Result := '-' + Result;
end;

// ==========================================================================
// == get: Value                                                         ====
// ==========================================================================
function TExifRational.GetValue: Double;
begin
  Result := FNamerator / FDenominator;
end;

// ==========================================================================
// == method: 符号付き数値の設定                                         ====
// ==========================================================================
procedure TExifRational.SetSingedValues(ANamerator, ADenominator: Integer);
begin
  FDenominator := ADenominator;
  FNamerator := ANamerator;
end;

// ==========================================================================
// == method: 符号付き数値の設定                                         ====
// ==========================================================================
procedure TExifRational.SetSingedValues(pRational: PSignedRational);
begin
  FDenominator := pRational^.Denominator;
  FNamerator := pRational^.Namerator;
end;

// ==========================================================================
// == method: 数値の設定                                                 ====
// ==========================================================================
procedure TExifRational.SetValues(ANamerator, ADenominator: LongWord);
begin
  FDenominator := Integer(ADenominator);
  FNamerator := Integer(ANamerator);
end;

// ==========================================================================
// == method: 数値の設定                                                 ====
// ==========================================================================
procedure TExifRational.SetValues(pRational: PUnsignedRational);
begin
  FDenominator := Integer(pRational^.Denominator);
  FNamerator := Integer(pRational^.Namerator);
end;

// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %% { EExifError 実装 }                                                   %%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
// %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

// ==========================================================================
// == method: コンストラクタ                                                 ====
// ==========================================================================
constructor EExifError.Create(const Msg: string);
begin
  inherited Create('TExifInfo: ' + Msg);
end;

end.
