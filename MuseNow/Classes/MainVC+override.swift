//
//  MainVC+override.swift
//  MuseNow
//
//  Created by warren on 1/28/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

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
            let onboarding = Onboard.shared.state == .boarding //???//  || true
            if  onboarding { self.makeOnboard() }
            else           { self.makePages {Timer.delay(4) {Tour.shared.buildInfoSet()}} }

        }
        Muse.shared.testScript() // for future use of ParGraph
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
        //...
    }

    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }

    override var prefersStatusBarHidden : Bool {
        return false
    }
    
}
