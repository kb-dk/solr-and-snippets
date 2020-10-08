#!/bin/bash

#
# Makes three config files for each of three zookeepers
#

for instance in {1..3}
do
    m4 -DINSTANCE=$instance \
       -DNUMBER=3 \
       -DHOME=/home/zookeeper \
       -DHOST=index-test-0  \
       -DDOMAIN=.kb.dk zoo-make-config.m4 > "zoo$instance.cfg"
done

		
		
