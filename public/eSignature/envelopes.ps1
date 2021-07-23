#Envelope functions

function Get-Envelopes() {
    Param (
        [Parameter(
            Mandatory = $true
        )]
        [DateTime]$fromDate
    )

    $accountId = Get-ApiAccountId
    $Uri = "{0}/v2.1/accounts/{1}/envelopes" -f $apiUri, $accountID
    $Headers = Get-Headers

    $body = @{ "from_date" = ${fromDate} }

    $response = Invoke-RestMethod -Uri $Uri -Method GET -Headers $Headers -Body $body

    return $response.envelopes
}

function Get-EnvelopeInfo() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipelineByPropertyName = $true,
            ValueFromPipeline = $true
        )]
        [string]$envelopeId
    )
    Begin {
        $accountId = Get-ApiAccountId        

        $Headers = Get-Headers
    }

    Process {

        $Uri = "{0}/v2.1/accounts/{1}/envelopes/{2}" -f $apiUri, $accountId, $envelopId

        $response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers

        return $response

    }
}

function Get-EnvelopeResipients() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$envelopeId
    )

    Begin {
        $accountId = Get-ApiAccountId

        $Headers = Get-Headers
    }

    Process {
        $Uri = "{0}/v2.1/accounts/{1}/envelopes/{2}/recipients" -f $apiUri, $accountId, $envelopeId

        $response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers

        return $response
    }    
}

function Show-EnvelopeDocuments() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$envelopeId
    )

    Begin {
        $accountId = Get-ApiAccountId

        $Headers = Get-Headers
    }

    Process {
        $Uri = "{0}/v2.1/accounts/{1}/envelopes/{2}/documents" -f $apiUri, $accountId, $envelopeId

        $response = Invoke-RestMethod -Uri $Uri -Method GET -Headers $Headers
    
        return $response
    }
}

function Get-EnvelopeDocuments() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true
        )]
        [string]$envelopeId,
        [Parameter(
            Mandatory = $true
        )]
        [listDocs]$listDocsView,
        [Parameter(
            Mandatory = $true
        )]
        [string]$outputFile
    )
    $accountId = Get-ApiAccountId

    $headers = Get-Headers

    $outputFileExtension = 'pdf'

    $docChoice = "1"

    if ($listDocsView -eq [listDocs]::CertificateOfCompletion) {
        $docChoice = "certificate"
    }
    elseif ($listDocsView -eq [listDocs]::DocumentsCombinedTogether) {
        $docChoice = "combined"
    }
    elseif ($listDocsView -eq [listDocs]::ZIPFile) {
        $docChoice = "archive"
        $outputFileExtension = "zip"
    }
    else {
        $docChoice = $listDocsView
    }
    
    
    $Uri = "{0}/v2.1/accounts/{1}/envelopes/{2}/documents/{3}" -f $apiUri, $accountId, $envelopeId, $docChoice

    Invoke-RestMethod -uri $Uri -Method GET -Headers $headers -OutFile ${$outputFile}${outputFileExtension}

    Write-Output "The document(s) are stored in file ${outputFile}${outputFileExtension}"
}

