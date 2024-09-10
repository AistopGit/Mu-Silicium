#include <AsmMacroIoLib.h>

ASM_FUNC (PlaformAssemblyInit)
    orr	    r0, r0, #1 << 25	@ big-endian page tables
	mrcne   p15, 0, r6, c2, c0, 2   @ read ttb control reg
	orrne	r0, r0, #1		@ MMU enabled
	movne	r1, #0xfffffffd		@ domain 0 = client
	bic     r6, r6, #1 << 31        @ 32-bit translation system
	bic     r6, r6, #(7 << 0) | (1 << 4)	@ use only ttbr0
	mcrne	p15, 0, r3, c2, c0, 0	@ load page table pointer
	mcrne	p15, 0, r0, c8, c7, 0	@ flush I,D TLBs
	mcr	    p15, 0, r0, c7, c5, 4	@ ISB
	mcrne	p15, 0, r1, c3, c0, 0	@ load domain access control
	mcrne   p15, 0, r6, c2, c0, 2   @ load ttb control

    bx lr
