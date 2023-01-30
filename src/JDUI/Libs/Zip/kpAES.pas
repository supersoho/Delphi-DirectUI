{ $HDR$}
{**********************************************************************}
{ Description of File:                                                 }
{                                                                      }
{                                                                      }
{ Copyright: 2007                                                           }
{ Original Author:  Kevin Boylan                                                   }
{**********************************************************************}
{}
{ $Log:  10113: kpAES.pas 
{
{   Rev 1.3    11/30/2008 1:44:02 PM  Delphi7    Version: VCLZip Version 4.50
{ Modifications for 4.50
}
{
{   Rev 1.2    2/19/2007 4:53:30 PM  Delphi7    Version: VCLZip Pro Encryption 4.0 b1
{ Clean up
}
{
{   Rev 1.1    2/19/2007 4:50:12 PM  Delphi7    Version: VCLZip Pro Encryption 4.0 b1
{ Move object files to a subdirectory
}
unit kpAES;

interface

uses
  Windows, SysUtils;

const
  SHA1_DIGEST_SIZE = 20;
  SHA1_BLOCK_SIZE = 64;
  PRNG_POOL_LEN = 256;
  PRNG_POOL_SIZE = (SHA1_DIGEST_SIZE * (1 + (PRNG_POOL_LEN - 1) DIV SHA1_DIGEST_SIZE));
  PWD_VER_LENGTH = 2;
  BLOCK_SIZE = 16;
  IN_BLOCK_LENGTH = SHA1_BLOCK_SIZE;
  MAC_LENGTH = 10;
  KS_LENGTH = 4 * BLOCK_SIZE;



type
  BYTEPTR = PByte;
  INT64PTR = ^Int64;
  AES_32T = LongWord;
  PWD_VER_TYPE = array[0..PWD_VER_LENGTH-1] of BYTE;

  prng_entropy_fn = function(buf: BYTEPTR; len: LongWord): integer; cdecl;


//  typedef struct
{   sha1_32t count[2];
    sha1_32t hash[5];
    sha1_32t wbuf[16];
} //sha1_ctx;

  sha1_ctx = record
    count:  array[0..1] of Longword;
    hash:   array[0..4] of Longword;
    wbuf:   array[0..15] of Longword;
   end;
   SHA1_CTX_PTR = ^sha1_ctx;

   //   typedef struct
{   unsigned char   rbuf[PRNG_POOL_SIZE];   /* the random pool          */
    unsigned char   obuf[PRNG_POOL_SIZE];   /* pool output buffer       */
    unsigned int    pos;                    /* output buffer position   */
    prng_entropy_fn entropy;                /* entropy function pointer */
} //prng_ctx;

   prng_ctx = record
    rbuf: array[0..PRNG_POOL_SIZE-1] of byte;
    obuf: array[0..PRNG_POOL_SIZE-1] of byte;
    pos:  longword;
    entropy: prng_entropy_fn;
   end;
   PRNG_CTX_PTR = ^prng_ctx;

//typedef struct                     /* the AES context for encryption    */
{   aes_32t    k_sch[KS_LENGTH];   /* the encryption key schedule       */
    aes_32t    n_rnd;              /* the number of cipher rounds       */
    aes_32t    n_blk;              /* the number of bytes in the state  */
    void      *t_ptr;              /* available this pointer is used    */
} //aes_ctx;

aes_ctx = record
  k_sch:  array[0..KS_LENGTH-1] of AES_32T;
  n_rnd:  AES_32T;
  n_blk:  AES_32T;
  t_ptr:  Pointer;
end;
AES_CTX_PTR = ^aes_ctx;

//typedef struct
{   unsigned char   key[IN_BLOCK_LENGTH];
    sha1_ctx        ctx[1];
    unsigned int    klen;
} //hmac_ctx;

hmac_ctx = record
  key:  array[0..IN_BLOCK_LENGTH-1] of byte;
  ctx:  array[0..0] of sha1_ctx;
  klen: LongWord;
end;
HMAC_CTX_PTR = ^hmac_ctx;

   //typedef struct
{   unsigned char   nonce[BLOCK_SIZE];          /* the CTR nonce          */
    unsigned char   encr_bfr[BLOCK_SIZE];       /* encrypt buffer         */
    aes_ctx         encr_ctx[1];                /* encryption context     */
    hmac_ctx        auth_ctx[1];                /* authentication context */
    unsigned int    encr_pos;                   /* block position (enc)   */
    unsigned int    pwd_len;                    /* password length        */
    unsigned int    mode;                       /* File encryption mode   */
} //fcrypt_ctx;

fcrypt_ctx = packed record
  nonce:    array[0..BLOCK_SIZE-1] of byte;
  encr_bfr: array[0..BLOCK_SIZE-1] of byte;
  encr_ctx: array[0..0] of aes_ctx;
  auth_ctx: array[0..0] of hmac_ctx;
  encr_pos: LongWord;
  pwd_len:  LongWord;
  mode:     LongWord;
end;
FCRYPT_CTX_PTR = ^fcrypt_ctx;

{$L AES\sha1.obj}
{$L AES\fileenc.obj}
{$L AES\prng.obj}
{$L AES\aescrypt.obj}
{$L AES\hmac.obj}
{$L AES\aeskey.obj}
{$L AES\aestab.obj}
{$L AES\pwd2key.obj}

//void sha1_begin(sha1_ctx ctx[1]);
procedure _sha1_begin; cdecl; external;
procedure _sha1_compile; cdecl; external;
procedure _sha1_hash; cdecl; external;
procedure _sha1_end; cdecl; external;

//void prng_init(prng_entropy_fn fun, prng_ctx ctx[1]);
procedure _prng_init(run: prng_entropy_fn; ctx: PRNG_CTX_PTR); cdecl; external;
//void prng_rand(unsigned char data[], unsigned int data_len, prng_ctx ctx[1]);
procedure _prng_rand(data: BYTEPTR; data_len: LongWord; ctx: PRNG_CTX_PTR); cdecl; external;
//void fcrypt_encrypt(unsigned char data[], unsigned int data_len, fcrypt_ctx cx[1]);
procedure _fcrypt_encrypt(data: BYTEPTR; data_len: LongWord; cx: FCRYPT_CTX_PTR); cdecl; external;
//void fcrypt_decrypt(unsigned char data[], unsigned int data_len, fcrypt_ctx cx[1]);
procedure _fcrypt_decrypt(data: BYTEPTR; data_len: LongWord; cx: FCRYPT_CTX_PTR); cdecl; external;
//void prng_end(prng_ctx ctx[1]);
procedure _prng_end(ctx: PRNG_CTX_PTR); cdecl;  external;

{
int fcrypt_init(
    int mode,                               /* the mode to be used (input)          */
    const unsigned char pwd[],              /* the user specified password (input)  */
    unsigned int pwd_len,                   /* the length of the password (input)   */
    const unsigned char salt[],             /* the salt (input)                     */
    unsigned char pwd_ver[PWD_VER_LENGTH],  /* 2 byte password verifier (output)    */
    fcrypt_ctx      cx[1]);                 /* the file encryption context (output) */
}
function _fcrypt_init(mode: integer; const pwd: PAnsiChar; pwd_len: LongWord; salt: BYTEPTR;
                     pwd_ver: BYTEPTR; cx: FCRYPT_CTX_PTR): integer; cdecl; external;

//int fcrypt_end(unsigned char mac[],     /* the MAC value (output)   */
//               fcrypt_ctx cx[1]);       /* the context (input)      */
function _fcrypt_end(mac: BYTEPTR; cx: FCRYPT_CTX_PTR): Integer; cdecl; external;
function SALT_LENGTH(mode: byte): LongWord;
function _entropy_fun(buf: BYTEPTR; len: LongWord): Integer; cdecl;


implementation

  procedure _memset(P: Pointer; B: Byte; count: Integer); cdecl;
  begin
     FillChar(P^, count, B);
  end;

  procedure _memcpy(dest, source: Pointer; count: Integer); cdecl;
  begin
     Move(source^, dest^, count);
  end;

  //#define SALT_LENGTH(mode)       (4 * (mode & 3) + 4)
  function SALT_LENGTH(mode: byte): LongWord;
  begin
    result := 4* (mode and 3) + 4;
  end;

  function _entropy_fun(buf: BYTEPTR; len: LongWord): Integer; cdecl;
  type
    large_integer = record
     case boolean of
      true: (large_int: Int64);
      false: (bytes: array[0..8] of byte);
    end;
    LARGE_INTEGER_PTR = ^large_integer;
  var
    pentium_tsc: large_integer;
    i: Int64;
  begin
    i := 0;
    QueryPerformanceCounter(i);
    pentium_tsc.large_int := i;
    result := 0;
    {$WARNINGS OFF}
    while (result < 8) and (result < len) do
    begin
      buf^ := pentium_tsc.bytes[result];
      Inc(result);
      Inc(buf);
    end;
    {$WARNINGS ON}
  end;


//  int entropy_fun(unsigned char buf[], unsigned int len)
{   unsigned __int64    pentium_tsc[1];
    unsigned int        i;

    QueryPerformanceCounter((LARGE_INTEGER *)pentium_tsc);
    for(i = 0; i < 8 && i < len; ++i)
        buf[i] = ((unsigned char*)pentium_tsc)[i];
    return i;
}

end.
