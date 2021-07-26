
$script:apiUri = "https://demo.docusign.net/restapi"

function Get-Headers() {
  
    $accessToken = Get-AccessToken
    $Headers = @{
        'Authorization' = "Bearer $accessToken";
        'Content-Type'  = "application/json";
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