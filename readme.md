Good Dynamics Contributor Code
==============================
This repository contains Good Dynamics&trade; contributor sample code. Good
Dynamics (GD) is the Good Technology&trade; platform for secure mobile
application development. To make use of the sample code in this repository you
will need the following.

- An account on the [Good Developer Network](https://developer.good.com).
- To have installed the GD SDK for Android or the GD SDK for iOS, or both.
- A deployment of GD, i.e. Good Control and Good Proxy servers.

Contents
--------
The contributor code includes a complete GD application: AppKinetics Workflow.
The application can be used to demonstrate the following tasks:

-   Send an email with To, Cc and Bcc addresses; a subject line and body text;
    and a number of file attachments. You must have GFE installed to demonstrate
    this. (Sorry, the contributor application for PhoneGap only demonstrates a
    subset of email features, at time of writing.)
-   Send a file to another application that provides the Transfer File service,
    for example Good Share.
-   Receive a file from another application that consumes the Transfer File
    service.
-   Open an HTTP URL. You must have Good Access or another secure browser
    installed to demonstrate this.

The demonstrations use simple diagnostic data that is generated within the
application.

Project files and source code are provided for Android, for iOS and for
PhoneGap.

Structure
---------
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

Each of the `forAndroid/`, `foriOS/`, and `forPhoneGap/` sub-directories
contains a readme file that explains how to use the sample code on that
platform.
