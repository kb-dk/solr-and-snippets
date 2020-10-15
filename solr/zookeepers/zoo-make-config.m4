#
# Automagically generated config file -- don't edit
#
dnl run as (for instance)
dnl m4 -DHOME="/home/slu/projects/zookeeper" -DOMAIN=.kb.dk -DINSTANCE=2 -DNUMBER=3 -DHOST=index-test-0 zoo-make-config.m4 
#
ifelse(eval(INSTANCE <= NUMBER),1,
tickTime=2000
dataDir=format(`%s%s',HOME,INSTANCE)/current/data/INSTANCE
clientPort=eval(2180+INSTANCE)
initLimit=5
syncLimit=2

define(`host_name',`ifelse(HOST,`localhost',`localhost',format(`%s%s%s',HOST,ifelse($1,1,FIRST,ifelse($1,2,FIRST,eval(FIRST+1))),DOMAIN))')dnl
define(`SRV',`server.$1=host_name(`$1'):eval($1 + 2887):eval($1 + 3887)
ifelse(eval($1<NUMBER),1,`$0(incr($1))',`')')
SRV(1)
,
``#' You are joking, are you not?
')
