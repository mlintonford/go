// Copyright 2014 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

#include "textflag.h"
#include "asm_sparc64.h"

TEXT _rt0_sparc64_solaris(SB),NOSPLIT,$-8
	MOVD	$main(SB), TMP
	JMPL	TMP, ZR

TEXT main(SB),NOSPLIT,$-8
	MOVD	$(8+128+STACK_BIAS)(RSP), R8 // argv
	MOVD	$(128+STACK_BIAS)(RSP), R9 // argc
	MOVD	$runtime·rt0_go(SB), TMP
	JMPL	TMP, ZR
