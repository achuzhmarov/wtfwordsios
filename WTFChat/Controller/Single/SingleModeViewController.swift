//
// Created by Artem Chuzhmarov on 31/05/16.
// Copyright (c) 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class SingleModeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    //private var ciphers: [CipherData]

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true

        //updateView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 6
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: RatingCell

        cell = tableView.dequeueReusableCellWithIdentifier("GlobalRatingCell", forIndexPath: indexPath) as! RatingCell
        //let friend = friends[indexPath.row]
        //cell.updateUser(friend, num: indexPath.row + 1)*/

        return cell
    }
}
