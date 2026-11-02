/// Surface style. `glass` uses Liquid Glass surfaces with specular highlights;
/// `standard` uses completely translucent native macOS frosted glass vibrancy.
enum VisualStyle: String, CaseIterable, Identifiable {
    case standard, glass

    var id: Self { self }

    var title: String {
        switch self {
        case .standard: "Standard"
        case .glass: "Liquid Glass"
        }
    }
}
