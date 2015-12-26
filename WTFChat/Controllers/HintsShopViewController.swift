//
//  ShopViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 14/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class HintsShopViewController: BaseShopViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateTable()
    }
    
    let HINTS_SECTION = 1
    
    let HINTS_FREE = 0
    let HINTS_1 = 1
    let HINTS_2 = 2
    let HINTS_3 = 3
    let HINTS_4 = 4
    let HINTS_5 = 5
    let HINTS_6 = 6
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == HINTS_SECTION) {
            if (indexPath.row == HINTS_FREE) {
                showAdAlert()
            } else if (indexPath.row == HINTS_1) {
                showPurchaseAlert(IAPProducts.HINTS_1)
            } else if (indexPath.row == HINTS_2) {
                showPurchaseAlert(IAPProducts.HINTS_2)
            } else if (indexPath.row == HINTS_3) {
                showPurchaseAlert(IAPProducts.HINTS_3)
            } else if (indexPath.row == HINTS_4) {
                showPurchaseAlert(IAPProducts.HINTS_4)
            } else if (indexPath.row == HINTS_5) {
                showPurchaseAlert(IAPProducts.HINTS_5)
            } else if (indexPath.row == HINTS_6) {
                showPurchaseAlert(IAPProducts.HINTS_6)
            }
        }
    }
    
    override func productPurchased(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.performSegueWithIdentifier("hintsBought", sender: self)
        })
    }
}