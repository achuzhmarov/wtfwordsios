import Foundation
import Localize_Swift

class WTFBaseAlert: NSObject, UIAlertViewDelegate  {
    @nonobjc static func presentAlert(_ alert: UIAlertController) {
        let rootViewController: UIViewController = UIApplication.shared.windows.last!.rootViewController!

        if let childController = rootViewController.presentedViewController {
            childController.present(alert, animated: true, completion: nil)
        } else {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }
}

class WTFOneButtonAlert: WTFBaseAlert  {
    static let CON_ERR = "%conError%"
    static let OK_TEXT = "Ok"

    static func show(_ title: String, message: String?, alertButtonAction:(() -> Void)? = nil) {
        show(title, message: message, firstButtonTitle: OK_TEXT.localized(), viewPresenter: nil, alertButtonAction: alertButtonAction)
    }

    static func show(_ title: String, message: String?, viewPresenter: UIViewController?, alertButtonAction:(() -> Void)? = nil) {
        show(title, message: message, firstButtonTitle: OK_TEXT.localized(), viewPresenter: viewPresenter, alertButtonAction: alertButtonAction)
    }

    static func show(_ title: String, message: String?, firstButtonTitle: String, alertButtonAction:(() -> Void)? = nil) {
        show(title, message: message, firstButtonTitle: firstButtonTitle, viewPresenter: nil, alertButtonAction: alertButtonAction)
    }

    static func show(_ title: String, message: String?, firstButtonTitle: String, viewPresenter: UIViewController?, alertButtonAction:(() -> Void)? = nil) {
        //if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title,
                message: message?.replace(CON_ERR, with: "Internet connection problem".localized()),
                preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: firstButtonTitle, style: .default, handler: { (action: UIAlertAction) in
                alertButtonAction?()
            }))

            if let presenter = viewPresenter {
                presenter.present(alert, animated: true, completion: nil)
            } else {
                presentAlert(alert)
            }

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
    static let CANCEL_TEXT = "Cancel"

    static func show(_ title: String, message: String?, firstButtonTitle: String, alertButtonAction:(() -> Void)?) {
        return WTFTwoButtonsAlert.show(title, message: message, firstButtonTitle: firstButtonTitle, secondButtonTitle: CANCEL_TEXT.localized(), alertButtonAction: alertButtonAction, cancelButtonAction: nil)
    }

    static func show(_ title: String, message: String?, firstButtonTitle: String, alertButtonAction:(() -> Void)?, cancelButtonAction:(() -> Void)?) {
        return WTFTwoButtonsAlert.show(title, message: message, firstButtonTitle: firstButtonTitle, secondButtonTitle: CANCEL_TEXT.localized(), alertButtonAction: alertButtonAction, cancelButtonAction: cancelButtonAction)
    }

    static func show(_ title: String, message: String?, firstButtonTitle: String, secondButtonTitle: String, alertButtonAction:(() -> Void)?) {
        return WTFTwoButtonsAlert.show(title, message: message, firstButtonTitle: firstButtonTitle, secondButtonTitle: secondButtonTitle, alertButtonAction: alertButtonAction, cancelButtonAction: nil)
    }

    static func show(_ title: String, message: String?, firstButtonTitle: String, secondButtonTitle: String, alertButtonAction:(() -> Void)?, cancelButtonAction:(() -> Void)?) {
        //if #available(iOS 8.0, *) {
            let alert = UIAlertController(title: title,
                message: message,
                preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: secondButtonTitle, style: .default, handler: { (action: UIAlertAction) in
                cancelButtonAction?()
            }))
            
            alert.addAction(UIAlertAction(title: firstButtonTitle, style: .default, handler: { (action: UIAlertAction) in
                alertButtonAction?()
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

    fileprivate func presentAlert() {

    }
}

class AlertWithDelegate: UIAlertView, UIAlertViewDelegate {
    var alertButtonAction: (() -> Void)?
    var cancelButtonAction: (() -> Void)?
    
    func setAlertFunction(_ alertButtonAction: (() -> Void)?) {
        self.alertButtonAction = alertButtonAction
        self.delegate = self
    }
    
    func setCancelFunction(_ cancelButtonAction: (() -> Void)?) {
        self.cancelButtonAction = cancelButtonAction
        self.delegate = self
    }
    
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int){
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
