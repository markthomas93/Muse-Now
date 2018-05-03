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
    ekevent     = "ekevent",    // Apple Calendar events
    ekreminder  = "ekreminder", // Apple Reminders
    memoRecord  = "memoRecord", // memo has audio recording
    memoTrans   = "memoTrans",  // memo transcribed
    memoBlank   = "memoBlank",  // memo transcription yielded nothing
    memoTrash   = "memoTrash",  // memo trashed by user
    routine     = "routine",
    time        = "time"
}
