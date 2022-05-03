/*
+-----------------------------------------------------------------------------+
| This code corresponds to the paper https://eprint.iacr.org/2019/1259.pdf by |
| Kaushik Nath,  Indian Statistical Institute, Kolkata, India, and            |
| Palash Sarkar, Indian Statistical Institute, Kolkata, India.	              |
+-----------------------------------------------------------------------------+
| Copyright (c) 2020, Kaushik Nath.                                           |
|                                                                             |
| Permission to use this code is granted.                          	      |
|                                                                             |
| Redistribution and use in source and binary forms, with or without          |
| modification, are permitted provided that the following conditions are      |
| met:                                                                        |
|                                                                             |
| * Redistributions of source code must retain the above copyright notice,    |
|   this list of conditions and the following disclaimer.                     |
|                                                                             |
| * Redistributions in binary form must reproduce the above copyright         |
|   notice, this list of conditions and the following disclaimer in the       |
|   documentation and/or other materials provided with the distribution.      |
|                                                                             |
| * The names of the contributors may not be used to endorse or promote       |
|   products derived from this software without specific prior written        |
|   permission.                                                               |
+-----------------------------------------------------------------------------+
| THIS SOFTWARE IS PROVIDED BY THE AUTHORS ""AS IS"" AND ANY EXPRESS OR       |
| IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES   |
| OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.     |
| IN NO EVENT SHALL THE CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,      |
| INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT    |
| NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,   |
| DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY       |
| THEORY LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING |
| NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,| 
| EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                          |
+-----------------------------------------------------------------------------+
*/

#include "basic_types.h"
#include "gf_p25519_type.h"
#include "gf_p25519_pack.h"
#include "gf_p25519_arith.h"
#include "curve25519.h"
#include "stdio.h"

int curve25519_scalarmult(uchar8 *q, const uchar8 *n, const uchar8 *p) {

	gfe_p25519 r[2];

	uchar8 i,s[CRYPTO_BYTES];

	for (i=0;i<CRYPTO_BYTES;++i) s[i] = n[i];
	s[CRYPTO_BYTES-1] = s[CRYPTO_BYTES-1] & 0x7F;
	s[CRYPTO_BYTES-1] = s[CRYPTO_BYTES-1] | 0x40;
	s[0] = s[0] & 0xF8;

	gfp25519pack(r,p);   

	curve25519_mladder(r,r,s);

	gfp25519invx(r+1,r+1);
	gfp25519mulx(r,r,r+1);
	gfp25519reduce(r);
	gfp25519makeunique(r);
	gfp25519unpack(q,r);

	return 0;
}

int curve25519_scalarmult_base(uchar8 *q, const uchar8 *n, const uchar8 *p) {

	gfe_p25519 r[2];

	uchar8 i,s[CRYPTO_BYTES];

	for (i=0;i<CRYPTO_BYTES;++i) s[i] = n[i];
	s[CRYPTO_BYTES-1] = s[CRYPTO_BYTES-1] & 0x7F;
	s[CRYPTO_BYTES-1] = s[CRYPTO_BYTES-1] | 0x40;
	s[0] = s[0] & 0xF8;

	gfp25519pack(r,p);   

	curve25519_mladder_base(r,r,s);

	gfp25519invx(r+1,r+1);
	gfp25519mulx(r,r,r+1);
	gfp25519reduce(r);
	gfp25519makeunique(r);
	gfp25519unpack(q,r);

	return 0;
}
