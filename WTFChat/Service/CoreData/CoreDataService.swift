import Foundation
import CoreData

class CoreDataService: Service {
    fileprivate static let projectName = "WTFChat"

    fileprivate lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    fileprivate lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: projectName, withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    fileprivate lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("\(projectName).sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            let migrationOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
                                    NSInferMappingModelAutomaticallyOption: true]

            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: migrationOptions)
        } catch {
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }

        return coordinator
    }()

    fileprivate lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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

    func createObject(_ className: String) -> NSManagedObject {
        return NSEntityDescription.insertNewObject(forEntityName: className, into: managedObjectContext)
    }

    func createFetch(_ className: String) -> NSFetchRequest<NSFetchRequestResult> {
        return  NSFetchRequest(entityName: className)
    }

    func executeFetch(_ fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [NSManagedObject] {
        do {
            let results = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            return results
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
            return [NSManagedObject]()
        }
    }

    func deleteObject(_ item: NSManagedObject) {
        managedObjectContext.delete(item)
        saveContext()
    }
}
