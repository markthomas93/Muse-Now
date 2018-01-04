//  Pages.swift

import UIKit

class OnboardPage: UIViewController {

    convenience init(_ title_:String) {
        self.init()
        title = title_
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        view.backgroundColor = .darkGray

        let label = UILabel()
        view.addSubview(label)
        label.text = title
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        Log("🔰 appear: \(title!)")
        let bubItem = BubbleItem(title!,4)
        let bubble = Bubble(title!, [bubItem], .center, .text, CGSize(width:128,height:64),
                            view,view,[],[],[])

        BubbleText(bubble).goBubble() {_ in }
    }

}

class OnboardVC: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var pages = [UIViewController]()
    let pageControl = UIPageControl()

    override init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]?) {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: options)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()

        dataSource = self
        delegate = self
        let initialPage = 0

        let page1 = OnboardPage("Hello")
        let page2 = OnboardPage("there")
        let page3 = OnboardPage("Human")

        // add the individual viewControllers to the pageViewController
        pages.append(page1)
        pages.append(page2)
        pages.append(page3)
        setViewControllers([pages[0]], direction: .forward, animated: true, completion: nil)

        // pageControl

        pageControl.frame = .zero
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = .gray
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = initialPage
        view.addSubview(pageControl)

        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -15).isActive = true
        pageControl.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -20).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 20).isActive = true
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        if let i = pages.index(of: viewController),
            i > 0 {

                return pages[i-1]
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        if let i = pages.index(of: viewController),
            i < pages.count - 1 {

            return pages[i+1]
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if  let vcs = pageViewController.viewControllers,
            let i = pages.index(of:vcs[0]) {

            Log("🔰 anim page:\(i)")
            pageControl.currentPage = i
        }
    }
}

