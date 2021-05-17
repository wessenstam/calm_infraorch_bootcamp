.. _calm_runbook_windows:

------------------------------------------------
Calm: Create Era snapshot MSSQL Database Runbook
------------------------------------------------

*The estimated time to complete this lab is 20 minutes.*

Overview
++++++++

In this lab, we will create a Calm Runbook for Creating a snapshot of the MSSQL Database in Era.

Creating A Runbook
++++++++++++++++++

#. Select **Runbooks** in the left hand toolbarto view and manage Runbooks.

#. Click **Create** Runbooks, or **Create your first Runbook** if there are no Runbooks available.
 
   .. figure:: images/1.png

#. Fill out the following fields:

   - **Name** - *Initials*\ **-Create MSSQL Snapshot**
   - **Description** - Something descriptive of your choice
   - **Project** - *Initials*\ **-Project**
   - **Endpoints** - Leave Empty

   .. figure:: images/2.png


#. Click **Proceed**

#. Click the **+ Add Task** Button

#. Provide the following

   - **Task Name** - Database Registered?
   - **Type** - Decision
   - **Script Type** - Powershell
   - **Endpoint (Optional)** - Add New Endpoint where

     - **Name** - *Initials*\ -MSSQL Server
     - **Type** - Windows
     - **Target Type** - VMs
     - **Account** - NTNX_LOCAL_AZ
     - **VM** - Your MSSQL Server
     - **Connection Type** - Powershell
     - Leave the rest default
     - **Credential** - Use the following

       - **Username** - Administrator
       - **Secret Type** - Password
       - **Password** - Nutanix/4u
       - Click the **Save** Button
   
   - **Credential (optional)** - Add New Credential where

     - **Credential Name** - Administrator
     - **Username** - Administrator
     - **Secret Type** - Password
     - **Password** - Nutanix/4u
     - Click the **Save** Button
   
   - **Script** - Copy and paste the below

     .. code-block:: Powershell
      
        









Takeaways
+++++++++


.. |proj-icon| image:: ../images/projects_icon.png
.. |mktmgr-icon| image:: ../images/marketplacemanager_icon.png
.. |mkt-icon| image:: ../images/marketplace_icon.png
.. |bp-icon| image:: ../images/blueprints_icon.png
.. |blueprints| image:: ../images/blueprints.png
.. |applications| image:: ../images/blueprints.png
.. |projects| image:: ../images/projects.png
