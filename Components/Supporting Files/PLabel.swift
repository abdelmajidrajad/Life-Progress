import SwiftUI
struct PLabel: UIViewRepresentable {
            
    @Binding var attributedText: NSAttributedString
    
    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        plabelStyle(label)
        return label
    }
    func updateUIView(_ label: UILabel, context: Context) {
        label.attributedText = attributedText
    }
}

let plabelStyle: (UILabel) -> Void = {
    $0.textAlignment = .left
    $0.adjustsFontSizeToFitWidth = true
}
