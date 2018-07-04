//
//  TreeNodes+Archive.swift
// muse •
//
//  Created by warren on 6/6/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

/** not currently used because dynamic changes, such as Calendars and Routine are derived from other sources */

extension TreeNodes {

    func archiveTree(done:@escaping CallVoid) {

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(root) {
            let _ = saveData(data)
        }
        done()
    }

  
    /**
     */
    func unarchiveTree(_ done: @escaping CallVoid) {

        assert(false, "Currently unused; changes to model persists in other json files")

        unarchiveData() { data in
           self.mergeData(data, done)
        }
    }
}
