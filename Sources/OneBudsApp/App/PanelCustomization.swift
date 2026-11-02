import Foundation
import SwiftUI

/// Modules available to display in the menu bar popover control panel.
enum PanelModule: String, CaseIterable, Identifiable, Codable {
    case battery = "battery"
    case noiseControl = "noiseControl"
    case gameMode = "gameMode"
    case equalizer = "equalizer"
    case inEarDetection = "inEarDetection"
    case spatialAudio = "spatialAudio"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .battery: "Battery Levels"
        case .noiseControl: "Noise Control"
        case .gameMode: "Game Mode"
        case .equalizer: "Equalizer Presets"
        case .inEarDetection: "In-Ear Detection"
        case .spatialAudio: "Spatial Audio"
        }
    }

    var subtitle: String {
        switch self {
        case .battery: "Live battery rings for left, right, and case"
        case .noiseControl: "ANC, Transparency, Off modes & depth selector"
        case .gameMode: "Ultra-low latency audio toggle"
        case .equalizer: "Hardware DSP audio tuning profiles"
        case .inEarDetection: "Auto-pause when removing earbuds"
        case .spatialAudio: "360° fixed spatial sound effect"
        }
    }

    var symbol: String {
        switch self {
        case .battery: "battery.100.bolt"
        case .noiseControl: "waveform"
        case .gameMode: "gamecontroller"
        case .equalizer: "slider.vertical.3"
        case .inEarDetection: "ear"
        case .spatialAudio: "dot.radiowaves.left.and.right"
        }
    }

    var isCompactTile: Bool {
        switch self {
        case .gameMode, .inEarDetection, .spatialAudio: true
        case .battery, .noiseControl, .equalizer: false
        }
    }
}

/// Arrangement and orientation style for modules in the popover panel.
enum PanelOrientation: String, CaseIterable, Identifiable, Codable {
    case stacked = "stacked"
    case modernGrid = "modernGrid"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stacked: "Full Cards (Stacked)"
        case .modernGrid: "Control Center Tiles"
        }
    }

    var subtitle: String {
        switch self {
        case .stacked: "Full-width cards stacked vertically in order."
        case .modernGrid: "Compact 2-column tiles for quick toggles, matching macOS Control Center."
        }
    }
}
