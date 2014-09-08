#!/bin/sh

# Sample application build and rebuild script

# Copyright (c) 2014 Good Technology Corporation
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Set ORGANISATION_NAME to the name of your organisation. Spaces are not allowed.
export ORGANISATION_NAME=GoodTechnologyExample

# Set GD_PLUGIN_DIR to the path of where you extracted the GD PhoneGap Plugin
# download.
export GD_PLUGIN_DIR=""

# Set either of these to the empty string to disable addition of the platform
export CREATE_ANDROID="yes"
export CREATE_IOS="yes"

# Set GD_ANDROID_DIR to the path to your GD for Android SDK installation, if
# the script cannot work it out.
export GD_ANDROID_DIR=''

export APP_NAME="AppKinetics Workflow"
export APP_ID_PREFIX="com.good.example.contributor.jhawkins"
export APP_ID="${APP_ID_PREFIX}.appkineticsworkflow"

function setAndroidDir()
{
    SAVE_DIR="$PWD"
    WHICH_ANDROID="which android"
    ANDROID_PATH=`$WHICH_ANDROID`
    if test -z "$ANDROID_PATH";
    then
        echo "Could not find android by \"$WHICH_ANDROID\"."
    else
        # Go up to the Android SDK and then down to the default installation
        # sub-directory of GD.
        ANDROID_PATH=`dirname "$ANDROID_PATH"`
        ANDROID_PATH=`dirname "$ANDROID_PATH"`
        ANDROID_PATH="${ANDROID_PATH}/extras/good/dynamics_sdk/libs"
        cd $ANDROID_PATH
        if test -d gd;
        then
            GD_ANDROID_DIR="${PWD}/gd"
        else
            echo \
                "Could not find GD SDK for Android installation under "\
                "\"${ANDROID_PATH}\" directory."
        fi
    fi
    cd $SAVE_DIR
}

function setAndroidRelative()
{
    SAVE_DIR="$PWD"
    # Establish the absolute physical directories for both parameters by cd'ing
    # into each and running the physical pwd command.
    cd "$1"
    START_ABS=`pwd -P`
    cd "$SAVE_DIR"
    cd "$2"
    END_ABS=`pwd -P`

    # Algorithm is to go up from the start until we are at a path that is a
    # prefix of the end. We go up by executing dirname.
    # The ${parameter/#pattern} notation invokes shell parameter expansion with
    # a check for a prefix.
    START_WORK="$START_ABS"
    UPDIRS=""
    
    while test -n "${START_WORK}" -a "${END_ABS/#${START_WORK}}" '==' "$END_ABS";
    do
        START_WORK=`dirname "$START_WORK"`"/"
        UPDIRS=${UPDIRS}"../"
    done
    UPDIRS="$UPDIRS${END_ABS/#${START_WORK}}"
    cd "$SAVE_DIR"
    export GD_ANDROID_RELATIVE="$UPDIRS"
}

