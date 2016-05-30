//
//  CoreBase.swift
//  WTFChat
//
//  Created by Artem Chuzhmarov on 29/12/15.
//  Copyright © 2015 Artem Chuzhmarov. All rights reserved.
//

import Foundation
import CoreData

let coreDataService = CoreDataService()

class CoreDataService {
    var managedContext: NSManagedObjectContext?
    
    func getContext() -> NSManagedObjectContext {
        if (managedContext == nil) {
            let appDelegate = (UIApplication.sharedApplication().delegate as! AppDelegate)
            managedContext = appDelegate.managedObjectContext
        }
        
        return managedContext!
    }
    
    func createObject(className: String) -> NSManagedObject {
        return NSEntityDescription.insertNewObjectForEntityForName(className, inManagedObjectContext: self.getContext())
    }
    
    func saveContext() {
        do {
            try getContext().save()
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func createFetch(className: String) -> NSFetchRequest {
        return  NSFetchRequest(entityName: className)
    }
    
    func executeFetch(fetchRequest: NSFetchRequest) -> [NSManagedObject] {
        do {
            let results = try getContext().executeFetchRequest(fetchRequest) as! [NSManagedObject]
            return results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return [NSManagedObject]()
        }
    }
    
    func deleteObject(item: NSManagedObject) {
        getContext().deleteObject(item)
        saveContext()
    }
}