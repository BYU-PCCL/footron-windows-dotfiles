# Based on https://docs.microsoft.com/en-us/windows/configuration/kiosk-shelllauncher#configure-a-custom-shell-using-powershell

# Enable Shell Launcher feature
Dism /online /Enable-Feature /all /FeatureName:Client-EmbeddedShellLauncher

# Check if shell launcher license is enabled
function Check-ShellLauncherLicenseEnabled
{
    [string]$source = @"
using System;
using System.Runtime.InteropServices;

static class CheckShellLauncherLicense
{
    const int S_OK = 0;

    public static bool IsShellLauncherLicenseEnabled()
    {
        int enabled = 0;

        if (NativeMethods.SLGetWindowsInformationDWORD("EmbeddedFeature-ShellLauncher-Enabled", out enabled) != S_OK) {
            enabled = 0;
        }
        return (enabled != 0);
    }

    static class NativeMethods
    {
        [DllImport("Slc.dll")]
        internal static extern int SLGetWindowsInformationDWORD([MarshalAs(UnmanagedType.LPWStr)]string valueName, out int value);
    }

}
"@

    $type = Add-Type -TypeDefinition $source -PassThru

    return $type[0]::IsShellLauncherLicenseEnabled()
}

[bool]$result = $false

$result = Check-ShellLauncherLicenseEnabled
"`nShell Launcher license enabled is set to " + $result
if (-not($result))
{
    "`nThis device doesn&#39;t have required license to use Shell Launcher"
    exit
}

$COMPUTER = "localhost"
$NAMESPACE = "root\standardcimv2\embedded"

# Create a handle to the class instance so we can call the static methods.
try {
    $ShellLauncherClass = [wmiclass]"\\$COMPUTER\${NAMESPACE}:WESL_UserSetting"
    } catch [Exception] {
    write-host $_.Exception.Message;
    write-host "Make sure Shell Launcher feature is enabled"
    exit
}


# This well-known security identifier (SID) corresponds to the BUILTIN\Administrators group.
$Admins_SID = "S-1-5-32-544"

# Create a function to retrieve the SID for a user account on a machine.
function Get-UsernameSID($AccountName) {

    $NTUserObject = New-Object System.Security.Principal.NTAccount($AccountName)
    $NTUserSID = $NTUserObject.Translate([System.Security.Principal.SecurityIdentifier])

    return $NTUserSID.Value
}

$ft_SID = Get-UsernameSID("ft")

# Define actions to take when the shell program exits.
$restart_shell = 0
$restart_device = 1
$shutdown_device = 2
$do_nothing = 3

$ShellLauncherClass.SetDefaultShell("explorer.exe", $restart_device)

$DefaultShellObject = $ShellLauncherClass.GetDefaultShell()
"`nDefault Shell is set to " + $DefaultShellObject.Shell + " and the default action is set to " + $DefaultShellObject.defaultaction

$ShellLauncherClass.SetEnabled($TRUE)
try {
$ShellLauncherClass.RemoveCustomShell($ft_SID)
    } catch [Exception] {
    write-host "There is likely no existing shell"
}
$ShellLauncherClass.SetCustomShell($ft_SID, "python -muvicorn footron_windows:app --reload --host 0.0.0.0", ($null), ($null), $restart_shell)

"`nCurrent settings for custom shells:"
Get-WmiObject -namespace $NAMESPACE -computer $COMPUTER -class WESL_UserSetting | Select Sid, Shell, DefaultAction
