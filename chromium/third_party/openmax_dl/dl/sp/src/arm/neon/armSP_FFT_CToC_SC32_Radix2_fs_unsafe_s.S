@//
@//  Copyright (c) 2013 The WebRTC project authors. All Rights Reserved.
@//
@//  Use of this source code is governed by a BSD-style license
@//  that can be found in the LICENSE file in the root of the source
@//  tree. An additional intellectual property rights grant can be found
@//  in the file PATENTS.  All contributing project authors may
@//  be found in the AUTHORS file in the root of the source tree.
@//
@//  This file was originally licensed as follows. It has been
@//  relicensed with permission from the copyright holders.

@//
@// 
@// File Name:  armSP_FFT_CToC_SC32_Radix2_fs_unsafe_s.s
@// OpenMAX DL: v1.0.2
@// Last Modified Revision:   5995
@// Last Modified Date:       Fri, 08 Jun 2007
@// 
@// (c) Copyright 2007-2008 ARM Limited. All Rights Reserved.
@// 
@// 
@//
@// Description:
@// Compute the first stage of a Radix 2 DIT in-order out-of-place FFT 
@// stage for a N point complex signal.
@// 

        
@// Include standard headers

#include "dl/api/arm/armCOMM_s.h"
#include "dl/api/arm/omxtypes_s.h"
        
        
@// Import symbols required from other files
@// (For example tables)
    
        
        
        
@// Set debugging level        
@//DEBUG_ON    SETL {TRUE}



@// Guarding implementation by the processor name
    
    
            
@// Guarding implementation by the processor name
    
    
@//Input Registers

#define pSrc		r0
#define pDst		r2
#define pTwiddle	r1
#define pPingPongBuf	r5
#define subFFTNum	r6
#define subFFTSize	r7


@//Output Registers


@//Local Scratch Registers

#define pointStep	r3
#define outPointStep	r3
#define grpSize		r4
#define setCount	r4
#define step		r8
#define dstStep		r8

@// Neon Registers

#define dX0	D0.S32
#define dX1	D1.S32
#define dY0	D2.S32
#define dY1	D3.S32


        .MACRO FFTSTAGE scaled, inverse, name
        
        @// Define stack arguments
        
        
        @// update subFFTSize and subFFTNum into RN6 and RN7 for the next stage
        
        
        MOV        subFFTSize,#2
        LSR        grpSize,subFFTNum,#1  
        MOV        subFFTNum,grpSize 
        
        
        @// pT0+1 increments pT0 by 8 bytes
        @// pT0+pointStep = increment of 8*pointStep bytes = 4*grpSize bytes
        @// Note: outPointStep = pointStep for firststage
        @// Note: setCount = grpSize/2 (reuse the updated grpSize for setCount)
        
        MOV        pointStep,grpSize,LSL #3
        RSB        step,pointStep,#8 
        
        
        @// Loop on the sets for grp zero

grpZeroSetLoop\name :	
        
        VLD1    dX0,[pSrc],pointStep
        VLD1    dX1,[pSrc],step                   @// step = -pointStep + 8
        SUBS    setCount,setCount,#1              @// decrement the loop counter
        
        .ifeqs "\scaled", "TRUE"
        
            VHADD    dY0,dX0,dX1
            VHSUB    dY1,dX0,dX1
        
        .ELSE
        
            VADD    dY0,dX0,dX1
            VSUB    dY1,dX0,dX1
        
         
        .ENDIF
        
        VST1    dY0,[pDst],outPointStep
        VST1    dY1,[pDst],dstStep                  @// dstStep =  step = -pointStep + 8
               
        BGT     grpZeroSetLoop\name
        
        
        @// reset pSrc to pDst for the next stage
        SUB     pSrc,pDst,pointStep                     @// pDst -= 2*grpSize 
        MOV     pDst,pPingPongBuf
                
        .endm
        
        
                
        M_START armSP_FFTFwd_CToC_SC32_Radix2_fs_OutOfPlace_unsafe,r4
        FFTSTAGE "FALSE","FALSE",fwd
        M_END

        
        
        M_START armSP_FFTInv_CToC_SC32_Radix2_fs_OutOfPlace_unsafe,r4
        FFTSTAGE "FALSE","TRUE",inv
        M_END
 
        
        
        M_START armSP_FFTFwd_CToC_SC32_Sfs_Radix2_fs_OutOfPlace_unsafe,r4
        FFTSTAGE "TRUE","FALSE",fwdsfs
        M_END

        
        
        M_START armSP_FFTInv_CToC_SC32_Sfs_Radix2_fs_OutOfPlace_unsafe,r4
        FFTSTAGE "TRUE","TRUE",invsfs
        M_END

	.end
