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

    var anys = [Any]()
    var bubble: Bubble!

    convenience init(_ title_:String,_ anys_: [Any]) {
        self.init()
        title = title_
        anys = anys_
    }

    override func viewDidLoad() {

        super.viewDidLoad()

        view.backgroundColor = .clear

        let label = UILabel()
        view.addSubview(label)
        label.text = title
        label.textAlignment = .center
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        label.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 0).isActive = true
        label.frame.size.width = view.frame.size.width
    }

    override func viewDidAppear(_ animated: Bool) {
        Log("🔰 appear: \(title!)")
        let bubs = Tour.shared.bubsFrom(anys)
        bubble = Bubble(title!, .center, .text, CGSize(width:256,height:128), view, view, [], [], [], bubs)
        bubble.tourNextBubble { }
    }
    override func viewWillDisappear(_ animated: Bool) {
        Log("🔰 disappear: \(title!)")
        bubble?.bubBase?.cancelBubble()
        super.viewWillDisappear(animated)
    }

}
