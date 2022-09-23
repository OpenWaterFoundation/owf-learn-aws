# AWS / CLI #

This documentation describes how to install and use the AWS command line interface (CLI).

* [Introduction](#introduction)
* [Install Python `awscli`](#install-python-awscli)
    + [Install on Windows](#install-on-windows)
    + [Install on Git Bash](#install-on-git-bash)
    + [Install on Cygwin](#install-on-cygwin)
* [User Authentication](#user-authentication)
* [Run `aws`](#run-aws)
    + [Run on Windows](#run-on-windows)
    + [Run on Git Bash](#run-on-git-bash)
    + [Run on Cygwin](#run-on-cygwin)

------------

## Introduction ##

[The AWS Command Line Interface (CLI)](https://aws.amazon.com/cli/) is a Python tool to manage AWS services on the command line.
CLI can be run from Windows command line, Cywin, Git Bash, and Linux shell,
and allows AWS commands to be scripted and automated.

See also the [TSTool Integration](../tstool/tstool.md) documentation
for information about using TSTool to automate AWS tasks.
TSTool is software developed by the Open Water Foundation to process time series,
data tables, and other data.

The AWS CLI software has multiple versions.  Make sure to install the latest major version if possible.
Version 2 has an improved launcher on Windows that simplifies its use over version 1.

## Install Python `awscli` ##

See the [AWS CLI installation documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html).

### Install on Windows ###

It is recommended to use the latest version of the software.

#### AWS CLI Version V2 ####

The software is available in a self-extracting installer on the download page.
Download and run the installer,
which by default installs the software in `C:\Program Files\Amazon\AWSCLIV2`.
The installer automatically adds the software folder to the `PATH` environment variable
and the program is `C:\Program Files\Amazon\AWSCLI2\aws.exe`.
Test that the software is accessible by opening a Windows command shell and running:

```
aws --version
```

#### AWS CLI Version V1 ####

**This section is retained for historical purposes.**

The AWS command line interface (CLI) is installed using `pip`.
First make sure that Python and pip are installed (not described here).
To ensure that the package is installed with the desired Python version,
first list Python versions using the following command.
The asterisk is output indicates the default Python that will be used.


```
>py --list

Installed Pythons found by py Launcher for Windows
 -3.7-64 *
 -3.5-64
 -2.7-64
```

To control the `awscli` Python package installation, use a command like the following on Windows:

```
py -m pip install awscli
```

which will use the pip corresponding to latest Python.
Similar commands can be used to install for a specific version of Python,
for example:

```
py -3.7 -m pip install awscli
```

The V1 `aws` script is installed in the `Scripts` folder under the Python installation
and may not be in the `PATH`, in particular if the `py` program installed on Windows is used
to run Python from Git Bash.
See the [Run `aws`](#run-aws) section for information about running `aws`.

### Install on Git Bash ###

It is often helpful to run the AWS CLI a Git Bash shell,
for example to automate S3 upload tasks.
If `aws` has been installed on Windows, it is possible to use the Windows version on Git Bash
without reinstalling.

#### AWS CLI V2 ####

Make sure that `aws` is not aliased in startup file such as `~/.bashrc` because
it will interfere with running the V2 installation.
Use the `alias` command to list aliases and if found,
remove or comment out in the `~/.bashrc` and reopen a shell window.

A Git Bash shell automatically includes the Windows `PATH` and therefore the
Windows `aws` program can theoretically be run from Git Bash.
The location of the program can be tested with the following:

```
which aws
/c/Program Files/Amazon/AWSCLIV2/aws
```

If the program is found and can be run using `aws`, then the configuration is OK.
However, if the program is not in the `PATH`, 
trying to run by specifying the full path may have issues because of the
space in the `Program Files`.
Running the program with a full path and escaping the space seems to work, as follows:

```
/c/Program\ Files/Amazon/AWSCLIV2/aws help
'/c/Program Files/Amazon/AWSCLIV2/aws' help
"/c/Program Files/Amazon/AWSCLIV2/aws" help
```

The latter form can be used in scripts where the path to software is provided in a variable that is expanded in double quotes,
for example:

```
awsExe=$(command -v aws)
"${awsExe}" s3 ...
```

Another option is to install the `aws` software from within a Git Bash shell using `pip`.
However, it may not be obvious whether Python software repositories provide the latest AWS CLI software.

#### AWS CLI V1 ####

The space in `Program Files` causes problems running `aws` V1 in Git Bash.
A workaround is to define an alias in he `.bashrc` file, as follows:

```
# The following fixes the issue of Git Bash not having separate Python installed (uses Windows copy)
# and the first line of the aws script specifies the Python path with space in name:
# -see: https://github.com/aws/aws-cli/issues/1323
# The following works for AWS CLI 1, but is not needed for AWS CLI2.
alias aws='python C:\Program Files\Python35\Scripts\aws"'
```

The alias should be removed if V2 is also installed.

### Install on Cygwin ###

Cygwin is similar to Git Bash in that a Cygwin terminal shell automatically includes the Windows `PATH`.
Therefore, running `aws` on Cygwin is similar to running on Git Bash.
See the previous Git Bash section.

## User Authentication ##

The `aws` program must be configured to allow the user to access AWS.

* See:  [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

The above results in AWS configuration files being saved in the user's files in a `.aws` folder.
A profile name will also have been selected.

The profile name is then used with `aws` script with the `--profile profile-name` command parameter.
If writing scripts to run `aws`, it is helpful to allow the profile to be specified with a script parameter
so that different users can run the script and provide their own profile name.

## Run `aws` ##

The `aws` script is run to interact with web services.
The script is typically installed in a location that is visible in the `PATH`.
Therefore, run `aws` from the command line as per the AWS CLI documentation for specific services.
The following sections provide additional information for various operating systems.

### Run on Windows ###

The Windows installer for `aws` program should result in the software being found in the `PATH`.
Therefore, open a command prompt window and run as `aws`.
Calls to `aws` can be added to `cmd` files.

### Run on Git Bash ###

The following shell script illustrates how to determine the location of the script
See the [full script](https://github.com/OpenWaterFoundation/owf-learn-mkdocs/blob/master/build-util/copy-to-owf-amazon-s3.sh).

```
# Set the AWS executable:
# - handle different operating systems
# - for AWS CLI V2, can call an executable
# - for AWS CLI V1, have to deal with Python
# - once set, use ${awsExe} as the command to run, followed by necessary command parameters
setAwsExe() {
  if [ "${operatingSystem}" = "mingw" ]; then
    # "mingw" is Git Bash:
    # - the following should work for V2
    # - if "aws" is in path, use it
    awsExe=$(command -v aws)
    if [ -n "${awsExe}" ]; then
      # Found aws in the PATH.
      awsExe="aws"
    else
      # Might be older V1.
      # Figure out the Python installation path.
      pythonExePath=$(py -c "import sys; print(sys.executable)")
      if [ -n "${pythonExePath}" ]; then
        # Path will be something like:  C:\Users\sam\AppData\Local\Programs\Python\Python37\python.exe
        # - so strip off the exe and substitute Scripts
        # - convert the path to posix first
        pythonExePathPosix="/$(echo "${pythonExePath}" | sed 's/\\/\//g' | sed 's/://')"
        pythonScriptsFolder="$(dirname "${pythonExePathPosix}")/Scripts"
        echo "${pythonScriptsFolder}"
        awsExe="${pythonScriptsFolder}/aws"
      else
        echo "[ERROR] Unable to find Python installation location to find 'aws' script"
        echo "[ERROR] Make sure Python 3.x is installed on Windows so 'py' is available in PATH"
        exit 1
      fi
    fi
  else
    # For other Linux, including Cygwin, just try to run.
    awsExe="aws"
  fi
}
```

### Run on Cygwin ###

Running on Cygwin depends on the `aws` version and whether the program is found in the `PATH`.
See the previous section for an example that can be used on Cygwin.
