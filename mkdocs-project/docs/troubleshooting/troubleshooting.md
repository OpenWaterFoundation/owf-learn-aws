# AWS / Troubleshooting

The following problems and solutions have been identified:

*   [`aws` Script not Working with Windows Git Bash](#aws-script-not-working-with-windows-git-bash)
*   [CloudFront/S3 website URLs do not return content](#cloudfronts3-website-urls-do-not-return-content)
*   [CloudFront invalidation complains about invalid path](#cloudfront-invalidation-complains-about-invalid-path)

-------

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

## CloudFront/S3 website URLs do not return content ##

Implementing a CloudFront distribution that provides access to content stored on S3 may have broken links.
If the content is a web application such as an Angular application, the application may not load and will show an empty page.
To troubleshoot, check the following:

1.  Confirm that the ***Origin Domain*** property for the CloudFront distribution includes the longer `website` URL,
    for example `poudre.openwaterfoundation.org.s3-website-us-west-2.amazonaws.com`.
    Note the `website` in this URL, which uses the longer resource name.
    See the articles below for more information.
2.  If the S3 bucket uses folders for versions of the web application, define a redirect.  [See documentation](../website/s3/redirect.md).
3.  Define a Lambda function to append `index.html` for folder-based URLs.  [See documentation](../cdn/cloudfront/lambda-to-append-index.md).

See the following for more information:

*   [Why S3 website redirect location is not followed by CloudFront?](https://serverfault.com/questions/450940/why-s3-website-redirect-location-is-not-followed-by-cloudfront)
*   [AWS Forum: Redirect not Working](https://forums.aws.amazon.com/message.jspa?messageID=907824)

=======

## General AWS Help ##

Resources that describe how to redirect to S3 subfolder using CloudFront. This is a fairly common
issue, as a true hierarchy does not exist in S3 as it does in CloudFront. Therefore requesting
subfolders when using CloudFront and S3 present problems, which as discussed in the links below.

*   https://stackoverflow.com/questions/49082709/redirect-to-index-html-for-s3-subfolder
*   https://serverfault.com/questions/450940/why-s3-website-redirect-location-is-not-followed-by-cloudfront
*   https://forums.aws.amazon.com/message.jspa?messageID=907824

## Cache key and origin requests help ##

This section presents to different radio buttons, **Cache policy and origin request policy (recommended)**,
and **Legacy cache settings**, with the former being the default choice.

The default choice should be the used. The main reason this section exists is to describe exactly
what's going on here in case a future developer gets as confused as the writer of this section.
The **Cache policy** and **Origin request policy - *optional***
choices above are actually connected to the default choice, even though they look
like they belong to **Legacy cache settings**. The following image shows the default choices,
which are desired.

**<p style="text-align: center;">
![cloudfront-1](images/cloudfront-cache-key-default.png)
</p>**

This image displays the actual Legacy options, which is not desired.

**<p style="text-align: center;">
![cloudfront-1](images/cloudfront-cache-key-legacy.png)
</p>**

## CloudFront invalidation complains about invalid path ##

A typical command to invalidate an `index.html` file, for example a dataset landing page, is as follows
(the distribution ID has been obfuscated).
Variations on the path must be invalidated to make sure that CloudFront does not cache content
associated with the URLs.

```
aws cloudfront create-invalidation --debug --distribution-id xxxxxxxxxxxxx --paths '/test/test1/index.html' --profile default
aws cloudfront create-invalidation --debug --distribution-id xxxxxxxxxxxxx --paths '/test/test1/' --profile default
aws cloudfront create-invalidation --debug --distribution-id xxxxxxxxxxxxx --paths '/test/test1' --profile default
```

The above commands may output an error similar to the following:

```
An error occurred (InvalidArgument) when calling the CreateInvalidation operation: Your request contains one or more invalid invalidation paths.
```

The above has been seen when using Git Bash to run a script on Windows, which uses the Windows `aws` CLI.
The reason is that the underlying MinGW (Minimalist GNU for Windows) environment attempts to convert paths into a notation for the environment.
In this case the path is actually for the cloud and not a local file and a warning results.
The problem can be understood better by using the `aws --debug` command parameter and reviewing the parsed command parameters in debug output.

The solution is described in a [Stack Overflow article](https://stackoverflow.com/questions/53706672/windows-git-bash-tries-to-resolve-string-as-file-when-calling-aws-cli).
The working command for the Bash shell is as follows, which temporarily turns off the path conversion:

```
MSYS_NO_PATHCONV=1 aws cloudfront create-invalidation --debug --distribution-id xxxxxxxxxxxxx --paths '/test/test1/index.html' --profile default
```

Another solution that worked is to use two `//` at the beginning of the path.
This may be necessary if the command being run mixes local file paths and cloud paths.

The following path with a wildcard does not generate a warning,
presumably because MinGW does not recognize it as a valid path due to the wildcard.

```
aws cloudfront create-invalidation --debug --distribution-id xxxxxxxxxxxxx --paths '/test/test1/index.html*' --profile default
```
