echo ${JBOSS_HOME}
${JBOSS_HOME}/bin/domain.sh --host-config=host-slave.xml -Djboss.domain.master.address=localhost -Djboss.management.native.port=10099
