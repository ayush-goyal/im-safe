//
//  AlertContactFetchedResultsController.swift
//  VolunteerNow
//
//  Created by Macbook on 10/24/17.
//  Copyright © 2017 Ayush. All rights reserved.
//

import CoreData
import UIKit

class AlertContactFetchedResultsController: NSFetchedResultsController<AlertContact>, NSFetchedResultsControllerDelegate {
    
    private let tableView: UITableView
    
    init(managedObjectContext: NSManagedObjectContext, tableView: UITableView) {
        self.tableView = tableView
        // Call super initializers in order to make a fetch results controller
        super.init(fetchRequest: AlertContact.fetchRequest(), managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Sets fetched results controller delegate for functions below
        self.delegate = self
        
        tryFetch()
    }
    
    // MARK: - Helper Functions
    
    // Function to call perform fetch that already has do/catch block implemente
    func tryFetch() {
        do {
            try performFetch()
        } catch {
            print("Unresolved error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetched Results Controller Delegate
    
    // Once changes are made, table view will begin updates
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    // Depending on type fo change for row, corresponding functions are called to keep efficiency
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }
    
    // Once changes are implemented, table view ends updates
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

