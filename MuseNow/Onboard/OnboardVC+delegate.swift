//
//  OnboardVC+delegate.swift
//  MuseNow
//
//  Created by warren on 1/13/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

extension OnboardVC:  UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        if let i = onboardPages.index(of: viewController),
            i > 0 {
            return onboardPages[i-1]
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        if let i = onboardPages.index(of: viewController),
            i < onboardPages.count - 1 {

            return onboardPages[i+1]
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {

        if  let vcs = pageViewController.viewControllers,
            let i = onboardPages.index(of:vcs[0]) {

            Log("🔰 anim page:\(i)")
            pageControl.currentPage = i
        }
    }
}
