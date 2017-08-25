<#
    1. ignore comments & strings
    2. offer scripting variable substitution
    3. split batches based on GO separators
    4. execute on target server
#>
[CmdletBinding()]
param(
    # if provided, will execute sql text using this connection
    [Parameter(Mandatory = $false, Position = 0)]
    [Alias('c')]
    [string]$ConnectionString,

    # sql text to parse & execute
    [Parameter(Mandatory = $true, Position = 1, ValueFromPipeline = $true)]
    [Alias('s')]
    [string]$SqlText,

    # scripting variables to substitute if desired
    [Parameter(Mandatory = $false, Position = 2)]
    [Alias('v')]
    [HashTable]$ScriptingVariables,

    # will prompt user for missing scripting variables' values
    [Alias('i')]
    [switch]$Interactive = $false,

    # will return the parsed batches as an array of strings
    [Alias('b')]
    [switch]$ReturnParsedBatches = $false,

    # time in seconds; timeout will default to unlimited (0)
    [Alias('t')]
    [int]$CommandTimeout = 0
)
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# constants
$multilineCommentRegex = '/\*(?>/\*(?<OPEN>)|\*/(?<-OPEN>)|(?!/\*|\*/).)+(?(OPEN)(?!))\*/'
$singleLineCommentRegex = '--(.*?)$'
$simpleStringRegex = "('[^']*')+"
$quotedIdentifierRegex = '("[^"]*")+'
$bracketIdentifierRegex = '\[(\]\]|[^\]])*\]'
$scriptingVariableRegex = '\$\([^\s\(\)\$]+\)'
$goRegex = '^\s*GO\s*\d*\s*$'

# set text
$text = $SqlText

# remove comments
$regex = [string]::Join('|',
    $multilineCommentRegex,
    $singleLineCommentRegex,
    $simpleStringRegex,
    $quotedIdentifierRegex,
    $bracketIdentifierRegex
)

$text = [System.Text.RegularExpressions.Regex]::Replace($text,
    $regex,
    { param($x)
        if ($x.Value.StartsWith('/*')) {
            return [string]::Empty
        }
        elseif ($x.Value.StartsWith('--')) {
            return [System.Environment]::NewLine
        }
        else {
            return $x.Value
        }
    },
    [System.Text.RegularExpressions.RegexOptions]::Singleline -bor
    [System.Text.RegularExpressions.RegexOptions]::Multiline)

# replace scripting variables
if ($ScriptingVariables -ne $null) {
    foreach ($scriptVar in $ScriptingVariables.Keys) {
        $regex = "\$\($([System.Text.RegularExpressions.Regex]::Escape($scriptVar))\)"
        $text = [System.Text.RegularExpressions.Regex]::Replace($text,
            $regex,
            $ScriptingVariables[$scriptVar],
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    }
}

# if interactive, offer to replace remaining scripting variables
if ($Interactive) {
    $text = [System.Text.RegularExpressions.Regex]::Replace($text,
        $scriptingVariableRegex,
        { param($x)
            Write-Host "provide value for scripting variable '$($x.Value)':"
            $value = Read-Host
            if ([string]::IsNullOrWhiteSpace($value)) {
                Write-Warning "no value substituted for '$($x.Value)'"
                return $x.Value
            }
            else {
                return $value
            }
        },
        [System.Text.RegularExpressions.RegexOptions]::Multiline)
}

# separate batches by GO
$regex = [string]::Join('|',
        $simpleStringRegex,
        $quotedIdentifierRegex,
        $bracketIdentifierRegex,
        $goRegex
    )

$matches = [System.Text.RegularExpressions.Regex]::Matches($text,
    $regex,
    [System.Text.RegularExpressions.RegexOptions]::IgnoreCase -bor
    [System.Text.RegularExpressions.RegexOptions]::Singleline -bor
    [System.Text.RegularExpressions.RegexOptions]::Multiline)

$batches = @()
$index = 0
foreach ($match in $matches) {
    if (-not ($match.Value.StartsWith("'") -or $match.Value.StartsWith('"') -or $match.Value.StartsWith('['))) {
        # parse batch
        $length = $match.Index - $index
        $batch = $text.Substring($index, $length)
        $index += $length + $match.Value.Length
        # get count
        $count = 1
        $countMatch = [System.Text.RegularExpressions.Regex]::Match($match.Value, '\d+')
        if ($countMatch.Success) {
            $count = [int]::Parse($countMatch.Value)
        }
        # add batch(es) to list
        for ($i = 0; $i -lt $count; $i++) {
            $batches += $batch
        }
    }
}
# add last batch
$batches += $text.Substring($index, $text.Length - $index)

Write-Verbose "$($batches.Length) batches parsed"
if ($ReturnParsedBatches) {
    Write-Output $batches
}

# execute batches
if (-not [string]::IsNullOrEmpty($ConnectionString)) {
    $conn = New-Object System.Data.SqlClient.SqlConnection ($ConnectionString)
    try {
        $conn.Open()
        foreach ($batch in $batches) {
            if (-not [string]::IsNullOrWhiteSpace($batch)) {
                $cmd = New-Object System.Data.SqlClient.SqlCommand ($batch, $conn)
                $cmd.CommandTimeout = $CommandTimeout
                try {
                    $null = $cmd.ExecuteNonQuery()
                }
                finally {
                    $cmd.Dispose()
                }
            }
        }
    }
    finally {
        $conn.Dispose()
    }
}