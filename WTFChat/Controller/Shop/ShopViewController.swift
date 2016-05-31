//
//  ShopViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 14/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class ShopViewController: BaseShopViewController {
    private let inAppService: InAppService = serviceLocator.get(InAppService)

    @IBOutlet weak var x2HintsLabel: UILabel!
    @IBOutlet weak var x2HintsBuyLabel: UILabel!
    
    @IBOutlet weak var allCiphersLabel: UILabel!
    @IBOutlet weak var allCiphersBuyLabel: UILabel!
    @IBOutlet weak var leftCutterLabel: UILabel!
    @IBOutlet weak var leftCutterBuyLabel: UILabel!
    @IBOutlet weak var doubleCutterLabel: UILabel!
    @IBOutlet weak var doubleCutterBuyLabel: UILabel!
    @IBOutlet weak var randomCutterLabel: UILabel!
    @IBOutlet weak var randomCutterBuyLabel: UILabel!
    @IBOutlet weak var shuffleLabel: UILabel!
    @IBOutlet weak var shuffleBuyLabel: UILabel!
    
    var isRestoreInProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a Restore Purchases button and hook it up to restoreTapped
        let restoreButton = UIBarButtonItem(title: "Restore", style: .Plain, target: self, action: #selector(ShopViewController.restoreTapped(_:)))
        navigationItem.rightBarButtonItem = restoreButton
        
        // Subscribe to a notification that fires when a product is restored.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopViewController.productRestore(_:)), name: IAPHelperProductRestoreNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ShopViewController.productRestoreError(_:)), name: IAPHelperProductRestoreErrorNotification, object: nil)
        
        updateTable()
    }
    
    // Restore purchases to this device.
    func restoreTapped(sender: AnyObject) {
        WTFTwoButtonsAlert.show("Restore purchased",
            message: "Are you sure you want to restore purchased content?",
            firstButtonTitle: "Ok",
            secondButtonTitle: "Cancel",
            viewPresenter: self) { () -> Void in
                self.isRestoreInProgress = true
                self.inAppService.restorePurchased()
        }
    }
    
    func productRestore(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateTable()
            
            if (self.isRestoreInProgress) {
                self.isRestoreInProgress = false
                
                WTFOneButtonAlert.show("Success",
                    message: "Restored successfully",
                    firstButtonTitle: "Ok",
                    viewPresenter: self)
            }
        })
    }
    
    func productRestoreError(notification: NSNotification) {
        let productIdentifier = notification.object as! String
        
        if let productTitle = inAppService.getProductTitle(productIdentifier) {
            dispatch_async(dispatch_get_main_queue(), {
                self.updateTable()
                
                if (self.isRestoreInProgress) {
                    self.isRestoreInProgress = false
                    
                    WTFOneButtonAlert.show("Error",
                        message: "\(productTitle) can't be restored",
                        firstButtonTitle: "Ok",
                        viewPresenter: self)
                }
            })
        }
    }
    
    override func updateTable() {
        super.updateTable()
        
        setBuyLabels(x2HintsLabel, buyTitle: x2HintsBuyLabel, productId: IAPProducts.HINTS_X2)
        
        setBuyLabels(allCiphersLabel, buyTitle: allCiphersBuyLabel, productId: IAPProducts.CIPHER_ALL)
        setBuyLabels(leftCutterLabel, buyTitle: leftCutterBuyLabel, productId: IAPProducts.CIPHER_LEFT_CUTTER)
        setBuyLabels(doubleCutterLabel, buyTitle: doubleCutterBuyLabel, productId: IAPProducts.CIPHER_DOUBLE_CUTTER)
        setBuyLabels(randomCutterLabel, buyTitle: randomCutterBuyLabel, productId: IAPProducts.CIPHER_RANDOM_CUTTER)
        setBuyLabels(shuffleLabel, buyTitle: shuffleBuyLabel, productId: IAPProducts.CIPHER_SHUFFLE)
        
        self.tableView.reloadData()
    }
    
    let HINTS_SECTION = 1
    let CIPHERS_SECTION = 2
    
    let HINTS_FREE = 0
    let HINTS_X2 = 1
    let HINTS_1 = 2
    let HINTS_2 = 3
    let HINTS_3 = 4
    let HINTS_4 = 5
    let HINTS_5 = 6
    let HINTS_6 = 7
    
    let CIPHERS_ALL = 0
    let CIPHERS_LEFT = 1
    let CIPHERS_DOUBLE = 2
    let CIPHERS_RANDOM = 3
    let CIPHERS_SHUFFLE = 4
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == HINTS_SECTION) {
            if (indexPath.row == HINTS_FREE) {
                showAdAlert()
            } else if (indexPath.row == HINTS_X2) {
                showPurchaseAlert(IAPProducts.HINTS_X2)
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
        } else if (indexPath.section == CIPHERS_SECTION) {
            if (indexPath.row == CIPHERS_ALL) {
                showPurchaseAlert(IAPProducts.CIPHER_ALL)
            } else if (indexPath.row == CIPHERS_LEFT) {
                showPurchaseAlert(IAPProducts.CIPHER_LEFT_CUTTER)
            } else if (indexPath.row == CIPHERS_DOUBLE) {
                showPurchaseAlert(IAPProducts.CIPHER_DOUBLE_CUTTER)
            } else if (indexPath.row == CIPHERS_RANDOM) {
                showPurchaseAlert(IAPProducts.CIPHER_RANDOM_CUTTER)
            } else if (indexPath.row == CIPHERS_SHUFFLE) {
                showPurchaseAlert(IAPProducts.CIPHER_SHUFFLE)
            }
        }
    }
}