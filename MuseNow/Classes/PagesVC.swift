//  Pages.swift

import UIKit

class PagesVC: UIViewController, UIPageViewControllerDataSource {
    
    static let shared = PagesVC()

    var pageVC : UIPageViewController!
    var pages: [UIViewController] = []
    var pagei = 1
    var scrollView: UIScrollView!
    
    var calTable: CalTableVC!
    var eventTable: EventTableVC!
    var panelY = CGFloat(0)

    override func viewDidLoad() {
        
        super.viewDidLoad()
        let optionsDict = [UIPageViewControllerOptionInterPageSpacingKey : 20]
        let marginY = CGFloat(36)

        pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: optionsDict)
        pageVC.dataSource = self
        pageVC.view!.frame = CGRect(x:0, y:marginY, width: view.frame.size.width, height: panelY-marginY)
        
        for view in pageVC.view.subviews {
            if view is UIScrollView {
                scrollView = view as! UIScrollView
                break
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        calTable   = storyboard.instantiateViewController(withIdentifier: "CalTable")   as! CalTableVC
        eventTable = storyboard.instantiateViewController(withIdentifier: "EventTable") as! EventTableVC
        setBorder(calTable,     radius:  8, width: 0)
        setBorder(eventTable,   radius: 16, width: 0)
        
        calTable.tableView.contentInset   = UIEdgeInsetsMake(0, 0, 0, 0)
        eventTable.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        pages = [calTable,eventTable]
        pageVC.setViewControllers([eventTable], direction: .reverse, animated: false, completion: nil)

        addChildViewController(pageVC)
        view.addSubview(pageVC.view)
        pageVC!.didMove(toParentViewController: self)
    }
    
    func setBorder(_ vc:UIViewController, radius: CGFloat, width: CGFloat) {
        vc.view.frame = CGRect(x:2,y:0,width:self.view.frame.size.width-4,height:  panelY - 40)
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
