#!/bin/bash
#
# a shell script that allows to convert between Amiga-style catalog
# description/translation files (.cd/.ct) and gettext-style translation
# files (.pot/.po).
#
# Copyright 2013-2014 Jens Maus <mail@jens-maus.de>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#
# $Id$
#

VERSION="1.6"

########################################################
# Script starts here
#

displayUsage()
{
  echo >&2 "cd2po.sh v${VERSION} - convert between Amiga-style and gettext translation files"
  echo >&2 "Copyright (c) 2013-2014 Jens Maus <mail@jens-maus.de>"
  echo >&2 
  echo >&2 "Usage: $0 <options> [inputfile (.cd/.ct/.pot/.po)]"
  echo >&2 "Options:"
  echo >&2 "  -c <charset> : use <charset> when converting the input file"
  echo >&2 "                 default: iso-8859-1"
}

################################
# AWK scripts                  #
################################

# the following is an awk script that converts an
# Amiga-style catalog description file (.cd) to a gettext
# PO-style translation template file (.pot).
read -d '' cd2pot << 'EOF'
BEGIN {
  tagfound=0
  firsttag=0
  multiline=0

  # get current date/time
  cmd="date +'%Y-%m-%d %H:%M%z'"
  cmd | getline date

  print "# Translation catalog description file (pot-style)"
  print "# $Id$"
  print "#"
  print "# WARNING: This file was automatically generated by cd2po.sh"
  print "#"
}
{
  if(firsttag == 0)
  {
    if($0 ~ /^#version .*/)
    {
      version=$2
      next
    }
    else if($0 ~ /^#language .*/)
    {
      language=$2
      next
    }
  }

  if($0 ~ /^MSG_.*\(.*\)/)
  {
    if(tagfound == 1)
    {
      # this is the end of the current
      # tag so lets output it in PO-format
      print ""
      #print "#: " msgcomment
      if(length(comment) > 0)
      {
        print comment
      }
      print "msgctxt \\"" msgctxt "\\""
      print "msgid " msgid
      print "msgstr \\"\\""
    }
 
    tagfound=1

    if(firsttag == 0)
    {
      print "# version " version
      print "# language " language
      print "#"
      print "#, fuzzy"
      print "msgid \\"\\""
      print "msgstr \\"\\""
      print "\\"Project-Id-Version: " version "\\\\n\\""
      print "\\"Report-Msgid-Bugs-To: http://URL/\\\\n\\""
      print "\\"POT-Creation-Date: " date "\\\\n\\""
      print "\\"PO-Revision-Date: YEAR-MO-DA HO:MI+ZONE\\\\n\\""
      print "\\"Last-Translator: FULL NAME <EMAIL@ADDRESS>\\\\n\\""
      print "\\"Language-Team: LANGUAGE <LL@li.org>\\\\n\\""
      print "\\"MIME-Version: 1.0\\\\n\\""
      print "\\"Content-Type: text/plain; charset=UTF-8\\\\n\\""
      print "\\"Content-Transfer-Encoding: 8bit\\\\n\\""
      print "\\"Language: " language "\\\\n\\""

      firsttag=1
    }

    msgctxt=$0
    msgcomment=$1

    # proceed with next word
    next
  }
  else if($0 ~ /^;$/)
  {
    if(tagfound == 1)
    {
      # this is the end of the current
      # tag so lets output it in PO-format
      print ""
      #print "#: " msgcomment
      if(length(comment) > 0)
      {
        print comment
      }
      print "msgctxt \\"" msgctxt "\\""
      print "msgid " msgid
      print "msgstr \\"\\""
    }
   
    tagfound=0
    multiline=0
    comment=""

    # proceed with next word
    next
  }
  else if($0 ~ /^;.+/)
  {
    if(length(comment) > 0)
    {
      comment = comment "\\n"
    }

    tmp=substr($0, 2)

    # remove any leading white space
    gsub(/^ /, "", tmp)

    # replace \\\\ by \\
    gsub(/\\\\\\\\/, "\\\\", tmp)

    comment = comment "#. " tmp
    multiline=0

    # proceed with next word
    next
  }

  if(tagfound == 1)
  {
    // remove any backslash at the end of line
    gsub(/\\\\$/, "")

    # replace \e with \033
    gsub(/\\\\\\e/, "\\\\033")

    # replace plain " with \" but make
    # sure to check if \" is already there
    gsub(/\\\\"/, "\\"") # replace \" with "
    gsub(/"/, "\\\\\\"") # replace " with \"

    # replace \\\\ by \\
    gsub(/\\\\\\\\/, "\\\\")

    # we have to escape the \033 and other escape
    # sequences
    gsub(/\\\\0/,  "\\\\\\\\\\\\0")
    gsub(/\\\\33/, "\\\\\\\\\\\\033")

    if(multiline == 0)
    {
      # the .po format doesn't allow empty msgid
      # strings, thus lets escape them with <EMPTY>
      if(length($0) == 0)
      {
        msgid="\\"<EMPTY>\\""
      }
      else
      {
        msgid="\\"" $0 "\\""
      }

      multiline=1
    }
    else
    {
      msgid=msgid "\\n" "\\"" $0 "\\""
    }
  }
}
EOF

# the following is an awk script that converts a
# gettext PO-style translation template file (.pot)
# to an Amiga-style catalog description file (.cd)
read -d '' pot2cd << 'EOF'
BEGIN {
  tagfound=0
  firsttag=0
  msgidfound=0
  print "; Catalog description file (Amiga-cd format)"
  print "; $Id$"
  print ";"
  print "; WARNING: This file was automatically generated by cd2po.sh"
  print ";"
}
{
  if(firsttag == 0)
  {
    if($0 ~ /^# version .*/)
    {
      version=$3
      next
    }
    else if($0 ~ /^# language .*/)
    {
      language=$3
      next
    }
  }

  if($0 ~ /^msgctxt "MSG_.*/)
  {
    tagfound=1
    msgidfound=0

    if(firsttag == 0)
    {
      print "#version " version
      print "#language " language
      print ";"

      firsttag=1
    }

    # extract the tag "MSG_XXXXX (X//)" as tag
    tag=substr($0, length($1)+2)

    # strip quotes (") from start&end
    gsub(/^"/, "", tag)
    gsub(/"$/, "", tag)
  }
  else if($0 ~ /^#\. .*/)
  {
    if(length(comment) > 0)
    {
      comment = comment "\\n"
    }

    # replace \\033 with \033
    gsub(/\\\\\\\\0/, "\\\\0")
    gsub(/\\\\\\\\33/, "\\\\033")

    # replace \\ by \\\\
    gsub(/\\\\\\\\/, "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\")

    comment = comment "; " substr($0, length($1)+2)
  }
  else if(length($0) == 0 && length(tag) != 0)
  {
    tagfound=0
    msgidfound=0

    print tag
    print msgid
    if(length(comment) > 0)
    {
      print comment
    }
    print ";"

    tag=""
    comment=""
  }

  if(tagfound == 1)
  {
    if($0 ~ /^msgid ".*/)
    {
      # get the msgid text only
      tmp=substr($0, length($1)+2)

      # strip quotes (") from start&end
      gsub(/^"/, "", tmp)
      gsub(/"$/, "", tmp)

      # replace \\033 with \033
      gsub(/\\\\\\\\0/, "\\\\0", tmp)
      gsub(/\\\\\\\\33/, "\\\\033", tmp)

      # replace \\ by \\\\
      gsub(/\\\\\\\\/, "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\", tmp)

      if(length(tmp) > 0)
      {
        # replace "<EMPTY>" with ""
        gsub(/<EMPTY>.*/, "", tmp)
        msgid = tmp
      }
      else
      {
        msgid=""
      }

      msgidfound=1
    }
    else if($0 ~ /^msgstr ".*/)
    {
      # ignore msgstr
      msgidfound=0
    }
    else if(msgidfound == 1)
    {
      # strip quotes (") from start&end
      gsub(/^"/, "")
      gsub(/"$/, "")

      # replace \\033 with \033
      gsub(/\\\\\\\\0/, "\\\\0")
      gsub(/\\\\\\\\33/, "\\\\033")

      # replace \\ by \\\\
      gsub(/\\\\\\\\/, "\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\")

      if(length(msgid) > 0)
      {
        msgid = msgid "\\\\\\n" $0
      }
      else
      {
        msgid = $0
      }
    }
  }
}
END {
  if(length(tag) != 0)
  {
    print tag
    print msgid
    if(length(comment) > 0)
    {
      print comment
    }
    print ";"
  }
}
EOF

# the following is an awk script that converts an
# Amiga-style catalog translation file (.ct) to a 
# gettext PO-style translation file (.po)
read -d '' ct2po << 'EOF'
BEGIN {
  tagfound=0
  firsttag=0
  multiline=0

  # get current date/time
  cmd="date +'%Y-%m-%d %H:%M%z'"
  cmd | getline date

  print "# Catalog translation file (po-style)"
  print "# $Id$"
  print "#"
  print "# WARNING: This file was automatically generated by cd2po.sh"
  print "#"
}
{
  if(firsttag == 0)
  {
    if($0 ~ /^## version .*/)
    {
      version=substr($0, length($1)+length($2)+3)
      next
    }
    else if($0 ~ /^## language .*/)
    {
      language=$3
      next
    }
    else if($0 ~ /^## codeset .*/)
    {
      codeset=$3
      next
    }
    else if($0 ~ /^## chunk AUTH .*/)
    {
      auth=substr($0, length($1)+length($2)+length($3)+4)
      next
    }
  }

  if($0 ~ /^MSG_.*$/)
  {
    tagfound=1
    multiline=0
    msgctxt=""
    msgid=""
    comment=""

    if(firsttag == 0)
    {
      print "# version " version
      print "# language " language
      print "# codeset " codeset
      print "# chunk AUTH " auth
      print "#"
      print "# Translators:"
      print "msgid \\"\\""
      print "msgstr \\"\\""
      print "\\"Project-Id-Version: " version "\\\\n\\""
      print "\\"Report-Msgid-Bugs-To: http://URL/\\\\n\\""
      print "\\"POT-Creation-Date: " date "\\\\n\\""
      print "\\"PO-Revision-Date: " date "\\\\n\\""
      print "\\"Last-Translator: " auth "\\\\n\\""
      print "\\"Language-Team: " language "\\\\n\\""
      print "\\"MIME-Version: 1.0\\\\n\\""
      print "\\"Content-Type: text/plain; charset=UTF-8\\\\n\\""
      print "\\"Content-Transfer-Encoding: 8bit\\\\n\\""
      print "\\"Language: " language "\\\\n\\""

      firsttag=1
    }

    # now we have to search in the CD file for the same string
    cmd="sed -n '/^" $1 " (/,/^;$/p' *.cd"
    while((cmd | getline output) > 0)
    {
      if(output ~ /^MSG_.*$/)
      {
        msgctxt=output
      }
      else if(output ~ /^;.+$/)
      {
        # replace \\\\ by \\
        gsub(/\\\\\\\\/, "\\\\", output)

        if(length(comment) > 0)
        {
          comment = comment "\\n"
        }

        tmp=substr(output, 2)
        gsub(/^ /, "", tmp)
        comment = comment "#. " tmp
      }
      else if(output ~ /^;$/)
      {
        # nothing
      }
      else if(length(msgctxt) > 0)
      {
        # remove any backslash at the end of line
        gsub(/\\\\$/, "", output)

        # replace \e with \033
        gsub(/\\\\\\e/, "\\\\033", output)

        # replace plain " with \" but make
        # sure to check if \" is already there
        gsub(/\\\\"/, "\\"", output) # replace \" with "
        gsub(/"/, "\\\\\\"", output) # replace " with \"

        # replace \\\\ by \\
        gsub(/\\\\\\\\/, "\\\\", output)

        # replace \033 with \\033
        gsub(/\\\\0/, "\\\\\\\\\\\\0", output)
        gsub(/\\\\33/, "\\\\\\\\\\\\033", output)

        if(length(msgid) > 0)
        {
          msgid = msgid "\\n"
        }

        msgid = msgid "\\"" output "\\""
      }
    }
    close(cmd)

    if(length(msgctxt) == 0)
    {
      tagfound=0
    }

    next
  }
  else if($0 ~ /^;.*$/)
  {
    if(tagfound == 1)
    {
      # output the stuff
      print ""
      if(length(comment) > 0)
      {
        print comment
      }
      print "msgctxt \\"" msgctxt "\\""

      # the .po format doesn't allow empty msgid
      # strings, thus lets escape them with <EMPTY>
      if(length(msgid) <= 2)
      {
        print "msgid \\"<EMPTY>\\""
      }
      else
      {
        # find out if this msgid is a multiline msgid or not
        if(msgid ~ /\\n/)
        {
          print "msgid \\"\\""
          print msgid
        }
        else
        {
          print "msgid " msgid
        }
      }

      print "msgstr \\"" msgstr "\\""
 
      tagfound=0
      multiline=0
    }

    next
  }

  if(tagfound == 1)
  {
    # remove any backslash at the end of line
    gsub(/\\\\$/, "")

    # replace \e with \033
    gsub(/\\\\\\e/, "\\\\033")

    # replace plain " with \" but make
    # sure to check if \" is already there
    gsub(/\\\\"/, "\\"") # replace \" with "
    gsub(/"/, "\\\\\\"") # replace " with \"

    # replace \033 with \\033
    gsub(/\\\\0/, "\\\\\\\\\\\\0")
    gsub(/\\\\33/, "\\\\\\\\\\\\033")

    if(multiline == 0)
    {
      msgstr = $0
      multiline=1
    }
    else
    {
      msgstr = msgstr $0
    }
  }
}
EOF

# the following is an awk script that converts a
# gettext PO-style translation file (.po) to an
# Amiga-style catalog translation file (.ct).
read -d '' po2ct << 'EOF'
BEGIN {
  tagfound=0
  firsttag=0
  msgidfound=0
  msgstrfound=0
}
{
  if(firsttag == 0)
  {
    if($0 ~ /^#? version .*/)
    {
      version=substr($0, length($1)+length($2)+3)
      next
    }
    else if($0 ~ /^# \\$Id: .* \\$$/)
    {
      revision=$4 # get revision out of $Id$ SVN keyword
      next
    }
    else if($0 ~ /^## language .*/)
    {
      language=$3
      next
    }
    else if($0 ~ /^## codeset .*/)
    {
      codeset=$3
      next
    }
    else if($0 ~ /^## chunk AUTH .*/)
    {
      auth=substr($0, length($1)+length($2)+length($3)+4)
      next
    }
    else if($0 ~ /^"PO-Revision-Date: .*"/)
    {
      revdate=substr($0, length($1)+2)
      gsub(/\\\\n"/, "", revdate);

      # parse the revision date
      cmd="date +'%d.%m.%Y' -d \\"" revdate "\\""
      cmd | getline revdate

      next
    }
    else if($0 ~ /^"Language: .*"/)
    {
      language=substr($0, length($1)+2)
      gsub(/\\\\n"/, "", language);
      next
    }
    else if($0 ~ /^"Language-Team: .*"/)
    {
      auth=substr($0, length($1)+2)
      gsub(/\\\\n"/, "", auth);
      next
    }
  }

  if($0 ~ /^msgctxt "MSG_.*/)
  {
    tagfound=1
    msgidfound=0
    msgstrfound=0
    msgid=""
    msgstr=""

    if(firsttag == 0)
    {
      print "## version $VER: XXXX.catalog " version "." revision " (" revdate ")"
      print "## language " lang
      print "## codeset " cset
      print "## chunk AUTH " auth
      print ";"
      print "; $Id$"
      print ";"

      firsttag=1
    }

    # strip quotes (") so that we get the plain MSG_XXXX
    # tag names
    gsub(/"/, "", $2);
    tag=$2
  }
  else if(length($0) == 0 && length(tag) != 0)
  {
    tagfound=0
    msgidfound=0
    msgstrfound=0

    if(length(msgstr) > 0)
    {
      print tag
      print msgstr
      print msgid
      print ";"
    }

    tag=""
  }

  if(tagfound == 1)
  {
    if($0 ~ /^msgid ".*/)
    {
      # get the msgid text only
      tmp=substr($0, length($1)+2)

      # strip quotes (") from start&end
      gsub(/^"/, "", tmp)
      gsub(/"$/, "", tmp)

      # replace \\033 with \033
      gsub(/\\\\\\\\0/, "\\\\0", tmp)
      gsub(/\\\\\\\\33/, "\\\\033", tmp)

      if(length(tmp) > 0)
      {
        if(length(msgid) > 0)
        {
          msgid = msgid "\\\\\\n; " tmp
        }
        else
        {
          msgid = "; " tmp
        }
      }

      msgstrfound=0
      msgidfound=1
    }
    else if($0 ~ /^msgstr ".*/)
    {
      # get the msgid text only
      tmp=substr($0, length($1)+2)

      # strip quotes (") from start&end
      gsub(/^"/, "", tmp)
      gsub(/"$/, "", tmp)

      # replace \\033 with \033
      gsub(/\\\\\\\\0/, "\\\\0", tmp)
      gsub(/\\\\\\\\33/, "\\\\033", tmp)

      if(length(tmp) > 0)
      {
        # replace "<EMPTY>" with ""
        gsub(/<EMPTY>.*/, "", tmp)

        if(length(msgstr) > 0)
        {
          msgstr = msgstr "\\\\\\n" tmp
        }
        else
        {
          msgstr = tmp
        }
      }

      msgstrfound=1
      msgidfound=0
    }
    else if(msgidfound == 1)
    {
      # strip quotes (") from start&end
      gsub(/^"/, "")
      gsub(/"$/, "")

      # replace \\033 with \033
      gsub(/\\\\\\\\0/, "\\\\0")
      gsub(/\\\\\\\\33/, "\\\\033")

      if(length($0) > 0)
      {
        if(length(msgid) > 0)
        {
          msgid = msgid "\\\\\\n; " $0
        }
        else
        {
          msgid = "; " $0
        }
      }
    }
    else if(msgstrfound == 1)
    {
      # strip quotes (") from start&end
      gsub(/^"/, "")
      gsub(/"$/, "")

      # replace \\033 with \033
      gsub(/\\\\\\\\0/, "\\\\0")
      gsub(/\\\\\\\\33/, "\\\\033")

      if(length($0) > 0)
      {
        if(length(msgstr) > 0)
        {
          msgstr = msgstr "\\\\\\n" $0
        }
        else
        {
          msgstr = $0
        }
      }
    }
  }
}
END {
  if(length(tag) != 0 && length(msgstr) > 0)
  {
    print tag
    print msgstr
    print msgid
    print ";"
  }
}
EOF

###################################################
identifyCharset()
{
  file="$1"
  charset=""
  
  case "${file}" in
    bosnian)
      charset="iso-8859-2"
    ;;
    catalan)
      charset="iso-8859-15"
    ;;
    croatian)
      charset="iso-8859-16"
    ;;
    czech)
      charset="iso-8859-2"
    ;;
    danish)
      charset="iso-8859-15"
    ;;
    dutch)
      charset="iso-8859-15"
    ;;
    finnish)
      charset="iso-8859-15"
    ;;
    french)
      charset="iso-8859-15"
    ;;
    german)
      charset="iso-8859-15"
    ;;
    greek)
      charset="iso-8859-7"
    ;;
    hungarian)
      charset="iso-8859-16"
    ;;
    italian)
      charset="iso-8859-15"
    ;;
    norwegian)
      charset="iso-8859-15"
    ;;
    polish)
      charset="iso-8859-16"
    ;;
    russian)
      charset="windows-1251" # this should be "Amiga-1251" but iconv doesn't support it :(
    ;;
    serbian)
      charset="iso-8859-16"
    ;;
    slovenian)
      charset="iso-8859-2"
    ;;
    spanish)
      charset="iso-8859-15"
    ;;
    swedish)
      charset="iso-8859-15"
    ;;
    turkish)
      charset="iso-8859-9"
    ;;
    *)
      charset="iso-8859-1"
    ;;
  esac

  echo ${charset}
}

identifyCodeset()
{
  file="$1"
  codeset=""
 
  case "${file}" in
    bosnian)
      codeset="5"
    ;;
    catalan)
      codeset="111"
    ;;
    croatian)
      codeset="112"
    ;;
    czech)
      codeset="5"
    ;;
    danish)
      codeset="111"
    ;;
    dutch)
      codeset="111"
    ;;
    finnish)
      codeset="111"
    ;;
    french)
      codeset="111"
    ;;
    german)
      codeset="111"
    ;;
    greek)
      codeset="10"
    ;;
    hungarian)
      codeset="112"
    ;;
    italian)
      codeset="111"
    ;;
    norwegian)
      codeset="111"
    ;;
    persian)
      codeset="0"
    ;;
    polish)
      codeset="112"
    ;;
    russian)
      codeset="2104" # 'Amiga-1251'
    ;;
    serbian)
      codeset="112"
    ;;
    slovenian)
      codeset="5"
    ;;
    spanish)
      codeset="111"
    ;;
    swedish)
      codeset="111"
    ;;
    turkish)
      codeset="12"
    ;;
    *)
      codeset="4"
    ;;
  esac

  echo ${codeset}
}

