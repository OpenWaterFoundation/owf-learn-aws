# AWS / CDN / CloudFront #

This documentation explains how to use AWS CloudFront to create a private,
authenticated content delivery network (CDN).

* [Introduction](#introduction)
* [Public Website](#public-website)
    + [Public website using an S3 bucket public static website](#public-website-using-an-s3-bucket-public-static-website)
    + [Public website using an S3 bucket folder as public static website](#public-website-using-an-S3-bucket-folder-as-public-static-website)
* [Authenticated Website](#authenticated-website)
    + [Authenticated website using a private S3 bucket and AWS Lambda Function](#authenticated-website-using-a-private-s3-bucket-and-lambda-function)
    + [Authenticated website using a private S3 bucket and Signed URLs and Signed Cookies](#authenticated-website-using-a-private-s3-bucket-and-signed-urls-and-signed-cookies)
* [CloudFront Distribution Configuration](#cloudfront-distribution-configuration)
* [Additional CloudFront Website Configuration](#additional-cloudfront-website-configuration)
    + [Custom Error Response](#custom-error-response)
    + [Add `favicon.ico` File](#add-faviconico-file)
    + [Set `index.html` as the Default for all Folders](#set-indexhtml-as-the-default-for-all-folders)
* [Troubleshooting](#troubleshooting)

---------------

## Introduction ##

CloudFront is used to configure and maintain a content delivery network (CDN).
For example, a read-only, authenticated website can be implemented that provides
access to [S3 storage](../../storage/s3/s3.md) files.
The S3 files can be managed using command line interface and other tools.
A CDN front end to the files is helpful when the amount of files is large and continues to grow over time.

The following are cases where CloudFront could be used.
**Currently this documentation focuses on experients with CloudFront, not authoritative documentation.
If experiments work, then this documentation will evolve into a reference to streamline future configurations.**
The following are questions to answer, with the primary goal being to provide an authenticated `https` website using
S3 bucket for content.

1. How to use CloudFront to provide authentication and `https` for an S3 bucket that is otherwise private,
using a general login.
2. How to use CloudFront to provide authentication and `https` for an S3 bucket that is otherwise private,
using multiple logins, with access granted to specific folders in the bucket.

In all cases, it is desirable that:

* DNS alias maps to a "nice" URL
* the website behaves similar to S3 static website, with ability to automate uploads and access the site
via web browser and programatically via command line interface (CLI)

## Public Website ##

It is often necessary to implement a public website, for example for public static content.
One option is to use an [S3 public static website](../../storage/s3/s3.md#hosting-a-public-static-website-on-s3).
However, adding a CloudFront service on top of the S3 public website provides additional
functionality such as distribution to regional servers, optimizing caching, and use of `https`.
The following sections describe how to use CloudFront with S3.

### Public website using an S3 bucket public static website ###

A public static website can be implemented using CloudFront and an S3 bucket that has been configured
as a public static website.

* See the [AWS / CloudFront / Public Static Website using S3 Bucket](public-s3-bucket.md) documentation.

### Public website using an S3 bucket folder as public static website ###

## Authenticated Website ##

It is often necessary to implement an authenticated website for private content.
Using AWS S3 by itself does not support authentication (for example authentication on a public static website).
One option is to use a cloud virtual machine, such as AWS EC2, with a web server such as Apache.
However, using a VM is more costly.
The options described below use CloudFront to implement an authenticated website,
with private S3 bucket providing the content.

### Authenticated website using a private S3 bucket and Lambda Function ###

Authentication for a Cloudfront distribution can be implemented using a Lambda function.
This simple approach is appropriate in cases where one or a small number of users needs
to access content.

* See the [AWS / CloudFront / Authentication Using Lambda Function](private-auth-lambda.md) documentation.

### Authenticated website using a private S3 bucket and Signed URLs and Signed Cookies ###

This documentation needs to be completed.  Using a Lambda function for authentication was the first example to be documented.

## CloudFront Distribution Configuration ##

Additional configuration is often needed after a distribution has been created,
as described below.

See also the next section, which focuses on website content.

### Change TTL ###

It may be useful to change the ***TTL*** values during development and testing of distributions.
For example, set the values to 0 to delegate caching to the origin.
Therefore, changing the original content should cause that content to be used for subsequent CloudFront requests.
However, there may be latency and it may still be required to invalidate CloudFront content.

## Additional CloudFront Website Configuration ##

Additional website configuration is likely needed after a distribution is configured and initial website content deployed.
Specific issues are discussed below.
Some of these issues, if not resolved, may severely limit effective use of a CloudFront website.

### Custom Error Response ###

The initial setup did not prompt for an error page.  To define, edit the distribution properties and then ***Error Pages***.
Use the ***Create Custom Error Response*** button to edit.
The HTTP error codes generated by CloudFront can be mapped to a specified error page.
The following indicates that a general error page should be used.
Specific pages can be defined for each error code, such as `400-error.html` or `400.html`.

**<p style="text-align: center;">
![cloudfront-error-page](images/cloudfront-error-page.png)
</p>**

**<p style="text-align: center;">
CloudFront Custom Error Response Setting (<a href="../images/cloudfront-error-page.png">see full-size image</a>)
</p>**


### Add `favicon.ico` File ###

A CloudFront website request may attempt to find a `favicon.ico` file in the root folder.
Failing to find the file will generate a 403 error, which can be seen in the web browser console.
Therefore, upload an appropriate `favicon.ico` file to eliminate this error.
If necessary, use software such as [`Gimp`](https://www.gimp.org/) to convert an image file to `ico` format.

### Set `index.html` as the Default for all Folders ###

See the [CloudFront Lambda Function to Append `index.html` to URL](lambda-to-append-index.md) documentation.

## Troubleshooting ##

This section provides troubleshooting information.

### Use `curl` to Access Content ###

The `curl` program can be used to query public and private web content.
For example, use the following to query public content and display verbose output,
which includes HTTP response headings.

```
curl -v https://something.cloudfront.net/test-folder/index.html
```

Use the `-u` option to specify the user and prompt for password for a site with authentication.

```
curl -v https://something.cloudfront.net/test-folder/index.html -u someuser
```
