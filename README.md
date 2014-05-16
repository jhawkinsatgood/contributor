# This repository is under construction

This repository contains Good Dynamics&trade; contributor sample code. Good Dynamics (GD) is the Good Technology&trade; platform for secure mobile application development. To make use of the sample code in this repository you will need the following.

- An account on the [Good Developer Network](https://developer.good.com) (GDN).
- To have installed the GD SDK for Android or the GD SDK for iOS, or both.
- A deployment of GD, i.e. Good Control and Good Proxy servers.

#### Directory Structure

There are two sub-directories in the repository: `forAndroid/` and `foriOS/`

Under each of those there are another couple of sub-directories:  
`src/` which contains common code.  
`samples/` which contains sample applications that use the common code.

At the moment there is only one sample application: AppKinetics Workflow

#### Using the sample applications for Android

To use the sample applications and code for Android with ADT or Eclipse for the first time, the following steps can be followed.

1. Download and unzip the repository, or use git or some other means to obtain the files.
1. Create new Android projects from the sub-directories of the `samples/` directory and from the `src/` directory.
1. Change the library reference of the GD Runtime in both of these projects to be your GD Runtime project. This is the project that you would have created when you installed the GD SDK for Android. Note that the sample applications require and already have a reference to the `src/` project, which is marked as a library.

The samples for Android are now ready to use. You can run the AppKinetics Workflow sample application on an emulator or real device.

#### Using the sample applications for iOS

To use the sample applications and code for iOS with Xcode for the first time, the following steps can be followed.

1. Download and unzip the repository, or use git or some other means to obtain the files.
1. Open the `.xcodeproj` file for the required sample. (There is currently only one.)
1. Open the target, and navigate to the Copy Bundle Resources list in the Build Phases tab.
1. Remove the existing `GDAssets.bundle` reference and replace with a reference to your own. Link the resources in the usual way; do not copy them.

The samples for iOS are now ready to use. You can run the AppKinetics Workflow sample application on a simulator or real device.

### More later...
