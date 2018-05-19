//  Pages.swift

import Foundation
import UIKit


public enum PageType: Int { case  main = 0, menu = 1, onboard = 3 }

class PagesVC: UIViewController, UIPageViewControllerDataSource {
    
    static let shared = PagesVC()

    var pageVC : UIPageViewController!
    var pages: [UIViewController] = []
    var pageType = PageType.main
    var scrollView: UIScrollView!
    
    var menuVC: MenuTableVC!
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

        menuVC.updateViews(size.width)
        menuVC.tableView.reloadData()
        eventVC.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        menuVC  = storyboard.instantiateViewController(withIdentifier: "TreeTable")  as! MenuTableVC

        setBorder(menuVC,  radius:  8, width: 0)
        setBorder(eventVC, radius: 16, width: 0)
        
        menuVC.tableView.contentInset  = .zero
        eventVC.tableView.contentInset = .zero

        menuVC.view?.frame = childFrame
        eventVC.view?.frame = childFrame

        pages = [eventVC,menuVC]
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

    func gotoPageType(_ type_:PageType, done:@escaping CallVoid) {

        if pageType == type_ {
            return done()
        }
        pageType = type_
        if pageType == .onboard {
            MainVC.shared?.makeOnboard()
            return done()
        }

        let index = pageType.rawValue
        let nextVC = pages[index]

        if !nextVC.isBeingPresented {
            pageVC.setViewControllers([nextVC], direction: (pageType == .main ? .forward : .reverse), animated: true, completion: {_ in
                done()
            })
        }
        else {
            Timer.delay(0.5) { done() }
        }
    }
    
    func setBorder(_ vc:UIViewController, radius: CGFloat, width: CGFloat) {

        vc.view.layer.cornerRadius = radius
        vc.view.layer.borderColor = headColor.cgColor
        vc.view.layer.borderWidth = width
        ///!!!/// vc.view.layer.masksToBounds = true
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let vc = pageViewController.viewControllers![0] as? PagesVC {
               pageType = vc.pageType
            }
        }
    }

    func pageViewController(_ pageVC: UIPageViewController, viewControllerBefore vc: UIViewController) -> UIViewController? {

        let index = pages.index(of: vc)! - 1
        if index >= 0 {
            pageType = PageType(rawValue: index) ?? .main
            return pages[index]
        }
        return nil
    }
    
    func pageViewController(_ pageVC: UIPageViewController, viewControllerAfter vc: UIViewController) -> UIViewController? {
        
        let index = pages.index(of: vc)! + 1
        if index < pages.count  {
            pageType = PageType(rawValue: index) ?? .main
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
