//
//  MainVC+Background.swift
//  MuseNow
//
//  Created by warren on 5/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

extension MainVC {

    func registerBackgroundTask() {
        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
            self?.endBackgroundTask()
        }
        assert(backgroundTask != UIBackgroundTaskInvalid)
    }

    func endBackgroundTask() {
        print("Background task ended.")
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = UIBackgroundTaskInvalid
    }

}
