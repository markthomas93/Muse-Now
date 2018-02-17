//
//  EventType.swift
//  MuseNow
//
//  Created by warren on 2/14/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

public enum EventType: String, Codable { case
    unknown     = "unknown",
    routine     = "routine",
    ekevent     = "ekevent",    // Apple Calendar events
    ekreminder  = "ekreminder", // Apple Reminders
    note        = "note",
    memo        = "memo",
    time        = "time"
}
