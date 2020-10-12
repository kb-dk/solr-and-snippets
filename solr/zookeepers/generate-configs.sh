#!/bin/bash

#
# Makes three config files for each of three zookeepers
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

for instance in {1..3}
do
    m4 -DINSTANCE=$instance \
       -DNUMBER=3 \
       -DHOME=$ZHOME \
       -DHOST=$ZHOST  \
       -DDOMAIN=$ZDOMAIN zoo-make-config.m4 > "zoo$instance.cfg"

    m4 -DINSTANCE=$instance \
       -DJAVA_DIR=$ZJAVA zookeeper-systemd-service.m4 > "zookeeper$instance.service"
done

		
		
