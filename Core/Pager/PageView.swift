/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view for bridging a UIPageViewController.
*/

import SwiftUI

public struct PageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>]
    @Binding var currentPage: Int

    public init(_ views: [Page], currentPage: Binding<Int>) {
        self.viewControllers = views
            .map { UIHostingController(rootView: $0) }
        self.viewControllers.forEach {
            $0.view.backgroundColor = .clear
        }
        self._currentPage = currentPage
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            PageViewController(
                controllers: viewControllers,
                currentPage: $currentPage
            )
            PageControl(
                numberOfPages: viewControllers.count,
                currentPage: $currentPage
            ).padding(.trailing)
        }
    }
}

