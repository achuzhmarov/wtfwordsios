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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a Restore Purchases button and hook it up to restoreTapped
        let restoreButton = UIBarButtonItem(title: "Restore", style: .Plain, target: self, action: "restoreTapped:")
        navigationItem.rightBarButtonItem = restoreButton
        
        // Subscribe to a notification that fires when a product is purchased.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "productPurchased:", name: IAPHelperProductPurchasedNotification, object: nil)
        
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
        inAppService.restorePurchased()
    }
    
    // Purchase the product
    /*func buyButtonTapped(button: UIButton) {
        let product = products[button.tag]
        RageProducts.store.purchaseProduct(product)
    }*/
    
    func productPurchased(notification: NSNotification) {
        updateTable()
    }
    
    func updateTable() {
        x2HintsLabel.text = inAppService.getProductTitle(IAPProducts.HINTS_X2)
        x2HintsBuyLabel.text = inAppService.getProductPrice(IAPProducts.HINTS_X2)
        
        allCiphersLabel.text = inAppService.getProductTitle(IAPProducts.CIPHER_ALL)
        allCiphersBuyLabel.text = inAppService.getProductPrice(IAPProducts.CIPHER_ALL)
        
        leftCutterLabel.text = inAppService.getProductTitle(IAPProducts.CIPHER_LEFT_CUTTER)
        leftCutterBuyLabel.text = inAppService.getProductPrice(IAPProducts.CIPHER_LEFT_CUTTER)
        
        doubleCutterLabel.text = inAppService.getProductTitle(IAPProducts.CIPHER_DOUBLE_CUTTER)
        doubleCutterBuyLabel.text = inAppService.getProductPrice(IAPProducts.CIPHER_DOUBLE_CUTTER)
        
        randomCutterLabel.text = inAppService.getProductTitle(IAPProducts.CIPHER_RANDOM_CUTTER)
        randomCutterBuyLabel.text = inAppService.getProductPrice(IAPProducts.CIPHER_RANDOM_CUTTER)
        
        shuffleLabel.text = inAppService.getProductTitle(IAPProducts.CIPHER_SHUFFLE)
        shuffleBuyLabel.text = inAppService.getProductPrice(IAPProducts.CIPHER_SHUFFLE)
        
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
                
            } else if (indexPath.row == HINTS_X2) {
                showPurchaseAlert(IAPProducts.HINTS_X2)
            } else if (indexPath.row == HINTS_1) {
                
            } else if (indexPath.row == HINTS_2) {
                
            } else if (indexPath.row == HINTS_3) {
                
            } else if (indexPath.row == HINTS_4) {
                
            } else if (indexPath.row == HINTS_5) {
                
            } else if (indexPath.row == HINTS_6) {
                
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
        if !inAppService.canPurchase(productId) {
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