VCLZip Native Delphi Zip/UnZip Component! 

IMPORTANT:  If installing the registered version, please be sure to always re-install/rebuild the components (VCLZip and VCLUnZip) to the component pallette (or rebuild the design time package) so that the ThisVersion property and any other new properties will be properly updated.  If your application still does not run without the IDE, open up VCLZip's package, click on options and look at the Directories/Conditionals tab.  If KPDEMO is defined, remove it and recompile the package.

***IMPORTANT: Please remember do not install these components into a package by the name of either VCLZip or VCLUnZip.  You will receive an error if you do.

PLEASE TAKE A LOOK AT THE "WHAT's NEW IN THIS VERSION" LINK IN THE HELP FILE AS IT HAS CONVENIENT LINKS TO ALL OF THE NEW TOPICS.

====================
Version 4.60 Build 1 Beta (02/24/2009)

- EncryptInPlace - New procedure that encrypts files in an existing archive without the need for unzipping and rezipping those files.
- DecryptInPlace - New procedure that decrypts files in an existing archive without the need for unzipping and rezipping those files.
- Ability to specify a file date (TDateTime) when calling ZipFromStream and ZipFromBuffer.


Version 4.50 Build 1 (11/24/2008)   UNICODE SUPPORT

PLEASE READ "Using Unicode" in the Help File or UsingUnicode.txt in the /help directory for important information about how to activate the use of Unicode in VCLZip.  For all but Delphi/BCB 2009 you will need to define a conditional named IMPLEMENT_UNICODE

- Unicode Support
- New read-only property thisReleaseLevel reflecting whether this version is a Beta or Production version
 
Beginning with VCLZip 4.50, VCLZip is able to store Unicode filenames and paths as well as use Unicode in archive filenames and paths.

In order to allow VCLZip to implement Unicode filenames in Delphi/BCB 6-2007 (NOT 2009), you must create a compiler define...

When you install VCLZip 4.50 the following should already be done.  But to verify that it is done, open up the VCLZip package with the package editor.  In Project | Options, select the Directories/Conditionals tab and if it is not there already, type  IMPLEMENT_UNICODE into the conditionals text box and save.

In order to implement Unicode in Delphi/BCB 6-2007, VCLZip uses WideStrings wherever filenames and paths are used.  Defining IMPLEMENT_UNICODE will cause VCLZip to compile all such strings as WideStrings and cause WideString functions to be called instead of the normal Ansii String functions.  When IMPLEMENT_UNICODE is not defined, VCLZip is compiled as it always was in earlier versions using regular Ansii strings and functions.

VERY IMPORTANT

- Only Delphi 6 and above, and BCB 6 and above are supported when implementing Unicode. Delphi 5 and below and BCB 5 and below are not supported for Unicode.

- If you are upgrading an existing application that uses VCLZip, this will cause many events to require changes since parameters that were regular strings will now be widestrings in a lot of instances.

- Prior to Delphi 2009, the Delphi GUI components do not support Unicode.  Therefore, if you wish to implement Unicode in your GUI you will need to add Unicode capable components.  When modifying the VCLZip Zip Utility Example to work with VCLZip 4.50, we used the TMS Unicode Component Pack which you can find at

            http://www.tmssoftware.com/site/tmsuni.asp

The VCLZip Zip Utility Example uses TMS Unicode controls, but does not include the TMS controls themselves. You will have to purchase TMS Unicode if you do not already own it for the example project to work.  However, it is not needed for VCLZip itself to support Unicode.

====================
Version 4.00 Build 3 (01/26/2008)

- Build 2 fix was not complete. Did not account for STOREd files.  That fix is completed.
- Added check for '\' at end to TempPath property.


====================
Version 4.00 Build 2 (01/25/2008)

- Fixed bug that did not allow you to call CheckArchive right after zipping a file with AES compression without closing and opening the file first or creating a new instance of VCLZip to perform the CheckArchive.

====================
Version 4.00 Build 1 (01/21/2008)

- Added Strong AES (AE-2) Encryption, compatible with PKZip and WinZip.

====================
Version 3.10 Build 1  (11/28/2008)

- Several bug fixes.
- Added support for Delphi 2005, 2006, 2007
- Added support for BCB 2006, 2007
- Improved memory performance when working with archives containing extremely high number of compressed files.

====================
Version 3.06 Build 2

Made Delphi 2005 compatible
Other assorted fixes

====================
Version 3.05 Build 1

