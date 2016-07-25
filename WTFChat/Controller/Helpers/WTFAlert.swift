import Foundation

class WTFBaseAlert: NSObject, UIAlertViewDelegate  {
    class func presentAlert(alert: UIAlertController) {
        let rootViewController: UIViewController = UIApplication.sharedApplication().windows.last!.rootViewController!

        if let childController = rootViewController.presentedViewController {
            childController.presentViewController(alert, animated: true, completion: nil)
        } else {
            rootViewController.presentViewController(alert, animated: true, completion: nil)
        }
    }
}

class WTFOneButtonAlert: WTFBaseAlert  {
    static let CON_ERR = "%conError%"
    private static let connectionErrorDescription = "Internet connection problem"

    class func show(title: String, message: String?, firstButtonTitle: String, alertButtonAction:(() -> Void)? = nil) {
        //if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title,
                message: message?.replace(CON_ERR, with: connectionErrorDescription),
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: firstButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
                alertButtonAction?()
            }))

            presentAlert(alert)

        /*} else {
            let alert = AlertWithDelegate()
            alert.title = title
            alert.message = message
            alert.addButtonWithTitle(firstButtonTitle)
            alert.setAlertFunction(alertButtonAction)
            alert.show()
        }*/
    }
}

class WTFTwoButtonsAlert: WTFBaseAlert {
    class func show(title: String, message: String?, firstButtonTitle: String, secondButtonTitle: String, alertButtonAction:(() -> Void)?) {
        return WTFTwoButtonsAlert.show(title, message: message, firstButtonTitle: firstButtonTitle, secondButtonTitle: secondButtonTitle, alertButtonAction: alertButtonAction, cancelButtonAction: nil)
    }
    
    class func show(title: String, message: String?, firstButtonTitle: String, secondButtonTitle: String, alertButtonAction:(() -> Void)?, cancelButtonAction:(() -> Void)?) {
        //if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: firstButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
                alertButtonAction?()
            }))
            
            alert.addAction(UIAlertAction(title: secondButtonTitle, style: .Default, handler: { (action: UIAlertAction) in
                cancelButtonAction?()
            }))

            presentAlert(alert)

        /*} else {
            let alert = AlertWithDelegate()
            alert.title = title
            alert.message = message
            alert.addButtonWithTitle(firstButtonTitle)
            alert.addButtonWithTitle(secondButtonTitle)
            alert.setAlertFunction(alertButtonAction)
            alert.setCancelFunction(cancelButtonAction)
            alert.show()
        }*/
    }

    private func presentAlert() {

    }
}

class AlertWithDelegate: UIAlertView, UIAlertViewDelegate {
    var alertButtonAction: (() -> Void)?
    var cancelButtonAction: (() -> Void)?
    
    func setAlertFunction(alertButtonAction: (() -> Void)?) {
        self.alertButtonAction = alertButtonAction
        self.delegate = self
    }
    
    func setCancelFunction(cancelButtonAction: (() -> Void)?) {
        self.cancelButtonAction = cancelButtonAction
        self.delegate = self
    }
    
    func alertView(alertView: UIAlertView, clickedButtonAtIndex buttonIndex: Int){
        switch buttonIndex{
        case 0:
            alertButtonAction?()
            break;
        case 1:
            cancelButtonAction?()
            break;
        default:
            //Do nothing
            break;
        }
    }
}