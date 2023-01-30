{**********************************************************************}
{ Unit archived using GP-Version                                       }
{ GP-Version is Copyright 1997 by Quality Software Components Ltd      }
{                                                                      }
{ For further information / comments, visit our WEB site at            }
{ http://www.qsc.u-net.com                                             }
{**********************************************************************}

{ $Log:  10020: kpCntn.pas 
{
{   Rev 1.2    11/30/2008 1:44:02 PM  Delphi7    Version: VCLZip Version 4.50
{ Modifications for 4.50
}
{
{   Rev 1.1    2/6/2006 10:59:52 PM  Delphi7
{ Modify memory allocation for when the object list grows.
}
{
{   Rev 1.0    8/14/2005 1:10:06 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.0    10/15/2002 8:15:12 PM  Supervisor
}
{
{   Rev 1.0    9/3/2002 8:16:48 PM  Supervisor
}
{
{   Rev 1.2    7/9/98 6:47:21 PM  Supervisor
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
{
{   Rev 1.1    Mon 27 Apr 1998   17:32:53  Supervisor
{ Added BCB 3 support
}

{%keywords: tcontain.pas 1.4 March 21. 1996 03:25:09 PM%}
{%nokeywords%}
Unit kpCntn;
(**************************************************)
(* tObjectList is taken largely from BI's RTL     *)
(* modified to use & free tObjects and added      *)
(* persistant stream support &                    *)
(* emulation of BP7's tCollection iteration       *)
(* support with ForEach,FirstThat & LastThat      *)
(*                                                *)
(* This container class assumes all items are     *)
(* derived from tObject                           *)
(* Limit is still MaxListSize items, for now..    *)
(**************************************************)
(*    95/05   LPL Soft inc                        *)
(**************************************************)
(* This source code is freeware. Use as you wish, *)
(* but *YOU* are responsible! RD(LPL Soft)        *)
{*********  Parts from  ***************************}
{                                                  }
{  Delphi Visual Component Library                 }
{                                                  }
{  Copyright (c) 1995 Borland International        }
{                                                  }
{**************************************************}
(* Send bug reports (with reproducable source)    *)
(*    LPL Soft : Robert Daignault                 *)
(*    Compuserve: 70302,1653                      *)
(*                                                *)
(**************************************************)
(*                History                         *)
(**************************************************)
(* 95/07/09 Fixed: FDestroy was not written/read  *)
(*                to/from stream in Read/WriteData*)
(*          Added: CopyOf Function. Copy instance *)
(*                of any registered object        *)
(*          Changed: Put all streaming Asm code in*)
(*                one procedure (CallStreamProc)  *)
(**************************************************)
(* 95/07/15 Added: Thomas's tSortedObjectList     *)
(**************************************************)
(* 95/07/25 Changed: Renamed RegisterClass        *)
(**************************************************)
(* 95/07/29 Added: Absolute memory stream object  *)
(*                moved to this unit              *)
(**************************************************)
(* 95/08/24 Added: ReadFromStream & WriteToStream *)
(*                procedures. Enables use of raw  *)
(*                streams (No need of lists).     *)
(**************************************************)
(* 95/08/28 Added: Clipboard support functions    *)
(**************************************************)
(* 96/03/01 Added:   Partial Support for Delphi 32*)
(*                   Read/write compatible streams*)
(*                   between Delphi 1 & 2         *)
(*                   Under Delphi32, maximum items*)
(*                   in list raised to 64K items  *)
(* Not yet done: Iterators ForEach, FirstThat and *)
(*               LastThat. Will need a real debug-*)
(*               ger for these. Just ordered today*)
(**************************************************)
(**************************************************)
(* 96/03/14 Added:   Full Support for Delphi 32   *)
(**************************************************)
(* 96/03/21 Fixed: Asm Iterators where dependant  *)
(*                on called proc not to modify    *)
(*                registers (EDX,EDI). They worked*)
(*                with my test samples (to simple)*)
(**************************************************)
                interface
(**************************************************)

{$I KPDEFS.INC}

Uses
{$IFDEF WIN32}
  Windows,
{$ELSE}
  WinProcs, WinTypes,
{$ENDIF}
{$IFDEF ISCLX}
  RTLConsts,
{$ENDIF}
 Classes, SysUtils;

const

(* Remove the following comment if you don't need 16/32 bit stream compatability*)
(* In that case, the default list size is 64K objects. To change, simply edit   *)
(* the cMaxList constant for 32 bit only operation                              *)

(*{$DEFINE Comp16_32Streams}*)

{$IFDEF WIN32}
 {$IFDEF Comp16_32Streams}
   cMaxList=$4000;
 {$ELSE}
   cMaxList=$1FFFFFFF; { 7/10/00 2.21b3+ }  (* 32 bit only operation : 64K objects. Could be much more ... *)
 {$ENDIF}
{$ELSE}
 cMaxList=MaxListSize;
 {$UNDEF Comp16_32Streams} (* Never defined in 16 bit mode *)
{$ENDIF}

type
 {$IFDEF Comp16_32Streams}
   tOLSize=SmallInt;
 {$ELSE}
   tOLSize=Integer;
 {$ENDIF}

 pObjects = ^tObjects;
 TObjects = array[0..cMaxList - 1] of pointer{tObject};
 TObjectList = class(TPersistent)
  private
    FDestroy : Boolean;
    FList    : pObjects;
    FCount   ,
    FCapacity: tOLSize;

    (*****************) protected {procedures *****************}
    procedure Error; virtual;
    procedure Grow; virtual;
    procedure Put(Index: tOLSize; Item: tObject);virtual;
    function  Get(Index: tOLSize): tObject;
    procedure SetCapacity(NewCapacity: tOLSize);
    procedure SetCount(NewCount: tOLSize);
    Function  Allocate(Size:LongInt):Pointer;
    Procedure FreeItem(AnItem:Pointer); virtual;
    (*****************) Public {procedures *****************}
    Constructor Create;
    Constructor CreateWithOptions(DestroyObjects:Boolean; InitialCapacity:tOLSize);
    destructor  Destroy; override;

    function    AddObject(Item: tObject): tOLSize; virtual;

    (* Clear and Delete are identical. They do not Free each object *)
    procedure   Clear; virtual;
    procedure   Delete(Index: tOLSize);
    Procedure   DeleteAll;

    (* Free procedures first destroy tObjects and then call Delete procedures*)
    Procedure   FreeAll;
    Procedure   FreeAt(Index:tOLSize);
    Procedure   FreeObject(Item: tObject);

    function    IndexOf(Item: tObject): tOLSize; virtual;
    procedure   Insert(Index: tOLSize; Item: tObject); virtual;
    procedure   Move(CurIndex, NewIndex: tOLSize);
    procedure   Pack;

    (***************** Streaming support *****************)
    Constructor CreateFromStream(const FileName: string);

    Procedure   SaveToStream(const FileName:String);
    procedure   LoadFromStream(const FileName: string);
    procedure   ReadData(S: TStream); virtual;
    procedure   WriteData(S: TStream); virtual;
    procedure   DefineProperties(Filer: TFiler); override;


    (***************** Iteration procedures **************)
    function    First: tObject; virtual;
    function    Last: tObject; virtual;
    Function    Next(Item:tObject; Forward:Boolean):tObject; virtual;

         (* Action will be called Count times, each with*)
         (* one of its contained tObject                *)
    (* Procedure Action(AnObject:YourClass); far; *)
    procedure   ForEach(Action: Pointer);

    (* Function Test(AnObject:YourClass):Boolean; far; *)
    function    LastThat(Test: Pointer): tObject;
    function    FirstThat(Test: Pointer): tObject;


   (*           ForEach, FirstThat and LastThat iterators
          These work exactly like BP7's tCollection methods.

              These methods will call their Action or test
             parameters for each tObject it contains.
             All Iterators assume that Action and test are
             <embedded procedures> or functions declared with
             the far attribute. Forgetting to put the far
             attribute will cause a GPF (Delphi 16 bit only). 
             Note that there is no type checking done by the 
             compiler on either the procedure type or the 
             parameters to Test and Action.
   *)

         (* FirstThat and LastThat stop the iteration when Test *)
         (* returns TRUE.These functions return the object that *)
         (* caused the iteration to stop. The differ only in the*)
         (* Iteration order. LastThat processes the list in     *)
         (* reverse order                                       *)

    (*****************  Properties  **************)
    property    Capacity: tOLSize read FCapacity write SetCapacity;
    property    Items[Index: tOLSize]: tObject read Get write Put; default;
    property    Count:tOLSize read FCount;
    Property    DestroyObjects:Boolean read FDestroy write FDestroy;
  end;


  (* Specialized memory Stream. Will Stream to a fixed memory buffer*)
  (* Mainly used when storing objects into a Object database record *)
  (* NOTE: the memory is not freed. That is your job!               *)
  (* An exception will be raised if an operation causes the stream  *)
  (* position to go behond it's max size                            *)
  TAbsMemStream = class(TStream)
  private
    FMemory: Pointer;
    FSize,
    FPosition: Longint;
  public
    Constructor Create(UseBuf:Pointer; MaxSize:LongInt);

    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;

    (*****************  Properties  **************)
    Property Position:LongInt read FPosition;
    Property Memory:Pointer read FMemory;
    Property Size: Longint read FSize;
  end;



(*************************************************)
(* Thanks to Thomas Roehrich, for the following. *)
(*************************************************)

  TSortedObjectList=class(TObjectList)
  private
    FDuplicates:TDuplicates;
  protected
    function  KeyOf(Item:TObject):Pointer;virtual;
    procedure Put(Index: tOLSize; Item: tObject); override;
  public
    constructor Create(WithDuplicates:TDuplicates);
    procedure ReadData(S: TStream); override;
    procedure WriteData(S: TStream); override;
    function  Compare(Key1, Key2:Pointer):integer;virtual;abstract;
    function  AddObject(Item: tObject): tOLSize; override;
    function  Search(Key:Pointer; var Index:tOLSize):boolean;virtual;
    procedure Insert(Index: tOLSize; Item: tObject); override;
    function  IndexOf(Item: tObject): tOLSize; override;

    property  Items[Index: tOLSize]: tObject read get;
    property  Duplicates:TDuplicates read FDuplicates;
  end;


             (* Streaming registration support *)
Procedure  DoRegisterClass(const LoadProc,StoreProc:Pointer;Sender:tClass);
Function   IsRegistered(AClass:tClass):Boolean;

  (******************************************************)
  (* Misc. Usefull tools enabled by registering classes *)
  (******************************************************)
Procedure  WriteObjectToStream(Source:tObject; S:tStream);
Function   ReadObjectFromStream(S:tStream):tObject;

  (* CopyOf creates and returns a new instance of Source *)
Function   CopyOf(Source:tObject):tObject;

  (* Clipboard related functions. Cut & paste tObjects!  *)
(*************************************************)
(* Thanks to Thomas Roehrich, for the following. *)
(*************************************************)
Function RegisterClipBoardType(const TypeName:String):Word;
  (* Use the result of RegisterClipBoardType as the ClipType
    Parameter to the 2 following procedures   *)
Function CopyObjectToClipboard(ClipType:word; Source:TObject):boolean;
Function PasteObjectFromClipboard(ClipType:word):TObject;

(**************************************************************************)
                              implementation
(**************************************************************************)
Uses
  Consts;


var
  FIdx: Integer;

type
 //tClassName=String[63];
 tClassName=String;

 tRegisterRec=Class(tObject)
  Obj:tClass; (* Class type *)
  DoLoad,
  DoStore :Pointer{TStreamProc}; (* This is a pointer because otherwise
                              a class instance would be required to register*)
  Constructor Create(AClass:tClass; Loader,Storer:Pointer);
 end;

var ClassRegistry:tStringList;
(**************************************************************************)
Constructor tRegisterRec.Create(AClass:tClass; Loader,Storer:Pointer);
begin
 Inherited Create;
 Obj:=AClass;
 DoLoad:=Loader;
 DoStore:=Storer;
end;

(**************************************************************************)
Procedure DoRegisterClass(const LoadProc,StoreProc:Pointer;Sender:tClass);
begin
 ClassRegistry.AddObject(Sender.ClassName,
                         tRegisterRec.Create(Sender,LoadProc,StoreProc));
end;

Function  IsRegistered(AClass:tClass):Boolean;
Var Index:Integer;
begin
 Result:=ClassRegistry.Find(AClass.ClassName,Index);
end;

(**************************************************************************)
Function   GetRegistration(AName:tClassName):tRegisterRec;
Var Index:Integer;
begin
 With ClassRegistry do
  If Find(AName,Index)
   then Result:=tRegisterRec(Objects[Index])
   else Result:=Nil;
end;

Function   CreateInstanceByName(const Name:tClassName;Var Loader:Pointer):tObject;
Var R:tRegisterRec;
begin
 R:=GetRegistration(Name);
 If R<>Nil
  then begin
   Result:=R.Obj.Create;
   Loader:=R.DoLoad;
  end
  else Raise EClassNotFound.CreateFmt('Class <%s> not registered',[Name]);
end;

Procedure  CallStreamProc(Obj:tObject; S:tStream; SProc:Pointer);
begin
 asm
   {$IFDEF WINDOWS}
    Les   Di,S
    Push  Es
    Push  Di
    Les   Di,Obj
    Push  Es
    Push  Di
    Call  DWord ptr SProc; (* Call Obj's Load or Store proc *)
   {$ELSE}
   (*  In delphi32 : using registers calling
    EAX = pointer to Obj
    EDX = pointer to S
    ECX = SProc
   *)
    Call ECX  (* Jmp ??? *)
   {$ENDIF}
 end;
end;

Function   CopyOf(Source:tObject):tObject;
Var S:tMemoryStream;
begin
 If Source<>nil
  then begin
    S:=tMemoryStream.Create;
   try
    WriteObjectToStream(Source,S);
    S.Seek(0,0);    (* Rewind to beginning *)
    Result:=ReadObjectFromStream(S);
   Finally
    S.Free;
   end;
  end
 else Raise EClassNotFound.Create('Nil Source Class!');
end;

(***********************************************************)
Function   ReadObjectFromStream(S:tStream):tObject;
Var Name:tClassName;
    LoadProc:Pointer;
    NameLen: Integer;
begin  (* Read the object name *)
 S.ReadBuffer(NameLen,1);
 S.ReadBuffer(Name[1],NameLen);
  (* If Name is valid (registered)... *)
 Result:=CreateInstanceByName(Name,LoadProc);
  (* Then ask it to load itself *)
 CallStreamProc(Result,S,LoadProc);
end;

Procedure  WriteObjectToStream(Source:tObject; S:tStream);
Var R:tRegisterRec;
    Name:tClassName;
    NameSize: Byte;
begin
 If Source<>nil
  then begin
   Name:=Source.ClassName;
   R:=GetRegistration(Name);
   If R=Nil
    then Raise EClassNotFound.CreateFmt('Source Class <%s> not registered',[Name]);
    (* First write out the object name *)
   NameSize := Byte(Length(Name)*SizeOf(Char));
   S.WriteBuffer(NameSize,Length(Name)*SizeOf(Char));
   S.WriteBuffer(Name[1],(Length(Name)* sizeof(Char)));
    (* And ask the object to write itself to S *)
   CallStreamProc(Source,S,R.DoStore); (* S now contains Source *)
  end
 else Raise EClassNotFound.Create('Nil Source Class!');
end;


(**************************************************************************)
Constructor tObjectList.Create;
begin
 Inherited Create;
 FCount:=0;
 FCapacity:=0;
 FDestroy:=True;
end;

Constructor tObjectList.CreateWithOptions(DestroyObjects:Boolean; InitialCapacity:tOLSize);
begin
 Create;
 FDestroy:=DestroyObjects;
 SetCapacity(InitialCapacity);
end;

Constructor tObjectList.CreateFromStream(const FileName: string);
begin
 Create;
 LoadFromStream(FileName);
end;

destructor tObjectList.Destroy;
begin
 FreeAll;
 Clear;
 Inherited Destroy;
end;

function tObjectList.AddObject(Item: tObject): tOLSize;
begin
 Result := FCount;
 if Result = FCapacity
  then Grow;
 FList^[Result] := Item;
 Inc(FCount);
end;

(**************************************************)
(* Clear does not free it's objects. It's the same*)
(* as calling DeleteAll                           *)
(**************************************************)
procedure tObjectList.Clear;
begin
 SetCount(0);
 SetCapacity(0);
end;

(**************************************************)
(* To provide some kind of support of tWriter &   *)
(* tReader classes.     Not yet tested            *)
(**************************************************)
procedure tObjectList.DefineProperties(Filer: TFiler);
begin
 Filer.DefineBinaryProperty('ObjectContainer', ReadData, WriteData, FCount>0);
end;

(**************************************************)
(* Add stream content to existing items           *)
(**************************************************)
procedure tObjectList.ReadData(S: TStream);
Var ObjCount,
    Index:tOLSize;
begin
 S.ReadBuffer(FDestroy,SizeOf(FDestroy));
 S.ReadBuffer(ObjCount,SizeOf(Objcount));  (* Read in Object count *)
 If FCapacity-FCount<ObjCount
  then SetCapacity(FCount+ObjCount);

   (* Read in Object Count *)
 For Index:=0 to ObjCount-1
  do AddObject(ReadObjectFromStream(S));
end;

      (* Write list to Stream *)
procedure tObjectList.WriteData(S: TStream);

 Procedure WriteItem(ThisItem:tObject);{far;}
 begin
  WriteObjectToStream(ThisItem,S);
 end;
Var Index,
    ObjCount:tOlSize;
begin
 S.WriteBuffer(FDestroy,SizeOf(FDestroy));
 ObjCount:=FCount;
 S.WriteBuffer(ObjCount,SizeOf(ObjCount));
  For Index:=0 to FCount-1
  do WriteObjectToStream(Items[Index],S);
 {ForEach(@WriteItem);}
end;

(**************************************************)
(* Overwrite if Items are not objects             *)
(**************************************************)
Procedure tObjectList.FreeItem(AnItem:Pointer);
begin
 If FDestroy
  then tObject(AnItem).Free;
end;

procedure tObjectList.Delete(Index: tOLSize);
begin
 if (Index < 0) or (Index >= FCount)
  then Error;
 Dec(FCount);
 if Index < FCount
  then System.Move(FList^[Index+1],
                   FList^[Index],
                   (FCount-Index)*SizeOf(tObject));
end;

procedure tObjectList.DeleteAll;
begin
 Clear;
end;

procedure tObjectList.FreeAt(Index: tOLSize);
begin
 if (Index < 0) or (Index >= FCount) then Error;
 FreeItem(FList^[Index]);
 Delete(Index);
end;

procedure tObjectList.FreeAll;
 Procedure DoFree(AnItem:Pointer); far;
 begin
  FreeItem(AnItem);
 end;
 Var Index:tOLSize;
begin
 For Index:=0 to FCount-1
  do FreeItem(FList^[Index]);
{ ForEach(@DoFree);}
 Clear;
end;

Procedure tObjectList.FreeObject(Item: tObject);
begin
 try
  FreeAt(IndexOf(Item));
 Except on EListError do
   Raise EListError.CreateFmt('tObject %s not in item list',[Item.ClassName]);end;
end;

procedure tObjectList.Error;
begin
{$IFDEF DELPHI_BCB_3}    { added D3 support 5-26-97  KLB }
	raise EListError.Create(SListIndexError);            {  This is for Delphi & BCB version 3  }
{$ELSE}
	raise EListError.Create(LoadStr(SListIndexError));   { version 1 and 2 and BCB 1 }
{$ENDIF}
end;

function tObjectList.Get(Index: tOLSize): tObject;
begin
 if (Index < 0) or (Index >= FCount)
  then Error;
 Result := FList^[Index];
end;

procedure tObjectList.Grow;
Var Delta:tOLSize;
begin
 if FCapacity > 8
  //then Delta := 16  // Changed to below 2/6/2006
  then Delta    := Round(Sqrt(FCapacity))  // to better handle zips with large # of files
  else if FCapacity > 4
        then Delta := 8
        else Delta := 4;
 SetCapacity(FCapacity+Delta);
end;

function tObjectList.IndexOf(Item: tObject): tOLSize;
begin
 Result := 0;
 while (Result < FCount) and (FList^[Result] <> Item)
  do Inc(Result);
 if Result = FCount
  then Result := -1;
end;

procedure tObjectList.Insert(Index: tOLSize; Item: tObject);
begin
 if (Index < 0) or (Index > FCount)
  then Error;
 if FCount = FCapacity
  then Grow;
 If FCount=0
  then FList^[0]:=Item
  else begin
   System.Move(FList^[Index], FList^[Index+1], (FCount-Index)*SizeOf(tObject));
   FList^[Index] := Item;
  end;
 Inc(FCount);
end;

function tObjectList.First: tObject;
begin
 Result:= Get(0);
end;

function tObjectList.Last: tObject;
begin
 Result := Get(FCount - 1);
end;
(**************************************************)
(* Call Next with a direction flag (forward=True  *)
(* or false. Returns Nil At end or at beginning   *)
(**************************************************)
(*
 O:=First
 repeat
  ...
  O:=Next(O,True);
 until O=Nil;
*)
Function    tObjectList.Next(Item:tObject; Forward:Boolean):tObject;
Const cDirection: Array[False..True] of Integer=(-1,1);
Var Index: tOLSize;
begin
 If Item=Nil
  then If Forward
        then result:=First
        else Result:=Last
  else begin
   Index:=IndexOf(Item);
   If Index>=0  (* If Object not found, Raise *)
    Then begin
     Index:=Index+cDirection[Forward];
     If (Index>=0) and (Index<FCount)
      then Result:=FList^[Index]
      else Result:=Nil;
    end
    else Raise EListError.CreateFmt('tObject %s not in item list',[Item.ClassName]);
  end;
end;

procedure tObjectList.Move(CurIndex, NewIndex: tOLSize);
var Item: tObject;
begin
 if CurIndex <> NewIndex
  then begin
   if (NewIndex < 0) or (NewIndex >= FCount)
    then Error;
   Item := Get(CurIndex);
   Delete(CurIndex);
   Insert(NewIndex, Item);
  end;
end;

procedure tObjectList.Put(Index: tOLSize; Item: tObject);
begin
 if (Index < 0) or (Index >= FCount)
  then Error;
 FList^[Index] := Item;
end;

procedure tObjectList.Pack;
var
  I: Integer;
begin
 for I := FCount - 1 downto 0
  do if Items[I] = nil
      then Delete(I);
end;

procedure tObjectList.SetCapacity(NewCapacity: tOLSize);
var NewList: pObjects;
begin
 if NewCapacity<>FCapacity
  then begin
   if (NewCapacity < FCount) or (NewCapacity>=cMaxList)
    then Error;
   if NewCapacity=0
    then NewList := nil
    else begin
     NewList:=Allocate(NewCapacity * SizeOf(tObject));
     if FCount<>0
      then System.Move(FList^, NewList^, FCount * SizeOf(tObject));
    end;
   if FCapacity<>0
    then FreeMem(FList, FCapacity * SizeOf(tObject));
   FList := NewList;
   FCapacity := NewCapacity;
  end;
end;

procedure tObjectList.SetCount(NewCount: tOLSize);
begin
 if (NewCount < 0) or (NewCount >= cMaxList)
  then Error;
 if NewCount > FCapacity
  then SetCapacity(NewCount);
 if NewCount > FCount
  then FillChar(FList^[FCount], (NewCount - FCount) * SizeOf(tObject), 0);
 FCount := NewCount;
end;

(**************************************************)
(* Will create Filename and overwrite any existing*)
(* file of the same name                          *)
(**************************************************)
Procedure   tObjectList.SaveToStream(const FileName:String);
Var S:tFileStream;
begin
 S:=tFileStream.Create(FileName,fmCreate);
 try
  WriteData(S);
 Finally
  S.Free;
 end;
end;

(* LoadFromStream will add the Stream's content to it's current items *)
procedure   tObjectList.LoadFromStream(const FileName: string);
Var S:tFileStream;
begin
 S:=tFileStream.Create(FileName,fmOpenRead);
 try
  ReadData(S)
 Finally
  S.Free;
 end;
end;



(* These three methods where taken as is from the BP7 RTL
   the only change required was class name from tCollection
   to tObjectList and 32 bit support *)
procedure TObjectList.ForEach(Action: Pointer); assembler;
asm
{$IFDEF WINDOWS}
      LES     DI,Self
      MOV     CX,ES:[DI].TObjectList.FCount
      JCXZ    @@2
      LES     DI,ES:[DI].tObjectList.FList
@@1:  PUSH    ES
      PUSH    DI
      PUSH    CX
      PUSH    WORD PTR ES:[DI+2]
      PUSH    WORD PTR ES:[DI]
      MOV     AX,[BP]
      AND     AL,0FEH
      PUSH    AX
      CALL    Action
      POP     CX
      POP     DI
      POP     ES
      ADD     DI,4
{$ELSE} (* EAX = Self *)
        (* EDX = Action *)
      {$IFDEF Comp16_32Streams}
      Xor     ECX,ECX
      Mov     CX,[EAX].TObjectList.FCount
      {$ELSE}
      Mov     ECX,[EAX].TObjectList.FCount
      {$ENDIF}
      JCXZ    @@2
      Mov     EDI,[EAX].TObjectList.FList
      Mov     ESI,EDX
@@1:  Push    ECX
      Push    EDI
      Push    EDX
      Push    EBP(* Set stack frame *)
      Mov     EAX, [EDI]    (* Current List item *)
      Call    EDX
      Pop     EBP
      Pop     EDX
      Pop     EDI
      Pop     ECX
      Add     EDI,4    (* Next Item *)
{$ENDIF}
      Loop    @@1
@@2:
End;



function tObjectList.FirstThat(Test: Pointer): tObject; assembler;
asm
{$IFDEF WINDOWS}
        LES     DI,Self
        MOV     CX,ES:[DI].tObjectList.FCount
        JCXZ    @@2
        LES     DI,ES:[DI].tObjectList.FList
@@1:    PUSH    ES
        PUSH    DI
        PUSH    CX
        PUSH    WORD PTR ES:[DI+2]
        PUSH    WORD PTR ES:[DI]
        MOV	    AX,[BP]
        AND	    AL,0FEH
        PUSH	 AX
        CALL    Test
        POP     CX
        POP     DI
        POP     ES
        OR      AL,AL
        JNE     @@3
        ADD     DI,4
        LOOP    @@1
@@2:    XOR     AX,AX
        MOV     DX,AX
        JMP     @@4
@@3:	  MOV	    AX,ES:[DI]
	     MOV	    DX,ES:[DI+2]
{$ELSE} (*    32 bit  *)
        (* EAX = Self *)
        (* EDX = Test *)
      {$IFDEF Comp16_32Streams}
      Xor     ECX,ECX
      Mov     CX,[EAX].TObjectList.FCount
      {$ELSE}
      Mov     ECX,[EAX].TObjectList.FCount
      {$ENDIF}
      JCXZ    @@2
      Mov     EDI,[EAX].TObjectList.FList
 (*     Mov     ESI,EDX*)
@@1:  Push    ECX
      Push    EDX           (* Bug fix. ESI/EDI could be zapped!! *)
      Push    EDI
      Push    EBP           (* Set stack frame *)
      Mov     EAX, [EDI]    (* Current List item *)
      Call    EDX
      Pop     EBP
      Pop     EDI
      Pop     EDX
      Pop     ECX
      Or      Al,Al    (* True result ? *)
      Jne     @@3
      Add     EDI,4    (* Next Item *)
      LOOP    @@1
@@2:
      Xor     EAX,EAX
      Jmp     @@4
@@3:  Mov     EAX, [EDI]    (* Current List item *)
{$ENDIF}
@@4:   
End;



function tObjectList.LastThat(Test: Pointer): tObject; assembler;
asm
{$IFDEF WINDOWS}
        LES     DI,Self
        MOV     CX,ES:[DI].tObjectList.FCount
        JCXZ    @@2
        LES     DI,ES:[DI].tObjectList.FList
        MOV     AX,CX
        SHL     AX,1
        SHL     AX,1
        ADD     DI,AX
@@1:    SUB     DI,4
        PUSH    ES
        PUSH    DI
        PUSH    CX
        PUSH    WORD PTR ES:[DI+2]
        PUSH    WORD PTR ES:[DI]
        MOV	AX,[BP]
        AND	AL,0FEH
        PUSH	AX       (* Set stack frame for Test *)
        CALL    Test
        POP     CX
        POP     DI
        POP     ES
        OR      AL,AL
        JNE     @@3
        LOOP    @@1
@@2:    XOR     AX,AX
        MOV     DX,AX
        JMP     @@4
@@3:	  MOV     AX,ES:[DI]
    	MOV	    DX,ES:[DI+2]
{$ELSE} (* EAX = Self *)
        (* EDX = Test *)
      {$IFDEF Comp16_32Streams}
      Xor     ECX,ECX
      Mov     CX,[EAX].TObjectList.FCount
      {$ELSE}
      Mov     ECX, [EAX].TObjectList.FCount
      {$ENDIF}
      JCXZ    @@2
      Mov     EDI,[EAX].TObjectList.FList
      Mov     EAX,ECX
      SHL     EAX,2
      Add     EDI,EAX
@@1:  Sub     EDI,4    (* preceding Item *)
      Push    ECX
      Push    EDX
      Push    EDI
      Push    EBP(* Set stack frame *)
      Mov     EAX, [EDI]    (* Current List item *)
      Call    EDX
      Pop     EBP
      Pop     EDI
      Pop     EDX
      Pop     ECX
      Or      Al,Al    (*  True result ? *)
      Jne     @@3
      LOOP    @@1
@@2:
      Xor     EAX,EAX
      Jmp     @@4
@@3:  Mov     EAX, [EDI]    (* Current List item *)
{$ENDIF}
@@4:
end;

Function  tObjectList.Allocate(Size:LongInt):Pointer;
begin
 GetMem(Result,Size);
end;


constructor TSortedObjectList.Create(WithDuplicates:TDuplicates);
begin
  inherited Create;
  FDuplicates:=WithDuplicates;
end;

procedure TSortedObjectList.ReadData(S:TStream);
begin
  S.ReadBuffer(FDuplicates,sizeof(FDuplicates));
  inherited ReadData(S);
end;

procedure TSortedObjectList.WriteData(S:TStream);
begin
  S.WriteBuffer(FDuplicates,sizeof(FDuplicates));
  inherited WriteData(S);
end;

Function TSortedObjectList.AddObject(Item: tObject): tOLSize;
Var Position:tOLSize;
begin
 Position := 0;
 Insert(Position, Item);
 Result := Position;
end;

{ ignores the Index-Value! }
procedure TSortedObjectList.Insert(Index: tOLSize; Item: tObject);
begin
  If Search(KeyOf(Item),Index)
   then Case FDuplicates of
         DupIgnore: Exit;
         DupError : Raise EListError.Create('Duplicate Object index');
        end;
  inherited Insert(Index,Item);
end;


function TSortedObjectList.KeyOf(Item:TObject):Pointer;
begin
  Result:=Item;
end;

function TSortedObjectList.IndexOf(Item: tObject): tOLSize;
begin
 If not Search(KeyOf(Item),Result)
  then Result:=-1;
end;

function TSortedObjectList.Search(Key:Pointer; var Index:tOLSize):boolean;
var
  L, H, I, C: tOLSize;
begin
  Result := False;
  L := 0;
  H := Count - 1;
  while L <= H do
  begin
    I := (L + H) shr 1;
    C := Compare(KeyOf(Items[I]), Key);
    if C < 0 then L := I + 1 else
    begin
      H := I - 1;
      if C = 0 then
      begin
        Result := True;
        if Duplicates<>dupAccept then L := I;
      end;
    end;
  end;
  Index := L;
end;

procedure TSortedObjectList.Put(Index: tOLSize; Item: tObject);
begin
 Raise EListError.Create('Cannot <Put> an Object in a sorted list!');
end;


            (* tAbsMemStream *)
{$IFDEF WINDOWS}
procedure __AHSHIFT; far; external 'KERNEL' index 113;
function OffsetPointer(P: Pointer; Ofs: Longint): Pointer; assembler;
asm
        MOV     AX,Ofs.Word[0]
        MOV     DX,Ofs.Word[2]
        ADD     AX,P.Word[0]
        ADC     DX,0
        MOV     CX,OFFSET __AHSHIFT
        SHL     DX,CL
        ADD     DX,P.Word[2]
end;
{$ENDIF}
Constructor tAbsMemStream.Create(UseBuf:Pointer; MaxSize:LongInt);
begin
 Inherited Create;
 FMemory:=UseBuf;
 FSize:=MaxSize;
 FPosition := 0;
end;

function tAbsMemStream.Read(var Buffer; Count: Longint): Longint;
begin
 if (FPosition >= 0) and (Count >= 0) then
 begin
  Result := FSize - FPosition; (* Remaining buffer *)
  if Result >= Count
   then Result:=Count
   else Raise EStreamError.Create('MemStream reading behond limits');
  {$IFDEF WINDOWS}
  hmemcpy(@Buffer, OffsetPointer(FMemory, FPosition), Result);
  {$ELSE}
  Move(Pointer(Longint(FMemory) + FPosition)^, Buffer, Result);
  {$ENDIF}
  Inc(FPosition, Result);
 end
 else Result := 0;
end;

function tAbsMemStream.Write(const Buffer; Count: Longint): Longint;
var Pos: Longint;
begin
 if (FPosition >= 0) and (Count >= 0)
  then begin
   Pos := FPosition + Count; (* Ending FPosition *)
   If (Pos>=FSize)
    then Raise EStreamError.Create('MemStream writing behond limits');
   {$IFDEF WINDOWS}
   hmemcpy(OffsetPointer(FMemory, FPosition), @Buffer, Count);
   {$ELSE}
    System.Move(Buffer, Pointer(Longint(FMemory) + FPosition)^, Count);
   {$ENDIF}
   FPosition := Pos;
   Result := Count;
  end
 else Result := 0;
end;

function tAbsMemStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
 case Origin of
   0: FPosition := Offset;
   1: Inc(FPosition, Offset);
   2: FPosition := FSize - Offset;
 end;
 If (FPosition>FSize) Or (FPosition<0)
  then Raise EStreamError.Create('MemStream seeking behond limits');
 Result := FPosition;
end;

(*************************************************)
(*          Clipboard related                    *)
(*************************************************)
Function RegisterClipBoardType(const TypeName:String):Word;
Var Name:pChar;
begin
 GetMem(Name,(Length(TypeName)*SizeOf(Char))+1);
 StrpCopy(Name,TypeName);
 Result:=RegisterClipBoardFormat(Name);
 FreeMem(Name,(Length(TypeName)*SizeOf(Char))+1);
end;


function CopyObjectToClipboard(ClipType:word; Source:TObject):boolean;
var
  S:tMemoryStream;
  MemHandle:THandle;
  MemPtr:Pointer;
begin
  If Source<>nil
   then begin
    Result:=False;
      S:=tMemoryStream.Create;
    try
      WriteObjectToStream(Source,S);
      S.Seek(0,0);                       		 (* Rewind to beginning *)
      MemHandle:=GlobalAlloc(GHND,S.Size);  	{allocate memory }
      If MemHandle=0
       then raise EOutOfMemory.Create('Not enough memory to copy object to clipboard');
      MemPtr:=GlobalLock(MemHandle);
      S.Read(MemPtr^,S.Size);  		{ read in the stream contents into MemPtr}
      GlobalUnlock(MemHandle);
      if SetClipboardData(ClipType, MemHandle)=0
       then GlobalFree(MemHandle)
       else Result:=true;
     Finally  S.Free;
    end;
  end
 else Raise EClassNotFound.Create('Nil Source Class!');
end;

function PasteObjectFromClipboard(ClipType:word):TObject;
var
  MemHandle:THandle;
  clipData:Pointer;
  ClipSize:longint;
  S:TAbsMemStream;
begin
  Result:=Nil;
  MemHandle:=GetClipBoardData(ClipType);
  if MemHandle<>0 then
  begin
    ClipSize:=GlobalSize(MemHandle);
    ClipData:=GlobalLock(MemHandle);
    S:=tAbsMemStream.Create(ClipData,ClipSize);
    try
      Result:=ReadObjectFromStream(S);
    finally
      GlobalUnlock(MemHandle);
      S.Free;
    end;
  end;
end;

{$IFNDEF WIN32}
(*************************************************)
Procedure tContainExitProc; far;
Var Idx:Integer;
begin
 For Idx:=0 to ClassRegistry.Count-1
  do (ClassRegistry.Objects[Idx] as tRegisterRec).Free;
 ClassRegistry.Free;
end;
{$ENDIF}

(*************************************************)
               Initialization
(*************************************************)
 ClassRegistry:=tStringList.Create;
 ClassRegistry.Sorted:=True;
 ClassRegistry.Duplicates:=dupIgnore;
 {$IFNDEF WIN32}
 AddExitProc(tContainExitProc);
 {$ENDIF}

{$IFDEF WIN32}
(*************************************************)
 Finalization
(*************************************************)
 FIdx := 0;
 While FIdx < ClassRegistry.Count do
  begin
     (ClassRegistry.Objects[FIdx] as tRegisterRec).Free;
     Inc(FIdx);
  end;
 ClassRegistry.Free;
{$ENDIF}

end.







