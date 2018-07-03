//
//  IntentHandler.swift
//  Muse Intent
//
//  Created by warren on 7/2/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Intents

class IntentHandler: INExtension, DotIntentHandling {

    func confirm(intent: DotIntent, completion: (DotIntentResponse) -> Void) {
        completion(DotIntentResponse(code: .ready, userActivity: nil))
    }
    func handle(intent: DotIntent, completion: (DotIntentResponse) -> Void) {
        print("\(#function) \(intent)")
        completion(DotIntentResponse(code: .success, userActivity: nil))
    }

    override func handler(for intent: INIntent) -> Any {
        print("\(#function) \(intent)")
        return self
    }
}
