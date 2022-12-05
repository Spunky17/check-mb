#!/bin/sh

VERSION="0.2"
TMP="/tmp"
WGET="/usr/bin/wget"
CAT="/usr/bin/cat"
GREP="/usr/bin/grep"
CUT="/usr/bin/cut"
GIT="/usr/bin/git"
DC="/usr/local/bin/docker-compose"

STATUS=0
RESULT=""

MBDINST="/opt/musicbrainz/musicbrainz-docker"
MBDGIT="musicbrainz-docker"
MBDURL="https://github.com/metabrainz/musicbrainz-docker"
MBDB="musicbrainz_db"
MBDBUSER="musicbrainz"

cd ${MBDINST}

case "$1" in
   "-sv"|"--serverversion")
      if [ -f ${MBINST} ]
      then
         rm -f ${MBINST}
      fi
      ${WGET} --output-file=/dev/null --output-document=${TMP}/${MBDGIT} ${MBDURL}
      MBDVER=`${CAT} ${TMP}/${MBDGIT} | ${GREP} "Current MB Branch:" | ${CUT} -f3 -d\> | ${CUT} -f1 -d\<`
      #echo "MBDVER: ${MBDVER}"
      LOCAL=`${GIT} describe --always --broken --dirty --tags`
      #LOCAL="v-2022-09-05"
      #echo "LOCAL: ${LOCAL}"
      RESULT="LOCAL: ${LOCAL}, MBDVER: ${MBDVER}"
      if [ "${LOCAL}" != "${MBDVER}" ]
      then
         STATUS=1
      else
         STATUS=0
      fi
      if [ -f ${MBINST} ]
      then
         rm -f ${MBINST}
      fi
   ;;
   "-rp"|"--replicationpackett")
      RESULT=`${DC} exec db psql -U ${MBDBUSER} -d ${MBDB} -c 'COPY(SELECT current_replication_sequence,last_replication_date FROM replication_control) TO STDOUT'`
      STATUS=0
   ;;
   "-?"|"-h"|"--help")
      echo
      echo "check-mb ${VERSION}"
      echo "-? | -h | --help      : prints out this help information"
      echo "-sv | --serverversion : prints out the current version of musicbrainz running"
      echo
      exit 0
   ;;
   *) exit 1
esac

echo ${RESULT}
#echo ${STATUS}
exit $STATUS
