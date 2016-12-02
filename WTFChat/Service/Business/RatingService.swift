import Foundation

class RatingService: Service {
    private let APP_STORE_ID = Bundle.main.object(forInfoDictionaryKey: "APP_STORE_ID") as! String
    private let SUPPORT_EMAIL = Bundle.main.object(forInfoDictionaryKey: "SUPPORT_EMAIL") as! String

    private let APP_STORE_MAIN_URL = "itms-apps://itunes.apple.com/app/id"
    private let APP_STORE_RATING_URL = "itms-apps://itunes.apple.com/app/viewContentsUserReviews?id="
    private let FEEDBACK_URL = "mailto:"

    private let ENJOY_TITLE = "Enjoying WTFWords".localized() + "?"
    private let ENJOY_YES_BUTTON_TEXT = "Yes".localized() + "!"
    private let ENJOY_NO_BUTTON_TEXT = "Not Really".localized()

    private let RATING_TITLE = "How about a rating on the App Store then".localized() + "?"
    private let FEEDBACK_TITLE = "Would you mind giving us some feedback".localized() + "?"
    private let OTHER_YES_BUTTON_TEXT = "Ok, Sure".localized()
    private let OTHER_NO_BUTTON_TEXT = "No, thanks".localized()

    private let UPDATE_RATING_TITLE = "How about updating your rating for new version".localized() + "?"
    private let UPDATE_FEEDBACK_TITLE = "How about updating your feedback for new version".localized() + "?"

    private let guiDataService: GuiDataService

    init(guiDataService: GuiDataService) {
        self.guiDataService = guiDataService
    }

    func askUserForAppRate() {
        switch guiDataService.getAppRateStatus() {
            case .never:
                showEnjoyWindow()
            case .rated:
                if (guiDataService.isVersionChanged()) {
                    showUpdateRatingWindow()
                    guiDataService.updateLastVersion()
                }
            case .feedback:
                if (guiDataService.isVersionChanged()) {
                    showUpdateFeedbackWindow()
                    guiDataService.updateLastVersion()
                }
            default:
                //do nothing
                return
        }
    }

    private func showEnjoyWindow() {
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

    private func showRatingWindow() {
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

    private func showUpdateRatingWindow() {
        WTFTwoButtonsAlert.show(UPDATE_RATING_TITLE,
                message: nil,
                firstButtonTitle: OTHER_YES_BUTTON_TEXT,
                secondButtonTitle: OTHER_NO_BUTTON_TEXT,
                alertButtonAction: { () -> Void in
                    self.guiDataService.updateAppRateStatus(.rated)
                    self.redirectToAppStore()
                }, cancelButtonAction: { () -> Void in
            self.guiDataService.updateAppRateStatus(.skipRateUpdate)
        })
    }

    private func showFeedbackWindow() {
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

    private func showUpdateFeedbackWindow() {
        WTFTwoButtonsAlert.show(UPDATE_FEEDBACK_TITLE,
                message: nil,
                firstButtonTitle: OTHER_YES_BUTTON_TEXT,
                secondButtonTitle: OTHER_NO_BUTTON_TEXT,
                alertButtonAction: { () -> Void in
                    self.guiDataService.updateAppRateStatus(.feedback)
                    self.sendFeedback()
                }, cancelButtonAction: { () -> Void in
            self.guiDataService.updateAppRateStatus(.skipFeedbackUpdate)
        })
    }

    private func redirectToAppStore() {
        let ratingUrl = URL(string: APP_STORE_RATING_URL + APP_STORE_ID)
        UIApplication.shared.openURL(ratingUrl!)
    }

    private func sendFeedback() {
        let ratingUrl = URL(string: FEEDBACK_URL + SUPPORT_EMAIL)
        UIApplication.shared.openURL(ratingUrl!)
    }
}
