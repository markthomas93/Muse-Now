import WatchKit

extension WatchCon  {
    
    func testSession() {
        
        let width  = roundf(Float(self.contentFrame.size.width  / 4)) * 8
        let height = roundf(Float(self.contentFrame.size.height / 4)) * 8
        
        let widthStr = String(format:"width:%.f",width)
        let widthMsg = ["size":widthStr as AnyObject]
        
        let heightStr = String(format:"height:%.f",height)
        let heightMsg = ["size":heightStr as AnyObject]
        
        var sending = Session.shared.sendMessage(widthMsg, errorHandler: { (error) -> Void in
            print ("↔︎ testSession width error:\(error)")
        })
        if !sending {
              print ("↔︎ testSession UNSENT")
        }
        sending = Session.shared.sendMessage(heightMsg, errorHandler: { (error) -> Void in
            print ("testSession height error:\(error)")
        })
        if !sending {
            print ("↔︎ testSession UNSENT")
        }

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
