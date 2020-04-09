# AWS / CLI #

This documentation describes how to install and use the AWS command line interface (CLI).

* [Introduction](#introduction)
* [Install Python `awscli`](#install-python-awscli)
* [User Authentication](#user-authentication)
* [Run `aws`](#run-aws)

------------

## Introduction ##

[The AWS Command Line Interface (CLI)](https://aws.amazon.com/cli/) is a Python tool to manage AWS services on the command line.
CLI can be run from Windows command line, Cywin, Git Bash, and Linux shell,
and allows AWS actions to be scripted and automated.

## Install Python `awscli` ##

See the [AWS CLI installation documentation](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-install.html).

### Windows ###

The AWS command line interface (CLI) is installed using `pip`.
First make sure that Python and pip are installed (not described here).
To ensure that the package is installed with the desired Python version,
first list Python versions using:

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

## User Authentication ##

The `aws` program must be configured to allow the user to access AWS.

* See:  [Configuring the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html)

The above results in AWS configuration files being saved in the user's files in a `.aws` folder.
A profile name will also have been selected.

The profile name is then used with `aws` script with the `--profile profile-name` argument.

## Run `aws` ##

The `aws` script is run to interact with web services.
On Linux the script is typically installed in a location that is visible in the `PATH`.
Therefore, run `aws` from the command line as per the AWS CLI documentation for specific services.

### Git Bash on Windows ###

When using Git Bash on Windows,
the `aws` script is installed in the `Scripts` folder under the Python installation
and may not be in the `PATH`, in particular if the `py` program installed on Windows is used
to run Python from Git Bash.
The following shell script illustrates how to determine the location of the script without
being in the `PATH`.
See the [full script](https://github.com/OpenWaterFoundation/owf-learn-mkdocs/blob/master/build-util/copy-to-owf-amazon-s3.sh).

```
# ...Other code would determine the operating system...

if [ "$operatingSystem" = "mingw" ]; then
	# If "aws" is in path, run it
	if [ "$(which aws 2> /dev/null | cut -c 1)" = "/" ]; then
		# Found aws
		aws s3 sync ../mkdocs-project/site ${s3Folder} ${dryrun} --delete --profile "$awsProfile"
	else
		# Figure out the Python installation path
		pythonExePath=$(py -c "import sys; print(sys.executable)")
		if [ -n "$pythonExePath" ]; then
			# Path will be something like:  C:\Users\sam\AppData\Local\Programs\Python\Python37\python.exe
			# - so strip off the exe and substitute Scripts
			# - convert the path to posix first
			pythonExePathPosix="/$(echo $pythonExePath | sed 's/\\/\//g' | sed 's/://')"
			pythonScriptsFolder="$(dirname $pythonExePathPosix)/Scripts"
			echo $pythonScriptsFolder
			$pythonScriptsFolder/aws s3 sync ../mkdocs-project/site ${s3Folder} ${dryrun} --delete --profile "$awsProfile"
		else
			echo "ERROR: Unable to find Python installation location to find 'aws' script"
			echo "ERROR: Make sure Python 3.x is installed on Windows so 'py' is available in PATH"
		fi
	fi
else
```
