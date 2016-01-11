//
//  CoreMessage+CoreDataProperties.swift
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

extension CoreMessage {

    @NSManaged var timestamp: NSDate?
    @NSManaged var talkId: String?
    @NSManaged var lastUpdate: NSDate?
    @NSManaged var author: String?
    @NSManaged var deciphered: NSNumber?
    @NSManaged var cipherType: NSNumber?
    @NSManaged var exp: NSNumber?
    @NSManaged var timerSecs: NSNumber?
    @NSManaged var hintsUsed: NSNumber?
    @NSManaged var id: String?
    @NSManaged var isLocal: NSNumber?
    @NSManaged var extId: String?
    
    @NSManaged var words: NSOrderedSet?

    @NSManaged func addWordsObject(word: CoreWord)
    @NSManaged func removeWordsObject(word: CoreWord)
    @NSManaged func addWords(words: NSOrderedSet)
    @NSManaged func removeWords(words: NSOrderedSet)
}
