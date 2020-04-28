#Requires -Module VsphereSshDsc


<#
    .DESCRIPTION
        Configuration that will disabled SMB1.
        The configuration then uses the RefreshRegistryPolicy resource to
        invoke gpupdate.exe to refresh group policy and enforce the policy
        that has been recently configured. The corresponding policy in gpedit
        will not reflect the policy is being enforce until the RefreshRegistryPolicy
        resource has successfully ran.
#>
Configuration VsphereSshdConfig_DisableHostbasedAuthentication_Config
{
    param
    (
        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $VcenterCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $SshCredential
    )

    Import-DscResource -ModuleName 'VsphereSshDsc'

    node localhost
    {
        VsphereSshdConfig 'Disable Host Based Auth'
        {
            SshValue = 'HostbasedAuthentication no'
            Command  = 'grep -i "^HostbasedAuthentication" /etc/ssh/sshd_config'
            VcenterServerIP = '192.168.128.10'
            VsphereHostIP   = '192.168.128.9'
            VcenterCredential  = $VcenterCredential
            SshCredential  = $SshCredential
        }
    }
}