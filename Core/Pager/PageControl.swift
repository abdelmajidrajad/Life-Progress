/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view wrapping a UIPageControl.
*/

import SwiftUI

import UIKit

public struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int
    
    public init(numberOfPages: Int, currentPage: Binding<Int>) {
        self.numberOfPages = numberOfPages
        self._currentPage = currentPage
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    public func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.numberOfPages = numberOfPages
        control.currentPageIndicatorTintColor = UIColor.label
        control.pageIndicatorTintColor = UIColor.secondaryLabel
        control.addTarget(
            context.coordinator,
            action: #selector(Coordinator.updateCurrentPage(sender:)),
            for: .valueChanged)

        return control
    }

    public func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
    }

    public class Coordinator: NSObject {
        var control: PageControl

        public init(_ control: PageControl) {
            self.control = control
        }

        @objc
        public func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}
