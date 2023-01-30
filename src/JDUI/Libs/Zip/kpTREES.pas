{ ********************************************************************************** }
{                                                                                    }
{ 	 COPYRIGHT 1997 Kevin Boylan                                                    }
{     Source File: Trees.pas                                                         }
{     Description: VCLZip component - native Delphi zip component.                   }
{     Date:        March 1997                                                        }
{     Author:      Kevin Boylan, CIS: boylank                                        }
{                                Internet: boylank@compuserve.com                    }
{                                                                                    }
{ ********************************************************************************** }

{ $Log:  10050: kpTREES.pas 
{
{   Rev 1.0    8/14/2005 1:10:08 PM  KLB    Version: VCLZip Pro 3.06
{ Initial load of VCLZip Pro on this computer
}
{
{   Rev 1.0    10/15/2002 8:15:18 PM  Supervisor
}
{
{   Rev 1.1    9/3/2002 10:50:04 PM  Supervisor
{ Mod for FILE_INT
}
{
{   Rev 1.0    9/3/2002 8:16:52 PM  Supervisor
}
{
{   Rev 1.1    7/9/98 6:47:18 PM  Supervisor
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

{$P-} { turn off open parameters }
{$Q-} { turn off overflow checking }
{$R-} { turn off range checking }
{$B-} { turn off complete boolean eval } { 12/24/98  2.17 }

{* ===========================================================================
 * Initialize a new block.
 *}
procedure init_block;
var
  n:    Integer; { iterates over tree elements }
begin
    { Initialize the trees. }
    for n := 0 to L_CODES-1 do
     dyn_ltree[n].fc.freq := 0;
    for n := 0 to D_CODES-1 do
     dyn_dtree[n].fc.freq := 0;
    for n := 0 to BL_CODES-1 do
     bl_tree[n].fc.freq := 0;

    dyn_ltree[END_BLOCK].fc.freq := 1;
    opt_len := 0;
    static_len := 0;
    last_lit := 0;
    last_dist := 0;
    last_flags := 0;
    flags := 0; flag_bit := 1;
end;

{* ===========================================================================
 * Compares to subtrees, using the tree depth as tie breaker when
 * the subtrees have equal frequency. This minimizes the worst case length.
 *}
function smaller( tree: ct_dataArrayPtr; n, m: LongInt ): Boolean;
begin
   Result := (tree^[n].fc.freq < tree^[m].fc.freq) or
             ((tree^[n].fc.freq = tree^[m].fc.freq) and
             (depth[n] <= depth[m]));
end;

{ $IFDEF SKIPCODE}
procedure send_code( c: LongInt; tree: ct_dataArrayPtr );
begin
  send_bits( Integer(tree^[c].fc.code), Integer(tree^[c].dl.len) );
end;
{ $ENDIF}

function d_code( d: Integer ): Byte;
begin
  If d < 256 then
   begin
     Result := dist_code[d]
   end
  Else
   begin
     Result := dist_code[256+(d shr 7)];
   end;
end;

procedure set_file_type;
var
  n:          LongInt;
  ascii_freq: usigned;
  bin_freq:   usigned;
begin
    n := 0;
    ascii_freq := 0;
    bin_freq := 0;
    while (n < 7) do
     begin
        Inc(bin_freq,dyn_ltree[n].fc.freq);
        Inc(n);
     end;
    while (n < 128) do
     begin
        Inc(ascii_freq,dyn_ltree[n].fc.freq);
        Inc(n);
     end;
    while (n < LITERALS) do
     begin
        Inc(bin_freq,dyn_ltree[n].fc.freq);
        Inc(n);
     end;
    If (bin_freq > (ascii_freq shr 2)) then
     tmpfile_info.internal_file_attributes := BINARY
    Else
     tmpfile_info.internal_file_attributes := ASCII;
end;

{* ===========================================================================
 * Generate the codes for a given tree and bit counts (which need not be
 * optimal).
 * IN assertion: the array bl_count contains the bit length statistics for
 * the given tree and the field len is set for all tree elements.
 * OUT assertion: the field code is set for all tree elements of non
 *     zero code length.
 *}
procedure gen_codes (tree: ct_dataArrayPtr; max_code: Integer);{checked out 6/14}
var
    { tree = the tree to decorate }
    { max_code =  largest code with non zero frequency }
    next_code:   array [0..MAX_ZBITS] of WORD; { next code value for each bit length }
    code:        WORD;                  { running code value }
    bits:        Integer;               { bit index }
    n:           LongInt;               { code index }
    len:         Integer;
begin

    {* The distribution counts are first used to generate the code values
     * without bit reversal.
     *}
    code := 0;
    for bits := 1 to MAX_ZBITS do
     begin
        {$IFOPT R+}
          {$DEFINE RWASON}
          {$R-}
        {$ENDIF}
        code := WORD((code + bl_count[bits-1])) shl 1;
        {$IFDEF RWASON}
          {$R+}
          {$UNDEF RWASON}
        {$ENDIF}
        next_code[bits] := code;
     end;
    {* Check that the bit counts in bl_count are consistent. The last code
     * must be all ones.
     *}

    {$IFDEF ASSERTS}
    Assert (code + bl_count[MAX_ZBITS]-1 = (1 shl MAX_ZBITS)-1,
            'inconsistent bit counts-gencodes');
    {$ENDIF}

    for n := 0 to max_code do
     begin
        len := tree^[n].dl.len;
        if (len = 0) then continue;
        { Now reverse the bits }
        tree^[n].fc.code := bi_reverse(next_code[len], len);
        Inc(next_code[len]);
        {Tracec(tree != static_ltree, (stderr,"\nn %3d %c l %2d c %4x (%x) ",
             n, (isgraph(n) ? n : ' '), len, tree[n].Code, next_code[len]-1));}
     end;
end;

procedure tr_static_init;
var
    n:        LongInt;     { iterates over tree elements }
    bits:     LongInt;     { bit counter }
    blength:   LongInt;     { length value }
    code:     LongInt;     { code value }
    dist:     LongInt;     { distance index }
begin
    { Initialize the mapping length (0..255) -> length code (0..28) }

    if TRInitialized then
        exit;

    blength := 0;
    for code := 0 to LENGTH_CODES-2 do
     begin
        base_length[code] := blength;
        for n := 0 to (1 shl extra_lbits[code])-1 do
         begin
            length_code[blength] := code;
            Inc(blength);
         end;
     end;

    {$IFDEF ASSERTS}
    Assert (blength = 256, 'ct_init: length <> 256');
    {$ENDIF}

    {* Note that the length 255 (match length 258) can be represented
     * in two different ways: code 284 + 5 bits or code 285, so we
     * overwrite length_code[255] to use the best encoding:
     *}
    code := LENGTH_CODES-1;
    length_code[blength-1] := code;

    { Initialize the mapping dist (0..32K) -> dist code (0..29) }
    dist := 0;
    for code := 0 to 15 do
     begin
        base_dist[code] := dist;
        for n := 0 to (1 shl extra_dbits[code])-1 do
         begin
            dist_code[dist] := code;
            Inc(dist);
         end;
     end;

    {$IFDEF ASSERTS}
    Assert (dist = 256, 'ct_init: dist <> 256');
    {$ENDIF}

    dist := dist shr 7; { from now on, all distances are divided by 128 }
    code := 16;
    while code < D_CODES do
     begin
        base_dist[code] := dist shl 7;
        for n := 0 to (1 shl (extra_dbits[code]-7))-1 do
         begin
            dist_code[256 + dist] := code;
            Inc(dist);
         end;
        Inc(code);
     end;

    {$IFDEF ASSERTS}
    Assert (dist = 256, 'ct_init: 256+dist <> 512');
    {$ENDIF}

    { Construct the codes of the static literal tree }
    for bits := 0 to MAX_ZBITS do
     bl_count[bits] := 0;
    n := 0;
    while (n <= 143) do
     begin
        static_ltree[n].dl.len := 8;
        Inc(n);
        Inc(bl_count[8]);
     end;
    while (n <= 255) do
     begin
        static_ltree[n].dl.len := 9;
        Inc(n);
        Inc(bl_count[9]);
     end;
    while (n <= 279) do
     begin
        static_ltree[n].dl.len := 7;
        Inc(n);
        Inc(bl_count[7]);
     end;
    while (n <= 287) do
     begin
        static_ltree[n].dl.len := 8;
        Inc(n);
        Inc(bl_count[8]);
     end;
    {* Codes 286 and 287 do not exist, but we must include them in the
     * tree construction to get a canonical Huffman tree (longest code
     * all ones)
     *}
    gen_codes(ct_dataArrayPtr(@static_ltree), L_CODES+1);  { added typecast 5/18/98  2.13 }

    { The static distance tree is trivial: }
    for n := 0 to D_CODES-1 do
     begin
        static_dtree[n].dl.len := 5;
        static_dtree[n].fc.code := bi_reverse(n, 5);
     end;
    TRInitialized := True;
end;

{* ===========================================================================
 * Allocate the match buffer, initialize the various tables and save the
 * location of the internal file attribute (ascii/binary) and method
 * (DEFLATE/STORE).
 *}
procedure ct_init;
begin
    tr_static_init;
    compressed_len := 0;
    input_len := 0;
    bi_buf := 0;
    bi_valid := 0;
    {$IFOPT D+}
    {$IFDEF KPDEBUG}
    bits_sent := 0;
    {$ENDIF}
    {$ENDIF}
    { Initialize the first block of the first file: }
    init_block;
end;  { ct_init }

function ct_tally( dist,lc: Integer ): Boolean;
var
  out_length:    LongInt;
  in_length:     LongInt;
  dcode:         Integer;
begin
  l_buf^[last_lit] := lc;
  Inc(last_lit);
  If dist = 0 then
     Inc(dyn_ltree[lc].fc.freq)
  Else
   begin
     Dec(dist);

     {$IFDEF ASSERTS}
     Assert( (dist < MAX_DIST) and (lc <= MAX_MATCH-MIN_MATCH) and
             (d_code(dist) < D_CODES), 'ct_tally: bad match' );
     {$ENDIF}

     Inc(dyn_ltree[length_code[lc]+LITERALS+1].fc.freq);
     Inc(dyn_dtree[d_code(dist)].fc.freq);
     d_buf^[last_dist] := dist;
     Inc(last_dist);
     flags := (flags or flag_bit);
   end;
   {$IFOPT R+}
     {$DEFINE RWASON}
     {$R-}
   {$ENDIF}
   flag_bit := flag_bit shl 1;
   {$IFDEF RWASON}
     {$R+}
     {$UNDEF RWASON}
   {$ENDIF}
    If ((last_lit and 7) = 0) then
    begin
     flag_buf^[last_flags] := flags;
     Inc(last_flags);
     flags := 0; flag_bit := 1;
    end;
    If (FPackLevel > 2) and ((last_lit and $FFF) = 0) then
     begin
        out_length := last_lit * 8;
        in_length := strstart - block_start;
        for dcode := 0 to D_CODES-1 do
           Inc(out_length,LongInt(LongInt(dyn_dtree[dcode].fc.freq)*LongInt(5+extra_dbits[dcode])));
        out_length := out_length shr 3;
        if (last_dist < last_lit div 2) and (out_length < in_length div 2) then
         begin
           Result := True;
           exit;
         end;
     end;
    Result := (last_lit = LIT_BUFSIZE-1) or (last_dist = DIST_BUFSIZE);
end;

{* ===========================================================================
 * Restore the heap property by moving down the tree starting at node k,
 * exchanging a node with the smallest of its two sons if necessary, stopping
 * when the heap property is re-established (each father smaller than its
 * two sons).
 *}
procedure pqdownheap(tree: ct_dataArrayPtr; k: LongInt);
var
    { tree    = the tree to restore }
    { k       = node to move down }
    v:     LongInt;
    j:     LongInt;  { left son of k }
    htemp: LongInt;  { required because of bug in SASC compiler }
begin
     v := heap[k];
     j := k shl 1;
    while (j <= heap_len) do
     begin
        { Set j to the smallest of the two sons: }
        if (j < heap_len) and (smaller(tree, heap[j+1], heap[j])) then
           Inc(j);

        { Exit if v is smaller than both sons }
        htemp := heap[j];
        if (smaller(tree, v, htemp)) then
           break;

        { Exchange v with the smallest son }
        heap[k] := htemp;
        k := j;

        { And continue down the tree, setting j to the left son of k }
        j := j shl 1;
    end;
    heap[k] := v;
end;

procedure pqremove( tree: ct_dataArrayPtr; var top: LongInt);
begin
  top := heap[SMALLEST];
  heap[SMALLEST] := heap[heap_len];
  Dec(heap_len);
  pqdownheap(tree, SMALLEST);
end;

{* ===========================================================================
 * Compute the optimal bit lengths for a tree and update the total bit length
 * for the current block.
 * IN assertion: the fields freq and dad are set, heap[heap_max] and
 *    above are the tree nodes sorted by increasing frequency.
 * OUT assertions: the field len is set to the optimal bit length, the
 *     array bl_count contains the frequencies for each bit length.
 *     The length opt_len is updated; static_len is also updated if stree is
 *     not null.
 *}
procedure gen_bitlen(desc: tree_desc);  { Checked out 6/14}
var
    { desc    = the tree descriptor }
    tree:           ct_dataArrayPtr;
    extra:          IntegerArrayPtr;
    base:           LongInt;
    max_code:       LongInt;
    max_length:     LongInt;
    stree:          ct_dataArrayPtr;
    h:              LongInt;         { heap index }
    n, m:           LongInt;         { iterate over the tree elements }
    bits:           LongInt;         { bit length }
    xbits:          LongInt;         { extra bits }
    f:              WORD;            { frequency }
    overflow:       LongInt;         { number of elements with bit length too large }
begin
    tree := desc.dyn_tree;
    extra := desc.extra_bits;
    base := desc.extra_base;
    max_code := desc.max_code;
    max_length := desc.max_length;
    stree := desc.static_tree;
    overflow := 0;

    for bits := 0 to MAX_ZBITS do
     bl_count[bits] := 0;

    {* In a first pass, compute the optimal bit lengths (which may
     * overflow in the case of the bit length tree).
     *}
    tree^[heap[heap_max]].dl.len := 0; { root of the heap }

    for h := heap_max+1 to HEAP_SIZE-1 do
     begin
        n := heap[h];
        bits := tree^[tree^[n].dl.dad].dl.len + 1;
        if (bits > max_length) then
         begin
           bits := max_length;
           Inc(overflow);
         end;
        tree^[n].dl.len := bits;
        { We overwrite tree[n].Dad which is no longer needed }

        if (n > max_code) then
           continue;   { not a leaf node }

        Inc(bl_count[bits]);
        xbits := 0;
        if (n >= base) then
           xbits := extra^[n-base];
        f := tree^[n].fc.freq;
        Inc(opt_len,LongInt(LongInt(f) * LongInt((bits + xbits))));
        if (stree <> nil) then
           Inc(static_len,LongInt(LongInt(f)*LongInt((stree^[n].dl.len + xbits))));
     end;
    if (overflow = 0) then
        exit;

    {Trace((stderr,"\nbit length overflow\n"));}
    { This happens for example on obj2 and pic of the Calgary corpus }

    { Find the first bit length which could increase: }
    Repeat
        bits := max_length-1;
        while (bl_count[bits] = 0) do
           Dec(bits);
        Dec(bl_count[bits]);      { move one leaf down the tree }
        Inc(bl_count[bits+1],2);  { move one overflow item as its brother }
        Dec(bl_count[max_length]);
        {* The brother of the overflow item also moves one step up,
         * but this does not affect bl_count[max_length]
         *}
        Dec(overflow,2);
    Until overflow <= 0;

    {* Now recompute all bit lengths, scanning in increasing frequency.
     * h is still equal to HEAP_SIZE. (It is simpler to reconstruct all
     * lengths instead of fixing only the wrong ones. This idea is taken
     * from 'ar' written by Haruhiko Okumura.)
     *}
    h := HEAP_SIZE;  { To be sure }
    for bits := max_length downto 1 do
     begin
        n := bl_count[bits];
        while (n <> 0) do
         begin
            Dec(h);
            m := heap[h];
            if (m > max_code) then
              continue;
            if (tree^[m].dl.len <> WORD(bits)) then
             begin
                {Trace((stderr,"code %d bits %d->%d\n", m, tree[m].Len, bits));}
                Inc(opt_len,LongInt((LongInt(bits-tree^[m].dl.len))*LongInt(tree^[m].fc.freq)));
                tree^[m].dl.len := WORD(bits);
             end;
            Dec(n);
         end;
     end;
end;


{
 * Construct one Huffman tree and assigns the code bit strings and lengths.
 * Update the total bit length for the current block.
 * IN assertion: the field freq is set for all tree elements.
 * OUT assertions: the fields len and code are set to the optimal bit length
 *     and corresponding code. The length opt_len is updated; static_len is
 *     also updated if stree is not null. The field max_code is set.
 }
procedure build_tree(var desc: tree_desc);  {Checked out 6/14}
var
  tree:       ct_dataArrayPtr;
  stree:      ct_dataArrayPtr;
  elems:      LongInt;
  n,m:        LongInt;        { iterate over heap elements }
  max_code:   LongInt;        { largest code with non zero frequency }
  node:       LongInt;        { next internal node of the tree }
  inew:       LongInt;
begin
    tree   := desc.dyn_tree;
    stree  := desc.static_tree;
    elems  := desc.elems;
    max_code := -1;
    node := elems;
    { Construct the initial heap, with least frequent element in
     * heap[SMALLEST]. The sons of heap[n] are heap[2*n] and heap[2*n+1].
     * heap[0] is not used.
     }
    heap_len := 0; heap_max := HEAP_SIZE;
    for n := 0 to elems-1 do
     if (tree^[n].fc.freq <> 0) then
      begin
        Inc(heap_len);
        heap[heap_len] := n;
        max_code := n;
        depth[n] := 0;
      end
     Else
        tree^[n].dl.len := 0;
    { The pkzip format requires that at least one distance code exists,
     * and that at least one bit should be sent even if there is only one
     * possible code. So to avoid special checks later on we force at least
     * two codes of non zero frequency.
     }
    while (heap_len < 2) do
     begin
        Inc(heap_len);
        If max_code <2 then
         begin
           Inc(max_code);
           heap[heap_len] := max_code;
         end
        Else
          heap[heap_len] := 0;
        inew := heap[heap_len];
        tree^[inew].fc.freq := 1;
        depth[inew] := 0;
        Dec(opt_len);
        If (stree <> nil) then
           Dec(static_len,stree^[inew].dl.len);
        { new is 0 or 1 so it does not have extra bits }
     end;
    desc.max_code := max_code;
    { The elements heap[heap_len/2+1 .. heap_len] are leaves of the tree,
     * establish sub-heaps of increasing lengths:
     }
    for n := (heap_len div 2) downto 1 do
     pqdownheap( tree, n );
    { Construct the Huffman tree by repeatedly combining the least two
     * frequent nodes.
     }
    Repeat
        pqremove(tree, n);   { n = node of least frequency }
        m := heap[SMALLEST];  { m = node of next least frequency }
        Dec(heap_max);
        heap[heap_max] := n; { keep the nodes sorted by frequency }
        Dec(heap_max);
        heap[heap_max] := m;
        { Create a new node father of n and m }
        tree^[node].fc.freq := tree^[n].fc.freq + tree^[m].fc.freq;
        depth[node] := Byte( kpmax(depth[n], depth[m]) + 1);
        tree^[m].dl.dad := node;
        tree^[n].dl.dad := node;
        { and insert the new node in the heap }
        heap[SMALLEST] := node;
        Inc(node);
        pqdownheap(tree, SMALLEST);
    Until heap_len < 2;  {while (heap_len >= 2);}
    Dec(heap_max);
    heap[heap_max] := heap[SMALLEST];
    { At this point, the fields freq and dad are set. We can now
     * generate the bit lengths.
     }
    gen_bitlen(desc);
    { The field len is now set, we can generate the bit codes }
    gen_codes(tree, max_code);
end;

{* ===========================================================================
 * Scan a literal or distance tree to determine the frequencies of the codes
 * in the bit length tree. Updates opt_len to take into account the repeat
 * counts. (The contribution of the bit length codes will be added later
 * during the construction of bl_tree.)
 *}
procedure scan_tree (tree: ct_dataArrayPtr; max_code: LongInt);
var
    { tree          = the tree to be scanned }
    {max_code       =  and its largest code of non zero frequency }
    n:              LongInt;       { iterates over all tree elements }
    prevlen:        LongInt;       { last emitted length }
    curlen:         LongInt;       { length of current code }
    nextlen:        LongInt;       { length of next code }
    icount:          LongInt;       { repeat count of the current code }
    max_count:      LongInt;       { max repeat count }
    min_count:      LongInt;       { min repeat count }
begin
    prevlen := -1;
    nextlen := tree^[0].dl.len;
    icount := 0;
    max_count := 7;
    min_count := 4;
    if (nextlen = 0) then
     begin
        max_count := 138;
        min_count := 3;
     end;
    tree^[max_code+1].dl.len := WORD(-1); { guard }

    for n := 0 to max_code do
     begin
        curlen := nextlen;
        nextlen := tree^[n+1].dl.len;
        Inc(icount);
        if (icount < max_count) and (curlen = nextlen) then
            continue
        Else if (icount < min_count) then
            Inc(bl_tree[curlen].fc.freq,icount)
        Else if (curlen <> 0) then
         begin
            if (curlen <> prevlen) then
              Inc(bl_tree[curlen].fc.freq);
            Inc(bl_tree[REP_3_6].fc.freq);
         end
        Else if (icount <= 10) then
            Inc(bl_tree[REPZ_3_10].fc.freq)
        Else
            Inc(bl_tree[REPZ_11_138].fc.freq);

        icount := 0; prevlen := curlen;
        if (nextlen = 0) then
         begin
            max_count := 138;
            min_count := 3;
         end
        Else if (curlen = nextlen) then
         begin
            max_count := 6;
            min_count := 3;
         end
        Else
         begin
            max_count := 7;
            min_count := 4;
         end;

     end;
end;


{* ===========================================================================
 * Construct the Huffman tree for the bit lengths and return the index in
 * bl_order of the last bit length code to send.
 *}
function build_bl_tree: LongInt;
{var}
  {max_blindex:   LongInt;}  { index of last bit length code of non zero freq }
begin
   { Determine the bit length frequencies for literal and distance trees }
    scan_tree(ct_dataArrayPtr(@dyn_ltree), l_desc.max_code);  { added typecast 5/18/98  2.13 }
    scan_tree(ct_dataArrayPtr(@dyn_dtree), d_desc.max_code);  { added typecast 5/18/98  2.13 }

    { Build the bit length tree: }
    build_tree(bl_desc);
    {* opt_len now includes the length of the tree representations, except
     * the lengths of the bit lengths codes and the 5+5+4 bits for the counts.
     *}

    {* Determine the number of bit length codes to send. The pkzip format
     * requires that at least 4 bit length codes be sent. (appnote.txt says
     * 3 but the actual value used is 4.)
     *}
    Result := BL_CODES-1;
    while (Result >= 3) do
     begin
        if (bl_tree[bl_order[Result]].dl.len <> 0) then
           break;
        Dec(Result);
     end;
    { Update opt_len to include the bit length tree and counts }
    Inc(opt_len,3*(Result+1)+5+5+4);
    {Tracev((stderr, "\ndyn trees: dyn %ld, stat %ld", opt_len, static_len));}

    {Result := max_blindex;}
end;

{* ===========================================================================
 * Send the block data compressed using the given Huffman trees
 *}
procedure compress_block(ltree, dtree: ct_dataArrayPtr);
var
    { ltree      = literal tree }
    { dtree      = distance tree }
    dist:     usigned;            { distance of matched string }
    lc:       LongInt;             { match length or unmatched char (if dist == 0) }
    lx:       usigned;            { running index in l_buf }
    dx:       usigned;            { running index in d_buf }
    fx:       usigned;            { running index in flag_buf }
    flag:     Byte;                { current flags }
    code:     usigned;            { the code to send }
    extra:    LongInt;             { number of extra bits to send }
begin
    lx := 0;
    dx := 0;
    fx := 0;
    flag := 0;
    if (last_lit <> 0) then
     Repeat
        if ((lx and 7) = 0) then
         begin
           flag := flag_buf^[fx];
           Inc(fx);
         end;
        lc := l_buf^[lx];
        Inc(lx);
        if ((flag and 1) = 0) then
         begin
            send_code(lc, ltree); { send a literal byte }
            {send_bits( Integer(ltree^[lc].fc.code), Integer(ltree^[lc].dl.len) );}
            {Tracecv(isgraph(lc), (stderr," '%c' ", lc));}
         end
        Else
         begin
            { Here, lc is the match length - MIN_MATCH }
            code := length_code[lc];
            send_code(code+LITERALS+1, ltree); { send the length code }
            {send_bits( Integer(ltree^[code+LITERALS+1].fc.code), Integer(ltree^[code+LITERALS+1].dl.len) );}
            extra := extra_lbits[code];
            if (extra <> 0) then
             begin
                Dec(lc,base_length[code]);
                send_bits(lc, extra);        { send the extra length bits }
             end;
            dist := d_buf^[dx];
            Inc(dx);
            { Here, dist is the match distance - 1 }
            code := d_code(dist);

            {$IFDEF ASSERTS}
            Assert (code < D_CODES, 'bad d_code-compress_block');
            {$ENDIF}

            send_code(code, dtree);       { send the distance code }
            {send_bits( Integer(dtree^[code].fc.code), Integer(dtree^[code].dl.len) );}
            extra := extra_dbits[code];
            if (extra <> 0) then
             begin
                Dec(dist,base_dist[code]);
                send_bits(dist, extra);   { send the extra distance bits }
             end;
         end; { literal or match pair ? }
        flag := flag shr 1;
     Until lx >= last_lit;  {while (lx < last_lit)}

    send_code(END_BLOCK, ltree);
    {send_bits( Integer(ltree^[END_BLOCK].fc.code), Integer(ltree^[END_BLOCK].dl.len) );}
end;

{* ===========================================================================
 * Send a literal or distance tree in compressed form, using the codes in
 * bl_tree.
 *}
procedure send_tree (tree: ct_dataArrayPtr; max_code: LongInt);
var
    { tree       = the tree to be scanned }
    { max_code   = and its largest code of non zero frequency }
    n: Integer;                       { iterates over all tree elements }
    prevlen: LongInt;                 { last emitted length }
    curlen:  LongInt;                 { length of current code }
    nextlen: LongInt;                 { length of next code }
    icount:   LongInt;                 { repeat count of the current code }
    max_count:  LongInt;              { max repeat count }
    min_count:  LongInt;              { min repeat count }
begin
    prevlen := -1;
    nextlen := tree^[0].dl.len;
    icount := 0;
    max_count := 7;
    min_count := 4;
    { tree[max_code+1].Len = -1; }  { guard already set }
    if (nextlen = 0) then
     begin
        max_count := 138;
        min_count := 3;
     end;

    for n := 0 to max_code do
     begin
        curlen := nextlen;
        nextlen := tree^[n+1].dl.len;
        Inc(icount);
        if (icount < max_count) and (curlen = nextlen) then
            continue
        Else if (icount < min_count) then
           Repeat
            If (bl_tree[curlen].dl.len > 0) and (bl_tree[curlen].dl.len < 16) then
              send_code(curlen, ct_dataArrayPtr(@bl_tree));   { added typecast 5/18/98  2.13 }
              {send_bits( Integer(ct_dataArrayPtr(@bl_tree)^[curlen].fc.code),}
              {           Integer(ct_dataArrayPtr(@bl_tree)^[curlen].dl.len) );}
            {else
              ShowMessage('Length out of range! - ' + IFileName);}
            Dec(icount);
           Until icount = 0
        Else if (curlen <> 0) then
           begin
            if (curlen <> prevlen) then
             begin
                send_code(curlen, ct_dataArrayPtr(@bl_tree));  { added typecast 5/18/98 2.13 }
                {send_bits( Integer(ct_dataArrayPtr(@bl_tree)^[curlen].fc.code),}
                {           Integer(ct_dataArrayPtr(@bl_tree)^[curlen].dl.len) );}
                Dec(icount);
             end;

            {$IFDEF ASSERTS}
            Assert((icount >= 3) and (icount <= 6), ' 3_6? - send_tree');
            {$ENDIF}

            If (bl_tree[REP_3_6].dl.len > 0) and (bl_tree[REP_3_6].dl.len < 16) then
              send_code(REP_3_6, ct_dataArrayPtr(@bl_tree));   { added typecast 5/18/98  2.13 }
              {send_bits( Integer(ct_dataArrayPtr(@bl_tree)^[REP_3_6].fc.code), }
              {           Integer(ct_dataArrayPtr(@bl_tree)^[REP_3_6].dl.len) ); }
            {else
              ShowMessage('Length out of range! -' + IFileName);}
            send_bits(icount-3, 2);
           end
        Else if (icount <= 10) then
           begin
            send_code(REPZ_3_10, ct_dataArrayPtr(@bl_tree));  { added typecast 5/18/98  2.13 }
            {send_bits( Integer(ct_dataArrayPtr(@bl_tree)^[REPZ_3_10].fc.code), }
            {             Integer(ct_dataArrayPtr(@bl_tree)^[REPZ_3_10].dl.len) ); }
            send_bits(icount-3, 3);
           end
        Else
           begin
            send_code(REPZ_11_138, ct_dataArrayPtr(@bl_tree)); { added typecast 5/18/98  2.13 }
            {send_bits( Integer(ct_dataArrayPtr(@bl_tree)^[REPZ_11_138].fc.code), }
            {            Integer(ct_dataArrayPtr(@bl_tree)^[REPZ_11_138].dl.len) ); }
            send_bits(icount-11, 7);
           end;

        icount := 0; prevlen := curlen;
        if (nextlen = 0) then
           begin
            max_count := 138;
            min_count := 3;
           end
        Else if (curlen = nextlen) then
           begin
            max_count := 6;
            min_count := 3;
           end
        Else
           begin
            max_count := 7;
            min_count := 4;
           end;
     end;
end;

{* ===========================================================================
 * Send the header for a block using dynamic Huffman trees: the counts, the
 * lengths of the bit length codes, the literal tree and the distance tree.
 * IN assertion: lcodes >= 257, dcodes >= 1, blcodes >= 4.
 *}
procedure send_all_trees(lcodes, dcodes, blcodes: LongInt);
var
  { lcodes, dcodes, blcodes  = number of codes for each tree }
  rank:    LongInt;   { index in bl_order }
begin
    {$IFDEF ASSERTS}
    Assert ((lcodes >= 257) and (dcodes >= 1) and (blcodes >= 4),
              'not enough codes-send_all_trees');
    Assert ((lcodes <= L_CODES) and (dcodes <= D_CODES) and (blcodes <= BL_CODES),
            'too many codes-send_all_trees');
    {$ENDIF} 

    send_bits(lcodes-257, 5);
    { not +255 as stated in appnote.txt 1.93a or -256 in 2.04c }
    send_bits(dcodes-1,   5);
    send_bits(blcodes-4,  4); { not -3 as stated in appnote.txt }
    for rank := 0 to blcodes-1 do
     begin
        {Tracev((stderr, "\nbl code %2d ", bl_order[rank]));}
        send_bits(bl_tree[bl_order[rank]].dl.len, 3);
     end;
    {Tracev((stderr, "\nbl tree: sent %ld", bits_sent));}

    send_tree(ct_dataArrayPtr(@dyn_ltree), lcodes-1); { send the literal tree } { added typecast 5/18/98  2.13 }
    {Tracev((stderr, "\nlit tree: sent %ld", bits_sent));}

    send_tree(ct_dataArrayPtr(@dyn_dtree), dcodes-1); { send the distance tree } { added typecast 5/18/98  2.13 }
    {Tracev((stderr, "\ndist tree: sent %ld", bits_sent));}
end;

function flush_the_block( buf: BytePtr; stored_len: FILE_INT; eofblock: Integer ): FILE_INT;
var
  opt_lenb, static_lenb:  LongInt;
  max_blindex:            LongInt;
begin
  flag_buf^[last_flags] := flags;
  If ( tmpfile_info.internal_file_attributes = UNKNOWN ) then
     set_file_type;

  build_tree( l_desc );
  build_tree( d_desc );

  max_blindex := build_bl_tree;

  opt_lenb := (opt_len+3+7) shr 3;
  static_lenb := (static_len+3+7) shr 3;
  Inc(input_len,stored_len);

  If (static_lenb <= opt_lenb) then
     opt_lenb := static_lenb;

  If (stored_len <= opt_lenb) and (eofblock <> 0) and (compressed_len = 0) then
   begin
     copy_block( buf, stored_len, 0 );
     compressed_len := stored_len shl 3;
     tmpfile_info.compression_method := STORE;
   end
  Else If (stored_len+4 <= opt_lenb) and (buf <> nil) then
   begin
     { The test buf <> nil is only necessary if LIT_BUFSIZE > WSIZE.
     * Otherwise we can't have processed more than WSIZE input bytes since
     * the last block flush, because compression would have been
     * successful. If LIT_BUFSIZE <= WSIZE, it is never too late to
     * transform a block into a stored block. }
     send_bits((STORED_BLOCK shl 1) + eofblock, 3);  { send block type }
     compressed_len := (compressed_len + 3 + 7) and (not LongInt(7));
     Inc(compressed_len,(stored_len + 4) shl 3);
     copy_block(buf, stored_len, 1); { with header }
   end
  Else If (static_lenb = opt_lenb) then
   begin
     send_bits((STATIC_TREES shl 1) + eofblock, 3);
     compress_block(ct_dataArrayPtr(@static_ltree), ct_dataArrayPtr(@static_dtree));   { added typecast 5/18/98  2.13 }
     Inc(compressed_len,3 + static_len);
   end
  Else
   begin
     send_bits((DYN_TREES shl 1)+eofblock, 3);
     send_all_trees(l_desc.max_code+1, d_desc.max_code+1, max_blindex+1);
     compress_block(ct_dataArrayPtr(@dyn_ltree), ct_dataArrayPtr(@dyn_dtree));  { added typecast 5/18/98  2.13 }
     Inc(compressed_len,3 + opt_len);
   end;
  init_block;
  if (eofblock <> 0) then
   begin
     ZeroMemory(@window^[0], 2*WSIZE-1);
     bi_windup;
     Inc(compressed_len,7);  { align on byte boundary }
   end;
  Result := compressed_len shr 3;
end;

