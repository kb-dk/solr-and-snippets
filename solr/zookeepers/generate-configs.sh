#!/bin/bash

#
# Makes three config files for each of three zookeepers
#

ZHOME=/home/zookeeper
ZHOST=index-test-0
# ZJAVA=/usr/local/java/latest
ZJAVA=/etc/alternatives/jre_1.8.0 

for instance in {1..3}
do
    m4 -DINSTANCE=$instance \
       -DNUMBER=3 \
       -DHOME=$ZHOME \
       -DHOST=$ZHOST  \
       -DDOMAIN=.kb.dk zoo-make-config.m4 > "zoo$instance.cfg"

    m4 -DINSTANCE=$instance \
       -DJAVA_DIR=$ZJAVA zookeeper-systemd-service.m4 > "zookeeper$instance.service"
done

		
		
