//
//  MainVC+override.swift
// muse •
//
//  Created by warren on 1/28/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit
import ParGraph

extension MainVC {

    override func viewDidLoad() {

        super.viewDidLoad()
        MainVC.shared = self

        view.accessibilityIgnoresInvertColors = true  // stay dark in invert mode
        view.backgroundColor = .black

        updateFrames(view.bounds.size)
        pagesVC.updateFrames(pagesFrame.size)
        view.addSubview(pagesVC.view)
        
        Settings.shared.unarchiveSettings {
            TreeNodes.shared.initTree() {
                if Settings.shared.onboarding {
                    self.makeOnboard()
                }
                else {
                    self.makePages {
                        Timer.delay(4) {Tour.shared.buildInfoSet()}
                    }
                }
            }
        }
        Muse.shared.testScript() // for future use of ParGraph
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        if UIAccessibilityIsInvertColorsEnabled() {
            return .default
        }
        else {
            return .lightContent
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {

        Log("▣ MainVC \(size)")
        super.viewWillTransition(to: size, with: coordinator)
    }

    override func viewDidAppear(_ animated: Bool) { Log("⟳ \(#function)")
        active?.startActive()
    }

    override func viewWillDisappear(_ animated: Bool) {
        observer?.invalidate()
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    override var prefersStatusBarHidden : Bool {
        return false
    }
    
}
