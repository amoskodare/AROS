#ifndef _LOCALE_H_
#define _LOCALE_H_

/*
    Copyright ? 1995-2020, The AROS Development Team. All rights reserved.
*/

#include <exec/types.h>

#define CATCOMP_NUMBERS
#include "muimaster_strings.h"

/*** Prototypes *************************************************************/
/* Main *********************************************************************/
CONST_STRPTR _(ULONG ID);       /* Get a message, as a STRPTR */
#define __(id) ((IPTR) _(id))   /* Get a message, as an IPTR */

/* Setup ********************************************************************/
VOID Locale_Initialize(VOID);
VOID Locale_Deinitialize(VOID);

#endif /* _LOCALE_H_ */
