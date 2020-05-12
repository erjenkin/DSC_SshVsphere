function New-SSHSession {
    param(
        [PSObject] $Server,
        [string] $Name
    )

    return $null
}


function Remove-SSHSession {
    param(
        [PSObject] $Server,
        [string] $Name
    )

    return $null
}


function Invoke-SSHCommand {
    param(
        [PSObject] $Server,
        [string] $Name
    )

    return $null
}

function Get-SSHSession{
    param(
        [string]$Name
    )

    $sshSession = @{
        SessionId = "1"
        Host = $Name
        Connect = "True"
    }
   return $sshSession
}
