# Website / Append `index.html` to URL

* [Introduction](#introduction)
* [Append `index.html` to URL](#append-indexhtml-to-url)
* [Current production Lambda function](#current-production-lambda-function)

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

The following articles provide background on this issue:

* [Stack Overflow: Redirect to index.html for S3 subfolder](https://stackoverflow.com/questions/49082709/redirect-to-index-html-for-s3-subfolder) - appending `index.html` to folder URLs

## Append `index.html` to URL

A solution that has been demonstrated to work
involves defining an AWS Lambda function for the CloudFront distribution.
The function modifies the requested URL and appends `index.html` if it is not already included in the URL.

An example of an older version of the Lambda function can be found in the
[CloudFront documentation](https://learn.openwaterfoundation.org/owf-learn-aws/cdn/cloudfront/cloudfront/#set-indexhtml-as-the-default-for-all-folders).
The Lambda function currently used in production can be found below.

Note that attempting to use a CloudFront function or the answer to the Stack
Overflow answer from above as the solution does not provide enough capabilities
and therefore a Lambda function is required. Keep in mind that these might be enough
to solve other issues when dealing with non Single Page Applications.

## Current production Lambda function ##

The newest version of the Lambda function performs the following three tasks:

* Resolves a S3 & Cloudfront issue when a URL with a subfolder is requested.
* Determines whether a URL ends in a versioned or latest folder and correctly appends
either `index.html` or `/index.html` to it.
* Returns a 200 OK response along with the changes from the previous two items so
Single Page Application functionality is maintained.

The code uses the `Node.js 16.x` runtime and is as follows:

```javascript
/**
 * This CloudFrontUrlHandler_SPA_TopLevelWithVersions lambda function deals with
 * server side routing for top-level Single Page Applications so the correct
 * path is displayed.
 * 
 * This function performs three major tasks:
 * 
 * 1. Intercepts a 403 or 404 error when a file in a subfolder is requested.
 *    This is because subfolders in S3 don't exist. More information can be found in
 *    this blog where the basis for this function's code was found:
 * 
 *    https://andrewlock.net/using-lambda-at-edge-to-handle-angular-client-side-routing-with-s3-and-cloudfront/
 * 
 * 2. Determines what the version is ('latest', '3.0.0') of the SPA in the URI,
 *    and if the request does not end in a file, makes a request back to the
 *    origin (S3) server for the SPA's index.html page. For example '/latest/index.html'
 *    or '/4.1.0/index.html'. If the request does end in a fileIn this case the URI is not changed.
 * 
 * 3. Returns a 200 OK response to the CloudFront server from the origin (S3) server.
 */

// For the HTTPS Node.js module for using HTTP protocol over TLS/SSL.
const http = require('https');

/**
 * 
 */
exports.handler = async (event, context, callback) => {
    /**
     * The following constants and variables are objects and strings obtained
     * from the origin-response object.
     * 
     * cf: The main CloudFront object that contains the config, request, and response objects.
     * request: The entire incoming request object.
     * uri: The incoming URI in the request, e.g. /0.7.0.dev.
     * host: The host being requested, e.g. poudre.openwaterfoundation.org.
     * response: The entire response object.
     * statusCode: The status of the resonse, e.g. 200.
     * indexPage: The new URI to be appended to the domain request.
     */
    const cf = event.Records[0].cf;
    const request = cf.request;
    var uri = request.uri;
    const host = request.headers.host[0].value;
    const response = cf.response;
    const statusCode = response.status;
    var indexPage = '';
    
    console.log('Initial request object:', request);
    console.log('Initial URI:           ', uri);

    // Determine whether to perform the replacement in the uri. Only perform if
    // the response is a 403 or 404 error. This is a CloudFront/S3 issue with subfolders.
    var doReplace = (request.method === 'GET') && ((statusCode == '403') || (statusCode == '404'));
    
    // Check for the pattern that matches a versioned file, including:
    //   /some/path/1.4.5
    //   /some/path/1.4.5/
    //   /some/path/1.4.5.dev
    //   /some/path/1.4.5.dev/
    // Regular expression to match a version at the end:
    // - see:  https://developer.mozilla.org/en-US/docs/Web/JavaScript/Guide/Regular_Expressions/Quantifiers
    // - regular expressions are similar to linux 'sed'
    // - * at the front is apparently not required
    //                        +---- start of regular expression
    //                        | +---- match a literal slash
    //                        | |  +---- match a digit
    //                        | |  |  +---- match preceding item (a digit) 1 or more times
    //                        | |  |  | +---- match a literal decimal point
    //                        | |  |  | |  +---- match second digit in semantic version
    //                        | |  |  | |  |       +---- match third digit in semantic version
    //                        | |  |  | |  |       |     +---- match the preceding item 0 or 1 times to support a 4th version part
    //                        | |  |  | |  |       |     |     must use a "0 or 1" match
    //                        | |  |  | |  |       |     |  +---- this sequence matches a lowercase letter, uppercase letter, or digit
    //                        | |  |  | |  |       |     |  |          +---- match the preceding character 0 or more times
    //                        | |  |  | |  |       |     |  |          |  +---- match 0 or 1 slash at the end (so trailing slash or not)
    //                        | |  |  | |  |       |     |  |          |  |
    //                        | |  |  | |  |       |     |  |          |  |+---- end of regular expression (no trailing 'g' so must match exactly)
    //                        | |  |  | |  |       |     |  |          |  ||
    //                        v v  v  v v  v       v     v  v          v  vv
    const versionExpression = /\/[0-9]+\.[0-9]+\.[0-9]+\.?([a-zA-Z0-9])*\/?/;
    // Is set to true if the uri matches the versionExpression, false if not.
    const hasVersion = versionExpression.test(uri);
    // Also test for file at the end that has an extension:
    // - must not end in /
    // - includes . in the file
    //                             +---- main part of filename can contain characters and digits
    //                             |            + required period to separate file and extension
    //                             |            |  +---- file extension can contain characters and digits
    //                             |            |  |           +---- match the end of string (don't allow match in the middle of the string)
    //                             |            |  |           |     No trailing slash.
    //                             v            v  v           v
    const fileAtEndExpression = /([a-zA-Z0-9])*\.([a-zA-Z0-9])*$/;
    // True if the uri matches the versionExpression, false if not.
    const fileAtEnd = fileAtEndExpression.test(uri);

    if (hasVersion) {
        var version = uri.split('/')[1];
        indexPage = `/${version}/index.html`;
    }
    else if (uri.includes('/latest')) {
        indexPage = '/latest/index.html';
    }
    else if (fileAtEnd) {
        // URI does not have version at the end but does seem to end in a file name.
        // Use the URI as is.
        indexPage = uri;
        doReplace = false;
    }
    else if (uri.endsWith('/')) {
        // A folder is at the end of the URL with trailing /, so just append index.html.
        indexPage = uri + 'index.html';
    }
    else {
        // A folder is at the end of the URL without trailing /, so just append /index.html.
        indexPage = uri + '/index.html';
    }
    // For debugging and testing. Will print when locally tested using the built
    // in testing for Lambda functions, and will also be printed in a Log Group
    // in CloudWatch.
    console.log('cf object:           ', cf);
    console.log('response status:     ', response.status);
    console.log('response description:', response.statusDescription);
    console.log('uri:                 ', uri);
    console.log('host:                ', host);
    console.log('domain:              ', cf.config.distributionDomainName);
    console.log('indexPage:           ', indexPage);
    console.log('doReplace:           ', doReplace);

    const result = doReplace
        ? await generateResponseAndLog(cf, request, indexPage, response.headers)
        : response;

    callback(null, result);
};

/**
 * 
 */
async function generateResponseAndLog(cf, request, indexPage, headers) {
    const domain = cf.config.distributionDomainName;
    const response = await generateResponse(domain, indexPage, headers);

    return response;
}

/**
 * 
 */
async function generateResponse(domain, path, headers) {
    try {
        // load HTML index from the CloudFront cache
        const s3Response = await httpGet({ hostname: domain, path: path });

        const outHeaders = {};

        // https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-requirements-limits.html
        for (var propName in headers) {
            var header = headers[propName];

            if ((propName === "transfer-encoding") || (propName === "via")) {
                // just here to make sure we don't change the read-onlys
            }
            else if (s3Response.headers[propName] != null) {
                header = s3Response.headers[propName];
            }

            if (Array.isArray(header)) {
                outHeaders[propName] = header;
            }
            else {
                outHeaders[propName] = [{ value: header }];
            }
        }
        
        return {
            status: '200',
            headers: outHeaders,
            body: s3Response.body
        };
    } catch (error) {
        return {
            status: '500',
            headers: {
                'content-type': [{ value: 'text/plain' }]
            },
            body: 'An error occurred loading the page'
        };
    }
}

/**
 * 
 */
function httpGet(params) {
    return new Promise((resolve, reject) => {
        http.get(params, (resp) => {
            console.log(`Fetching ${params.hostname}${params.path}, status code: ${resp.statusCode}`);
            let result = {
                headers: resp.headers,
                body: ''
            };
            resp.on('data', (chunk) => { result.body += chunk; });
            resp.on('end', () => { resolve(result); });
        }).on('error', (err) => {
            console.log(`Couldn't fetch ${params.hostname}${params.path} : ${err.message}`);
            reject(err, null);
        });
    });
}
```