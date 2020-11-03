extension Bundle {
    static var settings: Self {
        class Settings {}
        return Self(for: Settings.self)
    }
}
