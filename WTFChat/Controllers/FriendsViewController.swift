//
//  FriendsViewController.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import UIKit

let TALKS_UPDATE_TIMER_INTERVAL = 10.0

//let BACKGROUND_COLOR = UIColor(netHex:0xEEEEEE)
//let HIGHLIGHT_BACKGROUND_COLOR = UIColor(netHex:0xFFFFFF)

let SUCCESS_COLOR = UIColor(netHex:0x3EC303)
let CIPHERED_COLOR = UIColor(netHex:0x0092D7)
let FAILED_COLOR = UIColor(netHex:0xF26964)
let TRY_COLOR = UIColor(netHex:0xEE8D09)
let FONT_COLOR = UIColor.whiteColor()

class FriendsViewController: UITableViewController {
    var timer: NSTimer?
    
    var talks = [Talk]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        talks = userService.getCurrentUser().talks
        
        self.updateView()
    }
    
    override func viewDidDisappear(animated: Bool) {
        if let updateTimer = timer {
            updateTimer.invalidate()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        timer = NSTimer.scheduledTimerWithTimeInterval(TALKS_UPDATE_TIMER_INTERVAL, target: self,
            selector: "updateTalks", userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.talks = userService.getCurrentUser().talks
        self.updateView()
        
        updateTalks()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTalks() {
        userService.getUnreadTalks() {talks, error -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    //TODO - show error to user
                    print(requestError)
                } else {
                    if let newTalks = talks {
                        self.talks = newTalks
                        self.updateView()
                    }
                }
            })
        }
    }
    
    func updateView() {
        self.talks.sortInPlace { (talk1, talk2) -> Bool in
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
                return talk1.getFriendLogin().isGreater(talk2.getFriendLogin())
            }
        }
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return talks.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FriendCell", forIndexPath: indexPath) as! FriendCell

        let talk = talks[indexPath.row]
        
        cell.updateTalk(talk)
        
        return cell
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showMessages" {
            let targetController = segue.destinationViewController as! MessagesViewController
            
            if let rowIndex = tableView.indexPathForSelectedRow?.row {
                targetController.talk = talks[rowIndex]
            }
        }
    }
    
    @IBAction func addFriend(segue:UIStoryboardSegue) {
        if let addFriendController = segue.sourceViewController as? AddFriendViewController {
            self.talks.append(addFriendController.createdTalk!)
            self.updateView()
        }
    }
}
