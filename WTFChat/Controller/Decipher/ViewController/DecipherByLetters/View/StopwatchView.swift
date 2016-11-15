import UIKit

class StopwatchView: UILabel {
  
  //this should never be called
  required init(coder aDecoder:NSCoder) {
    fatalError("use init(frame:")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    self.backgroundColor = UIColor.clear
    self.font = FontHUDBig
  }
  
  //helper method that implements time formatting
  //to an int parameter (eg the seconds left)
  func setSeconds(_ seconds:Int) {
    self.text = String(format: " %02i : %02i", seconds/60, seconds % 60)
  }
}
