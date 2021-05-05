.. _calm_dsl:

-----------------------------------------
Calm: DSL
-----------------------------------------

Overview
++++++++

To start the DSL lab we have provided a DevWorkStation blueprint to quickly get you started. The included DevWorkstation.json builds a CentOS VM with all the necessary tools.  This blueprint can be launched directly from Calm, but we recommend publishing it to the Calm Marketpkace for Self Service.

Add Blueprint to Marketplace
++++++++++++++++++++++++++++

To get started download the following Blueprint JSON and Img file.

#. `Download the DevWorkStation Blueprint by right-clicking here <https://raw.githubusercontent.com/nutanixworkshops/CalmIaaS_Bootcamp/master/calm_dsl/DevWorkstation.json>`_.

#. `Download the DevWorkStation Blueprint Icon for the Market Place by right-clicking here <https://raw.githubusercontent.com/nutanixworkshops/CalmIaaS_Bootcamp/master/calm_dsl/images/MPDevWorkstation.png>`_.

Upload Blueprint to Calm
........................

#. From **Prism Central > Calm**, select **Blueprints** from the lefthand menu and click **Upload Blueprint**.

#. Select **DevWorkStation.json**

#. Update the **Blueprint Name** to *initials*\ **_DevWorkStation**. Even across different projects, Calm Blueprint names must be unique.

#. Select your Calm project and click **Upload**.

Publishing the Blueprint
........................

#. Select |blueprints| **Blueprints** in the left hand toolbar to view and manage Calm blueprints.

#. Click your *intials*\ **-CentOS-IaaS** blueprint.

#. Assign the **Primary** Network to the NIC on the **VM1** service.

#. Update the Credential for **local**, and click **Save** > then **Back**

    - **Password** - Nutanix/4u

#. Click the **Publish** button, and enter the following:

   - **Name** - *initials*\ _DevWorkStation
   - **Publish with secrets** - off
   - **Initial Version** - 1.0.0
   - **Description** - (Optional)
   - **Change Image** - Upload the **MPDevWorkstation.png** you downloaded earlier

#. Click **Submit for Approval**.

Approving Blueprints
....................

#. Select |mktmgr-icon| **Marketplace Manager** in the left hand toolbar to view and manage Marketplace Blueprints.

#. You will see the list of Marketplace blueprints, and their versions listed. Select **Approval Pending** at the top of the page.

#. Click your *intials*\ **_DevWorkStation** blueprint.

#. Click **Approve**.

Deploy Dev Workstation from Marketplace
+++++++++++++++++++++++++++++++++++++++

Launch DevWorkstation from Calm Marketplace
...........................................

#. Select |mktmgr-icon| **Marketplace Manager** in the left hand toolbar to view and manage Marketplace Blueprints.

#. Enter your *initials* in the search bar, and you should see your blueprint listed.

#. Select your *intials*\ **_DevWorkStation** blueprint, and click **Launch** from the Marketplace.

#. Select your *initials*\ **-Project** from the **Projects** dropdown.

#. Enter the following for **Profile Configuration**:

    - **Name of the Application** - *intials*\ **_DevWorkStation**
    - **Prism Central IP** - *Provided Prism Central IP*
    - **Prism Central Password** - *HPOC Password*
    - **Calm Project** - *initials*\ **-Project**

    .. figure:: images/DevLaunch.png

#. Enter the following for **Credentials**:

    - **Username** - centos
    - **Password** - Nutanix/4u

    .. figure:: images/Creds.png

#. Click **Create**

#. While waiting review the audit log to see packages being deployed.

  .. note::

    The blueprint automatically installs several utilities along with Calm DSL

#. Once the application is **Running** make note of the IP Address for the next lab.

   .. note::

     The IP address of the DevWorkstation is listed under the application overview.

   .. figure:: images/IPaddress.png

Start Using Calm DSL
++++++++++++++++++++

Start the virtual environment and connect to Prism Central
..........................................................

#. Open a Console session or SSH to your *intials*\ **_DevWorkStation**

#. Change Directories by running ```cd calm-dsl``` from the home directory

#. Run ```source venv/bin/activate``` to switch to the virtual environment. This will enable the virtual environment for Calm DSL

   .. note::

     This has already been done through the blueprint launch, but once you SSH into the DevWorkstation you can setup the connection to Prism Central by running ```calm init dsl```

#. Verify the current config settings by running ```calm show config```

    .. figure:: images/Config.png

List the current blueprints in Calm
...................................

#. Run ```calm get bps``` and we see all the blueprints in Calm with their UUID, description, application count, project, and state

    .. figure:: images/getbps.png

#. Run ```calm get bps -q``` to display quiet output with only the BP names

    .. figure:: images/calmgetbpsq.png

Review and Modify a Blueprint
.............................

Now lets review a python based blueprint, and make a modification.

#. Change to the **HelloBlueprint** directory by running ```cd HelloBlueprint``` and run ```ls``` to list the contents of the directory.

    .. note::

      This directory and it's contents were automatically created during the blueprint launch.
      As part of the DevWorkstation blueprint launch we ran ```calm init bp``` which creates a sample blueprint configured to the connected Calm instance.

#. There is a file called "blueprint.py" which is a python version of a blueprint

#. There is a "scripts" directory. This is where the bash/powershell/python scripts are stored that are referenced within the blueprint

    .. figure:: images/hellols.png

Modify blueprint.py
===================

#. Run ```vi blueprint.py``` to edit the python file.

#. Review the blueprint for familiar constructs.  To skip directly to a line enter ```:<linenumber>```

    - Credentials (line 54-60)

    - OS Image (line 62-66)

    - Under class HelloPackage(Package) you will see references to the pkg\_install\_task.sh script in the scripts directory (line 139)

    - Basic VM spec information (vCPU/memory/disks/nics) (line 153-159)

    - Guest Customization contains cloud-init (line 161-171)