Fixed a lot of incompatabilities between VCLZip and WinZip
Other assorted fixes

====================
Version 3.04 Build 1

New ZLib methods for optimized compression and decompression of single entities of data in standard ZLib format, without the overhead of the PKZip format.  This is excellent for compression of data to be sent across the net, compressing web pages (http compliant compression), blobs, etc.

- ZLibCompressStream
- ZLibDecompressStream
- ZLibCompressBuffer
- ZLibDecompressBuffer
- ZLibCompressString
- ZLibDecompressString

Overloaded TStream Methods for Delphi 4,5, BCB 4, and 5

- UnZipToStream
- UnZipToStreamByIndex
- ZipFromStream

Special OnGetNextTStream Event for Delphi 4,5, BCB 4, and 5
- Allows zipping multiple TStreams in one process
- More efficient than calling ZipFromStream multiple times

Capability to use the latest version of ZLib 1.2.1.  

- VCLZip currently uses 1.4.1 by default.
- By defining ZLIB121, VCLZip will use the latest version of ZLib which is included with the registered version.

Some optimization improvements which should show some improvement in zipping and unzipping speed when using TkpStreams with D4, D5, BCB4, and BCB5.

============
Version 3.03 (VCLZip Pro)

- Please test your application thoroughly with this new version of VCLZip Pro.  While it has been tested and has even been used in at least two production applications for several months now prior to initial release, there are so many combinations of property settings, environment differences, and ways to use VCLZip that you should always test VCLZip completely in your application before deploying.

*** New Zip64 capabilities, properties, methods and events:

- Uncompressed, Compressed, and Archive file sizes can be up to 2^63-1 bytes in length.  
- You can compress up to 2147483647 files into an archive.  This is compatible with PKZip's Zip64 format.  
- If a file does not extend beyond any of the original limitations (filesizes of 4 gig or 65535 files) then no Zip64 format information is included in the archive.
- property isZip64 - tells you when you are working with a zip file that is using Zip64 format.

Much faster processing due to linking to Zlib object files for compression and decompression routines.

Blocked Zip Files (spanned zip archives split onto hard drive) 

- Now completely compatible with PKZip and WinZip split archives file naming format. 
- For backwards compatability you can tell VCLZip to use the old VCLZip filenaming format by using the BlockMode property.
- New method OnFileNameForSplitPart called just before each split filepart is created.  VCLZip supplies a default implementation of this method so for most purposes you won't need your own.
   - method DefaultFileNameForSplitPart - VCLZip calls this internally if you don't define your own OnFileNameForSplitPart.  You can also call it from your own OnFileNameForSplitPart if you wish to add some processing to the default behavior.
   - property BlockMode - determines whether VCLZip uses PKZip/WinZip standard naming convention or VCLZip classic method.
   - method DefaultGetNextDisk - VCLZip calls this internally if you don't define your own OnGetNextDisk.  You can also call it from your own OnGetNextDisk event if you wish to add some processing to the default behavior.

- Properties for controlling which files are zipped...
    - IncludeHiddenFiles - default False;
    - IncludeSysFiles: - default False;
    - IncludeReadOnlyFiles: - default True;
    - IncludeArchiveFiles: - default True;

- Event OnGetNextStream - Allows you to zip from multiple streams when using the ZipFromStream method. This improves performance since repeated calls to ZipFromStream causes the archive to be updated on each subsequent call.

- property ThisBuild - Tells you the current build.  See also ThisVersion
      
- property OnHandleMessage - Handles interactive messages with VCLZip.  There is a default, so you don't need to define your own unless you wish to eliminate interactive messages and handle them on your own.  This is helpful if you are using VCLZip as a service or on a webserver for instance.

******** Upgrading existing applications that use VCLZip 2.X **********

For the most part, existing applications will work as-is.  Just install VCLZip 3.X and recompile your code.  Here are some things to be aware of though...

1) If your app currently creates mmBlock archives (spanned directly to hard drive) and you define your own OnGetNextDisk in VCLZip 2.X, you should move your code from this event that handles mmBlock events to the new event OnFileNameForSplitPart. However, if you simply rely on VCLZip's default OnGetNextDisk then you don't have to worry about this.

2) If your app creates mmBlock archives, the default naming convention has changed to match the PKZip/WinZip standard. If you wish to keep the same naming convention then set BlockMode := mbClassic.

3) OnGetNextDisk and OnPrepareNextDisk events are called for the 1st disk now.  VCLZip 2.X only calls these events starting with the 2nd disk.

