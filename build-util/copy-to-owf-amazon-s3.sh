#!/bin/sh
(set -o igncr) 2>/dev/null && set -o igncr; # this comment is required
# The above line ensures that the script can be run on Cygwin/Linux even with Windows CRNL
#
# Copy the site/* contents to the learn.openwaterfoundation.org website
# - replace all the files on the web with local files
# - must specify Amazon profile as argument to the script

# Supporting functions, alphabetized

# Make sure the MkDocs version is consistent with the documentation content
# - require that at least version 1.0 is used because of use_directory_urls = True default
# - must use "file.md" in internal links whereas previously "file" would work
# - it is not totally clear whether version 1 is needed but try this out to see if it helps avoid broken links
checkMkdocsVersion() {
  # Required MkDocs version is at least 1
  requiredMajorVersion="1"
  # On Cygwin, mkdocs --version gives:  mkdocs, version 1.0.4 from /usr/lib/python3.6/site-packages/mkdocs (Python 3.6)
  # On Debian Linux, similar to Cygwin:  mkdocs, version 0.17.3
  mkdocsVersionFull=$(${mkdocsExe} --version)
  echo "MkDocs --version:  ${mkdocsVersionFull}"
  mkdocsVersion=$(echo ${mkdocsVersionFull} | cut -d ' ' -f 3)
  echo "MkDocs full version number:  ${mkdocsVersion}"
  mkdocsMajorVersion=$(echo ${mkdocsVersion} | cut -d '.' -f 1)
  echo "MkDocs major version number:  ${mkdocsMajorVersion}"
  if [ "${mkdocsMajorVersion}" -lt ${requiredMajorVersion} ]; then
    echo ""
    echo "MkDocs version for this documentation must be version ${requiredMajorVersion} or later."
    echo "MkDocs mersion that is found is ${mkdocsMajorVersion}, from full version ${mkdocsVersion}."
    exit 1
  else
    echo ""
    echo "MkDocs major version (${mkdocsMajorVersion}) is OK for this documentation."
  fi
}

# Determine the operating system that is running the script
# - mainly care whether Cygwin or MINGW
checkOperatingSystem() {
  if [ ! -z "${operatingSystem}" ]; then
    # Have already checked operating system so return
    return
  fi
  operatingSystem="unknown"
  os=$(uname | tr [a-z] [A-Z])
  case "${os}" in
    CYGWIN*)
      operatingSystem="cygwin"
      ;;
    LINUX*)
      operatingSystem="linux"
      ;;
    MINGW*)
      operatingSystem="mingw"
      ;;
  esac
}

# Check the source files for issues
# - the main issue is internal links need to use [](file.md), not [](file)
checkSourceDocs() {
  # Currently don't do anything but could check the above
  # Need one line to not cause an error
  :
}

# Invalidate a CloudFront distribution for files:
# - first parameter is the CloudFront distribution ID
# - second parameter is the CloudFront folder.
# - ${awsProfile} must be set in global data
invalidateCloudFront() {
  local errorCode cloudFrontDistributionId cloudFrontFolder
  if [ -z "$1" ]; then
    logError "CloudFront distribution ID is not specified.  Script error."
    return 1
  fi
  if [ -z "$2" ]; then
    logError "CloudFront folder is not specified.  Script error."
    return 1
  fi
  # Check global data.
  if [ -z "${awsProfile}" ]; then
    logError "'awsProfile' is not set.  Script error."
    exit 1
  fi
  cloudFrontDistributionId=$1
  cloudFrontFolder=$2

  # Invalidate for CloudFront so that new version will be displayed:
  # - see:  https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/Invalidation.html
  # - TODO smalers 2020-04-13 for some reason invalidating /index.html does not work, have to do "/index.html*"
  echo "Invalidating files so CloudFront will make new version available..."
  ${awsExe} cloudfront create-invalidation --distribution-id ${cloudFrontDistributionId} --paths "${cloudFrontFolder}" --profile "${awsProfile}"
  errorCode=$?

  return ${errorCode}
}

