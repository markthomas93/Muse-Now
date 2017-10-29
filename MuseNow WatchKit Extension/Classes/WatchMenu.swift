//
//  WatchMenu.swift
//  Klio WatchKit Extension
//
//  Created by warren on 10/23/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import WatchKit

class WatchMenu {

    static var shared = WatchMenu()
   /**
     Menu of STT, hand stroked chars, popular commands
     - via WatchCon.menuAction
     */
    func recordMenu() {  printLog("∿ \(#function)")

        //let index = Anim.shared.getIndexForNote()
        let root = WKExtension.shared().rootInterfaceController!
        let suggestions = Actions.shared.getSuggestions()
        root.presentTextInputController(withSuggestions:suggestions, allowedInputMode: WKTextInputMode.plain) { results in
            guard let results = results else {  print("∿ no results"); return  }
            for result in results {
                if let inputText = result as? String {
                    self.recordMenuFinish(inputText, /*index*/ 0)
                }
            }
            //self.menuRecTimer = Timer.scheduledTimer(timeInterval: 1.0, target:self, selector: #selector(self.recordTimerDone),userInfo:nil, repeats:false)
        }
    }

    func recordMenuFinish(_ inputText:String,_ index: Int) { printLog("∿ \(#function)")
        Actions.shared.parseString(inputText, /*event*/ nil, index, isSender:true)
        //Crown.shared.updateCrown()
    }

}
