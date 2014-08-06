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
# Command line option vars
OPT_APP_ID=""
OPT_APP_NAME=""
OPT_COMPANY_ID=""
OPT_ORG_NAME=""
OPT_REDIRECT_URI="testsfdc:///mobilesdk/detect/oauth/done"
OPT_PROJECT_PATH=""
OPT_HYBRID_APP_START_PAGE=""
OPT_HYBRID_APP_IS_LOCAL=""

# Defaults for start page
DEF_START_PAGE_REMOTE="/apex/VFStartPage"
DEF_START_PAGE_LOCAL="index.html"

# Template substitution keys
SUB_APP_NAME="__TemplateAppName__"
SUB_APP_ID="__ChangeId__"
SUB_COMPANY_ID="__CompanyIdentifier__"
SUB_ORG_NAME="__OrganizationName__"

# Term color codes
TERM_COLOR_RED="\x1b[31;1m"
TERM_COLOR_GREEN="\x1b[32;1m"
TERM_COLOR_YELLOW="\x1b[33;1m"
TERM_COLOR_MAGENTA="\x1b[35;1m"
TERM_COLOR_CYAN="\x1b[36;1m"
TERM_COLOR_RESET="\x1b[0m"

function echoColor
{
  echo -e "$1$2$TERM_COLOR_RESET"
}

function usage()
{
  local appName=`basename $0`
  echoColor $TERM_COLOR_CYAN "Usage:"
  echoColor $TERM_COLOR_MAGENTA "$appName"
  echoColor $TERM_COLOR_MAGENTA "   -c <Company Identifier> (com.myCompany.myApp)"
  echoColor $TERM_COLOR_MAGENTA "   -g <Organization Name> (your company's/organization's name)"
  echoColor $TERM_COLOR_MAGENTA "   -i <Application Id> (your application id)"
  echoColor $TERM_COLOR_MAGENTA "   -p <Path to Project>"
}

function parseOpts()
{
  while [ "$1" != "" ]; do
      case $1 in
        -i)
          if [ -z "$2" ] || [ "$2" = "" ] || [ "$2" = "-c" ] || [ "$2" = "-g" ] || [ "$2" = "-p" ]; then
            echoColor $TERM_COLOR_RED "Application Id must have a value."
            usage
            exit 4
          fi
          idName="$2"
          noSpecialCharsAppName=`echo "${idName}" | sed 's/[^a-zA-Z0-9\.\-_]//g'`
          if [[ "${noSpecialCharsAppName}" != "${idName}" ]]; then
            echoColor $TERM_COLOR_RED "Application id (${idName}) cannot contain special characters.  Only letters, numbers and the characters '.',  '-', and '_' are allowed."
            usage
            exit 5
          fi
          OPT_APP_ID="${idName}"
          # Shift to next parameter.
          shift;shift;
          continue
          ;;
        -c)
          if [ -z "$2" ] || [ "$2" = "" ] || [ "$2" = "-i" ] || [ "$2" = "-g" ] || [ "$2" = "-p" ]; then
            echoColor $TERM_COLOR_RED "Company identifier must have a value."
            usage
            exit 6
          fi
          companyId="$2"
          # Like Apple's template, just convert non-standard Company Identifier characters to dashes, and cull leading periods.
          companyId=`echo "${companyId}" | sed -e 's/^\.\.*//g' | sed -e 's/[^a-zA-Z0-9\.]/-/g'`
          OPT_COMPANY_ID="${companyId}"
          # Shift to next parameter.
          shift;shift;
          continue
          ;;
        -g)
          if [ -z "$2" ] || [ "$2" = "" ] || [ "$2" = "-i" ] || [ "$2" = "-c" ] || [ "$2" = "-p" ]; then
            echoColor $TERM_COLOR_RED "Organization name must have a value."
            usage
            exit 7
          fi
          orgName="$2"
          noSpecialCharsAppName=`echo "${orgName}" | sed 's/[^a-zA-Z0-9\.\-_]//g'`
          if [[ "${noSpecialCharsAppName}" != "${orgName}" ]]; then
            echoColor $TERM_COLOR_RED "Organization name (${orgName}) cannot contain special characters.  Only letters, numbers, and the characters '.',  '-', and '_' are allowed."
            usage
            exit 5
          fi
          OPT_ORG_NAME="${orgName}"
          # Shift to next parameter.
          shift;shift;
          continue
          ;;
        -p)
          if [ -z "$2" ] || [ "$2" = "" ] || [ "$2" = "-i" ] || [ "$2" = "-c" ] || [ "$2" = "-g" ]; then
            echoColor $TERM_COLOR_RED "Project folder must have a value."
            usage
            exit 8
          fi
          projectPath="$2"        
          FILES=`find "$projectPath/" -maxdepth 1 -name \*.xcodeproj`
          OPT_APP_NAME=`basename "$FILES" | cut -d. -f1`       
        
          OPT_PROJECT_PATH="${projectPath}"
          # Shift to next parameter.
          shift;shift;
          continue
          ;;
        --)                                                                 
          # no more arguments to parse                                
          break      
          ;;
        *)
          echoColor $TERM_COLOR_RED "ERROR: unknown parameter \"$1\"."
          usage
          exit 1
          ;;
    esac
  done
  
  # Validate that we got the required command line args.
  if [[ "${OPT_COMPANY_ID}" == "" ]]; then
    echoColor $TERM_COLOR_RED "No option specified for Company Identifier."
    usage
    exit 14
  fi
  if [[ "${OPT_ORG_NAME}" == "" ]]; then
    echoColor $TERM_COLOR_RED "No option specified for Organization Name."
    usage
    exit 15
  fi
  if [[ "${OPT_APP_ID}" == "" ]]; then
    echoColor $TERM_COLOR_RED "No option specified for Application Id."
    usage
    exit 15
  fi
  if [[ "${OPT_PROJECT_PATH}" == "" ]]; then
    echoColor $TERM_COLOR_RED "No option specified for Project Path."
    usage
    exit 13
  fi
  if [[ "${OPT_APP_NAME}" == "" ]]; then
    echoColor $TERM_COLOR_RED "Can't find Xcode project in path - $OPT_PROJECT_PATH"
    usage
    exit 13
  fi
}

