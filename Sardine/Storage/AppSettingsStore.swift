import Foundation

final class AppSettingsStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    var lastPresetID: String? {
        get { defaults.string(forKey: "lastPresetID") }
        set { defaults.set(newValue, forKey: "lastPresetID") }
    }
}

