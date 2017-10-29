
import UIKit

extension MainVC {
    
    @IBAction func swipeDownAction(_ sender: Any) {
        //text.resignFirstResponder()
    }
    @IBAction func swipeUpAction(_ sender: Any) {
        //text.becomeFirstResponder()
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            //        if text == "\n" {
            //            textView.resignFirstResponder()
            //        }
            return true
        }
        func textViewDidEndEditing(_ textView: UITextView) {
            //actions.parseString(textView.text)
        }
    }
    
        
}