4) properties CompressedSize[Index], UncompressedSize[Index], ZipSize are now Int64 types.

5) Delphi 4, Delphi 5, BCB 4, and BCB5 are all capable of using the Zip64 format.  However they use the TkpHugeStream decendants which act just like TStreams except they handle files/stream sizes larger than 2gig. There is a TkpHugeFileStream and a TkpHugeMemoryStream which should handle 99% of all necessary actions.  If you currently work with VCLZip 2.X with TBlobStreams or some other type of streams, you can either define your own TkpBlobStream for instance which inherits from TkpHugeStream, or use the TkpHugeStream.CopyFrom(TStream, Count) and the TkpHugeStream.GetStream: TStream methods to give VCLZip your stream and get it back.  Ofcourse when using regular TStream decendants in D4,4,BCB4,and 5, you cannot create Zip64 archives.  If you use Delphi 6, 7, or BCB 6, you don't have to worry about any of this as the normal TSTream is used by VCLZip and handles large file/stream sizes.


============
Version 2.23 (VCLZip Lite)

Added the OEMConvert property.  Filenames stored in a PKZip compatible archive normally go through an OEM conversion to make them ascii compatible.  When opening the zip file the conversion is undone.  If you do not plan on having other zip utilities opening up your archives this conversion process is not really necessary.  Setting this property to False will eliminate this process.  The default value for this property is True for normal PKZip compatability.

Added OnEncrypt and OnDecrypt events.  These allow you to replace the standard pkzip encryption with your own.  Data is passed to these events a buffer at a time.  Use this with care as this is still somewhat experimental and I'm not sure how useful it is yet.  You must make all changes within the buffer sent in to you.  Treat the entire file as a stream.  Byte for byte replacement only.  No additional keys can be saved.

Added OnRecursingFile event.  Sometimes when using wildcards and recursing directories, there was no reporting of progress.  This will be fired each time a file matches as the file list is being built while recursing directories.

Added the EncryptBeforeCompress boolean property.  The default for this property is False and if left like this VCLZip will behave like normal.  If set to True, VCLZip will encrypt each buffer prior to compressing it instead of afterwards.  This will cause files to not be decryptable by normal zip utilities thereby adding a bit of extra security.

Bugs Fixed:

IMPORTANT!!!  Behavior of freeing the ArchiveStream (compressed stream) has been modified.  VCLZip will now no longer try to free ArchiveStream, you must free it yourself.  This was due to a problem where it would be freed automatically if there was a problem with the ArchiveStream when trying to open it as a zip file (possibly corrupt).  Best practice is that ArchiveStream should always point toward a TMemoryStream that you create anyway.

Modified the SFX code (the code used to create the SFX stub distributed with VCLZip) so that it handles filenames that have been run through an OEM Conversion.  The SFX was losing accented characters.  This modification means that if you are creating zip files to be used as SFX's you will want to leave the OEMConvert property mentioned above, set to it's default value of True.

Modified so that when cursor is changed to hourglass by VCLZip, previous cursor is saved correctly instead of just changing it back to default cursor.

Now saves Central Directory Extra Fields correctly.

Fixed the SFX code so that it works properly if you use Copy /B to concatenate a zip file to the stub.

Due to a Delphi strange behavior sometimes path names for directory only entries would become corrupted.

Removed reference to QConsts, replaced with RTLConsts.

Sometimes a GPF would result if a corrupt zip file was opened.

Using a wildcard in pathname added to FilesList did not work.

Using '*.*' as a wildcard in files added to FilesList now is the same as using '*'.

VCLZip will now check for CancelTheOperation during initial building of the fileslist instead of just during compression processing.

Added a final call to OnTotalPercentDone with 100% because this didn't always happen.

Attributes were not getting set correctly for directory-only entries.

Fixed a problem that was not allowing ZipComment's to be added correctly to spanned or blocked zip files.  Not the same fix as in 2.22.

Directories (directory-only entries) were not being restored properly unless DoAll was True.

You were unable to delete a directory from which files were recursively zipped until exiting your application.


============
Version 2.22

Now Delphi 6 compatible.

New event called {link=93,OnRecursingFile} which gets called as VCLZip recurses directories searching for files that match a wildcard that is entered in the FilesList.  This gets called each time a file matches the wildcard.

Fixed a bug which kept diskettes from being labeled when creating spanned zip files on WIN31.

Fixed a bug which sometimes did not allow zip comments to be added to blocked zip sets.

