/*
    Copyright (C) 1995-2000 AROS - The Amiga Research OS
    $Id$

    Desc: Common startup code
    Lang: english
*/
#include <aros/config.h>
#include <dos/dos.h>
#include <proto/exec.h>
#include <proto/dos.h>
#include <aros/asmcall.h>

#if (AROS_FLAVOUR & AROS_FLAVOUR_NATIVE)
asm("
	.text

	move.l	4.w,a6
	jra	_detach_entry(pc)
");
#endif

AROS_UFP3(LONG, entry,
AROS_UFPA(char *,argstr,A0),
AROS_UFPA(ULONG,argsize,D0),
AROS_UFPA(struct ExecBase *,sysbase,A6));

AROS_UFH3(LONG, detach_entry,
AROS_UFHA(char *,argstr,A0),
AROS_UFHA(ULONG,argsize,D0),
AROS_UFHA(struct ExecBase *,SysBase,A6))
{
    static BOOL firsttime = TRUE;
    static BPTR mysegment = NULL;

    struct DosLibrary *DOSBase;

    DOSBase = (struct DosLibrary *)OpenLibrary(DOSNAME, 39);
    if (!DOSBase) return RETURN_FAIL;

    if (firsttime)
    {
	struct CommandLineInterface *cli = Cli();

        firsttime = FALSE;

        /*
 	     We cannot be started from WorkBench
	*/
        if (!cli) return RETURN_FAIL;

	mysegment = cli->cli_Module;
        cli->cli_Module = NULL;
    }

    if (mysegment)
    {
	struct Process *newproc;

	struct TagItem tags[] =
        {
	    { NP_Seglist,   (IPTR)mysegment          },
	    { NP_Name,      (IPTR)"Detached Process" },
	    { NP_Arguments, (IPTR)argstr             },
	    { NP_Cli,       TRUE                     },
            { TAG_DONE,     0                        }
        };

        mysegment = NULL;

	/* CreateNewProc() will take care of freeing the seglist */
	newproc = CreateNewProc(tags);

        CloseLibrary(DOSBase);

	return newproc ? RETURN_OK : RETURN_FAIL;
    }

    CloseLibrary(DOSBase);

    return AROS_UFC3(LONG, entry,
           AROS_UFCA(char *,argstr,A0),
           AROS_UFCA(ULONG,argsize,D0),
           AROS_UFCA(struct ExecBase *,SysBase,A6));
}
