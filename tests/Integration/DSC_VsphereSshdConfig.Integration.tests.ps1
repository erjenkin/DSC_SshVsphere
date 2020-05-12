
$script:dscModuleName = 'VsphereSshDsc'
$script:dscResourceFriendlyName = 'VsphereSshdConfig'
$script:dscResourceName = "DSC_$($script:dscResourceFriendlyName)"

$scriptPath = split-path -parent (split-path -parent $MyInvocation.MyCommand.Definition)
Import-Module -Name "$scriptPath\TestHelpers\VMware.VimAutomation.Core" -verbose
Import-Module -Name "$scriptPath\TestHelpers\Posh-SSH" -verbose

$ModulePath = split-path -parent (split-path -parent (split-path -parent $MyInvocation.MyCommand.Definition))
Import-Module -Name $Modulepath\Source\DscResources\DSC_VsphereSshdConfig -verbose

try
{
    Import-Module -Name DscResource.Test -Force
}
catch [System.IO.FileNotFoundException]
{
    throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
}

$script:testEnvironment = Initialize-TestEnvironment `
    -DSCModuleName $script:dscModuleName `
    -DSCResourceName $script:dscResourceName `
    -ResourceType 'Mof' `
    -TestType 'Integration'

$script:TestServer = "192.168.100.2"


try
{
    #region Integration Tests
    $configurationFile = Join-Path -Path $PSScriptRoot -ChildPath "$($script:dscResourceName).config.ps1"
    . $configurationFile

    Describe "$($script:dscResourceName)_Integration" -Tag "Online" {
        Context 'Get-TargetResource Test' {

            It 'Get-TargetResource should return an object with all required parameters' {

                $VcenterCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @($ConfigurationData.AllNodes.VcenterLogin_UserName, (ConvertTo-SecureString -String $ConfigurationData.AllNodes.VcenterLogin_Password -AsPlainText -Force))

                $SshCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @($ConfigurationData.AllNodes.SshLogin_UserName, (ConvertTo-SecureString -String $ConfigurationData.AllNodes.SshLogin_Password -AsPlainText -Force))

                $getresult = Get-TargetResource -Command $ConfigurationData.AllNodes.Command `
                    -VcenterServerIP $ConfigurationData.AllNodes.VcenterServerIP `
                    -VsphereHostIP $ConfigurationData.AllNodes.VsphereHostIP `
                    -VcenterCredential $VcenterCredential `
                    -SshCredential $SshCredential

                $getresult.SshCredential | Should -Be $SshCredential
                $getresult.VcenterCredential | Should -Be $VcenterCredential
                $getresult.Command | Should -Be $ConfigurationData.AllNodes.Command
                $getresult.VcenterServerIP | Should -Be $ConfigurationData.AllNodes.VcenterServerIP
                $getresult.VsphereHostIP | Should -Be $ConfigurationData.AllNodes.VsphereHostIP
                $getresult.SshValue | Should -Be ""

            }

        }
        Context ('When using configuration {0}' -f $configurationName) {
            BeforeEach {
                $configurationName = "$($script:dscResourceName)"
                $resourceId = "[$($script:dscResourceFriendlyName)]Integration_Test_VsphereSshdConfig"
            }
            It 'Should compile the MOF without throwing' {
                {
                    $configurationParameters = @{
                        OutputPath           = $TestDrive
                        ConfigurationData    = $ConfigurationData
                    }

                    & $configurationName @configurationParameters
                } | Should -Not -Throw
            }
        }
    }
    Describe "$($script:dscResourceName)_Integration Local Tests" -Tag "LocalOnly" {
        It 'Should be able to call Start-DscConfiguration without throwing' {
            {
                $startDscConfigurationParameters = @{
                    Path         = $TestDrive
                    ComputerName = 'localhost'
                    Wait         = $true
                    Verbose      = $true
                    Force        = $true
                    ErrorAction  = 'Stop'
                }

                Start-DscConfiguration @startDscConfigurationParameters
            } | Should -Not -Throw
        }

        It 'Should be able to call Get-DscConfiguration without throwing' {
            {
                $script:currentConfiguration = Get-DscConfiguration -Verbose -ErrorAction Stop
            } | Should -Not -Throw
        }

        It 'Should have set the resource and all the parameters should match' {
            $resourceCurrentState = $script:currentConfiguration | Where-Object -FilterScript {
                $_.ConfigurationName -eq $configurationName `
                -and $_.ResourceId -eq $resourceId
            }

            $resourceCurrentState.VcenterServerIP | Should -Be $ConfigurationData.AllNodes.VcenterServerIP
            $resourceCurrentState.VsphereHostIP  | Should -Be $ConfigurationData.AllNodes.VsphereHostIP
            $resourceCurrentState.Command  | Should -Be $ConfigurationData.AllNodes.Command
            $resourceCurrentState.SshValue | Should -Be $ConfigurationData.AllNodes.SshValue
        }

        It 'Should return $true when Test-DscConfiguration is run' {
            Test-DscConfiguration -Verbose | Should -Be 'True'
        }
    }

    #endregion
}
finally
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}
