import Foundation

/// The data-driven compatibility registry. Adding a model means adding a profile here, with
/// sources and hardware evidence. Never mark something Verified without the owner's hardware test.
public enum DeviceRegistry {
    public static let opoService = "0000079A-D102-11E1-9B23-00025B00A5A5"
    static let opoBLE = BLEParameters(serviceUUID: opoService,
                                      writeUUID: "0100079A-D102-11E1-9B23-00025B00A5A5",
                                      notifyUUID: "0200079A-D102-11E1-9B23-00025B00A5A5")

    /// Noise-control values for the "NC tree" models (Buds 3, Buds Pro 2/3, Nord Buds 3 Pro).
    /// Hypothesis from S4's set/read tables and S12's values verified on the OPPO Enco Air5 Pro,
    /// which has an identical tree; S11 disagrees on the level bits (ProtocolSources §7, C2).
    static let ncTreeModes: [NoiseModeOption] = [
        NoiseModeOption(.off, set: [0x01], read: 0x0008),
        NoiseModeOption(.transparency, set: [0x04], read: 0x0100),
        NoiseModeOption(.noiseCancelling(nil), set: [0x02], read: 0x0002),
        NoiseModeOption(.noiseCancelling(.smart), set: [0x80], read: 0x0080),
        NoiseModeOption(.noiseCancelling(.deep), set: [0x10], read: 0x0010),
        NoiseModeOption(.noiseCancelling(.medium), set: [0x20], read: 0x0020),
        NoiseModeOption(.noiseCancelling(.light), set: [0x40], read: 0x0040),
    ]

    public static let onePlusBuds3 = DeviceProfile(
        id: "oneplus-buds-3",
        manufacturer: .onePlus,
        model: "OnePlus Buds 3 (E509A)",
        displayName: "OnePlus Buds 3",
        bluetoothNames: ["OnePlus Buds 3"],
        // Both bearers are exposed (Observed, PhaseB-Report §4). RFCOMM is HeyMelody's SPP route.
        transports: [.rfcomm, .ble],
        rfcommServiceUUIDs: [opoService],
        ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(
            productIDs: ["063C14"],
            noiseModes: ncTreeModes,
            equalizerPresets: [
                EQPresetOption(id: 0, name: "Balanced"),
                EQPresetOption(id: 1, name: "Deep Sea Bass"),
                EQPresetOption(id: 2, name: "Pure Vocals"),
                EQPresetOption(id: 3, name: "Bright & Crisp", minimumFirmware: 119),
            ],
            featureStatusIDs: [0x05, 0x04, 0x0B, 0x11, 0x18, 0x06, 0x1B, 0x1D, 0x1C],
            gameModeFeatureID: 0x06,
            wearDetectionFeatureID: 0x04,
            dualConnectionFeatureID: 0x11,
            gestureFunctions: [
                GestureAction.single.rawValue: [0x00, 0x01],
                GestureAction.double.rawValue: [0x03, 0x01, 0x05, 0x06, 0x11, 0x00],
                GestureAction.triple.rawValue: [0x03, 0x05, 0x06, 0x11, 0x00],
                GestureAction.hold.rawValue: [0x08],
                GestureAction.slide.rawValue: [0x07, 0x0A, 0x00],
            ]),
        status: .verified,
        capabilities: [
            .battery: .verified, .noiseControl: .verified, .equalizer: .verified,
            .gestures: .verified, .gameMode: .verified, .wearDetection: .experimental,
            .dualConnection: .experimental, .deviceInfo: .verified,
        ],
        testedFirmware: ["127.127.101"],
        limitations: [
            "Verified on firmware 127.127.101 (2026-10-12): every read, all 7 noise modes, 4 EQ presets, game mode, one gesture change; pushes for noise and EQ.",
            "In-ear detection: switch 0x04 toggles and is confirmed, but its effect is not yet confirmed (sources disagree on the id).",
            "Dual connection: read only so far; not toggled (switching it off could drop the Mac's link).",
            "No Adaptive mode in the vendor model list.",
            "Custom EQ curves are not implemented.",
        ],
        sources: ["S4", "S5", "S7", "S10", "S11", "S12", "PhaseB-Report §4"],
        evidence: [
            HardwareEvidence(date: "2026-10-12", firmware: nil,
                             what: "Read-only: SDP 079A on RFCOMM channel 15 and BLE GATT 0100/0200079A observed; advertisement product id 063C14",
                             by: "owner"),
            HardwareEvidence(date: "2026-10-12", firmware: "127.127.101",
                             what: "Observed over RFCOMM ch 15 (owner-approved): handshake, product id 063C14, firmware, battery, noise/EQ/feature/gesture reads; awaiting owner confirmation and set-command tests",
                             by: "owner-approved probe"),
            HardwareEvidence(date: "2026-10-12", firmware: "127.127.101",
                             what: "Feature test at the owner's request: 17/17 changes acknowledged and read back (noise Off/Transparency/ANC + Smart/Deep/Medium/Light, EQ 0-3, game mode, in-ear switch, left double-tap gesture), all restored; noise and EQ push events observed",
                             by: "owner-requested test"),
        ])