Fixed a bug which caused VCLZip to not properly handle the IncompleteZip exception on spanned zip sets unless you called ReadZip prior to calling UnZip.


Version 2.21 (Changes are shown in the build stages as they were implemented)

Pre-Release Build 5:

When working with temporary files, VCLZip will now rename, instead of copy, the temp file if the destination is on the same drive.  This will speed up the adding of files to an existing zip file when the resulting zip file is very large.

Pre-Release Build 4:

New event called OnPrepareNextDisk which is an event that will allow you, when creating spanned zip files across diskettes, to do things like format a diskette that has just been inserted, or to add or delete files from the diskette before continuing with the zipping process.

Fixed a problem that was causing the CancelTheOperation Method to not work properly.


Pre-Release Build 3:

Fixed bug which caused VCLZip to miscalculate space needed for zfc file if wildcards are put into the FilesList.

Fixed bug so you could have FilePercentDone without needing TotalPercentDone when creating spanned zip files

Fixed so relative_offset set correctly for spanned zips.  Side effect of removing needless write of header.

Added code to read local fileheaders if exception thrown when reading a central fileheader.

Fixed problem where directories couldn't be created from directory entries because the fullpath wasn't known yet.  Result of having moved this code to earlier.

Fixed typo in creation of LOC header values which could cause error if reading local headers.

Changed so Zip Comment starting position is calculated based on end of central record instead of end of file.


Pre-Release Build 2:

IMPORTANT: Changed default for FileOpenMode back to fmShareDenyNone as it had been for all but version 2.20.

Fixed a problem where drivepart (i.e. C:\) was not being stripped when saving relative paths.

Added a BufferedStreamSize property which can increase the speed of creating zips to floppy (and other slow media) dramatically.  The new default for this should increase the speed by as much as 3 times, but you can now tweak this especially for your application!

Added an ImproperZip property which gets set when VCLZip detects an inconsistency with the zip.  This can be useful for detecting when VCLZip was able to open the zip in spite of an inconsistency found.  There was no way to know this in the past.

Fixed a problem where zip comments in zfc files were not being read correctly.

Added a setZipSignatures procedure which allows you to modify the signatures of your zip file.  This will cause other zip utilities to not be able to recognize or read your zip files created with VCLZip.  Useful if you want to add further security to your zip files.

Pre-Release Build 1:

Some zip files would not open correctly, throwing an incomplete zip file exception due to an erroneous "extra field length" identifier in headers of some compressed files. These zip files are rare, but a very few people seemed to have several of them. This problem would not affect zip files created by VCLZip, and this problem should only occur in VCLZip 2.20, not in any previous version. 

If you had Range Checking turned on, VCLZip would get a range check error when using a wildcard that ended with a * as in 'somefile.*'. 

Under certain circumstances, drive information would not be stripped from path information if zipping recursively (including subdirectories) 

"Retrying" to zip a file that could not be opened using the OnSkippingFile event would not always work correctly. 

Creating spanned zip set to floppy should be faster now due to removing a needless header write to disk for each file. 

VCLZip would not compile correctly with MAKESMALL defined. 

Added code to make VCLZip work with BCB5. Haven't tested this yet though since I don't have BCB5 myself yet. 

Added readonly boolean ImproperZip property which will be set to True when some sort of problem is found when opening the zip file, even if recoverable. This property will be enhanced and refined in the future. 

If KeepZipOpen is set to True, when putting in the wrong disk in a spanned zip set, VCLZip would not always properly close the file on the old diskette before trying to open the file on the next diskette. 

Added ECantWriteUCF exception which will be thrown if VCLZip runs out of room to write the uncompressed file when unzipping. 

Timestamp was not being set properly when unzipping readonly files. Moved setting of the timestamp to before the attributes get set. 

============
Version 2.20

Changes have been made in the following areas:

--Performance

There are a few code optimizations that should speed up the zipping process slightly.

--Spanned Zip Files

A new feature, turned on with the SaveZipInfoOnFirstDisk allows VCLZip to create and read spanned zip files starting with the first disk instead of the normally required last disk of the spanned disk set by saving a Zip Configuration File on the first disk.  This feature can be used even if creating the spanned zip file directly to your hard drive.

A new property, SaveOnFirstDisk, allows you to save room on the first disk when creating a spanned zip file, to allow room for other files, such as setup programs, data files, or a Zip Configuration File.

Spanned zip files can now be directed toward disks greater than 2 gig in size as long as you are using Delphi 5 or BCB 4.

