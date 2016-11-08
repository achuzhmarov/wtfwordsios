import Foundation

class RatingService: Service {
    fileprivate let APP_STORE_ID = Bundle.main.object(forInfoDictionaryKey: "APP_STORE_ID") as! String
    fileprivate let SUPPORT_EMAIL = Bundle.main.object(forInfoDictionaryKey: "SUPPORT_EMAIL") as! String

    fileprivate let APP_STORE_MAIN_URL = "itms-apps://itunes.apple.com/app/id"
    fileprivate let APP_STORE_RATING_URL = "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id="
    fileprivate let FEEDBACK_URL = "mailto:"

    fileprivate let ENJOY_TITLE = "Enjoying WTFWords".localized() + "?"
    fileprivate let ENJOY_YES_BUTTON_TEXT = "Yes".localized() + "!"
    fileprivate let ENJOY_NO_BUTTON_TEXT = "Not Really".localized()

    fileprivate let RATING_TITLE = "How about a rating on the App Store then".localized() + "?"
    fileprivate let FEEDBACK_TITLE = "Would you mind giving us some feedback".localized() + "?"
    fileprivate let OTHER_YES_BUTTON_TEXT = "Ok, Sure".localized()
    fileprivate let OTHER_NO_BUTTON_TEXT = "No, thanks".localized()

    fileprivate let guiDataService: GuiDataService

    init(guiDataService: GuiDataService) {
        self.guiDataService = guiDataService
    }

    func askUserForAppRate() {
        if (guiDataService.getAppRateStatus() == .never) {
            showEnjoyWindow()
        }
    }

    fileprivate func showEnjoyWindow() {
        WTFTwoButtonsAlert.show(ENJOY_TITLE,
                message: nil,
                firstButtonTitle: ENJOY_YES_BUTTON_TEXT,
                secondButtonTitle: ENJOY_NO_BUTTON_TEXT,
                alertButtonAction: { () -> Void in
                    self.showRatingWindow()
                }, cancelButtonAction: { () -> Void in
                    self.showFeedbackWindow()
                })
    }

    fileprivate func showRatingWindow() {
        WTFTwoButtonsAlert.show(RATING_TITLE,
                message: nil,
                firstButtonTitle: OTHER_YES_BUTTON_TEXT,
                secondButtonTitle: OTHER_NO_BUTTON_TEXT,
                alertButtonAction: { () -> Void in
                    self.guiDataService.updateAppRateStatus(.rated)
                    self.redirectToAppStore()
                }, cancelButtonAction: { () -> Void in
                    self.guiDataService.updateAppRateStatus(.enjoyed)
                })
    }

    fileprivate func showFeedbackWindow() {
        WTFTwoButtonsAlert.show(FEEDBACK_TITLE,
                message: nil,
                firstButtonTitle: OTHER_YES_BUTTON_TEXT,
                secondButtonTitle: OTHER_NO_BUTTON_TEXT,
                alertButtonAction: { () -> Void in
                    self.guiDataService.updateAppRateStatus(.feedback)
                    self.sendFeedback()
                }, cancelButtonAction: { () -> Void in
                    self.guiDataService.updateAppRateStatus(.notEnjoyed)
                })
    }

    fileprivate func redirectToAppStore() {
        let ratingUrl = URL(string: APP_STORE_RATING_URL + APP_STORE_ID)
        UIApplication.shared.openURL(ratingUrl!)
    }

    fileprivate func sendFeedback() {
        let ratingUrl = URL(string: FEEDBACK_URL + SUPPORT_EMAIL)
        UIApplication.shared.openURL(ratingUrl!)
    }
}
