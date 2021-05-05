.. _labsetup:

----------------------
Calm Lab Setup
----------------------




Configuring a Project
+++++++++++++++++++++

In this lab you will leverage multiple pre-built Calm Blueprints to provision your applications...

#. In **Prism Central**, select :fa:`bars` **> Services > Calm**.\

#. Select **Projects** from the lefthand menu and click **+ Create Project**.

   .. figure:: images/2.png

#. Fill out the following fields:

   - **Project Name** - *Initials*\ -Project
   - Under **Users, Groups, and Roles**, select **+ User**
      - **Name** - Administrators
      - **Role** - Project Admin
      - **Action** - Save
   - Under **Infrastructure**, select **Select Provider > Nutanix**
   - Click **Select Clusters & Subnets**
   - Select *Your Assigned Cluster*
   - Under **Subnets**, select **Primary**, **Secondary**, and click **Confirm**
   - Mark **Primary** as the default network by clicking the :fa:`star`

   .. figure:: images/3.png

#. Click **Save & Configure Environment**.

.. note::

  After it is done saving, you will be in the **Environment** section of the Project. We will configure this later in the Bootcamp. Disregard this section for now, you do not have fill in anything at this time.


..  Deploying a Windows Tools VM
  ++++++++++++++++++++++++++++

  Some exercises in this track will depend on leveraging the Windows Tools VM. Follow the below steps to provision your personal VM from a disk image.

  #. In **Prism Central**, select :fa:`bars` **> Virtual Infrastructure > VMs**.

  #. Click **+ Create VM**.

  #. Fill out the following fields to complete the user VM request:

     - **Name** - *Initials*\ -WinToolsVM
     - **Description** - Manually deployed Tools VM
     - **vCPU(s)** - 2
     - **Number of Cores per vCPU** - 1
     - **Memory** - 4 GiB

     - Select **+ Add New Disk**
        - **Type** - DISK
        - **Operation** - Clone from Image Service
        - **Image** - WinToolsVM.qcow2
        - Select **Add**

     - Select **Add New NIC**
        - **VLAN Name** - Secondary
        - Select **Add**

  #. Click **Save** to create the VM.

  #. Power on your *Initials*\ **-WinToolsVM**.
