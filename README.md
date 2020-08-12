## 64-bit assembly implementations of X25519

The source code of this directory correspond to the work [Security and Efficiency Trade-offs for Elliptic Curve Diffie-Hellman
at the 128-bit and 224-bit Security Levels](https://eprint.iacr.org/2019/1259), authored by [Kaushik Nath](kaushikn_r@isical.ac.in) & [Palash Sarkar](palash@isical.ac.in) of [Indian Statistical Institute, Kolkata, India](https://www.isical.ac.in),
containing various 64-bit implementations of X25519. The implementations of Montgomery ladder are developed using 64-bit assembly language targeting the modern Intel architectures like Skylake and Haswell.

To report a bug or make a comment regarding the implementations please drop a mail to: [Kaushik Nath](kaushikn_r@isical.ac.in).

---

### Compilation and execution of programs 
    
* Please compile the ```makefile``` in the **test** directory and execute the generated executable file. 
* One can change the architecture accordingly in the makefile before compilation. Default provided is ```Skylake```.
---

### Overview of the implementations in the repository

* **intel64-maa-4limb**: 4-limb 64-bit assembly implementation of X448 using the instructions ```mul/add/adc```. 

* **intel64-mxaa-4limb**: 4-limb 64-bit assembly implementation of X448 using the instructions ```mulx/add/adc```.

* **intel64-maax-4limb**: 4-limb 64-bit assembly implementation of X448 using the instructions ```mulx/adcx/adox```.

---    
