# Session Replication with EAP 7.1 Using Domains.

**Purpose:**
The purpose of this repo is to demonstrate both jboss session replication in a domain environment. As a bonus effort, we will be showing replication with infinispan over the wire and through a database. Interestingly enough, the database method can be used to bridge sessions accross multiple domains. This is not recommended. Domains have

<br>
Steps

1. Setup JBoss 7.1.4
    1. Download JBoss and patch to 7.1.4
    2. Set your JBOSS\_HOME and Java environment variable in setVars.sh
    3. Execute the setVars shell script
        `. setVars.sh`
        Please note the . followed by a space is not a typo. it's required to set the variables.
    4. Start the master server with the shell script
        `./masterRun`
    5. Make Sure you add the admin password, so you can get to the console
        `./add-user.sh admin foopassword`
2. Deploy the Session application
    1. Clone the repo for a session application
       `git clone https://github.com/jgpreetham/basic-servlet-example.git` 
    2. edit the /basic\-servlet\-example/ServletSample/src/main/webapp/WEB\-INF and edit the web\.xml file and add "\<distributable/\>" under the "\<web\-app\>"
    
    example:

```
      <web-app>
         <display-name>Sample Servlet Example</display-name>
         <distributable/>
```

This will turn on distributed sessions for that application.

3. Clean and package and deploy the application to both Server Groups

    1. Build the package
         `mvn clean package`

    2. Deploy content in the admin console to both Server groups
        1. go into the management console on your local system at http://127.0.0.1:9990/console using the name you defined.
        2. add the content
        3. assign the deployment to both the main-server-group and the other-server-group

    3. Add "server-three" into the "other server group" in the console
        * It's important that you call it "server-three" in order for the getsession.sh script to work.

    4. find the URLs of all of your servers(These were  mine)
        * server-one - http://localhost:8080/ServletSample/
        * server-two - http://localhost:8230/ServletSample/
        * server-three - http://localhost:8180/ServletSample/

    5. Understand How the domains are set up.
        * The main-server-group is set up using the "full" profile, which does not include session replication
        * The other-server-group is set up to use the "full-ha" profile, which does include session replication


4. Fire up a Database
    1. login to the red hat registry
        * podman login registry.redhat.io
    2. Run the database creating a db called sessions
    3. podman run --name mysql-basic -e MYSQL\_USER=user1 -e MYSQL\_PASSWORD=password -e MYSQL\_DATABASE=sessions -e MYSQL\_ROOT\_PASSWORD=password -d --rm registry.redhat.io/rhel8/mysql-80
        * //please note the --rm will remove the container and all associated storage essentially wiping out your database. This --rm makes your data transient. So if you were to
        * //Start your sessions, then kill the db, your sessions would be gone
        * //if you want a more permanent db that you can start and stop that retains state remve the "--rm"
5. Download and add the mysql datasource driver
    * from https://dev.mysql.com/downloads/connector/j/
    * choose platform indepdent and download zip file
    * Extract jdbc jar file
    * Upload that jdbc jar file as a module in your console
6. go to your console, add your datasource under the ha-full profile and test it
7. Add Logic to the domain.xml to enable writes to the db
    1. Look for the web session(name="web") section that looks like the following in the domain.xml file. Add the binary-keyed-jdbc-store.

```
<cache-container name="web" default-cache="dist" module="org.wildfly.clustering.web.infinispan">
    <transport lock-timeout="60000"/>
        <distributed-cache name="dist">
            <locking isolation="REPEATABLE_READ"/>
            <transaction mode="BATCH"/>
            <file-store/>
        </distributed-cache>                        
```


    2. Add the following block to the distributed cache.


```
<binary-keyed-jdbc-store data-source="mySQLDS" dialect="MYSQL" create-table="true" passivation="false" preload="true" purge="true" shared="true" singleton="false">
    <binary-keyed-table prefix="SESS">
       <id-column name="id" type="VARCHAR2(500)"/>
       <data-column name="datum" type="BLOB"/>
       <timestamp-column name="version" type="NUMBER"/>
    </binary-keyed-table>
```


    * Alternatively, you could have done this with the local-cache vs the distributed cache and the alternitive bock would look like. It probably makes more sense that you would choose the distributed cache or the db cache, but not both.


```
    <cache-container name="web" default-cache="database" module="org.wildfly.clustering.web.infinispan">
        <local-cache name="database" >
               <binary-keyed-jdbc-store data-source="mySQLDS" dialect="MYSQL" create-table="true" passivation="false" preload="true" purge="true" shared="true" singleton="false">
                    <binary-keyed-table prefix="SESS">
                        <id-column name="id" type="VARCHAR2(500)"/>
                        <data-column name="datum" type="BLOB"/>
                        <timestamp-column name="version" type="NUMBER"/>
                    </binary-keyed-table>
                </binary-keyed-jdbc-store>
       </local-cache>
   </cache-container>
```


    3. Restart your server.