    public static let nordBuds4Pro = DeviceProfile(
        id: "oneplus-nord-buds-4-pro",
        manufacturer: .onePlus,
        model: "OnePlus Nord Buds 4 Pro",
        displayName: "OnePlus Nord Buds 4 Pro",
        bluetoothNames: ["OnePlus Nord Buds 4 Pro", "Nord Buds 4 Pro", "OnePlus Buds 4 Pro", "Omraj’s OnePlus Buds 4 Pro", "Omraj's OnePlus Buds 4 Pro"],
        transports: [.rfcomm, .ble],
        rfcommServiceUUIDs: [opoService, standardSPP],
        ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(
            productIDs: ["066814"],
            noiseModes: ncTreeModes,
            equalizerPresets: [
                EQPresetOption(id: 0, name: "Balanced"),
                EQPresetOption(id: 1, name: "Deep Sea Bass"),
                EQPresetOption(id: 2, name: "Pure Vocals"),
                EQPresetOption(id: 3, name: "Bright & Crisp"),
            ],
            featureStatusIDs: [0x04, 0x05, 0x06, 0x0B, 0x0C, 0x11, 0x18, 0x1B, 0x1D],
            gameModeFeatureID: 0x06,
            wearDetectionFeatureID: 0x04,
            dualConnectionFeatureID: 0x11,
            spatialAudioFeatureID: 0x0B,
            bassWaveFeatureID: 0x0C,
            gestureFunctions: [
                GestureAction.single.rawValue: [0x00, 0x01],
                GestureAction.double.rawValue: [0x03, 0x01, 0x05, 0x06, 0x11, 0x00],
                GestureAction.triple.rawValue: [0x03, 0x05, 0x06, 0x11, 0x00],
                GestureAction.hold.rawValue: [0x08, 0x03, 0x00],
                GestureAction.slide.rawValue: [0x07, 0x00],
            ]),
        status: .verified,
        capabilities: [
            .battery: .verified, .noiseControl: .verified, .equalizer: .verified,
            .gestures: .verified, .gameMode: .verified, .wearDetection: .verified,
            .dualConnection: .verified, .spatialAudio: .verified, .bassWave: .verified,
            .deviceInfo: .verified,
        ],
        testedFirmware: ["158.158.106"],
        limitations: [
            "Hardware-verified on OnePlus Nord Buds 4 Pro (fw 158.158.106): RFCOMM ch 7, product ID 066814, battery readings, ANC Smart mode, EQ presets, Spatial audio (0x0B), BassWave (0x0C), Game mode (0x06), In-ear detection (0x04), and Dual connection (0x11).",
        ],
        sources: ["Hardware-tested 2026-11-02", "S4", "S5", "S12"],
        evidence: [
            HardwareEvidence(date: "2026-11-02", firmware: "158.158.106",
                             what: "Live probe verified: RFCOMM ch 7, product ID 066814, battery L/R readings, ANC Smart read (0x0080), EQ Balanced (0), feature status switches (wear 0x04, game 0x06, spatial 0x0B, BassWave 0x0C, dual 0x11), and 14 gestures with stem volume slide.",
                             by: "Antigravity active probe")
        ])

