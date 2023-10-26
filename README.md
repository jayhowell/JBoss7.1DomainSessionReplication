# Session Replication with JBoss 7.1 Using Domains.
download JBoss
Set your JBOSS_HOME environment variable

Start the master server with the shell script

./add-user.sh admin foopassword

git clone https://github.com/jgpreetham/basic-servlet-example.git
or
https://github.com/liweinan/cluster-demo/tree/master
//go into the basic-servlet example
mvn clean package
//go into the management console on your local system at http://127.0.0.1:9990/console using the name you defined.
//add the content
//assign the deployment to both the main-server-group and the other-server-group
//go to
//http://localhost:8230/ServletSample/
//and
//http://localhost:8080/ServletSample/ 

You should see both appliations come up in both server_one and server_two

go into the /basic-servlet-example/ServletSample/src/main/webapp/WEB-INF and edit the web.xml file

and add "<distributable/>" under the "<web-app>"
ex:
<web-app>
  <display-name>Sample Servlet Example</display-name>
  <distributable/>

This will turn on distributed sessions for that appliation.


Fire up a Database
//login to the red hat registry
podman login registry.redhat.io
//Run the database creating a db called sessions
podman run --name mysql-basic -e MYSQL_USER=user1 -e MYSQL_PASSWORD=password -e MYSQL_DATABASE=sessions -e MYSQL_ROOT_PASSWORD=password -d --rm registry.redhat.io/rhel8/mysql-80
//please note the --rm will remove the container and all associated storage essentially wiping out your database.  This --rm makes your data transient.  So if you were to
//Start your sessions, then kill the db, your sessions would be gone
//if you want a more permanent db that you can start and stop that retains state remve the "--rm"

go to your console, create a database under the ha-full profile and test it using 
