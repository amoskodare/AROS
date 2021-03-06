#ifndef _AROS_TYPES_STACK_T_H
#define _AROS_TYPES_STACK_T_H

/*
    Copyright ? 2010-2011, The AROS Development Team. All rights reserved.
    $Id$

    POSIX.1-2008 stack_t type definition
*/

#include <aros/types/size_t.h>

#define SS_ONSTACK	0x0001
#define SS_DISABLE	0x0002

/* For sigaltstack() and the sigaltstack structure */
typedef struct
{
    void	    *ss_sp;		/* signal stack base */
    size_t	    ss_size;		/* signal stack size */
    int		    ss_flags;		/* SS_DISABLE and/or SS_ONSTACK */
} stack_t;

#endif /* _AROS_TYPES_STACK_T_H */
