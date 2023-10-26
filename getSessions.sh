JBOSS_HOST_NAME=jhowell.rdu.csb
JBOSS_HOME=/home/jhowell/Projects/JBossBCBSAL/jboss_7.1.4_master

#get sessions in server 1
JBOSS_SERVER_NAME=server-one


echo "Server1 on 8080 pid ${pid}"
#Get the number of sessions in server-one
${JBOSS_HOME}/bin/jboss-cli.sh --connect --command="/host=${JBOSS_HOST_NAME}/server=${JBOSS_SERVER_NAME}/deployment=ServletSample.war/subsystem=undertow:read-attribute(name=active-sessions)"
#Get Sessions in Server 2

pid=$(lsof -i :8080 -sTCP:LISTEN |awk 'NR > 1 {print $2}')
echo "Server2 on 8230 pid ${pid}" 
JBOSS_SERVER_NAME=server-two
${JBOSS_HOME}/bin/jboss-cli.sh --connect --command="/host=${JBOSS_HOST_NAME}/server=${JBOSS_SERVER_NAME}/deployment=ServletSample.war/subsystem=undertow:read-attribute(name=active-sessions)"


pid=$(lsof -i :8080 -sTCP:LISTEN |awk 'NR > 1 {print $2}')
echo "Server3 on 8180 pid ${pid}" 
JBOSS_SERVER_NAME=server-three
${JBOSS_HOME}/bin/jboss-cli.sh --connect --command="/host=${JBOSS_HOST_NAME}/server=${JBOSS_SERVER_NAME}/deployment=ServletSample.war/subsystem=undertow:read-attribute(name=active-sessions)"
