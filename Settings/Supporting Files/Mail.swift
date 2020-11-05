import SwiftUI
import MessageUI

let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
let appBuild = Bundle.main.infoDictionary?["CFBundleVersion"] as! String


struct SupportView: UIViewControllerRepresentable {
    
    let onDismiss: () -> Void
    
    init(onDismiss: @autoclosure @escaping () -> Void) {
        self.onDismiss = onDismiss
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = context.coordinator
        controller.setSubject("Feeback V:\(appVersion) Build: \(appBuild)")
        controller.setToRecipients(["abdelmajid.rajad@gmail.com"])
        controller.setMessageBody("progress life", isHTML: true)
        return controller
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject,
                       MFMailComposeViewControllerDelegate,
                       UINavigationControllerDelegate {
        let parent: SupportView
        init(parent: SupportView) {
            self.parent = parent
        }
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            self.parent.onDismiss()
        }
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
