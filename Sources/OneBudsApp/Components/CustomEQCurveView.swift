import OneBudsCore
import SwiftUI

/// Band definition for the 6-band custom parametric equalizer.
public struct EQBandInfo: Identifiable, Sendable {
    public let id: Int
    public let frequency: String
    public let role: String

    public static let defaultBands: [EQBandInfo] = [
        EQBandInfo(id: 0, frequency: "63 Hz", role: "Sub-Bass"),
        EQBandInfo(id: 1, frequency: "250 Hz", role: "Bass"),
        EQBandInfo(id: 2, frequency: "1 kHz", role: "Mids"),
        EQBandInfo(id: 3, frequency: "2.5 kHz", role: "Upper Mids"),
        EQBandInfo(id: 4, frequency: "6 kHz", role: "Treble"),
        EQBandInfo(id: 5, frequency: "16 kHz", role: "Air"),
    ]
}

/// Curve templates for one-click adjustments.
public struct EQCurveTemplate: Identifiable, Sendable {
    public let id: String
    public let name: String
    public let icon: String
    public let bands: [Int8]

    public static let templates: [EQCurveTemplate] = [
        EQCurveTemplate(id: "flat", name: "Flat", icon: "equal", bands: [0, 0, 0, 0, 0, 0]),
        EQCurveTemplate(id: "bass", name: "Bass Boost", icon: "speaker.wave.3.fill", bands: [4, 3, 1, 0, 1, 2]),
        EQCurveTemplate(id: "vocal", name: "Pure Vocals", icon: "mic.fill", bands: [-1, 0, 3, 3, 2, 0]),
        EQCurveTemplate(id: "vshape", name: "V-Shape", icon: "waveform", bands: [4, 2, -2, 0, 2, 4]),
        EQCurveTemplate(id: "air", name: "Treble Air", icon: "wind", bands: [-1, -1, 0, 1, 3, 5]),
        EQCurveTemplate(id: "electronic", name: "Club EDM", icon: "bolt.fill", bands: [5, 4, 1, -1, 2, 3]),
    ]
}

public struct CustomEQCurveView: View {
    @Environment(DeviceManager.self) private var manager
    @State private var bands: [Int8] = [0, 0, 0, 0, 0, 0]
    @State private var isApplying = false
    @State private var lastConfirmedTime: Date?

    public init() {}

    private let bandSpecs = EQBandInfo.defaultBands

