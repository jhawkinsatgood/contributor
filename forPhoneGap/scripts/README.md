Contributor Fixes
=================
This directory contains contributed fixes to the scripts and templates in the GD
PhoneGap Plugin.

The fixes are for version 1.8.31 of the plugin.

Installation
------------
The fixes can be installed after the plugin has been installed. Here is the
recommended procedure. __You will need to know the GD PhoneGap Plugin
installation directory, i.e. the location where the plugin download was
uncompressed.__

1.  Copy the fixed scripts into the same directory as the originals.

    The fixed scripts have the same names as the originals with a FIXED prefix.
    -   Copy `Android/FIXEDgdEnableApp.sh` from here to the
        `Android/GDCordova3x/` sub-directory of the plugin installation
        directory.
    -   Copy `iOS/FIXEDgdEnableApp.sh` from here to the
        `iOS/SampleApplications/UpdateApp-Cordova3x/` sub-directory of the
        plugin installation directory.
2.  Ensure that the copies of the FIXED scripts are executable by you.
3.  Make a safe copy of the project template for iOS.

    The easiest way to do the following may be in a terminal window.
    
    1.  Open the directory that contains the project template. This will be in
        the `__TemplateAppName__/__TemplateAppName__.xcodeproj/` sub-directory
        of the directory that was the destination of the FIXED script mentioned
        above.
    2.  Copy the `project.pbxproj` file to a safe name, such as
        `ORIGINALproject.pbxproj`.
    
4.  Ensure that the original `project.pbxproj` file is writable by you.
5.  Replace the original project template with the fixed project template.

    -   Copy `iOS/project.pbxproj` from here over the original `project.pbxproj`.

There is no need to fix the project templates for Android.

Usage
-----
Run the FIXED scripts instead of the originals.
