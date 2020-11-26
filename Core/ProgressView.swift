import SwiftUI

public struct UIViewRepresented<UIViewType>: UIViewRepresentable where UIViewType: UIView {
    let makeUIView: (Context) -> UIViewType
    let updateUIView: (UIViewType, Context) -> Void
    
    public init(makeUIView: @escaping (Context) -> UIViewType,
         updateUIView: @escaping (UIViewType, Context) -> Void = { _, _ in }) {
        self.makeUIView = makeUIView
        self.updateUIView = updateUIView
    }
    
    public func makeUIView(context: Context) -> UIViewType {
        self.makeUIView(context)
    }
    
    public func updateUIView(_ uiView: UIViewType, context: Context) {
        self.updateUIView(uiView, context)
    }
}


public struct UIViewControllerRepresented<UIViewControllerType>: UIViewControllerRepresentable where UIViewControllerType: UIViewController {
    let makeUIView: (Context) -> UIViewControllerType
    let updateUIView: (UIViewControllerType, Context) -> Void
    
    public init(makeUIView: @escaping (Context) -> UIViewControllerType,
         updateUIView: @escaping (UIViewControllerType, Context) -> Void = { _, _ in }) {
        self.makeUIView = makeUIView
        self.updateUIView = updateUIView
    }
    
    public func makeUIViewController(context: Context) -> UIViewControllerType {
        self.makeUIView(context)
    }
    
    public func updateUIViewController(_ viewController: UIViewControllerType, context: Context) {
        self.updateUIView(viewController, context)
    }
}



public struct ActivityIndicator: View {
    let style: UIActivityIndicatorView.Style
    public init(
        style: UIActivityIndicatorView.Style = .large
    ) {
        self.style = style
    }
    public var body: some View {
        UIViewRepresented(makeUIView: { _ in
            let indicator = UIActivityIndicatorView(style: self.style)
            indicator.startAnimating()
            return indicator
        })
    }
}
