unit FreeType;
{
FreeType2 Header conversion by Steffen Xonna. (08-20-2008)
Based on FreeType 2.3.5

http://www.dev-center.de/index.php?cat=header&file=freetype2
--- website dosn't exists yet !!! ---

Below you find an copy from the original FreeType2 header.
}

(***************************************************************************)
(*                                                                         *)
(*  freetype.h                                                             *)
(*                                                                         *)
(*    FreeType high-level API and common types (specification only).       *)
(*                                                                         *)
(*  Copyright 1996-2001, 2002, 2003, 2004, 2005, 2006, 2007 by             *)
(*  David Turner, Robert Wilhelm, and Werner Lemberg.                      *)
(*                                                                         *)
(*  This file is part of the FreeType project, and may only be used,       *)
(*  modified, and distributed under the terms of the FreeType project      *)
(*  license, LICENSE.TXT.  By continuing to use, modify, or distribute     *)
(*  this file you indicate that you have read the license and              *)
(*  understand and accept it fully.                                        *)
(*                                                                         *)
(***************************************************************************)


{$IFDEF FPC}
  {$MODE Delphi}

  {$IFDEF CPUI386}
    {$DEFINE CPU386}
    {$ASMMODE INTEL}
  {$ENDIF}

  {$IFNDEF WIN32}
    {$LINKLIB c}
  {$ENDIF}
{$ENDIF}


{$EXTENDEDSYNTAX ON}
{$ALIGN 8}
{$MINENUMSIZE 4}


interface


// basic types
type
  FT_Int32        = Integer;
  FT_UInt32       = Integer;

  (* generell types *)
  FT_Bool         = Byte;
  FT_Char         = Char;
  FT_Byte         = Byte;
  FT_Bytes        = ^FT_Byte;
  FT_Tag          = FT_UInt32;
  FT_String       = AnsiChar;
  FT_Short        = Smallint;
  FT_UShort       = Word;
  FT_Int          = Integer;
  FT_UInt         = Cardinal;
  FT_Fixed        = Integer;
  FT_Long         = Integer;
  FT_ULong        = Cardinal;
  FT_F26Dot6      = Integer;
  FT_F2Dot14      = Smallint;
  FT_Pos          = Integer;

  FT_Error        = Integer;

  FT_Pointer      = Pointer;

  FT_Byte_ptr     = ^FT_Byte;
  FT_Int_ptr      = ^FT_Int;
  FT_UInt_ptr     = ^FT_UInt;
  FT_Bool_ptr     = ^FT_Bool;
  FT_String_ptr   = pAnsiChar; //^FT_String;
  FT_Fixed_ptr    = ^FT_Fixed;


  
