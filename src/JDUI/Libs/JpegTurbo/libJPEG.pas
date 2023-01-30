Unit libJPEG;

{
  libJPEG Header conversion by Steffen Xonna. (21-03-2008)

  http://www.dev-center.de/index.php?cat=header&file=libjpeg


  Below you find an copy from the original libJPEG header.

  /*
  * jpeglib.h
  *
  * Copyright (C) 1991-1998, Thomas G. Lane.
  * This file is part of the Independent JPEG Group's software.
  * For conditions of distribution and use, see the accompanying README file.
  *
  * This file defines the application interface for the JPEG library.
  * Most applications using the library need only include this file,
  * and perhaps jerror.h if they want to know the exact error codes.
  */

}
Interface

Uses
  WinApi.Windows, Vcl.Dialogs, System.SysUtils,shareMem;
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

Type
  UINT8 = byte;
  UINT16 = word;
  JDIMENSION = cardinal;
  JCOEF = smallint;
  JOCTET = byte;
  JSAMPLE = byte;

  JOCTET_ptr = ^JOCTET;
  JSAMPLE_ptr = ^JSAMPLE;


  JBOOL = Byte; // Under windows they are only 1 byte large.

Const
  JPEG_LIB_VERSION = 62; { Version 6b }

  DCTSIZE = 8; { The basic DCT block is 8x8 samples }
  DCTSIZE2 = 64; { DCTSIZE squared; # of elements in a block }
  NUM_QUANT_TBLS = 4; { Quantization tables are numbered 0..3 }
  NUM_HUFF_TBLS = 4; { Huffman tables are numbered 0..3 }
  NUM_ARITH_TBLS = 16; { Arith-coding tables are numbered 0..15 }
  MAX_COMPS_IN_SCAN = 4; { JPEG limit on # of components in one scan }
  MAX_SAMP_FACTOR = 4; { JPEG limit on sampling factors }

  { Unfortunately, some bozo at Adobe saw no reason to be bound by the standard;
    the PostScript DCT filter can emit files with many more than 10 blocks/MCU.
    If you happen to run across such a file, you can up D_MAX_BLOCKS_IN_MCU
    to handle it.  We even let you do this from the jconfig.h file.  However,
    we strongly discourage changing C_MAX_BLOCKS_IN_MCU; just because Adobe
    sometimes emits noncompliant files doesn't mean you should too. }
  C_MAX_BLOCKS_IN_MCU = 10; { compressor's limit on blocks per MCU }
  D_MAX_BLOCKS_IN_MCU = 10; { decompressor's limit on blocks per MCU }

Type
  { Data structures for images (arrays of samples and of DCT coefficients).
    On 80x86 machines, the image arrays are too big for near pointers,
    but the pointer arrays can fit in near memory. }

  JSAMPROW = ^JSAMPLE; { ptr to one image row of pixel samples. }
  JSAMPARRAY = ^JSAMPROW; { ptr to some rows (a 2-D sample array) }
  JSAMPIMAGE = ^JSAMPARRAY; { a 3-D sample array: top index is color }

  JBLOCK = Array [1 .. DCTSIZE2] Of JCOEF; { one block of coefficients }
  JBLOCKROW = ^JBLOCK; { pointer to one row of coefficient blocks }
  JBLOCKARRAY = ^JBLOCKROW; { a 2-D array of coefficient blocks }
  JBLOCKIMAGE = ^JBLOCKARRAY; { a 3-D array of coefficient blocks }

  JCOEFPTR = ^JCOEF; { useful in a couple of places }

  JCOEFBITSPTR = ^JCOEFBITS;
  JCOEFBITS = Array [0 .. DCTSIZE2 - 1] Of integer;

  { Types for JPEG compression parameters and working tables. }

  // TODO: Möglicherweise betrifft dies auch die Rückgabewerte?

  { DCT coefficient quantization tables. }
  JQUANT_TBL = Record
    { This array gives the coefficient quantizers in natural array order
      (not the zigzag order in which they are stored in a JPEG DQT marker).
      CAUTION: IJG versions prior to v6a kept this array in zigzag order. }
    quantval: Array [0 .. DCTSIZE2 - 1] Of UINT16; { quantization step for each coefficient }

    { This field is used only during compression.  It's initialized FALSE when
      the table is created, and set TRUE when it's been output to the file.
      You could suppress output of a table by setting this to TRUE.
      (See jpeg_suppress_tables for an example.) }
    sent_table: JBOOL; { TRUE when table has been output }
  End;

  JQUANT_TBL_ptr = ^JQUANT_TBL;

  { Huffman coding tables. }
  JHUFF_TBL = Record
    { These two fields directly represent the contents of a JPEG DHT marker }
    bits: Array [0 .. 16] Of UINT8; { bits[k] = # of symbols with codes of }
    { length k bits; bits[0] is unused }
    huffval: Array [0 .. 255] Of UINT8; { The symbols, in order of incr code length }
    { This field is used only during compression.  It's initialized FALSE when
      the table is created, and set TRUE when it's been output to the file.
      You could suppress output of a table by setting this to TRUE.
      (See jpeg_suppress_tables for an example.) }
    sent_table: JBOOL; { TRUE when table has been output }
  End;

  JHUFF_TBL_ptr = ^JHUFF_TBL;

  { Basic info about one component (color channel). }
  jpeg_component_info_ptr = ^jpeg_component_info;

  jpeg_component_info = Record
    { These values are fixed over the whole image. }
    { For compression, they must be supplied by parameter setup; }
    { for decompression, they are read from the SOF marker. }
    component_id: integer; { identifier for this component (0..255) }
    component_index: integer; { its index in SOF or cinfo->comp_info[] }
    h_samp_factor: integer; { horizontal sampling factor (1..4) }
    v_samp_factor: integer; { vertical sampling factor (1..4) }
    quant_tbl_no: integer; { quantization table selector (0..3) }
    { These values may vary between scans. }
    { For compression, they must be supplied by parameter setup; }
    { for decompression, they are read from the SOS marker. }
    { The decompressor output side may not use these variables. }
    dc_tbl_no: integer; { DC entropy table selector (0..3) }
    ac_tbl_no: integer; { AC entropy table selector (0..3) }

    { Remaining fields should be treated as private by applications. }

    { These values are computed during compression or decompression startup: }
    { Component's size in DCT blocks.
      Any dummy blocks added to complete an MCU are not counted; therefore
      these values do not depend on whether a scan is interleaved or not. }
    width_in_blocks: JDIMENSION;
    height_in_blocks: JDIMENSION;
    { Size of a DCT block in samples.  Always DCTSIZE for compression.
      For decompression this is the size of the output from one DCT block,
      reflecting any scaling we choose to apply during the IDCT step.
      Values of 1,2,4,8 are likely to be supported.  Note that different
      components may receive different IDCT scalings. }
    DCT_scaled_size: integer;
    { The downsampled dimensions are the component's actual, unpadded number
      of samples at the main buffer (preprocessing/compression interface), thus
      downsampled_width = ceil(image_width * Hi/Hmax)
      and similarly for height.  For decompression, IDCT scaling is included, so
      downsampled_width = ceil(image_width * Hi/Hmax * DCT_scaled_size/DCTSIZE) }
    downsampled_width: JDIMENSION; { actual width in samples }
    downsampled_height: JDIMENSION; { actual height in samples }
    { This flag is used only for decompression.  In cases where some of the
      components will be ignored (eg grayscale output from YCbCr image),
      we can skip most computations for the unused components. }
    component_needed: JBOOL; { do we need the value of this component? }

    { These values are computed before starting a scan of the component. }
    { The decompressor output side may not use these variables. }
    MCU_width: integer; { number of blocks per MCU, horizontally }
    MCU_height: integer; { number of blocks per MCU, vertically }
    MCU_blocks: integer; { MCU_width * MCU_height }
    MCU_sample_width: integer; { MCU width in samples, MCU_width*DCT_scaled_size }
    last_col_width: integer; { # of non-dummy blocks across in last MCU }
    last_row_height: integer; { # of non-dummy blocks down in last MCU }

    { Saved quantization table for component; NULL if none yet saved.
      See jdinput.c comments about the need for this information.
      This field is currently used only for decompression. }
    quant_table: JQUANT_TBL_ptr;

    { Private per-component storage for DCT or IDCT subsystem. }
    dct_table: pointer;
  End;

  { The script for encoding a multiple-scan file is an array of these: }
  jpeg_scan_info_ptr = ^jpeg_scan_info;

  jpeg_scan_info = Record
    comps_in_scan: integer; { number of components encoded in this scan }
    component_index: Array [0 .. MAX_COMPS_IN_SCAN - 1] Of integer; { their SOF/comp_info[] indexes }
    Ss: integer;
    Se: integer; { progressive JPEG spectral selection parms }
    Ah: integer;
    Al: integer; { progressive JPEG successive approx. parms }
  End;

  { The decompressor can save APPn and COM markers in a list of these: }
  jpeg_saved_marker_ptr = ^jpeg_marker_struct;

  jpeg_marker_struct = Record
    next: jpeg_saved_marker_ptr; { next in list, or NULL * }
    marker: UINT8; { marker code: JPEG_COM, or JPEG_APP0+n }
    original_length: cardinal; { # bytes of data in the file }
    data_length: cardinal; { # bytes of data saved at data[] }
    data: JOCTET_ptr; { the data contained in the marker }
    { the marker length word is not counted in data_length or original_length }
  End;

  { Known color spaces. }
  J_COLOR_SPACE = (JCS_UNKNOWN, { error/unspecified }
    JCS_GRAYSCALE, { monochrome }
    JCS_RGB, { red/green/blue }
    JCS_YCbCr, { Y/Cb/Cr (also known as YUV) }
    JCS_CMYK, { C/M/Y/K }
    JCS_YCCK { Y/Cb/Cr/K }
    );

  { DCT/IDCT algorithm options. }
  J_DCT_METHOD = (JDCT_ISLOW, { slow but accurate integer algorithm }
    JDCT_IFAST, { faster, less accurate integer method }
    JDCT_FLOAT { floating-point: accurate, fast on fast HW }
    );

  J_DITHER_MODE = (JDITHER_NONE, { no dithering }
    JDITHER_ORDERED, { simple ordered dither }
    JDITHER_FS { Floyd-Steinberg error diffusion dither }
    );

Const
  JDCT_DEFAULT = JDCT_ISLOW;
  JDCT_FASTEST = JDCT_IFAST;

  JPOOL_PERMANENT = 0; { lasts until master record is destroyed }
  JPOOL_IMAGE = 1; { lasts until done with image/datastream }
  JPOOL_NUMPOOLS = 2;

  { Values of global_state field (jdapi.c has some dependencies on ordering!) }
  CSTATE_START = 100; { after create_compress }
  CSTATE_SCANNING = 101; { start_compress done, write_scanlines OK }
  CSTATE_RAW_OK = 102; { start_compress done, write_raw_data OK }
  CSTATE_WRCOEFS = 103; { jpeg_write_coefficients done }
  DSTATE_START = 200; { after create_decompress }
  DSTATE_INHEADER = 201; { reading header markers, no SOS yet }
  DSTATE_READY = 202; { found SOS, ready for start_decompress }
  DSTATE_PRELOAD = 203; { reading multiscan file in start_decompress }
  DSTATE_PRESCAN = 204; { performing dummy pass for 2-pass quant }
  DSTATE_SCANNING = 205; { start_decompress done, read_scanlines OK }
  DSTATE_RAW_OK = 206; { start_decompress done, read_raw_data OK }
  DSTATE_BUFIMAGE = 207; { expecting jpeg_start_output }
  DSTATE_BUFPOST = 208; { looking for SOS/EOI in jpeg_finish_output }
  DSTATE_RDCOEFS = 209; { reading file in jpeg_read_coefficients }
  DSTATE_STOPPING = 210; { looking for EOI in jpeg_finish_decompress }

Type
  // pointer forward
  jpeg_error_mgr_ptr = ^jpeg_error_mgr;
  jpeg_memory_mgr_ptr = ^jpeg_memory_mgr;
  jpeg_progress_mgr_ptr = ^jpeg_progress_mgr;
  jpeg_destination_mgr_ptr = ^jpeg_destination_mgr;
  jpeg_source_mgr_ptr = ^jpeg_source_mgr;

  // dummy types
  jvirt_sarray_control = Record
    dummy: longint;
  End;

  jvirt_sarray_ptr = ^jvirt_sarray_control;
  jvirt_sarray_ptr_ptr = ^jvirt_sarray_ptr;

  jvirt_barray_control = Record
    dummy: longint;
  End;

  jvirt_barray_ptr = ^jvirt_barray_control;
  jvirt_barray_ptr_ptr = ^jvirt_barray_ptr;

  jpeg_comp_master = Record
    dummy: longint;
  End;

  jpeg_comp_master_ptr = ^jpeg_comp_master;

  jpeg_c_main_controller = Record
    dummy: longint;
  End;

  jpeg_c_main_controller_ptr = ^jpeg_c_main_controller;

  jpeg_c_prep_controller = Record
    dummy: longint;
  End;

  jpeg_c_prep_controller_ptr = ^jpeg_c_prep_controller;

  jpeg_c_coef_controller = Record
    dummy: longint;
  End;

  jpeg_c_coef_controller_ptr = ^jpeg_c_coef_controller;

  jpeg_marker_writer = Record
    dummy: longint;
  End;

  jpeg_marker_writer_ptr = ^jpeg_marker_writer;

  jpeg_color_converter = Record
    dummy: longint;
  End;

  jpeg_color_converter_ptr = ^jpeg_color_converter;

  jpeg_downsampler = Record
    dummy: longint;
  End;

  jpeg_downsampler_ptr = ^jpeg_downsampler;

  jpeg_forward_dct = Record
    dummy: longint;
  End;

  jpeg_forward_dct_ptr = ^jpeg_forward_dct;

  jpeg_entropy_encoder = Record
    dummy: longint;
  End;

  jpeg_entropy_encoder_ptr = ^jpeg_entropy_encoder;

  jpeg_decomp_master = Record
    dummy: longint;
  End;

  jpeg_decomp_master_ptr = ^jpeg_decomp_master;

  jpeg_d_main_controller = Record
    dummy: longint;
  End;

  jpeg_d_main_controller_ptr = ^jpeg_d_main_controller;

  jpeg_d_coef_controller = Record
    dummy: longint;
  End;

  jpeg_d_coef_controller_ptr = ^jpeg_d_coef_controller;

  jpeg_d_post_controller = Record
    dummy: longint;
  End;

  jpeg_d_post_controller_ptr = ^jpeg_d_post_controller;

  jpeg_input_controller = Record
    dummy: longint;
  End;

  jpeg_input_controller_ptr = ^jpeg_input_controller;

  jpeg_marker_reader = Record
    dummy: longint;
  End;

  jpeg_marker_reader_ptr = ^jpeg_marker_reader;

  jpeg_entropy_decoder = Record
    dummy: longint;
  End;

  jpeg_entropy_decoder_ptr = ^jpeg_entropy_decoder;

  jpeg_inverse_dct = Record
    dummy: longint;
  End;

  jpeg_inverse_dct_ptr = ^jpeg_inverse_dct;

  jpeg_upsampler = Record
    dummy: longint;
  End;

  jpeg_upsampler_ptr = ^jpeg_upsampler;

  jpeg_color_deconverter = Record
    dummy: longint;
  End;

  jpeg_color_deconverter_ptr = ^jpeg_color_deconverter;

  jpeg_color_quantizer = Record
    dummy: longint;
  End;

  jpeg_color_quantizer_ptr = ^jpeg_color_quantizer;

  { Routines that are to be used by both halves of the library are declared
    to receive a pointer to this structure.  There are no actual instances of
    jpeg_common_struct, only of jpeg_compress_struct and jpeg_decompress_struct. }
  jpeg_common_struct = Record
    err: jpeg_error_mgr_ptr; { Error handler module }
    mem: jpeg_memory_mgr_ptr; { Memory manager module }
    progress: jpeg_progress_mgr_ptr; { Progress monitor, or NULL if none }
    client_data: pointer; { Available for use by application }
    is_decompressor: JBOOL; { So common code can tell which is which }
    global_state: integer; { For checking call sequence validity }
    { Additional fields follow in an actual jpeg_compress_struct or
      jpeg_decompress_struct.  All three structs must agree on these
      initial fields!  (This would be a lot cleaner in C++.) }
  End;

  j_common_ptr = ^jpeg_common_struct;
  j_compress_ptr = ^jpeg_compress_struct;
  j_decompress_ptr = ^jpeg_decompress_struct;

  { Master record for a compression instance }
  jpeg_compress_struct = Record
    err: jpeg_error_mgr_ptr; { Error handler module }
    mem: jpeg_memory_mgr_ptr; { Memory manager module }
    progress: jpeg_progress_mgr_ptr; { Progress monitor, or NULL if none }
    client_data: pointer; { Available for use by application }
    is_decompressor: JBOOL; { So common code can tell which is which }
    global_state: integer; { For checking call sequence validity }

    { Destination for compressed data }
    dest: jpeg_destination_mgr_ptr;

    { Description of source image --- these fields must be filled in by
      outer application before starting compression.  in_color_space must
      be correct before you can even call jpeg_set_defaults(). }

    image_width: JDIMENSION; { input image width }
    image_height: JDIMENSION; { input image height }
    input_components: integer; { # of color components in input image }
    in_color_space: J_COLOR_SPACE; { colorspace of input image }

    input_gamma: double; { image gamma of input image }

    { Compression parameters --- these fields must be set before calling
      jpeg_start_compress().  We recommend calling jpeg_set_defaults() to
      initialize everything to reasonable defaults, then changing anything
      the application specifically wants to change.  That way you won't get
      burnt when new parameters are added.  Also note that there are several
      helper routines to simplify changing parameters. }

    data_precision: integer; { bits of precision in image data }

    num_components: integer; { # of color components in JPEG image }
    jpeg_color_space: J_COLOR_SPACE; { colorspace of JPEG image }

    comp_info: jpeg_component_info_ptr;
    { comp_info[i] describes component that appears i'th in SOF }

    quant_tbl_ptrs: Array [0 .. NUM_QUANT_TBLS - 1] Of JQUANT_TBL_ptr;
    { ptrs to coefficient quantization tables, or NULL if not defined }

    dc_huff_tbl_ptrs: Array [0 .. NUM_HUFF_TBLS - 1] Of JHUFF_TBL_ptr;
    ac_huff_tbl_ptrs: Array [0 .. NUM_HUFF_TBLS - 1] Of JHUFF_TBL_ptr;
    { ptrs to Huffman coding tables, or NULL if not defined }

    arith_dc_L: Array [0 .. NUM_ARITH_TBLS - 1] Of UINT8; { L values for DC arith-coding tables }
    arith_dc_U: Array [0 .. NUM_ARITH_TBLS - 1] Of UINT8; { U values for DC arith-coding tables }
    arith_ac_K: Array [0 .. NUM_ARITH_TBLS - 1] Of UINT8; { Kx values for AC arith-coding tables }

    num_scans: integer; { # of entries in scan_info array }
    scan_info: jpeg_scan_info_ptr; { script for multi-scan file, or NULL }
    { The default value of scan_info is NULL, which causes a single-scan
      sequential JPEG file to be emitted.  To create a multi-scan file,
      set num_scans and scan_info to point to an array of scan definitions. }

    raw_data_in: JBOOL; { TRUE=caller supplies downsampled data }
    arith_code: JBOOL; { TRUE=arithmetic coding, FALSE=Huffman }
    optimize_coding: JBOOL; { TRUE=optimize entropy encoding parms }
    CCIR601_sampling: JBOOL; { TRUE=first samples are cosited }
    smoothing_factor: integer; { 1..100, or 0 for no input smoothing }
    dct_method: J_DCT_METHOD; { DCT algorithm selector }

    { The restart interval can be specified in absolute MCUs by setting
      restart_interval, or in MCU rows by setting restart_in_rows
      (in which case the correct restart_interval will be figured
      for each scan). }
    restart_interval: cardinal; { MCUs per restart, or 0 for no restart }
    restart_in_rows: integer; { if > 0, MCU rows per restart interval }

    { Parameters controlling emission of special markers. }

    write_JFIF_header: JBOOL; { should a JFIF marker be written? }
    JFIF_major_version: UINT8; { What to write for the JFIF version number }
    JFIF_minor_version: UINT8;
    { These three values are not used by the JPEG code, merely copied }
    { into the JFIF APP0 marker.  density_unit can be 0 for unknown, }
    { 1 for dots/inch, or 2 for dots/cm.  Note that the pixel aspect }
    { ratio is defined by X_density/Y_density even when density_unit=0. }
    density_unit: UINT8; { JFIF code for pixel size units }
    X_density: UINT16; { Horizontal pixel density }
    Y_density: UINT16; { Vertical pixel density }
    write_Adobe_marker: JBOOL; { should an Adobe marker be written? }

    { State variable: index of next scanline to be written to
      jpeg_write_scanlines().  Application may use this to control its
      processing loop, e.g., "while (next_scanline < image_height)". }

    next_scanline: JDIMENSION; { 0 .. image_height-1 }

    { Remaining fields are known throughout compressor, but generally
      should not be touched by a surrounding application. }

    { These fields are computed during compression startup }
    progressive_mode: JBOOL; { TRUE if scan script uses progressive mode }
    max_h_samp_factor: integer; { largest h_samp_factor }
    max_v_samp_factor: integer; { largest v_samp_factor }

    total_iMCU_rows: JDIMENSION; { # of iMCU rows to be input to coef ctlr }
    { The coefficient controller receives data in units of MCU rows as defined
      for fully interleaved scans (whether the JPEG file is interleaved or not).
      There are v_samp_factor * DCTSIZE sample rows of each component in an
      "iMCU" (interleaved MCU) row. }

    { These fields are valid during any one scan.
      They describe the components and MCUs actually appearing in the scan. }
    comps_in_scan: integer; { # of JPEG components in this scan }
    cur_comp_info: Array [0 .. MAX_COMPS_IN_SCAN - 1] Of jpeg_component_info_ptr;
    { *cur_comp_info[i] describes component that appears i'th in SOS }

    MCUs_per_row: JDIMENSION; { # of MCUs across the image }
    MCU_rows_in_scan: JDIMENSION; { # of MCU rows in the image }

    blocks_in_MCU: integer; { # of DCT blocks per MCU }
    MCU_membership: Array [0 .. C_MAX_BLOCKS_IN_MCU - 1] Of integer;
    { MCU_membership[i] is index in cur_comp_info of component owning }
    { i'th block in an MCU }

    Ss: integer;
    Se: integer;
    Ah: integer;
    Al: integer; { progressive JPEG parameters for scan }

    { Links to compression subobjects (methods and private variables of modules) }
    master: jpeg_comp_master_ptr;
    main: jpeg_c_main_controller_ptr;
    prep: jpeg_c_prep_controller_ptr;
    coef: jpeg_c_coef_controller_ptr;
    marker: jpeg_marker_writer_ptr;
    cconvert: jpeg_color_converter_ptr;
    downsample: jpeg_downsampler_ptr;
    fdct: jpeg_forward_dct_ptr;
    entropy: jpeg_entropy_encoder_ptr;

    script_space: jpeg_scan_info_ptr; { workspace for jpeg_simple_progression }
    script_space_size: integer;
  End;

  { Master record for a decompression instance }
  jpeg_decompress_struct = Record
    err: jpeg_error_mgr_ptr; { Error handler module }
    mem: jpeg_memory_mgr_ptr; { Memory manager module }
    progress: jpeg_progress_mgr_ptr; { Progress monitor, or NULL if none }
    client_data: pointer; { Available for use by application }
    is_decompressor: JBOOL; { So common code can tell which is which }

    global_state: Integer; { For checking call sequence validity }

    { Source of compressed data }
    src: jpeg_source_mgr_ptr;

    { Basic description of image --- filled in by jpeg_read_header(). }
    { Application may inspect these values to decide how to process image. }

    image_width: JDIMENSION; { nominal image width (from SOF marker) }
    image_height: JDIMENSION; { nominal image height }
    num_components: integer; { # of color components in JPEG image }
    jpeg_color_space: J_COLOR_SPACE; { colorspace of JPEG image }

    { Decompression processing parameters --- these fields must be set before
      calling jpeg_start_decompress().  Note that jpeg_read_header() initializes
      them to default values. }

    out_color_space: J_COLOR_SPACE; { colorspace for output }

    scale_num: cardinal;
    scale_denom: cardinal; { fraction by which to scale image }

    output_gamma: double; { image gamma wanted in output }

    buffered_image: JBOOL; { TRUE=multiple output passes }
    raw_data_out: JBOOL; { TRUE=downsampled data wanted }

    dct_method: J_DCT_METHOD; { IDCT algorithm selector }
    do_fancy_upsampling: JBOOL; { TRUE=apply fancy upsampling }
    do_block_smoothing: JBOOL; { TRUE=apply interblock smoothing }

    quantize_colors: JBOOL; { TRUE=colormapped output wanted }
    { the following are ignored if not quantize_colors: }
    dither_mode: J_DITHER_MODE; { type of color dithering to use }
    two_pass_quantize: JBOOL; { TRUE=use two-pass color quantization }
    desired_number_of_colors: Integer; { max # colors to use in created colormap }
    { these are significant only in buffered-image mode: }
    enable_1pass_quant: JBOOL; { enable future use of 1-pass quantizer }
    enable_external_quant: JBOOL; { enable future use of external colormap }
    enable_2pass_quant: JBOOL; { enable future use of 2-pass quantizer }
    { Description of actual output image that will be returned to application.
      These fields are computed by jpeg_start_decompress().
      You can also use jpeg_calc_output_dimensions() to determine these values
      in advance of calling jpeg_start_decompress(). }

    output_width: JDIMENSION; { scaled image width }
    output_height: JDIMENSION; { scaled image height }
    out_color_components: integer; { # of color components in out_color_space }
    output_components: integer; { # of color components returned }
    { output_components is 1 (a colormap index) when quantizing colors;
      otherwise it equals out_color_components. }

    rec_outbuf_height: integer; { min recommended height of scanline buffer }
    { If the buffer passed to jpeg_read_scanlines() is less than this many rows
      high, space and time will be wasted due to unnecessary data copying.
      Usually rec_outbuf_height will be 1 or 2, at most 4. }

    { When quantizing colors, the output colormap is described by these fields.
      The application can supply a colormap by setting colormap non-NULL before
      calling jpeg_start_decompress; otherwise a colormap is created during
      jpeg_start_decompress or jpeg_start_output.
      The map has out_color_components rows and actual_number_of_colors columns. }
    actual_number_of_colors: integer; { number of entries in use }
    colormap: JSAMPARRAY; { The color map as a 2-D pixel array }

    { State variables: these variables indicate the progress of decompression.
      The application may examine these but must not modify them. }

    { Row index of next scanline to be read from jpeg_read_scanlines().
      Application may use this to control its processing loop, e.g.,
      "while (output_scanline < output_height)". }
    output_scanline: JDIMENSION; { 0 .. output_height-1 }

    { Current input scan number and number of iMCU rows completed in scan.
      These indicate the progress of the decompressor input side. }
    input_scan_number: integer; { Number of SOS markers seen so far }
    input_iMCU_row: JDIMENSION; { Number of iMCU rows completed }

    { The "output scan number" is the notional scan being displayed by the
      output side.  The decompressor will not allow output scan/row number
      to get ahead of input scan/row, but it can fall arbitrarily far behind. }
    output_scan_number: integer; { Nominal scan number being displayed }
    output_iMCU_row: JDIMENSION; { Number of iMCU rows read }

    { Current progression status.  coef_bits[c][i] indicates the precision
      with which component c's DCT coefficient i (in zigzag order) is known.
      It is -1 when no data has yet been received, otherwise it is the point
      transform (shift) value for the most recent scan of the coefficient
      (thus, 0 at completion of the progression).
      This pointer is NULL when reading a non-progressive file. }
    coef_bits: JCOEFBITSPTR; { -1 or current Al value for each coef }

    { Internal JPEG parameters --- the application usually need not look at
      these fields.  Note that the decompressor output side may not use
      any parameters that can change between scans. }

    { Quantization and Huffman tables are carried forward across input
      datastreams when processing abbreviated JPEG datastreams. }

    quant_tbl_ptrs: Array [0 .. NUM_QUANT_TBLS - 1] Of JQUANT_TBL_ptr;
    { ptrs to coefficient quantization tables, or NULL if not defined }

    dc_huff_tbl_ptrs: Array [0 .. NUM_HUFF_TBLS - 1] Of JHUFF_TBL_ptr;
    ac_huff_tbl_ptrs: Array [0 .. NUM_HUFF_TBLS - 1] Of JHUFF_TBL_ptr;
    { ptrs to Huffman coding tables, or NULL if not defined }

    { These parameters are never carried across datastreams, since they
      are given in SOF/SOS markers or defined to be reset by SOI. }

    data_precision: integer; { bits of precision in image data }

    comp_info: jpeg_component_info_ptr;
    { comp_info[i] describes component that appears i'th in SOF }

    progressive_mode: JBOOL; { TRUE if SOFn specifies progressive mode }
    arith_code: JBOOL; { TRUE=arithmetic coding, FALSE=Huffman }

    arith_dc_L: Array [0 .. NUM_ARITH_TBLS - 1] Of UINT8; { L values for DC arith-coding tables }
    arith_dc_U: Array [0 .. NUM_ARITH_TBLS - 1] Of UINT8; { U values for DC arith-coding tables }
    arith_ac_K: Array [0 .. NUM_ARITH_TBLS - 1] Of UINT8; { Kx values for AC arith-coding tables }

    restart_interval: cardinal; { MCUs per restart interval, or 0 for no restart }

    { These fields record data obtained from optional markers recognized by
      the JPEG library. }
    saw_JFIF_marker: JBOOL; { TRUE iff a JFIF APP0 marker was found }
    { Data copied from JFIF marker; only valid if saw_JFIF_marker is TRUE: }
    JFIF_major_version: UINT8; { JFIF version number }
    JFIF_minor_version: UINT8;
    density_unit: UINT8; { JFIF code for pixel size units }
    X_density: UINT16; { Horizontal pixel density }
    Y_density: UINT16; { Vertical pixel density }
    saw_Adobe_marker: JBOOL; { TRUE iff an Adobe APP14 marker was found }
    Adobe_transform: UINT8; { Color transform code from Adobe marker }

    CCIR601_sampling: JBOOL; { TRUE=first samples are cosited }

    { Aside from the specific data retained from APPn markers known to the
      library, the uninterpreted contents of any or all APPn and COM markers
      can be saved in a list for examination by the application. }
    marker_list: jpeg_saved_marker_ptr; { Head of list of saved markers }

    { Remaining fields are known throughout decompressor, but generally
      should not be touched by a surrounding application. }

    { These fields are computed during decompression startup }
    max_h_samp_factor: integer; { largest h_samp_factor }
    max_v_samp_factor: integer; { largest v_samp_factor }

    min_DCT_scaled_size: integer; { smallest DCT_scaled_size of any component }

    total_iMCU_rows: JDIMENSION; { # of iMCU rows in image }
    { The coefficient controller's input and output progress is measured in
      units of "iMCU" (interleaved MCU) rows.  These are the same as MCU rows
      in fully interleaved JPEG scans, but are used whether the scan is
      interleaved or not.  We define an iMCU row as v_samp_factor DCT block
      rows of each component.  Therefore, the IDCT output contains
      v_samp_factor*DCT_scaled_size sample rows of a component per iMCU row. }

    sample_range_limit: JSAMPLE_ptr; { table for fast range-limiting }

    { These fields are valid during any one scan.
      They describe the components and MCUs actually appearing in the scan.
      Note that the decompressor output side must not use these fields. }
    comps_in_scan: integer; { # of JPEG components in this scan }
    cur_comp_info: Array [0 .. MAX_COMPS_IN_SCAN - 1] Of jpeg_component_info_ptr;
    { *cur_comp_info[i] describes component that appears i'th in SOS }

    MCUs_per_row: JDIMENSION; { # of MCUs across the image }
    MCU_rows_in_scan: JDIMENSION; { # of MCU rows in the image }

    blocks_in_MCU: integer; { # of DCT blocks per MCU }
    MCU_membership: Array [0 .. D_MAX_BLOCKS_IN_MCU - 1] Of integer;
    { MCU_membership[i] is index in cur_comp_info of component owning }
    { i'th block in an MCU }

    Ss: integer;
    Se: integer;
    Ah: integer;
    Al: integer; { progressive JPEG parameters for scan }

    { This field is shared between entropy decoder and marker parser.
      It is either zero or the code of a JPEG marker that has been
      read from the data source, but has not yet been processed. }
    unread_marker: integer;

    { Links to decompression subobjects (methods, private variables of modules) }
    master: jpeg_decomp_master_ptr;
    main: jpeg_d_main_controller_ptr;
    coef: jpeg_d_coef_controller_ptr;
    post: jpeg_d_post_controller_ptr;
    inputctl: jpeg_input_controller_ptr;
    marker: jpeg_marker_reader_ptr;
    entropy: jpeg_entropy_decoder_ptr;
    idct: jpeg_inverse_dct_ptr;
    upsample: jpeg_upsampler_ptr;
    cconvert: jpeg_color_deconverter_ptr;
    cquantize: jpeg_color_quantizer_ptr;
  End;

  { "Object" declarations for JPEG modules that may be supplied or called
    directly by the surrounding application.
    As with all objects in the JPEG library, these structs only define the
    publicly visible methods and state variables of a module.  Additional
    private fields may exist after the public ones. }

  { Error handler object }
  jpeg_error_mgr = Record
    { Error exit handler: does not return to caller }
    error_exit: Procedure(cinfo: j_common_ptr); Cdecl;
    { Conditionally emit a trace or warning message }
    emit_message: Procedure(cinfo: j_common_ptr; msg_level: integer); Cdecl;
    { Routine that actually outputs a trace or error message }
    output_message: Procedure(cinfo: j_common_ptr); Cdecl;
    { Format a message string for the most recent JPEG error or message }
    format_message: Procedure(cinfo: j_common_ptr; buffer: pchar); Cdecl;
    // #define JMSG_LENGTH_MAX  200	{ recommended size of format_message buffer }
    { Reset error state variables at start of a new image }
    reset_error_mgr: Procedure(cinfo: j_common_ptr); Cdecl;

    { The message ID code and any parameters are saved here.
      A message can have one string parameter or up to 8 int parameters. }
    msg_code: integer;
    msg_parm: Record Case integer Of 1: (i: Array [0 .. 7] Of integer);
    2: (s: Array [0 .. 79] Of char);
  End;

  { Standard state variables for error facility }

trace_level:
integer; { max msg_level that will be displayed }

{ For recoverable corrupt-data errors, we emit a warning message,
  but keep going unless emit_message chooses to abort.  emit_message
  should count warnings in num_warnings.  The surrounding application
  can check for bad data by seeing if num_warnings is nonzero at the
  end of processing. }
num_warnings:
longint; { number of corrupt-data warnings }

{ These fields point to the table(s) of error message strings.
  * An application can change the table pointer to switch to a different
  * message list (typically, to change the language in which errors are
  * reported).  Some applications may wish to add additional error codes
  * that will be handled by the JPEG library error mechanism; the second
  * table pointer is used for this purpose.
  *
  * First table includes all errors generated by JPEG library itself.
  * Error code 0 is reserved for a "no such error string" message.
}
// const char * const * jpeg_message_table; { Library errors }
jpeg_message_table:
pointer; { Library errors }
last_jpeg_message:
integer; { Table contains strings 0..last_jpeg_message }
{ Second table can be added by application (see cjpeg/djpeg for example).
  * It contains strings numbered first_addon_message..last_addon_message.
}
// const char * const * addon_message_table; { Non-library errors }
addon_message_table:
pointer; { Non-library errors }
first_addon_message:
integer; { code for first string in addon table }
last_addon_message:
integer; { code for last string in addon table }
End;

{ Progress monitor object }
jpeg_progress_mgr = Record progress_monitor:
Procedure(cinfo: j_common_ptr);
Cdecl;

pass_counter:
longint; { work units completed in this pass }
pass_limit:
longint; { total number of work units in this pass }
completed_passes:
integer; { passes completed so far }
total_passes:
integer; { total number of passes expected }
End;

{ Data destination object for compression }
jpeg_destination_mgr = Record next_output_byte: JOCTET_ptr; { => next byte to write in buffer }
free_in_buffer:
cardinal; { # of byte spaces remaining in buffer }

init_destination:

Procedure(cinfo: j_compress_ptr); Cdecl;
empty_output_buffer:
  Function(cinfo: j_compress_ptr): boolean; Cdecl;
term_destination:
    Procedure(cinfo: j_compress_ptr); Cdecl;
    End;

{ Data source object for decompression }
jpeg_source_mgr = Record next_input_byte: JOCTET_ptr; { => next byte to read from buffer }
bytes_in_buffer:
Integer; { # of bytes remaining in buffer }

init_source:
  Procedure(cinfo: j_decompress_ptr); Cdecl;
fill_input_buffer:
    Function(cinfo: j_decompress_ptr): boolean; Cdecl;
  skip_input_data:
      Procedure(cinfo: j_decompress_ptr; num_bytes: longint); Cdecl;
    resync_to_restart:
        Function(cinfo: j_decompress_ptr; desired: integer): boolean; Cdecl;
      term_source:
          Procedure(cinfo: j_decompress_ptr); Cdecl;
          End;

      { Memory manager object.
        Allocates "small" objects (a few K total), "large" objects (tens of K),
        and "really big" objects (virtual arrays with backing store if needed).
        The memory manager does not allow individual objects to be freed; rather,
        each created object is assigned to a pool, and whole pools can be freed
        at once.  This is faster and more convenient than remembering exactly what
        to free, especially where malloc()/free() are not too speedy.
        NB: alloc routines never return NULL.  They exit to error_exit if not
        successful. }

      jpeg_memory_mgr = Record
      { Method pointers }
        alloc_small:
      Function(cinfo: j_common_ptr; pool_id: integer; sizeofobject: cardinal): pointer;
      Cdecl;
    alloc_large:
        Function(cinfo: j_common_ptr; pool_id: integer; sizeofobject: cardinal): pointer; Cdecl;
      alloc_sarray:
          Function(cinfo: j_common_ptr; pool_id: integer; samplesperrow: JDIMENSION; numrows: JDIMENSION): JSAMPARRAY; Cdecl;
        alloc_barray:
            Function(cinfo: j_common_ptr; pool_id: integer; blocksperrow: JDIMENSION; numrows: JDIMENSION): JBLOCKARRAY; Cdecl;
          request_virt_sarray:
              Function(cinfo: j_common_ptr; pool_id: integer; pre_zero: boolean; samplesperrow: JDIMENSION; numrows: JDIMENSION; maxaccess: JDIMENSION)
                : jvirt_sarray_ptr; Cdecl;
            request_virt_barray:
                Function(cinfo: j_common_ptr; pool_id: integer; pre_zero: boolean; blocksperrow: JDIMENSION; numrows: JDIMENSION; maxaccess: JDIMENSION)
                  : jvirt_barray_ptr; Cdecl;
              realize_virt_arrays:
                  Procedure(cinfo: j_common_ptr); Cdecl;
                access_virt_sarray:
                    Function(cinfo: j_common_ptr; ptr: jvirt_sarray_ptr; start_row: JDIMENSION; num_rows: JDIMENSION; writable: boolean): JSAMPARRAY; Cdecl;
                  access_virt_barray:
                      Function(cinfo: j_common_ptr; ptr: jvirt_barray_ptr; start_row: JDIMENSION; num_rows: JDIMENSION; writable: boolean): JBLOCKARRAY; Cdecl;
                    free_pool:
                        Procedure(cinfo: j_common_ptr; pool_id: integer); Cdecl;
                      self_destruct:
                          Procedure(cinfo: j_common_ptr); Cdecl;

                          { Limit on memory allocation for this JPEG object.  (Note that this is
                            merely advisory, not a guaranteed maximum; it only affects the space
                            used for virtual-array buffers.)  May be changed by outer application
                            after creating the JPEG object. }
                        max_memory_to_use:
                          longint;

                          { Maximum allocation request accepted by alloc_large. }
                        max_alloc_chunk:
                          longint;
                          End;

                      Type
                        { Routine signature for application-supplied marker processing methods.
                          Need not pass marker code since it is stored in cinfo->unread_marker. }
                        jpeg_marker_parser_method = Function(cinfo: j_decompress_ptr): boolean; Cdecl;

                      Var
                        { Default error-management setup }
                        jpeg_std_error: Function(err: jpeg_error_mgr_ptr): jpeg_error_mgr_ptr; Cdecl;

                        { Initialization of JPEG compression objects.
                          jpeg_create_compress() and jpeg_create_decompress() are the exported
                          names that applications should call.  These expand to calls on
                          jpeg_CreateCompress and jpeg_CreateDecompress with additional information
                          passed for version mismatch checking.
                          NB: you must set up the error-manager BEFORE calling jpeg_create_xxx. }
                        jpeg_CreateCompress: Procedure(cinfo: j_compress_ptr; version: integer; structsize: cardinal); Cdecl;
                        jpeg_CreateDecompress: Procedure(cinfo: j_decompress_ptr; version: integer; structsize: cardinal); Cdecl;

                        { Destruction of JPEG compression objects }
                        jpeg_destroy_compress: Procedure(cinfo: j_compress_ptr); Cdecl;
                        jpeg_destroy_decompress: Procedure(cinfo: j_decompress_ptr); Cdecl;

                        { Standard data source and destination managers: stdio streams. }
                        { Caller is responsible for opening the file before and closing after. }
                        // jpeg_stdio_dest: procedure(cinfo: j_compress_ptr; FILE * outfile); cdecl;
                        // jpeg_stdio_src: procedure(cinfo: j_decompress_ptr; FILE * infile); cdecl;

                        { Default parameter setup for compression }
                        jpeg_set_defaults: Procedure(cinfo: j_compress_ptr); Cdecl;

                        { Compression parameter setup aids }
                        jpeg_set_colorspace: Procedure(cinfo: j_common_ptr; colorspace: J_COLOR_SPACE); Cdecl;
                        jpeg_default_colorspace: Procedure(cinfo: j_common_ptr); Cdecl;
                        jpeg_set_quality: Procedure(cinfo: j_common_ptr; quality: integer; force_baseline: boolean); Cdecl;
                        jpeg_set_linear_quality: Procedure(cinfo: j_common_ptr; scale_factor: integer; force_baseline: boolean); Cdecl;
                        jpeg_add_quant_table: Procedure(cinfo: j_common_ptr; which_tbl: integer; Const basic_table: pcardinal; scale_factor: integer;
                          force_baseline: boolean); Cdecl;
                        jpeg_quality_scaling: Function(quality: integer): integer; Cdecl;
                        jpeg_simple_progression: Procedure(cinfo: j_common_ptr); Cdecl;
                        jpeg_suppress_tables: Procedure(cinfo: j_common_ptr; suppress: boolean); Cdecl;
                        jpeg_alloc_quant_table: Function(cinfo: j_common_ptr): JQUANT_TBL_ptr; Cdecl;
                        jpeg_alloc_huff_table: Function(cinfo: j_common_ptr): JHUFF_TBL_ptr; Cdecl;

                        { Main entry points for compression }
                        jpeg_start_compress: Procedure(cinfo: j_compress_ptr; write_all_tables: boolean); Cdecl;
                        jpeg_write_scanlines: Function(cinfo: j_compress_ptr; scanlines: JSAMPARRAY; num_lines: JDIMENSION): JDIMENSION; Cdecl;
                        jpeg_finish_compress: Procedure(cinfo: j_compress_ptr); Cdecl;

                        { Replaces jpeg_write_scanlines when writing raw downsampled data. }
                        jpeg_write_raw_data: Function(cinfo: j_compress_ptr; data: JSAMPIMAGE; num_lines: JDIMENSION): JDIMENSION; Cdecl;

                        { Write a special marker.  See libjpeg.doc concerning safe usage. }
                        jpeg_write_marker: Procedure(cinfo: j_compress_ptr; marker: integer; Const dataptr: JOCTET_ptr; datalen: cardinal); Cdecl;
                        { Same, but piecemeal. }
                        jpeg_write_m_header: Procedure(cinfo: j_compress_ptr; marker: integer; datalen: cardinal); Cdecl;
                        jpeg_write_m_byte: Procedure(cinfo: j_compress_ptr; val: integer); Cdecl;

                        { Alternate compression function: just write an abbreviated table file }
                        jpeg_write_tables: Procedure(cinfo: j_compress_ptr); Cdecl;

                        { Decompression startup: read start of JPEG datastream to see what's there }
                        jpeg_read_header: Function(cinfo: j_decompress_ptr; require_image: boolean): integer; Cdecl;

                      Const
                        { Return value is one of: }
                        JPEG_SUSPENDED = 0; { Suspended due to lack of input data }
                        JPEG_HEADER_OK = 1; { Found valid image datastream }
                        JPEG_HEADER_TABLES_ONLY = 2; { Found valid table-specs-only datastream }
                        { If you pass require_image = TRUE (normal case), you need not check for
                          a TABLES_ONLY return code; an abbreviated file will cause an error exit.
                          JPEG_SUSPENDED is only possible if you use a data source module that can
                          give a suspension return (the stdio source module doesn't). }

                      Var
                        { Main entry points for decompression }
                        jpeg_start_decompress: Function(cinfo: j_decompress_ptr): boolean; Cdecl;
                        jpeg_read_scanlines: Function(cinfo: j_decompress_ptr; scanlines: JSAMPARRAY; max_lines: JDIMENSION): JDIMENSION; Cdecl;
                        jpeg_finish_decompress: Function(cinfo: j_decompress_ptr): boolean; Cdecl;

                        { Replaces jpeg_read_scanlines when reading raw downsampled data. }
                        jpeg_read_raw_data: Function(cinfo: j_decompress_ptr; data: JSAMPIMAGE; max_lines: JDIMENSION): JDIMENSION; Cdecl;

                        { Additional entry points for buffered-image mode. }
                        jpeg_has_multiple_scans: Function(cinfo: j_decompress_ptr): boolean; Cdecl;
                        jpeg_start_output: Function(cinfo: j_decompress_ptr; scan_number: integer): boolean; Cdecl;
                        jpeg_finish_output: Function(cinfo: j_decompress_ptr): boolean; Cdecl;
                        jpeg_input_complete: Function(cinfo: j_decompress_ptr): boolean; Cdecl;
                        jpeg_new_colormap: Procedure(cinfo: j_decompress_ptr); Cdecl;
                        jpeg_consume_input: Function(cinfo: j_decompress_ptr): integer; Cdecl;

                      Const
                        { Return value is one of: }
                        { #define JPEG_SUSPENDED	0    Suspended due to lack of input data }
                        JPEG_REACHED_SOS = 1; { Reached start of new scan }
                        JPEG_REACHED_EOI = 2; { Reached end of image }
                        JPEG_ROW_COMPLETED = 3; { Completed one iMCU row }
                        JPEG_SCAN_COMPLETED = 4; { Completed last iMCU row of a scan }

                      Var
                        { Precalculate output dimensions for current decompression parameters. }
                        jpeg_calc_output_dimensions: Procedure(cinfo: j_decompress_ptr); Cdecl;

                        { Control saving of COM and APPn markers into marker_list. }
                        jpeg_save_markers: Procedure(cinfo: j_decompress_ptr; marker_code: integer; length_limit: cardinal); Cdecl;

                        { Install a special processing method for COM or APPn markers. }
                        jpeg_set_marker_processor: Procedure(cinfo: j_decompress_ptr; marker_code: integer; routine: jpeg_marker_parser_method); Cdecl;

                        { Read or write raw DCT coefficients --- useful for lossless transcoding. }
                        jpeg_read_coefficients: Function(cinfo: j_decompress_ptr): jvirt_barray_ptr_ptr; Cdecl;
                        jpeg_write_coefficients: Procedure(cinfo: j_compress_ptr; coef_arrays: jvirt_barray_ptr_ptr); Cdecl;
                        jpeg_copy_critical_parameters: Procedure(srcinfo: j_decompress_ptr; dstinfo: j_compress_ptr); Cdecl;

                        { If you choose to abort compression or decompression before completing
                          jpeg_finish_(de)compress, then you need to clean up to release memory,
                          temporary files, etc.  You can just call jpeg_destroy_(de)compress
                          if you're done with the JPEG object, but if you want to clean it up and
                          reuse it, call this: }
                        jpeg_abort_compress: Procedure(cinfo: j_compress_ptr); Cdecl;
                        jpeg_abort_decompress: Procedure(cinfo: j_decompress_ptr); Cdecl;

                        { Generic versions of jpeg_abort and jpeg_destroy that work on either
                          flavor of JPEG object.  These may be more convenient in some places. }
                        jpeg_abort: Procedure(cinfo: j_common_ptr); Cdecl;
                        jpeg_destroy: Procedure(cinfo: j_common_ptr); Cdecl;

                        { Default restart-marker-resync procedure for use by data source modules }
                        jpeg_resync_to_restart: Function(cinfo: j_decompress_ptr; desired: integer): boolean; Cdecl;

                        { These marker codes are exported since applications and data source modules
                          are likely to want to use them. }

                      Const
                        JPEG_RST0 = $D0; { RST0 marker code }
                        JPEG_EOI = $D9; { EOI marker code }
                        JPEG_APP0 = $E0; { APP0 marker code }
                        JPEG_COM = $FE; { COM marker code }

                        Function init_libJPEG(): boolean;
                          Procedure quit_libJPEG;

                            Procedure jpeg_create_compress(cinfo: j_compress_ptr);
                              Procedure jpeg_create_decompress(cinfo: j_decompress_ptr);

Implementation

Var
  libJPEG_RefCount: Integer;
  libJPEG_Handle: THandle;

Procedure jpeg_create_compress(cinfo: j_compress_ptr);
Begin
  jpeg_CreateCompress(cinfo, JPEG_LIB_VERSION, sizeof(jpeg_compress_struct));
End;

Procedure jpeg_create_decompress(cinfo: j_decompress_ptr);
Begin
  jpeg_CreateDecompress(cinfo, JPEG_LIB_VERSION, sizeof(jpeg_decompress_struct));
End;

Function init_libJPEG(): boolean;
Var
  Temp: Boolean;
Begin
  If (libJPEG_RefCount = 0) Or (libJPEG_Handle = 0) Then
  Begin
    If libJPEG_Handle = 0 Then
{$IFDEF win32}
      libJPEG_Handle := LoadLibrary('jpeg62_32.dll');
{$ELSE}
      libJPEG_Handle := LoadLibrary('jpeg62_64.dll');
{$ENDIF}
    If libJPEG_Handle <> 0 Then
    Begin
      @jpeg_std_error := GetProcAddress(libJPEG_Handle, 'jpeg_std_error');
      @jpeg_CreateCompress := GetProcAddress(libJPEG_Handle, 'jpeg_CreateCompress');
      @jpeg_CreateDecompress := GetProcAddress(libJPEG_Handle, 'jpeg_CreateDecompress');
      @jpeg_destroy_compress := GetProcAddress(libJPEG_Handle, 'jpeg_destroy_compress');
      @jpeg_destroy_decompress := GetProcAddress(libJPEG_Handle, 'jpeg_destroy_decompress');
      @jpeg_set_defaults := GetProcAddress(libJPEG_Handle, 'jpeg_set_defaults');
      @jpeg_set_colorspace := GetProcAddress(libJPEG_Handle, 'jpeg_set_colorspace');
      @jpeg_default_colorspace := GetProcAddress(libJPEG_Handle, 'jpeg_default_colorspace');
      @jpeg_set_quality := GetProcAddress(libJPEG_Handle, 'jpeg_set_quality');
      @jpeg_set_linear_quality := GetProcAddress(libJPEG_Handle, 'jpeg_set_linear_quality');
      @jpeg_add_quant_table := GetProcAddress(libJPEG_Handle, 'jpeg_add_quant_table');
      @jpeg_quality_scaling := GetProcAddress(libJPEG_Handle, 'jpeg_quality_scaling');
      @jpeg_simple_progression := GetProcAddress(libJPEG_Handle, 'jpeg_simple_progression');
      @jpeg_suppress_tables := GetProcAddress(libJPEG_Handle, 'jpeg_suppress_tables');
      @jpeg_alloc_quant_table := GetProcAddress(libJPEG_Handle, 'jpeg_alloc_quant_table');
      @jpeg_alloc_huff_table := GetProcAddress(libJPEG_Handle, 'jpeg_alloc_huff_table');
      @jpeg_start_compress := GetProcAddress(libJPEG_Handle, 'jpeg_start_compress');
      @jpeg_write_scanlines := GetProcAddress(libJPEG_Handle, 'jpeg_write_scanlines');
      @jpeg_finish_compress := GetProcAddress(libJPEG_Handle, 'jpeg_finish_compress');
      @jpeg_write_raw_data := GetProcAddress(libJPEG_Handle, 'jpeg_write_raw_data');
      @jpeg_write_marker := GetProcAddress(libJPEG_Handle, 'jpeg_write_marker');
      @jpeg_write_m_header := GetProcAddress(libJPEG_Handle, 'jpeg_write_m_header');
      @jpeg_write_m_byte := GetProcAddress(libJPEG_Handle, 'jpeg_write_m_byte');
      @jpeg_write_tables := GetProcAddress(libJPEG_Handle, 'jpeg_write_tables');
      @jpeg_read_header := GetProcAddress(libJPEG_Handle, 'jpeg_read_header');
      @jpeg_start_decompress := GetProcAddress(libJPEG_Handle, 'jpeg_start_decompress');
      @jpeg_read_scanlines := GetProcAddress(libJPEG_Handle, 'jpeg_read_scanlines');
      @jpeg_finish_decompress := GetProcAddress(libJPEG_Handle, 'jpeg_finish_decompress');
      @jpeg_read_raw_data := GetProcAddress(libJPEG_Handle, 'jpeg_read_raw_data');
      @jpeg_has_multiple_scans := GetProcAddress(libJPEG_Handle, 'jpeg_has_multiple_scans');
      @jpeg_start_output := GetProcAddress(libJPEG_Handle, 'jpeg_start_output');
      @jpeg_finish_output := GetProcAddress(libJPEG_Handle, 'jpeg_finish_output');
      @jpeg_input_complete := GetProcAddress(libJPEG_Handle, 'jpeg_input_complete');
      @jpeg_new_colormap := GetProcAddress(libJPEG_Handle, 'jpeg_new_colormap');
      @jpeg_consume_input := GetProcAddress(libJPEG_Handle, 'jpeg_consume_input');
      @jpeg_calc_output_dimensions := GetProcAddress(libJPEG_Handle, 'jpeg_calc_output_dimensions');
      @jpeg_save_markers := GetProcAddress(libJPEG_Handle, 'jpeg_save_markers');
      @jpeg_set_marker_processor := GetProcAddress(libJPEG_Handle, 'jpeg_set_marker_processor');
      @jpeg_read_coefficients := GetProcAddress(libJPEG_Handle, 'jpeg_read_coefficients');
      @jpeg_write_coefficients := GetProcAddress(libJPEG_Handle, 'jpeg_write_coefficients');
      @jpeg_copy_critical_parameters := GetProcAddress(libJPEG_Handle, 'jpeg_copy_critical_parameters');
      @jpeg_abort_compress := GetProcAddress(libJPEG_Handle, 'jpeg_abort_compress');
      @jpeg_abort_decompress := GetProcAddress(libJPEG_Handle, 'jpeg_abort_decompress');
      @jpeg_abort := GetProcAddress(libJPEG_Handle, 'jpeg_abort');
      @jpeg_destroy := GetProcAddress(libJPEG_Handle, 'jpeg_destroy');
      @jpeg_resync_to_restart := GetProcAddress(libJPEG_Handle, 'jpeg_resync_to_restart');
    End;
  End;

  Temp := (Addr(jpeg_std_error) <> Nil) Or (Addr(jpeg_CreateCompress) <> Nil) Or (Addr(jpeg_CreateDecompress) <> Nil) Or (Addr(jpeg_destroy_compress) <> Nil) Or
    (Addr(jpeg_destroy_decompress) <> Nil) Or (Addr(jpeg_set_defaults) <> Nil) Or (Addr(jpeg_set_colorspace) <> Nil) Or (Addr(jpeg_default_colorspace) <> Nil)
    Or (Addr(jpeg_set_quality) <> Nil) Or (Addr(jpeg_set_linear_quality) <> Nil) Or (Addr(jpeg_add_quant_table) <> Nil) Or (Addr(jpeg_quality_scaling) <> Nil)
    Or (Addr(jpeg_simple_progression) <> Nil) Or (Addr(jpeg_suppress_tables) <> Nil) Or (Addr(jpeg_alloc_quant_table) <> Nil) Or
    (Addr(jpeg_alloc_huff_table) <> Nil) Or (Addr(jpeg_start_compress) <> Nil) Or (Addr(jpeg_write_scanlines) <> Nil) Or (Addr(jpeg_finish_compress) <> Nil) Or
    (Addr(jpeg_write_raw_data) <> Nil) Or (Addr(jpeg_write_marker) <> Nil) Or (Addr(jpeg_write_m_header) <> Nil) Or (Addr(jpeg_write_m_byte) <> Nil) Or
    (Addr(jpeg_write_tables) <> Nil) Or (Addr(jpeg_read_header) <> Nil) Or (Addr(jpeg_start_decompress) <> Nil) Or (Addr(jpeg_read_scanlines) <> Nil) Or
    (Addr(jpeg_finish_decompress) <> Nil) Or (Addr(jpeg_read_raw_data) <> Nil) Or (Addr(jpeg_has_multiple_scans) <> Nil) Or (Addr(jpeg_start_output) <> Nil) Or
    (Addr(jpeg_finish_output) <> Nil) Or (Addr(jpeg_input_complete) <> Nil) Or (Addr(jpeg_new_colormap) <> Nil) Or (Addr(jpeg_consume_input) <> Nil) Or
    (Addr(jpeg_calc_output_dimensions) <> Nil) Or (Addr(jpeg_save_markers) <> Nil) Or (Addr(jpeg_set_marker_processor) <> Nil) Or
    (Addr(jpeg_read_coefficients) <> Nil) Or (Addr(jpeg_write_coefficients) <> Nil) Or (Addr(jpeg_copy_critical_parameters) <> Nil) Or
    (Addr(jpeg_abort_compress) <> Nil) Or (Addr(jpeg_abort_decompress) <> Nil) Or (Addr(jpeg_abort) <> Nil) Or (Addr(jpeg_destroy) <> Nil) Or
    (Addr(jpeg_resync_to_restart) <> Nil);

  If Temp Then
    Inc(libJPEG_RefCount);

  Result := Temp;
End;

Procedure quit_libJPEG;
Begin
  Dec(libJPEG_RefCount);

  If libJPEG_RefCount <= 0 Then
  Begin
    If libJPEG_Handle <> 0 Then
    Begin
      FreeLibrary(libJPEG_Handle);
      libJPEG_Handle := 0;
    End;
    jpeg_std_error := Nil;
    jpeg_CreateCompress := Nil;
    jpeg_CreateDecompress := Nil;
    jpeg_destroy_compress := Nil;
    jpeg_destroy_decompress := Nil;
    jpeg_set_defaults := Nil;
    jpeg_set_colorspace := Nil;
    jpeg_default_colorspace := Nil;
    jpeg_set_quality := Nil;
    jpeg_set_linear_quality := Nil;
    jpeg_add_quant_table := Nil;
    jpeg_quality_scaling := Nil;
    jpeg_simple_progression := Nil;
    jpeg_suppress_tables := Nil;
    jpeg_alloc_quant_table := Nil;
    jpeg_alloc_huff_table := Nil;
    jpeg_start_compress := Nil;
    jpeg_write_scanlines := Nil;
    jpeg_finish_compress := Nil;
    jpeg_write_raw_data := Nil;
    jpeg_write_marker := Nil;
    jpeg_write_m_header := Nil;
    jpeg_write_m_byte := Nil;
    jpeg_write_tables := Nil;
    jpeg_read_header := Nil;
    jpeg_start_decompress := Nil;
    jpeg_read_scanlines := Nil;
    jpeg_finish_decompress := Nil;
    jpeg_read_raw_data := Nil;
    jpeg_has_multiple_scans := Nil;
    jpeg_start_output := Nil;
    jpeg_finish_output := Nil;
    jpeg_input_complete := Nil;
    jpeg_new_colormap := Nil;
    jpeg_consume_input := Nil;
    jpeg_calc_output_dimensions := Nil;
    jpeg_save_markers := Nil;
    jpeg_set_marker_processor := Nil;
    jpeg_read_coefficients := Nil;
    jpeg_write_coefficients := Nil;
    jpeg_copy_critical_parameters := Nil;
    jpeg_abort_compress := Nil;
    jpeg_abort_decompress := Nil;
    jpeg_abort := Nil;
    jpeg_destroy := Nil;
    jpeg_resync_to_restart := Nil;
  End;
End;

End.
