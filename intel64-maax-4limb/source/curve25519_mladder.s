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
.globl curve25519_mladder
curve25519_mladder:

movq 	%rsp, %r11
subq 	$376, %rsp

movq 	%r11,  0(%rsp)
movq 	%r12,  8(%rsp)
movq 	%r13, 16(%rsp)
movq 	%r14, 24(%rsp)
movq 	%r15, 32(%rsp)
movq 	%rbx, 40(%rsp)
movq 	%rbp, 48(%rsp)
movq 	%rdi, 56(%rsp)

// X1 ← XP, X3 ← XP
movq	0(%rsi), %r8
movq	%r8, 72(%rsp)
movq	%r8, 168(%rsp)
movq	8(%rsi), %r8
movq	%r8, 80(%rsp)
movq	%r8, 176(%rsp)
movq	16(%rsi), %r8
movq	%r8, 88(%rsp)
movq	%r8, 184(%rsp)
movq	24(%rsi), %r8
movq	%r8, 96(%rsp)
movq	%r8, 192(%rsp)   

// X2 ← 1
movq	$1, 104(%rsp)
movq	$0, 112(%rsp)
movq	$0, 120(%rsp)
movq	$0, 128(%rsp) 	 

// Z2 ← 0
movq	$0, 136(%rsp)
movq	$0, 144(%rsp)
movq	$0, 152(%rsp)
movq	$0, 160(%rsp)	 

// Z3 ← 1
movq	$1, 200(%rsp)
movq	$0, 208(%rsp)
movq	$0, 216(%rsp)
movq	$0, 224(%rsp)    

movq    $31, 240(%rsp)
movb	$6, 232(%rsp)
movb    $0, 234(%rsp)
movq    %rdx, 64(%rsp)

movq    %rdx, %rax

// Montgomery ladder loop

.L1:

addq    240(%rsp), %rax
movb    0(%rax), %r14b
movb    %r14b, 236(%rsp)

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
 * X3 ← X3 + Z3
 * Z3 ← X3 - Z3
 * Z3 ← Z3^2
 * X3 ← X3^2
 * T3 ← T1 - T2
 * T4 ← ((A + 2)/4) · T3
 * T4 ← T4 + T2
 * X2 ← T1 · T2
 * Z2 ← T3 · T4
 * Z3 ← Z3 · X1
 *
 */

// X2
movq    104(%rsp), %r8  
movq    112(%rsp), %r9
movq    120(%rsp), %r10
movq    128(%rsp), %r11

// copy X2
movq    %r8,  %rax	
movq    %r9,  %rbx
movq    %r10, %rbp
movq    %r11, %rsi

// T1 ← X2 + Z2
addq    136(%rsp), %r8
adcq    144(%rsp), %r9
adcq    152(%rsp), %r10
adcq    160(%rsp), %r11

movq    $0,   %rdi
movq    $38,  %rcx
cmovae  %rdi, %rcx

addq    %rcx, %r8
adcq    %rdi, %r9
adcq    %rdi, %r10
adcq    %rdi, %r11

cmovc   %rcx, %rdi
addq    %rdi, %r8

movq    %r8,  248(%rsp)
movq    %r9,  256(%rsp)
movq    %r10, 264(%rsp)
movq    %r11, 272(%rsp)

// T2 ← X2 - Z2
subq    136(%rsp), %rax
sbbq    144(%rsp), %rbx
sbbq    152(%rsp), %rbp
sbbq    160(%rsp), %rsi

movq    $0,   %rdi
movq    $38,  %rcx
cmovae  %rdi, %rcx

subq    %rcx, %rax
sbbq    %rdi, %rbx
sbbq    %rdi, %rbp
sbbq    %rdi, %rsi

cmovc   %rcx, %rdi
subq    %rdi, %rax

movq    %rax, 280(%rsp)
movq    %rbx, 288(%rsp)
movq    %rbp, 296(%rsp)
movq    %rsi, 304(%rsp)

// X3
movq    168(%rsp), %r8
movq    176(%rsp), %r9
movq    184(%rsp), %r10
movq    192(%rsp), %r11

// copy X3 
movq    %r8,  %rax
movq    %r9,  %rbx
movq    %r10, %rbp
movq    %r11, %rsi

