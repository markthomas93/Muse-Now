import UIKit

/**
 Cache speech + title items based on type, delay, and decay
 */
class SayCache {
    
    var sayType  : [SayType:SayItem] = [:]
    var sayQueue : [SayItem] = []
    
    /**
     Sequence phrases and title based an delay and decay.
     - decay < now: replace items of same type w new phrase
     - decay > now: Ok to repeat the same phrase
     */
    func updateCache(_ newItem:SayItem) {

        /// first remove item of same type in que if differnt
        func removeItemsOfSameTypeFromQueue() -> Bool {
            if let item = sayType[newItem.type] { // there is an item of same type in cache
                let timeNow = Date().timeIntervalSince1970
                if timeNow > item.decay { sayQueue.removeObject(item) } // prev expired past decay time
                else if newItem.spoken == item.spoken { return false }  // prev has same phrase so ignore
                else {  sayQueue.removeObject(item) } // different phrase, remove old version in sequence list
            }
            return true // still continue, even if no items of same type found
        }

        /// next add new item to queue, sometimes before slower feedback items
        func addNewItemToQueue() {
            var index = 0
            for item in sayQueue {
                if item.delay > newItem.delay {
                    sayQueue.insert(newItem, at: index) // newItem.log("say + at:\(index)")
                    return
                }
                index += 1
            }
            sayQueue.append(newItem) // newItem.log("say + append:\(index)")
        }

        if removeItemsOfSameTypeFromQueue() {
            sayType[newItem.type] = newItem
            addNewItemToQueue()
        }
    }
    
    func clearTypes(_ types: [SayType]) {
        for type in types {
            for item in sayQueue {
                if item.type == type {
                    sayQueue.removeObject(item)
                    break
                }
            }
        }
    }

    func clearAll() {
        sayType.removeAll()
        sayQueue.removeAll()
    }
    
    func popNext() -> SayItem! {
        if let tp = sayQueue.first {
            let timeNow =  Date().timeIntervalSince1970
            let deltaTime = tp.delay - timeNow
            if deltaTime <= 0 {
                sayQueue.remove(at: 0)
                return tp
            }
        }
        return nil
    }
    
    func getNext() -> SayItem! {
        if let tp = sayQueue.first {
            return tp
        }
        return nil
    }
}
