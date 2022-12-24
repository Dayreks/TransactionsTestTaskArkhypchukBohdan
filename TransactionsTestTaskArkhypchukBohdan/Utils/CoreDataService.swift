//
//  CoreDataService.swift
//  TODOList
//
//  Created by Bohdan on 24.11.2022.
//

import Foundation
import CoreData

final class CoreDataService {
    
    lazy private var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Transactions")
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    private var context: NSManagedObjectContext { container.viewContext }
    
    private(set) static var shared: CoreDataService = .init()
    
    @discardableResult
    func create<T: NSManagedObject>(_ type: T.Type, _ handler: ((T) -> ())? = nil) -> T {
        let newObject = T(context: context)
        handler?(newObject)
        return newObject
    }
    
    func saveContext() {
        guard context.hasChanges else { return }
        
        try? context.save()
    }
    
    func write(_ handler: () -> ()) {
        handler()
        saveContext()
    }
    
    func fetch<T: NSManagedObject>(_ type: T.Type, predicate: NSPredicate?) -> [T] {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        fetchRequest.predicate = predicate
        return (try? context.fetch(fetchRequest)) ?? []
    }
    
    func delete(_ object: NSManagedObject) {
        context.delete(object)
    }
    
    
    
}


@propertyWrapper
class Fetch<T: NSManagedObject> {
    
    var wrappedValue: [T] {
        CoreDataService.shared.fetch(T.self, predicate: predicate)
    }
    
    var predicate: NSPredicate?
    
}
