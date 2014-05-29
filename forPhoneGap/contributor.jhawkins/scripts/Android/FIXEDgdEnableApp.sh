#!/bin/sh

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY
# WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
PROJECT_PATH=""
ORIGINAL_PATH=`pwd`
ORGRANIZATION_NAME=""
APPLICATION_PACKAGE=""
APPLICATION_NAME=""
COMPANY_IDENTIFIER=""

# Term color codes
COLOR_RED="\x1b[31;1m"
COLOR_GREEN="\x1b[32;1m"
COLOR_YELLOW="\x1b[33;1m"
COLOR_MAGENTA="\x1b[35;1m"
COLOR_CYAN="\x1b[36;1m"
COLOR_RESET="\x1b[0m"

function echoColor
{
  echo -e "$1$2$COLOR_RESET"
}
 
function usage()
{
    echoColor $COLOR_CYAN "Usage:"
    echoColor $COLOR_MAGENTA "$0"
    echoColor $COLOR_MAGENTA "   -g <Organization Name> (your company's/organization's name)"
  	echoColor $COLOR_MAGENTA "   -i <Application Package> (com.application.package)"
    echoColor $COLOR_MAGENTA "   -n <Application Name> (ApplicationName)"
    echoColor $COLOR_MAGENTA "   -p <Path to Project>"
}

function parseOptions()
{
	while [ "$1" != "" ]; do
    	case $1 in
        	-p)
				if [ -z "$2" ] || [ "$2" = "" ] || [ "$2" = "-g" ] || [ "$2" = "-i" ] || [ "$2" = "-n" ]; then
					echoColor $COLOR_RED "Path to project must have a value."
                    usage
					exit
				fi

				FILES=`find "$2"/ -maxdepth 1 -name AndroidManifest.xml`
				if [ -z "$FILES" ] || [ "$FILES" = "" ]; then
					 echoColor $COLOR_RED "Can't find Android project in path - $2"
                     usage
                     exit
				fi

				PROJECT_PATH="$2"

				# Shift to next parameter.
            	shift;shift;

            	continue
            	;;
            -n)
                if [ -z "$2" ] || [ "$2" = "" ] || [ "$2" = "-g" ] || [ "$2" = "-i" ] || [ "$2" = "-p" ]; then
                    echoColor $COLOR_RED "Application name must have a value."
                    usage
                    exit
                fi

                appName="$2"
                noSpecialCharsAppName=`echo "${appName}" | sed 's/[^a-zA-Z0-9\.\-_]//g'`
                if [[ "${noSpecialCharsAppName}" != "${appName}" ]]; then
                    echoColor $COLOR_RED "Application name (${appName}) cannot contain special characters.  Only letters, numbers and the characters '.',  '-', and '_' are allowed."
                    usage
                    exit
                fi

                APPLICATION_NAME="$2"

                # Shift to next parameter.  
                shift;shift;

                continue
                ;;
        	-g)
				if [ -z "$2" ] || [ "$2" = "" ] || [ "$2" = "-p" ] || [ "$2" = "-i" ] || [ "$2" = "-n" ]; then
					echoColor $COLOR_RED "Organization name must have a value."
                    usage
					exit
				fi

            	ORGRANIZATION_NAME="$2"

            	# Shift to next parameter.	
            	shift;shift;

            	continue
            	;;
            -i)
				if [ -z "$2" ] || [ "$2" = "" ] || [ "$2" = "-g" ] || [ "$2" = "-p" ] || [ "$2" = "-n" ]; then
					echoColor $COLOR_RED "Application Package must have a value."
                    usage
					exit
				fi

            	APPLICATION_PACKAGE="$2"

            	noSpecialCharsAppName=`echo "${APPLICATION_PACKAGE}" | sed 's/[^a-z0-9\.]//g'`

          		if [[ "${noSpecialCharsAppName}" != "${APPLICATION_PACKAGE}" ]]; then
              		echoColor $COLOR_RED "Application package (${APPLICATION_PACKAGE}) cannot contain special characters.  Only small letters, numbers, and the '.' character."
              		usage
              		exit
          		fi

            	# Shift to next parameter.	
            	shift;shift;

            	continue
            	;;
        	--)                                                                 
            	# no more arguments to parse                                
            	break      
            	;;
        	*)
      			echoColor $COLOR_RED "ERROR: unknown parameter \"$1\"."
            	usage
            	exit 1
            	;;
    	esac
	done

	if [[ "${PROJECT_PATH}" == "" ]]; then
		echoColor $COLOR_RED "No option specified for Project path."
    	usage
    	exit
	fi

	if [[ "${ORGRANIZATION_NAME}" == "" ]]; then
		echoColor $COLOR_RED "No option specified for Organization Name."
    	usage
    	exit
	fi
	if [[ "${APPLICATION_PACKAGE}" == "" ]]; then
      	echoColor $COLOR_RED "No option specified for Application Package."
      	usage
      	exit
    fi
    if [[ "${APPLICATION_NAME}" == "" ]]; then
        echoColor $COLOR_RED "No option specified for Application Name."
        usage
        exit
    fi
}

