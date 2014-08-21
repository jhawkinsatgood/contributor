Good Dynamics Contributor Code for iOS
======================================
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

For general details about Good Dynamics contributor code see the readme file in
the parent repository.
