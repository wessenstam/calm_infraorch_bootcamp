.. _calm_multivm_linux:

------------------------------
Calm: Linux Multi VM Blueprint
------------------------------

*The estimated time to complete this lab is 60 minutes.*

Overview
++++++++
In this lab you will be creating a Linux MultiVM Blueprint and deploy it as an application. The application you are going to define is the FiestaApp. This simple application consists out of a Webserver and a mariaDB Database server.

Build the Linux MultiVM Blueprint
+++++++++++++++++++++++++++++++++

#. In **Prism Central**, select :fa:`bars` **> Services > Calm**

   .. figure:: images/1.png
      :align: center

#. Click |blueprints| 

#. Click the **+ Create Blueprint -> Multi VM/Pod Blueprint**

   .. figure:: images/2.png
      :align: center

#. Provide the following in the fields:

   - **Name** - *Initials*-multivm-Linux
   - **Description** - Optional
   - **Project** - *Initials*-Project

   .. figure:: images/3.png
      :align: center

#. Click the **Proceed** button

#. In the left hand side bottom corner click on the :fa:`plus` icon, right to the **Services** text, twice to add two "services".

   .. figure:: images/4.png
      :align: center

#. This will produce two services on the canvas in the middle of the screen.

Database tier - Define the VM
*****************************

#. Select **Service1** by clicking it in the left hand bottom corner under **Services**
   
   .. figure:: images/5.png
      :align: center

#. In the right hand side navigator, Set the Service name to **Database_Tier**

#. Click, in the right hand side navigator, on **VM**

#. Provide the following in the fields that are shown:

   - **Name** - Database_VM
   - **Account** - NTNX_LOCAL_AZ
   - **Operating System** - Linux
   - **Under VM Configuration**

     - **VM Name** - @@{initials}@@-mariadb-vm
     - **vCPUs** - 1
     - **Cores per vCPU** - 1
     - **Memory (GB)** - 2
     - **Guest Customization** - enabled and pasted the below code
       
       .. code-block:: bash

            #cloud-config
            preserve_hostname: false
            hostname: @@{initials}@@-mariadb-vm
            ssh_pwauth: true
            users:
                - name: centos
                  chpasswd: { expire: False }
                  lock-passwd: false
                  plain_text_passwd: 'nutanix/4u'
                  sudo: ['ALL=(ALL) NOPASSWD:ALL']
            runcmd:
                - setenforce 0
                - sed -i s/^SELINUX=.*$/SELINUX=disabled/ /etc/selinux/config
                - systemctl disable firewalld
                - systemctl stop firewalld
  
       .. note::
         Take note of the **@@{initials}@@** text.  In Calm the "@@{" and "}@@" characters represent a macro.  At runtime, Calm will automatically "patch" or substitute in the proper value(s) when it encounters a macro.  A macro could represent a system defined value, a VM property, or a runtime variable.  Later in this lab we'll create a runtime variables.
         For a full overview off built-in macros that Calm supports look at https://portal.nutanix.com/page/documents/details?targetId=Nutanix-Calm-Admin-Operations-Guide-v3_2_2:nuc-components-macros-overview-c.html 

     - **Disk** - Click the :fa:`plus` icon

       - **Device Type** - Disk
       - **Device Bus** - SCSI
       - **Operation** - Clone from Image Service
       - **Image** - CentOS7.qcow2

       .. figure:: images/6.png
          :align: center
     
     - **NETWORK ADAPTERS (NICS)** - Click the :fa:`plus` icon

       - **NIC 1** - Primary
       - **Provate IP** - Dynamic

       .. figure:: images/7.png
          :align: center

     - **CONNECTION**

       - **Check log-in upon create** - enabled
       - **Credential** - Add New Credential

         - **Credential Name** - root
         - **Username** - root
         - **Secret Type** - Password
         - **Password** - nutanix/4u

         Click the **Done** button

       - **Address** - NIC 1
       - **Connection Type** - ssh
       - Leave the rest default

       .. figure:: images/8.png
          :align: center

Database tier - Define the packages
***********************************

#. On the top of the right hand side navigation, click **Package**

#. Change **Package Name** to **Install Database**

#. Click **Configure install**

#. On the Canvas where you have your services, click the **+ Task** button to create a new Task

   .. figure:: images/9.png
      :align: center