function tokenSubstituteInFile()
{
  local subFile=$1
  local token=$2
  local replacement=$3

  # Sanitize the replacement value for sed.  (Assume $token is fine—we control that value.)
  replacement=`echo "${replacement}" | sed 's/[\&/]/\\\&/g'`

  cat "${subFile}" | sed "s/${token}/${replacement}/g" > "${subFile}.new"
  mv "${subFile}.new" "${subFile}"
}

function replaceTokens()
{
  local appNameToken

  appNameToken=${SUB_APP_NAME}

  # Make the output folder.
  rm -rf "$OPT_PROJECT_PATH/$OPT_APP_NAME"
  rm -rf "$OPT_PROJECT_PATH/$OPT_APP_NAME.xcodeproj"
  local outputFolderAbsPath=`cd "${OPT_PROJECT_PATH}" && pwd`

  # Copy the app template folder to a new working folder, and change to that folder.
  local origWorkingFolder=`pwd`
  local workingFolderPrefix=`basename ${BASH_SOURCE[0]}`
  local workingFolderTemplate="/tmp/${workingFolderPrefix}.XXXXXX"
  local workingFolder=`mktemp -d ${workingFolderTemplate}`
  local resourcesFolder=`dirname "${BASH_SOURCE[0]}"`
  cp -R "${resourcesFolder}/${appNameToken}" "${workingFolder}"
  cd "${workingFolder}"

  local inputPrefixFile="${appNameToken}/${appNameToken}/${appNameToken}-Prefix.pch"
  local inputInfoFile="${appNameToken}/${appNameToken}/${appNameToken}-Info.plist"
  local inputProjectFile="${appNameToken}/${appNameToken}.xcodeproj/project.pbxproj"
  local inputShemeFile="${appNameToken}/${appNameToken}.xcodeproj/xcshareddata/xcschemes/${appNameToken}.xcscheme"
  local inputIndexHtml="${appNameToken}/www/index.html"
  local inputConfigXMLwww="${appNameToken}/www/config.xml"
  local inputConfigXMLProject="${appNameToken}/${appNameToken}/config.xml"

  # Storing previous html page
  cp -R "${outputFolderAbsPath}/www/index.html" "${workingFolder}"

  # App name
  tokenSubstituteInFile "${inputPrefixFile}" "${appNameToken}" "${OPT_APP_NAME}"
  tokenSubstituteInFile "${inputProjectFile}" "${appNameToken}" "${OPT_APP_NAME}"
  tokenSubstituteInFile "${inputShemeFile}" "${appNameToken}" "${OPT_APP_NAME}"
  tokenSubstituteInFile "${inputIndexHtml}" "applicationName" "${OPT_APP_NAME}"
  tokenSubstituteInFile "${inputConfigXMLwww}" "applicationName" "${OPT_APP_NAME}"
  tokenSubstituteInFile "${inputConfigXMLProject}" "applicationName" "${OPT_APP_NAME}"
  
  # Company identifier
  tokenSubstituteInFile "${inputInfoFile}" "${SUB_COMPANY_ID}" "${OPT_COMPANY_ID}"

  # Application id
  tokenSubstituteInFile "${inputInfoFile}" "${SUB_APP_ID}" "${OPT_APP_ID}"
  tokenSubstituteInFile "${inputConfigXMLwww}" "applicationId" "${OPT_APP_ID}"
  tokenSubstituteInFile "${inputConfigXMLProject}" "applicationId" "${OPT_APP_ID}"
  
  # Org name
  tokenSubstituteInFile "${inputProjectFile}" "${SUB_ORG_NAME}" "${OPT_ORG_NAME}"
    
  # Rename files, move to destination folder.
  echoColor $TERM_COLOR_YELLOW "Updating app in ${outputFolderAbsPath}/${OPT_APP_NAME}"
  mv "${inputIndexHtml}" "${appNameToken}/www/index.html"
  mv "${inputConfigXMLwww}" "${appNameToken}/www/config.xml"
  mv "${inputConfigXMLProject}" "${appNameToken}/${appNameToken}/config.xml"
  mv "${inputPrefixFile}" "${appNameToken}/${appNameToken}/${OPT_APP_NAME}-Prefix.pch"
  mv "${inputInfoFile}" "${appNameToken}/${appNameToken}/${OPT_APP_NAME}-Info.plist"
  mv "${appNameToken}/${appNameToken}.xcodeproj" "${appNameToken}/${OPT_APP_NAME}.xcodeproj"
  mv "${appNameToken}/${OPT_APP_NAME}.xcodeproj/xcshareddata/xcschemes/${appNameToken}.xcscheme" "${appNameToken}/${OPT_APP_NAME}.xcodeproj/xcshareddata/xcschemes/${OPT_APP_NAME}.xcscheme"
  mv "${appNameToken}/${appNameToken}" "${appNameToken}/${OPT_APP_NAME}"
  mv "${appNameToken}" "${outputFolderAbsPath}/${OPT_APP_NAME}"
  mv "${outputFolderAbsPath}/${OPT_APP_NAME}" "${outputFolderAbsPath}/temp"
  cp -R "${outputFolderAbsPath}/temp/" "${outputFolderAbsPath}"
  rm -rf "${outputFolderAbsPath}/temp"

  cp -R "${workingFolder}/index.html" "${outputFolderAbsPath}/www"
  #Restoring previous html page
  sed -i -e 's/<script type="text\/javascript" src="cordova.js"><\/script>/<script type="text\/javascript" src="cordova.js"><\/script>\
      <script type="text\/javascript" src="GoodDynamics.js"><\/script>/g' "${outputFolderAbsPath}/www/index.html"

  sed -i -e 's/<script type="text\/javascript" charset="utf-8" src="cordova.js"><\/script>/<script type="text\/javascript" charset="utf-8" src="cordova.js"><\/script>\
      <script type="text\/javascript" src="GoodDynamics.js"><\/script>/g' "${outputFolderAbsPath}/www/index.html"

  rm -rf "${outputFolderAbsPath}/www/index.html-e"

  # Remove working artifacts
  cd "${origWorkingFolder}"
  rm -rf "${workingFolder}"
}

if [[ "$@" == "" ]]; then
  usage
  exit 1
fi

parseOpts "$@"
replaceTokens 

echoColor $TERM_COLOR_GREEN "Successfully updated app '${OPT_APP_NAME}'."