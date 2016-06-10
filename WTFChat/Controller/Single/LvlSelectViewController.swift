import Foundation

class LvlSelectViewController: UIViewController {
    @IBOutlet weak var lvlCollectionView: LvlCollectionView!

    var talk: SingleTalk!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true

        let nav = self.navigationController?.navigationBar
        nav?.translucent = false

        lvlCollectionView.delegate = lvlCollectionView
        lvlCollectionView.dataSource = lvlCollectionView

        updateLvlCollectionView()

        self.title = talk.cipherType.description + " - " + talk.cipherDifficulty.description
    }

    func updateLvlCollectionView() {
        lvlCollectionView.updateSingleTalk(talk)
    }
}
