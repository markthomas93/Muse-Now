
import Foundation



extension Collection {
    typealias Comparator = (Iterator.Element) -> Bool

    /**
     Finds index N such that isLess is true
     for all elements up to but not including the index N,
     and is false for all elements starting with index N.
     Behavior is undefined if there is no such N.
     */
    func search(isLess:Comparator) -> Index {

        var low = startIndex
        var high = endIndex

        while low != high {

            let mid = index(low, offsetBy: distance(from: low, to: high)/2)

            if isLess(self[mid]) { low = index(after: mid) }
            else                 { high = mid }
        }
        return low
    }

    func searchAfter(_ after:Int, isLess:Comparator) -> Index {

        var low = index(startIndex, offsetBy:after)
        var high = endIndex

        while low != high {

            let mid = index(low, offsetBy: distance(from: low, to: high)/2)

            if isLess(self[mid]) { low = index(after: mid) }
            else                  { high = mid }
        }
        return low
    }


    func searchBefore(_ before:Int, isLess:Comparator) -> Index {

        var low = startIndex
        var high = index(startIndex, offsetBy:before)

        while low != high {

            let mid = index(low, offsetBy: distance(from: low, to: high)/2)

            if isLess(self[mid]) { low = index(after: mid) }
            else                 { high = mid }
        }
        return low
    }

    func searchAdjacent(_ index_:Index, isDupli:Comparator, isUnique:Comparator) -> Any? {

        if isUnique(self[index_]) {  return self[index_] } // found unique id on first try

        var ii = index_
        while ii != startIndex {
            ii = index(ii, offsetBy: -1) // search before
            if !isDupli(self[ii]) { break }  // no more prior duplicate search keys
            if isUnique(self[ii]) { return self[ii] } // found unique id
        }
        ii = index_
        while ii != endIndex {
            ii = index(after:ii) // search after
            if !isDupli(self[ii]) { return nil } // no more duplicate search keys
            if isUnique(self[ii]) { return self[ii] } // found unique id
        }
        return nil
    }

}