function create()
{
    # Create a cordova project and copy in the sample application source.
    cordova create "$APP_NAME" "$APP_ID" "$APP_NAME" \
        --copy-from "../src/${APP_ID}/www/"
    
    # Change to the new project directory.
    cd "$APP_NAME"
    
    # Add some typical plugins.
    # Use these when connected to the Internet
    cordova plugin add org.apache.cordova.device
    cordova plugin add org.apache.cordova.file
    cordova plugin add org.apache.cordova.console
    # Otherwise, you can replace the IDs in the above with paths to the plugin
    # sub-directory of a local project in which you added the plugin.
    # Cordova will copy from the local project to this project.
    
    # Add the demo code, which is provided as a plugin.
    cordova plugin add ../../src/com.good.example.contributor.jhawkins
    
    # Add the required platforms.
    if test -n "$CREATE_ANDROID" ;
    then
        cordova platform add android
    fi
    if test -n "$CREATE_IOS" ;
    then
        cordova platform add ios
    fi
    # From this point onwards, the presence of platform sub-directories is used
    # to determine the need to do processing for each platform.

    # Save the project directory
    export PROJECT_DIR="$PWD"
    # Change back to the original directory in case any paths were specified
    # relatively.
    cd ..
    
    if test -d "${APP_NAME}/platforms/android" ;
    then
        # Enable GD for Android
        cd "${GD_PLUGIN_DIR}/Android/GDCordova3x/"
    
        bash ./FIXEDgdEnableApp.sh -n "$APP_ID_PREFIX" -g "$ORGANISATION_NAME" \
            -i "$APP_ID" -p "${PROJECT_DIR}/platforms/android/"
    
        # Fix up the project files created by the enable script.
        cd "${PROJECT_DIR}"
    
        echo "Fixing project.properties file."
        # Replace the ..gd library reference with the specified location
        setAndroidRelative "platforms/android" "$GD_ANDROID_DIR"
        sed -i -e 's?\.1=\.\.gd$?.2='"$GD_ANDROID_RELATIVE"'?' platforms/android/project.properties
        # Enable Android manifest merging
        echo 'manifestmerger.enabled=true' >> platforms/android/project.properties
        
        echo "Deleting project duplicate of the GD SDK for Android."
        rm -r platforms/android/gd
    
        echo "Overwriting settings.json file."
        cat >platforms/android/assets/settings.json <<SETTINGS.JSON
{
    "GDApplicationID":"$APP_ID",
    "GDApplicationVersion":"1.0.0.0",
    "GDLibraryMode": "GDEnterprise",
    "GDConsoleLogger": [
        "GDFilterErrors",
        "GDFilterWarnings",
        "GDFilterInfo",
        "GDFilterDetailed",
    ]
}
SETTINGS.JSON

        echo "Overwriting AndroidManifest.xml file."
        cat >platforms/android/AndroidManifest.xml <<ANDROIDMANIFEST.XML
<?xml version="1.0" encoding="utf-8"?>
<!--
       Licensed to the Apache Software Foundation (ASF) under one
       or more contributor license agreements.  See the NOTICE file
       distributed with this work for additional information
       regarding copyright ownership.  The ASF licenses this file
       to you under the Apache License, Version 2.0 (the
       "License"); you may not use this file except in compliance
       with the License.  You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

       Unless required by applicable law or agreed to in writing,
       software distributed under the License is distributed on an
       "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
       KIND, either express or implied.  See the License for the
       specific language governing permissions and limitations
       under the License.
-->
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
          android:windowSoftInputMode="adjustPan"
          package="${APP_ID}"
          android:versionName="1.0"
          android:versionCode="1">

    <supports-screens
            android:largeScreens="true"
            android:normalScreens="true"
            android:smallScreens="true"
            android:xlargeScreens="true"
            android:resizeable="true"
            android:anyDensity="true"/>

    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
    <uses-permission android:name="android.permission.ACCESS_LOCATION_EXTRA_COMMANDS"/>
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECEIVE_SMS"/>
    <uses-permission android:name="android.permission.RECORD_AUDIO"/>
    <uses-permission android:name="android.permission.RECORD_VIDEO"/>
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS"/>
    <uses-permission android:name="android.permission.READ_CONTACTS"/>
    <uses-permission android:name="android.permission.WRITE_CONTACTS"/>
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
    <uses-permission android:name="android.permission.GET_ACCOUNTS"/>
    <uses-permission android:name="android.permission.BROADCAST_STICKY"/>
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.READ_PHONE_STATE"/>

    <uses-sdk
            android:minSdkVersion="10"/>

    <application
            android:enabled="true"
            android:label="@string/app_name"
            android:icon="@drawable/icon"
            android:hardwareAccelerated="true"
            android:debuggable="true" >
        <activity
                android:name=".MainActivity"
                android:label="@string/app_name"
                android:theme="@android:style/Theme.Black.NoTitleBar"
                android:alwaysRetainTaskState="true"
                android:configChanges="orientation|keyboardHidden|keyboard|screenSize|locale" >
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
    </application>
</manifest>
ANDROIDMANIFEST.XML

        echo "Changing project name in .project file"
        sed -i -e 's/>'"$APP_NAME"'</>'"$APP_NAME"' (PhoneGap)</' platforms/android/.project
        
        # Switch back to initial directory
        cd ..
    fi

    if test -d "${APP_NAME}/platforms/ios" ;
    then
        # Enable GD for iOS
        cd "${GD_PLUGIN_DIR}/iOS/SampleApplications/UpdateApp-Cordova3x/"
        bash ./FIXEDgdEnableApp.sh -c "$APP_ID_PREFIX" -g "$ORGANISATION_NAME" \
            -i "$APP_ID" -p "${PROJECT_DIR}/platforms/ios/"
        
        cd "$PROJECT_DIR"
        echo "Fixing deployment target."
        sed -i \
            -e 's/IPHONEOS_DEPLOYMENT_TARGET = 5\.0;/IPHONEOS_DEPLOYMENT_TARGET = 6.0;/g' \
            "platforms/ios/${APP_NAME}.xcodeproj/project.pbxproj"
        
        cat <<ARCHITECTURES.NOTE

Sorry, this script does not fix the Architectures and Valid Architectures in
the project for iOS. You might need to do that yourself, in Xcode, before
building for iOS.

ARCHITECTURES.NOTE
        # Switch back to initial directory
        cd ..
    fi
}

