#region HEADER
# Integration Test Config Template Version: 1.2.1
#endregion

$configFile = [System.IO.Path]::ChangeExtension($MyInvocation.MyCommand.Path, 'json')
if (Test-Path -Path $configFile)
{
    $ConfigurationData = Get-Content -Path $configFile | ConvertFrom-Json
}
else
{
    $ConfigurationData = @{
        AllNodes = @(
            @{
                # policy with a dword datatype
                NodeName   = 'localhost'
                VcenterServerIP = '10.10.10.100'
                VsphereHostIP = '192.168.128.1'
                VcenterLogin_UserName = "administrator@vsphere.local"
                VcenterLogin_Password = 'P@ssword1'
                SshLogin_UserName = "root"
                SshLogin_Password = 'P@ssword1'
                Command = 'grep -i "^Ciphers" /etc/ssh/sshd_config'
                SshValue = 'Ciphers aes128-ctr,aes192-ctr,aes256-ctr'
                PSDscAllowPlainTextPassword = $true
                PSDscAllowDomainUser = $true

            }
        )
    }
}

<#
    .SYNOPSIS
        This configuration will add/update the Ciphers line in the SSHd Configuration File
#>
Configuration DSC_VsphereSshdConfig
{
    Import-DscResource -ModuleName 'VsphereSshDsc'

    node $AllNodes.NodeName
    {
        VsphereSshdConfig 'Integration_Test_VsphereSshdConfig'
        {
            VcenterServerIP = $node.VcenterServerIP
            VsphereHostIP   = $node.VsphereHostIP
            Command         = $node.Command
            SshValue        = $node.SshValue

            VcenterCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @($Node.VcenterLogin_UserName, (ConvertTo-SecureString -String $Node.VcenterLogin_Password -AsPlainText -Force))
            SshCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @($Node.SshLogin_UserName, (ConvertTo-SecureString -String $Node.SshLogin_Password -AsPlainText -Force))
        }
    }
}

