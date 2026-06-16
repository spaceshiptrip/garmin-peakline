param(
    [string[]]$WatchNamePatterns = @(
        "EPIX PRO - 51mm"
    ),
    [string]$SourceFile = (Join-Path $PSScriptRoot "build.prg"),
    [string]$DestinationFileName = ""
)

$ErrorActionPreference = "Stop"

if (-not [System.IO.Path]::IsPathRooted($SourceFile)) {
    $SourceFile = Join-Path $PSScriptRoot $SourceFile
}

if ([string]::IsNullOrWhiteSpace($DestinationFileName)) {
    $DestinationFileName = [System.IO.Path]::GetFileName($SourceFile)
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
    throw "No watch found matching: $patterns. Connect your Epix Pro via USB and wait for Internal Storage to appear."
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

$appsFolder = $apps.GetFolder
Write-Host "Copying $DestinationFileName to $($watch.Name)\Internal Storage\GARMIN\APPS ..."

$tempSource = $SourceFile
if ([System.IO.Path]::GetFileName($SourceFile) -ne $DestinationFileName) {
    $tempSource = Join-Path ([System.IO.Path]::GetTempPath()) $DestinationFileName
    Copy-Item -LiteralPath $SourceFile -Destination $tempSource -Force
}

$appsFolder.CopyHere($tempSource, 16)

$deadline = (Get-Date).AddSeconds(20)
do {
    Start-Sleep -Milliseconds 500
    $copied = $appsFolder.Items() | Where-Object { $_.Name -eq $DestinationFileName } | Select-Object -First 1
} until ($copied -or (Get-Date) -ge $deadline)

if (-not $copied) {
    throw "Copy did not complete within 20 seconds."
}

if ($tempSource -ne $SourceFile -and (Test-Path -LiteralPath $tempSource)) {
    Remove-Item -LiteralPath $tempSource -Force -ErrorAction SilentlyContinue
}

Write-Host "Done! On your Epix Pro: Apps, PeakLine" -ForegroundColor Green
