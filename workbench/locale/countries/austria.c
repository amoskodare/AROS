/*
    Copyright (C) 1995-2019, The AROS Development Team. All rights reserved.

    Desc: Country data for ?sterreich (Austria)
          based on the Amiga Developer CD 2.1 file -:
          NDK/NDK_3.5/Examples/Locale/Countries/make_country_files.c
*/

#include "country_locale.h"
#include <libraries/locale.h>

struct IntCountryPrefs austriaPrefs =
{
    {
        /* Reserved */
        { 0, 0, 0, 0 },

        /* Country code (licence plate number), telephone code, measuring system */
        MAKE_ID('A',0,0,0), 43, MS_ISO,

        /* Date time format, date format, time format */
        "%A, %e. %B %Y, %H:%M:%S",
        "%A, %e. %B %Y",
        "%H:%M:%S",

        /* Short datetime, short date, short time formats */
        "%Y-%m-%d %H:%M:%S",
        "%Y-%m-%d",
        "%H:%M",

        /* Decimal point, group separator, frac group separator */
        ",", ".", "",

        /* For grouping rules, see <libraries/locale.h> */

        /* Grouping, Frac Grouping */
        { 3 }, { 0 },

        /* Mon dec pt, mon group sep, mon frac group sep */
        ",", ".", "",

        /* Mon Grouping, Mon frac grouping */
        { 3 }, { 0 },

        /* Mon Frac digits, Mon IntFrac digits, then number of digits in
           the fractional part of the money value. Most countries that
           use dollars and cents, would have 2 for this value

           (As would many of those you don't).
        */
        2, 2,

#ifdef _EURO
        /* Currency symbol, Small currency symbol */
        "Euro", "Cent",

        /* Int CS, this is the ISO 4217 symbol, followed by the character to
           separate that symbol from the rest of the money. (\x00 for none).
        */
        "EUR",
#else
        "?S", "g",
        "ATS",
#endif
        /* Mon +ve sign, +ve space sep, +ve sign pos, +ve cs pos */
        "", SS_SPACE, SP_PREC_ALL, CSP_PRECEDES,

        /* Mon -ve sign, -ve space sep, -ve sign pos, -ve cs pos */
        "-", SS_SPACE, SP_PREC_ALL, CSP_PRECEDES,

        /* Calendar type */
        CT_7MON
    },
    "$VER: austria.country 44.0 (02.04.2019)",
    "\xD6sterreich",
    "Countries/Austria"
};
