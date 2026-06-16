# PeakLine

PeakLine is a Garmin Connect IQ app prototype for labeling nearby mountain peaks on a simple heading-relative horizon line.

The current implementation is Stage 0/1:

- Garmin device app scaffold for `epix2pro51mm`
- static demo peak dataset
- manual heading controls for simulator testing
- range cycling
- Windows build/sim/deploy scripts adapted from the contour watchface repo

See `PEAKS-PLAN.md` for the full product and implementation plan.

## Setup

Create local build config:

```powershell
Copy-Item .\build-config.example.bat .\build-config.local.bat
notepad .\build-config.local.bat
```

`build-config.local.bat` is ignored by git. Set:

```bat
set "DEVELOPER_KEY=%USERPROFILE%\Workspaces\garmin-fenix-simple-intervals\developer_key"
set "DEVICE_ID=epix2pro51mm"
```

`SDK_BIN` can be omitted if the Garmin Connect IQ SDK is installed under:

```text
%APPDATA%\Garmin\ConnectIQ\Sdks
```

## Build

```powershell
.\build-win.bat
```

## Simulate

Start the simulator first if needed:

```powershell
$sdkBin = (Get-ChildItem "$env:APPDATA\Garmin\ConnectIQ\Sdks" -Directory -Filter "connectiq-sdk-win-*" | Sort-Object Name -Descending | Select-Object -First 1).FullName + "\bin"
& "$sdkBin\connectiq.bat"
```

Then run:

```powershell
.\simulate-win.bat
```

## Quick Deploy

Build first, then with the watch connected:

```powershell
.\quick-deploy-win.bat
```

To deploy this app with a clearer watch-side PRG filename, use:

```powershell
.\quick-peakline-deploy.bat
```

That copies the current `build.prg` to the watch as:

```text
GARMIN\APPS\peakline.prg
```

## Regenerate Demo Peak Data

The current generator has no external dependencies and writes the static demo dataset:

```powershell
.\venv\Scripts\python.exe tools\generate_peaks.py --out source\PeakData.mc
```

Future work will replace this with an Overpass/OSM-backed generator.

## Simulator Controls

- Up: rotate heading left
- Down: rotate heading right
- Next page: increase range
- Previous page: decrease range
- Select: toggle heading lock label
- Back: exit
