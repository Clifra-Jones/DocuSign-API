function Request-CodeGrantAuthorization() {

<#   param(
    [Parameter(Mandatory = $true)]
    [string]$clientId,
    [Parameter(Mandatory = $true)]
    [string]$clientSecret,
    [Parameter(Mandatory = $true)]
    [string]$apiVersion) #>
  Param(
    [Parameter(
      Mandatory = $true
    )]
    [string]$apiVersion,
    [switch]$extended
  )

  $PORT = '8080'
  $IP = 'localhost'

  #$accessTokenFile = [System.IO.Path]::Combine($PSScriptRoot, "..\config\ds_access_token.txt")
  #$accountIdFile = [System.IO.Path]::Combine($PSScriptRoot, "..\config\API_ACCOUNT_ID")
  $accessTokenFile = "$home/.Docusign/ds_access_token.txt"
  $accountIdFile = "$Home/.Docusign/API_ACCOUNT_ID"
  $refreshTokenFile = "$Home/.Docusign/refresh_token.txt"
  $expiresDateFile = "$home/.Docusign/expiration_date.txt"
  $userInfoFile = "$home/.Docusign/userinfo.json"

  #Get current Config

    $Config = Get-Config
    $clientId = $config.INTEGRATION_KEY_AUTH_CODE
    $clientSecret = $config.SECRET_KEY
    #$apiVersion = "eSignature"

  $state = [Convert]::ToString($(Get-Random -Maximum 1000000000), 16)

  if($apiVersion -eq [APIVersions]::rooms){
    $scopes = "signature%20dtr.rooms.read%20dtr.rooms.write%20dtr.documents.read%20dtr.documents.write%20dtr.profile.read%20dtr.profile.write%20dtr.company.read%20dtr.company.write%20room_forms"
  }
  elseif ($apiVersion -eq [APIVersions]::eSignature) {
    $scopes = "signature"
  }
  elseif ($apiVersion -eq [APIVersions]::click) {
    $scopes = "click.manage"
  }
  elseif ($apiVersion -eq [APIVersions]::monitor) {
    $scopes = "signature impersonation"
  }

  If ($extended) {
    "extended%20" + $scopes
  }

  $authorizationEndpoint = "https://account-d.docusign.com/oauth/"
  $redirectUri = "http://${IP}:${PORT}/authorization-code/callback"
  $redirectUriEscaped = [Uri]::EscapeDataString($redirectURI)
  $authorizationURL = "${authorizationEndpoint}auth?response_type=code&scope=$scopes&client_id=$clientId&state=$state&redirect_uri=$redirectUriEscaped"

  Write-Output "The authorization URL is:"
  Write-Output $authorizationURL

  # Request the authorization code
  # Use Http Server
  $http = New-Object System.Net.HttpListener

  # Hostname and port to listen on

  $http.Prefixes.Add($redirectURI + "/")
  try {
  # Start the Http Server
  $http.Start()

  }
  catch {
      Write-Error "OAuth listener failed. Is port 8080 in use by another program?" -ErrorAction Stop
  }

  if ($http.IsListening) {
    Write-Output "Open the following URL in a browser to continue:" $authorizationURL
    Start-Process $authorizationURL
  }

  while ($http.IsListening) {
    $context = $http.GetContext()

    if ($context.Request.HttpMethod -eq 'GET' -and $context.Request.Url.LocalPath -match '/authorization-code/callback') {
      # write-host "Check context"
      # write-host "$($context.Request.UserHostAddress)  =>  $($context.Request.Url)" -f 'mag'
      [string]$html = '
          <html lang="en">
          <head>
            <meta charset="utf-8">
            <title></title>
          </head>
          <body>
          Ok. You may close this tab and return to the shell. This window closes automatically in five seconds.
          <script type="text/javascript">
            setTimeout(
            function ( )
            {
              self.close();
            }, 5000 );
            </script>
          </body>
          </html>
          '
      # Respond to the request
      $buffer = [System.Text.Encoding]::UTF8.GetBytes($html) # Convert HTML to bytes
      $context.Response.ContentLength64 = $buffer.Length
      $context.Response.OutputStream.Write($buffer, 0, $buffer.Length) # Stream HTML to browser
      $context.Response.OutputStream.Close() # Close the response

      # Get context
      $Regex = [Regex]::new("(?<=code=)(.*)(?=&state)")
      $Match = $Regex.Match($context.Request.Url)
      if ($Match.Success) {
        $authorizationCode = $Match.Value
      }

      $http.Stop()
    }
  }

  # Obtain the access token
  # Preparing an Authorization header which contains your integration key and secret key
  $authorizationHeader = "${clientId}:${clientSecret}"

  # Convert the Authorization header into base64
  $authorizationHeaderBytes = [System.Text.Encoding]::UTF8.GetBytes($authorizationHeader)
  $authorizationHeaderKey = [System.Convert]::ToBase64String($authorizationHeaderBytes)

  try {
    Write-Output "Getting an access token..."
    $accessTokenResponse = Invoke-RestMethod `
      -Uri "$authorizationEndpoint/token" `
      -Method "POST" `
      -Headers @{ "Authorization" = "Basic $authorizationHeaderKey" } `
      -Body @{
      "grant_type" = "authorization_code";
      "code"       = "$authorizationCode"
    }
    $accessToken = $accessTokenResponse.access_token
    $refreshToken = $AccessTokenResponse.refresh_token
    $expiresInSeconds = $AccessTokenResponse.expires_in
    $expirationDate = (Get-Date).AddSeconds($expiresInSeconds)

    Write-Output "Access token: $accessToken"
    Write-Output $accessToken > $accessTokenFile
    Write-Output "Access token has been written to $accessTokenFile file..."
    Write-Output "Refresh Token: $refreshToken"
    Write-Output $refreshToken > $refreshTokenFile
    Write-Output "Refresh token has been writen to $refreshTokenFile file..."
    Write-Output "Expires in: $expiresIn"
    write-output $expirationDate.ToFileTime() > $expiresDateFile
    Write-Output "Acccess token will expire on $expirationDate."

    Write-Output "Getting an account id..."
    $userInfoResponse = Invoke-RestMethod `
      -Uri "$authorizationEndpoint/userinfo" `
      -Method "GET" `
      -Headers @{ "Authorization" = "Bearer $accessToken" }
    $accountId = $userInfoResponse.accounts[0].account_id
    Write-Output "Account id: $accountId"
    Write-Output $accountId > $accountIdFile
    Write-Output "Account id has been written to $accountIdFile file..."
  }
  catch {
    Write-Error $_
  }
  try {
    #get user info
    $headers = Get-Headers
    $URI = "GET https://account-d.docusign.com/oauth/userinfo"
    $response = Invoke-RestMethod -Uri $uri -Method GET -Headers $headers
    $response | ConvertTo-Json -Depth 100 | Out-File $userInfoFile
  } catch {
    Write-Error $_
  }
}

function Request-CodeGrantRefresh() {

  #Get current Config
  $Config = Get-Config
  $clientId = $config.INTEGRATION_KEY_AUTH_CODE
  $clientSecret = $config.SECRET_KEY

  $accessTokenFile = "$home/.Docusign/ds_access_token.txt"
  $refreshTokenFile = "$home/.Docusign/refresh_token.txt"
  $expireDateFile = "$home/.Docusign/expiration_date.txt"

  $authorizationEndpoint = "https://account-d.docusign.com/oauth/"
 
  # Preparing an Authorization header which contains your integration key and secret key
  $authorizationHeader = "${clientId}:${clientSecret}"

  # Convert the Authorization header into base64
  $authorizationHeaderBytes = [System.Text.Encoding]::UTF8.GetBytes($authorizationHeader)
  $authorizationHeaderKey = [System.Convert]::ToBase64String($authorizationHeaderBytes)

  $refreshToken = Get-RefreshToken

  $Headers = @{
    "Authorization" = "Basic $authorizationHeaderKey";
  }

  $Body = @{
    "grant_type" = "refresh_token";
    "refresh_token" = "$refreshToken"
  }

  $Uri = "$authorizationEndpoint/token"
  try {
    $response = Invoke-RestMethod -Uri $Uri -Method POST -Headers $Headers -Body $Body
    $newAccessToken = $response.access_token
    $newRefreshToken = $response.refresh_token
    $expiresInSeconds = $response.expires_in
    $expirationDate = (Get-Date).AddSeconds($expiresInSeconds).ToLongDateString()

    Write-Output $newAccessToken > $accessTokenFile
    Write-Output $newRefreshToken > $refreshTokenFile
    Write-Output $expirationDate.ToFileTime() > $expireDateFile
  } catch {
    Write-Error $_
  }

}


