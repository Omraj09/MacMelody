import SwiftUI

struct AboutSettingsPane: View {
    var body: some View {
        Form {
            Section {
                LabeledContent("App", value: "MacMelody")
                LabeledContent("Version", value: AppModel.version)
                LabeledContent("Author", value: "Omraj Sawant")
                LabeledContent("Data", value: "Stays on this Mac")
            }
            Section("Links") {
                Link("GitHub Repository", destination: URL(string: "https://github.com/Omraj09/MacMelody")!)
                Link("Report an Issue", destination: URL(string: "https://github.com/Omraj09/MacMelody/issues")!)
            }
            Section {
                Text("Unofficial companion for OnePlus, OPPO, and realme audio devices on macOS.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .settingsPaneStyle()
    }
}
