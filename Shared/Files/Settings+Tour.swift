//
//  Settings+Tour.swift
//  MuseNow
//
//  Created by warren on 3/29/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

extension Settings {

    func backupSettings() {

        if let data = try? JSONEncoder().encode(settings) {
            let backName = fileName+".backup"
            Log ("⧉⧉ Settings::backupSettings to file: \(backName)")
            let _ = saveData(data, backName)
        }
    }

    func restoreFromBackup(_ done: @escaping () -> Void) {

        let backName = fileName+".backup"
        let fm = FileManager.default
        fm.delegate = self

        let fileUrl = FileManager.documentUrlFile(fileName)
        let backUrl = FileManager.documentUrlFile(backName)

        do {
            if fm.fileExists(atPath: backUrl.path) {
                if fm.fileExists(atPath: fileUrl.path) {
                    try fm.removeItem(at: fileUrl)
                }
                try fm.moveItem(at:backUrl, to:fileUrl)
            }
            Log ("⧉⧉ Settings::restoreFromBackup overwrite from backup file: \(backName)")
            done()
        }
        catch {
            Log ("⧉⧉ Settings::restoreFromBackup no backup file: \(backName)")
            done()
        }
    }


    func prepareDemoSettings() {
        #if os(iOS)
            Log ("⧉ Settings::\(#function)")

            backupSettings()

            // new demo Settings
            Show.shared.showSet = [.calendar,.reminder,.memo,.routine,.routList,.routDemo]
            Say.shared.saySet = []
            Actions.shared.dialColor(1.0, isSender: false)
            settingsFromMemory()

            TreeNodes.shared.root?.refreshNodeCells()
            PagesVC.shared.menuVC?.tableView.reloadData()
            Actions.shared.doAction(.refresh)
        #endif

    }

    func finishDemoSettings() {
        #if os(iOS)
            Log ("⧉ Settings::\(#function)")
            restoreFromBackup {
                self.unarchiveSettings {
                    TreeNodes.shared.root?.refreshNodeCells()
                    PagesVC.shared.menuVC?.tableView.reloadData()
                    Actions.shared.doAction(.refresh)
                }
            }
        #endif
    }

}
