# AWS / APIs and SDKs / Overview #

This documentation provides useful information about
AWS Application Development Interfaces (APIs)
and Standard Development Kits (SDKs).

*   [Introduction](#introduction)
*   [REST APIs](#rest-apis)
*   [Standard Development Kits (SDKs)](#standard-development-kits-sdks)
    +   [S3 Java SDK](#s3-java-sdk)

---------------

## Introduction ##

Specific AWS component services can be accessed and integrated with systems and software using various technologies:

*   The [AWS CLI](../cli/cli.md) can execute AWS commands on the command line and can be run from scripts.
*   The AWS Console dashboards can be used to interactively run services,
    for example to upload files to S3 storage or create CloudFront invalidations.
*   REST webs service APIs can be used to integrate AWS with software.
    APIs are used by Amazon's own CLI and AWS Console.

This documentation focuses on using the APIs.

## REST APIs ##

AWS provides REST APIs for many services to allow software to programmatically interface
with services.
For example, see the [Amazon S3 REST API Introduction](https://docs.aws.amazon.com/AmazonS3/latest/API/Welcome.html).
However, the services are complicated and can be difficult to use directly,
in particular when dealing with authentication.

To facilitate use of REST APIs and services, Amazon provides client-side libraries that can be used with
various programming languages.
See the next section.

## Standard Development Kits (SDKs) ##

Standard Development Kits (SDKs) are provided by Amazon for common programming languages,
including Python, Java, .NET, and JavaScript.
The SDKs provide client-side application libraries that interface with REST APIs.
Consequently, application code uses the libraries in the programming language rather than
making direct calls to REST web services.
The SDKs are extensive but documentation is often terse and examples beyond basic examples may be difficult to find.
SDK documentation can be found by searching for the service and language.

SDK versions are updated periodically and may or may not be consistent between SDKs and services.
Implementing a solution can be complicated by documentation and examples for old SDK versions that are no longer relevant.
Consequently, using the SDKs requires patience and internet searches to find suitable examples that can be adapted.

This documentation will be expanded over time to include information about SDKs based on lessons learned.

### S3 Java SDK ###

*   See the [S3 Java SDK](s3-java/s3-java.md)
