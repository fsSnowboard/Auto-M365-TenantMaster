# Function to get the policy ID by name
function Get-PolicyIdByName {
    param (
        [string]$policyName
    )

    # Get all device configurations
    $policies = Get-MgDeviceManagementDeviceConfiguration

    # Find the policy with the matching name
    $policy = $policies | Where-Object { $_.displayName -eq $policyName }

    if ($policy) {
        return $policy.id
    }
    else {
        Write-Error "Policy with name '$policyName' not found."
        return $null
        Exit
    }
}

# Function to export Intune configuration policy to JSON
function Export-IntuneConfigPolicy {
    param (
        [string]$policyName,
        [string]$outputFilePath
    )

    # Get the policy ID by name
    $policyId = Get-PolicyIdByName -policyName $policyName

    if ($policyId) {
        # Get the configuration policy by ID
        $policy = Get-MgDeviceManagementDeviceConfiguration -DeviceConfigurationId $policyId

        # Convert the policy to JSON and save to file
        $json = $policy | ConvertTo-Json -Depth 10
        $json | Out-File -FilePath $outputFilePath -Encoding utf8

        Write-Output "Configuration policy exported to $outputFilePath"
    }
}

# Function to sanitize the file name
function Sanitize-FileName {
    param (
        [string]$fileName
    )

    # Replace invalid characters with an underscore
    $fileName = $fileName -replace '[<>:"/\\|?*]', ''
    # Replace spaces with underscores
    $fileName = $fileName -replace ' ', '_'
    # Remove square brackets
    $fileName = $fileName -replace '[\[\]]', ''
    return $fileName
}

# Main Execution
$policyName = "[Bonus] W10 Enable FIDO2 security keys"  # Replace with your actual policy name

# Sanitize the policy name to create a valid file name
$sanitizedPolicyName = Sanitize-FileName -fileName $policyName
$outputFilePath = Join-Path $PSScriptRoot "$($sanitizedPolicyName).json"

Export-IntuneConfigPolicy -policyName $policyName -outputFilePath $outputFilePath
