/*
    (C) 1995-96 AROS - The Amiga Replacement OS
    $Id$
    $Log$
    Revision 1.3  1996/08/13 13:52:44  digulla
    Replaced <dos/dosextens.h> by "dos_intern.h" or added "dos_intern.h"
    Replaced __AROS_LA by __AROS_LHA

    Revision 1.2  1996/08/01 17:40:47  digulla
    Added standard header for all files

    Desc:
    Lang: english
*/
#include <clib/exec_protos.h>
#include "dos_intern.h"

/*****************************************************************************

    NAME */
	#include <clib/dos_protos.h>

	__AROS_LH1(struct DosList *, AttemptLockDosList,

/*  SYNOPSIS */
	__AROS_LHA(ULONG, flags, D1),

/*  LOCATION */
	struct DosLibrary *, DOSBase, 111, Dos)

/*  FUNCTION
	Tries to get a lock on some of the dos lists. If all went
	well a handle is returned that can be used for FindDosEntry().
	Don't try to busy wait until the lock can be granted - use
	LockDosList() instead.

    INPUTS
	flags - what lists to lock

    RESULT
	Handle to the dos list or NULL. This is not a direct pointer
	to the first list element but to a pseudo element instead.

    NOTES

    EXAMPLE

    BUGS

    SEE ALSO

    INTERNALS

    HISTORY
	29-10-95    digulla automatically created from
			    dos_lib.fd and clib/dos_protos.h

*****************************************************************************/
{
    __AROS_FUNC_INIT
    __AROS_BASE_EXT_DECL(struct DosLibrary *,DOSBase)
    if(flags&LDF_WRITE)
    {
	if(!AttemptSemaphore(&DOSBase->dl_DosListLock))
	    return NULL;
    }else
	if(!AttemptSemaphoreShared(&DOSBase->dl_DosListLock))
	    return NULL;
    return (struct DosList *)&DOSBase->dl_DevInfo;
    __AROS_FUNC_EXIT
} /* AttemptLockDosList */
