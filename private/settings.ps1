
#$script:apiUri = "https://demo.docusign.net/restapi"

function Get-Headers() {
    Param(
        [string]$contentType
    )

    $accessToken = Get-AccessToken
    $Headers = @{
        'Authorization' = "Bearer $accessToken"
    }
    if ($contentType) {
        $Headers.Add("Content-Type", $contentType)
    } else {
        $Headers.Add("Content-Type", "application/json")
    }

    return $Headers
}

function Get-Config() {
    $configPath = "$home/.Docusign/settings.json"
    if (-not (Test-Path $configPath)) {
        throw "Settings file not found. Use the Set-APIKeys function to create a settings file."
        exit
    }
    $config = Get-Content -Path $configPath -Raw | ConvertFrom-Json

    return $config
}

function Get-AccessToken() {
    $tokenPath = "$home/.Docusign/ds_access_token.txt"
    
    $DateString = Get-Content "$home/.Docusign/expiration_date.txt"
    $expirationDate = [DateTime]::FromFileTime($DateString)
    $currentDate = Get-Date

    if (($expirationDate - $currentDate).Hours -lt 2) {
        Request-CodeGrantRefresh
    }

    if (-not (Test-Path $tokenPath)) {
        Throw "Access Token file missing. Use the Request-CodeGrantAuthorization or the Request-JWTAuthorization to retrieve an access token."
        exit
    }
    $accessToken = Get-Content $tokenPath
    return $accessToken
}

function Get-RefreshToken() {
    $tokenPath = "$home/.Docusign/refresh_token.txt"
    if (-not (Test-Path $tokenPath)) {
        Throw "Refresh Token file missing. Use the Request-CodeGrantAuthorization or the Request-JWTAuthorization to retrieve an access token."
        exit
    }
    $refreshToken = Get-Content $tokenPath
    return $refreshToken
}

function Get-ApiAccountId() {
    $accountIdPath = "$home/.Docusign/API_ACCOUNT_ID"
    if (-not (Test-Path $accountIdPath)) {
        Throw "API Account ID file not found. Use the Request-CodeGrantAuthorization or the Request-JWTAuthorization to retrieve an access token."
        exit
    }
    $ApiAccountId = Get-Content "$home/.Docusign/API_ACCOUNT_ID"
    return $ApiAccountId
}

function Request-UserInfo() {
    try {
        #get user info
        $userInfoFile = "$home/.Docusign/userinfo.json"
        $headers = Get-Headers
        $URI = "https://account-d.docusign.com/oauth/userinfo"
        $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers
        $response | ConvertTo-Json -Depth 100 | Out-File $userInfoFile
      } catch {
        Write-Error $_
      }
}

function Get-UserInfo() {
    $userInfoPath = "$home/.Docusign/userinfo.json"
    $userInfoFile = Get-Item $userInfoPath
    $userInfoFileDate = $userInfoFile.LastWriteTime
    if (((Get-Date) - $userInfoFileDate).Days -gt 30) {
        Request-UserInfo
    }
    $userInfo = Get-Content -Path $userInfoPath -Raw |ConvertFrom-Json
    return $userInfo
}

function Get-ApiUri() {
    $AccountId = Get-ApiAccountId
    $userInfo = Get-UserInfo
    $accountInfo = $userInfo.accounts.where({$_.account_id -eq $AccountId})
    $apiUri = "{0}/restapi/v2.1/accounts/{1}" -f $accountInfo.base_uri, $AccountId
    return $apiUri
}