#ifndef KERNEL_INTERRUPTCONTROLLERS_H
#define KERNEL_INTERRUPTCONTROLLERS_H
/*
    Copyright ? 2017-2020, The AROS Development Team. All rights reserved.
    $Id$

    Desc:
*/

#ifdef KERNELIRQ_NEEDSCONTROLLERS
#include <inttypes.h>

/* Interrupt controller definitions ... */

struct IntrInstance;

typedef UBYTE   icid_t;
typedef UWORD   icintrid_t;

#define ICINTR_ICID(icintr)     ((icintr >> 8) & 0xFF)
#define ICINTR_INST(icintr)     (icintr & 0xFF)

/*
 * Details:
 * 
 * .ln_Node = "Controller Type" Name - set by the "driver".
 * .ln_Type = icid_t - value filled in by/returned from krnAddInterruptController.
 * .ln_Pri = use count - value filled in by/returned from krnAddInterruptController.
*/
struct IntrController
{
    struct Node ic_Node;
    ULONG        ic_Count;
    ULONG        ic_Type;                                                     /* IC drivers private "type"                              */
    ULONG        ic_Flags;
    APTR        ic_Private;
    icid_t      (*ic_Register)(struct KernelBase *);                          /* one time initialization called during Add              */
    BOOL        (*ic_Init)(struct KernelBase *, icid_t);                      /*                                                        */
    BOOL        (*ic_IntrEnable)(APTR, icid_t, icid_t);
    BOOL        (*ic_IntrDisable)(APTR, icid_t, icid_t);
    BOOL        (*ic_IntrAck)(APTR, icid_t, icid_t);
};

struct IntrMapping
{
    /*
     * im_Node.ln_Pri contains the Device IRQ
     * as used by KrnAddIRQHandler();
     */
    struct Node im_Node;
    UBYTE       im_Int;                                                         /* controller specific hardware interrupt to use        */
    UBYTE       im_Polarity;                                                    /* 0 = Default, 1 = HIGH, 2 = LOW                       */
    UBYTE       im_Trig;                                                        /* 0 = Default, 1 = LEVEL, 2 = EDGE                     */
};

/*
 * Interrupt controller needs to re-enable
 * the interrupt after acknowledging/processing
 */
#define ICF_ACKENABLE   (1 << 0)

#define ICF_READY       (1 << 30)
#define ICF_DISABLED    (1 << 31)

static inline struct IntrController *krnGetInterruptController(struct KernelBase *KernelBase, icid_t icid)
{
    struct IntrController *intContr;
    ForeachNode(&KernelBase->kb_ICList, intContr)
    {
        if (intContr->ic_Node.ln_Type == icid)
        {
            return intContr;
        }
    }
    return NULL;
}

/* Functions to be called by machine-specific code */
icintrid_t krnAddInterruptController(struct KernelBase *, struct IntrController *);
struct IntrController *krnFindInterruptController(struct KernelBase *, ULONG);
int krnInitInterruptControllers(struct KernelBase *);
BOOL krnInitInterrupt(struct KernelBase *, icid_t, icid_t, icid_t);
struct IntrMapping *krnInterruptMapping(struct KernelBase *, icid_t);
struct IntrMapping *krnInterruptMapped(struct KernelBase *, icid_t);

#endif /* KERNELIRQ_NEEDSCONTROLLERS */
#endif /* !KERNEL_INTERRUPTCONTROLLERS_H */
