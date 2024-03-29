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

.p2align 5
.globl curve25519_mladder_base
curve25519_mladder_base:

movq 	%rsp,%r11
subq 	$344,%rsp

movq 	%r11,0(%rsp)
movq 	%r12,8(%rsp)
movq 	%r13,16(%rsp)
movq 	%r14,24(%rsp)
movq 	%r15,32(%rsp)
movq 	%rbx,40(%rsp)
movq 	%rbp,48(%rsp)
movq 	%rdi,56(%rsp)

// X2 ← 1
movq	$1,72(%rsp)
movq	$0,80(%rsp)
movq	$0,88(%rsp)
movq	$0,96(%rsp) 	 

// Z2 ← 0
movq	$0,104(%rsp)
movq	$0,112(%rsp)
movq	$0,120(%rsp)
movq	$0,128(%rsp)

// X3 ← XP
movq	0(%rsi),%r8
movq	%r8,136(%rsp)
movq	8(%rsi),%r8
movq	%r8,144(%rsp)
movq	16(%rsi),%r8
movq	%r8,152(%rsp)
movq	24(%rsi),%r8
movq	%r8,160(%rsp)

// Z3 ← 1
movq	$1,168(%rsp)
movq	$0,176(%rsp)
movq	$0,184(%rsp)
movq	$0,192(%rsp)    

movq    $31,208(%rsp)
movb	$6,200(%rsp)
movb    $0,202(%rsp)
movq    %rdx,64(%rsp)

movq    %rdx,%rax

// Montgomery ladder loop

.L1:

addq    208(%rsp),%rax
movb    0(%rax),%r14b
movb    %r14b,204(%rsp)

.L2:

/* 
 * Montgomery ladder step
 *
 * Reduction ideas for addition and subtraction are taken from the 64-bit implementation 
 * "amd64-64" of the work "https://link.springer.com/article/10.1007/s13389-012-0027-1"
 *
 * T1 ← X2 + Z2
 * T2 ← X2 - Z2
 * T3 ← X3 + Z3
 * T4 ← X3 - Z3
 * Z3 ← T2 · T3
 * X3 ← T1 · T4
 *
 * bit ← n[i]
 * select ← bit ⊕ prevbit
 * prevbit ← bit
 * CSelect(T1,T3,select): if (select == 1) {T1 = T3}
 * CSelect(T2,T4,select): if (select == 1) {T2 = T4}
 *
 * T2 ← T2^2
 * T1 ← T1^2
 * T3 ← X3 + Z3
 * Z3 ← X3 - Z3
 * Z3 ← Z3^2
 * X3 ← T3^2
 * T3 ← T1 - T2
 * T4 ← ((A + 2)/4) · T3
 * T4 ← T4 + T2
 * X2 ← T1 · T2
 * Z2 ← T3 · T4
 * Z3 ← Z3 · X1
 *
 */

// X2
movq    72(%rsp),%r8  
movq    80(%rsp),%r9
movq    88(%rsp),%r10
movq    96(%rsp),%r11

// copy X2
movq    %r8,%rax	
movq    %r9,%rbx
movq    %r10,%rbp
movq    %r11,%rsi

// T1 ← X2 + Z2
addq    104(%rsp),%r8
adcq    112(%rsp),%r9
adcq    120(%rsp),%r10
adcq    128(%rsp),%r11

movq    $0,%rdi
movq    $38,%rcx
cmovae  %rdi,%rcx

addq    %rcx,%r8
adcq    %rdi,%r9
adcq    %rdi,%r10
adcq    %rdi,%r11

cmovc   %rcx,%rdi
addq    %rdi,%r8

movq    %r8,216(%rsp)
movq    %r9,224(%rsp)
movq    %r10,232(%rsp)
movq    %r11,240(%rsp)

// T2 ← X2 - Z2
subq    104(%rsp),%rax
sbbq    112(%rsp),%rbx
sbbq    120(%rsp),%rbp
sbbq    128(%rsp),%rsi

movq    $0,%rdi
movq    $38,%rcx
cmovae  %rdi,%rcx

subq    %rcx,%rax
sbbq    %rdi,%rbx
sbbq    %rdi,%rbp
sbbq    %rdi,%rsi

cmovc   %rcx,%rdi
subq    %rdi,%rax

