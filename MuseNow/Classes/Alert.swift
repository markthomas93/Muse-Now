//
//  Alert.swift
//  MuseNow
//
//  Created by warren on 3/30/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

class Alert {

    static var shared = Alert()

    var alert:UIAlertController!

    func doAct(_ headline_:String,_ body:String,_ anys:[Any],_ vc: UIViewController) {

        alert = UIAlertController(title: headline_, message: body, preferredStyle: .actionSheet)

        let attributedTitle = NSMutableAttributedString(string: headline_, attributes:
            [NSAttributedStringKey.font: UIFont(name:"Helvetica Neue", size: 24)!,
             NSAttributedStringKey.foregroundColor: UIColor.lightGray] )
        alert.setValue(attributedTitle, forKey : "attributedTitle")

        let attributedMessage = NSMutableAttributedString(string: "", attributes:
            [NSAttributedStringKey.font: UIFont(name:"Helvetica Neue", size: 2)!,
             NSAttributedStringKey.foregroundColor: UIColor.lightGray ] )
        alert.setValue(attributedMessage, forKey : "attributedMessage")

        if let firstView = alert.view.subviews.first?.subviews.first {
            for subview in firstView.subviews {
                subview.backgroundColor = cellColor
                //subview.layer.cornerRadius = 10
                subview.alpha = 1
                subview.layer.borderWidth = 1
                subview.layer.borderColor = UIColor.white.cgColor
            }
        }

        var title = ""
        for any in anys {
            switch any {
            case let any as String:   title = any
            case let any as CallVoid:

                let action = UIAlertAction(title: title, style: .default, handler: { _ in
                    any()
                })
                action.setValue(UIColor.white, forKey : "titleTextColor")
                alert.addAction(action)
            default: break
            }
        }
        vc.present(alert, animated: true, completion: nil)
    }

}
