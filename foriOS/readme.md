Good Dynamics Contributor Code for iOS
======================================
To use the contributor applications and code for iOS with Apple Xcode for the
first time, the following steps can be followed.

1.  Download and unzip the repository, or use git or some other means to obtain
    the files.
2.  Open the `.xcodeproj` file for the required sample.
3.  Open the target, and navigate to the Copy Bundle Resources list in the Build
    Phases tab.
4.  Remove the existing `GDAssets.bundle` reference and replace with a reference
    to your own. Link the resources in the usual way; do not copy them.

The contributor applications for iOS are now ready to use. You can run them on a
simulator or real device.

For general details about Good Dynamics contributor code see the readme file in
the parent repository.