--UnZipping

The new Selected indexed property offers another way to flag files to be unzipped.  Files that have the Selected property set to True can be unzipped using the UnZipSelected method.  The Selected property will be cleared (set to False) for each file as it is unzipped, but you can also call the ClearSelected method to clear them all.  At anytime the NumSelected property can be checked to see how many files have been selected.

Also, the UnZipToBufferByIndex and UnZipToStreamByIndex methods allow you to unzip files specified by their index instead of by name or wildcard.

The BufferLength property allows buffered output (buffer smaller than the total uncompressed filesize) when unzipping directly to memory (see UnZipToBuffer and UnZipToBufferByIndex).  This will cause the OnGetNextBuffer Event to be called everytime BufferLength bytes have been output by VCLZip.

Modified to work in all ways with zip files that have "extra fields" in their headers. These tend to be quite rare, but they do show up from time to time.

--Zipping

Added a property called FileOpenMode which allows you to define the file open mode for files when they are opened to be zipped.

Added a Retry parameter to the OnSkippingFile Event that can be used to re-attempt to open a file for zipping that is open by another process.  This gives the chance to close the file and continue with the zipping process rather than having to start over again.

Added a ENotEnoughRoom exception which will be thrown if there is not enough room to write to the archive, i.e. out of disk space.

The new OnUpdate Event gets fired when updating or freshening an existing archive.  It is triggered for each file that already exists in the archive as it is either replaced or kept in the updated archive.

The AddDirEntriesOnRecurse will cause separate directory entries to be included in archives when doing recursive zips through subdirectories.

--Integrity Checking

A new method, CheckArchive, will perform an integrity check on all files in an archive.  This is much faster than using FileIsOK on each file if testing all files in an archive with VERY MANY files.

Further improved checking for corrupted zip files when opening zip files.

--Encryption

The following new properties and methods allow lower level work with password encrypted archives:

DecryptHeader               Gets the decryption header for a particular compressed file in an archive 
GetDecryptHeaderPtr         Same as DecryptHeader but easier to use in BCB.

DecryptHeaderByte Method    Tests a password against the decryption header found in the DecryptHeader property.
GetDecryptHeaderByteByPtr   Same as DecryptHeaderByte but easier to use in BCB.

--Self Extracting Executables

Changes were made to the ZIPSFX32.BIN stub itself:

- Modified to work with zip files containing "extra fields" in their headers.
- Modified to change mouse cursor to an hour glass during processing.
- Check for correct file size is now done automatically
- Now uses the end of central and central headers to find the first local header.
- Added a progress meter 
- Better checking for corrupted zip files.
- Added an information window that can optionally be shown when the sfx is initially started up.
- Added an AutoRun option to make the sfx stub run automatially when double clicked with no other interaction from the user.

For the new modified sfx stub, ZIPSFX32.BIN, instead of using kpSFXOpt, you should now use the TSfxConfig component to set the options for the sfx stub.

The new sfx can be found in the sfx\ subdirectory as usual and is called ZIPSFX32.BIN and the original sfx can be found in the same subdirectory except it is now called ORGSFX32.bin.  Just rename it if you prefer that one (use KPSFXOPT instead of TSfxConfig with the old stub).

--Miscellaneous

The installation is now easier, atleast for first time installers of the source code.  The .DPK files for Delphi and .CPP files for BCB are now included.  Now these files simply have to be compiled and that's it.  There is a separate option in the installation for installing to the different versions of Delphi and BCB.

Added a property called FlushFilesOnClose which will cause all files opened for write by VCLZip to have their disk buffers flushed to disk when closed.

Added the capability to delete Selected files from an archive using the DeleteEntries Method.

The behavior of the OnInCompleteZip Event has been greatly improved.  You can now use this event to ask the user to insert the last disk of a spanned disk set rather than having to handle this situation from outside VCLZip.

The register procedures were changed so that the components now get installed to the "VCLZip" tab on the palette.  I found that for all but Delphi 1 I had to actually manually move the components to the "VCLZip" tab.  You may find that you have to do this too if you have already installed VCLZip before.

The components now use new bitmaps in place of the old ones on the component palette.

Separated many compiler defines into a new file called KPDEFS.INC.

====================================


Version 2.18: 

