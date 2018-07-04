import WatchKit

extension WatchCon  {
    
    func testSession() {
        
        let width  = roundf(Float(self.contentFrame.size.width  / 4)) * 8
        let height = roundf(Float(self.contentFrame.size.height / 4)) * 8
        
        let widthStr = String(format:"width:%.f",width)
        let widthMsg = ["size":widthStr as AnyObject]
        
        let heightStr = String(format:"height:%.f",height)
        let heightMsg = ["size":heightStr as AnyObject]
        
         Session.shared.sendMessage(
            widthMsg,
            replyHandler: {_ in },
            errorHandler: { err in print ("↔︎ testSession width error:\(err)")
        })

        Session.shared.sendMessage(
            heightMsg,
            replyHandler: {_ in },
            errorHandler: { err in print ("↔︎ testSession height error:\(err)")
        })
    }
    
    func testApplicationContext() {
        
        let width  = roundf(Float(self.contentFrame.size.width  / 4)) * 8
        let height = roundf(Float(self.contentFrame.size.height / 4)) * 8
        
        let widthStr = String(format:"width:%.f",width)
        let widthMsg = ["size":widthStr as AnyObject]
        
        let heightStr = String(format:"height:%.f",height)
        let heightMsg = ["size":heightStr as AnyObject]
        
       Session.shared.cacheMsg(widthMsg)
       Session.shared.cacheMsg(heightMsg)
    }
    
   
}