function rebuild()
{
    SAVE_DIR="$PWD"
    DID=""
    # Change to the project directory, if necessary.
    # If it's not here, assume we are already in the project directory.
    if test -d "$APP_NAME" ;
    then
        cd "$APP_NAME"
    fi

    # Uncomment the following to remove and re-add the code plugin
    #cordova plugin remove com.good.example.contributor.jhawkins
    #cordova plugin add ../../src/com.good.example.contributor.jhawkins

    # Uncomment the following to refresh the source from the original.
    #echo "Reloading www/ from original."
    #cp -r "../../src/${APP_ID}/www/" www/

    # Uncomment the following to remove and re-add the file plugin, which can
    # resolve some issues.
    cordova plugin remove org.apache.cordova.file
    cordova plugin add org.apache.cordova.file
    # See also the comment above about using a local project instead when not
    # connected to the Internet.

    if test -d platforms/android ;
    then
        echo "Synchronising asset files for Android"
        cp -R www/ platforms/android/assets/www/
        DID="${DID} Android"
    fi
    if test -d platforms/ios ;
    then
        echo "Synchronising asset files for iOS"
        cp -R www/ platforms/ios/www/
        DID="${DID} iOS"
    fi
    if test -z "$DID" ;
    then
        echo "Nothing to rebuild"
    fi
    cd "$SAVE_DIR"
}

if test $# '>' 0;
then
    GD_PLUGIN_DIR="$1"
    shift
fi

if test '!' -d "$APP_NAME" && test "`basename \"$PWD\"`" '!=' "$APP_NAME";
then
    # We will be creating the project.
    ERROR=''

    # Try to work out the GD SDK for Android install directory, if it's needed
    # and if it hasn't been specified explicitly.
    if test -n "$CREATE_ANDROID" -a -z "$GD_ANDROID_DIR";
    then
        setAndroidDir
    fi
    if test -z "$GD_ANDROID_DIR" -a -n "$CREATE_ANDROID";
    then
        ERROR="error"
        echo "GD_ANDROID_DIR not set manually or automatically."
    fi
    
    if test '!' -d "$GD_PLUGIN_DIR";
    then
        ERROR="error"
        cat <<GD_PLUGIN_DIR.BLANK
GD_PLUGIN_DIR "${GD_PLUGIN_DIR}" does not exist or is not a directory.
It should be the path to the directory in which you extracted the GD PhoneGap
Plugin download. You can set it at the top of the script or put it as the first
and only command line parameter.
GD_PLUGIN_DIR.BLANK
    fi
    
    if test -z "$ERROR";
    then
        create
        rebuild
    else
        # One or more error messages will have been printed already.
        exit 1
    fi
else
    rebuild
fi
