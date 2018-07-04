//
//  OnboardVC+delegate.swift
// muse •
//
//  Created by warren on 1/13/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

extension OnboardVC:  UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {

        if pageIndex > 0 {
            pageIndex -= 1
            pageControl.currentPage = pageIndex
            return onboardPages[pageIndex]
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        if pageIndex < onboardPages.count-1 {
            pageIndex += 1
            pageControl.currentPage = pageIndex
            return onboardPages[pageIndex]
        }
        return nil
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if (!completed) {
            return
        }
        pageIndex = pageViewController.viewControllers!.first!.view.tag
        pageControl.currentPage = pageIndex
        Log("🔰 Onboard page:\(pageIndex)")
    }
 }
