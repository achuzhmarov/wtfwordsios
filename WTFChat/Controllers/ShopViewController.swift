//
//  ShopViewController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 14/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class ShopViewController: UITableViewController {
    
    @IBOutlet weak var freeHintsLabel: UILabel!
    @IBOutlet weak var freeHintsBuyLabel: UILabel!
    
    @IBOutlet weak var x2HintsLabel: UILabel!
    @IBOutlet weak var x2HintsBuyLabel: UILabel!
    
    @IBOutlet weak var hints1Label: UILabel!
    @IBOutlet weak var hints1BuyLabel: UILabel!
    @IBOutlet weak var hints2Label: UILabel!
    @IBOutlet weak var hints2BuyLabel: UILabel!
    @IBOutlet weak var hints3Label: UILabel!
    @IBOutlet weak var hints3BuyLabel: UILabel!
    @IBOutlet weak var hints4Label: UILabel!
    @IBOutlet weak var hints4BuyLabel: UILabel!
    @IBOutlet weak var hints5Label: UILabel!
    @IBOutlet weak var hints5BuyLabel: UILabel!
    @IBOutlet weak var hints6Label: UILabel!
    @IBOutlet weak var hints6BuyLabel: UILabel!
    
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
    
    var detailColor: UIColor!
    var tintColor: UIColor!
    
    var isRestoreInProgress: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailColor = x2HintsBuyLabel.textColor
        tintColor = self.view.tintColor
        
        // Create a Restore Purchases button and hook it up to restoreTapped
        let restoreButton = UIBarButtonItem(title: "Restore", style: .Plain, target: self, action: "restoreTapped:")
        navigationItem.rightBarButtonItem = restoreButton
        
        // Subscribe to a notification that fires when a product is purchased.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchasedError:", name: IAPHelperProductPurchasedErrorNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productRestore:", name: IAPHelperProductRestoreNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productRestoreError:", name: IAPHelperProductRestoreErrorNotification, object: nil)
        
        updateTable()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(animated: Bool) {
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
                inAppService.restorePurchased()
        }
    }
    
    func productPurchased(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.updateTable()
        })
    }
    
    func productPurchasedError(notification: NSNotification) {
        if (notification.object != nil) {
            let productIdentifier = notification.object as! String
            
            if let productTitle = inAppService.getProductTitle(productIdentifier) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.updateTable()
                    
                    WTFOneButtonAlert.show("Error",
                        message: productTitle + " purchase error",
                        firstButtonTitle: "Ok",
                        viewPresenter: self)
                })
            }
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.updateTable()
                
                WTFOneButtonAlert.show("Error",
                    message: "Unknown error occured",
                    firstButtonTitle: "Ok",
                    viewPresenter: self)
            })
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
                        message: productTitle + " can't be restored",
                        firstButtonTitle: "Ok",
                        viewPresenter: self)
                }
            })
        }
    }
    
    func updateTable() {
        setBuyLabels(x2HintsLabel, buyTitle: x2HintsBuyLabel, productId: IAPProducts.HINTS_X2)
        
        setBuyLabels(hints1Label, buyTitle: hints1BuyLabel, productId: IAPProducts.HINTS_1)
        setBuyLabels(hints2Label, buyTitle: hints2BuyLabel, productId: IAPProducts.HINTS_2)
        setBuyLabels(hints3Label, buyTitle: hints3BuyLabel, productId: IAPProducts.HINTS_3)
        setBuyLabels(hints4Label, buyTitle: hints4BuyLabel, productId: IAPProducts.HINTS_4)
        setBuyLabels(hints5Label, buyTitle: hints5BuyLabel, productId: IAPProducts.HINTS_5)
        setBuyLabels(hints6Label, buyTitle: hints6BuyLabel, productId: IAPProducts.HINTS_6)
        
        setBuyLabels(allCiphersLabel, buyTitle: allCiphersBuyLabel, productId: IAPProducts.CIPHER_ALL)
        setBuyLabels(leftCutterLabel, buyTitle: leftCutterBuyLabel, productId: IAPProducts.CIPHER_LEFT_CUTTER)
        setBuyLabels(doubleCutterLabel, buyTitle: doubleCutterBuyLabel, productId: IAPProducts.CIPHER_DOUBLE_CUTTER)
        setBuyLabels(randomCutterLabel, buyTitle: randomCutterBuyLabel, productId: IAPProducts.CIPHER_RANDOM_CUTTER)
        setBuyLabels(shuffleLabel, buyTitle: shuffleBuyLabel, productId: IAPProducts.CIPHER_SHUFFLE)
        
        self.tableView.reloadData()
    }
    
    private func setBuyLabels(title: UILabel, buyTitle: UILabel, productId: ProductIdentifier) {
        title.text = inAppService.getProductTitle(productId)
        buyTitle.text = inAppService.getProductPrice(productId)
        
        if inAppService.canPurchase(productId) && !inAppService.isPurchased(productId) {
            buyTitle.textColor = tintColor
        } else {
            buyTitle.textColor = detailColor
        }
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
    
    private func showPurchaseAlert(productId: ProductIdentifier) {
        if (!inAppService.canPurchase(productId) || inAppService.isPurchased(productId)) {
            return
        }
        
        let productName = inAppService.getProductTitle(productId)
        let productPrice = inAppService.getProductPrice(productId)
        let productDescription = inAppService.getProductDescription(productId)
        
        WTFTwoButtonsAlert.show("Buy " + productName! + " for " + productPrice!,
            message: productDescription!,
            firstButtonTitle: "Ok",
            secondButtonTitle: "Cancel",
            viewPresenter: self) { () -> Void in
                inAppService.purchaseProduct(productId)
        }
    }
}