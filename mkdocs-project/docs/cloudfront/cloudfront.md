# AWS / Cloudfront #

This documentation explains how to use AWS CloudFront.

* [Introduction](#introduction)

---------------

## Introduction ##

CloudFront is used to configure and maintain a content delivery network (CDN).
For example, a read-only, authenticated website can be implemented that provides
access to [S3 storage](../s3/s3.md) files.

The hierarchy of services is as follows:

```
CloudFront
  uses: S3
```
