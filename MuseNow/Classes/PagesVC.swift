//  Pages.swift

import UIKit


public enum PageType: Int { case settings = 0, events = 1 }

class PagesVC: UIViewController, UIPageViewControllerDataSource {
    
    static let shared = PagesVC()

    var pageVC : UIPageViewController!
    var pages: [UIViewController] = []
    var pageType = PageType.events
    var scrollView: UIScrollView!
    
    var treeVC: TreeTableVC!
    var eventVC: EventTableVC!

    var spine: UIView!
    var pageFrame = CGRect.zero
    var childFrame = CGRect.zero
    var spineFrame = CGRect.zero

    func updateFrames(_ size:CGSize) {

        let width  = size.width
        let height = size.height
        let statusH = UIApplication.shared.statusBarFrame.height
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let isPanel = isPad && width < height/2 // is panel inside ipad app
        let isPortrait = height > width // is portrait mode
        let viewY = CGFloat(isPanel ? 0 : isPad ? 18 : isPortrait ? statusH : 0)
        let viewH = height - viewY

        let spineH = CGFloat(36)
        let spineY = height - spineH

        let childH = viewH - spineH

        pageFrame  = CGRect(x: 0, y: viewY,  width: width, height: viewH)
        childFrame = CGRect(x: 0, y: 0,      width: width, height: childH)
        spineFrame = CGRect(x: 0, y: spineY, width: width, height: spineH)
    }

    func updateViews(_ size:CGSize) {

        treeVC.updateViews(size.width)
        treeVC.tableView.reloadData()
        eventVC.tableView.reloadData()
    }

    var tourGuide: TourGuide!
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tourGuide = TourGuide()
        tourGuide.beginTour()
    }

    override func viewDidLoad() {
        
        super.viewDidLoad()
        let optionsDict = [UIPageViewControllerOptionInterPageSpacingKey : 20]

        pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: optionsDict)
        pageVC.dataSource = self
        pageVC.view!.frame = pageFrame
        pageVC.view.backgroundColor = .clear

        // find scrollview so that it can be disabled later
        for view in pageVC.view.subviews {
            if view is UIScrollView {
                scrollView = view as! UIScrollView
                break
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        eventVC = storyboard.instantiateViewController(withIdentifier: "EventTable") as! EventTableVC
        treeVC  = storyboard.instantiateViewController(withIdentifier: "TreeTable")  as! TreeTableVC

        setBorder(treeVC,  radius:  8, width: 0)
        setBorder(eventVC, radius: 16, width: 0)
        
        treeVC.tableView.contentInset  = .zero
        eventVC.tableView.contentInset = .zero

        treeVC.view?.frame = childFrame
        eventVC.view?.frame = childFrame

        pages = [treeVC,eventVC]
        pageVC.setViewControllers([eventVC], direction: .reverse, animated: false, completion: nil)

        spine = UIView(frame:spineFrame)
        spine.layer.cornerRadius = spine.frame.size.height/2
        spine.layer.borderColor = UIColor.clear.cgColor
        spine.layer.borderWidth = 0.5
        spine.isUserInteractionEnabled = false
        view.addSubview(spine)

        addChildViewController(pageVC)
        view.addSubview(pageVC.view)
        pageVC!.didMove(toParentViewController: self)
    }

    func gotoPageType(_ type_:PageType, done:@escaping (()->())) {

        if pageType == type_ { return done() }
        let index = type_.rawValue
        let nextVC = pages[index]
        pageVC.setViewControllers([nextVC],direction: pageType.rawValue < index ? .forward : .reverse, animated: true)
        let _ = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: {_ in
            done()
        })
    }
    
    func setBorder(_ vc:UIViewController, radius: CGFloat, width: CGFloat) {

        vc.view.layer.cornerRadius = radius
        vc.view.layer.borderColor = headColor.cgColor
        vc.view.layer.borderWidth = width
        vc.view.layer.masksToBounds = true
    }
    
    func pageViewController(_ pageVC: UIPageViewController, viewControllerBefore vc: UIViewController) -> UIViewController? {

        let index = pages.index(of: vc)! - 1
        if index >= 0 {
            pageType = PageType(rawValue: index) ?? .events
            return pages[index]
        }

        return nil
    }
    
    func pageViewController(_ pageVC: UIPageViewController, viewControllerAfter vc: UIViewController) -> UIViewController? {
        
        let index = pages.index(of: vc)! + 1
        if index < pages.count  {
            pageType = PageType(rawValue: index) ?? .events
            return pages[index]
        }
        return nil
    }
    
    func presentationCount(for: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for: UIPageViewController) -> Int {
        return pageType.rawValue
    }
    
    
}
