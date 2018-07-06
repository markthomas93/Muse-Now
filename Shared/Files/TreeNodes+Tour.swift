//
//  Settings+Tour.swift
// muse •
//
//  Created by warren on 3/29/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

extension Tour {

    //    func backupSettings() {
    //
    //        let encoder = JSONEncoder()
    //        encoder.outputFormatting = .prettyPrinted
    //
    //        if let data = try? encoder.encode(settings) {
    //            let backName = fileName+".backup"
    //            Log ("⧉⧉ Settings::backupSettings to file: \(backName)")
    //            let _ = saveData(data, backName)
    //        }
    //    }
    //
    //    func restoreFromBackup(_ done: @escaping () -> Void) {
    //
    //        let backName = fileName+".backup"
    //        let fm = FileManager.default
    //        fm.delegate = self
    //
    //        let fileUrl = FileManager.documentUrlFile(fileName)
    //        let backUrl = FileManager.documentUrlFile(backName)
    //
    //        do {
    //            if fm.fileExists(atPath: backUrl.path) {
    //                if fm.fileExists(atPath: fileUrl.path) {
    //                    try fm.removeItem(at: fileUrl)
    //                }
    //                try fm.moveItem(at:backUrl, to:fileUrl)
    //            }
    //            Log ("⧉⧉ Settings::restoreFromBackup overwrite from backup file: \(backName)")
    //            done()
    //        }
    //        catch {
    //            Log ("⧉⧉ Settings::restoreFromBackup no backup file: \(backName)")
    //            done()
    //        }
    //    }


    func prepareDemoSettings() {

        Log ("⧉ \(#function)")

        Show.shared.setupBeforeDemo()
        Say.shared.setupBeforeDemo()
        Settings.shared.setupBeforeDemo()

        TreeNodes.shared.root?.refreshNodeCells()
        PagesVC.shared.menuVC?.tableView.reloadData()
        Actions.shared.doAction(.refresh)
    }

    func finishDemoSettings() {
        Log ("⧉ \(#function)")
        Show.shared.restoreAfterDemo()
        Say.shared.restoreAfterDemo()
        Settings.shared.restoreAfterDemo()

        TreeNodes.shared.root?.refreshNodeCells()
        PagesVC.shared.menuVC?.tableView.reloadData()
        Actions.shared.doAction(.refresh)
    }

}
