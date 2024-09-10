//
//  Copyright (c) 2011-2015, ARM Limited. All rights reserved.
//  Copyright (c) 2019, RUIKAI LIU and MR TUNNEL. All rights reserved.
//
//  This program and the accompanying materials
//  are licensed and made available under the terms and conditions of the BSD License
//  which accompanies this distribution.  The full text of the license may be found at
//  http://opensource.org/licenses/bsd-license.php
//
//  THE PROGRAM IS DISTRIBUTED UNDER THE BSD LICENSE ON AN "AS IS" BASIS,
//  WITHOUT WARRANTIES OR REPRESENTATIONS OF ANY KIND, EITHER EXPRESS OR IMPLIED.
//

#include <AsmMacroIoLib.h>

ASM_FUNC (_ModuleEntryPoint)
  // Run Platform Specific Code
  //bl   ASM_PFX (PlaformAssemblyInit)
  
  orr	    r0, r0, #1 << 25	            @ big-endian page tables
  mrcne     p15, 0, r6, c2, c0, 2           @ read ttb control reg
  orrne	    r0, r0, #1		                @ MMU enabled
  movne	    r1, #0xfffffffd		            @ domain 0 = client
  bic       r6, r6, #1 << 31                @ 32-bit translation system
  bic       r6, r6, #(7 << 0) | (1 << 4)	@ use only ttbr0
  mcrne	    p15, 0, r3, c2, c0, 0	        @ load page table pointer
  mcrne	    p15, 0, r0, c8, c7, 0	        @ flush I,D TLBs
  mcr	    p15, 0, r0, c7, c5, 4	        @ ISB
  mcrne	    p15, 0, r1, c3, c0, 0	        @ load domain access control
  mcrne     p15, 0, r6, c2, c0, 2           @ load ttb control

  // Get MpId
  bl   ASM_PFX (ArmReadMpidr)

  // Save MpId
  mov  r8, r0

SetupExceptionVector:
  // Get Exception Vector Address
  ldr  r0, =FixedPcdGet64(PcdCpuVectorBaseAddress)

  // Setup Exception Loop
  ldr  r1, NeverReturn
  mov  r2, #0

FillVectors:
  // Fill every 8 Bytes
  str  r1, [r0, r2]
  adds r2, r2, #8
  cmp  r2, #0x800
  bne  FillVectors

SetupCoreStack:
  // Get Stack Base & Size
  ldr  r0, =FixedPcdGet32(PcdPrePiStackBase)
  ldr  r1, =FixedPcdGet32(PcdPrePiStackSize)

  // Set Core Stack
  add r4, r0, r1
  add sp, r4, #0

EnableCaches:
  // Invalidate D-Cache
  // bl   ArmInvalidateDataCache

  // Enable I-Cache & D-Cache
  bl   ASM_PFX(ArmEnableInstructionCache)
  bl   ASM_PFX(ArmEnableDataCache)

JumpToC:
  // Restore Values
  mov  r0, r8
  ldr  r1, =FixedPcdGet32(PcdPrePiStackBase)
  ldr  r2, =FixedPcdGet32(PcdPrePiStackSize)
  mov  r3, sp

  // Set Jump Location
  ldr  r4, =ASM_PFX (CEntryPoint)

  // Jump to C Code
  blx  r4

NeverReturn:
  b NeverReturn

.align 3
