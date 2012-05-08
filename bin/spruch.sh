#!/bin/sh
FORTUNEPATH=/usr/local/games/
DATAPATH=/usr/local/share/games/fortunes
FORTUNE=${FORTUNEPATH}fortune
SCRIPT=`echo $0 | sed "s/^.*\/\([^\\]*\)/\1/"`
if [ _${SCRIPT}_ != _spruch_  -a _${SCRIPT}_ != _fortune_  ] ; then
  DB=/${SCRIPT}
fi

lang=$(locale  2>/dev/null | sed -ne 's/"$//;s/^LC_MESSAGES="\?//p')
[ -e /etc/locale.alias ] && l=$(sed -ne "s/^$(echo $lang | sed 's/\(\.\|\^\|\$\|\*\|\[\)/\\\1/g')[ 	]\+//ip" /etc/locale.alias)
[ -n "$l" ] && lang="$l"

# check for the currently used charmap
charmap=$(locale 2>/dev/null -k LC_CTYPE | sed -ne 's/^charmap="\([^"]*\)"$/\1/p')

# if there are any parameters check for given file name
found=0
if [ $# -gt 0 ] ; then
  for par in "$@" ; do
    if [ $found -eq 0 ] ; then
      if [ -e "$par" ] ; then
        DBPATH="$par"
	found=1
      fi
      if [ -e "${DATAPATH}/$par" ] ; then
        DBPATH="${DATAPATH}/$par"
	found=1
      fi
    fi
  done
fi
if [ $found -eq 0 ] ; then
  DBPATH="${DATAPATH}/de${DB}"
fi

if [ ! -d ${DBPATH} ] ; then
    if [ ! -e ${DBPATH}.dat ] ; then
	echo "Database ${DBPATH} not installed.  Please try"
        echo "   dpkg-reconfigure fortunes-de"
        echo "to install more databases."
        exit
    fi
fi

if [ X"$1" = X"-x" ] ; then
   FORTUNE="${FORTUNE} ${DBPATH}"
   shift
else
   case "$lang" in
      de*)
      FORTUNE="${FORTUNE} ${DBPATH}"
     ;;
   esac
fi

$FORTUNE "$@" | iconv -f "iso-8859-1" -t "$charmap"