#. Provide the following for the task

   - **Task Name** - Update CentOS
   - **Type** - Execute
   - **Script Type** - Shell
   - **Endpoint** - leave blank
   - **Credential** - Select your created root credential
   - **Script** - Copy the below lines into the text area

     .. code-block:: bash
        
         #!/bin/bash
         yum update -y
         yum upgrade -y

   .. figure:: images/10.png
        :align: center

#. As we are needing the task also for the other Service, saving it into the Library will save us some time.

#. Click the **Publish To Library** button

#. Change the **Name** to *Update CentOS* and leave the rest default and hit the **Publish button**

   .. figure:: images/11.png
      :align: center

#. Click **+ Task** again for the next task

#. Provide the following for the task

   - **Task Name** - Install MariaDB
   - **Type** - Execute
   - **Script Type** - Shell
   - **Endpoint** - leave blank
   - **Credential** - Select your created root credential
   - **Script** - Copy the below lines into the text area

     .. code-block:: bash
        
         #!/bin/bash
         yum install -y mariadb mariadb-server git
         yum install zip unzip jq -y 

#. Click **+ Task** again for the next task

#. Provide the following for the task

   - **Task Name** - Initial configuration Database
   - **Type** - Execute
   - **Script Type** - Shell
   - **Endpoint** - leave blank
   - **Credential** - Select your created root credential
   - **Script** - Copy the below lines into the text area

     .. code-block:: bash
        
         #!/bin/bash
         # Get the MariaDB initial install done
         /usr/bin/mysql_install_db --user=mysql --ldata=/var/lib/mysql
         mkdir /run/mysqld
         chown mysql:mysql /run/mysqld
         
         # Making sure the MariaDB starts at boot time
         systemctl enable mariadb
         systemctl start mariadb

#. Click **+ Task** again for the next task

#. Provide the following for the task

   - **Task Name** - Initial configuration Database
   - **Type** - Execute
   - **Script Type** - Shell
   - **Endpoint** - leave blank
   - **Credential** - Select your created root credential
   - **Script** - Copy the below lines into the text area

     .. code-block:: bash
        
         #!/bin/bash
         # Get the MariaDB initial install done
         /usr/bin/mysql_install_db --user=mysql --ldata=/var/lib/mysql
         mkdir /run/mysqld
         chown mysql:mysql /run/mysqld
         
         # Making sure the MariaDB starts at boot time
         systemctl enable mariadb
         systemctl start mariadb

#. Click **+ Task** again for the next task

#. Provide the following for the task

   - **Task Name** - Inject FiestaDB data in Database
   - **Type** - Execute
   - **Script Type** - Shell
   - **Endpoint** - leave blank
   - **Credential** - Select your created root credential
   - **Script** - Copy the below lines into the text area
   
     .. code-block:: bash
         
            #!/bin/bash
            # Get the original data from the github
            mkdir /code
            git clone https://github.com/sharonpamela/Fiesta /code/Fiesta

            # Inject the data into the MariaDB
            mysql < /code/Fiesta/seeders/FiestaDB-mySQL.sql

            # Getting the correct rights for the fiesta user based on the variables we need.
            echo "grant all privileges on FiestaDB.* to fiesta@'%' identified by 'fiesta';" | sudo mysql
            echo "grant all privileges on FiestaDB.* to fiesta@localhost identified by 'fiesta';" | sudo mysql

            # Changing my.cnf so MariaDB is running Binary Logs
            sed -i 's/socket=\/var\/lib\/mysql\/mysql.sock/socket=\/var\/lib\/mysql\/mysql.sock\nlog_bin=\/var\/log\/mariadb\/mariadb-bin.log/g' /etc/my.cnf
            systemctl daemon-reload
            systemctl restart mariadb

            # Setting the Root password for mysql
            mysqladmin --user=root password 'nutanix/4u'

#. Your MariaDB_VM service should look something like the below screenshot

   .. figure:: images/12.png
      :align: center 

Webserver tier - Define the VM
*****************************

#. Select **Service2** by clicking it in the left hand bottom corner under **Services**
   
#. In the right hand side navigator, Set the Service name to **Webserver_Tier**

#. Click, in the right hand side navigator, on **VM**