movq    %rax,248(%rsp)
movq    %rbx,256(%rsp)
movq    %rbp,264(%rsp)
movq    %rsi,272(%rsp)

// X3
movq    136(%rsp),%r8
movq    144(%rsp),%r9
movq    152(%rsp),%r10
movq    160(%rsp),%r11

// copy X3 
movq    %r8,%rax
movq    %r9,%rbx
movq    %r10,%rbp
movq    %r11,%rsi

// T3 ← X3 + Z3
addq    168(%rsp),%r8
adcq    176(%rsp),%r9
adcq    184(%rsp),%r10
adcq    192(%rsp),%r11

movq    $0,%rdi
movq    $38,%rcx
cmovae  %rdi,%rcx

addq    %rcx,%r8
adcq    %rdi,%r9
adcq    %rdi,%r10
adcq    %rdi,%r11

cmovc   %rcx,%rdi
addq    %rdi,%r8

movq    %r8,280(%rsp)
movq    %r9,288(%rsp)
movq    %r10,296(%rsp)
movq    %r11,304(%rsp)

// T4 ← X3 - Z3
subq    168(%rsp),%rax
sbbq    176(%rsp),%rbx
sbbq    184(%rsp),%rbp
sbbq    192(%rsp),%rsi

movq    $0,%rdi
movq    $38,%rcx
cmovae  %rdi,%rcx

subq    %rcx,%rax
sbbq    %rdi,%rbx
sbbq    %rdi,%rbp
sbbq    %rdi,%rsi

cmovc   %rcx,%rdi
subq    %rdi,%rax

movq    %rax,312(%rsp)
movq    %rbx,320(%rsp)
movq    %rbp,328(%rsp)
movq    %rsi,336(%rsp)

// Z3 ← T2 · T3
movq    256(%rsp),%rax
mulq    304(%rsp)
movq    %rax,%r8
xorq    %r9,%r9
movq    %rdx,%r10
xorq    %r11,%r11

movq    264(%rsp),%rax
mulq    296(%rsp)
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    272(%rsp),%rax
mulq    288(%rsp)
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    264(%rsp),%rax
mulq    304(%rsp)
addq    %rax,%r10
adcq    $0,%r11
movq    %rdx,%r12
xorq    %r13,%r13

movq    272(%rsp),%rax
mulq    296(%rsp)
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    $38,%rax
mulq    %r10
imul    $38,%r11,%r11
movq    %rax,%r10
addq    %rdx,%r11

movq    272(%rsp),%rax
mulq    304(%rsp)
addq    %rax,%r12
adcq    $0,%r13

movq    $38,%rax
mulq    %rdx
movq    %rax,%r14
movq    %rdx,%r15

movq    $38,%rax
mulq    %r12
imul    $38,%r13,%r13
movq    %rax,%r12
addq    %rdx,%r13

