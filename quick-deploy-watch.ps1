param(
    [string[]]$WatchNamePatterns = @(
        "EPIX PRO - 51mm"
    ),
    [string]$SourceFile = (Join-Path $PSScriptRoot "build.prg")
)

$ErrorActionPreference = "Stop"

if (-not [System.IO.Path]::IsPathRooted($SourceFile)) {
    $SourceFile = Join-Path $PSScriptRoot $SourceFile
}

if (-not (Test-Path -LiteralPath $SourceFile)) {
    throw "Missing build output: $SourceFile - run build-win.bat first."
}

$shell = New-Object -ComObject Shell.Application
$computer = $shell.Namespace(17)

if (-not $computer) {
    throw "Failed to access This PC shell namespace."
}

$watch = $null
foreach ($pattern in $WatchNamePatterns) {
    $match = $computer.Items() | Where-Object { $_.Name -like "*$pattern*" } | Select-Object -First 1
    if ($match) {
        $watch = $match
        break
    }
}

if (-not $watch) {
    $patterns = $WatchNamePatterns -join ", "
    throw "No watch found matching: $patterns."
}

$internal = $watch.GetFolder.Items() | Where-Object { $_.Name -eq "Internal Storage" } | Select-Object -First 1
if (-not $internal) {
    throw "Internal Storage not found on '$($watch.Name)'."
}

$garmin = $internal.GetFolder.Items() | Where-Object { $_.Name -eq "GARMIN" } | Select-Object -First 1
if (-not $garmin) {
    throw "GARMIN folder not found on '$($watch.Name)'."
}

$apps = $garmin.GetFolder.Items() | Where-Object { $_.Name -eq "APPS" } | Select-Object -First 1
if (-not $apps) {
    throw "GARMIN\APPS folder not found on '$($watch.Name)'."
}

Write-Host "Sending build.prg copy command to $($watch.Name)\Internal Storage\GARMIN\APPS ..."
$apps.GetFolder.CopyHere($SourceFile, 16)
Write-Host "Copy command sent."
