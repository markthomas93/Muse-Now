//
//  Transcribe+SWM.swift
//  Klio
//
//  Created by warren on 9/6/17.
//  Copyright © 2017 Muse. All rights reserved.
//

import Foundation

// Transcribe speech to text using Speak With Me
extension Transcribe {

    static let SwmUrl = "http://demo.speakwithme.com/p.php" +
        "?api_user=speakwithme" +
        "&token=UqrcPSwbfEnd6Z8AEB5QItKKc8haFnXPhPc2nLsw1iy" +
        "&secret=T3JsjS9SOpzC5HoFmie5CL7v63RXUMz7aEZ9wZUjoxb" +
    "&method=dictation"

    func transcribeSWM(_ recName: String,_ completion: @escaping (_ result:String) -> Void) {

        let url = FileManager.documentUrlFile(recName)
        print ("✏ \(#function) url:\(url)")

        let data = NSData(contentsOfFile: url.path)! as Data

        let swmFileUrl = Transcribe.SwmUrl + "&filename=" + recName
        let request = NSMutableURLRequest(url: NSURL(string: swmFileUrl)! as URL)
        request.httpMethod = "POST"
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        let fname = url.path.utf8
        let mimetype =  "audio/mp4"

        let body = NSMutableData()
        body.append("--\(boundary)\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Disposition:form-data; name=\"file\"; filename=\"\(fname)\"\r\n".data(using: String.Encoding.utf8)!)
        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(data)
        body.append("\r\n".data(using: String.Encoding.utf8)!)
        body.append("--\(boundary)--\r\n".data(using: String.Encoding.utf8)!)

        request.httpBody = body as Data

        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if let data = data {
                if let error = error { print("error: \(error)") }
                let result = NSString(data: data, encoding: String.Encoding.utf8.rawValue) ?? "Memo"
                let output = result.lowercased.replacingOccurrences(of: "\n", with: "")
                //print("\(#function) response:\(response as Any) result:\(output)")
                print("✏ transcribe SWM result:\(output)")
                completion(output)
            }
            else if let error = error {
                print("✏ transcribe SWM error:\(error)")
                completion("Memo")
            }
        }
        task.resume()
    }

    //    class func transcribeSWM(_ recName: String, _ event:KoEvent)  {
    //
    //        let docURL = FileManager.documentUrlFile(recName)
    //        print ("✏ \(#function) url:\(docURL)")
    //        transcribeSWM(recName) { txt in
    //            if !txt.isEmpty {
    //                let found = Klio.shared.findMatch(txt)
    //                if let str = found.str {
    //                    event.title = str
    //                    event.sttSwm = str
    //                    Klio.shared.execFound(found, event)
    //
    //                }
    //            }
    //        }
    //    }

}
