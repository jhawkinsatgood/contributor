Good Dynamics Contributor Code
==============================
This repository contains Good Dynamics&trade; contributor sample code. Good
Dynamics (GD) is the Good Technology&trade; platform for secure mobile
application development. To make use of the sample code in this repository you
will need the following.

- An account on the [Good Developer Network](https://developer.good.com).
- To have installed the GD SDK for Android or the GD SDK for iOS, or both.
- A deployment of GD, i.e. Good Control and Good Proxy servers.

Directory Structure
-------------------
There are three sub-directories in the repository: `forAndroid/`, `foriOS/`, and
`forPhoneGap/`.

Under each of the directories for Android and iOS there are another couple of
sub-directories:  
`src/` which contains common code.  
`samples/` which contains sample applications that use the common code.

Under the directory for PhoneGap there are three sub-directories:  
`src/` which contains common code and a copy of the sample application code.  
`samples/` which contains a script that can be used to create the sample
application.  
`scripts/` which contains handy copies of the GD enabling scripts from the GD
download for PhoneGap with fixes by contributors to this repository.

At the moment there is only one contributor sample application: AppKinetics
Workflow.

Using the sample applications for Android
-----------------------------------------
To use the sample applications and code for Android with ADT or Eclipse for the
first time, the following steps can be followed.

1.  Download and unzip the repository, or use git or some other means to obtain
    the files.
2.  Create new Android projects from the sub-directories of the `samples/`
    directory and from the `src/` directory.
3.  Change the library reference of the GD Runtime in both of these projects to
    be your GD Runtime project. This is the project that you would have created
    when you installed the GD SDK for Android. Note that the sample applications
    require and already have a reference to the `src/` project, which is marked
    as a library.

The samples for Android are now ready to use. You can run the AppKinetics
Workflow sample application on an emulator or real device.

Using the sample applications for iOS
-------------------------------------
To use the sample applications and code for iOS with Apple Xcode for the first
time, the following steps can be followed.

1.  Download and unzip the repository, or use git or some other means to obtain
    the files.
2.  Open the `.xcodeproj` file for the required sample. (There is currently only
    one.)
3.  Open the target, and navigate to the Copy Bundle Resources list in the Build
    Phases tab.
4.  Remove the existing `GDAssets.bundle` reference and replace with a reference
    to your own. Link the resources in the usual way; do not copy them.

The samples for iOS are now ready to use. You can run the AppKinetics Workflow
sample application on a simulator or real device.

Using the sample applications for PhoneGap
------------------------------------------
To use the sample applications and code for PhoneGap, see the README file in the
samples sub-directory.