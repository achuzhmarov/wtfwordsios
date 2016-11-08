import UIKit

class RatingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    fileprivate let userService: UserService = serviceLocator.get(UserService.self)
    fileprivate let currentUserService: CurrentUserService = serviceLocator.get(CurrentUserService.self)

    @IBOutlet weak var categorySegment: UISegmentedControl!
    @IBOutlet weak var usersView: UITableView!
    
    var friends = [FriendInfo]()
    var users = [FriendInfo]()
    
    var showFriendsOnly = true
    
    var firstLoad = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        
        loadFriends()
        loadTopUsers()
        
        usersView.delegate = self
        usersView.dataSource = self
        
        updateView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if (firstLoad) {
            firstLoad = false
            return
        }
        
        loadFriends()
        loadTopUsers()
        
        updateView()
    }
    
    func loadFriends() {
        userService.getFriendsRating() { (users, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let requestError = error {
                    WTFOneButtonAlert.show("Error", message: WTFOneButtonAlert.CON_ERR, firstButtonTitle: "Ok")
                    
                    NSLog(requestError.localizedDescription)
                } else {
                    if let friends = users {
                        self.friends = friends
                        self.friends.append(self.currentUserService.getSelfUserInfo()!)
                        self.updateView()
                    }
                }
            })
        }
    }
    
    func loadTopUsers() {
        userService.getTopRatings() { (users, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let requestError = error {
                    WTFOneButtonAlert.show("Error", message: WTFOneButtonAlert.CON_ERR, firstButtonTitle: "Ok")
                    
                    NSLog(requestError.localizedDescription)
                } else {
                    if let topUsers = users {
                        self.users = topUsers
                        self.updateView()
                    }
                }
            })
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (showFriendsOnly) {
            return friends.count
        } else {
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: RatingCell
        
        if (showFriendsOnly) {
            cell = tableView.dequeueReusableCell(withIdentifier: "GlobalRatingCell", for: indexPath) as! RatingCell
            //cell = tableView.dequeueReusableCellWithIdentifier("FriendRatingCell", forIndexPath: indexPath) as! RatingCell
            let friend = friends[indexPath.row]
            cell.updateUser(friend, num: indexPath.row + 1)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "GlobalRatingCell", for: indexPath) as! RatingCell
            let user = users[indexPath.row]
            cell.updateUser(user, num: indexPath.row + 1)
            return cell
        }
        
        return cell
    }
    
    @IBAction func categoryChanged(_ sender: AnyObject) {
        switch categorySegment.selectedSegmentIndex
        {
        case 0:
            showFriendsOnly = true
        case 1:
            showFriendsOnly = false
        default:
            break
        }
        
        updateView()
    }
    
    func updateView() {
        self.friends = self.friends.sorted(by: FriendInfo.compareByExp)
        self.users = self.users.sorted(by: FriendInfo.compareByExp)
        self.usersView.reloadData()
    }
}
