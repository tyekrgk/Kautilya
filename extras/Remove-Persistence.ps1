<#
.SYNOPSIS
Script which could be used to clear the persistence added by Keylogger, HTTP Backdoor and DNS TXT Backdoor

.DESCRIPTION
This script cleans WMI events and Registry keys added by keylogger and both the backdoors.
Run the script as an Administrator to remove the WMI events.

.Example
PS > .\Remove-Persistence.ps1

.LINK
http://labofapenetrationtester.blogspot.com/
http://code.google.com/p/nishang
http://blogs.technet.com/b/heyscriptingguy/archive/2012/07/20/use-powershell-to-create-a-permanent-wmi-event-to-launch-a-vbscript.aspx
#>

Param( [Parameter(Position = 0)] [Switch] $remove)

function Remove-Persistence
{
    
    if ($remove -eq $true)
    {
        $currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent())
        if($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -ne $true)
        {    
            Write-Warning "Run the Command as an Administrator. Removing Registry keys only."
            Remove-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Run\ -Name Update -ErrorAction SilentlyContinue
            Break
        }

        Write-Output "Removing the WMI Events."
        $filterName = "WindowsSanity"
        gwmi __eventFilter -namespace root\subscription -filter "name='WindowsSanity'"| Remove-WmiObject
        gwmi activeScriptEventConsumer -Namespace root\subscription | Remove-WmiObject
        gwmi __filtertoconsumerbinding -Namespace root\subscription -Filter "Filter = ""__eventfilter.name='WindowsSanity'"""  | Remove-WmiObject
        Write-Output "Removing the Registry keys."
        Remove-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Run\ -Name Update -ErrorAction SilentlyContinue
    }
    $Regkey = Get-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Run\ -name Update -ErrorAction SilentlyContinue
    $wmi_1 = gwmi __eventFilter -namespace root\subscription -filter "name='WindowsSanity'"
    $wmi_2 = gwmi activeScriptEventConsumer -Namespace root\subscription
    $wmi_3 = gwmi __filtertoconsumerbinding -Namespace root\subscription -Filter "Filter = ""__eventfilter.name='WindowsSanity'"""
    if ($Regkey -ne $null )
    {
        Write-Warning "Run Registry key persistence found. Use with -Remove option to clean."
    }
    elseif (($wmi_1) -and ($wmi_2) -and ($wmi_3) -ne $null)    
    {
        Write-Warning "WMI permanent event consumer persistence found. Use with -Remove option to clean."
    }
    else
    {
        Write-Output "No Persistence found."
    }

    
}

Remove-Persistence