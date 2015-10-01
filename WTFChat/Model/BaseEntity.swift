//
//  BaseEntity.swift
//  wttc
//
//  Created by Artem Chuzhmarov on 05/09/15.
//  Copyright (c) 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation

class BaseEntity: NSObject {
    let id: String
    
    init(id: String) {
        self.id = id;
    }
}