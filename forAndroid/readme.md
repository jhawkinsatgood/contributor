Good Dynamics Contributor Code for Android
==========================================
To use the contributor applications and code for Android with ADT or Eclipse for
the first time, the following steps can be followed.

1.  Download and unzip the repository, or use git or some other means to obtain
    the files.
2.  Create new Android projects from the sub-directories of the `samples/`
    directory and from the `src/` directory.
3.  Change the library reference of the GD Runtime in both of these projects to
    be your GD Runtime project. This is the project that you would have created
    when you installed the GD SDK for Android. Note that the contributor
    applications require and already have a reference to the `src/` project,
    which is marked as a library.

The contributor applications for Android are now ready to use. You can run them
on an emulator or real device.

For general details about Good Dynamics contributor code see the readme file in
the parent repository.

Compatibility
-------------
The contributor code has been tested in the following environment.

Component                       | Version
--------------------------------|--------
Android Developer Tools         | 23.0.2
Android SDK Tools               | 23.0.5
Physical device running Android | 4.4.2
Good Dynamics SDK for Android   | 1.9.1162
Good Control and Good Proxy     | 1.8.42
OS X                            | 10.9.5