# Set the Python AWS executable.
setAwsExe() {
  if [ "${operatingSystem}" = "mingw" ]; then
    # If "aws" is in path, use it
    if [ "$(which aws 2> /dev/null | cut -c 1)" = "/" ]; then
      # Found aws
      awsExe="aws"
    else
      # Figure out the Python installation path
      pythonExePath=$(py -c "import sys; print(sys.executable)")
      if [ -n "${pythonExePath}" ]; then
        # Path will be something like:  C:\Users\sam\AppData\Local\Programs\Python\Python37\python.exe
        # - so strip off the exe and substitute Scripts
        # - convert the path to posix first
        pythonExePathPosix="/$(echo ${pythonExePath} | sed 's/\\/\//g' | sed 's/://')"
        pythonScriptsFolder="$(dirname ${pythonExePathPosix})/Scripts"
        echo ${pythonScriptsFolder}
        awsExe="${pythonScriptsFolder}/aws"
      else
        echo "ERROR: Unable to find Python installation location to find 'aws' script"
        echo "ERROR: Make sure Python 3.x is installed on Windows so 'py' is available in PATH"
        exit 1
      fi
    fi
  else
    # For other Linux just try to run.
    awsExe="aws"
  fi
}

# Set the MkDocs executable to use, depending operating system and PATH:
# - sets the global ${mkdocsExe} variable
# - return 0 if the executable is found, exit with 1 if not
setMkDocsExe() {
  if [ "${operatingSystem}" = "cygwin" -o "${operatingSystem}" = "linux" ]; then
    # Is usually in the PATH.
    mkdocsExe="mkdocs"
    if hash py 2>/dev/null; then
      echo "mkdocs is not found (not in PATH)."
      exit 1
    fi
  elif [ "${operatingSystem}" = "mingw" ]; then
    # This is used by Git Bash:
    # - calling 'hash' is a way to determine if the executable is in the path
    if hash py 2>/dev/null; then
      mkdocsExe="py -m mkdocs"
    else
      # Try adding the Windows folder to the PATH and rerun:
      # - not sure why C:\Windows is not in the path in the first place
      PATH=/C/Windows:${PATH}
      if hash py 2>/dev/null; then
        mkdocsExe="py -m mkdocs"
      else
        echo 'mkdocs is not found in C:\Windows.'
        exit 1
      fi
    fi
  fi
  return 0
}

# Entry point into the script

# Check the operating system
checkOperatingSystem

# Set the MkDocs executable:
# - will exit if MkDocs is not found
setMkDocsExe

# Set the Python aws executable:
setAwsExe

# Make sure the MkDocs version is OK
checkMkdocsVersion

# Check the source files for issues
checkSourceDocs

# Get the folder where this script is located since it may have been run from any folder
scriptFolder=$(cd $(dirname "$0") && pwd)
# Change to the folder where the script is since other actions below are relative to that
cd ${scriptFolder}

# Set --dryrun to test before actually doing
dryrun=""
#dryrun="--dryrun"
s3Folder="s3://learn.openwaterfoundation.org/owf-learn-aws"

if [ "$1" == "" ]
  then
  echo ""
  echo "Usage:  $0 AmazonConfigProfile"
  echo ""
  echo "Copy the site files to the Amazon S3 static website folder:  $s3Folder"
  echo ""
  exit 0
fi

awsProfile="$1"

# First build the site so that the "site" folder contains current content.
# - "mkdocs serve" does not do this

cd ../mkdocs-project

${mkdocsExe} build --clean

cd ../build-util

# Now sync the local files up to Amazon S3
${awsExe} s3 sync ../mkdocs-project/site ${s3Folder} ${dryrun} --delete --profile "${awsProfile}"

# Invalidate the CloudFront distribution.
cloudFrontDistributionId="E1OLDBANEI7OML"
cloudFrontFolder="/owf-learn-aws/*"
invalidateCloudFront ${cloudFrontDistributionId} ${cloudFrontFolder}

exit $?
