import UIKit

class TutorialCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!

    func initStyle() {
        title.adjustsFontSizeToFitWidth = true

        self.selectionStyle = .none;
    }
    
    func updateTitle(_ title: String) {
        initStyle()

        self.title.text = title
    }
}
