//  Mark.swift

import Foundation

class Marks: FileSync, Codable {
    
    static let shared = Marks()

    var idMark = [String:Mark]()

    override init() {
        super.init()
        fileName = "Marks.json"
    }

    func archiveMarks(done:@escaping CallVoid) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(idMark) {
            let _ = saveData(data)
        }
    }

    override func mergeData(_ data:Data?,_ done: @escaping CallVoid) {
        if let data = data,
            let newIdMark = try? JSONDecoder().decode([String:Mark].self, from:data) {

            idMark.removeAll()
            idMark = newIdMark
        }
        done()
    }
    
    func unarchiveMarks(_ done: @escaping CallVoid) {
        
        unarchiveData() { data in
            if  let data = data {
                self.mergeData(data,done)
            }
            else {
                done()
            }
        }
    }

}
