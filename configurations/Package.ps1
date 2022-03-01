# Create a package that will audit and apply the configuration (Set)
New-GuestConfigurationPackage `
    -Name 'RSAT' `
    -Configuration './RSAT/localhost.mof' `
    -Type AuditAndSet `
    -Force