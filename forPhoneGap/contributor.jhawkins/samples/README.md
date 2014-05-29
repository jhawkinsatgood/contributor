To create sample application for the Good Dynamics PhoneGap Plugin:

1. Download and unzip the Good Dynamics PhoneGap Plugin. Make a note of the path of the directory in which 
   you extracted it.
1. Apply the fixes for known issues to the two gdEnable scripts and template.
1. Download and unzip or synchronise this repository.
1. cd to this samples/ directory in your copy.
1. Run the build.sh script. Specify the directory in which you extracted the Plugin download as the command line
   parameter. Like this:

           ./build.sh /path/to/plugindownload

1. This will create the sample application (only one at time of writing) in a sub-directory.

It's a good idea to edit the top of the build.sh script. See the comments there for what to populate.

The build.sh script can also be used to resynchronise the platform www/ files from the project www/ files. Run it 
from this samples/ directory, or cd into the project directory and run it as ../build.sh
