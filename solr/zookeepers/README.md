
# zoo.cfg and zookeeper.service

"just" edit 

* the config in the zoo-make-config.m4 macro 
* the settings in zookeeper-systemd-service.m4

and run the generate-configs.sh

```
./generate-configs.sh -j /etc/alternatives/jre_1.8.0 -f 3 -h index-prod-0 -d .kb.dk -o ./prod
./generate-configs.sh -j /etc/alternatives/jre_1.8.0 -f 3 -h index-stage-0 -d .kb.dk -o ./stage
./generate-configs.sh -j /usr/local/java/latest -f 1 -h index-test-0 -d .kb.dk -o ./test
'''