// T3 ← X3 + Z3
addq    200(%rsp), %r8
adcq    208(%rsp), %r9
adcq    216(%rsp), %r10
adcq    224(%rsp), %r11

movq    $0,   %rdi
movq    $38,  %rcx
cmovae  %rdi, %rcx

addq    %rcx, %r8
adcq    %rdi, %r9
adcq    %rdi, %r10
adcq    %rdi, %r11

cmovc   %rcx, %rdi
addq    %rdi, %r8

movq    %r8,  312(%rsp)
movq    %r9,  320(%rsp)
movq    %r10, 328(%rsp)
movq    %r11, 336(%rsp)

// T4 ← X3 - Z3
subq    200(%rsp), %rax
sbbq    208(%rsp), %rbx
sbbq    216(%rsp), %rbp
sbbq    224(%rsp), %rsi

movq    $0,   %rdi
movq    $38,  %rcx
cmovae  %rdi, %rcx

subq    %rcx, %rax
sbbq    %rdi, %rbx
sbbq    %rdi, %rbp
sbbq    %rdi, %rsi

cmovc   %rcx, %rdi
subq    %rdi, %rax

movq    %rax, 344(%rsp)
movq    %rbx, 352(%rsp)
movq    %rbp, 360(%rsp)
movq    %rsi, 368(%rsp)

// Z3 ← T2 · T3
xorq    %r13, %r13
movq    280(%rsp), %rdx    

mulx    312(%rsp), %r8, %r9
mulx    320(%rsp), %rcx, %r10
adcx    %rcx, %r9     

mulx    328(%rsp), %rcx, %r11
adcx    %rcx, %r10    

