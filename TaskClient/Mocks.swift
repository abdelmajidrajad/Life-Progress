extension TaskClient {
    public static var empty: Self {
        Self(
            create: { _ in .none },
            update: { _ in .none },
            tasks: { _ in .none }
        )
    }
}
