Configuration RSAT {

    Param ()

    Import-DscResource -ModuleName PSDSCResources

    Node 'localhost'

    {
        WindowsFeature RSAT {
            Name                 = 'RSAT'
            Ensure               = 'Present'
            IncludeAllSubFeature = $true
        }
    }

}

RSAT