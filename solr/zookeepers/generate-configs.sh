#!/bin/bash

#
# Makes three config files for each of three zookeepers,
# and three systemd startup scripts
#

# The zookeeper homes will become /home/zookeeper<i>, i=1,2,3
ZHOME=/home/zookeeper

# Note index-test-0 will be extended with index i=1,2,3
ZHOST=index-test-0

# The hostname will be suffixed with the ZDOMAIN
ZDOMAIN=.kb.dk

# The the systemctl and others where you java is
# ZJAVA=/usr/local/java/latest
ZJAVA=/etc/alternatives/jre_1.8.0 

OUT=./test


ARGS="--host hostname --domain domain name --java JAVA_HOME --home directory --out write results"

if [ $? != 0 ] ; then echo "Please give $ARGS ..." >&2 ; exit 1 ; fi

while true; do
    case "$1" in
	-h | --host ) ZHOST="$2"; shift 2 ;;
	-d | --domain ) ZDOMAIN="$2"; shift 2 ;;
	-j | --java ) ZJAVA="$2"; shift 2 ;;
	-t | --home ) ZHOME="$2"; shift 2 ;;
	-o | --out  ) OUT="$2"; shift 2 ;;
	* ) break ;;
    esac
done

echo "Parameters given
host               = $ZHOST
domain             = $ZDOMAIN 
java livs in       = $ZJAVA 
zookeeper lives in = $ZHOME 
writing config in  = $OUT"

for instance in {1..3}
do
    m4 -DINSTANCE=$instance \
       -DNUMBER=3 \
       -DHOME=$ZHOME \
       -DHOST=$ZHOST  \
       -DDOMAIN=$ZDOMAIN zoo-make-config.m4 > "$OUT/zoo$instance.cfg"

    m4 -DINSTANCE=$instance \
       -DJAVA_DIR=$ZJAVA zookeeper-systemd-service.m4 > "$OUT/zookeeper$instance.service"
done

		
		
