Vectorial Polygon Rasterizer for Graphics32 1.23
================================================

Description:
 A new polygon rasterizer that computes exact coverage values in floating point
 precision. The rendering quality is on par with other high quality rasterizers,
 such as AGG and FreeType.

Homepage:
 <http://vpr.sourceforge.net>
 
Advantages:
 - Coverage values are computed with exact sub-pixel accuracy;
 - Support for rectangular clipping;
 - Support for non-zero and even-odd fill modes;
 - Supports poly-polygons;
 - High performance - does not require oversampling;
 - Supports the GR32 polygon fillers;
 - Possible to implement custom renderers for different render targets;
 - Support for General Polygon Clipper for performing polygon set operations.

Acknowledgements:
 - Thanks to Angus Johnson and Anders Melander for helping me track down bugs.
 - Thanks to Sanyin for providing SSE2 optimized CumSum implementation.
 - Thanks to Michael Hinrichs for reporting about a buffer overflow bug.
 
Change log:
 Version 1.00 (28 January 2009):
  - First version. Benchmark demo included.
 Version 1.01 (29 January 2009):
  - Added {$I GR32.INC} to units to avoid range check errors;
  - PolygonFS/PolyPolygonFS now have default parameter values for FillMode and
    RasterMode;
  - Fixed bug when using polygon filler (EMMS was not called);
  - Fixed problem when passing zero length polygon arrays;
  - Updated to correct dates in license preambles.
 Version 1.02 (1 February 2009):
  - Added Single precision version of Round (somewhat faster);
  - Fixed a problem in the MakeAlpha*P functions that would result in
    incorrect alpha values.
 Version 1.04 (4 February 2009):
  - Support for gamma correction (by defining USEGR32GAMMA symbol);
  - Minor tweaks and optimizations.
 Version 1.05 (11 February 2009):
  - Added PolyFillline routine to GR32_PolygonsEx;
  - Fixed vertical clipping problem;
  - Minor tweaks and optimizations.
 Version 1.06 (12 February 2009):
  - Fix: scanlines that were completely filled were not painted.
 Version 1.10 (25 February 2009):
  - Changed the clipping mechanism. Clipping is now handled by the ClipPolygon
    routine in GR32_VectorUtils.pas;
  - Fix: coordinates were in some instances outside the clipping rectangle;
  - Removed the RasterMode parameter (rmOptimize <> improved performance);
  - Added support for open polylines;
  - Added TJoinStyle and TEndStyle in PolyLine routines;
  - Added LibArt to the benchmark tool.
Version 1.11 (26 February 2009):  
  - Added GR32_VectorGraphics unit, which includes auxiliary classes for
    drawing paths.
Version 1.12 (28 February 2009):  	
  - Added BuildDashedLine routine, for creating dashed strokes;
  - Added Cairo Graphics to the benchmark tool;
  - Minor tweaks and bugfixes.
Version 1.13 (2 Mars 2009):
  - Changed naming of TEndStyle enumeration types, to avoid confusion;
  - Changed MiterLimit parameter to conform with the SVG specification;
  - Added TRenderSpanEvent type and changed declaration of TRenderSpanProc;
  - Fixed bug in ClipPolygon routine.
Version 1.14 (3 Mars 2009):
  - Fixed bug when rendering closed polylines;
  - Fixed bug that caused coordinates outside the clipping rectangle to be 
    processed by the renderer.
Version 1.15 (4 Mars 2009):
  - Fixed problem with line joins when polygon included zero-length segments.
Version 1.16 (4 Mars 2009):
  - Fixed problems with line ends and open polylines.
Version 1.17 (16 Mars 2009):
  - Fixed problem with line ends;
  - Addded GR32_CFDG.pas -- a renderer for CFDG commands.
Version 1.18 (18 May 2009):
  - Fixed problem in BuildPolyLine. Thanks to Dirk Carstensen for reporting.
Version 1.19 (25 May 2009):
  - Fixed BuildPolyLine problem again. Thanks to Angus Johnson.
Version 1.20 (16 June 2009):
  - Added support for LCD sub-pixel rendering (PolygonFS_LCD);
  - Added TransformPolygon function to GR32_VectorUtils;
  - Added AggLite library to the benchmark demo (thanks to Dmitry Gultyaev).
Version 1.21 (16 June 2009):
  - Fixed D7 compilation problem;
  - Fixed problems in LCD rendering routine.
Version 1.22 (17 June 2009):
  - Added PolygonFS_LCD2 routine that performs an additional filtering pass.
    The result is smoother, but the performance hit is bigger.
Version 1.23 (28 February 2010):
  - Added General Polygon Clipper (gpc.pas) [covered by separate license];
  - Added a GPC test project (originally written by Richard B. Winston);
  - Added SSE2 optimized CumSum routine by Sanyin <prevodilac@hotmail.com>;
  - Fix: BuildDashedLine could return faulty line segments;
  - Minor tweaks and optimizations.
Version 1.24 (30 April 2010):
  - Maintenance update -- fixes a potential buffer overflow problem;
  - Improved CumSum implementation by Sanyin.
Version 1.25 (6 November 2010):
  - Maintenance update -- renaming/fixing broken packages.

Included files:
  GR32_VPR.pas            this unit includes the core routines for computing 
                          coverage values for each scanline.
  GR32_PolygonsEx.pas     an interface to the GR32 library, with designated 
                          polygon routines.
  GR32_VectorUtils.pas    misc. auxiliary routines used by the rasterizer.
  demo\VPR_Benchmark.dpr  benchmark demo (comparison with GR32_Polygons).
  
License:
 This work is copyright Centaurix Interactive Designs / Mattias Andersson.
 It is licensed under the terms of the Mozilla Public Licene 1.1
 (MPL 1.1, available from http://www.mozilla.org/MPL/MPL-1.1.html)

3rd-party licenses:
 - The General Polygon Clipping library is copyright (C) Advanced Interfaces 
   Group, University of Manchester and is free for non-commercial use only:
   
   <http://www.cs.man.ac.uk/~toby/alan/software/gpc.html>
   
 - AggPas and AggLite is copyright (C) Maxim Shemanarev:
 
   <http://www.antigrain.com>
 
Contact Details:
 Snailmail:
   Mattias Andersson
   Stranden 19
   475 31 Öckerö
   Sweden
 E-mail:
   mattias@centaurix.com
   
Donations:
 If you find this software useful, the best way to show your support would
 be through a donation. See this page for more info:
 
 <http://graphics32.org/donation/>


Copyright (C) 2008 - 2009 Mattias Andersson