    public static let nordBuds3Pro = DeviceProfile(
        id: "oneplus-nord-buds-3-pro",
        manufacturer: .onePlus,
        model: "OnePlus Nord Buds 3 Pro",
        displayName: "OnePlus Nord Buds 3 Pro",
        bluetoothNames: ["OnePlus Nord Buds 3 Pro"],
        transports: [.ble, .rfcomm],
        rfcommServiceUUIDs: [opoService],
        ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(
            productIDs: ["064414"],
            noiseModes: ncTreeModes,
            featureStatusIDs: [0x05, 0x04, 0x0B, 0x0C, 0x11, 0x18, 0x06, 0x1B, 0x1D],
            gameModeFeatureID: 0x06,
            wearDetectionFeatureID: 0x04,
            dualConnectionFeatureID: 0x11,
            spatialAudioFeatureID: 0x0B,
            bassWaveFeatureID: 0x0C,
            gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .bassWave: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [],
        limitations: [
            "Protocol reference model (S1, S2 tested it over BLE); not tested with MacMelody.",
            "Reported to offer only battery and wear events (S4 issue #2).",
        ],
        sources: ["S1", "S2", "S3", "S4"],
        evidence: [])

    static let standardSPP = "00001101-0000-1000-8000-00805F9B34FB"

    static let onePlusEQ: [EQPresetOption] = [
        EQPresetOption(id: 0, name: "Balanced"),
        EQPresetOption(id: 1, name: "Deep Sea Bass"),
        EQPresetOption(id: 2, name: "Pure Vocals"),
        EQPresetOption(id: 3, name: "Bright & Crisp"),
    ]

    static let dynaudioEQ: [EQPresetOption] = [
        EQPresetOption(id: 0, name: "Dynaudio Balanced"),
        EQPresetOption(id: 1, name: "Bold Bass"),
        EQPresetOption(id: 2, name: "Serenade"),
        EQPresetOption(id: 3, name: "Dynaudio Clear"),
    ]

    static let oppoMasterEQ: [EQPresetOption] = [
        EQPresetOption(id: 0, name: "Original Sound"),
        EQPresetOption(id: 1, name: "Bass Boost"),
        EQPresetOption(id: 2, name: "Clear Vocals"),
    ]

    static let basicNCModes: [NoiseModeOption] = [
        NoiseModeOption(.off, set: [0x01], read: 0x0008),
        NoiseModeOption(.transparency, set: [0x04], read: 0x0100),
        NoiseModeOption(.noiseCancelling(nil), set: [0x02], read: 0x0002),
    ]

    static let oppoGestures: [UInt8: [UInt8]] = [
        GestureAction.single.rawValue: [0x00, 0x01],
        GestureAction.double.rawValue: [0x03, 0x01, 0x05, 0x06, 0x11, 0x00],
        GestureAction.triple.rawValue: [0x03, 0x05, 0x06, 0x11, 0x00],
        GestureAction.hold.rawValue: [0x08, 0x03, 0x00],
        GestureAction.slide.rawValue: [0x07, 0x0A, 0x00],
    ]

    // MARK: - Expanded OnePlus Profiles

    public static let onePlusBudsPro3 = DeviceProfile(
        id: "oneplus-buds-pro-3", manufacturer: .onePlus, model: "OnePlus Buds Pro 3", displayName: "OnePlus Buds Pro 3",
        bluetoothNames: ["OnePlus Buds Pro 3", "Buds Pro 3"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["064014"], noiseModes: ncTreeModes, equalizerPresets: dynaudioEQ,
                           featureStatusIDs: [0x04, 0x05, 0x06, 0x0B, 0x11, 0x18, 0x1B], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Dynaudio dual drivers, 50dB adaptive ANC, spatial audio, and stem squeeze/slide."], sources: ["S4", "S5"], evidence: [])

    public static let onePlusBudsPro2 = DeviceProfile(
        id: "oneplus-buds-pro-2", manufacturer: .onePlus, model: "OnePlus Buds Pro 2", displayName: "OnePlus Buds Pro 2",
        bluetoothNames: ["OnePlus Buds Pro 2", "OnePlus Buds Pro 2R", "Buds Pro 2", "Buds Pro 2R"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["062014", "062414"], noiseModes: ncTreeModes, equalizerPresets: dynaudioEQ,
                           featureStatusIDs: [0x04, 0x05, 0x06, 0x0B, 0x11, 0x18, 0x1B], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Dynaudio co-tuned dual drivers, ANC tree, and spatial audio."], sources: ["S4", "S5"], evidence: [])

    public static let onePlusBuds4 = DeviceProfile(
        id: "oneplus-buds-4", manufacturer: .onePlus, model: "OnePlus Buds 4", displayName: "OnePlus Buds 4",
        bluetoothNames: ["OnePlus Buds 4", "Buds 4"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["065414"], noiseModes: ncTreeModes, equalizerPresets: onePlusEQ,
                           featureStatusIDs: [0x04, 0x05, 0x06, 0x0B, 0x0C, 0x11], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, bassWaveFeatureID: 0x0C, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .bassWave: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Fully documented OPO protocol parameters; 50dB ANC tree and low latency."], sources: ["S4", "S5"], evidence: [])

    public static let nordBuds4 = DeviceProfile(
        id: "oneplus-nord-buds-4", manufacturer: .onePlus, model: "OnePlus Nord Buds 4", displayName: "OnePlus Nord Buds 4",
        bluetoothNames: ["OnePlus Nord Buds 4", "Nord Buds 4"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["066414"], noiseModes: ncTreeModes, equalizerPresets: onePlusEQ,
                           featureStatusIDs: [0x04, 0x06, 0x0C, 0x11], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, dualConnectionFeatureID: 0x11, bassWaveFeatureID: 0x0C, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .dualConnection: .experimental, .bassWave: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["48dB ANC, BassWave algorithm, dual connection, and in-ear wear detection."], sources: ["S4", "S5"], evidence: [])

    public static let nordBuds3 = DeviceProfile(
        id: "oneplus-nord-buds-3", manufacturer: .onePlus, model: "OnePlus Nord Buds 3", displayName: "OnePlus Nord Buds 3",
        bluetoothNames: ["OnePlus Nord Buds 3", "Nord Buds 3"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["065014"], noiseModes: ncTreeModes, equalizerPresets: onePlusEQ,
                           featureStatusIDs: [0x04, 0x06, 0x0C, 0x11], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, dualConnectionFeatureID: 0x11, bassWaveFeatureID: 0x0C, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .dualConnection: .experimental, .bassWave: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["32dB ANC, BassWave, dual connection, and low-latency game mode."], sources: ["S4", "S5"], evidence: [])

    public static let nordBuds3r = DeviceProfile(
        id: "oneplus-nord-buds-3r", manufacturer: .onePlus, model: "OnePlus Nord Buds 3r", displayName: "OnePlus Nord Buds 3r",
        bluetoothNames: ["OnePlus Nord Buds 3r", "Nord Buds 3r"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["064814"], noiseModes: [], equalizerPresets: onePlusEQ,
                           featureStatusIDs: [0x06, 0x0C, 0x11], gameModeFeatureID: 0x06,
                           dualConnectionFeatureID: 0x11, bassWaveFeatureID: 0x0C, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .dualConnection: .experimental, .bassWave: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Non-ANC model: battery, BassWave, dual connection, EQ, and low latency."], sources: ["S4", "S5"], evidence: [])

    public static let nordBuds2 = DeviceProfile(
        id: "oneplus-nord-buds-2", manufacturer: .onePlus, model: "OnePlus Nord Buds 2", displayName: "OnePlus Nord Buds 2",
        bluetoothNames: ["OnePlus Nord Buds 2", "Nord Buds 2"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["062C14"], noiseModes: basicNCModes, equalizerPresets: onePlusEQ,
                           featureStatusIDs: [0x04, 0x06, 0x0C], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, bassWaveFeatureID: 0x0C, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .bassWave: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Core ANC, EQ, wear detection, and BassWave supported."], sources: ["S4", "S5"], evidence: [])

    public static let nordBuds2r = DeviceProfile(
        id: "oneplus-nord-buds-2r", manufacturer: .onePlus, model: "OnePlus Nord Buds 2r", displayName: "OnePlus Nord Buds 2r",
        bluetoothNames: ["OnePlus Nord Buds 2r", "Nord Buds 2r"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["062814"], noiseModes: [], equalizerPresets: onePlusEQ,
                           featureStatusIDs: [0x06, 0x0C], gameModeFeatureID: 0x06,
                           bassWaveFeatureID: 0x0C, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .bassWave: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Non-ANC model: battery, EQ, BassWave, and game mode."], sources: ["S4", "S5"], evidence: [])

    public static let nordBuds = DeviceProfile(
        id: "oneplus-nord-buds", manufacturer: .onePlus, model: "OnePlus Nord Buds", displayName: "OnePlus Nord Buds",
        bluetoothNames: ["OnePlus Nord Buds", "Nord Buds"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["061414"], noiseModes: [], equalizerPresets: onePlusEQ,
                           featureStatusIDs: [0x06], gameModeFeatureID: 0x06, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["First-gen Nord Buds without ANC: battery, Sound Master EQ, and ultra-low latency."], sources: ["S4", "S5"], evidence: [])

    public static let onePlusBudsZ2 = DeviceProfile(
        id: "oneplus-buds-z2", manufacturer: .onePlus, model: "OnePlus Buds Z2", displayName: "OnePlus Buds Z2",
        bluetoothNames: ["OnePlus Buds Z2", "Buds Z2"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["060414"], noiseModes: basicNCModes, equalizerPresets: onePlusEQ,
                           featureStatusIDs: [0x04, 0x06], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Core ANC and low-latency mode supported."], sources: ["S4", "S5"], evidence: [])

    public static let onePlusBudsPro = DeviceProfile(
        id: "oneplus-buds-pro", manufacturer: .onePlus, model: "OnePlus Buds Pro", displayName: "OnePlus Buds Pro",
        bluetoothNames: ["OnePlus Buds Pro", "Buds Pro"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService, standardSPP], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["060C14", "060814"], noiseModes: ncTreeModes, equalizerPresets: onePlusEQ,
                           featureStatusIDs: [0x04, 0x06], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Legacy 1107 service fallback included."], sources: ["S5"], evidence: [])

    // MARK: - Expanded OPPO Profiles

    public static let oppoEncoX4 = DeviceProfile(
        id: "oppo-enco-x4", manufacturer: .oppo, model: "OPPO Enco X4", displayName: "OPPO Enco X4",
        bluetoothNames: ["OPPO Enco X4", "Enco X4"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["062810"], noiseModes: ncTreeModes, equalizerPresets: dynaudioEQ,
                           featureStatusIDs: [0x04, 0x05, 0x06, 0x0B, 0x11], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Dynaudio co-created dual-engine 55dB flagship with spatial audio and touch slide."], sources: ["S4", "S5", "S12"], evidence: [])

    public static let oppoEncoX2 = DeviceProfile(
        id: "oppo-enco-x2", manufacturer: .oppo, model: "OPPO Enco X2", displayName: "OPPO Enco X2",
        bluetoothNames: ["OPPO Enco X2", "Enco X2"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["060C10", "060E10"], noiseModes: ncTreeModes, equalizerPresets: dynaudioEQ,
                           featureStatusIDs: [0x04, 0x05, 0x06, 0x0B, 0x11], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Flagship Dynaudio dual-driver ANC model with touch gestures."], sources: ["S4", "S5", "S12"], evidence: [])

    public static let oppoEncoAir5Pro = DeviceProfile(
        id: "oppo-enco-air-5-pro", manufacturer: .oppo, model: "OPPO Enco Air5 Pro", displayName: "OPPO Enco Air5 Pro",
        bluetoothNames: ["OPPO Enco Air5 Pro", "OPPO Enco Air 5 Pro", "Enco Air5 Pro", "Enco Air 5 Pro"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["063810"], noiseModes: ncTreeModes, equalizerPresets: oppoMasterEQ,
                           featureStatusIDs: [0x04, 0x05, 0x06, 0x0B, 0x11], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["55dB smart ANC tree, spatial audio, and dual connection."], sources: ["S4", "S5"], evidence: [])

    public static let oppoEncoAir5 = DeviceProfile(
        id: "oppo-enco-air-5", manufacturer: .oppo, model: "OPPO Enco Air5", displayName: "OPPO Enco Air5",
        bluetoothNames: ["OPPO Enco Air5", "OPPO Enco Air 5", "Enco Air5", "Enco Air 5"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["063410"], noiseModes: [], equalizerPresets: oppoMasterEQ,
                           featureStatusIDs: [0x06, 0x11], gameModeFeatureID: 0x06,
                           dualConnectionFeatureID: 0x11, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .dualConnection: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Semi-in-ear non-ANC model: battery, Master EQ, dual connection, and game mode."], sources: ["S4", "S5"], evidence: [])

    public static let oppoEncoAir4Pro = DeviceProfile(
        id: "oppo-enco-air-4-pro", manufacturer: .oppo, model: "OPPO Enco Air4 Pro", displayName: "OPPO Enco Air4 Pro",
        bluetoothNames: ["OPPO Enco Air4 Pro", "OPPO Enco Air 4 Pro", "Enco Air4 Pro", "Enco Air 4 Pro"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["063010"], noiseModes: ncTreeModes, equalizerPresets: oppoMasterEQ,
                           featureStatusIDs: [0x04, 0x05, 0x06, 0x11], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, dualConnectionFeatureID: 0x11, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .dualConnection: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["49dB OPO protocol ANC tree and dual-device connection."], sources: ["S4", "S5"], evidence: [])

    public static let oppoEncoAir3Pro = DeviceProfile(
        id: "oppo-enco-air-3-pro", manufacturer: .oppo, model: "OPPO Enco Air3 Pro", displayName: "OPPO Enco Air3 Pro",
        bluetoothNames: ["OPPO Enco Air3 Pro", "OPPO Enco Air 3 Pro", "Enco Air3 Pro", "Enco Air 3 Pro"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["061810", "061C10"], noiseModes: ncTreeModes, equalizerPresets: oppoMasterEQ,
                           featureStatusIDs: [0x04, 0x05, 0x06, 0x0B, 0x11], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["LDAC & Bamboo fiber ANC model with Alive Audio (spatial sound)."], sources: ["S4", "S5", "S12"], evidence: [])

    public static let oppoEncoAir3 = DeviceProfile(
        id: "oppo-enco-air-3", manufacturer: .oppo, model: "OPPO Enco Air3", displayName: "OPPO Enco Air3",
        bluetoothNames: ["OPPO Enco Air3", "OPPO Enco Air 3", "Enco Air3", "Enco Air 3"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["061410"], noiseModes: [], equalizerPresets: oppoMasterEQ,
                           featureStatusIDs: [0x06, 0x11], gameModeFeatureID: 0x06,
                           dualConnectionFeatureID: 0x11, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .dualConnection: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Semi-in-ear: battery, EQ, dual connection, and game mode."], sources: ["S4", "S5"], evidence: [])

    public static let oppoEncoAir2Pro = DeviceProfile(
        id: "oppo-enco-air-2-pro", manufacturer: .oppo, model: "OPPO Enco Air2 Pro", displayName: "OPPO Enco Air2 Pro",
        bluetoothNames: ["OPPO Enco Air2 Pro", "OPPO Enco Air 2 Pro", "Enco Air2 Pro", "Enco Air 2 Pro"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["060810"], noiseModes: basicNCModes, equalizerPresets: oppoMasterEQ,
                           featureStatusIDs: [0x04, 0x06], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["28dB ANC, in-ear detection, and Enco Live presets."], sources: ["S4", "S5"], evidence: [])

    public static let oppoEncoBuds3ProPlus = DeviceProfile(
        id: "oppo-enco-buds-3-pro-plus", manufacturer: .oppo, model: "OPPO Enco Buds3 Pro+", displayName: "OPPO Enco Buds3 Pro+",
        bluetoothNames: ["OPPO Enco Buds3 Pro+", "OPPO Enco Buds 3 Pro+", "Enco Buds3 Pro+", "Enco Buds 3 Pro+"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["062610"], noiseModes: basicNCModes, equalizerPresets: oppoMasterEQ,
                           featureStatusIDs: [0x06, 0x11], gameModeFeatureID: 0x06,
                           dualConnectionFeatureID: 0x11, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .dualConnection: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["32dB hybrid ANC, dual device connection, and Master EQ."], sources: ["S4", "S5"], evidence: [])

    public static let oppoEncoBuds3Pro = DeviceProfile(
        id: "oppo-enco-buds-3-pro", manufacturer: .oppo, model: "OPPO Enco Buds3 Pro", displayName: "OPPO Enco Buds3 Pro",
        bluetoothNames: ["OPPO Enco Buds3 Pro", "OPPO Enco Buds 3 Pro", "Enco Buds3 Pro", "Enco Buds 3 Pro"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["062410"], noiseModes: basicNCModes, equalizerPresets: oppoMasterEQ,
                           featureStatusIDs: [0x06, 0x11], gameModeFeatureID: 0x06,
                           dualConnectionFeatureID: 0x11, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .dualConnection: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["32dB hybrid ANC, dual connection, and Master EQ."], sources: ["S4", "S5"], evidence: [])

    public static let oppoEncoBuds3 = DeviceProfile(
        id: "oppo-enco-buds-3", manufacturer: .oppo, model: "OPPO Enco Buds3", displayName: "OPPO Enco Buds3",
        bluetoothNames: ["OPPO Enco Buds3", "OPPO Enco Buds 3", "Enco Buds3", "Enco Buds 3"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["062010"], noiseModes: [], equalizerPresets: oppoMasterEQ,
                           featureStatusIDs: [0x06], gameModeFeatureID: 0x06, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Entry-level non-ANC model: battery, Master EQ, and low latency."], sources: ["S4", "S5"], evidence: [])

    public static let oppoEncoBuds2 = DeviceProfile(
        id: "oppo-enco-buds-2", manufacturer: .oppo, model: "OPPO Enco Buds2", displayName: "OPPO Enco Buds2",
        bluetoothNames: ["OPPO Enco Buds2", "OPPO Enco Buds 2", "Enco Buds2", "Enco Buds 2"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["061010", "061210"], noiseModes: [], equalizerPresets: oppoMasterEQ,
                           featureStatusIDs: [0x06], gameModeFeatureID: 0x06, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Enco Live stereo sound effects, battery, and low-latency mode."], sources: ["S4", "S5"], evidence: [])

    public static let oppoEncoFree3 = DeviceProfile(
        id: "oppo-enco-free-3", manufacturer: .oppo, model: "OPPO Enco Free3", displayName: "OPPO Enco Free3",
        bluetoothNames: ["OPPO Enco Free3", "OPPO Enco Free 3", "Enco Free3"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["061A10"], noiseModes: ncTreeModes, equalizerPresets: oppoMasterEQ,
                           featureStatusIDs: [0x04, 0x06, 0x11], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Bamboo diaphragm ANC model."], sources: ["S4", "S5"], evidence: [])

    public static let oppoEncoX = DeviceProfile(
        id: "oppo-enco-x", manufacturer: .oppo, model: "OPPO Enco X", displayName: "OPPO Enco X",
        bluetoothNames: ["OPPO Enco X", "Enco X"], transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["060410"], noiseModes: ncTreeModes, equalizerPresets: dynaudioEQ,
                           featureStatusIDs: [0x04, 0x06, 0x11], gameModeFeatureID: 0x06,
                           wearDetectionFeatureID: 0x04, gestureFunctions: oppoGestures),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gameMode: .experimental,
                       .wearDetection: .experimental, .deviceInfo: .experimental, .gestures: .experimental],
        testedFirmware: [], limitations: ["Dynaudio co-created ANC flagship."], sources: ["S4", "S5"], evidence: [])

    // MARK: - Expanded realme Profiles

    public static let realmeBudsAir8Pro = DeviceProfile(
        id: "realme-buds-air-8-pro", manufacturer: .realme, model: "Realme Buds Air 8 Pro", displayName: "Realme Buds Air 8 Pro",
        bluetoothNames: ["realme Buds Air 8 Pro", "Realme Buds Air 8 Pro", "Buds Air 8 Pro"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["065C12"], noiseModes: realmeLevelModes, equalizerPresets: realmeEQ,
                           featureStatusIDs: [0x04, 0x06, 0x0B, 0x11], gameModeFeatureID: 0x06, wearDetectionFeatureID: 0x04,
                           dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .wearDetection: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations, sources: ["S4", "S5"], evidence: [])

    public static let realmeBudsAir8 = DeviceProfile(
        id: "realme-buds-air-8", manufacturer: .realme, model: "Realme Buds Air 8", displayName: "Realme Buds Air 8",
        bluetoothNames: ["realme Buds Air 8", "Realme Buds Air 8", "Buds Air 8"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["065812"], noiseModes: realmeLevelModes, equalizerPresets: realmeEQ,
                           featureStatusIDs: [0x04, 0x06, 0x11], gameModeFeatureID: 0x06, wearDetectionFeatureID: 0x04,
                           dualConnectionFeatureID: 0x11, gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .wearDetection: .experimental, .dualConnection: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations, sources: ["S4", "S5"], evidence: [])

    public static let realmeBudsAir7Pro = DeviceProfile(
        id: "realme-buds-air-7-pro", manufacturer: .realme, model: "Realme Buds Air 7 Pro", displayName: "Realme Buds Air 7 Pro",
        bluetoothNames: ["realme Buds Air 7 Pro", "Realme Buds Air 7 Pro", "realme Buds Air7 Pro", "Buds Air 7 Pro", "Buds Air7 Pro"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["064C12"], noiseModes: realmeLevelModes, equalizerPresets: realmeEQ,
                           featureStatusIDs: [0x04, 0x06, 0x0B, 0x11], gameModeFeatureID: 0x06, wearDetectionFeatureID: 0x04,
                           dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .wearDetection: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations, sources: ["S4"], evidence: [])

    public static let realmeBudsAir7 = DeviceProfile(
        id: "realme-buds-air-7", manufacturer: .realme, model: "Realme Buds Air 7", displayName: "Realme Buds Air 7",
        bluetoothNames: ["realme Buds Air 7", "Realme Buds Air 7", "Buds Air 7"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["064812"], noiseModes: realmeLevelModes, equalizerPresets: realmeEQ,
                           featureStatusIDs: [0x04, 0x06, 0x11], gameModeFeatureID: 0x06, wearDetectionFeatureID: 0x04,
                           dualConnectionFeatureID: 0x11, gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .wearDetection: .experimental, .dualConnection: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations, sources: ["S4"], evidence: [])

    public static let realmeBudsAir6Pro = DeviceProfile(
        id: "realme-buds-air-6-pro", manufacturer: .realme, model: "Realme Buds Air 6 Pro", displayName: "Realme Buds Air 6 Pro",
        bluetoothNames: ["realme Buds Air 6 Pro", "Realme Buds Air 6 Pro", "realme Buds Air6 Pro", "Buds Air 6 Pro", "Buds Air6 Pro"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["063012"], noiseModes: realmeLevelModes, equalizerPresets: realmeEQ,
                           featureStatusIDs: [0x04, 0x06, 0x0B, 0x11], gameModeFeatureID: 0x06, wearDetectionFeatureID: 0x04,
                           dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .wearDetection: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations, sources: ["S4", "S5", "S15"], evidence: [])

    public static let realmeBudsAir6 = DeviceProfile(
        id: "realme-buds-air-6", manufacturer: .realme, model: "Realme Buds Air 6", displayName: "Realme Buds Air 6",
        bluetoothNames: ["realme Buds Air 6", "Realme Buds Air 6", "realme Buds Air6", "Buds Air 6", "Buds Air6"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["063412"], noiseModes: realmeLevelModes, equalizerPresets: realmeEQ,
                           featureStatusIDs: [0x04, 0x06, 0x11], gameModeFeatureID: 0x06, wearDetectionFeatureID: 0x04,
                           dualConnectionFeatureID: 0x11, gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .wearDetection: .experimental, .dualConnection: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations, sources: ["S4", "S5"], evidence: [])

    public static let realmeBudsAir5Pro = DeviceProfile(
        id: "realme-buds-air-5-pro", manufacturer: .realme, model: "Realme Buds Air 5 Pro", displayName: "Realme Buds Air 5 Pro",
        bluetoothNames: ["realme Buds Air 5 Pro", "Realme Buds Air 5 Pro", "realme Buds Air5 Pro", "Buds Air 5 Pro", "Buds Air5 Pro"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["061C12"], noiseModes: realmeLevelModes, equalizerPresets: realmeEQ,
                           featureStatusIDs: [0x04, 0x06, 0x0B, 0x11], gameModeFeatureID: 0x06, wearDetectionFeatureID: 0x04,
                           dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .wearDetection: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations, sources: ["S4", "S5"], evidence: [])

    public static let realmeBudsT310 = DeviceProfile(
        id: "realme-buds-t310", manufacturer: .realme, model: "Realme Buds T310", displayName: "Realme Buds T310",
        bluetoothNames: ["realme Buds T310", "Realme Buds T310", "Buds T310"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["063C12"], noiseModes: realmeLevelModes, equalizerPresets: realmeEQ,
                           featureStatusIDs: [0x06, 0x0B, 0x0C, 0x11], gameModeFeatureID: 0x06,
                           dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, bassWaveFeatureID: 0x0C, gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .bassWave: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations, sources: ["S4", "S5"], evidence: [])

    public static let realmeBudsT200 = DeviceProfile(
        id: "realme-buds-t200", manufacturer: .realme, model: "Realme Buds T200", displayName: "Realme Buds T200",
        bluetoothNames: ["realme Buds T200", "Realme Buds T200", "Buds T200"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["062C12"],
                           noiseModes: [NoiseModeOption(.off, set: [0x01], read: 0x01),
                                        NoiseModeOption(.transparency, set: [0x02], read: 0x02),
                                        NoiseModeOption(.noiseCancelling(nil), set: [0x08], read: 0x08)],
                           equalizerPresets: realmeEQ, featureStatusIDs: [0x06], gameModeFeatureID: 0x06,
                           gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations, sources: ["S4", "S15"], evidence: [])

    public static let realmeBudsT200x = DeviceProfile(
        id: "realme-buds-t200x", manufacturer: .realme, model: "Realme Buds T200x", displayName: "Realme Buds T200x",
        bluetoothNames: ["realme Buds T200x", "Realme Buds T200x", "Buds T200x"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["062E12"],
                           noiseModes: [NoiseModeOption(.off, set: [0x01], read: 0x01),
                                        NoiseModeOption(.transparency, set: [0x02], read: 0x02),
                                        NoiseModeOption(.noiseCancelling(nil), set: [0x08], read: 0x08)],
                           equalizerPresets: realmeEQ, featureStatusIDs: [0x06], gameModeFeatureID: 0x06,
                           gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations, sources: ["S4"], evidence: [])

    public static let realmeBudsT200Lite = DeviceProfile(
        id: "realme-buds-t200-lite", manufacturer: .realme, model: "Realme Buds T200 Lite", displayName: "Realme Buds T200 Lite",
        bluetoothNames: ["realme Buds T200 Lite", "Realme Buds T200 Lite", "Buds T200 Lite"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["062A12"], noiseModes: [], equalizerPresets: realmeEQ,
                           featureStatusIDs: [0x06, 0x11], gameModeFeatureID: 0x06,
                           dualConnectionFeatureID: 0x11, gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .dualConnection: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations + ["Non-ANC model: AI ENC, dual-device pairing, EQ, and low-latency mode."], sources: ["S4"], evidence: [])

    public static let realmeBudsT110 = DeviceProfile(
        id: "realme-buds-t110", manufacturer: .realme, model: "Realme Buds T110", displayName: "Realme Buds T110",
        bluetoothNames: ["realme Buds T110", "Realme Buds T110", "Buds T110"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["063812"], noiseModes: [], equalizerPresets: realmeEQ,
                           featureStatusIDs: [0x06], gameModeFeatureID: 0x06, gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations, sources: ["S4"], evidence: [])

    public static let realmeBudsN1 = DeviceProfile(
        id: "realme-buds-n1", manufacturer: .realme, model: "Realme Buds N1", displayName: "Realme Buds N1",
        bluetoothNames: ["realme Buds N1", "Realme Buds N1", "Buds N1"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["064012"], noiseModes: realmeLevelModes, equalizerPresets: realmeEQ,
                           featureStatusIDs: [0x06, 0x0B, 0x0C, 0x11], gameModeFeatureID: 0x06,
                           dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, bassWaveFeatureID: 0x0C, gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .bassWave: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations, sources: ["S4"], evidence: [])

    /// realme TL-family noise values: the written value is also the reported value (realme Link data
    /// via S4; verified by S12 on realme Buds T500 Pro, by S15 on Air6 Pro/T200). Plain ANC and Deep
    /// share 0x08, so reads of 0x08 show as Deep. Values may be reported as a single byte.
    static let realmeLevelModes: [NoiseModeOption] = [
        NoiseModeOption(.off, set: [0x01], read: 0x01),
        NoiseModeOption(.transparency, set: [0x02], read: 0x02),
        NoiseModeOption(.noiseCancelling(.deep), set: [0x08], read: 0x08),
        NoiseModeOption(.noiseCancelling(nil), set: [0x08], read: 0x08),
        NoiseModeOption(.noiseCancelling(.light), set: [0x04], read: 0x04),
        NoiseModeOption(.noiseCancelling(.medium), set: [0x10], read: 0x10),
        NoiseModeOption(.noiseCancelling(.smart), set: [0x20], read: 0x20),
    ]

    static let realmeEQ: [EQPresetOption] = [
        EQPresetOption(id: 0, name: "Pure Raw"), EQPresetOption(id: 1, name: "Deep Bass"),
        EQPresetOption(id: 2, name: "Pure Vocals"), EQPresetOption(id: 3, name: "Pure Bass"),
    ]

    /// realme gesture masks from realme Link data (S4 models.json, S15): voice assistant is 0x04.
    static let realmeGestures: [UInt8: [UInt8]] = [
        GestureAction.double.rawValue: [0x00, 0x01, 0x06, 0x04],
        GestureAction.triple.rawValue: [0x00, 0x01, 0x05, 0x06, 0x0B, 0x0C, 0x0D, 0x11, 0x04],
        GestureAction.hold.rawValue: [0x00, 0x08, 0x04, 0x11],
    ]

    static let realmeLimitations = [
        "Experimental: built from realme Link data and other realme models' hardware evidence; not yet tested on this model with MacMelody.",
        "realme reports power saving as feature 0x05; MacMelody never writes it.",
        "If the 079A service is absent, the standard serial port (0x1101) is tried; the product id must still match.",
    ]

    public static let realmeBudsAir5 = DeviceProfile(
        id: "realme-buds-air-5", manufacturer: .realme, model: "Realme Buds Air 5", displayName: "Realme Buds Air 5",
        bluetoothNames: ["realme Buds Air 5", "Realme Buds Air 5"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["062012"], noiseModes: realmeLevelModes, equalizerPresets: realmeEQ,
                           featureStatusIDs: [0x04, 0x06, 0x11], gameModeFeatureID: 0x06, wearDetectionFeatureID: 0x04,
                           dualConnectionFeatureID: 0x11, gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .wearDetection: .experimental, .dualConnection: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations, sources: ["S4", "S5", "S10", "S12", "S15"], evidence: [])

    public static let realmeBudsT300 = DeviceProfile(
        id: "realme-buds-t300", manufacturer: .realme, model: "Realme Buds T300", displayName: "Realme Buds T300",
        bluetoothNames: ["realme Buds T300", "Realme Buds T300"], transports: [.rfcomm], rfcommServiceUUIDs: [opoService, standardSPP], ble: nil,
        protocolKind: .opoV1,
        opo: OPOParameters(productIDs: ["062412"],
                           noiseModes: [NoiseModeOption(.off, set: [0x01], read: 0x01),
                                        NoiseModeOption(.transparency, set: [0x02], read: 0x02),
                                        NoiseModeOption(.noiseCancelling(nil), set: [0x08], read: 0x08)],
                           equalizerPresets: realmeEQ, featureStatusIDs: [0x06, 0x0B, 0x0C, 0x11], gameModeFeatureID: 0x06,
                           dualConnectionFeatureID: 0x11, spatialAudioFeatureID: 0x0B, bassWaveFeatureID: 0x0C, gestureFunctions: realmeGestures,
                           gestureFunctionNames: [0x04: "Voice assistant", 0x03: "Function 0x03"]),
        status: .experimental,
        capabilities: [.battery: .experimental, .noiseControl: .experimental, .equalizer: .experimental, .gestures: .experimental,
                       .gameMode: .experimental, .dualConnection: .experimental, .spatialAudio: .experimental, .bassWave: .experimental, .deviceInfo: .experimental],
        testedFirmware: [], limitations: realmeLimitations + ["No noise-cancelling levels; no in-ear detection in the vendor list."],
        sources: ["S4", "S5", "S10", "S15"], evidence: [])

    /// Older realme Link protocol (protocolType 2): not OPO, undocumented. Never controlled.
    public static let realmeBudsWireless2 = DeviceProfile(
        id: "realme-buds-wireless-2", manufacturer: .realme, model: "Realme Buds Wireless 2", displayName: "Realme Buds Wireless 2",
        bluetoothNames: ["realme Buds Wireless 2", "Realme Buds Wireless 2"], transports: [.rfcomm], rfcommServiceUUIDs: [standardSPP], ble: nil,
        protocolKind: .opoV1, opo: nil, status: .unsupported, capabilities: [:], testedFirmware: [],
        limitations: ["Uses realme's older realme Link protocol (protocolType 2), which no source documents. Needs an Android Bluetooth capture to add."],
        sources: ["S5", "S10"], evidence: [])

    public static let unknownModels: [DeviceProfile] = [
        unknown("oneplus-buds-v", .onePlus, "OnePlus Buds V", productID: "060214", note: "Untested model; diagnostics only."),
    ]

    static let realmeUnknownModels: [DeviceProfile] = [
        unknown("realme-buds-t100", .realme, "Realme Buds T100", productID: "062812", note: nil),
    ]

    public static let onePlusModels: [DeviceProfile] = [
        nordBuds4Pro,
        onePlusBuds3,
        nordBuds3Pro,
        onePlusBudsPro3,
        onePlusBudsPro2,
        onePlusBuds4,
        nordBuds4,
        nordBuds3,
        nordBuds3r,
        nordBuds2,
        nordBuds2r,
        nordBuds,
        onePlusBudsZ2,
        onePlusBudsPro,
    ]

    public static let oppoModels: [DeviceProfile] = [
        oppoEncoX4,
        oppoEncoAir5Pro,
        oppoEncoAir5,
        oppoEncoAir4Pro,
        oppoEncoAir3Pro,
        oppoEncoAir3,
        oppoEncoAir2Pro,
        oppoEncoBuds3ProPlus,
        oppoEncoBuds3Pro,
        oppoEncoBuds3,
        oppoEncoBuds2,
        oppoEncoFree3,
        oppoEncoX2,
        oppoEncoX,
    ]

    public static let realmeModels: [DeviceProfile] = [
        realmeBudsAir8Pro,
        realmeBudsAir8,
        realmeBudsAir7Pro,
        realmeBudsAir7,
        realmeBudsAir6Pro,
        realmeBudsAir6,
        realmeBudsAir5Pro,
        realmeBudsAir5,
        realmeBudsT310,
        realmeBudsT300,
        realmeBudsT200,
        realmeBudsT200x,
        realmeBudsT200Lite,
        realmeBudsT110,
        realmeBudsN1,
    ]

    public static let all: [DeviceProfile] = onePlusModels + oppoModels + realmeModels
        + unknownModels + realmeUnknownModels + [realmeBudsWireless2]

    /// Selects a profile by exact Bluetooth name first, trimmed possessive prefix (e.g. "Omraj's ..."), then by product id.
    public static func match(name: String?, productID: String? = nil, in profiles: [DeviceProfile] = all) -> DeviceProfile? {
        if let name {
            let lowered = name.trimmingCharacters(in: .whitespaces).lowercased()
            // 1. Exact name match
            if let profile = profiles.first(where: { $0.bluetoothNames.contains { $0.lowercased() == lowered } }) {
                return profile
            }
            // 2. User ownership prefix (e.g. "Omraj’s OnePlus Buds 4 Pro" -> "OnePlus Buds 4 Pro")
            if let stripped = stripPossessivePrefix(lowered) {
                if let profile = profiles.first(where: { $0.bluetoothNames.contains { $0.lowercased() == stripped } }) {
                    return profile
                }
            }
        }
        if let productID = productID?.uppercased() {
            return profiles.first { $0.opo?.productIDs.contains(productID) == true }
        }
        return nil
    }

    private static func stripPossessivePrefix(_ name: String) -> String? {
        let pattern = #"^.+?['’]s\s+"#
        if let range = name.range(of: pattern, options: .regularExpression) {
            return String(name[range.upperBound...])
        }
        return nil
    }

    private static func unknown(_ id: String, _ manufacturer: Manufacturer, _ name: String, productID: String, note: String?) -> DeviceProfile {
        DeviceProfile(id: id, manufacturer: manufacturer, model: name, displayName: name, bluetoothNames: [name],
                      transports: [.rfcomm, .ble], rfcommServiceUUIDs: [opoService], ble: opoBLE, protocolKind: .opoV1,
                      opo: OPOParameters(productIDs: [productID]), status: .unknown, capabilities: [:], testedFirmware: [],
                      limitations: ["Listed as likely compatible by reference projects; untested. Diagnostics only."] + (note.map { [$0] } ?? []),
                      sources: ["S5"], evidence: [])
    }
}
