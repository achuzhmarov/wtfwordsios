import UIKit

class FriendsViewController: UITableViewController, TalkListener {
    fileprivate let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)
    fileprivate let talkService: TalkService = serviceLocator.get(TalkService.self)
    fileprivate let windowService: WindowService = serviceLocator.get(WindowService.self)

    var talks = [FriendTalk]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        talkService.friendsTalkListener = self
        
        let nav = self.navigationController?.navigationBar
        nav?.isTranslucent = false
        
        let tab = self.tabBarController?.tabBar
        tab?.isTranslucent = false
    }
    
    deinit {
        talkService.friendsTalkListener = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.talks = talkService.talks
        self.updateView()
        talkService.getNewUnreadTalks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //delegate for TalkListener
    func updateTalks(_ talks: [FriendTalk]?, error: NSError?) {
        DispatchQueue.main.async(execute: {
            if let requestError = error {
                print(requestError)
            } else {
                if let newTalks = talks {
                    self.talks = newTalks
                    self.updateView()
                }
            }
        })
    }
    
    func updateView() {
        self.talks = self.talks.sorted { (talk1, talk2) -> Bool in
            if (talk1.isSingleMode) {
                return true
            } else if (talk2.isSingleMode) {
                return false
            } else if (talk1.lastMessage != nil && talk2.lastMessage != nil) {
                return talk1.lastMessage!.lastUpdate.isGreater(talk2.lastMessage!.lastUpdate)
            } else if (talk1.lastMessage != nil) {
                return true
            } else if (talk2.lastMessage != nil) {
                return false
            } else {
                let friend1 = currentUserService.getFriendLogin(talk1)
                let friend2 = currentUserService.getFriendLogin(talk2)

                return friend1.isGreater(friend2)
            }
        }
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendCell", for: indexPath) as! FriendCell

        let talk = talks[indexPath.row]
        
        cell.updateTalk(talk)
        
        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMessages" {
            let targetController = segue.destination as! MessagesViewController
            
            if let rowIndex = tableView.indexPathForSelectedRow?.row {
                targetController.talk = talks[rowIndex]
            }
        }
    }
}
