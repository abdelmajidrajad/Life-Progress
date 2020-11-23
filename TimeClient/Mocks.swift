extension TimeClient {
    public static var empty: TimeClient {
        TimeClient(
            yearProgress: { _ in .none },
            todayProgress: { _ in .none },
            weekProgress: { _ in .none },
            taskProgress: { _ in .none },
            yourDayProgress: { _ in .none },
            lifeProgress: { _ in .none }
        )
    }
}

