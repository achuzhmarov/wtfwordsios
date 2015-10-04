//
//  AlertHelper.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 04/10/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class WTFOneButtonAlert {
    var title = ""
    var message = ""
    var firstButtonTitle = ""
    var viewPresenter: UIViewController?
    
    var alertObject: AnyObject
    
    init(title: String, message: String, firstButtonTitle: String, viewPresenter: UIViewController?) {
        
        self.title = title
        self.message = message
        self.firstButtonTitle = firstButtonTitle
        self.viewPresenter = viewPresenter
        
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alertObject = alert
            
            alert.addAction(UIAlertAction(title: firstButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
                //do nothing
            }))
            
            alertObject = alert
        } else {
            let alert = UIAlertView()
            alert.title = title
            alert.message = message
            alert.addButtonWithTitle(firstButtonTitle)
            alertObject = alert
        }
    }
    
    func show() {
        if #available(iOS 8.0, *) {
            let alert = alertObject as! UIAlertController
            viewPresenter?.presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert = alertObject as! UIAlertView
            alert.show()
        }
    }
}

class WTFTwoButtonsAlert {
    var title = ""
    var message = ""
    var firstButtonTitle = ""
    var secondButtonTitle = ""
    var viewPresenter: UIViewController?
    var alertButtonAction: () -> Void
    
    var alertObject: AnyObject
    
    init(title: String, message: String, firstButtonTitle: String, secondButtonTitle: String, viewPresenter: UIViewController?, alertButtonAction:() -> Void) {
        
        self.title = title
        self.message = message
        self.firstButtonTitle = firstButtonTitle
        self.secondButtonTitle = secondButtonTitle
        self.viewPresenter = viewPresenter
        self.alertButtonAction = alertButtonAction
        
        if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alertObject = alert
            
            alert.addAction(UIAlertAction(title: firstButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
                alertButtonAction()
            }))
            
            alert.addAction(UIAlertAction(title: secondButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
                //do nothing
            }))
            
            alertObject = alert
        } else {
            let alert = UIAlertView()
            alert.title = title
            alert.message = message
            alert.addButtonWithTitle(firstButtonTitle)
            alert.addButtonWithTitle(secondButtonTitle)
            alertObject = alert
            alert.delegate = self
        }
    }
    
    func show() {
        if #available(iOS 8.0, *) {
            let alert = alertObject as! UIAlertController
            viewPresenter?.presentViewController(alert, animated: true, completion: nil)
        } else {
            let alert = alertObject as! UIAlertView
            alert.show()
        }
    }
    
    func alertView(View: UIAlertView!, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex{
        case 0:
            alertButtonAction()
            break;
        case 1:
            //Do nothing
            break;
        default:
            //Do nothing
            break;
        }
    }
}