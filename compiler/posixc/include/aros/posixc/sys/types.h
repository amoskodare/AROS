#ifndef _SYS_TYPES_H_
#define _SYS_TYPES_H_

/*
    Copyright ? 1995-2020, The AROS Development Team. All rights reserved.
    $Id$

    Desc: POSIX.1-2008 header file sys/types.h
*/

#include <aros/features.h>
#include <aros/system.h>
#include <aros/macros.h>

/*****************************************************************************/

#include <aros/types/off_t.h>
#include <aros/types/blk_t.h>
#include <aros/types/clock_t.h>
#include <aros/types/clockid_t.h>
#include <aros/types/dev_t.h>
#include <aros/types/fs_t.h>
#include <aros/types/gid_t.h>
#include <aros/types/id_t.h>
#include <aros/types/ino_t.h>
#include <aros/types/key_t.h>
#include <aros/types/mode_t.h>
#include <aros/types/nlink_t.h>

#include <aros/types/pid_t.h>
/* NOTIMPL
    pthread_attr_t
    pthread_cond_t
    pthread_condattr_t
    pthread_key_t
    pthread_mutex_t
    pthread_mutexattr_t
    pthread_once_t
    pthread_rwlock_t
    pthread_rwlockattr_t
    pthread_t
*/
#include <aros/types/size_t.h>
#include <aros/types/ssize_t.h>
#include <aros/types/socklen_t.h>
#include <aros/types/suseconds_t.h>
#include <aros/types/time_t.h>
#include <aros/types/timer_t.h>
/* NOTIMPL
    trace_event_id_t
    trace_event_set_t
    trace_id_t
*/
#include <aros/types/uid_t.h>

#if defined(__USE_BSD) || defined(__USE_NIXCOMMON)
#include <aros/types/int_t.h>
#endif

#if defined(__USE_BSD) && !defined(__u_char_defined)
#define  __u_char_defined
typedef unsigned char   u_char;
typedef unsigned short  u_short;
typedef unsigned int    u_int;
typedef unsigned long   u_long;
typedef int64_t       quad_t;
typedef uint64_t      u_quad_t;
#endif

/* Sys V/old C type compatibility */
#if defined(__USE_NIXCOMMON) && !defined(__posixc_misctypes_defined)
#define __posixc_misctypes_defined
typedef unsigned long int ulong;
typedef unsigned short  ushort;
typedef unsigned int    uint;
#endif

#if defined(__USE_BSD) && !defined(__posixc_bsdtypes_defined)
#define __posixc_bsdtypes_defined

typedef uint64_t      u_int64_t;      /* 64-bit unsigned integer */
typedef uint32_t      u_int32_t;      /* 32-bit unsigned integer */
typedef uint16_t      u_int16_t;      /* 16-bit unsigned integer */
typedef uint8_t       u_int8_t;       /* 8-bit unsigned integer  */
typedef quad_t *      qaddr_t;

#include <aros/types/socklen_t.h>
#include <aros/types/useconds_t.h>

typedef char *                    caddr_t;    /* Core address             */
typedef int32_t                   daddr_t;    /* Disk address             */
typedef uint32_t                  fixpt_t;    /* Fixed point number       */
typedef int64_t                   rlim_t;     /* Resource limit           */
typedef int64_t                   segsz_t;    /* Segment size             */
typedef int32_t                   swblk_t;    /* Swap offset              */

#endif /* __posixc_misctypes_defined */

#if defined(__USE_BSD) 
/*** Macros for endianness conversion ****************************************/

#define __htons(w) AROS_WORD2BE(w)
#define __htonl(l) AROS_LONG2BE(l)
#define __ntohs(w) AROS_BE2WORD(w)
#define __ntohl(l) AROS_BE2LONG(l)
#endif

#endif /* _SYS_TYPES_H_ */
