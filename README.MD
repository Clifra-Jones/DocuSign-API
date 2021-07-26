# Docusign API Powershell Module

Copyright 2021, Balfour Beatty US.

Currenly this only encompasses Authorization and the Envelope functionality.

Powershell Version: Powershell Core 6.0 or higher. Functionality may work in Windows PowerShell 5.4 but is not gauranteed.

## Installation:
User profile installation is recomended.

### User profile

First find your user module folder by examining the PSModulePath veriable
>$env:PSModulePath

The change directory to the powershell module folder in your user profile and issue a git clone.
>git clone https://github.com/Clifra-Jones/DocuSign-API.git

## Setup
You must have a Docusign Developer account in order to use this module.

You must log into Docusign Developer site go to Apps and Keys and create an application to use this module.
Withing that application create a secret key (copy the secret key before saving or you will not be able to copy later)
You will need your User GUID, Integration Key and Secret Key

Prior to using any of the other function you must create your settings file by running the Set-APIKey function.
>Set-API

You will be prompted for you User GUID, Integration Key and the Secret Key. Enter each when prompted, this will create a file called settings.json in a folder called .Docusign in you user profile folder.

## Initial Authorization
You must have an Authorization code to execute any of the Envelope finctions.
To get an authorization code execute:
>Request-CodeGrantAuthorization -APIVersion 'eSignature'
You can also utilize the built in class to retrive the API version.
>Request-CodeGrantAuthorization -APIVersion ([APIVersions]::eSignature)
(The parenthasis are required.)
You will  be prompted to log inot the docusign web site.
This will save your authorization code, a refresh token, your Account ID and the expiration date of the authorization code in the .Docusign folder.
NOTE: By default the Authorization token is only valid for 8 hours. 
You can request an extended token that will be valid for 30 days by using the -extended parameter
>Request-CodeGrantAuthorization -APIversion 'eSignature' -extended

If the token has expired or will expire within the next 2 hours a new authorization token will be requested using the stored refresh token. 
The user will not be required to log in to receive this new token.

##Envelope functions
Most of these function are based on envelopes. Envelopes are how Docusign stores and references Documents.
To retrieve envelopes use the Get-Envelopes function
>Get-Envelopes -fromDate [datetime]
The -fromDate should be a date object sime time prior to the current date. To retrieve envelopes for the last 10 dates issue:
>Get-Envelopes -fromDate (Get-Date).AddDate(-10)
It is a best practice to store envelopes in a variable because you will need them later and avoid unnecessar piping.
To only retrieve completed envelopes do the following:
>$envelopes = Get-Envelopes -fromDate (Get-Date).AddDays(-2) | Where-Object {$_.Status -eq ([EnvelopeStatus]::completed)}

To get more detailed information on an envelope use the Get-EnvelopeInfo function.
To get info on al lthe envelopes you retrieved previously use:
>$envelopes | Get-EnvelopeInfo
To get a single envelope you can use either:
>$envelope[0] | Get-EnvelopeInfo
or
>Get-EnvelopeInfo -envelopeId $envelopes[0].envelopeId





