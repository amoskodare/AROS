#ifndef _AROS_TYPES_SIGSET_T_H
#define _AROS_TYPES_SIGSET_T_H

/*
    Copyright ? 2010-2012, The AROS Development Team. All rights reserved.
    $Id$

    Desc: POSIX.1-2008 sigset_t type definition
*/

#include <aros/cpu.h>

/* TODO: Determine value for __POSIXC_SIGBITS */
#define _SIG_WORDS		4
#define _SIG_MAXSIG		(_SIG_WORDS * 32)

typedef struct {
    unsigned AROS_32BIT_TYPE __val[_SIG_WORDS];
} sigset_t;

#endif /* _AROS_TYPES_SIGSET_T_H */