1) Thanks to the hard work of a fellow registered user, added the capability to remove all dependencies on the Dialogs, Forms, Controls, and FileCtrl units by defining the conditional MAKESMALL, which results in a smaller footprint.  This can be quite useful when putting VCLZip into a DLL for instance.  In order to make this work, go into your Project | Options and select the Directories/Conditionals tab and enter MAKESMALL in the conditional defines text box.  In Delphi you can add this conditinal define to the project options of your application that uses VCLZip and then do a "build all".  In BCB you will have to add this to the project options of the package that contains VCLZip and then rebuild the package.  

If you define MAKESMALL, the only things you lose are:

a) ZIP file open dialog box that appears when the ZipName is set to "?" 
b) Select Directory dialog box that appears when the DestDir is set to "?"
c) Changing the cursor to an hour glass during some operations.
d) No long filename support in Delphi 1

2) Made VCLZip completely BCB4 compatible.

3) Added some exception handling to KPUNZIPP and KPINFLT, mainly to handle unexpected situations when wrong passwords are entered.  This fixes the problem with PRP, the password recovery program.

4) For Borland C++ Builder, changed any COMP types to double, getting rid of the compiler warnings for unsupported comp type.  This affects the OnStartZipInfo and OnStartUnZipInfo events, so you'll have to change the comp parameter to double in these events if you use them (in both your header files and in the CPP files).

5) Modified OnStartUnZip event so that FName (the filename of the file that is about to be unzipped along with complete path) is now a VAR parameter and can be modified. This allows you to change the path and name of a file that is about to be unzipped.  This is especially helpfull in applications like Install Programs.  

NOTE: You will need to change your current code to add the VAR to the event definition and implementation if you already use this event in your application. (In BCB, add a & just before the parameter instead of VAR)

6) Moved many type definitions to VCLUNZIP.PAS so that kpZipObj won't have to be included in your USES list.

7) Fixed bug that caused GPF when setting Zip Comment to '' (empty string).

8) Moved strings in VCLZip/VCLUnZip into a string table, making the code size a little smaller as well as making it much easier to localize string information.  However you have the option of not using the new string table, for whatever reason, by defining NO_RES in your project options (in the conditional defines text box on the Directories/Conditionals tab).

9) Removed the need for several files.  No longer included are kpstrm.res, kpstrm.rc, kpsconst.res, kpsconst.rc, kpstres.pas, and for Delphi 1, kpdrvs.pas.  In some cases the need for these files was eliminated and in other cases just rolled into the newly included  kpzcnst.rc, kpzcnst.pas, and kpzcnst.res.  Definining NO_RES in your project options will elimiate the need for these new files but will make your code size slightly larger and you won't be able to localize your application without changing VCLZip source code.

10) Modified the OnFilePercentDone and OnTotalPercentDone progress events to work better when creating spanned disk sets and blocked zip sets.  They no longer report 100% when the compressed file still has to be copied to disk.

11) Added the ReplaceReadOnly property.  Setting this to true will allow files with the ReadOnly attribute to be replaced during the unzip process.

12) Added the ifNewer and ifOlder options to the OverwriteMode property. (This had somehow made it into the help file but not into VCLUnZip)

13) Added the SFXToZip method which will convert an SFX file to a regular zip file. The header pointers will be properly adjusted during the conversion.

14) Fixed a problem where the OnGetNextDisk event would always revert to the DefaultGetNextDisk method instead of what you entered into the Object Inspector each time your project was re-opened.

15) Fixed a bug that caused CRC errors when unzipping files from spanned disk sets if they were STORED (no compression) and spanned across disks.

16) Added the OnZipComplete and OnUnZipComplete events.  If defined, these will fire at the very end of a zip or unzip operation (after all files have been processed, not after each file).  These events will rarely be used since, normally you will be able to do the same thing at the point that the call to Zip or UnZip returns, but these events can be useful when using VCLZip in threads where in certain circumstances the return from the Zip or UnZip methods are not seen.

17) Creation of SFX files has never been easier!!!  The addition of the MakeNewSFX method allows you to create Self Extracting Executables without the need to create a zip file first.  The files that you specify in the FilesList property will be zipped, using all the normal VCLZip property settings, and the SFX will be created, all in one step!  In addition, you can create configurable SFX files using this method, and you can do this especially easy by adding the new unit kpSFXOpt to your application's USES list and using the new 32bit SFX stub that is now distributed with VCLZip.  This allows you to easily set things like SFX Dialog caption, default target extraction directory,  file to launch after extraction, etc.

18) Fixed a memory leak that only affects applications using VCLZip that are compiled with Delphi 2, and that use wildcard specifications in the FilesList property.


