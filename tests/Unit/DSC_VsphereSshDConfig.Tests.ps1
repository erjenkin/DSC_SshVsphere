#region HEADER
$script:dscModuleName = 'VsphereSshDsc'
$script:dscResourceName = 'DSC_VsphereSshDConfig'

function Invoke-TestSetup
{
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
        -TestType 'Unit'
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        $mockFolderObject = $null

        Describe 'DSC_VsphereSshdConfig\Get-TargetResource' -Tag 'Get' {
            BeforeAll {

                $VcenterCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @("VcenterAdmin", (ConvertTo-SecureString -String "TestPassword123" -AsPlainText -Force))

                $SshCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @("SshAdmin", (ConvertTo-SecureString -String "TestPassword456" -AsPlainText -Force))

                $defaultParameters = @{
                    Command = "grep test"
                    VcenterServerIP = '192.168.128.15'
                    VsphereHostIP = '192.168.128.13'
                    VcenterCredential = $VcenterCredential
                    SshCredential = $SshCredential
                }
            }

            BeforeEach {
                $getTargetResourceParameters = $defaultParameters.Clone()
            }

            Context 'Testing Get-TargetResource' {
                BeforeEach {

                    $sshConnectionParameters = @{
                        VcenterServerIP = '192.168.128.15'
                        VsphereHostIP = '192.168.128.13'
                        VcenterCredential = $VcenterCredential
                        SshCredential = $SshCredential
                    }

                    Mock -CommandName Set-SshConnection -MockWith {
                        $sshConnectionParameters
                    }

                    Mock -CommandName Invoke-SSHCommand -MockWith {
                        $Command = "grep test"
                    }

                    Mock -CommandName Remove-SshConnection -MockWith {
                        $SessionId = "1"
                    }
                }

                It 'Should return the correct values' {
                    $getTargetResourceResult = Get-TargetResource @getTargetResourceParameters

                    $getTargetResourceResult.Command | Should -Be $getTargetResourceParameters.Command
                    $getTargetResourceResult.VcenterServerIP | Should -Be $getTargetResourceParameters.VcenterServerIP
                    $getTargetResourceResult.VsphereHostIP | Should -Be $getTargetResourceParameters.VsphereHostIP
                    $getTargetResourceResult.VcenterCredential | Should -Be $getTargetResourceParameters.VcenterCredential
                    $getTargetResourceResult.SshCredential | Should -Be $getTargetResourceParameters.SshCredential
                }
            }
        }
        Describe 'DSC_VsphereSshdConfig\Test-TargetResource' -Tag 'Test' {
            BeforeAll {

                $VcenterCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @("VcenterAdmin", (ConvertTo-SecureString -String "TestPassword123" -AsPlainText -Force))

                $SshCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @("SshAdmin", (ConvertTo-SecureString -String "TestPassword456" -AsPlainText -Force))

                $defaultParameters = @{
                    Command = "grep test"
                    VcenterServerIP = '192.168.128.15'
                    VsphereHostIP = '192.168.128.13'
                    VcenterCredential = $VcenterCredential
                    SshCredential = $SshCredential
                }
            }

            BeforeEach {
                $testTargetResourceParameters = $defaultParameters.Clone()
            }

            Context 'When the system is in the desired state' {

                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        $testTargetResourceParameters
                    }
                }

                BeforeEach {
                    $getTargetResourceResult = Get-TargetResource @testTargetResourceParameters
                    $getTargetResourceResult['sshvalue'] = "Correct Value"

                }

                It 'Should return the $true' {
                    $testTargetResourceResult = Test-TargetResource @getTargetResourceResult
                    $testTargetResourceResult | Should -Be $true

                    Assert-MockCalled Get-TargetResource -Exactly -Times 2 -Scope It
                }
            }

            Context 'When the system is not in the desired state' {

                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        $getTargetResourceResults
                    }
                }

                BeforeEach {
                    $testTargetResourceParameters['SshValue'] = 'Incorrect Value'
                    $getTargetResourceResult = $getTargetResourceResult + $testTargetResourceParameters
                }

                It 'Should return the $false' {

                    Mock -CommandName Get-TargetResource -MockWith {
                        return $getTargetResourceResults
                    }

                    $testTargetResourceResult = Test-TargetResource  @testTargetResourceParameters
                    $testTargetResourceResult | Should -Be $false

                    Assert-MockCalled Get-TargetResource -Exactly -Times 1 -Scope It
                }

            }
        }
        Describe 'DSC_VsphereSshdConfig\Set-TargetResource' -Tag 'Set' {
            BeforeAll {

                $VcenterCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @("VcenterAdmin", (ConvertTo-SecureString -String "TestPassword123" -AsPlainText -Force))

                $SshCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @("SshAdmin", (ConvertTo-SecureString -String "TestPassword456" -AsPlainText -Force))

                $defaultParameters = @{
                    Command = "grep test"
                    VcenterServerIP = '192.168.128.15'
                    VsphereHostIP = '192.168.128.13'
                    VcenterCredential = $VcenterCredential
                    SshCredential = $SshCredential
                }
            }

            BeforeEach {
                $setTargetResourceParameters = $defaultParameters.Clone()
            }

            Context 'Testing Set-TargetResource' {

                BeforeAll {
                    Mock -CommandName Get-TargetResource -MockWith {
                        $setTargetResourceParameters
                    }
                }

                BeforeEach {

                    $sshConnectionParameters = @{
                        VcenterServerIP = '192.168.128.15'
                        VsphereHostIP = '192.168.128.13'
                        VcenterCredential = $VcenterCredential
                        SshCredential = $SshCredential
                    }

                    Mock -CommandName Set-SshConnection -MockWith {
                        $sshConnectionParameters
                    }

                    Mock -CommandName Remove-SshConnection -MockWith {
                        $SessionId = "1"
                    }

                    $getTargetResourceResult = Get-TargetResource @setTargetResourceParameters
                    $getTargetResourceResult['sshvalue'] = "Correct Value"

                }

                It 'Should not throw an error' {
                    {Set-TargetResource @getTargetResourceResult} |  Should -Not -Throw
                    Assert-MockCalled Get-TargetResource -Exactly -Times 2 -Scope It
                }
            }
        }
        Describe 'DSC_VsphereSshdConfig\Set-SshConnection' -Tag 'Set-SshConnection' {
            BeforeAll {

                $VcenterCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @("VcenterAdmin", (ConvertTo-SecureString -String "TestPassword123" -AsPlainText -Force))

                $SshCredential = New-Object `
                -TypeName System.Management.Automation.PSCredential `
                -ArgumentList @("SshAdmin", (ConvertTo-SecureString -String "TestPassword456" -AsPlainText -Force))

                $defaultParameters = @{
                    VcenterServerIP = '192.168.128.15'
                    VsphereHostIP = '192.168.128.13'
                    VcenterCredential = $VcenterCredential
                    SshCredential = $SshCredential
                }
            }

            BeforeEach {
                $setTargetResourceParameters = $defaultParameters.Clone()
            }

            Context 'Testing Set-SshConnection' {

                BeforeEach {

                    $sshConnectionParameters = @{
                        VcenterServerIP = '192.168.128.15'
                        VsphereHostIP = '192.168.128.13'
                        VcenterCredential = $VcenterCredential
                        SshCredential = $SshCredential
                    }

                    Mock -CommandName Set-SshConnection -MockWith {
                        $sshConnectionParameters
                    }

                    $SetSshResult = Set-SshConnection @sshConnectionParameters

                }

                It 'Should not throw an error' {
                    {Set-SshConnection @sshConnectionParameters} |  Should -Not -Throw
                    Assert-MockCalled Set-SshConnection -Exactly -Times 2 -Scope It
                }
            }
        }
        Describe 'DSC_VsphereSshdConfig\Remove-SshConnection' -Tag 'Remove-SshConnection' {
            BeforeAll {

                $defaultParameters = @{
                    VsphereHostIP = '192.168.128.13'
                    SshStatus = $false
                }
            }

            BeforeEach {
                $SshResourceParameters = $defaultParameters.Clone()
            }

            Context 'Testing Remove-SshConnection' {

                BeforeEach {

                    Mock -CommandName Remove-SshConnection -MockWith {
                        $SshTargetResourceParameters
                    }

                    $RemoveSshResult = Remove-SshConnection @SshResourceParameters

                }

                It 'Should not throw an error' {
                    {Remove-SshConnection @SshResourceParameters} | Should -Not -Throw
                    Assert-MockCalled Remove-SshConnection -Exactly -Times 2 -Scope It
                }
            }
        }
    }
}
finally
{
    Invoke-TestCleanup
}

