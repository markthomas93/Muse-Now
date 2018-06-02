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

    func unarchiveMarks(_ done: @escaping () -> Void) {
        
        unarchiveData() { data in
            if let data = data,
                let newIdMark = try? JSONDecoder().decode([String:Mark].self, from:data) {

                self.idMark.removeAll()
                self.idMark = newIdMark
            }
            done()
        }

    }

}
