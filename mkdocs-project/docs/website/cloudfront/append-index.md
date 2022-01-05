# Website / Append `index.html` to URL

* [Introduction](#introduction)
* [Append `index.html` to URL](#append-indexhtml-to-url)

--------------

## Introduction ##

Many websites that use S3 content with CloudFront CDN use a convention that
if the URL is specified as a folder without a trailing `/`,
an `index.html` file should be returned by default.
The `index.html` file exists, but the goal is that `index.html`
should not need to be explicitly included in the URL.

Implementing a website using CloudFront requires implementing a solution
to append `index.html` to URLs if not explicitly included in the URL.
This allows any of the following variations of the URL to be requested:

* `https://domain/somefolder`
* `https://domain/somefolder/`
* `https://domain/somefolder/index.html`

Implementing a solution allows folder-based URLs to be used rather than
more explicit but uglier URLs that end in `index.html`.

## Append `index.html` to URL

A solution that has been demonstrated to work
involves defining an AWS Lambda function for the CloudFront distribution.
The function modifies the requested URL and appends `index.html` if it is not already included in the URL.

See the [CloudFront documentation](https://learn.openwaterfoundation.org/owf-learn-aws/cdn/cloudfront/cloudfront/#set-indexhtml-as-the-default-for-all-folders)
for a working example.

Note that attempting to use a CloudFront function as the solution does not provide enough capabilities
and therefore a Lambda function is required.
