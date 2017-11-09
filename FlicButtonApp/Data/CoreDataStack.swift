//
//  CoreDataStack.swift
//  FlicButtonApp
//
//  Created by Macbook on 11/8/17.
//  Copyright © 2017 Ayush. All rights reserved.
//

import CoreData
import Foundation

class CoreDataStack {
    
    // Create persistent container using VolunteerNow based on managed object model
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "FlicButtonApp")
        container.loadPersistentStores() { storeDescription, error in
            if let error = error as NSError? {
                fatalError("Unresolved error: \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    // Use persistent container to create managed object context
    lazy var managedObjectContext: NSManagedObjectContext = {
        let container = self.persistentContainer
        return container.viewContext
    }()
    
}

// Create extension on managed object context in order to easily save changes made
extension NSManagedObjectContext {
    func saveChanges() {
        // Check if any changes were made to context
        if self.hasChanges {
            do {
                try save()
            } catch {
                fatalError("Error: \(error.localizedDescription)")
            }
        }
    }
}