Version 2.17a:

1) Fixed a bug that was keeping VCLZip from reading truncated zip files or sfx files that did not have their headers adjusted.

2) Fixed a bug that was causing a directory to be created on the C drive when doing integrity checking with the FileIsOK property.

3) Added {$V-} to kpZipObj.PAS

4) Moved two AssignTo methods to public instead of private in kpZipObj.PAS


Version 2.17:

1) Added Memory zipping and unzipping capabilities through the UnZipToBuffer and ZipFromBuffer methods.  See the documentation for these methods in the Help File for more information.  

2) New FileIsOK Property allows you to check for the integrity of individual files within an archive without actually unzipping the file.

3) Fixed a bug that kept checking of volume labels from working on WIN31 when working with spanned disk sets.

4) Removed all references to ChDirectory so that VCLZip will be more thread safe allowing separate instances of VCLZip in separate threads to be performing zip/unzip operations at the same time.

5) A new public property PreserveStubs allows you to make modifications to sfx archives and have the archive remain an SFX rather than revert back to a normal zip file.

6) Added a default OnGetNextDisk event.  If one is not defined, then the default event will be called when the situation arises that a new disk is needed when zipping or unzipping a spanned or blocked zip archive.

7) Added more power to the wildcard capabilities.  Now you can qualify the * wildcard character, for instance:

  *<a-e> would satisfy any number of contiguous characters as long as they are all a thru e.
  *<!a-e> would satisfy any number of contiguous characters as long as none of them were a thru e.

  This allows you to do things like include files in specific direcories into your ExcludeList.  For instance:

     VCLZip1.ExcludeList.Add('c:\test\*<!\>.txt')

  would exclude the zipping of all .txt files in the test directory but not in any subdirectories.

8) Fixed other minor bugs and made other code enhancements.


Version 2.16:

***Please be aware that if you currently use the OnSkippingFile event in any of your applications, version 2.16 will require a small modification as this event has an added parameter and one of the current parameters is used a little differently when being called by the zip operation.  Please see the help file for more information.

1) The OnSkippingFile Event has been changed slightly, adding a parameter for the filename.

2) OnSkippingFile is now called when a file to be zipped is skipped because it is locked by another application.  See the Help File for more information.

3) Fixed a bug with the Exclude and NoCompressList where they were ignoring entries with anything before the extention (i.e. 'somefile.*' as opposed to '*.zip') if you were saving directory information.

4) Fixed a bug that caused an error if you added a wildcard with a non-existent directory to the FilesList.

5) A few other minor bug fixes.


Modifications for 2.15 include:

1) PackLevel can now be set to 0 (zero) which means no compression at all (STORED only).

2) New property ExcludeList is a new stringlist that you can add filenames and wildcards to in order to specify files that you do not wish to be included in an archive.

3) New property NoCompressList is a new stringlist that you can add filenames and wildcards to in order to specify files that you wish to be STORED with a PackLevel of 0 (zero), no compression.

4) All compiler warnings and hints were removed.


Modifications for 2.14 include:

1) Delphi 4 compatability.

2) Added ability to use complex wildcards when specifying which files are to be zipped.  This includes wildcard characters not only in the filename but also in the pathname.  This allows you to specify directories using wildcards, for instance:

  VCLZip1.FilesList.add('c:\test\w*\mycode*.pas');

  would get all PAS files beginning with mycode in subdirectories under TEST that begin with the letter w.  Wilcards may be much more complex than this.  Please see the help file for more information.

3) Added the ability to override the RECURSE property setting when specifying files to be zipped.  By adding the following characters to the beginning of the filenames being added, you can override whatever the current setting is for the RECURSE property:

   '>' will force recursion into subdirectories
   '|' will force NO-recursion

  For instance:

  VCLZip1.FilesList.add('>c:\windows\*.ini');

  will get all .ini files in and below the windows directory reguardless of what the recurse property setting is.

  and:

  VCLZip1.FilesList.add('|c:\windows\sys*\*.dll');

  will get all .dll files in subdirectories of the windows directories that start with 'sys' but will not recurse into any directories below the sys* directories.

4) The [ and ] characters previously used as special wildcard characters have been changed to < and > since [ and ] are valid filename characters.  If you still need to use the previous characters for backward compatability, I can show registered users how to easily modify a couple of constants in the source code in order to go back to the old style. See "Using Wildcards" in the help file for more information.

5) A few bug fixes.


Modifications for 2.13 include:

