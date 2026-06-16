import argparse
import json
from dataclasses import dataclass
from pathlib import Path


@dataclass(frozen=True)
class Peak:
    name: str
    lat: float
    lon: float
    elev_m: int
    priority: int


DEMO_PEAKS = [
    Peak("Mt Wilson", 34.2244, -118.0572, 1741, 1000),
    Peak("Strawberry Peak", 34.2801, -118.1830, 1879, 920),
    Peak("Mt Lukens", 34.2692, -118.2390, 1547, 900),
    Peak("San Gabriel Peak", 34.2886, -118.0980, 1876, 850),
    Peak("Mt Lowe", 34.2047, -118.1210, 1709, 830),
    Peak("Verdugo Peak", 34.2056, -118.3320, 952, 760),
    Peak("Mt Baldy", 34.2890, -117.6460, 3068, 980),
    Peak("Echo Mountain", 34.1617, -118.1680, 494, 600),
    Peak("Mt Disappointment", 34.2579, -118.1020, 1414, 650),
    Peak("Monrovia Peak", 34.1136, -118.0200, 991, 620),
]


def e7(value: float) -> int:
    return int(round(value * 10_000_000))


def mc_string(value: str) -> str:
    return value.replace("\\", "\\\\").replace('"', '\\"')


def write_peak_data(out_path: Path, dataset_id: str, center_lat: float, center_lon: float, radius_mi: int, peaks: list[Peak]) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    lines = [
        "module PeakData {",
        f'    const DATASET_ID = "{mc_string(dataset_id)}";',
        '    const GENERATED_AT = "demo-static";',
        '    const SOURCE = "tools/generate_peaks.py demo";',
        f"    const CENTER_LAT_E7 = {e7(center_lat)};",
        f"    const CENTER_LON_E7 = {e7(center_lon)};",
        f"    const RADIUS_MI = {radius_mi};",
        "",
        "    // Fields: [lat_e7, lon_e7, elev_m, priority, name]",
        "    const PEAKS = [",
    ]

    for index, peak in enumerate(peaks):
        suffix = "," if index < len(peaks) - 1 else ""
        lines.append(
            f'        [{e7(peak.lat)}, {e7(peak.lon)}, {peak.elev_m}, {peak.priority}, "{mc_string(peak.name)}"]{suffix}'
        )

    lines.extend(["    ];", "}"])
    out_path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def write_debug_json(path: Path, dataset_id: str, center_lat: float, center_lon: float, radius_mi: int, peaks: list[Peak]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    data = {
        "dataset_id": dataset_id,
        "source": "demo-static",
        "center": {"lat": center_lat, "lon": center_lon},
        "radius_mi": radius_mi,
        "peaks": [peak.__dict__ for peak in peaks],
    }
    path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def main() -> None:
    parser = argparse.ArgumentParser(description="Generate a demo PeakData.mc file for PeakLine.")
    parser.add_argument("--lat", type=float, default=34.199, help="Dataset center latitude.")
    parser.add_argument("--lon", type=float, default=-118.200, help="Dataset center longitude.")
    parser.add_argument("--radius-mi", type=int, default=80, help="Dataset radius in miles.")
    parser.add_argument("--dataset-id", default="socal_demo_static", help="Dataset identifier.")
    parser.add_argument("--out", default="source/PeakData.mc", help="Output Monkey C file.")
    parser.add_argument("--debug-json", default="generated/demo.peaks.json", help="Optional debug JSON output.")
    args = parser.parse_args()

    peaks = sorted(DEMO_PEAKS, key=lambda peak: (-peak.priority, peak.name))
    out_path = Path(args.out)
    write_peak_data(out_path, args.dataset_id, args.lat, args.lon, args.radius_mi, peaks)

    if args.debug_json:
        write_debug_json(Path(args.debug_json), args.dataset_id, args.lat, args.lon, args.radius_mi, peaks)

    print(f"Wrote {out_path} with {len(peaks)} demo peaks.")


if __name__ == "__main__":
    main()
