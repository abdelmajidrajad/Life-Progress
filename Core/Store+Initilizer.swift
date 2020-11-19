import ComposableArchitecture
extension Store {
    public convenience init(initialState: State) {
        self.init(
            initialState: initialState,
            reducer: .empty,
            environment: ()
        )
    }
}