mulx    336(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    288(%rsp), %rdx
   
mulx    312(%rsp), %rcx, %rbp
adcx    %rcx, %r9
adox    %rbp, %r10
    
mulx    320(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11
    
mulx    328(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    336(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    296(%rsp), %rdx
    
mulx    312(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11
    
mulx    320(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    328(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
    
mulx    336(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14
adcx    %r15, %r14

xorq    %rax, %rax
movq    304(%rsp), %rdx
    
mulx    312(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    320(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
    
mulx    328(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14
    
mulx    336(%rsp), %rcx, %rbp
adcx    %rcx, %r14
adox    %rbp, %r15			
adcx    %rax, %r15

xorq    %rbp, %rbp
movq    $38, %rdx

mulx    %r12, %rax, %r12 
adcx    %rax, %r8
adox    %r12, %r9

mulx    %r13, %rcx, %r13
adcx    %rcx, %r9
adox    %r13, %r10

mulx    %r14, %rcx, %r14
adcx    %rcx, %r10
adox    %r14, %r11

mulx    %r15, %rcx, %r15
adcx    %rcx, %r11
adox    zero, %r15
adcx    zero, %r15

shld    $1, %r11, %r15
andq    mask63, %r11

imul    $19, %r15, %r15
addq    %r15, %r8
adcq    $0, %r9
adcq    $0, %r10
adcq    $0, %r11

movq    %r8,  200(%rsp)
movq    %r9,  208(%rsp)
movq    %r10, 216(%rsp)
movq    %r11, 224(%rsp)

// X3 ← T1 · T4
xorq    %r13, %r13
movq    248(%rsp), %rdx    

mulx    344(%rsp), %r8, %r9
mulx    352(%rsp), %rcx, %r10
adcx    %rcx, %r9     

mulx    360(%rsp), %rcx, %r11
adcx    %rcx, %r10    

mulx    368(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    256(%rsp), %rdx
   
mulx    344(%rsp), %rcx, %rbp
adcx    %rcx, %r9
adox    %rbp, %r10
    
mulx    352(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11
    
mulx    360(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    368(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    264(%rsp), %rdx
    
mulx    344(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11
    
mulx    352(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    360(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
    
mulx    368(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14
adcx    %r15, %r14

xorq    %rax, %rax
movq    272(%rsp), %rdx
    
mulx    344(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    352(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
    
mulx    360(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14
    
mulx    368(%rsp), %rcx, %rbp
adcx    %rcx, %r14
adox    %rbp, %r15			
adcx    %rax, %r15

xorq    %rbp, %rbp
movq    $38, %rdx

mulx    %r12, %rax, %r12 
adcx    %rax, %r8
adox    %r12, %r9

mulx    %r13, %rcx, %r13
adcx    %rcx, %r9
adox    %r13, %r10

mulx    %r14, %rcx, %r14
adcx    %rcx, %r10
adox    %r14, %r11

mulx    %r15, %rcx, %r15
adcx    %rcx, %r11
adox    zero, %r15
adcx    zero, %r15

shld    $1, %r11, %r15
andq    mask63, %r11

imul    $19, %r15, %r15
addq    %r15, %r8
adcq    $0, %r9
adcq    $0, %r10
adcq    $0, %r11

movq    %r8,  168(%rsp)
movq    %r9,  176(%rsp)
movq    %r10, 184(%rsp)
movq    %r11, 192(%rsp)

movb	232(%rsp), %cl
movb	236(%rsp), %bl
shrb    %cl, %bl
andb    $1, %bl
movb    %bl, %cl
xorb    234(%rsp), %bl
movb    %cl, 234(%rsp)

cmpb    $1, %bl 

// CSelect(T1,T3,select)
movq    248(%rsp), %r8
movq    256(%rsp), %r9
movq    264(%rsp), %r10
movq    272(%rsp), %r11

movq    312(%rsp), %r12
movq    320(%rsp), %r13
movq    328(%rsp), %r14
movq    336(%rsp), %r15

cmove   %r12, %r8
cmove   %r13, %r9
cmove   %r14, %r10
cmove   %r15, %r11

movq    %r8,  248(%rsp)
movq    %r9,  256(%rsp)
movq    %r10, 264(%rsp)
movq    %r11, 272(%rsp)

// CSelect(T2,T4,select)
movq    280(%rsp), %rax
movq    288(%rsp), %rbx
movq    296(%rsp), %rbp
movq    304(%rsp), %rsi

movq    344(%rsp), %r12
movq    352(%rsp), %r13
movq    360(%rsp), %r14
movq    368(%rsp), %r15

cmove   %r12, %rax
cmove   %r13, %rbx
cmove   %r14, %rbp
cmove   %r15, %rsi

// T2 ← T2^2
xorq    %r13, %r13
movq    %rax, %rdx
    
mulx    %rbx, %r9, %r10

mulx    %rbp, %rcx, %r11
adcx    %rcx, %r10
    
mulx    %rsi, %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    %rbx, %rdx
    
mulx    %rbp, %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12
    
mulx    %rsi, %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    %rbp, %rdx
    
mulx    %rsi, %rcx, %r14
adcx    %rcx, %r13
adcx    %r15, %r14

shld    $1, %r14, %r15
shld    $1, %r13, %r14
shld    $1, %r12, %r13
shld    $1, %r11, %r12
shld    $1, %r10, %r11
shld    $1, %r9, %r10
shlq    $1, %r9
    
xorq    %rdx, %rdx
movq    %rax, %rdx
mulx    %rdx, %r8, %rdx
adcx    %rdx, %r9

movq    %rbx, %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r10
adcx    %rdx, %r11

movq    %rbp, %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r12
adcx    %rdx, %r13

movq    %rsi, %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r14
adcx    %rdx, %r15

xorq    %rbp, %rbp
movq    $38, %rdx    		

mulx    %r12, %rbx, %rbp
adcx    %r8, %rbx
adox    %r9, %rbp

mulx    %r13, %rcx, %rax
adcx    %rcx, %rbp
adox    %r10, %rax

mulx    %r14, %rcx, %rsi
adcx    %rcx, %rax
adox    %r11, %rsi

mulx    %r15, %rcx, %r15
adcx    %rcx, %rsi
adox    zero, %r15
adcx    zero, %r15

shld    $1, %rsi, %r15
andq    mask63, %rsi

imul    $19, %r15, %r15
addq    %r15, %rbx
adcq    $0, %rbp
adcq    $0, %rax
adcq    $0, %rsi

movq    %rbx, 280(%rsp)
movq    %rbp, 288(%rsp)
movq    %rax, 296(%rsp)
movq    %rsi, 304(%rsp)

// T1 ← T1^2
xorq    %r13, %r13
movq    248(%rsp), %rdx
    
mulx    256(%rsp), %r9, %r10

mulx    264(%rsp), %rcx, %r11
adcx    %rcx, %r10
    
mulx    272(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    256(%rsp), %rdx
    
mulx    264(%rsp), %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12
    
mulx    272(%rsp), %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    264(%rsp), %rdx
    
mulx    272(%rsp), %rcx, %r14
adcx    %rcx, %r13
adcx    %r15, %r14

shld    $1, %r14, %r15
shld    $1, %r13, %r14
shld    $1, %r12, %r13
shld    $1, %r11, %r12
shld    $1, %r10, %r11
shld    $1, %r9, %r10
shlq    $1, %r9
    
xorq    %rdx, %rdx
movq    248(%rsp), %rdx
mulx    %rdx, %r8, %rdx
adcx    %rdx, %r9

movq    256(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r10
adcx    %rdx, %r11

movq    264(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r12
adcx    %rdx, %r13

movq    272(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r14
adcx    %rdx, %r15

xorq    %rbp, %rbp
movq    $38, %rdx    		

mulx    %r12, %rbx, %rbp
adcx    %r8, %rbx
adox    %r9, %rbp

mulx    %r13, %rcx, %rax
adcx    %rcx, %rbp
adox    %r10, %rax

mulx    %r14, %rcx, %rsi
adcx    %rcx, %rax
adox    %r11, %rsi

mulx    %r15, %rcx, %r15
adcx    %rcx, %rsi
adox    zero, %r15
adcx    zero, %r15

shld    $1, %rsi, %r15
andq    mask63, %rsi

imul    $19, %r15, %r15
addq    %r15, %rbx
adcq    $0, %rbp
adcq    $0, %rax
adcq    $0, %rsi

movq    %rbx, 248(%rsp) 
movq    %rbp, 256(%rsp)
movq    %rax, 264(%rsp)
movq    %rsi, 272(%rsp)

// X3
movq    168(%rsp), %r8  
movq    176(%rsp), %r9
movq    184(%rsp), %r10
movq    192(%rsp), %r11

// copy X3
movq    %r8,  %rax	
movq    %r9,  %rbx
movq    %r10, %rbp
movq    %r11, %rsi

// X3 ← X3 + Z3
addq    200(%rsp), %r8
adcq    208(%rsp), %r9
adcq    216(%rsp), %r10
adcq    224(%rsp), %r11

movq    $0,   %rdi
movq    $38,  %rcx
cmovae  %rdi, %rcx

addq    %rcx, %r8
adcq    %rdi, %r9
adcq    %rdi, %r10
adcq    %rdi, %r11

cmovc   %rcx, %rdi
addq    %rdi, %r8

movq    %r8,  168(%rsp)
movq    %r9,  176(%rsp)
movq    %r10, 184(%rsp)
movq    %r11, 192(%rsp)

// Z3 ← X3 - Z3
subq    200(%rsp), %rax
sbbq    208(%rsp), %rbx
sbbq    216(%rsp), %rbp
sbbq    224(%rsp), %rsi

movq    $0,   %rdi
movq    $38,  %rcx
cmovae  %rdi, %rcx

subq    %rcx, %rax
sbbq    %rdi, %rbx
sbbq    %rdi, %rbp
sbbq    %rdi, %rsi

cmovc   %rcx, %rdi
subq    %rdi, %rax

// Z3 ← Z3^2
xorq    %r13, %r13
movq    %rax, %rdx
    
mulx    %rbx, %r9, %r10

mulx    %rbp, %rcx, %r11
adcx    %rcx, %r10
    
mulx    %rsi, %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    %rbx, %rdx
    
mulx    %rbp, %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12
    
mulx    %rsi, %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    %rbp, %rdx
    
mulx    %rsi, %rcx, %r14
adcx    %rcx, %r13
adcx    %r15, %r14

shld    $1, %r14, %r15
shld    $1, %r13, %r14
shld    $1, %r12, %r13
shld    $1, %r11, %r12
shld    $1, %r10, %r11
shld    $1, %r9, %r10
shlq    $1, %r9
    
xorq    %rdx, %rdx
movq    %rax, %rdx
mulx    %rdx, %r8, %rdx
adcx    %rdx, %r9

movq    %rbx, %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r10
adcx    %rdx, %r11

movq    %rbp, %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r12
adcx    %rdx, %r13

movq    %rsi, %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r14
adcx    %rdx, %r15

xorq    %rbp, %rbp
movq    $38, %rdx    		

mulx    %r12, %rbx, %rbp
adcx    %r8, %rbx
adox    %r9, %rbp

mulx    %r13, %rcx, %rax
adcx    %rcx, %rbp
adox    %r10, %rax

mulx    %r14, %rcx, %rsi
adcx    %rcx, %rax
adox    %r11, %rsi

mulx    %r15, %rcx, %r15
adcx    %rcx, %rsi
adox    zero, %r15
adcx    zero, %r15

shld    $1, %rsi, %r15
andq    mask63, %rsi

imul    $19, %r15, %r15
addq    %r15, %rbx
adcq    $0, %rbp
adcq    $0, %rax
adcq    $0, %rsi

movq    %rbx, 200(%rsp) 
movq    %rbp, 208(%rsp)
movq    %rax, 216(%rsp)
movq    %rsi, 224(%rsp)

// X3 ← X3^2
xorq    %r13, %r13
movq    168(%rsp), %rdx
    
mulx    176(%rsp), %r9, %r10

mulx    184(%rsp), %rcx, %r11
adcx    %rcx, %r10
    
mulx    192(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    176(%rsp), %rdx
    
mulx    184(%rsp), %rcx, %rdi
adcx    %rcx, %r11
adox    %rdi, %r12
    
mulx    192(%rsp), %rcx, %rdi
adcx    %rcx, %r12
adox    %rdi, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    184(%rsp), %rdx
    
mulx    192(%rsp), %rcx, %r14
adcx    %rcx, %r13
adcx    %r15, %r14

shld    $1, %r14, %r15
shld    $1, %r13, %r14
shld    $1, %r12, %r13
shld    $1, %r11, %r12
shld    $1, %r10, %r11
shld    $1, %r9, %r10
shlq    $1, %r9
    
xorq    %rdx, %rdx
movq    168(%rsp), %rdx
mulx    %rdx, %r8, %rdx
adcx    %rdx, %r9

movq    176(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r10
adcx    %rdx, %r11

movq    184(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r12
adcx    %rdx, %r13

movq    192(%rsp), %rdx
mulx    %rdx, %rcx, %rdx
adcx    %rcx, %r14
adcx    %rdx, %r15

xorq    %rbp, %rbp
movq    $38, %rdx    		

mulx    %r12, %rbx, %rbp
adcx    %r8, %rbx
adox    %r9, %rbp

mulx    %r13, %rcx, %rax
adcx    %rcx, %rbp
adox    %r10, %rax

mulx    %r14, %rcx, %rsi
adcx    %rcx, %rax
adox    %r11, %rsi

mulx    %r15, %rcx, %r15
adcx    %rcx, %rsi
adox    zero, %r15
adcx    zero, %r15

shld    $1, %rsi, %r15
andq    mask63, %rsi

imul    $19, %r15, %r15
addq    %r15, %rbx
adcq    $0, %rbp
adcq    $0, %rax
adcq    $0, %rsi

// update X3
movq    %rbx, 168(%rsp) 
movq    %rbp, 176(%rsp)
movq    %rax, 184(%rsp)
movq    %rsi, 192(%rsp)

// T3 ← T1 - T2
movq    248(%rsp), %rax
movq    256(%rsp), %rbx
movq    264(%rsp), %rsi
movq    272(%rsp), %rdi

subq    280(%rsp), %rax
sbbq    288(%rsp), %rbx
sbbq    296(%rsp), %rsi
sbbq    304(%rsp), %rdi

movq    $0,   %rbp
movq    $38,  %rcx
cmovae  %rbp, %rcx

subq    %rcx, %rax
sbbq    %rbp, %rbx
sbbq    %rbp, %rsi
sbbq    %rbp, %rdi

cmovc   %rcx, %rbp
subq    %rbp, %rax

movq    %rax, 312(%rsp) 
movq    %rbx, 320(%rsp)
movq    %rsi, 328(%rsp)
movq    %rdi, 336(%rsp)

// T4 ← ((A + 2)/4) · T3
xorq    %r12, %r12
movq    a24, %rdx

mulx    %rax, %rax, %rbp
mulx    %rbx, %rbx, %rcx
adcx    %rbp, %rbx

mulx    %rsi, %rsi, %rbp
adcx    %rcx, %rsi

mulx    %rdi, %rdi, %rcx
adcx    %rbp, %rdi
adcx    %r12, %rcx

shld    $1, %rdi, %rcx
andq    mask63, %rdi

imul    $19, %rcx, %rcx
addq    %rcx, %rax
adcq    $0, %rbx
adcq    $0, %rsi
adcq    $0, %rdi

// T4 ← T4 + T2
addq    280(%rsp), %rax
adcq    288(%rsp), %rbx
adcq    296(%rsp), %rsi
adcq    304(%rsp), %rdi

movq    $0,   %rbp
movq    $38,  %rcx
cmovae  %rbp, %rcx

addq    %rcx, %rax
adcq    %rbp, %rbx
adcq    %rbp, %rsi
adcq    %rbp, %rdi

cmovc   %rcx, %rbp
addq    %rbp, %rax

movq    %rax, 344(%rsp) 
movq    %rbx, 352(%rsp)
movq    %rsi, 360(%rsp)
movq    %rdi, 368(%rsp)

// X2 ← T1 · T2
xorq    %r13, %r13
movq    248(%rsp), %rdx    

mulx    280(%rsp), %r8, %r9
mulx    288(%rsp), %rcx, %r10
adcx    %rcx, %r9     

mulx    296(%rsp), %rcx, %r11
adcx    %rcx, %r10    

mulx    304(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    256(%rsp), %rdx
   
mulx    280(%rsp), %rcx, %rbp
adcx    %rcx, %r9
adox    %rbp, %r10
    
mulx    288(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11
    
mulx    296(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    304(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    264(%rsp), %rdx
    
mulx    280(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11
    
mulx    288(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    296(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
    
mulx    304(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14
adcx    %r15, %r14

xorq    %rax, %rax
movq    272(%rsp), %rdx
    
mulx    280(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    288(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
    
mulx    296(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14
    
mulx    304(%rsp), %rcx, %rbp
adcx    %rcx, %r14
adox    %rbp, %r15			
adcx    %rax, %r15

xorq    %rbp, %rbp
movq    $38, %rdx

mulx    %r12, %rax, %r12 
adcx    %rax, %r8
adox    %r12, %r9

mulx    %r13, %rcx, %r13
adcx    %rcx, %r9
adox    %r13, %r10

mulx    %r14, %rcx, %r14
adcx    %rcx, %r10
adox    %r14, %r11

mulx    %r15, %rcx, %r15
adcx    %rcx, %r11
adox    zero, %r15
adcx    zero, %r15

shld    $1, %r11, %r15
andq    mask63, %r11

imul    $19, %r15, %r15
addq    %r15, %r8
adcq    $0, %r9
adcq    $0, %r10
adcq    $0, %r11

// update X2
movq    %r8,  104(%rsp)
movq    %r9,  112(%rsp)
movq    %r10, 120(%rsp)
movq    %r11, 128(%rsp)

// Z2 ← T3 · T4
xorq    %r13, %r13
movq    344(%rsp), %rdx

mulx    312(%rsp), %r8, %r9
mulx    320(%rsp), %rcx, %r10
adcx    %rcx, %r9     

mulx    328(%rsp), %rcx, %r11
adcx    %rcx, %r10    

mulx    336(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    352(%rsp), %rdx
   
mulx    312(%rsp), %rcx, %rbp
adcx    %rcx, %r9
adox    %rbp, %r10
    
mulx    320(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11
    
mulx    328(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    336(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    360(%rsp), %rdx
    
mulx    312(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11
    
mulx    320(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    328(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
    
mulx    336(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14
adcx    %r15, %r14

xorq    %rax, %rax
movq    368(%rsp), %rdx
    
mulx    312(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    320(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
    
mulx    328(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14
    
mulx    336(%rsp), %rcx, %rbp
adcx    %rcx, %r14
adox    %rbp, %r15			
adcx    %rax, %r15

xorq    %rbp, %rbp
movq    $38, %rdx

mulx    %r12, %rax, %r12 
adcx    %rax, %r8
adox    %r12, %r9

mulx    %r13, %rcx, %r13
adcx    %rcx, %r9
adox    %r13, %r10

mulx    %r14, %rcx, %r14
adcx    %rcx, %r10
adox    %r14, %r11

mulx    %r15, %rcx, %r15
adcx    %rcx, %r11
adox    zero, %r15
adcx    zero, %r15

shld    $1, %r11, %r15
andq    mask63, %r11

imul    $19, %r15, %r15
addq    %r15, %r8
adcq    $0, %r9
adcq    $0, %r10
adcq    $0, %r11

// update Z2
movq    %r8,  136(%rsp)
movq    %r9,  144(%rsp)
movq    %r10, 152(%rsp)
movq    %r11, 160(%rsp)

// Z3 ← Z3 · X1
xorq    %r13, %r13
movq    200(%rsp), %rdx    

mulx    72(%rsp), %r8, %r9
mulx    80(%rsp), %rcx, %r10
adcx    %rcx, %r9     

mulx    88(%rsp), %rcx, %r11
adcx    %rcx, %r10    

mulx    96(%rsp), %rcx, %r12
adcx    %rcx, %r11
adcx    %r13, %r12

xorq    %r14, %r14
movq    208(%rsp), %rdx
   
mulx    72(%rsp), %rcx, %rbp
adcx    %rcx, %r9
adox    %rbp, %r10
    
mulx    80(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11
    
mulx    88(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    96(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
adcx    %r14, %r13

xorq    %r15, %r15
movq    216(%rsp), %rdx
    
mulx    72(%rsp), %rcx, %rbp
adcx    %rcx, %r10
adox    %rbp, %r11
    
mulx    80(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    88(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
    
mulx    96(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14
adcx    %r15, %r14

xorq    %rax, %rax
movq    224(%rsp), %rdx
    
mulx    72(%rsp), %rcx, %rbp
adcx    %rcx, %r11
adox    %rbp, %r12
    
mulx    80(%rsp), %rcx, %rbp
adcx    %rcx, %r12
adox    %rbp, %r13
    
mulx    88(%rsp), %rcx, %rbp
adcx    %rcx, %r13
adox    %rbp, %r14
    
mulx    96(%rsp), %rcx, %rbp
adcx    %rcx, %r14
adox    %rbp, %r15			
adcx    %rax, %r15

xorq    %rbp, %rbp
movq    $38, %rdx

mulx    %r12, %rax, %r12 
adcx    %rax, %r8
adox    %r12, %r9

mulx    %r13, %rcx, %r13
adcx    %rcx, %r9
adox    %r13, %r10

mulx    %r14, %rcx, %r14
adcx    %rcx, %r10
adox    %r14, %r11

mulx    %r15, %rcx, %r15
adcx    %rcx, %r11
adox    zero, %r15
adcx    zero, %r15

shld    $1, %r11, %r15
andq    mask63, %r11

imul    $19, %r15, %r15
addq    %r15, %r8
adcq    $0, %r9
adcq    $0, %r10
adcq    $0, %r11

// update Z3
movq    %r8,  200(%rsp)
movq    %r9,  208(%rsp)
movq    %r10, 216(%rsp)
movq    %r11, 224(%rsp)

movb    232(%rsp), %cl
subb    $1, %cl
movb    %cl, 232(%rsp)
cmpb	$0, %cl
jge     .L2

movb    $7, 232(%rsp)
movq    64(%rsp), %rax
movq    240(%rsp), %r15
subq    $1, %r15
movq    %r15, 240(%rsp)
cmpq	$0, %r15
jge     .L1

movq    56(%rsp), %rdi

movq    104(%rsp), %r8 
movq    112(%rsp), %r9
movq    120(%rsp), %r10
movq    128(%rsp), %r11

// store final value of X2
movq    %r8,   0(%rdi) 
movq    %r9,   8(%rdi)
movq    %r10, 16(%rdi)
movq    %r11, 24(%rdi)

movq    136(%rsp), %r8 
movq    144(%rsp), %r9
movq    152(%rsp), %r10
movq    160(%rsp), %r11

// store final value of Z2
movq    %r8,  32(%rdi) 
movq    %r9,  40(%rdi)
movq    %r10, 48(%rdi)
movq    %r11, 56(%rdi)

movq 	 0(%rsp), %r11
movq 	 8(%rsp), %r12
movq 	16(%rsp), %r13
movq 	24(%rsp), %r14
movq 	32(%rsp), %r15
movq 	40(%rsp), %rbx
movq 	48(%rsp), %rbp

movq 	%r11, %rsp

ret
