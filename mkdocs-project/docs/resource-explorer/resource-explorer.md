# AWS / Resource Explorer #

This documentation provides an overview of the AWS ***Resource Explorer***.

*   [Introduction](#introduction)
*   [Activating Resource Explorer](##Activating-resource-explorer)

---------------

## Introduction ##

The AWS ***Resource Explorer*** is a free interactive tool that allows AWS resources
to be searched and discovered across accounts and regions.
For example, use to identify untagged services so that tags can be added for cost tracking.

See the [AWS Resource Explorer](https://resource-explorer.console.aws.amazon.com/resource-explorer/home) web page.

## Activating Resource Explorer ##

The ***Resource Explorer*** is a free tool but does require activation.
An administrator for the AWS account in an organization should turn on,
for example with the following settings:

*   ***Enable multi-account resource search***:
    +   The setup tool will prompt and this may not be needed if using a single account.
*   ***Quick setup*** or ***Advanced setup***:
    +   Quick setup may be sufficient.
*   ***Aggregator index Region***:
    +   Indicates the region where aggregated ***Resource Explorer*** data will live
        and should be the region closest to the organization.

Once settings are specified use ***Turn on Resource Explorer*** to activate.
Resource indices will be quickly be created for all regions.
