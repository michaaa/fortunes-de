#!/bin/sh
### install.sh - installation skript for German fortunes
### Andreas Tille <tille@debian.org>
### GPL or EUPL

PREFIX=${PREFIX-"/usr/local"}

### Databases
FORTUNES=`find data -maxdepth 1 -type f | sed "s?data/??"`
FORTUNESMORE=`find data-more -maxdepth 1 -type f | sed "s?data-more/??"`
DIRS=`find data -maxdepth 1 -type d | sed "s?data/??" | sed "/data/d"`

DOC="README AUTHORS NEWS LIESMICH GPL-Deutsch"
DOCDIR=$PREFIX/${DOCDIR:-"doc/fortune-de"}
BINDIR=$PREFIX/${BINDIR:-"games"}
MANDIR=$PREFIX/${MANDIR:-"man"}
FORTUNEDIR=${FORTUNEDIR:-"$PREFIX/games"}
# SCRIPTS="spruch regeln"

FORTUNESDIR=$PREFIX/${FORTUNESDIR:-"share/games/fortunes"}
INSTDIR=$FORTUNESDIR/de

SCRIPTSEARCH=${SCRIPTSEARCH:-"$FORTUNESDIR"}

### Rezepte
REZEPTE=`find rezepte -maxdepth 1 -type d | sed "s?rezepte/??" | sed "/rezepte/d"`
REZEPTTMP=rezept.tmp.$$

str_it () {
  dat=`basename $1`
  cp -a -f $1 $INSTDIR
  # if [ "$UTF8" = "yes" ] ; then
     # Data files now are just UTF-8 encoded
     # recode latin1..u8 $INSTDIR/"$dat"
     # Create file with extension *.u8 to give Debian fortune binary a hint to this encoding
     ln -s "$dat" $INSTDIR/"$dat".u8
  # fi
  strfile -s $INSTDIR/"$dat"
}

if [ -d $DOCDIR ] || mkdir -p $DOCDIR
then cp -a -f $DOC $DOCDIR
else 
 echo "Unable to create $DOCDIR."
 exit 2
fi

if [ -d $INSTDIR ] || mkdir -p $INSTDIR
then
# nicht veränderte Datenfiles
 for spruch in $FORTUNES
 do
  str_it data/$spruch
 done
# Ungeprüfte und unsortierte Datenfiles
 for spruch in $FORTUNESMORE
 do
  str_it data-more/$spruch
 done
# Datenfiles, die einzeln besser pflegbar sind, aber zu einem
# Fortune-File zusammengefaßt werden
 mkdir tmp
 for dir in $DIRS
 do
  cat `find data/$dir -type f | sort` > tmp/$dir
  str_it tmp/$dir
  rm -f tmp/$dir
 done
# zu formatierende Daten
 cd predata 
# komische Namen
 sed "s/.*/Wie man sein Kind nicht nennen sollte: \\
  & \\
%/" prenamen | sed "\$d" > ../tmp/namen
 str_it ../tmp/namen
# "Warmduscher"
 sed "s/.*/Hallo &!\\
%/" prewarmduscher | sed "\$d" > ../tmp/warmduscher
 str_it ../tmp/warmduscher
 cd ..
# Rezepte
 for typ in $REZEPTE
 do
  rm -f ${REZEPTTMP}
  for rezept in `ls rezepte/$typ | sort`
  do
   cat rezepte/$typ/$rezept >> ${REZEPTTMP}
   echo "%" >> ${REZEPTTMP}
  done
  sed "$d" ${REZEPTTMP} > tmp/$typ
  str_it tmp/$typ
  rm -f ${REZEPTTMP}
 done
 rm -rf tmp
else
  echo "Unable to create $FORTUNESDIR."
  exit 3
fi

# Script-Pfade anpassen
mainsh="spruch"
if [ -d $BINDIR ] || mkdir -p $BINDIR
then
  cat bin/$mainsh.sh | \
      sed "s?/usr/local/share/games/fortunes?$SCRIPTSEARCH?" | \
      sed "s?\(FORTUNEPATH=\)/usr/local/games/?\1$FORTUNEDIR/?" \
      > $BINDIR/$mainsh
    chmod 755 $BINDIR/$mainsh
  for sh in `ls rezepte`
  do
    ln -sf $mainsh $BINDIR/$sh
  done
else
  echo  "Unable to create $BINDIR"
fi

MANLOCALES="/ /de/"
mainman="spruch.6"
for loc in ${MANLOCALES} ; do
  MAN6DIR=$MANDIR${loc}man6
  if [ -d $MAN6DIR ] || mkdir -p $MAN6DIR
  then
    cp -a man${loc}$mainman $MAN6DIR
    for man in `ls rezepte` ; do
      ln -sf $mainman $MAN6DIR/${man}.6
    done
#    if [ "$loc" = "/de/" ] ; then
#      ln -sf $mainman $MAN6DIR/fortune.6
#    fi
  else
    echo  "Unable to create $MAN6DIR"
  fi
done

if [ -f ${BINDIR}/fortune ] ; then
  if [ -f ${BINDIR}/fortune.en -o -L ${BINDIR}/fortune ] ; then
    echo "Es scheint schon eine frühere Version von fortunes-de installiert worden zu sein."
    echo "Verzichte auf das Umbenennen von ${BINDIR}/fortune."
  else
    mv ${BINDIR}/fortune ${BINDIR}/fortune.en
  fi
fi

exit $?

# Do not link to fortune because fortune is now internationalized
ln -sf $mainsh ${BINDIR}/fortune

MAN6DIR=$MANDIR/man6
if [ -f ${MAN6DIR}/fortune.6 ] ; then
  if [ -f ${MAN6DIR}/fortune.en.6 -o -L ${MAN6DIR}/fortune.6 ] ; then
    echo "Verzichte auf das Umbenennen von ${MAN6DIR}/fortune.en.6."
  else
    mv ${MAN6DIR}/fortune.6 ${MAN6DIR}/fortune.en.6
  fi
fi
if [ -f ${MAN6DIR}/fortune.6.gz ] ; then
  if [ -f ${MAN6DIR}/fortune.en.6.gz -o -L ${MAN6DIR}/fortune.6.gz ] ; then
    echo "Verzichte auf das Umbenennen von ${MAN6DIR}/fortune.en.6.gz."
  else
    mv ${MAN6DIR}/fortune.6.gz ${MAN6DIR}/fortune.en.6.gz
  fi
fi
ln -sf $mainman $MAN6DIR/fortune.6
