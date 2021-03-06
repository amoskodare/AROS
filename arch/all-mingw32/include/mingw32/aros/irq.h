#ifndef _AROS_IRQ_H
#define _AROS_IRQ_H

/*
    Copyright ? 1995-2010, The AROS Development Team. All rights reserved.
    $Id$

    Desc: host-side IRQ API for Windows-hosted AROS
    Lang: english
    
    Warning: this API is experimental and subject to change.
*/

int          __declspec(dllimport) KrnAllocSystemIRQ(void);
void         __declspec(dllimport) KrnFreeSystemIRQ(unsigned char irq);
void *       __declspec(dllimport) KrnGetSystemIRQObject(unsigned char irq);
unsigned int __declspec(dllimport) KrnCauseSystemIRQ(unsigned char irq);

#endif
