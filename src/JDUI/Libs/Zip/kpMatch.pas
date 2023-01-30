unit kpMatch;

{$R-}
{$Q-}

{
  File: match.pas
  Author: Kevin Boylan
}
{ $Id: kpMatch.pas,v 1.1 2001-08-12 17:30:37-04 kp Exp kp $ }

{ $Log:  10038: kpMatch.pas 
{
{   Rev 1.3    11/30/2008 1:44:04 PM  Delphi7    Version: VCLZip Version 4.50
{ Modifications for 4.50
}
{
{   Rev 1.2    4/17/2008 1:51:50 PM  Delphi7    Version: VCLZip Pro 4.10 Beta
{ Unicode Support
}
{
{   Rev 1.1    2/12/2007 10:08:00 PM  Encryption
{ lowercase to ansilowercase
}
{
{   Rev 1.0    8/14/2005 1:10:08 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.1    1/4/2003 1:57:26 PM  Supervisor
}
{
{   Rev 1.0    10/15/2002 8:15:16 PM  Supervisor
}
{
{   Rev 1.0    9/3/2002 8:16:50 PM  Supervisor
}
{ Revision 1.1  2001-08-12 17:30:37-04  kp
{ Initial revision
{
{ Revision 1.6  2000-05-13 16:25:22-04  kp
{ - Added code to get rid of range check errors
{
{ Revision 1.5  1999-11-27 20:54:34-05  kp
{ - Added some comments
{
{ Revision 1.4  1999-11-27 20:47:24-05  kp
{ - added (p < plen) check to avoid range check  2.20b5+
{
{ Revision 1.3  1999-01-08 12:10:26-05  kp
{ Added capability to qualify the * wildcard character
{
{ Revision 1.2  1998-12-26 16:44:05-05  kp
{ Fixed up comments a little to reflect change from [ ] to < >.
{ }

{  This code is meant to allow wildcard pattern matches.  It is VERY useful for matching filename wildcard
  patterns.  It allows unix grep-like pattern comparisons, for instance:

	?			Matches any single characer
	*			Matches any contiguous characters
	<abc>		Matches a or b or c at that position
	<^abc>	Matches anything but a or b or c at that position
	<!abc>	Ditto
	<a-e>		Matches a through e at that position
  *<a-e>   Matches any contiguous characters as long as they are all a thru e
  *<!a-e>  Matches any contiguous characters as long as they are all NOT a thru e

	'ma?ch.*'	-Would match match.exe, mavch.dat, march.on, etc
	'this <e-n>s a <!zy>est' -Would match 'this is a test', but would not match 'this as a yest'

  Notice that the < and > characters are used instead of the more common [ and ] characters.
  This is because this utility is used mainly for wildcards to test against filenames and on
  Windows [ and ] are valid filename characters while < and > are not.

  This is a Delphi VCL translation from C code that was downloaded from CIS.  That C code was written 
  by J. Kerceval and released to public domain 02/20/1991.  This code is ofcourse also public domain.
  I would appreciate it if you would let me know if you find any bugs.  I would also appreciate any
  notes sent my way letting me know if you find it useful.  My email address is 

				boylank@bigfoot.com
}

interface

uses SysUtils, kpUtilsUnicode;

const
	{ match defines }
	MATCH_PATTERN		= 6;
	MATCH_LITERAL		= 5;
	MATCH_RANGE			= 4;
	MATCH_ABORT			= 3;
	MATCH_END			= 2;
	MATCH_VALID			= 1;
	{ pattern defines }
	PATTERN_VALID		= 0;
	PATTERN_ESC			= -1;
	PATTERN_RANGE		= -2;
	PATTERN_CLOSE		= -3;
	PATTERN_EMPTY		= -4;
	{ character defines }
	MATCH_CHAR_SINGLE					= kpChar('?');
	MATCH_CHAR_KLEENE_CLOSURE		= kpChar('*');
	MATCH_CHAR_RANGE_OPEN			= kpChar('<');
	MATCH_CHAR_RANGE					= kpChar('-');
	MATCH_CHAR_RANGE_CLOSE			= kpChar('>');
	MATCH_CHAR_CARAT_NEGATE			= kpChar('^');
	MATCH_CHAR_EXCLAMATION_NEGATE	= kpChar('!');

type
  TCharSet = array of kpChar;

	function IsMatch( pattern, text: kpWString ): Boolean;
	function matche( pattern, text: kpWString ): Integer;
	function match_after_star( pattern, text: kpWString ): Integer;
	function is_pattern( pattern: kpWString ): Boolean;
	function is_valid_pattern( pattern: kpWString; var error_type: Integer ): Boolean;
  function inSet( W : kpChar; sets : TCharSet ) : Boolean;

implementation

  var
     CharSet        : TCharSet;
     sinvert        : Boolean;

	function IsMatch( pattern, text: kpWString ): Boolean;
	begin
  	Result := matche( pattern, text ) = 1;
	end;

	function matche( pattern, text: kpWString ): Integer;
	var
		range_start,
		range_end,
		p,
		t,
		plen,
		tlen				: Integer;
		invert,
		member_match,
		loop				: Boolean;

  procedure getSet(var CS: TCharSet);
  var
     j: kpChar;
  begin
     CS := nil;
     Inc(p,2);
     if (p > plen) then { 2/27/00  2.20+ }
        exit;
     sinvert := false;
     if (pattern[p]=MATCH_CHAR_CARAT_NEGATE) or (pattern[p]=MATCH_CHAR_EXCLAMATION_NEGATE) then
      begin
        sinvert := true;
        Inc(p);
      end;
     while (pattern[p] <> MATCH_CHAR_RANGE_CLOSE) do
      begin  { added (p < plen) check to avoid range check  11/27/99  2.20b5+ }
        if (p>plen) then { 2/27/00  2.20+ }
         begin
           CS := nil;
           exit;
         end;
        if ((p<plen) and (pattern[p+1]=MATCH_CHAR_RANGE)) then
         begin
           for j:=pattern[p] to pattern[p+2] do
              CS[High(CS)+1] := j;
           Inc(p,2);
         end
        else
         CS[High(CS)+1] := pattern[p];
        Inc(p,1);
      end;
     Inc(p,1);
  end;


	begin
		p := 1;
		t := 1;
     CharSet := nil;
     sinvert := false;
		pattern := kpLowerCase(pattern);
		text := kpLowerCase(Text);
		plen := Length( pattern );
		tlen := Length( text );
		Result := 0;
     { added the following for optimization }
     If (pattern = '*') then   { * matches everything ofcourse.  7/27/98 }
      begin
        Result := MATCH_VALID;
        exit;
      end;
		While ( (Result = 0) and (p <= plen) ) do
		begin
			if (t > tlen) then
			begin
				if (pattern[p] = MATCH_CHAR_KLEENE_CLOSURE) and (p+1 > plen) then
					Result := MATCH_VALID
				else
					Result := MATCH_ABORT;
				exit;
			end
			else
				Case (pattern[p]) of
					MATCH_CHAR_KLEENE_CLOSURE:
                 begin { added (p < plen) check to avoid range check  11/27/99  2.20b5+ }
                    if ((p < plen) and (pattern[p+1]=MATCH_CHAR_RANGE_OPEN)) then
                     begin
                       getSet( CharSet );
                       if CharSet = nil then  { 2/27/00  2.20+ }
                        begin
                          Result := MATCH_ABORT;
                          exit;
                       end;
                     end
                    else
                     begin
                       CharSet := nil;
                       sinvert := false;
                     end;
						   Result := match_after_star( Copy(pattern,p,plen),Copy(text,t,tlen) );
                 end;
					MATCH_CHAR_RANGE_OPEN:
						begin
							Inc(p);
                    if (p > plen) then  { 2/27/00  2.20+ }
                     begin
                       Result := MATCH_PATTERN;
                       exit;
                     end;
							invert := False;
							if (pattern[p] = MATCH_CHAR_EXCLAMATION_NEGATE) or
								(pattern[p] = MATCH_CHAR_CARAT_NEGATE) then
							begin
								invert := True;
								Inc(p);
                       if (p > plen) then  { 2/27/00  2.20+ }
                        begin
                          Result := MATCH_PATTERN;
                          exit;
                        end;
							end;
							if (pattern[p] = MATCH_CHAR_RANGE_CLOSE) then
							begin
								Result := MATCH_PATTERN;
								exit;
							end;
							member_match := False;
							loop := True;
							While ( (loop) and (pattern[p] <> MATCH_CHAR_RANGE_CLOSE) ) do
							begin
								range_start := p;
								range_end := p;
								Inc(p);
								if (p > plen) then
								begin
									Result := MATCH_PATTERN;
									exit;
								end;
								if (pattern[p] = MATCH_CHAR_RANGE) then
								begin
									Inc(p);
									range_end := p;
									if (p > plen) or (pattern[range_end] = MATCH_CHAR_RANGE_CLOSE) then
									begin
										Result := MATCH_PATTERN;
										exit;
									end;
									Inc(p);
								end;
								if (p > plen) then
								begin
									Result := MATCH_PATTERN;
									exit;
								end;
								if (range_start < range_end) then
								begin
									if (text[t] >= pattern[range_start]) and
									   (text[t] <= pattern[range_end]) then
									begin
										member_match := True;
										loop := False;
									end;
								end
								else begin
								  if (text[t] >= pattern[range_end]) and
									  (text[t] <= pattern[range_start]) then
									  begin
										member_match := True;
										loop := False;
									  end;
								end; { if (range_start < range_end) }
							end; { while (loop) }

							if (invert and member_match) or (not(invert or member_match)) then
							begin
								Result := MATCH_RANGE;
								exit;
							end;
							if (member_match) then
								while ((p <= plen) and (pattern[p] <> MATCH_CHAR_RANGE_CLOSE)) do
									Inc(p);
							if (p > plen) then
							begin
								Result := MATCH_PATTERN;
								exit;
							end;
						end; { MATCH_CHAR_RANGE_OPEN: }
					Else
						if (pattern[p] <> MATCH_CHAR_SINGLE) then
							if (pattern[p] <> text[t]) then
								Result := MATCH_LITERAL;
				end; { Case pattern[p] }
			Inc(p);
			Inc(t);
		end; { While ( (Result := 0) and (p < plen) ) }
		if (Result = 0) then
			if (t <= tlen) then
				Result := MATCH_END
			else
				Result := MATCH_VALID;
	end;

	function match_after_star( pattern, text: kpWString ): Integer;
	var
		p,
		t,
		plen,
		tlen		: Integer;
	begin
		Result := 0;
		p := 1;
		t := 1;
		plen := Length(pattern);
		tlen := Length(text);

     if (plen > 0) then
		   While (( t <= tlen ) and (p <= plen)) and  { (p = plen) to (p <= plen) 2/27/00  2.20+ }
        {$WARNINGS OFF}
				(pattern[p] in [MATCH_CHAR_SINGLE, MATCH_CHAR_KLEENE_CLOSURE]) do  { 2/27/00  2.20+ }
        {$WARNINGS ON}
		    begin
			   If (pattern[p] = MATCH_CHAR_SINGLE) then
				   Inc(t);
			   Inc(p);
		    end;

		If (t > tlen) then
		begin
			Result := MATCH_ABORT;
			exit;
		end;

		If (plen > 0) and (p > plen) then
		begin
			Result := MATCH_VALID;
			exit;
		end;

		Repeat
			If (plen > 0) and ((pattern[p] = text[t]) or (pattern[p] = MATCH_CHAR_RANGE_OPEN)) then
			begin
				pattern := Copy(pattern,p,plen);
				text := Copy(text,t,tlen);
				plen := Length(pattern);
				tlen := Length(text);
				p := 1;
				t := 1;
				Result := matche( pattern , text );
			end;
			if (t > tlen) then
			begin
				Result := MATCH_ABORT;
				exit;
			end;
        if (Result <> 1) and (CharSet <> nil) then
         begin
           if (sinvert) then
            begin
              if (inSet(text[t], CharSet)) then
               begin
                 Result := MATCH_ABORT;
                 exit;
               end;
            end
           else
              if not(inSet(text[t], CharSet)) then
               begin
                 Result := MATCH_ABORT;
                 exit;
               end;
         end;
			Inc(t);
		Until (Result = 1) or (t > tlen);
     if (p > plen) and (t > tlen) then
        Result := MATCH_VALID;
	{	Until ( Result <> 0 );  Modified to the above line 5/1/97 KLB }
	end;

	function is_pattern( pattern: kpWString ): Boolean;
	begin
     Result := True;
	end;

	function is_valid_pattern( pattern: kpWString; var error_type: Integer ): Boolean;
	begin
     Result := True;
	end;

function inSet( W : kpChar; sets : TCharSet ) : Boolean;
var
  ind : integer;
begin
  Result := true;
  for ind := 0 to High(sets) do
  begin
    if W = sets[ind] then exit;
  end;
  Result := False;
end;


end.
 
