//
//  RatingViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 16/11/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class RatingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
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
    
    override func viewWillAppear(animated: Bool) {
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
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    WTFOneButtonAlert.show("Error", message: connectionErrorDescription(), firstButtonTitle: "Ok", viewPresenter: self)
                    
                    NSLog(requestError.localizedDescription)
                } else {
                    if let friends = users {
                        self.friends = friends
                        self.friends.append(userService.getSelfUserInfo()!)
                        self.updateView()
                    }
                }
            })
        }
    }
    
    func loadTopUsers() {
        userService.getTopRatings() { (users, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    WTFOneButtonAlert.show("Error", message: connectionErrorDescription(), firstButtonTitle: "Ok", viewPresenter: self)
                    
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
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (showFriendsOnly) {
            return friends.count
        } else {
            return users.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: RatingCell
        
        if (showFriendsOnly) {
            cell = tableView.dequeueReusableCellWithIdentifier("FriendRatingCell", forIndexPath: indexPath) as! RatingCell
            let friend = friends[indexPath.row]
            cell.updateUser(friend, num: indexPath.row + 1)
        } else {
            cell = tableView.dequeueReusableCellWithIdentifier("GlobalRatingCell", forIndexPath: indexPath) as! RatingCell
            let user = users[indexPath.row]
            cell.updateUser(user, num: indexPath.row + 1)
            return cell
        }
        
        return cell
    }
    
    @IBAction func categoryChanged(sender: AnyObject) {
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
        self.friends = self.friends.sort(FriendInfo.compareByExp)
        self.users = self.users.sort(FriendInfo.compareByExp)
        self.usersView.reloadData()
    }
}