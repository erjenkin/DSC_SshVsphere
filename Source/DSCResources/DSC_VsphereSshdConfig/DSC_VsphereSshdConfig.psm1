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
        $Command

    )

    #Connect to Vcenter
    Connect-VIServer -Server $VcenterServerIP -Credential $VcenterCredential

    #get SSH running state
    $sshStatus = (Get-VMHost -Name $VsphereHostIP | Get-VMHostService | where Key -eq "TSM-SSH").Running
    Write-Verbose "Vmhost SSH service is currently running : $sshStatus"

    #If SSH isn't running, then start
    if($sshstatus -eq "false")
    {
        Get-VMHost -Name $VsphereHostIP | Get-VMHostService | where Key -eq "TSM-SSH"| Start-VMHostService -Confirm:$false
    }

    #If not connected via SSH, then connect
    Write-Verbose "Creating SSH session with : $VsphereHostIP"
    New-SSHSession -ComputerName $VsphereHostIP -Credential $SshCred -AcceptKey

    #Run the SSH command
    #$sshOutput = (Invoke-SSHCommand -index 0 -Command 'grep -i "^Banner" /etc/ssh/sshd_config').Output
    $sshOutput = (Invoke-SSHCommand -Index 0 -Command $sshCommand).Output

    #If connected via SSH, then disconnect
    Remove-SSHSession (Get-SSHSession).SessionID

    #Set SSH back to previous state if different
    if($sshStatus -eq "false")
    {
        Get-VMHost -Name $VsphereHostIP | Get-VMHostService | where Key -eq "TSM-SSH"| Stop-VMHostService -Confirm:$false
    }

    #Disconnect Vcenter
    Disconnect-VIServer -Confirm:$false

    return $sshOutput

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

    if($null -eq $getTargetResourceResult)
    {
        Write-Verbose "Creating configuration line"
        $sshCommand = "echo $sshValue >> /etc/ssh/sshd_config"
        Invoke-SSHCommand -Index 0 -Command $sshCommand
    }

    if($getTargetResourceResult -ne $SshValue)
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

    if ($SshValue -eq $getTargetResourceResult)
    {
        Write-Verbose -Message ($script:localizedData.InDesiredState)
        $testTargetResourceResult = $true
    }

    return $testTargetResourceResult
}
