import OneBudsCore
import SwiftUI

struct CustomEQEditor: View {
    @Environment(DeviceManager.self) private var manager
    let id: UInt8
    let saved: CustomEqualizer?
    @State private var draft: CustomEqualizer
    @State private var expanded = false
    @State private var confirmDelete = false

    init(id: UInt8, saved: CustomEqualizer?) {
        self.id = id
        self.saved = saved
        let existing = saved.flatMap { $0.frequencies.count == 6 && $0.levels.count == 6 ? $0 : nil }
        _draft = State(initialValue: existing ?? CustomEqualizer(id: id, name: "Custom \(id - 3)", minimum: -6, maximum: 6,
            frequencies: [62, 250, 1000, 4000, 8000, 16000], levels: Array(repeating: 0, count: 6)))
    }

    var body: some View {
        DisclosureGroup(isExpanded: $expanded) {
            TextField("Profile name", text: $draft.name)
            ForEach(0..<6, id: \.self) { index in
                Stepper(value: $draft.levels[index], in: draft.minimum...draft.maximum) {
                    LabeledContent("\(draft.frequencies[index]) Hz", value: "\(draft.levels[index]) dB")
                }
            }
            HStack {
                Button("Save and select") { Task { await manager.saveCustomEqualizer(draft) } }
                    .disabled(draft.name.isEmpty || draft.name.utf8.count > 20 || manager.status(of: .customEqualizer) == .pending)
                if saved != nil && !(saved?.frequencies.isEmpty ?? true) {
                    Button("Select") { Task { await manager.selectCustomEqualizer(id) } }
                        .disabled(manager.status(of: .customEqualizer) == .pending)
                    Button("Delete", role: .destructive) { confirmDelete = true }
                        .disabled(manager.status(of: .customEqualizer) == .pending)
                }
                if manager.equalizerPreset == id { Text("Selected").foregroundStyle(.secondary) }
            }
            Text("Names are limited to 20 UTF-8 bytes.").font(.caption).foregroundStyle(.secondary)
        } label: {
            Text(saved?.name.isEmpty == false ? saved!.name : "Custom \(id - 3)")
        }
        .confirmationDialog("Delete this saved EQ profile?", isPresented: $confirmDelete) {
            Button("Delete profile", role: .destructive) { Task { await manager.deleteCustomEqualizer(id) } }
        } message: { Text("This removes the profile from the earbuds.") }
        .onChange(of: saved) { _, updated in
            if let updated, updated.frequencies.count == 6, updated.levels.count == 6 { draft = updated }
        }
    }
}
