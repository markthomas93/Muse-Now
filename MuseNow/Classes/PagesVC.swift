//  Pages.swift

import UIKit

class PagesVC: UIViewController, UIPageViewControllerDataSource {
    
    static let shared = PagesVC()

    var pageVC : UIPageViewController!
    var pages: [UIViewController] = []
    var pagei = 1
    var scrollView: UIScrollView!
    
    var treeTable: TreeTableVC!
    var eventTable: EventTableVC!

    var dotBezel: UIView!
    var pageFrame = CGRect.zero
    var childFrame = CGRect.zero
    var bezelFrame = CGRect.zero

    func updateFrames(_ size:CGSize) {

        let width  = size.width
        let height = size.height
        let statusH = UIApplication.shared.statusBarFrame.height
        
        let isPad = UIDevice.current.userInterfaceIdiom == .pad
        let isPanel = isPad && width < height/2 // is panel inside ipad app
        let isPortrait = height > width // is portrait mode
        let viewY = CGFloat(isPanel ? 0 : isPad ? 18 : isPortrait ? statusH : 0)
        let viewH = height - viewY

        let bezelW = CGFloat(64)
        let bezelH = CGFloat(36)
        let bezelX = (width - bezelW)/2
        let bezelY = height - bezelH

        let childH = viewH - bezelH

        pageFrame  = CGRect(x: 0, y: viewY,  width: width, height: viewH)
        childFrame = CGRect(x: 0, y: 0,      width: width, height: childH)
        bezelFrame = CGRect(x: bezelX, y: bezelY, width: bezelW, height: bezelH)
    }

    func updateViews(_ size:CGSize) {

        treeTable.updateViews(size.width)
        treeTable.tableView.reloadData()
        eventTable.tableView.reloadData()
    }

    func showHelpBubble() {
        let helpText = """
            This preview will show your weekly routine on the clock face. \n
            You can edit times, titles, and days of the week, but not categories or colors. \n
            A more customizable version will be available for purchase in an upcoming release.
            """
        let _ = BubbleText(helpText, from:dotBezel, in:view)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //showHelpBubble()
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
        eventTable = storyboard.instantiateViewController(withIdentifier: "EventTable") as! EventTableVC
        treeTable  = storyboard.instantiateViewController(withIdentifier: "TreeTable")  as! TreeTableVC

        setBorder(treeTable,  radius:  8, width: 0)
        setBorder(eventTable, radius: 16, width: 0)
        
        treeTable.tableView.contentInset  = .zero
        eventTable.tableView.contentInset = .zero

        treeTable.view?.frame = childFrame
        eventTable.view?.frame = childFrame

        pages = [treeTable,eventTable]
        pageVC.setViewControllers([eventTable], direction: .reverse, animated: false, completion: nil)

        dotBezel = UIView(frame:bezelFrame)
        dotBezel.layer.cornerRadius = dotBezel.frame.size.height/2
        dotBezel.layer.borderColor = UIColor.clear.cgColor
        dotBezel.layer.borderWidth = 0.5
        view.addSubview(dotBezel)

        addChildViewController(pageVC)
        view.addSubview(pageVC.view)
        pageVC!.didMove(toParentViewController: self)
    }

    func setBorder(_ vc:UIViewController, radius: CGFloat, width: CGFloat) {

        vc.view.layer.cornerRadius = radius
        vc.view.layer.borderColor = headColor.cgColor
        vc.view.layer.borderWidth = width
        vc.view.layer.masksToBounds = true
    }
    
    func pageViewController(_ pageVC: UIPageViewController, viewControllerBefore vc: UIViewController) -> UIViewController? {
        
        if let index = pages.index(of: vc), index > 0 {
            pagei = index - 1
            return pages[pagei]
        }
        return nil
    }
    
    func pageViewController(_ pageVC: UIPageViewController, viewControllerAfter vc: UIViewController) -> UIViewController? {
        
        if let index = pages.index(of: vc), index < pages.count-1 {
            pagei = index + 1
            return pages[pagei]
        }
        return nil
    }
    
    func presentationCount(for: UIPageViewController) -> Int {
        return pages.count
    }
    
    func presentationIndex(for: UIPageViewController) -> Int {
        return pagei
    }
    
    
}
