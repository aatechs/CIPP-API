function Invoke-CIPPStandardSPExternalUserExpiration {
    <#
    .FUNCTIONALITY
        Internal
    .COMPONENT
        (APIName) SPExternalUserExpiration
    .SYNOPSIS
        Set guest access to expire automatically
    .DESCRIPTION
        (Helptext) Ensure guest access to a site or OneDrive will expire automatically
        (DocsDescription) Ensure guest access to a site or OneDrive will expire automatically
    .NOTES
        CAT
            SharePoint Standards
        TAG
            "mediumimpact"
            "CIS"
        ADDEDCOMPONENT
            {"type":"number","name":"standards.SPExternalUserExpiration.Days","label":"Days until expiration (Default 60)"}
        LABEL
            Set guest access to expire automatically
        IMPACT
            Medium Impact
        POWERSHELLEQUIVALENT
            Set-SPOTenant -ExternalUserExpireInDays 30 -ExternalUserExpirationRequired $True
        RECOMMENDEDBY
            "CIS 3.0"
        UPDATECOMMENTBLOCK
            Run the Tools\Update-StandardsComments.ps1 script to update this comment block
    #>

    param($Tenant, $Settings)
    $CurrentState = Get-CIPPSPOTenant -TenantFilter $Tenant |
        Select-Object -Property ExternalUserExpireInDays, ExternalUserExpirationRequired

    $StateIsCorrect = ($CurrentState.ExternalUserExpireInDays -eq $Settings.Days) -and
                      ($CurrentState.ExternalUserExpirationRequired -eq $true)

    if ($Settings.remediate -eq $true) {
        if ($StateIsCorrect -eq $true) {
            Write-LogMessage -API 'Standards' -Message 'Sharepoint External User Expiration is already enabled.' -Sev Info
        } else {
            $Properties = @{
                ExternalUserExpireInDays = $Settings.Days
                ExternalUserExpirationRequired = $true
            }

            try {
                Get-CIPPSPOTenant -TenantFilter $Tenant | Set-CIPPSPOTenant -Properties $Properties
                Write-LogMessage -API 'Standards' -Message 'Successfully set External User Expiration' -Sev Info
            } catch {
                $ErrorMessage = Get-NormalizedError -Message $_.Exception.Message
                Write-LogMessage -API 'Standards' -Message "Failed to set External User Expiration. Error: $ErrorMessage" -Sev Error
            }
        }
    }

    if ($Settings.alert -eq $true) {
        if ($StateIsCorrect -eq $true) {
            Write-LogMessage -API 'Standards' -Message 'External User Expiration is enabled' -Sev Info
        } else {
            Write-LogMessage -API 'Standards' -Message 'External User Expiration is not enabled' -Sev Alert
        }
    }

    if ($Settings.report -eq $true) {
        Add-CIPPBPAField -FieldName 'ExternalUserExpiration' -FieldValue $StateIsCorrect -StoreAs bool -Tenant $Tenant
    }
}