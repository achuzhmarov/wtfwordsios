import Foundation
import CoreData

class CoreDataService: Service {
    private static let projectName = "WTFChat"

    private lazy var applicationDocumentsDirectory: NSURL = {
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    private lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = NSBundle.mainBundle().URLForResource(projectName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    private lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("\(projectName).sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let migrationOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                                    NSInferMappingModelAutomaticallyOption: true]

            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: migrationOptions)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()

    private lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

    func createObject(className: String) -> NSManagedObject {
        return NSEntityDescription.insertNewObjectForEntityForName(className, inManagedObjectContext: managedObjectContext)
    }

    func createFetch(className: String) -> NSFetchRequest {
        return  NSFetchRequest(entityName: className)
    }

    func executeFetch(fetchRequest: NSFetchRequest) -> [NSManagedObject] {
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest) as! [NSManagedObject]
            return results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return [NSManagedObject]()
        }
    }

    func deleteObject(item: NSManagedObject) {
        managedObjectContext.deleteObject(item)
        saveContext()
    }
}
