//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 06/04/21.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer:NSPersistentContainer
    
    var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func configureContexts() {
        viewContext.automaticallyMergesChangesFromParent = true
        viewContext.mergePolicy = NSMergePolicy.mergeByPropertyStoreTrump
    }
    
    func load(completion: (() -> Void)? = nil) {
        print("load")
        persistentContainer.loadPersistentStores { storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveCurrentContext()
            self.configureContexts()
            completion?()
        }
    }
    
    
    func save() throws {
        if viewContext.hasChanges {
            try viewContext.save()
        }
    }
    
    static let shared = DataController(modelName: "VirtualTourist")
    
}

extension DataController {
    func autoSaveCurrentContext(interval:TimeInterval = 30) {
        print("Saving current context")
        guard interval > 0 else {
            print("Interval < 0")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + interval) {
            self.autoSaveCurrentContext(interval: interval)
        }
    }
}
