#Envelope functions

function Get-Envelopes() {
    Param (
        [Parameter(
            Mandatory = $true
        )]
        [DateTime]$fromDate
    )

    #$accountId = Get-ApiAccountId
    #$Uri = "{0}/v2.1/accounts/{1}/envelopes" -f $apiUri, $accountID
    $Uri = "{0}/envelopes" -f $apiUri
    $Headers = Get-Headers

    $sFromDate = $fromDate.ToString("yyyy-MM-ddThh:mm:ssK")

    $body = @{ "from_date" = ${sFromDate} }

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

        $Headers = Get-Headers
    }

    Process {

        $Uri = "{0}/envelopes/{1}" -f $apiUri, $envelopeId

        $response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers

        return $response

    }
}

function Get-EnvelopeRecipients() {
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

        $Headers = Get-Headers
    }

    Process {
        $Uri = "{0}/envelopes/{1}/recipients" -f $apiUri, $envelopeId

        $response = Invoke-RestMethod -Uri $Uri -Method Get -Headers $Headers

        return $response
    }    
}

function Select-EnvelopeDocuments() {
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

        $Headers = Get-Headers
    }

    Process {
        $Uri = "{0}/envelopes/{1}/documents" -f $apiUri, $envelopeId

        $response = Invoke-RestMethod -Uri $Uri -Method GET -Headers $Headers
    
        return $response
    }
}

function Get-EnvelopeDocuments() {
    [CmdletBinding()]
    Param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [string]$envelopeId,
        [Parameter(
            Mandatory = $true
        )]
        [string]$listDocsView,
        [string]$outputFile,
        [string]$outputFolder
    )
    
    Begin {

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
    }

    Process {
        if ($docChoice -eq [listDocs]::SeparateFiles) {
            $documents = (Select-EnvelopeDocuments -envelopeId $envelopeId).envelopeDocuments
            foreach ($document in $documents) {
                $documentId = $document.documentId
                $outputFile = $document.Name
                $outputFilePath = "{0}/{1}.{2}" -f $outputFolder, $outputFile, $outputFileExtension
                $Uri = "{0}/envelopes/{1}/documents/{2}" -f $apiUri, $envelopeId, $documentId
                Invoke-RestMethod -Uri $Uri -Method GET -Headers $headers -OutFile $outputFilePath
                Write-Output "The document is stored in file $outputFilePath."
            }
        } elseif ($docChoice -match '\d') {
            $document = ((Select-EnvelopeDocuments -envelopeId $envelopeId).envelopeDocuments).where({$_.documentId -eq $docChoice})
            $DocumentId = $document.documentId
            $outputFile = $document.Name
            $outputFilePath = "{0}/{1}.{2}" -f $outputFolder, $outputFile, $outputFileExtension
            $Uri = "{0}/envelopes/{1}/documents/{2}" -f $apiUri, $envelopeId, $documentId
            Invoke-RestMethod -Uri $Uri -Method GET -Headers $headers -OutFile $outputFilePath
            Write-Output "The document was stored in file $outputFilePath"
        } else {
            If (-not ($outputFile)) {
                Write-Output "Supply value for the following parameter:"
                $outputFile = Read-Host -Prompt 'outputFile: '
            }
            $Uri = "{0}/envelopes/{1}/documents/{2}" -f $apiUri, $envelopeId, $docChoice

            Invoke-RestMethod -uri $Uri -Method GET -Headers $headers -OutFile ${$outputFile}${outputFileExtension}

            Write-Output "The document(s) are stored in file ${outputFile}${outputFileExtension}"
        
        }
    }
}