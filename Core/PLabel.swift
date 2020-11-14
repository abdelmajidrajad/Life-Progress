import SwiftUI
public struct PLabel: UIViewRepresentable {
            
    @Binding var attributedText: NSAttributedString
    
    public init(attributedText: Binding<NSAttributedString>) {
        self._attributedText = attributedText
    }
    
    public func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        plabelStyle(label)
        return label
    }
    public func updateUIView(_ label: UILabel, context: Context) {
        label.attributedText = attributedText
    }
}

let plabelStyle: (UILabel) -> Void = {
    $0.textAlignment = .left
    $0.adjustsFontSizeToFitWidth = true
}
