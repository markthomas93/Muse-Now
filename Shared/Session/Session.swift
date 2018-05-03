import WatchKit
import WatchConnectivity

class Session: NSObject, WCSessionDelegate {
    
    static let shared = Session()

    var session: WCSession? = WCSession.isSupported() ? WCSession.default : nil

    var validSession: WCSession? {
        
        #if os(iOS)
            // watch is paired and app is installed ?
            if
                let session = session,
                session.isWatchAppInstalled,
                session.isPaired,
                session.isReachable {
                
                return session
            }
            return nil /* ask to install watch app? */
        #elseif os(watchOS)
            return session
        #endif
    }

    func startSession() {

        //anim = anim_
        //actions = actions_
        session?.delegate = self
        session?.activate()
    }

}
