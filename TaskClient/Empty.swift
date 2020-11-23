import Combine
extension AnyPublisher {
    public static var none: AnyPublisher {
        Empty(completeImmediately: true).eraseToAnyPublisher()
    }
}