    public var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.m) {
            // Visual Spline Frequency Graph
            curveGraph
                .frame(height: 120)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(nsColor: .controlBackgroundColor).opacity(0.6))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .strokeBorder(Color.secondary.opacity(0.15), lineWidth: 1)
                        }
                }

            // Quick Preset Curves
            VStack(alignment: .leading, spacing: 6) {
                Text("Quick Curve Presets")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.secondary)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(EQCurveTemplate.templates) { template in
                            let isCurrent = bands == template.bands
                            Button {
                                applyTemplate(template)
                            } label: {
                                HStack(spacing: 5) {
                                    Image(systemName: template.icon)
                                        .font(.caption2)
                                    Text(template.name)
                                        .font(.caption)
                                        .fontWeight(isCurrent ? .semibold : .regular)
                                }
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background {
                                    if isCurrent {
                                        Capsule()
                                            .fill(Color.accentColor)
                                    } else {
                                        Capsule()
                                            .fill(Color.secondary.opacity(0.1))
                                    }
                                }
                                .foregroundStyle(isCurrent ? Color.white : Color.primary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 2)
                }
            }

            // 6-Band Vertical Studio Faders Rack
            HStack(spacing: 0) {
                ForEach(0..<6, id: \.self) { index in
                    let spec = bandSpecs[index]
                    EQFaderColumn(
                        spec: spec,
                        gain: Binding(
                            get: { bands.indices.contains(index) ? bands[index] : 0 },
                            set: { newValue in
                                if bands.indices.contains(index) {
                                    bands[index] = newValue
                                    scheduleCommit()
                                }
                            }
                        )
                    )
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(.vertical, Theme.Spacing.s)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(nsColor: .controlBackgroundColor).opacity(0.4))
            }

            // Footer controls
            HStack {
                Button {
                    applyTemplate(EQCurveTemplate.templates[0]) // Flat
                } label: {
                    Label("Reset to Flat", systemImage: "arrow.counterclockwise")
                        .font(.caption)
                }
                .buttonStyle(.plain)
                .foregroundStyle(.secondary)

                Spacer()

                if isApplying {
                    ProgressView()
                        .controlSize(.small)
                    Text("Applying curve…")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if let last = lastConfirmedTime, Date().timeIntervalSince(last) < 3.0 {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.caption)
                    Text("Curve applied to earbuds")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Button {
                    commitBands(bands)
                } label: {
                    Text("Apply Curve")
                        .font(.caption.bold())
                        .padding(.horizontal, 12)
                        .padding(.vertical, 5)
                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
            }
        }
        .onAppear {
            if manager.customEQBands.count == 6 {
                bands = manager.customEQBands
            }
        }
        .onChange(of: manager.customEQBands) { _, newBands in
            if newBands.count == 6 && !isApplying {
                bands = newBands
            }
        }
    }

    private var curveGraph: some View {
        GeometryReader { proxy in
            let points = computePoints(size: proxy.size)
            let zeroY = computeZeroY(height: proxy.size.height)
            let curvePath = buildCurvePath(points: points)
            let fillPath = buildFillPath(points: points, zeroY: zeroY)

            ZStack {
                // Background grid lines
                buildGridLines(size: proxy.size, zeroY: zeroY)
                    .stroke(Color.secondary.opacity(0.12), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

                // Zero line
                buildZeroLine(size: proxy.size, zeroY: zeroY)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)

                // Fill under curve
                fillPath
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.35), Color.accentColor.opacity(0.05)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                // Stroke curve
                curvePath
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))

                // Point dots
                ForEach(0..<points.count, id: \.self) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                        .overlay {
                            Circle().strokeBorder(Color.accentColor, lineWidth: 2)
                        }
                        .shadow(color: Color.accentColor.opacity(0.4), radius: 3)
                        .position(points[i])
                }

                // Grid dB Labels on the left
                VStack {
                    HStack {
                        Text("+6 dB")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text("0 dB")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.secondary.opacity(0.8))
                            .padding(.leading, 4)
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Text("-6 dB")
                            .font(.system(size: 9, weight: .semibold, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .padding(.leading, 4)
                        Spacer()
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }

    private func computePoints(size: CGSize) -> [CGPoint] {
        let w = size.width
        let h = size.height
        let padX: CGFloat = 24
        let usableW = w - (padX * 2)
        let usableH = h - 40

        return (0..<6).map { index in
            let x = padX + (usableW / 5.0) * CGFloat(index)
            let db = Double(bands.indices.contains(index) ? bands[index] : 0)
            let norm = (db + 6.0) / 12.0
            let y = (h - 20) - CGFloat(norm) * usableH
            return CGPoint(x: x, y: y)
        }
    }

    private func computeZeroY(height: CGFloat) -> CGFloat {
        let usableH = height - 40
        return (height - 20) - 0.5 * usableH
    }

    private func buildGridLines(size: CGSize, zeroY: CGFloat) -> Path {
        var path = Path()
        let padX: CGFloat = 24
        let w = size.width
        let h = size.height
        let usableH = h - 40

        for db in [-6.0, -3.0, 3.0, 6.0] {
            let norm = (db + 6.0) / 12.0
            let y = (h - 20) - CGFloat(norm) * usableH
            path.move(to: CGPoint(x: padX, y: y))
            path.addLine(to: CGPoint(x: w - padX, y: y))
        }
        return path
    }

    private func buildZeroLine(size: CGSize, zeroY: CGFloat) -> Path {
        var path = Path()
        let padX: CGFloat = 24
        path.move(to: CGPoint(x: padX, y: zeroY))
        path.addLine(to: CGPoint(x: size.width - padX, y: zeroY))
        return path
    }

    private func buildCurvePath(points: [CGPoint]) -> Path {
        var path = Path()
        guard let first = points.first else { return path }
        path.move(to: first)
        for i in 1..<points.count {
            let prev = points[i - 1]
            let curr = points[i]
            let midX = (prev.x + curr.x) / 2
            path.addCurve(to: curr, control1: CGPoint(x: midX, y: prev.y), control2: CGPoint(x: midX, y: curr.y))
        }
        return path
    }

    private func buildFillPath(points: [CGPoint], zeroY: CGFloat) -> Path {
        var path = Path()
        guard let first = points.first, let last = points.last else { return path }
        path.move(to: CGPoint(x: first.x, y: zeroY))
        path.addLine(to: first)
        for i in 1..<points.count {
            let prev = points[i - 1]
            let curr = points[i]
            let midX = (prev.x + curr.x) / 2
            path.addCurve(to: curr, control1: CGPoint(x: midX, y: prev.y), control2: CGPoint(x: midX, y: curr.y))
        }
        path.addLine(to: CGPoint(x: last.x, y: zeroY))
        path.closeSubpath()
        return path
    }

    private func applyTemplate(_ template: EQCurveTemplate) {
        withAnimation(Theme.Motion.standard) {
            bands = template.bands
        }
        commitBands(template.bands)
    }

    private func scheduleCommit() {
        commitBands(bands)
    }

    private func commitBands(_ targetBands: [Int8]) {
        guard !isApplying else { return }
        isApplying = true
        Task {
            await manager.setCustomEQ(bands: targetBands)
            await MainActor.run {
                isApplying = false
                lastConfirmedTime = Date()
            }
        }
    }
}

/// A vertical fader column with dB gain readout, vertical track, and frequency labeling.
private struct EQFaderColumn: View {
    let spec: EQBandInfo
    @Binding var gain: Int8

    private var gainString: String {
        gain > 0 ? "+\(gain) dB" : (gain == 0 ? "0 dB" : "\(gain) dB")
    }

    var body: some View {
        VStack(spacing: 6) {
            // Gain readout
            Text(gainString)
                .font(.system(size: 10, weight: .semibold, design: .monospaced))
                .foregroundStyle(gain != 0 ? Color.accentColor : Color.secondary)
                .frame(height: 14)

            // Vertical Track and Thumb Slider
            GeometryReader { proxy in
                let height = proxy.size.height
                let thumbRadius: CGFloat = 8
                let usableH = max(10, height - (thumbRadius * 2))

                let norm = Double(gain + 6) / 12.0
                let thumbY = (height - thumbRadius) - CGFloat(norm) * usableH
                let zeroNorm = 0.5
                let zeroY = (height - thumbRadius) - CGFloat(zeroNorm) * usableH

                ZStack(alignment: .top) {
                    // Track background groove
                    Capsule()
                        .fill(Color.secondary.opacity(0.18))
                        .frame(width: 4)
                        .frame(maxHeight: .infinity)

                    // Active fill from zero line
                    if gain != 0 {
                        let fillTop = min(zeroY, thumbY)
                        let fillH = abs(zeroY - thumbY)
                        Capsule()
                            .fill(Color.accentColor.opacity(0.8))
                            .frame(width: 4, height: max(2, fillH))
                            .offset(y: fillTop)
                    }

                    // 0 dB reference notch mark
                    Rectangle()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 10, height: 1.5)
                        .offset(y: zeroY - 0.75)

                    // Fader Thumb Knob
                    Circle()
                        .fill(Color.white)
                        .frame(width: thumbRadius * 2, height: thumbRadius * 2)
                        .overlay {
                            Circle().strokeBorder(gain != 0 ? Color.accentColor : Color.secondary, lineWidth: 2)
                        }
                        .shadow(color: Color.black.opacity(0.15), radius: 2, y: 1)
                        .offset(y: thumbY - thumbRadius)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let clampedY = max(thumbRadius, min(height - thumbRadius, value.location.y))
                            let ratio = 1.0 - Double((clampedY - thumbRadius) / usableH)
                            let newDB = Int8(round(ratio * 12.0)) - 6
                            let clampedDB = max(-6, min(6, newDB))
                            if clampedDB != gain {
                                gain = clampedDB
                            }
                        }
                )
                .onTapGesture(count: 2) {
                    withAnimation(Theme.Motion.standard) {
                        gain = 0
                    }
                }
            }
            .frame(height: 100)

            // Frequency and Band labels
            VStack(spacing: 1) {
                Text(spec.frequency)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(.primary)

                Text(spec.role)
                    .font(.system(size: 8))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
    }
}
