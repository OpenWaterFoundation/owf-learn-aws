# AWS / CDN / Overview #

This documentation provides an overview of
content delivery network (CDN) concepts and describes solutions for common requirements.

* [Introduction](#introduction)
	+ [Distributed Services](#distributed-services)
	+ [Caching Content](#caching-content)
* [Implementing a CDN Using S3](#implementing-a-cdn-using-s3)
* [Implementing a CDN Using CloudFront](#implementing-a-cdn-using-cloudfront)

---------------

## Introduction ##

A content delivery network (CDN) is internet infrastructure and cloud services that 
provide access to web content.
See [Content Delivery Network on Wikipedia](https://en.wikipedia.org/wiki/Content_delivery_network).

A CDN can be used for read-only content that just needs to be served,
including documentation, data, and web applications.
Read-only services correspond to the "R" in "CRUD" (create/read/updated/write).
See ["Create, read, update and delete on Wikipedia](https://en.wikipedia.org/wiki/Create,_read,_update_and_delete).

A CDN also can serve content that contains links to create/update/delete functionality,
for example data entry, documentation authoring, purchasing, etc.
Web applications served as static content from a CDN can use web addresses that access static content.
Other web addresses in the static content provide access to web services that handle create/update/write functionality.

For the purpose of this documentation and the examples shown, the
discussion focuses on static, read-only content that can be accessed from a web browser.
The content for such sites can be uploaded using tools that have write capabilities,
such as [AWS command line interface (CLI)](../cli/cli.md).

### Distributed Services ###

To optimize performance, AWS provides services that distribute a CDN's content across the internet.
For example, a business with world-wide operations might want content for a website
to be available from multiple regional servers in order to provide the fastest service.
If the CDN provides access to web applications that accept orders,
the information must be synchronized consistent with the businesses' physical infrastructure,
which might be complex.  For this documentation,
the focus is on read-only content that is served to web browser and other data-consuming applications.
In this case, the mechanics of the CDN can be thought of as distributing the content from
the initial upload site to the regional servers for read-only access.

AWS uses regions to define service configurations and provide services.
Regions are locations for physical data centers.
See AWS [Regions and Availability Zones](https://aws.amazon.com/about-aws/global-infrastructure/regions_az/).

AWS also uses "Edge" locations to further distribute content.
For example see [Amazon CloudFront Key Features](https://aws.amazon.com/cloudfront/features/?p=ugi&l=na),
which lists edge locations for AWS CloudFront.
Services such as Lambda@Edge clearly utilize this capability.

### Caching Content ###

Once data are uploaded to the CDN, the CDN infrastructure distributes the content to regional servers.
A key component of a CDN is caching.
For example, when an address is entered into a web browser,
the web browser contacts the associated web server and asks for content.
If the content has not been accessed "recently" (or has never been accessed),
the CDN accesses the "origin content" and returns it to the browser.
The CDN assumes that another request may be made for the same content and caches the content,
meaning that it saves a copy of the content in a quickly-accessible location such as computer memory or fast disk access.
If another request is made, the content is quickly returned from the cache instead of doing a full retrieval.
The CDN's performance can therefore be optimized to serve often-requested content from the cache.

Caching requires that resources have unique identifiers (for web content, the URL) and an expiration,
which relates to what "recently" means.
A default expiration may be used, or can be set at a granular level.
Cache configuration and handling can be complex and should be evaluated using technical documentation for the software
components that are used.
A common issue is that new content is uploaded but is not visible because an older cached version is accessed.
This issue can be overcome in the CDN by "invalidating" the content, which forces the cached resources to be discarded.
For example, the `aws s3` command line can be used to upload content to S3 and an `aws cloudfront` command
can be used to invalidate the content so that it quickly propagates through the CloudFront cache.

The cache also can be "busted" by making sure that every resource has a new name,
for example by adding the publishing date/time, version number, or random numbers and strings.
The problem with busting the cache is that it can be difficult to add a unique identifier to all resources in a website.
Some web application development tools provide this ability and ensure that any internal references use the proper URLs.

Caching can be an issue because web browsers also maintain their own cache.
The cache busting technique typically works with browsers because new URLs are used,
assuming that the starting page (e.g., `index.html`) is not cached.
Doing a refresh sometimes helps, but may not.
It may be necessary to clear the cache in the web browser.

The following sections describe options for implementing a CDN to serve static content.
Again, if serving a web application as static content, the application can refer to other web addresses that are not static,
such as database servers.

## Implementing a CDN Using S3 ##

Amazon S3 can be used to implement a CDN, using the following options:

* [AWS / Storage / Hosting a Public Static Website on S3](../storage/s3/s3.md#hosting-a-public-static-website-on-s3) - requires only S3
* [AWS / Storage / Hosting a Private Static Website on S3](../storage/s3/s3.md#hosting-a-private-static-website-on-s3) - requires S3 and CloudFront

## Implementing a CDN Using CloudFront ##

AWS CloudFront is designed to implement a high-performing CDN.
See the following:

* [AWS / CDN / CloudFront](cloudfront/cloudfront.md)
