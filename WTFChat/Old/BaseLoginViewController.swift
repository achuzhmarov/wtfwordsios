//
//  BaseLoginController.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 11/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class BaseLoginViewController: UIViewController {
    private let authService: AuthService = serviceLocator.get(AuthService)
    private let windowService: WindowService = serviceLocator.get(WindowService)

    func login(login: String, password: String) {
        authService.login(login, password: password) { user, error -> Void in
            dispatch_async(dispatch_get_main_queue(), {
                if let requestError = error {
                    if (requestError.code == HTTP_UNAUTHORIZED) {
                        WTFOneButtonAlert.show("Error", message: "Invalid credentials", firstButtonTitle: "Ok", viewPresenter: self)
                    } else {
                        WTFOneButtonAlert.show("Error", message: WTFOneButtonAlert.CON_ERR, firstButtonTitle: "Ok", viewPresenter: self)
                    }
                } else {
                    self.windowService.showMainScreen()
                }
            })
        }
    }
}