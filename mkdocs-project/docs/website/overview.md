# AWS / Website / Overview #

This documentation provides information about implementing websites using AWS.

*   [Introduction](#introduction)
*   [Implementing a Website using S3](#implementing-a-website-using-s3)
*   [Implementing a Website Using CloudFront](#implementing-a-website-using-cloudfront)

---------------

## Introduction ##

AWS can be used to to implement a website using a range of solutions from basic website to
a content delivery network (CDN) that scales to provide high performance,

This documentation provides guidance on options that can be used to implement a website.
More detailed documentation about specific topics is available in other pages.

## Implementing a Website Using S3 ##

Amazon S3 can be used to implement a website using the following options:

*   [S3 / Hosting a Public Static Website on S3](s3/s3.md) - requires only S3
*   [S3 / Hosting a Private Static Website on S3](s3/s3.md#hosting-a-private-static-website-on-s3) - requires S3 and CloudFront

## Implementing a Website Using CloudFront ##

AWS CloudFront can be used to implement a high-performing CDN,
which allows authentication, `https`, and replicated servers.
See the following:

*   [AWS / CDN / CloudFront](../cdn/cloudfront/cloudfront.md)
