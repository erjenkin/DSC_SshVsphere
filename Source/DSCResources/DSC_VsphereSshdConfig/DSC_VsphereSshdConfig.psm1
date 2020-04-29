function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
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

    #Connect to Vcenter
    Connect-VIServer -Server $VcenterServerIP -Credential $VcenterCredential

    #get SSH running state
    $sshStatus = (Get-VMHost -Name $VsphereHostIP | Get-VMHostService | where Key -eq "TSM-SSH").Running
    Write-Verbose -Message "Vmhost SSH service is currently running : $sshStatus"

    #If SSH isn't running, then start
    if($sshstatus -eq "false")
    {
        Get-VMHost -Name $VsphereHostIP | Get-VMHostService | where Key -eq "TSM-SSH"| Start-VMHostService -Confirm:$false
    }

    #If not connected via SSH, then connect
    Write-Verbose -Message "Creating SSH session with : $VsphereHostIP"
    New-SSHSession -ComputerName $VsphereHostIP -Credential $SshCredential -AcceptKey

    #Run the SSH command
    #$sshOutput = (Invoke-SSHCommand -index 0 -Command 'grep -i "^Banner" /etc/ssh/sshd_config').Output
    $sshOutput = (Invoke-SSHCommand -Index 0 -Command $sshCommand).Output

    #If connected via SSH, then disconnect
    Remove-SSHSession (Get-SSHSession).SessionID

    #Set SSH back to previous state if different
    if($sshStatus -eq "false")
    {
        Write-Verbose -Message "Stopping SSH Service"
        Get-VMHost -Name $VsphereHostIP | Get-VMHostService | where Key -eq "TSM-SSH"| Stop-VMHostService -Confirm:$false
    }

    #Disconnect Vcenter
    Disconnect-VIServer -Confirm:$false

    $returnValue = @{
        VcenterServerIP   = [System.String] $VcenterServerIP
        VsphereHostIP     = [System.String] $VsphereHostIP
        VcenterCredential = [System.Object] $VcenterCredential
        SshCredential     = [System.Object] $SshCredential
        Command           = [System.String] $Command
        SshValue          = [System.String] $SshValue
        sshOutput         = [System.String] $sshOutput
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

    $testTargetResourceResult = $false
    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

    if($null -eq $getTargetResourceResult.sshOutput)
    {
        Write-Verbose "Creating configuration line"
        $sshCommand = "echo $sshValue >> /etc/ssh/sshd_config"
        Invoke-SSHCommand -Index 0 -Command $sshCommand
    }

    if($getTargetResourceResult.sshOutput -ne $SshValue)
    {
        Write-Verbose "Updating configuration line $getTargetResourceResult to $SshValue"
        $sshCommand = "sed -i 's/$getTargetResourceResult/$SshValue/g' /etc/ssh/sshd_config"
        Invoke-SSHCommand -Index 0 -Command $sshcommand
    }
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

    if ($SshValue -eq $getTargetResourceResult.sshOutput)
    {
        Write-Verbose -Message ($script:localizedData.InDesiredState)
        $testTargetResourceResult = $true
    }

    return $testTargetResourceResult
}