// consts
const
  FT_MAX_MODULES = 32;

  FT_TRUE = 1;
  FT_FALSE = 0;

  (*************************************************************************
   *
   *  @enum:
   *    FREETYPE_XXX
   *
   *  @description:
   *    These three macros identify the FreeType source code version.
   *    Use @FT_Library_Version to access them at runtime.
   *
   *  @values:
   *    FREETYPE_MAJOR :: The major version number.
   *    FREETYPE_MINOR :: The minor version number.
   *    FREETYPE_PATCH :: The patch level.
   *
   *  @note:
   *    The version number of FreeType if built as a dynamic link library
   *    with the `libtool' package is _not_ controlled by these three
   *    macros.
   *)
  FREETYPE_MAJOR  = 2;
  FREETYPE_MINOR  = 3;
  FREETYPE_PATCH  = 5;


  (*************************************************************************)
  (*                                                                       *)
  (* <Enum>                                                                *)
  (*    FT_FACE_FLAG_XXX                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A list of bit flags used in the `face_flags' field of the          *)
  (*    @FT_FaceRec structure.  They inform client applications of         *)
  (*    properties of the corresponding face.                              *)
  (*                                                                       *)
  (* <Values>                                                              *)
  (*    FT_FACE_FLAG_SCALABLE ::                                           *)
  (*      Indicates that the face contains outline glyphs.  This doesn't   *)
  (*      prevent bitmap strikes, i.e., a face can have both this and      *)
  (*      and @FT_FACE_FLAG_FIXED_SIZES set.                               *)
  (*                                                                       *)
  (*    FT_FACE_FLAG_FIXED_SIZES ::                                        *)
  (*      Indicates that the face contains bitmap strikes.  See also the   *)
  (*      `num_fixed_sizes' and `available_sizes' fields of @FT_FaceRec.   *)
  (*                                                                       *)
  (*    FT_FACE_FLAG_FIXED_WIDTH ::                                        *)
  (*      Indicates that the face contains fixed-width characters (like    *)
  (*      Courier, Lucido, MonoType, etc.).                                *)
  (*                                                                       *)
  (*    FT_FACE_FLAG_SFNT ::                                               *)
  (*      Indicates that the face uses the `sfnt' storage scheme.  For     *)
  (*      now, this means TrueType and OpenType.                           *)
  (*                                                                       *)
  (*    FT_FACE_FLAG_HORIZONTAL ::                                         *)
  (*      Indicates that the face contains horizontal glyph metrics.  This *)
  (*      should be set for all common formats.                            *)
  (*                                                                       *)
  (*    FT_FACE_FLAG_VERTICAL ::                                           *)
  (*      Indicates that the face contains vertical glyph metrics.  This   *)
  (*      is only available in some formats, not all of them.              *)
  (*                                                                       *)
  (*    FT_FACE_FLAG_KERNING ::                                            *)
  (*      Indicates that the face contains kerning information.  If set,   *)
  (*      the kerning distance can be retrieved through the function       *)
  (*      @FT_Get_Kerning.  Otherwise the function always return the       *)
  (*      vector (0,0).  Note that FreeType doesn't handle kerning data    *)
  (*      from the `GPOS' table (as present in some OpenType fonts).       *)
  (*                                                                       *)
  (*    FT_FACE_FLAG_FAST_GLYPHS ::                                        *)
  (*      THIS FLAG IS DEPRECATED.  DO NOT USE OR TEST IT.                 *)
  (*                                                                       *)
  (*    FT_FACE_FLAG_MULTIPLE_MASTERS ::                                   *)
  (*      Indicates that the font contains multiple masters and is capable *)
  (*      of interpolating between them.  See the multiple-masters         *)
  (*      specific API for details.                                        *)
  (*                                                                       *)
  (*    FT_FACE_FLAG_GLYPH_NAMES ::                                        *)
  (*      Indicates that the font contains glyph names that can be         *)
  (*      retrieved through @FT_Get_Glyph_Name.  Note that some TrueType   *)
  (*      fonts contain broken glyph name tables.  Use the function        *)
  (*      @FT_Has_PS_Glyph_Names when needed.                              *)
  (*                                                                       *)
  (*    FT_FACE_FLAG_EXTERNAL_STREAM ::                                    *)
  (*      Used internally by FreeType to indicate that a face's stream was *)
  (*      provided by the client application and should not be destroyed   *)
  (*      when @FT_Done_Face is called.  Don't read or test this flag.     *)
  (*                                                                       *)
  (*    FT_FACE_FLAG_HINTER ::                                             *)
  (*      Set if the font driver has a hinting machine of its own.  For    *)
  (*      example, with TrueType fonts, it makes sense to use data from    *)
  (*      the SFNT `gasp' table only if the native TrueType hinting engine *)
  (*      (with the bytecode interpreter) is available and active.         *)
  (*                                                                       *)
  FT_FACE_FLAG_SCALABLE          = 1 shl  0;
  FT_FACE_FLAG_FIXED_SIZES       = 1 shl  1;
  FT_FACE_FLAG_FIXED_WIDTH       = 1 shl  2;
  FT_FACE_FLAG_SFNT              = 1 shl  3;
  FT_FACE_FLAG_HORIZONTAL        = 1 shl  4;
  FT_FACE_FLAG_VERTICAL          = 1 shl  5;
  FT_FACE_FLAG_KERNING           = 1 shl  6;
  FT_FACE_FLAG_FAST_GLYPHS       = 1 shl  7;
  FT_FACE_FLAG_MULTIPLE_MASTERS  = 1 shl  8;
  FT_FACE_FLAG_GLYPH_NAMES       = 1 shl  9;
  FT_FACE_FLAG_EXTERNAL_STREAM   = 1 shl 10;
  FT_FACE_FLAG_HINTER            = 1 shl 11;


  (*************************************************************************)
  (*                                                                       *)
  (* <Constant>                                                            *)
  (*    FT_STYLE_FLAG_XXX                                                  *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A list of bit-flags used to indicate the style of a given face.    *)
  (*    These are used in the `style_flags' field of @FT_FaceRec.          *)
  (*                                                                       *)
  (* <Values>                                                              *)
  (*    FT_STYLE_FLAG_ITALIC ::                                            *)
  (*      Indicates that a given face is italicized.                       *)
  (*                                                                       *)
  (*    FT_STYLE_FLAG_BOLD ::                                              *)
  (*      Indicates that a given face is bold.                             *)
  (*                                                                       *)
  FT_STYLE_FLAG_ITALIC  = 1 shl 0;
  FT_STYLE_FLAG_BOLD    = 1 shl 1;


  (*************************************************************************)
  (*                                                                       *)
  (* <Enum>                                                                *)
  (*    FT_OPEN_XXX                                                        *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A list of bit-field constants used within the `flags' field of the *)
  (*    @FT_Open_Args structure.                                           *)
  (*                                                                       *)
  (* <Values>                                                              *)
  (*    FT_OPEN_MEMORY      :: This is a memory-based stream.              *)
  (*                                                                       *)
  (*    FT_OPEN_STREAM      :: Copy the stream from the `stream' field.    *)
  (*                                                                       *)
  (*    FT_OPEN_PATHNAME    :: Create a new input stream from a C          *)
  (*                           path name.                                  *)
  (*                                                                       *)
  (*    FT_OPEN_DRIVER      :: Use the `driver' field.                     *)
  (*                                                                       *)
  (*    FT_OPEN_PARAMS      :: Use the `num_params' and `params' fields.   *)
  (*                                                                       *)
  (*    ft_open_memory      :: Deprecated; use @FT_OPEN_MEMORY instead.    *)
  (*                                                                       *)
  (*    ft_open_stream      :: Deprecated; use @FT_OPEN_STREAM instead.    *)
  (*                                                                       *)
  (*    ft_open_pathname    :: Deprecated; use @FT_OPEN_PATHNAME instead.  *)
  (*                                                                       *)
  (*    ft_open_driver      :: Deprecated; use @FT_OPEN_DRIVER instead.    *)
  (*                                                                       *)
  (*    ft_open_params      :: Deprecated; use @FT_OPEN_PARAMS instead.    *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The `FT_OPEN_MEMORY', `FT_OPEN_STREAM', and `FT_OPEN_PATHNAME'     *)
  (*    flags are mutually exclusive.                                      *)
  (*                                                                       *)
  FT_OPEN_MEMORY    = $01;
  FT_OPEN_STREAM    = $02;
  FT_OPEN_PATHNAME  = $04;
  FT_OPEN_DRIVER    = $08;
  FT_OPEN_PARAMS    = $10;


  (*************************************************************************
   *
   * @enum:
   *   FT_LOAD_XXX
   *
   * @description:
   *   A list of bit-field constants used with @FT_Load_Glyph to indicate
   *   what kind of operations to perform during glyph loading.
   *
   * @values:
   *   FT_LOAD_DEFAULT ::
   *     Corresponding to 0, this value is used as the default glyph load
   *     operation.  In this case, the following happens:
   *
   *     1. FreeType looks for a bitmap for the glyph corresponding to the
   *        face's current size.  If one is found, the function returns.
   *        The bitmap data can be accessed from the glyph slot (see note
   *        below).
   *
   *     2. If no embedded bitmap is searched or found, FreeType looks for a
   *        scalable outline.  If one is found, it is loaded from the font
   *        file, scaled to device pixels, then `hinted' to the pixel grid
   *        in order to optimize it.  The outline data can be accessed from
   *        the glyph slot (see note below).
   *
   *     Note that by default, the glyph loader doesn't render outlines into
   *     bitmaps.  The following flags are used to modify this default
   *     behaviour to more specific and useful cases.
   *
   *   FT_LOAD_NO_SCALE ::
   *     Don't scale the outline glyph loaded, but keep it in font units.
   *
   *     This flag implies @FT_LOAD_NO_HINTING and @FT_LOAD_NO_BITMAP, and
   *     unsets @FT_LOAD_RENDER.
   *
   *   FT_LOAD_NO_HINTING ::
   *     Disable hinting.  This generally generates `blurrier' bitmap glyph
   *     when the glyph is rendered in any of the anti-aliased modes.  See
   *     also the note below.
   *
   *     This flag is implied by @FT_LOAD_NO_SCALE.
   *
   *   FT_LOAD_RENDER ::
   *     Call @FT_Render_Glyph after the glyph is loaded.  By default, the
   *     glyph is rendered in @FT_RENDER_MODE_NORMAL mode.  This can be
   *     overridden by @FT_LOAD_TARGET_XXX or @FT_LOAD_MONOCHROME.
   *
   *     This flag is unset by @FT_LOAD_NO_SCALE.
   *
   *   FT_LOAD_NO_BITMAP ::
   *     Ignore bitmap strikes when loading.  Bitmap-only fonts ignore this
   *     flag.
   *
   *     @FT_LOAD_NO_SCALE always sets this flag.
   *
   *   FT_LOAD_VERTICAL_LAYOUT ::
   *     Load the glyph for vertical text layout.  _Don't_ use it as it is
   *     problematic currently.
   *
   *   FT_LOAD_FORCE_AUTOHINT ::
   *     Indicates that the auto-hinter is preferred over the font's native
   *     hinter.  See also the note below.
   *
   *   FT_LOAD_CROP_BITMAP ::
   *     Indicates that the font driver should crop the loaded bitmap glyph
   *     (i.e., remove all space around its black bits).  Not all drivers
   *     implement this.
   *
   *   FT_LOAD_PEDANTIC ::
   *     Indicates that the font driver should perform pedantic verifications
   *     during glyph loading.  This is mostly used to detect broken glyphs
   *     in fonts.  By default, FreeType tries to handle broken fonts also.
   *
   *   FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH ::
   *     Indicates that the font driver should ignore the global advance
   *     width defined in the font.  By default, that value is used as the
   *     advance width for all glyphs when the face has
   *     @FT_FACE_FLAG_FIXED_WIDTH set.
   *
   *     This flag exists for historical reasons (to support buggy CJK
   *     fonts).
   *
   *   FT_LOAD_NO_RECURSE ::
   *     This flag is only used internally.  It merely indicates that the
   *     font driver should not load composite glyphs recursively.  Instead,
   *     it should set the `num_subglyph' and `subglyphs' values of the
   *     glyph slot accordingly, and set `glyph->format' to
   *     @FT_GLYPH_FORMAT_COMPOSITE.
   *
   *     The description of sub-glyphs is not available to client
   *     applications for now.
   *
   *     This flag implies @FT_LOAD_NO_SCALE and @FT_LOAD_IGNORE_TRANSFORM.
   *
   *   FT_LOAD_IGNORE_TRANSFORM ::
   *     Indicates that the transform matrix set by @FT_Set_Transform should
   *     be ignored.
   *
   *   FT_LOAD_MONOCHROME ::
   *     This flag is used with @FT_LOAD_RENDER to indicate that you want to
   *     render an outline glyph to a 1-bit monochrome bitmap glyph, with
   *     8 pixels packed into each byte of the bitmap data.
   *
   *     Note that this has no effect on the hinting algorithm used.  You
   *     should use @FT_LOAD_TARGET_MONO instead so that the
   *     monochrome-optimized hinting algorithm is used.
   *
   *   FT_LOAD_LINEAR_DESIGN ::
   *     Indicates that the `linearHoriAdvance' and `linearVertAdvance'
   *     fields of @FT_GlyphSlotRec should be kept in font units.  See
   *     @FT_GlyphSlotRec for details.
   *
   *   FT_LOAD_NO_AUTOHINT ::
   *     Disable auto-hinter.  See also the note below.
   *
   * @note:
   *   By default, hinting is enabled and the font's native hinter (see
   *   @FT_FACE_FLAG_HINTER) is preferred over the auto-hinter.  You can
   *   disable hinting by setting @FT_LOAD_NO_HINTING or change the
   *   precedence by setting @FT_LOAD_FORCE_AUTOHINT.  You can also set
   *   @FT_LOAD_NO_AUTOHINT in case you don't want the auto-hinter to be
   *   used at all.
   *
   *   Besides deciding which hinter to use, you can also decide which
   *   hinting algorithm to use.  See @FT_LOAD_TARGET_XXX for details.
   *)
  FT_LOAD_DEFAULT                      = $0000;
  FT_LOAD_NO_SCALE                     = $0001;
  FT_LOAD_NO_HINTING                   = $0002;
  FT_LOAD_RENDER                       = $0004;
  FT_LOAD_NO_BITMAP                    = $0008;
  FT_LOAD_VERTICAL_LAYOUT              = $0010;
  FT_LOAD_FORCE_AUTOHINT               = $0020;
  FT_LOAD_CROP_BITMAP                  = $0040;
  FT_LOAD_PEDANTIC                     = $0080;
  FT_LOAD_IGNORE_GLOBAL_ADVANCE_WIDTH  = $0200;
  FT_LOAD_NO_RECURSE                   = $0400;
  FT_LOAD_IGNORE_TRANSFORM             = $0800;
  FT_LOAD_MONOCHROME                   = $1000;
  FT_LOAD_LINEAR_DESIGN                = $2000;

  (* temporary hack! *)
  FT_LOAD_SBITS_ONLY                   = $4000;
  FT_LOAD_NO_AUTOHINT                  = $8000;


  (*************************************************************************
   *
   * @macro:
   *   FT_SUBGLYPH_FLAG_XXX
   *
   * @description:
   *   A list of constants used to describe subglyphs.  Please refer to the
   *   TrueType specification for the meaning of the various flags.
   *
   * @values:
   *   FT_SUBGLYPH_FLAG_ARGS_ARE_WORDS ::
   *   FT_SUBGLYPH_FLAG_ARGS_ARE_XY_VALUES ::
   *   FT_SUBGLYPH_FLAG_ROUND_XY_TO_GRID ::
   *   FT_SUBGLYPH_FLAG_SCALE ::
   *   FT_SUBGLYPH_FLAG_XY_SCALE ::
   *   FT_SUBGLYPH_FLAG_2X2 ::
   *   FT_SUBGLYPH_FLAG_USE_MY_METRICS ::
   *
   *)
  FT_SUBGLYPH_FLAG_ARGS_ARE_WORDS       = $0001;
  FT_SUBGLYPH_FLAG_ARGS_ARE_XY_VALUES   = $0002;
  FT_SUBGLYPH_FLAG_ROUND_XY_TO_GRID     = $0004;
  FT_SUBGLYPH_FLAG_SCALE                = $0008;
  FT_SUBGLYPH_FLAG_XY_SCALE             = $0040;
  FT_SUBGLYPH_FLAG_2X2                  = $0080;
  FT_SUBGLYPH_FLAG_USE_MY_METRICS       = $0200;


  (*************************************************************************)
  (*                                                                       *)
  (* <Enum>                                                                *)
  (*   FT_OUTLINE_FLAGS                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A list of bit-field constants use for the flags in an outline's    *)
  (*    `flags' field.                                                     *)
  (*                                                                       *)
  (* <Values>                                                              *)
  (*    FT_OUTLINE_NONE           :: Value 0 is reserved.                  *)
  (*                                                                       *)
  (*    FT_OUTLINE_OWNER          :: If set, this flag indicates that the  *)
  (*                                 outline's field arrays (i.e.,         *)
  (*                                 `points', `flags' & `contours') are   *)
  (*                                 `owned' by the outline object, and    *)
  (*                                 should thus be freed when it is       *)
  (*                                 destroyed.                            *)
  (*                                                                       *)
  (*   FT_OUTLINE_EVEN_ODD_FILL   :: By default, outlines are filled using *)
  (*                                 the non-zero winding rule.  If set to *)
  (*                                 1, the outline will be filled using   *)
  (*                                 the even-odd fill rule (only works    *)
  (*                                 with the smooth raster).              *)
  (*                                                                       *)
  (*   FT_OUTLINE_REVERSE_FILL    :: By default, outside contours of an    *)
  (*                                 outline are oriented in clock-wise    *)
  (*                                 direction, as defined in the TrueType *)
  (*                                 specification.  This flag is set if   *)
  (*                                 the outline uses the opposite         *)
  (*                                 direction (typically for Type 1       *)
  (*                                 fonts).  This flag is ignored by the  *)
  (*                                 scan-converter.                       *)
  (*                                                                       *)
  (*   FT_OUTLINE_IGNORE_DROPOUTS :: By default, the scan converter will   *)
  (*                                 try to detect drop-outs in an outline *)
  (*                                 and correct the glyph bitmap to       *)
  (*                                 ensure consistent shape continuity.   *)
  (*                                 If set, this flag hints the scan-line *)
  (*                                 converter to ignore such cases.       *)
  (*                                                                       *)
  (*   FT_OUTLINE_HIGH_PRECISION  :: This flag indicates that the          *)
  (*                                 scan-line converter should try to     *)
  (*                                 convert this outline to bitmaps with  *)
  (*                                 the highest possible quality.  It is  *)
  (*                                 typically set for small character     *)
  (*                                 sizes.  Note that this is only a      *)
  (*                                 hint, that might be completely        *)
  (*                                 ignored by a given scan-converter.    *)
  (*                                                                       *)
  (*   FT_OUTLINE_SINGLE_PASS     :: This flag is set to force a given     *)
  (*                                 scan-converter to only use a single   *)
  (*                                 pass over the outline to render a     *)
  (*                                 bitmap glyph image.  Normally, it is  *)
  (*                                 set for very large character sizes.   *)
  (*                                 It is only a hint, that might be      *)
  (*                                 completely ignored by a given         *)
  (*                                 scan-converter.                       *)
  (*                                                                       *)
  FT_OUTLINE_NONE             = $0;
  FT_OUTLINE_OWNER            = $1;
  FT_OUTLINE_EVEN_ODD_FILL    = $2;
  FT_OUTLINE_REVERSE_FILL     = $4;
  FT_OUTLINE_IGNORE_DROPOUTS  = $8;

  FT_OUTLINE_HIGH_PRECISION   = $100;
  FT_OUTLINE_SINGLE_PASS      = $200;



  FT_CURVE_TAG_ON          =  1;
  FT_CURVE_TAG_CONIC       =  0;
  FT_CURVE_TAG_CUBIC       =  2;

  FT_CURVE_TAG_TOUCH_X     =  8;  (* reserved for the TrueType hinter *)
  FT_CURVE_TAG_TOUCH_Y     = 16;  (* reserved for the TrueType hinter *)

  FT_CURVE_TAG_TOUCH_BOTH  = FT_CURVE_TAG_TOUCH_X or FT_CURVE_TAG_TOUCH_Y;


  (*************************************************************************)
  (*                                                                       *)
  (* <Enum>                                                                *)
  (*    FT_RASTER_FLAG_XXX                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A list of bit flag constants as used in the `flags' field of a     *)
  (*    @FT_Raster_Params structure.                                       *)
  (*                                                                       *)
  (* <Values>                                                              *)
  (*    FT_RASTER_FLAG_DEFAULT :: This value is 0.                         *)
  (*                                                                       *)
  (*    FT_RASTER_FLAG_AA      :: This flag is set to indicate that an     *)
  (*                              anti-aliased glyph image should be       *)
  (*                              generated.  Otherwise, it will be        *)
  (*                              monochrome (1-bit).                      *)
  (*                                                                       *)
  (*    FT_RASTER_FLAG_DIRECT  :: This flag is set to indicate direct      *)
  (*                              rendering.  In this mode, client         *)
  (*                              applications must provide their own span *)
  (*                              callback.  This lets them directly       *)
  (*                              draw or compose over an existing bitmap. *)
  (*                              If this bit is not set, the target       *)
  (*                              pixmap's buffer _must_ be zeroed before  *)
  (*                              rendering.                               *)
  (*                                                                       *)
  (*                              Note that for now, direct rendering is   *)
  (*                              only possible with anti-aliased glyphs.  *)
  (*                                                                       *)
  (*    FT_RASTER_FLAG_CLIP    :: This flag is only used in direct         *)
  (*                              rendering mode.  If set, the output will *)
  (*                              be clipped to a box specified in the     *)
  (*                              `clip_box' field of the                  *)
  (*                              @FT_Raster_Params structure.             *)
  (*                                                                       *)
  (*                              Note that by default, the glyph bitmap   *)
  (*                              is clipped to the target pixmap, except  *)
  (*                              in direct rendering mode where all spans *)
  (*                              are generated if no clipping box is set. *)
  (*                                                                       *)
  FT_RASTER_FLAG_DEFAULT  = $0;
  FT_RASTER_FLAG_AA       = $1;
  FT_RASTER_FLAG_DIRECT   = $2;
  FT_RASTER_FLAG_CLIP     = $4;


  (*************************************************************************
   *
   * @enum:
   *   FT_GASP_XXX
   *
   * @description:
   *   A list of values and/or bit-flags returned by the @FT_Get_Gasp
   *   function.
   *
   * @values:
   *   FT_GASP_NO_TABLE ::
   *     This special value means that there is no GASP table in this face.
   *     It is up to the client to decide what to do.
   *
   *   FT_GASP_DO_GRIDFIT ::
   *     Grid-fitting and hinting should be performed at the specified ppem.
   *     This *really* means TrueType bytecode interpretation.
   *
   *   FT_GASP_DO_GRAY ::
   *     Anti-aliased rendering should be performed at the specified ppem.
   *
   *   FT_GASP_SYMMETRIC_SMOOTHING ::
   *     Smoothing along multiple axes must be used with ClearType.
   *
   *   FT_GASP_SYMMETRIC_GRIDFIT ::
   *     Grid-fitting must be used with ClearType's symmetric smoothing.
   *
   * @note:
   *   `ClearType' is Microsoft's implementation of LCD rendering, partly
   *   protected by patents.
   *
   * @since:
   *   2.3.0
   *)
  FT_GASP_NO_TABLE             =  -1;
  FT_GASP_DO_GRIDFIT           = $01;
  FT_GASP_DO_GRAY              = $02;
  FT_GASP_SYMMETRIC_SMOOTHING  = $08;
  FT_GASP_SYMMETRIC_GRIDFIT    = $10;


  (* module bit flags *)
  FT_MODULE_FONT_DRIVER        = 1;  (* this module is a font driver  *)
  FT_MODULE_RENDERER           = 2;  (* this module is a renderer     *)
  FT_MODULE_HINTER             = 4;  (* this module is a glyph hinter *)
  FT_MODULE_STYLER             = 8;  (* this module is a styler       *)

  FT_MODULE_DRIVER_SCALABLE    = $100;   (* the driver supports      *)
                                         (* scalable fonts           *)
  FT_MODULE_DRIVER_NO_OUTLINES = $200;   (* the driver does not      *)
                                         (* support vector outlines  *)
  FT_MODULE_DRIVER_HAS_HINTER  = $400;   (* the driver provides its  *)



// enums
type
  (*************************************************************************)
  (*                                                                       *)
  (* <Enum>                                                                *)
  (*    FT_Encoding                                                        *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    An enumeration used to specify character sets supported by         *)
  (*    charmaps.  Used in the @FT_Select_Charmap API function.            *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    Despite the name, this enumeration lists specific character        *)
  (*    repertories (i.e., charsets), and not text encoding methods (e.g., *)
  (*    UTF-8, UTF-16, GB2312_EUC, etc.).                                  *)
  (*                                                                       *)
  (*    Because of 32-bit charcodes defined in Unicode (i.e., surrogates), *)
  (*    all character codes must be expressed as FT_Longs.                 *)
  (*                                                                       *)
  (*    Other encodings might be defined in the future.                    *)
  (*                                                                       *)
  (* <Values>                                                              *)
  (*   FT_ENCODING_NONE ::                                                 *)
  (*     The encoding value 0 is reserved.                                 *)
  (*                                                                       *)
  (*   FT_ENCODING_UNICODE ::                                              *)
  (*     Corresponds to the Unicode character set.  This value covers      *)
  (*     all versions of the Unicode repertoire, including ASCII and       *)
  (*     Latin-1.  Most fonts include a Unicode charmap, but not all       *)
  (*     of them.                                                          *)
  (*                                                                       *)
  (*   FT_ENCODING_MS_SYMBOL ::                                            *)
  (*     Corresponds to the Microsoft Symbol encoding, used to encode      *)
  (*     mathematical symbols in the 32..255 character code range.  For    *)
  (*     more information, see `http://www.ceviz.net/symbol.htm'.          *)
  (*                                                                       *)
  (*   FT_ENCODING_SJIS ::                                                 *)
  (*     Corresponds to Japanese SJIS encoding.  More info at              *)
  (*     at `http://langsupport.japanreference.com/encoding.shtml'.        *)
  (*     See note on multi-byte encodings below.                           *)
  (*                                                                       *)
  (*   FT_ENCODING_GB2312 ::                                               *)
  (*     Corresponds to an encoding system for Simplified Chinese as used  *)
  (*     used in mainland China.                                           *)
  (*                                                                       *)
  (*   FT_ENCODING_BIG5 ::                                                 *)
  (*     Corresponds to an encoding system for Traditional Chinese as used *)
  (*     in Taiwan and Hong Kong.                                          *)
  (*                                                                       *)
  (*   FT_ENCODING_WANSUNG ::                                              *)
  (*     Corresponds to the Korean encoding system known as Wansung.       *)
  (*     For more information see                                          *)
  (*     `http://www.microsoft.com/typography/unicode/949.txt'.            *)
  (*                                                                       *)
  (*   FT_ENCODING_JOHAB ::                                                *)
  (*     The Korean standard character set (KS C-5601-1992), which         *)
  (*     corresponds to MS Windows code page 1361.  This character set     *)
  (*     includes all possible Hangeul character combinations.             *)
  (*                                                                       *)
  (*   FT_ENCODING_ADOBE_LATIN_1 ::                                        *)
  (*     Corresponds to a Latin-1 encoding as defined in a Type 1          *)
  (*     Postscript font.  It is limited to 256 character codes.           *)
  (*                                                                       *)
  (*   FT_ENCODING_ADOBE_STANDARD ::                                       *)
  (*     Corresponds to the Adobe Standard encoding, as found in Type 1,   *)
  (*     CFF, and OpenType/CFF fonts.  It is limited to 256 character      *)
  (*     codes.                                                            *)
  (*                                                                       *)
  (*   FT_ENCODING_ADOBE_EXPERT ::                                         *)
  (*     Corresponds to the Adobe Expert encoding, as found in Type 1,     *)
  (*     CFF, and OpenType/CFF fonts.  It is limited to 256 character      *)
  (*     codes.                                                            *)
  (*                                                                       *)
  (*   FT_ENCODING_ADOBE_CUSTOM ::                                         *)
  (*     Corresponds to a custom encoding, as found in Type 1, CFF, and    *)
  (*     OpenType/CFF fonts.  It is limited to 256 character codes.        *)
  (*                                                                       *)
  (*   FT_ENCODING_APPLE_ROMAN ::                                          *)
  (*     Corresponds to the 8-bit Apple roman encoding.  Many TrueType and *)
  (*     OpenType fonts contain a charmap for this encoding, since older   *)
  (*     versions of Mac OS are able to use it.                            *)
  (*                                                                       *)
  (*   FT_ENCODING_OLD_LATIN_2 ::                                          *)
  (*     This value is deprecated and was never used nor reported by       *)
  (*     FreeType.  Don't use or test for it.                              *)
  (*                                                                       *)
  (*   FT_ENCODING_MS_SJIS ::                                              *)
  (*     Same as FT_ENCODING_SJIS.  Deprecated.                            *)
  (*                                                                       *)
  (*   FT_ENCODING_MS_GB2312 ::                                            *)
  (*     Same as FT_ENCODING_GB2312.  Deprecated.                          *)
  (*                                                                       *)
  (*   FT_ENCODING_MS_BIG5 ::                                              *)
  (*     Same as FT_ENCODING_BIG5.  Deprecated.                            *)
  (*                                                                       *)
  (*   FT_ENCODING_MS_WANSUNG ::                                           *)
  (*     Same as FT_ENCODING_WANSUNG.  Deprecated.                         *)
  (*                                                                       *)
  (*   FT_ENCODING_MS_JOHAB ::                                             *)
  (*     Same as FT_ENCODING_JOHAB.  Deprecated.                           *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*   By default, FreeType automatically synthetizes a Unicode charmap    *)
  (*   for Postscript fonts, using their glyph names dictionaries.         *)
  (*   However, it also reports the encodings defined explicitly in the    *)
  (*   font file, for the cases when they are needed, with the Adobe       *)
  (*   values as well.                                                     *)
  (*                                                                       *)
  (*   FT_ENCODING_NONE is set by the BDF and PCF drivers if the charmap   *)
  (*   is neither Unicode nor ISO-8859-1 (otherwise it is set to           *)
  (*   FT_ENCODING_UNICODE).  Use @FT_Get_BDF_Charset_ID to find out which *)
  (*   encoding is really present.  If, for example, the `cs_registry'     *)
  (*   field is `KOI8' and the `cs_encoding' field is `R', the font is     *)
  (*   encoded in KOI8-R.                                                  *)
  (*                                                                       *)
  (*   FT_ENCODING_NONE is always set (with a single exception) by the     *)
  (*   winfonts driver.  Use @FT_Get_WinFNT_Header and examine the         *)
  (*   `charset' field of the @FT_WinFNT_HeaderRec structure to find out   *)
  (*   which encoding is really present.  For example,                     *)
  (*   @FT_WinFNT_ID_CP1251 (204) means Windows code page 1251 (for        *)
  (*   Russian).                                                           *)
  (*                                                                       *)
  (*   FT_ENCODING_NONE is set if `platform_id' is @TT_PLATFORM_MACINTOSH  *)
  (*   and `encoding_id' is not @TT_MAC_ID_ROMAN (otherwise it is set to   *)
  (*   FT_ENCODING_APPLE_ROMAN).                                           *)
  (*                                                                       *)
  (*   If `platform_id' is @TT_PLATFORM_MACINTOSH, use the function  c     *)
  (*   @FT_Get_CMap_Language_ID  to query the Mac language ID which may be *)
  (*   needed to be able to distinguish Apple encoding variants.  See      *)
  (*                                                                       *)
  (*     http://www.unicode.org/Public/MAPPINGS/VENDORS/APPLE/README.TXT   *)
  (*                                                                       *)
  (*   to get an idea how to do that.  Basically, if the language ID is 0, *)
  (*   don't use it, otherwise subtract 1 from the language ID.  Then      *)
  (*   examine `encoding_id'.  If, for example, `encoding_id' is           *)
  (*   @TT_MAC_ID_ROMAN and the language ID (minus 1) is                   *)
  (*   `TT_MAC_LANGID_GREEK', it is the Greek encoding, not Roman.         *)
  (*   @TT_MAC_ID_ARABIC with `TT_MAC_LANGID_FARSI' means the Farsi        *)
  (*   variant the Arabic encoding.                                        *)
  (*                                                                       *)
  FT_Encoding = (
    FT_ENCODING_NONE            =        0 shl 24 or        0 shl 16 or        0 shl 8 or       0,

    FT_ENCODING_MS_SYMBOL       = ord('s') shl 24 or ord('y') shl 16 or ord('m') shl 8 or ord('b'),
    FT_ENCODING_UNICODE         = ord('u') shl 24 or ord('n') shl 16 or ord('i') shl 8 or ord('c'),

    FT_ENCODING_SJIS            = ord('s') shl 24 or ord('j') shl 16 or ord('i') shl 8 or ord('s'),
    FT_ENCODING_GB2312          = ord('g') shl 24 or ord('b') shl 16 or ord(' ') shl 8 or ord(' '),
    FT_ENCODING_BIG5            = ord('b') shl 24 or ord('i') shl 16 or ord('g') shl 8 or ord('5'),
    FT_ENCODING_WANSUNG         = ord('w') shl 24 or ord('a') shl 16 or ord('n') shl 8 or ord('s'),
    FT_ENCODING_JOHAB           = ord('j') shl 24 or ord('o') shl 16 or ord('h') shl 8 or ord('a'),

    FT_ENCODING_MS_SJIS         = FT_ENCODING_SJIS,
    FT_ENCODING_MS_GB2312       = FT_ENCODING_GB2312,
    FT_ENCODING_MS_BIG5         = FT_ENCODING_BIG5,
    FT_ENCODING_MS_WANSUNG      = FT_ENCODING_WANSUNG,
    FT_ENCODING_MS_JOHAB        = FT_ENCODING_JOHAB,

    FT_ENCODING_ADOBE_STANDARD  = ord('A') shl 24 or ord('D') shl 16 or ord('O') shl 8 or ord('B'),
    FT_ENCODING_ADOBE_EXPERT    = ord('A') shl 24 or ord('D') shl 16 or ord('B') shl 8 or ord('E'),
    FT_ENCODING_ADOBE_CUSTOM    = ord('A') shl 24 or ord('D') shl 16 or ord('B') shl 8 or ord('C'),
    FT_ENCODING_ADOBE_LATIN_1   = ord('l') shl 24 or ord('a') shl 16 or ord('t') shl 8 or ord('1'),

    FT_ENCODING_OLD_LATIN_2     = ord('l') shl 24 or ord('a') shl 16 or ord('t') shl 8 or ord('2'),

    FT_ENCODING_APPLE_ROMAN     = ord('a') shl 24 or ord('r') shl 16 or ord('m') shl 8 or ord('n')
  );


  (*************************************************************************)
  (*                                                                       *)
  (* <Enum>                                                                *)
  (*    FT_Glyph_Format                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    An enumeration type used to describe the format of a given glyph   *)
  (*    image.  Note that this version of FreeType only supports two image *)
  (*    formats, even though future font drivers will be able to register  *)
  (*    their own format.                                                  *)
  (*                                                                       *)
  (* <Values>                                                              *)
  (*    FT_GLYPH_FORMAT_NONE ::                                            *)
  (*      The value 0 is reserved.                                         *)
  (*                                                                       *)
  (*    FT_GLYPH_FORMAT_COMPOSITE ::                                       *)
  (*      The glyph image is a composite of several other images.  This    *)
  (*      format is _only_ used with @FT_LOAD_NO_RECURSE, and is used to   *)
  (*      report compound glyphs (like accented characters).               *)
  (*                                                                       *)
  (*    FT_GLYPH_FORMAT_BITMAP ::                                          *)
  (*      The glyph image is a bitmap, and can be described as an          *)
  (*      @FT_Bitmap.  You generally need to access the `bitmap' field of  *)
  (*      the @FT_GlyphSlotRec structure to read it.                       *)
  (*                                                                       *)
  (*    FT_GLYPH_FORMAT_OUTLINE ::                                         *)
  (*      The glyph image is a vectorial outline made of line segments     *)
  (*      and Bézier arcs; it can be described as an @FT_Outline; you      *)
  (*      generally want to access the `outline' field of the              *)
  (*      @FT_GlyphSlotRec structure to read it.                           *)
  (*                                                                       *)
  (*    FT_GLYPH_FORMAT_PLOTTER ::                                         *)
  (*      The glyph image is a vectorial path with no inside and outside   *)
  (*      contours.  Some Type 1 fonts, like those in the Hershey family,  *)
  (*      contain glyphs in this format.  These are described as           *)
  (*      @FT_Outline, but FreeType isn't currently capable of rendering   *)
  (*      them correctly.                                                  *)
  (*                                                                       *)
  FT_Glyph_Format = (
    FT_GLYPH_FORMAT_NONE      =        0 shl 24 or        0 shl 16 or        0 shl 8 or        0,

    FT_GLYPH_FORMAT_COMPOSITE = ord('c') shl 24 or ord('o') shl 16 or ord('m') shl 8 or ord('p'),
    FT_GLYPH_FORMAT_BITMAP    = ord('b') shl 24 or ord('i') shl 16 or ord('t') shl 8 or ord('s'),
    FT_GLYPH_FORMAT_OUTLINE   = ord('o') shl 24 or ord('u') shl 16 or ord('t') shl 8 or ord('l'),
    FT_GLYPH_FORMAT_PLOTTER   = ord('p') shl 24 or ord('l') shl 16 or ord('o') shl 8 or ord('t')
  );


  (*************************************************************************)
  (*                                                                       *)
  (* <Enum>                                                                *)
  (*    FT_Render_Mode                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    An enumeration type that lists the render modes supported by       *)
  (*    FreeType 2.  Each mode corresponds to a specific type of scanline  *)
  (*    conversion performed on the outline.                               *)
  (*                                                                       *)
  (*    For bitmap fonts the `bitmap->pixel_mode' field in the             *)
  (*    @FT_GlyphSlotRec structure gives the format of the returned        *)
  (*    bitmap.                                                            *)
  (*                                                                       *)
  (* <Values>                                                              *)
  (*    FT_RENDER_MODE_NORMAL ::                                           *)
  (*      This is the default render mode; it corresponds to 8-bit         *)
  (*      anti-aliased bitmaps, using 256 levels of opacity.               *)
  (*                                                                       *)
  (*    FT_RENDER_MODE_LIGHT ::                                            *)
  (*      This is equivalent to @FT_RENDER_MODE_NORMAL.  It is only        *)
  (*      defined as a separate value because render modes are also used   *)
  (*      indirectly to define hinting algorithm selectors.  See           *)
  (*      @FT_LOAD_TARGET_XXX for details.                                 *)
  (*                                                                       *)
  (*    FT_RENDER_MODE_MONO ::                                             *)
  (*      This mode corresponds to 1-bit bitmaps.                          *)
  (*                                                                       *)
  (*    FT_RENDER_MODE_LCD ::                                              *)
  (*      This mode corresponds to horizontal RGB and BGR sub-pixel        *)
  (*      displays, like LCD-screens.  It produces 8-bit bitmaps that are  *)
  (*      3 times the width of the original glyph outline in pixels, and   *)
  (*      which use the @FT_PIXEL_MODE_LCD mode.                           *)
  (*                                                                       *)
  (*    FT_RENDER_MODE_LCD_V ::                                            *)
  (*      This mode corresponds to vertical RGB and BGR sub-pixel displays *)
  (*      (like PDA screens, rotated LCD displays, etc.).  It produces     *)
  (*      8-bit bitmaps that are 3 times the height of the original        *)
  (*      glyph outline in pixels and use the @FT_PIXEL_MODE_LCD_V mode.   *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*   The LCD-optimized glyph bitmaps produced by FT_Render_Glyph are     *)
  (*   _not_ _filtered_ to reduce color-fringes.  It is up to the caller   *)
  (*   to perform this pass.                                               *)
  (*                                                                       *)
  FT_Render_Mode = (
    FT_RENDER_MODE_NORMAL = 0,
    FT_RENDER_MODE_LIGHT,
    FT_RENDER_MODE_MONO,
    FT_RENDER_MODE_LCD,
    FT_RENDER_MODE_LCD_V,

    FT_RENDER_MODE_MAX
  );


  (*************************************************************************)
  (*                                                                       *)
  (* <Enum>                                                                *)
  (*    FT_Pixel_Mode                                                      *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    An enumeration type used to describe the format of pixels in a     *)
  (*    given bitmap.  Note that additional formats may be added in the    *)
  (*    future.                                                            *)
  (*                                                                       *)
  (* <Values>                                                              *)
  (*    FT_PIXEL_MODE_NONE ::                                              *)
  (*      Value 0 is reserved.                                             *)
  (*                                                                       *)
  (*    FT_PIXEL_MODE_MONO ::                                              *)
  (*      A monochrome bitmap, using 1 bit per pixel.  Note that pixels    *)
  (*      are stored in most-significant order (MSB), which means that     *)
  (*      the left-most pixel in a byte has value 128.                     *)
  (*                                                                       *)
  (*    FT_PIXEL_MODE_GRAY ::                                              *)
  (*      An 8-bit bitmap, generally used to represent anti-aliased glyph  *)
  (*      images.  Each pixel is stored in one byte.  Note that the number *)
  (*      of value `gray' levels is stored in the `num_bytes' field of     *)
  (*      the @FT_Bitmap structure (it generally is 256).                  *)
  (*                                                                       *)
  (*    FT_PIXEL_MODE_GRAY2 ::                                             *)
  (*      A 2-bit/pixel bitmap, used to represent embedded anti-aliased    *)
  (*      bitmaps in font files according to the OpenType specification.   *)
  (*      We haven't found a single font using this format, however.       *)
  (*                                                                       *)
  (*    FT_PIXEL_MODE_GRAY4 ::                                             *)
  (*      A 4-bit/pixel bitmap, used to represent embedded anti-aliased    *)
  (*      bitmaps in font files according to the OpenType specification.   *)
  (*      We haven't found a single font using this format, however.       *)
  (*                                                                       *)
  (*    FT_PIXEL_MODE_LCD ::                                               *)
  (*      An 8-bit bitmap, used to represent RGB or BGR decimated glyph    *)
  (*      images used for display on LCD displays; the bitmap is three     *)
  (*      times wider than the original glyph image.  See also             *)
  (*      @FT_RENDER_MODE_LCD.                                             *)
  (*                                                                       *)
  (*    FT_PIXEL_MODE_LCD_V ::                                             *)
  (*      An 8-bit bitmap, used to represent RGB or BGR decimated glyph    *)
  (*      images used for display on rotated LCD displays; the bitmap      *)
  (*      is three times taller than the original glyph image.  See also   *)
  (*      @FT_RENDER_MODE_LCD_V.                                           *)
  (*                                                                       *)
  FT_Pixel_Mode = (
    FT_PIXEL_MODE_NONE = 0,
    FT_PIXEL_MODE_MONO,
    FT_PIXEL_MODE_GRAY,
    FT_PIXEL_MODE_GRAY2,
    FT_PIXEL_MODE_GRAY4,
    FT_PIXEL_MODE_LCD,
    FT_PIXEL_MODE_LCD_V,

    FT_PIXEL_MODE_MAX      (* do not remove *)
  );


  (*************************************************************************)
  (*                                                                       *)
  (* <Enum>                                                                *)
  (*    FT_Palette_Mode                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    THIS TYPE IS DEPRECATED.  DO NOT USE IT!                           *)
  (*                                                                       *)
  (*    An enumeration type to describe the format of a bitmap palette,    *)
  (*    used with ft_pixel_mode_pal4 and ft_pixel_mode_pal8.               *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    ft_palette_mode_rgb  :: The palette is an array of 3-bytes RGB     *)
  (*                            records.                                   *)
  (*                                                                       *)
  (*    ft_palette_mode_rgba :: The palette is an array of 4-bytes RGBA    *)
  (*                            records.                                   *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    As ft_pixel_mode_pal2, pal4 and pal8 are currently unused by       *)
  (*    FreeType, these types are not handled by the library itself.       *)
  (*                                                                       *)
  FT_Palette_Mode = (
    ft_palette_mode_rgb = 0,
    ft_palette_mode_rgba,

    ft_palettte_mode_max   (* do not remove *)
  );


  (*************************************************************************)
  (*                                                                       *)
  (* <Enum>                                                                *)
  (*    FT_Kerning_Mode                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    An enumeration used to specify which kerning values to return in   *)
  (*    @FT_Get_Kerning.                                                   *)
  (*                                                                       *)
  (* <Values>                                                              *)
  (*    FT_KERNING_DEFAULT  :: Return scaled and grid-fitted kerning       *)
  (*                           distances (value is 0).                     *)
  (*                                                                       *)
  (*    FT_KERNING_UNFITTED :: Return scaled but un-grid-fitted kerning    *)
  (*                           distances.                                  *)
  (*                                                                       *)
  (*    FT_KERNING_UNSCALED :: Return the kerning vector in original font  *)
  (*                           units.                                      *)
  (*                                                                       *)
  FT_Kerning_Mode = (
    FT_KERNING_DEFAULT  = 0,
    FT_KERNING_UNFITTED,
    FT_KERNING_UNSCALED
  );


  (*************************************************************************)
  (*                                                                       *)
  (* <Enum>                                                                *)
  (*    FT_Size_Request_Type                                               *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    An enumeration type that lists the supported size request types.   *)
  (*                                                                       *)
  (* <Values>                                                              *)
  (*    FT_SIZE_REQUEST_TYPE_NOMINAL ::                                    *)
  (*      The nominal size.  The `units_per_EM' field of @FT_FaceRec is    *)
  (*      used to determine both scaling values.                           *)
  (*                                                                       *)
  (*    FT_SIZE_REQUEST_TYPE_REAL_DIM ::                                   *)
  (*      The real dimension.  The sum of the the `Ascender' and (minus    *)
  (*      of) the `Descender' fields of @FT_FaceRec are used to determine  *)
  (*      both scaling values.                                             *)
  (*                                                                       *)
  (*    FT_SIZE_REQUEST_TYPE_BBOX ::                                       *)
  (*      The font bounding box.  The width and height of the `bbox' field *)
  (*      of @FT_FaceRec are used to determine the horizontal and vertical *)
  (*      scaling value, respectively.                                     *)
  (*                                                                       *)
  (*    FT_SIZE_REQUEST_TYPE_CELL ::                                       *)
  (*      The `max_advance_width' field of @FT_FaceRec is used to          *)
  (*      determine the horizontal scaling value; the vertical scaling     *)
  (*      value is determined the same way as                              *)
  (*      @FT_SIZE_REQUEST_TYPE_REAL_DIM does.  Finally, both scaling      *)
  (*      values are set to the smaller one.  This type is useful if you   *)
  (*      want to specify the font size for, say, a window of a given      *)
  (*      dimension and 80x24 cells.                                       *)
  (*                                                                       *)
  (*    FT_SIZE_REQUEST_TYPE_SCALES ::                                     *)
  (*      Specify the scaling values directly.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The above descriptions only apply to scalable formats.  For bitmap *)
  (*    formats, the behaviour is up to the driver.                        *)
  (*                                                                       *)
  (*    See the note section of @FT_Size_Metrics if you wonder how size    *)
  (*    requesting relates to scaling values.                              *)
  (*                                                                       *)
  FT_Size_Request_Type = (
    FT_SIZE_REQUEST_TYPE_NOMINAL,
    FT_SIZE_REQUEST_TYPE_REAL_DIM,
    FT_SIZE_REQUEST_TYPE_BBOX,
    FT_SIZE_REQUEST_TYPE_CELL,
    FT_SIZE_REQUEST_TYPE_SCALES,

    FT_SIZE_REQUEST_TYPE_MAX
  );


  (***************************************************************************
   *
   * @section:
   *   lcd_filtering
   *
   * @title:
   *   LCD Filtering
   *
   * @abstract:
   *   Reduce color fringes of LCD-optimized bitmaps.
   *
   * @description:
   *   The @FT_Library_SetLcdFilter API can be used to specify a low-pass
   *   filter which is then applied to LCD-optimized bitmaps generated
   *   through @FT_Render_Glyph.  This is useful to reduce color fringes
   *   which would occur with unfiltered rendering.
   *
   *   Note that no filter is active by default, and that this function is
   *   *not* implemented in default builds of the library.  You need to
   *   #define FT_CONFIG_OPTION_SUBPIXEL_RENDERING in your `ftoption.h' file
   *   in order to activate it.
   *)

  (****************************************************************************
   *
   * @func:
   *   FT_LcdFilter
   *
   * @description:
   *   A list of values to identify various types of LCD filters.
   *
   * @values:
   *   FT_LCD_FILTER_NONE ::
   *     Do not perform filtering.  When used with subpixel rendering, this
   *     results in sometimes severe color fringes.
   *
   *   FT_LCD_FILTER_DEFAULT ::
   *     The default filter reduces color fringes considerably, at the cost
   *     of a slight blurriness in the output.
   *
   *   FT_LCD_FILTER_LIGHT ::
   *     The light filter is a variant that produces less blurriness at the
   *     cost of slightly more color fringes than the default one.  It might
   *     be better, depending on taste, your monitor, or your personal vision.
   *
   *   FT_LCD_FILTER_LEGACY ::
   *     This filter corresponds to the original libXft color filter.  It
   *     provides high contrast output but can exhibit really bad color
   *     fringes if glyphs are not extremely well hinted to the pixel grid.
   *     In other words, it only works well if the TrueType bytecode
   *     interpreter is enabled *and* high-quality hinted fonts are used.
   *
   *     This filter is only provided for comparison purposes, and might be
   *     disabled or stay unsupported in the future.
   *
   * @since:
   *   2.3.0
   *)
  FT_LcdFilter = (
    FT_LCD_FILTER_NONE    = 0,
    FT_LCD_FILTER_DEFAULT = 1,
    FT_LCD_FILTER_LIGHT   = 2,
    FT_LCD_FILTER_LEGACY  = 16,

    FT_LCD_FILTER_MAX   (* do not remove *)
  );


  (*************************************************************************)
  (*                                                                       *)
  (* <Enum>                                                                *)
  (*    FT_Glyph_BBox_Mode                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    The mode how the values of @FT_Glyph_Get_CBox are returned.        *)
  (*                                                                       *)
  (* <Values>                                                              *)
  (*    FT_GLYPH_BBOX_UNSCALED ::                                          *)
  (*      Return unscaled font units.                                      *)
  (*                                                                       *)
  (*    FT_GLYPH_BBOX_SUBPIXELS ::                                         *)
  (*      Return unfitted 26.6 coordinates.                                *)
  (*                                                                       *)
  (*    FT_GLYPH_BBOX_GRIDFIT ::                                           *)
  (*      Return grid-fitted 26.6 coordinates.                             *)
  (*                                                                       *)
  (*    FT_GLYPH_BBOX_TRUNCATE ::                                          *)
  (*      Return coordinates in integer pixels.                            *)
  (*                                                                       *)
  (*    FT_GLYPH_BBOX_PIXELS ::                                            *)
  (*      Return grid-fitted pixel coordinates.                            *)
  (*                                                                       *)
  FT_Glyph_BBox_Mode = (
    FT_GLYPH_BBOX_UNSCALED  = 0,
    FT_GLYPH_BBOX_SUBPIXELS = 0,
    FT_GLYPH_BBOX_GRIDFIT   = 1,
    FT_GLYPH_BBOX_TRUNCATE  = 2,
    FT_GLYPH_BBOX_PIXELS    = 3
  );


 (**************************************************************************
  *
  * @enum:
  *   FT_Orientation
  *
  * @description:
  *   A list of values used to describe an outline's contour orientation.
  *
  *   The TrueType and Postscript specifications use different conventions
  *   to determine whether outline contours should be filled or unfilled.
  *
  * @values:
  *   FT_ORIENTATION_TRUETYPE ::
  *     According to the TrueType specification, clockwise contours must
  *     be filled, and counter-clockwise ones must be unfilled.
  *
  *   FT_ORIENTATION_POSTSCRIPT ::
  *     According to the Postscript specification, counter-clockwise contours
  *     must be filled, and clockwise ones must be unfilled.
  *
  *   FT_ORIENTATION_FILL_RIGHT ::
  *     This is identical to @FT_ORIENTATION_TRUETYPE, but is used to
  *     remember that in TrueType, everything that is to the right of
  *     the drawing direction of a contour must be filled.
  *
  *   FT_ORIENTATION_FILL_LEFT ::
  *     This is identical to @FT_ORIENTATION_POSTSCRIPT, but is used to
  *     remember that in Postscript, everything that is to the left of
  *     the drawing direction of a contour must be filled.
  *
  *   FT_ORIENTATION_NONE ::
  *     The orientation cannot be determined.  That is, different parts of
  *     the glyph have different orientation.
  *
  *)
  FT_Orientation = (
    FT_ORIENTATION_TRUETYPE   = 0,
    FT_ORIENTATION_POSTSCRIPT = 1,
    FT_ORIENTATION_FILL_RIGHT = FT_ORIENTATION_TRUETYPE,
    FT_ORIENTATION_FILL_LEFT  = FT_ORIENTATION_POSTSCRIPT,
    FT_ORIENTATION_NONE
  );


  (**************************************************************************
   *
   *  @enum:
   *     FT_TrueTypeEngineType
   *
   *  @description:
   *     A list of values describing which kind of TrueType bytecode
   *     engine is implemented in a given FT_Library instance.  It is used
   *     by the @FT_Get_TrueType_Engine_Type function.
   *
   *  @values:
   *     FT_TRUETYPE_ENGINE_TYPE_NONE ::
   *       The library doesn't implement any kind of bytecode interpreter.
   *
   *     FT_TRUETYPE_ENGINE_TYPE_UNPATENTED ::
   *       The library implements a bytecode interpreter that doesn't
   *       support the patented operations of the TrueType virtual machine.
   *
   *       Its main use is to load certain Asian fonts which position and
   *       scale glyph components with bytecode instructions.  It produces
   *       bad output for most other fonts.
   *
   *    FT_TRUETYPE_ENGINE_TYPE_PATENTED ::
   *       The library implements a bytecode interpreter that covers
   *       the full instruction set of the TrueType virtual machine.
   *       See the file `docs/PATENTS' for legal aspects.
   *
   *  @since:
   *       2.2
   *
   *)
  FT_TrueTypeEngineType = (
    FT_TRUETYPE_ENGINE_TYPE_NONE = 0,
    FT_TRUETYPE_ENGINE_TYPE_UNPATENTED,
    FT_TRUETYPE_ENGINE_TYPE_PATENTED
  );



const
  (**************************************************************************
   *
   * @enum:
   *   FT_LOAD_TARGET_XXX
   *
   * @description:
   *   A list of values that are used to select a specific hinting algorithm
   *   to use by the hinter.  You should OR one of these values to your
   *   `load_flags' when calling @FT_Load_Glyph.
   *
   *   Note that font's native hinters may ignore the hinting algorithm you
   *   have specified (e.g., the TrueType bytecode interpreter).  You can set
   *   @FT_LOAD_FORCE_AUTOHINT to ensure that the auto-hinter is used.
   *
   *   Also note that @FT_LOAD_TARGET_LIGHT is an exception, in that it
   *   always implies @FT_LOAD_FORCE_AUTOHINT.
   *
   * @values:
   *   FT_LOAD_TARGET_NORMAL ::
   *     This corresponds to the default hinting algorithm, optimized for
   *     standard gray-level rendering.  For monochrome output, use
   *     @FT_LOAD_TARGET_MONO instead.
   *
   *   FT_LOAD_TARGET_LIGHT ::
   *     A lighter hinting algorithm for non-monochrome modes.  Many
   *     generated glyphs are more fuzzy but better resemble its original
   *     shape.  A bit like rendering on Mac OS X.
   *
   *     As a special exception, this target implies @FT_LOAD_FORCE_AUTOHINT.
   *
   *   FT_LOAD_TARGET_MONO ::
   *     Strong hinting algorithm that should only be used for monochrome
   *     output.  The result is probably unpleasant if the glyph is rendered
   *     in non-monochrome modes.
   *
   *   FT_LOAD_TARGET_LCD ::
   *     A variant of @FT_LOAD_TARGET_NORMAL optimized for horizontally
   *     decimated LCD displays.
   *
   *   FT_LOAD_TARGET_LCD_V ::
   *     A variant of @FT_LOAD_TARGET_NORMAL optimized for vertically
   *     decimated LCD displays.
   *
   * @note:
   *   You should use only _one_ of the FT_LOAD_TARGET_XXX values in your
   *   `load_flags'.  They can't be ORed.
   *
   *   If @FT_LOAD_RENDER is also set, the glyph is rendered in the
   *   corresponding mode (i.e., the mode which matches the used algorithm
   *   best) unless @FT_LOAD_MONOCHROME is set.
   *
   *   You can use a hinting algorithm that doesn't correspond to the same
   *   rendering mode.  As an example, it is possible to use the `light'
   *   hinting algorithm and have the results rendered in horizontal LCD
   *   pixel mode, with code like
   *
   *     {
   *       FT_Load_Glyph( face, glyph_index,
   *                      load_flags | FT_LOAD_TARGET_LIGHT );
   *
   *       FT_Render_Glyph( face->glyph, FT_RENDER_MODE_LCD );
   *     }
   *)
  FT_LOAD_TARGET_NORMAL     = FT_UInt(FT_RENDER_MODE_NORMAL) and 15 shl 16;
  FT_LOAD_TARGET_LIGHT      = FT_UInt(FT_RENDER_MODE_LIGHT)  and 15 shl 16;
  FT_LOAD_TARGET_MONO       = FT_UInt(FT_RENDER_MODE_MONO)   and 15 shl 16;
  FT_LOAD_TARGET_LCD        = FT_UInt(FT_RENDER_MODE_LCD)    and 15 shl 16;
  FT_LOAD_TARGET_LCD_V      = FT_UInt(FT_RENDER_MODE_LCD_V)  and 15 shl 16;

  
// types and structures
type
  FT_Vector_ptr = ^FT_Vector;
  FT_Vector = record
    x: FT_Pos;
    y: FT_Pos;
  end;


  FT_Matrix_ptr = ^FT_Matrix;
  FT_Matrix = record
    xx, xy: FT_Fixed;
    yx, yy: FT_Fixed;
  end;


  FT_BBox_ptr = ^FT_BBox;
  FT_BBox = record       
    xMin, yMin: FT_Pos;
    xMax, yMax: FT_Pos;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (*                  M E M O R Y   M A N A G E M E N T                    *)
  (*                                                                       *)
  (*************************************************************************)


  (*************************************************************************
   *
   * @type:
   *   FT_Memory
   *
   * @description:
   *   A handle to a given memory manager object, defined with an
   *   @FT_MemoryRec structure.
   *
   *)
  FT_Memory = ^FT_MemoryRec;


  (*************************************************************************
   *
   * @functype:
   *   FT_Alloc_Func
   *
   * @description:
   *   A function used to allocate `size' bytes from `memory'.
   *
   * @input:
   *   memory ::
   *     A handle to the source memory manager.
   *
   *   size ::
   *     The size in bytes to allocate.
   *
   * @return:
   *   Address of new memory block.  0 in case of failure.
   *
   *)
  FT_Alloc_Func = function(
    memory: FT_Memory;
    size: Integer): Pointer; cdecl;


  (*************************************************************************
   *
   * @functype:
   *   FT_Free_Func
   *
   * @description:
   *   A function used to release a given block of memory.
   *
   * @input:
   *   memory ::
   *     A handle to the source memory manager.
   *
   *   block ::
   *     The address of the target memory block.
   *
   *)
  FT_Free_Func = procedure(
      memory: FT_Memory;
      block: pointer); cdecl;


  (*************************************************************************
   *
   * @functype:
   *   FT_Realloc_Func
   *
   * @description:
   *   A function used to re-allocate a given block of memory.
   *
   * @input:
   *   memory ::
   *     A handle to the source memory manager.
   *
   *   cur_size ::
   *     The block's current size in bytes.
   *
   *   new_size ::
   *     The block's requested new size.
   *
   *   block ::
   *     The block's current address.
   *
   * @return:
   *   New block address.  0 in case of memory shortage.
   *
   * @note:
   *   In case of error, the old block must still be available.
   *
   *)
  FT_Realloc_Func = function(
      memory: FT_Memory;
      cur_size: Integer;
      new_size: Integer;
      block: Pointer): Pointer; cdecl;


  (*************************************************************************
   *
   * @struct:
   *   FT_MemoryRec
   *
   * @description:
   *   A structure used to describe a given memory manager to FreeType 2.
   *
   * @fields:
   *   user ::
   *     A generic typeless pointer for user data.
   *
   *   alloc ::
   *     A pointer type to an allocation function.
   *
   *   free ::
   *     A pointer type to an memory freeing function.
   *
   *   realloc ::
   *     A pointer type to a reallocation function.
   *
   *)
  FT_MemoryRec = record
    user: Pointer;
    alloc: FT_Alloc_Func;
    free: FT_Free_Func;
    realloc: FT_Realloc_Func;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (*                       I / O   M A N A G E M E N T                     *)
  (*                                                                       *)
  (*************************************************************************)


  (*************************************************************************
   *
   * @type:
   *   FT_Stream
   *
   * @description:
   *   A handle to an input stream.
   *
   *)
  FT_Stream = ^FT_StreamRec;


  (*************************************************************************
   *
   * @struct:
   *   FT_StreamDesc
   *
   * @description:
   *   A union type used to store either a long or a pointer.  This is used
   *   to store a file descriptor or a `FILE*' in an input stream.
   *
   *)
  FT_StreamDesc = record
    value: Integer;
    pointer: Pointer;
  end;


  (*************************************************************************
   *
   * @functype:
   *   FT_Stream_IoFunc
   *
   * @description:
   *   A function used to seek and read data from a given input stream.
   *
   * @input:
   *   stream ::
   *     A handle to the source stream.
   *
   *   offset ::
   *     The offset of read in stream (always from start).
   *
   *   buffer ::
   *     The address of the read buffer.
   *
   *   count ::
   *     The number of bytes to read from the stream.
   *
   * @return:
   *   The number of bytes effectively read by the stream.
   *
   * @note:
   *   This function might be called to perform a seek or skip operation
   *   with a `count' of 0.
   *
   *)
  FT_Stream_IoFunc = function(
      stream: FT_Stream;
      offset: Cardinal;
      buffer: PByte;
      count: Cardinal): Cardinal; cdecl;


  (*************************************************************************
   *
   * @functype:
   *   FT_Stream_CloseFunc
   *
   * @description:
   *   A function used to close a given input stream.
   *
   * @input:
   *  stream ::
   *     A handle to the target stream.
   *
   *)
  FT_Stream_CloseFunc = procedure(
      stream: FT_Stream); cdecl;


  (*************************************************************************
   *
   * @struct:
   *   FT_StreamRec
   *
   * @description:
   *   A structure used to describe an input stream.
   *
   * @input:
   *   base ::
   *     For memory-based streams, this is the address of the first stream
   *     byte in memory.  This field should always be set to NULL for
   *     disk-based streams.
   *
   *   size ::
   *     The stream size in bytes.
   *
   *   pos ::
   *     The current position within the stream.
   *
   *   descriptor ::
   *     This field is a union that can hold an integer or a pointer.  It is
   *     used by stream implementations to store file descriptors or `FILE*'
   *     pointers.
   *
   *   pathname ::
   *     This field is completely ignored by FreeType.  However, it is often
   *     useful during debugging to use it to store the stream's filename
   *     (where available).
   *
   *   read ::
   *     The stream's input function.
   *
   *   close ::
   *     The stream;s close function.
   *
   *   memory ::
   *     The memory manager to use to preload frames.  This is set
   *     internally by FreeType and shouldn't be touched by stream
   *     implementations.
   *
   *   cursor ::
   *     This field is set and used internally by FreeType when parsing
   *     frames.
   *
   *   limit ::
   *     This field is set and used internally by FreeType when parsing
   *     frames.
   *
   *)
  FT_StreamRec = record
    base: PByte;
    size: Cardinal;
    pos: Cardinal;

    descriptor: FT_StreamDesc;
    pathname: FT_StreamDesc;
    read: FT_Stream_IoFunc;
    close: FT_Stream_CloseFunc;

    memory: FT_Memory;
    cursor: PByte;
    limit: PByte;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Bitmap                                                          *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A structure used to describe a bitmap or pixmap to the raster.     *)
  (*    Note that we now manage pixmaps of various depths through the      *)
  (*    `pixel_mode' field.                                                *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    rows         :: The number of bitmap rows.                         *)
  (*                                                                       *)
  (*    width        :: The number of pixels in bitmap row.                *)
  (*                                                                       *)
  (*    pitch        :: The pitch's absolute value is the number of bytes  *)
  (*                    taken by one bitmap row, including padding.        *)
  (*                    However, the pitch is positive when the bitmap has *)
  (*                    a `down' flow, and negative when it has an `up'    *)
  (*                    flow.  In all cases, the pitch is an offset to add *)
  (*                    to a bitmap pointer in order to go down one row.   *)
  (*                                                                       *)
  (*    buffer       :: A typeless pointer to the bitmap buffer.  This     *)
  (*                    value should be aligned on 32-bit boundaries in    *)
  (*                    most cases.                                        *)
  (*                                                                       *)
  (*    num_grays    :: This field is only used with                       *)
  (*                    @FT_PIXEL_MODE_GRAY; it gives the number of gray   *)
  (*                    levels used in the bitmap.                         *)
  (*                                                                       *)
  (*    pixel_mode   :: The pixel mode, i.e., how pixel bits are stored.   *)
  (*                    See @FT_Pixel_Mode for possible values.            *)
  (*                                                                       *)
  (*    palette_mode :: This field is intended for paletted pixel modes;   *)
  (*                    it indicates how the palette is stored.  Not       *)
  (*                    used currently.                                    *)
  (*                                                                       *)
  (*    palette      :: A typeless pointer to the bitmap palette; this     *)
  (*                    field is intended for paletted pixel modes.  Not   *)
  (*                    used currently.                                    *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*   For now, the only pixel modes supported by FreeType are mono and    *)
  (*   grays.  However, drivers might be added in the future to support    *)
  (*   more `colorful' options.                                            *)
  (*                                                                       *)
  FT_Bitmap_ptr = ^FT_Bitmap;
  FT_Bitmap = record
    rows: Integer;
    width: Integer;
    pitch: Integer;
    buffer: pAnsiChar;
    num_grays: Smallint;
    pixel_mode: char;
    palette_mode: char;
    palette: Pointer;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Bitmap_Size                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    This structure models the metrics of a bitmap strike (i.e., a set  *)
  (*    of glyphs for a given point size and resolution) in a bitmap font. *)
  (*    It is used for the `available_sizes' field of @FT_Face.            *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    height :: The vertical distance, in pixels, between two            *)
  (*              consecutive baselines.  It is always positive.           *)
  (*                                                                       *)
  (*    width  :: The average width, in pixels, of all glyphs in the       *)
  (*              strike.                                                  *)
  (*                                                                       *)
  (*    size   :: The nominal size of the strike in 26.6 fractional        *)
  (*              points.  This field is not very useful.                  *)
  (*                                                                       *)
  (*    x_ppem :: The horizontal ppem (nominal width) in 26.6 fractional   *)
  (*              pixels.                                                  *)
  (*                                                                       *)
  (*    y_ppem :: The vertical ppem (nominal height) in 26.6 fractional    *)
  (*              pixels.                                                  *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    Windows FNT:                                                       *)
  (*      The nominal size given in a FNT font is not reliable.  Thus when *)
  (*      the driver finds it incorrect, it sets `size' to some calculated *)
  (*      values and sets `x_ppem' and `y_ppem' to the pixel width and     *)
  (*      height given in the font, respectively.                          *)
  (*                                                                       *)
  (*    TrueType embedded bitmaps:                                         *)
  (*      `size', `width', and `height' values are not contained in the    *)
  (*      bitmap strike itself.  They are computed from the global font    *)
  (*      parameters.                                                      *)
  (*                                                                       *)
  FT_Bitmap_Size_ptr = ^FT_Bitmap_Size;
  FT_Bitmap_Size = record
    height: FT_Short;
    width: FT_Short;

    size: FT_Pos;

    x_ppem: FT_Pos;
    y_ppem: FT_Pos;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Outline                                                         *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    This structure is used to describe an outline to the scan-line     *)
  (*    converter.                                                         *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    n_contours :: The number of contours in the outline.               *)
  (*                                                                       *)
  (*    n_points   :: The number of points in the outline.                 *)
  (*                                                                       *)
  (*    points     :: A pointer to an array of `n_points' @FT_Vector       *)
  (*                  elements, giving the outline's point coordinates.    *)
  (*                                                                       *)
  (*    tags       :: A pointer to an array of `n_points' chars, giving    *)
  (*                  each outline point's type.  If bit 0 is unset, the   *)
  (*                  point is `off' the curve, i.e., a Bézier control     *)
  (*                  point, while it is `on' when set.                    *)
  (*                                                                       *)
  (*                  Bit 1 is meaningful for `off' points only.  If set,  *)
  (*                  it indicates a third-order Bézier arc control point; *)
  (*                  and a second-order control point if unset.           *)
  (*                                                                       *)
  (*    contours   :: An array of `n_contours' shorts, giving the end      *)
  (*                  point of each contour within the outline.  For       *)
  (*                  example, the first contour is defined by the points  *)
  (*                  `0' to `contours[0]', the second one is defined by   *)
  (*                  the points `contours[0]+1' to `contours[1]', etc.    *)
  (*                                                                       *)
  (*    flags      :: A set of bit flags used to characterize the outline  *)
  (*                  and give hints to the scan-converter and hinter on   *)
  (*                  how to convert/grid-fit it.  See @FT_OUTLINE_FLAGS.  *)
  (*                                                                       *)
  FT_Outline_ptr = ^FT_Outline;
  FT_Outline = record
    n_contours: Smallint;         (* number of contours in glyph        *)
    n_points: Smallint;           (* number of points in the glyph      *)

    points: FT_Vector_ptr;        (* the outline's points               *)
    tags: pAnsiChar;                  (* the points flags                   *)
    contours: pSmallInt;          (* the contour end points             *)

    flags: Integer;               (* outline masks                      *)
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Glyph_Metrics                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A structure used to model the metrics of a single glyph.  The      *)
  (*    values are expressed in 26.6 fractional pixel format; if the flag  *)
  (*    @FT_LOAD_NO_SCALE has been used while loading the glyph, values    *)
  (*    are expressed in font units instead.                               *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    width ::                                                           *)
  (*      The glyph's width.                                               *)
  (*                                                                       *)
  (*    height ::                                                          *)
  (*      The glyph's height.                                              *)
  (*                                                                       *)
  (*    horiBearingX ::                                                    *)
  (*      Left side bearing for horizontal layout.                         *)
  (*                                                                       *)
  (*    horiBearingY ::                                                    *)
  (*      Top side bearing for horizontal layout.                          *)
  (*                                                                       *)
  (*    horiAdvance ::                                                     *)
  (*      Advance width for horizontal layout.                             *)
  (*                                                                       *)
  (*    vertBearingX ::                                                    *)
  (*      Left side bearing for vertical layout.                           *)
  (*                                                                       *)
  (*    vertBearingY ::                                                    *)
  (*      Top side bearing for vertical layout.                            *)
  (*                                                                       *)
  (*    vertAdvance ::                                                     *)
  (*      Advance height for vertical layout.                              *)
  (*                                                                       *)
  FT_Glyph_Metrics_ptr = ^FT_Glyph_Metrics;
  FT_Glyph_Metrics = record
    width: FT_Pos;
    height: FT_Pos;

    horiBearingX: FT_Pos;
    horiBearingY: FT_Pos;
    horiAdvance: FT_Pos;

    vertBearingX: FT_Pos;
    vertBearingY: FT_Pos;
    vertAdvance: FT_Pos;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_Generic_Finalizer                                               *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Describes a function used to destroy the `client' data of any      *)
  (*    FreeType object.  See the description of the @FT_Generic type for  *)
  (*    details of usage.                                                  *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    The address of the FreeType object which is under finalization.    *)
  (*    Its client data is accessed through its `generic' field.           *)
  (*                                                                       *)
  // TODO: Attention. There was no calling convention in the header
  FT_Generic_Finalizer = procedure(object_: Pointer); cdecl;               


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Generic                                                         *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Client applications often need to associate their own data to a    *)
  (*    variety of FreeType core objects.  For example, a text layout API  *)
  (*    might want to associate a glyph cache to a given size object.      *)
  (*                                                                       *)
  (*    Most FreeType object contains a `generic' field, of type           *)
  (*    FT_Generic, which usage is left to client applications and font    *)
  (*    servers.                                                           *)
  (*                                                                       *)
  (*    It can be used to store a pointer to client-specific data, as well *)
  (*    as the address of a `finalizer' function, which will be called by  *)
  (*    FreeType when the object is destroyed (for example, the previous   *)
  (*    client example would put the address of the glyph cache destructor *)
  (*    in the `finalizer' field).                                         *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    data      :: A typeless pointer to any client-specified data. This *)
  (*                 field is completely ignored by the FreeType library.  *)
  (*                                                                       *)
  (*    finalizer :: A pointer to a `generic finalizer' function, which    *)
  (*                 will be called when the object is destroyed.  If this *)
  (*                 field is set to NULL, no code will be called.         *)
  (*                                                                       *)
  FT_Generic = record
    data: Pointer;
    finalizer: FT_Generic_Finalizer;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_ListNode                                                        *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*     Many elements and objects in FreeType are listed through an       *)
  (*     @FT_List record (see @FT_ListRec).  As its name suggests, an      *)
  (*     FT_ListNode is a handle to a single list element.                 *)
  (*                                                                       *)
  FT_ListNode = ^FT_ListNodeRec;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_ListNodeRec                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A structure used to hold a single list element.                    *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    prev :: The previous element in the list.  NULL if first.          *)
  (*                                                                       *)
  (*    next :: The next element in the list.  NULL if last.               *)
  (*                                                                       *)
  (*    data :: A typeless pointer to the listed object.                   *)
  (*                                                                       *)
  FT_ListNodeRec = record
    prev: FT_ListNode;
    next: FT_ListNode;
    data: Pointer;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_List                                                            *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to a list record (see @FT_ListRec).                       *)
  (*                                                                       *)
  FT_List = ^FT_ListRec;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_ListRec                                                         *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A structure used to hold a simple doubly-linked list.  These are   *)
  (*    used in many parts of FreeType.                                    *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    head :: The head (first element) of doubly-linked list.            *)
  (*                                                                       *)
  (*    tail :: The tail (last element) of doubly-linked list.             *)
  (*                                                                       *)
  FT_ListRec = record
    head: FT_ListNode;
    tail: FT_ListNode;
  end;


  (*************************************************************************)
  (*************************************************************************)
  (*                                                                       *)
  (*                     O B J E C T   C L A S S E S                       *)
  (*                                                                       *)
  (*************************************************************************)
  (*************************************************************************)

  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Library                                                         *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to a FreeType library instance.  Each `library' is        *)
  (*    completely independent from the others; it is the `root' of a set  *)
  (*    of objects like fonts, faces, sizes, etc.                          *)
  (*                                                                       *)
  (*    It also embeds a memory manager (see @FT_Memory), as well as a     *)
  (*    scan-line converter object (see @FT_Raster).                       *)
  (*                                                                       *)
  (*    For multi-threading applications each thread should have its own   *)
  (*    FT_Library object.                                                 *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    Library objects are normally created by @FT_Init_FreeType, and     *)
  (*    destroyed with @FT_Done_FreeType.                                  *)
  (*                                                                       *)
  FT_Library_ptr = ^FT_Library;
  FT_Library = ^FT_LibraryRec;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Module                                                          *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to a given FreeType module object.  Each module can be a  *)
  (*    font driver, a renderer, or anything else that provides services   *)
  (*    to the formers.                                                    *)
  (*                                                                       *)
  FT_Module = ^FT_ModuleRec;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Driver                                                          *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to a given FreeType font driver object.  Each font driver *)
  (*    is a special module capable of creating faces from font files.     *)
  (*                                                                       *)
  FT_Driver = ^FT_DriverRec;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Renderer                                                        *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to a given FreeType renderer.  A renderer is a special    *)
  (*    module in charge of converting a glyph image to a bitmap, when     *)
  (*    necessary.  Each renderer supports a given glyph image format, and *)
  (*    one or more target surface depths.                                 *)
  (*                                                                       *)
  FT_Renderer = ^FT_RendererRec;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Face                                                            *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to a given typographic face object.  A face object models *)
  (*    a given typeface, in a given style.                                *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    Each face object also owns a single @FT_GlyphSlot object, as well  *)
  (*    as one or more @FT_Size objects.                                   *)
  (*                                                                       *)
  (*    Use @FT_New_Face or @FT_Open_Face to create a new face object from *)
  (*    a given filepathname or a custom input stream.                     *)
  (*                                                                       *)
  (*    Use @FT_Done_Face to destroy it (along with its slot and sizes).   *)
  (*                                                                       *)
  (* <Also>                                                                *)
  (*    The @FT_FaceRec details the publicly accessible fields of a given  *)
  (*    face object.                                                       *)
  (*                                                                       *)
  FT_Face_ptr = ^FT_Face;
  FT_Face = ^FT_FaceRec;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Size                                                            *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to an object used to model a face scaled to a given       *)
  (*    character size.                                                    *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    Each @FT_Face has an _active_ @FT_Size object that is used by      *)
  (*    functions like @FT_Load_Glyph to determine the scaling             *)
  (*    transformation which is used to load and hint glyphs and metrics.  *)
  (*                                                                       *)
  (*    You can use @FT_Set_Char_Size, @FT_Set_Pixel_Sizes,                *)
  (*    @FT_Request_Size or even @FT_Select_Size to change the content     *)
  (*    (i.e., the scaling values) of the active @FT_Size.                 *)
  (*                                                                       *)
  (*    You can use @FT_New_Size to create additional size objects for a   *)
  (*    given @FT_Face, but they won't be used by other functions until    *)
  (*    you activate it through @FT_Activate_Size.  Only one size can be   *)
  (*    activated at any given time per face.                              *)
  (*                                                                       *)
  (* <Also>                                                                *)
  (*    The @FT_SizeRec structure details the publicly accessible fields   *)
  (*    of a given size object.                                            *)
  (*                                                                       *)
  FT_Size_ptr = ^FT_Size;
  FT_Size = ^FT_SizeRec;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_GlyphSlot                                                       *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to a given `glyph slot'.  A slot is a container where it  *)
  (*    is possible to load any one of the glyphs contained in its parent  *)
  (*    face.                                                              *)
  (*                                                                       *)
  (*    In other words, each time you call @FT_Load_Glyph or               *)
  (*    @FT_Load_Char, the slot's content is erased by the new glyph data, *)
  (*    i.e., the glyph's metrics, its image (bitmap or outline), and      *)
  (*    other control information.                                         *)
  (*                                                                       *)
  (* <Also>                                                                *)
  (*    @FT_GlyphSlotRec details the publicly accessible glyph fields.     *)
  (*                                                                       *)
  FT_GlyphSlot = ^FT_GlyphSlotRec;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_CharMap                                                         *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to a given character map.  A charmap is used to translate *)
  (*    character codes in a given encoding into glyph indexes for its     *)
  (*    parent's face.  Some font formats may provide several charmaps per *)
  (*    font.                                                              *)
  (*                                                                       *)
  (*    Each face object owns zero or more charmaps, but only one of them  *)
  (*    can be `active' and used by @FT_Get_Char_Index or @FT_Load_Char.   *)
  (*                                                                       *)
  (*    The list of available charmaps in a face is available through the  *)
  (*    `face->num_charmaps' and `face->charmaps' fields of @FT_FaceRec.   *)
  (*                                                                       *)
  (*    The currently active charmap is available as `face->charmap'.      *)
  (*    You should call @FT_Set_Charmap to change it.                      *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    When a new face is created (either through @FT_New_Face or         *)
  (*    @FT_Open_Face), the library looks for a Unicode charmap within     *)
  (*    the list and automatically activates it.                           *)
  (*                                                                       *)
  (* <Also>                                                                *)
  (*    The @FT_CharMapRec details the publicly accessible fields of a     *)
  (*    given character map.                                               *)
  (*                                                                       *)
  FT_CharMap_ptr = ^FT_CharMap;
  FT_CharMap = ^FT_CharMapRec;




  FT_DebugHook_Func = procedure(
      arg: Pointer); cdecl;

  FT_Bitmap_LcdFilterFunc = procedure(
      bitmap: FT_Bitmap_ptr;
      render_mode: FT_Render_Mode;
      library_: FT_Library); cdecl;

  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_LibraryRec                                                      *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    The FreeType library class.  This is the root of all FreeType      *)
  (*    data.  Use FT_New_Library() to create a library object, and        *)
  (*    FT_Done_Library() to discard it and all child objects.             *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    memory           :: The library's memory object.  Manages memory   *)
  (*                        allocation.                                    *)
  (*                                                                       *)
  (*    generic          :: Client data variable.  Used to extend the      *)
  (*                        Library class by higher levels and clients.    *)
  (*                                                                       *)
  (*    version_major    :: The major version number of the library.       *)
  (*                                                                       *)
  (*    version_minor    :: The minor version number of the library.       *)
  (*                                                                       *)
  (*    version_patch    :: The current patch level of the library.        *)
  (*                                                                       *)
  (*    num_modules      :: The number of modules currently registered     *)
  (*                        within this library.  This is set to 0 for new *)
  (*                        libraries.  New modules are added through the  *)
  (*                        FT_Add_Module() API function.                  *)
  (*                                                                       *)
  (*    modules          :: A table used to store handles to the currently *)
  (*                        registered modules. Note that each font driver *)
  (*                        contains a list of its opened faces.           *)
  (*                                                                       *)
  (*    renderers        :: The list of renderers currently registered     *)
  (*                        within the library.                            *)
  (*                                                                       *)
  (*    cur_renderer     :: The current outline renderer.  This is a       *)
  (*                        shortcut used to avoid parsing the list on     *)
  (*                        each call to FT_Outline_Render().  It is a     *)
  (*                        handle to the current renderer for the         *)
  (*                        FT_GLYPH_FORMAT_OUTLINE format.                *)
  (*                                                                       *)
  (*    auto_hinter      :: XXX                                            *)
  (*                                                                       *)
  (*    raster_pool      :: The raster object's render pool.  This can     *)
  (*                        ideally be changed dynamically at run-time.    *)
  (*                                                                       *)
  (*    raster_pool_size :: The size of the render pool in bytes.          *)
  (*                                                                       *)
  (*    debug_hooks      :: XXX                                            *)
  (*                                                                       *)
  FT_LibraryRec = record
    memory: FT_Memory;                            (* library's memory manager *)
  
    generic: FT_Generic;

    version_major: FT_Int;
    version_minor: FT_Int;
    version_patch: FT_Int;

    num_modules: FT_UInt;
    modules: array [0..FT_MAX_MODULES-1] of FT_Module;  (* module objects  *)

    renderers: FT_ListRec;                        (* list of renderers        *)
    cur_renderer: FT_Renderer;                    (* current outline renderer *)
    auto_hinter: FT_Module;

    raster_pool: FT_Byte_ptr;                     (* scan-line conversion *)
                                                  (* render pool          *)
    raster_pool_size: FT_ULong;                   (* size of render pool in bytes *)

    debug_hooks: array[0..3] of FT_DebugHook_Func;

    // #ifdef FT_CONFIG_OPTION_SUBPIXEL_RENDERING
    lcd_filter: FT_LcdFilter;
    lcd_extra: FT_Int;                            (* number of extra pixels *)
    lcd_weights: array[0..6] of FT_Byte;          (* filter weights, if any *)
    lcd_filter_func: Pointer; //TODO: FT_Bitmap_LcdFilterFunc;     (* filtering callback     *)
    // #endif
  end;



  FT_Module_Interface = FT_Pointer;

  FT_Module_Constructor = function(
      module: FT_Module): FT_Error; cdecl;

  FT_Module_Destructor = procedure(
      module: FT_Module); cdecl;

  FT_Module_Requester = function(
      module: FT_Module;
      name: pAnsiChar): FT_Module_Interface; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Module_Class                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    The module class descriptor.                                       *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    module_flags    :: Bit flags describing the module.                *)
  (*                                                                       *)
  (*    module_size     :: The size of one module object/instance in       *)
  (*                       bytes.                                          *)
  (*                                                                       *)
  (*    module_name     :: The name of the module.                         *)
  (*                                                                       *)
  (*    module_version  :: The version, as a 16.16 fixed number            *)
  (*                       (major.minor).                                  *)
  (*                                                                       *)
  (*    module_requires :: The version of FreeType this module requires,   *)
  (*                       as a 16.16 fixed number (major.minor).  Starts  *)
  (*                       at version 2.0, i.e., 0x20000.                  *)
  (*                                                                       *)
  (*    module_init     :: A function used to initialize (not create) a    *)
  (*                       new module object.                              *)
  (*                                                                       *)
  (*    module_done     :: A function used to finalize (not destroy) a     *)
  (*                       given module object                             *)
  (*                                                                       *)
  (*    get_interface   :: Queries a given module for a specific           *)
  (*                       interface by name.                              *)
  (*                                                                       *)
  FT_Module_Class_ptr = ^FT_Module_Class;
  FT_Module_Class = record
    module_flags: FT_ULong;
    module_size: FT_Long;
    module_name: FT_String_ptr;       
    module_version: FT_Fixed;               
    module_requires: FT_Fixed;

    module_interface: Pointer;

    module_init: FT_Module_Constructor;
    module_done: FT_Module_Destructor;
    get_interface: FT_Module_Requester;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Module                                                          *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to a given FreeType module object.  Each module can be a  *)
  (*    font driver, a renderer, or anything else that provides services   *)
  (*    to the formers.                                                    *)
  (*                                                                       *)
  FT_ModuleRec = record
    clazz: FT_Module_Class;
    library_: FT_Library;
    memory: FT_Memory;
    generic: FT_Generic;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Driver                                                          *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to a given FreeType font driver object.  Each font driver *)
  (*    is a special module capable of creating faces from font files.     *)
  (*                                                                       *)
  FT_DriverRec = record
    root: FT_ModuleRec;
    clazz: Pointer; // TODO: FT_Driver_Class; ??

    faces_list: FT_ListRec;
    extensions: Pointer;

    glyph_loader: Pointer; // TODO: FT_GlyphLoader; ??
  end;



  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Span                                                            *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A structure used to model a single span of gray (or black) pixels  *)
  (*    when rendering a monochrome or anti-aliased bitmap.                *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    x        :: The span's horizontal start position.                  *)
  (*                                                                       *)
  (*    len      :: The span's length in pixels.                           *)
  (*                                                                       *)
  (*    coverage :: The span color/coverage, ranging from 0 (background)   *)
  (*                to 255 (foreground).  Only used for anti-aliased       *)
  (*                rendering.                                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    This structure is used by the span drawing callback type named     *)
  (*    @FT_SpanFunc which takes the y-coordinate of the span as a         *)
  (*    a parameter.                                                       *)
  (*                                                                       *)
  (*    The coverage value is always between 0 and 255.                    *)
  (*                                                                       *)
  FT_Span_ptr = ^FT_Span;
  FT_Span = record
    X: Smallint;
    len: word;
    coverage: byte;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_SpanFunc                                                        *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A function used as a call-back by the anti-aliased renderer in     *)
  (*    order to let client applications draw themselves the gray pixel    *)
  (*    spans on each scan line.                                           *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    y     :: The scanline's y-coordinate.                              *)
  (*                                                                       *)
  (*    count :: The number of spans to draw on this scanline.             *)
  (*                                                                       *)
  (*    spans :: A table of `count' spans to draw on the scanline.         *)
  (*                                                                       *)
  (*    user  :: User-supplied data that is passed to the callback.        *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    This callback allows client applications to directly render the    *)
  (*    gray spans of the anti-aliased bitmap to any kind of surfaces.     *)
  (*                                                                       *)
  (*    This can be used to write anti-aliased outlines directly to a      *)
  (*    given background bitmap, and even perform translucency.            *)
  (*                                                                       *)
  (*    Note that the `count' field cannot be greater than a fixed value   *)
  (*    defined by the `FT_MAX_GRAY_SPANS' configuration macro in          *)
  (*    `ftoption.h'.  By default, this value is set to 32, which means    *)
  (*    that if there are more than 32 spans on a given scanline, the      *)
  (*    callback is called several times with the same `y' parameter in    *)
  (*    order to draw all callbacks.                                       *)
  (*                                                                       *)
  (*    Otherwise, the callback is only called once per scan-line, and     *)
  (*    only for those scanlines that do have `gray' pixels on them.       *)
  (*                                                                       *)
  FT_SpanFunc = procedure(
      Y: Integer;
      count: Integer;
      spans: FT_Span_ptr;
      user: Pointer); cdecl;

  FT_Raster_Span_Func = FT_SpanFunc;


  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_Raster_BitTest_Func                                             *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    THIS TYPE IS DEPRECATED.  DO NOT USE IT.                           *)
  (*                                                                       *)
  (*    A function used as a call-back by the monochrome scan-converter    *)
  (*    to test whether a given target pixel is already set to the drawing *)
  (*    `color'.  These tests are crucial to implement drop-out control    *)
  (*    per-se the TrueType spec.                                          *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    y     :: The pixel's y-coordinate.                                 *)
  (*                                                                       *)
  (*    x     :: The pixel's x-coordinate.                                 *)
  (*                                                                       *)
  (*    user  :: User-supplied data that is passed to the callback.        *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*   1 if the pixel is `set', 0 otherwise.                               *)
  (*                                                                       *)
  FT_Raster_BitTest_Func = function(
      y: Integer;
      x: Integer;
      user: Pointer): Integer; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_Raster_BitSet_Func                                              *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    THIS TYPE IS DEPRECATED.  DO NOT USE IT.                           *)
  (*                                                                       *)
  (*    A function used as a call-back by the monochrome scan-converter    *)
  (*    to set an individual target pixel.  This is crucial to implement   *)
  (*    drop-out control according to the TrueType specification.          *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    y     :: The pixel's y-coordinate.                                 *)
  (*                                                                       *)
  (*    x     :: The pixel's x-coordinate.                                 *)
  (*                                                                       *)
  (*    user  :: User-supplied data that is passed to the callback.        *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    1 if the pixel is `set', 0 otherwise.                              *)
  (*                                                                       *)
  FT_Raster_BitSet_Func = procedure(
      y: Integer;
      x: Integer;
      user: Pointer); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Raster_Params                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A structure to hold the arguments used by a raster's render        *)
  (*    function.                                                          *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    target      :: The target bitmap.                                  *)
  (*                                                                       *)
  (*    source      :: A pointer to the source glyph image (e.g., an       *)
  (*                   @FT_Outline).                                       *)
  (*                                                                       *)
  (*    flags       :: The rendering flags.                                *)
  (*                                                                       *)
  (*    gray_spans  :: The gray span drawing callback.                     *)
  (*                                                                       *)
  (*    black_spans :: The black span drawing callback.                    *)
  (*                                                                       *)
  (*    bit_test    :: The bit test callback.  UNIMPLEMENTED!              *)
  (*                                                                       *)
  (*    bit_set     :: The bit set callback.  UNIMPLEMENTED!               *)
  (*                                                                       *)
  (*    user        :: User-supplied data that is passed to each drawing   *)
  (*                   callback.                                           *)
  (*                                                                       *)
  (*    clip_box    :: An optional clipping box.  It is only used in       *)
  (*                   direct rendering mode.  Note that coordinates here  *)
  (*                   should be expressed in _integer_ pixels (and not in *)
  (*                   26.6 fixed-point units).                            *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    An anti-aliased glyph bitmap is drawn if the @FT_RASTER_FLAG_AA    *)
  (*    bit flag is set in the `flags' field, otherwise a monochrome       *)
  (*    bitmap is generated.                                               *)
  (*                                                                       *)
  (*    If the @FT_RASTER_FLAG_DIRECT bit flag is set in `flags', the      *)
  (*    raster will call the `gray_spans' callback to draw gray pixel      *)
  (*    spans, in the case of an aa glyph bitmap, it will call             *)
  (*    `black_spans', and `bit_test' and `bit_set' in the case of a       *)
  (*    monochrome bitmap.  This allows direct composition over a          *)
  (*    pre-existing bitmap through user-provided callbacks to perform the *)
  (*    span drawing/composition.                                          *)
  (*                                                                       *)
  (*    Note that the `bit_test' and `bit_set' callbacks are required when *)
  (*    rendering a monochrome bitmap, as they are crucial to implement    *)
  (*    correct drop-out control as defined in the TrueType specification. *)
  (*                                                                       *)
  FT_Raster_Params_ptr = ^FT_Raster_Params;
  FT_Raster_Params = record
    target: FT_Bitmap_ptr;
    source: Pointer;
    flags: Integer;
    gray_spans: FT_SpanFunc;
    black_spans: FT_SpanFunc;
    bit_test: FT_Raster_BitTest_Func;     (* doesn't work! *)
    bit_set: FT_Raster_BitSet_Func;       (* doesn't work! *)
    user: Pointer;
    clip_box: FT_BBox;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Raster                                                          *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle (pointer) to a raster object.  Each object can be used    *)
  (*    independently to convert an outline into a bitmap or pixmap.       *)
  (*                                                                       *)
//  typedef struct FT_RasterRec_*  FT_Raster;
  FT_Raster_ptr = ^FT_Raster;
  FT_Raster = Pointer;  // FT_RasterRec is unknown 


  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_Raster_NewFunc                                                  *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A function used to create a new raster object.                     *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    memory :: A handle to the memory allocator.                        *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    raster :: A handle to the new raster object.                       *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    Error code.  0 means success.                                      *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The `memory' parameter is a typeless pointer in order to avoid     *)
  (*    un-wanted dependencies on the rest of the FreeType code.  In       *)
  (*    practice, it is an @FT_Memory object, i.e., a handle to the        *)
  (*    standard FreeType memory allocator.  However, this field can be    *)
  (*    completely ignored by a given raster implementation.               *)
  (*                                                                       *)
  FT_Raster_NewFunc = function (
      memory: Pointer;
      raster: FT_Raster_ptr): Integer; cdecl;

  FT_Raster_New_Func = FT_Raster_NewFunc;

  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_Raster_DoneFunc                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A function used to destroy a given raster object.                  *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    raster :: A handle to the raster object.                           *)
  (*                                                                       *)
  FT_Raster_DoneFunc = procedure (
      raster: FT_Raster); cdecl;

  FT_Raster_Done_Func = FT_Raster_DoneFunc;

  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_Raster_ResetFunc                                                *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    FreeType provides an area of memory called the `render pool',      *)
  (*    available to all registered rasters.  This pool can be freely used *)
  (*    during a given scan-conversion but is shared by all rasters.  Its  *)
  (*    content is thus transient.                                         *)
  (*                                                                       *)
  (*    This function is called each time the render pool changes, or just *)
  (*    after a new raster object is created.                              *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    raster    :: A handle to the new raster object.                    *)
  (*                                                                       *)
  (*    pool_base :: The address in memory of the render pool.             *)
  (*                                                                       *)
  (*    pool_size :: The size in bytes of the render pool.                 *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    Rasters can ignore the render pool and rely on dynamic memory      *)
  (*    allocation if they want to (a handle to the memory allocator is    *)
  (*    passed to the raster constructor).  However, this is not           *)
  (*    recommended for efficiency purposes.                               *)
  (*                                                                       *)
  FT_Raster_ResetFunc = procedure(
      raster: FT_Raster;
      pool_base: PByte;
      pool_size: Cardinal); cdecl;

  FT_Raster_Reset_Func = FT_Raster_ResetFunc;

  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_Raster_SetModeFunc                                              *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    This function is a generic facility to change modes or attributes  *)
  (*    in a given raster.  This can be used for debugging purposes, or    *)
  (*    simply to allow implementation-specific `features' in a given      *)
  (*    raster module.                                                     *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    raster :: A handle to the new raster object.                       *)
  (*                                                                       *)
  (*    mode   :: A 4-byte tag used to name the mode or property.          *)
  (*                                                                       *)
  (*    args   :: A pointer to the new mode/property to use.               *)
  (*                                                                       *)
  FT_Raster_SetModeFunc = function(
      raster: FT_Raster;
      mode: Cardinal;
      args: Pointer): Integer; cdecl;

  FT_Raster_Set_Mode_Func = FT_Raster_SetModeFunc;

  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_Raster_RenderFunc                                               *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*   Invokes a given raster to scan-convert a given glyph image into a   *)
  (*   target bitmap.                                                      *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    raster :: A handle to the raster object.                           *)
  (*                                                                       *)
  (*    params :: A pointer to an @FT_Raster_Params structure used to      *)
  (*              store the rendering parameters.                          *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    Error code.  0 means success.                                      *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The exact format of the source image depends on the raster's glyph *)
  (*    format defined in its @FT_Raster_Funcs structure.  It can be an    *)
  (*    @FT_Outline or anything else in order to support a large array of  *)
  (*    glyph formats.                                                     *)
  (*                                                                       *)
  (*    Note also that the render function can fail and return a           *)
  (*    `FT_Err_Unimplemented_Feature' error code if the raster used does  *)
  (*    not support direct composition.                                    *)
  (*                                                                       *)
  (*    XXX: For now, the standard raster doesn't support direct           *)
  (*         composition but this should change for the final release (see *)
  (*         the files `demos/src/ftgrays.c' and `demos/src/ftgrays2.c'    *)
  (*         for examples of distinct implementations which support direct *)
  (*         composition).                                                 *)
  (*                                                                       *)
  FT_Raster_RenderFunc = function(
      raster: FT_Raster;
      params: FT_Raster_Params_ptr): Integer; cdecl;

  FT_Raster_Render_Func = FT_Raster_RenderFunc;

  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Raster_Funcs                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*   A structure used to describe a given raster class to the library.   *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    glyph_format  :: The supported glyph format for this raster.       *)
  (*                                                                       *)
  (*    raster_new    :: The raster constructor.                           *)
  (*                                                                       *)
  (*    raster_reset  :: Used to reset the render pool within the raster.  *)
  (*                                                                       *)
  (*    raster_render :: A function to render a glyph into a given bitmap. *)
  (*                                                                       *)
  (*    raster_done   :: The raster destructor.                            *)
  (*                                                                       *)
  FT_Raster_Funcs_ptr = ^FT_Raster_Funcs;
  FT_Raster_Funcs = record
    glyph_format: FT_Glyph_Format;
    raster_new: FT_Raster_NewFunc;
    raster_reset: FT_Raster_ResetFunc;
    raster_set_mode: FT_Raster_SetModeFunc;
    raster_render: FT_Raster_RenderFunc;
    raster_done: FT_Raster_DoneFunc;
  end;


  FT_Renderer_RenderFunc = function(
      renderer: FT_Renderer;
      slot: FT_GlyphSlot;
      mode: FT_UInt;
      origin: FT_Vector_ptr): FT_Error; cdecl;

  FT_Renderer_TransformFunc = function(
      renderer: FT_Renderer;
      slot: FT_GlyphSlot;
      matrix: FT_Matrix_ptr;
      delta: FT_Vector_ptr): FT_Error; cdecl;

  FT_Renderer_GetCBoxFunc = procedure(
      renderer: FT_Renderer;
      slot: FT_GlyphSlot;
      cbox: FT_BBox_ptr); cdecl;

  FT_Renderer_SetModeFunc = function(
      renderer: FT_Renderer; 
      mode_tag: FT_ULong;
      mode_ptr: FT_Pointer): FT_Error; cdecl;

      
  (* deprecated identifiers *)
  FTRenderer_render = FT_Renderer_RenderFunc;
  FTRenderer_transform = FT_Renderer_TransformFunc;
  FTRenderer_getCBox = FT_Renderer_GetCBoxFunc;
  FTRenderer_setMode = FT_Renderer_SetModeFunc;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Renderer_Class                                                  *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    The renderer module class descriptor.                              *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    root         :: The root @FT_Module_Class fields.                  *)
  (*                                                                       *)
  (*    glyph_format :: The glyph image format this renderer handles.      *)
  (*                                                                       *)
  (*    render_glyph :: A method used to render the image that is in a     *)
  (*                    given glyph slot into a bitmap.                    *)
  (*                                                                       *)
  (*    set_mode     :: A method used to pass additional parameters.       *)
  (*                                                                       *)
  (*    raster_class :: For @FT_GLYPH_FORMAT_OUTLINE renderers only.  This *)
  (*                    is a pointer to its raster's class.                *)
  (*                                                                       *)
  (*    raster       :: For @FT_GLYPH_FORMAT_OUTLINE renderers only.  This *)
  (*                    is a pointer to the corresponding raster object,   *)
  (*                    if any.                                            *)
  (*                                                                       *)
  FT_Renderer_Class = record
    root: FT_Module_Class;

    glyph_format: FT_Glyph_Format;

    render_glyph: FT_Renderer_RenderFunc;
    transform_glyph: FT_Renderer_TransformFunc;
    get_glyph_cbox: FT_Renderer_GetCBoxFunc;
    set_mode: FT_Renderer_SetModeFunc;   

    raster_class: FT_Raster_Funcs_ptr;       
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Glyph                                                           *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Handle to an object used to model generic glyph images.  It is a   *)
  (*    pointer to the @FT_GlyphRec structure and can contain a glyph      *)
  (*    bitmap or pointer.                                                 *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    Glyph objects are not owned by the library.  You must thus release *)
  (*    them manually (through @FT_Done_Glyph) _before_ calling            *)
  (*    @FT_Done_FreeType.                                                 *)
  (*                                                                       *)
  FT_Glyph_ptr = ^FT_Glyph;
  FT_Glyph = ^FT_GlyphRec;


  (* create a new glyph object *)
  FT_Glyph_InitFunc = function(
      glyph: FT_Glyph;
      slot: FT_GlyphSlot): FT_Error; cdecl;

  (* destroys a given glyph object *)
  FT_Glyph_DoneFunc = procedure(
      glyph: FT_Glyph); cdecl;

  FT_Glyph_TransformFunc = procedure(
      glyph: FT_Glyph;
      matrix: FT_Matrix_ptr;
      delta: FT_Vector_ptr); cdecl;

  FT_Glyph_GetBBoxFunc = procedure (
      glyph: FT_Glyph;
      abbox: FT_BBox_ptr); cdecl;

  FT_Glyph_CopyFunc = function(
      source: FT_Glyph;
      target: FT_Glyph): FT_Error; cdecl;

  FT_Glyph_PrepareFunc = function (
      glyph: FT_Glyph;
      slot: FT_GlyphSlot): FT_Error; cdecl;

  (* deprecated *)
  FT_Glyph_Init_Func       = FT_Glyph_InitFunc;
  FT_Glyph_Done_Func       = FT_Glyph_DoneFunc;
  FT_Glyph_Transform_Func  = FT_Glyph_TransformFunc;
  FT_Glyph_BBox_Func       = FT_Glyph_GetBBoxFunc;
  FT_Glyph_Copy_Func       = FT_Glyph_CopyFunc;
  FT_Glyph_Prepare_Func    = FT_Glyph_PrepareFunc;


  FT_Glyph_Class_ptr = ^FT_Glyph_Class; 
  FT_Glyph_Class = record
    glyph_size: FT_Long;
    glyph_format: FT_Glyph_Format;
    glyph_init: FT_Glyph_InitFunc;
    glyph_done: FT_Glyph_DoneFunc;
    glyph_copy: FT_Glyph_CopyFunc;
    glyph_transform: FT_Glyph_TransformFunc;
    glyph_bbox: FT_Glyph_GetBBoxFunc;
    glyph_prepare: FT_Glyph_PrepareFunc;    
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Renderer                                                        *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to a given FreeType renderer.  A renderer is a special    *)
  (*    module in charge of converting a glyph image to a bitmap, when     *)
  (*    necessary.  Each renderer supports a given glyph image format, and *)
  (*    one or more target surface depths.                                 *)
  (*                                                                       *)
  FT_RendererRec = record
    root: FT_ModuleRec;
    clazz: FT_Renderer_Class;
    glyph_format: FT_Glyph_Format;
    glyph_class: FT_Glyph_Class;

    raster: FT_Raster;
    raster_render: FT_Raster_Render_Func;
    render: FT_Renderer_RenderFunc;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Size_Internal                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    An opaque handle to an `FT_Size_InternalRec' structure, used to    *)
  (*    model private data of a given FT_Size object.                      *)
  (*                                                                       *)
  FT_Size_Internal = Pointer; // TODO: FT_Size_Internal is unknown


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Size_Metrics                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    The size metrics structure gives the metrics of a size object.     *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    x_ppem       :: The width of the scaled EM square in pixels, hence *)
  (*                    the term `ppem' (pixels per EM).  It is also       *)
  (*                    referred to as `nominal width'.                    *)
  (*                                                                       *)
  (*    y_ppem       :: The height of the scaled EM square in pixels,      *)
  (*                    hence the term `ppem' (pixels per EM).  It is also *)
  (*                    referred to as `nominal height'.                   *)
  (*                                                                       *)
  (*    x_scale      :: A 16.16 fractional scaling value used to convert   *)
  (*                    horizontal metrics from font units to 26.6         *)
  (*                    fractional pixels.  Only relevant for scalable     *)
  (*                    font formats.                                      *)
  (*                                                                       *)
  (*    y_scale      :: A 16.16 fractional scaling value used to convert   *)
  (*                    vertical metrics from font units to 26.6           *)
  (*                    fractional pixels.  Only relevant for scalable     *)
  (*                    font formats.                                      *)
  (*                                                                       *)
  (*    ascender     :: The ascender in 26.6 fractional pixels.  See       *)
  (*                    @FT_FaceRec for the details.                       *)
  (*                                                                       *)
  (*    descender    :: The descender in 26.6 fractional pixels.  See      *)
  (*                    @FT_FaceRec for the details.                       *)
  (*                                                                       *)
  (*    height       :: The height in 26.6 fractional pixels.  See         *)
  (*                    @FT_FaceRec for the details.                       *)
  (*                                                                       *)
  (*    max_advance  :: The maximal advance width in 26.6 fractional       *)
  (*                    pixels.  See @FT_FaceRec for the details.          *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The scaling values, if relevant, are determined first during a     *)
  (*    size changing operation.  The remaining fields are then set by the *)
  (*    driver.  For scalable formats, they are usually set to scaled      *)
  (*    values of the corresponding fields in @FT_FaceRec.                 *)
  (*                                                                       *)
  (*    Note that due to glyph hinting, these values might not be exact    *)
  (*    for certain fonts.  Thus they must be treated as unreliable        *)
  (*    with an error margin of at least one pixel!                        *)
  (*                                                                       *)
  (*    Indeed, the only way to get the exact metrics is to render _all_   *)
  (*    glyphs.  As this would be a definite performance hit, it is up to  *)
  (*    client applications to perform such computations.                  *)
  (*                                                                       *)
  (*    The FT_Size_Metrics structure is valid for bitmap fonts also.      *)
  (*                                                                       *)
  FT_Size_Metrics = record
    x_ppem: FT_UShort;      (* horizontal pixels per EM               *)
    y_ppem: FT_UShort;      (* vertical pixels per EM                 *)

    x_scale: FT_Fixed;      (* scaling values used to convert font    *)
    y_scale: FT_Fixed;      (* units to 26.6 fractional pixels        *)

    ascender: FT_Pos;       (* ascender in 26.6 frac. pixels          *)
    descender: FT_Pos;      (* descender in 26.6 frac. pixels         *)
    height: FT_Pos;         (* text height in 26.6 frac. pixels       *)
    max_advance: FT_Pos;    (* max horizontal advance, in 26.6 pixels *)
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_SizeRec                                                         *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    FreeType root size class structure.  A size object models a face   *)
  (*    object at a given size.                                            *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    face    :: Handle to the parent face object.                       *)
  (*                                                                       *)
  (*    generic :: A typeless pointer, which is unused by the FreeType     *)
  (*               library or any of its drivers.  It can be used by       *)
  (*               client applications to link their own data to each size *)
  (*               object.                                                 *)
  (*                                                                       *)
  (*    metrics :: Metrics for this size object.  This field is read-only. *)
  (*                                                                       *)
  FT_SizeRec = record
    face: FT_Face;              (* parent face object              *)
    generic: FT_Generic;        (* generic pointer for client uses *)
    metrics: FT_Size_Metrics;   (* size metrics                    *)
    internal: FT_Size_Internal;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_CharMapRec                                                      *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    The base charmap structure.                                        *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    face        :: A handle to the parent face object.                 *)
  (*                                                                       *)
  (*    encoding    :: An @FT_Encoding tag identifying the charmap.  Use   *)
  (*                   this with @FT_Select_Charmap.                       *)
  (*                                                                       *)
  (*    platform_id :: An ID number describing the platform for the        *)
  (*                   following encoding ID.  This comes directly from    *)
  (*                   the TrueType specification and should be emulated   *)
  (*                   for other formats.                                  *)
  (*                                                                       *)
  (*    encoding_id :: A platform specific encoding number.  This also     *)
  (*                   comes from the TrueType specification and should be *)
  (*                   emulated similarly.                                 *)
  (*                                                                       *)
  FT_CharMapRec = record
    face: FT_Face;
    encoding: FT_Encoding;
    platform_id: FT_UShort;
    encoding_id: FT_UShort;
  end;


  (*************************************************************************)
  (*************************************************************************)
  (*                                                                       *)
  (*                 B A S E   O B J E C T   C L A S S E S                 *)
  (*                                                                       *)
  (*************************************************************************)
  (*************************************************************************)


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Face_Internal                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    An opaque handle to an `FT_Face_InternalRec' structure, used to    *)
  (*    model private data of a given @FT_Face object.                     *)
  (*                                                                       *)
  (*    This structure might change between releases of FreeType 2 and is  *)
  (*    not generally available to client applications.                    *)
  (*                                                                       *)
  FT_Face_Internal = ^FT_Face_InternalRec;
  FT_Face_InternalRec = pointer; (*record
    // #ifdef FT_CONFIG_OPTION_OLD_INTERNALS
    reserved1: FT_UShort;
    reserved2: FT_Short;
    // #endif
    transform_matrix: FT_Matrix;
    transform_delta: FT_Vector;
    transform_flags: FT_Int;

    services: Pointer; // TODO: FT_ServiceCacheRec;

    // #ifdef FT_CONFIG_OPTION_INCREMENTAL
    incremental_interface: Pointer; // TODO: *FT_Incremental_InterfaceRec;
    // #endif

    ignore_unpatented_hinter: FT_Bool;
  end;
*)

  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_FaceRec                                                         *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    FreeType root face class structure.  A face object models a        *)
  (*    typeface in a font file.                                           *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    num_faces           :: The number of faces in the font file.  Some *)
  (*                           font formats can have multiple faces in     *)
  (*                           a font file.                                *)
  (*                                                                       *)
  (*    face_index          :: The index of the face in the font file.  It *)
  (*                           is set to 0 if there is only one face in    *)
  (*                           the font file.                              *)
  (*                                                                       *)
  (*    face_flags          :: A set of bit flags that give important      *)
  (*                           information about the face; see             *)
  (*                           @FT_FACE_FLAG_XXX for the details.          *)
  (*                                                                       *)
  (*    style_flags         :: A set of bit flags indicating the style of  *)
  (*                           the face; see @FT_STYLE_FLAG_XXX for the    *)
  (*                           details.                                    *)
  (*                                                                       *)
  (*    num_glyphs          :: The number of glyphs in the face.  If the   *)
  (*                           face is scalable and has sbits (see         *)
  (*                           `num_fixed_sizes'), it is set to the number *)
  (*                           of outline glyphs.                          *)
  (*                                                                       *)
  (*    family_name         :: The face's family name.  This is an ASCII   *)
  (*                           string, usually in English, which describes *)
  (*                           the typeface's family (like `Times New      *)
  (*                           Roman', `Bodoni', `Garamond', etc).  This   *)
  (*                           is a least common denominator used to list  *)
  (*                           fonts.  Some formats (TrueType & OpenType)  *)
  (*                           provide localized and Unicode versions of   *)
  (*                           this string.  Applications should use the   *)
  (*                           format specific interface to access them.   *)
  (*                                                                       *)
  (*    style_name          :: The face's style name.  This is an ASCII    *)
  (*                           string, usually in English, which describes *)
  (*                           the typeface's style (like `Italic',        *)
  (*                           `Bold', `Condensed', etc).  Not all font    *)
  (*                           formats provide a style name, so this field *)
  (*                           is optional, and can be set to NULL.  As    *)
  (*                           for `family_name', some formats provide     *)
  (*                           localized and Unicode versions of this      *)
  (*                           string.  Applications should use the format *)
  (*                           specific interface to access them.          *)
  (*                                                                       *)
  (*    num_fixed_sizes     :: The number of bitmap strikes in the face.   *)
  (*                           Even if the face is scalable, there might   *)
  (*                           still be bitmap strikes, which are called   *)
  (*                           `sbits' in that case.                       *)
  (*                                                                       *)
  (*    available_sizes     :: An array of @FT_Bitmap_Size for all bitmap  *)
  (*                           strikes in the face.  It is set to NULL if  *)
  (*                           there is no bitmap strike.                  *)
  (*                                                                       *)
  (*    num_charmaps        :: The number of charmaps in the face.         *)
  (*                                                                       *)
  (*    charmaps            :: An array of the charmaps of the face.       *)
  (*                                                                       *)
  (*    generic             :: A field reserved for client uses.  See the  *)
  (*                           @FT_Generic type description.               *)
  (*                                                                       *)
  (*    bbox                :: The font bounding box.  Coordinates are     *)
  (*                           expressed in font units (see                *)
  (*                           `units_per_EM').  The box is large enough   *)
  (*                           to contain any glyph from the font.  Thus,  *)
  (*                           `bbox.yMax' can be seen as the `maximal     *)
  (*                           ascender', and `bbox.yMin' as the `minimal  *)
  (*                           descender'.  Only relevant for scalable     *)
  (*                           formats.                                    *)
  (*                                                                       *)
  (*    units_per_EM        :: The number of font units per EM square for  *)
  (*                           this face.  This is typically 2048 for      *)
  (*                           TrueType fonts, and 1000 for Type 1 fonts.  *)
  (*                           Only relevant for scalable formats.         *)
  (*                                                                       *)
  (*    ascender            :: The typographic ascender of the face,       *)
  (*                           expressed in font units.  For font formats  *)
  (*                           not having this information, it is set to   *)
  (*                           `bbox.yMax'.  Only relevant for scalable    *)
  (*                           formats.                                    *)
  (*                                                                       *)
  (*    descender           :: The typographic descender of the face,      *)
  (*                           expressed in font units.  For font formats  *)
  (*                           not having this information, it is set to   *)
  (*                           `bbox.yMin'.  Note that this field is       *)
  (*                           usually negative.  Only relevant for        *)
  (*                           scalable formats.                           *)
  (*                                                                       *)
  (*    height              :: The height is the vertical distance         *)
  (*                           between two consecutive baselines,          *)
  (*                           expressed in font units.  It is always      *)
  (*                           positive.  Only relevant for scalable       *)
  (*                           formats.                                    *)
  (*                                                                       *)
  (*    max_advance_width   :: The maximal advance width, in font units,   *)
  (*                           for all glyphs in this face.  This can be   *)
  (*                           used to make word wrapping computations     *)
  (*                           faster.  Only relevant for scalable         *)
  (*                           formats.                                    *)
  (*                                                                       *)
  (*    max_advance_height  :: The maximal advance height, in font units,  *)
  (*                           for all glyphs in this face.  This is only  *)
  (*                           relevant for vertical layouts, and is set   *)
  (*                           to `height' for fonts that do not provide   *)
  (*                           vertical metrics.  Only relevant for        *)
  (*                           scalable formats.                           *)
  (*                                                                       *)
  (*    underline_position  :: The position, in font units, of the         *)
  (*                           underline line for this face.  It's the     *)
  (*                           center of the underlining stem.  Only       *)
  (*                           relevant for scalable formats.              *)
  (*                                                                       *)
  (*    underline_thickness :: The thickness, in font units, of the        *)
  (*                           underline for this face.  Only relevant for *)
  (*                           scalable formats.                           *)
  (*                                                                       *)
  (*    glyph               :: The face's associated glyph slot(s).        *)
  (*                                                                       *)
  (*    size                :: The current active size for this face.      *)
  (*                                                                       *)
  (*    charmap             :: The current active charmap for this face.   *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*   Fields may be changed after a call to @FT_Attach_File or            *)
  (*   @FT_Attach_Stream.                                                  *)
  (*                                                                       *)
  FT_FaceRec = record
    num_faces: FT_Long;
    face_index: FT_Long;

    face_flags: FT_Long;
    style_flags: FT_Long;

    num_glyphs: FT_Long;

    family_name: FT_String_ptr;
    style_name: FT_String_ptr;

    num_fixed_sizes: FT_Int;
    available_sizes: FT_Bitmap_Size_ptr;

    num_charmaps: FT_Int;
    charmaps: FT_CharMap_ptr;

    generic: FT_Generic;

    (*# The following member variables (down to `underline_thickness') *)
    (*# are only relevant to scalable outlines; cf. @FT_Bitmap_Size    *)
    (*# for bitmap fonts.                                              *)
    bbox: FT_BBox;

    units_per_EM: FT_UShort;
    ascender: FT_Short;
    descender: FT_Short;
    height: FT_Short;

    max_advance_width: FT_Short;
    max_advance_height: FT_Short;

    underline_position: FT_Short;
    underline_thickness: FT_Short;

    glyph: FT_GlyphSlot;
    size: FT_Size;
    charmap: FT_CharMap;

    (*@private begin *)

    driver: FT_Driver;
    memory: FT_Memory;
    stream: FT_Stream;

    sizes_list: FT_ListRec;

    autohint: FT_Generic;
    extensions: Pointer;

    internal: FT_Face_Internal;

    (*@private end *)
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_SubGlyph                                                        *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    The subglyph structure is an internal object used to describe      *)
  (*    subglyphs (for example, in the case of composites).                *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The subglyph implementation is not part of the high-level API,     *)
  (*    hence the forward structure declaration.                           *)
  (*                                                                       *)
  (*    You can however retrieve subglyph information with                 *)
  (*    @FT_Get_SubGlyph_Info.                                             *)
  (*                                                                       *)
  FT_SubGlyph = ^FT_SubGlyphRec;
  FT_SubGlyphRec = record
    index_: FT_Int;
    flags: FT_UShort;
    arg1: FT_Int;
    arg2: FT_Int;
    transform: FT_Matrix;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_Slot_Internal                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    An opaque handle to an `FT_Slot_InternalRec' structure, used to    *)
  (*    model private data of a given FT_GlyphSlot object.                 *)
  (*                                                                       *)
  FT_Slot_Internal = ^FT_Slot_InternalRec;
  FT_Slot_InternalRec = record
    loader: Pointer; // TODO: FT_GlyphLoader;
    flags: FT_UInt;
    glyph_transformed: FT_Bool;
    glyph_matrix: FT_Matrix;
    glyph_delta: FT_Vector;
    glyph_hints: Pointer;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_GlyphSlotRec                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    FreeType root glyph slot class structure.  A glyph slot is a       *)
  (*    container where individual glyphs can be loaded, be they in        *)
  (*    outline or bitmap format.                                          *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    library           :: A handle to the FreeType library instance     *)
  (*                         this slot belongs to.                         *)
  (*                                                                       *)
  (*    face              :: A handle to the parent face object.           *)
  (*                                                                       *)
  (*    next              :: In some cases (like some font tools), several *)
  (*                         glyph slots per face object can be a good     *)
  (*                         thing.  As this is rare, the glyph slots are  *)
  (*                         listed through a direct, single-linked list   *)
  (*                         using its `next' field.                       *)
  (*                                                                       *)
  (*    generic           :: A typeless pointer which is unused by the     *)
  (*                         FreeType library or any of its drivers.  It   *)
  (*                         can be used by client applications to link    *)
  (*                         their own data to each glyph slot object.     *)
  (*                                                                       *)
  (*    metrics           :: The metrics of the last loaded glyph in the   *)
  (*                         slot.  The returned values depend on the last *)
  (*                         load flags (see the @FT_Load_Glyph API        *)
  (*                         function) and can be expressed either in 26.6 *)
  (*                         fractional pixels or font units.              *)
  (*                                                                       *)
  (*                         Note that even when the glyph image is        *)
  (*                         transformed, the metrics are not.             *)
  (*                                                                       *)
  (*    linearHoriAdvance :: The advance width of the unhinted glyph.      *)
  (*                         Its value is expressed in 16.16 fractional    *)
  (*                         pixels, unless @FT_LOAD_LINEAR_DESIGN is set  *)
  (*                         when loading the glyph.  This field can be    *)
  (*                         important to perform correct WYSIWYG layout.  *)
  (*                         Only relevant for outline glyphs.             *)
  (*                                                                       *)
  (*    linearVertAdvance :: The advance height of the unhinted glyph.     *)
  (*                         Its value is expressed in 16.16 fractional    *)
  (*                         pixels, unless @FT_LOAD_LINEAR_DESIGN is set  *)
  (*                         when loading the glyph.  This field can be    *)
  (*                         important to perform correct WYSIWYG layout.  *)
  (*                         Only relevant for outline glyphs.             *)
  (*                                                                       *)
  (*    advance           :: This is the transformed advance width for the *)
  (*                         glyph.                                        *)
  (*                                                                       *)
  (*    format            :: This field indicates the format of the image  *)
  (*                         contained in the glyph slot.  Typically       *)
  (*                         @FT_GLYPH_FORMAT_BITMAP,                      *)
  (*                         @FT_GLYPH_FORMAT_OUTLINE, or                  *)
  (*                         @FT_GLYPH_FORMAT_COMPOSITE, but others are    *)
  (*                         possible.                                     *)
  (*                                                                       *)
  (*    bitmap            :: This field is used as a bitmap descriptor     *)
  (*                         when the slot format is                       *)
  (*                         @FT_GLYPH_FORMAT_BITMAP.  Note that the       *)
  (*                         address and content of the bitmap buffer can  *)
  (*                         change between calls of @FT_Load_Glyph and a  *)
  (*                         few other functions.                          *)
  (*                                                                       *)
  (*    bitmap_left       :: This is the bitmap's left bearing expressed   *)
  (*                         in integer pixels.  Of course, this is only   *)
  (*                         valid if the format is                        *)
  (*                         @FT_GLYPH_FORMAT_BITMAP.                      *)
  (*                                                                       *)
  (*    bitmap_top        :: This is the bitmap's top bearing expressed in *)
  (*                         integer pixels.  Remember that this is the    *)
  (*                         distance from the baseline to the top-most    *)
  (*                         glyph scanline, upwards y-coordinates being   *)
  (*                         *positive*.                                   *)
  (*                                                                       *)
  (*    outline           :: The outline descriptor for the current glyph  *)
  (*                         image if its format is                        *)
  (*                         @FT_GLYPH_FORMAT_OUTLINE.  Once a glyph is    *)
  (*                         loaded, `outline' can be transformed,         *)
  (*                         distorted, embolded, etc.  However, it must   *)
  (*                         not be freed.                                 *)
  (*                                                                       *)
  (*    num_subglyphs     :: The number of subglyphs in a composite glyph. *)
  (*                         This field is only valid for the composite    *)
  (*                         glyph format that should normally only be     *)
  (*                         loaded with the @FT_LOAD_NO_RECURSE flag.     *)
  (*                         For now this is internal to FreeType.         *)
  (*                                                                       *)
  (*    subglyphs         :: An array of subglyph descriptors for          *)
  (*                         composite glyphs.  There are `num_subglyphs'  *)
  (*                         elements in there.  Currently internal to     *)
  (*                         FreeType.                                     *)
  (*                                                                       *)
  (*    control_data      :: Certain font drivers can also return the      *)
  (*                         control data for a given glyph image (e.g.    *)
  (*                         TrueType bytecode, Type 1 charstrings, etc.). *)
  (*                         This field is a pointer to such data.         *)
  (*                                                                       *)
  (*    control_len       :: This is the length in bytes of the control    *)
  (*                         data.                                         *)
  (*                                                                       *)
  (*    other             :: Really wicked formats can use this pointer to *)
  (*                         present their own glyph image to client       *)
  (*                         applications.  Note that the application      *)
  (*                         needs to know about the image format.         *)
  (*                                                                       *)
  (*    lsb_delta         :: The difference between hinted and unhinted    *)
  (*                         left side bearing while autohinting is        *)
  (*                         active.  Zero otherwise.                      *)
  (*                                                                       *)
  (*    rsb_delta         :: The difference between hinted and unhinted    *)
  (*                         right side bearing while autohinting is       *)
  (*                         active.  Zero otherwise.                      *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    If @FT_Load_Glyph is called with default flags (see                *)
  (*    @FT_LOAD_DEFAULT) the glyph image is loaded in the glyph slot in   *)
  (*    its native format (e.g., an outline glyph for TrueType and Type 1  *)
  (*    formats).                                                          *)
  (*                                                                       *)
  (*    This image can later be converted into a bitmap by calling         *)
  (*    @FT_Render_Glyph.  This function finds the current renderer for    *)
  (*    the native image's format then invokes it.                         *)
  (*                                                                       *)
  (*    The renderer is in charge of transforming the native image through *)
  (*    the slot's face transformation fields, then convert it into a      *)
  (*    bitmap that is returned in `slot->bitmap'.                         *)
  (*                                                                       *)
  (*    Note that `slot->bitmap_left' and `slot->bitmap_top' are also used *)
  (*    to specify the position of the bitmap relative to the current pen  *)
  (*    position (e.g., coordinates (0,0) on the baseline).  Of course,    *)
  (*    `slot->format' is also changed to @FT_GLYPH_FORMAT_BITMAP.         *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    Here a small pseudo code fragment which shows how to use           *)
  (*    `lsb_delta' and `rsb_delta':                                       *)
  (*                                                                       *)
  (*    {                                                                  *)
  (*      FT_Pos  origin_x       = 0;                                      *)
  (*      FT_Pos  prev_rsb_delta = 0;                                      *)
  (*                                                                       *)
  (*                                                                       *)
  (*      for all glyphs do                                                *)
  (*        <compute kern between current and previous glyph and add it to *)
  (*         `origin_x'>                                                   *)
  (*                                                                       *)
  (*        <load glyph with `FT_Load_Glyph'>                              *)
  (*                                                                       *)
  (*        if ( prev_rsb_delta - face->glyph->lsb_delta >= 32 )           *)
  (*          origin_x -= 64;                                              *)
  (*        else if ( prev_rsb_delta - face->glyph->lsb_delta < -32 )      *)
  (*          origin_x += 64;                                              *)
  (*                                                                       *)
  (*        prev_rsb_delta = face->glyph->rsb_delta;                       *)
  (*                                                                       *)
  (*        <save glyph image, or render glyph, or ...>                    *)
  (*                                                                       *)
  (*        origin_x += face->glyph->advance.x;                            *)
  (*      endfor                                                           *)
  (*    }                                                                  *)
  (*                                                                       *)
  FT_GlyphSlotRec = record
    library_: FT_Library;
    face: FT_Face;
    next: FT_GlyphSlot;
    reserved: FT_UInt;       (* retained for binary compatibility *)
    generic: FT_Generic;

    metrics: FT_Glyph_Metrics;
    linearHoriAdvance: FT_Fixed;
    linearVertAdvance: FT_Fixed;
    advance: FT_Vector;

    format: FT_Glyph_Format;

    bitmap: FT_Bitmap;
    bitmap_left: FT_Int;
    bitmap_top: FT_Int;

    outline: FT_Outline;

    num_subglyphs: FT_UInt;
    subglyphs: FT_SubGlyph;

    control_data: Pointer;
    control_len: Integer;

    lsb_delta: FT_Pos;
    rsb_delta: FT_Pos;

    other: Pointer;

    internal: FT_Slot_Internal;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Size_RequestRec                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A structure used to model a size request.                          *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    type           :: See @FT_Size_Request_Type.                       *)
  (*                                                                       *)
  (*    width          :: The desired width.                               *)
  (*                                                                       *)
  (*    height         :: The desired height.                              *)
  (*                                                                       *)
  (*    horiResolution :: The horizontal resolution.  If set to zero,      *)
  (*                      `width' is treated as a 26.6 fractional pixel    *)
  (*                      value.                                           *)
  (*                                                                       *)
  (*    vertResolution :: The vertical resolution.  If set to zero,        *)
  (*                      `height' is treated as a 26.6 fractional pixel   *)
  (*                      value.                                           *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    If `width' is zero, then the horizontal scaling value is set      *)
  (*    equal to the vertical scaling value, and vice versa.               *)
  (*                                                                       *)
  FT_Size_Request = ^FT_Size_RequestRec;
  FT_Size_RequestRec = record
    type_: FT_Size_Request_Type;
    width: FT_Long;
    height: FT_Long;
    horiResolution: FT_UInt;
    vertResolution: FT_UInt;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Parameter                                                       *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A simple structure used to pass more or less generic parameters    *)
  (*    to @FT_Open_Face.                                                  *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    tag  :: A four-byte identification tag.                            *)
  (*                                                                       *)
  (*    data :: A pointer to the parameter data.                           *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The ID and function of parameters are driver-specific.             *)
  (*                                                                       *)
  FT_Parameter_ptr = ^FT_Parameter;
  FT_Parameter = record
    tag: FT_ULong;
    data: FT_Pointer;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Open_Args                                                       *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A structure used to indicate how to open a new font file or        *)
  (*    stream.  A pointer to such a structure can be used as a parameter  *)
  (*    for the functions @FT_Open_Face and @FT_Attach_Stream.             *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    flags       :: A set of bit flags indicating how to use the        *)
  (*                   structure.                                          *)
  (*                                                                       *)
  (*    memory_base :: The first byte of the file in memory.               *)
  (*                                                                       *)
  (*    memory_size :: The size in bytes of the file in memory.            *)
  (*                                                                       *)
  (*    pathname    :: A pointer to an 8-bit file pathname.                *)
  (*                                                                       *)
  (*    stream      :: A handle to a source stream object.                 *)
  (*                                                                       *)
  (*    driver      :: This field is exclusively used by @FT_Open_Face;    *)
  (*                   it simply specifies the font driver to use to open  *)
  (*                   the face.  If set to 0, FreeType tries to load the  *)
  (*                   face with each one of the drivers in its list.      *)
  (*                                                                       *)
  (*    num_params  :: The number of extra parameters.                     *)
  (*                                                                       *)
  (*    params      :: Extra parameters passed to the font driver when     *)
  (*                   opening a new face.                                 *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The stream type is determined by the contents of `flags' which     *)
  (*    are tested in the following order by @FT_Open_Face:                *)
  (*                                                                       *)
  (*    If the `FT_OPEN_MEMORY' bit is set, assume that this is a          *)
  (*    memory file of `memory_size' bytes, located at `memory_address'.   *)
  (*    The data are are not copied, and the client is responsible for     *)
  (*    releasing and destroying them _after_ the corresponding call to    *)
  (*    @FT_Done_Face.                                                     *)
  (*                                                                       *)
  (*    Otherwise, if the `FT_OPEN_STREAM' bit is set, assume that a       *)
  (*    custom input stream `stream' is used.                              *)
  (*                                                                       *)
  (*    Otherwise, if the `FT_OPEN_PATHNAME' bit is set, assume that this  *)
  (*    is a normal file and use `pathname' to open it.                    *)
  (*                                                                       *)
  (*    If the `FT_OPEN_DRIVER' bit is set, @FT_Open_Face only tries to    *)
  (*    open the file with the driver whose handler is in `driver'.        *)
  (*                                                                       *)
  (*    If the `FT_OPEN_PARAMS' bit is set, the parameters given by        *)
  (*    `num_params' and `params' is used.  They are ignored otherwise.    *)
  (*                                                                       *)
  (*    Ideally, both the `pathname' and `params' fields should be tagged  *)
  (*    as `const'; this is missing for API backwards compatibility.  With *)
  (*    other words, applications should treat them as read-only.          *)
  (*                                                                       *)
  FT_Open_Args_ptr = ^FT_Open_Args; 
  FT_Open_Args = record
    flags: FT_UInt;
    memory_base: FT_Byte_ptr;
    memory_size: FT_Long;
    pathname: FT_String_ptr;
    stream: FT_Stream;
    driver: FT_Module;
    num_params: FT_Int;
    params: FT_Parameter_ptr;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_GlyphRec                                                        *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    The root glyph structure contains a given glyph image plus its     *)
  (*    advance width in 16.16 fixed float format.                         *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    library :: A handle to the FreeType library object.                *)
  (*                                                                       *)
  (*    clazz   :: A pointer to the glyph's class.  Private.               *)
  (*                                                                       *)
  (*    format  :: The format of the glyph's image.                        *)
  (*                                                                       *)
  (*    advance :: A 16.16 vector that gives the glyph's advance width.    *)
  (*                                                                       *)
  FT_GlyphRec = record
    library_: FT_Library;
    clazz: FT_Glyph_Class_ptr;
    format: FT_Glyph_Format;
    advance: FT_Vector;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_BitmapGlyph                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to an object used to model a bitmap glyph image.  This is *)
  (*    a sub-class of @FT_Glyph, and a pointer to @FT_BitmapGlyphRec.     *)
  (*                                                                       *)
  FT_BitmapGlyph = ^FT_BitmapGlyphRec;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_BitmapGlyphRec                                                  *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A structure used for bitmap glyph images.  This really is a        *)
  (*    `sub-class' of @FT_GlyphRec.                                       *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    root   :: The root @FT_Glyph fields.                               *)
  (*                                                                       *)
  (*    left   :: The left-side bearing, i.e., the horizontal distance     *)
  (*              from the current pen position to the left border of the  *)
  (*              glyph bitmap.                                            *)
  (*                                                                       *)
  (*    top    :: The top-side bearing, i.e., the vertical distance from   *)
  (*              the current pen position to the top border of the glyph  *)
  (*              bitmap.  This distance is positive for upwards-y!        *)
  (*                                                                       *)
  (*    bitmap :: A descriptor for the bitmap.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    You can typecast an @FT_Glyph to @FT_BitmapGlyph if you have       *)
  (*    `glyph->format == FT_GLYPH_FORMAT_BITMAP'.  This lets you access   *)
  (*    the bitmap's contents easily.                                      *)
  (*                                                                       *)
  (*    The corresponding pixel buffer is always owned by @FT_BitmapGlyph  *)
  (*    and is thus created and destroyed with it.                         *)
  (*                                                                       *)
  FT_BitmapGlyphRec = record
    root: FT_GlyphRec;
    left: FT_Int;
    top: FT_Int;
    bitmap: FT_Bitmap;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <Type>                                                                *)
  (*    FT_OutlineGlyph                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A handle to an object used to model an outline glyph image.  This  *)
  (*    is a sub-class of @FT_Glyph, and a pointer to @FT_OutlineGlyphRec. *)
  (*                                                                       *)
  FT_OutlineGlyph = ^FT_OutlineGlyphRec;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_OutlineGlyphRec                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A structure used for outline (vectorial) glyph images.  This       *)
  (*    really is a `sub-class' of @FT_GlyphRec.                           *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    root    :: The root @FT_Glyph fields.                              *)
  (*                                                                       *)
  (*    outline :: A descriptor for the outline.                           *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    You can typecast a @FT_Glyph to @FT_OutlineGlyph if you have       *)
  (*    `glyph->format == FT_GLYPH_FORMAT_OUTLINE'.  This lets you access  *)
  (*    the outline's content easily.                                      *)
  (*                                                                       *)
  (*    As the outline is extracted from a glyph slot, its coordinates are *)
  (*    expressed normally in 26.6 pixels, unless the flag                 *)
  (*    @FT_LOAD_NO_SCALE was used in @FT_Load_Glyph() or @FT_Load_Char(). *)
  (*                                                                       *)
  (*    The outline's tables are always owned by the object and are        *)
  (*    destroyed with it.                                                 *)
  (*                                                                       *)
  FT_OutlineGlyphRec = record
    root: FT_GlyphRec;
    outline: FT_Outline;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_Outline_MoveToFunc                                              *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A function pointer type used to describe the signature of a `move  *)
  (*    to' function during outline walking/decomposition.                 *)
  (*                                                                       *)
  (*    A `move to' is emitted to start a new contour in an outline.       *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    to   :: A pointer to the target point of the `move to'.            *)
  (*                                                                       *)
  (*    user :: A typeless pointer which is passed from the caller of the  *)
  (*            decomposition function.                                    *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    Error code.  0 means success.                                      *)
  (*                                                                       *)
  FT_Outline_MoveToFunc = function (
      to_: FT_Vector_ptr;
      user: Pointer): Integer; cdecl;

  FT_Outline_MoveTo_Func = FT_Outline_MoveToFunc;

  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_Outline_LineToFunc                                              *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A function pointer type used to describe the signature of a `line  *)
  (*    to' function during outline walking/decomposition.                 *)
  (*                                                                       *)
  (*    A `line to' is emitted to indicate a segment in the outline.       *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    to   :: A pointer to the target point of the `line to'.            *)
  (*                                                                       *)
  (*    user :: A typeless pointer which is passed from the caller of the  *)
  (*            decomposition function.                                    *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    Error code.  0 means success.                                      *)
  (*                                                                       *)
  FT_Outline_LineToFunc = function (
      to_: FT_Vector_ptr;
      user: pointer): Integer; cdecl;

  FT_Outline_LineTo_Func = FT_Outline_LineToFunc;

  
  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_Outline_ConicToFunc                                             *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A function pointer type use to describe the signature of a `conic  *)
  (*    to' function during outline walking/decomposition.                 *)
  (*                                                                       *)
  (*    A `conic to' is emitted to indicate a second-order Bézier arc in   *)
  (*    the outline.                                                       *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    control :: An intermediate control point between the last position *)
  (*               and the new target in `to'.                             *)
  (*                                                                       *)
  (*    to      :: A pointer to the target end point of the conic arc.     *)
  (*                                                                       *)
  (*    user    :: A typeless pointer which is passed from the caller of   *)
  (*               the decomposition function.                             *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    Error code.  0 means success.                                      *)
  (*                                                                       *)
  FT_Outline_ConicToFunc = function(
      control: FT_Vector_ptr;
      to_: FT_Vector_ptr;
      user: Pointer): Integer; cdecl; 

  FT_Outline_ConicTo_Func = FT_Outline_ConicToFunc;

  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_Outline_CubicToFunc                                             *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A function pointer type used to describe the signature of a `cubic *)
  (*    to' function during outline walking/decomposition.                 *)
  (*                                                                       *)
  (*    A `cubic to' is emitted to indicate a third-order Bézier arc.      *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    control1 :: A pointer to the first Bézier control point.           *)
  (*                                                                       *)
  (*    control2 :: A pointer to the second Bézier control point.          *)
  (*                                                                       *)
  (*    to       :: A pointer to the target end point.                     *)
  (*                                                                       *)
  (*    user     :: A typeless pointer which is passed from the caller of  *)
  (*                the decomposition function.                            *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    Error code.  0 means success.                                      *)
  (*                                                                       *)
  FT_Outline_CubicToFunc = function (
      control1: FT_Vector_ptr;
      control2: FT_Vector_ptr;
      to_: FT_Vector_ptr;
      user: Pointer): Integer; cdecl;

  FT_Outline_CubicTo_Func = FT_Outline_CubicToFunc;


  (*************************************************************************)
  (*                                                                       *)
  (* <Struct>                                                              *)
  (*    FT_Outline_Funcs                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A structure to hold various function pointers used during outline  *)
  (*    decomposition in order to emit segments, conic, and cubic Béziers, *)
  (*    as well as `move to' and `close to' operations.                    *)
  (*                                                                       *)
  (* <Fields>                                                              *)
  (*    move_to  :: The `move to' emitter.                                 *)
  (*                                                                       *)
  (*    line_to  :: The segment emitter.                                   *)
  (*                                                                       *)
  (*    conic_to :: The second-order Bézier arc emitter.                   *)
  (*                                                                       *)
  (*    cubic_to :: The third-order Bézier arc emitter.                    *)
  (*                                                                       *)
  (*    shift    :: The shift that is applied to coordinates before they   *)
  (*                are sent to the emitter.                               *)
  (*                                                                       *)
  (*    delta    :: The delta that is applied to coordinates before they   *)
  (*                are sent to the emitter, but after the shift.          *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The point coordinates sent to the emitters are the transformed     *)
  (*    version of the original coordinates (this is important for high    *)
  (*    accuracy during scan-conversion).  The transformation is simple:   *)
  (*                                                                       *)
  (*    {                                                                  *)
  (*      x' = (x << shift) - delta                                        *)
  (*      y' = (x << shift) - delta                                        *)
  (*    }                                                                  *)
  (*                                                                       *)
  (*    Set the value of `shift' and `delta' to 0 to get the original      *)
  (*    point coordinates.                                                 *)
  (*                                                                       *)
  FT_Outline_Funcs_ptr = ^FT_Outline_Funcs;
  FT_Outline_Funcs = record
    move_to: FT_Outline_MoveToFunc;
    line_to: FT_Outline_LineToFunc;
    conic_to: FT_Outline_ConicToFunc;
    cubic_to: FT_Outline_CubicToFunc;

    shift: Integer;
    delta: FT_Pos;
  end;


  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_List_Iterator                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    An FT_List iterator function which is called during a list parse   *)
  (*    by @FT_List_Iterate.                                               *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    node :: The current iteration list node.                           *)
  (*                                                                       *)
  (*    user :: A typeless pointer passed to @FT_List_Iterate.             *)
  (*            Can be used to point to the iteration's state.             *)
  (*                                                                       *)
  FT_List_Iterator = function (
      node: FT_ListNode;
      user: Pointer): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <FuncType>                                                            *)
  (*    FT_List_Destructor                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    An @FT_List iterator function which is called during a list        *)
  (*    finalization by @FT_List_Finalize to destroy all elements in a     *)
  (*    given list.                                                        *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    system :: The current system object.                               *)
  (*                                                                       *)
  (*    data   :: The current object to destroy.                           *)
  (*                                                                       *)
  (*    user   :: A typeless pointer passed to @FT_List_Iterate.  It can   *)
  (*              be used to point to the iteration's state.               *)
  (*                                                                       *)
  FT_List_Destructor = procedure(
      memory: FT_Memory;
      data: Pointer;
      user: Pointer); cdecl;





  (*************************************************************************)
  (*************************************************************************)
  (*                                                                       *)
  (*                         F U N C T I O N S                             *)
  (*                                                                       *)
  (*************************************************************************)
  (*************************************************************************)

var
  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Init_FreeType                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Initialize a new FreeType library object.  The set of modules      *)
  (*    that are registered by this function is determined at build time.  *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    alibrary :: A handle to a new library object.                      *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Init_FreeType: function (library_: FT_Library_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Done_FreeType                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Destroy a given FreeType library object and all of its children,   *)
  (*    including resources, drivers, faces, sizes, etc.                   *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    library :: A handle to the target library object.                  *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Done_FreeType: function (library_: FT_Library): FT_Error; cdecl;

  
  (**************************************************************************
   *
   * @func:
   *   FT_Library_SetLcdFilter
   *
   * @description:
   *   This function is used to apply color filtering to LCD decimated
   *   bitmaps, like the ones used when calling @FT_Render_Glyph with
   *   @FT_RENDER_MODE_LCD or @FT_RENDER_MODE_LCD_V.
   *
   * @input:
   *   library ::
   *     A handle to the target library instance.
   *
   *   filter ::
   *     The filter type.
   *
   *     You can use @FT_LCD_FILTER_NONE here to disable this feature, or
   *     @FT_LCD_FILTER_DEFAULT to use a default filter that should work
   *     well on most LCD screens.
   *
   * @return:
   *   FreeType error code.  0 means success.
   *
   * @note:
   *   This feature is always disabled by default.  Clients must make an
   *   explicit call to this function with a `filter' value other than
   *   @FT_LCD_FILTER_NONE in order to enable it.
   *
   *   Due to *PATENTS* covering subpixel rendering, this function doesn't
   *   do anything except returning `FT_Err_Unimplemented_Feature' if the
   *   configuration macro FT_CONFIG_OPTION_SUBPIXEL_RENDERING is not
   *   defined in your build of the library, which should correspond to all
   *   default builds of FreeType.
   *
   *   The filter affects glyph bitmaps rendered through @FT_Render_Glyph,
   *   @FT_Outline_Get_Bitmap, @FT_Load_Glyph, and @FT_Load_Char.
   *
   *   It does _not_ affect the output of @FT_Outline_Render and
   *   @FT_Outline_Get_Bitmap.
   *
   *   If this feature is activated, the dimensions of LCD glyph bitmaps are
   *   either larger or taller than the dimensions of the corresponding
   *   outline with regards to the pixel grid.  For example, for
   *   @FT_RENDER_MODE_LCD, the filter adds up to 3 pixels to the left, and
   *   up to 3 pixels to the right.
   *
   *   The bitmap offset values are adjusted correctly, so clients shouldn't
   *   need to modify their layout and glyph positioning code when enabling
   *   the filter.
   *
   * @since:
   *   2.3.0
   *)
  FT_Library_SetLcdFilter: function(
      library_: FT_Library;
      filter: FT_LcdFilter): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_New_Face                                                        *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    This function calls @FT_Open_Face to open a font by its pathname.  *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    library    :: A handle to the library resource.                    *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    pathname   :: A path to the font file.                             *)
  (*                                                                       *)
  (*    face_index :: The index of the face within the font.  The first    *)
  (*                  face has index 0.                                    *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    aface      :: A handle to a new face object.  If `face_index' is   *)
  (*                  greater than or equal to zero, it must be non-NULL.  *)
  (*                  See @FT_Open_Face for more details.                  *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_New_Face: function(
      library_: FT_Library;
      filepathname: pAnsiChar;
      face_index: FT_Long;
      aface: FT_Face_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_New_Memory_Face                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    This function calls @FT_Open_Face to open a font which has been    *)
  (*    loaded into memory.                                                *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    library    :: A handle to the library resource.                    *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    file_base  :: A pointer to the beginning of the font data.         *)
  (*                                                                       *)
  (*    file_size  :: The size of the memory chunk used by the font data.  *)
  (*                                                                       *)
  (*    face_index :: The index of the face within the font.  The first    *)
  (*                  face has index 0.                                    *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    aface      :: A handle to a new face object.  If `face_index' is   *)
  (*                  greater than or equal to zero, it must be non-NULL.  *)
  (*                  See @FT_Open_Face for more details.                  *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    You must not deallocate the memory before calling @FT_Done_Face.   *)
  (*                                                                       *)
  FT_New_Memory_Face: function(
      library_: FT_Library;
      file_base: FT_Byte_ptr;
      file_size: FT_Long;
      face_index: FT_Long;
      aface: FT_Face_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Open_Face                                                       *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Create a face object from a given resource described by            *)
  (*    @FT_Open_Args.                                                     *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    library    :: A handle to the library resource.                    *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    args       :: A pointer to an `FT_Open_Args' structure which must  *)
  (*                  be filled by the caller.                             *)
  (*                                                                       *)
  (*    face_index :: The index of the face within the font.  The first    *)
  (*                  face has index 0.                                    *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    aface      :: A handle to a new face object.  If `face_index' is   *)
  (*                  greater than or equal to zero, it must be non-NULL.  *)
  (*                  See note below.                                      *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    Unlike FreeType 1.x, this function automatically creates a glyph   *)
  (*    slot for the face object which can be accessed directly through    *)
  (*    `face->glyph'.                                                     *)
  (*                                                                       *)
  (*    FT_Open_Face can be used to quickly check whether the font         *)
  (*    format of a given font resource is supported by FreeType.  If the  *)
  (*    `face_index' field is negative, the function's return value is 0   *)
  (*    if the font format is recognized, or non-zero otherwise;           *)
  (*    the function returns a more or less empty face handle in `*aface'  *)
  (*    (if `aface' isn't NULL).  The only useful field in this special    *)
  (*    case is `face->num_faces' which gives the number of faces within   *)
  (*    the font file.  After examination, the returned @FT_Face structure *)
  (*    should be deallocated with a call to @FT_Done_Face.                *)
  (*                                                                       *)
  (*    Each new face object created with this function also owns a        *)
  (*    default @FT_Size object, accessible as `face->size'.               *)
  (*                                                                       *)
  FT_Open_Face: function(
      library_: FT_Library;
      args: FT_Open_Args_ptr;
      face_index: FT_Long;
      aface: FT_Face_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Attach_File                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    This function calls @FT_Attach_Stream to attach a file.            *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    face         :: The target face object.                            *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    filepathname :: The pathname.                                      *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Attach_File: function(
      face: FT_Face;
      filepathname: pAnsiChar): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Attach_Stream                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    `Attach' data to a face object.  Normally, this is used to read    *)
  (*    additional information for the face object.  For example, you can  *)
  (*    attach an AFM file that comes with a Type 1 font to get the        *)
  (*    kerning values and other metrics.                                  *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    face       :: The target face object.                              *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    parameters :: A pointer to @FT_Open_Args which must be filled by   *)
  (*                  the caller.                                          *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The meaning of the `attach' (i.e., what really happens when the    *)
  (*    new file is read) is not fixed by FreeType itself.  It really      *)
  (*    depends on the font format (and thus the font driver).             *)
  (*                                                                       *)
  (*    Client applications are expected to know what they are doing       *)
  (*    when invoking this function.  Most drivers simply do not implement *)
  (*    file attachments.                                                  *)
  (*                                                                       *)
  FT_Attach_Stream: function(
      face: FT_Face;
      parameters: FT_Open_Args_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Done_Face                                                       *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Discard a given face object, as well as all of its child slots and *)
  (*    sizes.                                                             *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    face :: A handle to a target face object.                          *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Done_Face: function(face: FT_Face): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Select_Size                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Select a bitmap strike.                                            *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    face         :: A handle to a target face object.                  *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    strike_index :: The index of the bitmap strike in the              *)
  (*                    `available_sizes' field of @FT_FaceRec structure.  *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Select_Size: function(
      face: FT_Face;
      strike_index: FT_Int): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Request_Size                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Resize the scale of the active @FT_Size object in a face.          *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    face :: A handle to a target face object.                          *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    req  :: A pointer to a @FT_Size_RequestRec.                        *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    Although drivers may select the bitmap strike matching the         *)
  (*    request, you should not rely on this if you intend to select a     *)
  (*    particular bitmap strike.  Use @FT_Select_Size instead in that     *)
  (*    case.                                                              *)
  (*                                                                       *)
  FT_Request_Size: function(
      face: FT_Face;
      req: FT_Size_Request): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Set_Char_Size                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    This function calls @FT_Request_Size to request the nominal size   *)
  (*    (in points).                                                       *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    face            :: A handle to a target face object.               *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    char_width      :: The nominal width, in 26.6 fractional points.   *)
  (*                                                                       *)
  (*    char_height     :: The nominal height, in 26.6 fractional points.  *)
  (*                                                                       *)
  (*    horz_resolution :: The horizontal resolution in dpi.               *)
  (*                                                                       *)
  (*    vert_resolution :: The vertical resolution in dpi.                 *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    If either the character width or height is zero, it is set equal   *)
  (*    to the other value.                                                *)
  (*                                                                       *)
  (*    If either the horizontal or vertical resolution is zero, it is set *)
  (*    equal to the other value.                                          *)
  (*                                                                       *)
  (*    A character width or height smaller than 1pt is set to 1pt; if     *)
  (*    both resolution values are zero, they are set to 72dpi.            *)
  (*                                                                       *)
  FT_Set_Char_Size: function(
      face: FT_Face;
      char_width: FT_F26Dot6;
      char_height: FT_F26Dot6;
      horz_resolution: FT_UInt;
      vert_resolution: FT_UInt): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Set_Pixel_Sizes                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    This function calls @FT_Request_Size to request the nominal size   *)
  (*    (in pixels).                                                       *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    face         :: A handle to the target face object.                *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    pixel_width  :: The nominal width, in pixels.                      *)
  (*                                                                       *)
  (*    pixel_height :: The nominal height, in pixels.                     *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Set_Pixel_Sizes: function(
      face: FT_Face;
      pixel_width: FT_UInt;
      pixel_height: FT_UInt): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Load_Glyph                                                      *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A function used to load a single glyph into the glyph slot of a    *)
  (*    face object.                                                       *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    face        :: A handle to the target face object where the glyph  *)
  (*                   is loaded.                                          *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    glyph_index :: The index of the glyph in the font file.  For       *)
  (*                   CID-keyed fonts (either in PS or in CFF format)     *)
  (*                   this argument specifies the CID value.              *)
  (*                                                                       *)
  (*    load_flags  :: A flag indicating what to load for this glyph.  The *)
  (*                   @FT_LOAD_XXX constants can be used to control the   *)
  (*                   glyph loading process (e.g., whether the outline    *)
  (*                   should be scaled, whether to load bitmaps or not,   *)
  (*                   whether to hint the outline, etc).                  *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The loaded glyph may be transformed.  See @FT_Set_Transform for    *)
  (*    the details.                                                       *)
  (*                                                                       *)
  FT_Load_Glyph: function(
      face: FT_Face;
      glyph_index: FT_UInt;
      load_flags: FT_Int32): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Load_Char                                                       *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A function used to load a single glyph into the glyph slot of a    *)
  (*    face object, according to its character code.                      *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    face        :: A handle to a target face object where the glyph    *)
  (*                   is loaded.                                          *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    char_code   :: The glyph's character code, according to the        *)
  (*                   current charmap used in the face.                   *)
  (*                                                                       *)
  (*    load_flags  :: A flag indicating what to load for this glyph.  The *)
  (*                   @FT_LOAD_XXX constants can be used to control the   *)
  (*                   glyph loading process (e.g., whether the outline    *)
  (*                   should be scaled, whether to load bitmaps or not,   *)
  (*                   whether to hint the outline, etc).                  *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    This function simply calls @FT_Get_Char_Index and @FT_Load_Glyph.  *)
  (*                                                                       *)
  FT_Load_Char: function(
      face: FT_Face;
      char_code: FT_ULong;
      load_flags: FT_Int32): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Set_Transform                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A function used to set the transformation that is applied to glyph *)
  (*    images when they are loaded into a glyph slot through              *)
  (*    @FT_Load_Glyph.                                                    *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    face   :: A handle to the source face object.                      *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    matrix :: A pointer to the transformation's 2x2 matrix.  Use 0 for *)
  (*              the identity matrix.                                     *)
  (*    delta  :: A pointer to the translation vector.  Use 0 for the null *)
  (*              vector.                                                  *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The transformation is only applied to scalable image formats after *)
  (*    the glyph has been loaded.  It means that hinting is unaltered by  *)
  (*    the transformation and is performed on the character size given in *)
  (*    the last call to @FT_Set_Char_Size or @FT_Set_Pixel_Sizes.         *)
  (*                                                                       *)
  (*    Note that this also transforms the `face.glyph.advance' field, but *)
  (*    *not* the values in `face.glyph.metrics'.                          *)
  (*                                                                       *)
  FT_Set_Transform: procedure(
      face: FT_Face;
      matrix: FT_Matrix_ptr;
      delta: FT_Vector_ptr); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Render_Glyph                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Convert a given glyph image to a bitmap.  It does so by inspecting *)
  (*    the glyph image format, finding the relevant renderer, and         *)
  (*    invoking it.                                                       *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    slot        :: A handle to the glyph slot containing the image to  *)
  (*                   convert.                                            *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    render_mode :: This is the render mode used to render the glyph    *)
  (*                   image into a bitmap.  See @FT_Render_Mode for a     *)
  (*                   list of possible values.                            *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Render_Glyph: function(
      slot: FT_GlyphSlot;
      render_mode: FT_Render_Mode): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Get_Kerning                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Return the kerning vector between two glyphs of a same face.       *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    face        :: A handle to a source face object.                   *)
  (*                                                                       *)
  (*    left_glyph  :: The index of the left glyph in the kern pair.       *)
  (*                                                                       *)
  (*    right_glyph :: The index of the right glyph in the kern pair.      *)
  (*                                                                       *)
  (*    kern_mode   :: See @FT_Kerning_Mode for more information.          *)
  (*                   Determines the scale and dimension of the returned  *)
  (*                   kerning vector.                                     *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    akerning    :: The kerning vector.  This is either in font units   *)
  (*                   or in pixels (26.6 format) for scalable formats,    *)
  (*                   and in pixels for fixed-sizes formats.              *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    Only horizontal layouts (left-to-right & right-to-left) are        *)
  (*    supported by this method.  Other layouts, or more sophisticated    *)
  (*    kernings, are out of the scope of this API function -- they can be *)
  (*    implemented through format-specific interfaces.                    *)
  (*                                                                       *)
  FT_Get_Kerning: function(
      face: FT_Face;
      left_glyph: FT_UInt;
      right_glyph: FT_UInt;
      kern_mode: FT_UInt;
      akerning: FT_Vector_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Get_Track_Kerning                                               *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Return the track kerning for a given face object at a given size.  *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    face        :: A handle to a source face object.                   *)
  (*                                                                       *)
  (*    point_size  :: The point size in 16.16 fractional points.          *)
  (*                                                                       *)
  (*    degree      :: The degree of tightness.                            *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    akerning    :: The kerning in 16.16 fractional points.             *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Get_Track_Kerning: function(
      face: FT_Face;
      point_size: FT_Fixed;
      degree: FT_Int;
      akerning: FT_Fixed_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Get_Glyph_Name                                                  *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Retrieve the ASCII name of a given glyph in a face.  This only     *)
  (*    works for those faces where @FT_HAS_GLYPH_NAMES(face) returns 1.   *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    face        :: A handle to a source face object.                   *)
  (*                                                                       *)
  (*    glyph_index :: The glyph index.                                    *)
  (*                                                                       *)
  (*    buffer_max  :: The maximal number of bytes available in the        *)
  (*                   buffer.                                             *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    buffer      :: A pointer to a target buffer where the name is      *)
  (*                   copied to.                                          *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    An error is returned if the face doesn't provide glyph names or if *)
  (*    the glyph index is invalid.  In all cases of failure, the first    *)
  (*    byte of `buffer' is set to 0 to indicate an empty name.            *)
  (*                                                                       *)
  (*    The glyph name is truncated to fit within the buffer if it is too  *)
  (*    long.  The returned string is always zero-terminated.              *)
  (*                                                                       *)
  (*    This function is not compiled within the library if the config     *)
  (*    macro `FT_CONFIG_OPTION_NO_GLYPH_NAMES' is defined in              *)
  (*    `include/freetype/config/ftoptions.h'.                             *)
  (*                                                                       *)
  FT_Get_Glyph_Name: function(
      face: FT_Face;
      glyph_index: FT_UInt;
      buffer: FT_Pointer;
      buffer_max: FT_UInt): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Get_Postscript_Name                                             *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Retrieve the ASCII Postscript name of a given face, if available.  *)
  (*    This only works with Postscript and TrueType fonts.                *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    face :: A handle to the source face object.                        *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    A pointer to the face's Postscript name.  NULL if unavailable.     *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The returned pointer is owned by the face and is destroyed with    *)
  (*    it.                                                                *)
  (*                                                                       *)
  FT_Get_Postscript_Name: function (face: FT_Face): pAnsiChar; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Select_Charmap                                                  *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Select a given charmap by its encoding tag (as listed in           *)
  (*    `freetype.h').                                                     *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    face     :: A handle to the source face object.                    *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    encoding :: A handle to the selected encoding.                     *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    This function returns an error if no charmap in the face           *)
  (*    corresponds to the encoding queried here.                          *)
  (*                                                                       *)
  (*    Because many fonts contain more than a single cmap for Unicode     *)
  (*    encoding, this function has some special code to select the one    *)
  (*    which covers Unicode best.  It is thus preferable to               *)
  (*    @FT_Set_Charmap in this case.                                      *)
  (*                                                                       *)
  FT_Select_Charmap: function(
      face: FT_Face;
      encoding: FT_Encoding): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Set_Charmap                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Select a given charmap for character code to glyph index mapping.  *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    face    :: A handle to the source face object.                     *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    charmap :: A handle to the selected charmap.                       *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    This function returns an error if the charmap is not part of       *)
  (*    the face (i.e., if it is not listed in the `face->charmaps'        *)
  (*    table).                                                            *)
  (*                                                                       *)
  FT_Set_Charmap: function(
      face: FT_Face;
      charmap: FT_CharMap): FT_Error; cdecl;


  (*************************************************************************
   *
   * @function:
   *   FT_Get_Charmap_Index
   *
   * @description:
   *   Retrieve index of a given charmap.
   *
   * @input:
   *   charmap ::
   *     A handle to a charmap.
   *
   * @return:
   *   The index into the array of character maps within the face to which
   *   `charmap' belongs.
   *
   *)
  FT_Get_Charmap_Index: function(charmap: FT_CharMap): FT_Int; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Get_Char_Index                                                  *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Return the glyph index of a given character code.  This function   *)
  (*    uses a charmap object to do the mapping.                           *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    face     :: A handle to the source face object.                    *)
  (*                                                                       *)
  (*    charcode :: The character code.                                    *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    The glyph index.  0 means `undefined character code'.              *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    If you use FreeType to manipulate the contents of font files       *)
  (*    directly, be aware that the glyph index returned by this function  *)
  (*    doesn't always correspond to the internal indices used within      *)
  (*    the file.  This is done to ensure that value 0 always corresponds  *)
  (*    to the `missing glyph'.                                            *)
  (*                                                                       *)
  FT_Get_Char_Index: function(
      face: FT_Face;
      charcode: FT_ULong): FT_UInt; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Get_First_Char                                                  *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    This function is used to return the first character code in the    *)
  (*    current charmap of a given face.  It also returns the              *)
  (*    corresponding glyph index.                                         *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    face    :: A handle to the source face object.                     *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    agindex :: Glyph index of first character code.  0 if charmap is   *)
  (*               empty.                                                  *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    The charmap's first character code.                                *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    You should use this function with @FT_Get_Next_Char to be able to  *)
  (*    parse all character codes available in a given charmap.  The code  *)
  (*    should look like this:                                             *)
  (*                                                                       *)
  (*    {                                                                  *)
  (*      FT_ULong  charcode;                                              *)
  (*      FT_UInt   gindex;                                                *)
  (*                                                                       *)
  (*                                                                       *)
  (*      charcode = FT_Get_First_Char( face, &gindex );                   *)
  (*      while ( gindex != 0 )                                            *)
  (*      {                                                                *)
  (*        ... do something with (charcode,gindex) pair ...               *)
  (*                                                                       *)
  (*        charcode = FT_Get_Next_Char( face, charcode, &gindex );        *)
  (*      }                                                                *)
  (*    }                                                                  *)
  (*                                                                       *)
  (*    Note that `*agindex' is set to 0 if the charmap is empty.  The     *)
  (*    result itself can be 0 in two cases: if the charmap is empty or    *)
  (*    when the value 0 is the first valid character code.                *)
  (*                                                                       *)
  FT_Get_First_Char: function(
      face: FT_Face;
      agindex: FT_UInt_ptr): FT_ULong; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Get_Next_Char                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    This function is used to return the next character code in the     *)
  (*    current charmap of a given face following the value `char_code',   *)
  (*    as well as the corresponding glyph index.                          *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    face      :: A handle to the source face object.                   *)
  (*    char_code :: The starting character code.                          *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    agindex   :: Glyph index of first character code.  0 if charmap    *)
  (*                 is empty.                                             *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    The charmap's next character code.                                 *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    You should use this function with @FT_Get_First_Char to walk       *)
  (*    over all character codes available in a given charmap.  See the    *)
  (*    note for this function for a simple code example.                  *)
  (*                                                                       *)
  (*    Note that `*agindex' is set to 0 when there are no more codes in   *)
  (*    the charmap.                                                       *)
  (*                                                                       *)
  FT_Get_Next_Char: function(
      face: FT_Face;
      char_code: FT_ULong;
      agindex: FT_UInt_ptr): FT_ULong; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Get_Name_Index                                                  *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Return the glyph index of a given glyph name.  This function uses  *)
  (*    driver specific objects to do the translation.                     *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    face       :: A handle to the source face object.                  *)
  (*                                                                       *)
  (*    glyph_name :: The glyph name.                                      *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    The glyph index.  0 means `undefined character code'.              *)
  (*                                                                       *)
  FT_Get_Name_Index: function(
      face: FT_Face;
      glyph_name: FT_String_ptr): FT_UInt; cdecl;


  (*************************************************************************
   *
   * @func:
   *   FT_Get_SubGlyph_Info
   *
   * @description:
   *   Retrieve a description of a given subglyph.  Only use it if
   *   `glyph->format' is @FT_GLYPH_FORMAT_COMPOSITE, or an error is
   *   returned.
   *
   * @input:
   *   glyph ::
   *     The source glyph slot.
   *
   *   sub_index ::
   *     The index of subglyph.  Must be less than `glyph->num_subglyphs'.
   *
   * @output:
   *   p_index ::
   *     The glyph index of the subglyph.
   *
   *   p_flags ::
   *     The subglyph flags, see @FT_SUBGLYPH_FLAG_XXX.
   *
   *   p_arg1 ::
   *     The subglyph's first argument (if any).
   *
   *   p_arg2 ::
   *     The subglyph's second argument (if any).
   *
   *   p_transform ::
   *     The subglyph transformation (if any).
   *
   * @return:
   *   FreeType error code.  0 means success.
   *
   * @note:
   *   The values of `*p_arg1', `*p_arg2', and `*p_transform' must be
   *   interpreted depending on the flags returned in `*p_flags'.  See the
   *   TrueType specification for details.
   *
   *)
  FT_Get_SubGlyph_Info: function(
      glyph: FT_GlyphSlot;
      sub_index: FT_UInt;
      p_index: FT_Int_ptr;
      p_flags: FT_UInt_ptr;
      p_arg1: FT_Int_ptr;
      p_arg2: FT_Int_ptr;
      p_transform: FT_Matrix_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_MulDiv                                                          *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A very simple function used to perform the computation `(a*b)/c'   *)
  (*    with maximal accuracy (it uses a 64-bit intermediate integer       *)
  (*    whenever necessary).                                               *)
  (*                                                                       *)
  (*    This function isn't necessarily as fast as some processor specific *)
  (*    operations, but is at least completely portable.                   *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    a :: The first multiplier.                                         *)
  (*    b :: The second multiplier.                                        *)
  (*    c :: The divisor.                                                  *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    The result of `(a*b)/c'.  This function never traps when trying to *)
  (*    divide by zero; it simply returns `MaxInt' or `MinInt' depending   *)
  (*    on the signs of `a' and `b'.                                       *)
  (*                                                                       *)
  FT_MulDiv: function(
      a: FT_Long;
      b: FT_Long;
      c: FT_Long): FT_Long; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_MulFix                                                          *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A very simple function used to perform the computation             *)
  (*    `(a*b)/0x10000' with maximal accuracy.  Most of the time this is   *)
  (*    used to multiply a given value by a 16.16 fixed float factor.      *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    a :: The first multiplier.                                         *)
  (*    b :: The second multiplier.  Use a 16.16 factor here whenever      *)
  (*         possible (see note below).                                    *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    The result of `(a*b)/0x10000'.                                     *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    This function has been optimized for the case where the absolute   *)
  (*    value of `a' is less than 2048, and `b' is a 16.16 scaling factor. *)
  (*    As this happens mainly when scaling from notional units to         *)
  (*    fractional pixels in FreeType, it resulted in noticeable speed     *)
  (*    improvements between versions 2.x and 1.x.                         *)
  (*                                                                       *)
  (*    As a conclusion, always try to place a 16.16 factor as the         *)
  (*    _second_ argument of this function; this can make a great          *)
  (*    difference.                                                        *)
  (*                                                                       *)
  FT_MulFix: function(
      a: FT_Long;
      b: FT_Long): FT_Long; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_DivFix                                                          *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A very simple function used to perform the computation             *)
  (*    `(a*0x10000)/b' with maximal accuracy.  Most of the time, this is  *)
  (*    used to divide a given value by a 16.16 fixed float factor.        *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    a :: The first multiplier.                                         *)
  (*    b :: The second multiplier.  Use a 16.16 factor here whenever      *)
  (*         possible (see note below).                                    *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    The result of `(a*0x10000)/b'.                                     *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The optimization for FT_DivFix() is simple: If (a << 16) fits in   *)
  (*    32 bits, then the division is computed directly.  Otherwise, we    *)
  (*    use a specialized version of @FT_MulDiv.                           *)
  (*                                                                       *)
  FT_DivFix: function(
      a: FT_Long;
      b: FT_Long): FT_Long;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_RoundFix                                                        *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A very simple function used to round a 16.16 fixed number.         *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    a :: The number to be rounded.                                     *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    The result of `(a + 0x8000) & -0x10000'.                           *)
  (*                                                                       *)
  FT_RoundFix: function(a: FT_Fixed): FT_Fixed; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_CeilFix                                                         *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A very simple function used to compute the ceiling function of a   *)
  (*    16.16 fixed number.                                                *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    a :: The number for which the ceiling function is to be computed.  *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    The result of `(a + 0x10000 - 1) & -0x10000'.                      *)
  (*                                                                       *)
  FT_CeilFix: function(a: FT_Fixed): FT_Fixed; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_FloorFix                                                        *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A very simple function used to compute the floor function of a     *)
  (*    16.16 fixed number.                                                *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    a :: The number for which the floor function is to be computed.    *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    The result of `a & -0x10000'.                                      *)
  (*                                                                       *)
  FT_FloorFix: function(a: FT_Fixed): FT_Fixed; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Vector_Transform                                                *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Transform a single vector through a 2x2 matrix.                    *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    vector :: The target vector to transform.                          *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    matrix :: A pointer to the source 2x2 matrix.                      *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The result is undefined if either `vector' or `matrix' is invalid. *)
  (*                                                                       *)
  FT_Vector_Transform: procedure(
      vec: FT_Vector_ptr;
      matrix: FT_Matrix_ptr); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Library_Version                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Return the version of the FreeType library being used.  This is    *)
  (*    useful when dynamically linking to the library, since one cannot   *)
  (*    use the macros @FREETYPE_MAJOR, @FREETYPE_MINOR, and               *)
  (*    @FREETYPE_PATCH.                                                   *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    library :: A source library handle.                                *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    amajor  :: The major version number.                               *)
  (*                                                                       *)
  (*    aminor  :: The minor version number.                               *)
  (*                                                                       *)
  (*    apatch  :: The patch version number.                               *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The reason why this function takes a `library' argument is because *)
  (*    certain programs implement library initialization in a custom way  *)
  (*    that doesn't use @FT_Init_FreeType.                                *)
  (*                                                                       *)
  (*    In such cases, the library version might not be available before   *)
  (*    the library object has been created.                               *)
  (*                                                                       *)
  FT_Library_Version: procedure(
      library_: FT_Library;
      amajor: FT_Int_ptr;
      aminor: FT_Int_ptr;
      apatch: FT_Int_ptr); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Face_CheckTrueTypePatents                                       *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Parse all bytecode instructions of a TrueType font file to check   *)
  (*    whether any of the patented opcodes are used.  This is only useful *)
  (*    if you want to be able to use the unpatented hinter with           *)
  (*    fonts that do *not* use these opcodes.                             *)
  (*                                                                       *)
  (*    Note that this function parses *all* glyph instructions in the     *)
  (*    font file, which may be slow.                                      *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    face :: A face handle.                                             *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    1 if this is a TrueType font that uses one of the patented         *)
  (*    opcodes, 0 otherwise.                                              *)
  (*                                                                       *)
  (* <Since>                                                               *)
  (*    2.3.5                                                              *)
  (*                                                                       *)
  FT_Face_CheckTrueTypePatents: function(face: FT_Face): FT_Bool; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Face_SetUnpatentedHinting                                       *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Enable or disable the unpatented hinter for a given face.          *)
  (*    Only enable it if you have determined that the face doesn't        *)
  (*    use any patented opcodes (see @FT_Face_CheckTrueTypePatents).      *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    face  :: A face handle.                                            *)
  (*                                                                       *)
  (*    value :: New boolean setting.                                      *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    The old setting value.  This will always be false if this is not   *)
  (*    a SFNT font, or if the unpatented hinter is not compiled in this   *)
  (*    instance of the library.                                           *)
  (*                                                                       *)
  (* <Since>                                                               *)
  (*    2.3.5                                                              *)
  (*                                                                       *)
  FT_Face_SetUnpatentedHinting: function(
      face: FT_Face;
      value: FT_Bool): FT_Bool; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Get_Glyph                                                       *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A function used to extract a glyph image from a slot.              *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    slot   :: A handle to the source glyph slot.                       *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    aglyph :: A handle to the glyph object.                            *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Get_Glyph: function(
      slot: FT_GlyphSlot;
      aglyph: FT_Glyph_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Glyph_Copy                                                      *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    A function used to copy a glyph image.  Note that the created      *)
  (*    @FT_Glyph object must be released with @FT_Done_Glyph.             *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    source :: A handle to the source glyph object.                     *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    target :: A handle to the target glyph object.  0 in case of       *)
  (*              error.                                                   *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Glyph_Copy: function(
      source: FT_Glyph;
      target: FT_Glyph_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Glyph_Transform                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Transforms a glyph image if its format is scalable.                *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    glyph  :: A handle to the target glyph object.                     *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    matrix :: A pointer to a 2x2 matrix to apply.                      *)
  (*                                                                       *)
  (*    delta  :: A pointer to a 2d vector to apply.  Coordinates are      *)
  (*              expressed in 1/64th of a pixel.                          *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code (if not 0, the glyph format is not scalable).  *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The 2x2 transformation matrix is also applied to the glyph's       *)
  (*    advance vector.                                                    *)
  (*                                                                       *)
  FT_Glyph_Transform: function(
      glyph: FT_Glyph;
      matrix: FT_Matrix_ptr;
      delta: FT_Vector_ptr): FT_Error; cdecl;

  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Glyph_Get_CBox                                                  *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Return a glyph's `control box'.  The control box encloses all the  *)
  (*    outline's points, including Bézier control points.  Though it      *)
  (*    coincides with the exact bounding box for most glyphs, it can be   *)
  (*    slightly larger in some situations (like when rotating an outline  *)
  (*    which contains Bézier outside arcs).                               *)
  (*                                                                       *)
  (*    Computing the control box is very fast, while getting the bounding *)
  (*    box can take much more time as it needs to walk over all segments  *)
  (*    and arcs in the outline.  To get the latter, you can use the       *)
  (*    `ftbbox' component which is dedicated to this single task.         *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    glyph :: A handle to the source glyph object.                      *)
  (*                                                                       *)
  (*    mode  :: The mode which indicates how to interpret the returned    *)
  (*             bounding box values.                                      *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    acbox :: The glyph coordinate bounding box.  Coordinates are       *)
  (*             expressed in 1/64th of pixels if it is grid-fitted.       *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    Coordinates are relative to the glyph origin, using the Y-upwards  *)
  (*    convention.                                                        *)
  (*                                                                       *)
  (*    If the glyph has been loaded with @FT_LOAD_NO_SCALE, `bbox_mode'   *)
  (*    must be set to @FT_GLYPH_BBOX_UNSCALED to get unscaled font        *)
  (*    units in 26.6 pixel format.  The value @FT_GLYPH_BBOX_SUBPIXELS    *)
  (*    is another name for this constant.                                 *)
  (*                                                                       *)
  (*    Note that the maximum coordinates are exclusive, which means that  *)
  (*    one can compute the width and height of the glyph image (be it in  *)
  (*    integer or 26.6 pixels) as:                                        *)
  (*                                                                       *)
  (*    {                                                                  *)
  (*      width  = bbox.xMax - bbox.xMin;                                  *)
  (*      height = bbox.yMax - bbox.yMin;                                  *)
  (*    }                                                                  *)
  (*                                                                       *)
  (*    Note also that for 26.6 coordinates, if `bbox_mode' is set to      *)
  (*    @FT_GLYPH_BBOX_GRIDFIT, the coordinates will also be grid-fitted,  *)
  (*    which corresponds to:                                              *)
  (*                                                                       *)
  (*    {                                                                  *)
  (*      bbox.xMin = FLOOR(bbox.xMin);                                    *)
  (*      bbox.yMin = FLOOR(bbox.yMin);                                    *)
  (*      bbox.xMax = CEILING(bbox.xMax);                                  *)
  (*      bbox.yMax = CEILING(bbox.yMax);                                  *)
  (*    }                                                                  *)
  (*                                                                       *)
  (*    To get the bbox in pixel coordinates, set `bbox_mode' to           *)
  (*    @FT_GLYPH_BBOX_TRUNCATE.                                           *)
  (*                                                                       *)
  (*    To get the bbox in grid-fitted pixel coordinates, set `bbox_mode'  *)
  (*    to @FT_GLYPH_BBOX_PIXELS.                                          *)
  (*                                                                       *)
  FT_Glyph_Get_CBox: procedure(
      glyph: FT_Glyph;
      bbox_mode: FT_UInt;
      acbox: FT_BBox_ptr); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Glyph_To_Bitmap                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Converts a given glyph object to a bitmap glyph object.            *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    the_glyph   :: A pointer to a handle to the target glyph.          *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    render_mode :: An enumeration that describe how the data is        *)
  (*                   rendered.                                           *)
  (*                                                                       *)
  (*    origin      :: A pointer to a vector used to translate the glyph   *)
  (*                   image before rendering.  Can be 0 (if no            *)
  (*                   translation).  The origin is expressed in           *)
  (*                   26.6 pixels.                                        *)
  (*                                                                       *)
  (*    destroy     :: A boolean that indicates that the original glyph    *)
  (*                   image should be destroyed by this function.  It is  *)
  (*                   never destroyed in case of error.                   *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The glyph image is translated with the `origin' vector before      *)
  (*    rendering.                                                         *)
  (*                                                                       *)
  (*    The first parameter is a pointer to an @FT_Glyph handle, that will *)
  (*    be replaced by this function.  Typically, you would use (omitting  *)
  (*    error handling):                                                   *)
  (*                                                                       *)
  (*                                                                       *)
  (*      {                                                                *)
  (*        FT_Glyph        glyph;                                         *)
  (*        FT_BitmapGlyph  glyph_bitmap;                                  *)
  (*                                                                       *)
  (*                                                                       *)
  (*        // load glyph                                                  *)
  (*        error = FT_Load_Char( face, glyph_index, FT_LOAD_DEFAUT );     *)
  (*                                                                       *)
  (*        // extract glyph image                                         *)
  (*        error = FT_Get_Glyph( face->glyph, &glyph );                   *)
  (*                                                                       *)
  (*        // convert to a bitmap (default render mode + destroy old)     *)
  (*        if ( glyph->format != FT_GLYPH_FORMAT_BITMAP )                 *)
  (*        {                                                              *)
  (*          error = FT_Glyph_To_Bitmap( &glyph, FT_RENDER_MODE_DEFAULT,  *)
  (*                                      0, 1 );                          *)
  (*          if ( error ) // glyph unchanged                              *)
  (*            ...                                                        *)
  (*        }                                                              *)
  (*                                                                       *)
  (*        // access bitmap content by typecasting                        *)
  (*        glyph_bitmap = (FT_BitmapGlyph)glyph;                          *)
  (*                                                                       *)
  (*        // do funny stuff with it, like blitting/drawing               *)
  (*        ...                                                            *)
  (*                                                                       *)
  (*        // discard glyph image (bitmap or not)                         *)
  (*        FT_Done_Glyph( glyph );                                        *)
  (*      }                                                                *)
  (*                                                                       *)
  (*                                                                       *)
  (*    This function does nothing if the glyph format isn't scalable.     *)
  (*                                                                       *)
  FT_Glyph_To_Bitmap: function(
      the_glyph: FT_Glyph_ptr;
      render_mode: FT_Render_Mode;
      origin: FT_Vector_ptr;
      destroy: FT_Bool): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Done_Glyph                                                      *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Destroys a given glyph.                                            *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    glyph :: A handle to the target glyph object.                      *)
  (*                                                                       *)
  FT_Done_Glyph: procedure(glyph: FT_Glyph); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Matrix_Multiply                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Performs the matrix operation `b = a*b'.                           *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    a :: A pointer to matrix `a'.                                      *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    b :: A pointer to matrix `b'.                                      *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The result is undefined if either `a' or `b' is zero.              *)
  (*                                                                       *)
  FT_Matrix_Multiply: procedure(
      a: FT_Matrix_ptr;
      b: FT_Matrix_ptr); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Matrix_Invert                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Inverts a 2x2 matrix.  Returns an error if it can't be inverted.   *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    matrix :: A pointer to the target matrix.  Remains untouched in    *)
  (*              case of error.                                           *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Matrix_Invert: function(
      matrix: FT_Matrix_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Bitmap_New                                                      *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Initialize a pointer to an @FT_Bitmap structure.                   *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    abitmap :: A pointer to the bitmap structure.                      *)
  (*                                                                       *)
  FT_Bitmap_New: procedure(abitmap: FT_Bitmap_ptr); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Bitmap_Copy                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Copies an bitmap into another one.                                 *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    library :: A handle to a library object.                           *)
  (*                                                                       *)
  (*    source  :: A handle to the source bitmap.                          *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    target  :: A handle to the target bitmap.                          *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Bitmap_Copy: function(
      library_: FT_Library;
      source: FT_Bitmap_ptr;
      target: FT_Bitmap_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Bitmap_Embolden                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Embolden a bitmap.  The new bitmap will be about `xStrength'       *)
  (*    pixels wider and `yStrength' pixels higher.  The left and bottom   *)
  (*    borders are kept unchanged.                                        *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    library   :: A handle to a library object.                         *)
  (*                                                                       *)
  (*    xStrength :: How strong the glyph is emboldened horizontally.      *)
  (*                 Expressed in 26.6 pixel format.                       *)
  (*                                                                       *)
  (*    yStrength :: How strong the glyph is emboldened vertically.        *)
  (*                 Expressed in 26.6 pixel format.                       *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    bitmap    :: A handle to the target bitmap.                        *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The current implementation restricts `xStrength' to be less than   *)
  (*    or equal to 8 if bitmap is of pixel_mode @FT_PIXEL_MODE_MONO.      *)
  (*                                                                       *)
  (*    If you want to embolden the bitmap owned by a @FT_GlyphSlotRec,    *)
  (*    you should call `FT_GlyphSlot_Own_Bitmap' on the slot first.       *)
  (*                                                                       *)
  FT_Bitmap_Embolden: function(
      library_: FT_Library;
      bitmap: FT_Bitmap_ptr;
      xStrength: FT_Pos;
      yStrength: FT_Pos): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Bitmap_Convert                                                  *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Convert a bitmap object with depth 1bpp, 2bpp, 4bpp, or 8bpp to a  *)
  (*    bitmap object with depth 8bpp, making the number of used bytes per *)
  (*    line (a.k.a. the `pitch') a multiple of `alignment'.               *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    library   :: A handle to a library object.                         *)
  (*                                                                       *)
  (*    source    :: The source bitmap.                                    *)
  (*                                                                       *)
  (*    alignment :: The pitch of the bitmap is a multiple of this         *)
  (*                 parameter.  Common values are 1, 2, or 4.             *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    target    :: The target bitmap.                                    *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    It is possible to call @FT_Bitmap_Convert multiple times without   *)
  (*    calling @FT_Bitmap_Done (the memory is simply reallocated).        *)
  (*                                                                       *)
  (*    Use @FT_Bitmap_Done to finally remove the bitmap object.           *)
  (*                                                                       *)
  (*    The `library' argument is taken to have access to FreeType's       *)
  (*    memory handling functions.                                         *)
  (*                                                                       *)
  FT_Bitmap_Convert: function(
      library_: FT_Library;
      source: FT_Bitmap_ptr;
      target: FT_Bitmap_ptr;
      alignment: FT_Int): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Bitmap_Done                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Destroy a bitmap object created with @FT_Bitmap_New.               *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    library :: A handle to a library object.                           *)
  (*                                                                       *)
  (*    bitmap  :: The bitmap object to be freed.                          *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The `library' argument is taken to have access to FreeType's       *)
  (*    memory handling functions.                                         *)
  (*                                                                       *)
  FT_Bitmap_Done: function(
      library_: FT_Library;
      bitmap: FT_Bitmap_ptr): FT_Error; cdecl;


  (*************************************************************************
   *
   * @func:
   *   FT_Get_Gasp
   *
   * @description:
   *   Read the `gasp' table from a TrueType or OpenType font file and
   *   return the entry corresponding to a given character pixel size.
   *
   * @input:
   *   face :: The source face handle.
   *   ppem :: The vertical character pixel size.
   *
   * @return:
   *   Bit flags (see @FT_GASP_XXX), or @FT_GASP_NO_TABLE is there is no
   *   `gasp' table in the face.
   *
   * @since:
   *   2.3.0
   *)
  FT_Get_Gasp: function(
      face: FT_Face;
      ppem: FT_UInt): FT_Int; cdecl;


 (************************************************************************
  *
  * @function:
  *   FT_Stream_OpenGzip
  *
  * @description:
  *   Open a new stream to parse gzip-compressed font files.  This is
  *   mainly used to support the compressed `*.pcf.gz' fonts that come
  *   with XFree86.
  *
  * @input:
  *   stream ::
  *     The target embedding stream.
  *
  *   source ::
  *     The source stream.
  *
  * @return:
  *   FreeType error code.  0 means success.
  *
  * @note:
  *   The source stream must be opened _before_ calling this function.
  *
  *   Calling the internal function `FT_Stream_Close' on the new stream will
  *   *not* call `FT_Stream_Close' on the source stream.  None of the stream
  *   objects will be released to the heap.
  *
  *   The stream implementation is very basic and resets the decompression
  *   process each time seeking backwards is needed within the stream.
  *
  *   In certain builds of the library, gzip compression recognition is
  *   automatically handled when calling @FT_New_Face or @FT_Open_Face.
  *   This means that if no font driver is capable of handling the raw
  *   compressed file, the library will try to open a gzipped stream from
  *   it and re-open the face with it.
  *
  *   This function may return `FT_Err_Unimplemented_Feature' if your build
  *   of FreeType was not compiled with zlib support.
  *)
  FT_Stream_OpenGzip: function(
      stream: FT_Stream;
      source: FT_Stream): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Outline_Decompose                                               *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Walks over an outline's structure to decompose it into individual  *)
  (*    segments and Bézier arcs.  This function is also able to emit      *)
  (*    `move to' and `close to' operations to indicate the start and end  *)
  (*    of new contours in the outline.                                    *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    outline        :: A pointer to the source target.                  *)
  (*                                                                       *)
  (*    func_interface :: A table of `emitters', i.e,. function pointers   *)
  (*                      called during decomposition to indicate path     *)
  (*                      operations.                                      *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    user           :: A typeless pointer which is passed to each       *)
  (*                      emitter during the decomposition.  It can be     *)
  (*                      used to store the state during the               *)
  (*                      decomposition.                                   *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Outline_Decompose: function(
      outline: FT_Outline_ptr;
      func_interface: FT_Outline_Funcs_ptr;
      user: Pointer): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Outline_New                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Creates a new outline of a given size.                             *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    library     :: A handle to the library object from where the       *)
  (*                   outline is allocated.  Note however that the new    *)
  (*                   outline will *not* necessarily be *freed*, when     *)
  (*                   destroying the library, by @FT_Done_FreeType.       *)
  (*                                                                       *)
  (*    numPoints   :: The maximal number of points within the outline.    *)
  (*                                                                       *)
  (*    numContours :: The maximal number of contours within the outline.  *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    anoutline   :: A handle to the new outline.  NULL in case of       *)
  (*                   error.                                              *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The reason why this function takes a `library' parameter is simply *)
  (*    to use the library's memory allocator.                             *)
  (*                                                                       *)
  FT_Outline_New: function(
      library_: FT_Library;
      numPoints: FT_UInt;
      numContours: FT_Int;
      anoutline: FT_Outline_ptr): FT_Error; cdecl;


  FT_Outline_New_Internal: function(
      memory: FT_Memory;
      numPoints: FT_UInt;
      numContours: FT_Int;
      anoutline: FT_Outline_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Outline_Done                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Destroys an outline created with @FT_Outline_New.                  *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    library :: A handle of the library object used to allocate the     *)
  (*               outline.                                                *)
  (*                                                                       *)
  (*    outline :: A pointer to the outline object to be discarded.        *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    If the outline's `owner' field is not set, only the outline        *)
  (*    descriptor will be released.                                       *)
  (*                                                                       *)
  (*    The reason why this function takes an `library' parameter is       *)
  (*    simply to use ft_mem_free().                                       *)
  (*                                                                       *)
  FT_Outline_Done: function(
      library_: FT_Library;
      outline: FT_Outline_ptr): FT_Error; cdecl;


  FT_Outline_Done_Internal: function(
      memory: FT_Memory;
      outline: FT_Outline_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Outline_Check                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Check the contents of an outline descriptor.                       *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    outline :: A handle to a source outline.                           *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Outline_Check: function(
      outline: FT_Outline_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Outline_Get_BBox                                                *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Computes the exact bounding box of an outline.  This is slower     *)
  (*    than computing the control box.  However, it uses an advanced      *)
  (*    algorithm which returns _very_ quickly when the two boxes          *)
  (*    coincide.  Otherwise, the outline Bézier arcs are walked over to   *)
  (*    extract their extrema.                                             *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    outline :: A pointer to the source outline.                        *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    abbox   :: The outline's exact bounding box.                       *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Outline_Get_BBox: function(
      outline: FT_Outline_ptr;
      abbox: FT_BBox_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Outline_Get_CBox                                                *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Returns an outline's `control box'.  The control box encloses all  *)
  (*    the outline's points, including Bézier control points.  Though it  *)
  (*    coincides with the exact bounding box for most glyphs, it can be   *)
  (*    slightly larger in some situations (like when rotating an outline  *)
  (*    which contains Bézier outside arcs).                               *)
  (*                                                                       *)
  (*    Computing the control box is very fast, while getting the bounding *)
  (*    box can take much more time as it needs to walk over all segments  *)
  (*    and arcs in the outline.  To get the latter, you can use the       *)
  (*    `ftbbox' component which is dedicated to this single task.         *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    outline :: A pointer to the source outline descriptor.             *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    acbox   :: The outline's control box.                              *)
  (*                                                                       *)
  FT_Outline_Get_CBox: procedure(
      outline: FT_Outline_ptr;
      acbox: FT_BBox_ptr); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Outline_Translate                                               *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Applies a simple translation to the points of an outline.          *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    outline :: A pointer to the target outline descriptor.             *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    xOffset :: The horizontal offset.                                  *)
  (*                                                                       *)
  (*    yOffset :: The vertical offset.                                    *)
  (*                                                                       *)
  FT_Outline_Translate: procedure(
      outline: FT_Outline_ptr;
      xOffset: FT_Pos;
      yOffset: FT_Pos); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Outline_Copy                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Copies an outline into another one.  Both objects must have the    *)
  (*    same sizes (number of points & number of contours) when this       *)
  (*    function is called.                                                *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    source :: A handle to the source outline.                          *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    target :: A handle to the target outline.                          *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Outline_Copy: function(
      source: FT_Outline_ptr;
      target: FT_Outline_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Outline_Transform                                               *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Applies a simple 2x2 matrix to all of an outline's points.  Useful *)
  (*    for applying rotations, slanting, flipping, etc.                   *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    outline :: A pointer to the target outline descriptor.             *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    matrix  :: A pointer to the transformation matrix.                 *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    You can use @FT_Outline_Translate if you need to translate the     *)
  (*    outline's points.                                                  *)
  (*                                                                       *)
  FT_Outline_Transform: procedure(
      outline: FT_Outline_ptr;
      matrix: FT_Matrix_ptr); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Outline_Embolden                                                *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Emboldens an outline.  The new outline will be at most 4 times     *)
  (*    `strength' pixels wider and higher.  You may think of the left and *)
  (*    bottom borders as unchanged.                                       *)
  (*                                                                       *)
  (*    Negative `strength' values to reduce the outline thickness are     *)
  (*    possible also.                                                     *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    outline  :: A handle to the target outline.                        *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    strength :: How strong the glyph is emboldened.  Expressed in      *)
  (*                26.6 pixel format.                                     *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The used algorithm to increase or decrease the thickness of the    *)
  (*    glyph doesn't change the number of points; this means that certain *)
  (*    situations like acute angles or intersections are sometimes        *)
  (*    handled incorrectly.                                               *)
  (*                                                                       *)
  (*    Example call:                                                      *)
  (*                                                                       *)
  (*    {                                                                  *)
  (*      FT_Load_Glyph( face, index, FT_LOAD_DEFAULT );                   *)
  (*      if ( face->slot->format == FT_GLYPH_FORMAT_OUTLINE )             *)
  (*        FT_Outline_Embolden( &face->slot->outline, strength );         *)
  (*    }                                                                  *)
  (*                                                                       *)
  FT_Outline_Embolden: function(
      outline: FT_Outline_ptr;
      strength: FT_Pos): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Outline_Reverse                                                 *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Reverses the drawing direction of an outline.  This is used to     *)
  (*    ensure consistent fill conventions for mirrored glyphs.            *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    outline :: A pointer to the target outline descriptor.             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    This functions toggles the bit flag @FT_OUTLINE_REVERSE_FILL in    *)
  (*    the outline's `flags' field.                                       *)
  (*                                                                       *)
  (*    It shouldn't be used by a normal client application, unless it     *)
  (*    knows what it is doing.                                            *)
  (*                                                                       *)
  FT_Outline_Reverse: procedure(
      outline: FT_Outline_ptr); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Outline_Get_Bitmap                                              *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Renders an outline within a bitmap.  The outline's image is simply *)
  (*    OR-ed to the target bitmap.                                        *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    library :: A handle to a FreeType library object.                  *)
  (*                                                                       *)
  (*    outline :: A pointer to the source outline descriptor.             *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    abitmap :: A pointer to the target bitmap descriptor.              *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    This function does NOT CREATE the bitmap, it only renders an       *)
  (*    outline image within the one you pass to it!                       *)
  (*                                                                       *)
  (*    It will use the raster corresponding to the default glyph format.  *)
  (*                                                                       *)
  FT_Outline_Get_Bitmap: procedure(
      library_: FT_Library;
      outline: FT_Outline_ptr;
      abitmap: FT_Bitmap_ptr); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Outline_Render                                                  *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Renders an outline within a bitmap using the current scan-convert. *)
  (*    This functions uses an @FT_Raster_Params structure as an argument, *)
  (*    allowing advanced features like direct composition, translucency,  *)
  (*    etc.                                                               *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    library :: A handle to a FreeType library object.                  *)
  (*                                                                       *)
  (*    outline :: A pointer to the source outline descriptor.             *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    params  :: A pointer to an @FT_Raster_Params structure used to     *)
  (*               describe the rendering operation.                       *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    You should know what you are doing and how @FT_Raster_Params works *)
  (*    to use this function.                                              *)
  (*                                                                       *)
  (*    The field `params.source' will be set to `outline' before the scan *)
  (*    converter is called, which means that the value you give to it is  *)
  (*    actually ignored.                                                  *)
  (*                                                                       *)
  FT_Outline_Render: function(
      library_: FT_Library;
      outline: FT_Outline_ptr;
      params: FT_Raster_Params_ptr): FT_Error; cdecl;


 (**************************************************************************
  *
  * @function:
  *   FT_Outline_Get_Orientation
  *
  * @description:
  *   This function analyzes a glyph outline and tries to compute its
  *   fill orientation (see @FT_Orientation).  This is done by computing
  *   the direction of each global horizontal and/or vertical extrema
  *   within the outline.
  *
  *   Note that this will return @FT_ORIENTATION_TRUETYPE for empty
  *   outlines.
  *
  * @input:
  *   outline ::
  *     A handle to the source outline.
  *
  * @return:
  *   The orientation.
  *
  *)
  FT_Outline_Get_Orientation: function(
      outline: FT_Outline_ptr): FT_Orientation; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_List_Find                                                       *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Finds the list node for a given listed object.                     *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    list :: A pointer to the parent list.                              *)
  (*    data :: The address of the listed object.                          *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    List node.  NULL if it wasn't found.                               *)
  (*                                                                       *)
  FT_List_Find: function(
      list: FT_List;
      data: pointer): FT_ListNode; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_List_Add                                                        *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Appends an element to the end of a list.                           *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    list :: A pointer to the parent list.                              *)
  (*    node :: The node to append.                                        *)
  (*                                                                       *)
  FT_List_Add: procedure(
      list: FT_List;
      node: FT_ListNode); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_List_Insert                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Inserts an element at the head of a list.                          *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    list :: A pointer to parent list.                                  *)
  (*    node :: The node to insert.                                        *)
  (*                                                                       *)
  FT_List_Insert: procedure(
      list: FT_List;
      node: FT_ListNode); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_List_Remove                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Removes a node from a list.  This function doesn't check whether   *)
  (*    the node is in the list!                                           *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    node :: The node to remove.                                        *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    list :: A pointer to the parent list.                              *)
  (*                                                                       *)
  FT_List_Remove: procedure(
      list: FT_List;
      node: FT_ListNode); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_List_Up                                                         *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Moves a node to the head/top of a list.  Used to maintain LRU      *)
  (*    lists.                                                             *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    list :: A pointer to the parent list.                              *)
  (*    node :: The node to move.                                          *)
  (*                                                                       *)
  FT_List_Up: procedure(
      list: FT_List;
      node: FT_ListNode); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_List_Iterate                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Parses a list and calls a given iterator function on each element. *)
  (*    Note that parsing is stopped as soon as one of the iterator calls  *)
  (*    returns a non-zero value.                                          *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    list     :: A handle to the list.                                  *)
  (*    iterator :: An iterator function, called on each node of the list. *)
  (*    user     :: A user-supplied field which is passed as the second    *)
  (*                argument to the iterator.                              *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    The result (a FreeType error code) of the last iterator call.      *)
  (*                                                                       *)
  FT_List_Iterate: function(
      list: FT_List;
      iterator: FT_List_Iterator;
      user: Pointer): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_List_Finalize                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Destroys all elements in the list as well as the list itself.      *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    list    :: A handle to the list.                                   *)
  (*                                                                       *)
  (*    destroy :: A list destructor that will be applied to each element  *)
  (*               of the list.                                            *)
  (*                                                                       *)
  (*    memory  :: The current memory object which handles deallocation.   *)
  (*                                                                       *)
  (*    user    :: A user-supplied field which is passed as the last       *)
  (*               argument to the destructor.                             *)
  (*                                                                       *)
  FT_List_Finalize: procedure(
      list: FT_List;
      destroy: FT_List_Destructor;
      memory: FT_Memory;
      user: Pointer); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_New_Size                                                        *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Create a new size object from a given face object.                 *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    face :: A handle to a parent face object.                          *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    asize :: A handle to a new size object.                            *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    You need to call @FT_Activate_Size in order to select the new size *)
  (*    for upcoming calls to @FT_Set_Pixel_Sizes, @FT_Set_Char_Size,      *)
  (*    @FT_Load_Glyph, @FT_Load_Char, etc.                                *)
  (*                                                                       *)
  FT_New_Size: function(
      face: FT_Face;
      size: FT_Size_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Done_Size                                                       *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Discard a given size object.  Note that @FT_Done_Face              *)
  (*    automatically discards all size objects allocated with             *)
  (*    @FT_New_Size.                                                      *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    size :: A handle to a target size object.                          *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Done_Size: function(
      size: FT_Size): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Activate_Size                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Even though it is possible to create several size objects for a    *)
  (*    given face (see @FT_New_Size for details), functions like          *)
  (*    @FT_Load_Glyph or @FT_Load_Char only use the last-created one to   *)
  (*    determine the `current character pixel size'.                      *)
  (*                                                                       *)
  (*    This function can be used to `activate' a previously created size  *)
  (*    object.                                                            *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    size :: A handle to a target size object.                          *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    If `face' is the size's parent face object, this function changes  *)
  (*    the value of `face->size' to the input size handle.                *)
  (*                                                                       *)
  FT_Activate_Size: function(
      size: FT_Size): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Get_Renderer                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Retrieves the current renderer for a given glyph format.           *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    library :: A handle to the library object.                         *)
  (*                                                                       *)
  (*    format  :: The glyph format.                                       *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    A renderer handle.  0 if none found.                               *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    An error will be returned if a module already exists by that name, *)
  (*    or if the module requires a version of FreeType that is too great. *)
  (*                                                                       *)
  (*    To add a new renderer, simply use @FT_Add_Module.  To retrieve a   *)
  (*    renderer by its name, use @FT_Get_Module.                          *)
  (*                                                                       *)
  FT_Get_Renderer: function(
      library_: FT_Library;
      format: FT_Glyph_Format): FT_Renderer; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Set_Renderer                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Sets the current renderer to use, and set additional mode.         *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    library    :: A handle to the library object.                      *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    renderer   :: A handle to the renderer object.                     *)
  (*                                                                       *)
  (*    num_params :: The number of additional parameters.                 *)
  (*                                                                       *)
  (*    parameters :: Additional parameters.                               *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    In case of success, the renderer will be used to convert glyph     *)
  (*    images in the renderer's known format into bitmaps.                *)
  (*                                                                       *)
  (*    This doesn't change the current renderer for other formats.        *)
  (*                                                                       *)
  FT_Set_Renderer: function(
      library_: FT_Library;
      renderer: FT_Renderer;
      num_params: FT_UInt;
      parameters: FT_Parameter_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Add_Module                                                      *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Adds a new module to a given library instance.                     *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    library :: A handle to the library object.                         *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    clazz   :: A pointer to class descriptor for the module.           *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    An error will be returned if a module already exists by that name, *)
  (*    or if the module requires a version of FreeType that is too great. *)
  (*                                                                       *)
  FT_Add_Module: function(
      library_: FT_Library;
      clazz: FT_Module_Class_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Get_Module                                                      *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Finds a module by its name.                                        *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    library     :: A handle to the library object.                     *)
  (*                                                                       *)
  (*    module_name :: The module's name (as an ASCII string).             *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    A module handle.  0 if none was found.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    FreeType's internal modules aren't documented very well, and you   *)
  (*    should look up the source code for details.                        *)
  (*                                                                       *)
  FT_Get_Module: function(
      library_: FT_Library;
      module_name: pAnsiChar): FT_Module; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Remove_Module                                                   *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Removes a given module from a library instance.                    *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    library :: A handle to a library object.                           *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    module  :: A handle to a module object.                            *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    The module object is destroyed by the function in case of success. *)
  (*                                                                       *)
  FT_Remove_Module: function(
      library_: FT_Library;
      module: FT_Module): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_New_Library                                                     *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    This function is used to create a new FreeType library instance    *)
  (*    from a given memory object.  It is thus possible to use libraries  *)
  (*    with distinct memory allocators within the same program.           *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    memory   :: A handle to the original memory object.                *)
  (*                                                                       *)
  (* <Output>                                                              *)
  (*    alibrary :: A pointer to handle of a new library object.           *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_New_Library: function(
      memory: FT_Memory; 
      alibrary: FT_Library_ptr): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Done_Library                                                    *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Discards a given library object.  This closes all drivers and      *)
  (*    discards all resource objects.                                     *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    library :: A handle to the target library.                         *)
  (*                                                                       *)
  (* <Return>                                                              *)
  (*    FreeType error code.  0 means success.                             *)
  (*                                                                       *)
  FT_Done_Library: function(
      library_: FT_Library): FT_Error; cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Set_Debug_Hook                                                  *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Sets a debug hook function for debugging the interpreter of a font *)
  (*    format.                                                            *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    library    :: A handle to the library object.                      *)
  (*                                                                       *)
  (* <Input>                                                               *)
  (*    hook_index :: The index of the debug hook.  You should use the     *)
  (*                  values defined in `ftobjs.h', e.g.,                  *)
  (*                  `FT_DEBUG_HOOK_TRUETYPE'.                            *)
  (*                                                                       *)
  (*    debug_hook :: The function used to debug the interpreter.          *)
  (*                                                                       *)
  (* <Note>                                                                *)
  (*    Currently, four debug hook slots are available, but only two (for  *)
  (*    the TrueType and the Type 1 interpreter) are defined.              *)
  (*                                                                       *)
  (*    Since the internal headers of FreeType are no longer installed,    *)
  (*    the symbol `FT_DEBUG_HOOK_TRUETYPE' isn't available publicly.      *)
  (*    This is a bug and will be fixed in a forthcoming release.          *)
  (*                                                                       *)
  FT_Set_Debug_Hook: procedure(
      library_: FT_Library;        
      hook_index: FT_UInt;            
      debug_hook: FT_DebugHook_Func); cdecl;


  (*************************************************************************)
  (*                                                                       *)
  (* <Function>                                                            *)
  (*    FT_Add_Default_Modules                                             *)
  (*                                                                       *)
  (* <Description>                                                         *)
  (*    Adds the set of default drivers to a given library object.         *)
  (*    This is only useful when you create a library object with          *)
  (*    @FT_New_Library (usually to plug a custom memory manager).         *)
  (*                                                                       *)
  (* <InOut>                                                               *)
  (*    library :: A handle to a new library object.                       *)
  (*                                                                       *)
  FT_Add_Default_Modules: procedure(
      library_: FT_Library); cdecl;


  (**************************************************************************
   *
   *  @func:
   *     FT_Get_TrueType_Engine_Type
   *
   *  @description:
   *     Return a @FT_TrueTypeEngineType value to indicate which level of
   *     the TrueType virtual machine a given library instance supports.
   *
   *  @input:
   *     library ::
   *       A library instance.
   *
   *  @return:
   *     A value indicating which level is supported.
   *
   *  @since:
   *     2.2
   *
   *)
  FT_Get_TrueType_Engine_Type: function(
      library_: FT_Library): FT_TrueTypeEngineType; cdecl;


 (************************************************************************
  *
  * @function:
  *   FT_Stream_OpenLZW
  *
  * @description:
  *   Open a new stream to parse LZW-compressed font files.  This is
  *   mainly used to support the compressed `*.pcf.Z' fonts that come
  *   with XFree86.
  *
  * @input:
  *   stream :: The target embedding stream.
  *
  *   source :: The source stream.
  *
  * @return:
  *   FreeType error code.  0 means success.
  *
  * @note:
  *   The source stream must be opened _before_ calling this function.
  *
  *   Calling the internal function `FT_Stream_Close' on the new stream will
  *   *not* call `FT_Stream_Close' on the source stream.  None of the stream
  *   objects will be released to the heap.
  *
  *   The stream implementation is very basic and resets the decompression
  *   process each time seeking backwards is needed within the stream
  *
  *   In certain builds of the library, LZW compression recognition is
  *   automatically handled when calling @FT_New_Face or @FT_Open_Face.
  *   This means that if no font driver is capable of handling the raw
  *   compressed file, the library will try to open a LZW stream from it
  *   and re-open the face with it.
  *
  *   This function may return `FT_Err_Unimplemented_Feature' if your build
  *   of FreeType was not compiled with LZW support.
  *)
  FT_Stream_OpenLZW: function(
      stream: FT_Stream;
      source: FT_Stream): FT_Error; cdecl;




  (*
   * @macro:
   *   FT_LOAD_TARGET_MODE
   *
   * @description:
   *   Return the @FT_Render_Mode corresponding to a given
   *   @FT_LOAD_TARGET_XXX value.
   *)
  function FT_LOAD_TARGET_MODE(x: FT_Int): FT_Render_Mode;


  (*************************************************************************
   *
   * @macro:
   *   FT_HAS_HORIZONTAL( face )
   *
   * @description:
   *   A macro that returns true whenever a face object contains
   *   horizontal metrics (this is true for all font formats though).
   *
   * @also:
   *   @FT_HAS_VERTICAL can be used to check for vertical metrics.
   *
   *)
  function FT_HAS_HORIZONTAL(face: FT_Face): boolean;


  (*************************************************************************
   *
   * @macro:
   *   FT_HAS_VERTICAL( face )
   *
   * @description:
   *   A macro that returns true whenever a face object contains vertical
   *   metrics.
   *
   *)
  function FT_HAS_VERTICAL(face: FT_Face): boolean;


  (*************************************************************************
   *
   * @macro:
   *   FT_HAS_KERNING( face )
   *
   * @description:
   *   A macro that returns true whenever a face object contains kerning
   *   data that can be accessed with @FT_Get_Kerning.
   *
   *)
  function FT_HAS_KERNING(face: FT_Face): boolean;


  (*************************************************************************
   *
   * @macro:
   *   FT_IS_SCALABLE( face )
   *
   * @description:
   *   A macro that returns true whenever a face object contains a scalable
   *   font face (true for TrueType, Type 1, Type 42, CID, OpenType/CFF,
   *   and PFR font formats.
   *
   *)
  function FT_IS_SCALABLE(face: FT_Face): boolean;


  (*************************************************************************
   *
   * @macro:
   *   FT_IS_SFNT( face )
   *
   * @description:
   *   A macro that returns true whenever a face object contains a font
   *   whose format is based on the SFNT storage scheme.  This usually
   *   means: TrueType fonts, OpenType fonts, as well as SFNT-based embedded
   *   bitmap fonts.
   *
   *   If this macro is true, all functions defined in @FT_SFNT_NAMES_H and
   *   @FT_TRUETYPE_TABLES_H are available.
   *
   *)
  function FT_IS_SFNT(face: FT_Face): boolean;


  (*************************************************************************
   *
   * @macro:
   *   FT_IS_FIXED_WIDTH( face )
   *
   * @description:
   *   A macro that returns true whenever a face object contains a font face
   *   that contains fixed-width (or `monospace', `fixed-pitch', etc.)
   *   glyphs.
   *
   *)
  function FT_IS_FIXED_WIDTH(face: FT_Face): boolean;


  (*************************************************************************
   *
   * @macro:
   *   FT_HAS_FIXED_SIZES( face )
   *
   * @description:
   *   A macro that returns true whenever a face object contains some
   *   embedded bitmaps.  See the `available_sizes' field of the
   *   @FT_FaceRec structure.
   *
   *)
  function FT_HAS_FIXED_SIZES(face: FT_Face): boolean;


  (*************************************************************************
   *
   * @macro:
   *   FT_HAS_FAST_GLYPHS( face )
   *
   * @description:
   *   Deprecated.
   *
   *)
  function FT_HAS_FAST_GLYPHS(face: FT_Face): boolean;


  (*************************************************************************
   *
   * @macro:
   *   FT_HAS_GLYPH_NAMES( face )
   *
   * @description:
   *   A macro that returns true whenever a face object contains some glyph
   *   names that can be accessed through @FT_Get_Glyph_Name.
   *
   *)
  function FT_HAS_GLYPH_NAMES(face: FT_Face): boolean;


  (*************************************************************************
   *
   * @macro:
   *   FT_HAS_MULTIPLE_MASTERS( face )
   *
   * @description:
   *   A macro that returns true whenever a face object contains some
   *   multiple masters.  The functions provided by @FT_MULTIPLE_MASTERS_H
   *   are then available to choose the exact design you want.
   *
   *)
  function FT_HAS_MULTIPLE_MASTERS(face: FT_Face): boolean;


  
const
  {$ifdef win32}
    FREETYPE2_NAME = 'freetype6.dll';
  {$else}
    FREETYPE2_NAME = 'freetype.so.1' ----;
  {$endif}


  function init_FreeType2(FreeType2_Name: AnsiString = FREETYPE2_NAME): boolean;
  procedure quit_FreeType2;


implementation


var
  FreeType2_RefCount: Integer;

  {$ifdef win32}
    FreeType2_Handle: cardinal;
  {$else}
    FreeType2_Handle: pointer;
  {$endif}


// FreeType macros
function FT_LOAD_TARGET_MODE(x: FT_Int): FT_Render_Mode;
begin
  Result := FT_Render_Mode((x shr 16) and 15);
end;


function FT_HAS_HORIZONTAL(face: FT_Face): boolean;
begin
  result := face^.face_flags and FT_FACE_FLAG_HORIZONTAL > 0;
end;


function FT_HAS_VERTICAL(face: FT_Face): boolean;
begin
  result := face^.face_flags and FT_FACE_FLAG_VERTICAL > 0;
end;


function FT_HAS_KERNING(face: FT_Face): boolean;
begin
  result := face^.face_flags and FT_FACE_FLAG_KERNING > 0;
end;


function FT_IS_SCALABLE(face: FT_Face): boolean;
begin
  result := face^.face_flags and FT_FACE_FLAG_SCALABLE > 0;
end;


function FT_IS_SFNT(face: FT_Face): boolean;
begin
  result := face^.face_flags and FT_FACE_FLAG_SFNT > 0;
end;


function FT_IS_FIXED_WIDTH(face: FT_Face): boolean;
begin
  result := face^.face_flags and FT_FACE_FLAG_FIXED_WIDTH > 0;
end;


function FT_HAS_FIXED_SIZES(face: FT_Face): boolean;
begin
  result := face^.face_flags and FT_FACE_FLAG_FIXED_SIZES > 0;
end;


function FT_HAS_FAST_GLYPHS(face: FT_Face): boolean;
begin
  result := False;
end;


function FT_HAS_GLYPH_NAMES(face: FT_Face): boolean;
begin
  result := face^.face_flags and FT_FACE_FLAG_GLYPH_NAMES > 0;
end;


function FT_HAS_MULTIPLE_MASTERS(face: FT_Face): boolean;
begin
  result := face^.face_flags and FT_FACE_FLAG_MULTIPLE_MASTERS > 0;
end;



{$ifdef win32}
const
  Kernel32 = 'kernel32.dll';

  function LoadLibrary(lpFileName: pAnsiChar): LongWord; stdcall; external Kernel32 name 'LoadLibraryA';
  function FreeLibrary(hModule: LongWord): LongBool; stdcall; external Kernel32 name 'FreeLibrary';
  function GetProcAddress(hModule: LongWord; lpProcName: pAnsiChar): Pointer; stdcall; external Kernel32 name 'GetProcAddress';
{$else}
const
  libdl = {$IFDEF Linux} 'libdl.so.2'{$ELSE} 'c'{$ENDIF};

  RTLD_LAZY = $001;

  function dlopen(Name: pAnsiChar; Flags: LongInt): Pointer; cdecl; external libdl name 'dlopen';
  function dlclose(Lib: Pointer): LongInt; cdecl; external libdl name 'dlclose';
  function dlsym(Lib: Pointer; Name: pAnsiChar): Pointer; cdecl; external libdl name 'dlsym';
{$endif}



function GetProcAddr(Name: pAnsiChar): Pointer;
begin
  {$ifdef win32}
    GetProcAddr := GetProcAddress(FreeType2_Handle, Name);
  {$else}
    GetProcAddr := dlsym(FreeType2_Handle, Name);
  {$endif}
end;



function init_FreeType2(FreeType2_Name: AnsiString): boolean;
var
  Temp: boolean;
begin
  if (FreeType2_RefCount = 0) or (FreeType2_Handle = {$ifdef win32} 0 {$else} nil {$endif}) then begin
    if FreeType2_Handle = {$ifdef win32} 0 {$else} nil {$endif} then
      {$ifdef win32}
        FreeType2_Handle := LoadLibrary(pAnsiChar(FreeType2_Name));
      {$else}
        FreeType2_Handle := dlopen(pAnsiChar(FreeType2_Name), RTLD_LAZY);
      {$endif}

    // load function pointers
    if FreeType2_Handle <> {$ifdef win32} 0 {$else} nil {$endif} then begin
      FT_Init_FreeType := GetProcAddr('FT_Init_FreeType');
      FT_Done_FreeType := GetProcAddr('FT_Done_FreeType');
      FT_Library_SetLcdFilter := GetProcAddr('FT_Library_SetLcdFilter');  // since 2.3.0
      FT_New_Face := GetProcAddr('FT_New_Face');
      FT_New_Memory_Face := GetProcAddr('FT_New_Memory_Face');
      FT_Open_Face := GetProcAddr('FT_Open_Face');
      FT_Attach_File := GetProcAddr('FT_Attach_File');
      FT_Attach_Stream := GetProcAddr('FT_Attach_Stream');
      FT_Done_Face := GetProcAddr('FT_Done_Face');
      FT_Select_Size := GetProcAddr('FT_Select_Size');
      FT_Request_Size := GetProcAddr('FT_Request_Size');
      FT_Set_Char_Size := GetProcAddr('FT_Set_Char_Size');
      FT_Set_Pixel_Sizes := GetProcAddr('FT_Set_Pixel_Sizes');
      FT_Load_Glyph := GetProcAddr('FT_Load_Glyph');
      FT_Load_Char := GetProcAddr('FT_Load_Char');
      FT_Set_Transform := GetProcAddr('FT_Set_Transform');
      FT_Render_Glyph := GetProcAddr('FT_Render_Glyph');
      FT_Get_Kerning := GetProcAddr('FT_Get_Kerning');
      FT_Get_Track_Kerning := GetProcAddr('FT_Get_Track_Kerning');
      FT_Get_Glyph_Name := GetProcAddr('FT_Get_Glyph_Name');
      FT_Get_Postscript_Name := GetProcAddr('FT_Get_Postscript_Name');
      FT_Select_Charmap := GetProcAddr('FT_Select_Charmap');
      FT_Set_Charmap := GetProcAddr('FT_Set_Charmap');
      FT_Get_Charmap_Index := GetProcAddr('FT_Get_Charmap_Index');
      FT_Get_Char_Index := GetProcAddr('FT_Get_Char_Index');
      FT_Get_First_Char := GetProcAddr('FT_Get_First_Char');
      FT_Get_Next_Char := GetProcAddr('FT_Get_Next_Char');
      FT_Get_Name_Index := GetProcAddr('FT_Get_Name_Index');
      FT_Get_SubGlyph_Info := GetProcAddr('FT_Get_SubGlyph_Info');
      FT_MulDiv := GetProcAddr('FT_MulDiv');
      FT_MulFix := GetProcAddr('FT_MulFix');
      FT_DivFix := GetProcAddr('FT_DivFix');
      FT_RoundFix := GetProcAddr('FT_RoundFix');
      FT_CeilFix := GetProcAddr('FT_CeilFix');
      FT_FloorFix := GetProcAddr('FT_FloorFix');
      FT_Vector_Transform := GetProcAddr('FT_Vector_Transform');
      FT_Library_Version := GetProcAddr('FT_Library_Version');
      FT_Face_CheckTrueTypePatents := GetProcAddr('FT_Face_CheckTrueTypePatents');  // since 2.3.5
      FT_Face_SetUnpatentedHinting := GetProcAddr('FT_Face_SetUnpatentedHinting');  // since 2.3.5
      FT_Get_Glyph := GetProcAddr('FT_Get_Glyph');
      FT_Glyph_Copy := GetProcAddr('FT_Glyph_Copy');
      FT_Glyph_Transform := GetProcAddr('FT_Glyph_Transform');
      FT_Glyph_Get_CBox := GetProcAddr('FT_Glyph_Get_CBox');
      FT_Glyph_To_Bitmap := GetProcAddr('FT_Glyph_To_Bitmap');
      FT_Done_Glyph := GetProcAddr('FT_Done_Glyph');
      FT_Matrix_Multiply := GetProcAddr('FT_Matrix_Multiply');
      FT_Matrix_Invert := GetProcAddr('FT_Matrix_Invert');
      FT_Bitmap_New := GetProcAddr('FT_Bitmap_New');
      FT_Bitmap_Copy := GetProcAddr('FT_Bitmap_Copy');
      FT_Bitmap_Embolden := GetProcAddr('FT_Bitmap_Embolden');
      FT_Bitmap_Convert := GetProcAddr('FT_Bitmap_Convert');
      FT_Bitmap_Done := GetProcAddr('FT_Bitmap_Done');
      FT_Get_Gasp := GetProcAddr('FT_Get_Gasp');    // since 2.3.0
      FT_Stream_OpenGzip := GetProcAddr('FT_Stream_OpenGzip');
      FT_Outline_Decompose := GetProcAddr('FT_Outline_Decompose');
      FT_Outline_New := GetProcAddr('FT_Outline_New');
      FT_Outline_New_Internal := GetProcAddr('FT_Outline_New_Internal');
      FT_Outline_Done := GetProcAddr('FT_Outline_Done');
      FT_Outline_Done_Internal := GetProcAddr('FT_Outline_Done_Internal');
      FT_Outline_Check := GetProcAddr('FT_Outline_Check');
      FT_Outline_Get_BBox := GetProcAddr('FT_Outline_Get_BBox');
      FT_Outline_Get_CBox := GetProcAddr('FT_Outline_Get_CBox');
      FT_Outline_Translate := GetProcAddr('FT_Outline_Translate');
      FT_Outline_Copy := GetProcAddr('FT_Outline_Copy');
      FT_Outline_Transform := GetProcAddr('FT_Outline_Transform');
      FT_Outline_Embolden := GetProcAddr('FT_Outline_Embolden');
      FT_Outline_Reverse := GetProcAddr('FT_Outline_Reverse');
      FT_Outline_Get_Bitmap := GetProcAddr('FT_Outline_Get_Bitmap');
      FT_Outline_Render := GetProcAddr('FT_Outline_Render');
      FT_Outline_Get_Orientation := GetProcAddr('FT_Outline_Get_Orientation');
      FT_List_Find := GetProcAddr('FT_List_Find');
      FT_List_Add := GetProcAddr('FT_List_Add');
      FT_List_Insert := GetProcAddr('FT_List_Insert');
      FT_List_Remove := GetProcAddr('FT_List_Remove');
      FT_List_Up := GetProcAddr('FT_List_Up');
      FT_List_Iterate := GetProcAddr('FT_List_Iterate');
      FT_List_Finalize := GetProcAddr('FT_List_Finalize');
      FT_New_Size := GetProcAddr('FT_New_Size');
      FT_Done_Size := GetProcAddr('FT_Done_Size');
      FT_Activate_Size := GetProcAddr('FT_Activate_Size');
      FT_Get_Renderer := GetProcAddr('FT_Get_Renderer');
      FT_Set_Renderer := GetProcAddr('FT_Set_Renderer');
      FT_Add_Module := GetProcAddr('FT_Add_Module');
      FT_Get_Module := GetProcAddr('FT_Get_Module');
      FT_Remove_Module := GetProcAddr('FT_Remove_Module');
      FT_New_Library := GetProcAddr('FT_New_Library');
      FT_Done_Library := GetProcAddr('FT_Done_Library');
      FT_Set_Debug_Hook := GetProcAddr('FT_Set_Debug_Hook');
      FT_Add_Default_Modules := GetProcAddr('FT_Add_Default_Modules');
      FT_Get_TrueType_Engine_Type := GetProcAddr('FT_Get_TrueType_Engine_Type');    // since 2.2
      FT_Stream_OpenLZW := GetProcAddr('FT_Stream_OpenLZW');
    end;
  end;

  // check pointers
  Temp :=
    (FreeType2_Handle <> {$ifdef win32} 0 {$else} nil {$endif}) and
    (Addr(FT_Init_FreeType) <> nil) and
    (Addr(FT_Done_FreeType) <> nil) and
//    (Addr(FT_Library_SetLcdFilter) <> nil) and  // since 2.3.0
    (Addr(FT_New_Face) <> nil) and
    (Addr(FT_New_Memory_Face) <> nil) and
    (Addr(FT_Open_Face) <> nil) and
    (Addr(FT_Attach_File) <> nil) and
    (Addr(FT_Attach_Stream) <> nil) and
    (Addr(FT_Done_Face) <> nil) and
    (Addr(FT_Select_Size) <> nil) and
    (Addr(FT_Request_Size) <> nil) and
    (Addr(FT_Set_Char_Size) <> nil) and
    (Addr(FT_Set_Pixel_Sizes) <> nil) and
    (Addr(FT_Load_Glyph) <> nil) and
    (Addr(FT_Load_Char) <> nil) and
    (Addr(FT_Set_Transform) <> nil) and
    (Addr(FT_Render_Glyph) <> nil) and
    (Addr(FT_Get_Kerning) <> nil) and
    (Addr(FT_Get_Track_Kerning) <> nil) and
    (Addr(FT_Get_Glyph_Name) <> nil) and
    (Addr(FT_Get_Postscript_Name) <> nil) and
    (Addr(FT_Select_Charmap) <> nil) and
    (Addr(FT_Set_Charmap) <> nil) and
    (Addr(FT_Get_Charmap_Index) <> nil) and
    (Addr(FT_Get_Char_Index) <> nil) and
    (Addr(FT_Get_First_Char) <> nil) and
    (Addr(FT_Get_Next_Char) <> nil) and
    (Addr(FT_Get_Name_Index) <> nil) and
    (Addr(FT_Get_SubGlyph_Info) <> nil) and
    (Addr(FT_MulDiv) <> nil) and
    (Addr(FT_MulFix) <> nil) and
    (Addr(FT_DivFix) <> nil) and
    (Addr(FT_RoundFix) <> nil) and
    (Addr(FT_CeilFix) <> nil) and
    (Addr(FT_FloorFix) <> nil) and
    (Addr(FT_Vector_Transform) <> nil) and
    (Addr(FT_Library_Version) <> nil) and
//    (Addr(FT_Face_CheckTrueTypePatents) <> nil) and   // since 2.3.5
//    (Addr(FT_Face_SetUnpatentedHinting) <> nil) and   // since 2.3.5
    (Addr(FT_Get_Glyph) <> nil) and
    (Addr(FT_Glyph_Copy) <> nil) and
    (Addr(FT_Glyph_Transform) <> nil) and
    (Addr(FT_Glyph_Get_CBox) <> nil) and
    (Addr(FT_Glyph_To_Bitmap) <> nil) and
    (Addr(FT_Done_Glyph) <> nil) and
    (Addr(FT_Matrix_Multiply) <> nil) and
    (Addr(FT_Matrix_Invert) <> nil) and
    (Addr(FT_Bitmap_New) <> nil) and
    (Addr(FT_Bitmap_Copy) <> nil) and
    (Addr(FT_Bitmap_Embolden) <> nil) and
    (Addr(FT_Bitmap_Convert) <> nil) and
    (Addr(FT_Bitmap_Done) <> nil) and
//    (Addr(FT_Get_Gasp) <> nil) and    // since 2.3.0
    (Addr(FT_Stream_OpenGzip) <> nil) and
    (Addr(FT_Outline_Decompose) <> nil) and
    (Addr(FT_Outline_New) <> nil) and
    (Addr(FT_Outline_New_Internal) <> nil) and
    (Addr(FT_Outline_Done) <> nil) and
    (Addr(FT_Outline_Done_Internal) <> nil) and
    (Addr(FT_Outline_Check) <> nil) and
    (Addr(FT_Outline_Get_BBox) <> nil) and
    (Addr(FT_Outline_Get_CBox) <> nil) and
    (Addr(FT_Outline_Translate) <> nil) and
    (Addr(FT_Outline_Copy) <> nil) and
    (Addr(FT_Outline_Transform) <> nil) and
    (Addr(FT_Outline_Embolden) <> nil) and
    (Addr(FT_Outline_Reverse) <> nil) and
    (Addr(FT_Outline_Get_Bitmap) <> nil) and
    (Addr(FT_Outline_Render) <> nil) and
    (Addr(FT_Outline_Get_Orientation) <> nil) and
    (Addr(FT_List_Find) <> nil) and
    (Addr(FT_List_Add) <> nil) and
    (Addr(FT_List_Insert) <> nil) and
    (Addr(FT_List_Remove) <> nil) and
    (Addr(FT_List_Up) <> nil) and
    (Addr(FT_List_Iterate) <> nil) and
    (Addr(FT_List_Finalize) <> nil) and
    (Addr(FT_New_Size) <> nil) and
    (Addr(FT_Done_Size) <> nil) and
    (Addr(FT_Activate_Size) <> nil) and
    (Addr(FT_Get_Renderer) <> nil) and
    (Addr(FT_Set_Renderer) <> nil) and
    (Addr(FT_Add_Module) <> nil) and
    (Addr(FT_Get_Module) <> nil) and
    (Addr(FT_Remove_Module) <> nil) and
    (Addr(FT_New_Library) <> nil) and
    (Addr(FT_Done_Library) <> nil) and
    (Addr(FT_Set_Debug_Hook) <> nil) and
    (Addr(FT_Add_Default_Modules) <> nil) and
//    (Addr(FT_Get_TrueType_Engine_Type) <> nil) and    // since 2.2
    (Addr(FT_Stream_OpenLZW) <> nil) and

    True;

  if Temp then
    Inc(FreeType2_RefCount);

  Result := Temp;
end;


procedure quit_FreeType2;
begin
  Dec(FreeType2_RefCount);

  if FreeType2_RefCount <= 0 then begin
    if FreeType2_Handle <> {$ifdef win32} 0 {$else} nil {$endif} then begin
      {$ifdef win32}
        FreeLibrary(FreeType2_Handle);
        FreeType2_Handle := 0;
      {$else}
        dlclose(FreeType2_Handle);
        FreeType2_Handle := nil;
      {$endif}
    end;

    FT_Init_FreeType := nil;
    FT_Done_FreeType := nil;
    FT_Library_SetLcdFilter := nil;  // since 2.3.0
    FT_New_Face := nil;
    FT_New_Memory_Face := nil;
    FT_Open_Face := nil;
    FT_Attach_File := nil;
    FT_Attach_Stream := nil;
    FT_Done_Face := nil;
    FT_Select_Size := nil;
    FT_Request_Size := nil;
    FT_Set_Char_Size := nil;
    FT_Set_Pixel_Sizes := nil;
    FT_Load_Glyph := nil;
    FT_Load_Char := nil;
    FT_Set_Transform := nil;
    FT_Render_Glyph := nil;
    FT_Get_Kerning := nil;
    FT_Get_Track_Kerning := nil;
    FT_Get_Glyph_Name := nil;
    FT_Get_Postscript_Name := nil;
    FT_Select_Charmap := nil;
    FT_Set_Charmap := nil;
    FT_Get_Charmap_Index := nil;
    FT_Get_Char_Index := nil;
    FT_Get_First_Char := nil;
    FT_Get_Next_Char := nil;
    FT_Get_Name_Index := nil;
    FT_Get_SubGlyph_Info := nil;
    FT_MulDiv := nil;
    FT_MulFix := nil;
    FT_DivFix := nil;
    FT_RoundFix := nil;
    FT_CeilFix := nil;
    FT_FloorFix := nil;
    FT_Vector_Transform := nil;
    FT_Library_Version := nil;
    FT_Face_CheckTrueTypePatents := nil;  // since 2.3.5
    FT_Face_SetUnpatentedHinting := nil;  // since 2.3.5
    FT_Get_Glyph := nil;
    FT_Glyph_Copy := nil;
    FT_Glyph_Transform := nil;
    FT_Glyph_Get_CBox := nil;
    FT_Glyph_To_Bitmap := nil;
    FT_Done_Glyph := nil;
    FT_Matrix_Multiply := nil;
    FT_Matrix_Invert := nil;
    FT_Bitmap_New := nil;
    FT_Bitmap_Copy := nil;
    FT_Bitmap_Embolden := nil;
    FT_Bitmap_Convert := nil;
    FT_Bitmap_Done := nil;
    FT_Get_Gasp := nil;   // since 2.3.0
    FT_Stream_OpenGzip := nil;
    FT_Outline_Decompose := nil;
    FT_Outline_New := nil;
    FT_Outline_New_Internal := nil;
    FT_Outline_Done := nil;
    FT_Outline_Done_Internal := nil;
    FT_Outline_Check := nil;
    FT_Outline_Get_BBox := nil;
    FT_Outline_Get_CBox := nil;
    FT_Outline_Translate := nil;
    FT_Outline_Copy := nil;
    FT_Outline_Transform := nil;
    FT_Outline_Embolden := nil;
    FT_Outline_Reverse := nil;
    FT_Outline_Get_Bitmap := nil;
    FT_Outline_Render := nil;
    FT_Outline_Get_Orientation := nil;
    FT_List_Find := nil;
    FT_List_Add := nil;
    FT_List_Insert := nil;
    FT_List_Remove := nil;
    FT_List_Up := nil;
    FT_List_Iterate := nil;
    FT_List_Finalize := nil;
    FT_New_Size := nil;
    FT_Done_Size := nil;
    FT_Activate_Size := nil;
    FT_Get_Renderer := nil;
    FT_Set_Renderer := nil;
    FT_Add_Module := nil;
    FT_Get_Module := nil;
    FT_Remove_Module := nil;
    FT_New_Library := nil;
    FT_Done_Library := nil;
    FT_Set_Debug_Hook := nil;
    FT_Add_Default_Modules := nil;
    FT_Get_TrueType_Engine_Type := nil;   // since 2.2
    FT_Stream_OpenLZW := nil;
  end;
end;


end.
