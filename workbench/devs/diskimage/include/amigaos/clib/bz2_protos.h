#ifndef CLIB_BZ2_PROTOS_H
#define CLIB_BZ2_PROTOS_H


/*
**	$VER: bz2_protos.h 2.1 (28.05.2012)
**
**	C prototypes. For use with 32 bit integers only.
**
**	Copyright ? 2012 
**	All Rights Reserved
*/

#include <exec/types.h>

const char * BZ2_bzlibVersion(void);
LONG BZ2_bzCompressInit(bz_stream * strm, LONG blockSize100k, LONG verbosity, LONG workFactor);
LONG BZ2_bzCompress(bz_stream * strm, LONG action);
LONG BZ2_bzCompressEnd(bz_stream * strm);
LONG BZ2_bzDecompressInit(bz_stream * strm, LONG verbosity, LONG small);
LONG BZ2_bzDecompress(bz_stream * strm);
LONG BZ2_bzDecompressEnd(bz_stream * strm);
LONG BZ2_bzBuffToBuffCompress(APTR dest, ULONG * destLen, LONG source, ULONG sourceLen,
	LONG blockSize100k, LONG verbosity, LONG workFactor);
LONG BZ2_bzBuffToBuffDecompress(APTR dest, ULONG * destLen, LONG source, ULONG sourceLen, LONG small,
	LONG verbosity);

#endif	/*  CLIB_BZ2_PROTOS_H  */
