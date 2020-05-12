Add-Type -TypeDefinition @"
 namespace VMware.Vim
 {
    public class ViServer : System.IEquatable<ViServer>
    {
        // Property used only for comparing ViServer objects.
        public string Id { get; set; }

        public string Name { get; set; }

        public bool Equals(ViServer ViServer)
        {
            return ViServer != null && this.Id == ViServer.Id && this.Name == ViServer.Name;
        }

        public override bool Equals(object ViServer)
        {
            return this.Equals(ViServer as ViServer);
        }

        public override int GetHashCode()
        {
            return (this.Id + "_" + this.Name + "_").GetHashCode();
        }
    }
    public class VmService : System.IEquatable<VmService>
    {
        // Property used only for comparing VmService objects.
        public string Id { get; set; }

        public string Name { get; set; }

        public bool Equals(VmService VmService)
        {
            return VmService != null && this.Id == VmService.Id && this.Name == VmService.Name;
        }

        public override bool Equals(object VmService)
        {
            return this.Equals(VmService as VmService);
        }

        public override int GetHashCode()
        {
            return (this.Id + "_" + this.Name + "_").GetHashCode();
        }
    }
  }
"@

function Connect-ViServer {
    param(
        [PSObject] $Server,
        [string] $Name
    )

    return New-Object VMware.Vim.ViServer
}

function Get-VmHostService {
    param(
        [PSObject] $Server,
        [string] $Name
    )

    return New-Object VMware.Vim.VmService
}

function Disconnect-VIServer  {
    param(
        [PSObject] $Server,
        [string] $Name
    )

    return $null
}