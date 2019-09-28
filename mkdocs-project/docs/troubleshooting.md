# AWS / Troubleshooting

# `aws` Script not Working with Windows Git Bash ##

The `aws` script is typically installed in the `Scripts` folder of Python.
The first line of the script indicates the Python to run.
If Python is installed in the main system location, the line may look like the following:

```
#!c:\program files\python35\python.exe
```

Trying to run `aws` from Git Bash may display a warning similar to the following:

```
./copy-to-owf-amazon-s3.sh: /c/Program Files/Python35/Scripts/aws: 'c:\program: bad interpreter: No such file or directory
```

This occurs because of the space in the path.  A work-around is to edit the `aws` script and change to old-style path notation without a space:
```
#!c:\progra~1\python35\python.exe
```

The above will not impact running `aws` with Cygwin if a separate Cygwin copy of Python has been installed.
Another work-around would be to create a symbolic link `ProgramFiles -> Program Files` and change the script to use `ProgramFiles` in the path.
