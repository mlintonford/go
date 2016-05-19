// Copyright 2016 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.
//
// System calls and other sys.stuff for SPARC64, Solaris.
//

#include "go_asm.h"
#include "textflag.h"
#include "asm_sparc64.h"

// int64 runtime·nanotime1(void);
//
// clock_gettime(3c) wrapper because Timespec is too large for
// runtime·nanotime stack.
//
// Called using runtime·sysvicall6 from os_solaris.c:/nanotime.
// NOT USING GO CALLING CONVENTION.
TEXT runtime·nanotime1(SB),NOSPLIT,$64
	MOVW	$3, O0	// CLOCK_REALTIME from <sys/time_impl.h>
	MOVD	$-16(BFP), O1
	MOVD	$libc_clock_gettime(SB), R27
	CALL	R27
	MOVD	-16(BFP), R27	// tv_sec from struct timespec
	MOVD	$1000000000, R25
	MULD	R25, R27	// multiply into nanoseconds
	MOVD	-8(BFP), R29	// tv_nsec, offset should be stable.
	ADD	R29, R27, O0
	RET

// pipe(3c) wrapper that returns fds in AX, DX.
// NOT USING GO CALLING CONVENTION.
TEXT runtime·pipe1(SB),NOSPLIT,$16
	MOVD	$FIXED_FRAME(BSP), O0
	MOVD	$libc_pipe(SB), R27
	CALL	R27
	MOVW	(FIXED_FRAME+0)(BSP), O0
	MOVW	(FIXED_FRAME+4)(BSP), O1
	RET

// Call a library function with SysV calling conventions.
// The called function can take a maximum of 6 INTEGER class arguments,
// see 
// 	SYSTEM V APPLICATION BINARY INTERFACE
// 	SPARC Version 9 Processor Supplement
// section 3.2.2.
//
// Called by runtime·asmcgocall or runtime·cgocall.
// NOT USING GO CALLING CONVENTION.
TEXT runtime·asmsysvicall6(SB),NOSPLIT,$0
	// asmcgocall will put first argument into I0.
	MOVD	I0, R23
	MOVD	libcall_fn(I0), R27
	MOVD	libcall_args(I0), R17
	MOVD	libcall_n(I0), R18

	CMP	R17, ZR
	BED	skipargs
	// Load 6 args into correspondent registers.
	MOVD	0(R17), O0
	MOVD	8(R17), O1
	MOVD	16(R17), O2
	MOVD	24(R17), O3
	MOVD	32(R17), O4
	MOVD	40(R17), O5
skipargs:

	MOVD	g, L0
	// Call SysV function
	CALL	R27
	MOVD	L0, g

	// Return result
	MOVD	O0, libcall_r1(R23)
	MOVD	O1, libcall_r2(R23)	
	RET

// uint32 tstart_sysvicall(M *newm);
TEXT runtime·tstart_sysvicall(SB),NOSPLIT,$0
	// TODO(aram):
	MOVD	$74, R27
	ADD	$'!', R27, R27
	MOVB	R27, dbgbuf(SB)
	MOVD	$2, R8
	MOVD	$dbgbuf(SB), R9
	MOVD	$2, R10
	MOVD	$libc_write(SB), R27
	CALL	R27
	UNDEF
	RET

// Careful, this is called by __sighndlr, a libc function. We must preserve
// registers as per AMD 64 ABI.
TEXT runtime·sigtramp(SB),NOSPLIT,$0
	// TODO(aram):
	MOVD	$75, R27
	ADD	$'!', R27, R27
	MOVB	R27, dbgbuf(SB)
	MOVD	$2, R8
	MOVD	$dbgbuf(SB), R9
	MOVD	$2, R10
	MOVD	$libc_write(SB), R27
	CALL	R27
	UNDEF
	RET

// Runs on OS stack, called from runtime·usleep1_go.
TEXT runtime·usleep2(SB),NOSPLIT,$0
	MOVW	usec+0(FP), O0
	MOVD	$libc_usleep(SB), R27
	CALL	R27
	RET

// Runs on OS stack, called from runtime·osyield.
TEXT runtime·osyield1(SB),NOSPLIT,$0
	MOVD	$libc_sched_yield(SB), R27
	CALL	R27
	RET

// func now() (sec int64, nsec int32)
TEXT time·now(SB),NOSPLIT,$16-12
	// TODO(aram):
	MOVD	$79, R27
	ADD	$'!', R27, R27
	MOVB	R27, dbgbuf(SB)
	MOVD	$2, R8
	MOVD	$dbgbuf(SB), R9
	MOVD	$2, R10
	MOVD	$libc_write(SB), R27
	CALL	R27
	UNDEF
	RET