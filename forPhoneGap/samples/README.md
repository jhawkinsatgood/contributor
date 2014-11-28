Contributor Sample Application for PhoneGap
===========================================
This directory contains a script that creates a contributor sample application
for the Good Dynamics (GD) PhoneGap Plugin.

The script and sample have been tested in the following environment:  
Android Developer Tools: 23.0.0  
Android SDK Tools: 23.0.2  
Physical device running Android: 4.4.2  
Good Dynamics SDK for Android: 1.8.1145  
Xcode: 5.1.1  
iPad device running iOS: 7.1.2  
Good Dynamics SDK for iOS: 1.8.4327  
Cordova: 3.5.0-0.2.4  
Good Dynamics PhoneGap Plugin: 1.8.31  
OS X: 10.9.4

Source Location
---------------
The source for the sample is in the sub-directories of the `src/` sub-directory
of this repository. Part of the source is copied by the script. The rest is a
Cordova plugin.

This seems to be the easiest and cleanest way to publish the code.

Getting the sample application
------------------------------
To create the contributor sample application:

1.  Download and unzip the Good Dynamics PhoneGap Plugin. Make a note of the
    path of the directory in which you extracted it.
2.  Download and unzip or synchronise this repository.
3.  Apply the fixes for known issues to the two gdEnable scripts and template.
    See the `scripts/` sub-directory of this repository for instructions.
4.  Open a terminal window and cd to this `samples/` directory in your copy.
5.  Run the build.sh script. Specify the directory in which you extracted the GD
    PhoneGap Plugin download as the command line parameter. Like this:

        ./build.sh /path/to/plugindownload
    
    Note that the `path/to/plugindownload` directory will have `iOS/` and
    `Android/` sub-directories.

6.  This will create a sub-directory that contains a project for the sample
    application.

It's a good idea to edit the top of the `build.sh` script. See the comments
there for what to populate.

Editing the sample application
------------------------------
The `build.sh` script can also be used to resynchronise the platform `www/`
files from the project `www/` files, in case you want to edit the sample
application.

Run the script from the `samples/` directory, as above, or cd into the project
directory and run it as `../build.sh` with a relative path.

Running the sample application
------------------------------
To run the sample application on either Android or on iOS, open the relevant
platform project in an integrated development environment (IDE) such as ADT or
Apple Xcode.

Known Issues
------------
Sometimes the CDVFile.m file gets removed from the Compile Sources list in the
platform project for iOS. If this happens, you will see build errors relating to
the Cordova File plugin like:

    Undefined symbols for architecture armv7s:
        "_OBJC_CLASS_$_CDVFilesystemURL", referenced from:
            objc-class-ref in CDVLocalFilesystem.o
        "_OBJC_CLASS_$_CDVFile", referenced from:
            objc-class-ref in CDVCapture.o
            objc-class-ref in CDVFileTransfer.o
            (maybe you meant: _OBJC_CLASS_$_CDVFileTransferEntityLengthRequest,
                _OBJC_CLASS_ $_CDVFileTransfer ,
                _OBJC_CLASS_$_CDVFileTransferDelegate )
    ld: symbol(s) not found for architecture armv7s

To fix this issue, add the CDVFile.m back to the Compile Sources in the
application target.

Sometimes other .m files get removed from the Compile Sources list in the
platform project for iOS. You can spot them quite easily by opening the add
sources dialog and looking for any .m files, which have a different icon.
