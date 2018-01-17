//
//  FileSync+delegate.swift
//  MuseNow
//
//  Created by warren on 1/12/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

extension FileSync {

    func fileManager(_ fileManager: FileManager,
                              shouldProceedAfterError error: Error,
                              copyingItemAt srcURL: URL,
                              to dstURL: URL) -> Bool {
        return true
    }
}
