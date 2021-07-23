function set-APIKeys() {
    if (-not (Test-Path "$home/.Docusign")) {
        New-Item -ItemType Directory -Path "$Home\.DocuSign"
    }
    
    $configPath = "$HOME/.Docusign/settings.json"
    if (Test-Path $configPath) {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json        
    } else {
        $config = @{
            "IMPERSONATE_USER_GUID" = ""
            "INTEGRATION_KEY_JWT" = ""
            "INTEGRATION_KEY_AUTH_CODE" = ""
            "SECRET_KEY" = ""
        }
    }

    $userInput = Read-Host -Prompt "Enter your impersonate User GUID: [$($config.IMPERSONATE_USER_GUID)] "
    if ($userInput) {
        $config.IMPERSONATE_USER_GUID= $userInput
    }
    $userInput = Read-Host -Prompt "Enter your Integration Key (for Auth Code and JWT Authorization): [$($config.INTEGRATION_KEY_JWT)] "
    if ($userInput) {
        $config.INTEGRATION_KEY_JWT = $userInput
        $config.INTEGRATION_KEY_AUTH_CODE = $userInput
    }
    $userInput = Read-Host -Prompt "Enter your Secret Key: [$($config.SECRET_KEY)] "
    if ($userInput) {
        $config.SECRET_KEY = $userInput
    }

    $config | ConvertTo-Json -Depth 100 | Out-File -FilePath $configPath
}