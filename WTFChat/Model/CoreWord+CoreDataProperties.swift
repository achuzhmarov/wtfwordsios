//
//  CoreWord+CoreDataProperties.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 29/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension CoreWord {

    @NSManaged var text: String?
    @NSManaged var wordType: NSNumber?
    @NSManaged var additional: String?
    @NSManaged var cipheredText: String?
    @NSManaged var wasCloseTry: NSNumber?

}