#. Provide the following in the fields that are shown:

   - **Name** - Webserver_VM
   - **Account** - NTNX_LOCAL_AZ
   - **Operating System** - Linux
   - **Under VM Configuration**

     - **VM Name** - @@{initials}@@-webserver-vm
     - **vCPUs** - 1
     - **Cores per vCPU** - 1
     - **Memory (GB)** - 2
     - **Guest Customization** - enabled and pasted the below code
       
       .. code-block:: bash

            #cloud-config
            preserve_hostname: false
            hostname: @@{initials}@@-webserver-vm
            ssh_pwauth: true
            users:
                - name: centos
                  chpasswd: { expire: False }
                  lock-passwd: false
                  plain_text_passwd: 'nutanix/4u'
                  sudo: ['ALL=(ALL) NOPASSWD:ALL']
            runcmd:
                - setenforce 0
                - sed -i s/^SELINUX=.*$/SELINUX=disabled/ /etc/selinux/config
                - systemctl disable firewalld
                - systemctl stop firewalld
  
     - **Disk** - Click the :fa:`plus` icon

       - **Device Type** - Disk
       - **Device Bus** - SCSI
       - **Operation** - Clone from Image Service
       - **Image** - CentOS7.qcow2
     
     - **NETWORK ADAPTERS (NICS)** - Click the :fa:`plus` icon

       - **NIC 1** - Primary
       - **Provate IP** - Dynamic

     - **CONNECTION**

       - **Check log-in upon create** - enabled
       - **Credential** - Select your earlier created **root** credentials
       - **Address** - NIC 1
       - **Connection Type** - ssh
       - Leave the rest default

Webserver tier - Define the packages
***********************************

#. On the top of the right hand side navigation, click **Package**

#. Change **Package Name** to **Install Webserver**

#. Click **Configure install**

#. On the Canvas where you have your services, click the **+ Task** button to create a new Task

#. Provide the following for the task

   - **Task Name** - Update CentOS
   - **Type** - Execute
   - Click the **Browse Library** button

     - Select the **Update CentOS** package
     - Click **Select**

       .. figure:: images/13.png
          :align: center
      
     - Click **Copy** to have all information copied to your task
      
       .. figure:: images/14.png
          :align: center

       .. note::
         The Library can be used for the packages that are being used often in packages and saves a lot of typing.

#. Click **+ Task** again for the next task

#. Provide the following for the task

   - **Task Name** - Install MariaDB
   - **Type** - Execute
   - **Script Type** - Shell
   - **Endpoint** - leave blank
   - **Credential** - Select your created root credential
   - **Script** - Copy the below lines into the text area

     .. code-block:: bash
        
         #!/bin/bash
         yum install -y mariadb mariadb-server git
         yum install zip unzip jq -y 

#. Click **+ Task** again for the next task

#. Provide the following for the task

   - **Task Name** - Install npm
   - **Type** - Execute
   - **Script Type** - Shell
   - **Endpoint** - leave blank
   - **Credential** - Select your created root credential
   - **Script** - Copy the below lines into the text area

     .. code-block:: bash
        
         #!/bin/bash
         # Install the needed packages
         yum install -y mysql mysql-client git gcc curl wget vim gcc-c++
         
         # Install node
         curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
         yum install -y nodejs
         node --version
         
         # Clone Repo
         git clone https://github.com/sharonpamela/Fiesta.git /code/Fiesta
         cd /code/Fiesta
         npm install
         cd /code/Fiesta/client
         npm install
         npm run build
         npm install nodemon concurrently
         

#. Click **+ Task** again for the next task

#. Provide the following for the task

   - **Task Name** - Start the Fiesta App
   - **Type** - Execute
   - **Script Type** - Shell
   - **Endpoint** - leave blank
   - **Credential** - Select your created root credential
   - **Script** - Copy the below lines into the text area

     .. code-block:: bash
        
         #!/bin/bash
         # Change the code so it works in the container
         sed -i 's/REPLACE_DB_NAME/FiestaDB/g' /code/Fiesta/config/config.js
         sed -i "s/REPLACE_DB_HOST_ADDRESS/@@{Database_Tier.address}@@/g" /code/Fiesta/config/config.js
         sed -i "s/REPLACE_DB_DIALECT/mysql/g" /code/Fiesta/config/config.js
         sed -i "s/REPLACE_DB_USER_NAME/fiesta/g" /code/Fiesta/config/config.js
         sed -i "s/REPLACE_DB_PASSWORD/fiesta/g" /code/Fiesta/config/config.js
         sed -i 's/REPLACE_DB_DOMAIN_NAME/\/\/DB_DOMAIN_NAME/g' /code/Fiesta/config/config.js     
         
         # Create the unit file
         echo '[Service]
         
         ExecStart=/usr/bin/node /code/Fiesta/index.js
         Restart=always
         RestartSec=2s
         
         StandardOutput=syslog
         StandardError=syslog
         
         SyslogIdentifier=fiesta
         
         User=root
         Group=root
         
         Environment=NODE_ENV=production PORT=5001
         
         [Install]
         WantedBy=multi-user.target' | sudo tee /etc/systemd/system/fiesta.service
         
         # Reload daemons and start service
         sudo systemctl daemon-reload
         sudo systemctl start fiesta
         sudo systemctl enable fiesta
         sudo systemctl status fiesta -l


     .. note::
         The Macro **@@(Database_Tier.address}@@** is a special macro that can be used in Calm. This macro is providing the IP address(es) of the VM(s) that are in the Service. In this case it will provide only one IP address as the Service only has one VM. You will see later in this module, whwre the Webserver_Tier service will consist out of multiple VMs, a same macro to configure another service that we will add.

