module PeakData {
    const DATASET_ID = "socal_demo_static";
    const GENERATED_AT = "demo-static";
    const SOURCE = "tools/generate_peaks.py demo";
    const CENTER_LAT_E7 = 341990000;
    const CENTER_LON_E7 = -1182000000;
    const RADIUS_MI = 80;

    // Fields: [lat_e7, lon_e7, elev_m, priority, name]
    const PEAKS = [
        [342244000, -1180572000, 1741, 1000, "Mt Wilson"],
        [342890000, -1176460000, 3068, 980, "Mt Baldy"],
        [342801000, -1181830000, 1879, 920, "Strawberry Peak"],
        [342692000, -1182390000, 1547, 900, "Mt Lukens"],
        [342886000, -1180980000, 1876, 850, "San Gabriel Peak"],
        [342047000, -1181210000, 1709, 830, "Mt Lowe"],
        [342056000, -1183320000, 952, 760, "Verdugo Peak"],
        [342579000, -1181020000, 1414, 650, "Mt Disappointment"],
        [341136000, -1180200000, 991, 620, "Monrovia Peak"],
        [341617000, -1181680000, 494, 600, "Echo Mountain"]
    ];
}
