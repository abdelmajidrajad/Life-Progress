import UIKit
import SwiftUI

struct PageViewController: UIViewControllerRepresentable {
    var controllers: [UIViewController]
    @Binding var currentPage: Int
    var onIndexChanged: (Int) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIPageViewController {
        let pageViewController = UIPageViewController(
            transitionStyle: .scroll,
            navigationOrientation: .horizontal)
        
        pageViewController.dataSource = context.coordinator
        pageViewController.delegate = context.coordinator

        return pageViewController
    }

    func updateUIViewController(_ pageViewController: UIPageViewController, context: Context) {
        pageViewController.setViewControllers(
            [controllers[currentPage]], direction: currentPage == 1 ? .forward: .reverse, animated: true)
    }

    class Coordinator: NSObject, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
        var parent: PageViewController

        init(_ pageViewController: PageViewController) {
            self.parent = pageViewController
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerBefore viewController: UIViewController) -> UIViewController?
        {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            parent.onIndexChanged(index)
            if index == 0 {
                return parent.controllers.last
            }
            return parent.controllers[index - 1]
        }

        func pageViewController(
            _ pageViewController: UIPageViewController,
            viewControllerAfter viewController: UIViewController) -> UIViewController?
        {
            guard let index = parent.controllers.firstIndex(of: viewController) else {
                return nil
            }
            parent.onIndexChanged(index)
            if index + 1 == parent.controllers.count {
                return parent.controllers.first
            }
            return parent.controllers[index + 1]
        }
                              
      
    }
}

struct PageView<Page: View>: View {
    var viewControllers: [UIHostingController<Page>]
    @Binding var currentPage: Int

    init(_ views: Page..., currentPage: Binding<Int>) {
        self.viewControllers = views
            .map(UIHostingController.init(rootView:))
        self._currentPage = currentPage
    }
    
    init(_ views: [Page], currentPage: Binding<Int>) {
        self.viewControllers = views
            .map(UIHostingController.init(rootView:))
        self._currentPage = currentPage
    }

    var body: some View {
        PageViewController(
            controllers: viewControllers,
            currentPage: $currentPage,
            onIndexChanged: {
                self.currentPage = $0
        })
    }
}


struct PageControl: UIViewRepresentable {
    var numberOfPages: Int
    @Binding var currentPage: Int

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPageControl {
        let control = UIPageControl()
        control.addTarget(context.coordinator, action: #selector(context.coordinator.updateCurrentPage(sender:)), for: .touchUpInside)
        control.numberOfPages = numberOfPages
        if #available(iOS 14.0, *) {
            control.backgroundStyle = .prominent
            control.allowsContinuousInteraction = true
        }
        control.pageIndicatorTintColor = .systemRed
        control.hidesForSinglePage = true
        control.currentPageIndicatorTintColor = UIColor.systemRed.withAlphaComponent(0.5)

        return control
    }

    func updateUIView(_ pageControl: UIPageControl, context: Context) {
        pageControl.currentPage = currentPage
    }

    class Coordinator: NSObject, UIPageViewControllerDelegate {
        var control: PageControl

        init(_ control: PageControl) {
            self.control = control
        }

        @objc func updateCurrentPage(sender: UIPageControl) {
            control.currentPage = sender.currentPage
        }
    }
}

struct Pager_Previews: PreviewProvider {
    static var previews: some View {
        PageControl(numberOfPages: 10, currentPage: .constant(5))
    }
}
