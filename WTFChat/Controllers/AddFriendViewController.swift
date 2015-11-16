//
//  AddFriendViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 26/09/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

class AddFriendViewController: UITableViewController, UISearchResultsUpdating {
    var friends = [FriendInfo]()
    var lastRequest = ""
    
    var searchController: AnyObject?
    
    var createdTalk: Talk?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true
        
        addSearchController()
        
        loadFriends("")
    }

    func addSearchController() {
        if #available(iOS 8.0, *) {
            let searchController = UISearchController(searchResultsController: nil)
            searchController.searchResultsUpdater = self
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.sizeToFit()
            self.tableView.tableHeaderView = searchController.searchBar
            self.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AddFriendCell", forIndexPath: indexPath) as! AddFriendCell
        
        let friend = friends[indexPath.row]
        cell.updateFriend(friend)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let friend = friends[indexPath.row]
  
        var viewPresenter: UIViewController
        
        if #available(iOS 8.0, *) {
            let uiSearchController = searchController as! UISearchController
            
            if (uiSearchController.active) {
                viewPresenter = uiSearchController
            } else {
                viewPresenter = self
            }
        } else {
            viewPresenter = self
        }
        
        WTFTwoButtonsAlert.show("Add Friend",
            message: "Are you sure you want to add \(friend.getDisplayName()) to your friends?",
            firstButtonTitle: "Ok",
            secondButtonTitle: "Cancel",
            viewPresenter: viewPresenter) { () -> Void in
                self.makeFriends(friend)
        }
    }
    
    @available(iOS 8.0, *)
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        loadFriends(searchController.searchBar.text!)
    }
    
    private func makeFriends(friend: FriendInfo) {
        userService.makeFriends(friend) { (talk, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    //TODO - show error to user
                    print(requestError)
                } else {
                    self.createdTalk = talk
                    self.performSegueWithIdentifier("addFriend", sender: self)
                }
            })
        }
    }
    
    private func loadFriends(request: String) {
        self.lastRequest = request
        
        userService.getNewFriends(request) { (friends, error) -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    //TODO - show error to user
                    print(requestError)
                } else {
                    if let newFriends = friends {
                        self.updateFriends(request, friends: newFriends)
                    }
                }
            })
        }
    }
    
    private func updateFriends(request: String, friends: [FriendInfo]) {
        if (self.lastRequest == request) {
            self.friends = friends
            self.tableView.reloadData()
        }
    }
}
