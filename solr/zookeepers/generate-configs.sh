#!/bin/bash


for instance in {1..3}
do
   m4 -DINSTANCE=$instance -DNUMBER=3 -DHOME=/home/zookeeper -DHOST=index-test-0  -DDOMAIN=.kb.dk zoo-make-config.m4 
done

		
		
