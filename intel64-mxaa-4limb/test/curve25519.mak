#+-----------------------------------------------------------------------------+
#| This code corresponds to the paper https://eprint.iacr.org/2019/1259.pdf by |
#| Kaushik Nath,  Indian Statistical Institute, Kolkata, India, and            |
#| Palash Sarkar, Indian Statistical Institute, Kolkata, India.	               |
#+-----------------------------------------------------------------------------+
#| Copyright (c) 2020, Kaushik Nath, Palash Sarkar.                            |
#|                                                                             |
#| Permission to use this code is granted.                          	       |
#|                                                                             |
#| Redistribution and use in source and binary forms, with or without          |
#| modification, are permitted provided that the following conditions are      |
#| met:                                                                        |
#|                                                                             |
#| * Redistributions of source code must retain the above copyright notice,    |
#|   this list of conditions and the following disclaimer.                     |
#|                                                                             |
#| * Redistributions in binary form must reproduce the above copyright         |
#|   notice, this list of conditions and the following disclaimer in the       |
#|   documentation and/or other materials provided with the distribution.      |
#|                                                                             |
#| * The names of the contributors may not be used to endorse or promote       |
#|   products derived from this software without specific prior written        |
#|   permission.                                                               |
#+-----------------------------------------------------------------------------+
#| THIS SOFTWARE IS PROVIDED BY THE AUTHORS ""AS IS"" AND ANY EXPRESS OR       |
#| IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES   |
#| OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.     |
#| IN NO EVENT SHALL THE CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,      |
#| INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT    |
#| NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,   |
#| DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY       |
#| THEORY LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING |
#| NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,| 
#| EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.                          |
#+-----------------------------------------------------------------------------+

INCDRS = -I../include/

SRCFLS = ../source/curve25519_const.s 		\
	 ../source/curve25519_mladder.s		\
	 ../source/curve25519_mladder_base.s	\
	 ../source/gf_p25519_mul.s 		\
	 ../source/gf_p25519_nsqr.s 		\
	 ../source/gf_p25519_makeunique.s 	\
	 ../source/gf_p25519_pack.c		\
	 ../source/gf_p25519_inv.c 		\
	 ../source/curve25519_scalarmult.c	\
	  ./curve25519_test.c
         
OBJFLS = ../source/curve25519_const.o 		\
	 ../source/curve25519_mladder.o		\
	 ../source/curve25519_mladder_base.o	\
	 ../source/gf_p25519_mul.o 		\
	 ../source/gf_p25519_nsqr.o 		\
	 ../source/gf_p25519_makeunique.o 	\
	 ../source/gf_p25519_pack.o		\
	 ../source/gf_p25519_inv.o 		\
	 ../source/curve25519_scalarmult.o	\
	  ./curve25519_test.o

EXE    = curve25519_test

#CFLAGS = -march=haswell -mtune=haswell -m64 -O3 -funroll-loops -fomit-frame-pointer
CFLAGS = -march=skylake -mtune=skylake -m64 -O3 -funroll-loops -fomit-frame-pointer

CC     = gcc
LL     = gcc

$(EXE): $(OBJFLS)
	$(LL) -o $@ $(OBJFLS) -lm -no-pie

.c.o:
	$(CC) $(INCDRS) $(CFLAGS) -o $@ -c $<

clean:
	-rm $(EXE)
	-rm $(OBJFLS)
