import UIKit

class TutorialCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!

    func initStyle() {
        title.adjustsFontSizeToFitWidth = true

        self.selectionStyle = .None;
    }
    
    func updateTitle(title: String) {
        initStyle()

        self.title.text = title
    }
}
