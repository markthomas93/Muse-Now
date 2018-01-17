//
//  OnboardPages.swift
//  MuseNow
//
//  Created by warren on 1/13/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation
import UIKit

class OnboardPage: UIViewController {

    var action: CallVoid! // action after bubble is shown

    convenience init(_ title_:String, _ action_: @escaping CallVoid) {
        self.init()
        title = title_
        action = action_
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        view.backgroundColor = .darkGray

        let label = UILabel()
        view.addSubview(label)
        label.text = title
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        Log("🔰 appear: \(title!)")
        let bubItem = BubbleItem(title!,4)
        let bubble = Bubble(title!, [bubItem], .center, .text, CGSize(width:128,height:64),
                            view,view,[],[],[])

        BubbleText(bubble).goBubble() {_ in
            self.action?()
        }
    }

}
