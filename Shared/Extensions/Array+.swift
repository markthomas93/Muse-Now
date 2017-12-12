//  Array+Remove.swift

import Foundation

extension Array {
    // remove object from array
    mutating func removeObject<T>(_ obj: T) where T : Equatable {
        self = self.filter({$0 as? T != obj})
    }
    
    public init(count: Int, instancesOf: @autoclosure () -> Element) {
        self = (0 ..< count).map { _ in instancesOf() }
    }
}

