[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$ConnectionString
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# get database name
$csb = New-Object System.Data.SqlClient.SqlConnectionStringBuilder ($ConnectionString)
$dbName = $csb.Database
if ([string]::IsNullOrEmpty($dbName) -or $dbName -eq 'master') {
    throw "database is required"
}
$csb.Database = 'master'

# create blank database
$createScript = Join-Path -Path $PSScriptRoot -ChildPath 'create.sql'
$sql = Get-Content -Path $createScript -Raw
Write-Output $createScript
& .\Invoke-Sql.ps1 -ConnectionString $csb.ToString() -SqlText $sql -ScriptingVariables @{
    DatabaseName = $dbName
}

# scripts to execute
$paths = @(
    'tables/dbo.Blob.sql'
    'tables/dbo.Product.sql'
    'tables/dbo.Customer.sql'
    'tables/dbo.Project.sql'
    'tables/dbo.Connection.sql'
    'tables/dbo.DataFolder.sql'
    'procedures/*.sql'
)

foreach ($path in $paths) {
    # get matching files
    $path = Join-Path -Path $PSScriptRoot -ChildPath $path
    $files = Get-ChildItem -Path $path -Recurse -File

    foreach ($file in $files) {
        # execute script
        $sql = Get-Content -Path $file.FullName -Raw
        Write-Output $file.FullName
        & .\Invoke-Sql.ps1 -ConnectionString $ConnectionString -SqlText $sql
    }
}

# clear pools
[System.Data.SqlClient.SqlConnection]::ClearAllPools()