//
//  DemoBackupDelegate.swift
// muse •
//
//  Created by warren on 6/1/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

public protocol DemoBackupDelegate : NSObjectProtocol {

    func setFrom(_ from:Any)
    func setupBackup()
    func setupBeforeDemo()
    func restoreAfterDemo() 
}