1) New property ResetArchiveBitOnZip causes each file's archive bit to be turned off after being zipped.

2) New Property SkipIfArchiveBitNotSet causes files who's archive bit is not set to be skipped during zipping operations.

3) A few modifications were made to allow more compatibility with BCB 1.

4) Cleaned up the Help File some.

5) KWF file now works for Delphi 1 and Delphi 2 again. Still can't get context sensitive help in Delphi 3.

6) Cleaned up some of the code that was causing compiler warnings and hints.


Modifications for 2.12 include:

1) Added a TempPath property to allow the temporary files path to be different from the Windows default.

2) Modified VCLZip so that any temporary files that are created receive a unique temporary filename so as not to clash with any other files in the temporary directory.  This also allows working with zip files residing in the temporary directory.

3) Fixed a bug in the relative path feature.

4) Fixed a bug that caused a "list out of bounds" error if a file in the FilesList did not actually exist.

Modifications for 2.11 include:

1) Fixed password encryption bug for 16 bit.

2) Fixed "invalid pointer operation" when closing application bug.

3) Fixed path device truncation bug which caused inability to modify existing archives in 16 bit.

4) Fixed inability to cancel during wilcard expansion bug.

5) Added capability to better handle corrupted timestamps.

6) Added capability to open and work with SFX files that were created with the COPY/B method (header files not adjusted).

7) Other small bug fixes.

I'm still working on a bug which causes a GPF when continually unzipping the same file thousands to millions of times.  This mainly affects programs like the Password Recovery Program (PRP) which uses the brute force method of searching for an archive's password.

Modifications for 2.10 include:

1) Capability for 16bit VCLZip to store long file/path names when running on a 32bit OS.

2) New property (Store83Names) which allows you to force DOS 8.3 file and path names to be stored.

3) Better UNC path support.

4) Fixed a bug to allow files to be added to an empty archive.

Modifications for 2.03 include:

1) Volume labels now get written correctly to spanned disk sets in Delphi 1 for all versions of Windows.

2) Delphi 1 VCLZip now correctly recognizes when it is running on Windows NT.

3) Fixed a problem with zipping files in the root directory when StorePaths = True.

4) File and Zip Comments are now read correctly from spanned/blocked zip archives.

5) Fixed a buf that was causing "Duplicate Object" errors. 


Modifications for 2.02 include:

1) Fix for file comments which were supposed to be fixed in version 2.01 but weren't.

2) Fix for stream zipping.  Version 2.01 would not create a new archive if using a stream.  (The Stream Demo now allows creating new zip files to streams too)

3) A few other minor modifications to further solidify the code.

4) A modification to the Zip Utility Demo which allows unzipping from Blocked zip files as if they were single zip files.

5) Added a read-only, published ThisVersion property which reflects the version of the VCLZip/VCLUnZip that you are currently working with.

Modifications for 2.01 include:

1) Fixes for exceptions that were caused when CANCELING a zip or unzip of a spanned zip file.

2) Fix for a possible problem when zipping or unzipping a spanned zip file when one or more of the compressed files resided on more than 2 of the spanned parts.

3) Fix for file comments which were broken in version 2.00.


Additional features for version 2.00 include:

1) Modify/Add internal file details (filename, pathname, timestamp, comment) for any file while zipping, in the OnStartZip event.

2) Add an Archive Comment while zipping in the OnStartZipInfo event.

3) Delphi 1 compatiblity for VCLZip. 

4) Stream to Stream Zipping - Archives themselves can now be TStreams!

5) New Relative Path Information option.

6) Unzip archives that weren't zipped with the Relative Path option turned on as if they had been by determining how much path information to use with the
   Rootpath property.

7) Modify timestamps for files in existing archives (you could already modify filenames and pathnames for files in existing archives)

8) The OnBadPassword event now allows you to supply a new password and try the same file again when unzipping.

9) Source code has been cleaned up so that it will compile under Borland C++ Builder with no modifications.

Also some bugs were fixed, most importantly:

1) An empty file, that had been compressed into an archive would cause any file added to the archive to cause the archive to approximately double in size. Any archives containing empty files are not corrupted, they are OK.  This was simply a fix to the way the archive was processed.

2) After creating an SFX file, you had to close the zip file before you could modify it in any way, otherwise a stream read error was encountered.


See the Help file for more information on new features.

This zip file is part of a self contained installation program.  Just run it and the installation program will begin.

Contact vclzip@bigfoot.com for further information

Thanks!

Kevin Boylan
