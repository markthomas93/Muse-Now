//
//  Transcribe+Pargraph.swift
// muse •
//
//  Created by warren on 5/3/18.
//  Copyright © 2018 Muse. All rights reserved.
//

import Foundation

#if os(iOS)
import Speech
extension Transcribe {

    func matchMuseFound(_ result: SFSpeechRecognitionResult) -> MuseFound {

        var log = "✏\n"

        var nearestFound = MuseFound(result.bestTranscription.formattedString,nil,Int.max)

        for trans in result.transcriptions {

            let txt = trans.formattedString.lowercased()
            log += "   \"\(txt)\" "
            let found = Muse.shared.findMatch(txt)
            log += Muse.shared.resultStr(found) + "\n"

            if  nearestFound.hops > found.hops, found.hops > -1 {
                nearestFound = MuseFound(found)
            }

            for seg in trans.segments {
                log += String(format:"     t:%.2f d:%.2f conf:%.3f \"%@\"\n",
                              seg.timestamp, seg.duration, seg.confidence, seg.substring)
            }
        }
        log += "     ✏ \(nearestFound.str!)"
        Log(log)
        return nearestFound
    }

}
#endif