identifyLanguage()
{
  file="$1"
  language=""
  
  case "${file}" in
    bosnian)
      language="bosanski"
    ;;
    catalan)
      language="catal?"
    ;;
    croatian)
      language="hrvatski"
    ;;
    danish)
      language="dansk"
    ;;
    dutch)
      language="nederlands"
    ;;
    english-british)
      language="english-british"
    ;;
    finnish)
      language="suomi"
    ;;
    french)
      language="fran?ais"
    ;;
    german)
      language="deutsch"
    ;;
    hungarian)
      language="magyar"
    ;;
    italian)
      language="italiano"
    ;;
    japanese)
      language="nihongo"
    ;;
    korean)
      language="hangul"
    ;;
    norwegian)
      language="norsk"
    ;;
    persian)
      language="farsi"
    ;;
    polish)
      language="polski"
    ;;
    portuguese)
      language="portugu?s"
    ;;
    portuguese-brazil)
      language="portugu?s-brasil"
    ;;
    serbian)
      language="srpski"
    ;;
    slovenian)
      language="slovensko"
    ;;
    spanish)
      language="espa?ol"
    ;;
    swedish)
      language="svenska"
    ;;
    turkish)
      language="t?rk?e"
    ;;
    *)
      language=${file}
    ;;
  esac

  echo ${language}
}


