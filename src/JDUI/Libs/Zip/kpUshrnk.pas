{**********************************************************************}
{ Unit archived using GP-Version                                       }
{ GP-Version is Copyright 1997 by Quality Software Components Ltd      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.qsc.u-net.com                                             }
{**********************************************************************}

{ $Log:  10056: kpUshrnk.pas 
{
{   Rev 1.0    8/14/2005 1:10:10 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.0    10/15/2002 8:15:20 PM  Supervisor
}
{
{   Rev 1.0    9/3/2002 8:16:52 PM  Supervisor
}
{
{   Rev 1.1    7/9/98 6:47:19 PM  Supervisor
{ Version 2.13
{ 
{ 1) New property ResetArchiveBitOnZip causes each file's 
{ archive bit to be turned  off after being zipped.
{ 
{ 2) New Property SkipIfArchiveBitNotSet causes files 
{ who's archive bit is not set to be skipped during zipping 
{ operations.
{ 
{ 3) A few modifications were made to allow more 
{ compatibility with BCB 1.
{ 
{ 4) Modified how directory information is used when 
{ comparing filenames to be unzipped.  Now it is always 
{ used.
}

{ ********************************************************************************** }
{                                                                                    }
{ 	 COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: Unshrink.pas                                                      }
{     Description: VCLUnZip component - native Delphi unzip component.               }
{     Date:        March 1997                                                        }
{     Author:      Kevin Boylan, CIS: boylank                                        }
{                                Internet: boylank@compuserve.com                    }
{                                                                                    }
{ ********************************************************************************** }


procedure Unshrink;
var
	  codesize: WORD;
    {maxcode: WORD;}
    maxcodemax: WORD;
    free_ent: WORD;

procedure partial_clear;
var
	pr:	short_int;
  cd:	short_int;
begin
	{ mark all nodes as potentially unused }
  cd := FIRST_ENT;
  while (WORD(cd) < free_ent) do
   begin
   	area^.shrink.Prefix_of[cd] := WORD(area^.shrink.Prefix_of[cd]) or $8000;
     Inc(cd);
   end;
   cd := FIRST_ENT;
   while (WORD(cd) < free_ent) do
    begin
     pr := area^.shrink.Prefix_of[cd] and $7fff;
     if (pr >= FIRST_ENT) then
     	area^.shrink.Prefix_of[pr] := area^.shrink.Prefix_of[pr] and $7fff;
     Inc(cd);
    end;
   { clear the ones that are still marked }
   cd := FIRST_ENT;
   while (WORD(cd) < free_ent) do
    begin
    	if (area^.shrink.Prefix_of[cd] and $8000) <> 0 then
     	area^.shrink.Prefix_of[cd] := -1;
     Inc(cd);
    end;
   { find first cleared node as next free_ent }
   cd := FIRST_ENT;
   while ((WORD(cd) < maxcodemax) and (area^.shrink.Prefix_of[cd] <> -1)) do
   	Inc(cd);
   free_ent := cd;

end;

var
	code: 	short_int;
  stackp: 	short_int;
  finchar: short_int;
  oldcode: short_int;
  incode:	short_int;
begin
	ZeroMemory( area, SizeOf(area));
  codesize := INIT_BITS;
  {maxcode := (1 shl codesize) - 1;}
  maxcodemax := HSIZE;
  free_ent := FIRST_ENT;
  code := maxcodemax;

  Repeat
  	area^.shrink.Prefix_of[code] := -1;
     Dec(code);
  Until code <= 255;

  for code := 255 downto 0 do
   begin
		area^.shrink.Prefix_of[code] := 0;
     area^.shrink.Suffix_of[code] := code;
   end;

   READBIT(codesize,oldcode);
   if (zipeof) then
    begin
     xFlushOutput;
   	exit;
    end;
   finchar := oldcode;
   OUTB(finchar);
   stackp := HSIZE;

   while not(zipeof) do
    begin
    		READBIT(codesize,code);
        if (zipeof) then
         begin
           xFlushOutput;
   	      exit;
         end;
        while (code = CLEAR) do
         begin
         	READBIT(codesize,code);
           Case code of
            	1: begin
              		Inc(codesize);
                  {  if (codesize = MAX_BITS) then
                    	maxcode := maxcodemax
                    else
                    	maxcode := (1 shl codesize) - 1; }
              	end;
              2: partial_clear;
           end;
           READBIT(codesize,code);
           if (zipeof) then
            begin
              xFlushOutput;
   	         exit;
            end;
         end;

    { Special case for KwKwK string }
     incode := code;
    	if (area^.shrink.Prefix_of[code] = -1) then
    	 begin
     	Dec(stackp);
     	area^.shrink.Stack[stackp] := Byte(finchar);
        code := oldcode;
      end;

     { Generate output characters in reverse order }
      while (code >= FIRST_ENT) do
       begin
      	{ Adding characters to stack }
        if (area^.shrink.Prefix_of[code] = -1) then
         begin
         	Dec(stackp);
           area^.shrink.Stack[stackp] := Byte(finchar);
           code := oldcode;
         end
        Else
         begin
         	Dec(stackp);
           area^.shrink.Stack[stackp] := area^.shrink.Suffix_of[code];
           code := area^.shrink.Prefix_of[code];
         end;
       end;

       finchar := area^.shrink.Suffix_of[code];
       Dec(stackp);
       area^.shrink.Stack[stackp] := Byte(finchar);

       { And put them out in forward order, block copy }
       if ((HSIZE - stackp + outcnt) < 2048) then
        begin
        	MoveMemory(outptr, @area^.shrink.Stack[stackp], HSIZE-stackp);
        	Inc(outptr,HSIZE-stackp);
        	Inc(outcnt,HSIZE-stackp);
        	stackp := HSIZE;
       	end
       Else    { output byte by byte if we can't go by blocks }
       	while (stackp < HSIZE) do
         begin
        	OUTB(area^.shrink.Stack[stackp]);
           Inc(stackp);
         end;

        { Generate new entry }
        code := free_ent;
        if (WORD(code) < maxcodemax) then
         begin
           area^.shrink.Prefix_of[code] := oldcode;
           area^.shrink.Suffix_of[code] := Byte(finchar);
           Repeat
           	Inc(code);
           Until (WORD(code) >= maxcodemax) or (area^.shrink.Prefix_of[code] = -1);
           free_ent := code;
         end;

         { remember previous code }

       oldcode := incode;
    end;  { While not(zipeof)) }

    xFlushOutput;
    
end;
