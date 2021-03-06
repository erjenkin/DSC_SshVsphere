<#
    .SYNOPSIS
        Returns the current state if a machine requires a group policy refresh.
    .PARAMETER Command
        A Command to serve as the key property.
    .PARAMETER VcenterServerIP
        A Command to serve as the key property.
    .PARAMETER VsphereHostIP
        A Command to serve as the key property.
    .PARAMETER VcenterCredential
        A Command to serve as the key property.
    .PARAMETER SshCredential
        A Command to serve as the key property.
#>

function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $Command,

        [Parameter(Mandatory = $true)]
        [System.String]
        $VcenterServerIP,

        [Parameter(Mandatory = $true)]
        [System.String]
        $VsphereHostIP,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $VcenterCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SshCredential
    )

    #Establish Ssh Connection
    $sshStatus = Set-SshConnection -VcenterServerIP $VcenterServerIP -VsphereHostIP $VsphereHostIP -VcenterCredential $VcenterCredential -SshCredential $SshCredential

    #Run the SSH command
    Write-Verbose -Message "Attempting to run SSH command"
    $sshOutput = (Invoke-SSHCommand -Index 0 -Command $Command).Output

    #Remove Ssh Connection
    $null = Remove-SshConnection -VsphereHostIP $VsphereHostIP -SshStatus $sshStatus

    $returnValue = @{
        VcenterServerIP   = [System.String] $VcenterServerIP
        VsphereHostIP     = [System.String] $VsphereHostIP
        VcenterCredential = [System.Object] $VcenterCredential
        SshCredential     = [System.Object] $SshCredential
        Command           = [System.String] $Command
        SshValue          = [System.String] $SshOutput
    }

    return $returnValue
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $VcenterServerIP,

        [Parameter(Mandatory = $true)]
        [System.String]
        $VsphereHostIP,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $VcenterCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SshCredential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Command,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SshValue
    )

    $getTargetResourceParameters = @{
        VcenterServerIP   = $VcenterServerIP
        VsphereHostIP     = $VsphereHostIP
        VcenterCredential = $VcenterCredential
        SshCredential     = $SshCredential
        Command           = $Command
    }

    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

    #Establish Ssh Connection
    $sshStatus = Set-SshConnection -VcenterServerIP $VcenterServerIP -VsphereHostIP $VsphereHostIP -VcenterCredential $VcenterCredential -SshCredential $SshCredential

    if($getTargetResourceResult.SshValue -ne $SshValue)
    {
        if(-not $getTargetResourceResult.SshValue)
        {
            Write-Verbose "Creating configuration line"
            $sshSetCommand = "echo $sshValue >> /etc/ssh/sshd_config"
            Invoke-SSHCommand -Index 0 -Command $sshSetCommand
        }
        else
        {
            Write-Verbose "Updating configuration line $getTargetResourceResult to $SshValue"
            $sshSetCommand = "sed -i 's/$getTargetResourceResult.SshValue/$SshValue/g' /etc/ssh/sshd_config"
            Invoke-SSHCommand -Index 0 -Command $sshSetCommand
        }
    }

    #Remove Ssh Connection
    Remove-SshConnection -VsphereHostIP $VsphereHostIP -SshStatus $sshStatus
}


function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $VcenterServerIP,

        [Parameter(Mandatory = $true)]
        [System.String]
        $VsphereHostIP,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $VcenterCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SshCredential,

        [Parameter(Mandatory = $true)]
        [System.String]
        $Command,

        [Parameter(Mandatory = $true)]
        [System.String]
        $SshValue
    )

    $getTargetResourceParameters = @{
        VcenterServerIP   = $VcenterServerIP
        VsphereHostIP     = $VsphereHostIP
        VcenterCredential = $VcenterCredential
        SshCredential     = $SshCredential
        Command           = $Command
    }

    $testTargetResourceResult = $false
    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

    if ($SshValue -eq $getTargetResourceResult.sshValue)
    {
        Write-Verbose -Message "Result match $SshValue"
        $testTargetResourceResult = $true
    }

    return $testTargetResourceResult
}

function Set-SshConnection
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $VcenterServerIP,

        [Parameter(Mandatory = $true)]
        [System.String]
        $VsphereHostIP,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $VcenterCredential,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        [System.Management.Automation.Credential()]
        $SshCredential
    )

    #Connect to Vcenter
    Connect-VIServer -Server $VcenterServerIP -Credential $VcenterCredential

    #get SSH running state
    $sshStatus = (Get-VMHostService -VMHost $VsphereHostIP | Where-Object -Property Key -eq "TSM-SSH").Running
    Write-Verbose -Message "Vmhost SSH service is currently running : $sshStatus"

    #If SSH isn't running, then start
    if($sshstatus -eq $false)
    {
        Get-VMHostService -VMHost $VsphereHostIP | Where-Object -Property Key -eq "TSM-SSH" | Start-VMHostService -Confirm:$false
    }

    #If not connected via SSH, then connect
    Write-Verbose -Message "Creating SSH session with : $VsphereHostIP"
    New-SSHSession -ComputerName $VsphereHostIP -Credential $SshCredential -AcceptKey

    return $sshStatus

}

function Remove-SshConnection
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [System.String]
        $VsphereHostIP,

        [Parameter(Mandatory = $true)]
        [System.Object]
        $SshStatus
    )

    #If connected via SSH, then disconnect
    Remove-SSHSession (Get-SSHSession).SessionID

    #Set SSH back to previous state if different
    if($SshStatus -eq $false)
    {
        Write-Verbose -Message "Stopping SSH Service"
        Get-VMHostService -VMHost $VsphereHostIP | Where-Object -Property Key -eq "TSM-SSH" | Stop-VMHostService -Confirm:$false
    }

    #Disconnect Vcenter
    Disconnect-VIServer -Confirm:$false
}