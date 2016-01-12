//
//  NSError+Extension.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 12/01/16.
//  Copyright © 2016 Artem Chuzhmarov. All rights reserved.
//

import Foundation

extension NSError {
    convenience init(code: Int, message: String) {
        self.init(domain:"com.artemchuzhmarov", code: code, userInfo:[NSLocalizedDescriptionKey : message])
    }
}