#. In the blueprint.py modify the number of vCPU

    - Change the vCPU from 2 to 4 (line 154)

      .. figure:: images/vcpu.png

#. Add a unique VM name using a macro (line 185)

    - ```provider_spec.name = "<Initials>-@@{calm_unique}@@"```

      .. figure:: images/vmname.png

#. Write/quit ```:wq``` the .py blueprint file to save and close

Modify pkg\_install\_task.sh
============================

#. Change to the scripts directory and run ```ls```. We will see 2 scripts that are being referenced inside blueprint.py

#. Run ```cat pkg_install_task.sh``` to view the current contents of the install script.  What does the script do?

    .. figure:: images/more1.png

#. Run ```curl -Sks https://raw.githubusercontent.com/nutanixworkshops/prep/master/nginx > pkg_install_task.sh``` to replace the existing install script

#. Run ```cat pkg_install_task.sh``` to view the changed script.  What does the script do now?

    .. figure:: images/more2.png

Push The Modified Blueprint To Calm
+++++++++++++++++++++++++++++++++++

#. Return to the "HelloBlueprint" directory

#. Run ```calm create bp --file blueprint.py --name FromDSL-<Initials>```

    .. note::

      This converts the .py file to json and pushes it to Calm

    .. figure:: images/syncbp.png

#. **Optional:** Run ```calm compile bp -f blueprint.py``` to view the python blueprint in json format from DSL

#. Verify your new blueprint by running ```calm get bps -q | grep FromDSL-<Initials>```

    .. figure:: images/verifygrep.png

Launch The Blueprint Into An Application
++++++++++++++++++++++++++++++++++++++++

#. Run ```calm get apps``` to verify all the current applications before launching your new app

#. We can also run ```calm get apps -q``` to quiet the details like we did with blueprints earlier

Launch Your Newly Uploaded Blueprint
....................................

#. Run ```calm launch bp FromDSL-<Initials> --app_name AppFromDSL-<Initials> -i```

    .. figure:: images/launchbp.png

#. Run ```calm describe app AppFromDSL-<Initials>``` to see the application summary

#. Once the app status changes to "running" we will have a nginx server deployed from Calm DSL!

    .. figure:: images/describe.png

#. Now we need to get the VM/Application IP address.  To get this we will pull the "address" from the application json output using jq by running the following:
```calm describe app AppFromDSL-<Initials> --out json | jq '.status.resources.deployment_list[].substrate_configuration.element_list[].address'```

    .. figure:: images/jqout.png

#. Enter the IP in a web browser and this will take you to the nginx **"Welcome to DSL"** web page

    .. figure:: images/welcome2.png

Log into Prism Central to Verify
.................................

#. Check the blueprint created from DSL

#. Check the application launched from DSL

Looking Back At What We Did
+++++++++++++++++++++++++++

As you went through this lab not only did you use Calm DSL, but you also used several native Linux tools such as vi, curl, grep, cat, pipe, and redirects.  Calm DSL allows extended felxibily by combining it with these powerful tools.

Think about how you can add git to this workflow to track changes or modify blueprints with sed

Optional: Getting started with git
++++++++++++++++++++++++++++++++++

Speaking of git lets contiue on and push our blueprint to git.  We will need a github.com account before you can get started

#. Logon to git and create new repo "dsl-blueprints"

#. From the "HelloBlueprint" directory run:

    - ```echo "# dsl-blueprints" >> README.md``` to create a README

    - ```git init``` initialize git in your working directory

    - ```git config --global user.email "<youremail>@example.com"```  identify yourself

    - ```git config --global user.name "<GitUserName>"``` identify yourself

    - ```git config --global color.ui true``` because colors are cool

    - ```git remote add origin https://github.com/<GitUserName>/dsl-blueprints.git``` to add your new github repo

    - ```git remote -v``` to verify your remote origin

    .. figure:: images/gitsetup.png

    - ```git status``` to see whats being tracked

    - ```git add --all``` adds all files in the current directory into staging

    - ```git status``` to see the change after adding the files

    .. figure:: images/gitstatus.png

#. From the above output we can see there are some keys, so lets remove those since this is being pushed to a public repo.

#. Run the following to remove the keys ```git rm --cached .local -r```

#. Run ```git status``` to verify they were removed

    .. figure:: images/gitremove.png

#. Run ```git commit -m "My DSL blueprints"``` to commit the files

    .. figure:: images/gitcommit.png

#. Run ```git push -u origin master``` to push to git.  You will be prompted for your user/pass unless you setup key access to github

    .. figure:: images/gitpush.png

#. Check your github repo and verify your files were pushed.

#. Now that your blueprints exists in both Calm and github lets increase the memory to 8 in the blueprint by running:

        - ```sed -i 's/memory = 4/memory = 8/g' blueprint.py``` use the linux sed tool to change the memory config

        - ```git add blueprint.py```

        - ```git commit -m "change memory"```

        - ```git push -u origin master```

#. Back in github there is a new verion under the "history" of blueprint.py with the changed memory

    .. figure:: images/diff.png

Takeaways
+++++++++

You have now edited a blueprint, sent it to Calm, launched an application, and used version control all from the command line using Calm-dsl.

.. |proj-icon| image:: ../images/projects_icon.png
.. |mktmgr-icon| image:: ../images/marketplacemanager_icon.png
.. |mkt-icon| image:: ../images/marketplace_icon.png
.. |bp-icon| image:: ../images/blueprints_icon.png
.. |blueprints| image:: ../images/blueprints.png
.. |applications| image:: ../images/blueprints.png
.. |projects| image:: ../images/projects.png
