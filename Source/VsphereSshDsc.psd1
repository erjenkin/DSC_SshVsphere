@{
    # Version number of this module.
    moduleVersion = '1.0.0'

    # ID used to uniquely identify this module
    GUID = '1c8aa1c6-751e-4286-ab0d-4d93a1cb56cf'

    # Author of this module
    Author = 'DSC Community'

    # Company or vendor of this module
    CompanyName = 'DSC Community'

    # Copyright statement for this module
    Copyright = 'Copyright the DSC Community contributors. All rights reserved.'

    # Description of the functionality provided by this module
    Description = 'This resource module contains DSC resources used to apply and manage local group policies by modifying the respective .pol file.'

    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'

    # Minimum version of the common language runtime (CLR) required by this module
    CLRVersion = '4.0'

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules  = @(
    @{ModuleName = 'VMware.VimAutomation.Sdk'; ModuleVersion = '12.0.0.15939651'}
    @{ModuleName = 'VMware.VimAutomation.Common'; ModuleVersion = '12.0.0.15939652'}
    @{ModuleName = 'VMware.Vim'; ModuleVersion ='7.0.0.15939650'}
    @{ModuleName = 'VMware.VimAutomation.Cis.Core'; ModuleVersion = '12.0.0.15939657'}
    @{ModuleName = 'VMware.VimAutomation.Core'; ModuleVersion = '12.0.0.15939655'}
    @{ModuleName = 'VMware.VimAutomation.Storage'; ModuleVersion = '12.0.0.15939648'}
    @{ModuleName = 'VMware.VimAutomation.Vds'; ModuleVersion = '12.0.0.15940185'}
    @{ModuleName = 'Vmware.vSphereDsc'; ModuleVersion = '2.1.0.58'}
)

    # Functions to export from this module
    FunctionsToExport = @()

    # Cmdlets to export from this module
    CmdletsToExport = @()

    # Variables to export from this module
    VariablesToExport = @()

    # Aliases to export from this module
    AliasesToExport = @()

    # DSC resources to export from this module
    DscResourcesToExport = @(
        'VsphereSshdConfig'
    )

    # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
    PrivateData = @{

        PSData = @{
            Prerelease = ''

            # Tags applied to this module. These help with module discovery in online galleries.
            Tags = @('Vsphere', 'Ssh', 'DesiredStateConfiguration', 'DSC', 'DSCResourceKit', 'DSCResource')

            # A URL to the license for this module.
            LicenseUri = 'https://github.com/erjenkin/DSC_SshVsphere/blob/master/LICENSE'

            # A URL to the main website for this project.
            ProjectUri = 'https://github.com/erjenkin/DSC_SshVsphere'

            # ReleaseNotes of this module
            ReleaseNotes = ''

        } # End of PSData hash table

    } # End of PrivateData hash table
  }