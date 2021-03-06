#ifndef KERNEL_SCHEDULER_H
#define KERNEL_SCHEDULER_H
/*
    Copyright ? 2017, The AROS Development Team. All rights reserved.
    $Id$

    Desc:
*/

#include <aros/config.h>

#if defined(__AROSEXEC_SMP__)
#include <exec/tasks.h>

struct X86SchedulerPrivate
{
    struct Task         *RunningTask;   /* Currently running task on this core                  */

    ULONG               ScheduleFlags;
    UWORD               Granularity;    /* length of one heartbear tick                         */
    UWORD               Quantum;        /* # of heartbeat ticks, a task may run                 */
    UWORD               Elapsed;        /* # of heartbeat ticks, the current task has run       */
    BYTE                IDNestCnt;
    BYTE                TDNestCnt;
};
#endif

BOOL core_Schedule(void);			/* Reschedule the current task if needed */
void core_Switch(void);				/* Switch away from the current task     */
struct Task *core_Dispatch(void);		/* Select the new task for execution     */
#if defined(__AROSEXEC_SMP__)
void core_InitScheduleData(struct X86SchedulerPrivate *);
#endif
#endif /* !KERNEL_SCHEDULER_H */