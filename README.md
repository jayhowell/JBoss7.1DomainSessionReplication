# Session Replication with JBoss 7.1 Using Domains.

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
2. Deploy the Session applciation
    1. Clone the repo for a session appliation

    `git clone https://github.com/jgpreetham/basic-servlet-example.git` or https://github.com/liweinan/cluster-demo/tree/master
    2\. edit the /basic\-servlet\-example/ServletSample/src/main/webapp/WEB\-INF and edit the web\.xml fileand add "\<distributable/\>" under the "\<web\-app\>"

ex:

```
      <web-app>
         <display-name>Sample Servlet Example</display-name>
         <distributable/>
```

This will turn on distributed sessions for that appliation.

<br>
1. Clean and package and deploy the application to both Server Groups

`mvn clean package`

1. Deploy content in the admin console to both Server groups
    1. go into the management console on your local system at http://127.0.0.1:9990/console using the name you defined.
    2. add the content
    3. assign the deployment to both the main-server-group and the other-server-group
2. Add "server-three" into the "other server group" in the console

* It's important that you call it "server-three" in order for the getsession.sh script to work.
 
3. find the URLs of all of your servers
* server-one - http://localhost:8080/ServletSample/
* server-two - http://localhost:8230/ServletSample/
* server-three - http://localhost:8180/ServletSample/


1. Understand How the domains are set up. 

* The main-server-group is set up using the "full" profile, which does not include session replication
* The other-server-group is set up to use the "full-ha" profile, which does include session replication


<br>
Fire up a Database
//login to the red hat registry
podman login registry.redhat.io
//Run the database creating a db called sessions
podman run --name mysql-basic -e MYSQL\_USER=user1 -e MYSQL\_PASSWORD=password -e MYSQL\_DATABASE=sessions -e MYSQL\_ROOT\_PASSWORD=password -d --rm registry.redhat.io/rhel8/mysql-80
//please note the --rm will remove the container and all associated storage essentially wiping out your database. This --rm makes your data transient. So if you were to
//Start your sessions, then kill the db, your sessions would be gone
//if you want a more permanent db that you can start and stop that retains state remve the "--rm"

go to your console, create a database under the ha-full profile and test it using