movq    248(%rsp),%rax
mulq    304(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    256(%rsp),%rax
mulq    296(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    264(%rsp),%rax
mulq    288(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    272(%rsp),%rax
mulq    280(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    $38,%rax
mulq    %r8
imul    $38,%r9,%r9
movq    %rax,%r8
addq    %rdx,%r9

movq    248(%rsp),%rax
mulq    280(%rsp)
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    248(%rsp),%rax
mulq    288(%rsp)
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    256(%rsp),%rax
mulq    280(%rsp)
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    248(%rsp),%rax
mulq    296(%rsp)
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

movq    256(%rsp),%rax
mulq    288(%rsp)
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

movq    264(%rsp),%rax
mulq    280(%rsp)
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

addq    %r9,%r10
adcq    $0,%r11

addq    %r11,%r12
adcq    $0,%r13

addq    %r13,%r14
adcq    $0,%r15

shld    $1,%r14,%r15
andq    mask63(%rip),%r14
imul    $19,%r15,%r15

addq    %r15,%r8
adcq    $0,%r10
adcq    $0,%r12
adcq    $0,%r14

movq    %r8,168(%rsp)
movq    %r10,176(%rsp)
movq    %r12,184(%rsp)
movq    %r14,192(%rsp)

// X3 ← T1 · T4
movq    224(%rsp),%rax
mulq    336(%rsp)
movq    %rax,%r8
xorq    %r9,%r9
movq    %rdx,%r10
xorq    %r11,%r11

movq    232(%rsp),%rax
mulq    328(%rsp)
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    240(%rsp),%rax
mulq    320(%rsp)
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    232(%rsp),%rax
mulq    336(%rsp)
addq    %rax,%r10
adcq    $0,%r11
movq    %rdx,%r12
xorq    %r13,%r13

movq    240(%rsp),%rax
mulq    328(%rsp)
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    $38,%rax
mulq    %r10
imul    $38,%r11,%r11
movq    %rax,%r10
addq    %rdx,%r11

movq    240(%rsp),%rax
mulq    336(%rsp)
addq    %rax,%r12
adcq    $0,%r13

movq    $38,%rax
mulq    %rdx
movq    %rax,%r14
movq    %rdx,%r15

movq    $38,%rax
mulq    %r12
imul    $38,%r13,%r13
movq    %rax,%r12
addq    %rdx,%r13

movq    216(%rsp),%rax
mulq    336(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    224(%rsp),%rax
mulq    328(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    232(%rsp),%rax
mulq    320(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    240(%rsp),%rax
mulq    312(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    $38,%rax
mulq    %r8
imul    $38,%r9,%r9
movq    %rax,%r8
addq    %rdx,%r9

movq    216(%rsp),%rax
mulq    312(%rsp)
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    216(%rsp),%rax
mulq    320(%rsp)
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    224(%rsp),%rax
mulq    312(%rsp)
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    216(%rsp),%rax
mulq    328(%rsp)
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

movq    224(%rsp),%rax
mulq    320(%rsp)
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

movq    232(%rsp),%rax
mulq    312(%rsp)
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

addq    %r9,%r10
adcq    $0,%r11

addq    %r11,%r12
adcq    $0,%r13

addq    %r13,%r14
adcq    $0,%r15

shld    $1,%r14,%r15
andq    mask63(%rip),%r14
imul    $19,%r15,%r15

addq    %r15,%r8
adcq    $0,%r10
adcq    $0,%r12
adcq    $0,%r14

movq    %r8,136(%rsp)
movq    %r10,144(%rsp)
movq    %r12,152(%rsp)
movq    %r14,160(%rsp)

movb	200(%rsp),%cl
movb	204(%rsp),%bl
shrb    %cl,%bl
andb    $1,%bl
movb    %bl,%cl
xorb    202(%rsp),%bl
movb    %cl,202(%rsp)

cmpb    $1,%bl 

// CSelect(T1,T3,select)
movq    216(%rsp),%r8
movq    224(%rsp),%r9
movq    232(%rsp),%r10
movq    240(%rsp),%r11

movq    280(%rsp),%r12
movq    288(%rsp),%r13
movq    296(%rsp),%r14
movq    304(%rsp),%r15

cmove   %r12,%r8
cmove   %r13,%r9
cmove   %r14,%r10
cmove   %r15,%r11

movq    %r8,216(%rsp)
movq    %r9,224(%rsp)
movq    %r10,232(%rsp)
movq    %r11,240(%rsp)

// CSelect(T2,T4,select)
movq    248(%rsp),%rbx
movq    256(%rsp),%rbp
movq    264(%rsp),%rcx
movq    272(%rsp),%rsi

movq    312(%rsp),%r12
movq    320(%rsp),%r13
movq    328(%rsp),%r14
movq    336(%rsp),%r15

cmove   %r12,%rbx
cmove   %r13,%rbp
cmove   %r14,%rcx
cmove   %r15,%rsi

// T2 ← T2^2
movq    %rsi,%rax
mulq    %rsi
movq    %rax,%r12
xorq    %r13,%r13

movq    $38,%rax
mulq    %rdx
movq    %rax,%r14
movq    %rdx,%r15

movq    %rbp,%rax
mulq    %rsi
movq    %rax,%r8
xorq    %r9,%r9
movq    %rdx,%r10
xorq    %r11,%r11

addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    %rcx,%rax
mulq    %rcx
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    %rcx,%rax
mulq    %rsi
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    $38,%rax
mulq    %r10
imul    $38,%r11,%r11
movq    %rax,%r10
addq    %rdx,%r11

movq    $38,%rax
mulq    %r12
imul    $38,%r13,%r13
movq    %rax,%r12
addq    %rdx,%r13

movq    %rbx,%rax
mulq    %rsi
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    %rbp,%rax
mulq    %rcx
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    $38,%rax
mulq    %r8
imul    $38,%r9,%r9
movq    %rax,%r8
addq    %rdx,%r9

movq    %rbx,%rax
mulq    %rbx
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    %rbx,%rax
mulq    %rbp
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    %rbx,%rax
mulq    %rcx
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

movq    %rbp,%rax
mulq    %rbp
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

addq    %r9,%r10
adcq    $0,%r11

addq    %r11,%r12
adcq    $0,%r13

addq    %r13,%r14
adcq    $0,%r15

shld    $1,%r14,%r15
imul    $19,%r15,%r15
andq    mask63(%rip),%r14

addq    %r15,%r8
adcq    $0,%r10
adcq    $0,%r12
adcq    $0,%r14

movq    %r8,248(%rsp)
movq    %r10,256(%rsp)
movq    %r12,264(%rsp)
movq    %r14,272(%rsp)

// T1 ← T1^2
movq    216(%rsp),%rbx
movq    224(%rsp),%rbp
movq    232(%rsp),%rcx
movq    240(%rsp),%rsi

movq    %rsi,%rax
mulq    %rsi
movq    %rax,%r12
xorq    %r13,%r13

movq    $38,%rax
mulq    %rdx
movq    %rax,%r14
movq    %rdx,%r15

movq    %rbp,%rax
mulq    %rsi
movq    %rax,%r8
xorq    %r9,%r9
movq    %rdx,%r10
xorq    %r11,%r11

addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    %rcx,%rax
mulq    %rcx
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    %rcx,%rax
mulq    %rsi
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    $38,%rax
mulq    %r10
imul    $38,%r11,%r11
movq    %rax,%r10
addq    %rdx,%r11

movq    $38,%rax
mulq    %r12
imul    $38,%r13,%r13
movq    %rax,%r12
addq    %rdx,%r13

movq    %rbx,%rax
mulq    %rsi
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    %rbp,%rax
mulq    %rcx
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    $38,%rax
mulq    %r8
imul    $38,%r9,%r9
movq    %rax,%r8
addq    %rdx,%r9

movq    %rbx,%rax
mulq    %rbx
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    %rbx,%rax
mulq    %rbp
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    %rbx,%rax
mulq    %rcx
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

movq    %rbp,%rax
mulq    %rbp
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

addq    %r9,%r10
adcq    $0,%r11

addq    %r11,%r12
adcq    $0,%r13

addq    %r13,%r14
adcq    $0,%r15

shld    $1,%r14,%r15
imul    $19,%r15,%r15
andq    mask63(%rip),%r14

addq    %r15,%r8
adcq    $0,%r10
adcq    $0,%r12
adcq    $0,%r14

movq    %r8,216(%rsp)
movq    %r10,224(%rsp)
movq    %r12,232(%rsp)
movq    %r14,240(%rsp)

// X3 ← X3 + Z3
movq    136(%rsp),%r8
movq    144(%rsp),%r9
movq    152(%rsp),%r10
movq    160(%rsp),%r11

movq    %r8,%rbx
movq    %r9,%rbp
movq    %r10,%rcx
movq    %r11,%rsi

addq    168(%rsp),%r8
adcq    176(%rsp),%r9
adcq    184(%rsp),%r10
adcq    192(%rsp),%r11

movq    $0,%rax
movq    $38,%rdx
cmovae  %rax,%rdx

addq    %rdx,%r8
adcq    %rax,%r9
adcq    %rax,%r10
adcq    %rax,%r11

cmovc   %rdx,%rax
addq    %rax,%r8

movq    %r8,136(%rsp)
movq    %r9,144(%rsp)
movq    %r10,152(%rsp)
movq    %r11,160(%rsp)

// Z3 ← X3 - Z3
subq    168(%rsp),%rbx
sbbq    176(%rsp),%rbp
sbbq    184(%rsp),%rcx
sbbq    192(%rsp),%rsi

movq    $0,%rax
movq    $38,%rdx
cmovae  %rax,%rdx

subq    %rdx,%rbx
sbbq    %rax,%rbp
sbbq    %rax,%rcx
sbbq    %rax,%rsi

cmovc   %rdx,%rax
subq    %rax,%rbx

// Z3 ← Z3^2
movq    %rsi,%rax
mulq    %rsi
movq    %rax,%r12
xorq    %r13,%r13

movq    $38,%rax
mulq    %rdx
movq    %rax,%r14
movq    %rdx,%r15

movq    %rbp,%rax
mulq    %rsi
movq    %rax,%r8
xorq    %r9,%r9
movq    %rdx,%r10
xorq    %r11,%r11

addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    %rcx,%rax
mulq    %rcx
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    %rcx,%rax
mulq    %rsi
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    $38,%rax
mulq    %r10
imul    $38,%r11,%r11
movq    %rax,%r10
addq    %rdx,%r11

movq    $38,%rax
mulq    %r12
imul    $38,%r13,%r13
movq    %rax,%r12
addq    %rdx,%r13

movq    %rbx,%rax
mulq    %rsi
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    %rbp,%rax
mulq    %rcx
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    $38,%rax
mulq    %r8
imul    $38,%r9,%r9
movq    %rax,%r8
addq    %rdx,%r9

movq    %rbx,%rax
mulq    %rbx
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    %rbx,%rax
mulq    %rbp
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    %rbx,%rax
mulq    %rcx
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

movq    %rbp,%rax
mulq    %rbp
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

addq    %r9,%r10
adcq    $0,%r11

addq    %r11,%r12
adcq    $0,%r13

addq    %r13,%r14
adcq    $0,%r15

shld    $1,%r14,%r15
imul    $19,%r15,%r15
andq    mask63(%rip),%r14

addq    %r15,%r8
adcq    $0,%r10
adcq    $0,%r12
adcq    $0,%r14

movq    %r8,168(%rsp) 
movq    %r10,176(%rsp)
movq    %r12,184(%rsp)
movq    %r14,192(%rsp)

// X3 ← X3^2
movq    136(%rsp),%rbx
movq    144(%rsp),%rbp
movq    152(%rsp),%rcx
movq    160(%rsp),%rsi

movq    %rsi,%rax
mulq    %rsi
movq    %rax,%r12
xorq    %r13,%r13

movq    $38,%rax
mulq    %rdx
movq    %rax,%r14
movq    %rdx,%r15

movq    %rbp,%rax
mulq    %rsi
movq    %rax,%r8
xorq    %r9,%r9
movq    %rdx,%r10
xorq    %r11,%r11

addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    %rcx,%rax
mulq    %rcx
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    %rcx,%rax
mulq    %rsi
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    $38,%rax
mulq    %r10
imul    $38,%r11,%r11
movq    %rax,%r10
addq    %rdx,%r11

movq    $38,%rax
mulq    %r12
imul    $38,%r13,%r13
movq    %rax,%r12
addq    %rdx,%r13

movq    %rbx,%rax
mulq    %rsi
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    %rbp,%rax
mulq    %rcx
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    $38,%rax
mulq    %r8
imul    $38,%r9,%r9
movq    %rax,%r8
addq    %rdx,%r9

movq    %rbx,%rax
mulq    %rbx
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    %rbx,%rax
mulq    %rbp
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    %rbx,%rax
mulq    %rcx
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

movq    %rbp,%rax
mulq    %rbp
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

addq    %r9,%r10
adcq    $0,%r11

addq    %r11,%r12
adcq    $0,%r13

addq    %r13,%r14
adcq    $0,%r15

shld    $1,%r14,%r15
imul    $19,%r15,%r15
andq    mask63(%rip),%r14

addq    %r15,%r8
adcq    $0,%r10
adcq    $0,%r12
adcq    $0,%r14

// update X3
movq    %r8,136(%rsp) 
movq    %r10,144(%rsp)
movq    %r12,152(%rsp)
movq    %r14,160(%rsp)

// T3 ← T1 - T2
movq    216(%rsp),%rbx
movq    224(%rsp),%rbp
movq    232(%rsp),%rcx
movq    240(%rsp),%rsi

subq    248(%rsp),%rbx
sbbq    256(%rsp),%rbp
sbbq    264(%rsp),%rcx
sbbq    272(%rsp),%rsi

movq    $0,%rax
movq    $38,%rdx
cmovae  %rax,%rdx

subq    %rdx,%rbx
sbbq    %rax,%rbp
sbbq    %rax,%rcx
sbbq    %rax,%rsi

cmovc   %rdx,%rax
subq    %rax,%rbx

movq    %rbx,280(%rsp)
movq    %rbp,288(%rsp)
movq    %rcx,296(%rsp)
movq    %rsi,304(%rsp)

// T4 ← ((A + 2)/4) · T3
movq    a24(%rip),%rax
mulq    %rbx
movq    %rax,%r8
movq    %rdx,%r9

movq    $0,%r10
movq    a24(%rip),%rax
mulq    %rbp
addq    %rax,%r9
adcq    %rdx,%r10

movq    $0,%r11
movq    a24(%rip),%rax
mulq    %rcx
addq    %rax,%r10
adcq    %rdx,%r11

movq    $0,%r12
movq    a24(%rip),%rax
mulq    %rsi
addq    %rax,%r11
adcq    %rdx,%r12

shld    $1,%r11,%r12
andq    mask63(%rip),%r11

imul    $19,%r12,%r12
addq    %r12,%r8
adcq    $0,%r9
adcq    $0,%r10
adcq    $0,%r11

// T4 ← T4 + T2
addq    248(%rsp),%r8
adcq    256(%rsp),%r9
adcq    264(%rsp),%r10
adcq    272(%rsp),%r11

movq    $0,%rax
movq    $38,%rdx
cmovae  %rax,%rdx

addq    %rdx,%r8
adcq    %rax,%r9
adcq    %rax,%r10
adcq    %rax,%r11

cmovc   %rdx,%rax
addq    %rax,%r8

movq    %r8,312(%rsp) 
movq    %r9,320(%rsp)
movq    %r10,328(%rsp)
movq    %r11,336(%rsp)

// X2 ← T1 · T2
movq    224(%rsp),%rax
mulq    272(%rsp)
movq    %rax,%r8
xorq    %r9,%r9
movq    %rdx,%r10
xorq    %r11,%r11

movq    232(%rsp),%rax
mulq    264(%rsp)
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    240(%rsp),%rax
mulq    256(%rsp)
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    232(%rsp),%rax
mulq    272(%rsp)
addq    %rax,%r10
adcq    $0,%r11
movq    %rdx,%r12
xorq    %r13,%r13

movq    240(%rsp),%rax
mulq    264(%rsp)
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    $38,%rax
mulq    %r10
imul    $38,%r11,%r11
movq    %rax,%r10
addq    %rdx,%r11

movq    240(%rsp),%rax
mulq    272(%rsp)
addq    %rax,%r12
adcq    $0,%r13

movq    $38,%rax
mulq    %rdx
movq    %rax,%r14
movq    %rdx,%r15

movq    $38,%rax
mulq    %r12
imul    $38,%r13,%r13
movq    %rax,%r12
addq    %rdx,%r13

movq    216(%rsp),%rax
mulq    272(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    224(%rsp),%rax
mulq    264(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    232(%rsp),%rax
mulq    256(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    240(%rsp),%rax
mulq    248(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    $38,%rax
mulq    %r8
imul    $38,%r9,%r9
movq    %rax,%r8
addq    %rdx,%r9

movq    216(%rsp),%rax
mulq    248(%rsp)
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    216(%rsp),%rax
mulq    256(%rsp)
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    224(%rsp),%rax
mulq    248(%rsp)
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    216(%rsp),%rax
mulq    264(%rsp)
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

movq    224(%rsp),%rax
mulq    256(%rsp)
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

movq    232(%rsp),%rax
mulq    248(%rsp)
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

addq    %r9,%r10
adcq    $0,%r11

addq    %r11,%r12
adcq    $0,%r13

addq    %r13,%r14
adcq    $0,%r15

shld    $1,%r14,%r15
andq    mask63(%rip),%r14
imul    $19,%r15,%r15

addq    %r15,%r8
adcq    $0,%r10
adcq    $0,%r12
adcq    $0,%r14

// update X2
movq    %r8,72(%rsp) 
movq    %r10,80(%rsp)
movq    %r12,88(%rsp)
movq    %r14,96(%rsp)

// Z2 ← T3 · T4
movq    288(%rsp),%rax
mulq    336(%rsp)
movq    %rax,%r8
xorq    %r9,%r9
movq    %rdx,%r10
xorq    %r11,%r11

movq    296(%rsp),%rax
mulq    328(%rsp)
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    304(%rsp),%rax
mulq    320(%rsp)
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    296(%rsp),%rax
mulq    336(%rsp)
addq    %rax,%r10
adcq    $0,%r11
movq    %rdx,%r12
xorq    %r13,%r13

movq    304(%rsp),%rax
mulq    328(%rsp)
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    $38,%rax
mulq    %r10
imul    $38,%r11,%r11
movq    %rax,%r10
addq    %rdx,%r11

movq    304(%rsp),%rax
mulq    336(%rsp)
addq    %rax,%r12
adcq    $0,%r13

movq    $38,%rax
mulq    %rdx
movq    %rax,%r14
movq    %rdx,%r15

movq    $38,%rax
mulq    %r12
imul    $38,%r13,%r13
movq    %rax,%r12
addq    %rdx,%r13

movq    280(%rsp),%rax
mulq    336(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    288(%rsp),%rax
mulq    328(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    296(%rsp),%rax
mulq    320(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    304(%rsp),%rax
mulq    312(%rsp)
addq    %rax,%r14
adcq    $0,%r15
addq    %rdx,%r8
adcq    $0,%r9

movq    $38,%rax
mulq    %r8
imul    $38,%r9,%r9
movq    %rax,%r8
addq    %rdx,%r9

movq    280(%rsp),%rax
mulq    312(%rsp)
addq    %rax,%r8
adcq    $0,%r9
addq    %rdx,%r10
adcq    $0,%r11

movq    280(%rsp),%rax
mulq    320(%rsp)
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    288(%rsp),%rax
mulq    312(%rsp)
addq    %rax,%r10
adcq    $0,%r11
addq    %rdx,%r12
adcq    $0,%r13

movq    280(%rsp),%rax
mulq    328(%rsp)
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

movq    288(%rsp),%rax
mulq    320(%rsp)
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

movq    296(%rsp),%rax
mulq    312(%rsp)
addq    %rax,%r12
adcq    $0,%r13
addq    %rdx,%r14
adcq    $0,%r15

addq    %r9,%r10
adcq    $0,%r11

addq    %r11,%r12
adcq    $0,%r13

addq    %r13,%r14
adcq    $0,%r15

shld    $1,%r14,%r15
andq    mask63(%rip),%r14
imul    $19,%r15,%r15

addq    %r15,%r8
adcq    $0,%r10
adcq    $0,%r12
adcq    $0,%r14

// update Z2
movq    %r8,104(%rsp) 
movq    %r10,112(%rsp)
movq    %r12,120(%rsp)
movq    %r14,128(%rsp)

// Z3 ← Z3 · X1
movq    $9,%rdx

mulx    168(%rsp),%rbx,%r9
mulx    176(%rsp),%rbp,%r10
addq    %r9,%rbp

mulx    184(%rsp),%rcx,%r9
adcq    %r10,%rcx

mulx    192(%rsp),%rsi,%r10
adcq    %r9,%rsi
adcq    $0,%r10

shld    $1,%rsi,%r10
andq    mask63(%rip),%rsi

imul    $19,%r10,%r10
addq    %r10,%rbx
adcq    $0,%rbp
adcq    $0,%rcx
adcq    $0,%rsi

// update Z3
movq    %rbx,168(%rsp) 
movq    %rbp,176(%rsp)
movq    %rcx,184(%rsp)
movq    %rsi,192(%rsp)

movb    200(%rsp),%cl
subb    $1,%cl
movb    %cl,200(%rsp)
cmpb	$0,%cl
jge     .L2

movb    $7,200(%rsp)
movq    64(%rsp),%rax
movq    208(%rsp),%r15
subq    $1,%r15
movq    %r15,208(%rsp)
cmpq	$0,%r15
jge     .L1

movq    56(%rsp),%rdi

movq    72(%rsp),%r8 
movq    80(%rsp),%r9
movq    88(%rsp),%r10
movq    96(%rsp),%r11

// store final value of X2
movq    %r8,0(%rdi) 
movq    %r9,8(%rdi)
movq    %r10,16(%rdi)
movq    %r11,24(%rdi)

movq    104(%rsp),%r8 
movq    112(%rsp),%r9
movq    120(%rsp),%r10
movq    128(%rsp),%r11

// store final value of Z2
movq    %r8,32(%rdi) 
movq    %r9,40(%rdi)
movq    %r10,48(%rdi)
movq    %r11,56(%rdi)

movq 	 0(%rsp),%r11
movq 	 8(%rsp),%r12
movq 	16(%rsp),%r13
movq 	24(%rsp),%r14
movq 	32(%rsp),%r15
movq 	40(%rsp),%rbx
movq 	48(%rsp),%rbp

movq 	%r11,%rsp

ret