function changeRootFiles()
{
	echoColor $COLOR_YELLOW "Updating app in ${PROJECT_PATH}"
    rm "$PROJECT_PATH/AndroidManifest.xml"
    cp "$ORIGINAL_PATH/Files/AndroidManifest.xml" "$PROJECT_PATH/"
    chmod 777 "$PROJECT_PATH/AndroidManifest.xml"

    # Replace package name with our.
    sed -i -e 's/applicationPackage/'${APPLICATION_PACKAGE}'/g' "$PROJECT_PATH/AndroidManifest.xml"
    rm -rf "$PROJECT_PATH/AndroidManifest.xml-e"

    echoColor $COLOR_YELLOW "Copying libraries.."
    cp -Rf  "$ORIGINAL_PATH/Files/libs" "$PROJECT_PATH/"
}

function changeSourcesFolder()
{
    rm -rf "$PROJECT_PATH/src"
    mkdir "$PROJECT_PATH/src"
    cd "$PROJECT_PATH/src"
    IFS='.' read -a array <<< "$APPLICATION_PACKAGE"
    for element in "${array[@]}"
    do
        mkdir "$element"
        cd $element
    done

    cp "$ORIGINAL_PATH/Files/src/IccReceivingActivity.java" "./"
    cp "$ORIGINAL_PATH/Files/src/MainActivity.java" "./"

    sed -i -e 's/applicationPackage/'${APPLICATION_PACKAGE}'/g' ./IccReceivingActivity.java
    rm -rf "IccReceivingActivity.java-e"

    sed -i -e 's/applicationPackage/'$APPLICATION_PACKAGE'/g' ./MainActivity.java
    rm -rf "MainActivity.java-e"
}

function changeAssetsFolder()
{
    ASSETS_PATH="$PROJECT_PATH/assets"
    cp "$ORIGINAL_PATH/Files/assets/settings.json" "$ASSETS_PATH/"

    # Replace package name with our.
    sed -i -e 's/applicationPackage/'${APPLICATION_PACKAGE}'/g' "$ASSETS_PATH/settings.json"
    rm -rf "$ASSETS_PATH/settings.json-e"

    WWW_PATH="$ASSETS_PATH/www"
    cp "$ORIGINAL_PATH/Files/assets/www/GoodDynamics.js" "$WWW_PATH/"
    rm -rf "$WWW_PATH/index.html"
    cp -Rf "$ORIGINAL_PATH/Files/assets/www/index.html" "$WWW_PATH/index.html" 
    chmod 777 "$WWW_PATH/index.html"
    sed -i -e 's/applicationName/'${APPLICATION_NAME}'/g' "$WWW_PATH/index.html"
    rm -rf "$WWW_PATH/index.html-e"

    rm -rf "$WWW_PATH/config.xml"
    cp -Rf "$ORIGINAL_PATH/Files/assets/www/config.xml" "$WWW_PATH/config.xml" 
    chmod 777 "$WWW_PATH/config.xml"
    sed -i -e 's/applicationPackage/'${APPLICATION_PACKAGE}'/g' "$WWW_PATH/config.xml"
    sed -i -e 's/applicationName/'${APPLICATION_NAME}'/g' "$WWW_PATH/config.xml"
    rm -rf "$WWW_PATH/config.xml-e"

    chmod 777 "$WWW_PATH/GoodDynamics.js"
    chmod 777 "$WWW_PATH/index.html"

    cp -Rf "$ORIGINAL_PATH/Files//res/xml/config.xml" "$PROJECT_PATH/res/xml/config.xml"
    chmod 777 "$PROJECT_PATH/res/xml/config.xml"
    sed -i -e 's/applicationPackage/'${APPLICATION_PACKAGE}'/g' "$PROJECT_PATH/res/xml/config.xml"
    sed -i -e 's/applicationName/'${APPLICATION_NAME}'/g' "$PROJECT_PATH/res/xml/config.xml"
    rm -rf "$PROJECT_PATH/res/xml/config.xml-e"
}

function addDependencies()
{
    echoColor $COLOR_YELLOW "Adding libraries dependencies..."
    #cd "$ORIGINAL_PATH"
    #cd ..
    cd $HOME/adt/sdk/extras/good/dynamics_sdk/libs
    if ! [ -d "./gd" ]; then
        echoColor $COLOR_RED "Can't find GD Core library in path - `pwd`"
        exit
    fi
    cp -Rf "gd" "$PROJECT_PATH/"
    cat "$ORIGINAL_PATH/Files/application.properties" >> "$PROJECT_PATH/project.properties"
    sed -i -e 's/..gd/.gd/g' "$PROJECT_PATH/project.properties"
    rm -rf "$PROJECT_PATH/project.properties-e"
    rm -rf "$PROJECT_PATH/gd/backup"
    rm -rf "$PROJECT_PATH/gd/gd.iml"
    rm -rf "$PROJECT_PATH/gd/gen"
    rm -rf "$PROJECT_PATH/gd/local.properties"
}

parseOptions "$@"
changeRootFiles
changeSourcesFolder
changeAssetsFolder
addDependencies

echoColor $COLOR_GREEN "Successfully updated app."