###################################################
charset=""
inputfile="$1"

# parse the command-line options
while getopts "c:" opt
do
  case "$opt" in
    c)  charset="$OPTARG";;
    \?)   # unknown flag
      displayUsage
      exit 2;;
  esac
done
shift `expr $OPTIND - 1`

if [ -z "${inputfile}" ]; then
  displayUsage
  exit 2
fi
 
# lets identify by the file extension which operation to perform
fname=$(basename "${inputfile}")
filename="${fname%.*}"
extension="${fname##*.}"
case "${extension}" in
  cd) # convert from cd -> pot
    if [ -z "${charset}" ]; then
      charset="iso-8859-1"
    fi
    iconv -c -f "${charset}" -t utf8 ${inputfile} | awk "${cd2pot}"
  ;;
  ct) # convert from ct -> po
    if [ -z "${charset}" ]; then
      charset=$(identifyCharset ${filename})
    fi
    iconv -c -f ${charset} -t utf8 ${inputfile} | awk "${ct2po}"
  ;;
  po) # convert from po -> ct
    if [ -z "${charset}" ]; then
      charset=$(identifyCharset ${filename})
      codeset=$(identifyCodeset ${filename})
    fi
    lang=$(identifyLanguage ${filename})
    awk -v lang=${lang} -v cset=${codeset} "${po2ct}" ${inputfile} | iconv -c -f utf8 -t ${charset}
  ;;
  pot) # convert from pot -> cd
    if [ -z "${charset}" ]; then
      charset="iso-8859-1"
    fi
    awk "${pot2cd}" ${inputfile} | iconv -c -f utf8 -t ${charset}
  ;;
esac

exit 0