#. Your Webserver_VM service should look something like the below screenshot

   .. figure:: images/15.png
      :align: center 


#. **Save** the blueprint. You will see it is saved, but with errors. 

   .. figure:: images/16.png
      :align: center 

Using variables in Blueprints
*****************************

To solve the errors that are being shown, variables need to be defined. 

#. Click in the left hand bottom corner **Default** under *Application Profile*

   .. figure:: images/17.png
      :align: center

#. In the right hand navigation, click the :fa:`plus` icon to add a variable

#. Fill out the following

   - **Name** - initials
   - **Data Type** - String
   - **Value** - Leave blank. This is the default value this variable should have.
   - **Secret** - Leave unchecked. This is, for instance, used for passwords. If checked it will only show astriks.
   - Click the Running Man icon (|runningman|) so the variable can be changed at **Launch** times

#. Click the **Save**

#. There should not be any errors now and the blueprint has been saved

Deploy the blueprint
********************

Now that we have the Blueprint ready, it's time to deploy it.

#. Click the **Launch** button

#. Provide the following:

   - **Application Name** - xyz-FiestaApp
   - Leave the rest default, except the **initials** field
   - **initials** - Your initials, or username

   .. figure:: images/18.png
      :align: center

#. Click the **Deploy** button

#. This will open the Application screen

#. Click on the **Manage** tab

#. Click on the :fa:`eye` icon to see the progress and steps.

   .. figure:: images/19.png
      :align: center

   .. note::
      As the screen shows the steps that will be run, dependencies are also show. They are represented by the organge lines and created by Calm automatically. An example of this is the orange line that flows from **Database_Tier Start** towards **...r - Package Install** of the Webserver_VM. That dependencies is there due to the fact that one of the task has the macro **@@{Database_Tier.address}@@** in it.
      Before Calm can patch that variable, the service needs to be started first so Calm knows the IP address(es) of the service.

#. Follow the deployment till it has the **RUNNING** state. The total deployment takes approx. 10 minutes

   .. note::
      To see the individual steps, click on the step you want to see the details and you can follow the step, including the output.

   .. figure:: images/20.png
      :align: center

Checking the deployment
***********************

#. Click the |applications| icon and click on your Application

#. Click on **Services** and click your **Webserver**

#. On the right hand side you will see the IP address

   .. figure:: images/21.png
      :align: center

#. Copy the IP address and open a new browser

#. Past the IP address and add port 3000 (*example: http:10.42.77.56:3000*)

#. This is showing the FiestaApp

   .. figure:: images/22.png
      :align: center

#. Your application is running
      

This concludes the module. In a later module you are going to add some steps to make the application more scalable.

Take aways
++++++++++

- Calm is very well suited to deploy applications that are build from multiple VMs in a consistent manner
- Macros and variables can be used to have dynamical settings during the deployment of the application
- Possible dependencies will be dynamically detected by Calm and followed in the deployment of the application

.. |proj-icon| image:: ../images/projects_icon.png
.. |mktmgr-icon| image:: ../images/marketplacemanager_icon.png
.. |mkt-icon| image:: ../images/marketplace_icon.png
.. |bp-icon| image:: ../images/blueprints_icon.png
.. |blueprints| image:: ../images/blueprints.png
.. |applications| image:: ../images/blueprints.png
.. |projects| image:: ../images/projects.png
.. |runbooks| image:: ../images/runbooks.png
.. |runningman| image:: ../images/running_man.png